#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#F  PrimePowerPcSequence( <pcgs> )
##
BindGlobal( "PrimePowerPcSequence", function( pcgs )
    local   new,  i,  p;

    new := List( [1..Length(pcgs)], x -> false );
    p   := RelativeOrders( pcgs );
    for i in [1..Length(pcgs)] do
        new[i] := PrimePowerComponent( pcgs[i], p[i] );
    od;
    return new;
end );


#############################################################################
##
#F  ModifyPcgs( ... )
##
DeclareGlobalName("ModifyPcgs");
BindGlobal( "ModifyPcgs", function( pcgs, wf, list, weights, work, g, wt )
    local d, h, S, s, min, tmp, i;

    # the trivial case
    d := DepthOfPcElement( pcgs, g );
    if d > Length( pcgs ) then return d; fi;

    h := ReducedPcElement( pcgs, list[d], g );
    S := PrimePowerComponents( h );

    # insert h in base
    if weights[ d ] < wt  then

        Info(InfoSpecPcgs, 3, " insert ", g );
        Info(InfoSpecPcgs, 3, " at position ",d," with weight ", wt);
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
end );


#############################################################################
##
#F  PcgsSystemWithWf( <pcgs> <wf> )
##
BindGlobal( "PcgsSystemWithWf", function( pcgs, wf )
    local   ppcgs,  m,  list,  weights,  work,  nilp,  h,  i,  j,  g,  S,
            pos,  s,  wt,  newpcgs,  wset,  layers,  first;

    ppcgs := PrimePowerPcSequence( pcgs );

    # initialise
    m    := Length( pcgs );
    list := ShallowCopy( ppcgs );
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
                    Info(InfoSpecPcgs, 3, " try ",i," ",j);

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

    # compute pcgs - be careful!
    if ppcgs = AsList( pcgs ) and
       ForAll( [1..m], x -> DepthOfPcElement(pcgs, list[x]) = x )
    then
        newpcgs := pcgs;
    else
        newpcgs := PcgsByPcSequenceNC( FamilyObj(OneOfPcgs(pcgs)), list );
        SetRelativeOrders(newpcgs, List(weights, x -> x[3]));
        SetOneOfPcgs( newpcgs, OneOfPcgs(pcgs) );
    fi;

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
end );


#############################################################################
##
#F  PcgsSystemLGSeries( <pcgs> )
##
BindGlobal( "PcgsSystemLGSeries", function( pcgs )
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
end );


#############################################################################
##
#F  LeastBadHallLayer( <pcgssys>, <i> )
##
BindGlobal( "LeastBadHallLayer", function( pcgssys, i )
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
end );


#############################################################################
##
#F  PcgsSystemWithHallSystem( <pcgssys> )
##
BindGlobal( "PcgsSystemWithHallSystem", function( pcgssys )
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

            # InitializeSystem inhomogeneous system
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
            subs := PcElementByExponentsNC(pcgssys.pcgs, base, solution);
            new[i] := new[i] * subs;
            pcgssys.pcgs := PcgsByPcSequenceNC( F, new );

            # change k
            k := LeastBadHallLayer( pcgssys, i );
        od;
    od;
    return pcgssys;
end );


#############################################################################
##
#F  LeastBadComplementLayer( <pcgssys>, <i> )
##
BindGlobal( "LeastBadComplementLayer", function( pcgssys, i )
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
end );


#############################################################################
##
#F  PcgsSystemWithComplementSystem( <pcgssys> )
##
BindGlobal( "PcgsSystemWithComplementSystem", function( pcgssys )
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

            # InitializeSystem inhomogeneous system
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
            subs:= PcElementByExponentsNC(pcgssys.pcgs, base, solution);
            new[i] := new[i] * subs;
            pcgssys.pcgs := PcgsByPcSequenceNC( F, new );

            # change k
            k := LeastBadComplementLayer( pcgssys, i );
        od;
    od;
    return pcgssys;
end );


#############################################################################
##
#M  SpecialPcgs( <pcgs> )
##
InstallMethod( SpecialPcgs, "method for special pcgs", true,
    [ IsSpecialPcgs ],
    # we need to rank this method higher -- otherwise the extra filters in
    # the following method give it the same rank...
    10,IdFunc);


InstallMethod( SpecialPcgs,
    "generic method for pcgs",
    true,
    [ IsPcgs and IsFiniteOrdersPcgs and IsPrimeOrdersPcgs ],
    0,

function( pcgs )
    local   newpcgs,  pcgssys,w;

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
        if IsBound(pcgssys.pcgs!.LGWeights) then
          # pcgs is reused -- force new one
          pcgssys.pcgs:=PcgsByPcSequence(FamilyObj(OneOfPcgs(pcgs)),
            pcgssys.pcgs!.pcSequence);
        fi;

        # create the special pcgs
        newpcgs := pcgssys.pcgs;
        SetIsSpecialPcgs( newpcgs, true );

        w:=pcgssys.weights;
        if w[Length(w)][1]=1 then
          SetIndicesCentralNormalSteps( newpcgs, pcgssys.first );
          if Length(Set(RelativeOrders(newpcgs)))=1 then
            SetIndicesPCentralNormalStepsPGroup( newpcgs, pcgssys.first );
          fi;
        fi;

        SetLGWeights( newpcgs, pcgssys.weights );
        SetLGLayers( newpcgs, pcgssys.layers );
        SetLGFirst( newpcgs, pcgssys.first );
        SetIndicesEANormalSteps( newpcgs, pcgssys.first );
        SetIndicesChiefNormalSteps( newpcgs, pcgssys.first );
        SetIsFiniteOrdersPcgs( newpcgs, true );
        SetIsPrimeOrdersPcgs( newpcgs, true );
    fi;
    if HasGroupOfPcgs (pcgs) then
        SetGroupOfPcgs (newpcgs, GroupOfPcgs (pcgs));
    fi;
    return newpcgs;
end );

#############################################################################
##
#M  LGHeads( <pcgs> )
##
InstallMethod( LGHeads, "for special pcgs", true,
               [ IsSpecialPcgs ], 0,
function( pcgs )
    local h, i, w, j;
    h := [];
    i := 1;
    w := LGWeights( pcgs );
    for j in [1..Length(w)] do
        if w[j][1] = i then
            Add( h, j );
            i := i + 1;
        fi;
    od;
    Add( h, Length( w ) + 1 );
    return h;
end);

#############################################################################
##
#M  LGTails( <pcgs> )
##
InstallMethod( LGTails, "for special pcgs", true,
               [ IsSpecialPcgs ], 0,
function( pcgs )
    local h, w, i, j, t;
    h := LGHeads( pcgs );
    w := LGWeights( pcgs );
    t := [];
    for i in [1..Length(h)-1] do
        j := h[i];
        while j <= Length( w ) and w[h[i]][1] = w[j][1] and w[j][2] = 1 do
            j := j + 1;
        od;
        Add( t, j );
    od;
    return t;
end);

#############################################################################
##
#M  SpecialPcgs( <group> )
##
InstallOtherMethod( SpecialPcgs,
    "generic method for groups",
    true,
    [ IsGroup ],
    0,

function( group )
    local   spec;

    if HasPcgs(group)  then
        spec := SpecialPcgs( Pcgs( group ) );
    else
        spec := SpecialPcgs( AttributeValueNotSet( Pcgs, group ) );
        SetPcgs( group, spec );
    fi;
    SetGroupOfPcgs (spec, group);
    return spec;
end );

InstallOtherMethod( SpecialPcgs,"last resort method which tests solvability",
    true,[IsGroup],0,
function(G)
  # this test should always fail (because otherwise the other method
  # that uses 'CanEasilyComputePcgs' will have been called). It is there
  # just to avoid infinite recursion if methods get sorted in a strange way.
  if HasIsSolvableGroup(G) then
    TryNextMethod();
  fi;
  if not IsSolvableGroup(G) then
    Error("<G> must be solvable to permit computation of a special pcgs");
  else
    return SpecialPcgs(G);
  fi;
end);

#############################################################################
##
#M  IsomorphismSpecialPcGroup( <group> )
##
InstallMethod( IsomorphismSpecialPcGroup, "method for pc groups",
    true, [ IsPcGroup ], 0,
function(G)
local s,H,iso,pc,w;
  s:=SpecialPcgs(G);
  H:=PcGroupWithPcgs(s);
  pc:=FamilyPcgs(H);
  SetLGWeights(pc,LGWeights(s));
  SetLGLayers(pc,LGLayers(s));
  SetLGFirst(pc,LGFirst(s));
  SetIsSpecialPcgs(pc,true);
  if Length(LGWeights(pc)) = 0 or LGWeights(pc)[Length(LGWeights(pc))][1]=1 then
        SetIsPcgsCentralSeries(pc,true);
  fi;
  SetIndicesEANormalSteps( pc, LGFirst(pc) );
  SetIndicesChiefNormalSteps( pc, LGFirst(pc) );
  w:=LGWeights(pc);
  if Length(w) > 0 and w[Length(w)][1]=1 then
    SetIndicesCentralNormalSteps( pc, LGFirst(pc));
    if Length(Set(RelativeOrders(pc)))=1 then
      SetIndicesPCentralNormalStepsPGroup( pc, LGFirst(pc) );
    fi;
  fi;


  iso:=GroupHomomorphismByImagesNC(G,H,s,pc);
  SetIsBijective( iso, true );
  SetSpecialPcgs(H,pc);
  SetPcgs(H,pc);
  # note: `ImagesSource' might be
  # physically a different group than the `Range' H.
  SetSpecialPcgs(ImagesSource(iso),pc);
  SetPcgs(ImagesSource(iso),pc);
  return iso;
end);

InstallMethod( IsomorphismSpecialPcGroup, "generic method for groups",
    true, [ IsGroup ], 0,
function(G)
local iso;
  iso:=IsomorphismPcGroup(G);
  return iso*IsomorphismSpecialPcGroup(Range(iso));
end);

#############################################################################
##
#M  InducedPcgsWrtSpecialPcgs( <group> )
##
InstallOtherMethod( InducedPcgsWrtSpecialPcgs, "method for pc groups",
    true, [ IsPcGroup ], 0,
function( U )
local spec, ind;
    spec := SpecialPcgs( FamilyPcgs( U ) );
    if HasPcgs(U) and spec=HomePcgs(U) then
      return InducedPcgsWrtHomePcgs(U);
    fi;
    ind := InducedPcgsByGeneratorsNC( spec, GeneratorsOfGroup(U) );
    SetGroupOfPcgs (ind, U);
    return ind;
end );

InstallOtherMethod( InducedPcgsWrtSpecialPcgs, "generic method for groups",
    true, [ IsGroup ], 0,
function( U )
local spec, ind;
  spec := SpecialPcgs( Parent( U ) );
  ind := InducedPcgsByGeneratorsNC( spec, GeneratorsOfGroup(U) );
  SetGroupOfPcgs (ind, U);
  return ind;
end );

BindGlobal( "IndPcgsWrtSpecFromFamOrHome", function( U )
local spec, ind;
  spec := SpecialPcgs( FamilyPcgs( U ) );
  if spec=HomePcgs(U) then
    return InducedPcgsWrtHomePcgs(U);
  elif IsSortedPcgsRep(spec) and spec!.sortingPcgs=HomePcgs(U) then
    ind := InducedPcgsByPcSequenceNC(spec,AsList(InducedPcgsWrtHomePcgs(U)));
  else
     ind := InducedPcgsByGeneratorsNC( spec, InducedPcgsWrtHomePcgs(U) );
  fi;
  SetGroupOfPcgs (ind, U);
  return ind;
end );

InstallOtherMethod( InducedPcgsWrtSpecialPcgs,
  "for groups that have already an induced pcgs wrt home pcgs", true,
  [ IsGroup and HasInducedPcgsWrtHomePcgs], 0,
IndPcgsWrtSpecFromFamOrHome);

InstallOtherMethod( InducedPcgsWrtSpecialPcgs,
  "for groups that have already an induced pcgs wrt family pcgs", true,
  [ IsGroup and HasInducedPcgsWrtFamilyPcgs], 0,
IndPcgsWrtSpecFromFamOrHome);

#############################################################################
##
#M LGWeights( pcgs )
##
InstallMethod( LGWeights,
               "for induced wrt special",
               true,
               [IsInducedPcgsWrtSpecialPcgs],
               0,
function( pcgs )
    local spec, sweights, weights, i, g, d;

    # catch special pcgs
    spec := ParentPcgs( pcgs );
    sweights := LGWeights( spec );

    # rewrite weights
    weights := List( pcgs, x -> true );
    for i in [1..Length(pcgs)] do
        g := pcgs[i];
        d := DepthOfPcElement( spec, g );
        weights[i] := sweights[d];
    od;
    return weights;
end );

#############################################################################
##
#M LGLayers( pcgs )
##
InstallMethod( LGLayers,
               "for induced wrt special",
               true,
               [IsInducedPcgsWrtSpecialPcgs],
               0,
function( pcgs )
    local weights, layers, layer, o, i, w;

    weights := LGWeights( pcgs );
    layers  := List( pcgs, x -> true );
    layer   := 1;
    o       := weights[1];
    for i in [1..Length( pcgs )] do
        w := weights[i];
        if w <> o then
            o := w;
            layer := layer + 1;
        fi;
        layers[i] := layer;
    od;
    return layers;
end );

#############################################################################
##
#M LGFirst( pcgs )
##
InstallMethod( LGFirst,
               "for induced wrt special",
               true,
               [IsInducedPcgsWrtSpecialPcgs],
               0,
function( pcgs )
    local weights, first, o, i, w;

    weights := LGWeights( pcgs );
    first   := [1];
    o       := weights[1];
    for i in [1..Length( pcgs )] do
        w := weights[i];
        if w <> o then
            o := w;
            Add( first, i );
        fi;
    od;
    Add( first, Length(pcgs) + 1 );
    return first;
end );

#############################################################################
##
#M LGLength( G )
##
InstallMethod( LGLength,
               "for groups",
               true,
               [ IsGroup ],
               0,
function( G )

    if not IsSolvableGroup( G ) then
        return fail;
    fi;
    return Length( Set( LGWeights( SpecialPcgs( G ) ) ) );
end );

#############################################################################
##
#M  PClassPGroup( <G> )   . . . . . . . . . .  . . . . . . <p>-central series
##
InstallMethod( PClassPGroup,
    "for groups with special pcgs",
    true, [ IsPGroup and HasSpecialPcgs ], 1,
    function( G )

    return LGLength( G );
    end );

#############################################################################
##
#M  RankPGroup( <G> ) . . . . . . . . . . . .  . . . . . . <p>-central series
##
InstallMethod( RankPGroup,
    "for groups with special pcgs",
    true, [ IsPGroup and HasSpecialPcgs ], 1,
    function( G )

    return LGFirst( SpecialPcgs( G ) )[ 2 ] - 1;
    end );

#############################################################################
##
#F SpecialPcgsSubgroup( G, i )
##
BindGlobal( "SpecialPcgsSubgroup", function( G, i )
    local spec, firs, sub;
    spec := SpecialPcgs( G );
    firs := LGFirst( spec );
    sub  := InducedPcgsByPcSequenceNC( spec, spec{[firs[i]..Length(spec)]} );
    return SubgroupByPcgs( G, sub );
end );

#############################################################################
##
#F SpecialPcgsFactor( G, i )
##
BindGlobal( "SpecialPcgsFactor", function( G, i )
    return G / SpecialPcgsSubgroup( G, i );
end );

#############################################################################
##
#M  IndicesEANormalSteps( <pcgs> )
##
InstallMethod( IndicesEANormalSteps, "special pcgs: LGFirst", true,
        [ IsSpecialPcgs ], 0, LGFirst );

BindGlobal( "DoCentralSeriesPcgsIfNilpot", function(G)
local w;
  w:=LGWeights(SpecialPcgs(G));
  if w[Length(w)][1]<>1 then
    Error("The group is not nilpotent");
  fi;
  return SpecialPcgs(G);
end );

InstallOtherMethod( PcgsCentralSeries, "if special pcgs is known",
  true,[HasSpecialPcgs],0,DoCentralSeriesPcgsIfNilpot);

InstallOtherMethod( PcgsCentralSeries, "for pc groups use SpecialPcgs",
  true,[IsPcGroup],0,DoCentralSeriesPcgsIfNilpot);

InstallOtherMethod( PcgsPCentralSeriesPGroup, "for pc groups use SpecialPcgs",
  true,[IsPcGroup],0,DoCentralSeriesPcgsIfNilpot);

InstallOtherMethod( PcgsCentralSeries, "for pcgs computable use SpecialPcgs",
  true,[CanEasilyComputePcgs],0,DoCentralSeriesPcgsIfNilpot);

InstallOtherMethod( PcgsPCentralSeriesPGroup,
  "for pcgs computable use SpecialPcgs",
  true,[CanEasilyComputePcgs],0,DoCentralSeriesPcgsIfNilpot);

BindGlobal( "PcgsElAbSerFromSpecPcgs", function(G)
local s;
  if HasHomePcgs(G)
     and IsPcgsElementaryAbelianSeries(InducedPcgsWrtHomePcgs(G)) then
    return InducedPcgsWrtHomePcgs(G);
    # prefer the `HomePcgs' because wrt. it we store inducedness and for pc
    # groups its the family pcgs wrt. calculations are quicker
  fi;
  s:=SpecialPcgs(G);
  return s;
end );

InstallOtherMethod(PcgsElementaryAbelianSeries, "if special pcgs is known",
  true,[HasSpecialPcgs],0,PcgsElAbSerFromSpecPcgs);

InstallMethod(PcgsElementaryAbelianSeries,"for PCgroups via SpecialPcgs",
  true,[IsPcGroup],0,PcgsElAbSerFromSpecPcgs);
