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
##  \beginlist%unordered
##    \item{$\bullet$} the  non-affine primitive permutation groups of degree
##      $\le999$,   described    in  \cite{DixonMortimer88},  with generators
##      calculated in \cite{Theissen97},
##    \item{$\bullet$} all  primitive  permutation groups of  degree $\<256$,
##      in particular,
##      \itemitem{$\circ$}%unordered
##        the primitive permutation groups up to degree~50,
##        calculated by C.~Sims,
##      \itemitem{$\circ$}  the solvable (hence affine) primitive permutation
##        groups of degree $\<256$ as calculated by M.~Short \cite{Sho92},
##      \itemitem{$\circ$} some insolvable affine primitive permutation groups
##        of degree $\<256$ as calculated in \cite{Theissen97}.
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
##  The work in \cite{Theissen97} is known to have ommissions. Because of this
##  we do not guarantee completeness of the lists beyond degree 50, though
##  we have corrected errors as far as we know of them.
##  When preparing the library it also has been
##  ensured that the groups in it are all primitive and not conjugate.
##
##  In detail, we guarantee the following properties for this and further
##  versions (but *not* versions which came before {\GAP}~4.2) of the library:
##
##  \beginlist%unordered
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
##
##  (Note that the arrangement of groups is not guaranteed to be in
##  increasing size, though it holds for many degrees.)

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
##  (Note, that for groups of degree up to 999, O'Nan-Scott types 4a, 4b and
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
#V  PrimitiveIndexIrreducibleSolvableGroup
##
##  This variable provides a way to get from irreducible solvable groups to
##  primitive groups and vice versa. For the group
## <G>=`IrreducibleSolvableGroup( <n>, <p>, <k> )' and $d=p^n$, the entry
##  `PrimitiveIndexIrreducibleSolvableGroup[d][i]' gives the index number of
##  the semidirect product $p^n:G$ in the library of primitive groups.
##
##  Searching for an index `Position' in this list gives the translation in
##  the other direction.
DeclareGlobalVariable("PrimitiveIndexIrreducibleSolvableGroup");

#############################################################################
##
#F  MaximalSubgroupsSymmAlt( <grp> [,<onlyprimitive>] )
##
##  For a symmetric or alternating group <grp>, this function returns
##  representatives of the classes of maximal subgroups.
##
##  If the parameter <onlyprimitive> is given and set to `true' only the
##  primitive maximal subgroups are computed.
##
##  No parameter test is performed. (The function relies on the primitive
##  groups library for its functionality.)
##
DeclareGlobalFunction("MaximalSubgroupsSymmAlt");

#############################################################################
##
#E
##




