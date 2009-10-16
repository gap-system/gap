#############################################################################
##
#W  crossed.gd             The Wedderga package           Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                           Gabriela Olteanu
#W                                                              Ángel del Río
##
#H  $Id: crossed.gd,v 1.7 2008/01/03 14:43:22 alexk Exp $
##
#############################################################################


#############################################################################
##
#C  IsElementOfCrossedProduct( <obj> )
#C  IsElementOfCrossedProductCollection( <obj> )
##
DeclareCategory( "IsElementOfCrossedProduct", IsRingElementWithInverse );

DeclareCategoryCollections( "IsElementOfCrossedProduct" );


#############################################################################
##
#C  IsElementOfCrossedProductFamily( <Fam> )
##
DeclareCategoryFamily( "IsElementOfCrossedProduct" );


#############################################################################
##
#A  CoefficientsAndMagmaElements( <elm> ) . . . for elm. in a crossed product
##
##  is a list that contains at the odd positions the group elements,
##  and at the even positions their coefficients in the element <elm>.
##  We did not rename it to "CoefficientsAndGroupElements" since we want to
##  use for crossed products some functions for group rings elements that
##  already use "CoefficientsAndMagmaElements"
##
DeclareAttribute( "CoefficientsAndMagmaElements", IsElementOfCrossedProduct );


#############################################################################
##
#A  ZeroCoefficient( <elm> )
##
##  For an element <elm> of a crossed product $RM$,
##  `ZeroCoefficient' returns the zero element of the coefficient ring $R$.
##
DeclareAttribute( "ZeroCoefficient", IsElementOfCrossedProduct );


#############################################################################
##
#C  IsCrossedProduct( <obj> )
##
##  An object lies in the category `IsCrossedProduct' if it has been 
##  constructed as a crossed product. Each element of such crossed product 
##  has a unique normal form, so `CoefficientsAndMagmaElements' is 
##  well-defined for it. Note that such object will be IsAlgebra in the GAP 
##  since we constructed it in the category IsFLMLORWithOne despite it will
##  be not an algebra in the theoretical sense. In order to give the correct
##  output, we install highly ranked method for ViewObj and PrintObj for
##  generic crossed products.
##
DeclareCategory( "IsCrossedProduct", IsFLMLORWithOne );


#############################################################################
##
#A  UnderlyingMagma( <RM> )
##
DeclareAttribute( "UnderlyingMagma", IsCrossedProduct );


#############################################################################
##
#A  OperationRecord( <RM> )
##
DeclareAttribute( "OperationRecord", IsCrossedProduct );


#############################################################################
##
#A  ActionForCrossedProduct( <RM> )
##
DeclareAttribute( "ActionForCrossedProduct", IsCrossedProduct );


#############################################################################
##
#A  TwistingForCrossedProduct( <RM> )
##
DeclareAttribute( "TwistingForCrossedProduct", IsCrossedProduct );


#############################################################################
##
#A  CenterOfCrossedProduct( <RM> )
##
DeclareAttribute( "CenterOfCrossedProduct", IsCrossedProduct );


#############################################################################
##
#O  ElementOfCrossedProduct( <Fam>, <zerocoeff>, <coeffs>, <mgmelms> )
##
##  `ElementOfCrossedProduct' returns the element $\sum_{i=1}^n c_i m_i^{\prime}$,
##  where $<coeffs> = [ c_1, c_2, \ldots, c_n ]$ is a list of coefficients,
##  $<mgmelms> = [ m_1, m_2, \ldots, m_n ]$ is a list of group elements, and
##  $m_i^{\prime}$ is the image of $m_i$ under an embedding of a group 
##  containing $m_i$ into a crossed product with elements in the family <Fam>.
##  <zerocoeff> must be the zero of the coefficient ring containing $c_i$.
##
DeclareOperation( "ElementOfCrossedProduct",
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ] );

DeclareGlobalFunction("CrossedProduct");

#############################################################################
##
#E
