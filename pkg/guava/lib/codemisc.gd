#############################################################################
##
#A  codemisc.gd             GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
##
##  This file contains miscellaneous functions for codes
##
#H  @(#)$Id: codemisc.gd,v 1.4 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codemisc_gd") :=
    "@(#)$Id: codemisc.gd,v 1.4 2004/12/20 21:26:06 gap Exp $";

########################################################################
##
#F  CodeWeightEnumerator( <code> )
##
##  Returns a polynomial over the rationals 
##  with degree not greater than the length of the code.
##  The coefficient of x^i equals
##  the number of codewords of weight i.
##
DeclareOperation("CodeWeightEnumerator", [IsCode]); 

########################################################################
##
#F  CodeDistanceEnumerator( <code>, <word> )
##
##  Returns a polynomial over the rationals
##  with degree not greater than the length of the code.
##  The coefficient of x^i equals 
##  the number of codewords with distance i to <word>.
DeclareOperation("CodeDistanceEnumerator", 
										[IsCode, IsCodeword]); 

########################################################################
##
#F  CodeMacWilliamsTransform( <code> )
##
##  Returns a polynomial with the weight
##  distribution of the dual code as
##  coefficients.
##
DeclareOperation("CodeMacWilliamsTransform", [IsCode]); 

########################################################################
##
#F  WeightVector( <vector> )
##
##  Returns the number of non-zeroes in a vector.
DeclareOperation("WeightVector", [IsVector]); 

########################################################################
##
#F  RandomVector( <len> [, <weight> [, <field> ] ] )
##
DeclareOperation("RandomVector", [IsInt, IsInt, IsField]); 

########################################################################
##
#F  IsSelfComplementaryCode( <code> )
##
##  Return true if <code> is a complementary code, false otherwise.
##  A code is called complementary if for every v \in <code>
##  also 1 - v \in <code> (where 1 is the all-one word).
##
DeclareProperty("IsSelfComplementaryCode", IsCode);

########################################################################
##
#F  IsAffineCode( <code> )
##
##  Return true if <code> is affine, i.e. a linear code or
##  a coset of a linear code, false otherwise.
##
DeclareProperty("IsAffineCode", IsCode);

########################################################################
##
#F  IsAlmostAffineCode( <code> )
##
##  Return true if <code> is almost affine, false otherwise.
##  A code is called almost affine if the size of any punctured
##  code is equal to q^r for some integer r, where q is the
##  size of the alphabet of the code.
##
DeclareProperty("IsAlmostAffineCode", IsCode);

########################################################################
##
#F  IsGriesmerCode( <code> )
##
##  Return true if <code> is a Griesmer code, i.e. if
##  n = \sum_{i=0}^{k-1} d/(q^i), false otherwise.
##
DeclareProperty("IsGriesmerCode", IsCode);

########################################################################
##
#F  CodeDensity( <code> )
##
##  Return the density of <code>, i.e. M*V_q(n,r)/(q^n).
##
DeclareAttribute("CodeDensity", IsCode); 

########################################################################
##
#F  DecreaseMinimumDistanceUpperBound( <C>, <s>, <iteration> )
##
##  Tries to compute the minimum distance of C.
##  The algorithm is Leon's, see for more
##  information his article.
DeclareOperation("DecreaseMinimumDistanceUpperBound", 
						[IsCode, IsInt, IsInt]); 


