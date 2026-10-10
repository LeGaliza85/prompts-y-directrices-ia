# EXPECT.md — Cuándo está terminado

Un cambio está terminado cuando se cumplen **todas** estas condiciones. No hay atajos: si
una falla, no está terminado, y se dice que no lo está.

---

## Las condiciones

### Funcionalidad
Lo implementado hace lo que dice la spec activa. Cada requisito con comportamiento
observable está cubierto.

### Verificación
La comprobación se ha ejecutado **y su resultado se ha visto**. «Debería funcionar» no es
un resultado. Si no hay comprobación automática, la manual se documentó y se ejecutó.

**Cualquier comprobación repetida dos veces se automatiza.** No es solo una optimización
de tiempo: la verificación manual que se repite se repite peor. La persona acaba haciendo
menos pasos cada vez, y deja de detectar lo que detectaba al principio.

Algunas herramientas cubren más que los tests. Antes de escribir una comprobación a mano,
plantéate instalar una herramienta externa —con su aprobación, según el principio 1—:

| La tarea es | Herramienta tipo |
|---|---|
| Formato y estilo del código | linter / formateador |
| Tipos | comprobador estático de tipos |
| Tests unitarios y de integración | marco de pruebas |
| Accesibilidad de la interfaz | revisor automático de accesibilidad |
| Comportamiento real en el navegador | navegador controlado (p. ej. Chrome DevTools) |
| Rendimiento | perfilador / auditor |
| Seguridad (dependencias y configuración) | escáner |

El criterio para elegirla es el mismo que para un requisito: **si se puede ejecutar y
produce un resultado, es una comprobación; si solo es una impresión, no lo es.**

Lo mismo aplica fuera de los tests. Cualquier tarea que se haga a mano más de una vez y
se pueda automatizar —generar datos de prueba, poblar una base de datos, comprobar que un
formato es válido, convertir archivos, ejecutar el proyecto en condiciones concretas— se
propone como comando o script antes de repetirla. «Lo haría más rápido a mano» es la
señal para automatizarlo, no para saltárselo.

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
No quedan archivos de depuración, código muerto ni importaciones sin usar **que hayas
introducido tú**. Lo que ya existía no es asunto tuyo, salvo que lo estés tocando.

---

## ¿Vas rápido o vas bien?

No es una preferencia: es una restricción. No se decide en el momento, se decide al empezar
el proyecto.

### Cómo se resuelve

Se responde a dos preguntas con **hechos**, no con impresiones. La respuesta se escribe
en `docs/constitution.md` como orden de sacrificios.

| Pregunta | Si **sí** | Si **no** |
|---|---|---|
| ¿Es para aprender y no para entregar? | Orden C | — |
| ¿Existe algo funcionando que no se puede romper? | Orden A | — |

**No hay un orden de «velocidad primero».** Se descartó al decidir que los proyectos no tienen
fecha: sin plazo no hay conflicto entre terminar rápido y terminar bien. Si algún día un
proyecto lo tuviera, ese orden habría que escribirlo — y con la condición de que
**recortar alcance nunca incluye recortar la verificación**.

### Orden A — calidad primero

Se reduce **alcance** antes que calidad de lo entregado:

1. Se recorta alcance: menos funcionalidades, todas terminadas.
2. Se recorta detalle: se resuelve lo importante, lo accesorio queda pendiente.
3. Registrado siempre qué quedó fuera.
4. Si el mínimo es inalcanzable, se para y se dice.

### Orden C — aprender primero

1. Una cosa a la vez.
2. Se explica el porqué de cada decisión.
3. **La verificación es la misma que en cualquier proyecto.** Puede ser manual mientras
   se automatiza, pero se ejecuta y se ve el resultado. «Lo comprobaré luego» no es un
   plan: si la automatización queda pendiente, es una tarea en `tasks.md`.

### El orden importa más que la etiqueta

Un proyecto puede ser urgente y aun así exigir comprobación mínima. Lo que se sacrifica es
**alcance y detalle**, nunca la verificación de lo que se dice haber hecho.

Si el orden no está escrito, se asume **A**.

---

## Cuándo se considera terminado el proyecto

Las condiciones anteriores dicen cuándo está *terminado un cambio*. Cerrado eso, cerrar el
proyecto es otra decisión, y no la toman las condiciones.

**Se termina cuando tú lo dices.** La calidad no es un número al que se converge: sin
plazos, el punto de retorno es la decisión de quien lo pidió. Por eso el orden de
sacrificios está escrito desde el principio — para que la decisión sea informada.

Para que lo sea, cada tarea deja escrito:

- Qué se hizo.
- Qué se comprobó.
- **Qué se dejó sin hacer a propósito.**

Con eso delante, «ya está» es una conclusión, no una suposición.

### Lo que no es cerrar

- Dejar trabajo a medias sin registrarlo.
- Ampliar el alcance sin avisar.
- Dejar una spec abierta sin marcar por qué.
- Marcar como hecho algo que no se ha comprobado.

### La última tarea

La última tarea de una spec es una tarea de cierre: recorre los requisitos, comprueba los
criterios de finalización y escribe el estado real en `MEMORY.md` —incluido lo que queda
pendiente y por qué.

---

## El límite de «hecho»

«Hecho» significa **verificado por alguien, no por quien lo escribió**.
