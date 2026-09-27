import {chromium} from 'playwright';
import assert from 'node:assert/strict';
const b=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try {
 const p=await b.newPage({viewport:{width:1600,height:1000}});await p.goto('http://127.0.0.1:5197/editor.html');await p.waitForFunction(()=>window.editorTest);
 assert.equal(await p.locator('#animateWater').isChecked(),true);
 await p.evaluate(async()=>{const {emptyMap}=await import('./src/map-model.js');const m=emptyMap();m.extent=128;for(let z=0;z<65;z++)for(let x=0;x<65;x++)m.terrain[z*65+x]=(x-32)*.25+Math.sin(z*.25)*1.2;m.water.ocean.enabled=true;editorTest.load(m);});
 await p.click('#frame');await p.waitForTimeout(600);const a=await p.evaluate(()=>({frames:mapDiagnostics.frames,time:editorTest.getView().waterTime}));await p.waitForTimeout(400);const c=await p.evaluate(()=>({frames:mapDiagnostics.frames,time:editorTest.getView().waterTime}));assert(c.frames>a.frames);assert(c.time>a.time);
 await p.locator('#animateWater').evaluate(el=>{el.checked=false;el.dispatchEvent(new Event('change'));});await p.evaluate(()=>editorTest.idle());await p.click('#terrainTab');await p.screenshot({path:'artifacts/water-shore-refined.png'});assert.deepEqual(await p.evaluate(()=>mapDiagnostics.errors),[]);console.log('Default water animation advances frames and time; coastal scene renders without GPU errors.');
}finally{await b.close();}
