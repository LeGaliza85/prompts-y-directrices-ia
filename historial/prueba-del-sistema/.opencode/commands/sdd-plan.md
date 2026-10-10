---
description: SDD · Genera el plan técnico de una especificación aprobada
agent: plan
---

Lee `docs/constitution.md`, `AGENTS.md` y `specs/$1/spec.md`. Usa la skill `sdd`.
**NO escribas código.**

Genera `specs/$1/plan.md` con:

1. **Archivos** que se crean o modifican, y la responsabilidad de cada uno.
2. **Funciones puras** de lógica que se necesitan, con la fecha actual como parámetro donde
   aplique, para poder comprobarlas sin abrir la interfaz.
3. **Algoritmo** en pseudocódigo.
4. **Interfaz**: cómo se pinta, qué estados hay y qué se ve en cada uno.
5. **Decisiones técnicas justificadas**, cada una **con su alternativa descartada** y por qué
   se descartó.
6. **Estrategia de comprobación**, con una tabla de qué requisito cubre cada parte.

Todo debe respetar la constitución y cubrir todos los requisitos de la spec.

Si la spec no está aprobada, o tiene dudas abiertas, **para y avísame**.
