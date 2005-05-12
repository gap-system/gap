#############################################################################
##
#W  pcgsind.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This  file  contains  the operations   for  induced polycylic  generating
##  systems.
##
Revision.pcgsind_gd :=
    "@(#)$Id$";

#############################################################################
##
#C  IsInducedPcgs(<pcgs>)
##
##  The category of induced pcgs. This a subcategory of pcgs.
DeclareCategory( "IsInducedPcgs", IsPcgs );


#############################################################################
##
#O  InducedPcgsByPcSequence( <pcgs>, <pcs> )
#O  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )
#O  InducedPcgsByPcSequenceNC( <pcgs>, <pcs>,<depths> )
##
##  If <pcs> is a list of elements that form an induced pcgs with respect to
##  <pcgs> this operation returns an induced pcgs with these elements.
##
##  In the third version, the depths of <pcs> with respect to <pcgs> can be
##  given (they are computed anew otherwise).
DeclareOperation( "InducedPcgsByPcSequence", [ IsPcgs, IsList ] );
DeclareOperation( "InducedPcgsByPcSequenceNC", [ IsPcgs, IsList ] );

#############################################################################
##
#A  LeadCoeffsIGS( <igs> )
##
##  This attribute is used to store leading coefficients with respect to the
##  parent pcgs. the <i>-th entry - if bound - is the leading exponent of
##  the element of <igs> that has depth <i> in the parent.  (It cannot be
##  assigned to a component in `InducedPcgsByPcSequenceNC' as the
##  permutation group methods call it from within the  postprocessing,
##  before this postprocessing however no coefficients may be computed.)
DeclareAttribute( "LeadCoeffsIGS", IsInducedPcgs );


#############################################################################
##
#O  InducedPcgsByPcSequenceAndGenerators( <pcgs>, <ind>, <gens> )
##
##  returns an induced pcgs with respect to <pcgs> of the subgroup generated
##  by <ind> and <gens>. Here <ind> must be an induced pcgs with respect to
##  <pcgs> (or a list of group elements that form such an igs) and it will
##  be used as initial sequence for the computation.
DeclareOperation(
    "InducedPcgsByPcSequenceAndGenerators",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##
#O  InducedPcgsByGenerators( <pcgs>, <gens> )
#O  InducedPcgsByGeneratorsNC( <pcgs>, <gens> )
##
##  returns an induced pcgs with respect to <pcgs> for the subgroup generated
##  by <gens>.
DeclareOperation( "InducedPcgsByGenerators", [ IsPcgs, IsCollection ] );
DeclareOperation( "InducedPcgsByGeneratorsNC", [ IsPcgs, IsCollection ] );


#############################################################################
##
#O  InducedPcgsByGeneratorsWithImages( <pcgs>, <gens>, <imgs> )
##
DeclareOperation(
    "InducedPcgsByGeneratorsWithImages",
    [ IsPcgs, IsCollection, IsCollection ] );

#############################################################################
##
#O  CanonicalPcgsByGeneratorsWithImages( <pcgs>, <gens>, <imgs> )
##
##  computes a canonical, <pcgs>-induced pcgs for the span of <gens> and
##  simultaneously does the same transformations on <imgs>, preserving thus
##  a correspondence between <gens> and <imgs>. This operation is used to
##  represent homomorphisms from a pc group.
DeclareOperation(
    "CanonicalPcgsByGeneratorsWithImages",
    [ IsPcgs, IsCollection, IsCollection ] );


#############################################################################
##
#O  AsInducedPcgs( <parent>, <pcs> )
##
##  Obsolete function, potentially erraneous. DO NOT USE!
##  returns an induced pcgs with <parent> as parent pcgs and to the
##  sequence of elements <pcs>.
DeclareOperation(
    "AsInducedPcgs",
    [ IsPcgs, IsList ] );


#############################################################################
##
#A  ParentPcgs( <pcgs> )
##
##  returns the pcgs by which <pcgs> was induced. If <pcgs> was not induced,
##  it simply returns <pcgs>.
DeclareAttribute( "ParentPcgs", IsInducedPcgs );


#############################################################################
##
#A  CanonicalPcgs( <pcgs> )
##
##  returns the canonical pcgs corresponding to the induced pcgs <pcgs>.
DeclareAttribute( "CanonicalPcgs", IsInducedPcgs );


#############################################################################
##
#P  IsCanonicalPcgs( <pcgs> )
##
##  An induced pcgs is canonical if the matrix of the exponent vectors of
##  the elements of <pcgs> with respect to `ParentPcgs(<pcgs>)' is in
##  Hermite normal form
##  (see \cite{SOGOS}). While a subgroup can have various
##  induced pcgs with respect to a parent pcgs a canonical pcgs is unique.
DeclareProperty( "IsCanonicalPcgs", IsInducedPcgs );

#############################################################################
##
#P  IsParentPcgsFamilyPcgs( <pcgs> )
##
##  This property indicates that the pcgs <pcgs> is induced with respect to
##  a family pcgs.
DeclareProperty( "IsParentPcgsFamilyPcgs", IsInducedPcgs,
  20 # we want this to be larger than filters like `PrimeOrderPcgs'
     # (cf. rank for `IsFamilyPcgs' in pcgsind.gd)
  );

#############################################################################
##
#A  ElementaryAbelianSubseries( <pcgs> )
##
DeclareAttribute(
    "ElementaryAbelianSubseries",
    IsPcgs );



#############################################################################
##
#O  CanonicalPcElement( <ipcgs>, <elm> )
##
##  reduces <elm> at the induces pcgs <ipcgs> such that the exponents of the
##  reduced result <r> are zero at the depths for which there are generators
##  in <ipcgs>. Elements, whose quotient lies in the group generated by
##  <ipcgs> yield the same canonical element.
DeclareOperation( "CanonicalPcElement", [ IsInducedPcgs, IsObject ] );


#############################################################################
##
#O  SiftedPcElement( <pcgs>, <elm> )
##
##  sifts <elm> through <pcgs>, reducing it if the depth is the same as the
##  depth of one of the generators in <pcgs>. Thus the identity is returned
##  if <elm> lies in the group generated by <pcgs>.
##  <pcgs> must be an induced pcgs and <elm> must lie in the span of the
##  parent of <pcgs>.
DeclareOperation(
    "SiftedPcElement",
    [ IsInducedPcgs, IsObject ] );


#############################################################################
##
#O  HomomorphicCanonicalPcgs( <pcgs>, <imgs> )
##
##  It  is important that  <imgs>  are the images of  in  induced  generating
##  system  in their natural order, ie.  they must not be sorted according to
##  their  depths in the new group,  they must be  sorted according to  their
##  depths in the old group.
##
DeclareOperation(
    "HomomorphicCanonicalPcgs",
    [ IsPcgs, IsList ] );


#############################################################################
##
#O  HomomorphicInducedPcgs( <pcgs>, <imgs> )
##
##  It  is important that  <imgs>  are the images of  in  induced  generating
##  system  in their natural order, ie.  they must not be sorted according to
##  their  depths in the new group,  they must be  sorted according to  their
##  depths in the old group.
##
DeclareOperation(
    "HomomorphicInducedPcgs",
    [ IsPcgs, IsList ] );

#############################################################################
##
#O  CorrespondingGeneratorsByModuloPcgs( <mpcgs>, <imgs> )
##
##  let <mpcgs> be a modulo pcgs for a factor of a group $G$ and let
##  $U$ be a subgroup of $G$ generated by <imgs> such that $U$
##  covers the factor for the modulo pcgs. Then this function computes
##  elements in $U$ corresponding to the generators of the modulo pcgs.
##
##  Note that the computation of induced generating sets is not possible
##  for some modulo pcgs.
DeclareGlobalFunction("CorrespondingGeneratorsByModuloPcgs");

#############################################################################
##
#F  NORMALIZE_IGS( <pcgs>, <list> )
##
##  Obsolete function, potentially erraneous. DO NOT USE!
DeclareGlobalFunction("NORMALIZE_IGS");

#############################################################################
##
#E  pcgsind.gd 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
