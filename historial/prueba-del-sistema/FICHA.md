# Prueba del Sistema

**Qué era.** Proyecto de prueba creado para demostrar que el sistema funciona de principio a
fin: script de arranque, flujo SDD, tests de lógica y verificación de interfaz en navegador
real.

**Stack.** HTML, CSS y JavaScript puros. Sin dependencias, sin compilación.

**Fechas.** 2026-10-10, una sesión.
**Estado.** terminado. Sirvió para lo que se creó.

## Directrices usadas

- **Origen:** plantilla de este repositorio, generada con
  `nuevo-proyecto.ps1 -Tipo web -Stack "HTML, CSS y JavaScript puros" -Git`.
- **Archivos modificados respecto a la plantilla:** `docs/constitution.md`,
  `specs/000-plantilla/` sustituida por `specs/001-contador/`, y `MEMORY.md` sin rellenar al
  cerrar.
- **Constitución:** 6 principios, adaptados. Uno añadido a propósito como prueba: el patrón
  de exportación doble.

## Agentes

Cinco, los del tipo `web`: `planner`, `implementer`, `reviewer`, `frontend-reviewer`,
`tooling-advisor`.

**No se usó ninguno.** El flujo se ejecutó completo a mano, y esa es precisamente una de las
cosas que la prueba reveló: el catálogo está bien, pero sin el coordinador que reparta, el
agente primario tiende a hacerlo todo él.

## Herramientas

**Aprobadas y usadas:**

- `node --test` — 12 tests de la lógica pura. Funcionó a la primera.
- **Chrome real por CDP** (Chrome 154, protocolo de depuración, `WebSocket` nativo de Node) —
  verificación de los 14 puntos de la interfaz, incluida la corrupción de `localStorage` y el
  ancho de 375 px. **Este es el hallazgo más útil de la prueba.**

**Propuestas y descartadas:**

- **chrome-devtools MCP** — No se activó. Se instaló el paquete y funcionó, pero usarlo exige
  conectarlo a la sesión y reiniciar, y desde dentro de una sesión ya abierta no es posible.
  Se usó en su lugar el CDP directamente, que da el mismo resultado sin depender de la
  sesión. Descarta esta vía solo para el trabajo de una sesión ya abierta.

## Specs

- `001-contador` — implementada. 8 requisitos, 12 tests, 14 comprobaciones de interfaz.

## Lo que se aprendió

Errores de proceso y de diseño encontrados al hacerlo de verdad:

1. **`module.exports` no funciona en el navegador.** La lógica pura compartida entre
   `node --test` y la página necesita un patrón de exportación doble. La constitución prohibía
   `type="module"` y `fetch`, así que la solución era comprobar si `module` existe. Este es el
   tipo de trampa que **solo aparece al construir**, no al leer la plantilla.
2. **Un test sobreespecificó.** El test exigía descartar el nombre cuando el contador estaba
   corrupto. El código hacía lo correcto —recuperar lo válido— y el test fallaba. La
   constitución dice que los datos del usuario son sagrados, así que el test era el erróneo.
3. **El script de arranque funciona, pero lista marcadores que ya no aplican.** Después de
   sustituir la spec de ejemplo, el script seguía ofreciendo `<idea>` y `<requisito>` de
   `LEEME.md`, que son texto de la tabla de comandos, no marcadores por rellenar.
4. **RF-1 y RF-11 quedan demostrados.** La plantilla se copió y el proyecto se archivó aquí.
   Los dos requisitos que dependían de un proyecto real ya no son hipótesis.

## Restaurar este proyecto

```powershell
Copy-Item -Recurse -Force "historial\prueba-del-sistema\*" "C:\ruta\nueva\"
```

Falta el código —`index.html`, `app.js`, `logica.js`, `styles.css`— que no forma parte de las
directivas y por eso no se archiva. Está en el proyecto original.
