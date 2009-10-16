g93:=function()
local g1,g2,r,f,g,rws,x;
f:=FreeGroup(2);
g:=GeneratorsOfGroup(f);
g1:=g[1];
g2:=g[2];
rws:=SingleCollector(f,[ 3, 31 ]);
r:=[
];
for x in r do SetPower(rws,x[1],x[2]);od;
r:=[
[2,1,g2^4]
];
for x in r do SetCommutator(rws,x[1],x[2],x[3]);od;
return GroupByRwsNC(rws);
end;
g93:=g93();
Print("#I A group of order ",Size(g93)," has been defined.\n");
Print("#I It is called g93\n");
