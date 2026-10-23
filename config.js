/*
 * Configuración de la web. Solo hay que tocar este archivo.
 * La clave "anon" de Supabase es pública por diseño: puede estar aquí sin problema.
 * La seguridad la ponen las reglas de la base de datos (supabase/schema.sql).
 * Si supabaseUrl o supabaseAnonKey están vacíos, la web funciona en modo ejemplo.
 */
window.APP_CONFIG = {
  club: "Padel Mes Malgrat",
  tagline: "by Mily Daub",   // aparece bajo el nombre del club
  portada: "img/portada-pistas.jpg",   // foto de cabecera por defecto (se cambia desde la pestaña Club)
  fotosTorneo: ["img/club-pelota.jpg", "img/club-atardecer.jpg", "img/portada-pistas.jpg"],  // fondo de los torneos sin cartel
  contacto: {                          // datos por defecto del pie (se cambian desde la pestaña Club)
    telefono: "937 611 533",
    email: "mesmalgrat@mesmalgrat.com",
    direccion: "Avinguda Josep Ragull i Vilaró 13, 08380 Malgrat de Mar",
  },
  supabaseUrl: "https://wffvsnrghjefikgmxclc.supabase.co",      // Supabase → Project Settings → API → Project URL
  supabaseAnonKey: "sb_publishable_hrPCzG9mI-3ecQvKEFc3OQ_yJ9Z06tU",  // Supabase → Project Settings → API → anon public
};
