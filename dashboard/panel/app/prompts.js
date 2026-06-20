/* ============================================================================
   prompts.js — Biblioteca de prompts de acción (Fase 3, mejoras #21–#22).
   Cada alerta del motor (semaforo.js) lleva un `kind`; aquí se mapea ese kind a un
   prompt LISTO PARA PEGAR en Claude Code, con el contexto del proyecto. El botón
   "Copiar prompt" (vistas.js/detalle.js) copia el resultado de promptDe(p, kind).

   Capa de DATOS: solo construye texto a partir de metadatos ya escaneados (nombre,
   ruta, números). No lee contenido de bóvedas. Redactados en español, seguros
   (piden verificar antes de cualquier acción destructiva).
   ============================================================================ */
window.PROMPTS = {
  'no-repo': p =>
`La carpeta del proyecto "${p.nombre}" (${p.ruta}) no es un repositorio git.
Inicialízalo de forma segura: ejecuta git init, crea un .gitignore adecuado al stack del proyecto, revisa qué debe quedar fuera del control de versiones (backups, secretos, dependencias) y haz el primer commit con un mensaje claro. Si conviene conectarlo a un remoto, propónmelo antes de hacerlo.`,

  'sin-remoto': p =>
`El proyecto "${p.nombre}" (${p.ruta}) es un repositorio git SIN remoto, así que su historia solo existe en este equipo (riesgo de pérdida).
Ayúdame a crear un repositorio remoto y conectarlo (git remote add origin …), y luego sube todo con git push -u origin <rama>. Muéstrame los pasos y confirma la rama antes de subir.`,

  'sin-push': p =>
`En el proyecto "${p.nombre}" (${p.ruta}) hay ${p.git&&p.git.sinPush!=null?p.git.sinPush:'varios'} commit(s) locales sin subir al remoto.
Revisa el estado (git status, git log origin/${(p.git&&p.git.rama)||'main'}..HEAD), confirma que la rama es la correcta y sube los commits con git push. No fuerces nada; si algo no cuadra, explícamelo antes.`,

  'sin-upstream': p =>
`La rama actual de "${p.nombre}" (${p.ruta}) no tiene upstream configurado, por lo que los commits no van a ningún remoto.
Verifica el remoto y enlaza la rama con git push -u origin ${(p.git&&p.git.rama)||'main'}. Comprueba después que git status muestra el seguimiento correcto.`,

  'backup': p =>
`La copia de seguridad más reciente de "${p.nombre}" (${p.ruta}) tiene ${p.backup&&p.backup.dias!=null?p.backup.dias:'varios'} días.
Genera un respaldo nuevo en su carpeta 03-Backups siguiendo la convención del proyecto (nombre con fecha DDMMAAAA, manifiesto .md). Si hay un script o procedimiento de backup, úsalo; si no, propón uno mínimo.`,

  'backup-ausente': p =>
`El proyecto "${p.nombre}" (${p.ruta}) no tiene carpeta de copias de seguridad (03-Backups).
Crea la carpeta 03-Backups y genera un primer respaldo siguiendo la convención de la plataforma (fecha DDMMAAAA + manifiesto). Confirma qué debe incluir el respaldo antes de copiar nada pesado.`,

  'backup-vacia': p =>
`La carpeta 03-Backups de "${p.nombre}" (${p.ruta}) existe pero está vacía: no hay ningún respaldo.
Genera el primer respaldo siguiendo la convención del proyecto (fecha DDMMAAAA + manifiesto .md).`,

  'sucio': p =>
`En "${p.nombre}" (${p.ruta}) hay ${p.git&&p.git.archivosSucios!=null?p.git.archivosSucios:'varios'} cambio(s) sin commitear.
Revisa git status y el diff, agrupa los cambios en commits coherentes con mensajes claros (imitando el estilo del repo) y commitéalos. Si algo debería descartarse o ignorarse, dímelo antes de hacerlo.`,

  'rotos': p =>
`El grafo de conocimiento (SABIO) de "${p.nombre}" (${p.ruta}) tiene ${p.vault&&p.vault.rotos!=null?p.vault.rotos:'varios'} enlace(s) [[rotos]].
Ejecuta /memory-lint y corrige los wikilinks rotos del vault (apuntan a notas que no existen o están mal escritas), sin alterar el contenido de las notas más allá de los enlaces.`,

  'claude-grande': p =>
`El CLAUDE.md de "${p.nombre}" (${p.ruta}) pesa ${p.claudeMd&&p.claudeMd.bytes?Math.round(p.claudeMd.bytes/1024):'>12'} KB y conviene podarlo para cuidar el contexto.
Propón qué mover a la documentación o a la Sala de conocimiento que corresponda, y deja el CLAUDE.md con lo esencial y estable, SIN perder reglas importantes (aislamiento, hechos, convenciones). Enséñame el antes/después antes de aplicar.`,

  'huerfanas': p =>
`El vault de "${p.nombre}" (${p.ruta}) tiene ${p.vault&&p.vault.huerfanas!=null?p.vault.huerfanas:'varias'} notas huérfanas (sin enlaces de entrada ni salida).
Ayúdame a enlazarlas al grafo donde tenga sentido, respetando el esquema de la bóveda. Si alguna nota está obsoleta y debería archivarse en vez de enlazarse, propónmelo.`,

  'secretos': p =>
`ALERTA DE SEGURIDAD en "${p.nombre}" (${p.ruta}): el panel detectó ${p.seguridad&&p.seguridad.secretos?p.seguridad.secretos.length:'algunos'} archivo(s) que parecen secretos VERSIONADOS en git${p.seguridad&&p.seguridad.secretos&&p.seguridad.secretos.length?': '+p.seguridad.secretos.slice(0,6).join(', '):''}.
Revisa si contienen credenciales reales. Si es así: (1) sácalos del control de versiones con git rm --cached, (2) añádelos al .gitignore, (3) avísame para ROTAR las credenciales expuestas, y (4) valora si hace falta limpiar el historial de git. No subas nada hasta confirmar conmigo el plan.`,

  'sin-gitignore': p =>
`El repositorio de "${p.nombre}" (${p.ruta}) no tiene .gitignore, así que es fácil versionar por error secretos, dependencias o backups.
Crea un .gitignore adecuado al stack del proyecto (revisa qué hay hoy en el árbol que NO debería versionarse) y, si ya hay algo trackeado que debería excluirse, propónme cómo sacarlo sin perder datos.`,
};

/* Devuelve el prompt final para (proyecto, kind); fallback genérico si el kind no tiene plantilla. */
function promptDe(p, kind){
  const f = window.PROMPTS[kind];
  if(f) return f(p);
  return `En el proyecto "${p.nombre}" (${p.ruta}), ayúdame a revisar y corregir este aspecto de salud detectado por el panel de flota. Explícame qué encuentras antes de cambiar nada.`;
}
