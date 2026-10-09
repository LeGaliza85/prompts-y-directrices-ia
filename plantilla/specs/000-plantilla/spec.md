# Spec 000 — Búsqueda en la lista de sesiones

Estado: borrador

## Contexto y objetivo

La lista de sesiones crece sin límite: quien usa la app cada día durante meses acaba con
varias decenas de entradas y encontrar una concreta exige recorrerlas todas. El objetivo es
poder filtrar por texto para localizar una sesión antigua sin salir de la pantalla
principal.

Es una funcionalidad de ejemplo: sirve como referencia de cómo se redacta una spec en
este proyecto. Sustituirla por la primera spec real.

## Usuarios

- Persona que registra sus sesiones de estudio y quiere recuperar una concreta.

## Historias de usuario

- HU-1. Como persona que estudia, quiero filtrar la lista escribiendo texto, para
  encontrar una sesión antigua sin recorrerlas todas.
- HU-2. Como persona que estudia, quiero poder quitar el filtro de un gesto, para volver a
  ver todo lo registrado.

## Requisitos funcionales

**RF-1.** CUANDO la persona escriba texto en el campo de búsqueda, EL SISTEMA muestra en
la lista solo las sesiones cuyo tema contenga ese texto, sin distinguir mayúsculas de
minúsculas.

**RF-2.** CUANDO la persona borre todo el texto del campo, EL SISTEMA vuelve a mostrar la
lista completa.

**RF-3.** MIENTRAS el filtro esté activo, EL SISTEMA mantiene el orden de más reciente a
más antigua.

**RF-4.** SI ninguna sesión coincide con el texto, ENTONCES EL SISTEMA muestra un mensaje
que lo indique en lugar de una lista vacía.

**RF-5.** SI el texto contiene solo espacios en blanco, ENTONCES EL SISTEMA lo trata como
búsqueda vacía y muestra la lista completa.

**RF-6.** CUANDO la persona pulse el botón de limpiar, EL SISTEMA vacía el campo y quita
el filtro.

**RF-7.** MIENTRAS el campo tenga texto, EL SISTEMA muestra un botón de limpiar; cuando
esté vacío, lo oculta.

## Requisitos no funcionales

- El filtro responde al escribir, sin botón de aplicar.
- La lista filtrada se recalcula en cada pulsación: con unas 200 sesiones no hay
  perdida perceptible, así que no hace falta optimizar el algoritmo.
- El campo de búsqueda es accesible con teclado y tiene etiqueta asociada.

## Casos límite

- Texto que coincide con parte de una palabra (" estu " debe encontrar "Estudiar").
- Sesiones con el tema vacío o con solo espacios: no deberían coincidir con ninguna
  búsqueda salvo que el filtro también esté vacío.
- Búsqueda con acentos: "estudio" y "estúdio" se comportan igual.
- Lista vacía desde el principio: el mensaje de "sin resultados" no debe confundirse con
  el de "no hay sesiones todavía".

## Fuera de alcance

- Filtrar por fecha o por minutos. Solo por texto del tema.
- Buscar en varios campos a la vez.
- Guardar el filtro entre recargas.
- Resaltar el texto coincidente dentro del resultado.

## Criterios de finalización

- Los siete requisitos funcionales comprobados con un test o con una comprobación manual
  documentada.
- Los cinco casos límite recorridos.
- Comprobación de la accesibilidad del campo con teclado.
- `MEMORY.md` actualizado con la decisión de filtrar en memoria frente a recalcular sobre
  los datos guardados.

## Dudas abiertas

- [NECESITA ACLARACIÓN] ¿El filtro debe aplicarse también a la fecha formateada ("12 de
  marzo") o solo al tema? La especificación actual dice solo al tema; confirmar antes de
  implementar.
- [NECESITA ACLARACIÓN] ¿Qué hace exactamente el botón de limpiar cuando el campo ya está
  vacío y no hay filtro: no aparece, o aparece desactivado?
