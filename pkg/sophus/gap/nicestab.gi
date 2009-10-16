#############################################################################
##
#W  nicestab.gi                 Sophus package                Csaba Schneider 
##
#W  The methods in this file were written based on the methods in the 
#W  file of the autpgrp package.
##
#H  $Id: nicestab.gi,v 1.3 2005/08/09 17:06:07 gap Exp $

#############################################################################
##
#F TryPermOperationNL( A ) . . . . . . . . resets A.glOper to perms or nothing
##

TryPermOperationNL := function( A )
    local L, r, p, base, V, norm, f, M, iso, P;

    # if its too big, then don't try.
    L := A.liealg;
    r := MinimalGeneratorNumber( L );
    p := Characteristic( LeftActingDomain( L ));
    if (p^r - 1) / (p - 1) > 1100 then 
        Unbind( A.glOper );
        return; 
    fi;
    Info( InfoAutGrp, 4, "    compute perm rep");
    
    #Error();
    
    # now we compute it
    base := IdentityMat( r, GF(p) );
    V    := GF(p)^r;               
    norm := NormedVectors( V );    
    f    := function( pt, a ) return NormedRowVector( pt * a ); end;
    M    := Group( A.glOper, base );
    iso  := ActionHomomorphism( M, norm, f );
    P    := Image( iso );

    # and get images
    A.glOper := GeneratorsOfGroup( P );
end;  



#############################################################################
##
#F ReducePermOperNL( A )
##

ReducePermOperNL := function(A)
    local P, B, phom, gens, auts;
    
    Info( InfoAutGrp, 4, "  reduce permutation operation");
    
    # get perm group
    P := Group( A.glOper, ());
    B := Group( A.glAutos );
    SetSize( P, A.glOrder );
    
    # mapping from A to permgroup P
    phom := GroupHomomorphismByImagesNC( B, P, A.glAutos, A.glOper );
    gens := SmallGeneratingSet(P);
    gens := Filtered( gens, x -> Order(x) > 1 );
    auts := List( gens, x -> PreImagesRepresentative( phom, x ) );
    A.glAutos := auts;
    A.glOper  := gens;

    Info( InfoAutGrp, 4, "  factor has size ",A.glOrder," and ",
                         Length(A.glAutos)," generators");
end;



#############################################################################
##
#F TrySolvableSubgroupNL( A )
##

TrySolvableSubgroupNL := function( A )
    local P, B, N, pcgs, phom, nhom, G, auts, gens;

    Info( InfoAutGrp, 4, "  try solvable normal subgroup");

    # get perm group
    P := Group( A.glOper, ());
    B := Group( A.glAutos );
    SetSize( P, A.glOrder );

    # mapping from A to permgroup P
    phom := GroupHomomorphismByImagesNC( B, P, A.glAutos, A.glOper );

    #Error();

    # get normal subgroup
    N := RadicalGroup( P );
    pcgs := Pcgs( N ); 
    Info( InfoAutGrp, 4, "  found pcgs of length ", Length(pcgs));
    if Length(pcgs) = 0 then return; fi;

    # construct factor
    nhom := NaturalHomomorphismByNormalSubgroup( P, N );
    G := ImagesSource( nhom );

    # get ag part
    auts := List( pcgs, x -> PreImagesRepresentative( phom,x ) );
    A.agAutos := Concatenation( auts, A.agAutos );
    A.agOrder := Concatenation( RelativeOrders( pcgs ), A.agOrder );

    # and the factor 
    phom := phom * nhom;
    gens := SmallGeneratingSet( G );
    gens := Filtered( gens, x -> Order(x) > 1 );
    auts := List( gens, x -> PreImagesRepresentative( phom, x ) );
    A.glAutos := auts;
    A.glOrder := Size( G );
    A.glOper  := gens;
    Info( InfoAutGrp, 4, "  factor has size ",A.glOrder," and ", 
                         Length(A.glAutos)," generators");

end;


#############################################################################
##
#F NiceInitGroupNL( A, "init" ) . . . . . . .  flag indicates the init method 
##
## try to compute a perm rep and, if successful, compute N.
##

NiceInitGroupNL := function( A, flag )

    Info( InfoAutGrp, 3, "  nice init group");

    # catch a trivial case
    if Length( A.glOper ) = 0 then
        Unbind( A.glOper );
        return;
    fi;
 
    # try to compute perm-oper, if possible
    if IsMatrix( A.glOper[1] ) then
        TryPermOperationNL( A );
        return;
    fi;

    # finally, if a perm oper is given, then try to enlarge agAutos
    if IsPerm( A.glOper[1] ) and flag then
        if REDU_OPER then
            ReducePermOperNL( A );
        else
            TrySolvableSubgroupNL( A );
        fi;
    fi;
end;


    
