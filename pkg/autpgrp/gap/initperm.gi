#############################################################################
##
#W  initperm.gi              AutPGrp package                     Bettina Eick
##
#H  @(#)$Id: initperm.gi,v 1.7 2009/08/31 07:40:15 gap Exp $
##
Revision.("autpgrp/gap/initperm_gi") :=
    "@(#)$Id: initperm.gi,v 1.7 2009/08/31 07:40:15 gap Exp $";

#############################################################################
##
#F Fingerprint( G, U )
##
FingerprintSmall := function( G, U )
    return Flat( [IdGroup( U ), Size(CommutatorSubgroup( G, U )) ]);
end;

FingerprintMedium := function( G, U )
    local ranks, invs, comm, all, cls, fus, new;

    # some general stuff
    ranks := LGFirst( SpecialPcgs( U ) );
    invs  := AbelianInvariants( Centre(U) );
    comm  := Size( CommutatorSubgroup( G, U ) );

    # use conjugacy classes
    all := Orbits( G, AsList(U) );
    all := List( all, x -> Set(x));
    cls := List( all, x -> Order(x[1]) );
    Sort( cls );

    return Concatenation( ranks, invs, [comm], cls );
end;

FingerprintLarge := function( G, U )
    return LGFirst( SpecialPcgs(U) );
end;

FingerprintHuge := function( G, U )
    return List( DerivedSeries(U), Size );
end;

PGFingerprint := function ( G, U )
    if Size( U ) <= 255 and IsRecord( ID_AVAILABLE( Size(U) ) ) then
        return FingerprintSmall( G, U );
    elif Size( U ) <= 1000 then
        return FingerprintMedium( G, U );
    elif Size( U ) <= 2^21 then
        return FingerprintLarge( G, U );
    else
        return FingerprintHuge( G, U );
    fi;
end;

DualBasis := function( base )
  local M;
  M := NullspaceMat( TransposedMat( base ));
  M := List( M, ShallowCopy );
  TriangulizeMat( M );
  return M;
end;

#############################################################################
##
#F PartitionMinimalOvergrps ( G, pcgs, norm )
##
PartitionMinimalOvergrps := function( G, pcgs, norm )
    local min, done, part, i, tup, pos;

    Info( InfoAutGrp, 3, "  computing partition ");
    done := [];
    part := [];
    for i in [1..Length(norm)] do
        Info( InfoAutGrp, 4, "    start ",i);
        #min := DualBasis( [norm[i]] );
        min := InducedPcgsByBasis( pcgs, [norm[i]] );
        tup := PGFingerprint( G, SubgroupByPcgs( G, min ) );
        pos := Position( done, tup );
        if IsBool( pos ) then
            Add( part, [i] );
            Add( done, tup );
        else
            Add( part[pos], i );
        fi;
    od;
    Sort( part, function( x, y ) return Length(x) < Length(y); end );
    return part;
end;

#############################################################################
##
#F PartitionStabilizer ( A, part, norm )
##
PartitionStabilizer := function( A, part, norm )
    local iso, P, sub, gens, n, q;

    Info( InfoAutGrp, 3, "  computing stabilizer of ", part);
    iso := ActionHomomorphism( A, norm, OnLines, "surjective" );
    P := Image( iso );

    # transfer size info
    n := DimensionOfMatrixGroup(A);
    q := Size(FieldOfMatrixGroup(A));
    if HasIsNaturalGL(A) and IsNaturalGL(A) then
        SetSize(P,Size(A)/(q-1));
    elif HasIsNaturalSL(A) and IsNaturalSL(A) then
        SetSize(P,Size(A)/Gcd(n,q-1));
    fi;

    # loop
    for sub in part{[1..Length(part)-1]} do 
        if Length( sub ) = 1 then
            P := Stabilizer( P, sub[1], OnPoints );
            Info( InfoAutGrp, 3, "  found stabilizer of size ", Size(P));
        else
            P := Stabilizer( P, sub, OnSets );
            Info( InfoAutGrp, 3, "  found stabilizer of size ", Size(P));
        fi;
    od;
    gens := SmallGeneratingSet( P ); 
   
    # return
    return rec( perm := gens,
                mats := List( gens, x -> PreImagesRepresentative(iso,x) ),
                size := Size(P) ); 
end;

#############################################################################
##
#F AutoOfMat( mat, H )
##
AutoOfMat := function( mat, H )
    local img, aut, pcgs;
    pcgs := Pcgs(H);
    img := List( mat, x -> PcElementByExponentsNC(pcgs, x) );
    aut := PGAutomorphism( H, pcgs, img );
    return aut;
end;

#############################################################################
##
#F InitAutomorphismGroupOver( G )
##
InstallGlobalFunction( InitAutomorphismGroupOver,
  function( G )
    local r, p, pcgsG, pcgsN, pcgs, base, V, norm, part, stab, H, kern, A;

    Info( InfoAutGrp, 2, "  initialize automorphism group: Over ");

    # set up
    r := RankPGroup( G );
    p := PrimePGroup( G );

    # pgcs'se
    pcgsG := SpecialPcgs(G);
    pcgsN := InducedPcgsByPcSequenceNC( pcgsG, pcgsG{[r+1..Length(pcgsG)]} );
    pcgs  := pcgsG mod pcgsN;

    # get partition stabilizer
    base := IdentityMat( r, GF(p) );
    V    := GF(p)^r;
    norm := NormedVectors( V );
    part := PartitionMinimalOvergrps( G, pcgs, norm );
    stab := PartitionStabilizer( GL( r, p ), part, norm );

    # get quotient
    H := FrattiniQuotientPGroup( G );
    kern := InitAgAutos( H, p );

    # create aut grp
    A := rec();
    A.glAutos := List( stab.mats, x -> AutoOfMat( x, H ) );
    A.glOrder := stab.size;
    A.glOper  := ShallowCopy( stab.perm );
    A.agAutos := kern.auts;
    A.agOrder := kern.rels;
    A.one     := IdentityPGAutomorphism(H);
    A.group   := H;
    A.size    := A.glOrder * Product( A.agOrder );

    # try to construct solvable normal subgroup
    NiceInitGroup( A, true );
    return A;
  end);
