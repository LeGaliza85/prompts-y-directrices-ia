# ESTADO

Estado crudo de ejecución. **Se escribe antes del riesgo, no después.** Su función es que un
agotamiento de contexto cueste un paso, no la sesión.

No es documentación: es el sitio donde vive el dato que se pierde si la conversación se
corta. Léelo junto a `PROXIMA-SESION.md`, que tiene el relato.

## Última actualización

2026-10-10, cierre de sesión.

## Paso actual

**Ninguno en curso.** La sesión terminó con el trabajo commiteado y el paquete de entrega
generado.

## Lo último que se hizo

1. `PROXIMA-SESION.md` reescrito: el commit que tenía (`18ef8d9`) llevaba varios commits de
   retraso.
2. Este fichero creado.

## Lo siguiente, en orden

| # | Qué | Dónde |
|---|---|---|
| 1 | Regla de interrupción: seguir con la tarea previa salvo que el usuario lo pida o seguir sea contraproducente | `directrices/AGENTS.md` (Mientras trabajas › Siempre) y `plantilla/AGENTS.md` (Forma de trabajar) |
| 2 | Principio ampliado: ningún paso se cierra solo en la conversación | `directrices/CONSTITUTION.md` |
| 3 | T13: proyecto `divisor` con subagentes | `C:\Proyectos\divisor` |
| 4 | Limpiar T1-T12 de `tasks.md` | `specs/000-sistema-de-trabajo/tasks.md` |
| 5 | Acceso remoto, si se decide | — |

## Decisiones que bloquean y quién las toma

| Decisión | Estado |
|---|---|
| Si `ESTADO.md` es el sitio del estado o si va en `PROXIMA-SESION.md` | Sin tomar. Se creó por criterio propio |
| Si `verificar.ps1` debe mirar también `.ps1` y `.jsonc` | Sin tomar. Hoy se corrompieron dos ficheros que el verificador no cubre |

## Lo que está verificado hoy

| Dato | Valor | Fuente |
|---|---|---|
| Commits | 32 | `git rev-list --count HEAD` |
| Ficheros versionados | 115 | `git ls-files` |
| Documentos en `directrices/` | 23 | conteo |
| `.md` en todo el repo | 104 | conteo |
| Scripts | 5 | `git ls-files` |
| Verificador | verde | `verificar.ps1` |
| Paquete de entrega | zip y bundle de 4,2 MB | generados tras `efdde48` |

## Trampas a recordar

- Cada `.md` nuevo desincroniza las cifras. `verificar.ps1` lo pilla y hay que corregir
  `AGENTS.md`, `INDICE.md` y `PROXIMA-SESION.md`.
- Los scripts `.ps1` necesitan BOM. Sin él, PowerShell 5.1 los lee como ANSI.
- No interpoles variables de PowerShell dentro de cadenas al escribir texto: `$o""gica`
  deja una comilla dentro de la palabra. Usa la herramienta de edición.
- El zip se genera con `git ls-files`. Si se hace antes de un commit, sale viejo.

## Cómo retomar

1. `powershell -File verificar.ps1` — verde.
2. Leer `PROXIMA-SESION.md`.
3. Mirar la tabla «Lo siguiente, en orden» de arriba y empezar por el 1.
