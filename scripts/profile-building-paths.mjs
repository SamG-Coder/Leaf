import {chromium} from 'playwright';
import {writeFile} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try {
 const page=await browser.newPage(); const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.route('**/performance-check.html',route=>route.fulfill({contentType:'text/html',body:'<canvas id="canvas" width="1024" height="768"></canvas>'}));
 if(process.argv.includes('--baseline'))for(const file of ['building-renderer.js','map-renderer.js','scene-camera.js']){const body=execFileSync('git',['show','804d52b:src/'+file],{encoding:'utf8'});await page.route('**/src/'+file,route=>route.fulfill({contentType:'text/javascript',body}));}
 await page.goto('http://127.0.0.1:5197/performance-check.html');
 page.on('console',msg=>{if(msg.type()==='log')console.log(msg.text());});
 const result=await page.evaluate(async()=>{
  const {MapRenderer}=await import('./src/map-renderer.js'),{emptyMap}=await import('./src/map-model.js'),{newBuilding}=await import('./src/building-model.js'),{newPath,validatePaths}=await import('./src/path-model.js');
  const r=await MapRenderer.create(document.querySelector('canvas'),e=>{throw e;});
  let cpu={};for(const [obj,name,label] of [[r,'updatePaths','pathUpload'],[r,'preparePlacements','placements'],[r.buildings,'prepare','buildingPrepare'],[r.buildings,'prepareShadow','shadowPrepare']]){const original=obj[name];obj[name]=function(...args){const start=performance.now();try{return original.apply(this,args);}finally{cpu[label]=(cpu[label]??0)+performance.now()-start;}};}
  const stat=a=>{const s=[...a].sort((a,b)=>a-b);return {p50:s[Math.floor(s.length*.5)],p95:s[Math.floor(s.length*.95)],max:s.at(-1)};};
  const base={position:[0,18,-45],yaw:0,pitch:-.28,pivot:[0,0,0],distance:50,fov:60,aspect:4/3,grid:false,anime:true,groundCover:true,waterTime:0,environmentTime:0,shadowStrength:.85};
  function fixture(buildings,paths){const m=emptyMap();m.extent=1024;m.environment.enabled=false;m.light={azimuth:35,elevation:40};m.buildings=Array.from({length:buildings},(_,i)=>{const p=newBuilding(i+1,i%13,((i%32)-16)*6,(Math.floor(i/32)-8)*6);p.material=i%7;p.rotation=(i%4)*90;return p;});m.paths=Array.from({length:paths},(_,i)=>{const p=newPath(i+1,0,0,m.extent);p.material=i%14;p.nodes=Array.from({length:32},(_,j)=>({id:j+1,x:(j-16)*20,z:(i-paths/2)*8}));p.edges=p.nodes.slice(1).map((n,j)=>({id:j+1,a:j+1,b:j+2,x:n.x-10,z:n.z+(j%2?8:-8)}));return p;});m.paths=validatePaths(m.paths,m.extent);return m;}
  const hash=async b=>{const a=await r.runtime.read(b,Uint32Array);return Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',a)),v=>v.toString(16).padStart(2,'0')).join('');};
  const results=[];
  for(const [name,nb,np,mode] of [['empty',0,0,'orbit'],['buildings-256-cached',256,0,'static'],['buildings-256-orbit',256,0,'orbit'],['buildings-2048-fast-flight',2048,0,'flight'],['buildings-2048-close',2048,0,'close'],['building-edit',256,0,'edit'],['building-sun-change',256,0,'sun'],['paths-14-orbit',0,14,'orbit'],['paths-32-orbit',0,32,'orbit'],['path-node-edit',0,32,'edit'],['combined-flight',512,14,'flight']]){
   const m=fixture(nb,np),frames=[],stages=[],checkpoints=[],visibleCounts=[];let v={...base};
   for(let i=0;i<8;i++)await r.render(m,new Set(),v);
   const shadowStart=r.buildings.shadowUpdates;
   for(let i=0;i<72;i++){
    cpu={};let validation=0;const start=performance.now();
    if(mode==='orbit'){const a=i/72*Math.PI*2;v={...base,position:[Math.sin(a)*45,18,-Math.cos(a)*45],yaw:-a};}
    if(mode==='flight'){const x=-450+i/71*900;v={...base,position:[x,8,-20],pivot:[x+50,0,-20],yaw:Math.PI/2};}
    if(mode==='close')v={...base,position:[Math.sin(i*.08)*3,1.8,Math.cos(i*.08)*3],yaw:i*.08,pitch:0};
    if(mode==='sun')m.light={azimuth:i*5,elevation:40};
    if(mode==='edit'&&nb)m.buildings=m.buildings.map((p,j)=>j? p:{...p,x:-2+i*.04,z:0});
    if(mode==='edit'&&np){const t=performance.now();m.paths=validatePaths(m.paths.map((p,j)=>j?p:{...p,edges:p.edges.map((e,k)=>k?e:{...e,z:Math.sin(i*.1)*10})}),m.extent);validation=performance.now()-t;}
    await r.render(m,new Set(),v);frames.push({total:performance.now()-start,...cpu,validation});visibleCounts.push(r.buildings.count);
    if(i%12===0)checkpoints.push({frame:i,colour:await hash(r.output),depth:await hash(r.buffers.depth),picks:await hash(r.buffers.picks),shadow:await hash(r.buildings.shadow)});
   }
   for(let i=0;i<5;i++){await r.render(m,new Set(),{...v,profile:true});stages.push({...r.profile});}
   const sums=Object.fromEntries(['total','pathUpload','placements','buildingPrepare','shadowPrepare','validation'].map(k=>[k,stat(frames.map(f=>f[k]??0))]));
   const stage=Object.fromEntries(['paths','prepare','ground','geometry','buildings','water','shadows','weather','post','total'].map(k=>[k,stat(stages.map(s=>s[k]??0))]));
   const item={name,checkpoints,buildings:nb,paths:np,segments:r.pathIndex.segments.length,maxPathCell:Math.max(...r.pathIndex.cells.map(c=>c.length)),visibleBuildings:{min:Math.min(...visibleCounts),max:Math.max(...visibleCounts)},shadowUpdates:r.buildings.shadowUpdates-shadowStart,samples:frames.length,timing:sums,isolatedStages:stage};results.push(item);console.log(JSON.stringify(item));
  }
  // Profiling itself must leave final colour, geometry depth and picking identical.
  const parityMap=fixture(128,14),digest=async()=>{const out={};for(const [k,b] of [['colour',r.output],['depth',r.buffers.depth],['picks',r.buffers.picks],['shadow',r.buildings.shadow]]){const a=await r.runtime.read(b,Uint32Array);out[k]=Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',a)),v=>v.toString(16).padStart(2,'0')).join('');}return out;};
  await r.render(parityMap,new Set(),base);const normal=await digest();await r.render(parityMap,new Set(),{...base,profile:true});const profiled=await digest();
  return {resolution:[1024,768],userAgent:navigator.userAgent,adapter:Object.fromEntries(["vendor","architecture","device","description"].map(k=>[k,r.runtime.device.adapterInfo?.[k]??"unavailable"])),results,parity:{normal,profiled,equal:JSON.stringify(normal)===JSON.stringify(profiled)}};
 });
 if(errors.length)throw Error(errors.join('\n'));if(!result.parity.equal)throw Error('Profiler changed output');
 await writeFile(process.argv[2]??'artifacts/building-path-performance.json',JSON.stringify(result,null,2));
} finally {await browser.close();}
