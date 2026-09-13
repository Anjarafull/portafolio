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
   **Revisar tambien los coches ocultos** (ver abajo): el clasico es el candidato
   a dos puertas, y pisar un coche que estaba oculto de todos modos vuelve casi
   nulo el costo del reemplazo, a cambio de depender del mod que los destapa.
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

## Contenido oculto en el juego

Hay cuatro vehiculos completos que no aparecen en el menu de compra del telefono,
con precio ya asignado — no son restos a medio hacer:

| Coche | Precio |
|---|---|
| Clasico | $15,000 |
| Pickup | $40,000 |
| STARIA | $20,000 |
| IONIQ 9 | $50,000 |

Los destapa un mod de **Yocodream** (Nexus 337 / CurseForge "Vehicles Unlocked").
STARIA e IONIQ 9 son Hyundai, coreana igual que KRAFTON: parece un acuerdo de
marca preparado y no activado, mas que contenido olvidado.

Implicaciones para este proyecto:

- El **clasico** es el candidato a base de dos puertas que le falta al 911.
  Habria que abrirlo y medir carroceria y distancia entre ejes; su forma no esta
  verificada.
- Reemplazar un coche oculto no le quita nada al jugador, asi que el costo
  habitual del reemplazo (perder el original) casi desaparece.
- Que la via comunitaria para "mas coches" sea destapar entradas existentes y no
  anadirlas refuerza que el catalogo es una lista fija con bandera de visibilidad.

## Migrar a la version actual (13 sep 2026)

El juego paso de la v0.8.0 de abril a la **v0.10.0 el 3 de septiembre** (update
"Vacations"), mas el hotfix **v0.10.1** y correcciones el 9 y el 10 de septiembre.
Build Windows Steam del parche base: `20260902.14983.W`.

### Primero: reactivar, no diagnosticar

El juego **desactiva todos los mods automaticamente** cuando se aplica un parche,
por estabilidad, y hay que reactivarlos a mano. Un mod que "dejo de funcionar"
puede estar simplemente apagado. Separar lo desactivado de lo roto antes de tocar
un solo archivo.

### Cada tipo se rompe distinto

| Tipo | Que lo rompe |
|---|---|
| Mods de ModKit (ropa, muebles, accesorios) | Cambios en el propio ModKit. Se actualiza desde Steam y se reempaquetan. El parche de septiembre toco el ModKit y corrigio los mods creados duplicando datos de DLC. |
| `.pak` en `~mods` (reemplazo de assets) | Que el parche haya movido o renombrado el asset original que sobrescribes. Causa numero uno de rotura silenciosa: el mod carga y no pasa nada. |
| UE4SS (Mod Menu y similares) | Lo mas fragil: engancha estructuras en memoria, cualquier recompilacion lo desalinea. Depende de que su autor lo actualice. |

### Orden de trabajo

1. Reactivar todo y anotar que falla de verdad.
2. Actualizar el ModKit desde Steam antes de reabrir ningun proyecto.
3. Para cada `.pak`, verificar que la ruta del asset que pisa sigue existiendo con
   el mismo nombre.
4. Reempaquetar y probar **de uno en uno**, nunca todos a la vez.

Romperse en cada version es lo normal aqui, no la excepcion: hay hilos de usuarios
reportando 40 de 139 mods muertos tras un parche de ModKit. Presupuestar el
reempaquetado como mantenimiento recurrente.

### Inventario (barrido del 13 sep 2026)

Revisadas las 24 sesiones de la cuenta. **De inZOI hay una sola linea de trabajo**,
no varias:

| Sesion | Cuando | Estado |
|---|---|---|
| "Una mision para ti" (`session_01AVicWagbzNvLqkHJu6U2wD`) | 22-24 ago | El Porsche. Reimportando malla desde FBX en UE 5.6.1 |
| "Acceso a Blender desde Codex" (`session_01BvSuMpa17CLGK6JZ3gZok5`) | 22-29 ago | Rama de modelado que lo alimentaba. Colgada en "¿La refuerzo?" |
| "Inzoi mod coche conducible" (`session_01AavtwTEfGEnueSXrQEhNUP`) | 5-13 sep | Solo investigacion, sin archivos |

Los otros proyectos de modding son **de otros juegos** y no entran aqui:
Minecraft (barco Prinz Eugen, jar compilado e instalado en `a0a4b75`, pendiente de
prueba en juego), Soulmask (Galeon San Felipe), e impresion 3D (Mewtwo, Taller 3D).

Sin clasificar: "Shaders y assets para adultos" (`session_01C7DWHwrfdt2KGnMZ8EAbfX`,
8-9 sep, en la PC). El titulo no dice a que juego pertenece.

### Consecuencia: no hay nada roto

El Porsche nunca se empaqueto ni se instalo, asi que la v0.10 no tumbo nada. Esto
no es un trabajo de reparacion sino de terminar algo a medias — y en el punto mas
barato para migrar, porque quedo en el reimport de la malla y no en el empaquetado.

### Lo que no se puede hacer en remoto

Verificar que un mod funciona exige **correr el juego**: arrancar inZOI, comprar el
coche y conducirlo. Ninguna herramienta remota sustituye eso. Para trabajar sobre
los archivos hace falta Remote Control desde la PC; las sesiones bridge vienen
marcando `computer_unreachable`.

## Ideas de mods de jugabilidad (pendientes, no empezadas)

Recordadas por el usuario el 13 sep 2026, sin chat localizable que las respalde:
mercado negro, drogas, alcohol, cuchillo, "un mundo mas vivo", y gasolina.

**No se encontro el chat de origen.** Los dos unicos candidatos sin clasificar
("Shaders y assets para adultos" `session_01C7DWHwrfdt2KGnMZ8EAbfX` del 8-9 sep, y
"Una mision para ti" `session_01HUeAcoHkiqKUESKdzszicy` del 24-28 ago) no guardan
resumen, y `get_session` solo devuelve metadatos. Punto ciego importante: el
listado solo cubre sesiones de Claude Code, no chats normales de claude.ai.

### Por que ninguna se puede construir todavia

| Idea | Que necesita |
|---|---|
| Mercado negro, drogas, alcohol | Sistemas nuevos, objetos e interacciones |
| Cuchillo | Objeto + interacciones, probablemente crimen |
| Mundo mas vivo | Comportamiento de NPCs |
| Gasolina | Mecanica de combustible enganchada al estado del vehiculo |

Las cuatro son **logica de juego**, no assets — categoria distinta a la del Porsche.
El ModKit cubre ropa, muebles y accesorios; las interacciones personalizadas siguen
en "proximamente". **Los script mods con Lua llegan en diciembre de 2026**: KRAFTON
los retraso un ano y cambio a Lua para que salgan mas completos y documentados.

Hoy la unica via seria UE4SS, la capa mas fragil, la que se desalinea con cada
parche. Conclusion: son proyecto de diciembre, sobre base oficial.

**Excepcion parcial:** ya existen herramientas para modificar movimiento, guiones de
conversacion, voces y recompensas de las interacciones entre Zois. Una rebanada de
"mundo mas vivo" podria ser alcanzable hoy sin tocar UE4SS.

**Orden:** el mod de gasolina tendria que engancharse al estado del vehiculo, asi
que va despues del Porsche, nunca antes.

