#############################################################################
##
#W  ffe.gi                      GAP library                     Werner Nickel
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for 'FFE's.
##  Note that we must distinguish finite fields and fields that consist of
##  'FFE's.
##  (The image of the natural embedding of the field 'GF(<q>)' into a field
##  of rational functions is of course a finite field but its elements are
##  not 'FFE's since this would be a property given by their family.)
##
##  Special methods for (elements of) general finite fields can be found in
##  the file 'fieldfin.gi'.
##
##  The implementation of elements of rings 'Integers mod <n>' can be found
##  in the file 'zmodnz.gi'.
##
Revision.ffe_gi :=
    "@(#)$Id$";


#############################################################################
##
##  DegreeFFE( <vector> )
##
InstallOtherMethod( DegreeFFE, true, [ IsRowVector and IsFFECollection ], 0,
    function( list )
    local deg, i;
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
#F  FFEFamily( <p> )
##
FFEFamily := function( p )
    local F;
    if not IsInt( p ) or not IsPosRat( p ) then
      Error( "<p> must be a positive integer" );
    elif p in FAMS_FFE_EXT[1] then

      F:= FAMS_FFE_EXT[2][ PositionSorted( FAMS_FFE_EXT[1], p ) ];

    else

      if not IsPrimeInt( p ) then

        Error( "<p> must be a prime" );

      elif MAXSIZE_GF_INTERNAL < p then

        F:= NewFamily( "FFEFamily", IsFFE );
        SetCharacteristic( F, p );

        # Store the kind for the representation of prime field elements
        # via residues.
        F!.kindOfZmodnZObj:= NewKind( F, IsZmodpZObjLarge and IsModulusRep );
        F!.kindOfZmodnZObj![3]:= p;
        F!.kindOfZmodnZObj![4]:= F!.kindOfZmodnZObj;

        SetOne(  F, ZmodnZObj( F, 1 ) );
        SetZero( F, ZmodnZObj( F, 0 ) );

      else

        KIND_FFE( p );
        F:= FAMS_FFE[p];

        # Store the kind for the representation of prime field elements
        # via residues.
        F!.kindOfZmodnZObj:= NewKind( F, IsZmodpZObjSmall and IsModulusRep );
        F!.kindOfZmodnZObj![3]:= p;
        F!.kindOfZmodnZObj![4]:= F!.kindOfZmodnZObj;

        SetOne(  F, Z(p)^0 );
        SetZero( F, 0*Z(p) );

      fi;

      # The whole family is a unique factorisation domain.
      SetIsUFDFamily( F, true );

      Add( FAMS_FFE_EXT[1], p );
      Add( FAMS_FFE_EXT[2], F );
      SortParallel( FAMS_FFE_EXT[1], FAMS_FFE_EXT[2] );

    fi;
    return F;
end;


#############################################################################
##
#M  Zero( <ffe-family> )
##
InstallOtherMethod( Zero,
    true,
    [ IsFFEFamily ],
    0,

function( fam )
    return 0*Z(Characteristic(fam));
end );


#############################################################################
##
#M  One( <ffe-family> )
##
InstallOtherMethod( One,
    true,
    [ IsFFEFamily ],
    0,

function( fam )
    return Z(Characteristic(fam))^0;
end );


#############################################################################
##
#F  LargeGaloisField( <p>^<n> )
#F  LargeGaloisField( <p>, <n> )
##
#T other construction possibilities?
##
LargeGaloisField := function( arg )

    local p, d;

    # if necessary split the arguments
    if Length( arg ) = 1 and IsInt( arg[1] ) and 0 < arg[1] then

        # 'LargeGaloisField( p^d )'
        p := SmallestRootInt( arg[1] );
        d := LogInt( arg[1], p );

    elif Length( arg ) = 2 then
        p := arg[1];
        d := arg[2];
    else
        Error( "usage: LargeGaloisField( <subfield>, <extension> )" );
    fi;

    if IsPrimeInt( p ) and d = 1 then
      return ZmodpZNC( p );
    else
      Error( "sorry, large non-prime fields are not yet implemented" );
    fi;
end;


#############################################################################
##
#F  GaloisField( <p>^<d> )  . . . . . . . . . .  create a finite field object
#F  GaloisField( <p>, <d> )
#F  GaloisField( <subfield>, <d> )
#F  GaloisField( <p>, <pol> )
#F  GaloisField( <subfield>, <pol> )
##
GaloisField := function ( arg )

    local F,         # the field, result
          p,         # characteristic
          d,         # degree over the prime field
          subfield,  # left acting domain of the field under construction
          B;         # basis of the extension

    # if necessary split the arguments
    if Length( arg ) = 1 and IsInt( arg[1] ) and 0 < arg[1] then

        # 'GF( p^d )'
        p := SmallestRootInt( arg[1] );
        d := LogInt( arg[1], p );

    elif Length( arg ) = 2 then
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

        # 'GF( p, d )' for prime 'p'
        if MAXSIZE_GF_INTERNAL < p^d then
          return LargeGaloisField( p, d );
        fi;

      # if the extension is given by an irreducible polynomial
      elif     IsUnivariateLaurentPolynomial( d )
           and DegreeFFE( d.coefficients ) = 1  then

        # 'GF( p, <pol> )' for prime 'p'
        return FieldExtension( GaloisField( p, 1 ), d );

      # if the extension is given by coefficients of an irred. polynomial
      elif IsHomogeneousList( d )  and DegreeFFE( d ) = 1  then

        Error( "univ. pol. ..." );
#T !!
        return FieldExtension( GaloisField( p, 1 ),
                               UnivariatePolynomial( GaloisField(p,1), d ) );

      # if a basis for the extension is given
      elif IsHomogeneousList( d ) then

#T The construction of a field together with a basis is obsolete.
#T One should construct the basis explicitly.
        # 'GF( p, <basisvectors> )' for prime 'p'
        F := GaloisField( GaloisField( p, 1 ), Length( d ) );

        # Check that the vectors in 'd' really form a basis,
        # and construct the basis.
        B:= BasisByGenerators( F, d );
        if B = fail then
          Error( "<extension> is not linearly independent" );
        fi;

        # Note that 'F' is *not* the field stored in the global list!
        SetBasisOfDomain( F, B );
        return F;

      fi;

    # if the subfield is given by a finite field
    elif IsField( p ) then

      subfield:= p;
      p:= Characteristic( subfield );

      # if the degree of the extension is given
      if   IsInt( d )  then

        if MAXSIZE_GF_INTERNAL < p^d then
          return LargeGaloisField( p, d );
        fi;

        d:= d * DegreeOverPrimeField( subfield );

      # if the extension is given by coefficients of an irred. polynomial
#T should be obsolete!
      elif     IsHomogeneousList( d )
           and DegreeOverPrimeField( subfield ) mod DegreeFFE( d ) = 0 then

        Error( "univ. pol. ..." );
#T !!
        return FieldExtension( subfield,
                               UnivariatePolynomial( subfield, d ) );

      # if the extension is given by an irreducible polynomial
      elif     IsUnivariateLaurentPolynomial( d )
           and DegreeOverPrimeField( subfield )
                                     mod DegreeFFE( d.coefficients ) = 0 then
#T DegreeVecFFE ?
#T polynomial!

        return FieldExtension( subfield, d );

      # if a basis for the extension is given
#T The construction of a field together with a basis is obsolete.
      elif IsHomogeneousList( d ) then

        # 'GF( <subfield>, <basisvectors> )'
        F := GaloisField( subfield, Length( d ) );

        # Check that the vectors in 'd' really form a basis,
        # and construct the basis.
        B:= BasisByGenerators( F, d );
        if B = fail then
          Error( "<extension> is not linearly independent" );
        fi;

        # Note that 'F' is *not* the field stored in the global list!
        SetBasisOfDomain( F, B );
        return F;

      # Otherwise we don't know how to handle the extension.
      else
        Error( "<extension> must be a <deg>, <bas>, or <pol>" );
      fi;

    # Otherwise we don't know how to handle the subfield.
    else
      Error( "<subfield> must be a prime or a finite field" );
    fi;

    if IsInt( subfield ) then

      # The standard field is required.  Look whether it is already stored.
      if not IsBound( GALOIS_FIELDS[p] ) then
        GALOIS_FIELDS[p]:= [];
      elif IsBound( GALOIS_FIELDS[p][d] ) then
        return GALOIS_FIELDS[p][d];
      fi;

      # Construct the finite field object.
      if d = 1 then
        F:= FieldOverItselfByGenerators( [ Z(p) ] );
      else
        F:= FieldByGenerators( FieldOverItselfByGenerators( [ Z(p) ] ),
                               [ Z(p^d) ] );
      fi;

      # Store the standard field.
      GALOIS_FIELDS[p][d]:= F;

    else

      # Construct the finite field object.
      F:= FieldByGenerators( subfield, [ Z(p^d) ] );

    fi;

    # Return the finite field.
    return F;
end;

FiniteField := GaloisField;
GF := GaloisField;


#############################################################################
##
#M  FieldExtension( <subfield>, <poly> )
##
InstallOtherMethod( FieldExtension, true,
#T CollPoly
    [ IsField and IsFFECollection, IsUnivariateLaurentPolynomial ], 0,
    function( F, poly )

    local coeffs, p, d, z, r, E;

    coeffs:= ShiftedCoeffs( poly, Valuation( poly ) );
    p:= Characteristic( F );
    d:= ( Length( coeffs ) - 1 ) * DegreeOverPrimeField( F );

    if MAXSIZE_GF_INTERNAL < p^d then
      TryNextMethod();
    fi;

    # Compute a root of the defining polynomial.
    z := Z( p^d );
    r := z;
    while r <> r^0 and ValuePol( coeffs, r ) <> 0 * r  do
      r := r * z;
    od;
    if DegreeFFE( r ) < Length( coeffs ) - 1  then
      Error( "<poly> must be irreducible" );
    fi;

    E:= AsField( F, GF( p, d ) );
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
#M  PrintObj( <F> ) . . . . . . . . . . . . . . . . . print a field of 'FFE's
##
InstallMethod( PrintObj, true, [ IsField and IsFFECollection ], 10,
    function( F )
    if IsPrimeField( F ) then
      Print( "GF(", Characteristic( F ), ")" );
    elif IsPrimeField( LeftActingDomain( F ) ) then
      Print( "GF(", Characteristic( F ),
                    "^", DegreeOverPrimeField( F ), ")" );
    elif F = LeftActingDomain( F ) then
      Print( "FieldOverItselfByGenerators( ",
             GeneratorsOfField( F ), " )" );
    else
      Print( "AsField( ", LeftActingDomain( F ),
             ", GF(", Characteristic( F ),
                      "^", DegreeOverPrimeField( F ), ") )" );
    fi;
    end );
#T or consider how the field was defined ?


#############################################################################
##
#M  \in( <z> ,<F> ) . . . . . . . .  test if an object lies in a finite field
##
InstallMethod( \in, IsElmsColls, [ IsFFE, IsField and IsFFECollection ], 0,
    function ( z, F )
    return DegreeOverPrimeField( F ) mod DegreeFFE( z ) = 0;
    end );


#############################################################################
##
#M  Intersection( <F>, <G> )  . . . . . . . intersection of two finite fields
##
InstallMethod( Intersection2, IsIdentical,
    [ IsField and IsFFECollection, IsField and IsFFECollection ], 0,
    function ( F, G )
    return GF( Characteristic( F ), GcdInt( DegreeOverPrimeField( F ),
                                            DegreeOverPrimeField( G ) ) );
    end );


#############################################################################
##
#M  Conjugates( <F>, <z> ) . . . . . . . conjugates of a finite field element
##
InstallMethod( Conjugates, IsCollsElms,
    [ IsField and IsFinite and IsFFECollection, IsFFE ], 0,
    function ( F, z )
    local   cnjs,       # conjugates of <z> in <F>, result
            ord,        # order of the subfield of <F>
            deg,        # degree of <F> over its subfield
            i;          # loop variable

    # get the order of the subfield and the dimension
    ord := Size( LeftActingDomain( F ) );
    deg := Dimension( F );
    if DegreeOverPrimeField( F ) mod DegreeFFE(z) <> 0  then
        Error("<z> must lie in <F>");
    fi;

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
#F  Norm( <F>, <z> )  . . . . . . . . . . . .  norm of a finite field element
##
InstallMethod( Norm, IsCollsElms,
    [ IsField and IsFinite and IsFFECollection, IsFFE ], 0,
    function ( F, z )
    local   nrm,        # norm of <z> in <F>, result
            ord,        # order of the subfield of <F>
            deg;        # degree of <F> over its subfield

    # get the order of the subfield and the dimension
    ord := Size( LeftActingDomain( F ) );
    deg := Dimension( F );
    if DegreeOverPrimeField( F ) mod DegreeFFE(z) <> 0  then
        Error("<z> must lie in <F>");
    fi;

    # $nrm = \prod_{i=0}^{deg-1}{ z^(ord^i) }
    #      = z ^ {1 + ord + ord^2 + .. + ord^{deg-1}}
    #      = z ^ {(ord^deg-1)/(ord-1)} $
    nrm := z ^ ((ord^deg-1)/(ord-1));

    # return the norm
    return nrm;
    end );

#############################################################################
##
#M  Trace( <F>, <z> ) . . . . . . . . . . . . trace of a finite field element
##
InstallMethod( Trace, IsCollsElms,
    [ IsField and IsFinite and IsFFECollection, IsFFE ], 0,
    function ( F, z )
    local   trc,        # trace of <z> in <F>, result
            ord,        # order of the subfield of <F>
            deg,        # degree of <F> over its subfield
            i;          # loop variable

    # get the order of the subfield and the dimension
    ord := Size( LeftActingDomain( F ) );
    deg := Dimension( F );
    if DegreeOverPrimeField( F ) mod DegreeFFE(z) <> 0  then
        Error("<z> must lie in <F>");
    fi;

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
InstallMethod( Order, true, [ IsFFE and IsInternalRep ], 0,
    function ( z )
    local   ord,        # order of <z>, result
            chr,        # characteristic of <F> (and <z>)
            deg;        # degree of <z> over the primefield

    # compute the order
    if z = 0 * z   then
        ord := 0;
    else
        chr := Characteristic( z );
        deg := DegreeFFE( z );
        ord := (chr^deg-1) / GcdInt( chr^deg-1, LogFFE( z, Z(chr^deg) ) );
    fi;

    # return the order
    return ord;
    end );

#############################################################################
##
#M  SquareRoots( <F>, <z> )
##
InstallMethod( SquareRoots, IsCollsElms,
    [ IsField and IsFFECollection, IsFFE ], 0,
    function( F, z )
    local r;
    if IsZero( z ) then
      return [ z ];
    elif Characteristic( z ) = 2 then

      # unique square root for each element
      r:= PrimitiveRoot( F );
      return [ r ^ ( LogFFE( z, r ) / 2 mod ( Size( F )-1 ) ) ];

    else

      # either two solutions in 'F' or no solution
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
#M  Int( <z> ) . . . . . . . . . convert a finite field element to an integer
##
InstallMethod( Int, true, [ IsFFE and IsInternalRep ], 0, IntFFE );


#############################################################################
##
#M  String( <ffe> ) . . . . . .  convert a finite field element into a string
##
InstallMethod( String, true, [ IsFFE and IsInternalRep ], 0,
    function ( ffe )
    local   str, root;
    if   ffe = 0 * ffe  then
        str := Concatenation("0*Z(",String(Characteristic(ffe)),")");
    else
        str := Concatenation("Z(",String(Characteristic(ffe)));
        if DegreeFFE(ffe) <> 1  then
            str := Concatenation(str,"^",String(DegreeFFE(ffe)));
        fi;
        str := Concatenation(str,")");
        root:= Z( Characteristic( ffe ) ^ DegreeFFE( ffe ) );
        if LogFFE( ffe, root ) <> 1  then
            str := Concatenation(str,"^",String(LogFFE(ffe,root)));
        fi;
    fi;
    ConvertToStringRep( str );
    return str;
    end );


#############################################################################
##
#M  FieldOverItselfByGenerators( <elms> )
##
InstallMethod( FieldOverItselfByGenerators, true, [ IsFFECollection ], 0,
    function( elms )

    local F, d, q;

    F:= Objectify( NewKind( FamilyObj( elms ),
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

    if q < MAXSIZE_GF_INTERNAL then
      SetRootOfDefiningPolynomial( F, Z(q) );
      SetPrimitiveRoot( F, Z(q) );
    fi;

    return F;
    end );


#############################################################################
##
#M  FieldByGenerators( <F>, <elms> )  . . . . . . . . . . field by generators
##
InstallMethod( FieldByGenerators, IsIdentical,
    [ IsFFECollection and IsField, IsFFECollection ], 0,
    function( subfield, gens )

    local F, d, q;

    F := Objectify( NewKind( FamilyObj( gens ),
                             IsField and IsAttributeStoringRep ),
                    rec() );

    d:= DegreeFFE( gens );
    q:= Characteristic( subfield )^d;

    if d mod DegreeOverPrimeField( subfield ) <> 0 then
      Error( "<subfield> must be contained in the field of <gens>" );
    fi;

    SetLeftActingDomain( F, subfield );
    SetIsPrimeField( F, d = 1 );
    SetIsFinite( F, true );
    SetSize( F, q );
    SetGeneratorsOfDivisionRing( F, gens );
    SetGeneratorsOfRing( F, gens );
    SetDegreeOverPrimeField( F, d );
    SetDimension( F, d / DegreeOverPrimeField( subfield ) );

    if q < MAXSIZE_GF_INTERNAL then
      SetRootOfDefiningPolynomial( F, Z(q) );
      SetPrimitiveRoot( F, Z(q) );
    fi;

    return F;
    end );


#############################################################################
##
#M  DefaultFieldByGenerators( <z> ) . . . . . . default field containing ffes
#M  DefaultFieldByGenerators( <F>, <elms> ) . . default field containing ffes
##
InstallMethod( DefaultFieldByGenerators, true,
    [ IsFFECollection and IsList ], 0,
    gens -> GF( Characteristic( gens ), DegreeFFE( gens ) ) );

InstallOtherMethod( DefaultFieldByGenerators, IsIdentical,
    [ IsField and IsFinite, IsFFECollection and IsList ], 0,
    function( F, gens )
    return GF( F, DegreeFFE( gens ) );
    end );


#############################################################################
##
#M  RingByGenerators( <elms> )  . . . . . . . . . . . . .  ring by generators
##
InstallMethod( RingByGenerators, true, [ IsFFECollection ], 0,
    gens -> GF( Characteristic( gens ), DegreeFFE( gens ) ) );


#############################################################################
##
#M  DefaultRingByGenerators( <z> )  . . . . . .  default ring containing ffes
##
InstallMethod( DefaultRingByGenerators, true,
    [ IsFFECollection and IsList ], 0,
    gens -> GF( Characteristic( gens ), DegreeFFE( gens ) ) );


#############################################################################
##
#E  ffe.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



