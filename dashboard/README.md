# Dashboard de Flota — la salud de tus proyectos SABIO de un vistazo

Un panel HTML **modular, 100 % offline, sin servidor** que muestra el estado real de tus proyectos
(git, conocimiento SABIO, stack, despliegue, MCP, backups, seguridad) y **qué atender primero**.

**Multiplataforma:** el escáner es **Python** (Windows · macOS · Linux). En Windows hay además
lanzadores `.ps1`/`.cmd` por comodidad — son envolturas finas que llaman al mismo escáner Python (un
solo motor, sin lógica duplicada).

---

## Cómo funciona

1. El **escáner** (`escanear-flota.py`) recorre tu **Centro de Mando Sabio** y/o tu carpeta de
   **proyectos**, y escribe `estado-flota.json` + los datos del panel en `panel/datos/*.js`.
2. El **panel** (`panel/index.html`) carga esos datos con `<script src>` y funciona abriéndolo
   directamente en el navegador (`file://`). No necesita servidor ni conexión.

## Configurar (una sola vez)

Copia `flota.config.example.json` → `flota.config.json` y pon **tus** rutas:

```json
{ "centro": "C:\\Ruta\\A\\Tu Centro de Mando Sabio", "proyectos": "C:\\Ruta\\A\\Tus Proyectos" }
```

`flota.config.json` es **local** a tu máquina (está en `.gitignore`). En macOS/Linux usa rutas con `/`.

## Usar

| Sistema | Comando |
|---|---|
| Cualquiera | `python escanear-flota.py --abrir` |
| Windows (doble-clic) | `Abrir-Panel.cmd` |
| Windows (PowerShell) | `.\Escanear-Flota.ps1 -Abrir` |
| Rutas ad-hoc (sin config) | `python escanear-flota.py --centro "<hub>" --proyectos "<carpeta>" --abrir` |

Para **refrescar**, vuelve a ejecutar el escáner y recarga el panel.

## Qué mide (por proyecto) — solo metadatos, nunca el contenido de tus bóvedas

- **Git:** repo · remoto · rama · nº de commits · árbol sucio · **commits sin push** · último commit.
- **SABIO:** salud del **grafo del vault** (notas curadas, huérfanas, `[[rotos]]`); el conocimiento
  **federado** (Salas B/C/D) se cuenta aparte y separa **fichas de autoría** del **corpus importado**
  (una subcarpeta con ≥ 40 `.md`), para no inflar el conteo.
- **Stack:** lenguajes y paquetes (busca `package.json` / `requirements.txt` / `pyproject.toml`).
- **Despliegue:** marcadores Vercel (`.vercel`/`vercel.json`) o Supabase (`supabase/`).
- **Agentes / Skills:** los del proyecto (`.claude/`) y los globales de tu usuario (`~/.claude`).
- **Backup:** antigüedad de la copia más reciente en `03-Backups`.
- **MCP:** servidores declarados en el `.mcp.json` del proyecto.
- **Seguridad:** ¿hay `.gitignore`? ¿hay **secretos versionados** (`.env` reales, claves `.pem/.key`,
  `credentials.json`…)? — leyendo solo los **nombres** de `git ls-files`, **nunca** el contenido.

> **Aislamiento (Capa 1).** Todo lo anterior son **metadatos** de salud/configuración. El escáner
> **nunca** lee ni copia el contenido de las bóvedas ni mezcla conocimiento entre proyectos.

## Arquetipos y semáforo

No mide a todos por igual: clasifica cada proyecto en un **arquetipo** (`control` · `agéntico` ·
`tradicional` · `simple`) y aplica umbrales propios (una app con datos no se cuida como una estática).
El color de cada proyecto es su **peor señal** (🟢 en orden · 🟡 atención · 🔴 crítico). La cola
**"Prioridades · qué hacer ahora"** lista lo más urgente de toda la flota; cada alerta trae un botón
**"Copiar prompt"** para pegar en Claude Code y arreglar el problema.

## Archivos

```
dashboard/
├── escanear-flota.py            # el escáner (motor portable, multiplataforma)
├── Escanear-Flota.ps1           # envoltura Windows (llama al .py)
├── Abrir-Panel.cmd              # doble-clic en Windows (re-escanea y abre)
├── flota.config.example.json    # plantilla de config (cópiala a flota.config.json)
└── panel/                       # el panel: index.html · estilos/ · app/
```

Lo **generado** (`estado-flota.json`, `historial-flota.jsonl`, `panel/datos/`) no se versiona: se
regenera en cada escaneo.
