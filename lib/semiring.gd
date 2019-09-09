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
##  This file declares the operations for semirings.
##


#############################################################################
##
#P  IsLDistributive( <C> )
##
##  <#GAPDoc Label="IsLDistributive">
##  <ManSection>
##  <Prop Name="IsLDistributive" Arg='C'/>
##
##  <Description>
##  is <K>true</K> if the relation
##  <M>a * ( b + c ) = ( a * b ) + ( a * c )</M>
##  holds for all elements <M>a</M>, <M>b</M>, <M>c</M> in the collection
##  <A>C</A>, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsLDistributive", IsRingElementCollection );

InstallSubsetMaintenance( IsLDistributive,
    IsRingElementCollection and IsLDistributive,
    IsRingElementCollection );

InstallFactorMaintenance( IsLDistributive,
    IsRingElementCollection and IsLDistributive,
    IsObject,
    IsRingElementCollection );


#############################################################################
##
#P  IsRDistributive( <C> )
##
##  <#GAPDoc Label="IsRDistributive">
##  <ManSection>
##  <Prop Name="IsRDistributive" Arg='C'/>
##
##  <Description>
##  is <K>true</K> if the relation
##  <M>( a + b ) * c = ( a * c ) + ( b * c )</M>
##  holds for all elements <M>a</M>, <M>b</M>, <M>c</M> in the collection
##  <A>C</A>, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsRDistributive", IsRingElementCollection );

InstallSubsetMaintenance( IsRDistributive,
    IsRingElementCollection and IsRDistributive,
    IsRingElementCollection );

InstallFactorMaintenance( IsRDistributive,
    IsRingElementCollection and IsRDistributive,
    IsObject,
    IsRingElementCollection );


#############################################################################
##
#P  IsDistributive( <C> )
##
##  <#GAPDoc Label="IsDistributive">
##  <ManSection>
##  <Prop Name="IsDistributive" Arg='C'/>
##
##  <Description>
##  is <K>true</K> if the collection <A>C</A> is both left and right
##  distributive
##  (see <Ref Prop="IsLDistributive"/>, <Ref Prop="IsRDistributive"/>),
##  and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap> IsDistributive( Integers );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsDistributive", IsLDistributive and IsRDistributive );


#############################################################################
##
#P  IsSemiring( <S> )
##
##  <ManSection>
##  <Prop Name="IsSemiring" Arg='S'/>
##
##  <Description>
##  A <E>semiring</E> in &GAP; is an additive magma (see&nbsp;<Ref Func="IsAdditiveMagma"/>)
##  that is also a magma (see&nbsp;<Ref Func="IsMagma"/>),
##  such that addition <C>+</C> and multiplication <C>*</C> are distributive.
##  <P/>
##  The multiplication need <E>not</E> be associative (see&nbsp;<Ref Func="IsAssociative"/>).
##  For example, a Lie algebra (see&nbsp;<Ref Chap="Lie Algebras"/>) is regarded as a
##  semiring in &GAP;.
##  A semiring need not have an identity and a zero element,
##  see&nbsp;<Ref Prop="IsSemiringWithOne"/> and <Ref Prop="IsSemiringWithZero"/>.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsSemiring",
    IsAdditiveMagma and IsMagma and IsDistributive );


#############################################################################
##
#P  IsSemiringWithOne( <S> )
##
##  <ManSection>
##  <Prop Name="IsSemiringWithOne" Arg='S'/>
##
##  <Description>
##  A <E>semiring-with-one</E> in &GAP; is a semiring (see&nbsp;<Ref Prop="IsSemiring"/>)
##  that is also a magma-with-one (see&nbsp;<Ref Func="IsMagmaWithOne"/>).
##  <P/>
##  Note that a semiring-with-one need not contain a zero element
##  (see&nbsp;<Ref Prop="IsSemiringWithZero"/>).
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsSemiringWithOne",
    IsAdditiveMagma and IsMagmaWithOne and IsDistributive );


#############################################################################
##
#P  IsSemiringWithZero( <S> )
##
##  <ManSection>
##  <Prop Name="IsSemiringWithZero" Arg='S'/>
##
##  <Description>
##  A <E>semiring-with-zero</E> in &GAP; is a semiring (see&nbsp;<Ref Prop="IsSemiring"/>)
##  that is also an additive magma-with-zero (see&nbsp;<Ref Func="IsAdditiveMagmaWithZero"/>).
##  <P/>
##  Note that a semiring-with-zero need not contain an identity element
##  (see&nbsp;<Ref Prop="IsSemiringWithOne"/>).
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsSemiringWithZero",
    IsAdditiveMagmaWithZero and IsMagma and IsDistributive );


#############################################################################
##
#P  IsSemiringWithOneAndZero( <S> )
##
##  <ManSection>
##  <Prop Name="IsSemiringWithOneAndZero" Arg='S'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsSemiringWithOneAndZero",
    IsAdditiveMagmaWithZero and IsMagmaWithOne and IsDistributive );


#############################################################################
##
#A  GeneratorsOfSemiring( <S> )
##
##  <ManSection>
##  <Attr Name="GeneratorsOfSemiring" Arg='S'/>
##
##  <Description>
##  <C>GeneratorsOfSemiring</C> returns a list of elements such that
##  the semiring <A>S</A> is the closure of these elements
##  under addition and multiplication.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "GeneratorsOfSemiring", IsSemiring );


#############################################################################
##
#A  GeneratorsOfSemiringWithOne( <S> )
##
##  <ManSection>
##  <Attr Name="GeneratorsOfSemiringWithOne" Arg='S'/>
##
##  <Description>
##  <C>GeneratorsOfSemiringWithOne</C> returns a list of elements such that
##  the semiring <A>R</A> is the closure of these elements
##  under addition, multiplication, and taking the identity element
##  <C>One( <A>S</A> )</C>.
##  <P/>
##  <A>S</A> itself need <E>not</E> be known to be a semiring-with-one.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "GeneratorsOfSemiringWithOne", IsSemiringWithOne );


#############################################################################
##
#A  GeneratorsOfSemiringWithZero( <S> )
##
##  <ManSection>
##  <Attr Name="GeneratorsOfSemiringWithZero" Arg='S'/>
##
##  <Description>
##  <C>GeneratorsOfSemiringWithZero</C> returns a list of elements such that
##  the semiring <A>S</A> is the closure of these elements
##  under addition, multiplication, and taking the zero element
##  <C>Zero( <A>S</A> )</C>.
##  <P/>
##  <A>S</A> itself need <E>not</E> be known to be a semiring-with-zero.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "GeneratorsOfSemiringWithZero", IsSemiringWithZero );


#############################################################################
##
#A  GeneratorsOfSemiringWithOneAndZero( <S> )
##
##  <ManSection>
##  <Attr Name="GeneratorsOfSemiringWithOneAndZero" Arg='S'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "GeneratorsOfSemiringWithOneAndZero",
    IsSemiringWithOneAndZero );


#############################################################################
##
#A  AsSemiring( <C> )
##
##  <ManSection>
##  <Attr Name="AsSemiring" Arg='C'/>
##
##  <Description>
##  If the elements in the collection <A>C</A> form a semiring
##  then <C>AsSemiring</C> returns this semiring,
##  otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AsSemiring", IsRingElementCollection );


#############################################################################
##
#A  AsSemiringWithOne( <C> )
##
##  <ManSection>
##  <Attr Name="AsSemiringWithOne" Arg='C'/>
##
##  <Description>
##  If the elements in the collection <A>C</A> form a semiring-with-one
##  then <C>AsSemiringWithOne</C> returns this semiring-with-one,
##  otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AsSemiringWithOne", IsRingElementCollection );


#############################################################################
##
#A  AsSemiringWithZero( <C> )
##
##  <ManSection>
##  <Attr Name="AsSemiringWithZero" Arg='C'/>
##
##  <Description>
##  If the elements in the collection <A>C</A> form a semiring-with-zero
##  then <C>AsSemiringWithZero</C> returns this semiring-with-zero,
##  otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AsSemiringWithZero", IsRingElementCollection );


#############################################################################
##
#A  AsSemiringWithOneAndZero( <C> )
##
##  <ManSection>
##  <Attr Name="AsSemiringWithOneAndZero" Arg='C'/>
##
##  <Description>
##  If the elements in the collection <A>C</A> form a semiring-with-one-and-zero
##  then <C>AsSemiringWithOneAndZero</C> returns this semiring-with-one-and-zero,
##  otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AsSemiringWithOneAndZero", IsRingElementCollection );


#############################################################################
##
#O  ClosureSemiring( <S>, <s> )
#O  ClosureSemiring( <S>, <T> )
##
##  <ManSection>
##  <Oper Name="ClosureSemiring" Arg='S, s'/>
##  <Oper Name="ClosureSemiring" Arg='S, T'/>
##
##  <Description>
##  For a semiring <A>S</A> and either an element <A>s</A> of its elements family
##  or a semiring <A>T</A>,
##  <C>ClosureSemiring</C> returns the semiring generated by both arguments.
##  </Description>
##  </ManSection>
##
DeclareOperation( "ClosureSemiring", [ IsSemiring, IsObject ] );


#############################################################################
##
#O  SemiringByGenerators( <C> ) . . .  semiring gener. by elements in a coll.
##
##  <ManSection>
##  <Oper Name="SemiringByGenerators" Arg='C'/>
##
##  <Description>
##  <C>SemiringByGenerators</C> returns the semiring generated by the elements
##  in the collection <A>C</A>,
##  i.&nbsp;e., the closure of <A>C</A> under addition and multiplication.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SemiringByGenerators", [ IsCollection ] );


#############################################################################
##
#O  SemiringWithOneByGenerators( <C> )
##
##  <ManSection>
##  <Oper Name="SemiringWithOneByGenerators" Arg='C'/>
##
##  <Description>
##  <C>SemiringWithOneByGenerators</C> returns the semiring-with-one generated by
##  the elements in the collection <A>C</A>, i.&nbsp;e., the closure of <A>C</A> under
##  addition, multiplication, and taking the identity of an element.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SemiringWithOneByGenerators", [ IsCollection ] );


#############################################################################
##
#O  SemiringWithZeroByGenerators( <C> )
##
##  <ManSection>
##  <Oper Name="SemiringWithZeroByGenerators" Arg='C'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "SemiringWithZeroByGenerators", [ IsCollection ] );


#############################################################################
##
#O  SemiringWithOneAndZeroByGenerators( <C> )
##
##  <ManSection>
##  <Oper Name="SemiringWithOneAndZeroByGenerators" Arg='C'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "SemiringWithOneAndZeroByGenerators", [ IsCollection ] );


#############################################################################
##
#F  Semiring( <r> ,<s>, ... )  . . . . . . semiring generated by a collection
#F  Semiring( <C> )  . . . . . . . . . . . semiring generated by a collection
##
##  <ManSection>
##  <Func Name="Semiring" Arg='r ,s, ...'/>
##  <Func Name="Semiring" Arg='C'/>
##
##  <Description>
##  In the first form <C>Semiring</C> returns the smallest semiring that
##  contains all the elements <A>r</A>, <A>s</A>... etc.
##  In the second form <C>Semiring</C> returns the smallest semiring that
##  contains all the elements in the collection <A>C</A>.
##  If any element is not an element of a semiring or if the elements lie in
##  no common semiring an error is raised.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "Semiring" );


#############################################################################
##
#F  SemiringWithOne( <r>, <s>, ... )
#F  SemiringWithOne( <C> )
##
##  <ManSection>
##  <Func Name="SemiringWithOne" Arg='r, s, ...'/>
##  <Func Name="SemiringWithOne" Arg='C'/>
##
##  <Description>
##  In the first form <C>SemiringWithOne</C> returns the smallest
##  semiring-with-one that contains all the elements <A>r</A>, <A>s</A>... etc.
##  In the second form <C>SemiringWithOne</C> returns the smallest
##  semiring-with-one that contains all the elements in the collection <A>C</A>.
##  If any element is not an element of a semiring or if the elements lie in
##  no common semiring an error is raised.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SemiringWithOne" );


#############################################################################
##
#F  SemiringWithZero( <r>, <s>, ... )
#F  SemiringWithZero( <C> )
##
##  <ManSection>
##  <Func Name="SemiringWithZero" Arg='r, s, ...'/>
##  <Func Name="SemiringWithZero" Arg='C'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SemiringWithZero" );


#############################################################################
##
#F  SemiringWithOneAndZero( <r>, <s>, ... )
#F  SemiringWithOneAndZero( <C> )
##
##  <ManSection>
##  <Func Name="SemiringWithOneAndZero" Arg='r, s, ...'/>
##  <Func Name="SemiringWithOneAndZero" Arg='C'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SemiringWithOneAndZero" );


#############################################################################
##
#F  Subsemiring( <S>, <gens> )
#F  SubsemiringNC( <S>, <gens> )
##
##  <ManSection>
##  <Func Name="Subsemiring" Arg='S, gens'/>
##  <Func Name="SubsemiringNC" Arg='S, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "Subsemiring" );
DeclareGlobalFunction( "SubsemiringNC" );


#############################################################################
##
#F  SubsemiringWithOne( <S>, <gens> )
#F  SubsemiringWithOneNC( <S>, <gens> )
##
##  <ManSection>
##  <Func Name="SubsemiringWithOne" Arg='S, gens'/>
##  <Func Name="SubsemiringWithOneNC" Arg='S, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SubsemiringWithOne" );
DeclareGlobalFunction( "SubsemiringWithOneNC" );


#############################################################################
##
#F  SubsemiringWithZero( <S>, <gens> )
#F  SubsemiringWithZeroNC( <S>, <gens> )
##
##  <ManSection>
##  <Func Name="SubsemiringWithZero" Arg='S, gens'/>
##  <Func Name="SubsemiringWithZeroNC" Arg='S, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SubsemiringWithZero" );
DeclareGlobalFunction( "SubsemiringWithZeroNC" );


#############################################################################
##
#F  SubsemiringWithOneAndZero( <S>, <gens> )
#F  SubsemiringWithOneAndZeroNC( <S>, <gens> )
##
##  <ManSection>
##  <Func Name="SubsemiringWithOneAndZero" Arg='S, gens'/>
##  <Func Name="SubsemiringWithOneAndZeroNC" Arg='S, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SubsemiringWithOneAndZero" );
DeclareGlobalFunction( "SubsemiringWithOneAndZeroNC" );


#############################################################################
##
#A  CentralIdempotentsOfSemiring( <S> )
##
##  <ManSection>
##  <Attr Name="CentralIdempotentsOfSemiring" Arg='S'/>
##
##  <Description>
##  For a semiring <A>S</A>, this function returns
##  a list of central primitive idempotents such that their sum is
##  the identity element of <A>S</A>.
##  Therefore <A>S</A> is required to have an identity.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "CentralIdempotentsOfSemiring", IsSemiring );
