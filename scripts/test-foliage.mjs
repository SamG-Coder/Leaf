import {chromium} from 'playwright';
import {writeFile,mkdir} from 'node:fs/promises';
await mkdir('artifacts/species',{recursive:true});
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
const errors=[];
try{
 const page=await browser.newPage({viewport:{width:800,height:800}});page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
 await page.goto('http://127.0.0.1:5197/profile.html');
 await page.evaluate(async()=>{
  const {FoliageSystem}=await import('./src/foliage-system.js');window.fs=await FoliageSystem.create({width:768,height:768,onError:e=>console.error(e)});window.presets=(await import('./src/species.js')).PRESETS;
  document.body.innerHTML='<canvas width="768" height="768"></canvas>';document.body.style.margin='0';window.ctx=document.querySelector('canvas').getContext('webgpu');ctx.configure({device:fs.runtime.device,format:'rgba8unorm',usage:GPUTextureUsage.COPY_DST|GPUTextureUsage.RENDER_ATTACHMENT,alphaMode:'opaque'});
  window.digest=async a=>Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',a)),b=>b.toString(16).padStart(2,'0')).join('');
 });
 const results=[];
 for(let id=0;id<121;id++){
  const result=await page.evaluate(async id=>{
   fs.configure({preset:id,count:100000,seed:42,bins:8}).setLight({azimuth:305,elevation:40});
   const opts={scale:id===10?85:id>=11?150:80,tilt:id>=111?-.45:id>=101?-.85:id>=81?-.5:id>=71?-.35:id>=61?-.5:id>=51?.16:id===10?-.65:id>=41?.65:id>=31?.4:.16,wind:0,time:0};
   fs.render(opts);await fs.runtime.idle();const p=await fs.read('pos'),nm=await fs.read('normal'),sh=await fs.read('shape');
   if(!p.every(Number.isFinite)||!nm.every(Number.isFinite)||!sh.every(Number.isFinite))throw Error('Nonfinite geometry');
   const geometryHash=await digest(p),generations=fs.stats.generations;
   fs.setLight({azimuth:120,elevation:20});fs.render(opts);await fs.runtime.idle();if(await digest(await fs.read('pos'))!==geometryHash||fs.stats.generations!==generations)throw Error('Lighting regenerated geometry');
   fs.configure({seed:17});fs.render(opts);await fs.runtime.idle();if(await digest(await fs.read('pos'))===geometryHash)throw Error('Seed did not change geometry');
   fs.configure({seed:42});fs.render(opts);await fs.runtime.idle();if(await digest(await fs.read('pos'))!==geometryHash)throw Error('Seed not deterministic');
   fs.setLight({azimuth:305,elevation:40});fs.render(opts);await fs.runtime.idle();
   const pixelsHash=await digest(await fs.read('pixels'));fs.render({...opts,wind:.25,time:3});await fs.runtime.idle();const windChangesPixels=await digest(await fs.read('pixels'))!==pixelsHash;
   if(id<81&&!windChangesPixels)throw Error('Wind had no visible effect');if(id>=81&&windChangesPixels)throw Error('Rigid preset moved in wind');
   const rootsFixed=id===10?p.slice(0,400000).every((v,i)=>i%4!==1||v===0):null;if(id===10&&!rootsFixed)throw Error('Grass roots not at ground');
   const d=fs.runtime.device,q=d.createQuerySet({type:'timestamp',count:2}),qb=d.createBuffer({size:16,usage:GPUBufferUsage.QUERY_RESOLVE|GPUBufferUsage.COPY_SRC}),rb=d.createBuffer({size:16,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ}),times=[];
   for(let k=-3;k<15;k++){
    fs.render({...opts,timestampWrites:{querySet:q,beginningOfPassWriteIndex:0,endOfPassWriteIndex:1}});
    const e=d.createCommandEncoder();e.resolveQuerySet(q,0,2,qb,0);e.copyBufferToBuffer(qb,0,rb,0,16);d.queue.submit([e.finish()]);await rb.mapAsync(GPUMapMode.READ);const t=new BigUint64Array(rb.getMappedRange());if(k>=0)times.push(Number(t[1]-t[0])/1e6);rb.unmap();
   }q.destroy();qb.destroy();rb.destroy();times.sort((a,b)=>a-b);
   fs.render(opts);fs.present(ctx);await fs.runtime.idle();
   return {id,key:presets[id].key,name:presets[id].name,geometryHash,pixelsHash,windChangesPixels,rootsFixed,medianGpuMs:times[7]};
  },id);
  await page.locator('canvas').screenshot({path:`artifacts/species/${result.key}.png`});results.push(result);console.log(JSON.stringify(result));
 }
 const additional=await page.evaluate(async()=>{
  fs.configure({preset:'grass',count:200000,bins:16});fs.render({tilt:-.65});await fs.runtime.idle();const grassMax=(await fs.read('pos')).every(Number.isFinite);
  fs.configure({preset:9,count:200000});fs.render({scale:200});await fs.runtime.idle();
  for(const mode of [1,2,3]){fs.render({mode});await fs.runtime.idle();}
  const before=(await fs.read('pos')).slice(0,40000);fs.configure({count:10000});fs.render();await fs.runtime.idle();const after=await fs.read('pos');const prefixStable=before.every((v,i)=>v===after[i]);
  let rejected=0;for(const options of [{count:200001},{seed:-1},{bins:3},{preset:'missing'}]){try{fs.configure(options);}catch{rejected++;}}
  if(!grassMax||!prefixStable||rejected!==4)throw Error('Capacity/prefix/validation failure');
  fs.setInstances({positions:new Float32Array([0,3.6,0,.15]),normals:new Float32Array([0,0,.5,0]),shapes:new Float32Array([1,0,0,.5]),centers:new Float32Array(512)});
  const gen=fs.stats.generations;fs.render({mode:2});await fs.runtime.idle();const depth=await fs.read('depth');const customVisible=depth.some(v=>v!==4294967295);const noBranches=depth.every(v=>v===4294967295||(v&262143)===0);if(!customVisible||!noBranches||gen!==fs.stats.generations)throw Error('Custom instance render failed');
  fs.setLight({azimuth:80});fs.render();await fs.runtime.idle();if(gen!==fs.stats.generations)throw Error('Custom geometry overwritten');
  fs.useGpuInstances({count:1,kind:'leaves'});fs.render();await fs.runtime.idle();
  fs.useGenerated({preset:1,count:10000});fs.render();await fs.runtime.idle();if(gen===fs.stats.generations)throw Error('Generated switch failed');
  return {grassMax,prefixStable,rejectedInvalidOptions:rejected,customVisible,noBranches,customLightPreservesGeometry:true};
 });
 // Independently check prefix preservation without embedding huge arrays in reports.
 const prefix=await page.evaluate(async()=>{fs.configure({preset:0,count:10000});fs.render();await fs.runtime.idle();const a=(await fs.read('pos')).slice(0,40000);fs.configure({count:200000});fs.render();await fs.runtime.idle();const b=await fs.read('pos');return a.every((v,i)=>v===b[i]);});
 if(!prefix||errors.length)throw Error(JSON.stringify({prefix,errors}));
 await writeFile('artifacts/foliage-validation.json',JSON.stringify({resolution:[768,768],count:100000,results,prefixStable:prefix,additional,errors},null,2));
 await page.goto('http://127.0.0.1:5197/');await page.waitForFunction(()=>window.leafDiagnostics?.frames>5||window.leafDiagnostics?.errors.length);const ui=await page.evaluate(()=>leafDiagnostics);if(ui.errors.length)throw Error(JSON.stringify(ui));
 await page.locator('#species').selectOption('10');await page.waitForFunction(()=>leafDiagnostics.species===10&&leafDiagnostics.frames>10);await page.screenshot({path:'artifacts/grass-ui.png',fullPage:true});
 await page.setViewportSize({width:1500,height:900});await page.goto('http://127.0.0.1:5197/gallery.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/species-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/bushes.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/bush-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=20');await page.waitForFunction(()=>window.leafDiagnostics?.species===20&&leafDiagnostics.frames>5);if((await page.evaluate(()=>leafDiagnostics.errors)).length)throw Error('Bush UI failure');
 await page.goto('http://127.0.0.1:5197/flowers.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/flower-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=30');await page.waitForFunction(()=>window.leafDiagnostics?.species===30&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/ferns.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/fern-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=40');await page.waitForFunction(()=>window.leafDiagnostics?.species===40&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/moss.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/moss-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=50');await page.waitForFunction(()=>window.leafDiagnostics?.species===50&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/vines.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/vine-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=60');await page.waitForFunction(()=>window.leafDiagnostics?.species===60&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/grasses.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/grass-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=69');await page.waitForFunction(()=>window.leafDiagnostics?.species===69&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/crops.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/crop-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=75');await page.waitForFunction(()=>window.leafDiagnostics?.species===75&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/mushrooms.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/mushroom-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=81');await page.waitForFunction(()=>window.leafDiagnostics?.species===81&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/rocks.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/rock-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=97');await page.waitForFunction(()=>window.leafDiagnostics?.species===97&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/litter.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/litter-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=110');await page.waitForFunction(()=>window.leafDiagnostics?.species===110&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 await page.goto('http://127.0.0.1:5197/deadwood.html');await page.waitForFunction(()=>document.images.length===10&&[...document.images].every(i=>i.complete&&i.naturalWidth>0));await page.screenshot({path:'artifacts/deadwood-gallery.png',fullPage:true});
 await page.goto('http://127.0.0.1:5197/?preset=112');await page.waitForFunction(()=>window.leafDiagnostics?.species===112&&leafDiagnostics.frames>5);if(errors.length)throw Error(JSON.stringify(errors));
 console.log('121 presets, deterministic seeds, stable lighting geometry, wind, prefix and UI passed.');
}finally{await browser.close();}
