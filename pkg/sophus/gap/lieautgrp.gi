#############################################################################
##
#W  lieautgrp.gi                Sophus package                Csaba Schneider 
##
#W The functions in this file are used to compute the automorphism 
#W group of a nilpotent Lie algebra. Parts of this package use 
#W the autpgrp package by Eick and O'Brien.
##
#H  $Id: lieautgrp.gi,v 1.9 2005/08/09 17:06:07 gap Exp $



#############################################################################
##
#M  LiftAutomorphismToLieCover( <a> )
##  
##  Lifts automorphism <a> to the cover of the domain of <a>.
##  

InstallMethod( 
        LiftAutorphismToLieCover,
        "for nilpotent Lie algebra automorphisms",
        [ IsNilpotentLieAutomorphism ],
function( a )
   
    local d, L, CL, gensCL, imsCL, basL, 
          basCL, hL, newa, mat, T, i, defs;
    
    L := Source( a );
    CL := LieCover( L );

    #Error();

    if a = IdentityNilpotentLieAutomorphism( L ) then
        return IdentityNilpotentLieAutomorphism( CL );
    fi;
    
    basCL := Basis( CL );
    basL := basCL{[1..Dimension( L )]}; 
    d := MinimalGeneratorNumber( L );
    gensCL := List( [1..d], x-> basCL[x] );    

    imsCL := List( a!.mingensetimgs, 
                   x -> LinearCombination( basL, Coefficients( a!.basis, x )));
    
    
    return NilpotentLieAutomorphism( CL, gensCL, imsCL );
 end );



#############################################################################
##
#F  LiftNLAutGrpToLieCover( <A> )
##  
##   <A> is the automorphism group record of a nilpotent Lie algebra. Lifts
##   the generators of <A> to the Lie cover, and returns the record so 
##   obtained.

LiftNLAutGrpToLieCover := function( A )
        
    return rec( 
           glAutos := List( A.glAutos, x -> LiftAutorphismToLieCover( x )),
           glOper := A.glOper,
           glOrder := A.glOrder,     
           agAutos := List( A.agAutos, x -> LiftAutorphismToLieCover( x )),
           agOrder := A.agOrder,
           one := IdentityNilpotentLieAutomorphism( LieCover( A.liealg )),
           liealg := LieCover( A.liealg ),     
           size := A.size );
    
end;




#############################################################################
##
#M  LinearActionOnMultiplicator( <a> )
##  
##  Computes the action of <a> on the multiplicator. This is uniquely 
##  determined by <a>.
##  

InstallMethod( 
        LinearActionOnMultiplicator,
        "for nilpotent Lie algebra automorphisms",
        [ IsNilpotentLieAutomorphism ],
function( a  )
    local C, M, mat, B, i, b, L;
    
    L := Source( a );
    
    C := LieCover( L ); 
    M := LieMultiplicator( C );
    B := Basis( M );
    b := LiftAutorphismToLieCover( a );
    
    mat := [];
    for i in B do
        Add( mat, Coefficients( B, i^b ));
    od;
    
    ConvertToMatrixRep( mat );
    a!.mat := Immutable( mat );
    
end );
  


#############################################################################
##
#F LinearActionOfGroupOnMultiplier( <A> )
## 
##  Computes the matrix group induced by the action of the automorphisms
##  in <A> on the multiplicator.

LinearActionpOfGroupOnMultiplier := function( A  )
    local aut, L;
    
    if A.glAutos <> [] then 
        L := Source( A.glAutos[1] );
    else
        L := Source( A.agAutos[1] );
    fi;
    
    
    # add information
    for aut in A.glAutos do
        LinearActionOnMultiplicator( aut );
    od;
    for aut in A.agAutos do
        LinearActionOnMultiplicator( aut );
    od;
    A.field := LeftActingDomain( L );
    A.prime := Characteristic( A.field );
    A.one!.mat := 1;
end;



#############################################################################
##
#F CentralAutosNL( L, N )
## 
## Computes the generators for the central automorphisms.

CentralAutosNL := function( L, N )
    local baseN, baseL, cent, b, i, imgs, aut;

    baseN := Basis(N);
    baseL := NilpotentBasis(L);
    cent := [];
    for b in baseN do
        for i in [1..MinimalGeneratorNumber(L)] do
            imgs := ShallowCopy( baseL );
            imgs[i] := imgs[i] + b;
            aut := NilpotentLieAutomorphism( L, baseL, imgs );
            Add( cent, aut );
        od;
    od;
    return cent;
end;

#############################################################################
##
#F RestrictAutomorphismToQuotient( <A>, <C>, <K> )
## 
## <A> is an automorphism group record of a Lie algebra L and <C> is the cover
## of <L>. <K> is an <A>-invariant quotient of <C>. Computes the induced
## automorphisms on <K>

RestrictAutomorphismsToQuotient := function( A, C, K )
    local L, Q, new, aut, basis, mingensetL, mingensetQ, imgs, h, cent,
          dimL, dimC, M, heads, remaining, T, new_T, newimgs, img, imgcomp, c, row, laut, i;
    
    new := rec();
    
    L := A.liealg;
    dimL := Dimension( L ); dimC := Dimension( C );
    
    M := List( Basis( K ), x->Coefficients( Basis( C ), x ){[dimL+1..dimC]});
    TriangulizeMat( M );
    
    heads := List( M, x->PositionNonZero( x ) + dimL );
    remaining := DifferenceLists( [1..Dimension( C )], heads );
    
    
    T := StructureConstantsTable( Basis( C ));
    new_T := LieQuotientTable( T, M, dimL );
    Q := AlgebraByStructureConstants( LeftActingDomain( L ), new_T );
    
    basis := Basis( Q );
    basis!.weights := C!.pseudo_weights{remaining};
    basis!.definitions := C!.pseudo_definitions{remaining};
    Setter( IsNilpotentBasis )( basis, true );
    
    Setter( NilpotentBasis )( Q, basis );
    Setter( IsLieAlgebraWithNB )( Q, true );
    
    mingensetQ := basis{[1..MinimalGeneratorNumber( Q )]};
    mingensetL := NilpotentBasis( L ){[1..MinimalGeneratorNumber( L)]};
        
    new.glAutos := [];
    for aut in A.glAutos do 
        if aut <> IdentityNilpotentLieAutomorphism( A.liealg ) then
            laut := LiftAutorphismToLieCover( aut );
            imgs := laut!.mingensetimgs; 
            imgs := List( imgs, x->Coefficients( Basis( C ), x ));
            newimgs := [];
            for img in imgs do
                imgcomp := Coeff2Compact( img );
                for i in Intersection( imgcomp[1], heads )  do
                    row := M[Position( heads, i )];
                    c := Coeff2Compact( row );
                    RemoveElmList( c[1], 1 );
                    RemoveElmList( c[2], 1 );
                    c[1] := c[1] + Dimension( L );
                    c[2] := -imgcomp[2][Position( imgcomp[1], i )]*c[2];
                    RemoveElmList( imgcomp[2], Position( imgcomp[1], i ));
                    RemoveElmList( imgcomp[1], Position( imgcomp[1], i)); 
                    imgcomp := SumSCT( imgcomp, c );
                od;
                imgcomp := Compact2Coeffs( 
                                   imgcomp, dimC, Zero( LeftActingDomain( L )));
                Add( newimgs, LinearCombination( basis, imgcomp{remaining}));
            od;
            Add( new.glAutos, NilpotentLieAutomorphism( Q, mingensetQ, 
                    newimgs ));
        else
            Print( "Warning: trivial automorphism in the semisimple part\n" );
        fi;
    od;
    
    new.agAutos := [];
    for aut in A.agAutos do 
        if aut <> IdentityNilpotentLieAutomorphism( A.liealg ) then
            laut := LiftAutorphismToLieCover( aut );
            imgs := laut!.mingensetimgs; 
            imgs := List( imgs, x->Coefficients( Basis( C ), x ));
            newimgs := [];
            for img in imgs do
                imgcomp := Coeff2Compact( img );
                for i in Intersection( imgcomp[1], heads )  do
                    row := M[Position( heads, i )];
                    c := Coeff2Compact( row );
                    RemoveElmList( c[1], 1 );
                    RemoveElmList( c[2], 1 );
                    c[1] := c[1] + Dimension( L );
                    c[2] := -imgcomp[2][Position( imgcomp[1], i )]*c[2];
                    RemoveElmList( imgcomp[2], Position( imgcomp[1], i ));
                    RemoveElmList( imgcomp[1], Position( imgcomp[1], i)); 
                    imgcomp := SumSCT( imgcomp, c );
                od;
                imgcomp := Compact2Coeffs( imgcomp, dimC, 
                                   Zero( LeftActingDomain( L )));
                Add( newimgs, LinearCombination( basis, imgcomp{remaining}));
            od;
            Add( new.agAutos, NilpotentLieAutomorphism( Q, 
                    mingensetQ, newimgs ));
        else
            Error( "Warning: trivial automorphism in the soluble part!\n" );
        fi;
    od;
    
        
    new.glOrder := A.glOrder;
    if IsBound( A.glOper ) then
        new.glOper := A.glOper;
    fi;
    new.agOrder := A.agOrder;
    new.liealg := Q;
    new.one := IdentityNilpotentLieAutomorphism( Q );
    new.size := Product( A.agOrder )*A.glOrder;
    new.field := A.field;
    new.prime := A.prime;
    
    cent := CentralAutosNL( Q, 
                    LieLowerCentralSeries( Q )[Length( 
                            LieLowerCentralSeries( Q ))-1]);
    
    Append( new.agAutos, cent );
    Append( new.agOrder, List( cent, x-> Characteristic( LeftActingDomain( L ))));
    new.size := new.glOrder*Product( new.agOrder );
    
    return new;
end;


#############################################################################
##
#A AutomorphismGroupOfNilpotentLieAlgebra( <L> )
## 
## Returns the automorphism group of <L> in a hybrid record format.

InstallMethod( 
        AutomorphismGroupOfNilpotentLieAlgebra,
        "for nilpotent Lie algebras",
        [ IsLieAlgebra ],
        function( L )
    local r, basis, first, n, str, A, F, Q, Q1, i, s, t, C, N, M, U, B,
          baseU, baseN, epi, interrupt, f, h, S, j, rem;
    
    t := Runtime();
    
    if not IsLieNilpotent( L ) then
	TryNextMethod();
    fi;
    
    # catch the trivial case
    if Size( L ) = 1 then return Group( [], IdentityMapping(L) ); fi;

    # compute special NilpotentBasis
    
    basis := NilpotentBasis( L );
        
    S := LieLowerCentralSeries( L );
    
    first := [1];
    for i in [2..Length( basis )] do
        if LieNBWeights( basis )[i] > LieNBWeights( basis )[i-1] then
            Add( first, i );
        fi;
    od;
    
    n := Length( basis );
    r := MinimalGeneratorNumber( L );
    f := LeftActingDomain( L );
    
    A := GeneratorsOfGroup( GL( r, f ));
    
    Info( LieInfo, 1, 
          "Precomputation took ", Runtime() - t );
    t := Runtime();

    if  r < 4 then 
        A :=InitNLAutomorphismGroup( L );
    else 
        A := InitNLAAutomorphismGroupOver( L );
    fi;
    
    # init automorphism group - compute Aut(L/L_1)
    
    Info( LieInfo, 1, 
          "Init AutGrp took ", Runtime() - t );
    t := Runtime();
    
    # loop over remaining steps
    for i in [2..Length( LieLowerCentralSeries( L )) - 1] do
        
        Q := A.liealg;
        Q1 := L/S[i+1];
        
        Info( LieInfo, 1, "Computing quot took ", Runtime() - t );
        t := Runtime();
        
        s := first[i];
        t := Runtime();

        # the cover
        C := LieCover( Q );
        M := LieMultiplicator( C );
        N := LieNucleus( C );
        
        h := AlgebraHomomorphismByImagesNC( C, Q1, 
        Basis( C ){[1..r]}, NilpotentBasis( Q1 ){[1..r]} );
        U := Kernel( h );
        
        # induced action of A on M
        Info( LieInfo, 1, "Computing cover info took ", Runtime() - t );
        t := Runtime();
        LinearActionpOfGroupOnMultiplier( A );
        
        # compute stabilizer
        Info( LieInfo, 2, "  computing stabilizer of U");
        baseN := Basis(N);
        baseU := Basis(U);
        baseN := List( baseN, x -> Coefficients( Basis( M ), x ));
        baseU := List(baseU, x -> Coefficients( Basis( M ), x ));
        baseU := EcheloniseMat( baseU );
        
        Info( LieInfo, 1, "Computing matrix action took ", Runtime() - t );
        t := Runtime();
	
	#Error();

        PGOrbitStabilizer( A, baseU, baseN, false );
                        
        A.size := A.glOrder*Product( A.agOrder );
        
        rem := [];
        
        for j in [1..Length( A.glAutos )] do
            if A.glAutos[j] = IdentityMapping( A.liealg ) then
                Add( rem, j );
            fi;
        od;
        
        rem := DifferenceLists( [1..Length( A.glAutos )], rem );
        A.glAutos := A.glAutos{rem}; 
        if IsBound( A.glOper ) then
            A.glOper := A.glOper{rem};	
        fi;
        
        Info( LieInfo, 1, "Computing orbit and stabiliser took ", Runtime() - t );
        t := Runtime();
	A := RestrictAutomorphismsToQuotient( A, C, U );
        
        Info( LieInfo, 1, "Updating autgroup took ", Runtime() - t );
    od;
    
    return A;
end );



#############################################################################
##
#A AutomorphismGroup( <L> )
## 
## Returns the automorphism group of <L> as a group generated by 
## automorphisms.
             
InstallMethod( 
        AutomorphismGroup,
        "for nilpotent Lie algebras",
        [ IsLieAlgebra ],
        function( L )
	local A, gens, auts, i, f, g;

	if not IsLieNilpotentOverFp( L ) then
		TryNextMethod();
	fi;
	
	A := AutomorphismGroupOfNilpotentLieAlgebra( L );
	f := AlgebraHomomorphismByImages( L, A.liealg, NilpotentBasis( L ), 
					  NilpotentBasis( A.liealg ));
	g := InverseGeneralMapping( f );

	gens := NilpotentBasis( L ){[1..MinimalGeneratorNumber( L )]};
	auts := [];
	for i in A.glAutos do
		Add( auts, AlgebraHomomorphismByImagesNC( 
			   L, L, gens, List( gens, x->x^(f*i*g))));
	od;
	
	for i in A.agAutos do
		Add( auts, AlgebraHomomorphismByImagesNC( 
			   L, L, gens, List( gens, x->x^(f*i*g))));
	od;
	
return Group( auts );
end );






