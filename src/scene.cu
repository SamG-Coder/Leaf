// Perspective world rendering. Geometry stays in CUDA; camera data is host input.
__device__ float3 scene_color(float4 p,float4 nm,int species,float e,float lx,float ly,float lz){float r=0.0f;float g=0.0f;float b=0.0f;float yaw=0.0f;float tilt=0.0f;float autumn=0.0f;
 float pigment=0.8f+(nm.z-floorf(nm.z))*0.35f;r=(0.10f+e*0.38f)*pigment;g=(0.19f+e*0.53f)*pigment;b=(0.045f+e*0.12f)*pigment;

 if(species==2||species==3){r*=1.12f;g*=1.08f;}

 if(species==4||species==5||species==7){r*=0.55f;g*=0.70f;b*=1.05f;}

 if(species==8){r*=0.78f;g*=0.82f;b*=1.65f;}

 if(species==9){r*=0.8f;g*=0.9f;}

 if(species==10){r*=0.8f;g*=0.95f;}

 if(species>=11&&species<=20){

 if(species==11||species==19){r*=0.55f;g*=0.73f;b*=0.9f;}

 if(species==12){r=r*0.65f+0.08f;g=g*0.68f+0.08f;b=b*1.2f+0.1f;}

 if(species==13){r*=0.55f;g*=0.72f;b*=1.2f;}

 if(species==14||species==15){r*=0.65f;g*=0.78f;b*=1.05f;}

 if(species==18){r*=0.55f;g*=0.65f;b=b*1.7f+0.06f;}

 if(species==20){r=(0.18f+e*0.35f)*pigment;g=(0.04f+e*0.085f)*pigment;b=(0.08f+e*0.16f)*pigment;}

 if(nm.z>=1.0f){float illumination=0.55f+e*0.45f;r=0.75f*illumination;g=0.25f*illumination;b=0.55f*illumination;

 if(species==12){r=0.5f*illumination;g=0.3f*illumination;b=0.85f*illumination;}

 if(species==13){r=0.48f*illumination;g=0.59f*illumination;b=0.85f*illumination;}

 if(species==14){r=0.98f*illumination;g=0.53f*illumination;b=0.73f*illumination;}

 if(species==15){r=0.65f*illumination;g=0.3f*illumination;b=0.82f*illumination;}

 if(species==16){r=0.96f*illumination;g=0.24f*illumination;b=0.41f*illumination;}

 if(species==17){r=1.0f*illumination;g=0.79f*illumination;b=0.05f*illumination;}}

 }

 if(species<=3||species==6||((species==14||species==17||species==20)&&nm.z<1.0f)){float ar=(0.50f+e*0.45f)*pigment;float ag=(0.21f+e*0.35f)*pigment;if(species==1){ag*=0.32f;}r=r*(1.0f-autumn)+ar*autumn;g=g*(1.0f-autumn)+ag*autumn;b=b*(1.0f-autumn)+0.035f*autumn;}

 if(species>=21&&species<=30&&nm.z>=1.0f){
  float illumination=(0.46f+0.54f*e)*(0.94f+0.06f*pigment);
  float3 color=make_float3(1.0f,0.75f,0.035f);
  if(species==22)color=make_float3(0.98f,0.97f,0.90f);
  if(species==23)color=make_float3(0.95f,0.12f,0.30f);
  if(species==24)color=make_float3(1.0f,0.91f,0.36f);
  if(species==25)color=make_float3(0.98f,0.085f,0.04f);
  if(species==26)color=make_float3(0.95f,0.16f,0.32f);
  if(species==27)color=make_float3(0.94f,0.30f,0.67f);
  if(species==28)color=make_float3(0.80f,0.32f,0.61f);
  if(species==29)color=make_float3(0.30f,0.32f,0.95f);
  if(species==30)color=make_float3(0.49f,0.27f,0.87f);
  if(nm.z>=2.0f){color=make_float3(0.96f,0.65f,0.07f);if(species==21||species==25)color=make_float3(0.20f,0.105f,0.035f);if(species==28)color=make_float3(0.63f,0.28f,0.075f);if(species==24)color=make_float3(1.0f,0.56f,0.045f);}
  r=color.x*illumination;g=color.y*illumination;b=color.z*illumination;
 }

 if(species>=31&&species<=40){
  float shade=0.28f+0.72f*e;float3 tint=make_float3(0.26f,0.64f,0.12f);
  if(species==32)tint=make_float3(0.35f,0.72f,0.15f);
  if(species==33)tint=make_float3(0.33f,0.69f,0.22f);
  if(species==34){tint=make_float3(0.27f,0.53f,0.12f);if(((unsigned int)nm.w%16u)%3u==0u)tint=make_float3(0.85f,0.40f,0.16f);}
  if(species==35)tint=make_float3(0.57f,0.66f,0.62f);
  if(species==36)tint=make_float3(0.37f,0.69f,0.12f);
  if(species==37||species==38)tint=make_float3(0.11f,0.44f,0.14f);
  if(species==39)tint=make_float3(0.34f,0.59f,0.19f);
  if(species==40)tint=make_float3(0.46f,0.71f,0.21f);
  r=tint.x*shade*pigment;g=tint.y*shade*pigment;b=tint.z*shade*pigment;
 }

 if(species>=41&&species<=50){
  float shade=0.35f+0.65f*e;float3 tint=make_float3(0.55f,0.70f,0.40f);
  if(species==42)tint=make_float3(0.19f,0.48f,0.13f);
  if(species==43)tint=make_float3(0.48f,0.62f,0.12f);
  if(species==44)tint=make_float3(0.30f,0.50f,0.14f);
  if(species==45)tint=make_float3(0.23f,0.59f,0.20f);
  if(species==46)tint=make_float3(0.47f,0.57f,0.20f);
  if(species==47)tint=make_float3(0.49f,0.73f,0.20f);
  if(species==48)tint=make_float3(0.36f,0.59f,0.15f);
  if(species==49){float tintVariation=rnd((unsigned int)nm.w+71u);tint=make_float3(0.58f+0.15f*tintVariation,0.60f+0.10f*tintVariation,0.28f+0.06f*tintVariation);}
  if(species==50)tint=make_float3(0.65f,0.73f,0.63f);
  r=tint.x*shade*pigment;g=tint.y*shade*pigment;b=tint.z*shade*pigment;
 }

 if(species>=51&&species<=60){float shade=0.32f+0.68f*e;float3 tint=make_float3(0.15f,0.43f,0.18f);
 if(species==52)tint=make_float3(0.25f,0.52f,0.20f);
 if(species==53||species==54)tint=make_float3(0.26f,0.57f,0.19f);
 if(species==55)tint=make_float3(0.40f,0.59f,0.17f);
 if(species==56)tint=make_float3(0.35f,0.61f,0.20f);
 if(species==57)tint=make_float3(0.29f,0.56f,0.29f);
 if(species==58)tint=make_float3(0.30f,0.52f,0.16f);
 if(species==59)tint=make_float3(0.28f,0.63f,0.20f);
 if(species==60)tint=make_float3(0.24f,0.49f,0.23f);
 r=tint.x*shade*pigment;g=tint.y*shade*pigment;b=tint.z*shade*pigment;}

 if(species>=61&&species<=70){float shade=0.30f+0.70f*e;float3 tint=make_float3(0.32f,0.60f,0.20f);
 if(species==61)tint=make_float3(0.39f,0.62f,0.68f);
 if(species==62)tint=make_float3(0.25f,0.49f,0.21f);
 if(species==63)tint=make_float3(0.20f,0.48f,0.30f);
 if(species==64)tint=make_float3(0.15f,0.43f,0.16f);
 if(species==65)tint=make_float3(0.35f,0.60f,0.18f);
 if(species==66)tint=make_float3(0.36f,0.51f,0.18f);
 if(species==67)tint=make_float3(0.40f,0.61f,0.23f);
 if(species==68)tint=make_float3(0.33f,0.55f,0.39f);
 if(species==69)tint=make_float3(0.46f,0.63f,0.22f);
 if(species==70)tint=make_float3(0.68f,0.66f,0.36f);
 if(nm.z>=1.0f)tint=make_float3(0.83f,0.72f,0.48f);
 r=tint.x*shade*pigment;g=tint.y*shade*pigment;b=tint.z*shade*pigment;
 }

 if(species>=71&&species<=80){float shade=0.40f+0.60f*e;float3 tint=make_float3(0.35f,0.58f,0.16f);
 if(species==71||species==72)tint=make_float3(0.66f,0.60f,0.27f);
 if(species==73)tint=make_float3(0.48f,0.58f,0.22f);
 if(species==75||species==78)tint=make_float3(0.24f,0.49f,0.13f);
 if(nm.z>=1.0f){tint=make_float3(0.82f,0.68f,0.34f);if(species==76)tint=make_float3(0.51f,0.23f,0.13f);if(species==77)tint=make_float3(0.57f,0.46f,0.25f);if(species==79)tint=make_float3(0.58f,0.45f,0.25f);if(species==80)tint=make_float3(0.96f,0.95f,0.86f);}
 r=tint.x*shade*pigment;g=tint.y*shade*pigment;b=tint.z*shade*pigment;
 }

 if(species>=81&&species<=90){
 float3 tint=make_float3(0.88f,0.82f,0.67f);float shade=0.32f+0.68f*e;
 if(nm.z>=1.0f){
  tint=make_float3(0.78f,0.075f,0.035f);
  if(species==81){float spots=noise3(p.x*42.0f,p.y*42.0f,p.z*42.0f);if(spots>0.70f)tint=make_float3(0.96f,0.92f,0.80f);}
  if(species==82)tint=make_float3(0.43f,0.24f,0.10f);
  if(species==83)tint=make_float3(0.98f,0.63f,0.075f);
  if(species==84)tint=make_float3(0.51f,0.27f,0.67f);
  if(species==85){float flakes=noise3(p.x*48.0f,p.y*28.0f,p.z*48.0f);tint=make_float3(0.90f,0.87f,0.77f);if(flakes>0.63f)tint=make_float3(0.43f,0.35f,0.27f);}
  if(species==86)tint=make_float3(0.85f,0.68f,0.13f);
  if(species==87)tint=make_float3(0.58f,0.54f,0.46f);
  if(species==88){float mx=((float)((unsigned int)nm.w%4u)-1.5f)*0.65f+0.12f*sinf((float)((unsigned int)nm.w%16u));float dx=p.x-mx;float dz=p.z+0.20f;float band=0.5f+0.5f*sinf(sqrtf(dx*dx+dz*dz)*75.0f);tint=make_float3(0.24f+0.48f*band,0.16f+0.44f*band,0.10f+0.40f*band);}
  if(species==89)tint=make_float3(0.88f,0.84f,0.72f);
  if(species==90)tint=make_float3(0.65f,0.43f,0.23f);
 }else{if(species==83)tint=make_float3(0.89f,0.56f,0.10f);if(species==84)tint=make_float3(0.48f,0.29f,0.56f);}
 r=tint.x*shade*pigment;g=tint.y*shade*pigment;b=tint.z*shade*pigment;
 }

 if(species>=91&&species<=100){
 float3 tint=make_float3(0.55f,0.53f,0.50f);float texture=1.0f;float rough=noise3(p.x*35.0f,p.y*35.0f,p.z*35.0f);
 if(species==91){texture=0.65f+0.60f*rough;if(rough>0.66f)tint=make_float3(0.74f,0.61f,0.55f);if(rough<0.3f)tint=make_float3(0.21f,0.23f,0.23f);}
 if(species==92){tint=make_float3(0.23f,0.25f,0.27f);texture=0.85f+0.25f*rough;}
 if(species==93){tint=make_float3(0.75f,0.42f,0.23f);texture=0.78f+0.18f*sinf(p.y*72.0f)+0.15f*rough;}
 if(species==94){tint=make_float3(0.28f,0.34f,0.39f);texture=0.8f+0.2f*rough;}
 if(species==95){tint=make_float3(0.73f,0.71f,0.59f);texture=0.72f+0.35f*rough;}
 if(species==96)tint=make_float3(0.78f,0.87f,0.90f);
 if(species==97)tint=make_float3(0.49f,0.22f,0.75f);
 if(species==98)tint=make_float3(0.36f,0.29f,0.23f);
 if(species==99)tint=make_float3(0.78f,0.60f,0.19f);
 if(species==100)tint=make_float3(0.26f,0.70f,0.51f);
 float shade=(0.25f+0.75f*e)*texture;float spec=0.0f;
 if(species>=96){float3 n=normdir(nm.x,nm.y);float hx=lx-sinf(yaw)*cosf(tilt);float hy=ly-sinf(tilt);float hz=lz-cosf(yaw)*cosf(tilt);float hl=sqrtf(hx*hx+hy*hy+hz*hz);float d=fmaxf(0.0f,(n.x*hx+n.y*hy+n.z*hz)/fmaxf(0.001f,hl));spec=d*d*d*d;spec=spec*spec*spec*0.75f;}
 r=tint.x*shade+spec;g=tint.y*shade+spec;b=tint.z*shade+spec;
 }

 if(species>=101&&species<=110){
 int kind=species-101;if(species==110)kind=(int)((unsigned int)nm.w%9u);
 float3 tint=make_float3(0.48f,0.25f,0.09f);
 if(kind==1)tint=make_float3(0.72f,0.26f,0.07f);if(kind==2)tint=make_float3(0.75f,0.59f,0.18f);if(kind==3)tint=make_float3(0.47f,0.34f,0.13f);
 if(kind==4)tint=make_float3(0.30f,0.21f,0.12f);if(kind==5)tint=make_float3(0.43f,0.30f,0.18f);if(kind==6)tint=make_float3(0.40f,0.23f,0.10f);if(kind==7)tint=make_float3(0.55f,0.30f,0.12f);if(kind==8)tint=make_float3(0.47f,0.47f,0.43f);
 float grain=noise3(p.x*95.0f,p.y*95.0f,p.z*95.0f);float shade=(0.38f+0.62f*e)*(0.78f+0.30f*grain)*pigment;
 r=tint.x*shade;g=tint.y*shade;b=tint.z*shade;
 }

 if(species>=111){
 float grain=noise3(p.x*36.0f,p.y*36.0f,p.z*36.0f);float3 tint=make_float3(0.32f,0.21f,0.12f);float texture=0.70f+0.4f*grain;
 if(species==116)tint=make_float3(0.61f,0.57f,0.47f);
 if(species==117){float marks=noise3(p.x*42.0f,p.y*6.0f,p.z*6.0f);tint=make_float3(0.84f,0.80f,0.68f);if(marks>0.64f)tint=make_float3(0.18f,0.16f,0.13f);}
 if(nm.z>=1.0f&&nm.z<2.0f){tint=make_float3(0.68f,0.48f,0.27f);float radial=sqrtf(p.y*p.y+p.z*p.z);if(species==113||species==114||species==115||species==120)radial=sqrtf(p.x*p.x+p.z*p.z);texture=0.83f+0.13f*sinf(radial*115.0f)+0.08f*grain;}
 if(nm.z>=2.0f){tint=make_float3(0.18f,0.11f,0.06f);texture*=0.70f;}
 float shade=(0.28f+0.72f*e)*texture;r=tint.x*shade;g=tint.y*shade;b=tint.z*shade;
 }

 return make_float3(r,g,b);}


__device__ float3 scene_foliage_lit(float3 p,float size,float4 nm,float4 cluster,int species,int toon,float llx,float ly,float llz){
 float exposureValue=exposure(normdir(nm.x,nm.y),p,make_float3(llx,ly,llz),species);if(toon!=0&&species!=10&&species<21){float nx=p.x-cluster.x;float ny=(p.y-cluster.y)*1.3f;float nz=p.z-cluster.z;float nl=fmaxf(0.05f,sqrtf(nx*nx+ny*ny+nz*nz));float local=(nx*llx+ny*ly+nz*llz)/nl;float cy=4.4f;if(species>=11)cy=0.9f;nx=p.x;ny=(p.y-cy)*0.8f;nz=p.z;nl=fmaxf(0.1f,sqrtf(nx*nx+ny*ny+nz*nz));float broad=(nx*llx+ny*ly+nz*llz)/nl;exposureValue=fminf(1.0f,fmaxf(0.0f,0.38f+0.42f*broad+0.27f*local));}float3 color=scene_color(make_float4(p.x,p.y,p.z,size),nm,species,exposureValue,llx,ly,llz);
 if(toon!=0&&species<21&&species!=10){float t=exposureValue;t=t*t*(3.0f-2.0f*t);float pigment=0.94f+0.06f*(nm.z-floorf(nm.z));float conifer=1.0f;if(species==4||species==5||species==7)conifer=0.82f;float3 paint=make_float3((0.035f+0.41f*t)*pigment,(0.19f+0.43f*t)*pigment,(0.20f-0.095f*t)*pigment);color=make_float3((paint.x*0.8f+color.x*0.2f)*conifer,(paint.y*0.8f+color.y*0.2f)*conifer,(paint.z*0.8f+color.z*0.2f)*conifer);}
 return color;
}
__device__ float terrain_node(const float* tiles,const int* table,int x,int z){int tx=(int)floorf((float)x/32.0f);int tz=(int)floorf((float)z/32.0f);unsigned int slot=(((unsigned int)tx*73856093u)^((unsigned int)tz*19349663u))&8191u;for(int j=0;j<64;j++){int k=(int)slot*4;int offset=table[k+2];if(offset<0)return 0.0f;if(table[k]==tx&&table[k+1]==tz)return tiles[offset+(z-tz*32)*32+x-tx*32];slot=(slot+1u)&8191u;}return 0.0f;}
__device__ float terrain_world(const float* base,const float* tiles,const int* table,float x,float z,float extent){float gx=fminf(63.9999f,fmaxf(0.0f,(x/extent+0.5f)*64.0f));float gz=fminf(63.9999f,fmaxf(0.0f,(z/extent+0.5f)*64.0f));int ix=(int)gx;int iz=(int)gz;float u=gx-(float)ix;float v=gz-(float)iz;float h=(base[iz*65+ix]*(1.0f-u)+base[iz*65+ix+1]*u)*(1.0f-v)+(base[(iz+1)*65+ix]*(1.0f-u)+base[(iz+1)*65+ix+1]*u)*v;gx=x*0.5f;gz=z*0.5f;ix=(int)floorf(gx);iz=(int)floorf(gz);u=gx-(float)ix;v=gz-(float)iz;return h+(terrain_node(tiles,table,ix,iz)*(1.0f-u)+terrain_node(tiles,table,ix+1,iz)*u)*(1.0f-v)+(terrain_node(tiles,table,ix,iz+1)*(1.0f-u)+terrain_node(tiles,table,ix+1,iz+1)*u)*v;}

__global__ void ground_cover_clear(unsigned int* cover,int count){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)count)return;cover[i]=0u;}
__global__ void ground_cover_stamp(const float4* sources,unsigned int* cover,int count,float originX,float originZ,float cell,float lx,float ly,float lz){
 unsigned int job=blockIdx.x*blockDim.x+threadIdx.x;if(job>=(unsigned int)(count*3))return;unsigned int object=job/3u;unsigned int zone=job%3u;float4 a=sources[object*2u];float4 b=sources[object*2u+1u];int kind=(int)b.y;float x=a.x;float z=a.y;float radius=a.z;int channel=1;float strength=0.85f;
 if(zone==0u){if(kind==3||kind==6)return;x-=lx*a.w/fmaxf(0.18f,ly);z-=lz*a.w/fmaxf(0.18f,ly);channel=0;strength=0.75f;}
 if(zone==1u){if(kind==3){channel=3;strength=0.95f;}if(kind==4){channel=4;strength=0.85f;}if(kind==5){channel=3;strength=0.65f;}if(kind==2)strength=1.0f;}
 if(zone==2u){if(kind==3||kind==6)return;radius=b.x;channel=2;strength=0.95f;}
 int minx=(int)floorf((x-radius-originX)/cell);int maxx=(int)ceilf((x+radius-originX)/cell);int minz=(int)floorf((z-radius-originZ)/cell);int maxz=(int)ceilf((z+radius-originZ)/cell);
 minx=max(0,minx);maxx=min(511,maxx);minz=max(0,minz);maxz=min(511,maxz);
 for(int zz=minz;zz<=maxz;zz++)for(int xx=minx;xx<=maxx;xx++){float wx=originX+((float)xx+0.5f)*cell;float wz=originZ+((float)zz+0.5f)*cell;float dx=(wx-x)/fmaxf(cell,radius);float dz=(wz-z)/fmaxf(cell,radius);float d=sqrtf(dx*dx+dz*dz);float edge=0.82f+0.22f*noise3(wx*.7f,0.0f,wz*.7f);float value=fmaxf(0.0f,1.0f-d/edge);value=sqrtf(value)*strength;unsigned int q=(unsigned int)(value*65535.0f);atomicMax(&cover[(zz*512+xx)*5+channel],q);}
}
__device__ float cover_value(const unsigned int* cover,float x,float z,float ox,float oz,float cell,int channel){float gx=(x-ox)/cell-0.5f;float gz=(z-oz)/cell-0.5f;if(gx<0.0f||gz<0.0f||gx>=511.0f||gz>=511.0f)return 0.0f;int ix=(int)gx;int iz=(int)gz;float u=gx-(float)ix;float v=gz-(float)iz;int k=(iz*512+ix)*5+channel;return (((float)cover[k]*(1.0f-u)+(float)cover[k+5]*u)*(1.0f-v)+((float)cover[k+2560]*(1.0f-u)+(float)cover[k+2565]*u)*v)/65535.0f;}
__global__ void scene_ground(const float4* waters,const float4* waterPoints,const unsigned int* cover,const float* base,const float* tiles,const int* table,unsigned int* depth,unsigned int* pixels,unsigned int* picks,int w,int h,float cx,float cy,float cz,float yaw,float pitch,float aspect,float tangent,float extent,float minY,float maxY,float coverX,float coverZ,float coverCell,int groundCover,int waterCount,int grid,int toon,float lx,float ly,float lz){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;
 float sx=(((float)(i%(unsigned int)w)+0.5f)/(float)w*2.0f-1.0f)*tangent*aspect;float sy=(1.0f-((float)(i/(unsigned int)w)+0.5f)/(float)h*2.0f)*tangent;
 float cp=cosf(pitch);float sp=sinf(pitch);float ca=cosf(yaw);float sa=sinf(yaw);float dx=sa*cp+ca*sx-sa*sp*sy;float dy=sp+cp*sy;float dz=ca*cp-sa*sx-ca*sp*sy;float dl=sqrtf(dx*dx+dy*dy+dz*dz);dx/=dl;dy/=dl;dz/=dl;
 float r=0.14f+0.16f*fmaxf(dy,0.0f);float g=0.19f+0.19f*fmaxf(dy,0.0f);float b=0.24f+0.22f*fmaxf(dy,0.0f);float distance=1000000.0f;
 float begin=0.05f;float finish=extent*3.0f+10000.0f;
 if(fabsf(dy)>0.000001f){float a=(minY-cy)/dy;float bb=(maxY-cy)/dy;begin=fmaxf(begin,fminf(a,bb));finish=fminf(finish,fmaxf(a,bb)+1.0f);}
 float t=begin;float previous=begin;
 for(int step=0;step<256;step++){if(t>finish)break;float x=cx+dx*t;float y=cy+dy*t;float z=cz+dz*t;
 if(fabsf(x)<=extent*0.5f&&fabsf(z)<=extent*0.5f&&y<=terrain_world(base,tiles,table,x,z,extent)+0.001f){float lo=previous;float hi=t;for(int k=0;k<10;k++){float mid=(lo+hi)*0.5f;if(cy+dy*mid>terrain_world(base,tiles,table,cx+dx*mid,cz+dz*mid,extent))lo=mid;else hi=mid;}t=(lo+hi)*0.5f;x=cx+dx*t;z=cz+dz*t;float eps=fmaxf(0.25f,fminf(2.0f,extent/64.0f));float nx=(terrain_world(base,tiles,table,x-eps,z,extent)-terrain_world(base,tiles,table,x+eps,z,extent))/(2.0f*eps);float nz=(terrain_world(base,tiles,table,x,z-eps,extent)-terrain_world(base,tiles,table,x,z+eps,extent))/(2.0f*eps);float light=0.30f+0.70f*fmaxf(0.0f,(nx*lx+ly+nz*lz)/sqrtf(nx*nx+nz*nz+1.0f));if(toon!=0)light=light<0.48f?0.44f:light<0.76f?0.69f:0.96f;r=0.26f*light;g=0.32f*light;b=0.21f*light;
 if(groundCover!=0){float shade=cover_value(cover,x,z,coverX,coverZ,coverCell,0);float litter=cover_value(cover,x,z,coverX,coverZ,coverCell,1);float soil=cover_value(cover,x,z,coverX,coverZ,coverCell,2);float moss=cover_value(cover,x,z,coverX,coverZ,coverCell,3);float stone=cover_value(cover,x,z,coverX,coverZ,coverCell,4);float patch=noise3(x*0.8f,1.0f,z*0.8f);moss=fmaxf(moss,shade*(1.0f-litter)*patch*.7f);float slope=sqrtf(nx*nx+nz*nz);stone=fmaxf(stone,fminf(.8f,fmaxf(0.0f,slope-.8f)));float3 tint=make_float3(.26f,.43f,.105f);tint=make_float3(tint.x*(1.0f-litter)+.36f*litter,tint.y*(1.0f-litter)+.255f*litter,tint.z*(1.0f-litter)+.115f*litter);tint=make_float3(tint.x*(1.0f-moss)+.13f*moss,tint.y*(1.0f-moss)+.30f*moss,tint.z*(1.0f-moss)+.14f*moss);tint=make_float3(tint.x*(1.0f-soil)+.29f*soil,tint.y*(1.0f-soil)+.19f*soil,tint.z*(1.0f-soil)+.105f*soil);tint=make_float3(tint.x*(1.0f-stone)+.38f*stone,tint.y*(1.0f-stone)+.37f*stone,tint.z*(1.0f-stone)+.30f*stone);
 float detail=0.86f+0.23f*patch;float fine=noise3(x*9.0f,2.0f,z*13.0f);float distanceFade=1.0f/(1.0f+t*.015f);detail+=(fine-.5f)*.16f*distanceFade;float illumination=light*(1.0f-shade*.48f);r=tint.x*detail*illumination;g=tint.y*detail*illumination;b=tint.z*detail*illumination;
 }

 float4 wet=water_context(waters,waterPoints,waterCount,x,z,cy+dy*t);if(wet.w>0.0f){float elevation=cy+dy*t-wet.x;float shore=fmaxf(0.0f,1.0f-fmaxf(0.0f,elevation)/2.2f)*fmaxf(0.0f,1.0f-wet.y/5.0f);float sand=wet.z>1.5f?1.0f:0.0f;float grain=.9f+.12f*noise3(x*1.7f,2.0f,z*1.7f);float wetness=elevation<.25f?.72f:1.0f;float rr=(sand>.5f?.66f:.27f)*light*grain*wetness;float gg=(sand>.5f?.60f:.29f)*light*grain*wetness;float bb=(sand>.5f?.39f:.16f)*light*grain*wetness;r=r*(1.0f-shore)+rr*shore;g=g*(1.0f-shore)+gg*shore;b=b*(1.0f-shore)+bb*shore;}
 float cell=1.0f;if(t>100.0f)cell=10.0f;if(t>1000.0f)cell=100.0f;if(t>10000.0f)cell=1000.0f;float line=fminf(fabsf(x/cell-floorf(x/cell+0.5f)),fabsf(z/cell-floorf(z/cell+0.5f)));if(grid!=0&&line<fminf(0.08f,t*0.001f/cell)){r+=0.04f;g+=0.04f;b+=0.04f;}float fog=fminf(0.8f,t/(extent*0.5f+2000.0f));r=r*(1.0f-fog)+0.20f*fog;g=g*(1.0f-fog)+0.25f*fog;b=b*(1.0f-fog)+0.29f*fog;distance=t*(dx*sa*cp+dy*sp+dz*ca*cp);break;}
 if(t>=finish)break;previous=t;t=fminf(finish,t+fmaxf(0.20f,t*0.025f));}
 depth[i]=distance>=999999.0f?4294967295u:(unsigned int)(fmaxf(0.0f,distance)*1000.0f);picks[i]=0u;pixels[i]=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,b)*255.0f)<<16)|4278190080u;
}
__global__ void scene_splat(const float4* pos,const float4* normal,const float4* shape,const float4* wood,const float4* objects,unsigned int* depth,unsigned int* pixels,unsigned int* picks,int w,int h,int capacity,int objectCount,int taskCount,int referenceRaster,int pass,int toon,float yaw,float pitch,float aspect,float tangent,float lx,float ly,float lz){
 unsigned int task=blockIdx.x+blockIdx.y*65535u;if(task>=(unsigned int)taskCount)return;float4 job=objects[objectCount*4+(int)task];int object=(int)job.x;float4 oa=objects[object*4];float4 ob=objects[object*4+1];float4 oc=objects[object*4+2];int slot=(int)oa.x;int samples=(int)oa.y;int species=(int)oa.z;int branchSteps=(int)oa.w;unsigned int objectId=(unsigned int)ob.x;int selected=(int)ob.y;float tx=ob.z;float ty=ob.w;float tz=oc.x;float rotation=oc.y;float scale=oc.z;int branchCount=(int)oc.w;float4 od=objects[object*4+3];if(od.z>=1.0f)return;int branchSides=(int)od.x;float screenRadius=od.y;
 unsigned int i=(unsigned int)job.y+threadIdx.x;bool grass=species==10||(species>=61&&species<=70);unsigned int leafCount=(unsigned int)samples;if(grass)leafCount*=4u;if(i>=leafCount+(unsigned int)(branchCount*branchSteps*branchSides))return;
 float3 p;float3 color=make_float3(0.0f,0.0f,0.0f);float radius=0.02f;float ca=cosf(rotation);float sa=sinf(rotation);float llx=lx*ca+lz*sa;float llz=-lx*sa+lz*ca;
 if(i<leafCount){unsigned int j=i;if(grass)j=i/4u;j+=(unsigned int)(slot*capacity);float4 v=pos[j];float4 nm=normal[j];float4 sh=shape[j];p=make_float3(v.x,v.y,v.z);radius=v.w;if(species<21&&!grass)radius*=fminf(3.5f,fmaxf(1.0f,sqrtf(20000.0f/(float)samples)));
 if(grass){float t=((float)(i%4u)+0.5f)/4.0f;p.x+=sh.x*v.w*t*t;p.y+=v.w*t;p.z+=sh.z*v.w*t*t;radius=fmaxf(0.007f,v.w*sh.w*1.5f);}
 if(pass==1)color=scene_foliage_lit(p,v.w,nm,wood[slot*1152+1024+(int)nm.w],species,toon,llx,ly,llz);
 }else{unsigned int part=i-leafCount;unsigned int perBranch=(unsigned int)(branchSteps*branchSides);unsigned int branch=part/perBranch;float4 a=wood[(unsigned int)(slot*1152)+branch];float4 b=wood[(unsigned int)(slot*1152+512)+branch];if(a.w<=0.0f)return;unsigned int local=part%perBranch;float u=((float)(local/(unsigned int)branchSides)+0.5f)/(float)branchSteps;float angle=((float)(local%(unsigned int)branchSides)+0.5f)*6.2831853f/(float)branchSides;float dx=b.x-a.x;float dy=b.y-a.y;float dz=b.z-a.z;float length=sqrtf(dx*dx+dy*dy+dz*dz);if(length<0.00001f)return;dx/=length;dy/=length;dz/=length;float sx=-dz;float sz=dx;float sl=sqrtf(sx*sx+sz*sz);if(sl<0.1f){sx=1.0f;sz=0.0f;}else{sx/=sl;sz/=sl;}float r=a.w*(1.0f-u)+b.w*u;float nx=sx*cosf(angle)+dy*sz*sinf(angle);float ny=(dz*sx-dx*sz)*sinf(angle);float nz=sz*cosf(angle)-dy*sx*sinf(angle);p=make_float3(a.x+(b.x-a.x)*u+nx*r,a.y+(b.y-a.y)*u+ny*r,a.z+(b.z-a.z)*u+nz*r);radius=fmaxf(0.008f,fminf(r*1.25f,sqrtf(r*r*0.0625f+length*length/(float)(branchSteps*branchSteps))*0.9f));float e=0.3f+0.7f*fmaxf(0.0f,nx*llx+ny*ly+nz*llz);if(toon!=0)e=e<0.46f?0.40f:e<0.74f?0.65f:0.95f;if(pass==1){float3 barkColor=bark(p,species);color=make_float3(barkColor.x*e,barkColor.y*e,barkColor.z*e);}}
 float x=(p.x*ca-p.z*sa)*scale+tx;float y=p.y*scale+ty;float z=(p.x*sa+p.z*ca)*scale+tz;float cp=cosf(pitch);float sp=sinf(pitch);float yc=cosf(yaw);float ys=sinf(yaw);float forward=x*ys*cp+y*sp+z*yc*cp;if(forward<0.05f)return;
 float horizontal=x*yc-z*ys;float vertical=-x*ys*sp+y*cp-z*yc*sp;float px=(float)w*0.5f+horizontal/(forward*tangent*aspect)*(float)w*0.5f;float py=(float)h*0.5f-vertical/(forward*tangent)*(float)h*0.5f;
 float filteredRadius=0.7f;if(i<leafCount&&screenRadius<80.0f)filteredRadius=fminf(1.5f,fmaxf(0.7f,screenRadius/sqrtf((float)samples)));float rad=fmaxf(filteredRadius,fminf(64.0f,radius*scale*(float)h/(2.0f*tangent*forward)));if(px< -rad||py< -rad||px>(float)w+rad||py>(float)h+rad)return;unsigned int key=(unsigned int)(forward*1000.0f);int ir=(int)ceilf(rad);
 if(selected!=0){color.x=color.x*0.78f+0.19f;color.y=color.y*0.78f+0.14f;color.z=color.z*0.78f+0.025f;}unsigned int packed=(unsigned int)(fminf(1.0f,color.x)*255.0f)|((unsigned int)(fminf(1.0f,color.y)*255.0f)<<8)|((unsigned int)(fminf(1.0f,color.z)*255.0f)<<16)|4278190080u;
 for(int yy=max(-ir,-(int)py);yy<=min(ir,h-1-(int)py);yy++){float rowY=(float)((int)py+yy)+.5f-py;float halfWidth=sqrtf(fmaxf(0.0f,rad*rad-rowY*rowY));int left=max(-ir,(int)floorf(px-halfWidth)-(int)px-1);int right=min(ir,(int)ceilf(px+halfWidth)-(int)px+1);if(referenceRaster!=0){left=-ir;right=ir;}for(int xx=max(left,-(int)px);xx<=min(right,w-1-(int)px);xx++){int sx=(int)px+xx;int sy=(int)py+yy;if(sx<0||sy<0||sx>=w||sy>=h)continue;float dx=(float)sx+0.5f-px;float dy=(float)sy+0.5f-py;if(dx*dx+dy*dy>rad*rad)continue;unsigned int index=(unsigned int)(sy*w+sx);if(od.z>0.0f&&rnd(index*1664525u+objectId*1013904223u)<od.z)continue;if(pass==0)atomicMin(&depth[index],key);else if(depth[index]==key){pixels[index]=packed;picks[index]=objectId;}}}
}


// Per-placement visible screen bounds and average colour, gathered entirely on the GPU.
__global__ void scene_style_clear(unsigned int* stats,int count){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(count*8))return;stats[i]=(i%8u<2u)?4294967295u:0u;}
// Only silhouette-boundary pixels can establish a bounding-box extremum.
// Colour sums are no longer consumed by the painterly finish.
__global__ void scene_style_stats(const unsigned int* pixels,const unsigned int* picks,unsigned int* stats,int w,int h){unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;unsigned int id=picks[i];if(id==0u)return;unsigned int k=id*8u;unsigned int x=i%(unsigned int)w;unsigned int y=i/(unsigned int)w;
 if(x==0u||picks[i-1u]!=id)atomicMin(&stats[k],x);
 if(x==(unsigned int)(w-1)||picks[i+1u]!=id)atomicMax(&stats[k+2u],x);
 if(y==0u||picks[i-(unsigned int)w]!=id)atomicMin(&stats[k+1u],y);
 if(y==(unsigned int)(h-1)||picks[i+(unsigned int)w]!=id)atomicMax(&stats[k+3u],y);
}
__global__ void scene_style_blur(const unsigned int* source,const unsigned int* guide,const unsigned int* picks,const unsigned int* depth,const unsigned int* stats,unsigned int* target,int w,int h,int axis,float softness){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;if(depth[i]==4294967295u){target[i]=source[i];return;}unsigned int id=picks[i];int x=(int)(i%(unsigned int)w);int y=(int)(i/(unsigned int)w);float radius=3.0f*softness;
 if(id!=0u){unsigned int k=id*8u;float span=(float)(stats[k+2u]-stats[k]+stats[k+3u]-stats[k+1u])*0.5f;radius=fminf(18.0f,fmaxf(1.0f,span*0.028f))*softness;}
 float r=0.0f;float g=0.0f;float b=0.0f;float total=0.0f;
 for(int tap=-8;tap<=8;tap++){int offset=(int)floorf((float)tap*radius/8.0f+0.5f);int xx=x;int yy=y;if(axis==0)xx+=offset;else yy+=offset;if(xx<0||xx>=w||yy<0||yy>=h)continue;int j=yy*w+xx;if(picks[j]!=id||depth[j]==4294967295u)continue;if(id==0u&&fabsf((float)depth[j]-(float)depth[i])>fmaxf(500.0f,(float)depth[i]*0.04f))continue;float t=(float)tap/8.0f;unsigned int a=guide[i];unsigned int q=guide[j];float al=(float)(a&255u)*0.2126f+(float)((a>>8)&255u)*0.7152f+(float)((a>>16)&255u)*0.0722f;float ql=(float)(q&255u)*0.2126f+(float)((q>>8)&255u)*0.7152f+(float)((q>>16)&255u)*0.0722f;float dl=(al-ql)/24.0f;float dz=((float)depth[j]-(float)depth[i])/fmaxf(500.0f,(float)depth[i]*0.008f);float weight=expf(-2.0f*t*t-dl*dl-dz*dz);unsigned int c=source[j];r+=(float)(c&255u)*weight;g+=(float)((c>>8)&255u)*weight;b+=(float)((c>>16)&255u)*weight;total+=weight;}
 target[i]=(unsigned int)(r/total)|((unsigned int)(g/total)<<8)|((unsigned int)(b/total)<<16)|4278190080u;
}
__global__ void scene_anime(const unsigned int* pixels,const unsigned int* depth,const unsigned int* picks,const unsigned int* stats,unsigned int* styled,int w,int h,float outline,float softness,float paint){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;int x=(int)(i%(unsigned int)w);int y=(int)(i/(unsigned int)w);unsigned int packed=pixels[i];float r=(float)(packed&255u)/255.0f;float g=(float)((packed>>8)&255u)/255.0f;float b=(float)((packed>>16)&255u)/255.0f;
 if(depth[i]==4294967295u){float t=(float)y/(float)h;r=0.24f+0.32f*t;g=0.56f+0.27f*t;b=0.81f+0.13f*t;}
 else{
 unsigned int id=picks[i];
 // Overlapping, irregular brush dabs sample the existing lit surface, never another object.
 if(paint>0.0f){float size=5.0f;if(id!=0u){unsigned int sk=id*8u;float span=(float)(stats[sk+2u]-stats[sk]+stats[sk+3u]-stats[sk+1u])*0.5f;size=fminf(16.0f,fmaxf(3.0f,span*0.026f));}
 float ox=0.0f;float oy=0.0f;if(id!=0u){ox=(float)stats[id*8u];oy=(float)stats[id*8u+1u];}
 float gx=((float)x-ox)/size;float gy=((float)y-oy)/size;int cellx=(int)floorf(gx);int celly=(int)floorf(gy);float sr=0.0f;float sg=0.0f;float sb=0.0f;float total=0.0f;float localL=r*0.2126f+g*0.7152f+b*0.0722f;
 for(int yy=-1;yy<=1;yy++)for(int xx=-1;xx<=1;xx++){int bx=cellx+xx;int by=celly+yy;unsigned int seed=(unsigned int)bx*73856093u^(unsigned int)by*19349663u^id*83492791u;float cx=(float)bx+0.2f+rnd(seed)*0.6f;float cy=(float)by+0.2f+rnd(seed+1u)*0.6f;float a=-0.8f+rnd(seed+2u)*1.6f;float ca=cosf(a);float sa=sinf(a);float dx=gx-cx;float dy=gy-cy;float u=(dx*ca+dy*sa)/0.85f;float v=(-dx*sa+dy*ca)/0.40f;
 float rough=0.08f*sinf(u*23.0f+(float)(seed%97u));float edge=fmaxf(fabsf(u),fabsf(v)+rough);if(edge>1.0f)continue;int sx=(int)(ox+cx*size);int sy=(int)(oy+cy*size);if(sx<0||sx>=w||sy<0||sy>=h)continue;int j=sy*w+sx;if(picks[j]!=id||depth[j]==4294967295u)continue;float dz=fabsf((float)depth[j]-(float)depth[i]);if(dz>fmaxf(500.0f,(float)depth[i]*0.01f))continue;
 unsigned int c=pixels[j];float cr=(float)(c&255u)/255.0f;float cg=(float)((c>>8)&255u)/255.0f;float cb=(float)((c>>16)&255u)/255.0f;float light=cr*0.2126f+cg*0.7152f+cb*0.0722f;float difference=(light-localL)/0.12f;float weight=fminf(1.0f,(1.0f-edge)*8.0f)*expf(-difference*difference);float pigment=0.92f+0.16f*rnd(seed+3u);sr+=cr*pigment*weight;sg+=cg*pigment*weight;sb+=cb*pigment*weight;total+=weight;}
 if(total>0.001f){float amount=paint*0.72f;r=r*(1.0f-amount)+sr/total*amount;g=g*(1.0f-amount)+sg/total*amount;b=b*(1.0f-amount)+sb/total*amount;}
 // Fine dry pigment remains subtle so it does not replace the underlying lighting.
 float grain=(rnd((unsigned int)x*1664525u+(unsigned int)y*1013904223u+id)-0.5f)*0.045f*paint;float bristle=sinf(gx*35.0f+gy*8.0f)*0.012f*paint;r=fmaxf(0.0f,r+grain+bristle);g=fmaxf(0.0f,g+grain+bristle);b=fmaxf(0.0f,b+grain+bristle);
 }
 // Broad light bands are applied after object-space-on-screen colour filtering.
 float l=r*0.2126f+g*0.7152f+b*0.0722f;float band=floorf(l*5.0f+0.5f)/5.0f;float scale=(l*0.65f+band*0.35f)/fmaxf(0.025f,l);r*=scale;g*=scale;b*=scale;float lift=0.025f*(1.0f-l);r=r*1.08f+lift;g=g*1.04f+lift;b=b+lift;
 float edges=0.0f;for(int k=0;k<4;k++){int xx=x;int yy=y;if(k==0)xx--;if(k==1)xx++;if(k==2)yy--;if(k==3)yy++;if(xx<0||xx>=w||yy<0||yy>=h)continue;int j=yy*w+xx;if(picks[j]!=id&&depth[j]>depth[i]&&((float)depth[j]-(float)depth[i])>fmaxf(250.0f,(float)depth[i]*0.025f))edges+=1.0f;}
 if(edges>=2.0f){float ink=outline*0.65f;r=r*(1.0f-ink)+0.09f*ink;g=g*(1.0f-ink)+0.14f*ink;b=b*(1.0f-ink)+0.17f*ink;}
 }
 styled[i]=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,b)*255.0f)<<16)|4278190080u;
}

__device__ float3 lod_project(float3 p,float4 ob,float4 oc,float yaw,float pitch,float tangent,float aspect,int w,int h){float ca=cosf(oc.y);float sa=sinf(oc.y);float x=(p.x*ca-p.z*sa)*oc.z+ob.z;float y=p.y*oc.z+ob.w;float z=(p.x*sa+p.z*ca)*oc.z+oc.x;float cp=cosf(pitch);float sp=sinf(pitch);float cy=cosf(yaw);float sy=sinf(yaw);float d=x*sy*cp+y*sp+z*cy*cp;return make_float3((float)w*.5f+(x*cy-z*sy)/(fmaxf(.01f,d)*tangent*aspect)*(float)w*.5f,(float)h*.5f-(-x*sy*sp+y*cp-z*cy*sp)/(fmaxf(.01f,d)*tangent)*(float)h*.5f,d);}
__device__ float3 lod_ring(float4 c,float radius,float vertical,int vertex){if(vertex==4)return make_float3(c.x,c.y+vertical,c.z);if(vertex==5)return make_float3(c.x,c.y-vertical,c.z);float a=(float)vertex*1.5707963f;return make_float3(c.x+cosf(a)*radius,c.y,c.z+sinf(a)*radius);}
__device__ float3 lod_branch_vertex(float4 a,float4 b,int vertex){float dx=b.x-a.x;float dy=b.y-a.y;float dz=b.z-a.z;float len=fmaxf(.0001f,sqrtf(dx*dx+dy*dy+dz*dz));dx/=len;dy/=len;dz/=len;float sx=-dz;float sz=dx;float sl=sqrtf(sx*sx+sz*sz);if(sl<.01f){sx=1.0f;sz=0.0f;}else{sx/=sl;sz/=sl;}float angle=(float)(vertex%8)*.78539816f;float u=0.0f;if(vertex>=8)u=1.0f;float r=a.w*(1.0f-u)+b.w*u;return make_float3(a.x+(b.x-a.x)*u+(sx*cosf(angle)+dy*sz*sinf(angle))*r,a.y+(b.y-a.y)*u+(dz*sx-dx*sz)*sinf(angle)*r,a.z+(b.z-a.z)*u+(sz*cosf(angle)-dy*sx*sinf(angle))*r);}
// Shared edge midpoints keep the cluster shell watertight as its shape rounds up close.
__device__ float3 lod_mid(float3 a,float3 b,float4 centre,float radius,float vertical,float smooth){float x=((a.x+b.x)*.5f-centre.x)/radius;float y=((a.y+b.y)*.5f-centre.y)/vertical;float z=((a.z+b.z)*.5f-centre.z)/radius;float k=1.0f+smooth*(1.0f/fmaxf(.001f,sqrtf(x*x+y*y+z*z))-1.0f);return make_float3(centre.x+x*k*radius,centre.y+y*k*vertical,centre.z+z*k*radius);}
__global__ void scene_triangles(const float4* normal,const float4* wood,const float4* objects,unsigned int* depth,unsigned int* pixels,unsigned int* picks,int w,int h,int capacity,int objectCount,int taskCount,int taskOffset,int referenceRaster,int pass,float yaw,float pitch,float aspect,float tangent,float lx,float ly,float lz,int toon){
 unsigned int task=blockIdx.x+blockIdx.y*65535u;if(task>=(unsigned int)taskCount)return;float4 job=objects[objectCount*4+taskOffset+(int)task];int object=(int)job.x;float4 oa=objects[object*4];float4 ob=objects[object*4+1];float4 oc=objects[object*4+2];float4 od=objects[object*4+3];if(od.w<=0.0f)return;unsigned int work=(unsigned int)job.y+threadIdx.x;unsigned int lanes=(unsigned int)od.w;unsigned int triangle=work/lanes;int lane=(int)(work%lanes);if(triangle>=20480u)return;int slot=(int)oa.x;int species=(int)oa.z;float3 a;float3 b;float3 c;float3 tint;
 if(triangle<4096u){int cluster=(int)(triangle/32u);int face=(int)((triangle/4u)%8u);float4 centre=wood[slot*1152+1024+cluster];float radius=.78f;float vertical=.65f;if(species>=11){radius=.28f;vertical=.25f;}if(species==2){radius=.55f;vertical=.7f;}if(species==4){radius=.22f+.4f*(1.0f-(float)(cluster/8)/16.0f);vertical=.22f;}if(species==5){radius=.6f;vertical=.3f;}if(species==6){radius=.25f;vertical=.4f;}if(species==7){radius=.16f;vertical=.28f;}if(species==3)vertical=1.7f;int corner=face%4;int pole=4;if(face>=4)pole=5;a=lod_ring(centre,radius,vertical,pole);b=lod_ring(centre,radius,vertical,corner);c=lod_ring(centre,radius,vertical,(corner+1)%4);float inset=.88f+.12f*od.z;float smooth=1.0f-od.z;
 float3 ab=lod_mid(a,b,centre,radius,vertical,smooth);float3 bc=lod_mid(b,c,centre,radius,vertical,smooth);float3 ac=lod_mid(a,c,centre,radius,vertical,smooth);int sub=(int)(triangle%4u);if(sub==0){b=ab;c=ac;}else if(sub==1){a=ab;c=bc;}else if(sub==2){a=ac;b=bc;}else{a=ab;b=bc;c=ac;}
 a=make_float3(centre.x+(a.x-centre.x)*inset,centre.y+(a.y-centre.y)*inset,centre.z+(a.z-centre.z)*inset);b=make_float3(centre.x+(b.x-centre.x)*inset,centre.y+(b.y-centre.y)*inset,centre.z+(b.z-centre.z)*inset);c=make_float3(centre.x+(c.x-centre.x)*inset,centre.y+(c.y-centre.y)*inset,centre.z+(c.z-centre.z)*inset);
 tint=make_float3(.27f,.47f,.13f);if(species==4||species==5||species==7)tint=make_float3(.15f,.32f,.13f);
 }else{unsigned int part=triangle-4096u;int branch=(int)(part/32u);int face=(int)(part%32u);float4 start=wood[slot*1152+branch];float4 end=wood[slot*1152+512+branch];if(start.w<=0.0f)return;
 if(face<16){int side=face/2;int next=(side+1)%8;if(face%2==0){a=lod_branch_vertex(start,end,side);b=lod_branch_vertex(start,end,next);c=lod_branch_vertex(start,end,side+8);}else{a=lod_branch_vertex(start,end,next);b=lod_branch_vertex(start,end,next+8);c=lod_branch_vertex(start,end,side+8);}}
 else{int side=(face-16)%8;int offset=face>=24?8:0;a=make_float3(start.x,start.y,start.z);if(offset==8)a=make_float3(end.x,end.y,end.z);b=lod_branch_vertex(start,end,side+offset);c=lod_branch_vertex(start,end,(side+1)%8+offset);}tint=make_float3(1.0f,1.0f,1.0f);}

 float llx=lx*cosf(oc.y)+lz*sinf(oc.y);float llz=-lx*sinf(oc.y)+lz*cosf(oc.y);float3 ca;float3 cb;float3 cc;
 if(pass==1){if(triangle<4096u){int cluster=(int)(triangle/32u);float4 centre=wood[slot*1152+1024+cluster];float4 nm=normal[slot*capacity+cluster];nm.z=floorf(nm.z)+0.5f;ca=scene_foliage_lit(a,.02f,nm,centre,species,toon,llx,ly,llz);cb=scene_foliage_lit(b,.02f,nm,centre,species,toon,llx,ly,llz);cc=scene_foliage_lit(c,.02f,nm,centre,species,toon,llx,ly,llz);}
 else{float nx=(b.y-a.y)*(c.z-a.z)-(b.z-a.z)*(c.y-a.y);float ny=(b.z-a.z)*(c.x-a.x)-(b.x-a.x)*(c.z-a.z);float nz=(b.x-a.x)*(c.y-a.y)-(b.y-a.y)*(c.x-a.x);float nl=fmaxf(.001f,sqrtf(nx*nx+ny*ny+nz*nz));float3 middle=make_float3((a.x+b.x+c.x)/3.0f,(a.y+b.y+c.y)/3.0f,(a.z+b.z+c.z)/3.0f);int branch=(int)((triangle-4096u)/32u);float4 start=wood[slot*1152+branch];float4 end=wood[slot*1152+512+branch];float bx=end.x-start.x;float by=end.y-start.y;float bz=end.z-start.z;float t=((middle.x-start.x)*bx+(middle.y-start.y)*by+(middle.z-start.z)*bz)/fmaxf(.001f,bx*bx+by*by+bz*bz);float rx=middle.x-start.x-bx*t;float ry=middle.y-start.y-by*t;float rz=middle.z-start.z-bz*t;if(nx*rx+ny*ry+nz*rz<0.0f){nx=-nx;ny=-ny;nz=-nz;}float lighting=.3f+.7f*fmaxf(0.0f,(nx*llx+ny*ly+nz*llz)/nl);if(toon!=0)lighting=lighting<.46f?.40f:lighting<.74f?.65f:.95f;ca=make_float3(tint.x*lighting,tint.y*lighting,tint.z*lighting);cb=ca;cc=ca;}}

 float3 localA=a;float3 localB=b;float3 localC=c;
 a=lod_project(a,ob,oc,yaw,pitch,tangent,aspect,w,h);b=lod_project(b,ob,oc,yaw,pitch,tangent,aspect,w,h);c=lod_project(c,ob,oc,yaw,pitch,tangent,aspect,w,h);if(a.z<.05f||b.z<.05f||c.z<.05f)return;float area=(b.x-a.x)*(c.y-a.y)-(b.y-a.y)*(c.x-a.x);if(fabsf(area)<.001f)return;int minx=max(0,(int)floorf(fminf(a.x,fminf(b.x,c.x))));int maxx=min(w-1,(int)ceilf(fmaxf(a.x,fmaxf(b.x,c.x))));int miny=max(0,(int)floorf(fminf(a.y,fminf(b.y,c.y))));int maxy=min(h-1,(int)ceilf(fmaxf(a.y,fmaxf(b.y,c.y))));
 for(int y=miny+lane;y<=maxy;y+=(int)lanes){float scanY=(float)y+.5f;float left=(float)w;float right=-1.0f;
 if(fabsf(b.y-a.y)>.000001f){float edge=(scanY-a.y)/(b.y-a.y);if(edge>=0.0f&&edge<=1.0f){float hit=a.x+(b.x-a.x)*edge;left=fminf(left,hit);right=fmaxf(right,hit);}}
 if(fabsf(c.y-b.y)>.000001f){float edge=(scanY-b.y)/(c.y-b.y);if(edge>=0.0f&&edge<=1.0f){float hit=b.x+(c.x-b.x)*edge;left=fminf(left,hit);right=fmaxf(right,hit);}}
 if(fabsf(a.y-c.y)>.000001f){float edge=(scanY-c.y)/(a.y-c.y);if(edge>=0.0f&&edge<=1.0f){float hit=c.x+(a.x-c.x)*edge;left=fminf(left,hit);right=fmaxf(right,hit);}}
 // Single-lane reference retains the full bounding box for parity checks.
 if(referenceRaster!=0){left=(float)minx;right=(float)maxx;}
 // Conservative row span; the original barycentric test still decides exact coverage.
 for(int x=max(minx,(int)floorf(left)-1);x<=min(maxx,(int)ceilf(right)+1);x++){float px=(float)x+.5f;float py=(float)y+.5f;float u=((b.x-px)*(c.y-py)-(b.y-py)*(c.x-px))/area;float v=((c.x-px)*(a.y-py)-(c.y-py)*(a.x-px))/area;float t=1.0f-u-v;if(u<0.0f||v<0.0f||t<0.0f)continue;unsigned int d=(unsigned int)(1000.0f/(u/a.z+v/b.z+t/c.z));int index=y*w+x;if(pass==0)atomicMin(&depth[index],d);else if(depth[index]==d){float inv=1.0f/(u/a.z+v/b.z+t/c.z);float ru=u/a.z*inv;float rv=v/b.z*inv;float rt=t/c.z*inv;float r=ca.x*ru+cb.x*rv+cc.x*rt;float g=ca.y*ru+cb.y*rv+cc.y*rt;float bl=ca.z*ru+cb.z*rv+cc.z*rt;if(triangle>=4096u){float3 surface=make_float3(localA.x*ru+localB.x*rv+localC.x*rt,localA.y*ru+localB.y*rv+localC.y*rt,localA.z*ru+localB.z*rv+localC.z*rt);float3 pigment=bark(surface,species);r*=pigment.x;g*=pigment.y;bl*=pigment.z;}if(ob.y>.5f){r=r*.78f+.19f;g=g*.78f+.14f;bl=bl*.78f+.025f;}unsigned int packed=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,bl)*255.0f)<<16)|4278190080u;pixels[index]=packed;picks[index]=(unsigned int)ob.x;}}
}
}
