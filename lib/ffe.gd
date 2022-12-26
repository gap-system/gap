#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel, Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares operations for `FFE's.
##


#############################################################################
##
##  <#GAPDoc Label="Z">
##  <ManSection>
##  <Func Name="Z" Arg='p^d' Label="for field size"/>
##  <Func Name="Z" Arg='p, d' Label="for prime and degree"/>
##
##  <Description>
##  For creating elements of a finite field,
##  the function <Ref Func="Z" Label="for field size"/> can be used.
##  The call <C>Z(<A>p</A>,<A>d</A>)</C>
##  (alternatively <C>Z(<A>p</A>^<A>d</A>)</C>)
##  returns the designated generator of the multiplicative group of the
##  finite field with <A>p^d</A> elements.
##  <A>p</A> must be a prime integer.
##  <P/>
##  &GAP; can represent elements of all finite fields
##  <C>GF(<A>p^d</A>)</C> such that either
##  (1) <A>p^d</A> <M>&lt;= 65536</M> (in which case an extremely efficient
##      internal representation is used);
##  (2) d = 1, (in which case, for large <A>p</A>, the field is represented
##      using the machinery of residue class rings
##      (see section&nbsp;<Ref Sect="Residue Class Rings"/>) or
##  (3) if the Conway polynomial of degree <A>d</A> over the field with
##      <A>p</A> elements is known, or can be computed
##      (see <Ref Func="ConwayPolynomial"/>).
##  <P/>
##  If you attempt to construct an element of <C>GF(<A>p^d</A>)</C> for which
##  <A>d</A> <M>> 1</M> and the relevant Conway polynomial is not known,
##  and not necessarily easy to find
##  (see <Ref Func="IsCheapConwayPolynomial"/>),
##  then &GAP; will stop with an error and enter the break loop.
##  If you leave this break loop by entering <C>return;</C>
##  &GAP; will attempt to compute the Conway polynomial,
##  which may take a very long time.
##  <P/>
##  The root returned by <Ref Func="Z" Label="for field size"/> is a
##  generator of the multiplicative group of the finite field with <A>p^d</A>
##  elements, which is cyclic.
##  The order of the element is of course <A>p^d</A> <M>-1</M>.
##  The <A>p^d</A> <M>-1</M> different powers of the root
##  are exactly the nonzero elements of the finite field.
##  <P/>
##  Thus all nonzero elements of the finite field with <A>p^d</A> elements
##  can be entered as <C>Z(<A>p^d</A>)^</C><M>i</M>.
##  Note that this is also the form that &GAP; uses to output those elements
##  when they are stored in the internal representation.
##  In larger fields, it is more convenient to enter and print elements as
##  linear combinations of powers of the primitive element, see section
##  <Ref Sect="Printing, Viewing and Displaying Finite Field Elements"/>.
##  <P/>
##  The additive neutral element is <C>0 * Z(<A>p</A>)</C>.
##  It is different from the integer <C>0</C> in subtle ways.
##  First <C>IsInt( 0 * Z(<A>p</A>)  )</C> (see <Ref Filt="IsInt"/>) is
##  <K>false</K> and <C>IsFFE( 0 * Z(<A>p</A>) )</C>
##  (see <Ref Filt="IsFFE"/>) is <K>true</K>, whereas it is
##  just the other way around for the integer <C>0</C>.
##  <P/>
##  The multiplicative neutral element is <C>Z(<A>p</A>)^0</C>.
##  It is different from the integer <C>1</C> in subtle ways.
##  First <C>IsInt( Z(<A>p</A>)^0 )</C> (see <Ref Filt="IsInt"/>)
##  is <K>false</K> and <C>IsFFE( Z(<A>p</A>)^0 )</C>
##  (see <Ref Filt="IsFFE"/>) is <K>true</K>, whereas it
##  is just the other way around for the integer <C>1</C>.
##  Also <C>1+1</C> is <C>2</C>,
##  whereas, e.g., <C>Z(2)^0 + Z(2)^0</C> is <C>0 * Z(2)</C>.
##  <P/>
##  The various roots returned by <Ref Func="Z" Label="for field size"/>
##  for finite fields of the same characteristic are compatible in the
##  following sense.
##  If the field <C>GF(<A>p</A>,</C><M>n</M><C>)</C> is a subfield of the
##  field <C>GF(<A>p</A>,</C><M>m</M><C>)</C>, i.e.,
##  <M>n</M> divides <M>m</M>,
##  then <C>Z</C><M>(<A>p</A>^n) =
##  </M><C>Z</C><M>(<A>p</A>^m)^{{(<A>p</A>^m-1)/(<A>p</A>^n-1)}}</M>.
##  Note that this is the simplest relation that may hold between a generator
##  of <C>GF(<A>p</A>,</C><M>n</M><C>)</C> and
##  <C>GF(<A>p</A>,</C><M>m</M><C>)</C>,
##  since <C>Z</C><M>(<A>p</A>^n)</M> is an element of order
##  <M><A>p</A>^m-1</M> and <C>Z</C><M>(<A>p</A>^m)</M> is an element
##  of order <M><A>p</A>^n-1</M>.
##  This is achieved  by choosing <C>Z(<A>p</A>)</C> as the smallest
##  primitive root modulo <A>p</A> and <C>Z(</C><A>p^n</A><C>)</C> as a root
##  of the <M>n</M>-th <E>Conway polynomial</E>
##  (see&nbsp;<Ref Func="ConwayPolynomial"/>) of characteristic <A>p</A>.
##  Those polynomials were defined by J.&nbsp;H.&nbsp;Conway,
##  and many of them were computed by R.&nbsp;A.&nbsp;Parker.
##  <P/>
##  <Example><![CDATA[
##  gap> a:= Z( 32 );
##  Z(2^5)
##  gap> a+a;
##  0*Z(2)
##  gap> a*a;
##  Z(2^5)^2
##  gap> b := Z(3,12);
##  z
##  gap> b*b;
##  z2
##  gap> b+b;
##  2z
##  gap> Print(b^100,"\n");
##  Z(3)^0+Z(3,12)^5+Z(3,12)^6+2*Z(3,12)^8+Z(3,12)^10+Z(3,12)^11
##  ]]></Example>
##  <Log><![CDATA[
##  gap> Z(11,40);
##  Error, Conway Polynomial 11^40 will need to computed and might be slow
##  return to continue called from
##  FFECONWAY.ZNC( p, d ) called from
##  <function>( <arguments> ) called from read-eval-loop
##  Entering break read-eval-print loop ...
##  you can 'quit;' to quit to outer loop, or
##  you can 'return;' to continue
##  brk>
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
##  <#GAPDoc Label="[2]{ffe}">
##  Since finite field elements are scalars,
##  the operations <Ref Attr="Characteristic"/>,
##  <Ref Attr="One"/>, <Ref Attr="Zero"/>, <Ref Attr="Inverse"/>,
##  <Ref Attr="AdditiveInverse"/>, <Ref Attr="Order"/> can be applied to
##  them (see&nbsp;<Ref Sect="Attributes and Properties of Elements"/>).
##  Contrary to the situation with other scalars,
##  <Ref Attr="Order"/> is defined also for the zero element
##  in a finite field, with value <C>0</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> Characteristic( Z( 16 )^10 );  Characteristic( Z( 9 )^2 );
##  2
##  3
##  gap> Characteristic( [ Z(4), Z(8) ] );
##  2
##  gap> One( Z(9) );  One( 0*Z(4) );
##  Z(3)^0
##  Z(2)^0
##  gap> Inverse( Z(9) );  AdditiveInverse( Z(9) );
##  Z(3^2)^7
##  Z(3^2)^5
##  gap> Order( Z(9)^7 );
##  8
##  ]]></Example>
##  <#/GAPDoc>
##


#############################################################################
##
##  <#GAPDoc Label="DefaultField:ffe">
##  <ManSection>
##  <Func Name="DefaultField" Arg='list' Label="for finite field elements"/>
##  <Func Name="DefaultRing" Arg='list' Label="for finite field elements"/>
##
##  <Description>
##  <Ref Func="DefaultField" Label="for finite field elements"/> and
##  <Ref Func="DefaultRing" Label="for finite field elements"/>
##  for finite field elements are defined to return the <E>smallest</E> field
##  containing the given elements.
##  <P/>
##  <Example><![CDATA[
##  gap> DefaultField( [ Z(4), Z(4)^2 ] );  DefaultField( [ Z(4), Z(8) ] );
##  GF(2^2)
##  GF(2^6)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsFFE(<obj>)
#C  IsFFECollection(<obj>)
#C  IsFFECollColl(<obj>)
##
##  <#GAPDoc Label="IsFFE">
##  <ManSection>
##  <Filt Name="IsFFE" Arg='obj' Type='Category'/>
##  <Filt Name="IsFFECollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsFFECollColl" Arg='obj' Type='Category'/>
##  <Filt Name="IsFFECollCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  Objects in the category <Ref Filt="IsFFE"/> are used to implement
##  elements of finite fields.
##  In this manual, the term <E>finite field element</E> always means an
##  object in <Ref Filt="IsFFE"/>.
##  All finite field elements of the same characteristic form a family in
##  &GAP; (see&nbsp;<Ref Sect="Families"/>).
##  Any collection of finite field elements of the same characteristic
##  (see&nbsp;<Ref Filt="IsCollection"/>) lies in
##  <Ref Filt="IsFFECollection"/>, and a collection of such collections
##  (e.g., a matrix of finite field elements) lies in
##  <Ref Filt="IsFFECollColl"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
#C  IsLexOrderedFFE(<ffe>)
#C  IsLogOrderedFFE(<ffe>)
##
##  <#GAPDoc Label="IsLexOrderedFFE">
##  <ManSection>
##  <Filt Name="IsLexOrderedFFE" Arg='ffe' Type='Category'/>
##  <Filt Name="IsLogOrderedFFE" Arg='ffe' Type='Category'/>
##
##  <Description>
##  Elements of finite fields can be compared using the operators <C>=</C>
##  and <C>&lt;</C>.
##  The call <C><A>a</A> = <A>b</A></C> returns <K>true</K> if and only if
##  the finite field elements <A>a</A> and <A>b</A> are equal.
##  Furthermore <C><A>a</A> &lt; <A>b</A></C> tests whether <A>a</A> is
##  smaller than <A>b</A>.
##  The exact behaviour of this comparison depends on which of two categories
##  the field elements belong to:
##  <P/>
##  Finite field elements are ordered in &GAP; (by <Ref Oper="\&lt;"/>)
##  first by characteristic and then by their degree
##  (i.e. the sizes of the smallest fields containing them).
##  Amongst irreducible elements of a given field, the ordering
##  depends on which of these categories the elements of the field belong to
##  (all irreducible elements of a given field should belong to the same one)
##  <P/>
##  Elements in <Ref Filt="IsLexOrderedFFE"/> are ordered lexicographically
##  by their coefficients with respect to the canonical basis of the field.
##  <P/>
##  Elements in <Ref Filt="IsLogOrderedFFE"/> are ordered according to their
##  discrete logarithms with respect to the <Ref Attr="PrimitiveElement"/>
##  attribute of the field.
##  For the comparison of finite field elements with other &GAP; objects,
##  see&nbsp;<Ref Sect="Comparisons"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> Z( 16 )^10 = Z( 4 )^2;  # illustrates embedding of GF(4) in GF(16)
##  true
##  gap> 0 < 0*Z(101);
##  true
##  gap> Z(256) > Z(101);
##  false
##  gap> Z(2,20) < Z(2,20)^2; # this illustrates the lexicographic ordering
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsLexOrderedFFE", IsFFE);
DeclareCategory("IsLogOrderedFFE", IsFFE);
InstallTrueMethod(IsLogOrderedFFE, IsFFE and IsInternalRep);


#############################################################################
##
#C  IsFFEFamily
##
##  <ManSection>
##  <Filt Name="IsFFEFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Var Name="FAMS_FFE_LARGE"/>
##
##  <Description>
##  At position 1 the ordered list of characteristics is stored,
##  at position 2 the families of field elements of these characteristics.
##  <P/>
##  Known families of FFE in characteristic at most <C>MAXSIZE_GF_INTERNAL</C>
##  are stored via the types in the list <C>TYPE_FFE</C>, the default type of
##  elements in characteristic <M>p</M> at position <M>p</M>.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "FAMS_FFE_LARGE", NEW_SORTED_CACHE(false) );


#############################################################################
##
#V  GALOIS_FIELDS
##
##  <ManSection>
##  <Var Name="GALOIS_FIELDS"/>
##
##  <Description>
##  global cache of finite fields <C>GF( <A>p</A>^<A>d</A> )</C> whose order
##  satisfies <M>p^d < MAXSIZE_GF_INTERNAL</M>.  Larger fields are stored in
##  the FFEFamily of the appropriate characteristic.
##
##  <C>GALOIS_FIELDS</C> contains a pair of lists; the first being a sorted
##  list of field sizes, the second a list of fields. The field of size
##  <M>p^d</M> is stored in <C>GALOIS_FIELDS[2][pos]</C>, if and only if
##  <C>GALOIS_FIELDS[1][pos]</C> is equal to <M>p^d</M>.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "GALOIS_FIELDS", NEW_SORTED_CACHE(true) );


#############################################################################
##
#O  LargeGaloisField( <p>^<n> )
#O  LargeGaloisField( <p>, <n> )
##
##  <ManSection>
##  <Oper Name="LargeGaloisField" Arg='p^n'/>
##  <Oper Name="LargeGaloisField" Arg='p, n'/>
##
##  <Description>
##  Ideally these would be declared for IsPosInt, but this
##  causes problems with reading order.
##  <P/>
##  <!-- other construction possibilities?-->
##  </Description>
##  </ManSection>
##
DeclareOperation( "LargeGaloisField", [IS_INT] );
DeclareOperation( "LargeGaloisField", [IS_INT, IS_INT] );

#############################################################################
##
#F  GaloisField( <p>^<d> )  . . . . . . . . . .  create a finite field object
#F  GF( <p>^<d> )
#F  GaloisField( <p>, <d> )
#F  GF( <p>, <d> )
#F  GaloisField( <subfield>, <d> )
#F  GF( <subfield>, <d> )
#F  GaloisField( <p>, <pol> )
#F  GF( <p>, <pol> )
#F  GaloisField( <subfield>, <pol> )
#F  GF( <subfield>, <pol> )
##
##  <#GAPDoc Label="GaloisField">
##  <ManSection>
##  <Func Name="GaloisField" Arg='p^d' Label="for field size"/>
##  <Func Name="GF" Arg='p^d' Label="for field size"/>
##  <Func Name="GaloisField" Arg='p, d'
##   Label="for characteristic and degree"/>
##  <Func Name="GF" Arg='p, d' Label="for characteristic and degree"/>
##  <Func Name="GaloisField" Arg='subfield, d'
##   Label="for subfield and degree"/>
##  <Func Name="GF" Arg='subfield, d' Label="for subfield and degree"/>
##  <Func Name="GaloisField" Arg='p, pol'
##   Label="for characteristic and polynomial"/>
##  <Func Name="GF" Arg='p, pol' Label="for characteristic and polynomial"/>
##  <Func Name="GaloisField" Arg='subfield, pol'
##   Label="for subfield and polynomial"/>
##  <Func Name="GF" Arg='subfield, pol' Label="for subfield and polynomial"/>
##
##  <Description>
##  <Ref Func="GaloisField" Label="for field size"/> returns a finite field.
##  It takes two arguments.
##  The form <C>GaloisField( <A>p</A>, <A>d</A> )</C>,
##  where <A>p</A>, <A>d</A> are integers,
##  can also be given as <C>GaloisField( <A>p</A>^<A>d</A> )</C>.
##  <Ref Func="GF" Label="for field size"/> is an abbreviation for
##  <Ref Func="GaloisField" Label="for field size"/>.
##  <P/>
##  The first argument specifies the subfield <M>S</M> over which the new
##  field is to be taken.
##  It can be a prime integer or a finite field.
##  If it is a prime <A>p</A>, the subfield is the prime field of this
##  characteristic.
##  <P/>
##  The second argument specifies the extension.
##  It can be an integer or an irreducible polynomial over the field
##  <M>S</M>.
##  If it is an integer <A>d</A>, the new field is constructed as the
##  polynomial extension w.r.t. the Conway polynomial
##  (see&nbsp;<Ref Func="ConwayPolynomial"/>)
##  of degree <A>d</A> over <M>S</M>.
##  If it is an irreducible polynomial <A>pol</A> over <M>S</M>,
##  the new field is constructed as polynomial extension of <M>S</M>
##  with this polynomial;
##  in this case, <A>pol</A> is accessible as the value of
##  <Ref Attr="DefiningPolynomial"/> for the new field,
##  and a root of <A>pol</A> in the new field is accessible as the value of
##  <Ref Attr="RootOfDefiningPolynomial"/>.
##  <P/>
##  Note that the subfield over which a field was constructed determines over
##  which  field  the  Galois  group,  conjugates,   norm,   trace,   minimal
##  polynomial, and trace polynomial are  computed
##  (see&nbsp;<Ref Attr="GaloisGroup" Label="of field"/>,
##  <Ref Attr="Conjugates"/>, <Ref Attr="Norm"/>,
##  <Ref Attr="Trace" Label="for a field element"/>,
##  <Ref Oper="MinimalPolynomial" Label="over a field"/>,
##  <Ref Oper="TracePolynomial"/>).
##  <P/>
##  The field is regarded as a vector space
##  (see&nbsp;<Ref Chap="Vector Spaces"/>) over the given subfield,
##  so this determines the dimension and the canonical basis of the field.
##  <P/>
##  <Example><![CDATA[
##  gap> f1:= GF( 2^4 );
##  GF(2^4)
##  gap> Size( GaloisGroup ( f1 ) );
##  4
##  gap> BasisVectors( Basis( f1 ) );
##  [ Z(2)^0, Z(2^4), Z(2^4)^2, Z(2^4)^3 ]
##  gap> f2:= GF( GF(4), 2 );
##  AsField( GF(2^2), GF(2^4) )
##  gap> Size( GaloisGroup( f2 ) );
##  2
##  gap> BasisVectors( Basis( f2 ) );
##  [ Z(2)^0, Z(2^4) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GaloisField" );

DeclareSynonym( "FiniteField", GaloisField );
DeclareSynonym( "GF", GaloisField );


#############################################################################
##
#A  DegreeFFE( <z> )
#A  DegreeFFE( <vec> )
#A  DegreeFFE( <mat> )
##
##  <#GAPDoc Label="DegreeFFE">
##  <ManSection>
##  <Attr Name="DegreeFFE" Arg='z' Label="for a FFE"/>
##  <Meth Name="DegreeFFE" Arg='vec' Label="for a vector of FFEs"/>
##  <Meth Name="DegreeFFE" Arg='mat' Label="for a matrix of FFEs"/>
##
##  <Description>
##  <Ref Attr="DegreeFFE" Label="for a FFE"/> returns the degree of the
##  smallest finite field <A>F</A> containing the element <A>z</A>,
##  respectively all elements of the row vector <A>vec</A> over a finite
##  field (see&nbsp;<Ref Chap="Row Vectors"/>),
##  or the matrix <A>mat</A> over a finite field
##  (see&nbsp;<Ref Chap="Matrices"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> DegreeFFE( Z( 16 )^10 );
##  2
##  gap> DegreeFFE( Z( 16 )^11 );
##  4
##  gap> DegreeFFE( [ Z(2^13), Z(2^10) ] );
##  130
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DegreeFFE", IsFFE  );


#############################################################################
##
#O  LogFFE( <z>, <r> )
##
##  <#GAPDoc Label="LogFFE">
##  <ManSection>
##  <Oper Name="LogFFE" Arg='z, r'/>
##
##  <Description>
##  <Ref Oper="LogFFE"/> returns the discrete logarithm of the element
##  <A>z</A> in a finite field with respect to the root <A>r</A>.
##  An error is signalled if <A>z</A> is zero.
##  <K>fail</K> is returned if <A>z</A> is not a power of <A>r</A>.
##  <P/>
##  The <E>discrete logarithm</E> of the element <A>z</A> with respect to
##  the root <A>r</A> is the smallest nonnegative integer <M>i</M> such that
##  <M><A>r</A>^i = <A>z</A></M> holds.
##  <P/>
##  <Example><![CDATA[
##  gap> LogFFE( Z(409)^116, Z(409) );  LogFFE( Z(409)^116, Z(409)^2 );
##  116
##  58
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LogFFE", [ IsFFE, IsFFE ] );


#############################################################################
##
#A  IntFFE( <z> )
##
##  <#GAPDoc Label="IntFFE">
##  <ManSection>
##  <Attr Name="IntFFE" Arg='z'/>
##  <Meth Name="Int" Arg='z' Label="for a FFE"/>
##
##  <Description>
##  <Ref Attr="IntFFE"/> returns the integer corresponding to the element
##  <A>z</A>, which must lie in a finite prime field.
##  That is, <Ref Attr="IntFFE"/> returns the smallest nonnegative integer
##  <M>i</M> such that <M>i</M><C> * One( </C><A>z</A><C> ) = </C><A>z</A>.
##  <P/>
##  The  correspondence between elements from a finite prime field of
##  characteristic <M>p</M> (for <M>p &lt; 2^{16}</M>) and the integers
##  between <M>0</M> and <M>p-1</M> is defined by
##  choosing <C>Z(</C><M>p</M><C>)</C> the element corresponding to the
##  smallest primitive root mod <M>p</M>
##  (see&nbsp;<Ref Func="PrimitiveRootMod"/>).
##  <P/>
##  <Ref Attr="IntFFE"/> is installed as a method for the operation
##  <Ref Attr="Int"/> with argument a finite field element.
##  <P/>
##  <Example><![CDATA[
##  gap> IntFFE( Z(13) );  PrimitiveRootMod( 13 );
##  2
##  2
##  gap> IntFFE( Z(409) );
##  21
##  gap> IntFFE( Z(409)^116 );  21^116 mod 409;
##  311
##  311
##  ]]></Example>
##
##  See also <Ref Attr="IntFFESymm" Label="for a FFE"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IntFFE", IsFFE  );


#############################################################################
##
#A  IntFFESymm( <z> )
#A  IntFFESymm( <vec> )
##
##  <#GAPDoc Label="IntFFESymm">
##  <ManSection>
##  <Attr Name="IntFFESymm" Arg='z' Label="for a FFE"/>
##  <Attr Name="IntFFESymm" Arg='vec' Label="for a vector of FFEs"/>
##
##  <Description>
##  For a finite prime field element <A>z</A>,
##  <Ref Attr="IntFFESymm" Label="for a FFE"/> returns the corresponding
##  integer of smallest absolute value.
##  That is, <Ref Attr="IntFFESymm" Label="for a FFE"/> returns the integer
##  <M>i</M> of smallest absolute value such that
##  <M>i</M><C> * One( </C><A>z</A><C> ) = </C><A>z</A> holds.
##  <P/>
##  For a vector <A>vec</A> of FFEs, the operation returns the result of
##  applying <Ref Attr="IntFFESymm" Label="for a vector of FFEs"/>
##  to every entry of the vector.
##  <P/>
##  The  correspondence between elements from a finite prime field of
##  characteristic <M>p</M> (for <M>p &lt; 2^{16}</M>) and the integers
##  between <M>-p/2</M> and <M>p/2</M> is defined by
##  choosing <C>Z(</C><M>p</M><C>)</C> the element corresponding to the
##  smallest positive primitive root mod <M>p</M>
##  (see&nbsp;<Ref Func="PrimitiveRootMod"/>) and reducing results to the
##  <M>-p/2 .. p/2</M> range.
##  <P/>
##  <Example><![CDATA[
##  gap> IntFFE(Z(13)^2);IntFFE(Z(13)^3);
##  4
##  8
##  gap> IntFFESymm(Z(13)^2);IntFFESymm(Z(13)^3);
##  4
##  -5
##  ]]></Example>
##
##  See also <Ref Attr="IntFFE"/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IntFFESymm", IsFFE  );

#############################################################################
##
#O  IntVecFFE( <vecffe> )
##
##  <#GAPDoc Label="IntVecFFE">
##  <ManSection>
##  <Oper Name="IntVecFFE" Arg='vecffe'/>
##
##  <Description>
##  is the list of integers corresponding to the vector <A>vecffe</A> of
##  finite field elements in a prime field (see&nbsp;<Ref Attr="IntFFE"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IntVecFFE", [ IsRowVector and IsFFECollection ] );
#T Why is the function `IntFFE' not good enough to handle also row vectors
#T and perhaps matrices of FFEs, in analogy to `DegreeFFE'?


#############################################################################
##
#A  AsInternalFFE( <ffe> )
##
##  <#GAPDoc Label="AsInternalFFE">
##  <ManSection>
##  <Attr Name="AsInternalFFE" Arg='ffe'/>
##
## <Description>
## return an internal FFE equal to <A>ffe</A> if one exists, otherwise <C>fail</C>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsInternalFFE", IsFFE);


#############################################################################
##
#O  RootFFE( <z>, <k> )
##
##  <#GAPDoc Label="RootFFE">
##  <ManSection>
##  <Oper Name="RootFFE" Arg='F, z, k'/>
##
##  <Description>
##  <Ref Oper="RootFFE"/> returns a finite field element
##  <A>r</A> from <A>F</A> whose <A>k</A>-th power is <A>z</A>.
##  If no such element exists
##  then
##  <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RootFFE", [ IsObject, IsFFE, IsObject ] );
