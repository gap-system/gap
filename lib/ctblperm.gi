#############################################################################
##
#W  ctblperm.gi                  GAP library                 Alexander Hulpke
##
##
#Y  Copyright (C) 1993, 1997
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementation of the Dixon-Schneider algorithm
##

#############################################################################
##
#F  FingerprintPerm( <D>, <el>, <i>, <j>, <orbitJ>, <representatives>)
#F       Entry i,j of the matrix of el in the permutation representation of G
##
FingerprintPerm := function(D,el,i,j,orbitJ,representatives)
  local x,a,cycle,cycles;
  a:=0;
  #cycles:=Cycles(el,D.group.orbit);
  cycles:=Cycles(el,MovedPoints(D.group));
  for cycle in cycles do
    x:=cycle[1];
    if x^(el*representatives[x]) in orbitJ then
      a:=a+Length(cycle);
    fi;
  od;
  return a;
end;


#############################################################################
##
#F  IdentificationPermGroup(<D>,<el>) . . . . .  class invariants for el in G
##
##  The class invariant consists of the cycle structure and - if computation
##  might improve results - of the Fingerprint of the permutation
##
IdentificationPermGroup := function(D,el)
  local s,t,i,l; # guter Programmier s t i l !
  s:=CycleStructurePerm(el);
  s:=ShallowCopy(s);
  if not IsPerfectGroup(D.group) then
    Add(s,CanonicalRightCosetElement(DerivedSubgroup(D.group),el));
  fi;
  t:=ShallowCopy(s);
  if t in D.centmulCandidates then
    Add(s,"c");
    l:=First(D.centmulMults,i->i[1]=t);
    for i in l{[2..Length(l)]} do
      s:=Concatenation(s,CycleStructurePerm(
                           el*D.classreps[i]));
    od;
  fi;
  if t in D.fingerprintCandidates then
    Add(s,-FingerprintPerm(D,el,D.p1,D.p2,D.fingerprintOrbitStabilizer,
                                    D.fingerprintRepresentatives));
  fi;
  if IsBound(D.usefitfree) and not s in D.nocanonize then
    l:=First(D.faclaimg,x->x[1]=s);
    l:=TFCanonicalClassRepresentative(D.group,[el]:candidatenums:=l[2]);
    Add(s,l[1][2]);
  fi;
  return s;
end;


#############################################################################
##
#F  RationalIdentificationPermGroup( <D>, <el> )   galois-fix class invariant
##
##  When trying to use cheap identifications, we cannot use all
##  identification routines: For exaple galois conjugated elements must be
##  multiplied by the *galois conjugate* of the central element!
##
RationalIdentificationPermGroup := function(D,el)
  return CycleStructurePerm(el);
end;


#############################################################################
##
#M  DxPreparation(<G>)
##  Set up some functions. Also test, whether calculating fingerprints and
##  multiplication by central elements might improve the quick
##  identification
##
InstallMethod(DxPreparation,"perm",true,[IsPermGroup,IsRecord],0,
function(G,D)
local k,structures,ambiguousStructures,i,j,p,cem,ces,z,t,cen,a,
      c,s,f,fc,fs,fos,fr,enum;

  D.identification:=IdentificationPermGroup;
  D.rationalidentification:=RationalIdentificationPermGroup;
  D.ClassMatrixColumn:=StandardClassMatrixColumn;

  if IsDxLargeGroup(G) then
    D.ClassElement:=ClassElementLargeGroup;
  else
    enum:=Enumerator(G);
    D.enum:=enum;
    D.ClassElement:=ClassElementSmallGroup;
    
    D.classMap:=ListWithIdenticalEntries(Size(G),D.klanz);
    for j in [1..D.klanz-1] do
      for i in Orbit(G,D.classreps[j]) do
        D.classMap[Position(enum,i)]:=j;
      od;
    od;
  fi;

  D.fingerprintCandidates:=[];
  D.centmulCandidates:=[];
  D.permdegree:=LargestMovedPoint(G);
  k:=D.klanz;
  if IsDxLargeGroup(G) then
    # test, if cyclestructure yields no perfect result
    structures:=[];
    ambiguousStructures:=[];
    for i in [1..k] do
      s:=IdentificationPermGroup(D,D.classreps[i]);
      if not s in structures then
        Add(structures,s);
      elif not s in ambiguousStructures then
        Add(ambiguousStructures,s);
      fi;
    od;
    if ambiguousStructures<>[] then
      # Centre multiplikation test
      cem:=[];
      cen:=[];
      for i in [2..Length(D.classes)] do
        if D.classiz[i]=1 then
          Add(cen,i);
        fi;
      od;

      if cen<>[] then
        for s in ambiguousStructures do
          ces:=[s];
          c:=Filtered(D.classrange,i->
               IdentificationPermGroup(D,D.classreps[i])=s);
          a:=[[1..Length(c)]];
          for z in cen do
            t:=List(c,i->
                     CycleStructurePerm(
                                    D.classreps[i]*
                                    D.classreps[z]));
            if Length(Set(t))>1 then
              # improved result ?
              fc:=[];
              fs:=[];
              for i in [1..Length(t)] do
                p:=Position(fc,t[i]);
                if p=fail then
                  Add(fc,t[i]);
                  p:=Length(fc);
                  fs[p]:=[];
                fi;
                Add(fs[p],i);
              od;
              fc:=[];
              for i in a do
                fc:=Concatenation(fc,Filtered(List(fs,j->Intersection(j,i)),
                                    j->j<>[]));
              od;
              fc:=Set(fc);
              if fc<>a then
                Add(ces,z);
                a:=fc;
              fi;
            fi;
          od;
          if Length(ces)>1 then
            Add(cem,ces);
          fi;
        od;
        D.centmulMults:=cem;
      fi;

      # fingerprint test
      if IsTransitive(G,MovedPoints(G)) and
  # otherwise lotsa representatives will mess up memory
         Length(MovedPoints(G))<1500 then

        # select moved points 1 and 2
        fos:=MovedPoints(G);
        D.p1:=fos[1];
        D.p2:=fos[2]; 

        fs  := Stabilizer(G,D.p1);
        fos := First(OrbitsDomain(fs,[1..D.permdegree]),o->D.p2 in o);
        fr  := List([1..D.permdegree],x->RepresentativeAction(G,x,D.p1));
        fc:=[];
        for s in ambiguousStructures do
          c:=Filtered([1..D.klanz],i->IdentificationPermGroup(D,
                  D.classreps[i])=s);
          f:=List(c,i->FingerprintPerm(D,
                    D.classreps[i],D.p1,D.p2,fos,fr));
          if Length(Set(f))>1 then Add(fc,s);
          fi;
        od;
        if Length(fc)>0 then
          D.fingerprintCandidates:=fc;
          D.fingerprintOrbitStabilizer:=fos;
          D.fingerprintRepresentatives:=fr;
        fi;
      fi;
      D.centmulCandidates:=Set(List(cem,i->i[1]));
    fi;
  fi;

  D.ids:=[];
  D.rids:=[];
  for i in [1..D.klanz] do
    D.ids[i]:=D.identification(D,D.classreps[i]);
    D.rids[i]:=
     D.rationalidentification(D,D.classreps[i]);
  od;

  # use canonical reps?
  if Size(RadicalGroup(D.group))>1 then
    D.usefitfree:=true;
    D.nocanonize:=[];
    D.faclaimg:=[];
    fs:=List(D.ids,ShallowCopy);
    for i in [1..D.klanz] do
      f:=Filtered([1..D.klanz],x->fs[x]=fs[i]);
      if Length(f)=1 then
	Add(D.nocanonize,fs[i]);
      else
	Add(D.faclaimg,[fs[i],f]); # store which classes images could be
	f:=TFCanonicalClassRepresentative(D.group,[D.classreps[i]]);
	Add(D.ids[i],f[1][2]);
      fi;
    od;
  fi;

  return D;

end);


#############################################################################
##
#E  ctblperm.gi
##
