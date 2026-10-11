# Plan 000 — Sistema de trabajo con IA

Plan de esta spec. Marca qué requisito cubre cada parte.

## Archivos

| Archivo | Qué contiene | Requisitos |
|---|---|---|
| `directrices/` (23 archivos) | Capa genérica: principios, instrucción, memoria, criterios, flujo, requisitos, catálogos, blindaje y registros | RF-1 a RF-8 |
| `plantilla/` (33 archivos) | Esqueleto copiable para un proyecto nuevo | RF-1 |
| `.opencode/agents/` | `reviewer` y `tooling-advisor`, con permisos de escritura denegados | RF-5, RF-6 |
| `verificar.ps1` | Comprobador de documentos | RF-8 |
| `curso/` | Material de origen intacto y apuntes extraídos | — |
| `historial/` | Formato de archivo por proyecto | RF-11 |
| `INDICE.md` | Mapa y estado | — |

## Decisiones técnicas

**Dividir la instrucción en documentos en lugar de un archivo único.** `AGENTS.md` manda, pero
el detalle vive en documentos que se cargan por tarea.
*Alternativa descartada:* un único archivo largo. Se descarta porque degrada lo que el modelo
recuerda al llenar la ventana de contexto, y porque un archivo que nadie lee entero se
convierte en uno que nadie mantiene.

**Copiar la plantilla a mano, sin script.** Hasta que haya varios proyectos, no hay evidencia
de que automaticarlo ahorre trabajo real.
*Alternativa descartada:* un script de scaffold. Se descarta por el principio 3: la solución
más simple que funcione. Se reevalúa en el cuarto proyecto.

**Verificar la sintaxis contra la documentación, no solo contra ejemplos.** Lo que no está en
`APIS-VERIFICADAS.md` es una suposición.
*Alternativa descartada:* fiarse de los ejemplos del material de origen. Se descarta porque ya
falló: la sintaxis de permisos del curso está obsoleta y el fallo es silencioso.

**`permission:` con mapa de claves en los agentes**, no `permissions:` con
`action`/`resource`/`effect`. Está verificado contra la versión instalada.
*Alternativa descartada:* la sintaxis del curso. Se descarta porque en la versión instalada el
archivo se carga pero no aplica las restricciones.

**Comprobar los documentos con un script antes de darlos por bueno.**
*Alternativa descartada:* revisión visual. Se descarta porque no detecta caracteres CJK ni
palabras en inglés coladas en un texto en español, y porque la consola de PowerShell no
muestra bien los acentos.

## Qué requisito cubre cada parte

| Requisito | Dónde se cumple |
|---|---|
| RF-1 | `plantilla/` completa |
| RF-2 | Flujo de aprobación, principio 9 |
| RF-3 | `BITACORA.md` |
| RF-4 | `aprendido.md` |
| RF-5 | `directrices/AGENTES.md` y agentes en `plantilla/` |
| RF-6 | `directrices/CAPACIDADES.md` y `tooling-advisor` |
| RF-7 | `PIN.md`, `APIS-VERIFICADAS.md`, `PROCEDIMIENTO-ACTUALIZACION.md` |
| RF-8 | `verificar.ps1` |
| RF-9 | `CAPACIDADES.md`, registro de rechazos |
| RF-10 | Convención `specs/NNN-nombre/`, en `SDD.md` |
| RF-11 | `historial/` |
| RF-12 | Principio 7, corregido en esta sesión |

## Qué no cubre este plan

Dos requisitos dependen de que exista un proyecto real. RF-11 no tiene nada que archivar
todavía, y RF-1 solo se demuestra cuando alguien copie la plantilla. Se marcarán como
cumplidos cuando ocurra, no antes.
