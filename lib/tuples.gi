#############################################################################
##
#W  tuples.gi                   GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for tuples.
##
Revision.tuples_gi :=
  "@(#)$Id$";


#############################################################################
##
#V  InfoTuples . . . . . . . . . . . . . . . . . . . . . . . . . . Info Class
##
DeclareInfoClass( "InfoTuples" );


#############################################################################
##
#R  IsDefaultTupleRep( <obj> )  . . . . .  representation as component object
##
DeclareRepresentation( "IsDefaultTupleRep",
    IsPositionalObjectRep and IsTuple, [] );


#############################################################################
##
#V  TUPLES_FAMILIES  . . . . . . . . . . . . . .  list of all tuples families
##
BindGlobal( "EmptyTuplesFamily",
    NewFamily( "TuplesFamily([])", IsTuple, IsTuple ) );

EmptyTuplesFamily!.defaultTupleType:= NewType( EmptyTuplesFamily,
                                               IsDefaultTupleRep );

SetComponentsOfTuplesFamily( EmptyTuplesFamily, [] );

InstallValue( TUPLES_FAMILIES, [ [ EmptyTuplesFamily ] ] );


#############################################################################
##
#M  TuplesFamily( <famlist> )  . . . . . . . . . family of tuples of elements
##
InstallMethod( TuplesFamily,
    "for a collection (of families)",
    fam -> fam = CollectionsFamily(FamilyOfFamilies),
    [ IsCollection ],
    function( famlist )
    local n, tupfams, freepos, len, i, fam, tuplespos,
          tuplesfam,filter,filter2;

    n := Length(famlist);
    if not IsBound(TUPLES_FAMILIES[n+1]) then
      tupfams:= WeakPointerObj( [] );
      TUPLES_FAMILIES[n+1]:= tupfams;
      freepos:= 1;
    else
      tupfams:= TUPLES_FAMILIES[n+1];
      len:= LengthWPObj( tupfams );
      for i in [ 1 .. len+1 ]  do
        fam:= ElmWPObj( tupfams, i );
        if fam = fail then
          if not IsBound( freepos ) then
            freepos:= i;
          fi;
        elif ComponentsOfTuplesFamily( fam ) = famlist then
          tuplespos:= i;
          break;
        fi;
      od;
    fi;

    if IsBound( tuplespos ) then
      Info( InfoTuples, 2, "Reused tuples family, length ", n );
      tuplesfam:= tupfams[ tuplespos ];
    else
      Info( InfoTuples, 1, "Created new tuples family, length ", n );
      filter:=IsTuple;
      filter2:=IsTupleFamily;
      # inherit positive element comparison from the families but do not
      # trigger the computation.
      if ForAll(famlist,i->HasCanEasilyCompareElements(i) and
       CanEasilySortElements(i)) then
        filter:=filter and CanEasilySortElements;
        filter2:=filter2 and CanEasilySortElements;
      elif ForAll(famlist,i->HasCanEasilyCompareElements(i) and
        CanEasilyCompareElements(i)) then
        filter:=filter and CanEasilyCompareElements;
        filter2:=filter2 and CanEasilyCompareElements;
      fi;
      tuplesfam:= NewFamily( "TuplesFamily( <<famlist>> )",
                             IsTuple , filter,filter2);
      SetComponentsOfTuplesFamily( tuplesfam, Immutable( famlist ) );
      SetElmWPObj( tupfams, freepos, tuplesfam );
      tuplesfam!.defaultTupleType:=NewType(tuplesfam,  IsDefaultTupleRep );
    fi;

    return tuplesfam;
    end );


#############################################################################
##
#M  TuplesFamily( [] ) . . . . . . . . . . . . . . . .  family of empty tuple
##
InstallOtherMethod( TuplesFamily,
    "for an empty list",
    [ IsList and IsEmpty ],
    function( empty )
    Info(InfoTuples, 2, "Reused tuples family, length 0");
    return TUPLES_FAMILIES[1][1];
    end );


#############################################################################
##
#M  Tuple( <objlist> ) . . . . . . . . . . . . . . . . . . . . . make a tuple
##
InstallMethod( Tuple,
    "for a list",
    [ IsList ],
    function( objlist )
    local fam;
    fam := TuplesFamily( List(objlist, FamilyObj) );
    return TupleNC ( fam, objlist );
    end );


#############################################################################
##
#M  Tuple( <tuplesfam>, <objlist> )  . . . . . . . . . . . . . . make a tuple
##
InstallOtherMethod( Tuple,
    "for a tuples family, and a list",
    [ IsTupleFamily, IsList ],
    function( fam, objlist )
    while ComponentsOfTuplesFamily(fam) <>  List(objlist, FamilyObj) do
      objlist :=
          Error( "objects not of proper families for tuples family supplied, you may supply replacements");
    od;
    return TupleNC ( fam, objlist );
    end );


#############################################################################
##
#M  PrintObj( <tuple> )  . . . . . . . . . . . . . . . . . . .  print a tuple
#M  ViewObj( <tuple> ) . . . . . . . . . . . . . . . . . . . . . view a tuple
##
##  We install a special `ViewObj' method because as soon as a tuple stores
##  that it is finite (this happens for example in a call to `ShallowCopy'),
##  the `ViewObj' method for finite lists would strike.
##
InstallMethod( PrintObj,
    "for a tuple",
    [ IsTuple ],
    function( tuple )
    local i;
    Print("Tuple( [ ");
    for i in [1.. Length(tuple)-1] do
      Print(tuple[i],", ");
    od;
    if Length(tuple) <> 0 then
      Print(tuple[Length(tuple)]);
    fi;
    Print(" ] )");
    end );

InstallMethod( ViewObj,
    "for a tuple (call `PrintObj')",
    [ IsTuple ],
    PrintObj );


#############################################################################
##
#M  <tuple1> <  <tuple2> . . . . . . . . . . . . . . . . . . . . . comparison
##
InstallMethod( \<,
    "for two tuples",
    IsIdenticalObj,
    [ IsTuple, IsTuple ],
    function (tuple1, tuple2)
    local i;
    for i in [1..Length(tuple1)] do
      if tuple1[i] < tuple2[i] then
        return true;
      elif tuple1[i] > tuple2[i] then
        return false;
      fi;
    od;
    return false;
    end );


#############################################################################
##
#M  <tuple1> = <tuple2>  . . . . . . . . . . . . . . . . . . . . . comparison
##
InstallMethod( \=,
    "for two tuples",
    IsIdenticalObj,
    [ IsTuple, IsTuple ],
    function (tuple1, tuple2)
    local i;
    for i in [1..Length(tuple1)] do
      if tuple1[i] <> tuple2[i] then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  CanEasilyCompareElements( <tup> )
##
InstallMethod( CanEasilyCompareElements,
    "for tuple",
    [ IsTuple ],
    function(tup)
    local i;
    for i in [1..Length(tup)] do
      if not CanEasilyCompareElements(tup[i]) then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  TupleNC( <tuplesfam>, <objlist> )  . . . . . . . . . . . . . make a tuple
##
##  Note that we really have to copy the list passed, even if it is Immutable
##  as we are going to Objectify it.
##
InstallMethod( TupleNC,
    "for a tuples family, and a list",
    [ IsTupleFamily, IsList ],
    function( fam, objlist )
    local t;
    Assert(2, ComponentsOfTuplesFamily( fam ) = List(objlist, FamilyObj));
    t := Objectify( fam!.defaultTupleType,
         PlainListCopy(List(objlist, Immutable)) );
    Info(InfoTuples,3,"Created a new Tuple ",t);
    return t;
    end );


#############################################################################
##
#M  <tuple>[ <index> ] . . . . . . . . . . . . . . . . . . . component access
##
InstallMethod( \[\],
    "for a tuple in default representation, and a positive integer",
    [ IsDefaultTupleRep, IsPosInt ],
    function( tuple, index )
    while index > Length(tuple) do
      index:= Error( "<index> too large for <tuple>, you may return another index" );
    od;
    return tuple![index];
    end );


#############################################################################
##
#M  Length( <tuple> )  . . . . . . . . . . . . . . . . . number of components
##
InstallMethod( Length,
    "for a tuple in default representation",
    [ IsDefaultTupleRep ],
    function( tuple )
    return Length(ComponentsOfTuplesFamily( FamilyObj (tuple)));
    end );


#############################################################################
##
#M  InverseOp( <tuple> )
##
InstallMethod( InverseOp,
    "for a tuple",
    [ IsTuple ],
    function( elm )
    return Tuple( List( elm, Inverse ) );
    end );


#############################################################################
##
#M  OneOp( <tuple> )
##
InstallMethod( OneOp,
    "for a tuple",
    [ IsTuple ],
    function( elm )
    return Tuple( List( elm, One ) );
    end );


#############################################################################
##
#M  \*( <tuple>, <tuple> )
##
InstallMethod( \*,
    "for two tuples",
    [ IsTuple, IsTuple ],
    function( elm1, elm2 )
    local n;
    n := Length( elm1 );
    return Tuple( List( [1..n], x -> elm1[x]*elm2[x] ) );
    end );


#############################################################################
##
#M  \^( <tuple>, <integer> )
##
InstallMethod( \^,
    "for tuple, and integer",
    [ IsTuple, IsInt ],
    function( elm, x )
    return Tuple( List( elm, y -> y^x ) );
    end );


#############################################################################
##
#M  AdditiveInverseOp( <tuple> )
##
InstallMethod( AdditiveInverseOp,
    "for a tuple",
    [ IsTuple ],
    function( elm )
    return Tuple( List( elm, AdditiveInverse ) );
    end );


#############################################################################
##
#M  ZeroOp( <tuple> )
##
InstallMethod( ZeroOp,
    "for a tuple",
    [ IsTuple ],
    function( elm )
    return Tuple( List( elm, Zero ) );
    end );


#############################################################################
##
#M  \+( <tuple>, <tuple> )
##
InstallMethod( \+,
    "for two tuples",
    [ IsTuple, IsTuple ],
    function( elm1, elm2 )
    local n;
    n := Length( elm1 );
    return Tuple( List( [1..n], x -> elm1[x]+elm2[x] ) );
    end );


#############################################################################
##
#M  \+( <tuple>, <defaultlist> )
#M  \+( <defaultlist>, <tuple> )
#M  \*( <tuple>, <defaultlist> )
#M  \*( <defaultlist>, <tuple> )
#M  \+( <tuple>, <nonlist> )
#M  \+( <nonlist>, <tuple> )
#M  \*( <tuple>, <nonlist> )
#M  \*( <nonlist>, <tuple> )
##
##  Tuples do *not* lie in `IsGeneralizedRowVector', since they shall behave
##  as scalars; for example we want the sum of a tuple and a list of tuples
##  to be the list of sums.
##  (It would also be possible to make them generalized row vectors with
##  additive and multiplicative nesting depth zero, but then the nesting
##  depths would have to be calculated whenever they are needed.
##  In fact I think this approach would be equivalent.)
##
##  Because tuples are lists, there are no default methods for adding or
##  multiplying a tuple and a default list.
##  So we install such methods where tuples act as scalars.
##  Analogously, we define the sum and the product of a tuple with a non-list
##  as the tuple of componentwise sums and products, respectively.
##
#T As soon as IsListDefault implies IsAdditiveElement and
#T IsMultiplicativeElement, the InstallOtherMethod in the first four
#T of the following methods can be replaced by InstallMethod!
InstallOtherMethod( \+,
    "for a tuple, and a default list",
    [ IsTuple, IsListDefault ],
    SUM_SCL_LIST_DEFAULT );

InstallOtherMethod( \+,
    "for a default list, and a tuple",
    [ IsListDefault, IsTuple ],
    SUM_LIST_SCL_DEFAULT );

InstallOtherMethod( \*,
    "for a tuple, and a default list",
    [ IsTuple, IsListDefault ],
    PROD_SCL_LIST_DEFAULT );

InstallOtherMethod( \*,
    "for a default list, and a tuple",
    [ IsListDefault, IsTuple ],
    PROD_LIST_SCL_DEFAULT );

InstallOtherMethod( \+,
    "for a tuple, and a non-list",
    [ IsTuple, IsObject ],
    function( tuple, nonlist )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return Tuple( List( tuple, entry -> entry + nonlist ) );
    end );

InstallOtherMethod( \+,
    "for a non-list, and a tuple",
    [ IsObject, IsTuple ],
    function( nonlist, tuple )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return Tuple( List( tuple, entry -> nonlist + entry ) );
    end );

InstallOtherMethod( \*,
    "for a tuple, and a non-list",
    [ IsTuple, IsObject ],
    function( tuple, nonlist )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return Tuple( List( tuple, entry -> entry * nonlist ) );
    end );

InstallOtherMethod( \*,
    "for a non-list, and a tuple",
    [ IsObject, IsTuple ],
    function( nonlist, tuple )
    if IsList( nonlist ) then
      TryNextMethod();
    fi;
    return Tuple( List( tuple, entry -> nonlist * entry ) );
    end );


#############################################################################
##
#E

