#############################################################################
##
#A  codenorm.gd             GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
##
##  This file contains functions for calculating code norms
##
#H  @(#)$Id: codenorm.gd,v 1.4 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codenorm_gd") :=
    "@(#)$Id: codenorm.gd,v 1.4 2004/12/20 21:26:06 gap Exp $";

########################################################################
##
#F  CoordinateSubCode( <code>, <i>, <element> )
##
##  Return the subcode of <code>, that has elements
##  with an <element> in coordinate position <i>.
##  If no elements have an <element> in position <i>, return false.
##
DeclareOperation("CoordinateSubCode", [IsCode, IsInt, IsFFE]); 

########################################################################
##
#F  CoordinateNorm( <code>, <i> )
##
##  Returns the norm of code with respect to coordinate i.
##
DeclareAttribute("CoordinateNorm", IsCode, "mutable");

########################################################################
##
#F  CodeNorm( <code> )
##
##  Return the norm of code.
##  The norm of code is the minimum of the coordinate norms
##  of code with respect to i = 1, ..., n.
##
DeclareAttribute("CodeNorm", IsCode);

########################################################################
##
#F  IsCoordinateAcceptable( <code>, <i> )
##
##  Test whether coordinate i of <code> is acceptable.
##  (a coordinate is acceptable if the norm of code with respect to
##   that coordinate is less than or equal to one plus two times the 
##   covering radius of code).
DeclareOperation("IsCoordinateAcceptable", 
										[IsCode, IsInt]); 
########################################################################
##
#F  IsNormalCode( <code> )
##
##  Return true if code is a normal code, false otherwise.
##  A code is called normal if its norm is smaller than or
##  equal to two times its covering radius + one.
##
DeclareProperty("IsNormalCode", IsCode);

########################################################################
##
#F  GeneralizedCodeNorm( <code>, <code1>, <code2>, ... , <codek> )
## 
##  Compute the k-norm of code with respect to the k subcode
##  code1, code2, ... , codek.
##
DeclareGlobalFunction("GeneralizedCodeNorm"); 

