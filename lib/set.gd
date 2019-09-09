#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains some functions for proper sets.
##
##  <#GAPDoc Label="[1]{set}">
##  The following functions, if not explicitly stated differently,
##  take two arguments, <A>set</A> and <A>obj</A>,
##  where <A>set</A> must be a proper set,
##  otherwise an error is signalled;
##  If the second argument <A>obj</A> is a list that is not a proper set
##  then <Ref Oper="Set"/> is silently applied to it first.
##  <#/GAPDoc>
##


#############################################################################
##
#F  SSortedListList( <list> ) . . . . . . . . . . . . . . . . . set of <list>
##
##  <ManSection>
##  <Func Name="SSortedListList" Arg='list'/>
##
##  <Description>
##  <Ref Func="SSortedListList"/> returns a mutable, strictly sorted list
##  containing the same elements as the <E>internally represented</E> list
##  <A>list</A> (which may have holes).
##  <Ref Func="SSortedListList"/> makes a shallow copy, sorts it,
##  and removes duplicates.
##  <Ref Func="SSortedListList"/> is an internal function.
##  </Description>
##  </ManSection>
##
DeclareSynonym( "SSortedListList", LIST_SORTED_LIST );


#############################################################################
##
#O  IsEqualSet( <list1>, <list2> )  . . . .  check if lists are equal as sets
##
##  <#GAPDoc Label="IsEqualSet">
##  <ManSection>
##  <Oper Name="IsEqualSet" Arg='list1, list2'/>
##
##  <Description>
##  <Index Subkey="for set equality">test</Index>
##  tests whether <A>list1</A> and <A>list2</A> are equal
##  <E>when viewed as sets</E>, that is if every element of <A>list1</A> is
##  an element of <A>list2</A> and vice versa.
##  Either argument of <Ref Oper="IsEqualSet"/> may also be a list that is
##  not a proper set, in which case <Ref Oper="Set"/> is applied to it first.
##  <P/>
##  If both lists are proper sets then they are of course equal if and only
##  if they are also equal as lists.
##  Thus <C>IsEqualSet( <A>list1</A>, <A>list2</A> )</C> is equivalent to
##  <C>Set( <A>list1</A>  ) = Set( <A>list2</A> )</C>
##  (see&nbsp;<Ref Oper="Set"/>), but the former is more efficient.
##  <P/>
##  <Example><![CDATA[
##  gap> IsEqualSet( [2,3,5,7,11], [11,7,5,3,2] );
##  true
##  gap> IsEqualSet( [2,3,5,7,11], [2,3,5,7,11,13] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsEqualSet", [ IsList, IsList ] );


#############################################################################
##
#O  IsSubsetSet( <list1>, <list2> ) . check if <list2> is a subset of <list1>
##
##  <#GAPDoc Label="IsSubsetSet">
##  <ManSection>
##  <Oper Name="IsSubsetSet" Arg='list1, list2'/>
##
##  <Description>
##  tests whether every element of <A>list2</A> is contained in <A>list1</A>.
##  Either argument of <Ref Oper="IsSubsetSet"/> may also be a list
##  that is not a proper set,
##  in which case <Ref Oper="Set"/> is applied to it first.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsSubsetSet", [ IsList, IsList ] );


#############################################################################
##
#O  AddSet( <set>, <obj> )  . . . . . . . . . . . . . . .  add <obj> to <set>
##
##  <#GAPDoc Label="AddSet">
##  <ManSection>
##  <Oper Name="AddSet" Arg='set, obj'/>
##
##  <Description>
##  <Index Subkey="an element to a set">add</Index>
##  adds the element <A>obj</A> to the proper set <A>set</A>.
##  If <A>obj</A> is already contained in <A>set</A> then <A>set</A> is not
##  changed.
##  Otherwise <A>obj</A> is inserted at the correct position such that
##  <A>set</A> is again a proper set afterwards.
##  <P/>
##  Note that <A>obj</A> must be in the same family as each element of
##  <A>set</A>.
##  <Example><![CDATA[
##  gap> s := [2,3,7,11];;
##  gap> AddSet( s, 5 );  s;
##  [ 2, 3, 5, 7, 11 ]
##  gap> AddSet( s, 13 );  s;
##  [ 2, 3, 5, 7, 11, 13 ]
##  gap> AddSet( s, 3 );  s;
##  [ 2, 3, 5, 7, 11, 13 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AddSet", [ IsList and IsMutable, IsObject ] );


#############################################################################
##
#O  RemoveSet( <set>, <obj> ) . . . . . . . . . . . . remove <obj> from <set>
##
##  <#GAPDoc Label="RemoveSet">
##  <ManSection>
##  <Oper Name="RemoveSet" Arg='set, obj'/>
##
##  <Description>
##  <Index Subkey="an element from a set">remove</Index>
##  removes the element <A>obj</A> from the proper set <A>set</A>.
##  If <A>obj</A> is not contained in <A>set</A> then <A>set</A> is not
##  changed.
##  If <A>obj</A> is an element of <A>set</A> it is removed and all the
##  following elements in the list are moved one position forward.
##  <P/>
##  <Example><![CDATA[
##  gap> s := [ 2, 3, 4, 5, 6, 7 ];;
##  gap> RemoveSet( s, 6 ); s;
##  [ 2, 3, 4, 5, 7 ]
##  gap> RemoveSet( s, 10 ); s;
##  [ 2, 3, 4, 5, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RemoveSet", [ IsList and IsMutable, IsObject ] );


#############################################################################
##
#O  UniteSet( <set>, <list> ) . . . . . . . . . . . . unite <set> with <list>
##
##  <#GAPDoc Label="UniteSet">
##  <ManSection>
##  <Oper Name="UniteSet" Arg='set, list'/>
##
##  <Description>
##  <Index Subkey="of sets">union</Index>
##  unites the proper set <A>set</A> with <A>list</A>.
##  This is equivalent to adding all elements of <A>list</A> to <A>set</A>
##  (see&nbsp;<Ref Oper="AddSet"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> set := [ 2, 3, 5, 7, 11 ];;
##  gap> UniteSet( set, [ 4, 8, 9 ] );  set;
##  [ 2, 3, 4, 5, 7, 8, 9, 11 ]
##  gap> UniteSet( set, [ 16, 9, 25, 13, 16 ] );  set;
##  [ 2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 25 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UniteSet", [ IsList and IsMutable, IsList ] );


#############################################################################
##
#O  IntersectSet( <set>, <list> ) . . . . . . . . intersect <set> with <list>
##
##  <#GAPDoc Label="IntersectSet">
##  <ManSection>
##  <Oper Name="IntersectSet" Arg='set, list'/>
##
##  <Description>
##  <Index Subkey="of sets">intersection</Index>
##  intersects the proper set <A>set</A> with <A>list</A>.
##  This is equivalent to removing from <A>set</A> all elements of <A>set</A>
##  that are not contained in <A>list</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> set := [ 2, 3, 4, 5, 7, 8, 9, 11, 13, 16 ];;
##  gap> IntersectSet( set, [ 3, 5, 7, 9, 11, 13, 15, 17 ] );  set;
##  [ 3, 5, 7, 9, 11, 13 ]
##  gap> IntersectSet( set, [ 9, 4, 6, 8 ] );  set;
##  [ 9 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IntersectSet", [ IsList and IsMutable, IsList ] );


#############################################################################
##
#O  SubtractSet( <set>, <list> )  . . . . . remove <list> elements from <set>
##
##  <#GAPDoc Label="SubtractSet">
##  <ManSection>
##  <Oper Name="SubtractSet" Arg='set, list'/>
##
##  <Description>
##  <Index Subkey="a set from another">subtract</Index>
##  subtracts <A>list</A> from the proper set <A>set</A>.
##  This is equivalent to removing from <A>set</A> all elements of
##  <A>list</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> set := [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ];;
##  gap> SubtractSet( set, [ 6, 10 ] );  set;
##  [ 2, 3, 4, 5, 7, 8, 9, 11 ]
##  gap> SubtractSet( set, [ 9, 4, 6, 8 ] );  set;
##  [ 2, 3, 5, 7, 11 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SubtractSet", [ IsList and IsMutable, IsList ] );
