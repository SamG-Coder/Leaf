import {FoliageSystem} from './foliage-system.js';

import {PRESETS} from './species.js';

const $=id=>document.getElementById(id),canvas=document.querySelector('canvas');

for(const p of PRESETS){const o=document.createElement('option');o.value=p.id;o.textContent=p.name;$('species').append(o);}

const initialPreset=Number(new URLSearchParams(location.search).get('preset'));if(Number.isInteger(initialPreset)&&initialPreset>=0&&initialPreset<PRESETS.length)$('species').value=initialPreset;

const state={yaw:.3,tilt:Number($('species').value)>=111?-.45:Number($('species').value)>=101?-.85:Number($('species').value)>=81?-.5:Number($('species').value)>=71?-.35:Number($('species').value)>=61?-.5:Number($('species').value)>=51?.16:Number($('species').value)>=41?.65:Number($('species').value)>=31?.4:.16,scale:Number($('species').value)>=11?150:95,time:0};let running=true,last=performance.now();

if(Number($('species').value)===10){state.scale=105;state.tilt=-.65;}

window.leafDiagnostics={ready:false,errors:[],frames:0};

function fail(e){leafDiagnostics.errors.push(String(e));$('status').textContent=String(e);console.error(e);running=false;}

function update(){

 for(const id of ['count','sun','elevation','wind','autumn'])$(id+'Out').textContent=id==='count'?Number($(id).value).toLocaleString():$(id).value+(id==='sun'||id==='elevation'?'°':'');

 const p=PRESETS[Number($('species').value)];$('treeName').textContent=p.name;$('scientific').textContent=p.scientific;$('description').textContent=p.description;

 $('research').hidden=!p.source;if(p.source)$('research').href=p.source;$('autumn').disabled=!p.deciduous;

 const groups=128*Number($('bins').value)**2/2;$('groups').textContent=groups.toLocaleString();$('ratio').textContent=(Number($('count').value)/groups).toFixed(1)+'×';$('memory').textContent='9.6 MB';

}

for(const id of ['count','sun','elevation','bins','mode','wind','seed','animate','species','autumn'])$(id).addEventListener('input',()=>{if(id==='species'){state.scale=Number($('species').value)===10?105:Number($('species').value)>=11?150:95;state.tilt=Number($('species').value)===10?-.65:Number($('species').value)>=111?-.45:Number($('species').value)>=101?-.85:Number($('species').value)>=81?-.5:Number($('species').value)>=71?-.35:Number($('species').value)>=61?-.5:Number($('species').value)>=51?.16:Number($('species').value)>=41?.65:Number($('species').value)>=31?.4:.16;}update();});

$('newseed').onclick=()=>{$('seed').value=(Number($('seed').value)+7919)%1000000;};

let drag=null;canvas.onpointerdown=e=>{drag=[e.clientX,e.clientY];canvas.setPointerCapture(e.pointerId);};canvas.onpointerup=()=>drag=null;canvas.onpointercancel=()=>drag=null;

canvas.onpointermove=e=>{if(!drag)return;state.yaw+=(e.clientX-drag[0])*.008;state.tilt=Math.max(-.9,Math.min(.9,state.tilt+(e.clientY-drag[1])*.006));drag=[e.clientX,e.clientY];};

canvas.addEventListener('wheel',e=>{e.preventDefault();state.scale=Math.min(200,Math.max(55,state.scale*Math.exp(-e.deltaY*.001)));},{passive:false});

try{

 const system=await FoliageSystem.create({onError:fail});const runtime=system.runtime,device=runtime.device;

 const context=canvas.getContext('webgpu');context.configure({device,format:'rgba8unorm',alphaMode:'opaque',usage:GPUTextureUsage.COPY_DST|GPUTextureUsage.RENDER_ATTACHMENT});

 const diagnostics=window.leafDiagnostics;diagnostics.ready=true;const info=runtime.adapter?.info;diagnostics.adapter=info?{vendor:info.vendor,architecture:info.architecture}:null;

 window.leafTest={readGeometry:async()=>Array.from(await system.read('pos')),readNormals:async()=>Array.from(await system.read('normal')),readShapes:async()=>Array.from(await system.read('shape')),readLights:async()=>Array.from(await system.read('light')),readPixels:async()=>Array.from(await system.read('pixels'))};

 update();let smooth=0;

 async function frame(){if(!running)return;try{

  const start=performance.now(),dt=Math.min(.05,(start-last)/1000);last=start;if($('animate').checked)state.time+=dt;

  const n=Number($('count').value),seed=Math.max(0,Math.min(999999,Math.floor(Number($('seed').value)||0))),bins=Number($('bins').value),mode=Number($('mode').value),species=Number($('species').value);

  system.configure({count:n,seed,bins,preset:species}).setLight({azimuth:Number($('sun').value),elevation:Number($('elevation').value)});

  system.render({...state,wind:Number($('wind').value),mode,autumn:PRESETS[species].deciduous?Number($('autumn').value):0});system.present(context);await runtime.idle();

  const ms=performance.now()-start;smooth=smooth?smooth*.9+ms*.1:ms;Object.assign(diagnostics,system.stats,{n,seed,bins,mode,species,frameMs:smooth,groups:128*bins*bins/2});

  if(diagnostics.frames%15===0){$('frame').textContent=smooth.toFixed(1)+' ms';$('status').textContent=`${n.toLocaleString()} ${species>=111?'DEADWOOD SURFACE SAMPLES':species>=101?'GROUND LITTER SURFACE SAMPLES':species>=91?'ROCK / CRYSTAL SURFACE SAMPLES':species>=81?'MUSHROOM SURFACE SAMPLES':species>=71?'CROP SURFACE SAMPLES':species===10||species>=61?'BLADES / STALKS':species>=51?'VINE LEAF SAMPLES':species>=41?'MOSS SURFACE SAMPLES':species>=31?'FERN SURFACE SAMPLES':species>=21?'PETAL / LEAF SAMPLES':'FOLIAGE INSTANCES'} · GPU RESIDENT`;}

  requestAnimationFrame(frame);

 }catch(e){fail(e);}}

 requestAnimationFrame(frame);

}catch(e){fail(e);}

