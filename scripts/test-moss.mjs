import {chromium} from 'playwright';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try{
 const page=await browser.newPage();const errors=[];page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
 await page.goto('http://127.0.0.1:5197/profile.html');
 const results=await page.evaluate(async()=>{
  const {FoliageSystem}=await import('./src/foliage-system.js');const fs=await FoliageSystem.create({width:768,height:768});const results=[];
  const digest=async a=>Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',a))).join(',');
  for(let id=41;id<=50;id++){
   fs.configure({preset:id,count:10000,seed:42}).setLight({azimuth:305,elevation:40});fs.render({wind:0});await fs.runtime.idle();const prefix=(await fs.read('pos')).slice(0,40000);
   fs.configure({count:200000});fs.render({wind:0});await fs.runtime.idle();const p=await fs.read('pos'),nm=await fs.read('normal');
   if(!prefix.every((v,i)=>p[i]===v))throw Error('Moss prefix changed');
   let leaves=0,petals=0;for(let i=0;i<200000;i++){const k=i*4;if(nm[k]<0||nm[k]>=6.283185||nm[k+1]<-1.35||nm[k+1]>=1.35)throw Error('Light group out of bounds');if(nm[k+2]<1)leaves++;else petals++;}
   if(leaves!==200000||petals!==0)throw Error('Moss emitted flower material');
   const wood=await fs.read('woodA');let segments=0;for(let j=3;j<wood.length;j+=4)if(wood[j]>0)segments++;if(segments!==0)throw Error('Unexpected tree or fern stems');
   const before=await digest(await fs.read('pixels'));const gen=fs.stats.generations;
   fs.setLight({azimuth:120,elevation:15});fs.render({wind:0});await fs.runtime.idle();if(before===await digest(await fs.read('pixels'))||gen!==fs.stats.generations)throw Error('Lighting failed');
   for(const mode of [1,2,3]){fs.render({mode,wind:.35,time:2,yaw:2.4,tilt:.55,scale:200});await fs.runtime.idle();}
   results.push({id,count:200000,prefixStable:true,leaves,petals,lightChangesPixels:true,lightPreservesGeometry:true,inspectionModes:true});
  }
  await fs.dispose();return results;
 });
 if(errors.length)throw Error(JSON.stringify(errors));await writeFile('artifacts/moss-validation.json',JSON.stringify({results,errors},null,2));console.log('All 10 mosses: 200k capacity, stable prefixes, valid lighting groups, foliage and no unwanted branches, light changes and inspection modes passed.');
}finally{await browser.close();}

