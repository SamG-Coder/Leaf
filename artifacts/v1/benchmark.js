import {GpuRuntime} from '../vendor/cuda-webshader/runtime/runtime.js';
export async function benchmark({baseline=false,n=100000,scale=95,samples=25,seed=42,yaw=.3,tilt=.16,time=0,wind=0,mode=0}={}){
 const errors=[],rt=await GpuRuntime.create({onError:e=>errors.push(String(e))}),d=rt.device;
 if(!d.features.has('timestamp-query'))throw Error('GPU timestamps unavailable');
 const names=['generate','lighting','clear','raster','branches','resolve'],ks={};
 for(const name of names)ks[name]=await rt.kernel(await(await fetch(`${baseline?'./artifacts/baseline/generated':'./generated'}/${name}.json`)).json());
 const pos=rt.createBuffer(n*16),normal=rt.createBuffer(n*16),light=rt.createBuffer(4096*4),depth=rt.createBuffer(1280*896*4),pixels=rt.createBuffer(1280*896*4);
 const cam={w:1280,h:896,yaw,tilt,scale},az=305*Math.PI/180,el=40*Math.PI/180,sun={lx:Math.cos(az)*Math.cos(el),ly:Math.sin(el),lz:Math.sin(az)*Math.cos(el)};
 const inv=[ks.generate.bind({pos,normal},{seed,n}),ks.lighting.bind({light},{seed,bins:8,...sun}),ks.clear.bind({depth},{pixels:1280*896}),ks.raster.bind({pos,normal,depth},{n,...cam,time,wind}),ks.branches.bind({depth},{seed,...cam}),ks.resolve.bind({depth,pos,normal,light,pixels},{...cam,bins:8,mode,...sun})];
 const counts=[Math.ceil(n/128),32,8960,Math.ceil(n/128),baseline?2:129,8960];
 const qs=d.createQuerySet({type:'timestamp',count:12}),qb=d.createBuffer({size:96,usage:GPUBufferUsage.QUERY_RESOLVE|GPUBufferUsage.COPY_SRC}),rb=d.createBuffer({size:96,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});
 const rows=[];
 for(let s=-5;s<samples;s++){
  for(let k=0;k<6;k++)rt.batch({timestampWrites:{querySet:qs,beginningOfPassWriteIndex:k*2,endOfPassWriteIndex:k*2+1}}).dispatch(inv[k],[counts[k],1,1]).submit();
  const enc=d.createCommandEncoder();enc.resolveQuerySet(qs,0,12,qb,0);enc.copyBufferToBuffer(qb,0,rb,0,96);d.queue.submit([enc.finish()]);await rb.mapAsync(GPUMapMode.READ);
  const t=new BigUint64Array(rb.getMappedRange());const row=names.map((_,k)=>Number(t[k*2+1]-t[k*2])/1e6);rb.unmap();if(s>=0)rows.push(row);
 }
 const raw=await rt.read(pixels,Uint32Array);const digest=await crypto.subtle.digest('SHA-256',raw);const hash=Array.from(new Uint8Array(digest),b=>b.toString(16).padStart(2,'0')).join('');
 const med=a=>a.sort((a,b)=>a-b)[Math.floor(a.length/2)];const stages=Object.fromEntries(names.map((name,k)=>[name,med(rows.map(r=>r[k]))]));
 const result={baseline,n,scale,seed,yaw,tilt,time,wind,mode,samples,stages,steadyGpuMs:med(rows.map(r=>r.slice(2).reduce((a,b)=>a+b,0))),hash,errors};
 qs.destroy();qb.destroy();rb.destroy();rt.dispose();return result;
}
