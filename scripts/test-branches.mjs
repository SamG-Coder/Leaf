import {chromium} from 'playwright';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try{
 const page=await browser.newPage({viewport:{width:896,height:896}}),errors=[];page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
 await page.goto('http://127.0.0.1:5197/profile.html');await page.evaluate(async()=>{const {FoliageSystem}=await import('./src/foliage-system.js');window.fs=await FoliageSystem.create({width:896,height:896});document.body.innerHTML='<canvas width="896" height="896"></canvas>';document.body.style.margin='0';window.ctx=document.querySelector('canvas').getContext('webgpu');ctx.configure({device:fs.runtime.device,format:'rgba8unorm',usage:GPUTextureUsage.COPY_DST|GPUTextureUsage.RENDER_ATTACHMENT});});
 const checks=[];
 for(const species of [0,1,2,5,8]){
  const result=await page.evaluate(async species=>{
   fs.configure({preset:species,count:1}).setLight({azimuth:240,elevation:35});const opts={scale:105,focus:3.5,wind:0};fs.render(opts);await fs.runtime.idle();
   const a=await fs.read('pixels'),depth=await fs.read('depth'),wood=await fs.read('woodA');
   fs.setLight({azimuth:60,elevation:35});fs.render(opts);await fs.runtime.idle();const b=await fs.read('pixels'),newDepth=await fs.read('depth'),newWood=await fs.read('woodA');
   let visible=0,changed=0;for(let i=0;i<a.length;i++){if(depth[i]!==4294967295&&(depth[i]&262143)>=250000){visible++;if(a[i]!==b[i])changed++;}}
   if(visible<100||changed/visible<.5||!depth.every((v,i)=>v===newDepth[i])||!wood.every((v,i)=>v===newWood[i]))throw Error(`Branch lighting failed ${species}`);
   // Same camera/light after an orbit reproduces bark exactly.
   fs.render({...opts,yaw:1.4});await fs.runtime.idle();fs.render(opts);await fs.runtime.idle();const returned=await fs.read('pixels');if(!b.every((v,i)=>v===returned[i]))throw Error('Nonrepeatable bark');
   fs.setLight({azimuth:240,elevation:35});fs.render(opts);fs.present(ctx);await fs.runtime.idle();
   return {species,visibleWoodPixels:visible,relitWoodPixels:changed,geometryAndDepthUnchanged:true,orbitReturnExact:true};
  },species);await page.locator('canvas').screenshot({path:`artifacts/branches-${species}.png`});checks.push(result);
 }
 if(errors.length)throw Error(errors.join('\n'));await writeFile('artifacts/branch-validation.json',JSON.stringify({checks,errors},null,2));console.log(JSON.stringify(checks));
}finally{await browser.close();}
