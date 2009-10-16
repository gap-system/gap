LoadPackage("atlasrep");
AtlasOfGroupRepresentationsInfo.wget := true;

RestoreStateRandom(
[ 3, [ 52349192, 31282640, 121642702, 143650411, 82791369, 188184991, 
      109596351, 1676699, 227212123, 18775664, 128013466, 146544596, 
      191725122, 56159048, 15524557, 183293956, 264828058, 59362813, 
      127717877, 122728203, 242329526, 124578652, 57549843, 12514804, 
      28934020, 256932993, 68980346, 96208051, 152611532, 5064751, 258216571, 
      43745861, 153121536, 217883387, 109749659, 206130753, 224762113, 
      70466959, 50655943, 26416458, 193095859, 214754032, 245087340, 
      249299918, 14756640, 182562303, 139538053, 73000045, 142305647, 
      105478795, 192370632, 9536762, 118224155, 71207311, 154049343 ] ]);

Maker := function(name,rep,maxnr,nrsub)
  local f,g,gens,gensu,m,s,x;
  gens := AtlasGenerators(name,rep);
  s := AtlasStraightLineProgram(name,maxnr);
  gensu := ResultOfStraightLineProgram(s.program,gens.generators);
  f := FieldOfMatrixList(gensu);
  Print("Making ",maxnr,"th subgroup of ",name," over GF(",Size(f),")...\c");
  while nrsub > 0 do
      Print("\nChop...\c");
      g := GModuleByMats(gensu,f);
      m := MTX.ProperSubmoduleBasis(g);
      if m = fail then
          Print("fail...\c");
          break;
      else
          Print("dimension ",Length(m),"...\c");
      fi;
      s := MTX.InducedActionSubmodule(g,m);
      gensu := s.generators;
      nrsub := nrsub - 1;
  od;
  x := PseudoRandom(GL(Length(gensu[1]),Size(f)));
  gensu := List(gensu,y->x*y*x^-1);
  Print(name,"m",maxnr,"mod",Characteristic(f),"\n");
  return GroupWithGenerators(gensu);
end;

MakeTensorProduct := function(g,h)
  local d,f,gens,i,j,x;
  gens := [];
  for i in GeneratorsOfGroup(g) do
      for j in GeneratorsOfGroup(h) do
          Add(gens,KroneckerProduct(i,j));
      od;
  od;
  for i in gens do ConvertToMatrixRep(i); od;
  f := FieldOfMatrixGroup(g);
  d := Length(gens[1]);
  x := PseudoRandom(GL(d,f));
  gens := List(gens,y->x*y*x^-1);
  return GroupWithGenerators(gens);
end;

Lym3mod5 := Maker("Ly",3,3,1);
M24m7mod2 := Maker("M24",13,7,1);
M24m2mod7 := Maker("M24",31,2,0);
HSm4mod5 := Maker("HS",29,4,0);
M12m6mod5 := Maker("M12",17,6,1);
guck := MakeTensorProduct(HSm4mod5,SL(3,5));

