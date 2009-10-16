OOF:=function()
local g1,g2,g3,g4,g5,r,f,g,rws,x;
f:=FreeGroup(5);
g:=GeneratorsOfGroup(f);
g1:=g[1];
g2:=g[2];
g3:=g[3];
g4:=g[4];
g5:=g[5];
rws:=SingleCollector(f,[ 3, 7, 2, 2, 2 ]);
r:=[
];
for x in r do SetPower(rws,x[1],x[2]);od;
r:=[
[2,1,g2],
[4,1,g5],
[5,1,g4*g5],
[3,2,g3*g5],
[4,2,g3*g4*g5],
[5,2,g4*g5],
];
for x in r do SetCommutator(rws,x[1],x[2],x[3]);od;
return GroupByRwsNC(rws);
end;
OOF:=OOF();
Print("#I A group of order ",Size(OOF)," has been defined.\n");
Print("#I It is called OOF [our old friend]\n");
Print("#I and is the primitive solvable group of degree 8 and\n");
Print("#I order 168.\n");
