import {readyEditor,islandTemplate} from './editor-test-helpers.mjs';
import {chromium} from 'playwright';import assert from 'node:assert/strict';
const root=(process.argv[2]||'https://samg-coder.github.io/Leaf/').replace(/\/?$/,'/');
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try{const page=await browser.newPage({viewport:{width:1600,height:1000}});const errors=[];page.on('pageerror',e=>errors.push(e.message));page.on('response',r=>{if(r.status()>=400)errors.push(`${r.status()} ${r.url()}`);});
await page.goto(root+'editor.html');await page.waitForFunction(()=>window.mapDiagnostics?.ready,{},{timeout:60000});await readyEditor(page);await page.evaluate(()=>editorTest.idle());await islandTemplate(page);await page.evaluate(()=>editorTest.idle());assert.deepEqual(await page.evaluate(()=>mapDiagnostics.errors),[]);await page.screenshot({path:'artifacts/pages-editor.png'});console.log('Published editor:',await page.evaluate(()=>editorTest.renderStats()));
await page.goto(root);await page.waitForFunction(()=>window.leafDiagnostics?.ready,{},{timeout:60000});assert.deepEqual(await page.evaluate(()=>leafDiagnostics.errors),[]);assert.deepEqual(errors,[]);console.log('Editor, example forest and rendering lab loaded with no HTTP or runtime errors.');}finally{await browser.close();}
