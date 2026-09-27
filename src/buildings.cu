// Analytic modular solids: one thread per pixel, screen-tile candidate lists.
__device__ float4 building_box(float3 o,float3 d,float3 center,float3 half,float angle){
 float co=cosf(angle);float si=sinf(angle);float oy=o.y-center.y;float oz=o.z-center.z;
 float3 p=make_float3(o.x-center.x,co*oy+si*oz,-si*oy+co*oz);float3 v=make_float3(d.x,co*d.y+si*d.z,-si*d.y+co*d.z);
 float lo=-10000000.0f;float hi=10000000.0f;float3 n=make_float3(0.0f,0.0f,0.0f);float3 farN=n;
 for(int axis=0;axis<3;axis++){float a=axis==0?p.x:axis==1?p.y:p.z;float b=axis==0?v.x:axis==1?v.y:v.z;float h=axis==0?half.x:axis==1?half.y:half.z;
 if(fabsf(b)<.000001f){if(fabsf(a)>h)return make_float4(0.0f,0.0f,0.0f,10000000.0f);}else{float t1=(-h-a)/b;float t2=(h-a)/b;float near=fminf(t1,t2);float far=fmaxf(t1,t2);float sign=b>0.0f?-1.0f:1.0f;if(near>lo){lo=near;n=make_float3(axis==0?sign:0.0f,axis==1?sign:0.0f,axis==2?sign:0.0f);}if(far<hi){hi=far;farN=make_float3(axis==0?-sign:0.0f,axis==1?-sign:0.0f,axis==2?-sign:0.0f);}}}
 if(lo>hi||hi<.03f)return make_float4(0.0f,0.0f,0.0f,10000000.0f);if(lo<.03f){lo=hi;n=farN;}return make_float4(n.x,co*n.y-si*n.z,si*n.y+co*n.z,lo);
}
__device__ int building_parts(float4 size,float4 flags){int type=(int)size.w;float width=size.x;float length=size.y;float height=size.z;int parts=1;if(type==0||type==1)parts=(int)flags.z==2?1:(int)flags.z==1?2:5;if(type==4)parts=3;if(type==5)parts=4;if(type==6)parts=12;if(type==8)parts=2;if(type==11)parts=7;
return parts;}
__device__ float4 building_part_hit(float3 o,float3 d,float4 a,float4 size,float4 flags,float4 support,int part){int type=(int)size.w;float width=size.x;float length=size.y;float height=size.z;float3 center=make_float3(0.0f,height*.5f,0.0f);float3 half=make_float3(width*.5f,height*.5f,length*.5f);float angle=0.0f;
 if(type<2){center.y=-height*.5f;if(part>0){float bx=0.0f;float bz=0.0f;float bottom=support.x;if((int)flags.z==0){bx=(part==1||part==2?-1.0f:1.0f)*(width*.5f-.14f);bz=(part==1||part==3?-1.0f:1.0f)*(length*.5f-.14f);bottom=part==1?support.x:part==2?support.y:part==3?support.z:support.w;half.x=.12f;half.z=.12f;}float span=fmaxf(.02f,a.y-height-bottom);center=make_float3(bx,-height-span*.5f,bz);half.y=span*.5f;}}
 if(type==4||type==5){float opening=fminf(1.4f,width*.55f);float side=(width-opening)*.5f;if(part<2){half.x=side*.5f;center.x=(part==0?-1.0f:1.0f)*(width-side)*.5f;}else{half.x=opening*.5f;half.y=height*.16f;center.y=height-half.y;if(type==5&&part==3)center.y=half.y;}}
 if(type==6){float step=length/12.0f;half.z=step*.5f;half.y=height*(float)(part+1)/24.0f;center.y=half.y;center.z=-length*.5f+step*((float)part+.5f);}
 if(type==7){angle=-atan2f(height,length);half.z=sqrtf(length*length+height*height)*.5f;half.y=.12f;center.y=height*.5f;}
 if(type==8){float sign=part==0?-1.0f:1.0f;angle=sign*atan2f(height,length*.5f);center.y=height*.5f;center.z=sign*length*.25f;half.y=.12f;half.z=sqrtf(length*length*.25f+height*height)*.5f;}
 if(type==11){if(part<5){half.x=.055f;center.x=-width*.5f+(float)part*width*.25f;}else{half.y=.06f;center.y=part==5?height:height*.5f;}}
 return building_box(o,d,center,half,angle);}
__global__ void scene_buildings(const float4* pieces,const int* cells,const int* refs,const float* base,const float* tiles,const int* table,unsigned int* depth,unsigned int* pixels,unsigned int* picks,int w,int h,float cx,float cy,float cz,float yaw,float pitch,float aspect,float tangent,float extent,float lx,float ly,float lz,int toon){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;int px=(int)(i%(unsigned int)w);int py=(int)(i/(unsigned int)w);int cell=((py/32)*((w+31)/32)+px/32)*2;int start=cells[cell];int count=cells[cell+1];if(count==0)return;
 float sx=(((float)px+.5f)/(float)w*2.0f-1.0f)*tangent*aspect;float sy=(1.0f-((float)py+.5f)/(float)h*2.0f)*tangent;float cp=cosf(pitch);float sp=sinf(pitch);float ca=cosf(yaw);float sa=sinf(yaw);
 float3 rd=make_float3(sa*cp+ca*sx-sa*sp*sy,sp+cp*sy,ca*cp-sa*sx-ca*sp*sy);float best=(float)depth[i]/1000.0f;float3 normal=make_float3(0.0f,1.0f,0.0f);float3 textureNormal=normal;float3 position=normal;int material=0;unsigned int pick=0u;float selected=0.0f;
 for(int k=0;k<count;k++){int index=refs[start+k]*4;float4 a=pieces[index];float4 size=pieces[index+1];float4 flags=pieces[index+2];float4 support=pieces[index+3];float c=cosf(a.w);float s=sinf(a.w);float3 o=make_float3((cx-a.x)*c+(cz-a.z)*s,cy-a.y,-(cx-a.x)*s+(cz-a.z)*c);float3 d=make_float3(rd.x*c+rd.z*s,rd.y,-rd.x*s+rd.z*c);int parts=building_parts(size,flags);
 for(int part=0;part<parts;part++){float4 hit=building_part_hit(o,d,a,size,flags,support,part);if(hit.w<best){best=hit.w;textureNormal=make_float3(hit.x,hit.y,hit.z);normal=make_float3(hit.x*c-hit.z*s,hit.y,hit.x*s+hit.z*c);position=make_float3(o.x+d.x*best,o.y+d.y*best,o.z+d.z*best);material=(int)flags.x;pick=(unsigned int)flags.y;selected=flags.w;}}
 }
 if(pick==0u)return;float u=fabsf(textureNormal.y)>.7f?position.z:position.y;float v=position.x;if(fabsf(textureNormal.x)>.7f)v=position.z;float pigment=.86f+.17f*floorf(noise3(position.x*3.0f,position.y*3.0f,position.z*3.0f)*5.0f)/5.0f;float filter=1.0f/(1.0f+best*best*.00015f);float r=.52f;float g=.31f;float b=.14f;
 if(material==0){float plank=u*3.0f;float seam=fminf(plank-floorf(plank),1.0f-(plank-floorf(plank)));pigment-=fmaxf(0.0f,1.0f-seam/.04f)*.28f*filter;pigment+=sinf(v*2.0f+noise3(v*.6f,u*15.0f,2.0f)*5.0f)*.06f*filter;}
 if(material==1||material==3||material==5){r=material==3?.62f:material==5?.27f:.54f;g=material==3?.29f:material==5?.33f:.53f;b=material==3?.18f:material==5?.39f:.46f;float row=floorf(u*2.0f);float a=v*1.5f+(row-floorf(row*.5f)*2.0f)*.5f;float aa=a-floorf(a);float bb=u*2.0f-row;float seam=fminf(fminf(aa,1.0f-aa),fminf(bb,1.0f-bb));pigment-=fmaxf(0.0f,1.0f-seam/.055f)*.28f*filter;}
 if(material==2){r=.58f;g=.41f;b=.24f;}if(material==4){r=.87f;g=.79f;b=.61f;}if(material==6){r=.66f;g=.54f;b=.25f;pigment+=sinf(v*60.0f+u*2.0f)*.10f*filter;}
 float light=.3f+.7f*fmaxf(0.0f,normal.x*lx+normal.y*ly+normal.z*lz);if(toon!=0)light=light<.48f?.43f:light<.76f?.68f:.96f;r*=light*pigment;g*=light*pigment;b*=light*pigment;if(selected>.5f){r=r*.8f+.18f;g=g*.8f+.14f;b=b*.8f+.04f;}float fog=fminf(.8f,best/(extent*.5f+2000.0f));r=r*(1.0f-fog)+.2f*fog;g=g*(1.0f-fog)+.25f*fog;b=b*(1.0f-fog)+.29f*fog;
 depth[i]=(unsigned int)(best*1000.0f);picks[i]=pick;pixels[i]=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,b)*255.0f)<<16)|4278190080u;
}

// The same solids cast into the light-space height map, including apertures and supports.
__global__ void building_shadow(const float4* pieces,const int* cells,const int* refs,unsigned int* shadow,float originX,float originZ,float cell,float lx,float ly,float lz){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=1048576u)return;int x=(int)(i%1024u);int z=(int)(i/1024u);int tile=((z/32)*32+x/32)*2;float kx=lx/ly;float kz=lz/ly;float cx=originX+((float)x+.5f)*cell+8192.0f*kx;float cz=originZ+((float)z+.5f)*cell+8192.0f*kz;float best=10000000.0f;
 for(int k=0;k<cells[tile+1];k++){int index=refs[cells[tile]+k]*4;float4 a=pieces[index];float4 size=pieces[index+1];float4 flags=pieces[index+2];float4 support=pieces[index+3];float c=cosf(a.w);float s=sinf(a.w);float3 o=make_float3((cx-a.x)*c+(cz-a.z)*s,8192.0f-a.y,-(cx-a.x)*s+(cz-a.z)*c);float3 d=make_float3(-kx*c-kz*s,-1.0f,kx*s-kz*c);int parts=building_parts(size,flags);
 for(int part=0;part<parts;part++){float4 hit=building_part_hit(o,d,a,size,flags,support,part);best=fminf(best,hit.w);}}
 shadow[i]=best>=9999999.0f?0u:(unsigned int)(fmaxf(0.0f,8192.0f-best+65536.0f)*1024.0f);
}
