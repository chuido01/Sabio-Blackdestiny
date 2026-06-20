/* ============================================================================
   semaforo.js — MOTOR de reglas (puro, sin DOM).
   Clasifica el ARQUETIPO del proyecto, evalúa su salud con umbrales propios del
   arquetipo y deriva la "acción recomendada". Es el cerebro del panel: testeable
   y reutilizable (p. ej. por un futuro MCP fleet-health). NO toca el DOM.

   Fase 2: un proyecto agéntico, una web tradicional y una app simple NO se miden
   igual. La clasificación y los umbrales viven AQUÍ (juicio en un solo sitio); el
   escáner solo aporta hechos crudos.

   Cada alerta es una cuádrupla: [sev, mensaje, acciónHTML, kind]. El `kind` (Fase 3) es la
   clave estable que prompts.js usa para el botón "Copiar prompt de arreglo".
   `federado` NO entra en el semáforo (es informativo).
   ============================================================================ */

/* Constantes de severidad (compartidas con las vistas). */
const SEVCSS = {verde:'var(--verde)', ambar:'var(--ambar)', rojo:'var(--rojo)'};
const SEVAB  = {verde:'v', ambar:'a', rojo:'r'};
const SEVTXT = {verde:'En orden', ambar:'Atención', rojo:'Crítico'};

/* ---------- arquetipos (4: control · agéntico · tradicional · simple) ---------- */
const ARQUETIPOS = {
  control:     {label:'Control',     pill:'purple', desc:'Plano de control de la flota.'},
  agentico:    {label:'Agéntico',    pill:'cyan',   desc:'Agentes, skills, MCP y/o workflows.'},
  tradicional: {label:'Tradicional', pill:'teal',   desc:'Web/app con stack y/o despliegue.'},
  simple:      {label:'Simple',      pill:'dim',    desc:'Estática/offline, sin build.'},
};
/* Criticidad para ordenar la cola de acciones (desempate, no severidad). */
const CRITICIDAD = {tradicional:3, control:2, agentico:2, simple:1};

/* Umbrales por arquetipo. `backupObligatorio:false` => una app simple no se marca
   por backup viejo/ausente (suele ser regenerable). Un agéntico tolera CLAUDE.md
   más grande (más instrucciones). NOTA (revisión Fase 2): agéntico comparte el backup
   ESTRICTO de tradicional (5/10) a propósito — así, si la heurística de nombre
   clasificara mal una web con datos como agéntica, NO le relaja la protección de backup
   (lado seguro). La única diferencia agéntico↔tradicional es el tamaño de CLAUDE.md. */
const UMBRALES = {
  control:     {backupObligatorio:true,  backupAmbar:7,  backupRojo:14, claudeKB:16, huerfanas:12},
  agentico:    {backupObligatorio:true,  backupAmbar:5,  backupRojo:10, claudeKB:16, huerfanas:12},
  tradicional: {backupObligatorio:true,  backupAmbar:5,  backupRojo:10, claudeKB:12, huerfanas:12},
  simple:      {backupObligatorio:false, backupAmbar:null, backupRojo:null, claudeKB:12, huerfanas:20},
};

function arquetipoDe(p){
  if(p.tipo==='control') return 'control';
  const as=p.agentesSkills||{};
  const propios=((as.agentes||[]).length+(as.skills||[]).length+(as.comandos||[]).length);
  // Heurística de nombre ANCLADA a límite de palabra/segmento y sin la palabra común "agente"
  // (evita falsos positivos tipo "reagente", "Agente Inmobiliario"). "agentic"/"workflow" son
  // términos técnicos poco probables por accidente. Un MCP extra ya NO clasifica por sí solo
  // (muchos MCP son tooling de infraestructura, no agencia). Override explícito: .fleet.json (Fase 4).
  const nombre=String(p.nombre||'').toLowerCase();
  const nombreAgentico=/(^|[-_ ])(agentic|workflows?)([-_ ]|$)/.test(nombre);
  if(nombreAgentico || propios>=1) return 'agentico';
  const tieneStack=!!(p.stack&&p.stack.lenguajes&&p.stack.lenguajes.length);
  const tieneDeploy=!!(p.deploy&&p.deploy.length);
  if(tieneStack||tieneDeploy) return 'tradicional';
  return 'simple';
}

function evaluar(p){
  const al=[]; const g=p.git||{}, v=p.vault||{}, b=p.backup||{}, cm=p.claudeMd||{};
  const arq=arquetipoDe(p); const u=UMBRALES[arq]||UMBRALES.simple;

  // --- git / riesgo de pérdida (escalado) ---
  // Cada alerta lleva un 4.º elemento `kind` estable: la clave que usa prompts.js para
  // ofrecer el botón "Copiar prompt de arreglo" (Fase 3). NO cambia el semáforo.
  if(!g.esRepo)                  al.push(['rojo','No es repositorio git','Inicializa git en la carpeta del proyecto.','no-repo']);
  else if(!g.tieneRemoto)        al.push(['rojo','Sin remoto git — riesgo de pérdida','Crea un remoto y haz <code>git push</code>.','sin-remoto']);
  else if(g.sinPush>0)           al.push(['ambar', g.sinPush+' commit(s) sin subir (push)','Sube los commits con <code>git push</code> para no perder trabajo.','sin-push']);
  else if(g.sinPush==null)       al.push(['ambar','Rama sin upstream — los commits no suben a ningún sitio','Enlaza la rama con <code>git push -u origin '+(g.rama||'main')+'</code>.','sin-upstream']);

  // --- backup (solo si el arquetipo lo exige) ---
  if(u.backupObligatorio){
    if(!b.existe)                          al.push(['rojo','Sin carpeta de copias (03-Backups)','Crea <code>03-Backups</code> y genera un respaldo.','backup-ausente']);
    else if(b.dias==null)                  al.push(['rojo','Carpeta de copias vacía','Genera un primer respaldo en <code>03-Backups</code>.','backup-vacia']);
    else if(u.backupRojo!=null && b.dias>u.backupRojo)   al.push(['rojo','Copia de seguridad de '+b.dias+' días','Haz un respaldo nuevo cuanto antes.','backup']);
    else if(u.backupAmbar!=null && b.dias>u.backupAmbar) al.push(['ambar','Copia de seguridad de '+b.dias+' días','Conviene un respaldo reciente.','backup']);
  }

  // --- higiene ---
  if(g.sucio)                    al.push(['ambar', g.archivosSucios+' cambio(s) sin commitear','Commitea o descarta los cambios pendientes.','sucio']);
  if(v.rotos>30)                 al.push(['rojo', v.rotos+' enlaces [[rotos]] en el grafo','Revisa el grafo con <code>/memory-lint</code>.','rotos']);
  else if(v.rotos>0)             al.push(['ambar', v.rotos+' enlace(s) [[roto(s)]] en el grafo','Corrige los wikilinks con <code>/memory-lint</code>.','rotos']);
  if(cm.bytes>u.claudeKB*1024)   al.push(['ambar','CLAUDE.md grande ('+Math.round(cm.bytes/1024)+' KB)','Divide o poda el <code>CLAUDE.md</code> para cuidar el contexto.','claude-grande']);
  if(v.huerfanas>u.huerfanas)    al.push(['ambar', v.huerfanas+' notas huérfanas','Enlaza las notas huérfanas al grafo.','huerfanas']);

  // --- seguridad (F4 #16): nombres de archivos versionados, nunca contenido ---
  const seg=p.seguridad||{};
  if(g.esRepo && seg.secretos && seg.secretos.length)
    al.push(['rojo', seg.secretos.length+' posible(s) secreto(s) versionado(s) en git','Saca esos archivos del control de versiones (<code>git rm --cached</code>), añádelos al <code>.gitignore</code> y rota las credenciales si eran reales.','secretos']);
  if(g.esRepo && seg.tieneGitignore===false)
    al.push(['ambar','Sin <code>.gitignore</code> — riesgo de versionar lo que no debes','Crea un <code>.gitignore</code> adecuado al stack del proyecto.','sin-gitignore']);

  const sev = al.some(a=>a[0]==='rojo')?'rojo':(al.length?'ambar':'verde');
  // Score de riesgo (F4 #17): peso por severidad de cada señal, ponderado por la criticidad
  // del arquetipo. Ordena la flota de forma objetiva (no solo por color).
  let riesgo=0; for(const a of al){ riesgo += (a[0]==='rojo'?10:(a[0]==='ambar'?3:0)); }
  riesgo = Math.round(riesgo*(1+0.2*((CRITICIDAD[arq]||1)-1)));
  return {sev, al, arq, riesgo};
}

function insightDe(e){
  if(!e.al.length) return null;
  const roja = e.al.find(a=>a[0]==='rojo');
  const pick = roja || e.al[0];
  return {motivo:pick[1], accion:pick[2], kind:pick[3]};
}
