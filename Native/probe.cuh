// Compile/run feasibility probe only; this is not the native world player.
#include <cstdio>
#include <vector>
extern "C" int leafNativeProbe(){
 cudaDeviceProp prop{};cudaError_t e=cudaGetDeviceProperties(&prop,0);
 if(e!=cudaSuccess){std::fprintf(stderr,"CUDA: %s\n",cudaGetErrorString(e));return 1;}
 constexpr unsigned n=4096;float4 *pos=nullptr,*normal=nullptr,*shape=nullptr;
 if(cudaMalloc(&pos,n*sizeof(float4))!=cudaSuccess||cudaMalloc(&normal,n*sizeof(float4))!=cudaSuccess||cudaMalloc(&shape,n*sizeof(float4))!=cudaSuccess)return 2;
 std::vector<float4> first(n),again(n);unsigned checked=0;
 for(int species=0;species<121;species++){
  generate<<<32,128>>>(pos,normal,shape,42,n,species);
  if(cudaDeviceSynchronize()!=cudaSuccess)return 3;
  if(cudaMemcpy(first.data(),pos,n*sizeof(float4),cudaMemcpyDeviceToHost)!=cudaSuccess)return 4;
  generate<<<32,128>>>(pos,normal,shape,42,n,species);
  if(cudaMemcpy(again.data(),pos,n*sizeof(float4),cudaMemcpyDeviceToHost)!=cudaSuccess)return 5;
  for(unsigned i=0;i<n;i++){const float *a=&first[i].x,*b=&again[i].x;for(int k=0;k<4;k++)if(!std::isfinite(a[k])||a[k]!=b[k])return 6;}checked++;
 }
 cudaFree(pos);cudaFree(normal);cudaFree(shape);
 std::printf("GPU: %s (sm_%d%d)\nPASS: %u asset presets x %u positions, finite and repeatable.\n",prop.name,prop.major,prop.minor,checked,n);
 return 0;
}
