# Constitución — <NOMBRE DEL PROYECTO>

Principios innegociables. Toda spec, plan y tarea debe cumplirlos. Completar los `<...>`
antes de la primera tarea.

## Simplicidad primero
`<STACK>` y nada más. Sin dependencias que no estén justificadas en una spec, sin capas de
abstracción que este proyecto no necesite. `<RESTRICCIÓN: p. ej. funciona abriendo
index.html con doble clic, sin servidor ni compilación>.`

## La spec manda
Nada se implementa si no está en la spec activa. Si falta una decisión, se para y se
pregunta: no se improvisa. Un cambio de requisito se escribe primero en la spec, después
en el plan y las tareas, y por último en el código.

## Lógica separada de interfaz
Los cálculos son funciones puras: sin DOM, sin acceso a datos, recibiendo lo que varíen —
como la fecha actual— como parámetro. Así se pueden comprobar sin abrir la interfaz.

## La comprobación es la puerta
`<COMANDO_DE_COMPROBACIÓN>`. Prohibido dar una tarea por terminada con la comprobación en
rojo. Si no hay comprobación automática, la manual se documenta y se ejecuta igual: la
diferencia es el método, no si se hace.

## Los datos del usuario son sagrados
`<DÓNDE SE GUARDAN>`, con compatibilidad hacia atrás si cambia el formato. Ninguna
actualización puede destruir lo que ya existe. Fechas siempre en la zona horaria local
del usuario, nunca en UTC, salvo que el proyecto trate con zonas horarias explícitamente.

## Idioma
Código en inglés. Textos de la interfaz, comentarios y documentación en `<IDIOMA>`.

---

## Cómo adaptar esta constitución

Sustituir cada `<...>` por lo concreto del proyecto. Los principios se mantienen; lo que
cambia es la forma de comprobarlos. Un principio que no se puede comprobar en este
proyecto es un principio que no está escrito bien.

Si hace falta un séptimo principio, se añade con su razón, y se registra en `BITACORA.md`
del sistema. No sobrepasar seis o siete: una constitución que nadie recuerda entera no
gobierna nada.
