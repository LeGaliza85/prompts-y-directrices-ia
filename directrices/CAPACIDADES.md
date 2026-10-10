# CAPACIDADES.md — Catálogo de capacidades y cómo se proponen

Herramientas que se pueden añadir a un proyecto: qué resuelve cada una, cuánto cuesta de
verdad y el formato exacto para pedir permiso antes de activarla. La regla que gobierna todo
lo de aquí es el principio 1 de la constitución: **nada se activa sin tu permiso**.

---

## El formato de recomendación

Cuando detecto que falta una capacidad, presento este bloque **en el momento de detectarlo**
y espero tu respuesta. No lo agrupo para el final de la fase ni lo dejo para el cierre: si
llega tarde, la decisión ya no existe y solo queda un aviso inútil.

## Cuándo te aviso

**Al empezar el proyecto**, con la constitución ya escrita. Es el momento más barato para
decidir: poner una herramienta al principio cuesta menos queañadirla cuando ya hay código
escrito contra ella.

**Al cerrar cada fase del SDD** —spec aprobada, plan aprobado, tareas aprobadas—. Lo que se
acaba de definir dice qué va a hacer el proyecto, y de ahí se deduce qué necesitará.

**Cuando algo se haya hecho a mano por segunda vez.** La repetición es la señal más fiable de
que falta algo.

**Siempre que me lo pidas**, con la duda que tengas.

El agente encargado de esto es `tooling-advisor`. Está en solo lectura y sin permiso para
instalar nada, precisamente para que su salida sea una propuesta y no un cambio.

```
🛑
Recomendación — <MCP | skill | subagente>
Falta:        <qué no puedo hacer sin esto>
Propuesta:    <nombre> · <fuente> · local o remoto>
Resuelve:     <qué cubre exactamente>
Coste:        <instalación> · <arranque por sesión> · <contexto: tokens de instrucciones>
Riesgo:       <qué puede salir mal>
Alternativa:  <qué hago si dices que no>
¿Lo activo?   (s/n)
```

Tres cosas sobre el bloque:

- **`Falta` va antes de `Propuesta`.** Si no sabría decir qué no puedo hacer sin la
  herramienta, la recomendación no tiene fundamento y no se envía.
- **`Alternativa` no es opcional.** Es lo que hago si dices que no, y tiene que ser real:
  hacerlo a mano, leer documentación en la web, o aplazar la tarea y decirlo.
- **`Riesgo` es concreto.** «Puede fallar» no es un riesgo. «Abre una web que puede
  requerir sesión iniciada» sí lo es.

Si dices que no, la recomendación queda registrada con su motivo en `MEMORY.md` y no se
vuelve a proponer por el mismo motivo. Puede reaparecer si el motivo cambia: otro proyecto,
otra tarea, otra versión de la herramienta. En ese caso se explica qué ha cambiado, no se
repite el mismo bloque como si fuera nuevo.

Si dices que sí, se activa, se anota dónde quedó configurada y se comprueba que funciona
con una tarea real antes de darla por disponible.

---

## Cómo se mide el coste

Todo coste se desglosa en tres, y los tres se declaran:

| Coste | Qué es | Cómo se mide |
|---|---|---|
| Instalación | Descarga de paquetes y su caché | Primera vez: minutos de descarga. Después: ya está en caché, cuesta cero |
| Arranque | Lo que se pone en marcha en cada sesión | MCP local: proceso en segundo plano por sesión. MCP remoto: llamadas por uso |
| Contexto | Tokens de instrucciones que consume | Skills: solo al cargarse. Subagentes: ninguno, son sesiones aparte |

Tres detalles que cambian la decisión:

- **Instalar no es gratis, pero se paga una sola vez.** El paquete se descarga una vez y
  queda en caché; lo que se repite en cada sesión es el arranque, no la descarga.
- **Un MCP local es un proceso más en tu máquina**, vivo durante toda la sesión aunque no
  se use. Un MCP remoto no consume recursos locales, pero llama a la red en cada uso y
  depende de que el servicio esté disponible.
- **El contexto es el coste que se olvida.** Los servidores con muchas herramientas acaban
  describiendo cada una en el prompt, aunque solo uses una. No he medido cuánto cuesta cada
  herramienta: se nota con servidores muy grandes y conviene activarlos cuando la tarea los
  necesita y apagarlos cuando no. Las skills añaden su `SKILL.md` al contexto **solo cuando
  se cargan**, no desde el principio. Un subagente no consume contexto del principal porque
  trabaja en su propia sesión, aunque el traspaso de información para arrancarlo tenga su
  propio coste.

---

## MCP

| MCP | Fuente | Modo | Requiere API key |
|---|---|---|---|
| `chrome-devtools` | Google | local, vía `npx` | No |
| `context7` | Upstash | remoto | Sí |
| `github` | GitHub | remoto | Sí (token) |
| `figma` | Figma | remoto | Sí |

**`chrome-devtools`** — Abre una web real, ejecuta flujos completos, lee la consola y hace
capturas de pantalla. Es la herramienta para verificar requisitos de interfaz que no se
pueden comprobar leyendo el código: que un formulario responde, que la vista móvil no
desborda, que no hay errores en consola. Coste: proceso local por sesión y un navegador
que se abre. Útil incluso sin interfaz propia, para mirar cómo se comporta un servicio
externo.

**`context7`** — Documentación actualizada de librerías, en lugar de la versión que el
modelo recuerde. Evita inventar una API que cambió. Coste: remoto, una llamada por consulta.

**`github`** — Repositorios, issues y pull requests sin salir de la sesión. Útil cuando el
trabajo está en GitHub y hay que leer un issue, revisar un PR o consultar el historial.

**`figma`** — Pasa diseño a código leyendo el archivo de diseño. Útil en proyectos con
diseño previo; sin él, el diseño se interpreta a partir de capturas.

Configuración de ejemplo. Todos los MCP van **comentados** con `//` a propósito: el
principio 1 prohíbe precargar nada, y dejarlos escritos pero apagados permite activarlos
con una palabra cuando hagan falta.

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  // Ninguno activo: todos comentados a proposito. Escribir el nombre
  // del que haga falta en el proyecto.
  // "mcp": {
  //   "chrome-devtools": {
  //     "type": "local",
  //     "command": ["npx", "-y", "chrome-devtools-mcp@latest", "--no-usage-statistics"]
  //   },
  //   "context7": {
  //     "type": "remote",
  //     "url": "https://mcp.context7.com/mcp",
  //     "headers": { "CONTEXT7_API_KEY": "<TU_API_KEY>" }
  //   },
  //   "github": { "type": "remote", "url": "https://api.githubcopilot.com/mcp/" },
  //   "figma": { "type": "remote", "url": "https://mcp.figma.com/mcp" }
  // }
}
```

La API key de los remotos va en variables de entorno o en la configuración local, nunca en
el repositorio.

**Cómo se configuran, se comprueban y se apagan:** `MCP.md`. Allí está el orden de revisión
cuando un MCP figura en `/mcps` pero no conecta, que es el modo de fallo más común y no da
error visible.

---

## Skills

Una skill es un paquete de instrucciones que se carga **cuando hace falta**, no desde el
principio de la sesión. Se instala con:

```bash
npx skills add <paquete>
```

| Skill | Fuente | Qué resuelve | Cuándo es útil | Contexto |
|---|---|---|---|---|
| `find-skills` | Vercel | Busca en el catálogo de skills | Cuando sospecho que existe una skill para esto | Medio |
| `grill-me` | Matt Pocock | Interroga una propuesta antes de aceptarla | Antes de dar por buena una decisión técnica dudosa | Bajo |
| `frontend-design` | Anthropic | Criterios de interfaz y maquetación | Al construir o revisar una interfaz | Alto |
| `web-design-guidelines` | Vercel | Reglas concretas de diseño web | Al revisar una interfaz ya escrita | Medio |
| `systematic-debugging` | Obra de Jesse Vincent | Método ordenado para depurar | Cuando un fallo no se reproduce a la primera | Medio |

Las dos primeras son de proceso: no añaden código, añaden método. `frontend-design` es la que
más contexto carga de las cinco, así que se pide solo si la tarea es de interfaz y no «por si
acaso».

La columna *Contexto* es una estimación del tamaño del `SKILL.md`, no una medición. No he medido
cuántos tokens gasta cada una: es una impresión a partir de lo que ocupan.

---

## Subagentes

Mención breve: el catálogo propio de subagentes vive en `AGENTES.md`, que se escribe
aparte. Aquí solo el criterio general.

Se delega cuando el trabajo es **independiente** —dos tareas que no se pisan— o cuando
hace falta una **especialidad o un permiso restringido** que el agente principal no tiene.
También cuando tú lo pides.

No se delega para coordinar, y no se encadenan fases donde el resultado de una alimenta
directamente a la siguiente: el traspaso de contexto cuesta más que hacerlo en una sola
sesión.

**Delegar con beneficio no requiere autorización previa.** Es organización interna del
trabajo, no una capacidad que se activa. Lo que se consulta siempre es lo que rompe el
flujo: paralelizar donde SDD exige una tarea cada vez, o cadenas de fases dependientes.

---

## Herramientas de automatización

Cualquier comprobación que se repita dos veces, y cualquier tarea manual que se repita dos
veces, se propone como herramienta externa. Se propone, no se instala: el principio 1
también aplica aquí.

| La tarea es | Herramienta tipo |
|---|---|
| Estilo y formato del código | linter / formateador |
| Tipos | comprobador estático de tipos |
| Pruebas unitarias y de integración | framework de tests |
| Accesibilidad de la interfaz | revisor automático de accesibilidad |
| Comportamiento real en el navegador | navegador controlado |
| Rendimiento | perfilador / auditor |
| Dependencias y configuración | escáner de seguridad |

Fuera del código aplica lo mismo: generar datos de prueba, poblar una base de datos,
validar que un formato es correcto, convertir archivos, ejecutar el proyecto en
condiciones concretas. Todas son tareas candidatas a ser un comando.

El criterio para distinguir una comprobación real de una impresión: **si se puede ejecutar
y produce un resultado, es una comprobación; si solo es una impresión, no lo es.** «El
código parece limpio» no es un resultado. «El linter devuelve 0 avisos» sí lo es.

---

## Lo que este catálogo no incluye

- **Dependencias de proyecto** (`npm`, `pip`, gemas, lo que use el stack). Tienen su propio
  flujo de aprobación en el `AGENTS.md` del proyecto, porque allí se conoce el stack y el
  criterio para elegir versión. Este documento solo cubre capacidades del entorno de
  trabajo.
- **Herramientas sin verificar.** Si una herramienta de este catálogo no se ha ejecutado en
  el proyecto actual, se marca como *sin verificar* y se comprueba con una tarea real antes
  de tratarla como disponible. Un nombre en una tabla no es una herramienta que funciona.
