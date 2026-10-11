# PRÓXIMA SESIÓN

**Fecha:** 2026-10-11
**Estado:** verificador en verde. 106 archivos, 0 incidencias. Batería de 15 casos, 15 correctos.
**Último commit:** `8627291`. Árbol limpio. 36 commits.
**Si has perdido el hilo:** lee `ESTADO.md` antes de esto. Tiene el paso exacto.

## Dónde paramos

La sesión se cerró con todo el material listo para entregarse a otro usuario. El paquete
está hecho y verificado.

### El entregable

| Fichero | Para qué |
|---|---|
| `C:\Proyectos\entrega\prompts-y-directrices-ia.zip` | El que se manda. 4,2 MB, 115 ficheros |
| `C:\Proyectos\entrega\prompts-y-directrices-ia.bundle` | Alternativa si el otro usuario usa git |
| `C:\Proyectos\entrega\mensaje-para-enviar.txt` | El texto del correo |

**No se ha enviado.** No hay herramienta de email ni acceso al Gmail. Queda pendiente solo
el envío, que son 30 segundos: adjuntar el zip y pegar el texto.

Si se vuelve a generar el zip o el bundle, hay que hacerlo **después** del último commit,
porque se construyen con `git ls-files`. Un zip generado antes de un commit sale con
ficheros viejos.

## Lo que quedó pendiente

**Bloquea la mejora de estado**
1. **Dónde vive el estado durable.** Se propuso `ESTADO.md`, que ya existe, pero la
   decisión de si es ese o `PROXIMA-SESION.md` o `tasks.md` sigue sin tomarse formalmente.
   `ESTADO.md` se creó por criterio propio y funciona; conviene confirmarlo o cambiarlo.

**Van juntas**
2. **Regla de interrupción** — seguir con la tarea previa cuando el usuario interrumpe,
   salvo que lo pida o que seguir sea contraproducente. **Pendiente de escribir** en
   `directrices/AGENTS.md` y `plantilla/AGENTS.md`.
3. **Principio ampliado** — ningún paso se cierra solo en la conversación; su resultado
   tiene que estar en el repo. Pendiente de escribir.

**Independientes**
4. **T13** — proyecto `divisor` con subagentes. Es la prueba que junta `modelos.ps1 -Elegir`
   (elegir antes de delegar) con el watchdog (vigilar durante). Sin ella, ninguna de las dos
   mitades tiene prueba real más allá del log.
5. **`tasks.md`** — T1 a T12 siguen marcadas pese a estar hechas. T13 es la única pendiente.
6. **Acceso remoto** — investigado y documentado, **cero instalado** (ni Tailscale ni
   RustDesk).

## Lo que no se puede hacer, y no se rellena

- **El tiempo desde que se llama al subagente hasta que arranca.** Las líneas
  `permission=task` llevan `run=` pero no `session.id`. Sin ese campo no se puede vincular
  una llamada con su sesión hija. No se estima.
- **Quién canceló una sesión.** Comprobado campo a campo: 156 líneas `message=cancel` con
  solo `timestamp`, `level`, `run`, `session.id`. No existe tipo de evento `abort`. Los
  campos de origen (`reason=`, `source=`, `user=`) dan 0. Solo se distingue «lo canceló el
  watchdog» revisando `watchdog-registro.md`.
- **La cuota restante del plan.** Ningún comando la expone.

## Lo que hay que reeditar, no heredar

Las mediciones de `MODELOS.md` y `BLOQUEOS.md` salieron del log de la cuenta de origen.
**No son hechos de otro sistema.** Heredarlas sin medir es lo que prohíbe el principio 10.
Lo portable es el método para medirlas, que está descrito ahí.

## Decisiones que se tomaron y por qué

Para no reabrirlas sin motivo:

- **Los umbrales de tiempo del watchdog se eliminaron.** No había medida que los sostuviera:
  el log no distingue un agente callado de un usuario ausente. Medidos 426 silencios de
  trabajo por encima de 30 s, el mayor de 1873 s.
- **El atasco se detecta por estado, no por tiempo.** Emitió stream + su último evento fue un
  stream + el silencio pasa el límite. La condición del «último evento» es la que evita los
  falsos positivos de sesiones terminadas hace horas.
- **`modelos.ps1` sin umbrales.** Ni tope, ni memoria de resultado, ni paralelismo. Los tres
  eran invención.
- **ZED se dejó marcado «sin verificar».** No se comprobó su formato de agentes ni cómo carga
  instrucciones. No se afirma que funcione.
- **ChatGPT se documentó con su límite real:** sin acceso al sistema de ficheros no lee el
  repo ni carga los agentes; solo viaja el método como texto.

## Errores de esta sesión, para no repetirlos

Están desarrollados en `aprendido.md`, que ya va por 13 entradas. Los tres que más cuestan:

1. **Afirmar sin comprobar.** Cinco retractadas en una sesión. Directiva: si la comprobación
   no se ha ejecutado, no se afirma.
2. **`$S` y `$s` son la misma variable en PowerShell.** Un análisis se destruyó a sí mismo.
   Usar `$tabla` y `$fila`.
3. **Un objeto nuevo no hereda las propiedades del hashtable.** `Get-Sesiones` tenía los
   datos y no los copiaba; el contador daba cero sin error.

## Antes de dar nada por bueno

```powershell
powershell -File verificar.ps1
```

Si sale rojo, suele ser el recuento de ficheros: cada `.md` nuevo obliga a actualizar
`AGENTS.md`, `INDICE.md` y `PROXIMA-SESION.md` a la vez.
