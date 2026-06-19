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

- **Sala A · Investigación** — la bóveda de notas atómicas enlazadas (`investigacion:<tema>`).
- **Sala B · Catálogo** — fichas de tus herramientas y activos (`activo:<cosa>`).
- **Sala C · Referencia** — normas y estándares externos (`norma:<marco>:<código>`).
- **Sala D · Aprendizaje** — lecciones para no repetir errores (`aprendizaje:<id>`).

Y en **2 planos**, unidos por una sola flecha **hacia arriba y de solo lectura**:

```text
PLANO GLOBAL · Centro de Mando Sabio   (solo lectura)
  ★ índice de índices · Sala C (Referencia) · Sala D (Aprendizaje)
                 ▲
                 │  el proyecto LEE el plano global (solo lectura, vía sabio-shared)
                 │
PLANO LOCAL · Proyecto   (aislado)
  Sala A (Investigación) · Sala B (Catálogo) · Sala D (captura local)
  /aprender → /promover  sube lo genérico ↑ al plano global
```

> Un proyecto **jamás** lee la carpeta de otro proyecto. Solo puede *consultar* el plano global
> (vía el MCP `sabio-shared`, de solo lectura). Eso es el **aislamiento**.

---

## Qué incluye este repo

Todo lo que es SABIO hoy, en versión genérica y reutilizable:

| Componente | Qué es |
|---|---|
| 🧰 **Kit de proyectos** | Crea un proyecto nuevo completo (carpetas, git aislado, bóveda y las 4 Salas), en perfil **básico** o **agéntico**. |
| 🏛 **Centro de Mando Sabio** | El molde del *hub* / plano global que sirve a todos tus proyectos. |
| 🔌 **MCP `sabio-shared`** | El puente de solo-lectura para que un proyecto consulte el plano global. |
| 🤖 **Autoaprendizaje** | El perfil agéntico de la Sala D: captura + validador de aprendizajes. |
| ⌨️ **Skills / comandos** | `/aprender`, `/promover`, `/memory-lint`, `/disenar`. |
| 🧠 **Agentes** | Curador de SABIO, curador de investigación, revisor de código, escritor de commits, de documentación y de seguridad. |
| 📚 **Guías** | Documentación visual "en cristiano" de cada componente ([`docs/`](docs/)). |

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
