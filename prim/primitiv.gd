#############################################################################
##
#W  primitiv.gd              GAP group library               Heiko Theissen
#W                                                           Alexander Hulpke
##
##
#H  @(#)$Id$
##
##
Revision.primitiv_gd :=
    "@(#)$Id$";


#1
##  {\GAP} contains a library of primitive permutation groups which includes
##  the following permutation groups up to permutation isomorphism (i.e., up
##  to conjugacy  in the corresponding symmetric group)
##  \beginlist
##    \item{$\bullet$} the  non-affine primitive permutation groups of degree
##      $\<=999$,   described    in  \cite{DixonMortimer88},  with generators
##      calculated in \cite{Theissen97},
##    \item{$\bullet$} all  primitive  permutation groups of  degree $\<256$,
##      in particular,
##      \itemitem{$\circ$} the primitive permutation groups up to degree~50,
##        calculated by C.~Sims,
##      \itemitem{$\circ$}  the solvable (hence affine) primitive permutation
##        groups of degree $\<256$, calculated by M.~Short \cite{Sho92},
##      \itemitem{$\circ$} the insolvable affine primitive permutation groups
##        of degree $\<256$, calculated in \cite{Theissen97}.
##  \endlist
##  Note that the affine primitive permutation groups of degrees 256--999 are
##  not included.
##
##  For degree up to 50, the names used are as given by Buekenhout and
##  Leemans \cite{BuekenhoutLeemans96}.
##
##  The names for the groups of higher degree are as chosen by
##  \cite{Theissen97} and reflect the cohort structure in
##  \cite{DixonMortimer88}. They do *not* conform to the usual naming for
##  extensions. That is `l3,4.3' is the third (in some arbitrary ordering)
##  group in a cohort for socle l3,4, but the socle factor is *not
##  necessarily* of order 3.
##
##  As the work in \cite{Theissen97} has not been checked independently for
##  completeness, it is perceivable in theory that for degrees above 50
##  groups are missing. However when preparing the library it has been
##  ensured that the groups in it are all primitive and not conjugate.
##
##  In detail, we guarantee the following properties for this and further
##  versions (but *not* versions which came before {\GAP}~4.2) of the library:
##
##  \beginlist
##  \item{$\bullet$} All groups in the library are primitive permutation
##  groups of the indicated degree.
##  \item{$\bullet$} The positions of the groups in the library are stable.
##  That is `PrimitiveGroup(<n>,<nr>)' will always give you a permutation
##  isomorphic group. Note however that we do not guarantee to keep the
##  chosen $S_n$-representative, the generating set or the name for 
##  eternity.
##  \item{$\bullet$} Different groups in the library are not conjugate in
##  $S_n$.
##  \item{$\bullet$} If a group in the library has a primitive subgroup with 
##  the same socle, this group is in the library as well.
##  \endlist

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("prim","2.0");


#############################################################################
##
#F  PrimitiveGroup(<deg>,<nr>)
##
##  returns the primitive permutation  group of degree <deg> with number <nr>
##  from the list. 
##
##  % this arrangement might not be true any more. Ignore
##  %255$ first  come affine groups. If <deg> is a prime <p> it starts with the
##  %one-dimensional affine  groups over the field $F_p$, that is Frobenius
##  %groups of the  form $ F_p{:}A$ for a  subgroup $A\le{\rm Aut}(F_p)$.  Then
##  %come the other solvable  affine groups, in the same order as in the list of
##  %M.~Short (who did not include the Frobenius groups).  Next  in the list
##  %come the insolvable affine primitive  permutation groups.
##  %
##  %Then come the   non-affine primitive permutation  groups  of degree <deg>.
##  %They have been  classified  into cohorts in  \cite{DixonMortimer88},  and
##  %{\GAP}    represents a     cohort   as a     homomorphism   $\kappa\colon
##  %N=N_{S_{<deg>}}(S)\to A$ whose kernel $S$  is the socle  of $N$ and every
##  %primitive group in that cohort is the preimage of a subgroup of $A$ (only
##  %one from   each conjugacy  class)  under $\kappa$.   For the  degrees  in
##  %question,  $A$ is solvable. All  primitive groups in  the cohort $\kappa$
##  %have the same socle, namely~$S$. The groups  of each cohort appear in the
##  %list consecutively.
##  %
##  %(The functions `NrAffinePrimitiveGroups and `NrSolvablePrimitiveGroups' can
##  %be used to determine where the different parts of the lists start.)
##  %
##  The arrangement of the groups differs from the arrangement of primitive
##  groups in the list of C.~Sims, which was used in {\GAP}~3. See
##  `SimsNo' ("SimsNo").
##
UnbindGlobal("PrimitiveGroup");
DeclareGlobalFunction( "PrimitiveGroup" );


#############################################################################
##
#F  NrPrimitiveGroups(<deg>)
##
##  returns the number of primitive permutation groups of degree <deg> in the
##  library.
##
DeclareGlobalFunction( "NrPrimitiveGroups" );

#2
##  The selection functions (see~"Selection functions") for the primitive
##  groups library are `AllTransitiveGroups' and `OneTransitiveGroup'. They
##  obtain the following properties from the database without having to
##  compute them anew: 
##
##  `NrMovedPoints', `Size', `Transitivity', `ONanScottType',
##  `IsSimpleGroup', `IsSolvableGroup', and `SocleTypePrimitiveGroup'.
##
##  (Note, that for groups of degree up to 999, ONan-Scott types 4a, 4b and
##  5 cannot occur.)

#############################################################################
##
#F  PrimitiveGroupsIterator(<attr1>,<val1>,<attr2>,<val2>,...)
##
##  returns an iterator through
##  `AllPrimitiveGroups(<attr1>,<val1>,<attr2>,<val2>,...)' without creating
##  all these groups at the same time.
##
DeclareGlobalFunction( "PrimitiveGroupsIterator" );

#############################################################################
##
#F  AllPrimitiveGroups(<attr1>,<val1>,<attr2>,<val2>,...)
##
DeclareGlobalFunction( "AllPrimitiveGroups" );

#############################################################################
##
#F  OnePrimitiveGroup(<attr1>,<val1>,<attr2>,<val2>,...)
##
DeclareGlobalFunction( "OnePrimitiveGroup" );

#############################################################################
##
#F  PrimitiveGroupSims(<deg>,<nr>)
##
##  For  compatibility with earlier versions  of {\GAP}, the original list of
##  function  `PrimitiveGroupSims'.
##
DeclareGlobalFunction( "PrimitiveGroupSims" );


#############################################################################
##
#A  SimsNo(<G>)
##
##  If <G> is a primitive group obtained by `PrimitiveGroup' (respectively one
##  of the selection functions) this attribute contains the number of the
##  isomorphic group in the original list of C.~Sims. (this is the
##  arrangement as it was used in {\GAP}~3.
##
DeclareAttribute( "SimsNo", IsPermGroup );

#############################################################################
##
#F  IrreducibleSolvableGroup( <n>, <p>, <i> )
##
## returns  the   <i>-th  irreducible  solvable subgroup  of GL(  <n>,  <p> ).
## The  irreducible  solvable subgroups of GL(n,p) are ordered with respect to
## the following criteria:
##  \beginlist
##  \item{-} increasing size;
##  \item{-} increasing guardian number.
##  \endlist
##  If two groups have the same size and guardian, they  are in no particular
##  order.  (See the library documentation   or  \cite{Sho92} for the meaning
##  of guardian.)
##
DeclareGlobalFunction( "IrreducibleSolvableGroup" );

#############################################################################
##
#E
##


