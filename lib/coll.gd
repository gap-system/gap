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
##  This file declares the operations for collections.
##

#T change the installation of isomorphism and factor maintained methods
#T in the same way as that of subset maintained methods!


#############################################################################
##
##  <#GAPDoc Label="[1]{coll}">
##  A <E>collection</E> in &GAP; consists of elements in the same family
##  (see&nbsp;<Ref Sect="Families"/>).
##  The most important kinds of collections are <E>homogeneous lists</E>
##  (see&nbsp;<Ref Chap="Lists"/>)
##  and <E>domains</E> (see&nbsp;<Ref Chap="Domains"/>).
##  Note that a list is never a domain, and a domain is never a list.
##  A list is a collection if and only if it is nonempty and homogeneous.
##  <P/>
##  Basic operations for collections are <Ref Attr="Size"/>
##  and <Ref Attr="Enumerator"/>;
##  for <E>finite</E> collections,
##  <Ref Attr="Enumerator"/> admits to delegate the other
##  operations for collections
##  (see&nbsp;<Ref Sect="Attributes and Properties for Collections"/>
##  and&nbsp;<Ref Sect="Operations for Collections"/>)
##  to functions for lists (see&nbsp;<Ref Chap="Lists"/>).
##  Obviously, special methods depending on the arguments are needed for
##  the computation of e.g.&nbsp;the intersection of two <E>infinite</E>
##  domains.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsListOrCollection( <obj> )
##
##  <#GAPDoc Label="IsListOrCollection">
##  <ManSection>
##  <Filt Name="IsListOrCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  Several functions are defined for both lists and collections,
##  for example <Ref Func="Intersection" Label="for a list"/>,
##  <Ref Oper="Iterator"/>,
##  and <Ref Oper="Random" Label="for a list or collection"/>.
##  <Ref Filt="IsListOrCollection"/> is a supercategory of
##  <Ref Filt="IsList"/> and <Ref Filt="IsCollection"/>
##  (that is, all lists and collections lie in this category),
##  which is used to describe the arguments of functions such as the ones
##  listed above.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsListOrCollection", IsObject );


#############################################################################
##
#C  IsCollection( <obj> ) . . . . . . . . . test if an object is a collection
##
##  <#GAPDoc Label="IsCollection">
##  <ManSection>
##  <Filt Name="IsCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  tests whether an object is a collection.
##  <P/>
##  Some of the functions for lists and collections are described in the
##  chapter about lists,
##  mainly in Section&nbsp;<Ref Sect="Operations for Lists"/>.
##  In the current chapter, we describe those functions for which the
##  <Q>collection aspect</Q> seems to be more important than the
##  <Q>list aspect</Q>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsCollection", IsListOrCollection );


#############################################################################
##
#A  CollectionsFamily( <Fam> )  . . . . . . . . . . make a collections family
##
##  <#GAPDoc Label="CollectionsFamily">
##  <ManSection>
##  <Attr Name="CollectionsFamily" Arg='Fam'/>
##
##  <Description>
##  For a family <A>Fam</A>, <Ref Attr="CollectionsFamily"/> returns the
##  family of all collections over <A>Fam</A>,
##  that is, of all dense lists and domains that consist of objects in
##  <A>Fam</A>.
##  <P/>
##  The <Ref Func="NewFamily"/> call in the standard method of
##  <Ref Attr="CollectionsFamily"/> is executed with second argument
##  <Ref Filt="IsCollection"/>,
##  since every object in the collections family must be a collection,
##  and with third argument the collections categories of the involved
##  categories in the implied filter of <A>Fam</A>.
##  <P/>
##  Note that families (see&nbsp;<Ref Sect="Families"/>)
##  are used to describe relations between objects.
##  Important such relations are that between an element <M>e</M> and each
##  collection of elements that lie in the same family as <M>e</M>,
##  and that between two collections whose elements lie in the same family.
##  Therefore, all collections of elements in the family <A>Fam</A> form the
##  new family <C>CollectionsFamily( <A>Fam</A> )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CollectionsFamily", IsFamily );


#############################################################################
##
#C  IsCollectionFamily( <Fam> )  test if an object is a family of collections
##
##  <#GAPDoc Label="IsCollectionFamily">
##  <ManSection>
##  <Filt Name="IsCollectionFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  is <K>true</K> if <A>Fam</A> is a family of collections,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryFamily( "IsCollection" );


#############################################################################
##
#A  ElementsFamily( <Fam> ) . . . . . . . . . . . . fetch the elements family
##
##  <#GAPDoc Label="ElementsFamily">
##  <ManSection>
##  <Attr Name="ElementsFamily" Arg='Fam'/>
##
##  <Description>
##  If <A>Fam</A> is a collections family
##  (see&nbsp;<Ref Filt="IsCollectionFamily"/>)
##  then <Ref Attr="ElementsFamily"/>
##  returns the family from which <A>Fam</A> was created
##  by <Ref Attr="CollectionsFamily"/>.
##  The way a collections family is created, it always has its elements
##  family stored.
##  If <A>Fam</A> is not a collections family then an error is signalled.
##  <P/>
##  <Example><![CDATA[
##  gap> fam:= FamilyObj( (1,2) );;
##  gap> collfam:= CollectionsFamily( fam );;
##  gap> fam = collfam;  fam = ElementsFamily( collfam );
##  false
##  true
##  gap> collfam = FamilyObj( [ (1,2,3) ] );
##  true
##  gap> collfam = FamilyObj( Group( () ) );
##  true
##  gap> collfam = CollectionsFamily( collfam );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ElementsFamily", IsFamily );


#############################################################################
##
#V  CATEGORIES_COLLECTIONS  . . . . . . global list of collections categories
##
##  <ManSection>
##  <Var Name="CATEGORIES_COLLECTIONS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "CATEGORIES_COLLECTIONS", [] );
if IsHPCGAP then
  ShareSpecialObj(CATEGORIES_COLLECTIONS, "CATEGORIES_COLLECTIONS");
fi;


#############################################################################
##
#F  CategoryCollections( <filter> ) . . . . . . . . . .  collections category
##
##  <#GAPDoc Label="CategoryCollections">
##  <ManSection>
##  <Func Name="CategoryCollections" Arg='filter'/>
##
##  <Description>
##  Let <A>filter</A> be a filter that is <K>true</K> for all elements of a
##  family <A>Fam</A>, by the construction of <A>Fam</A>.
##  Then <Ref Func="CategoryCollections"/> returns the
##  <E>collections category</E> of <A>filter</A>.
##  This is a category that is <K>true</K> for all elements in
##  <C>CollectionsFamily( <A>Fam</A> )</C>.
##  <P/>
##  For example, the construction of
##  <Ref Fam="PermutationsFamily"/> guarantees that
##  each of its elements lies in the filter
##  <Ref Filt="IsPerm"/>,
##  and each collection of permutations (permutation group or dense list of
##  permutations) lies in the category <C>CategoryCollections( IsPerm )</C>.
##  <C>CategoryCollections( IsPerm )</C>.
##  Note that this works only if the collections category is created
##  <E>before</E> the collections family.
##  So it is necessary to construct interesting collections categories
##  immediately after the underlying category has been created.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "CategoryCollections", function ( elms_filter )
    local    pair, super, flags, name, coll_filter, len;

    # check once with read lock -- common case
    atomic readonly CATEGORIES_COLLECTIONS do
    # Check whether the collections category is already defined.
    for pair in CATEGORIES_COLLECTIONS do
      if IsIdenticalObj( pair[1], elms_filter ) then
        return pair[2];
      fi;
    od;
    if IsHPCGAP then
      len := LENGTH(CATEGORIES_COLLECTIONS);
    fi;
    od; # end atomic

    # that failed, so get exclusive lock as we may need to modify
    atomic readwrite CATEGORIES_COLLECTIONS do
    if IsHPCGAP then
      # Check whether in the meantime another thread defined the collections category
      if LENGTH(CATEGORIES_COLLECTIONS) > len then
        for pair in CATEGORIES_COLLECTIONS do
          if IsIdenticalObj( pair[1], elms_filter ) then
            return pair[2];
          fi;
        od;
      fi;
    fi;

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
    ADD_LIST( CATEGORIES_COLLECTIONS, MakeImmutable([ elms_filter, coll_filter ]) );
    return coll_filter;
    od; # end atomic
end );


#############################################################################
##
#f  DeclareCategoryCollections( <name> )
##
##  <#GAPDoc Label="DeclareCategoryCollections">
##  <ManSection>
##  <Func Name="DeclareCategoryCollections" Arg='name'/>
##
##  <Description>
##  Calls <Ref Func="CategoryCollections"/> on the category that is bound to
##  the global variable with name <A>name</A> to obtain its collections
##  category, and binds the latter to the global variable with name
##  <C>nname</C>. This name is defined as follows: If <A>name</A> is of the
##  form <C><A>Something</A>Collection</C> then <C>nname</C> is set to
##  <C><A>Something</A>CollColl</C>, if <A>name</A> is of the form
##  <C><A>Something</A>Coll</C> then <C>nname</C> is set to
##  <C><A>Something</A>CollColl</C>, otherwise we set <C>nname</C> to
##  <C><A>name</A>Collection</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NameOfCategoryCollections", function( name )
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
    return coll_name;
end );

BIND_GLOBAL( "DeclareCategoryCollections", function( name )
    local coll_name;
    coll_name := NameOfCategoryCollections( name );
    BIND_GLOBAL( coll_name, CategoryCollections( VALUE_GLOBAL( name ) ) );
end );


#############################################################################
##
#F  DeclareSynonym( <name>, <value> )
#F  DeclareSynonymAttr( <name>, <value> )
##
##  <#GAPDoc Label="DeclareSynonym">
##  <ManSection>
##  <Func Name="DeclareSynonym" Arg='name, value'/>
##  <Func Name="DeclareSynonymAttr" Arg='name, value'/>
##
##  <Description>
##  <Ref Func="DeclareSynonym"/> assigns the string <A>name</A> to a global
##  variable as a synonym for <A>value</A>.
##  Two typical intended usages are to declare an <Q>and-filter</Q>, e.g.
##  <P/>
##  <Log><![CDATA[
##  DeclareSynonym( "IsGroup", IsMagmaWithInverses and IsAssociative );
##  ]]></Log>
##  <P/>
##  and to provide a previously declared global function with an alternative
##  name, e.g.
##  <P/>
##  <Log><![CDATA[
##  DeclareGlobalFunction( "SizeOfSomething" );
##  DeclareSynonym( "OrderOfSomething", SizeOfSomething );
##  ]]></Log>
##  <P/>
##  <E>Note:</E> Before using <Ref Func="DeclareSynonym"/> in the way of this
##  second example,
##  one should determine whether the synonym is really needed.
##  Perhaps an extra index entry in the documentation would be sufficient.
##  <P/>
##  When <A>value</A> is actually an attribute then
##  <Ref Func="DeclareSynonymAttr"/> should be used;
##  this binds also globals variables <C>Set</C><A>name</A> and
##  <C>Has</C><A>name</A> for its setter and tester, respectively.
##  <P/>
##  <Log><![CDATA[
##  DeclareSynonymAttr( "IsField", IsDivisionRing and IsCommutative );
##  DeclareAttribute( "GeneratorsOfDivisionRing", IsDivisionRing );
##  DeclareSynonymAttr( "GeneratorsOfField", GeneratorsOfDivisionRing );
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareSynonym", function( name, value )
    if ISBOUND_GLOBAL(name) and IS_IDENTICAL_OBJ(VALUE_GLOBAL(name), value) then
        if not REREADING then
            INFO_DEBUG( 1, "multiple declarations for synonym `", name, "'\n" );
        fi;
    else
        BIND_GLOBAL( name, value );
    fi;
end );

BIND_GLOBAL( "DeclareSynonymAttr", function( name, value )
    local nname;
    DeclareSynonym( name, value );
    nname:= "Set";
    APPEND_LIST_INTR( nname, name );
    DeclareSynonym( nname, Setter( value ) );
    nname:= "Has";
    APPEND_LIST_INTR( nname, name );
    DeclareSynonym( nname, Tester( value ) );
end );


#############################################################################
##
#V  SUBSET_MAINTAINED_INFO
##
##  <ManSection>
##  <Var Name="SUBSET_MAINTAINED_INFO"/>
##
##  <Description>
##  is a list of length two.
##  At the first position, a list of lists of the form
##  <C>[ <A>filtsuper</A>, <A>filtsub</A>, <A>opr</A>, <A>testopr</A>, <A>settopr</A> ]</C>
##  is stored,
##  which is used for calls of <C>UseSubsetRelation( <A>super</A>, <A>sub</A> )</C>.
##  At the second position, a corresponding list of lists of the form
##  <C>[ <A>flagsopr</A>, <A>flagssub</A>, <A>rank</A> ]</C>
##  is stored, which is used for choosing an appropriate ordering of the
##  entries when the lists are enlarged in a call to
##  <C>InstallSubsetMaintenance</C>.
##  <P/>
##  The meaning of the entries is as follows.
##  <List>
##  <Mark><A>filtsuper</A> </Mark>
##  <Item>
##      required filter for <A>super</A>,
##  </Item>
##  <Mark><A>filtsub</A> </Mark>
##  <Item>
##      required filter for <A>sub</A>,
##  </Item>
##  <Mark><A>opr</A> </Mark>
##  <Item>
##      operation whose value is inherited from <A>super</A> to <A>sub</A>,
##  </Item>
##  <Mark><A>testopr</A> </Mark>
##  <Item>
##      tester filter of <A>opr</A>,
##  </Item>
##  <Mark><A>settopr</A> </Mark>
##  <Item>
##      setter filter of <A>opr</A>,
##  </Item>
##  <Mark><A>flagsopr</A> </Mark>
##  <Item>
##      list of those true flags of <A>opr</A>
##      that belong neither to categories nor to representations,
##  </Item>
##  <Mark><A>flagssub</A> </Mark>
##  <Item>
##      list of those true flags of <A>filtsub</A>
##      that belong neither to categories nor to representations,
##  </Item>
##  <Mark><A>rank</A> </Mark>
##  <Item>
##      a rational number that denotes the priority of the information
##      in the list; <C>SUBSET_MAINTAINED_INFO</C> is sorted according to
##      decreasing <A>rank</A> value.
##  <!--  We must be careful to choose the right succession of the methods.-->
##  <!--  Note that one method may require a property that is acquired using-->
##  <!--  another method.-->
##  <!--  For that, we give a method a rank that is lower than that of all methods-->
##  <!--  that may yield some of the requirements and that is higher than that of-->
##  <!--  all methods that require <A>opr</A>;-->
##  <!--  if this is not possible then a warning is printed.-->
##  <!--  (Maybe the mechanism has to be changed at some time because of this.-->
##  <!--  Another reason would be the direct installation of methods for-->
##  <!--  <C>UseSubsetRelation</C>, i.e., the ranks of these methods are not affected-->
##  <!--  by the code in <C>InstallSubsetMaintenance</C>.) -->
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "SUBSET_MAINTAINED_INFO", [ [], [] ] );
if IsHPCGAP then
  ShareSpecialObj(SUBSET_MAINTAINED_INFO, "SUBSET_MAINTAINED_INFO");
fi;


#############################################################################
##
#O  UseSubsetRelation( <super>, <sub> )
##
##  <#GAPDoc Label="UseSubsetRelation">
##  <ManSection>
##  <Oper Name="UseSubsetRelation" Arg='super, sub'/>
##
##  <Description>
##  Methods for this operation transfer possibly useful information from the
##  domain <A>super</A> to its subset <A>sub</A>, and vice versa.
##  <P/>
##  <Ref Oper="UseSubsetRelation"/> is designed to be called automatically
##  whenever substructures of domains are constructed.
##  So the methods must be <E>cheap</E>, and the requirements should be as
##  sharp as possible!
##  <P/>
##  To achieve that <E>all</E> applicable methods are executed, all methods for
##  this operation except the default method must end with <C>TryNextMethod()</C>.
##  This default method deals with the information that is available by
##  the calls of <Ref Func="InstallSubsetMaintenance"/> in the &GAP; library.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= Group( (1,2), (3,4), (5,6) );; h:= Group( (1,2), (3,4) );;
##  gap> IsAbelian( g );  HasIsAbelian( h );
##  true
##  false
##  gap> UseSubsetRelation( g, h );;  HasIsAbelian( h );  IsAbelian( h );
##  true
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UseSubsetRelation", [ IsCollection, IsCollection ] );

InstallMethod( UseSubsetRelation,
    "default method that checks maintenances and then returns `true'",
    IsIdenticalObj,
    [ IsCollection, IsCollection ],
    # Make sure that this method is installed with ``real'' rank zero.
    {} -> - 2 * RankFilter( IsCollection ),
    function( super, sub )

    local entry;

    atomic readonly SUBSET_MAINTAINED_INFO do
    for entry in SUBSET_MAINTAINED_INFO[1] do
      if entry[1]( super ) and entry[2]( sub ) and not entry[4]( sub ) then
        entry[5]( sub, entry[3]( super ) );
      fi;
    od;
    od; # end atomic

    return true;
    end );


#############################################################################
##
#F  InstallSubsetMaintenance( <opr>, <super_req>, <sub_req> )
##
##  <#GAPDoc Label="InstallSubsetMaintenance">
##  <ManSection>
##  <Func Name="InstallSubsetMaintenance" Arg='opr, super_req, sub_req'/>
##
##  <Description>
##  <A>opr</A> must be a property or an attribute.
##  The call of <Ref Func="InstallSubsetMaintenance"/> has the effect that
##  for a domain <M>D</M> in the filter <A>super_req</A>,
##  and a domain <M>S</M> in the filter <A>sub_req</A>,
##  the call <C>UseSubsetRelation</C><M>( D, S )</M>
##  (see&nbsp;<Ref Oper="UseSubsetRelation"/>)
##  sets a known value of <A>opr</A> for <M>D</M> as value of <A>opr</A> also
##  for <M>S</M>.
##  A typical example for which <Ref Func="InstallSubsetMaintenance"/> is
##  applied is given by <A>opr</A> <C>= IsFinite</C>,
##  <A>super_req</A> <C>= IsCollection and IsFinite</C>,
##  and <A>sub_req</A> <C>= IsCollection</C>.
##  <P/>
##  If <A>opr</A> is a property and the filter <A>super_req</A> lies in the
##  filter <A>opr</A> then we can use also the following inverse implication.
##  If <M>D</M> is in the filter whose intersection with <A>opr</A> is
##  <A>super_req</A> and if <M>S</M> is in the filter <A>sub_req</A>,
##  <M>S</M> is a subset of <M>D</M>, and the value of <A>opr</A> for
##  <M>S</M> is <K>false</K> then the value of <A>opr</A> for <M>D</M> is
##  also <K>false</K>.
##  <!-- This is implemented only for the case <A>super_req</A> = <A>opr</A>
##       and <A>sub_req</A>.-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
    atomic readwrite SUBSET_MAINTAINED_INFO, readonly FILTER_REGION do
    for flag in TRUES_FLAGS( FLAGS_FILTER( sub_req ) ) do
      if not INFO_FILTERS[flag] in FNUM_CATS_AND_REPS then
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
      if not INFO_FILTERS[flag] in FNUM_CATS_AND_REPS then
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
    SUBSET_MAINTAINED_INFO[2][ i+1 ]:=
                MakeImmutable([ filtsopr, filtssub, rank ]);
    if attrprop then
      SUBSET_MAINTAINED_INFO[1][ i+1 ]:=
                MakeImmutable([ filt1, filt2, operation, tester, setter ]);
    else
      SUBSET_MAINTAINED_INFO[1][ i+1 ]:= MakeImmutable(
                [ filt1, filt2, operation, operation,
                  function( sub, val )
                      if val then
                          SetFilterObj( sub, operation );
                      else
                          ResetFilterObj( sub, operation );
                      fi;
                  end ]);
    fi;
    od; # end atomic

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
##  <ManSection>
##  <Var Name="ISOMORPHISM_MAINTAINED_INFO"/>
##
##  <Description>
##  is a list of lists of the form
##  <C>[ <A>filtsold</A>, <A>filtsnew</A>, <A>opr</A>, <A>testopr</A>, <A>settopr</A>, <A>old_req</A>,
##  <A>new-req</A> ]</C>
##  which is used for calls of <C>UseIsomorphismRelation( <A>old</A>, <A>new</A> )</C>.
##  This list is enlarged by calls to <C>InstallIsomorphismMaintenance</C>.
##  <P/>
##  The meaning of the entries is as follows.
##  <List>
##  <Mark><A>filtsold</A> </Mark>
##  <Item>
##      required filter for <A>old</A>,
##  </Item>
##  <Mark><A>filtsnew</A> </Mark>
##  <Item>
##      required filter for <A>new</A>,
##  </Item>
##  <Mark><A>opr</A> </Mark>
##  <Item>
##      operation whose value is inherited from <A>old</A> to <A>new</A>,
##  </Item>
##  <Mark><A>testopr</A> </Mark>
##  <Item>
##      tester filter of <A>opr</A>,
##  </Item>
##  <Mark><A>settopr</A> </Mark>
##  <Item>
##      setter filter of <A>opr</A>,
##  </Item>
##  <Mark><A>old-req</A> </Mark>
##  <Item>
##      requirements for <A>old</A> in the <C>InstallIsomorphismMaintenance</C> call,
##  </Item>
##  <Mark><A>new-req</A> </Mark>
##  <Item>
##      requirements for <A>new</A> in the <C>InstallIsomorphismMaintenance</C> call.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "ISOMORPHISM_MAINTAINED_INFO", [] );
if IsHPCGAP then
  ShareSpecialObj(ISOMORPHISM_MAINTAINED_INFO, "ISOMORPHISM_MAINTAINED_INFO");
fi;


#############################################################################
##
#O  UseIsomorphismRelation( <old>, <new> )
##
##  <#GAPDoc Label="UseIsomorphismRelation">
##  <ManSection>
##  <Oper Name="UseIsomorphismRelation" Arg='old, new'/>
##
##  <Description>
##  Methods for this operation transfer possibly useful information from the
##  domain <A>old</A> to the isomorphic domain <A>new</A>.
##  <P/>
##  <Ref Oper="UseIsomorphismRelation"/> is designed to be called
##  automatically whenever isomorphic structures of domains are constructed.
##  So the methods must be <E>cheap</E>, and the requirements should be as
##  sharp as possible!
##  <P/>
##  To achieve that <E>all</E> applicable methods are executed, all methods
##  for this operation except the default method must end with a call to
##  <Ref Func="TryNextMethod"/>.
##  This default method deals with the information that is available by
##  the calls of <Ref Func="InstallIsomorphismMaintenance"/> in the &GAP;
##  library.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= Group( (1,2) );;  h:= Group( [ [ -1 ] ] );;
##  gap> Size( g );  HasSize( h );
##  2
##  false
##  gap> UseIsomorphismRelation( g, h );;  HasSize( h );  Size( h );
##  true
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UseIsomorphismRelation", [ IsCollection, IsCollection ] );

InstallMethod( UseIsomorphismRelation,
    "default method that checks maintenances and then returns `true'",
    [ IsCollection, IsCollection ],
    # Make sure that this method is installed with ``real'' rank zero.
    {} -> - 2 * RankFilter( IsCollection ),
    function( old, new )
    local entry;

    atomic readonly ISOMORPHISM_MAINTAINED_INFO do
    for entry in ISOMORPHISM_MAINTAINED_INFO do
      if entry[1]( old ) and entry[2]( new ) and not entry[4]( new ) then
        entry[5]( new, entry[3]( old ) );
      fi;
    od;
    od; # end atomic

    return true;
    end );


#############################################################################
##
#F  InstallIsomorphismMaintenance( <opr>, <old_req>, <new_req> )
##
##  <#GAPDoc Label="InstallIsomorphismMaintenance">
##  <ManSection>
##  <Func Name="InstallIsomorphismMaintenance" Arg='opr, old_req, new_req'/>
##
##  <Description>
##  <A>opr</A> must be a property or an attribute.
##  The call of <Ref Func="InstallIsomorphismMaintenance"/> has the effect
##  that for a domain <M>D</M> in the filter <A>old_req</A>,
##  and a domain <M>E</M> in the filter <A>new_req</A>,
##  the call <C>UseIsomorphismRelation</C><M>( D, E )</M>
##  (see&nbsp;<Ref Oper="UseIsomorphismRelation"/>)
##  sets a known value of <A>opr</A> for <M>D</M> as value of <A>opr</A> also
##  for <M>E</M>.
##  A typical example for which <Ref Func="InstallIsomorphismMaintenance"/>
##  is applied is given by <A>opr</A> <C>= Size</C>,
##  <A>old_req</A> <C>= IsCollection</C>,
##  and <A>new_req</A> <C>= IsCollection</C>.
##  <!-- Up to now, there are no dependencies between the maintenances-->
##  <!-- (contrary to the case of subset maintenances),-->
##  <!-- so we do not take care of the succession.-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallIsomorphismMaintenance",
    function( opr, old_req, new_req )
    local tester;

    tester:= Tester( opr );

    atomic ISOMORPHISM_MAINTAINED_INFO do
    ADD_LIST( ISOMORPHISM_MAINTAINED_INFO, MakeImmutable(
        [ IsCollection and Tester( old_req ) and old_req and tester,
          IsCollection and Tester( new_req ) and new_req,
          opr,
          tester,
          Setter( opr ),
          old_req,
          new_req ] ) );
    od; # end atomic
end );


#############################################################################
##
#V  FACTOR_MAINTAINED_INFO
##
##  <ManSection>
##  <Var Name="FACTOR_MAINTAINED_INFO"/>
##
##  <Description>
##  is a list of lists of the form
##  <C>[ <A>filtsnum</A>, <A>filtsden</A>, <A>filtsfac</A>, <A>opr</A>, <A>testopr</A>, <A>settopr</A> ]</C>
##  which is used for calls of <C>UseFactorRelation( <A>num</A>, <A>den</A>, <A>fac</A> )</C>.
##  This list is enlarged by calls to <C>InstallFactorMaintenance</C>.
##  <P/>
##  The meaning of the entries is as follows.
##  <List>
##  <Mark><A>filtsnum</A> </Mark>
##  <Item>
##      required filter for <A>num</A>,
##  </Item>
##  <Mark><A>filtsden</A> </Mark>
##  <Item>
##      required filter for <A>den</A>,
##  </Item>
##  <Mark><A>filtsfac</A> </Mark>
##  <Item>
##      required filter for <A>fac</A>,
##  </Item>
##  <Mark><A>opr</A> </Mark>
##  <Item>
##      operation whose value is inherited from <A>num</A> to <A>fac</A>,
##  </Item>
##  <Mark><A>testopr</A> </Mark>
##  <Item>
##      tester filter of <A>opr</A>,
##  </Item>
##  <Mark><A>settopr</A> </Mark>
##  <Item>
##      setter filter of <A>opr</A>.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "FACTOR_MAINTAINED_INFO", [] );
if IsHPCGAP then
  ShareSpecialObj(FACTOR_MAINTAINED_INFO, "FACTOR_MAINTAINED_INFO");
fi;


#############################################################################
##
#O  UseFactorRelation( <numer>, <denom>, <factor> )
##
##  <#GAPDoc Label="UseFactorRelation">
##  <ManSection>
##  <Oper Name="UseFactorRelation" Arg='numer, denom, factor'/>
##
##  <Description>
##  Methods for this operation transfer possibly useful information from the
##  domain <A>numer</A> or its subset <A>denom</A> to the domain
##  <A>factor</A> that is isomorphic to the factor of <A>numer</A> by
##  <A>denom</A>, and vice versa.
##  <A>denom</A> may be <K>fail</K>, for example if <A>factor</A> is just
##  known to be a factor of <A>numer</A> but <A>denom</A> is not available as
##  a &GAP; object;
##  in this case those factor relations are used that are installed without
##  special requirements for <A>denom</A>.
##  <P/>
##  <Ref Oper="UseFactorRelation"/> is designed to be called automatically
##  whenever factor structures of domains are constructed.
##  So the methods must be <E>cheap</E>, and the requirements should be as
##  sharp as possible!
##  <P/>
##  To achieve that <E>all</E> applicable methods are executed, all methods
##  for this operation except the default method must end with a call to
##  <Ref Func="TryNextMethod"/>.
##  This default method deals with the information that is available by
##  the calls of <Ref Func="InstallFactorMaintenance"/> in the &GAP; library.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= Group( (1,2,3,4), (1,2) );; h:= Group( (1,2,3), (1,2) );;
##  gap> IsSolvableGroup( g );  HasIsSolvableGroup( h );
##  true
##  false
##  gap> UseFactorRelation(g, Subgroup( g, [ (1,2)(3,4), (1,3)(2,4) ] ), h);;
##  gap> HasIsSolvableGroup( h );  IsSolvableGroup( h );
##  true
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UseFactorRelation",
    [ IsCollection, IsObject, IsCollection ] );

InstallMethod( UseFactorRelation,
    "default method that checks maintenances and then returns `true'",
    true,
    [ IsCollection, IsObject, IsCollection ],
    # Make sure that this method is installed with ``real'' rank zero.
    {} -> - 2 * RankFilter( IsCollection )-RankFilter(IsObject),
    function( num, den, fac )

    local entry;

    atomic readonly FACTOR_MAINTAINED_INFO do
    for entry in FACTOR_MAINTAINED_INFO do
      if entry[1]( num ) and entry[2]( den ) and entry[3]( fac )
                         and not entry[5]( fac ) then
        entry[6]( fac, entry[4]( num ) );
      fi;
    od;
    od; # end atomic

    return true;
    end );


#############################################################################
##
#F  InstallFactorMaintenance( <opr>, <numer_req>, <denom_req>, <factor_req> )
##
##  <#GAPDoc Label="InstallFactorMaintenance">
##  <ManSection>
##  <Func Name="InstallFactorMaintenance"
##   Arg='opr, numer_req, denom_req, factor_req'/>
##
##  <Description>
##  <A>opr</A> must be a property or an attribute.
##  The call of <Ref Func="InstallFactorMaintenance"/> has the effect that
##  for collections <M>N</M>, <M>D</M>, <M>F</M> in the filters
##  <A>numer_req</A>, <A>denom_req</A>, and <A>factor_req</A>, respectively,
##  the call <C>UseFactorRelation</C><M>( N, D, F )</M>
##  (see&nbsp;<Ref Oper="UseFactorRelation"/>)
##  sets a known value of <A>opr</A> for <M>N</M> as value of <A>opr</A> also
##  for <M>F</M>.
##  A typical example for which <Ref Func="InstallFactorMaintenance"/> is
##  applied is given by <A>opr</A> <C>= IsFinite</C>,
##  <A>numer_req</A> <C>= IsCollection and IsFinite</C>,
##  <A>denom_req</A> <C>= IsCollection</C>,
##  and <A>factor_req</A> <C>= IsCollection</C>.
##  <P/>
##  For the other direction, if <A>numer_req</A> involves the filter
##  <A>opr</A> then a known <K>false</K> value of <A>opr</A> for <M>F</M>
##  implies a <K>false</K> value for <M>D</M> provided that <M>D</M> lies in
##  the filter obtained from <A>numer_req</A> by removing <A>opr</A>.
##  <P/>
##  Note that an implication of a factor relation holds in particular for the
##  case of isomorphisms.
##  So one need <E>not</E> install an isomorphism maintained method when
##  a factor maintained method is already installed.
##  For example, <Ref Oper="UseIsomorphismRelation"/>
##  will transfer a known <Ref Prop="IsFinite"/> value because of the
##  installed factor maintained method.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallFactorMaintenance",
    function( opr, numer_req, denom_req, factor_req )

    local tester;

    # Information that is maintained under taking factors
    # is especially maintained under isomorphisms.
    InstallIsomorphismMaintenance( opr, numer_req, factor_req );

    tester:= Tester( opr );

    atomic FACTOR_MAINTAINED_INFO do
    ADD_LIST( FACTOR_MAINTAINED_INFO, MakeImmutable(
        [ IsCollection and Tester( numer_req ) and numer_req and tester,
          Tester( denom_req ) and denom_req,
          IsCollection and Tester( factor_req ) and factor_req,
          opr,
          tester,
          Setter( opr ) ] ) );
    od; # end atomic

#T not yet available in the new implementation
#     if     FLAGS_FILTER( opr ) <> false
#        and IS_EQUAL_FLAGS( FLAGS_FILTER( opr and factor_req ),
#                            FLAGS_FILTER( numer_req ) )  then
#         InstallMethod( UseFactorRelation, infostring, IsFamFamX,
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
#O  Iterator( <listorcoll> )  . . . . . . . iterator for a list or collection
##
##  <#GAPDoc Label="Iterator">
##  <ManSection>
##  <Oper Name="Iterator" Arg='listorcoll'/>
##  <Filt Name="IsStandardIterator" Arg='listorcoll'/>
##
##  <Description>
##  Iterators provide a possibility to loop over the elements of a
##  (countable) collection or list <A>listorcoll</A>, without repetition.
##  For many collections <M>C</M>,
##  an iterator of <M>C</M> need not store all elements of <M>C</M>,
##  for example it is possible to construct an iterator of some infinite
##  domains, such as the field of rational numbers.
##  <P/>
##  <Ref Oper="Iterator"/> returns a mutable <E>iterator</E> <M>iter</M> for
##  its argument.
##  If this argument is a list (which may contain holes),
##  then <M>iter</M> iterates over the elements (but not the holes) of this
##  list in the same order (see&nbsp;<Ref Func="IteratorList"/> for details).
##  If this argument is a collection but not a list then <M>iter</M> iterates
##  over the elements of this collection in an unspecified order,
##  which may change for repeated calls of <Ref Oper="Iterator"/>.
##  Because iterators returned by <Ref Oper="Iterator"/> are mutable
##  (see&nbsp;<Ref Sect="Mutability and Copyability"/>),
##  each call of <Ref Oper="Iterator"/> for the same argument returns a
##  <E>new</E> iterator.
##  Therefore <Ref Oper="Iterator"/> is not an attribute
##  (see&nbsp;<Ref Sect="Attributes"/>).
##  <P/>
##  The only operations for iterators are <Ref Oper="IsDoneIterator"/>,
##  <Ref Oper="NextIterator"/>, and <Ref Oper="ShallowCopy"/>.
##  In particular, it is only possible to access the next element of the
##  iterator with <Ref Oper="NextIterator"/> if there is one,
##  and this can be checked with <Ref Oper="IsDoneIterator"/>
##  For an iterator <M>iter</M>, <Ref Oper="ShallowCopy"/> returns a
##  mutable iterator <M>new</M> that iterates over the remaining elements
##  independent of <M>iter</M>;
##  the results of <Ref Oper="IsDoneIterator"/> for <M>iter</M> and
##  <M>new</M> are equal,
##  and if <M>iter</M> is mutable then also the results of
##  <Ref Oper="NextIterator"/> for <M>iter</M> and <M>new</M> are equal;
##  note that <C>=</C> is not defined for iterators,
##  so the equality of two iterators cannot be checked with <C>=</C>.
##  <P/>
##  When <Ref Oper="Iterator"/> is called for a <E>mutable</E> collection
##  <M>C</M> then it is not defined whether <M>iter</M> respects changes to
##  <M>C</M> occurring after the construction of <M>iter</M>,
##  except if the documentation explicitly promises a certain behaviour.
##  The latter is the case if the argument is a mutable list
##  (see&nbsp;<Ref Func="IteratorList"/> for subtleties in this case).
##  <P/>
##  It is possible to have <K>for</K>-loops run over mutable iterators
##  instead of lists.
##  <P/>
##  In some situations, one can construct iterators with a special
##  succession of elements,
##  see&nbsp;<Ref Oper="IteratorByBasis"/> for the possibility to loop over
##  the elements of a vector space w.r.t.&nbsp;a given basis.
##  <!-- (also for perm. groups, w.r.t. a given stabilizer chain?)-->
##  <P/>
##  For lists, <Ref Oper="Iterator"/> is implemented by
##  <Ref Func="IteratorList"/>.
##  For collections <M>C</M> that are not lists, the default method is
##  <C>IteratorList( Enumerator( </C><M>C</M><C> ) )</C>.
##  Better methods depending on <M>C</M> should be provided if possible.
##  <P/>
##  For random access to the elements of a (possibly infinite) collection,
##  <E>enumerators</E> are used.
##  See&nbsp;<Ref Sect="Enumerators"/> for the facility to compute a list
##  from <M>C</M>, which provides a (partial) mapping from <M>C</M> to the
##  positive integers.
##  <P/>
##  The filter <Ref Filt="IsStandardIterator"/> means that the iterator is
##  implemented as a component object and has components <C>IsDoneIterator</C>
##  and <C>NextIterator</C> which are bound to the methods of the operations of
##  the same name for this iterator.
##  <!-- (This is used to avoid overhead when looping over such iterators.) -->
##  <!--  We wanted to admit an iterator as first argument of <C>Filtered</C>,-->
##  <!--  <C>First</C>, <C>ForAll</C>, <C>ForAny</C>, <C>Number</C>.-->
##  <!--  This is not yet implemented.-->
##  <!--  (Note that the iterator is changed in the call,-->
##  <!--  so the meaning of the operations would be slightly abused,-->
##  <!--  or we must define that these operations first make a shallow copy.)-->
##  <!--  (Additionally, the unspecified order of the elements makes it-->
##  <!--  difficult to define what <C>First</C> and <C>Filtered</C> means for an iterator.)-->
##  <Example><![CDATA[
##  gap> iter:= Iterator( GF(5) );
##  <iterator>
##  gap> l:= [];;
##  gap> for i in iter do Add( l, i ); od; l;
##  [ 0*Z(5), Z(5)^0, Z(5), Z(5)^2, Z(5)^3 ]
##  gap> iter:= Iterator( [ 1, 2, 3, 4 ] );;  l:= [];;
##  gap> for i in iter do
##  >      new:= ShallowCopy( iter );
##  >      for j in new do Add( l, j ); od;
##  >    od; l;
##  [ 2, 3, 4, 3, 4, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter("IsStandardIterator");
DeclareOperation( "Iterator", [ IsListOrCollection ] );


#############################################################################
##
#O  IteratorSorted( <C> ) . . . . . . . . . . . set iterator for a collection
#O  IteratorSorted( <list> )  . . . . . . . . . . . . set iterator for a list
##
##  <#GAPDoc Label="IteratorSorted">
##  <ManSection>
##  <Oper Name="IteratorSorted" Arg='listorcoll'/>
##
##  <Description>
##  <Ref Oper="IteratorSorted"/> returns a mutable iterator.
##  The argument must be a collection or a list that is not
##  necessarily dense but whose elements lie in the same family
##  (see&nbsp;<Ref Sect="Families"/>).
##  It loops over the different elements in sorted order.
##  <P/>
##  For a collection <M>C</M> that is not a list, the generic method is
##  <C>IteratorList( EnumeratorSorted( </C><A>C</A><C> ) )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IteratorSorted", [ IsListOrCollection ] );


#############################################################################
##
#C  IsIterator( <obj> ) . . . . . . . . . .  test if an object is an iterator
##
##  <#GAPDoc Label="IsIterator">
##  <ManSection>
##  <Filt Name="IsIterator" Arg='obj' Type='Category'/>
##
##  <Description>
##  Every iterator lies in the category <C>IsIterator</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsIterator", IsObject );


#############################################################################
##
#O  IsDoneIterator( <iter> )  . . . . . . .  test if an iterator is exhausted
##
##  <#GAPDoc Label="IsDoneIterator">
##  <ManSection>
##  <Oper Name="IsDoneIterator" Arg='iter'/>
##
##  <Description>
##  If <A>iter</A> is an iterator for the list or collection <M>C</M> then
##  <C>IsDoneIterator( <A>iter</A> )</C> is <K>true</K> if all elements of
##  <M>C</M> have been returned already by <C>NextIterator( <A>iter</A> )</C>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsDoneIterator", [ IsIterator ] );


#############################################################################
##
#O  NextIterator( <iter> )  . . . . . . . . . . next element from an iterator
##
##  <#GAPDoc Label="NextIterator">
##  <ManSection>
##  <Oper Name="NextIterator" Arg='iter'/>
##
##  <Description>
##  Let <A>iter</A> be a mutable iterator for the list or collection <M>C</M>.
##  If <C>IsDoneIterator( <A>iter</A> )</C> is <K>false</K> then
##  <Ref Oper="NextIterator"/> is applicable to <A>iter</A>,
##  and the result is the next element of <M>C</M>,
##  according to the succession defined by <A>iter</A>.
##  <P/>
##  If <C>IsDoneIterator( <A>iter</A> )</C> is <K>true</K> then it is not
##  defined what happens when <Ref Oper="NextIterator"/> is called for
##  <A>iter</A>;
##  that is, it may happen that an error is signalled or that something
##  meaningless is returned, or even that &GAP; crashes.
##  <P/>
##  <Example><![CDATA[
##  gap> iter:= Iterator( [ 1, 2, 3, 4 ] );
##  <iterator>
##  gap> sum:= 0;;
##  gap> while not IsDoneIterator( iter ) do
##  >      sum:= sum + NextIterator( iter );
##  >    od;
##  gap> IsDoneIterator( iter ); sum;
##  true
##  10
##  gap> ir:= Iterator( Rationals );;
##  gap> l:= [];; for i in [1..20] do Add( l, NextIterator( ir ) ); od; l;
##  [ 0, 1, -1, 1/2, 2, -1/2, -2, 1/3, 2/3, 3/2, 3, -1/3, -2/3, -3/2, -3,
##    1/4, 3/4, 4/3, 4, -1/4 ]
##  gap> for i in ir do
##  >      if DenominatorRat( i ) > 10 then break; fi;
##  >    od;
##  gap> i;
##  1/11
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NextIterator", [ IsIterator and IsMutable ] );


#############################################################################
##
#F  TrivialIterator( <elm> )
##
##  <#GAPDoc Label="TrivialIterator">
##  <ManSection>
##  <Func Name="TrivialIterator" Arg='elm'/>
##
##  <Description>
##  is a mutable iterator for the collection <C>[ <A>elm</A> ]</C> that
##  consists of exactly one element <A>elm</A>
##  (see&nbsp;<Ref Prop="IsTrivial"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TrivialIterator" );


#############################################################################
##
#F  IteratorByFunctions( <record> )
##
##  <#GAPDoc Label="IteratorByFunctions">
##  <ManSection>
##  <Func Name="IteratorByFunctions" Arg='record'/>
##
##  <Description>
##  <Ref Func="IteratorByFunctions"/> returns a (mutable) iterator
##  <A>iter</A> for which <Ref Oper="NextIterator"/>,
##  <Ref Oper="IsDoneIterator"/>,
##  and <Ref Oper="ShallowCopy"/>
##  are computed via prescribed functions.
##  <P/>
##  Let <A>record</A> be a record with at least the following components.
##  <List>
##  <Mark><C>NextIterator</C></Mark>
##  <Item>
##      a function taking one argument <A>iter</A>,
##      which returns the next element of <A>iter</A>
##      (see&nbsp;<Ref Oper="NextIterator"/>);
##      for that, the components of <A>iter</A> are changed,
##  </Item>
##  <Mark><C>IsDoneIterator</C></Mark>
##  <Item>
##      a function taking one argument <A>iter</A>,
##      which returns the <Ref Oper="IsDoneIterator"/> value of <A>iter</A>,
##  </Item>
##  <Mark><C>ShallowCopy</C></Mark>
##  <Item>
##      a function taking one argument <A>iter</A>,
##      which returns a record for which <Ref Func="IteratorByFunctions"/>
##      can be called in order to create a new iterator that is independent
##      of <A>iter</A> but behaves like <A>iter</A> w.r.t. the operations
##      <Ref Oper="NextIterator"/> and <Ref Oper="IsDoneIterator"/>.
##  </Item>
##  <Mark><C>ViewObj</C> and <C>PrintObj</C></Mark>
##  <Item>
##      two functions that print what one wants to be printed when
##      <C>View( <A>iter</A> )</C> or <C>Print( <A>item</A> )</C> is called
##      (see&nbsp;<Ref Sect="View and Print"/>),
##      if the <C>ViewObj</C> component is missing then the <C>PrintObj</C>
##      method is used as a default.
##  </Item>
##  </List>
##  Further (data) components may be contained in <A>record</A> which can be
##  used by these function.
##  <P/>
##  <Ref Func="IteratorByFunctions"/> does <E>not</E> make a shallow copy of
##  <A>record</A>, this record is changed in place
##  (see Section &nbsp;<Ref Sect="Creating Objects"/>).
##  <P/>
##  Iterators constructed with <Ref Func="IteratorByFunctions"/> are in the
##  filter <Ref Filt="IsStandardIterator"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IteratorByFunctions" );


#############################################################################
##
#P  IsEmpty( <C> )  . . . . . . . . . . . . . . test if a collection is empty
#P  IsEmpty( <list> ) . . . . . . . . . . . . . test if a collection is empty
##
##  <#GAPDoc Label="IsEmpty">
##  <ManSection>
##  <Prop Name="IsEmpty" Arg='listorcoll'/>
##
##  <Description>
##  <Ref Prop="IsEmpty"/> returns <K>true</K> if the collection or list
##  <A>listorcoll</A> is <E>empty</E> (that is it contains no elements),
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsEmpty", IsListOrCollection );


#############################################################################
##
#P  IsTrivial( <C> )  . . . . . . . . . . . . test if a collection is trivial
##
##  <#GAPDoc Label="IsTrivial">
##  <ManSection>
##  <Prop Name="IsTrivial" Arg='C'/>
##
##  <Description>
##  <Ref Prop="IsTrivial"/> returns <K>true</K> if the collection <A>C</A>
##  consists of exactly one element.
##  <!--  1996/08/08 M.Schönert is this a sensible definition?-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsTrivial", IsCollection );

InstallFactorMaintenance( IsTrivial,
    IsCollection and IsTrivial, IsObject, IsCollection );


#############################################################################
##
#P  IsNonTrivial( <C> ) . . . . . . . . .  test if a collection is nontrivial
##
##  <#GAPDoc Label="IsNonTrivial">
##  <ManSection>
##  <Prop Name="IsNonTrivial" Arg='C'/>
##
##  <Description>
##  <Ref Prop="IsNonTrivial"/> returns <K>true</K> if the collection <A>C</A>
##  is empty or consists of at least two elements
##  (see&nbsp;<Ref Prop="IsTrivial"/>).
##  <P/>
##  <!-- I need this to distinguish trivial rings-with-one from fields!-->
##  <!-- (indication to introduce antifilters?)-->
##  <!--  1996/08/08 M.Schönert is this a sensible definition?-->
##  <Example><![CDATA[
##  gap> IsEmpty( [] ); IsEmpty( [ 1 .. 100 ] ); IsEmpty( Group( (1,2,3) ) );
##  true
##  false
##  false
##  gap> IsFinite( [ 1 .. 100 ] );  IsFinite( Integers );
##  true
##  false
##  gap> IsTrivial( Integers );  IsTrivial( Group( () ) );
##  false
##  true
##  gap> IsNonTrivial( Integers );  IsNonTrivial( Group( () ) );
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsNonTrivial", IsCollection );

InstallTrueMethod( IsNonTrivial, IsEmpty );
InstallTrueMethod( HasIsTrivial, IsNonTrivial );
InstallTrueMethod( HasIsEmpty, IsTrivial );
InstallTrueMethod( HasIsNonTrivial, IsTrivial );


#############################################################################
##
#P  IsFinite( <C> ) . . . . . . . . . . . . .  test if a collection is finite
##
##  <#GAPDoc Label="IsFinite">
##  <ManSection>
##  <Prop Name="IsFinite" Arg='C'/>
##
##  <Description>
##  <Index Subkey="for a list or collection">finiteness test</Index>
##  <Ref Prop="IsFinite"/> returns <K>true</K> if the collection <A>C</A>
##  is finite, and <K>false</K> otherwise.
##  <P/>
##  The default method for <Ref Prop="IsFinite"/> checks the size
##  (see&nbsp;<Ref Attr="Size"/>) of <A>C</A>.
##  <P/>
##  Methods for <Ref Prop="IsFinite"/> may call <Ref Attr="Size"/>,
##  but methods for <Ref Attr="Size"/> must <E>not</E> call
##  <Ref Prop="IsFinite"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFinite", IsListOrCollection );

InstallSubsetMaintenance( IsFinite,
    IsCollection and IsFinite, IsCollection );
InstallFactorMaintenance( IsFinite,
    IsCollection and IsFinite, IsObject, IsCollection );

InstallTrueMethod( IsFinite, IsTrivial );
InstallTrueMethod( IsFinite, IsEmpty );


#############################################################################
##
#P  IsWholeFamily( <C> )  . .  test if a collection contains the whole family
##
##  <#GAPDoc Label="IsWholeFamily">
##  <ManSection>
##  <Prop Name="IsWholeFamily" Arg='C'/>
##
##  <Description>
##  <Ref Prop="IsWholeFamily"/> returns <K>true</K> if the collection
##  <A>C</A> contains the whole family (see&nbsp;<Ref Sect="Families"/>)
##  of its elements.
##  <P/>
##  <Example><![CDATA[
##  gap> IsWholeFamily( Integers )
##  >    ;  # all rationals and cyclotomics lie in the family
##  false
##  gap> IsWholeFamily( Integers mod 3 )
##  >    ;  # all finite field elements in char. 3 lie in this family
##  false
##  gap> IsWholeFamily( Integers mod 4 );
##  true
##  gap> IsWholeFamily( FreeGroup( 2 ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsWholeFamily", IsCollection );


#############################################################################
##
#A  Size( <C> ) . . . . . . . . . . . . . . . . . . . .  size of a collection
#A  Size( <list> )  . . . . . . . . . . . . . . . . . .  size of a collection
##
##  <#GAPDoc Label="Size">
##  <ManSection>
##  <Attr Name="Size" Arg='listorcoll'/>
##
##  <Description>
##  <Index Subkey="of a list or collection">size</Index>
##  <Index Subkey="of a list, collection or domain">order</Index>
##  <Ref Attr="Size"/> returns the size of the list or collection
##  <A>listorcoll</A>, which is either an integer or <Ref Var="infinity"/>.
##  If the argument is a list then the result is its length
##  (see&nbsp;<Ref Attr="Length"/>).
##  <P/>
##  The default method for <Ref Attr="Size"/> checks the length of an
##  enumerator of <A>listorcoll</A>.
##  <P/>
##  Methods for <Ref Prop="IsFinite"/> may call <Ref Attr="Size"/>,
##  but methods for <Ref Attr="Size"/> must not call <Ref Prop="IsFinite"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> Size( [1,2,3] );  Size( Group( () ) );  Size( Integers );
##  3
##  1
##  infinity
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Size", IsListOrCollection );

InstallIsomorphismMaintenance( Size, IsCollection, IsCollection );


#############################################################################
##
#A  Representative( <C> ) . . . . . . . . . . . . one element of a collection
##
##  <#GAPDoc Label="Representative">
##  <ManSection>
##  <Attr Name="Representative" Arg='C'/>
##
##  <Description>
##  <Ref Attr="Representative"/> returns a <E>representative</E>
##  of the collection <A>C</A>.
##  <P/>
##  Note that <Ref Attr="Representative"/> is free in choosing
##  a representative if there are several elements in <A>C</A>.
##  It is not even guaranteed that <Ref Attr="Representative"/> returns
##  the same representative if it is called several times for one collection.
##  The main difference between <Ref Attr="Representative"/> and
##  <Ref Oper="Random" Label="for a list or collection"/>
##  is that <Ref Attr="Representative"/> is free
##  to choose a value that is cheap to compute,
##  while <Ref Oper="Random" Label="for a list or collection"/>
##  must make an effort to randomly distribute its answers.
##  <P/>
##  If <A>C</A> is a domain then there are methods for
##  <Ref Attr="Representative"/> that try
##  to fetch an element from any known generator list of <A>C</A>,
##  see&nbsp;<Ref Chap="Domains and their Elements"/>.
##  Note that <Ref Attr="Representative"/> does not try to <E>compute</E>
##  generators of <A>C</A>,
##  thus <Ref Attr="Representative"/> may give up and signal an error
##  if <A>C</A> has no generators stored at all.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Representative", IsListOrCollection );


#############################################################################
##
#A  RepresentativeSmallest( <C> ) . . . . .  smallest element of a collection
##
##  <#GAPDoc Label="RepresentativeSmallest">
##  <ManSection>
##  <Attr Name="RepresentativeSmallest" Arg='C'/>
##
##  <Description>
##  <Index Subkey="of a list or collection">representative</Index>
##  returns the smallest element in the collection <A>C</A>, w.r.t.&nbsp;the
##  ordering <Ref Oper="\&lt;"/>.
##  While the operation defaults to comparing all elements,
##  better methods are installed for some collections.
##  <P/>
##  <Example><![CDATA[
##  gap> Representative( Rationals );
##  0
##  gap> Representative( [ -1, -2 .. -100 ] );
##  -1
##  gap> RepresentativeSmallest( [ -1, -2 .. -100 ] );
##  -100
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RepresentativeSmallest", IsListOrCollection );


#############################################################################
##
#O  Random( <C> ) . . . . . . . . . . random element of a nonempty collection
#O  Random( <list> )  . . . . . . .  random element of a dense, nonempty list
#O  Random( <from>, <to> )
##
##  <#GAPDoc Label="Random:coll">
##  <ManSection>
##  <Oper Name="Random" Arg='listorcoll' Label="for a list or collection"/>
##  <Oper Name="Random" Arg='from, to' Label="for lower and upper bound"/>
##
##  <Description>
##  <!-- to get this on top of results for ?Random -->
##  <Index Key="Random"><Ref Oper="Random"
##                           Label="for a list or collection"/></Index>
##  <Ref Oper="Random" Label="for a list or collection"/> returns a
##  (pseudo-)random element of the dense, nonempty list or nonempty
##  collection <A>listorcoll</A>.
##  The behaviour for non-dense or empty lists, and for empty collections
##  (see <Ref Filt="IsDenseList"/>, <Ref Prop="IsEmpty"/>)
##  is undefined.
##  <P/>
##  As lists or ranges are restricted in length (<M>2^{28}-1</M> or
##  <M>2^{60}-1</M> depending on your system), the second form returns a
##  random integer in the range <A>from</A> to <A>to</A> (inclusive) for
##  arbitrary integers <A>from</A> and <A>to</A>.
##  The behaviour in the case that <A>from</A> is larger than <A>to</A>
##  is undefined.
##  <P/>
##  See Section <Ref Sect="Random Sources"/> for more about computing
##  random elements, in particular for
##  <Ref Oper="Random" Label="for random source and list"/> methods
##  that take a random source as the first argument.
##  <P/>
##  The distribution of elements returned by
##  <Ref Oper="Random" Label="for a list or collection"/> depends
##  on the argument.
##  For a dense, nonempty list the distribution is uniform (all elements are
##  equally likely).
##  The same holds usually for finite collections that are
##  not lists.
##  For infinite collections some reasonable distribution is used.
##  <P/>
##  See the chapters of the various collections to find out
##  which distribution is being used.
##  <P/>
##  For some collections ensuring a reasonable distribution can be
##  difficult and require substantial runtime (for example for large
##  finite groups). If speed is more important than a guaranteed
##  distribution,
##  the operation <Ref Oper="PseudoRandom"/> should be used instead.
##  <P/>
##  Note that <Ref Oper="Random" Label="for a list or collection"/>
##  is of course <E>not</E> an attribute.
##  <P/>
##  <Example><![CDATA[
##  gap> Random([1..6]);
##  6
##  gap> Random(1, 2^100);
##  866227015645295902682304086250
##  gap> g:= Group( (1,2,3) );;  Random( g );  Random( g );
##  (1,3,2)
##  ()
##  gap> Random(Rationals);
##  -4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
# We keep the declaration for non-dense lists
# in order not to break existing code.
DeclareOperation( "Random", [ IsListOrCollection ] );
DeclareOperation( "Random", [ IS_INT, IS_INT ] );


#############################################################################
##
##  <#GAPDoc Label="[2]{coll}">
##  The method used by &GAP; to obtain random elements may depend on the
##  type object.
##  <P/>
##  Most methods which produce random elements in &GAP; use a global random
##  number generator (see <Ref Var="GlobalMersenneTwister"/>).
##  This random number generator is (deliberately) initialized to the same
##  values when &GAP; is started, so different runs of &GAP; with the same
##  input will always produce the same result, even if random calculations
##  are involved.
##  <P/>
##  See <Ref Oper="Reset"/> for a description of how to reset the
##  random number generator to a previous state.
##  <P/>
##  <#/GAPDoc>
##


#############################################################################
##
#F  RandomList( [<rs>, ]<list> )
##
##  <#GAPDoc Label="RandomList">
##  <ManSection>
##  <Func Name="RandomList" Arg='[rs,] list'/>
##
##  <Description>
##  <Index>random seed</Index>
##  For a dense list <A>list</A>,
##  <Ref Func="RandomList"/> returns a (pseudo-)random element with equal
##  distribution.
##  <P/>
##  The random source <A>rs</A> (see <Ref Sect="Random Sources"/>)
##  is used to choose a random number.
##  If <A>rs</A> is absent,
##  this function uses the <Ref Var="GlobalMersenneTwister"/> to produce the
##  random elements (a source of high quality random numbers).
##  <P/>
##  <Example><![CDATA[
##  gap> RandomList( [ 1 .. 6 ] );
##  3
##  gap> elms:= AsList( Group( (1,2,3) ) );;
##  gap> RandomList( elms );  RandomList( elms );
##  (1,3,2)
##  (1,2,3)
##  gap> rs:= RandomSource( IsMersenneTwister, 1 );
##  <RandomSource in IsMersenneTwister>
##  gap> RandomList( rs, elms );
##  (1,3,2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RandomList" );


#############################################################################
##
#O  PseudoRandom( <C> ) . . . . . . . . pseudo random element of a collection
#O  PseudoRandom( <list> )  . . . . . . . . . pseudo random element of a list
##
##  <#GAPDoc Label="PseudoRandom">
##  <ManSection>
##  <Oper Name="PseudoRandom" Arg='listorcoll'/>
##
##  <Description>
##  <Ref Oper="PseudoRandom"/> returns a pseudo random element
##  of the list or collection <A>listorcoll</A>,
##  which can be roughly described as follows.
##  For a list, <Ref Oper="PseudoRandom"/> returns the same as
##  <Ref Oper="Random" Label="for a list or collection"/>.
##  For collections that are not lists,
##  the elements returned by <Ref Oper="PseudoRandom"/> are
##  <E>not</E> necessarily equally distributed,
##  even for finite collections;
##  the idea is that <Ref Oper="Random" Label="for a list or collection"/>
##  returns elements according to
##  a reasonable distribution, <Ref Oper="PseudoRandom"/> returns elements
##  that are cheap to compute but need not satisfy this strong condition, and
##  <Ref Attr="Representative"/> returns arbitrary elements,
##  probably the same element for each call.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PseudoRandom", [ IsListOrCollection ] );


#############################################################################
##
#A  PseudoRandomSeed( <C> )
##
##  <ManSection>
##  <Attr Name="PseudoRandomSeed" Arg='C'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "PseudoRandomSeed", IsListOrCollection, "mutable" );


#############################################################################
##
#A  Enumerator( <C> ) . . . . . . . . . . .  list of elements of a collection
#A  Enumerator( <list> )  . . . . . . . . . . . .  list of elements of a list
##
##  <#GAPDoc Label="Enumerator">
##  <ManSection>
##  <Attr Name="Enumerator" Arg='listorcoll'/>
##
##  <Description>
##  <Ref Attr="Enumerator"/> returns an immutable list <M>enum</M>.
##  If the argument is a list (which may contain holes),
##  then <C>Length( </C><M>enum</M><C> )</C> is the length of this list,
##  and <M>enum</M> contains the elements (and holes) of this list in the
##  same order.
##  If the argument is a collection that is not a list,
##  then <C>Length( </C><M>enum</M><C> )</C> is the number of different
##  elements of <A>C</A>,
##  and <M>enum</M> contains the different elements of the collection in an
##  unspecified order, which may change for repeated calls of
##  <Ref Attr="Enumerator"/>.
##  <M>enum[pos]</M> may not execute in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <M>enum</M> in memory is as small as is feasible.
##  <P/>
##  For lists, the default method is <Ref Func="Immutable"/>.
##  For collections that are not lists, there is no default method.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Enumerator", IsListOrCollection );


#############################################################################
##
#A  EnumeratorSorted( <C> ) . . . . .  proper set of elements of a collection
#A  EnumeratorSorted( <list> )  . . . . . .  proper set of elements of a list
##
##  <#GAPDoc Label="EnumeratorSorted">
##  <ManSection>
##  <Attr Name="EnumeratorSorted" Arg='listorcoll'/>
##
##  <Description>
##  <Ref Attr="EnumeratorSorted"/> returns an immutable list <M>enum</M>.
##  The argument must be a collection or a list <A>listorcoll</A>
##  which may contain holes but whose elements lie in the same family
##  (see&nbsp;<Ref Sect="Families"/>).
##  <C>Length( </C><M>enum</M><C> )</C> is the number of different elements
##  of the argument,
##  and <M>enum</M> contains the different elements in sorted order,
##  w.r.t.&nbsp;<C>&lt;</C>.
##  <M>enum[pos]</M> may not execute in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <M>enum</M> in memory is as small as is feasible.
##  <P/>
##  <Example><![CDATA[
##  gap> Enumerator( [ 1, 3,, 2 ] );
##  [ 1, 3,, 2 ]
##  gap> enum:= Enumerator( Rationals );;  elm:= enum[ 10^6 ];
##  -69/907
##  gap> Position( enum, elm );
##  1000000
##  gap> IsMutable( enum );  IsSortedList( enum );
##  false
##  false
##  gap> IsConstantTimeAccessList( enum );
##  false
##  gap> EnumeratorSorted( [ 1, 3,, 2 ] );
##  [ 1, 2, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "EnumeratorSorted", IsListOrCollection );


#############################################################################
##
#F  EnumeratorOfSubset( <list>, <blist>[, <ishomog>] )
##
##  <ManSection>
##  <Func Name="EnumeratorOfSubset" Arg='list, blist[, ishomog]'/>
##
##  <Description>
##  Let <A>list</A> be a list, and <A>blist</A> a Boolean list of the same
##  length (see&nbsp;<Ref Chap="Boolean Lists"/>).
##  <Ref Func="EnumeratorOfSubset"/> returns a list <A>new</A> of length
##  equal to the number of <K>true</K> entries in <A>blist</A>,
##  such that <C><A>new</A>[i]</C>, if bound, equals the entry of <A>list</A>
##  at the <A>i</A>-th <K>true</K> position in <A>blist</A>.
##  <P/>
##  If <A>list</A> is homogeneous then also <A>new</A> is homogeneous.
##  If <A>list</A> is <E>not</E> homogeneous then the third argument
##  <A>ishomog</A> must be present and equal to <K>true</K> or <K>false</K>,
##  saying whether or not <A>new</A> is homogeneous.
##  <P/>
##  This construction is used for example in the situation that <A>list</A>
##  is an enumerator of a large set,
##  and <A>blist</A> describes a union of orbits in an action on this set.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "EnumeratorOfSubset" );


#############################################################################
##
#F  EnumeratorByFunctions( <D>, <record> )
#F  EnumeratorByFunctions( <Fam>, <record> )
##
##  <#GAPDoc Label="EnumeratorByFunctions">
##  <Heading>EnumeratorByFunctions</Heading>
##  <ManSection>
##  <Func Name="EnumeratorByFunctions" Arg='D, record'
##   Label="for a domain and a record"/>
##  <Func Name="EnumeratorByFunctions" Arg='Fam, record'
##   Label="for a family and a record"/>
##
##  <Description>
##  <Ref Func="EnumeratorByFunctions" Label="for a domain and a record"/>
##  returns an immutable, dense, and duplicate-free list <M>enum</M> for
##  which <Ref Oper="IsBound" Label="for a list index"/>,
##  element access via <Ref Oper="\[\]"/>,
##  <Ref Attr="Length"/>, and <Ref Oper="Position"/>
##  are computed via prescribed functions.
##  <P/>
##  Let <A>record</A> be a record with at least the following components.
##  <List>
##  <Mark><C>ElementNumber</C></Mark>
##  <Item>
##      a function taking two arguments <A>enum</A> and <A>pos</A>,
##      which returns <C><A>enum</A>[ <A>pos</A> ]</C>
##      (see&nbsp;<Ref Sect="Basic Operations for Lists"/>);
##      it can be assumed that the argument <A>pos</A> is a positive integer,
##      but <A>pos</A> may be larger than the length of <A>enum</A>
##      (in which case an error must be signalled);
##      note that the result must be immutable since <A>enum</A> itself is
##      immutable,
##  </Item>
##  <Mark><C>NumberElement</C></Mark>
##  <Item>
##      a function taking two arguments <A>enum</A> and <A>elm</A>,
##      which returns <C>Position( <A>enum</A>, <A>elm</A> )</C>
##      (see&nbsp;<Ref Oper="Position"/>);
##      it cannot be assumed that <A>elm</A> is really contained in
##      <A>enum</A> (and <K>fail</K> must be returned if not);
##      note that for the three argument version of <Ref Oper="Position"/>,
##      the method that is available for duplicate-free lists suffices.
##  </Item>
##  </List>
##  <P/>
##  Further (data) components may be contained in <A>record</A>
##  which can be used by these function.
##  <P/>
##  If the first argument is a domain <A>D</A> then <A>enum</A> lists the
##  elements of <A>D</A> (in general <A>enum</A> is <E>not</E> sorted),
##  and methods for <Ref Attr="Length"/>,
##  <Ref Oper="IsBound" Label="for a list index"/>,
##  and <Ref Oper="PrintObj"/> may use <A>D</A>.
##  <!-- is this really true for Length?-->
##  <P/>
##  If one wants to describe the result without creating a domain then the
##  elements are given implicitly by the functions in <A>record</A>,
##  and the first argument must be a family <A>Fam</A> which will become the
##  family of <A>enum</A>;
##  if <A>enum</A> is not homogeneous then <A>Fam</A> must be
##  <C>ListsFamily</C>,
##  otherwise it must be the collections family of any element in <A>enum</A>.
##  In this case, additionally the following component in <A>record</A> is
##  needed.
##  <P/>
##  <List>
##  <Mark><C>Length</C></Mark>
##  <Item>
##      a function taking the argument <A>enum</A>,
##      which returns the length of <A>enum</A>
##      (see&nbsp;<Ref Attr="Length"/>).
##  </Item>
##  </List>
##  <P/>
##  The following components are optional; they are used if they are present
##  but default methods are installed for the case that they are missing.
##  <List>
##  <Mark><C>IsBound\[\]</C></Mark>
##  <Item>
##      a function taking two arguments <A>enum</A> and <A>k</A>,
##      which returns <C>IsBound( <A>enum</A>[ <A>k</A> ] )</C>
##      (see&nbsp;<Ref Sect="Basic Operations for Lists"/>);
##      if this component is missing then <Ref Attr="Length"/> is used for
##      computing the result,
##  </Item>
##  <Mark><C>Membership</C></Mark>
##  <Item>
##      a function taking two arguments <A>elm</A> and <A>enum</A>,
##      which returns <K>true</K> is <A>elm</A> is an element of <A>enum</A>,
##      and <K>false</K> otherwise
##      (see&nbsp;<Ref Sect="Basic Operations for Lists"/>);
##      if this component is missing then <C>NumberElement</C> is used
##      for computing the result,
##  </Item>
##  <Mark><C>AsList</C></Mark>
##  <Item>
##      a function taking one argument <A>enum</A>, which returns a list with
##      the property that the access to each of its elements will take
##      roughly the same time
##      (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>);
##      if this component is missing then
##      <Ref Attr="ConstantTimeAccessList"/> is used for computing the result,
##  </Item>
##  <Mark><C>ViewObj</C> and <C>PrintObj</C></Mark>
##  <Item>
##      two functions that print what one wants to be printed when
##      <C>View( <A>enum</A> )</C> or <C>Print( <A>enum</A> )</C> is called
##      (see&nbsp;<Ref Sect="View and Print"/>),
##      if the <C>ViewObj</C> component is missing then the <C>PrintObj</C>
##      method is used as a default.
##  </Item>
##  </List>
##  <P/>
##  If the result is known to have additional properties such as being
##  strictly sorted (see&nbsp;<Ref Prop="IsSSortedList"/>) then it can be
##  useful to set these properties after the construction of the enumerator,
##  before it is used for the first time.
##  And in the case that a new sorted enumerator of a domain is implemented
##  via <Ref Func="EnumeratorByFunctions" Label="for a domain and a record"/>,
##  and this construction is
##  installed as a method for the operation <Ref Attr="Enumerator"/>,
##  then it should be installed also as a method for
##  <Ref Attr="EnumeratorSorted"/>.
##  <P/>
##  Note that it is <E>not</E> checked that
##  <Ref Func="EnumeratorByFunctions" Label="for a domain and a record"/>
##  really returns a dense and duplicate-free list.
##  <Ref Func="EnumeratorByFunctions" Label="for a domain and a record"/>
##  does <E>not</E> make a shallow copy of <A>record</A>,
##  this record is changed in place,
##  see&nbsp;<Ref Sect="Creating Objects"/>.
##  <P/>
##  It would be easy to implement a slightly generalized setup for
##  enumerators that need not be duplicate-free (where the three argument
##  version of <Ref Oper="Position"/> is supported),
##  but the resulting overhead for the methods seems not to be justified.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EnumeratorByFunctions" );


#############################################################################
##
#A  UnderlyingCollection( <enum> )
##
##  <ManSection>
##  <Attr Name="UnderlyingCollection" Arg='enum'/>
##
##  <Description>
##  An enumerator of a domain can delegate the task to compute its length to
##  <C>Size</C> for the underlying domain, and <C>ViewObj</C> and <C>PrintObj</C> methods
##  may refer to this domain.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "UnderlyingCollection", IsListOrCollection );


#############################################################################
##
#F  List( <list>[, <func>] )  . . . . . . .  list of elements of a collection
#F  List( <C> )
##
##  <#GAPDoc Label="List:list">
##  <ManSection>
##  <Func Name="List" Arg='list[, func]' Label="for a list (and a function)"/>
##
##  <Description>
##  This function returns a new mutable list <C>new</C> of the same length
##  as the list <A>list</A> (which may have holes). The entry <C>new[i]</C>
##  is unbound if <C><A>list</A>[i]</C> is unbound. Otherwise
##  <C>new[i] = <A>func</A>(<A>list</A>[i])</C>. If the argument <A>func</A> is
##  omitted, its default is <Ref Func="IdFunc"/>, so this function does the
##  same as <Ref Oper="ShallowCopy"/> (see also
##  <Ref Sect="Duplication of Lists"/>).
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>ListOp</C>.
##  <Index Key="ListOp"><C>ListOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> List( [1,2,3], i -> i^2 );
##  [ 1, 4, 9 ]
##  gap> List( [1..10], IsPrime );
##  [ false, true, true, false, true, false, true, false, false, false ]
##  gap> List([,1,,3,4], x-> x > 2);
##  [ , false,, true, true ]
##  ]]></Example>
##  <P/>
##  (See also <Ref Func="List" Label="for a collection"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <#GAPDoc Label="List:coll">
##  <ManSection>
##  <Func Name="List" Arg='C' Label="for a collection"/>
##
##  <Description>
##  For a collection <A>C</A> (see&nbsp;<Ref Chap="Collections"/>)
##  that is not a list, <Ref Func="List" Label="for a collection"/> returns
##  a new mutable list <A>new</A> such that <C>Length( <A>new</A> )</C>
##  is the number of different elements of <A>C</A>,
##  and <A>new</A> contains the different elements of <A>C</A> in an
##  unspecified order which may change for repeated calls.
##  <C><A>new</A>[<A>pos</A>]</C> executes in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <A>new</A> is proportional to its length.
##  The generic method for this case is
##  <C>ShallowCopy( Enumerator( <A>C</A> ) )</C>.
##  <!-- this is not reasonable since <C>ShallowCopy</C> need not guarantee to return-->
##  <!-- a constant time access list-->
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>ListOp</C>.
##  <Index Key="ListOp"><C>ListOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> l:= List( Group( (1,2,3) ) );
##  [ (), (1,3,2), (1,2,3) ]
##  gap> IsMutable( l );  IsSortedList( l );  IsConstantTimeAccessList( l );
##  true
##  false
##  true
##  ]]></Example>
##  <P/>
##  (See also <Ref Func="List" Label="for a list (and a function)"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "List" );
DeclareOperation( "ListOp", [ IsListOrCollection ] );
DeclareOperation( "ListOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  SortedList( <C> )
#O  SortedList( <list> )
##
##  <#GAPDoc Label="SortedList">
##  <ManSection>
##  <Oper Name="SortedList" Arg='listorcoll[, func]'/>
##
##  <Description>
##  <Ref Oper="SortedList"/> returns a new mutable and dense list <A>new</A>.
##  The argument must be a collection or list <A>listorcoll</A> which may
##  contain holes but whose elements lie in the same family
##  (see&nbsp;<Ref Sect="Families"/>).
##  <C>Length( <A>new</A> )</C> is the number of elements of
##  <A>listorcoll</A>,
##  and <A>new</A> contains the elements in sorted order,
##  w.r.t.&nbsp;<C>&lt;</C> or <A>func</A> if it is specified.
##  For details, please refer to <Ref Oper="Sort"/>.
##  <C><A>new</A>[<A>pos</A>]</C> executes in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <A>new</A> in memory is proportional to its length.
##  <P/>
##  <Example><![CDATA[
##  gap> l:= SortedList( Group( (1,2,3) ) );
##  [ (), (1,2,3), (1,3,2) ]
##  gap> IsMutable( l );  IsSortedList( l );  IsConstantTimeAccessList( l );
##  true
##  true
##  true
##  gap> SortedList( [ 1, 2, 1,, 3, 2 ] );
##  [ 1, 1, 2, 2, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SortedList", [ IsListOrCollection ] );
DeclareOperation( "SortedList", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  SSortedList( <C>[, <fun>] ) . . . . . . . set of elements of a collection
#O  SSortedList( <list>[, <fun>] )  . . . . . . . . set of elements of a list
#O  Set( <C>[, <fun>] )
##
##  <#GAPDoc Label="SSortedList">
##  <ManSection>
##  <Oper Name="SSortedList" Arg='listorcoll[, fun]'/>
##  <Oper Name="Set" Arg='C[, fun]'/>
##
##  <Description>
##  <Ref Oper="SSortedList"/> (<Q>strictly sorted list</Q>) returns a new
##  dense, mutable, and duplicate free list <A>new</A>.
##  The argument must be a collection or list <A>listorcoll</A>
##  which may contain holes.
##  <P/>
##  If the optional argument <A>fun</A> is not given then
##  <C>Length( <A>new</A> )</C> is the number of different elements of
##  <A>listorcoll</A>,
##  and <A>new</A> contains the different elements in strictly sorted order,
##  w.r.t.&nbsp;<Ref Oper="\&lt;"/>.
##  For that, any two entries of <A>listorcoll</A> must be comparable via
##  <Ref Oper="\&lt;"/>.
##  (Typically, the entries lie in the same family,
##  see&nbsp;<Ref Sect="Families"/>.)
##  <P/>
##  If <A>fun</A> is given then it must be a unary function.
##  In this case, <A>fun</A> is applied to all elements of <A>listorcoll</A>,
##  <A>new</A> contains the different return values in strictly sorted order,
##  and <C>Length( <A>new</A> )</C> is the number of different such values.
##  For that, any two return values must be comparable via
##  <Ref Oper="\&lt;"/>.
##  <P/>
##  <C><A>new</A>[<A>pos</A>]</C> executes in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <A>new</A> in memory is proportional to its length.
##  <P/>
##  <Ref Oper="Set"/> is simply a synonym for <Ref Oper="SSortedList"/>.
##  <!-- <P/> -->
##  <!--  For collections that are not lists, the default method is-->
##  <!--  <C>ShallowCopy( EnumeratorSorted( <A>C</A> ) )</C>.-->
##  <P/>
##  <Example><![CDATA[
##  gap> l:= SSortedList( Group( (1,2,3) ) );
##  [ (), (1,2,3), (1,3,2) ]
##  gap> IsMutable( l );  IsSSortedList( l );  IsConstantTimeAccessList( l );
##  true
##  true
##  true
##  gap> SSortedList( Group( (1,2,3) ), Order );
##  [ 1, 3 ]
##  gap> SSortedList( [ 1, 2, 1,, 3, 2 ] );
##  [ 1, 2, 3 ]
##  gap> SSortedList( [ 1, 2, 1,, 3, 2 ], x -> x^2 );
##  [ 1, 4, 9 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SSortedList", [ IsListOrCollection ] );
DeclareOperation( "SSortedList", [ IsListOrCollection, IsFunction ] );

DeclareSynonym( "Set", SSortedList );


#############################################################################
##
#A  AsList( <C> ) . . . . . . . . . . . . .  list of elements of a collection
#A  AsList( <list> )  . . . . . . . . . . . . . .  list of elements of a list
##
##  <#GAPDoc Label="AsList">
##  <ManSection>
##  <Attr Name="AsList" Arg='listorcoll'/>
##
##  <Description>
##  <Ref Attr="AsList"/> returns a immutable list <A>imm</A>.
##  If the argument is a list (which may contain holes),
##  then <C>Length( <A>imm</A> )</C> is the <Ref Attr="Length"/> value of
##  this list,
##  and <A>imm</A> contains the elements (and holes) of the list
##  in the same order.
##  If the argument is a collection that is not a list,
##  then <C>Length( <A>imm</A> )</C> is the number of different elements
##  of this collection, and <A>imm</A> contains the different elements of
##  the collection in an unspecified order,
##  which may change for repeated calls of <Ref Attr="AsList"/>.
##  <C><A>imm</A>[<A>pos</A>]</C> executes in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <A>imm</A> in memory is proportional to its length.
##  <P/>
##  If you expect to do many element tests in the resulting list, it might
##  be worth to use a sorted list instead, using <Ref Attr="AsSSortedList"/>.
##  <!-- <P/> -->
##  <!--  For both lists and collections, the default method is-->
##  <!--  <C>ConstantTimeAccessList( Enumerator( <A>C</A> ) )</C>.-->
##  <P/>
##  <Example><![CDATA[
##  gap> l:= AsList( [ 1, 3, 3,, 2 ] );
##  [ 1, 3, 3,, 2 ]
##  gap> IsMutable( l );  IsSortedList( l );  IsConstantTimeAccessList( l );
##  false
##  false
##  true
##  gap> AsList( Group( (1,2,3), (1,2) ) );
##  [ (), (2,3), (1,3,2), (1,3), (1,2,3), (1,2) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsList", IsListOrCollection );


#############################################################################
##
#A  AsSortedList( <C> )
#A  AsSortedList( <list> )
##
##  <#GAPDoc Label="AsSortedList">
##  <ManSection>
##  <Attr Name="AsSortedList" Arg='listorcoll'/>
##
##  <Description>
##  <Ref Attr="AsSortedList"/> returns a dense and immutable list <A>imm</A>.
##  The argument must be a collection or list <A>listorcoll</A>
##  which may contain holes but whose elements lie in the same family
##  (see&nbsp;<Ref Sect="Families"/>).
##  <C>Length( <A>imm</A> )</C> is the number of elements of the argument,
##  and <A>imm</A> contains the elements in sorted order,
##  w.r.t.&nbsp;<C>&lt;=</C>.
##  <C><A>new</A>[<A>pos</A>]</C> executes in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <A>imm</A> in memory is proportional to its length.
##  <P/>
##  The only difference to the operation <Ref Oper="SortedList"/>
##  is that <Ref Attr="AsSortedList"/> returns an <E>immutable</E> list.
##  <P/>
##  <Example><![CDATA[
##  gap> l:= AsSortedList( [ 1, 3, 3,, 2 ] );
##  [ 1, 2, 3, 3 ]
##  gap> IsMutable( l );  IsSortedList( l );  IsConstantTimeAccessList( l );
##  false
##  true
##  true
##  gap> IsSSortedList( l );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsSortedList", IsListOrCollection );


#############################################################################
##
#A  AsSSortedList( <C> )  . . . . . . . . . . set of elements of a collection
#A  AsSSortedList( <list> ) . . . . . . . . . . . . set of elements of a list
#A  AsSet( <C> )
##
##  <#GAPDoc Label="AsSSortedList">
##  <ManSection>
##  <Attr Name="AsSSortedList" Arg='listorcoll'/>
##  <Attr Name="AsSet" Arg='listorcoll'/>
##
##  <Description>
##  <Index Subkey="of a list or collection">elements</Index>
##  <Ref Attr="AsSSortedList"/> (<Q>as strictly sorted list</Q>) returns
##  a dense, immutable, and duplicate free list <A>imm</A>.
##  The argument must be a collection or list <A>listorcoll</A>
##  which may contain holes but whose elements lie in the same family
##  (see&nbsp;<Ref Sect="Families"/>).
##  <C>Length( <A>imm</A> )</C> is the number of different elements
##  of <A>listorcoll</A>,
##  and <A>imm</A> contains the different elements in strictly sorted order,
##  w.r.t.&nbsp;<Ref Oper="\&lt;"/>.
##  <C><A>imm</A>[<A>pos</A>]</C> executes in constant time
##  (see&nbsp;<Ref Filt="IsConstantTimeAccessList"/>),
##  and the size of <A>imm</A> in memory is proportional to its length.
##  <P/>
##  Because the comparisons required for sorting can be very expensive for
##  some kinds of objects, you should use <Ref Attr="AsList"/> instead
##  if you do not require the result to be sorted.
##  <P/>
##  The only difference to the operation <Ref Oper="SSortedList"/>
##  is that <Ref Attr="AsSSortedList"/> returns an <E>immutable</E> list.
##  <P/>
##  <Ref Attr="AsSet"/> is simply a synonym for <Ref Attr="AsSSortedList"/>.
##  <P/>
##  In general a function that returns a set of elements is free, in fact
##  encouraged, to return a domain instead of the proper set of its elements.
##  This allows one to keep a given structure, and moreover the
##  representation by a domain object is usually more space efficient.
##  <Ref Attr="AsSSortedList"/> must of course <E>not</E> do this,
##  its only purpose is to create the proper set of elements.
##  <!-- <P/> -->
##  <!--  For both lists and collections, the default method is-->
##  <!--  <C>ConstantTimeAccessList( EnumeratorSorted( <A>C</A> ) )</C>.-->
##  <P/>
##  <Example><![CDATA[
##  gap> l:= AsSSortedList( l );
##  [ 1, 2, 3 ]
##  gap> IsMutable( l );  IsSSortedList( l );  IsConstantTimeAccessList( l );
##  false
##  true
##  true
##  gap> AsSSortedList( Group( (1,2,3), (1,2) ) );
##  [ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsSSortedList", IsListOrCollection );
DeclareSynonym( "AsSet", AsSSortedList );


#############################################################################
##
#A  AsSSortedListNonstored( <C> )
##
##  <ManSection>
##  <Attr Name="AsSSortedListNonstored" Arg='C'/>
##
##  <Description>
##  returns the <Ref Func="AsSSortedList"/> value of the list or collection
##  <A>C</A> but ensures that this list
##  (nor a permutation or substantial subset) will not be
##  stored in attributes of <A>C</A> unless such a list is already stored.
##  This permits to obtain an element list once
##  without danger of clogging up memory in the long run.
##  <P/>
##  Because of this guarantee of nonstorage, methods for
##  <Ref Func="AsSSortedListNonstored"/> may not default to
##  <Ref Func="AsSSortedList"/>, but only vice versa.
##  </Description>
##  </ManSection>
##
DeclareOperation( "AsSSortedListNonstored", [IsListOrCollection] );


#############################################################################
##
#F  Elements( <C> )
##
##  <#GAPDoc Label="Elements">
##  <ManSection>
##  <Func Name="Elements" Arg='C'/>
##
##  <Description>
##  <Ref Func="Elements"/> does the same as <Ref Attr="AsSSortedList"/>,
##  that is, the return value is a strictly sorted list of the elements in
##  the list or collection <A>C</A>.
##  <P/>
##  <Ref Func="Elements"/> is only supported for backwards compatibility.
##  In many situations, the sortedness of the <Q>element list</Q> for a
##  collection is in fact not needed, and one can save a lot of time by
##  asking for a list that is <E>not</E> necessarily sorted,
##  using <Ref Attr="AsList"/>.
##  If one is really interested in the strictly sorted list of elements in
##  <A>C</A> then one should use <Ref Attr="AsSet"/> or
##  <Ref Attr="AsSSortedList"/> instead.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Elements" );


#############################################################################
##
#F  Sum( <list>[, <init>] ) . . . . . . . . . . sum of the elements of a list
#F  Sum( <C>[, <init>] )  . . . . . . . . sum of the elements of a collection
#F  Sum( <list>, <func>[, <init>] ) . . . . .  sum of images under a function
#F  Sum( <C>, <func>[, <init>] )  . . . . . .  sum of images under a function
##
##  <#GAPDoc Label="Sum">
##  <ManSection>
##  <Func Name="Sum" Arg='listorcoll[, func][, init]'/>
##
##  <Description>
##  Called with one argument, a dense list or collection <A>listorcoll</A>,
##  <Ref Func="Sum"/> returns the sum of the elements of <A>listorcoll</A>
##  (see&nbsp;<Ref Chap="Collections"/>).
##  <P/>
##  Called with a dense list or collection <A>listorcoll</A> and a function
##  <A>func</A>, which must be a function taking one argument,
##  <Ref Func="Sum"/> applies the function <A>func</A>
##  to the elements of <A>listorcoll</A>, and returns the sum of the results.
##  In either case <Ref Func="Sum"/> returns <C>0</C> if the first argument
##  is empty.
##  <P/>
##  The general rules for arithmetic operations apply
##  (see&nbsp;<Ref Sect="Mutability Status and List Arithmetic"/>),
##  so the result is immutable if and only if all summands are immutable.
##  <P/>
##  If <A>listorcoll</A> contains exactly one element then this element
##  (or its image under <A>func</A> if applicable) itself is returned,
##  not a shallow copy of this element.
##  <P/>
##  If an additional initial value <A>init</A> is given,
##  <Ref Func="Sum"/> returns the sum of <A>init</A> and the elements of the
##  first argument resp.&nbsp;of their images under the function <A>func</A>.
##  This is useful for example if the first argument is empty and a different
##  zero than <C>0</C> is desired, in which case <A>init</A> is returned.
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>SumOp</C>.
##  <Index Key="SumOp"><C>SumOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> Sum( [ 2, 3, 5, 7, 11, 13, 17, 19 ] );
##  77
##  gap> Sum( [1..10], x->x^2 );
##  385
##  gap> Sum( [ [1,2], [3,4], [5,6] ] );
##  [ 9, 12 ]
##  gap> Sum( GF(8) );
##  0*Z(2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "Sum" );
DeclareOperation( "SumOp", [ IsListOrCollection ] );


#############################################################################
##
#F  Product( <list>[, <init>] ) . . . . . . product of the elements of a list
#F  Product( <C>[, <init>] )  . . . . product of the elements of a collection
#F  Product( <list>, <func>[, <init>] ) .  product of images under a function
#F  Product( <C>, <func>[, <init>] )  . .  product of images under a function
##
##  <#GAPDoc Label="Product">
##  <ManSection>
##  <Func Name="Product" Arg='listorcoll[, func][, init]'/>
##
##  <Description>
##  Called with one argument, a dense list or collection <A>listorcoll</A>,
##  <Ref Func="Product"/> returns the product of the elements of
##  <A>listorcoll</A> (see&nbsp;<Ref Chap="Collections"/>).
##  <P/>
##  Called with a dense list or collection <A>listorcoll</A> and a function
##  <A>func</A>, which must be a function taking one argument,
##  <Ref Func="Product"/> applies the function <A>func</A>
##  to the elements of <A>listorcoll</A>, and returns the product of the
##  results.
##  In either case <Ref Func="Product"/> returns <C>1</C> if the first
##  argument is empty.
##  <P/>
##  The general rules for arithmetic operations apply
##  (see&nbsp;<Ref Sect="Mutability Status and List Arithmetic"/>),
##  so the result is immutable if and only if all summands are immutable.
##  <P/>
##  If <A>listorcoll</A> contains exactly one element then this element
##  (or its image under <A>func</A> if applicable) itself is returned,
##  not a shallow copy of this element.
##  <P/>
##  If an additional initial value <A>init</A> is given,
##  <Ref Func="Product"/> returns the product of <A>init</A> and the elements
##  of the first argument resp.&nbsp;of their images under the function
##  <A>func</A>.
##  This is useful for example if the first argument is empty and a different
##  identity than <C>1</C> is desired, in which case <A>init</A> is returned.
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>ProductOp</C>.
##  <Index Key="ProductOp"><C>ProductOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> Product( [ 2, 3, 5, 7, 11, 13, 17, 19 ] );
##  9699690
##  gap> Product( [1..10], x->x^2 );
##  13168189440000
##  gap> Product( [ (1,2), (1,3), (1,4), (2,3), (2,4), (3,4) ] );
##  (1,4)(2,3)
##  gap> Product( GF(8) );
##  0*Z(2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "Product" );
DeclareOperation( "ProductOp", [ IsListOrCollection ] );


#############################################################################
##
#F  Filtered( <list>, <func> )  . . . . extract elements that have a property
#F  Filtered( <C>, <func> ) . . . . . . extract elements that have a property
##
##  <#GAPDoc Label="Filtered">
##  <ManSection>
##  <Func Name="Filtered" Arg='listorcoll, func'/>
##
##  <Description>
##  returns a new list that contains those elements of the list or collection
##  <A>listorcoll</A> (see&nbsp;<Ref Chap="Collections"/>), respectively,
##  for which the unary function <A>func</A> returns <K>true</K>.
##  <P/>
##  If the first argument is a list, the order of the elements in the result
##  is the same as the order of the corresponding elements of this list.
##  If an element for which <A>func</A> returns <K>true</K> appears several
##  times in the list it will also appear the same number of times
##  in the result.
##  The argument list may contain holes,
##  they are ignored by <Ref Func="Filtered"/>.
##  <P/>
##  For each element of <A>listorcoll</A>,
##  <A>func</A> must return either <K>true</K> or <K>false</K>,
##  otherwise an error is signalled.
##  <P/>
##  The result is a new list that is not identical to any other list.
##  The elements of that list however are identical to the corresponding
##  elements of the argument list (see&nbsp;<Ref Sect="Identical Lists"/>).
##  <P/>
##  List assignment using the operator <Ref Oper="\{\}"/>
##  (see&nbsp;<Ref Sect="List Assignment"/>) can be used to extract
##  elements of a list according to indices given in another list.
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>FilteredOp</C>.
##  <Index Key="FilteredOp"><C>FilteredOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> Filtered( [1..20], IsPrime );
##  [ 2, 3, 5, 7, 11, 13, 17, 19 ]
##  gap> Filtered( [ 1, 3, 4, -4, 4, 7, 10, 6 ], IsPrimePowerInt );
##  [ 3, 4, 4, 7 ]
##  gap> Filtered( [ 1, 3, 4, -4, 4, 7, 10, 6 ],
##  >              n -> IsPrimePowerInt(n) and n mod 2 <> 0 );
##  [ 3, 7 ]
##  gap> Filtered( Group( (1,2), (1,2,3) ), x -> Order( x ) = 2 );
##  [ (2,3), (1,2), (1,3) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "Filtered" );
DeclareOperation( "FilteredOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#F  Number( <list> )
#F  Number( <list>, <func> )  . . . . . . count elements that have a property
#F  Number( <C>, <func> ) . . . . . . . . count elements that have a property
##
##  <#GAPDoc Label="Number">
##  <ManSection>
##  <Func Name="Number" Arg='listorcoll[, func]'/>
##
##  <Description>
##  Called with a list <A>listorcoll</A>, <Ref Func="Number"/> returns the
##  number of bound entries in this list.
##  For dense lists <Ref Func="Number"/>, <Ref Attr="Length"/>,
##  and <Ref Attr="Size"/> return the same value;
##  for lists with holes <Ref Func="Number"/> returns the number of bound
##  entries, <Ref Attr="Length"/> returns the largest index of a bound entry,
##  and <Ref Attr="Size"/> signals an error.
##  <P/>
##  Called with two arguments, a list or collection <A>listorcoll</A> and a
##  unary function <A>func</A>, <Ref Func="Number"/> returns the number of
##  elements of <A>listorcoll</A> for which <A>func</A> returns <K>true</K>.
##  If an element for which <A>func</A> returns <K>true</K> appears several
##  times in <A>listorcoll</A> it will also be counted the same number of
##  times.
##  <P/>
##  For each element of <A>listorcoll</A>,
##  <A>func</A> must return either <K>true</K> or <K>false</K>,
##  otherwise an error is signalled.
##  <P/>
##  <Ref Func="Filtered"/> allows you to extract the elements of a list
##  that have a certain property.
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>NumberOp</C>.
##  <Index Key="NumberOp"><C>NumberOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> Number( [ 2, 3, 5, 7 ] );
##  4
##  gap> Number( [, 2, 3,, 5,, 7,,,, 11 ] );
##  5
##  gap> Number( [1..20], IsPrime );
##  8
##  gap> Number( [ 1, 3, 4, -4, 4, 7, 10, 6 ], IsPrimePowerInt );
##  4
##  gap> Number( [ 1, 3, 4, -4, 4, 7, 10, 6 ],
##  >            n -> IsPrimePowerInt(n) and n mod 2 <> 0 );
##  2
##  gap> Number( Group( (1,2), (1,2,3) ), x -> Order( x ) = 2 );
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "Number" );
DeclareOperation( "NumberOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#F  ForAll( <list>, <func> )
#F  ForAll( <C>, <func> )
##
##  <#GAPDoc Label="ForAll">
##  <ManSection>
##  <Func Name="ForAll" Arg='listorcoll, func'/>
##
##  <Description>
##  tests whether the unary function <A>func</A> returns <K>true</K>
##  for all elements in the list or collection <A>listorcoll</A>.
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>ForAllOp</C>.
##  <Index Key="ForAllOp"><C>ForAllOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> ForAll( [1..20], IsPrime );
##  false
##  gap> ForAll( [2,3,4,5,8,9], IsPrimePowerInt );
##  true
##  gap> ForAll( [2..14], n -> IsPrimePowerInt(n) or n mod 2 = 0 );
##  true
##  gap> ForAll( Group( (1,2), (1,2,3) ), i -> SignPerm(i) = 1 );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "ForAll" );
DeclareOperation( "ForAllOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#F  ForAny( <list>, <func> )
#F  ForAny( <C>, <func> )
##
##  <#GAPDoc Label="ForAny">
##  <ManSection>
##  <Func Name="ForAny" Arg='listorcoll, func'/>
##
##  <Description>
##  tests whether the unary function <A>func</A> returns <K>true</K>
##  for at least one element in the list or collection <A>listorcoll</A>.
##  <P/>
##  Developers who wish to adapt this for custom list or collection types need to
##  install suitable methods for the operation <C>ForAnyOp</C>.
##  <Index Key="ForAnyOp"><C>ForAnyOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> ForAny( [1..20], IsPrime );
##  true
##  gap> ForAny( [2,3,4,5,8,9], IsPrimePowerInt );
##  true
##  gap> ForAny( [2..14],
##  >    n -> IsPrimePowerInt(n) and n mod 5 = 0 and not IsPrime(n) );
##  false
##  gap> ForAny( Integers, i ->     i > 0
##  >                           and ForAll( [0,2..4], j -> IsPrime(i+j) ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "ForAny" );
DeclareOperation( "ForAnyOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  ListX( <arg1>, <arg2>, ... <argn>, <func> )
##
##  <#GAPDoc Label="ListX">
##  <ManSection>
##  <Func Name="ListX" Arg='arg1, arg2, ... argn, func'/>
##
##  <Description>
##  <Ref Func="ListX"/> returns a new list constructed from the arguments.
##  <P/>
##  Each of the arguments <A>arg1</A>, <A>arg2</A>, <M>\ldots</M> <A>argn</A>
##  must be one of the following:
##  <List>
##  <Mark>a list or collection</Mark>
##  <Item>
##      this introduces a new for-loop in the sequence of nested
##      for-loops and if-statements;
##  </Item>
##  <Mark>a function returning a list or collection</Mark>
##  <Item>
##      this introduces a new for-loop in the sequence of nested
##      for-loops and if-statements, where the loop-range depends on
##      the values of the outer loop-variables; or
##  </Item>
##  <Mark>a function returning <K>true</K> or <K>false</K></Mark>
##  <Item>
##      this introduces a new if-statement in the sequence of nested
##      for-loops and if-statements.
##  </Item>
##  </List>
##  <P/>
##  The last argument <A>func</A> must be a function,
##  it is applied to the values of the loop-variables
##  and the results are collected.
##  <P/>
##  Thus <C>ListX( <A>list</A>, <A>func</A> )</C> is the same as
##  <C>List( <A>list</A>, <A>func</A> )</C>,
##  and <C>ListX( <A>list</A>, <A>func</A>, x -> x )</C> is the same as
##  <C>Filtered( <A>list</A>, <A>func</A> )</C>.
##  <P/>
##  As a more elaborate example, assume <A>arg1</A> is a list or collection,
##  <A>arg2</A> is a function returning <K>true</K> or <K>false</K>,
##  <A>arg3</A> is a function returning a list or collection, and
##  <A>arg4</A> is another function returning <K>true</K> or <K>false</K>,
##  then
##  <P/>
##  <C><A>result</A> := ListX( <A>arg1</A>, <A>arg2</A>, <A>arg3</A>,
##  <A>arg4</A>, <A>func</A> );</C>
##  <P/>
##  is equivalent to
##  <P/>
##  <Listing><![CDATA[
##  result := [];
##  for v1 in arg1 do
##    if arg2( v1 ) then
##      for v2 in arg3( v1 ) do
##        if arg4( v1, v2 ) then
##          Add( result, func( v1, v2 ) );
##        fi;
##      od;
##    fi;
##  od;
##  ]]></Listing>
##  <P/>
##  The following example shows how <Ref Func="ListX"/> can be used to
##  compute all pairs and all strictly sorted pairs of elements in a list.
##  <P/>
##  <Example><![CDATA[
##  gap> l:= [ 1, 2, 3, 4 ];;
##  gap> pair:= function( x, y ) return [ x, y ]; end;;
##  gap> ListX( l, l, pair );
##  [ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 1 ], [ 2, 2 ],
##    [ 2, 3 ], [ 2, 4 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ],
##    [ 4, 1 ], [ 4, 2 ], [ 4, 3 ], [ 4, 4 ] ]
##  ]]></Example>
##  <P/>
##  In the following example, <Ref Oper="\&lt;"/> is the comparison
##  operation:
##  <P/>
##  <Example><![CDATA[
##  gap> ListX( l, l, \<, pair );
##  [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ListX" );


#############################################################################
##
#O  SetX( <arg1>, <arg2>, ... <func> )
##
##  <#GAPDoc Label="SetX">
##  <ManSection>
##  <Func Name="SetX" Arg='arg1, arg2, ... func'/>
##
##  <Description>
##  The only difference between <Ref Func="SetX"/> and <Ref Func="ListX"/>
##  is that the result list of <Ref Func="SetX"/> is strictly sorted.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SetX" );


#############################################################################
##
#O  SumX( <arg1>, <arg2>, ... <func> )
##
##  <#GAPDoc Label="SumX">
##  <ManSection>
##  <Func Name="SumX" Arg='arg1, arg2, ... func'/>
##
##  <Description>
##  <Ref Func="SumX"/> returns the sum of the elements in the list obtained
##  by <Ref Func="ListX"/> when this is called with the same arguments.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SumX" );


#############################################################################
##
#O  ProductX( <arg1>, <arg2>, ... <func> )
##
##  <#GAPDoc Label="ProductX">
##  <ManSection>
##  <Func Name="ProductX" Arg='arg1, arg2, ... func'/>
##
##  <Description>
##  <Ref Func="ProductX"/> returns the product of the elements in the list
##  obtained by <Ref Func="ListX"/> when this is called with the same
##  arguments.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ProductX" );


#############################################################################
##
#O  Perform( <list>, <func>)
##
##  <#GAPDoc Label="Perform">
##  <ManSection>
##  <Func Name="Perform" Arg='list, func'/>
##
##  <Description>
##  <Ref Func="Perform"/> applies the function <A>func</A> to every element
##  of the list <A>list</A>, discarding any return values.
##  It does not return a value.
##  <P/>
##  <Example><![CDATA[
##  gap> l := [1, 2, 3];; Perform(l,
##  > function(x) if IsPrimeInt(x) then Print(x,"\n"); fi; end);
##  2
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Perform" );


#############################################################################
##
#O  IsSubset( <C1>, <C2> )  . . . . . . . . .  test for subset of collections
##
##  <#GAPDoc Label="IsSubset">
##  <ManSection>
##  <Oper Name="IsSubset" Arg='C1, C2'/>
##
##  <Description>
##  <Index Subkey="for collections">subset test</Index>
##  <Ref Oper="IsSubset"/> returns <K>true</K> if <A>C2</A>,
##  which must be a collection, is a <E>subset</E> of <A>C1</A>,
##  which also must be a collection, and <K>false</K> otherwise.
##  <P/>
##  <A>C2</A> is considered a subset of <A>C1</A> if and only if each element
##  of <A>C2</A> is also an element of <A>C1</A>.
##  That is <Ref Oper="IsSubset"/> behaves as if implemented as
##  <C>IsSubsetSet( AsSSortedList( <A>C1</A> ), AsSSortedList( <A>C2</A> ) )</C>,
##  except that it will also sometimes, but not always,
##  work for infinite collections,
##  and that it will usually work much faster than the above definition.
##  Either argument may also be a proper set
##  (see&nbsp;<Ref Sect="Sorted Lists and Sets"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> IsSubset( Rationals, Integers );
##  true
##  gap> IsSubset( Integers, [ 1, 2, 3 ] );
##  true
##  gap> IsSubset( Group( (1,2,3,4) ), [ (1,2,3) ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsSubset", [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#F  Intersection( <C1>, <C2>, ... ) . . . . . . . intersection of collections
#F  Intersection( <list> )  . . . . . . . . . . . intersection of collections
#O  Intersection2( <C1>, <C2> ) . . . . . . . . . intersection of collections
##
##  <#GAPDoc Label="Intersection">
##  <ManSection>
##  <Heading>Intersection</Heading>
##  <Func Name="Intersection" Arg='C1, C2, ...'
##   Label="for various collections"/>
##  <Func Name="Intersection" Arg='list' Label="for a list"/>
##  <Oper Name="Intersection2" Arg='C1, C2'/>
##
##  <Description>
##  <Index Subkey="of collections">intersection</Index>
##  In the first form
##  <Ref Func="Intersection" Label="for various collections"/> returns the
##  intersection of the collections <A>C1</A>, <A>C2</A>, etc.
##  In the second form <A>list</A> must be a <E>nonempty</E> list of
##  collections and <Ref Func="Intersection" Label="for a list"/> returns
##  the intersection of those collections.
##  Each argument or element of <A>list</A> respectively may also be a
##  homogeneous list that is not a proper set,
##  in which case <Ref Func="Intersection" Label="for a list"/> silently
##  applies <Ref Oper="Set"/> to it first.
##  <P/>
##  The result of <Ref Func="Intersection" Label="for a list"/> is the set
##  of elements that lie in every of the collections <A>C1</A>, <A>C2</A>,
##  etc.
##  If the result is a list then it is mutable and new, i.e., not identical
##  to any of <A>C1</A>, <A>C2</A>, etc.
##  <P/>
##  Methods can be installed for the operation <Ref Oper="Intersection2"/>
##  that takes only two arguments.
##  <Ref Func="Intersection" Label="for a list"/> calls
##  <Ref Oper="Intersection2"/>.
##  <P/>
##  Methods for <Ref Oper="Intersection2"/> should try to maintain as much
##  structure as possible, for example the intersection of two permutation
##  groups is again a permutation group.
##  <P/>
##  <Example><![CDATA[
##  gap> # this is one of the rare cases where the intersection of two
##  gap> # infinite domains works ('CF' is a shorthand for 'CyclotomicField'):
##  gap> Intersection( CyclotomicField(9), CyclotomicField(12) );
##  CF(3)
##  gap> D12 := Group( (2,6)(3,5), (1,2)(3,6)(4,5) );;
##  gap> Intersection( D12, Group( (1,2), (1,2,3,4,5) ) );
##  Group([ (1,5)(2,4) ])
##  gap> Intersection( D12, [ (1,3)(4,6), (1,2)(3,4) ] )
##  >    ;  # note that the second argument is not a proper set
##  [ (1,3)(4,6) ]
##  gap> # although the result is mathematically a group it is returned as a
##  gap> # proper set because the second argument is not regarded as a group:
##  gap> Intersection( D12, [ (), (1,2)(3,4), (1,3)(4,6), (1,4)(5,6) ] );
##  [ (), (1,3)(4,6) ]
##  gap> Intersection( Group( () ), [1,2,3] );
##  [  ]
##  gap> Intersection( [2,4,6,8,10], [3,6,9,12,15], [5,10,15,20,25] )
##  >    ;  # two or more lists or collections as arguments are legal
##  [  ]
##  gap> Intersection( [ [1,2,4], [2,3,4], [1,3,4] ] )
##  >    ;  # or one list of lists or collections
##  [ 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Intersection" );

DeclareOperation( "Intersection2",
    [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#F  Union( <C1>, <C2>, ... )  . . . . . . . . . . . . .  union of collections
#F  Union( <list> ) . . . . . . . . . . . . . . . . . .  union of collections
#O  Union2( <C1>, <C2> )  . . . . . . . . . . . . . . .  union of collections
##
##  <#GAPDoc Label="Union">
##  <ManSection>
##  <Heading>Union</Heading>
##  <Func Name="Union" Arg='C1, C2, ...' Label="for various collections"/>
##  <Func Name="Union" Arg='list' Label="for a list"/>
##  <Oper Name="Union2" Arg='C1, C2'/>
##
##  <Description>
##  <Index Subkey="of collections">union</Index>
##  In the first form <Ref Func="Union" Label="for various collections"/>
##  returns the union of the collections <A>C1</A>, <A>C2</A>, etc.
##  In the second form <A>list</A> must be a list of collections
##  and <Ref Func="Union" Label="for a list"/> returns the union of those
##  collections.
##  Each argument or element of <A>list</A> respectively may also be a
##  homogeneous list that is not a proper set,
##  in which case <Ref Func="Union" Label="for a list"/> silently applies
##  <Ref Oper="Set"/> to it first.
##  <P/>
##  The result of <Ref Func="Union" Label="for a list"/> is the set of
##  elements that lie in any of the collections <A>C1</A>, <A>C2</A>, etc.
##  If the result is a list then it is mutable and new, i.e., not identical
##  to any of <A>C1</A>, <A>C2</A>, etc.
##  <P/>
##  Methods can be installed for the operation <Ref Oper="Union2"/>
##  that takes only two arguments.
##  <Ref Func="Union" Label="for a list"/> calls <Ref Oper="Union2"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> Union( [ (1,2,3), (1,2,3,4) ], Group( (1,2,3), (1,2) ) );
##  [ (), (2,3), (1,2), (1,2,3), (1,2,3,4), (1,3,2), (1,3) ]
##  gap> Union( [2,4,6,8,10], [3,6,9,12,15], [5,10,15,20,25] )
##  >    ;  # two or more lists or collections as arguments are legal
##  [ 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 20, 25 ]
##  gap> Union( [ [1,2,4], [2,3,4], [1,3,4] ] )
##  >    ;  # or one list of lists or collections
##  [ 1 .. 4 ]
##  gap> Union( [ ] );
##  [  ]
##  ]]></Example><P/>
##  When computing the Union of lists or sets of small integers and ranges,
##  every attempt is made to return the result as a range and to avoid expanding
##  ranges provided as input.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Union" );

DeclareOperation( "Union2", [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#O  Difference( <C1>, <C2> )  . . . . . . . . . . . difference of collections
##
##  <#GAPDoc Label="Difference">
##  <ManSection>
##  <Oper Name="Difference" Arg='C1, C2'/>
##
##  <Description>
##  <Index Subkey="of collections">set difference</Index>
##  <Ref Oper="Difference"/> returns the set difference of the collections
##  <A>C1</A> and <A>C2</A>.
##  Either argument may also be a homogeneous list that is not a proper set,
##  in which case <Ref Oper="Difference"/> silently applies <Ref Oper="Set"/>
##  to it first.
##  <P/>
##  The result of <Ref Oper="Difference"/> is the set of elements that lie in
##  <A>C1</A> but not in <A>C2</A>.
##  Note that <A>C2</A> need not be a subset of <A>C1</A>.
##  The elements of <A>C2</A>, however, that are not elements of <A>C1</A>
##  play no role for the result.
##  If the result is a list then it is mutable and new, i.e., not identical
##  to <A>C1</A> or <A>C2</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> Difference( [ (1,2,3), (1,2,3,4) ], Group( (1,2,3), (1,2) ) );
##  [ (1,2,3,4) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Difference", [ IsListOrCollection, IsListOrCollection ] );


#############################################################################
##
#P  CanEasilyCompareElements( <obj> )
#F  CanEasilyCompareElementsFamily( <fam> )
#P  CanEasilySortElements( <obj> )
#F  CanEasilySortElementsFamily( <fam> )
##
##  <#GAPDoc Label="CanEasilyCompareElements">
##  <ManSection>
##  <Prop Name="CanEasilyCompareElements" Arg='obj'/>
##  <Func Name="CanEasilyCompareElementsFamily" Arg='fam'/>
##  <Prop Name="CanEasilySortElements" Arg='obj'/>
##  <Func Name="CanEasilySortElementsFamily" Arg='fam'/>
##
##  <Description>
##  For some objects a <Q>normal form</Q> is hard to compute
##  and thus equality of elements of a domain might be expensive to test.
##  Therefore &GAP; provides a (slightly technical) property with which an
##  algorithm can test whether an efficient equality test is available
##  for elements of a certain kind.
##  <P/>
##  <Ref Prop="CanEasilyCompareElements"/> indicates whether the elements in
##  the family <A>fam</A> of <A>obj</A> can be easily compared with
##  <Ref Oper="\="/>.
##  <P/>
##  The default method for this property is to ask the family of <A>obj</A>,
##  the default method for the family is to return <K>false</K>.
##  <P/>
##  The ability to compare elements may depend on the successful computation
##  of certain information. (For example for finitely presented groups it
##  might depend on the knowledge of a faithful permutation representation.)
##  This information might change over time and thus it might not be a good
##  idea to store a value <K>false</K> too early in a family. Instead the
##  function <Ref Func="CanEasilyCompareElementsFamily"/> should be called
##  for the family of <A>obj</A> which returns <K>false</K> if the value of
##  <Ref Prop="CanEasilyCompareElements"/> is not known for the family
##  without computing it. (This is in fact what the above mentioned family
##  dispatch does.)
##  <P/>
##  If a family knows ab initio that it can compare elements this property
##  should be set as implied filter <E>and</E> filter for the family
##  (the 3rd and 4th argument of <Ref Func="NewFamily"/>
##  respectively).
##  This guarantees that code which directly asks the family gets a right
##  answer.
##  <P/>
##  The property <Ref Prop="CanEasilySortElements"/> and the function
##  <Ref Func="CanEasilySortElementsFamily"/> behave exactly in the same way,
##  except that they indicate that objects can be compared via
##  <Ref Oper="\&lt;"/>.
##  This property implies <Ref Prop="CanEasilyCompareElements"/>,
##  as the ordering must be total.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="CanComputeIsSubset">
##  <ManSection>
##  <Oper Name="CanComputeIsSubset" Arg='A, B'/>
##
##  <Description>
##  This filter indicates that &GAP; can test (via <Ref Oper="IsSubset"/>)
##  whether <A>B</A> is a subset of <A>A</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CanComputeIsSubset", [IsObject,IsObject] );


#############################################################################
##
#F  CanComputeSize( <dom> )
##
##  <#GAPDoc Label="CanComputeSize">
##  <ManSection>
##  <Filt Name="CanComputeSize" Arg='dom'/>
##
##  <Description>
##  This filter indicates that we know that the size of the domain <A>dom</A>
##  (which might be <Ref Var="infinity"/>) can be computed reasonably
##  easily. It doesn't imply as quick a computation as <C>HasSize</C> would
##  but its absence does not imply that the size cannot be computed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter( "CanComputeSize" );

InstallTrueMethod( CanComputeSize, HasSize );
