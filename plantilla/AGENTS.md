# AGENTS.md — <NOMBRE DEL PROYECTO>

<Una o dos frases: qué es, para quién y cuál es su objetivo.>

## Stack y estructura

- `<TECNOLOGÍAS Y VERSIONES CLAVE>`
- `<QUÉ HAY EN CADA CARPETA O ARCHIVO IMPORTANTE, solo lo que no es obvio>`
- `<RESTRICCIÓN DE ARRANQUE: p. ej. debe funcionar abriendo el archivo principal con doble clic>`

## Comandos

- Arrancar: `<COMANDO>`
- Comprobar: `<COMANDO_DE_TEST>`
- Lint y formato: `<COMANDO_DE_LINT>`

## Convenciones

- Código en inglés; textos de la interfaz, comentarios y documentación en `<IDIOMA>`.
- `<ESTILO DE CÓDIGO, NOMBRES, PATRONES A SEGUIR, con el archivo de referencia>`

## Reglas de dominio y trampas conocidas

<Lo que es fácil hacer mal y no se puede deducir leyendo el código: la regla que parece
obvia pero está invertida aquí, el detalle que ya se rompió una vez.>

## Datos

- `<DÓNDE Y EN QUÉ FORMATO: clave, campos, ejemplos>`
- Si cambia el formato, mantener compatibilidad con lo ya guardado.

## Forma de trabajar

- Antes de tocar código: ¿la tarea está en `tasks.md`? ¿El cambio está en la spec activa?
- Cambios pequeños y enfocados. No reescribir lo que ya funciona.
- Un cambio de cada vez. Tres cosas a la vez son tres tareas.
- Al terminar, resumir qué cambió, qué se comprobó y qué queda pendiente.

## Límites

- **Siempre:** respetar las reglas de dominio de este archivo; mantener los textos en
  `<IDIOMA>`; ejecutar la comprobación antes de dar algo por terminado.
- **Preguntar antes:** crear archivos nuevos, añadir una dependencia, un MCP, una skill o
  un subagente; cambiar el formato de datos guardado; rediseñar algo que funciona.
- **Nunca:** añadir una dependencia o un paso de compilación sin que esté en la spec;
  introducir secretos ni datos personales; añadir funcionalidad que nadie ha pedido.

## Verificación

`<CÓMO SE COMPRUEBA QUE UN CAMBIO FUNCIONA, en comandos concretos.>`

## Memoria

- Al empezar una sesión, lee `MEMORY.md`: estado, decisiones y errores a evitar.
- Al terminar una tarea, actualízalo con lo que cambió y por qué.
- Máximo ~50 líneas. Lo que se convierta en regla permanente se propone subir a este
  archivo en lugar de quedarse en la memoria.
- Nunca guardes claves, tokens ni datos personales.

## Cómo cargar el contexto

Los documentos se cargan según la tarea, para no llenar el contexto de golpe:

| Si la tarea es | Carga |
|---|---|
| Redactar o cambiar una spec | `SDD.md`, `EARS.md` |
| Decidir si algo está bien hecho | `CONSTITUTION.md`, `EXPECT.md` |
| Proponer una herramienta nueva | `CAPACIDADES.md` |
| Buscar en el código | propón usar `@explore` y espera aprobación |

El campo `instructions` de `opencode.jsonc` carga por defecto este archivo, `MEMORY.md` y
`docs/constitution.md`.

## Specs

- Constitución: `docs/constitution.md`
- Spec activa: la de mayor número en `specs/` sin marcar como `implementada`
- Flujo completo: `SDD.md`
