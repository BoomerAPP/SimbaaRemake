/* Deterministic UI-controller tests. No live backend, network or real audio. */
const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const path=require('node:path');
const source=fs.readFileSync(process.env.SIMBAA_TEST_SOURCE||path.join(__dirname,'../app.js'),'utf8').replace("  window.addEventListener('DOMContentLoaded',init);",'  globalThis.testAPI={state,initMusicPlayer,updateMusicIsland,toggleMusic,playMusicIndex,initSiteNotices,toggleUpdates,togglePreferences};');
class Element {
 constructor(id=''){this.id=id;this.hidden=false;this.inert=false;this.value='20';this.textContent='';this.attributes={};this.events={};this.classSet=new Set();this.classList={add:(x)=>this.classSet.add(x),remove:(x)=>this.classSet.delete(x),contains:x=>this.classSet.has(x),toggle:(x,force)=>{const add=force??!this.classSet.has(x);if(add)this.classSet.add(x);else this.classSet.delete(x);return add;}};this.tagName='DIV';this.children=[];}
 setAttribute(k,v){this.attributes[k]=String(v);if(k==='hidden')this.hidden=true;}
 removeAttribute(k){delete this.attributes[k];if(k==='hidden')this.hidden=false;}
 addEventListener(k,f){(this.events[k]??=[]).push(f);}
 querySelector(s){return s==='.modal-close'?this.close:null;}
 querySelectorAll(){return [];}
 getClientRects(){return [{}];}
 focus(){this.doc.activeElement=this;}
 appendChild(e){e.doc=this.doc;this.children.push(e);if(e.id)this.doc.elements.set(e.id,e);}
}
function setup({blocked=false,enabled=true,paused=false,spotify=false}={}){
 const elements=new Map();const document={elements,events:{},querySelector(s){return s[0]==='#'?elements.get(s.slice(1))||null:null;},querySelectorAll(){return [];},addEventListener(k,f){(this.events[k]??=[]).push(f);},createElement(){const el=new Element();el.doc=this;return el;}};
 for(const id of ['simbaaMusicIsland','musicDock','musicBrandButton','musicIslandTitle','musicIslandStatus','musicPopoverTitle','musicPopoverMeta','musicVolumeControl','musicVolumeValue','musicVolumeWrap','musicPlayButton','musicPopoverPlay','musicSpotifyLink','musicSpotifyEmbed','musicPopoverList','musicPopover','musicCollapseButton','musicPopoverClose','musicPrevButton','musicNextButton','updatesPanel','preferencesPanel','updatesButton','preferencesButton','updatesClose','preferencesClose','themeToggle','languageToggle','main']){const el=new Element(id);el.doc=document;elements.set(id,el);}
 document.body=new Element('body');document.body.doc=document;document.body.children=['main','simbaaMusicIsland','updatesPanel','preferencesPanel','updatesButton','preferencesButton'].map(x=>elements.get(x));document.activeElement=elements.get('preferencesButton');
 for(const id of ['updatesPanel','preferencesPanel'])elements.get(id).close=elements.get(id==='updatesPanel'?'updatesClose':'preferencesClose');
 const storage=new Map(paused?[['simbaa-music-paused','1']]:[]);const localStorage={getItem:()=>null,setItem(){}};const sessionStorage={getItem:k=>storage.get(k)||null,setItem:(k,v)=>storage.set(k,v)};
 let plays=0;
 class Audio {constructor(){this.paused=true;this.events={};this.currentTime=0;}addEventListener(k,f){(this.events[k]??=[]).push(f);}async play(){plays++;if(blocked){const e=new Error();e.name='NotAllowedError';throw e;}this.paused=false;this.emit('play');}pause(){this.paused=true;this.emit('pause');}emit(k){for(const f of this.events[k]||[])f();}removeAttribute(){}load(){}}
 const context={window:{addEventListener(){},SIMBAA_SUPABASE:{}},document,localStorage,sessionStorage,Audio,URL,URLSearchParams,console,setTimeout,clearTimeout};vm.createContext(context);vm.runInContext(source,context);const api=context.testAPI;api.state.settings={...api.state.settings,music_enabled:enabled,music_playlist:[{title:'Test track',url:'https://example.test/track.mp3',source_type:spotify?'spotify':'url',spotify_embed_url:spotify?'https://open.spotify.com/embed/track/abc':'',default:true}],music_volume:20};return {api,e:id=>elements.get(id),document,plays:()=>plays,storage};
}
(async()=>{
 let t=setup();t.api.initMusicPlayer();await Promise.resolve();assert.equal(t.plays(),1);assert.equal(t.e('musicPlayButton').textContent,'Ⅱ');await t.api.toggleMusic();assert.equal(t.e('musicPlayButton').textContent,'▶');assert.equal(t.storage.get('simbaa-music-paused'),'1');await t.api.toggleMusic();assert.equal(t.e('musicPlayButton').attributes['aria-label'],'Jeda musik');
 t.e('musicVolumeControl').events.input[0]({target:{value:'67'}});t.api.updateMusicIsland();assert.equal(t.e('musicVolumeControl').value,'67');const count=t.e('musicPlayButton').events.click.length;t.api.initMusicPlayer();assert.equal(t.e('musicPlayButton').events.click.length,count);
 t=setup({blocked:true});t.api.initMusicPlayer();await new Promise(setImmediate);assert.match(t.e('musicIslandStatus').textContent,/Autoplay diblokir/);assert.equal(t.e('musicPlayButton').textContent,'▶');
 t=setup({enabled:false});t.api.initMusicPlayer();assert.equal(t.plays(),0);assert.equal(t.e('musicDock').hidden,true);
 t=setup({paused:true});t.api.initMusicPlayer();assert.equal(t.plays(),0);
 t=setup({spotify:true});t.api.initMusicPlayer();assert.equal(t.plays(),0);assert.equal(t.e('musicPlayButton').disabled,true);
 t=setup();t.api.initSiteNotices();t.api.togglePreferences(true);assert.equal(t.e('preferencesPanel').attributes['aria-hidden'],'false');assert.equal(t.e('main').inert,true);assert.equal(t.document.activeElement.id,'preferencesClose');t.api.toggleUpdates(true);assert.equal(t.e('preferencesPanel').attributes['aria-hidden'],'true');assert.equal(t.e('updatesPanel').attributes['aria-hidden'],'false');t.api.toggleUpdates(false);assert.equal(t.e('main').inert,false);assert.equal(t.document.activeElement.id,'preferencesButton');assert.equal(t.document.elements.get('sitePanelBackdrop').hidden,true);
 console.log('PASS: autoplay allowed/blocked, manual pause/resume, session pause, disabled music, Spotify controls, volume persistence, idempotent initialization, exclusive panels, focus and inert restoration.');
})().catch(e=>{console.error(e);process.exitCode=1;});
// Geometry controller: dynamic header row and mobile/laptop bottom clearance.
{
 const properties=new Map(),events={};let headerHeight=132,navVisible=true,navTop=770;
 const root={style:{setProperty:(k,v)=>properties.set(k,v)}};
 const header={getBoundingClientRect:()=>({height:headerHeight})},nav={getBoundingClientRect:()=>({top:navTop})};
 const context={document:{documentElement:root,querySelector:s=>s==='.site-header'?header:nav},window:{visualViewport:{height:844,addEventListener(){}}},innerHeight:844,getComputedStyle:()=>({display:navVisible?'grid':'none'}),addEventListener:(name,f)=>events[name]=f,requestAnimationFrame:f=>f(),ResizeObserver:class{observe(){}}};
 context.window.ResizeObserver=context.ResizeObserver;vm.createContext(context);vm.runInContext(fs.readFileSync(path.join(__dirname,'../chrome-layout-v30.js'),'utf8'),context);
 assert.equal(properties.get('--chrome-height'),'132px');assert.equal(properties.get('--nav-clearance'),'82px');
 headerHeight=80;navVisible=false;events.resize();assert.equal(properties.get('--chrome-height'),'80px');assert.equal(properties.get('--nav-clearance'),'16px');
 console.log('PASS: measured header geometry and mobile/laptop navigation clearance.');
}
