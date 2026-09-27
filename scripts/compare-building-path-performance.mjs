import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
const before=JSON.parse(await readFile(process.argv[2]??'artifacts/building-path-performance-before.json','utf8'));
const after=JSON.parse(await readFile(process.argv[3]??'artifacts/building-path-performance-after.json','utf8'));
assert.deepEqual(before.resolution,after.resolution);assert(before.parity.equal&&after.parity.equal);
assert.deepEqual(before.parity.normal,after.parity.normal);
assert.equal(before.results.length,after.results.length);
let frames=0;
for(let i=0;i<before.results.length;i++){
 const a=before.results[i],b=after.results[i];assert.equal(a.name,b.name);assert.deepEqual(a.checkpoints,b.checkpoints,a.name+' changed colour/depth/picking/shadows');frames+=a.checkpoints.length;
 console.log(`${a.name}: median ${a.timing.total.p50.toFixed(2)} -> ${b.timing.total.p50.toFixed(2)} ms; p95 ${a.timing.total.p95.toFixed(2)} -> ${b.timing.total.p95.toFixed(2)} ms`);
}
console.log(`${frames} rendered checkpoints match exactly across colour, depth, picking and shadows.`);
