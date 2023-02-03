#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick and Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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

# non-solvable cohomology based on rewriting

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
    local C, d, z, co, cb;
    C := CollectorSQ( G, M, false );
    d := Length( C.orders );
    d := d * (d+1) / 2;
    z := Flat( List( [1..d], x -> C.mzero[1] ) );
    co := TwoCocyclesSQ( C, G, M );
    co := VectorSpace( M.field, co, z );
    cb := TwoCoboundariesSQ( C, G, M );
    cb := SubspaceNC( co, cb );
    return rec( group := G,
                module := M,
                collector := C,
                isPcCohomology:=true,
                cohom :=
                NaturalHomomorphismBySubspaceOntoFullRowSpace(co,cb),
                presentation := FpGroupPcGroupSQ( G ) );
end );

# code for generic 2-cohomology (solvable not required)

InstallMethod( TwoCohomologyGeneric,"generic, using rewriting system",true,
  [IsGroup and IsFinite,IsObject],0,
function(G,mo)
local field,fp,fpg,gens,hom,mats,fm,mon,tzrules,dim,rules,eqs,i,j,k,l,o,l1,
      len1,l2,m,start,formalinverse,hastail,one,zero,new,v1,v2,collectail,
      findtail,colltz,mapped,mapped2,onemat,zerovec,mal,p,genkill,
      c,nvars,htpos,zeroq,r,ogens,bds,model,q,pre,pcgs,miso,ker,solvec,rulpos,
      nonone,olen,dag;


  # collect the word in factor group
  colltz:=function(a)
  local i,p;

    # collect from left
    i:=1;
    while i<=Length(a) do

      # does a rule apply at position i?
      p:=RuleAtPosKBDAG(dag,a,i);

      if IsInt(p) then
        a:=Concatenation(a{[1..i-1]},tzrules[p][2],
          a{[i+Length(tzrules[p][1])..Length(a)]});
        i:=Maximum(0,i-mal); # earliest which could be affected
      fi;
      i:=i+1;
    od;

    return a;
  end;

  # matrix corresponding to monoid word
  mapped:=function(list)
  local a,i;
    a:=onemat;
    for i in list do
      if i in nonone then
        a:=a*mats[i];
      fi;
    od;
    return a;
  end;

  # normalform word and collect the tails
  collectail:=function(wrd)
  local v,tail,i,p;
    v:=List(rules,x->zero);

    # collect from left
    i:=1;
    while i<=Length(wrd) do

      # does a rule apply at position i?
      p:=RuleAtPosKBDAG(dag,wrd,i);

      if IsInt(p) and rulpos[p]<>fail then
        p:=rulpos[p];
        tail:=wrd{[i+Length(rules[p][1])..Length(wrd)]};
        wrd:=Concatenation(wrd{[1..i-1]},rules[p][2],tail);
        if p in hastail then
          if IsIdenticalObj(v[p],zero) then
            v[p]:=mapped(tail);
          else
            v[p]:=v[p]+mapped(tail);
          fi;
        fi;
        i:=Maximum(0,i-mal); # earliest which could be affected
      fi;
      i:=i+1;
    od;

    return [wrd,v];
  end;

  field:=mo.field;

  ogens:=GeneratorsOfGroup(G);

#  if false then
#    #  old general KB code, left for debugging
#    fp:=IsomorphismFpGroup(G);
#    fpg:=Range(fp);
#    fm:=IsomorphismFpMonoid(fpg);
#    mon:=Range(fm);
#
#    if IsBound(mon!.confl) then
#      tzrules:=mon!.confl;
#    else
#      kb:=KnuthBendixRewritingSystem(mon);
#      MakeConfluent(kb);
#      tzrules:=kb!.tzrules;
#      mon!.confl:=tzrules;
#    fi;
#  else

    # new approach with RWS from chief series
    mon:=ConfluentMonoidPresentationForGroup(G);
    fp:=mon.fphom;
    fpg:=Range(fp);
    fm:=mon.monhom;
    mon:=Range(fm);
    tzrules:=List(RelationsOfFpMonoid(mon),x->List(x,LetterRepAssocWord));
#  fi;

  dag:=EmptyKBDAG(Union(List(GeneratorsOfMonoid(FreeMonoidOfFpMonoid(mon)),
    LetterRepAssocWord)));
  mal:=Maximum(List(tzrules,x->Length(x[1])));
  for i in [1..Length(tzrules)] do
    AddRuleKBDAG(dag,tzrules[i][1],i);
  od;

  gens:=List(GeneratorsOfGroup(FamilyObj(fpg)!.wholeGroup),
    x->PreImagesRepresentative(fp,x));

  hom:=GroupHomomorphismByImagesNC(G,Group(mo.generators),
    GeneratorsOfGroup(G),mo.generators);
  mo:=GModuleByMats(List(gens,x->ImagesRepresentative(hom,x)),mo.field); # new gens

  l1:=GeneratorsOfGroup(fpg);
  l1:=Concatenation(l1,List(l1,Inverse));
  formalinverse:=[];
  for i in l1 do
    j:=LetterRepAssocWord(UnderlyingElement(ImagesRepresentative(fm,i)));
    o:=LetterRepAssocWord(UnderlyingElement(ImagesRepresentative(fm,i^-1)));
    if Length(j)<>1 or Length(o)<>1 then Error("length!");fi;
    formalinverse[j[1]]:=o[1];
  od;

  # rules that describe formal inverses, or delete generators of order 2 get no
  # tails.
  hastail:=[];
  rules:=[];
  genkill:=[]; # relations that kill generators. Needed for presenation.
  for r in tzrules do
    if Length(r[1])>=2 then
      Add(rules,r);
      if Length(r[1])>2 or
        (Length(r[1])=2 and (Length(r[2])>0 or formalinverse[r[1][1]]<>r[1][2]))
        then
          AddSet(hastail,Length(rules));
      fi;
    else
      # Length of r[1] is 1. That is, this generator is not used!
      m:=First(RelationsOfFpMonoid(mon),x->List(x,LetterRepAssocWord)=r);
      m:=List(m,x->PreImagesRepresentative(fm,ElementOfFpMonoid(FamilyObj(One(mon)),x)));
      m:=List(m,UnderlyingElement); # free group elements/words

      if not IsOne(m[1]*Subword(m[2],1,1)) then
        # Does the relation make a generator redundant (by expressing it in the
        # other gens)? If so, remember relation as needed to kill this generator, but
        # no influence on Cohomology calculation (which just uses the rest)
        if  m[1] in GeneratorsOfGroup(FreeGroupOfFpGroup(FamilyObj(fpg)!.wholeGroup))
          then Add(genkill,r);
        fi;
      fi;
    fi;
  od;

  rulpos:=List(tzrules,x->PositionProperty(rules,y->y[1]=x[1]));

  htpos:=List([1..Length(rules)],x->Position(hastail,x));

  model:=ValueOption("model");
  if model<>fail then
    q:=GQuotients(model,G)[1];
    pre:=List(gens,x->PreImagesRepresentative(q,x));
    ker:=KernelOfMultiplicativeGeneralMapping(q);
    pcgs:=Pcgs(ker);
    l1:=GModuleByMats(LinearActionLayer(Group(pre),pcgs),mo.field);
    MTX.IsIrreducible(mo);
    miso:=MTX.Isomorphism(mo,l1);
    new:=List(miso,x->PcElementByExponents(pcgs,x));
    pcgs:=PcgsByPcSequence(FamilyObj(One(model)),new);
    # now calculate the vector
    solvec:=[];
    one:=One(model);
    m:=GroupGeneralMappingByImagesNC(fpg,model,GeneratorsOfGroup(fpg),pre);
    mats:=List(GeneratorsOfMonoid(mon),
      x->ImagesRepresentative(m,
      PreImagesRepresentative(fm,x))); #Elements for monoid generators
    nonone:=[1..Length(mats)];
    pre:=mats;
    onemat:=One(G);
    for i in [1..Length(hastail)] do
      r:=rules[hastail[i]];
      m:=LeftQuotient(mapped(r[2]),mapped(r[1]));
      m:=ExponentsOfPcElement(pcgs,m);
      solvec:=Concatenation(solvec,m*One(field));
    od;
  fi;

  onemat:=One(mo.generators[1]);
  zerovec:=Zero(onemat[1]);

  mats:=List(GeneratorsOfMonoid(mon),
    x->ImagesRepresentative(hom,PreImagesRepresentative(fp,
    PreImagesRepresentative(fm,x)))); # matrices for monoid generators
  one:=One(mats[1]);
  nonone:=Filtered([1..Length(mats)],x->not IsOne(mats[x]));
  zero:=zerovec;
  dim:=Length(zero);
  nvars:=dim*Length(hastail); #Number of variables

#rk:=0;
  zeroq:=ImmutableVector(field,ListWithIdenticalEntries(nvars,Zero(field)));
  eqs:=MutableBasis(field,[],zeroq);
  olen:=[-1,0];
  for i in [1..Length(rules)] do
    Info(InfoCoh,1,"First rule ",i,", ",Length(BasisVectors(eqs))," equations");
    l1:=rules[i][1];
    len1:=Length(l1);
    for j in [1..Length(rules)] do
      l2:=rules[j][1];
      m:=Minimum(len1,Length(l2));
      for o in [1..m-1] do # possible overlap Length
        start:=len1-o;
        if ForAll([1..o],k->l1[start+k]=l2[k]) then

          # apply l1 first
          new:=Concatenation(rules[i][2],l2{[o+1..Length(l2)]});
          c:=collectail(new);
          v1:=c[2];c:=c[1];
          if i in hastail then
            v1[i]:=v1[i]+mapped(l2{[o+1..Length(l2)]});
          fi;

          # apply l2 first
          new:=Concatenation(l1{[1..len1-o]},rules[j][2]);
          v2:=collectail(new);
          if c<>v2[1] then Error("different in factor");
          #else Print("Both reduce to ",c,"\n");
          fi;
          v2:=v2[2];
          if j in hastail then
            v2[j]:=v2[j]+one;
          fi;
          if v1<>v2 then # If entries stay zero they are identical (and thus test cheaply)
            c:=List([1..dim],x->ShallowCopy(zeroq));
            for k in hastail do
              if v1[k]<>v2[k] then
                new:=TransposedMat(v1[k]-v2[k]);
                r:=(htpos[k]-1)*dim+[1..dim];
                for l in [1..dim] do
                  if not IsZero(new[l]) then
                    c[l]{r}:=new[l];
                  fi;
                od;
              fi;
            od;
            for k in c do

              if model<>fail and not IsZero(solvec*k) then
                Error("model does not fit");
              fi;
              #AddSet(eqs,ImmutableVector(field,k));
              #k:=SiftedVector(eqs,ImmutableVector(field,k));
  #Add(alleeqs,ImmutableVector(field,k));
              k:=SiftedVector(eqs,k);
              if not IsZero(k) then
                CloseMutableBasis(eqs,ImmutableVector(field,k));

              fi;

            od;
          fi;

        fi;
      od;
    od;
    Add(olen,Length(BasisVectors(eqs)));
    if Length(olen)>3 and
      # if twice stayed the same after increase
      olen[Length(olen)]=olen[Length(olen)-2] and
      olen[Length(olen)]<>olen[Length(olen)-3] then

      k:=List(BasisVectors(eqs),ShallowCopy);;
      TriangulizeMat(k);
      eqs:=MutableBasis(field,
        List(k,x->ImmutableVector(field,x)),zeroq);
    fi;

  od;

  #eqs:=Filtered(TriangulizedMat(eqs),x->not IsZero(x));
  eqs:=ShallowCopy(BasisVectors(eqs));
  if Length(eqs)=0 then
    eqs:=IdentityMat(Length(rules),field);
  else
    eqs:=ImmutableMatrix(field,eqs);
    eqs:=NullspaceMat(TransposedMat(eqs)); # basis of cocycles
  fi;

  # Now get Coboundaries

  # different collection function: Sum up changes for generator i
  findtail:=function(wrd,nums,vecs)
  local a,i,j,p,v;
    a:=zerovec;
    for i in [1..Length(wrd)] do
      p:=Position(nums,wrd[i]);
      if p<>fail then
        v:=vecs[p];
        for j in [i+1..Length(wrd)] do
          v:=v*mats[wrd[j]];
        od;
        a:=a+v;
      fi;
    od;
    return a;
  end;

  bds:=[];
  for i in [1..Length(mats)] do
    if formalinverse[i]>i then
      c:=[i,formalinverse[i]];
      for k in one do
        r:=[k,-k*mats[formalinverse[i]]];

        new:=[];
        for j in hastail do
          v1:=findtail(rules[j][1],c,r);
          v2:=findtail(rules[j][2],c,r);
          Append(new,v1-v2);
        od;
        new:=ImmutableVector(field,new);
        Assert(0,(Length(eqs)>0 and SolutionMat(eqs,new)<>fail) or IsZero(new));
        Add(bds,new);
      od;
    fi;
  od;
  bds:=Filtered(TriangulizedMat(bds),x->not IsZero(x));
  bds:=List(bds,Immutable);

  if gens<>GeneratorsOfGroup(G) then
    G:=GroupWithGenerators(gens);
  fi;
  r:=rec(group:=G,module:=mo,cocycles:=eqs,coboundaries:=bds,zero:=zeroq,
         prime:=Size(field));
  new:=List(BaseSteinitzVectors(eqs,bds).factorspace,x->ImmutableVector(field,x));
  r.cohomology:=new;

  new:=[];
  one:=One(FreeGroupOfFpGroup(fpg));

  k:=List(GeneratorsOfMonoid(mon),
    x->UnderlyingElement(PreImagesRepresentative(fm,x)));
  # matrix corresponding to monoid word
  mapped2:=function(list)
  local a,i;
    a:=one;
    for i in list do
      a:=a*k[i];
    od;
    return a;
  end;

  for i in hastail do
    # rule that would get the tail
    Add(new,LeftQuotient(mapped2(rules[i][1]),mapped2(rules[i][2])));
  od;

  r.presentation:=rec(group:=FreeGroupOfFpGroup(fpg),relators:=new,
    # relators to kill superfluous generators
    killrelators:=List(genkill,i->LeftQuotient(mapped2(i[1]),mapped2(i[2]))),
    # position of relators with tails in tzrules
    monrulpos:=List(rules{hastail},x->Position(tzrules,x)),
    prewords:=List(ogens,x->UnderlyingElement(ImagesRepresentative(fp,x))));

  # normalform word and collect the tails
  r.tailforword:=function(wrd,zy)
  local v,i,j,p,w,tail;
    v:=zerovec;

    # collect from left
    i:=1;
    while i<=Length(wrd) do

      # does a rule apply at position i?
      p:=RuleAtPosKBDAG(dag,wrd,i);

      if IsInt(p) and rulpos[p]<>fail then
        p:=rulpos[p];
        tail:=wrd{[i+Length(rules[p][1])..Length(wrd)]};
        wrd:=Concatenation(wrd{[1..i-1]},rules[p][2],tail);

        if p in hastail then
          w:=zy{dim*(htpos[p]-1)+[1..dim]};
          for j in tail do
            w:=w*mats[j];
          od;
          v:=v+w;
        fi;

        i:=Maximum(0,i-mal); # earliest which could be affected
      fi;
      i:=i+1;
    od;
    return [wrd,v];
  end;

  r.fphom:=fp;
  r.monhom:=fm;
  r.colltz:=colltz;

  # inverses of generators
  r.myinvers:=function(wrd,zy)
    return [colltz(formalinverse{Reversed(wrd)}),
    -r.tailforword(Concatenation(wrd,colltz(formalinverse{Reversed(wrd)})),zy)
      [2]];
  end;

  r.pairact:=function(zy,pair)
  local autom,mat,i,imagemonwords,imgwrd,left,right,extim,prdout,myinvers,v;

    autom:=InverseGeneralMapping(pair[1]);

    # cache words for images of monoid generators
    if not IsBound(autom!.imagemonwords) then autom!.imagemonwords:=[]; fi;
    imagemonwords:=autom!.imagemonwords;
    imgwrd:=function(nr)
    local a;
      if not IsBound(imagemonwords[nr]) then
        # apply automorphism
        a:=PreImagesRepresentative(fm,GeneratorsOfMonoid(mon)[nr]);
        a:=PreImagesRepresentative(fp,a);
        a:=ImagesRepresentative(autom,a);
        a:=ImagesRepresentative(fp,a);
        a:=ImagesRepresentative(fm,a);
        a:=LetterRepAssocWord(UnderlyingElement(a));
        a:=colltz(a);
        imagemonwords[nr]:=a;
      fi;
      return imagemonwords[nr];
    end;

    # normalform word and collect the tails
    collectail:=function(wrd)
    local v,i,j,p,w,tail;
      v:=zerovec;

      # collect from left
      i:=1;
      while i<=Length(wrd) do

        # does a rule apply at position i?
        p:=RuleAtPosKBDAG(dag,wrd,i);

        if IsInt(p) and rulpos[p]<>fail then
          p:=rulpos[p];
          tail:=wrd{[i+Length(rules[p][1])..Length(wrd)]};
          wrd:=Concatenation(wrd{[1..i-1]},rules[p][2],tail);

          if p in hastail then
            w:=zy{dim*(htpos[p]-1)+[1..dim]};
            for j in tail do
              w:=w*mats[j];
            od;
            v:=v+w;
          fi;

          i:=Maximum(0,i-mal); # earliest which could be affected
        fi;
        i:=i+1;
      od;
      return [wrd,v];
    end;

    prdout:=function(l)
    local w,v,j;
      w:=[];
      v:=zerovec;
      for j in l do
        v:=v*mapped(j[1]); # move right
        w:=collectail(Concatenation(w,j[1]));
        v:=v+w[2]+j[2];
        w:=w[1];
      od;
      return [w,v];
    end;

    mat:=pair[2];
    new:=[];

    # inverses of generators
    myinvers:=wrd->[colltz(formalinverse{Reversed(wrd)}),
      -collectail(Concatenation(wrd,colltz(formalinverse{Reversed(wrd)})))[2]];

    # images of generators
    extim:=List([1..Length(mats)/2],x->imgwrd(2*x-1));

    # collect inverses and interleave generators/inverses
    extim:=Concatenation(List(extim,x->[[x,zerovec],myinvers(x)]));

    for i in [1..Length(hastail)] do
      # evaluate rules in images
      left:=prdout(extim{rules[hastail[i]][1]});

      # invert left
      v:=myinvers(left[1]);
      left:=[v[1],v[2]-left[2]/mapped(left[1])];

      right:=prdout(extim{rules[hastail[i]][2]});

      # quotient left^-1*right
      left:=prdout(Concatenation([left],[right]));
      if left[1]<>[] then Error("not rule");fi;

      Append(new,-left[2]*mat);
    od;

# debugging code: Construct group and work there
#    new2:=[];
#    ext:=FpGroupCocycle(r,zy,true);
#    hom:=IsomorphismPermGroup(ext);
#    ext:=Image(hom);
#    epcgs:=PcgsByPcSequence(FamilyObj(One(ext)),
#      GeneratorsOfGroup(ext){[Length(mats)/2+1..Length(GeneratorsOfGroup(ext))]});
#
#    exta:=Concatenation(List([1..Length(mats)/2],x->[ext.(x),ext.(x)^-1]));
#    exte:=exta;
#
#    myprd:=function(wrd)
#    local i,w;
#      w:=One(ext);
#      for i in wrd do
#        w:=w*exte[i];
#      od;
#      return w;
#    end;
#
#    v:=List([1..Length(mats)/2],x->myprd(imgwrd(2*x-1))); # new generators
#    v:=Concatenation(List([1..Length(mats)/2],x->[v[x],v[x]^-1]));
#    exte:=v;
#
#    for i in [1..Length(hastail)] do
#      left:=rules[hastail[i]][1];
#      right:=rules[hastail[i]][2];
#      left:=myprd(left)^-1*myprd(right);
#      v:=-ExponentsOfPcElement(epcgs,left)*One(mo.field);
#
#      Append(new2,v*mat);
#    od;
#    if new2<>new then Error("wrong ",pair);fi;
#    if IsOne(pair[1]) and IsOne(pair[2]) then
#      if new<>zy then Error("one");else Print("onegood\n");fi;
#    fi;

    return ImmutableVector(mo.field,new);
  end;

  return r;
end);

BindGlobal( "MatricesStabilizerOneDim", function(field,mats)
local e,one,m,r,a,c,is,i;
    e:=[];
    one:=One(mats[1]);
    for m in mats do
      r:=Set(RootsOfUPol(field,CharacteristicPolynomial(m)));
      a:=List(r,x->NullspaceMat(m-x*one));
      if Length(a)=0 then return false;fi;
      Add(e,a);
    od;
    for c in Cartesian(e) do
      is:=c[1];
      for i in [2..Length(c)] do
        is:=SumIntersectionMat(is,c[i])[2];
      od;
      if Length(is)>0 then
        return is;
      fi;
    od;
  return false;
end );

BindGlobal("WreathElm",function(b,l,m)
local n,ran,r,d,p,i,j;
  n:=Length(l);
  ran:=[1..b];
  r:=0;
  d:=[];
  p:=[];
  # base bit
  for i in [1..n] do
    for j in ran do
      p[r+j]:=r+j^l[i];
    od;
    Add(d,ran+r);
    r:=r+b;
  od;
  # permuter bit
  p:=PermList(p)/PermList(Concatenation(Permuted(d,m)));
  return p;
end);

BindGlobal("PermrepSemidirectModule",function(G,module)
local hom,mats,m,i,j,mo,bas,a,l,ugens,gi,r,cy,act,k,it,p;
  if not MTX.IsIrreducible(module) then Error("reducible");fi;
  p:=Size(module.field);
  if not IsPrime(p) then Error("must be over prime field");fi;
  k:=Length(module.generators);
  hom:=GroupHomomorphismByImagesNC(G,Group(module.generators),
    GeneratorsOfGroup(G),module.generators);
  # we allow do go immediately to normal subgroup of index up to 4.
  # This reduces search space
  it:=DescSubgroupIterator(G:skip:=LogInt(Size(G),2));
  repeat
    m:=NextIterator(it);

    if Index(G,m)*p>p^module.dimension then
      Info(InfoExtReps,2,"Index reached ",Index(G,m),
        ", write out module action");
      # alternative, boring version
      mo:=AbelianGroup(ListWithIdenticalEntries(module.dimension,p));
      bas:=Pcgs(mo);
      act:=List(module.generators,m->
        GroupHomomorphismByImagesNC(mo,mo,bas,
          List(m,x->PcElementByExponents(bas,x)):noassert));
      Assert(3,ForAll(act,IsBijective));
      a:=Group(act);
      SetIsGroupOfAutomorphismsFiniteGroup(a,true);
      gi:=SemidirectProduct(G,GroupHomomorphismByImages(G,a,
        GeneratorsOfGroup(G),act),mo);
      r:=rec(group:=gi,
                  ggens:=List(GeneratorsOfGroup(G),x->
                    ImagesRepresentative(Embedding(gi,1),x)),
                  #vector:=ImagesRepresentative(Embedding(gi,2),bas[1]),
        basis:=List(bas,x->ImagesRepresentative(Embedding(gi,2),x)));
      Assert(0,Size(gi)=Size(G)*p^module.dimension);
      return r;

    elif Size(Core(G,m))>1 then
      Info(InfoExtReps,4,"Index ",Index(G,m)," has nontrivial core");
    else
      Info(InfoExtReps,2,"Trying index ",Index(G,m));

      mats:=List(GeneratorsOfGroup(m),
        x->TransposedMat(ImagesRepresentative(hom,x^-1)));
      a:=MatricesStabilizerOneDim(module.field,mats);
      if a<>false then
        # quotient module
        # basis: supplemental vector and submodule basis
        bas:=BaseSteinitzVectors(IdentityMat(module.dimension,GF(p)),
          NullspaceMat(TransposedMat(a{[1]})));
        bas:=Concatenation(bas.factorspace,bas.subspace);

        # assume we have a generating set for the SDP consisting of the
        # complement gens, and one element of the module.
        cy:=CyclicGroup(IsPermGroup,p).1; # p-cycle
        ugens:=[];

        # also transversal chosen in complement
        r:=RightTransversal(G,m);
        act:=ActionHomomorphism(G,r,OnRight);
        act:=List(GeneratorsOfGroup(G),x->ImagesRepresentative(act,x));
        #l:=ListWithIdenticalEntries(Index(G,m),());
        for gi in [1..k] do
          l:=[];
          for j in [1..Length(r)] do
            # matrix for Schreier gen
            a:=ImagesRepresentative(hom,
              r[j]*G.(gi)/r[PositionCanonical(r,r[j]*G.(gi))]);
            # how does it act on bas[1]-span, get factor
            a:=Int(SolutionMat(bas,bas[1]*a)[1]);
            # write down permutation that acts as mult by a
            if IsZero(a) then
              l[j]:=();
            else
              l[j]:=MappingPermListList([1..p],Cycle(cy^a,1));
            fi;
          od;
          Add(ugens,WreathElm(p,l,act[gi]) );
        od;

        # module generator
        for j in [1..Length(r)] do
          #r[j]*g/r[j^g]); Note j^g=j here as kernel of permrep
          l[j]:=
            cy^Int(SolutionMat(bas,bas[1]/ImagesRepresentative(hom,r[j]))[1]);
        od;
        Add(ugens,WreathElm(p,l,()) );
        gi:=Group(ugens);
        Assert(0,Size(gi)=p^module.dimension*Size(G));
        if ValueOption("cheap")<>true then
          a:=SmallerDegreePermutationRepresentation(gi:cheap);
          if NrMovedPoints(Range(a))<NrMovedPoints(gi) then
            gi:=Image(a,gi);
            ugens:=List(ugens,x->ImagesRepresentative(a,x));
          fi;
        fi;

        r:=rec(group:=gi,ggens:=ugens{[1..k]});

        # compute basis
        bas:=bas{[1]};
        gi:=ugens{[1..k]};
        ugens:=ugens{[k+1]};
        i:=1;
        while Length(bas)<module.dimension do
          for j in [1..k] do
            a:=bas[i]*module.generators[j];
            if SolutionMat(bas,a)=fail then
              Add(bas,a);
              Add(ugens,ugens[i]^gi[j]);
            fi;
          od;
          i:=i+1;
        od;
        # convert back to standard basis
        r.basis:=List(Inverse(bas),x->LinearCombinationPcgs(ugens,x));

        return r;
      fi;
    fi;
  until false;
end);

BindGlobal("RandomSubgroupNotIncluding",function(g,n,time)
local best,u,v,start,cnt,runtime;
  runtime:=GET_TIMER_FROM_ReproducibleBehaviour();
  start:=runtime();
  best:=TrivialSubgroup(g);
  cnt:=0;
  while runtime()-start<time or cnt<100 do
    cnt:=cnt+1;
    u:=TrivialSubgroup(g);
    repeat
      v:=u;
      u:=ClosureGroup(u,Random(g));
    until IsSubset(u,n);
    if IndexNC(g,v)<IndexNC(g,best) then best:=v;fi;
  od;
  return best;
end);

InstallGlobalFunction(FpGroupCocycle,function(arg)
local r,z,ogens,n,gens,str,dim,i,j,f,rels,new,quot,g,p,collect,m,e,fp,sim,
      it,hom,trysy,prime,mindeg,fps,ei,mgens,mwrd,nn,newfree,mfpi,mmats,sub,
      tab,tab0,evalprod,gensmrep,invsmrep,zerob,step,simi,simiq,wasbold,
      mon,ord,mn,melmvec,killgens,frew,fffam,ofgens,rws,formalinverse;

  # function to evaluate product (as integer list) in gens (and their
  # inverses invs) with corresponding action mats
  evalprod:=function(w,gens,invs,mats)
  local new,i;
    new:=[[],zerob];
    for i in w do
      if i>0 then
        collect:=r.tailforword(Concatenation(new[1],gens[i][1]),z);
        new:=[collect[1],collect[2]+new[2]*mats[i]+gens[i][2]];
      else
        collect:=r.tailforword(Concatenation(new[1],invs[-i][1]),z);
        new:=[collect[1],collect[2]+new[2]/mats[-i]+invs[-i][2]];
      fi;
    od;
    return new;
  end;

  melmvec:=function(v)
  local i,a,w;
    w:=One(f);
    for i in [1..Length(v)] do
      a:=Int(v[i]);
      if prime=2 or a*2<prime then
        w:=w*gens[2*i-1+mn]^a;
      else
        a:=prime-a;
        w:=w*gens[2*i+mn]^a;
      fi;
    od;
    return w;
  end;

  # formal inverse of module element
  formalinverse:=function(w)
  local l,i;
    l:=[];
    for i in Reversed(LetterRepAssocWord(w)) do
      if IsEvenInt(i) then Add(l,i-1);
      else Add(l,i+1);fi;
    od;
    return AssocWordByLetterRep(FamilyObj(w),l);
  end;

  r:=arg[1];
  z:=arg[2];
  ogens:=GeneratorsOfGroup(r.presentation.group);
  dim:=r.module.dimension;
  prime:=Size(r.module.field);

  if ValueOption("normalform")<>true then
    mon:=fail;
  else
    # Construct the monoid and rewriting system, as this is cheap to do but
    # will allow for reduced multiplication. Do so before the group, so there is no
    # issue about overwriting variables that might be needed later
    mon:=Image(r.monhom);
    ofgens:=FreeGeneratorsOfFpMonoid(mon);
    fffam:=FamilyObj(One(FreeMonoidOfFpMonoid(mon)));
    frew:=ReducedConfluentRewritingSystem(mon);
    # generators that get killed. Do not use in RHS
    killgens:=Filtered(GeneratorsOfMonoid(mon),x->UnderlyingElement(x)<>
      ReducedForm(frew,UnderlyingElement(x)));
    killgens:=Union(List(killgens,x->LetterRepAssocWord(UnderlyingElement(x))));

    str:=List(GeneratorsOfMonoid(mon),String);
    mn:=Length(str);
    for i in [1..dim] do
      Add(str,Concatenation("m",String(i)));
      Add(str,Concatenation("m",String(i),"^-1"));
    od;
    f:=FreeMonoid(str);
    gens:=GeneratorsOfMonoid(f);

    rels:=[];
    # inverse rules
    for i in [1,3..Length(gens)-1] do
      Add(rels,[gens[i]*gens[i+1],One(f)]);
      Add(rels,[gens[i+1]*gens[i],One(f)]);
    od;

    # module is elementary abelian
    for i in [mn+1,mn+3..Length(str)-1] do
      if prime=2 then
        Add(rels,[gens[i]^2,One(f)]);
        Add(rels,[gens[i+1],gens[i]]);
      else
        j:=QuoInt(prime+1,2); # power that changes the exponent sign
        Add(rels,[gens[i]^j,gens[i+1]^(j-1)]);
        Add(rels,[gens[i+1]^j,gens[i]^(j-1)]);
      fi;
      for j in [i+2..Length(str)] do
        Add(rels,[gens[j]*gens[i],gens[i]*gens[j]]);
        Add(rels,[gens[j]*gens[i+1],gens[i+1]*gens[j]]);
      od;
    od;

    # module rules
    for i in [1..mn] do
      if not i in killgens then
        for j in [mn+1..Length(str)] do
          new:=r.module.generators[QuoInt(i+1,2)];
          if IsEvenInt(i) then new:=new^-1; fi;
          new:=new[QuoInt(j-mn+1,2)];
          if IsEvenInt(j) then new:=-new;fi;
          Add(rels,[gens[j]*gens[i],gens[i]*melmvec(new)]);
        od;
      fi;
    od;

    # rules with tails
    for i in [1..Length(r.presentation.monrulpos)] do
      new:=RelationsOfFpMonoid(mon)[r.presentation.monrulpos[i]];
      new:=List(new,x->MappedWord(x,ofgens,gens{[1..mn]}));
      new[2]:=new[2]*melmvec(z{[(i-1)*dim+1..i*dim]});
      Add(rels,new);
    od;

    # Any killed generators -- use just the same word expression
    if r.presentation.killrelators<>[] then
      for i in Filtered(killgens,IsOddInt) do
        new:=AssocWordByLetterRep(fffam,[i]);
        new:=[new,ReducedForm(frew,new)];
        new:=List(new,x->MappedWord(x,
          ofgens,gens{[1..mn]}));
        Add(rels,new);
        RemoveSet(killgens,i);
      od;
    fi;

    if HasReducedConfluentRewritingSystem(mon) then
      ord:=OrderingOfRewritingSystem(ReducedConfluentRewritingSystem(mon));
      if HasLevelsOfGenerators(ord) then
        ord:=WreathProductOrdering(f,
          Concatenation(LevelsOfGenerators(ord)+1,
                        ListWithIdenticalEntries(2*dim,1)));
      else
        ord:=WreathProductOrdering(f,
          Concatenation(ListWithIdenticalEntries(mn,2),
                        ListWithIdenticalEntries(2*dim,1)));
      fi;
    else
      ord:=WreathProductOrdering(f,
        Concatenation(ListWithIdenticalEntries(mn,2),
                      ListWithIdenticalEntries(2*dim,1)));
    fi;

    # if there is any [x^2,1] relation, this means the inverse needs to be
    # mapped to the generator. (This will have been skipped in the
    # monrulpos.)
    for i in rels do
      if Length(i[2])=0 and Length(i[1])=2
        and Length(Set(LetterRepAssocWord(i[1])))=1 then
        new:=LetterRepAssocWord(i[1])[1];
        if IsOddInt(new) then
          Add(rels,[gens[new+1],gens[new]]);
        fi;
      fi;
    od;

    # temporary build to be able to reduce
    mon:=FactorFreeMonoidByRelations(f,rels);
    rws:=KnuthBendixRewritingSystem(FamilyObj(One(mon)),ord);

    # handle inverses that get killed
    for i in killgens do
      new:=AssocWordByLetterRep(fffam,[i]);
      new:=ReducedForm(frew,new); # what is it in the factor?
      new:=MappedWord(new,ofgens,gens{[1..mn]});
      # now left multiply with non-inverse generator
      j:=ReducedForm(rws,gens[i-1]*new); #must be a tail.
      j:=ReducedForm(rws,formalinverse(j)); # invert
      Add(rels,[gens[i],new*j]);
    od;

    mon:=FactorFreeMonoidByRelations(f,rels);
    rws:=KnuthBendixRewritingSystem(FamilyObj(One(mon)),ord:isconfluent);
    ReduceRules(rws);
    MakeConfluent(rws);  # will add rules to kill inverses, if needed
    SetReducedConfluentRewritingSystem(mon,rws);
  fi;

  # now construct the group
  str:=List(ogens,String);
  zerob:=ImmutableVector(r.module.field,
    ListWithIdenticalEntries(dim,Zero(r.module.field)));
  n:=Length(ogens);

  gensmrep:=List(GeneratorsOfGroup(r.presentation.group),
   x->[LetterRepAssocWord(UnderlyingElement(ImagesRepresentative(r.monhom,
     ElementOfFpGroup(FamilyObj(One(Range(r.fphom))),x)))),zerob]);
  # module generators
  Append(gensmrep,List(IdentityMat(r.module.dimension,r.module.field),
    x->[[],x]));
  invsmrep:=List(gensmrep,x->r.myinvers(x[1],z));

  for i in [1..dim] do
    Add(str,Concatenation("m",String(i)));
  od;
  f:=FreeGroup(str);
  gens:=GeneratorsOfGroup(f);
  rels:=[];
  for i in [1..Length(r.presentation.relators)] do
    new:=MappedWord(r.presentation.relators[i],ogens,gens{[1..n]});
    for j in [1..dim] do
      new:=new*gens[n+j]^Int(z[(i-1)*dim+j]);
    od;
    Add(rels,new);
  od;
  for i in [1..Length(r.presentation.killrelators)] do
    new:=MappedWord(r.presentation.killrelators[i],ogens,gens{[1..n]});
    Add(rels,new);
  od;

  for i in [n+1..Length(gens)] do
    Add(rels,gens[i]^prime);
    for j in [i+1..Length(gens)] do
      Add(rels,Comm(gens[i],gens[j]));
    od;
  od;
  for i in [1..n] do
    for j in [1..dim] do
      Add(rels,gens[n+j]^gens[i]/
        LinearCombinationPcgs(gens{[n+1..Length(gens)]},r.module.generators[i][j]));
    od;
  od;
  fp:=f/rels;
  SetSize(fp,Size(r.group)*prime^r.module.dimension);
  simi:=fail;
  wasbold:=false;

  if mon<>fail then
    rels:=MakeFpGroupToMonoidHomType1(fp,mon);
    SetReducedMultiplication(fp);
  fi;

  if Length(arg)>2 and arg[3]=true then
    if IsZero(z) and MTX.IsIrreducible(r.module) then
      # make SDP directly
      m:=PermrepSemidirectModule(r.group,r.module:cheap);
      p:=m.group;
      # test is cheap here, thus no NC
      new:=GroupHomomorphismByImages(fp,p,GeneratorsOfGroup(fp),
        Concatenation(m.ggens,m.basis));
    else

      #sim:=IsomorphismSimplifiedFpGroup(fp);
      sim:=IdentityMapping(fp);
      fps:=Image(sim,fp);

      g:=r.group;
      quot:=InverseGeneralMapping(sim)
        *GroupHomomorphismByImages(fp,g,GeneratorsOfGroup(fp),
        Concatenation(GeneratorsOfGroup(g),
          ListWithIdenticalEntries(r.module.dimension,One(g))));
      hom:=GroupHomomorphismByImages(r.group,Group(r.module.generators),
        GeneratorsOfGroup(r.group),r.module.generators);
      p:=Image(quot);
      trysy:=Maximum(1000,50*IndexNC(p,SylowSubgroup(p,prime)));
      # allow to enforce test coverage
      if ValueOption("forcetest")=true then trysy:=2;fi;

      mindeg:=2;
      if IsPermGroup(p) then
        mindeg:=Minimum(List(Orbits(p,MovedPoints(p)),Length));
      fi;
      it:=fail;
      while Size(p)<Size(fp) do
        # we allow do go immediately to normal subgroup of index up to 4.
        # This reduces search space
        repeat
          if it=fail then
            # re-use the first quotient, helps with repeated subgroups iterator
            if p=r.group then
              m:=r.group;
            else
              m:=p;
            fi;
            # avoid working hard for outer automorphisms
            e:=Filtered(DerivedSeriesOfGroup(m),
              # roughly 5 for 1000, 30 for 10^6, 170 for 10^9
              x->IndexNC(m,x)^4<=Size(m));
            m:=e[Length(e)];
            it:=DescSubgroupIterator(m:skip:=LogInt(Size(p),2));
          fi;

          wasbold:=false;
          m:=NextIterator(it);
          # catch case of large permdegree, try naive first
          if Index(p,m)=1 and IsPermGroup(p)
            and NrMovedPoints(p)^2>Size(p) then
            # take set stabilizer of orbit points.
            e:=Set(List(Orbits(p,MovedPoints(p)),x->x[1]));
            m:=Stabilizer(p,e,OnSets);
            if IndexNC(p,m)>10*NrMovedPoints(p) then
              m:=Intersection(MaximalSubgroupClassReps(p));
            fi;
            if IndexNC(p,m)>10*NrMovedPoints(p) then
              m:=p; # after all..
              wasbold:=false;
            else
              wasbold:=true;
            fi;
          fi;
          Info(InfoExtReps,3,"Found index ",Index(p,m));
          e:=fail;
          if Index(p,m)>=mindeg and (hom=false or Size(m)=1 or
            false<>MatricesStabilizerOneDim(r.module.field,
              List(GeneratorsOfGroup(m),
              x->TransposedMat(ImagesRepresentative(hom,x))^-1))) then
            Info(InfoExtReps,2,"Attempt index ",Index(p,m));
            if hom=false then Info(InfoExtReps,2,"hom is false");fi;

            if hom<>false and Index(p,m)>
              # up to index
              50
              # the rewriting seems to be sufficiently spiffy that we don't
              # need to worry about this more involved process.

              # this might fail if generators are killed by rewriting
              and Length(r.presentation.killrelators)=0
              then

              # Rewriting produces a bad presentation. Rather rebuild a new
              # fp group using rewriting rules, finds its abelianization,
              # and then lift that quotient
              sub:=PreImage(quot,m);
              tab0:=AugmentedCosetTableInWholeGroup(sub);

              # primary generators
              mwrd:=List(tab0!.primaryGeneratorWords,
                x->ElementOfFpGroup(FamilyObj(One(fps)),x));
              Info(InfoExtReps,4,"mwrd=",mwrd);
              mgens:=List(mwrd,x->ImagesRepresentative(quot,x));
              nn:=Length(mgens);
              if IsPermGroup(m) then
                e:=SmallerDegreePermutationRepresentation(m);
                mfpi:=IsomorphismFpGroupByGenerators(Image(e,m),
                  List(mgens,x->ImagesRepresentative(e,x)):cheap);
                mfpi:=e*mfpi;
              else
                mfpi:=IsomorphismFpGroupByGenerators(m,mgens:cheap);
              fi;
              mmats:=List(mgens,x->ImagesRepresentative(hom,x));

              i:=Concatenation(r.module.generators,
                ListWithIdenticalEntries(r.module.dimension,
                  IdentityMat(r.module.dimension,r.module.field)));
              e:=List(mwrd,
                x->evalprod(LetterRepAssocWord(UnderlyingElement(x)),
                gensmrep,invsmrep,i));
              ei:=List(e,function(x)
                  local i;
                    i:=r.myinvers(x[1],z);
                    return [i[1],i[2]-x[2]];
                  end);

              newfree:=FreeGroup(nn+dim);
              gens:=GeneratorsOfGroup(newfree);
              rels:=[];

              # module relations
              for i in [1..dim] do
                Add(rels,gens[nn+i]^prime);
                for j in [1..i-1] do
                  Add(rels,Comm(gens[nn+i],gens[nn+j]));
                od;
                for j in [1..Length(mgens)] do
                  Add(rels,gens[nn+i]^gens[j]/
                     LinearCombinationPcgs(gens{[nn+1..nn+dim]},mmats[j][i]));
                od;
              od;

              #extended presentation

              for i in RelatorsOfFpGroup(Range(mfpi)) do
                i:=LetterRepAssocWord(i);
                str:=evalprod(i,e,ei,mmats);
                if Length(str[1])>0 then Error("inconsistent");fi;
                Add(rels,AssocWordByLetterRep(FamilyObj(One(newfree)),i)
                         /LinearCombinationPcgs(gens{[nn+1..nn+dim]},str[2]));
              od;
              newfree:=newfree/rels; # new extension
              Assert(2,
                AbelianInvariants(newfree)=AbelianInvariants(PreImage(quot,m)));
              mfpi:=GroupHomomorphismByImagesNC(newfree,m,
                GeneratorsOfGroup(newfree),Concatenation(mgens,
                  ListWithIdenticalEntries(dim,One(m))));

              # first just try a bit, and see whether this gets all (e.g. if
              # module is irreducible).
              e:=LargerQuotientBySubgroupAbelianization(mfpi,m:cheap);
              if e<>fail then
                step:=0;
                while step<=1 do
                  # Now write down the combined representation in wreath

                  e:=DefiningQuotientHomomorphism(e);
                  # define map on subgroup.
                  tab:=CopiedAugmentedCosetTable(tab0);
                  tab.primaryImages:=Immutable(
                    List(GeneratorsOfGroup(newfree){[1..nn]},
                      x->ImagesRepresentative(e,x)));
                  TrySecondaryImages(tab);

                  i:=GroupHomomorphismByImagesNC(sub,Range(e),mwrd,
                    List(GeneratorsOfGroup(newfree){[1..nn]},
                      x->ImagesRepresentative(e,x)):noassert);
                  SetCosetTableFpHom(i,tab);
                  e:=PreImage(i,TrivialSubgroup(Range(e)));
                  e:=Intersection(e,
                      KernelOfMultiplicativeGeneralMapping(quot));

                  # this check is very cheap, in comparison. So just be safe
                  Assert(0,ForAll(RelatorsOfFpGroup(fps),
                    x->IsOne(MappedWord(x,FreeGeneratorsOfFpGroup(fps),
                      GeneratorsOfGroup(e!.quot)))));

                  if step=0 then
                    i:=GroupHomomorphismByImagesNC(e!.quot,p,
                      GeneratorsOfGroup(e!.quot),
                      GeneratorsOfGroup(p));
                    j:=PreImage(i,m);
                    if AbelianInvariants(j)=AbelianInvariants(newfree) then
                      step:=2;
                      Info(InfoExtReps,2,"Small bit did good");
                    else
                      Info(InfoExtReps,2,"Need expensive version");
                      e:=LargerQuotientBySubgroupAbelianization(mfpi,m:
                        cheap:=false);
                      e:=Intersection(e,
                        KernelOfMultiplicativeGeneralMapping(quot));
                    fi;
                  fi;


                  step:=step+1;
                od;

              fi;

            else
              if simi=fail then
                simi:=IsomorphismSimplifiedFpGroup(Source(quot));
                simiq:=InverseGeneralMapping(simi)*quot;
              fi;
              e:=LargerQuotientBySubgroupAbelianization(simiq,m);
              if e<>fail then
                i:=simi*DefiningQuotientHomomorphism(e);
                j:=Image(DefiningQuotientHomomorphism(e));;
                j:=List(Orbits(j,MovedPoints(j)),x->Stabilizer(j,x[1]));
                j:=List(j,x->PreImage(i,x));
                e:=Intersection(j);
                e:=Intersection(e,KernelOfMultiplicativeGeneralMapping(quot));
              fi;
            fi;


            if e<>fail then
              # can we do better degree -- greedy block reduction?
              nn:=e!.quot;
              if IsTransitive(nn,MovedPoints(nn)) then
                repeat
                  ei:=ShallowCopy(RepresentativesMinimalBlocks(nn,
                    MovedPoints(nn)));
                  SortBy(ei,x->-Length(x)); # long ones first
                  j:=false;
                  i:=1;
                  while i<=Length(ei) and j=false do
                    str:=Stabilizer(nn,ei[i],OnSets);
                    if Size(Core(nn,str))=1 then
                      j:=ei[i];
                    fi;
                    i:=i+1;
                  od;
                  if j<>false then
                    Info(InfoExtReps,4,"deg. improved by blocks ",Size(j));
                    # action on blocks
                    i:=ActionHomomorphism(nn,Orbit(nn,j,OnSets),OnSets);
                    j:=Size(nn);
                    # make new group to not cache anything about old.
                    nn:=Group(List(GeneratorsOfGroup(nn),
                      x->ImagesRepresentative(i,x)),());
                    SetSize(nn,j);
                  fi;
                until j=false;

              fi;
              if not IsIdenticalObj(nn,e!.quot) then
                Info(InfoExtReps,2,"Degree improved by factor ",
                  NrMovedPoints(e!.quot)/NrMovedPoints(nn));

                e:=SubgroupOfWholeGroupByQuotientSubgroup(FamilyObj(fps),nn,
                  Stabilizer(nn,1));
              fi;
            elif e=fail and IndexNC(p,m)>trysy then
              trysy:=Size(fp); # never try again
              # can the Sylow subgroup get us something?
              m:=SylowSubgroup(p,prime);
              e:=PreImage(quot,m);
              Info(InfoExtReps,2,"Sylow test for index ",IndexNC(p,m));
              i:=IsomorphismFpGroup(e:cheap); # only one TzGo
              e:=EpimorphismPGroup(Range(i),prime,PClassPGroup(m)+1);
              e:=i*e; # map onto pgroup
              j:=KernelOfMultiplicativeGeneralMapping(
                  InverseGeneralMapping(e)*quot);
              i:=RandomSubgroupNotIncluding(Range(e),j,20000); # 20 seconds
              Info(InfoExtReps,2,"Sylow found ",IndexNC(p,m)," * ",
                IndexNC(Range(e),i));
              if IndexNC(Range(e),i)*IndexNC(p,m)<
                  # consider permdegree up to
                  100000
                  # as manageable
                then
                e:=PreImage(e,i);
                #e:=KernelOfMultiplicativeGeneralMapping(
                #  DefiningQuotientHomomorphism(i));
              else
                e:=fail; # not good
              fi;
            fi;

          else Info(InfoExtReps,4,"Don't index ",Index(p,m));
          fi;

        until e<>fail;
        i:=p;

        quot:=DefiningQuotientHomomorphism(Intersection(e,
          KernelOfMultiplicativeGeneralMapping(quot)));
        p:=Image(quot);
        Info(InfoExtReps,1,"index ",Index(i,m)," increases factor by ",
             Size(p)/Size(i)," at degree ",NrMovedPoints(p));
        hom:=false; # we don't have hom cheaply any longer as group changed.
        # this is not an issue if module is irreducible
        it:=fail; simi:=fail; # cleanout info for first factor
      od;
      quot:=sim*quot;
      new:=GroupHomomorphismByImages(fp,p,GeneratorsOfGroup(fp),
        List(GeneratorsOfGroup(fp),x->ImagesRepresentative(quot,x)));

    fi;
    # if we used factor perm rep, be bolder
    if IsPermGroup(p) then
      new:=new*SmallerDegreePermutationRepresentation(p:cheap:=wasbold<>true);
      SetIsomorphismPermGroup(fp,new);
    elif IsPcGroup(p) then
      SetIsomorphismPcGroup(fp,new);
    fi;
  fi;

  if HasIsSolvableGroup(r.group) then
    SetIsSolvableGroup(fp,IsSolvableGroup(r.group));
  fi;

  return fp;
end);

InstallGlobalFunction("CompatiblePairOrbitRepsGeneric",function(cp,coh)
local bas,ran,mats,o;
  if Length(coh.cohomology)=0 then return [coh.zero];fi;
  if Length(coh.cohomology)=1 and Size(coh.module.field)=2 then
    # 1-dim space over GF(2)
    return [coh.zero,coh.cohomology[1]];
  fi;
  # make basis
  bas:=Concatenation(coh.coboundaries,coh.cohomology);
  ran:=[Length(coh.coboundaries)+1..Length(bas)];
  mats:=List(GeneratorsOfGroup(cp),g->List(coh.cohomology,
    v->SolutionMat(bas,coh.pairact(v,g)){ran}));
  o:=Orbits(Group(mats),coh.module.field^Length(coh.cohomology));
  o:=List(o,x->x[1]*coh.cohomology);
  return o;
end);

#############################################################################
##
#M  Extensions( G, M )
##
InstallOtherMethod(Extensions,"generic method for finite groups",
    true,[IsGroup and IsFinite,IsObject],
    -RankFilter(IsGroup and IsFinite),
function(G,M)
local coh;
  coh:=TwoCohomologyGeneric(G,M);
  return List(Elements(VectorSpace(coh.module.field,coh.cohomology)),
    x->FpGroupCocycle(coh,x,true:normalform));
end);

InstallOtherMethod(ExtensionRepresentatives,"generic method for finite groups",
  true,[IsGroup and IsFinite,IsObject,IsGroup],
    -RankFilter(IsGroup and IsFinite),
function(G,M,P)
local coh;
  coh:=TwoCohomologyGeneric(G,M);
  return List(CompatiblePairOrbitRepsGeneric(P,coh),
    x->FpGroupCocycle(coh,x,true:normalform));
end);

