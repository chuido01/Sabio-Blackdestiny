<!-- sabio-generacion: 1 -->
# Sala B — Catálogo operativo (esquema)

> **Para qué existe esta sala:** guardar el "**qué hace / qué tiene** el sistema": sus capacidades,
> activos, productos o componentes, **con atributos estructurados**. Es conocimiento **estable y
> versionado**, no narrativo — por eso NO va en la bóveda de investigación (Sala A): un catálogo
> volcado como notas atómicas rompe la atomicidad del wiki.
>
> *(Salas A–D = tipos de conocimiento; no confundir con Capa 1/2 = arquitectura del sistema.)*

## Cuándo empezar a usarla

Cuando el proyecto tenga su **primera capacidad/activo concreto que describir** (una herramienta, un
agente, un producto, un servicio). Hasta entonces, puede quedar vacía: ya está reservada y con esquema.

## Estructura

```
02-Catalogo/
├── LEEME - Esquema Sala B.md    (este archivo)
├── index.md                     (1 línea por ficha: - activo:<slug> — resumen)
└── fichas/                      (una ficha .md por activo)
```

## Esquema de una ficha (`fichas/<slug>.md`)

```yaml
---
id: activo:<slug>            # estable; no se renombra
nombre: ""
categoria: ""                # vocabulario del dominio del proyecto
version: 1                   # sube +1 con cada mejora promovida
estado: borrador             # borrador | activo | retirado
resumen: "Una frase."
atributos: {}                # los campos que tu dominio necesite (fijarlos pronto)
relaciones:                  # SOLO IDs de otras salas; nunca copiar su contenido
  - "norma:<marco>:<codigo>"     # qué normas satisface (Sala C)
  - "investigacion:<slug>"       # investigación de fondo (Sala A)
procedencia: []              # aprendizaje:<id> que originaron/mejoraron esta ficha
actualizado: AAAA-MM-DD
---

Descripción del activo (libre, pero breve). Qué hace, cómo se usa, límites conocidos.
```

## Reglas

1. **Una ficha = un activo.** El `index.md` se actualiza con cada alta/cambio.
2. **Versionado con procedencia:** si un aprendizaje (Sala D) mejora la ficha, sube `version` y
   registra el `aprendizaje:<id>` en `procedencia:`. Nunca se mejora automáticamente sin revisión.
3. **Amoldar sin perder el sentido:** renombra `categoria`/`atributos` a tu dominio cuanto quieras;
   lo que define a esta sala es: **estructurado, versionado, estable, referenciado por `activo:`**.
