#############################################################################
##
#W  pcgsspec.gi                 GAP library                      Bettina Eick
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.pcgsspec_gi :=
    "@(#)$Id$";


#############################################################################
##

#F  PrimePowerPcSequence( <pcgs> )
##
PrimePowerPcSequence := function( pcgs )
    local   new,  i,  p;
    
    new := List( [1..Length(pcgs)], x -> false );
    p   := RelativeOrders( pcgs );
    for i in [1..Length(pcgs)] do
        new[i] := PrimePowerComponent( pcgs[i], p[i] );
    od;
    return new;
end;


#############################################################################
##
#F  ModifyPcgs( ... )
##
ModifyPcgs := function( pcgs, wf, list, weights, work, g, wt )
    local d, h, S, s, min, tmp, i;

    # the trivial case
    d := DepthOfPcElement( pcgs, g );
    if d > Length( pcgs ) then return d; fi;

    h := ReducedPcElement( pcgs, list[d], g );
    S := PrimePowerComponents( h );

    # insert h in base 
    if weights[ d ] < wt  then
        tmp := weights[ d ];
        weights[ d ] := wt;
        list[ d ] := g;

        # correct work-flag
        work[ d ] := List( work[ d ], x -> true );
        for i in [d..Length( pcgs )]  do
            work[ i ][ d ] := true;
        od;

        # ModifyPcgs with components of h
        for s  in S  do 
            ModifyPcgs( pcgs, wf, list, weights, work, s, 
                        wf.adj( pcgs, s, tmp ));
        od;
        return d;

    # base is not changed 
    else
         
        # modify with components of gg
        min := Length( pcgs ) + 1;
        for s  in S  do
            tmp := wf.adj( pcgs, s, wt );
            min := Minimum( min, 
                   ModifyPcgs(pcgs, wf, list, weights, work , s, tmp) );
        od;
        return min;
    fi;
end;


#############################################################################
##
#F  PcgsSystemWithWf( <pcgs> <wf> )
##
PcgsSystemWithWf := function( pcgs, wf )
    local   m,  list,  weights,  work,  nilp,  h,  i,  j,  g,  S,  
            pos,  s,  wt,  newpcgs,  wset,  layers,  first;
   
    # initialise
    m    := Length( pcgs );
    list := PrimePowerPcSequence( pcgs );
    weights := List( list, x -> wf.one( pcgs, x ) );
    work    := List( [1..m], x -> List( [1..x], y -> true ) );

    # run down series
    nilp := 1;
    h := 1;
    while h <= nilp+1 do

        # run through powers and commutators 
        Info(InfoSpecPcgs, 2, " start layer ",h);
        i := 1;
        while i <= m  do
            j := 1;
            while j <= i  do
                if wf.relevant( pcgs, weights, i, j, h ) and work[i][j]  then
 
                    # set work flag new
                    if wf.useful( weights, i, j, h ) then
                        work[ i ][ j ] := false;
                    fi;

                    # modify with components of power or commutator
                    if i = j  then
                        g := list[ i ] ^ weights[i][3];
                    else
                        g := Comm( list[ i ], list[ j ] );
                    fi;
                    S := PrimePowerComponents( g );
                    pos := m + 1;
                    for s  in S  do
                        wt := wf.weight( pcgs, weights, i, j, h, s );
                        pos := Minimum( pos, 
                        ModifyPcgs( pcgs, wf, list, weights, work, s, wt ) );
                    od;
    
                    # if necessary, set indices new
                    if pos <= i  then
                        i := pos;
                        j := 0;
                    fi;
                fi;
                j := j+1;
            od;
            i := i+1;
        od;
        h := h+1;

        # set nilp
        for i in [1..m] do
            nilp := Maximum( nilp, weights[i][1] );
        od;
    od;

    # sort
    SortParallel( weights, list );

    # compute pcgs
    newpcgs := PcgsByPcSequenceNC( FamilyObj(OneOfPcgs(pcgs)), list );

    # set up layers
    wset := Set( weights );
    layers := List( [1..m], x -> Position( wset, weights[x] ) );

    # set up first 
    first := [1];
    for i in [2..m] do
        if weights[i] <> weights[i-1] then
            Add( first, i );
        fi;
    od;
    Add( first, m+1 );

    return rec( pcgs    := newpcgs, 
                weights := weights, 
                layers  := layers,
                first   := first );
end;


#############################################################################
##
#F  PcgsSystemLGSeries( <pcgs> )
##
PcgsSystemLGSeries := function( pcgs )
    local wf;

    # set up weight function
    wf := rec( 

        adj := function( pcgs, g, wt )
            wt := ShallowCopy( wt );
            wt[ 3 ] := RelativeOrderOfPcElement( pcgs, g );
            return wt;
        end,

        one := function( pcgs, g )
            return [ 1, 1, RelativeOrderOfPcElement( pcgs, g ) ];
        end,

        relevant := function( pcgs, w, i, j, h )
            if i = j  and (w[i][1] = h-1 or w[i][1] = h+1)  then
                return true;
            else
                if w[i][1] = w[j][1]  then
                    if w[i][1] = h-1 and w[i][3] = w[j][3] and 
                      (w[i][2] = 1 or w[j][2] = 1)  then
                        return true;
                    elif w[i][1] = h  and w[i][3] <> w[j][3]  then
                        return true;
                    elif w[i][1] >= h+1  then
                        return true;
                    else
                        return false;
                    fi;
                elif w[i][1] >= h+1 and w[j][1] >= h+1 then
                     return true;
                elif w[i][1] = h+1  and w[j][1] <= h  and w[j][2] = 1  then 
                     return true;
                elif w[i][1] <= h  and w[j][1] = h+1  and w[i][2] = 1  then 
                     return true;
                else 
                     return false;
                fi;
            fi;
        end,

        weight := function( pcgs, w, i, j, h, g )
            local p;

            p := RelativeOrderOfPcElement(pcgs, g);
            if i = j  then
                if w[i][1] = h-1  then
                    return [ w[i][1], w[i][2]+1, w[i][3] ];
                else
                    return w[i];
                fi;
            else
                if w[i][1] = w[j][1]  and w[i][1] = h-1  then
                    return [ w[i][1], w[i][2]+w[j][2], w[i][3] ];
                elif w[i][1] = w[j][1]  and w[i][1] = h  then
                    return [ w[i][1]+1, 1, p ];
                elif w[i][1] = w[j][1]  and w[j][1] >= h+1  then
                    if w[i][3] <> w[j][3] or w[i][3] <> p then
                        return [w[i][1]+1, 1, p];
                    else
                        return [w[i][1], 1, p];
                    fi;
                else
                    return [ Maximum( w[i][1],w[j][1] ), 1, p ];
                fi;
            fi;
        end,

        useful := function( w, i, j, h )
    
            if i = j and w[i][1] >= h+1 then
                return false;
            elif i<>j and w[i][1] = w[j][1] and w[i][1] >= h+1 and
                w[i][3] = w[j][3] then
                return false;
            else
                return true;
            fi;
        end
    );

    return PcgsSystemWithWf( pcgs, wf );
end;


#############################################################################
##
#F  LeastBadHallLayer( <pcgssys>, <i> )
##
LeastBadHallLayer := function( pcgssys, i )
    local m, pi, bad, j, w, pj, k, exponents;

    m  := Length( pcgssys.pcgs );
    pi := pcgssys.weights[ i ][ 3 ];

    # run through powers/commutators and search for bad one
    bad := m + 1;
    for j  in [ i .. m ]  do
        if j = i  then
            w := pcgssys.pcgs[ i ] ^ pi;
            pj := pi;
        else
            w := Comm( pcgssys.pcgs[ j ], pcgssys.pcgs[ i ] );
            pj := pcgssys.weights[ j ][ 3 ];
        fi;
        if DepthOfPcElement( pcgssys.pcgs, w ) <= m then
            exponents := ExponentsOfPcElement( pcgssys.pcgs, w, [i+1..m] );
            k := 1;

            # run through exponent list until bad entry is found
            while k <= Length( exponents )  do

                # test primes
                if exponents[k] <> 0 and 
                   pi <> pcgssys.weights[k+i][3] and 
                   pj <> pcgssys.weights[k+i][3] 
                then
                    bad := Minimum( bad, k+i );
                    k := Length( exponents ) + 1;  
                else
                    k := k + 1;
                fi;
            od;
        fi;

        # if bad is minimal return; otherwise go on 
        if i = bad -1  then
            return bad;
        fi;
    od;
    return bad;
end;


#############################################################################
##
#F  PcgsSystemWithHallSystem( <pcgssys> )
##
PcgsSystemWithHallSystem := function( pcgssys )
    local m, i, k, n, F,
          layer, start, next, size, base, 
          V, M, 
          pi, pk, field, id,
          g, v, A, I, B, l, test, aij, 
          new, solution, j, subs;

    # set up
    m   := Length( pcgssys.pcgs );
    F   := FamilyObj(OneOfPcgs(pcgssys.pcgs));

    # find starting index
    n := m;
    while 1 <= n and pcgssys.weights[n][1] = pcgssys.weights[m][1] do
         n := n - 1;
    od;
    if n = 1 and pcgssys.weights[n][1] = pcgssys.weights[m][1] then
        return pcgssys;
    fi;

    # run up the composition series
    for i in Reversed( [1..n] ) do
        Info(InfoSpecPcgs, 2, " start ",i,"th pcgs element");
        k := LeastBadHallLayer( pcgssys, i );
        while k <= m do
            Info(InfoSpecPcgs, 2, "  bad layer ",k);
            layer := pcgssys.layers[k];
            start := pcgssys.first[ layer ];
            next  := pcgssys.first[ layer+1 ];
            size  := next - start;
            base  := pcgssys.pcgs{[start..next-1]};

            # InitializeSystem inhomogenous system  
            V := [];
            M := List([1..size], x -> []);

            # get primes and field
            pi := pcgssys.weights[ i ][ 3 ];
            pk := pcgssys.weights[ k ][ 3 ];
            field := GF(pk);
            id := One( field );

            # add the power
            g := pcgssys.pcgs[ i ] ^ pi;
            v := ExponentsOfPcElement( pcgssys.pcgs, g, [start..next-1] );
            v := v * id;
 
            # set up matrix
            A := List( base, x -> ExponentsOfPcElement( 
                       pcgssys.pcgs, x^pcgssys.pcgs[i], [start..next-1] ) );
            A := A * id;
            I := A ^ 0;
            B := I;
            for l  in [ 1..pi-1 ]  do
                B := B * A + I;
            od;
            B := (- 1) * B;

            # append to system
            for l  in [ 1..size ]  do
                Append( M[ l ], B[ l ] );
            od;
            Append( V, v );

            # add the commutators
            test := Filtered([i+1..start-1], x -> pcgssys.weights[x][3] <> pk);
            for j in test do
                g := Comm( pcgssys.pcgs[j], pcgssys.pcgs[i] );
                v := ExponentsOfPcElement( pcgssys.pcgs, g, [start..next-1] );
                v := v * id;

                # corresponding matrix
                aij := pcgssys.pcgs[j] ^ pcgssys.pcgs[i];
                A := List( base, x -> ExponentsOfPcElement( 
                                 pcgssys.pcgs, x^aij, [start..next-1] ) );
                A := A * id;
                I := A ^ 0;
                I := (-1) * I;
                B := A + I;

                # append to system
                for l  in [ 1..size ]  do
                    Append( M[ l ], B[ l ] );
                od;
                Append( V, v );
            od;

            # solve system simultaneously
            solution := SolutionMat( M, V );

            # calculate new i-th base element
            new := ShallowCopy( pcgssys.pcgs!.pcSequence );
            subs := PcElementByExponents(pcgssys.pcgs, base, solution);
            new[i] := new[i] * subs;
            pcgssys.pcgs := PcgsByPcSequenceNC( F, new );

            # change k
            k := LeastBadHallLayer( pcgssys, i );
        od;
    od;
    return pcgssys;
end;


#############################################################################
##
#F  LeastBadComplementLayer( <pcgssys>, <i> )
##
LeastBadComplementLayer := function( pcgssys, i )
    local m, p, bad, j, w, exponents, k;

    m := Length( pcgssys.pcgs );
    p := pcgssys.weights[i][3];
    bad := m + 1;

    # look through commutators
    for j in [ 1 .. m ] do
        if pcgssys.weights[j][1] >= pcgssys.weights[i][1] and 
           pcgssys.weights[j][3] <> p then
            w := Comm( pcgssys.pcgs[j], pcgssys.pcgs[i] );
            if DepthOfPcElement( pcgssys.pcgs, w ) <= m then
                exponents := ExponentsOfPcElement( pcgssys.pcgs, w, [i+1..m] );
                k := 1;

                # run through exponent list until bad entry is found
                while k <= Length( exponents )  do
                    if exponents[k] <> 0 and 
                       pcgssys.weights[i+k][1] = pcgssys.weights[j][1] + 1 and
                       pcgssys.weights[i+k][2] = 1  and
                       pcgssys.weights[i+k][3] = p  then
                        if i+k < bad  then
                            bad := i+k;
                        fi;
                        k := Length( exponents ) + 1;
                    else
                        k := k + 1;
                    fi;
                od;
            fi;
        fi;

        ## if bad is minimal return; otherwise go on
        if i = bad - 1  then
            return bad;
        fi;
    od;
    return bad;
end;


#############################################################################
##
#F  PcgsSystemWithComplementSystem( <pcgssys> )
##
PcgsSystemWithComplementSystem := function( pcgssys )
    local m, F, n, i, k, 
          layer, start, next, size, base,
          V, M, l,
          pi, pk, field, 
          nil, test, j, g, v, aij, A, B,
          solution, new, subs;

    m  := Length( pcgssys.pcgs );
    F  := FamilyObj( OneOfPcgs(pcgssys.pcgs) );

    # find starting index
    n := m;
    while 1 <= n and pcgssys.weights[n][1] = pcgssys.weights[m][1] do
         n := n - 1;
    od;
    if n = 1 and pcgssys.weights[n][1] = pcgssys.weights[m][1] then
        return pcgssys;
    fi;

    # run up the composition series
    for i in Reversed( [1..n] ) do
        Info(InfoSpecPcgs, 2, " start ",i,"th pcgs element");
        k := LeastBadComplementLayer( pcgssys, i );
        while k <= m do
            Info(InfoSpecPcgs, 2, "  bad index ",k);
            layer := pcgssys.layers[ k ];
            start := pcgssys.first[ layer ];
            next  := pcgssys.first[ layer+1 ];
            size  := next - start;
            base  := pcgssys.pcgs{[start..next-1]};

            # InitializeSystem inhomogenous system  
            V := [];
            M := List([1..size], x -> []);

            # get primes
            pi := pcgssys.weights[ i ][ 3 ];
            pk := pcgssys.weights[ k ][ 3 ];
            field := GF( pk );

            # pic the p'-generators in the head above
            nil  := pcgssys.weights[k][1]-1;
            test := Filtered( [1..m], x -> pcgssys.weights[x][3] <> pi 
                                      and  pcgssys.weights[x][1] = nil );
            for j in test do
                g := Comm( pcgssys.pcgs[j], pcgssys.pcgs[i] );
                v := ExponentsOfPcElement( pcgssys.pcgs, g, [start..next-1] );
                v := v * One(field);

                # corresponding matrix
                aij := pcgssys.pcgs[j] ^ pcgssys.pcgs[i];
                A := List( base, x -> ExponentsOfPcElement( 
                           pcgssys.pcgs, x^aij, [start..next-1] ) );
                A := A * One(field);
                B := A - A ^ 0;

                # append to system
                for l  in [ 1..size ]  do
                    Append( M[ l ], B[ l ] );
                od;
                Append( V, v );
            od;

            # solve system simultaneously
            solution := SolutionMat( M, V );

            # calculate new i-th base element
            new := ShallowCopy( pcgssys.pcgs!.pcSequence );
            subs:= PcElementByExponents(pcgssys.pcgs, base, solution);
            new[i] := new[i] * subs;
            pcgssys.pcgs := PcgsByPcSequenceNC( F, new );

            # change k
            k := LeastBadComplementLayer( pcgssys, i );
        od;
    od;
    return pcgssys;
end;


#############################################################################
##

#M  SpecialPcgs( <pcgs> )
##
InstallMethod( SpecialPcgs,
    "generic method for pcgs",
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    local   newpcgs,  pcgssys;

    # catch the trivial case
    if Length( pcgs ) = 0 then
        newpcgs := pcgs;
        SetIsSpecialPcgs( pcgs, true );
        SetLGWeights( pcgs, [ ] );
        SetLGLayers( pcgs, [ ] );
        SetLGFirst( pcgs, [1] );

    else
        # compute Leedham-Green series
        Info(InfoSpecPcgs, 1, "compute LG series");
        pcgssys := PcgsSystemLGSeries( pcgs );

        # change to hall base
        Info(InfoSpecPcgs, 1, "exhibit hall system");
        pcgssys := PcgsSystemWithHallSystem( pcgssys );

        # change to complement base
        Info(InfoSpecPcgs, 1, "exhibit complement system");
        pcgssys := PcgsSystemWithComplementSystem( pcgssys );

        # create the special pcgs
        newpcgs := pcgssys.pcgs;
        SetIsSpecialPcgs( newpcgs, true );
        SetLGWeights( newpcgs, pcgssys.weights );
        SetLGLayers( newpcgs, pcgssys.layers );
        SetLGFirst( newpcgs, pcgssys.first );
    fi;
    return newpcgs;
end );


#############################################################################
##
#M  SpecialPcgs( <group> )
##
InstallOtherMethod( SpecialPcgs,
    "generic method for groups",
    true,
    [ IsGroup and IsPcgsComputable ],
    0,

function( group )
    local   spec;

    if HasPcgs(group)  then
        spec := SpecialPcgs( Pcgs( group ) );
    else
        spec := SpecialPcgs(Pcgs(group));
        SetPcgs( group, spec );
    fi;
    return spec;
end );


#############################################################################
##

#E  pcgsspec.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
