# BITACORA.md — Registro de decisiones

Cada decisión sobre las directrices: qué se decidió, cuándo, por qué y quién la propuso.
El objetivo es poder reconstruir el razonamiento, no solo el resultado.

Los cambios en las directrices se anotan aquí **antes** de aplicarse. Una directiva
modificada sin registro se considera un error.

---

## 2026-10-11 — Portabilidad: qué se lleva a otro agente y qué no

**Decisión.** Se añade `PORTABILIDAD.md`, que separa lo independiente de la herramienta de lo
que hay que adaptar. Y se generalizan las tres menciones innecesarias que quedaban en la capa
genérica.

**Propuso.** El usuario, al pedir que el sistema se pudiera usar fuera de OpenCode y con otros
modelos.

**El hallazgo que cambió el documento.** Al medirlo, la mayoría de las 61 menciones de
"OpenCode" estaban en los documentos **sobre** la herramienta —`OPENCODE.md`, `PIN.md`,
`APIS-VERIFICADAS.md`, `MCP.md`, `PROCEDIMIENTO-ACTUALIZACION.md`—, que por definición tratan de
ella. En la capa genérica quedaban **cuatro**, y tres eran exemples de estructura de proyecto
que se podían escribir con un marcador.

**Medición después del cambio.** Siete documentos de veinte no mencionan ninguna
herramienta: `DEPURACION.md`, `EARS.md`, `EXPECT.md`, `MEMORY.md` y `REFACTOR.md`. Los otros
trece la mencionan en una nota, en un ejemplo, o son sobre la herramienta.

**Los cuatro puntos realmente atados**, y son cuatro: `opencode.jsonc` y `instructions`, la
carpeta `.opencode/`, el frontmatter de los agentes, y la ubicación de las skills. Todo lo
demás se copia tal cual.

**El dato que más importa.** `AGENTS.md` es un formato estándar, no una invención de OpenCode:
lo leen varios agentes, y OpenCode acepta `CLAUDE.md` si no encuentra `AGENTS.md`. Es el mayor
punto de portabilidad del sistema, y hasta ahora no estaba escrito en ningún sitio.

**La conclusión incómoda.** Los subagentes son lo más atado: Cursor y Windsurf no tienen el
concepto. El principio 7 sobrevive —habla de "cuando aporta", no de cómo—, pero **el catálogo
de trece agentes no es portable**, y eso no estaba dicho.

**Con otros modelos.** No hay diferencia de compatibilidad: los documentos son texto. Lo que
cambia es cuánta documentación conviene cargar a la vez, y eso es una decisión de proyecto, no
del sistema. Queda escrito que cuanto mejor es el modelo, más importa el principio 4: un modelo
mejor no compensa una spec peor.

---

## 2026-10-10 — AGENTS.md en la raíz, y el archivo de próxima sesión

**Decisión.** Este repo tiene ahora `AGENTS.md` en la raíz y `PROXIMA-SESION.md`. El primero
manda leer el segundo antes de tocar nada.

**Propuso.** El usuario, al pedir que se guardara lo necesario para seguir en otro momento y
que se le recordaran tres cosas.

**Por qué.** El repo no tenía nada en la raíz, así que una sesión nueva arrancaba **sin
instrucciones y sin recordatorio**: dependía de que alguien abriera `INDICE.md` por iniciativa
propia. Para un repo cuyo contenido es texto, ese hueco es caro —lo pendiente se pierde sin
dejar rastro.

**La contradicción con una decisión anterior, resuelta.** En esta bitácora consta que este repo
**no** tendría `MEMORY.md` en la raíz porque no hay estado de implementación que recordar. Se
mantiene: sigue sin haberlo. Lo que se anade no es memoria de proyecto, es *traspaso entre
sesiones*, que es otra cosa. `PROXIMA-SESION.md` dice qué queda por hacer; una memoria diría
en qué estado está el código, y aquí no hay código.

**Contenido del traspaso.** Las tres cosas que el usuario pidió que se le recuerden: verificar
todo lo hecho en busca de fallos, asegurar que el sistema funciona fuera de OpenCode y con
otros modelos, y preguntar al agente qué añadiría y qué recomendaría. Más el estado de los
bloques, lo que reveló la prueba y quedó sin corregir, y lo que no se ha probado.

**Consecuencia.** `specs/000-sistema-de-trabajo/tasks.md` pasa de 10 a 13 tareas. Las tres
nuevas son T11 (aplicar lo que reveló la prueba), T12 (portabilidad) y T13 (probar el flujo con
agentes). T10 queda como segunda pasada del revisor.

---

## 2026-10-09 — Condición de trabajo: sin plazos

**Decisión.** Los proyectos se hacen con el tiempo necesario hasta que queden bien. No
hay fechas de entrega.

**Propuso.** El usuario.
**Afecta a.** `EXPECT.md`, `plantilla/docs/constitution.md`.

**Por qué.** Sin fecha, la pregunta «¿velocidad o calidad?» deja de tener conflicto real:
siempre es calidad. Se eliminan el orden B (velocidad primero) y la mayoría de las
preguntas de decisión.

**Consecuencia principal.** El riesgo pasa de *entregar roto* a *no terminar nunca*. Por
eso `EXPECT.md` incluye una sección de cierre: el proyecto termina cuando el usuario lo
dice, y para que esa decisión sea informada cada tarea deja escrito qué se dejó sin hacer
a propósito. `MEMORY.md` pasa a ser crítico: es lo que recuerda qué queda entre sesiones.

**Alternativa descartada.** Mantener los tres órdenes de sacrificio por si en el futuro
aparece un proyecto con plazo. Se descarta porque una opción que nunca se usa solo añade
texto que hay que leer y mantener.

---

## 2026-10-09 — La capa genérica se propone y se aprueba antes de escribirse

**Decisión.** Los documentos de `directrices/` se enseñan en conversación y se escriben
en disco solo tras aprobación.

**Propuso.** El usuario.
**Afecta a.** Toda la capa genérica.

**Por qué.** Sin este paso, la biblioteca crecería sin que nadie hubiera comprobado qué
dice. Con él, cada documento tiene alguien responsable de su contenido.

---

## 2026-10-09 — Se archivan copias literales de cada proyecto

**Decisión.** Al terminar un proyecto, sus directrices se copian sin modificar a
`historial/<nombre>/`, junto a una `FICHA.md` con stack, fecha y capacidades usadas.

**Propuso.** El usuario.
**Por qué.** Poder recuperar lo que se usó, no solo lo que nunca se usó. Una copia literal
permite comparar dos proyectos aunque la capa genérica haya cambiado entre medias.

---

## 2026-10-09 — Nada se activa sin propuesta y aprobación

**Decisión.** Toda capacidad —MCP, skill, subagente, dependencia— se propone con motivo,
coste y alternativa antes de activarse. Base del principio 1.

**Propuso.** El usuario.
**Por qué.** Una herramienta activada sin permiso es irreversible en la práctica: ocupa
contexto, arranca procesos y cambia el comportamiento del agente.

**Extensión posterior.** La propuesta se avisa **en el momento** en que se detecta la
necesidad, no agrupada al final de la fase: si llega tarde, ya no hay decisión que tomar.
El coste indicado incluye tiempo, arranque y tokens de contexto.

---

## 2026-10-09 — Los subagentes se usan cuando aportan o cuando se piden

**Decisión.** Base del principio 7: se delegan subagentes cuando el trabajo se beneficia,
y también cuando el usuario lo pide. Ambas vías.

**Propuso.** El usuario.
**Corrección en el camino.** La primera versión del principio lo limitaba a criterio
propio; se interpretó mal una aclaración posterior y se eliminó el criterio. La versión
final contiene las dos vías, que era lo que se quería decir.

**Consecuencia.** El catálogo de subagentes (`AGENTES.md`) es una **oferta**, no un
activador. La fila que decía «busca en el código con `@explore`» pasó a ser «propón usar
`@explore` y espera aprobación».

---

## 2026-10-09 — Se inicia git para poder ver los cambios

**Decisión.** El repositorio se versiona con git; cada bloque aprobado es un commit.

**Propuso.** El agente, aceptado por el usuario.
**Por qué.** Sin historial de commits, «aprender de los errores» se queda en leer dos
versiones de un archivo y compararlas a ojo. El diff muestra qué cambió y cuándo.

---

## 2026-10-09 — El material del curso se verifica antes de copiarse

**Decisión.** Nada del material de origen se copia sin comprobarlo contra la versión
instalada. `APIS-VERIFICADAS.md` registra el estado y la fecha de cada comprobación.

**Propuso.** El agente.
**Por qué.** El curso usa sintaxis de permisos obsoleta (`permissions:` con
`action`/`resource`/`effect`). Copiada tal cual, produce agentes que se cargan pero no
aplican ninguna restricción: el fallo es silencioso.

---

## 2026-10-09 — Delegar con beneficio no requiere autorización previa

**Decisión.** El principio 7 se amplía: cuando dividir el trabajo en agentes independientes
reduce el tiempo de reloj, evita cargar el contexto con tareas de búsqueda, o permite
paralelizar lo que de otro modo sería secuencial, se delega y se informa. Sin consultar
antes.

**Propuso.** El usuario, tras comprobar que no se delegaba cuando era útil.
**Afecta a.** `CONSTITUTION.md` principio 7, `AGENTS.md`, `CAPACIDADES.md`.

**Por qué.** La autorización previa del principio 1 protege de activar una **capacidad**
que consume contexto o arranca procesos. Delegar no activa nada: reorganiza el trabajo.
Aplicarle la misma fricción hacía que el método se aplicara poco, que es justo el
resultado que se quería evitar.

**Qué se consulta igualmente.** Tres casos, porque la delegación no los resuelve: cuando
rompe una regla del flujo (fases 6 y 7 de SDD), cuando una fase alimenta directamente a la
siguiente, y cuando el usuario ha pedido expresamente que no se use.

**El coste real.** Cada subagente es una sesión sin contexto compartido: hay que pasarle
todo explícitamente. Si lo que se transmite ocupa más que el trabajo en sí, delegar no sale
a cuenta.

---

## 2026-10-09 — Los comandos `/sdd-*` y los tres documentos de método

**Decisión.** Se completan las piezas que faltaban del material de origen: los diez comandos
que automatizan las fases del SDD, y los tres documentos de método que no tenian versión
propia.

**Propuso.** El usuario, al preguntar qué faltaba.

**Los comandos.** Diez, en `plantilla/.opencode/commands/` y en `.opencode/commands/` de este
repositorio: `sdd`, `sdd-constitution`, `sdd-spec`, `sdd-clarify`, `sdd-plan`, `sdd-tasks`,
`sdd-implement`, `sdd-validate`, `sdd-change`, `sdd-status`.

Cada uno con el agente adecuado en el frontmatter: los de planificación y especificación
corren con `plan`, que no puede tocar código; los de implementación y validación con `build`.
La restricción está en el comando, no en que quien lo use se acuerde.

**Los documentos.** `DEPURACION.md` (reproducir, aislar, formular hipótesis con predicción,
verificar), `REFACTOR.md` (comprobación antes, un cambio cada vez, comprobar después) y
`MCP.md` (tipos local y remoto, cómo se comprueba que conecta, cómo se apaga).

**Por qué separados.** Los agentes `debugger` y `refactorer` ya existían como ejecutores, pero
no había método escrito. Un agente que sabe ejecutar y no sabe cómo, inventa el cómo cada vez.
Y la configuración de MCP estaba dentro de `CAPACIDADES.md`, que es el catálogo: mezclar el
catálogo con la parte técnica hacía que ninguna de las dos se encontrara.

**Consecuencia.** La tabla de carga de contexto pasa de cuatro filas a seis, y el `AGENTS.md`
de la plantilla apunta a `.opencode/commands/` como vía para ejecutar el flujo sin recordar
prompts.

---

## 2026-10-09 — La plantilla se automatiza con un script

**Decisión.** Se anade `nuevo-proyecto.ps1`: copia la plantilla, elige los agentes segun el
tipo de proyecto, sustituye los marcadores que se pueden saber de antemano, inicializa git y
lista lo que queda por rellenar.

**Propuso.** El usuario, preguntando si se podia automatizar sin tener que hacer nada.

**Por qué.** En el plan de la Spec 000 estaba registrado como alternativa descartada, con la
nota de reevaluarlo en el cuarto proyecto. La pregunta lo adelanta: el coste de copiar a mano
y editar siete archivos se paga en cada proyecto, no en el cuarto.

**Que no hace, a proposito.** No inventa nada del proyecto. El stack, los comandos, las
trampas de dominio y el formato de datos solo los sabe quien lo pide. El script resuelve lo
mecanico y lista los huecos: rellenarlos por su cuenta produciria un `AGENTS.md` que parece
completo y no dice nada de este proyecto.

**Consecuencia.** El informe de pendientes usa lista blanca: solo los archivos que la persona
edita. La primera version listaba 55 marcadores, de los cuales 40 eran ejemplos de formato
dentro de la skill y la spec de ejemplo. Un informe asi se ignora entero.

**Fallos encontrados al probarlo, y corregidos:**

1. El script no llevaba BOM, asi que PowerShell 5.1 lo leia como ANSI y el parser fallaba con
   los acentos del patron.
2. La clave de sustitucion de `<TECNOLOGIAS Y VERSIONES CLAVE>` no llevaba tilde, y
   `-replace` no falla cuando no encuentra: el marcador se quedaba en el archivo generado sin
   ningun aviso.
3. El listado de pendientes tampoco lo detectaba, porque su patron solo aceptaba ASCII. Dos
   filtros que fallaban en silencio seguidos parecian que no habia fallo.

Los tres estan en `aprendido.md`, porque los tres volveran a ocurrir.

---

## 2026-10-09 — Los agentes los recluta el proyecto, no una lista de partida

**Decisión.** Se abandona el conjunto fijo de cuatro agentes. La plantilla ofrece doce
candidatos y el proyecto se queda con los que su trabajo requiera. El límite lo marca la
ne necesidad, no un número.

**Propuso.** El usuario, con el argumento de que un edificio necesita arquitecto, aparejador
y albaniles, y una campana de publicidad director, disenador y editor: el equipo lo define
la tarea.

**Afecta a.** `directrices/AGENTES.md`, `plantilla/.opencode/agents/`, `plantilla/LEEME.md`.

**Por qué.** El modelo anterior tenia una «base obligatoria» de cuatro agentes heredada del
curso. La justificacion honesta era solo la frontera de permisos, y el mas debil de los
cuatro —`coordinator`— ha pasado a opcional: su trabajo consiste en repartir entre
subagentes, y desde que delegar no requiere autorizacion previa el primario puede hacerlo
directamente.

**Como se decide ahora.** Tabla por tipo de proyecto (web, API, datos, CLI, movil, infra,
documentacion) como punto de partida, y un procedimiento de cuatro pasos. Dos agentes son
comunes a todos: alguien que planifique y alguien que revise. Sin planificacion no hay
spec; sin revision, el principio 5 no se cumple.

**Catalogo completo.** Once de trabajo —`planner`, `implementer`, `reviewer`, `tester`,
`debugger`, `docs-writer`, `security-auditor`, `refactorer`, `perf-auditor`, `migrator`,
`frontend-reviewer`— mas `coordinator`, opcional.

**Consecuencia.** Cada agente del catalogo tiene escrita la restriccion de permisos que lo
justifica, porque esa es la unica razon valida para que exista como agente y no como
comando.

---

## 2026-10-09 — La verificación repetida se automatiza

**Decisión.** El principio 5 gana un criterio concreto: cualquier comprobación que se haga
a mano dos veces se propone como herramienta externa o script. Y se extiende más allá de
los tests: cualquier tarea repetida y automatizable.

**Propuso.** El usuario.
**Afecta a.** `EXPECT.md` (condición de verificación), `CONSTITUTION.md` principio 5,
`CAPACIDADES.md`.

**Por qué.** La verificación manual que se repite **se repite peor**: cada vez se hacen
menos pasos y se deja de detectar lo que se detectaba al principio. No es solo tiempo
perdido, es fiabilidad perdida.

**El alcance.** La tabla de herramientas cubre linter, tipos, tests, accesibilidad,
navegador controlado, perfilado y seguridad. Y fuera del código: generar datos de prueba,
poblar una base de datos, validar un formato, convertir archivos, ejecutar el proyecto en
condiciones concretas.

**El criterio para elegir herramienta.** El mismo que para un requisito: si se puede
ejecutar y produce un resultado, es una comprobación; si solo es una impresión, no lo es.

**«Lo haría más rápido a mano» es la señal para automatizarlo**, no para saltárselo.

---

## 2026-10-09 — Sin `MEMORY.md` en la raíz de este repositorio

**Decisión.** La capa genérica define el protocolo de memoria, pero este repo no tiene un
`MEMORY.md` propio. Sus equivalentes son `aprendido.md` y este archivo.

**Propuso.** El agente.
**Por qué.** No hay código que implementar, así que no hay estado de implementación que
recordar. Un archivo con la forma correcta y el contenido vacío enseña mal.
