#############################################################################
##
#W  ctblsymm.gd                 GAP library                    Goetz Pfeiffer
#W                                                               Felix Noeske
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
Revision.ctblsymm_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  BetaSet( <alpha> )  . . . . . . . . . . . . . . . . . . . . . . beta set.
##
DeclareGlobalFunction( "BetaSet" );


#############################################################################
##
#F  CentralizerWreath( <sub_cen>, <ptuple> )  . . . . centralizer in G wr Sn.
##
DeclareGlobalFunction( "CentralizerWreath" );


#############################################################################
##
#F  PowerWreath( <sub_pm>, <ptuple>, <p> )  . . . . . . power map in G wr Sn.
##
DeclareGlobalFunction( "PowerWreath" );


#############################################################################
##
#F  InductionScheme( <n> )  . . . . . . . . . . . . . . . . removal of hooks.
##
DeclareGlobalFunction( "InductionScheme" );


#############################################################################
##
#F  MatCharsWreathSymmetric( <tbl>, <n> ) . . .  character matrix of G wr Sn.
##
DeclareGlobalFunction( "MatCharsWreathSymmetric" );


#############################################################################
##
#F  CharValueSymmetric( <n>, <beta>, <pi> ) . . . . . character value in S_n.
##
DeclareGlobalFunction( "CharValueSymmetric" );


#############################################################################
##
#V  CharTableSymmetric  . . . .  generic character table of symmetric groups.
##
DeclareGlobalVariable( "CharTableSymmetric",
    "generic character table of symmetric groups" );


#############################################################################
##
#V  CharTableAlternating  . .  generic character table of alternating groups.
##
DeclareGlobalVariable( "CharTableAlternating",
    "generic character table of alternating groups" );


#############################################################################
##
#F  CharValueWeylB( <n>, <beta>, <pi> ) . . . . . character value in 2 wr Sn.
##
DeclareGlobalFunction( "CharValueWeylB" );


#############################################################################
##
#V  CharTableWeylB  . . . . generic character table of Weyl groups of type B.
##
DeclareGlobalVariable( "CharTableWeylB",
    "generic character table of Weyl groups of type B" );


#############################################################################
##
#V  CharTableWeylD  . . . . generic character table of Weyl groups of type D.
##
DeclareGlobalVariable( "CharTableWeylD",
    "generic character table of Weyl groups of type D" );


#############################################################################
##
#F  CharValueWreathSymmetric(<sub>,<n>,<beta>,<pi>) . char. value in G wr Sn.
##
DeclareGlobalFunction( "CharValueWreathSymmetric" );


#############################################################################
##
#F  CharacterTableWreathSymmetric( <tbl>, <n> )  . .  char. table of G wr Sn.
##
##  returns the character table of the wreath product of a group $G$ with
##  the full symmetric group on $n$ points,
##  where <tbl> is the character table of $G$.
##
##  The result has values for `ClassParameters' and `CharacterParameters'
##  (see~"ctbllib:ClassParameters"
##  in the manual for the {\GAP} Character Table Library) stored,
##  the entries in these lists are sequences of partitions.
##  Note that this parametrization prevents the principal character from
##  being the first one in the list of irreducibles.
##
DeclareGlobalFunction( "CharacterTableWreathSymmetric" );


#############################################################################
##
#V  CharTableDoubleCoverSymmetric
##
DeclareGlobalVariable( "CharTableDoubleCoverSymmetric",
    "gen. char. table of the standard Schur double cover of symm. groups" );


#############################################################################
##
#V  CharTableDoubleCoverAlternating
##
DeclareGlobalVariable( "CharTableDoubleCoverAlternating",
    "generic char. table of the Schur double cover of alternating groups" );


#############################################################################
##
#E

