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
##  The Valuation is the p-part of the p-adic number.
DeclareOperation( "Valuation",  [ IsObject ] );


#############################################################################
##
#O  PadicNumber( <fam>, <rat> )
#O  PadicNumber( <purefam>,<list>)
#O  PadicNumber( <extfam>,<list>)
##
##  creates a $p$-adic number in the $p$-adic numbers family <fam>. The
##  first usage returns the $p$-adic number corresponding to the rational
##  <rat>.
##
##  The second usage takes a pure $p$-adic numbers family <purefam> and a
##  list <list> of length 2 and returns the number `p^<list>[1]  *
##  <list>[2]'.  It must be guaranteed that every entry of  list[2] is never
##  divisible by the prime p.  By that we have always maximum precision.
##
##  The third usage creates a number in the family <extfam> of a $p$-adic
##  extension. The second entry must be a list <L> of length 2 such that
##  <list>[2] is  the list of coeff. for  the  Basis
##  $\{1,\ldots,x^{f-1}cdot y^{e-1}\}$ of the extended p-adic field and
##  <list>[1] is a common p-part of all the coeff.
##
DeclareOperation( "PadicNumber", [ IsPadicNumberFamily, IsObject ] );



#############################################################################
##
#O  ShiftedPadicNumber( <padic>, <int> )
##
##  ShiftedPadicNumber  takes a p-adic number <padic>  and an integer <shift>
##  and returns the  p-adic number   c, that is   `<padic> *  p^<shift>'.   The
##  <shift> is just added to the p-part.
##
DeclareOperation( "ShiftedPadicNumber", [ IsPadicNumber, IsInt ] );


#############################################################################
##
#O  PurePadicNumberFamily( <p>, <precision> )
##
##  returns the family of pure p-adic numbers over the
##  prime  <p> with  <precision>  ``digits''.
##
DeclareGlobalFunction( "PurePadicNumberFamily" );


#############################################################################
##
#F  PadicExtensionNumberFamily( <p>, <precision>, <unram>, <ram> )
##
##  An   extended p-adic field  L  is given by two   polynomials h and g with
##  coeff.-lists   <unram> (for  the  unramified  part)  and <ram>  (for  the
##  ramified part). Then L  is Q_p[x,y]/(h(x),g(y)).  This function takes the
##  prime number  <p> and the two coeff.-lists  <unram> and <ram> for the two
##  polynomials.  It   is  not checked  BUT <unram>   should be  a cyclotomic
##  polynomial and <ram> should be  an Eisenstein-polynomial or [1,1].  Every
##  number  out   of  L is  represented   as   a coeff.-list   for  the basis
##  {1,x,x^2,...,y,xy,x^2y,...} of L.   <precision> is the number of
##  ``digits''
##  that all the coefficients may have.
##  
DeclareGlobalFunction( "PadicExtensionNumberFamily" );


#2
##  A general  comment:    In  PadicExtensionNumberFamily  you  give   the two
##  polynomials  that define  the  extension of  Q_p.  You have to take care
##  yourself that these polynomials  are  really irreducible over Q_p!
##  For example x^2+x+1 is *not* irreducible over Q_p. Therefore the
##  ``extension''
##  PadicExtensionNumberFamily(3, 4, [1,1,1], [1,1]) 
##  contains non-invertible extended  p-adic numbers. Vice versa, if you get
##  noninverible padics, check the polynomials!
##  if that happens, check your polynomials!
##

#3
##  A word of warning:
##  Depending on the actual representation of quotients precision may seem
##  to ``vanish''.
##  For example in PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]) the
##  number (1.2000, 0.1210)(3) can be represented as `[ 0, [ 1.2000, 0.1210
##  ] ]'   or as `[-1, [ 12.000, 1.2100 ] ]' (here the coeff. have to be
##  multiplied by $p^{-1}$).
##
##  So there may be a number (1.2, 2.2)(3) which seems to have only two
##  digits of precision instead of the declared 5. By internally the number
##  is stored as `[-3, [ 0.0012, 0.0022  ] ]'  and  so has in  fact maximum
##  precision.

#############################################################################
##
#E  padics.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
