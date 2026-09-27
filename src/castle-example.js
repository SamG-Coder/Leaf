import {emptyMap,validateMap} from './map-model.js';
import {newBuilding,localToWorld} from './building-model.js';
import {newPath} from './path-model.js';
import {defaultScale} from './asset-scale.js';
// Authored from the same editable pieces exposed in Building mode.
export function castleExample(){
 const m=emptyMap();m.name='Castle';m.extent=256;m.light={azimuth:235,elevation:42};m.environment.enabled=false;
 const height=(x,z)=>{const r=Math.max(Math.abs(x),Math.abs(z));if(r<=34)return 2;if(r<38)return 2-(r-34)*1.2;if(r<=46)return -2.8;if(r<52)return -2.8+(r-46)*.8;return 2+Math.sin(x*.04)*Math.cos(z*.05)*2+Math.max(0,z-60)*.05;};
 for(let z=0;z<65;z++)for(let x=0;x<65;x++)m.terrain[z*65+x]=height((x/64-.5)*256,(z/64-.5)*256);
 const add=(name,type,x,z,level,width,depth,h,rotation=0,material=1,support=2)=>{const p=newBuilding(m.buildings.length+1,type,x,z);Object.assign(p,{name,level,width,depth,height:h,rotation,material,support});m.buildings.push(p);return p;};
 const wall=(name,x,z,width,rotation=0,inside=1)=>{add(name,2,x,z,2,width,1.5,7,rotation);add(name+' crenellations',13,x,z,9,width,1.5,1.5,rotation);const a=rotation*Math.PI/180;add(name+' wall walk',0,x+Math.sin(a)*1.5*inside,z-Math.cos(a)*1.5*inside,9,width,2,.3,rotation);};
 wall('North curtain west',-11.65,28,23.3);wall('North curtain east',11.65,28,23.3);
 for(const x of [-28,28])for(const z of [-11.65,11.65])wall((x<0?'West':'East')+' curtain '+z,x,z,23.3,x<0?90:270);
 for(const x of [-13.65,13.65]){wall('Gate curtain '+x,x,-28,19.3,0,-1);add('Curtain buttress '+x,15,x,-29.5,2,1.5,2,6);}
 for(const x of [-5.5,5.5]){add('Gatehouse pier '+x,2,x,-28,2,3,3,10);add('Gatehouse pyramid roof '+x,22,x,-28,12,4,4,3,0,5);}
 add('Main gate arch',14,0,-28,2,8,3,7);add('Gatehouse crown',13,0,-28,9,8,3,1.5);add('Gatehouse walk',0,0,-26,9,8,2,.3);
 for(const x of [-28,28])for(const z of [-28,28]){
  const name=(z<0?'South':'North')+(x<0?'west':'east')+' round tower';
  add(name+' foundation',18,x,z,2.3,10,10,.3,0,1,1);
  for(let floor=0;floor<4;floor++)add(name+' storey '+(floor+1),floor===0?20:19,x,z,2.3+floor*3,10,10,3,x<0?90:270);
  for(let floor=0;floor<4;floor++){
   const side=floor%2?1:-1;add(name+' stair '+(floor+1),6,x+side*1.8,z,2.3+floor*3,1.6,5.4,3,floor%2?180:0,1);
   const end=floor%2?-1:1;add(name+' landing '+(floor+1),0,x,z+end*3.15,5.3+floor*3,4.8,.9,.2);
  }
  if(z<0){add(name+' upper chamber',19,x,z,14.3,10,10,3);add(name+' conical slate roof',21,x,z,17.3,11.5,11.5,6,0,5);}
  else{for(let i=0;i<16;i++){if([12,13,14].includes(i))continue;const a=i*Math.PI/8;add(name+' roof walk',0,x+Math.cos(a)*3.7,z+Math.sin(a)*3.7,14.3,1.6,1,.2,(i*22.5+90)%360);}add(name+' circular parapet',19,x,z,14.3,10,10,.7);for(let i=0;i<16;i++){const a=i*Math.PI/8;add(name+' merlon '+(i+1),10,x+Math.cos(a)*4.5,z+Math.sin(a)*4.5,15,.9,.9,.8,90-i*22.5<0?450-i*22.5:90-i*22.5);}}
 }
 // Compact switchbacks: continuous lower flight, turning landing, upper flight and wall landing.
 const access=(name,x,z,rotation)=>{const anchor={x,z,rotation};const part=(label,type,dx,dz,level,width,depth,height,turn=0)=>{const q=localToWorld(anchor,dx,dz);add(name+' '+label,type,q.x,q.z,level,width,depth,height,(rotation+turn)%360);};part('lower stair',6,-1.5,0,2,2,6,3.5);part('turning landing',0,0,3.75,5.5,5,1.5,.2);part('upper stair',6,1.5,0,5.5,2,6,3.5,180);part('wall landing',0,0,-3.75,9,5,1.5,.2);};
 access('West wall stair',-23.5,-10,0);access('East wall stair',23.5,10,180);access('North wall stair',0,23.5,90);access('South wall stair',-14,-23.5,270);
 add('Keep foundation',1,0,7,2.3,18,20,.3,0,1,1);
 for(const x of [-6,6])add('Keep gate flank '+x,2,x,-3,2.3,6,1,9);
 add('Keep entrance arch',14,0,-3,2.3,6,1,5);add('Keep above entrance',16,0,-3,7.3,6,1,4);
 for(let floor=0;floor<3;floor++){
  for(const x of [-8.5,8.5])add('Keep side '+x+' level '+floor,floor===1?16:2,x,7,2.3+floor*3,20,1,3,90);
  add('Keep rear level '+floor,floor===1?16:2,0,16.5,2.3+floor*3,18,1,3);
 }
 add('Keep hipped slate roof',23,0,7,11.3,20,22,5,0,5);
 for(const x of [-8,8])for(const z of [1,13])add('Keep buttress',15,x+(x<0?-1:1),z,2.3,1.5,2,7,x<0?90:270);
 // Entry bridge stays level over the moat. Pillars automatically reach its bed.
 for(const z of [-35,-43,-51]){add('Timber bridge deck',0,0,z,2.1,6,8,.25,0,0,0);for(const x of [-2.8,2.8])add('Bridge railing',11,x,z,2.1,8,.15,1,90,0);}
 for(const x of [-13,13])for(const z of [-12,8]){add('Courtyard bench',0,x,z,2.65,3,1,.18,90,0,0);add('Courtyard bench back',3,x+(x<0?-.45:.45),z,2.65,3,.15,.65,90,0);}
 for(const [x,z]of [[-6,8],[6,8]]){add('Great hall table',0,x,z,3.1,2,4,.2,0,0,0);for(const side of [-1,1])add('Great hall seat',0,x+side*1.5,z,2.75,.6,4,.15,0,0,0);}
 const rectangle=(x,z,w,d)=>[{x:x-w/2,z:z-d/2},{x:x+w/2,z:z-d/2},{x:x+w/2,z:z+d/2},{x:x-w/2,z:z+d/2}];
 const plan=(name,type,vertices,extra={})=>m.plans.push({id:m.plans.length+1,name,type,vertices,visible:true,seed:120+m.plans.length,spacing:4,scale:.65,preset:63,level:0,kind:'pond',smooth:false,randomRotation:true,...extra});
 plan('North moat','water',rectangle(0,42,92,12));plan('South moat','water',rectangle(0,-42,92,12));plan('West moat','water',rectangle(-42,0,12,72));plan('East moat','water',rectangle(42,0,12,72));
 for(const x of [-16,16])plan('Courtyard lawn '+x,'grass',rectangle(x,0,8,28),{spacing:2,scale:.35});
 for(const x of [-72,72])plan('Outer meadow '+x,'grass',rectangle(x,0,32,110));
 const path=(name,nodes,width,material)=>{const p=newPath(m.paths.length+1,0,0,m.extent);Object.assign(p,{name,width,material,nodes:nodes.map(([x,z],i)=>({id:i+1,x,z})),edges:nodes.slice(1).map(([x,z],i)=>({id:i+1,a:i+1,b:i+2,x:(x+nodes[i][0])/2,z:(z+nodes[i][1])/2}))});m.paths.push(p);};
 path('Approach road',[[0,-115],[0,-60],[0,-29],[0,-4]],6,5);path('Courtyard crosswalk',[[-25,-18],[0,-18],[25,-18]],3,2);path('Courtyard ring',[[-22,-18],[-22,22],[22,22],[22,-18]],3,4);
 let seed=29471;const random=()=>((seed=Math.imul(seed,1664525)+1013904223>>>0)/4294967296);
 for(let i=0;i<90;i++){const x=(random()-.5)*236,z=(random()-.5)*236;if(Math.max(Math.abs(x),Math.abs(z))<60||Math.abs(x)<9&&z<0)continue;m.objects.push({id:m.objects.length+1,preset:i%4===0?2:0,x,z,scale:defaultScale(0)*(.6+random()*.35),rotation:random()*360,seed:42+i%4,visible:true});}
 m.spawn={x:0,z:-59,yaw:0};return validateMap(m);
}
