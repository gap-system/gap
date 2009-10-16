#############################################################################
##
#W  lag.g                    GAP library                         Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains some functions, mostly developed for debugging purposes
##  and automated testing some conjectures in modular group algebras
##

PcPresentationOfNormalizedUnit := function( KG ) 
#
# For a group algebra KG this function returns another function, 
# which for a given element x of KG will return corresponding
# element of PcNormalizedUnitGroup. This fuction is used in
# the construction of NaturalBijectionToPcNormalizedUnitGroup
#
local emb;
  emb:=function(x)
    local coeffs, gens, w, i;
    coeffs := NormalizedUnitCF( KG, x );
    gens := GeneratorsOfGroup( PcNormalizedUnitGroup( KG ));
    w := One( PcNormalizedUnitGroup( KG ));
    for i in [ 1 .. Length(coeffs) ] do
      if not coeffs[i] = Zero( LeftActingDomain( KG ) ) then
        w := w*gens[i];
      fi;
    od;
    return w;
  end;
return emb;
end;


#############################################################################
##
#E
##

