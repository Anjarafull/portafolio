# Mod Porsche conducible para inZOI — estado y plan

> Notas de investigación del 5 sep 2026. Página con checklist marcable:
> https://claude.ai/code/artifact/b9695338-b27c-4dd8-96f8-047a6080e64a

## Dónde quedó el proyecto

- Sesión de origen: **«Una misión para ti»** (`session_01AVicWagbzNvLqkHJu6U2wD`),
  22–24 ago 2026, corriendo por Remote Control sobre la PC de casa. Archivada.
- Último estado registrado: *"rebuilding Porsche mod in UE5.6.1; reimporting mesh from FBX"*.
- Sesión hermana: **«Acceso a Blender desde Codex»** (`session_01BvSuMpa17CLGK6JZ3gZok5`),
  22–29 ago 2026, quedó abierta con la pregunta *"¿La refuerzo?"* sin responder.
- Los archivos (`.uproject`, FBX, blend) viven en el disco de esa PC. No hay nada
  del mod en este repositorio.

## La bifurcación

Los vehículos **no son una categoría del ModKit oficial**. Eso deja dos caminos:

| Ruta | Cómo | Resultado |
|---|---|---|
| ModKit oficial | UE 5.6.1, plugin Blender/Maya, FBX + JSON, publica en CurseForge. Cubre ropa, muebles, accesorios | Prop decorativo. **Nunca conducible** |
| Reemplazo de malla | Sustituir la malla de un coche base del juego, empaquetar en `.pak` | **Conducible** — hereda esqueleto, físicas y lógica de la base |

La versión de engine que se estaba usando (**UE 5.6.1**) era la correcta: el juego
saltó a UE 5.6 el 29 abr 2026 (v0.8.0) y el ModKit se actualizó a la par.

### "Coche nuevo" no es una tercera ruta

El catálogo de vehículos es cerrado — tanto que existe un mod dedicado solo a
desbloquear coches ya presentes pero ocultos en el menú de compra del teléfono.
Añadir una entrada exigiría sobrescribir la tabla del catálogo completa: se sigue
pagando el costo del reemplazo, cada parche que toque esa tabla tumba el mod, y
dos mods que lo intenten chocan. No verificado para inZOI, y desaconsejable.

Señales de que la ruta real es reemplazo: el lenguaje de la comunidad asume una
base ("funciona con cualquier coche, pero sedán y SUV son los más amigables";
"las puertas funcionan si *reemplazas* bien las mallas"), el ModKit no soporta
vehículos, y la tilde de `~mods` existe precisamente para pisar el original.

## Secuencia de ejecución

1. Confirmar que la instalación del juego está en UE 5.6.x.
2. Abrir el `.uproject` del Porsche en UE 5.6.1 y verificar que carga limpio.
3. Revisar el reimport del FBX — es donde se quedó la sesión de agosto.
4. **COMPUERTA** — Probar que un `.pak` con malla propia carga. Prueba mínima:
   un `.pak` que sobrescriba la malla de un coche base con una geometría
   cualquiera. Si aparece en juego, la ruta está abierta.
   No confundir mecanismos: el *coming soon* de "custom user meshes" es de
   Mod Menu v2, que corre sobre **UE4SS** e intercambia en tiempo real piezas ya
   cargadas en el juego. Eso es distinto de un `.pak` que sobrescribe un asset en
   disco; la limitación de esa herramienta no dice nada sobre esta ruta.
5. Elegir coche base **por conteo de puertas y distancia entre ejes**, no por
   categoría. Sedán y SUV son las bases más dóciles pero tienen cuatro puertas, y
   el 911 tiene dos: sobre una base de cuatro, las traseras siguen en el esqueleto
   y en la lógica, y el juego intentará abrirlas. O se busca una base de dos
   puertas, o se les entrega geometría vacía. Es el factor que más trabajo ahorra
   o cuesta en los pasos 6 y 8.
6. Auditar el Porsche contra la base: nombres y conteo de mallas de puerta,
   esqueleto, colisión. Las puertas solo funcionan si sus mallas se reemplazan bien.
7. Empaquetar `.pak` → `BlueClient\Content\Paks\~mods\` (carpeta que
   probablemente haya que crear a mano). La tilde va **al inicio**: fuerza la
   carga posterior a los archivos base, que es el mecanismo por el que el mod
   sobrescribe el original. Al reves no pisa nada.
8. Probar en orden: aparece → el Zoi entra → **conduce** → abren las puertas.
9. Retomar la sesión de Blender.

## Confianza de las fuentes

Toda la investigación salió de fragmentos de buscador. La política de red rechazó
*todos* los dominios probados — Nexus, Patreon, CurseForge, `mod-docs.playinzoi.com`,
`forum.playinzoi.com`, los sitios de la comunidad, YouTube y hasta Wikipedia.
Ninguna página pudo abrirse de primera mano.

**Alta confianza:** el salto a UE 5.6 y su fecha; la actualización del ModKit;
que los vehículos no son categoría soportada.

**Alta tambien:** la carpeta es `~mods` con la tilde al inicio, y esa posicion es
lo que fuerza la carga posterior a los archivos base.

**Media:** que el reemplazo produce coches conducibles y que las puertas dependen
de sus mallas; que Mod Menu v2 corre sobre UE4SS.

**Sin verificar:** el mod del correo de Patreon del 4 sep 2026 y su supuesta
etiqueta "full drivable" (el texto del cuerpo nunca fue visible en la captura);
quién lo firma. El coche de la foto es un **Toyota Supra A90**, no un Porsche.

**Contradicho:** que "wickedzoy" haya sacado un mod de coche. Lo indexado bajo ese
nombre es **WickedZoi**, un mod adulto distribuido por Patreon e itch.io, con una
nota de prensa cuestionando si es estafa. Ningún resultado lo liga a vehículos.
Precaución con cualquier descarga de esa fuente.
