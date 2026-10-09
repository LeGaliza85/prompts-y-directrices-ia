# historial/ — Archivo de proyectos

Copia **literal** de las directrices que se usaron en cada proyecto, para poder recuperarlas.

## Cómo se archiva

Al terminar un proyecto —o en cualquier momento en que quieras dejar constancia— se copia su
carpeta aquí sin modificar nada:

```
historial/
└── <nombre-del-proyecto>/
    ├── FICHA.md          ← qué era, cuándo, qué se usó
    ├── AGENTS.md         ← copia literal
    ├── MEMORY.md         ← copia literal
    ├── EXPECT.md         ← copia literal
    ├── docs/
    │   └── constitution.md
    ├── .opencode/        ← agentes y comandos que usó
    └── .agents/skills/
```

**Copia literal, sin adaptar.** Si se modifica algo al archivar, deja de ser un registro y
pasa a ser una reinterpretación, y ya no sirve para recuperar lo que se usó de verdad.

## La ficha

Cada proyecto lleva una `FICHA.md`:

```markdown
# <Nombre del proyecto>

**Qué era.** <Una o dos frases.>
**Stack.** <Tecnologías y versiones.>
**Fechas.** <Inicio — fin, o "en curso".>
**Estado.** <terminado | en curso | abandonado — y por qué>

## Directrices usadas
- Capa genérica del sistema: <fecha o commit>
- Archivos modificados respecto a la plantilla: <lista>
- Constitución: <nº de principios y si se adaptaron>

## Agentes
- <Agentes que tenía, y para qué se usó cada uno>

## Herramientas
- <MCP, skills y comandos aprobados>
- <Herramientas propuestas y rechazadas, con el motivo>

## Specs
- <NNN-nombre — estado>

## Lo que se aprendió
- <Errores de proceso encontrados, para no repetirlos>
```

Las tres secciones que más valor tienen a largo plazo son **Herramientas** —qué se aprobó y
qué se rechazó, con su motivo—, **Agentes** —qué equipo se formó y funcionó— y **Lo que se
aprendió**. Con ellas, un proyecto nuevo parecido se arma sin repetir decisiones.

## Para qué sirve esto

- **Recuperar** una configuración que funcionó, cuando un proyecto nuevo se parece a uno
  antiguo.
- **Comparar** dos proyectos aunque la capa genérica haya cambiado entre medias.
- **Ver qué se rechazó**, y no volver a proponer lo mismo por el mismo motivo.
- **Aprender de los errores de proceso**, que es el principio 6.

## Cuándo se archiva

- Al terminar un proyecto.
- Al abandonarlo, que es cuando más se aprende.
- Cuando un cambio en la capa genérica haga que las directrices antiguas de ese proyecto
  dejen de tener equivalente.

## Estado

Vacío. Todavía no hay proyectos que archivar: el primero llega con el primer proyecto real
que se construya con este sistema.
