#############################################################################
##
#W  arith.gi                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file  contains  the generic  methods  for elements in families  that
##  allow certain arithmetical operations.
##
Revision.arith_gi :=
    "@(#)$Id$";


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
#M  Zero( <elm> ) . . . . . . . . . . . . . . . .  for an add.-elm.-with-zero
##
##  `ZeroOp' guarantees that its results are *new* objects,
##  so we may call `MakeImmutable'.
#T This should be installed for `IsAdditiveElementWithZero',
#T but at least in the compatibility mode we need it also for records ...
##
InstallOtherMethod( Zero,
    "for any object (call `ZeroOp')",
    true,
    [ IsObject ], 0,
    function( elm )
    elm:= ZeroOp( elm );
    MakeImmutable( elm );
    return elm;
    end );
#T In cases where the OneOp result will normally be immutable, we could install 
#T OneOp itself as a method for OneAttr. This is worse if the result is mutable,
#T because a call to MakeImmutable is replaced by one to Immutable, but still 
#T works. This reduces the indirection to a method selection in these cases, 
#T which takes less than 1 microsecond on my system.
#T         Steve


#############################################################################
##
#M  Zero( <elm> ) . . . . . . . . . . . . . . . . . . . .  for a zero element
##
InstallMethod( Zero,
    "for a zero element",
    true,
    [ IsAdditiveElementWithZero and IsZero ], 0,
    Immutable );


#############################################################################
##
#M  ZeroOp( <elm> ) . . . . . . . . . . . . . for a non-copyable zero element
##
InstallMethod( ZeroOp,
    "for a (non-copyable) zero element",
    true,
    [ IsAdditiveElementWithZero and IsZero ], 0,
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
    true,
    [ IsAdditiveElementWithZero ], 0,
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
##  generic method for `ZeroAttr' that tries to fetch a stored zero from the
##  family of <elm>.
##
InstallMethod( ZeroOp,
    "for an additive-element-with-zero (look at the family)",
    true,
    [ IsAdditiveElementWithZero ], 0,
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
    true,
    [ IsAdditiveElementWithZero ], 0,
    function ( elm )
    return (elm = 0*elm);
    end );


#############################################################################
##
#M  AdditiveInverse( <elm> )
##
##  `AdditiveInverseOp' guarantees that its results are *new* objects,
##  so we may call `MakeImmutable'.
#T This should be installed for `IsAdditiveElementWithInverse',
#T but at least in the compatibility mode we need it also for records ...
##
InstallOtherMethod( AdditiveInverse,
    "for any object (call `AdditiveInverseOp')",
    true,
    [ IsObject ], 0,
    function( elm )
    elm:= AdditiveInverseOp( elm );
    MakeImmutable( elm );
    return elm;
    end );


#############################################################################
##
#M  AdditiveInverse( <elm> )  . . . . . . . . . . . . . .  for a zero element
##
InstallMethod( AdditiveInverse,
    "for a zero element",
    true,
    [ IsAdditiveElementWithInverse and IsZero ], 0,
    Immutable );


#############################################################################
##
#M  AdditiveInverseOp( <elm> )  . . . . . . . for a non-copyable zero element
##
InstallMethod( AdditiveInverseOp,
    "for a (non-copyable) zero element",
    true,
    [ IsAdditiveElementWithInverse and IsZero ], 0,
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
    true,
    [ IsExtAElement, IsNearAdditiveElementWithInverse ], 0,
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
InstallOtherMethod( One,
    "for any object (call `OneOp')",
    true,
    [ IsObject ], 0,
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
    true,
    [ IsMultiplicativeElementWithOne and IsOne ], 0,
    Immutable );


#############################################################################
##
#M  OneOp( <elm> )  . . . . . . . . . . . for a non-copyable identity element
##
InstallMethod( OneOp,
    "for a (non-copyable) identity element",
    true,
    [ IsMultiplicativeElementWithOne and IsOne ], 0,
    function( one )
    if IsCopyable( one ) then
      TryNextMethod();
    fi;
    return one;
    end );


#############################################################################
##
#M  One( <elm> )
##
InstallMethod( One,
    "for a multiplicative-element-with-one (look at the family)",
    true,
    [ IsMultiplicativeElementWithOne ], 0,
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
##  generic method for `OneAttr' that tries to fetch a stored identity from
##  the family of <elm>.
##
InstallMethod( OneOp,
    "for a multiplicative-element-with-one (look at the family)",
    true,
    [ IsMultiplicativeElementWithOne ], 0,
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
    true,
    [ IsMultiplicativeElementWithOne ], 0,
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
    "for any object (call `InverseOp')",
    true,
    [ IsObject ], 0,
    function( elm )
    elm:= InverseOp( elm );
    MakeImmutable( elm );
    return elm;
    end );


#############################################################################
##
#M  Inverse( <elm> )  . . . . . . . . . . . . . . . . for an identity element
##
InstallMethod( Inverse,
    "for an identity element",
    true,
    [ IsMultiplicativeElementWithInverse and IsOne ], 0,
    Immutable );


#############################################################################
##
#M  InverseOp( <elm> )  . . . . . . . . . for a non-copyable identity element
##
InstallMethod( InverseOp,
    "for a (non-copyable) identity element",
    true,
    [ IsMultiplicativeElementWithInverse and IsOne ], 0,
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
    true,
    [ IsExtRElement, IsMultiplicativeElementWithInverse ], 0,
    QUO_DEFAULT );


#############################################################################
##
#M  LeftQuotient( <elm1>, <elm2> )
##
InstallMethod( LeftQuotient,
    "for multiplicative-element-with-inverse, and ext. l elm.",
    true,
    [ IsMultiplicativeElementWithInverse, IsExtLElement ], 0,
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
    0,
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
    0,
    COMM_DEFAULT );


#############################################################################
##
#M  LieBracket( <elm1>, <elm2> )
##
InstallMethod( LieBracket,
    "for two ring elements",
    IsIdenticalObj,
    [ IsRingElement, IsRingElement ], 0,
    function ( elm1, elm2 )
    return ( elm1 * elm2 ) - ( elm2 * elm1 );
    end );


#############################################################################
##
#M  <int> * <elm>
##
##  `PROD_INT_OBJ' is a kernel function that first checks whether <int> is
##  equal to one of
##  `0' (then `ZERO' is called),
##  `1' (then a copy of <elm> is returned), or
##  `-1' (then `AINV' is called).
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
    true, [ IsPosInt, IsAdditiveElement ], 0,
    PROD_INT_OBJ );

InstallOtherMethod( \*,
    "zero integer * additive element with zero",
    true,
    [ IsInt and IsZeroCyc, IsAdditiveElementWithZero ], SUM_FLAGS,
    PROD_INT_OBJ );

InstallOtherMethod( \*,
    "negative integer * additive element with inverse",
    true,
    [ IsInt and IsNegRat, IsAdditiveElementWithInverse ], 0,
    PROD_INT_OBJ );

#############################################################################
##
#M  <elm> * <int>
##
InstallOtherMethod( \*,
    "additive element * positive integer",
    true,
    [ IsAdditiveElement, IsPosInt ], 0,
function(a,b)
  return PROD_INT_OBJ(b,a);
end);

InstallOtherMethod( \*,
    "additive element with zero * zero integer",
    true,
    [ IsAdditiveElementWithZero, IsInt and IsZeroCyc ], SUM_FLAGS,
function(a,b)
  return PROD_INT_OBJ(b,a);
end);

InstallOtherMethod( \*,
    "additive element with inverse * negative integer",
    true,
    [ IsAdditiveElementWithInverse, IsInt and IsNegRat ], 0,
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
    true,
    [ IsMultiplicativeElement, IsPosInt ], 0,
    POW_OBJ_INT );

InstallMethod( \^,
    "for mult. element-with-one, and zero",
    true,
    [ IsMultiplicativeElementWithOne, IsZeroCyc ], 0,
    POW_OBJ_INT );

InstallMethod( \^,
    "for mult. element-with-inverse, and negative integer",
    true,
    [ IsMultiplicativeElementWithInverse, IsInt and IsNegRat ], 0,
    POW_OBJ_INT );

InstallMethod( \^, "catch wrong root taking", true,
    [ IsMultiplicativeElement, IsRat ], 0,
function(a,e)
  Error("^ cannot be used here to compute roots (use `RootInt' instead?)");
end);


#############################################################################
##
#M  SetElementsFamily( <Fam>, <ElmsFam> )
##
InstallMethod( SetElementsFamily,
    "method to inherit `Characteristic' to collections families",
    true,
    [ IsFamily and IsAttributeStoringRep, IsFamily ], 0,
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
    "method that asks the family",
    true,
    [ IsObject ], 0,
    function ( obj )
    local   F;
    F := FamilyObj( obj );
    if not HasCharacteristic( F ) then
        TryNextMethod();
    fi;
    return Characteristic( F );
end );


#############################################################################
##
#M  Order( <obj> )
##
InstallMethod( Order,
    "for a mult. element-with-one",
    true,
    [ IsMultiplicativeElementWithOne ], 0,
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
  "for families of additive elements",true,[IsFamily],0,
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
  true,[IsAdditiveElement],0,function(obj)
local fam;
  fam:=AdditiveElementsAsMultiplicativeElementsFamily(FamilyObj(obj));
  return Objectify(fam!.defaultType,[obj]);
end);

InstallMethod(AdditiveElementAsMultiplicativeElement,
  "for additive elements with zero",
  true,[IsAdditiveElementWithZero],0,function(obj)
local fam;
  fam:=AdditiveElementsAsMultiplicativeElementsFamily(FamilyObj(obj));
  return Objectify(fam!.defaultTypeOne,[obj]);
end);

InstallMethod(AdditiveElementAsMultiplicativeElement,
  "for additive elements with inverse",
  true,[IsAdditiveElementWithInverse],0,function(obj)
local fam;
  fam:=AdditiveElementsAsMultiplicativeElementsFamily(FamilyObj(obj));
  return Objectify(fam!.defaultTypeInverse,[obj]);
end);

#############################################################################
##
#M  PrintObj( <wrapped-addelm> )
##
InstallMethod(PrintObj,"wrapped additive elements",true,
  [IsAdditiveElementAsMultiplicativeElementRep],0,
function(x)
  Print("AdditiveElementAsMultiplicativeElement(",x![1],")");
end);

#############################################################################
##
#M  ViewObj( <wrapped-addelm> )
##
InstallMethod(ViewObj,"wrapped additive elements",true,
  [IsAdditiveElementAsMultiplicativeElementRep],0,
function(x)
  Print("<",x![1],", +>");
end);

#############################################################################
##
#M  UnderlyingElement( <wrapped-addelm> )
##
InstallMethod(UnderlyingElement,"wrapped additive elements",true,
  [IsAdditiveElementAsMultiplicativeElementRep],0,
function(x)
  return x![1];
end);

#############################################################################
##
#M  \*( <wrapped-addelm>,<wrapped-addelm> )
##
InstallMethod(\*,"wrapped additive elements",IsIdenticalObj,
  [IsAdditiveElementAsMultiplicativeElementRep,
   IsAdditiveElementAsMultiplicativeElementRep],0,
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
   IsMultiplicativeElementWithInverse],0,
function(x,y)
  # is this safe, or do we have to consider that one has and one doesn't
  # have inverses? AH
  return Objectify(TypeObj(x),[x![1]-y![1]]);
end);

#############################################################################
##
#M  InverseOp( <wrapped-addelm> )
##
InstallMethod(InverseOp,"wrapped additive elements",true,
  [IsAdditiveElementAsMultiplicativeElementRep and
  IsMultiplicativeElementWithInverse],0,
function(x)
  return Objectify(TypeObj(x),[-x![1]]);
end);

#############################################################################
##
#M  OneOp( <wrapped-addelm> )
##
InstallMethod(OneOp,"wrapped additive elements",true,
  [IsAdditiveElementAsMultiplicativeElementRep and
  IsMultiplicativeElementWithOne],0,
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
   IsMultiplicativeElementWithInverse],0,
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
   IsAdditiveElementAsMultiplicativeElementRep],0,
function(x,y)
  return x![1]<y![1];
end);

#############################################################################
##
#M  \=( <wrapped-addelm>,<wrapped-addelm> )
##
InstallMethod(\=,"wrapped additive elements",IsIdenticalObj,
  [IsAdditiveElementAsMultiplicativeElementRep,
   IsAdditiveElementAsMultiplicativeElementRep],0,
function(x,y)
  return x![1]=y![1];
end);

#############################################################################
##
#M  IsIdempotent( <elm> )
##
InstallMethod(IsIdempotent,"multiplicative element",true,
  [IsMultiplicativeElement],0,
function(x)
  return x*x = x;
end);


#############################################################################
##
#E

