# Constitución — Sistema de trabajo con IA

Constitución de este repositorio. Es la versión concreta de los 9 principios de
`directrices/CONSTITUTION.md`, adaptada a un proyecto que no tiene código de producción.

Los principios generales no se repiten aquí. Lo que sigue es lo que este proyecto añade o
concreta.

## 1. Este repositorio no tiene código de producción

No hay aplicación, no hay servidor, no hay base de datos. El producto son **instrucciones**.
Eso cambia qué significa "terminado": aquí una directiva está terminada cuando es
**aplicable sin interpretación**, no cuando hay un test que pase.

Consecuencia: no existe `MEMORY.md` en la raíz. Sus equivalentes son `aprendido.md`
(errores de proceso) y `BITACORA.md` (decisiones). Una memoria de sesión sin estado de
implementación no tiene nada que recordar.

## 2. Nada se escribe sin haberse propuesto y aprobado

Es el principio 9 aplicado con rigor máximo, porque aquí **todo** es texto: un error de
proceso en este repo contamina directamente todos los proyectos futuros que copien la
plantilla.

Excepción deliberada: los registros (`BITACORA.md`, `aprendido.md`, `historial/`, `curso/`).
Un registro que hay que aprobar antes de escribirse deja de ser un registro fiable.

## 3. Toda directiva se comprueba contra la versión instalada

Nada se copia de material externo sin verificarlo. Lo que no esté en
`APIS-VERIFICADAS.md` con su fecha es una suposición, y se marca como tal.

Esto ya ha evitado un fallo real: el material de origen usa una sintaxis de permisos
obsoleta que produce archivos que se cargan sin error pero no aplican ninguna restricción.

## 4. Los documentos se dividen para poder cargarse por separado

La instrucción no vive en un archivo único. Se divide en documentos que se cargan según la
tarea, usando el campo `instructions` de `opencode.json` y la referencia explícita en
`AGENTS.md`.

Razón: OpenCode **no** interpreta `@archivo.md` por sí solo. Sin decírselo, una referencia
en el texto no carga nada. Y sin división, un `AGENTS.md` que lo contenga todo degrada la
calidad de lo que el modelo recuerda.

## 5. Un error de proceso se registra, no solo se corrige

Corregir sin registrar deja el sistema igual de vulnerable. Cada error queda en
`aprendido.md` con su causa y la directiva que lo previene, y cada decisión en `BITACORA.md`
con su razonamiento y su alternativa descartada.

## 6. El revisor no corrige

`reviewer` y `tooling-advisor` tienen todos los permisos de escritura denegados, a propósito.
Quien no puede arreglar algo no tiene la tentación de ofrecer el arreglo, y su salida es una
decisión para ti en lugar de un cambio que nadie revisó.
