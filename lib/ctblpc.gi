#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the parts of the Dixon-Schneider specific to pc groups
##


#############################################################################
##
#F  PcGroupClassMatrixColumn(<D>,<mat>,<r>,<t>)  . calculate the t-th column
#F       of the r-th class matrix and store it in the appropriate column of M
##
PcGroupClassMatrixColumn := function(D,M,r,t)
  local c,s,z,i,T,p,orb,chunk;
  if t=1 then
    M[D.inversemap[r]][t]:=D.classiz[r];
  else
    orb:=DxGaloisOrbits(D,r);
    z:=D.classreps[t];
    c:=orb.orbits[t][1];
    if c<>t then
      p:=RepresentativeAction(orb.group,c,t);
      # was the first column of the galois class active?
      if ForAny([1..NrRows(M)],i->M[i,c]>0) then
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
    T[3]:=List(T[1],x->Position(D.ids,D.identification(D,x)));

    # identify in blocks of at most 5000
    chunk:=5000;

    for i in [0..QuoInt(Length(T[1]),chunk)] do
      orb:=[chunk*i+1..Minimum(chunk*(i+1)-1,Length(T[1]))];

      z:=ClassesSolvableGroup(D.group,0, rec(candidates:=T[1]{orb}));
      # The class identification in chunks can produce wrong results if
      # elements do not end up in the same class (since
      # it assumes the vector space decomposition to be always the same).
      # Thus do not test the resulting canonical representatives, but
      # conjugate the representatives as indicated and allow for
      # failure.
      z:=List([1..Length(orb)],x->Position(D.ids,T[1][orb[x]]^z[x].operator));
      T[3]{orb}:=z;

    od;

    for i in [1..Length(T[1])] do
      s:=T[3][i];
      if s=fail then
        s:=Position(D.ids,D.identification(D,T[1][i]));
      fi;

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
  #D.ids:=List(ClassesSolvableGroup(D.group,0,rec(candidates:=D.classreps)),
  #  x->x.representative);
  D.rids:=[];
  for i in D.classrange do
    D.ids[i]:=D.identification(D,D.classreps[i]);
    D.rids[i]:=D.rationalidentification(D,D.classreps[i]);
  od;

  return D;

end);
