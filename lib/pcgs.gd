#############################################################################
##
#W  pcgs.gd                     GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for polycylic generating systems.
##
Revision.pcgs_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsPcgs
##
IsPcgs := NewCategory(
    "IsPcgs",
    IsHomogeneousList and IsDuplicateFreeList 
    and IsMultiplicativeElementWithInverseCollection );


#############################################################################
##
#C  IsPcgsFamily
##
IsPcgsFamily := NewCategory(
    "IsPcgsFamily",
    IsFamily );


#############################################################################
##
#R  IsPcgsDefaultRep
##
IsPcgsDefaultRep := NewRepresentation(
    "IsPcgsDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##

#O  PcgsByPcSequence( <fam>, <pcs> )
##
PcgsByPcSequence := NewOperation(
    "PcgsByPcSequence",
    [ IsFamily, IsList ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  PcgsByPcSequenceNC( <fam>, <pcs> )
##
PcgsByPcSequenceNC := NewOperation(
    "PcgsByPcSequenceNC",
    [ IsFamily, IsList ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  PcgsByPcSequenceCons( <req-filters>, <imp-filters>, <fam>, <pcs> )
##
PcgsByPcSequenceCons := NewConstructor(
    "PcgsByPcSequenceCons",
    [ IsObject, IsObject, IsFamily, IsList ] );


#############################################################################
##

#A  GroupByPcgs( <pcgs> )
##
GroupByPcgs := NewAttribute(
    "GroupByPcgs",
    IsPcgs );

SetGroupByPcgs := Setter(GroupByPcgs);
HasGroupByPcgs := Tester(GroupByPcgs);


#############################################################################
##
#A  GroupOfPcgs( <pcgs> )
##
GroupOfPcgs := NewAttribute(
    "GroupOfPcgs",
    IsPcgs );

SetGroupOfPcgs := Setter(GroupOfPcgs);
HasGroupOfPcgs := Tester(GroupOfPcgs);


#############################################################################
##
#A  OneOfPcgs( <pcgs> )
##
OneOfPcgs := NewAttribute(
    "OneOfPcgs",
    IsPcgs );

SetOneOfPcgs := Setter(OneOfPcgs);
HasOneOfPcgs := Tester(OneOfPcgs);


#############################################################################
##
#A  PcSeries( <pcgs> )
##
PcSeries := NewAttribute(
    "PcSeries",
    IsPcgs );

SetPcSeries := Setter(PcSeries);
HasPcSeries := Tester(PcSeries);


#############################################################################
##

#P  IsPrimeOrdersPcgs( <pcgs> )
##
IsPrimeOrdersPcgs := NewProperty(
    "IsPrimeOrdersPcgs",
    IsPcgs );

SetIsPrimeOrdersPcgs := Setter(IsPrimeOrdersPcgs);
HasIsPrimeOrdersPcgs := Tester(IsPrimeOrdersPcgs);


#############################################################################
##
#P  IsFiniteOrdersPcgs( <pcgs> )
##
IsFiniteOrdersPcgs := NewProperty(
    "IsFiniteOrdersPcgs",
    IsPcgs );

SetIsFiniteOrdersPcgs := Setter(IsFiniteOrdersPcgs);
HasIsFiniteOrdersPcgs := Tester(IsFiniteOrdersPcgs);


#############################################################################
##
#M  IsFiniteOrdersPcgs( <pcgs> )
##
InstallTrueMethod( IsFiniteOrdersPcgs, IsPrimeOrdersPcgs );


#############################################################################
##

#O  DepthOfPcElement( <pcgs>, <elm> )
##
DepthOfPcElement := NewOperation(
    "DepthOfPcElement",
    [ IsPcgs, IsObject ] );


#############################################################################
##
#O  DifferenceOfPcElement( <pcgs>, <left>, <right> )
##
DifferenceOfPcElement := NewOperation(
    "DifferenceOfPcElement",
    [ IsPcgs, IsObject, IsObject ] );


#############################################################################
##
#O  ExponentOfPcElement( <pcgs>, <elm>, <pos> )
##
ExponentOfPcElement := NewOperation(
    "ExponentOfPcElement",
    [ IsPcgs, IsObject, IsInt and IsPosRat ] );


#############################################################################
##
#O  ExponentsOfPcElement( <pcgs>, <elm> )
##
ExponentsOfPcElement := NewOperation(
    "ExponentsOfPcElement",
    [ IsPcgs, IsObject ] );


#############################################################################
##
#O  HeadPcElementByNumber( <pcgs>, <elm>, <num> )
##
HeadPcElementByNumber := NewOperation(
    "HeadPcElementByNumber",
    [ IsPcgs, IsObject, IsInt ] );


#############################################################################
##
#O  LeadingExponentOfPcElement( <pcgs>, <elm> )
##
LeadingExponentOfPcElement := NewOperation(
    "LeadingExponentOfPcElement",
    [ IsPcgs, IsObject ] );


#############################################################################
##
#O  PcElementByExponents( <pcgs>, <list> )
##
PcElementByExponents := NewOperation(
    "PcElementByExponents",
    [ IsPcgs, IsList ] );


#############################################################################
##
#O  ReducedPcElement( <pcgs>, <left>, <right> )
##
ReducedPcElement := NewOperation(
    "ReducedPcElement",
    [ IsPcgs, IsObject, IsObject ] );


#############################################################################
##
#O  RelativeOrderOfPcElement( <pcgs>, <elm> )
##
RelativeOrderOfPcElement := NewOperation(
    "RelativeOrderOfPcElement",
    [ IsPcgs, IsObject ] );


#############################################################################
##
#O  SumOfPcElement( <pcgs>, <left>, <right> )
##
SumOfPcElement := NewOperation(
    "SumOfPcElement",
    [ IsPcgs, IsObject, IsObject ] );


#############################################################################
##

#O  ExtendedIntersectionSumPcgs( <parent-pcgs>, <n>, <u> )
##
ExtendedIntersectionSumPcgs := NewOperation(
    "ExtendedIntersectionSumPcgs",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##
#O  IntersectionSumPcgs( <parent-pcgs>, <n>, <u> )
##
IntersectionSumPcgs := NewOperation(
    "IntersectionSumPcgs",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##
#O  NormalIntersectionPcgs( <parent-pcgs>, <n>, <u> )
##
NormalIntersectionPcgs := NewOperation(
    "NormalIntersectionPcgs",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##
#O  SumPcgs( <parent-pcgs>, <n>, <u> )
##
SumPcgs := NewOperation(
    "SumPcgs",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##
#O  SumFactorizationFunctionPcgs( <parent-pcgs>, <n>, <u> )
##
SumFactorizationFunctionPcgs := NewOperation(
    "SumFactorizationFunctionPcgs",
    [ IsPcgs, IsList, IsList ] );


#############################################################################
##

#F  EnumeratorByPcgs( <pcgs>, <poss> )
##
EnumeratorByPcgs := NewOperation(
    "EnumeratorByPcgs",
    [ IsPcgs ] );


#############################################################################
##
#O  ExtendedPcgs( <N>, <gens> )
##
ExtendedPcgs := NewOperation(
    "ExtendedPcgs",
    [ IsPcgs, IsList and IsMultiplicativeElementWithInverseCollection ] );


#############################################################################
##

#E  pcgs.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
