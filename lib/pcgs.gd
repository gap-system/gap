#############################################################################
##
#W  pcgs.gd                     GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for polycylic generating systems.
##
Revision.pcgs_gd :=
    "@(#)$Id$";

#############################################################################
##
#C  IsGeneralPcgs(<obj>)
##
##  A general pcgs is a list of elements corresponding to a descending
##  subnormal series for which relative orders are defined.
DeclareCategory( "IsGeneralPcgs",
    IsHomogeneousList and IsDuplicateFreeList and IsFinite
    and IsMultiplicativeElementWithInverseCollection );

#############################################################################
##
#C  IsModuloPcgs(<obj>)
##
##  A modulo pcgs is a generalized pcgs that permits the calculation of
##  exponent vectors. Typically, it is obtained by taking a pcgs modulo
##  another one.
DeclareCategory("IsModuloPcgs",IsGeneralPcgs);

#############################################################################
##
#C  IsPcgs(<obj>)
##
##  A pcgs is a modulo pcgs whose series stops at the identity.
DeclareCategory( "IsPcgs", IsModuloPcgs);


#############################################################################
##
#C  IsPcgsFamily
##
DeclareCategory(
    "IsPcgsFamily",
    IsFamily );


#############################################################################
##
#R  IsPcgsDefaultRep
##
DeclareRepresentation(
    "IsPcgsDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );


#############################################################################
##
#O  PcgsByPcSequence( <fam>, <pcs> )
#O  PcgsByPcSequenceNC( <fam>, <pcs> )
##
##  constructs a pcgs for the elements family <fam> from the elements in the
##  list <pcs>. The elements must be in the family <fam>.
##  The NC version does not test the arguments for validity.
##  `PcgsByPcSequence' calls the operation `PcgsByPcSequenceCons' to do the
##  actual work.
DeclareOperation( "PcgsByPcSequence", [ IsFamily, IsList ] );
DeclareOperation( "PcgsByPcSequenceNC", [ IsFamily, IsList ] );


#############################################################################
##
#O  PcgsByPcSequenceCons( <req-filters>, <imp-filters>, <fam>, <pcs> )
##
DeclareConstructor( "PcgsByPcSequenceCons",
    [ IsObject, IsObject, IsFamily, IsList ] );


#############################################################################
##
#A  GroupByPcgs( <pcgs> )
##
DeclareAttribute(
    "GroupByPcgs",
    IsPcgs );



#############################################################################
##
#A  GroupOfPcgs( <pcgs> )
##
DeclareAttribute(
    "GroupOfPcgs",
    IsPcgs );



#############################################################################
##
#A  OneOfPcgs( <pcgs> )
##
DeclareAttribute(
    "OneOfPcgs",
    IsPcgs );



#############################################################################
##
#A  PcSeries( <pcgs> )
##
##  returns the subnormal series defined by <pcgs>.
DeclareAttribute(
    "PcSeries",
    IsPcgs );



#############################################################################
##
#A  IndicesNormalSteps( <pcgs> )
##
##  gives the indices of the elements of <pcgs> that correspond to a normal
##  subgroup in the descending subnormal series defined by <pcgs>. It ends with
##  an entry `Length(<pcgs>)+1'.
##  If <pcgs> was defined to correspond to a special series, the normal steps
##  given by `IndicesNormalSteps' are chosen to respect the special properties
##  of the series.
DeclareAttribute( "IndicesNormalSteps", IsPcgs );


#############################################################################
##
#A  NormalSeriesByPcgs( <pcgs> )
##
##  returns the series of normal subgroups corresponding to
##  `IndicesNormalSteps(<pcgs>'
##
DeclareAttribute( "NormalSeriesByPcgs", IsPcgs);


#############################################################################
##
#P  IsPrimeOrdersPcgs( <pcgs> )
##
##  tests whether the relative orders of all elements of <pcgs> are prime
##  numbers. Many algorithms require this property.
DeclareProperty(
    "IsPrimeOrdersPcgs",
    IsGeneralPcgs );



#############################################################################
##
#P  IsFiniteOrdersPcgs( <pcgs> )
##
##  tests whether the relative orders of all elements of <pcgs> are finite.
DeclareProperty(
    "IsFiniteOrdersPcgs",
    IsGeneralPcgs );



#############################################################################
##
#M  IsFiniteOrdersPcgs( <pcgs> )
##
InstallTrueMethod( IsFiniteOrdersPcgs, IsPrimeOrdersPcgs );


#############################################################################
##
#O  DepthOfPcElement( <pcgs>, <elm> )
##
##  is the smallest index <i> such that <elm> has a nonzero exponent with
##  respect to <pcgs>. (In other words: The smallest <i> such that <elm> is
##  contained in $U_i$ but not in $U_{i+1}$. The depth of the identity is
##  the length of the pcgs plus one.
DeclareOperation(
    "DepthOfPcElement",
    [ IsModuloPcgs, IsObject ] );


#############################################################################
##
#O  DifferenceOfPcElement( <pcgs>, <left>, <right> )
##
DeclareOperation(
    "DifferenceOfPcElement",
    [ IsPcgs, IsObject, IsObject ] );


#############################################################################
##
#O  ExponentOfPcElement( <pcgs>, <elm>, <pos> )
##
##  returns the <pos>-th exponent of <elm> with respect to <pcgs>.
DeclareOperation(
    "ExponentOfPcElement",
    [ IsModuloPcgs, IsObject, IsPosInt ] );


#############################################################################
##
#O  ExponentsOfPcElement( <pcgs>, <elm> )
#O  ExponentsOfPcElement( <pcgs>, <elm>, <posran> )
##
##  returns the exponents of <elm> with respect to <pcgs>. The second form
##  returns the exponents in the positions given in <posran>.
##  (The result is equivalent to an appended '{posran}' sublist operator.)
##
DeclareOperation(
    "ExponentsOfPcElement",
    [ IsModuloPcgs, IsObject ] );

#############################################################################
##
#O  HeadPcElementByNumber( <pcgs>, <elm>, <num> )
##
DeclareOperation(
    "HeadPcElementByNumber",
    [ IsModuloPcgs, IsObject, IsInt ] );


#############################################################################
##
#O  LeadingExponentOfPcElement( <pcgs>, <elm> )
##
DeclareOperation(
    "LeadingExponentOfPcElement",
    [ IsModuloPcgs, IsObject ] );


#############################################################################
##
#O  PcElementByExponents( <pcgs>, <list> )
##
##  returns the element corresponding to the exponent vector <list> with
##  respect to <pcgs>. This is the element $<pcgs>_i^{<list>_i}$.
DeclareOperation(
    "PcElementByExponents",
    [ IsModuloPcgs, IsList ] );


#############################################################################
##
#O  ReducedPcElement( <pcgs>, <left>, <right> )
##
DeclareOperation(
    "ReducedPcElement",
    [ IsModuloPcgs, IsObject, IsObject ] );


#############################################################################
##
#O  RelativeOrderOfPcElement( <pcgs>, <elm> )
##
##  is the smallest exponent <e> such that $<elm>^e$ has a zero exponent
##  vector with respect to the modulo pcgs <pcgs>.
DeclareOperation(
    "RelativeOrderOfPcElement",
    [ IsModuloPcgs, IsObject ] );


#############################################################################
##
#O  SumOfPcElement( <pcgs>, <left>, <right> )
##
DeclareOperation(
    "SumOfPcElement",
    [ IsModuloPcgs, IsObject, IsObject ] );


#############################################################################
##

#O  ExtendedIntersectionSumPcgs( <parent-pcgs>, <n>, <u>, <modpcgs> )
##
DeclareOperation(
    "ExtendedIntersectionSumPcgs",
    [ IsModuloPcgs, IsList, IsList, IsObject ] );


#############################################################################
##
#O  IntersectionSumPcgs( <parent-pcgs>, <n>, <u> )
##
DeclareOperation(
    "IntersectionSumPcgs",
    [ IsModuloPcgs, IsList, IsList ] );


#############################################################################
##
#O  NormalIntersectionPcgs( <parent-pcgs>, <n>, <u> )
##
DeclareOperation(
    "NormalIntersectionPcgs",
    [ IsModuloPcgs, IsList, IsList ] );


#############################################################################
##
#O  SumPcgs( <parent-pcgs>, <n>, <u> )
##
DeclareOperation(
    "SumPcgs",
    [ IsModuloPcgs, IsList, IsList ] );


#############################################################################
##
#O  SumFactorizationFunctionPcgs( <parent-pcgs>, <n>, <u>, <modpcgs> )
##
DeclareOperation(
    "SumFactorizationFunctionPcgs",
    [ IsModuloPcgs, IsList, IsList, IsObject ] );


#############################################################################
##

#F  EnumeratorByPcgs( <pcgs>, <poss> )
##
DeclareOperation(
    "EnumeratorByPcgs",
    [ IsModuloPcgs ] );


#############################################################################
##
#O  ExtendedPcgs( <N>, <gens> )
##
DeclareOperation(
    "ExtendedPcgs",
    [ IsModuloPcgs, IsList ] );


#############################################################################
##
#P  IsGenericPcgs( <pcgs> )
##
DeclareProperty( "IsGenericPcgs", IsPcgs );


#############################################################################
##
#F  PcgsByIndependentGeneratorsOfAbelianGroup( <A> )
##
DeclareGlobalFunction( "PcgsByIndependentGeneratorsOfAbelianGroup" );

#############################################################################
##
#E  pcgs.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
