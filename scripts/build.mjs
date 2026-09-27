import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {compile,serializableArtifact} from '../vendor/cuda-webshader/compiler/compiler.js';
const source=await readFile(new URL('../src/leaf.cu',import.meta.url),'utf8');
await mkdir(new URL('../generated/',import.meta.url),{recursive:true});
for(const entry of ['wood','generate','clusters','lighting','clear','raster','branches','resolve']){
 const a=compile(source,{entry,workgroupSize:[128,1,1]});
 await writeFile(new URL(`../generated/${entry}.json`,import.meta.url),JSON.stringify(serializableArtifact(a)));
 console.log(`${entry}: compiled`);
}


const mapSource=await readFile(new URL('../src/map.cu',import.meta.url),'utf8');
const mapArtifact=compile(mapSource,{entry:'map_render',workgroupSize:[128,1,1]});
await writeFile(new URL('../generated/map_render.json',import.meta.url),JSON.stringify(serializableArtifact(mapArtifact)));console.log('map_render: compiled');

const sceneText=await readFile(new URL('../src/scene.cu',import.meta.url),'utf8');const waterText=await readFile(new URL('../src/water.cu',import.meta.url),'utf8');const sceneSource=source+'\n'+sceneText.replace('__global__ void scene_ground',waterText+'\n__global__ void scene_ground');
for(const entry of ['scene_ground','scene_splat','scene_anime','scene_style_clear','scene_style_stats','scene_style_blur','ground_cover_clear','ground_cover_stamp','scene_triangles','scene_water']){const artifact=compile(sceneSource,{entry,workgroupSize:[128,1,1]});await writeFile(new URL(`../generated/${entry}.json`,import.meta.url),JSON.stringify(serializableArtifact(artifact)));console.log(`${entry}: compiled`);}
