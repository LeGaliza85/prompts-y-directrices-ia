# BLOQUEOS.md — Cuando un subagente se queda parado

Un subagente que se atasca **no da error**. Simplemente deja de escribir en el log, y la
sesión principal sigue ocupada esperando su resultado. Si no se vigila, la sesión se queda
colgada y el trabajo no avanza.

Este documento explica cómo detectarlo y qué hacer, con el método ya construido en
`vigilar-agentes.ps1`.

## Qué pasa realmente

Medido sobre el log real (2026-10-10, opencode 1.4.0, modelo `space-bunny-free`, desde Zed).
Estos son los eventos de un subagente que se quedó atascado, de principio a fin:

```
09:03:03.467  loop
09:03:03.778  process
09:03:03.779  stream                       ← pide tokens al modelo
09:03:03.780  llm runtime selected
09:03:05.335  touching file                ← ÚLTIMO evento
09:06:05.928  cancel                       ← 3 minutos de silencio
09:06:05.933  ERROR ... error=Aborted
```

Y el que **sí funcionó** (el mismo día, mismo modelo):

```
neon-wizard: 11 iteraciones de loop, 4 minutos
```

## La causa

**No es el modelo, ni un límite de uso, ni un diálogo de permiso.** Los datos:

- **Cero tool calls.** El subagente abrió el stream contra el modelo y se paró antes de
  ejecutar nada. Nunca llegó a pedir una herramienta.
- **Un solo loop.** El sano hizo 11 iteraciones; el atascado, 1.
- **`error=Aborted` al cancelarlo**, no un `429` ni un rate limit. No hay ningún `429` en
  todo el log.

Lo que ocurre: **el stream contra el modelo no devuelve respuesta y se queda colgado.** No
llega a ejecutar nada, no pide permisos, no da error — simplemente espera. Por eso no se
detecta mirando la interfaz: no hay ningún diálogo abierto, solo silencio.

Mi hipótesis inicial fue que era un permiso de `external_directory` sin responder, porque el
subagente pedía acceso a un directorio fuera del proyecto. **Era falso**: el log muestra que
el permiso se concedía (el `evaluated` llegaba casi en el mismo milisegundo). Lo que quedaba
después era el stream estéril.

## Cómo se detecta: la señal es el silencio + no hacer nada

Un subagente sano puede estar pensando varios segundos sin escribir nada. Así que **el tiempo
solo no basta**. La condición que sí distingue (medida sobre los datos):

> **Está atascado si lleva N segundos en silencio Y no ha hecho nada: `tools = 0` y
> `loops <= 1`.**

Un subagente que piensa tiene varios loops. Un subagente atascado tiene uno y ningún trabajo.
Los datos de esta sesión:

| Subagente | Estado | loops | tools |
|---|---|---|---|
| `crisp-otter` | atascado | 1 | 0 |
| `misty-cactus` | atascado | 1 | 0 |
| `neon-wizard` | sano | 11 | — |
| `curious-star` | sano | 4 | — |

## El detector

```powershell
# Informe puntual
powershell -File vigilar-agentes.ps1

# Vigilancia continua, cancela solo al detectar un atasco
powershell -File vigilar-agentes.ps1 -Umbral 90 -CancelarSegundos 240

# Umbral más agresivo, para no esperar
powershell -File vigilar-agentes.ps1 -Umbral 45 -CancelarSegundos 120
```

- **`-Umbral`** (90 s): silencio a partir del cual avisa de que algo va lento.
- **`-CancelarSegundos`** (240 s): a partir del cual **cancela el subagente solo**, por la API
  del servidor. Con `0` no cancela, solo avisa.
- **`-UnaVez`**: informe y salida. Es lo que se usa desde otro proceso.

Cuando detecta un atasco crítico, cancela la sesión con `POST /session/<id>/abort` al servidor
local de opencode (verificado: devuelve 200). Si la API no está disponible, avisa para que
canceles con `ESC` en el editor.

### Por qué dos umbrales y no uno

Un umbral único tendría dos fallos opuestos: si es corto, cancela subagentes que solo estaban
pensando; si es largo, deja pasar atascos reales. Con dos, el de aviso es conservador y el de
cancelación es exigente: solo se cancela cuando hay silencio **y** cero actividad.

## Errores del propio detector, encontrados al construirlo

Merece la pena porque son los que cometería cualquiera que lo replique:

1. **El log no se puede leer con `Get-Content` ni `ReadAllLines`.** El propio opencode lo
   tiene abierto en exclusiva. Hay que abrirlo con `FileShare.ReadWrite`. Un vigilante que solo
   funciona con el log cerrado solo sirve cuando el agente ya está parado: justo cuando no
   sirve.

2. **Los timestamps son UTC; la hora local es UTC+2.** Comparar un `ToLocalTime()` contra
   `UtcNow` da un número negativo, y `[int]` de un negativo pequeño da **0**: el script
   informaba "hace ahora" de algo que llevaba media hora parado. **Comparar siempre UTC contra
   UTC.**

3. **La detección por permisos pendientes no funciona.** El log pone el `session.id` en la
   línea del `asking` pero **no** en la del `evaluated`, así que no se puede emparejar por
   sesión. Y además, como se vio, el permiso se concedía: no era la causa.

4. **Un subagente sano puede tener `tools = 0`.** Si un subagente solo razona y responde sin
   tocar ficheros, tiene cero tools. Por eso la condición es `tools = 0` **Y** `loops <= 1`, no
   solo cero tools.

## Nota sobre el modelo

`space-bunny-free` es un modelo gratuito y puede tener límites de uso que no se\loguean como
`429`. Si tras la primera_cancelación un subagente vuelve a atascarse, conviene comprobar si
hay límite de cuota del modelo. Pero en los datos de hoy, la causa fue el stream estéril, no
la cuota.

## Relación con el principio 7

El principio 7 dice que delegar no requiere autorización previa **si hay beneficio**. Este
documento cubre el otro lado: cuando delegar **no aporta** porque el subagente se atasca, el
agente principal debe poder hacerlo él mismo sin esperar. Delegar es una optimización, no un
compromiso: si el subagente lleva parado más de lo razonable, el primario retoma el trabajo.