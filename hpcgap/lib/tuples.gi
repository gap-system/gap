#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for direct product elements.
##


#############################################################################
##
#V  DIRECT_PRODUCT_ELEMENT_FAMILIES . . . all direct product element families
#V                                                             so far created
##
##  <ManSection>
##  <Var Name="DIRECT_PRODUCT_ELEMENT_FAMILIES"/>
##
##  <Description>
##  <Ref Var="DIRECT_PRODUCT_ELEMENT_FAMILIES"/> is a list whose <M>i</M>-th
##  component is a weak pointer object containing all currently known
##  families of <M>i+1</M> component direct product elements.
##  </Description>
##  </ManSection>
##
EmptyDirectProductElementsFamily!.defaultTupleType:= NewType(
    EmptyDirectProductElementsFamily, IsDefaultDirectProductElementRep );

SetComponentsOfDirectProductElementsFamily( EmptyDirectProductElementsFamily,
    [] );

BindGlobal( "DIRECT_PRODUCT_ELEMENT_FAMILIES",
    [ [ EmptyDirectProductElementsFamily ] ] );
ShareSpecialObj( DIRECT_PRODUCT_ELEMENT_FAMILIES );


#############################################################################
##
#M  DirectProductElementsFamily( <famlist> )  . . .  family of direct product
#M                                                                   elements
##
InstallMethod( DirectProductElementsFamily,
    "for a collection (of families)",
    fam -> fam = CollectionsFamily(FamilyOfFamilies),
    [ IsCollection ],
    function( famlist )
    local n, tupfams, freepos, len, i, fam, tuplespos,
          tuplesfam,filter,filter2;

    atomic readwrite DIRECT_PRODUCT_ELEMENT_FAMILIES do

    n := Length(famlist);
    if not IsBound(DIRECT_PRODUCT_ELEMENT_FAMILIES[n+1]) then
      tupfams:= WeakPointerObj( [] );
      tupfams:= MigrateObj( tupfams, DIRECT_PRODUCT_ELEMENT_FAMILIES );
      DIRECT_PRODUCT_ELEMENT_FAMILIES[n+1]:= tupfams;
      freepos:= 1;
    else
      tupfams:= DIRECT_PRODUCT_ELEMENT_FAMILIES[n+1];
      len:= LengthWPObj( tupfams );
      for i in [ 1 .. len+1 ]  do
        fam:= ElmWPObj( tupfams, i );
        if fam = fail then
          if not IsBound( freepos ) then
            freepos:= i;
          fi;
        elif ComponentsOfDirectProductElementsFamily( fam ) = famlist then
          tuplespos:= i;
          break;
        fi;
      od;
    fi;

    if IsBound( tuplespos ) then
      Info( InfoDirectProductElements, 2,
            "Reused direct product elements family, length ", n );
      tuplesfam:= tupfams[ tuplespos ];
    else
      Info( InfoDirectProductElements, 1,
            "Created new direct product elements family, length ", n );
      filter:=IsDirectProductElement;
      filter2:=IsDirectProductElementFamily;
      # inherit positive element comparison from the families but do not
      # trigger the computation.
      if ForAll(famlist,i->HasCanEasilySortElements(i) and
       CanEasilySortElements(i)) then
        filter:=filter and CanEasilySortElements;
        filter2:=filter2 and CanEasilySortElements;
      elif ForAll(famlist,i->HasCanEasilyCompareElements(i) and
        CanEasilyCompareElements(i)) then
        filter:=filter and CanEasilyCompareElements;
        filter2:=filter2 and CanEasilyCompareElements;
      fi;
      tuplesfam:= NewFamily( "DirectProductElementsFamily( <<famlist>> )",
                             IsDirectProductElement, filter, filter2 );
      SetComponentsOfDirectProductElementsFamily( tuplesfam,
          Immutable( famlist ) );
      SetElmWPObj( tupfams, freepos, tuplesfam );
      tuplesfam!.defaultTupleType:= NewType( tuplesfam,
                                        IsDefaultDirectProductElementRep );
    fi;

    return tuplesfam;
    od;
    end );


#############################################################################
##
#M  DirectProductElementsFamily( [] ) . . . .  family of empty direct product
#M                                                                 element(s)
##
InstallOtherMethod( DirectProductElementsFamily,
    "for an empty list",
    [ IsList and IsEmpty ],
    function( empty )
    Info( InfoDirectProductElements, 2,
          "Reused direct product elements family, length 0 ");
    atomic readonly DIRECT_PRODUCT_ELEMENT_FAMILIES do
      return DIRECT_PRODUCT_ELEMENT_FAMILIES[1][1];
    od;
    end );


#############################################################################
##
#M  DirectProductElement( <objlist> ) . . . . . make a direct product element
##
InstallMethod( DirectProductElement,
    "for a list",
    [ IsList ],
    function( objlist )
    local fam;
    fam := DirectProductElementsFamily( List(objlist, FamilyObj) );
    return DirectProductElementNC( fam, objlist );
    end );


#############################################################################
##
#M  DirectProductElement( <fam>, <objlist> )  . make a direct product element
##
InstallOtherMethod( DirectProductElement,
    "for a direct product elements family, and a list",
    [ IsDirectProductElementFamily, IsList ],
    function( fam, objlist )
    while ComponentsOfDirectProductElementsFamily( fam )
          <> List( objlist, FamilyObj ) do
      objlist:=
          Error( "objects not of proper families for direct product ",
                 "elements family supplied, you may supply replacements" );
    od;
    return DirectProductElementNC( fam, objlist );
    end );

#############################################################################
##
#M  String( <dpelm> )  . . . . . . convert a direct product element to string
##
InstallMethod( String,
    "for a direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    local i, str;
    str := "DirectProductElement( [ ";
    if Length( dpelm ) > 0 then
      Append( str, String( dpelm[1] ) );
    fi;
    for i in [ 2 .. Length( dpelm ) ] do
      Append( str, ", " );
      Append( str, String( dpelm[i] ) );
    od;
    Append( str, " ] )" );
    return str;
    end );

#############################################################################
##
#M  PrintString( <dpelm> ) . convert a direct product element to print string
##
InstallMethod( PrintString,
    "for a direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    local i, str;
    str := "DirectProductElement( [ ";
    if Length( dpelm ) > 0 then
      Append( str, PrintString( dpelm[1] ) );
    fi;
    for i in [ 2 .. Length( dpelm ) ] do
      Append( str, ",\<\> " );
      Append( str, PrintString( dpelm[i] ) );
    od;
    Append( str, " ] )" );
    return str;
    end );


#############################################################################
##
#M  ViewObj( <dpelm> ) . . . . . . . . . . . .  view a direct product element
##
InstallMethod( ViewObj,
    "for a direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    Print( "DirectProductElement( " );
    Print( ViewString( AsList( (dpelm) ) ) );
    Print(" )");
    end );


#############################################################################
##
#M  <dpelm1> <  <dpelm2> . . . . . . . . . . . . . . . . . . . . . comparison
##
InstallMethod( \<,
    "for two direct product elements",
    IsIdenticalObj,
    [ IsDirectProductElement, IsDirectProductElement ],
    function( dpelm1, dpelm2 )
    local i;
    for i in [1..Length(dpelm1)] do
      if dpelm1[i] < dpelm2[i] then
        return true;
      elif dpelm1[i] > dpelm2[i] then
        return false;
      fi;
    od;
    return false;
    end );


#############################################################################
##
#M  <dpelm1> = <dpelm2>  . . . . . . . . . . . . . . . . . . . . . comparison
##
InstallMethod( \=,
    "for two direct product elements",
    IsIdenticalObj,
    [ IsDirectProductElement, IsDirectProductElement ],
    function( dpelm1, dpelm2 )
    local i;
    for i in [1..Length(dpelm1)] do
      if dpelm1[i] <> dpelm2[i] then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  CanEasilyCompareElements( <dpelm> )
##
InstallMethod( CanEasilyCompareElements,
    "for direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    local i;
    for i in dpelm do
      if not CanEasilyCompareElements( i ) then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  DirectProductElementNC( <dpelmfam>, <objlist> )   . make a direct product
#M                                                                    element
##
##  Note that we really have to copy the list passed, even if it is immutable
##  as we are going to call `Objectify'.
##
InstallMethod( DirectProductElementNC,
    "for a direct product elements family, and a list",
    [ IsDirectProductElementFamily, IsList ],
    function( fam, objlist )
    local t;
    Assert( 2, ComponentsOfDirectProductElementsFamily( fam )
                   = List( objlist, FamilyObj ) );
    t:= Objectify( fam!.defaultTupleType,
            PlainListCopy( List( objlist, Immutable ) ) );
    Info( InfoDirectProductElements, 3,
          "Created a new DirectProductElement ", t );
    return t;
    end );


#############################################################################
##
#M  <dpelm>[ <index> ] . . . . . . . . . . . . . . . . . . . component access
##
InstallMethod( \[\],
    "for a direct product element in default repres., and a pos. integer",
    [ IsDefaultDirectProductElementRep, IsPosInt ],
    function( dpelm, index )
    while index > Length( dpelm ) do
      index:= Error( "<index> too large for <dpelm>, ",
                     "you may return another index" );
    od;
    return dpelm![index];
    end );


#############################################################################
##
#M  Length( <dpelm> )  . . . . . . . . . . . . . . . . . number of components
##
InstallMethod( Length,
    "for a direct product element in default representation",
    [ IsDefaultDirectProductElementRep ],
    function( dpelm )
    return Length( ComponentsOfDirectProductElementsFamily(
                       FamilyObj( dpelm ) ) );
    end );


#############################################################################
##
#M  InverseOp( <dpelm> )
##
InstallMethod( InverseOp,
    "for a direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    return DirectProductElement( List( dpelm, Inverse ) );
    end );


#############################################################################
##
#M  OneOp( <dpelm> )
##
InstallMethod( OneOp,
    "for a direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    return DirectProductElement( List( dpelm, One ) );
    end );


#############################################################################
##
#M  \*( <dpelm>, <dpelm> )
##
InstallMethod( \*,
    "for two direct product elements",
    [ IsDirectProductElement, IsDirectProductElement ],
    function( elm1, elm2 )
    local n;
    n := Length( elm1 );
    return DirectProductElement( List( [1..n], x -> elm1[x]*elm2[x] ) );
    end );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <list> )
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for list of direct product elements",
    [ IsDirectProductElementCollection ],
    function( l )
        local n;
        if IsEmpty (l) then
            return true;
        fi;
        n := Length (l[1]);
        if ForAny (l, x -> Length (x) <> n) then
            return false;
        fi;
        return ForAll( [ 1 .. n ],
            i -> IsGeneratorsOfMagmaWithInverses (l{[1..Length(l)]}[i]));
    end );

#############################################################################
##
#M  \^( <dpelm>, <integer> )
##
InstallMethod( \^,
    "for direct product element, and integer",
    [ IsDirectProductElement, IsInt ],
    function( dpelm, x )
    return DirectProductElement( List( dpelm, y -> y^x ) );
    end );


#############################################################################
##
#M  AdditiveInverseOp( <dpelm> )
##
InstallMethod( AdditiveInverseOp,
    "for a direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    return DirectProductElement( List( dpelm, AdditiveInverse ) );
    end );


#############################################################################
##
#M  ZeroOp( <dpelm> )
##
InstallMethod( ZeroOp,
    "for a direct product element",
    [ IsDirectProductElement ],
    function( dpelm )
    return DirectProductElement( List( dpelm, Zero ) );
    end );


#############################################################################
##
#M  \+( <dpelm1>, <dpelm2> )
##
InstallMethod( \+,
    "for two direct product elements",
    [ IsDirectProductElement, IsDirectProductElement ],
    function( dpelm1, dpelm2 )
    local n;
    n := Length( dpelm1 );
    return DirectProductElement( List( [1..n], x -> dpelm1[x]+dpelm2[x] ) );
    end );


#############################################################################
##
#M  \+( <dpelm>, <defaultlist> )
#M  \+( <defaultlist>, <dpelm> )
#M  \*( <dpelm>, <defaultlist> )
#M  \*( <defaultlist>, <dpelm> )
#M  \+( <dpelm>, <nonlist> )
#M  \+( <nonlist>, <dpelm> )
#M  \*( <dpelm>, <nonlist> )
#M  \*( <nonlist>, <dpelm> )
##
##  Direct product elements do *not* lie in `IsGeneralizedRowVector',
##  since they shall behave as scalars;
##  for example we want the sum of a direct product element and a list of
##  direct product elements to be the list of sums.
##  (It would also be possible to make them generalized row vectors with
##  additive and multiplicative nesting depth zero, but then the nesting
##  depths would have to be calculated whenever they are needed.
##  In fact I think this approach would be equivalent.)
##
##  Because direct product elements are lists, there are no default methods
##  for adding or multiplying a direct product element and a default list.
##  So we install such methods where direct product elements act as scalars.
##  Analogously,
##  we define the sum and the product of a direct product element
##  with a non-list as the direct product element of componentwise sums and
##  products, respectively.
##
#T As soon as IsListDefault implies IsAdditiveElement and
#T IsMultiplicativeElement, the InstallOtherMethod in the first four
#T of the following methods can be replaced by InstallMethod!
InstallOtherMethod( \+,
    "for a direct product element, and a default list",
    [ IsDirectProductElement, IsListDefault ],
    SUM_SCL_LIST_DEFAULT );

InstallOtherMethod( \+,
    "for a default list, and a direct product element",
    [ IsListDefault, IsDirectProductElement ],
    SUM_LIST_SCL_DEFAULT );

InstallOtherMethod( \*,
    "for a direct product element, and a default list",
    [ IsDirectProductElement, IsListDefault ],
    PROD_SCL_LIST_DEFAULT );

InstallOtherMethod( \*,
    "for a default list, and a direct product element",
    [ IsListDefault, IsDirectProductElement ],
    PROD_LIST_SCL_DEFAULT );

InstallOtherMethod( \+,
    "for a direct product element, and a non-list",
    [ IsDirectProductElement, IsObject ],
    function( dpelm, nonlist )
    if IsListOrCollection( nonlist ) then
      TryNextMethod();
    fi;
    return DirectProductElement( List( dpelm, entry -> entry + nonlist ) );
    end );

InstallOtherMethod( \+,
    "for a non-list, and a direct product element",
    [ IsObject, IsDirectProductElement ],
    function( nonlist, dpelm )
    if IsListOrCollection( nonlist ) then
      TryNextMethod();
    fi;
    return DirectProductElement( List( dpelm, entry -> nonlist + entry ) );
    end );

InstallOtherMethod( \*,
    "for a direct product element, and a non-list",
    [ IsDirectProductElement, IsObject ],
    function( dpelm, nonlist )
    if IsListOrCollection( nonlist ) then
      TryNextMethod();
    fi;
    return DirectProductElement( List( dpelm, entry -> entry * nonlist ) );
    end );

InstallOtherMethod( \*,
    "for a non-list, and a direct product element",
    [ IsObject, IsDirectProductElement ],
    function( nonlist, dpelm )
    if IsListOrCollection( nonlist ) then
      TryNextMethod();
    fi;
    return DirectProductElement( List( dpelm, entry -> nonlist * entry ) );
    end );


#############################################################################
##
##
InstallGlobalFunction( DirectProductFamily,
    function( args )
    if not IsDenseList(args) or not ForAll(args, IsCollectionFamily) then
        ErrorNoReturn("<args> must be a dense list of collection families");
    fi;
    return CollectionsFamily(
        DirectProductElementsFamily( List( args, ElementsFamily ) )
    );
    end );
