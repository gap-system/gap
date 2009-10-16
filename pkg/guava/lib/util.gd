#############################################################################
##
#A  util.gd                  GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains miscellaneous functions
##
#H  @(#)$Id: util.gd,v 1.6 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/util_gd") :=
    "@(#)$Id: util.gd,v 1.6 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  SphereContent( <n>, <e> [, <F>] ) . . . . . . . . . . .  contents of ball
##
##  SphereContent(n, e [, F]) calculates the contents of a ball of radius e in 
##  the space (GF(q))^n
##
DeclareOperation("SphereContent", [IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  Krawtchouk( <k>, <i>, <n> [, <F>] ) . . . . . .  Krwatchouk number K_k(i)
##
##  Krawtchouk(k, i, n [, F]) calculates the Krawtchouk number K_k(i) 
##  over field of size q (or 2), wordlength n.
##  Pre: 0 <= k <= n
##
DeclareOperation("Krawtchouk", [IsInt, IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  PermutedCols( <M>, <P> )  . . . . . . . . . .  permutes columns of matrix
##
DeclareOperation("PermutedCols", [IsMatrix, IsPerm]); 

#############################################################################
##
#F  ReciprocalPolynomial( <p> [, <n>] ) . . . . . .  reciprocal of polynomial
##
DeclareOperation("ReciprocalPolynomial",[IsUnivariatePolynomial, IsInt]); 
							
#############################################################################
##
#F  CyclotomicCosets( [<q>, ] <n> ) . . . .  cyclotomic cosets of <q> mod <n>
##
DeclareOperation("CyclotomicCosets", [IsInt, IsInt]); 

#############################################################################
##
#F  PrimitiveUnityRoot( [<q>, ] <n> ) . .  primitive n'th power root of unity
##
DeclareOperation("PrimitiveUnityRoot", [IsInt, IsInt]); 

#############################################################################
##
#F  RemoveFiles( <arglist> )  . . . . . . . .  removes all files in <arglist>
##
##  used for functions which use external programs (like Leons stuff)
##
DeclareGlobalFunction("RemoveFiles"); 

#############################################################################
##
#F  NullVector( <n> [, <F> ] )  . .  vector consisting of <n> coordinates <o>
##
DeclareOperation("NullVector", [IsInt]); 

