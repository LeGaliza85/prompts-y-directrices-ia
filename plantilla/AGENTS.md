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

**Añade aquí las trampas de tu proyecto, y borra las de ejemplo cuando no apliquen.**

### Trampa de ejemplo: la lógica compartida entre pruebas y navegador

Si el proyecto usa JavaScript sin compilación, hay un fallo que **no da error en las pruebas**:
la página se rompe y los tests pasan.

`module.exports` solo existe en Node. Cargar el archivo con `<script src>` en el navegador da
`ReferenceError: module is not defined`. Como las pruebas se ejecutan en Node, todo parece
correcto y el fallo solo aparece al abrir la página.

Dos vías, y son excluyentes según lo que permita la constitución:

- **Con módulos nativos:** un archivo `.mjs`, o `<script type="module">`. Node lo importa con
  `import`. Es la vía limpia, y exige servidor o configuración de módulos.
- **Sin módulos y sin servidor:** exportación doble en el mismo archivo:

```js
(function (raiz) {
  const api = { /* ... */ };
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;      // Node
  } else {
    raiz.MiApi = api;          // Navegador
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);
```

**Cómo se comprueba:** después de cambiar la forma de exportar, abre la página en un navegador
y comprueba la consola. Los tests no la cubren.

### Trampa de ejemplo: fechas

`toISOString()` y `new Date("AAAA-MM-DD")` devuelven **UTC**, no la hora local del usuario. En
una zona horaria positiva, una acción hecha a las 00:30 se guarda con la fecha del día
anterior; en una negativa, con la del día siguiente.

`YYYY-MM-DD` es solo un formato. El instante es UTC; la zona horaria hay que declararla.

### Trampa de ejemplo: datos corruptos

Un valor guardado puede no tener la forma esperada: JSON roto, un número donde tocaba texto,
un campo que ya no existe. La tentación es fallar al leerlo. La correcta es **descartar solo
lo que no sea válido y conservar el resto**, porque esos datos son de alguien.

Un dato corrupto nunca se repara ni se medio-adivina: se trata como ausente.

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

Los documentos se cargan según la tarea, para no llenar el contexto de golpe. Los de abajo
viven en la biblioteca del sistema, no en el proyecto:

| Si la tarea es | Carga |
|---|---|
| Redactar o cambiar una spec | `<BIBLIOTECA>/SDD.md`, `<BIBLIOTECA>/EARS.md` |
| Decidir si algo está bien hecho | `docs/constitution.md`, `EXPECT.md` (este proyecto) |
| Depurar un fallo | `<BIBLIOTECA>/DEPURACION.md` |
| Refactorizar sin romper | `<BIBLIOTECA>/REFACTOR.md` |
| Proponer o configurar una herramienta | `<BIBLIOTECA>/CAPACIDADES.md`, `<BIBLIOTECA>/MCP.md` |
| Buscar en el código | propón usar `@explore` y espera aprobación |

Las fases del flujo están automatizadas en `.opencode/commands/`. Escribe `/sdd` para ver el
menú completo y en qué fase estás.

`<BIBLIOTECA>` es la ruta a la carpeta de directrices del sistema. Ponla aquí una sola vez y
todas las rutas de arriba quedan resueltas: `<RUTA_A_LAS_DIRECTRICES>`.

Los tres archivos de este proyecto que se cargan siempre son el campo `instructions` de
`opencode.jsonc`: este archivo, `MEMORY.md` y `docs/constitution.md`. El resto se carga a mano
cuando la tarea lo pida.

## Herramientas: cuándo te propongo algo

El agente `tooling-advisor` te avisa de lo que pueda ayudarte. Los cuatro momentos en que
lo hace:

1. **Al empezar el proyecto**, con la constitución ya escrita. Es el momento más barato para
   elegir herramientas.
2. **Al cerrar cada fase del SDD**: spec, plan o tareas aprobadas.
3. **Cuando algo se haya hecho a mano por segunda vez.** La repetición es la señal.
4. **Siempre que me lo pidas.**

Cada propuesta llega con qué falta sin ella, qué resuelve, cuánto cuesta —instalación,
arranque por sesión y contexto en tokens—, el riesgo y la alternativa si dices que no. Nada
se instala sin tu aprobación. Si la rechazas, queda registrado el motivo y no se vuelve a
proponer por el mismo.

## Specs

- Constitución: `docs/constitution.md`
- Spec activa: la de mayor número en `specs/` sin marcar como `implementada`
- Flujo completo: `SDD.md`
