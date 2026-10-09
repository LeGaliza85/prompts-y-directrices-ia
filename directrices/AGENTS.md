# AGENTS.md — Instrucción maestra del agente

> Carga bajo demanda. Este archivo dice qué haces; `CONSTITUTION.md` dice qué es correcto.

## Al empezar una sesión

1. Lee la constitución del proyecto: `docs/constitution.md`. Sus principios son
   vinculantes y tienen prioridad sobre todo lo que sigue aquí.
2. Lee `MEMORY.md`: estado actual, decisiones tomadas con su porqué, errores a evitar.
3. Lee la spec activa si existe: `specs/NNN-*/`. Si hay varias, la de mayor número que no
   esté marcada como `implementada`.
4. Revisa qué cambió desde la última sesión en este proyecto (`git status`, `git diff`).

No asumas el estado del proyecto. Está escrito en `MEMORY.md`. Si no está ahí, no lo
inventes; y si debería estar, eso es un fallo de la memoria, no un dato que debas rellenar.

## Antes de tocar código

- ¿La tarea está en `tasks.md`? Si no, vuelve a `tasks.md`.
- ¿El cambio está cubierto por la spec activa? Si no, es un cambio de requisito: primero
  la spec (principio 2).
- ¿Es un cambio grande, un refactor o una decisión de estrategia? Pasa a modo Plan y
  propón antes de escribir.

Un cambio grande en modo Build es un error de proceso, no un atajo.

## Mientras trabajas

**Siempre**
- Un cambio de cada vez. Si estás haciendo tres cosas, son tres tareas.
- Escribe el nombre que usará el código, no el que usaría un humano.
- Si una decisión tiene una alternativa razonada, anótala en el `plan.md` correspondiente
  con la alternativa descartada (principio 3).

**Pregunta antes de**
- Añadir una dependencia, MCP, skill o subagente (principio 1). Usa el formato de
  recomendación de `CAPACIDADES.md`.
- Cambiar el formato de datos persistidos, los límites del sistema o las APIs públicas.
- Rediseñar algo que ya funciona.
- Salirte de la spec activa.

**Nunca**
- Marcar una tarea como hecha sin haber ejecutado su comprobación (principio 5).
- Tocar un archivo que la tarea no necesita.
- Introducir secretos, claves o datos personales en el repo.
- Añadir funcionalidad que nadie ha pedido. "Estaba ahí y me pareció útil" no es un motivo.

## Subagentes

Se usan cuando aportan a que el trabajo sea más rápido o eficiente, y también cuando tú lo
pidas. **Delegar con beneficio no requiere autorización previa**: si dividir el trabajo
reduce el tiempo de reloj, si evita cargar el contexto con búsquedas, o si permite
paralelizar lo secuencial, se delega y se informa.

La autorización previa —principio 1— es para las **capacidades que se activan**, no para
organizar el trabajo.

Sí consulta siempre, aunque no lo exija la regla:

- Si el paralelismo rompe una regla del flujo SDD (una tarea cada vez; validar antes de cerrar).
- Si el resultado de una fase alimenta directamente a la siguiente.
- Si has pedido expresamente que no se use.

Si vas a delegar, delega trabajo independiente y pásale al subagente todo lo que necesita
de forma explícita: está en una sesión separada y no ve esta conversación. Ese traspaso es
el coste real; si explicar la tarea ocupa más que hacerla, hazla tú.

Detalle y catálogo en `directrices/AGENTES.md` (se escribe aparte) y formatos de propuesta
en `CAPACIDADES.md`. El documento que estás leyendo es el `AGENTS.md` **del proyecto**;
nombres parecidos se distinguen siempre por la ruta completa.

## Al terminar una tarea

1. Ejecuta la comprobación de la tarea —comando de tests, lint, o la comprobación manual
   documentada— y muestra el resultado real, no un resumen.
2. Marca la tarea en `tasks.md` con los RF que cubre.
3. Actualiza `MEMORY.md`: estado, decisiones con su porqué, errores a evitar.
4. Resume en un párrafo qué cambió, qué verificaste y qué queda pendiente.

Si un paso se salta, dilo. Un resumen que omite lo que no se hizo es peor que no resumir.

## Cómo cargar el contexto

La instrucción se divide en varios documentos a propósito: cuando el contexto se llena, el
agente empieza a olvidar los principios de los primeros documentos y a inventar. Carga solo
lo que la tarea necesita.

| Si la tarea es | Carga |
|---|---|
| Redactar o cambiar una spec | `SDD.md`, `EARS.md` |
| Decidir si algo está bien hecho | `CONSTITUTION.md`, `EXPECT.md` |
| Proponer una herramienta nueva | `CAPACIDADES.md` |
| Delegar trabajo | `AGENTES.md` del sistema |
| Buscar en el código | propón usar `@explore` y espera aprobación |

En un proyecto nuevo, la carga la resuelve el campo `instructions` de `opencode.jsonc`:

```jsonc
{ "instructions": ["AGENTS.md", "MEMORY.md", "docs/constitution.md"] }
```

Los documentos restantes se cargan bajo demanda, con una instrucción explícita en
`AGENTS.md`. **OpenCode no interpreta `@archivo.md` por sí solo**: si escribes «lee
`EARS.md`», tiene que quedar claro que debes cargarlo con la herramienta de lectura.
