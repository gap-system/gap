#############################################################################
##
#W  zmodnz.gi                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains methods for the elements of the rings $Z / n Z$
##  in their representation via the residue modulo $n$.
##  This residue is always assumed to be in the range $[ 0, 1 ..., n-1 ]$.
##
##  Each ring $\Z / n \Z$ contains the whole elements family if $n$ is not a
##  prime, and is embedded into the family of finite field elements of
##  characteristic $n$ otherwise.
##
##  If $n$ is not a prime then an external representation of elements is
##  defined.  For the element $k + n \Z$, it is the representative $k$,
##  chosen such that $0 \leq k \leq n - 1$.
##
##  The ordering of elements for nonprime $n$ is defined by the ordering of
##  the representatives.
##  For primes smaller than 'MAXSIZE_GF_INTERNAL', the ordering of the
##  internal finite field elements must be respected, for larger primes
##  again the ordering of representatives is chosen.
##
Revision.zmodnz_gi :=
    "@(#)$Id$";


#############################################################################
##
#V  ZNZ_PURE_TYPE
##
##  position where the type of an object in $\Z \bmod n \Z$
##  stores the default type
##
ZNZ_PURE_TYPE := POS_FIRST_FREE_TYPE;


#############################################################################
##
#R  IsModulusRep( <obj> )
##
##  Objects in this representation are defined by a single data entry, an
##  integer at first position.
##
IsModulusRep := NewRepresentation( "IsModulusRep", IsPositionalObjectRep,
    [ 1 ] );


#############################################################################
##
##  1. The elements
##


#############################################################################
##
#M  ZmodnZObj( <Fam>, <residue> )
##
InstallMethod( ZmodnZObj,
    "method for family of elements in Z/nZ (nonprime), and integer",
    true,
    [ IsZmodnZObjNonprimeFamily, IsInt ], 0,
    function( Fam, residue )
    return Objectify( Fam!.typeOfZmodnZObj, [ residue mod Fam!.modulus ] );
    end );

InstallOtherMethod( ZmodnZObj,
    "method for family of FFE elements, and integer",
    true,
    [ IsFFEFamily, IsInt ], 0,
    function( Fam, residue )
    return Objectify( Fam!.typeOfZmodnZObj,
                      [ residue mod Characteristic( Fam ) ] );
    end );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <residue> )
##
##  Note that finite field elements do not have an external representation.
##
InstallMethod( ObjByExtRep,
    "method for family of elements in Z/nZ (nonprime), and integer",
    true,
    [ IsZmodnZObjNonprimeFamily, IsInt ], 0,
    function( Fam, residue )
    return ZmodnZObj( Fam, residue mod Fam!.modulus );
    end );


#############################################################################
##
#M  ExtRepOfObj( <obj> )
##
InstallMethod( ExtRepOfObj,
    "method for element in Z/nZ (ModulusRep, nonprime)",
    true,
    [ IsZmodnZObjNonprime and IsModulusRep ], 0,
    obj -> obj![1] );


#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . .  for element in Z/nZ (ModulusRep)
##
InstallMethod( PrintObj,
    "method for element in Z/nZ (ModulusRep)",
    IsZmodnZObjNonprimeFamily,
    [ IsZmodnZObj and IsModulusRep ], 0,
    function( x )
    Print( "ZmodnZObj( ", x![1], ", ", DataType( TypeObj( x ) ), " )" );
    end );

InstallMethod( PrintObj,
    "method for element in Z/pZ (ModulusRep)",
    true,
    [ IsZmodpZObj and IsModulusRep ], 0,
    function( x )
    Print( "ZmodpZObj( ", x![1], ", ", Characteristic( x ), " )" );
    end );


#############################################################################
##
#M  \=( <x>, <y> )
#M  \<( <x>, <y> )
##
InstallMethod( \=,
    "method for two elements in Z/nZ (ModulusRep)",
    IsIdentical,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \=,
    "method for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdentical,
    [ IsZmodpZObj and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y )
    return DegreeFFE( y ) = 1 and x![1] = IntFFE( y );
    end );

InstallMethod( \=,
    "method for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsZmodpZObj and IsModulusRep ], 0,
    function( x, y )
    return DegreeFFE( x ) = 1 and y![1] = IntFFE( x );
    end );

InstallMethod( \<,
    "method for two elements in Z/nZ (ModulusRep, nonprime)",
    IsIdentical,
    [ IsZmodnZObjNonprime and IsModulusRep,
      IsZmodnZObjNonprime and IsModulusRep ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \<,
    "method for two elements in Z/pZ (ModulusRep, large)",
    IsIdentical,
    [ IsZmodpZObjLarge and IsModulusRep,
      IsZmodpZObjLarge and IsModulusRep ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \<,
    "method for two elements in Z/pZ (ModulusRep, small)",
    IsIdentical,
    [ IsZmodpZObjSmall and IsModulusRep,
      IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y )
    local p, r;      # characteristic and primitive root
    if x![1] = 0 then
      return y![1] <> 0;
    elif y![1] = 0 then
      return false;
    else
      p:= Characteristic( x );
      r:= PrimitiveRootMod( p );
      return LogMod( x![1], r, p ) < LogMod( y![1], r, p );
    fi;
    end );

InstallMethod( \<,
    "method for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdentical,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y )
    return x![1] * One( Z( Characteristic( x ) ) ) < y;
    end );

InstallMethod( \<,
    "method for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y )
    return x < y![1] * One( Z( Characteristic( y ) ) );
    end );


#############################################################################
##
#M  \+( <x>, <y> )
#M  \-( <x>, <y> )
#M  \*( <x>, <y> )
#M  \/( <x>, <y> )
#M  \^( <x>, <n> )
##
##  The result of an arithmetic operation between two 'ZmodnZObj' is again a
##  'ZmodnZObj'.
##  The result of an arithmetic operation between a 'ZmodnZObj' and an
##  integer is a 'ZmodnZObj'.
##  The result of an arithmetic operation between a 'ZmodpZObj' and an
##  internal FFE is an internal FFE.
##
InstallMethod( \+,
    "method for two elements in Z/nZ (ModulusRep)",
    IsIdentical,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] + y![1] ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \+,
    "method for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] + y ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \+,
    "method for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
                      [ ( x + y![1] ) mod DataType( TypeObj( y ) ) ] );
    end );

InstallMethod( \+,
    "method for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdentical,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] + y; end );

InstallMethod( \+,
    "method for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x + y![1]; end );

InstallMethod( \-,
    "method for two elements in Z/nZ (ModulusRep)",
    IsIdentical,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] - y![1] ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \-,
    "method for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] - y ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \-,
    "method for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
                      [ ( x - y![1] ) mod DataType( TypeObj( y ) ) ] );
    end );

InstallMethod( \-,
    "method for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdentical,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] - y; end );

InstallMethod( \-,
    "method for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x - y![1]; end );

InstallMethod( \*,
    "method for two elements in Z/nZ (ModulusRep)",
    IsIdentical,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] * y![1] ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \*,
    "method for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] * y ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \*,
    "method for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
                      [ ( x * y![1] ) mod DataType( TypeObj( y ) ) ] );
    end );

InstallMethod( \*,
    "method for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdentical,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] * y; end );

InstallMethod( \*,
    "method for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x * y![1]; end );

InstallMethod( \/,
    "method for two elements in Z/nZ (ModulusRep)",
    IsIdentical,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    # Avoid to touch the rational arithmetics.
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                 [ QuotientMod( x![1], y![1], DataType( TypeObj( x ) ) ) ] );
    end );

InstallMethod( \/,
    "method for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    # Avoid to touch the rational arithmetics.
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                     [ QuotientMod( x![1], y, DataType( TypeObj( x ) ) ) ] );
    end );

InstallMethod( \/,
    "method for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    # Avoid to touch the rational arithmetics.
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
                     [ QuotientMod( x, y![1], DataType( TypeObj( y ) ) ) ] );
    end );

InstallMethod( \/,
    "method for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdentical,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] / y; end );

InstallMethod( \/,
    "method for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdentical,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x / y![1]; end );

InstallMethod( \^,
    "method for element in Z/nZ (ModulusRep), and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, n )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                  [ PowerModInt( x![1], n, DataType( TypeObj( x ) ) ) ] );
    end );


#############################################################################
##
#M  Zero( <elm> ) . . . . . . . . . . . . . . . . . . . . . for 'IsZmodnZObj'
##
InstallMethod( Zero,
    "method for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj ], 0,
    elm -> ZmodnZObj( FamilyObj( elm ), 0 ) );


#############################################################################
##
#M  AdditiveInverse( <elm> )  . . . . . . . . . . . . . . . for 'IsZmodnZObj'
##
InstallMethod( AdditiveInverse,
    "method for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj and IsModulusRep ], 0,
    elm -> ZmodnZObj( FamilyObj( elm ), -elm![1] ) );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . . . . . for 'IsZmodnZObj'
##
InstallMethod( One,
    "method for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj ], 0,
    elm -> ZmodnZObj( FamilyObj( elm ), 1 ) );


#############################################################################
##
#M  Inverse( <elm> )  . . . . . . . . . . . . . . . . . . . for 'IsZmodnZObj'
##
InstallMethod( Inverse,
    "method for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj and IsModulusRep ], 0,
    function( elm )
    local modulus;
    modulus:= QuotientMod( 1, elm![1], FamilyObj( elm )!.modulus );
    if modulus <> fail then
      modulus:= ZmodnZObj( FamilyObj( elm ), modulus );
    fi;
    return modulus;
    end );


#############################################################################
##
#M  DegreeFFE( <obj> )  . . . . . . . . . . . . . . . . . . for 'IsZmodpZObj'
##
InstallMethod( DegreeFFE,
    "method for element in Z/pZ (ModulusRep)",
    true,
    [ IsZmodpZObj and IsModulusRep ], 0,
    z -> 1 );


#############################################################################
##
#M  Int( <obj> )  . . . . . . . . . . . . . . . . . . . . . for 'IsZmodnZObj'
##
InstallMethod( Int,
    "method for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj and IsModulusRep ], 0,
    z -> z![1] );


#############################################################################
##
##  2. The collections
##


#############################################################################
##
#M  PrintObj( <R> ) . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( PrintObj,
    "method for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], SUM_FLAGS,
    function( obj )
    Print( "(Integers mod ", Size( obj ), ")" );
    end );


#############################################################################
##
#M  AsListSorted( <R> ) . . . . . . . . . . . .  set of elements of Z mod n Z
#M  AsList( <R> ) . . . . . . . . . . . . . . .  set of elements of Z mod n Z
##
InstallMethod( AsList,
    "method for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    function( R )
    local F;
    F:= ElementsFamily( FamilyObj( R ) );
    F:= List( [ 0 .. Size( R ) - 1 ], x -> ZmodnZObj( F, x ) );
    SetAsListSorted( R, F );
    return F;
    end );

InstallMethod( AsListSorted,
    "method for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    function( R )
    local F;
    F:= ElementsFamily( FamilyObj( R ) );
    return List( [ 0 .. Size( R ) - 1 ], x -> ZmodnZObj( F, x ) );
    end );


#############################################################################
##
#M  Random( <R> ) . . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( Random,
    "method for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    R -> ZmodnZObj( ElementsFamily( FamilyObj( R ) ),
                    Random( [ 0 .. Size( R ) - 1 ] ) ) );


#############################################################################
##
#M  Size( <R> ) . . . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( Size,
    "method for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    R -> ElementsFamily( FamilyObj( R ) )!.modulus );


#############################################################################
##
#M  Units( <R> )  . . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( Units,
    "method for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing ], 0,
    function( R )
    local F;
    F:= ElementsFamily( FamilyObj( R ) );
    return List( PrimeResidues( Size( R ) ), x -> ZmodnZObj( F, x ) );
    end );


#############################################################################
##
#R  IsZmodnZEnumeratorRep( <R> )
##
IsZmodnZEnumeratorRep := NewRepresentation( "ZmodnZEnumerator",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "size", "type" ] );


#############################################################################
##
#M  Enumerator( <R> )  . . . . . . . . . . . . . . . . enumerator for Z / n Z
##
InstallMethod( \[\],
    "method for enumerator of full ring Z/nZ, and pos. integer",
    true,
    [ IsList and IsZmodnZEnumeratorRep, IsPosRat and IsInt ], 0,
    function( enum, nr )
    if nr <= enum!.size then
      return Objectify( enum!.type, [ nr - 1 ] );
    else
      Error( "<nr> is too large" );
    fi;
    end );

InstallMethod( Position,
    "method for enumerator of full ring Z/nZ, and element",
    true,
    [ IsZmodnZEnumeratorRep, IsZmodnZObj and IsModulusRep, IsZeroCyc ], 0,
    function( enum, elm, zero )
    if IsCollsElms( FamilyObj( enum ), FamilyObj( elm ) ) then
      return elm![1] + 1;
    else;
      return fail;
    fi;
    end );

InstallMethod( Enumerator,
    "method for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], SUM_FLAGS,
    function( R )
    local enum;
    enum:= Objectify( NewType( FamilyObj( R ),
                                   IsList
                               and IsSSortedList
                               and IsZmodnZEnumeratorRep ),
                rec(
                     size:= Size( R ),
                     type:= ElementsFamily( FamilyObj( R ) )!.typeOfZmodnZObj
                    ) );
    SetUnderlyingCollection( enum, R );
    return enum;
    end );


#############################################################################
##
#M  SquareRoots( <F>, <obj> )
##
##  (is used in the implementation of Dixon's algorithm ...)
##
InstallMethod( SquareRoots,
    "method for prime field and object in Z/pZ",
    IsCollsElms,
    [ IsField and IsPrimeField, IsZmodpZObj and IsModulusRep ], 0,
    function( F, obj )
    F:= FamilyObj( obj );
    return List( RootsMod( obj![1], 2, Characteristic( obj ) ),
                 x -> ZmodnZObj( F, x ) );
    end );


#############################################################################
##
#F  ZmodpZ( <p> ) . . . . . . . . . . . . . . .  construct 'Integers mod <p>'
#F  ZmodpZNC( <p> ) . . . . . . . . . . . . . .  construct 'Integers mod <p>'
##
ZmodpZ := function( p )
    if not IsPrimeInt( p ) then
      Error( "<p> must be a prime" );
    fi;
    return ZmodpZNC( p );
end;

ZmodpZNC := function( p )

    local pos, F;

    # Check whether this has been stored already.
    pos:= Position( Z_MOD_NZ[1], p );
    if pos = fail then

      # Get the family of element objects of our ring.
      F:= FFEFamily( p );

      # Make the domain.
      F:= FieldOverItselfByGenerators( [ ZmodnZObj( F, 1 ) ] );
      SetIsPrimeField( F, true );

      # Store the field.
      Add( Z_MOD_NZ[1], p );
      Add( Z_MOD_NZ[2], F );
      SortParallel( Z_MOD_NZ[1], Z_MOD_NZ[2] );

    else
      F:= Z_MOD_NZ[2][ pos ];
    fi;

    # Return the field.
    return F;
end;


#############################################################################
##
#F  ZmodnZ( <n> ) . . . . . . . . . . . . . . .  construct 'Integers mod <n>'
##
ZmodnZ := function( n )

    local pos,
          F,
          R;

    if not IsInt( n ) or n <= 0 then
      Error( "<n> must be a positive integer" );
    elif IsPrimeInt( n ) then
      return ZmodpZNC( n );
    fi;

    # Check whether this has been stored already.
    pos:= Position( Z_MOD_NZ[1], n );
    if pos = fail then

      # Construct the family of element objects of our ring.
      F:= NewFamily( Concatenation( "Zmod", String( n ) ),
                     IsZmodnZObj,
                     IsZmodnZObjNonprime );

      # Install the data.
      F!.modulus:= n;

      # Store the objects type.
      F!.typeOfZmodnZObj:= NewType( F,     IsZmodnZObjNonprime
                                       and IsModulusRep );
      SetDataType( F!.typeOfZmodnZObj, n );
      F!.typeOfZmodnZObj![ ZNZ_PURE_TYPE ]:= F!.typeOfZmodnZObj;

      # Make the domain.
      R:= RingWithOneByGenerators( [ ZmodnZObj( F, 1 ) ] );
      SetIsWholeFamily( R, true );

      # Store the ring.
      Add( Z_MOD_NZ[1], n );
      Add( Z_MOD_NZ[2], R );
      SortParallel( Z_MOD_NZ[1], Z_MOD_NZ[2] );

    else
      R:= Z_MOD_NZ[2][ pos ];
    fi;

    # Return the ring.
    return R;
end;


#############################################################################
##
#M  \mod( Integers, <n> )
##
InstallMethod( \mod,
    "method for 'Integers', and positive integers",
    true,
    [ IsIntegers, IsPosRat and IsInt ], 0,
    function( Integers, n ) return ZmodnZ( n ); end );


#############################################################################
##
#E  zmodnz.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



