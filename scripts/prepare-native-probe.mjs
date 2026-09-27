import {readFile,writeFile,mkdir} from 'node:fs/promises';
const files=['leaf.cu','map.cu','water-fft.cu','paths.cu','scene.cu','buildings.cu','water.cu','weather.cu','shadows.cu'];
const sources=await Promise.all(files.map(f=>readFile(`src/${f}`,'utf8')));
const declarations=sources.flatMap(s=>[...s.matchAll(/(__device__\s+[\w]+\s+\w+\([^{}]*?\))\s*\{/g)].map(m=>m[1]+';'));
await mkdir('Native/build',{recursive:true});
await writeFile('Native/build/kernels.cu','#include <cuda_runtime.h>\n#include <cmath>\n'+declarations.join('\n')+'\n'+files.map(f=>`#include "../../src/${f}"`).join('\n')+'\n#include "../probe.cuh"\n');
console.log(`Prepared native source: ${sources.join('\n').match(/__global__ void /g).length} kernels; no shader body rewrites.`);
