# PRÓXIMA SESIÓN

**Fecha:** 2026-10-11
**Estado:** verificador en verde. 106 archivos, 0 incidencias. Batería de 15 casos, 15 correctos.
**Último commit:** el de esta línea, en `master`. Árbol limpio.
**Número de commits:** no se escribe aquí a propósito. Un número de commits escrito en
un documento deja de ser cierto en el commit que lo corrige, así que se consulta:
`git rev-list --count HEAD`.
**Si has perdido el hilo:** lee `ESTADO.md` antes de esto. Tiene el paso exacto.

## Dónde paramos

El repositorio está **público** desde el 2026-10-11 en
<https://github.com/LeGaliza85/prompts-y-directrices-ia>. Se clona sin cuenta.

Lo último que se hizo fue la primera parte de la vigilancia de subagentes
(`medir-api.ps1` y `vigilancia.ps1`), y el usuario la dejó **apartada a propósito**.
Está en la sección siguiente, con el detalle de lo que falta.

### El entregable

| Fichero | Para qué |
|---|---|
| `C:\Proyectos\entrega\prompts-y-directrices-ia.zip` | El que se manda |
| `C:\Proyectos\entrega\prompts-y-directrices-ia.bundle` | Alternativa si el otro usuario usa git |
| `C:\Proyectos\entrega\mensaje-para-enviar.txt` | El texto del correo |

Como el repositorio es público, el zip ya no es la única vía: basta con pasarle el enlace.

Si se vuelve a generar el zip o el bundle, hay que hacerlo **después** del último commit,
porque se construyen con `git archive` sobre `HEAD`. Un zip generado antes de un commit
sale con ficheros viejos.

## Apartado a propósito: la vigilancia de subagentes

**El usuario dijo: «vamos a dejar esto apartado un momento». Se deja, y se vuelve sin
preguntar cuando lo pida.** No está abandonado ni olvidado: está acotado.

| Qué | Estado |
|---|---|
| `medir-api.ps1` | **Hecho.** Mide las duraciones desde la API. |
| `vigilancia.ps1` | **Hecho hasta avisar.** Detecta, avisa, y no reanuda nada todavía. |
| Reanudación del subagente | **Sin escribir.** A propósito. |
| Prueba con subagente colgado | **Sin hacer.** |

### Por qué la reanudación no está escrita

Se podría escribir, pero sin probarla no hay forma de garantizar que no duplique trabajo,
y duplicar trabajo es justo lo que pidió evitar quien lo pidió. Escribirla sin probarla
sería entregar una garantía falsa.

El paso que falta, y su coste: lanzar un subagente real, dejarse colgar a propósito,
comprobar que al reanudarlo no repite ninguna llamada, y solo entonces escribirlo. **Gasta
recursos de verdad**: por eso espera a que lo pidan.

### Lo que ya está decidido y no hay que volver a discutir

- **La raíz solo se avisa; nunca se toca.** Tocar la sesión principal puede destruir todo
  el trabajo, y reanudarse a uno mismo es un bucle peligroso. Los subagentes sí se pueden
  tocar, porque perder uno cuesta poco: se relanza.
- **Permiso pendiente = no se toca, nunca.** Un subagente que espera permiso no está
  atascado: está esperando al usuario. Reanudarlo sería aprobar en su nombre.
- **Reanudar es en la MISMA sesión, nunca una nueva.** Así conserva el contexto y sabe qué
  hizo. El mensaje lleva la lista de lo ya ejecutado y le dice que compruebe antes de
  repetir.
- **La verificación es por `callID`**, que es único por diseño, más la huella
  herramienta+entrada. Si aparece una llamada nueva idéntica a otra ya completada, se
  **aborta la sesión y se avisa**.
- **`-SoloInformar` por defecto; `-Auto` es opt-in.**

### El umbral, con su medida

No hay umbral por herramienta: se probó y no sirve, porque un `edit` tarda 24 ms y su
máximo son 67 ms, así que cualquier umbral derivado marcaría cada edit normal. Lo que se
mide es el **silencio de la sesión**. Medido el 2026-10-11 sobre 2611 huecos entre acciones:

    p50 4 s    p90 30 s    p99 282 s    max 48.533 s

Solo **4 de 2611** superan los 2100 s (0,15 %) y son sesiones dejadas abiertas. Por eso el
umbral sigue en 2100: unas 7,5 veces el p99. Si la medición cambia, se cambia el valor y
se vuelve a anotar por qué.

## Lo que quedó pendiente

**Lo primero, porque bloquea lo demás**
1. **Regla de interrupción** — seguir con la tarea previa cuando el usuario interrumpe,
   salvo que lo pida o que seguir sea contraproducente. **Pendiente de escribir** en
   `directrices/AGENTS.md` y `plantilla/AGENTS.md`.
2. **Principio ampliado** — ningún paso se cierra solo en la conversación; su resultado
   tiene que estar en el repo. Pendiente de escribir.

**Independientes**
3. **Elegir licencia.** El repositorio es público desde el 2026-10-11 y **no tiene
   `LICENSE`**, así que está en «todos los derechos reservados» por defecto: se puede leer
   y clonar, pero no reutilizar ni modificar. Es una decisión de quien lo posee. Lo
   normal sería MIT o CC BY-SA.
4. **T13** — proyecto `divisor` con subagentes. Es la prueba que junta `modelos.ps1 -Elegir`
   (elegir antes de delegar) con el watchdog (vigilar durante). Sin ella, ninguna de las dos
   mitades tiene prueba real más allá del log.
5. **`tasks.md`** — T1 a T12 siguen marcadas pese a estar hechas. T13 es la única pendiente.
6. **`ESTADO.md` frente a `PROXIMA-SESION.md`** — ambos existen y funcionan. Falta decidir
   cuál manda. `ESTADO.md` se creó por criterio propio.
7. **Acceso remoto** — investigado y documentado, **cero instalado** (ni Tailscale ni
   RustDesk).

## Preguntas que el usuario tiene pendientes de contestar

Estaban solo en la conversación, que es justo lo que no debe pasar. Se escriben aquí el
2026-10-11 para que sobrevivan a que se cierre la sesión.

**Sobre el contexto**
1. ¿Hay que fijar una regla de «compactar o sesión nueva antes de X»? Si la hay, **¿qué
   límite te resulta cómodo?** No se inventa. Hay datos para derivarlo: esta sesión
   compactó en el mensaje 818 y en el 1378.
2. **¿Cada cuánto se reescribe el estado en disco?** Es la regla que aplica Gentle antes
   del reset de contexto y este repo aplica después.

**Sobre lo descubierto hoy**
3. El aviso de la codificación de consola va a `aprendido.md` (error de proceso) o a
   `directrices/DEPURACION.md` (herramienta de depuración)?
4. **¿Licencia?** El repositorio es público y no tiene ninguna, así que está en «todos los
   derechos reservados» por defecto. Si se toman ideas de un proyecto MIT, lo razonable es
   que el nuestro lo sea.

**Sobre Gentle / Engram**
5. **¿Adoptar Engram** (binario Go + SQLite vía MCP, no se controla) **o extraer las ideas
   y hacerlo aquí**? Recomendación propia: extraer.
6. ¿Leer el **código** del mecanismo de compactación de Engram? Lo que se sabe viene del
   README, no de la implementación.

**Sobre este repositorio**
7. `ESTADO.md` frente a `PROXIMA-SESION.md`: ¿cuál manda? Ya está en la lista de arriba.
8. `tasks.md`: T1 a T12 siguen marcadas pese a estar hechas.

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

Están desarrollados en `aprendido.md`, que ya va por 15 entradas. Los que más cuestan:

1. **Afirmar sin comprobar.** Cinco retractadas en una sesión. Directiva: si la comprobación
   no se ha ejecutado, no se afirma.
2. **`$S` y `$s` son la misma variable en PowerShell.** Un análisis se destruyó a sí mismo.
   Usar `$tabla` y `$fila`.
3. **Un objeto nuevo no hereda las propiedades del hashtable.** `Get-Sesiones` tenía los
   datos y no los copiaba; el contador daba cero sin error.
4. **`@(función)` no aplana lo que devuelve la función.** Devuelve un elemento que es el
   array entero. La asignación sí. Con `@()` la medición daba 1 sesión y 0 herramientas
   cuando había 59. **Asignar primero, envolver después.**
5. **Renombrar sin ver el contexto destruye código.** Un reemplazo por palabra suela renombró
   una propiedad de un hashtable, una abreviatura dentro de una cadena de formato y una
   variable dentro del nombre de otra. Se rompió en tres sitios a la vez.
6. **La sintaxis correcta no significa código correcto.** `[regexes]::Matches` compila
   perfectamente y no existe. El fallo aparece al ejecutar, no al leer.

## Antes de dar nada por bueno

```powershell
powershell -File verificar.ps1
powershell -File tests-verificar.ps1
```

El segundo no es opcional: son 15 casos, y varios son falsos positivos que el primero no
detecta. Si sale rojo, suele ser el recuento de ficheros: cada `.md` nuevo obliga a
actualizar `AGENTS.md`, `INDICE.md` y `PROXIMA-SESION.md` a la vez.
