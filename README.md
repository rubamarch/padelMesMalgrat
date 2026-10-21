# Padel Mes Malgrat · Torneos

Web de los torneos del club: portada con carteles, inscripción de parejas, horario de partidos, cuadros
y un configurador para los organizadores.

- **Web:** https://padelmesmalgrat.github.io (GitHub Pages, gratis)
- **Datos:** Supabase (plan gratuito)
- **Coste:** 0 €

## Qué ve cada uno

| Estado del torneo | Jugadores |
|---|---|
| Inscripción abierta | Información · Inscripción |
| Inscripción cerrada | Información |
| En juego / Finalizado | Horario · Cuadros · Parejas · Mi pareja · Información |
| Oculto | No aparece |

Los **organizadores** entran con "Acceso organizador" (al pie de la página) y además pueden:
crear y borrar torneos, editar sus datos y subir el cartel, cambiar el estado, ver las inscripciones con
teléfono y extras, marcar quién ha pagado, pasar las inscripciones al cuadrante, editar parejas,
generar y retocar el horario, y cambiar los ajustes (días, horas, pistas, categorías, niveles, finales).

## Archivos

| Archivo | Para qué |
|---|---|
| `index.html` | La web completa |
| `config.js` | Nombre del club y conexión a Supabase. **Es el único archivo que hay que tocar.** |
| `supabase/schema.sql` | Tablas, reglas de seguridad y funciones de la base de datos |
| `.github/workflows/mantener-activo.yml` | Consulta Supabase cada 3 días para que no se pause |

Si `config.js` no tiene los datos de Supabase, la web funciona en **modo ejemplo** (datos inventados,
contraseña de organizador `1234`). Sirve para verla antes de conectarla.

## Puesta en marcha (una sola vez)

### 1. Base de datos

1. En https://supabase.com crea un proyecto (plan Free, región Europa).
2. Ve a **SQL Editor → New query**, pega todo el contenido de `supabase/schema.sql` y pulsa **Run**.
3. En **Project Settings → API Keys** copia la **Project URL** y la clave pública
   (*publishable* o *anon*). **Nunca** uses la clave *secret* / *service_role* en la web.
4. Ponlas en `config.js`.

### 2. Organizadores

1. **Authentication → Users → Add user → Create new user**: correo y contraseña, con
   *Auto Confirm User* marcado.
2. En **SQL Editor** ejecuta (cambiando el correo):

   ```sql
   insert into public.admins (user_id)
   select id from auth.users where email = 'tu-correo@ejemplo.com';
   ```

3. Repite para cada organizador.
4. Recomendado: **Authentication → Sign In / Providers → Email** → desactiva
   *Allow new users to sign up*. Aunque alguien se registrara, no tendría permisos, pero así es más limpio.

### 3. Web

El repositorio se llama `padelmesmalgrat.github.io` dentro de la organización `padelmesmalgrat`,
así que GitHub Pages lo publica solo en https://padelmesmalgrat.github.io.
Si no aparece: **Settings → Pages → Source: Deploy from a branch → main / (root)**.

## Uso habitual

1. **Nuevo torneo**: entra como organizador → portada → **+ Nuevo torneo**. Se crea *Oculto*.
2. En **Configurador**: completa los datos, sube el cartel y revisa los ajustes (días, horas,
   categorías y niveles: el formulario de inscripción usa estos mismos valores).
3. Cambia el estado a **Inscripción abierta** y comparte el enlace (botón *Copiar enlace del torneo*).
4. Al cerrar inscripciones: **Pasar al cuadrante** → revisa **Parejas** → **Generar horario** en
   **Horario** → estado **En juego**. Desde ese momento los jugadores ven horarios y cuadros.

## Seguridad y privacidad

- El público solo puede leer torneos publicados e inscribirse (función `inscribir`, que valida estado,
  plazas, categoría, nivel y horarios).
- Teléfonos, extras y pagos solo los ven los organizadores (reglas RLS en `schema.sql`).
- La clave pública de Supabase puede estar en `config.js`: la seguridad la ponen esas reglas.
