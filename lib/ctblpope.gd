#############################################################################
##
#W  ctblpope.gd                 GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of those functions  that are needed to
##  compute and test possible permutation characters.
##
#N  TODO:
#N  - 'IsPermChar( <tbl>, <pc> )'
#N    (check whether <pc> can be a permutation character of <tbl>;
#N     use also the kernel of <pc>, i.e., check whether the kernel factor
#N     of <pc> can be a permutation character of the factor of <tbl> by the
#N     kernel; one example where this helps is the sum of characters of S3
#N     in O8+(2).3.2)
#N  - 'Constituent' und 'Maxdeg' - Optionen in 'PermComb'
##
Revision.ctblpope_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  ClassOrbitCharTable( <tbl>, <cc> )  . . . .  classes of a cyclic subgroup
##
DeclareGlobalFunction( "ClassOrbitCharTable" );


#############################################################################
##
#F  ClassRootsCharTable( <tbl> )  . . . . . . . . nontrivial root of elements
##
DeclareGlobalFunction( "ClassRootsCharTable" );


#############################################################################
##
#F  SubClass( <tbl>, <char> ) . . . . . . . . . . . size of class in subgroup
##
##  Given a permutation character <char> of the group with character table
##  <tbl>, 'SubClass' determines the sizes of the intersections of the
##  classes with the corresponding subgroup.
##  Of course this has to be a nonnegative integer.
##
DeclareGlobalFunction( "SubClass" );


#############################################################################
##
#F  TestPerm1( <tbl>, <char> ) . . . . . . . . . . . . . . . . test permchar
##
##  performs CAS test 1 and 2 for permutation characters
##
DeclareGlobalFunction( "TestPerm1" );
   

#############################################################################
##
#F  TestPerm2( <tbl>, <char> ) . . . . . . . . . . . . test permchar
##
##  performs CAS test 3, 4, and 5 for permutation characters
##
DeclareGlobalFunction( "TestPerm2" );


#############################################################################
##
#F  TestPerm3( <tbl>, <permch> ) . . . . . . . . . . . . . . . test permchar
##
##  'TestPerm3' performs CAS test 6
##
DeclareGlobalFunction( "TestPerm3" );


#############################################################################
##
#F  Inequalities( <tbl>, <chars>[, <option>] ) . . .
##                                            projected system of inequalites
##
##  There are two ways to organize the projection.
##  The first is the straight approach which takes the rationalized
##  characters in their original order and by this guarantees the character
##  with the smallest degree to be considered first. --> no option
##
##  The other way tries to keep the number of intermediate inequalities
##  small by eventually changing the order of characters. --> option "small"
##
DeclareGlobalFunction( "Inequalities" );


#############################################################################
##
#F  Permut( <tbl>, <arec> )               2 Jul 91
##
##  determine possible permutation characters
##
DeclareGlobalFunction( "Permut" );


#############################################################################
##
#F  PermBounds( <tbl> , <option> ) . . . . . . .  boundary points for simplex 
##
DeclareGlobalFunction( "PermBounds" );


#############################################################################
##
#F  PermComb( <tbl>, <arec> ) . . . . . . . . . . . .  permutation characters
##
##  For computing the possible linear combinations using 'lincom' without
##  better bounds, enter '<arec>:= rec( degree:= <degree>, bounds:= false )'.
##  (This is useful if the multiplicities are expected to be small, and if
##  this is forced by high irreducible degrees.)
##
DeclareGlobalFunction( "PermComb" );


#############################################################################
##
#F  PermCandidates( <tbl>, <characters>, <torso> )
##
##  computes all possible permutation characters of the character table
##  <tbl> that
##  1. have only the (necessarily rational) characters <chars> as
##     constituents,
##  2. are completions of <torso>.
##
##  Known values of the candidates must be nonnegative integers in <torso>,
##  the other positions of <torso> are unbound;
##  at least the degree '<torso>[1]' must be an integer.
##
DeclareGlobalFunction( "PermCandidates" );


#############################################################################
##
#F  PermCandidatesFaithful( <tbl>, <chars>, <norm_subgrp>, <nonfaithful>,
#F                          <lower>, <upper>, <torso> )
##
##  computes all possible permutation characters of the character table
##  <tbl> that
##  1. have only the (necessarily rational) characters <chars> as
##     constituents,
##  2. are completions of <torso>,
##  3. have the character <nonfaithful> as maximal constituent with kernel
##     <norm_subgrp>.
##
##  Known values of the candidates must be nonnegative integers in <torso>,
##  the other positions of <torso> are unbound;
##  at least the degree '<torso>[1]' must be an integer.
##
DeclareGlobalFunction( "PermCandidatesFaithful" );


#############################################################################
##
#F  PermChars( <tbl>[, <arec>] )  . . . . . . . . . . 06 Aug 91
##
##  Find all possible permutation characters of the group with character
##  table <tbl> by use of an algorithm specified by choice of the arguments.
##
DeclareGlobalFunction( "PermChars" );


#############################################################################
##
#F  PermCharInfo( <tbl>, <permchars> )
##
##  Let <tbl> be the character table of the group $G$, and 'permchars' the
##  permutation character $(1_U)^G$ for a subgroup $U$ of $G$, or a list
##  of such permutation characters.
##  'PermCharInfo' returns a record with components
##
##  'contained':\\
##    a list containing for each character in <permchars> a list containing
##    at position <i> the number of elements of $U$ that are contained in
##    class <i> of <tbl>, this is equal to
##    $'permchar[<i>]' \|U\| / 'centralizers[<i>]',
##    
##  'bound':\\
##    a list containing for each character in <permchars> a list containing
##    at position <i> the class length in $U$ of an element in class <i>
##    of <tbl> must be a multiple of
##    $'bound[<i>]' = \|U\| / \gcd( \|U\|, centralizers[<i>] )$,
##
##  'display':\\
##    record that can be used as second argument of 'Display'
##    to display each permutation character in <permchars> and the
##    corresponding components 'contained' and 'bound',
##    for the classes where at least one permutation character is nonzero,
##
##  'ATLAS':\\
##    list of strings containing the decomposition of the permutation
##    characters into the irreducible characters of <tbl>,
##    given in {\ATLAS} notation.
##
DeclareGlobalFunction( "PermCharInfo" );


#############################################################################
##
#E  ctblpope.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



