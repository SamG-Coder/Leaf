// Screen-space sampling: distant coverage is filtered over a small pixel neighbourhood.
export function sampleBudget(radius,capacity){
 const transition=Math.max(0,Math.min(1,(radius-16)/64));
 const density=.5+1.5*transition;
 return Math.min(capacity,Math.max(16,Math.ceil(radius*radius*density)));
}
export function assetRadius(preset){
 if(preset<10)return 3;
 if(preset===10)return 4;
 if(preset<=20)return 1.8;
 if(preset<=30)return 1.5;
 if(preset<=40)return 2;
 if(preset<=50)return 1.5;
 if(preset<=60)return 2;
 if(preset<=70)return 2;
 if(preset<=80)return 2;
 if(preset<=90)return 1.5;
 return 2;
}
