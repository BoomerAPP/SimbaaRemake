/* Keep overlays attached to the actual header, including the optional music row. */
(() => {
  const root=document.documentElement,header=document.querySelector('.site-header'),toolbar=document.querySelector('.site-header .topbar'),nav=document.querySelector('body>.bottom-nav');
  if(!header)return;
  let scheduled=false;
  const measure=()=>{
    scheduled=false;
    root.style.setProperty('--chrome-height',`${Math.ceil(header.getBoundingClientRect().height)}px`);
    root.style.setProperty('--toolbar-height',`${Math.ceil(toolbar?.getBoundingClientRect().height||header.getBoundingClientRect().height)}px`);
    const viewport=window.visualViewport;
    root.style.setProperty('--viewport-height',`${Math.round(viewport?.height||innerHeight)}px`);
    const visible=nav&&getComputedStyle(nav).display!=='none';
    root.style.setProperty('--nav-clearance',visible?`${Math.ceil(innerHeight-nav.getBoundingClientRect().top)+8}px`:'16px');
  };
  const schedule=()=>{if(!scheduled){scheduled=true;requestAnimationFrame(measure);}};
  if('ResizeObserver' in window){const observer=new ResizeObserver(schedule);observer.observe(header);if(toolbar)observer.observe(toolbar);if(nav)observer.observe(nav);}
  else new MutationObserver(schedule).observe(header,{childList:true,subtree:true,attributes:true});
  addEventListener('resize',schedule,{passive:true});addEventListener('pageshow',schedule);
  window.visualViewport?.addEventListener('resize',schedule,{passive:true});
  measure();
})();
