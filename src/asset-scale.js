// Placement defaults in world metres, relative to each procedural generator.
// These are scene-authoring defaults, not a botanical size catalogue.
export function defaultScale(id){
 if(id<10)return [2.5,2.3,2,2.5,3,2.5,3,2.5,3,2][id];
 if(id===10)return 1;
 if(id<=20)return [0.65,0.65,0.7,0.75,0.7,0.65,0.8,0.75,0.8,0.8][id-11];
 if(id<=30)return 0.5;
 if(id<=40)return [0.45,0.5,0.5,0.4,0.4,0.45,0.45,0.4,0.5,0.45][id-31];
 if(id<=50)return 0.3;
 if(id<=60)return 1;
 if(id<=70)return 1;
 if(id<=80)return 1;
 if(id<=90)return 0.25;
 if(id<=100)return 1;
 if(id<=110)return 0.5;
 return 1;
}
