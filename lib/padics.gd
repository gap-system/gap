#############################################################################
##
#W  padics.gd                   GAP Library                     Jens Hollmann
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration part of the padic numbers.
##
Revision.padics_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsPadicNumber
##
DeclareCategory( "IsPadicNumber", IsScalar 
    and IsAssociativeElement and IsCommutativeElement );

DeclareCategoryCollections( "IsPadicNumber" );
DeclareCategoryCollections( "IsPadicNumberCollection" );

DeclareSynonym( "IsPadicNumberList", IsPadicNumberCollection and IsList );
DeclareSynonym( "IsPadicNumberTable", IsPadicNumberCollColl and IsTable );


#############################################################################
##
#C  IsPadicNumberFamily
##
DeclareCategoryFamily( "IsPadicNumber" );


#############################################################################
##
#C  IsPurePadicNumber(<obj>)
##
DeclareCategory( "IsPurePadicNumber", IsPadicNumber );


#############################################################################
##
#C  IsPurePadicNumberFamily(<fam>)
##
DeclareCategoryFamily( "IsPurePadicNumber" );


#############################################################################
##
#C  IsPadicExtensionNumber(<obj>)
##
DeclareCategory( "IsPadicExtensionNumber", IsPadicNumber );


#############################################################################
##
#C  IsPadicExtensionNumberFamily(<fam>)
##
DeclareCategoryFamily( "IsPadicExtensionNumber" );


#############################################################################
##
#O  Valuation( <obj> )
##
##  The Valuation is the $p$-part of the $p$-adic number.
DeclareOperation( "Valuation",  [ IsObject ] );


#############################################################################
##
#O  PadicNumber( <fam>, <rat> )
#O  PadicNumber( <purefam>,<list>)
#O  PadicNumber( <extfam>,<list>)
##
##  create a $p$-adic number in the $p$-adic numbers family <fam>. The
##  first usage returns the $p$-adic number corresponding to the rational
##  <rat>.
##
##  The second usage takes a pure $p$-adic numbers family <purefam> and a
##  list <list> of length 2 and returns the number `p^<list>[1]  *
##  <list>[2]'.  It must be guaranteed that no entry of list[2] is 
##  divisible by the prime p. (Otherwise precision will get lost.)
##
##  The third usage creates a number in the family <extfam> of a $p$-adic
##  extension. The second entry must be a list <L> of length 2 such that
##  <list>[2] is  the list of coeff. for  the  basis
##  $\{1,\ldots,x^{f-1}\cdot y^{e-1}\}$ of the extended $p$-adic field and
##  <list>[1] is a common $p$-part of all the coeff.
##
##  $p$-adic numbers allow the usual field operations.
##
DeclareOperation( "PadicNumber", [ IsPadicNumberFamily, IsObject ] );

#############################################################################
##
#O  ShiftedPadicNumber( <padic>, <int> )
##
##  ShiftedPadicNumber takes a $p$-adic number <padic> and an integer <shift>
##  and returns the $p$-adic number $c$, that is `<padic>* p^<shift>'. The
##  <shift> is just added to the $p$-part.
##
DeclareOperation( "ShiftedPadicNumber", [ IsPadicNumber, IsInt ] );


#############################################################################
##
#O  PurePadicNumberFamily( <p>, <precision> )
##
##  returns the family of pure $p$-adic numbers over the
##  prime <p> with  <precision>  ``digits''.
##
DeclareGlobalFunction( "PurePadicNumberFamily" );


#############################################################################
##
#F  PadicExtensionNumberFamily( <p>, <precision>, <unram>, <ram> )
##
##  An extended $p$-adic field $L$ is given by two polynomials h and g with
##  coeff.-lists   <unram> (for  the  unramified  part)  and <ram>  (for  the
##  ramified part). Then $L$ is isomorphic to $Q_p[x,y]/(h(x),g(y))$.
##
##  This function takes the prime number  <p> and the two coefficient lists
##  <unram> and <ram> for the two polynomials. The polynomial given by the
##  coefficients in <unram> must be a cyclotomic polynomial and the
##  polynomial given by <ram> an Eisenstein-polynomial (or 1+x). *This is
##  not checked by {\sf GAP}.*
##
##  Every number  out   of  $L$ is  represented   as   a coeff.-list   for
##  the basis $\{1,x,x^2,\ldots,y,xy,x^2y,\ldots\}$ of $L$. The integer
##  <precision> is the number of ``digits'' that all the coefficients have.
##  
DeclareGlobalFunction( "PadicExtensionNumberFamily" );


#2
##  A general  comment: the polynomials with which
##  `PadicExtensionNumberFamily'  is called define an extension of $Q_p$. It
##  must be ensured that both polynomials are  really irreducible over
##  $Q_p$!  For example x^2+x+1 is *not* irreducible over Q_p. Therefore the
##  ``extension'' PadicExtensionNumberFamily(3, 4, [1,1,1], [1,1]) contains
##  non-invertible ``pseudo-$p$-adic numbers''. Conversely, if an
##  ``extension'' contains noninvertible elements one of the polynomials was
##  not irreducible.
##

#3
##  A word of warning:
##  Depending on the actual representation of quotients, precision may seem
##  to ``vanish''.
##  For example in PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]) the
##  number (1.2000, 0.1210)(3) can be represented as `[ 0, [ 1.2000, 0.1210
##  ] ]'   or as `[-1, [ 12.000, 1.2100 ] ]' (here the coefficients have to be
##  multiplied by $p^{-1}$).
##
##  So there may be a number (1.2, 2.2)(3) which seems to have only two
##  digits of precision instead of the declared 5. But internally the number
##  is stored as `[-3, [ 0.0012, 0.0022  ] ]'  and  so has in  fact maximum
##  precision.

#############################################################################
##
#E  padics.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
