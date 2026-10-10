# Plan 000 — Búsqueda en la lista de sesiones

Plan técnico de la spec `spec.md`. Cubre los requisitos funcionales indicados en cada
punto. No implementa nada por sí solo: las tareas derivadas están en `tasks.md`.

## Archivos

| Archivo | Cambio | Responsabilidad |
|---|---|---|
| `<app.js>` | Modificar | Función pura de filtrado y estado del campo |
| `<index.html>` | Modificar | Campo de búsqueda, botón de limpiar y mensaje de sin resultados |
| `<styles.css>` | Modificar | Estilos del campo y del mensaje |
| `<test>` | Crear | Comprobaciones de la función pura de filtrado |

## Funciones puras

Las funciones reciben las sesiones y el texto, y devuelven el resultado. Sin DOM y sin
acceso a datos guardados, para poder comprobarse sin abrir la interfaz.

```
filtrar(sesiones, texto) -> sesiones[]
  Devuelve las sesiones cuyo tema contiene texto, sin distinguir mayúsculas.
  Si texto está vacío o solo tiene espacios, devuelve todas.
  No modifica el array de entrada.
```

Cubre: RF-1, RF-2, RF-5. Casos límite: palabra parcial, tema vacío, acentos, lista vacía.

```
hayFiltroActivo(texto) -> booleano
  Cierto si texto tiene contenido que no sea solo espacios en blanco.
```

Cubre: RF-5, RF-6, RF-7.

## Dónde vive el estado

El texto del filtro es estado de interfaz, no dato guardado. No se persiste: al recargar,
la lista aparece completa. Está fuera de alcance (ver `spec.md`) y conviene dejarlo
explícito para que no se cuele después.

## Interfaz

- Campo de búsqueda sobre la lista, con etiqueta asociada y `autocomplete="off"`.
- Botón de limpiar a la derecha del campo. Visible solo cuando hay texto (RF-7).
- Mensaje de «sin resultados» bajo la lista, visible solo cuando el filtro está activo y no
  hay coincidencias (RF-4).
- El recuento o la racha, si la pantalla los muestra, **no** cambian con el filtro: el
  filtro afecta a la lista, no a los totales.

## Decisiones técnicas

**Filtrar sobre los datos en memoria, no releer del almacenamiento.** Las sesiones ya están
cargadas para pintar la lista. Releer del almacenamiento en cada pulsación sería más lento
y más complejo sin ganar nada.
*Alternativa descartada:* consultar el almacenamiento con el filtro. Se descarta porque el
volumen es pequeño y el almacenamiento es síncrono: no hay ganancia, sí hay coste.

**Recalcular en cada pulsación, sin esperar a que deje de escribir.** Con unas 200
sesiones, `filter` sobre un array es instantáneo. Añadir un retardo para no saturar sería
optimizar lo que no es lento.
*Alternativa descartada:* retardo de ~150 ms antes de filtrar. Se descarta por
complejidad añadida sin beneficio medible a este volumen.

**La comparación ignora mayúsculas con `toLowerCase()` en texto y tema.** No se usa
expresión regular: el texto del campo puede contener caracteres que la romperían.
*Alternativa descartada:* `RegExp` con escape. Se descarta porque añade un problema
—escapar la entrada— para resolver uno que no existe.

## Comprobación

- Test de la función pura `filtrar`: los cuatro casos límite de la spec.
- Comprobación manual de RF-6 y RF-7, que son de interfaz.
- Comprobación de accesibilidad: el campo se alcanza con Tab y tiene etiqueta.

Cada requisito y la comprobación que lo cubre:

| Requisito | Comprobación |
|---|---|
| RF-1, RF-2, RF-5 | Test de `filtrar` |
| RF-3 | Comprobación manual: el orden no cambia con el filtro |
| RF-4 | Comprobación manual |
| RF-6 | Comprobación manual |
| RF-7 | Comprobación manual |
