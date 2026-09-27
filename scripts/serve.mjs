import http from 'node:http';
import {readFile} from 'node:fs/promises';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const types={'.html':'text/html','.js':'text/javascript','.json':'application/json','.css':'text/css','.cu':'text/plain'};
http.createServer(async(req,res)=>{
 try{const url=new URL(req.url,'http://localhost'); if(url.pathname==='/favicon.ico'){res.writeHead(204);res.end();return;}
 const file=path.resolve(root,'.'+decodeURIComponent(url.pathname==='/'?'/index.html':url.pathname));
 if(!file.startsWith(root+path.sep))throw Error('Invalid path');
 const data=await readFile(file);res.writeHead(200,{'Content-Type':types[path.extname(file)]||'application/octet-stream','Cache-Control':'no-store','Cross-Origin-Opener-Policy':'same-origin','Cross-Origin-Embedder-Policy':'require-corp'});res.end(data);
 }catch{res.writeHead(404);res.end('Not found');}
}).listen(5197,'127.0.0.1',()=>console.log('Leaf: http://127.0.0.1:5197'));

