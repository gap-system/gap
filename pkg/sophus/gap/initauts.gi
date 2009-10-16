#############################################################################
##
#W  initauts.gi             Sophus package                   Csaba Schneider 
##
#W The functions in this file contain some procedures to initialise
#W the automorphism group computation. Its aim is to reduce the linear
#W part of the automorphism group and hence to accelerate the automorphism
#W group computation. The user is encouraged to experiment with these 
#W functions.
#H  $Id: initauts.gi,v 1.6 2005/08/09 17:06:07 gap Exp $

	  


#############################################################################
##
#F NLAFingerprintSmall( <L>, <U> )
##

NLAFingerprintSmall := function( L, U )
    return Dimension( ProductSpace( L, U ));
end;



#############################################################################
##
#F NLAFingerprintMedium( <L>, <U> )
##

NLAFingerprintMedium := function( L, U )
    local ranks, invs, comm, all, cls, fus, new, w;

    w := LieNBWeights( NilpotentBasis( U ));
    
    ranks := List( [1..w[Length( w )]], x->Position( w, x ));
    invs  := Dimension( Centre(U) );
    comm  := Size( ProductSpace( L, U ) );

    # use conjugacy classes
    all := Orbits( L, AsList(U) );
    all := List( all, x -> Set(x));
    cls := List( all, x -> Order(x[1]) );
    Sort( cls );

    return Concatenation( ranks, invs, [comm], cls );
end;



#############################################################################
##
#F NLAFingerprintLarge( <L>, <U> )
##

NLAFingerprintLarge := function( L, U )
    local w;
    
    w := LieNBWeights( NilpotentBasis( U ));
    return List( [1..w[Length( w )]], x->Position( w, x ));
end;



#############################################################################
##
#F NLAFingerprintHuge( <L>, <U> )
##

NLAFingerprintHuge := function( L, U )
    
    return List( LieDerivedSeries(U), Size );
end;



#############################################################################
##
#F NLAFingerprint( <L>, <U> )
##

NLAFingerprint := function ( L, U )
    if Size( U ) <= 255 and IsRecord( ID_AVAILABLE( Size(U) ) ) then
        return NLAFingerprintSmall( L, U );
    elif Size( U ) <= 1000 then
        return NLAFingerprintSmall( L, U );
    elif Size( U ) <= 2^21 then
        return NLAFingerprintSmall( L, U );
    else
        return NLAFingerprintSmall( L, U );
    fi;
end;



#############################################################################
##
#F PartitionMinimalOveralgebras ( L, basis, norm )
##

PartitionMinimalOveralgebras := function( L, basis, norm )
    local min, done, part, i, tup, pos, d, D, f, Q;

    Info( LieInfo, 3, "  computing partition ");
    d := MinimalGeneratorNumber( L );
    done := [];
    part := [];
    
    D := LieDerivedSubalgebra( L );
    f := NaturalHomomorphismByIdeal( L, D );
    Q := Image( f );
    
    for i in [1..Length(norm)] do
        tup := NLAFingerprint( L, Subalgebra( L, 
                       Concatenation( NilpotentBasis( L ){[d+1..Dimension( L )]}, 
                               [PreImagesRepresentative( f, LinearCombination( Basis( Q ), norm[i]))])));
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
#F NLAAutoOfMat( mat, H )
##

NLAAutoOfMat := function( mat, H )
    local img, aut, basis;
    
    basis := NilpotentBasis(H);
    img := List( mat, x -> LinearCombination( basis, x ));
    aut := NilpotentLieAutomorphism( H, basis, img );
    return aut;
end;



#############################################################################
##
#F InitAgAutosNL( H, p )
##

InitAgAutosNL := function( H, p )
    local basis, auts, alpha, fac, i, imgs;
    if p <> 2 then
        basis  := NilpotentBasis(H);
        auts  := [];
        alpha := PrimitiveRoot( GF(p) );
        fac   := Factors( p - 1 );
        for i in [1..Length(fac)] do
            imgs := List( basis, x-> x*IntFFE( alpha ) );
            Add( auts, NilpotentLieAutomorphism( H, basis, imgs ));
            alpha := alpha ^ fac[i];
        od;
        return rec( auts := auts, rels := fac );
    else
        return rec( auts := [], rels := [] );
    fi;
end;



#############################################################################
##
#F InitNLAAutomorphismGroupOver( L )
##

InitNLAAutomorphismGroupOver := function( L )
    local r, p, npbasis, base, V, norm, part, stab, H, kern, A;

    Info( LieInfo, 1, "Initialize automorphism group: Over ");
    
    # set up
    r := MinimalGeneratorNumber( L );
    p := Characteristic( LeftActingDomain( L ));

    npbasis := NilpotentBasis( L );
    
    
    # get partition stabilizer
    base := IdentityMat( r, GF(p) );
    V    := GF(p)^r;
    norm := NormedVectors( V );
    part := PartitionMinimalOveralgebras( L, npbasis, norm );
	
    stab := PartitionStabilizer( GL( r, p ), part, norm );
	
    # the Frattini Quotient
    H := L/LieDerivedSubalgebra( L );
    kern := InitAgAutosNL( H, p );

    # create aut grp
    A := rec();
    
    #Error();
    
    #stab.mats := List( stab.mats, x -> TransposedMat( x ));
    #stab.perm := List( stab.mats, x -> PermList( List( norm, 
    #                     y -> Position( norm, y*x ))));
    

    A.glAutos := List( stab.mats, x -> NLAAutoOfMat( x, H ) );

    A.glOrder := stab.size;
    A.glOper  := ShallowCopy( stab.perm );
    A.agAutos := kern.auts;
    A.agOrder := kern.rels;
    A.one     := IdentityNilpotentLieAutomorphism(H);
    A.liealg   := H;
    A.size    := A.glOrder * Product( A.agOrder );
    
    
    # try to construct perm rep
    #Error();	
    NiceInitGroupNL( A, true );
    #Error();
    return A;
end;



#############################################################################
##
#F PGCharSubalgebras( L )
##

SomeCharSubalgebras := function( L )
    local  cent, omega;
    
    return LieUpperCentralSeries( L );
end;

#############################################################################
##
#F AbelianQuotientBase( basis, U )
##

AbelianQuotientBase := function( basis, U )
    local r;
    
    
    if 2 in LieNBWeights( basis ) then
        r := Position( LieNBWeights( basis ), 2 ) - 1;
    else
        r := Length( LieNBWeights( basis ));
    fi;
    return List( Basis( U ), x -> Coefficients( basis, x ){[1..r]} );
    
end;

#############################################################################
##
#F InitGlAutosNL( H, mats )
##

InitGlAutosNL := function( H, mats )
    local basis;
    basis := NilpotentBasis( H );
    return List( mats, x -> NilpotentLieAutomorphism( H, basis, List( x, 
                       y -> LinearCombination( basis, y) ) ) );
end;



#############################################################################
##
#F InitNLAutomorphismGroupChar( L ) 
##

InitNLAutomorphismGroupChar := function( L )
    local r, p, chars, bases, S, H, A, z, bas, kern;

    Info( InfoAutGrp, 2, "  init automorphism group : Char ");

    # set up 
    r := MinimalGeneratorNumber( L );
    p := Characteristic( LeftActingDomain( L ));
    z := One(GF(p));
    bas := NilpotentBasis( L );

    # compute characteristic subgroups 
    Info( InfoAutGrp, 3, "  compute characteristic subgroups ");
    chars := SomeCharSubalgebras( L );
    bases := List( chars, x -> AbelianQuotientBase( bas, x ) ) * z;

    # compute the matrixgroup stabilising all subspaces in chain
    Info( InfoAutGrp, 3, "  compute stabilizer ");
    S := StabilizingMatrixGroup( bases, r, p );

    # the Frattini Quotient
    H := L/LieDerivedSubalgebra( L );
    kern := InitAgAutosNL( H, p );

    # the aut group
    A := rec( );
    A.glAutos := InitGlAutosNL( H, GeneratorsOfGroup(S) );
    A.glOrder := Size(S) / Product( kern.rels );
    A.glOper  := GeneratorsOfGroup(S);
    Assert(1,IsInt(A.glOrder));
    A.agAutos := kern.auts;
    A.agOrder := kern.rels;
    A.one     := IdentityNilpotentLieAutomorphism( H );
    A.liealg   := H;
    A.size    := A.glOrder * Product( A.agOrder );

    # try to construct perm rep
    NiceInitGroupNL( A, true );
    return A;
end;



######################################################################
##
#F InitNLAutomorphismGroup( L )
##

InitNLAutomorphismGroup := function( L )
    local r, f, S, H, A, kern;

    Info( LieInfo, 1, "  init automorphism group (full).");

    # set up
    r := MinimalGeneratorNumber( L );
    f := LeftActingDomain( L );
    S := GL( r, f );
    H := L/LieDerivedSubalgebra( L );
    kern := InitAgAutosNL( H, Characteristic( f ));

    # the aut group
    A := rec( );
    A.glAutos := InitGlAutosNL( H, GeneratorsOfGroup(S) );
    A.glOrder := Size(S) / Product( kern.rels );
    A.glOper  := GeneratorsOfGroup( ProjectiveActionOnFullSpace( S, f, r ));
    Assert( 1, IsInt( A.glOrder ));
    A.agAutos := kern.auts;
    A.agOrder := kern.rels;
    A.one     := IdentityNilpotentLieAutomorphism( H );
    A.liealg   := H;
    A.size    := A.glOrder * Product( A.agOrder );

    return A;
end;


