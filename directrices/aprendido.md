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
`permissions:` y `action`/`resource`/`effect`. En OpenCode 1.3.11 la sintaxis es
`permission:` con mapa `clave: valor`, y la acción para delegar es `task`, no `subagent`.

**Por qué.** El curso se grabó contra una versión anterior. Copiar los agentes tal cual
produce archivos que se cargan pero no aplican ninguna restricción: el fallo es
silencioso, no da error.

**Directiva que lo previene.** Nada de este repo se copia de material externo sin
verificarlo contra `directrices/APIS-VERIFICADAS.md`. Un ejemplo de material no verificado
se documenta como tal en esa tabla, con la fecha de la última comprobación.
