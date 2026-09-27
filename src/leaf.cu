// All geometry, lighting, visibility and pixel colour are authored in CUDA.

__device__ unsigned int hash(unsigned int x){x ^= x >> 16; x *= 2146121005u; x ^= x >> 15; x *= 2221713035u; x ^= x >> 16; return x;}

__device__ float rnd(unsigned int x){return (float)(hash(x)&16777215u)/16777216.0f;}

// Four planted rows, eight plants per row; fixed layout with seeded variation.
// Stable fruiting bodies; surface count adds detail without adding mushrooms.
__device__ float4 mineralBody(unsigned int body,unsigned int seed,int species){
 float a=(float)body*2.399963f;float dist=0.95f*sqrtf((float)body/16.0f);float size=0.28f+0.18f*rnd(body+seed+601u);float height=0.65f+1.0f*rnd(body+seed+602u);
 float x=cosf(a)*dist;float z=sinf(a)*dist;
 if(species==91||species==95){dist*=1.35f;x=cosf(a)*dist;z=sinf(a)*dist;height=size*1.5f;}
 if(species==92){x=((float)(body%4u)-1.5f)*0.49f;z=((float)(body/4u)-1.5f)*0.43f;if(body%2u==0u)z+=0.2f;size=0.28f;}
 if(species==94){x=cosf(a)*0.45f;z=sinf(a)*0.45f;size=0.7f+0.25f*rnd(body+seed);height=0.12f;}
 if(species==93){x=((float)(body%2u)-0.5f)*0.95f;z=((float)((body/2u)%2u)-0.5f)*0.85f;size=0.52f+0.1f*rnd(body+seed);height=0.38f;}
 if(species==99||species==100)height=size*1.8f;
 return make_float4(x,height,z,size);
}

__device__ float4 mushroomBody(unsigned int body,unsigned int seed,int species){
 float a=(float)body*2.399963f;float r=0.34f+1.1f*sqrtf(rnd(body+seed+441u));
 if(species==86)r*=0.62f;
 if(species==90){a=(float)body*0.392699f;r=1.3f+0.08f*rnd(body+seed);}
 float h=0.42f+0.38f*rnd(body+seed+442u);float size=0.21f+0.12f*rnd(body+seed+443u);
 if(species==82){h*=0.8f;size*=1.3f;}if(species==84||species==86||species==90)size*=0.68f;
 if(species==85){h*=1.2f;size*=0.65f;}
 if(species==89){h=size*0.7f;}
 float3 pos=make_float3(cosf(a)*r,h,sinf(a)*r);
 if(species==87||species==88){pos=make_float3(((float)(body%4u)-1.5f)*0.65f+0.12f*sinf((float)body),0.25f+(float)(body/4u)*0.10f+0.025f*rnd(body+seed),-0.20f);size*=1.5f;}
 return make_float4(pos.x,pos.y,pos.z,size);
}

__device__ float3 cropRoot(unsigned int plant,unsigned int seed){return make_float3(((float)(plant%8u)-3.5f)*0.43f+(rnd(plant+seed)-0.5f)*0.06f,0.0f,((float)(plant/8u)-1.5f)*0.60f);}
__device__ float cropHeight(unsigned int plant,unsigned int seed,int species){
 float h=1.2f;if(species==73)h=1.35f;if(species==74)h=0.95f;if(species==75)h=2.15f;if(species==76)h=1.85f;if(species==77)h=1.50f;if(species==78)h=2.25f;if(species==79)h=0.80f;if(species==80)h=1.05f;
 return h*(0.87f+0.24f*rnd(plant+seed+713u));
}
__device__ float3 cropStem(unsigned int plant,unsigned int seed,int species,float t){float3 p=cropRoot(plant,seed);return make_float3(p.x+0.035f*t*t*sinf((float)plant),cropHeight(plant,seed,species)*t,p.z+0.025f*t*t*cosf((float)plant));}

__device__ float3 grassSite(unsigned int c,unsigned int seed,int species){
 if(species>=62&&species<=66)return make_float3(((float)(c%16u)+0.5f)*0.22f-1.76f,0.0f,((float)(c/16u)+0.5f)*0.36f-1.44f);
 unsigned int clump=c%7u;float angle=(float)clump*2.399963f+rnd(seed)*6.283185f;float radius=1.05f*sqrtf((float)clump/7.0f);
 return make_float3(cosf(angle)*radius,0.0f,sinf(angle)*radius);
}

// Growth guides: root/disc clingers follow bark; twiners circle a trunk;
// tendril and petiole climbers spread over an explicit trellis.
__device__ int vineTrellis(int species){if(species==55||species==58)return 1;return 0;}
__device__ float vineAttach(unsigned int lane){return (6.0f+(float)(lane%5u))/20.0f;}
__device__ float3 vineMain(unsigned int lane,unsigned int seed,int species,float t){
 float phase=rnd(seed+lane*127u)*0.35f;float a=(float)lane*0.785398f+phase;
 float height=2.45f+0.52f*rnd(lane+seed+81u);float y=height*t;
 if(vineTrellis(species)==1){
  float start=((float)(lane%3u)-1.0f)*0.8f;float target=((float)((lane+1u)%3u)-1.0f)*0.8f;
  float u=fminf(1.0f,fmaxf(0.0f,(t-0.27f)*1.7f));
  return make_float3(start+(target-start)*u, y, -0.085f-0.025f*sinf(t*17.0f+phase));
 }
 if(species==56||species==57||species==59){float direction=1.0f;if(species==56)direction=-1.0f;a+=direction*t*10.0f;}
 else a+=0.23f*sinf(t*8.0f+phase)+(rnd(lane+seed+13u)-0.5f)*t*1.6f;
 float radius=0.435f+0.012f*sinf(y*4.0f+a*3.0f);
 return make_float3(cosf(a)*radius,y,sinf(a)*radius);
}
__device__ float3 vinePath(unsigned int path,unsigned int seed,int species,float t){
 if(path<8u)return vineMain(path,seed,species,t);
 unsigned int lane=path-8u;float3 root=vineMain(lane,seed,species,vineAttach(lane));float side=1.0f;if(lane%2u==0u)side=-1.0f;
 if(vineTrellis(species)==1)return make_float3(root.x+side*0.55f*t,root.y+0.85f*t,root.z-0.025f*sinf(t*8.0f)*t);
 float a=atan2f(root.z,root.x);float y=root.y+1.0f*t;
 if(species==56||species==57||species==59){float direction=1.0f;if(species==56)direction=-1.0f;a+=direction*5.0f*t;}
 else a+=side*0.85f*t+0.08f*sinf(t*6.0f);
 float radius=0.435f+0.012f*sinf(y*4.0f+a*3.0f);
 if(t==0.0f)return root;
 return make_float3(cosf(a)*radius,y,sinf(a)*radius);
}
__device__ float3 vinePoint(unsigned int path,unsigned int seed,int species,float t){
 float f=t*20.0f;float segment=fminf(19.0f,floorf(f));float u=f-segment;
 float3 a=vinePath(path,seed,species,segment/20.0f);float3 b=vinePath(path,seed,species,(segment+1.0f)/20.0f);
 return make_float3(a.x+(b.x-a.x)*u,a.y+(b.y-a.y)*u,a.z+(b.z-a.z)*u);
}
__device__ float vineNode(unsigned int c,unsigned int seed){return ((float)(c/16u)+0.35f+0.35f*rnd(c+seed+981u))/8.3f;}
__device__ float3 vineLeaf(unsigned int c,unsigned int seed,int species){
 float3 p=vinePoint(c%16u,seed,species,vineNode(c,seed));float side=1.0f;if((c/16u)%2u==0u)side=-1.0f;
 if(vineTrellis(species)==1)return make_float3(p.x+side*0.13f,p.y+0.05f,p.z-0.13f);
 float a=atan2f(p.z,p.x);return make_float3(p.x+cosf(a)*0.15f-sinf(a)*side*0.07f,p.y+0.055f,p.z+sinf(a)*0.15f+cosf(a)*side*0.07f);
}

// Moss patches are magnified displays. 128 clusters, 16 shoots per cluster.
__device__ float3 mossSite(unsigned int cluster,unsigned int seed,int species){
 float angle=(float)cluster*2.399963f+rnd(seed)*6.283185f;
 float radius=1.6f*sqrtf(((float)cluster+0.5f)/128.0f);
 float x=cosf(angle)*radius;float z=sinf(angle)*radius;float y=0.025f;
 if(species==41){
  unsigned int mound=cluster%7u;float a=(float)mound*2.399963f;float r=0.95f*sqrtf((float)mound/7.0f);
  float local=0.52f*sqrtf(rnd(cluster+seed+81u));x=cosf(a)*r+cosf(angle)*local;z=sinf(a)*r+sinf(angle)*local;
  y=0.48f*sqrtf(fmaxf(0.0f,1.0f-local*local/0.30f));
 }
 if(species==43)y=0.16f+0.10f*sinf(x*3.0f)*cosf(z*3.0f);
 if(species==49)y=0.12f+0.12f*sinf(x*2.5f)*cosf(z*3.0f);
 if(species==50)y=0.05f+0.04f*cosf(x*7.0f)*sinf(z*5.0f);
 return make_float3(x,y,z);
}

// Fern rachises and foliage share one curve; t runs from crown to tip.
__device__ float fernAngle(unsigned int frond,unsigned int seed){float a=(float)frond*2.399963f+rnd(seed)*6.283185f;return a-floorf(a/6.283185f)*6.283185f;}
__device__ float3 fernPoint(unsigned int frond,unsigned int seed,int species,float t){
 float a=fernAngle(frond,seed);float size=0.65f+0.45f*rnd(frond+seed+431u);
 float reach=1.8f;float height=1.8f;float droop=0.8f;
 if(species==31){reach=2.0f;height=1.7f;droop=1.1f;}
 if(species==32){reach=0.95f;height=2.9f;droop=0.18f;}
 if(species==33){reach=1.55f;height=1.4f;droop=0.0f;}
 if(species==34){reach=1.55f;height=1.8f;droop=0.35f;}
 if(species==35){reach=1.5f;height=1.25f;droop=0.45f;}
 if(species==36){reach=1.35f;height=1.9f;droop=0.5f;}
 if(species==37){reach=1.75f;height=1.6f;droop=0.35f;}
 if(species==38){reach=1.7f;height=1.25f;droop=0.4f;}
 if(species==39){reach=1.4f;height=2.6f;droop=0.25f;}
 if(species==40){reach=1.5f;height=1.9f;droop=0.15f;}
 float radial=0.06f+reach*t*t*size;float y=(height*sinf(t*1.65f)-droop*t*t*t)*size;
 if(species==33){radial=0.06f+reach*fmaxf(0.0f,t-0.3f)/0.7f*size;y=height*fminf(1.0f,t/0.35f)*size-0.12f*t*t;}
 return make_float3(cosf(a)*radial,y,sinf(a)*radial);
}
__device__ float fernWidth(float t,int species){
 float width=0.34f;
 if(species==32)width=0.31f;if(species==33)width=0.20f;if(species==34||species==35)width=0.43f;
 if(species==36)width=0.25f;if(species==37)width=0.40f;if(species==39)width=0.49f;if(species==40)width=0.46f;
 return width*powf(fmaxf(0.0f,sinf((t-0.12f)/0.88f*3.14159f)),0.65f);
}

// Flower beds use 16 plants and eight lighting clusters per plant.
__device__ float3 flowerHead(unsigned int plant,unsigned int seed,int species){
 float a=(float)plant*2.399963f+rnd(seed)*6.28f;
 float r=1.55f*sqrtf(((float)plant+0.5f)/16.0f);
 float h=1.25f+0.55f*rnd(plant+seed+521u);
 if(species==21)h+=0.45f;if(species==29)h+=0.3f;
 return make_float3(cosf(a)*r,h,sinf(a)*r);
}

// Stable preset IDs: trees 0..9, grass 10, bushes 11..20, flowers 21..30.

__device__ float3 center(unsigned int c,unsigned int seed,int species){

 if(species>=111)return make_float3(0.0f,0.65f,0.0f);
 if(species>=101)return make_float3((rnd(c+seed+701u)-0.5f)*3.6f,0.04f,(rnd(c+seed+702u)-0.5f)*2.8f);
 if(species>=91&&species<=100){float4 m=mineralBody(c%16u,seed,species);return make_float3(m.x,m.y*0.5f,m.z);}
 if(species>=81&&species<=90){float4 m=mushroomBody(c%16u,seed,species);return make_float3(m.x,m.y,m.z);}
 if(species>=71)return cropStem(c%32u,seed,species,0.7f);
 if(species>=61)return grassSite(c,seed,species);
 if(species>=51)return vineLeaf(c,seed,species);
 if(species>=41)return mossSite(c,seed,species);
 if(species>=31)return fernPoint(c%16u,seed,species,0.18f+0.82f*((float)(c/16u)+0.5f)/8.0f);
 if(species>=21)return flowerHead(c%16u,seed,species);
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

 if(species>=11&&species<=20){

 float q=rnd(c*73u+seed+9u);float ht=rnd(c*37u+seed+11u);a=(float)(c%16u)*2.399963f+0.15f*sinf((float)c);

 r=1.25f*sqrtf(q);y=0.45f+1.45f*sqrtf(fmaxf(0.0f,1.0f-r*r/1.7f))*ht;

 if(species==12){r=1.25f*sqrtf(q);y=0.25f+0.55f*sqrtf(fmaxf(0.0f,1.0f-r*r/1.7f));}

 if(species==13){r=0.95f*sqrtf(q);y=0.45f+1.8f*ht;}

 if(species==14){r=1.5f*sqrtf(q);y=0.4f+1.35f*sqrtf(fmaxf(0.0f,1.0f-r*r/2.5f))*ht;}

 if(species==15){r=1.6f*sqrtf(q);y=0.55f+1.6f*ht;}

 if(species==16){r=1.25f*sqrtf(q);y=0.35f+1.1f*ht;}

 if(species==17){float t=0.25f+0.75f*ht;r=1.9f*t;y=0.15f+3.8f*t-2.3f*t*t;}

 if(species==18){r=2.0f*sqrtf(q);y=0.12f+0.3f*(1.0f-q);}

 if(species==19){r=0.8f*sqrtf(q);y=0.25f+2.5f*ht;}

 if(species==20){float t=0.2f+0.8f*ht;r=1.45f*t;y=0.18f+2.8f*t-1.8f*t*t;}

 }

 return make_float3(cosf(a)*r,y,sinf(a)*r);

}

__device__ float3 normdir(float a,float e){return make_float3(cosf(a)*cosf(e),sinf(e),sinf(a)*cosf(e));}

__device__ float exposure(float3 n,float3 p,float3 l,int species){

 float lam=fabsf(n.x*l.x+n.y*l.y+n.z*l.z);

 float side=(p.x*l.x+(p.y-4.8f)*l.y+p.z*l.z)/3.7f;

 if(species==10)side=0.25f;

 if(species>=11)side=(p.x*l.x+(p.y-0.9f)*l.y+p.z*l.z)/2.0f;

 float shelter=fminf(1.0f,fmaxf(0.12f,0.5f+side*0.48f));

 return 0.18f+0.82f*lam*shelter;

}

__device__ float3 flowerWind(float3 p,float time,float wind){
 float bend=p.y*p.y*wind*0.10f;
 return make_float3(p.x+sinf(time*1.5f)*bend,p.y,p.z+cosf(time*1.1f)*bend*0.4f);
}

__device__ float3 plantWind(float3 p,float time,float wind,int species){
 if(species>=81)return p;
 if(species>=51&&species<=60)return p;

 return flowerWind(p,time,wind);
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

 if(species>=11&&species<=20){spread=0.28f;vertical=0.25f;}

 if(species==18){spread=0.32f;vertical=0.08f;}

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

 float bloom=0.0f;

 if(species>=11&&species<=20){

 len=0.018f+rnd(s+6u)*0.025f;width=0.6f;

 if(species==12||species==13){len*=1.3f;width=0.13f;axis=make_float3(cosf(a)*0.6f,0.7f,sinf(a)*0.6f);}

 if(species==14||species==15){len*=2.0f;width=0.68f;}

 if(species==18){len*=0.65f;width=0.16f;axis=make_float3(cosf(a),0.15f,sinf(a));}

 if(species==19){len*=0.75f;width=0.65f;}

 if(species==20){len*=0.7f;width=0.85f;}

 float chance=0.0f;if(species==12)chance=0.22f;if(species==13)chance=0.045f;if(species==14)chance=0.22f;if(species==15)chance=0.15f;if(species==16)chance=0.32f;if(species==17)chance=0.85f;

 if(rnd(s+31u)<chance){bloom=1.0f;width=0.9f;len=0.02f+rnd(s+32u)*0.018f;

 if(species==12){p=center(c,seed,species);p.x+=cosf(a)*0.04f;p.z+=sinf(a)*0.04f;p.y+=0.25f+rnd(s+33u)*0.32f;len*=0.6f;}

 if(species==14||species==15){unsigned int flower=c%24u;float fa=(float)flower*2.399963f;float fr=1.15f*sqrtf(rnd(flower+seed+433u));float yy=1.45f+0.3f*rnd(flower+seed+511u);if(species==15)yy+=0.95f;float ball=0.22f;if(species==15)ball=0.16f;

 p=make_float3(cosf(fa)*fr+cosf(a)*cosf(e)*ball,yy+sinf(e)*ball,sinf(fa)*fr+sinf(a)*cosf(e)*ball);}

 }

 p.y=fmaxf(0.04f,p.y);

 }


 // Petal surfaces are sampled in the same seeded instance buffers as leaves.
 // Marker 0 = leaf, 1 = petal, 2 = centre/corona. Count is surface samples.
 if(species>=21&&species<=30){
  unsigned int plant=c%16u;float3 head=flowerHead(plant,seed,species);
  float turn=rnd(plant+seed+811u)*0.8f-0.4f;
  float u=rnd(s+61u);float v=rnd(s+62u);float theta=6.283185f*rnd(s+63u);
  float x=0.0f;float y=0.0f;float z=0.0f;float choose=rnd(s+64u);
  len=0.021f;width=1.0f;bloom=1.0f;
  float nx=0.0f;float ny=0.65f;float nz=-0.76f;
  if(choose<0.25f){
   // Repeated samples fill a small, finite set of leaves attached to each stem.
   unsigned int leaf=(unsigned int)(rnd(s+65u)*6.0f);float la=(float)leaf*2.399963f+turn;
   float attach=0.18f+(float)leaf*0.12f;float reach=0.45f;float leafWidth=0.13f;
   if(species==21){reach=0.52f;leafWidth=0.22f;}
   if(species==27){reach=0.42f;leafWidth=0.018f;}
   if(species==23||species==24||species==29||species==30){attach=0.04f;reach=0.6f;leafWidth=0.07f;}
   float side=(v-0.5f)*2.0f*sinf(u*3.14159f)*leafWidth;
   p=make_float3(head.x+cosf(la)*reach*u-sinf(la)*side,head.y*attach+0.36f*sinf(u*2.0f),head.z+sinf(la)*reach*u+cosf(la)*side);
   if(species==23||species==24||species==29||species==30)p.y=head.y*attach+u*1.15f;
   bloom=0.0f;nx=cosf(la)*0.45f;ny=0.78f;nz=sinf(la)*0.45f;
  }else{
   float petals=16.0f;float inner=0.12f;float reach=0.28f;float wide=0.06f;
   if(species==21){petals=24.0f;inner=0.21f;reach=0.26f;wide=0.055f;}
   if(species==22){petals=20.0f;inner=0.09f;reach=0.27f;wide=0.038f;}
   if(species==24){petals=6.0f;inner=0.04f;reach=0.31f;wide=0.11f;}
   if(species==25){petals=4.0f;inner=0.015f;reach=0.35f;wide=0.27f;}
   if(species==27){petals=8.0f;inner=0.065f;reach=0.3f;wide=0.13f;}
   if(species==28){petals=15.0f;inner=0.10f;reach=0.33f;wide=0.04f;}
   float pa=floorf(rnd(s+65u)*petals)*6.283185f/petals+turn;
   float radial=inner+reach*u;float across=(v-0.5f)*2.0f*wide*sinf(3.14159f*powf(u,0.7f));
   x=cosf(pa)*radial-sinf(pa)*across;y=sinf(pa)*radial+cosf(pa)*across;
   z=0.045f*sinf(u*3.14159f);
   if(species==25)z=-0.15f*u*u+0.018f*sinf(across*90.0f);
   if(species==28)z=0.30f*u*u;
   if(choose>0.85f){bloom=2.0f;float rr=inner*sqrtf(u);x=cosf(theta)*rr;y=sinf(theta)*rr;z=-0.02f-0.05f*(1.0f-u);if(species==28)z=-0.23f*(1.0f-sqrtf(u));}
   // Tilt disk flowers toward the open sky. The normal follows petal curvature.
   float yy=y*0.76f-z*0.65f;float zz=y*0.65f+z*0.76f;y=yy;z=zz;
   nx=cosf(pa)*0.2f*u;ny=0.65f;nz=-0.76f;
   if(species==23){ // Six overlapping upright tepals, open at the rim.
    pa=floorf(rnd(s+65u)*6.0f)*1.047198f+turn+(v-0.5f)*1.12f;
    float radius=0.06f+0.19f*sinf(u*2.0f);x=cosf(pa)*radius;z=sinf(pa)*radius;y=-0.1f+u*0.48f-0.045f*powf(fabsf(v-0.5f)*2.0f,3.0f);
    bloom=1.0f;nx=cosf(pa)*0.9f;ny=0.2f;nz=sinf(pa)*0.9f;
   }
   if(species==24&&choose>0.70f){ // Projecting hollow trumpet with a flared lip.
    float radius=0.07f+0.055f*u*u;x=cosf(theta)*radius;y=sinf(theta)*radius*0.76f+u*0.14f;z=sinf(theta)*radius*0.65f-u*0.20f;bloom=2.0f;
    nx=cosf(theta);ny=sinf(theta)*0.76f;nz=sinf(theta)*0.65f;
   }
   if(species==26){ // Five staggered whorls form a layered garden rose.
    float layer=floorf(rnd(s+65u)*5.0f);pa=floorf(rnd(s+66u)*7.0f)*0.897598f+layer*0.47f+(v-0.5f)*1.1f;
    float radius=(0.055f+layer*0.047f)*(0.55f+0.65f*u);
    x=cosf(pa)*radius;z=sinf(pa)*radius;y=0.13f-layer*0.045f+0.14f*sinf(u*2.5f)-0.055f*u*u;
    float ry=y;float rz=z;y=ry*0.65f+rz*0.76f;z=-ry*0.76f+rz*0.65f;
    bloom=1.0f;nx=cosf(pa)*0.7f;ny=0.65f;nz=-0.76f+sinf(pa)*0.3f;
   }
   if(species==29){ // Six pendent bells on one side of each flowering stalk.
    float bell=floorf(rnd(s+65u)*6.0f);float t=u;float radius=0.065f+0.04f*powf(t,3.0f);
    x=0.10f+bell*0.024f+cosf(theta)*radius;y=-bell*0.14f-t*0.18f;z=sinf(theta)*radius;
    if(t>0.8f)y+=0.025f*cosf(theta*6.0f)*(t-0.8f)*5.0f;
    bloom=1.0f;nx=cosf(theta);ny=0.15f;nz=sinf(theta);
   }
   if(species==30){ // Three upright standards and three drooping falls.
    float fall=0.0f;if(choose>0.60f)fall=1.0f;
    pa=floorf(rnd(s+65u)*3.0f)*2.094395f+turn+fall*1.047198f;
    float rr=0.08f+u*0.26f;float sw=(v-0.5f)*0.28f*sinf(u*3.14159f);
    x=cosf(pa)*rr-sinf(pa)*sw;z=sinf(pa)*rr+cosf(pa)*sw;y=0.38f*sinf(u*1.8f);
    if(fall>0.5f)y=0.10f*sinf(u*3.14159f)-0.22f*u*u;
    bloom=1.0f;if(fall>0.5f&&fabsf(v-0.5f)<0.07f&&u<0.65f)bloom=2.0f;
    nx=cosf(pa)*0.55f;ny=0.65f;nz=sinf(pa)*0.55f;
   }
   p=make_float3(head.x+x*cosf(turn)-z*sinf(turn),head.y+y,head.z+x*sinf(turn)+z*cosf(turn));
  }
  na=atan2f(nz,nx);if(na<0.0f)na+=6.283185f;
  ne=atan2f(ny,sqrtf(nx*nx+nz*nz));ne=fminf(1.34f,fmaxf(-1.34f,ne));
  axis=make_float3(cosf(na),0.25f,sinf(na));
 }


 // Each patch samples an attached pinna/pinnule, never a canopy volume.
 if(species>=31&&species<=40){
  unsigned int frond=c%16u;float fa=fernAngle(frond,seed);float u=rnd(s+71u);float v=rnd(s+72u);
  float side=1.0f;if(rnd(s+73u)<0.5f)side=-1.0f;
  float pairs=24.0f;if(species==32)pairs=32.0f;if(species==33)pairs=12.0f;if(species==37||species==40)pairs=9.0f;
  if(species==34||species==35||species==39)pairs=8.0f;
  float row=floorf(rnd(s+74u)*pairs);float t=0.19f+0.78f*(row+0.5f)/pairs;
  if(species==33)t=0.40f+0.57f*(row+0.5f)/pairs;
  float3 root=fernPoint(frond,seed,species,t);float wide=fernWidth(t,species);
  float across=side*wide*u;float along=0.12f*u+(v-0.5f)*0.10f*sinf(u*3.14159f);float lift=0.02f*sinf(u*3.14159f);
  if(species==37){along=0.23f*u+(v-0.5f)*0.23f*sinf(u*3.14159f);}
  if(species==38){along=0.075f*u+(v-0.5f)*0.12f*sinf(u*3.14159f);}
  if(species==40){along=0.13f*u+(v-0.5f)*0.26f*sinf(u*3.14159f)*(0.8f+0.2f*cosf(u*25.0f));}
  if(species==33){ // Small fan-shaped pinnules on spreading fingers.
   across=side*(0.025f+0.15f*u);along=0.025f+(v-0.5f)*0.19f*u;lift=-0.06f*u;
  }
  if(species==34||species==35||species==39){ // Second-order pinnules along each pinna.
   float at=(floorf(rnd(s+75u)*7.0f)+0.5f)/7.0f;float ps=1.0f;if(rnd(s+76u)<0.5f)ps=-1.0f;
   float length=0.09f*(1.0f-at*0.65f);if(species==39)length=0.16f*(1.0f-at*0.4f);
   across=side*(wide*at+(v-0.5f)*0.065f*sinf(u*3.14159f));
   along=0.12f*at+ps*length*u;lift=0.025f*sinf(u*3.14159f);
  }
  if(species==36){ // Undivided strap blade with a wavy edge and raised midrib.
   t=0.13f+0.86f*rnd(s+74u);root=fernPoint(frond,seed,species,t);
   across=(v-0.5f)*2.0f*fernWidth(t,species)*(0.94f+0.06f*sinf(t*58.0f));along=0.0f;
   lift=0.025f*cosf(v*6.283185f)+0.035f*sinf(t*58.0f)*fabsf(v-0.5f);
  }
  float3 next=fernPoint(frond,seed,species,t+0.005f);
  float dx=next.x-root.x;float dy=next.y-root.y;float dz=next.z-root.z;float d=sqrtf(dx*dx+dy*dy+dz*dz);dx/=d;dy/=d;dz/=d;
  p=make_float3(root.x-sinf(fa)*across+dx*along,root.y+lift+dy*along,root.z+cosf(fa)*across+dz*along);
  // Approximate upward surface normal varies smoothly across the blade.
  na=fa+3.14159f;if(na>=6.283185f)na-=6.283185f;ne=fminf(1.34f,atan2f(sqrtf(dx*dx+dz*dz),fabsf(dy)));if(dy<0.0f){na=fa;}
  axis=make_float3(-sinf(fa),0.15f,cosf(fa));len=0.018f;width=0.9f;bloom=0.0f;
 }


 if(species>=41&&species<=50){
  unsigned int shoot=(i/128u)%16u;if(species==44||species==45||species==46||species==48)shoot=0u;if(species==42)shoot%=4u;unsigned int ss=hash(seed+c*713u+shoot*3571u);
  float3 base=mossSite(c,seed,species);base.x+=(rnd(ss+1u)-0.5f)*0.23f;base.z+=(rnd(ss+2u)-0.5f)*0.23f;
  if(species==41){
   float ma=(float)(c%7u)*2.399963f;float mr=0.95f*sqrtf((float)(c%7u)/7.0f);
   float local=0.60f*sqrtf(rnd(ss+9u));float la=rnd(ss+10u)*6.283185f;
   base=make_float3(cosf(ma)*mr+cosf(la)*local,0.46f*sqrtf(fmaxf(0.0f,1.0f-local*local/0.36f)),sinf(ma)*mr+sinf(la)*local);
  }
  float turn=rnd(ss+3u)*6.283185f;float h=0.12f+0.10f*rnd(ss+4u);
  if(species==42)h=0.38f+0.32f*rnd(ss+4u);
  if(species==43)h=0.22f+0.16f*rnd(ss+4u);
  if(species==47)h=0.22f+0.14f*rnd(ss+4u);
  if(species==48)h=0.40f+0.30f*rnd(ss+4u);
  if(species==49)h=0.22f+0.20f*rnd(ss+4u);
  if(species==50)h=0.07f+0.08f*rnd(ss+4u);
  float t=rnd(s+81u);float u=rnd(s+82u);float v=rnd(s+83u);float angle=turn+floorf(rnd(s+84u)*9.0f)*0.698132f;
  float reach=0.055f;float leafWidth=0.015f;float rise=0.055f;
  if(species==41){reach=0.028f;rise=0.08f;leafWidth=0.009f;}
  if(species==42){reach=0.09f;rise=0.04f;leafWidth=0.009f;}
  if(species==43){reach=0.065f;rise=0.11f;leafWidth=0.008f;angle=turn*0.2f+0.45f;}
  if(species==47){reach=0.095f;rise=-0.035f;leafWidth=0.012f;}
  if(species==50){reach=0.025f;rise=0.04f;leafWidth=0.016f;}
  float lateral=(v-0.5f)*2.0f*leafWidth*sinf(u*3.14159f);
  float3 anchor=make_float3(base.x,base.y+h*t,base.z);
  if(species==44||species==45||species==46){
   // Creeping main axis, paired lateral branches and fine secondary leaves.
   float length=0.30f;if(species==45)length=0.46f;if(species==46)length=0.40f;
   float row=floorf(t*10.0f)/10.0f;float side=1.0f;if(rnd(s+85u)<0.5f)side=-1.0f;
   float branch=(1.0f-row)*length*0.50f*rnd(s+86u);
   float forward=length*row;float elevation=0.06f+forward*0.12f;
   if(species==46){float tier=floorf(rnd(ss+7u)*3.0f);elevation+=tier*0.13f;forward+=tier*0.07f;}
   anchor=make_float3(base.x+cosf(turn)*forward-sinf(turn)*branch*side,base.y+elevation,base.z+sinf(turn)*forward+cosf(turn)*branch*side);
   angle=turn+side*1.0f;reach=0.04f;rise=0.012f;leafWidth=0.009f;
   lateral=(v-0.5f)*2.0f*leafWidth*sinf(u*3.14159f);
  }
  if(species==48){ // Branched, miniature tree-like crowns above exposed stalks.
   float branch=floorf(rnd(s+85u)*8.0f);angle=turn+branch*0.785398f;
   float bt=rnd(s+86u);float radial=bt*0.17f;
   anchor=make_float3(base.x+cosf(angle)*radial,base.y+h-0.12f*bt*bt,base.z+sinf(angle)*radial);
   angle+=1.0f;reach=0.035f;rise=0.012f;
  }
  if(species==49){ // Compact capitula above clustered spreading branches.
   float arm=floorf(rnd(s+85u)*5.0f);angle=turn+arm*1.256637f;
   float bt=rnd(s+86u);anchor=make_float3(base.x+cosf(angle)*bt*0.12f,base.y+h-0.05f*bt,base.z+sinf(angle)*bt*0.12f);
   reach=0.025f;rise=0.02f;leafWidth=0.015f;
  }
  p=make_float3(anchor.x+cosf(angle)*reach*u-sinf(angle)*lateral,anchor.y+rise*u,anchor.z+sinf(angle)*reach*u+cosf(angle)*lateral);
  // Some samples fill the shoot axis instead of leaf surfaces.
  if(rnd(s+87u)<0.10f){p=make_float3(base.x,base.y+h*t,base.z);}
  na=angle-floorf(angle/6.283185f)*6.283185f;ne=0.8f;
  axis=make_float3(cosf(angle)*0.6f,0.8f,sinf(angle)*0.6f);len=0.017f;width=0.7f;bloom=0.0f;
 }


 if(species>=51&&species<=60){
  p=vineLeaf(c,seed,species);float u=rnd(s+101u);float theta=rnd(s+102u)*6.283185f;
  float radius=sqrtf(u);float leafSize=0.17f;float lobes=0.76f+0.24f*cosf(theta*5.0f);
  if(species==52)leafSize=0.24f;
  if(species==53){leafSize=0.22f;lobes=0.76f+0.24f*cosf(theta*3.0f);}
  if(species==55){leafSize=0.24f;lobes=0.82f+0.18f*cosf(theta*5.0f);}
  if(species==54||species==56||species==58){
   float leaflet=floorf(rnd(s+103u)*5.0f);float la=leaflet*0.65f-1.3f;
   if(species==54){p.x+=sinf(la)*0.20f;p.y+=cosf(la)*0.20f;leafSize=0.105f;}
   if(species==56){float pair=floorf(rnd(s+103u)*5.0f);float side=1.0f;if(rnd(s+104u)<0.5f)side=-1.0f;p.x+=side*0.085f;p.y-=pair*0.09f;leafSize=0.085f;}
   if(species==58){la=floorf(rnd(s+103u)*3.0f)*1.1f-1.1f;p.x+=sinf(la)*0.16f;p.y+=cosf(la)*0.16f;leafSize=0.12f;}
   lobes=1.0f;
  }
  if(species==57){float side=1.0f;if(rnd(s+103u)<0.5f)side=-1.0f;p.x+=side*0.08f;leafSize=0.14f;lobes=1.0f;}
  if(species==59){leafSize=0.20f;lobes=0.8f-0.2f*sinf(theta);}
  if(species==60){leafSize=0.095f;lobes=1.0f;}
  float x=cosf(theta)*radius*leafSize*lobes;float y=sinf(theta)*radius*leafSize*lobes;
  if(species==59){x=leafSize*radius*sinf(theta)*sinf(theta)*sinf(theta);y=leafSize*radius*(13.0f*cosf(theta)-5.0f*cosf(theta*2.0f)-2.0f*cosf(theta*3.0f)-cosf(theta*4.0f))/16.0f;}
  if(species==54||species==56||species==58){x*=0.55f;y*=1.15f;}
  if(species==57||species==60){x*=0.72f;y*=1.08f;}
  float3 leafRoot=vineLeaf(c,seed,species);float localX=p.x-leafRoot.x+x;float localY=p.y-leafRoot.y+y;
  float outward=0.035f*(1.0f-radius*radius);float angle=4.712389f;
  if(vineTrellis(species)==0)angle=atan2f(leafRoot.z,leafRoot.x);
  p=make_float3(leafRoot.x-sinf(angle)*localX+cosf(angle)*outward,leafRoot.y+localY,leafRoot.z+cosf(angle)*localX+sinf(angle)*outward);
  na=angle;if(na<0.0f)na+=6.283185f;ne=0.2f+0.25f*rnd(c+seed);axis=make_float3(1.0f,0.2f,0.0f);len=0.012f;width=1.0f;bloom=0.0f;
 }


 if(species>=61&&species<=70){
  p=grassSite(c,seed,species);float direction=rnd(s+131u)*6.283185f;
  float spread=0.11f;float length=0.40f;float variation=0.22f;float lean=0.35f;width=0.007f;
  if(species==61){spread=0.15f;length=0.42f;variation=0.23f;lean=1.0f;width=0.004f;}
  if(species==62){length=0.22f;variation=0.30f;lean=0.7f;width=0.0035f;}
  if(species==63){length=0.18f;variation=0.15f;lean=0.35f;width=0.008f;}
  if(species==64){length=0.32f;variation=0.20f;lean=0.25f;width=0.009f;}
  if(species==65){length=0.08f;variation=0.10f;lean=0.8f;width=0.0045f;}
  if(species==66){length=0.12f;variation=0.10f;lean=0.12f;width=0.007f;}
  if(species==67){spread=0.18f;length=1.10f;variation=0.80f;lean=0.65f;width=0.015f;}
  if(species==68){spread=0.15f;length=0.95f;variation=0.70f;lean=0.22f;width=0.009f;}
  if(species==69){spread=0.17f;length=0.55f;variation=0.65f;lean=1.25f;width=0.009f;}
  if(species==70){spread=0.16f;length=0.55f;variation=0.50f;lean=1.45f;width=0.0025f;}
  float rr=spread*sqrtf(rnd(s+132u));p.x+=cosf(direction)*rr;p.z+=sinf(direction)*rr;
  if(species>=62&&species<=66){p.x+=(rnd(s+133u)-0.5f)*0.22f;p.z+=(rnd(s+134u)-0.5f)*0.36f;}
  len=length+variation*rnd(s+135u);float bend=lean*(0.35f+0.65f*rnd(s+136u));
  axis=make_float3(cosf(direction)*bend,1.0f,sinf(direction)*bend);na=direction;ne=0.0f;bloom=0.0f;
  if(species>=67&&rnd(s+137u)<0.0015f){bloom=1.0f;len=length+variation+0.60f;width=0.005f;axis.x*=0.4f;axis.z*=0.4f;}
 }


 if(species>=71&&species<=80){
  unsigned int plant=c%32u;float h=cropHeight(plant,seed,species);float3 root=cropRoot(plant,seed);
  float u=rnd(s+151u);float v=rnd(s+152u);float angle=rnd(s+153u)*6.283185f;float choose=rnd(s+154u);
  float leaf=floorf(rnd(s+155u)*6.0f);float la=leaf*2.399963f+rnd(plant+seed+156u)*6.283185f;
  float attach=0.12f+leaf*0.12f;float reach=0.32f;float bladeWidth=0.026f;
  if(species==75||species==78){reach=0.68f;bladeWidth=0.075f;}
  if(species==76||species==77){reach=0.47f;bladeWidth=0.05f;}
  if(species==74){reach=0.40f;bladeWidth=0.020f;attach*=0.65f;}
  if(species==79||species==80){reach=0.30f;bladeWidth=0.11f;}
  float3 anchor=cropStem(plant,seed,species,attach);float side=(v-0.5f)*2.0f*bladeWidth*sinf(u*3.14159f);
  p=make_float3(anchor.x+cosf(la)*reach*u-sinf(la)*side,anchor.y+0.20f*sinf(u*3.14159f)-0.12f*u*u,anchor.z+sinf(la)*reach*u+cosf(la)*side);
  if(species==79){float leaflet=floorf(rnd(s+157u)*3.0f);la+=leaflet*0.9f-0.9f;p=make_float3(anchor.x+cosf(la)*(0.12f+0.18f*u)-sinf(la)*side,anchor.y+0.07f,anchor.z+sinf(la)*(0.12f+0.18f*u)+cosf(la)*side);}
  if(choose>0.64f&&species!=78){
   bloom=1.0f;float3 tip=cropStem(plant,seed,species,1.0f);
   if(species==71||species==72){float grain=floorf(u*12.0f);float level=grain/12.0f;float face=1.0f;if(v<0.5f)face=-1.0f;
    p=make_float3(tip.x+face*(0.018f+0.025f*sinf(angle)),tip.y+level*0.27f+0.016f*cosf(angle),tip.z+0.023f*cosf(angle));
    if(species==72&&rnd(s+158u)<0.35f){float awn=rnd(s+159u);p.x+=face*awn*0.10f;p.y+=awn*0.23f;}
   }
   if(species==73||species==74){float branch=floorf(u*9.0f);float ba=branch*2.399963f;float t=rnd(s+158u);float extent=0.08f+0.14f*branch/9.0f;
    p=make_float3(tip.x+cosf(ba)*extent*t,tip.y+0.22f-branch*0.022f-0.10f*t*t,tip.z+sinf(ba)*extent*t);
    if(species==74){p.x+=0.15f*u;p.y-=0.20f*u*u;}
   }
   if(species==75){if(v<0.6f){float a2=angle;float y=u*0.25f;p=make_float3(root.x+0.11f+0.055f*cosf(a2)*sinf(u*3.14159f),h*0.56f+y,root.z+0.055f*sinf(a2));}else{float bt=rnd(s+158u);p=make_float3(tip.x+cosf(angle)*bt*0.19f,tip.y+0.25f*u,tip.z+sinf(angle)*bt*0.19f);}}
   if(species==76||species==77){float radius=0.11f;if(species==77)radius=0.055f;radius*=sinf(u*3.14159f);p=make_float3(tip.x+cosf(angle)*radius,tip.y+u*0.30f,tip.z+sinf(angle)*radius);}
   if(species==79){p=make_float3(anchor.x+cosf(la)*0.11f,anchor.y-0.13f*u,anchor.z+sinf(la)*0.11f+0.025f*cosf(angle));}
   if(species==80){float ball=0.09f;float e2=(v-0.5f)*3.14159f;p=make_float3(anchor.x+cosf(la)*0.25f+cosf(angle)*cosf(e2)*ball,anchor.y+sinf(e2)*ball,anchor.z+sinf(la)*0.25f+sinf(angle)*cosf(e2)*ball);}
  }
  if(choose<0.08f){p=cropStem(plant,seed,species,u);bloom=0.0f;}
  len=0.014f;width=0.85f;axis=make_float3(cosf(la),0.35f,sinf(la));na=la-floorf(la/6.283185f)*6.283185f;ne=0.8f;
 }

 if(species>=81&&species<=90){
  unsigned int body=c%16u;float4 m=mushroomBody(body,seed,species);float a=rnd(s+201u)*6.283185f;float t=sqrtf(rnd(s+202u));float part=rnd(s+203u);
  float rad=m.w*t;float dome=0.18f*(1.0f-t*t);float stemRadius=0.025f;
  if(species==82){dome=0.24f*sqrtf(fmaxf(0.0f,1.0f-t*t));stemRadius=0.075f;}
  if(species==83){dome=0.20f*t*t;rad*=1.0f+0.08f*sinf(a*7.0f);}
  if(species==84)dome=0.05f*(1.0f-t*t);
  if(species==85)dome=0.45f*sqrtf(fmaxf(0.0f,1.0f-t*t));
  if(species==86||species==90)dome=0.11f*(1.0f-t*t);
  p=make_float3(m.x+cosf(a)*rad,m.y+dome,m.z+sinf(a)*rad);bloom=1.0f;na=a;ne=fminf(1.34f,1.34f-t*0.8f);
  if(part<0.22f){float h=rnd(s+204u);float rr=stemRadius*(1.0f+0.3f*(1.0f-h));p=make_float3(m.x+cosf(a)*rr,m.y*h,m.z+sinf(a)*rr);bloom=0.0f;ne=0.0f;}
  else if(part<0.34f){p.y=m.y-0.018f-0.008f*(0.5f+0.5f*cosf(a*50.0f));bloom=0.0f;ne=-1.2f;}
  if(species==87||species==88){a=(rnd(s+201u)-0.5f)*3.14159f;rad=m.w*t;p=make_float3(m.x+sinf(a)*rad,m.y+0.035f*sinf(t*3.14159f),m.z-cosf(a)*rad);bloom=1.0f;ne=1.3f;na=a+1.570796f;if(part<0.2f){p.y-=0.04f;bloom=0.0f;ne=-1.2f;}}
  if(species==89){float elev=(rnd(s+202u)-0.5f)*3.14159f;p=make_float3(m.x+cosf(a)*cosf(elev)*m.w,m.w+sinf(elev)*m.w,m.z+sinf(a)*cosf(elev)*m.w);bloom=1.0f;ne=fmaxf(-1.34f,fminf(1.34f,elev));}
  len=0.017f;width=1.0f;axis=make_float3(-sinf(a),0.0f,cosf(a));
 }

 if(species>=91&&species<=100){
 unsigned int body=c%16u;float4 m=mineralBody(body,seed,species);float u=rnd(s+301u);float v=rnd(s+302u);float pick=rnd(s+303u);float turn=rnd(body+seed+604u)*6.283185f;
 float x=0.0f;float y=0.0f;float z=0.0f;na=0.0f;ne=0.0f;
 if(species==91||species==95){
  float a=u*6.283185f;float elev=(v-0.5f)*3.14159f;float rough=1.0f+0.10f*sinf(a*5.0f+body)*cosf(elev*6.0f);
  x=cosf(a)*cosf(elev)*m.w*rough;z=sinf(a)*cosf(elev)*m.w*rough;y=(sinf(elev)+1.0f)*m.y*0.5f;na=a;ne=fmaxf(-1.34f,fminf(1.34f,elev));
 }else if(species==93||species==94||species==99||species==100){
  float thickness=m.y;float face=floorf(pick*5.0f);x=(u-0.5f)*m.w*2.0f;z=(v-0.5f)*m.w*2.0f;y=thickness;
  ne=1.34f;if(face<4.0f){y=v*thickness;ne=0.0f;na=face*1.570796f;if(face==0.0f){x=m.w;z=(u-0.5f)*m.w*2.0f;}if(face==1.0f){z=m.w;x=(u-0.5f)*m.w*2.0f;}if(face==2.0f){x=-m.w;z=(u-0.5f)*m.w*2.0f;}if(face==3.0f){z=-m.w;x=(u-0.5f)*m.w*2.0f;}}
  if(species==94)y+=(float)body*0.105f;if(species==93){y+=(float)(body/4u)*0.35f;turn*=0.08f;}
 }else{
  if(species==92)turn=0.0f;float face=floorf(u*6.0f);float a=face*1.047198f;float next=a+1.047198f;float edge=u*6.0f-face;
  x=(cosf(a)*(1.0f-edge)+cosf(next)*edge)*m.w;z=(sinf(a)*(1.0f-edge)+sinf(next)*edge)*m.w;y=v*m.y;na=a+0.523599f;ne=0.0f;
  if(pick>0.72f){float t=sqrtf(v);x*=t;z*=t;y=m.y;if(species!=92)y+=m.w*1.6f*(1.0f-t);ne=species==92?1.34f:0.56f;}
 }
 float xx=x*cosf(turn)-z*sinf(turn);float zz=x*sinf(turn)+z*cosf(turn);na+=turn;na-=floorf(na/6.283185f)*6.283185f;
 p=make_float3(m.x+xx,y,m.z+zz);len=0.035f;width=1.0f;axis=make_float3(-sinf(na),0.0f,cosf(na));bloom=1.0f;
 }

 // Fixed 128 debris objects, sampled with stable seed/group offsets.
 if(species>=101&&species<=110){
  int kind=species-101;if(species==110)kind=(int)(c%9u);
  float a=rnd(c+seed+703u)*6.283185f;float u=rnd(s+401u)*2.0f-1.0f;float v=rnd(s+402u)*2.0f-1.0f;float t=rnd(s+403u)*6.283185f;
  float size=0.75f+0.55f*rnd(c+seed+704u);float x=u*0.18f*size;float z=v*0.10f*size;float y=0.02f;
  if(kind<=2){float edge=sqrtf(fmaxf(0.0f,1.0f-u*u));if(kind==0)edge*=0.75f+0.25f*cosf(u*13.0f);if(kind==1)edge*=0.55f+0.45f*fabsf(cosf(u*6.0f));if(kind==2){edge=1.0f-fabsf(u);x*=0.7f;}z*=edge;y+=0.07f*u*u+0.035f*v*v;}
  if(kind==3){x=u*0.22f*size;z=v*0.006f;y+=0.015f*u*u;}
  if(kind==4){x=u*0.28f*size;z=cosf(t)*0.018f;y=0.024f+sinf(t)*0.018f;}
  if(kind==5){x=u*0.16f*size;z=v*0.065f*size;y+=0.025f*v*v+0.014f*(0.5f+0.5f*sinf(u*20.0f));}
  if(kind==6){float ring=sqrtf(fmaxf(0.0f,1.0f-u*u));float scales=1.0f+0.13f*cosf(u*24.0f+t*7.0f);x=u*0.14f*size;z=cosf(t)*0.07f*ring*scales;y=0.085f+sinf(t)*0.07f*ring*scales;}
  if(kind==7){float ring=sqrtf(fmaxf(0.0f,1.0f-u*u));x=u*0.08f;z=cosf(t)*0.048f*ring;y=0.055f+sinf(t)*0.048f*ring;}
  if(kind==8){float ring=sqrtf(fmaxf(0.0f,1.0f-u*u));x=u*0.105f*size;z=cosf(t)*0.075f*ring;y=0.055f+sinf(t)*0.050f*ring;}
  float3 root=center(c,seed,species);p=make_float3(root.x+x*cosf(a)-z*sinf(a),y,root.z+x*sinf(a)+z*cosf(a));
  na=a;ne=1.15f;if(kind>=4&&kind!=5){na=a+t;na-=floorf(na/6.283185f)*6.283185f;ne=fmaxf(-1.3f,fminf(1.3f,sinf(t)*1.3f));}
  axis=make_float3(cosf(a),0.0f,sinf(a));len=0.012f;width=1.0f;bloom=1.0f;
 }

 if(species>=111){
  float u=rnd(s+501u);float v=rnd(s+502u);float theta=rnd(s+503u)*6.283185f;float choose=rnd(s+504u);unsigned int part=c%8u;
  float3 a=make_float3(-1.4f,0.38f,0.0f);float3 b=make_float3(1.4f,0.38f,0.0f);float radius=0.35f;float taper=0.85f;
  if(species==113||species==114||species==115||species==120){a=make_float3(0.0f,0.0f,0.0f);b=make_float3(0.08f,0.95f,0.04f);radius=0.48f;taper=0.75f;if(species==120){b=make_float3(0.25f,2.45f,0.05f);radius=0.30f;taper=0.40f;}}
  if(species==115&&part<6u){float ra=(float)part*1.047198f;a=make_float3(cosf(ra)*0.18f,0.26f,sinf(ra)*0.18f);b=make_float3(cosf(ra)*1.40f,0.07f,sinf(ra)*1.40f);radius=0.16f;taper=0.2f;}
  if(species==116){radius=0.18f;a=make_float3(-1.4f,0.20f,0.0f);b=make_float3(1.4f,0.25f,0.15f);if(part<6u){float at=(float)part/6.0f;a=make_float3(-1.2f+at*2.4f,0.22f,at*0.15f);float side=part%2u==0u?1.0f:-1.0f;b=make_float3(a.x+0.45f,0.28f+0.3f*rnd(part+seed),side*0.75f);radius=0.075f;taper=0.22f;}}
  if(species==119){unsigned int log=c%5u;float row=(float)(log%3u);a=make_float3(-1.15f+(rnd(log+seed)-0.5f)*0.3f,0.23f+(float)(log/3u)*0.40f,(row-1.0f)*0.44f);b=make_float3(1.15f,a.y,a.z+0.08f);radius=0.22f;taper=0.9f;}
  if(species==120&&part<3u){float ra=(float)part*2.094395f;a=make_float3(0.10f,1.1f+(float)part*0.35f,0.0f);b=make_float3(cosf(ra)*0.72f,a.y+0.25f,sinf(ra)*0.72f);radius=0.09f;taper=0.3f;}
  float variation=0.94f+0.12f*rnd(seed+611u);a.x*=variation;b.x*=variation;
  float dx=b.x-a.x;float dy=b.y-a.y;float dz=b.z-a.z;float length=sqrtf(dx*dx+dy*dy+dz*dz);dx/=length;dy/=length;dz/=length;
  float sx=-dz;float sz=dx;float sl=sqrtf(sx*sx+sz*sz);if(sl<0.1f){sx=1.0f;sz=0.0f;}else{sx/=sl;sz/=sl;}
  float tx=dy*sz;float ty=dz*sx-dx*sz;float tz=-dy*sx;
  if(species==118)theta=rnd(s+503u)*3.14159f;
  float rr=radius*(1.0f-u*(1.0f-taper));float along=u;float material=0.0f;float nx=sx*cosf(theta)+tx*sinf(theta);float ny=ty*sinf(theta);float nz=sz*cosf(theta)+tz*sinf(theta);
  if(species==112&&choose<0.3f){rr*=0.68f;material=2.0f;nx=-nx;ny=-ny;nz=-nz;}
  if(choose>0.78f){along=choose>0.89f?1.0f:0.0f;rr=radius*(1.0f-along*(1.0f-taper))*sqrtf(v);if(species==112)rr=radius*(1.0f-along*(1.0f-taper))*sqrtf(0.4624f+0.5376f*v);material=1.0f;float sign=along>0.5f?1.0f:-1.0f;nx=dx*sign;ny=dy*sign;nz=dz*sign;}
  float jag=0.0f;if((species==114||species==120)&&along>0.75f)jag=0.18f*(0.5f+0.5f*cosf(theta*9.0f))*(along-0.75f)*4.0f;
  p=make_float3(a.x+(b.x-a.x)*along+rr*(sx*cosf(theta)+tx*sinf(theta)),a.y+(b.y-a.y)*along+rr*ty*sinf(theta)+jag,a.z+(b.z-a.z)*along+rr*(sz*cosf(theta)+tz*sinf(theta)));
  if(species==118&&choose<0.22f){p=make_float3(a.x+(b.x-a.x)*u,a.y,a.z+(v*2.0f-1.0f)*radius);material=1.0f;nx=0.0f;ny=1.0f;nz=0.0f;}
  p.y=fmaxf(0.006f,p.y);na=atan2f(nz,nx);if(na<0.0f)na+=6.283185f;ne=fmaxf(-1.34f,fminf(1.34f,atan2f(ny,sqrtf(nx*nx+nz*nz))));
  axis=make_float3(sx,0.0f,sz);len=0.023f;width=1.0f;bloom=material;
 }

 pos[i]=make_float4(p.x,p.y,p.z,len);

 shape[i]=make_float4(axis.x,axis.y,axis.z,width);

 normal[i]=make_float4(na,ne,rnd(s+7u)+bloom,(float)c);

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

 if(species==10||(species>=61&&species<=70)){

 // Curved, root-anchored blades use the same depth keys and lighting records.

 float3 prev=project(p,yaw,tilt,scale,w,h,focus);

 for(int segment=1;segment<=6;segment++){

 float t=(float)segment/6.0f;float bend=t*t;

 float3 tip=make_float3(p.x+sh.x*v.w*bend+sinf(time*1.7f+p.x+p.z)*wind*bend,p.y+v.w*t,p.z+sh.z*v.w*bend+cosf(time+p.z)*wind*bend*0.4f);
 if(species>=67&&nm.z<1.0f){float droop=0.38f;if(species==68)droop=0.12f;tip.y-=v.w*droop*t*t*t;}

 float3 q2=project(tip,yaw,tilt,scale,w,h,focus);float vx=q2.x-prev.x;float vy=q2.y-prev.y;

 int steps=(int)ceilf(sqrtf(vx*vx+vy*vy))+1;

 for(int step=0;step<=steps;step++){float f=(float)step/(float)steps;int px=(int)(prev.x+vx*f);int py=(int)(prev.y+vy*f);float rad=fmaxf(0.45f,sh.w*scale*(1.0f-t*0.85f));if(species>=67&&nm.z>=1.0f){float tt=((float)(segment-1)+f)/6.0f;float head=fmaxf(0.0f,(tt-0.72f)/0.28f);float fullness=sinf(head*3.14159f);float hw=0.045f;if(species==67)hw=0.075f;if(species==68)hw=0.11f;if(species==70)hw=0.022f;rad=fmaxf(rad,hw*scale*fullness);}
 int radI=(int)ceilf(rad);

 for(int ox=-radI;ox<=radI;ox++){int xx=px+ox;if(xx>=0&&xx<w&&py>=0&&py<h&&fabsf((float)ox)<=rad)atomicMin(&depth[py*w+xx],key(prev.z+(q2.z-prev.z)*f,i));}}

 prev=q2;

 }return;}

 if(species>=51&&species<=60){float flutter=sinf(time*1.7f+nm.w)*wind*0.025f;p.x+=cosf(nm.x)*flutter;p.z+=sinf(nm.x)*flutter;}
 else if(species>=21)p=plantWind(p,time,wind,species);
 else{p.x+=sinf(time*1.5f+p.y*0.9f+p.z)*wind*(p.y/7.0f);p.z+=cosf(time+p.x)*wind*0.35f;}

 float3 q=project(p,yaw,tilt,scale,w,h,focus);

 float3 nn=normdir(nm.x,nm.y);float facing=fabsf(nn.x*sinf(yaw)*cosf(tilt)+nn.y*sinf(tilt)+nn.z*cosf(yaw)*cosf(tilt));

 float3 end=project(make_float3(p.x+sh.x*v.w,p.y+sh.y*v.w,p.z+sh.z*v.w),yaw,tilt,scale,w,h,focus);

 float ax=end.x-q.x;float ay=end.y-q.y;float ra=fmaxf(0.7f,sqrtf(ax*ax+ay*ay));float rb=fmaxf(0.4f,v.w*scale*sh.w*(0.3f+0.7f*facing));

 float angle=atan2f(ay,ax);if(species<81)angle+=0.15f*sinf(time+nm.z*9.0f)*wind;

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

 if(species>=11&&species<=20&&nm.z>=1.0f){float petal=0.75f+0.25f*cosf(atan2f(v2,u)*5.0f);mask=(u*u+v2*v2)/(petal*petal);}

 if(mask<1.0f)atomicMin(&depth[y*w+x],k);

 }}

}



__device__ float3 trunkPoint(float y,int species){

 float bend=0.09f;if(species==8)bend=0.22f;if(species==2)bend=0.055f;

 return make_float3(bend*sinf(y*0.85f)*y/5.0f,y,bend*0.6f*(cosf(y*0.7f)-1.0f));

}

__device__ float3 hub(unsigned int limb,unsigned int seed,int species){

 float a=(float)limb*0.785398f;float radius=1.6f;float y=4.4f+rnd(limb+seed+91u)*0.65f;

 if(species==1){radius=1.2f;y+=0.35f;}

 if(species==2){radius=0.8f;y+=0.4f;}

 if(species==5){radius=1.8f;y=5.8f+rnd(limb+seed)*0.2f;}

 if(species==8){radius=1.2f;y=5.0f+rnd(limb+seed)*0.65f;}

 return make_float3(cosf(a)*radius,y,sinf(a)*radius);

}

__device__ float3 bez(float3 a,float3 m,float3 b,float t){float u=1.0f-t;return make_float3(a.x*u*u+2.0f*m.x*u*t+b.x*t*t,a.y*u*u+2.0f*m.y*u*t+b.y*t*t,a.z*u*u+2.0f*m.z*u*t+b.z*t*t);}

__global__ void wood(float4* woodA,float4* woodB,unsigned int seed,int species){

 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=512u)return;

 woodA[i]=make_float4(0.0f,0.0f,0.0f,0.0f);woodB[i]=make_float4(0.0f,0.0f,0.0f,0.0f);

 if(species>=91)return;
 if(species>=81&&species<=90){
  if((species==87||species==88||species==86)&&i==0u){float radius=0.22f;if(species==87||species==88)radius=0.32f;woodA[i]=make_float4(-1.35f,radius,0.0f,radius);woodB[i]=make_float4(1.35f,radius,0.0f,radius);}return;
 }
 if(species>=71&&species<=80){
  if(i>=256u)return;unsigned int plant=i/8u;float t=(float)(i%8u)/8.0f;float3 a=cropStem(plant,seed,species,t);float3 b=cropStem(plant,seed,species,t+0.125f);
  float radius=0.007f;if(species==75||species==78)radius=0.025f;
  woodA[i]=make_float4(a.x,a.y,a.z,radius);woodB[i]=make_float4(b.x,b.y,b.z,radius*0.95f);return;
 }

 if(species==10||(species>=61&&species<=70)||(species>=41&&species<=50))return;
 if(species>=51&&species<=60){
  float3 a;float3 b;float radius=0.012f;
  if(i<320u){unsigned int path=i/20u;float t=(float)(i%20u)/20.0f;a=vinePath(path,seed,species,t);b=vinePath(path,seed,species,t+0.05f);radius*=1.0f-0.7f*t;}
  else if(i<448u){unsigned int c=i-320u;a=vinePoint(c%16u,seed,species,vineNode(c,seed));b=vineLeaf(c,seed,species);radius=0.004f;}
  else if(i<456u){
   unsigned int j=i-448u;
   if(vineTrellis(species)==0){if(j>0u)return;a=make_float3(0.0f,0.0f,0.0f);b=make_float3(0.0f,3.2f,0.0f);radius=0.38f;}
   else{if(j<3u){float x=((float)j-1.0f)*0.8f;a=make_float3(x,0.0f,0.0f);b=make_float3(x,3.2f,0.0f);radius=0.035f;}else{float y=0.4f+(float)(j-3u)*0.65f;a=make_float3(-1.2f,y,0.0f);b=make_float3(1.2f,y,0.0f);radius=0.025f;}}
  }else{ // Contact connectors illustrate rootlet/pad/tendril attachment.
   unsigned int c=i-456u;a=vinePoint(c%16u,seed,species,vineNode(c,seed));b=a;
   if(vineTrellis(species)==0){float angle=atan2f(a.z,a.x);b=make_float3(cosf(angle)*0.38f,a.y-0.015f,sinf(angle)*0.38f);}
   else{float post=floorf(a.x/0.8f+0.5f)*0.8f;b=make_float3(post,a.y,0.0f);}
   radius=0.0025f;
  }
  woodA[i]=make_float4(a.x,a.y,a.z,radius);woodB[i]=make_float4(b.x,b.y,b.z,radius);return;
 }
 if(species>=31&&species<=40){
  unsigned int frond=i/16u;float t0=(float)(i%16u)/16.0f;float t1=t0+0.0625f;
  float3 a;float3 b;float radius=0.009f;
  if(i<256u){a=fernPoint(frond,seed,species,t0);b=fernPoint(frond,seed,species,t1);radius*=1.0f-0.75f*t0;}
  else{
   if(species!=34&&species!=35&&species!=39)return;
   frond=(i-256u)/16u;unsigned int row=((i-256u)%16u)/2u;float side=1.0f;if(i%2u==0u)side=-1.0f;
   float t=0.19f+0.78f*((float)row+0.5f)/8.0f;float fa=fernAngle(frond,seed);float w=fernWidth(t,species);
   a=fernPoint(frond,seed,species,t);float3 q=fernPoint(frond,seed,species,t+0.005f);float dx=q.x-a.x;float dy=q.y-a.y;float dz=q.z-a.z;float d=sqrtf(dx*dx+dy*dy+dz*dz);
   b=make_float3(a.x-sinf(fa)*side*w+dx/d*0.12f,a.y+dy/d*0.12f,a.z+cosf(fa)*side*w+dz/d*0.12f);radius=0.003f;
  }
  woodA[i]=make_float4(a.x,a.y,a.z,radius);woodB[i]=make_float4(b.x,b.y,b.z,radius*0.7f);return;
 }

 if(species>=21){
  if(species==29&&i>=128u&&i<224u){
   unsigned int plant=(i-128u)/6u;float bell=(float)((i-128u)%6u);float3 head=flowerHead(plant,seed,species);float turn=rnd(plant+seed+811u)*0.8f-0.4f;float reach=0.10f+bell*0.024f;
   woodA[i]=make_float4(head.x,head.y-bell*0.14f+0.04f,head.z,0.005f);
   woodB[i]=make_float4(head.x+cosf(turn)*reach,head.y-bell*0.14f,head.z+sinf(turn)*reach,0.004f);return;
  }
  if(i>=128u)return;unsigned int plant=i/8u;float t0=(float)(i%8u)/8.0f;float t1=t0+0.125f;
  float3 head=flowerHead(plant,seed,species);
  woodA[i]=make_float4(head.x,head.y*t0,head.z,0.012f*(1.0f-0.4f*t0));
  woodB[i]=make_float4(head.x,head.y*t1,head.z,0.012f*(1.0f-0.4f*t1));return;
 }


 if(species>=11&&species<=20){

 if(i>=288u)return;float3 a;float3 b;float ra=0.018f;float rb=0.006f;

 if(i<32u){unsigned int limb=i/2u;float3 tip=center(limb+64u,seed,species);float3 root=make_float3(tip.x*0.12f,0.0f,tip.z*0.12f);float3 mid=make_float3(tip.x*0.5f,tip.y*0.8f,tip.z*0.5f);float t0=(float)(i%2u)*0.5f;a=bez(root,mid,tip,t0);b=bez(root,mid,tip,t0+0.5f);ra=0.035f*(1.0f-t0*0.6f);rb=ra*0.65f;

 }else{unsigned int c=(i-32u)/2u;float3 tip=center(c%16u+64u,seed,species);float3 root=make_float3(tip.x*0.12f,0.0f,tip.z*0.12f);float3 mid=make_float3(tip.x*0.5f,tip.y*0.8f,tip.z*0.5f);float3 join=bez(root,mid,tip,0.5f);float3 target=center(c,seed,species);float3 control=make_float3((join.x+target.x)*0.5f,fmaxf(join.y,target.y)+0.1f,(join.z+target.z)*0.5f);float t0=(float)((i-32u)%2u)*0.5f;a=bez(join,control,target,t0);b=bez(join,control,target,t0+0.5f);ra=0.014f*(1.0f-t0*0.7f);rb=ra*0.5f;}

 woodA[i]=make_float4(a.x,a.y,a.z,ra);woodB[i]=make_float4(b.x,b.y,b.z,rb);return;

 }



 if(species==0||species==1||species==2||species==5||species==8){

 if(i>=288u)return;float3 a;float3 b;float ra=0.02f;float rb=0.009f;

 float height=5.7f;float root=0.24f;if(species==2){root=0.12f;height=6.3f;}if(species==5){root=0.25f;height=5.8f;}if(species==8){root=0.20f;height=6.0f;}

 if(i<8u){float t0=(float)i/8.0f;float t1=(float)(i+1u)/8.0f;a=trunkPoint(t0*height,species);b=trunkPoint(t1*height,species);ra=root*powf(1.0f-t0,0.75f)+0.012f;rb=root*powf(1.0f-t1,0.75f)+0.012f;}

 else if(i<32u){unsigned int limb=(i-8u)/3u;unsigned int piece=(i-8u)%3u;

 float attach=1.9f+rnd(limb+seed+51u)*1.8f;if(species==5)attach=4.1f+rnd(limb+seed)*0.8f;if(species==8)attach=2.6f+rnd(limb+seed)*1.6f;

 float3 aa=trunkPoint(attach,species);float3 bb=hub(limb,seed,species);float3 mid=make_float3(aa.x*0.65f+bb.x*0.35f,(aa.y+bb.y)*0.5f+0.3f,aa.z*0.65f+bb.z*0.35f);

 float t0=(float)piece/3.0f;float t1=(float)(piece+1u)/3.0f;a=bez(aa,mid,bb,t0);b=bez(aa,mid,bb,t1);float thick=root*0.42f;ra=thick*(1.0f-t0*0.65f);rb=thick*(1.0f-t1*0.65f);

 }else{unsigned int c=(i-32u)/2u;unsigned int piece=(i-32u)%2u;float3 target=center(c,seed,species);

 float angle=atan2f(target.z,target.x);if(angle<0.0f)angle+=6.283185f;unsigned int limb=((unsigned int)(angle/0.785398f+0.5f))%8u;

 float attach=1.9f+rnd(limb+seed+51u)*1.8f;if(species==5)attach=4.1f+rnd(limb+seed)*0.8f;if(species==8)attach=2.6f+rnd(limb+seed)*1.6f;

 float3 rootPoint=trunkPoint(attach,species);float3 hubPoint=hub(limb,seed,species);float3 control=make_float3(rootPoint.x*0.65f+hubPoint.x*0.35f,(rootPoint.y+hubPoint.y)*0.5f+0.3f,rootPoint.z*0.65f+hubPoint.z*0.35f);

 float at=0.3f+0.69f*rnd(c+seed+413u);float step=floorf(at*3.0f);float f=at*3.0f-step;float3 qa=bez(rootPoint,control,hubPoint,step/3.0f);float3 qb=bez(rootPoint,control,hubPoint,(step+1.0f)/3.0f);

 float3 aa=make_float3(qa.x+(qb.x-qa.x)*f,qa.y+(qb.y-qa.y)*f,qa.z+(qb.z-qa.z)*f);float3 mid=make_float3((aa.x+target.x)*0.5f,(aa.y+target.y)*0.5f+0.15f,(aa.z+target.z)*0.5f);

 float t0=(float)piece*0.5f;float t1=t0+0.5f;a=bez(aa,mid,target,t0);b=bez(aa,mid,target,t1);ra=0.025f*(1.0f-t0*0.7f);rb=0.025f*(1.0f-t1*0.7f);

 }

 woodA[i]=make_float4(a.x,a.y,a.z,ra);woodB[i]=make_float4(b.x,b.y,b.z,rb);return;

 }

 if(i>256u||(species!=3&&i>128u))return;

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



 woodA[i]=make_float4(a.x,a.y,a.z,radius);woodB[i]=make_float4(b.x,b.y,b.z,radius*0.35f);

}

// Each workgroup covers a segment bounding rectangle, each pixel exactly once.

__global__ void branches(unsigned int* depth,const float4* woodA,const float4* woodB,int w,int h,float yaw,float tilt,float scale,float focus,int species,float time,float wind){

 unsigned int i=blockIdx.x;if(i>=512u)return;float4 va=woodA[i];float4 vb=woodB[i];if(va.w<=0.0f)return;

 float3 ap=make_float3(va.x,va.y,va.z);float3 bp=make_float3(vb.x,vb.y,vb.z);
 if(species>=21){ap=plantWind(ap,time,wind,species);bp=plantWind(bp,time,wind,species);}
 float3 a=project(ap,yaw,tilt,scale,w,h,focus);float3 b=project(bp,yaw,tilt,scale,w,h,focus);

 float margin=fmaxf(va.w,vb.w)*scale+1.0f;

 int x0=(int)fmaxf(0.0f,floorf(fminf(a.x,b.x)-margin));int y0=(int)fmaxf(0.0f,floorf(fminf(a.y,b.y)-margin));

 int x1=(int)fminf((float)(w-1),ceilf(fmaxf(a.x,b.x)+margin));int y1=(int)fminf((float)(h-1),ceilf(fmaxf(a.y,b.y)+margin));int width=x1-x0+1;int height=y1-y0+1;if(width<=0||height<=0)return;

 float vx=b.x-a.x;float vy=b.y-a.y;float dd=fmaxf(0.00001f,vx*vx+vy*vy);

 for(int p=(int)threadIdx.x;p<width*height;p+=(int)blockDim.x){int x=x0+p%width;int y=y0+p/width;

 float t=fminf(1.0f,fmaxf(0.0f,(((float)x+0.5f-a.x)*vx+((float)y+0.5f-a.y)*vy)/dd));

 float dx=(float)x+0.5f-a.x-vx*t;float dy=(float)y+0.5f-a.y-vy*t;float rad=fmaxf(0.55f,(va.w+(vb.w-va.w)*t)*scale);float r2=rad*rad-dx*dx-dy*dy;

 if(r2>=0.0f)atomicMin(&depth[y*w+x],key(a.z+(b.z-a.z)*t-sqrtf(r2)/scale,250000u+i));

 }

}



__device__ float noise3(float x,float y,float z){

 int ix=(int)floorf(x);int iy=(int)floorf(y);int iz=(int)floorf(z);float fx=x-floorf(x);float fy=y-floorf(y);float fz=z-floorf(z);

 fx=fx*fx*(3.0f-2.0f*fx);fy=fy*fy*(3.0f-2.0f*fy);fz=fz*fz*(3.0f-2.0f*fz);float value=0.0f;

 for(int k=0;k<2;k++){for(int j=0;j<2;j++){for(int i=0;i<2;i++){

 float wx=1.0f-fx;if(i==1)wx=fx;float wy=1.0f-fy;if(j==1)wy=fy;float wz=1.0f-fz;if(k==1)wz=fz;

 value+=rnd((unsigned int)(ix+i)*73856093u^(unsigned int)(iy+j)*19349663u^(unsigned int)(iz+k)*83492791u)*wx*wy*wz;

 }}}return value;

}

__device__ float3 bark(float3 p,int species){

 // Irregular object-space grain, no screen-coordinate noise or regular bands.

 float broad=noise3(p.x*12.0f,p.y*1.6f,p.z*12.0f);

 float grain=noise3(p.x*110.0f,p.y*20.0f,p.z*110.0f);

 float ridges=noise3(p.x*55.0f+broad*2.0f,p.y*4.0f,p.z*55.0f+broad*2.0f);

 float value=0.55f+0.55f*ridges+0.12f*grain;

 float3 color=make_float3(0.38f*value,0.28f*value,0.19f*value);

 if(species==1)color=make_float3(0.38f*value,0.35f*value,0.30f*value);

 if(species==5){float plates=noise3(p.x*21.0f,p.y*7.0f,p.z*21.0f);float fissure=fmaxf(0.0f,1.0f-fabsf(plates-0.48f)*22.0f);value=0.80f+0.25f*plates+0.10f*grain-0.40f*fissure;color=make_float3(0.46f*value,0.30f*value,0.18f*value);}

 if(species==2){float marks=noise3(p.x*9.0f,p.y*50.0f,p.z*9.0f);float dash=fminf(1.0f,fmaxf(0.0f,(marks-0.62f)*8.0f));float v=0.83f-dash*0.58f+grain*0.045f;color=make_float3(v,v*0.96f,v*0.88f);}

 if(species==8){float patch=noise3(p.x*16.0f,p.y*2.6f,p.z*16.0f);color=make_float3(0.53f+0.24f*patch,0.53f+0.21f*patch,0.42f+0.19f*patch);}

 if(species==9){float band=0.75f+0.13f*sinf(p.y*34.0f+sinf(p.x*12.0f+p.z*12.0f));color=make_float3(0.42f*band,0.29f*band,0.16f*band);}

 if(species>=21)color=make_float3(0.15f*value,0.38f*value,0.065f*value);
 if(species==33)color=make_float3(0.085f,0.06f,0.045f);
 if(species==35)color=make_float3(0.31f,0.12f,0.16f);
 if(species>=81)color=make_float3(0.24f*value,0.15f*value,0.08f*value);
 if(species==36)color=make_float3(0.16f,0.13f,0.06f);
 return color;

}

__global__ void resolve(const unsigned int* depth,const float4* pos,const float4* normal,const float* light,const float4* woodA,const float4* woodB,unsigned int* pixels,int w,int h,int bins,int mode,float lx,float ly,float lz,float yaw,float tilt,float scale,int species,float autumn,float focus,float time,float wind){

 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;

 unsigned int k=depth[i];float y=(float)(i/(unsigned int)w)/(float)h;float x=(float)(i%(unsigned int)w)/(float)w;

 float r=0.055f+y*0.045f;float g=0.085f+y*0.065f;float b=0.095f+y*0.065f;

 float3 base=project(make_float3(0.0f,0.0f,0.0f),yaw,tilt,scale,w,h,focus);

 float sx=((float)(i%(unsigned int)w)-base.x)/(scale*3.3f);float sy=((float)(i/(unsigned int)w)-base.y)/(scale*0.44f);

 float shadow=expf(-sx*sx-sy*sy)*0.50f;r*=1.0f-shadow;g*=1.0f-shadow;b*=1.0f-shadow;

 if(k!=4294967295u){unsigned int id=k&262143u;

 if(id>=250000u){

 unsigned int branch=id-250000u;float4 va=woodA[branch];float4 vb=woodB[branch];

 float3 ap=make_float3(va.x,va.y,va.z);float3 bp=make_float3(vb.x,vb.y,vb.z);
 if(species>=21){ap=plantWind(ap,time,wind,species);bp=plantWind(bp,time,wind,species);}
 float3 aa=project(ap,yaw,tilt,scale,w,h,focus);float3 bb=project(bp,yaw,tilt,scale,w,h,focus);

 float px=(float)(i%(unsigned int)w)+0.5f;float py=(float)(i/(unsigned int)w)+0.5f;float vx=bb.x-aa.x;float vy=bb.y-aa.y;

 float t=fminf(1.0f,fmaxf(0.0f,((px-aa.x)*vx+(py-aa.y)*vy)/fmaxf(0.00001f,vx*vx+vy*vy)));

 float rad=fmaxf(0.55f/scale,va.w+(vb.w-va.w)*t);float dx=(px-aa.x-vx*t)/scale;float dy=-(py-aa.y-vy*t)/scale;float front=sqrtf(fmaxf(0.0f,rad*rad-dx*dx-dy*dy));

 float nx=(dx*cosf(yaw)-dy*sinf(yaw)*sinf(tilt)-front*sinf(yaw)*cosf(tilt))/rad;

 float ny=(dy*cosf(tilt)-front*sinf(tilt))/rad;

 float nz=(-dx*sinf(yaw)-dy*cosf(yaw)*sinf(tilt)-front*cosf(yaw)*cosf(tilt))/rad;

 float3 world=make_float3(va.x+(vb.x-va.x)*t+nx*rad,va.y+(vb.y-va.y)*t+ny*rad,va.z+(vb.z-va.z)*t+nz*rad);

 float direct=fmaxf(0.0f,nx*lx+ny*ly+nz*lz);float illumination=0.25f+0.75f*direct;

 float3 albedo=bark(world,species);if(species>=51&&species<=60&&branch>=448u&&branch<456u)albedo=bark(world,0);r=albedo.x*illumination;g=albedo.y*illumination;b=albedo.z*illumination;

 }

 else{float4 nm=normal[id];float4 p=pos[id];int az=(int)(nm.x/6.283185f*(float)bins);int el=(int)((nm.y/2.7f+0.5f)*(float)(bins/2));

 int nb=bins*bins/2;unsigned int group=(unsigned int)nm.w*(unsigned int)nb+(unsigned int)(el*bins+az);

 float grouped=light[group];float exact=grouped;

 if(mode==1||mode==3)exact=exposure(normdir(nm.x,nm.y),make_float3(p.x,p.y,p.z),make_float3(lx,ly,lz),species);

 float e=grouped;if(mode==1)e=exact;

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

 if(mode==2){r=rnd(group+3u)*0.8f+0.1f;g=rnd(group+9u)*0.8f+0.1f;b=rnd(group+17u)*0.8f+0.1f;}

 if(mode==3){float err=fminf(1.0f,fabsf(grouped-exact)*5.0f);r=err;g=0.12f+0.2f*(1.0f-err);b=0.22f*(1.0f-err);}

 }}

 pixels[i]=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,b)*255.0f)<<16)|4278190080u;

}



