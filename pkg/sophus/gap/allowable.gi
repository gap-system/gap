#############################################################################
##
#W  allowable.gi             Sophus package                   Csaba Schneider 
##
#W  The functions in this file implement the procedures that find the orbits
#W  on the set of allowable subgroups. Each subgroup is represented by a label
#W  as explained by O'Brien. Then we compute the orbits on the set of labels.
#W  The algorithm is not explained here, see [O'Brien, J. Symbolic Comput.
#W  vol. 9, pp. 677-698].
##
#H  $Id: allowable.gi,v 1.6 2005/08/09 17:06:07 gap Exp $

#############################################################################
##
#F ReduceGenSet( <G> )
##  
##  Tries to reduce a generating set for a group G. This function is there
##  only for experimenting. If FIND_MIN_GEN_SET is set 'true' then this
##  function is called before the orbit computation. The generating set 
##  it returns is not necessarily minimal!

ReduceGenSet := function( G )
    local i, E, gens, newgens, PG, f, min, x, y;
    
    Info( LieInfo, 1, "Computing minimal set of generators." );
    
    E := Elements( DefaultFieldOfMatrixGroup( G )^DimensionOfMatrixGroup( G ));
    
    gens := GeneratorsOfGroup( G );
    
    newgens := List( gens, x->PermList( List( E, y->Position( E, y*x ))));
            
    PG := Group( newgens );
    
    f := GroupHomomorphismByImagesNC( PG, G, newgens, gens );
    
    
    if IsSolvable( PG ) then
        min := List( MinimalGeneratingSet( PG ), x->x^f );
    else
	Info( LieInfo, 1, "G not soluble... Trying random search." );
        repeat
            x := Random( PG );
            y := Random( PG );
        until Group( x, y ) = PG;
        min := [x^f,y^f];
    fi;
    
    
    Info( LieInfo, 1, "Min gen set found with ", Length( min ), " generators." );
    
    return Group( min );
end;



#############################################################################
##
#F ReduceGenSet2( <G> )
##  
##  A different function to do pretty much the same as the previous one.
##  It is used for experimenting.

ReduceGenSet2 := function( G )
    local i, gens, newgens, length, maxel, newsize, maxsize;

    Info( LieInfo, 1, "Computing small set of generators." );

    gens := [ Random( G )];
    newgens := ShallowCopy( gens );	
    
    repeat
	 length := Length( newgens );
	 maxsize := 1;
	 for i in [1..20] do
             newgens[length+1] := Random( G );
             if Size( Group( newgens )) = Size( G ) then
		Info( LieInfo, 1, "Small gen set found with ", Length( newgens ), " generators." );
		return Group( newgens );
	     fi;
	     newsize := Size( Group( newgens ));
	     if newsize > maxsize then 
		maxsize := newsize;
		maxel := newgens[length+1];
	     fi;
	 od;
	 newgens[length+1] := maxel;
    until false;


    Info( LieInfo, 1, "Min gen set found with ", Length( gens ), " generators." );

    return Group( gens );
end;



#############################################################################
##
#F HeadVector( <v> )
##  

HeadVector := function( v )
    local i;
    
    for i in [1..Length( v )] do
        if v[i] <> 0*v[1] then
            return i;
        fi;
    od;
    
    return fail;
end;



#############################################################################
##
#F DefinitionSet( <M>, <N> )
##  
##  Returns the set of definitions with respect to a vectorspace M and its
##  subspace N. 

DefinitionSet := function( M, N )
    local dim, F, R, U, basU, basN, defset, eqset, coeffs, i;
    
    dim := Length( Basis( M )[1] );
    
    if Dimension( M ) + Dimension( N ) - Dimension( Intersection( M, N )) <> 
       dim then
        Error( "M is not an allowable subgroup" );
    fi;
    
    F := LeftActingDomain( M );
    R := F^dim;
    
    U := M;
    basU := ShallowCopy( BasisVectors( Basis( U )));
    basN := Basis( N );
    defset := [];
    eqset := [];
    
    for i in [1..Length( basN )] do
        if basN[i] in U then
            coeffs := Coefficients( RelativeBasis( Basis( U ), basU ), 
                              basN[i] );
            Add( eqset, coeffs{[Dimension( M )+1..Length( coeffs )]});
        else
            Add( defset, basN[i] );
            Add( basU, basN[i] );
            U := Subspace( R, basU, "basis" );
        fi;
    od;
        
    return rec( defset := defset, eqset := eqset );
end;


#############################################################################
##
#F NrOfAllowablePositions( <comb>, <dim2> )
##  
##  Computes the number of allowable positions.

NrOfAllowablePositions := function( comb, dim2 )
        
    return Sum( List( comb, x->dim2-x ))-Sum( [1..Length( comb )-1], x->x );
end;



#############################################################################
##
#F IsAllowablePositions( <comb>, <pos> )
##  
##  returns true if <pos> is allowable with respect to <comb>.

IsAllowablePosition := function( comb, pos )
    
    if pos[2] <= comb[pos[1]] or pos[2] in comb then
        return false;
    else 
        return true;
    fi;
end;


#############################################################################
##
#F NrsWithDefsets( <dim1>, <dim2>, <dimN>, <p> )
##  

NrsWithDefsets := function( dim1, dim2, dimN, p )
    
    local combs, list, comb;
    
    combs := Combinations( [1..dimN], dim1 ); 
    
    list := [];
    for comb in combs do
        Add( list, p^NrOfAllowablePositions( comb, dim2 ));
    od;
    
    return list;
    
end;

#############################################################################
##
#F ComputeAllowableInfo( <dim1>, <dim2>, <dimN>, <p> )
##  
##  Computes the information that is necessary for the computation of 
##  the orbits on the set of allowable subgroups.
##

ComputeAllowableInfo := function( dim1, dim2, dimN, p )
    
    local allowablepositions, list, comb, i, j, 
          combinations, nrswithdefsets, nrsofallowablepositions;
    
    combinations := Combinations( [1..dimN], dim1 );
    nrswithdefsets := NrsWithDefsets( dim1, dim2, dimN, p );
        
    allowablepositions := [];
    
    for comb in combinations do
        list := [];
        for i in [1..dim1] do
            for j in [1..dim2] do
                if IsAllowablePosition( comb, [i,j] ) then
                    Add( list, [i,j] );
                fi;
            od;
        od;
        Add( allowablepositions, list );
    od;
        
    return rec( dim1 := dim1, 
                dim2 := dim2, 
                p := p,
                combinations := combinations,
                nrswithdefsets := nrswithdefsets,
                nrsofallowablepositions := List( allowablepositions, Length ), 
                allowablepositions := allowablepositions );
end;

#############################################################################
##
#F StandardMatrix( <M>, <N> )
##  
##  Computes the standard matrix of the subspace <M> with respect to the 
##  nucleus <N>.
##

StandardMatrix := function( M, N )
    local dim, F, R, Defspace, eqset, gens, imgs, count, basM, theta, 
          i, defset, defs;
    
    basM := Basis( M );
    dim := Length( basM[1] );
    
    if Dimension( M ) + Dimension( N ) - Dimension( Intersection( M, N )) <> 
       dim then
        Error( "M is not an allowable subgroup" );
    fi;
    
    F := LeftActingDomain( M );
    R := F^dim;
    
    defset := DefinitionSet( M, N );
    defs := defset.defset;
    Defspace := Subspace( R, defs, "basis" );
                         
    eqset := defset.eqset;
    
    gens := DifferenceLists( Basis( N ), defs );
    imgs := List( [1..Length( gens )], x -> LinearCombination( 
                    RelativeBasis( Basis( Defspace ), defs ), eqset[x] ));
       
    Append( gens, defs );
    Append( imgs, defs );
     
    count := 1;
    repeat
        if not basM[count] in Subspace( R, gens ) then
            Add( gens, basM[count] );
        fi;
        count := count + 1;
    until Length( gens ) = dim;
    
    for i in [1..dim - Length( imgs )] do
        Add( imgs, Zero( R));
    od;
    
    theta := LeftModuleHomomorphismByImages( R, 
                     Subspace( R, Defspace ), gens, imgs );
    
    return TransposedMat( List( [1..dim], x-> Coefficients( Basis( Defspace ), 
                   Basis( R )[x]^theta )));
end;


#############################################################################
##
#F LabelOfMatrix( <M>, <info> )
##  
##  Computes the label of the matrix <M>. <info> contains the the information
##  necessary for the computation of the label.
##

LabelOfMatrix := function( M, info )
    local p, defset, defsetpos, list, i, j, number, offset;
    
    p := info.p;
    defset := List( M, x->HeadVector( x ));
    defsetpos := Position( info.combinations, defset );
    
    list := [];
    
    for i in info.allowablepositions[defsetpos] do
        Add( list, IntFFE( M[i[1]][i[2]] ));
    od;
    
    number := 0;
    for i in [0..Length( list )-1] do
        number := number + list[i+1]*p^i;
    od;
    
    offset := Sum( info.nrswithdefsets{[1..defsetpos-1]});
        
    return offset + number;
end;

CharValue := function( c )
    return Position( [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ], c ) - 1;
end;


#############################################################################
##
#F MatrixOfLabel( <label>, <info> )
##  
##  Computes the matrix of the label <label>. <info> contains the the 
##  information necessary for the computation of the matrix.
##

MatrixOfLabel := function( label, info )
    local number, defset, positions, entries, i, M, j, count, 
          nodefset, sum, nrs, offset, dim1, dim2, p, e, z;
    
    nrs := info.nrswithdefsets;
    p := info.p; dim1 := info.dim1; dim2 := info.dim2;
    e := Z(p)^0; z := 0*Z(p);
    
    
    sum := 0;
    i := 1;
    repeat
        sum := sum + nrs[i];
        i := i+1;
    until sum > label;
    
    nodefset := i-1;
    
    defset := info.combinations[nodefset];
    offset := Sum( info.nrswithdefsets{[1..nodefset-1]});
    number := label-offset;

    entries := List( CoefficientsQadic( number, p ), 
                       x->x*Z(p)^0 );
    
    
    Append( entries, List( [1..info.nrsofallowablepositions[nodefset]-
            Length( entries )], x->0*Z(p)));
    count := 1;
    
        
    M := e*NullMat( dim1, dim2 );
    for i in [1..dim1] do
        M[i][defset[i]] := e;
    od;
    
    count := 1;
    for i in info.allowablepositions[nodefset] do
        M[i[1]][i[2]] := entries[count];
        count := count + 1;
    od;
        
    return M;
end;



#############################################################################
##
#F PermutationOnAllowableSubgroups( <g>, <info> )
##  
##  <g> is a matrix acting on the multiplicator. <g> permutes the allowable
##  subgroups, and this function computes the permutation corresponding to.
##  <g>. <info> contains information necessary for this computation.
##

PermutationOnAllowableSubgroups := function( g, info )
    local els, remaining, first, list, lists, i, mat;
    
    els := [0..Sum( info.nrswithdefsets )-1];
        
    list := [];
    
   for i in els do
       mat := MatrixOfLabel( i, info )*g;
       TriangulizeMat( mat );
       mat := LabelOfMatrix( mat, info );
       Add( list, mat );
       if i mod 10000  = 0 then Print( i, "\n" ); fi; 
   od;
   return list;
end;


AllowableSubgroupByMatrix := function( mat )
    local dim_dom, dim_im, p, domain, image, basis_domain, ims;

    dim_dom := Length( mat[1] );
    dim_im  := Length( mat );
    p := Characteristic( FieldOfMatrixList( [mat] ));
    domain := GF(p)^dim_dom;
    image  := GF(p)^dim_im;
    basis_domain := Basis( domain );
    ims := List( basis_domain, x->mat*x );

    return Kernel( LeftModuleHomomorphismByImages( domain, image,
                   basis_domain, ims ));
end;

#############################################################################
##
#F OrbitsOfAllowableSubgroups( <dim1>, <dim2>, <dimN>, <p>, <G> )
##
##  <dim1> is the dimension of the multiplicator, <dim2> is the stepsize,
##  <dimN> is the dimension of the nucleus, <p> is the prime, <G> is
##  the matrix group that correspond to the action of Aut L on the 
##  multiplicator. Returns the orbits on the allowable subgroups.
##

OrbitsOfAllowableSubgroups := function( dim1, dim2, dimN, p, G )
    local positions, els, act, info, orbs, gens, p_gens, PG, f, stabs;

    
    info := ComputeAllowableInfo( dim1, dim2, dimN, p );
	
    els :=  [0..Sum( info.nrswithdefsets )-1];
    
    Info( LieInfo, 1, "Degree of action: ", Length( els ));
    
    act := function( l, g )
        local y, x;
        
        
        x := MatrixOfLabel( l, info );
        y := x*TransposedMat( g );
        TriangulizeMat( y );
        
        return LabelOfMatrix( y, info );
    end;
   
    if FIND_MIN_GEN_SET then
        G := ReduceGenSet2( G );
    fi;

    orbs := OrbitsDomain( G, els, act );


    return List( orbs, x -> AllowableSubgroupByMatrix( 
                   MatrixOfLabel( x[1], info )));
end;


#############################################################################
##
#F LabelOfDescendant( <L>, <K> )
##
##  <K> must be a descendant of <L>. Computes the label of the standard 
##  matrix that correspond to <K>. Only used for testing and experimenting.
##

LabelOfDescendant := function( L, K )
    local C, d, M, N, p, V, f, bK, bN, posN, order, trans, mat, info;
    
    C := LieCover( L );
    
    d := MinimalGeneratorNumber( L );
    
    M := LieMultiplicator( C );
    N := LieNucleus( C );
    
    p := Characteristic( LeftActingDomain( L ));
    V := GF( p )^Dimension( M );
    
    f := AlgebraHomomorphismByImagesNC( C, K, NilpotentBasis( C ){[1..d]}, 
                 NilpotentBasis( K ){[1..d]}); 
    K := Kernel( f );
    
    bK := List( Basis( K ), x->Coefficients( Basis( M ), x ));
    bN := List( Basis( N ), x->Coefficients( Basis( M ), x ));
    
    
    
    posN := List( Basis( M ), x -> x in N );
    order := [1..Dimension( V )];
    SortParallel( posN, order );
    trans := PermutationMat( PermList( order )^-1, Dimension( V ), GF(p));
    
    mat := StandardMatrix( Subspace( V, bK*trans ), Subspace( V, bN*trans ));
    info := ComputeAllowableInfo( Dimension( M ) - Dimension( K ), 
                    Dimension( M ), Dimension( N ), p );
    
    return LabelOfMatrix( mat, info );
    
end;

#############################################################################
##
#F OrbitOfDescendant( <L>, <K> )
##
##  <K> must be a descendant of <L>. Computes the labels 
##  of the the standard matrices that correspond to 
##  the orbit of <K>. Only used for testing and experimenting.
##

OrbitOfDescendant := function( L, K )
    local C, d, M, N, p, V, f, bK, bN, posN, order, trans, 
          mat, info, label, act, G, gens, i, A, x, y;
    
    label := LabelOfDescendant( L, K );
    A := AutomorphismGroupOfNilpotentLieAlgebra( L );
    gens := [];
    
    C := LieCover( L );
    M := LieMultiplicator( C );
    N := LieNucleus( C );
    p := Characteristic( LeftActingDomain( L ));
    
    for i in A.glAutos do
        LinearActionOnMultiplicator( i );
        Add( gens, i!.mat );
    od;
    for i in A.agAutos do
        LinearActionOnMultiplicator( i );
        Add( gens, i!.mat );
    od;
       
    V := GF(p)^Dimension( M );
    posN := List( Basis( M ), x -> x in N );
    order := [1..Dimension( V )];
    SortParallel( posN, order );
    trans := PermutationMat( PermList( order )^-1, Dimension( V ), GF(p));
    
    G := Group( List( gens, x->x^trans ));
    info := ComputeAllowableInfo( Dimension( K ) - Dimension( L ), 
                    Dimension( M ), Dimension( N ), p );
    
    #G := ReduceGenSet( G );
        
    act := function( l, g )
        local y, x;
        
        
        x := MatrixOfLabel( l, info );
        y := x*TransposedMat( g );
        TriangulizeMat( y );
        
        return LabelOfMatrix( y, info );
    end;
    
    return Orbit( G, label, act );
    
end;


#############################################################################
##
#F SameOrbitOfDescendant( <L>, <K1>, <K2> )
##
##  <K1> and <K2> must be descendants of <L>. Returns true of the labels of
##  <K1> and <K2> are in the same orbit under Aut L. Only used for testing
##  and experimenting.
##

SameOrbitOfDescendant := function( L, K1, K2 )
    local C, d, M, N, p, V, f, bK, bN, posN, order, trans, 
          mat, info, label1, label2, act, G, gens, i, A, x, y;
    
    label1 := LabelOfDescendant( L, K1 );
    label2 := LabelOfDescendant( L, K2 );
    A := AutomorphismGroupOfNilpotentLieAlgebra( L );
    gens := [];
    
    C := LieCover( L );
    M := LieMultiplicator( C );
    N := LieNucleus( C );
    p := Characteristic( LeftActingDomain( L ));
    
    for i in A.glAutos do
        LinearActionOnMultiplicator( i );
        Add( gens, i!.mat );
    od;
    for i in A.agAutos do
        LinearActionOnMultiplicator( i );
        Add( gens, i!.mat );
    od;
       
    V := GF(p)^Dimension( M );
    posN := List( Basis( M ), x -> x in N );
    order := [1..Dimension( V )];
    SortParallel( posN, order );
    trans := PermutationMat( PermList( order )^-1, Dimension( V ), GF(p));
    
    G := Group( List( gens, x->x^trans ));
    info := ComputeAllowableInfo( Dimension( K1 ) - Dimension( L ), 
                    Dimension( M ), Dimension( N ), p );
    
    
    G := ReduceGenSet2( G );
        
    act := function( l, g )
        local y, x;
        
        
        x := MatrixOfLabel( l, info );
        y := x*TransposedMat( g );
        TriangulizeMat( y );
        
        return LabelOfMatrix( y, info );
    end;
    
    return RepresentativeAction( G, label1, label2, act );
    
     
end;
