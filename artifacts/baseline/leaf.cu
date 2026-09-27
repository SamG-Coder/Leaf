// All geometry, lighting, visibility and pixel colour are authored in CUDA.
__device__ unsigned int hash(unsigned int x){x ^= x >> 16; x *= 2146121005u; x ^= x >> 15; x *= 2221713035u; x ^= x >> 16; return x;}
__device__ float rnd(unsigned int x){return (float)(hash(x)&16777215u)/16777216.0f;}
__device__ float3 center(unsigned int c,unsigned int seed){
 float a=(float)c*2.399963f+rnd(seed)*6.28f;
 float h=rnd(c*37u+seed+11u);
 float r=sqrtf(rnd(c*73u+seed+9u))*3.1f*sqrtf(1.0f-0.55f*h);
 return make_float3(cosf(a)*r,3.3f+h*3.4f,sinf(a)*r);
}
__device__ float3 normdir(float a,float e){return make_float3(cosf(a)*cosf(e),sinf(e),sinf(a)*cosf(e));}
__device__ float exposure(float3 n,float3 p,float3 l){
 float lam=fabsf(n.x*l.x+n.y*l.y+n.z*l.z);
 float side=(p.x*l.x+(p.y-4.8f)*l.y+p.z*l.z)/3.7f;
 float shelter=fminf(1.0f,fmaxf(0.12f,0.5f+side*0.48f));
 return 0.18f+0.82f*lam*shelter;
}
__device__ float3 project(float3 p,float yaw,float tilt,float scale,int w,int h){
 float x=p.x*cosf(yaw)-p.z*sinf(yaw);
 float z=p.x*sinf(yaw)+p.z*cosf(yaw);
 float y=p.y-3.6f;
 return make_float3((float)w*0.5f+x*scale,(float)h*0.51f-(y*cosf(tilt)-z*sinf(tilt))*scale,z*cosf(tilt)+y*sinf(tilt));
}
__device__ unsigned int key(float z,unsigned int id){return ((unsigned int)(fminf(16382.0f,fmaxf(0.0f,(z+16.0f)*480.0f)))<<18)|id;}
__global__ void generate(float4* pos,float4* normal,unsigned int seed,unsigned int n){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
 unsigned int c=i%128u;unsigned int s=hash(seed+c*719u)^hash(i/128u+31u);
 float3 p=center(c,seed);
 float a=rnd(s+1u)*6.283185f;float e=(rnd(s+2u)-0.5f)*3.14159f;
 float rr=powf(rnd(s+3u),0.333333f);
 p.x+=cosf(a)*cosf(e)*rr*0.94f;p.y+=sinf(e)*rr*0.7f;p.z+=sinf(a)*cosf(e)*rr*0.94f;
 float na=rnd(s+4u)*6.283185f;float ne=(rnd(s+5u)-0.5f)*2.7f;
 pos[i]=make_float4(p.x,p.y,p.z,0.025f+rnd(s+6u)*0.022f);
 normal[i]=make_float4(na,ne,rnd(s+7u),0.0f);
}
__global__ void lighting(float* light,unsigned int seed,int bins,float lx,float ly,float lz){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;unsigned int nb=(unsigned int)(bins*bins/2);if(i>=128u*nb)return;
 unsigned int b=i%nb;float a=((float)(b%(unsigned int)bins)+0.5f)*6.283185f/(float)bins;
 float e=(((float)(b/(unsigned int)bins)+0.5f)/(float)(bins/2)-0.5f)*2.7f;
 light[i]=exposure(normdir(a,e),center(i/nb,seed),make_float3(lx,ly,lz));
}
__global__ void clear(unsigned int* depth,int pixels){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<(unsigned int)pixels)depth[i]=4294967295u;}
__global__ void raster(const float4* pos,const float4* normal,unsigned int* depth,unsigned int n,int w,int h,float yaw,float tilt,float scale,float time,float wind){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
 float4 v=pos[i];float4 nm=normal[i];float3 p=make_float3(v.x,v.y,v.z);
 p.x+=sinf(time*1.5f+p.y*0.9f+p.z)*wind*(p.y/7.0f);p.z+=cosf(time+p.x)*wind*0.35f;
 float3 q=project(p,yaw,tilt,scale,w,h);
 float3 nn=normdir(nm.x,nm.y);float facing=fabsf(nn.x*sinf(yaw)*cosf(tilt)+nn.y*sinf(tilt)+nn.z*cosf(yaw)*cosf(tilt));
 float ra=fmaxf(1.0f,v.w*scale);float rb=ra*(0.24f+0.5f*facing);float angle=nm.x+yaw+0.25f*sinf(time+nm.z*9.0f)*wind;
 int r=(int)ceilf(ra+1.0f);unsigned int k=key(q.z,i);
 for(int dy=-r;dy<=r;dy++){for(int dx=-r;dx<=r;dx++){
 int x=(int)q.x+dx;int y=(int)q.y+dy;if(x<0||y<0||x>=w||y>=h)continue;
 float fx=(float)x+0.5f-q.x;float fy=(float)y+0.5f-q.y;
 float u=(fx*cosf(angle)+fy*sinf(angle))/ra;float v2=(-fx*sinf(angle)+fy*cosf(angle))/rb;
 if(u*u+v2*v2<1.0f)atomicMin(&depth[y*w+x],k);
 }}
}
__global__ void branches(unsigned int* depth,unsigned int seed,int w,int h,float yaw,float tilt,float scale){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>128u)return;
 float3 b=center(i%128u,seed);float3 a=make_float3(0.0f,1.6f+(b.y-3.3f)*0.55f,0.0f);
 float radius=0.027f;
 if(i==128u){a=make_float3(0.0f,0.0f,0.0f);b=make_float3(0.12f,5.5f,0.0f);radius=0.18f;}
 float3 aa=project(a,yaw,tilt,scale,w,h);float3 bb=project(b,yaw,tilt,scale,w,h);
 int steps=(int)(sqrtf((aa.x-bb.x)*(aa.x-bb.x)+(aa.y-bb.y)*(aa.y-bb.y))*1.5f)+1;
 for(int j=0;j<=steps;j++){float t=(float)j/(float)steps;float x=aa.x+(bb.x-aa.x)*t;float y=aa.y+(bb.y-aa.y)*t;float z=aa.z+(bb.z-aa.z)*t;
 float rad=fmaxf(0.7f,radius*scale*(1.0f-t*0.65f));int r=(int)ceilf(rad);
 for(int dy=-r;dy<=r;dy++){for(int dx=-r;dx<=r;dx++){int px=(int)x+dx;int py=(int)y+dy;if(px>=0&&py>=0&&px<w&&py<h&&(float)(dx*dx+dy*dy)<=rad*rad)atomicMin(&depth[py*w+px],key(z,250000u+i));}}
 }
}
__global__ void resolve(const unsigned int* depth,const float4* pos,const float4* normal,const float* light,unsigned int* pixels,int w,int h,int bins,int mode,float lx,float ly,float lz,float yaw,float tilt,float scale){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;
 unsigned int k=depth[i];float y=(float)(i/(unsigned int)w)/(float)h;float x=(float)(i%(unsigned int)w)/(float)w;
 float r=0.055f+y*0.045f;float g=0.085f+y*0.065f;float b=0.095f+y*0.065f;
 float3 base=project(make_float3(0.0f,0.0f,0.0f),yaw,tilt,scale,w,h);
 float sx=((float)(i%(unsigned int)w)-base.x)/(scale*3.3f);float sy=((float)(i/(unsigned int)w)-base.y)/(scale*0.44f);
 float shadow=expf(-sx*sx-sy*sy)*0.50f;r*=1.0f-shadow;g*=1.0f-shadow;b*=1.0f-shadow;
 if(k!=4294967295u){unsigned int id=k&262143u;
 if(id>=250000u){float grain=rnd(i)*0.05f;r=0.22f+grain;g=0.14f+grain;b=0.075f+grain;}
 else{float4 nm=normal[id];float4 p=pos[id];int az=(int)(nm.x/6.283185f*(float)bins);int el=(int)((nm.y/2.7f+0.5f)*(float)(bins/2));
 int nb=bins*bins/2;unsigned int group=(id%128u)*(unsigned int)nb+(unsigned int)(el*bins+az);
 float grouped=light[group];float exact=grouped;
 if(mode==1||mode==3)exact=exposure(normdir(nm.x,nm.y),make_float3(p.x,p.y,p.z),make_float3(lx,ly,lz));
 float e=grouped;if(mode==1)e=exact;
 float pigment=0.8f+nm.z*0.35f;r=(0.10f+e*0.38f)*pigment;g=(0.19f+e*0.53f)*pigment;b=(0.045f+e*0.12f)*pigment;
 if(mode==2){r=rnd(group+3u)*0.8f+0.1f;g=rnd(group+9u)*0.8f+0.1f;b=rnd(group+17u)*0.8f+0.1f;}
 if(mode==3){float err=fminf(1.0f,fabsf(grouped-exact)*5.0f);r=err;g=0.12f+0.2f*(1.0f-err);b=0.22f*(1.0f-err);}
 }}
 pixels[i]=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,b)*255.0f)<<16)|4278190080u;
}
