#############################################################################
##
#W  ffe.gd                      GAP library                     Werner Nickel
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares operations for 'FFE's.
##
Revision.ffe_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFFE
##
IsFFE := NewCategoryKernel(
    "IsFFE",
    IsScalar and IsAssociativeElement and IsCommutativeElement,
    IS_FFE );

IsFFECollection := CategoryCollections(
    "IsFFECollection",
    IsFFE );

IsFFECollColl := CategoryCollections(
    "IsFFECollColl",
    IsFFECollection );

IsFFECollCollColl := CategoryCollections(
    "IsFFECollCollColl",
    IsFFECollColl );


#############################################################################
##
#C  IsFFEFamily
##
IsFFEFamily := CategoryFamily(
    "IsFFEFamily",
    IsFFE );


#############################################################################
##

#F  FFEFamily( <p> )
##
##  is the family of finite field elements in characteristic <p>.
##
FFEFamily := NewOperationArgs( "FFEFamily" );


#############################################################################
##
#V  FAMS_FFE_EXT
##
##  At position 1 the ordered list of characteristics is stored,
##  at position 2 the families of field elements of these characteristics.
##
FAMS_FFE_EXT := [ [], [] ];


#############################################################################
##
#V  GALOIS_FIELDS
##
##  global list of finite fields 'GF( <p>^<d> )',
##  the field of size $p^d$ is stored in 'GALOIS_FIELDS[<p>][<d>]'.
##
GALOIS_FIELDS := [];


#############################################################################
##
#F  LargeGaloisField( <p>^<n> )
#F  LargeGaloisField( <p>, <n> )
##
#T other construction possibilities?
##
LargeGaloisField := NewOperationArgs( "LargeGaloisField" );


#############################################################################
##
#F  GaloisField( <p>^<d> )  . . . . . . . . . .  create a finite field object
#F  GaloisField( <p>, <d> )
#F  GaloisField( <subfield>, <d> )
#F  GaloisField( <p>, <pol> )
#F  GaloisField( <subfield>, <pol> )
##
GaloisField := NewOperationArgs( "GaloisField" );

FiniteField := GaloisField;
GF := GaloisField;


#############################################################################
##
#O  DegreeFFE( <ffe> )
##
DegreeFFE := NewOperation( "DegreeFFE", [ IsFFE ] );


#############################################################################
##
#O  LogFFE( <ffe>, <ffe> )
##
LogFFE := NewOperation( "LogFFE", [ IsFFE, IsFFE ] );


#############################################################################
##
#O  IntFFE( <ffe> )
##
IntFFE := NewOperation( "IntFFE", [ IsFFE ] );


#############################################################################
##

#E  ffe.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
