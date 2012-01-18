#############################################################################
##
#W  matunits.gi     Alnuth - ALgebraic NUmber THeory           Bettina Eick
##

#############################################################################
##
#F IntersectionOfUnitSubgroups( F, gen1, gen2 )
##
## Let <gen1> and <gen2> be two subgroups of U(F).
## This function computes the intersection of <gen1> and <gen2> as exponents
## in the generators of <gen1>.
##
InstallGlobalFunction( IntersectionOfUnitSubgroups, function(F,gen1,gen2)
    local add, ad1, ad2, U, u, l, m, t, int, i;

    # get an additive description of both unit groups
    add := ExponentsOfUnits( F, Concatenation( gen1, gen2 ) );
    ad1 := add{[1..Length(gen1)]};
    ad2 := add{[Length(gen1)+1..Length(gen1)+Length(gen2)]};

    # extract units
    U := UnitGroupOfNumberField( F );
    u := GeneratorsOfGroup(U);
    l := Length(u)-1;
    m := Order(u[1]);
    t := List( [1..l+1], x -> 0 ); t[1] := m;

    # compute intersection
    int := NullspaceIntMat( Concatenation( ad1, ad2, [t] ) );
    int := int{[1..Length(int)]}{[1..Length(ad1)]};

    # reduce torsion
    if int[1][1] <> 0 then
        int[1][1] := int[1][1] mod m;
    fi;
    if int[1] = 0*int[1] then 
        int := int{[2..Length(int)]};
    fi;

    return int;
end );

#############################################################################
##
#F IntersectionOfTFUnitsByCosets( F, mats, C )
##
## <mats> is a torsion free subgroup of U(F) und C are some cosets in U(F).
##
InstallGlobalFunction( IntersectionOfTFUnitsByCosets, function( F, mats, C )
    local a, b, c, d, all, add, rep, s, i, r, fr1, fr2, int;

    # set up
    a := Length( mats );
    b := Length( C.units );
    c := Length( C.reprs );

    # determine additive description
    all := Concatenation( mats, C.units, C.reprs );
    add := ExponentsOfUnits( F, all );

    # mod out torsion 
    d := Length( GeneratorsOfGroup(UnitGroup(F)) ) - 1;
    add := add{[1..Length(add)]}{[2..d+1]};

    # cut into pieces
    rep := add{[ a+b+1..a+b+c ]};
    add := add{[ 1..a+b ]};

    # loop over reps
    s := false;
    i := 1;
    while IsBool(s) and i <= Length(rep) do
        r := SolutionIntMat( add, rep[i] );
        i := i+1;
        if not IsBool(r) then s := r{[1..a]}; fi;
    od;

    # if we cannot find a representative, then return
    if IsBool(s) then return false; fi;

    # otherwise add intersection of mats with C.units
    fr1 := add{[1..a]};
    fr2 := add{[a+1..a+b]};

    # find linear combinations of mgrp in unit
    int := NullspaceIntMat( Concatenation( fr1, fr2 ) );
    int := int{[1..Length(int)]}{[1..a]};

    return rec( repr := s, ints := int );
end );

