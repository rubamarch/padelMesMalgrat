// Copia la web (index.html + config.js) dentro de www/ para empaquetarla en la app.
// Los iconos y la pantalla de arranque se generan a partir de iconos/ con @capacitor/assets (carpeta assets/).
import { mkdirSync, copyFileSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const app = join(dirname(fileURLToPath(import.meta.url)), "..");
const web = join(app, "..");
const www = join(app, "www");

rmSync(www, { recursive: true, force: true });
mkdirSync(join(www, "app-movil", "iconos"), { recursive: true });
copyFileSync(join(web, "index.html"), join(www, "index.html"));
copyFileSync(join(web, "config.js"), join(www, "config.js"));
for (const f of ["icon-192.png", "apple-touch-icon.png"]) copyFileSync(join(app, "iconos", f), join(www, "app-movil", "iconos", f));
copyFileSync(join(app, "manifest.webmanifest"), join(www, "app-movil", "manifest.webmanifest"));

// fuentes para @capacitor/assets, generadas a partir del logo (no se guardan en el repositorio)
const sharp = (await import("sharp")).default;
const logo = join(app, "iconos", "icon-512.png");
const assets = join(app, "assets");
mkdirSync(assets, { recursive: true });
const lienzo = (size, bg) => sharp({ create: { width: size, height: size, channels: 4, background: bg } });
const centrado = async (size, frac, bg, out) => {
  const s = Math.round(size * frac), img = await sharp(logo).resize(s, s).toBuffer();
  await lienzo(size, bg).composite([{ input: img, gravity: "center" }]).png().toFile(join(assets, out));
};
const blanco = { r: 255, g: 255, b: 255, alpha: 1 }, nada = { r: 0, g: 0, b: 0, alpha: 0 };
await centrado(1024, .86, blanco, "icon-only.png");          // icono clásico
await centrado(1024, .60, nada, "icon-foreground.png");      // icono adaptativo de Android (zona segura)
await lienzo(1024, blanco).png().toFile(join(assets, "icon-background.png"));
await centrado(2732, .22, blanco, "splash.png");             // pantalla de arranque
await centrado(2732, .22, blanco, "splash-dark.png");
console.log("www/ y assets/ listos");
