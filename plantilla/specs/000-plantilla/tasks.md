# Tareas 000 — Búsqueda en la lista de sesiones

Tareas derivadas de `spec.md` y `plan.md`. Una tarea cada vez: implementar, comprobar,
marcar y parar.

---

- [ ] **T1. Función pura de filtrado.** RF-1, RF-2, RF-5
  - Hecho cuando: `filtrar(sesiones, texto)` devuelve lo que dice la spec, con los cinco
    casos límite cubiertos por un test que pasa.

- [ ] **T2. Detección de filtro activo.** RF-5, RF-6, RF-7
  - Hecho cuando: `hayFiltroActivo(texto)` devuelve falso para cadenas vacías y con solo
    espacios, con test que pasa.

- [ ] **T3. Campo de búsqueda en la interfaz.** RF-1
  - Hecho cuando: el campo existe sobre la lista, tiene etiqueta asociada y al escribir se
    muestra la lista filtrada.

- [ ] **T4. Botón de limpiar.** RF-6, RF-7
  - Hecho cuando: el botón vacía el campo y quita el filtro; se oculta cuando no hay
    texto. Comprobado a mano.

- [ ] **T5. Mensaje de sin resultados.** RF-4
  - Hecho cuando: con filtro activo y cero coincidencias se muestra el mensaje; con la
    lista vacía desde el principio se muestra el mensaje de "no hay sesiones", que es
    otro. Comprobado a mano.

- [ ] **T6. Comprobación de accesibilidad y cierre.** todos
  - Hecho cuando: el campo se alcanza con Tab, la etiqueta está asociada, y los requisitos
    de la spec se han recorrido uno a uno con su comprobación.

---

## Al terminar

- Actualizar `MEMORY.md`: la decisión de filtrar en memoria y su alternativa descartada.
- Revisar si `spec.md` debe pasar a estado `implementada`.
- Cerrar las dos dudas abiertas de la spec, o dejarlas marcadas con el motivo.
