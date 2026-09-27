import {presetFor} from './species.js';
export const LIMIT=100000;
export const MAX_EXTENT=65536,TILE_CELLS=32,TERRAIN_CELL=2,MAX_TILES=4096;
export function emptyMap(){return {format:'leaf-map',version:1,name:'Untitled woodland',extent:32,light:{azimuth:305,elevation:40},terrain:Array(65*65).fill(0),terrainTiles:{},objects:[]};}
export function validateMap(input){
 if(!input||input.format!=='leaf-map'||input.version!==1)throw Error('Unsupported map format or version.');
 if(typeof input.name!=='string'||input.name.length>100)throw Error('Map name must be 100 characters or fewer.');
 if(!Number.isFinite(input.extent)||input.extent<8||input.extent>MAX_EXTENT)throw Error('Map size must be between 8 and 65536 metres.');
 if(!input.light||!Number.isFinite(input.light.azimuth)||input.light.azimuth<0||input.light.azimuth>360||!Number.isFinite(input.light.elevation)||input.light.elevation<5||input.light.elevation>85)throw Error('Invalid sunlight settings.');
 if(!Array.isArray(input.objects)||input.objects.length>LIMIT)throw Error(`A map supports up to ${LIMIT} objects.`);
 const terrain=input.terrain??Array(65*65).fill(0);if(!Array.isArray(terrain)||terrain.length!==65*65||terrain.some(v=>!Number.isFinite(v)||v< -256||v>2048))throw Error('Terrain must contain 65 × 65 heights between -256 and 2048.');
 const terrainTiles={};if(input.terrainTiles!==undefined){if(!input.terrainTiles||typeof input.terrainTiles!=='object'||Array.isArray(input.terrainTiles)||Object.keys(input.terrainTiles).length>MAX_TILES)throw Error('Terrain supports up to 4096 edited tiles.');for(const [key,values] of Object.entries(input.terrainTiles)){if(!/^-?\d+,-?\d+$/.test(key)||key.split(',').some(v=>Math.abs(Number(v))>1024)||!Array.isArray(values)||values.length!==1024||values.some(v=>!Number.isFinite(v)||v< -256||v>2048))throw Error('Invalid terrain tile.');terrainTiles[key]=[...values];}}
 const ids=new Set();const objects=input.objects.map(o=>{if(!o||!Number.isInteger(o.id)||o.id<1||o.id>1000000||ids.has(o.id))throw Error('Object IDs must be unique positive integers.');ids.add(o.id);const preset=presetFor(o.preset).id;
 for(const k of ['x','z','scale','rotation'])if(!Number.isFinite(o[k]))throw Error('Object transforms must be finite.');
 if(Math.abs(o.x)>input.extent/2||Math.abs(o.z)>input.extent/2||o.scale<.1||o.scale>3||o.rotation<0||o.rotation>=360||!Number.isInteger(o.seed)||o.seed<0||o.seed>4294967295||typeof o.visible!=='boolean')throw Error('Object is outside supported bounds.');
 return {id:o.id,preset,x:o.x,z:o.z,scale:o.scale,rotation:o.rotation,seed:o.seed,visible:o.visible};});
 return {format:'leaf-map',version:1,name:input.name,extent:input.extent,light:{azimuth:input.light.azimuth,elevation:input.light.elevation},terrain:[...terrain],terrainTiles,objects};
}
export class MapHistory{
 constructor(map=emptyMap()){this.map=validateMap(map);this.past=[];this.future=[];}
 commit(next){const valid=validateMap(next);if(JSON.stringify(valid)===JSON.stringify(this.map))return;this.past.push(structuredClone(this.map));while(this.past.length>1&&(this.past.length>60||this.past.reduce((bytes,m)=>bytes+m.objects.length*160+Object.keys(m.terrainTiles??{}).length*8192+34000,0)>64*1024*1024))this.past.shift();this.future=[];this.map=valid;}
 undo(){if(!this.past.length)return false;this.future.push(this.map);this.map=this.past.pop();return true;}
 redo(){if(!this.future.length)return false;this.past.push(this.map);this.map=this.future.pop();return true;}
}

function baseHeight(map,x,z){const gx=Math.max(0,Math.min(63.9999,(x/map.extent+.5)*64)),gz=Math.max(0,Math.min(63.9999,(z/map.extent+.5)*64));const ix=Math.floor(gx),iz=Math.floor(gz),u=gx-ix,v=gz-iz,t=map.terrain;return (t[iz*65+ix]*(1-u)+t[iz*65+ix+1]*u)*(1-v)+(t[(iz+1)*65+ix]*(1-u)+t[(iz+1)*65+ix+1]*u)*v;}
function baseBrush(map,x,z,radius,strength,mode,target=0){const old=[...map.terrain];for(let iz=0;iz<65;iz++)for(let ix=0;ix<65;ix++){const wx=(ix/64-.5)*map.extent,wz=(iz/64-.5)*map.extent,d=Math.hypot(wx-x,wz-z);if(d>radius)continue;const k=iz*65+ix,f=(1-d/radius)**2;let value=old[k];if(mode==='raise')value+=strength*f;if(mode==='lower')value-=strength*f;if(mode==='flatten')value+=(target-value)*Math.min(1,strength*2)*f;if(mode==='smooth'){let total=0,n=0;for(let dz=-1;dz<=1;dz++)for(let dx=-1;dx<=1;dx++){const xx=ix+dx,zz=iz+dz;if(xx>=0&&xx<=64&&zz>=0&&zz<=64){total+=old[zz*65+xx];n++;}}value+=(total/n-value)*Math.min(1,strength*3)*f;}map.terrain[k]=Math.max(-256,Math.min(2048,value));}}

function node(map,x,z){const tx=Math.floor(x/32),tz=Math.floor(z/32);return map.terrainTiles?.[`${tx},${tz}`]?.[(z-tz*32)*32+x-tx*32]??0;}
export function terrainHeight(map,x,z){const gx=x/2,gz=z/2,ix=Math.floor(gx),iz=Math.floor(gz),u=gx-ix,v=gz-iz;return baseHeight(map,x,z)+(node(map,ix,iz)*(1-u)+node(map,ix+1,iz)*u)*(1-v)+(node(map,ix,iz+1)*(1-u)+node(map,ix+1,iz+1)*u)*v;}
export function brushTerrain(map,x,z,radius,strength,mode,target=0){if(![x,z,radius,strength,target].every(Number.isFinite)||radius<=0)return;if(map.extent<=128&&!Object.keys(map.terrainTiles??{}).length)return baseBrush(map,x,z,radius,strength,mode,target);
 map.terrainTiles??={};const updates=[];for(let iz=Math.floor((z-radius)/2);iz<=Math.ceil((z+radius)/2);iz++)for(let ix=Math.floor((x-radius)/2);ix<=Math.ceil((x+radius)/2);ix++){if(Math.abs(ix*2)>map.extent/2||Math.abs(iz*2)>map.extent/2)continue;const d=Math.hypot(ix*2-x,iz*2-z);if(d>radius)continue;const f=(1-d/radius)**2,old=node(map,ix,iz);let value=old;if(mode==='raise')value+=strength*f;if(mode==='lower')value-=strength*f;if(mode==='flatten')value+=(target-baseHeight(map,ix*2,iz*2)-value)*Math.min(1,strength*2)*f;if(mode==='smooth'){let total=0;for(let dz=-1;dz<=1;dz++)for(let dx=-1;dx<=1;dx++)total+=node(map,ix+dx,iz+dz);value+=(total/9-value)*Math.min(1,strength*3)*f;}updates.push([ix,iz,Math.max(-256,Math.min(2048,value))]);}
 const newKeys=new Set(updates.map(([ix,iz])=>`${Math.floor(ix/32)},${Math.floor(iz/32)}`).filter(k=>!map.terrainTiles[k]));if(newKeys.size+Object.keys(map.terrainTiles).length>MAX_TILES)throw Error('Edited terrain tile limit reached.');for(const [ix,iz,value] of updates){const tx=Math.floor(ix/32),tz=Math.floor(iz/32),key=`${tx},${tz}`;map.terrainTiles[key]??=Array(1024).fill(0);map.terrainTiles[key][(iz-tz*32)*32+ix-tx*32]=value;}}
