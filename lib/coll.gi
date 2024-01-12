#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert, Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for collections in general.
##


#############################################################################
##
#M  CollectionsFamily(<F>)  . . . . . . . . . . . . . . . . .  generic method
##
InstallMethod( CollectionsFamily,
    "for a family",
    [ IsFamily ], 90,
    function ( F )
    local   colls, coll_req, coll_imp, elms_flags, tmp;
    coll_req := IsCollection;
    coll_imp := IsObject;
    elms_flags := F!.IMP_FLAGS;
    atomic readonly CATEGORIES_COLLECTIONS do
        for tmp  in CATEGORIES_COLLECTIONS  do
            if IS_SUBSET_FLAGS( elms_flags, FLAGS_FILTER( tmp[1] ) )  then
                coll_imp := coll_imp and tmp[2];
            fi;
        od;
    od;

    if    ( not HasElementsFamily( F ) )
       or not IsOddAdditiveNestingDepthFamily( F ) then
      colls := NewFamily( "CollectionsFamily(...)", coll_req,
                          coll_imp and IsOddAdditiveNestingDepthObject );
      SetFilterObj( colls, IsOddAdditiveNestingDepthFamily );
    else
      colls := NewFamily( "CollectionsFamily(...)", coll_req, coll_imp );
    fi;

    SetElementsFamily( colls, F );

    return colls;
end );

#
# Rather nasty cludge follows. We need StringFamily before we read
# this file, so we created it earlier and "force" it to be the CollectionsFamily of
# CharsFamily here.
#

SetElementsFamily( StringFamily, CharsFamily);
SetCollectionsFamily( CharsFamily, StringFamily);


#############################################################################
##
##  Iterators
##

#############################################################################
##
#V  IteratorsFamily
##
BIND_GLOBAL( "IteratorsFamily", NewFamily( "IteratorsFamily", IsIterator ) );


#############################################################################
##
#M  PrintObj( <iter> )  . . . . . . . . . . . . . . . . . . print an iterator
##
##  This method is also the default for `ViewObj'.
##
InstallMethod( PrintObj,
    "for an iterator",
    [ IsIterator ],
    function( iter )
    local msg;
    msg := "<iterator";
    if not IsMutable( iter ) then
      Append(msg, " (immutable)");
    fi;
    Append(msg,">");
    Print(msg);
    end );


#############################################################################
##
#M  IsEmpty(<C>)  . . . . . . . . . . . . . . . test if a collection is empty
##
InstallImmediateMethod( IsEmpty,
    IsCollection and HasSize, 0,
    C -> Size( C ) = 0 );

InstallMethod( IsEmpty,
    "for a collection",
    [ IsCollection ],
    C -> Size( C ) = 0 );

InstallMethod( IsEmpty,
    "for a list",
    [ IsList ],
    list -> Length( list ) = 0 );


#############################################################################
##
#M  IsTrivial(<C>)  . . . . . . . . . . . . . test if a collection is trivial
##
InstallImmediateMethod( IsTrivial,
    IsCollection and HasSize, 0,
    C -> Size( C ) = 1 );

InstallMethod( IsTrivial,
    "for a collection",
    [ IsCollection ],
    C -> Size( C ) = 1 );

InstallMethod( IsTrivial,
    [IsCollection and HasIsNonTrivial], 0,
    C -> not IsNonTrivial( C ) );


#############################################################################
##
#M  IsNonTrivial( <C> ) . . . . . . . . .  test if a collection is nontrivial
##
InstallMethod( IsNonTrivial,
    [IsCollection and HasIsTrivial], 0,
    C -> not IsTrivial( C ) );

InstallMethod( IsNonTrivial,
    "for a collection",
    [ IsCollection ],
    C -> Size( C ) <> 1 );


#############################################################################
##
#M  IsFinite(<C>) . . . . . . . . . . . . . .  test if a collection is finite
##
InstallImmediateMethod( IsFinite,
    IsCollection and HasSize, 0,
    C -> not IsIdenticalObj( Size( C ), infinity ) );

InstallMethod( IsFinite,
    "for a collection",
    [ IsCollection ],
    C -> Size( C ) < infinity );


#############################################################################
##
#M  IsWholeFamily( <C> )  . .  test if a collection contains the whole family
##
InstallMethod( IsWholeFamily,
    "default for a collection, print an error message",
    [ IsCollection ],
    function ( C )
    Error( "cannot test whether <C> contains the family of its elements" );
    end );


#############################################################################
##
#M  Size( <C> ) . . . . . . . . . . . . . . . . . . . .  size of a collection
##
#  This used to be an immediate method. It was replaced by an ordinary
#  method, as the immediate method would get called for every group that
#  knows it is finite but does not know its size -- e.g.  permutation, pc.
#  The benefit of this is minimal beyond showing off a feature.
InstallMethod( Size,true, [IsCollection and HasIsFinite],
  100, # rank above object-specific methods
    function ( C )
    if IsFinite( C ) then
        TryNextMethod();
    fi;
    return infinity;
    end );

InstallImmediateMethod( Size,
    IsCollection and HasAsList and IsAttributeStoringRep, 0,
    C -> Length( AsList( C ) ) );

InstallMethod( Size,
    "for a collection",
    [ IsCollection ],
    C -> Length( Enumerator( C ) ) );


#############################################################################
##
#M  Representative( <C> ) . . . . . . . . . . for a collection that is a list
##
InstallMethod( Representative,
    "for a collection that is a list",
    [ IsCollection and IsList ],
    function ( C )
    if IsEmpty( C ) then
      Error( "<C> must be nonempty to have a representative" );
    else
      return C[1];
    fi;
    end );

InstallImmediateMethod( RepresentativeSmallest,
    IsCollection and HasEnumeratorSorted and IsAttributeStoringRep, 1000,
    function( C )
    C:= EnumeratorSorted( C );
    if IsEmpty( C ) then
      TryNextMethod();
    else
      return C[1];
    fi;
    end );

InstallImmediateMethod( RepresentativeSmallest,
    IsCollection and HasAsSSortedList and IsAttributeStoringRep, 1000,
    function( C )
    C:= AsSSortedList( C );
    if IsEmpty( C ) then
      TryNextMethod();
    else
      return C[1];
    fi;
    end );

InstallMethod( RepresentativeSmallest,
    "for a collection",
    [ IsCollection ],
    function ( C )
    local   elm;
    for elm in EnumeratorSorted( C ) do
        return elm;
    od;
    Error( "<C> must be nonempty to have a representative" );
    end );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . . . . . . . . . . . . . .  for a list
#M  Random( <C> ) . . . . . . . . . . . . . . . . . . . . .  for a collection
##
##  The default function for random selection in a finite collection computes
##  an enumerator of <C> and selects a random element of this list using the
##  function `RandomList', which uses a pseudo random number generator.
##

# RandomList is not an operation to avoid the (often expensive) cost of
# dispatch for lists
InstallGlobalFunction( RandomList, function(args...)
  local len, source, list;
  len := Length(args);
  if len = 1 then
    source := GlobalMersenneTwister;
    list := args[1];
  elif len = 2 then
    source := args[1];
    list := args[2];
  else
    Error( "usage: RandomList( [<rs>], <list> ) for a dense list <list>" );
  fi;

  return list[Random(source, 1, Length(list))];
end );


RedispatchOnCondition(Random,true,[IsCollection],[IsFinite],0);
RedispatchOnCondition(Random,true,[IsRandomSource,IsCollection],[,IsFinite],0);

#############################################################################
##
#M  PseudoRandom( <list> )  . . . . . . . . . . . . . .  for an internal list
##
InstallMethod( PseudoRandom,
    "for an internal list",
    [ IsList and IsInternalRep ], 100,
    RandomList );


#############################################################################
##
#M  PseudoRandom( <C> ) . . . . . . . . . . . . . .  for a list or collection
##
InstallMethod( PseudoRandom,
    "for a list or collection (delegate to `Random')",
    [ IsListOrCollection ], Random );

#############################################################################
##
#M  AsList( <coll> )
##
InstallMethod( AsList,
    "for a collection",
    [ IsCollection ],
    coll -> ConstantTimeAccessList( Enumerator( coll ) ) );

InstallMethod( AsList,
    "for collections that are constant time access lists",
    [ IsCollection and IsConstantTimeAccessList ],
    Immutable );


#############################################################################
##
#M  AsSSortedList( <coll> )
##
InstallMethod( AsSSortedList,
    "for a collection",
    [ IsCollection ],
    coll -> ConstantTimeAccessList( EnumeratorSorted( coll ) ) );

InstallOtherMethod( AsSSortedList,
    "for a collection that is a constant time access list",
    [ IsCollection and IsConstantTimeAccessList ],
    l->AsSSortedListList(AsPlist(l)) );

#############################################################################
##
#M  AsSSortedListNonstored( <C> )
##
InstallMethod(AsSSortedListNonstored,"if `AsSSortedList' is known",
  [IsListOrCollection and HasAsSSortedList],
  # besser geht nicht
  SUM_FLAGS,
  AsSSortedList);

InstallMethod(AsSSortedListNonstored,"if `AsList' is known:sort",
  [IsListOrCollection and HasAsList],
  # unless the construction constructs the elements already sorted, this
  # method is as good as it gets
  QuoInt(SUM_FLAGS,4),
function(l)
local a;
  a:=ShallowCopy(AsList(l));
  Sort(a);
  return a;
end);


#############################################################################
##
#M  Enumerator( <C> )
##
InstallImmediateMethod( Enumerator,
    IsCollection and HasAsList and IsAttributeStoringRep, 0,
    AsList );

InstallMethod( Enumerator,
    "for a collection with known `AsList' value",
    [ IsCollection and HasAsList ],
    SUM_FLAGS, # we don't want to compute anything anew -- this is already a
               # known result as good as any.
    AsList );

InstallMethod( Enumerator,
    "for a collection with known `AsSSortedList' value",
    [ IsCollection and HasAsSSortedList ],
    SUM_FLAGS, # we don't want to compute anything anew -- this is already a
               # known result as good as any.
    AsSSortedList );

InstallMethod( Enumerator,
    "for a collection that is a list",
    [ IsCollection and IsList ],
    Immutable );


#############################################################################
##
#M  EnumeratorSorted( <C> )
##
##  If a collection known already its `AsSSortedList' value then
##  `EnumeratorSorted' may fetch this value.
##
InstallImmediateMethod( EnumeratorSorted,
    IsCollection and HasAsSSortedList and IsAttributeStoringRep, 0,
    AsSSortedList );

InstallMethod( EnumeratorSorted,
    "for a collection with known `AsSSortedList' value",
    [ IsCollection and HasAsSSortedList ],
    SUM_FLAGS, # we don't want to compute anything anew -- this is already a
               # known result as good as any.
    AsSSortedList );


#############################################################################
##
#M  PrintObj( <enum> )  . . . . . . . . . . . . . . . . . print an enumerator
##
##  This is also the default method for `ViewObj'.
##
InstallMethod( PrintObj,
    "for an enumerator",
    [ IsList and IsAttributeStoringRep ],
    function( enum )
    Print( "<enumerator>" );
    end );


#############################################################################
##
#F  EnumeratorByFunctions( <D>, <record> )
#F  EnumeratorByFunctions( <Fam>, <record> )
##
DeclareRepresentation( "IsEnumeratorByFunctionsRep", IsComponentObjectRep );

DeclareSynonym( "IsEnumeratorByFunctions",
    IsEnumeratorByFunctionsRep and IsDenseList and IsDuplicateFreeList );

InstallGlobalFunction( EnumeratorByFunctions, function( D, record )
    local filter, Fam, enum;

    if not ( IsRecord( record ) and IsBound( record.ElementNumber )
                                and IsBound( record.NumberElement ) ) then
      Error( "<record> must be a record with components `ElementNumber'\n",
             "and `NumberElement'" );
    fi;
    filter:= IsEnumeratorByFunctions and IsAttributeStoringRep;
    if IsDomain( D ) then
      Fam:= FamilyObj( D );
    elif IsFamily( D ) then
      if not IsBound( record.Length ) then
        Error( "<record> must have the component `Length'" );
      fi;
      Fam:= D;
    else
      Error( "<D> must be a record or a family" );
    fi;

    enum:= Objectify( NewType( Fam, filter ), record );

    if IsDomain( D ) then
      SetUnderlyingCollection( enum, D );
      if HasIsFinite( D ) then
        SetIsFinite( enum, IsFinite( D ) );
      fi;
    fi;

    return enum;
    end );


InstallOtherMethod( \[\],
    "for enumerator by functions",
    [ IsEnumeratorByFunctions, IsPosInt ],
    function( enum, nr )
    return enum!.ElementNumber( enum, nr );
    end );

InstallOtherMethod( Position,
    "for enumerator by functions",
    [ IsEnumeratorByFunctions, IsObject, IsZeroCyc ],
    RankFilter( IsSmallList ), # override the generic method for those lists
    function( enum, elm, zero )
    return enum!.NumberElement( enum, elm );
    end );

InstallOtherMethod( PositionCanonical,
    "for enumerator by functions",
    [ IsEnumeratorByFunctions, IsObject ],
    function( enum, elm )
    if IsBound( enum!.PositionCanonical ) then
      return enum!.PositionCanonical( enum, elm );
    else
      return enum!.NumberElement( enum, elm );
    fi;
    end );
# (was defined for EnumeratorByBasis, IsExternalOrbitByStabilizerEnumerator,
# IsRationalClassGroupEnumerator!)
# I am still convinced that `PositionCanonical' is not a well-defined concept!

InstallMethod( Length,
    "for an enumerator that perhaps has its own `Length' function",
    [ IsEnumeratorByFunctions ],
    function( enum )
    if IsBound( enum!.Length ) then
      return enum!.Length( enum );
    elif HasUnderlyingCollection( enum ) then
      return Size( UnderlyingCollection( enum ) );
    else
      Error( "neither `Length' function nor `UnderlyingCollection' found ",
             "in <enum>" );
    fi;
    end );

InstallMethod( IsBound\[\],
    "for an enumerator that perhaps has its own `IsBound' function",
    [ IsEnumeratorByFunctions, IsPosInt ],
    function( enum, n )
    if IsBound( enum!.IsBound\[\] ) then
      return enum!.IsBound\[\]( enum, n );
    else
      return n <= Length( enum );
    fi;
    end );

InstallOtherMethod( \in,
    "for an enumerator that perhaps has its own membership test function",
    [ IsObject, IsEnumeratorByFunctions ],
    function( elm, enum )
    if IsBound( enum!.Membership ) then
      return enum!.Membership( elm, enum );
    else
      return enum!.NumberElement( enum, elm ) <> fail;
    fi;
    end );

InstallMethod( AsList,
    "for an enumerator that perhaps has its own `AsList' function",
    [ IsEnumeratorByFunctions ],
    function( enum )
    if IsBound( enum!.AsList ) then
      return enum!.AsList( enum );
    else
      return ConstantTimeAccessList( enum );
    fi;
    end );

InstallMethod( ViewObj,
    "for an enumerator that perhaps has its own `ViewObj' function",
    [ IsEnumeratorByFunctions ], SUM_FLAGS,
    # override, e.g., the method for finite lists
    # in the case of an enumerator of GF(q)^n
    function( enum )
    if   IsBound( enum!.ViewObj ) then
      enum!.ViewObj( enum );
    elif IsBound( enum!.PrintObj ) then
      enum!.PrintObj( enum );
    elif HasUnderlyingCollection( enum ) then
      Print( "<enumerator of " );
      View( UnderlyingCollection( enum ) );
      Print( ">" );
    else
      Print( "<enumerator>" );
    fi;
    end );

InstallMethod( PrintObj,
    "for an enumerator that perhaps has its own `PrintObj' function",
    [ IsEnumeratorByFunctions ],
    function( enum )
    if IsBound( enum!.PrintObj ) then
      enum!.PrintObj( enum );
    elif HasUnderlyingCollection( enum ) then
      Print( "<enumerator of ", UnderlyingCollection( enum ), ">" );
    else
      Print( "<enumerator>" );
    fi;
    end );


#############################################################################
##
#F  EnumeratorOfSubset( <list>, <blist>[, <ishomog>] )
##
BIND_GLOBAL( "ElementNumber_Subset", function( senum, num )
    local pos;

    pos:= PositionNthTrueBlist( senum!.blist, num );
    if pos = fail then
      Error( "List Element: <list>[", num, "] must have an assigned value" );
    else
      return senum!.list[ pos ];
    fi;
    end );

BIND_GLOBAL( "NumberElement_Subset", function( senum, elm )
    local pos;

    pos:= Position( senum!.list, elm );
    if pos = fail or not senum!.blist[ pos ] then
      return fail;
    else
      return SIZE_BLIST( senum!.blist{ [ 1 .. pos ] } );
    fi;
    end );

BIND_GLOBAL( "PositionCanonical_Subset", function( senum, elm )
    local pos;

    pos:= PositionCanonical( senum!.list, elm );
    if pos = fail or not senum!.blist[ pos ] then
      return fail;
    else
      return SIZE_BLIST( senum!.blist{ [ 1 .. pos ] } );
    fi;
    end );

BIND_GLOBAL( "Length_Subset", senum -> SIZE_BLIST( senum!.blist ) );

BIND_GLOBAL( "AsList_Subset",
    senum -> senum!.list{ LIST_BLIST( [ 1 .. Length( senum!.list ) ],
                          senum!.blist ) } );

InstallGlobalFunction( EnumeratorOfSubset,
    function( arg )
    local list, blist, Fam;

    # Get and check the arguments.
    if Length( arg ) < 2 or 3 < Length( arg ) then
      Error( "usage: EnumeratorOfSubset( <list>, <blist>[, <ishomog>] )" );
    fi;
    list:= arg[1];
    blist:= arg[2];

    # Determine the family of the result.
    if IsHomogeneousList( list ) then
      Fam:= FamilyObj( list );
    elif Length( arg ) = 2 then
      Error( "missing third argument <ishomog> for inhomog. <list>" );
    elif arg[3] = true then
      Fam:= FamilyObj( list );
    else
      Fam:= ListsFamily;
    fi;

    # Construct the enumerator.
    return EnumeratorByFunctions( Fam, rec(
               ElementNumber     := ElementNumber_Subset,
               NumberElement     := NumberElement_Subset,
               PositionCanonical := PositionCanonical_Subset,
               Length            := Length_Subset,
               AsList            := AsList_Subset,

               list              := list,
               blist             := blist ) );
    end );


#############################################################################
##
#F  List( <coll> )
#F  List( <coll>, <func> )
##
InstallGlobalFunction( List,
    function( arg )
    local tnum, C, func, res, i, l;
    l := Length(arg);
    if l = 0 or l > 2 then
      ErrorNoReturn( "usage: List( <C>[, <func>] )" );
    fi;
    tnum:= TNUM_OBJ( arg[1] );
    # handle built-in lists directly, to avoid method dispatch overhead
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        return ShallowCopy( C );
      else
        func:= arg[2];
        res := EmptyPlist(Length(C));
        # hack to save type adjustments and conversions (e.g. to blist)
        if Length(C) > 0 then res[Length(C)] := 1; fi;
        if IsDenseList(C) then
          # save the IsBound tests from general case
          for i in [1..Length(C)] do
            res[i] := func( C[i] );
          od;
        else
          for i in [1..Length(C)] do
            if IsBound(C[i]) then
              res[i] := func( C[i] );
            fi;
          od;
        fi;
        return res;
      fi;
    else
      return CallFuncList( ListOp, arg );
    fi;
end );


#############################################################################
##
#M  ListOp( <coll> )
##
InstallMethod( ListOp,
    "for a collection",
    [ IsCollection ],
    C -> ShallowCopy( Enumerator( C ) ) );

InstallMethod( ListOp,
    "for a collection that is a list",
    [ IsCollection and IsList ],
    ShallowCopy );

InstallMethod( ListOp,
    "for a list",
    [ IsList ],
    ShallowCopy );


#############################################################################
##
#M  ListOp( <coll>, <func> )
##
InstallMethod( ListOp,
    "for a list/collection, and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local   res, i, elm;
    res := [];
    i   := 0;
    for elm in C do
      i:= i+1;
      res[i]:= func( elm );
    od;
    return res;
    end );

InstallMethod( ListOp,
    "for a list, and a function",
    [ IsList, IsFunction ],
    function ( C, func )
    local   res, i, elm;
    res := [];
    i   := 0;
    for elm in [1..Length(C)] do
      if IsBound(C[elm]) then
          i:= i+1;
          res[i]:= func( C[elm] );
      fi;
    od;
    return res;
    end );

InstallMethod( ListOp,
    "for a dense list, and a function",
    [ IsDenseList, IsFunction ],
    function ( C, func )
    local   res, elm;
    res := EmptyPlist(Length(C));
    for elm in [1..Length(C)] do
      res[elm]:= func( C[elm] );
    od;
    return res;
    end );

#############################################################################
##
#M  SortedList( <C> )
##
InstallMethod( SortedList, "for a list or collection",
    true, [ IsListOrCollection ], 0,
function(C)
local l;
  if IsList(C) then
    l := Compacted(C);
  else
    l := List(C);
  fi;
  Sort(l);
  return l;
end);

InstallMethod(SortedList, "for a list or collection and a function",
[ IsListOrCollection, IsFunction ],
function(C, func)
local l;
  if IsList(C) then
    l := Compacted(C);
  else
    l := List(C);
  fi;
  Sort(l, func);
  return l;
end);

InstallMethod( AsSortedList, "for a list or collection",
        true, [ IsListOrCollection ], 0,
        function(l)
    local s;
    s := SortedList(l);
    MakeImmutable(s);
    return s;
end);

#############################################################################
##
#M  SSortedList( <C> )
##
InstallMethod( SSortedList,
    "for a collection",
    true, [ IsCollection ], 0,
    C -> ShallowCopy( EnumeratorSorted( C ) ) );

InstallMethod( SSortedList,
    "for a collection that is a small list",
    true, [ IsCollection and IsList and IsSmallList ], 0,
    SSortedListList );

InstallMethod( SSortedList,
        "for a collection that is a list",
        true, [ IsCollection and IsList ], 0,
        function(list)
    if IsSmallList(list) then
       return SSortedListList(list);
    else
        Error("Sort for large lists not yet implemented");
    fi;
    end
        );


#############################################################################
##
#M  SSortedList( <C>, <func> )
##
InstallOtherMethod( SSortedList,
    "for a collection, and a function",
    true, [ IsCollection, IsFunction ], 0,
    function ( C, func )
    return SSortedListList( List( C, func ) );
    end );


#############################################################################
##
#M  Iterator(<C>)
##
InstallMethod( Iterator,
    "for a collection",
    [ IsCollection ],
    C -> IteratorList( Enumerator( C ) ) );

InstallMethod( Iterator,
    "for a collection that is a list",
    [ IsCollection and IsList ],
    C -> IteratorList( C ) );

InstallOtherMethod( Iterator,
    "for a mutable iterator",
    [ IsIterator and IsMutable ],
    IdFunc );
#T or change the for-loop to accept iterators?

#############################################################################
##
#M  List( <iter> ) . . . . . . return list of remaining objects in an iterator
##
##  Does not change the iterator.
##
InstallOtherMethod( ListOp,
    "for an iterator",
    [ IsIterator ],
    function ( iter )
    local   res, elm;
    res := [];
    iter := ShallowCopy( iter );
    for elm in iter do
      Add( res, elm );
    od;
    return res;
    end );

InstallOtherMethod( ListOp,
    "for an iterator, and a function",
    [ IsIterator, IsFunction ],
    function ( iter, func )
    local   res, elm;
    res := [];
    iter := ShallowCopy( iter );
    for elm in iter do
      Add( res, func( elm ) );
    od;
    return res;
    end );


#############################################################################
##
#M  IteratorSorted(<C>)
##
InstallMethod( IteratorSorted,
    "for a collection",
    [ IsCollection ],
    C -> IteratorList( EnumeratorSorted( C ) ) );

InstallMethod( IteratorSorted,
    "for a collection that is a list",
    [ IsCollection and IsList ],
    C -> IteratorList( SSortedListList( C ) ) );


#############################################################################
##
#M  NextIterator( <iter> ) . . . . . . for immutable iterator (error message)
##
InstallOtherMethod( NextIterator,
    "for an immutable iterator (print a reasonable error message)",
    [ IsIterator ],
    function( iter )
    if IsMutable( iter ) then
      TryNextMethod();
    fi;
    Error( "no `NextIterator' method for immutable iterator <iter>" );
    end );


#############################################################################
##
#F  IteratorByFunctions( <record> )
##
if IsHPCGAP then
DeclareRepresentation( "IsIteratorByFunctionsRep", IsNonAtomicComponentObjectRep );
else
DeclareRepresentation( "IsIteratorByFunctionsRep", IsComponentObjectRep );
fi;

DeclareSynonym( "IsIteratorByFunctions",
    IsIteratorByFunctionsRep and IsIterator );

InstallGlobalFunction( IteratorByFunctions, function( record )
    local filter;

    if not ( IsRecord( record ) and IsBound( record.NextIterator )
                                and IsBound( record.IsDoneIterator )
                                and IsBound( record.ShallowCopy ) ) then
      Error( "<record> must be a record with components `NextIterator',\n",
             "`IsDoneIterator', and `ShallowCopy'" );
    fi;
    filter:= IsIteratorByFunctions and IsStandardIterator and IsMutable;

    return Objectify( NewType( IteratorsFamily, filter ), record );
end );

InstallMethod( IsDoneIterator,
    "for `IsIteratorByFunctions'",
    [ IsIteratorByFunctions ],
    iter -> iter!.IsDoneIterator( iter ) );

InstallMethod( NextIterator,
    "for `IsIteratorByFunctions'",
    [ IsIteratorByFunctions and IsMutable ],
    iter -> iter!.NextIterator( iter ) );

InstallMethod( ShallowCopy,
    "for `IsIteratorByFunctions'",
    [ IsIteratorByFunctions ],
    function( iter )
    local new;
    new:= iter!.ShallowCopy( iter );
    new.NextIterator   := iter!.NextIterator;
    new.IsDoneIterator := iter!.IsDoneIterator;
    new.ShallowCopy    := iter!.ShallowCopy;
    if IsBound(iter!.ViewObj) then
        new.ViewObj    := iter!.ViewObj;
    fi;
    if IsBound(iter!.PrintObj) then
        new.PrintObj   := iter!.PrintObj;
    fi;
    return IteratorByFunctions( new );
    end );

InstallMethod( ViewObj,
    "for an iterator that perhaps has its own `ViewObj' function",
    [ IsIteratorByFunctions ], 20,
function( iter )
    if IsBound( iter!.ViewObj ) then
        iter!.ViewObj( iter );
    elif IsBound( iter!.PrintObj ) then
        iter!.PrintObj( iter );
    elif HasUnderlyingCollection( iter ) then
        Print( "<iterator of " );
        View( UnderlyingCollection( iter ) );
        Print( ">" );
    else
        Print( "<iterator>" );
    fi;
end );

InstallMethod( PrintObj,
    "for an iterator that perhaps has its own `PrintObj' function",
    [ IsIteratorByFunctions ],
function( iter )
    if IsBound( iter!.PrintObj ) then
       iter!.PrintObj( iter );
    elif HasUnderlyingCollection( iter ) then
       Print( "<iterator of ", UnderlyingCollection( iter ), ">" );
    else
       Print( "<iterator>" );
    fi;
end );

#############################################################################
##
#F  ConcatenationIterators( <iters> ) . . . . . . . combine list of iterators
##  to one iterator
##
BIND_GLOBAL("NextIterator_Concatenation", function(it)
  local i, it1, res;
  i := it!.i;
  it1 := it!.iters[i];
  res := NextIterator(it1);
  while i <= Length(it!.iters) and IsDoneIterator(it!.iters[i]) do
    i := i+1;
  od;
  it!.i := i;
  return res;
end);
BIND_GLOBAL("IsDoneIterator_Concatenation", function(it)
  return it!.i > Length(it!.iters);
end);
BIND_GLOBAL("ShallowCopy_Concatenation", function(it)
  return rec(NextIterator := it!.NextIterator,
    IsDoneIterator := it!.IsDoneIterator,
    ShallowCopy := it!.ShallowCopy,
    i := it!.i,
    iters := List(it!.iters, ShallowCopy)
    );
end);
BIND_GLOBAL("ConcatenationIterators", function(iters)
  local i;
  i := 1;
  while i <= Length(iters) and IsDoneIterator(iters[i]) do
    i := i+1;
  od;
  return IteratorByFunctions(rec(
    NextIterator := NextIterator_Concatenation,
    IsDoneIterator := IsDoneIterator_Concatenation,
    ShallowCopy := ShallowCopy_Concatenation,
    i := i,
    iters := iters,
            ));
end);

#############################################################################
##
#F  TrivialIterator( <elm> )
##
BIND_GLOBAL( "IsDoneIterator_Trivial", iter -> iter!.isDone );

BIND_GLOBAL( "NextIterator_Trivial", function( iter )
    iter!.isDone:= true;
    return iter!.element;
    end );

BIND_GLOBAL( "ShallowCopy_Trivial",
    iter -> rec( element:= iter!.element, isDone:= iter!.isDone ) );

InstallGlobalFunction( TrivialIterator, function( elm )
    return IteratorByFunctions( rec(
               IsDoneIterator := IsDoneIterator_Trivial,
               NextIterator   := NextIterator_Trivial,
               ShallowCopy    := ShallowCopy_Trivial,

               element := elm,
               isDone  := false ) );
end );

InstallMethod( Iterator,
    "for a trivial collection",
    [ IsCollection and IsTrivial ], SUM_FLAGS,
    D -> TrivialIterator( Enumerator( D )[1] ) );


#############################################################################
##
#F  Sum( <coll> )
#F  Sum( <coll>, <func> )
#F  Sum( <coll>, <init> )
#F  Sum( <coll>, <func>, <init> )
##
InstallGlobalFunction( Sum,
    function( arg )
    local tnum, C, func, sum, i, l;
    l := Length( arg );
    if l = 0 then
      Error( "usage: Sum( <C>[, <func>][, <init>] )" );
    fi;
    tnum:= TNUM_OBJ( arg[1] );
    # handle built-in lists directly, to avoid method dispatch overhead
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        if IsEmpty( C ) then
          sum:= 0;
        else
          sum:= C[1];
          for i in [ 2 .. Length( C ) ] do
            sum:= sum + C[i];
          od;
        fi;
      elif l = 2 and IsFunction( arg[2] ) then
        func:= arg[2];
        if IsEmpty( C ) then
          sum:= 0;
        else
          sum:= func( C[1] );
          for i in [ 2 .. Length( C ) ] do
            sum:= sum + func( C[i] );
          od;
        fi;
      elif l = 2 then
        sum:= arg[2];
        for i in C do
          sum:= sum + i;
        od;
      elif l = 3 and IsFunction( arg[2] ) then
        func:= arg[2];
        sum:= arg[3];
        for i in C do
          sum:= sum + func( i );
        od;
      else
        Error( "usage: Sum( <C>[, <func>][, <init>] )" );
      fi;
      return sum;
    else
      return CallFuncList( SumOp, arg );
    fi;
end );


#############################################################################
##
#M  SumOp( <C> )  . . . . . . . . . . . . . . . . . . . for a list/collection
##
InstallMethod( SumOp,
    "for a list/collection",
    [ IsListOrCollection ],
    function ( C )
    local   sum;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        sum := NextIterator( C );
        while not IsDoneIterator( C ) do
            sum := sum + NextIterator( C );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );


#############################################################################
##
#M  SumOp( <C>, <func> )  . . . . . . . for a list/collection, and a function
##
InstallOtherMethod( SumOp,
    "for a list/collection, and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local   sum;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        sum := func( NextIterator( C ) );
        while not IsDoneIterator( C ) do
            sum := sum + func( NextIterator( C ) );
        od;
    else
        sum := 0;
    fi;
    return sum;
    end );


#############################################################################
##
#M  SumOp( <C>, <init> )  . . . . . .  for a list/collection, and init. value
##
InstallOtherMethod( SumOp,
    "for a list/collection, and init. value",
    [ IsListOrCollection, IsAdditiveElement ],
    function ( C, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init + NextIterator( C );
    od;
    return init;
    end );


#############################################################################
##
#M  SumOp( <C>, <func>, <init> )  . for a list/coll., a func., and init. val.
##
InstallOtherMethod( SumOp,
    "for a list/collection, and a function, and an initial value",
    [ IsListOrCollection, IsFunction, IsAdditiveElement ],
    function ( C, func, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init + func( NextIterator( C ) );
    od;
    return init;
    end );


#############################################################################
##
#F  Product( <coll> )
#F  Product( <coll>, <func> )
#F  Product( <coll>, <init> )
#F  Product( <coll>, <func>, <init> )
##
InstallGlobalFunction( Product,
    function( arg )
    local tnum, C, func, product, l, i;
    l := Length(arg);
    if l = 0 then
      Error( "usage: Product( <C>[, <func>][, <init>] )" );
    fi;
    tnum:= TNUM_OBJ( arg[1] );
    # handle built-in lists directly, to avoid method dispatch overhead
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        if IsEmpty( C ) then
          product:= 1;
        else
          product:= C[1];
          for i in [ 2 .. Length( C ) ] do
            product:= product * C[i];
          od;
        fi;
      elif l = 2 and IsFunction( arg[2] ) then
        func:= arg[2];
        if IsEmpty( C ) then
          product:= 1;
        else
          product:= func( C[1] );
          for i in [ 2 .. Length( C ) ] do
            product:= product * func( C[i] );
          od;
        fi;
      elif l = 2 then
        product:= arg[2];
        for i in C do
          product:= product * i;
        od;
      elif l = 3 and IsFunction( arg[2] ) then
        func:= arg[2];
        product:= arg[3];
        for i in C do
          product:= product * func( i );
        od;
      else
        Error( "usage: Product( <C>[, <func>][, <init>] )" );
      fi;
      return product;
    else
      return CallFuncList( ProductOp, arg );
    fi;
end );


#############################################################################
##
#M  ProductOp( <C> )  . . . . . . . . . . . . . . . . . for a list/collection
##
InstallMethod( ProductOp,
    "for a list/collection",
    [ IsListOrCollection ],
    function ( C )
    local   prod;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        prod := NextIterator( C );
        while not IsDoneIterator( C ) do
            prod := prod * NextIterator( C );
        od;
    else
        prod := 1;
    fi;
    return prod;
    end );


#############################################################################
##
#M  ProductOp( <C>, <func> )  . . . . . for a list/collection, and a function
##
InstallOtherMethod( ProductOp,
    "for a list/collection, and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local   prod;
    C := Iterator( C );
    if not IsDoneIterator( C ) then
        prod := func( NextIterator( C ) );
        while not IsDoneIterator( C ) do
            prod := prod * func( NextIterator( C ) );
        od;
    else
        prod := 1;
    fi;
    return prod;
    end );


#############################################################################
##
#M  ProductOp( <C>, <init> )  . . . .  for a list/collection, and init. value
##
InstallOtherMethod( ProductOp,
    "for a list/collection, and initial value",
    [ IsListOrCollection, IsMultiplicativeElement ],
    function ( C, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init * NextIterator( C );
    od;
    return init;
    end );


#############################################################################
##
#M  ProductOp( <C>, <func>, <init> )  . . . for list/coll., func., init. val.
##
InstallOtherMethod( ProductOp,
    "for a list/collection, a function, and an initial value",
    [ IsListOrCollection, IsFunction, IsMultiplicativeElement ],
    function ( C, func, init )
    C := Iterator( C );
    while not IsDoneIterator( C ) do
      init := init * func( NextIterator( C ) );
    od;
    return init;
    end );


#############################################################################
##
#F  ProductMod(<l>,<m>) . . . . . . . . . . . . . . . . . .  Product(l) mod m
##
BIND_GLOBAL( "ProductMod", function(l,m)
local i,p;
  if l=[] then
    p:=1;
  else
    p:=l[1]^0;
  fi;
  for i in l do
    p:=p*i mod m;
  od;
  return p;
end );


#############################################################################
##
#F  Filtered( <coll>, <func> )
##
InstallGlobalFunction( Filtered,
    function( C, func )
    local tnum, res, i, elm;
    tnum:= TNUM_OBJ( C );
    # handle built-in lists directly, to avoid method dispatch overhead
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      # start with empty list of same representation
      res := C{[]};
      i   := 0;
      for elm in C do
        if func( elm ) then
          i:= i+1;
          res[i]:= elm;
        fi;
      od;
    else
      res:= FilteredOp( C, func );
    fi;

    if HasIsSSortedList( C ) and IsSSortedList( C ) then
      SetIsSSortedList( res, true );
    fi;

    return res;
end );


#############################################################################
##
#M  FilteredOp( <C>, <func> ) . . . . . extract elements that have a property
##
InstallMethod( FilteredOp,
    "for a list/collection, and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local res, elm;
    res := [];
    for elm in C do
        if func( elm ) then
            Add( res, elm );
        fi;
    od;
    return res;
    end );
InstallMethod( FilteredOp,
    "for a list, and a function",
    [ IsList, IsFunction ],
    function ( C, func )
    local res, elm, ob;
    res := [];
    for elm in [1..Length(C)] do
        if IsBound(C[elm]) then
            ob := C[elm];
            if func( ob ) then
                Add( res, ob );
            fi;
        fi;
    od;
    return res;
    end );
InstallMethod( FilteredOp,
    "for a dense list, and a function",
    [ IsDenseList, IsFunction ],
    function ( C, func )
    local res, elm, ob;
    res := [];
    for elm in [1..Length(C)] do
        ob := C[elm];
        if func( ob ) then
            Add( res, ob );
        fi;
    od;
    return res;
    end );


#############################################################################
##
#F  Number( <coll> )
#F  Number( <coll>, <func> )
##
InstallGlobalFunction( Number,
    function( arg )
    local tnum, C, func, nr, elm,l;
    l := Length( arg );
    if l = 0 then
      Error( "usage: Number( <C>[, <func>] )" );
    fi;
    tnum:= TNUM_OBJ( arg[1] );
    # handle built-in lists directly, to avoid method dispatch overhead
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      C:= arg[1];
      if l = 1 then
        nr := 0;
        for elm in C do
            nr := nr + 1;
        od;
        return nr;
      else
        func:= arg[2];
        nr := 0;
        for elm in C do
            if func( elm ) then
                nr:= nr + 1;
            fi;
        od;
        return nr;
      fi;
    else
      return CallFuncList( NumberOp, arg );
    fi;
end );


#############################################################################
##
#M  NumberOp( <C>, <func> ) . . . . . . . count elements that have a property
##
InstallMethod( NumberOp,
    "for a list/collection, and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local nr, elm;
    nr := 0;
    for elm in C do
        if func( elm ) then
            nr:= nr + 1;
        fi;
    od;
    return nr;
    end );
InstallMethod( NumberOp,
    "for a list, and a function",
    [ IsList, IsFunction ],
    function ( C, func )
    local nr, elm;
    nr := 0;
    for elm in [1..Length(C)] do
        if IsBound(C[elm]) then
            if func( C[elm] ) then
                nr:= nr + 1;
            fi;
        fi;
    od;
    return nr;
    end );
InstallMethod( NumberOp,
    "for a dense list, and a function",
    [ IsDenseList, IsFunction ],
    function ( C, func )
    local nr, elm;
    nr := 0;
    for elm in [1..Length(C)] do
        if func( C[elm] ) then
            nr:= nr + 1;
        fi;
    od;
    return nr;
    end );


#############################################################################
##
#M  NumberOp( <C> ) . . . . . . . . . . . count elements
##
InstallOtherMethod( NumberOp,
    "for a list/collection",
    [ IsListOrCollection ],
    function ( C )
    local nr, elm;
    nr := 0;
    for elm in C do
        nr := nr + 1;
    od;
    return nr;
    end );
InstallOtherMethod( NumberOp,
    "for a list",
    [ IsList ],
    function ( C )
    local nr, elm;
    nr := 0;
    for elm in [1..Length(C)] do
        if IsBound(C[elm]) then
            nr := nr + 1;
        fi;
    od;
    return nr;
    end );
InstallOtherMethod( NumberOp,
    "for a dense list",
    [ IsDenseList ], Length );


#############################################################################
##
#F  ForAll( <coll>, <func> )
##
InstallGlobalFunction( ForAll,
    function( C, func )
    local tnum, elm;
    tnum:= TNUM_OBJ( C );
    # handle built-in lists directly, to avoid method dispatch overhead
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      for elm in C do
          if not func( elm ) then
              return false;
          fi;
      od;
      return true;
    else
      return ForAllOp( C, func );
    fi;
end );


#############################################################################
##
#M  ForAllOp( <C>, <func> ) . . .  test a property for all elements of a list
##
InstallMethod( ForAllOp,
    "for a list/collection, and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local elm;
    for elm in C do
        if not func( elm ) then
            return false;
        fi;
    od;
    return true;
    end );
InstallMethod( ForAllOp,
    "for a list, and a function",
    [ IsList and IsFinite, IsFunction ],
    function ( C, func )
    local elm;
    for elm in [1..Length(C)] do
        if IsBound(C[elm]) then
            if not func( C[elm] ) then
                return false;
            fi;
        fi;
    od;
    return true;
    end );
InstallMethod( ForAllOp,
    "for a dense list, and a function",
    [ IsDenseList and IsFinite, IsFunction ],
    function ( C, func )
    local elm;
    for elm in [1..Length(C)] do
        if not func( C[elm] ) then
            return false;
        fi;
    od;
    return true;
    end );


#############################################################################
##
#F  ForAny( <coll>, <func> )
##
InstallGlobalFunction( ForAny,
    function( C, func )
    local tnum, elm;
    tnum:= TNUM_OBJ( C );
    # handle built-in lists directly, to avoid method dispatch overhead
    if FIRST_LIST_TNUM <= tnum and tnum <= LAST_LIST_TNUM then
      for elm in C do
          if func( elm ) then
              return true;
          fi;
      od;
      return false;
    else
      return ForAnyOp( C, func );
    fi;
end );


#############################################################################
##
#M  ForAnyOp( <C>, <func> ) . . . . test a property for any element of a list
##
InstallMethod( ForAnyOp,
    "for a list/collection, and a function",
    [ IsListOrCollection, IsFunction ],
    function ( C, func )
    local elm;
    for elm in C do
        if func( elm ) then
            return true;
        fi;
    od;
    return false;
end );

InstallMethod( ForAnyOp,
    "for a list, and a function",
    [ IsList and IsFinite, IsFunction ],
    function ( C, func )
    local elm;
    for elm in [1..Length(C)] do
        if IsBound(C[elm]) then
            if func( C[elm] ) then
                return true;
            fi;
        fi;
    od;
    return false;
    end );
InstallMethod( ForAnyOp,
    "for a dense list, and a function",
    [ IsDenseList and IsFinite, IsFunction ],
    function ( C, func )
    local elm;
    for elm in [1..Length(C)] do
        if func( C[elm] ) then
            return true;
        fi;
    od;
    return false;
    end );


#############################################################################
##
#M  ListX(<obj>,...)
##
DeclareGlobalName("ListXHelp");
BIND_GLOBAL( "ListXHelp", function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                ListXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, CallFuncList( gens[i+1], vals ) );
end );

BIND_GLOBAL( "ListXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                ListXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, gens[i+1]( val1, val2 ) );
end );

BIND_GLOBAL( "ListXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            for val2  in gen  do
                ListXHelp2( result, gens, i+1, val1, val2 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, gens[i+1]( val1 ) );
end );

BIND_GLOBAL( "ListXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            for val1  in gen  do
                ListXHelp1( result, gens, i+1, val1 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    Add( result, gens[i+1]() );
end );

InstallGlobalFunction( ListX, function ( arg )
    local   result;
    result := [];
    ListXHelp0( result, arg, 0 );
    return result;
end );


#############################################################################
##
#M  SetX(<obj>,...)
##
DeclareGlobalName("SetXHelp");
BIND_GLOBAL( "SetXHelp", function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                SetXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, CallFuncList( gens[i+1], vals ) );
end );

BIND_GLOBAL( "SetXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                SetXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, gens[i+1]( val1, val2 ) );
end );

BIND_GLOBAL( "SetXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            for val2  in gen  do
                SetXHelp2( result, gens, i+1, val1, val2 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, gens[i+1]( val1 ) );
end );

BIND_GLOBAL( "SetXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return;
        elif IsListOrCollection( gen )  then
            for val1  in gen  do
                SetXHelp1( result, gens, i+1, val1 );
            od;
            return;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    AddSet( result, gens[i+1]() );
end );

InstallGlobalFunction( SetX, function ( arg )
    local   result;
    result := [];
    SetXHelp0( result, arg, 0 );
    return result;
end );


#############################################################################
##
#M  SumX(<obj>,...)
##
DeclareGlobalName("SumXHelp");
BIND_GLOBAL( "SumXHelp", function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                result := SumXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := CallFuncList( gens[i+1], vals );
    else
        result := result + CallFuncList( gens[i+1], vals );
    fi;
    return result;
end );

BIND_GLOBAL( "SumXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                result := SumXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1, val2 );
    else
        result := result + gens[i+1]( val1, val2 );
    fi;
    return result;
end );

BIND_GLOBAL( "SumXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            for val2  in gen  do
                result := SumXHelp2( result, gens, i+1, val1, val2 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1 );
    else
        result := result + gens[i+1]( val1 );
    fi;
    return result;
end );

BIND_GLOBAL( "SumXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            for val1  in gen  do
                result := SumXHelp1( result, gens, i+1, val1 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]();
    else
        result := result + gens[i+1]();
    fi;
    return result;
end );

InstallGlobalFunction( SumX, function ( arg )
    local   result;
    result := fail;
    result := SumXHelp0( result, arg, 0 );
    return result;
end );


#############################################################################
##
#M  ProductX(<obj>,...)
##
DeclareGlobalName("ProductXHelp");
BIND_GLOBAL( "ProductXHelp", function ( result, gens, i, vals, l )
    local   gen, val;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := CallFuncList( gen, vals );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            for val  in gen  do
                vals[l+1] := val;
                result := ProductXHelp( result, gens, i+1, vals, l+1 );
            od;
            Unbind( vals[l+1] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := CallFuncList( gens[i+1], vals );
    else
        result := result * CallFuncList( gens[i+1], vals );
    fi;
    return result;
end );

BIND_GLOBAL( "ProductXHelp2", function ( result, gens, i, val1, val2 )
    local   gen, vals, val3;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1, val2 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            vals := [ val1, val2 ];
            for val3  in gen  do
                vals[3] := val3;
                result := ProductXHelp( result, gens, i+1, vals, 3 );
            od;
            Unbind( vals[3] );
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1, val2 );
    else
        result := result * gens[i+1]( val1, val2 );
    fi;
    return result;
end );

BIND_GLOBAL( "ProductXHelp1", function ( result, gens, i, val1 )
    local   gen, val2;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen( val1 );
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            for val2  in gen  do
                result := ProductXHelp2( result, gens, i+1, val1, val2 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]( val1 );
    else
        result := result * gens[i+1]( val1 );
    fi;
    return result;
end );

BIND_GLOBAL( "ProductXHelp0", function ( result, gens, i )
    local   gen, val1;
    while i+1 < Length(gens)  do
        gen := gens[i+1];
        if IsFunction( gen )  then
            gen := gen();
        fi;
        if gen = true  then
            i := i + 1;
        elif gen = false  then
            return result;
        elif IsListOrCollection( gen )  then
            for val1  in gen  do
                result := ProductXHelp1( result, gens, i+1, val1 );
            od;
            return result;
        else
            Error( "gens[",i+1,"] must be a collection, a list, a boolean, ",
                   "or a function" );
        fi;
    od;
    if result = fail then
        result := gens[i+1]();
    else
        result := result * gens[i+1]();
    fi;
    return result;
end );

InstallGlobalFunction( ProductX, function ( arg )
    local   result;
    result := fail;
    result := ProductXHelp0( result, arg, 0 );
    return result;
end );

#############################################################################
##
#F  Perform( <list>, <func> )
##
InstallGlobalFunction( Perform, function(l, f)
    local x;
    for x in l do
        f(x);
    od;
end);


#############################################################################
##
#M  IsSubset( <C1>, <C2> )
##
InstallMethod( IsSubset,
    "for two collections in different families",
    IsNotIdenticalObj,
    [ IsCollection,
      IsCollection ],
    ReturnFalse );

InstallMethod( IsSubset,
    "for empty list and collection",
    [ IsList and IsEmpty,
      IsCollection ],
    function( empty, coll )
    return IsEmpty( coll );
    end );

InstallMethod( IsSubset,
    "for collection and empty list",
    [ IsCollection,
      IsList and IsEmpty ],
    ReturnTrue );

InstallMethod( IsSubset,
    "for two collections, the first containing the whole family",
    IsIdenticalObj,
    [ IsCollection and IsWholeFamily,
      IsCollection ],
    SUM_FLAGS+2, # better than everything else, however we must override the
                 # following two which are already ranked high.
    ReturnTrue );


InstallMethod( IsSubset,
    "for two collections, check for identity",
    IsIdenticalObj,
    [ IsCollection,
      IsCollection ],
    SUM_FLAGS+1, # better than the following method

function ( D, E )
    if not IsIdenticalObj( D, E ) then
        TryNextMethod();
    fi;
    return true;
end );


InstallMethod( IsSubset,
    "for two collections with known sizes, check sizes",
    IsIdenticalObj,
    [ IsCollection and HasSize,
      IsCollection and HasSize ],
    SUM_FLAGS, # do this before everything else

function ( D, E )
    if Size( E ) <= Size( D ) then
        TryNextMethod();
    fi;
    return false;
end );


InstallMethod( IsSubset,
    "for two internal lists",
    [ IsList and IsInternalRep,
      IsList and IsInternalRep ],
    IsSubsetSet );


InstallMethod( IsSubset,
    "for two collections that are internal lists",
    IsIdenticalObj,
    [ IsCollection and IsList and IsInternalRep,
      IsCollection and IsList and IsInternalRep ],
    IsSubsetSet );


InstallMethod( IsSubset,
    "for two collections with known `AsSSortedList'",
    IsIdenticalObj,
    [ IsCollection and HasAsSSortedList,
      IsCollection and HasAsSSortedList ],
function ( D, E )
    return IsSubsetSet( AsSSortedList( D ), AsSSortedList( E ) );
end );


InstallMethod( IsSubset,
    "for two collections (loop over the elements of the second)",
    IsIdenticalObj,
    [ IsCollection,
      IsCollection ],
function( D, E )
    return ForAll( E, e -> e in D );
end );


#############################################################################
##
#M  Intersection( <C>, ... )
##
BIND_GLOBAL( "IntersectionSet", function ( C1, C2 )
    local   I;
    if Length( C1 ) < Length( C2 ) then
        I := Set( C1 );
        IntersectSet( I, C2 );
    else
        I := Set( C2 );
        IntersectSet( I, C1 );
    fi;
    return I;
end );

InstallOtherMethod( Intersection2,
    "for two lists (not necessarily in the same family)",
    [ IsList, IsList ],
    IntersectionSet );

InstallOtherMethod( Intersection2,
    "for two lists or collections, the second being empty",
    [ IsListOrCollection, IsListOrCollection and IsEmpty ],
    function(C1, C2) return []; end);

InstallOtherMethod( Intersection2,
    "for two lists or collections, the first being empty",
    [ IsListOrCollection and IsEmpty, IsListOrCollection ],
    function(C1, C2) return []; end);

InstallMethod( Intersection2,
    "for two collections in the same family, both lists",
    IsIdenticalObj,
    [ IsCollection and IsList, IsCollection and IsList ],
    IntersectionSet );

InstallMethod( Intersection2,
    "for two collections in different families",
    IsNotIdenticalObj,
    [ IsCollection, IsCollection ],
    function( C1, C2 ) return []; end );

InstallMethod( Intersection2,
    "for two collections in the same family, the second being a list",
    IsIdenticalObj,
    [ IsCollection, IsCollection and IsList ],
    function ( C1, C2 )
    local   I, elm;
    if ( HasIsFinite( C1 ) or CanComputeSize( C1 ) ) and IsFinite( C1 ) then
        I := ShallowCopy( AsSSortedList( C1 ) );
        IntersectSet( I, C2 );
    else
        I := [];
        for elm in C2 do
            if elm in C1 then
                AddSet( I, elm );
            fi;
        od;
    fi;
    return I;
    end );

InstallMethod( Intersection2,
    "for two collections in the same family, the first being a list",
    IsIdenticalObj,
    [ IsCollection and IsList, IsCollection ],
    function ( C1, C2 )
    local   I, elm;
    if ( HasIsFinite( C2 ) or CanComputeSize( C2 ) ) and IsFinite( C2 ) then
        I := ShallowCopy( AsSSortedList( C2 ) );
        IntersectSet( I, C1 );
    else
        I := [];
        for elm in C1 do
            if elm in C2 then
                AddSet( I, elm );
            fi;
        od;
    fi;
    return I;
    end );

InstallMethod( Intersection2,
    "for two collections in the same family",
    IsIdenticalObj,
    [ IsCollection, IsCollection ],
    function ( C1, C2 )
    local   I, elm;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            I := ShallowCopy( AsSSortedList( C1 ) );
            IntersectSet( I, AsSSortedList( C2 ) );
        else
            I := [];
            for elm in C1 do
                if elm in C2 then
                    AddSet( I, elm );
                fi;
            od;
        fi;
    elif IsFinite( C2 ) then
        I := [];
        for elm in C2 do
            if elm in C1 then
                AddSet( I, elm );
            fi;
        od;
    else
        TryNextMethod();
    fi;
    return I;
    end );

InstallGlobalFunction( Intersection, function ( arg )
    local   I,          # intersection, result
            D,          # domain or list, running over the arguments
            copied,     # true if I is a list not identical to anything else
            i;          # loop variable

    # unravel the argument list if necessary
    if Length(arg) = 1  then
        arg := arg[1];
        if IsEmpty(arg) then
            return [];
        fi;
    fi;

    for D in arg do
        if not IsListOrCollection(D) then
            Error("Intersection: arguments must be lists or collections");
        fi;
    od;

    # start with the first domain or list
    I := arg[1];
    copied := false;

    # loop over the other domains or lists
    for i  in [2..Length(arg)]  do
        D := arg[i];
        if IsList( I ) and IsList( D )  then
            if not copied then I := Set( I ); fi;
            IntersectSet( I, D );
            copied := true;
        else
            I := Intersection2( I, D );
            copied := false;
        fi;
    od;

    # return the intersection
    if IsSSortedList( I ) then
      if not copied  then
        I:= ShallowCopy( I );
      fi;
    elif IsList( I ) then
      I:= Set( I );
    fi;
    return I;
end );


#############################################################################
##
#M  Union2( <C1>, <C2> )
##
BIND_GLOBAL( "UnionSet", function ( C1, C2 )
    local   I;
    if Length( C1 ) < Length( C2 ) then
        I := Set( C2 );
        UniteSet( I, C1 );
    else
        I := Set( C1 );
        UniteSet( I, C2 );
    fi;
    return I;
end );

InstallMethod( Union2,
    "for two collections that are lists",
    IsIdenticalObj,
    [ IsCollection and IsList, IsCollection and IsList ],
    UnionSet );

InstallOtherMethod( Union2,
    "for two lists",
    [ IsList, IsList ],
    UnionSet );

InstallMethod( Union2,
    "for two collections, the second being a list",
    IsIdenticalObj, [ IsCollection, IsCollection and IsList ],
    function ( C1, C2 )
    local   I;
    if IsFinite( C1 ) then
        I := ShallowCopy( AsSSortedList( C1 ) );
        UniteSet( I, C2 );
    else
        Error("sorry, cannot unite <C2> with the infinite collection <C1>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    "for two collections, the first being a list",
    IsIdenticalObj, [ IsCollection and IsList, IsCollection ],
    function ( C1, C2 )
    local   I;
    if IsFinite( C2 ) then
        I := ShallowCopy( AsSSortedList( C2 ) );
        UniteSet( I, C1 );
    else
        Error("sorry, cannot unite <C1> with the infinite collection <C2>");
    fi;
    return I;
    end );

InstallMethod( Union2,
    "for two collections",
    IsIdenticalObj, [ IsCollection, IsCollection ],
    function ( C1, C2 )
    local   I;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            I := ShallowCopy( AsSSortedList( C1 ) );
            UniteSet( I, AsSSortedList( C2 ) );
        else
            Error("sorry, cannot unite <C1> with the infinite collection <C2>");
        fi;
    elif IsFinite( C2 ) then
        Error("sorry, cannot unite <C2> with the infinite collection <C1>");
    else
        TryNextMethod();
    fi;
    return I;
    end );


#############################################################################
##
#F  Union( <list> )
#F  Union( <C>, ... )
##
## This apparently simple function (given that the work is usually done in
## Union2, UniteSet or Set) is complicated by the presence of ranges, something
## which comes up in a lot of permutation group and combinatorial applications
## We want to avoid unpacking long ranges if we possibly can, and return the result
## as a range if it can be.
##
## This code uses IS_RANGE and IS_RANGE_REP in place of ConvertToRangeRep and
## IsRangeRep because it is loaded early.
##
InstallGlobalFunction(Union, function(arg)
    local  tounite, handles, x, useUnion2, rangeSeen, distinct,
           lasthandle, i, h, u, smallest, secondsmallest,
           largest, ranges, sets, singletons, rd, singleton, min, max,
           smin, s, stride, goal, data, sizebound, needed, minNeeded,
           rstart, r, rmax, split, r2, newneeded;
    #
    # Union of one list is assumed to run over the list
    #
    if Length(arg) = 1 then
        arg := arg[1];
    fi;
    if Length(arg) = 0 then
        return [];
    fi;
    #
    # First scan. O(1) time per list
    #
    tounite := [];
    handles := [];
    useUnion2 := false;
    rangeSeen := false;
    for x in arg do
        if not IsListOrCollection(x) then
            Error("Union: arguments must be lists or collections");
        fi;
        if (HasLength(x) and Length(x) = 0) or (HasSize(x) and Size(x) = 0) then
            continue;
        fi;
        if IS_RANGE_REP(x) then
            rangeSeen := true;
        elif not IsPlistRep(x) then
            useUnion2 := true;
        fi;
        Add(tounite,x);
        Add(handles, HANDLE_OBJ(x));
    od;
    if Length(tounite) = 0 then
        return [];
    elif Length(tounite) = 1 then
        x := tounite[1];
        if IsList(x) then
            return Set(x);
        else
            return x;
        fi;
    fi;
    #
    # if we spotted anything except a plain list or range then we use
    # Union2 and UniteSet since the objects might have good methods installed
    #T could be cleverer if the first "non-plain" object is late in a long list
    #T but it's not clear whether the clever thing is to unite all the rest, or
    #T to start with the external object.
    #
    if useUnion2 then
        u := Union2(tounite[1],tounite[2]);
        for i in [3..Length(tounite)] do
            x := tounite[i];
            if IsSet(u) and IsMutable(u) and IsList(x) then
                UniteSet(u,x);
            else
                u := Union2(u,x);
            fi;
        od;
        IS_RANGE(u);
        return u;
    fi;
    #
    # Now eliminate identical lists
    #
    SortParallel(handles,tounite);
    distinct := [];
    lasthandle := fail;
    for i in [1..Length(tounite)] do
        h := handles[i];
        if h <> lasthandle then
            x := tounite[i];
            Add(distinct,x);
            lasthandle := h;
        fi;
    od;
    tounite := distinct;

    if Length(tounite) = 1 then
        x := tounite[1];
        if IsList(x) then
            return Set(x);
        else
            return x;
        fi;
    fi;
    #
    # if we have nothing but plain lists then it is at most linear in space and time
    # to concatenate and sort and then check for range
    #
    if not rangeSeen then
        u := Set(Concatenation(tounite));
        IS_RANGE(u);
        return u;
    fi;
    #
    # Next pass looks at all entries of lists and the defining data of ranges
    # linear in the total memory occupied by the (remaining) input.
    # in this pass we will notice any elements that are not small integers and also
    # work out what range the union is, if in fact it is a range.
    #

    smallest := infinity;
    secondsmallest := infinity;
    largest := -infinity;
    ranges := [];
    sets := [];
    singletons := [];



    for x in tounite do
        rd := fail;
        singleton := false;

        if Length(x) = 1 then
            singleton := true;
            min := x[1];
            max := x[1];
        elif IS_RANGE_REP(x) then
            if x[2] < x[1] then
                x := Reversed(x);
            fi;
            rd := x;
            min := x[1];
            smin := x[2];
            max := x[Length(x)];
        else
            s := Set(x);
            if Length(s) = 1 then
                singleton := true;
                min := s[1];
                max := s[1];
            else
                if IS_RANGE(s) then
                    rd := s;
                else
                    rd := fail;
                    if not ForAll(s, IsSmallIntRep) then
                        #
                        # result cannot be a range, so fall back
                        #
                        return Set(Concatenation(tounite));
                    fi;
                fi;
                min := s[1];
                smin := s[2];
                max := s[Length(s)];
            fi;
        fi;
        #
        # At this point either x was a singleton whose value is now in max and min
        # or x was a range of length 2 or more and rd contains it
        # or x was NOT a range rd is fail and s contains x sorted and with duplicates removed
        # but x does consist entirely of small integers
        #
        # Furthermore min, smin and max contain the smallest, second smallest and largest
        # entries of x (except if singleton is true)
        #

        if singleton then
            if not IsSmallIntRep(min) then
                return Set(Concatenation(tounite));
            fi;
            Add(singletons, min);
        elif rd = fail then
            Add(sets,s);
        else
            Add(ranges,rd);
        fi;

        if min < smallest then
            secondsmallest := smallest;
            smallest := min;
        elif min > smallest and min < secondsmallest then
            secondsmallest := min;
        fi;
        if not singleton and smin < secondsmallest then
            secondsmallest := smin;
        fi;
        if max > largest then
            largest := max;
        fi;
    od;

    singletons := Set(singletons);
    Add(sets, singletons);

    # So, if we get to here we know that everything is small integers and that if the result is a range
    # then we know which range it is. Now we somehow have to work out if it actually is that range or not
    # it's not too hard to check if it is a subset of that range (indeed if the stride is 1 we know it is).
    # but we're trying hard to avoid time or space proportional to the size of that range.

    # Since we know by this point that we started with at least one range, we know we had
    # at least two values, so if the result is a range it will have a defined stride

    stride := secondsmallest - smallest;
    if (largest - smallest) mod stride <> 0 then
        return Set(Concatenation(tounite));
    fi;

    goal := [smallest, secondsmallest .. largest];


    #
    # We want the stride 1 ranges in front, ordered by starting position
    #

    data := List(ranges, r-> [r[2]-r[1],r[1],-Length(r)]);
    SortParallel(data,ranges);

    #
    # Check for inclusion
    #

    if stride > 1 and
        (ForAny(ranges, r->not r[1] in goal or (r[2]-r[1]) mod stride <> 0) or
            ForAny(sets, s-> ForAny(s, a -> not a in goal))) then
       return Set(Concatenation(tounite));
    fi;


    #
    # So now we have the hard part. We need to check that the whole range is actually covered
    #


    #
    # Start with an easy size bound
    #

    sizebound := Sum(sets,Size) + Sum(ranges, Size);

    if sizebound < Size(goal) then
        #
        # Even if everything is disjoint there are not enough points to cover the range
        #
        return Set(Concatenation(tounite));
    fi;

    #
    # We can deal with the ranges with matching stride super-quickly by
    # sweeping through them in order
    #
    needed := [];
    minNeeded := goal[1];
    rstart := Length(ranges)+1;
    for i in [1..Length(ranges)] do
        r := ranges[i];
        if r[2] -r[1] > stride then
            #
            # passed all the stuff with matching stride, leave the rest to the more complex
            # code
            #
            rstart := i;
            break;
        fi;
        # if we were out of phase we'd have failed the inclusion check above
        if r[1] > minNeeded then
            #
            #  leaves a hole
            #
            Add(needed,[minNeeded, minNeeded+stride..r[1]-stride]);
        fi;
        rmax := r[Length(r)];
        if rmax >= minNeeded then
            #
            # Progress with sweep
            #
            minNeeded := rmax+stride;
        fi;
    od;
    #
    # Don't forget the last bit.
    #
    if minNeeded <= largest then
        Add(needed,[minNeeded, minNeeded+stride.. largest]);
    fi;

    if needed = [] then
        return goal;
    fi;


    # Finally then, we are in a case where we really need to be clever, so
    # We keep track of the points in goal we haven't seen yet as we run through the ranges
    # of non-matching stride
    # But we represent them as a union of ranges.

    split := function(r, r2)
        local  outs, max2, max, stride, stride2, i;
        #
        # This function essentially computes the difference between r and r2
        # but represents it as a union of ranges
        #
        outs := [];
        max2 := r2[Length(r2)];
        if Length(r) = 1 then
            #
            # This case is simpler
            if not r[1] in r2 then
                Add(outs,r);
            fi;
            return outs;
        fi;
        max := r[Length(r)];

        #
        # There is a good kernel intersection for two ranges
        # replacing r2 by the intersection (which is always a range)
        # makes the next part simpler
        #
        r2 := Intersection(r2,r);

        #
        # We might miss completely
        #

        if Length(r2) = 0 then
            Add(outs,r);
            return outs;
        fi;

        max2 := r2[Length(r2)];

        #
        # In general we have the bit before r2, the bit after and
        # the stuff within r2 but which it misses
        #
        stride := r[2]-r[1];
        if r2[1] > r[1] then
            Add(outs, [r[1],r[2]..r2[1]-stride]);
        fi;
        if max > max2 then
            Add(outs, [max2+stride,max2+2*stride..max]);
        fi;
        if Length(r2) > 1 then
            stride2 := r2[2]-r2[1];
            if stride2 > stride then
                for i in [stride,stride*2..stride2-stride] do
                    Add(outs,[r2[1]+i,r2[1]+stride2+i..max2-stride2+i]);
                od;
            fi;
        fi;

        return outs;
    end;

    #
    # Now we subtract the ranges we have from the goal
    #
    for r2 in ranges{[rstart..Length(ranges)]} do
        newneeded := [];
        for r in needed do
            Append(newneeded,split(r,r2));
        od;
        needed := newneeded;
    od;

    #
    # and then any remaining points must be in the sets
    #

    if ForAny(needed, r-> ForAny(r, x-> ForAll(sets, s -> not x in s))) then
        return Set(Concatenation(tounite));
    else
        return goal;
    fi;
end);


#############################################################################
##
#M  Difference( <C1>, <C2> )
##
InstallOtherMethod( Difference,
    "for empty list, and collection",
    [ IsList and IsEmpty, IsListOrCollection ],
    function ( C1, C2 )
    return [];
    end );

InstallOtherMethod( Difference,
    "for collection, and empty list",
    [ IsCollection, IsList and IsEmpty ],
    function ( C1, C2 )
    return Set( C1 );
    end );

InstallOtherMethod( Difference,
    "for two lists (assume one can produce a sorted result)",
    [ IsList, IsList ],
    function ( C1, C2 )
    C1 := Set( C1 );
    SubtractSet( C1, C2 );
    return C1;
    end );

InstallMethod( Difference,
    "for two collections that are lists",
    IsIdenticalObj, [ IsCollection and IsList, IsCollection and IsList ],
    function ( C1, C2 )
    C1 := Set( C1 );
    SubtractSet( C1, C2 );
    return C1;
    end );

InstallMethod( Difference,
    "for two collections in different families",
    IsNotIdenticalObj, [ IsCollection, IsCollection ],
    function( C1, C2 ) return C1; end );

InstallMethod( Difference,
    "for two collections in the same family",
    IsIdenticalObj, [ IsCollection, IsCollection ],
    function ( C1, C2 )
    local   D, elm;
    if IsFinite( C1 ) then
        if IsFinite( C2 ) then
            D := ShallowCopy( AsSSortedList( C1 ) );
            SubtractSet( D, AsSSortedList( C2 ) );
        else
            D := [];
            for elm in C1 do
                if not elm in C2 then
                    AddSet( D, elm );
                fi;
            od;
        fi;
    else
        Error("sorry, cannot subtract from the infinite domain <C1>");
    fi;
    return D;
    end );

InstallMethod( Difference,
    "for two collections in the same family, the first being a list",
    IsIdenticalObj, [ IsCollection and IsList, IsCollection ],
    function ( C1, C2 )
    local   D, elm;
    if IsFinite( C2 )  then
        D := Set( C1 );
        SubtractSet( D, AsSSortedList( C2 ) );
    else
        D := [];
        for elm in C1 do
            if not elm in C2 then
                AddSet( D, elm );
            fi;
        od;
    fi;
    return D;
    end );

InstallMethod( Difference,
    "for two collections in the same family, the second being a list",
    IsIdenticalObj, [ IsCollection, IsCollection and IsList ],
    function ( C1, C2 )
    local   D;
    if IsFinite( C1 ) then
        D := ShallowCopy( AsSSortedList( C1 ) );
        SubtractSet( D, C2 );
    else
        Error( "sorry, cannot subtract from the infinite domain <D>" );
    fi;
    return D;
    end );


#############################################################################
##
#M  CanEasilyCompareElements( <obj> )
##
InstallMethod(CanEasilyCompareElements,"generic: inherit `true' from family",
  [IsObject],
function(obj)
  if not IsFamily(obj) then
    return CanEasilyCompareElementsFamily(FamilyObj(obj));
  fi;
  return false;
end);

InstallGlobalFunction(CanEasilyCompareElementsFamily,function(fam)
  if HasCanEasilyCompareElements(fam) then
    return CanEasilyCompareElements(fam);
  else
    return false;
  fi;
end);

InstallMethod(CanEasilyCompareElements,"family: default false",
  [IsFamily], ReturnFalse);

InstallOtherMethod(SetCanEasilyCompareElements,"family setter",
  [IsFamily,IsObject],
function(fam,val)
  # if the value is `true' we want to store it and to imply it for elements
  if val=true then
    fam!.IMP_FLAGS:=WITH_IMPS_FLAGS(AND_FLAGS(fam!.IMP_FLAGS,
                                              CanEasilyCompareElements ) );
  fi;
  TryNextMethod();
end);

#############################################################################
##
#M  CanEasilySortElements( <obj> )
##
InstallMethod(CanEasilySortElements,"generic: inherit `true' from family",
  [IsObject],
function(obj)
  if not IsFamily(obj) then
    return CanEasilySortElementsFamily(FamilyObj(obj));
  fi;
  return false;
end);

InstallGlobalFunction(CanEasilySortElementsFamily,function(fam)
  if HasCanEasilySortElements(fam) then
    return CanEasilySortElements(fam);
  else
    return false;
  fi;
end);

InstallMethod(CanEasilySortElements,"family: default false",
  [IsFamily],ReturnFalse);

InstallOtherMethod(SetCanEasilySortElements,"family setter",
  [IsFamily,IsObject],
function(fam,val)
  # if the value is `true' we want to store it and to imply it for elements
  if val=true then
    fam!.IMP_FLAGS:=WITH_IMPS_FLAGS(AND_FLAGS(fam!.IMP_FLAGS,
                                              CanEasilySortElements ) );
  fi;
  TryNextMethod();
end);

InstallMethod( CanComputeIsSubset,"default: no, unless identical",
  [IsObject,IsObject],IsIdenticalObj);

# This setter method is installed to implement filter settings in response
# to an objects size as part of setting the size. This used to be handled
# instead by immediate methods, but in a situation as here it would trigger
# multiple immediate methods, several of which could apply and each changing
# the type of the object. Doing so can be costly and thus should be
# avoided.
InstallOtherMethod(SetSize,true,[IsObject and IsAttributeStoringRep,IsObject],
  100, # override system setter
function(obj,sz)
local filt;
  if HasSize(obj) and Size(obj)<>sz then
    CHECK_REPEATED_ATTRIBUTE_SET(obj, "Size", sz);
    return;
  fi;

  # some sanity checks
  Assert(0, not HasIsEmpty(obj) or (IsEmpty(obj) = (sz=0)));
  Assert(0, not HasIsNonTrivial(obj) or (IsNonTrivial(obj) = (sz<>1)));
  Assert(0, not HasIsTrivial(obj) or (IsTrivial(obj) = (sz=1)));
  Assert(0, not HasIsFinite(obj) or (IsFinite(obj) = (sz<>infinity)));

  if sz=0 then filt:=IsEmpty;
  elif sz=1 then filt:=IsTrivial;
  elif sz=infinity then filt:=IsNonTrivial and HasIsFinite;
  else filt:=IsNonTrivial and IsFinite;
  fi;
  filt:=filt and HasSize;
  obj!.Size:=sz;
  SetFilterObj(obj,filt);
end);
