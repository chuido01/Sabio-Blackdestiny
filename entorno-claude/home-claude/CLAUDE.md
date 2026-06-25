# Preferencias transversales — <TU NOMBRE / TU PLATAFORMA>

> Instrucciones **de usuario** (siempre cargadas, en cualquier proyecto). Solo lo **transversal**: lo
> específico de un proyecto vive en el `CLAUDE.md` de ESE proyecto.
> **Esto es una PLANTILLA** — ajústala a tu idioma y tu forma de trabajar.

## Comunicación
- **Responde siempre en tu idioma** (estos ejemplos están en español). Identificadores de código, rutas y nombres de archivo pueden quedar en inglés cuando es la convención.

## Modelo por tarea (coste/calidad)
- **Haiku** = mecánico (mover/renombrar, commits, scans). **Sonnet** = desarrollo (código, docs, integración). **Opus** = arquitectura/seguridad/verificación/síntesis.

## Aislamiento entre proyectos (por defecto)
- Cada proyecto trabaja **solo con su propio contexto**; no asumas datos (paletas, marcas, stacks) de otros proyectos ni mezcles sus bóvedas.
- **Única excepción:** lectura del **plano global** vía el MCP `sabio-shared` (compartido por diseño) — nunca de otro proyecto.

## Sistema de conocimiento = SABIO
- **Sin RAG:** gestión de contexto nativa de Claude Code + una bóveda-wiki en Obsidian estilo Karpathy, con el conocimiento **federado en 4 Salas** (A·Investigación · B·Catálogo · C·Referencia · D·Aprendizaje) unidas por el *índice de índices*.
- **2 planos:** conocimiento **local** por proyecto + un **plano global** (Centro de Mando Sabio) que guarda la referencia canónica transversal (`norma:…`) e investigación compartida, accesible **solo-lectura** vía `sabio-shared`.

## Captura de aprendizajes (Sala D)
- Al cerrar un trabajo no trivial, si apareció un *gotcha*, un error ya resuelto o un mejor camino, **ofrece capturarlo** (captura local en la Sala D del proyecto activo): **`/aprender`** para captura rápida, o **`/sabio-reflector`** cuando haya **feedback externo** que valga analizar (test, ejecución, tu reacción) — infiere la causa antes de guardar. No guardes sin tu OK, no interrumpas por nimiedades, ni conviertas la Sala D en bitácora. La salida es `/promover`.

## Decisiones de diseño — comando `/disenar`
- Ante una **duda de diseño** (¿abstraer o duplicar?, ¿añadir capas o mantener simple?), invoca **`/disenar`**: secuencia KISS/YAGNI → DRY/SOLID/DDD → Clean Arch, **Regla de Tres** como dial y **legibilidad** como desempate.

## (Opcional) Tu contrato de trabajo
> Añade aquí cómo quieres que se construya y documente. Ejemplos de reglas útiles:
- **Proporción ante todo.** Lo más pequeño que resuelve el problema; no sobre-construyas.
- **Confirmar la forma antes de construir.** Para algo no trivial, propón la forma y valida con **una muestra** antes de replicar.
- **Mostrar, no afirmar.** No digas "listo/hecho" sin enseñar la prueba real.
- **Honestidad sin adornos.** Si algo falló, falta o se saltó, dilo. Verifica antes de dar números o estados.
