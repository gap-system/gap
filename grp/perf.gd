#############################################################################
##
#W  perf.gd               GAP Groups Library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for the Holt/Plesken library of
##  perfect groups
##
Revision.perf_gd :=
    "@(#)$Id$";


PERFRec := fail; # indicator that perf0.grp is not loaded
PERFSELECT := [];
PERFGRP := [];


#############################################################################
##
#C  IsPerfectLibraryGroup(<G>)  identifier for groups constructed from the
##                              library (used for perm->fp isomorphism)
##
DeclareCategory("IsPerfectLibraryGroup", IsGroup );


#############################################################################
##
#O  PerfGrpConst(<filter>,<descriptor>)
##
DeclareConstructor("PerfGrpConst",[IsGroup,IsList]);


#############################################################################
##
#F  PerfGrpLoad(<size>)  force loading of secondary files, return index
##
DeclareGlobalFunction("PerfGrpLoad");


#############################################################################
##
#A  PerfectIdentification(<G>) . . . . . . . . . . . . id. for perfect groups
##
##  This attribute is set for all groups obtained from the perfect groups
##  library and has the value `[<size>,<nr>]' if the group is obtained with
##  these parameters from the library.
##
DeclareAttribute("PerfectIdentification", IsGroup );


#############################################################################
##
#F  SizesPerfectGroups()
##
DeclareGlobalFunction("SizesPerfectGroups");


#############################################################################
##
#F  NumberPerfectGroups( <size> ) . . . . . . . . . . . . . . . . . . . . . .
##
##  returns the number of non-isomorphic perfect groups of size <size> for
##  each positive integer  <size> up to $10^6$ except for the eight  sizes
##  listed at the beginning  of  this section for  which the number is not
##  yet known. For these values as well as for any argument out of range it
##  returns `fail'.
##
DeclareGlobalFunction("NumberPerfectGroups");
DeclareSynonym("NrPerfectGroups",NumberPerfectGroups);


#############################################################################
##
#F  NumberPerfectLibraryGroups( <size> )  . . . . . . . . . . . . . . . . . .
##
##  returns the number of perfect groups of size <size> which are available
##  in the  library of finite perfect groups. (The purpose  of the function
##  is  to provide a simple way  to formulate a loop over all library groups
##  of a given size.)
##
DeclareGlobalFunction("NumberPerfectLibraryGroups");
DeclareSynonym("NrPerfectLibraryGroups",NumberPerfectLibraryGroups);


#############################################################################
##
#F  PerfectGroup( [<filt>, ]<size>[, <n>] )
#F  PerfectGroup( [<filt>, ]<sizenumberpair> )
##
##  returns a group which is isomorphic to the library group specified
##  by the size number `[ <size>, <n> ]'  or   by the  two  separate
##  arguments <size> and  <n>,  assuming a default   value  of $<n> = 1$.
##  The optional argument <filt> defines the filter in which the group is
##  returned.
##  Possible filters so far are `IsPermGroup' and `IsSubgroupFpGroup'.
##  In the latter case, the  generators and relators used coincide with those
##  given in~\cite{HP89}.
##
DeclareGlobalFunction("PerfectGroup");


#############################################################################
##
#F  DisplayInformationPerfectGroups( <size> ) . . . . . . . . . . . . . . . .
#F  DisplayInformationPerfectGroups( <size>, <n> )  . . . . . . . . . . . . .
#F  DisplayInformationPerfectGroups( [ <size>, <n> ] )  . . . . . . . . . . .
##
##  `DisplayInformationPerfectGroups' displays some invariants of the <n>-th
##  group of order <size> from the perfect groups library.
##
##  If no value of <n> has been specified, the invariants will be displayed
##  for all groups of size <size> available in the library.
##  The information provided for $G$ includes the following items:
##  \beginlist%unordered
##    \item{$\bullet$}
##        a headline containing the size number `[ <size>, <n> ]' of $G$
##        in the form `<size>.<n>' (the suffix `.<n>' will be suppressed
##        if, up to isomorphism, $G$ is the only perfect group of order
##        <size>),
##    \item{$\bullet$} a message if $G$ is simple  or quasisimple, i.e.,
##        if the factor group of $G$ by its centre is simple,
##    \item{$\bullet$} the ``description'' of  the structure of  $G$ as it is
##      given by Holt and Plesken in~\cite{HP89} (see below),
##    \item{$\bullet$} the size of  the centre of $G$  (suppressed, if $G$ is
##      simple),
##    \item{$\bullet$} the prime decomposition of the size of $G$,
##    \item{$\bullet$} orbit sizes for  a faithful permutation representation
##      of $G$ which is provided by the library (see below),
##    \item{$\bullet$} a reference to each occurrence of $G$ in the tables of
##      section 5.3    of  \cite{HP89}. Each  of   these  references
##      consists of a class number and an internal number $(i,j)$ under which
##      $G$ is listed in that class. For some groups, there  is more than one
##      reference because these groups belong to more than one of the classes
##      in the book.
##  \endlist
##
DeclareGlobalFunction("DisplayInformationPerfectGroups");


#############################################################################
##
#F  SizeNumbersPerfectGroups( <factor1>, <factor2>, ... )
##
##  `SizeNumbersPerfectGroups' returns a list of pairs, each entry consisting
##  of a group order and the number of those groups in the library of perfect
##  groups that contain the specified factors <factor1>, <factor2>, ...
##  among their composition factors.
##
##  Each argument must either be the name of a simple group or an integer
##  which stands for the product of the sizes of one or more cyclic factors.
##  (In fact, the function replaces all integers among the arguments
##  by their product.)
##
##  The following text strings are accepted as simple group names.
##  \beginlist%unordered
##    \item{$\bullet$} `A<n>' or  `A(<n>)' for the  alternating groups $A_n$,
##      $5\leq n\leq9$, for example `A5' or `A(6)'.
##    \item{$\bullet$}  `L<n>(<q>)'   or  `L(<n>,<q>)' for  $PSL(n,q)$, where
##      $n\in\{2,3\}$ and $q$ a prime power, ranging
##      \itemitem{$\circ$}%unordered
##                         for $n=2$ from 4 to 125
##      \itemitem{$\circ$} for $n=3$ from 2 to 5
##    \item{$\bullet$} `U<n>(<q>)'  or  `U(<n>,<q>)' for   $PSU(n,q)$,  where
##      $n\in\{3,4\}$ and $q$ a prime power, ranging
##      \itemitem{$\circ$}%unordered
##                         for $n=3$ from 3 to 5
##      \itemitem{$\circ$} for $n=4$ from 2 to 2
##    \item{$\bullet$} `Sp4(4)' or `S(4,4)' for the symplectic group $S(4,4)$,
##    \item{$\bullet$} `Sz(8)' for the Suzuki group $Sz(8)$,
##    \item{$\bullet$} `M<n>'  or `M(<n>)' for  the  Mathieu groups $M_{11}$,
##      $M_{12}$, and $M_{22}$, and
##    \item{$\bullet$} `J<n>' or `J(<n>)'   for  the Janko groups  $J_1$  and
##      $J_2$.
##  \endlist
##
##  Note  that, for  most  of the  groups,   the  preceding list  offers  two
##  different  names in order  to  be consistent  with the  notation used  in
##  \cite{HP89}  as     well  as     with    the  notation    used    in  the
##  `DisplayCompositionSeries' command of {\GAP}.   However, as the names are
##  compared  as text strings, you are  restricted to  the above choice. Even
##  expressions like `L2(2^5)' are not accepted.
##
##  As the use of the  term $PSU(n,q)$ is  not  unique in the literature,  we
##  mention that in this library it denotes the factor  group of $SU(n,q)$ by
##  its centre, where $SU(n,q)$ is  the group of all $n  \times n$ unitary
##  matrices  with entries in $GF(q^2)$ and determinant 1.
##
##  The purpose  of the function is  to provide a  simple way to  formulate a
##  loop over all library groups which contain certain composition factors.
##
DeclareGlobalFunction("SizeNumbersPerfectGroups");


#############################################################################
##
#E

