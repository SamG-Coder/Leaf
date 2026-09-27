// Artistic ground-cover influences, not a growth simulation. Shapes are painted by CUDA.
export function groundInfluence(o){
 const id=o.preset,s=o.scale;
 if(id<10)return [o.x,o.z,([3.6,3,2.2,3.5,2.5,3.7,1,0.7,3,3][id])*s,6*s,0.65*s,([4,5,7].includes(id)?2:1),0,0];
 if(id>=11&&id<=20)return [o.x,o.z,1.4*s,1.4*s,.3*s,1,0,0];
 if(id>=41&&id<=50)return [o.x,o.z,1.6*s,.1,.1,3,0,0];
 if(id>=91&&id<=100)return [o.x,o.z,1.4*s,.6*s,.8*s,4,0,0];
 if(id>=111)return [o.x,o.z,1.6*s,.5*s,.7*s,5,0,0];
 if(id>=101&&id<=110)return [o.x,o.z,1.6*s,.1,.1,6,0,0];
 return null;
}
