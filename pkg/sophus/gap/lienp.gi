#############################################################################
##
#W  lienp.gi                 Sophus package                  Csaba Schneider 
##
#W  Computing a nilpotent basis for a Lie algebra.
##
#H  $Id: lienp.gi,v 1.7 2005/08/22 13:13:09 gap Exp $


######################################################################
## 
#P IsLieAlgebraWithNB( <L> )
## 
## returns true if <L> has a nilpotent basis.

InstallMethod( 
        IsLieAlgebraWithNB,
        "for nilpotent Lie algebras", 
        [ IsLieNilpotentOverFp ],
        function( L )
    
    if IsBound( L!.NilpotentBasis ) then
        return true;
    else
        return false;
    fi;
end );


######################################################################
##
#A NilpotentBasis( <L> )
##
## The function computes a nilpotent basis for a nilpotent Lie algebra.
## See the manual for explanation

InstallMethod( 
        NilpotentBasis,
        "for nilpotent Lie algebras",
        [ IsLieAlgebra ],
        function( L )
    
    local 
      i, j, k,            # for indexing
      f,                  # natural homom onto a quot of lcs
      Q,                  # the image of f
      newbas,             # the new basis
      defs,               # definition of the new basis elements 
      weight,             # the weight vector
      choosebasis,        # a function to choose a basis from a spanning set
      firstlength,        # number of weigtht 1 generators
      lastlength,         # the no. of generators with the last computed weight
      indices,            # indices of basis elements in a spanning set
      class,              # nilpotency class of L
      list,               # list to store coeffs
      npb,                # the new basis
      S;                  # lower central series
    
        
    
    choosebasis := function( S, s )   # S is a vectorspace s is a spanning set
        local i, bas, S0, indices;   
        
        bas := []; indices := [];
        
        S0 := Subspace( S, [] );
        for i in [1..Length( s )] do
            if not s[i] in S0 then
                Add( bas, s[i] );
                Add( indices, i );
                S0 := Subspace( S, bas );
            fi;
        od;
        
        return indices;
    end;
    
    if not IsLieNilpotentOverFp( L ) then
	TryNextMethod();
    fi;

    S := LieLowerCentralSeries( L );
    class := Length( S ) - 1;
    
    f := NaturalHomomorphismByIdeal( L, S[2] );
    Q := Image( f, L );
    newbas := List( BasisVectors( Basis( Q )), 
                    x->PreImagesRepresentative( f, x ));
    defs := List( [1..Dimension( Q )], x -> 0 );    
    weight := List( [1..Dimension( Q )], x -> 1 );
    
    firstlength := Dimension( Q ); lastlength := Dimension( Q );
    
    for i in [2..class] do
        f := NaturalHomomorphismByIdeal( S[i], S[i+1] );
        Q := Image( f, S[i] );
        list := [];
        
        for j in [1..firstlength] do
            for k in [ Maximum( j+1, Length( newbas ) - lastlength + 1 )..
                    Length( newbas )] do
                Add( list, [ [j, k], newbas[j]*newbas[k]]);
            od;
        od;
        indices := choosebasis( Q, List( list, x->Image( f, x[2] )));
        for k in indices do
            Add( newbas, list[k][2] );
            Add( defs, list[k][1] );
            Add( weight, i );
        od;
        lastlength := Length( indices );
    od;
    
    
    npb := RelativeBasisNC( Basis( L ), newbas );
    npb!.definitions := defs; npb!.weights := weight;
    npb!.isNilpotentBasis := true;
    
    return npb;
    
end );



######################################################################
##
#P IsNilpotentBasis( <B> )
##

InstallMethod( 
        IsNilpotentBasis,
        "for bases of Lie algebras",
        [ IsBasis ],
        function( B )
    
    if IsBound( B!.isNilpotentBasis ) then 
        return B!.isNilpotentBasis; 
    else 
        return false;
    fi;
    
end );


######################################################################
## 
#A LieNBDefinitions( B )
##
## gets the definitions for a nilpotent basis <B>
##

InstallMethod( 
        LieNBDefinitions,
        "for NB bases of Lie algebras",
        [ IsNilpotentBasis ],
        function( B )
    
    return B!.definitions;
end );


######################################################################
## 
#A LieNBWeights( <B> )
## Gets the weights from a NilpotentBasis

InstallMethod( 
        LieNBWeights,
        "for NB bases of Lie algebras",
        [ IsNilpotentBasis ],
        function( B )
    
    return B!.weights;
end );




