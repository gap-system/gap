#############################################################################
##
#W  pcgsind.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
##  is the cateory of induced pcgs.
DeclareCategory( "IsInducedPcgs", IsPcgs );


#############################################################################
##
#O  InducedPcgsByPcSequence( <pcgs>, <pcs> )
#O  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )
##
##  If <pcs> is a list of elements that form an induced pcgs with respect to
##  <pcgs> this operation returns an induced pcgs with these elements.
##  The NC version skips argument checks.
DeclareOperation( "InducedPcgsByPcSequence", [ IsPcgs, IsList ] );
DeclareOperation( "InducedPcgsByPcSequenceNC", [ IsPcgs, IsList ] );


#############################################################################
##
#O  InducedPcgsByPcSequenceAndGenerators( <pcgs>, <ind>, <gens> )
##
DeclareOperation(
    "InducedPcgsByPcSequenceAndGenerators",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##
#O  InducedPcgsByGenerators( <pcgs>, <gens> )
#O  InducedPcgsByGeneratorsNC( <pcgs>, <gens> )
##
##  If <pcs> is a list of generators for a subgroup <U>,
##  this operation returns an induced pcgs for <U> with respect to <pcgs>.
##  The NC version skips argument checks.
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
DeclareOperation(
    "CanonicalPcgsByGeneratorsWithImages",
    [ IsPcgs, IsCollection, IsCollection ] );


#############################################################################
##
#O  AsInducedPcgs( <parent>, <pcgs> )
##
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
##  returns a canonical pcgs derived from the (induced) pcgs <pcgs>.
DeclareAttribute( "CanonicalPcgs", IsInducedPcgs );


#############################################################################
##
#P  IsCanonicalPcgs( <pcgs> )
##
##  An induced pcgs is canonical if the matrix of the exponent vectors of
##  the elements of <pcgs> with respect to `ParentPcgs(<pcgs>)' is in normed
##  echelon form with columns in which a row has its first entry cleared in
##  the other rows (see \cite{SOGOS}). While a subgroup can have various
##  induced pcgs with respect to a parent pcgs a canonical pcgs is unique.
DeclareProperty( "IsCanonicalPcgs", IsInducedPcgs );



#############################################################################
##
#P  IsParentPcgsFamilyPcgs( <pcgs> )
##
DeclareProperty(
    "IsParentPcgsFamilyPcgs",
    IsInducedPcgs );



#############################################################################
##
#A  ElementaryAbelianSubseries( <pcgs> )
##
DeclareAttribute(
    "ElementaryAbelianSubseries",
    IsPcgs );



#############################################################################
##
#O  CanonicalPcElement( <pcgs>, <elm> )
##
DeclareOperation(
    "CanonicalPcElement",
    [ IsInducedPcgs, IsObject ] );


#############################################################################
##
#O  SiftedPcElement( <pcgs>, <elm> )
##
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
##  computes a list of elements in the span of <imgs> that form a cgs with
##  respect to <mpcgs> (The calculation of induced generating sets is not
##  possible for some modulo pcgs).
DeclareGlobalFunction("CorrespondingGeneratorsByModuloPcgs");

#############################################################################
##
#E  pcgsind.gd 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
