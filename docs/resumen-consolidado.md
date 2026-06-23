# SABIO Blackdestiny

> Consolida las 4 guías por componente
> (SABIO · Centro de Mando · Proyectos · Mapa de Archivos) en lenguaje llano.
> Pensado para explicar **todos los conceptos** a alguien que parte de cero.

---

## 1. Qué es SABIO (la idea en una frase)

SABIO es la **memoria a largo plazo para trabajar con una IA**: un sitio ordenado donde cada cosa
que investigas o decides queda guardada **una sola vez**, etiquetada, y se puede volver a encontrar —
sin que un proyecto se contamine con los datos de otro.

**SABIO** = **S**istema de **A**rchivos, **B**óvedas e **Í**ndices **O**rganizados.

---

## 2. El problema que resuelve (dos olvidos y un desorden)

- **Olvido dentro del chat.** En conversaciones largas la IA olvida lo de arriba: su "ventana" de
  atención se satura.
- **Olvido entre sesiones.** Cierras el chat y mañana no recuerda lo que decidieron.
- **Desorden / mezcla.** Antes todo vivía junto sin frontera, y los datos de un proyecto (su marca,
  su paleta) se filtraban en otro.

SABIO ataca los tres a la vez.

---

## 3. La gran decisión: SIN RAG

No se usa una base de datos vectorial (eso es "RAG"). A un volumen moderado (menos de ~2.000
páginas) basta una **wiki en texto que la IA lee directamente**. Es más simple, más barato y más
controlable. Es el patrón "LLM Wiki" de Andrej Karpathy.

---

## 4. Los dos cimientos: Capa 1 y Capa 2

Son la **arquitectura** (los cimientos del sistema):

- **Capa 1 — No perderse.** Dos cosas: el **aislamiento** (cada proyecto en su caja) y la **gestión
  de contexto** (que la IA no se sature en un chat largo).
- **Capa 2 — Recordar.** La **bóveda de conocimiento** que guarda lo aprendido entre sesiones.

> ⚠️ No confundir las **Capas** (la arquitectura) con las **Salas** (los tipos de conocimiento).

---

## 5. Los dos planos: global y local

- **Plano global — el Centro de Mando.** Lo que es igual para todos vive aquí **una sola vez** y es
  de **solo lectura**: la investigación transversal (Sala A, hoy **multi-dominio**), las normas (Sala C) y las lecciones transversales que se promueven (Sala D).
- **Plano local — cada proyecto.** Lo propio de cada proyecto, dentro de su caja: su investigación
  (Sala A), su catálogo (Sala B) y su captura de aprendizajes (Sala D). *(La Sala A y la D viven en los dos planos: locales en cada proyecto, y transversales/multi-dominio en el Centro.)*

**La única conexión va hacia arriba y es de solo lectura:** un proyecto puede *consultar* el plano
global (vía un puente llamado MCP `sabio-shared`), pero **jamás** lee la carpeta de otro proyecto.
Eso es el aislamiento.

---

## 6. Las 4 Salas del conocimiento

Cada dato es de un tipo, y por eso vive en una Sala concreta (como cuatro estanterías):

| Sala | Qué guarda | Etiqueta (ID) |
|---|---|---|
| **A · Investigación** | Lo que estudias: notas cortas (una idea por nota) enlazadas entre sí. Es la bóveda. La del Centro es **multi-dominio** (un dominio nuevo = etiqueta + mapa, no una bóveda aparte). | `investigacion:<tema>` |
| **B · Catálogo** | Tus herramientas y activos: fichas de qué tienes, para qué sirve, qué cuesta. | `activo:<cosa>` |
| **C · Referencia** | Normas y estándares externos (NIST, ISO, PCI). Iguales para todos → viven en el plano global. | `norma:<marco>:<código>` |
| **D · Aprendizaje** | Lecciones de lo que pasó, para no repetir errores. | `aprendizaje:<id>` |

**Dos perfiles de la Sala D**, según el proyecto:
- **Base** — captura sencilla, a mano, con el comando `/aprender`.
- **Agéntico** — añade un validador automático y mide la confianza con números. Para proyectos con
  flotas de agentes. Es la **misma** Sala D; solo cambia cuánta maquinaria carga.

---

## 7. La regla de oro: un dato, un solo hogar

**Nada se copia.** Si dos sitios necesitan el mismo dato, uno lo **guarda** y el otro lo **señala
con su etiqueta (ID)**.

- Ejemplo: una norma vive una sola vez en la Sala C, con su etiqueta. Los proyectos no la copian: la
  señalan. Si la norma cambia, se actualiza en un solo sitio y todos ven el cambio.
- El **índice de índices** es el mapa que dice **qué etiqueta vive en qué Sala**. Es el espinazo del
  sistema: con él, cualquiera que encuentre una etiqueta sabe dónde resolverla.

Esto evita duplicados y "deriva" (que dos copias del mismo dato se desincronicen).

---

## 8. El Centro de Mando: el cuartel general

No es un proyecto más: es el sitio que **sirve a todos los proyectos** sin ser uno de ellos.

**Sus 4 trabajos:**
1. **Guardar el conocimiento común** (el plano global: la Sala A transversal multi-dominio + las Salas C y D transversales).
2. **Repartir SABIO a proyectos nuevos** (el Kit).
3. **Observar la salud de la flota** (un panel/dashboard).
4. **Mejorar la flota sola** (el volante: agentes y comandos).

**El dashboard de flota** lee datos de configuración (no el contenido de tu trabajo) y responde dos
preguntas: *¿está todo a salvo y sano?* y *¿qué atiendo primero?*. No mide a todos igual: distingue
**4 arquetipos** de proyecto (control, agéntico, tradicional, simple) y a cada uno lo cuida con su
propia vara. Usa un **semáforo** (verde / ámbar / rojo) y una lista de prioridades.

**El poder especial — sede de despliegue:** el Centro de Mando es el único que puede "salir" hacia
los proyectos, pero **solo en una dirección y para una cosa**: desplegar el Kit (crear o actualizar
estructura). Nunca lee ni mezcla el conocimiento de un proyecto con otro.

---

## 9. Los proyectos: iguales por fuera, aislados por dentro

- **Iguales por fuera:** todos nacen del Kit, así que comparten las mismas 5 carpetas. Entiendes uno,
  los entiendes todos.
- **Aislados por dentro:** cada proyecto trabaja solo con su contexto; ninguno lee a otro. Esa
  ausencia de conexiones *es* el aislamiento.
- **Lo único compartido:** el conocimiento común del Centro de Mando, de solo lectura.

---

## 10. El volante: cómo una buena idea llega a todos

Sin esto, los proyectos serían islas que repiten trabajo. El volante hace que lo bueno se contagie:

- **Agentes** — ayudantes especializados disponibles en todos los proyectos (revisor de código,
  escritor de commits, de documentación, curador de investigación, curador de SABIO, de seguridad).
- **`/promover`** — sube una lección genérica al plano global (una sola copia) para que todos la usen.
- **`/memory-lint`** — vigila que no haya conocimiento duplicado ni desactualizado. Por defecto solo
  reporta, no toca nada.
- **`/aprender`** — captura una lección en la Sala D local (la puerta de entrada).
- **`/disenar`** — ante una duda de diseño, da una recomendación equilibrando simplicidad y estructura.

---

## 11. Glosario express (las confusiones aclaradas)

- **Capa 1 / Capa 2** = la **arquitectura** (aislamiento + no perderse / la bóveda que recuerda).
- **Sala A–D** = los **tipos de conocimiento** (Investigación, Catálogo, Referencia, Aprendizaje).
- **Plano local** = el conocimiento de un proyecto, que no sale de su caja.
- **Plano global** = el conocimiento compartido por toda la plataforma (la Sala A transversal multi-dominio + Salas C y D), de solo lectura.
- **Federar** = guardar un dato una vez y que los demás lo señalen por su etiqueta, en vez de copiarlo.
- **raw vs wiki** = fuentes originales intocables vs. las notas que la IA escribe a partir de ellas.
- **MCP `sabio-shared`** = el puente de solo-lectura por el que un proyecto consulta el plano global.

---

### Ideas clave para el infográfico (lo esencial que debe verse)

1. **SABIO Blackdestiny = memoria a largo plazo para trabajar con IA, sin RAG.**
2. **Dos olvidos + un desorden** → los tres problemas que resuelve.
3. **2 planos** (global de solo lectura ↑ y local aislado) con **una sola flecha hacia arriba**.
4. **4 Salas** (A·Investigación, B·Catálogo, C·Referencia, D·Aprendizaje).
5. **Un dato, un solo hogar** → federación por ID, cero copias.
6. **El Kit** crea proyectos iguales; **el volante** contagia lo aprendido a todos.
