import assert from 'node:assert/strict';
import {cameraProjector,projectPoint} from '../src/scene-camera.js';
// Cover rotations, wide/narrow lenses, tiny depth, behind-camera and large coordinates.
let seed=42;const random=()=>((seed=Math.imul(seed,1664525)+1013904223>>>0)/4294967296);
for(let i=0;i<100;i++){
 const c={position:[random()*64000-32000,random()*1000,random()*64000-32000],yaw:random()*Math.PI*2,pitch:random()*3-1.5,fov:10+random()*150,aspect:.5+random()*2};
 const project=cameraProjector(c,1024,768);
 for(let j=0;j<100;j++){const p=j===0?[...c.position]:c.position.map(v=>v+(random()-.5)*1000);assert.deepEqual(project(...p),projectPoint(c,p,1024,768));}
}
console.log('10,000 camera projections match the reference exactly.');
