import assert from 'node:assert/strict';
import {emptyMap,validateMap,MapHistory,brushTerrain,terrainHeight} from '../src/map-model.js';
const map=emptyMap();map.objects.push({id:1,preset:113,x:0,z:0,scale:1,rotation:0,seed:42,visible:true});const h=new MapHistory(map),next=structuredClone(map);brushTerrain(next,0,0,3,1,'raise');h.commit(next);assert(terrainHeight(h.map,0,0)>.9);h.undo();assert.equal(terrainHeight(h.map,0,0),0);h.redo();assert(terrainHeight(h.map,0,0)>.9);assert.deepEqual(validateMap(JSON.parse(JSON.stringify(h.map))),h.map);
for(const invalid of [{...map,terrain:[0]},{...map,objects:[...map.objects,...map.objects]},{...map,objects:[{...map.objects[0],scale:NaN}]},{...map,version:2},{...map,extent:65537}])assert.throws(()=>validateMap(invalid));
console.log('Model: validation, terrain attachment heights, undo/redo and JSON round-trip passed.');

const sculpt=emptyMap();brushTerrain(sculpt,0,0,2,1,'raise');const raised=terrainHeight(sculpt,0,0);brushTerrain(sculpt,0,0,2,.25,'lower');assert(terrainHeight(sculpt,0,0)<raised);brushTerrain(sculpt,0,0,2,1,'flatten',2);assert.equal(terrainHeight(sculpt,0,0),2);brushTerrain(sculpt,0,0,2,1,'smooth');assert(terrainHeight(sculpt,0,0)<2);console.log('All four terrain brushes passed.');

const large=emptyMap();large.extent=65536;large.objects=[{id:1,preset:113,x:24000,z:-20000,scale:1,rotation:0,seed:42,visible:true}];brushTerrain(large,24000,-20000,16,4,'raise');assert(terrainHeight(large,24000,-20000)>3.9);assert(Object.keys(large.terrainTiles).length<10);assert.deepEqual(validateMap(JSON.parse(JSON.stringify(large))),large);const legacy=emptyMap();delete legacy.terrainTiles;assert.deepEqual(validateMap(legacy).terrainTiles,{});console.log('64 km sparse terrain and legacy map migration passed.');
