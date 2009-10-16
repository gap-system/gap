#############################################################################
##
#F specsr.gi  .... tables for a special series
##

#############################################################################
##
#F LowerNilpotentBasis( L )
##
LowerNilpotentBasis := function( L )
    local n, B, U, H, w, i, j, W, F;

    n := Dimension(L);

    # set up bases
    U := CBS(L);
    H := [];
    B := [];

    # set up weights
    w := [];
    i := 0;
    j := 1;

    # find nice basis for the given Lie-Algebra
    while Length(B) <> n do

        # try a central step
        if Length(H) > 0 then 
           #Print("try central step\n");
           W := CommutatorBasis( U, H );

           # found a central step?
           if Length(W) < Length(U) then 
               j := j + 1;
               F := ComplementBasis( U, W );
               U := W;
               Append( B, F );
               Append( w, List( F, x -> [i,j] ) );
               #Print("  found central step of dim ",Length(F),"\n");

           # otherwise reset
           else
               #Print("  no central step \n");
               j := 1;
               H := [];
           fi;

        # try a derived step
        else
           #Print("try derived step\n");
           i := i + 1;
           W := CommutatorBasis( U, U );

           # if this also does not yield anything, then return
           if Length(W) = Length(U) then
               Append(B, U);
               Append(w, List(U, x -> false));
               return rec( basis := B, weights := w );
           fi;

           # otherwise we add new step    
           F := ComplementBasis( U, W );
           H := U;
           U := W;
           Append( B, F );
           Append( w, List( F, x -> [i,j] ) );
           #Print("  found derived step of dim ",Length(F),"\n");
        fi;
    od;

    return rec( basis := B, weights := w );
end;

#############################################################################
##
#F LieAlgebraByLowerNilpotentSeries( L )
##
LieAlgebraByLowerNilpotentSeries := function( L )
    local B, H;
    B := LowerNilpotentBasis( L );
    H := LieAlgebraByBasis( L, B.basis );
    H!.weights := B.weights;
    H!.bijection := List( B.basis, x -> x![1] );
end;

#############################################################################
##
#F UpperNilpotentBasis( L )
##
UpperNilpotentBasis := function( L )
    local N, B, C, w;
    N := LieNilRadical(L);
    B := LowerNilpotentBasis(N);
    B.weights := List( B.weights, x -> x[2] );
    C := ComplementBasis( CBS(L), B.basis );
    w := List( C, x -> 0 );
    return rec( basis := Concatenation( C, B.basis ),
                weights := Concatenation( w, B.weights ) );
end;
    
