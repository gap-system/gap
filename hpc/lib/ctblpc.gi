#############################################################################
##
#W  ctblpc.gi                    GAP library                 Alexander Hulpke
##
##
#Y  Copyright (C) 1993, 1997
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the parts of the Dixon-Schneider specific to pc groups
##


#############################################################################
##
#F  PcGroupClassMatrixColumn(<D>,<mat>,<r>,<t>)  . calculate the t-th column
#F       of the r-th class matrix and store it in the appropriate column of M
##
PcGroupClassMatrixColumn := function(D,M,r,t)
  local c,s,z,i,T,p,orb;
  if t=1 then
    M[D.inversemap[r]][t]:=D.classiz[r];
  else
    orb:=DxGaloisOrbits(D,r);
    z:=D.classreps[t];
    c:=orb.orbits[t][1];
    if c<>t then
      p:=RepresentativeAction(orb.group,c,t);
      # was the first column of the galois class active?
      if ForAny(M,i->i[c]>0) then
	for i in D.classrange do
	  M[i^p][t]:=M[i][c];
	od;
	Info(InfoCharacterTable,2,"by GaloisImage");
	return;
      fi;
    fi;

    T:=DoubleCentralizerOrbit(D,r,t);
    Info(InfoCharacterTable,2,Length(T[1])," instead of ",D.classiz[r]);

    for i in [1..Length(T[1])] do
      T[1][i]:=T[1][i]*z;
    od;

    #T AH: Here something goes wrong in the solvable group class
    #T computation. Workaround
    T[1]:=List(T[1],i->Position(D.ids,D.identification(D,i)));

    #T[1]:=List(ClassesSolvableGroup(D.group,0,rec(candidates:=T[1])),
    #           i->Position(D.ids,i.representative));

    for i in [1..Length(T[1])] do
      s:=T[1][i];
      M[s][t]:=M[s][t]+T[2][i];
    od;

  fi;
end;


#############################################################################
##
#F  IdentificationSolvableGroup(<D>,<el>) . .  class invariants for el in G
##
IdentificationSolvableGroup := function(D,el)
  return ClassesSolvableGroup(D.group,0,rec(candidates:=[el]))[1].representative;
end;


#############################################################################
##
#M  DxPreparation(<G>)
##
InstallMethod(DxPreparation,"pc group",true,[IsPcGroup,IsRecord],0,
function(G,D)
local i,cl;

  if not IsDxLargeGroup(G) then
    TryNextMethod();
  fi;

  D.ClassElement:=ClassElementLargeGroup;
  D.identification:=IdentificationSolvableGroup;
  D.rationalidentification:=IdentificationGenericGroup;
  D.ClassMatrixColumn:=PcGroupClassMatrixColumn;

  cl:=D.classes;
  D.ids:=[];
  D.rids:=[];
  for i in D.classrange do
    D.ids[i]:=D.identification(D,D.classreps[i]);
    D.rids[i]:=D.rationalidentification(D,D.classreps[i]);
  od;

  return D;

end);


#############################################################################
##
#E  ctblpc.gi
##
