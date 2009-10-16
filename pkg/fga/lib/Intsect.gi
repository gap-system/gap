#############################################################################
##  
#W Intsect.gi                  FGA package                  Christian Sievers
##
## Installations for the computation of intersections of free groups
##
#H @(#)$Id: Intsect.gi,v 1.4 2005/04/07 17:56:57 gap Exp $
##
#Y 2003 - 2005
##
Revision.("fga/lib/Intsect_gi") :=
    "@(#)$Id: Intsect.gi,v 1.4 2005/04/07 17:56:57 gap Exp $";


#############################################################################
##
#F  FGA_StateTable( <table>, <i>, <j> )
##
InstallGlobalFunction( FGA_StateTable,
    function( t, i, j )
    local l;
    if not IsBound( t[i] ) then
        t[i] := [];
    fi;
    if not IsBound( t[i][j] ) then
        t[i][j] := FGA_newstate();
    fi;
    return t[i][j];
    end );

#############################################################################
##
#M  Intersection2( <G1>, <G2> )
##
InstallMethod( Intersection2,
    "for subgroups of free groups",
    IsIdenticalObj,
    [ CanComputeWithInverseAutomaton, CanComputeWithInverseAutomaton ],
    function( G1, G2 )
    local A, t, sl1, sl2, i, nr1, nr2, Q, pair, g, q, q1, q2, bpd, bpdi;

    # let the gap lib handle this case:
    if IsSubgroupOfWholeGroupByQuotientRep( G1 ) and
       IsSubgroupOfWholeGroupByQuotientRep( G2 ) then
        TryNextMethod();
    fi;

    t := [];
    i := FGA_StateTable( t, 1, 1 );
    sl1 := FGA_States( FreeGroupAutomaton( G1 ) );
    sl2 := FGA_States( FreeGroupAutomaton( G2 ) );
    Q := [ [1,1] ];
    for pair in Q do
        q1 := sl1[ pair[1] ];
        q2 := sl2[ pair[2] ];
        q  := FGA_StateTable( t, pair[1], pair[2] );
        for g in Difference(
                   Intersection( BoundPositions( q1.delta ),
                                 BoundPositions( q2.delta ) ),
                   BoundPositions( q.delta ) ) do
            nr1 := q1.delta[g].nr;
            nr2 := q2.delta[g].nr;
            FGA_connectpos( q, FGA_StateTable( t, nr1, nr2 ), g );
            Add( Q, [ nr1, nr2 ] );
        od;

        for g in Difference(
                   Intersection( BoundPositions( q1.deltainv ),
                                 BoundPositions( q2.deltainv ) ),
                   BoundPositions( q.deltainv ) ) do
            nr1 := q1.deltainv[g].nr;
            nr2 := q2.deltainv[g].nr;
            FGA_connectpos( FGA_StateTable( t, nr1, nr2 ), q, g );
            Add( Q, [ nr1, nr2 ] );
        od;

        bpd  := BoundPositions( q.delta );
        bpdi := BoundPositions( q.deltainv );
        while Size( bpd ) + Size( bpdi ) = 1  and
              IsNotIdenticalObj( q, i ) do
            if Size( bpd ) = 1 then
                g := bpd[ 1 ];
                q := q.delta[ g ];
                Unbind( q.deltainv[ g ] );
            else
                g := bpdi[ 1 ];
                q := q.deltainv[ g ];
                Unbind( q.delta[ g ] );
            fi;
            bpd  := BoundPositions( q.delta );
            bpdi := BoundPositions( q.deltainv );
        od;
    od;
    A := Objectify( NewType( FamilyObj( G1 ), IsSimpleInvAutomatonRep ),
                    rec( initial:=i, terminal:=i, 
                         group := TrivialSubgroup( G1 ) ) );
    return AsGroup( A );
    end );


#############################################################################
##
#F  FGA_TrySetRepTable( <t>, <i>, <j>, <r>, <g> )
##
InstallGlobalFunction( FGA_TrySetRepTable,
    function( t, i, j, r, g )    
    local rx;
    if not IsBound( t[i] ) then
        t[i] := [];
    fi;
    if not IsBound( t[i][j] ) then
        rx := ShallowCopy( r );
        Add( rx, g );
        t[i][j] := rx;
        return rx;
    else
        return fail;
    fi;
    end );


#############################################################################
##
#F  FGA_GetNr ( <state>, <statelist> )
##
InstallGlobalFunction( FGA_GetNr,
    function( q ,sl )
    if not IsBound( q.nr ) then
        Add( sl, q );
        q.nr := Size( sl );
    elif not IsBound( sl[ q.nr ] ) then
        sl[ q.nr ] := q;
    fi;
    return q.nr;
    end );

#############################################################################
##
#F  FGA_FindRepInIntersection ( <A1>, <A2> )
##
InstallGlobalFunction( FGA_FindRepInIntersection,
    function( A1, t1, A2, t2 )
    local tab, t1nr, t2nr, sl1, sl2, Q, pair, g, q1, nr1, q2, nr2, r, rx;
    sl1 := [];
    sl1 [ Size( FGA_States( A1 ) ) + 1 ] := 23;
    sl2 := [];
    sl2 [ Size( FGA_States( A2 ) ) + 1 ] := 42;
    q1 := A1!.initial;
    q2 := A2!.initial;
    if IsIdenticalObj( q1, t1) and
       IsIdenticalObj( q1, t2) then
        return [];
    fi;
    nr1 := FGA_GetNr( q1, sl1 );
    nr2 := FGA_GetNr( q2, sl2 );
    tab := [];
    tab [ nr1 ] := [];
    tab [ nr1 ][ nr2 ] := []; # empty word at initial state
    Q := [ [ nr1, nr2 ] ];
    for pair in Q do
        q1 := sl1[ pair[1] ];
        q2 := sl2[ pair[2] ];
        r  := tab [ pair[1] ] [ pair[2] ];
        for g in Intersection( BoundPositions( q1.delta ),
                               BoundPositions( q2.delta ) ) do
            nr1 := FGA_GetNr(q1.delta[g], sl1);
            nr2 := FGA_GetNr(q2.delta[g], sl2);
            rx := FGA_TrySetRepTable( tab, nr1, nr2, r, g );
            if rx <> fail then
                if IsIdenticalObj(sl1[ nr1 ], t1)
                      and IsIdenticalObj(sl2[ nr2 ], t2) then
                    return rx;
                fi;
                Add( Q, [ nr1, nr2 ] );
            fi;
        od;

        for g in Intersection( BoundPositions( q1.deltainv ),
                               BoundPositions( q2.deltainv ) ) do
            nr1 := FGA_GetNr(q1.deltainv[g], sl1);
            nr2 := FGA_GetNr(q2.deltainv[g], sl2);
            rx := FGA_TrySetRepTable( tab, nr1, nr2, r, -g );
            if rx <> fail then
                if IsIdenticalObj(sl1[ nr1 ], t1)
                      and IsIdenticalObj(sl2[ nr2 ], t2) then
                    return rx;
                fi;
                Add( Q, [ nr1, nr2 ] );
            fi;
        od;
    od;

    return fail;

    end );



#############################################################################
##
#E
