# App móvil

App nativa de **Mes Malgrat** para Android (y más adelante iPhone), hecha con [Capacitor](https://capacitorjs.com).
La web (`index.html` y `config.js`) va **dentro** de la app: se instala desde un APK o desde Google Play, arranca con
la pantalla del logo, tiene el botón atrás de Android, y los PDF y Excel se comparten con el menú del móvil
(WhatsApp, Drive, correo…). Los datos (torneos, horarios, parejas) salen de Supabase, igual que en la web.

## Descargar la app de prueba

Cada vez que cambia la web o esta carpeta, GitHub compila la app sola (pestaña **Actions → App Android**, unos 5 min)
y la deja en **Releases → App Android** del repositorio:

https://github.com/rubamarch/padelMesMalgrat/releases/tag/app-android

Enlace directo al APK (siempre la última versión):
https://github.com/rubamarch/padelMesMalgrat/releases/download/app-android/mes-malgrat.apk

Ábrelo desde el móvil, descarga `mes-malgrat.apk` e instálalo. Android pedirá permiso para instalar apps de esa
fuente (Chrome o Archivos). Las siguientes versiones se instalan encima, sin desinstalar.

## Archivos

| Archivo | Para qué |
|---|---|
| `capacitor.config.json` | Nombre de la app, identificador (`com.mesmalgrat.torneos`), pantalla de arranque y barra de estado |
| `package.json` | Versiones de Capacitor y sus módulos |
| `scripts/preparar.mjs` | Copia la web a `www/` y genera el icono adaptativo y la pantalla de arranque a partir del logo |
| `iconos/` | El logo en varios tamaños: icono de la app, de la web instalada y del iPhone |
| `manifest.webmanifest` | Para instalar la web desde el navegador (sigue funcionando aparte de la app) |
| `debug.keystore` | Firma de las versiones **de prueba** (es pública a propósito). Para Google Play se usará otra firma, privada, que no va en el repositorio |
| `../.github/workflows/app-android.yml` | La compilación automática (GitHub obliga a que esté en esa carpeta) |

`android/`, `www/`, `assets/` y `node_modules/` se generan al compilar y no se suben.

## Compilar en un ordenador (opcional)

Hace falta Node 22, Java 21 y el Android SDK (o Android Studio):

```bash
cd app-movil
npm ci
npm run android          # crea android/ con la web, iconos y pantalla de arranque
cd android && ./gradlew assembleDebug
# APK en android/app/build/outputs/apk/debug/app-debug.apk
```

## Próximos pasos

1. Notificaciones push (horario publicado, recordatorio del partido).
2. Google Play: cuenta de desarrollador (25 $, pago único) y firma privada de publicación.
3. iPhone / App Store (99 $/año). Se compila en la nube porque hace falta un Mac.

## Instalar la web sin la app

- **Android (Chrome):** menú ⋮ → **Instalar aplicación**.
- **iPhone (Safari):** compartir → **Añadir a pantalla de inicio**.
