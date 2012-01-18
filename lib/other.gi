#############################################################################
##
#W  other.gi                    GAP library                  Alexander Hulpke
##
##                                                     
#Y  (C) 2000 School Mathematical Sciences, University of St Andrews, Scotland
##
##  This file contains implementations for interface functions to other
##  systems.


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
