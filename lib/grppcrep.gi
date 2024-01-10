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
#F MappedVector( <exp>, <list> ). . . . . . . . . . . . . . . . . . . . local
##
# FIXME: the polycyclic package overwrites MappedVector with an identical
# implementation. Also several packages use MappedVector. This means we can't
# make `MappedVector` read-only, nor can we rename it (and then make it
# read-only). To resolve this, various packages (at least polycyclic) need
# updates.
MappedVector := function( exp, list )
    local elm, i;

    if Length( list ) = 0 then
        Error("cannot compute this");
    fi;
    if IsFFE( exp[1] ) then exp := IntVecFFE(exp); fi;
    elm := list[1]^exp[1];
    for i in [2..Length(list)] do
        elm := elm * list[i]^exp[i];
    od;
    return elm;
end;

#############################################################################
##
#F BlownUpMatrix( <B>, <mat> ) . . . . . . . . . . blow up by field extension
##
BindGlobal( "BlownUpMatrix", function ( B, mat )
    local vec, d, tmp, big, i, j, k, new, l;

    # blow up each entry of mat
    vec := BasisVectors( B );
    d   := Length( vec );
    tmp := [];
    big := [];
    for i in [ 1 .. Length( mat ) ] do
        big[i] := [];
        for j in [ 1 .. Length( mat ) ] do
            for k in [ 1 .. d ] do
                tmp[k] := Coefficients( B, mat[i][j] * vec[k] );
            od;
            big[i][j] := TransposedMat( tmp );
        od;
    od;

    # translate it into big matrix
    new := List( [1..Length(big)*d], x -> [] );
    for i in [1..Length(big)] do
        for j in [1..Length(big)] do
            for k in [1..d] do
                for l in [1..d] do
                    new[(i-1)*d + k][(j-1)*d + l] := big[i][j][k][l];
                od;
            od;
        od;
    od;
    return new;
end );

#############################################################################
##
#F BlownUpModule( <modu>, <E>, <F> ) . . . . . . . blow up by field extension
##
InstallGlobalFunction( BlownUpModule, function( modu, E, F )
    local B, mats;

    # the trivial case
    B := AsField( F, E );
    if Dimension( B ) = 1 then return modu; fi;
    B := Basis( B );

    #mats := List( modu.generators, x -> TransposedMat(BlownUpMat(B, x)));
    mats:=List(modu.generators,x ->ImmutableMatrix(F,BlownUpMatrix(B,x)));
    return GModuleByMats( mats, F );
end );

#############################################################################
##
#F ConjugatedModule( <pcgsN>, <g>, <modu> ) . . . . . . . . conjugated module
##
InstallGlobalFunction( ConjugatedModule, function( pcgsN, g, modu )
local mats, i, exp;

  mats := List(modu.generators, ReturnFalse );
  for i in [1..Length(mats)] do
    exp := ExponentsOfPcElement( pcgsN, pcgsN[i]^g );
    mats[i] := ImmutableMatrix(modu.field,MappedVector(exp,modu.generators));
  od;
  return GModuleByMats( mats, modu.field );
end );

#############################################################################
##
#F FpOfModules( <pcgs>, <list of reps> ) . . . . . . . . distinguish by chars
##
InstallGlobalFunction( FpOfModules, function( pcgs, modus )
    local words, traces, trset, word, exp, new, i, newset, n;

    n      := Length( modus );
    words  := ShallowCopy( AsList( pcgs ) );
    traces := List( modus, x -> Concatenation( [x.dimension],
                                List(x.generators, TraceMat)));
    trset  := Set( traces );

    # iterate computation of elements
    while Length( trset ) < Length( modus ) do
        word := Random( GroupOfPcgs( pcgs ) );
        if word <> OneOfPcgs( pcgs ) and not word in words then
            exp := ExponentsOfPcElement( pcgs, word );
            new := List( modus, x->TraceMat(MappedVector(exp, x.generators)));
            for i in [1..n] do
                new[i] := Concatenation( traces[i], [new[i]] );
            od;
            newset := Set( new );
            if Length( newset ) > Length( trset ) then
                Add( words, word );
                traces := ShallowCopy( new );
                trset  := ShallowCopy( newset );
            fi;
        fi;
    od;

    words := List( words, x -> ExponentsOfPcElement( pcgs, x ) );
    return rec( words  := words,
                traces := traces );
end );

#############################################################################
##
#F EquivalenceType( <fp>, <modu> ) . . . . . . . . . . use chars to find type
##
InstallGlobalFunction( EquivalenceType, function( fp, modu )
    local trace;

    trace := List(fp.words, x -> TraceMat(MappedVector(x, modu.generators)));
    trace := Concatenation( [modu.dimension], trace );
    return Position( fp.traces, trace );
end );

#############################################################################
##
#F IsEquivalentByFp( <fp>, <x>, <y> ) . . . . . . . equivalence type by chars
##
InstallGlobalFunction( IsEquivalentByFp, function( fp, x, y )

    # get the easy cases first
    if x.dimension <> y.dimension then
        return false;
    elif Dimension( x.field ) <> Dimension( y.field ) then
        return false;
    fi;

    # now it remains to check this really
    return EquivalenceType( fp, x ) = EquivalenceType( fp, y );
end );

#############################################################################
##
#F GaloisConjugates( <modu>, <F> ) . . . . . . . . . . .apply frobenius autom
##
InstallGlobalFunction( GaloisConjugates, function( modu, F )
    local d, p, conj, k, mats, r, i, new;

    # set up
    d := Dimension( F );
    p := Characteristic( F );
    conj := [ modu ];

    # conjugate
    for k in [1..d-1] do
      mats := List( modu.generators, ReturnFalse );
      r    := RemInt( p^k, p^d-1 );
      for i in [1..Length(mats)] do
        mats[i]:=ImmutableMatrix(F,List(modu.generators[i],x->List(x,y->y^r)));
      od;
      new := GModuleByMats( mats, F );
      Add( conj, new );
    od;
    return conj;
end );

#############################################################################
##
#F TrivialModule( <n>, <F> ) . . . . . . . . . . . trivial module with n gens
##
InstallGlobalFunction( TrivialModule, function( n, F )
local r;
    r:=rec( field := F,
      dimension := 1,
      generators := ListWithIdenticalEntries( n,
                        Immutable( IdentityMat( 1, F ) ) ),
      isMTXModule := true,
      basis := [[One(F)]] );
  if IsFinite(F) then r.IsOverFiniteField:=true;fi;
  return r;
end );

#############################################################################
##
#F InducedModule( <pcgsS>, <modu> ) . . . . . . . . . . . . . .induced module
##
InstallGlobalFunction( InducedModule, function( pcgsS, modu )
    local m, d, h, r, mat, i, j, mats, zero, id, exp, g;

    g := pcgsS[1];
    m := Length( pcgsS );
    d := modu.dimension;
    r := RelativeOrderOfPcElement( pcgsS, g );
    zero := Immutable( NullMat( d, d, modu.field ) );
    id   := Immutable( IdentityMat( d, modu.field ) );

    # the first matrix
    mat := List( [1..r], x -> List( [1..r], y -> zero ) );
    exp := ExponentsOfPcElement( pcgsS, g^r, [2..m] );
    mat[1][r] := MappedVector( exp, modu.generators );
    for j in [2..r] do
        mat[j][j-1] := id;
    od;
    mats := [FlatBlockMat( mat )];

    # the remaining ones
    for i in [2..m] do
        mat := List( [1..r], x -> List( [1..r], y -> zero ) );
        for j in [1..r] do
            h := pcgsS[i]^(g^(j-1));
            exp := ExponentsOfPcElement( pcgsS, h, [2..m] );
            mat[j][j] := MappedVector( exp, modu.generators );
        od;
        Add( mats, ImmutableMatrix(modu.field,FlatBlockMat( mat ) ));
    od;

    return GModuleByMats( mats, modu.field );
end );

#############################################################################
##
#F InducedModuleByFieldReduction( <pcgsS>, <modu>, <conj>, <gal>, <s> ) . . .
##
## The conjugated module is also galoisconjugate to modu. Thus we may use
## a field extension to induce.
##
InstallGlobalFunction( InducedModuleByFieldReduction,
    function( pcgsS, modu, conj, gal, s )
    local r, E, dE, p, l, K, EK, base, vecs, matsN, iso, coeffs, id, ch,
          matg, mats, newm, exp, e, k, q, c, m, gmat;

    # reduce field and increase dimension
    r := RelativeOrderOfPcElement( pcgsS, pcgsS[1] );
    E := modu.field;
    dE := Dimension( E );
    p := Characteristic( modu.field );
    l := QuoInt( dE, r );
    K := GF( p^l );
    EK := AsField( K, E );
    base := Basis( EK );
    vecs := BasisVectors( base );

    # blow up matrices in N
    matsN := List( modu.generators, x -> BlownUpMatrix( base, x ) );

    # compute isomorphism
    MTX.IsIrreducible( conj );
    iso := MTX.Isomorphism( conj, gal )^-1;

    # compute inverse galois automorphism and corresponding matrix
    exp  := ExponentsOfPcElement( pcgsS, pcgsS[1]^r, [2..Length(pcgsS)] );
    gmat := MappedVector( exp, modu.generators );
    e := iso * gmat^-1;
    for k in [1..r-1] do
        q := RemInt( p^((s-1)*k), p^dE - 1);
        e := List( iso, x -> List( x, y -> y^q ) ) * e;
    od;
    e := e[1][1];
    c := PrimitiveRoot( E ) ^ QuoInt( LogFFE( e, PrimitiveRoot(E) ),
                         QuoInt( p^dE - 1, p^l - 1 ) );
    # correct iso
    iso := c^-1 * iso;

    # compute base change
    m := p^(1-s) mod (p^dE - 1);
    coeffs := List( [1..r], j -> Coefficients( base, vecs[j]^m ) );
    id := IdentityMat( modu.dimension, K );
    ch := KroneckerProduct( id, TransposedMat( coeffs ) );

    # construct matrix
    matg := ch * BlownUpMatrix( base, iso );

    # construct module and return
    mats := List(Concatenation( [matg], matsN ),i->ImmutableMatrix(K,i));
    newm := GModuleByMats( mats, K );
    return newm;
end );

#############################################################################
##
#F ExtensionsOfModule( <pcgsS>, <modu>, <conj>, <dim> ) . . .extended modules
##
InstallGlobalFunction( ExtensionsOfModule, function( pcgsS, modu, conj, dim )
    local r, new, E, p, dE, exp, gmat, iso, e, c, mats, newm, f, d, b,
          L, j, w, g, k;

    # set up
    g    := pcgsS[1];
    r    := RelativeOrderOfPcElement( pcgsS, g );
    new  := [];

    # set up fields
    E  := modu.field;
    p  := Characteristic( E );
    dE := Dimension( E );

    # compute matrix to g^r in N
    exp  := ExponentsOfPcElement( pcgsS, g^r, [2..Length(pcgsS)] );
    gmat := MappedVector( exp, modu.generators );

    # we know that conj and modu are equivalent - compute e
    MTX.IsIrreducible( conj );
    iso := MTX.Isomorphism( modu, conj );
    e   := (gmat * iso^(-r));
    e   := e[1][1];

    if (p^dE - 1) mod r <> 0 then

      # compute rth root c of e in E
      c := e ^ (r^(-1) mod (p^dE - 1));

      # this yields a unique extension of modu over E
      mats:=List(Concatenation([c*iso],modu.generators),
                 i->ImmutableMatrix(E,i));
      newm := GModuleByMats( mats, E );
      Add( new, newm );

      # if we have roots of unity in an extension of E
      if r <> p then
          f := Indeterminate( E );
          f := Sum( List( [1..r], x -> f^(x-1) ) );
          f := Factors( PolynomialRing( E ), f );
          d := DegreeOfLaurentPolynomial( f[1] );
          b := dE * d;

          # construct new field of dimension b
          if dim = 0 or b * modu.dimension <= dim then
            L := GF(p^b);
            for j in [1..Length(f)] do
              w := PrimitiveRoot( L ) ^ ((p^b - 1)/r);
              while Value( f[j], w ) <> Zero( E ) do
                w := w * PrimitiveRoot( L )^ ((p^b - 1)/r);
              od;
              mats:=List(Concatenation([w*c*iso],modu.generators),
                i->ImmutableMatrix(L,i));
              newm := GModuleByMats( mats, L );
              Add( new, newm );
            od;
          fi;
      fi;
      return new;
    fi;

    # now we know that p^dE - 1 mod r = 0
    k := 0;
    while (p^dE - 1) mod r^(k+1) = 0 do
        k := k + 1;
    od;

    # if we have r distinct rth roots of e in E
    if Order( e ) mod r^k <> 0 then
        c := PrimitiveRoot( E ) ^ QuoInt( LogFFE( e, PrimitiveRoot(E) ), r );
        for j in [1..r] do
            mats:=List(Concatenation([c*iso],modu.generators),
                 i->ImmutableMatrix(E,i));
            newm := GModuleByMats( mats, E );
            Add( new, newm );
            c := c * PrimitiveRoot( E ) ^ QuoInt( p^dE-1, r );
        od;
        return new;
    fi;

    # if we have we do not have any root in E, go over to extension
    # construct new field of dimension b
    b := dE * r;
    if dim = 0 or b * modu.dimension <= dim then
        L := GF( p^b );
        c := PrimitiveRoot( L ) ^ QuoInt( LogFFE( e, PrimitiveRoot( L ) ), r );
        mats:=List(Concatenation([c*iso],modu.generators),
                   i->ImmutableMatrix(L,i));
        newm := GModuleByMats( mats, L );
        Add( new, newm );
    fi;
    return new;
end );

#############################################################################
##
#F InitAbsAndIrredModules( <r>, <F>, <dim> )  . . . . . . . . . . . . . local
##
InstallGlobalFunction( InitAbsAndIrredModules, function( r, F, dim )
    local new, mats, modu, f, l, E, w, j, d, p, b, irr, i;

    # set up
    new := [];
    p   := Characteristic( F );
    d   := Dimension(F);

    if ( (p^d-1) mod r ) <> 0 then

        # construct a 1-dimensional module
        mats := [ ImmutableMatrix(F, IdentityMat( 1, F ) ) ];
        modu := GModuleByMats( mats, F );
        Add( new, modu );

        if r <> p then
            f := Indeterminate( F );
            f := Sum( List([1..r], x -> f^(x-1) ) );
            f := Factors( PolynomialRing( F ), f );
            l := DegreeOfLaurentPolynomial( f[1] );
            b := l * d;

            # construct l-dimensional module
            if dim = 0 or b <= dim then
                E := GF( p^b );
                for j in [ 1..Length( f ) ] do
                    w := PrimitiveRoot(E)^QuoInt( p^b-1, r );
                    while Value( f[j], w ) <> Zero( F ) do
                        w := w * PrimitiveRoot(E)^QuoInt( p^b-1, r );
                    od;
                    modu := GModuleByMats( [ImmutableMatrix(E,[[w]])], E );
                    Add( new, modu );
                od;
            fi;
        fi;
    else

        # construct 1-dimensional module
        w := PrimitiveRoot( F )^QuoInt( p^d - 1, r );
        for j in [ 1..r ] do
            mats := [ ImmutableMatrix(F,[[w]]) ];
            modu := GModuleByMats( mats, F );
            Add( new, modu );
            w := w * PrimitiveRoot( F )^QuoInt( p^d - 1, r );
        od;
    fi;

    # blow modules up
    for i in [1..Length(new)] do
        irr := BlownUpModule( new[i], new[i].field, F );
        new[i] := rec( irred := irr,
                       absirr := new[i] );
    od;

    # return
    return new;
end );

#############################################################################
##
#F LiftAbsAndIrredModules( <pcgsS>, <pcgsN>, <modrec>, <dim> ). . . . . local
##
InstallGlobalFunction( LiftAbsAndIrredModules,
    function( pcgsS, pcgsN, modrec, dim )
    local todo, fp, new, i, modu, E, conj, type, s, gal, r, un, j,
          g, galfp, small, sconj, irred, absirr, n, F, irr, dF;

    # split modules into parts
    irred  := List( modrec, x -> x.irred );
    absirr := List( modrec, x -> x.absirr );
    n      := Length( modrec );
    F      := irred[1].field;
    dF     := Dimension( F );

    # set up
    todo := [1..n];
    fp   := FpOfModules( pcgsN, irred );
    g    := pcgsS[1];
    r    := RelativeOrderOfPcElement( pcgsS, g );
    new  := [];

    # until we have all modules lifted
    while Length( todo ) > 0 do

        # choose a module
        i := todo[1];
        todo := todo{[2..Length(todo)]};
        modu  := absirr[i];
        E     := modu.field;
        small := irred[i];

        # compute its conjugate
        sconj := ConjugatedModule( pcgsN, g, small );
        type  := EquivalenceType( fp, sconj );

        # if the are equivalent
        if type <> i then

            # absirr: dimension  d := d * r -- field e := e
            # irr   : dimension  d := d * r
            if dim = 0 or r * dF * small.dimension <= dim then
                Add( new, InducedModule( pcgsS, modu ) );
            fi;

            # filter out the modules also inducing to the new one
            un := [type];
            for j in [1..r-2] do
                sconj := ConjugatedModule( pcgsN, g, sconj );
                type := EquivalenceType( fp, sconj );
                AddSet( un, type );
            od;
            todo := Difference( todo, un );
        else

            # compute galois conjugates and try to find equivalent one
            conj  := ConjugatedModule( pcgsN, g, modu );
            gal   := GaloisConjugates( modu, AsField( F, E ) );
            galfp := FpOfModules( pcgsN, gal );
            s     := EquivalenceType( galfp, conj );

            if s = 1 then

                # absirr: dimension: d := d -- field e := e      (1 or r mod)
                #                                    e := e * l  (f mod)
                #                                    e := e * r  (1 mod)
                Append( new, ExtensionsOfModule( pcgsS, modu, conj, dim ) );
            else

                # absirr: dimension d := d * r -- field e := e / r
                # irr   : dimension d := d
                Add( new, InducedModuleByFieldReduction(
                          pcgsS, modu, conj, gal[s], s));
            fi;
        fi;
    od;

    # now it remains to blow the modules up
    for i in [1..Length(new)] do
        E := new[i].field;
        irr := BlownUpModule( new[i], E, F );
        new[i] := rec( irred := irr,
                       absirr := new[i] );
    od;

    # return
    return new;
end );

#############################################################################
##
#F AbsAndIrredModules( <G>, <F>, <dim> ) . . . . . . . . . . . . . . . .local
##
InstallGlobalFunction( AbsAndIrredModules, function( G, F, dim )
    local pcgs, m, modrec, i, pcgsS, pcgsN, r;

    # check
    if dim < 0 then Error("dimension limit must be non-negative"); fi;
    if dim > 0 and Dimension( F ) > dim then return [,[]]; fi;

    # set up
    pcgs  := Pcgs( G );
    m     := Length( pcgs );

    if m = 0 and (dim = 0 or Dimension( F ) <= dim) then
        return [rec( irred  := TrivialModule( 0, F ),
                     absirr := TrivialModule( 0, F ))];
    elif m = 0 then return [pcgs,[]]; fi;

    # the first step is separated - too many problems with empty lists
    r      := RelativeOrderOfPcElement( pcgs, pcgs[m] );
    modrec := InitAbsAndIrredModules( r, F, dim );

    # step up pc series
    for i in Reversed( [1..m-1] ) do
        pcgsS := InducedPcgsByPcSequence( pcgs, pcgs{[i..m]} );
        pcgsN := InducedPcgsByPcSequence( pcgs, pcgs{[i+1..m]} );
        modrec := LiftAbsAndIrredModules( pcgsS, pcgsN, modrec, dim );
    od;

    # return
    return [pcgs,modrec];
end );

#############################################################################
##
#M AbsolutIrreducibleModules( <G>, <F>, <dim> ). . . . . . .up to equivalence
##
InstallMethod( AbsolutIrreducibleModules,
    "method for group with pcgs and finite prime field",
    true,
    [ IsGroup and CanEasilyComputePcgs, IsField and IsFinite and IsPrimeField, IsInt ],
    0,

function( G, F, dim )
    local modus;
    modus := AbsAndIrredModules( G, F, dim );
    return [ modus[1],
             Filtered( List( modus[2], x -> x.absirr ),
                       x -> IsPrimeField( x.field ) ) ];
end );

#############################################################################
##
#M IrreducibleModules( <G>, <F>, <dim> ) . . . . . . . . . .up to equivalence
##
## <dim> is the limit of Dim( F ) * Dim( M ) for the modules M
##
InstallMethod( IrreducibleModules,
    "generic method for groups with pcgs",
    true,
    [ IsGroup and CanEasilyComputePcgs, IsField and IsFinite and IsPrimeField, IsInt ],
    0,

function( G, F, dim )
    local modus, i, tmp,gens;
    modus := AbsAndIrredModules( G, F, dim );
    gens:=modus[1];
    modus:=modus[2];
    for i in [1..Length(modus)] do
        tmp := modus[i].irred;
        tmp.absolutelyIrreducible := modus[i].absirr;
        modus[i] := tmp;
    od;
    return [gens,modus];
end );
