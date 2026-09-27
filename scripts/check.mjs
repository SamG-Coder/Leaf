import {readdir} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
for(const dir of ['src','scripts'])for(const entry of await readdir(dir))if(/\.(mjs|js)$/.test(entry))execFileSync(process.execPath,['--check',`${dir}/${entry}`],{stdio:'inherit'});
console.log('JavaScript syntax checks passed.');
