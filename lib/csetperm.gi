#############################################################################
##
#W  csetperm.gi                     GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for cosets of permutation groups
##
Revision.csetperm_gi:=
  "@(#)$Id$";

InstallMethod( AscendingChainOp, "PermGroup", IsIdenticalObj,
  [IsPermGroup,IsPermGroup],0,
function(G,U)
local s,c,mp,o,i,step;
  s:=G;
  c:=[G];
  repeat
    mp:=MovedPoints(s);
    o:=ShallowCopy(OrbitsDomain(s,mp));
    Sort(o,function(a,b) return Length(a)<Length(b);end);
    i:=1;
    step:=false;
    while i<=Length(o) and step=false do
      if not IsTransitive(U,o[i]) then
	Info(InfoCoset,2,"AC: orbit");
	o:=ShallowCopy(OrbitsDomain(U,o[i]));
	Sort(o,function(a,b) return Length(a)<Length(b);end);
	s:=Stabilizer(s,Set(o[1]),OnSets);
	step:=true;
      elif IsPrimitive(s,o[i]) and not IsPrimitive(U,o[i]) then
	Info(InfoCoset,2,"AC: blocks");
	s:=Stabilizer(s,Set(List(MaximalBlocks(U,o[i]),Set)),
                      OnSetsDisjointSets);
	step:=true;
      else
	i:=i+1;
      fi;
    od;
    if step then
      Add(c,s);
    fi;
  until step=false or Index(s,U)=1; # we could not refine better
  if Index(s,U)>1 then
    Add(c,U);
  fi;
  if InfoLevel(InfoCoset)>1 then
    Print("Indices",List([1..Length(c)-1],i->Index(c[i],c[i+1])),"\n");
  fi;
  return RefinedChain(G,Reversed(c));
end);

InstallMethod(CanonicalRightCosetElement,"Perm",IsCollsElms,
  [IsPermGroup,IsPerm],0,
function(U,e)
  return MinimalElementCosetStabChain(MinimalStabChain(U),e);
end);

InstallMethod(\<,"RightCosets of perm group",IsIdenticalObj,
  [IsRightCoset and IsPermCollection,IsRightCoset and IsPermCollection],0,
function(a,b)
  # for permutation groups the canonical rep is the smallest element of the
  # coset
  if ActingDomain(a)<>ActingDomain(b) then
    return ActingDomain(a)<ActingDomain(b);
  fi;
  return CanonicalRepresentativeOfExternalSet(a)
         <CanonicalRepresentativeOfExternalSet(b);
end);


#############################################################################
##
#E  csetperm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
