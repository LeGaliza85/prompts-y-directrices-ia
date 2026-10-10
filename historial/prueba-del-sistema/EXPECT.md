# EXPECT.md — Cuándo está terminado

Un cambio está terminado cuando se cumplen **todas** estas condiciones. Si una falla, no
está terminado, y se dice que no lo está.

## Las condiciones

### Funcionalidad
Lo implementado hace lo que dice la spec activa. Cada requisito con comportamiento
observable está cubierto.

### Verificación
La comprobación se ha ejecutado **y su resultado se ha visto**. «Debería funcionar» no es
un resultado. Si no hay comprobación automática, la manual se documentó y se ejecutó.

**Cualquier comprobación repetida dos veces se automatiza.** La verificación manual que se
repite se repite peor: cada vez se hacen menos pasos y se deja de detectar lo que se
detectaba al principio. Antes de escribir una comprobación a mano, plantéate una
herramienta externa —con su aprobación, según el principio 1.

El criterio para elegirla es el mismo que para un requisito: **si se puede ejecutar y
produce un resultado, es una comprobación; si solo es una impresión, no lo es.**

Y se aplica fuera de los tests: generar datos de prueba, poblar una base de datos, validar
un formato, convertir archivos. «Lo haría más rápido a mano» es la señal para automatizarlo,
no para saltárselo.

### Constitución
Ningún principio de `docs/constitution.md` está incumplido. Se comprueba, no se supone.

### Alcance
No hay nada fuera de la spec activa. Si algo se hizo sin estar pedido, se quita o se
registra como requisito nuevo —pero no se deja a medias y en silencio.

### Memoria
`MEMORY.md` actualizado: estado, decisiones con su porqué, errores con su causa.

### Registro
`tasks.md` marca la tarea con los requisitos que cubre.

### Sin secretos
Ninguna clave, token ni dato personal introducido.

### Limpieza
No quedan archivos de depuración, código muerto ni imports sin usar **que hayas
introducido tú**.

## Prioridad ante falta de tiempo

No se decide en el momento, se decide al empezar el proyecto, y se escribe en
`docs/constitution.md`. Mientras no esté escrito, se asume **calidad primero**.

**Calidad primero.** Se reduce alcance antes que calidad de lo entregado: menos
funcionalidades, todas terminadas. Siempre se registra qué quedó fuera.

**Aprender primero.** Una cosa a la vez. Se explica el por qué de cada decisión. La
verificación es la misma que en cualquier proyecto: puede ser manual mientras se
automatiza, pero se ejecuta y se ve el resultado. «Lo comprobaré luego» no es un plan.

**El orden importa más que la etiqueta.** Lo que se sacrifica es alcance y detalle, nunca la
verificación de lo que se dice haber hecho. Si alguna vez hay que recortar la verificación,
se declara por escrito que la entrega no está verificada, y eso deja de ser una entrega.

## Cuándo se considera terminado el proyecto

Las condiciones anteriores dicen cuándo está terminado **un cambio**. Cerrado eso, cerrar
el proyecto es otra decisión.

**Se termina cuando quien lo pidió lo dice.** La calidad no es un número al que se converge:
sin plazos, el punto de retorno es tu decisión. Para que sea informada, cada tarea deja
escrito qué se hizo, qué se comprobó y **qué se dejó sin hacer a propósito**.

Con eso delante, «ya está» es una conclusión, no una suposición.

### Lo que no es cerrar

- Dejar trabajo a medias sin registrarlo.
- Ampliar el alcance sin avisar.
- Dejar una spec abierta sin marcar por qué.
- Marcar como hecho algo que no se ha comprobado.

### La última tarea

La última tarea de una spec es una tarea de cierre: recorre los requisitos, comprueba los
criterios de finalización y escribe el estado real en `MEMORY.md`, incluido lo que queda
pendiente y por qué.

---

## El límite de «hecho»

«Hecho» significa **verificado por alguien, no por quien lo escribió**.
