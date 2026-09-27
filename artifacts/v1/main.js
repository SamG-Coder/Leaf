import {GpuRuntime} from '../vendor/cuda-webshader/runtime/runtime.js';
const $=id=>document.getElementById(id), canvas=document.querySelector('canvas');
const W=1280,H=896,MAX=200000;
const controls=['count','sun','elevation','bins','mode','wind','seed','animate'];
const state={yaw:0.3,tilt:0.16,scale:95,time:0};
let generationDirty=true,lightDirty=true,running=true,last=performance.now();
window.leafDiagnostics={ready:false,errors:[],frames:0};
function fail(e){window.leafDiagnostics.errors.push(String(e));$('status').textContent=String(e);console.error(e);running=false;}
function update(){
 for(const id of ['count','sun','elevation','wind'])$(id+'Out').textContent=id==='count'?Number($(id).value).toLocaleString():$(id).value+(id==='sun'||id==='elevation'?'°':'');
 const groups=128*Number($('bins').value)**2/2;
 $('groups').textContent=groups.toLocaleString();$('ratio').textContent=(Number($('count').value)/groups).toFixed(1)+'×';$('memory').textContent='6.4 MB';
}
for(const id of controls)$(id).addEventListener('input',()=>{if(id==='seed'||id==='count')generationDirty=true;if(['seed','sun','elevation','bins'].includes(id))lightDirty=true;update();});
$('newseed').onclick=()=>{$('seed').value=(Number($('seed').value)+7919)%1000000;generationDirty=true;lightDirty=true;};
let drag=null;canvas.onpointerdown=e=>{drag=[e.clientX,e.clientY];canvas.setPointerCapture(e.pointerId);};canvas.onpointerup=()=>drag=null;canvas.onpointercancel=()=>drag=null;
canvas.onpointermove=e=>{if(!drag)return;state.yaw+=(e.clientX-drag[0])*0.008;state.tilt=Math.max(-0.4,Math.min(0.7,state.tilt+(e.clientY-drag[1])*0.006));drag=[e.clientX,e.clientY];};
canvas.addEventListener('wheel',e=>{e.preventDefault();state.scale=Math.min(200,Math.max(55,state.scale*Math.exp(-e.deltaY*0.001)));},{passive:false});
try{
 const runtime=await GpuRuntime.create({onError:fail});const device=runtime.device;
 const kernels={};for(const entry of ['generate','lighting','clear','raster','branches','resolve'])kernels[entry]=await runtime.kernel(await(await fetch(`./generated/${entry}.json`)).json());
 const pos=runtime.createBuffer(MAX*16),normal=runtime.createBuffer(MAX*16),light=runtime.createBuffer(16384*4),depth=runtime.createBuffer(W*H*4),pixels=runtime.createBuffer(W*H*4);
 const context=canvas.getContext('webgpu');context.configure({device,format:'rgba8unorm',alphaMode:'opaque',usage:GPUTextureUsage.COPY_DST|GPUTextureUsage.RENDER_ATTACHMENT});
 const diagnostics=window.leafDiagnostics;diagnostics.ready=true;
 const info=runtime.adapter?.info;diagnostics.adapter=info?{vendor:info.vendor,architecture:info.architecture,device:info.device,description:info.description}:null;diagnostics.instanceBytes=MAX*32;
 // Readbacks are exposed for validation only; normal rendering stays on the GPU.
 window.leafTest={readGeometry:async()=>{await runtime.idle();return Array.from(await runtime.read(pos));},readNormals:async()=>{await runtime.idle();return Array.from(await runtime.read(normal));},readLights:async()=>{await runtime.idle();return Array.from(await runtime.read(light));},readPixels:async()=>{await runtime.idle();return Array.from(new Uint32Array((await runtime.read(pixels)).buffer));}};
 update();let smooth=0;
 async function frame(){if(!running)return;try{
 const start=performance.now();const dt=Math.min(0.05,(start-last)/1000);last=start;if($('animate').checked)state.time+=dt;
 const n=Number($('count').value),seed=Math.max(0,Math.min(999999,Number($('seed').value)||0)),bins=Number($('bins').value),mode=Number($('mode').value);
 const a=Number($('sun').value)*Math.PI/180,e=Number($('elevation').value)*Math.PI/180;
 const sun={lx:Math.cos(a)*Math.cos(e),ly:Math.sin(e),lz:Math.sin(a)*Math.cos(e)};
 const cam={w:W,h:H,yaw:state.yaw,tilt:state.tilt,scale:state.scale};
 const batch=runtime.batch();const dispatch=(entry,buffers,scalars,count)=>batch.dispatch(kernels[entry].bind(buffers,scalars),[Math.ceil(count/128),1,1]);
 if(generationDirty){dispatch('generate',{pos,normal},{seed,n},n);generationDirty=false;diagnostics.generations=(diagnostics.generations||0)+1;}
 if(lightDirty){dispatch('lighting',{light},{seed,bins,...sun},128*bins*bins/2);lightDirty=false;diagnostics.lightUpdates=(diagnostics.lightUpdates||0)+1;}
 dispatch('clear',{depth},{pixels:W*H},W*H);
 dispatch('raster',{pos,normal,depth},{n,...cam,time:state.time,wind:Number($('wind').value)},n);
 dispatch('branches',{depth},{seed,...cam},129*128);
 dispatch('resolve',{depth,pos,normal,light,pixels},{...cam,bins,mode,...sun},W*H);batch.submit();
 const encoder=device.createCommandEncoder();encoder.copyBufferToTexture({buffer:pixels.gpuBuffer,bytesPerRow:W*4},{texture:context.getCurrentTexture()},[W,H]);device.queue.submit([encoder.finish()]);await runtime.idle();
 const ms=performance.now()-start;smooth=smooth?smooth*.9+ms*.1:ms;diagnostics.frames++;Object.assign(diagnostics,{n,seed,bins,mode,frameMs:smooth,groups:128*bins*bins/2});
 if(diagnostics.frames%15===0){$('frame').textContent=smooth.toFixed(1)+' ms';$('status').textContent=`${n.toLocaleString()} INSTANCES · GPU RESIDENT`;}
 requestAnimationFrame(frame);
 }catch(e){fail(e);}}
 requestAnimationFrame(frame);
}catch(e){fail(e);}
