---
description: Aplica un lineamiento de diseño a una decisión concreta — equilibra KISS/YAGNI/DRY/SOLID/DDD/Clean Arch como una secuencia en el tiempo, con la Regla de Tres como dial y la legibilidad como desempate. Devuelve una recomendación con su porqué. Self-contained.
argument-hint: [la decisión de diseño en duda | el archivo/código a evaluar]
model: sonnet
---

Ayuda a tomar **una** decisión de diseño sin caer ni en el sobre-diseño ni en el caos. No es teoría:
es un dial que se aplica a lo que tienes delante. **Pragmatismo, no dogma.**

## El lineamiento (la regla de fondo)
Los principios **no se promedian**: se aplican como una **secuencia en el tiempo** según madura el código.
- **Nacer — KISS / YAGNI:** lo más simple que resuelve el problema de **hoy**. No construyas para un futuro que no llegó.
- **Crecer — DRY / SOLID / bloques DDD:** cuando aparece el **dolor real** (duplicación que cuesta, lógica difícil de probar), introduce abstracción y separa responsabilidades.
- **Madurar — Clean Architecture:** aísla la lógica de negocio de la tecnología **solo** cuando las reglas son muchas, valiosas y cambian seguido.

**Dial maestro — la Regla de Tres**, en dos escalas:
- *Micro:* extrae una abstracción a la **3.ª** duplicación, no antes. *"Duplicar es más barato que la abstracción equivocada."*
- *Macro:* monta capas DDD/Clean solo si puedes **nombrar ≥3 reglas de negocio reales**. Si no, una capa basta.

**Desempate:** cuando dos diseños son defendibles, gana el que **se lee mejor**. El código se lee mucho más de lo que se escribe.

## Procedimiento (qué hago al invocarme con "$ARGUMENTS")
1. **Entender la decisión** concreta en duda (qué se quiere abstraer, separar o estructurar).
2. **Situar la etapa** del código (¿nace, crece o madura?) — no apliques herramientas de "madurar" a algo que "nace".
3. **Aplicar el dial:** ¿hay ya 3 duplicaciones reales? ¿puedes nombrar 3 reglas de negocio? Si no llegas a 3, **espera y duplica**.
4. **Correr el checklist** (abajo). Si una respuesta delata complejidad especulativa o accidental, simplifica.
5. **Recomendar** la **opción más simple que pasa el checklist**, con una frase de porqué. Ofrece refactor posterior como plan, no ahora.

## Checklist antes de añadir estructura
1. ¿El cambio que justifica esto **ya ocurrió**, o es **especulativo**?
2. ¿Se **lee mejor o peor** que la opción simple?
3. ¿Un compañero nuevo se **orienta en una semana**?
4. ¿La complejidad es **esencial** del problema, o **accidental** de mi implementación?

## Salida
- **Recomendación:** la opción elegida (la más simple que pasa el checklist).
- **Porqué:** etapa + resultado del dial + desempate, en 1–2 frases llanas.
- **Plan diferido (si aplica):** qué señal disparará el siguiente nivel de estructura (p. ej. "extraer a la 3.ª duplicación").

## Fuentes (respaldo)
Lineamiento destilado de: Metz (*The Wrong Abstraction*) · Dodds (*AHA Programming*) · Seemann (*Why DRY?*, coste = C×p) · Three Dots Labs (*Is Clean Architecture Overengineering?*) · hidekazu-konishi (*Software Design Principles in Practice*, el checklist) · canon: R. C. Martin (SOLID/Clean Arch), E. Evans (DDD), M. Fowler (Rule of Three, YAGNI). Puedes guardar la razón y la evidencia como nota de respaldo `investigacion:decision-equilibrio-principios-diseno` en tu Sala A.
