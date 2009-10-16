#############################################################################
##
#W  other.gi                    GAP library                  Alexander Hulpke
##
#H  @(#)$Id: other.gi,v 4.1 2000/08/17 10:58:08 ahulpke Exp $
##                                                     
#Y  (C) 2000 School Mathematical Sciences, University of St Andrews, Scotland
##
##  This file contains implementations for interface functions to other
##  systems.

Revision.other_gi :=
    "@(#)$Id: other.gi,v 4.1 2000/08/17 10:58:08 ahulpke Exp $";                 

InstallMethod(MagmaInputString,"perm group",true,
  [IsPermGroup,IsString],0,
function(g,s)
local i,nf;
  s:=ShallowCopy(s);
  Append(s,":=PermutationGroup<");
  Append(s,String(LargestMovedPoint(g)));
  Add(s,'|');
  nf:=false;
  for i in GeneratorsOfGroup(g) do
    if nf then
      Append(s,",\n");
    fi;
    nf:=true;
    Append(s,String(i));
  od;
  Append(s,">;\n");
  return s;
end);
