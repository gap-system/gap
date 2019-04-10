#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This files's authors include Bettina Eick and Alexander Hulpke.
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

# return isomorphism G-fp and fp->mon, such that presentation of monoid is
# confluent (wrt wreath order). Returns list [fphom,monhom,ordering]
BindGlobal("ConfluentMonoidPresentationForGroup",function(G)
local iso,fp,n,dec,homs,mos,i,j,ffp,imo,m,k,gens,fm,mgens,rules,
      loff,off,monreps,left,right,fmgens,r,diff,monreal,nums,reduce,hom,dept;
  iso:=IsomorphismFpGroupByChiefSeries(G:rewrite);
  fp:=Range(iso);
  gens:=GeneratorsOfGroup(fp);
  n:=Length(gens);
  dec:=iso!.decompinfo;

  fmgens:=[];
  mgens:=[];
  for i in gens do
    Add(fmgens,i);
    Add(fmgens,i^-1);
    Add(mgens,String(i));
    Add(mgens,String(i^-1));
  od;
  nums:=List(fmgens,x->LetterRepAssocWord(UnderlyingElement(x))[1]);
  fm:=FreeMonoid(mgens);
  mgens:=GeneratorsOfMonoid(fm);
  rules:=[];
  reduce:=function(w)
  local red,i,p;
    w:=LetterRepAssocWord(w);
    repeat
      i:=1;
      red:=false;
      while i<=Length(rules) and red=false do
        p:=PositionSublist(w,LetterRepAssocWord(rules[i][1]));
        if p<>fail then
          #Print("Apply ",rules[i],p,w,"\n");
          w:=Concatenation(w{[1..p-1]},LetterRepAssocWord(rules[i][2]),
            w{[p+Length(rules[i][1])..Length(w)]});
          red:=true;
        else
          i:=i+1;
        fi;
      od;
    until red=false;
    return AssocWordByLetterRep(FamilyObj(One(fm)),w);
  end;


  homs:=ShallowCopy(dec.homs);
  mos:=[];
  off:=Length(mgens);
  dept:=[];
  # go up so we may reduce tails
  for i in [Length(homs),Length(homs)-1..1] do
    Add(dept,off);
    if IsPcgs(homs[i]) then
      ffp:=AbelianGroup(IsFpGroup,RelativeOrders(homs[i]));
    else
      ffp:=Range(dec.homs[i]);
    fi;
    imo:=IsomorphismFpMonoid(ffp);
    Add(mos,imo);
    m:=Range(imo);
    loff:=off-Length(GeneratorsOfMonoid(m));
    monreps:=fmgens{[loff+1..off]};
    monreal:=mgens{[loff+1..off]};
    if IsBound(m!.rewritingSystem) then
      k:=m!.rewritingSystem;
    else
      k:=KnuthBendixRewritingSystem(m);
    fi;
    MakeConfluent(k);
    # convert rules
    for r in Rules(k) do
      left:=MappedWord(r[1],FreeGeneratorsOfFpMonoid(m),monreps);
      right:=MappedWord(r[2],FreeGeneratorsOfFpMonoid(m),monreps);
      diff:=LeftQuotient(PreImagesRepresentative(iso,right),
              PreImagesRepresentative(iso,left));
      diff:=ImagesRepresentative(iso,diff);

      left:=MappedWord(r[1],FreeGeneratorsOfFpMonoid(m),monreal);
      right:=MappedWord(r[2],FreeGeneratorsOfFpMonoid(m),monreal);
      if not IsOne(diff) then 
        right:=right*Product(List(LetterRepAssocWord(UnderlyingElement(diff)),
          x->mgens[Position(nums,x)]));
      fi;
      right:=reduce(right); # monoid word might change
      Add(rules,[left,right]);
    od;
    for j in [loff+1..off] do
      # if the generator gets reduced away, won't need to use it
      if reduce(mgens[j])=mgens[j] then
        for k in [off+1..Length(mgens)] do
          if reduce(mgens[k])=mgens[k] then
            right:=fmgens[j]^-1*fmgens[k]*fmgens[j];
            #collect
            right:=ImagesRepresentative(iso,PreImagesRepresentative(iso,right));
            right:=Product(List(LetterRepAssocWord(UnderlyingElement(right)),
              x->mgens[Position(nums,x)]));
            right:=reduce(mgens[j]*right);
            Add(rules,[mgens[k]*mgens[j],right]);
          fi;
        od;
      fi;
    od;
    #if i<Length(homs) then Error("ZU");fi;
    off:=loff;
  od;
  Add(dept,off);
  # calculate levels for ordering
  dept:=dept+1;
  dept:=List([1..Length(mgens)],
    x->PositionProperty(dept,y->x>=y)-1);

  if ForAny(rules,x->x[2]<>reduce(x[2])) then Error("irreduced right");fi;

  # inverses are true inverses, also for extension
  for i in [1..Length(gens)] do
    left:=mgens[2*i-1]*mgens[2*i];
    left:=reduce(left);
    if left<>One(fm) then Add(rules,[left,One(fm)]); fi;
    left:=mgens[2*i]*mgens[2*i-1];
    left:=reduce(left);
    if left<>One(fm) then Add(rules,[left,One(fm)]); fi;
  od;

  # finally create 
  m:=FactorFreeMonoidByRelations(fm,rules);
  mgens:=GeneratorsOfMonoid(m);

  hom:=MagmaIsomorphismByFunctionsNC(fp,m,
        function(w)
          local l,i;
          l:=[];
          for i in LetterRepAssocWord(UnderlyingElement(w)) do
            if i>0 then Add(l,2*i-1);
            else Add(l,-2*i);fi;
          od;
          return ElementOfFpMonoid(FamilyObj(One(m)),
                  AssocWordByLetterRep(FamilyObj(One(fm)),l));
        end,
        function(w)
          local g,i,x;
          g:=[];
          for i in LetterRepAssocWord(UnderlyingElement(w)) do
            if IsOddInt(i) then x:=(i+1)/2;
            else x:=-i/2;fi;
            # word must be freely cancelled
            if Length(g)>0 and x=-g[Length(g)] then
              Unbind(g[Length(g)]);
            else Add(g,x); fi;
          od;
          return ElementOfFpGroup(FamilyObj(One(fp)),
                  AssocWordByLetterRep(FamilyObj(One(FreeGroupOfFpGroup(fp))),g));
        end);

  hom!.type:=1;
  if not HasIsomorphismFpMonoid(G) then
    SetIsomorphismFpMonoid(G,hom);
  fi;
  return [iso,hom,WreathProductOrdering(fm,dept)];
end);

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
                isPcCohomology:=true,
                cohom := 
                NaturalHomomorphismBySubspaceOntoFullRowSpace(co,cb),
                presentation := FpGroupPcGroupSQ( G ) );
end );

# code for generic 2-cohomology (solvable not required)

InstallMethod( TwoCohomologyGeneric,"generic, using rewriting system",true, 
  [IsGroup and IsFinite,IsObject],0,
function(G,mo)
local field,fp,fpg,gens,hom,mats,fm,mon,kb,tzrules,dim,rules,eqs,i,j,k,l,o,l1,
      len1,l2,m,start,formalinverse,hastail,one,zero,new,v1,v2,collectail,
      findtail,colltz,mapped,mapped2,onemat,zerovec,dict,max,mal,s,p,
      c,nvars,htpos,zeroq,r,ogens,bds,model,q,pre,pcgs,miso,ker,solvec,rulpos;


  # collect the word in factor group
  colltz:=function(a)
  local i,j,s,mm,p;

    # collect from left
    i:=1;
    while i<=Length(a) do

      # does a rule apply at position i?
      j:=0;
      s:=0;
      mm:=Minimum(mal,Length(a)-i+1);
      while j<mm do
        s:=s*max+a[i+j];
        p:=LookupDictionary(dict,s);
        if p<>fail then break; fi;
        j:=j+1;
      od;

      if p<>fail then
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
      a:=a*mats[i];
    od;
    return a;
  end;

  # normalform word and collect the tails
  collectail:=function(wrd)
  local v,tail,i,j,s,p,mm;
    v:=List(rules,x->zero);

    # collect from left
    i:=1;
    while i<=Length(wrd) do

      # does a rule apply at position i?
      j:=0;
      s:=0;
      mm:=Minimum(mal,Length(wrd)-i+1);
      while j<mm do
        s:=s*max+wrd[i+j];
        p:=LookupDictionary(dict,s);
        if p<>fail and rulpos[p]<>fail then break; fi;
        j:=j+1;
      od;

      if p<>fail and rulpos[p]<>fail then
        p:=rulpos[p];
        tail:=wrd{[i+Length(rules[p][1])..Length(wrd)]};
        wrd:=Concatenation(wrd{[1..i-1]},rules[p][2],tail);
#Print("Apply ",p,"@",i,":",wrd,"\n");
        if p in hastail then v[p]:=v[p]+mapped(tail); fi;
        i:=Maximum(0,i-mal); # earliest which could be affected
      fi;
      i:=i+1;
    od;

    return [wrd,v];
  end;

  field:=mo.field;

  ogens:=GeneratorsOfGroup(G);

  if false then
    #  old general KB code, left for debugging
    fp:=IsomorphismFpGroup(G);
    fpg:=Range(fp);
    fm:=IsomorphismFpMonoid(fpg);
    mon:=Range(fm);

    if IsBound(mon!.confl) then 
      tzrules:=mon!.confl;
    else
      kb:=KnuthBendixRewritingSystem(mon);
      MakeConfluent(kb);
      tzrules:=kb!.tzrules;
      mon!.confl:=tzrules;
    fi;
  else
    # new approach with RWS from chief series
    mon:=ConfluentMonoidPresentationForGroup(G);
    fp:=mon[1];
    fpg:=Range(fp);
    fm:=mon[2];
    mon:=Range(fm);
    tzrules:=List(RelationsOfFpMonoid(mon),x->List(x,LetterRepAssocWord));
  fi;

  # build data structure to find rule applicable at given position. Assumes
  # that rule set is reduced.
  max:=Maximum(Union(List(tzrules,x->x[1])))+1;
  mal:=Maximum(List(tzrules,x->Length(x[1])));
  dict:=NewDictionary(max,Integers,true);
  for i in [1..mal] do
    p:=Filtered([1..Length(tzrules)],x->Length(tzrules[x][1])=i);
    for j in p do
      s:=0;
      for k in [1..i] do
        s:=s*max+tzrules[j][1][k];
      od;
      AddDictionary(dict,s,j);
    od;
  od;

  gens:=List(GeneratorsOfGroup(FamilyObj(fpg)!.wholeGroup),
    x->PreImagesRepresentative(fp,x));

  hom:=GroupHomomorphismByImages(G,Group(mo.generators),GeneratorsOfGroup(G),mo.generators);
  mo:=GModuleByMats(List(gens,x->ImagesRepresentative(hom,x)),mo.field); # new gens

  #rules:=ShallowCopy(kb!.tzrules);
  #hastail:=Filtered([1..Length(rules)],x->Length(rules[x][1])<>2 or
  #  Length(rules[x][2])>0 or formalinverse[rules[x][1][1]]<>rules[x][1][2]);
  #IsSet(hastail); # quick membership test

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
  for r in tzrules do
    if Length(r[1])>=2 then
      Add(rules,r);
      if Length(r[1])>2 or
        (Length(r[1])=2 and (Length(r[2])>0 or formalinverse[r[1][1]]<>r[1][2]))
        then 
          AddSet(hastail,Length(rules));
      fi;
    elif Length(r[1])>1 then
      if Length(r[2])=0 then Error("generator is trivial");fi;
      if Length(r[2])<>1 or formalinverse[r[1][1]]<>r[2][1] then
        Add(rules,r);
        AddSet(hastail,Length(rules));
      else
#Print("Not use: ",r,"\n");
        # Do not use these rules for overlaps
        if r[2][1]>r[1][1] then
          Error("code assumes that larger number gets reduced to smaller");
        fi;
        if ForAny(rules,x->r[1][1] in x[2] or (x<>r and r[1][1] in x[1])) then
          Error("rules are not reduced");
        fi;
      fi;
    else
      # Length of r[1] is 1. That is this generator is not used.
      # check that it is really just an inverse that goes away, otherwise
      # awkward.
      if formalinverse[r[1][1]]>r[1][1] then
        Error("generator vanishes?");
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
  zero:=zerovec;
  dim:=Length(zero);
  nvars:=dim*Length(hastail); #Number of variables

  eqs:=[];
  zeroq:=ImmutableVector(field,ListWithIdenticalEntries(nvars,Zero(field)));
  for i in [1..Length(rules)] do
    l1:=rules[i][1];
    len1:=Length(l1);
    for j in [1..Length(rules)] do
      l2:=rules[j][1];
      m:=Minimum(len1,Length(l2));
      for o in [1..m-1] do # possible overlap Length
        start:=len1-o;
        if ForAll([1..o],k->l1[start+k]=l2[k]) then
          #Print("Overlap ",l1," ",l2," ",o,"\n");

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
              if not IsZero(k) then
                if model<>fail and not IsZero(solvec*k) then
                  Error("model does not fit");
                fi;
                AddSet(eqs,ImmutableVector(field,k));
              fi;
            od;
          fi;
        fi;
      od;
    od;
  od;
  eqs:=Filtered(TriangulizedMat(eqs),x->not IsZero(x));
  eqs:=NullspaceMat(TransposedMat(eqs)); # basis of cocycles

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
        Assert(1,SolutionMat(eqs,new)<>fail);
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
    prewords:=List(ogens,x->UnderlyingElement(ImagesRepresentative(fp,x))));

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
    local v,i,j,s,p,mm,w,tail;
      v:=zerovec;

      # collect from left
      i:=1;
      while i<=Length(wrd) do

        # does a rule apply at position i?
        j:=0;
        s:=0;
        mm:=Minimum(mal,Length(wrd)-i+1);
        while j<mm do
          s:=s*max+wrd[i+j];
          p:=LookupDictionary(dict,s);
          if p<>fail and rulpos[p]<>fail then break; fi;
          j:=j+1;
        od;

        if p<>fail and rulpos[p]<>fail then
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

InstallGlobalFunction(FpGroupCocycle,function(arg)
local r,z,ogens,n,gens,str,dim,i,j,f,rels,new,quot,g,p,lay,m,e,fp,old,sim;
  r:=arg[1];
  z:=arg[2];
  ogens:=GeneratorsOfGroup(r.presentation.group);
  n:=Length(ogens);
  str:=List(ogens,String);
  dim:=r.module.dimension;
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
  for i in [n+1..Length(gens)] do
    Add(rels,gens[i]^r.prime);
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
  SetSize(fp,Size(r.group)*Size(r.module.field)^r.module.dimension);

  if Length(arg)>2 and arg[3]=true then
    #sim:=IsomorphismSimplifiedFpGroup(fp);
    sim:=IdentityMapping(fp);

    g:=r.group;
    quot:=InverseGeneralMapping(sim)*GroupHomomorphismByImages(fp,g,GeneratorsOfGroup(fp),
      Concatenation(GeneratorsOfGroup(g),
        ListWithIdenticalEntries(r.module.dimension,One(g))));
    p:=Image(quot);
    old:=[];
    while Size(p)<Size(fp) do
      lay:=0;
      repeat
        if lay=0 then
          if IsPermGroup(p) then
            m:=List(Orbits(p,MovedPoints(p)),x->Stabilizer(p,x[1]));
          else
            m:=[];
          fi;
        else
          m:=ShallowCopy(LowLayerSubgroups(p,lay));
        fi;
        # no repetition
        m:=Filtered(m,x->not ForAny(old,y->Size(x)=Size(y) and x=y));
        Append(old,m);

        SortBy(m,x->-Size(x));
        i:=1;
        e:=fail;
        while i<=Length(m) and e=fail do
          e:=LargerQuotientBySubgroupAbelianization(quot,m[i]);
          i:=i+1;
        od;
        lay:=lay+1;
      until e<>fail;

      quot:=DefiningQuotientHomomorphism(Intersection(e,
        KernelOfMultiplicativeGeneralMapping(quot)));
      p:=Image(quot);
    od;
    quot:=sim*quot;
    new:=GroupHomomorphismByImages(fp,p,GeneratorsOfGroup(fp),
      List(GeneratorsOfGroup(fp),x->ImagesRepresentative(quot,x)));
    new:=new*SmallerDegreePermutationRepresentation(p);
    SetIsomorphismPermGroup(fp,new);
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
