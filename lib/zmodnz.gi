#############################################################################
##
#W  zmodnz.gi                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
##  For primes smaller than `MAXSIZE_GF_INTERNAL', the ordering of the
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
DeclareSynonym( "ZNZ_PURE_TYPE", POS_FIRST_FREE_TYPE );


#############################################################################
##
#R  IsModulusRep( <obj> )
##
##  Objects in this representation are defined by a single data entry, an
##  integer at first position.
##
DeclareRepresentation( "IsModulusRep", IsPositionalObjectRep, [ 1 ] );


#############################################################################
##
##  1. The elements
##


#############################################################################
##
#M  ZmodnZObj( <Fam>, <residue> )
##
InstallMethod( ZmodnZObj,
    "for family of elements in Z/nZ (nonprime), and integer",
    true,
    [ IsZmodnZObjNonprimeFamily, IsInt ], 0,
    function( Fam, residue )
    return Objectify( Fam!.typeOfZmodnZObj,
                   [ residue mod Fam!.modulus ] );
    end );

InstallOtherMethod( ZmodnZObj,
    "for family of FFE elements, and integer",
    true,
    [ IsFFEFamily, IsInt ], 0,
    function( Fam, residue )
    local p;
    p:= Characteristic( Fam );
    if not IsBound( Fam!.typeOfZmodnZObj ) then

      # Store the type for the representation of prime field elements
      # via residues.
      Fam!.typeOfZmodnZObj:= NewType( Fam,
                                 IsZmodpZObjSmall and IsModulusRep );
      SetDataType( Fam!.typeOfZmodnZObj, p );
      Fam!.typeOfZmodnZObj![ ZNZ_PURE_TYPE ]:= Fam!.typeOfZmodnZObj;

    fi;
    return Objectify( Fam!.typeOfZmodnZObj, [ residue mod p ] );
    end );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <residue> )
##
##  Note that finite field elements do not have an external representation.
##
InstallMethod( ObjByExtRep,
    "for family of elements in Z/nZ (nonprime), and integer",
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
    "for element in Z/nZ (ModulusRep, nonprime)",
    true,
    [ IsZmodnZObjNonprime and IsModulusRep ], 0,
    obj -> obj![1] );


#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . .  for element in Z/nZ (ModulusRep)
##
InstallMethod( PrintObj,
    "for element in Z/nZ (ModulusRep)",
    IsZmodnZObjNonprimeFamily,
    [ IsZmodnZObj and IsModulusRep ], 0,
    function( x )
    Print( "ZmodnZObj( ", x![1], ", ", DataType( TypeObj( x ) ), " )" );
    end );

InstallMethod( PrintObj,
    "for element in Z/pZ (ModulusRep)",
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
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \=,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObj and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y )
    return DegreeFFE( y ) = 1 and x![1] = IntFFE( y );
    end );

InstallMethod( \=,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObj and IsModulusRep ], 0,
    function( x, y )
    return DegreeFFE( x ) = 1 and y![1] = IntFFE( x );
    end );

InstallMethod( \<,
    "for two elements in Z/nZ (ModulusRep, nonprime)",
    IsIdenticalObj,
    [ IsZmodnZObjNonprime and IsModulusRep,
      IsZmodnZObjNonprime and IsModulusRep ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \<,
    "for two elements in Z/pZ (ModulusRep, large)",
    IsIdenticalObj,
    [ IsZmodpZObjLarge and IsModulusRep,
      IsZmodpZObjLarge and IsModulusRep ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \<,
    "for two elements in Z/pZ (ModulusRep, small)",
    IsIdenticalObj,
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
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y )
    return x![1] * One( Z( Characteristic( x ) ) ) < y;
    end );

InstallMethod( \<,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
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
##  The result of an arithmetic operation between two `ZmodnZObj' is again a
##  `ZmodnZObj'.
##  The result of an arithmetic operation between a `ZmodnZObj' and an
##  integer is a `ZmodnZObj'.
##  The result of an arithmetic operation between a `ZmodpZObj' and an
##  internal FFE is an internal FFE.
##
InstallMethod( \+,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] + y![1] ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \+,
    "for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] + y ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \+,
    "for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
                      [ ( x + y![1] ) mod DataType( TypeObj( y ) ) ] );
    end );

InstallMethod( \+,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] + y; end );

InstallMethod( \+,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x + y![1]; end );

InstallMethod( \-,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] - y![1] ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \-,
    "for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] - y ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \-,
    "for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
                      [ ( x - y![1] ) mod DataType( TypeObj( y ) ) ] );
    end );

InstallMethod( \-,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] - y; end );

InstallMethod( \-,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x - y![1]; end );

InstallMethod( \*,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] * y![1] ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \*,
    "for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                      [ ( x![1] * y ) mod DataType( TypeObj( x ) ) ] );
    end );

InstallMethod( \*,
    "for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
                      [ ( x * y![1] ) mod DataType( TypeObj( y ) ) ] );
    end );

InstallMethod( \*,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] * y; end );

InstallMethod( \*,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x * y![1]; end );

InstallMethod( \/,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    # Avoid to touch the rational arithmetics.
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
               [ QuotientMod( Integers, x![1], y![1],
                              DataType( TypeObj( x ) ) ) ] );
    end );

InstallMethod( \/,
    "for element in Z/nZ (ModulusRep) and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, y )
    # Avoid to touch the rational arithmetics.
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
               [ QuotientMod( Integers, x![1], y,
                              DataType( TypeObj( x ) ) ) ] );
    end );

InstallMethod( \/,
    "for integer and element in Z/nZ (ModulusRep)",
    true,
    [ IsInt, IsZmodnZObj and IsModulusRep ], 0,
    function( x, y )
    # Avoid to touch the rational arithmetics.
    return Objectify( TypeObj( y )![ ZNZ_PURE_TYPE ],
               [ QuotientMod( x, y![1],
                              DataType( TypeObj( y ) ) ) ] );
    end );

InstallMethod( \/,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ], 0,
    function( x, y ) return x![1] / y; end );

InstallMethod( \/,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ], 0,
    function( x, y ) return x / y![1]; end );

InstallMethod( \^,
    "for element in Z/nZ (ModulusRep), and integer",
    true,
    [ IsZmodnZObj and IsModulusRep, IsInt ], 0,
    function( x, n )
    return Objectify( TypeObj( x )![ ZNZ_PURE_TYPE ],
                  [ PowerModInt( x![1], n, DataType( TypeObj( x ) ) ) ] );
    end );


#############################################################################
##
#M  ZeroOp( <elm> ) . . . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( ZeroOp,
    "for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj ], 0,
    elm -> ZmodnZObj( FamilyObj( elm ), 0 ) );


#############################################################################
##
#M  AdditiveInverseOp( <elm> )  . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( AdditiveInverseOp,
    "for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj and IsModulusRep ], 0,
    elm -> ZmodnZObj( FamilyObj( elm ), -elm![1] ) );


#############################################################################
##
#M  OneOp( <elm> )  . . . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( OneOp,
    "for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj ], 0,
    elm -> ZmodnZObj( FamilyObj( elm ), 1 ) );


#############################################################################
##
#M  InverseOp( <elm> )  . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( InverseOp,
    "for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj and IsModulusRep ], 0,
    function( elm )
    local modulus;
    modulus:= QuotientMod( Integers, 1, elm![1], FamilyObj( elm )!.modulus );
    if modulus <> fail then
      modulus:= ZmodnZObj( FamilyObj( elm ), modulus );
    fi;
    return modulus;
    end );


#############################################################################
##
#M  DegreeFFE( <obj> )  . . . . . . . . . . . . . . . . . . for `IsZmodpZObj'
##
InstallMethod( DegreeFFE,
    "for element in Z/pZ (ModulusRep)",
    true,
    [ IsZmodpZObj and IsModulusRep ], 0,
    z -> 1 );


#############################################################################
##
#M  LogFFE( <n>, <r> )  . . . . . . . . . . . . . . . . . . for `IsZmodpZObj'
##
InstallMethod( LogFFE,
    "for two elements in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodpZObj and IsModulusRep, IsZmodpZObj and IsModulusRep ], 0,
    function( n, r )
    return LogMod( n![1], r![1], Characteristic( n ) );
    end );


#############################################################################
##
#M  Int( <obj> )  . . . . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( Int,
    "for element in Z/nZ (ModulusRep)",
    true,
    [ IsZmodnZObj and IsModulusRep ], 0,
    z -> z![1] );


#############################################################################
##
##  2. The collections
##


#############################################################################
##
#M  ViewObj( <R> )  . . . . . . . . . . . . . . . . method for full ring Z/nZ
#M  PrintObj( <R> ) . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( ViewObj,
    "for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], SUM_FLAGS,
    function( obj )
    Print( "(Integers mod ", Size( obj ), ")" );
    end );

InstallMethod( PrintObj,
    "for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], SUM_FLAGS,
    function( obj )
    Print( "(Integers mod ", Size( obj ), ")" );
    end );


#############################################################################
##
#M  AsSSortedList( <R> ) . . . . . . . . . . . .  set of elements of Z mod n Z
#M  AsList( <R> ) . . . . . . . . . . . . . . .  set of elements of Z mod n Z
##
InstallMethod( AsList,
    "for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    function( R )
    local F;
    F:= ElementsFamily( FamilyObj( R ) );
    F:= List( [ 0 .. Size( R ) - 1 ], x -> ZmodnZObj( F, x ) );
    SetAsSSortedList( R, F );
    SetIsSSortedList( F, true );
    return F;
    end );

InstallMethod( AsSSortedList,
    "for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    function( R )
    local F;
    F:= ElementsFamily( FamilyObj( R ) );
    F:= List( [ 0 .. Size( R ) - 1 ], x -> ZmodnZObj( F, x ) );
    SetIsSSortedList( F, true );
    return F;
    end );


#############################################################################
##
#M  Random( <R> ) . . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( Random,
    "for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    R -> ZmodnZObj( ElementsFamily( FamilyObj( R ) ),
                    Random( [ 0 .. Size( R ) - 1 ] ) ) );


#############################################################################
##
#M  Size( <R> ) . . . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( Size,
    "for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], 0,
    R -> ElementsFamily( FamilyObj( R ) )!.modulus );


#############################################################################
##
#M  Units( <R> )  . . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( Units,
    "for full ring Z/nZ",
    true,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing ], 0,
    function( R )
    local   G,  gens;
    
    gens := GeneratorsPrimeResidues( Size( R ) ).generators;
    if not IsEmpty( gens )  and  gens[ 1 ] = 1  then
        gens := gens{ [ 2 .. Length( gens ) ] };
    fi;
    gens := Flat( gens ) * One( R );
    G := GroupByGenerators( gens, One( R ) );
    SetIsAbelian( G, true );
    SetIndependentGeneratorsOfAbelianGroup( G, gens );
    SetIsHandledByNiceMonomorphism(G,true);
    return G;
end );

#InstallTrueMethod( IsHandledByNiceMonomorphism,
#        IsGroup and IsZmodnZObjNonprimeCollection );

#############################################################################
##
#M  <res> in <G>  . . . . . . . . . . . for cyclic prime residue class groups
##
InstallMethod( \in,
    "for subgroups of Z/p^aZ, p<>2",
    IsElmsColls,
    [ IsZmodnZObjNonprime, IsGroup and IsZmodnZObjNonprimeCollection ],0,
    function( res, G )
    local   m;

    m := FamilyObj( res )!.modulus;
    res := Int( res );
    if GcdInt( res, m ) <> 1  then
        return false;
    elif m mod 2 <> 0  and  IsPrimePowerInt( m )  then
        return LogMod( res, PrimitiveRootMod( m ), m ) mod
               ( Phi( m ) / Size( G ) ) = 0;
    else
        TryNextMethod();
    fi;
end );


#############################################################################
##
#R  IsZmodnZEnumeratorRep( <R> )
##
DeclareRepresentation( "IsZmodnZEnumeratorRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "size", "type" ] );


#############################################################################
##
#M  Enumerator( <R> )  . . . . . . . . . . . . . . . . enumerator for Z / n Z
##
InstallMethod( \[\],
    "for enumerator of full ring Z/nZ, and pos. integer",
    true,
    [ IsList and IsZmodnZEnumeratorRep, IsPosInt ], 0,
    function( enum, nr )
    if nr <= enum!.size then
      return Objectify( enum!.type, [ nr - 1 ] );
    else
      Error( "<nr> is too large" );
    fi;
    end );

InstallMethod( Position,
    "for enumerator of full ring Z/nZ, and element",
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
    "for full ring Z/nZ",
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
    "for prime field and object in Z/pZ",
    IsCollsElms,
    [ IsField and IsPrimeField, IsZmodpZObj and IsModulusRep ], 0,
    function( F, obj )
    F:= FamilyObj( obj );
    return List( RootsMod( obj![1], 2, Characteristic( obj ) ),
                 x -> ZmodnZObj( F, x ) );
    end );


#############################################################################
##
#F  ZmodpZ( <p> ) . . . . . . . . . . . . . . .  construct `Integers mod <p>'
#F  ZmodpZNC( <p> ) . . . . . . . . . . . . . .  construct `Integers mod <p>'
##
InstallGlobalFunction( ZmodpZ, function( p )
    if not IsPrimeInt( p ) then
      Error( "<p> must be a prime" );
    fi;
    return ZmodpZNC( p );
end );

InstallGlobalFunction( ZmodpZNC, function( p )

    local pos, F;

    # Check whether this has been stored already.
    pos:= Position( Z_MOD_NZ[1], p );
    if pos = fail then

      # Get the family of element objects of our ring.
      F:= FFEFamily( p );

      # Make the domain.
      F:= FieldOverItselfByGenerators( [ ZmodnZObj( F, 1 ) ] );
      SetIsPrimeField( F, true );
      SetIsWholeFamily( F, false );

      # Store the field.
      Add( Z_MOD_NZ[1], p );
      Add( Z_MOD_NZ[2], F );
      SortParallel( Z_MOD_NZ[1], Z_MOD_NZ[2] );

    else
      F:= Z_MOD_NZ[2][ pos ];
    fi;

    # Return the field.
    return F;
end );


#############################################################################
##
#F  ZmodnZ( <n> ) . . . . . . . . . . . . . . .  construct `Integers mod <n>'
##
InstallGlobalFunction( ZmodnZ, function( n )

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
                     IsZmodnZObjNonprime and CanEasilySortElements
                                         and IsNoImmediateMethodsObject,
		     CanEasilySortElements);

      # Install the data.
      F!.modulus:= n;

      # Store the objects type.
      F!.typeOfZmodnZObj:= NewType( F,     IsZmodnZObjNonprime
                                       and IsModulusRep );
      SetDataType( F!.typeOfZmodnZObj, n );
      F!.typeOfZmodnZObj![ ZNZ_PURE_TYPE ]:= F!.typeOfZmodnZObj;

      # as n is no prime, the family is no UFD
      SetIsUFDFamily(F,false);

      # Make the domain.
      R:= RingWithOneByGenerators( [ ZmodnZObj( F, 1 ) ] );
      SetIsWholeFamily( R, true );
      SetZero(F,Zero(R));
      SetOne(F,One(R));

      # Store the ring.
      Add( Z_MOD_NZ[1], n );
      Add( Z_MOD_NZ[2], R );
      SortParallel( Z_MOD_NZ[1], Z_MOD_NZ[2] );

    else
      R:= Z_MOD_NZ[2][ pos ];
    fi;

    # Return the ring.
    return R;
end );


#############################################################################
##
#M  \mod( Integers, <n> )
##
InstallMethod( \mod,
    "for `Integers', and positive integers",
    true,
    [ IsIntegers, IsPosInt ], 0,
    function( Integers, n ) return ZmodnZ( n ); end );


#############################################################################
##
#M  ModulusOfZmodnZObj( <obj> )
##
##  For an element <obj> in a residue class ring of integers modulo $n$
##  (see~"IsZmodnZObj"), `ModulusOfZmodnZObj' returns the positive integer
##  $n$.
##
InstallMethod( ModulusOfZmodnZObj,
    "for element in Z/nZ (nonprime)",
    true,
    [ IsZmodnZObjNonprime ], 0,
    res -> FamilyObj( res )!.modulus );

InstallMethod( ModulusOfZmodnZObj,
    "for element in Z/pZ (prime)",
    true,
    [ IsZmodpZObj ], 0,
    Characteristic );

InstallOtherMethod( ModulusOfZmodnZObj,
    "for FFE",
    true,
    [ IsFFE ], 0,
    function( ffe )
    if DegreeFFE( ffe ) = 1 then
      return Characteristic( ffe );
    else
      return fail;
    fi;
    end );


#############################################################################
##
#M  DefaultRingByGenerators( <zmodnzcoll> )
##
InstallMethod( DefaultRingByGenerators,
    "for a collection over a ring Z/nZ",
    [ IsZmodnZObjNonprimeCollection ],
    C -> ZmodnZ( ModulusOfZmodnZObj( Representative( C ) ) ) );


#############################################################################
##
#M  FieldOfMatrixGroup( <zmodnz-mat-grp> )
##
##  Is it possible to avoid this very special method?
##  In fact the whole stuff in the library is not very clean,
##  as the ``generic'' method for matrix groups claims to be allowed to
##  call `Field'.
##  The bad name of the function (`FieldOfMatrixGroup') may be the reason
##  for this bad behaviour.
##  Do we need to distinguish matrix groups over fields and rings that aren't
##  fields, and change the generic `FieldOfMatrixGroup' method accordingly?
##
InstallMethod( FieldOfMatrixGroup,
    "for a matrix group over a ring Z/nZ",
    [ IsMatrixGroup and IsZmodnZObjNonprimeCollCollColl ],
    G -> ZmodnZ( ModulusOfZmodnZObj( Representative( G )[1][1] ) ) );


#############################################################################
##
#E

