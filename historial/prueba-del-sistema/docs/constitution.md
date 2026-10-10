# Constitución — Prueba del Sistema

Principios innegociables. Toda spec, plan y tarea debe cumplirlos. Este proyecto existe para
demostrar que el sistema funciona, no para producir software útil.

## Simplicidad primero

HTML, CSS y JavaScript puros. Sin dependencias, sin frameworks, sin compilación. Funciona
abriendo `index.html` con doble clic (`file://`).

Prohibido: `type="module"`, `fetch` a archivos locales, cualquier cosa que requiera servidor.

## La spec manda

Nada se implementa si no está en la spec activa. Un cambio de requisito se escribe primero en
la spec, después en el plan y las tareas, y por último en el código. Si falta una decisión, se
para y se pregunta.

## Lógica separada de interfaz

Los cálculos son funciones puras: sin DOM, sin acceso a datos guardados, recibiendo `hoy` como
parámetro. Así se comprueban con `node --test` sin abrir el navegador.

## La comprobación es la puerta

La lógica se comprueba con `node --test`. La interfaz se verifica abriendo el navegador.

Prohibido dar una tarea por terminada con la comprobación en rojo. Si no hay comprobación
automática, la manual se documenta y se ejecuta igual.

## Los datos del usuario son sagrados

`localStorage`, clave `prueba-contador`. Si cambia el formato, compatibilidad hacia atrás.
Fechas siempre en hora local, nunca UTC.

## Idioma

Código en inglés. Textos de la interfaz y documentación en español.
