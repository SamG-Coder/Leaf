import {GpuRuntime} from '../vendor/cuda-webshader/runtime/runtime.js';

import {presetFor} from './species.js';

const ENTRIES=['wood','generate','clusters','lighting','clear','raster','branches','resolve'];

const finite=(v,name)=>{if(!Number.isFinite(v))throw new TypeError(`${name} must be finite`);return v;};

/** DOM-independent GPU batch for seeded leaves or rooted grass blades.

 * render returns an RGBA8 storage buffer; present is optional canvas glue.

 */

export class FoliageSystem {

 static async create({runtime,width=1280,height=896,capacity=200000,onError,artifactBase=new URL('../generated/',import.meta.url)}={}){

  if(!Number.isInteger(capacity)||capacity<1||capacity>200000)throw new RangeError('capacity must be 1..200000');

  if(!Number.isInteger(width)||!Number.isInteger(height)||width<1||height<1||width%64||Math.ceil(width*height/128)>65535)throw new RangeError('Width must be a multiple of 64; maximum 8,388,480 pixels');

  const owned=!runtime;runtime??=await GpuRuntime.create({onError});

  const self=new FoliageSystem();Object.assign(self,{runtime,owned,width,height,capacity,kernels:{},invocations:{},disposed:false});

  try{

   for(const entry of ENTRIES){const response=await fetch(new URL(`${entry}.json`,artifactBase));if(!response.ok)throw Error(`Missing kernel ${entry}`);self.kernels[entry]=await runtime.kernel(await response.json());}

   self.buffers={woodA:runtime.createBuffer(512*16),woodB:runtime.createBuffer(512*16),pos:runtime.createBuffer(capacity*16),normal:runtime.createBuffer(capacity*16),shape:runtime.createBuffer(capacity*16),centers:runtime.createBuffer(128*16),light:runtime.createBuffer(16384*4),depth:runtime.createBuffer(width*height*4),pixels:runtime.createBuffer(width*height*4)};

   self.config={preset:0,count:Math.min(100000,capacity),seed:42,bins:8};self.sun={lx:.45,ly:.7,lz:-.55};self.geometryDirty=true;self.lightDirty=true;self.stats={generations:0,lightUpdates:0,frames:0,instanceBytes:capacity*48};return self;

  }catch(e){await self.dispose();throw e;}

 }

 assertAlive(){if(this.disposed)throw Error('FoliageSystem is disposed');}

 configure(options={}){

  this.assertAlive();const next={...this.config};

  for(const key of Object.keys(options))if(!['preset','count','seed','bins'].includes(key))throw Error(`Unknown configuration: ${key}`);

  if(options.preset!==undefined)next.preset=presetFor(options.preset).id;

  for(const key of ['count','seed','bins'])if(options[key]!==undefined)next[key]=options[key];

  if(!Number.isInteger(next.count)||next.count<1||next.count>this.capacity)throw new RangeError('count exceeds capacity');

  if(!Number.isInteger(next.seed)||next.seed<0||next.seed>0xffffffff)throw new RangeError('seed must be uint32');

  if(![4,8,16].includes(next.bins))throw new RangeError('bins must be 4, 8 or 16');

  if(['preset','count','seed'].some(k=>next[k]!==this.config[k])){this.geometryDirty=true;if(this.external)this.lightDirty=true;this.external=false;}

  if(['preset','bins','seed'].some(k=>next[k]!==this.config[k]))this.lightDirty=true;

  this.config=next;return this;

 }

 /** Upload custom instance records once, then use the same CUDA wind/light renderer.

  * A custom CUDA emitter may instead write these public buffers directly and call

  * useGpuInstances once its queue-ordered dispatch has been submitted.

  */

 setInstances({positions,normals,shapes,centers,kind='leaves'}){

  this.assertAlive();const n=positions?.length/4;

  if(!Number.isInteger(n)||n<1||n>this.capacity||!['leaves','grass'].includes(kind))throw new RangeError('Invalid custom batch');

  for(const [name,data,length] of [['positions',positions,n*4],['normals',normals,n*4],['shapes',shapes,n*4],['centers',centers,512]])if(!(data instanceof Float32Array)||data.length!==length||!data.every(Number.isFinite))throw new TypeError(`Invalid ${name} records`);

  for(let i=0;i<n;i++){const k=i*4;if(positions[k+3]<=0||positions[k+3]>2||normals[k]<0||normals[k]>=6.283185||normals[k+1]<-1.35||normals[k+1]>=1.35||normals[k+2]<0||normals[k+2]>1||!Number.isInteger(normals[k+3])||normals[k+3]<0||normals[k+3]>=128||shapes[k+3]<=0||shapes[k+3]>1)throw new RangeError('Custom record outside supported range');}

  for(const [name,data] of [['pos',positions],['normal',normals],['shape',shapes],['centers',centers]])this.runtime.device.queue.writeBuffer(this.buffers[name].gpuBuffer,0,data);

  return this.useGpuInstances({count:n,kind});

 }

 useGpuInstances({count,kind='leaves'}){this.assertAlive();if(!Number.isInteger(count)||count<1||count>this.capacity||!['leaves','grass'].includes(kind))throw new RangeError('Invalid GPU batch');this.config={...this.config,count,preset:kind==='grass'?10:0};this.external=true;this.geometryDirty=false;this.lightDirty=true;return this;}

 useGenerated(options={}){this.assertAlive();this.external=false;this.geometryDirty=true;this.lightDirty=true;return this.configure(options);}

 setLight({azimuth=305,elevation=40}={}){

  this.assertAlive();finite(azimuth,'azimuth');finite(elevation,'elevation');const a=azimuth*Math.PI/180,e=elevation*Math.PI/180;

  const next={lx:Math.cos(a)*Math.cos(e),ly:Math.sin(e),lz:Math.sin(a)*Math.cos(e)};

  if(Object.keys(next).some(k=>next[k]!==this.sun[k]))this.lightDirty=true;this.sun=next;return this;

 }

 render({yaw=.3,tilt=this.config.preset>=111?-.45:this.config.preset>=101?-.85:this.config.preset>=81?-.5:this.config.preset>=71?-.35:this.config.preset===10?-.65:this.config.preset>=61?-.5:this.config.preset>=51?.16:this.config.preset>=41?.65:this.config.preset>=31?.4:.16,scale=this.config.preset>=11?150:95,focus=this.config.preset>=111?.8:this.config.preset>=101?.1:this.config.preset>=91?.8:this.config.preset>=81?.45:this.config.preset>=71?1.15:this.config.preset>=61?.65:this.config.preset>=51?1.5:this.config.preset>=41?.3:this.config.preset===10?.5:this.config.preset>=11?1.15:3.6,time=0,wind=.1,mode=0,autumn=0,timestampWrites}={}){

  this.assertAlive();for(const [k,v] of Object.entries({yaw,tilt,scale,focus,time,wind,autumn}))finite(v,k);

  if(scale<1||scale>200||wind<0||wind>1||autumn<0||autumn>1||!Number.isInteger(mode)||mode<0||mode>3)throw new RangeError('Invalid render options');

  const {pos,normal,shape,centers,light,depth,pixels,woodA,woodB}=this.buffers,{count:n,seed,bins,preset:species}=this.config;

  const cam={w:this.width,h:this.height,yaw,tilt,scale,focus},batch=this.runtime.batch({timestampWrites});

  const launch=(entry,buffers,scalars,groups)=>{let inv=this.invocations[entry];if(!inv){inv=this.kernels[entry].bind(buffers,scalars);this.invocations[entry]=inv;}else inv.setScalars(scalars);batch.dispatch(inv,[groups,1,1]);};

  if(this.geometryDirty){launch('wood',{woodA,woodB},{seed,species},4);launch('clusters',{centers},{seed,species},1);launch('generate',{pos,normal,shape},{seed,n,species},Math.ceil(n/128));this.stats.generations++;this.geometryDirty=false;}

  if(this.lightDirty){launch('lighting',{light,centers},{seed,bins,species,...this.sun},bins*bins/2);this.stats.lightUpdates++;this.lightDirty=false;}

  launch('clear',{depth},{pixels:this.width*this.height},Math.ceil(this.width*this.height/128));

  launch('raster',{pos,normal,shape,depth},{n,species,...cam,time,wind},Math.ceil(n/128));

  if(species!==10&&(species<61||species>=71)&&!this.external)launch('branches',{depth,woodA,woodB},{...cam,species,time,wind},512);

  launch('resolve',{depth,pos,normal,light,woodA,woodB,pixels},{...cam,bins,mode,...this.sun,species,autumn,time,wind},Math.ceil(this.width*this.height/128));

  batch.submit();this.stats.frames++;return pixels;

 }

 present(context){this.assertAlive();const encoder=this.runtime.device.createCommandEncoder();encoder.copyBufferToTexture({buffer:this.buffers.pixels.gpuBuffer,bytesPerRow:this.width*4},{texture:context.getCurrentTexture()},[this.width,this.height]);this.runtime.device.queue.submit([encoder.finish()]);}

 async read(name){this.assertAlive();if(!Object.hasOwn(this.buffers,name))throw Error(`Unknown buffer ${name}`);await this.runtime.idle();return this.runtime.read(this.buffers[name],['depth','pixels'].includes(name)?Uint32Array:Float32Array);}

 async dispose(){if(this.disposed)return;this.disposed=true;if(this.runtime){await this.runtime.idle();for(const b of Object.values(this.buffers||{}))this.runtime.destroyBuffer(b);if(this.owned)this.runtime.dispose();}}

}



