#############################################################################
##
#W  coll.gd                     GAP library                  Martin Schoenert
#W                                                            & Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for collections.
##
##  Basic operation for collections is 'Enumerator'.
##
Revision.coll_gd :=
    "@(#)$Id$";


#T change the installation of isomorphism and factor maintained methods
#T in the same way as that of subset maintained methods!


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
IsFamilyCollections := CategoryFamily( IsCollection );


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
#O  CategoryCollections( <elms_filter> )  . . . . . . .  collections category
##
CATEGORIES_COLLECTIONS  := [];

CategoryCollections  := function ( elms_filter )
    local    pair, super, flags, name, coll_filter;

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

    # Construct the name of the category.
    name := "CategoryCollections(";
    APPEND_LIST_INTR( name, SHALLOW_COPY_OBJ( NameFunction(elms_filter) ) );
    APPEND_LIST_INTR( name, ")" );
    CONV_STRING( name );

    # Construct the collections category.
    coll_filter := NewCategory( name, super );
    ADD_LIST( CATEGORIES_COLLECTIONS, [ elms_filter, coll_filter ] );
    return coll_filter;
end;


#############################################################################
##
#O  UseSubsetRelation( <super>, <sub> )
##
##  Methods for this operation deduce possibly useful information from the
##  collection <super> to its subset <sub>, or vice versa.
##
##  'UseSubsetRelation' is called automatically whenever substructures
##  of domains are constructed.
##  So the methods must be *cheap*, and the requirements should be as
##  sharp as possible!
##
##  To achieve that *all* applicable methods are executed, all methods for
##  this operation except the default method installed below must end with
##  'TryNextMethod()'.
##
UseSubsetRelation := NewOperation( "UseSubsetRelation",
    [ IsCollection, IsCollection ] );

InstallMethod( UseSubsetRelation,
    "default method that returns 'true'",
    IsIdentical,
    [ IsCollection, IsCollection ],
    # Make sure that this method is installed with ``real'' rank zero.
    - 2 * SIZE_FLAGS(WITH_HIDDEN_IMPS_FLAGS(FLAGS_FILTER( IsCollection ))),
    function( super, sub )
    return true;
    end );


#############################################################################
##
#V  SUBSET_MAINTAINED_INFO
##
##  is a list of triples,
##  the first entry being the list of filter numbers of an operation that is
##  inherited to subsets,
##  the second being the list of filter numbers of requirements,
##  and the third being the real rank of the method.
##
SUBSET_MAINTAINED_INFO := [];


#############################################################################
##
#F  InstallSubsetMaintainedMethod( <opr>, <super_req>, <sub_req> )
##
##  <opr> must be a property or an attribute.
##  Let $S$ be a domain in the filter <sub_req> that is known to be a subset
##  of a domain $D$ in the filter <super_req> such that the value of <opr> is
##  known for $D$.
##  Then the value of <opr> for $S$ shall be the same as the value for $D$.
##
##  If <opr> is a property and the filter <super_req> lies in the filter
##  <opr> then we can use also the following inverse implication.
##  If $D$ is in the filter whose intersection with <opr> is <super_req>
##  and if $S$ is in the filter <sub_req>, $S$ is a subset of $D$, and
##  the value of <opr> for $S$ is `false'
##  then the value of <opr> for $D$ is also `false'.
#T This is implemented only for the case <super_req> = <opr> and <sub_req>.
##
##  We must be careful to choose the right ranks for the methods.
##  Note that one method may require a property that is acquired using
##  another method.
##  For that, we give a method a rank that is lower than that of all methods 
##  that may yield some of the requirements and that is higher than that of
##  all methods that require <opr>;
##  if this is not possible then a warning is printed.
#T  (Maybe the mechanism has to be changed at some time because of this.
#T  Another reason would be the direct installation of methods for
#T  'UseSubsetRelation', i.e., the ranks of these methods are not affected
#T  by the code in 'InstallSubsetMaintainedMethod'.)
##
InstallSubsetMaintainedMethod := function( operation, super_req, sub_req )

    local setter,
          tester,
          infostring,
          upper,
          lower,
          rank,
          filtssub,       # property and attribute flags of `sub_req'
          filtsopr,       # property and attribute flags of `operation'
          triple,
          req,
          requsub,
          testsub,
          flag,
          filt1,
          filt2;

    setter:= Setter( operation );
    tester:= Tester( operation );
    infostring:= "method for operation ";
    APPEND_LIST_INTR( infostring, NameFunction(operation) );

    # Are there methods that may give us some of the requirements?
    upper:= SUM_FLAGS;
    # We must not call `SUBTR_SET' here because the lists types may be
    # not yet defined.
    # filtssub:= TRUES_FLAGS( FLAGS_FILTER( sub_req ) );
    # SUBTR_SET( filtssub, CATS_AND_REPS );
    filtssub:= [];
    for flag in TRUES_FLAGS( FLAGS_FILTER( sub_req ) ) do
      if not flag in CATS_AND_REPS then
        ADD_LIST_DEFAULT( filtssub, flag );
      fi;
    od;
    for triple in SUBSET_MAINTAINED_INFO do
      req:= SHALLOW_COPY_OBJ( filtssub );
      INTER_SET( req, triple[1] );
      if LEN_LIST( req ) <> 0 and triple[3] < upper then
        upper:= triple[3];
      fi;
    od;

    setter:= Setter( operation );
    # Are there methods that require 'operation'?
    lower:= 0;
    filt1:= FLAGS_FILTER( operation );
    if filt1 = false then
      filt1:= FLAGS_FILTER( Tester( operation ) );
    fi;
    # We must not call `SUBTR_SET' here because the lists types may be
    # not yet defined.
    # filtsopr:= SHALLOW_COPY_OBJ( TRUES_FLAGS( filt1 ) );
    # SUBTR_SET( filtsopr, CATS_AND_REPS );
    filtsopr:= [];
    for flag in TRUES_FLAGS( filt1 ) do
      if not flag in CATS_AND_REPS then
        ADD_LIST_DEFAULT( filtsopr, flag );
      fi;
    od;
    for triple in SUBSET_MAINTAINED_INFO do
      req:= SHALLOW_COPY_OBJ( filtsopr );
      INTER_SET( req, triple[2] );
      if LEN_LIST( req ) <> 0 and lower < triple[3] then
        lower:= triple[3];
      fi;
    od;

    # Compute the rank of the method.
    # (Do we have a cycle?)
    if upper <= lower then
      Print( "#W  warning: cycle in 'InstallSubsetMaintainedMethod'\n" );
      rank:= lower;
    else
      rank:= ( upper + lower ) / 2;
    fi;

    # Update the info list.
    ADD_LIST( SUBSET_MAINTAINED_INFO, [ filtsopr, filtssub, rank ] );

    # Create the requirements for the method.
    # 'super_req' may be taken as a whole,
    # but 'sub_req' must be split into the category/representation part
    # 'requsub' that is required by the method,
    # and the property/attribute part 'testsub' that can be checked only
    # after the method has been called.
    # Note that some of the properties/attributes may be acquired by the
    # object due to some other subset maintained methods, and the method
    # selection of the operation 'UseSubsetRelation' would regard methods
    # that require them as not applicable.
    testsub:= IsObject;
    requsub:= IsObject;
    for flag in TRUES_FLAGS( FLAGS_FILTER( sub_req ) ) do
      if flag in filtssub then
        testsub:= testsub and FILTERS[ flag ];
      else
        requsub:= requsub and FILTERS[ flag ];
      fi;
    od;
    filt1:= IsCollection and Tester( super_req ) and super_req and tester;
    filt2:= IsCollection and Tester( requsub ) and requsub;

    # Adjust 'rank' such that 'INSTALL_METHOD' takes our rank.
    rank:= rank - SIZE_FLAGS(WITH_HIDDEN_IMPS_FLAGS(FLAGS_FILTER( filt1 )));
    rank:= rank - SIZE_FLAGS(WITH_HIDDEN_IMPS_FLAGS(FLAGS_FILTER( filt2 )));

    # Install the method.
    InstallMethod( UseSubsetRelation,
        infostring,
        IsIdentical,
        [ filt1, filt2 ], rank,
        function( super, sub )
        if ( not tester( sub ) ) and testsub( sub ) then
          setter( sub, operation( super ) );
        fi;
#T argument for ``antifilters'' ?
        TryNextMethod();
        end );

    if     FLAGS_FILTER( operation ) <> false
       and IS_EQUAL_FLAGS( FLAGS_FILTER( operation and sub_req ),
                           FLAGS_FILTER( super_req ) )  then
        InstallMethod( UseSubsetRelation, infostring, IsIdentical,
                [ sub_req, sub_req ], 0,
            function( super, sub )
            if tester( sub )  and  not operation( sub )  then
                setter( super, false );
            fi;
            TryNextMethod();
        end );
    fi;
end;


#############################################################################
##
#O  UseIsomorphismRelation( <old>, <new> )
##
##  Methods for this operation deduce possibly useful information from the
##  collection <old> to the isomorphic collection <new>.
##
##  'UseIsomorphismRelation' is called automatically whenever isomorphic
##  structures of domains are constructed.
##  So the methods must be *cheap*, and the requirements should be as
##  sharp as possible!
##
##  To achieve that *all* applicable methods are executed, all methods for
##  this operation except the default method installed below must end with
##  'TryNextMethod()'.
##
UseIsomorphismRelation := NewOperation( "UseIsomorphismRelation",
    [ IsCollection, IsCollection ] );

InstallMethod( UseIsomorphismRelation,
    "default method that returns 'true'",
    true,
    [ IsCollection, IsCollection ], 0,
    function( old, new )
    return true;
    end );


#############################################################################
##
#F  InstallIsomorphismMaintainedMethod( <opr>, <old_req>, <new_req> )
##
##  <opr> must be a property or an attribute.
##  Let $D$ be a domain in the filter <new_req> that is known to be
##  isomorphic to a domain $E$ in the filter <old_req> for that the value of
##  <opr> is known.
##  Then the value of <opr> for $D$ shall be the same as the value for $E$.
##
InstallIsomorphismMaintainedMethod := function( opr, old_req, new_req )
    local setter, tester, infostring;

    setter:= Setter( opr );
    tester:= Tester( opr );
    infostring:= "method for operation ";
    APPEND_LIST_INTR( infostring, NameFunction(opr) );

    InstallMethod( UseIsomorphismRelation,
        infostring,
        true,
        [ IsCollection and Tester( old_req ) and old_req and tester,
          IsCollection and Tester( new_req ) and new_req ], 0,
        function( old, new )
        if not tester( new ) then
          setter( new, opr( old ) );
        fi;
        TryNextMethod();
        end );
end;


#############################################################################
##
#O  UseFactorRelation( <numer>, <denom>, <factor> )
##
##  Methods for this operation deduce possibly useful information from the
##  collection <numer> or its subset <denom> to the collection <factor> that
##  is isomorphic to the factor of <numer> by <denom>, or vice versa.
##
##  'UseFactorRelation' is called automatically whenever factor structures
##  of domains are constructed.
##  So the methods must be *cheap*, and the requirements should be as
##  sharp as possible!
##
##  To achieve that *all* applicable methods are executed, all methods for
##  this operation except the default method installed below must end with
##  'TryNextMethod()'.
##
UseFactorRelation := NewOperation( "UseFactorRelation",
    [ IsCollection, IsCollection, IsCollection ] );

IsIdenticalObjObjX := function( F1, F2, F3 )
    return IsIdentical( F1, F2 );
end;

InstallMethod( UseFactorRelation,
    "default method that returns 'true'",
    IsIdenticalObjObjX,
    [ IsCollection, IsCollection, IsCollection ], 0,
    function( numer, denom, factor )
    return true;
    end );


#############################################################################
##
#F  InstallFactorMaintainedMethod( <opr>, <numer_req>, <denom_req>,
#F                                 <factor_req> )
##
##  <opr> must be a property or an attribute.
##  Let $F$ be a domain in the filter <factor_req> that is known to be
##  the homomorphic image of a domain $D$ in the filter <numer_req> by a
##  domain in the filter <denom_req>,
##  such that the value of <opr> is known for $D$.
##  Then the value of <opr> for $F$ shall be the same as the value for $D$.
##
##  Note that the implications installed by 'InstallFactorMaintainedMethod'
##  can be used in the case of isomorphisms.
##  So they should *not* be installed also as isomorphism maintained methods.
##
InstallFactorMaintainedMethod := function( opr, numer_req, denom_req,
                                           factor_req )
    local setter, tester, infostring;

    InstallIsomorphismMaintainedMethod( opr, numer_req, factor_req );

    setter:= Setter( opr );
    tester:= Tester( opr );
    infostring:= "method for operation ";
    APPEND_LIST_INTR( infostring, NameFunction(opr) );

    InstallMethod( UseFactorRelation,
        infostring,
        IsIdenticalObjObjX,
        [ IsCollection and Tester( numer_req ) and numer_req and tester,
          IsCollection and Tester( denom_req ) and denom_req,
          IsCollection and Tester( factor_req ) and factor_req ], 0,
        function( numer, denom, factor )
        if not tester( factor ) then
          setter( factor, opr( numer ) );
        fi;
        TryNextMethod();
        end );
        
    if     FLAGS_FILTER( opr ) <> false
       and IS_EQUAL_FLAGS( FLAGS_FILTER( opr and factor_req ),
                           FLAGS_FILTER( numer_req ) )  then
        InstallMethod( UseFactorRelation, infostring, IsIdenticalObjObjX,
                [ factor_req, denom_req, factor_req ], 0,
            function( numer, denom, factor )
            if tester( factor )  and  not opr( factor )  then
                setter( numer, false );
            fi;
            TryNextMethod();
        end );
    fi;
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
        IsListOrCollection );
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
#P  IsNonTrivial(<C>) . . . . . . . . . .  test if a collection is nontrivial
##
##  'IsNonTrivial' returns 'true' if the collection <C> is empty or consists
##  of at least two elements.
##  (see "IsTrivial")
##
#N  1996/08/08 M.Schoenert is this a sensible definition?
##
IsNonTrivial :=
    NewProperty( "IsNonTrivial",
        IsCollection );
SetIsNonTrivial := Setter( IsNonTrivial );
HasIsNonTrivial := Tester( IsNonTrivial );
#T I need this to distinguish trivial rings-with-one from fields!
#T (indication to introduce antifilters?)


#############################################################################
##
#P  IsFinite(<C>) . . . . . . . . . . . . . .  test if a collection is finite
##
##  'IsFinite' returns 'true' if the collection <C> is finite, and 'false'
##  otherwise.
##
##  the default method for 'IsFinite' checks the size of <C>.
##
##  Methods for 'IsFinite' may call 'Size',
##  but methods for 'Size' must not call 'IsFinite'.
##
IsFinite :=
    NewProperty( "IsFinite",
        IsCollection );
SetIsFinite := Setter( IsFinite );
HasIsFinite := Tester( IsFinite );

InstallSubsetMaintainedMethod( IsFinite,
    IsCollection and IsFinite, IsCollection );
InstallFactorMaintainedMethod( IsFinite,
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
##  'Size' returns the size of the collection <C>, which is either an integer
##  or 'infinity'.
##  <C> may also be a list, in which case the result is the length of <C>.
##
##  The default method for 'Size' checks the length of an enumerator of <C>.
##
##  Methods for 'IsFinite' may call 'Size',
##  but methods for 'Size' must not call 'IsFinite'.
##
Size :=
    NewAttribute( "Size",
        IsListOrCollection );
SetSize := Setter( Size );
HasSize := Tester( Size );

InstallIsomorphismMaintainedMethod( Size,
    IsCollection, IsCollection );


#############################################################################
##
#A  Representative(<C>) . . . . . . . . . . . . . one element of a collection
##
##  'Representative' returns a representative of the collection <C>.
##
##  Note that 'Representative' is pretty free in choosing a representative if
##  there are several elements in <C>.
##  It is not even guaranteed that 'Representative' returns the same
##  representative if it is called several times for one collection.
##  Thus the main difference between 'Representative' and 'Random'
##  (see "Random") is that 'Representative' is free to choose a value that is
##  cheap to compute, while 'Random' must make an effort to randomly
##  distribute its answers.
##
##  The default method for 'Representative' calls 'Enumerator' and returns an
##  element of this list.
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
##  'Random' returns a random element of the collection <C>.
##  The distribution of elements returned by 'Random' depends on <C>.
##  For finite collections all elements are usually equally likely.
##  For infinite collections some reasonable distribution is used.
##  See the chapters of the various collections to find out which
##  distribution is being used.
##
Random :=
    NewOperation( "Random",
        [ IsListOrCollection ] );


#############################################################################
##
#F  PseudoRandom( <C> ) . . . . . . . . pseudo random element of a collection
##
PseudoRandom := NewOperation(
    "PseudoRandom",
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
##  In  general functions that  return  a set of   elements are free, in fact
##  encouraged, to return a  domain instead  of the  proper set of  elements.
##  For  one  thing this  allows  to  keep the    structure, for  another the
##  representation   by a  domain record is    usually more space  efficient.
##  'Elements' must not do this, its only purpose is to create the proper set
##  of elements.
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
##  For lists this is implemented by 'ListSortedList( <coll> )'.
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
#O  Sum( <C> )  . . . . . . . . . . . . . sum of the elements of a collection
#O  Sum( <C>, <func> )  . . . . . . . . . . .  sum of images under a function
##
##  When used in the first way 'Sum' returns the sum of the elements
##  of the collection <C>.
##  When used in the second way 'Sum' applies the function <func>,
##  which must be a function taking one argument, and returns the sum
##  of the  results.
##  In either case if <C> is empty 'Sum' returns 0.
##
#O  Sum( <C>, <init> )  . . . . . . . . . sum of the elements of a collection
#O  Sum( <C>, <func>, <init> )  . . . . . . .  sum of images under a function
##
##  If an additional initial value <init> is given, 'Sum' returns the
##  sum of <init> and the elements of the collection <C> resp. the
##  sum of the images of these elements under the function <func>.
##  This is useful for example if <C> is empty and a different zero than
##  '0' is desired, in which case <init> is returned.
##
Sum :=
    NewOperation( "Sum",
        [ IsListOrCollection ] );


#############################################################################
##
#O  Product( <C> )  . . . . . . . . . product of the elements of a collection
#O  Product( <C>, <func> )  . . . . . . .  product of images under a function
##
##  When used in the first way 'Product' returns the product of the elements
##  of the collection <C>.
##  When used in the second way 'Product' applies the function <func>,
##  which must be a function taking one argument, and returns the product
##  of the results.
##  In either case if <C> is empty 'Product' returns 1.
##
#O  Product( <C>, <init> )  . . . . . product of the elements of a collection
#O  Product( <C>, <func>, <init> )  . . .  product of images under a function
##
##  If an additional initial value <init> is given, 'Product' returns the
##  product of <init> and the elements of the collection <C> resp. the
##  product of the images of these elements under the function <func>.
##  This is useful for example if <C> is empty and a different identity than
##  '1' is desired, in which case <init> is returned.
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
##  <C2> is considered a subset of <C1> if and only if the set of elements of
##  <C2> is as a set a subset of the set of  elements of <C1> (see "AsList").
##  That is 'IsSubset' behaves as if implemented as
##  'IsSubsetSet( AsList(<C1>), AsList(<C2>) )', except that it will also
##  sometimes, but not always, work for infinite collections,
##  and that it will usually work much faster than the above definition.
##  Either argument may also be a proper set.
##
IsSubset :=
    NewOperation( "IsSubset",
        [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
##
#O  Intersection2(<C1>,<C2>)  . . . . . . . . . . intersection of collections
##
#F  Intersection(<C1>,<C2>...)  . . . . . . . . . intersection of collections
#F  Intersection(<list>)  . . . . . . . . . . . . intersection of collections
##
##  In the first form 'Intersection' returns the intersection of the
##  collections <C1>, <C2>, etc.
##  In the second form <list> must be a list of collections
##  and 'Intersection' returns the intersection of those collections.
##  Each argument or element of <list> respectively may also be an
##  arbitrary list, in which case 'Intersection' silently applies 'Set'
##  (see "Set") to it first.
##  
##  Methods can be installed for the operation 'Intersection2' that allows
##  only two arguments.
##  'Intersection' calls 'Intersection2'.
##
##  Methods for 'Intersection2' should try to keep as much structure as
##  possible.
##  
Intersection2 :=
    NewOperation( "Intersection2",
        [ IsListOrCollection, IsListOrCollection ] );

Intersection :=
    NewOperationArgs( "Intersection" );


#############################################################################
##
#O  Union2(<C1>,<C2>) . . . . . . . . . . . . . . . . .  union of collections
##
#F  Union(<C1>,<C2>...) . . . . . . . . . . . . . . . .  union of collections
#F  Union(<list>) . . . . . . . . . . . . . . . . . . .  union of collections
##
##  In the first form 'Union' returns the union of the
##  collections <C1>, <C2>, etc.
##  In the second form <list> must be a list of collections
##  and 'Union' returns the union of those collections.
##  Each argument or element of <list> respectively may also be an
##  arbitrary list, in which case 'Union' silently applies 'Set'
##  (see "Set") to it first.
##  
##  The result of 'Union' is the set of elements that lie in any of the
##  collections <C1>, <C2>, etc.
##  
##  Methods can be installed for the operation 'Union2' that allows
##  only two arguments.
##  'Union' calls 'Union2'.
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
##  'Difference' returns the set difference of the collections <C1> and <C2>.
##  Either argument may also be an arbitrary list, in which case 'Difference'
##  silently applies 'Set' (see "Set") to it first.
##  
##  The result of 'Difference' is the set of elements that lie in <C1> but
##  not in <C2>.
##  Note that <C2> need not be a subset of <C1>.
##  The elements of <C2>, however, that are not element of <C1> play no role
##  for the result.
##
Difference :=
    NewOperation( "Difference",
        [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#E  coll.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

