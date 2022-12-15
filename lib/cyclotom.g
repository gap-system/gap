#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with cyclotomics.
##


#############################################################################
##
#C  IsCyclotomic( <obj> ) . . . . . . . . . . . . category of all cyclotomics
#C  IsCyc( <obj> )
##
##  <#GAPDoc Label="IsCyclotomic">
##  <ManSection>
##  <Filt Name="IsCyclotomic" Arg='obj' Type='Category'/>
##  <Filt Name="IsCyc" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Index Key="CyclotomicsFamily"><C>CyclotomicsFamily</C></Index>
##  Every object in the family <C>CyclotomicsFamily</C> lies in the category
##  <Ref Filt="IsCyclotomic"/>.
##  This covers integers, rationals, proper cyclotomics, the object
##  <Ref Var="infinity"/>,
##  and unknowns (see Chapter&nbsp;<Ref Chap="Unknowns"/>).
##  All these objects except <Ref Var="infinity"/> and unknowns
##  lie also in the category <Ref Filt="IsCyc"/>,
##  <Ref Var="infinity"/> lies in (and can be detected from) the category
##  <Ref Filt="IsInfinity"/>,
##  and unknowns lie in <Ref Filt="IsUnknown"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> IsCyclotomic(0); IsCyclotomic(1/2*E(3)); IsCyclotomic( infinity );
##  true
##  true
##  true
##  gap> IsCyc(0); IsCyc(1/2*E(3)); IsCyc( infinity );
##  true
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsCyclotomic",
    IsScalar and IsAssociativeElement and IsCommutativeElement
    and IsAdditivelyCommutativeElement and IsZDFRE);

DeclareCategoryKernel( "IsCyc", IsCyclotomic, IS_CYC );


#############################################################################
##
#C  IsCyclotomicCollection  . . . . . . category of collection of cyclotomics
#C  IsCyclotomicCollColl  . . . . . . .  category of collection of collection
#C  IsCyclotomicCollCollColl  . . . .  category of collection of coll of coll
##
##  <ManSection>
##  <Filt Name="IsCyclotomicCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsCyclotomicCollColl" Arg='obj' Type='Category'/>
##  <Filt Name="IsCyclotomicCollCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryCollections( "IsCyclotomic" );
DeclareCategoryCollections( "IsCyclotomicCollection" );
DeclareCategoryCollections( "IsCyclotomicCollColl" );


#############################################################################
##
#C  IsRat( <obj> )
##
##  <#GAPDoc Label="IsRat">
##  <ManSection>
##  <Filt Name="IsRat" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Index Subkey="for a rational">test</Index>
##  Every rational number lies in the category <Ref Filt="IsRat"/>,
##  which is a subcategory of <Ref Filt="IsCyc"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> IsRat( 2/3 );
##  true
##  gap> IsRat( 17/-13 );
##  true
##  gap> IsRat( 11 );
##  true
##  gap> IsRat( IsRat );  # `IsRat' is a function, not a rational
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsRat", IsCyc, IS_RAT );


#############################################################################
##
#C  IsInt( <obj> )
##
##  <#GAPDoc Label="IsInt">
##  <ManSection>
##  <Filt Name="IsInt" Arg='obj' Type='Category'/>
##
##  <Description>
##  Every rational integer lies in the category <Ref Filt="IsInt"/>,
##  which is a subcategory of <Ref Filt="IsRat"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsInt", IsRat, IS_INT );


#############################################################################
##
#C  IsPosRat( <obj> )
##
##  <#GAPDoc Label="IsPosRat">
##  <ManSection>
##  <Filt Name="IsPosRat" Arg='obj' Type='Category'/>
##
##  <Description>
##  Every positive rational number lies in the category
##  <Ref Filt="IsPosRat"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsPosRat", IsRat );


#############################################################################
##
#C  IsPosInt( <obj> )
##
##  <#GAPDoc Label="IsPosInt">
##  <ManSection>
##  <Filt Name="IsPosInt" Arg='obj' Type='Category'/>
##
##  <Description>
##  Every positive integer lies in the category <Ref Filt="IsPosInt"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsPosInt", IsInt and IsPosRat );


#############################################################################
##
#C  IsNegRat( <obj> )
##
##  <#GAPDoc Label="IsNegRat">
##  <ManSection>
##  <Filt Name="IsNegRat" Arg='obj' Type='Category'/>
##
##  <Description>
##  Every negative rational number lies in the category
##  <Ref Filt="IsNegRat"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsNegRat", IsRat );


#############################################################################
##
#C  IsNegInt( <obj> )
##
##  <ManSection>
##  <Filt Name="IsNegInt" Arg='obj' Type='Category'/>
##
##  <Description>
##  Every negative integer lies in the category <Ref Func="IsNegInt"/>.
##  </Description>
##  </ManSection>
##
DeclareSynonym( "IsNegInt", IsInt and IsNegRat );


#############################################################################
##
#C  IsZeroCyc( <obj> )
##
##  <ManSection>
##  <Filt Name="IsZeroCyc" Arg='obj' Type='Category'/>
##
##  <Description>
##  Only the zero <C>0</C> of the cyclotomics lies in the category
##  <Ref Func="IsZeroCyc"/>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsZeroCyc", IsInt and IsZero );


#############################################################################
##
#V  CyclotomicsFamily . . . . . . . . . . . . . . . . . family of cyclotomics
##
##  <ManSection>
##  <Var Name="CyclotomicsFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "CyclotomicsFamily",
    NewFamily( "CyclotomicsFamily",
    IsCyclotomic,CanEasilySortElements,
    CanEasilySortElements ) );

#############################################################################
##
#R  IsSmallIntRep . . . . . . . . . . . . . . . . . .  small internal integer
##
##  <ManSection>
##  <Filt Name="IsSmallIntRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsSmallIntRep", IsInternalRep );


#############################################################################
##
#V  TYPE_INT_SMALL_ZERO . . . . . . . . . . . . . . type of the internal zero
##
##  <ManSection>
##  <Var Name="TYPE_INT_SMALL_ZERO"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_INT_SMALL_ZERO", NewType( CyclotomicsFamily,
                            IsInt and IsZeroCyc and IsSmallIntRep ) );


#############################################################################
##
#V  TYPE_INT_SMALL_NEG  . . . . . . type of a small negative internal integer
##
##  <ManSection>
##  <Var Name="TYPE_INT_SMALL_NEG"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_INT_SMALL_NEG", NewType( CyclotomicsFamily,
                            IsInt and IsNegRat and IsSmallIntRep ) );


#############################################################################
##
#V  TYPE_INT_SMALL_POS  . . . . . . type of a small positive internal integer
##
##  <ManSection>
##  <Var Name="TYPE_INT_SMALL_POS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_INT_SMALL_POS", NewType( CyclotomicsFamily,
                            IsPosInt and IsSmallIntRep ) );


#############################################################################
##
#V  TYPE_INT_LARGE_NEG  . . . . . . type of a large negative internal integer
##
##  <ManSection>
##  <Var Name="TYPE_INT_LARGE_NEG"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_INT_LARGE_NEG", NewType( CyclotomicsFamily,
                            IsInt and IsNegRat and IsInternalRep ) );


#############################################################################
##
#V  TYPE_INT_LARGE_POS  . . . . . . type of a large positive internal integer
##
##  <ManSection>
##  <Var Name="TYPE_INT_LARGE_POS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_INT_LARGE_POS", NewType( CyclotomicsFamily,
                            IsPosInt and IsInternalRep ) );


#############################################################################
##
#V  TYPE_RAT_NEG  . . . . . . . . . . .  type of a negative internal rational
##
##  <ManSection>
##  <Var Name="TYPE_RAT_NEG"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_RAT_NEG", NewType( CyclotomicsFamily,
                            IsRat and IsNegRat and IsInternalRep ) );


#############################################################################
##
#V  TYPE_RAT_POS  . . . . . . . . . . .  type of a positive internal rational
##
##  <ManSection>
##  <Var Name="TYPE_RAT_POS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_RAT_POS", NewType( CyclotomicsFamily,
                            IsRat and IsPosRat and IsInternalRep ) );

#############################################################################
##
#V  TYPE_CYC  . . . . . . . . . . . . . . . . type of an internal cyclotomics
##
##  <ManSection>
##  <Var Name="TYPE_CYC"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_CYC",
    NewType( CyclotomicsFamily, IsCyc and IsInternalRep ) );


#############################################################################
##
#v  One( CyclotomicsFamily )
#v  Zero( CyclotomicsFamily )
#v  Characteristic( CyclotomicsFamily )
##
SetOne( CyclotomicsFamily, 1 );
SetZero( CyclotomicsFamily, 0 );
SetCharacteristic( CyclotomicsFamily, 0 );


#############################################################################
##
#v  IsUFDFamily( CyclotomicsFamily )
##
SetIsUFDFamily( CyclotomicsFamily, true );


#############################################################################
##
#F  E( <n> )
##
##  <#GAPDoc Label="E">
##  <ManSection>
##  <Oper Name="E" Arg='n'/>
##
##  <Description>
##  <Index>roots of unity</Index>
##  <Ref Oper="E"/> returns the primitive <A>n</A>-th root of unity
##  <M>e_n = \exp(2\pi i/n)</M>.
##  Cyclotomics are usually entered as sums of roots of unity,
##  with rational coefficients,
##  and irrational cyclotomics are displayed in such a way.
##  (For special cyclotomics, see&nbsp;<Ref Sect="ATLAS Irrationalities"/>.)
##  <P/>
##  <Example><![CDATA[
##  gap> E(9); E(9)^3; E(6); E(12) / 3;
##  -E(9)^4-E(9)^7
##  E(3)
##  -E(3)^2
##  -1/3*E(12)^7
##  ]]></Example>
##  <P/>
##  A particular basis is used to express cyclotomics,
##  see&nbsp;<Ref Sect="Integral Bases of Abelian Number Fields"/>;
##  note that <C>E(9)</C> is <E>not</E> a basis element,
##  as the above example shows.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsInfinity( <obj> ) . . . . . . . . . . . . . . . .  category of infinity
#V  infinity  . . . . . . . . . . . . . . . . . . . . . .  the value infinity
#C  IsNegInfinity( <obj> ) . . . . . . . . . .  category of negative infinity
#V  -infinity . . . . . . . . . . . . . . . . . . . . . . the value -infinity
##  <#GAPDoc Label="IsInfinity">
##  <ManSection>
##  <Filt Name="IsInfinity" Arg='obj' Type='Category'/>
##  <Filt Name="IsNegInfinity" Arg='obj' Type='Category'/>
##  <Var Name="infinity"/>
##  <Var Name="-infinity"/>
##
##  <Description>
##  <Ref Var="infinity"/> and <Ref Var="-infinity"/> are special &GAP; objects
##  that lie in <C>CyclotomicsFamily</C>.
##  They are larger or smaller than all other objects in this family
##  respectively.
##  <Ref Var="infinity"/> is mainly used as return value of operations such
##  as <Ref Attr="Size"/>
##  and <Ref Attr="Dimension"/> for infinite and infinite dimensional domains,
##  respectively.
##  <P/>
##  Some arithmetic operations are provided for convenience when using
##  <Ref Var="infinity"/> and <Ref Var="-infinity"/> as top and bottom element
##  respectively.
##  <Example><![CDATA[
##  gap> -infinity + 1;
##  -infinity
##  gap> infinity + infinity;
##  infinity
##  ]]></Example>
##  Often it is useful to distinguish <Ref Var="infinity"/>
##  from <Q>proper</Q> cyclotomics.
##  For that, <Ref Var="infinity"/> lies in the category
##  <Ref Filt="IsInfinity"/> but not in <Ref Filt="IsCyc"/>,
##  and the other cyclotomics lie in the category <Ref Filt="IsCyc"/> but not
##  in <Ref Filt="IsInfinity"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> s:= Size( Rationals );
##  infinity
##  gap> s = infinity; IsCyclotomic( s ); IsCyc( s ); IsInfinity( s );
##  true
##  true
##  false
##  true
##  gap> s in Rationals; s > 17;
##  false
##  true
##  gap> Set( [ s, 2, s, E(17), s, 19 ] );
##  [ 2, 19, E(17), infinity ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsInfinity", IsCyclotomic );

UNBIND_GLOBAL( "infinity" );
BIND_GLOBAL( "infinity",
    Objectify( NewType( CyclotomicsFamily, IsInfinity
                        and IsPositionalObjectRep ), [] ) );
if IsHPCGAP then
    MakeReadOnlyObj(infinity);
fi;

InstallMethod( PrintObj,
    "for infinity",
    [ IsInfinity ], function( obj ) Print( "infinity" ); end );

InstallMethod( \=,
    "for cyclotomic and `infinity'",
    IsIdenticalObj, [ IsCyclotomic, IsInfinity ], ReturnFalse );

InstallMethod( \=,
    "for `infinity' and cyclotomic",
    IsIdenticalObj, [ IsInfinity, IsCyclotomic ], ReturnFalse );

InstallMethod( \<,
    "for cyclotomic and `infinity'",
    IsIdenticalObj, [ IsCyclotomic, IsInfinity ], ReturnTrue );

InstallMethod( \<,
    "for `infinity' and cyclotomic",
    IsIdenticalObj, [ IsInfinity, IsCyclotomic ], ReturnFalse );


DeclareCategory( "IsNegInfinity", IsCyclotomic );

BIND_GLOBAL( "Ninfinity",
    Objectify( NewType( CyclotomicsFamily, IsNegInfinity
                        and IsPositionalObjectRep ), [] ) );
if IsHPCGAP then
    MakeReadOnlyObj(Ninfinity);
fi;

InstallMethod( PrintObj,
    "for -infinity",
    [ IsNegInfinity ], function( obj ) Print( "-infinity" ); end );

InstallMethod( \=,
    "for cyclotomic and `-infinity'",
    IsIdenticalObj, [ IsCyclotomic, IsNegInfinity ], ReturnFalse );

InstallMethod( \=,
    "for `-infinity' and cyclotomic",
    IsIdenticalObj, [ IsNegInfinity, IsCyclotomic ], ReturnFalse );

InstallMethod( \<,
    "for cyclotomic and `-infinity'",
    IsIdenticalObj, [ IsCyclotomic, IsNegInfinity ], ReturnFalse );

InstallMethod( \<,
    "for `-infinity' and cyclotomic",
    IsIdenticalObj, [ IsNegInfinity, IsCyclotomic ], ReturnTrue );


InstallMethod( AdditiveInverseOp,
    "for `infinity'",
    [ IsInfinity ], x -> Ninfinity  );

InstallMethod( AdditiveInverseOp,
    "for `-infinity'",
    [ IsNegInfinity ], x -> infinity  );

InstallMethod( \+,
    "for `infinity' and cyclotomic",
    IsIdenticalObj, [ IsInfinity, IsCyc ], function(x,y) return infinity; end );

InstallMethod( \+,
    "for cyclotomic and `infinity'",
    IsIdenticalObj, [ IsCyc, IsInfinity ], function(x,y) return infinity; end );

InstallMethod( \+,
    "for `infinity' and `infinity'",
    IsIdenticalObj, [ IsInfinity, IsInfinity ], function(x,y) return infinity; end );

InstallMethod( \+,
    "for `-infinity' and cyclotomic",
    IsIdenticalObj, [ IsNegInfinity, IsCyc ], function(x,y) return -infinity; end );

InstallMethod( \+,
    "for cyclotomic and `-infinity'",
    IsIdenticalObj, [ IsCyc, IsNegInfinity ], function(x,y) return -infinity; end );

InstallMethod( \+,
    "for `-infinity' and `-infinity'",
    IsIdenticalObj, [ IsNegInfinity, IsNegInfinity ], function(x,y) return -infinity; end );


#############################################################################
##
#P  IsIntegralCyclotomic( <obj> ) . . . . . . . . . . .  integral cyclotomics
##
##  <#GAPDoc Label="IsIntegralCyclotomic">
##  <ManSection>
##  <Prop Name="IsIntegralCyclotomic" Arg='obj'/>
##
##  <Description>
##  A cyclotomic is called <E>integral</E> or a <E>cyclotomic integer</E>
##  if all coefficients of its minimal polynomial over the rationals are
##  integers.
##  Since the underlying basis of the external representation of cyclotomics
##  is an integral basis
##  (see&nbsp;<Ref Sect="Integral Bases of Abelian Number Fields"/>),
##  the subring of cyclotomic integers in a cyclotomic field is formed
##  by those cyclotomics for which the external representation is a list of
##  integers.
##  For example, square roots of integers are cyclotomic integers
##  (see&nbsp;<Ref Sect="ATLAS Irrationalities"/>),
##  any root of unity is a cyclotomic integer,
##  character values are always cyclotomic integers,
##  but all rationals which are not integers are not cyclotomic integers.
##  <P/>
##  <Example><![CDATA[
##  gap> r:= ER( 5 );               # The square root of 5 ...
##  E(5)-E(5)^2-E(5)^3+E(5)^4
##  gap> IsIntegralCyclotomic( r ); # ... is a cyclotomic integer.
##  true
##  gap> r2:= 1/2 * r;              # This is not a cyclotomic integer, ...
##  1/2*E(5)-1/2*E(5)^2-1/2*E(5)^3+1/2*E(5)^4
##  gap> IsIntegralCyclotomic( r2 );
##  false
##  gap> r3:= 1/2 * r - 1/2;        # ... but this is one.
##  E(5)+E(5)^4
##  gap> IsIntegralCyclotomic( r3 );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsIntegralCyclotomic", IsObject );

DeclareSynonymAttr( "IsCycInt", IsIntegralCyclotomic );

InstallMethod( IsIntegralCyclotomic,
    "for an internally represented cyclotomic",
    [ IsInternalRep ],
    IS_CYC_INT );


#############################################################################
##
#A  Conductor( <cyc> )  . . . . . . . . . . . . . . . . . .  for a cyclotomic
#A  Conductor( <C> )  . . . . . . . . . . . . for a collection of cyclotomics
##
##  <#GAPDoc Label="Conductor">
##  <ManSection>
##  <Attr Name="Conductor" Arg='cyc' Label="for a cyclotomic"/>
##  <Attr Name="Conductor" Arg='C' Label="for a collection of cyclotomics"/>
##
##  <Description>
##  For an element <A>cyc</A> of a cyclotomic field,
##  <Ref Attr="Conductor" Label="for a cyclotomic"/>
##  returns the smallest integer <M>n</M> such that <A>cyc</A> is contained
##  in the <M>n</M>-th cyclotomic field.
##  For a collection <A>C</A> of cyclotomics (for example a dense list of
##  cyclotomics or a field of cyclotomics),
##  <Ref Attr="Conductor" Label="for a collection of cyclotomics"/> returns
##  the smallest integer <M>n</M> such that all elements of <A>C</A>
##  are contained in the <M>n</M>-th cyclotomic field.
##  <P/>
##  <Example><![CDATA[
##  gap> Conductor( 0 ); Conductor( E(10) ); Conductor( E(12) );
##  1
##  5
##  12
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttributeKernel( "Conductor", IsCyc, CONDUCTOR );
DeclareAttribute( "Conductor", IsCyclotomicCollection );

#T also for matrices, matrix groups etc. of cyclotomics?


#############################################################################
##
#O  GaloisCyc( <cyc>, <k> ) . . . . . . . . . . . . . . . .  Galois conjugate
#O  GaloisCyc( <list>, <k> )  . . . . . . . . . . . list of Galois conjugates
##
##  <#GAPDoc Label="GaloisCyc">
##  <ManSection>
##  <Oper Name="GaloisCyc" Arg='cyc, k' Label="for a cyclotomic"/>
##  <Oper Name="GaloisCyc" Arg='list, k' Label="for a list of cyclotomics"/>
##
##  <Description>
##  For a cyclotomic <A>cyc</A> and an integer <A>k</A>,
##  <Ref Oper="GaloisCyc" Label="for a cyclotomic"/> returns the cyclotomic
##  obtained by raising the roots of unity in the Zumbroich basis
##  representation of <A>cyc</A> to the <A>k</A>-th power.
##  If <A>k</A> is coprime to the integer <M>n</M>,
##  <C>GaloisCyc( ., <A>k</A> )</C> acts as a Galois automorphism
##  of the <M>n</M>-th cyclotomic field
##  (see&nbsp;<Ref Sect="Galois Groups of Abelian Number Fields"/>);
##  to get the Galois automorphisms themselves,
##  use <Ref Attr="GaloisGroup" Label="of field"/>.
##  <P/>
##  The <E>complex conjugate</E> of <A>cyc</A> is
##  <C>GaloisCyc( <A>cyc</A>, -1 )</C>,
##  which can also be computed using <Ref Attr="ComplexConjugate"/>.
##  <P/>
##  For a list or matrix <A>list</A> of cyclotomics,
##  <Ref Oper="GaloisCyc" Label="for a list of cyclotomics"/> returns
##  the list obtained by applying
##  <Ref Oper="GaloisCyc" Label="for a cyclotomic"/> to the entries of
##  <A>list</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "GaloisCyc", [ IsCyc, IsInt ], GALOIS_CYC );
DeclareOperation( "GaloisCyc", [ IsCyclotomicCollection, IsInt ] );
DeclareOperation( "GaloisCyc", [ IsCyclotomicCollColl, IsInt ] );

InstallMethod( GaloisCyc,
    "for a list of cyclotomics, and an integer",
    [ IsList and IsCyclotomicCollection, IsInt ],
    function( list, k )
    return List( list, entry -> GaloisCyc( entry, k ) );
    end );

InstallMethod( GaloisCyc,
    "for a list of lists of cyclotomics, and an integer",
    [ IsList and IsCyclotomicCollColl, IsInt ],
    function( list, k )
    return List( list, entry -> GaloisCyc( entry, k ) );
    end );


#############################################################################
##
#F  NumeratorRat( <rat> ) . . . . . . . . . .  numerator of internal rational
##
##  <#GAPDoc Label="NumeratorRat">
##  <ManSection>
##  <Func Name="NumeratorRat" Arg='rat'/>
##
##  <Description>
##  <Index Subkey="of a rational">numerator</Index>
##  <Ref Func="NumeratorRat"/> returns the numerator of the rational
##  <A>rat</A>.
##  Because the numerator holds the sign of the rational it may be any
##  integer.
##  Integers are rationals with denominator <M>1</M>,
##  thus <Ref Func="NumeratorRat"/> is the identity function for integers.
##  <P/>
##  <Example><![CDATA[
##  gap> NumeratorRat( 2/3 );
##  2
##  gap> # numerator and denominator are made relatively prime:
##  gap> NumeratorRat( 66/123 );
##  22
##  gap> NumeratorRat( 17/-13 );  # numerator holds the sign of the rational
##  -17
##  gap> NumeratorRat( 11 );      # integers are rationals with denominator 1
##  11
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NumeratorRat", NUMERATOR_RAT );


#############################################################################
##
#F  DenominatorRat( <rat> ) . . . . . . . .  denominator of internal rational
##
##  <#GAPDoc Label="DenominatorRat">
##  <ManSection>
##  <Func Name="DenominatorRat" Arg='rat'/>
##
##  <Description>
##  <Index Subkey="of a rational">denominator</Index>
##  <Ref Func="DenominatorRat"/> returns the denominator of the rational
##  <A>rat</A>.
##  Because the numerator holds the  sign of the rational the denominator is
##  always a positive integer.
##  Integers are rationals with the denominator 1,
##  thus <Ref Func="DenominatorRat"/> returns 1 for integers.
##  <P/>
##  <Example><![CDATA[
##  gap> DenominatorRat( 2/3 );
##  3
##  gap> # numerator and denominator are made relatively prime:
##  gap> DenominatorRat( 66/123 );
##  41
##  gap> # the denominator holds the sign of the rational:
##  gap> DenominatorRat( 17/-13 );
##  13
##  gap> DenominatorRat( 11 ); # integers are rationals with denominator 1
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DenominatorRat", DENOMINATOR_RAT );


#############################################################################
##
#F  QuoInt( <n>, <m> )  . . . . . . . . . . . . quotient of internal integers
##
##  <#GAPDoc Label="QuoInt">
##  <ManSection>
##  <Func Name="QuoInt" Arg='n, m'/>
##
##  <Description>
##  <Index>integer part of a quotient</Index>
##  <Ref Func="QuoInt"/> returns the integer part of the quotient of its
##  integer operands.
##  <P/>
##  If <A>n</A> and <A>m</A> are positive, <Ref Func="QuoInt"/> returns
##  the largest positive integer <M>q</M> such that
##  <M>q * <A>m</A> \leq <A>n</A></M>.
##  If <A>n</A> or <A>m</A> or both are negative the absolute value of the
##  integer part of the quotient is the quotient of the absolute values of
##  <A>n</A> and <A>m</A>,
##  and the sign of it is the product of the signs of <A>n</A> and <A>m</A>.
##  <P/>
##  <Ref Func="QuoInt"/> is used in a method for the general operation
##  <Ref Oper="EuclideanQuotient"/>.
##  <Example><![CDATA[
##  gap> QuoInt(5,3);  QuoInt(-5,3);  QuoInt(5,-3);  QuoInt(-5,-3);
##  1
##  -1
##  -1
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "QuoInt", QUO_INT );


#############################################################################
##
#F  RemInt( <n>, <m> )  . . . . . . . . . . .  remainder of internal integers
##
##  <#GAPDoc Label="RemInt">
##  <ManSection>
##  <Func Name="RemInt" Arg='n, m'/>
##
##  <Description>
##  <Index>remainder of a quotient</Index>
##  <Ref Func="RemInt"/> returns the remainder of its two integer operands.
##  <P/>
##  If <A>m</A> is not equal to zero, <Ref Func="RemInt"/> returns
##  <C><A>n</A> - <A>m</A> * QuoInt( <A>n</A>, <A>m</A> )</C>.
##  Note that the rules given for <Ref Func="QuoInt"/> imply that the return
##  value of <Ref Func="RemInt"/> has the same sign as <A>n</A>
##  and its absolute value is strictly less than the absolute value
##  of <A>m</A>.
##  Note also that the return value equals <C><A>n</A> mod <A>m</A></C>
##  when both <A>n</A> and <A>m</A> are nonnegative.
##  Dividing by <C>0</C> signals an error.
##  <P/>
##  <Ref Func="RemInt"/> is used in a method for the general operation
##  <Ref Oper="EuclideanRemainder"/>.
##  <Example><![CDATA[
##  gap> RemInt(5,3);  RemInt(-5,3);  RemInt(5,-3);  RemInt(-5,-3);
##  2
##  -2
##  2
##  -2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "RemInt", REM_INT );


#############################################################################
##
#F  GcdInt( <m>, <n> )  . . . . . . . . . . . . . .  gcd of internal integers
##
##  <#GAPDoc Label="GcdInt">
##  <ManSection>
##  <Func Name="GcdInt" Arg='m, n'/>
##
##  <Description>
##  <Ref Func="GcdInt"/> returns the greatest common divisor
##  of its two integer operands <A>m</A> and <A>n</A>, i.e.,
##  the greatest integer that divides both <A>m</A> and <A>n</A>.
##  The greatest common divisor is never negative, even if the arguments are.
##  We define
##  <C>GcdInt( <A>m</A>, 0 ) = GcdInt( 0, <A>m</A> ) = AbsInt( <A>m</A> )</C>
##  and <C>GcdInt( 0, 0 ) = 0</C>.
##  <P/>
##  <Ref Func="GcdInt"/> is a method used by the general function
##  <Ref Func="Gcd" Label="for (a ring and) several elements"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> GcdInt( 123, 66 );
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "GcdInt", GCD_INT );


#############################################################################
##
#m  Order( <cyc> ) . . . . . . . . . . . . . . . . .  order of an alg. number
##
##  If <cyc> is not a cyclotomic integer then its order is infinity.
##  Otherwise, <cyc> is a root of unity iff its absolute value is $1$.
##  (This follows from the more general theorem that an algebraic integer is
##  a root of unity iff all its algebraic conjugates have absolute value $1$;
##  note that we assume that <cyc> lies in a cyclotomic field,
##  so the Galois group of the field extension is abelian.)
##
##  This method is thought for cyclotomics for which it is cheap to decide
##  whether they are algebraic integers, and to compute the conductor;
##  both conditions hold for internally represented cyclotomics,
##  since they are represented w.r.t. an integral basis of the smallest
##  possible cyclotomic field.
##
InstallMethod( Order,
    "for a cyclotomic",
    [ IsCyc ],
    function ( cyc )
    local n;

    # Check that the argument is a root of unity.
    if cyc = 0 then
      Error( "argument must be nonzero" );
    elif not IsIntegralCyclotomic( cyc )
         or cyc * GaloisCyc( cyc, -1 ) <> 1 then
      return infinity;
    fi;

    # Let $n$ be the conductor of `cyc'.
    # The roots of unity in the $n$-th cyclotomic field are exactly the
    # $n$-th roots if $n$ is even, and the $2 n$-th roots if $n$ is odd.
    n:= Conductor( cyc );
    if n mod 2 = 0 or cyc^n = 1 then
      return n;
    else
      Assert( 1, cyc^n = -1 );
      return 2*n;
    fi;
    end );


#############################################################################
##
#M  Int( <int> )  . . . . . . . . . . . . . . . . . . . . . .  for an integer
#M  Int( <rat> ) . . . . . . . . . . . .   convert a rational into an integer
#M  Int( <cyc> )  . . . . . . . . . . . . .  cyclotomic integer near to <cyc>
##
##  <#GAPDoc Label="Int:cyclotomics">
##  <ManSection>
##  <Meth Name="Int" Arg='cyc' Label="for a cyclotomic"/>
##
##  <Description>
##  The operation <Ref Meth="Int" Label="for a cyclotomic"/>
##  can be used to find a cyclotomic integer near to an arbitrary cyclotomic,
##  by applying <Ref Attr="Int"/> to the coefficients.
##  <P/>
##  <Example><![CDATA[
##  gap> Int( E(5)+1/2*E(5)^2 ); Int( 2/3*E(7)-3/2*E(4) );
##  E(5)
##  -E(4)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( Int,
    "for an integer",
    [ IsInt ],
    IdFunc );

InstallMethod( Int,
    "for a rational",
    [ IsRat ],
    obj -> QuoInt( NumeratorRat( obj ), DenominatorRat( obj ) ) );

InstallMethod( Int,
    "for a cyclotomic",
    [ IsCyc ],
    cyc -> CycList( List( COEFFS_CYC( cyc ), Int ) ) );


#############################################################################
##
#M  String( <int> ) . . . . . . . . . . . . . . . . . . . . .  for an integer
#M  String( <rat> ) . . . . . . . . . . . .  convert a rational into a string
#M  String( <cyc> ) . . . . . . . . . . . .  convert cyclotomic into a string
#M  String( <infinity> )  . . . . . . . . . . . . . . . . . .  for `infinity'
##
##  <#GAPDoc Label="String:cyclotomics">
##  <ManSection>
##  <Meth Name="String" Arg='cyc' Label="for a cyclotomic"/>
##
##  <Description>
##  The operation <Ref Meth="String" Label="for a cyclotomic"/>
##  returns for a cyclotomic <A>cyc</A> a string corresponding to the way
##  the cyclotomic is printed by <Ref Oper="ViewObj"/> and
##  <Ref Oper="PrintObj"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> String( E(5)+1/2*E(5)^2 ); String( 17/3 );
##  "E(5)+1/2*E(5)^2"
##  "17/3"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallMethod( String,
    "for an integer",
    [ IsInt ],
function(a)
  local sign, halflen, b, q, qr, s1, s2, pad;

  # "small" numbers
  if Log2Int(a) < 5000 then
    # kernel method
    return STRING_INT(a);
  fi;

  # sign
  if a < 0 then
    sign := "-";
    a := -a;
  else
    sign := "";
  fi;

  # recursion
  halflen := QuoInt(Log2Int(a)*100, 664);
  b := 10^halflen;
  q := QUO_INT(a, b);
  qr := [q, a-q*b]; #QuotientRemainder(a, 10^halflen);
  if qr[1] = 0 then
    s1 := "";
  else
    s1 := String(qr[1]);
  fi;
  s2 := String(qr[2]);
  pad := ListWithIdenticalEntries(halflen-Length(s2), '0');

  return Concatenation(sign,s1,pad,s2);
end);

InstallMethod( String,
    "for a rational",
    [ IsRat ],
    function ( rat )
    local   str;

    str := String( NumeratorRat( rat ) );
    if DenominatorRat( rat ) <> 1  then
        str := Concatenation( str, "/", String( DenominatorRat( rat ) ) );
    fi;
    ConvertToStringRep( str );
    return str;
    end );

InstallMethod( String,
    "for a cyclotomic",
    [ IsCyc ],
    function( cyc )
    local i, j, En, coeffs, str;

    # get the coefficients
    coeffs := COEFFS_CYC( cyc );

    # get the root as a string
    En := Concatenation( "E(", String( Length( coeffs ) ), ")" );

    # print the first non zero coefficient
    i := 1;
    while coeffs[i] = 0 do i:= i+1; od;
    if i = 1  then
        str := ShallowCopy( String( coeffs[1] ) );
    elif coeffs[i] = -1 then
        str := Concatenation( "-", En );
    elif coeffs[i] = 1 then
        str := ShallowCopy( En );
    else
        str := Concatenation( String( coeffs[i] ), "*", En );
    fi;
    if 2 < i  then
        Add( str, '^' );
        Append( str, String(i-1) );
    fi;

    # print the other coefficients
    for j  in [i+1..Length(coeffs)]  do
        if   coeffs[j] = 1 then
            Add( str, '+' );
            Append( str, En );
        elif coeffs[j] = -1 then
            Add( str, '-' );
            Append( str, En );
        elif 0 < coeffs[j] then
            Add( str, '+' );
            Append( str, String( coeffs[j] ) );
            Add( str, '*' );
            Append( str, En );
        elif coeffs[j] < 0 then
            Append( str, String( coeffs[j] ) );
            Add( str, '*' );
            Append( str, En );
        fi;
        if 2 < j  and coeffs[j] <> 0  then
            Add( str, '^' );
            Append( str, String( j-1 ) );
        fi;
    od;

    # Convert to string representation.
    ConvertToStringRep( str );

    # Return the string.
    return str;
    end );

InstallMethod( String,
    "for infinity",
    [ IsInfinity ],
    x -> "infinity" );

InstallMethod( String,
    "for -infinity",
    [ IsNegInfinity ],
    x -> "-infinity" );
