#############################################################################
##
#W  coll.gd                     GAP library                  Martin Schoenert
#W                                                            & Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for collections.
##
Revision.coll_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsListOrCollection( <obj> )
##
##  New intermediate Category to get Lists and Collections under a common roof
##
IsListOrCollection := NewCategory( "IsListOrCollection", IsObject );


#############################################################################
##
#C  IsCollection(<obj>) . . . . . . . . . . test if an object is a collection
##
IsCollection := NewCategory(
     "IsCollection",
     IsListOrCollection );


#############################################################################
##
#C  IsFamilyCollections(<Fam>)  . . test if an object is a collections family
##
IsFamilyCollections :=
    CategoryFamily( "IsFamilyCollections",
        IsCollection );


#############################################################################
##
#A  CollectionsFamily(<F>)  . . . . . . . . . . . . make a collections family
##
CollectionsFamily :=
    NewAttribute( "CollectionsFamily",
        IsFamily );
SetCollectionsFamily := Setter( CollectionsFamily );
HasCollectionsFamily := Tester( CollectionsFamily );


#############################################################################
##
#A  ElementsFamily(<F>) . . . . . . . . . . . . . .  make the elements family
##
##  The way collections families are created, they always know their elements
##  family.
##
ElementsFamily :=
    NewAttribute( "ElementsFamily",
        IsFamily );
SetElementsFamily := Setter( ElementsFamily );
HasElementsFamily := Tester( ElementsFamily );


#############################################################################
##
#V  CATEGORIES_COLLECTIONS  . . . . . . global list of collections categories
##
#O  CategoryCollections(<name>,<elms_filter>) . . . . .  collections category
##
CATEGORIES_COLLECTIONS  := [];

CategoryCollections  := function ( name, elms_filter )
    local    pair, super, flags, coll_filter;

    # Check whether the collections category is already defined.
    for pair in CATEGORIES_COLLECTIONS do
      if IsIdentical( pair[1], elms_filter ) then
        return pair[2];
      fi;
    od;

    # Find the super category among the known collections categories.
    super := IsCollection;
    flags := WITH_IMPS_FLAGS( FLAGS_FILTER( elms_filter ) );
    for pair in CATEGORIES_COLLECTIONS do
      if IS_SUBSET_FLAGS( flags, FLAGS_FILTER( pair[1] ) ) then
        super := super and pair[2];
      fi;
    od;

    # Construct the collections category.
    coll_filter := NewCategory( name, super );
    ADD_LIST( CATEGORIES_COLLECTIONS, [ elms_filter, coll_filter ] );
    return coll_filter;
end;


#############################################################################
##
#F  InstallCollectionsTrueMethod(<filter>,<elms-req>,<coll-req>)
##
InstallCollectionsTrueMethod := function ( filter, elms_req, coll_req )
    local    coll_cat;
    coll_cat := CategoryCollections( "<<collections-cat>>", elms_req );
    InstallTrueMethod( filter, coll_cat and coll_req );
end;


#############################################################################
##
#C  IsIterator(<obj>) . . . . . . . . . . .  test if an object is an iterator
##
IsIterator :=
    NewCategory( "IsIterator",
        IsObject );


#############################################################################
##
#O  IsDoneIterator(<iter>)  . . . . . . . .  test if an iterator is exhausted
##
##  If <iter> is an iterator for the collection $C$ then
##  'IsDoneIterator( <iter> )' is 'true' if all elements of $C$ have been
##  returned already by 'NextIterator( <iter> )', and 'false' otherwise.
##
IsDoneIterator :=
    NewOperation( "IsDoneIterator",
        [ IsIterator ] );


#############################################################################
##
#O  NextIterator(<iter>)  . . . . . . . . . . . next element from an iterator
##
##  Let <iter> be an iterator for the collection $C$.
##  If 'IsDoneIterator( <iter> )' is 'false' then 'NextIterator( <iter> )' is
##  the next element of $C$, according to the succession defined by <iter>,
##  and 'fail' otherwise.
##
NextIterator :=
    NewOperation( "NextIterator",
        [ IsIterator ] );


#############################################################################
##
#P  IsEmpty(<C>)  . . . . . . . . . . . . . . . test if a collection is empty
##
##  'IsEmpty'  returns 'true'  if the  collection  <C> is  empty, and 'false'
##  otherwise.
##
IsEmpty :=
    NewProperty( "IsEmpty",
        IsCollection );
SetIsEmpty := Setter( IsEmpty );
HasIsEmpty := Tester( IsEmpty );


#############################################################################
##
#P  IsTrivial(<C>)  . . . . . . . . . . . . . test if a collection is trivial
##
##  'IsTrivial' returns 'true' if the collection <C>  consists of exactly one
##  element.
##
#N  1996/08/08 M.Schoenert is this a sensible definition?
##
IsTrivial :=
    NewProperty( "IsTrivial",
        IsCollection );
SetIsTrivial := Setter( IsTrivial );
HasIsTrivial := Tester( IsTrivial );


#############################################################################
##
#P  IsFinite(<C>) . . . . . . . . . . . . . .  test if a collection is finite
##
##  'IsFinite' returns  'true' if the  collection <C>  is  finite and 'false'
##  otherwise.
##
IsFinite :=
    NewProperty( "IsFinite",
        IsCollection );
SetIsFinite := Setter( IsFinite );
HasIsFinite := Tester( IsFinite );

InstallSubsetTrueMethod( IsFinite,
    IsCollection and IsFinite, IsCollection );
InstallFactorTrueMethod( IsFinite,
    IsCollection and IsFinite, IsCollection, IsCollection );

InstallTrueMethod( IsFinite, IsTrivial );


#############################################################################
##
#P  IsWholeFamily(<C>)  . . . .test if a collection contains the whole family
##
##  'IsWholeFamily' returns  'true' if the collection  <C> contains the whole
##  family.
##
IsWholeFamily :=
    NewProperty( "IsWholeFamily",
        IsCollection );
SetIsWholeFamily := Setter( IsWholeFamily );
HasIsWholeFamily := Tester( IsWholeFamily );


#############################################################################
##
#A  Size(<C>) . . . . . . . . . . . . . . . . . . . . .  size of a collection
##
Size :=
    NewAttribute( "Size",
        IsListOrCollection );
SetSize := Setter( Size );
HasSize := Tester( Size );


#############################################################################
##
#A  Representative(<C>) . . . . . . . . . . . . . one element of a collection
##
Representative :=
    NewAttribute( "Representative",
        IsListOrCollection );
SetRepresentative := Setter( Representative );
HasRepresentative := Tester( Representative );


#############################################################################
##
#A  RepresentativeSmallest(<C>) . . . . . . . . . one element of a collection
##
RepresentativeSmallest :=
    NewAttribute( "RepresentativeSmallest",
        IsListOrCollection );
SetRepresentativeSmallest := Setter( RepresentativeSmallest );
HasRepresentativeSmallest := Tester( RepresentativeSmallest );


#############################################################################
##
#O  Random(<C>) . . . . . . . . . . . . . . .  random element of a collection
##
Random :=
    NewOperation( "Random",
        [ IsListOrCollection ] );


#############################################################################
##
#A  AsList( <coll> )  . . . . . . . . . . .  list of elements of a collection
##
##  'AsList' returns an immutable list <list>.
##  <coll> must be a collection or a list.
##  If <coll> is a list (which may contain holes), then 'Length(<list>)' is
##  'Length(<coll>)' and <list> contains the elements (and holes) of <coll>
##  in the same order.
##  If <coll> is a collection that is not a list, then 'Length(<list>)' is
##  the number of different elements of <coll> and <list> contains the
##  different elements of <coll> in an unspecified order, which may change
##  for repeated calls of 'AsList'.
##  '<list>[<pos>]' executes in constant time,
##  and the size of <list> is proportional to its length.
##  'AsList' is an attribute.
##
##  For both lists and collections, the default method is
##  'ConstantTimeAccessList( Enumerator( <coll> ) )'.
##    
AsList :=
    NewAttribute( "AsList",
        IsListOrCollection );
SetAsList := Setter( AsList );
HasAsList := Tester( AsList );


#############################################################################
##
#A  AsListSorted( <coll> )  . . . . . . . . . set of elements of a collection
##
##  'AsListSorted' returns an immutable list <list>.
##  <coll> must be a collection or a list that is not dense but whose
##  elements lie in the same family.
##  'Length(<list>)' is the number of different elements of <coll>,
##  and <list> contains the different elements of <coll> in sorted order.
##  '<list>[<pos>]' executes in constant time, and the size of <list> is
##  proportional to its length.
##  'AsListSorted' is an attribute.
##
##  For both lists and collections, the default method is
##  'ConstantTimeAccessList( EnumeratorSorted( <coll> ) )'.
##
AsListSorted :=
    NewAttribute( "AsListSorted",
        IsListOrCollection );
SetAsListSorted := Setter( AsListSorted );
HasAsListSorted := Tester( AsListSorted );


#############################################################################
##
#A  Enumerator( <coll> )  . . . . . . . . .  list of elements of a collection
##
##  'Enumerator' returns an immutable list <list>.
##  <coll> must be a collection.
##  If <coll> is a list (which may contain holes), then 'Length(<list>)' is
##  'Length(<coll>)', and <list> contains the elements (and holes) of <coll>
##  in the same order.
##  If <coll> is a collection that is not a list, then 'Length(<list>)' is
##  the number of different elements of <coll>, and <list> contains the
##  different elements of <coll> in an unspecified order, which may change
##  for repeated calls.
##  '<list>[<pos>]' may not execute in constant time and the size of
##  <list> is as small as feasable.
##  'Enumerator' is an attribute.
##
##  For lists, the default method is 'Immutable'.
##  For collections that are not lists, there is no default method.
##
Enumerator :=
    NewAttribute( "Enumerator",
        IsListOrCollection );
SetEnumerator := Setter( Enumerator );
HasEnumerator := Tester( Enumerator );


#############################################################################
##
#A  EnumeratorSorted( <coll> )  . . . . . . . set of elements of a collection
##
##  'EnumeratorSorted' returns an immutable list <list>.
##  <coll> must be a collection or a list that is not dense but whose
##  elements lie in the same family.
##  'Length(<list>)' is the number of different elements of <coll>,
##  and <list> contains the different elements of <coll> in sorted order.
##  '<list>[<pos>]' may not execute in constant time, and the size of <list>
##  is as small as feasable.
##  'EnumeratorSorted' is an attribute.
##
##  For lists this is implemented by 'AsListSortedList( <coll> )'.
##  For collections that are not lists, the generic method is
##  'AsListSortedList( Enumerator( <coll> ) )'.
##
EnumeratorSorted :=
    NewAttribute( "EnumeratorSorted",
        IsListOrCollection );
SetEnumeratorSorted := Setter( EnumeratorSorted );
HasEnumeratorSorted := Tester( EnumeratorSorted );


#############################################################################
##
#O  List( <coll> )  . . . . . . . . . . . .  list of elements of a collection
##
##  'List' returns a new mutable list <list>.
##  <coll> must be a collection or a list.
##  If <coll> is a list (which need not be dense or homogeneous),
##  then 'Length(<list>)' is 'Length(<coll>)', and <list> contains the
##  elements (and the holes) of <coll> in the same order.
##  If <coll> is a collection that is not a list, then 'Length(<list>)'
##  is the number of different elements of <coll>, and <list> contains the
##  different elements of <coll> in an unspecified order which may change
##  for repeated calls.
##  '<list>[<pos>]' executes in constant time, and the size of <list> is
##  proportional to its length.
##  'List' is an operation.
##
##  For lists this is implemented by 'ShallowCopy( <coll> )'.
##  For collections that are not lists, the generic method is
##  'ShallowCopy( Enumerator( <coll> ) )'.
#T this is not reasonable since 'ShallowCopy' need not guarantee to return
#T a constant time access list
##
List :=
    NewOperation( "List",
        [ IsListOrCollection ] );


#############################################################################
##
#O  ListSorted( <coll> )  . . . . . . . . . . set of elements of a collection
##
##  'ListSorted' returns a new mutable list <list>.
##  <coll> must be a collection or a list that is not necessarily dense
##  but whose elements lie in the same family.
##  'Length(<list>)' is the number of different elements of <coll>,
##  and <list> contains the different elements of <coll> in sorted order.
##  '<list>[<pos>]' executes in constant time, and the size of <list> is
##  proportional to its length.
##  'ListSorted' is an operation.
##
##  For lists this is implemented by 'ShallowCopy( ListSortedList(<coll>) )'.
##  For collections that are not lists, the generic method is
##  'ShallowCopy( EnumeratorSorted( <coll> ) )'.
##
ListSorted :=
    NewOperation( "ListSorted",
        [ IsListOrCollection ] );

Set := ListSorted;


#############################################################################
##
#O  Iterator( <coll> )  . . . . . . . . . . .  list iterator for a collection
##
##  'Iterator' returns an iterator.
##  <coll> must be a collection or a list.
##  If <coll> is a list (which may contain holes), then it iterates over the
##  elements (but not the holes) of <coll> in the same order.
##  Otherwise it iterates over the elements of <coll> in an unspecified
##  order, which may change for repeated calls.
##  'Iterator' is an operation.
##
##  For lists this is implemented by 'IteratorList( <coll> )'.
##  For collections that are not lists, the generic method is
##  'IteratorList( Enumerator( <coll> ) )'.
##  For collections better methods should be provided if possible.
##
Iterator :=
    NewOperation( "Iterator",
        [ IsListOrCollection ] );


#############################################################################
##
#O  IteratorSorted( <coll> )  . . . . . . . . . set iterator for a collection
##
##  'IteratorSorted' returns an iterator.
##  <coll> must be a collection or a list that is not dense but whose
##  elements lie in the same family.
##  It loops over the different elements of <coll> in sorted order.
##  'IteratorSorted' is an operation.
##
##  For lists this is implemented by 'IteratorList(ListSortedList(<coll>))'.
##  For collections that are not lists, the generic method is
##  'IteratorList( EnumeratorSorted( <coll> ) )'.
##
IteratorSorted :=
    NewOperation( "IteratorSorted",
        [ IsListOrCollection ] );


#############################################################################
##
#F  TrivialIterator( <elm> )
##
##  is an iterator for a collection that consists of one element <elm>.
##
TrivialIterator := NewOperationArgs( "TrivialIterator" );


#############################################################################
##
#O  Sum(<C>)  . . . . . . . . . . . . . . sum of the elements of a collection
##
Sum :=
    NewOperation( "Sum",
        [ IsListOrCollection ] );


#############################################################################
##
#O  Product(<C>)  . . . . . . . . . . product of the elements of a collection
##
##  'Product( <C> )' \\
##  'Product( <C>, <func> )'
##
##  When used in the first way 'Product'  returns the product of the elements
##  of the collection <C>.  When used in the second way 'Product' applies the
##  function  <func>, which   must be a   function taking  one  argument, and
##  returns  the  product of the  results.   In either case   if <C> is empty
##  'Product' returns 1.
##
Product :=
    NewOperation( "Product",
        [ IsListOrCollection ] );


#############################################################################
##
#O  Filtered(<C>,<func>)  . . . . . . . extract elements that have a property
##
Filtered :=
    NewOperation( "Filtered",
        [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  Number(<C>,<func>)  . . . . . . . . . count elements that have a property
##
Number :=
    NewOperation( "Number",
        [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  ForAll(<C>,<func>)  . . . . .  test a property for all elements of a list
##
ForAll :=
    NewOperation( "ForAll",
        [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  ForAny(<C>,<func>)  . . . . . . test a property for any element of a list
##
ForAny :=
    NewOperation( "ForAny",
        [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  ListX(<arg1>,...)
##
##  'ListX' returns a new list constructed from the arguments.
##
##  Each argument except  the final one must   be either a  collection, which
##  introduces a nested for-loop; or a function returning a collection, which
##  introduces a nested for-loop where  the loop-range depends on the  values
##  of the outer  loop-variables; or a function  returning 'true' or 'false',
##  which  introduces a   nested  if-statement.  The  last  argument must  be
##  function, which is applied to the values  of the loop-variables and whose
##  results are collected.
##
##  For example,  assuming <arg1>  is  a  collection, <arg2> is   a  function
##  returning 'true' or 'false', <arg3> is a function returning a collection,
##  <arg4>  is another  function returning  'true'  or 'false', then the call
##  '<result> := ListX(<arg1>,<arg2>,<arg3>,<arg4>,<arg5>)' is equivalent to
##
##      <result> := [];
##      for v1 in <arg1> do
##          if <arg2>( v1 ) then
##              for v2 in <arg3>( v1 ) do
##                  if <arg4>( v1, v2 ) then
##                      Add( <result>, <arg5>( v1, v2 ) );
##                  fi;
##              od;
##          fi;
##      od;
##
ListX :=
    NewOperationArgs( "ListX" );


#############################################################################
##
#O  SetX(<arg1>,...)
##
SetX :=
    NewOperationArgs( "SetX" );


#############################################################################
##
#O  SumX(<arg1>,...)
##
SumX :=
    NewOperationArgs( "SumX" );


#############################################################################
##
#O  ProductX(<arg1>,...)
##
ProductX :=
    NewOperationArgs( "ProductX" );


#############################################################################
##
#O  IsSubset(<C1>,<C2>) . . . . . . . . . . .  test for subset of collections
##
##  'IsSubset'  returns 'true'  if  <C2>, which must   be a collection, is  a
##  subset of <C1>, which also must be a collection, and 'false' otherwise.
##
IsSubset :=
    NewOperation( "IsSubset",
        [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#O  Intersection(<C1>,<C2>...)  . . . . . . . . . intersection of collections
##
Intersection2 :=
    NewOperation( "Intersection2",
        [ IsListOrCollection, IsListOrCollection ] );

Intersection :=
    NewOperationArgs( "Intersection" );


#############################################################################
##
#O  Union(<C1>,<C2>...) . . . . . . . . . . . . . . . .  union of collections
##
Union2 :=
    NewOperation( "Union2",
        [ IsListOrCollection, IsListOrCollection ] );

Union :=
    NewOperationArgs( "Union" );


#############################################################################
##
#O  Difference(<C1>,<C2>) . . . . . . . . . . . . .  difference of collection
##
Difference :=
    NewOperation( "Difference",
        [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#O  IsElmsColls(<F1>,<F2>) test if a family is the elements family of another
##
#N  1996/08/08 M.Schoenert this should not be in this file
##
IsElmsColls := function ( F1, F2 )
    return HasElementsFamily( F2 )
       and IsIdentical( F1, ElementsFamily(F2) );
end;

IsNotElmsColls := function ( F1, F2 )
    return not HasElementsFamily( F2 )
       or IsNotIdentical( F1, ElementsFamily(F2) );
end;

IsElmsCollColls := function ( F1, F2 )
    return HasElementsFamily( F2 )
       and HasElementsFamily( ElementsFamily( F2 ) )
       and IsIdentical( F1, ElementsFamily( ElementsFamily( F2 ) ) );
end;


#############################################################################
##
#O  IsCollsElms(<F1>,<F2>) test if a family is the elements family of another
##
#N  1996/08/08 M.Schoenert this should not be in this file
##
IsCollsElms := function ( F1, F2 )
    return HasElementsFamily( F1 )
       and IsIdentical( ElementsFamily(F1), F2 );
end;

IsCollCollsElms := function ( F1, F2 )
    return HasElementsFamily( F1 )
       and HasElementsFamily( ElementsFamily( F1 ) )
       and IsIdentical( ElementsFamily( ElementsFamily( F1 ) ), F2 );
end;


#############################################################################
##
#O  IsCollsElmsElms( <F1>, <F2>, <F3> )
##
#N  1996/08/08 M.Schoenert this should not be in this file
##
IsCollsElmsElms := function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and IsIdentical( ElementsFamily(F1), F2 )
       and IsIdentical( F2, F3 );
end;

IsCollsElmsElmsElms := function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdentical( ElementsFamily(F1), F2 )
       and IsIdentical( F2, F3 )
       and IsIdentical( F2, F4 );
end;

IsCollCollsElmsElms := function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and HasElementsFamily( ElementsFamily(F1) )
       and IsIdentical( ElementsFamily( ElementsFamily(F1) ), F2 )
       and IsIdentical( F2, F3 );
end;

IsCollsCollsElms := function( F1, F2, F3 )
    return HasElementsFamily( F1 )
       and IsIdentical( F1, F2 )
       and IsIdentical( ElementsFamily( F1 ), F3 );
end;

IsCollsElmsColls := function(a,b,c)
  return IsIdentical(a,c) and HasElementsFamily(a) and
    IsIdentical(b,ElementsFamily(a));
end;


#############################################################################
##
#E  coll.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

