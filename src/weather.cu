// Absolute cloud layer and world-space precipitation share one drifting density field.
__device__ float cloud_density(float x,float z,float time,float windSpeed,float windDirection){float a=windDirection*.0174532925f;x=(x-cosf(a)*time*windSpeed*.35f)*.002f;z=(z-sinf(a)*time*windSpeed*.35f)*.002f;return noise3(x,3.0f,z)*.65f+noise3(x*2.7f,5.0f,z*2.7f)*.35f+(noise3(x*10.0f,11.0f,z*10.0f)-.5f)*.15f;}
__device__ float cloud_rain(float x,float z,float time,float clouds,float windSpeed,float windDirection){float n=cloud_density(x,z,time,windSpeed,windDirection);return fminf(1.0f,fmaxf(0.0f,(n-(.83f-clouds*.6f))/.10f));}
__global__ void scene_weather(const unsigned int* waterMask,const unsigned int* depth,unsigned int* pixels,const unsigned int* picks,const float4* waters,const float4* waterPoints,int waterCount,int w,int h,float cx,float cy,float cz,float yaw,float pitch,float aspect,float tangent,float time,float day,float clouds,float rain,float wetness,float windSpeed,float windDirection,int toon,float paint,float lx,float ly,float lz){
unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;float px=(float)(i%(unsigned int)w),py=(float)(i/(unsigned int)w);float sx=((px+.5f)/(float)w*2.0f-1.0f)*tangent*aspect,sy=(1.0f-(py+.5f)/(float)h*2.0f)*tangent;float cp=cosf(pitch),sp=sinf(pitch),ca=cosf(yaw),sa=sinf(yaw);float dx=sa*cp+ca*sx-sa*sp*sy,dy=sp+cp*sy,dz=ca*cp-sa*sx-ca*sp*sy;float length=sqrtf(dx*dx+dy*dy+dz*dz);dx/=length;dy/=length;dz/=length;
unsigned int old=pixels[i];float r=(float)(old&255u)/255.0f,g=(float)((old>>8)&255u)/255.0f,b=(float)((old>>16)&255u)/255.0f;
if(depth[i]==4294967295u){float horizon=1.0f-fmaxf(0.0f,dy);r=(.14f+.25f*horizon)*day+.012f*(1.0f-day);g=(.40f+.22f*horizon)*day+.02f*(1.0f-day);b=(.70f+.10f*horizon)*day+.06f*(1.0f-day);float dusk=(1.0f-fabsf(day*2.0f-1.0f))*powf(horizon,6.0f);r+=dusk*.35f;g+=dusk*.08f;
float sun=powf(fmaxf(0.0f,dx*lx+dy*ly+dz*lz),900.0f);float moon=powf(fmaxf(0.0f,-dx*lx-dy*ly-dz*lz),1500.0f)*(1.0f-day);r+=sun*.9f+moon*.5f;g+=sun*.7f+moon*.6f;b+=sun*.35f+moon*.7f;
if(dy>.01f&&cy<600.0f){float t=(600.0f-cy)/fmaxf(.01f,dy),angle=windDirection*.0174532925f,x=(cx+dx*t-cosf(angle)*time*windSpeed*.35f)*.002f,z=(cz+dz*t-sinf(angle)*time*windSpeed*.35f)*.002f;// Cloud-space brush detail stays attached to the drifting cloud field.
float broad=noise3(x,3.0f,z)*.65f+noise3(x*2.7f,5.0f,z*2.7f)*.35f;
float detail=noise3(x*10.0f,11.0f,z*10.0f),brush=noise3(x*23.0f,13.0f,z*17.0f);
float detailFade=fminf(1.0f,dy*8.0f);float n=broad+(detail-.5f)*.15f*detailFade;
float threshold=.83f-clouds*.6f;float edgeWidth=toon!=0?.025f:.16f;
float cover=fminf(1.0f,fmaxf(0.0f,(n-threshold)/edgeWidth));cover=cover*cover*(3.0f-2.0f*cover);cover*=fminf(1.0f,dy*15.0f);
float sunward=noise3(x-lx*.16f,3.0f,z-lz*.16f);float form=fminf(1.0f,fmaxf(0.0f,.5f+(broad-sunward)*3.0f+(detail-.5f)*.55f));
float band=toon!=0?(form<.36f?.70f:form<.56f?.82f:form<.72f?.93f:1.0f):.65f+form*.35f;
float pigment=1.0f;if(toon!=0)pigment+=(brush-.5f)*.09f*paint*detailFade;
float lit=band*pigment*(1.0f-rain*.55f)*(.16f+.84f*day);
float warm=(1.0f-fabsf(day*2.0f-1.0f))*.18f;
float cr=lit+warm*band,cg=lit*(.97f+warm*.2f),cb=lit+(1.0f-band)*.11f*day;
r=r*(1.0f-cover)+cr*cover;g=g*(1.0f-cover)+cg*cover;b=b*(1.0f-cover)+cb*cover;
float star=noise3(dx*650.0f,dy*650.0f,dz*650.0f);if(star>.91f){float twinkle=(star-.91f)*5.0f*(1.0f-day)*(1.0f-cover);r+=twinkle;g+=twinkle;b+=twinkle;}}
}else{float illumination=(.30f+.70f*day)*(1.0f-clouds*.22f);r*=illumination;g*=illumination;b*=illumination+(1.0f-day)*.10f;r+=(1.0f-day)*.008f;g+=(1.0f-day)*.014f;b+=(1.0f-day)*.026f;float forward=dx*sa*cp+dy*sp+dz*ca*cp,t=(float)depth[i]/(1000.0f*fmaxf(.001f,forward));float x=cx+dx*t,y=cy+dy*t,z=cz+dz*t;if(picks[i]==0u){float water=(float)waterMask[i];if(water>.5f&&rain>.001f){float gx=x*1.5f,gz=z*1.5f;float rings=0.0f;for(int oz=-1;oz<=1;oz++){for(int ox=-1;ox<=1;ox++){float cellX=floorf(gx)+(float)ox,cellZ=floorf(gz)+(float)oz;unsigned int key=(unsigned int)(int)cellX*73856093u^(unsigned int)(int)cellZ*19349663u;float phase=time*1.8f+rnd(key)*13.0f;int cycle=(int)floorf(phase);float age=phase-floorf(phase);key^=(unsigned int)cycle*83492791u;if(rnd(key+37u)>.7f)continue;float ux=gx-cellX-(.1f+.8f*rnd(key+11u)),uz=gz-cellZ-(.1f+.8f*rnd(key+23u));float radius=sqrtf(ux*ux+uz*uz);rings+=expf(-fabsf(radius-age*.48f)*100.0f)*(1.0f-age);}}float ring=rings*rain/(1.0f+t*.02f);r+=ring*.24f;g+=ring*.30f;b+=ring*.32f;}else if(water<.5f&&wetness>.0001f){float damp=wetness*.30f*(.35f+.65f*cloud_rain(x,z,time,clouds,windSpeed,windDirection));r*=1.0f-damp;g*=1.0f-damp;b*=1.0f-damp*.8f;float sheen=wetness*.08f*powf(fmaxf(0.0f,-dy),2.0f);r+=sheen*.5f;g+=sheen*.65f;b+=sheen;}}}
// Original lightweight screen-space rain. Subtract time so the pattern moves down.
float column=floorf((px+py*.13f)/9.0f),seed=noise3(column,7.0f,2.0f),trail=py-time*(400.0f+seed*220.0f);float phase=trail/95.0f+seed*17.0f;phase-=floorf(phase);float line=(px+py*.13f)/9.0f-column;float drop=fmaxf(0.0f,1.0f-fabsf(line-.5f)*22.0f)*fmaxf(0.0f,1.0f-phase*7.0f)*rain*.4f*(.25f+.75f*day);r+=drop*.65f;g+=drop*.8f;b+=drop;
pixels[i]=(unsigned int)(fminf(1.0f,fmaxf(0.0f,r))*255.0f)|((unsigned int)(fminf(1.0f,fmaxf(0.0f,g))*255.0f)<<8)|((unsigned int)(fminf(1.0f,fmaxf(0.0f,b))*255.0f)<<16)|4278190080u;
}
