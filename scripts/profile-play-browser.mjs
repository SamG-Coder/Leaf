import {readyEditor} from './editor-test-helpers.mjs';
import {chromium} from 'playwright';
import {writeFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try{
 const p=await browser.newPage({viewport:{width:1440,height:900}}),errors=[];p.on('pageerror',e=>errors.push(e.message));await p.goto('http://127.0.0.1:5197/editor.html');await p.waitForFunction(()=>window.mapDiagnostics?.ready);await readyEditor(p);
 await p.evaluate(async()=>{const {islandExample}=await import('./src/island-example.js');const m=islandExample();m.spawn={x:-140,z:115,yaw:0};editorTest.load(m);});await p.evaluate(()=>editorTest.idle());await p.click('#play');await p.waitForFunction(()=>!!document.pointerLockElement);await p.waitForTimeout(1500);
 assert.equal((await p.evaluate(()=>editorTest.playState())).swimming,false);const result={};for(const mode of ['standing','walking','sprinting','rotating']){
  if(mode==='walking'||mode==='sprinting')await p.keyboard.down('KeyW');if(mode==='sprinting')await p.keyboard.down('ShiftLeft');
  result[mode]=await p.evaluate(async(mode)=>{mapDiagnostics.timings=[];const samples=[];await new Promise(resolve=>{let remaining=150;function frame(now){if(mode==='rotating')document.dispatchEvent(new MouseEvent('mousemove',{movementX:2}));samples.push({time:now,position:editorTest.getView().position});if(--remaining)requestAnimationFrame(frame);else resolve();}requestAnimationFrame(frame);});return {frames:mapDiagnostics.timings.slice(),samples};},mode);
  await p.keyboard.up('KeyW');await p.keyboard.up('ShiftLeft');
 }
 assert.deepEqual(errors,[]);assert.deepEqual(await p.evaluate(()=>mapDiagnostics.errors),[]);
 const summaries={};for(const [mode,{frames}]of Object.entries(result)){const ms=frames.map(f=>f.total).sort((a,b)=>a-b);summaries[mode]={frames:ms.length,median:ms[Math.floor(ms.length*.5)],p95:ms[Math.floor(ms.length*.95)],max:ms.at(-1),generated:frames.reduce((n,f)=>n+f.generated,0),coverUpdates:frames.reduce((n,f)=>n+f.coverUpdates,0)};}
 await writeFile('artifacts/play-motion-browser.json',JSON.stringify({summaries,result,errors},null,2));console.log(JSON.stringify(summaries,null,2));
}finally{await browser.close();}
