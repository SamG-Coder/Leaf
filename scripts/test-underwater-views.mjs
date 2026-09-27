import {chromium} from 'playwright';
import assert from 'node:assert/strict';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try {
 const page=await browser.newPage({viewport:{width:1440,height:900}}),errors=[];
 page.on('pageerror',e=>errors.push(e.message));
 await page.goto('http://127.0.0.1:5197/editor.html');await page.waitForFunction(()=>window.mapDiagnostics?.ready);
 await page.evaluate(async()=>{const {emptyMap}=await import('./src/map-model.js');const m=emptyMap();m.extent=1000;for(let z=0;z<65;z++)for(let x=0;x<65;x++){const xx=(x/64-.5)*1000,zz=(z/64-.5)*1000;m.terrain[z*65+x]=-8+Math.sin(xx*.04)*1.5+Math.cos(zz*.06)*2;}m.water.ocean={enabled:true,level:0};m.environment.enabled=true;m.environment.weatherMode='manual';m.environment.weather='clear';m.environment.hour=12;m.environment.playing=false;editorTest.load(m);});
 await page.evaluate(()=>editorTest.idle());await page.click('#play');await page.waitForFunction(()=>!!document.pointerLockElement);
 await page.keyboard.down('ControlLeft');await page.waitForTimeout(900);await page.keyboard.up('ControlLeft');await page.waitForTimeout(100);
 assert((await page.evaluate(()=>editorTest.playState())).underwater);
 await page.screenshot({path:'artifacts/underwater-horizontal.png'});
 await page.evaluate(()=>document.dispatchEvent(new MouseEvent('mousemove',{movementY:(editorTest.getView().pitch+.65)/.0025})));await page.waitForTimeout(200);await page.screenshot({path:'artifacts/underwater-seabed.png'});
 await page.evaluate(()=>document.dispatchEvent(new MouseEvent('mousemove',{movementY:(editorTest.getView().pitch-.8)/.0025})));await page.waitForTimeout(200);await page.screenshot({path:'artifacts/underwater-surface.png'});
 assert.deepEqual(errors,[]);assert.deepEqual(await page.evaluate(()=>mapDiagnostics.errors),[]);
 console.log('Underwater seabed, horizontal and surface views rendered without GPU errors.');
} finally {await browser.close();}
