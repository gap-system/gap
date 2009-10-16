#############################################################################
##
#A  equiv.gd                  Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##

#############################################################################
##
#O  ConjugatorSpaceGroups( S1, S2 ) . . . . . . . . .returns C with S1^C = S2
##
DeclareOperation( "ConjugatorSpaceGroups",
    [ IsAffineCrystGroupOnLeftOrRight, IsAffineCrystGroupOnLeftOrRight ] );
