ONF:=function()
local g1,g2,g3,g4,g5,g6,g7,r,f,g,rws,x;
f:=FreeGroup(7);
g:=GeneratorsOfGroup(f);
g1:=g[1];
g2:=g[2];
g3:=g[3];
g4:=g[4];
g5:=g[5];
g6:=g[6];
g7:=g[7];
rws:=SingleCollector(f,[ 3, 31, 2, 2, 5, 5, 5 ]);
r:=[
[3,g4],
];
for x in r do SetPower(rws,x[1],x[2]);od;
r:=[
[2,1,g2^4],
[5,1,g6*g7],
[6,1,g6^4*g7^3],
[7,1,g6^3*g7^3],
[5,2,g6^4*g7^3],
[6,2,g5^4*g6^4*g7^2],
[7,2,g5^2*g6^4*g7^4],
[5,3,g5],
[6,3,g6],
[7,3,g7],
[5,4,g5^3],
[6,4,g6^3],
[7,4,g7^3],
];
for x in r do SetCommutator(rws,x[1],x[2],x[3]);od;
return GroupByRwsNC(rws);
end;
ONF:=ONF();
Print("#I A group of order ",Size(ONF)," has been defined.\n");
Print("#I It is called ONF [our new friend].\n");
Print( "It is the extended Affine Group of degree 3 over GF(5),\n");
Print( "Aff(5,3)+ = f]e]d, with l < e a 31-Sylow subgroup.\n");
