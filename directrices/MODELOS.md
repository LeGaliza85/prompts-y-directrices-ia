# MODELOS

Qué modelos hay, de dónde sale cada cifra, y qué no se sabe.

**La cifra que decide no está aquí.** Este documento dice cómo se ha comportado cada
modelo hasta ahora. Si vas a usar uno, se comprueba **en ese momento**:
principio 10 de `CONSTITUTION.md`. Lo de aquí es historial, y el historial caduca.

## Estado en esta máquina (medido el 2026-10-11)

Fuente: `GET http://127.0.0.1:4096/api/model` del servidor de OpenCode, y sondas reales
con `modelos.ps1 -Comprobar`.

| Qué | Resultado |
|---|---|
| Modelos que anuncia el servidor | 38, todos del proveedor `opencode` |
| Modelos de `zai-coding-plan` | **0**. La credencial sigue conectada, pero no ofrece ninguno. |
| `opencode/space-bunny-free` | Responde. Sonda entre 1,6 s y 22 s según la carga del servidor. |
| `opencode/big-pickle` | Responde. |
| `zai-coding-plan/glm-5.3-highspeed` | **No responde.** Motivo del proveedor: «Insufficient balance or no resource package». Tardó 73 s en fallar. |

Dos cosas que cambian cómo se usa lo de abajo:

1. **El CLI ya no sirve para comprobar modelos.** `opencode run -m <modelo>` devuelve 403
   con un texto explícito: el nivel gratuito solo se puede usar desde dentro de la propia
   aplicación. `modelos.ps1` pregunta al servidor, que sí cuenta como «dentro».
2. **`-Todos` es impracticable en primer plano.** Las sondas van de 2,9 s a 73 s según
   el modelo. Los 14 del catálogo tardan más de diez minutos. Para una comprobación puntual
   sirve `-Comprobar` o `-Elegir`.

La tabla de más abajo es de la cuenta de origen y describe el historial de uso. Se conserva
como historial; no dice qué hay hoy en esta máquina.

## De dónde sale cada número

Ninguna cifra de este documento está elegida a ojo. Cada columna tiene su origen:

| Columna | Origen |
|---|---|
| Usos | Apariciones de `modelID=<modelo>` en `opencode.log`. Medido el 2026-10-10 sobre 28.496 líneas, 5.373.691 caracteres. |
| Errores | Líneas del mismo log con ese `modelID` y «no disponible / not available / unavailable». |
| Último error | Fecha de la más reciente de esas líneas. |
| Contexto / Salida | `~/.cache/opencode/models.json`, que viene de models.dev. **Es heredado**, no medido por mí: la caché es de terceros y puede estar desfasada. |

## Lo que NO se puede saber aquí

**La disponibilidad de ahora mismo.** Ninguna columna de arriba la da. Un modelo con 0
errores puede estar caído desde hace diez minutos, y uno con errores puede funcionar ya.
No hay forma de distinguirlo sin llamarlo, y llamarlo es gastar.

Por eso este documento no tiene columna de «funciona / no funciona». La tiene el
comprobador del momento de uso, que es donde se decide.

## Los 18 modelos

**Gratuitos** (proveedor `opencode`, «OpenCode Zen»)

| Modelo | Usos | Errores | Último error | Contexto | Salida |
|---|---|---|---|---|---|
| `space-bunny-free` | **1494** | **0** | — | 1.048.576 | 524.288 |
| `big-pickle` | **1058** | **0** | — | 200.000 | 32.000 |
| `step-5-preview-free` | 408 | **3** | **hoy 16:26** | 1.000.000 | 65.536 |
| `ling-3.0-flash-fin-free` | 12 | **6** | 2026-10-09 | 262.144 | 32.768 |
| `ling-3.1-flash-free` | 0 | 0 | — | 262.144 | 32.768 |
| `nemotron-3-ultra-free` | 0 | 0 | — | 1.000.000 | 128.000 |
| `nemotron-3.5-lightning-free` | 0 | 0 | — | 262.144 | 262.144 |
| `longcat-2.5-preview-free` | 0 | 0 | — | 1.000.000 | 131.072 |
| `mimo-v2.6-flash-free` | 2 | 0 | — | 200.000 | 32.000 |
| `muse-spark-1.3-contributor-free` | 2 | 0 | — | 1.048.576 | 131.072 |
| `exo-free` | 0 | 0 | — | 1.048.576 | 131.072 |

**De suscripción** (proveedor `zai-coding-plan`)

| Modelo | Usos | Errores | Último error | Contexto | Salida |
|---|---|---|---|---|---|
| `glm-4.7` | 8 | 0 | — | 204.800 | 131.072 |
| `glm-5-turbo` | 0 | 0 | — | 200.000 | 131.072 |
| `glm-5.2` | 12 | 0 | — | 1.000.000 | 131.072 |
| `glm-5.2-highspeed` | 0 | 0 | — | 1.000.000 | 131.072 |
| `glm-5.3` | 0 | 0 | — | 1.000.000 | 131.072 |
| `glm-5.3-flash` | 0 | 0 | — | 1.000.000 | 131.072 |
| `glm-5.3-highspeed` | 0 | 0 | — | 1.000.000 | 131.072 |

## Lo que se puede concluir, y lo que no

**Con evidencia:** `space-bunny-free` y `big-pickle` suman **2.552 usos sin un solo error
de disponibilidad**. Son los dos únicos modelos de los 18 con historial que lo sustente.

**Con evidencia en contra:** `step-5-preview-free` falló 3 veces hoy en 22 minutos
(16:04, 16:12, 16:26), todas con «Endpoint is unavailable». `ling-3.0-flash-fin-free`
falló 6 veces y la última fue el 9 de octubre. Ninguno de los dos se da por usable.

**Sin evidencia:** los 14 restantes tienen 0, 1 o 2 usos. **No se puede decir que
funcionen ni que fallen.** Un uso no es una prueba, y cero usos no es un problema: es
que nadie los ha pedido. Presentarlos como opciones sería inventar.

**Sobre los de suscripción:** sus límites, según la caché heredada, no superan a los
gratuitos. `glm-5.3-flash` anuncia 1.000.000 de contexto y `space-bunny-free` tiene más
(1.048.576) y es gratuito. No hay motivo medible para gastar cuota en ellos, aunque la
cuota no es el criterio: el criterio es que funcionen cuando se los llame.

## La cuota

`opencode stats` marca **$0.00** de coste total. Eso es la contabilidad de OpenCode, no el
plan de Z.AI. La cuota real **no se expone en ningún comando**, así que este documento no
sabe cuánto queda.

Lo que sí consta: 33 eventos de «Insufficient balance» en el log. Por días: 23 el 27 de
junio, 6 el 29 de junio, 4 el 9 de octubre. Es decir, el plan se agotó al menos tres veces.
No dice cuánto queda ahora.

## Cómo se usa esto

No se elige un modelo por lo que dice esta tabla. Se elige por lo que responde **al
llamarlo**:

1. Antes de lanzar un subagente, se comprueba que el modelo responde ahora.
2. Si no responde, se pasa al siguiente. No se espera y no se reintenta a ciegas.
3. `space-bunny-free` es el primero de la lista porque es el que más usos tiene sin
   fallos, no porque sea el mejor.

La comprobación en el momento de uso y la vigilancia durante el trabajo son dos cosas
distintas: la primera decide si se lanza, la segunda decide si se para. El watchdog hace
la segunda; su documentación está en `BLOQUEOS.md`.

## Lo que falta por medir

- **La latencia real** de cada modelo. Exige llamarlos, y no se ha hecho.
- **La disponibilidad de los 14 modelos sin uso.** Exige lo mismo.
- **La cuota restante.** No hay comando que la dé.

Ninguna de las tres se rellena con una estimación. Se rellena llamando.
