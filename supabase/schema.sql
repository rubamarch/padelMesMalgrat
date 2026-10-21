-- =====================================================================
-- Padel Mes Malgrat · base de datos (Supabase)
-- Pégalo entero en Supabase → SQL Editor → New query → Run.
-- Se puede ejecutar más de una vez sin perder datos.
-- =====================================================================

-- ---------- tablas ----------
create table if not exists public.torneos (
  id          text primary key,
  nombre      text not null,
  fechas      text not null default '',
  lugar       text not null default '',
  precio      text not null default '',
  plazas      integer not null default 0 check (plazas >= 0),
  estado      text not null default 'oculto'
              check (estado in ('abierta', 'cerrada', 'juego', 'finalizado', 'oculto')),
  descripcion text not null default '',
  cartel      text not null default '',
  orden       integer not null default 0,
  creado      timestamptz not null default now()
);

create table if not exists public.inscripciones (
  id         uuid primary key default gen_random_uuid(),
  torneo_id  text not null references public.torneos(id) on delete cascade,
  creado     timestamptz not null default now(),
  jugador    text not null,
  companero  text not null,
  telefono   text not null default '',
  categoria  text not null,
  nivel      text not null,
  disp       jsonb not null default '{}'::jsonb,
  extras     text not null default '',
  pagado     boolean not null default false
);
create index if not exists inscripciones_torneo on public.inscripciones (torneo_id);

-- El cuadrante de cada torneo (ajustes, parejas y horario) como un documento JSON.
create table if not exists public.cuadrantes (
  torneo_id   text primary key references public.torneos(id) on delete cascade,
  datos       jsonb not null,
  actualizado timestamptz not null default now()
);

-- Quién es organizador. Se añaden a mano (ver README).
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  creado  timestamptz not null default now()
);

-- ---------- ¿es organizador quien hace la petición? ----------
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- ---------- seguridad por filas ----------
alter table public.torneos       enable row level security;
alter table public.inscripciones enable row level security;
alter table public.cuadrantes    enable row level security;
alter table public.admins        enable row level security;

drop policy if exists torneos_leer on public.torneos;
drop policy if exists torneos_admin on public.torneos;
create policy torneos_leer  on public.torneos for select using (estado <> 'oculto' or public.is_admin());
create policy torneos_admin on public.torneos for all using (public.is_admin()) with check (public.is_admin());

-- Las inscripciones solo las ve y toca el organizador. Los jugadores se inscriben con la función inscribir().
drop policy if exists inscripciones_admin on public.inscripciones;
create policy inscripciones_admin on public.inscripciones for all using (public.is_admin()) with check (public.is_admin());

-- El cuadrante completo (con teléfonos) solo el organizador. El público lo lee limpio con get_torneo().
drop policy if exists cuadrantes_admin on public.cuadrantes;
create policy cuadrantes_admin on public.cuadrantes for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists admins_yo on public.admins;
create policy admins_yo on public.admins for select using (user_id = auth.uid());

-- ---------- funciones públicas ----------
-- Lista de torneos para la portada.
create or replace function public.get_torneos() returns json
language sql stable security definer set search_path = public as $$
  select coalesce(json_agg(x order by x.orden, x.creado desc), '[]'::json) from (
    select t.id, t.nombre, t.fechas, t.lugar, t.precio, t.plazas, t.estado, t.descripcion, t.cartel, t.orden, t.creado,
           (select count(*) from public.inscripciones i where i.torneo_id = t.id) as inscritas,
           coalesce(jsonb_array_length(c.datos -> 'pairs'), 0) as parejas,
           coalesce(c.datos -> 'config' -> 'categories', '["Masculino","Femenino"]'::jsonb) as categorias,
           coalesce(c.datos -> 'config' -> 'levels', '["A","B","C"]'::jsonb) as niveles
    from public.torneos t
    left join public.cuadrantes c on c.torneo_id = t.id
    where t.estado <> 'oculto' or public.is_admin()
  ) x;
$$;

-- Un torneo con su cuadrante, sin teléfonos ni notas privadas.
create or replace function public.get_torneo(p_id text) returns json
language plpgsql stable security definer set search_path = public as $$
declare
  t public.torneos;
  c jsonb;
begin
  select * into t from public.torneos where id = p_id and (estado <> 'oculto' or public.is_admin());
  if not found then
    raise exception 'Este torneo no existe o ya no está publicado.';
  end if;
  select datos into c from public.cuadrantes where torneo_id = p_id;
  if c is not null and jsonb_typeof(c -> 'pairs') = 'array' then
    c := jsonb_set(c, '{pairs}', coalesce(
      (select jsonb_agg(p - 'tel' - 'extras' - 'note' - 'src') from jsonb_array_elements(c -> 'pairs') p), '[]'::jsonb));
  end if;
  return json_build_object(
    'torneo', to_jsonb(t) || jsonb_build_object('inscritas', (select count(*) from public.inscripciones where torneo_id = p_id)),
    'cuadrante', c);
end;
$$;

-- Inscripción de una pareja (la única forma de escribir para el público).
create or replace function public.inscribir(p jsonb) returns json
language plpgsql volatile security definer set search_path = public as $$
declare
  t public.torneos;
  cfg jsonb;
  n integer;
  dia text;
  x jsonb;
  disp jsonb := '{}'::jsonb;
  alguno boolean := false;
begin
  select * into t from public.torneos where id = p ->> 'torneoId' for update;
  if not found or t.estado <> 'abierta' then
    raise exception 'Este torneo ya no está abierto a inscripciones.';
  end if;
  select count(*) into n from public.inscripciones where torneo_id = t.id;
  if t.plazas > 0 and n >= t.plazas then
    raise exception 'El torneo está completo.';
  end if;
  if coalesce(btrim(p ->> 'jugador'), '') = '' or coalesce(btrim(p ->> 'companero'), '') = '' then
    raise exception 'Faltan los nombres de la pareja.';
  end if;

  select datos -> 'config' into cfg from public.cuadrantes where torneo_id = t.id;
  if not coalesce(cfg -> 'categories', '["Masculino","Femenino"]'::jsonb) ? (p ->> 'categoria') then
    raise exception 'Elige una categoría.';
  end if;
  if not coalesce(cfg -> 'levels', '["A","B","C"]'::jsonb) ? (p ->> 'nivel') then
    raise exception 'Elige un nivel.';
  end if;

  foreach dia in array array['jue', 'vie', 'sab', 'dom'] loop
    x := p -> 'disponibilidad' -> dia;
    if x is not null and (x ->> 'disponible')::boolean then
      if (x ->> 'desde') !~ '^\d\d:\d\d$' or (x ->> 'hasta') !~ '^\d\d:\d\d$' or (x ->> 'desde') >= (x ->> 'hasta') then
        raise exception 'Revisa los horarios: la hora de inicio debe ser anterior a la de fin.';
      end if;
      disp := disp || jsonb_build_object(dia, (x ->> 'desde') || '-' || (x ->> 'hasta'));
      alguno := true;
    end if;
  end loop;
  if not alguno then
    raise exception 'Marca al menos un día en el que podáis jugar.';
  end if;

  insert into public.inscripciones (torneo_id, jugador, companero, telefono, categoria, nivel, disp, extras)
  values (t.id, left(btrim(p ->> 'jugador'), 120), left(btrim(p ->> 'companero'), 120),
          left(coalesce(btrim(p ->> 'telefono'), ''), 40), p ->> 'categoria', p ->> 'nivel', disp,
          left(coalesce(btrim(p ->> 'extras'), ''), 1000));
  return json_build_object('ok', true);
end;
$$;

revoke all on function public.get_torneos() from public;
revoke all on function public.get_torneo(text) from public;
revoke all on function public.inscribir(jsonb) from public;
grant execute on function public.is_admin() to anon, authenticated;
grant execute on function public.get_torneos() to anon, authenticated;
grant execute on function public.get_torneo(text) to anon, authenticated;
grant execute on function public.inscribir(jsonb) to anon, authenticated;

-- ---------- carteles (imágenes) ----------
insert into storage.buckets (id, name, public)
values ('carteles', 'carteles', true)
on conflict (id) do update set public = true;

drop policy if exists carteles_admin_subir on storage.objects;
drop policy if exists carteles_admin_cambiar on storage.objects;
drop policy if exists carteles_admin_borrar on storage.objects;
create policy carteles_admin_subir   on storage.objects for insert with check (bucket_id = 'carteles' and public.is_admin());
create policy carteles_admin_cambiar on storage.objects for update using (bucket_id = 'carteles' and public.is_admin());
create policy carteles_admin_borrar  on storage.objects for delete using (bucket_id = 'carteles' and public.is_admin());
