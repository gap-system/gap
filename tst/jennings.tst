# test for JenningsLieAlgebra (fixing a bug reported by Laurent Bartholdi):

gap> g := Group((1,10)(2,9)(3,11)(4,12)(5,15)(6,16)(7,13)(8,14)(17,21)(18,22)*
> (19,24)(20,23)(25,27)(26,28)(29,30)(33,51)(34,52)(35,49)(36,50)(37,54)(38,53)*
> (39,55)(40,56)(41,61)(42,62)(43,64)(44,63)(45,57)(46,58)(47,60)(48,59), 
> (1,19)(2,20)(3,17)(4,18)(5,22)(6,21)(7,23)(8,24)(9,29)(10,30)(11,32)(12,31)*
> (13,25)(14,26)(15,28)(16,27)(33,42)(34,41)(35,43)(36,44)(37,47)(38,48)(39,45)*
> (40,46)(49,53)(50,54)(51,56)(52,55)(57,59)(58,60)(61,62), 
> (1,37)(2,38)(3,40)(4,39)(5,33)(6,34)(7,36)(8,35)(9,43)(10,44)(11,41)(12,42)*
> (13,46)(14,45)(15,47)(16,48)(17,58)(18,57)(19,59)(20,60)(21,63)(22,64)(23,61)*
> (24,62)(25,50)(26,49)(27,51)(28,52)(29,55)(30,56)(31,53)(32,54));
<permutation group with 3 generators>
gap> L:= JenningsLieAlgebra(g);
<Lie algebra of dimension 13 over GF(2)>
gap> List(Basis(L),PthPowerImage);
[ 0*v.1, v.6, 0*v.1, v.7, v.8, v.9, 0*v.1, v.10, v.11, v.12, 0*v.1, v.13, 
  0*v.1 ]
gap> LieLowerCentralSeries(L);
[ <Lie algebra of dimension 13 over GF(2)>, 
  <Lie algebra of dimension 3 over GF(2)>, 
  <Lie algebra of dimension 0 over GF(2)> ]
gap> L:= PCentralLieAlgebra(g);
<Lie algebra of dimension 13 over GF(2)>
gap> LieLowerCentralSeries(L);
[ <Lie algebra of dimension 13 over GF(2)>, 
  <Lie algebra of dimension 10 over GF(2)>, 
  <Lie algebra of dimension 7 over GF(2)>, 
  <Lie algebra of dimension 4 over GF(2)>, 
  <Lie algebra of dimension 2 over GF(2)>, 
  <Lie algebra of dimension 1 over GF(2)>, 
  <Lie algebra of dimension 0 over GF(2)> ]
