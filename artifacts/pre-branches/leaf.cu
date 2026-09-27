// All geometry, lighting, visibility and pixel colour are authored in CUDA.
__device__ unsigned int hash(unsigned int x){x ^= x >> 16; x *= 2146121005u; x ^= x >> 15; x *= 2221713035u; x ^= x >> 16; return x;}
__device__ float rnd(unsigned int x){return (float)(hash(x)&16777215u)/16777216.0f;}
// Species 0..9, grass 10. Common cluster contract is shared by both emitters.
__device__ float3 center(unsigned int c,unsigned int seed,int species){
 float a=(float)c*2.399963f+rnd(seed)*6.28f;
 float h=rnd(c*37u+seed+11u);
 float r=sqrtf(rnd(c*73u+seed+9u))*3.1f*sqrtf(1.0f-0.55f*h);
 float y=3.3f+h*3.4f;
 if(species==0){r*=1.18f;y=3.1f+h*2.8f;}
 if(species==1){r*=0.86f;y=3.0f+h*3.9f;}
 if(species==2){r*=0.62f;y=2.8f+h*4.3f;}
 if(species==3){r=1.0f+2.3f*sqrtf(rnd(c*73u+seed+9u));y=5.7f-0.16f*r*r;}
 if(species==4){h=(float)(c/8u)/16.0f;r=(2.7f*(1.0f-h)+0.08f)*(0.55f+0.45f*rnd(c+seed));y=0.9f+h*6.9f;a=(float)(c%8u)*0.785398f+(float)(c/8u)*0.6f;}
 if(species==5){r=3.4f*sqrtf(rnd(c*73u+seed+9u));y=5.9f+0.7f*sqrtf(fmaxf(0.0f,1.0f-r*r/12.0f));}
 if(species==6){r=0.80f*sinf(3.14159f*(0.1f+h*0.85f))*sqrtf(rnd(c+seed));y=1.0f+h*7.0f;}
 if(species==7){r=0.48f*powf(sinf(3.14159f*(0.05f+h*0.94f)),0.5f);y=0.5f+h*7.6f;}
 if(species==8){r*=0.85f;y=4.0f+h*3.0f;}
 if(species==9){a=(float)(c%32u)*2.399963f;float t=((float)(c/32u)+0.5f)/4.0f;r=3.1f*t;y=5.4f+2.4f*t-(2.0f+rnd(c%32u+seed)*1.8f)*t*t;}
 if(species==10){return make_float3(((float)(c%16u)+0.5f)*0.5f-4.0f,0.0f,((float)(c/16u)+0.5f)*0.75f-3.0f);}
 return make_float3(cosf(a)*r,y,sinf(a)*r);
}
__device__ float3 normdir(float a,float e){return make_float3(cosf(a)*cosf(e),sinf(e),sinf(a)*cosf(e));}
__device__ float exposure(float3 n,float3 p,float3 l,int species){
 float lam=fabsf(n.x*l.x+n.y*l.y+n.z*l.z);
 float side=(p.x*l.x+(p.y-4.8f)*l.y+p.z*l.z)/3.7f;
 if(species==10)side=0.25f;
 float shelter=fminf(1.0f,fmaxf(0.12f,0.5f+side*0.48f));
 return 0.18f+0.82f*lam*shelter;
}
__device__ float3 project(float3 p,float yaw,float tilt,float scale,int w,int h,float focus){
 float x=p.x*cosf(yaw)-p.z*sinf(yaw);
 float z=p.x*sinf(yaw)+p.z*cosf(yaw);
 float y=p.y-focus;
 return make_float3((float)w*0.5f+x*scale,(float)h*0.51f-(y*cosf(tilt)-z*sinf(tilt))*scale,z*cosf(tilt)+y*sinf(tilt));
}
__device__ unsigned int key(float z,unsigned int id){return ((unsigned int)(fminf(16382.0f,fmaxf(0.0f,(z+16.0f)*480.0f)))<<18)|id;}
__global__ void generate(float4* pos,float4* normal,float4* shape,unsigned int seed,unsigned int n,int species){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
 unsigned int c=i%128u;unsigned int s=hash(seed+c*719u)^hash(i/128u+31u);
 float3 p=center(c,seed,species);
 float a=rnd(s+1u)*6.283185f;float e=(rnd(s+2u)-0.5f)*3.14159f;
 float rr=powf(rnd(s+3u),0.333333f);
 float spread=0.8f;float vertical=0.65f;
 if(species==2){spread=0.55f;vertical=0.7f;}
 if(species==4){spread=0.22f+0.40f*(1.0f-(float)(c/8u)/16.0f);vertical=0.22f;}
 if(species==5){spread=0.6f;vertical=0.3f;}
 if(species==6){spread=0.25f;vertical=0.4f;}
 if(species==7){spread=0.16f;vertical=0.28f;}
 if(species==8){spread=0.66f;vertical=0.65f;}
 p.x+=cosf(a)*cosf(e)*rr*spread;p.y+=sinf(e)*rr*vertical;p.z+=sinf(a)*cosf(e)*rr*spread;
 if(species==3){p=center(c,seed,species);float drop=rnd(s+8u)*3.6f;p.y-=drop;p.x+=cosf(a)*0.20f+cosf((float)c)*drop*0.08f;p.z+=sinf(a)*0.20f+sinf((float)c)*drop*0.08f;}
 float na=rnd(s+4u)*6.283185f;float ne=(rnd(s+5u)-0.5f)*2.7f;
 float len=0.026f+rnd(s+6u)*0.022f;float width=0.53f;
 float3 axis=normdir(a,e);
 if(species==0){width=0.62f;len*=1.15f;}
 if(species==1){width=0.88f;len*=1.2f;}
 if(species==2){width=0.70f;len*=0.8f;}
 if(species==3){width=0.19f;len*=1.5f;axis=make_float3(0.2f*cosf(a),-1.0f,0.2f*sinf(a));}
 if(species==4){width=0.13f;len*=0.75f;}
 if(species==5){width=0.13f;len*=1.6f;}
 if(species==6){width=0.73f;len*=0.9f;}
 if(species==7){width=0.32f;len*=0.72f;axis=make_float3(cosf(a)*0.2f,1.0f,sinf(a)*0.2f);}
 if(species==8){width=0.19f;len*=2.1f;axis=make_float3(cosf(a)*0.4f,-0.9f,sinf(a)*0.4f);}
 if(species==9){
 float fa=(float)(c%32u)*2.399963f;float t=((float)(c/32u)+rnd(s+8u))/4.0f;float curve=2.0f+rnd(c%32u+seed)*1.8f;
 p=make_float3(cosf(fa)*3.1f*t,5.4f+2.4f*t-curve*t*t,sinf(fa)*3.1f*t);
 float side=1.0f;if(rnd(s+9u)<0.5f)side=-1.0f;
 len=(0.12f+0.25f*sinf(t*3.14159f))*(0.75f+0.25f*rnd(s));width=0.065f;
 axis=make_float3(cosf(fa+side*1.1f)*0.85f,-0.5f,sinf(fa+side*1.1f)*0.85f);
 p.x+=axis.x*len;p.y+=axis.y*len;p.z+=axis.z*len;
 }
 if(species==10){p=center(c,seed,species);p.x+=(rnd(s+1u)-0.5f)*0.5f;p.z+=(rnd(s+2u)-0.5f)*0.75f;p.y=0.0f;len=0.18f+0.46f*rnd(s+3u);width=0.012f;axis=make_float3(cosf(a)*0.35f,1.0f,sinf(a)*0.35f);ne=0.0f;}
 pos[i]=make_float4(p.x,p.y,p.z,len);
 shape[i]=make_float4(axis.x,axis.y,axis.z,width);
 normal[i]=make_float4(na,ne,rnd(s+7u),(float)c);
}
__global__ void clusters(float4* centers,unsigned int seed,int species){
 unsigned int c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=128u)return;float3 p=center(c,seed,species);centers[c]=make_float4(p.x,p.y,p.z,0.0f);
}
__global__ void lighting(float* light,const float4* centers,unsigned int seed,int bins,float lx,float ly,float lz,int species){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;unsigned int nb=(unsigned int)(bins*bins/2);if(i>=128u*nb)return;
 unsigned int b=i%nb;float a=((float)(b%(unsigned int)bins)+0.5f)*6.283185f/(float)bins;
 float e=(((float)(b/(unsigned int)bins)+0.5f)/(float)(bins/2)-0.5f)*2.7f;
 float4 cp=centers[i/nb];light[i]=exposure(normdir(a,e),make_float3(cp.x,cp.y,cp.z),make_float3(lx,ly,lz),species);
}
__global__ void clear(unsigned int* depth,int pixels){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<(unsigned int)pixels)depth[i]=4294967295u;}
__global__ void raster(const float4* pos,const float4* normal,const float4* shape,unsigned int* depth,unsigned int n,int w,int h,float yaw,float tilt,float scale,float time,float wind,int species,float focus){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
 float4 v=pos[i];float4 nm=normal[i];float4 sh=shape[i];float3 p=make_float3(v.x,v.y,v.z);
 if(species==10){
 // Curved, root-anchored blades use the same depth keys and lighting records.
 float3 prev=project(p,yaw,tilt,scale,w,h,focus);
 for(int segment=1;segment<=6;segment++){
 float t=(float)segment/6.0f;float bend=t*t;
 float3 tip=make_float3(p.x+sh.x*v.w*bend+sinf(time*1.7f+p.x+p.z)*wind*bend,p.y+v.w*t,p.z+sh.z*v.w*bend+cosf(time+p.z)*wind*bend*0.4f);
 float3 q2=project(tip,yaw,tilt,scale,w,h,focus);float vx=q2.x-prev.x;float vy=q2.y-prev.y;
 int steps=(int)ceilf(sqrtf(vx*vx+vy*vy))+1;
 for(int step=0;step<=steps;step++){float f=(float)step/(float)steps;int px=(int)(prev.x+vx*f);int py=(int)(prev.y+vy*f);float rad=fmaxf(0.45f,sh.w*scale*(1.0f-t*0.85f));int radI=(int)ceilf(rad);
 for(int ox=-radI;ox<=radI;ox++){int xx=px+ox;if(xx>=0&&xx<w&&py>=0&&py<h&&fabsf((float)ox)<=rad)atomicMin(&depth[py*w+xx],key(prev.z+(q2.z-prev.z)*f,i));}}
 prev=q2;
 }return;}
 p.x+=sinf(time*1.5f+p.y*0.9f+p.z)*wind*(p.y/7.0f);p.z+=cosf(time+p.x)*wind*0.35f;
 float3 q=project(p,yaw,tilt,scale,w,h,focus);
 float3 nn=normdir(nm.x,nm.y);float facing=fabsf(nn.x*sinf(yaw)*cosf(tilt)+nn.y*sinf(tilt)+nn.z*cosf(yaw)*cosf(tilt));
 float3 end=project(make_float3(p.x+sh.x*v.w,p.y+sh.y*v.w,p.z+sh.z*v.w),yaw,tilt,scale,w,h,focus);
 float ax=end.x-q.x;float ay=end.y-q.y;float ra=fmaxf(0.7f,sqrtf(ax*ax+ay*ay));float rb=fmaxf(0.4f,v.w*scale*sh.w*(0.3f+0.7f*facing));
 float angle=atan2f(ay,ax)+0.15f*sinf(time+nm.z*9.0f)*wind;
 int r=(int)ceilf(fmaxf(ra,rb)+1.0f);unsigned int k=key(q.z,i);
 for(int dy=-r;dy<=r;dy++){for(int dx=-r;dx<=r;dx++){
 int x=(int)q.x+dx;int y=(int)q.y+dy;if(x<0||y<0||x>=w||y>=h)continue;
 float fx=(float)x+0.5f-q.x;float fy=(float)y+0.5f-q.y;
 float u=(fx*cosf(angle)+fy*sinf(angle))/ra;float v2=(-fx*sinf(angle)+fy*cosf(angle))/rb;
 float mask=u*u+v2*v2;
 if(species==0){float lobes=0.72f+0.28f*cosf(u*14.0f);mask=u*u+v2*v2/(lobes*lobes);}
 if(species==1){float lobes=0.72f+0.28f*cosf(atan2f(v2,u)*5.0f);mask=(u*u+v2*v2)/(lobes*lobes);}
 if(species==2||species==6)mask=fabsf(u)+fabsf(v2);
 if(species==8)mask=u*u+(v2-u*u*0.35f)*(v2-u*u*0.35f);
 if(mask<1.0f)atomicMin(&depth[y*w+x],k);
 }}
}
__global__ void branches(unsigned int* depth,unsigned int seed,int w,int h,float yaw,float tilt,float scale,int species,float focus){
 // One workgroup per branch. Distribute its original stamp sequence across
 // lanes; integer atomicMin preserves exactly the original visibility result.
 unsigned int i=blockIdx.x;if(i>256u||species==10||(species!=3&&i>128u))return;
 float3 b=center(i%128u,seed,species);float3 a=make_float3(0.0f,1.6f+(b.y-3.3f)*0.55f,0.0f);
 if(species==4){a.y=b.y+0.35f;}
 if(species==5){a.y=4.5f;}
 if(species==6||species==7){a.y=b.y-0.7f;}
 if(species==8){a.x=0.22f*sinf(b.y);a.y=2.8f+(b.y-4.0f)*0.6f;}
 float radius=0.027f;
 if(i==128u){a=make_float3(0.0f,0.0f,0.0f);b=make_float3(0.12f,5.5f,0.0f);radius=0.18f;
 if(species==0)radius=0.24f;if(species==2)radius=0.105f;if(species==7)radius=0.055f;
 if(species==4||species==6||species==7)b.y=7.7f;
 if(species==5){radius=0.22f;b.y=5.9f;}
 if(species==9){radius=0.26f;b=make_float3(0.0f,5.4f,0.0f);}}
 if(species==9&&i<128u){
 float fa=(float)(i%32u)*2.399963f;float t0=(float)(i/32u)/4.0f;float t1=t0+0.25f;float curve=2.0f+rnd(i%32u+seed)*1.8f;
 a=make_float3(cosf(fa)*3.1f*t0,5.4f+2.4f*t0-curve*t0*t0,sinf(fa)*3.1f*t0);
 b=make_float3(cosf(fa)*3.1f*t1,5.4f+2.4f*t1-curve*t1*t1,sinf(fa)*3.1f*t1);radius=0.018f*(1.0f-t0*0.6f);}
 if(species==3&&i>128u){unsigned int c=i-129u;a=center(c,seed,species);b=make_float3(a.x+cosf((float)c)*3.6f*0.08f,a.y-3.6f,a.z+sinf((float)c)*3.6f*0.08f);radius=0.009f;}
 float3 aa=project(a,yaw,tilt,scale,w,h,focus);float3 bb=project(b,yaw,tilt,scale,w,h,focus);
 int steps=(int)(sqrtf((aa.x-bb.x)*(aa.x-bb.x)+(aa.y-bb.y)*(aa.y-bb.y))*1.5f)+1;
 for(int j=(int)threadIdx.x;j<=steps;j+=(int)blockDim.x){float t=(float)j/(float)steps;float x=aa.x+(bb.x-aa.x)*t;float y=aa.y+(bb.y-aa.y)*t;float z=aa.z+(bb.z-aa.z)*t;
 float rad=fmaxf(0.7f,radius*scale*(1.0f-t*0.65f));int r=(int)ceilf(rad);
 for(int dy=-r;dy<=r;dy++){for(int dx=-r;dx<=r;dx++){int px=(int)x+dx;int py=(int)y+dy;if(px>=0&&py>=0&&px<w&&py<h&&(float)(dx*dx+dy*dy)<=rad*rad)atomicMin(&depth[py*w+px],key(z,250000u+i));}}
 }
}
__global__ void resolve(const unsigned int* depth,const float4* pos,const float4* normal,const float* light,unsigned int* pixels,int w,int h,int bins,int mode,float lx,float ly,float lz,float yaw,float tilt,float scale,int species,float autumn,float focus){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;
 unsigned int k=depth[i];float y=(float)(i/(unsigned int)w)/(float)h;float x=(float)(i%(unsigned int)w)/(float)w;
 float r=0.055f+y*0.045f;float g=0.085f+y*0.065f;float b=0.095f+y*0.065f;
 float3 base=project(make_float3(0.0f,0.0f,0.0f),yaw,tilt,scale,w,h,focus);
 float sx=((float)(i%(unsigned int)w)-base.x)/(scale*3.3f);float sy=((float)(i/(unsigned int)w)-base.y)/(scale*0.44f);
 float shadow=expf(-sx*sx-sy*sy)*0.50f;r*=1.0f-shadow;g*=1.0f-shadow;b*=1.0f-shadow;
 if(k!=4294967295u){unsigned int id=k&262143u;
 if(id>=250000u){float grain=rnd(i)*0.05f;r=0.22f+grain;g=0.14f+grain;b=0.075f+grain;
 if(species==2){float mark=rnd((i/(unsigned int)w)/4u+(i%(unsigned int)w)/9u*713u);float white=0.64f;if(mark>0.88f)white=0.19f;r=white+grain;g=white+grain;b=white*0.91f+grain;}
 if(species==8){r=0.48f+grain;g=0.46f+grain;b=0.37f+grain;}
 if(species==9){float bands=0.07f*sinf((float)(i/(unsigned int)w)*0.65f);r+=bands;g+=bands;b+=bands;}}
 else{float4 nm=normal[id];float4 p=pos[id];int az=(int)(nm.x/6.283185f*(float)bins);int el=(int)((nm.y/2.7f+0.5f)*(float)(bins/2));
 int nb=bins*bins/2;unsigned int group=(unsigned int)nm.w*(unsigned int)nb+(unsigned int)(el*bins+az);
 float grouped=light[group];float exact=grouped;
 if(mode==1||mode==3)exact=exposure(normdir(nm.x,nm.y),make_float3(p.x,p.y,p.z),make_float3(lx,ly,lz),species);
 float e=grouped;if(mode==1)e=exact;
 float pigment=0.8f+nm.z*0.35f;r=(0.10f+e*0.38f)*pigment;g=(0.19f+e*0.53f)*pigment;b=(0.045f+e*0.12f)*pigment;
 if(species==2||species==3){r*=1.12f;g*=1.08f;}
 if(species==4||species==5||species==7){r*=0.55f;g*=0.70f;b*=1.05f;}
 if(species==8){r*=0.78f;g*=0.82f;b*=1.65f;}
 if(species==9){r*=0.8f;g*=0.9f;}
 if(species==10){r*=0.8f;g*=0.95f;}
 if(species<=3||species==6){float ar=(0.50f+e*0.45f)*pigment;float ag=(0.21f+e*0.35f)*pigment;if(species==1){ag*=0.32f;}r=r*(1.0f-autumn)+ar*autumn;g=g*(1.0f-autumn)+ag*autumn;b=b*(1.0f-autumn)+0.035f*autumn;}
 if(mode==2){r=rnd(group+3u)*0.8f+0.1f;g=rnd(group+9u)*0.8f+0.1f;b=rnd(group+17u)*0.8f+0.1f;}
 if(mode==3){float err=fminf(1.0f,fabsf(grouped-exact)*5.0f);r=err;g=0.12f+0.2f*(1.0f-err);b=0.22f*(1.0f-err);}
 }}
 pixels[i]=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,b)*255.0f)<<16)|4278190080u;
}

