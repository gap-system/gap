#############################################################################
##
#W  descendant.gi            Sophus package                   Csaba Schneider 
##
#W The methods in this file are used to compute the descendants of a 
#W nilpotent Lie algebra.
## 
#H  $Id: descendant.gi,v 1.10 2005/08/09 17:06:07 gap Exp $



#############################################################################
##
#M  DescendantsOfStep1OfAbelianLieAlgebra( <dim>, <p> )
##  
##  Computes the descendants of the <dim>-dimensional abelian Lie algebra over
##  the field of <p> elements.
##  

InstallMethod( DescendantsOfStep1OfAbelianLieAlgebra,
   "for abelian Lie algebras", true, [ IsPosInt, IsPosInt ], 0,

function( dim, p )
    local L, C, M, B,  els, el, subs, i, V;
    
    L := AbelianLieAlgebra( GF(p), dim );
    C := LieCover( L );
    M := LieMultiplicator( C );
    B := NilpotentBasis( C );
    
    els := [];
    el := Zero( C );
    
    for i in [1..Int( dim/2 )] do
        el := el + B[2*i-1]*B[2*i];
        Add( els, el );
    od;
    
    V := GF(p)^Dimension( M );
    
    subs := List( els, x->Coefficients( Basis( M ), x ));
    subs := List( subs, x->Basis( Subspace( V, [x] )));
    subs := List( subs, x->DualBasis( x ));
    subs := List( subs, x->List( x, y->LinearCombination( Basis( M ), y )));
    subs := List( subs, x->Ideal( C, x ));
    
    return List( subs, x->C/x );
end );


    

#############################################################################
##
#M  Descendants( <L>, <step> )
##  
##  Computes the <step>-step descendants of the nilpotent Lie algebra <L>.
##  

InstallMethod( Descendants,
   "for nilpotent Lie algebras", true, [ IsLieAlgebra, IsPosInt ], 0,

function( L, step )
    local A, C, M, N, G, orbs, V, T, new_Ts, basN, reps_bas, 
          USE_DUAL, dim, iter, i, reps, algs, p, info, posN, 
          order, mat, gens, newG;

    if not IsLieNilpotentOverFp( L ) then
		TryNextMethod();
    fi;

    Info( LieInfo, 1, "Computing Cover Info" );
  
    if 
      Length( LieLowerCentralSeries( L )) = 
      Length( LieLowerCentralSeries( LieCover( L )))  
      or 
      step > Dimension( LieMultiplicator( LieCover( L ))) then 
        return []; 
    fi;


    A := ShallowCopy( AutomorphismGroupOfNilpotentLieAlgebra( L ));
    L := A.liealg;
    
    C := LieCover( L );
    
    M := LieMultiplicator( C );
    N := LieNucleus( C );
    
	
    
    C := LieCover( L );
    
    Info( LieInfo, 1, "Computing action on multiplier" );
    
    LinearActionpOfGroupOnMultiplier( A );
    
    
    G := Group( Union( List( A.glAutos, x -> x!.mat ), 
                 List( A.agAutos, x -> x!.mat )));
    
    p := Characteristic( LeftActingDomain( L ));
    V := GF( p )^Dimension( M );
    
    dim := Dimension( M ) - step;
    
    Info( LieInfo, 1, "Computing Orbits. Multiplicator has dimension ", 
          Dimension( M ));
    
    if step = Dimension( M ) and Dimension( M ) = Dimension( N ) then
        return [ C ];
    elif step = Dimension( M ) and Dimension( M ) <> Dimension( N ) then
        return [];
    else
        posN := List( Basis( M ), x -> x in N );
        order := [1..Dimension( V )];
        SortParallel( posN, order );
        mat := PermutationMat( PermList( order )^-1, Dimension( V ), GF(p));
        gens := GeneratorsOfGroup( G );
        newG :=  Group( List( gens, x -> x^mat ));
        
        reps := OrbitsOfAllowableSubgroups( Dimension( V ) - dim, 
                        Dimension( V ), Dimension( N ), 
                        p, newG );
        
        reps := List( reps, x -> Basis( x ));
        reps := List( reps, x -> BasisVectors( x )*mat^-1 );
    fi;
    
    Info( LieInfo, 1, "Computing allowable orbits" );
    
    
    Info( LieInfo, 1, "Computing descendants" );
    
    T := StructureConstantsTable( Basis( C ));
    
    reps := List( reps, x-> MutableCopyMat( x ));
    
    for i in reps do
        TriangulizeMat( i );
    od;
    
    new_Ts := List( reps, x -> LieQuotientTable( T, x, Dimension( L )));
    
    algs := List( new_Ts, 
                  x -> LieAlgebraByStructureConstants( 
                          LeftActingDomain( L ), x ));	
    
    for i in algs do 
        Setter( IsLieNilpotent )( i, true );
    od;
        
    return algs;
end );





    
           
    
    
    

    
    
