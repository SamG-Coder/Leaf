import {FoliageSystem} from './foliage-system.js';
export async function benchmark({preset=0,n=100000,scale=95,samples=25}={}){
 const errors=[],fs=await FoliageSystem.create({onError:e=>errors.push(String(e))});
 try{
 fs.configure({preset,count:n}).setLight();const d=fs.runtime.device;
 if(!d.features.has('timestamp-query'))throw Error('GPU timestamps unavailable');
 const q=d.createQuerySet({type:'timestamp',count:2}),qb=d.createBuffer({size:16,usage:GPUBufferUsage.QUERY_RESOLVE|GPUBufferUsage.COPY_SRC}),rb=d.createBuffer({size:16,usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});
 const times=[];const options={scale,tilt:preset===10?.65:.16,wind:.1,time:1};
 for(let k=-5;k<samples;k++){
  fs.render({...options,timestampWrites:{querySet:q,beginningOfPassWriteIndex:0,endOfPassWriteIndex:1}});
  const e=d.createCommandEncoder();e.resolveQuerySet(q,0,2,qb,0);e.copyBufferToBuffer(qb,0,rb,0,16);d.queue.submit([e.finish()]);await rb.mapAsync(GPUMapMode.READ);const t=new BigUint64Array(rb.getMappedRange());if(k>=0)times.push(Number(t[1]-t[0])/1e6);rb.unmap();
 }
 times.sort((a,b)=>a-b);q.destroy();qb.destroy();rb.destroy();return {preset,n,scale,resolution:[1280,896],samples,medianGpuMs:times[Math.floor(times.length/2)],p95GpuMs:times[Math.floor(times.length*.95)],errors};
 }finally{await fs.dispose();}
}
