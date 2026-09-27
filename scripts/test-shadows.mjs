import {readyEditor} from './editor-test-helpers.mjs';
import {chromium} from 'playwright';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try{
 const page=await browser.newPage({viewport:{width:1024,height:768}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:5197/editor.html');await page.waitForFunction(()=>window.mapDiagnostics?.ready);await readyEditor(page);
 const result=await page.evaluate(async()=>{
  const {MapRenderer}=await import('./src/map-renderer.js');const {emptyMap}=await import('./src/map-model.js');
  const canvas=document.createElement('canvas');canvas.width=1024;canvas.height=768;canvas.id='shadowTest';canvas.style.cssText='position:fixed;inset:0;z-index:99999';document.body.append(canvas);
  const r=await MapRenderer.create(canvas,e=>{throw e;});const m=emptyMap();m.extent=128;m.light={azimuth:0,elevation:40};m.objects=[{id:1,preset:0,x:0,z:0,scale:1,rotation:37,seed:4294967294,visible:true}];
  const v={position:[16,14,-20],yaw:-.675,pitch:-.46,pivot:[0,2,0],distance:28,fov:60,aspect:4/3,grid:false,anime:false,groundCover:false,waterTime:0,environmentTime:0,shadowStrength:.85};
  const read=async()=>({pixels:await r.runtime.read(r.buffers.pixels,Uint32Array),depth:await r.runtime.read(r.buffers.depth,Uint32Array),picks:await r.runtime.read(r.buffers.picks,Uint32Array)});
  await r.render(m,new Set(),{...v,shadows:false});const off=await read();await r.render(m,new Set(),v);const on=await read();let changed=0,skyChanged=0,groundChanged=0,depthChanged=0,picksChanged=0;for(let i=0;i<on.pixels.length;i++){if(on.depth[i]!==off.depth[i])depthChanged++;if(on.picks[i]!==off.picks[i])picksChanged++;if(on.pixels[i]!==off.pixels[i]){changed++;if(off.depth[i]===4294967295)skyChanged++;if(off.picks[i]===0&&off.depth[i]!==4294967295)groundChanged++;}}
  const count=r.shadowUpdates,gen=r.generations;await r.render(m,new Set(),v);const cached=r.shadowUpdates===count&&r.generations===gen;
  const centroid=async()=>{const map=await r.runtime.read(r.shadowBuffer,Uint32Array);let x=0,z=0,n=0;for(let i=0;i<map.length;i++)if(map[i]){n++;x+=r.shadowRegion.originX+(i%1024+.5)*r.shadowRegion.cell;z+=r.shadowRegion.originZ+(Math.floor(i/1024)+.5)*r.shadowRegion.cell;}return {x:x/n,z:z/n,n};};
  const a=await centroid();m.light={azimuth:180,elevation:40};await r.render(m,new Set(),v);const b=await centroid();
  m.light={azimuth:0,elevation:15};const away={...v,position:[-12,4,0],yaw:-Math.PI/2,pitch:-.35};await r.render(m,new Set(),{...away,shadows:false});const awayOff=await read();await r.render(m,new Set(),away);const awayOn=await read();let offscreenPixels=0;for(let i=0;i<awayOn.pixels.length;i++)if(awayOn.pixels[i]!==awayOff.pixels[i]&&awayOn.picks[i]===0)offscreenPixels++;const offscreen={rendered:r.rendered,casters:r.shadowCasterCount,changed:offscreenPixels};
  const beforeTerrain=r.shadowUpdates;m.terrain=m.terrain.map(()=>2);await r.render(m,new Set(),v);const terrainInvalidated=r.shadowUpdates>beforeTerrain;m.terrain=m.terrain.map(()=>0);
  const beforeEdit=r.shadowUpdates;m.objects=m.objects.map(o=>({...o,visible:false}));await r.render(m,new Set(),v);const removed=await centroid();const invalidated=r.shadowUpdates>beforeEdit;
  m.objects=m.objects.map(o=>({...o,visible:true}));m.light={azimuth:0,elevation:40};
  const samples=[];for(let n=0;n<8;n++){await r.render(m,new Set(),{...v,profile:true,waterTime:n*.15,environmentTime:n*.15});samples.push(r.profile.shadows);}
  await r.render(m,new Set(),{...v,anime:true,animeMode:'painted'});
  window.shadowFixture={r,m,v};return {offscreen,terrainInvalidated,changed,skyChanged,groundChanged,depthChanged,picksChanged,cached,centroids:[a,b],removed,invalidated,samples};
 });
 await page.locator('#shadowTest').screenshot({path:'artifacts/shadows-painted.png'});
 assert.equal(result.offscreen.rendered,0);assert(result.offscreen.casters===1&&result.offscreen.changed>100);assert(result.terrainInvalidated);assert(result.groundChanged>100);assert.equal(result.skyChanged,0);assert.equal(result.depthChanged,0);assert.equal(result.picksChanged,0);assert(result.cached);assert(result.centroids[0].x<-1&&result.centroids[1].x>1);assert.equal(result.removed.n,0);assert(result.invalidated);assert.deepEqual(errors,[]);
 const island=await page.evaluate(async()=>{
 const {r,v}=window.shadowFixture;const {islandExample}=await import('./src/island-example.js');const m=islandExample();m.environment.enabled=false;
 const camera={...v,position:[220,125,390],pivot:[0,25,0],yaw:Math.PI+.51,pitch:-.30,distance:390,anime:true,shadowStrength:.65};
 for(let n=0;n<4;n++)await r.render(m,new Set(),camera);
 const frames=[];for(let n=0;n<12;n++){await r.render(m,new Set(),{...camera,profile:true,environmentTime:n*.15});frames.push({total:r.profile.total,shadow:r.profile.shadows});}
 const styles=[];for(const animeMode of ['painted','cel','watercolour']){await r.render(m,new Set(),{...camera,animeMode});styles.push(animeMode);}
 await r.render(m,new Set(),camera);return {casters:r.shadowCasterCount,frames,styles};
 });await page.locator('#shadowTest').screenshot({path:'artifacts/shadows-island.png'});
 assert.deepEqual(errors,[]);
 await writeFile('artifacts/shadows-validation.json',JSON.stringify({result,island,errors},null,2));console.log(JSON.stringify({result,island,errors}));
}finally{await browser.close();}
