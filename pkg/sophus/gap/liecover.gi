#############################################################################
##
#W  liecover.gi                Sophus package                Csaba Schneider 
##
#W  This file contains the methods to compute the cover of a nilpotent
#W  Lie algebra.
##
#H  $Id: liecover.gi,v 1.6 2005/08/09 17:06:07 gap Exp $

######################################################################
## 
#P IsLieCover( <L>
##
## Is a Lie cover of something?

InstallMethod( 
        IsLieCover,
        "for nilpotent Lie algebras with nilpotent presentation",
        [ IsLieNilpotentOverFp ],
        function( L )
    
    if IsBound( L!.isLieCover ) then 
        return L!.isLieCover; 
    else 
        return false;
    fi;
    
end );


######################################################################
## 
#A CoverOf( <L> )
## 
##  If L is a Lie cover then the next method returns what it is a 
##  cover of.

InstallMethod( 
        CoverOf,
        "for nilpotent Lie algebras with nilpotent presentation",
        [ IsLieCover ],
        function( L )
    
    return L!.coverOf;
end );



######################################################################
## 
##
#A CoverHomomorphism( <L> )
##  
## Returns the homom between the cover and the original

InstallMethod( 
        CoverHomomorphism,
        "for nilpotent Lie algebras with nilpotent presentation",
        [ IsLieCover ],
        function( L )
    
    return L!.homom;
end );


######################################################################
## 
##
#F AdjustWeights( <L> )
##  
## Corrects the weights.


AdjustWeights := function( weights, A, offset )
    local changed, zero, a, vect, i, collvect, wrongweight, newweight;
    
    
    if A = [] then return weights; fi;
    zero := 0*A[1][1];
    
    
    repeat
            changed := false;
            for a in A do
            vect := [];
            for i in [1..Length( a )] do
                if a[i] = zero then 
                    Add( vect, 0 );
                else 
                    Add( vect, weights[i+offset] );
                fi;
            od;
            collvect := Collected( vect );
            if Length( collvect ) >= 3 and collvect[2][2] = 1 then
                wrongweight := Position( vect, collvect[2][1] ) + offset;
                newweight := MinimumList( 
                                     List( collvect{[3..Length( collvect )]}, 
                                           x->x[1] ));
                weights[wrongweight] := newweight;
                changed := true;
            fi;
        od;
    until not changed;
    
    return weights;
end;

       
                
    


######################################################################
## 
#A LieCover( <L> )
## 
##  Computes the cover of the Lie algebra L

InstallMethod( 
        LieCover,
        "for nilpotent Lie algebras with nilpotent presentation",
        [ IsLieAlgebra ],
        function( L )
    
    local 
      class,                     # nilpotency class of L
      weights,                   # weights of NB basis for L
      defs,                      # definitions of NB basis for L
      no_weight_one,             # dim L/L'
      i, j, k,                   # indexing
      dim,                       # dim of L
      T,                         # SC table
      no_tails,                  # the number of tails
      tails_list1, tails_list2,    # the lists with the new products
      prod1, prod2,              # the product of two basis elements
      c,                         # current class
      F,                         # underlying field
      A, dimA, BA,               # the assoc cover, basis, and dim 
      Q,                         # the final result, the cover
      equations,                 # subspace spanned by Jacobi instances
      jac,                       # a jacobi instance          
      new,                       # a copy of basis vectors
      Bas,                       # basis for L                
      bas,
      eq,
      t,
      pseudo_defs,
      pseudo_weights,
      surv,
      list;                      # coefficient list of a product
    
    
    t := Runtime();   

    if not IsLieNilpotentOverFp( L ) then
	TryNextMethod();
    fi;	
 
    F := LeftActingDomain( L );
    Bas := NilpotentBasis( L );
    weights := ShallowCopy( LieNBWeights( Bas )); 
    defs := List(  LieNBDefinitions( Bas ), x->ShallowCopy( x ));
    class := weights[ Length( weights )];
    dim := Length( Bas );
    
    if 2 in weights then
        no_weight_one := Position( weights, 2 ) - 1;
    else 
        no_weight_one := Length( weights );
    fi;
    
    tails_list1 := []; tails_list2 := [];
    
    Info( LieInfo, 1, "Setup took ", Runtime()-t ); t := Runtime();
    
    no_tails := 0;
    
    for i in [2..dim] do
        for j in [1..Minimum( i-1, no_weight_one )] do
            if weights[j] + weights[i] 
               <= class + 1 then
                if not [ j, i ] in defs then
                    if Bas[j]*Bas[i] = Zero( L ) then
                        Add( tails_list2, [ j, i ] );
                    else
                        Add( tails_list1, [ j, i ] );
                    fi;
                    no_tails := no_tails + 1;
                fi;
            fi;
        od;
    od;
        
    T := EmptySCTable( dim + no_tails, Zero( F ), "antisymmetric" );
    no_tails := 0;
    
    for i in [1..Length( defs )] do
        if not IsInt( defs[i] ) then
            SetEntrySCTable( T, defs[i][1], defs[i][2], [ One( F ), i ] );
        fi;
    od;
    
    pseudo_defs := ShallowCopy( LieNBDefinitions( Bas ));
    pseudo_weights := ShallowCopy( LieNBWeights( Bas ));
    
    for i in tails_list1 do
        prod1 := Coefficients( Bas, Bas[i[1]]*Bas[i[2]]);
        list := [];
        for c in [1..dim] do
            if prod1[c] <> Zero( F ) then
                Add( list, prod1[c] );
                Add( list, c );
            fi;
        od;
        no_tails := no_tails + 1;
        Add( list, One( F ));
        Add( list, dim + no_tails );
        Info( LieInfo, 2, "New pseudogenerator: [ ", i[1], ", ", i[2], " ] <- ",               dim + no_tails );
        SetEntrySCTable( T, i[1], i[2], list );
        Add( pseudo_defs, i );
        Add( pseudo_weights, pseudo_weights[i[1]]+pseudo_weights[i[2]] );
    od;
    
    
    for i in tails_list2 do
        prod1 := Coefficients( Bas, Bas[i[1]]*Bas[i[2]]);
        list := [];
        for c in [1..dim] do
            if prod1[c] <> Zero( F ) then
                Add( list, prod1[c] );
                Add( list, c );
            fi;
        od;
        no_tails := no_tails + 1;
        Add( list, One( F ));
        Add( list, dim + no_tails );
        Info( LieInfo, 2, "New generator: [ ", i[1], ", ", i[2], " ] <- ", 
              dim + no_tails );
        SetEntrySCTable( T, i[1], i[2], list );
        Add( pseudo_defs, i );
        Add( pseudo_weights, pseudo_weights[i[1]]+pseudo_weights[i[2]] );
    od;
    
    # complete SC table
    
    
    Info( LieInfo, 1, "Completing partial table took ", Runtime()-t ); 
    t := Runtime();
    
    for i in [no_weight_one + 1..dim] do
        for j in [i+1..dim] do
            if weights[i] + weights[j] <= class + 1 then
                prod1 := T[j][defs[i][1]];
                prod1 := ProductSCT( T, prod1, defs[i][2] );
                prod2 := T[j][defs[i][2]];
                prod2 :=  ProductSCT( T, prod2, defs[i][1] );
		prod2[2] := -prod2[2];
                prod1 := SumSCT( prod1, prod2 );
                Info( LieInfo, 2, "Tail computed: ", j, " ", i );
                SetEntrySCTable( T, j, i, 
                        NativeSCTableForm2SCTableForm( prod1 ));
            fi;
        od;
    od;
   
    Info( LieInfo, 1, "Completing table took ", Runtime()-t ); t := Runtime();
    A := AlgebraByStructureConstants( F, T );
    
    BA := Basis( A );
    
    dimA := Dimension( A );
    
    equations := Subspace( A, [] );
    
    new := [];
    
    for i in [1..no_weight_one] do
        for j in [i+1..dim] do
            for k in [j+1..dim] do
                if weights[i] + weights[j] + weights[k] <= class + 1 then
                    jac := BA[i]*BA[j]*BA[k]+BA[j]*BA[k]*BA[i]+BA[k]*BA[i]*BA[j];
                    if jac <> Zero( A ) then	
                        Info( LieInfo, 2, "Jacobi: ", i, " ", j, " ", k, ": ", 
                              jac );
                        Add( new, Coefficients( BA, jac ){[dim+1..dimA]});
                    	TriangulizeMat( new );
                    	new := Filtered( new, x -> x <> new[1]*0 );
		    fi;
                fi;
            od;
        od;
    od;
    
    Info( LieInfo, 1, "Computing Jacobis took ", Runtime()-t ); t := Runtime();
    
    pseudo_weights := AdjustWeights( pseudo_weights, new, dim );
    
    if Length( new ) > 0 then
        surv := Difference( [1..Length( pseudo_defs )], 
                        List( new, x->PositionNonZero( x )+dim ));
        pseudo_defs := pseudo_defs{surv};
        pseudo_weights := pseudo_weights{surv};
    fi;
    
    Q := AlgebraByStructureConstants(  F, 
                 LieQuotientTable( StructureConstantsTable( Basis( A )), 
                         new, dim ));
    
    Q!.pseudo_definitions := pseudo_defs;
    Q!.pseudo_weights := pseudo_weights;
    
    Info( LieInfo, 1, "Computing new table took ", Runtime()-t );
    t := Runtime();
    
    Q!.LieMultiplicator := Subalgebra( Q, List( [dim+1..Dimension( Q )], x->Basis( Q )[x] ), "basis" );
    Q!.isLieCover := true;
    Setter( IsLieNilpotentOverFp )( Q, true );
    #Setter( LieLowerCentralSeries )( Q, MyLieLowerCentralSeries( Q ));
    Q!.LieNucleus := LieLowerCentralSeries( Q )[Length( LieLowerCentralSeries( L ))];
    Q!.coverOf := L;
    Q!.homom := AlgebraHomomorphismByImagesNC( Q, L, List( [1..no_weight_one], x->Basis( Q )[x] ), List( [1..no_weight_one], x->Bas[x] ));
    
    Info( LieInfo, 1, "Final computation took ", Runtime()-t ); t := Runtime();

    return Q;
    
end );


######################################################################
##
#A LieNucleus( <L> )
## 
## returns the nucleus

InstallMethod( 
        LieNucleus,
        "for nilpotent Lie algebras",
        [ IsLieNilpotentOverFp ],
        function( L )
    
    if IsBound( L!.LieNucleus ) then 
        return L!.LieNucleus;
    else 
        return false;
    fi;
    
end );



######################################################################
##
#A LieMultiplicator( <L> )
## 
## returns the multiplicator of a Lie algebra

InstallMethod( 
        LieMultiplicator,
        "for nilpotent Lie algebras",
        [ IsLieNilpotentOverFp ],
        function( L )
    
    if IsBound( L!.LieMultiplicator ) then 
        return L!.LieMultiplicator;
    else 
        return false;
    fi;
    
end );

