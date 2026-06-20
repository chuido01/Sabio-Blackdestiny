/* ============================================================================
   detalle.js — Panel lateral (drawer) con el detalle del proyecto seleccionado:
   pestañas Resumen · Stack · Agentes · Skills · MCP, acción recomendada y accesos.
   Usa el estado y las utilidades de vistas.js, y el motor de semaforo.js.
   ============================================================================ */
let LASTFOCUS=null;

function openDrawer(i){
  SEL=i; TAB='resumen'; LASTFOCUS=document.activeElement;
  renderDrawer();
  document.querySelectorAll('.node,.card').forEach(el=>el.classList.toggle('sel', el.dataset.i==String(i)));
  $('drawer').setAttribute('aria-label','Detalle: '+(PS[i]?PS[i].nombre:''));
  $('drawer').classList.add('on'); $('backdrop').classList.add('on');
  const c=$('drClose'); if(c) c.focus();
}
function closeDrawer(){
  if(SEL==null) return;
  SEL=null; $('drawer').classList.remove('on'); $('backdrop').classList.remove('on');
  document.querySelectorAll('.node.sel,.card.sel').forEach(el=>el.classList.remove('sel'));
  if(LASTFOCUS && LASTFOCUS.focus){ LASTFOCUS.focus(); LASTFOCUS=null; }
}

/* COPY_SVG (icono de copiar) se define en vistas.js (se carga antes) y se reutiliza aquí. */

function tabBtn(id,label,svg){ return `<button class="tab ${TAB===id?'active':''}" data-tab="${id}" role="tab" aria-selected="${TAB===id}">${svg}${label}</button>`; }
function chipList(arr,cls,vacio){ return (arr&&arr.length)?`<div class="chips">${arr.map(x=>`<span class="pill ${cls}">${esc(x)}</span>`).join('')}</div>`:`<div class="empty">${vacio}</div>`; }

function renderDrawer(){
  if(SEL==null) return;
  const p=PS[SEL], e=p._e, s=SEVCSS[e.sev];
  const g=p.git||{}, v=p.vault||{}, b=p.backup||{}, cm=p.claudeMd||{};
  const gc=FLOTA.globalClaude||{};
  const dr=$('drawer'); dr.style.setProperty('--s',s);

  // --- pestaña activa ---
  let body='';
  if(TAB==='resumen'){
    const ins=insightDe(e);
    body += ins ? `<div class="insight"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18h6"/><path d="M10 22h4"/><path d="M12 2a7 7 0 0 0-4 12.7c.6.5 1 1.3 1 2.1h6c0-.8.4-1.6 1-2.1A7 7 0 0 0 12 2Z"/></svg><div style="flex:1"><div class="it">Acción recomendada</div><div class="ix">${ins.accion}</div>${ins.kind?`<button class="copybtn pri" data-copy="${esc(ins.kind)}">${COPY_SVG}Copiar prompt de arreglo</button>`:''}</div></div>` : '';
    if(p.descripcion) body += `<div class="blocklabel">Descripción</div><div class="desc">${esc(p.descripcion)}</div>`;
    body += `<div class="blocklabel">Estado</div><div class="statgrid">
      <div class="stat"><div class="sl"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><path d="M18 9a9 9 0 0 1-9 9"/></svg>Git</div><div class="sv">${g.esRepo?`${g.commits} commits <span class="mut">· ${esc(g.rama||'?')}</span>`:'<span class="mut">no es repo</span>'}${g.sucio?`<br><span class="mut">${g.archivosSucios} sin commit</span>`:''}${g.sinPush>0?`<br><span class="mut">${g.sinPush} sin push</span>`:''}${g.esRepo&&g.ultimoCommit&&g.ultimoCommit.fecha?`<br><span class="mut">últ. ${esc(hace(g.ultimoCommit.fecha))}</span>`:''}</div></div>
      <div class="stat"><div class="sl"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M3 5v14a9 3 0 0 0 18 0V5"/><path d="M3 12a9 3 0 0 0 18 0"/></svg>Vault</div><div class="sv">${v.tieneVault?`${v.notas} notas <span class="mut">· ${v.rotos} rotos · ${v.huerfanas} huérf.</span>`:'<span class="mut">sin vault</span>'}${fedTxt(v)}</div></div>
      <div class="stat"><div class="sl"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="5" rx="1"/><path d="M4 9v9a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9"/><path d="M10 13h4"/></svg>Backup</div><div class="sv">${!b.existe?'<span class="mut">sin carpeta</span>':(b.dias==null?'<span class="mut">vacía</span>':`${esc(hace(b.ultimo))}<br><span class="mut">${b.archivos} arch.</span>`)}</div></div>
      <div class="stat"><div class="sl"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg>CLAUDE.md</div><div class="sv">${cm.existe?`${Math.round(cm.bytes/1024)} KB <span class="mut">· ${cm.lineas} líneas</span>`:'<span class="mut">no existe</span>'}</div></div>
    </div>`;
    body += `<div class="blocklabel">Señales</div>`;
    body += e.al.length ? `<div class="alist">${e.al.map(a=>`<div class="al ${SEVAB[a[0]]}"><i></i><span class="al-msg">${esc(a[1])}</span>${a[3]?`<button class="copybtn" data-copy="${esc(a[3])}" title="Copiar prompt de arreglo" aria-label="Copiar prompt de arreglo para: ${esc(a[1])}">${COPY_SVG}</button>`:''}</div>`).join('')}</div>`
                        : `<div class="okrow">✔ sin alertas — todo en orden</div>`;
    const tN=serieDe(p.nombre,'notas'), tR=serieDe(p.nombre,'rotos'), tC=serieDe(p.nombre,'commits');
    if(HISTORIAL && HISTORIAL.length>=2 && (tN.length>=2||tR.length>=2||tC.length>=2)){
      body += `<div class="blocklabel">Tendencia · últimos ${HISTORIAL.length} escaneos</div><div class="trend">`
        + trendRow('Notas',tN,'var(--teal)') + trendRow('Rotos',tR,'var(--ambar)') + trendRow('Commits',tC,'var(--cyan)')
        + `</div>`;
    }
  }
  else if(TAB==='stack'){
    const st=p.stack||{};
    body += `<div class="blocklabel">Lenguajes / runtime</div>${chipList(st.lenguajes,'cyan','Sin manifiestos detectados (app estática o sin build).')}`;
    body += `<div class="blocklabel">Paquetes notables</div>${chipList(st.paquetes,'purple','—')}`;
    body += `<div class="blocklabel">Despliegue</div>${chipList(p.deploy,'teal','Sin marcadores de despliegue (.vercel / supabase).')}`;
  }
  else if(TAB==='agentes'){
    const own=(p.agentesSkills&&p.agentesSkills.agentes)||[];
    body += `<div class="blocklabel">Agentes propios del proyecto</div>${chipList(own,'cyan','Ninguno propio — usa la flota global.')}`;
    body += `<div class="blocklabel">Disponibles en la flota · ~/.claude</div>${chipList(gc.agentes,'purple','—')}`;
  }
  else if(TAB==='skills'){
    const own=(p.agentesSkills&&p.agentesSkills.skills)||[];
    const cmd=(p.agentesSkills&&p.agentesSkills.comandos)||[];
    body += `<div class="blocklabel">Skills / comandos propios</div>${chipList(own.concat(cmd),'cyan','Ninguno propio — usa la flota global.')}`;
    body += `<div class="blocklabel">Skills de la flota · ~/.claude</div>${chipList(gc.skills,'purple','—')}`;
    body += `<div class="blocklabel">Comandos de la flota</div>${chipList(gc.comandos,'teal','—')}`;
  }
  else if(TAB==='mcp'){
    body += `<div class="blocklabel">Servidores MCP del proyecto</div>${chipList(p.mcps,'cyan','Sin .mcp.json de proyecto.')}`;
  }

  // --- acciones ---
  const url=repoUrl(g.remoto);
  const repoBtn = url ? `<a class="btn gho" href="${esc(url)}" target="_blank" rel="noopener"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6"/><path d="M10 14 21 3"/><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/></svg>Repo</a>`
                       : `<span class="btn gho dis"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6"/><path d="M10 14 21 3"/></svg>Sin remoto</span>`;

  dr.innerHTML = `
    <div class="dr-head">
      <div class="dr-ring" style="--s:${s}"><span class="node-num" style="color:${s}">${esc(numProy(p,SEL))}</span></div>
      <div class="dr-titles">
        <h3>${esc(p.nombre)}</h3>
        <div class="dr-meta">${esc(p.ruta)}</div>
        <div class="dr-badges">
          <div class="statepill" style="--s:${s}"><i></i>${SEVTXT[e.sev]}</div>
          <span class="pill ${(ARQUETIPOS[e.arq]||ARQUETIPOS.simple).pill}" title="${esc((ARQUETIPOS[e.arq]||ARQUETIPOS.simple).desc)}">${(ARQUETIPOS[e.arq]||ARQUETIPOS.simple).label}</span>
          ${e.riesgo>0?`<span class="pill dim" title="Riesgo ponderado: severidad de las señales × criticidad del arquetipo">riesgo ${e.riesgo}</span>`:''}
        </div>
      </div>
      <button class="dr-close" id="drClose"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="M6 6l12 12"/></svg></button>
    </div>
    <div class="tabs" role="tablist">
      ${tabBtn('resumen','Resumen','<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18"/><path d="M9 21V9"/></svg>')}
      ${tabBtn('stack','Stack','<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2 2 7l10 5 10-5z"/><path d="m2 17 10 5 10-5"/><path d="m2 12 10 5 10-5"/></svg>')}
      ${tabBtn('agentes','Agentes','<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="10" rx="2"/><circle cx="12" cy="5" r="2"/><path d="M12 7v4"/><path d="M8 16h.01"/><path d="M16 16h.01"/></svg>')}
      ${tabBtn('skills','Skills','<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3l1.9 4.6L18 9l-4.1 1.4L12 15l-1.9-4.6L6 9l4.1-1.4z"/><path d="M19 14l.7 1.7L21 16l-1.3.3L19 18l-.7-1.7L17 16l1.3-.3z"/></svg>')}
      ${tabBtn('mcp','MCP','<svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22v-5"/><path d="M9 8V2"/><path d="M15 8V2"/><path d="M18 8v5a4 4 0 0 1-4 4h-4a4 4 0 0 1-4-4V8Z"/></svg>')}
    </div>
    <div class="dr-body">
      ${body}
      <div class="actions">
        ${repoBtn}
        <a class="btn gho" href="${esc(fileUrl(p.ruta))}" target="_blank" rel="noopener"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>Carpeta</a>
        <a class="btn gho" href="vscode://file/${encodeURI(String(p.ruta).replace(/\\/g,'/'))}"><svg class="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>VS Code</a>
      </div>
    </div>`;

  $('drClose').onclick=closeDrawer;
  dr.querySelectorAll('.tab').forEach(t=>t.onclick=()=>{TAB=t.dataset.tab; renderDrawer();});
  dr.querySelectorAll('[data-copy]').forEach(b=>b.onclick=(ev)=>{ ev.stopPropagation(); copiarPromptAlerta(SEL, b.dataset.copy); });
}
