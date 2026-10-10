# Tareas 001 — Contador con nombre guardado

Tareas derivadas de `spec.md` y `plan.md`.

---

- [ ] **T1. Función `normalizarNombre`.** RF-4, RF-5
  - Hecho cuando: recorta extremos, devuelve `""` con solo espacios, y `node --test` pasa.

- [ ] **T2. Función `incrementar`.** RF-2
  - Hecho cuando: suma 1 a un número, devuelve 1 con entrada no numérica, y el test pasa.

- [ ] **T3. Función `estadoInicial`.** RF-8
  - Hecho cuando: devuelve contador 0 y nombre vacío con `null`, JSON roto o tipos
    incorrectos, y el test pasa.

- [ ] **T4. Estructura HTML.** RF-1, RF-6
  - Hecho cuando: la página abre sin errores en consola y muestra el campo de nombre.

- [ ] **T5. Conexión de la lógica con el DOM.** RF-1, RF-2, RF-3
  - Hecho cuando: guardar nombre y pulsar contar funcionan, y el estado sobrevive a recargar.

- [ ] **T6. Reinicio y casos límite visuales.** RF-7, RF-8
  - Hecho cuando: reiniciar pone a cero y borra el nombre, y un valor corrupto en
    `localStorage` arranca en estado inicial sin error.

- [ ] **T7. Verificación completa.** todos
  - Hecho cuando: los ocho requisitos recorridos uno a uno con su comprobación, la vista
    móvil comprobada a 375 px, y `MEMORY.md` actualizado.

---

## Al terminar

- Marcar esta spec como `implementada`.
- Registrar en `aprendido.md` del sistema todo lo que el flujo haya revelado.
