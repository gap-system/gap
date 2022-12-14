#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Jens Hollmann.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration part of the padic numbers.
##


#############################################################################
##
#C  IsPadicNumber
##
##  <ManSection>
##  <Filt Name="IsPadicNumber" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Filt Name="IsPadicNumberFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryFamily( "IsPadicNumber" );


#############################################################################
##
#C  IsPurePadicNumber(<obj>)
##
##  <#GAPDoc Label="IsPurePadicNumber">
##  <ManSection>
##  <Filt Name="IsPurePadicNumber" Arg='obj' Type='Category'/>
##
##  <Description>
##  The category of pure <M>p</M>-adic numbers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsPurePadicNumber", IsPadicNumber );


#############################################################################
##
#C  IsPurePadicNumberFamily(<fam>)
##
##  <#GAPDoc Label="IsPurePadicNumberFamily">
##  <ManSection>
##  <Filt Name="IsPurePadicNumberFamily" Arg='fam' Type='Category'/>
##
##  <Description>
##  The family of pure <M>p</M>-adic numbers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryFamily( "IsPurePadicNumber" );


#############################################################################
##
#C  IsPadicExtensionNumber(<obj>)
##
##  <#GAPDoc Label="IsPadicExtensionNumber">
##  <ManSection>
##  <Filt Name="IsPadicExtensionNumber" Arg='obj' Type='Category'/>
##
##  <Description>
##  The category of elements of the extended <M>p</M>-adic field.
##  <Example><![CDATA[
##  gap>  efam:=PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]);;
##  gap> IsPadicExtensionNumber(PadicNumber(efam,7/9));
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsPadicExtensionNumber", IsPadicNumber );


#############################################################################
##
#C  IsPadicExtensionNumberFamily(<fam>)
##
##  <#GAPDoc Label="IsPadicExtensionNumberFamily">
##  <ManSection>
##  <Filt Name="IsPadicExtensionNumberFamily" Arg='fam' Type='Category'/>
##
##  <Description>
##  Family of elements of the extended <M>p</M>-adic field.
##  <Example><![CDATA[
##  gap> efam:=PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]);;
##  gap> IsPadicExtensionNumberFamily(efam);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryFamily( "IsPadicExtensionNumber" );


#############################################################################
##
#O  Valuation( <obj> )
##
##  <#GAPDoc Label="Valuation">
##  <ManSection>
##  <Oper Name="Valuation" Arg='obj'/>
##
##  <Description>
##  The valuation is the <M>p</M>-part of the <M>p</M>-adic number.
##  See also <Ref Func="PValuation"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Valuation",  [ IsObject ] );


#############################################################################
##
#O  PadicNumber( <fam>, <rat> )
#O  PadicNumber( <purefam>,<list>)
#O  PadicNumber( <extfam>,<list>)
##
##  <#GAPDoc Label="PadicNumber">
##  <ManSection>
##  <Oper Name="PadicNumber" Arg='fam, rat'
##   Label="for a p-adic extension family and a rational"/>
##  <Oper Name="PadicNumber" Arg='purefam, list'
##   Label="for a pure p-adic numbers family and a list"/>
##  <Oper Name="PadicNumber" Arg='extfam, list'
##   Label="for a p-adic extension family and a list"/>
##
##  <Description>
##  (see also <Ref Oper="PadicNumber" Label="for pure padics"/>).
##  <P/>
##  <Ref Oper="PadicNumber"
##   Label="for a p-adic extension family and a rational"/>
##  creates a <M>p</M>-adic number in the
##  <M>p</M>-adic numbers family <A>fam</A>.
##  The first form returns the <M>p</M>-adic number corresponding to the
##  rational <A>rat</A>.
##  <P/>
##  The second form takes a pure <M>p</M>-adic numbers family <A>purefam</A>
##  and a list <A>list</A> of length two, and returns the number
##  <M>p</M><C>^</C><A>list</A><C>[1] * </C><A>list</A><C>[2]</C>.
##  It must be guaranteed that no entry of <A>list</A><C>[2]</C> is
##  divisible by the prime <M>p</M>.
##  (Otherwise precision will get lost.)
##  <P/>
##  The third form creates a number in the family <A>extfam</A> of a
##  <M>p</M>-adic extension.
##  The second argument must be a list <A>list</A> of length two such that
##  <A>list</A><C>[2]</C> is the list of coefficients w.r.t. the basis
##  <M>\{ 1, \ldots, x^{{f-1}} \cdot y^{{e-1}} \}</M> of the extended
##  <M>p</M>-adic field and <A>list</A><C>[1]</C> is a common <M>p</M>-part
##  of all these coefficients.
##  <P/>
##  <M>p</M>-adic numbers admit the usual field operations.
##  <Example><![CDATA[
##  gap> efam:=PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1]);;
##  gap> PadicNumber(efam,7/9);
##  padic(120(3),0(3))
##  ]]></Example>
##  <P/>
##  <E>A word of warning:</E>
##  <P/>
##  Depending on the actual representation of quotients, precision may seem
##  to <Q>vanish</Q>.
##  For example in <C>PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1])</C>
##  the number <C>(1.2000, 0.1210)(3)</C> can be represented as
##  <C>[ 0, [ 1.2000, 0.1210 ] ]</C>  or as <C>[ -1, [ 12.000, 1.2100 ] ]</C>
##  (here the coefficients have to be multiplied by <M>p^{{-1}}</M>).
##  <P/>
##  So there may be a number <C>(1.2, 2.2)(3)</C> which seems to have
##  only two digits of precision instead of the declared 5.
##  But internally the number is stored as <C>[ -3, [ 0.0012, 0.0022 ] ]</C>
##  and so has in fact maximum precision.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PadicNumber", [ IsPadicNumberFamily, IsObject ] );


#############################################################################
##
#O  ShiftedPadicNumber( <padic>, <int> )
##
##  <#GAPDoc Label="ShiftedPadicNumber">
##  <ManSection>
##  <Oper Name="ShiftedPadicNumber" Arg='padic, int'/>
##
##  <Description>
##  <Ref Oper="ShiftedPadicNumber"/> takes a <M>p</M>-adic number
##  <A>padic</A> and an integer <A>shift</A>
##  and returns the <M>p</M>-adic number <M>c</M>,
##  that is <A>padic</A> <C>*</C> <M>p</M><C>^</C><A>shift</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ShiftedPadicNumber", [ IsPadicNumber, IsInt ] );


#############################################################################
##
#O  PurePadicNumberFamily( <p>, <precision> )
##
##  <#GAPDoc Label="PurePadicNumberFamily">
##  <ManSection>
##  <Func Name="PurePadicNumberFamily" Arg='p, precision'/>
##
##  <Description>
##  returns the family of pure <M>p</M>-adic numbers over the
##  prime <A>p</A> with <A>precision</A> <Q>digits</Q>. That is to say, the approximate value
##  will differ from the correct value by a multiple of <M>p^{digits}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PurePadicNumberFamily" );


#############################################################################
##
#F  PadicExtensionNumberFamily( <p>, <precision>, <unram>, <ram> )
##
##  <#GAPDoc Label="PadicExtensionNumberFamily">
##  <ManSection>
##  <Func Name="PadicExtensionNumberFamily" Arg='p, precision, unram, ram'/>
##
##  <Description>
##  An extended <M>p</M>-adic field <M>L</M> is given by two polynomials
##  <M>h</M> and <M>g</M> with coefficient lists <A>unram</A> (for the
##  unramified part) and <A>ram</A> (for the ramified part).
##  Then <M>L</M> is isomorphic to <M>Q_p[x,y]/(h(x),g(y))</M>.
##  <P/>
##  This function takes the prime number <A>p</A> and the two coefficient
##  lists <A>unram</A> and <A>ram</A> for the two polynomials.
##  The polynomial given by the coefficients in <A>unram</A> must be a
##  cyclotomic polynomial and the polynomial given by <A>ram</A> must be
##  either an Eisenstein polynomial or <M>1+x</M>.
##  <E>This is not checked by &GAP;.</E>
##  <P/>
##  Every number in <M>L</M> is represented as a coefficient list w. r. t.
##  the basis <M>\{ 1, x, x^2, \ldots, y, xy, x^2 y, \ldots \}</M>
##  of <M>L</M>.
##  The integer <A>precision</A> is the number of <Q>digits</Q> that all the
##  coefficients have.
##  <P/>
##  <E>A general comment:</E>
##  <P/>
##  The polynomials with which <Ref Func="PadicExtensionNumberFamily"/> is
##  called define an extension of <M>Q_p</M>.
##  It must be ensured that both polynomials are really irreducible over
##  <M>Q_p</M>!
##  For example <M>x^2+x+1</M> is <E>not</E> irreducible over <M>Q_p</M>.
##  Therefore the <Q>extension</Q>
##  <C>PadicExtensionNumberFamily(3, 4, [1,1,1], [1,1])</C> contains
##  non-invertible <Q>pseudo-p-adic numbers</Q>.
##  Conversely, if an <Q>extension</Q> contains noninvertible elements
##  then one of the defining polynomials was not irreducible.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PadicExtensionNumberFamily" );
