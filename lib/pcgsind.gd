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
InducedPcgsByPcSequence := NewOperation(
    "InducedPcgsByPcSequence",
    [ IsPcgs, IsList ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )
##
InducedPcgsByPcSequenceNC := NewOperation(
    "InducedPcgsByPcSequenceNC",
    [ IsPcgs, IsList ] );
#T 1997/01/16 fceller was old 'NewConstructor'


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
#O  AsInducedPcgs( <parent>, <pcgs> )
##
AsInducedPcgs := NewOperation(
    "AsInducedPcgs",
    [ IsPcgs, IsList ] );


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

#O  CanonicalPcElement( <pcgs>, <elm> )
##
CanonicalPcElement := NewOperation(
    "CanonicalPcElement",
    [ IsInducedPcgs, IsObject ] );


#############################################################################
##
#O  ClearedPcElement( <pcgs>, <elm> )
##
ClearedPcElement := NewOperation(
    "ClearedPcElement",
    [ IsInducedPcgs, IsObject ] );


#############################################################################
##
#O  SiftedPcElement( <pcgs>, <elm> )
##
SiftedPcElement := NewOperation(
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
HomomorphicCanonicalPcgs := NewOperation(
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
HomomorphicInducedPcgs := NewOperation(
    "HomomorphicInducedPcgs",
    [ IsPcgs, IsList ] );

#############################################################################
##

#E  pcgsind.gd 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
