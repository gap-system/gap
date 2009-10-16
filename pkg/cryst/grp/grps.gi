#############################################################################
##
#F The extraction function
##
LibraryCrystGroup := function( d, i )
    local gens, norm, fini, S, P, N;

    if d = 2 then
        gens := Space_Group_Gens_2d;
        norm := Point_Group_Norm_Gens_2d;
        fini := Point_Group_Norm_IsFinite_2d;
    elif d = 3 then
        gens := Space_Group_Gens_3d;
        norm := Point_Group_Norm_Gens_3d;
        fini := Point_Group_Norm_IsFinite_3d;
    else
        Error("only dimensions 2 and 3 are available");
    fi;

    S := AffineCrystGroupOnRightNC( List( gens[i], MutableMatrix ), 
                                  IdentityMat( d+1 ) );
    AddTranslationBasis( S, IdentityMat( d ) );
    P := PointGroup( S );
    N := GroupByGenerators( List( norm[i], MutableMatrix ), 
                            IdentityMat( d ) );
    SetIsFinite( N, fini[i] );
    SetNormalizerInGLnZ( P, N );
    return S;
end;
