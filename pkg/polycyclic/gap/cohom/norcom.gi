#############################################################################
##
#W  norcom.gi                    Polycyc                         Bettina Eick
##

##
## computing normal complements
##

#############################################################################
##
#F ComplementsCR( C ) . . . . . . . . . . . . . . . . . . . . all complements
##
ComplementsCR := function( C )
    local B, cc, elm, rel, new;

    if Length( C.factor ) = 0 then
        B := SubgroupByIgs( C.group, DenominatorOfPcp( C.normal ) );
        return [B];
    fi;

    cc := OneCocyclesEX( C );
    if IsBool( cc.transl ) then return []; fi;

    # if there are infinitely many complements
    if C.char = 0 and Length( cc.basis ) > 0 then
        Print("infinitely many complements \n");
        return fail;
    fi;

    # otherwise compute all elements
    new := [];
    if Length( cc.basis ) = 0 then
        elm := ComplementCR( C, cc.transl );
        Add( new, elm );
    else
        rel := ExponentsByRels( List( cc.basis, x -> C.char ) );
        elm := List( rel, x -> IntVector( x * cc.basis + cc.transl ) );
        elm := List( elm, x -> ComplementCR( C, x ) );
        Append( new, elm );
    fi;
    return new;
end;

#############################################################################
##
#F Complements( U, N ) . . . . . . . . . . . . . . . .compute all complements
##
Complements := function( U, N )
    local pcps, com, pcp, new, L, C;

    # catch the trivial case
    if U = N then return [TrivialSubgroup(U)]; fi;

    # compute complements along a series
    pcps := PcpsOfEfaSeries( N );
    com  := [ U ];
    for pcp in pcps do
        new := [];
        for L in com do

            # set up CR record
            C := rec();
            C.group  := U;
            C.factor := Pcp( L, GroupOfPcp( pcp ) );
            C.normal := pcp;
        
            AddFieldCR( C );
            AddRelatorsCR( C );
            AddOperationCR( C );
            AddInversesCR( C );
            Append( new, ComplementsCR( C ) );
        od;
        com := ShallowCopy( new );
    od;
    return com;
end;

#############################################################################
##
#F OperationOnZ1( C, cc )   . . . . . . . . . . . . . . . C.super on cocycles
##
OperationOnZ1 := function( C, cc )
    local l, m, s, lin, trl, i, j, g, h, ms, coc, img, add, act;

    # catch some trivial cases
    if Length( C.super ) = 0 then
        return [];
    elif Length( cc.basis ) = 0 then
        return List( C.super, x -> 1 );
    fi;
    l := Length( C.factor );

    # compute the linear action
    lin := List( C.super, x -> [] );
    trl := List( C.super, x -> 0 );
    for i in [1..Length(C.super)] do
        g := C.super[i]^-1;
        h := C.super[i];
        m := C.smats[i];
        s := List( C.factor, x -> ExponentsByPcp( C.factor, x^g ) );

        # the linear part
        for j in [1..Length( cc.basis )] do
            coc := CutVector( cc.basis[j], l );
            img := List( s, x -> EvaluateCocycle( C, coc, x ) );
            img := List( img, x -> x * m );
            lin[i][j] := Flat( img );
        od;

        # translation part
        coc := CutVector( cc.transl, l );
        img := List( s, x -> EvaluateCocycle( C, coc, x ) );
        img := List( img, x -> x * m );
        add := List( [1..l],
               x -> C.factor[x]^-1 * MappedVector(s[x], C.factor)^h);
        add := List( add, x -> ExponentsByPcp( C.normal, x ) );
        trl[i] := Flat( img ) + Flat( add ) - cc.transl;

    od;

    # combine linear and translation action
    act := [];
    for i in [1..Length( C.super )] do
        if lin[i] = cc.basis and trl[i] = 0*trl[i] then
            act[i] := 1;
        else
            act[i] := rec( lin := lin[i], trl := trl[i] );
        fi;
    od;
    return act;
end;

#############################################################################
##
#F FixedPoints( pts, gens, oper )
##
FixedPoints := function( pts, gens, oper )
    return Filtered( pts, x -> ForAll( gens, y -> oper( x, y ) = x ) );
end;

#############################################################################
##
#F InvariantComplementsCR( C ) . . . . . . . . . . .invariant under operation
##
InvariantComplementsCR := function( C )
   local cc, f, rels, elms, act, sub;

    # compute H^1( U, A/B ) and return if there is no complement
    if not C.central then return []; fi;
    cc := OneCocyclesEX( C );
    if IsBool( cc.transl ) then return []; fi;

    # check the finiteness of H^1
    if C.char = 0 and Length( cc.basis ) > 0 then 
        Print("infinitely many complements \n");
        return fail;
    fi;

    # catch the case of a trivial H1
    if Length( cc.basis ) = 0 then
        return [ComplementCR( C, cc.transl )];
    fi;

    # the operation of G on H1
    f := function( pt, act )
        local im;
        if act = 1 then return pt; fi;
        im := pt * act.lin + act.trl;
        return SolutionMat( cc.basis, im );
    end;

    # create elements of cc.factor
    rels := List( cc.basis, x -> C.char );
    elms := ExponentsByRels( rels ) * One( C.field );

    # compute action and fixed points
    act := OperationOnZ1( C, cc );
    sub := FixedPoints( elms, act, f );

    # catch trivial case and translate result
    if Length(sub) = 0 then return sub; fi;
    sub := sub * cc.basis;
    return List(sub, x -> ComplementCR( C, IntVector(x+cc.transl)));
end;


#############################################################################
##
#F InvariantComplementsEfaPcps( G, U, pcps ). . . . .
##        compute invariant complements in U along series. Series must
##        be an efa-series and each subgroup in series must be normal
##        under G.
##
InvariantComplementsEfaPcps := function( G, U, pcps )
    local cls, pcp, new, L, C;

    cls := [ U ];
    for pcp in pcps do
        if Length( pcp ) > 0 then
            new := [];
            for L in cls do

                # set up class record
                C := rec( group  := L,
                          super  := Pcp( G, L ),
                          factor := Pcp( L, GroupOfPcp( pcp ) ),
                          normal := pcp );

                AddFieldCR( C );
                AddRelatorsCR( C );
                AddOperationCR( C );
                AddInversesCR( C );
                Append( new, InvariantComplementsCR( C ) );
            od;
            cls := ShallowCopy(new);
        fi;
    od;
    return cls;
end;


#############################################################################
##
#F InvariantComplements( [G,] U, N ). . . . . invariant complements to N in U
##
InvariantComplements := function( arg )
    local G, U, N, pcps;

    # the arguments
    G := arg[1];
    if Length( arg ) = 3 then
        U := arg[2];
        N := arg[3];
    else
        U := arg[1];
        N := arg[2];
    fi;

    # catch a trivial case
    if U = N then return [ TrivialSubgroup(N) ]; fi;

    # otherwise compute series and all next function
    pcps := PcpsOfEfaSeries( N );
    return InvariantComplementsEfaPcps( G, U, pcps );
end;
