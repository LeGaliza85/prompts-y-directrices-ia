# MEMORY.md — Protocolo de memoria

> Plantilla y reglas de uso. En cada proyecto, `MEMORY.md` es una instancia de esto.

## Qué es y qué no es

La memoria es el **puente entre sesiones**. Un agente arranca sin recordar nada: lo que no
está escrito en el repo no existe para él. `MEMORY.md` cubre el hueco entre lo que el
código demuestra y lo que solo se decidió.

**Lo que sí va:** estado actual, decisiones con su porqué, errores ya cometidos con su
causa, próximo paso.

**Lo que no va:** lo que el código ya dice, lo que se deduce de los tests, historia del
proyecto, secretos.

**La prueba:** si alguien con el código delante puede deducirlo, no va en la memoria. La
memoria es para lo que **no** se puede leer.

## Formato

```markdown
# MEMORY.md — <Nombre del proyecto>

## Estado actual
- v1 funcionando: <qué funciona>
- <Qué está a medias, si algo>

## Decisiones (y por qué)
- <Decisión> — <por qué se tomó>

## Errores a evitar
- <Qué no hacer> — <causa: qué pasó la última vez>

## Próximos pasos
- <Lo siguiente, en orden>
```

## El protocolo

**Al empezar una sesión:** léelo entero, después de la constitución.

**Al terminar una tarea:** actualízalo en este orden.

1. *Estado actual* — qué funciona ahora y qué acaba de cambiar.
2. *Decisiones* — las nuevas, **con su porqué**. El porqué es lo que importa: sin él, la
   decisión parece arbitraria y el siguiente agente la revierte sin querer.
3. *Errores a evitar* — lo que falló, **con su causa**. Sin la causa, el error se repite.

## Cuándo recortar

Se recorta cuando ocurra cualquiera de estas tres cosas, lo que llegue antes:

- Algo del archivo contradice lo que el código hace hoy.
- Una sección no ha cambiado en varias sesiones.
- Un apartado no lo ha necesitado nadie en las últimas tres sesiones.

Superar unas ~50 líneas es una señal de que hay que **revisar**, no una razón para podar
por sí sola. El número de líneas es un termómetro poco fino: no mide lo que importa, que
es la vigencia. Un archivo de 20 líneas con la mitad caducada dirige peor que uno de 60
todavía al día.

## La prueba de utilidad

> ¿El agente tomaría una decisión distinta con este archivo que sin él?

Si la respuesta es no, sobra la parte que no cambió esa respuesta.

El riesgo real de una memoria obsoleta no es el tamaño: es que **el agente no puede
distinguir lo vigente de lo caducado**. Lo caducado induce a error con apariencia de
fuente fiable.

## El filtro de promoción

Si un hallazgo deja de ser una nota de sesión y pasa a ser una regla permanente —un
principio que no se deduce del código, una trampa que se repite— no se queda en la
memoria: **propón moverlo a `AGENTS.md`**.

La separación es deliberada: la memoria es transitoria y se recorta; `AGENTS.md` es
permanente y no se toca. Un hallazgo que vive en la memoria acaba desapareciendo cuando
alguien resume la memoria.

## Secretos

Nunca claves, tokens, contraseñas ni datos personales. Ni en la memoria, ni en ningún
archivo, ni en el repo. Si un secreto se escribe por error, se rota.

## Errores ya cometidos en este sistema

- **Guardar el estado nuevo sin decir qué cambió.** Si algo se modifica, la memoria
  registra el cambio y su porqué, no solo el resultado.
- **Convertir la memoria en una lista de tareas.** `MEMORY.md` no es `tasks.md`. Las
  tareas viven en la spec; aquí solo el punto de partida.
- **Confundir error de código con error de proceso.** Un bug va en la memoria del
  proyecto donde ocurrió. Un fallo en nuestra forma de trabajar va en
  `directrices/aprendido.md`.
- **Copiar un umbral sin derivarlo.** Ver la entrada de 2026-10-09 en `aprendido.md`: se
  heredó un límite de líneas sin comprobar qué medía.

## Lo que este repo no usa

No hay un `MEMORY.md` en la raíz de este repositorio. Sus equivalentes son
`directrices/aprendido.md` (errores de proceso) y `directrices/BITACORA.md` (decisiones
aprobadas).

Es deliberado: esta biblioteca no tiene código que crear, y una memoria de sesión sin
estado de implementación no tiene nada que recordar.
