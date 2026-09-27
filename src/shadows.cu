// Seeded canopy shadow map. X/Z coordinates are projected onto the y=0 plane.
// Ellipsoid clusters reuse the renderer's seed and species; no leaf regeneration.
__global__ void shadow_clear(unsigned int* shadow){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i<1048576u)shadow[i]=0u;}
__global__ void shadow_stamp(unsigned int* shadow,const float4* casters,int count,float originX,float originZ,float cell,float lx,float ly,float lz,float windTime,float windSpeed,float windDirection){
 unsigned int job=(blockIdx.x+blockIdx.y*65535u)*blockDim.x+threadIdx.x;if(job>=(unsigned int)(count*144))return;
 int object=(int)(job/144u);unsigned int cluster=job%144u;float4 a=casters[object*3];float4 b=casters[object*3+1];float4 meta=casters[object*3+2];int species=(int)b.y;unsigned int seed=(unsigned int)b.z+((unsigned int)b.w<<16);
 float3 p=center(cluster,seed,species);float radius=.78f;float vertical=.65f;
 if(species>=11){radius=.28f;vertical=.25f;}if(species==2){radius=.55f;vertical=.7f;}if(species==4){radius=.22f+.4f*(1.0f-(float)(cluster/8u)/16.0f);vertical=.22f;}if(species==5){radius=.6f;vertical=.3f;}if(species==6){radius=.25f;vertical=.4f;}if(species==7){radius=.16f;vertical=.28f;}if(species==3)vertical=1.7f;
 if(species>=91){if(cluster>=16u)return;float4 rock=mineralBody(cluster,seed,species);p=make_float3(rock.x,rock.y*.5f,rock.z);radius=rock.w;vertical=rock.y*.5f;}
 if(cluster>=128u){if(species>=10)return;float h=5.7f;float root=.24f;if(species==2){h=6.3f;root=.12f;}if(species==5){h=5.8f;root=.25f;}if(species==8){h=6.0f;root=.20f;}float t=((float)(cluster-128u)+.5f)/16.0f;p=trunkPoint(t*h,species);radius=root*powf(1.0f-t,.75f)+.012f;vertical=h/16.0f;}
 p=vegetation_wind(p,species,b.x,meta.x*1.618f,windTime,windSpeed,windDirection);
 float ca=cosf(b.x);float sa=sinf(b.x);float x=a.x+(p.x*ca-p.z*sa)*a.w;float y=a.y+p.y*a.w;float z=a.z+(p.x*sa+p.z*ca)*a.w;radius=fmaxf(.02f,radius*a.w);vertical=fmaxf(.02f,vertical*a.w);
 float kx=lx/ly;float kz=lz/ly;float px=x-y*kx;float pz=z-y*kz;float rx=sqrtf(radius*radius+kx*kx*vertical*vertical);float rz=sqrtf(radius*radius+kz*kz*vertical*vertical);
 int left=max(0,(int)floorf((px-rx-originX)/cell));int right=min(1023,(int)ceilf((px+rx-originX)/cell));int top=max(0,(int)floorf((pz-rz-originZ)/cell));int bottom=min(1023,(int)ceilf((pz+rz-originZ)/cell));
 float rr=radius*radius;float A=(kx*kx+kz*kz)/rr+1.0f/(vertical*vertical);
 for(int iz=top;iz<=bottom;iz++)for(int ix=left;ix<=right;ix++){float qx=originX+((float)ix+.5f)*cell-px;float qz=originZ+((float)iz+.5f)*cell-pz;float B=(qx*kx+qz*kz)/rr;float C=(qx*qx+qz*qz)/rr-1.0f;float D=B*B-A*C;if(D<0.0f)continue;float height=y+(-B+sqrtf(D))/A;atomicMax(&shadow[iz*1024+ix],(unsigned int)(fmaxf(0.0f,height+65536.0f)*1024.0f));}
}
__global__ void scene_shadows(const unsigned int* shadow,const unsigned int* depth,const unsigned int* picks,unsigned int* pixels,int w,int h,float cx,float cy,float cz,float yaw,float pitch,float aspect,float tangent,float originX,float originZ,float cell,float lx,float ly,float lz,float strength){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h)||depth[i]==4294967295u)return;
 float distance=(float)depth[i]*.001f;float sx=(((float)(i%(unsigned int)w)+.5f)/(float)w*2.0f-1.0f)*tangent*aspect;float sy=(1.0f-((float)(i/(unsigned int)w)+.5f)/(float)h*2.0f)*tangent;
 float cp=cosf(pitch);float sp=sinf(pitch);float ca=cosf(yaw);float sa=sinf(yaw);float x=cx+(sa*cp+ca*sx-sa*sp*sy)*distance;float y=cy+(sp+cp*sy)*distance;float z=cz+(ca*cp-sa*sx-ca*sp*sy)*distance;
 float gx=(x-y*lx/ly-originX)/cell-.5f;float gz=(z-y*lz/ly-originZ)/cell-.5f;int ix=(int)floorf(gx);int iz=(int)floorf(gz);float u=gx-(float)ix;float v=gz-(float)iz;float shade=0.0f;
 // Bilinear PCF: fixed four depth comparisons, with a receiver bias for shell approximation.
 float bias=.10f+cell*.5f;if(picks[i]!=0u)bias+=.40f;
 for(int dz=0;dz<2;dz++)for(int dx=0;dx<2;dx++){int xx=ix+dx;int zz=iz+dz;if(xx<0||xx>=1024||zz<0||zz>=1024)continue;float weight=(dx==0?1.0f-u:u)*(dz==0?1.0f-v:v);float top=(float)shadow[zz*1024+xx]/1024.0f-65536.0f;if(top>y+bias)shade+=weight;}
 float edge=fminf(fminf(gx,gz),fminf(1023.0f-gx,1023.0f-gz));shade*=fminf(1.0f,fmaxf(0.0f,edge/32.0f))*strength;
 unsigned int colour=pixels[i];float r=(float)(colour&255u)*(1.0f-shade*.62f);float g=(float)((colour>>8)&255u)*(1.0f-shade*.53f);float b=(float)((colour>>16)&255u)*(1.0f-shade*.36f);
 pixels[i]=(unsigned int)r|((unsigned int)g<<8)|((unsigned int)b<<16)|4278190080u;
}
