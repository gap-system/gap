#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file is being maintained by Thomas Breuer.
##  Please do not make any changes without consulting him.
##  (This holds also for minor changes such as the removal of whitespace or
##  the correction of typos.)
##
##  This file declares operations for cyclotomics.
##


#############################################################################
##
##  <#GAPDoc Label="DefaultField:cyclotomics">
##  <ManSection>
##  <Func Name="DefaultField" Arg="list" Label="for cyclotomics"/>
##
##  <Description>
##  <Ref Func="DefaultField" Label="for cyclotomics"/> for cyclotomics
##  is defined to return the smallest <E>cyclotomic</E> field containing
##  the given elements.
##  <P/>
##  Note that <Ref Func="Field" Label="for several generators"/> returns
##  the smallest field containing all given elements,
##  which need not be a cyclotomic field.
##  In both cases, the fields represent vector spaces over the rationals
##  (see&nbsp;<Ref Sect="Integral Bases of Abelian Number Fields"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> Field( E(5)+E(5)^4 );  DefaultField( E(5)+E(5)^4 );
##  NF(5,[ 1, 4 ])
##  CF(5)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <!-- what about <C>DefaultRing</C>?? (integral rings are missing!)-->
##  <#/GAPDoc>
##


#############################################################################
##
#M  IsIntegralRing( <R> ) . . . . . .  Every ring of cyclotomics is integral.
##
InstallTrueMethod( IsIntegralRing,
    IsCyclotomicCollection and IsRing and IsNonTrivial );


#############################################################################
##
#A  AbsoluteValue( <cyc> )
##
##  <#GAPDoc Label="AbsoluteValue">
##  <ManSection>
##  <Attr Name="AbsoluteValue" Arg='cyc'/>
##
##  <Description>
##  returns the absolute value of a cyclotomic number <A>cyc</A>.
##  At the moment only methods for rational numbers exist.
##  <Example><![CDATA[
##  gap> AbsoluteValue(-3);
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AbsoluteValue" ,  IsCyclotomic  );


#############################################################################
##
#O  RoundCyc( <cyc> )
##
##  <#GAPDoc Label="RoundCyc">
##  <ManSection>
##  <Oper Name="RoundCyc" Arg='cyc'/>
##
##  <Description>
##  is a cyclotomic integer <M>z</M> (see <Ref Prop="IsIntegralCyclotomic"/>)
##  near to the cyclotomic <A>cyc</A> in the following sense:
##  Let <C>c</C> be the <M>i</M>-th coefficient in the external
##  representation (see&nbsp;<Ref Func="CoeffsCyc"/>) of <A>cyc</A>.
##  Then the <M>i</M>-th coefficient in the external representation of
##  <M>z</M> is <C>Int( c + 1/2 )</C> or <C>Int( c - 1/2 )</C>,
##  depending on whether <C>c</C> is nonnegative or negative, respectively.
##  <P/>
##  Expressed in terms of the Zumbroich basis
##  (see&nbsp;<Ref Sect="Integral Bases of Abelian Number Fields"/>),
##  rounding the coefficients of <A>cyc</A> w.r.t.&nbsp;this basis to the
##  nearest integer yields the coefficients of <M>z</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> RoundCyc( E(5)+1/2*E(5)^2 ); RoundCyc( 2/3*E(7)+3/2*E(4) );
##  E(5)+E(5)^2
##  -2*E(28)^3+E(28)^4-2*E(28)^11-2*E(28)^15-2*E(28)^19-2*E(28)^23
##   -2*E(28)^27
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RoundCyc" , [ IsCyclotomic ] );


#############################################################################
##
#O  RoundCycDown( <cyc> )
##
##  <ManSection>
##  <Oper Name="RoundCycDown" Arg='cyc'/>
##
##  <Description>
##  Performs much the same as RoundCyc, but rounds halves down.
##  </Description>
##  </ManSection>
##
DeclareOperation( "RoundCycDown" , [ IsCyclotomic ] );


#############################################################################
##
#F  CoeffsCyc( <cyc>, <N> )
##
##  <#GAPDoc Label="CoeffsCyc">
##  <ManSection>
##  <Func Name="CoeffsCyc" Arg='cyc, N'/>
##
##  <Description>
##  <Index Subkey="for cyclotomics">coefficients</Index>
##  Let <A>cyc</A> be a cyclotomic with conductor <M>n</M>
##  (see <Ref Attr="Conductor" Label="for a cyclotomic"/>).
##  If <A>N</A> is not a multiple of <M>n</M> then <Ref Func="CoeffsCyc"/>
##  returns <K>fail</K> because <A>cyc</A> cannot be expressed in terms of
##  <A>N</A>-th roots of unity.
##  Otherwise <Ref Func="CoeffsCyc"/> returns a list of length <A>N</A> with
##  entry at position <M>j</M> equal to the coefficient of
##  <M>\exp(2 \pi i (j-1)/<A>N</A>)</M> if this root
##  belongs to the <A>N</A>-th Zumbroich basis
##  (see&nbsp;<Ref Sect="Integral Bases of Abelian Number Fields"/>),
##  and equal to zero otherwise.
##  So we have
##  <A>cyc</A> = <C>CoeffsCyc(</C> <A>cyc</A>, <A>N</A> <C>) *
##  List( [1..</C><A>N</A><C>], j -> E(</C><A>N</A><C>)^(j-1) )</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> cyc:= E(5)+E(5)^2;
##  E(5)+E(5)^2
##  gap> CoeffsCyc( cyc, 5 );  CoeffsCyc( cyc, 15 );  CoeffsCyc( cyc, 7 );
##  [ 0, 1, 1, 0, 0 ]
##  [ 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 0, -1, 0, -1, 0 ]
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CoeffsCyc" );


##############################################################################
##
#F  DescriptionOfRootOfUnity( <root> )
##
##  <#GAPDoc Label="DescriptionOfRootOfUnity">
##  <ManSection>
##  <Func Name="DescriptionOfRootOfUnity" Arg='root'/>
##
##  <Description>
##  <Index Subkey="of a root of unity">logarithm</Index>
##  <P/>
##  Given a cyclotomic <A>root</A> that is known to be a root of unity
##  (this is <E>not</E> checked),
##  <Ref Func="DescriptionOfRootOfUnity"/> returns a list <M>[ n, e ]</M>
##  of coprime positive integers such that
##  <A>root</A> <M>=</M> <C>E</C><M>(n)^e</M> holds.
##  <P/>
##  <Example><![CDATA[
##  gap> E(9);  DescriptionOfRootOfUnity( E(9) );
##  -E(9)^4-E(9)^7
##  [ 9, 1 ]
##  gap> DescriptionOfRootOfUnity( -E(3) );
##  [ 6, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DescriptionOfRootOfUnity" );


#############################################################################
##
#F  EB( <N> ) . . . . . . . . . . . . . . . some atomic ATLAS irrationalities
#F  EC( <N> )
#F  ED( <N> )
#F  EE( <N> )
#F  EF( <N> )
#F  EG( <N> )
#F  EH( <N> )
##
##  <#GAPDoc Label="EB">
##  <ManSection>
##  <Heading>EB, EC, <M>\ldots</M>, EH</Heading>
##  <Func Name="EB" Arg='N'/>
##  <Func Name="EC" Arg='N'/>
##  <Func Name="ED" Arg='N'/>
##  <Func Name="EE" Arg='N'/>
##  <Func Name="EF" Arg='N'/>
##  <Func Name="EG" Arg='N'/>
##  <Func Name="EH" Arg='N'/>
##
##  <Description>
##  <Index Key="b_N"><M>b_N</M> (irrational value)</Index>
##  <Index Key="c_N"><M>c_N</M> (irrational value)</Index>
##  <Index Key="d_N"><M>d_N</M> (irrational value)</Index>
##  <Index Key="e_N"><M>e_N</M> (irrational value)</Index>
##  <Index Key="f_N"><M>f_N</M> (irrational value)</Index>
##  <Index Key="g_N"><M>g_N</M> (irrational value)</Index>
##  <Index Key="h_N"><M>h_N</M> (irrational value)</Index>
##  For a positive integer <A>N</A>,
##  let <M>z =</M> <C>E(</C><A>N</A><C>)</C> <M>= \exp(2 \pi i/<A>N</A>)</M>.
##  The following so-called <E>atomic irrationalities</E>
##  (see <Cite Key="CCN85" Where="Chapter 7, Section 10"/>)
##  can be entered using functions.
##  (Note that the values are not necessary irrational.)
##  <P/>
##  <Table Align="lclclcl">
##  <Row>
##    <Item><C>EB(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>b_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>\left( \sum_{{j = 1}}^{{<A>N</A>-1}} z^{{j^2}} \right) / 2</M>
##    </Item>
##    <Item>,</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod{2}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EC(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>c_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>\left( \sum_{{j = 1}}^{{<A>N</A>-1}} z^{{j^3}} \right) / 3</M>
##    </Item>
##    <Item>,</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod{3}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>ED(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>d_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>\left( \sum_{{j = 1}}^{{<A>N</A>-1}} z^{{j^4}} \right) / 4</M>
##    </Item>
##    <Item>,</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod{4}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EE(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>e_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>\left( \sum_{{j = 1}}^{{<A>N</A>-1}} z^{{j^5}} \right) / 5</M>
##    </Item>
##    <Item>,</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod{5}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EF(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>f_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>\left( \sum_{{j = 1}}^{{<A>N</A>-1}} z^{{j^6}} \right) / 6</M>
##    </Item>
##    <Item>,</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod{6}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EG(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>g_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>\left( \sum_{{j = 1}}^{{<A>N</A>-1}} z^{{j^7}} \right) / 7</M>
##    </Item>
##    <Item>,</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod{7}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EH(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>h_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>\left( \sum_{{j = 1}}^{{<A>N</A>-1}} z^{{j^8}} \right) / 8</M>
##    </Item>
##    <Item>,</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod{8}</M></Item>
##  </Row>
##  </Table>
##  (Note that in <C>EC(</C><A>N</A><C>)</C>, <M>\ldots</M>,
##  <C>EH(</C><A>N</A><C>)</C>, <A>N</A> must be a prime.)
##  <P/>
##  <Example><![CDATA[
##  gap> EB(5);  EB(9);
##  E(5)+E(5)^4
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EB" );
DeclareGlobalFunction( "EC" );
DeclareGlobalFunction( "ED" );
DeclareGlobalFunction( "EE" );
DeclareGlobalFunction( "EF" );
DeclareGlobalFunction( "EG" );
DeclareGlobalFunction( "EH" );


#############################################################################
##
#F  EI( <N> ) . . . . ATLAS irrationality $i_{<N>}$ (the square root of -<N>)
#F  ER( <N> ) . . . . ATLAS irrationality $r_{<N>}$ (pos. square root of <N>)
##
##  <#GAPDoc Label="EI">
##  <ManSection>
##  <Heading>EI and ER</Heading>
##  <Func Name="EI" Arg='N'/>
##  <Func Name="ER" Arg='N'/>
##
##  <Description>
##  <Index Key="i_N"><M>i_N</M> (irrational value)</Index>
##  <Index Key="r_N"><M>r_N</M> (irrational value)</Index>
##  For a rational number <A>N</A>,
##  <Ref Func="ER"/> returns the square root <M>\sqrt{{<A>N</A>}}</M> of
##  <A>N</A>,
##  and <Ref Func="EI"/> returns <M>\sqrt{{-<A>N</A>}}</M>.
##  By the chosen embedding of cyclotomic fields into the complex numbers,
##  <Ref Func="ER"/> returns the positive square root if <A>N</A> is
##  positive, and if <A>N</A> is negative then
##  <C>ER(</C><A>N</A><C>) = EI(-</C><A>N</A><C>)</C> holds.
##  In any case, <C>EI(</C><A>N</A><C>) = E(4) * ER(</C><A>N</A><C>)</C>.
##  <P/>
##  <Ref Func="ER"/> is installed as method for the operation
##  <Ref Oper="Sqrt"/>, for rational argument.
##  <P/>
##  From a theorem of Gauss we know that
##  <M>b_{<A>N</A>} =</M>
##  <Table Align="lcl">
##  <Row>
##    <Item><M>(-1 + \sqrt{{<A>N</A>}}) / 2</M></Item>
##    <Item>if</Item>
##    <Item><M><A>N</A> \equiv 1 \pmod 4</M></Item>
##  </Row>
##  <Row>
##    <Item><M>(-1 + i \sqrt{{<A>N</A>}}) / 2</M></Item>
##    <Item>if</Item>
##    <Item><M><A>N</A> \equiv -1 \pmod 4</M></Item>
##  </Row>
##  </Table>
##  So <M>\sqrt{{<A>N</A>}}</M> can be computed from <M>b_{<A>N</A>}</M>,
##  see&nbsp;<Ref Func="EB"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> ER(3); EI(3);
##  -E(12)^7+E(12)^11
##  E(3)-E(3)^2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EI" );
DeclareGlobalFunction( "ER" );


#############################################################################
##
#F  EY( <N>[, <d>] )
#F  EX( <N>[, <d>] )
#F  EW( <N>[, <d>] )
#F  EV( <N>[, <d>] )
#F  EU( <N>[, <d>] )
#F  ET( <N>[, <d>] )
#F  ES( <N>[, <d>] )
##
##  <#GAPDoc Label="EY">
##  <ManSection>
##  <Heading>EY, EX, <M>\ldots</M>, ES</Heading>
##  <Func Name="EY" Arg='N[, d]'/>
##  <Func Name="EX" Arg='N[, d]'/>
##  <Func Name="EW" Arg='N[, d]'/>
##  <Func Name="EV" Arg='N[, d]'/>
##  <Func Name="EU" Arg='N[, d]'/>
##  <Func Name="ET" Arg='N[, d]'/>
##  <Func Name="ES" Arg='N[, d]'/>
##
##  <Description>
##  <Index Key="s_N"><M>s_N</M> (irrational value)</Index>
##  <Index Key="t_N"><M>t_N</M> (irrational value)</Index>
##  <Index Key="u_N"><M>u_N</M> (irrational value)</Index>
##  <Index Key="v_N"><M>v_N</M> (irrational value)</Index>
##  <Index Key="w_N"><M>w_N</M> (irrational value)</Index>
##  <Index Key="x_N"><M>x_N</M> (irrational value)</Index>
##  <Index Key="y_N"><M>y_N</M> (irrational value)</Index>
##  For the given integer <A>N</A> <M>> 2</M>,
##  let <M><A>N</A>_k</M> denote the first integer
##  with multiplicative order exactly <M>k</M> modulo <A>N</A>,
##  chosen in the order of preference
##  <Display Mode="M">
##  1, -1, 2, -2, 3, -3, 4, -4, \ldots .
##  </Display>
##  <P/>
##  We define (with <M>z = \exp(2 \pi i/<A>N</A>)</M>)
##  <Table Align="lclcll">
##  <Row>
##    <Item><C>EY(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>y_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z + z^n</M></Item>
##    <Item><M>(n = <A>N</A>_2)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EX(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>x_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z + z^n + z^{{n^2}}</M></Item>
##    <Item><M>(n = <A>N</A>_3)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EW</C>(<A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>w_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z + z^n + z^{{n^2}} + z^{{n^3}}</M></Item>
##    <Item><M>(n = <A>N</A>_4)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EV(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>v_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z + z^n + z^{{n^2}} + z^{{n^3}} + z^{{n^4}}</M></Item>
##    <Item><M>(n = <A>N</A>_5)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EU(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>u_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z + z^n + z^{{n^2}} + \ldots + z^{{n^5}}</M></Item>
##    <Item><M>(n = <A>N</A>_6)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>ET(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>t_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z + z^n + z^{{n^2}} + \ldots + z^{{n^6}}</M></Item>
##    <Item><M>(n = <A>N</A>_7)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>ES(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>s_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z + z^n + z^{{n^2}} + \ldots + z^{{n^7}}</M></Item>
##    <Item><M>(n = <A>N</A>_8)</M></Item>
##  </Row>
##  </Table>
##  <P/>
##  For the two-argument versions of the functions,
##  see Section <Ref Func="NK"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> EY(5);
##  E(5)+E(5)^4
##  gap> EW(16,3); EW(17,2);
##  0
##  E(17)+E(17)^4+E(17)^13+E(17)^16
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EY" );
DeclareGlobalFunction( "EX" );
DeclareGlobalFunction( "EW" );
DeclareGlobalFunction( "EV" );
DeclareGlobalFunction( "EU" );
DeclareGlobalFunction( "ET" );
DeclareGlobalFunction( "ES" );


#############################################################################
##
#F  EM( <N>[, <d>] )
#F  EL( <N>[, <d>] )
#F  EK( <N>[, <d>] )
#F  EJ( <N>[, <d>] )
##
##  <#GAPDoc Label="EM">
##  <ManSection>
##  <Heading>EM, EL, <M>\ldots</M>, EJ</Heading>
##  <Func Name="EM" Arg='N[, d]'/>
##  <Func Name="EL" Arg='N[, d]'/>
##  <Func Name="EK" Arg='N[, d]'/>
##  <Func Name="EJ" Arg='N[, d]'/>
##
##  <Description>
##  Let <A>N</A> be an integer, <A>N</A> <M>> 2</M>.
##  We define (with <M>z = \exp(2 \pi i/<A>N</A>)</M>)
##  <Index Key="j_N"><M>j_N</M> (irrational value)</Index>
##  <Index Key="k_N"><M>k_N</M> (irrational value)</Index>
##  <Index Key="l_N"><M>l_N</M> (irrational value)</Index>
##  <Index Key="m_N"><M>m_N</M> (irrational value)</Index>
##  <Table Align="lclcll">
##  <Row>
##    <Item><C>EM(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>m_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z - z^n</M></Item>
##    <Item><M>(n = <A>N</A>_2)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EL(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>l_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z - z^n + z^{{n^2}} - z^{{n^3}}</M></Item>
##    <Item><M>(n = <A>N</A>_4)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EK(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>k_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z - z^n + \ldots - z^{{n^5}}</M></Item>
##    <Item><M>(n = <A>N</A>_6)</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EJ(</C><A>N</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>j_{<A>N</A>}</M></Item>
##    <Item>=</Item>
##    <Item><M>z - z^n + \ldots - z^{{n^7}}</M></Item>
##    <Item><M>(n = <A>N</A>_8)</M></Item>
##  </Row>
##  </Table>
##  <P/>
##  For the two-argument versions of the functions,
##  see Section <Ref Func="NK"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EM" );
DeclareGlobalFunction( "EL" );
DeclareGlobalFunction( "EK" );
DeclareGlobalFunction( "EJ" );


#############################################################################
##
#F  NK( <N>, <k>, <d> ) . . . . . . . . . . utility for ATLAS irrationalities
##
##  <#GAPDoc Label="NK">
##  <ManSection>
##  <Func Name="NK" Arg='N, k, d'/>
##
##  <Description>
##  Let <M><A>N</A>_{<A>k</A>}^{(<A>d</A>)}</M> be the <M>(<A>d</A>+1)</M>-th
##  integer with multiplicative order exactly <A>k</A> modulo <A>N</A>,
##  chosen in the order of preference defined in Section <Ref Subsect="EY"/>;
##  <Ref Func="NK"/> returns <M><A>N</A>_{<A>k</A>}^{(<A>d</A>)}</M>;
##  if there is no integer with the required multiplicative order,
##  <Ref Func="NK"/> returns <K>fail</K>.
##  <P/>
##  We write <M><A>N</A>_{<A>k</A>} = <A>N</A>_{<A>k</A>}^{(0)},
##  <A>N</A>_{<A>k</A>}^{\prime} = <A>N</A>_{<A>k</A>}^{(1)},
##  <A>N</A>_{<A>k</A>}^{\prime\prime} = <A>N</A>_{<A>k</A>}^{(2)}</M>
##  and so on.
##  <P/>
##  The algebraic numbers
##  <Display Mode="M">
##  y_{<A>N</A>}^{\prime} = y_{<A>N</A>}^{(1)},
##  y_{<A>N</A>}^{\prime\prime} = y_{<A>N</A>}^{(2)}, \ldots,
##  x_{<A>N</A>}^{\prime}, x_{<A>N</A>}^{\prime\prime}, \ldots,
##  j_{<A>N</A>}^{\prime}, j_{<A>N</A>}^{\prime\prime}, \ldots
##  </Display>
##  are obtained on replacing <M><A>N</A>_{<A>k</A>}</M> in the
##  definitions in the sections <Ref Subsect="EY"/> and <Ref Subsect="EM"/>
##  by <M><A>N</A>_{<A>k</A>}^{\prime},
##  <A>N</A>_{<A>k</A>}^{\prime\prime}, \ldots</M>;
##  they can be entered as
##  <P/>
##  <Table Align="lcl">
##  <Row>
##    <Item><C>EY(</C><A>N</A>,<A>d</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>y_{<A>N</A>}^{(<A>d</A>)}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>EX(</C><A>N</A>,<A>d</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>x_{<A>N</A>}^{(<A>d</A>)}</M></Item>
##  </Row>
##  <Row>
##    <Item></Item>
##    <Item><M>\ldots</M></Item>
##    <Item></Item>
##  </Row>
##  <Row>
##    <Item><C>EJ(</C><A>N</A>,<A>d</A><C>)</C></Item>
##    <Item>=</Item>
##    <Item><M>j_{<A>N</A>}^{(<A>d</A>)}</M></Item>
##  </Row>
##  </Table>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NK" );


#############################################################################
##
#F  AtlasIrrationality( <irratname> )
##
##  <#GAPDoc Label="AtlasIrrationality">
##  <ManSection>
##  <Func Name="AtlasIrrationality" Arg='irratname'/>
##
##  <Description>
##  Let <A>irratname</A> be a string that describes an irrational value as
##  a linear combination in terms of the atomic irrationalities introduced in
##  the sections <Ref Subsect="EB"/>, <Ref Subsect="EI"/>,
##  <Ref Subsect="EY"/>, <Ref Subsect="EM"/>.
##  These irrational values are defined in
##  <Cite Key="CCN85" Where="Chapter 6, Section 10"/>, and the following
##  description is mainly copied from there.
##  If <M>q_N</M> is such a value (e.g. <M>y_{24}^{\prime\prime}</M>)
##  then linear combinations of algebraic conjugates of <M>q_N</M> are
##  abbreviated as in the following examples:
##  <P/>
##  <Table Align="lcl">
##  <Row>
##    <Item><C>2qN+3&amp;5-4&amp;7+&amp;9</C></Item>
##    <Item>means</Item>
##    <Item><M>2 q_N + 3 q_N^{{*5}} - 4 q_N^{{*7}} + q_N^{{*9}}</M>
##    </Item>
##  </Row>
##  <Row>
##    <Item><C>4qN&amp;3&amp;5&amp;7-3&amp;4</C></Item>
##    <Item>means</Item>
##    <Item><M>4 (q_N + q_N^{{*3}} + q_N^{{*5}} + q_N^{{*7}})
##    - 3 q_N^{{*11}}</M></Item>
##  </Row>
##  <Row>
##    <Item><C>4qN*3&amp;5+&amp;7</C></Item>
##    <Item>means</Item>
##    <Item><M>4 (q_N^{{*3}} + q_N^{{*5}}) + q_N^{{*7}}</M></Item>
##  </Row>
##  </Table>
##  <P/>
##  To explain the <Q>ampersand</Q> syntax in general we remark that
##  <Q>&amp;k</Q> is interpreted as <M>q_N^{{*k}}</M>,
##  where <M>q_N</M> is the most recently named atomic irrationality,
##  and that the scope of any premultiplying coefficient is broken by a
##  <M>+</M> or <M>-</M> sign, but not by <M>\&amp;</M> or <M>*k</M>.
##  The algebraic conjugations indicated by the ampersands apply directly to
##  the <E>atomic</E> irrationality <M>q_N</M>, even when,
##  as in the last example,
##  <M>q_N</M> first appears with another conjugacy <M>*k</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> AtlasIrrationality( "b7*3" );
##  E(7)^3+E(7)^5+E(7)^6
##  gap> AtlasIrrationality( "y'''24" );
##  E(24)-E(24)^19
##  gap> AtlasIrrationality( "-3y'''24*13&5" );
##  3*E(8)-3*E(8)^3
##  gap> AtlasIrrationality( "3y'''24*13-2&5" );
##  -3*E(24)-2*E(24)^11+2*E(24)^17+3*E(24)^19
##  gap> AtlasIrrationality( "3y'''24*13-&5" );
##  -3*E(24)-E(24)^11+E(24)^17+3*E(24)^19
##  gap> AtlasIrrationality( "3y'''24*13-4&5&7" );
##  -7*E(24)-4*E(24)^11+4*E(24)^17+7*E(24)^19
##  gap> AtlasIrrationality( "3y'''24&7" );
##  6*E(24)-6*E(24)^19
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AtlasIrrationality" );


#############################################################################
##
#F  StarCyc( <cyc> )  . . . . the unique nontrivial Galois conjugate of <cyc>
##
##  <#GAPDoc Label="StarCyc">
##  <ManSection>
##  <Func Name="StarCyc" Arg='cyc'/>
##
##  <Description>
##  If the cyclotomic <A>cyc</A> is an irrational element of a quadratic
##  extension of the rationals then <Ref Func="StarCyc"/> returns the unique
##  Galois conjugate of <A>cyc</A> that is different from <A>cyc</A>,
##  otherwise <K>fail</K> is returned.
##  In the first case, the return value is often called <A>cyc</A><M>*</M>
##  (see&nbsp;<Ref Sect="Printing Character Tables"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> StarCyc( EB(5) ); StarCyc( E(5) );
##  E(5)^2+E(5)^3
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StarCyc" );


#############################################################################
##
#F  Quadratic( <cyc> ) . . . . .  information about quadratic irrationalities
##
##  <#GAPDoc Label="Quadratic">
##  <ManSection>
##  <Func Name="Quadratic" Arg='cyc'/>
##
##  <Description>
##  Let <A>cyc</A> be a cyclotomic integer that lies in a quadratic extension
##  field of the rationals.
##  Then we have <A>cyc</A><M> = (a + b \sqrt{{n}}) / d</M>,
##  for integers <M>a</M>, <M>b</M>, <M>n</M>, <M>d</M>,
##  such that <M>d</M> is either <M>1</M> or <M>2</M>.
##  In this case, <Ref Func="Quadratic"/> returns a record with the
##  components <C>a</C>, <C>b</C>, <C>root</C>, <C>d</C>, <C>ATLAS</C>,
##  and <C>display</C>;
##  the values of the first four are <M>a</M>, <M>b</M>, <M>n</M>,
##  and <M>d</M>,
##  the <C>ATLAS</C> value is a (not necessarily shortest) representation of
##  <A>cyc</A> in terms of the &ATLAS; irrationalities
##  <M>b_{{|n|}}</M>, <M>i_{{|n|}}</M>, <M>r_{{|n|}}</M>,
##  and the <C>display</C> value is a string that expresses <A>cyc</A> in
##  &GAP; notation, corresponding to the value of the <C>ATLAS</C> component.
##  <P/>
##  If <A>cyc</A> is not a cyclotomic integer or does not lie in a quadratic
##  extension field of the rationals then <K>fail</K> is returned.
##  <P/>
##  If the denominator <M>d</M> is <M>2</M> then necessarily <M>n</M> is
##  congruent to <M>1</M> modulo <M>4</M>,
##  and <M>r_n</M>, <M>i_n</M> are not possible;
##  we have <C><A>cyc</A> = x + y * EB( root )</C>
##  with <C>y = b</C>, <C>x = ( a + b ) / 2</C>.
##  <P/>
##  If <M>d = 1</M>, we have the possibilities
##  <M>i_{{|n|}}</M> for <M>n &lt; -1</M>,
##  <M>a + b * i</M> for <M>n = -1</M>, <M>a + b * r_n</M>
##  for <M>n &gt; 0</M>.
##  Furthermore if <M>n</M> is congruent to <M>1</M> modulo <M>4</M>,
##  also <A>cyc</A> <M>= (a+b) + 2 * b * b_{{|n|}}</M> is possible;
##  the shortest string of these is taken as the value for the component
##  <C>ATLAS</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> Quadratic( EB(5) ); Quadratic( EB(27) );
##  rec( ATLAS := "b5", a := -1, b := 1, d := 2,
##    display := "(-1+Sqrt(5))/2", root := 5 )
##  rec( ATLAS := "1+3b3", a := -1, b := 3, d := 2,
##    display := "(-1+3*Sqrt(-3))/2", root := -3 )
##  gap> Quadratic(0); Quadratic( E(5) );
##  rec( ATLAS := "0", a := 0, b := 0, d := 1, display := "0", root := 1 )
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Quadratic" );


#############################################################################
##
#A  GaloisMat( <mat> )
##
##  <#GAPDoc Label="GaloisMat">
##  <ManSection>
##  <Attr Name="GaloisMat" Arg='mat'/>
##
##  <Description>
##  Let <A>mat</A> be a matrix of cyclotomics.
##  <Ref Attr="GaloisMat"/> calculates the complete orbits under
##  the operation of the Galois group of the (irrational) entries of
##  <A>mat</A>,
##  and the permutations of rows corresponding to the generators of the
##  Galois group.
##  <P/>
##  If some rows of <A>mat</A> are identical,
##  only the first one is considered for the permutations,
##  and a warning will be printed.
##  <P/>
##  <Ref Attr="GaloisMat"/> returns a record with the components <C>mat</C>,
##  <C>galoisfams</C>, and <C>generators</C>.
##  <P/>
##  <List>
##  <Mark><C>mat</C></Mark>
##  <Item>
##     a list with initial segment being the rows of <A>mat</A>
##     (<E>not</E> shallow copies of these rows);
##     the list consists of full orbits under the action of the Galois
##     group of the entries of <A>mat</A> defined above.
##     The last rows in the list are those not contained in <A>mat</A> but
##     must be added in order to complete the orbits;
##     so if the orbits were already complete, <A>mat</A> and <C>mat</C> have
##     identical rows.
##  </Item>
##  <Mark><C>galoisfams</C></Mark>
##  <Item>
##     a list that has the same length as the <C>mat</C> component,
##     its entries are either 1, 0, -1, or lists.
##     <List>
##     <Mark><C>galoisfams[i] = 1</C></Mark>
##     <Item>
##        means that <C>mat[i]</C> consists of rationals,
##        i.e., <C>[ mat[i] ]</C> forms an orbit;
##     </Item>
##     <Mark><C>galoisfams[i] = -1</C></Mark>
##     <Item>
##        means that <C>mat[i]</C> contains unknowns
##        (see Chapter&nbsp;<Ref Chap="Unknowns"/>);
##        in this case <C>[ mat[i] ]</C> is regarded as an orbit, too,
##        even if <C>mat[i]</C> contains irrational entries;
##     </Item>
##     <Mark><C>galoisfams[i] = </C><M>[ l_1, l_2 ]</M></Mark>
##     <Item>
##        (a list) means that <C>mat[i]</C> is the first element of its orbit
##        in <C>mat</C>,
##        <M>l_1</M> is the list of positions of rows that form the orbit,
##        and <M>l_2</M> is the list of corresponding Galois automorphisms
##        (as exponents, not as functions);
##        so we have <C>mat</C><M>[ l_1[j] ][k] = </M>
##        <C>GaloisCyc( mat</C><M>[i][k], l_2[j]</M><C> )</C>;
##     </Item>
##     <Mark><C>galoisfams[i] = 0</C></Mark>
##     <Item>
##        means that <C>mat[i]</C> is an element of a
##        nontrivial orbit but not the first element of it.
##     </Item>
##     </List>
##  </Item>
##  <Mark><C>generators</C></Mark>
##  <Item>
##     a list of permutations generating the permutation group
##     corresponding to the action of the Galois group on the rows of
##     <C>mat</C>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> GaloisMat( [ [ E(3), E(4) ] ] );
##  rec( galoisfams := [ [ [ 1, 2, 3, 4 ], [ 1, 7, 5, 11 ] ], 0, 0, 0 ],
##    generators := [ (1,2)(3,4), (1,3)(2,4) ],
##    mat := [ [ E(3), E(4) ], [ E(3), -E(4) ], [ E(3)^2, E(4) ],
##        [ E(3)^2, -E(4) ] ] )
##  gap> GaloisMat( [ [ 1, 1, 1 ], [ 1, E(3), E(3)^2 ] ] );
##  rec( galoisfams := [ 1, [ [ 2, 3 ], [ 1, 2 ] ], 0 ],
##    generators := [ (2,3) ],
##    mat := [ [ 1, 1, 1 ], [ 1, E(3), E(3)^2 ], [ 1, E(3)^2, E(3) ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GaloisMat", IsMatrix );


#############################################################################
##
#A  RationalizedMat( <mat> )  . . . . . .  list of rationalized rows of <mat>
##
##  <#GAPDoc Label="RationalizedMat">
##  <ManSection>
##  <Attr Name="RationalizedMat" Arg='mat'/>
##
##  <Description>
##  returns the list of rationalized rows of <A>mat</A>,
##  which must be a matrix of cyclotomics.
##  This is the set of sums over orbits under the action of the Galois group
##  of the entries of <A>mat</A> (see <Ref Attr="GaloisMat"/>),
##  so the operation may be viewed as a kind of trace on the rows.
##  <P/>
##  Note that no two rows of <A>mat</A> should be equal.
##  <P/>
##  <Example><![CDATA[
##  gap> mat:= [ [ 1, 1, 1 ], [ 1, E(3), E(3)^2 ], [ 1, E(3)^2, E(3) ] ];;
##  gap> RationalizedMat( mat );
##  [ [ 1, 1, 1 ], [ 2, -1, -1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RationalizedMat", IsMatrix );


#############################################################################
##
#F  DenominatorCyc( <cyc> )
##
##  <#GAPDoc Label="DenominatorCyc">
##  <ManSection>
##  <Func Name="DenominatorCyc" Arg='cyc'/>
##
##  <Description>
##  For a cyclotomic number <A>cyc</A> (see&nbsp;<Ref Filt="IsCyclotomic"/>),
##  this function returns the smallest positive integer <M>n</M> such that
##  <M>n</M><C> * </C><A>cyc</A> is a cyclotomic integer
##  (see&nbsp;<Ref Prop="IsIntegralCyclotomic"/>).
##  For rational numbers <A>cyc</A>, the result is the same as that of
##  <Ref Func="DenominatorRat"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DenominatorCyc" );
