# Cobranza al Día

App de cuentas por cobrar para negocios que venden a crédito. Corre entera en el
navegador: sin servidor, sin base de datos, sin costo de operación. Se publica como
archivos estáticos junto al portafolio.

```
app/
  index.html        la app
  venta.html        la página de ventas (a esta mandas a la gente)
  licencias.html    generador de claves Pro — uso interno, no lo compartas
  captura-*.png     capturas reales usadas en la página de ventas
```

Para verla en local, desde la raíz del repo:

```bash
python -m http.server 8000
```

y entra a `http://localhost:8000/app/venta.html`.

---

## Antes de publicar: tres cosas que sí o sí

1. **Tu correo de contacto.** En `venta.html` hay dos `mailto:tucorreo@ejemplo.com`
   (botón "Quiero Pro" y "Cotizar la instalación"). Cámbialos por el tuyo o por un
   número de WhatsApp (`https://wa.me/52XXXXXXXXXX?text=...`).
2. **Los precios.** Están escritos en `venta.html`: `$890 MXN` para Pro y `$2,500 MXN`
   para la instalación. Son un punto de partida razonable para pyme mexicana; súbelos o
   bájalos según a quién le vendas.
3. **La sal de las licencias.** Cambia `SAL` por una frase tuya. Está en dos lugares y
   **tiene que ser idéntica en los dos**:
   - `index.html`, cerca del inicio del script: `var SAL = 'cbz-2026-antoine';`
   - `licencias.html`: `var SAL = 'cbz-2026-antoine';`

   Cámbiala **antes** de vender la primera licencia: si la cambias después, las claves
   que ya entregaste dejan de funcionar.

## Cómo cobras

1. El cliente prueba gratis (hasta 15 facturas abiertas).
2. Cuando choca con el tope o quiere exportar, la app le ofrece Pro y lo manda a `venta.html`.
3. Te escribe. Le pasas tus datos de pago (transferencia, PayPal, Mercado Pago, lo que uses).
4. Con el pago confirmado, abres `licencias.html`, escribes **su correo** y le mandas la clave
   que sale, junto con el texto que la misma página te arma.
5. Él la captura en Ajustes → "Ya tengo mi clave" y queda en Pro para siempre en ese equipo.

Guarda tú una lista de correo ↔ pago; la app no lleva registro de ventas.

### Qué separa Gratis de Pro

| | Gratis | Pro |
|---|---|---|
| Facturas abiertas | hasta 15 | sin límite |
| Panel, fila de cobro, WhatsApp | sí | sí |
| Pagos, abonos, gestiones | sí | sí |
| Exportar a CSV | — | sí |
| Estado de cuenta imprimible | — | sí |
| Respaldo y restauración | — | sí |
| Plantillas editables | — | sí |

El tope vive en `index.html`: `var LIMITE_GRATIS = 15;`.

### Sobre la licencia, sin adornos

La clave se valida dentro del navegador del cliente, así que la sal viaja en el código y
alguien con conocimientos puede fabricarse una. Es una licencia de honor: sirve para
cobrarle al cliente honesto, que es la enorme mayoría de una pyme. Si algún día vendes en
volumen y eso te empieza a doler, la solución es un servidor de licencias, no ofuscar más.

## Cómo vender las primeras

- El mejor prospecto es quien te dice "es que el cliente no me ha pagado": distribuidores,
  imprentas, talleres, despachos, constructoras, agencias, cualquiera que facture a 15 o 30 días.
- Vende con el número, no con la app: pídele su Excel, cárgalo tú en cinco minutos y muéstrale
  la pantalla con **su** cartera. El "tienes $X vencido con 65 días de atraso promedio" cierra
  la venta solo.
- El servicio de instalación deja más que la licencia suelta y te da el caso de estudio para
  el portafolio. Empieza por ahí.
- Cada cliente instalado es una captura de pantalla y un testimonio. Súbelos a `venta.html`.

## Detalles técnicos

- Un solo archivo, sin dependencias, sin build. Se edita con cualquier editor.
- Los datos viven en `localStorage` bajo la llave `cobranza.v1`. Se van si el usuario
  borra los datos del navegador: por eso el respaldo es una función de Pro y conviene
  insistirle al cliente que lo use.
- Fechas en `AAAA-MM-DD`, siempre en hora local. La importación entiende también
  `DD/MM/AAAA`, separadores `,` `;` y tabulador (pegar directo desde Excel funciona).
- Montos con `Intl.NumberFormat`; la moneda se elige en Ajustes y trae 16 países.
- Probado en Chromium con Playwright: panel, fila de cobro, pagos, importación,
  activación de licencia y persistencia tras recarga.

### Ideas para la siguiente versión

Por orden de lo que más pediría un cliente que ya paga:

1. Recordatorios automáticos por día de la semana (una lista "hoy toca cobrarle a estos").
2. Varias monedas conviviendo en la misma cartera.
3. Un modo "cobrador" para el equipo de campo, con menos botones.
4. Sincronización entre equipos — ahí sí toca backend, y ahí sí cabe cobrar mensualidad.
