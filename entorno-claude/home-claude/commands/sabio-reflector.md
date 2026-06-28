---
description: (DEPRECADO — fusionado en /sabio-aprender --reflexivo) Alias que sigue funcionando. Reflexiona sobre un trabajo cerrado con feedback externo e infiere la CAUSA, delegando en el agente sabio-reflector (Opus). Captura local en la Sala D; la salida es /sabio-promover.
argument-hint: [contexto del trabajo cerrado | --sesion]
model: haiku
---

> **Comando unificado.** La captura tiene **un solo verbo**: `/sabio-aprender`. El modo reflexivo (causal,
> con feedback externo) es ahora **`/sabio-aprender --reflexivo`**. Este comando se conserva como **alias**
> para no romper tu memoria muscular; hace exactamente lo mismo.

Ejecuta el flujo de **`/sabio-aprender --reflexivo`** con el contexto de "$ARGUMENTS" (o la sesión si no hay
argumento): delega en el agente `sabio-reflector` (Opus), que exige **feedback externo**, infiere la **causa**
(no el síntoma), chequea novedad contra la Sala D y escribe **UN** candidato `verificado:false,
estado:pendiente` en `04-Recursos/04-Aprendizaje/registros/` del proyecto activo. Captura **local**; el
ascenso lo decide `/sabio-promover`. Sin feedback externo no afirma corrección.
