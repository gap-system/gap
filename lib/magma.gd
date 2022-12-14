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
##  This  file   declares   the categories   of  magmas,   their  properties,
##  attributes, and operations.  Note that the  meaning of generators for the
##  three categories  magma,   magma-with-one, and    magma-with-inverses  is
##  different.
##


#############################################################################
##
#C  IsMagma( <obj> )  . . . . . . . . . . . test whether an object is a magma
##
##  <#GAPDoc Label="IsMagma">
##  <ManSection>
##  <Filt Name="IsMagma" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>magma</E> in &GAP; is a domain <M>M</M> with
##  (not necessarily associative) multiplication
##  <C>*</C><M>: M \times M \rightarrow M</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsMagma", IsDomain and IsMultiplicativeElementCollection );


#############################################################################
##
#C  IsMagmaWithOne( <obj> ) . . .  test whether an object is a magma-with-one
##
##  <#GAPDoc Label="IsMagmaWithOne">
##  <ManSection>
##  <Filt Name="IsMagmaWithOne" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>magma-with-one</E> in &GAP; is a magma <M>M</M> with an operation
##  <C>^0</C> (or <Ref Attr="One"/>) that yields the identity of <M>M</M>.
##  <P/>
##  So a magma-with-one <M>M</M> does always contain a unique
##  multiplicatively neutral element <M>e</M>, i.e.,
##  <M>e</M><C> * </C><M>m = m = m</M><C> * </C><M>e</M> holds
##  for all <M>m \in M</M>
##  (see&nbsp;<Ref Attr="MultiplicativeNeutralElement"/>).
##  This element <M>e</M> can be computed with the operation
##  <Ref Attr="One"/> as <C>One( </C><M>M</M><C> )</C>,
##  and <M>e</M> is also equal to <C>One( </C><M>m</M><C> )</C> and to
##  <M>m</M><C>^0</C> for each element <M>m \in M</M>.
##  <P/>
##  <E>Note</E> that a magma may contain a multiplicatively neutral element
##  but <E>not</E> an identity (see&nbsp;<Ref Attr="One"/>),
##  and a magma containing an identity may <E>not</E> lie in the category
##  <Ref Filt="IsMagmaWithOne"/>
##  (see Section&nbsp;<Ref Sect="Domain Categories"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsMagmaWithOne",
    IsMagma and IsMultiplicativeElementWithOneCollection );


#############################################################################
##
#C  IsMagmaWithInversesIfNonzero( <obj> )
##
##  <#GAPDoc Label="IsMagmaWithInversesIfNonzero">
##  <ManSection>
##  <Filt Name="IsMagmaWithInversesIfNonzero" Arg='obj' Type='Category'/>
##
##  <Description>
##  An object in this &GAP; category is a magma-with-one <M>M</M>
##  with an operation
##  <C>^-1</C><M>: M \setminus Z \rightarrow M \setminus Z</M>
##  that maps each element <M>m</M> of <M>M \setminus Z</M> to its inverse
##  <M>m</M><C>^-1</C>
##  (or <C>Inverse( </C><M>m</M><C> )</C>, see&nbsp;<Ref Attr="Inverse"/>),
##  where <M>Z</M> is either empty or consists exactly of one element of
##  <M>M</M>.
##  <P/>
##  This category was introduced mainly to describe division rings,
##  since the nonzero elements in a division ring form a group;
##  So an object <M>M</M> in <Ref Filt="IsMagmaWithInversesIfNonzero"/>
##  will usually have both a multiplicative and an additive structure
##  (see&nbsp;<Ref Chap="Additive Magmas"/>),
##  and the set <M>Z</M>, if it is nonempty, contains exactly the zero
##  element (see&nbsp;<Ref Attr="Zero"/>) of <M>M</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsMagmaWithInversesIfNonzero",
    IsMagmaWithOne and IsMultiplicativeElementWithOneCollection );


#############################################################################
##
#C  IsMagmaWithInverses( <obj> )
##
##  <#GAPDoc Label="IsMagmaWithInverses">
##  <ManSection>
##  <Filt Name="IsMagmaWithInverses" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>magma-with-inverses</E> in &GAP; is a magma-with-one <M>M</M> with
##  an operation <C>^-1</C><M>: M \rightarrow M</M> that maps each element
##  <M>m</M> of <M>M</M> to its inverse <M>m</M><C>^-1</C>
##  (or <C>Inverse( </C><M>m</M><C> )</C>, see&nbsp;<Ref Attr="Inverse"/>).
##  <P/>
##  Note that not every trivial magma is a magma-with-one,
##  but every trivial magma-with-one is a magma-with-inverses.
##  This holds also if the identity of the magma-with-one is a zero element.
##  So a magma-with-inverses-if-nonzero can be a magma-with-inverses
##  if either it contains no zero element or consists of a zero element that
##  has itself as zero-th power.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsMagmaWithInverses",
        IsMagmaWithInversesIfNonzero
    and IsMultiplicativeElementWithInverseCollection );

# FIXME: this is wrong for empty magmas
# InstallTrueMethod( IsMagmaWithInverses,
#     IsFiniteOrderElementCollection and IsMagma );

InstallTrueMethod( IsMagmaWithInverses,
    IsFiniteOrderElementCollection and IsMagmaWithOne );


#############################################################################
##
#a  One( <D> )
##
##  (see the description in `arith.gd')
##
DeclareAttribute( "One",
    IsDomain and IsMultiplicativeElementWithOneCollection );


#############################################################################
##
#F  Magma( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="Magma">
##  <ManSection>
##  <Func Name="Magma" Arg='[Fam, ]gens'/>
##
##  <Description>
##  returns the magma <M>M</M> that is generated by the elements
##  in the list <A>gens</A>, that is,
##  the closure of <A>gens</A> under multiplication <Ref Oper="\*"/>.
##  The family <A>Fam</A> of <M>M</M> can be entered as the first argument;
##  this is obligatory if <A>gens</A> is empty
##  (and hence also <M>M</M> is empty).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Magma" );


#############################################################################
##
#F  MagmaWithOne( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="MagmaWithOne">
##  <ManSection>
##  <Func Name="MagmaWithOne" Arg='[Fam, ]gens'/>
##
##  <Description>
##  returns the magma-with-one <M>M</M> that is generated by the elements
##  in the list <A>gens</A>, that is,
##  the closure of <A>gens</A> under multiplication <Ref Oper="\*"/> and
##  <Ref Attr="One"/>.
##  The family <A>Fam</A> of <M>M</M> can be entered as first argument;
##  this is obligatory if <A>gens</A> is empty
##  (and hence <M>M</M> is trivial).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MagmaWithOne" );


#############################################################################
##
#F  MagmaWithInverses( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="MagmaWithInverses">
##  <ManSection>
##  <Func Name="MagmaWithInverses" Arg='[Fam, ]gens'/>
##
##  <Description>
##  returns the magma-with-inverses <M>M</M> that is generated by the
##  elements in the list <A>gens</A>, that is,
##  the closure of <A>gens</A> under multiplication <Ref Oper="\*"/>,
##  <Ref Attr="One"/>, and <Ref Attr="Inverse"/>.
##  The family <A>Fam</A> of <M>M</M> can be entered as first argument;
##  this is obligatory if <A>gens</A> is empty
##  (and hence <M>M</M> is trivial).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MagmaWithInverses" );


#############################################################################
##
#O  MagmaByGenerators( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="MagmaByGenerators">
##  <ManSection>
##  <Oper Name="MagmaByGenerators" Arg='[Fam, ]gens'/>
##
##  <Description>
##  An underlying operation for <Ref Func="Magma"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MagmaByGenerators", [ IsCollection ] );


#############################################################################
##
#O  MagmaWithOneByGenerators( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="MagmaWithOneByGenerators">
##  <ManSection>
##  <Oper Name="MagmaWithOneByGenerators" Arg='[Fam, ]gens'/>
##
##  <Description>
##  An underlying operation for <Ref Func="MagmaWithOne"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MagmaWithOneByGenerators", [ IsCollection ] );


#############################################################################
##
#O  MagmaWithInversesByGenerators( [<Fam>, ]<gens> )
##
##  <#GAPDoc Label="MagmaWithInversesByGenerators">
##  <ManSection>
##  <Oper Name="MagmaWithInversesByGenerators" Arg='[Fam, ]gens'/>
##
##  <Description>
##  An underlying operation for <Ref Func="MagmaWithInverses"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MagmaWithInversesByGenerators", [ IsCollection ] );


#############################################################################
##
#F  Submagma( <D>, <gens> )
#F  SubmagmaNC( <D>, <gens> )
##
##  <#GAPDoc Label="Submagma">
##  <ManSection>
##  <Func Name="Submagma" Arg='D, gens'/>
##  <Func Name="SubmagmaNC" Arg='D, gens'/>
##
##  <Description>
##  <Ref Func="Submagma"/> returns the magma generated by
##  the elements in the list <A>gens</A>, with parent the domain <A>D</A>.
##  <Ref Func="SubmagmaNC"/> does the same, except that it is not checked
##  whether the elements of <A>gens</A> lie in <A>D</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Submagma" );

DeclareGlobalFunction( "SubmagmaNC" );


#############################################################################
##
#F  SubmagmaWithOne( <D>, <gens> )
#F  SubmagmaWithOneNC( <D>, <gens> )
##
##  <#GAPDoc Label="SubmagmaWithOne">
##  <ManSection>
##  <Func Name="SubmagmaWithOne" Arg='D, gens'/>
##  <Func Name="SubmagmaWithOneNC" Arg='D, gens'/>
##
##  <Description>
##  <Ref Func="SubmagmaWithOne"/> returns the magma-with-one generated by
##  the elements in the list <A>gens</A>, with parent the domain <A>D</A>.
##  <Ref Func="SubmagmaWithOneNC"/> does the same, except that it is not
##  checked whether the elements of <A>gens</A> lie in <A>D</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubmagmaWithOne" );

DeclareGlobalFunction( "SubmagmaWithOneNC" );


#############################################################################
##
#F  SubmagmaWithInverses( <D>, <gens> )
#F  SubmagmaWithInversesNC( <D>, <gens> )
##
##  <#GAPDoc Label="SubmagmaWithInverses">
##  <ManSection>
##  <Func Name="SubmagmaWithInverses" Arg='D, gens'/>
##  <Func Name="SubmagmaWithInversesNC" Arg='D, gens'/>
##
##  <Description>
##  <Ref Func="SubmagmaWithInverses"/> returns the magma-with-inverses
##  generated by the elements in the list <A>gens</A>,
##  with parent the domain <A>D</A>.
##  <Ref Func="SubmagmaWithInversesNC"/> does the same,
##  except that it is not checked whether the elements of <A>gens</A>
##  lie in <A>D</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubmagmaWithInverses" );

DeclareGlobalFunction( "SubmagmaWithInversesNC" );


#############################################################################
##
#A  AsMagma( <C> )  . . . . . . . . . . . . . .  view a collection as a magma
##
##  <#GAPDoc Label="AsMagma">
##  <ManSection>
##  <Attr Name="AsMagma" Arg='C'/>
##
##  <Description>
##  For a collection <A>C</A> whose elements form a magma,
##  <Ref Attr="AsMagma"/> returns this magma.
##  Otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AsMagma", IsCollection );


#############################################################################
##
#O  AsSubmagma( <D>, <C> )  . . . view a collection as a submagma of a domain
##
##  <#GAPDoc Label="AsSubmagma">
##  <ManSection>
##  <Oper Name="AsSubmagma" Arg='D, C'/>
##
##  <Description>
##  Let <A>D</A> be a domain and <A>C</A> a collection.
##  If <A>C</A> is a subset of <A>D</A> that forms a magma then
##  <Ref Oper="AsSubmagma"/> returns this magma, with parent <A>D</A>.
##  Otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsSubmagma", [ IsDomain, IsCollection ] );


#############################################################################
##
#A  GeneratorsOfMagma( <M> )
##
##  <#GAPDoc Label="GeneratorsOfMagma">
##  <ManSection>
##  <Attr Name="GeneratorsOfMagma" Arg='M'/>
##
##  <Description>
##  is a list <A>gens</A> of elements of the magma <A>M</A> that generates
##  <A>M</A> as a magma, that is,
##  the closure of <A>gens</A> under multiplication <Ref Oper="\*"/>
##  is <A>M</A>.
##  <P/>
##  For a free magma, each generator can also be accessed using
##  the <C>.</C> operator (see <Ref Attr="GeneratorsOfDomain"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfMagma", IsMagma );


#############################################################################
##
#A  GeneratorsOfMagmaWithOne( <M> )
##
##  <#GAPDoc Label="GeneratorsOfMagmaWithOne">
##  <ManSection>
##  <Attr Name="GeneratorsOfMagmaWithOne" Arg='M'/>
##
##  <Description>
##  is a list <A>gens</A> of elements of the magma-with-one <A>M</A> that
##  generates <A>M</A> as a magma-with-one,
##  that is, the closure of <A>gens</A> under multiplication <Ref Oper="\*"/>
##  and <Ref Attr="One"/> is <A>M</A>.
##  <P/>
##  For a free magma with one, each generator can also be accessed using
##  the <C>.</C> operator (see <Ref Attr="GeneratorsOfDomain"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfMagmaWithOne", IsMagmaWithOne );


#############################################################################
##
#A  GeneratorsOfMagmaWithInverses( <M> )
##
##  <#GAPDoc Label="GeneratorsOfMagmaWithInverses">
##  <ManSection>
##  <Attr Name="GeneratorsOfMagmaWithInverses" Arg='M'/>
##
##  <Description>
##  is a list <A>gens</A> of elements of the magma-with-inverses <A>M</A>
##  that generates <A>M</A> as a magma-with-inverses,
##  that is, the closure of <A>gens</A> under multiplication <Ref Oper="\*"/>
##  and taking inverses (see&nbsp;<Ref Attr="Inverse"/>) is <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfMagmaWithInverses", IsMagmaWithInverses );


#############################################################################
##
#P  IsGeneratorsOfMagmaWithInverses( <gens> )
##
##  <ManSection>
##  <Prop Name="IsGeneratorsOfMagmaWithInverses" Arg='gens'/>
##
##  <Description>
##  <Ref Func="IsGeneratorsOfMagmaWithInverses"/> returns <K>true</K> if the
##  elements in the list or collection <A>gens</A> generate a magma with
##  inverses, and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
#TODO: Decide: Is this property meaningful in nonassociative situations?
##     (cf. the discussion for issue 4480)
##
DeclareProperty( "IsGeneratorsOfMagmaWithInverses", IsListOrCollection );


#############################################################################
##
#A  TrivialSubmagmaWithOne( <M> ) . . . . . . . . . . .  for a magma-with-one
##
##  <#GAPDoc Label="TrivialSubmagmaWithOne">
##  <ManSection>
##  <Attr Name="TrivialSubmagmaWithOne" Arg='M'/>
##
##  <Description>
##  is the magma-with-one that has the identity of the magma-with-one
##  <A>M</A> as only element.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TrivialSubmagmaWithOne", IsMagmaWithOne );


#############################################################################
##
#P  IsAssociative( <M> )  . . . . .  test whether a collection is associative
##
##  <#GAPDoc Label="IsAssociative">
##  <ManSection>
##  <Prop Name="IsAssociative" Arg='M'/>
##
##  <Description>
##  A collection <A>M</A> of elements that can be multiplied via
##  <Ref Oper="\*"/>
##  is <E>associative</E> if for all elements
##  <M>a, b, c \in</M> <A>M</A> the equality
##  <M>(a</M><C> * </C><M>b)</M><C> * </C><M>c =
##  a</M><C> * </C><M>(b</M><C> * </C><M>c)</M> holds.
##  <P/>
##  An associative magma is called a <E>semigroup</E>
##  (see&nbsp;<Ref Chap="Semigroups"/>),
##  an associative magma-with-one is called a <E>monoid</E>
##  (see&nbsp;<Ref Chap="Semigroups"/>),
##  and an associative magma-with-inverses is called a <E>group</E>
##  (see&nbsp;<Ref Chap="Groups"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsAssociative", IsCollection );

InstallTrueMethod( IsAssociative, IsAssociativeElementCollection );

InstallSubsetMaintenance( IsAssociative,
    IsMagma and IsAssociative, IsMagma );

InstallFactorMaintenance( IsAssociative,
    IsMagma and IsAssociative, IsObject, IsMagma );

InstallTrueMethod( IsAssociative, IsMagma and IsTrivial );


#############################################################################
##
#P  IsCommutative( <M> )  . . . . .  test whether a collection is commutative
#P  IsAbelian( <M> )
##
##  <#GAPDoc Label="IsCommutative">
##  <ManSection>
##  <Prop Name="IsCommutative" Arg='M'/>
##  <Prop Name="IsAbelian" Arg='M'/>
##
##  <Description>
##  A collection <A>M</A> of elements that can be multiplied via
##  <Ref Oper="\*"/>
##  is <E>commutative</E> if for all elements
##  <M>a, b \in</M> <A>M</A> the
##  equality <M>a</M><C> * </C><M>b = b</M><C> * </C><M>a</M> holds.
##  <Ref Prop="IsAbelian"/> is a synonym of <Ref Prop="IsCommutative"/>.
##  <P/>
##  Note that the commutativity of the <E>addition</E> <Ref Oper="\+"/> in an
##  additive structure can be tested with
##  <Ref Prop="IsAdditivelyCommutative"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsCommutative", IsCollection );

DeclareSynonymAttr( "IsAbelian", IsCommutative );

InstallTrueMethod( IsCommutative, IsCommutativeElementCollection );

InstallSubsetMaintenance( IsCommutative,
    IsMagma and IsCommutative, IsMagma );

InstallFactorMaintenance( IsCommutative,
    IsMagma and IsCommutative, IsObject, IsMagma );

InstallTrueMethod( IsCommutative, IsMagma and IsTrivial );


#############################################################################
##
#P  IsFinitelyGeneratedMagma( <M> ) . . . . test whether a magma is fin. gen.
##
##  <#GAPDoc Label="IsFinitelyGeneratedMagma">
##  <ManSection>
##  <Prop Name="IsFinitelyGeneratedMagma" Arg='M'/>
##
##  <Description>
##  A magma <A>M</A> is <E>finitely generated</E> if there is a finite subset
##  <M>X</M> of the magma such that every element of the magma can be written
##  as a product of the elements of <M>X</M>.
##  <P/>
##  Note that this is a pure existence statement. Even if a magma is known to
##  be generated by a finite number of elements, it can be very hard or even
##  impossible to obtain such a generating set if it is not known.
##  <P/>
##  Also note that the notion of being finitely generated is independent of
##  whether the magma is considered as a magma, a magma-with-one or a
##  magma-with-inverses.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFinitelyGeneratedMagma", IsMagma );
InstallTrueMethod( IsMagma, IsFinitelyGeneratedMagma );

InstallFactorMaintenance( IsFinitelyGeneratedMagma,
    IsMagma and IsFinitelyGeneratedMagma, IsObject, IsMagma );

InstallTrueMethod( IsFinitelyGeneratedMagma, IsMagma and IsFinite );


#############################################################################
##
#A  MultiplicativeNeutralElement( <M> )
##
##  <#GAPDoc Label="MultiplicativeNeutralElement">
##  <ManSection>
##  <Attr Name="MultiplicativeNeutralElement" Arg='M'/>
##
##  <Description>
##  returns the element <M>e</M> in the magma <A>M</A> with the property that
##  <M>e</M><C> * </C><M>m = m = m</M><C> * </C><M>e</M> holds for all
##  <M>m \in</M> <A>M</A>,
##  if such an element exists.
##  Otherwise <K>fail</K> is returned.
##  <P/>
##  A magma that is not a magma-with-one can have a multiplicative neutral
##  element <M>e</M>;
##  in this case, <M>e</M> <E>cannot</E> be obtained as
##  <C>One( <A>M</A> )</C>, see&nbsp;<Ref Attr="One"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MultiplicativeNeutralElement", IsMagma );


#############################################################################
##
#A  Centre( <M> ) . . . . . . . . . . . . . . . . . . . . . centre of a magma
#A  Center( <M> ) . . . . . . . . . . . . . . . . . . . . . centre of a magma
##
##  <#GAPDoc Label="Centre">
##  <ManSection>
##  <Attr Name="Centre" Arg='M'/>
##  <Attr Name="Center" Arg='M'/>
##
##  <Description>
##  <Ref Attr="Centre"/> returns the <E>centre</E> of the magma <A>M</A>,
##  i.e., the domain of those elements <A>m</A> <M>\in</M> <A>M</A>
##  that commute and associate with all elements of <A>M</A>.
##  That is, the set
##  <M>\{ m \in M; \forall a, b \in M: ma = am,
##  (ma)b = m(ab), (am)b = a(mb), (ab)m = a(bm) \}</M>.
##  <P/>
##  <Ref Attr="Center"/> is just a synonym for <Ref Attr="Centre"/>.
##  <P/>
##  For associative magmas we have that
##  <C>Centre( <A>M</A> ) = Centralizer( <A>M</A>, <A>M</A> )</C>,
##  see&nbsp;<Ref Oper="Centralizer" Label="for a magma and a submagma"/>.
##  <P/>
##  The centre of a magma is always commutative
##  (see&nbsp;<Ref Prop="IsCommutative"/>).
##  (When one installs a new method for <Ref Attr="Centre"/>,
##  one should set the <Ref Prop="IsCommutative"/> value of the result to
##  <K>true</K>, in order to make this information available.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Centre", IsMagma );

DeclareSynonymAttr( "Center", Centre );


#############################################################################
##
#A  Idempotents( <M> )
##
##  <#GAPDoc Label="Idempotents">
##  <ManSection>
##  <Attr Name="Idempotents" Arg='M'/>
##
##  <Description>
##  The set of elements of <A>M</A> which are their own squares.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Idempotents", IsMagma );


#############################################################################
##
#O  IsCentral( <M>, <obj> ) . .  test whether an object is central in a magma
##
##  <#GAPDoc Label="IsCentral">
##  <ManSection>
##  <Oper Name="IsCentral" Arg='M, obj'/>
##
##  <Description>
##  <Ref Oper="IsCentral"/> returns <K>true</K> if the object <A>obj</A>,
##  which must either be an element or a magma,
##  commutes with all elements in the magma <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsCentral", [ IsMagma, IsObject ] );


#############################################################################
##
#O  Centralizer( <M>, <elm> )
#O  Centralizer( <M>, <S> )
#A  Centralizer( <class> )
##
##  <#GAPDoc Label="Centralizer">
##  <ManSection>
##  <Heading>Centralizer</Heading>
##  <Oper Name="Centralizer" Arg='M, elm'
##   Label="for a magma and an element"/>
##  <Oper Name="Centralizer" Arg='M, S'
##   Label="for a magma and a submagma"/>
##  <Attr Name="Centralizer" Arg='class'
##   Label="for a class of objects in a magma"/>
##
##  <Description>
##  <Index>centraliser</Index><Index>center</Index>
##  For an element <A>elm</A> of the magma <A>M</A> this operation returns
##  the  <E>centralizer</E> of <A>elm</A>.
##  This is the domain of those elements <A>m</A> <M>\in</M> <A>M</A>
##  that commute  with <A>elm</A>.
##  <P/>
##  For a submagma <A>S</A> it returns the domain of those elements that
##  commute with <E>all</E> elements <A>s</A> of <A>S</A>.
##  <P/>
##  If <A>class</A> is a class of objects of a magma (this magma then is
##  stored as the <C>ActingDomain</C> of <A>class</A>)
##  such as given by <Ref Oper="ConjugacyClass"/>,
##  <Ref Oper="Centralizer" Label="for a magma and an element"/> returns the
##  centralizer of <C>Representative(<A>class</A>)</C> (which is a slight
##  abuse of the notation).
##  <!-- do we really want this?-->
##  <!-- (we may be interested in using the <E>attribute</E> also for conjugacy classes,-->
##  <!-- but also the <E>function</E>?)-->
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> Centralizer(g,(1,2,3));
##  Group([ (1,2,3) ])
##  gap> Centralizer(g,Subgroup(g,[(1,2,3)]));
##  Group([ (1,2,3) ])
##  gap> Centralizer(g,Subgroup(g,[(1,2,3),(1,2)]));
##  Group(())
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InParentFOA( "Centralizer", IsMagma, IsObject, DeclareAttribute );


#############################################################################
##
#O  SquareRoots( <M>, <elm> )
##
##  <#GAPDoc Label="SquareRoots">
##  <ManSection>
##  <Oper Name="SquareRoots" Arg='M, elm'/>
##
##  <Description>
##  is the proper set of all elements <M>r</M> in the magma <A>M</A>
##  such that <M>r * r =</M> <A>elm</A> holds.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SquareRoots", [ IsMagma, IsMultiplicativeElement ] );


################################################################################
##
DeclareGlobalFunction("FreeXArgumentProcessor");


#############################################################################
##
#F  FreeMagma( <rank>[, <name>] )
#F  FreeMagma( <name1>[, <name2>[, ...]] )
#F  FreeMagma( <names> )
#F  FreeMagma( infinity[, <name>][, <init>] )
##
##  <#GAPDoc Label="FreeMagma">
##  <ManSection>
##  <Heading>FreeMagma</Heading>
##  <Func Name="FreeMagma" Arg='rank[, name]'
##   Label="for given rank"/>
##  <Func Name="FreeMagma" Arg='name1[, name2[, ...]]'
##   Label="for various names"/>
##  <Func Name="FreeMagma" Arg='names'
##   Label="for a list of names"/>
##  <Func Name="FreeMagma" Arg='infinity[, name][, init]'
##   Label="for infinitely many generators"/>
##
##  <Description>
##  <C>FreeMagma</C> returns a free magma. The number of
##  generators, and the labels given to the generators, can be specified in
##  several different ways.
##  Warning: the labels of generators are only an aid for printing,
##  and do not necessarily distinguish generators;
##  see the examples at the end of
##  <Ref Func="FreeSemigroup" Label="for given rank"/>
##  for more information.
##  <List>
##    <Mark>
##      1: For a given rank, and an optional generator name prefix
##    </Mark>
##    <Item>
##      Called with a positive integer <A>rank</A>,
##      <Ref Func="FreeMagma" Label="for given rank"/> returns
##      a free magma on <A>rank</A> generators.
##      The optional argument <A>name</A> must be a string;
##      its default value is <C>"x"</C>. <P/>
##
##      If <A>name</A> is not given but the <C>generatorNames</C> option is,
##      then this option is respected as described in
##      Section&nbsp;<Ref Sect="Generator Names"/>. <P/>
##
##      Otherwise, the generators of the returned free magma are labelled
##      <A>name</A><C>1</C>, ..., <A>name</A><C>k</C>,
##      where <C>k</C> is the value of <A>rank</A>. <P/>
##    </Item>
##    <Mark>2: For given generator names</Mark>
##    <Item>
##      Called with various (at least one) nonempty strings,
##      <Ref Func="FreeMagma" Label="for various names"/> returns
##      a free magma on as many generators as arguments, which are labelled
##      <A>name1</A>, <A>name2</A>, etc.
##    </Item>
##    <Mark>3: For a given list of generator names</Mark>
##    <Item>
##      Called with a finite nonempty list <A>names</A> of
##      nonempty strings,
##      <Ref Func="FreeMagma" Label="for a list of names"/> returns
##      a free magma on <C>Length(<A>names</A>)</C> generators, whose
##      <C>i</C>-th generator is labelled <A>names</A><C>[i]</C>.
##    </Item>
##    <Mark>
##      4: For the rank <K>infinity</K>,
##         an optional default generator name prefix,
##         and an optional finite list of generator names
##    </Mark>
##    <Item>
##      Called in the fourth form,
##      <Ref Func="FreeMagma" Label="for infinitely many generators"/>
##      returns a free magma on infinitely many generators.
##      The optional argument <A>name</A> must be a string; its default value is
##      <C>"x"</C>,
##      and the optional argument <A>init</A> must be a finite list of
##      nonempty strings; its default value is an empty list.
##      The generators are initially labelled according to the list <A>init</A>,
##      followed by
##      <A>name</A><C>i</C> for each <C>i</C> in the range from
##      <C>Length(<A>init</A>)+1</C> to <K>infinity</K>.
##    </Item>
##  </List>
##  <Example><![CDATA[
##  gap> FreeMagma( 4 );
##  <free magma on the generators [ x1, x2, x3, x4 ]>
##  gap> FreeMagma( 3, "a" );
##  <free magma on the generators [ a1, a2, a3 ]>
##  gap> FreeMagma( "a", "b" );
##  <free magma on the generators [ a, b ]>
##  gap> FreeMagma( [ "a", "b" ] );
##  <free magma on the generators [ a, b ]>
##  gap> FreeMagma( infinity );
##  <free magma with infinity generators>
##  gap> F := FreeMagma( infinity, "gen" );;
##  gap> GeneratorsOfMagma( F ){[ 1 .. 4 ]};
##  [ gen1, gen2, gen3, gen4 ]
##  gap> F := FreeMagma( infinity, [ "z", "a" ] );;
##  gap> GeneratorsOfMagma( F ){[ 1 .. 3 ]};
##  [ z, a, x3 ]
##  gap> F := FreeMagma( infinity, "y", [ "z", "a" ] );;
##  gap> GeneratorsOfMagma( F ){[ 1 .. 4 ]};
##  [ z, a, y3, y4 ]
##  gap> FreeMagma( 3 : generatorNames := "elt" );
##  <free magma on the generators [ elt1, elt2, elt3 ]>
##  gap> FreeMagma( 2 : generatorNames := [ "u", "v", "w" ] );
##  <free magma on the generators [ u, v ]>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeMagma" );


#############################################################################
##
#F  FreeMagmaWithOne( <rank>[, <name>] )
#F  FreeMagmaWithOne( [<name1>[, <name2>[, ...]]] )
#F  FreeMagmaWithOne( <names> )
#F  FreeMagmaWithOne( infinity[, <name>][, <init>] )
##
##  <#GAPDoc Label="FreeMagmaWithOne">
##  <ManSection>
##  <Heading>FreeMagmaWithOne</Heading>
##  <Func Name="FreeMagmaWithOne" Arg='rank[, name]'
##   Label="for given rank"/>
##  <Func Name="FreeMagmaWithOne" Arg='[name1[, name2[, ...]]]'
##   Label="for various names"/>
##  <Func Name="FreeMagmaWithOne" Arg='names'
##   Label="for a list of names"/>
##  <Func Name="FreeMagmaWithOne" Arg='infinity[, name][, init]'
##   Label="for infinitely many generators"/>
##
##  <Description>
##  <C>FreeMagmaWithOne</C> returns a free magma-with-one. The number of
##  generators, and the labels given to the generators, can be specified in
##  several different ways.
##  Warning: the labels of generators are only an aid for printing,
##  and do not necessarily distinguish generators;
##  see the examples at the end of
##  <Ref Func="FreeSemigroup" Label="for given rank"/>
##  for more information.
##  <List>
##    <Mark>
##      1: For a given rank, and an optional generator name prefix
##    </Mark>
##    <Item>
##      Called with a nonnegative integer <A>rank</A>,
##      <Ref Func="FreeMagmaWithOne" Label="for given rank"/> returns
##      a free magma-with-one on <A>rank</A> generators.
##      The optional argument <A>name</A> must be a string;
##      its default value is <C>"x"</C>. <P/>
##
##      If <A>name</A> is not given but the <C>generatorNames</C> option is,
##      then this option is respected as described in
##      Section&nbsp;<Ref Sect="Generator Names"/>. <P/>
##
##      Otherwise, the generators of the returned free magma-with-one are
##      labelled <A>name</A><C>1</C>, ..., <A>name</A><C>k</C>,
##      where <C>k</C> is the value of <A>rank</A>. <P/>
##    </Item>
##    <Mark>2: For given generator names</Mark>
##    <Item>
##      Called with various nonempty strings,
##      <Ref Func="FreeMagmaWithOne" Label="for various names"/> returns
##      a free magma-with-one on as many generators as arguments, which are
##      labelled <A>name1</A>, <A>name2</A>, etc.
##    </Item>
##    <Mark>3: For a given list of generator names</Mark>
##    <Item>
##      Called with a finite list <A>names</A> of
##      nonempty strings,
##      <Ref Func="FreeMagmaWithOne" Label="for a list of names"/> returns
##      a free magma-with-one on <C>Length(<A>names</A>)</C> generators, whose
##      <C>i</C>-th generator is labelled <A>names</A><C>[i]</C>.
##    </Item>
##    <Mark>
##      4: For the rank <K>infinity</K>,
##         an optional default generator name prefix,
##         and an optional finite list of generator names
##    </Mark>
##    <Item>
##      Called in the fourth form,
##      <Ref Func="FreeMagmaWithOne" Label="for infinitely many generators"/>
##      returns a free magma-with-one on infinitely many generators.
##      The optional argument <A>name</A> must be a string; its default value is
##      <C>"x"</C>,
##      and the optional argument <A>init</A> must be a finite list of
##      nonempty strings; its default value is an empty list.
##      The generators are initially labelled according to the list <A>init</A>,
##      followed by
##      <A>name</A><C>i</C> for each <C>i</C> in the range from
##      <C>Length(<A>init</A>)+1</C> to <K>infinity</K>.
##    </Item>
##  </List>
##  <Example><![CDATA[
##  gap> FreeMagmaWithOne( 4 );
##  <free magma-with-one on the generators [ x1, x2, x3, x4 ]>
##  gap> FreeMagmaWithOne( 3, "a" );
##  <free magma-with-one on the generators [ a1, a2, a3 ]>
##  gap> FreeMagmaWithOne( "a", "b" );
##  <free magma-with-one on the generators [ a, b ]>
##  gap> FreeMagmaWithOne( [ "a", "b" ] );
##  <free magma-with-one on the generators [ a, b ]>
##  gap> FreeMagmaWithOne( infinity );
##  <free magma-with-one with infinity generators>
##  gap> F := FreeMagmaWithOne( infinity, "gen" );;
##  gap> GeneratorsOfMagmaWithOne( F ){[ 1 .. 4 ]};
##  [ gen1, gen2, gen3, gen4 ]
##  gap> F := FreeMagmaWithOne( infinity, [ "z", "a" ] );;
##  gap> GeneratorsOfMagmaWithOne( F ){[ 1 .. 3 ]};
##  [ z, a, x3 ]
##  gap> F := FreeMagmaWithOne( infinity, "y", [ "z", "a" ] );;
##  gap> GeneratorsOfMagmaWithOne( F ){[ 1 .. 4 ]};
##  [ z, a, y3, y4 ]
##  gap> FreeMagmaWithOne( 0 );
##  <free group of rank zero>
##  gap> FreeMagmaWithOne( 3 : generatorNames := "elt" );
##  <free magma-with-one on the generators [ elt1, elt2, elt3 ]>
##  gap> FreeMagmaWithOne( 2 : generatorNames := [ "u", "v", "w" ] );
##  <free magma-with-one on the generators [ u, v ]>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeMagmaWithOne" );


#############################################################################
##
#F  IsCommutativeFromGenerators( <GeneratorsOfStruct> )
##
##  <ManSection>
##  <Func Name="IsCommutativeFromGenerators" Arg='GeneratorsOfStruct'/>
##
##  <Description>
##  is a function that takes one domain argument <A>D</A> and checks whether
##  <C><A>GeneratorsOfStruct</A>( <A>D</A> )</C> commute.
##  </Description>
##  </ManSection>
##
BindGlobal( "IsCommutativeFromGenerators", function( GeneratorsStruct )
    return function( D )

    local gens,   # list of generators
          i, j;   # loop variables

    # Test if every element commutes with all the others.
    gens:= GeneratorsStruct( D );
    for i in [ 2 .. Length( gens ) ] do
      for j in [ 1 .. i-1 ] do
        if gens[i] * gens[j] <> gens[j] * gens[i] then
          return false;
        fi;
      od;
    od;

    # All generators commute.
    return true;
    end;
end );


#############################################################################
##
#F  IsCentralFromGenerators( <GeneratorsStruct1>, <GeneratorsStruct2> )
##
##  <ManSection>
##  <Func Name="IsCentralFromGenerators" Arg='GeneratorsStruct1, GeneratorsStruct2'/>
##
##  <Description>
##  is a function which returns a function that takes two domain arguments <A>D1</A>,
##  <A>D2</A> and checks whether <C><A>GeneratorsStruct1</A>( <A>D1</A> )</C>
##  and <C><A>GeneratorsStruct2</A>( <A>D2</A> )</C> commute.
##  </Description>
##  </ManSection>
##
BindGlobal( "IsCentralFromGenerators",
    function( GeneratorsStruct1, GeneratorsStruct2 )
    return function( D1, D2 )
    local g1, g2;
    for g1 in GeneratorsStruct1( D1 ) do
      for g2 in GeneratorsStruct2( D2 ) do
        if g1 * g2 <> g2 * g1 then
          return false;
        fi;
      od;
    od;
    return true;
    end;
end );


#############################################################################
##
#F  IsCentralElementFromGenerators( <GeneratorsStruct> )
##
##  <ManSection>
##  <Func Name="IsCentralElementFromGenerators" Arg='GeneratorsStruct'/>
##
##  <Description>
##  is a function which returns a function that takes a domain argument
##  <A>D</A>  and an object <A>obj</A> and checks whether
##  <C><A>GeneratorsStruct</A>( <A>D</A> )</C> and <A>obj</A> commute.
##  </Description>
##  </ManSection>
##
BindGlobal( "IsCentralElementFromGenerators",
    function( GeneratorsStruct )
    return function( D, obj )
    local g;
    for g in GeneratorsStruct( D ) do
      if g * obj <> obj * g then
        return false;
      fi;
    od;
    return true;
    end;
end );


#############################################################################
##
#A  MagmaGeneratorsOfFamily( <Fam> )
##
##  <ManSection>
##  <Attr Name="MagmaGeneratorsOfFamily" Arg='Fam'/>
##
##  <Description>
##  For a family <A>Fam</A> of words in a free magma, free magma-with-one,
##  free semigroup, free monoid, or free group,
##  <C>MagmaGeneratorsOfFamily</C> returns a list of magma generators for the
##  free object that contains each element in <A>Fam</A>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "MagmaGeneratorsOfFamily", IsFamily );
