import assert from 'node:assert/strict';
import {newPath,validatePaths,buildPathIndex,hitPath,pathPoint,PATH_TYPES} from '../src/path-model.js';
import {emptyMap,validateMap,MapHistory,terrainHeight,brushTerrain} from '../src/map-model.js';
const map=emptyMap();map.extent=128;const p=newPath(1,0,0,128);p.nodes=[{id:1,x:-20,z:0},{id:2,x:20,z:0},{id:3,x:20,z:20}];p.edges=[{id:1,a:1,b:2,x:0,z:20},{id:2,a:2,b:3,x:20,z:10}];map.paths=[p];const q=pathPoint(p.nodes[0],p.edges[0],p.nodes[1],.5);assert.equal(q.z,10);const index=buildPathIndex(map.paths,128);assert(hitPath(index,q.x,q.z));assert(!hitPath(index,0,0));assert(hitPath(index,20,10));assert.equal(PATH_TYPES.length,14);for(let material=0;material<14;material++)assert.equal(validatePaths([{...p,material}],128)[0].material,material);
assert.deepEqual(validateMap(JSON.parse(JSON.stringify(map))).paths,map.paths);const legacy={...map};delete legacy.paths;assert.deepEqual(validateMap(legacy).paths,[]);
for(const bad of [{...p,width:NaN},{...p,material:14},{...p,nodes:[p.nodes[0]]},{...p,edges:[{...p.edges[0],b:9}]},{...p,edges:[p.edges[0],p.edges[0]]},{...p,nodes:p.nodes.map(n=>({...n,x:Infinity}))}])assert.throws(()=>validatePaths([bad],128));
const history=new MapHistory(map);history.commit({...map,paths:[]});history.undo();assert.equal(history.map.paths.length,1);history.redo();assert.equal(history.map.paths.length,0);
const before=terrainHeight(map,0,10);brushTerrain(map,0,10,8,3,'raise');assert(terrainHeight(map,0,10)>before);assert.deepEqual(map.paths,[p]);
console.log('Spline curvature, junctions, 14 materials, spatial hit tests, validation, terrain attachment data, legacy maps, persistence and undo/redo passed.');
