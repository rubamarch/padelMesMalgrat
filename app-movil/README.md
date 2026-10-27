# App móvil

La web se puede instalar como una app en el móvil: icono del club en la pantalla de inicio, se abre a pantalla
completa sin la barra del navegador y se actualiza sola cada vez que cambia la web (no hay que volver a instalarla).

| Archivo | Para qué |
|---|---|
| `manifest.webmanifest` | Nombre, colores e iconos de la app. Lo enlaza `index.html` |
| `iconos/icon-192.png`, `iconos/icon-512.png` | Icono normal (logo sobre fondo transparente) |
| `iconos/maskable-512.png` | Icono para Android: logo sobre blanco con margen, para que el móvil lo recorte en círculo o cuadrado sin cortar las letras |
| `iconos/apple-touch-icon.png` | Icono para iPhone (sin transparencia) |

Son las únicas imágenes del repositorio: las demás (logo de la web, portada, carátula) se suben desde la pestaña *Club*.

## Instalarla sin tienda

- **Android (Chrome):** abre https://rubamarch.github.io/padelMesMalgrat/ → menú ⋮ → **Instalar aplicación**.
- **iPhone (Safari):** abre la web → botón compartir → **Añadir a pantalla de inicio**.

## Crear la APK y subirla a Google Play

1. Entra en https://www.pwabuilder.com, pega `https://rubamarch.github.io/padelMesMalgrat/` y pulsa **Start**.
2. **Package for stores → Android → Generate package**. Deja el *Package ID* que propone o pon uno tuyo
   (por ejemplo `com.mesmalgrat.torneos`) y **guárdalo: no se puede cambiar después**.
3. Descarga el ZIP. Dentro están:
   - el archivo `.aab` (es el que se sube a Google Play) y un `.apk` para probarla en tu móvil;
   - `signing.keystore` y `signing-key-info.txt`: **guárdalos en un sitio seguro y NO los subas a GitHub**.
     Sin ellos no podrás publicar actualizaciones de la app con el mismo nombre.
   - `assetlinks.json`: para que la app se abra sin la barra del navegador (paso 5).
4. Crea la cuenta en https://play.google.com/console (pago único de 25 $), crea la app y sube el `.aab`.
5. Pásame el `assetlinks.json` y lo coloco en la web. Hay que ponerlo en
   `https://rubamarch.github.io/.well-known/assetlinks.json`, que es otro repositorio (`rubamarch.github.io`),
   no este. Si no se pone, la app funciona igual pero enseña una barra pequeña con la dirección arriba.
