#############################################################################
##
#W  ffe.gd                      GAP library                     Werner Nickel
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares operations for 'FFE's.
##
Revision.ffe_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFFE
#C  IsFFECollection
#C  IsFFECollColl
#C  IsFFECollCollColl
##
IsFFE := NewCategoryKernel(
    "IsFFE",
    IsScalar and IsAssociativeElement and IsCommutativeElement,
    IS_FFE );

IsFFECollection := CategoryCollections( IsFFE );

IsFFECollColl := CategoryCollections( IsFFECollection );

IsFFECollCollColl := CategoryCollections( IsFFECollColl );


#############################################################################
##
#C  IsFFEFamily
##
IsFFEFamily := CategoryFamily( IsFFE );


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
#F  GaloisField( <S>, <d> )
#F  GaloisField( <p>, <pol> )
#F  GaloisField( <S>, <pol> )
##
##  'GaloisField' returns a  finite field.  It takes two arguments.  The form
##  'GaloisField(<p>,<d>)',  where <p>,<d> are integers, can also be given as
##  'GaloisField(<p>\^<d>)'.  'GF' is an abbreviation for 'GaloisField'.
##  
##  The first argument  specifies the subfield <S>  over which the new  field
##  <F> is to be  taken.  It  can be  a prime or  a finite field.  If it is a
##  prime <p>, the  subfield is the  prime field of this characteristic.
##  
##  The second  argument specifies the extension.  It can be an integer or an
##  irreducible polynomial.   If  it is an  integer  <d>, the  new  field  is
##  constructed  as  the  polynomial  extension  with  the  Conway polynomial
##  of  degree <d> over the subfield <S>.  If it is an irreducible polynomial
##  <pol>,  in which case the elements  of the list <pol> must all lie in the
##  subfield <S>, the new field  is  constructed as  polynomial extension  of
##  the subfield <S> with this polynomial.
##  
##  Note that the subfield over which a field was constructed determines over
##  which field the Galois group, conjugates, norm,  trace,  minimal polynom,
##  and characteristic polynom are computed (see "GaloisGroup", "Conjugates",
##  "Norm", "Trace", "MinPol", "CharPol", and   "Field  Functions for  Finite
##  Fields").
##  
GaloisField := NewOperationArgs( "GaloisField" );

FiniteField := GaloisField;
GF := GaloisField;


#############################################################################
##
#O  DegreeFFE( <z> )
#O  DegreeFFE( <vec> )
#O  DegreeFFE( <mat> )
##  
##  'DegreeFFE'  returns  the   degree of  the   smallest  finite field   <F>
##  containing the element <z>, respectively all elements of the vector <vec>
##  over a finite field (see "Vectors"), or matrix  <mat> over a finite field
##  (see "Matrices").
##  
DegreeFFE := NewOperation( "DegreeFFE", [ IsFFE ] );


#############################################################################
##
#O  LogFFE( <z>, <r> )
##  
##  'LogFFE' returns the discrete  logarithm of the element <z> in  a  finite
##  field with  respect  to  the  root <r>.
##  An  error is signalled if <z> is zero, or if <z> is not a power of <r>.
##  
##  The *discrete logarithm* of an element $z$ with  respect to a root $r$ is
##  the smallest nonnegative integer $i$ such that $r^i = z$.
##  
LogFFE := NewOperation( "LogFFE", [ IsFFE, IsFFE ] );


#############################################################################
##
#O  IntFFE( <z> )
##
##  'IntFFE' returns the integer corresponding to the element <z>, which must
##  lie in  a finite  prime field.   That is  'IntFFE' returns  the  smallest
##  nonnegative integer <i> such that '<i> \*\ One( <z> ) = <z>'.
##  
##  The  correspondence between   elements   from a finite   prime field   of
##  characteristic <p> and the integers between 0  and  '<p>-1' is defined by
##  choosing 'Z(<p>)'  the     smallest  primitive  root    mod   <p>    (see
##  "PrimitiveRootMod").
##
IntFFE := NewOperation( "IntFFE", [ IsFFE ] );


#############################################################################
##
#O  IntVecFFE( <vecffe> )
##
##  is the list of integers corresponding to the vector <vecffe> of finite
##  field elements in a prime field (see "IntFFE").
##
IntVecFFE := NewOperation( "IntVecFFE", [ IsFFECollection ] );


#############################################################################
##

#E  ffe.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
