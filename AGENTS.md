# AGENTS.md — Prompts y directrices IA

Este repositorio es una **biblioteca de directrices** para trabajar con agentes de IA. No es
una aplicación: no hay código de producción, sino instrucciones, plantillas y registros.

## Antes de empezar: lee esto primero

**Lee `PROXIMA-SESION.md`.** Contiene el estado de la última sesión y lo que quedó pendiente.
Si no existe, este aviso sobra y puedes seguir por `INDICE.md`.

## Qué es cada cosa

| Carpeta | Qué hay |
|---|---|
| `directrices/` | La capa genérica: 20 documentos que gobiernan cómo se trabaja en cualquier proyecto |
| `plantilla/` | El esqueleto que se copia a cada proyecto nuevo. 33 archivos |
| `historial/` | Copia literal de las directrices de cada proyecto, con su ficha |
| `curso/` | Material de origen intacto y apuntes extraídos |
| `specs/000-*` | La spec de este propio repositorio |
| `.opencode/` | Los agentes y comandos disponibles aquí |

Empieza por `INDICE.md` para el mapa completo.

## Cómo se trabaja aquí

Las reglas están en `directrices/CONSTITUTION.md`: nueve principios. Los dos que más importan
en este repo:

**Nada se escribe sin haberse propuesto y aprobado.** Este repo no tiene código: todo su
contenido es texto, así que un error de proceso aquí contamina directamente todos los
proyectos futuros que copien la plantilla.

**Todo error de proceso se registra.** En `directrices/aprendido.md`, con su causa y la
directiva que lo previene. Ahora hay once entradas; casi todas se descubrieron construyendo
de verdad, no leyendo.

## Antes de dar cualquier documento por bueno

```powershell
powershell -File verificar.ps1
```

Recorre los 100 archivos buscando caracteres cirílicos o CJK colados, puntuación china y
palabras en inglés dentro de texto español. Puede fallar con falsos positivos si se toca un
documento sin haberlo leído primero: conviene leer lo que cambias.

## Para crear un proyecto nuevo

```powershell
.\nuevo-proyecto.ps1 -Nombre "mi-proyecto" -Tipo web -Stack "React, TypeScript" -Git
```

Tipos disponibles: `web`, `api`, `datos`, `cli`, `movil`, `infra`, `docs`, `todos`.
No inventa nada del proyecto: lo que solo sabe quien lo pide queda marcado y se lista.

## Lo que no debes hacer

- **No copies nada de material externo sin verificarlo.** El material de origen usa una
  sintaxis de permisos obsoleta que produce archivos que se cargan sin error y no aplican
  nada. El fallo es silencioso. Comprueba contra `directrices/APIS-VERIFICADAS.md`.
- **No repitas los errores de `aprendido.md`.** Ahí están las once entradas, con por qué pasaron.
- **No anadas un `MEMORY.md` en la raíz para "completar" la estructura.** Aquí no hay estado de
  implementación que recordar; `PROXIMA-SESION.md` y `aprendido.md` hacen esa función.
