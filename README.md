# SABIO Blackdestiny

<p align="center">
  <img src="docs/media/sabio-infografia.png" alt="SABIO — La memoria a largo plazo para trabajar con IA" width="860">
</p>

> **La memoria a largo plazo para trabajar con IA — sin base de datos vectorial, sin RAG.**
> Un sistema de archivos de texto, bóvedas-wiki e índices que tu asistente (Claude Code) lee
> directamente. Ordenado, federado y aislado por proyecto.

> 🌎 **English, in one line:** *SABIO is a no-RAG long-term memory system for working with AI
> coding assistants — plain Markdown vaults, four federated "rooms" of knowledge, and a
> Claude-Code-driven installer. Everything below is in Spanish; the install guide
> ([`INSTALAR.md`](INSTALAR.md)) is run by Claude Code itself.*

**SABIO** = **S**istema de **A**rchivos, **B**óvedas e **Í**ndices **O**rganizados.

---

## En una frase

SABIO es un sitio ordenado donde **cada cosa que investigas o decides queda guardada una sola vez**,
etiquetada, y se puede volver a encontrar — sin que un proyecto se contamine con los datos de otro,
y sin que la IA tenga que "recordar" nada entre sesiones: lo lee de los archivos.

## El problema que resuelve

La IA tiene **dos olvidos y un desorden**. SABIO ataca los tres:

| Problema | Qué pasa | Quién lo cura en SABIO |
|---|---|---|
| **Olvido en el chat** | En conversaciones largas, la IA olvida lo de arriba (la ventana se satura). | La **gestión de contexto** (Capa 1). |
| **Olvido entre sesiones** | Cierras el chat y mañana no recuerda lo decidido. | La **bóveda de conocimiento** (Capa 2). |
| **Desorden / mezcla** | Los datos de un proyecto se filtran en otro. | El **aislamiento** por proyecto. |

**La apuesta de diseño: sin RAG.** A volúmenes moderados (< 2.000 páginas) no hace falta una base
de datos vectorial: basta una wiki en texto que la IA lee directamente. Más simple y más barato.
Es el patrón "LLM Wiki" de Andrej Karpathy.

---

## Cómo está organizado: 4 Salas y 2 planos

El conocimiento se federa en **4 Salas** (cada dato vive en UNA sola; las demás lo señalan por su ID):

- **Sala A · Investigación** — la bóveda de notas atómicas enlazadas (`investigacion:<tema>`). En el Centro de Mando es **multi-dominio**: un dominio nuevo se añade como una etiqueta + un mapa, **nunca** como una bóveda aparte.
- **Sala B · Catálogo** — fichas de tus herramientas y activos (`activo:<cosa>`).
- **Sala C · Referencia** — normas y estándares externos (`norma:<marco>:<código>`). Se **segmenta por ámbito** con una etiqueta: `universal` (marcos internacionales — NIST/ISO/PCI — para todos), `jurisdiccion:` (la legislación de aplicación general de un país) y `sector:` (la regulación de un rubro). Lo que sube al plano global es lo que **necesita más de un proyecto**, no "lo internacional"; cada proyecto declara su *perfil de aplicabilidad* y resuelve lo `universal` + lo suyo.
- **Sala D · Aprendizaje** — lecciones para no repetir errores (`aprendizaje:<id>`).

Y en **2 planos**, unidos por una sola flecha **hacia arriba y de solo lectura**:

```text
PLANO GLOBAL · Centro de Mando Sabio   (solo lectura)
  ★ índice de índices · Sala A (Investigación · multi-dominio) · Sala C (Referencia) · Sala D (Aprendizaje)
                 ▲
                 │  el proyecto LEE el plano global (solo lectura, vía sabio-shared)
                 │
PLANO LOCAL · Proyecto   (aislado)
  Sala A (Investigación) · Sala B (Catálogo) · Sala D (captura local)
  /sabio-aprender → /sabio-promover  sube lo genérico ↑ al plano global
```

> Un proyecto **jamás** lee la carpeta de otro proyecto. Solo puede *consultar* el plano global
> (vía el MCP `sabio-shared`, de solo lectura). Eso es el **aislamiento**.

---

## Qué incluye este repo

Todo lo que es SABIO hoy, en versión genérica y reutilizable:

| Componente | Qué es |
|---|---|
| 🧰 **Kit de proyectos** | Crea un proyecto nuevo completo (carpetas, git aislado, bóveda y las 4 Salas), en perfil **básico** o **agéntico**. |
| 🚀 **Despliegue end-to-end** | `/sabio-welcome <ruta>` crea el proyecto, lo **prueba** (estructura + canal del plano global, con un test determinista) y lo adopta en el dashboard — en un solo paso. Incluye el test `kit/Validar-Despliegue.ps1`. |
| 🏛 **Centro de Mando Sabio** | El molde del *hub* / plano global que sirve a todos tus proyectos. |
| 🔌 **MCP `sabio-shared`** | El puente de solo-lectura para que un proyecto consulte el plano global. |
| 🤖 **Autoaprendizaje** | El patrón **Reflector** (agente `sabio-reflector`): reflexiona con feedback externo e infiere la lección antes de guardarla. Más el perfil agéntico de la Sala D: captura + validador. |
| ⌨️ **Skills / comandos** | `/sabio-aprender`, `/sabio-reflector`, `/sabio-promover`, `/sabio-promover-buzon`, `/memory-lint`, `/disenar`, `/sabio-welcome`. |
| 📮 **Buzón de promoción** | `/sabio-promover-buzon` (desde el Centro): descubre **automáticamente** los paquetes que los proyectos dejan listos en su buzón y materializa el que elijas — automatiza el *transporte* del volante, sin copia-pega. Tú decides qué sube (el *gate*); el escaneo solo lo trae. Lee solo el buzón de cada proyecto, nunca su bóveda. |
| 🧠 **Agentes** | Curador de SABIO, reflector de auto-mejora, curador de investigación, revisor de código, escritor de commits, de documentación y de seguridad. |
| 📊 **Dashboard de flota** | Panel **offline** (Python + HTML) que muestra la salud de tus proyectos (git, SABIO, backups, seguridad) y qué atender primero ([`dashboard/`](dashboard/)). |
| 📚 **Guías** | Documentación visual "en cristiano" de cada componente ([`docs/`](docs/)). |

---

## Estructura del repositorio

Cada archivo, con su rol. Lo **generado** (entornos `.venv/`, `flota.config.json`, `estado-flota.json`,
`panel/datos/`) no se versiona: se crea en tu máquina al instalar/escanear.

```text
sabio-blackdestiny/
├── README.md                         # este archivo: qué es SABIO y qué incluye
├── INSTALAR.md                       # guía de instalación que Claude Code ejecuta (4 pasos)
├── LICENSE                           # licencia MIT
├── .gitignore                        # ignora venvs, config local y datos generados
│
├── kit/                              # 🧰 crea proyectos nuevos completos (Capa 1 + Capa 2)
│   ├── Crear-Proyecto.ps1            #   despliega un proyecto entero en un paso (idempotente)
│   ├── Actualizar-Proyecto.ps1       #   propaga el estándar a proyectos ya existentes (ADD-ONLY)
│   ├── Validar-Despliegue.ps1        #   🚀 TEST del despliegue: estructura + aislamiento + canal global
│   ├── LEEME - Crear un proyecto nuevo.md
│   ├── Chuleta de Prompts - Investigacion e Ingesta.md   # prompts para poblar la bóveda
│   ├── _proyecto/CLAUDE.md           #   molde del CLAUDE.md del proyecto (árbol + reglas + federado)
│   ├── _plantilla/                   #   molde de la BÓVEDA (Sala A): CLAUDE.md, index.md, log.md, templates/, raw/, wiki/
│   └── _federado/                    #   molde del CEREBRO FEDERADO: índice + Salas B/C/D + Sala D unificada (ESQUEMA + validador, estándar en todos)
│
├── centro-de-mando-sabio/            # 🏛 molde del hub / plano global (móntalo una vez)
│   ├── CLAUDE.md                     #   el rol del hub
│   └── LEEME - Montar tu Centro de Mando Sabio.md
│
├── mcp/                              # 🔌 el puente de solo-lectura al plano global
│   ├── server.py                     #   servidor MCP sabio-shared (stdio, read-only, 4 herramientas)
│   ├── requirements.txt              #   dependencias: mcp + pydantic
│   └── README.md                     #   qué expone, seguridad y cómo registrarlo en un proyecto
│
├── dashboard/                        # 📊 panel offline de salud de la flota (multiplataforma)
│   ├── escanear-flota.py             #   el escáner (motor portable; Windows · macOS · Linux)
│   ├── Escanear-Flota.ps1            #   envoltura Windows (llama al .py)
│   ├── Abrir-Panel.cmd               #   doble-clic en Windows (re-escanea y abre el panel)
│   ├── flota.config.example.json     #   plantilla de config (cópiala a flota.config.json, local)
│   ├── README.md                     #   cómo configurarlo, qué mide y los arquetipos/semáforo
│   └── panel/                        #   el panel: index.html · estilos/ (tokens.css, panel.css) · app/ (5 módulos JS)
│
├── entorno-claude/                   # ⌨️🤖 tu entorno de Claude Code (se instala en ~/.claude)
│   ├── Aplicar-Setup.ps1             #   copia el entorno a ~/.claude (con respaldo)
│   ├── Sincronizar-Setup.ps1         #   vuelca tu ~/.claude de regreso al repo (para versionarlo)
│   ├── README.md                     #   qué hace cada pieza del entorno
│   └── home-claude/                  #   el contenido que va a ~/.claude:
│       ├── CLAUDE.md                 #     preferencias transversales (plantilla genérica)
│       ├── settings.json             #     ajustes + hooks de sesión
│       ├── commands/                 #     skills: sabio-aprender · sabio-reflector · sabio-promover · sabio-promover-buzon · memory-lint · disenar · sabio-welcome
│       ├── agents/                   #     7 agentes: sabio-curator · sabio-reflector · research-curator · code-reviewer · commit-writer · doc-writer · security-engineer
│       └── scripts/                  #     hooks: recordatorio al iniciar sesión · captura al compactar
│
└── docs/                             # 📚 guías "en cristiano"
    ├── guia-sabio.md                 #   qué es SABIO y cómo se usa, sin jerga
    ├── resumen-consolidado.md        #   visión integral en una pasada
    └── media/sabio-infografia.png    #   infografía de portada
```

---

## Instalación

SABIO se instala **conduciendo a Claude Code** — funciona en **Windows, macOS y Linux** porque
es Claude quien ejecuta los pasos adaptándose a tu sistema.

```text
1. Clona este repo.
2. Abre Claude Code en la carpeta del repo.
3. Dile:  «Instala SABIO siguiendo INSTALAR.md»
```

👉 Guía completa, paso a paso: **[`INSTALAR.md`](INSTALAR.md)**

---

## Filosofía

- **Sin RAG.** Texto plano que la IA lee directo. Menos piezas, menos coste, más control.
- **Un dato, un solo hogar.** Nada se copia; se referencia por ID. Cero duplicados, cero *drift*.
- **Aislado por defecto.** Cada proyecto en su caja; una sola puerta al conocimiento común.
- **Proporción.** Lo más pequeño que resuelve el problema. El perfil agéntico solo se enciende
  cuando un proyecto de verdad ejecuta agentes en bucle.

---

## Licencia y crédito

**SABIO Blackdestiny** — creado por **Blackdestiny**. Publicado bajo licencia **MIT**
(ver [`LICENSE`](LICENSE)): úsalo, adáptalo y compártelo libremente, manteniendo la atribución.
