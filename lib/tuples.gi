#############################################################################
##
#W  tuples.gi                   GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for tuples
##
Revision.tuples_gi :=
  "@(#)$Id$";

#############################################################################
##
#V  InfoTuples . . . . . . . . . . . . . . . . . . . . . . . . . . Info Class
##

InfoTuples := NewInfoClass("InfoTuples");


#############################################################################
##
#M  HasComponentsOfTuplesFamily( <tuplesfam> ) . . . . . . . . . .always there
##

InstallTrueMethod( HasComponentsOfTuplesFamily, IsTuplesFamily );


#############################################################################
##
#V  TUPLES_FAMILIES . . . . . . . . . . . . . . . list of all tuples families
##

EmptyTuplesFamily := NewFamily( "TuplesFamily([])", IsTuple , IsTuple, 
                             IsTuplesFamily);

SetComponentsOfTuplesFamily(EmptyTuplesFamily, []);

TUPLES_FAMILIES := [ [ EmptyTuplesFamily ] ];


#############################################################################
##
#M  TuplesFamily ( <famlist> ) . . . . . . . . . family of tuples of elements
##
##

InstallMethod( TuplesFamily, 
        fam -> fam = CollectionsFamily(FamilyOfFamilies), 
        [ IsCollection ], 0,
        function( famlist )
    local n, tuplespos, tuplesfam;
    n := Length(famlist);
    if not IsBound(TUPLES_FAMILIES[n+1]) then
        TUPLES_FAMILIES[n+1] := [];
        tuplespos := fail;
    else
        tuplespos := PositionProperty(TUPLES_FAMILIES[n+1], 
                           fam -> ComponentsOfTuplesFamily(fam) = famlist);
    fi;
    if tuplespos = fail then
        Info(InfoTuples, 1, "Created new tuples family, length ",n);
        tuplesfam := NewFamily("TuplesFamily( <<famlist>> )", 
                              IsTuple , IsTuple, IsTuplesFamily);
        SetComponentsOfTuplesFamily( tuplesfam, Immutable(famlist));
        Add(TUPLES_FAMILIES[n+1], tuplesfam);
    else
        Info(InfoTuples, 2, "Reused tuples family, length ",n);
        tuplesfam := TUPLES_FAMILIES[n+1][tuplespos];
    fi;
    return tuplesfam;
end);
                         
#############################################################################
##
#M  TuplesFamily ( [] ) . . .  . . . . . . . . . . . . .family of empty tuple
##

InstallMethod( TuplesFamily, 
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

InstallMethod( Tuple, true, [ IsList ], 0,
        function( objlist )
    local fam;
    fam := TuplesFamily( List(objlist, FamilyObj) );
    return TupleNC ( fam, objlist );
end);

#############################################################################
##
#M  Tuple ( <tuplesfam>, <objlist> ) . . . . . . . . . . . . . . make a tuple
##

InstallOtherMethod( Tuple, true, [ IsTuplesFamily, IsList ], 0,
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

InstallMethod( PrintObj, true, [IsTuple], 0,
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

InstallMethod( \<, IsIdentical, [IsTuple, IsTuple], 0,
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

InstallMethod( \=, IsIdentical, [IsTuple, IsTuple], 0,
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

IsDefaultTupleRep := NewRepresentation( "IsDefaultTupleRep", 
                             IsComponentObjectRep and IsTuple, [] );


#############################################################################
##
#M  TupleNC ( <tuplesfam>, <objlist> ) . . . . . . . . . . . . . make a tuple
##
##  Note that we really have to copy the list passed, even if it is Immutable
##  as we are going to Objectify it.
##

InstallMethod( TupleNC, true, [ IsTuplesFamily, IsList ], 0,
        function( fam, objlist )
    local t;
    Assert(2, ComponentsOfTuplesFamily = List(objlist, FamilyObj));
    t := Objectify( NewKind(fam,  IsDefaultTupleRep ), 
         List(objlist, Immutable) );
    Info(InfoTuples,3,"Created a new Tuple ",t);
    return t;
end);


##############################################################################
##
#M  <tuple> [ <index> ] .. . . . . . . . . . . . . . . . . . .component access
##
##

InstallMethod( \[\], true, [IsDefaultTupleRep, IsInt and IsPosRat], 0,
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

InstallMethod( Length, true, [IsDefaultTupleRep], 0,
        function (tuple) 
    return Length(ComponentsOfTuplesFamily( FamilyObj (tuple)));
end);








