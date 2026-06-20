/* ============================================================================
   main.js — Cableado: navegación entre vistas, apertura del drawer, teclado,
   trampa de foco y arranque (render). Carga el último.
   ============================================================================ */

/* ---------- navegación / eventos ---------- */
function setVista(v){
  VISTA=v;
  $('view-control').classList.toggle('hidden', v!=='control');
  $('view-grid').classList.toggle('hidden', v!=='grid');
  document.querySelectorAll('.nav-btn[data-view]').forEach(b=>{ const on=b.dataset.view===v; b.classList.toggle('active', on); b.setAttribute('aria-pressed', on); });
  if(v==='control') requestAnimationFrame(drawLinks);
}
document.querySelectorAll('.nav-btn[data-view]').forEach(b=>b.onclick=()=>setVista(b.dataset.view));
document.addEventListener('click', ev=>{
  // botones genéricos "copiar este texto literal" (p. ej. el comando de refresco o un prompt de acción)
  const cp=ev.target.closest('[data-copytxt]'); if(cp){ ev.preventDefault(); copiar(cp.getAttribute('data-copytxt')); return; }
  const n=ev.target.closest('.node,.card,.cola-item'); if(n && n.dataset.i!=null){ openDrawer(Number(n.dataset.i)); }
});
$('backdrop').onclick=closeDrawer;

/* ---------- barra de filtros de la cuadrícula (#29) ---------- */
(function(){
  const q=$('q'), solo=$('soloAlertas');
  if(q) q.oninput=()=>{ GQ=q.value; renderGrid(); };
  if(solo) solo.onchange=()=>{ GSOLO=solo.checked; renderGrid(); };
  document.querySelectorAll('.gsort').forEach(b=>b.onclick=()=>{
    GSORT=b.dataset.sort;
    document.querySelectorAll('.gsort').forEach(x=>x.classList.toggle('active', x===b));
    renderGrid();
  });
})();

/* ---------- refresco (#25): copia el comando de re-escaneo al portapapeles ---------- */
$('reBtn').onclick=()=>{
  copiar('powershell -ExecutionPolicy Bypass -File ".\\Escanear-Flota.ps1" -Abrir');
  showToast('Comando de refresco copiado — pégalo en una terminal (o doble-clic en Abrir-Panel.cmd)');
};
document.addEventListener('keydown', ev=>{
  if(ev.key==='Escape'){ closeDrawer(); return; }
  if(ev.key==='Enter' || ev.key===' '){
    const el=document.activeElement;
    if(el && el.classList && el.classList.contains('card') && el.dataset.i!=null){ ev.preventDefault(); openDrawer(Number(el.dataset.i)); }
  }
});
// trampa de foco dentro del drawer abierto
$('drawer').addEventListener('keydown', ev=>{
  if(ev.key!=='Tab' || !$('drawer').classList.contains('on')) return;
  const f=$('drawer').querySelectorAll('a[href],button:not([disabled]),[tabindex]:not([tabindex="-1"])');
  if(!f.length) return;
  const first=f[0], last=f[f.length-1];
  if(ev.shiftKey && document.activeElement===first){ last.focus(); ev.preventDefault(); }
  else if(!ev.shiftKey && document.activeElement===last){ first.focus(); ev.preventDefault(); }
});
window.addEventListener('resize', ()=>{ if(VISTA==='control') drawLinks(); });

render();
