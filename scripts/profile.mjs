import {chromium} from 'playwright';
import {writeFile} from 'node:fs/promises';
if(process.argv.includes('--baseline'))throw Error('The original single-tree baseline is archived in artifacts/profile-before.json. Current species use a different geometry contract; run npm run profile.');
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--enable-unsafe-webgpu']});
try{
 const page=await browser.newPage();await page.goto('http://127.0.0.1:5197/profile.html');const results=[];
 for(let preset=0;preset<11;preset++){
  const result=await page.evaluate(async opts=>(await import('./src/benchmark.js')).benchmark(opts),{preset});if(result.errors.length)throw Error(JSON.stringify(result));results.push(result);console.log(JSON.stringify(result));
 }
 for(const opts of [{preset:10,n:200000},{preset:9,n:200000},{preset:9,n:100000,scale:200}]){const result=await page.evaluate(async opts=>(await import('./src/benchmark.js')).benchmark(opts),opts);if(result.errors.length)throw Error(JSON.stringify(result));results.push(result);console.log(JSON.stringify(result));}
 await writeFile('artifacts/profile-foliage.json',JSON.stringify(results,null,2));
}finally{await browser.close();}
