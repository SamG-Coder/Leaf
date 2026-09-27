import assert from 'node:assert/strict';
import {castleExample} from '../src/castle-example.js';
import {newBuilding,validateBuildings,buildingSockets,stairSteps} from '../src/building-model.js';
import {BuildingCollision} from '../src/building-collision.js';
import {PlayController} from '../src/play-controller.js';
import {validateMap} from '../src/map-model.js';
const m=castleExample();assert.deepEqual(validateMap(JSON.parse(JSON.stringify(m))),m);
for(let type=13;type<25;type++){const p=newBuilding(1,type,0,0);assert.equal(validateBuildings([p],256)[0].type,type);assert(new BuildingCollision({...m,buildings:[p]}).cells.size>0);}
const wall=newBuilding(1,2,0,0),battlement=newBuilding(2,13,0,0);assert(buildingSockets(wall,battlement).some(s=>s.level===wall.level+wall.height));
const p=new PlayController(m);for(let i=0;i<930;i++)p.step(1/60,new Set(['KeyW']));console.log('Gate route',p.x,p.y,p.z);assert(p.z>5&&p.y>=2.29,'walk across bridge, main gate and keep entrance');assert(!p.swimming);
function walk(x,z,yaw,frames){const p=new PlayController({...m,spawn:{x,z,yaw}});for(let i=0;i<frames;i++)p.step(1/60,new Set(['KeyW']));return p;}
// Walk every compact switchback in local coordinates, including both landings.
for(const [x,z,rotation]of [[-23.5,-10,0],[23.5,10,180],[0,23.5,90],[-14,-23.5,270]]){
 const a=rotation*Math.PI/180,world=(dx,dz)=>({x:x+dx*Math.cos(a)-dz*Math.sin(a),z:z+dx*Math.sin(a)+dz*Math.cos(a)}),start=world(-1.5,-3.4),p=new PlayController({...m,spawn:{...start,yaw:-rotation}});
 for(const [yaw,frames]of [[-rotation,98],[90-rotation,43],[180-rotation,97]]){p.yaw=yaw*Math.PI/180;for(let i=0;i<frames;i++)p.step(1/60,new Set(['KeyW']));}
 console.log('Switchback',x,z,p.x,p.y,p.z);assert(p.y>=8.99,'switchback reaches wall walk');
}
const tower=walk(-29.8,24.9,0,89);assert(tower.y>=5.29,'round tower first landing');
for(const [yaw,frames]of [[Math.PI/2,52],[Math.PI,89],[-Math.PI/2,52],[0,89],[Math.PI/2,52],[Math.PI,89]]){tower.yaw=yaw;for(let i=0;i<frames;i++)tower.step(1/60,new Set(['KeyW']));}console.log('Round tower roof',tower.x,tower.y,tower.z);assert(tower.y>=14.29,'round tower stairs reach the roof');
const gate=m.buildings.find(p=>p.name==='Main gate arch'),c=new BuildingCollision({...m,buildings:[gate]});let inside={x:0,y:2,z:-28};c.resolve(inside);assert.equal(inside.z,-28,'arch opening stays open');inside={x:3.5,y:2,z:-28};c.resolve(inside);assert(Math.hypot(inside.x-3.5,inside.z+28)>.1,'gate jamb is solid');
console.log('Castle persistence, new shapes, battlement sockets, bridge/gate/keep route, wall and tower stairs passed.');

assert.equal(stairSteps(3.5),14);assert.equal(stairSteps(32),128);
for(const height of [.15,1,3,3.5,9,32])assert(height/stairSteps(height)<=.25);
const quarter=newBuilding(1,24,0,0),quarters=buildingSockets(quarter,{...quarter,id:2});assert(quarters.some(s=>s.level===quarter.level&&s.rotation===90));
const circle={...newBuilding(1,19,0,0),level:0},circular=new BuildingCollision({...m,buildings:[circle]});assert.equal(circular.floor(0,0,3,0),0,'round walls stay hollow');assert.equal(circular.floor(2,2,3,0),3,'round wall cap is solid');
const curved=new BuildingCollision({...m,buildings:[quarter]});assert.equal(curved.floor(-2,2,3,0),0,'quarter circle leaves other quadrants open');assert.equal(curved.floor(2,2,3,0),3);
for(const [type,x,z,expected]of [[21,0,0,3],[21,1,0,2],[22,1,1,2],[23,1,0,3]]){const roof=newBuilding(1,type,0,0),collision=new BuildingCollision({...m,buildings:[roof]});assert(Math.abs(collision.floor(x,z,3,0)-expected)<1e-6,'roof slope profile '+type);}
console.log('Adaptive risers, circular wall hollows, quarter sockets and roof slope profiles passed.');
