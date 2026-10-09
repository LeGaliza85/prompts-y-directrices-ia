# Tareas 000 — Sistema de trabajo con IA

Tareas de la spec `spec.md` según el `plan.md`. Una tarea cada vez: implementar, comprobar,
marcar y parar.

---

- [ ] **T1. Comprobador de documentos.** RF-8
  - Hecho cuando: `verificar.ps1` recorre los `.md` y detecta caracteres cirílicos o CJK,
    puntuación CJK y palabras en inglés. Probado contra un archivo con fallos sembrados.

- [ ] **T2. Blindaje de versiones.** RF-7
  - Hecho cuando: `PIN.md`, `APIS-VERIFICADAS.md` y `PROCEDIMIENTO-ACTUALIZACION.md` existen,
    con la versión real instalada y la fecha de cada comprobación.

- [ ] **T3. Capa genérica.** RF-1 a RF-8, RF-10
  - Hecho cuando: los 14 documentos de `directrices/` están escritos, verificados sin
    incidencias y coherentes entre sí.

- [ ] **T4. Catálogo de agentes.** RF-5
  - Hecho cuando: el catálogo de trece agentes existe en `directrices/AGENTES.md` y como
    archivos copiables en `plantilla/.opencode/agents/`, cada uno con la restricción de
    permisos que lo justifica.

- [ ] **T5. Catálogo de capacidades.** RF-6, RF-9
  - Hecho cuando: `CAPACIDADES.md` cataloga MCP, skills y herramientas con su coste, y
    documenta el rechazo con su motivo.

- [ ] **T6. Plantilla.** RF-1
  - Hecho cuando: `plantilla/` está completa, `LEEME.md` solo lista archivos que existen, y
    `opencode.jsonc` es JSON válido.

- [ ] **T7. Registro de errores y decisiones.** RF-3, RF-4
  - Hecho cuando: `aprendido.md` tiene al menos tres entradas reales con causa y directiva, y
    `BITACORA.md` registra las decisiones con su alternativa descartada.

- [ ] **T8. Archivo de proyectos.** RF-11
  - Hecho cuando: `historial/_plantilla.md` define el formato de ficha y la regla de copia
    literal.

- [ ] **T9. Material de origen.** —
  - Hecho cuando: los PDF están en `curso/originales/` con su hash, y `curso/apuntes/` tiene
    lo extraído organizado por tema.

- [ ] **T10. Revisión completa.** todos
  - Hecho cuando: `reviewer` ha recorrido la capa genérica y la plantilla buscando
    incoherencias, referencias rotas, ejemplos que contradicen su regla y sintaxis
    desactualizada, con su informe.

---

## Al terminar

- Marcar la spec como `implementada` si el revisor la aprueba.
- Anotar en `aprendido.md` lo que la revisión encuentre.
- Dejar anotado qué requisitos quedan sin demostrar hasta que exista un proyecto real: RF-1 y
  RF-11.
