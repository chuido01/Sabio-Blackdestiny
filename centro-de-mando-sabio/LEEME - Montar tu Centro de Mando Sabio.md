# Montar tu Centro de Mando Sabio (el plano global)

> El Centro de Mando Sabio es **una carpeta normal** que actúa como tu *hub*: guarda el conocimiento
> compartido por todos tus proyectos y aloja el MCP que se lo sirve en solo-lectura. Móntalo **una vez**.

## Qué tendrá dentro

```
Centro de Mando Sabio/
├── CLAUDE.md            ← el rol del hub (copia la plantilla de esta carpeta)
├── mcp/                 ← el servidor sabio-shared (copia la carpeta mcp/ del repo) + su .venv
└── 04-Recursos/         ← el PLANO GLOBAL (las 4 Salas), creado con los moldes del Kit
    ├── 00-INDICE-DE-INDICES.md
    ├── 01-Boveda/<TuBovedaGlobal>/   ← Sala A · investigación compartida
    ├── 02-Catalogo/                          ← Sala B
    ├── 03-Referencia/                        ← Sala C 🌐 (normas/estándares)
    └── 04-Aprendizaje/                       ← Sala D 🌐 (lecciones transversales promovidas)
```

## Cómo montarlo (lo más fácil: que lo haga Claude)

Abre Claude Code en la carpeta del repo y pídele:

```
Monta mi Centro de Mando Sabio en la ruta <RUTA>. Haz esto:
1) Crea la carpeta <RUTA> y copia ahí centro-de-mando-sabio/CLAUDE.md como CLAUDE.md.
2) Copia la carpeta mcp/ del repo a <RUTA>/mcp/ y crea su entorno: python -m venv <RUTA>/mcp/.venv
   y pip install -r requirements.txt dentro de ese venv.
3) Crea <RUTA>/04-Recursos/ con los moldes del Kit: copia kit/_federado/ (índice de índices + Salas
   B/C/D) y crea una bóveda global en 04-Recursos/01-Boveda/<TuBovedaGlobal>/ con kit/_plantilla/.
   Sustituye <NombreProyecto> por "Centro de Mando Sabio", <NombreBoveda> y <fecha>.
4) Confírmame el árbol creado y que el MCP arranca (python <RUTA>/mcp/server.py debe loguear la raíz).
```

## Cómo lo usan tus proyectos

- Al crear un proyecto con el Kit, pásale `-CentroDeMando "<RUTA>"`: el `.mcp.json` del proyecto
  quedará apuntando a `<RUTA>/mcp/server.py` con `SABIO_GLOBAL_ROOT=<RUTA>`.
- Desde un proyecto, el plano global es **solo-lectura** (las 4 herramientas `sabio_*`). La **escritura**
  del plano global ocurre **solo aquí**, en el Centro de Mando, normalmente vía `/sabio-promover`.

## Reglas que NO se rompen
- El Centro de Mando **escribe hacia fuera solo para desplegar el Kit**; nunca lee ni importa el
  conocimiento de un proyecto.
- Los proyectos **leen** el plano global pero **jamás** se leen entre sí. Ese es el aislamiento.
