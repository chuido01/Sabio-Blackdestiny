# Kit de Proyecto Nuevo — Capa 1 + Capa 2 en un solo paso

> Este kit crea un **proyecto completo** con el estándar SABIO: estructura de carpetas,
> repositorio git aislado (Capa 1), `CLAUDE.md` con sus reglas, y la **bóveda Obsidian de
> Capa 2** (el wiki LLM / segundo cerebro) ya instalada dentro de `04-Recursos/`.
> **Un solo paso lo hace todo** — ya no hay pasos manuales que se puedan olvidar.

---

## 📁 La estructura estándar que crea

```
<Mi Proyecto>/
├── 00-Documentacion/      Documentación oficial, técnica, ejecutiva, tests, diagramas…
├── 01-Produccion/         Código y/o proyecto en producción.
├── 02-Desarrollo/         Código que se está modificando.
├── 03-Backups/            Respaldos fechados (DDMMAAAA).
├── 04-Recursos/           El CEREBRO FEDERADO del proyecto (4 salas de conocimiento):
│   ├── 00-INDICE-DE-INDICES.md   ← el espinazo: qué prefijo de ID vive en qué sala
│   ├── 01-Vault Obsidian/
│   │   └── <NombreBoveda>/   ← Sala A · Investigación (el wiki de notas atómicas)
│   ├── 02-Catalogo/          ← Sala B · Catálogo (fichas de activos)
│   ├── 03-Referencia/        ← Sala C · Referencia externa (estándares oficiales)
│   └── 04-Aprendizaje/       ← Sala D · Aprendizaje operativo
├── CLAUDE.md              La ficha del proyecto (árbol + regla de Obsidian + reglas federadas).
└── .gitignore
```

> **¿Por qué 4 salas?** «Conocimiento» no es una sola cosa: investigación curada, catálogo de
> activos, normas externas y aprendizajes tienen volúmenes y ritmos distintos. Cada sala nace con su
> **`LEEME - Esquema`** que explica para qué existe y su formato; se **federan por IDs** (no se copian
> datos entre ellas). *(Nomenclatura: «Capa 1/2» = arquitectura; «Sala A–D» = tipos de conocimiento.)*

---

## ✅ Método A (Windows): el script único

Desde la carpeta `kit/` del repo, en PowerShell:

```powershell
& ".\Crear-Proyecto.ps1" -ProyectoDestino "C:\Mis Proyectos\Mi App" -NombreBoveda "Memoria_MiApp" -CentroDeMando "C:\Centro de Mando Sabio"
```

- `-CentroDeMando` conecta el MCP `sabio-shared` (plano global). **Omítelo** si quieres un proyecto
  solo-local (sin plano global).
- `-PerfilSalaD agentico` si el proyecto va a ejecutar agentes en bucle (default: `base`).
- **Es seguro re-ejecutarlo**: nunca sobrescribe lo que ya está; solo completa lo que falte.

> **Si PowerShell bloquea el script** («la ejecución de scripts está deshabilitada»):
> ```powershell
> powershell -ExecutionPolicy Bypass -File ".\Crear-Proyecto.ps1" -ProyectoDestino "C:\Mis Proyectos\Mi App"
> ```

Último toque: abre el `CLAUDE.md` del proyecto y rellena los `<RELLENAR>` (nombre, paleta, tecnología),
o pídeselo a Claude: *«revisa el CLAUDE.md y pregúntame los datos que faltan»*.

---

## 🗣️ Método B (cualquier sistema): pídeselo a Claude Code

Útil en macOS/Linux o si prefieres no tocar PowerShell. Abre Claude Code en la carpeta del repo y pega:

```
Crea un PROYECTO NUEVO en la ruta <RUTA> usando el Kit de la carpeta kit/. COPIA los archivos
canónicos del Kit (no los reinventes). Haz EXACTAMENTE esto:

1) git init en <RUTA> (memoria aislada).
2) Crea: 00-Documentacion/ 01-Produccion/ 02-Desarrollo/ 03-Backups/ 04-Recursos/
3) Crea .gitignore con: node_modules/, .env, .env.*, dist/, build/, .claude/, .understand-anything/
4) COPIA kit/_proyecto/CLAUDE.md a la raíz como CLAUDE.md y sustituye <NombreProyecto>,
   <NombreBoveda> y <PerfilSalaD>; pregúntame los <RELLENAR>.
5) Crea 04-Recursos/01-Vault Obsidian/<NombreBoveda>/ y COPIA dentro TODO kit/_plantilla/
   (sustituye <NombreBoveda> y <fecha>).
6) COPIA a 04-Recursos/ el contenido de kit/_federado/ (índice de índices + Salas B/C/D),
   sustituyendo <NombreProyecto>, <NombreBoveda> y <fecha>.
7) Si el perfil es agentico, superpón kit/_perfiles/agentico/ sobre 04-Aprendizaje/.
8) Si tengo un Centro de Mando Sabio, crea .mcp.json con el MCP sabio-shared apuntando a
   <RUTA_CENTRO_DE_MANDO>/mcp/server.py y SABIO_GLOBAL_ROOT=<RUTA_CENTRO_DE_MANDO>.

Cuando termines, muéstrame el árbol creado y confírmame que el repo quedó aislado.
```

> Clave: el método B le pide a Claude **copiar** los archivos canónicos del Kit, **no** reinventarlos.

---

## 📚 Después de crear el proyecto

1. **Acceso nativo a la bóveda local:** no hay nada que conectar (sin MCP). Claude edita los `.md`
   directamente; la segmentación la dan el aislamiento del proyecto + la regla «Acceso a Obsidian».
2. **Poblar la bóveda:** usa la **`Chuleta de Prompts - Investigacion e Ingesta.md`** (incluida).
3. **Verificar en Obsidian (opcional):** abre la carpeta de la bóveda como vault para ver el grafo.

---

## 📦 Contenido del Kit

```
kit/
├── Crear-Proyecto.ps1                          (el script único: proyecto + bóveda)
├── Actualizar-Proyecto.ps1                     (propaga el estándar a proyectos existentes)
├── LEEME - Crear un proyecto nuevo.md          (este archivo)
├── Chuleta de Prompts - Investigacion e Ingesta.md
├── _proyecto/CLAUDE.md       (plantilla del CLAUDE.md del PROYECTO)
├── _plantilla/               (los archivos canónicos de la BÓVEDA — Sala A)
├── _federado/                (el molde del CEREBRO FEDERADO — Salas B, C, D + espinazo)
└── _perfiles/agentico/       (Sala D ampliada para proyectos con agentes)
```
