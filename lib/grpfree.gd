#############################################################################
##
#W  grpfree.gd                  GAP library                     Werner Nickel
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Free groups are treated as   special cases of finitely presented  groups.
##  In addition,   elements  of  a free   group are
##  (associative) words, that is they have a normal  form that allows an easy
##  equalitity test.  
##


#############################################################################
##
#F  IsElementOfFreeGroup  . . . . . . . . . . . . .  elements in a free group
##
##  <ManSection>
##  <Func Name="IsElementOfFreeGroup" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "IsElementOfFreeGroup", IsAssocWordWithInverse );
DeclareSynonym( "IsElementOfFreeGroupFamily",IsAssocWordWithInverseFamily );


#############################################################################
##
#F  FreeGroup( [<wfilt>,]<rank> )
#F  FreeGroup( [<wfilt>,]<rank>, <name> )
#F  FreeGroup( [<wfilt>,]<name1>, <name2>, ... )
#F  FreeGroup( [<wfilt>,]<names> )
#F  FreeGroup( [<wfilt>,]infinity, <name>, <init> )
##
##  <#GAPDoc Label="FreeGroup">
##  <ManSection>
##  <Heading>FreeGroup</Heading>
##  <Func Name="FreeGroup" Arg='[wfilt, ]rank[, name]'
##   Label="for given rank"/>
##  <Func Name="FreeGroup" Arg='[wfilt, ]name1, name2, ...'
##   Label="for various names"/>
##  <Func Name="FreeGroup" Arg='[wfilt, ]names'
##   Label="for a list of names"/>
##  <Func Name="FreeGroup" Arg='[wfilt, ]infinity, name, init'
##   Label="for infinitely many generators"/>
##
##  <Description>
##  Called with a positive integer <A>rank</A>,
##  <Ref Func="FreeGroup" Label="for given rank"/> returns
##  a free group on <A>rank</A> generators.
##  If the optional argument <A>name</A> is given then the generators are
##  printed as <A>name</A><C>1</C>, <A>name</A><C>2</C> etc.,
##  that is, each name is the concatenation of the string <A>name</A> and an
##  integer from <C>1</C> to <A>range</A>.
##  The default for <A>name</A> is the string <C>"f"</C>.
##  <P/>
##  Called in the second form,
##  <Ref Func="FreeGroup" Label="for various names"/> returns
##  a free group on as many generators as arguments, printed as
##  <A>name1</A>, <A>name2</A> etc.
##  <P/>
##  Called in the third form,
##  <Ref Func="FreeGroup" Label="for a list of names"/> returns
##  a free group on as many generators as the length of the list
##  <A>names</A>, the <M>i</M>-th generator being printed as
##  <A>names</A><C>[</C><M>i</M><C>]</C>.
##  <P/>
##  Called in the fourth form,
##  <Ref Func="FreeGroup" Label="for infinitely many generators"/>
##  returns a free group on infinitely many generators, where the first
##  generators are printed by the names in the list <A>init</A>,
##  and the other generators by <A>name</A> and an appended number.
##  <P/>
##  If the extra argument <A>wfilt</A> is given, it must be either
##  <C>IsSyllableWordsFamily</C> or <C>IsLetterWordsFamily</C> or
##  <C>IsWLetterWordsFamily</C> or <C>IsBLetterWordsFamily</C>.
##  This filter then specifies the representation used for the elements of
##  the free group
##  (see&nbsp;<Ref Sect="Representations for Associative Words"/>).
##  If no such filter is given, a letter representation is used.
##  <P/>
##  (For interfacing to old code that omits the representation flag, use of
##  the syllable representation is also triggered by setting the option
##  <C>FreeGroupFamilyType</C> to the string <C>"syllable"</C>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeGroup" );


#############################################################################
##
#E

