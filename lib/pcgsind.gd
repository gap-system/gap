#############################################################################
##
#W  pcgsind.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains  the operations   for  induced polycylic  generating
##  systems.
##
Revision.pcgsind_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsInducedPcgs
##
IsInducedPcgs := NewCategory(
    "IsInducedPcgs",
    IsPcgs );


#############################################################################
##

#O  InducedPcgsByPcSequence( <pcgs>, <pcs> )
##
InducedPcgsByPcSequence := NewConstructor(
    "InducedPcgsByPcSequence",
    [ IsPcgs, IsList ] );


#############################################################################
##
#O  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )
##
InducedPcgsByPcSequenceNC := NewConstructor(
    "InducedPcgsByPcSequenceNC",
    [ IsPcgs, IsList ] );


#############################################################################
##

#O  InducedPcgsByPcSequenceAndGenerators( <pcgs>, <ind>, <gens> )
##
InducedPcgsByPcSequenceAndGenerators := NewOperation(
    "InducedPcgsByPcSequenceAndGenerators",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##
#O  InducedPcgsByGenerators( <pcgs>, <gens> )
##
InducedPcgsByGenerators := NewOperation(
    "InducedPcgsByGenerators",
    [ IsPcgs, IsCollection ] );


#############################################################################
##
#O  InducedPcgsByGeneratorsNC( <pcgs>, <gens> )
##
InducedPcgsByGeneratorsNC := NewOperation(
    "InducedPcgsByGeneratorsNC",
    [ IsPcgs, IsCollection ] );


#############################################################################
##
#O  InducedPcgsByGeneratorsWithImages( <pcgs>, <gens>, <imgs> )
##
InducedPcgsByGeneratorsWithImages := NewOperation(
    "InducedPcgsByGeneratorsWithImages",
    [ IsPcgs, IsCollection, IsCollection ] );

#############################################################################
##

#A  ParentPcgs( <pcgs> )
##
ParentPcgs := NewAttribute(
    "ParentPcgs",
    IsInducedPcgs );

SetParentPcgs := Setter(ParentPcgs);
HasParentPcgs := Tester(ParentPcgs);


#############################################################################
##
#A  CanonicalPcgs( <pcgs> )
##
CanonicalPcgs := NewAttribute(
    "CanonicalPcgs",
    IsInducedPcgs );


#############################################################################
##
#P  IsCanonicalPcgs( <pcgs> )
##
IsCanonicalPcgs := NewProperty(
    "IsCanonicalPcgs",
    IsInducedPcgs );

SetIsCanonicalPcgs := Setter(IsCanonicalPcgs);
HasIsCanonicalPcgs := Tester(IsCanonicalPcgs);


#############################################################################
##

#O  SiftedPcElement( <pcgs>, <elm> )
##
SiftedPcElement := NewOperation(
    "SiftedPcElement",
    [ IsPcgs, IsObject ] );


#############################################################################
##
#O  HomomorphicInducedPcgs( <pcgs>, <imgs> )
##
##  It  is important that  <imgs>  are the images of  in  induced  generating
##  system  in their natural order, ie.  they must not be sorted according to
##  their  depths in the new group,  they must be  sorted according to  their
##  depths in the old group.
##
HomomorphicInducedPcgs := NewOperation(
    "HomomorphicInducedPcgs",
    [ IsPcgs, IsList ] );


#############################################################################
##

#E  pcgsind.gd 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
