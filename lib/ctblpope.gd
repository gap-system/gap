#############################################################################
##
#W  ctblpope.gd                 GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
#F  SubClass( <tbl>, <char> ) . . . . . . . . . . . size of class in subgroup
##
##  Given a permutation character <char> of the group with character table
##  <tbl> 'SubClass' determines the sizes of the intersections of the
##  classes with the corresponding subgroup. Of course this has to be a
##  positive integer.
##
SubClass := NewOperationArgs( "SubClass" );


#############################################################################
##
#F  TestPerm1( <tbl>, <char> ) . . . . . . . . . . . . . . . . test permchar
##
##  performs CAS test 1 and 2 for permutation characters
##
TestPerm1 := NewOperationArgs( "TestPerm1" );
   

#############################################################################
##
#F  TestPerm2( <tbl>, <char> ) . . . . . . . . . . . . test permchar
##
##  performs CAS test 3, 4, and 5 for permutation characters
##
TestPerm2 := NewOperationArgs( "TestPerm2" );


#############################################################################
##
#F  TestPerm3( <tbl>, <permch> ) . . . . . . . . . . . . . . . test permchar
##
##  'TestPerm3' performs CAS test 6
##
TestPerm3 := NewOperationArgs( "TestPerm3" );


#############################################################################
##
#F  Inequalities( <tbl>, <chars> [, <option>] ) . . .
#F                                            projected system of inequalites
##
##  There are two ways to organize the projection. The first is the straight
##  approach which takes the rationalized characters in their original order
##  and by this guarantees the character with the smallest degree to be
##  considered first. --> no option
##  The other way tries to keep the number of intermediate inequalities
##  small by eventually changing the order of characters. -->option "small"
##
Inequalities := NewOperationArgs( "Inequalities" );


#############################################################################
##
#F  Permut( <tbl>, <arec> )               2 Jul 91
##
##  determine possible permutation characters
##
Permut := NewOperationArgs( "Permut" );


#############################################################################
##
#F  PermBounds( <tbl> , <option> ) . . . . . . .  boundary points for simplex 
##
PermBounds := NewOperationArgs( "PermBounds" );


#############################################################################
##
#F  PermComb( <tbl>, <arec> ) . . . . . . . . . . . .  permutation characters
##
##  For computing the possible linear combinations using 'lincom' without
##  better bounds, enter '<arec>:= rec( degree:= <degree>, bounds:= false )'.
##  (This is useful if the multiplicities are expected to be small, and if
##  this is forced by high irreducible degrees.)
##
PermComb := NewOperationArgs( "PermComb" );


#############################################################################
##
#F  PermCandidates( <tbl>, <characters>, <torso> )
##
##  computes all permutation character candidates of the character table
##  <tbl> which have only the (necessarily rational) characters <characters>
##  as constituents and which are completions of <torso>: Known values of the
##  candidates must be nonnegative integers in <torso>, the other positions
##  of <torso> are unbound; at least the degree '<torso>[1]' must be an
##  integer.
##
PermCandidates := NewOperationArgs( "PermCandidates" );


#############################################################################
##
#F  'PermCandidatesFaithful( <tbl>, <chars>, <norm\_subgrp>, <nonfaithful>,
#F                           <lower>, <upper>, <torso> )'
##
##  computes all permutation character candidates of the character table
##  <tbl> which have only the (necessarily rational) characters <chars>
##  as constituents and which are completions of <torso>: Known values of the
##  candidates must be nonnegative integers in <torso>, the other positions
##  of <torso> are unbound; at least the degree '<torso>[1]' must be an
##  integer.
##

# 'PermCandidatesFaithful'\\
# '      ( tbl, chars, norm\_subgrp, nonfaithful, lower, upper, torso )'
# 
# reference of variables\:
# \begin{itemize}
# \item 'tbl'\:         a character table which must contain field 'order'
# \item 'chars'\:       *rational* characters of 'tbl'
# \item 'nonfaithful'\: $(1_{UN})^G$
# \item 'lower'\:       lower bounds for $(1_U)^G$
#                       (may be unspecified, i.e. 0)
# \item 'upper'\:       upper bounds for $(1_U)^G$
#                       (may be unspecified, i.e. 0)
# \item 'torso'\:       $(1_U)^G$ (at known positions)
# \item 'faithful'\:    'torso' - 'nonfaithful'
# \item 'divs'\:        'divs[i]' divides $(1_U)^G[i]$
# \end{itemize}
# 
# The algorithm proceeds in 5 steps\:
# 
# *step 1*\: Try to improve the input data
# \begin{enumerate}
# \item Check if 'torso[1]' divides $\|G\|$, 'nonfaithful[1]' divides
#       'torso[1]'.
# \item If 'orders[i]' does not divide $U$ 
#       or if $'nonfaithful[i]' = 0$, 'torso[i]' must be 0.
# \item Transfer 'upper' and 'lower' to upper bounds and lower bounds for
#       the values of 'faithful' and try to improve them\:
# \begin{enumerate}
# \item \['lower[i]'\:= \max\{'lower[i]',0\} - 'nonfaithful[i]';\]
#       If $UN$ has only one galois family of classes for a prime
#       representative order $p$, and $p$ divides $\|G\|/'torso[1]'$,
#       or if $g_i$ is a $p$-element and $p$ does not divide $[UN\:U]$,
#       then necessarily these elements lie in $U$, and we have
#       \['lower[i]'\:= \max\{'lower[i]',1\} - 'nonfaithful[i]';\]
# \item \begin{eqnarray*}
#       'upper[i]' & \:= & \min\{'upper[i]','torso[1]',
#                                'tbl.centralizers[i]'-1,\\
#       & & 'torso[1]' \cdot 'nonfaithful[i]'/'nonfaithful[1]'\}
#       -'nonfaithful[i]'.
#       \end{eqnarray*}
# \end{enumerate}
# \item Compute divisors of the values of $(1_U)^G$\:
#       \['divs[i]'\:= 'torso[1]'/\gcd\{'torso[1]',\|G\|/\|N_G[i]\|\}
#       \mbox{\rm \ divides} (1_U)^G[i].\]
#       ($\|N_G[i]\|$ denotes the normalizer order of $\langle g_i \rangle$.)
# 
#       If $g_i$ generates a Sylow $p$ subgroup of $UN$ and $p$ does not
#       divide $[UN\:U]$ then $(1_{UN})^G(g_i)$ divides $(1_U)^G(g_i)$,
#       and we have \['divs[i]'\:= 'Lcm( divs[i], nonfaithful[i] )'.\]
# \item Compute 'roots' and 'powers' for later improvements of local bounds\:
#       $j$ is in 'roots[i]' iff there exists a prime $p$ with powermap
#       stored on 'tbl' and $g_j^p = g_i$,
#       $j$ is in 'powers[i]' iff there exists a prime $p$ with powermap
#       stored on 'tbl' and $g_i^p = g_j$.
# \item Compute the list 'matrix' of possible constituents of 'faithful'\:
#       (If 'torso[1]' = 1, we have none.)
#       Every constituent $\chi$ must have degree $\chi(1)$ lower than
#       $'torso[1]' - 'nonfaithful[1]'$, and $N \not\subseteq \ker(\chi)$;
#       also, for all i, we must have
#       $\chi[i] \geq \chi[1] - 'faithful[1]' - 'nonfaithful[i]'$.
# \end{enumerate}
# 
# *step 2*\: Collapse classes which are equal for all possible constituents
# 
# (*Note*\: We only needed the fusion of classes, but we also have to make
#         a copy.)
# 
# After that, 'fusion' induces an equivalence relation of conjugacy classes,
# 'matrix' is the new list of constituents. Let $C \:= \{i_1,\ldots,i_n\}$
# be an equivalence class; for further computation, we have to adjust the
# other informations\:
# 
# \begin{enumerate}
# \item Collapse 'faithful'; the values that are not yet known later will be
#       filled in using the decomposability test (see "ContainedCharacters");
#       the equality 
#       \['torso' = 'nonfaithful' + 'Indirection'('faithful','fusion')\]
#       holds, so later we have
#       \[(1_U)^G = (1_{UN})^G + 'Indirection( faithful , fusion )'.\]
# \item Adjust the old structures\:
# \begin{enumerate}
# \item Define as new roots \[ 'roots[C]'\:=
#       \bigcup_{1 \leq j \leq n} 'set(Indirection(fusion,roots[i_j]))', \]
# \item as new powers \[ 'powers[C]'\:=
#       \bigcup_{1 \leq j \leq n} 'set(Indirection(fusion,powers[i_j]))',\]
# \item as new upper bound \['upper[C]'\:=
#       \min_{1 \leq j \leq n}('upper[i_j]'), \]
#       try to improve the bound using the fact that for each j in
#       'roots[C]' we have
#       \['nonfaithful[j]'+'faithful[j]' \leq
#       'nonfaithful[C]'+'faithful[C]',\]
# \item as new lower bound \['lower[C]'\:=
#       \max_{1 \leq j \leq n}('lower[i_j]'),\]
#        try to improve the bound using the fact that for each j in
#        'powers[C]' we have
#        \['nonfaithful[j]'+'faithful[j]' \geq
#        'nonfaithful[C]'+'faithful[C]',\]
# \item as new divisors \['divs[C]'\:=
#       'Lcm'( 'divs'[i_1],\ldots, 'divs'[i_n] ).\]
# \end{enumerate}
# \item Define some new structures\:
# \begin{enumerate}
# \item the moduls for the basechange \['moduls[C]'\:=
#          \max_{1 \leq j \leq n}('tbl.centralizers[i_j]'),\]
# \item new classes \['classes[C]'\:=
#          \sum_{1 \leq j \leq n} 'tbl.classes[i_j]',\]
# \item \['nonfaithsum[C]'\:= \sum_{1 \leq j \leq n} 'tbl.classes[i_j]'
#       \cdot 'nonfaithful[i_j]',\]
# \item a variable 'rest', preset with $\|G\|$\: We know that
#       $\sum_{g \in G} (1_U)^G(g) = \|G\|$.
#       Let the values of $(1_U)^G$ be known for a subset
#       $\tilde{G} \subseteq G$, and define
#       $'rest'\:= \sum_{g \in \tilde{G}} (1_U)^G(g)$;
#       then for $g \in G \setminus \tilde{G}$, we
#       have $(1_U)^G(g) \leq 'rest'/\|Cl_G(g)\|$.
#       In our situation, this means
#       \[\sum_{1 \leq j \leq n} \|Cl_G(g_j)\| \cdot (1_U)^G(g_j)
#       \leq 'rest',\]
#       or equivalently
#       $'nonfaithsum[C]' + 'faithful[C]' \cdot 'classes[C]' \leq 'rest'$.
#       (*Note* that 'faithful' necessarily is constant on 'C'.).
#       So 'rest' is used to update local upper bounds.
# \end{enumerate}
# \item (possible acceleration\: If we allow to collapse classes on which
#       'nonfaithful' takes different values, the situation is a little
#       more difficult. The new upper and lower bounds will be others,
#       and the new divisors will become moduls in a congruence relation
#       that has nothing to do with the values of torso or faithful.)
# \end{enumerate}
# 
# *step 3*\: Eliminate classes for which the values of 'faithful' are known
# 
# The subroutine 'erase' successively eliminates the columns of 'matrix'
# listed up in 'uniques'; at most one row remains with a nonzero entry 'val'
# in that column 'col', this is the gcd of the former column values.
# If we can eliminate 'difference[ col ]', we proceed with the next column,
# else there is a contradiction (i.e. no generalized character exists that
# satisfies our conditions), and we set 'impossible' true and then return
# all extracted rows which must be used at lower levels of a backtrack
# which may have called 'erase'.
# Having erased all uniques without finding a contradiction, 'erase' looks
# if other columns have become unique, i.e. the bounds and divisors allow
# just one value; those columns are erased, too.
# 'erase' also updates the (local) upper and lower bounds using 'roots',
# 'powers' and 'rest'.
# If no further elimination is possible, there can be two reasons\:
# If all columns are erased, 'faithful' is complete, and if it is really a
# character, it will be appended to 'possibilities'; then 'impossible' is
# set true to indicate that this branch of the backtrack search tree has
# ended here.
# Otherwise 'erase' looks for that column where the number of possible
# values is minimal, and puts a record with informations about first
# possible value, step (of the arithmetic progression) and number of
# values into that column of 'faithful';
# the number of the column is written to 'min\_class',
# 'impossible' is set false, and the extracted rows are returned.
# 
# And this way 'erase' computes the lists of possible values\:
# 
# Let $d\:= 'divs[ i ]', z\:= 'val', c\:= 'difference[ i ]',
# n\:= 'nonfaithful[ i ]', low\:= 'local\_lower[ i ]',
# upp\:= 'local\_upper[ i ]', g\:= \gcd\{d,z\} = ad + bz$.
# 
# Then the set of allowed values is
# \[ M\:= \{x; low \leq x \leq upp; x \equiv -c \pmod{z};
#              x \equiv -n \pmod{d} \}.\]
# If $g$ does not divide $c-n$, we have a contradiction, else
# $y\:= -n -ad \frac{c-n}{g}$ defines the correct arithmetic progression\:
# \[ M = \{x;low \leq x \leq upp; x \equiv y \pmod{'Lcm'(d,z)} \} \]
# The minimum of $M$ is then given by 
# \[ L\:= low + (( y - low ) \bmod 'Lcm'(d,z)).\]
# 
# (*Note* that for the usual case $d=1$ we have $a=1, b=0, y=-c$.)
# 
# Therefore the number of values is
# $'Int( '( upp - L ) ' / Lcm'(d,z) ' )' +1$.
# 
# In step 3, 'erase' is called with the list of known values of 'faithful'
# as 'uniques'.
# Afterwards, if 'InfoCharTable2 = Print' and a backtrack search is necessary,
# a message about the found improvements and the expected expense
# for the backtrack search is printed.
# (*Note* that we are allowed to forget the rows which we have extracted in
# this first elimination.)
# 
# *step 4*\: Delete eliminated columns physically before the backtrack search
# 
# The eliminated columns (those with 'nonzerocol[i] = false') of 'matrix'
# are deleted, and the other objects are adjusted\:
# \begin{enumerate}
# \item In 'differences', 'divs', 'nonzerocol', 'moduls', 'classes',
#       'nonfaithsum', 'upper', 'lower', the columns are simply deleted.
# \item For adjusting 'fusion', first a permutation 'fusionperm' is
#       constructed that maps the eliminated columns behind the remaining
#       columns; after 'faithful\:= Indirection( faithful, fusionperm )' and
#       'fusion\:= Indirection( fusionperm, fusion )', we have again
#       \[ (1_U)^G = (1_{UN})^G + 'Indirection( faithful, fusion )'. \]
# \item adjust 'roots' and 'powers'.
# \end{enumerate}
# 
# *step 5*\: The backtrack search
# 
# The subroutine 'evaluate' is called with a column 'unique'; this (and other
# uniques, if possible) is eliminated. If there was an inconsistence, the
# extracted rows are returned; otherwise the column 'min\_class' subsequently
# will be set to all possible values and 'evaluate' is called with
# 'unique = min\_class'.
# After each return from 'evaluate', the returned rows are appended to matrix
# again; if matrix becomes too long, a call of 'ModGauss' will shrink it.
# Note that 'erase' must be able to update the value of 'rest', but any call
# of 'evaluate' must not change 'rest'; so 'rest' is a parameter of
# 'evaluate', but for 'erase' it is global (realized as '[ rest ]').
 
PermCandidatesFaithful := NewOperationArgs( "PermCandidatesFaithful" );


#############################################################################
##
#F  PermChars( <tbl> [, <arec>] ) . . . . . . . . . . 06 Aug 91
##
##  Find all Candidates for Permutation Characters of the group with
##  Character table <tbl> by use of an algorithm specified by choice of
##  the arguments.
##
PermChars := NewOperationArgs( "PermChars" );


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
##    $'permchar[<i>]' \|U\| / 'tbl.centralizers[<i>]',
##    
##  'bound':\\
##    a list containing for each character in <permchars> a list containing
##    at position <i> the class length in $U$ of an element in class <i>
##    of <tbl> must be a multiple of
##    $'bound[<i>]' = \|U\| / \gcd( \|U\|, <tbl>.centralizers[<i>] )$,
##
##  'display':\\
##    record that can be used as second argument of 'DisplayCharTable'
##    to display each permutation character in <permchars> and the
##    corresponding components 'contained' and 'bound',
##    for the classes where at least one permutation character is nonzero,
##
##  'ATLAS':\\
##    list of strings containing the decomposition of the permutation
##    characters into '<tbl>.irreducibles' in {\ATLAS} notation.
##
PermCharInfo := NewOperationArgs( "PermCharInfo" );


#############################################################################
##
#E  ctblpope.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



