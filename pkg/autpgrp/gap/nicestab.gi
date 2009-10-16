#############################################################################
##
#W  nicestab.gi             AutPGrp package                      Bettina Eick
##
#H  @(#)$Id: nicestab.gi,v 1.7 2005/01/06 12:47:06 gap Exp $
##
Revision.("autpgrp/gap/nicestab_gi") :=
    "@(#)$Id: nicestab.gi,v 1.7 2005/01/06 12:47:06 gap Exp $";

#############################################################################
##
#F GLMatrix( aut )
##
GLMatrix := function( aut )
    local G, r, pcgsG, pcgsN, pcgsF, mat;
    G := Source( aut );
    r := RankPGroup( G );
    pcgsG := Pcgs( G );
    pcgsN := InducedPcgsByPcSequenceNC( pcgsG, pcgsG{[r+1..Length(pcgsG)]} );
    pcgsF := pcgsG mod pcgsN;
    mat := List(pcgsF,
                x->ExponentsOfPcElement(pcgsF,ImagesRepresentative(aut,x)));
    return mat;
end;

#############################################################################
##
#F TryPermOperation( A ) . . . . . . . . resets A.glOper to perms or nothing
##
TryPermOperation := function( A )
    local G, r, p, base, V, norm, f, M, iso, P;

    # if its too big, then don't try.
    G := A.group;
    r := RankPGroup( G );
    p := PrimePGroup( G );
    if (p^r - 1) / (p - 1) > 1100 then 
        Unbind( A.glOper );
        return; 
    fi;
    Info( InfoAutGrp, 4, "    compute perm rep");

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
#F ReducePermOper( A )
##
ReducePermOper := function(A)
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
#F TrySolvableSubgroup( A )
##
TrySolvableSubgroup := function( A )
    local P, B, N, pcgs, phom, nhom, G, auts, gens;

    Info( InfoAutGrp, 4, "  try solvable normal subgroup");

    # get perm group
    P := Group( A.glOper, ());
    B := Group( A.glAutos );
    SetSize( P, A.glOrder );

    # mapping from A to permgroup P
    phom := GroupHomomorphismByImagesNC( B, P, A.glAutos, A.glOper );

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
#F NiceInitGroup( A, "init" ) . . . . . . . .  flag indicates the init method 
##
## try to compute a perm rep and, if successful, compute N.
##
NiceInitGroup := function( A, flag )

    Info( InfoAutGrp, 3, "  nice init group");

    # catch a trivial case
    if Length( A.glOper ) = 0 then
        Unbind( A.glOper );
        return;
    fi;
 
    # try to compute perm-oper, if possible
    if IsMatrix( A.glOper[1] ) then
        TryPermOperation( A );
        return;
    fi;

    # finally, if a perm oper is given, then try to enlarge agAutos
    if IsPerm( A.glOper[1] ) and flag then
        if REDU_OPER then
            ReducePermOper( A );
        else
            TrySolvableSubgroup( A );
        fi;
    fi;
end;

#############################################################################
##
#F NiceHybridGroup( A )
##
NiceHybridGroup := function( A )
    local mats, done, auts, i, mat, aut, fac, rels, e, f; 

    # catch the trivial cases
    if Length( A.glAutos ) = 0 or A.glOrder = 1 then
        Unbind( A.glOper );
        A.glautos := [];
        return;
    fi;

    # in case we have a perm rep
    if IsBound( A.glOper ) then
        Info( InfoAutGrp, 3, "  nice stabilizer with perm rep");
        if REDU_OPER then
            ReducePermOper(A);
        else
            TrySolvableSubgroup( A );
        fi;
        return;
    fi;
    Info( InfoAutGrp, 3, "  nice stabilizer with matr rep");

    # otherwise
    mats := List( A.glAutos, x -> GLMatrix( x ) * One( A.field ) );
    done := [mats[1]^0];
    auts := [];
    for i in [1..Length(mats)] do
        if not mats[i] in done then
            Add( auts, A.glAutos[i] );
            Add( done, mats[i] );
        fi;
    od;

    # catch a special case
    if Length( auts ) = 1 then
        mat := done[2];
        aut := auts[1];
        fac := Factors( Order( mat ) );
        rels := [];
        auts := [];
        e := 1;
        for f in fac do
            Add( auts, aut^e );
            e := e * f;
        od;
        A.agAutos := Concatenation( auts, A.agAutos );
        A.agOrder := Concatenation( fac, A.agOrder );
        A.glAutos := [];
        A.glOrder := 1;
    else
        A.glAutos := auts;
    fi;
    Info( InfoAutGrp, 4, "     factor has size ",A.glOrder," and");
    Info( InfoAutGrp, 4, Length(A.glAutos)," generators");
end;
    
