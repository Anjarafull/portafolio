# Portafolio — Antoine Jacquemin Ramírez

Sitio estático de una página. Sin dependencias, sin build: es HTML y CSS.

```
index.html                          la página completa
assets/
  ecommerce-sales-intelligence.png  dashboard del caso de e-commerce
  caso-ecommerce-sales-intelligence.pdf
  CV-Antoine-Jacquemin-ES.pdf       el botón "Descargar CV"
  CV-Antoine-Jacquemin-EN.pdf       el botón "CV en inglés"
proyectos/
  growth-analytics-fintech.html     dashboard interactivo enlazado desde la tarjeta
```

## Estructura de cada proyecto

Cada uno de los 6 proyectos tiene dos piezas:

| Pieza | Dónde vive |
|---|---|
| Portada 16:10 | `assets/<slug>.png` — es la miniatura de la tarjeta |
| Caso de estudio en PDF | `casos/<slug>.pdf` — el botón "Descargar el caso" |

Los slugs son: `finemetrix`, `cartera`, `multisucursal`, `customer-health-score`,
`growth-analytics-fintech`, `ecommerce-sales-intelligence`.

Dos portadas son capturas reales del tablero (e-commerce y growth fintech). Las otras
cuatro son portadas de caso diseñadas, con el título, las herramientas y —donde hay
cifras verificables— sus métricas. Si consigues la captura real de alguno, sustituye
el PNG con el mismo nombre y listo: la tarjeta la toma sola.

Las portadas y los PDFs se regeneran con los scripts del scratchpad
(`casos_contenido.py` tiene todo el texto, `render_casos.py` los dibuja).

## Ver el sitio en local

Basta abrir `index.html` en el navegador. Si prefieres servirlo:

```bash
python -m http.server 8000
```

Y entra a http://localhost:8000

## Publicar en GitHub Pages

1. Crea un repositorio **público** en GitHub llamado `portafolio` (o el nombre que quieras).
2. Desde esta carpeta:

```bash
git remote add origin https://github.com/USUARIO/portafolio.git
```

```bash
git push -u origin main
```

3. En GitHub: **Settings → Pages → Source: Deploy from a branch → Branch: `main` / `(root)`** y guarda.
4. En un par de minutos el sitio queda en `https://USUARIO.github.io/portafolio/`.

Sustituye `USUARIO` por tu usuario de GitHub. Cada `git push` posterior actualiza el sitio.
