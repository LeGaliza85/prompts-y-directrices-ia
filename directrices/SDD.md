# SDD.md — Spec-Driven Development

> Es el flujo que gobierna todo proyecto. Lo que no está aquí, no se hace.

## Qué es

Primero defines **qué debe hacer el sistema** —requisitos, límites y criterios de
aceptación— y después usas esa especificación para guiar la implementación y comprobar el
resultado.

No es documentación que se escribe después de codificar. La spec está **viva**: guía la
implementación, se comprueba contra el resultado, y se modifica cuando el requisito cambia.

## Las tres formas

| Forma | Cómo funciona | Cuándo |
|---|---|---|
| **Spec-first** | Escribes la spec, generas el código una vez, y desde entonces editas el código directamente. | Prototipos. La spec muere al empezar el código. |
| **Spec-anchored** | La spec se mantiene viva: se conserva y se actualiza para seguir guiando el código. | **Por defecto.** |
| **Spec-as-source** | Se edita solo la spec; el código se genera a partir de ella y no se toca a mano. | Solo con generación automática fiable. |

**Spec-anchored es la opción por defecto.** La diferencia que importa: cuando el código y
la spec discrepan, en spec-first no hay manera de saber cuál tiene razón. En spec-anchored
la spec manda (principio 2).

## El flujo

```
Constitución → Spec → Clarificación → Plan → Tareas → Implementación → Validación → Cambio ↑ │
     └────────────────────────── vuelve al paso 2 ─────────────────────────────┘
```

| # | Fase | Qué ocurre |
|---|---|---|
| 1 | **Constitución** | Una vez por proyecto. Principios innegociables. |
| 2 | **Especificación** | Qué y por qué. Nada de stack ni de nombres de archivo. |
| 3 | **Clarificación** | Revisión de la spec como QA. Detecta, no resuelve. |
| 4 | **Planificación** | Cómo se va a construir: archivos, funciones, decisiones. |
| 5 | **Tareas** | El plan dividido en unidades verificables. |
| 6 | **Implementación** | Una tarea cada vez. Comprobación primero, código después. |
| 7 | **Validación** | Recorrido de la spec requisito por requisito. |
| 8 | **Cambio** | Un requisito nuevo pasa por la spec antes que por el código. |

## Las reglas del flujo

- **Nunca se pasa de fase sin tu aprobación explícita**, ni de la spec ni del plan con sus
  tareas.
- **La spec manda.** Lo que no está en la spec no se implementa. Si falta una decisión, se
  para y se pregunta.
- **Un cambio de requisito va primero a la spec**, luego al plan y las tareas, y por último
  al código. Ese es el paso 8, y es el que evita que el código y la spec se separen sin
  que nadie lo note.
- **Una tarea cada vez.** Implementar dos tareas y esperar que "salgan bien" es cómo se
  pierde el hilo de qué está verificado y qué no.
- **Al terminar cada fase, `MEMORY.md` se actualiza.**
- La clarificación puede repetirse tras el plan o las tareas si algo sigue sin quedar claro.
  Repetir una fase barata es mejor que implementar sobre una ambigüedad cara.

## Qué produce cada fase

| Fase | Archivo | Contiene | No contiene |
|---|---|---|---|
| 1 | `docs/constitution.md` | Principios innegociables | Detalles de implementación |
| 2 | `spec.md` | Contexto, requisitos, criterios, límites | Stack, arquitectura, nombres de archivo |
| 3 | — (lista en el chat) | Ambigüedades detectadas | Soluciones |
| 4 | `plan.md` | Archivos, funciones, decisiones justificadas, estrategia de comprobación | Código |
| 5 | `tasks.md` | Tareas de 20-30 min con su «hecho cuando» | Código |
| 8 | Revisa spec, plan y tareas | El requisito nuevo, en su sitio | Cambios directos en código |

**La frontera de la fase 2 es la que más se olvida:** la spec describe el **qué** y el **por
qué**. El stack, la arquitectura y los nombres de archivo son del plan. Escribir nombres
de archivo en la spec ata la solución a una estructura que todavía no está decidida.

## Estructura de un proyecto con SDD

```
proyecto/
├── AGENTS.md · MEMORY.md · opencode.jsonc
├── .opencode/
│   ├── agents/        subagentes
│   └── commands/      comandos /sdd-*
├── .agents/skills/    habilidades
├── docs/
│   └── constitution.md
├── specs/
│   ├── 001-nombre/
│   │   ├── spec.md
│   │   ├── plan.md
│   │   └── tasks.md
│   └── 002-nombre/
└── <código del proyecto>
```

Cada spec en su carpeta numerada: `specs/NNN-nombre/`, con `spec.md`, `plan.md` y `tasks.md`.

`NNN` es un número correlativo de tres cifras. La spec **activa** es la de mayor número sin
marcar como `implementada`: si hay tres, se trabaja sobre la más alta, y las anteriores son
histórico que no se toca.

El nombre de la carpeta lleva un guion y minúsculas. Se usa tal cual al invocar los comandos
del sistema: `/sdd-plan 002-mapa-de-calor`.

## Cuándo no usar SDD

SDD tiene coste: escribir requisitos, clarificar, planificar, generar tareas. Ese coste no
se paga en todo.

**No hace falta spec para:**

- Un cambio evidente.
- Un refactor mecánico.
- Corregir algo que ya está en el plan.
- Una exploración para entender cómo funciona algo.

**Sí hace falta para:**

- Cualquier funcionalidad con comportamiento que se pueda definir mal.
- Cualquier cambio que afecte a datos o a APIs.
- Cualquier cosa que resulte problemática si se implementa al revés.

**La regla práctica:** si el error sería caro, escribe la spec. Si es caro deshacerlo, no.

Una spec de media hora sale más barata que una implementación que hay que revertir.