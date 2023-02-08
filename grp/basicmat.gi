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
##  This file  contains the methods for the  construction of the basic matrix
##  group types.
##


#############################################################################
##
#M  CyclicGroupCons( <IsMatrixGroup>, <field>, <n> )
##
InstallOtherMethod( CyclicGroupCons,
    "matrix group for given field",
    true,
    [ IsMatrixGroup and IsFinite and IsCyclic,
      IsField,
      IsInt and IsPosRat ],
    0,

function( filter, fld, n )
    local   o,  m,  i, g;

    o := One(fld);
    m := NullMat( n, n, fld );
    for i  in [ 1 .. n-1 ]  do
        m[i,i+1] := o;
    od;
    m[n,1] := o;
    m :=  [ ImmutableMatrix(fld,m,true) ];
    g := GroupByGenerators( m );
    SetIsCyclic (g, true);
    SetMinimalGeneratingSet (g, m);
    SetSize( g, n );
    return g;

end );


#############################################################################
##
#M  CyclicGroupCons( <IsMatrixGroup>, <n> )
##
InstallMethod( CyclicGroupCons,
    "matrix group for default field",
    true,
    [ IsMatrixGroup and IsFinite and IsCyclic,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   m,  i;

    m := NullMat( n, n, Rationals );
    for i  in [ 1 .. n-1 ]  do
        m[i,i+1] := 1;
    od;
    m[n,1] := 1;
    m := GroupByGenerators( [ ImmutableMatrix(Rationals,m,true) ] );
    SetSize( m, n );
    return m;

end );

#############################################################################
##
#M  DicyclicGroupCons( <IsMatrixGroup>, <n> )
##
InstallMethod( DicyclicGroupCons,
    "matrix group for default field",
    true,
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat ],
    0,
function( filter, n )
  return DicyclicGroup( filter, Rationals, n );
end );

#############################################################################
##
#M  DicyclicGroupCons( <IsMatrixGroup>, <field>, <n> )
##
InstallOtherMethod( DicyclicGroupCons,
    "matrix group for given field",
    true,
    [ IsMatrixGroup and IsFinite,
      IsField,
      IsInt and IsPosRat ],
    0,

function( filter, fld, n )
  local bas, grp, cyc, one;
  if 0 <> n mod 4 then TryNextMethod(); fi;
  if n = 4 then return CyclicGroup( filter, fld, n ); fi;
  if Characteristic( fld ) = 0 and IsAbelianNumberField( fld )
  then
    cyc := E( n / 2 );
    bas := CanonicalBasis( Field( fld, [ cyc ]  ) );
    one := 1;
  elif Characteristic( fld ) = 0 or (0 = n mod Characteristic( fld ))
  then # XXX: regular rep is not minimal
    grp := DicyclicGroup( IsPermGroup, n );
    grp := Group( List( GeneratorsOfGroup( grp ), prm -> PermutationMat( prm, NrMovedPoints( grp ), fld ) ) );
    SetSize( grp, n );
    return grp;
  elif IsFFECollection( fld )
  then
    # XXX: If OrderMod( Size( fld ), n/2 ) is large, then this asks GAP
    # XXX: to compute a large conway polynomial, rather than just using
    # XXX: a companion polynomial directly.
    bas := CanonicalBasis( GF( Size( fld ), OrderMod( Size( fld ), n/2 ) ) );
    cyc := Z( Size( Field( bas ) ) )^( ( Size( Field( bas ) ) - 1 ) / (n/2) );
    one := One( fld );
  else
    bas := CanonicalBasis( GF( Characteristic( fld ), OrderMod( Characteristic( fld ), n/2 ) ) );
    cyc := Z( Size( Field( bas ) ) )^( ( Size( Field( bas ) ) - 1 ) / (n/2) );
    one := One( Field( bas ) );
  fi;
  grp := Group( List( [[[0,1],[-1,0]],[[cyc,0],[0,1/cyc]]]*one,
    mat -> ImmutableMatrix( fld, BlownUpMat( bas, mat )*One(fld), true ) ) );
  SetSize( grp, n );
  return grp;
end);

#############################################################################
##
#M  GeneralLinearGroupCons( <IsMatrixGroup>, <d>, <F> )
##
InstallMethod( GeneralLinearGroupCons,
    "matrix group for dimension and finite field",
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat,
      IsField and IsFinite ],
function( filter, n, f )
    local   q,  z,  o,  mat1,  mat2,  i,  g;

    q:= Size( f );

    # small cases
    if q = 2 and 1 < n  then
#T why 1 < n?
        return SL( n, 2 );
    fi;

    # construct the generators
    z := PrimitiveRoot( f );
    o := One( f );

    mat1 := IdentityMat( n, f );
    mat1[1,1] := z;
    mat2 := List( Zero(o) * mat1, ShallowCopy );
    mat2[1,1] := -o;
    mat2[1,n] := o;
    for i  in [ 2 .. n ]  do mat2[i,i-1]:= -o;  od;

    mat1 := ImmutableMatrix( f, mat1,true );
    mat2 := ImmutableMatrix( f, mat2,true );

    g := GroupByGenerators( [ mat1, mat2 ] );
    SetName( g, Concatenation("GL(",String(n),",",String(q),")") );
    SetDimensionOfMatrixGroup( g, n );
    SetFieldOfMatrixGroup( g, f );
    SetIsNaturalGL( g, true );
    SetIsFinite(g,true);

    if n<50 or n+q<500 then
      Size(g);
    fi;

    # Return the group.
    return g;
end );

#############################################################################
##
#M  SpecialLinearGroupCons( <IsMatrixGroup>, <d>, <q> )
##
InstallMethod( SpecialLinearGroupCons,
    "matrix group for dimension and finite field",
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat,
      IsField and IsFinite ],

function( filter, n, f )
    local   q,  g,  o,  z,  mat1,  mat2,  i,  size,  qi;

    q:= Size( f );

    # handle the trivial case first
    if n = 1 then
        g := GroupByGenerators( [ ImmutableMatrix( f, [[One(f)]],true ) ] );

    # now the general case
    else

        # construct the generators
        o := One(f);
        z := PrimitiveRoot(f);
        mat1 := IdentityMat( n, f );
        mat2 := List( Zero(o) * mat1, ShallowCopy );
        mat2[1,n] := o;
        for i  in [ 2 .. n ]  do mat2[i,i-1]:= -o;  od;

        if q = 2 or q = 3 then
            mat1[1,2] := o;
        else
            mat1[1,1] := z;
            mat1[2,2] := z^-1;
            mat2[1,1] := -o;
        fi;
        mat1 := ImmutableMatrix(f,mat1,true);
        mat2 := ImmutableMatrix(f,mat2,true);

        g := GroupByGenerators( [ mat1, mat2 ] );
    fi;

    # set name, dimension and field
    SetName( g, Concatenation("SL(",String(n),",",String(q),")") );
    SetDimensionOfMatrixGroup( g, n );
    SetFieldOfMatrixGroup( g, f );
    SetIsFinite( g, true );
    if q = 2  then
        SetIsNaturalGL( g, true );
    fi;
    SetIsNaturalSL( g, true );
    SetIsFinite(g,true);

    # add the size
    if n<50 or n+q<500 then
      Size(g);
    fi;

    # return the group
    return g;
end );


#############################################################################
##
#M  GeneralSemilinearGroupCons( IsMatrixGroup, <d>, <q> )
##
InstallMethod( GeneralSemilinearGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite, IsInt and IsPosRat, IsInt and IsPosRat ],
    function( filter, d, q )
    local p, f, field, B, gl, gens, frobact, frobmat, i, g;

    p:= Factors( Integers, q );
    f:= Length( p );
    if f = 1 then
      return GL( d, q );
    fi;
    p:= p[1];

    field:= GF(q);
    B:= Basis( field );
    gl:= GL( d, q );
    gens:= List( GeneratorsOfGroup( gl ), x -> BlownUpMat( B, x ) );

    frobact:= List( BasisVectors( B ), x -> Coefficients( B, x^p ) );
    frobmat:= NullMat( d*f, d*f, GF(p) );
    for i in [ 1 .. d ] do
      frobmat{ [ (i-1)*f+1 .. i*f ] }{ [ (i-1)*f+1 .. i*f ] }:= frobact;
    od;
    Add( gens, frobmat );

    g:= GroupWithGenerators( gens );
    SetName( g, Concatenation( "GammaL(",String(d),",",String(q),")" ) );
    SetDimensionOfMatrixGroup( g, d*f );
    SetFieldOfMatrixGroup( g, GF(p) );
    SetIsFinite( g, true );

    SetSize( g, f * Size( gl ) );

    return g;
    end );


#############################################################################
##
#M  SpecialSemilinearGroupCons( IsMatrixGroup, <d>, <q> )
##
InstallMethod( SpecialSemilinearGroupCons,
    "matrix group for dimension and finite field size",
    [ IsMatrixGroup and IsFinite, IsInt and IsPosRat, IsInt and IsPosRat ],
    function( filter, d, q )
    local p, f, field, B, sl, gens, frobact, frobmat, i, g;

    p:= Factors( Integers, q );
    f:= Length( p );
    if f = 1 then
      return SL( d, q );
    fi;
    p:= p[1];

    field:= GF(q);
    B:= Basis( field );
    sl:= SL( d, q );
    gens:= List( GeneratorsOfGroup( sl ), x -> BlownUpMat( B, x ) );

    frobact:= List( BasisVectors( B ), x -> Coefficients( B, x^p ) );
    frobmat:= NullMat( d*f, d*f, GF(p) );
    for i in [ 1 .. d ] do
      frobmat{ [ (i-1)*f+1 .. i*f ] }{ [ (i-1)*f+1 .. i*f ] }:= frobact;
    od;
    Add( gens, frobmat );

    g:= GroupWithGenerators( gens );
    SetName( g, Concatenation( "SigmaL(",String(d),",",String(q),")" ) );
    SetDimensionOfMatrixGroup( g, d*f );
    SetFieldOfMatrixGroup( g, GF(p) );
    SetIsFinite( g, true );

    SetSize( g, f * Size( sl ) );

    return g;
    end );


#############################################################################
##
#M  GeneralSemilinearGroupCons( IsPermGroup, <d>, <q> )
#M  SpecialSemilinearGroupCons( IsPermGroup, <d>, <q> )
##
PermConstructor( GeneralSemilinearGroupCons,
    [ IsPermGroup, IsPosInt, IsPosInt ],
    IsMatrixGroup and IsFinite );

PermConstructor( SpecialSemilinearGroupCons,
    [ IsPermGroup, IsPosInt, IsPosInt ],
    IsMatrixGroup and IsFinite );

##############################################################################
##
#M  SylowSubgroupOp( NaturalGL, p )
##
##  Use Weir and Carter-Fong's explicit generators for Sylow p-subgroups of
##  natural general linear groups.
##
CallFuncList( function()

# Avoid polluting the namespace with these functions of somewhat limited interest.
  local
    SylowSubgroupOfWreathProduct,
    MaximalUnipotentSubgroupOfNaturalGL,
    SylowSubgroupOfTorusOfNaturalGL,
    SylowSubgroupOfNaturalGL;

# Return a Sylow p-subgroup of Sym(k) wreath Sym(m)
SylowSubgroupOfWreathProduct := function( k, m, p )
  local wr, ss, sy;
  wr := WreathProduct( SymmetricGroup( k ), SymmetricGroup( m ) );
  ss := List( [1..m+1], i -> Image( Embedding( wr, i ), SylowSubgroup( Source( Embedding( wr, i ) ), p ) ) );
  sy := Subgroup( wr, Concatenation( List( ss, GeneratorsOfGroup ) ) );
  SetSize( sy, Size(ss[1])^m*Size(ss[m+1]) );
  Assert( 2, Size( sy ) = Size( Subgroup( wr, GeneratorsOfGroup( sy ) ) ) );
  Assert( 0, 0 <> ( Size(wr) / Size(sy) ) mod p and IsSubgroup( wr, sy ) );
  return sy;
end;

# The following function creates the subgroup generated by the positive simple
# roots (upper triangular matrices with 1s on the diagonal, and a single
# non-zero entry on the first super diagonal, the non-zero entries varying over
# a basis of GF(q) over GF(p)).
MaximalUnipotentSubgroupOfNaturalGL := function( gl )
  local n, q, o, z, u;
  n := DimensionOfMatrixGroup( gl );
  q := Size( DefaultFieldOfMatrixGroup( gl ) );
  if SizeGL( n, q ) <> Size( gl ) then
    q := Size( FieldOfMatrixGroup( gl ) );
  fi;
  if IsPosInt(q) then q := GF(q); fi;
  o := One(q);
  z := Zero(q);
  u := Subgroup( gl,
    Concatenation(
      List( [1..n-1], r ->
        List( Basis( q ), b ->
          ImmutableMatrix( q,
            List( [1..n], i ->
              List( [1..n], function(j)
                if i = r and j = r+1 then return b;
                elif i = j then return o;
                else return z;
                fi;
              end )
            ),
            true
          )
        )
      )
    )
  );
  SetSize( u, Size(q)^Binomial(n,2) );
  SetIsPGroup( u, true );
  SetPrimePGroup( u, Characteristic(q) );
  return u;
end;

# The Sylow p-subgroup of a direct product of cyclic groups is quite easy to
# compute.
SylowSubgroupOfTorusOfNaturalGL := function( gl, pi, p )
  local n, q, gfq, one, orbs, gens, sub;
  n := DimensionOfMatrixGroup( gl );
  q := Size( DefaultFieldOfMatrixGroup( gl ) );
  if SizeGL( n, q ) <> Size( gl ) then
    q := Size( FieldOfMatrixGroup( gl ) );
  fi;
  gfq := GF(q);
  one := IdentityMat( n, gfq );
  orbs := Cycles( pi, [1..n] );
  gens := List( orbs, function( orb )
    local k, mat;
    k := Size(orb);
    mat := MutableCopyMatrix( one );
    mat{orb}{orb} := CompanionMat( MinimalPolynomial( gfq, Z(q^k) ) )^( (q^k-1)/p^PadicValuation(q^k-1,p));
    return ImmutableMatrix( gfq, mat, true );
  end );
  sub := Subgroup( gl, gens );
  SetIsAbelian( sub, true );
  SetAbelianInvariants( sub, AbelianInvariantsOfList( List( orbs, orb -> p^PadicValuation(q^Size(orb)-1,p) ) ) );
  SetSize( sub, Product( AbelianInvariants( sub ) ) );
  return sub;
end;

# The main worker. In defining characteristic, return the maximal unipotent
# subgroup.  In cross-characteristic, take a Sylow p-subgroup of a
# as-split-possible maximal torus, and if the dimension is large enough, the
# Sylow p-subgroup of the part of the Weyl group normalizing it.
SylowSubgroupOfNaturalGL := function( gl, p )
  local n, q, syl, s, syl2, k, sylp, pi, prm, syl1;
  n := DimensionOfMatrixGroup( gl );
  q := Size( DefaultFieldOfMatrixGroup( gl ) );
  if SizeGL( n, q ) <> Size( gl ) then
    q := Size( FieldOfMatrixGroup( gl ) );
  fi;
  if p = SmallestRootInt( q ) then # unipotent sylow
    syl := MaximalUnipotentSubgroupOfNaturalGL( gl );
  elif p = 2 then # use Carter-Fong description
    s := PadicValuation( q-1, 2 );
    syl1 := Subgroup( GL( 1, q ), [ [ [ Z(q)^((q-1)/2^s) ] ] ] );
    if 1 = q mod 4 then
      s := PadicValuation( q-1, 2 );
      syl2 := Subgroup( GL( 2, q ), [
          [[ 0, 1 ], [ 1, 0 ]],
          [[ Z(q)^((q-1)/2^s), 0 ], [ 0, 1 ]],
          [[ 1, 0 ], [ 0, Z(q)^((q-1)/2^s) ]],
        ]*One(GF(q)) );
    else
      s := PadicValuation( q+1, 2 );
      syl2 := Subgroup( GL( 2, q ), [
          [[ 0, 1 ], [ -1, 0 ]],
          [[ 0, 1 ], [ 1, Z(q^2)^((q^2-1)/2^(s+1)) + Z(q^2)^(q*(q^2-1)/2^(s+1)) ]],
        ]*One(GF(q)) );
    fi;
    s := 0;
    pi := [];
    repeat
      k := PadicValuation( n - s, 2 );
      Add( pi, [s+1..s+2^k] );
      s := s+2^k;
    until n = s;
    syl := Subgroup( gl, Concatenation( List( pi, function( part )
      local one, prm;
      one := One(gl);
      if Size( part ) = 1
      then return List( GeneratorsOfGroup( syl1 ),
        function( x )
          local mat;
          mat := MutableCopyMatrix( one );
          mat{part}{part} := x ;
          return mat;
        end );
      fi;
      prm := SylowSubgroup( SymmetricGroup( Size( part ) / 2 ), 2 );
      return Concatenation(
        List( GeneratorsOfGroup( prm ), function( x )
          local mat;
          mat := MutableCopyMatrix( one );
          mat{part}{part} := KroneckerProduct( PermutationMat( x, Size( part )/2, GF( q ) ), One( syl2 ) );
          return mat;
        end ),
        List( GeneratorsOfGroup( syl2 ), function( x )
          local mat;
          mat := MutableCopyMatrix( one );
          mat{part{[1..2]}}{part{[1..2]}} := x;
          return mat;
        end ) );
      end ) ) );
  else
    k := OrderMod( q, p^(2/GcdInt(p-1,2)) );
    pi := PermList( List( [1..n], function(i) if i > Int(n/k)*k then return i; else return (i mod k) + 1 + k*Int((i-1)/k); fi; end ) );
    syl := SylowSubgroupOfTorusOfNaturalGL( gl, pi, p );
    if n >= p*k or ( p = 2 and k <= n ) then # non-abelian sylow
      prm := SylowSubgroupOfWreathProduct( k, Int(n/k), p );
      syl2 := Subgroup( gl, Concatenation( List( GeneratorsOfGroup( prm ), pi -> PermutationMat( pi, n, GF(q) ) ),
        GeneratorsOfGroup( syl ) ) );
      SetSize( syl2, Size(prm)*Size(syl) );
      syl := syl2;
    fi;
  fi;
  SetSize( syl, p^PadicValuation( Size(gl), p ) );
  SetIsPGroup( syl, true );
  SetPrimePGroup( syl, p );
  SetHallSubgroup(gl, [p], syl);
  Assert( 2, Size( Group( GeneratorsOfGroup( syl ) ) ) = Size( syl ) );
  return syl;
end;

# Just install the method.
InstallMethod( SylowSubgroupOp,
  "Direct construction for natural GL",
  [ IsNaturalGL and IsFinite and IsFFEMatrixGroup, IsPosInt ],
  SylowSubgroupOfNaturalGL
);

end, [] );
