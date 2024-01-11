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
##  This file  contains  the generic  methods  for elements in families  that
##  allow certain arithmetical operations.
##


#############################################################################
##
##  The GAP Reference Manual defines 'One' only for an argument in
##  'IsMultiplicativeElementWithOne' or 'IsDomain'.
##  The following method tries to extend this definition to collections of
##  'IsMultiplicativeElementWithOne' objects that aren't domains,
##  by delegating to a representative of the collection.
##
##  This causes a logical problem if the collection is itself in
##  'IsMultiplicativeElementWithOne', because of a different meaning.
##  Such a situation occurs in the case of a group character,
##  for which 'One' shall return not '1' but the trivial character.
##
##  It would be good if we could eventually get rid of this method.
##
InstallOtherMethod(One, "for a multiplicative element with one collection",
[IsMultiplicativeElementWithOneCollection],
function(coll)
  if IsMultiplicativeElementWithOne( coll ) then
    # The fact that 'coll' is an element counts more
    # than the fact that 'coll' is a collection of elements.
    TryNextMethod();
  fi;
  return One(Representative(coll));
end);


#############################################################################
##
#M  IsImpossible( <matrix> )
##
##  Forbid that a matrix is both an ordinary matrix and a Lie matrix.
##
InstallImmediateMethod( IsImpossible,
    IsOrdinaryMatrix and IsLieMatrix, 0,
    matrix -> Error( "<matrix> cannot be both assoc. and Lie matrix" ) );


#############################################################################
##
#A  NestingDepthA( <obj> )
##
InstallMethod( NestingDepthA,
    [ IsObject ],
    function( obj )
    if not IsGeneralizedRowVector( obj ) then
      return 0;
    elif IsEmpty( obj ) then
      return 1;
    else
      return 1 + NestingDepthA( obj[ PositionBound( obj ) ] );
    fi;
    end );


#############################################################################
##
#A  NestingDepthM( <obj> )
##
InstallMethod( NestingDepthM,
    [ IsObject ],
    function( obj )
    if not IsMultiplicativeGeneralizedRowVector( obj ) then
      return 0;
    elif IsEmpty( obj ) then
      return 1;
    else
      return 1 + NestingDepthM( obj[ PositionBound( obj ) ] );
    fi;
    end );


#############################################################################
##
#M  Zero( <elm> ) . . . . . . . . . . . . . . . .  for an add.-elm.-with-zero
##
##  `ZeroMutable' guarantees that its results are *new* objects,
##  so we may call `MakeImmutable'.
#T This should be installed for `IsAdditiveElementWithZero',
#T but at least in the compatibility mode we need it also for records ...
##
InstallOtherMethod( Zero,
    "for any object (call `ZeroMutable')",
    [ IsObject ],
    function( elm )
    elm:= ZeroMutable( elm );
    MakeImmutable( elm );
    return elm;
    end );
#T In cases where the OneOp result will normally be immutable, we could install
#T OneOp itself as a method for OneImmutable. This is worse if the result is mutable,
#T because a call to MakeImmutable is replaced by one to Immutable, but still
#T works. This reduces the indirection to a method selection in these cases,
#T which takes less than 1 microsecond on my system.
#T         Steve


#############################################################################
##
#M  ZeroSameMutability( <obj> ) . . . . . . . . . . for an (immutable) object
##
##  This method is applicable for example to domains.
##
InstallOtherMethod( ZeroSameMutability,
    "for an (immutable) object",
    [ IsObject ],
    function( obj )
    if IsMutable( obj ) then
      TryNextMethod();
    fi;
    return ZeroImmutable( obj );
    end );


#############################################################################
##
#M  Zero( <elm> ) . . . . . . . . . . . . . . . . . . . .  for a zero element
##
InstallMethod( Zero,
    "for a zero element",
    [ IsAdditiveElementWithZero and IsZero ],
    Immutable );


#############################################################################
##
#M  ZeroOp( <elm> ) . . . . . . . . . . . . . for a non-copyable zero element
##
InstallMethod( ZeroOp,
    "for a (non-copyable) zero element",
    [ IsAdditiveElementWithZero and IsZero ],
    function( zero )
    if IsCopyable( zero ) then
      TryNextMethod();
    fi;
    return zero;
    end );


#############################################################################
##
#M  Zero( <elm> )
##
InstallMethod( Zero,
    "for an additive-element-with-zero (look at the family)",
    [ IsAdditiveElementWithZero ],
    function ( elm )
    local   F;
    F := FamilyObj( elm );
    if not HasZero( F ) then
      TryNextMethod();
    fi;
    return Zero( F );
    end );


#############################################################################
##
#M  ZeroOp( <elm> )
##
##  If <elm> is not copyable (and hence immutable) then we may call the
##  generic method for `ZeroImmutable' that tries to fetch a stored zero from the
##  family of <elm>.
##
InstallMethod( ZeroOp,
    "for an additive-element-with-zero (look at the family)",
    [ IsAdditiveElementWithZero ],
#T better install with requirement that the argument is not copyable?
#T or test first that the argument is not copyable?
#T (can we think of copyable arithmetic objects with non-copyable zero?)
#T (The same comments hold for `OneOp'.)
    function ( elm )
    local   F;
    F := FamilyObj( elm );
    if not HasZero( F ) then
      TryNextMethod();
    fi;
    elm:= Zero( F );
    if IsCopyable( elm ) then
      TryNextMethod();
    fi;
    return elm;
    end );


#############################################################################
##
#M  IsZero( <elm> )
##
InstallMethod( IsZero,
    "for an additive-element-with-zero",
    [ IsAdditiveElementWithZero ],
    function ( elm )
    return (elm = 0*elm);
    end );


#############################################################################
##
#M  AdditiveInverse( <elm> )
##
##  `AdditiveInverseMutable' guarantees that its results are *new* objects,
##  so we may call `MakeImmutable'.
#T This should be installed for `IsAdditiveElementWithInverse',
#T but at least in the compatibility mode we need it also for records ...
##
InstallOtherMethod( AdditiveInverse,
    "for any object (call `AdditiveInverseMutable')",
    [ IsObject ],
    function( elm )
    elm:= AdditiveInverseMutable( elm );
    MakeImmutable( elm );
    return elm;
    end );

InstallOtherMethod( AdditiveInverseSameMutability,
    "for an (immutable) object",
    [ IsObject ],
    function( elm )
    local a;
    if IsMutable( elm ) then
      TryNextMethod();
    fi;
    a:= AdditiveInverseImmutable( elm );
    MakeImmutable( a );
    return a;
    end );


#############################################################################
##
#M  AdditiveInverse( <elm> )  . . . . . . . . . . . . . .  for a zero element
##
InstallMethod( AdditiveInverse,
    "for a zero element",
    [ IsAdditiveElementWithInverse and IsZero ],
    Immutable );


#############################################################################
##
#M  AdditiveInverseOp( <elm> )  . . . . . . . for a non-copyable zero element
##
InstallMethod( AdditiveInverseOp,
    "for a (non-copyable) zero element",
    [ IsAdditiveElementWithInverse and IsZero ],
    function( zero )
    if IsCopyable( zero ) then
      TryNextMethod();
    fi;
    return zero;
    end );


#############################################################################
##
#M  <elm1>-<elm2>
##
InstallMethod( \-,
    "for external add. element, and additive-element-with-zero",
    [ IsExtAElement, IsNearAdditiveElementWithInverse ],
    DIFF_DEFAULT );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . for a mult.-elm.-with-one
##
##  `OneOp' guarantees that its results are *new* objects,
##  so we may call `MakeImmutable'.
#T This should be installed for `IsMultiplicativeElementWithOne',
#T but at least in the compatibility mode we need it also for records ...
##
InstallOtherMethod( OneImmutable,
    "for any object (call `OneOp' and make immutable)",
    [ IsObject ],
    function( elm )
    elm:= OneOp( elm );
    MakeImmutable( elm );
    return elm;
    end );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . . for an identity element
##
InstallMethod( One,
    "for an identity element",
    [ IsMultiplicativeElementWithOne and IsOne ],
    Immutable );


#############################################################################
##
#M  OneOp( <elm> )  . . . . . . . . . . . for a non-copyable identity element
##
InstallMethod( OneOp,
    "for a (non-copyable) identity element",
    [ IsMultiplicativeElementWithOne and IsOne ],
    function( one )
    if IsCopyable( one ) then
      TryNextMethod();
    fi;
    return one;
    end );


#############################################################################
##
#M  OneSameMutability( <obj> )  . . . . . . . . . . for an (immutable) object
##
##  This method is applicable for example to domains.
##
InstallOtherMethod( OneSameMutability,
    "for an (immutable) object",
    [ IsObject ],
    function( obj )
    if IsMutable( obj ) then
      TryNextMethod();
    fi;
    return OneImmutable( obj );
    end );


#############################################################################
##
#M  One( <elm> )
##
InstallMethod( One,
    "for a multiplicative-element-with-one (look at the family)",
    [ IsMultiplicativeElementWithOne ],
    function( elm )
    local   F;
    F := FamilyObj( elm );
    if not HasOne( F ) then
      TryNextMethod();
    fi;
    return One( F );
    end );


#############################################################################
##
#M  OneOp( <elm> )
##
##  If <elm> is not copyable (and hence immutable) then we may call the
##  generic method for `OneImmutable' that tries to fetch a stored identity from
##  the family of <elm>.
##
InstallMethod( OneOp,
    "for a multiplicative-element-with-one (look at the family)",
    [ IsMultiplicativeElementWithOne ],
    function ( elm )
    local   F;
    F := FamilyObj( elm );
    if not HasOne( F ) then
      TryNextMethod();
    fi;
    elm:= One( F );
    if IsCopyable( elm ) then
      TryNextMethod();
    fi;
    return elm;
    end );


#############################################################################
##
#M  IsOne( <elm> )
##
InstallMethod( IsOne,
    "for a multiplicative-element-with-one",
    [ IsMultiplicativeElementWithOne ],
    function ( elm )
    return (elm = elm^0);
    end );


#############################################################################
##
#M  Inverse( <elm> )
##
##  `InverseOp' guarantees that its results are *new* objects,
##  so we may call `MakeImmutable'.
#T This should be installed for `IsMultiplicativeElementWithInverse',
#T but at least in the compatibility mode we need it also for records ...
##
InstallOtherMethod( Inverse,
    "for any object (call `InverseOp' and make immutable)",
    [ IsObject ],
    function( elm )
    elm:= InverseOp( elm );
    MakeImmutable( elm );
    return elm;
    end );

InstallOtherMethod( InverseSameMutability,
    "for an (immutable) object",
    [ IsObject ],
    function( elm )
    local a;
    if IsMutable( elm ) then
      TryNextMethod();
    fi;
    a:= InverseOp( elm );
    MakeImmutable( a );
    return a;
    end );


#############################################################################
##
#M  Inverse( <elm> )  . . . . . . . . . . . . . . . . for an identity element
##
InstallMethod( Inverse,
    "for an identity element",
    [ IsMultiplicativeElementWithInverse and IsOne ],
    Immutable );


#############################################################################
##
#M  InverseOp( <elm> )  . . . . . . . . . for a non-copyable identity element
##
InstallMethod( InverseOp,
    "for a (non-copyable) identity element",
    [ IsMultiplicativeElementWithInverse and IsOne ],
    function( one )
    if IsCopyable( one ) then
      TryNextMethod();
    fi;
    return one;
    end );

#############################################################################
##
#M  InverseSameMutability( <elm> )  . . . for a non-copyable identity element
##
InstallMethod( InverseSameMutability,
    "for a (non-copyable) identity element",
    [ IsMultiplicativeElementWithInverse and IsOne ],
    function( one )
    if IsCopyable( one ) then
      TryNextMethod();
    fi;
    return one;
    end );


#############################################################################
##
#M  <elm1> / <elm2>
##
InstallMethod( \/,
    "for ext. r elm., and multiplicative-element-with-inverse",
    [ IsExtRElement, IsMultiplicativeElementWithInverse ],
        QUO_DEFAULT );

InstallOtherMethod( \/,
        "for multiplicative grvs which might not be IsExtRElement",
        [ IsMultiplicativeGeneralizedRowVector, IsMultiplicativeGeneralizedRowVector],
        QUO_DEFAULT);

#T
#T  This is there to handle some mgrvs, like [,2] which might not
#T  be IsExtRElement. In fact, plain lists will be caught by the
#T  kernel and x/y turned into  x*InverseSameMutability(y). This method is thus
#T  needed only for compressed matrices and other external objects
#T
#T  It isn't clear that this is the right long-term solution. It might
#T  be better to make IsMGRV imply is IsMultiplicativeObject, or some such
#T  or simply to install QUO_DEFAULT for IsObject, matching the kernel
#T  behaviour for internal objects
#T

#############################################################################
##
#M  LeftQuotient( <elm1>, <elm2> )
##
InstallMethod( LeftQuotient,
    "for multiplicative-element-with-inverse, and ext. l elm.",
    [ IsMultiplicativeElementWithInverse, IsExtLElement ],
    LQUO_DEFAULT );


#############################################################################
##
#M  <elm1> ^ <elm2>
##
InstallMethod( \^,
    "for two mult.-elm.-with-inverse",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    POW_DEFAULT );


#############################################################################
##
#M  Comm( <elm1>, <elm2> )
##
InstallMethod( Comm,
    "for two mult.-elm.-with-inverse",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    COMM_DEFAULT );


#############################################################################
##
#M  LieBracket( <elm1>, <elm2> )
##
InstallMethod( LieBracket,
    "for two ring elements",
    IsIdenticalObj,
    [ IsRingElement, IsRingElement ],
    function ( elm1, elm2 )
    return ( elm1 * elm2 ) - ( elm2 * elm1 );
    end );


#############################################################################
##
#M  <int> * <elm>
##
##  `PROD_INT_OBJ' is a kernel function that first checks whether <int> is
##  equal to one of
##  `0' (then `ZeroSameMutability' is called),
##  `1' (then a copy of <elm> is returned), or
##  `-1' (then `AdditiveInverseSameMutability' is called).
##  Otherwise if <int> is negative then the product of the additive inverses
##  of <int> and <elm> is computed,
##  where the product with positive <int> is formed by repeated doubling.
##
##  So this method is optimal if <int> is equal to `0',
##  and generic (i.e., relies only on `ZeroOp', `\+', `AdditiveInverseOp')
##  otherwise.
##
InstallOtherMethod( \*,
    "positive integer * additive element",
    [ IsPosInt, IsNearAdditiveElement ],
    PROD_INT_OBJ );

InstallOtherMethod( \*,
    "zero integer * additive element with zero",
    [ IsInt and IsZeroCyc, IsNearAdditiveElementWithZero ], SUM_FLAGS,
    PROD_INT_OBJ );

InstallOtherMethod( \*,
    "negative integer * additive element with inverse",
    [ IsNegInt, IsNearAdditiveElementWithInverse ],
    PROD_INT_OBJ );


#############################################################################
##
#M  <elm> * <int>
##
InstallOtherMethod( \*,
    "additive element * positive integer",
    [ IsNearAdditiveElement, IsPosInt ],
function(a,b)
  return PROD_INT_OBJ(b,a);
end);

InstallOtherMethod( \*,
    "additive element with zero * zero integer",
    [ IsNearAdditiveElementWithZero, IsInt and IsZeroCyc ], SUM_FLAGS,
function(a,b)
  return PROD_INT_OBJ(b,a);
end);

InstallOtherMethod( \*,
    "additive element with inverse * negative integer",
    [ IsNearAdditiveElementWithInverse, IsNegInt ],
function(a,b)
  return PROD_INT_OBJ(b,a);
end);


#############################################################################
##
#M  <elm>^<int>
##
##  `POW_OBJ_INT' is a kernel function;
##  see the comment made for `PROD_INT_OBJ' above.
##
InstallMethod( \^,
    "for mult. element, and positive integer",
    [ IsMultiplicativeElement, IsPosInt ],
    POW_OBJ_INT );

InstallMethod( \^,
    "for mult. element-with-one, and zero",
    [ IsMultiplicativeElementWithOne, IsZeroCyc ],
    POW_OBJ_INT );

InstallMethod( \^,
    "for mult. element-with-inverse, and negative integer",
    [ IsMultiplicativeElementWithInverse, IsNegInt ],
    POW_OBJ_INT );

InstallMethod( \^, "catch wrong root taking",
    [ IsMultiplicativeElement, IsRat ],
function(a,e)
  Error("^ cannot be used here to compute roots (use `RootInt' instead?)");
end);


#############################################################################
##
#M  SetElementsFamily( <Fam>, <ElmsFam> )
##
InstallMethod( SetElementsFamily,
    "method to inherit `Characteristic' to collections families",
    [ IsFamily and IsAttributeStoringRep, IsFamily ],
    function( Fam, ElmsFam )
    if HasCharacteristic( ElmsFam ) then
      SetCharacteristic( Fam, Characteristic( ElmsFam ) );
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  Characteristic(<obj>)
##
InstallMethod( Characteristic,
    "ask the family",
    [ IsObject ],
    function ( obj )
    local   F;
    F := FamilyObj( obj );
    if not HasCharacteristic( F ) then
      TryNextMethod();
    fi;
    return Characteristic( F );
end );

InstallMethod( Characteristic,
    "delegate to family (element)",
    [ IsAdditiveElementWithZero ],
    function( el )
      return Characteristic( FamilyObj(el) );
    end );

InstallMethod( Characteristic,
    "for family delegate to elements family",
    [ IsFamily and HasElementsFamily],
    function( el )
      return Characteristic( ElementsFamily(el) );
    end );

InstallMethod( Characteristic,
    "return fail",
    [ IsObject ], -SUM_FLAGS,
    ReturnFail);

#############################################################################
##
#M  Order( <obj> )
##
InstallMethod( Order,
    "for a mult. element-with-one",
    [ IsMultiplicativeElementWithOne ],
    function( obj )
    local one, pow, ord;

    # Try to get the identity of the object.
    one:= One( obj );
    if one = fail then
      Error( "<obj> has not an identity" );
    fi;

    # Check that the object is invertible.
    if Inverse( obj ) = fail then
      Error( "<obj> is not invertible" );
    fi;

    # Compute the order.
#T warnings about possibly infinite order ??
    pow:= obj;
    ord:= 1;
    while pow <> one do
    ord:= ord + 1;
      pow:= pow * obj;
    od;

    # Return the order.
    return ord;
    end );


#############################################################################
##
#M  AdditiveElementsAsMultiplicativeElementsFamily( <fam> )
##
InstallMethod(AdditiveElementsAsMultiplicativeElementsFamily,
  "for families of additive elements",[IsFamily],
function(fam)
local nfam;
  nfam:=NewFamily("AdditiveElementsAsMultiplicativeElementsFamily(...)");
  nfam!.underlyingFamily:=fam;
  nfam!.defaultType:=NewType(nfam,IsAdditiveElementAsMultiplicativeElementRep);
  nfam!.defaultTypeOne:=
    NewType(nfam,IsAdditiveElementAsMultiplicativeElementRep and
    IsMultiplicativeElementWithOne);
  nfam!.defaultTypeInverse:=
    NewType(nfam,IsAdditiveElementAsMultiplicativeElementRep and
    IsMultiplicativeElementWithInverse);
  return nfam;
end);


#############################################################################
##
#M  AdditiveElementAsMultiplicativeElement( <obj> )
##
InstallMethod(AdditiveElementAsMultiplicativeElement,"for additive elements",
  [IsAdditiveElement],function(obj)
local fam;
  fam:=AdditiveElementsAsMultiplicativeElementsFamily(FamilyObj(obj));
  return Objectify(fam!.defaultType,[obj]);
end);

InstallMethod(AdditiveElementAsMultiplicativeElement,
  "for additive elements with zero",
  [IsAdditiveElementWithZero],function(obj)
local fam;
  fam:=AdditiveElementsAsMultiplicativeElementsFamily(FamilyObj(obj));
  return Objectify(fam!.defaultTypeOne,[obj]);
end);

InstallMethod(AdditiveElementAsMultiplicativeElement,
  "for additive elements with inverse",
  [IsAdditiveElementWithInverse],function(obj)
local fam;
  fam:=AdditiveElementsAsMultiplicativeElementsFamily(FamilyObj(obj));
  return Objectify(fam!.defaultTypeInverse,[obj]);
end);

#############################################################################
##
#M  PrintObj( <wrapped-addelm> )
##
InstallMethod(PrintObj,"wrapped additive elements",
  [IsAdditiveElementAsMultiplicativeElementRep],
function(x)
  Print("AdditiveElementAsMultiplicativeElement(",x![1],")");
end);

#############################################################################
##
#M  ViewObj( <wrapped-addelm> )
##
InstallMethod(ViewObj,"wrapped additive elements",
  [IsAdditiveElementAsMultiplicativeElementRep],
function(x)
  Print("<",x![1],", +>");
end);

#############################################################################
##
#M  UnderlyingElement( <wrapped-addelm> )
##
InstallMethod(UnderlyingElement,"wrapped additive elements",
  [IsAdditiveElementAsMultiplicativeElementRep],
function(x)
  return x![1];
end);

#############################################################################
##
#M  \*( <wrapped-addelm>,<wrapped-addelm> )
##
InstallMethod(\*,"wrapped additive elements",IsIdenticalObj,
  [IsAdditiveElementAsMultiplicativeElementRep,
   IsAdditiveElementAsMultiplicativeElementRep],
function(x,y)
  # is this safe, or do we have to consider that one has and one doesn't
  # have inverses? AH
  return Objectify(TypeObj(x),[x![1]+y![1]]);
end);

#############################################################################
##
#M  \/( <wrapped-addelm>,<wrapped-addelm> )
##
InstallMethod(\/,"wrapped additive elements",IsIdenticalObj,
  [IsAdditiveElementAsMultiplicativeElementRep,
   IsAdditiveElementAsMultiplicativeElementRep and
   IsMultiplicativeElementWithInverse],
function(x,y)
  # is this safe, or do we have to consider that one has and one doesn't
  # have inverses? AH
  return Objectify(TypeObj(x),[x![1]-y![1]]);
end);

#############################################################################
##
#M  InverseOp( <wrapped-addelm> )
##
InstallMethod(InverseOp,"wrapped additive elements",
  [IsAdditiveElementAsMultiplicativeElementRep and
  IsMultiplicativeElementWithInverse],
function(x)
  return Objectify(TypeObj(x),[-x![1]]);
end);

#############################################################################
##
#M  OneOp( <wrapped-addelm> )
##
InstallMethod(OneOp,"wrapped additive elements",
  [IsAdditiveElementAsMultiplicativeElementRep and
  IsMultiplicativeElementWithOne],
function(x)
  return Objectify(TypeObj(x),[Zero(x![1])]);
end);

#############################################################################
##
#M  \^( <wrapped-addelm>,<wrapped-addelm> )
##
InstallMethod(\^,"wrapped additive elements",IsIdenticalObj,
  [IsAdditiveElementAsMultiplicativeElementRep,
   IsAdditiveElementAsMultiplicativeElementRep and
   IsMultiplicativeElementWithInverse],
function(x,y)
  # is this safe, or do we have to consider that one has and one doesn't
  # have inverses? AH
  return Objectify(TypeObj(x),[x![1]]);
end);

#############################################################################
##
#M  \<( <wrapped-addelm>,<wrapped-addelm> )
##
InstallMethod(\<,"wrapped additive elements",IsIdenticalObj,
  [IsAdditiveElementAsMultiplicativeElementRep,
   IsAdditiveElementAsMultiplicativeElementRep],
function(x,y)
  return x![1]<y![1];
end);

#############################################################################
##
#M  \=( <wrapped-addelm>,<wrapped-addelm> )
##
InstallMethod(\=,"wrapped additive elements",IsIdenticalObj,
  [IsAdditiveElementAsMultiplicativeElementRep,
   IsAdditiveElementAsMultiplicativeElementRep],
function(x,y)
  return x![1]=y![1];
end);

#############################################################################
##
#M  IsIdempotent( <elm> )
##
InstallMethod(IsIdempotent,"multiplicative element",
  [IsMultiplicativeElement],
function(x)
  return x*x = x;
end);
