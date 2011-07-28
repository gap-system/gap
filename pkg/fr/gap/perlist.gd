#############################################################################
##
#W perlist.gd                                               Laurent Bartholdi
##
#H   @(#)$Id: perlist.gd,v 1.4 2011/06/13 22:54:35 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file declares periodic lists and FIFO's
##
#############################################################################

#############################################################################
##
#H Periodic lists
##
## <#GAPDoc Label="PeriodicLists">
## <ManSection>
##   <Fam Name="PeriodicListsFamily"/>
##   <Filt Name="IsPeriodicList"/>
##   <Description>
##     The family, respectively filter, of <Ref Oper="PeriodicList"/>s.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="PeriodicList" Arg="preperiod[,period]"/>
##   <Oper Name="PeriodicList" Arg="list,i" Label="period, looping point"/>
##   <Oper Name="PeriodicList" Arg="list,f" Label="list, function"/>
##   <Oper Name="CompressedPeriodicList" Arg="preperiod[,period]"/>
##   <Oper Name="CompressedPeriodicList" Arg="list,i" Label="period, looping point"/>
##   <Oper Name="PrePeriod" Arg="list"/>
##   <Oper Name="Period" Arg="list"/>
##   <Description>
##     These functions manipulate <E>periodic lists</E>, i.e. lists of
##     infinite length such that elements follow a periodic order after
##     some point.
##
##     <P/> The first command creates a periodic list, specified by
##     its preperiod and period, which must both be lists. If the period
##     is absent, this is actually a finite list.
##
##     <P/> The second command creates a periodic list by decreeing that
##     the entries after the end of the list start again at position
##     <A>i</A>.
##
##     <P/> The third command creates a list by applying function <A>f</A>
##     to all elements of <A>l</A>.
##
##     <P/> The fourth and fifth command compress the newly created
##     periodic list, see <Ref Oper="CompressPeriodicList"/>.
##
##     <P/> The sixth and seventh commands return respectively the preperiod
##     and period of a periodic list.
##
##     <P/> Most of the methods applied for lists have an obvious equivalent
##     for periodic lists: <Ref Oper="List" BookName="ref"/>,
##     <Ref Oper="Filtered" BookName="ref"/>,
##     <Ref Oper="First" BookName="ref"/>,
##     <Ref Oper="ForAll" BookName="ref"/>,
##     <Ref Oper="ForAny" BookName="ref"/>,
##     <Ref Oper="Number" BookName="ref"/>.
## <Example><![CDATA[
## gap> l := PeriodicList([1],[2,3,4]);
## [ 1, / 2, 3, 4 ]
## gap> l[5];
## 2
## gap> Add(l,100,3); l;
## [ 1, 2, 100, / 3, 4, 2 ]
## gap> Remove(l,5);
## 4
## gap> l;
## [ 1, 2, 100, 3, / 2, 3, 4 ]
## gap> PrePeriod(l);
## [ 1, 2, 100, 3 ]
## gap> Period(l);
## [ 2, 3, 4 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="CompressPeriodicList" Arg="l"/>
##   <Description>
##     This function compresses a periodic list, in replacing the
##     period by a minimal period, and shortening the preperiod. No
##     value is returned, but the list <A>l</A> is modified. It remains
##     equal (under <C>=</C>) to the original list.
## <Example><![CDATA[
## gap> l := PeriodicList([1],[2,3,4,2,3,4]);
## [ 1, / 2, 3, 4, 2, 3, 4 ]
## gap> Add(l,4,5); l;
## [ 1, 2, 3, 4, 4, / 2, 3, 4, 2, 3, 4 ]
## gap> CompressPeriodicList(l);
## gap> l;
## [ 1, 2, 3, 4, / 4, 2, 3 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="IsConfinal" Arg="l,m"/>
##   <Returns><K>true</K> if <A>l</A> and <A>m</A> are eventually equal.</Returns>
##   <Description>
##     This function tests whether two lists are <E>confinal</E>, i.e.
##     whether, after removal of the same suitable number of elements
##     from both lists, they become equal.
## <Example><![CDATA[
## gap> l := PeriodicList([1],[2,3,2,3]);
## [ 1, / 2, 3, 2, 3 ]
## gap> m := PeriodicList([0,1],[3,2]);
## [ 0, 1, / 3, 2 ]
## gap> IsConfinal(l,m);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="ConfinalityClass" Arg="l"/>
##   <Returns>The strictly periodic list with same tail as <A>l</A>.</Returns>
##   <Description>
##     There exists a unique periodic list, with no preperiod, which is
##     confinal (see <Ref Oper="IsConfinal"/>) to <A>l</A>. This strictly
##     periodic list is returned by this command.
## <Example><![CDATA[
## gap> l := PeriodicList([1],[2,3,2,3]);
## [ 1, / 2, 3, 2, 3 ]
## gap> ConfinalityClass(l);
## [/ 3, 2 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="LargestCommonPrefix" Arg="c"/>
##   <Returns>The longest list that is a prefix of all elements of <A>c</A>.</Returns>
##   <Description>
##     This command computes the longest (finite or periodic) list which is a
##     prefix of all elements of <A>c</A>. The argument <A>c</A> is a
##     collection of finite and periodic lists.
## <Example><![CDATA[
## gap> LargestCommonPrefix([PeriodicList([1],[2,3,2,3]),[1,2,3,4]]);
## [ 1, 2, 3 ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsPeriodicList",IsList);
BindGlobal("PeriodicListsFamily",
        NewFamily("PeriodicListsFamily",IsPeriodicList));
BindGlobal("TYPE_LIST_PERIODIC",
        NewType(PeriodicListsFamily,IsPeriodicList));
DeclareOperation("PeriodicList",[IsList]);
DeclareOperation("PeriodicList",[IsList,IsList]);
DeclareOperation("PeriodicList", [IsList, IsPosInt]);
DeclareOperation("PeriodicList", [IsList, IsFunction]);
DeclareOperation("Period", [IsPeriodicList]);
DeclareOperation("PrePeriod", [IsPeriodicList]);
DeclareOperation("CompressPeriodicList", [IsPeriodicList]);
DeclareGlobalFunction("CompressedPeriodicList");
DeclareOperation("IsConfinal",[IsPeriodicList,IsPeriodicList]);
DeclareOperation("ConfinalityClass",[IsPeriodicList]);
DeclareOperation("LargestCommonPrefix",[IsList]);
#############################################################################

#############################################################################
##
#H FIFOs
##
## <#GAPDoc Label="FIFOs">
## <ManSection>
##   <Filt Name="IsFIFO"/>
##   <Oper Name="NewFIFO" Arg="[l]"/>
##   <Oper Name="Add" Arg="f,i" Label="FIFO"/>
##   <Oper Name="Append" Arg="f,l" Label="FIFO"/>
##   <Description>
##     These functions create and extend FIFOs, i.e. first-in first-out
##     data structures.
##
##     <P/> The first command creates a FIFO, with an optional list
##     initializing it.
##
##     <P/> The second and third commands add an element, or append a list,
##     to the FIFO.
##
##     <P/> Elements are removed via <C>NextIterator(f)</C>, and the
##     FIFO is tested for emptyness via <C>IsDoneIterator(f)</C>. Thus,
##     a typical use is the following code, which tests in breadth-first
##     manner that all numbers in <C>[1..1000]</C> have a successor which is
##     prime:
## <Example><![CDATA[
## gap> f := NewFIFO([1..10000]);
## <iterator>
## gap> for i in f do if not IsPrime(i) then Add(f,i+1); fi; od;
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsFIFO",IsIterator and IsList);
DeclareOperation("NewFIFO",[IsList]);
DeclareOperation("NewFIFO",[]);
DeclareOperation("Add",[IsFIFO,IsObject]);
DeclareOperation("Append", [IsFIFO,IsObject]);
#############################################################################

#E perlist.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
