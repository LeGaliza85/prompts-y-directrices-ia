# BLOQUEOS.md — Subagentes atascados: antes y después

Un subagente que se atasca **no da error**. Deja de escribir en el log y la sesión principal
se queda esperando. Sin vigilancia, el trabajo no avanza y nadie sabe por qué.

Este documento está dividido en dos: **cómo funcionaba antes** de entender la causa, y **cómo
funciona después**.

---

# PARTE 1 — ANTES

## Qué pasaba

Se lanzaba un subagente para trabajar en otro directorio. A los pocos minutos devolvía
`Task cancelled` y no se sabía por qué.

## Cómo se intentaba diagnosticar

Mirando la interfaz y esperando más. Cuando el subagente no volvía, la únicas opciones eran
esperar o cancelar a mano. El trabajo se perdía.

## Por qué no se podía saber

| Se sospechaba | Si era cierto |
|---|---|
| El modelo se había congelado | Habría que cambiar de modelo |
| Faltaba de saldo o cuota | Habría que recargar |
| Un diálogo de permiso esperaba respuesta | Habría que pulsar ESC |
| Había un límite de uso por paralelizar | Habría que delegar menos |

Las cuatro eran **igualmente plausibles**, y ninguna se comprobaba. Se cancelaba por
descarte: se cancelaba y se probaba otra cosa.

## Consecuencia práctica

Un atasco de tres minutos costaba tres minutos. Uno de nueve minutos, nueve. Y no había
forma de diferenciar «el subagente está pensando» de «el subagente está muerto»: ambos se
veían igual desde fuera, que era no ver nada.

---

# PARTE 2 — DESPUÉS

## La causa, medida

Se leyó el log entero: 25.573 líneas, varias semanas, seis modelos. De ahí salen **cinco
causas distintas**, todas con su firma en el log.

### 1. Límite de uso del modelo
```
AI_APICallError: Rate limit exceeded. Please try again later.
```
8 veces, incluido `space-bunny-free`.

**Causa raíz: paralelizar.** Tres subagentes creados en el **mismo milisegundo** (01:157,
01:188, 01:214) produjeron rate limit **0,6 segundos después**.

### 2. Saldo del proveedor agotado
```
AI_APICallError: Insufficient balance or no resource package. Please recharge.
```
32 veces. No tiene arreglo desde el agente: hay que cambiar de modelo o recargar.

### 3. Modelo no disponible
```
AI_APICallError: Upstream request failed: Model is unavailable.
```
6 veces. Se resuelve cambiando de modelo.

### 4. Ventana de contexto excedida
```
Input token count (382306) exceeded
```
Ocurre cuando una sesión crece demasiado. Se resuelve con `/compact` o sesión nueva.

### 5. Stream estéril
**No deja error en absoluto.** El modelo abre el stream contra el proveedor y no devuelve
nada. Ni un `429`, ni un timeout, ni una tool call.

La secuencia completa de un subagente atascado así, del principio al final:
```
09:03:03.467  loop
09:03:03.779  stream                       ← pide tokens
09:03:05.335  touching file                ← último evento
09:06:05.928  cancel                       ← 3 minutos de silencio
09:06:05.933  ERROR error=Aborted
```
Y uno sano, el mismo día: **11 iteraciones de loop**, 4 minutos.

**Mi hipótesis inicial era falsa.** Creí que era un diálogo de permiso esperando, porque los
subagentes pedían acceso a un directorio fuera del proyecto. El log lo desmiente: el permiso
se concedía en el mismo milisegundo. Lo que quedaba era el stream estéril.

## Cómo se detecta: silencio + inactividad

El tiempo solo no sirve: un subagente sano puede pensar varios segundos sin escribir. La
condición que sí separa, medida sobre los datos:

> **Atascado = silencio prolongado Y `tools = 0` Y `loops <= 1`**

Un subagente que piensa tiene varios loops. El atascado tiene uno y ningún trabajo.

| Subagente | Estado | loops | tools |
|---|---|---|---|
| `crisp-otter` | atascado | 1 | 0 |
| `misty-cactus` | atascado | 1 | 0 |
| `quiet-moon` | sano | 2 | 0 |
| `neon-wizard` | sano | 11 | — |

## Qué hace el watchdog

`watchdog.ps1` vigila el log y actúa solo.

```powershell
# Informe puntual
powershell -File watchdog.ps1 -UnaVez

# Vigilancia continua, cancela al detectar
powershell -File watchdog.ps1 -Umbral 90 -CancelarSegundos 240

# Agresivo: no esperar
powershell -File watchdog.ps1 -Umbral 45 -CancelarSegundos 120
```

### Detecta las cinco causas

| En el log | Lo clasifica como | Qué hace |
|---|---|---|
| `Rate limit exceeded` | límite de uso | Avisa: menos subagentes en paralelo |
| `Insufficient balance` | sin saldo | Avisa: cambiar modelo o recargar |
| `Model is unavailable` | no disponible | Avisa: cambiar de modelo |
| `Input token count...exceeded` | contexto | Avisa: `/compact` o sesión nueva |
| Silencio + `loops<=1` + `tools=0` | stream estéril | **Cancela** el subagente |

### Cancela en caliente

`POST /session/<id>/abort` al servidor local de OpenCode. Verificado: devuelve 200. Un
comando de la CLI abriría una sesión nueva, que es justo lo que no se quiere mientras la otra
está colgada.

### No pierde información

**Solo cancela subagentes que no han hecho nada.** Si un subagente tiene tool calls, avisa
pero **no lo toca**: ahí hay trabajo que perder. Es la garantía más importante del script.

Cada cancelación o error se escribe en `watchdog-registro.md`, junto al log, con la causa y
qué hacer. Así el registro sobrevive a la sesión.

### Dos umbrales

Uno solo falla en las dos direcciones: si es corto, cancela subagentes que pensaban; si es
largo, deja pasar atascos reales. Con dos, el de aviso es conservador (90 s) y el de
cancelación es exigente (240 s) y además exige inactividad total.

## Verificación

```
[WATCHDOG] 09:52:50  aviso 120s  cancelar 240s
  ERROR    gentle-engine    El modelo ling-3.0-flash-fin-free no está disponible ahora mismo.
  ATASCO   crisp-otter      hace 2987s  loops=1 tools=0
```

`crisp-otter` con `loops=1` sale como atasco. `quiet-moon` con `loops=2` sale como `ok`. La
distinción funciona en los dos sentidos.

## Errores del propio watchdog

Documentados porque los repetiría cualquiera que lo replique:

1. **El log no se lee con `ReadAllLines`.** OpenCode lo tiene abierto en exclusiva; hay que
   usar `FileShare.ReadWrite`. Un vigilante que solo lee con el log cerrado solo sirve cuando
   el agente ya está parado: justo cuando no sirve.

2. **Los timestamps son UTC y la hora local es UTC+2.** Comparar `ToLocalTime()` contra
   `UtcNow` da negativo, y `[int]` de un negativo pequeño da **0**: informaba "hace ahora" de
   algo parado 40 minutos. **Comparar siempre UTC contra UTC.**

3. **El `session.id` no aparece en `stream error` ni en `evaluated`.** Solo en `loop`, `process`
   y `cancel`. Por eso los errores no se pueden atribuir a una sesión: se asignan a la
   subsesión más reciente. Es la razón de que un rate limit inicialmente pasara
   desapercibido.

4. **Un subagente sano puede tener `tools = 0`.** Si solo razona y responde sin tocar
   ficheros. Por eso la condición es `tools = 0` **Y** `loops <= 1`, no solo cero tools.

## Qué hacer cuando salta

| Dice | Qué hacer |
|---|---|
| Límite de uso | Delega menos a la vez. Espera un poco antes de relanzar. |
| Sin saldo | Cambia de modelo en `/models`. Recargar si es la única opción. |
| Modelo no disponible | Cambia de modelo. |
| Contexto excedido | `/compact`, o sesión nueva. |
| Stream estéril | El watchdog ya lo canceló. Relanza o hazlo tú. |

## Relación con el principio 7

El principio 7 dice que delegar no requiere autorización previa **si hay beneficio**. Este
documento cubre el otro lado: **si el subagente se atasca, el agente principal retoma el
trabajo sin esperar.** Delegar es una optimización, no un compromiso.

Y con la causa 1 añadida, la regla práctica es: **no más de dos subagentes a la vez con
modelos gratuitos.** Tres en paralelo reproducen el rate limit en menos de un segundo.
