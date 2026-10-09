# INDICE — Prompts y directrices IA

Biblioteca de directrices para trabajar con agentes de IA en cualquier proyecto. Lo que hay
aquí se propone, se aprueba y se registra antes de escribirse en disco.

**Estado:** capa genérica completa · plantilla completa · falta el registro y la Spec 000.

## Para empezar en 30 segundos

**Si vienes a trabajar en un proyecto ya creado:** copia `plantilla/` y sigue el
`plantilla/LEEME.md`.

**Si quieres entender cómo se trabaja aquí:** lee, en este orden, `directrices/CONSTITUTION.md`
(los 9 principios) y `directrices/AGENTS.md` (qué hago en concreto).

**Si quieres ver qué se decidió y por qué:** `directrices/BITACORA.md`.

**Si algo no funciona y crees que es la versión:** `directrices/PIN.md`.

## Qué hay

### `directrices/` — la capa genérica

Lo que se aplica a cualquier proyecto, con independencia del stack.

| Documento | Qué es |
|---|---|
| `CONSTITUTION.md` | Los 9 principios innegociables, en tres bloques, con su origen. |
| `AGENTS.md` | Instrucción maestra: qué hago al empezar, mientras trabajo y al terminar. |
| `MEMORY.md` | Protocolo de memoria entre sesiones y cuándo recortarla. |
| `EXPECT.md` | Cuándo se da algo por terminado, y la decisión de calidad frente a velocidad. |
| `SDD.md` | El flujo de 8 fases, las tres formas de SDD y cuándo no usarlo. |
| `EARS.md` | Cómo se escribe un requisito para que sea verificable, con ejemplos. |
| `APIS-VERIFICADAS.md` | Inventario de la sintaxis de OpenCode comprobada, con su fecha. |
| `PIN.md` | La versión exacta contra la que está verificado todo esto. |
| `PROCEDIMIENTO-ACTUALIZACION.md` | Qué hacer al actualizar OpenCode, con los modos de fallo silencioso. |
| `CAPACIDADES.md` | Catálogo de MCP, skills y herramientas, con el formato para proponerlas. |
| `AGENTES.md` | Catálogo de subagentes: quién necesita cada proyecto y cómo se eligen. |
| `OPENCODE.md` | Referencia práctica de la herramienta: agentes, comandos, modo Plan. |
| `aprendido.md` | Errores de proceso, con su causa y la directiva que los previene. |
| `BITACORA.md` | Registro de decisiones con su razonamiento. |

**Aviso de nombres.** `AGENTS.md` y `AGENTES.md` son dos archivos distintos que solo se
diferencian en una letra: la instrucción maestra y el catálogo de subagentes. Sitúate siempre
por la ruta completa.

### `plantilla/` — el esqueleto de un proyecto nuevo

Lo que se copia a cada proyecto. Detalle de uso en `plantilla/LEEME.md`.

Contiene `AGENTS.md`, `MEMORY.md`, `EXPECT.md`, `docs/constitution.md`, una spec de ejemplo
completa con su plan y sus tareas, la skill `sdd`, `opencode.jsonc` y trece agentes
candidatos de los que el proyecto se queda con los que necesite.

### `.opencode/` — agentes de este repositorio

`reviewer.md` (revisa sin modificar nada) y `tooling-advisor.md` (propone herramientas con su
coste). Los mismos que están en la plantilla, para poder usarlos aquí.

## Estado del trabajo

| Bloque | Estado |
|---|---|
| 0 · Andamiaje: git, carpetas y verificador | hecho |
| 1 · Capa genérica (14 documentos) | hecho |
| 2 · Blindaje contra la desactualización | hecho |
| 3 · Plantilla completa | hecho |
| 4 · Registro: historial,curso, apuntes | **en curso** |
| 5 · Spec 000, el sistema aplicado a sí mismo | pendiente |

### Lo que falta

- `historial/` — copia literal de las directrices de cada proyecto, con su ficha. La carpeta
  existe; falta el formato y el primer proyecto que archivar.
- `curso/` — apuntes extraídos del material de origen, organizados por tema. Los PDF
  originales aún no se han copiado.
- `specs/000-sistema-de-trabajo/` — la spec de este propio repositorio.
- Lanzar `reviewer` sobre la capa genérica y la plantilla.

## Las decisiones que gobiernan cómo se trabaja aquí

Resumidas para no tener que abrir la constitución:

1. **Nada se activa sin permiso.** MCP, skill, agente o dependencia se propone con motivo,
   coste y alternativa.
2. **Lo acordado manda.** Un cambio de requisito pasa por la spec antes que por el código.
3. **Lo simple sobrevive.** Toda decisión técnica registra su alternativa descartada.
4. **Verificable o no existe.** Sin criterio medible, no es un requisito.
5. **Nada se da por bueno sin verificar.** Comprobación ejecutada y resultado visto.
6. **Aprender de los errores es parte del trabajo.**
7. **Se delega cuando aporta o cuando lo pidas.** Sin autorización previa si hay beneficio.
8. **Tú decides, yo propongo.** La iniciativa es mía en el cómo, no en el qué.
9. **Nada se ejecuta sin estar escrito.** Primero el acuerdo, después el artefacto.

El texto completo, con su ámbito y su procedencia, está en `directrices/CONSTITUTION.md`.

## Comprobación

Antes de dar cualquier documento por bueno:

```powershell
powershell -File verificar.ps1
```

Detecta caracteres cirílicos o CJK colados en texto español, puntuación china y palabras en
inglés que deberían ser españolas. No detecta errores de lógica ni incoherencias: para eso
está el agente `reviewer`.
