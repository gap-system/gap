#############################################################################
##
#W  polyquot.gi                   ipcq package                   Bettina Eick
##

#############################################################################
##
#F GroupByQSystem( Q )
##
InstallGlobalFunction( GroupByQSystem, function( Q )
    local G, g, H, h, hom; 
    G := Q.fpgroup;
    g := GeneratorsOfGroup( G );
    H := Q.pcgroup;
    h := Q.imgs;
    hom := GroupHomomorphismByImagesNC( G, H, g, h );
    SetIsSurjective( hom, true ); 
    H!.isomorphism := hom;
    return H;
end);

#############################################################################
##
#F PolycyclicQuotient( G ) . . . . . . . . . . . . . . . . . . . . . . . ipcq
##
InstallGlobalFunction( PolycyclicQuotient, function( G )
    local Q, i;

    # init the system
    Q := InitQSystem( G );
    i := 1;

    # iterate 
    while Length( Q.steps[i] ) > 0 do
        NextStepQSystem( Q );
        i := i + 1;
    od;

    # return
    return GroupByQSystem( Q );
end );

