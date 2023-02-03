#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for normalizers of polycyclic groups.
##


#############################################################################
##
#F  PCGS_STABILIZER( <pcgs>, <pnt>, <op> )  . . . . . . . . . . . . . . local
##
BindGlobal( "PCGS_STABILIZER", function( arg )
    local   pcgs,  pnt,  op,  data,  one,  orb,  prod,  n,  s,  i,
            mi,  np,  j,  o,  len,  l1,  k,  l2,  r,  e,  stab,  ros,dict;

    pcgs := arg[1];
    pnt  := arg[2];
    op   := arg[3];
    one  := OneOfPcgs(pcgs);
    ros  := RelativeOrders(pcgs);
    pcgs := ShallowCopy(pcgs);
    dict:=NewDictionary(pnt,true,true);

    # without data blob
    if Length(arg) = 3  then

        # operate on canonical versions
        pnt := op( pnt, one );

        # store representatives in <r>
        orb  := [ pnt ];
        AddDictionary(dict,pnt,1);
        prod := [ 1 ];
        n    := [];
        s    := [];
        stab := [];

        # go *up* the composition series
        for i  in Reversed([1..Length(pcgs)])  do
            mi := pcgs[i];
            np := op( pnt, mi );

            # is <np> really a new point or is it in <orb>
            j := LookupDictionary(dict, np );

            # add it if it is new
            if j = fail  then
                o := ros[i];
                Add( prod, prod[Length(prod)] * o );
                Add( n, i );
                len := Length(orb);
                l1  := 0;
                for k  in [ 1 .. o-1 ]  do
                    l2 := l1 + len;
                    for j  in [ 1 .. len ]  do
                        orb[j+l2] := op( orb[j+l1], mi );
                        AddDictionary(dict,orb[j+l2],j+l2);
                    od;
                    l1 := l2;
                od;

            # if it is the start point the element stabilizes
            elif j = 1 then
                Add( s, mi );

            # compute a stabilizing element
            else
                if not IsBound(stab[j])  then
                    r   := one;
                    l1  := j-1;
                    len := Length(prod);
                    for k  in [ 1 .. len-1 ]  do
                        e  := QuoInt( l1, prod[len-k] );
                        r  := pcgs[n[len-k]]^e * r;
                        l1 := l1 mod prod[len-k];
                        if l1 = 0  then
                            break;
                        fi;
                    od;
                    stab[j] := r;
                fi;
                Add( s, pcgs[i] / stab[j] );
            fi;
        od;

    # with data blob
    else
        data := arg[4];

        # operate on canonical versions
        pnt := op( data, pnt, one );

        # store representatives in <r>
        orb  := [ pnt ];
        AddDictionary(dict,pnt,1);
        prod := [ 1 ];
        n    := [];
        s    := [];
        stab := [];

        # go *up* the composition series
        for i  in Reversed([1..Length(pcgs)])  do
            mi := pcgs[i];
            np := op( data, pnt, mi );

            # is <np> really a new point or is it in <orb>
            j := LookupDictionary(dict, np );

            # add it if it is new
            if j = fail  then
                o := ros[i];
                Add( prod, prod[Length(prod)] * o );
                Add( n, i );
                len := Length(orb);
                l1  := 0;
                for k  in [ 1 .. o-1 ]  do
                    l2 := l1 + len;
                    for j  in [ 1 .. len ]  do
                        orb[j+l2] := op( data, orb[j+l1], mi );
                        AddDictionary(dict,orb[j+l2],j+l2);
                    od;
                    l1 := l2;
                od;

            # if it is the start point the element stabilizes
            elif j = 1 then
                Add( s, mi );

            # compute a stabilizing element
            else
                if not IsBound(stab[j])  then
                    r   := one;
                    l1  := j-1;
                    len := Length(prod);
                    for k  in [ 1 .. len-1 ]  do
                        e  := QuoInt( l1, prod[len-k] );
                        r  := pcgs[n[len-k]]^e * r;
                        l1 := l1 mod prod[len-k];
                        if l1 = 0  then
                            break;
                        fi;
                    od;
                    stab[j] := r;
                fi;
                Add( s, pcgs[i] / stab[j] );
            fi;
        od;
    fi;

    Info( InfoPcNormalizer, 3, "orbit length: ", Length(orb) );
    return Reversed(s);

end );


#############################################################################
##
#F  PCGS_STABILIZER_HOMOMORPHIC( <pcgs>, <homs>, <pnt>, <op> )  . . . . local
##
BindGlobal( "PCGS_STABILIZER_HOMOMORPHIC", function( arg )
    local   pcgs,  homs,  pnt,  op,  ros,  one,  hone,  orb,  prod,
            n,  s,  stab,  i,  mi,  np,  j,  o,  len,  l1,  k,  l2,
            r,  e,  dict;

    pcgs := arg[1];
    homs := arg[2];
    pnt  := arg[3];
    op   := arg[4];
    dict:=NewDictionary(pnt,true,true);
    if 0 = Length(pcgs)  then
        return pcgs;
    fi;
    if Length(pcgs) <> Length(homs)  then
        Error( "expecting ", Length(pcgs), " homomorphic images in <homs>" );
    fi;
    ros  := RelativeOrders(pcgs);
    one  := OneOfPcgs(pcgs);
    hone := One(homs[1]);
    pcgs := ShallowCopy(pcgs);

    # without data blob
    if Length(arg) = 4  then

        # operate on canonical versions
        pnt := op( pnt, hone );

        # store representatives in <r>
        orb  := [ pnt ];
        AddDictionary(dict,pnt,1);
        prod := [ 1 ];
        n    := [];
        s    := [];
        stab := [];

        # go *up* the composition series
        for i  in Reversed([1..Length(pcgs)])  do
            mi := homs[i];
            np := op( pnt, mi );

            # is <np> really a new point or is it in <orb>
            j := LookupDictionary(dict, np );

            # add it if it is new
            if j = fail  then
                o := ros[i];
                Add( prod, prod[Length(prod)] * o );
                Add( n, i );
                len := Length(orb);
                l1  := 0;
                for k  in [ 1 .. o-1 ]  do
                    l2 := l1 + len;
                    for j  in [ 1 .. len ]  do
                        orb[j+l2] := op( orb[j+l1], mi );
                        AddDictionary(dict,orb[j+l2],j+l2);
                    od;
                    l1 := l2;
                od;

            # if it is the start point the element stabilizes
            elif j = 1 then
                Add( s, pcgs[i] );

            # compute a stabilizing element
            else
                if not IsBound(stab[j])  then
                    r   := one;
                    l1  := j-1;
                    len := Length(prod);
                    for k  in [ 1 .. len-1 ]  do
                        e  := QuoInt( l1, prod[len-k] );
                        r  := pcgs[n[len-k]]^e * r;
                        l1 := l1 mod prod[len-k];
                        if l1 = 0  then
                            break;
                        fi;
                    od;
                    stab[j] := r;
                fi;
                Add( s, pcgs[i] / stab[j] );
            fi;
        od;

    # with data blob, this case is not used at all
    else
      Error("you should never be here");
    fi;

    Info( InfoPcNormalizer, 3, "orbit length: ", Length(orb) );
    return Reversed(s);

end );


#############################################################################
##
#F  PCGS_NORMALIZER( <home>, <norm>, <point>, <pcgs>, <modulo> )
##
BindGlobal( "PCGS_NORMALIZER_OPB", function( home, elm, obj )
    local   ord;

    elm := elm^obj;
    ord := RelativeOrderOfPcElement( home, elm );
    return elm ^ ( 1 / LeadingExponentOfPcElement( home, elm ) mod ord );
end );

BindGlobal( "PCGS_NORMALIZER_OPC1", function( data, elm, obj )
    local   ord;

    elm := elm^obj;
    ord := RelativeOrderOfPcElement( data[1], elm );
    elm := elm ^ ( 1 / LeadingExponentOfPcElement( data[1], elm ) mod ord );
    return HeadPcElementByNumber( data[1], elm, data[2] );
end );

BindGlobal( "PCGS_NORMALIZER_OPC2", function( data, elm, obj )
# was:  return CanonicalPcElement( data[2], elm^obj );
local ord;
    elm := elm^obj;
    ord:=RelativeOrderOfPcElement(data[1],elm);
    elm := elm ^ ( 1 / LeadingExponentOfPcElement( data[1], elm ) mod ord );
    return CanonicalPcElement( data[2], elm );
end );

BindGlobal( "PCGS_NORMALIZER_OPD", function( data, lst, obj )
  lst:=CorrespondingGeneratorsByModuloPcgs(data,List(lst,i->i^obj));
  return lst;
end );

BindGlobal( "PCGS_NORMALIZER_OPE", function( data, lst, obj )
    local   home,  pag,  pos,  max,  i,  g,  dg,  exp,  j,  ros;

    home := data[1];
    pag  := data[2]; # make sure to reset <pag> before returning
    pos  := [];
    max  := data[3];
    ros  := data[4];
    for i  in [ Length(lst), Length(lst)-1 .. 1 ]  do
        g  := lst[i]^obj;
        dg := DepthOfPcElement( home, g );
        while dg < max  do
            if IsBound(pag[dg])  then
                g  := ReducedPcElement( home, g, pag[dg] );
                dg := DepthOfPcElement( home, g );
            else
                pag[dg] := g;
                AddSet( pos, dg );
                break;
            fi;
        od;
    od;
    for i  in Reversed(pos)  do
        exp := LeadingExponentOfPcElement( home, pag[i] );
        if exp <> 1  then
            pag[i] := pag[i] ^ (1/exp mod ros[i]);
        fi;
        for j  in [ i+1 .. max-1 ]  do
            if IsBound(pag[j])  then
                exp := ExponentOfPcElement( home, pag[i], j );
                if exp <> 0  then
                    pag[i] := pag[i] * pag[j]^(ros[j]-exp);
                fi;
            fi;
        od;
        pag[i] := HeadPcElementByNumber( home, pag[i], max );
    od;
    lst := pag{pos};
    for i  in pos  do Unbind(pag[i]);  od;
    return lst;
end );

BindGlobal( "PCGS_NORMALIZER_DATAE", function( home, modulo )
    local   ros,  sub,  i,  dg,  exp,  max;

    ros := RelativeOrders(home);
    sub := [];
    for i  in modulo  do
        dg  := DepthOfPcElement( home, i );
        exp := LeadingExponentOfPcElement( home, i );
        if exp <> 1  then
            i := i ^ (1/exp mod ros[dg]);
        fi;
        sub[dg] := i;
    od;
    max := Length(home)+1;
    while 2 <= max and IsBound(sub[max-1])  do
        max := max-1;
    od;
    return [ home, sub, max, ros ];
end );


BindGlobal( "PCGS_NORMALIZER", function( home, pcgs, pnt, modulo )
    local   op,  s,  data;

    Info( InfoPcNormalizer, 5, "home:       ", ShallowCopy(home) );
    Info( InfoPcNormalizer, 4, "normalizer: ", ShallowCopy(pcgs) );
    Info( InfoPcNormalizer, 4, "point:      ", ShallowCopy(pnt) );
    Info( InfoPcNormalizer, 5, "modulo:     ", ShallowCopy(modulo) );

    # if <pnt> and <modulo> have the same length nothing is to be done
    if Length(pnt) = Length(modulo)  then
        Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case A" );
        return pcgs;

    # if <pnt> mod <modulo> has only one element operate on elements
    elif Length(pnt)-1 = Length(modulo)  then
        if 0 = Length(modulo)  then
            Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case B" );
            pnt  := pnt[1];
            op   := PCGS_NORMALIZER_OPB;
            data := home;
            s    := PCGS_STABILIZER( pcgs, pnt, op, home );
        else
            pnt  := pnt mod modulo;
            pnt  := pnt[1];
            if ParentPcgs(modulo)=home and IsTailInducedPcgsRep(modulo)  then
                Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case C1" );
                op   := PCGS_NORMALIZER_OPC1;
                data := [ home, modulo!.tailStart ];
            else
                Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case C2" );
                op   := PCGS_NORMALIZER_OPC2;
                data := [home,modulo];
            fi;
            s := PCGS_STABILIZER( pcgs, pnt, op, data );
        fi;

    # if the <modulo> is trivial it is relatively easy
    elif 0 = Length(modulo)  then
        Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case D" );
        op   := PCGS_NORMALIZER_OPD;
        pnt  := ShallowCopy(pnt);
        s    := PCGS_STABILIZER( pcgs, pnt, op, home );

    # it is get more complicated
    else
        Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case E" );
        data := PCGS_NORMALIZER_DATAE( home, modulo );
        op   := PCGS_NORMALIZER_OPE;
        pnt  := ShallowCopy( pnt mod modulo );
        s    := PCGS_STABILIZER( pcgs, pnt, op, data );
    fi;

    # convert it into a modulo pcgs
    pcgs := SumPcgs( home, DenominatorOfModuloPcgs(pcgs), s )
        mod DenominatorOfModuloPcgs(pcgs);
    Info( InfoPcNormalizer, 4, "new norm:   ", ShallowCopy(pcgs) );
    return pcgs;

end );


#############################################################################
##
#F  PCGS_NORMALIZER_LINEAR( <home>, <norm>, <point>, <modulo-pcgs> )
##
BindGlobal( "PCGS_NORMALIZER_LINEAR", function( home, pcgs, pnt, modulo )
local   f,  o,  m,  sub,  s,p,op;

    Info( InfoPcNormalizer, 5, "home:       ", ShallowCopy(home) );
    Info( InfoPcNormalizer, 4, "normalizer: ", ShallowCopy(pcgs) );
    Info( InfoPcNormalizer, 4, "point:      ", ShallowCopy(pnt) );
    Info( InfoPcNormalizer, 5, "modulo:     ", ShallowCopy(modulo) );

    # construct the linear operation
    p:=RelativeOrderOfPcElement( home, modulo[1] );
    f := GF(p);
    o := One(f);
    m := List( pcgs, x -> List( modulo, y ->
             ExponentsConjugateLayer( modulo, y,x ) * o ) );

    for s in [1..Length(m)] do
      m[s]:=ImmutableMatrix(f,m[s]);
    od;

    # convert <pnt> into a subspace
    sub := pnt mod DenominatorOfModuloPcgs(modulo);
    sub := List( sub, x -> ExponentsOfPcElement( modulo, x ) * o );
    sub:=ImmutableMatrix(f,sub);

    # select operation function and prepare matrices if necessary
    if p=2 then
      op:=OnSubspacesByCanonicalBasisGF2;
    else
      op:=OnSubspacesByCanonicalBasis;
    fi;

    # compute the stabilizer
    Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER_LINEAR case A" );
    s := PCGS_STABILIZER_HOMOMORPHIC( pcgs, m, sub, op );

    # convert it into a modulo pcgs
    pcgs := SumPcgs( home, DenominatorOfModuloPcgs(pcgs), s )
        mod DenominatorOfModuloPcgs(pcgs);
    Info( InfoPcNormalizer, 4, "new norm:   ", ShallowCopy(pcgs) );
    return pcgs;

end );


#############################################################################
##
#F  PCGS_CONJUGATING_WORD_GS( <home>, <n>, <u>, <v>, <k> )
##
##  Let <u> / <k> and <v>  / <k> be two  p-groups such that <u>*<n> = <v>*<n>
##  and let <n> be an elementary abelian  q-group with q  <> p. Then a word x
##  of <n> with <u> ^ x = <v> is returned. <k> must be normal in <u>*<n>.
##
##  It is important, that the weights of <K> are less than those of <N>.
##
BindGlobal( "PCGS_CONJUGATING_WORD_GS", function( home, n, u, v, k )
    local   id,  x,  q,  i,  p,  t,  m,  vv,  mm,  xx,  j;

    # if <n> or <u> / <k> is trivial, just return identity
    id := OneOfPcgs(home);
    if 0 = Length(n) or 0 = Length(u) or u = v  then
        return id;
    fi;

    # Find  the  word  <n>  using the algorithm of Kantor. See S.P.Glasby and
    # Michael  C.  Slattery,  "Computing  intersections  and  normalizers  in
    # soluble groups", 1989.

    x := id;
    q := RelativeOrderOfPcElement( home, n[1] );
    for i  in Reversed( [ 1 .. Length(u) ] )  do

        # the orders must be coprime
        p := RelativeOrderOfPcElement( home, u[i] );
        if q = p  then
            Error( "relative orders <u> and <n> are not coprime" );
        fi;

        # Compute an integer <t> such that <t> * <p> = -1 mod <q>.
        t := -Gcdex( p, q ).coeff1;
        while t > q  do t := t - q;  od;
        while t < 0  do t := t + q;  od;

        m  := LeftQuotient( u[i]^x, v[i] );
        m  := SiftedPcElement( k, m );
        vv := id;
        mm := id;
        xx := id;

        # construct the product m^v * (m^2)^(v^2) * ... * (m^p-1)^(v^p-1)
        for j  in [ 1 .. p-1 ]  do
            vv := vv * v[i];
            mm := mm * m;
            xx := xx * ( mm^vv );
        od;
        x := x * ( xx ^ t );
    od;

    return x;

end );


#############################################################################
##
#F  PCGS_NORMALIZER_GLASBY( <home>, <norm>, <nis>, <pcgs>, <modulo> )
##
BindGlobal( "PCGS_NORMALIZER_GLASBY", function( home, pcgs, nis, u1, u2 )
    local   id,  stb,  data,  pnt,  i,  cnj,  ns,  one,  mats,  sys,
            sol,  v,  j;

    # The situation is as follows:
    #
    #                    S
    #                     \
    #                      \
    #                       Us
    #                      /  \
    #                     /    \
    #                    U1      Ns       N
    #                      \    /  \     /
    #                       \  /    \   /
    #                        U2      NiS
    #                         \     /
    #                          \   /
    #                           Un
    #
    # and <S> stabilizes <U2>

    # first correct (S mod NiS)
    Info( InfoPcNormalizer, 4, "correcting glasby block stabilizer" );
    id   := OneOfPcgs(pcgs);
    stb  := NumeratorOfModuloPcgs(pcgs) mod NumeratorOfModuloPcgs(nis);
    stb  := ShallowCopy(stb);
    data := PCGS_NORMALIZER_DATAE( home, u2 );
    pnt  := PCGS_NORMALIZER_OPE( data, u1 mod u2, id );
    for i  in [ 1 .. Length(stb) ]  do
        cnj := PCGS_NORMALIZER_OPE( data, pnt, stb[i] );
        cnj := PCGS_CONJUGATING_WORD_GS( home, nis, cnj, pnt, u2 );
        stb[i] := stb[i] * cnj;
    od;

    # now compute the stabilizer in <nis>
    Info( InfoPcNormalizer, 4, "computing the centralizer in <nis>" );

    # first the operation of <pnt> on (NiS mod U2)
    ns   := SumPcgs( home, u2, NumeratorOfModuloPcgs(nis) ) mod u2;
    one  := One( GF(RelativeOrderOfPcElement(home,ns[1])) );
    mats := List( pnt, x -> List( ns, y ->
                ExponentsConjugateLayer( ns, y,x ) * one ) );

    # set up the system of equations
    one := One(mats[1]);
    sys := [];
    for i  in [ 1 .. Length(mats[1]) ]  do
        sys[i] := [];
        for j  in [ 1 .. Length(mats) ]  do
            Append( sys[i], one[i] - mats[j][i] );
        od;
    od;
    sol := TriangulizedNullspaceMat(sys);
    for v  in sol  do
        v := List( v, IntFFE );
        Add( stb, PcElementByExponentsNC(ns,v) );
    od;

    # Now we have the normalizer in <S> / <U2>.  Get the complete preimage.
    return SumPcgs( home, u2, stb )
       mod DenominatorOfModuloPcgs(pcgs);

end );


#############################################################################
##
#F  PCGS_NORMALIZER_COBOUNDS( <home>, <norm>, <nis>, <pcgs>, <modulo> )
##
BindGlobal( "PCGS_NORMALIZER_COBOUNDS", function( home, pcgs, nis, u1, u2 )
    local   ns,  us,  gf,  one,  data,  u,  ui,  mats,  t,  l,  i,  b,
            nb,  c,  heads,  k,  ln1,  ln2,  op,  stab,  s,  j,  v;

    # The situation is as follows:
    #
    #                    S
    #                     \
    #                      \
    #                       Us
    #                      /  \
    #                     /    \
    #                   U1      Ns       N
    #                     \    /  \     /
    #                      \  /    \   /
    #                       U2      NiS
    #                         \    /
    #                          \  /
    #                           Un
    #
    # and <S> stabilizes <U2>

    # compute the operation of <u1> mod <u2> on <ns> mod <u2>
    ns   := SumPcgs( home, u2, NumeratorOfModuloPcgs(nis) ) mod u2;
    us   := SumPcgs( home, u1, NumeratorOfModuloPcgs(nis) );
    gf   := GF(RelativeOrderOfPcElement(home,ns[1]));
    one  := One(gf);
    data := PCGS_NORMALIZER_DATAE( home, u2 );
    u    := PCGS_NORMALIZER_OPE( data, u1 mod u2, OneOfPcgs(home) );
    ui   := List( u, Inverse );
    mats := List( u, x -> List(ns, y -> ExponentsConjugateLayer(ns,y,x)*one) );

    # compute the coboundaries
    Info( InfoPcNormalizer, 4, "using coboundaries and centralizer" );

    t := One(mats[1]);
    l := [];
    for i  in [ 1 .. Length(mats[1]) ]  do
        l[i] := [];
        for j  in [ 1 .. Length(mats) ]  do
            Append( l[i], t[i]-mats[j][i] );
        od;
    od;
    b  := TriangulizedGeneratorsByMatrix( ns, l, gf );
    nb := b[1];
    b  := b[2];
    b  := ImmutableMatrix(gf, b);

    # trivial coboundaries, use ordinary orbit
    if IsEmpty(b)  then
        Info( InfoPcNormalizer, 4, "coboundaries are trivial" );
        return PCGS_NORMALIZER( home, pcgs, u1, u2 );
    fi;
    Info( InfoPcNormalizer, 4, "|coboundaries| = ",
          RelativeOrderOfPcElement(home,ns[1]), "^", Length(b) );

    # compute the stabilizer
    c := List( TriangulizedNullspaceMat(l), x -> PcElementByExponentsNC(ns,x) );

    # compute the heads of the coboundaries
    heads := [];
    k := 1;
    i := 1;
    while i <= Length(b) and k <= Length(b[1])  do
        if IntFFE(b[i][k]) <> 0  then
            heads[i] := k;
        i := i+1;
        fi;
        k := k+1;
    od;

    # now the function which acts on the coboundaries
    ln1  := Length(ns);
    ln2  := Length(u);

    op := function( v, x )
        local        w,  i;

        # add the coboundary <v> to <u>
        w := ShallowCopy(u);
        for i  in [ 1 .. ln2 ]  do
            w[i] := w[i] * PcElementByExponentsNC(ns, v{[(i-1)*ln1+1..i*ln1]});
        od;

        # operate with <x> on <w> and normalize modulo <u2>
        w := PCGS_NORMALIZER_OPE( data, w, x );

        # convert back into a vector
        v := [];
        for i  in [ 1 .. ln2 ]  do
            Append( v, ExponentsOfPcElement( ns, ui[i]*w[i] ) );
        od;
        v := v * One(gf);
        v := ImmutableVector(gf, v);
        for i  in [ 1 .. Length(heads) ]  do
          v := v - v[heads[i]] * b[i];
        od;
        return Immutable(v);
    end;

    # compute the blockstabilizer
    Info( InfoPcNormalizer, 4, "computing blockstabilizer" );
    stab := PCGS_STABILIZER( NumeratorOfModuloPcgs(pcgs) mod us,
                             b[1] * Zero(gf),
                             op );

    # compute and correct the blockstabilizer
    Info( InfoPcNormalizer, 4, "correcting blockstabilizer" );
    nb := List( nb, x -> x ^ -1 );
    for i  in [ 1 .. Length(stab) ]  do
        s := PCGS_NORMALIZER_OPE( data, u, stab[i] );
        v := [];
        for j  in [ 1 .. ln2 ]  do
            Append( v, ExponentsOfPcElement( ns, ui[j]*s[j] ) );
        od;
        for j  in [ 1 .. Length(heads) ]  do
            if v[heads[j] ] <> 0  then
                stab[i] := stab[i] * ( nb[j]^v[heads[j]] );
            fi;
        od;
    od;

    # return sum of <L>, <C> and <U1>
    return InducedPcgsByGeneratorsNC( home, Concatenation( stab, c, u1 ) )
       mod DenominatorOfModuloPcgs(pcgs);

end );


#############################################################################
##
#F  PcGroup_NormalizerWrtHomePcgs( <u>, <f1>, <f2>, <f3>, <f4> )
##
##  compute the normalizer of <u>  in its home pcgs,  the flags <f1> to  <f4>
##  can be used to fine tune the normalizer computation:
##
##  <f1>    if 'true', intersections with the same prime than  the module are
##          computed  using    one  cobounds.   Otherwise an  ordinary  orbit
##          stabilizer algorithm is used.
##
##  <f2>    if 'true', intersections with different prime than the module are
##          computed using one cobounds.  Otherwise the method of computation
##          depends on the flag <f3>.
##
##  <f3>    if 'true' and <f2> is  'false', then intersections with different
##          prime than  the  module  are computed  using Glasby's  algorithm.
##          Otherwise a ordinary orbit stabilizer algorithm is used.
##
##  <f4>    if 'true', the first  intersection  is computed   using    linear
##          operations.  Otherwise a ordinary orbit  stabilizer  algorithm is
##          used.
##
DeclareGlobalName("PcGroup_NormalizerWrtHomePcgs");
BindGlobal( "PcGroup_NormalizerWrtHomePcgs", function( u, f1, f2, f3, f4 )

    local   g,              # home pcgs of <pcgs>
            e,  r,          # elementary abelian series of <G> and its length
            ue,             # factor pcgs <pcgs><e>[i] mod <e>[i]
            uk,  uj,  ui_1, # intersections of <pcgs> with <e>[x]
            s,  si_1,       # stabilizer and its intersection with <e>[i-1]
            ei_1,           # <e>[i-1] mod <e>[i]
            pj,  pi_1,      # primes of <e>[j] and <e>[i-1]
            st,             # used for checking the algorithm
            i,  j,  k,      # loops
            pcgs,           # pcgs of <u>
            id,             # identity element
            tmp;            # temporary

    # get the parent pcgs and the elementary abelian series
    g  := HomePcgs(u);
    id := OneOfPcgs(g);
    e  := ElementaryAbelianSubseries(g);
    if e = fail  then
        Info( InfoPcNormalizer, 1, "Computing el.ab. PCGS" );
        s := SpecialPcgs(g);
        k := NaturalIsomorphismByPcgs( GroupOfPcgs(g), s );
        if ElementaryAbelianSubseries(Pcgs(Image(k))) = fail  then
            Error( "corrupted special pcgs" );
        fi;
        tmp := InducedPcgsByGeneratorsNC( g, List(
                PcGroup_NormalizerWrtHomePcgs( Image(k,u), f1, f2, f3, f4 ),
                x -> PreImage( k, x ) ) );
        SetHomePcgs( tmp, g );
        return tmp;
    fi;
    r := Length(e);

    # get a canonical pcgs for <u>
    pcgs := CanonicalPcgsWrtHomePcgs(u);

    # If <r> = 2,  <g> is abelian, so we can return <g>
    if r = 2  then
        return g;
    fi;

    # compute the closure of <pcgs> and <e>[i]
    ue := [];
    for i  in [ 1 .. r ]  do
        ue[i] := SumPcgs( g, e[i], pcgs );
    od;

    # begin with <g>/<e>[2], in this factorgroup nothing is to be done
    s := e[1] mod e[2];
    Info( InfoPcNormalizer, 1, "skipping level 1 of ", r );
    Info( InfoPcNormalizer, 1, "skipping level 2 of ", r );

    # start with <g>/<e>[3] because <g>/<e>[2] is abelian
    for i  in [ 3 .. r ]  do

        # <s> = Normalizer( <G>/<E>[i-1], <pcgs> )
        #
        # The first step looks like ( U = <pcgs> )
        #
        #               S
        #                 \
        #                  \
        #           U        Ei-1
        #            \      /
        #             \    /
        #              Ui-1
        #                  \
        #                   \
        #                    Ei
        #
        # Now get  the complete preimage of <s>  in  <g>/<e>[i] and start the
        # whole computation for that factorgroup.

        s := NumeratorOfModuloPcgs(s) mod e[i];
        Info( InfoPcNormalizer, 1, "reached level ", i, " of ", r );
        Info( InfoPcNormalizer, 4, "normalizer:   ", AsList(s) );
        Info( InfoPcNormalizer, 4, "subgroup:     ", AsList(ue[i]) );
        Info( InfoPcNormalizer, 5, "modulo:       ", AsList(e[i]) );

        # keep the old stabilizer for an assert later
        st := s;

        # if <ue>[i] is trivial we can skip this step
        ei_1 := e[i-1] mod e[i];
        if Length(ue[i]) = Length(e[i])  then
            Info( InfoPcNormalizer, 2, "<ue>[", i, "] is trivial" );
            Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(ue[i])) );

        # if <e>[i-1] is a subgroup of <ue>[i] we can skip this step
        elif ForAll( ei_1, x -> SiftedPcElement(ue[i],x) = id )  then
            Info( InfoPcNormalizer, 2, "<e>[",i,"] > <ue>[",i-1,"]" );
            Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(ue[i])) );

        # now do some real work
        else

            # remember the prime of the current section for later
            pi_1 := RelativeOrderOfPcElement( g, ei_1[1] );

            # get the first section
            ui_1 := NormalIntersectionPcgs( g, e[i-1], ue[i] );

            # if the factor is trivial do nothing
            if Length(ui_1) = Length(e[i])  then
                Info( InfoPcNormalizer, 2,
                      "<ue>[",i,"] /\\ <e>[",i-1,"] is trivial" );

            # if <f4> is true, use linear operations
            elif f4  then
                Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", i-1,
                      "] using linear operation" );

                s := PCGS_NORMALIZER_LINEAR( g, s, ui_1, ei_1 );

            # otherwise use a normal stabilizer
            else
                Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", i-1,
                      "] using orbit" );
                s := PCGS_NORMALIZER( g, s, ui_1, e[i] );
            fi;

            # check the stabilizer
            Assert( 3, Stabilizer( GroupOfPcgs(st), GroupOfPcgs(ui_1),
                       function(U,g) return U^g;end)
                     = GroupOfPcgs(s) );

            # now <ui_1> must be stabilized by <s>
            st := s;
            Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(ui_1)) );

            # find <ue>[i]/\<E>[j] which is larger then <ue>[i]/\<E>[i-1]
            j  := i-2;
            uj := NormalIntersectionPcgs( g, e[j], ue[i] );
            k  := i-1;
            uk := ui_1;
            while 0 < j and Length(uj) = Length(ui_1)  do
                Info( InfoPcNormalizer, 2, "<ue>[",i,"] /\\ <e>[", j,
                      "] = <ue>[", i, "] /\\ e[", k, "]" );
                k  := j;
                uk := uj;
                j  := j - 1;
                if 0 < j  then
                    uj := NormalIntersectionPcgs( g, e[j], ue[i] );
                fi;
            od;

            # The next step for <s> = Normalizer( <uk> ) is
            #
            #       S
            #        \    Ej
            #         \  /  \
            #   U      **    \
            #    \    /  \    Ek
            #     \  /    \  /  \
            #      Uj      **    \
            #        \    /  \    Ei-1
            #         \  /    \  /
            #          Uk      Si-1
            #            \     /
            #             \   /
            #              Ui-1
            #                \
            #                 \
            #                  Ei
            #
            # If <j> = 0 or  <s> and <u> have  the same <E>[i-1] intersection
            # we are finished with this step.

            si_1 := NormalIntersectionPcgs(
                        g,
                        e[i-1],
                        NumeratorOfModuloPcgs(s) )
                    mod e[i];

            while 0<j and not ForAll(si_1,x ->SiftedPcElement(ui_1,x)=id)  do

                # this only works for subseries <e>
                tmp := First( e[j], x -> not x in e[j+1] );
                pj  := RelativeOrderOfPcElement( g, tmp );

                # cobounds
                if ( pj = pi_1 and f1 ) or ( pj <> pi_1 and f2 )  then
                    Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", j,
                          "] using cobounds" );
                    s := PCGS_NORMALIZER_COBOUNDS( g, s, si_1, uj, uk );

                # glasby
                elif pj <> pi_1 and f3  then
                    Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", j,
                          "] using Glasby" );
                    s := PCGS_NORMALIZER_GLASBY( g, s, si_1, uj, uk );

                # orbit
                else
                    Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", j,
                          "] using orbit" );
                    s := PCGS_NORMALIZER( g, s, uj, uk );
                fi;

                # check the stabilizer
                Assert( 3, Stabilizer( GroupOfPcgs(st), GroupOfPcgs(uj),
                         function(U,g) return U^g;end)
                         = GroupOfPcgs(s) );

                # now <uj> must be stabilized by <s>
                st := s;
                Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(uj)) );

                # find the next non-trivial intersection
                k  := j;
                uk := uj;
                while 0 < j and Length(uj) = Length(uk)  do
                    if k <> j  then
                        Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[",
                              j, "] = <ue>[", i, "] /\\ e[", k, "]" );
                    fi;

                    k  := j;
                    uk := uj;
                    j  := j - 1;
                    if 0 < j  then
                        uj := NormalIntersectionPcgs( g, e[j], ue[i] );
                    fi;
                od;

                # Now we know our new <S>, if <j>-1 is still nonzero, compute
                # the intersection in order to see, if we are finished.

                if 0 < j  then
                    si_1 := NormalIntersectionPcgs(
                                g,
                                e[i-1],
                                NumeratorOfModuloPcgs(s) )
                            mod e[i];
                fi;

            od;
        fi;
    od;
    Assert( 1, IsNormal( GroupOfPcgs(s), u ) );

    if Length(s) = Length(pcgs)  then
        return pcgs;
    else
        tmp := InducedPcgsByPcSequence( g, List( s, x -> x ) );
        SetHomePcgs( tmp, g );
        return tmp;
    fi;

end );


#############################################################################
##
#M  NormalizerInHomePcgs( <pc-group> )
##
InstallMethod( NormalizerInHomePcgs,
    "for group with home pcgs",
    true,
    [ IsGroup and HasHomePcgs ],
    0,

function( u )
    if not IsPrimeOrdersPcgs(HomePcgs(u))  then
        TryNextMethod();
    fi;
    return PcGroup_NormalizerWrtHomePcgs( u, true, false, true, true );
end );


#############################################################################
##
#M  Normalizer( <pc-group>, <pc-group> )
##
InstallMethod( NormalizerOp, "for groups with home pcgs", IsIdenticalObj,
    [ IsGroup and HasHomePcgs and CanComputeFittingFree, IsGroup and HasHomePcgs ],
    1, #better than the next method
function( g, u )
    local   home,  norm,  pcgs;

    # for small groups use direct calculation
    if Size(g) < 1000 or (Size(g)<100000 and Size(g)/Size(u)<500) then
      TryNextMethod();
    fi;
    home := HomePcgs(g);
    if home <> HomePcgs(u)  then
        TryNextMethod();
    fi;

    # first compute the normalizer with respect to the home
    pcgs := NormalizerInHomePcgs(u);
    norm := SubgroupByPcgs( g, pcgs );

    # then the intersection
    norm := Intersection( g, norm );

    # and return
    return norm;

end );

InstallMethod( NormalizerOp, "slightly better orbit algorithm for pc groups",
  IsIdenticalObj, [ IsGroup and HasHomePcgs, IsGroup and HasHomePcgs ], 0,
function( G, U )
local N,h,opfun;
  h:=HomePcgs(G);
  opfun:=function(p,g)
    return CanonicalPcgs(InducedPcgsByGeneratorsNC(h,List(p,i->i^g)));
  end;

  N:=Stabilizer(G,CanonicalPcgs(InducedPcgs(h,U)),opfun);
  return N;
end);
