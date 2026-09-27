import {chromium} from 'playwright';
import assert from 'node:assert/strict';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try{
 const p=await browser.newPage({viewport:{width:1600,height:1000}}),errors=[];p.on('pageerror',e=>errors.push(e.message));
 let release;const gate=new Promise(r=>release=r);await p.route('**/generated/generate.json',async route=>{await gate;await route.continue();});
 await p.goto('http://127.0.0.1:5197/editor.html');await p.getByRole('heading',{name:'Compiling GPU shaders'}).waitFor();
 await p.waitForFunction(()=>document.querySelector('#loadingProgress').value===1);assert.equal(await p.locator('#loadingProgress').getAttribute('max'),'32');assert(await p.locator('#workspaceLoading').isVisible());assert.equal(await p.locator('header').evaluate(el=>el.inert),true);await p.screenshot({path:'artifacts/editor-loading-shaders.png'});release();
 await p.waitForFunction(()=>mapDiagnostics.ready);await p.locator('#newMapDialog').waitFor({state:'visible'});await p.screenshot({path:'artifacts/editor-new-project.png'});
 assert.equal(await p.locator('#example,#emptyExample').count(),0);await p.locator('[name=projectTemplate][value=island]').check();assert.equal(await p.locator('#newMapExtent').inputValue(),'1000');assert(await p.locator('#newMapExtent').getAttribute('readonly')!==null);await p.fill('#newMapName','My island');await p.click('#createMap');await p.locator('#workspaceLoading').waitFor({state:'visible'});await p.screenshot({path:'artifacts/editor-loading-map.png'});await p.locator('#workspaceLoading').waitFor({state:'hidden'});assert.equal(await p.evaluate(()=>editorTest.getMap().name),'My island');assert((await p.evaluate(()=>editorTest.getMap().objects.length))>2000);
 await p.click('#new');await p.locator('[name=projectTemplate][value=blank]').check();await p.fill('#newMapExtent','2048');await p.click('#cancelNewMap');assert.equal(await p.evaluate(()=>editorTest.getMap().extent),1000);
 await p.click('#new');await p.fill('#newMapName','New landscape');await p.fill('#newMapExtent','2048');await p.click('#createMap');await p.locator('#workspaceLoading').waitFor({state:'hidden'});assert.equal(await p.evaluate(()=>editorTest.getMap().extent),2048);assert.equal(await p.evaluate(()=>editorTest.getMap().objects.length),0);
 await p.evaluate(()=>editorTest.flushAutosave());await p.reload();await p.waitForFunction(()=>mapDiagnostics.ready);assert(!await p.locator('#newMapDialog').isVisible());assert.equal(await p.evaluate(()=>editorTest.getMap().name),'New landscape');
 await p.locator('#file').setInputFiles({name:'bad.json',mimeType:'application/json',buffer:Buffer.from('{broken')});await p.locator('#workspaceLoading').waitFor({state:'hidden'});assert.equal(await p.evaluate(()=>editorTest.getMap().name),'New landscape');assert.equal(await p.locator('header').evaluate(el=>el.inert),false);
 assert.deepEqual(errors,[]);assert.deepEqual(await p.evaluate(()=>mapDiagnostics.errors),[]);
 const failed=await browser.newPage();await failed.route('**/generated/wood.json',r=>r.fulfill({status:404,body:'missing'}));await failed.goto('http://127.0.0.1:5197/editor.html');await failed.getByRole('heading',{name:'Could not open the workspace'}).waitFor();assert(await failed.locator('#retryLoading').isVisible());assert(!await failed.evaluate(()=>mapDiagnostics.ready));
 console.log('Shader progress, first-run New Project, island template, blank dimensions, cancel, autosave restore, invalid import recovery and shader failure UI passed.');
}finally{await browser.close();}
