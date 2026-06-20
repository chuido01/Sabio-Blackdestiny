/* ============================================================================
   vistas.js — Utilidades compartidas, estado y render de las vistas principales:
   KPIs, organigrama (Control) y cuadrícula (Grid).
   Los datos llegan como globales window.FLOTA / window.HISTORIAL
   (los escribe Escanear-Flota.ps1 en datos/*.js). Carga después de semaforo.js.
   ============================================================================ */

/* ---------- datos (generados; ver datos/*.js) ---------- */
const FLOTA      = window.FLOTA      || null;
const HISTORIAL  = window.HISTORIAL  || null;

/* Icono de copiar, compartido por todos los botones "Copiar …" (vistas + drawer). */
const COPY_SVG = '<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>';

/* ---------- estado compartido (mutado por el drawer y la navegación) ---------- */
let VISTA='control', SEL=null, TAB='resumen', PS=[];
let GQ='', GSOLO=false, GSORT='riesgo';   // filtro/orden de la cuadrícula (#29)

/* ---------- utilidades ---------- */
const $ = (id) => document.getElementById(id);
const esc = (s) => String(s==null?'':s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

function minutos(iso){ if(!iso) return null; return (Date.now()-new Date(iso).getTime())/60000; }
function hace(iso){
  const m = minutos(iso); if(m==null) return null;
  if(m<1) return 'hace segundos';
  if(m<60) return 'hace '+Math.round(m)+' min';
  if(m<1440) return 'hace '+Math.round(m/60)+' h';
  const d=Math.round(m/1440); return 'hace '+d+(d===1?' día':' días');
}
function fmt(n){ return n==null?'—':Number(n).toLocaleString('es'); }
function abrev(n){ n=Number(n||0); return n>=1000 ? (n/1000).toFixed(n>=10000?0:1).replace('.0','')+'k' : String(n); }
function numProy(p,i){ const m=String(p.nombre).match(/^(\d+)/); return m?m[1]:(p.tipo==='control'?'★':String(i)); }
function repoUrl(r){ if(!r) return null; let u=r.trim(); if(u.startsWith('git@')) u=u.replace('git@','https://').replace(/:(?=[^/])/,'/'); return u.replace(/\.git$/,''); }
function fileUrl(ruta){ return 'file:///'+encodeURI(String(ruta).replace(/\\/g,'/')); }
/* Federado honesto: separa fichas de autoría del corpus importado (MITRE/NIST/skills). */
function fedTxt(v){
  const fed=Number((v&&v.federado)||0); if(!fed) return '';
  const corp=Number((v&&v.federadoCorpus)||0), fichas=Math.max(0,fed-corp);
  return `<br><span class="mut">${abrev(fichas)} fichas${corp>0?` · +${abrev(corp)} corpus imp.`:''} fed.</span>`;
}

/* ---------- portapapeles + toast (Fase 3: botones que inyectan prompts) ---------- */
function fallbackCopy(texto){
  // Guardamos el foco actual: el <textarea> temporal lo roba, y al eliminarlo el foco
  // caería en <body> rompiendo la trampa de foco del drawer (accesibilidad por teclado).
  const prev=document.activeElement;
  const restaurar=()=>{ if(prev && prev.focus){ try{ prev.focus(); }catch(_){ } } };
  try{
    const ta=document.createElement('textarea');
    ta.value=texto; ta.setAttribute('readonly',''); ta.style.position='fixed'; ta.style.top='-1000px'; ta.style.opacity='0';
    document.body.appendChild(ta); ta.focus(); ta.select();
    const ok=document.execCommand('copy'); document.body.removeChild(ta);
    restaurar(); return ok;
  }catch(e){ restaurar(); return false; }
}
function copiar(texto){
  const ok=()=>showToast('✓ Prompt copiado — pégalo en Claude Code');
  const ko=()=>showToast('No se pudo copiar — selecciona y copia a mano');
  if(navigator.clipboard && navigator.clipboard.writeText){
    navigator.clipboard.writeText(texto).then(ok).catch(()=>{ fallbackCopy(texto)?ok():ko(); });
  } else { fallbackCopy(texto)?ok():ko(); }
}
let _toastT=null;
function showToast(msg){
  const t=$('toast'); if(!t) return;
  t.textContent=msg; t.classList.add('on');
  clearTimeout(_toastT); _toastT=setTimeout(()=>t.classList.remove('on'), 2600);
}
/* Copia el prompt de arreglo de una alerta (proyecto i, kind). */
function copiarPromptAlerta(i, kind){
  const p=PS[i]; if(!p || typeof promptDe!=='function') return;
  copiar(promptDe(p, kind));
}

/* ---------- tendencias (sparklines sobre el historial datado) ---------- */
function serieDe(nombre, campo){
  if(!HISTORIAL || !HISTORIAL.length) return [];
  return HISTORIAL.map(s => (s.proyectos && s.proyectos[nombre] && s.proyectos[nombre][campo]!=null) ? Number(s.proyectos[nombre][campo]) : null).filter(x=>x!=null);
}
function sparkline(serie, color){
  const w=118,h=26,pad=3;
  if(!serie || serie.length<2) return '';
  const min=Math.min(...serie), max=Math.max(...serie), rng=(max-min)||1;
  const xy=serie.map((v,i)=>[pad+i*(w-2*pad)/(serie.length-1), h-pad-((v-min)/rng)*(h-2*pad)]);
  const pts=xy.map(p=>p[0].toFixed(1)+','+p[1].toFixed(1)).join(' ');
  const last=xy[xy.length-1];
  const area=`${pad},${h-pad} ${pts} ${last[0].toFixed(1)},${h-pad}`;
  return `<svg class="spark" viewBox="0 0 ${w} ${h}" width="${w}" height="${h}" aria-hidden="true">`
    + `<polygon points="${area}" fill="${color}" fill-opacity=".10"/>`
    + `<polyline points="${pts}" fill="none" stroke="${color}" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round"/>`
    + `<circle cx="${last[0].toFixed(1)}" cy="${last[1].toFixed(1)}" r="2.3" fill="${color}"/></svg>`;
}
function trendRow(label, serie, color){
  if(serie.length<2) return '';
  const last=serie[serie.length-1], first=serie[0], d=last-first;
  const dtxt = d===0 ? '—' : (d>0?'▲ +'+d:'▼ '+d);
  const dcol = d===0 ? 'var(--dim)' : (label==='Rotos' ? (d>0?'var(--rojo)':'var(--verde)') : (d>0?'var(--verde)':'var(--muted)'));
  return `<div class="trow"><span class="tl">${label}</span>${sparkline(serie,color)}`
    + `<span class="tv mono">${last}</span><span class="td mono" style="color:${dcol}">${dtxt}</span></div>`;
}

/* ---------- render principal ---------- */
function render(){
  if(!FLOTA || !FLOTA.proyectos){
    $('tree').innerHTML = '<div class="empty" style="padding:20px">Sin datos. Ejecuta <code>Escanear-Flota.ps1</code>.</div>';
    return;
  }
  PS = FLOTA.proyectos.map(p=>({...p, _e:evaluar(p)}));

  // sello de generación
  const mins = minutos(FLOTA.generado);
  const cls = mins==null?'':(mins>1440?'old':(mins>60?'warn':''));
  $('stamp').outerHTML = `<div id="stamp" class="stamp ${cls}"><span class="pip"></span>`
    + `Generado <span class="mono">${esc(hace(FLOTA.generado)||'—')}</span>`
    + ` · <span class="mono">${PS.length}</span> proyectos</div>`;

  renderKpis();
  renderCola();
  renderNovedades();
  renderControl();
  renderGrid();
}

/* ---------- novedades desde el último escaneo (F4 #19) ----------
   Compara los dos últimos snapshots del historial y resume qué cambió en la flota:
   commits nuevos, [[rotos]] que suben/bajan, backups renovados, notas, proyectos nuevos.
   Pasa de "foto fija" a "qué se movió" de un vistazo. */
const NOV_ICON = '<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 7v5l3 3"/><path d="M3.05 11a9 9 0 1 1 .5 4"/><path d="M3 5v4h4"/></svg>';
function renderNovedades(){
  const el=$('novedades'); if(!el) return;
  if(!HISTORIAL || HISTORIAL.length<2){ el.classList.add('hidden'); return; }
  el.classList.remove('hidden');
  const cur=HISTORIAL[HISTORIAL.length-1], prev=HISTORIAL[HISTORIAL.length-2];
  const cp=cur.proyectos||{}, pp=prev.proyectos||{};
  const filas=[];
  Object.keys(cp).forEach(nombre=>{
    const c=cp[nombre], p=pp[nombre], cambios=[];
    if(!p){ cambios.push(['add','nuevo en la flota']); }
    else {
      const dc=(c.commits||0)-(p.commits||0); if(dc>0) cambios.push(['up', `+${dc} commit${dc>1?'s':''}`]);
      if((c.rotos||0)!==(p.rotos||0)) cambios.push([(c.rotos||0)<(p.rotos||0)?'good':'bad', `rotos ${p.rotos||0}→${c.rotos||0}`]);
      const dn=(c.notas||0)-(p.notas||0); if(dn!==0) cambios.push([dn>0?'up':'warn', `notas ${dn>0?'+':''}${dn}`]);
      if(p.backupDias!=null && c.backupDias!=null && c.backupDias < p.backupDias-0.4) cambios.push(['good','backup renovado']);
      if((c.sucios||0)!==(p.sucios||0)) cambios.push([(c.sucios||0)<(p.sucios||0)?'good':'warn', `sin commit ${p.sucios||0}→${c.sucios||0}`]);
    }
    if(cambios.length) filas.push({nombre, cambios});
  });
  const head=`<div class="nov-head">${NOV_ICON}Novedades · desde el escaneo anterior <span class="nov-when">${esc(hace(cur.fecha)||'')}</span></div>`;
  if(!filas.length){ el.innerHTML = head + `<div class="nov-empty">Sin cambios desde el escaneo anterior.</div>`; return; }
  el.innerHTML = head + `<div class="nov-list">`
    + filas.map(f=>`<div class="nov-row"><span class="nov-name" title="${esc(f.nombre)}">${esc(f.nombre)}</span><span class="nov-chips">${f.cambios.map(c=>`<span class="nov-chip ${c[0]}">${esc(c[1])}</span>`).join('')}</span></div>`).join('')
    + `</div>`;
}

/* ---------- cola de acciones priorizada de la flota (Top 5) ----------
   Aplana todas las alertas de todos los proyectos y las ordena por severidad
   (rojo > ámbar) y, a igualdad, por criticidad del arquetipo. Convierte el panel
   de "describir" a "decidir": qué hacer ahora, de un vistazo. */
function renderCola(){
  const el=$('cola'); if(!el) return;
  const items=[];
  PS.forEach((p,i)=>{ (p._e.al||[]).forEach(a=>items.push({i, sev:a[0], motivo:a[1], arq:p._e.arq, nombre:p.nombre})); });
  if(!items.length){
    el.innerHTML = `<div class="cola-empty"><span class="cola-ok">✔</span> Flota en orden — nada urgente que hacer ahora.</div>`;
    return;
  }
  const rank={rojo:0,ambar:1,verde:2};
  items.sort((x,y)=> (rank[x.sev]-rank[y.sev]) || ((CRITICIDAD[y.arq]||1)-(CRITICIDAD[x.arq]||1)) );
  const top=items.slice(0,5);
  const arqPill=a=>{ const m=ARQUETIPOS[a]||ARQUETIPOS.simple; return `<span class="pill ${m.pill}">${m.label}</span>`; };
  el.innerHTML =
      `<div class="cola-head"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m3 17 2 2 4-4"/><path d="m3 7 2 2 4-4"/><path d="M13 6h8"/><path d="M13 12h8"/><path d="M13 18h8"/></svg>Prioridades · qué hacer ahora</div>`
    + `<div class="cola-list">`
    + top.map(t=>`<button class="cola-item s-${SEVAB[t.sev]}" data-i="${t.i}" style="--s:${SEVCSS[t.sev]}" aria-label="${esc(t.nombre)}: ${esc(t.motivo)}">
        <span class="cola-dot"></span>
        <span class="cola-txt"><b>${esc(t.nombre)}</b> — ${esc(t.motivo)}</span>
        ${arqPill(t.arq)}
      </button>`).join('')
    + `</div>`
    + (items.length>5?`<div class="cola-more">+${items.length-5} señal(es) más · ábrelas desde las tarjetas</div>`:'');
}

function renderKpis(){
  const nV=PS.filter(p=>p._e.sev==='verde').length, nA=PS.filter(p=>p._e.sev==='ambar').length, nR=PS.filter(p=>p._e.sev==='rojo').length;
  const remoto=PS.filter(p=>p.git&&p.git.tieneRemoto).length;
  const notas=PS.reduce((s,p)=>s+((p.vault&&p.vault.notas)||0),0);
  const deploys=PS.filter(p=>p.deploy&&p.deploy.length).length;
  const skills=(FLOTA.globalClaude&&FLOTA.globalClaude.skills?FLOTA.globalClaude.skills.length:0);
  const kpi=(l,v,c)=>`<div class="kpi" style="--c:${c}"><div class="l">${l}</div><div class="v">${v}</div></div>`;
  $('kpis').innerHTML =
      kpi('Proyectos', PS.length, 'var(--cyan)')
    + kpi('En orden', nV, 'var(--verde)')
    + kpi('Atención', nA, 'var(--ambar)')
    + kpi('Crítico', nR, 'var(--rojo)')
    + kpi('Con remoto', `${remoto}<small>/${PS.length}</small>`, 'var(--purple)')
    + kpi('Notas (wiki)', fmt(notas), 'var(--teal)')
    + kpi('Despliegues', deploys, 'var(--pink)');
}

/* ---------- vista CONTROL ---------- */
function nodoHtml(p,i,root){
  const e=p._e, s=SEVCSS[e.sev];
  const motivo = e.al.length ? e.al[0][1] : 'sin alertas';
  const rcls = e.al.length ? '' : 'ok';
  const arq = ARQUETIPOS[e.arq]||ARQUETIPOS.simple;
  return `<button class="node s-${SEVAB[e.sev]} ${SEL===i?'sel':''}" data-i="${i}" style="--s:${s}">
    <span class="node-ring"><span class="node-num">${esc(numProy(p,i))}</span></span>
    <span class="node-body">
      <span class="node-name" title="${esc(p.nombre)}">${esc(p.nombre)}</span>
      <span class="node-arq pill ${arq.pill}">${arq.label}</span>
      <span class="node-reason ${rcls}">${e.al.length?'<span class="dotr"></span>':'✔ '}${esc(motivo)}</span>
    </span>
  </button>`;
}
function renderControl(){
  const ri = PS.findIndex(p=>p.tipo==='control');
  const rootI = ri<0?0:ri;
  const kids = PS.map((p,i)=>({p,i})).filter(x=>x.i!==rootI);
  $('tree').innerHTML =
      `<svg class="tree-links" id="links"></svg>`
    + `<div class="tree-root">${nodoHtml(PS[rootI],rootI,true)}</div>`
    + `<div class="tree-branches">${kids.map(x=>nodoHtml(x.p,x.i,false)).join('')}</div>`;
  requestAnimationFrame(drawLinks);
}
function drawLinks(){
  const tree=$('tree'), svg=$('links'); if(!tree||!svg) return;
  const tr=tree.getBoundingClientRect();
  const rootEl=tree.querySelector('.tree-root .node'); if(!rootEl) return;
  const rr=rootEl.getBoundingClientRect();
  const rx=rr.right-tr.left+tree.scrollLeft, ry=rr.top+rr.height/2-tr.top;
  const W=tree.scrollWidth, H=tree.scrollHeight;
  svg.setAttribute('width',W); svg.setAttribute('height',H); svg.setAttribute('viewBox',`0 0 ${W} ${H}`);
  let d='';
  tree.querySelectorAll('.tree-branches .node').forEach(el=>{
    const b=el.getBoundingClientRect();
    const nx=b.left-tr.left+tree.scrollLeft, ny=b.top+b.height/2-tr.top;
    const dx=Math.max(28,(nx-rx)*0.5);
    const sev=el.style.getPropertyValue('--s')||'var(--border-hi)';
    d+=`<path d="M ${rx} ${ry} C ${rx+dx} ${ry}, ${nx-dx} ${ny}, ${nx} ${ny}" fill="none" stroke="${sev}" stroke-opacity=".35" stroke-width="1.6"/>`;
  });
  svg.innerHTML=d;
}

/* ---------- vista GRID (filtro/orden #29, riesgo #17) ---------- */
function renderGrid(){
  const q=GQ.trim().toLowerCase();
  let items=PS.map((p,i)=>({p,i}))
    .filter(({p})=> (!q || String(p.nombre).toLowerCase().includes(q)) && (!GSOLO || (p._e.al&&p._e.al.length)));
  if(GSORT==='nombre') items.sort((a,b)=> String(a.p.nombre).localeCompare(String(b.p.nombre),'es'));
  else items.sort((a,b)=> ((b.p._e.riesgo||0)-(a.p._e.riesgo||0)) || (a.i-b.i));
  if(!items.length){ $('grid').innerHTML = `<div class="empty" style="grid-column:1/-1;padding:18px 6px">Ningún proyecto coincide con el filtro.</div>`; return; }
  $('grid').innerHTML = items.map(({p,i})=>{
    const e=p._e, s=SEVCSS[e.sev], g=p.git||{}, v=p.vault||{}, b=p.backup||{};
    const motivo = e.al.length ? e.al[0][1] : '✔ sin alertas';
    const commit = g.esRepo ? `<span class="mono">${g.commits}</span> commit · <span class="mut">${esc(g.rama||'?')}</span>` : '<span class="mut">no es repo</span>';
    const vaultL = v.tieneVault ? `<span class="mono">${v.notas}</span> notas <span class="mut">· ${v.rotos} rotos</span>` : '<span class="mut">sin vault</span>';
    const backL = !b.existe?'<span class="mut">sin carpeta</span>':(b.dias==null?'<span class="mut">vacía</span>':`${esc(hace(b.ultimo))}`);
    const stk = (p.stack&&p.stack.lenguajes&&p.stack.lenguajes.length)
      ? p.stack.lenguajes.slice(0,2).map(l=>`<span class="pill cyan">${esc(l)}</span>`).join('')
      + (p.deploy&&p.deploy.length?p.deploy.map(d=>`<span class="pill teal">${esc(d)}</span>`).join(''):'')
      : (p.deploy&&p.deploy.length?p.deploy.map(d=>`<span class="pill teal">${esc(d)}</span>`).join(''):'<span class="pill dim">estático</span>');
    const arq=ARQUETIPOS[e.arq]||ARQUETIPOS.simple;
    return `<div class="card s-${SEVAB[e.sev]}" data-i="${i}" role="button" tabindex="0" aria-label="${esc(p.nombre)} — ${arq.label} — ${SEVTXT[e.sev]}" style="--s:${s};animation-delay:${i*45}ms">
      <div class="chead"><span class="dot"></span><span class="ctitle" title="${esc(p.nombre)}">${esc(p.nombre)}</span>
        <span class="pill ${arq.pill}" title="${esc(arq.desc)}">${arq.label}</span></div>
      <div class="rows">
        <div class="row"><span class="ric"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><path d="M18 9a9 9 0 0 1-9 9"/></svg></span><span class="k">Git</span><span>${commit}</span></div>
        <div class="row"><span class="ric"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M3 5v14a9 3 0 0 0 18 0V5"/><path d="M3 12a9 3 0 0 0 18 0"/></svg></span><span class="k">Vault</span><span>${vaultL}</span></div>
        <div class="row"><span class="ric"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="5" rx="1"/><path d="M4 9v9a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9"/><path d="M10 13h4"/></svg></span><span class="k">Backup</span><span>${backL}</span></div>
        <div class="row"><span class="ric"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22v-5"/><path d="M9 8V2"/><path d="M15 8V2"/><path d="M18 8v5a4 4 0 0 1-4 4h-4a4 4 0 0 1-4-4V8Z"/></svg></span><span class="k">Stack</span><span class="chips">${stk}</span></div>
      </div>
      <div class="reason-line ${e.al.length?'':'ok'}">${e.al.length?'<span class="dotr"></span>':''}${esc(motivo)}</div>
    </div>`;
  }).join('');
}
