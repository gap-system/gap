#############################################################################
##
#W  csetperm.gi                     GAP library              Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for cosets of permutation groups
##
Revision.csetperm_gi:=
  "@(#)$Id$";

InstallMethod( AscendingChainOp, "PermGroup", IsIdentical,
  [IsPermGroup,IsPermGroup],0,
function(G,U)
local np,a,b,c,s,i;
  np:=Difference(MovedPoints(G),MovedPoints(U));
  c:=[G];
  s:=G;
  for i in np do
    s:=Stabilizer(s,i);
    if Size(s)>Size(U) then
      Add(c,s);
    fi;
  od;
  Add(c,U);
  return RefinedChain(G,Reversed(c));
end);

InstallMethod(CanonicalRightCosetElement,"Perm",IsCollsElms,
  [IsPermGroup,IsPerm],0,
function(U,e)
  return MinimalElementCosetStabChain(MinimalStabChain(U),e);
end);


#############################################################################
##
#E  csetperm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
