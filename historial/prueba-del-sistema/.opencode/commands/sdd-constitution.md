---
description: SDD · Propone la constitución del proyecto (principios innegociables)
agent: plan
---

Vamos a crear —o revisar, si ya existe— `docs/constitution.md`. Usa la skill `sdd`.

Antes de proponer nada, lee `AGENTS.md`, `MEMORY.md` y el código del proyecto.

Contexto adicional: $ARGUMENTS

Proponme **6 principios innegociables**, cortos y verificables, que cubran:

1. Simplicidad del stack: qué se permite usar y qué no.
2. Relación entre spec y código: nada se implementa si no está en la spec activa.
3. Separación entre lógica e interfaz: qué es función pura y qué toca el DOM o los datos.
4. Política de comprobación: con qué se comprueba y qué pasa si está en rojo.
5. Protección de los datos del usuario: dónde se guardan y qué no se puede perder.
6. Idioma: código en un idioma, textos y documentación en otro.

Máximo 15 líneas en total. Cada principio debe ser comprobable: si no se puede demostrar que
se cumple o se incumple, no es un principio, es una intención.

**NO escribas el archivo todavía: espera mi aprobación.**
