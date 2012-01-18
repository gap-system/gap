#############################################################################
##
#W  twocohom.gi                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##

#############################################################################
##
#F  CollectedWordSQ( C, u, v ) 
##
##  The tail of  a conjugate  i^j  (i>j) or a   power i^p (i=j) is  stored at
##  posiition (i^2-i)/2+j
##
InstallGlobalFunction( CollectedWordSQ, function( C, u, v )
    local   w, p, c, m, g, n, i, j, x, mx, l1, l2, l; 

    # convert lists in to word/module pair
    if IsList(v)  then
        v := rec( word := v,  tail := [] );
    fi;
    if IsList(u)  then
        u := rec( word := u,  tail := [] );
    fi;

    # if <v> is trivial  return <u>
    if 0 = Length(v.word) and 0 = Length(v.tail)  then
        return u;
    fi;

    # if <u> is trivial  return <v>
    if 0 = Length(u.word) and 0 = Length(u.tail)  then
        return v;
    fi;

    # if <v> has trivial word but a nontrivial tail add tails
    if 0 = Length(v.word)  then
        u := ShallowCopy(u);
        for i  in [ 1 .. Length(v.tail) ]  do
            if IsBound(v.tail[i])  then
                if IsBound(u.tail[i])  then
                    u.tail[i] := u.tail[i] + v.tail[i];
                else
                    u.tail[i] := v.tail[i];
                fi;
            fi;
        od;
        return u;
    fi;

    # unpack <u> into <x>
    x := C.list;
    n := Length(x);
    for i  in [ 1 .. n ]  do
        x[i] := 0;
    od;
    for i  in [ 1, 3 .. Length(u.word)-1 ]  do
        x[u.word[i]] := u.word[i+1];
    od;

    # <mx> contains the tail of <x>
    mx := ShallowCopy(u.tail);

    # get stacks
    w := C.wstack;
    p := C.pstack;
    c := C.cstack;
    m := C.mstack;

    # put <v> onto the stack
    w[1] := v.word;
    p[1] := 1;
    c[1] := 1;
    m[1] := ShallowCopy(v.tail);

    # run until the stack is empty
    l := 1;
    while 0 < l  do

        # remove next generator from stack
        g := w[l][p[l]];

        # apply generator to <mx>
        for i  in [ 1 .. Length(mx) ]  do
            if IsBound(mx[i])  then

                # we use the transposed for technical reasons
                mx[i] := C.module[g] * mx[i];
            fi;
        od;

        # raise current exponent
        c[l] := c[l]+1;

        # if exponent is too big
        if w[l][p[l]+1] < c[l]  then

            # reset exponent
            c[l] := 1;

            # move position
            p[l] := p[l] + 2;

            # if position is too big
            if Length(w[l]) < p[l]  then

                # modify tail (add both tails)
                l1 := Length(mx);
                l2 := Length(m[l]);
                for i  in [ 1 .. Minimum(l1,l2) ]  do
                    if IsBound(mx[i])  then
                        if IsBound(m[l][i])  then
                            mx[i] := mx[i]+m[l][i];
                        fi;
                    elif IsBound(m[l][i])  then
                        mx[i] := m[l][i];
                    fi;
                od;
                if l1 < l2  then
                    for i  in [ l1+1 .. l2 ]  do
                        if IsBound(m[l][i])  then
                            mx[i] := m[l][i];
                        fi;
                    od;
                fi;

                # and unbind word
                m[l] := 0;
                l := l - 1;
            fi;
        fi;

        # now move generator to correct position
        for i  in [ n, n-1 .. g+1 ]  do
            if x[i] <> 0  then
                l := l+1;
                w[l] := C.relators[i][g];
                c[l] := 1;
                p[l] := 1;
                l1   := (i^2-i)/2+g;
                if not l1 in C.avoid  then
                    if IsBound(mx[l1])  then
                        mx[l1] := C.mone + mx[l1];
                    else
                        mx[l1] := C.mone;
                    fi;
                fi;
                m[l] := mx;
                mx := [];
                l2 := [];
                if not l1 in C.avoid  then
                    l2[l1] := C.mone;
                fi;
                for j  in [ 2 .. x[i] ]  do
                    l := l+1;
                    w[l] := C.relators[i][g];
                    c[l] := 1;
                    p[l] := 1;
                    m[l] := l2;
                od;
                x[i] := 0;
            fi;
        od;

        # raise exponent
        x[g] := x[g] + 1;

        # and check for overflow
        if x[g] = C.orders[g]  then
            x[g] := 0;
            if C.relators[g][g] <> 0  then
                l1 := C.relators[g][g];
                for i  in [ 1, 3 .. Length(l1)-1 ]  do
                    x[l1[i]] := l1[i+1];
                od;
            fi;
            l1 := (g^2+g)/2;
            if not l1 in C.avoid  then
                if IsBound(mx[l1])  then
                    mx[l1] := C.mone + mx[l1];
                else
                    mx[l1] := C.mone;
                fi;
            fi;
        fi;
    od;

    # and return result
    w := [];
    for i  in [ 1 .. Length(x) ]  do
        if x[i] <> 0  then
            Add( w, i );
            Add( w, x[i] );
        fi;
    od;
    return rec( word := w,  tail := mx );
end );

#############################################################################
##
#F  CollectorSQ( G, M, isSplit )
##
InstallGlobalFunction( CollectorSQ, function( G, M, isSplit )
    local  r,  pcgs,  o,  i,  j,  word,  k, Gcoll;

    # convert word into gen/exp form
    word := function( pcgs, w )
        local   r,  l,  k;
        if OneOfPcgs( pcgs ) = w  then
            r := 0;
        else
            l := ExponentsOfPcElement( pcgs, w );
            r := [];
            for k  in [ 1 .. Length(l) ]  do
                if l[k] <> 0  then
                    Add( r, k );
                    Add( r, l[k] );
                fi;
            od;
        fi;
        return r;
    end;

    # convert relators into list of lists
    if IsPcgs( G ) then 
        pcgs := G;
    else
        pcgs := Pcgs( G );
    fi;
    r := [];
    o := RelativeOrders( pcgs );
    for i  in [ 1 .. Length(pcgs) ]  do
        r[i] := [];
        for j  in [ 1 .. i-1 ]  do
            r[i][j] := word( pcgs, pcgs[i]^pcgs[j]);
        od;
        r[i][i] := word( pcgs, pcgs[i]^o[i] );
    od;

    # create collector for G
    Gcoll := rec( );
    Gcoll.relators := r;
    Gcoll.orders := o;

    # create stacks
    Gcoll.wstack := [];
    Gcoll.estack := [];
    Gcoll.pstack := [];
    Gcoll.cstack := [];
    Gcoll.mstack := [];

    # create collector list
    Gcoll.list := List( pcgs, x -> 0 );

    # in case we are not interested in the module
    if IsBool( M ) then return Gcoll; fi;

    # copy collector and add module generators
    r := ShallowCopy(Gcoll);

    # create module gens (the transposed is a technical detail)
    r.module:=List(M.generators,i->ImmutableMatrix(M.field,TransposedMat(i)));
    r.mone  :=ImmutableMatrix(M.field,(IdentityMat(M.dimension, M.field)));
    r.mzero :=ImmutableMatrix(M.field,Zero(r.mone));

    # add avoid 
    r.avoid := [];
    if isSplit  then
        k := Characteristic( M.field );
        for i  in [ 1 .. Length(r.orders) ]  do
            for j  in [ 1 .. i ]  do
		# we can avoid
		if Order(pcgs[i]) mod k <>0 and Order(pcgs[j]) mod k <>0 then
		# was: r.orders[i] <> k and r.orders[j] <> k  then
                    AddSet( r.avoid, (i^2-i)/2 + j );
                fi;
            od;
        od;
    fi;

    # and return collector
    return r;
end );

#############################################################################
##
#F  AddEquationsSQ( eq, t1, t2 )
##
InstallGlobalFunction( AddEquationsSQ, function( eq, t1, t2 )
    local   i,  j,  l,  v,  w,  x,  n,  c;

    # if <t1> = <t2>  return
    if t1 = t2  then return; fi;

    # compute <t1> - <t2>
    t1 := ShallowCopy(t1);
    for i  in [ 1 .. Length(t2) ]  do
        if IsBound(t2[i])  then
            if IsBound(t1[i])  then
                t1[i] := t1[i] - t2[i];
            else
                t1[i] := -t2[i];
            fi;
        fi;
    od;

    # make lines
    l := List( eq.vzero,  x -> [] );
    v := [];
    for i  in [ 1 .. Length(t1) ]  do
        if IsBound(t1[i])  then
            for j  in [ 1 .. eq.dimension ]  do
                if t1[i][j] <> eq.vzero then
                    l[j][i] := ShallowCopy(t1[i][j]);
                    AddCoeffs( l[j][i], v );
                    ShrinkRowVector(l[j][i]);
                fi;
            od;
        fi;
    od;

    # and reduce lines
    n := eq.dimension;
    for j  in [ 1 .. n ]  do
        x := l[j];
        v := Length(x);
        if 0 < v  then w := (v-1)*n + Length(x[v]);  fi;
        while 0 < v and IsBound(eq.system[w])  do
            c := -x[v][Length(x[v])];
            for i  in eq.spos[w]  do
                if IsBound(x[i])  then
                    x[i] := ShallowCopy( x[i] );
                    AddCoeffs( x[i], eq.system[w][i], c );
                    ShrinkRowVector(x[i]);
                    if 0 = Length(x[i])  then
                        Unbind(x[i]);
                    fi;
                else
                    x[i] := c * eq.system[w][i];
                fi;
            od;
            v := Length(x);
            if 0 < v  then w := (v-1)*n + Length(x[v]);  fi;
        od;
        if 0 < v  then
            eq.system[w] := x * (1/x[v][Length(x[v])]);
            eq.spos[w]   := Filtered( [1..eq.nrels], t -> IsBound(x[t]) );
        fi;
    od;
end );

#############################################################################
##
#F  SolutionSQ( C, eq )
##
InstallGlobalFunction( SolutionSQ, function( C, eq )
    local   x,  e,  d,  t,  j,  v,  i,  n,  p,  w;

    # construct null vector
    n := [];
    for i  in [ 1 .. eq.nrels-Length(C.avoid) ]  do
        Append( n, eq.vzero );
    od;

    # generated position 
    C.unavoidable := [];
    j := 1;
    for i  in [ 1 .. eq.nrels ]  do
        if not i in C.avoid  then
            C.unavoidable[i] := j;
            j := j+1;
        fi;
    od;

    # blow up vectors
    t := [];
    w := [];
    for j  in [ 1 .. Length(eq.system) ]  do
        if IsBound(eq.system[j])  then
            v := ShallowCopy(n);
            for i  in eq.spos[j]  do
                if not i in C.avoid  then
                    p := eq.dimension*(C.unavoidable[i]-1);
                    v{[p+1..p+Length(eq.system[j][i])]} := eq.system[j][i];
                fi;
            od;
            ShrinkRowVector(v);
            t[Length(v)] := v;
            AddSet( w, Length(v) );
        fi;
    od;

    # normalize system
    v := 0*eq.vzero[1];
    for i  in w  do
        for j  in w  do
            if j > i  then
                p := t[j][i];
                if p <> v  then
                    t[j] := ShallowCopy( t[j] );
                    AddCoeffs( t[j], t[i], -p );
                    ShrinkRowVector(t[j]);
                fi;
            fi;
        od;
    od;

    # compute homogeneous solution
    d := Difference( [ 1 .. (eq.nrels-Length(C.avoid))*eq.dimension ],  w );
    v := [];
    e := eq.vzero[1]^0;
    for i  in d  do
        x := ShallowCopy(n);
        x[i] := e;
        for j  in w  do
            if j >= i  then
                x[j] := -t[j][i];
            fi;
        od;
        Add( v, x );
    od;
    if 0 = Length(C.avoid)  then
        return v;
    fi;

    # construct null vector
    n := [];
    for i  in [ 1 .. eq.nrels ]  do
        Append( n, eq.vzero );
    od;

    # construct a blow up matrix
    i := [];
    for j  in [ 1 .. eq.nrels ]  do
        if not j in C.avoid  then
            Append( i, (j-1)*eq.dimension + [ 1 .. eq.dimension ] );
        fi;
    od;

    # blowup the vectors
    e := [];
    for x  in v  do
        d := ShallowCopy(n);
        d{i} := x;
        Add( e, d );
    od;

    # and return
    return e;
end );

#############################################################################
##
#F  TwoCocyclesSQ( C, G, M )
##
InstallGlobalFunction( TwoCocyclesSQ, function( C, G, M )
    local   pairs, i,  j,  k, w1, w2, eq, p, n;
            
    # get number of generators
    n := Length(Pcgs(G));

    # collect equations in <eq>
    eq := rec( vzero     := C.mzero[1],
               mzero     := C.mzero,
               dimension := Length(C.mzero),
               nrels     := (n^2+n)/2,
               spos      := [],
               system    := [] );

    # precalculate (ij) for i > j
    pairs := List( [1..n], x -> [] );
    for i  in [ 2 .. n ]  do
        for j  in [ 1 .. i-1 ]  do
            pairs[i][j] := CollectedWordSQ( C, [i,1], [j,1] );
        od;
    od;

    # consistency 1:  k(ji) = (kj)i
    for i  in [ n, n-1 .. 1 ]  do
        for j  in [ n, n-1 .. i+1 ]  do
            for k  in [ n, n-1 .. j+1 ]  do
                w1 := CollectedWordSQ( C, [k,1], pairs[j][i] );
                w2 := CollectedWordSQ( C, pairs[k][j], [i,1] );
                if w1.word <> w2.word  then
                    Error( "k(ji) <> (kj)i" );
                else
                    AddEquationsSQ( eq, w1.tail, w2.tail );
                fi;
            od;
        od;
    od;

    # consistency 2: j^(p-1) (ji) = j^p i
    for i  in [ n, n-1 .. 1 ]  do
        for j  in [ n, n-1 .. i+1 ]  do
            p  := C.orders[j];
            w1 := CollectedWordSQ( C, [j,p-1],
                    CollectedWordSQ( C, [j,1], [i,1] ) );
            w2 := CollectedWordSQ( C, CollectedWordSQ( C, [j,p-1], [j,1] ),
                    [i,1] );
            if w1.word <> w2.word  then
                Error( "j^(p-1) (ji) <> j^p i" );
            else
                AddEquationsSQ( eq, w1.tail, w2.tail );
            fi;
        od;
    od;

    # consistency 3: k (i i^(p-1)) = (ki) i^p-1
    for i  in [ n, n-1 .. 1 ]  do
        p := C.orders[i];
        for k  in [ n, n-1 .. i+1 ]  do
            w1 := CollectedWordSQ( C, [k,1],
                    CollectedWordSQ( C, [i,1], [i,p-1] ) );
            w2 := CollectedWordSQ( C, CollectedWordSQ( C, [k,1], [i,1] ),
                    [i,p-1] );
            if w1.word <> w2.word  then
                Error( "k i^p <> (ki) i^(p-1)" );
            else
                AddEquationsSQ( eq, w1.tail, w2.tail );
            fi;
        od;
    od;

    # consistency 4: (i i^(p-1)) i = i (i^(p-1) i)
    for i  in [ n, n-1 .. 1 ]  do
        p  := C.orders[i];
        w1 := CollectedWordSQ( C, CollectedWordSQ( C, [i,1], [i,p-1] ),
                [i,1] );
        w2 := CollectedWordSQ( C, [i,1],
                CollectedWordSQ( C, [i,p-1], [i,1] ) );
        if w1.word <> w2.word  then
            Error( "i i^p-1 <> i^p" );
        else
            AddEquationsSQ( eq, w1.tail, w2.tail );
        fi;
    od;

    # and return solution
    return SolutionSQ( C, eq );
end );

#############################################################################
##
#F  TwoCoboundariesSQ( C, G, M )
##
InstallGlobalFunction( TwoCoboundariesSQ, function( C, G, M )
    local   n,  R,  MI,  j,  i,  x,  m,  e,  k,  r,  d;

    # start with zero matrix
    n := Length(Pcgs( G ));
    R := [];
    r := n*(n+1)/2;
    for i  in [ 1 .. n ]  do
        R[i] := [];
        for j in [ 1 .. r ] do
            R[i][j] := C.mzero;
        od;
    od;

    # compute inverse generators
    M  := M.generators;
    MI := List( M, x -> x^-1 );
    d  := Length(M[1]);

    # loop over all relators
    for j  in [ 1 .. n ]  do
        for i in  [ j .. n ]  do
            x := (i^2-i)/2 + j;

            # power relator
            if i = j  then
                m := C.mone;
                for e  in [ 1 .. C.orders[i] ]  do
                    R[i][x] := R[i][x] - m;  m := M[i] * m;
                od;

            # conjugate
            else
                R[i][x] := R[i][x] - M[j];
                R[j][x] := R[j][x] + MI[j]*M[i]*M[j] - C.mone;
            fi;

            # compute fox derivatives
            m := C.mone;
            r := C.relators[i][j];
            if r <> 0  then
                for k  in [ Length(r)-1, Length(r)-3 .. 1 ]  do
                    for e  in [ 1 .. r[k+1] ]  do
                        R[r[k]][x] := R[r[k]][x] + m;
                        m := M[r[k]] * m;
                    od;
                od;
            fi;
        od;
    od;

    # make one list
    m := [];
    r := n*(n+1)/2;
    for i  in [ 1 .. n ]  do
        for k  in [ 1 .. d ]  do
            e := [];
            for j  in [ 1 .. r ]  do
                Append( e, R[i][j][k] );
            od;
            Add( m, e );
        od;
    od;

    # compute a base for <m>
    return BaseMat(m);
end );

#############################################################################
##
#F  TwoCohomologySQ( C, G, M )
##
InstallGlobalFunction( TwoCohomologySQ, function( C, G, M )
    local cc, cb;
    cc := TwoCocyclesSQ( C, G, M );
    if Length( cc ) > 0 then
        cb := TwoCoboundariesSQ( C, G, M );
        if Length( C.avoid ) > 0 then
            cb := SumIntersectionMat( cc, cb )[2];
        fi;
        if Length( cb ) > 0 then
            cc := BaseSteinitzVectors( cc, cb ).factorspace;
        fi;
    fi;
    return cc;
end );
     
#############################################################################
##
#M  TwoCocycles( G, M )
##
InstallMethod( TwoCocycles,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject ], 
    0,

function( G, M )
    local C;
    C := CollectorSQ( G, M, false );
    return TwoCocyclesSQ( C, G, M );
end );

#############################################################################
##
#M  TwoCoboundaries( G, M )
##
InstallMethod( TwoCoboundaries,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject ], 
    0,

function( G, M )
    local C;
    C := CollectorSQ( G, M, false );
    return TwoCoboundariesSQ( C, G, M );
end );

#############################################################################
##
#M  TwoCohomology( G, M )
##
InstallMethod( TwoCohomology,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject ], 
    0,

function( G, M )
    local C, d, z, co, cb, pr;
    C := CollectorSQ( G, M, false );
    d := Length( C.orders );
    d := d * (d+1) / 2;
    z := Flat( List( [1..d], x -> C.mzero[1] ) );
    co := TwoCocyclesSQ( C, G, M );
    co := VectorSpace( M.field, co, z );
    cb := TwoCoboundariesSQ( C, G, M );
    cb := SubspaceNC( co, cb );
    pr := FpGroupPcGroupSQ( G );
    return rec( group := G,
                module := M,
                collector := C,
                cohom := 
                NaturalHomomorphismBySubspaceOntoFullRowSpace(co,cb),
                presentation := FpGroupPcGroupSQ( G ) );
end );
