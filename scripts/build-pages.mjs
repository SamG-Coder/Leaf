import {cp,mkdir,readdir,writeFile} from 'node:fs/promises';
await mkdir('dist',{recursive:true});
for(const file of await readdir('.'))if(/\.(html|css)$/.test(file))await cp(file,`dist/${file}`);
for(const dir of ['src','generated','vendor','artifacts','docs'])await cp(dir,`dist/${dir}`,{recursive:true});
await cp('README.md','dist/README.md');await writeFile('dist/.nojekyll','');
console.log('Static Pages site staged in dist/.');
