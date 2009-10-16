#############################################################################
##
#W  sylow.gi                     NilMat                          Alla Detinko
#W                                                               Bettina Eick
#W                                                              Dane Flannery
##

##
## This file contains a method to compute a list of Sylow subgroups of a
## given nilpotent matrix group over GF(q).
##


#############################################################################
##
#F SylowSubgroupsOfNilpotentMatGroupFF(G) . . . . . determine Sylow subgroups
##
## This function takes a nilpotent matrix group G over GF(q) and returns
## its Sylow system.
##
## Note that this function does not check if the given group G is nilpotent
## and it may return wrong results if it is not.
##
## Note that the generic method to compute the Sylow system of nilpotent 
## groups is not so bad. Hence the function below is only a small improvement 
## that uses the results of the nilpotency test in a sensible form.
##
InstallGlobalFunction( SylowSubgroupsOfNilpotentFFMatGroup, function(G)
    local F, p, n, l, J, S, U, P, B, C, W, bC, oC, bB, oB, sB, o, syl, q, t;

    F := FieldOfMatrixGroup(G);
    p := Characteristic(F);
    n := DimensionOfMatrixGroup(G);
    l := ClassLimit(n, F);

    # compute Jordan and Pi-primary splitting
    J := JordanSplitting(G);
    S := J[1];
    U := J[2];
    P := PiPrimarySplitting(S);
    B := P[1];
    C := P[2];

    # now G = U x C x B 
    # U is a p-subgroup, C is abelian and 
    # Sylow subgroups of B are available unless B is abelian

    # get generators and relevant primes for C
    bC := GeneratorsOfGroup(C);
    oC := Set(PrimeFactors(List(GeneratorsOfGroup(C), Order)));

    # get generators and relevant primes for B
    if HasSylowSystem(B) then 
        sB := SylowSystem(B);
        oB := List(sB, PrimePGroup);
    else
        oB := Set(PrimeFactors(List(GeneratorsOfGroup(B), Order)));
        bB := GeneratorsOfGroup(B);
    fi;

    # do a check 
    if p in oB or p in oC then 
        Error("something wrong with Sylow subgroups");
    fi;
  
    # get relevant primes for G
    if ForAny( GeneratorsOfGroup(U), x -> x <> x^0 ) then
        o := Union( [p], oC, oB );
    else
        o := Union( oC, oB );
    fi;

    # determine Sylow subgroups corresponding to o
    syl := [];
    for q in o do

        # the p-Sylow subgroup is U (unless it is trivial)
        if q = p then 
            SetIsPGroup(U, true);
            SetPrimePGroup(U, q);
            Add( syl, U ); 
        else

            # otherwise join p-Sylow subgroups of C and B
            t := [];
            if q in oB then
                if HasSylowSystem(B) then 
                    W := sB[Position(oB,q)];
                else
                    W := SylowSubgroupOfNilpotentMatGroupFF( B, bB, q );
                fi;
                Append( t, GeneratorsOfGroup(W) );
            fi;
            if q in oC then
                W := SylowSubgroupOfNilpotentMatGroupFF( C, bC, q );
                Append( t, GeneratorsOfGroup(W) );
            fi;

            # create group and store info
            W := GroupByGenerators(t);
            SetIsPGroup(W, true);
            SetPrimePGroup(W, q);
            Add( syl, W );
        fi;
    od;

    return syl;
end );

##
## need high value, otherwise GAP chooses the method for solvable groups
## using a special pc sequence to compute the Sylow system.
##
InstallMethod( SylowSystem, true, [IsMatrixGroup and IsNilpotentGroup], 
SUM_FLAGS, function(G)
    if IsFinite(FieldOfMatrixGroup(G)) then 
        return SylowSubgroupsOfNilpotentFFMatGroup(G);
    fi;
    TryNextMethod();
end );
