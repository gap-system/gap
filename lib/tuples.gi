#############################################################################
##
#W  tuples.gi                   GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for tuples
##
Revision.tuples_gi :=
  "@(#)$Id$";

#############################################################################
##
#V  InfoTuples . . . . . . . . . . . . . . . . . . . . . . . . . . Info Class
##

DeclareInfoClass("InfoTuples");


#############################################################################
##
#V  TUPLES_FAMILIES . . . . . . . . . . . . . . . list of all tuples families
##

EmptyTuplesFamily := NewFamily( "TuplesFamily([])", IsTuple , IsTuple );

SetComponentsOfTuplesFamily(EmptyTuplesFamily, []);

InstallValue( TUPLES_FAMILIES, [ [ EmptyTuplesFamily ] ] );


#############################################################################
##
#M  TuplesFamily ( <famlist> ) . . . . . . . . . family of tuples of elements
##
##

InstallMethod( TuplesFamily, 
    "for a collection (of families)",
        fam -> fam = CollectionsFamily(FamilyOfFamilies), 
        [ IsCollection ], 0,
        function( famlist )
    local n, tupfams, freepos, len, i, fam, tuplespos, tuplesfam;

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
      tuplesfam:= NewFamily( "TuplesFamily( <<famlist>> )", 
                             IsTuple , IsTuple, IsTupleFamily );
      SetComponentsOfTuplesFamily( tuplesfam, Immutable( famlist ) );
      SetElmWPObj( tupfams, freepos, tuplesfam );
    fi;

    return tuplesfam;
end);
                         
#############################################################################
##
#M  TuplesFamily ( [] ) . . .  . . . . . . . . . . . . .family of empty tuple
##

InstallOtherMethod( TuplesFamily, 
    "for an empty list",
        true, [ IsList and IsEmpty ], 0,
        function( empty )
    Info(InfoTuples, 2, "Reused tuples family, length 0");
    return TUPLES_FAMILIES[1][1];
end);

#############################################################################
##
#M  Tuple ( <objlist> ) . . . . . . . . . . . . . . . . . . . . .make a tuple
##
##

InstallMethod( Tuple,
    "for a list",
    true, [ IsList ], 0,
        function( objlist )
    local fam;
    fam := TuplesFamily( List(objlist, FamilyObj) );
    return TupleNC ( fam, objlist );
end);

#############################################################################
##
#M  Tuple ( <tuplesfam>, <objlist> ) . . . . . . . . . . . . . . make a tuple
##

InstallOtherMethod( Tuple,
    "for a tuples family, and a list",
    true, [ IsTupleFamily, IsList ], 0,
        function( fam, objlist )
    while ComponentsOfTuplesFamily(fam) <>  List(objlist, FamilyObj) do
        objlist := 
          Error( "objects not of proper families for tuples family supplied, you may supply replacements");
    od;
    return TupleNC ( fam, objlist );
end);





##############################################################################
##
#M  PrintObj( <tuple> ) . . . . . . . . . . . . . . . . . . . .  print a tuple
##

InstallMethod( PrintObj,
    "for a tuple",
    true, [ IsTuple ], 0,
        function (tuple) 
    local i;
    Print("Tuple( [ ");
    for i in [1.. Length(tuple)-1] do
        Print(tuple[i],", ");
    od;
    if Length(tuple) <> 0 then
        Print(tuple[Length(tuple)]);
    fi;
    Print(" ] )");
end);


##############################################################################
##
#M  <tuple1> <  <tuple2>. . . . . . . . . . . . . . . . . . . . . . comparison
##
##

InstallMethod( \<,
    "for two tuples",
    IsIdenticalObj, [ IsTuple, IsTuple ], 0,
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
end);

##############################################################################
##
#M  <tuple1> =  <tuple2>. . . . . . . . . . . . . . . . . . . . . . comparison
##
##

InstallMethod( \=,
    "for two tuples",
    IsIdenticalObj, [ IsTuple, IsTuple ], 0,
        function (tuple1, tuple2) 
    local i;
    for i in [1..Length(tuple1)] do
        if tuple1[i] <> tuple2[i] then
            return false;
        fi;
    od;
    return true;
end);



#############################################################################
##
#R  IsDefaultTupleRep ( <obj> ) . . . . .  representation as component object
##

DeclareRepresentation( "IsDefaultTupleRep", 
                             IsComponentObjectRep and IsTuple, [] );


#############################################################################
##
#M  TupleNC ( <tuplesfam>, <objlist> ) . . . . . . . . . . . . . make a tuple
##
##  Note that we really have to copy the list passed, even if it is Immutable
##  as we are going to Objectify it.
##

InstallMethod( TupleNC,
    "for a tuples family, and a list",
    true, [ IsTupleFamily, IsList ], 0,
        function( fam, objlist )
    local t;
    Assert(2, ComponentsOfTuplesFamily( fam ) = List(objlist, FamilyObj));
    t := Objectify( NewType(fam,  IsDefaultTupleRep ), 
         List(objlist, Immutable) );
    Info(InfoTuples,3,"Created a new Tuple ",t);
    return t;
end);


##############################################################################
##
#M  <tuple> [ <index> ] .. . . . . . . . . . . . . . . . . . .component access
##
##

InstallMethod( \[\],
    "for a tuple in default representation, and a positive integer",
    true, [ IsDefaultTupleRep, IsPosInt ], 0,
        function (tuple, index) 
    while index > Length(tuple) do
        index := Error("Index too large for tuple, you may return another index");
    od;
    return tuple![index];
end);

##############################################################################
##
#M  Length ( <tuple> ) . .  . . . . . . . . . . . . . . . number of components
##
##

InstallMethod( Length,
    "for a tuple in default representation",
    true, [ IsDefaultTupleRep ], 0,
        function (tuple) 
    return Length(ComponentsOfTuplesFamily( FamilyObj (tuple)));
end);

##############################################################################
##
#M  Inverse( <tuple> )
##
InstallMethod( Inverse,
    "for a tuple",
    true, [ IsTuple ], 0,
function( elm )
    return Tuple( List( elm, Inverse ) );
end );

##############################################################################
##
#M  One( <tuple> )
##
InstallMethod( One,
    "for a tuple",
    true, [ IsTuple ], 0,
function( elm )
    return Tuple( List( elm, One ) );
end);

##############################################################################
##
#M  \*( <tuple>, <tuple> )
##
InstallMethod( \*,
    "for two tuples",
    true, [ IsTuple, IsTuple ], 0,
function( elm1, elm2 )
    local n;
    n := Length( elm1 );
    return Tuple( List( [1..n], x -> elm1[x]*elm2[x] ) );
end );

##############################################################################
##
#M  \^( <tuple>, <tuple> ) 
##
InstallMethod( \^,
    "for tuple, and integer",
    true, [ IsTuple, IsInt ], 0,
function( elm, x )
    return Tuple( List( elm, y -> y^x ) );
end);


#############################################################################
##
#E  tuples.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

