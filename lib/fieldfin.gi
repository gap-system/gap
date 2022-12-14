#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel, Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file    contains  methods for  finite  fields.    Note that  we must
##  distinguish finite fields and fields that  consist of `FFE's.  (The image
##  of the natural embedding of the field  `GF(<q>)' into a field of rational
##  functions is of  course a finite field  but  its elements are  not `FFE's
##  since this would be a property given by their family.)
##
##  Special methods for `FFE's can be found in the file `ffe.gi'.
##
##  1. Miscellaneous Functions
##  2. Groups of FFEs
##  3. Bases of Finite Fields
##  4. Automorphisms of Finite Fields
##


#############################################################################
##
##  1. Miscellaneous Functions
##


#############################################################################
##
#M  GeneratorsOfLeftModule( <F> ) . . . .  the vectors of the canonical basis
##
InstallMethod( GeneratorsOfLeftModule,
    "for a finite field (return the vectors of the canonical basis)",
    [ IsField and IsFinite ],
    function( F )
    local z;
    z:= RootOfDefiningPolynomial( F );
    return List( [ 0 .. Dimension( F ) - 1 ], i -> z^i );
#T call of `UseBasis' ?
    end );


#############################################################################
##
#M  Random( <F> ) . . . . . . . . . . . .  random element from a finite field
##
##  We have special methods for finite prime fields and for fields with
##  primitive root, for efficiency reasons.
##  All other cases are handled by the vector space methods.
##
InstallMethodWithRandomSource( Random,
    "for a random source and a finite prime field",
    [ IsRandomSource, IsField and IsPrimeField and IsFinite ],
    { rs, F } -> Random(rs,1,Size(F)) * One( F ) );

InstallMethodWithRandomSource( Random,
    "for a random source and a finite field with known primitive root",
    [ IsRandomSource, IsField and IsFinite and HasPrimitiveRoot ],
    function ( rs, F )
    local   rnd;
    rnd := Random( rs, 0, Size( F )-1 );
    if rnd = 0  then
      rnd := Zero( F );
    else
      rnd := PrimitiveRoot( F )^rnd;
    fi;
    return rnd;
    end );


#############################################################################
##
#M  Units( <F> )  . . . . . . . . . . . . . . . . . . . . via `PrimitiveRoot'
##
InstallMethod( Units,
    "for a finite field",
    [ IsField and IsFinite ],
    function ( F )
    local G;
    G := GroupByGenerators( [ PrimitiveRoot( F ) ] );
    if HasSize( F ) then
      SetSize( G, Size( F )-1 );
    fi;
    return G;
    end );


#############################################################################
##
#M  \=( <F>, <G> ) . . . . . . . . . . . . . . . . . .  for two finite fields
##
##  Note that for two finite fields in the same family,
##  it suffices to check the dimensions as vector spaces over the (common)
##  prime field.
##
InstallMethod( \=,
    "for two finite fields in the same family",
    IsIdenticalObj,
    [ IsField and IsFinite, IsField and IsFinite ],
    function ( F, G )
    return DegreeOverPrimeField( F ) = DegreeOverPrimeField( G );
    end );


#############################################################################
##
#M  IsSubset( <F>, <G> )  . . . . . . . . . . . . . . . for two finite fields
##
##  Note that for two finite fields in the same family,
##  it suffices to check the dimensions as vector spaces over the (common)
##  prime field.
##
InstallMethod( IsSubset,
    "for two finite fields in the same family",
    IsIdenticalObj,
    [ IsField and IsFinite, IsField and IsFinite ],
    function( F, G )
    return DegreeOverPrimeField( F ) mod DegreeOverPrimeField( G ) = 0;
    end );


#############################################################################
##
#M  Subfields( <F> )  . . . . . . . . . . . . . . subfields of a finite field
##
InstallMethod( Subfields,
    "for finite field of FFEs",
    [ IsField and IsFinite and IsFFECollection ],
    function( F )
    local d, p;
    d:= DegreeOverPrimeField( F );
    p:= Characteristic( F );
    return List( DivisorsInt( d ), n -> GF( p, n ) );
    end );

#############################################################################
##
#M  Subfields( <F> )  . . . . . . . . . . . . . . subfields of a finite field
##
InstallMethod( Subfields, "for finite fields that are not FFEs",
    [ IsField and IsFinite ],
function( F )
local d, p,l,i,mp,fac,S;
  d:= DegreeOverPrimeField( F );
  p:= Characteristic( F );
  l:=[];
  for i in Filtered(DivisorsInt(d),x->x<d) do
    mp:=MinimalPolynomial(GF(p),PrimitiveRoot(GF(p^i)));
    mp:=Value(mp,X(F),One(F));
    fac:=Factors(mp);
    fac:=RootsOfUPol(fac[1])[1]; # one root
    S:=FieldByGenerators([fac]);
    SetDegreeOverPrimeField(S,i);
    SetSize(S,p^i);
    # hack, as there is no good print routine for subfields
    SetName(S,Concatenation("Field([",String(fac),"])"));
    Add(l,S);
  od;
  Add(l,F); # field itself -- save on expensive factorization
  return l;
end );


#############################################################################
##
#M  PrimeField( <F> ) . . . . . . . . . . . . . . . . . .  for a finite field
##
InstallMethod( PrimeField,
    "for finite field of FFEs",
    [ IsField and IsFFECollection ],
    F -> GF( Characteristic( F ) ) );


#############################################################################
##
#M  MinimalPolynomial( <F>, <z>, <inum> )
##
InstallMethod( MinimalPolynomial,
    "finite field, finite field element, and indet. number",
    IsCollsElmsX,
    [ IsField and IsFinite, IsScalar, IsPosInt ],
function( F, z, inum )
    local   df,  dz,  q,  dd,  pol,  deg,  con,  i;

    # get the field in which <z> lies
    df := DegreeOverPrimeField(F);
    dz := DegreeOverPrimeField(DefaultField(z));
    q  := Size(F);
    dd := LcmInt(df,dz) / df;

    # compute the minimal polynomial simply by multiplying $x-cnj$
    pol := [ One(F) ];
    deg := 0;
    for con  in Set( [ 0 .. dd-1 ], x -> z^(q^x) )  do
        pol[deg+2] := pol[deg+1];
        for i  in [ deg+1, deg .. 2 ]  do
            pol[i] := pol[i-1] -  con*pol[i];
        od;
        pol[1] := -con*pol[1];
        deg := deg + 1;
    od;

    # return the coefficients list of the minimal polynomial
    return UnivariatePolynomial( F, pol, inum );
end );


#############################################################################
##
##  2. Groups of FFEs
##


#############################################################################
##
#M  IsHandledByNiceMonomorphism( <G> )  . . . . . . `true' for groups of FFEs
##
InstallTrueMethod( IsHandledByNiceMonomorphism,
    IsGroup and IsFFECollection );


#############################################################################
##
#M  IsCyclic( <G> ) . . . . . . . . . . . . . . . . groups of FFEs are cyclic
##
InstallTrueMethod( IsCyclic, IsGroup and IsFFECollection );


#############################################################################
##
#M  <elm> in <G>  . . . . . . . . . . . . . . . . . . . . via `PrimitiveRoot'
##
InstallMethod( \in,
    "for groups of FFE",
    IsElmsColls,
    [ IsFFE, IsGroup and IsFFECollection ],
    function( elm, G )
    local F;

    F:= Field( Concatenation( GeneratorsOfGroup( G ), [ One( G ) ] ) );
    return     elm in F and not IsZero( elm )
           and LogFFE( elm, PrimitiveRoot( F ) ) mod
               ( ( Size( F ) - 1 ) / Size( G ) ) = 0;
    end );


#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . . . . via `PrimitiveRoot'
##
InstallMethod( Size,
    "for groups of FFE",
    [ IsGroup and IsFFECollection ],
    function( G )
    local   gens, F, z, k;

    if IsTrivial( G )  then
        return 1;
    fi;

    gens := GeneratorsOfGroup( G );
    F := Field( gens );
    z := PrimitiveRoot( F );
    k := Gcd( Integers, List( gens, g -> LogFFE(g, z) ) );
    return ( Size( F ) - 1 ) /  GcdInt(k, ( Size( F ) - 1 ));
end );


#############################################################################
##
#M  AbelianInvariants( <G> ) . . . . . . . . . . . . . .  via `PrimitiveRoot'
##
InstallMethod( AbelianInvariants,
    "for groups of FFE",
    [ IsGroup and IsFFECollection ],
    G -> AbelianInvariantsOfList( [Size( G )] ) );

#############################################################################
##
#M  CanEasilyComputeWithIndependentGensAbelianGroup( <G> )
##
InstallTrueMethod(CanEasilyComputeWithIndependentGensAbelianGroup,
    IsGroup and IsFFECollection);

#############################################################################
##
#M  IndependentGeneratorsOfAbelianGroup( <G> ) . . . . .  via `PrimitiveRoot'
##
InstallMethod( IndependentGeneratorsOfAbelianGroup,
    "for groups of FFE",
    [ IsGroup and IsFFECollection ],
    function( G )
    local   F, g, base, ord, o, cf, j;

    if IsTrivial( G )  then
        return [];
    fi;

    F := Field( GeneratorsOfGroup( G ) );
    g := PrimitiveRoot( F ) ^ ( ( Size( F ) - 1 ) / Size( G ) );
    base := [];
    ord := [];
    o := Order( g );
    cf:=Collected( Factors( o ) );
    for j in cf do
        j := j[1]^j[2];
        Add( base, g^(o/j) );
        Add( ord, j );
    od;
    SortParallel(ord,base);
    return base;
end );

#############################################################################
##
#M  IndependentGeneratorExponents( <G> ) . . . . . . . .  via `PrimitiveRoot'
##
InstallMethod( IndependentGeneratorExponents,
    "for groups of FFE",
    IsCollsElms,
    [ IsGroup and IsFFECollection, IsFFE ],
    function( G, elm )
    local   F, z, gens, j, exps;

    if IsTrivial( G )  then
        return [];
    fi;

    F := Field( GeneratorsOfGroup( G ) );
    z := PrimitiveRoot( F );
    gens := IndependentGeneratorsOfAbelianGroup( G );

    # We need to compute LogFFE for every element of gens, which is
    # in general quite expensive. But if gens was computed by our
    # IndependentGeneratorsOfAbelianGroup method, then we actually
    # know the LogFFE value. Since verifying this is cheap, try that
    # first before resorting to LogFFE.
    exps := List( gens, g -> ( Size(F) - 1 ) / Order( g ) );

    if ForAny( [ 1 .. Length(exps) ], i -> gens[i] <> z^exps[i] ) then
        # We have to do it the hard way...
        exps := List( gens, g -> LogFFE( g, z ) );
    fi;

    j := LogFFE( elm, z );
    exps := List( [1..Length(exps)], i -> ( j / exps[i] ) mod Order( gens[i] ) );

    Assert( 0, elm = Product( [1..Length(exps)], i -> gens[i]^exps[i]) );
    return exps;
end );


#############################################################################
##
##  3. Bases of Finite Fields
##
##  *Note*:  Bases of *subspaces* of fields which are themselves not fields
##  are handled by the mechanism of nice bases (see `field.gi').
##


#############################################################################
##
#R  IsBasisFiniteFieldRep( <F> )
##
##  Bases of finite fields in the representation `IsBasisFiniteFieldRep'
##  are dealt with as follows.
##
##  Coefficients w.r.t.~a basis $B = (b_0, b_1, \ldots, b_d)$ of the field
##  extension $GF(q^{d+1})$ over $GF(q)$ can be computed as follows.
##  $x \in GF(q^{d+1})$ is of the form $x = \sum_{i=0}^d a_i b_i$,
##  with $a_i \in GF(q)$, if and only if for $0 \leq k \leq d$ the equation
##  $x^{q^k} = \sum_{i=0}^d a_i b_i^{q^k}$ holds.
##  Thus we have the matrix equation
##  $$
##  [ x^{q^k} ]_{k=0}^d = [ a_i ]_{i=0}^d [ b_i^{q^k} ]_{i,k=0}^d ,
##  $$
##  from which the coefficients $a_i$ can be computed.
##  The inverse of the matrix $[ b_i^{q^k} ]_{i,k=0}^d$ is stored in the
##  basis as value of the component `inverseBase'.
##
DeclareRepresentation( "IsBasisFiniteFieldRep",
    IsAttributeStoringRep,
    [ "inverseBase", "d", "q" ] );

InstallTrueMethod( IsFinite, IsBasis and IsBasisFiniteFieldRep );


#############################################################################
##
#M  Basis( <F> )
##
##  We know a canonical basis for finite fields.
##
InstallMethod( Basis,
    "for a finite field (delegate to `CanonicalBasis')",
    [ IsField and IsFinite ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  Basis( <F>, <gens> )
#M  BasisNC( <F>, <gens> )
##
InstallMethod( Basis,
    "for a finite field, and a hom. list",
    IsIdenticalObj,
    [ IsField and IsFinite, IsFFECollection and IsList ],
    function( F, gens )

    local B,     # the basis, result
          q,     # size of the subfield
          d,     # dimension of the extension
          mat,
          b,b1,
          cnjs,
          k;

    # Set up the basis object.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsBasisFiniteFieldRep ),
                   rec() );
    SetUnderlyingLeftModule( B, F );
    SetBasisVectors( B, gens );

    # Get the size `q' of the subfield and the dimension `d'
    # of the extension with respect to the subfield.
    q:= Size( LeftActingDomain( F ) );
    d:= Dimension( F );

    # Test that the basis vectors really define the
    # (unique) finite field extension of degree `d'.
    if d <> Length( gens ) then
      return fail;
    fi;

    # Build the matrix `M[i][k] = vectors[i]^(q^k)'.
    mat:= [];
    for b in gens do
        cnjs := [];
        b1 := b;
        cnjs := [b];
        for k in [ 1 .. d-1 ] do
            b1 := b1^q;
            Add( cnjs, b1 );
        od;
        Add( mat, cnjs );
    od;

    # We have a basis if and only if `mat' is invertible.
    if Length(mat) > 0 then
        mat:= Inverse( mat );
        if mat = fail then
            return fail;
        fi;
    else
        mat := Immutable(mat);
    fi;

    # Add the coefficients information.
    B!.inverseBase:= mat;
    B!.d:= d;
    B!.q:= q;

    # Return the basis.
    return B;
    end );

InstallMethod( BasisNC,
    "for a finite field, and a hom. list",
    IsIdenticalObj,
    [ IsField and IsFinite, IsFFECollection and IsList ], 10,
    function( F, gens )

    local B,     # the basis, result
          q,     # size of the subfield
          d,     # dimension of the extension
          mat,
          b,b1,
          cnjs,
          k;

    # Set up the basis object.
    B:= Objectify( NewType( FamilyObj( gens ),
                                IsFiniteBasisDefault
                            and IsBasisFiniteFieldRep ),
                   rec() );
    SetUnderlyingLeftModule( B, F );
    SetBasisVectors( B, gens );

    # Get the size `q' of the subfield and the dimension `d'
    # of the extension with respect to the subfield.
    q:= Size( LeftActingDomain( F ) );
    d:= Dimension( F );

    # Build the matrix `M[i][k] = vectors[i]^(q^k)'.
    mat:= [];
    for b in gens do
        cnjs := [b];
        b1 := b;
        for k in [ 1 .. d-1 ] do
            b1 := b1^q;
            Add( cnjs, b1 );
        od;
        Add( mat, cnjs );
    od;

    # Add the coefficients information.
    if Length(mat) > 0 then
        B!.inverseBase:= Inverse( mat );
    else
        B!.inverseBase:= Immutable(mat);
    fi;
    B!.d:= d;
    B!.q:= q;

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  Coefficients( <B>, <z> )  . . . . . . . . . . for basis of a finite field
##
InstallMethod( Coefficients,
    "for a basis of a finite field, and a scalar",
    IsCollsElms,
    [ IsBasis and IsBasisFiniteFieldRep, IsScalar ],
    function ( B, z )
    local   q, d, k, zz;

    if   not z in UnderlyingLeftModule( B ) then
      return fail;
    fi;

    # Get the size `q' of the subfield and the degree `d' of the extension
    # with respect to the subfield.
    q := B!.q;
    d := B!.d;

    # Compute the vector of conjugates of `z'.
    zz := [];
    for k  in [0..d-1]  do
        Add( zz, z^(q^k) );
    od;

    # The `inverseBase' component of the basis defines the base change
    # to the normal basis.
    return zz * B!.inverseBase;
    end );


#############################################################################
##
#M  LinearCombination( <B>, <coeffs> )
##
InstallMethod( LinearCombination,
    "for a basis of a finite field, and a hom. list",
    IsIdenticalObj,
    [ IsBasis and IsBasisFiniteFieldRep, IsHomogeneousList ],
        function ( B, coeffs )
    if Length(coeffs) = 0 then
        TryNextMethod();
    fi;
    return coeffs * BasisVectors( B );
#T This calls PROD_LIST_LIST_DEFAULT
#T if both lists are known to be small,
#T and PROD_LIST_LIST_TRY otherwise!
#T Is this method necessary at all??
    end );


#############################################################################
##
#M  CanonicalBasis( <F> )
##
##  The canonical basis of the finite field <F> with $p^n$ elements,
##  viewed over its subfield with $p^d$ elements,
##  consists of the vectors $<z>^i$, $0 \leq i \< n/d$,
##  where <z> is `RootOfDefiningPolynomial( <F> )'.
##
InstallMethod( CanonicalBasis,
    "for a finite field",
    [ IsField and IsFinite and IsFFECollection ],
    function( F )
    local z,         # primitive root
          B;         # basis record, result

    z:= RootOfDefiningPolynomial( F );
    B:= BasisNC( F, List( [ 0 .. Dimension( F ) - 1 ], i -> z ^ i ) );
    SetIsCanonicalBasis( B, true );

    # Return the basis object.
    return B;
    end );


#############################################################################
##
#M  NormalBase( <F>, <elm> )
##
##  For finite fields just search.
##
InstallMethod( NormalBase,
"for a finite field and scalar",
    [ IsField and IsFinite, IsScalar ],
function(F, b)
    local q, d, z, l, bas, i;
    if b=0*b then
        b := One(F);
    fi;
    q := Size(LeftActingDomain(F));
    d := Dimension(F);
    z := PrimitiveRoot(F);
    repeat
        l := [b];
        for i in [1..d-1] do
          Add(l, l[i]^q);
        od;
        bas := Basis(F, l);
        b := b*z;
    until bas <> fail;
    return l;
end);


#############################################################################
##
##  4. Automorphisms of Finite Fields
##


#############################################################################
##
#R  IsFrobeniusAutomorphism( <obj> )  . test if an object is a Frobenius aut.
##
DeclareRepresentation( "IsFrobeniusAutomorphism",
        IsFieldHomomorphism
    and IsMapping
    and IsAttributeStoringRep,
    [ "power" ] );


#############################################################################
##
#F  FrobeniusAutomorphism(<F>)  . .  Frobenius automorphism of a finite field
##
BindGlobal( "FrobeniusAutomorphismI", function ( F, i )

    local Fam, frob;

    # Catch the bad case.
    if Size( F ) = 2 then
      i:= 1;
    else
      i:= i mod ( Size( F ) - 1 );
    fi;

    if i = 1 then
      return IdentityMapping( F );
    fi;

    Fam:= ElementsFamily( FamilyObj( F ) );

    # make the mapping object
    frob:= Objectify( TypeOfDefaultGeneralMapping( F, F,
                              IsFrobeniusAutomorphism
                          and IsSPGeneralMapping
                          and IsRingWithOneHomomorphism
                          and IsBijective ),
                      rec() );

    frob!.power := i;

    return frob;
end );

InstallMethod( FrobeniusAutomorphism,
    "for a field",
    [ IsField ],
    function ( F )

    # check the arguments
    if not IsPosRat( Characteristic( F ) ) then
        Error( "<F> must be a field of nonzero characteristic" );
    fi;

    # return the automorphism
    return FrobeniusAutomorphismI( F, Characteristic( F ) );
end );


#############################################################################
##
#M  \=( <frob1>, <frob2> )
#M  \=( <id>, <frob> )
#M  \=( <frob>, <id> )
##
InstallMethod( \=,
    "for two Frobenius automorphisms",
    IsIdenticalObj,
    [ IsFrobeniusAutomorphism, IsFrobeniusAutomorphism ],
    function( aut1, aut2 )
    return Source( aut1 ) = Source( aut2 ) and aut1!.power  = aut2!.power;
    end );

InstallMethod( \=,
    "for identity mapping and Frobenius automorphism",
    IsIdenticalObj,
    [ IsMapping and IsOne, IsFrobeniusAutomorphism ],
    function( id, aut )
    return Source( id ) = Source( aut ) and aut!.power = 1;
    end );

InstallMethod( \=,
    "for Frobenius automorphism and identity mapping",
    IsIdenticalObj,
    [ IsFrobeniusAutomorphism, IsMapping and IsOne ],
    function( aut, id )
    return Source( id ) = Source( aut ) and aut!.power = 1;
    end );

InstallMethod( ImageElm,
    "for Frobenius automorphism and source element",
    FamSourceEqFamElm,
    [ IsFrobeniusAutomorphism, IsObject ],
    function( aut, elm )
    return elm ^ aut!.power;
    end );

InstallMethod( ImagesElm,
    "for Frobenius automorphism and source element",
    FamSourceEqFamElm,
    [ IsFrobeniusAutomorphism, IsObject ],
    function( aut, elm )
    return [ elm ^ aut!.power ];
    end );

InstallMethod( ImagesSet,
    "for Frobenius automorphism and field contained in the source",
    CollFamSourceEqFamElms,
    [ IsFrobeniusAutomorphism, IsField ],
    function( aut, elms )
    return elms;
    end );

InstallMethod( ImagesRepresentative,
    "for Frobenius automorphism and source element",
    FamSourceEqFamElm,
    [ IsFrobeniusAutomorphism, IsObject ],
    function( aut, elm )
    return elm ^ aut!.power;
    end );

InstallMethod( CompositionMapping2,
    "for two Frobenius automorphisms",
    IsIdenticalObj,
    [ IsFrobeniusAutomorphism, IsFrobeniusAutomorphism ],
    function( aut1, aut2 )
    if Characteristic( Source( aut1 ) )
       = Characteristic( Source( aut2 ) ) then
      return FrobeniusAutomorphismI( Source( aut1 ),
                                     aut1!.power * aut2!.power );
    else
      Error( "Frobenius automorphisms of different characteristics" );
    fi;
    end );

InstallMethod( InverseGeneralMapping,
    "for a Frobenius automorphism",
    [ IsFrobeniusAutomorphism ],
    aut -> FrobeniusAutomorphismI( Source( aut ),
                                   Size( Source( aut ) ) / aut!.power ) );

InstallMethod( \^,
    "for a Frobenius automorphism, and an integer",
    [ IsFrobeniusAutomorphism, IsInt ],
    function ( aut, i )
    return FrobeniusAutomorphismI( Source( aut ),
                   PowerModInt( aut!.power, i, Size( Source( aut ) ) - 1 ) );
    end );

InstallMethod( \<,
    "for an identity mapping, and a Frobenius automorphism",
    IsIdenticalObj,
    [ IsMapping and IsOne, IsFrobeniusAutomorphism ],
    function ( id, aut )
    local source1, # source of `id'
          source2, # source of `aut'
          p,       # characteristic
          root,    # primitive root of source
          size,    # size of source
          d,       # degree
          gen;     # generator of cyclic group of subfield

    source1:= Source( id );
    source2:= Source( aut );
    if source1 <> source2 then
      return source1 < source2;
    elif    PrimitiveRoot( source1 )
         <> PrimitiveRoot( source2 ) then
      return   PrimitiveRoot( source1 )
             < PrimitiveRoot( source2 );
#T o.k.?
    else
        p := Characteristic( source1 );
        root:= PrimitiveRoot( source1 );
        size:= Size( source1 );
        for d  in DivisorsInt( LogInt( size, p ) )  do
            gen:= root^( ( size - 1 ) / ( p^d - 1 ) );
            if gen <> gen ^ aut!.power  then
                return gen < gen ^ aut!.power;
            fi;
        od;
        return false;
    fi;
    end );

InstallMethod( \<,
    "for a Frobenius automorphism, and an identity mapping",
    IsIdenticalObj,
    [ IsFrobeniusAutomorphism, IsMapping and IsOne ],
    function ( aut, id )
    local source1, # source of `aut'
          source2, # source of `id'
          p,       # characteristic
          root,    # primitive root of source
          size,    # size of source
          d,       # degree
          gen;     # generator of cyclic group of subfield

    source1:= Source( aut );
    source2:= Source( id );
    if source1 <> source2 then
      return source1 < source2;
    elif    PrimitiveRoot( source1 )
         <> PrimitiveRoot( source2 ) then
      return   PrimitiveRoot( source1 )
             < PrimitiveRoot( source2 );
#T o.k.?
    else
        p := Characteristic( source1 );
        root:= PrimitiveRoot( source1 );
        size:= Size( source1 );
        for d  in DivisorsInt( LogInt( size, p ) )  do
            gen:= root^( ( size - 1 ) / ( p^d - 1 ) );
            if gen ^ aut!.power <> gen then
                return gen ^ aut!.power < gen;
            fi;
        od;
        return false;
    fi;
    end );

InstallMethod( \<,
    "for two Frobenius automorphisms",
    IsIdenticalObj,
    [ IsFrobeniusAutomorphism, IsFrobeniusAutomorphism ],
    function ( aut1, aut2 )
    local source1, # source of `aut1'
          source2, # source of `aut2'
          p,       # characteristic
          root,    # primitive root of source
          size,    # size of source
          d,       # degree
          gen;     # generator of cyclic group of subfield

    source1:= Source( aut1 );
    source2:= Source( aut2 );
    if source1 <> source2 then
      return source1 < source2;
    elif    PrimitiveRoot( source1 )
         <> PrimitiveRoot( source2 ) then
      return   PrimitiveRoot( source1 )
             < PrimitiveRoot( source2 );
#T o.k.?
    else
        p := Characteristic( source1 );
        root:= PrimitiveRoot( source1 );
        size:= Size( source1 );
        for d  in DivisorsInt( LogInt( size, p ) )  do
            gen:= root^( ( size - 1 ) / ( p^d - 1 ) );
            if gen ^ aut1!.power <> gen ^ aut2!.power  then
                return gen ^ aut1!.power < gen ^ aut2!.power;
            fi;
        od;
        return false;
    fi;
    end );

InstallMethod( PrintObj,
    "for a Frobenius automorphism",
    [ IsFrobeniusAutomorphism ],
    function ( aut )
    if aut!.power = Characteristic( Source( aut ) ) then
        Print( "FrobeniusAutomorphism( ", Source( aut ), " )" );
    else
        Print( "FrobeniusAutomorphism( ", Source( aut ), " )^",
               LogInt( aut!.power, Characteristic( Source( aut ) ) ) );
    fi;
    end );


#############################################################################
##
#M  GaloisGroup( <F> )  . . . . . . . . . . .  Galois group of a finite field
##
InstallMethod( GaloisGroup,
    "for a finite field",
    [ IsField and IsFinite ],
    F -> GroupByGenerators(
            [ FrobeniusAutomorphismI( F, Size( LeftActingDomain(F) ) ) ] ) );
