import {emptyMap} from './map-model.js';
import {defaultScale} from './asset-scale.js';
// Deterministic authored distribution; the asset shapes still come from CUDA.
export function forestExample(){
 const map=emptyMap();map.name='Forest hills - stress test';map.extent=512;map.light={azimuth:245,elevation:32};
 let seed=73191;const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296;};
 const hill=(x,z,cx,cz,r,h)=>h*Math.exp(-((x-cx)**2+(z-cz)**2)/(r*r));
 for(let z=0;z<65;z++)for(let x=0;x<65;x++){const wx=(x/64-.5)*512,wz=(z/64-.5)*512;map.terrain[z*65+x]=hill(wx,wz,-75,70,85,42)+hill(wx,wz,110,110,65,58)+hill(wx,wz,-145,-100,75,32)+hill(wx,wz,160,-100,90,26)+3*Math.sin(wx/43)*Math.cos(wz/59);}
 const trail=z=>18*Math.sin(z/42)+8*Math.sin(z/19);
 const clearing=(x,z)=>Math.hypot(x-15,z+32)<22;
 function place(preset,x,z,factor=1){map.objects.push({id:map.objects.length+1,preset,x,z,scale:Math.min(3,defaultScale(preset)*factor),rotation:random()*360,seed:42+Math.floor(random()*4),visible:true});}
 // Jittered spacing keeps trunks apart; terrain regions favour different canopy species.
 for(let z=-240;z<=240;z+=10)for(let x=-240;x<=240;x+=10){const wx=x+(random()-.5)*6,wz=z+(random()-.5)*6;if(Math.abs(wx-trail(wz))<7||clearing(wx,wz)||random()<.13)continue;const r=random();const preset=wz>30?(r<.65?4:r<.85?2:0):(r<.52?0:r<.80?2:1);place(preset,wx,wz,.65+random()*.35);}
 // Understory follows shaded edges; grass and flowers occupy the glade and trail margins.
 for(let i=0;i<6000;i++){const x=(random()-.5)*480,z=(random()-.5)*480,edge=Math.abs(x-trail(z));if(edge<3)continue;const open=clearing(x,z)||edge<10;const choices=open?[61,62,67,21,24,29]:[31,34,37,41,44,49,81,84,11,16,101,105,109,111,113,115,95];const preset=choices[Math.floor(random()*choices.length)];place(preset,x,z,.7+random()*.5);}
 return map;
}
