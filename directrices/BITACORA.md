# BITACORA.md — Registro de decisiones

Cada decisión sobre las directrices: qué se decidió, cuándo, por qué y quién la propuso.
El objetivo es poder reconstruir el razonamiento, no solo el resultado.

Los cambios en las directrices se anotan aquí **antes** de aplicarse. Una directiva
modificada sin registro se considera un error.

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
