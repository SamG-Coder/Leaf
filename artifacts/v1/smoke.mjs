import {chromium} from 'file:///D:/cuda-webshader/node_modules/playwright/index.mjs';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
const page=await browser.newPage({viewport:{width:1500,height:1000}});const errors=[];
page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
try{
 await page.goto('http://127.0.0.1:5197');
 await page.waitForFunction(()=>window.leafDiagnostics?.frames>10||window.leafDiagnostics?.errors.length,{timeout:120000});
 const d=await page.evaluate(()=>window.leafDiagnostics);if(d.errors.length)throw Error(JSON.stringify(d));
 await page.locator('#animate').uncheck();await page.locator('#wind').fill('0');
 await page.screenshot({path:'artifacts/leaf-default.png'});
 const check=await page.evaluate(async()=>{
  const initial=await leafTest.readGeometry();const before=leafDiagnostics.generations;
  document.getElementById('sun').value='120';document.getElementById('sun').dispatchEvent(new Event('input'));
  await new Promise(r=>setTimeout(r,300));const changed=await leafTest.readGeometry();
  return {finite:initial.every(Number.isFinite),sameGeometryAfterLight:initial.every((v,i)=>v===changed[i]),noRegeneration:before===leafDiagnostics.generations,initialSample:initial.slice(0,16)};
 });
 if(!check.finite||!check.sameGeometryAfterLight||!check.noRegeneration)throw Error(JSON.stringify(check));
 for(const mode of ['1','2','3']){await page.locator('#mode').selectOption(mode);await page.waitForTimeout(250);}
 await page.locator('#count').fill('200000');await page.locator('#bins').selectOption('16');await page.waitForTimeout(700);
 const max=await page.evaluate(()=>window.leafDiagnostics);
 await page.locator('#count').fill('100000');await page.locator('#bins').selectOption('8');await page.locator('#mode').selectOption('0');await page.locator('#sun').fill('305');await page.waitForTimeout(500);
 const deterministic=await page.evaluate(async()=>{
  const a=await leafTest.readGeometry();const s=document.getElementById('seed');s.value='777';s.dispatchEvent(new Event('input'));await new Promise(r=>setTimeout(r,300));
  const b=await leafTest.readGeometry();s.value='42';s.dispatchEvent(new Event('input'));await new Promise(r=>setTimeout(r,300));const c=await leafTest.readGeometry();
  return {seedChangesGeometry:a.slice(0,400000).some((v,i)=>v!==b[i]),repeatable:a.slice(0,400000).every((v,i)=>v===c[i])};
 });
 if(!deterministic.seedChangesGeometry||!deterministic.repeatable||errors.length)throw Error(JSON.stringify({deterministic,errors}));
 await page.screenshot({path:'artifacts/leaf-default.png'});
 const exposureErrors=[];
 for(const bins of [4,8,16]){
  await page.locator('#bins').selectOption(String(bins));await page.waitForTimeout(200);
  exposureErrors.push(await page.evaluate(async(bins)=>{
   const p=await leafTest.readGeometry(),nm=await leafTest.readNormals(),lights=await leafTest.readLights();
   const az=305*Math.PI/180,el=40*Math.PI/180,l=[Math.cos(az)*Math.cos(el),Math.sin(el),Math.sin(az)*Math.cos(el)];
   let sum=0,max=0,sq=0;const n=100000,nb=bins*bins/2;
   for(let i=0;i<n;i++){
    const a=nm[i*4],e=nm[i*4+1];const nn=[Math.cos(a)*Math.cos(e),Math.sin(e),Math.sin(a)*Math.cos(e)];
    const side=(p[i*4]*l[0]+(p[i*4+1]-4.8)*l[1]+p[i*4+2]*l[2])/3.7;
    const exact=.18+.82*Math.abs(nn.reduce((s,v,k)=>s+v*l[k],0))*Math.min(1,Math.max(.12,.5+side*.48));
    const b=Math.floor((e/2.7+.5)*(bins/2))*bins+Math.floor(a/6.283185*bins);
    const error=Math.abs(exact-lights[(i%128)*nb+b]);sum+=error;sq+=error*error;max=Math.max(max,error);
   }
   return {bins,groups:128*nb,meanAbsoluteError:sum/n,rootMeanSquareError:Math.sqrt(sq/n),maxAbsoluteError:max};
  },bins));
 }
 await page.locator('#bins').selectOption('8');await page.waitForTimeout(200);
 if(exposureErrors.some(v=>!Number.isFinite(v.rootMeanSquareError))||errors.length)throw Error(JSON.stringify({exposureErrors,errors}));
 const report={default:d,check,maximum:max,deterministic,exposureErrors,errors};await writeFile('artifacts/validation.json',JSON.stringify(report,null,2));console.log(JSON.stringify(report,null,2));
}finally{await browser.close();}

