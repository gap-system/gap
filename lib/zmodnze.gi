#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Konovalov.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for the elements of the rings $Z/nZ(epsilon)$,
##  where epsilon is the primitive root of unity of degree m (not depending
##  on n).
##  The following approach was used to construct such rings. First we create
##  a ring of integral cyclotomics in the m-th cyclotomic field. Then we
##  construct from its elements a new ring, defining operations modulo n.
##  Thus, elements of the ring $Z/nz(epsilon)$ internally are represented
##  as cyclotomic integers.
##


#############################################################################
#
# RingOfIntegralCyclotomics( F )
#
# Let F be a cyclotomic field. This function returns the ring of integral
# cyclotomics of the field F
#
InstallGlobalFunction( RingOfIntegralCyclotomics,
function( F )
  local R;
  if not IsCyclotomicField( F ) then
    Error("RingOfIntegralCyclotomics : an argument is not cyclotomic field !");
  fi;
  R := RingWithOne( E( Conductor( F ) ) );
  SetIsRingOfIntegralCyclotomics( R, true );
  SetName( R, Concatenation( "(RingInt(CF(", String(Conductor(F)), ")))" ) );
  return R;
end );


#############################################################################
#
# ZmodnZepsObj( Fam, celt )
#
# This function takes a cyclotomic element celt and creates an object in a
# family Fam, internally represented by this cyclotomic
#
InstallGlobalFunction( ZmodnZepsObj,
function( Fam, celt )
  local n , m, coeffs, elt;
  m := Fam!.degree;
  n := Fam!.modulus;
  # we find coefficients of celt in the m-th Zumbroich basis
  # this guarantee the canonical form of an element from Z_m(eps)
  coeffs := CoeffsCyc(celt, m);
  if ForAny(coeffs, x -> not IsInt(x)) then
    Error("ZmodnZepsObj : cyclotomic is not integral !!!");
  fi;
  # now we reduce coefficients modulo n
  coeffs := List(coeffs, x -> x mod n);
  elt := coeffs * List( [1..m], j -> E(m)^(j-1) );
  return Objectify( NewType( Fam, IsZmodnZepsObj and IsZmodnZepsRep ),
                    [ elt ] );
end );


#############################################################################
#
# ZmodnZeps( n, m)
#
# This function returns the ring $Z/nZ(epsilon)$, where n is a positive
# integer and epsilon is a primitive root of unity of degree m.
# Alternatively, the same result may me obtained using the command
# RingInt(CF(m)) mod n
# since below we install special method for \mod operation for this case
#
InstallGlobalFunction( ZmodnZeps,
function( n, m )
  local F, R;
  if not IsPosInt( m ) then
    Error( "<m> must be a positive integer" );
  fi;
  if not IsPosInt( n ) then
    Error( "<n> must be a positive integer" );
  fi;
  # Construct the family of element objects of our ring.
  F := NewFamily( Concatenation( "Zmod", String(n), "Z(", String(m), ")" ),
                  IsZmodnZepsObj );
  # Install the data.
  F!.modulus := n;
  F!.degree  := m;
  # Make the domain.
  R := RingWithOneByGenerators( [ ZmodnZepsObj( F, E(m) ) ] );
  SetIsWholeFamily( R, true );
  SetName( R, Concatenation( "(RingInt(CF(", String(m), ")) mod ",
              String(n), ")" ) );
  # Return the ring.
  return R;
end );


#############################################################################

#
# PrintObj( R )
#
# If R is the ring $Z/nZ(epsilon)$, where epsilon^m=1, then it will be
# printed in the following form:
# RingInt(CF(m)) mod n
#
InstallMethod( PrintObj,
  "zmodnze : for full collection Z/nZ(m)",
  [ CategoryCollections( IsZmodnZepsObj ) and IsWholeFamily ],
function( R )
  local F, m, n;
  F := ElementsFamily( FamilyObj(R) );
  n := F!.modulus;
  m := F!.degree;
  Print( Concatenation( "(RingInt(CF(", String(m), ")) mod ",
                        String(n), ")" ) );
end );


#############################################################################
#
# PrintObj( x )
#
# If x is an element of the ring $Z/nZ(epsilon)$, where epsilon^m=1, and celt
# is its underlying cyclotomic element (thus, its internal representation),
# then x will be printed in the following form:
# ( celt mod n )
#
InstallMethod( PrintObj,
  "zmodnze : for element in Z/nZ(m) (ZmodnZepsRep)",
  [ IsZmodnZepsObj and IsZmodnZepsRep ],
function( x )
  Print( "( ", x![1], " mod ", FamilyObj(x)!.modulus, " )" );
end );


#############################################################################
#
# x=y
#
# x equal y iff corresponding underlying cyclotomics are equal, since
# their canonical form is uniquely determined by ZmodnZepsObj
#
InstallMethod( \=,
  "zmodnze : for two elements in Z/nZ(m) (ZmodnZepsRep)",
  IsIdenticalObj,
  [ IsZmodnZepsObj and IsZmodnZepsRep,
    IsZmodnZepsObj and IsZmodnZepsRep ],
function( x, y )
  return x![1] = y![1]; end );


#############################################################################
#
# x < y
#
# this is just extending of relation "<" implemented in GAP for
# cyclotomics. Thus, x < y iff the same relation holds for underlying
# cyclotomics, since their canonical form is uniquely determined by
# ZmodnZepsObj
#
InstallMethod( \<,
  "zmodnze : for two elements in Z/nZ(m) (ZmodnZepsRep)",
  IsIdenticalObj,
  [ IsZmodnZepsObj and IsZmodnZepsRep,
    IsZmodnZepsObj and IsZmodnZepsRep ],
function( x, y )
  return x![1] < y![1];
end );


#############################################################################
#
#  x+y
#
#  x and y in Z/nZ(m)
#  x in Z/nZ(m), y Cyclotomic
#  x Cyclotomic, y in Z/nZ(m)
#
#  These operations are implemented via appropriate operations over
#  (underlying) cyclotomics and then 'objectifying' the result
#
InstallMethod( \+,
  "zmodnze : for two elements in Z/nZ(m) (ZmodnZepsRep)",
  IsIdenticalObj,
  [ IsZmodnZepsObj and IsZmodnZepsRep,
    IsZmodnZepsObj and IsZmodnZepsRep ],
function( x, y )
  return ZmodnZepsObj( FamilyObj( x ), x![1] + y![1] );
end );

InstallMethod( \+,
  "zmodnze : for element in Z/nZ(m) (ZmodnZepsRep) and cyclotomic",
  [ IsZmodnZepsObj and IsZmodnZepsRep, IsCyclotomic ],
function( x, y )
  return ZmodnZepsObj( FamilyObj( x ), x![1] + y );
end );

InstallMethod( \+,
  "zmodnze : for cyclotomic and element in Z/nZ(m) (ZmodnZepsRep)",
  [ IsCyclotomic, IsZmodnZepsObj and IsZmodnZepsRep ],
function( x, y )
  return ZmodnZepsObj( FamilyObj( y ), x + y![1] );
end );

#############################################################################
#
#  x * y
#  x Cyclotomic , y in Z/nZ(m)
#  x in Z/nZ(m) , y Cyclotomic
#  x in Z/nZ(m) , y in Z/nZ
#  x in Z/nZ    , y in Z/nZ(m)
#  x in Z/nZ(m) , y in Z/nZ(m)
#
#  These operations are implemented via appropriate operations over
#  (underlying) cyclotomics and then 'objectifying' the result
#
InstallMethod( \*,
  "zmodnze : for cyclotomic x and element y in Z/nZ(m) (ZmodnZepsRep)",
  [ IsCyclotomic,
    IsZmodnZepsObj and IsZmodnZepsRep ],
function( x, y )
  return ZmodnZepsObj( FamilyObj( y ), x * y![1] );
end );

InstallMethod( \*,
  "zmodnze : for element x in Z/nZ(m) (ZmodnZepsRep) and cyclotomic y",
  [ IsZmodnZepsObj and IsZmodnZepsRep,
    IsCyclotomic],
function( x, y )
  return ZmodnZepsObj( FamilyObj( x ), x![1] * y );
end );

InstallMethod( \*,
  "zmodnze : for element x in Z/nZ(m) and y in Z/nZ",
  [ IsZmodnZepsObj and IsZmodnZepsRep,
    IsZmodnZObj and IsModulusRep],
function( x, y )
  return ZmodnZepsObj( FamilyObj( x ), x![1] * Int(y) );
end );

InstallMethod( \*,
  "zmodnze : for element x in Z/nZ and y in Z/nZ(m)",
  [ IsZmodnZObj and IsModulusRep,
    IsZmodnZepsObj and IsZmodnZepsRep],
function( x, y )
  return ZmodnZepsObj( FamilyObj( y ), Int(x) * y![1] );
end );

InstallMethod( \*,
  "zmodnze : for two elements in Z/nZ(m) (ZmodnZepsRep)",
  IsIdenticalObj,
  [ IsZmodnZepsObj and IsZmodnZepsRep,
    IsZmodnZepsObj and IsZmodnZepsRep ],
function( x, y )
  return ZmodnZepsObj( FamilyObj( x ), x![1] * y![1] );
end );


#############################################################################
#
# Zero
#
InstallMethod( ZeroOp,
    "zmodnze : for element in Z/nZ(m) (ZmodnZepsRep)",
    [ IsZmodnZepsObj ],
    x -> ZmodnZepsObj( FamilyObj( x ), 0 ) );

#############################################################################
#
# One
#
InstallMethod( OneOp,
  "zmodnze : for element in Z/nZ(m) (ZmodnZepsRep)",
  [ IsZmodnZepsObj ],
elm -> ZmodnZepsObj( FamilyObj( elm ), 1 ) );


#############################################################################
#
# -x
#
InstallMethod( AdditiveInverseOp,
  "zmodnze : for element in Z/nZ(m) (ZmodnZepsRep)",
  [ IsZmodnZepsObj and IsZmodnZepsRep ],
x -> ZmodnZepsObj( FamilyObj( x ), AdditiveInverse( x![1] ) ) );


#############################################################################
#
# Cyclotomic
#
# returns an underlying cyclotomic element
#
InstallMethod( Cyclotomic,
  "zmodnze : for element in Z/nZ(m) (ZmodnZepsRep)",
  [ IsZmodnZepsObj and IsZmodnZepsRep ],
z -> z![1] );


#############################################################################
#
# mod
#
# Creates the ring Z/nZ(m) from the ring Z/nZ
#
InstallMethod( \mod,
  "zmodnze : for RingOfIntegralCyclotomics and a positive integer",
  [ IsRingOfIntegralCyclotomics,
    IsPosRat and IsInt ],
function( R, n )
  return ZmodnZeps( n, Conductor(GeneratorsOfRingWithOne(R)[1]) );
end );


#############################################################################
#
# Size of Z/nZ(m) is equal to n^Phi(m)
#
InstallMethod( Size,
  "zmodnze : for full ring Z/nZ(m)",
  [ CategoryCollections( IsZmodnZepsObj ) and IsWholeFamily ],
R -> ElementsFamily(FamilyObj(R))!.modulus^
     Phi(ElementsFamily(FamilyObj(R))!.degree));


#############################################################################
#
# IsFinite = true
#
InstallTrueMethod( IsFinite,
CategoryCollections( IsZmodnZepsObj ) and IsDomain );


#############################################################################
#
# Random
#
InstallMethodWithRandomSource( Random,
  "for a random source and the full collection Z/nZ(m)",
  [ IsRandomSource, CategoryCollections( IsZmodnZepsObj ) and IsWholeFamily ],
function(rs, R)
  local m, n, coeffs, elt;
  m:=FamilyObj(One(R))!.degree;
  n:=FamilyObj(One(R))!.modulus;
  coeffs := List([1..m], x -> Random(rs, 0, n-1));
  elt := coeffs * List( [1..m], j -> E(m)^(j-1) );
  return ZmodnZepsObj( FamilyObj(One(R)) , elt );
end );


#############################################################################
#
# Enumerator
#
InstallMethod( Enumerator,
  "zmodnze : for full collection Z/nZ(m)",
  [ CategoryCollections( IsZmodnZepsObj ) and IsWholeFamily ],
function( R )
  local F, m, n, x, j;
  F:= ElementsFamily( FamilyObj(R) );
  m:=FamilyObj(One(R))!.degree;
  n:=FamilyObj(One(R))!.modulus;
  return List( Enumerator( (Integers mod n)^Phi(m) ),
    x -> ZmodnZepsObj(F, List(x,Int) *
         List( [1..Phi(m)], j -> E(m)^(j-1) ) ) );
end );



#############################################################################
#
# IsUnit( R, elm )
#
# checks whether the element is a unit, building the list of its powers
# 1. <elm>^<deg>=1              => <elm>^(-1)=<elm>^<deg-1>
# 2. <elm>^<deg>=0              => <elm> is not a unit
# 3. <elm>^<deg>=<elm>^<deg+C>  => <elm> is not a unit
#
InstallMethod( IsUnit,
  "zmodnze : for element in Z/nZ(m) (ZModnZepsRep) with given ring",
  [ CategoryCollections( IsZmodnZepsObj ) and IsWholeFamily and IsRing,
    IsZmodnZepsObj and IsZmodnZepsRep ],
function( R, elm )
  local pow, powers;
  if HasUnits(R) then
    return elm in Units(R);
  fi;
  powers:=[];      # to store powers of elm
  pow:=elm;
  while true do
    if pow*elm=One(elm) then
      return true;
    elif IsZero(pow) or (pow in powers) then
      return false;
    fi;
    Add(powers,pow);
    pow:=pow*elm;
  od;
end );


#############################################################################
#
# IsUnit( elm )
#
# checks whether the element is a unit, building the list of its powers
# 1. <elm>^<deg>=1              => <elm>^(-1)=<elm>^<deg-1>
# 2. <elm>^<deg>=0              => <elm> is not a unit
# 3. <elm>^<deg>=<elm>^<deg+C>  => <elm> is not a unit
#
InstallOtherMethod( IsUnit,
  "zmodnze : for element in Z/nZ(m) (ZModnZepsRep) without given ring",
  [ IsZmodnZepsObj and IsZmodnZepsRep ],
function( elm )
  local pow, powers;
  powers:=[];      # to store powers of elm
  pow:=elm;
  while true do
    if pow*elm=One(elm) then
      return true;
    elif IsZero(pow) or (pow in powers) then
      return false;
    fi;
    Add(powers,pow);
    pow:=pow*elm;
  od;
end );


#############################################################################
#
# x^-1
# calculates the inverse element building the list of its powers
#
InstallMethod( InverseOp,
  "zmodnze : for element in Z/nZ(m) (ZModnZepsRep)",
  [ IsZmodnZepsObj and IsZmodnZepsRep ],
function( elm )
  local pow, powers;
  powers:=[];      # to store powers of elm
  pow:=elm;
  while true do
    if pow*elm=One(elm) then
      return pow;
    elif IsZero(pow) or (pow in powers) then
      return fail;
    fi;
    Add(powers,pow);
    pow:=pow*elm;
  od;
end );


#############################################################################
#
# Units
#
# now simply generates the group using all units.
# TODO: Improve by minimizing the list of generators
#
InstallMethod( Units,
  "zmodnze : for full ring Z/nZ(m)",
  [ CategoryCollections( IsZmodnZepsObj ) and IsWholeFamily and IsRing ],
function( R )
  return Group( Filtered(AsList(R), IsUnit ) );
end );
