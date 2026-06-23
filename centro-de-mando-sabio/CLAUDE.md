# Centro de Mando Sabio

> El **hub** de tu plataforma SABIO: el plano de control y el **plano global de conocimiento**.
> No es un proyecto entregable; **sirve a todos tus proyectos** sin ser uno de ellos.

## Qué es / qué NO es
- **SÍ:** guarda el conocimiento común (Salas C y D transversales + investigación compartida),
  reparte el Kit a proyectos nuevos y es el **único** que escribe el plano global.
- **NO:** no es una app ni un entregable. Su "producto" es mantener sana y coordinada la plataforma.

## Hechos estables (NO inventar)
- **Arquitectura:** 2 capas, **SIN RAG** (gestión de contexto nativa de Claude Code + una bóveda-wiki
  en Obsidian estilo Karpathy).
- **Estructura:** las mismas 5 carpetas que cualquier proyecto. El **plano global** vive en
  `04-Recursos/` (índice de índices + las 4 Salas).
- **MCP:** `mcp/server.py` expone `04-Recursos/` en **solo-lectura** a los proyectos (`sabio-shared`).

## Dueño del plano global (escritura)
- Este es el **único** sitio con **escritura** sobre el plano global (Salas C y D transversales,
  investigación compartida). Desde los proyectos, el plano global es **solo-lectura** (vía el MCP
  `sabio-shared`).
- `/promover` **materializa aquí** los candidatos genéricos triados y traídos desde los proyectos.

## Sede de despliegue (poderes y límites)
- Puede **desplegar el Kit** (`Crear-Proyecto.ps1` / `Actualizar-Proyecto.ps1`) hacia el destino que el
  usuario **indique explícitamente**. Es idempotente y no destructivo.
- **Restricción del destino — inmutable:** cada destino conserva **su propio** aislamiento. El
  despliegue lo **escribe o preserva, nunca lo debilita**.
- **NO** lee, copia ni mezcla conocimiento, bóvedas ni datos de otros proyectos. El acceso hacia fuera
  es **solo de escritura para el despliegue**.

## Conocimiento federado (Salas A–D)
- Antes de buscar o guardar conocimiento, **lee `04-Recursos/00-INDICE-DE-INDICES.md`** (el espinazo:
  qué prefijo de ID vive en qué Sala).
- **Sala A · Investigación** (bóveda; en el hub es **transversal y multi-dominio** 🌐) · **Sala B · Catálogo** · **Sala C · Referencia** 🌐 ·
  **Sala D · Aprendizaje** 🌐.
- **Sala A multi-dominio:** la bóveda del hub aloja investigación transversal de varios dominios; un dominio nuevo = clave `dominio:<slug>` + nota-índice (MOC) en la **única** bóveda, **nunca** una bóveda nueva por tema (`sabio-shared` expone una sola).
- **Reglas:** un dato vive en UNA sola Sala; las demás lo referencian por ID (**nunca copiar**). Respeta
  el `LEEME - Esquema` de cada Sala. La Sala C solo se alimenta de fuente oficial citada.

## Aislamiento
- Trabaja **solo con el contexto de este hub**. La única salida permitida es **desplegar el Kit** hacia
  destinos indicados; nunca para leer ni importar conocimiento de otro proyecto.
