
##
#F  AddHallPolynomials 
##
BindGlobal( "AddHallPolynomials", function( coll )

    if not IsWeightedCollector( coll ) then

        Error( "Hall polynomials can be computed ",
               "for weighted collectors only" );
    fi;

    if not IsBound( coll![PC_DEEP_THOUGHT_POLS] ) or 
       coll![PC_DEEP_THOUGHT_POLS] = [] then

        # Compute the deep thought polynomials
        coll![PC_DEEP_THOUGHT_POLS] := calcreps2(coll![PC_CONJUGATES], 8, 1);

        # Compute the orders of the genrators of dtrws
        CompleteOrdersOfRws(coll);

        # reduce the coefficients of the deep thought polynomials
        ReduceCoefficientsOfRws(coll);

        SetFeatureObj( coll, IsPolynomialCollector, true );
    fi;

end );


##
#F  SetDeepThoughtBoundary  . . .  set the generator from which on DT is used
##
BindGlobal( "SetDeepThoughtBound", function( coll, n )

    coll![ PC_DEEP_THOUGHT_BOUND ] := n;
end );


##  
##  Methods for  CollectWordOrFail.
##
InstallMethod(CollectWordOrFail,

    "FTL collector with Hall polynomials, exponent vector, gen-exp-pairs",

    [ IsFromTheLeftCollectorRep
      and IsPolynomialCollector    
      and IsUpToDatePolycyclicCollector,
      IsList, 
      IsList],
        
function( coll, l, genexp )
    local   res,  i,  n;

    if Length(genexp) = 0 then return true; fi;

    res := ObjByExponents( coll, l );
    
    i := 1;
    while i < Length(genexp) do
        res := DTMultiply( res, [genexp[i], genexp[i+1]], coll );
        i := i + 2;
    od;

    for i in [1..Length(l)] do l[i] := 0; od;
    n := Length( res );
    l{ res{[1,3..n-1]} } := res{ [2,4..n] };

    return true;
end );


