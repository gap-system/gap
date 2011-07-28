############################################################################
##
##  util.gd                      IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: util.gd,v 1.3 2011/04/07 07:58:09 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#I  InfoIrredsol
##
##  info class for the library
##  
DeclareInfoClass ("InfoIrredsol");


############################################################################
##
#F  TestFlag(<n>)
##
##  tests if a bit is set in t
##  
DeclareGlobalFunction ("TestFlag");


############################################################################
##
#F  NumberOfFFPolynomial(<p>, <q>)
##
##  computes a number characterising the polynomial p.
##  The polynomial p wmust be over GF(q)
##  
DeclareGlobalFunction ("NumberOfFFPolynomial");


############################################################################
##
#F  FFMatrixByNumber(n, d, q)
##
##  computes a d x d matrix over GF(q) represented by the integer n
##  
DeclareGlobalFunction ("FFMatrixByNumber");


############################################################################
##
#F  CanonicalPcgsByNumber(<p>, <q>)
##
##  computes a number characterising the matrix m.
##  The matrix m wmust be over GF(q)
##  
DeclareGlobalFunction ("CanonicalPcgsByNumber");


############################################################################
##
#F  OrderGroupByCanonicalPcgsByNumber(<pcgs>, <n>)
##
##  computes Order (Group (CanonicalPcgsByNumber(<pcgs>, <n>))) without 
##  actually constructing the canonical pcgs or the group
##  
DeclareGlobalFunction ("OrderGroupByCanonicalPcgsByNumber");


############################################################################
##
#F  ExponentsCanonicalPcgsByNumber(<pcgs>, <n>)
##
##  computes the list of exponent vectors (relative to exp) of the 
##  elements of CanonicalPcgsByNumber(<pcgs>, <n>)) without actually
##  constructing the canonical pcgs itself
##  
DeclareGlobalFunction ("ExponentsCanonicalPcgsByNumber");


############################################################################
##
#F  IsMatGroupOverFieldFam(famG, famF)
##
##  tests whether famG is the collections family of matrices over the field
##  whose family is famF
##  
DeclareGlobalFunction ("IsMatGroupOverFieldFam");


############################################################################
##
#F  IsPPowerInt(q)
##
##  tests whether q is a prime power, caching new prime powers
##  
DeclareGlobalFunction ("IsPPowerInt");


############################################################################
##
#E
##
