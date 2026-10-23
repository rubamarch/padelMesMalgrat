/*
 * Configuración de la web. Solo hay que tocar este archivo.
 * La clave "anon" de Supabase es pública por diseño: puede estar aquí sin problema.
 * La seguridad la ponen las reglas de la base de datos (supabase/schema.sql).
 * Si supabaseUrl o supabaseAnonKey están vacíos, la web funciona en modo ejemplo.
 */
window.APP_CONFIG = {
  club: "Padel Mes Malgrat",
  tagline: "by Mily Daub",   // aparece bajo el nombre del club
  supabaseUrl: "https://wffvsnrghjefikgmxclc.supabase.co",      // Supabase → Project Settings → API → Project URL
  supabaseAnonKey: "sb_publishable_hrPCzG9mI-3ecQvKEFc3OQ_yJ9Z06tU",  // Supabase → Project Settings → API → anon public
};
