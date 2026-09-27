import {emptyMap,terrainHeight,validateMap} from './map-model.js';
import {defaultScale} from './asset-scale.js';
import {insidePlan,planOutline,planCells} from './plan-model.js';
// One kilometre map: offshore margin, coastal shelf, wooded uplands and an estuary.
export function islandExample(){
 const m=emptyMap();m.name='Island - 1 km';m.extent=1000;m.environment={...m.environment,enabled:true,hour:14};m.light={azimuth:235,elevation:38};m.water.ocean={enabled:true,level:0};m.water.weather={windDirection:35,windSpeed:3,rain:0};
 const riverX=z=>28*Math.sin((z+80)/100);
 const height=(x,z)=>{const a=Math.atan2(z,x),r=Math.hypot(x/1.06,z),shore=350+24*Math.sin(a*3)+16*Math.cos(a*5),inland=shore-r;let h=inland<0?inland*.18:Math.min(24,inland*.20);h+=65*Math.exp(-((x+135)**2+(z+100)**2)/10000)*Math.min(1,Math.max(0,inland/80))+42*Math.exp(-((x-150)**2+(z+95)**2)/6500);if(z>-95&&z<390){const d=Math.abs(x-riverX(z));const cut=Math.max(0,Math.min(1,(58-d)/36));const blend=cut*cut*(3-2*cut);h=h*(1-blend)+(-4)*blend;}const lake=Math.hypot(x,z+55);if(lake<70)h=Math.min(h,-3+(lake/70)**4*15);return h;};
 for(let z=0;z<65;z++)for(let x=0;x<65;x++)m.terrain[z*65+x]=height((x/64-.5)*1000,(z/64-.5)*1000);
 const addPlan=(name,type,vertices,extra={})=>m.plans.push({id:m.plans.length+1,name,type,vertices,visible:true,seed:42,spacing:4,scale:.7,preset:61,level:0,kind:'lake',smooth:true,randomRotation:true,...extra});
 const oval=(x,z,rx,rz)=>Array.from({length:12},(_,i)=>({x:x+Math.cos(i*Math.PI/6)*rx,z:z+Math.sin(i*Math.PI/6)*rz}));
 addPlan('Inland lagoon','water',oval(0,-55,68,68),{level:.1});
 const riverZ=[-70,-10,50,110,170,230,290,350,400];
 addPlan('River to the southern bay','water',[...riverZ.map(z=>({x:riverX(z)-36,z})),...riverZ.toReversed().map(z=>({x:riverX(z)+36,z}))],{level:.1,flowEnabled:true,flowDirection:90,flowSpeed:.8});
 for(const [name,x,z,rx,rz,preset] of [['West meadow',-140,115,90,95,61],['East meadow',155,100,85,90,62],['Northern clearing',30,-225,75,45,67],['Coastal meadow',-180,-215,50,40,65]])addPlan(name,'grass',oval(x,z,rx,rz),{preset,seed:100+m.plans.length,spacing:4});
 // Clip authored grass footprints to dry, gently sloping land before committing the example.
 m.plans=m.plans.filter(p=>p.type==='water'||planCells(p).every(c=>terrainHeight(m,c.x,c.z)>3));
 let seed=87191;const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;};
 const grass=m.plans.filter(p=>p.type==='grass').map(planOutline);
 const place=(preset,x,z,factor=1)=>m.objects.push({id:m.objects.length+1,preset,x,z,scale:Math.min(3,defaultScale(preset)*factor),rotation:random()*360,seed:42+Math.floor(random()*4),visible:true});
 for(let z=-335;z<335;z+=12)for(let x=-360;x<360;x+=12){const xx=x+(random()-.5)*7,zz=z+(random()-.5)*7,h=terrainHeight(m,xx,zz);if(h<6||grass.some(v=>insidePlan(xx,zz,v))||Math.abs(xx-riverX(zz))<53&&zz>-110||random()<.24)continue;const slope=Math.hypot(terrainHeight(m,xx+3,zz)-h,terrainHeight(m,xx,zz+3)-h)/3;if(slope>1)continue;place(h>38?4:random()<.65?0:2,xx,zz,.7+random()*.25);if(random()<.4)place(31,xx+3,zz+2,.9);if(random()<.13)place(111,xx-3,zz+3,.8);if(random()<.15)place(81,xx+2,zz-2,.8);}
 for(let i=0;i<500;i++){const x=(random()-.5)*700,z=(random()-.5)*700,h=terrainHeight(m,x,z);if(h<1||h>75)continue;if(h<5)place(91+Math.floor(random()*5),x,z,.8+random()*.8);else if(grass.some(v=>insidePlan(x,z,v)))place(random()<.5?21:24,x,z,.8);else if(Math.abs(x-riverX(z))>50)place(random()<.5?11:41,x,z,.8);}
 return validateMap(m);
}
