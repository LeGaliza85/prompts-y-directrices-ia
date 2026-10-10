# PROXIMA-SESION.md — Estado al cerrar la sesión del 2026-10-10

Actualizado por el agente al terminar la sesión. **Este archivo es lo primero que se lee al
abrir el repo**: si estás aquí, léelo entero antes de tocar nada.

---

## Para la próxima sesión: tres cosas que hay que hacer

El usuario pidió expresamente que se le recuerden estas tres. Están en este orden:

### 1. Verificar todo lo hecho hasta ahora, buscando fallos

**Qué.** Pasar el revisor por la capa genérica, la plantilla y el proyecto de prueba. No es la
comprobación de `verificar.ps1` —eso solo mira caracteres y palabras sueltas— sino revisión de
fondo: contradicciones internas, referencias rotas, ejemplos que incumplen su propia regla,
tablas que no discriminan, sintaxis desactualizada.

**Dónde quedó.** Los tres documentos ya están definidos. Queda ejecutarlos.

**Herramienta.** El agente `reviewer` en `.opencode/agents/reviewer.md`. Revisa sin modificar
nada, que es justo lo que hace falta: detecta, no arregla.

**Estado.** Ya se hizo una pasada y corrigió cinco fallos. Esta es una segunda pasada, sobre
lo que se añadió después: los 10 comandos `/sdd-*`, los tres documentos de método, el script
de arranque y el proyecto de prueba.

### 2. Asegurar que el sistema funciona fuera de OpenCode y con otros modelos

**Por qué importa.** Hoy casi todo está verificado contra OpenCode 1.4.0 y contra nada más.
Los requisitos de la Spec 000 no dicen "en OpenCode": dicen "con agentes de IA". Si el sistema
sirve solo aquí, está a medio hacer.

**Qué es portable y qué no.**

| Portable | Anclado a OpenCode |
|---|---|
| Los 9 principios | `opencode.jsonc` y su campo `instructions` |
| `SDD.md`, `EARS.md` | La carpeta `.opencode/` |
| `EXPECT.md`, `MEMORY.md` | El frontmatter de agentes y comandos |
| La spec, el plan, las tareas | La skill `sdd` con su `description` |
| `verificar.ps1` (es PowerShell puro) | — |

**`AGENTS.md` sí es estándar**: lo leen varios agentes, no solo OpenCode. Es el punto más
fuerte de portabilidad del sistema.

**Qué hacer.**

1. Revisar qué documentos mencionan OpenCode por su nombre y si ese dato podría ir en un
   apartado en vez de en el cuerpo.
2. Anadir a cada documento que dependa de la herramienta una nota de qué cambia en otros
   agentes: Cursor usa `.cursor/rules/`, Claude Code usa `CLAUDE.md`, otros leen `AGENTS.md`.
3. Comprobar que la constitución genérica y `SDD.md` no mencionan la herramienta en ningún
   sitio donde no haga falta.
4. Dejar escrito qué habría que adaptar para usar la capa genérica con otro agente, aunque no
   se adapte ahora.

### 3. Preguntar al agente qué añadiría y qué recomendaría

**Por qué.** El sistema está construido desde el curso y desde lo que ha ido haciendo falta,
pero nadie se ha parado a mirarlo desde fuera con lo aprendido. El usuario quiere esa
opinión explícita, no implícita.

**Cómo responderlo.** Con lo que **no** está y se echa de menos, no con una lista de deseos.
Lo que sobra también cuenta: si hay algo que no aporta, decirlo.

---

## Estado del trabajo

| Bloque | Estado |
|---|---|
| 0 · Andamiaje | hecho |
| 1 · Capa genérica (17 documentos) | hecho |
| 2 · Blindaje contra desactualización | hecho |
| 3 · Plantilla (33 archivos, 10 comandos) | hecho |
| 4 · Registro: historial, curso | hecho |
| 5 · Spec 000 | hecho |
| 6 · Prueba con proyecto real | **hecho** |
| 7 · Correcciones que reveló la prueba | **pendiente** |
| 8 · Portabilidad a otros agentes | **pendiente** |

## Lo que dejó la prueba, sin corregir

Estos cuatro salieron de `historial/prueba-del-sistema` y quedan anotados en
`directrices/aprendido.md`, pero **no se han aplicado al sistema**:

1. **El patrón de exportación doble.** La lógica compartida entre `node --test` y el navegador
   lo necesita. No está en la plantilla como trampa conocida. Es el fallo más caro de los
   cuatro porque **los tests pasan y la página se rompe**.
2. **El pendiente falso del script.** `nuevo-proyecto.ps1` lista `<idea>` y `<requisito>` del
   LEEME como marcadores por rellenar, y no lo son.
3. **La verificación de interfaz sin MCP.** El CDP directo funcionó y el MCP no se pudo activar
   desde una sesión abierta. El método está en `aprendido.md` pero no es una herramienta del
   repo.
4. **Sin memoria del proyecto al cerrar.** El `MEMORY.md` de la prueba quedó sin rellenar. No
   es un fallo del sistema, es un fallo de proceso: la última tarea era rellenarlo.

## Lo que no se ha probado

- **El flujo con agentes.** En la prueba el agente primario hizo todo a mano. Que el catálogo
  de 13 agentes y los 10 comandos funcionen Delegando no está comprobado.
- **La constitución de un proyecto con tests reales.** La de la prueba se escribió a medida,
  no se generó con `/sdd-constitution`.
- **`historial/` con más de un proyecto.** Se archiva uno. El formato no está probado frente a
  un segundo.

## Notas para quien retome

- **La versión real de OpenCode es 1.4.0**, no la que marcan los metadatos del binario (1.3.11).
  Manda `opencode --version`. Detalle en `directrices/PIN.md`.
- **Este repo ya tiene `AGENTS.md` en la raíz**, que antes no tenía y por eso una sesión nueva
  arrancaba sin instrucciones. Fue la razón de crear este archivo.
- **Sigue sin haber `MEMORY.md` en la raíz**, a propósito: aquí no hay estado de
  implementación que recordar. Este archivo hace esa función.
