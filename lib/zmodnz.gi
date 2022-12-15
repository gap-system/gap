#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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

#T for small residue class rings, avoid constructing new objects by
#T keeping an elements list, and change the constructor such that the
#T object in question is just fetched
#T (check performance for matrices over Z/4Z, say)


#############################################################################
##
#R  IsModulusRep( <obj> )
##
##  Objects in this representation are defined by a single data entry, an
##  integer at first position.
##
if IsHPCGAP then
DeclareRepresentation( "IsModulusRep", IsReadOnlyPositionalObjectRep, [ 1 ] );
else
DeclareRepresentation( "IsModulusRep", IsPositionalObjectRep, [ 1 ] );
fi;


#############################################################################
##
##  1. The elements
##


#############################################################################
##
#M  ZmodnZObj( <Fam>, <residue> )
#M  ZmodnZObj( <residue>, <modulus> )
##
InstallMethod( ZmodnZObj,
    "for family of elements in Z/nZ (nonprime), and integer",
    [ IsZmodnZObjNonprimeFamily, IsInt ],
    function( Fam, residue )
    return Objectify( Fam!.typeOfZmodnZObj,
                   [ residue mod Fam!.Characteristic ] );
    end );

InstallOtherMethod( ZmodnZObj,
    "for family of elements in Z/nZ (nonprime), and rational",
    [ IsZmodnZObjNonprimeFamily, IsRat ],
    function( Fam, val )
    local m;
    m:= Fam!.Characteristic;
    if GcdInt( DenominatorRat( val ), m ) <> 1 then
      return fail;
    fi;
    return Objectify( Fam!.typeOfZmodnZObj, [ val mod m ] );
    end );

InstallOtherMethod( ZmodnZObj,
    "for family of FFE elements, and integer",
    [ IsFFEFamily, IsInt ],
    function( Fam, residue )
    local p;
    p:= Fam!.Characteristic;
    if not IsBound( Fam!.typeOfZmodnZObj ) then

      # Store the type for the representation of prime field elements
      # via residues.
      Fam!.typeOfZmodnZObj:= NewType( Fam,
                                 IsZmodpZObjSmall and IsModulusRep );

    fi;
    return Objectify( Fam!.typeOfZmodnZObj, [ residue mod p ] );
    end );

InstallMethod( ZmodnZObj,
    "for a positive integer, and an integer -- check small primes",
    [ IsInt, IsPosInt ],
    function( residue, n )
    if n in PRIMES_COMPACT_FIELDS then
      return residue*Z(n)^0;
    fi;
    return ZmodnZObj( ElementsFamily( FamilyObj( ZmodnZ( n ) ) ), residue );
    end );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <residue> )
##
##  Note that finite field elements do not have an external representation.
##
InstallMethod( ObjByExtRep,
    "for family of elements in Z/nZ (nonprime), and integer",
    [ IsZmodnZObjNonprimeFamily, IsInt ],
    function( Fam, residue )
    return ZmodnZObj( Fam, residue );
    end );


#############################################################################
##
#M  ExtRepOfObj( <obj> )
##
InstallMethod( ExtRepOfObj,
    "for element in Z/nZ (ModulusRep, nonprime)",
    [ IsZmodnZObjNonprime and IsModulusRep ],
    obj -> obj![1] );


#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . .  for element in Z/nZ (ModulusRep)
##
InstallMethod( PrintObj,
    "for element in Z/nZ (ModulusRep)",
    IsZmodnZObjNonprimeFamily,
    [ IsZmodnZObj and IsModulusRep ],
    function( x )
    Print( "ZmodnZObj( ", x![1], ", ", FamilyObj( x )!.Characteristic, " )" );
    end );

InstallMethod( PrintObj,
    "for element in Z/pZ (ModulusRep)",
    [ IsZmodpZObj and IsModulusRep ],
    function( x )
    Print( "ZmodpZObj( ", x![1], ", ", FamilyObj( x )!.Characteristic, " )" );
    end );

InstallMethod( String,
    "for element in Z/nZ (ModulusRep)",
    IsZmodnZObjNonprimeFamily,
    [ IsZmodnZObj and IsModulusRep ],
    function( x )
      return Concatenation( "ZmodnZObj(", String(x![1]), ",",
      String(FamilyObj( x )!.Characteristic), ")" );
    end );

InstallMethod( String,
    "for element in Z/pZ (ModulusRep)",
    [ IsZmodpZObj and IsModulusRep ],
    function( x )
      return Concatenation( "ZmodpZObj(", String(x![1]), ",",
      String(FamilyObj( x )!.Characteristic), ")" );
    end );


#############################################################################
##
#M  \=( <x>, <y> )
#M  \<( <x>, <y> )
##
InstallMethod( \=,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \=,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObj and IsModulusRep, IsFFE and IsInternalRep ],
    function( x, y )
    return DegreeFFE( y ) = 1 and x![1] = IntFFE( y );
    end );

InstallMethod( \=,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObj and IsModulusRep ],
    function( x, y )
    return DegreeFFE( x ) = 1 and y![1] = IntFFE( x );
    end );

InstallMethod( \<,
    "for two elements in Z/nZ (ModulusRep, nonprime)",
    IsIdenticalObj,
    [ IsZmodnZObjNonprime and IsModulusRep,
      IsZmodnZObjNonprime and IsModulusRep ],
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \<,
    "for two elements in Z/pZ (ModulusRep, large)",
    IsIdenticalObj,
    [ IsZmodpZObjLarge and IsModulusRep,
      IsZmodpZObjLarge and IsModulusRep ],
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \<,
    "for two elements in Z/pZ (ModulusRep, small)",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep,
      IsZmodpZObjSmall and IsModulusRep ],
    function( x, y )
    local p, r;      # characteristic and primitive root
    if x![1] = 0 then
      return y![1] <> 0;
    elif y![1] = 0 then
      return false;
    fi;
    p:= Characteristic( x );
    r:= PrimitiveRootMod( p );
    return LogMod( x![1], r, p ) < LogMod( y![1], r, p );
    end );

InstallMethod( \<,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ],
    function( x, y )
    return x![1] * One( Z( Characteristic( x ) ) ) < y;
    end );

InstallMethod( \<,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ],
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
##  The result of an arithmetic operation of
##  - two `ZmodnZObj' is again a `ZmodnZObj',
##  - a `ZmodnZObj' and a rational with acceptable denominator
##    is a `ZmodnZObj',
##  - a `ZmodpZObj' and an internal FFE in the same characteristic
##    is an internal FFE.
##
InstallMethod( \+,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] + y![1] );
    end );

InstallMethod( \+,
    "for element in Z/nZ (ModulusRep) and integer",
    [ IsZmodnZObj and IsModulusRep, IsInt ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] + y );
    end );

InstallMethod( \+,
    "for integer and element in Z/nZ (ModulusRep)",
    [ IsInt, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( y ), x + y![1] );
    end );

InstallMethod( \+,
    "for element in Z/nZ (ModulusRep) and rational",
    [ IsZmodnZObj and IsModulusRep, IsRat ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] + y );
    end );

InstallMethod( \+,
    "for rational and element in Z/nZ (ModulusRep)",
    [ IsRat, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( y ), x + y![1] );
    end );

InstallMethod( \+,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ],
    function( x, y ) return x![1] + y; end );

InstallMethod( \+,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ],
    function( x, y ) return x + y![1]; end );


InstallMethod( \-,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] - y![1] );
    end );

InstallMethod( \-,
    "for element in Z/nZ (ModulusRep) and integer",
    [ IsZmodnZObj and IsModulusRep, IsInt ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] - y );
    end );

InstallMethod( \-,
    "for integer and element in Z/nZ (ModulusRep)",
    [ IsInt, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( y ), x - y![1] );
    end );

InstallMethod( \-,
    "for element in Z/nZ (ModulusRep) and rational",
    [ IsZmodnZObj and IsModulusRep, IsRat ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] - y );
    end );

InstallMethod( \-,
    "for rational and element in Z/nZ (ModulusRep)",
    [ IsRat, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( y ), x - y![1] );
    end );

InstallMethod( \-,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ],
    function( x, y ) return x![1] - y; end );

InstallMethod( \-,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ],
    function( x, y ) return x - y![1]; end );


InstallMethod( \*,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] * y![1] );
    end );

InstallMethod( \*,
    "for element in Z/nZ (ModulusRep) and integer",
    [ IsZmodnZObj and IsModulusRep, IsInt ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] * y );
    end );

InstallMethod( \*,
    "for integer and element in Z/nZ (ModulusRep)",
    [ IsInt, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( y ), x * y![1] );
    end );

InstallMethod( \*,
    "for element in Z/nZ (ModulusRep) and rational",
    [ IsZmodnZObj and IsModulusRep, IsRat ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] * y );
    end );

InstallMethod( \*,
    "for rational and element in Z/nZ (ModulusRep)",
    [ IsRat, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( y ), x * y![1] );
    end );

InstallMethod( \*,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ],
    function( x, y ) return x![1] * y; end );

InstallMethod( \*,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ],
    function( x, y ) return x * y![1]; end );


InstallMethod( \/,
    "for two elements in Z/nZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
        function( x, y )
    local Fam, q;
    Fam := FamilyObj( x );
    q := QuotientMod( Integers, x![1], y![1],
                 Fam!.Characteristic );
    if q = fail then
        Error("invalid division");
    fi;
    return ZmodnZObj( Fam, q );
    end );

InstallMethod( \/,
    "for element in Z/nZ (ModulusRep) and integer",
    [ IsZmodnZObj and IsModulusRep, IsInt ],
    function( x, y )
    local Fam, q;
    Fam := FamilyObj( x );
    q := QuotientMod( Integers, x![1], y,
                 Fam!.Characteristic );
    if q = fail then
        Error("invalid division");
    fi;
    return ZmodnZObj( Fam, q );
    end );

InstallMethod( \/,
    "for integer and element in Z/nZ (ModulusRep)",
    [ IsInt, IsZmodnZObj and IsModulusRep ],
        function( x, y )
    local Fam, q;
    Fam := FamilyObj( y );
    q := QuotientMod( Integers, x, y![1],
                 Fam!.Characteristic );
    if q = fail then
        Error("invalid division");
    fi;
    return ZmodnZObj( Fam, q );
    end );

InstallMethod( \/,
    "for element in Z/nZ (ModulusRep) and rational",
    [ IsZmodnZObj and IsModulusRep, IsRat ],
    function( x, y )
    return ZmodnZObj( FamilyObj( x ), x![1] / y );
    end );

InstallMethod( \/,
    "for rational and element in Z/nZ (ModulusRep)",
    [ IsRat, IsZmodnZObj and IsModulusRep ],
    function( x, y )
    return ZmodnZObj( FamilyObj( y ), x / y![1] );
    end );

InstallMethod( \/,
    "for element in Z/pZ (ModulusRep) and internal FFE",
    IsIdenticalObj,
    [ IsZmodpZObjSmall and IsModulusRep, IsFFE and IsInternalRep ],
    function( x, y ) return x![1] / y; end );

InstallMethod( \/,
    "for internal FFE and element in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsZmodpZObjSmall and IsModulusRep ],
    function( x, y ) return x / y![1]; end );


InstallMethod( \^,
    "for element in Z/nZ (ModulusRep), and integer",
    [ IsZmodnZObj and IsModulusRep, IsInt ],
    function( x, n )
    local Fam;
    Fam := FamilyObj( x );
    return ZmodnZObj( Fam,
                  PowerModInt( x![1], n, Fam!.Characteristic ) );
    end );


#############################################################################
##
#M  ZeroOp( <elm> ) . . . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( ZeroOp,
    "for element in Z/nZ (ModulusRep)",
    [ IsZmodnZObj ],
    elm -> ZmodnZObj( FamilyObj( elm ), 0 ) );


#############################################################################
##
#M  AdditiveInverseOp( <elm> )  . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( AdditiveInverseOp,
    "for element in Z/nZ (ModulusRep)",
    [ IsZmodnZObj and IsModulusRep ],
    elm -> ZmodnZObj( FamilyObj( elm ), AdditiveInverse( elm![1] ) ) );


#############################################################################
##
#M  OneOp( <elm> )  . . . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( OneOp,
    "for element in Z/nZ (ModulusRep)",
    [ IsZmodnZObj ],
    elm -> ZmodnZObj( FamilyObj( elm ), 1 ) );


#############################################################################
##
#M  InverseOp( <elm> )  . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( InverseOp,
    "for element in Z/nZ (ModulusRep)",
    [ IsZmodnZObj and IsModulusRep ],
    function( elm )
    local fam, inv;
    fam:= FamilyObj( elm );
    inv:= QuotientMod( Integers, 1, elm![1], fam!.Characteristic );
    if inv <> fail then
      inv:= ZmodnZObj( fam, inv );
    fi;
    return inv;
    end );


#############################################################################
##
#M  Order( <obj> )  . . . . . . . . . . . . . . . . . . . . for `IsZmodpZObj'
##
InstallMethod( Order,
    "for element in Z/nZ (ModulusRep)",
    [ IsZmodnZObj and IsModulusRep ],
    function( elm )
    local ord;
    ord := OrderMod( elm![1], FamilyObj( elm )!.Characteristic );
    if ord = 0  then
        Error( "<obj> is not invertible" );
    fi;
    return ord;
    end );


#############################################################################
##
#M  DegreeFFE( <obj> )  . . . . . . . . . . . . . . . . . . for `IsZmodpZObj'
##
InstallMethod( DegreeFFE,
    "for element in Z/pZ (ModulusRep)",
    [ IsZmodpZObj and IsModulusRep ],
    z -> 1 );


#############################################################################
##
#M  LogFFE( <n>, <r> )  . . . . . . . . . . . . . . . . . . for `IsZmodpZObj'
##
InstallMethod( LogFFE,
    "for two elements in Z/pZ (ModulusRep)",
    IsIdenticalObj,
    [ IsZmodpZObj and IsModulusRep, IsZmodpZObj and IsModulusRep ],
    function( n, r )
    return LogMod( n![1], r![1], Characteristic( n ) );
    end );


#############################################################################
##
#M  RootFFE( <z>, <k> )  . . . . . . . . . . . . . . . . . . for `IsZmodpZObj'
##
InstallOtherMethod(RootFFE,"for modulus rep, using RootMod",true,
  [IsPosInt,IsZmodpZObj and IsModulusRep,IsPosInt],
function( A, z, k )
local r,fam;
  fam:=FamilyObj(z);
  if A<>fam!.Characteristic then
    TryNextMethod();
  fi;
  if k=1 or z![1]=0 or z![1]=1 then return z;fi;
  r:=RootMod(z![1],k,A);
  if r=fail then return r;fi;
  return ZmodnZObj(fam,r);
end );

InstallOtherMethod(RootFFE,"for modulus rep",true,
  [IsZmodpZObj and IsModulusRep,IsPosInt],
function(z,k)
  return RootFFE(FamilyObj(z)!.Characteristic,z,k);
end);


#############################################################################
##
#M  Int( <obj> )  . . . . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( Int,
    "for element in Z/nZ (ModulusRep)",
    [ IsZmodnZObj and IsModulusRep ],
    z -> z![1] );


#############################################################################
##
#M IntFFE( <obj> )  . .  . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod(IntFFE,
        [IsZmodpZObj and IsModulusRep],
        x->x![1]);


#############################################################################
##
#M  IntFFESymm( <obj> )  . . . . . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallOtherMethod(IntFFESymm,"Z/nZ (ModulusRep)",
  [IsZmodnZObj and IsModulusRep],
function(z)
local n;
  n:=Characteristic( FamilyObj(z) );
  if 2*z![1]>n then
    return z![1]-n;
  else
    return z![1];
  fi;
end);


#############################################################################
##
#M  Z(p) ... return a primitive root
##
InstallMethod(ZOp,
        [IsPosInt],
        function(p)
    local   f;
    if p <= MAXSIZE_GF_INTERNAL then
        TryNextMethod(); # should never happen
    fi;
    if not IsProbablyPrimeInt(p) then
        TryNextMethod();
    fi;
    f := FFEFamily(p);
    if not IsBound(f!.primitiveRootModP) then
        f!.primitiveRootModP := PrimitiveRootMod(p);
    fi;
    return ZmodnZObj(f!.primitiveRootModP,p);
end);


#############################################################################
##
#M  EuclideanDegree( <R>, <n> )
##
##  For an overview on the theory of euclidean rings which are not domains,
##  see Pierre Samuel, "About Euclidean rings", J. Algebra, 1971 vol. 19 pp. 282-301.
##  https://doi.org/10.1016/0021-8693(71)90110-4

InstallMethod( EuclideanDegree,
    "for Z/nZ and an element in Z/nZ",
    IsCollsElms,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing, IsZmodnZObj and IsModulusRep ],
    function ( R, n )
      return GcdInt( n![1], Characteristic( n ) );
    end );


#############################################################################
##
#M  QuotientRemainder( <R>, <n>, <m> )
##
InstallMethod( QuotientRemainder,
    "for Z/nZ and two elements in Z/nZ",
    IsCollsElmsElms,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing,
      IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
    function ( R, n, m )
    local u, s, q, r;
    u := StandardAssociateUnit(R, m);
    s := u * m; # the standard associate of m
    q := QuoInt(n![1], s![1]);
    r := n![1] - q * s![1];
    return [ ZmodnZObj( FamilyObj( n ), (q * u![1]) mod Characteristic(R) ),
             ZmodnZObj( FamilyObj( n ), r ) ];
    end );


#############################################################################
##
#M  Quotient( <R>, <n>, <m> ) . . . . . . . . . . . . . . . for `IsZmodnZObj'
##
InstallMethod( Quotient,
    "for Z/nZ and two elements in Z/nZ",
    IsCollsElmsElms,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing,
      IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
    function ( R, x, y )
    local Fam, q;
    Fam := FamilyObj( x );
    q := QuotientMod( Integers, x![1], y![1],
                 Fam!.Characteristic );
    if q = fail then
        return fail;
    fi;
    return ZmodnZObj( Fam, q );
    end );


#############################################################################
##
#M  StandardAssociate( <r> )
##
InstallMethod( StandardAssociate,
    "for full ring Z/nZ and an element in Z/nZ",
    IsCollsElms,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing, IsZmodnZObj and IsModulusRep ],
    function ( R, r )
      local m, n;
      m := Characteristic( r );
      n := GcdInt( r![1], m );
      return ZmodnZObj( FamilyObj( r ), n );
    end );

#############################################################################
##
#M  StandardAssociateUnit( <r> )
##
InstallMethod( StandardAssociateUnit,
    "for full ring Z/nZ and an element in Z/nZ",
    IsCollsElms,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing, IsZmodnZObj and IsModulusRep ],
    function ( R, r )
      local m, n, u, pd, p, d, x, residues, moduli;
      # zero is associated to itself, so return identity
      if r![1] = 0 then
        return ZmodnZObj( FamilyObj( r ), 1 );
      fi;
      m := Characteristic( r );
      # divide input by its standard associate
      n := r![1] / GcdInt( r![1], m );
      # we really need the "inverse" of n, i.e., a unit u such that r*u is
      # equal to the standard associate. If n is a unit (i.e., coprime to the
      # modulus m), we can invert it and use that as u:
      if GcdInt( n, m ) = 1 then
        u := (1 / n) mod m;
        return ZmodnZObj( FamilyObj( r ), u );
      fi;
      # otherwise, first factor the modulus m into a product of prime powers,
      # m = p_1^{d_1} \cdots p_k^{d_k}. Then compute the StandardAssociateUnit
      # modulo each p_i^{d_i}; then finally use the Chinese Remainder Theorem
      # to combine these back together.
      residues := [];
      moduli := [];
      for pd in Collected(Factors(Integers, m)) do
        p := pd[1];
        d := pd[2];
        pd := p^d;
        if n mod p = 0 then
            # if n is divisible by p, then in fact r![1] is divisible by p^d,
            # i.e., it is 0 mod p^d, and we can choose 1 as the
            # StandardAssociateUnit (mod p^d)
            x := 1;
        else
            # if n is not divisible by p, we can invert it modulo p^d to get
            # the StandardAssociateUnit (mod p^d)
            x := 1 / n mod pd;
        fi;
        Add( residues, x );
        Add( moduli, pd );
      od;
      u := ChineseRem( moduli, residues );
      return ZmodnZObj( FamilyObj( r ), u );
    end );


#############################################################################
##
#M  IsAssociated( <R>, <n>, <m> )
##
InstallMethod( IsAssociated,
    "for Z/nZ and two elements in Z/nZ",
    IsCollsElmsElms,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing,
      IsZmodnZObj and IsModulusRep, IsZmodnZObj and IsModulusRep ],
    function ( R, n, m )
      R := Characteristic( n );
      return GcdInt( n![1], R ) = GcdInt( m![1], R );
    end );


##  2. The collections
##


#############################################################################
##
#M  InverseOp( <mat> )  . . . . . . . . . . . . for ordinary matrix over Z/nZ
#M  InverseSameMutability( <mat> )  . . . . . . for ordinary matrix over Z/nZ
##
##  For a nonprime integer $n$, the residue class ring $\Z/n\Z$ has zero
##  divisors, so the standard algorithm to invert a matrix over $\Z/n\Z$
##  cannot be applied.
##
#T  The method below should of course be replaced by a method that uses
#T  inversion modulo the maximal prime powers dividing the modulus,
#T  this ``brute force method'' is only preliminary!
##
InstallMethod( InverseOp,
    "for an ordinary matrix over a ring Z/nZ",
    [ IsMatrix and IsOrdinaryMatrix and IsZmodnZObjNonprimeCollColl ],
    function( mat )
    local one;

    one:= One( mat[1][1] );
    mat:= InverseOp( List( mat, row -> List( row, Int ) ) );
    if mat <> fail then
      mat:= mat * one;
    fi;
    if not IsMatrix( mat ) then
      mat:= fail;
    fi;
    return mat;
    end );

InstallMethod( InverseSameMutability,
    "for an ordinary matrix over a ring Z/nZ",
    [ IsMatrix and IsOrdinaryMatrix and IsZmodnZObjNonprimeCollColl ],
    function( mat )
    local inv, row;

    inv:= InverseOp( mat );
    if inv <> fail then
      if   not IsMutable( mat ) then
        MakeImmutable( inv );
      elif not IsMutable( mat[1] ) then
        for row in inv do
          MakeImmutable( row );
        od;
      fi;
    fi;
    return inv;
    end );


InstallMethod( TriangulizeMat,
    "for a mutable ordinary matrix over a ring Z/nZ",
    [ IsMatrix and IsMutable and IsOrdinaryMatrix
               and IsZmodnZObjNonprimeCollColl ],
    function( mat )
    local imat, i;
    imat:= List( mat, row -> List( row, Int ) );
    TriangulizeMat( imat );
    imat:= imat * One( mat[1][1] );
    for i in [ 1 .. Length( mat ) ] do
      mat[i]:= imat[i];
    od;
    end );


#############################################################################
##
#M  ViewObj( <R> )  . . . . . . . . . . . . . . . . method for full ring Z/nZ
#M  PrintObj( <R> ) . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( ViewObj,
    "for full ring Z/nZ",
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], SUM_FLAGS,
    function( obj )
    Print( "(Integers mod ", Size( obj ), ")" );
    end );

InstallMethod( PrintObj,
    "for full ring Z/nZ",
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
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ],
    {} -> RankFilter( IsRing ),
    AsSSortedList );

InstallMethod( AsSSortedList,
    "for full ring Z/nZ",
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ],
    {} -> RankFilter( IsRing ),
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
InstallMethodWithRandomSource(Random,
    "for a random source and full ring Z/nZ",
    [ IsRandomSource, IsZmodnZObjNonprimeCollection and IsWholeFamily ],
    {} -> RankFilter( IsRing ),
    { rs, R } -> ZmodnZObj( ElementsFamily( FamilyObj( R ) ),
                    Random( rs, 0, Size( R ) - 1 ) ) );


#############################################################################
##
#M  IsIntegralRing( <obj> )  . . . . . . . . . .  method for subrings of Z/nZ
##
InstallImmediateMethod( IsIntegralRing,
    IsZmodnZObjNonprimeCollection and IsRing, 0,
    ReturnFalse );


#############################################################################
##
#M  IsUnit( <obj> )  . . . . . . . . . . . . . . . . . . .  for `IsZmodpZObj'
##
InstallMethod( IsUnit,
    "for element in Z/nZ (ModulusRep)",
    IsCollsElms,
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing, IsZmodnZObj and IsModulusRep ],
    function( R, elm )
    return GcdInt( elm![1], FamilyObj( elm )!.Characteristic ) = 1;
    end );


#############################################################################
##
#M  Units( <R> )  . . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallMethod( Units,
    "for full ring Z/nZ",
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily and IsRing ],
    function( R )
    local   G,  gens;

    gens := GeneratorsPrimeResidues( Size( R ) ).generators;
    if not IsEmpty( gens )  and  gens[ 1 ] = 1  then
        gens := gens{ [ 2 .. Length( gens ) ] };
    fi;
    gens := Flat( gens ) * One( R );
    G := GroupByGenerators( gens, One( R ) );
    SetIsAbelian( G, true );
    SetSize( G, Product( List( gens, Order ) ) );
    SetIsHandledByNiceMonomorphism(G,true);
    return G;
end );


#############################################################################
##
#M  <res> in <G>  . . . . . . . . . . . for cyclic prime residue class groups
##
InstallMethod( \in,
    "for subgroups of Z/p^aZ, p<>2",
    IsElmsColls,
    [ IsZmodnZObjNonprime, IsGroup and IsZmodnZObjNonprimeCollection ],
    function( res, G )
    local   m;

    m := FamilyObj( res )!.Characteristic;
    res := Int( res );
    if GcdInt( res, m ) <> 1  then
        return false;
    elif IsEvenInt(m) or not IsPrimePowerInt( m ) then
        TryNextMethod();
    fi;
    return LogMod( res, PrimitiveRootMod( m ), m ) mod
           ( Phi( m ) / Size( G ) ) = 0;
end );


#############################################################################
##
#F  EnumeratorOfZmodnZ( <R> ). . . . . . . . . . . . . enumerator for Z / n Z
#M  Enumerator( <R> )  . . . . . . . . . . . . . . . . enumerator for Z / n Z
##
BindGlobal( "ElementNumber_ZmodnZ", function( enum, nr )
    if nr > enum!.size then
      Error( "<enum>[", nr, "] must have an assigned value" );
    fi;
    return Objectify( enum!.type, [ nr - 1 ] );
    end );

BindGlobal( "NumberElement_ZmodnZ", function( enum, elm )
    if IsCollsElms( FamilyObj( enum ), FamilyObj( elm ) ) then
      return elm![1] + 1;
    fi;
    return fail;
    end );

InstallGlobalFunction( EnumeratorOfZmodnZ, function( R )
    local enum;

    enum:= EnumeratorByFunctions( R, rec(
             ElementNumber := ElementNumber_ZmodnZ,
             NumberElement := NumberElement_ZmodnZ,

             size:= Size( R ),
             type:= ElementsFamily( FamilyObj( R ) )!.typeOfZmodnZObj ) );

    SetIsSSortedList( enum, true );
    return enum;
    end );

InstallMethod( Enumerator,
    "for full ring Z/nZ",
    [ IsZmodnZObjNonprimeCollection and IsWholeFamily ], SUM_FLAGS,
    EnumeratorOfZmodnZ );


#############################################################################
##
#M  SquareRoots( <F>, <obj> )
##
##  (is used in the implementation of Dixon's algorithm ...)
##
InstallMethod( SquareRoots,
    "for prime field and object in Z/pZ",
    IsCollsElms,
    [ IsField and IsPrimeField, IsZmodpZObj and IsModulusRep ],
    function( F, obj )
    F:= FamilyObj( obj );
    return List( RootsMod( obj![1], 2, F!.Characteristic ),
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
    return ZmodpZNC( AbsInt( p ) );
end );

InstallGlobalFunction( ZmodpZNC, p -> GET_FROM_SORTED_CACHE( Z_MOD_NZ, p, function( )
    local F;

    # Get the family of element objects of our ring.
    F:= FFEFamily( p );

    # Make the domain.
    F:= FieldOverItselfByGenerators( [ ZmodnZObj( F, 1 ) ] );
    SetIsPrimeField( F, true );
    SetIsWholeFamily( F, false );

    # Return the field.
    return F;
end ) );


#############################################################################
##
#F  ZmodnZ( <n> ) . . . . . . . . . . . . . . .  construct `Integers mod <n>'
##
InstallGlobalFunction( ZmodnZ, function( n )
    local F, R;

    if not IsInt( n ) then
      Error( "<n> must be an integer" );
    elif n = 0 then
      return Integers;
    elif n < 0 then
      n := -n;
    fi;
    if IsPrimeInt( n ) then
      return ZmodpZNC( n );
    fi;

    return GET_FROM_SORTED_CACHE( Z_MOD_NZ, n, function( )

    # Construct the family of element objects of our ring.
    F:= NewFamily( Concatenation( "Zmod", String( n ) ),
                   IsZmodnZObj,
                   IsZmodnZObjNonprime and CanEasilySortElements
                                       and IsNoImmediateMethodsObject,
                   CanEasilySortElements);

    # Install the data.
    SetCharacteristic(F,n);

    # Store the objects type.
    F!.typeOfZmodnZObj:= NewType( F, IsZmodnZObjNonprime and IsModulusRep );

    # as n is no prime, the family is no UFD
    SetIsUFDFamily(F,false);

    # Make the domain.
    R:= RingWithOneByGenerators( [ ZmodnZObj( F, 1 ) ] );
    SetIsWholeFamily( R, true );
    SetZero(F,Zero(R));
    SetOne(F,One(R));
    SetSize(R,n);

    # Return the ring.
    return R;

    end );
end );


#############################################################################
##
#M  \mod( Integers, <n> )
##
InstallMethod( \mod,
    "for `Integers', and integer",
    [ IsIntegers, IsInt ],
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
    [ IsZmodnZObjNonprime ],
    res -> FamilyObj( res )!.Characteristic );

InstallMethod( ModulusOfZmodnZObj,
    "for element in Z/pZ (prime)",
    [ IsZmodpZObj ],
    Characteristic );

InstallOtherMethod( ModulusOfZmodnZObj,
    "for FFE",
    [ IsFFE ],
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
    C -> ZmodnZ( Characteristic( Representative( C ) ) ) );


#############################################################################
##
#M  DefaultFieldOfMatrixGroup( <zmodnz-mat-grp> )
##
##  Is it possible to avoid this very special method?
##  In fact the whole stuff in the library is not very clean,
##  as the ``generic'' method for matrix groups claims to be allowed to
##  call `Field'.
##  The bad name of the function (`DefaultFieldOfMatrixGroup') may be the
##  reason for this bad behaviour.
##  Do we need to distinguish matrix groups over fields and rings that aren't
##  fields, and change the generic `DefaultFieldOfMatrixGroup' method
##  accordingly?
##
InstallMethod( DefaultFieldOfMatrixGroup,
    "for a matrix group over a ring Z/nZ",
    [ IsMatrixGroup and IsZmodnZObjNonprimeCollCollColl ],
    G -> ZmodnZ( Characteristic( Representative( G )[1,1] ) ) );


#############################################################################
##
#M  AsInternalFFE( <zmodpzobj> )
##
##  A ZmodpZ object can be a finite field element, but is never equal to
##  an internal FFE, so this method just returns fail
##
InstallMethod(AsInternalFFE, [IsZmodpZObj], ReturnFail);
