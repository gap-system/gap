#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert, Werner Nickel.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the definition of operations and functions for lists.
##


#############################################################################
##
#C  IsList( <obj> ) . . . . . . . . . . . . . . . test if an object is a list
##
##  <#GAPDoc Label="IsList">
##  <ManSection>
##  <Filt Name="IsList" Arg='obj' Type='Category'/>
##
##  <Description>
##  tests whether <A>obj</A> is a list.
##  <P/>
##  <Example><![CDATA[
##  gap> IsList( [ 1, 3, 5, 7 ] );  IsList( 1 );
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsList", IsListOrCollection, IS_LIST );


#############################################################################
##
#V  ListsFamily . . . . . . . . . . . . . . . . . . . . . . . family of lists
##
##  <ManSection>
##  <Var Name="ListsFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "ListsFamily", NewFamily( "ListsFamily", IsList ) );


#############################################################################
##
#R  IsPlistRep  . . . . . . . . . . . . . . . . representation of plain lists
##
##  <#GAPDoc Label="IsPlistRep">
##  <ManSection>
##  <Filt Name="IsPlistRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  &GAP; lists created by entering comma separated values in square brackets
##  are usually represented internally as so-called <E>plain lists</E>.
##  Other representations of lists are <Ref Filt="IsBlistRep"/>,
##  <Ref Filt="IsRangeRep"/>, <Ref Filt="IsStringRep"/>,
##  or the ones that are chosen for implementing enumerators,
##  see Section <Ref Sect="Enumerators"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> IsPlistRep( [ 1, 2, 3 ] );
##  true
##  gap> IsPlistRep( "abc" );
##  false
##  gap> IsPlistRep( [ 1 .. 5 ] );
##  false
##  gap> IsPlistRep( BlistList( [ 1 .. 5 ], [ 1 ] ) );
##  false
##  gap> IsPlistRep( 0 );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentationKernel( "IsPlistRep",
    IsInternalRep, IS_PLIST_REP );


#############################################################################
##
#C  IsConstantTimeAccessList( <list> )
##
##  <#GAPDoc Label="IsConstantTimeAccessList">
##  <ManSection>
##  <Filt Name="IsConstantTimeAccessList" Arg='list' Type='Category'/>
##
##  <Description>
##  This category indicates whether the access to each element of the list
##  <A>list</A> will take roughly the same time.
##  This is implied for example by <C>IsList and IsInternalRep</C>,
##  so all strings, Boolean lists, ranges, and internally represented plain
##  lists are in this category.
##  <P/>
##  But also other enumerators (see&nbsp;<Ref Sect="Enumerators"/>) can lie
##  in this category if they guarantee constant time access to their elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsConstantTimeAccessList", IsList );

InstallTrueMethod( IsConstantTimeAccessList, IsList and IsInternalRep );


#############################################################################
##
#P  IsSmallList . . . . . . . . . . . . . . .  lists of length at most $2^28$
#V  MAX_SIZE_LIST_INTERNAL
##
##  <ManSection>
##  <Prop Name="IsSmallList" Arg='obj'/>
##  <Var Name="MAX_SIZE_LIST_INTERNAL"/>
##
##  <Description>
##  We need this property to describe for which lists the default methods for
##  comparison, assignment, addition etc. are applicable.
##  Note that these methods call <C>LEN_LIST</C>,
##  and for that the list must be small.
##  Of course every internally represented list is small,
##  and every empty list is small.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsSmallList", IsList );
InstallTrueMethod( IsList, IsSmallList );

InstallTrueMethod( IsSmallList, IsList and IsInternalRep );
InstallTrueMethod( IsFinite, IsList and IsSmallList );
InstallTrueMethod( IsSmallList, IsList and IsEmpty );

BIND_GLOBAL( "MAX_SIZE_LIST_INTERNAL", 2^(8*GAPInfo.BytesPerVariable-4) - 1 );


#############################################################################
##
#A  Length( <list> )  . . . . . . . . . . . . . . . . . . .  length of a list
##
##  <#GAPDoc Label="Length">
##  <ManSection>
##  <Attr Name="Length" Arg='list'/>
##
##  <Description>
##  returns the <E>length</E> of the list <A>list</A>, which is defined to be
##  the index of the last bound entry in <A>list</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeKernel( "Length", IsList, LENGTH );
InstallTrueMethod(HasLength,IsPlistRep);


#############################################################################
##
#O  IsBound( <list>[<pos>] )  . . . . . . . . test for an element from a list
##
##  <#GAPDoc Label="IsBound_list">
##  <ManSection>
##  <Oper Name="IsBound" Arg='list[n]' Label="for a list index"/>
##
##  <Description>
##  <Ref Oper="IsBound" Label="for a list index"/> returns <K>true</K>
##  if the list <A>list</A> has an element at index <A>n</A>,
##  and <K>false</K> otherwise.
##  <A>list</A> must evaluate to a list, or to an object for which a suitable
##  method for <C>IsBound\[\]</C> has been installed, otherwise an error is signalled.
##  <P/>
##  <Example><![CDATA[
##  gap> l := [ , 2, 3, , 5, , 7, , , , 11 ];;
##  gap> IsBound( l[7] );
##  true
##  gap> IsBound( l[4] );
##  false
##  gap> IsBound( l[101] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "IsBound[]",
    [ IsList, IS_INT ],
    ISB_LIST );


#############################################################################
##
#o  <list>[<pos>] . . . . . . . . . . . . . . . select an element from a list
##
DeclareOperationKernel( "[]",
    [ IsList, IS_INT ],
    ELM_LIST );

#############################################################################
##
##  <#GAPDoc Label="GetWithDefault_list">
##  <ManSection>
##  <Oper Name="GetWithDefault" Arg='list, n, default'/>
##
##  <Description>
##  <Ref Oper="GetWithDefault"/> returns the <A>n</A>th element of the list
##  <A>list</A>, if <A>list</A> has a value at index <A>n</A>, and
##  <A>default</A> otherwise.
##  <P/>
##  While this method can be used on any list, it is particularly useful
##  for Weak Pointer lists <Ref Sect="Weak Pointer Objects"/> where the
##  value of the list can change.
##  <P/>
##  To distinguish between the <A>n</A>th element being unbound, or
##  <A>default</A> being in <A>list</A>, users can create a new mutable
##  object, such as a string. <Ref Func="IsIdenticalObj"/> returns
##  <K>false</K> for different mutable strings, even if their contents are
##  the same.
##
##  <Example><![CDATA[
##  gap> l := [1,2,,"a"];
##  [ 1, 2,, "a" ]
##  gap> newobj := "a";
##  "a"
##  gap> GetWithDefault(l, 2, newobj);
##  2
##  gap> GetWithDefault(l, 3, newobj);
##  "a"
##  gap> GetWithDefault(l, 4, newobj);
##  "a"
##  gap> IsIdenticalObj(GetWithDefault(l, 3, newobj), newobj);
##  true
##  gap> IsIdenticalObj(GetWithDefault(l, 4, newobj), newobj);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "GetWithDefault",
    [ IsList, IS_INT, IsObject ],
    ELM_DEFAULT_LIST );


#############################################################################
##
#o  <list>{<poss>}  . . . . . . . . . . . . . . . select elements from a list
##
DeclareOperationKernel( "{}",
    [ IsList, IsList ],
    ELMS_LIST );


#############################################################################
##
#O  Unbind( <list>[<n>] )
##
##  <#GAPDoc Label="Unbind_list">
##  <ManSection>
##  <Oper Name="Unbind" Arg='list[n]' Label="unbind a list entry"/>
##
##  <Description>
##  <Ref Oper="Unbind" Label="unbind a list entry"/> deletes the element with
##  index <A>n</A> in the mutable list <A>list</A>.  That is, after
##  execution of <Ref Oper="Unbind" Label="unbind a list entry"/>,
##  <A>list</A> no longer has an assigned value with index <A>n</A>.
##  Thus <Ref Oper="Unbind" Label="unbind a list entry"/> can be used to
##  produce holes in a list.
##  Note that it is not an error to unbind a nonexistent list element.
##  <A>list</A> must evaluate to a list, or to an object for which a suitable
##  method for <C>Unbind\[\]</C> has been installed, otherwise an error is signalled.
##  <P/>
##  <Example><![CDATA[
##  gap> l := [ , 2, 3, 5, , 7, , , , 11 ];;
##  gap> Unbind( l[3] ); l;
##  [ , 2,, 5,, 7,,,, 11 ]
##  gap> Unbind( l[4] ); l;
##  [ , 2,,,, 7,,,, 11 ]
##  ]]></Example>
##  <P/>
##  Note that <Ref Oper="IsBound" Label="for a list index"/> and
##  <Ref Oper="Unbind" Label="unbind a list entry"/> are special
##  in that they do not evaluate their argument,
##  otherwise <Ref Oper="IsBound" Label="for a list index"/>
##  would always signal an error when it is supposed to return <K>false</K>
##  and there would be no way to tell
##  <Ref Oper="Unbind" Label="unbind a list entry"/>
##  which component to remove.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "Unbind[]",
    [ IsList and IsMutable, IS_INT ],
    UNB_LIST );


#############################################################################
##
#o  <list>[<pos>] := <obj>
##
DeclareOperationKernel( "[]:=",
    [ IsList and IsMutable, IS_INT, IsObject ],
    ASS_LIST );


#############################################################################
##
#o  <list>{<poss>} := <objs>
##
DeclareOperationKernel( "{}:=",
    [ IsList and IsMutable, IsList, IsList ],
    ASSS_LIST );


#############################################################################
##
#A  ConstantTimeAccessList( <list> )
##
##  <#GAPDoc Label="ConstantTimeAccessList">
##  <ManSection>
##  <Attr Name="ConstantTimeAccessList" Arg='list'/>
##
##  <Description>
##  <Ref Attr="ConstantTimeAccessList"/> returns an immutable list containing
##  the same elements as the list <A>list</A> (which may have holes) in the
##  same order.
##  If <A>list</A> is already a constant time access list,
##  <Ref Attr="ConstantTimeAccessList"/> returns an immutable copy of
##  <A>list</A> directly.
##  Otherwise it puts all elements and holes of <A>list</A> into a new list
##  and makes that list immutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConstantTimeAccessList", IsList );


#############################################################################
##
#F  AsSSortedListList( <list> )
##
##  <ManSection>
##  <Func Name="AsSSortedListList" Arg='list'/>
##
##  <Description>
##  <Ref Func="AsSSortedListList"/> returns an immutable list containing the
##  same elements as the <E>internally represented</E> list <A>list</A>
##  (which may have holes) in strictly sorted order.
##  If <A>list</A> is already immutable and strictly sorted,
##  <Ref Func="AsSSortedListList"/> returns <A>list</A> directly.
##  Otherwise it makes a deep copy, and makes that copy immutable.
##  <Ref Func="AsSSortedListList"/> is an internal function.
##  </Description>
##  </ManSection>
##
DeclareSynonym( "AsSSortedListList", AS_LIST_SORTED_LIST );


#############################################################################
##
#A  AsPlist( <l> )
##
##  <ManSection>
##  <Attr Name="AsPlist" Arg='l'/>
##
##  <Description>
##  <Ref Attr="AsPlist"/> returns a list in the representation
##  <Ref Filt="IsPlistRep"/> that is equal to the list <A>l</A>.
##  It is used before calling kernel functions to sort plists.
##  </Description>
##  </ManSection>
##
DeclareOperation( "AsPlist", [IsListOrCollection] );


#############################################################################
##
#C  IsDenseList( <obj> )
##
##  <#GAPDoc Label="IsDenseList">
##  <ManSection>
##  <Filt Name="IsDenseList" Arg='obj' Type='Category'/>
##
##  <Description>
##  A list is <E>dense</E> if it has no holes, i.e., contains an element at
##  every position up to the length.
##  It is absolutely legal to have lists with holes.
##  They are created by leaving the entry between the commas empty.
##  Holes at the end of a list are ignored.
##  Lists with holes are sometimes convenient when the list represents
##  a mapping from a finite, but not consecutive,
##  subset of the positive integers.
##  <Log><![CDATA[
##  gap> IsDenseList( [ 1, 2, 3 ] );
##  true
##  gap> l := [ , 4, 9,, 25,, 49,,,, 121 ];;  IsDenseList( l );
##  false
##  gap> l[3];
##  9
##  gap> l[4];
##  List Element: <list>[4] must have an assigned value
##  not in any function
##  Entering break read-eval-print loop ...
##  you can 'quit;' to quit to outer loop, or
##  you can 'return;' after assigning a value to continue
##  brk> l[4] := 16;;  # assigning a value
##  brk> return;       # to escape the break-loop
##  16
##  gap>
##  ]]></Log>
##  <P/>
##  Observe that requesting the value of <C>l[4]</C>, which was not
##  assigned, caused the entry of a <K>break</K>-loop
##  (see Section&nbsp;<Ref Sect="Break Loops"/>).
##  After assigning a value and typing <C>return;</C>, &GAP; is finally
##  able to comply with our request (by responding with <C>16</C>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsDenseList", IsList, IS_DENSE_LIST );

InstallTrueMethod( IsDenseList, IsList and IsEmpty );


#############################################################################
##
#C  IsHomogeneousList( <obj> )
##
##  <#GAPDoc Label="IsHomogeneousList">
##  <ManSection>
##  <Filt Name="IsHomogeneousList" Arg='obj' Type='Category'/>
##
##  <Description>
##  returns <K>true</K> if <A>obj</A> is a list and it is homogeneous,
##  and <K>false</K> otherwise.
##  <P/>
##  A <E>homogeneous</E> list is a dense list whose elements lie in the same
##  family (see&nbsp;<Ref Sect="Families"/>).
##  The empty list is homogeneous but not a collection
##  (see&nbsp;<Ref Chap="Collections"/>),
##  a nonempty homogeneous list is also a collection.
##  <!-- can we guarantee this? -->
##  <Example><![CDATA[
##  gap> IsHomogeneousList( [ 1, 2, 3 ] );  IsHomogeneousList( [] );
##  true
##  true
##  gap> IsHomogeneousList( [ 1, false, () ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsHomogeneousList", IsDenseList, IS_HOMOG_LIST );


#############################################################################
##
#M  IsHomogeneousList( <coll_and_list> )  . . for a collection that is a list
#M  IsHomogeneousList( <empty> )  . . . . . . . . . . . . . for an empty list
##
InstallTrueMethod( IsHomogeneousList, IsList and IsCollection );

InstallTrueMethod( IsHomogeneousList, IsList and IsEmpty );


#############################################################################
##
#M  IsFinite( <homoglist> )
##
InstallTrueMethod( IsFinite, IsHomogeneousList and IsInternalRep );


#############################################################################
##
#P  IsSortedList( <obj> )
##
##  <#GAPDoc Label="IsSortedList">
##  <ManSection>
##  <Prop Name="IsSortedList" Arg='obj'/>
##
##  <Description>
##  returns <K>true</K> if <A>obj</A> is a list and it is sorted,
##  <Index Subkey="sorted">list</Index> and <K>false</K> otherwise.
##  <P/>
##  A list <A>list</A> is <E>sorted</E> if it is dense
##  (see&nbsp;<Ref Filt="IsDenseList"/>)
##  and satisfies the relation <M><A>list</A>[i] \leq <A>list</A>[j]</M>
##  whenever <M>i &lt; j</M>.
##  Note that a sorted list is not necessarily duplicate free
##  (see&nbsp;<Ref Prop="IsDuplicateFree"/> and <Ref Prop="IsSSortedList"/>).
##  <P/>
##  Many sorted lists are in fact homogeneous
##  (see&nbsp;<Ref Filt="IsHomogeneousList"/>),
##  but also non-homogeneous lists may be sorted
##  (see&nbsp;<Ref Sect="Comparison Operations for Elements"/>).
##  <P/>
##  In sorted lists, membership test and computing of positions can be done
##  by binary search, see&nbsp;<Ref Sect="Sorted Lists and Sets"/>.
##  <P/>
##  Note that  &GAP; cannot  compare (by  less than)  arbitrary objects.
##  This can cause  that <Ref Prop="IsSortedList"/> runs  into an error,
##  if <A>obj</A> is a list with some non-comparable entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSortedList", IsList);

InstallTrueMethod( IsList, IsSortedList );


#############################################################################
##
#P  IsSSortedList( <obj> )
#P  IsSet( <obj> )
##
##  <#GAPDoc Label="IsSSortedList">
##  <ManSection>
##  <Prop Name="IsSSortedList" Arg='obj'/>
##  <Prop Name="IsSet" Arg='obj'/>
##
##  <Description>
##  returns <K>true</K> if <A>obj</A> is a list and it is strictly sorted,
##  <Index>strictly sorted list</Index>
##  and <K>false</K> otherwise.
##  <Ref Prop="IsSSortedList"/> is short for <Q>is strictly sorted list</Q>;
##  <Ref Prop="IsSet"/> is just a synonym for <Ref Prop="IsSSortedList"/>.
##  <P/>
##  A list <A>list</A> is <E>strictly sorted</E> if it is sorted
##  (see&nbsp;<Ref Prop="IsSortedList"/>)
##  and satisfies the relation <M><A>list</A>[i] &lt; <A>list</A>[j]</M>
##  whenever <M>i &lt; j</M>.
##  In particular, such lists are duplicate free
##  (see&nbsp;<Ref Prop="IsDuplicateFree"/>).
##  <P/>
##  (Currently there is little special treatment of lists that are sorted
##  but not strictly sorted.
##  In particular, internally represented lists will <E>not</E> store
##  that they are sorted but not strictly sorted.)
##  <P/>
##  Note that  &GAP; cannot  compare (by  less than)  arbitrary objects.
##  This can cause  that <Ref Prop="IsSSortedList"/> runs  into an error,
##  if <A>obj</A> is a list with some non-comparable entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclarePropertyKernel( "IsSSortedList", IsList, IS_SSORT_LIST );
DeclareSynonym( "IsSet", IsSSortedList );

InstallTrueMethod( IsSortedList, IsSSortedList );
InstallTrueMethod( IsSSortedList, IsList and IsEmpty );


#############################################################################
##
#P  IsDuplicateFree( <obj> )
#P  IsDuplicateFreeList( <obj> )
##
##  <#GAPDoc Label="IsDuplicateFree">
##  <ManSection>
##  <Prop Name="IsDuplicateFree" Arg='obj'/>
##  <Filt Name="IsDuplicateFreeList" Arg='obj'/>
##
##  <Description>
##  <Ref Prop="IsDuplicateFree"/> returns <K>true</K> if <A>obj</A> is both a
##  list or collection, and it is duplicate free;
##  <Index>duplicate free</Index>
##  otherwise it returns <K>false</K>.
##  <Ref Filt="IsDuplicateFreeList"/> is a synonym for
##  <C>IsDuplicateFree and IsList</C>.
##  <P/>
##  A list is <E>duplicate free</E> if it is dense and does not contain equal
##  entries in different positions.
##  Every domain (see&nbsp;<Ref Sect="Domains"/>) is duplicate free.
##  <P/>
##  Note that  &GAP; cannot  compare arbitrary objects (by equality).
##  This can cause  that <Ref Prop="IsDuplicateFree"/> runs  into an error,
##  if <A>obj</A> is a list with some non-comparable entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsDuplicateFree", IsListOrCollection );

DeclareSynonymAttr( "IsDuplicateFreeList", IsDuplicateFree and IsList );

InstallTrueMethod( IsDuplicateFree, IsList and IsSSortedList );


#############################################################################
##
#P  IsPositionsList(<obj>)
##
##  <ManSection>
##  <Prop Name="IsPositionsList" Arg='obj'/>
##
##  <Description>
##  <!--  1996/09/01 M.Schönert should inherit from <C>IsHomogeneousList</C>-->
##  <!--  but the empty list is a positions list but not homogeneous-->
##  </Description>
##  </ManSection>
##
DeclarePropertyKernel( "IsPositionsList", IsDenseList, IS_POSS_LIST );


#############################################################################
##
#C  IsTable( <obj> )
##
##  <#GAPDoc Label="IsTable">
##  <ManSection>
##  <Filt Name="IsTable" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>table</E> is a nonempty list of homogeneous lists which lie in the
##  same family.
##  Typical examples of tables are matrices
##  (see&nbsp;<Ref Chap="Matrices"/>).
##  <Example><![CDATA[
##  gap> IsTable( [ [ 1, 2 ], [ 3, 4 ] ] );    # in fact a matrix
##  true
##  gap> IsTable( [ [ 1 ], [ 2, 3 ] ] );       # not rectangular but a table
##  true
##  gap> IsTable( [ [ 1, 2 ], [ () , (1,2) ] ] );  # not homogeneous
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsTable", IsHomogeneousList and IsCollection,
    IS_TABLE_LIST );


#############################################################################
##
#O  Position( <list>, <obj>[, <from>] ) . . . position of an object in a list
##
##  <#GAPDoc Label="Position">
##  <ManSection>
##  <Oper Name="Position" Arg='list, obj[, from]'/>
##
##  <Description>
##  returns the position of the first occurrence <A>obj</A> in <A>list</A>,
##  or <K>fail</K> if <A>obj</A> is not contained in <A>list</A>.
##  If a starting index <A>from</A> is given, it
##  returns the position of the first occurrence starting the search
##  <E>after</E> position <A>from</A>.
##  <P/>
##  Each call to the two argument version is translated into a call of the
##  three argument version, with third argument the integer zero <C>0</C>.
##  (Methods for the two argument version must be installed as methods for
##  the version with three arguments, the third being described by
##  <C>IsZeroCyc</C>.)
##  <P/>
##  <Example><![CDATA[
##  gap> Position( [ 2, 2, 1, 3 ], 1 );
##  3
##  gap> Position( [ 2, 1, 1, 3 ], 1 );
##  2
##  gap> Position( [ 2, 1, 1, 3 ], 1, 2 );
##  3
##  gap> Position( [ 2, 1, 1, 3 ], 1, 3 );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "Position", [ IsList, IsObject ], POS_LIST );
DeclareOperation( "Position", [ IsList, IsObject, IS_INT ] );


#############################################################################
##
#F  Positions( <list>, <obj> ) . . . . . . . positions of an object in a list
#O  PositionsOp( <list>, <obj> ) . . . . . . . . . . . . underlying operation
##
##  <#GAPDoc Label="Positions">
##  <ManSection>
##  <Func Name="Positions" Arg='list, obj'/>
##
##  <Description>
##  returns the set of positions of <E>all</E> occurrences of <A>obj</A> in
##  <A>list</A>.
##  <P/>
##  Developers who wish to adapt this for custom list types need to
##  install suitable methods for the operation <C>PositionsOp</C>.
##  <Index Key="PositionsOp"><C>PositionsOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> Positions([1,2,1,2,3,2,2],2);
##  [ 2, 4, 6, 7 ]
##  gap> Positions([1,2,1,2,3,2,2],4);
##  [  ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch plain lists by a function to avoid method selection:
DeclareGlobalFunction( "Positions" );
DeclareOperation( "PositionsOp", [ IsList, IsObject ] );


#############################################################################
##
#O  PositionCanonical( <list>, <obj> )  . . . position of canonical associate
##
##  <#GAPDoc Label="PositionCanonical">
##  <ManSection>
##  <Oper Name="PositionCanonical" Arg='list, obj'/>
##
##  <Description>
##  returns the position of the canonical associate of <A>obj</A> in
##  <A>list</A>.
##  The definition of this associate depends on <A>list</A>.
##  For internally represented lists it is defined as the element itself
##  (and <Ref Oper="PositionCanonical"/> thus defaults to
##  <Ref Oper="Position"/>,
##  but for example for certain enumerators
##  (see&nbsp;<Ref Sect="Enumerators"/>)
##  other canonical associates can be defined.
##  <P/>
##  For example <Ref Oper="RightTransversal"/> defines the
##  canonical associate to be the element in the transversal defining the
##  same coset of a subgroup in a group.
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;u:=Subgroup(g,[(1,2)(3,4),(1,3)(2,4)]);;
##  gap> rt:=RightTransversal(g,u);;AsList(rt);
##  [ (), (3,4), (2,3), (2,3,4), (2,4,3), (2,4) ]
##  gap> Position(rt,(1,2));
##  fail
##  gap> PositionCanonical(rt,(1,2));
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionCanonical", [ IsList, IsObject ]);


#############################################################################
##
#O  PositionNthOccurrence(<list>,<obj>,<n>) pos. of <n>th occurrence of <obj>
##
##  <#GAPDoc Label="PositionNthOccurrence">
##  <ManSection>
##  <Oper Name="PositionNthOccurrence" Arg='list,obj,n'/>
##
##  <Description>
##  returns the position of the <A>n</A>-th occurrence of <A>obj</A> in
##  <A>list</A>
##  and returns <K>fail</K> if <A>obj</A> does not occur <A>n</A> times.
##  <P/>
##  <Example><![CDATA[
##  gap> PositionNthOccurrence([1,2,3,2,4,2,1],1,1);
##  1
##  gap> PositionNthOccurrence([1,2,3,2,4,2,1],1,2);
##  7
##  gap> PositionNthOccurrence([1,2,3,2,4,2,1],2,3);
##  6
##  gap> PositionNthOccurrence([1,2,3,2,4,2,1],2,4);
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionNthOccurrence", [ IsList, IsObject, IS_INT ] );


#############################################################################
##
#F  PositionSorted( <list>, <elm>[, <func>] ) . . . . position in sorted list
##
##  <#GAPDoc Label="PositionSorted">
##  <ManSection>
##  <Func Name="PositionSorted" Arg='list, elm[, func]'/>
##
##  <Description>
##  Called with two arguments, <Ref Func="PositionSorted"/> returns
##  the position of the element <A>elm</A> in the sorted list <A>list</A>.
##  <P/>
##  Called with three arguments, <Ref Func="PositionSorted"/> returns
##  the position of the element <A>elm</A> in the list <A>list</A>,
##  which must be sorted with respect to <A>func</A>.
##  <A>func</A> must be a function of two arguments that returns <K>true</K>
##  if the first argument is less than the second argument,
##  and <K>false</K> otherwise.
##  <P/>
##  <Ref Func="PositionSorted"/> returns <A>pos</A> such that
##  <M><A>list</A>[<A>pos</A>-1] &lt; <A>elm</A> \leq
##  <A>list</A>[<A>pos</A>]</M> holds.
##  That means, if <A>elm</A> appears once in <A>list</A>,
##  its position is returned.
##  If <A>elm</A> appears several times in <A>list</A>,
##  the position of the first occurrence is returned.
##  If <A>elm</A> is not an element of <A>list</A>,
##  the index where <A>elm</A> must be inserted to keep the list sorted
##  is returned.
##  <P/>
##  <Ref Func="PositionSorted"/> uses binary search,
##  whereas <Ref Oper="Position"/> can in general
##  use only linear search, see the remark at the beginning
##  of&nbsp;<Ref Sect="Sorted Lists and Sets"/>.
##  For sorting lists, see&nbsp;<Ref Sect="Sorting Lists"/>,
##  for testing whether a list is sorted,
##  see&nbsp;<Ref Prop="IsSortedList"/> and <Ref Prop="IsSSortedList"/>.
##  <P/>
##  Developers who wish to adapt this for custom list types need to
##  install suitable methods for the operation <C>PositionSortedOp</C>.
##  <Index Key="PositionSortedOp"><C>PositionSortedOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> PositionSorted( [1,4,5,5,6,7], 0 );
##  1
##  gap> PositionSorted( [1,4,5,5,6,7], 2 );
##  2
##  gap> PositionSorted( [1,4,5,5,6,7], 4 );
##  2
##  gap> PositionSorted( [1,4,5,5,6,7], 5 );
##  3
##  gap> PositionSorted( [1,4,5,5,6,7], 8 );
##  7
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch plain lists by a function to avoid method selection:
DeclareGlobalFunction( "PositionSorted" );
DeclareOperation( "PositionSortedOp", [ IsList, IsObject ] );
DeclareOperation( "PositionSortedOp", [ IsList, IsObject, IsFunction ] );


#############################################################################
##
#F  PositionSortedBy( <list>, <val>, <func> )
##
##  <#GAPDoc Label="PositionSortedBy">
##  <ManSection>
##  <Func Name="PositionSortedBy" Arg='list, val, func'/>
##
##  <Description>
##  This function returns the same value that would be returned by
##  <C>PositionSorted(List(list, func), val)</C>, but computes it in
##  a more efficient way.
##  <P/>
##  To be more precise, <A>func</A> must be a function on one argument which
##  returns values that can be compared to <A>val</A>, and <A>list</A>
##  must be a list for which <C>func(list[i]) &lt;= func(list[i+1])</C> holds
##  for all relevant <A>i</A>. This property is not verified, and if the
##  input violates it, then the result is undefined.
##  <P/>
##  <Ref Func="PositionSortedBy"/> returns <A>pos</A> such that
##  <M><A>func</A>(<A>list</A>[<A>pos</A>-1]) &lt; <A>val</A>
##  \leq <A>func</A>(<A>list</A>[<A>pos</A>])</M> holds.
##  That means, if there are elements <C>elm</C> in <A>list</A>
##  for which <M><A>func</A>(elm) = <A>val</A></M> holds, then
##  the position of the first such element is returned.
##  If no element of <A>list</A> satisfies this condition, then
##  the lowest index where an element <A>elm</A> satisfying
##  <M><A>func</A>(elm) = <A>val</A></M> must be inserted to preserve
##  the property <C>func(list[i]) &lt;= func(list[i+1])</C> is returned.
##  <P/>
##  <Ref Func="PositionSortedBy"/> uses binary search.
##  Each <C>func(list[i])</C> is computed at most once.
##  <P/>
##  Developers who wish to adapt this for custom list types need to
##  install suitable methods for the operation <C>PositionSortedByOp</C>.
##  <Index Key="PositionSortedByOp"><C>PositionSortedByOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> PositionSortedBy( [ "", "ab", ], -1, Length );
##  1
##  gap> PositionSortedBy( [ "", "ab", ], 0, Length );
##  1
##  gap> PositionSortedBy( [ "", "ab", ], 1, Length );
##  2
##  gap> PositionSortedBy( [ "", "ab", ], 2, Length );
##  2
##  gap> PositionSortedBy( [ "", "ab", ], 3, Length );
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch plain lists by a function to avoid method selection:
DeclareGlobalFunction( "PositionSortedBy" );
DeclareOperation("PositionSortedByOp", [ IsList, IsObject, IsFunction ]);


#############################################################################
##
#F  PositionSet( <list>, <obj>[, <func>] )
##
##  <#GAPDoc Label="PositionSet">
##  <ManSection>
##  <Func Name="PositionSet" Arg='list, obj[, func]'/>
##
##  <Description>
##  <Ref Func="PositionSet"/> is a slight variation of
##  <Ref Func="PositionSorted"/>.
##  The only difference to <Ref Func="PositionSorted"/> is that
##  <Ref Func="PositionSet"/> returns
##  <K>fail</K> if <A>obj</A> is not in <A>list</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> PositionSet( [1,4,5,5,6,7], 0 );
##  fail
##  gap> PositionSet( [1,4,5,5,6,7], 2 );
##  fail
##  gap> PositionSet( [1,4,5,5,6,7], 4 );
##  2
##  gap> PositionSet( [1,4,5,5,6,7], 5 );
##  3
##  gap> PositionSet( [1,4,5,5,6,7], 8 );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PositionSet" );


#############################################################################
##
#O  PositionProperty( <list>, <func>[, <from>] )
##
##  <#GAPDoc Label="PositionProperty">
##  <ManSection>
##  <Oper Name="PositionProperty" Arg='list, func[, from]'/>
##
##  <Description>
##  returns the position of the first entry in the list <A>list</A>
##  for which the property tester function <A>func</A> returns <K>true</K>,
##  or <K>fail</K> if no such entry exists.
##  If a starting index <A>from</A> is given, it
##  returns the position of the first entry satisfying <A>func</A>,
##  starting the search <E>after</E> position <A>from</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> PositionProperty( [10^7..10^8], IsPrime );
##  20
##  gap> PositionProperty( [10^5..10^6],
##  >        n -> not IsPrime(n) and IsPrimePowerInt(n) );
##  490
##  ]]></Example>
##  <P/>
##  <Ref Oper="First"/> allows you to extract the first element of a list
##  that satisfies a certain property.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionProperty", [ IsList, IsFunction ] );
DeclareOperation( "PositionProperty", [ IsList, IsFunction, IS_INT ] );

#############################################################################
##
#O  PositionMaximum( <list> [, <func>] )
#O  PositionMinimum( <list> [, <func>] )
##
##  <#GAPDoc Label="PositionMaximum">
##  <ManSection>
##  <Func Name="PositionMaximum" Arg='list [, func]'/>
##  <Func Name="PositionMinimum" Arg='list [, func]'/>
##
##  <Description>
##  returns the position of maximum (with <Ref Func="PositionMaximum"/>) or
##  minimum (with <Ref Func="PositionMinimum"/>) entry in the list <A>list</A>.
##  If a second argument <A>func</A> is passed, then return instead the position
##  of the largest/smallest entry in <C>List( <A>list</A> , <A>func</A> )</C>.
##  If several entries of the list are equal
##  to the maximum/minimum, the first such position is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> PositionMaximum( [2,4,-6,2,4] );
##  2
##  gap> PositionMaximum( [2,4,-6,2,4], x -> -x);
##  3
##  gap> PositionMinimum( [2,4,-6,2,4] );
##  3
##  gap> PositionMinimum( [2,4,-6,2,4], x -> -x);
##  2
##  ]]></Example>
##  <P/>
##  <Ref Func="Maximum" Label="for various objects"/> and
##  <Ref Func="Minimum" Label="for various objects"/>
##  allow you to find the maximum or minimum element of a list directly.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PositionMaximum" );
DeclareGlobalFunction( "PositionMinimum" );

#############################################################################
##
#O  PositionsProperty( <list>, <func> )
##
##  <#GAPDoc Label="PositionsProperty">
##  <ManSection>
##  <Oper Name="PositionsProperty" Arg='list, func'/>
##
##  <Description>
##  returns the set of all those positions in the list <A>list</A>
##  which are bound and
##  for which the property tester function <A>func</A> returns <K>true</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> l:= [ -5 .. 5 ];;
##  gap> PositionsProperty( l, IsPosInt );
##  [ 7, 8, 9, 10, 11 ]
##  gap> PositionsProperty( l, IsPrimeInt );
##  [ 1, 3, 4, 8, 9, 11 ]
##  ]]></Example>
##  <P/>
##  <Ref Oper="PositionProperty"/> allows you to extract the position of the
##  first element in a list that satisfies a certain property.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionsProperty", [ IsList, IsFunction ] );


#############################################################################
##
#O  PositionBound( <list> ) . . . . position of first bound element in a list
##
##  <#GAPDoc Label="PositionBound">
##  <ManSection>
##  <Oper Name="PositionBound" Arg='list'/>
##
##  <Description>
##  returns the first bound position of the list
##  <A>list</A>.
##  For the empty list it returns <K>fail</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> PositionBound([1,2,3]);
##  1
##  gap> PositionBound([,1,2,3]);
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionBound", [ IsList ] );


#############################################################################
##
#F  PositionsBound( <list> ) . . . . . . . . . positions of all bound entries
##
##  <#GAPDoc Label="PositionsBound">
##  <ManSection>
##  <Func Name="PositionsBound" Arg='list'/>
##
##  <Description>
##  returns the set of all bound positions in the list
##  <A>list</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> PositionsBound([1,2,3]);
##  [ 1 .. 3 ]
##  gap> PositionsBound([,1,,3]);
##  [ 2, 4 ]
##  gap> PositionsBound([]);
##  []
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PositionsBound" );


#############################################################################
##
#O  PositionSublist( <list>, <sub>[, <from>] )
##
##  <#GAPDoc Label="PositionSublist">
##  <ManSection>
##  <Oper Name="PositionSublist" Arg='list, sub[, from]'/>
##
##  <Description>
##  returns the smallest index in the list <A>list</A> at which a sublist
##  equal to <A>sub</A> starts.
##  If <A>sub</A> does not occur the operation returns <K>fail</K>.
##  The version with given <A>from</A> starts searching <E>after</E>
##  position <A>from</A>.
##  <P/>
##  To determine whether <A>sub</A> matches <A>list</A> at a particular
##  position, use <Ref Oper="IsMatchingSublist"/> instead.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionSublist", [ IsList,IsList,IS_INT ] );


#############################################################################
##
#O  IsMatchingSublist( <list>, <sub>[, <at>] )
##
##  <#GAPDoc Label="IsMatchingSublist">
##  <ManSection>
##  <Oper Name="IsMatchingSublist" Arg='list, sub[, at]'/>
##
##  <Description>
##  returns <K>true</K> if <A>sub</A> matches a sublist of <A>list</A> from
##  position <C>1</C> (or position <A>at</A>, in the case of three arguments),
##  or <K>false</K>, otherwise.
##  If <A>sub</A> is empty <K>true</K> is returned.
##  If <A>list</A> is empty but <A>sub</A> is non-empty
##  <K>false</K> is returned.
##  <P/>
##  If you actually want to know whether there is an <A>at</A> for which
##  <C>IsMatchingSublist( <A>list</A>, <A>sub</A>, <A>at</A> )</C> is true,
##  use a construction like
##  <C>PositionSublist( <A>list</A>, <A>sub</A> ) &tlt;&tgt; fail</C> instead
##  (see <Ref Oper="PositionSublist"/>); it's more efficient.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsMatchingSublist", [ IsList,IsList,IS_INT ] );

#############################################################################
##
#F  IsQuickPositionList( <list> )
##
##  <#GAPDoc Label="IsQuickPositionList">
##  <ManSection>
##  <Filt Name="IsQuickPositionList" Arg='list'/>
##
##  <Description>
##  This filter indicates that a position test in <A>list</A> is quicker than
##  about 5 or 6 element comparisons for <Q>smaller</Q>.
##  If this is the case it can be beneficial to use <Ref Oper="Position"/>
##  in <A>list</A> and a bit list than ordered lists to represent subsets
##  of <A>list</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareFilter( "IsQuickPositionList" );


#############################################################################
##
#O  Add( <list>, <obj>[, <pos>] ) . . . . . add an element anywhere in a list
##
##  <#GAPDoc Label="Add">
##  <ManSection>
##  <Oper Name="Add" Arg='list, obj[, pos]'/>
##
##  <Description>
##  adds the element <A>obj</A> to the mutable list <A>list</A>.
##  The two argument version adds <A>obj</A> at the end of <A>list</A>,
##  i.e., it is equivalent to the assignment
##  <C><A>list</A>[ Length(<A>list</A>) + 1 ] := <A>obj</A></C>,
##  see&nbsp;<Ref Sect="List Assignment"/>.
##  <P/>
##  The three argument version adds <A>obj</A> in position <A>pos</A>,
##  moving all later elements of the list (if any) up by one position.
##  Any holes at or after position <A>pos</A> are also moved up by one
##  position, and new holes are created before <A>pos</A> if they are needed.
##  <P/>
##  Nothing is returned by <Ref Oper="Add"/>,
##  the function is only called for its side effect.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "Add", [ IsList and IsMutable, IsObject ], ADD_LIST );
DeclareOperation( "Add", [ IsList and IsMutable, IsObject,  IS_INT ]);


#############################################################################
##
#O  Remove( <list>[, <pos>] )  . .  remove an entry from pos. <pos> of a list
##
##  <#GAPDoc Label="Remove">
##  <ManSection>
##  <Oper Name="Remove" Arg='list[, pos]'/>
##
##  <Description>
##  removes an element from <A>list</A>.
##  The one argument form removes the last element.
##  The two argument form removes the element in position <A>pos</A>,
##  moving all subsequent elements down one position. Any holes after
##  position <A>pos</A> are also moved down by one position.
##  <P/>
##  The one argument form always returns the removed element.
##  In this case <A>list</A> must be non-empty.
##  <P/>
##  The two argument form returns the old value of <A>list</A>[<A>pos</A>]
##  if it was bound, and nothing if it was not.
##  Note that accessing or assigning the return value of this form of
##  the <Ref Oper="Remove"/> operation is only safe when you <E>know</E>
##  that there will be a  value, otherwise it will cause an error.
##  <P/>
##  <Example><![CDATA[
##  gap> l := [ 2, 3, 5 ];; Add( l, 7 ); l;
##  [ 2, 3, 5, 7 ]
##  gap> Add(l,4,2); l;
##  [ 2, 4, 3, 5, 7 ]
##  gap> Remove(l,2); l;
##  4
##  [ 2, 3, 5, 7 ]
##  gap> Remove(l); l;
##  7
##  [ 2, 3, 5 ]
##  gap> Remove(l,5); l;
##  [ 2, 3, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "Remove", [IsList and IsMutable], REM_LIST);
DeclareOperation( "Remove", [IsList and IsMutable, IS_INT]);

DeclareSynonym( "CopyListEntries", COPY_LIST_ENTRIES );

#############################################################################
##
#O  Append( <list1>, <list2> )  . . . . . . . . . . . append a list to a list
##
##  <#GAPDoc Label="Append">
##  <ManSection>
##  <Oper Name="Append" Arg='list1, list2'/>
##
##  <Description>
##  adds the elements of the list <A>list2</A> to the end of the mutable list
##  <A>list1</A>, see&nbsp;<Ref Sect="List Assignment"/>.
##  <A>list2</A> may contain holes, in which case the corresponding entries
##  in <A>list1</A> will be left unbound.
##  <Ref Oper="Append"/> returns nothing,
##  it is only called for its side effect.
##  <P/>
##  Note that <Ref Oper="Append"/> changes its first argument,
##  while <Ref Func="Concatenation" Label="for a list of lists"/> creates
##  a new list and leaves its arguments unchanged.
##  <P/>
##  <Example><![CDATA[
##  gap> l := [ 2, 3, 5 ];; Append( l, [ 7, 11, 13 ] ); l;
##  [ 2, 3, 5, 7, 11, 13 ]
##  gap> Append( l, [ 17,, 23 ] ); l;
##  [ 2, 3, 5, 7, 11, 13, 17,, 23 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "Append", [ IsList and IsMutable, IsList ],
    APPEND_LIST );


#############################################################################
##
#F  Apply( <list>, <func> ) . . . . . . . .  apply a function to list entries
##
##  <#GAPDoc Label="Apply">
##  <ManSection>
##  <Func Name="Apply" Arg='list, func'/>
##
##  <Description>
##  <Ref Func="Apply"/> applies the function <A>func</A> to every element
##  of the dense and mutable list <A>list</A>,
##  and replaces each element entry by the corresponding return value.
##  <P/>
##  <Ref Func="Apply"/> changes its argument.
##  The nondestructive counterpart of <Ref Func="Apply"/>
##  is <Ref Func="List" Label="for a collection"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> l:= [ 1, 2, 3 ];;  Apply( l, i -> i^2 );  l;
##  [ 1, 4, 9 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Apply" );


#############################################################################
##
#F  Concatenation( <list1>, <list2>, ... )  . . . . .  concatenation of lists
#F  Concatenation( <list> ) . . . . . . . . . . . . .  concatenation of lists
##
##  <#GAPDoc Label="Concatenation">
##  <ManSection>
##  <Func Name="Concatenation" Arg='list1, list2, ...'
##   Label="for several lists"/>
##  <Func Name="Concatenation" Arg='list' Label="for a list of lists"/>
##
##  <Description>
##  In the first form <Ref Func="Concatenation" Label="for several lists"/>
##  returns the concatenation of the lists <A>list1</A>, <A>list2</A>, etc.
##  The <E>concatenation</E> is the list that begins with the elements of
##  <A>list1</A>, followed by the elements of <A>list2</A>, and so on.
##  Each list may also contain holes, in which case the concatenation also
##  contains holes at the corresponding positions.
##  <P/>
##  In the second form <A>list</A> must be a dense list of lists
##  <A>list1</A>, <A>list2</A>, etc.,
##  and <Ref Func="Concatenation" Label="for a list of lists"/> returns the
##  concatenation of those lists.
##  <P/>
##  The result is a new mutable list,
##  that is not identical to any other list.
##  The elements of that list however are identical to the corresponding
##  elements of <A>list1</A>, <A>list2</A>, etc.
##  (see&nbsp;<Ref Sect="Identical Lists"/>).
##  <P/>
##  Note that <Ref Func="Concatenation" Label="for several lists"/> creates
##  a new list and leaves its arguments unchanged,
##  while <Ref Oper="Append"/> changes its first argument.
##  For computing the union of proper sets,
##  <Ref Func="Union" Label="for a list"/> can be used,
##  see also <Ref Sect="Sorted Lists and Sets"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> Concatenation( [ 1, 2, 3 ], [ 4, 5 ] );
##  [ 1, 2, 3, 4, 5 ]
##  gap> Concatenation( [2,3,,5,,7], [11,,13,,,,17,,19] );
##  [ 2, 3,, 5,, 7, 11,, 13,,,, 17,, 19 ]
##  gap> Concatenation( [ [1,2,3], [2,3,4], [3,4,5] ] );
##  [ 1, 2, 3, 2, 3, 4, 3, 4, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Concatenation" );


#############################################################################
##
#O  Compacted( <list> ) . . . . . . . . . . . . . .  remove holes from a list
##
##  <#GAPDoc Label="Compacted">
##  <ManSection>
##  <Oper Name="Compacted" Arg='list'/>
##
##  <Description>
##  returns a new mutable list that contains the elements of <A>list</A>
##  in the same order but omitting the holes.
##  <P/>
##  <Example><![CDATA[
##  gap> l:=[,1,,,3,,,4,[5,,,6],7];;  Compacted( l );
##  [ 1, 3, 4, [ 5,,, 6 ], 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Compacted", [ IsList ] );


#############################################################################
##
#O  Collected( <list> ) . . . . . . . . . . collect like elements from a list
##
##  <#GAPDoc Label="Collected">
##  <ManSection>
##  <Oper Name="Collected" Arg='list'/>
##
##  <Description>
##  returns a new list <A>new</A> that contains for each element <A>elm</A>
##  of the list <A>list</A> a list of length two,
##  the first element of this is <A>elm</A> itself and the second element is
##  the number of times <A>elm</A> appears in <A>list</A>.
##  The order of those pairs in <A>new</A> corresponds to the ordering of
##  the elements elm, so that the result is sorted.
##  <P/>
##  For all pairs of elements in <A>list</A> the comparison via <C>&lt;</C>
##  must be defined.
##  <P/>
##  <Example><![CDATA[
##  gap> Factors( Factorial( 10 ) );
##  [ 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 5, 5, 7 ]
##  gap> Collected( last );
##  [ [ 2, 8 ], [ 3, 4 ], [ 5, 2 ], [ 7, 1 ] ]
##  gap> Collected( last );
##  [ [ [ 2, 8 ], 1 ], [ [ 3, 4 ], 1 ], [ [ 5, 2 ], 1 ], [ [ 7, 1 ], 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Collected", [ IsList ] );


#############################################################################
##
#O  DuplicateFreeList( <list> ) . . . .  duplicate free list of list elements
#O  Unique( <list> )
##
##  <#GAPDoc Label="DuplicateFreeList">
##  <ManSection>
##  <Oper Name="DuplicateFreeList" Arg='list'/>
##  <Oper Name="Unique" Arg='list'/>
##
##  <Description>
##  returns a new mutable list whose entries are the elements of the list
##  <A>list</A> with duplicates removed.
##  <Ref Oper="DuplicateFreeList"/> only uses the <C>=</C> comparison
##  and will not sort the result.
##  Therefore <Ref Oper="DuplicateFreeList"/> can be used even if the
##  elements of <A>list</A> do not lie in the same family.
##  Otherwise, if <A>list</A> contains objects that can be compared with
##  <Ref Oper="\&lt;"/> then it is much more efficient to use
##  <Ref Oper="Set"/> instead of <Ref Oper="DuplicateFreeList"/>.
##  <P/>
##  <Ref Oper="Unique"/> is a synonym for <Ref Oper="DuplicateFreeList"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> l:=[1,Z(3),1,"abc",Group((1,2,3),(1,2)),Z(3),Group((1,2),(2,3))];;
##  gap> DuplicateFreeList( l );
##  [ 1, Z(3), "abc", Group([ (1,2,3), (1,2) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DuplicateFreeList", [ IsList ] );

DeclareSynonym( "Unique", DuplicateFreeList );


#############################################################################
##
#A  AsDuplicateFreeList( <list> ) . . .  duplicate free list of list elements
##
##  <#GAPDoc Label="AsDuplicateFreeList">
##  <ManSection>
##  <Attr Name="AsDuplicateFreeList" Arg='list'/>
##
##  <Description>
##  returns the same result as <Ref Oper="DuplicateFreeList"/>,
##  except that the result is immutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsDuplicateFreeList", IsList );


#############################################################################
##
#O  DifferenceLists(<list1>,<list2>)  . list without elements in another list
##
##  <ManSection>
##  <Oper Name="DifferenceLists" Arg='list1,list2'/>
##
##  <Description>
##  This operation accepts two lists <A>list1</A> and <A>list2</A>
##  and returns a list containing the elements in <A>list1</A>
##  that do not lie in <A>list2</A>.
##  The elements of the resulting list are in the same order as they are in
##  <A>list1</A>.  The result of this operation is the same as that of the
##  operation <Ref Func="Difference"/>
##  except that the first argument is not treated as a proper set,
##  and therefore the result need not be duplicate-free or sorted.
##  </Description>
##  </ManSection>
##
DeclareOperation( "DifferenceLists", [IsList, IsList] );


#############################################################################
##
#O  Flat( <list> )  . . . . . . . list of elements of a nested list structure
##
##  <#GAPDoc Label="Flat">
##  <ManSection>
##  <Oper Name="Flat" Arg='list'/>
##
##  <Description>
##  returns the list of all elements that are contained in the list
##  <A>list</A> or its sublists.
##  That is, <Ref Oper="Flat"/> first makes a new empty list <A>new</A>.
##  Then it loops over the elements <A>elm</A> of <A>list</A>.
##  If <A>elm</A> is not a list it is added to <A>new</A>,
##  otherwise <Ref Oper="Flat"/> appends <C>Flat( <A>elm</A> )</C>
##  to <A>new</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> Flat( [ 1, [ 2, 3 ], [ [ 1, 2 ], 3 ] ] );
##  [ 1, 2, 3, 1, 2, 3 ]
##  gap> Flat( [ ] );
##  [  ]
##  ]]></Example>
##  <P/>
##  To reconstruct a matrix from the list obtained by applying
##  <Ref Oper="Flat"/> to the matrix,
##  the sublist operator can be used, as follows.
##  <P/>
##  <Example><![CDATA[
##  gap> l:=[9..14];;w:=2;; # w is the length of each row
##  gap> sub:=[1..w];;List([1..Length(l)/w],i->l{(i-1)*w+sub});
##  [ [ 9, 10 ], [ 11, 12 ], [ 13, 14 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Flat", [ IsList ] );


#############################################################################
##
#F  Reversed( <list> )  . . . . . . . . . . .  reverse the elements in a list
##
##  <#GAPDoc Label="Reversed">
##  <ManSection>
##  <Func Name="Reversed" Arg='list'/>
##
##  <Description>
##  returns a new mutable list, containing the elements of the dense list
##  <A>list</A> in reversed order.
##  <P/>
##  The argument list is unchanged.
##  The result list is a new list, that is not identical to any other list.
##  The elements of that list however are identical to the corresponding
##  elements of the argument list (see&nbsp;<Ref Sect="Identical Lists"/>).
##  <P/>
##  <Ref Func="Reversed"/> implements a special case of list assignment,
##  which can also be formulated in terms of the <C>{}</C> operator
##  (see&nbsp;<Ref Sect="List Assignment"/>).
##  <P/>
##  Developers who wish to adapt this for custom list types need to
##  install suitable methods for the operation <C>ReversedOp</C>.
##  <Index Key="ReversedOp"><C>ReversedOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> Reversed( [ 1, 4, 9, 5, 6, 7 ] );
##  [ 7, 6, 5, 9, 4, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "Reversed" );
DeclareOperation( "ReversedOp", [ IsDenseList ] );


#############################################################################
##
#F  Shuffle( <list> )  . . . . . . . . . . . . . . . permute entries randomly
##
##  <#GAPDoc Label="Shuffle">
##  <ManSection>
##  <Oper Name="Shuffle" Arg='list'/>
##
##  <Description>
##  The argument <A>list</A> must be a dense mutable list. This operation
##  permutes the entries of <A>list</A> randomly (in place), and returns
##  <A>list</A>.
##  <Example>
##  gap> Reset(GlobalMersenneTwister, 12345);; # make manual tester happy
##  gap> l := [1..20];
##  [ 1 .. 20 ]
##  gap> m := Shuffle(ShallowCopy(l));
##  [ 8, 13, 1, 3, 20, 15, 4, 7, 5, 18, 6, 12, 16, 11, 2, 10, 19, 17, 9,
##    14 ]
##  gap> l;
##  [ 1 .. 20 ]
##  gap> Shuffle(l);;
##  gap> l;
##  [ 19, 5, 7, 20, 16, 1, 10, 15, 12, 11, 13, 2, 14, 3, 4, 17, 6, 8, 9,
##    18 ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Shuffle", [IsDenseList and IsMutable] );


#############################################################################
##
#O  Sort( <list>[, <func>] )  . . . . . . . . . . . . . . . . . . sort a list
#O  SortBy( <list>, <func> )  . . . . . . . . . . . . . . . . . . sort a list
##
##  <#GAPDoc Label="Sort">
##  <ManSection>
##  <Oper Name="Sort" Arg='list[, func]'/>
##  <Oper Name="SortBy" Arg='list, func'/>
##  <Oper Name="StableSort" Arg='list, [func]'/>
##  <Oper Name="StableSortBy" Arg='list, [func]'/>
##  <Description>
##  <Ref Oper="Sort"/> sorts the list <A>list</A> in increasing order.
##  In the one argument form <Ref Oper="Sort"/> uses the operator <C>&lt;</C>
##  to compare the elements.
##  (If the list is not homogeneous it is the user's responsibility to ensure
##  that <C>&lt;</C> is defined for all element pairs,
##  see&nbsp;<Ref Sect="Comparison Operations for Elements"/>)
##  In the two argument form <Ref Oper="Sort"/> uses the function <A>func</A>
##  to compare elements.
##  <A>func</A> must be a function taking two arguments that returns
##  <K>true</K> if the first is regarded as strictly smaller than the second,
##  and <K>false</K> otherwise.
##  <P/>
##  <Ref Oper="StableSort"/> behaves identically to <Ref Oper="Sort"/>, except
##  that <Ref Oper="StableSort"/> will keep elements which compare equal in the
##  same relative order, while <Ref Oper="Sort"/> may change their relative order.
##  <P/>
##  <Ref Oper="Sort"/> does not return anything,
##  it just changes the argument <A>list</A>.
##  Use <Ref Oper="ShallowCopy"/> if you want to keep <A>list</A>.
##  Use <Ref Func="Reversed"/> if you want to get a new list that is
##  sorted in decreasing order.
##  <P/>
##  <Ref Oper="SortBy"/> sorts the list <A>list</A> into an order such that
##  <C>func(list[i]) &lt;= func(list[i+1])</C> for all relevant
##  <A>i</A>. <A>func</A> must thus be a function on one argument which returns
##  values that can be compared.  Each <C>func(list[i])</C> is computed just
##  once and stored, making this more efficient than using the two-argument
##  version of <Ref Oper="Sort"/> in many cases.
##  <P/>
##  <Ref Oper="StableSortBy"/> behaves the same as <Ref Oper="SortBy"/> except that,
## like <Ref Oper="StableSort"/>, it keeps pairs of values which compare equal when
## <C>func</C> is applied to them in the same relative order.
##  <P/>
##  <Example><![CDATA[
##  gap> list := [ 5, 4, 6, 1, 7, 5 ];; Sort( list ); list;
##  [ 1, 4, 5, 5, 6, 7 ]
##  gap> SortBy(list, x -> x mod 3);
##  gap> list; # Sorted by mod 3
##  [ 6, 1, 4, 7, 5, 5]
##  gap> list := [ [0,6], [1,2], [1,3], [1,5], [0,4], [3,4] ];;
##  gap> Sort( list, function(v,w) return v*v < w*w; end );
##  gap> list;  # sorted according to the Euclidean distance from [0,0]
##  [ [ 1, 2 ], [ 1, 3 ], [ 0, 4 ], [ 3, 4 ], [ 1, 5 ], [ 0, 6 ] ]
##  gap> SortBy( list, function(v) return v[1] + v[2]; end );
##  gap> list;  # sorted according to Manhattan distance from [0,0]
##  [ [ 1, 2 ], [ 1, 3 ], [ 0, 4 ], [ 1, 5 ], [ 0, 6 ], [ 3, 4 ] ]
##  gap> list := [ [0,6], [1,3], [3,4], [1,5], [1,2], [0,4], ];;
##  gap> Sort( list, function(v,w) return v[1] < w[1]; end );
##  gap> # note the random order of the elements with equal first component:
##  gap> list;
##  [ [ 0, 6 ], [ 0, 4 ], [ 1, 3 ], [ 1, 5 ], [ 1, 2 ], [ 3, 4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Sort", [ IsList and IsMutable ] );
DeclareOperation( "Sort", [ IsList and IsMutable, IsFunction ] );
DeclareOperation( "SortBy", [IsList and IsMutable, IsFunction ] );

DeclareOperation( "StableSort", [ IsList and IsMutable ] );
DeclareOperation( "StableSort", [ IsList and IsMutable, IsFunction ] );
DeclareOperation( "StableSortBy", [IsList and IsMutable, IsFunction ] );


#############################################################################
##
#O  Sortex( <list>[, <func>] ) . . sort a list (stable), return applied perm.
##
##  <#GAPDoc Label="Sortex">
##  <ManSection>
##  <Oper Name="Sortex" Arg='list[, func]'/>
##
##  <Description>
##  sorts the list <A>list</A> and returns a permutation
##  that can be applied to <A>list</A> to obtain the sorted list.
##  The one argument form sorts via the operator <C>&lt;</C>,
##  the two argument form sorts w.r.t. the function <A>func</A>.
##  The permutation returned by <Ref Oper="Sortex"/> will keep
##  elements which compare equal in the same relative order.
##  (If the list is not homogeneous it is the user's responsibility to ensure
##  that <C>&lt;</C> is defined for all element pairs,
##  see&nbsp;<Ref Sect="Comparison Operations for Elements"/>)
##  <P/>
##  <Ref Oper="Permuted"/> allows you to rearrange a list according to
##  a given permutation.
##  <P/>
##  <Example><![CDATA[
##  gap> list1 := [ 5, 4, 6, 1, 7, 5 ];;
##  gap> list2 := ShallowCopy( list1 );;
##  gap> perm := Sortex( list1 );
##  (1,3,5,6,4)
##  gap> list1;
##  [ 1, 4, 5, 5, 6, 7 ]
##  gap> Permuted( list2, perm );
##  [ 1, 4, 5, 5, 6, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Sortex", [ IsList and IsMutable ] );
DeclareOperation( "Sortex", [ IsList and IsMutable, IsFunction ] );


#############################################################################
##
#A  SortingPerm( <list> )
##
##  <#GAPDoc Label="SortingPerm">
##  <ManSection>
##  <Attr Name="SortingPerm" Arg='list'/>
##
##  <Description>
##  <Ref Attr="SortingPerm"/> returns the same as <Ref Oper="Sortex"/>
##  but does <E>not</E> change the argument.
##  <P/>
##  <Example><![CDATA[
##  gap> list1 := [ 5, 4, 6, 1, 7, 5 ];;
##  gap> list2 := ShallowCopy( list1 );;
##  gap> perm := SortingPerm( list1 );
##  (1,3,5,6,4)
##  gap> list1;
##  [ 5, 4, 6, 1, 7, 5 ]
##  gap> Permuted( list2, perm );
##  [ 1, 4, 5, 5, 6, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SortingPerm", IsList );


#############################################################################
##
#F  PermListList( <list1>, <list2> ) . what permutation of <list1> is <list2>
##
##  <#GAPDoc Label="PermListList">
##  <ManSection>
##  <Func Name="PermListList" Arg='list1, list2'/>
##
##  <Description>
##  returns a permutation <M>p</M> of <C>[ 1 .. Length( <A>list1</A> ) ]</C>
##  such that <A>list1</A><M>[i</M><C>^</C><M>p] =</M> <A>list2</A><M>[i]</M>.
##  It returns <K>fail</K> if there is no such permutation.
##  <P/>
##  <Example><![CDATA[
##  gap> list1 := [ 5, 4, 6, 1, 7, 5 ];;
##  gap> list2 := [ 4, 1, 7, 5, 5, 6 ];;
##  gap> perm := PermListList(list1, list2);
##  (1,2,4)(3,5,6)
##  gap> Permuted( list2, perm );
##  [ 5, 4, 6, 1, 7, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PermListList" );


#############################################################################
##
#O  SortParallel( <list1>, <list2>[, <func>] )  .  sort two lists in parallel
##
##  <#GAPDoc Label="SortParallel">
##  <ManSection>
##  <Oper Name="SortParallel" Arg='list1, list2[, func]'/>
##  <Oper Name="StableSortParallel" Arg='list1, list2[, func]'/>
##
##  <Description>
##  <Ref Oper="SortParallel"/> sorts the list <A>list1</A> in increasing order
##  just as <Ref Oper="Sort"/> does.
##  In parallel it applies the same exchanges that are necessary to sort
##  <A>list1</A> to the list <A>list2</A>,
##  which must of course have at least as many elements as <A>list1</A> does.
##  <P/>
##  <Ref Oper="StableSortParallel"/> behaves identically to
##  <Ref Oper="SortParallel"/>, except it keeps elements in <A>list1</A> which
##  compare equal in the same relative order.
##  <P/>
##  <Example><![CDATA[
##  gap> list1 := [ 5, 4, 6, 1, 7, 5 ];;
##  gap> list2 := [ 2, 3, 5, 7, 8, 9 ];;
##  gap> SortParallel( list1, list2 );
##  gap> list1;
##  [ 1, 4, 5, 5, 6, 7 ]
##  gap> list2;
##  [ 7, 3, 2, 9, 5, 8 ]
##  ]]></Example>
##  <P/>
##  Note that <C>[ 7, 3, 2, 9, 5, 8 ]</C> or <C>[ 7, 3, 9, 2, 5, 8 ]</C>
##  are possible results. <Ref Oper="StableSortParallel"/> will always
##  return <C>[ 7, 3, 2, 9, 5, 8]</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SortParallel",
    [ IsList and IsMutable, IsList and IsMutable ] );
DeclareOperation( "SortParallel",
    [ IsList and IsMutable, IsList and IsMutable, IsFunction ] );

DeclareOperation( "StableSortParallel",
    [ IsList and IsMutable, IsList and IsMutable ] );
DeclareOperation( "StableSortParallel",
    [ IsList and IsMutable, IsList and IsMutable, IsFunction ] );


#############################################################################
##
#F  Maximum( <obj1>, <obj2>, ... )  . . . . . . . . . . .  maximum of objects
#F  Maximum( <list> )
##
##  <#GAPDoc Label="Maximum">
##  <ManSection>
##  <Heading>Maximum</Heading>
##  <Func Name="Maximum" Arg='obj1, obj2, ...' Label="for various objects"/>
##  <Func Name="Maximum" Arg='list' Label="for a list"/>
##
##  <Description>
##  In the first form <Ref Func="Maximum" Label="for various objects"/>
##  returns the <E>maximum</E> of its arguments, i.e.,
##  one argument <A>obj</A> for which <M><A>obj</A> \geq <A>obj1</A></M>,
##  <M><A>obj</A> \geq <A>obj2</A></M> etc.
##  <P/>
##  In the second form <Ref Func="Maximum" Label="for a list"/> takes a
##  homogeneous list <A>list</A> and returns the maximum of the elements in
##  this list.
##  <P/>
##  <Example><![CDATA[
##  gap> Maximum( -123, 700, 123, 0, -1000 );
##  700
##  gap> Maximum( [ -123, 700, 123, 0, -1000 ] );
##  700
##  gap> # lists are compared elementwise:
##  gap> Maximum( [1,2], [0,15], [1,5], [2,-11] );
##  [ 2, -11 ]
##  ]]></Example>
##  To get the index of the maximum element use <Ref Func="PositionMaximum"/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Maximum" );


#############################################################################
##
#F  Minimum( <obj1>, <obj2>, ... )  . . . . . . . . . . .  minimum of objects
#F  Minimum( <list> )
##
##  <#GAPDoc Label="Minimum">
##  <ManSection>
##  <Heading>Minimum</Heading>
##  <Func Name="Minimum" Arg='obj1, obj2, ...' Label="for various objects"/>
##  <Func Name="Minimum" Arg='list' Label="for a list"/>
##
##  <Description>
##  In the first form <Ref Func="Minimum" Label="for various objects"/>
##  returns the <E>minimum</E> of its arguments, i.e.,
##  one argument <A>obj</A> for which <M><A>obj</A> \leq <A>obj1</A></M>,
##  <M><A>obj</A> \leq <A>obj2</A></M> etc.
##  <P/>
##  In the second form <Ref Func="Minimum" Label="for a list"/> takes a
##  homogeneous list <A>list</A> and returns the minimum of the elements in
##  this list.
##  <P/>
##  Note that for both <Ref Func="Maximum" Label="for various objects"/> and
##  <Ref Func="Minimum" Label="for various objects"/> the comparison of the
##  objects <A>obj1</A>, <A>obj2</A> etc.&nbsp;must be defined;
##  for that, usually they must lie in the same family
##  (see&nbsp;<Ref Sect="Families"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> Minimum( -123, 700, 123, 0, -1000 );
##  -1000
##  gap> Minimum( [ -123, 700, 123, 0, -1000 ] );
##  -1000
##  gap> Minimum( [ 1, 2 ], [ 0, 15 ], [ 1, 5 ], [ 2, -11 ] );
##  [ 0, 15 ]
##  ]]></Example>
##  To get the index of the minimum element use <Ref Func="PositionMinimum"/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Minimum" );


#############################################################################
##
#O  MaximumList( <list> )  . . . . . . . . . . . . . . . .  maximum of a list
#O  MinimumList( <list> )  . . . . . . . . . . . . . . . .  minimum of a list
##
##  <#GAPDoc Label="MaximumList">
##  <ManSection>
##  <Heading>MaximumList and MinimumList</Heading>
##  <Oper Name="MaximumList" Arg='list [seed]'/>
##  <Oper Name="MinimumList" Arg='list [seed]'/>
##
##  <Description>
##  return the maximum resp.&nbsp;the minimum of the elements in the list
##  <A>list</A>.
##  They are the operations called by
##  <Ref Func="Maximum" Label="for various objects"/>
##  resp.&nbsp;<Ref Func="Minimum" Label="for various objects"/>.
##  Methods can be installed for special kinds of lists.
##  For example, there are special methods to compute the maximum
##  resp.&nbsp;the minimum of a range (see&nbsp;<Ref Sect="Ranges"/>).
##  <P/>
##  If a second argument <A>seed</A> is supplied, then the result is the
##  maximum resp.&nbsp;minimum of the union of <A>list</A> and <A>seed</A>.
##  In this manner, the operations may be applied to empty lists.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MaximumList", [ IsList ] );
DeclareOperation( "MaximumList", [ IsList, IsObject ] );

DeclareOperation( "MinimumList", [ IsList ] );
DeclareOperation( "MinimumList", [ IsList, IsObject ] );


#############################################################################
##
#F  Cartesian( <list1>, <list2>, ... )  . . . . .  cartesian product of lists
#F  Cartesian( <list> )
##
##  <#GAPDoc Label="Cartesian">
##  <ManSection>
##  <Heading>Cartesian</Heading>
##  <Func Name="Cartesian" Arg='list1, list2, ...'
##   Label="for various objects"/>
##  <Func Name="Cartesian" Arg='list' Label="for a list"/>
##
##  <Description>
##  In the first form <Ref Func="Cartesian" Label="for various objects"/>
##  returns the cartesian product of the lists <A>list1</A>, <A>list2</A>,
##  etc.
##  <P/>
##  In the second form <A>list</A> must be a list of lists <A>list1</A>,
##  <A>list2</A>, etc.,
##  and <Ref Func="Cartesian" Label="for a list"/> returns the cartesian
##  product of those lists.
##  <P/>
##  The <E>cartesian product</E> is a list <A>cart</A> of lists <A>tup</A>,
##  such that the first element of <A>tup</A> is an element of <A>list1</A>,
##  the second element of <A>tup</A> is an element of <A>list2</A>,
##  and so on.
##  The total number of elements in <A>cart</A> is the product of the lengths
##  of the argument lists.
##  In particular <A>cart</A> is empty if and only if at least one of the
##  argument lists is empty.
##  Also <A>cart</A> contains duplicates if and only if no argument list is
##  empty and at least one contains duplicates.
##  <P/>
##  The last index runs fastest.
##  That means that the first element <A>tup1</A> of <A>cart</A> contains
##  the first element from <A>list1</A>, from <A>list2</A> and so on.
##  The second element <A>tup2</A> of <A>cart</A> contains the first element
##  from <A>list1</A>, the first from <A>list2</A>, and so on,
##  but the last element of <A>tup2</A> is the second element of the last
##  argument list.
##  This implies that <A>cart</A> is a proper set if and only if all argument
##  lists are proper sets (see&nbsp;<Ref Sect="Sorted Lists and Sets"/>).
##  <P/>
##  The function <Ref Func="Tuples"/> computes the  <A>k</A>-fold cartesian
##  product of a list.
##  <P/>
##  <Example><![CDATA[
##  gap> Cartesian( [1,2], [3,4], [5,6] );
##  [ [ 1, 3, 5 ], [ 1, 3, 6 ], [ 1, 4, 5 ], [ 1, 4, 6 ], [ 2, 3, 5 ],
##    [ 2, 3, 6 ], [ 2, 4, 5 ], [ 2, 4, 6 ] ]
##  gap> Cartesian( [1,2,2], [1,1,2] );
##  [ [ 1, 1 ], [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], [ 2, 1 ], [ 2, 2 ],
##    [ 2, 1 ], [ 2, 1 ], [ 2, 2 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Cartesian" );


#############################################################################
##
#O  Permuted(<list>,<perm>)  . . . . . . . . .  apply a permutation to a list
##
##  <#GAPDoc Label="Permuted">
##  <ManSection>
##  <Oper Name="Permuted" Arg='list,perm'/>
##
##  <Description>
##  returns a new list <A>new</A> that contains the elements of the
##  list <A>list</A> permuted according to the permutation <A>perm</A>.
##  That is <C><A>new</A>[<A>i</A>^<A>perm</A>] = <A>list</A>[<A>i</A>]</C>
##  whenever <C><A>list</A>[<A>i</A>]</C> is bound.
##  <P/>
##  <Ref Oper="Sortex"/> allows you to compute a permutation that must
##  be applied to a list in order to get the sorted list.
##  <P/>
##  <Example><![CDATA[
##  gap> Permuted( [ 5, 4, 6, 1, 7, 5 ], (1,3,5,6,4) );
##  [ 1, 4, 5, 5, 6, 7 ]
##  gap> Permuted( [ 5, 4, 6,, 7, 5 ], (1,3,5,6,4) );
##  [ , 4, 5, 5, 6, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Permuted", [ IsList, IS_PERM ] );


#############################################################################
##
#F  IteratorList( <list> )
##
##  <#GAPDoc Label="IteratorList">
##  <ManSection>
##  <Func Name="IteratorList" Arg='list'/>
##
##  <Description>
##  <Ref Func="IteratorList"/> returns a new iterator that allows iteration
##  over the elements of the list <A>list</A> (which may have holes)
##  in the same order.
##  <P/>
##  If <A>list</A> is mutable then it is in principle possible to change
##  <A>list</A> after the call of <Ref Func="IteratorList"/>.
##  In this case all changes concerning positions that have not yet been
##  reached in the iteration will also affect the iterator.
##  For example, if <A>list</A> is enlarged then the iterator will iterate
##  also over the new elements at the end of the changed list.
##  <P/>
##  <E>Note</E> that changes of <A>list</A> will also affect all
##  shallow copies of <A>list</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IteratorList" );


#############################################################################
##
#F  First( <list>[, <func>] ) .  find first element in a list with a property
##
##  <#GAPDoc Label="First">
##  <ManSection>
##  <Oper Name="First" Arg='list[, func]'/>
##
##  <Description>
##  <Ref Oper="First"/> returns the first element of the list <A>list</A>
##  for which the unary function <A>func</A> returns <K>true</K>;
##  if <A>func</A> is not given, the first element is returned.
##  <A>list</A> may contain holes.
##  <A>func</A> must return either <K>true</K> or <K>false</K> for each
##  element of <A>list</A>, otherwise an error is signalled.
##  If <A>func</A> returns <K>false</K> for all elements of <A>list</A>
##  then <Ref Oper="First"/> returns <K>fail</K>.
##  <P/>
##  <Ref Oper="PositionProperty"/> allows you to find the
##  position of the first element in a list that satisfies a certain
##  property.
##  <P/>
##  Before &GAP; 4.12, developers who wished to adapt this for custom
##  list types needed to install suitable methods for the operation
##  <C>FirstOp</C>. This is still possible for backwards compatibility,
##  but <C>FirstOp</C> now is just a synonym for <Ref Oper="First"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> First( [10^7..10^8], IsPrime );
##  10000019
##  gap> First( [10^5..10^6],
##  >      n -> not IsPrime(n) and IsPrimePowerInt(n) );
##  100489
##  gap> First( [ 1 .. 20 ], x -> x < 0 );
##  fail
##  gap> First( [ fail ], x -> x = fail );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "First", [ IsListOrCollection ] );
DeclareOperation( "First", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#F  Last( <list>[, <func>] ) . .  find last element in a list with a property
##
##  <#GAPDoc Label="Last">
##  <ManSection>
##  <Func Name="Last" Arg='list[, func]'/>
##
##  <Description>
##  <Ref Func="Last"/> returns the last element of the list <A>list</A>
##  for which the unary function <A>func</A> returns <K>true</K>;
##  if <A>func</A> is not given, the last element is returned.
##  <A>list</A> may contain holes.
##  <A>func</A> must return either <K>true</K> or <K>false</K> for each
##  element of <A>list</A>, otherwise an error is signalled.
##  If <A>func</A> returns <K>false</K> for all elements of <A>list</A>
##  then <Ref Func="Last"/> returns <K>fail</K>.
##  <P/>
##  Developers who wish to adapt this for custom list types need to
##  install suitable methods for the operation <C>LastOp</C>.
##  <Index Key="LastOp"><C>LastOp</C></Index>
##  <P/>
##  <Example><![CDATA[
##  gap> Last( [10^7..10^8], IsPrime );
##  99999989
##  gap> Last( [10^5..10^6],
##  >      n -> not IsPrime(n) and IsPrimePowerInt(n) );
##  994009
##  gap> Last( [ 1 .. 20 ], x -> x < 0 );
##  fail
##  gap> Last( [ fail ], x -> x = fail );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  We catch internal lists by a function to avoid method selection:
DeclareGlobalFunction( "Last" );
DeclareOperation( "LastOp", [ IsListOrCollection ] );
DeclareOperation( "LastOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  Iterated( <list>, <f> ) . . . . . . . . .  iterate a function over a list
##
##  <#GAPDoc Label="Iterated">
##  <ManSection>
##  <Oper Name="Iterated" Arg='list, f'/>
##
##  <Description>
##  returns the result of the iterated application of the function
##  <A>f</A>, which must take two arguments,
##  to the elements of the list <A>list</A>.
##  More precisely, if <A>list</A> has length <M>n</M> then
##  <Ref Oper="Iterated"/> returns the result of the following application,
##  <M><A>f</A>( \ldots <A>f</A>( <A>f</A>( <A>list</A>[1], <A>list</A>[2] ),
##  <A>list</A>[3] ), \ldots, <A>list</A>[n] )</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> Iterated( [ 126, 66, 105 ], Gcd );
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Iterated", [ IsList, IsFunction ] );


#############################################################################
##
#F  ListN( <list1>, <list2>, ..., <listn>, <f> )
##
##  <#GAPDoc Label="ListN">
##  <ManSection>
##  <Func Name="ListN" Arg='list1, list2, ..., listn, f'/>
##
##  <Description>
##  applies the <M>n</M>-argument function <A>f</A> to the lists.
##  That is, <Ref Func="ListN"/> returns the list whose <M>i</M>-th entry is
##  <M><A>f</A>(<A>list1</A>[i], <A>list2</A>[i], \ldots,
##  <A>listn</A>[i])</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> ListN( [1,2], [3,4], \+ );
##  [ 4, 6 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ListN" );


#############################################################################
##
#F  UnionBlist( <blist1>, <blist2>[, ...] )
#F  UnionBlist( <list> )
##
##  <#GAPDoc Label="UnionBlist">
##  <ManSection>
##  <Heading>UnionBlist</Heading>
##  <Func Name="UnionBlist" Arg='blist1,blist2[,...]'
##   Label="for various boolean lists"/>
##  <Func Name="UnionBlist" Arg='list' Label="for a list"/>
##
##  <Description>
##  In the first form
##  <Ref Func="UnionBlist" Label="for various boolean lists"/> returns the
##  union of the boolean lists <A>blist1</A>, <A>blist2</A>, etc.,
##  which must have equal length.
##  The <E>union</E> is a new boolean list that contains at position <M>i</M>
##  the value <A>blist1</A><M>[i]</M> <K>or</K>
##  <A>blist2</A><M>[i]</M> <K>or</K> <M>\ldots</M>.
##  <P/>
##  The second form takes the union of all blists (which
##  as for the first form must have equal length) in the list <A>list</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "UnionBlist" );


#############################################################################
##
#F  DifferenceBlist( <blist1>, <blist2> )
##
##  <#GAPDoc Label="DifferenceBlist">
##  <ManSection>
##  <Func Name="DifferenceBlist" Arg='blist1, blist2'/>
##
##  <Description>
##  returns the asymmetric set difference of the two
##  boolean lists <A>blist1</A> and <A>blist2</A>,
##  which must have equal length.
##  The <E>asymmetric set difference</E> is a new boolean list that contains
##  at position <M>i</M> the value
##  <A>blist1</A><M>[i]</M> <K>and</K> <K>not</K>
##  <A>blist2</A><M>[i]</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> blist1 := [ true, true, false, false ];;
##  gap> blist2 := [ true, false, true, false ];;
##  gap> UnionBlist( blist1, blist2 );
##  [ true, true, true, false ]
##  gap> IntersectionBlist( blist1, blist2 );
##  [ true, false, false, false ]
##  gap> DifferenceBlist( blist1, blist2 );
##  [ false, true, false, false ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DifferenceBlist");


#############################################################################
##
#F  IntersectionBlist( <blist1>, <blist2>[, ...] )
#F  IntersectionBlist( <list> )
##
##  <#GAPDoc Label="IntersectionBlist">
##  <ManSection>
##  <Heading>IntersectionBlist</Heading>
##  <Func Name="IntersectionBlist" Arg='blist1,blist2[,...]'
##   Label="for various boolean lists"/>
##  <Func Name="IntersectionBlist" Arg='list' Label="for a list"/>
##
##  <Description>
##  In the first form
##  <Ref Func="IntersectionBlist" Label="for various boolean lists"/> returns
##  the intersection of the boolean lists <A>blist1</A>, <A>blist2</A>, etc.,
##  which must have equal length.
##  The <E>intersection</E> is a new blist that contains at position <M>i</M>
##  the value <A>blist1</A><M>[i]</M>
##  <K>and</K> <A>blist2</A><M>[i]</M> <K>and</K> <M>\ldots</M>.
##  <P/>
##  In the second form <A>list</A> must be a list of boolean lists
##  <A>blist1</A>, <A>blist2</A>, etc., which must have equal length,
##  and <Ref Func="IntersectionBlist" Label="for a list"/> returns the
##  intersection of those boolean lists.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IntersectionBlist" );


#############################################################################
##
#F  ListWithIdenticalEntries( <n>, <obj> )
##
##  <#GAPDoc Label="ListWithIdenticalEntries">
##  <ManSection>
##  <Func Name="ListWithIdenticalEntries" Arg='n, obj'/>
##
##  <Description>
##  is a list <A>list</A> of length <A>n</A> that has the object <A>obj</A>
##  stored at each of the positions from <C>1</C> to <A>n</A>.
##  Note that all elements of <A>lists</A> are identical,
##  see&nbsp;<Ref Sect="Identical Lists"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> ListWithIdenticalEntries( 10, 0 );
##  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ListWithIdenticalEntries" );

#############################################################################
##
#O  PositionNot( <list>, <val>[, <from>] )  . . . . . . . . .  find not <val>
##
##  <#GAPDoc Label="PositionNot">
##  <ManSection>
##  <Oper Name="PositionNot" Arg='list, val[, from]'/>
##
##  <Description>
##  For a list <A>list</A> and an object <A>val</A>,
##  <Ref Oper="PositionNot"/> returns the smallest
##  nonnegative integer <M>n</M> such that <M><A>list</A>[n]</M>
##  is either unbound or not equal to <A>val</A>.
##  If a starting index <A>from</A> is given, it
##  returns the first position with this property
##  starting the search <E>after</E> position <A>from</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> l:= [ 1, 1, 2, 3, 2 ];;  PositionNot( l, 1 );
##  3
##  gap> PositionNot( l, 1, 4 );  PositionNot( l, 2, 4 );
##  5
##  6
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionNot", [ IsList, IsObject ] );
DeclareOperation( "PositionNot", [ IsList, IsObject, IS_INT ] );


#############################################################################
##
#O  PositionNonZero( <vec>[, <from>] ) . . . position of first non-zero entry
##
##  <#GAPDoc Label="PositionNonZero">
##  <ManSection>
##  <Oper Name="PositionNonZero" Arg='vec[, from]'/>
##
##  <Description>
##  For a row vector <A>vec</A>,
##  <Ref Oper="PositionNonZero"/> returns the position of the
##  first non-zero element of <A>vec</A>,
##  or <C>Length(</C> <A>vec</A> <C>)+1</C> if all entries of
##  <A>vec</A> are zero.
##  <P/>
##  If a starting index <A>from</A> is given,
##  it returns the position of the first occurrence starting the search
##  <E>after</E> position <A>from</A>.
##  <P/>
##  <Ref Oper="PositionNonZero"/> implements a special case of
##  <Ref Oper="PositionNot"/>.
##  Namely, the element to be avoided is the zero element,
##  and the list must be (at least) homogeneous
##  because otherwise the zero element cannot be specified implicitly.
##  <P/>
##  <Example><![CDATA[
##  gap> PositionNonZero( [ 1, 1, 2, 3, 2 ] );
##  1
##  gap> PositionNonZero( [ 2, 3, 4, 5 ] * Z(2) );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionNonZero", [ IsHomogeneousList ] );
DeclareOperation( "PositionNonZero", [ IsHomogeneousList, IS_INT ] );


#############################################################################
##
#P  IsDuplicateFreeCollection
##
##  <ManSection>
##  <Prop Name="IsDuplicateFreeCollection" Arg='obj'/>
##
##  <Description>
##  Needs to be after DeclareSynonym is declared
##  </Description>
##  </ManSection>
##
DeclareSynonym("IsDuplicateFreeCollection", IsCollection and IsDuplicateFree);


#############################################################################
##
#F  HexStringBlist(<b>)
##
##  <ManSection>
##  <Func Name="HexStringBlist" Arg='b'/>
##
##  <Description>
##  takes a binary list and returns a hex string representing this blist.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("HexStringBlist");


#############################################################################
##
#F  HexStringBlistEncode(<b>)
##
##  <ManSection>
##  <Func Name="HexStringBlistEncode" Arg='b'/>
##
##  <Description>
##  works like <Ref Func="HexStringBlist"/>, but uses <C>s<A>xx</A></C>
##  (<A>xx</A> is a hex number up to 255) to indicate skips of zeroes.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("HexStringBlistEncode");


#############################################################################
##
#F  BlistStringDecode(<s>,[<l>])
##
##  <ManSection>
##  <Func Name="BlistStringDecode" Arg='s,[l]'/>
##
##  <Description>
##  takes a string as produced by <Ref Func="HexStringBlist"/> and
##  <Ref Func="HexStringBlistEncode"/> and returns a binary list.
##  If a length <A>l</A> is given the list is filed with <K>false</K> or
##  trimmed to obtain this length,
##  otherwise the list has the length as given by the string (this might
##  leave out or add some trailing <K>false</K> values.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("BlistStringDecode");


#############################################################################
##
#F  Average(l);
#F  Median(l);
#F  Variance(l);
##
##  For a nonempty list of objects that can be ordered totally and permit
##  scalar multiplication by rational numbers, these functions compute the
##  average, median, and variance of the objects in the list.
##
DeclareGlobalFunction("Average");
DeclareGlobalFunction("Median");
DeclareGlobalFunction("Variance");
