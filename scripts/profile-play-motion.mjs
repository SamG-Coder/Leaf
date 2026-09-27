import assert from 'node:assert/strict';
import {PlayController} from '../src/play-controller.js';
import {emptyMap} from '../src/map-model.js';
const results=[];
for(const hz of [60,120,144,165])for(const sprint of [false,true]){
 const map=emptyMap();map.extent=128;const p=new PlayController(map),keys=new Set(sprint?['KeyW','ShiftLeft']:['KeyW']),view={},speeds=[];
 let previous=0;
 for(let i=0;i<hz*3;i++){p.step(1/hz,keys);p.camera(view);if(i>hz)speeds.push((view.position[2]-previous)*hz);previous=view.position[2];}
 const mean=speeds.reduce((a,b)=>a+b)/speeds.length;
 results.push({hz,mode:sprint?'sprint':'walk',stationaryFrames:speeds.filter(v=>Math.abs(v)<1e-8).length,frames:speeds.length,meanSpeed:mean,speedStdDev:Math.sqrt(speeds.reduce((a,b)=>a+(b-mean)**2,0)/speeds.length)});
}
for(const result of results){assert.equal(result.stationaryFrames,0);assert(result.speedStdDev<1e-8);assert(Math.abs(result.meanSpeed-(result.mode==='sprint'?7:4.2))<1e-8);}
// Irregular presentation intervals should still track elapsed time, including multiple ticks.
const map=emptyMap();map.extent=128;const player=new PlayController(map),view={};let elapsed=0;
for(let i=0;i<200;i++){const dt=[.007,.011,.022,.009,.035][i%5];elapsed+=dt;player.step(dt,new Set(['KeyW']));player.camera(view);assert(Math.abs(view.position[2]-4.2*Math.max(0,elapsed-1/60))<1e-8);}
player.yaw=1.2;player.pitch=.3;player.camera(view);assert.equal(view.yaw,1.2);assert.equal(view.pitch,.3);
player.reset();player.camera(view);assert.deepEqual(view.position,[0,1.65,0]);
console.log(JSON.stringify(results,null,2));
