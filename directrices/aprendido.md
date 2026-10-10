# aprendido.md — Errores de proceso y conocimiento acumulado

Errores **nuestros** al trabajar: ambigüedades, desviaciones, suposiciones que salieron
mal. Los errores de código de un proyecto concreto viven en su `MEMORY.md`.

Cada entrada: qué pasó · por qué · qué directiva lo previene.

---

## 2026-10-09 — Carácter corrupto al escribir un documento

**Qué pasó.** Al escribir `directrices/CONSTITUTION.md`, se coló un carácter cirílico
ilegible en mitad de una frase en español (un ideograma, U+6B1F). No apareció en el chat,
donde el documento se revisó y aprobó, sino al escribirlo en disco.

**Por qué.** La revisión se hizo sobre el texto mostrado en la conversación, que estaba
correcto. El fallo se introdujo en el momento de la escritura. Además, la consola de
PowerShell no muestra bien los acentos, así que una comprobación visual rápida no
servía para detectarlo.

**Cómo se detectó.** Barrido de caracteres no latinos sobre el archivo ya escrito:
`[\u0400-\u04FF\u4E00-\u9FFF\uFFFD]`. Salió una coincidencia.

**Directiva que lo previene.** Después de escribir un documento con texto no ASCII en
español, ejecutar el barrido de caracteres cirílicos/CJK antes de darlo por bueno:

```powershell
$l = Get-Content <archivo> -Encoding UTF8
if ($l | Select-String '[\u0400-\u04FF\u4E00-\u9FFF\uFFFD]') { "REVISAR" } else { "OK" }
```

No confiar en la vista de la consola: `PowerShell` en `cp1252` muestra `ñ` como `?`. La
comprobación válida es sobre los códigos de carácter, no sobre lo que se ve.

**Alcance.** Aplica a todo archivo con acentos, sobre todo a los que van a leerse como
instrucciones por un modelo: un carácter corrupto en una instrucción es una instrucción
que el modelo no puede cumplir.

**Nota sobre el propio archivo.** Al redactar esta entrada se repitió el error: se coló
un carácter corrupto en la frase «acentos, [corrupto] los que». El barrido lo detectó.
Dos Lessons: (1) citar un carácter ilegible es escreverlo de verdad, así que se describe
con su nombre y su código en lugar de pegarlo; (2) un archivo que documenta errores
contiene ejemplos que disparan su propio detector, así que hay que distinguirlos de los
errores reales revisando la línea, no solo la alerta.

---

## 2026-10-09 — El material del curso usa sintaxis obsoleta de OpenCode

**Qué pasó.** Los cuatro agentes multiagente del curso están escritos con
`permissions:` y `action`/`resource`/`effect`. En OpenCode 1.4.0 la sintaxis es
`permission:` con mapa `clave: valor`, y la acción para delegar es `task`, no `subagent`.

**Por qué.** El curso se grabó contra una versión anterior. Copiar los agentes tal cual
produce archivos que se cargan pero no aplican ninguna restricción: el fallo es
silencioso, no da error.

**Directiva que lo previene.** Nada de este repo se copia de material externo sin
verificarlo contra `directrices/APIS-VERIFICADAS.md`. Un ejemplo de material no verificado
se documenta como tal en esa tabla, con la fecha de la última comprobación.
---

## 2026-10-09 — Manipular caracteres de un archivo escrito con WriteAllLines corrompe los acentos

**Que paso.** Para corregir dos filas de una tabla en un archivo UTF-8, se leyeron las
lineas con ReadAllLines, se reasigno por indice y se escribieron con WriteAllLines. Las dos
lineas salieron sin tildes y con el contenido roto. Un intento posterior de insertar los
acentos caracter a caracter produjo basura ilegible.

**Por que.** WriteAllLines con un encoding sin BOM escribe UTF-8, pero el problema real fue
otro: la edicion por indice de lineas ya escritas no es una operacion segura cuando el texto
tiene acentos y la herramienta intermedia los reinterpreta. La segunda causa es mas
simple: se construyeron cadenas concatenando caracteres por codigo Unicode y la expresion
salió mal.

**Directiva que lo previene.** No se editan lineas sueltas de un archivo de texto con
manipulacion de arrays de caracteres, ni se insertan acentos por codigo Unicode.

1. Cambios pequenos y localizados: herramienta de edicion con old/new string.
2. Cambios de estructura un bloque grande: reescritura completa del archivo con la
   herramienta de escritura.
3. Para verificar que quedo bien: leer el archivo con la herramienta de lectura y comprobar
   que los acentos son correctos, no solo que no haya caracteres corruptos.

El patrón que funciona: editar con la herramienta de archivos, nunca con el intérprete de
PowerShell. El mismo script que verifica caracteres no detecta acentos perdidos, asi que la
comprobacion visual sigue siendo necesaria.

---

## 2026-10-10 — `module.exports` no funciona en el navegador: lógica compartida

**Qué pasó.** Un proyecto con lógica pura compartida entre `node --test` y la página exportaba
con `module.exports`. Los tests pasaban. Al abrir la página en el navegador daba
`ReferenceError: module is not defined`.

**Por qué.** La constitución del proyecto prohibía `type="module"` y `fetch`, que son las dos
vías normales de compartir código sin compilación. Sin ellas, el archivo se carga con
`<script src>` y `module` no existe en el navegador.

Lo peligroso: **los tests seguían verdes**. El fallo solo aparecía al abrir la página. Una
comprobación que pasa y otra que no se ha hecho parecen "todo bien".

**Directiva que lo previene.** Para compartir lógica entre Node y navegador sin compilación,
patrón de exportación doble:

```js
(function (raiz) {
  const api = { /* ... */ };
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = api;      // Node
  } else {
    raiz.MiApi = api;          // Navegador
  }
})(typeof globalThis !== 'undefined' ? globalThis : this);
```

Y es una **trampa conocida** del proyecto, no un detalle: si alguien cambia la exportación, los
tests siguen pasando y la página se rompe en silencio. Va en la sección de trampas del
`AGENTS.md` del proyecto.

**Alcance general.** Verificar en navegador no es opcional cuando hay lógica compartida. Los
tests verdes no implican que la página funcione.

---

## 2026-10-10 — Un test puede sobreespecificar y estar equivocado

**Qué pasó.** El test exigía que un dato corrupto descartara **todo** el objeto guardado. El
código recuperaba solo el campo válido y descartaba el corrupto. El test fallaba.

**Quién tenía razón.** El código. La constitución del proyecto decía que los datos del usuario
son sagrados, y perder un nombre válido porque el contador estuviera corrupto tira información
que estaba bien.

**Directiva que lo previene.** Cuando un test falla, lo primero no es arreglar el código: es
preguntarse **cuál de los dos codifica la intención correcta**. Un test escrito con prisa
puede fijar un comportamiento más estricto de lo que la especificación pide.

Si el test estaba mal, se corrige el test y se deja escrito el porqué en un comentario, para
que la próxima vez no se "corrija" otra vez en la dirección equivocada.

---

## 2026-10-10 — Verificar la interfaz en un navegador real, sin MCP ni dependencias

**Qué pasó.** Para comprobar una web hacían falta 14 verificaciones de interfaz: flujo,
persistencia, corrupción de datos, vista móvil y consola sin errores. Hacerlas a mano es lento
y no se repite igual.

Se intentó el MCP de `chrome-devtools`. **No se pudo usar**: activarlo exige conectarlo a la
sesión y reiniciar, y desde dentro de una sesión ya abierta no hay forma.

**La solución que funcionó.** Chrome en modo headless con el puerto de depuración remoto, y un
script de Node que habla el protocolo CDP por `WebSocket` —que Node trae de serie desde la 22.
Cero dependencias en el proyecto:

```powershell
chrome.exe --headless=new --remote-debugging-port=9222 --user-data-dir=<perfil temporal>
```

El detalle que costó: **el `sessionId` va en el mensaje CDP, no dentro de `params`**. Si se
manda como parámetro, el servidor responde `"Runtime.enable" wasn't found`, que parece un error
de nombre de método y no lo es.

**Qué comprobó.** 14 puntos, incluidos dos que un test unitario no puede ver: que un
`localStorage` con JSON roto arranca en estado inicial sin error en consola, y que nada
desborda a 375 px medido (`scrollWidth - clientWidth`). Más una captura, que es la única forma
de comprobar que algo **se ve** bien y no solo que cuadra.

**Directiva que lo previene.** Para verificar interfaz, el MCP es la vía cómoda pero no está
disponible dentro de una sesión abierta. El CDP directo da el mismo resultado y no depende de
configurar nada. El patrón queda en `historial/` como referencia.

---

## 2026-10-10 — El script de arranque lista marcadores que ya no aplican

**Qué pasó.** `nuevo-proyecto.ps1` terminó su informe listando `<idea>` y `<requisito>` como
pendientes de rellenar. No lo eran: son palabras de la tabla de comandos del `LEEME.md`.

**Por qué.** El listado usa una lista blanca de archivos editables, y dentro de esos busca
cualquier cosa con forma de marcador. La tabla de comandos del LEEME contiene `<idea>` y
`<requisito>` como texto explicativo, no como huecos.

**Directiva que lo previene.** El mismo riesgo que ya se registró: *un informe que lista
pendientes que no lo son acaba ignorándose entero*. Si se amplía la lista blanca, se comprueba
el resultado con un proyecto real, no con la plantilla en seco.

---

## 2026-10-09 — Delegar en paralelo acelera, pero hay que revisar el resultado

**Qué pasó.** Tres subagentes escribieron tres documentos independientes en paralelo y los
tres pasaron el verificador de caracteres. La revisión posterior encontró dos errores que el
script no detecta:

1. `CAPACIDADES.md`: el bloque de ejemplo de `opencode.jsonc` tenía Chrome DevTools
   **activo** y los demás comentados. El documento proclama que nada se precarga por el
   principio 1, y su propio ejemplo lo incumplía.
2. `AGENTES.md`: la tabla que distingue los dos archivos puso la **misma ruta** en las dos
   filas —la confusión de nombres que existe el documento entero para prevenir.

**Por qué.** El script comprueba caracteres y palabras en inglés. No comprueba lógica,
coherencia interna ni si un ejemplo contradice la regla que lo rodea.

**Directiva que lo previene.** Un subagente acelera la producción; no sustituye la revisión.
Después de recibir un documento de un subagente, se comprueba al menos:

- Que el ejemplo cumple la regla que ilustra, no que la contradice.
- Que las tablas de conceptos no repitan valores que deberían distinguirse.
- Que lo que afirma de otros archivos coincida con lo que esos archivos dicen.

Y el beneficio sigue siendo real: tres documentos independientes en paralelo frente a tres
secuenciales. El error no fue delegar, fue no revisar lo delegado.

---

## 2026-10-09 — PowerShell 5.1 lee los `.ps1` como ANSI si no llevan BOM

**Qué pasó.** El script `nuevo-proyecto.ps1` tenía un patrón con caracteres acentuados
(`ÁÉÍÓÚÑ`) en una expresión regular. Al ejecutarlo, el parser falló con errores de sintaxis
en esa misma línea.

**Por qué.** PowerShell 5.1 interpreta un `.ps1` como ANSI (cp1252) salvo que el archivo
empiece por un BOM UTF-8. Sin BOM, cada carácter acentuado se convierte en basura y la
expresión regular deja de ser válida.

**Directiva que lo previene.** Todo `.ps1` con texto no ASCII debe escribirse con BOM:

```powershell
[System.IO.File]::WriteAllText($ruta, $texto, (New-Object System.Text.UTF8Encoding $true))
```

Alternativa si no se puede controlar el encoding: escribir los caracteres acentuados como
escapes `\uXXXX` dentro del patrón, para que la fuente sea ASCII puro. Es más feo pero
inmune al encoding.

**Alcance.** Afecta a cualquier script que se vaya a ejecutar con `powershell -File`, no a
scripts embebidos en una sesión.

---

## 2026-10-09 — Un marcador con tilde no lo sustituye un patrón ASCII

**Qué pasó.** `nuevo-proyecto.ps1` debía reemplazar `<TECNOLOGÍAS Y VERSIONES CLAVE>`, pero
la clave usada en el script era `<TECNOLOGIAS...>` sin tilde. La sustitución no ocurrió y **no
dio error**: el marcador se quedó en el archivo generado.

Peor: el listado de marcadores pendientes tampoco lo detectó, porque su patrón
`<[A-Z][A-Z0-9_ \-]*>` solo acepta ASCII, así que un marcador con `Í` dentro no encajaba y no
se listaba. Dos filtros que fallaban en silencio, uno detrás del otro.

**Por qué.** El marcador con tilde es correcto en español, pero un patrón pensado para ASCII
no lo ve. Y un fallo silencioso en dos puntos seguidos parece que no hay fallo.

**Directiva que lo previene.**

1. Los patrones que recorran texto en español incluyen los acentos:
   `<[A-ZÁÉÍÓÚÑa-z][^<>]{0,60}>`, o mejor, `[^<>]` a secas cuando no hace falta restringir.
2. Cuando una sustitución no se aplica, se comprueba el resultado, no la ausencia de error.
   `-replace` no falla si no encuentra nada: devuelve el texto tal cual.
3. Los marcadores pendientes se listan con un patrón que no pueda excluir por encoding.

---

## 2026-10-09 — El informe de pendientes debe ser corto o se ignora

**Qué pasó.** La primera versión del listado de marcadores mostró 55 entradas. La mayoría no
eran para rellenar: eran ejemplos de formato dentro de la skill, la spec de ejemplo y el
bloque de recomendación del asesor.

**Por qué.** El script buscaba marcadores en todos los archivos, incluidos los que los usan
como plantilla. Un listado donde 40 de 55 no aplican hace que nadie lo lea.

**Directiva que lo previene.** Lista blanca, no lista negra: se enumeran los archivos que la
persona tiene que editar y solo se buscan marcadores ahí. Añadir un archivo nuevo a la lista
blanca es una decisión; dejar que todos entren por defecto pone el ruido en el informe.

**Qué pasó.** Tres subagentes escribieron tres documentos independientes en paralelo y los
tres pasaron el verificador de caracteres. La revisión posterior encontró dos errores
reales que el script no detecta:

1. `CAPACIDADES.md`: el bloque de ejemplo de `opencode.jsonc` tenía Chrome Devtools
   **activo** y los demás comentados. El documento proclama que nada se precarga por el
   principio 1, y su propio ejemplo lo incumplía.
2. `AGENTES.md`: la tabla que distingue los dos archivos puso la **misma ruta** en las dos
   filas —la confusión de nombres que existe el documento entero para prevenir.

**Por qué.** El script comprueba caracteres y palabras en inglés. No comprueba lógica,
coherencia interna ni si un ejemplo contradice la regla que lo rodea.

**Directiva que lo previene.** Un subagente acelera la producción; no sustituye la revisión.
Después de recibir un documento de un subagente, se comprueba al menos:

- Que el ejemplo cumple la regla que ilustra, no que la contradice.
- Que las tablas de conceptos no repitan valores que deberían distinguirse.
- Que lo que afirma de otros archivos coincida con lo que esos archivos dicen.

Y el beneficio sigue siendo real: tres documentos independientes en paralelo frente a tres
secuenciales. El error no fue delegar, fue no revisar lo delegado.