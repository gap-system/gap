#############################################################################
##
#W  primitiv.gd              GAP group library               Heiko Theissen
#W                                                           Alexander Hulpke
#W                                                          Colva Roney-Dougal
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
##    \item{$\bullet$} all  primitive  permutation groups of  degree $\<2500$,
##      calculated in \cite{RoneyDougal05}
##      in particular,
##      \itemitem{$\circ$}%unordered
##        the primitive permutation groups up to degree~50,
##        calculated by C.~Sims,
##      \itemitem{$\circ$} the primitive groups with insoluble socles of 
##        degree $\<1000$ as calculated in \cite{DixonMortimer88},
##      \itemitem{$\circ$} the solvable (hence affine) primitive permutation
##        groups of degree $\<256$ as calculated by M.~Short \cite{Sho92},
##      \itemitem{$\circ$} some insolvable affine primitive permutation groups
##        of degree $\<256$ as calculated in \cite{Theissen97}.
##      \itemitem{$\circ$} The solvable primitive groups of degree up to
##        $999$ as calculated in  \cite{EickHoefling02}.
##      \itemitem{$\circ$} The primitive groups of affine type of degree up 
##        to $999$ as calculated in \cite{RoneyDougal02}.
##  \endlist
##
##  Not all groups are named, those which do have names use
##  ATLAS notation. Not all names are necessary unique!
##
##  The list given in \cite{RoneyDougal05} is believed to be complete,
##  correcting various omissions in \cite{DixonMortimer88}, \cite{Sho92}
##  and \cite{Theissen97}.
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
DeclareComponent("prim","2.1");


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
##  groups library are `AllPrimitiveGroups' and `OnePrimitiveGroup'. They
##  obtain the following properties from the database without having to
##  compute them anew: 
##
##  `NrMovedPoints', `Size', `Transitivity', `ONanScottType',
##  `IsSimpleGroup', `IsSolvableGroup', and `SocleTypePrimitiveGroup'.
##
##  (Note, that for groups of degree up to 2499, O'Nan-Scott types 4a, 4b and
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




