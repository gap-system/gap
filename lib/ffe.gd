#############################################################################
##
#W  ffe.gd                      GAP library                     Werner Nickel
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares operations for `FFE's.
##
#1
##  For creating elements of a finite field the function `Z' can be used.
##  The call `Z( <p>^<d> )' returns  the designated generator of  the 
##  multiplicative
##  group of the finite field with `<p>^<d>' elements.  <p>  must be a prime
##  and `<p>^<d>' must be less than or equal to $2^{16} = 65536$.
##
##  The  root returned by `Z' is  a generator of  the multiplicative group of
##  the finite field with $p^d$ elements, which  is cyclic.  The order of the
##  element is  of course $p^d-1$.  The $p^d-1$  different powers of the root
##  are exactly the nonzero elements of the finite field.
##
##  Thus  all nonzero elements of the  finite field  with `<p>^<d>' elements
##  can  be entered  as `Z(<p>^<d>)^<i>'.  Note that this is  also the form
##  that {\GAP} uses to output those elements.
##
##  The additive neutral element  is `0\*Z(<p>)'.  It  is  different from the
##  integer `0' in subtle ways.  First `IsInt( 0\*Z(<p>)  )' (see "IsInt") is
##  `false' and `IsFFE( 0\*Z(<p>) )'  (see "IsFFE") is  `true', whereas it is
##  just the other way around for the integer `0'.
##
##  The multiplicative neutral element is `Z(<p>)^0'.   It is different from
##  the integer `1' in subtle ways.  First `IsInt( Z(<p>)^0 )' (see "IsInt")
##  is `false' and `IsFFE( Z(<p>)^0 )' (see  "IsFFE") is  `true', whereas it
##  is just the  other  way around for the  integer `1'.  Also `1+1' is `2',
##  whereas, e.g., `Z(2)^0 + Z(2)^0' is `0\*Z(2)'.
##
##  The  various  roots  returned  by  `Z'  for  finite  fields  of the  same
##  characteristic  are  compatible  in  the  following  sense.  If the field
##  $GF(p^n)$ is a  subfield of the  field  $GF(p^m)$, i.e., $n$ divides $m$,
##  then $Z(p^n) = Z(p^m)^{(p^m-1)/(p^n-1)}$.  Note that this is the simplest
##  relation that may  hold  between a generator of $GF(p^n)$ and  $GF(p^m)$,
##  since $Z(p^n)$ is an element of order $p^m-1$ and $Z(p^m)$  is an element
##  of order  $p^n-1$.  This is achieved  by choosing $Z(p)$ as  the smallest
##  primitive  root modulo $p$  and  $Z(p^n)$ as a root of the $n$-th *Conway
##  polynomial* (see~"ConwayPolynomial") of characteristic $p$.
##  Those polynomials were defined by J.~H.~Conway, and many of them were
##  computed by R.~A.~Parker.
##
##  Elements of prime fields of order larger than $2^{16}$ can be handled
##  using the machinery of Residue Class Rings
##  (see section~"Residue Class Rings").
##

#############################################################################
#2
##  Since finite field elements are scalars, the operations `Characteristic',
##  `One', `Zero', `Inverse', `AdditiveInverse', `Order' can be applied to
##  then (see~"Attributes and Properties of Elements").
##  Contrary to the situation with other scalars, `Order' is defined also for
##  the zero element in a finite field, with value `0'.
##  % mainly for {\GAP}~3 compatibility ...
##

#############################################################################
#3
##  `DefaultField' (see~"DefaultField") and `DefaultRing' (see~"DefaultRing")
##  for finite field elements are defined to return the *smallest* field
##  containing the given elements.
##
Revision.ffe_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFFE(<obj>)
#C  IsFFECollection(<obj>)
#C  IsFFECollColl(<obj>)
#c  IsFFECollCollColl(<obj>)
##
##  Objects in the category `IsFFE' are used to implement elements of finite
##  fields.  In this manual, the term *finite field element* always means an
##  object in `IsFFE'.
##  All finite field elements of the same characteristic form a family in
##  {\GAP} (see~"Families").
##  Any collection of finite field elements (see~"IsCollection") lies in
##  `IsFFECollection', and a collection of such collections
##  (e.g., a matrix) lies in `IsFFECollColl'.
##
DeclareCategoryKernel( "IsFFE",
    IsScalar and IsAssociativeElement and IsCommutativeElement
    and IsAdditivelyCommutativeElement and IsZDFRE,
    IS_FFE );

DeclareCategoryCollections( "IsFFE" );
DeclareCategoryCollections( "IsFFECollection" );
DeclareCategoryCollections( "IsFFECollColl" );


#############################################################################
##
#C  IsFFEFamily
##
DeclareCategoryFamily( "IsFFE" );


#############################################################################
##

#F  FFEFamily( <p> )
##
##  is the family of finite field elements in characteristic <p>.
##
DeclareGlobalFunction( "FFEFamily" );


#############################################################################
##
#V  FAMS_FFE_LARGE
##
##  At position 1 the ordered list of characteristics is stored,
##  at position 2 the families of field elements of these characteristics.
##
##  Known families of FFE in characteristic at most `MAXSIZE_GF_INTERNAL'
##  are stored via the types in the list `TYPE_FFE', the default type of
##  elements in characteristic $p$ at position $p$.
##
BIND_GLOBAL( "FAMS_FFE_LARGE", [ [], [] ] );


#############################################################################
##
#V  GALOIS_FIELDS
##
##  global list of finite fields `GF( <p>^<d> )',
##  the field of size $p^d$ is stored in `GALOIS_FIELDS[<p>][<d>]'.
##
DeclareGlobalVariable( "GALOIS_FIELDS",
    "list of lists, GALOIS_FIELDS[p][n] = GF(p^n) if bound" );
InstallFlushableValue( GALOIS_FIELDS, [] );


#############################################################################
##
#F  LargeGaloisField( <p>^<n> )
#F  LargeGaloisField( <p>, <n> )
##
#T other construction possibilities?
##
DeclareGlobalFunction( "LargeGaloisField" );


#############################################################################
##
#F  GaloisField( <p>^<d> )  . . . . . . . . . .  create a finite field object
#F  GaloisField( <p>, <d> )
#F  GaloisField( <S>, <d> )
#F  GaloisField( <p>, <pol> )
#F  GaloisField( <S>, <pol> )
##
##  `GaloisField' returns a finite field.  It takes two arguments.
##  The form `GaloisField( <p>, <d> )', where <p>, <d> are integers,
##  can also be given as `GaloisField( <p>^<d> )'.
##  `GF' is an abbreviation for `GaloisField'.
##
##  The first argument specifies the subfield <S> over which the new field
##  <F> is to be taken.
##  It can be a prime or a finite field.
##  If it is a prime <p>, the subfield is the prime field of this
##  characteristic.
##
##  The second argument specifies the extension.
##  It can be an integer or an irreducible polynomial over the field <S>.
##  If it is an integer <d>, the new field is constructed as the
##  polynomial extension with the Conway polynomial (see~"ConwayPolynomial")
##  of degree <d> over the subfield <S>.
##  If it is an irreducible polynomial <pol> over <S>,
##  the new field is constructed as polynomial extension of the subfield <S>
##  with this polynomial;
##  in this case, <pol> is accessible as the value of `DefiningPolynomial'
##  (see~"DefiningPolynomial") for the new field,
##  and a root of <pol> in the new field is accessible as the value of
##  `RootOfDefiningPolynomial' (see~"RootOfDefiningPolynomial").
##
##  Note that the subfield over which a field was constructed determines over
##  which  field  the  Galois  group,  conjugates,   norm,   trace,   minimal
##  polynomial, and trace polynomial are  computed  (see~"GaloisGroup!of field",
##  "Conjugates", "Norm", "Trace!for field elements", "MinimalPolynomial!over
##  a field", "TracePolynomial").
##
##  The field is regarded as a vector space (see~"Vector Spaces") over the
##  given subfield, so this determines the dimension and the canonical basis
##  of the field.
##
DeclareGlobalFunction( "GaloisField" );

DeclareSynonym( "FiniteField", GaloisField );
DeclareSynonym( "GF", GaloisField );


#############################################################################
##
#O  DegreeFFE( <z> )
#O  DegreeFFE( <vec> )
#O  DegreeFFE( <mat> )
##  
##  `DegreeFFE'  returns  the   degree of  the   smallest  finite field
##  <F> containing the element <z>, respectively all elements of the vector
##  <vec> over a finite field (see~"Row Vectors"), or matrix  <mat> over a
##  finite field (see~"Matrices").
##  
DeclareOperation( "DegreeFFE", [ IsFFE ] );


#############################################################################
##
#O  LogFFE( <z>, <r> )
##  
##  `LogFFE' returns the discrete  logarithm of the element <z> in  a  finite
##  field with  respect  to  the  root <r>.
##  An  error is signalled if <z> is zero, or if <z> is not a power of <r>.
##  
##  The *discrete logarithm* of an element $z$ with  respect to a root $r$ is
##  the smallest nonnegative integer $i$ such that $r^i = z$.
##  
DeclareOperation( "LogFFE", [ IsFFE, IsFFE ] );


#############################################################################
##
#O  IntFFE( <z> )
##
##  `IntFFE' returns the integer corresponding to the element <z>, which must
##  lie in  a finite  prime field.   That is  `IntFFE' returns  the  smallest
##  nonnegative integer <i> such that `<i> \*\ One( <z> ) = <z>'.
##  
##  The  correspondence between elements from a finite prime field of
##  characteristic <p> and the integers between $0$ and `<p>-1' is defined by
##  choosing `Z(<p>)' the element corresponding to the smallest primitive
##  root mod <p> (see~"PrimitiveRootMod").
##
##  `IntFFE' is installed as a method for the operation `Int' (see~"Int")
##  with argument a finite field element.
##
DeclareOperation( "IntFFE", [ IsFFE ] );


#############################################################################
##
#O  IntVecFFE( <vecffe> )
##
##  is the list of integers corresponding to the vector <vecffe> of finite
##  field elements in a prime field (see~"IntFFE").
##
DeclareOperation( "IntVecFFE", [ IsRowVector and IsFFECollection ] );
#T Why is the function `IntFFE' not good enough to handle also row vectors
#T and perhaps matrices of FFEs, in analogy to `DegreeFFE'?


#############################################################################
##
#E

