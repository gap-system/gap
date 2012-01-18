#############################################################################
##
#W  orbstab.gi                   Polycyc                         Bettina Eick
#W                                                              Werner Nickel
##

#############################################################################
##
#F TransversalInverse( j, trels )
##
TransversalInverse := function( j, trels )
    local l, w, s, p, t;
    l := Product( trels );
    j := j - 1;
    w := [];
    for s in Reversed( [1..Length( trels )] ) do
        p := trels[s];
        l := l/p;
        t := QuoInt( j, l );
        j := RemInt( j, l );
        if t > 0 then Add( w, [s,t] ); fi;
    od;
    return w;
end;

#############################################################################
##
#F SubsWord( word, list )
##
SubsWord := function( word, list )
    local g, w;
    g := list[1]^0;
    for w in word do
        g := g * list[w[1]]^w[2];
    od;
    return g;
end;

#############################################################################
##
#F TransversalElement( j, stab, id )
##
TransversalElement := function( j, stab, id )
    local t;
    if Length( stab.trels ) = 0 then return id; fi;
    t := TransversalInverse(j, stab.trels);
    return SubsWord( t, stab.trans )^-1;
end;

#############################################################################
##
#F Translate( word, t )
##
Translate := function( word, t )
    return List( word, x -> [t[x[1]], -x[2]] );
end;

#############################################################################
##
#F PcpOrbitStabilizer( e, pcp, act, op )
##
## Warning: this function runs forever, if the orbit is infinite!
##
# FIXME: This function is documented and should be turned into a GlobalFunction
PcpOrbitStabilizer := function( e, pcp, act, op )
    local  rels, orbit, trans, trels, tword, stab, word, w, i, f, j, n, t, s;

    # check relative orders
    if IsList( pcp ) then
        rels := List( pcp, x -> 0 );
    else
        rels := RelativeOrdersOfPcp( pcp );
    fi;

    # set up
    orbit := [e];
    trans := [];
    trels := [];
    tword := [];
    stab  := [];
    word  := [];

    # construct orbit and stabilizer
    for i in Reversed( [1..Length(pcp)] ) do

        # get new point
        f := op( e, act[i] );
        j := Position( orbit, f );

        # if it is new, add all blocks
        n := orbit;
        t := [];
        s := 1;
        while IsBool( j ) do
            n := List( n, x -> op( x, act[i] ) );
            Append( t, n );
            j := Position( orbit, op( n[1], act[i] ) );
            s := s + 1;
        od;

        # add to orbit
        Append( orbit, t );

        # add to transversal
        if s > 1 then
            Add( trans, pcp[i]^-1 );
            Add( trels, s );
            Add( tword, i );
        fi;

        # compute stabiliser element
        if rels[i] = 0 or s < rels[i] then
            if j = 1 then
                Add( stab, pcp[i]^s );
                Add( word, [[i,s]] );
            else
                t := TransversalInverse(j, trels);
                Add( stab, pcp[i]^s * SubsWord( t, trans ) );
                Add( word, Concatenation( [[i,s]], Translate( t, tword )));
            fi;
        fi;
    od;

    # return orbit and stabilizer
    return rec( orbit := orbit,
                trels := trels,
                trans := trans,
                stab  := Reversed(stab),
                word  := Reversed(word) );
end;

#############################################################################
##
#F  PcpOrbitsStabilizers( dom, pcp, act, op )
##
##  dom is the operation domain
##  pcp is a igs or pcp of a group
##  act is the action corresponding to pcp
##  op is the operation of act on dom
##
##  The function returns a list of records - one for each orbit. Each record
##  contains a representative and an igs of the stabilizer.
##
##  Warning: this function runs forever, if one of the orbits is infinite!
##
# FIXME: This function is documented and should be turned into a GlobalFunction
PcpOrbitsStabilizers := function( dom, pcp, act, op )
    local todo, orbs, e, o;
    todo := [1..Length(dom)];
    orbs := [];
    while Length( todo ) > 0 do
        e := dom[todo[1]];
        o := PcpOrbitStabilizer( e, pcp, act, op );
        Add( orbs, rec( repr := o.orbit[1], 
                        leng := Length(o.orbit),
                        stab := o.stab,
                        word := o.word ) );
        todo := Difference( todo, List( o.orbit, x -> Position(dom,x)));
    od;
    return orbs;
end;

#############################################################################
##
#F RandomPcpOrbitStabilizer( e, pcp, act, op )
##
RandomPcpOrbitStabilizer := function( e, pcp, act, op )
    local  one, acts, gens, O, T, S, count, i, j, t, g, im, index, l, s;

    # a trivial check
    if Length( pcp ) = 0 then return rec( orbit := [e], stab := pcp ); fi;

    # generators and inverses
    acts := Concatenation( AsList( act ), List( act, g -> g^-1 ) );
    gens := Concatenation( AsList( pcp ), List( pcp, g -> g^-1 ) );
    one  := gens[1]^0;

    # set up
    O := [ e ];            # orbit
    T := [ one ];          # transversal
    S := [];               # stabilizer

    # set counter
    count := 0;

    i := 1;
    while i <= Length(O) do
        e := O[ i ];
        t := T[ i ];

        for j in [1..Length(gens)] do
            im := op( e, acts[j] );

            index := Position( O, im );
            if index = fail then
                Add( O, im );
                Add( T, t * gens[j] );

                if Length(O) > 500 then
                    Print( "#I  Orbit longer than limit: exiting.\n" );
                    return rec( orbit := O, stab := S );
                fi;
            else
                l := Length( S );
                s := t * gens[j] * T[ index ]^-1;
                if s <> one then
                    S := AddToIgs( S, [s] );
                    if l = Length(S) then
                        count := count + 1;
                    else
                        count := 0;
                    fi;
                    if count > 100 then 
                        Print( "#I  Stabilizer not increasing: exiting.\n" );
                        return rec( orbit := O, stab := S ); 
                    fi;
                fi;
            fi;
        od;

        i := i+1;
    od;
    Print( "#I  Orbit calculation complete.\n" );
    return rec( orbit := O, stab := S );
end;

#############################################################################
##
#F RandomCentralizerPcpGroup( G, g )
##
# FIXME: This function is documented and should be turned into a GlobalFunction
RandomCentralizerPcpGroup := function( G, g )
    local gens, stab, h;
    gens := Igs( G );
    if IsPcpElement( g ) then
        stab := RandomPcpOrbitStabilizer( g, gens, gens, OnPoints ).stab;
    elif IsSubgroup( G, g ) then 
        stab := ShallowCopy( gens );
        for h in GeneratorsOfGroup( g ) do
            stab := RandomPcpOrbitStabilizer( h, stab, stab, OnPoints ).stab;
        od;
    else
        Print("g must be a subgroup or an element of G \n");
    fi;
    return Subgroup( G, stab );
end;

#############################################################################
##
#F RandomNormalizerPcpGroup( G, N )
##
# FIXME: This function is documented and should be turned into a GlobalFunction
RandomNormalizerPcpGroup := function( G, N )
    local gens, stab;
    gens := Igs(G);
    stab := RandomPcpOrbitStabilizer( N, gens, gens, OnPoints);
    return Subgroup( G, stab.stab );
end;
