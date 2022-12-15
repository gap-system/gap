#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Götz Pfeiffer, Felix Noeske.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file  contains  the  declaration  of functions  needed for a  direct
##  computation of the character values of  wreath  products of a  group  $G$
##  with $S_n$, the  symmetric group  on  n points.  Special  cases  are  the
##  symmetric group $S_n$ itself  and the Weyl group  of type  $B_n$ which is
##  a wreath product of a  cyclic group $C_2$ of order 2  with  the symmetric
##  group $S_n$.
##
##  Moreover the character values of   alternating groups $A_n$ are  obtained
##  by  restriction from $S_n$ and  the  character  values of Weyl  groups of
##  type $D_n$ are obtained from those of type $B_n$.
##
##  The values are computed by a generalized Murnaghan-Nakayama formula.
##
##  For a good reference of used formulae see:
##  G. James, A.Kerber: The Representation Theory of the Symmetric Group,
##  Addison-Wesley, 1981.
##  A. Kerber, Representations of Permutation Groups I, Springer 1971.
##  A. Kerber, Representations of Permutation Groups II, Springer 1975.
##
##  Now  the classes (as  well  as the  characters)  of $S_n$ are indexed  by
##  partitions (i.e.  the  cycle structure of  the elements in  that  class).
##  In  general the   classes  (and  again  the  characters)  of  the  wreath
##  product $G  wr S_n$ are indexed  by  $r$-tuples of partitions,  where $r$
##  is  the number of   classes   of  the  group  $G$  and  these  partitions
##  together form a  partition of $n$.  That is  after distributing  $n$ over
##  $r$ places each place is partitioned.
##
##  There are different  ways  to  represent a  partition and we  make use of
##  two of them.
##
##  First there is  the  partition as  a   finite  nonincreasing sequence  of
##  numbers which sum up  to  $n$.  This representation serves to  compute  a
##  complete  list of  partitions  of $n$   and is stored in  the   resulting
##  table as value of `ClassParameters'.
##
##  The most beautiful way to treat  Young  tableaux and hooks of  partitions
##  is their  representation  as beta-numbers.    A  beta-number   is a  set,
##  which arises  from a  partition  by reversing  the   order  and  adding a
##  sequence [0,1,2,...] of   the  same    length.    Since this     reversed
##  partition  is   allowed to have   leading zeros,   its   beta-set  is not
##  uniquely  determined.  Each beta-set    however   determines  a    unique
##  partition.   For   example  a   beta-set for  the partition    [4,2,1] is
##  [1,3,6], another  one  [0,1,3,5,8].   To  remove    a  $k$-hook from  the
##  corresponding  Young  tableau  the beta-numbers  are  placed  as beads on
##  $k$ strings.
##
##  xxxx         _________      _________      _________        xxxx
##  xx            0  1  2        |  o  |        o  o  |
##  x             3  4  5        o  |  |   ->   |  |  |
##                6  |  |        o  |  |        o  |  |
##
##  To  find a removable  $k$-hook now  simply  means  to find a  free  place
##  for  a bead  one step  up  on its string,  the  hook is  then  removed by
##  lifting this  bead.  (You see  how  this process   can   produce  leading
##  zeros.)  Beta-numbers are used to parametrize the characters.
##
##  The case $2  wr S-n$  uses pairs  of these  objects  while  the   general
##  wreath product  uses  lists of them. A list  of beta-numbers is  called a
##  symbol.
##


#############################################################################
##
#F  BetaSet( <alpha> )  . . . . . . . . . . . . . . . . . . . . . . beta set.
##
##  <#GAPDoc Label="BetaSet">
##  <ManSection>
##  <Func Name="BetaSet" Arg='alpha'/>
##
##  <Description>
##  For a list <A>alpha</A> that describes a partition of a nonnegative
##  integer (see <Ref Func="Partitions"/>),
##  <Ref Func="BetaSet"/> returns the list of integers obtained by reversing
##  the order of <A>alpha</A>
##  and then adding the sequence <C>[ 0, 1, 2, ... ]</C> of the same length,
##  cf. <Cite Key="JK81" Where="Section 2.7"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> BetaSet( [ 4, 2, 1 ] );
##  [ 1, 3, 6 ]
##  gap> BetaSet( [] );
##  [  ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BetaSet" );


#############################################################################
##
#F  CentralizerWreath( <sub_cen>, <ptuple> )  . . . . centralizer in G wr Sn.
##
##  <ManSection>
##  <Func Name="CentralizerWreath" Arg='sub_cen, ptuple'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CentralizerWreath" );


#############################################################################
##
#F  PowerWreath( <sub_pm>, <ptuple>, <p> )  . . . . . . power map in G wr Sn.
##
##  <ManSection>
##  <Func Name="PowerWreath" Arg='sub_pm, ptuple, p'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PowerWreath" );


#############################################################################
##
#F  InductionScheme( <n> )  . . . . . . . . . . . . . . . . removal of hooks.
##
##  <ManSection>
##  <Func Name="InductionScheme" Arg='n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InductionScheme" );


#############################################################################
##
#F  MatCharsWreathSymmetric( <tbl>, <n> ) . . .  character matrix of G wr Sn.
##
##  <ManSection>
##  <Func Name="MatCharsWreathSymmetric" Arg='tbl, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "MatCharsWreathSymmetric" );


#############################################################################
##
#F  CharValueSymmetric( <n>, <beta>, <pi> ) . . . . . character value in S_n.
##
##  <ManSection>
##  <Func Name="CharValueSymmetric" Arg='n, beta, pi'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CharValueSymmetric" );


#############################################################################
##
#V  CharTableSymmetric  . . . .  generic character table of symmetric groups.
##
##  <ManSection>
##  <Var Name="CharTableSymmetric"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "CharTableSymmetric" );


#############################################################################
##
#V  CharTableAlternating  . .  generic character table of alternating groups.
##
##  <ManSection>
##  <Var Name="CharTableAlternating"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "CharTableAlternating" );


#############################################################################
##
#F  CharValueWeylB( <n>, <beta>, <pi> ) . . . . . character value in 2 wr Sn.
##
##  <ManSection>
##  <Func Name="CharValueWeylB" Arg='n, beta, pi'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CharValueWeylB" );


#############################################################################
##
#V  CharTableWeylB  . . . . generic character table of Weyl groups of type B.
##
##  <ManSection>
##  <Var Name="CharTableWeylB"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "CharTableWeylB" );


#############################################################################
##
#V  CharTableWeylD  . . . . generic character table of Weyl groups of type D.
##
##  <ManSection>
##  <Var Name="CharTableWeylD"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "CharTableWeylD" );


#############################################################################
##
#F  CharacterValueWreathSymmetric( <tbl>, <n>, <beta>, <pi> ) . .
#F                                        . . . .  character value in G wr Sn
##
##  <#GAPDoc Label="CharacterValueWreathSymmetric">
##  <ManSection>
##  <Func Name="CharacterValueWreathSymmetric" Arg='tbl, n, beta, pi'/>
##
##  <Description>
##  Let <A>tbl</A> be the ordinary character table of a group <M>G</M>.
##  The aim of this function is to compute a single character value
##  from the character table of the wreath product of <M>G</M>
##  with the full symmetric group on <A>n</A> points.
##  <P/>
##  The conjugacy classes and the irreducible characters of this
##  wreath product are parametrized by <M>r</M>-tuples of partitions
##  which together form a partition of <A>n</A>
##  (see <Ref Func="PartitionTuples"/>),
##  where <M>r</M> is the number of conjugacy classes of <M>G</M>.
##  <P/>
##  We describe the conjugacy class for which we want to compute the value
##  by the <M>r</M>-tuple <A>pi</A> of partitions in question,
##  and describe the character for which we want to compute the value
##  by the <M>r</M>-tuple <A>beta</A> of <Ref Func="BetaSet"/> values of the
##  <M>r</M>-tuple of partitions in question.
##  <P/>
##  <Example><![CDATA[
##  gap> n:= 4;;
##  gap> classpara:= [ [], [ 2, 1, 1 ] ];;
##  gap> charpara:= [ [ 2, 1 ], [ 1 ] ];;
##  gap> betas:= List( charpara, BetaSet );;
##  gap> c2:= CharacterTable( "Cyclic", 2 );;
##  gap> CharacterValueWreathSymmetric( c2, n, betas, classpara );
##  0
##  gap> wr:= CharacterTableWreathSymmetric( c2, n );;
##  gap> classpos:= Position( ClassParameters( wr ), classpara );;
##  gap> charpos:= Position( CharacterParameters( wr ), charpara );;
##  gap> Irr( wr )[ charpos, classpos ];
##  0
##  ]]></Example>
##  <P/>
##  This function can be useful if one is interested in only a few
##  character values.
##  If many character values are needed then it is probably faster to
##  compute the whole character table of the wreath product using
##  <Ref Func="CharacterTableWreathSymmetric"/>,
##  which uses intermediate results of recursive computations
##  and therefore can avoid repetitions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterValueWreathSymmetric" );


#############################################################################
##
#F  CharacterTableWreathSymmetric( <tbl>, <n> )  . .  char. table of G wr Sn.
##
##  <#GAPDoc Label="CharacterTableWreathSymmetric">
##  <ManSection>
##  <Func Name="CharacterTableWreathSymmetric" Arg='tbl, n'/>
##
##  <Description>
##  returns the character table of the wreath product of a group <M>G</M>
##  with the full symmetric group on <A>n</A> points,
##  where <A>tbl</A> is the character table of <M>G</M>.
##  <P/>
##  The result has values for <Ref Attr="ClassParameters"/> and
##  <Ref Attr="CharacterParameters"/> stored,
##  the entries in these lists are sequences of partitions.
##  Note that this parametrization prevents the principal character from
##  being the first one in the list of irreducibles.
##  <P/>
##  <Example><![CDATA[
##  gap> c3:= CharacterTable( "Cyclic", 3 );;
##  gap> wr:= CharacterTableWreathSymmetric( c3, 2 );;
##  gap> Display( wr );
##  C3wrS2
##
##       2  1   .   .   1  .   1  1   1   1
##       3  2   2   2   2  2   2  1   1   1
##
##         1a  3a  3b  3c 3d  3e 2a  6a  6b
##      2P 1a  3b  3a  3e 3d  3c 1a  3c  3e
##      3P 1a  1a  1a  1a 1a  1a 2a  2a  2a
##
##  X.1     1   1   1   1  1   1 -1  -1  -1
##  X.2     2   A  /A   B -1  /B  .   .   .
##  X.3     2  /A   A  /B -1   B  .   .   .
##  X.4     1 -/A  -A  -A  1 -/A -1  /A   A
##  X.5     2  -1  -1   2 -1   2  .   .   .
##  X.6     1  -A -/A -/A  1  -A -1   A  /A
##  X.7     1   1   1   1  1   1  1   1   1
##  X.8     1 -/A  -A  -A  1 -/A  1 -/A  -A
##  X.9     1  -A -/A -/A  1  -A  1  -A -/A
##
##  A = -E(3)^2
##    = (1+Sqrt(-3))/2 = 1+b3
##  B = 2*E(3)
##    = -1+Sqrt(-3) = 2b3
##  gap> CharacterParameters( wr )[1];
##  [ [ 1, 1 ], [  ], [  ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterTableWreathSymmetric" );


#############################################################################
##
#V  CharTableDoubleCoverSymmetric
##
##  <ManSection>
##  <Var Name="CharTableDoubleCoverSymmetric"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "CharTableDoubleCoverSymmetric" );


#############################################################################
##
#V  CharTableDoubleCoverAlternating
##
##  <ManSection>
##  <Var Name="CharTableDoubleCoverAlternating"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalName( "CharTableDoubleCoverAlternating" );
