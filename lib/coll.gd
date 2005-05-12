#############################################################################
##
#W  coll.gd                     GAP library                  Martin Schoenert
#W                                                            & Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for collections.
##
Revision.coll_gd :=
    "@(#)$Id$";

#T change the installation of isomorphism and factor maintained methods
#T in the same way as that of subset maintained methods!

#1
##  A *collection* in {\GAP} consists of elements in the same family
##  (see~"Families").
##  The most important kinds of collections are *homogeneous lists*
##  (see~"Lists") and *domains* (see~"Domains").
##  Note that a list is never a domain, and a domain is never a list.
##  A list is a collection if and only if it is nonempty and homogeneous.
##
##  Basic operations for collections are `Size' (see~"Size")
##  and `Enumerator' (see~"Enumerator");
##  for *finite* collections, `Enumerator' admits to delegate the other
##  operations for collections
##  (see~"Attributes and Properties for Collections"
##  and~"Operations for Collections")
##  to functions for lists (see~"Lists").
##  Obviously, special methods depending on the arguments are needed for
##  the computation of e.g.~the intersection of two *infinite* domains.
##


#############################################################################
##
#C  IsListOrCollection( <obj> )
##
##  Several functions are defined for both lists and collections,
##  for example `Intersection' (see~"Intersection"), `Iterator'
##  (see~"Iterator"), and `Random' (see~"Random").
##  `IsListOrCollection' is a supercategory of `IsList' and `IsCollection'
##  (that is, all lists and collections lie in this category),
##  which is used to describe the arguments of functions such as the ones
##  listed above.
##
DeclareCategory( "IsListOrCollection", IsObject );


#############################################################################
##
#C  IsCollection( <obj> ) . . . . . . . . . test if an object is a collection
##
##  tests whether an object is a collection.
##
DeclareCategory( "IsCollection", IsListOrCollection );


#############################################################################
##
#A  CollectionsFamily( <Fam> )  . . . . . . . . . . make a collections family
##
##  For a family <Fam>, `CollectionsFamily' returns the family of all
##  collections that consist of elements in <Fam>.
##
##  Note that families (see~"Families") are used to describe relations
##  between objects.
##  Important such relations are that between an element <elm> and each
##  collection of elements that lie in the same family as <elm>,
##  and that between two collections whose elements lie in the same family.
##  Therefore, all collections of elements in the family <Fam> form the new
##  family `CollectionsFamily( <Fam> )'.
##
DeclareAttribute( "CollectionsFamily", IsFamily );


#############################################################################
##
#C  IsCollectionFamily( <Fam> )  test if an object is a family of collections
##
##  is `true' if <Fam> is a family of collections, and `false' otherwise.
##
DeclareCategoryFamily( "IsCollection" );


#############################################################################
##
#A  ElementsFamily( <Fam> ) . . . . . . . . . . . . fetch the elements family
##
##  returns the family from which the collections family <Fam> was created
##  by `CollectionsFamily'.
##  The way a collections family is created, it always has its elements
##  family stored.
##  If <Fam> is not a collections family (see~"IsCollectionFamily")
##  then an error is signalled.
##
DeclareAttribute( "ElementsFamily", IsFamily );


#############################################################################
##
#V  CATEGORIES_COLLECTIONS  . . . . . . global list of collections categories
##
BIND_GLOBAL( "CATEGORIES_COLLECTIONS", [] );


#############################################################################
##
#F  CategoryCollections( <filter> ) . . . . . . . . . .  collections category
##
##  Let <filter> be a filter that is `true' for all elements of a family
##  <Fam>, by construction of <Fam>.
##  Then `CategoryCollections' returns a category that is `true' for all
##  elements in `CollectionsFamily( <Fam> )'.
##
##  For example, the construction of `PermutationsFamily' guarantees that
##  each of its elements lies in the filter `IsPerm',
##  and each collection of permutations lies in the category
##  `CategoryCollections( IsPerm )'.
##
##  Note that this works only if the collections category is created *before*
##  the collections family.
##  So it is necessary to construct interesting collections categories
##  immediately after the underlying category has been created.
##
BIND_GLOBAL( "CategoryCollections", function ( elms_filter )
    local    pair, super, flags, name, coll_filter;

    # Check whether the collections category is already defined.
    for pair in CATEGORIES_COLLECTIONS do
      if IsIdenticalObj( pair[1], elms_filter ) then
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
    coll_filter:= NewCategory( name, super );
    ADD_LIST( CATEGORIES_COLLECTIONS, [ elms_filter, coll_filter ] );
    return coll_filter;
end );


#############################################################################
##
#f  DeclareCategoryCollections( <name> )
##
##  binds the collections category of the category that is bound to the
##  global variable with name <name> to the global variable associated to the
##  name <nname>.
##  If <name> is of the form `<initname>Collection' then <nname> is equal to
##  `<initname>CollColl',
##  if <name> is of the form `<initname>Coll' then <nname> is equal to
##  `<initname>CollColl',
##  otherwise we have <nname> equal to `<name>Collection'.
##
BIND_GLOBAL( "DeclareCategoryCollections", function( name )
    local len, coll_name;

    len:= LEN_LIST( name );
    if    3 < len and name{ [ len-3 .. len ] } = "Coll" then
      coll_name:= SHALLOW_COPY_OBJ( name );
      APPEND_LIST_INTR( coll_name, "Coll" );
    elif 9 < len and name{ [ len-9 .. len ] } = "Collection" then
      coll_name:= name{ [ 1 .. len-6 ] };
      APPEND_LIST_INTR( coll_name, "Coll" );
    else
      coll_name:= SHALLOW_COPY_OBJ( name );
      APPEND_LIST_INTR( coll_name, "Collection" );
    fi;

    BIND_GLOBAL( coll_name, CategoryCollections( VALUE_GLOBAL( name ) ) );
end );


#############################################################################
##
#F  DeclareSynonym( <name>, <value> )
#F  DeclareSynonymAttr( <name>, <value> )
##
#T Why is this in this file?
##

BIND_GLOBAL( "DeclareSynonym", function( name, value )
    BIND_GLOBAL( name, value );
end );

BIND_GLOBAL( "DeclareSynonymAttr", function( name, value )
    local nname;
    BIND_GLOBAL( name, value );
    nname:= "Set";
    APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, Setter( value ) );
    nname:= "Has";
    APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, Tester( value ) );
end );


#############################################################################
##
#V  SUBSET_MAINTAINED_INFO
##
##  is a list of length two.
##  At the first position, a list of lists of the form
##  `[ <filtsuper>, <filtsub>, <opr>, <testopr>, <settopr> ]'
##  is stored,
##  which is used for calls of `UseSubsetRelation( <super>, <sub> )'.
##  At the second position, a corresponding list of lists of the form
##  `[ <flagsopr>, <flagssub>, <rank> ]'
##  is stored, which is used for choosing an appropriate ordering of the
##  entries when the lists are enlarged in a call to
##  `InstallSubsetMaintenance'.
##
##  The meaning of the entries is as follows.
##  \beginitems
##  <filtsuper> &
##      required filter for <super>,
##
##  <filtsub> &
##      required filter for <sub>,
##
##  <opr> &
##      operation whose value is inherited from <super> to <sub>,
##
##  <testopr> &
##      tester filter of <opr>,
##
##  <settopr> &
##      setter filter of <opr>,
##
##  <flagsopr> &
##      list of those true flags of <opr>
##      that belong neither to categories nor to representations,
##
##  <flagssub> &
##      list of those true flags of <filtsub>
##      that belong neither to categories nor to representations,
##
##  <rank> &
##      a rational number that denotes the priority of the information
##      in the list; `SUBSET_MAINTAINED_INFO' is sorted according to
##      decreasing <rank> value.
#T  We must be careful to choose the right succession of the methods.
#T  Note that one method may require a property that is acquired using
#T  another method.
#T  For that, we give a method a rank that is lower than that of all methods
#T  that may yield some of the requirements and that is higher than that of
#T  all methods that require <opr>;
#T  if this is not possible then a warning is printed.
#T  (Maybe the mechanism has to be changed at some time because of this.
#T  Another reason would be the direct installation of methods for
#T  `UseSubsetRelation', i.e., the ranks of these methods are not affected
#T  by the code in `InstallSubsetMaintenance'.)
##  \enditems
##
BIND_GLOBAL( "SUBSET_MAINTAINED_INFO", [ [], [] ] );


#############################################################################
##
#O  UseSubsetRelation( <super>, <sub> )
##
##  Methods for this operation transfer possibly useful information from the
##  domain <super> to its subset <sub>, and vice versa.
##
##  `UseSubsetRelation' is designed to be called automatically
##  whenever substructures of domains are constructed.
##  So the methods must be *cheap*, and the requirements should be as
##  sharp as possible!
##
##  To achieve that *all* applicable methods are executed, all methods for
##  this operation except the default method must end with `TryNextMethod()'.
##  This default method deals with the information that is available by
##  the calls of `InstallSubsetMaintenance' in the {\GAP} library.
##
DeclareOperation( "UseSubsetRelation", [ IsCollection, IsCollection ] );

InstallMethod( UseSubsetRelation,
    "default method that checks maintenances and then returns `true'",
    IsIdenticalObj,
    [ IsCollection, IsCollection ],
    # Make sure that this method is installed with ``real'' rank zero.
    - 2 * RankFilter( IsCollection ),
    function( super, sub )

    local entry;

    for entry in SUBSET_MAINTAINED_INFO[1] do
      if entry[1]( super ) and entry[2]( sub ) and not entry[4]( sub ) then
        entry[5]( sub, entry[3]( super ) );
      fi;
    od;

    return true;
    end );


#############################################################################
##
#F  InstallSubsetMaintenance( <opr>, <super_req>, <sub_req> )
##
##  <opr> must be a property or an attribute.
##  The call of `InstallSubsetMaintenance' has the effect that
##  for a domain <D> in the filter <super_req>, and a domain <S> in the
##  filter <sub_req>,
##  the call `UseSubsetRelation( <D>, <S> )' (see~"UseSubsetRelation")
##  sets a known value of <opr> for <D> as value of <opr> also for <S>.
##  A typical example for which `InstallSubsetMaintenance' is applied
##  is given by `<opr> = IsFinite',
##  `<super_req> = IsCollection and IsFinite',
##  and `<sub_req> = IsCollection'.
##
##  If <opr> is a property and the filter <super_req> lies in the filter
##  <opr> then we can use also the following inverse implication.
##  If $D$ is in the filter whose intersection with <opr> is <super_req>
##  and if $S$ is in the filter <sub_req>, $S$ is a subset of $D$, and
##  the value of <opr> for $S$ is `false'
##  then the value of <opr> for $D$ is also `false'.
#T This is implemented only for the case <super_req> = <opr> and <sub_req>.
##
BIND_GLOBAL( "InstallSubsetMaintenance",
    function( operation, super_req, sub_req )

    local setter,         # setter filter of `operation'
          tester,         # tester filter of `operation'
          upper,
          lower,
          attrprop,       # id `operation' an attribute/property?
          rank,
          filtssub,       # property and attribute flags of `sub_req'
          filtsopr,       # property and attribute flags of `operation'
          triple,         # loop over `SUBSET_MAINTAINED_INFO[2]'
          req,
          flag,
          filt1,
          filt2,
          i;

    setter:= Setter( operation );
    tester:= Tester( operation );

    # Are there methods that may give us some of the requirements?
    upper:= SUM_FLAGS;

    # (We must not call `SUBTR_SET' here because the lists types may be
    # not yet defined.)
    filtssub:= [];
    for flag in TRUES_FLAGS( FLAGS_FILTER( sub_req ) ) do
      if not flag in CATS_AND_REPS then
        ADD_LIST_DEFAULT( filtssub, flag );
      fi;
    od;

    for triple in SUBSET_MAINTAINED_INFO[2] do
      req:= SHALLOW_COPY_OBJ( filtssub );
      INTER_SET( req, triple[1] );
      if LEN_LIST( req ) <> 0 and triple[3] < upper then
        upper:= triple[3];
      fi;
    od;

    # Are there methods that require `operation'?
    lower:= 0;
    attrprop:= true;
    filt1:= FLAGS_FILTER( operation );
    if filt1 = false then

      # `operation' is an attribute.
      filt1:= FLAGS_FILTER( tester );

    else

      # Special treatment of categories, representations (makes sense?),
      # and filters created by `NewFilter'.
      if FLAG2_FILTER( operation ) = 0 then
        attrprop:= false;
      fi;

    fi;

    # (We must not call `SUBTR_SET' here because the lists types may be
    # not yet defined.)
    filtsopr:= [];
    for flag in TRUES_FLAGS( filt1 ) do
      if not flag in CATS_AND_REPS then
        ADD_LIST_DEFAULT( filtsopr, flag );
      fi;
    od;
    for triple in SUBSET_MAINTAINED_INFO[2] do
      req:= SHALLOW_COPY_OBJ( filtsopr );
      INTER_SET( req, triple[2] );
      if LEN_LIST( req ) <> 0 and lower < triple[3] then
        lower:= triple[3];
      fi;
    od;

    # Compute the ``rank'' of the maintenance.
    # (Do we have a cycle?)
    if upper <= lower then
      Print( "#W  warning: cycle in `InstallSubsetMaintenance'\n" );
      rank:= lower;
    else
      rank:= ( upper + lower ) / 2;
    fi;

    filt1:= IsCollection and Tester( super_req ) and super_req and tester;
    filt2:= IsCollection and Tester( sub_req   ) and sub_req;

    # Update the info list.
    i:= LEN_LIST( SUBSET_MAINTAINED_INFO[2] );
    while 0 < i and SUBSET_MAINTAINED_INFO[2][i][3] < rank do
      SUBSET_MAINTAINED_INFO[1][ i+1 ]:= SUBSET_MAINTAINED_INFO[1][ i ];
      SUBSET_MAINTAINED_INFO[2][ i+1 ]:= SUBSET_MAINTAINED_INFO[2][ i ];
      i:= i-1;
    od;
    SUBSET_MAINTAINED_INFO[2][ i+1 ]:= [ filtsopr, filtssub, rank ];
    if attrprop then
      SUBSET_MAINTAINED_INFO[1][ i+1 ]:=
                [ filt1, filt2, operation, tester, setter ];
    else
      SUBSET_MAINTAINED_INFO[1][ i+1 ]:=
                [ filt1, filt2, operation, operation,
                  function( sub, val )
                      SetFeatureObj( sub, operation, val );
                  end ];
    fi;

#T missing in new implementation!
#     # Install the method.
#     if     FLAGS_FILTER( operation ) <> false
#        and IS_EQUAL_FLAGS( FLAGS_FILTER( operation and sub_req ),
#                            FLAGS_FILTER( super_req ) )  then
#         InstallMethod( UseSubsetRelation, infostring, IsIdenticalObj,
#                 [ sub_req, sub_req ], 0,
#             function( super, sub )
#             if tester( sub )  and  not operation( sub )  then
#                 setter( super, false );
#             fi;
#             TryNextMethod();
#         end );
#     fi;
end );


#############################################################################
##
#V  ISOMORPHISM_MAINTAINED_INFO
##
##  is a list of lists of the form
##  `[ <filtsold>, <filtsnew>, <opr>, <testopr>, <settopr>, <old_req>,
##  <new_req> ]'
##  which is used for calls of `UseIsomorphismRelation( <old>, <new> )'.
##  This list is enlarged by calls to `InstallIsomorphismMaintenance'.
##
##  The meaning of the entries is as follows.
##  \beginitems
##  <filtsold> &
##      required filter for <old>,
##
##  <filtsnew> &
##      required filter for <new>,
##
##  <opr> &
##      operation whose value is inherited from <old> to <new>,
##
##  <testopr> &
##      tester filter of <opr>,
##
##  <settopr> &
##      setter filter of <opr>,
##
##  <old_req> &
##      requirements for <old> in the `InstallIsomorphismMaintenance' call,
##
##  <new_req> &
##      requirements for <new> in the `InstallIsomorphismMaintenance' call.
##  \enditems
##
BIND_GLOBAL( "ISOMORPHISM_MAINTAINED_INFO", [] );


#############################################################################
##
#O  UseIsomorphismRelation( <old>, <new> )
##
##  Methods for this operation transfer possibly useful information from the
##  domain <old> to the isomorphic domain <new>.
##
##  `UseIsomorphismRelation' is designed to be called automatically
##  whenever isomorphic structures of domains are constructed.
##  So the methods must be *cheap*, and the requirements should be as
##  sharp as possible!
##
##  To achieve that *all* applicable methods are executed, all methods for
##  this operation except the default method must end with `TryNextMethod()'.
##  This default method deals with the information that is available by
##  the calls of `InstallIsomorphismMaintenance' in the {\GAP} library.
##
DeclareOperation( "UseIsomorphismRelation", [ IsCollection, IsCollection ] );

InstallMethod( UseIsomorphismRelation,
    "default method that checks maintenances and then returns `true'",
    [ IsCollection, IsCollection ],
    # Make sure that this method is installed with ``real'' rank zero.
    - 2 * RankFilter( IsCollection ),
    function( old, new )
    local entry;

    for entry in ISOMORPHISM_MAINTAINED_INFO do
      if entry[1]( old ) and entry[2]( new ) and not entry[4]( new ) then
        entry[5]( new, entry[3]( old ) );
      fi;
    od;

    return true;
    end );


#############################################################################
##
#F  InstallIsomorphismMaintenanceFunction( <func> )
##
##  `InstallIsomorphismMaintenanceFunction' installs <func>, so that
##  `<func>( <filtsold>, <filtsnew>, <opr>, <testopr>, <settopr>, <old_req>,
##  <new_req> )' is called for each isomorphism maintenance.
##  More precisely, <func> is called for each entry in the global list
##  `ISOMORPHISM_MAINTAINED_INFO', also to those that are entered into this
##  list after the installation of <func>.
##  (The mechanism is the same as for attributes, which is installed in the
##  file `lib/oper.g'.)
##
BIND_GLOBAL( "ISOM_MAINT_FUNCS", [] );

BIND_GLOBAL( "InstallIsomorphismMaintenanceFunction", function( func )
    local entry;
    for entry in ISOMORPHISM_MAINTAINED_INFO do
      CallFuncList( func, entry );
    od;
    ADD_LIST( ISOM_MAINT_FUNCS, func );
end );

BIND_GLOBAL( "RUN_ISOM_MAINT_FUNCS",
    function( arglist )
    local func;
    for func in ISOM_MAINT_FUNCS do
      CallFuncList( func, arglist );
    od;
    ADD_LIST( ISOMORPHISM_MAINTAINED_INFO, arglist );
end );


#############################################################################
##
#F  InstallIsomorphismMaintenance( <opr>, <old_req>, <new_req> )
##
##  <opr> must be a property or an attribute.
##  The call of `InstallIsomorphismMaintenance' has the effect that
##  for a domain <D> in the filter <old_req>, and a domain <E> in the
##  filter <new_req>,
##  the call `UseIsomorphismRelation( <D>, <E> )'
##  (see~"UseIsomorphismRelation")
##  sets a known value of <opr> for <D> as value of <opr> also for <E>.
##  A typical example for which `InstallIsomorphismMaintenance' is
##  applied is given by `<opr> = Size',
##  `<old_req> = IsCollection', and `<new_req> = IsCollection'.
#T Up to now, there are no dependencies between the maintenances
#T (contrary to the case of subset maintenances),
#T so we do not take care of the succession.
##
BIND_GLOBAL( "InstallIsomorphismMaintenance",
    function( opr, old_req, new_req )
    local tester;

    tester:= Tester( opr );

    RUN_ISOM_MAINT_FUNCS(
        [ IsCollection and Tester( old_req ) and old_req and tester,
          IsCollection and Tester( new_req ) and new_req,
          opr,
          tester,
          Setter( opr ),
          old_req,
          new_req ] );
end );


#############################################################################
##
#V  FACTOR_MAINTAINED_INFO
##
##  is a list of lists of the form
##  `[ <filtsnum>, <filtsden>, <filtsfac>, <opr>, <testopr>, <settopr> ]'
##  which is used for calls of `UseFactorRelation( <num>, <den>, <fac> )'.
##  This list is enlarged by calls to `InstallFactorMaintenance'.
##
##  The meaning of the entries is as follows.
##  \beginitems
##  <filtsnum> &
##      required filter for <num>,
##
##  <filtsden> &
##      required filter for <den>,
##
##  <filtsfac> &
##      required filter for <fac>,
##
##  <opr> &
##      operation whose value is inherited from <num> to <fac>,
##
##  <testopr> &
##      tester filter of <opr>,
##
##  <settopr> &
##      setter filter of <opr>.
##  \enditems
##
BIND_GLOBAL( "FACTOR_MAINTAINED_INFO", [] );


#############################################################################
##
#O  UseFactorRelation( <numer>, <denom>, <factor> )
##
##  Methods for this operation transfer possibly useful information from the
##  domain <numer> or its subset <denom> to the domain <factor> that
##  is isomorphic to the factor of <numer> by <denom>, and vice versa.
##  <denom> may be `fail', for example if <factor> is just known to be a
##  factor of <numer> but <denom> is not available as a {\GAP} object;
##  in this case those factor relations are used that are installed without
##  special requirements for <denom>.
##
##  `UseFactorRelation' is designed to be called automatically
##  whenever factor structures of domains are constructed.
##  So the methods must be *cheap*, and the requirements should be as
##  sharp as possible!
##
##  To achieve that *all* applicable methods are executed, all methods for
##  this operation except the default method must end with `TryNextMethod()'.
##  This default method deals with the information that is available by
##  the calls of `InstallFactorMaintenance' in the {\GAP} library.
##
DeclareOperation( "UseFactorRelation",
    [ IsCollection, IsObject, IsCollection ] );

IsIdenticalObjObjObjX := function( F1, F2, F3 )
    return IsIdenticalObj( F1, F2 );
end;

InstallMethod( UseFactorRelation,
    "default method that checks maintenances and then returns `true'",
    true,
    [ IsCollection, IsObject, IsCollection ],
    # Make sure that this method is installed with ``real'' rank zero.
    - 2 * RankFilter( IsCollection )-RankFilter(IsObject),
    function( num, den, fac )

    local entry;

    for entry in FACTOR_MAINTAINED_INFO do
      if entry[1]( num ) and entry[2]( den ) and entry[3]( fac )
                         and not entry[5]( fac ) then
        entry[6]( fac, entry[4]( num ) );
      fi;
    od;

    return true;
    end );


#############################################################################
##
#F  InstallFactorMaintenance( <opr>, <numer_req>, <denom_req>, <factor_req> )
##
##  <opr> must be a property or an attribute.
##  The call of `InstallFactorMaintenance' has the effect that
##  for collections <N>, <D>, <F> in the filters <numer_req>, <denom_req>,
##  and <factor_req>, respectively,
##  the call `UseFactorRelation( <N>, <D>, <F> )'
##  (see~"UseFactorRelation")
##  sets a known value of <opr> for <N> as value of <opr> also for <F>.
##  A typical example for which `InstallFactorMaintenance' is
##  applied is given by `<opr> = IsFinite',
##  `<numer_req> = IsCollection and IsFinite', `<denom_req> = IsCollection',
##  and `<factor_req> = IsCollection'.
##
##  For the other direction, if <numer_req> involves the filter <opr>
##  then a known `false' value of <opr> for $F$ implies a `false'
##  value for $D$ provided that $D$ lies in the filter obtained from
##  <numer_req> by removing <opr>.
##
##  Note that an implication of a factor relation holds in particular for the
##  case of isomorphisms.
##  So one need *not* install an isomorphism maintained method when
##  a factor maintained method is already installed.
##  For example, `UseIsomorphismRelation' (see~"UseIsomorphismRelation")
##  will transfer a known `IsFinite' value because of the installed factor
##  maintained method.
##
BIND_GLOBAL( "InstallFactorMaintenance",
    function( opr, numer_req, denom_req, factor_req )

    local tester;

    # Information that is maintained under taking factors
    # is especially maintained under isomorphisms.
    InstallIsomorphismMaintenance( opr, numer_req, factor_req );

    tester:= Tester( opr );

    ADD_LIST( FACTOR_MAINTAINED_INFO,
        [ IsCollection and Tester( numer_req ) and numer_req and tester,
          Tester( denom_req ) and denom_req,
          IsCollection and Tester( factor_req ) and factor_req,
          opr,
          tester,
          Setter( opr ) ] );

#T not yet available in the new implementation
#     if     FLAGS_FILTER( opr ) <> false
#        and IS_EQUAL_FLAGS( FLAGS_FILTER( opr and factor_req ),
#                            FLAGS_FILTER( numer_req ) )  then
#         InstallMethod( UseFactorRelation, infostring, IsIdenticalObjObjObjX,
#                 [ factor_req, denom_req, factor_req ], 0,
#             function( numer, denom, factor )
#             if tester( factor )  and  not opr( factor )  then
#                 setter( numer, false );
#             fi;
#             TryNextMethod();
#         end );
#     fi;
end );


#############################################################################
##
#O  Iterator( <C> ) . . . . . . . . . . . . iterator for a list or collection
#O  Iterator( <list> )  . . . . . . . . . . iterator for a list or collection
##
##  Iterators provide a possibility to loop over the elements of a
##  (countable) collection <C> or a list <list>, without repetition.
##  For many collections <C>,
##  an iterator of <C> need not store all elements of <C>,
##  for example it is possible to construct an iterator of some infinite
##  domains, such as the field of rational numbers.
##
##  `Iterator' returns a mutable *iterator* <iter> for its argument.
##  If this is a list <list> (which may contain holes),
##  then <iter> iterates over the elements (but not the holes) of <list> in
##  the same order (see~"IteratorList" for details).
##  If this is a collection <C> but not a list then <iter> iterates over the
##  elements of <C> in an unspecified order,
##  which may change for repeated calls of `Iterator'.
##  Because iterators returned by `Iterator' are mutable
##  (see~"Mutability and Copyability"),
##  each call of `Iterator' for the same argument returns a *new* iterator.
##  Therefore `Iterator' is not an attribute (see~"Attributes").
##
##  The only operations for iterators are `IsDoneIterator',
##  `NextIterator', and `ShallowCopy'.
##  In particular, it is only possible to access the next element of the
##  iterator with `NextIterator' if there is one, and this can be checked
##  with `IsDoneIterator' (see~"NextIterator").
##  For an iterator <iter>, `ShallowCopy( <iter> )' is a mutable iterator
##  <new> that iterates over the remaining elements independent of <iter>;
##  the results of `IsDoneIterator' for <iter> and <new> are equal,
##  and if <iter> is mutable then also the results of `NextIterator' for
##  <iter> and <new> are equal;
##  note that `=' is not defined for iterators,
##  so the equality of two iterators cannot be checked with `='.
##
##  When `Iterator' is called for a *mutable* collection <C> then it is not
##  defined whether <iter> respects changes to <C> occurring after the
##  construction of <iter>, except if the documentation explicitly promises
##  a certain behaviour.  The latter is the case if the argument is a mutable
##  list <list> (see~"IteratorList" for subtleties in this case).
##
##  It is possible to have `for'-loops run over mutable iterators instead of
##  lists.
##
##  In some situations, one can construct iterators with a special
##  succession of elements,
##  see~"IteratorByBasis" for the possibility to loop over the elements
##  of a vector space w.r.t.~a given basis.
#T (also for perm. groups, w.r.t. a given stabilizer chain?)
##
##  For lists, `Iterator' is implemented by `IteratorList( <list> )'.
##  For collections that are not lists, the default method is
##  `IteratorList( Enumerator( <C> ) )'.
##  Better methods depending on <C> should be provided if possible.
##
##  For random access to the elements of a (possibly infinite) collection,
##  *enumerators* are used.
##  See~"Enumerators" for the facility to compute a list from <C>,
##  which provides a (partial) mapping from <C> to the positive integers.
##
#T  We wanted to admit an iterator as first argument of `Filtered',
#T  `First', `ForAll', `ForAny', `Number'.
#T  This is not yet implemented.
#T  (Note that the iterator is changed in the call,
#T  so the meaning of the operations would be slightly abused,
#T  or we must define that these operations first make a shallow copy.)
#T  (Additionally, the unspecified order of the elements makes it
#T  difficult to define what `First' and `Filtered' means for an iterator.)
##
DeclareOperation( "Iterator", [ IsListOrCollection ] );


#############################################################################
##
#O  IteratorSorted( <C> ) . . . . . . . . . . . set iterator for a collection
#O  IteratorSorted( <list> )  . . . . . . . . . . . . set iterator for a list
##
##  `IteratorSorted' returns a mutable iterator.
##  The argument must be a collection <C> or a list <list> that is not
##  necessarily dense but whose elements lie in the same family
##  (see~"Families").
##  It loops over the different elements in sorted order.
##
##  For collections <C> that are not lists, the generic method is
##  `IteratorList( EnumeratorSorted( <C> ) )'.
##
DeclareOperation( "IteratorSorted", [ IsListOrCollection ] );


#############################################################################
##
#C  IsIterator( <obj> ) . . . . . . . . . .  test if an object is an iterator
##
##  Every iterator lies in the category `IsIterator'.
##
DeclareCategory( "IsIterator", IsObject );


#############################################################################
##
#O  IsDoneIterator( <iter> )  . . . . . . .  test if an iterator is exhausted
##
##  If <iter> is an iterator for the list or collection $C$ then
##  `IsDoneIterator( <iter> )' is `true' if all elements of $C$ have been
##  returned already by `NextIterator( <iter> )', and `false' otherwise.
##
DeclareOperation( "IsDoneIterator", [ IsIterator ] );


#############################################################################
##
#O  NextIterator( <iter> )  . . . . . . . . . . next element from an iterator
##
##  Let <iter> be a mutable iterator for the list or collection $C$.
##  If `IsDoneIterator( <iter> )' is `false' then `NextIterator' is
##  applicable to <iter>, and the result is the next element of $C$,
##  according to the succession defined by <iter>.
##
##  If `IsDoneIterator( <iter> )' is `true' then it is not defined what
##  happens if `NextIterator' is called for <iter>;
##  that is, it may happen that an error is signalled or that something
##  meaningless is returned, or even that {\GAP} crashes.
##
DeclareOperation( "NextIterator", [ IsIterator and IsMutable ] );


#############################################################################
##
#F  TrivialIterator( <elm> )
##
##  is a mutable iterator for the collection `[ <elm> ]' that consists of
##  exactly one element <elm> (see~"IsTrivial").
##
DeclareGlobalFunction( "TrivialIterator" );


#############################################################################
##
#F  IteratorByFunctions( <record> )
##
##  `IteratorByFunctions' returns a (mutable) iterator <iter> for which
##  `NextIterator', `IsDoneIterator', and `ShallowCopy'
##  are computed via prescribed functions.
##
##  Let <record> be a record with at least the following components.
##  \beginitems
##  `NextIterator' &
##      a function taking one argument <iter>,
##      which returns the next element of <iter> (see~"NextIterator");
##      for that, the components of <iter> are changed,
##
##  `IsDoneIterator' &
##      a function taking one argument <iter>,
##      which returns `IsDoneIterator( <iter> )' (see~"IsDoneIterator");
##
##  `ShallowCopy' &
##      a function taking one argument <iter>,
##      which returns a record for which `IteratorByFunctions' can be called
##      in order to create a new iterator that is independent of <iter> but
##      behaves like <iter> w.r.t. the operations `NextIterator' and
##      `IsDoneIterator'.
##  \enditems
##  Further (data) components may be contained in <record> which can be used
##  by these function.
##
##  `IteratorByFunctions' does *not* make a shallow copy of <record>,
##  this record is changed in place
##  (see~"prg:Creating Objects" in ``Programming in {\GAP}'').
##
DeclareGlobalFunction( "IteratorByFunctions" );


#############################################################################
##
#P  IsEmpty( <C> )  . . . . . . . . . . . . . . test if a collection is empty
#P  IsEmpty( <list> ) . . . . . . . . . . . . . test if a collection is empty
##
##  `IsEmpty' returns `true' if the collection <C> resp.~the list <list> is
##  *empty* (that is it contains no elements), and `false' otherwise.
##
DeclareProperty( "IsEmpty", IsListOrCollection );


#############################################################################
##
#P  IsTrivial( <C> )  . . . . . . . . . . . . test if a collection is trivial
##
##  `IsTrivial' returns `true' if the collection <C>  consists of exactly one
##  element.
##
#T  1996/08/08 M.Schoenert is this a sensible definition?
##
DeclareProperty( "IsTrivial", IsCollection );

InstallFactorMaintenance( IsTrivial,
    IsCollection and IsTrivial, IsObject, IsCollection );


#############################################################################
##
#P  IsNonTrivial( <C> ) . . . . . . . . .  test if a collection is nontrivial
##
##  `IsNonTrivial' returns `true' if the collection <C> is empty or consists
##  of at least two elements (see~"IsTrivial").
##
#T I need this to distinguish trivial rings-with-one from fields!
#T (indication to introduce antifilters?)
#T  1996/08/08 M.Schoenert is this a sensible definition?
##
DeclareProperty( "IsNonTrivial", IsCollection );


#############################################################################
##
#P  IsFinite( <C> ) . . . . . . . . . . . . .  test if a collection is finite
##
##  `IsFinite' returns `true' if the collection <C> is finite, and `false'
##  otherwise.
##
##  The default method for `IsFinite' checks the size (see~"Size") of <C>.
##
##  Methods for `IsFinite' may call `Size',
##  but methods for `Size' must *not* call `IsFinite'.
##
DeclareProperty( "IsFinite", IsCollection );

InstallSubsetMaintenance( IsFinite,
    IsCollection and IsFinite, IsCollection );
InstallFactorMaintenance( IsFinite,
    IsCollection and IsFinite, IsObject, IsCollection );

InstallTrueMethod( IsFinite, IsTrivial );


#############################################################################
##
#P  IsWholeFamily( <C> )  . .  test if a collection contains the whole family
##
##  `IsWholeFamily' returns `true' if the collection <C> contains the whole
##  family (see~"Families") of its elements.
##
DeclareProperty( "IsWholeFamily", IsCollection );


#############################################################################
##
#A  Size( <C> ) . . . . . . . . . . . . . . . . . . . .  size of a collection
#A  Size( <list> )  . . . . . . . . . . . . . . . . . .  size of a collection
##
##  `Size' returns the size of the collection <C>, which is either an integer
##  or `infinity'.
##  The argument may also be a list <list>, in which case the result is the
##  length of <list> (see~"Length").
##
##  The default method for `Size' checks the length of an enumerator of <C>.
##
##  Methods for `IsFinite' may call `Size',
##  but methods for `Size' must not call `IsFinite'.
##
DeclareAttribute( "Size", IsListOrCollection );

InstallIsomorphismMaintenance( Size, IsCollection, IsCollection );


#############################################################################
##
#A  Representative( <C> ) . . . . . . . . . . . . one element of a collection
##
##  `Representative' returns a *representative* of the collection <C>.
##
##  Note that `Representative' is free in choosing a representative if
##  there are several elements in <C>.
##  It is not even guaranteed that `Representative' returns the same
##  representative if it is called several times for one collection.
##  The main difference between `Representative' and `Random'
##  (see~"Random") is that `Representative' is free to choose a value that is
##  cheap to compute,
##  while `Random' must make an effort to randomly distribute its answers.
##
##  If <C> is a domain then there are methods for `Representative' that try
##  to fetch an element from any known generator list of <C>,
##  see~"Domains and their Elements".
##  Note that `Representative' does not try to *compute* generators of <C>,
##  thus `Representative' may give up and signal an error if <C> has no
##  generators stored at all.
##
DeclareAttribute( "Representative", IsListOrCollection );


#############################################################################
##
#A  RepresentativeSmallest( <C> ) . . . . .  smallest element of a collection
##
##  returns the smallest element in the collection <C>, w.r.t.~the ordering
##  `\<'.
##  While the operation defaults to comparing all elements,
##  better methods are installed for some collections.
##
DeclareAttribute( "RepresentativeSmallest", IsListOrCollection );


#############################################################################
##
#O  Random( <C> ) . . . . . . . . . .  random element of a list or collection
#O  Random( <list> )  . . . . . . . .  random element of a list or collection
##
##  `Random' returns a (pseudo-)random element of the collection <C>
##  respectively the list <list>.
##
##  The distribution of elements returned by `Random' depends on the
##  argument.  For a list <list>, all elements are equally likely.  The same
##  holds usually for finite collections <C> that are not lists.  For
##  infinite collections <C> some reasonable distribution is used.
##
##  See the chapters of the various collections to find out
##  which distribution is being used.
##
##  For some collections ensuring a reasonable distribution can be
##  difficult and require substantial runtime.
##  If speed at the cost of equal distribution is desired,
##  the operation `PseudoRandom' should be used instead.
##
##  Note that `Random' is of course *not* an attribute.
##
DeclareOperation( "Random", [ IsListOrCollection ] );

##
#2
##  The method used by {\GAP} to obtain random elements may depend on the
##  type object.
##
##  Many random methods in the library are eventually based on the function
##  `RandomList'. As `RandomList' is restricted to lists of up to $2^{28}$
##  elements, this may create problems for very large collections. Also note
##  that the method used by `RandomList' is intended to provide a fast
##  algorithm rather than to produce high quality randomness for
##  statistical purposes.
##
##  If you implement your own `Random' methods we recommend
##  that they initialize their seed to a defined value when they are loaded
##  to permit to reproduce calculations even if they involved random
##  elements.

#############################################################################
##
#F  RandomList( <list> )
##
##  \index{random seed}
##  For a dense list <list> of up to $2^{28}$ elements,
##  `RandomList' returns a (pseudo-)random element with equal distribution.
##
##  The algorithm used is an additive number generator (Algorithm A in
##  section~3.2.2 of \cite{TACP2} with lag 30)
##
##  This random number generator is (deliberately) initialized to the same
##  values when {\GAP} is started, so different runs of {\GAP} with the same
##  input will always produce the same result, even if random calculations
##  are involved.
##
##  See `StateRandom' for a description on how to reset the random number
##  generator to a previous state.
##
DeclareSynonym( "RandomList", RANDOM_LIST);

#############################################################################
##
#F  StateRandom()
#F  RestoreStateRandom(<obj>)
##
##  For debugging purposes, it can be desirable to reset the random number
##  generator to a state it had before. `StateRandom' returns a {\GAP}
##  object that represents the current state of the random number generator
##  used by `RandomList'.
##
##  By calling `RestoreStateRandom' with this object as argument, the
##  random number is reset to this same state.
##
##  (The same result can be obtained by accessing the two global variables
##  `R_N' and `R_X'.)
##
##  (The format of the object used to represent the random generator seed
##  is not guaranteed to be stable betweed different machines or versions
##  of {\GAP}.
##
DeclareGlobalFunction( "StateRandom" );
DeclareGlobalFunction( "RestoreStateRandom" );

# older documentation referred to `StatusRandom'. 
DeclareSynonym("StatusRandom",StateRandom);

#############################################################################
##
#O  PseudoRandom( <C> ) . . . . . . . . pseudo random element of a collection
#O  PseudoRandom( <list> )  . . . . . . . . . pseudo random element of a list
##
##  `PseudoRandom' returns a pseudo random element of the collection <C>
##  respectively the list <list>, which can be roughly described as follows.
##  For a list <list>, `PseudoRandom' returns the same as `Random'.
##  For collections <C> that are not lists,
##  the elements returned by `PseudoRandom' are *not* necessarily equally
##  distributed, even for finite collections <C>;
##  the idea is that `Random' (see~"Random") returns elements according to
##  a reasonable distribution, `PseudoRandom' returns elements that are
##  cheap to compute but need not satisfy this strong condition, and
##  `Representative' (see~"Representative") returns arbitrary elements,
##  probably the same element for each call.
##
DeclareOperation( "PseudoRandom", [ IsListOrCollection ] );


#############################################################################
##
#A  PseudoRandomSeed( <C> )
##
DeclareAttribute( "PseudoRandomSeed", IsListOrCollection, "mutable" );


#############################################################################
##
#A  Enumerator( <C> ) . . . . . . . . . . .  list of elements of a collection
#A  Enumerator( <list> )  . . . . . . . . . . . .  list of elements of a list
##
##  `Enumerator' returns an immutable list <enum>.
##  If the argument is a list <list> (which may contain holes),
##  then `Length( <enum> )' is `Length( <list> )',
##  and <enum> contains the elements (and holes) of <list> in the same order.
##  If the argument is a collection <C> that is not a list,
##  then `Length( <enum> )' is the number of different elements of <C>,
##  and <enum> contains the different elements of <C> in an unspecified
##  order, which may change for repeated calls of `Enumerator'.
##  `<enum>[<pos>]' may not execute in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <enum> in memory is as small as is feasible.
##
##  For lists <list>, the default method is `Immutable'.
##  For collections <C> that are not lists, there is no default method.
##
DeclareAttribute( "Enumerator", IsListOrCollection );


#############################################################################
##
#A  EnumeratorSorted( <C> ) . . . . .  proper set of elements of a collection
#A  EnumeratorSorted( <list> )  . . . . . .  proper set of elements of a list
##
##  `EnumeratorSorted' returns an immutable list <enum>.
##  The argument must be a collection <C> or a list <list> which may contain
##  holes but whose elements lie in the same family (see~"Families").
##  `Length( <enum> )' is the number of different elements of
##  <C> resp.~<list>,
##  and <enum> contains the different elements in sorted order, w.r.t.~`\<'.
##  `<enum>[<pos>]' may not execute in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <enum> in memory is as small as is feasible.
##
DeclareAttribute( "EnumeratorSorted", IsListOrCollection );


#############################################################################
##
#F  EnumeratorOfSubset( <list>, <blist>[, <ishomog>] )
##
##  Let <list> be a list, and <blist> a Boolean list of the same length
##  (see~"Boolean Lists").
##  `EnumeratorOfSubset' returns a list <new> of length equal to the number
##  of `true' entries in <blist>,
##  such that `<new>[i]', if bound, equals the entry of <list> at the <i>-th
##  `true' position in <blist>.
##
##  If <list> is homogeneous then also <new> is homogeneous.
##  If <list> is *not* homogeneous then the third argument <ishomog> must
##  be present and equal to `true' or `false', saying whether or not <new> is
##  homogeneous.
##
##  This construction is used for example in the situation that <list> is an
##  enumerator of a large set, and <blist> describes a union of orbits in an
##  action on this set.
##
DeclareGlobalFunction( "EnumeratorOfSubset" );


#############################################################################
##
#F  EnumeratorByFunctions( <D>, <record> )
#F  EnumeratorByFunctions( <Fam>, <record> )
##
##  `EnumeratorByFunctions' returns an immutable, dense, and duplicate-free
##  list <enum> for which `IsBound', element access, `Length', and `Position'
##  are computed via prescribed functions.
##
##  Let <record> be a record with at least the following components.
##  \beginitems
##  `ElementNumber' &
##      a function taking two arguments <enum> and <pos>,
##      which returns `<enum>[ <pos> ]' (see~"Basic Operations for Lists");
##      it can be assumed that the argument <pos> is a positive integer,
##      but <pos> may be larger than the length of <enum> (in which case
##      an error must be signalled);
##      note that the result must be immutable since <enum> itself is
##      immutable,
##
##  `NumberElement' &
##      a function taking two arguments <enum> and <elm>,
##      which returns `Position( <enum>, <elm> )' (see~"Position");
##      it cannot be assumed that <elm> is really contained in <enum>
##      (and `fail' must be returned if not);
##      note that for the three argument version of `Position', the
##      method that is available for duplicate-free lists suffices.
##  \enditems
##  Further (data) components may be contained in <record> which can be used
##  by these function.
##
##  If the first argument is a domain <D> then <enum> lists the elements of
##  <D> (in general <enum> is *not* sorted),
##  and methods for `Length', `IsBound', and `PrintObj' may use <D>.
#T is this really true for `Length'?
##
##  If one wants to describe the result without creating a domain then the
##  elements are given implicitly by the functions in <record>,
##  and the first argument must be a family <Fam> which will become the
##  family of <enum>;
##  if <enum> is not homogeneous then <Fam> must be `ListsFamily',
##  otherwise it must be the collections family of any element in <enum>.
##  In this case, additionally the following component in <record> is
##  needed.
##  \beginitems
##  `Length' &
##      a function taking the argument <enum>,
##      which returns the length of <enum> (see~"Length").
##  \enditems
##
##  The following components are optional; they are used if they are present
##  but default methods are installed for the case that they are missing.
##  \beginitems
##  `IsBound\\[\\]' &
##      a function taking two arguments <enum> and <k>,
##      which returns `IsBound( <enum>[ <k> ] )'
##      (see~"Basic Operations for Lists");
##      if this component is missing then `Length' is used for computing the
##      result,
##
##  `Membership' &
##      a function taking two arguments <elm> and <enum>,
##      which returns `true' is <elm> is an element of <enum>,
##      and `false' otherwise (see~"Basic Operations for Lists");
##      if this component is missing then `NumberElement' is used
##      for computing the result,
##
##  `AsList' &
##      a function taking one argument <enum>, which returns a list with the
##      property that the access to each of its elements will take roughly
##      the same time (see~"IsConstantTimeAccessList");
##      if this component is missing then `ConstantTimeAccessList' is used
##      for computing the result,
##
##  `ViewObj' and `PrintObj' &
##      two functions that print what one wants to be printed when
##      `View( <enum> )' or `Print( <enum> )' is called
##      (see~"View and Print"),
##      if the `ViewObj' component is missing then the `PrintObj' method is
##      used as a default.
##  \enditems
##
##  If the result is known to have additional properties such as being
##  strictly sorted (see~"IsSSortedList") then it can be useful to set
##  these properties after the construction of the enumerator,
##  before it is used for the first time.
##  And in the case that a new sorted enumerator of a domain is implemented
##  via `EnumeratorByFunctions', and this construction is installed as a
##  method for the operation `Enumerator' (see~"Enumerator"),
##  then it should be installed also as a method for `EnumeratorSorted'
##  (see~"EnumeratorSorted").
##
##  Note that it is *not* checked that `EnumeratorByFunctions' really returns
##  a dense and duplicate-free list.
##  `EnumeratorByFunctions' does *not* make a shallow copy of <record>,
##  this record is changed in place
##  (see~"prg:Creating Objects" in ``Programming in {\GAP}'').
##
##  It would be easy to implement a slightly generalized setup for
##  enumerators that need not be duplicate-free (where the three argument
##  version of `Position' is supported),
##  but the resulting overhead for the methods seems not to be justified.
##
DeclareGlobalFunction( "EnumeratorByFunctions" );


#############################################################################
##
#A  UnderlyingCollection( <enum> )
##
##  An enumerator of a domain can delegate the task to compute its length to
##  `Size' for the underlying domain, and `ViewObj' and `PrintObj' methods
##  may refer to this domain.
##
DeclareAttribute( "UnderlyingCollection", IsListOrCollection );


#############################################################################
##
#F  List( <list> )  . . . . . . . . . . . .  list of elements of a collection
#F  List( <C> )
#F  List( <list>, <func> )
##
##  In the first form, where <list> is a list (not necessarily dense or
##  homogeneous), `List' returns a new mutable list <new> that contains
##  the elements (and the holes) of <list> in the same order;
##  thus `List' does the same as `ShallowCopy' (see~"ShallowCopy")
##  in this case.
##
##  In the second form, where <C> is a collection (see~"Collections")
##  that is not a list,
##  `List' returns a new mutable list <new> such that `Length( <new> )'
##  is the number of different elements of <C>, and <new> contains the
##  different elements of <C> in an unspecified order which may change
##  for repeated calls.
##  `<new>[<pos>]' executes in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <new> is proportional to its length.
##  The generic method for this case is `ShallowCopy( Enumerator( <C> ) )'.
#T this is not reasonable since `ShallowCopy' need not guarantee to return
#T a constant time access list
##
##  In the third form, for a dense list <list> and a function <func>,
##  which must take exactly one argument, `List' returns a new mutable list
##  <new> given by $<new>[i] = <func>( <list>[i] )$.
##
DeclareGlobalFunction( "List" );

DeclareOperation( "ListOp", [ IsListOrCollection ] );
DeclareOperation( "ListOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  SortedList( <C> )
#O  SortedList( <list> )
##
##  `SortedList' returns a new mutable and dense list <new>.
##  The argument must be a collection <C> or a list <list> which may contain
##  holes but whose elements lie in the same family (see~"Families").
##  `Length( <new> )' is the number of elements of <C> resp.~<list>,
##  and <new> contains the elements in sorted order, w.r.t.~`\<='.
##  `<new>[<pos>]' executes in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <new> in memory is proportional to its length.
##
DeclareOperation( "SortedList", [ IsListOrCollection ] );


#############################################################################
##
#O  SSortedList( <C> )  . . . . . . . . . . . set of elements of a collection
#O  SSortedList( <list> ) . . . . . . . . . . . . . set of elements of a list
#O  Set( <C> )
##
##  `SSortedList' (``strictly sorted list'') returns a new dense, mutable,
##  and duplicate free list <new>.
##  The argument must be a collection <C> or a list <list> which may contain
##  holes but whose elements lie in the same family (see~"Families").
##  `Length( <new> )' is the number of different elements of <C>
##  resp.~<list>,
##  and <new> contains the different elements in strictly sorted order,
##  w.r.t.~`\<'.
##  `<new>[<pos>]' executes in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <new> in memory is proportional to its length.
##
##  `Set' is simply a synonym for `SSortedList'.
##
#T  For collections that are not lists, the default method is
#T  `ShallowCopy( EnumeratorSorted( <C> ) )'.
##
DeclareOperation( "SSortedList", [ IsListOrCollection ] );
DeclareSynonym( "Set", SSortedList );


#############################################################################
##
#A  AsList( <C> ) . . . . . . . . . . . . .  list of elements of a collection
#A  AsList( <list> )  . . . . . . . . . . . . . .  list of elements of a list
##
##  `AsList' returns a immutable list <imm>.
##  If the argument is a list <list> (which may contain holes),
##  then `Length( <imm> )' is `Length( <list> )',
##  and <imm> contains the elements (and holes) of <list> in the same order.
##  If the argument is a collection <C> that is not a list,
##  then `Length( <imm> )' is the number of different elements of <C>,
##  and <imm> contains the different elements of <C> in an unspecified
##  order, which may change for repeated calls of `AsList'.
##  `<imm>[<pos>]' executes in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <imm> in memory is proportional to its length.
##
##  If you expect to do many element tests in the resulting list, it might
##  be worth to use a sorted list instead, using `AsSSortedList'.
##
#T  For both lists and collections, the default method is
#T  `ConstantTimeAccessList( Enumerator( <C> ) )'.
##
DeclareAttribute( "AsList", IsListOrCollection );


#############################################################################
##
#A  AsSortedList( <C> )
#A  AsSortedList( <list> )
##
##  `AsSortedList' returns a dense and immutable list <imm>.
##  The argument must be a collection <C> or a list <list> which may contain
##  holes but whose elements lie in the same family (see~"Families").
##  `Length( <imm> )' is the number of elements of <C> resp.~<list>,
##  and <imm> contains the elements in sorted order, w.r.t.~`\<='.
##  `<new>[<pos>]' executes in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <imm> in memory is proportional to its length.
##
##  The only difference to the operation `SortedList' (see~"SortedList")
##  is that `AsSortedList' returns an *immutable* list.
##
DeclareAttribute( "AsSortedList", IsListOrCollection );


#############################################################################
##
#A  AsSSortedList( <C> )  . . . . . . . . . . set of elements of a collection
#A  AsSSortedList( <list> ) . . . . . . . . . . . . set of elements of a list
#A  AsSet( <C> )
##
##  `AsSSortedList' (``as strictly sorted list'') returns a dense, immutable,
##  and duplicate free list <imm>.
##  The argument must be a collection <C> or a list <list> which may contain
##  holes but whose elements lie in the same family (see~"Families").
##  `Length( <imm> )' is the number of different elements of <C>
##  resp.~<list>,
##  and <imm> contains the different elements in strictly sorted order,
##  w.r.t.~`\<'.
##  `<imm>[<pos>]' executes in constant time
##  (see~"IsConstantTimeAccessList"),
##  and the size of <imm> in memory is proportional to its length.
##
##  Because the comparisons required for sorting can be very expensive for
##  some kinds of objects, you should use `AsList' instead if you do not
##  require the result to be sorted.
##
##  The only difference to the operation `SSortedList' (see~"SSortedList")
##  is that `AsSSortedList' returns an *immutable* list.
##
##  `AsSet' is simply a synonym for `AsSSortedList'.
##
##  In general a function that returns a set of elements is free, in fact
##  encouraged, to return a domain instead of the proper set of its elements.
##  This allows one to keep a given structure, and moreover the
##  representation by a domain object is usually more space efficient.
##  `AsSSortedList' must of course *not* do this,
##  its only purpose is to create the proper set of elements.
##
#T  For both lists and collections, the default method is
#T  `ConstantTimeAccessList( EnumeratorSorted( <C> ) )'.
##
DeclareAttribute( "AsSSortedList", IsListOrCollection );
DeclareSynonym( "AsSet", AsSSortedList );

#############################################################################
##
#A  AsSSortedListNonstored( <C> )
##
##  returns the `AsSSortedList(<C>)' but ensures that this list (nor a
##  permutation or substantial subset) will not be
##  stored in attributes of <C> unless such a list is already stored.
##  This permits to obtain an element list once
##  without danger of clogging up memory in the long run.
##
##  Because of this guarantee of nonstorage, methods for
##  `AsSSortedListNonstored' may not default to `AsSSortedList', but only
##  vice versa.
##
DeclareOperation( "AsSSortedListNonstored", [IsListOrCollection] );


#############################################################################
##
#F  Elements( <C> )
##
##  `Elements' does the same as `AsSSortedList' (see~"AsSSortedList"),
##  that is, the return value is a strictly sorted list of the elements in
##  the list or collection <C>.
##
##  `Elements' is only supported for backwards compatibility.
##  In many situations, the sortedness of the ``element list'' for a
##  collection is in fact not needed, and one can save a lot of time by
##  asking for a list that is *not* necessarily sorted, using `AsList'
##  (see~"AsList").
##  If one is really interested in the strictly sorted list of elements in
##  <C> then one should use `AsSet' or `AsSSortedList' instead.
##
DeclareGlobalFunction( "Elements" );


#############################################################################
##
#F  Sum( <list>[, <init>] ) . . . . . . . . . . sum of the elements of a list
#F  Sum( <C>[, <init>] )  . . . . . . . . sum of the elements of a collection
#F  Sum( <list>, <func>[, <init>] ) . . . . .  sum of images under a function
#F  Sum( <C>, <func>[, <init>] )  . . . . . .  sum of images under a function
##
##  In the first two forms `Sum' returns the sum of the elements of the
##  dense list <list> resp.~the collection <C> (see~"Collections").
##  In the last two forms `Sum' applies the function <func>,
##  which must be a function taking one argument,
##  to the elements of the dense list <list> resp.~the collection <C>,
##  and returns the sum of the results.
##  In either case `Sum' returns `0' if the first argument is empty.
##
##  The general rules for arithmetic operations apply
##  (see~"Mutability Status and List Arithmetic"),
##  so the result is immutable if and only if all summands are immutable.
##
##  If <list> or <C> contains exactly one element then this element (or its
##  image under <func> if applicable) itself is returned, not a shallow copy
##  of this element.
##
##  If an additional initial value <init> is given,
##  `Sum' returns the sum of <init> and the elements of the first argument
##  resp.~of their images under the function <func>.
##  This is useful for example if the first argument is empty and a different
##  zero than `0' is desired, in which case <init> is returned.
##
DeclareGlobalFunction( "Sum" );


#############################################################################
##
#O  SumOp( <C> )
#O  SumOp( <C>, <func> )
#O  SumOp( <C>, <init> )
#O  SumOp( <C>, <func>, <init> )
##
##  `SumOp' is the operation called by `Sum' if <C> is not an internal list.
##
DeclareOperation( "SumOp", [ IsListOrCollection ] );


#############################################################################
##
#F  Product( <list>[, <init>] ) . . . . . . product of the elements of a list
#F  Product( <C>[, <init>] )  . . . . product of the elements of a collection
#F  Product( <list>, <func>[, <init>] ) .  product of images under a function
#F  Product( <C>, <func>[, <init>] )  . .  product of images under a function
##
##  In the first two forms `Product' returns the product of the elements of
##  the dense list <list> resp.~the collection <C> (see~"Collections").
##  In the last two forms `Product' applies the function <func>,
##  which must be a function taking one argument,
##  to the elements of the dense list <list> resp.~the collection <C>,
##  and returns the product of the results.
##  In either case `Product' returns `1' if the first argument is empty.
##
##  The general rules for arithmetic operations apply
##  (see~"Mutability Status and List Arithmetic"),
##  so the result is immutable if and only if all summands are immutable.
##
##  If <list> or <C> contains exactly one element then this element (or its
##  image under <func> if applicable) itself is returned, not a shallow copy
##  of this element.
##
##  If an additional initial value <init> is given,
##  `Product' returns the product of <init> and the elements of the first
##  argument resp.~of their images under the function <func>.
##  This is useful for example if the first argument is empty and a different
##  identity than `1' is desired, in which case <init> is returned.
##
DeclareGlobalFunction( "Product" );


#############################################################################
##
#O  ProductOp( <C> )
#O  ProductOp( <C>, <func> )
#O  ProductOp( <C>, <init> )
#O  ProductOp( <C>, <func>, <init> )
##
##  `ProductOp' is the operation called by `Product' if <C> is not
##  an internal list.
##
DeclareOperation( "ProductOp", [ IsListOrCollection ] );


#############################################################################
##
#F  Filtered( <list>, <func> )  . . . . extract elements that have a property
#F  Filtered( <C>, <func> ) . . . . . . extract elements that have a property
##
##  returns a new list that contains those elements of the list <list> or
##  collection <C> (see~"Collections"), respectively,
##  for which the unary function <func> returns `true'.
##
##  If the first argument is a list, the order of the elements in the result
##  is the same as the order of the corresponding elements of <list>.
##  If an element for which <func> returns `true' appears several times in
##  <list> it will also appear the same number of times in the result.
##  <list> may contain holes, they are ignored by `Filtered'.
##
##  For each element of <list> resp.~<C>, <func> must return either `true' or
##  `false', otherwise an error is signalled.
##
##  The result is a new list that is not identical to any other list.
##  The elements of that list however are identical to the corresponding
##  elements of the argument list (see~"Identical Lists").
##
##  List assignment using the operator `{}' (see~"List Assignment") can be
##  used to extract elements of a list according to indices given in another
##  list.
##
DeclareGlobalFunction( "Filtered" );


#############################################################################
##
#O  FilteredOp( <C>, <func> )
##
##  `FilteredOp' is the operation called by `Filtered' if <C> is not
##  an internal list.
##
DeclareOperation( "FilteredOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#F  Number( <list> )
#F  Number( <list>, <func> )  . . . . . . count elements that have a property
#F  Number( <C>, <func> ) . . . . . . . . count elements that have a property
##
##  In the first form, `Number' returns the number of bound entries in the
##  list <list>.
##  For dense lists `Number', `Length' (see~"Length"),
##  and `Size' (see~"Size") return the same value;
##  for lists with holes `Number' returns the number of bound entries,
##  `Length' returns the largest index of a bound entry,
##  and `Size' signals an error.
##
##  In the last two forms, `Number' returns the number of elements of the
##  list <list> resp.~the collection <C> for which the unary function <func>
##  returns `true'.
##  If an element for which <func> returns `true' appears several times in
##  <list> it will also be counted the same number of times.
##
##  For each element of <list> resp.~<C>, <func> must return either `true' or
##  `false', otherwise an error is signalled.
##
##  `Filtered' (see~"Filtered") allows you to extract the elements of a list
##  that have a certain property.
##
DeclareGlobalFunction( "Number" );


#############################################################################
##
#O  NumberOp( <C>, <func> )
##
##  `NumberOp' is the operation called by `Number' if <C> is not
##  an internal list.
##
DeclareOperation( "NumberOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#F  ForAll( <list>, <func> )
#F  ForAll( <C>, <func> )
##
##  tests whether the unary function <func> returns `true' for all elements
##  in the list <list> resp.~the collection <C>.
##
DeclareGlobalFunction( "ForAll" );


#############################################################################
##
#O  ForAllOp( <C>, <func> )
##
##  `ForAllOp' is the operation called by `ForAll' if <C> is not
##  an internal list.
##
DeclareOperation( "ForAllOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#F  ForAny( <list>, <func> )
#F  ForAny( <C>, <func> )
##
##  tests whether the unary function <func> returns `true' for at least one
##  element in the list <list> resp.~the collection <C>.
##
DeclareGlobalFunction( "ForAny" );


#############################################################################
##
#O  ForAnyOp( <C>, <func> )
##
##  `ForAnyOp' is the operation called by `ForAny' if <C> is not
##  an internal list.
##
DeclareOperation( "ForAnyOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  ListX( <arg1>, <arg2>, ... <argn>, <func> )
##
##  `ListX' returns a new list constructed from the arguments.
##
##  Each of the arguments `<arg1>, <arg2>, ... <argn>' must be one of the
##  following:
##  \beginitems
##  a list or collection &
##      this introduces a new for-loop in the sequence of nested
##      for-loops and if-statements;
##
##  a function returning a list or collection &
##      this introduces a new for-loop in the sequence of nested
##      for-loops and if-statements, where the loop-range depends on
##      the values of the outer loop-variables; or
##
##  a function returning `true' or `false' &
##      this introduces a new if-statement in the sequence of nested
##      for-loops and if-statements.
##  \enditems
##
##  The last argument <func> must be a function,
##  it is applied to the values of the loop-variables
##  and the results are collected.
##
##  Thus `ListX( <list>, <func> )' is the same as `List( <list>, <func> )',
##  and `ListX( <list>, <func>, x -> x )' is the same as
##  `Filtered( <list>, <func> )'.
##
##  As a more elaborate example, assume <arg1> is a list or collection,
##  <arg2> is a function returning `true' or `false',
##  <arg3> is a function returning a list or collection, and
##  <arg4> is another function returning `true' or `false',
##  then
##
##  \)\kernttindent<result> := ListX( <arg1>, <arg2>, <arg3>, <arg4>, <func> );
##
##  is equivalent to
##
##  \){\kernttindent}<result> := [];
##  \){\kernttindent}for v1 in <arg1> do
##  \){\kernttindent\quad}if <arg2>( v1 ) then
##  \){\kernttindent\quad\quad}for v2 in <arg3>( v1 ) do
##  \){\kernttindent\quad\quad\quad}if <arg4>( v1, v2 ) then
##  \){\kernttindent\quad\quad\quad\quad}Add( <result>, <func>( v1, v2 ) );
##  \){\kernttindent\quad\quad\quad}fi;
##  \){\kernttindent\quad\quad}od;
##  \){\kernttindent\quad}fi;
##  \){\kernttindent}od;
##
##  \goodbreak%
##  The following example shows how `ListX' can be used to compute all pairs
##  and all strictly sorted pairs of elements in a list.
##  \beginexample
##  gap> l:= [ 1, 2, 3, 4 ];;
##  gap> pair:= function( x, y ) return [ x, y ]; end;;
##  gap> ListX( l, l, pair );
##  [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], 
##    [ 2, 4 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ], [ 4, 1 ], [ 4, 2 ], 
##    [ 4, 3 ], [ 4, 4 ] ]
##  \endexample
##  In the following example, `\<' is the comparison operation:
##  \beginexample
##  gap> ListX( l, l, \<, pair );
##  [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ]
##  \endexample
##
DeclareGlobalFunction( "ListX" );


#############################################################################
##
#O  SetX( <arg1>, <arg2>, ... <func> )
##
##  The only difference between `SetX' and `ListX' is that the result list of
##  `SetX' is strictly sorted.
##
DeclareGlobalFunction( "SetX" );


#############################################################################
##
#O  SumX( <arg1>, <arg2>, ... <func> )
##
##  `SumX' returns the sum of the elements in the list obtained by
##  `ListX' when this is called with the same arguments.
##
DeclareGlobalFunction( "SumX" );


#############################################################################
##
#O  ProductX( <arg1>, <arg2>, ... <func> )
##
##  `ProductX' returns the product of the elements in the list obtained by
##  `ListX' when this is called with the same arguments.
##
DeclareGlobalFunction( "ProductX" );

#############################################################################
##
#O  Perform( <list>, <func>)
##
##  `Perform( <list>, <func> )' applies func to every element of
##  <list>, discarding any return values. It does not return a value.
##

DeclareGlobalFunction( "Perform" );

#############################################################################
##
#O  IsSubset( <C1>, <C2> )  . . . . . . . . .  test for subset of collections
##
##  `IsSubset' returns `true' if <C2>, which must be a collection, is a
##  *subset* of <C1>, which also must be a collection, and `false' otherwise.
##
##  <C2> is considered a subset of <C1> if and only if each element of <C2>
##  is also an element of <C1>.
##  That is `IsSubset' behaves as if implemented as
##  `IsSubsetSet( AsSSortedList( <C1> ), AsSSortedList( <C2> ) )',
##  except that it will also sometimes, but not always,
##  work for infinite collections,
##  and that it will usually work much faster than the above definition.
##  Either argument may also be a proper set (see~"Sorted Lists and Sets").
##
DeclareOperation( "IsSubset", [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#F  Intersection( <C1>, <C2> ... )  . . . . . . . intersection of collections
#F  Intersection( <list> )  . . . . . . . . . . . intersection of collections
#O  Intersection2( <C1>, <C2> ) . . . . . . . . . intersection of collections
##
##  In the first form `Intersection' returns the intersection of the
##  collections <C1>, <C2>, etc.
##  In the second form <list> must be a *nonempty* list of collections
##  and `Intersection' returns the intersection of those collections.
##  Each argument or element of <list> respectively may also be a
##  homogeneous list that is not a proper set,
##  in which case `Intersection' silently applies `Set' (see~"Set") to it
##  first.
##
##  The result of `Intersection' is the set of elements that lie in every of
##  the collections <C1>, <C2>, etc.
##  If the result is a list then it is mutable and new, i.e., not identical
##  to any of <C1>, <C2>, etc.
##
##  Methods can be installed for the operation `Intersection2' that takes
##  only two arguments.
##  `Intersection' calls `Intersection2'.
##
##  Methods for `Intersection2' should try to maintain as much structure as
##  possible, for example the intersection of two permutation groups is
##  again a permutation group.
##
DeclareGlobalFunction( "Intersection" );

DeclareOperation( "Intersection2",
    [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#F  Union( <C1>, <C2> ... ) . . . . . . . . . . . . . .  union of collections
#F  Union( <list> ) . . . . . . . . . . . . . . . . . .  union of collections
#O  Union2( <C1>, <C2> )  . . . . . . . . . . . . . . .  union of collections
##
##  In the first form `Union' returns the union of the
##  collections <C1>, <C2>, etc.
##  In the second form <list> must be a list of collections
##  and `Union' returns the union of those collections.
##  Each argument or element of <list> respectively may also be a
##  homogeneous list that is not a proper set,
##  in which case `Union' silently applies `Set' (see~"Set") to it first.
##
##  The result of `Union' is the set of elements that lie in any of the
##  collections <C1>, <C2>, etc.
##  If the result is a list then it is mutable and new, i.e., not identical
##  to any of <C1>, <C2>, etc.
##
##  Methods can be installed for the operation `Union2' that takes only two
##  arguments.
##  `Union' calls `Union2'.
##
DeclareGlobalFunction( "Union" );

DeclareOperation( "Union2", [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#O  Difference( <C1>, <C2> )  . . . . . . . . . . . difference of collections
##
##  `Difference' returns the set difference of the collections <C1> and <C2>.
##  Either argument may also be a homogeneous list that is not a proper set,
##  in which case `Difference' silently applies `Set' (see~"Set") to it
##  first.
##
##  The result of `Difference' is the set of elements that lie in <C1> but
##  not in <C2>.
##  Note that <C2> need not be a subset of <C1>.
##  The elements of <C2>, however, that are not elements of <C1> play no role
##  for the result.
##  If the result is a list then it is mutable and new, i.e., not identical
##  to <C1> or <C2>.
##
DeclareOperation( "Difference", [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#P  CanEasilyCompareElements( <obj> )
#F  CanEasilyCompareElementsFamily( <fam> )
#P  CanEasilySortElements( <obj> )
#F  CanEasilySortElementsFamily( <fam> )
##
##  `CanEasilyCompareElements' indicates whether the elements in the family
##  <fam> of <obj> can be easily compared with `='.
##  (In some cases element comparisons are very hard, for example in cases
##  where no normal forms for the elements exist.)
##
##  The default method for this property is to ask the family of <obj>,
##  the default method for the family is to return `false'.
##
##  The ability to compare elements may depend on the successful computation
##  of certain information. (For example for finitely presented groups it
##  might depend on the knowledge of a faithful permutation representation.)
##  This information might change over time and thus it might not be a good
##  idea to store a value `false' too early in a family. Instead the
##  function `CanEasilyCompareElementsFamily' should be called for the
##  family of <obj> which returns `false' if the value of
##  `CanEasilyCompareElements' is not known for the family without computing
##  it. (This is in fact what the above mentioned family dispatch does.)
##
##  If a family knows ab initio that it can compare elements this property
##  should be set as implied filter *and* filter for the family (the 3rd and
##  4th argument of `NewFamily' respectively). This guarantees that code
##  which directly asks the family gets a right answer.
##
##  The property `CanEasilySortElements' and the function
##  `CanEasilySortElementsFamily' behave exactly in the same way, except
##  that they indicate that objects can be compared via `\<'. This property
##  implies `CanEasilyCompareElements', as the ordering must be total.
##
DeclareProperty( "CanEasilyCompareElements", IsObject );
DeclareGlobalFunction( "CanEasilyCompareElementsFamily" );
DeclareProperty( "CanEasilySortElements", IsObject );
DeclareGlobalFunction( "CanEasilySortElementsFamily" );

InstallTrueMethod(CanEasilyCompareElements,CanEasilySortElements);


#############################################################################
##
#O  CanComputeIsSubset( <A>, <B> )
##
##  This filter indicates that {\GAP} can test (via `IsSubset') whether <B>
##  is a subset of <A>.
DeclareOperation( "CanComputeIsSubset", [IsObject,IsObject] );


#############################################################################
##
#F  CanComputeSize( <dom> )
##
##  This filter indicates whether the size of the domain <dom> (which might
##  be `infinity') can be computed.
DeclareFilter( "CanComputeSize" );

InstallTrueMethod( CanComputeSize, HasSize );


#############################################################################
##
#E

