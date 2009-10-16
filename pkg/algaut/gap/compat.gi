CompatiblePairsOfAlgebraBimodule := function( M )
    local Coeffs, ConvertGroupElement, DirectProductIntoMatrix, 
          MatrixIntoDirectProduct, A, V, autA, autV, 
          F, H, BH, G, gens, rep, mats, S;
    
    Coeffs := function( hom )
        local vec, i;
        
        vec := [];
        
        for i in Basis( A ) do
            Append( vec, Coefficients( Basis( End( F, V )), i^hom ));
        od;
        
        return vec;
    end;
    
    #-------------------
    #
    # a function to convert a group element into a matrix
    
    
    ConvertGroupElement := function( g )
        local b, ims, endims, a, f;
        
        ims := [];
        
        for b in BH do
            endims := [];
            for a in Basis( A ) do
                Append( endims, 
                        Coefficients( Basis( End( F, V )), 
                                CompositionMapping( g[2]^-1, 
                        (a^(g[1]^-1))^b, g[2] )));
            od;
            Add( ims, endims );
        od;
        
        return ims;
    end;
    
    #-----------------------
    
    DirectProductIntoMatrix := function( g )
        local gens, b1, b2, mat1, mat2;
        
        b1 := Basis( Source( g[1] ));
        b2 := Basis( Source( g[2] ));
        
        mat1 := List( b1, x->Coefficients( b1, x^g[1] ));
        mat2 := List( b2, x->Coefficients( b2, x^g[2] ));
        
        return DirectSumMat( mat1, mat2 );
    end;
    
    MatrixIntoDirectProduct := function( m )
        local gens1, gens2, d1, d2, m1, m2, b1, b2;
        
        d1 := Dimension( A );
        d2 := Dimension( V );
        m1 := List( m{[1..d1]}, x->x{[1..d1]} );
        m2 := List( m{[d1+1..d1+d2]}, x->x{[d1+1..d1+d2]} );
        
        b1 := Basis( A );
        b2 := Basis( V );
        
        gens1 := List( b1, x->LinearCombination( b1, 
                         Coefficients( b1, x )^m1 ));
        gens2 := List( b2, x->LinearCombination( b2, 
                         Coefficients( b2, x )^m2 ));
        
        return LeftModuleHomomorphismByImages( A, A, Basis( A ),
                       gens1 )^Embedding( G, 1 )*
                 LeftModuleHomomorphismByImages( V, V, Basis( V ),
                         gens2 )^Embedding( G, 2 );
    end;

        
    A := AActingAlgebra( M );
    F := LeftActingDomain( A );
    V := Bimodule( M );
    autA := AutomorphismGroup( A ); autV := AutomorphismGroup( V );
    
    H := Hom( F, A, End( F, V ));
    BH := Basis( H );
    G := DirectProduct( autA, autV );
    gens := List( GeneratorsOfGroup( G ), 
                  ConvertGroupElement );
    
    mats := List( GeneratorsOfGroup( G ), DirectProductIntoMatrix );
    
    rep := GroupHomomorphismByImagesNC( Group( mats ), Group( gens ), mats,
                   gens );
    
    S := Intersection( Stabilizer( Group( gens ), Coeffs( RRightAction( M ))),
                 Stabilizer( Group( gens ), Coeffs( LLeftAction( M ))));
    
    S := Group( List( GeneratorsOfGroup( S ), x->PreImagesRepresentative( 
                 rep, x )));
    
    return  Group( List( GeneratorsOfGroup( S ), MatrixIntoDirectProduct ));

end;

IsCompatiblePair := function( M, x )
    local b, R, L, A;
    
    R := RRightAction( M );
    L := LLeftAction( M );
    A := AActingAlgebra( M );
    
    for b in Basis( A ) do
        if not (b^x[1])^R = CompositionMapping( x[2]^-1, 
                   b^R, x[2] ) then
            return b;
        fi;
    od;
    
    for b in Basis( A ) do
        if not (b^x[1])^L = CompositionMapping( x[2]^-1, 
                   b^L, x[2] ) then
            return b;
        fi;
    od;
    
    
    return true;
end;
