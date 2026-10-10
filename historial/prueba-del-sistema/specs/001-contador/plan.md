# Plan 001 — Contador con nombre guardado

Plan técnico de `spec.md`. Cubre los requisitos indicados en cada parte.

## Archivos

| Archivo | Cambio | Responsabilidad |
|---|---|---|
| `index.html` | Crear | Estructura: campo de nombre, contador, botones |
| `styles.css` | Crear | Estilos, incluido ancho de móvil |
| `app.js` | Crear | Lógica pura y conexión con el DOM |
| `logica.test.js` | Crear | Comprobaciones de las funciones puras |
| `spec.md` | Crear | Esta spec |

## Funciones puras

Reciben el estado y lo que varía, y devuelven el resultado. Sin DOM y sin `localStorage`, para
poder comprobarlas con `node --test`.

```
normalizarNombre(texto) -> string
  Recorta los extremos. Devuelve "" si solo hay espacios.
```
Cubre: RF-4, RF-5. Casos límite: espacios internos, nombre largo, cadena vacía.

```
incrementar(contador) -> number
  Devuelve contador + 1. Si el valor de entrada no es un número, devuelve 1.
```
Cubre: RF-2. Caso límite: valor corrupto en `localStorage`.

```
estadoInicial(guardado) -> estado
  Devuelve el estado que se pinta al arrancar. Si `guardado` es null o está corrupto,
  devuelve contador 0 y nombre "".
```
Cubre: RF-8. Caso límite: JSON roto, campos ausentes, tipos incorrectos.

## Dónde vive el estado

`localStorage`, clave `prueba-contador`, con un objeto `{ nombre, contador }`.

Se lee **una vez al arrancar** y se escribe en cada cambio. No hay estado en memoria: la página
recarga y el estado viene del almacenamiento.

Si el JSON está corrupto o los tipos no son los esperados, se descarta y se usa el estado
inicial. No se intenta reparar: un dato roto se trata como ausente, nunca se medio-adivina.

## Interfaz

- **Sin nombre guardado:** campo de texto, botón de guardar, y un mensaje de error bajo el
  campo cuando se pulsa vacío.
- **Con nombre guardado:** el nombre a la vista, el contador en grande, y dos botones: contar
  y reiniciar.
- Los dos estados son excluyentes. No se muestran los dos a la vez.
- Ancho de móvil: nada desborda a 375 px.

## Decisiones técnicas

**JavaScript puro, sin framework.** La lógica son tres funciones de una línea.
*Alternativa descartada:* un framework. Se descarta porque anade una dependencia y un paso de
compilación a un proyecto que debe funcionar abriendo un archivo.

**Funciones puras separadas del DOM.** Es lo que permite comprobar la lógica sin navegador.
*Alternativa descartada:* todo junto leyendo del DOM. Se descarta porque entonces los tests
necesitan un navegador y los casos límite se comprueban a mano.

**Estado fuera de memoria.** La fuente de verdad es el almacenamiento, no una variable.
*Alternativa descartada:* estado en JavaScript y volcado al almacenamiento. Se descarta porque
introduce dos fuentes de verdad y la posibilidad de que se desincronicen al recargar.

**Sin confirmación al reiniciar.** Es inmediato, como dice la spec.
*Alternativa descartada:* pedir confirmación. Se descarta porque la spec no la pide; añadirla
sería funcionalidad fuera de alcance.

## Comprobación

`node --test logica.test.js` para las tres funciones puras. La interfaz se verifica en
navegador, incluido el ancho de móvil.

| Requisito | Comprobación |
|---|---|
| RF-4, RF-5 | Test de `normalizarNombre` |
| RF-2 | Test de `incrementar` |
| RF-8 | Test de `estadoInicial` |
| RF-1, RF-3, RF-6, RF-7 | Navegador: flujo completo |
