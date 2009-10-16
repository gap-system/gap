#############################################################################
##
#W  lieisom.gi                Sophus package                 Csaba Schneider 
##
#W  This file contains the functions for isomorphism testing between 
#W  nilpotent Lie algebras.
##
#H  $Id: lieisom.gi,v 1.11 2005/08/30 06:53:29 gap Exp $




######################################################################
##
#F  RestrictIsomorphismToLieMultiplicator( <C>, <g> )
## 

RestrictIsomorphismToLieMultiplicator := function( C, g )
    local M, BM, BC;
    
    M := LieMultiplicator( C ); 
    BM := Basis( M ); BC := NilpotentBasis( C );
    
    return List( BM, x -> Coefficients( BM, 
                   LinearCombination( BC, Coefficients( BC, x )*g )));
    
end;



######################################################################
##
#F  LiftIsomorphismToLieCover( <L>, <K>, a )

InstallMethod( 
        LiftIsomorphismToLieCover,
        "for nilpotent Lie algebras with nilpotent presentation",
        [ IsLieAlgebra, IsLieAlgebra, IsMatrix ],
        function( L, K, a )
    
    local d, CL, CK, gensCL, gensCK, imsCL, basL, basK, 
          basCL, basCK, hL, hK, newa, mat, T, i, defs;
    
    CL := LieCover( L );
    CK := LieCover( K );
    
    basL := NilpotentBasis( L ); basCL := NilpotentBasis( CL );
    basK := NilpotentBasis( K ); basCK := NilpotentBasis( CK );
    
    d := MinimalGeneratorNumber( L );
    
    hL := AlgebraHomomorphismByImagesNC( CL, L, 
                  List( [1..d], x->basCL[x] ), 
                  List( [1..d], x->basL[x] ));        
    
    hK := AlgebraHomomorphismByImagesNC( CK, K, 
                  List( [1..d], x->basCK[x] ), 
                  List( [1..d], x->basK[x] ));        
    
    gensCL := List( [1..d], x-> basCL[x]);
    
    imsCL := List( gensCL, x -> Image( hL, x ));
    imsCL := List( imsCL, x -> 
                   LinearCombination( basK, Coefficients( basL, x )^a ));
    
    imsCL := List( imsCL, x -> PreImagesRepresentative( hK, x ));
    
    mat := List( imsCL, x->Coefficients( basCK, x ));
	
    defs := LieNBDefinitions( basCK );

    for i in [d+1..Dimension( CK )] do
        Add( mat, Coefficients( basCK, 
                LinearCombination( basCK, 
                        mat[defs[i][1]])*
                LinearCombination( basCK, 
                        mat[defs[i][2]])));
    od;
    
    if Determinant( mat ) = 0*mat[1][1] then
        Error( "not an invertible matrix" );
    fi;
    
#    if not CheckAutomorphisms( [mat] ) then
#       Error( "Wrong automorphism!" );
#    fi;
    
    return mat;
end );

######################################################################
##
#F ApplyAut( <M>, <U>, <g> ) 

ApplyAut := function( M, U, g )
    local basU, basM;
    
    basU := Basis( U );
    basM:= Basis( M );
    
    return Subspace( M, List( basU, x -> LinearCombination( basM, 
                   Coefficients( basM, x )^g )));
    
end;




######################################################################
##
#O AreIsomorphicNilpotentLieAlgebras( <L>, <K> )
## 
## Decides if two nilpotent Lie algebras are isomorphic

 InstallMethod( 
         AreIsomorphicNilpotentLieAlgebras,
         "for nilpotent Lie algebras with nilpotent presentation",
         [ IsLieAlgebra, IsLieAlgebra ],
         function( L, K )

     local SL, d, SK, QL, QK, A, A1, CL, CK, fK, KK, fL, KL, Li, F, KKim,
           Q1L, Q1K, O, S, OS, r, R, newbas, bv, newiso, isoKL, i, ii, VAut, s, x, y, t, LM, ML, h, G, G1, npbas, f;

     
     VAut := function( L, x, y )
        local basL, d, S, n,  ims, T, i, defs;
        
        basL := NilpotentBasis( L );
        d := MinimalGeneratorNumber( L );
        S := LieLowerCentralSeries( L );
        n := Dimension( L/S[ Length( S ) - 1 ]);
        
        ims := List( [1..d], x->basL[x] );
        
        ims[x] := basL[x] + basL[n+y];
        
        defs := LieNBDefinitions( basL );
        
        for i in [d+1..Dimension( L )] do
            ims[i] := ims[defs[i][1]]*ims[defs[i][2]];
        od;
        
        ims := List( ims, z->Coefficients( basL, z ));
        
        return ims;
        
    end;
    
    t := Runtime();

    if not IsLieNilpotentOverFp( L ) or not IsLieNilpotentOverFp( K ) then
		TryNextMethod();
    fi;
    
    F := LeftActingDomain( L );
    SL := LieLowerCentralSeries( L );
    SK := LieLowerCentralSeries( K );
    
    d := MinimalGeneratorNumber( L );
     
    if List( SL, x->Dimension( x )) <> List( SK, x->Dimension( x )) then 
        return false;
    fi;
    
    if Length( SL ) = 2 then return true; fi;
   
    Q1L := L/SL[2]; Q1K := K/SK[2];
    
    A := GeneratorsOfGroup( GL( d, F ));
    
    for i in [2..Length( SL ) - 1] do
        
        QL := Q1L; QK := Q1K; Q1L := L/SL[i+1]; 
        
        f := NaturalHomomorphismByIdeal( K, SK[i+1] );
        Q1K := Images( f );
        
        CK := LieCover( QK ); CL := LieCover( QL ); 
        ML := LieMultiplicator( CL );
        
        fK := AlgebraHomomorphismByImagesNC( CK, Q1K, 
                      List( [1..d], x->NilpotentBasis( CK )[x] ), 
                      List( [1..d], x->NilpotentBasis( Q1K )[x] ));
        
        KK := Kernel( fK );
        
        fL := AlgebraHomomorphismByImagesNC( CL, Q1L, 
                      List( [1..d], x->NilpotentBasis( CL )[x] ), 
                      List( [1..d], x->NilpotentBasis( Q1L )[x] ));
        
        KL := Subspace( ML, Basis( Kernel( fL ))); 
        
        KKim := Subspace( ML, List( Basis( KK ), 
                        x->LinearCombination( Basis( CL ),
                                Coefficients( Basis( CK ), x ))));
        
        A := List( A, x->LiftIsomorphismToLieCover( QL, QL, x ));
        
#        if not CheckAutomorphisms( A ) then
#            Error( "Wrong Automorphisms!!!" );
#        fi;
        
        Info( LieInfo, 1, "Time to set up computation: ", Runtime() - t );
        t := Runtime();
        
        OS := OrbitStabilizer( Group( A ), KL, function( U, g ) 
            return ApplyAut( ML, U, RestrictIsomorphismToLieMultiplicator( CL, g )); end); 
            
        O := OS.orbit; 
        S := GeneratorsOfGroup( OS.stabilizer );
            
        
        Info( LieInfo, 1, "Time to compute orbit and stabiliser: ", 
              Runtime() - t );
        t := Runtime();
        
        if KKim in O then
            isoKL := RepresentativeAction( Group( A ), O, 
                             KL, KKim,  function( U, g ) 
                return ApplyAut( ML, U, RestrictIsomorphismToLieMultiplicator( CL, g )); end); 
        else
                return false;
        fi;
        
        newiso := [];
        
        for ii in [1..Dimension( Q1K )] do
            bv := PreImagesRepresentative( fL, NilpotentBasis( Q1L )[ii]);
            bv := LinearCombination( NilpotentBasis( CK ), 
                          Coefficients( NilpotentBasis( CL ), bv )*isoKL );
            bv := Image( fK, bv );
            Add( newiso, bv );
        od;
	
        npbas := RelativeBasisNC( Basis( Q1K ), newiso );
        npbas!.weights := LieNBWeights( NilpotentBasis( Q1L ));
        npbas!.definitions := LieNBDefinitions( NilpotentBasis( Q1L ));
        Setter( IsNilpotentBasis )( npbas, true );
        Setter( NilpotentBasis )( Q1K, npbas );
        if StructureConstantsTable( NilpotentBasis( Q1L ) ){[1..Dimension( Q1L )]} <> 
           StructureConstantsTable( NilpotentBasis( Q1K ) ){[1..Dimension( Q1K )]} then
            Error( "Structure constants do not match" );
        fi;
        
        
        Info( LieInfo, 1, "Time to find isomorphism: ", Runtime() - t );
        t := Runtime();
        
        newbas := 
          List( NilpotentBasis( Q1K ), x->PreImagesRepresentative( f, x ));
        Append( newbas, BasisVectors( Basis( SK[i+1] )));

        K := LieAlgebraByStructureConstants( F, 
                     StructureConstantsTable( Basis( K, newbas )));
        SK := LieLowerCentralSeries( K );
        
        A := List( S, x -> List( NilpotentBasis( Q1L ), 
                     y -> Coefficients( NilpotentBasis( Q1L ), 
                          Image( fL, LinearCombination( NilpotentBasis( CL ), 
                          Coefficients( NilpotentBasis( CL ), 
                          PreImagesRepresentative( fL, y ))^x )))));        
        
        Info( LieInfo, 1, "Time to lift ", Length( A ), " automorphisms: ", Runtime() - t );
        t := Runtime();
        
        s := Dimension( Q1L ) - Dimension( QL );
        
        for x in [1..d] do
            for y in [1..s] do
                Add( A, VAut( Q1L, x, y ));
            od;
        od;
        
#        if not CheckAutomorphisms( A ) then
#            Error( "Wrong Automorphisms!!" );
#        fi;
        
        Info( LieInfo, 1, "Time to finish cycle: ", Runtime() - t );
        Info( LieInfo, 1, "Size of autgroup: ", Size( Group( A )));
        t := Runtime();
    od;
    
    return true;
    
end);


