#############################################################################
##
#A  util2.gd                GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains miscellaneous functions
##
#H  @(#)$Id: util2.gd,v 1.5 2004/12/20 21:26:06 gap Exp $
##
## several functions added 12-16-2005 
##            (CoefficientToPolynomial, ...,DivisorsMultivariatePolynomial)

Revision.("guava/lib/util2_gd") :=
    "@(#)$Id: util2.gd,v 1.5 2004/12/20 21:26:06 gap Exp $";

########################################################################
##
#F  AllOneVector( <n> [, <field> ] )
##
##  Return a vector with all ones.
##
DeclareOperation("AllOneVector", [IsInt, IsField]); 

########################################################################
##
#F  AllOneCodeword( <n>, <field> )
##
##  Return a codeword with <n> ones.
##
DeclareOperation("AllOneCodeword", [IsInt, IsField]); 

#############################################################################
##
#F  IntCeiling( <r> )
##
##  Return the smallest integer greater than or equal to r.
##  3/2 => 2,  -3/2 => -1.
##
DeclareOperation("IntCeiling", [IsRat]); 

########################################################################
##
#F  IntFloor( <r> ) 
##
##  Return the greatest integer smaller than or equal to r.
##  3/2 => 1, -3/2 => -2.
##
DeclareOperation("IntFloor", [IsRat]); 

########################################################################
##
#F  KroneckerDelta( <i>, <j> )
##
##  Return 1 if i = j,
##         0 otherwise
##
DeclareOperation("KroneckerDelta", [IsInt, IsInt]); 

########################################################################
##
#F  BinaryRepresentation( <elements>, <length> )
##
##  Return a binary representation of an element
##  of GF( 2^k ), where k <= length.
##  
##  If elements is a list, then return the binary
##  representation of every element of the list.
##
##  This function is used to make to Gabidulin codes.
##  It is not intended to be a global function, but including
##  it in all five Gabidulin codes is a bit over the top
##
##  Therefore, no error checking is done.
##

########################################################################
##
#F  SortedGaloisFieldElements( <size> )
##
##  Sort the field elements of size <size> according to
##  their log.
##
##  This function is used to make to Gabidulin codes.
##  It is not intended to be a global function, but including
##  it in all five Gabidulin codes is not a good idea.
## 

########################################################################
##
#F  CoefficientToPolynomial( <coeffs> , <R> )
##  
##  Input: a list of coeffs = [c0,c1,..,cd]
##         a univariate polynomial ring R = F[x]
##  Output: a polynomial c0+c1*x+...+cd*x^(d-1) in R
##
DeclareOperation("CoefficientToPolynomial", [IsList, IsRing]); 

########################################################################
##
#F  VandermondeMat( <Pts> , <a> )
##  
## Input: Pts=[x1,..,xn], a >0 an integer
## Output: Vandermonde matrix (xi^j), 
##         for xi in Pts and 0 <= j <= a
##         (an nx(a+1) matrix)
##
DeclareOperation("VandermondeMat", [IsList, IsInt]); 

###########################################################
##
##      DegreeMonomialTerm(m)
##  
## Input: a monomial m in n variables,
##        n1 <= n is the number of variables occuring
##          in each monomial term of m. 
## Output: the list of degrees of each variable in m.
##

########################################################################
##
#F  DivisorsMultivariatePolynomial( <f> , <R> )
##  
## Input: f is a polynomial in R=F[x1,...,xn]
## Output: all divisors of f
## uses a slow algorithm (see Joachim von zur Gathen, Jürgen Gerhard,
##  Modern Computer Algebra, exercise 16.10)
DeclareOperation("DivisorsMultivariatePolynomial",[IsPolynomial,IsPolynomialRing]); 

###########################################################
##
#F    MultiplicityInList(L,a)
##  
## Input: a list L
##        an element a of L
## Output: the multiplicity a occurs in L
##

###########################################################
##
#F    MostCommonInList(L,a)
##  
## Input: a list L
## Output: an a in L which occurs at least as much as any other in L
##