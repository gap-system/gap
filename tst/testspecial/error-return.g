# test returning a replacement value in response to an error
f:={x}->x;;
f();
return [42];
f:={}->1;;
f(1);
return [];
f(1,2);
return [];
f(1,2,3);
return [];
f(1,2,3,4);
return [];
f(1,2,3,4,5);
return [];
f(1,2,3,4,5,6);
return [];
f(1,2,3,4,5,6,7);
return [];
