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
##  This file declares the operations for additive magmas,
##  Note that the meaning of generators for the three categories
##  additive magma, additive-magma-with-zero,
##  and additive-magma-with-inverses is different.
##


#############################################################################
##
#C  IsNearAdditiveMagma( <obj> )
##
##  <#GAPDoc Label="IsNearAdditiveMagma">
##  <ManSection>
##  <Filt Name="IsNearAdditiveMagma" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>near-additive magma</E> in &GAP; is a domain <M>A</M>
##  with an associative but not necessarily commutative addition
##  <C>+</C><M>: A \times A \rightarrow A</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsNearAdditiveMagma",
    IsDomain and IsNearAdditiveElementCollection );


#############################################################################
##
#C  IsNearAdditiveMagmaWithZero( <obj> )
##
##  <#GAPDoc Label="IsNearAdditiveMagmaWithZero">
##  <ManSection>
##  <Filt Name="IsNearAdditiveMagmaWithZero" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>near-additive magma-with-zero</E> in &GAP; is a near-additive magma
##  <M>A</M> with an operation <C>0*</C> (or <Ref Attr="Zero"/>)
##  that yields the zero element of <M>A</M>.
##  <P/>
##  So a near-additive magma-with-zero <A>A</A> does always contain a unique
##  additively neutral element <M>z</M>,
##  i.e., <M>z + a = a = a + z</M> holds for all <M>a \in A</M>
##  (see&nbsp;<Ref Attr="AdditiveNeutralElement"/>).
##  This zero element <M>z</M> can be computed with the operation
##  <Ref Attr="Zero"/>, by applying this function to <M>A</M> or to any
##  element <M>a</M> in <M>A</M>.
##  The zero element can be computed also as <C>0 * </C><M>a</M>,
##  for any <M>a</M> in <M>A</M>.
##  <P/>
##  <E>Note</E> that it may happen that
##  a near-additive magma containing a zero does <E>not</E> lie in the
##  category <Ref Filt="IsNearAdditiveMagmaWithZero"/>
##  (see&nbsp;<Ref Sect="Domain Categories"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsNearAdditiveMagmaWithZero",
    IsNearAdditiveMagma and IsNearAdditiveElementWithZeroCollection );


#############################################################################
##
#C  IsNearAdditiveGroup( <obj> )
#C  IsNearAdditiveMagmaWithInverses( <obj> )
##
##  <#GAPDoc Label="IsNearAdditiveGroup">
##  <ManSection>
##  <Filt Name="IsNearAdditiveGroup" Arg='obj' Type='Category'/>
##  <Filt Name="IsNearAdditiveMagmaWithInverses" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>near-additive group</E> in &GAP; is a near-additive magma-with-zero
##  <M>A</M> with an operation <C>-1*</C><M>: A \rightarrow A</M> that maps
##  each element <M>a</M> of <M>A</M> to its additive inverse
##  <C>-1*</C><M>a</M> (or <C>AdditiveInverse( </C><A>a</A><C> )</C>,
##  see&nbsp;<Ref Attr="AdditiveInverse"/>).
##  <P/>
##  The addition <C>+</C> of <M>A</M> is assumed to be associative,
##  so a near-additive group is not more than a
##  <E>near-additive magma-with-inverses</E>.
##  <Ref Filt="IsNearAdditiveMagmaWithInverses"/> is just a synonym for
##  <Ref Filt="IsNearAdditiveGroup"/>,
##  and can be used alternatively in all function names involving the string
##  <C>"NearAdditiveGroup"</C>.
##  <P/>
##  Note that not every trivial near-additive magma is a near-additive
##  magma-with-zero,
##  but every trivial near-additive magma-with-zero is a near-additive group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsNearAdditiveGroup",
        IsNearAdditiveMagmaWithZero
    and IsNearAdditiveElementWithInverseCollection );

DeclareSynonym( "IsNearAdditiveMagmaWithInverses", IsNearAdditiveGroup );


#############################################################################
##
#P  IsAdditivelyCommutative( <A> )
##
##  <#GAPDoc Label="IsAdditivelyCommutative">
##  <ManSection>
##  <Prop Name="IsAdditivelyCommutative" Arg='A'/>
##
##  <Description>
##  A near-additive magma <A>A</A> in &GAP; is <E>additively commutative</E>
##  if for all elements <M>a, b \in <A>A</A></M> the equality
##  <M>a + b = b + a</M> holds.
##  <P/>
##  Note that the commutativity of the <E>multiplication</E> <C>*</C> in a
##  multiplicative structure can be tested with <Ref Prop="IsCommutative"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsAdditivelyCommutative", IsNearAdditiveMagma );

InstallTrueMethod( IsAdditivelyCommutative,
    IsAdditivelyCommutativeElementCollection and IsMagma );

InstallSubsetMaintenance( IsAdditivelyCommutative,
    IsNearAdditiveMagma and IsAdditivelyCommutative, IsNearAdditiveMagma );

InstallFactorMaintenance( IsAdditivelyCommutative,
    IsNearAdditiveMagma and IsAdditivelyCommutative,
    IsObject, IsNearAdditiveMagma );

InstallTrueMethod( IsAdditivelyCommutative,
    IsNearAdditiveMagma and IsTrivial );


InstallTrueMethod( IsAdditiveElementCollection,
    IsNearAdditiveElementCollection and IsAdditivelyCommutative );
InstallTrueMethod( IsAdditiveElementWithZeroCollection,
    IsNearAdditiveElementWithZeroCollection and IsAdditivelyCommutative );
InstallTrueMethod( IsAdditiveElementWithInverseCollection,
        IsNearAdditiveElementWithInverseCollection
    and IsAdditivelyCommutative );


#############################################################################
##
#C  IsAdditiveMagma( <obj> )
##
##  <#GAPDoc Label="IsAdditiveMagma">
##  <ManSection>
##  <Filt Name="IsAdditiveMagma" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>additive magma</E> in &GAP; is a domain <M>A</M> with an
##  associative and commutative addition
##  <C>+</C><M>: A \times A \rightarrow A</M>,
##  see&nbsp;<Ref Filt="IsNearAdditiveMagma"/> and
##  <Ref Prop="IsAdditivelyCommutative"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsAdditiveMagma",
    IsNearAdditiveMagma and IsAdditivelyCommutative );


#############################################################################
##
#C  IsAdditiveMagmaWithZero( <obj> )
##
##  <#GAPDoc Label="IsAdditiveMagmaWithZero">
##  <ManSection>
##  <Filt Name="IsAdditiveMagmaWithZero" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>additive magma-with-zero</E> in &GAP; is an additive magma <M>A</M>
##  (see <Ref Filt="IsAdditiveMagma"/> with an operation <C>0*</C>
##  (or <Ref Attr="Zero"/>) that yields the zero of <M>A</M>.
##  <P/>
##  So an additive magma-with-zero <M>A</M> does always contain a unique
##  additively neutral element <M>z</M>, i.e.,
##  <M>z + a = a = a + z</M> holds for all <M>a \in A</M>
##  (see&nbsp;<Ref Attr="AdditiveNeutralElement"/>).
##  This element <M>z</M> can be computed with the operation
##  <Ref Attr="Zero"/> as <C>Zero( </C><M>A</M><C> )</C>,
##  and <M>z</M> is also equal to <C>Zero( </C><M>a</M><C> )</C> and to
##  <C>0*</C><M>a</M> for each element <M>a</M> in <M>A</M>.
##  <P/>
##  <E>Note</E> that it may happen that
##  an additive magma containing a zero does <E>not</E> lie in the category
##  <Ref Filt="IsAdditiveMagmaWithZero"/>
##  (see&nbsp;<Ref Sect="Domain Categories"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsAdditiveMagmaWithZero",
    IsNearAdditiveMagmaWithZero and IsAdditiveMagma );


#############################################################################
##
#C  IsAdditiveGroup( <obj> )
#C  IsAdditiveMagmaWithInverses( <obj> )
##
##  <#GAPDoc Label="IsAdditiveGroup">
##  <ManSection>
##  <Filt Name="IsAdditiveGroup" Arg='obj' Type='Category'/>
##  <Filt Name="IsAdditiveMagmaWithInverses" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>additive group</E> in &GAP; is an additive magma-with-zero <M>A</M>
##  with an operation <C>-1*</C><M>: A \rightarrow A</M> that maps
##  each element <M>a</M> of <M>A</M> to its additive inverse
##  <C>-1*</C><M>a</M> (or <C>AdditiveInverse( </C><M>a</M><C> )</C>,
##  see&nbsp;<Ref Attr="AdditiveInverse"/>).
##  <P/>
##  The addition <C>+</C> of <M>A</M> is assumed to be commutative and
##  associative, so an additive group is not more than an
##  <E>additive magma-with-inverses</E>.
##  <Ref Filt="IsAdditiveMagmaWithInverses"/> is just a synonym for
##  <Ref Filt="IsAdditiveGroup"/>,
##  and can be used alternatively in all function names involving the string
##  <C>"AdditiveGroup"</C>.
##  <P/>
##  Note that not every trivial additive magma is an additive
##  magma-with-zero,
##  but every trivial additive magma-with-zero is an additive group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsAdditiveGroup",
    IsNearAdditiveGroup and IsAdditiveMagma );

DeclareSynonym( "IsAdditiveMagmaWithInverses", IsAdditiveGroup );


#############################################################################
##
#A  Zero( <D> )
##
##  (see the description in `arith.gd')
##
DeclareAttribute( "Zero", IsDomain and IsAdditiveElementWithZeroCollection );


#############################################################################
##
#F  NearAdditiveMagma( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="NearAdditiveMagma">
##  <ManSection>
##  <Func Name="NearAdditiveMagma" Arg='[Fam, ]gens'/>
##
##  <Description>
##  returns the (near-)additive magma <M>A</M> that is generated by the
##  elements in the list <A>gens</A>, that is,
##  the closure of <A>gens</A> under addition <C>+</C>.
##  The family <A>Fam</A> of <M>A</M> can be entered as first argument;
##  this is obligatory if <A>gens</A> is empty
##  (and hence also <M>A</M> is empty).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NearAdditiveMagma" );

DeclareSynonym( "AdditiveMagma", NearAdditiveMagma );


#############################################################################
##
#F  NearAdditiveMagmaWithZero( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="NearAdditiveMagmaWithZero">
##  <ManSection>
##  <Func Name="NearAdditiveMagmaWithZero" Arg='[Fam, ]gens'/>
##
##  <Description>
##  returns the (near-)additive magma-with-zero <M>A</M> that is generated by
##  the elements in the list <A>gens</A>, that is,
##  the closure of <A>gens</A> under addition <C>+</C> and
##  <Ref Attr="Zero"/>.
##  The family <A>Fam</A> of <M>A</M> can be entered as first argument;
##  this is obligatory if <A>gens</A> is empty
##  (and hence <M>A</M> is trivial).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NearAdditiveMagmaWithZero" );

DeclareSynonym( "AdditiveMagmaWithZero", NearAdditiveMagmaWithZero );


#############################################################################
##
#F  NearAdditiveGroup( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="NearAdditiveGroup">
##  <ManSection>
##  <Func Name="NearAdditiveGroup" Arg='[Fam, ]gens'/>
##
##  <Description>
##  returns the (near-)additive group <M>A</M> that is generated by
##  the elements in the list <A>gens</A>, that is,
##  the closure of <A>gens</A> under addition <C>+</C>, <Ref Attr="Zero"/>,
##  and <Ref Attr="AdditiveInverse"/>.
##  The family <A>Fam</A> of <M>A</M> can be entered as first argument;
##  this is obligatory if <A>gens</A> is empty
##  (and hence <M>A</M> is trivial).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NearAdditiveGroup" );

DeclareSynonym( "AdditiveGroup", NearAdditiveGroup );
DeclareSynonym( "NearAdditiveMagmaWithInverses", NearAdditiveGroup );
DeclareSynonym( "AdditiveMagmaWithInverses", NearAdditiveGroup );


#############################################################################
##
#O  NearAdditiveMagmaByGenerators( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="NearAdditiveMagmaByGenerators">
##  <ManSection>
##  <Oper Name="NearAdditiveMagmaByGenerators" Arg='[Fam, ]gens'/>
##
##  <Description>
##  An underlying operation for <Ref Func="NearAdditiveMagma"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NearAdditiveMagmaByGenerators", [ IsCollection ] );

DeclareSynonym( "AdditiveMagmaByGenerators", NearAdditiveMagmaByGenerators );


#############################################################################
##
#O  NearAdditiveMagmaWithZeroByGenerators( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="NearAdditiveMagmaWithZeroByGenerators">
##  <ManSection>
##  <Oper Name="NearAdditiveMagmaWithZeroByGenerators" Arg='[Fam, ]gens'/>
##
##  <Description>
##  An underlying operation for <Ref Func="NearAdditiveMagmaWithZero"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NearAdditiveMagmaWithZeroByGenerators",
    [ IsCollection ] );

DeclareSynonym( "AdditiveMagmaWithZeroByGenerators",
    NearAdditiveMagmaWithZeroByGenerators );


#############################################################################
##
#O  NearAdditiveGroupByGenerators( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="NearAdditiveGroupByGenerators">
##  <ManSection>
##  <Oper Name="NearAdditiveGroupByGenerators" Arg='[Fam, ]gens'/>
##
##  <Description>
##  An underlying operation for <Ref Func="NearAdditiveGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NearAdditiveGroupByGenerators", [ IsCollection ] );

DeclareSynonym( "AdditiveGroupByGenerators",
    NearAdditiveGroupByGenerators );
DeclareSynonym( "NearAdditiveMagmaWithInversesByGenerators",
    NearAdditiveGroupByGenerators );
DeclareSynonym( "AdditiveMagmaWithInversesByGenerators",
    NearAdditiveGroupByGenerators );


#############################################################################
##
#F  SubnearAdditiveMagma( <D>, <gens> )
#F  SubnearAdditiveMagma( <D>, <gens> )
#F  SubadditiveMagmaNC( <D>, <gens> )
#F  SubadditiveMagmaNC( <D>, <gens> )
##
##  <#GAPDoc Label="SubnearAdditiveMagma">
##  <ManSection>
##  <Func Name="SubnearAdditiveMagma" Arg='D, gens'/>
##  <Func Name="SubadditiveMagma" Arg='D, gens'/>
##  <Func Name="SubnearAdditiveMagmaNC" Arg='D, gens'/>
##  <Func Name="SubadditiveMagmaNC" Arg='D, gens'/>
##
##  <Description>
##  <Ref Func="SubnearAdditiveMagma"/> returns the near-additive magma
##  generated by the elements in the list <A>gens</A>,
##  with parent the domain <A>D</A>.
##  <Ref Func="SubnearAdditiveMagmaNC"/> does the same, except that it
##  does not check whether the elements of <A>gens</A> lie in <A>D</A>.
##  <P/>
##  <Ref Func="SubadditiveMagma"/> and <Ref Func="SubadditiveMagmaNC"/>
##  are just synonyms of these functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubnearAdditiveMagma" );

DeclareGlobalFunction( "SubnearAdditiveMagmaNC" );

DeclareSynonym( "SubadditiveMagma", SubnearAdditiveMagma );
DeclareSynonym( "SubadditiveMagmaNC", SubnearAdditiveMagmaNC );


#############################################################################
##
#F  SubnearAdditiveMagmaWithZero( <D>, <gens> )
#F  SubnearAdditiveMagmaWithZeroNC( <D>, <gens> )
##
##  <#GAPDoc Label="SubnearAdditiveMagmaWithZero">
##  <ManSection>
##  <Func Name="SubnearAdditiveMagmaWithZero" Arg='D, gens'/>
##  <Func Name="SubadditiveMagmaWithZero" Arg='D, gens'/>
##  <Func Name="SubnearAdditiveMagmaWithZeroNC" Arg='D, gens'/>
##  <Func Name="SubadditiveMagmaWithZeroNC" Arg='D, gens'/>
##
##  <Description>
##  <Ref Func="SubnearAdditiveMagmaWithZero"/> returns the near-additive
##  magma-with-zero generated by the elements in the list <A>gens</A>,
##  with parent the domain <A>D</A>.
##  <Ref Func="SubnearAdditiveMagmaWithZeroNC"/> does the same, except that
##  it does not check whether the elements of <A>gens</A> lie in <A>D</A>.
##  <P/>
##  <Ref Func="SubadditiveMagmaWithZero"/> and
##  <Ref Func="SubadditiveMagmaWithZeroNC"/>
##  are just synonyms of these functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubnearAdditiveMagmaWithZero" );

DeclareGlobalFunction( "SubnearAdditiveMagmaWithZeroNC" );

DeclareSynonym( "SubadditiveMagmaWithZero", SubnearAdditiveMagmaWithZero );
DeclareSynonym( "SubadditiveMagmaWithZeroNC",
    SubnearAdditiveMagmaWithZeroNC );


#############################################################################
##
#F  SubnearAdditiveGroup( <D>, <gens> )
#F  SubnearAdditiveGroupNC( <D>, <gens> )
##
##  <#GAPDoc Label="SubnearAdditiveGroup">
##  <ManSection>
##  <Func Name="SubnearAdditiveGroup" Arg='D, gens'/>
##  <Func Name="SubadditiveGroup" Arg='D, gens'/>
##  <Func Name="SubnearAdditiveGroupNC" Arg='D, gens'/>
##  <Func Name="SubadditiveGroupNC" Arg='D, gens'/>
##
##  <Description>
##  <Ref Func="SubnearAdditiveGroup"/> returns the near-additive group
##  generated by the elements in the list <A>gens</A>,
##  with parent the domain <A>D</A>.
##  <Ref Func="SubadditiveGroupNC"/> does the same, except that it does not
##  check whether the elements of <A>gens</A> lie in <A>D</A>.
##  <P/>
##  <Ref Func="SubadditiveGroup"/> and <Ref Func="SubadditiveGroupNC"/>
##  are just synonyms of these functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubnearAdditiveGroup" );

DeclareGlobalFunction( "SubnearAdditiveGroupNC" );

DeclareSynonym( "SubadditiveGroup", SubnearAdditiveGroup );
DeclareSynonym( "SubnearAdditiveMagmaWithInverses", SubnearAdditiveGroup );
DeclareSynonym( "SubadditiveMagmaWithInverses", SubnearAdditiveGroup );

DeclareSynonym( "SubadditiveGroupNC", SubnearAdditiveGroupNC );
DeclareSynonym( "SubnearAdditiveMagmaWithInversesNC",
    SubnearAdditiveGroupNC );
DeclareSynonym( "SubadditiveMagmaWithInversesNC", SubnearAdditiveGroupNC );


#############################################################################
##
#A  GeneratorsOfNearAdditiveMagma( <A> )
#A  GeneratorsOfAdditiveMagma( <A> )
##
##  <#GAPDoc Label="GeneratorsOfNearAdditiveMagma">
##  <ManSection>
##  <Attr Name="GeneratorsOfNearAdditiveMagma" Arg='A'/>
##  <Attr Name="GeneratorsOfAdditiveMagma" Arg='A'/>
##
##  <Description>
##  is a list of elements of the near-additive magma <A>A</A>
##  that generates <A>A</A> as a near-additive magma,
##  that is, the closure of this list under addition is <A>A</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfNearAdditiveMagma", IsNearAdditiveMagma );

DeclareSynonymAttr( "GeneratorsOfAdditiveMagma",
    GeneratorsOfNearAdditiveMagma );


#############################################################################
##
#A  GeneratorsOfNearAdditiveMagmaWithZero( <A> )
#A  GeneratorsOfAdditiveMagmaWithZero( <A> )
##
##  <#GAPDoc Label="GeneratorsOfNearAdditiveMagmaWithZero">
##  <ManSection>
##  <Attr Name="GeneratorsOfNearAdditiveMagmaWithZero" Arg='A'/>
##  <Attr Name="GeneratorsOfAdditiveMagmaWithZero" Arg='A'/>
##
##  <Description>
##  is a list of elements of the near-additive magma-with-zero
##  <A>A</A> that generates <A>A</A> as a near-additive magma-with-zero,
##  that is,
##  the closure of this list under addition and <Ref Attr="Zero"/>
##  is <A>A</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfNearAdditiveMagmaWithZero",
    IsNearAdditiveMagmaWithZero );

DeclareSynonymAttr( "GeneratorsOfAdditiveMagmaWithZero",
    GeneratorsOfNearAdditiveMagmaWithZero );


#############################################################################
##
#A  GeneratorsOfNearAdditiveGroup( <A> )
#A  GeneratorsOfAdditiveGroup( <A> )
##
##  <#GAPDoc Label="GeneratorsOfNearAdditiveGroup">
##  <ManSection>
##  <Attr Name="GeneratorsOfNearAdditiveGroup" Arg='A'/>
##  <Attr Name="GeneratorsOfAdditiveGroup" Arg='A'/>
##
##  <Description>
##  is a list of elements of the near-additive group <A>A</A>
##  that generates <A>A</A> as a near-additive group,
##  that is, the closure of this list under addition,
##  taking the zero element, and taking additive inverses
##  (see&nbsp;<Ref Attr="AdditiveInverse"/>) is <A>A</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfNearAdditiveGroup", IsNearAdditiveGroup );

DeclareSynonymAttr( "GeneratorsOfAdditiveMagmaWithInverses",
    GeneratorsOfNearAdditiveGroup );
DeclareSynonymAttr( "GeneratorsOfNearAdditiveMagmaWithInverses",
    GeneratorsOfNearAdditiveGroup );
DeclareSynonymAttr( "GeneratorsOfAdditiveGroup",
    GeneratorsOfNearAdditiveGroup );


#############################################################################
##
#A  TrivialSubnearAdditiveMagmaWithZero( <A> )
##
##  <#GAPDoc Label="TrivialSubnearAdditiveMagmaWithZero">
##  <ManSection>
##  <Attr Name="TrivialSubnearAdditiveMagmaWithZero" Arg='A'/>
##
##  <Description>
##  is the additive magma-with-zero that has the zero of
##  the near-additive magma-with-zero <A>A</A> as its only element.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TrivialSubnearAdditiveMagmaWithZero",
    IsNearAdditiveMagmaWithZero );

DeclareSynonymAttr( "TrivialSubadditiveMagmaWithZero",
    TrivialSubnearAdditiveMagmaWithZero );


#############################################################################
##
#A  AdditiveNeutralElement( <A> )
##
##  <#GAPDoc Label="AdditiveNeutralElement">
##  <ManSection>
##  <Attr Name="AdditiveNeutralElement" Arg='A'/>
##
##  <Description>
##  returns the element <M>z</M> in the near-additive magma <A>A</A>
##  with the property that <M>z + a = a = a + z</M> holds for all
##  <M>a \in</M> <A>A</A>, if such an element exists.
##  Otherwise <K>fail</K> is returned.
##  <P/>
##  A near-additive magma that is not a near-additive magma-with-zero
##  can have an additive neutral element <M>z</M>;
##  in this case, <M>z</M> <E>cannot</E> be obtained as
##  <C>Zero( <A>A</A> )</C> or as <C>0*</C><M>a</M>
##  for an element <M>a</M> in <A>A</A>, see&nbsp;<Ref Attr="Zero"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AdditiveNeutralElement", IsNearAdditiveMagma );


#############################################################################
##
#O  ClosureNearAdditiveGroup( <A>, <a> )  . . for near-add. group and element
#O  ClosureNearAdditiveGroup( <A>, <B> )  . . . . .  for two near-add. groups
##
##  <#GAPDoc Label="ClosureNearAdditiveGroup">
##  <ManSection>
##  <Heading>ClosureNearAdditiveGroup</Heading>
##  <Oper Name="ClosureNearAdditiveGroup" Arg='A, a'
##   Label="for a near-additive group and an element"/>
##  <Oper Name="ClosureNearAdditiveGroup" Arg='A, B'
##   Label="for two near-additive groups"/>
##
##  <Description>
##  returns the closure of the near-additive magma <A>A</A> with the element
##  <A>a</A> or with the near-additive magma <A>B</A>, w.r.t.&nbsp;addition,
##  taking the zero element, and taking additive inverses.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClosureNearAdditiveGroup",
    [ IsNearAdditiveGroup, IsNearAdditiveElement ] );

DeclareSynonym( "ClosureNearAdditiveMagmaWithInverses",
    ClosureNearAdditiveGroup );
DeclareSynonym( "ClosureAdditiveGroup",
    ClosureNearAdditiveGroup );
DeclareSynonym( "ClosureAdditiveMagmaWithInverses",
    ClosureNearAdditiveGroup );
