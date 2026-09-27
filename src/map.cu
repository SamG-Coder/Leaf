__device__ float terrain_height(const float* terrain,float x,float z,float extent){float gx=fminf(63.9999f,fmaxf(0.0f,(x/extent+0.5f)*64.0f));float gz=fminf(63.9999f,fmaxf(0.0f,(z/extent+0.5f)*64.0f));int ix=(int)gx;int iz=(int)gz;float u=gx-(float)ix;float v=gz-(float)iz;return (terrain[iz*65+ix]*(1.0f-u)+terrain[iz*65+ix+1]*u)*(1.0f-v)+(terrain[(iz+1)*65+ix]*(1.0f-u)+terrain[(iz+1)*65+ix+1]*u)*v;}
// Cached CUDA colour/depth surfaces composed in a shared isometric world.
__global__ void map_render(const unsigned int* atlas,const unsigned int* atlasDepth,const float4* objects,const float4* flags,const float* terrain,unsigned int* pixels,unsigned int* picks,int w,int h,int n,int tile,float zoom,float panX,float panY,float extent,int grid,float lx,float ly,float lz){
 unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=(unsigned int)(w*h))return;
 float px=(float)(i%(unsigned int)w)+0.5f;float py=(float)(i/(unsigned int)w)+0.5f;
 float cy=0.95533649f;float sy=0.29552021f;float ct=0.7960838f;float st=-0.6051864f;
 float xx=(px-(float)w*0.5f-panX)/zoom;float zz=(py-(float)h*0.54f-panY)/(zoom*st);
 float wx=xx*cy+zz*sy;float wz=-xx*sy+zz*cy;
 float r=0.070f;float g=0.090f;float b=0.094f;float closest=10000.0f;unsigned int chosen=0u;
 float ground=0.0f;bool hit=false;
 for(int step=0;step<35;step++){float yy=6.25f-(float)step*0.25f;float rz=((py-(float)h*0.54f-panY)/zoom+yy*ct)/st;float rx=xx*cy+rz*sy;float rz2=-xx*sy+rz*cy;
 if(fabsf(rx)<=extent*0.5f&&fabsf(rz2)<=extent*0.5f&&yy<=terrain_height(terrain,rx,rz2,extent)){float lo=yy;float hi=yy+0.25f;for(int k=0;k<6;k++){float mid=(lo+hi)*0.5f;float mz=((py-(float)h*0.54f-panY)/zoom+mid*ct)/st;float mx=xx*cy+mz*sy;float mw=-xx*sy+mz*cy;if(mid>terrain_height(terrain,mx,mw,extent))hi=mid;else lo=mid;}ground=(lo+hi)*0.5f;zz=((py-(float)h*0.54f-panY)/zoom+ground*ct)/st;wx=xx*cy+zz*sy;wz=-xx*sy+zz*cy;hit=true;break;}}
 if(hit){float eps=extent/64.0f;float nx=(terrain_height(terrain,wx-eps,wz,extent)-terrain_height(terrain,wx+eps,wz,extent))/(2.0f*eps);float nz=(terrain_height(terrain,wx,wz-eps,extent)-terrain_height(terrain,wx,wz+eps,extent))/(2.0f*eps);float illumination=0.52f+0.48f*fmaxf(0.0f,(nx*lx+ly+nz*lz)/sqrtf(nx*nx+1.0f+nz*nz));r=0.22f*illumination;g=0.27f*illumination;b=0.20f*illumination;closest=zz*ct+ground*st;
 float gx=fabsf(wx-floorf(wx+0.5f));float gz=fabsf(wz-floorf(wz+0.5f));if(grid!=0&&(gx<0.6f/zoom||gz<0.6f/zoom)){r+=0.035f;g+=0.04f;b+=0.04f;}
 if(fabsf(wx)<0.025f){r=0.21f;g=0.26f;b=0.34f;}if(fabsf(wz)<0.025f){r=0.32f;g=0.23f;b=0.20f;}}
 for(int j=0;j<n;j++){float4 o=objects[j];float4 f=flags[j];if(f.z<0.5f)continue;
 float cx=(float)w*0.5f+panX+(o.x*cy-o.y*sy)*zoom;float cz=o.x*sy+o.y*cy;float by=(float)h*0.54f+panY+cz*st*zoom-f.w*ct*zoom;
 float ratio=zoom*o.z/30.0f;float ax=(px-cx)/ratio+(float)tile*0.5f;float ay=(py-by)/ratio+(float)tile*0.51f+3.6f*ct*30.0f;
 if(ax<0.0f||ay<0.0f||ax>=(float)tile||ay>=(float)tile)continue;
 unsigned int index=(unsigned int)o.w*(unsigned int)(tile*tile)+(unsigned int)ay*(unsigned int)tile+(unsigned int)ax;unsigned int d=atlasDepth[index];if(d==4294967295u)continue;
 float depth=(((float)(d>>18)/480.0f-16.0f)+3.6f*st)*o.z+cz*ct+f.w*st;
 if(depth<=closest+0.003f){closest=depth;chosen=(unsigned int)f.x;unsigned int c=atlas[index];r=(float)(c&255u)/255.0f;g=(float)((c>>8)&255u)/255.0f;b=(float)((c>>16)&255u)/255.0f;
 if(f.y>0.5f){r=r*0.78f+0.19f;g=g*0.78f+0.14f;b=b*0.78f+0.025f;}}
 }
 pixels[i]=(unsigned int)(fminf(1.0f,r)*255.0f)|((unsigned int)(fminf(1.0f,g)*255.0f)<<8)|((unsigned int)(fminf(1.0f,b)*255.0f)<<16)|4278190080u;picks[i]=chosen;
}
