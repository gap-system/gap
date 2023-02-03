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
##  This file contains methods for `FFE's.
##  Note that we must distinguish finite fields and fields that consist of
##  `FFE's.
##  (The image of the natural embedding of the field `GF(<q>)' into a field
##  of rational functions is of course a finite field but its elements are
##  not `FFE's since this would be a property given by their family.)
##
##  Special methods for (elements of) general finite fields can be found in
##  the file `fieldfin.gi'.
##
##  The implementation of elements of rings `Integers mod <n>' can be found
##  in the file `zmodnz.gi'.
##


#############################################################################
##
#M  \+( <ffe>, <rat> )
#M  \+( <rat>, <ffe> )
#M  \*( <ffe>, <rat> )
#M  \*( <rat>, <ffe> )
##
##  The arithmetic operations with one operand a FFE <ffe> and the other
##  a rational <rat> are defined as follows.
##  Let `<one> = One( <ffe> )', and let <num> and <den> denote the numerator
##  and denominator of <rat>.
##  Let `<new> = (<num>\*<one>) / (<den>\*<one>)'.
##  (Note that the multiplication of FFEs with positive integers is defined
##  as abbreviated addition.)
##  Then we have `<ffe> + <rat> = <rat> + <ffe> = <ffe> + <new>',
##  and `<ffe> \* <rat> = <rat> \* <ffe> = <ffe> \* <new>'.
##  As usual, difference and quotient are defined as sum and product,
##  with the second argument replaced by its additive and multiplicative
##  inverse, respectively.
##
##  (It would be possible to install these methods in the kernel tables,
##  where the case of arithmetic operations with one operand an internally
##  represented FFE and the other a rational *integer* is handled.
##  But the case of noninteger rationals does probably not occur particularly
##  often.)
##
InstallMethod( \+,
    "for a FFE and a rational",
    [ IsFFE, IsRat ],
    function( ffe, rat )
    rat:= (rat mod Characteristic(ffe))*One(ffe);
    return ffe + rat;
    end );

InstallMethod( \+,
    "for a rational and a FFE",
    [ IsRat, IsFFE ],
    function( rat, ffe )
    rat:= (rat mod Characteristic(ffe))*One(ffe);
    return rat + ffe;
    end );

InstallMethod( \*,
    "for a FFE and a rational",
    [ IsFFE, IsRat ],
    function( ffe, rat )
    if IsInt( rat ) then
      # Avoid the recursion trap.
      TryNextMethod();
    fi;
    # Replace the rational by an equivalent integer.
    rat:= rat mod Characteristic(ffe);
    return ffe * rat;
    end );

InstallMethod( \*,
    "for a rational and a FFE",
    [ IsRat, IsFFE ],
    function( rat, ffe )
    if IsInt( rat ) then
      # Avoid the recursion trap.
      TryNextMethod();
    fi;
    # Replace the rational by an equivalent integer.
    rat:= rat mod Characteristic(ffe);
    return rat * ffe;
    end );


#############################################################################
##
#M  DegreeFFE( <vector> )
##
InstallOtherMethod( DegreeFFE,
    "for a row vector of FFEs",
    [ IsRowVector and IsFFECollection ],
    function( list )
    local deg, i;

    #
    # Those length zero vectors for which this makes sense have
    # representation-specific methods
    #
    if Length(list) = 0 then
        TryNextMethod();
    fi;
    deg:= DegreeFFE( list[1] );
    for i in [ 2 .. Length( list ) ] do
      deg:= LcmInt( deg, DegreeFFE( list[i] ) );
    od;
    return deg;
    end );
#T    list -> Lcm( List( list, DegreeFFE ) ) );
#T to be provided by the kernel!


#############################################################################
##
#M  DegreeFFE( <matrix> )
##
InstallOtherMethod( DegreeFFE,
    "for a matrix of FFEs",
    [ IsMatrix and IsFFECollColl ],
    function( mat )
    local deg, i;
    deg:= DegreeFFE( mat[1] );
    for i in [ 2 .. Length( mat ) ] do
      deg:= LcmInt( deg, DegreeFFE( mat[i] ) );
    od;
    return deg;
    end );


#############################################################################
##
#M  LogFFE( <n>, <r> )  . . . . . . . . . . . .  for two FFE in a prime field
##
InstallMethod( LogFFE,
    "for two FFEs (in a prime field)",
    IsIdenticalObj,
    [ IsFFE, IsFFE ],
        function( n, r )
    if DegreeFFE( n ) = 1 and DegreeFFE( r ) = 1 then
        return LogMod( Int( n ), Int( r ), Characteristic( n ) );
    else
        TryNextMethod();
    fi;
end );


#############################################################################
##
#M  IntVecFFE( <vector> )
##
InstallMethod( IntVecFFE,
    "for a row vector of FFEs",
    [ IsRowVector and IsFFECollection ],
    v -> List( v, IntFFE ) );


#############################################################################
##
#F  FFEFamily( <p> )
##
InstallGlobalFunction( FFEFamily, function( p )
    local F;

    if MAXSIZE_GF_INTERNAL < p then

      # large characteristic
      F:= GET_FROM_SORTED_CACHE( FAMS_FFE_LARGE, p, function()

        F:= NewFamily( "FFEFamily", IsFFE,
                       CanEasilySortElements,
                       CanEasilySortElements );
        SetCharacteristic( F, p );

        # Store the type for the representation of prime field elements
        # via residues.
        F!.typeOfZmodnZObj:= NewType( F, IsZmodpZObjLarge
          and IsModulusRep and IsZDFRE);

        SetOne(  F, ZmodnZObj( F, 1 ) );
        SetZero( F, ZmodnZObj( F, 0 ) );

        # The whole family is a unique factorisation domain.
        SetIsUFDFamily( F, true );

        return F;

      end );

    else

      # small characteristic
      # (The list `TYPE_FFE' is used to store the types.)
      F:= FamilyType( TYPE_FFE( p ) );
      if not HasOne( F ) then

        # This family has not been accessed by `FFEFamily' before.
        SetOne(  F, One( Z(p) ) );
        SetZero( F, Zero( Z(p) ) );

      fi;

    fi;

    MakeWriteOnceAtomic(F); # needed for HPC-GAP, does nothing in plain GAP
    return F;
end );


#############################################################################
##
#M  Zero( <ffe-family> )
##
InstallOtherMethod( Zero,
    "for a family of FFEs",
    [ IsFFEFamily ],
    function( fam )
    local char;
    char:= Characteristic( fam );
    if char <= MAXSIZE_GF_INTERNAL then
      return Zero( Z( char ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  One( <ffe-family> )
##
InstallOtherMethod( One,
    "for a family of FFEs",
    [ IsFFEFamily ],
    function( fam )
    local char;
    char:= Characteristic( fam );
    if char <= MAXSIZE_GF_INTERNAL then
      return One( Z( char ) );
    else
      TryNextMethod();
    fi;
end );


#############################################################################
##
#F  LargeGaloisField( <p>^<n> )
#F  LargeGaloisField( <p>, <n> )
##
#T other construction possibilities?
##


InstallMethod( LargeGaloisField,
        [IsPosInt],
        function(q)
    local p,d;
    p := SmallestRootInt(q);
    d := LogInt(q,p);
    Assert(1, q = p^d);
    Assert(1, IsPrimeInt(p));
    return LargeGaloisField(p,d);
end);


InstallMethod( LargeGaloisField,
        [IsPosInt, IsPosInt],
        function(p,d)
    if not IsPrimeInt(p) then
        Error("LargeGalosField: Characteristic must be prime");
    fi;
    if d = 1 then
        return ZmodpZNC( p );
    else
        TryNextMethod();
    fi;
end );


#############################################################################
##
#F  GaloisField( <p>^<d> )  . . . . . . . . . .  create a finite field object
#F  GF( <p>^<d> )
#F  GaloisField( <p>, <d> )
#F  GF( <p>, <d> )
#F  GaloisField( <subfield>, <d> )
#F  GF( <subfield>, <d> )
#F  GaloisField( <p>, <pol> )
#F  GF( <p>, <pol> )
#F  GaloisField( <subfield>, <pol> )
#F  GF( <subfield>, <pol> )
##

# in Finite field calculations we often ask again and again for the same GF.
# Therefore cache the last entry.
GFCACHE:=[0,0];
MakeThreadLocal("GFCACHE");

InstallGlobalFunction( GaloisField, function ( arg )
    local F,         # the field, result
          p,         # characteristic
          d,         # degree over the prime field
          d1,        # degree of subfield over prime field
          q,         # size of field to be constructed
          subfield,  # left acting domain of the field under construction
          new,
          B;         # basis of the extension

    # if necessary split the arguments
    if Length( arg ) = 1 and IsPosInt( arg[1] ) then

        if arg[1]=GFCACHE[1] then
          return GFCACHE[2];
        fi;

        # `GF( p^d )'
        p := SmallestRootInt( arg[1] );
        d := LogInt( arg[1], p );

    elif Length( arg ) = 2 then

        # `GF( p, d )'
        p := arg[1];
        d := arg[2];

    else
        Error( "usage: GF( <subfield>, <extension> )" );
    fi;

    # if the subfield is given by a prime denoting the prime field
    if IsInt( p ) and IsPrimeInt( p ) then

      subfield:= p;

      # if the degree of the extension is given
      if   IsInt( d ) and 0 < d then

        # `GF( p, d )' for prime `p'
        if MAXSIZE_GF_INTERNAL < p^d then
          return LargeGaloisField( p, d );
        fi;

      # if the extension is given by an irreducible polynomial
      # over the prime field
      elif     IsRationalFunction( d )
           and IsLaurentPolynomial( d )
           and DegreeFFE( CoefficientsOfLaurentPolynomial( d )[1] ) = 1 then

        # `GF( p, <pol> )' for prime `p'
        return FieldExtension( GaloisField( p, 1 ), d );

      # if the extension is given by coefficients of an irred. polynomial
      # over the prime field
      elif IsHomogeneousList( d )  and DegreeFFE( d ) = 1  then

        # `GF( p, <polcoeffs> )' for prime `p'
        return FieldExtension( GaloisField( p, 1 ),
                               UnivariatePolynomial( GaloisField(p,1), d ) );

      # if a basis for the extension is given
      elif IsHomogeneousList( d ) then

#T The construction of a field together with a basis is obsolete.
#T One should construct the basis explicitly.
        # `GF( p, <basisvectors> )' for prime `p'
        F := GaloisField( GaloisField( p, 1 ), Length( d ) );

        # Check that the vectors in `d' really form a basis,
        # and construct the basis.
        B:= Basis( F, d );
        if B = fail then
          Error( "<extension> is not linearly independent" );
        fi;

        # Note that `F' is *not* the field stored in the global list!
        SetBasis( F, B );
        return F;

      fi;

    # if the subfield is given by a finite field
    elif IsField( p ) then

      subfield:= p;
      p:= Characteristic( subfield );

      d1 := DegreeOverPrimeField(subfield);
      # if the degree of the extension is given
      if   IsInt( d )  then
          q := p^(d*d1);
          if MAXSIZE_GF_INTERNAL < q then
              if d1 = 1 then
                  return LargeGaloisField( p, d );
              else
                  return FieldByGenerators(subfield, [Z(p,d*d1)]);
              fi;
          fi;

        d:= d * DegreeOverPrimeField( subfield );

      # if the extension is given by coefficients of an irred. polynomial
#T should be obsolete!
      elif     IsHomogeneousList( d )
           and DegreeOverPrimeField( subfield ) mod DegreeFFE( d ) = 0 then

        # `GF( subfield, <polcoeffs> )'
        return FieldExtension( subfield,
                               UnivariatePolynomial( subfield, d ) );


      # if the extension is given by an irreducible polynomial
      elif     IsRationalFunction( d )
           and IsLaurentPolynomial( d )
           and DegreeOverPrimeField( subfield ) mod
               DegreeFFE( CoefficientsOfLaurentPolynomial( d )[1] ) = 0 then

        # `GF( subfield, <pol> )'
        return FieldExtension( subfield, d );

      # if a basis for the extension is given
#T The construction of a field together with a basis is obsolete.
      elif IsHomogeneousList( d ) then

        # `GF( <subfield>, <basisvectors> )'
        F := GaloisField( subfield, Length( d ) );

        # Check that the vectors in `d' really form a basis,
        # and construct the basis.
        B:= Basis( F, d );
        if B = fail then
          Error( "<extension> is not linearly independent" );
        fi;

        # Note that `F' is *not* the field stored in the global list!
        SetBasis( F, B );
        return F;

      # Otherwise we don't know how to handle the extension.
      else
        Error( "<extension> must be a <deg>, <bas>, or <pol>" );
      fi;

    # Otherwise we don't know how to handle the subfield.
    else
      Error( "<subfield> must be a prime or a finite field" );
    fi;

    # If this place is reached,
    # `p' is the characteristic, `d' is the degree of the extension,
    # and `p^d' is less than or equal to `MAXSIZE_GF_INTERNAL'.

    if IsInt( subfield ) then

      # The standard field is required.  Look whether it is already stored.

      new := false;
      F := GET_FROM_SORTED_CACHE(GALOIS_FIELDS, p^d, function()
        new := true;
        # Construct the finite field object.
        if d = 1 then
          F:= FieldOverItselfByGenerators( [ Z(p) ] );
        else
          F:= FieldByGenerators( FieldOverItselfByGenerators( [ Z(p) ] ),
                                 [ Z(p^d) ] );
        fi;
        return F;
      end );

      if Length(arg)=1 and not new then
        GFCACHE:=[arg[1],F];
      fi;

    else

      # Construct the finite field object.
      F:= FieldByGenerators( subfield, [ Z(p^d) ] );

    fi;

    # Return the finite field.
    return F;
end );


#############################################################################
##
#M  FieldExtension( <subfield>, <poly> )
##
InstallOtherMethod( FieldExtension,
    "for a field of FFEs, and a univ. Laurent polynomial",
#T CollPoly
    [ IsField and IsFFECollection, IsLaurentPolynomial ],
    function( F, poly )

    local coeffs, p, d, z, r, one, zero, E;

    coeffs:= CoefficientsOfLaurentPolynomial( poly );
    coeffs:= ShiftedCoeffs( coeffs[1], coeffs[2] );
    p:= Characteristic( F );
    d:= ( Length( coeffs ) - 1 ) * DegreeOverPrimeField( F );

    if MAXSIZE_GF_INTERNAL < p^d then
      TryNextMethod();
    fi;

    # Compute a root of the defining polynomial.
    z := Z( p^d );
    r := z;
    one:= One( r );
    zero:= Zero( r );
    while r <> one and ValuePol( coeffs, r ) <> zero do
      r := r * z;
    od;
    if DegreeFFE( r ) < Length( coeffs ) - 1  then
      Error( "<poly> must be irreducible" );
    fi;

    # We must not call `AsField' here because then the standard `GF(p^d)'
    # would be returned whenever `F' is equal to `GF(p)'.
    E:= FieldByGenerators( F, [ z ] );
    SetDefiningPolynomial( E, poly );
    SetRootOfDefiningPolynomial( E, r );
    if r = z or Order( r ) = Size( E ) - 1  then
      SetPrimitiveRoot( E, r );
    else
      SetPrimitiveRoot( E, z );
    fi;

    return E;
    end );


#############################################################################
##
#M  DefiningPolynomial( <F> ) . . . . . . . . . .  for standard finite fields
##
InstallMethod( DefiningPolynomial,
    "for a field of FFEs",
    [ IsField and IsFFECollection ],
    function( F )
    local root;

    if HasRootOfDefiningPolynomial( F ) then
      # We must choose a compatible polynomial.
      return MinimalPolynomial( LeftActingDomain( F ),
                                RootOfDefiningPolynomial( F ) );
    fi;

    # Choose a primitive polynomial, and store a root.
    root:= Z( Size( F ) );
    SetRootOfDefiningPolynomial( F, root );
    if IsPrimeField( LeftActingDomain( F ) ) then
      return ConwayPolynomial( Characteristic( F ),
                               DegreeOverPrimeField( F ) );
    else
      return MinimalPolynomial( LeftActingDomain( F ), root );
    fi;
    end );


#############################################################################
##
#M  RootOfDefiningPolynomial( <F> ) . . . . . . .  for standard finite fields
##
InstallMethod( RootOfDefiningPolynomial,
    "for a small field of FFEs",
    [ IsField and IsFFECollection ],
    function( F )
    local coeffs, p, d, z, r, one, zero;

    coeffs:= CoefficientsOfLaurentPolynomial( DefiningPolynomial( F ) );

    # Maybe the call to `DefiningPolynomial' has caused that a root is bound.
    if HasRootOfDefiningPolynomial( F ) then
      return RootOfDefiningPolynomial( F );
    fi;

    coeffs:= ShiftedCoeffs( coeffs[1], coeffs[2] );
    p:= Characteristic( F );
    d:= DegreeOverPrimeField( F );

    if Length( coeffs ) = 2 then
      return - coeffs[1] / coeffs[2];
    elif MAXSIZE_GF_INTERNAL < p^d then
      TryNextMethod();
    fi;

    # Compute a root of the defining polynomial.
    z := Z( p^d );
    r := z;
    one:= One( r );
    zero:= Zero( r );
    while r <> one and ValuePol( coeffs, r ) <> zero do
      r := r * z;
    od;
    if DegreeFFE( r ) < Length( coeffs ) - 1  then
      Error( "<poly> must be irreducible" );
    fi;

    # Return the root.
    return r;
    end );


#############################################################################
##
#M  ViewObj( <F> ) . . . . . . . . . . . . . . . . . . view a field of `FFE's
#M  PrintObj( <F> ) . . . . . . . . . . . . . . . . . print a field of `FFE's
#M  String( <F> ) . . . . . . . . . . a string representing a field of `FFE's
#M  ViewString( <F> ) . . . . . a short string representing a field of `FFE's
##

GAPInfo.tmpGFstring := function( F )
    if IsPrimeField( F ) then
      return Concatenation( "GF(", String(Characteristic( F )), ")" );
    elif IsPrimeField( LeftActingDomain( F ) ) then
      return Concatenation( "GF(", String(Characteristic( F )),
                    "^", String(DegreeOverPrimeField( F )), ")" );
    elif F = LeftActingDomain( F ) then
      return Concatenation( "FieldOverItselfByGenerators( ",
             String(GeneratorsOfField( F )), " )" );
    else
      return Concatenation( "AsField( ", String(LeftActingDomain( F )),
             ", GF(", String(Characteristic( F )),
                      "^", String(DegreeOverPrimeField( F )), ") )" );
    fi;
end;
InstallMethod( String, "for a field of FFEs",
        [ IsField and IsFFECollection ], 10, GAPInfo.tmpGFstring );

InstallMethod( ViewString, "for a field of FFEs",
        [ IsField and IsFFECollection ], 10, GAPInfo.tmpGFstring );
Unbind(GAPInfo.tmpGFstring);
InstallMethod( ViewObj, "for a field of FFEs",
        [ IsField and IsFFECollection ], 10, function( F )
    Print( ViewString(F) );
end );

InstallMethod( PrintObj, "for a field of FFEs",
        [ IsField and IsFFECollection ], 10, function( F )
    Print( ViewString(F) );
end );



#############################################################################
##
#M  \in( <z> ,<F> ) . . . . . . . .  test if an object lies in a finite field
##
InstallMethod( \in,
    "for a FFE, and a field of FFEs",
    IsElmsColls,
    [ IsFFE, IsField and IsFFECollection ],
    function ( z, F )
    return DegreeOverPrimeField( F ) mod DegreeFFE( z ) = 0;
    end );


#############################################################################
##
#M  Intersection( <F>, <G> )  . . . . . . . intersection of two finite fields
##
InstallMethod( Intersection2,
    "for two fields of FFEs",
    IsIdenticalObj,
    [ IsField and IsFFECollection, IsField and IsFFECollection ],
    function ( F, G )
    return GF( Characteristic( F ), GcdInt( DegreeOverPrimeField( F ),
                                            DegreeOverPrimeField( G ) ) );
    end );


#############################################################################
##
#M  Conjugates( <L>, <K>, <z> )  . . . . conjugates of a finite field element
##
InstallMethod( Conjugates,
    "for two fields of FFEs, and a FFE",
    IsCollsXElms,
    [ IsField and IsFinite and IsFFECollection,
      IsField and IsFinite and IsFFECollection, IsFFE ],
    function( L, K, z )
    local   cnjs,       # conjugates of <z> in <L>/<K>, result
            ord,        # order of the subfield <K>
            deg,        # degree of <L> over <K>
            i;          # loop variable

    if DegreeOverPrimeField( L ) mod DegreeFFE(z) <> 0  then
      Error( "<z> must lie in <L>" );
    fi;

    # Get the order of `K' and the dimension of `L' as a `K'-vector space.
    ord := Size( K );
    deg := DegreeOverPrimeField( L ) / DegreeOverPrimeField( K );

    # compute the conjugates $\set_{i=0}^{d-1}{z^(q^i)}$
    cnjs := [];
    for i  in [0..deg-1]  do
        Add( cnjs, z );
        z := z^ord;
    od;

    # return the conjugates
    return cnjs;
    end );


#############################################################################
##
#F  Norm( <L>, <K>, <z> )   . . . . . . . . .  norm of a finite field element
##
InstallMethod( Norm,
    "for two fields of FFEs, and a FFE",
    IsCollsXElms,
    [ IsField and IsFinite and IsFFECollection,
      IsField and IsFinite and IsFFECollection, IsFFE ],
    function( L, K, z )

    if DegreeOverPrimeField( L ) mod DegreeFFE(z) <> 0  then
      Error( "<z> must lie in <L>" );
    fi;

    # Let $|K| = q$, $|L| = q^d$.
    # The norm of $z$ is
    # $\prod_{i=0}^{d-1} (z^{q^i}) = z^{\sum_{i=0}^{d-1} q^i}
    #                              = z^{\frac{q^d-1}{q-1}$.
    return z ^ ( ( Size(L) - 1 ) / ( Size(K) - 1 ) );
    end );


#############################################################################
##
#M  Trace( <L>, <K>, <z> )  . . . . . . . . . trace of a finite field element
##
InstallMethod( Trace,
    "for two fields of FFEs, and a FFE",
    IsCollsXElms,
    [ IsField and IsFinite and IsFFECollection,
      IsField and IsFinite and IsFFECollection, IsFFE ],
    function( L, K, z )
    local   trc,        # trace of <z> in <L>/<K>, result
            ord,        # order of the subfield <K>
            deg,        # degree of <L> over <K>
            i;          # loop variable

    if DegreeOverPrimeField( L ) mod DegreeFFE(z) <> 0  then
      Error( "<z> must lie in <L>" );
    fi;

    # Get the order of `K' and the dimension of `L' as a `K'-vector space.
    ord := Size( K );
    deg := DegreeOverPrimeField( L ) / DegreeOverPrimeField( K );

    # $trc = \sum_{i=0}^{deg-1}{ z^(ord^i) }$
    trc := 0;
    for i  in [0..deg-1]  do
        trc := trc + z;
        z := z^ord;
    od;

    # return the trace
    return trc;
    end );


#############################################################################
##
#M  Order( <z> )  . . . . . . . . . . . . . . order of a finite field element
##
InstallMethod( Order,
    "for an internal FFE",
    [ IsFFE and IsInternalRep ],
    function ( z )
    local   ord,        # order of <z>, result
            chr,        # characteristic of <F> (and <z>)
            deg;        # degree of <z> over the prime field

    # compute the order
    if IsZero( z )   then
        ord := 0;
    else
        chr := Characteristic( z );
        deg := DegreeFFE( z );
        ord := (chr^deg-1) / GcdInt( chr^deg-1, LogFFE( z, Z(chr^deg) ) );
    fi;

    # return the order
    return ord;
end );

InstallMethod( Order,
        "for a general FFE",
        [IsFFE],
        function(z)
    local   p,  d,  ord,  facs,  f,  i,  o;
    p := Characteristic(z);
    d := DegreeFFE(z);
    ord := p^d-1;
    facs := Collected(Factors(Integers,ord));
    for f in facs do
        for i in [1..f[2]] do
            o := ord/f[1];
            if not IsOne(z^o) then
                break;
            fi;
            ord := o;
        od;
    od;
    return ord;
end);

#############################################################################
##
#M  SquareRoots( <F>, <z> )
##
InstallMethod( SquareRoots,
    "for a field of FFEs, and a FFE",
    IsCollsElms,
    [ IsField, IsFFE ],
    function( F, z )
    local r;
    if IsZero( z ) then
      return [ z ];
    elif Characteristic( z ) = 2 then

      # unique square root for each element
      r:= PrimitiveRoot( F );
      return [ r ^ ( LogFFE( z, r ) / 2 mod ( Size( F )-1 ) ) ];

    else

      # either two solutions in `F' or no solution
      r:= PrimitiveRoot( F );
      z:= LogFFE( z, r ) / 2;
      if IsInt( z ) then
        z:= r ^ z;
        return Set( [ z, -z ] );
      else
        return [];
      fi;

    fi;
    end );


#############################################################################
##
#M  NthRoot( <F>, <z>, <n> )
##
InstallMethod( NthRoot, "for a field of FFEs, and a FFE", IsCollsElmsX,
    [ IsField, IsFFE,IsPosInt ],
function( F, a,n )
local z,qm;
  if IsOne(a) or IsZero(a) or n=1 then
    return a;
  fi;
  z:=PrimitiveRoot(F);
  qm:=Size(F)-1;
  a:=LogFFE(a,z)/n;
  if 1<GcdInt(DenominatorRat(a),qm) then
    return fail;
  fi;
  return z^(a mod qm);
end);


#############################################################################
##
#M  Int( <z> ) . . . . . . . . . convert a finite field element to an integer
##
InstallMethod( Int,
    "for an FFE",
    [ IsFFE ],
    IntFFE );


#############################################################################
##
#M  IntFFESymm( <z> )
##
InstallMethod(IntFFESymm,"FFE",true,[ IsFFE ],0,
function(z)
local i,p;
  p:=Characteristic(z);
  i:=IntFFE(z);
  if 2*i>p then
    return i-p;
  else
    return i;
  fi;
end);


#############################################################################
##
#M  IntFFESymm( <vector> )
##
InstallOtherMethod(IntFFESymm,"vector",true,
  [IsRowVector and IsFFECollection ],0,
    v -> List( v, IntFFESymm ) );

#############################################################################
##
#M  String( <ffe> ) . . . . . .  convert a finite field element into a string
##
InstallMethod(String,"for an internal FFE",true,[IsFFE and IsInternalRep],0,
function ( ffe )
local   str, log,deg,char;
  char:=Characteristic(ffe);
  if   IsZero( ffe )  then
    str := Concatenation("0*Z(",String(char),")");
  else
    str := Concatenation("Z(",String(char));
    deg:=DegreeFFE(ffe);
    if deg <> 1  then
      str := Concatenation(str,"^",String(deg));
    fi;
    str := Concatenation(str,")");
    log:= LogFFE(ffe,Z( char ^ deg ));
    if log <> 1 then
      str := Concatenation(str,"^",String(log));
    fi;
  fi;
  ConvertToStringRep( str );
  return str;
end );

InstallMethod(ViewString, "for an internal FFE delegating to String",
  [IsFFE and IsInternalRep], String );

InstallMethod(DisplayString, "for an internal FFE via String",
  [IsFFE and IsInternalRep], ffe -> Concatenation( String(ffe), "\n") );


#############################################################################
##
#M  FieldOverItselfByGenerators( <elms> )
##
InstallMethod( FieldOverItselfByGenerators,
    "for a collection of FFEs",
    [ IsFFECollection ],
    function( elms )

    local F, d, q;

    F:= Objectify( NewType( FamilyObj( elms ),
                            IsField and IsAttributeStoringRep ),
                   rec() );
    d:= DegreeFFE( elms );
    q:= Characteristic( F )^d;

    SetLeftActingDomain( F, F );
    SetIsPrimeField( F, d = 1 );
    SetIsFinite( F, true );
    SetSize( F, q );
    SetGeneratorsOfDivisionRing( F, elms );
    SetGeneratorsOfRing( F, elms );
    SetDegreeOverPrimeField( F, d );
    SetDimension( F, 1 );

    if q <= MAXSIZE_GF_INTERNAL then
      SetPrimitiveRoot( F, Z(q) );
    fi;

    return F;
    end );


#############################################################################
##
#M  FieldByGenerators( <F>, <elms> )  . . . . . . . . . . field by generators
##
InstallMethod( FieldByGenerators,
    "for two coll. of FFEs, the first a field",
    IsIdenticalObj,
    [ IsFFECollection and IsField, IsFFECollection ],
    function( subfield, gens )

    local F, d, subd, q, z;

    F := Objectify( NewType( FamilyObj( gens ),
                             IsField and IsAttributeStoringRep ),
                    rec() );

    d:= DegreeFFE( gens );
    subd:= DegreeOverPrimeField( subfield );
    if d mod subd <> 0 then
      d:= LcmInt( d, subd );
      gens:= Concatenation( gens, GeneratorsOfDivisionRing( subfield ) );
    fi;

    q:= Characteristic( subfield )^d;

    SetLeftActingDomain( F, subfield );
    SetIsPrimeField( F, d = 1 );
    SetIsFinite( F, true );
    SetSize( F, q );
    SetDegreeOverPrimeField( F, d );
    SetDimension( F, d / DegreeOverPrimeField( subfield ) );

    if q <= MAXSIZE_GF_INTERNAL then
      z:= Z(q);
      SetPrimitiveRoot( F, z );
      gens:= [ z ];
#    elif d <> 1 then
#      Error( "sorry, large non-prime fields are not yet implemented" );
    fi;

    SetGeneratorsOfDivisionRing( F, gens );
    SetGeneratorsOfRing( F, gens );

    return F;
    end );


#############################################################################
##
#M  DefaultFieldByGenerators( <z> ) . . . . . . default field containing ffes
#M  DefaultFieldByGenerators( <F>, <elms> ) . . default field containing ffes
##
InstallMethod( DefaultFieldByGenerators,
    "for a collection of FFEs that is a list",
    [ IsFFECollection and IsList ],
    gens -> GF( Characteristic( gens ), DegreeFFE( gens ) ) );

InstallOtherMethod( DefaultFieldByGenerators,
    "for a finite field, and a collection of FFEs that is a list",
    IsIdenticalObj,
    [ IsField and IsFinite, IsFFECollection and IsList ],
    function( F, gens )
    return GF( F, DegreeFFE( gens ) );
    end );


#############################################################################
##
#M  RingByGenerators( <elms> )  . . . . . . . . . . . . .  for FFE collection
#M  RingWithOneByGenerators( <elms> ) . . . . . . . . . .  for FFE collection
#M  DefaultRingByGenerators( <z> )  . . . . . .  default ring containing FFEs
#M  FLMLORByGenerators( <F>, <elms> ) . . . . . . . . . .  for FFE collection
#M  FLMLORWithOneByGenerators( <F>, <elms> )  . . . . . .  for FFE collection
##
##  In all these cases, the result is either zero or in fact a field,
##  so we may delegate to `GF'.
##
BindGlobal( "RingFromFFE", function( gens )
    local F;

    F:= GF( Characteristic( gens ), DegreeFFE( gens ) );
    if ForAll( gens, IsZero ) then
      F:= TrivialSubalgebra( F );
    fi;
    return F;
end );

InstallMethod( RingByGenerators,
    "for a collection of FFE",
    [ IsFFECollection ],
    RingFromFFE );

InstallMethod( RingWithOneByGenerators,
    "for a collection of FFE",
    [ IsFFECollection ],
    RingFromFFE );

InstallMethod( DefaultRingByGenerators,
    "for a collection of FFE",
    [ IsFFECollection and IsList ],
    RingFromFFE );


BindGlobal( "FLMLORFromFFE", function( F, elms )
    if ForAll( elms, IsZero ) then
      return TrivialSubalgebra( F );
    else
      return GF( Characteristic( F ),
                 Lcm( DegreeFFE( elms ), DegreeOverPrimeField( F ) ) );
    fi;
end );

InstallMethod( FLMLORByGenerators,
    "for a field, and a collection of FFE",
    IsIdenticalObj,
    [ IsField and IsFFECollection, IsFFECollection ], 0,
    FLMLORFromFFE );

InstallMethod( FLMLORWithOneByGenerators,
    "for a field, and a collection of FFE",
    IsIdenticalObj,
    [ IsField and IsFFECollection, IsFFECollection ], 0,
    FLMLORFromFFE );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <ffelist> )
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for a collection of FFEs",
    [ IsFFECollection ],
    ffelist -> ForAll( ffelist, x -> not IsZero( x ) ) );


#############################################################################
##
#M  AsInternalFFE( <internal ffe> )
##
InstallMethod( AsInternalFFE, [IsFFE and IsInternalRep],
        x->x);

#############################################################################
##
#M  AsInternalFFE( <non-ffe> )
##
InstallOtherMethod( AsInternalFFE, [IsObject],
        function(x)
    if not IsFFE(x) then
        return fail;
    else
        TryNextMethod();
    fi;
end);

#############################################################################
##
#M  RootFFE( <z>, <k> )
##
InstallMethod(RootFFE,"use field order",IsCollsElmsX,
  [IsField,IsFFE,IsPosInt],0,
function(F,z,k)
  return RootFFE(Size(F),z,k);
end);

InstallOtherMethod(RootFFE,"use LogFFE",true,[IsPosInt,IsFFE,IsPosInt],
function(q,z,k)
local e,m,p,a;
  if IsZero(z) or IsOne(z) then return z;fi;
  m:=q-1;
  e:=LogFFE(z,Z(q));
  p:=GcdInt(m,e); #power for subgroup it is in
  k:=k mod m;
  a:=GcdInt(m,k); # power for subgroup we want
  if p mod a<>0 then
    return fail; # element does not lie in subgroup of a-th powers
  fi;
  # k/a is coprime to order of elts in subgroup and elt is an a-th power
  a:=(e*(a/k mod (m/p))/a mod m);
  return Z(q)^a;
end);

InstallOtherMethod(RootFFE,"without field",true,
  [IsFFE,IsPosInt],0,
function(z,k)
  return RootFFE(Characteristic(z)^DegreeFFE(z),z,k);
end);
