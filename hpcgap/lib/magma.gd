#############################################################################
##
#W  magma.gd                    GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  <C>^0</C> (or <Ref Func="One"/>) that yields the identity of <M>M</M>.
##  <P/>
##  So a magma-with-one <M>M</M> does always contain a unique
##  multiplicatively neutral element <M>e</M>, i.e.,
##  <M>e</M><C> * </C><M>m = m = m</M><C> * </C><M>e</M> holds
##  for all <M>m \in M</M>
##  (see&nbsp;<Ref Func="MultiplicativeNeutralElement"/>).
##  This element <M>e</M> can be computed with the operation
##  <Ref Oper="One"/> as <C>One( </C><M>M</M><C> )</C>,
##  and <M>e</M> is also equal to <C>One( </C><M>m</M><C> )</C> and to
##  <M>m</M><C>^0</C> for each element <M>m \in M</M>.
##  <P/>
##  <E>Note</E> that a magma may contain a multiplicatively neutral element
##  but <E>not</E> an identity (see&nbsp;<Ref Oper="One"/>),
##  and a magma containing an identity may <E>not</E> lie in the category
##  <Ref Func="IsMagmaWithOne"/>
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
##  So an object <M>M</M> in <Ref Func="IsMagmaWithInversesIfNonzero"/>
##  will usually have both a multiplicative and an additive structure
##  (see&nbsp;<Ref Chap="Additive Magmas"/>),
##  and the set <M>Z</M>, if it is nonempty, contains exactly the zero
##  element (see&nbsp;<Ref Func="Zero"/>) of <M>M</M>.
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
##  (or <C>Inverse( </C><M>m</M><C> )</C>, see&nbsp;<Ref Func="Inverse"/>).
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

InstallTrueMethod( IsMagmaWithInverses,
    IsFiniteOrderElementCollection and IsMagma );

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
##  the closure of <A>gens</A> under multiplication <Ref Func="\*"/>.
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
##  the closure of <A>gens</A> under multiplication <Ref Func="\*"/> and
##  <Ref Func="One"/>.
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
##  the closure of <A>gens</A> under multiplication <Ref Func="\*"/>,
##  <Ref Func="One"/>, and <Ref Func="Inverse"/>.
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
##  <Ref Func="AsMagma"/> returns this magma.
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
##  <Ref Func="AsSubmagma"/> returns this magma, with parent <A>D</A>.
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
##  the closure of <A>gens</A> under multiplication <Ref Func="\*"/>
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
##  that is, the closure of <A>gens</A> under multiplication <Ref Func="\*"/>
##  and <Ref Func="One"/> is <A>M</A>.
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
##  that is, the closure of <A>gens</A> under multiplication <Ref Func="\*"/>
##  and taking inverses (see&nbsp;<Ref Func="Inverse"/>) is <A>M</A>.
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
#P  IsAssociative( <M> )  . . . . . . . . test whether a magma is associative
##
##  <#GAPDoc Label="IsAssociative">
##  <ManSection>
##  <Prop Name="IsAssociative" Arg='M'/>
##
##  <Description>
##  A magma <A>M</A> is <E>associative</E> if for all elements
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
DeclareProperty( "IsAssociative", IsMagma );

InstallTrueMethod( IsAssociative,
    IsAssociativeElementCollection and IsMagma );

InstallSubsetMaintenance( IsAssociative,
    IsMagma and IsAssociative, IsMagma );

InstallFactorMaintenance( IsAssociative,
    IsMagma and IsAssociative, IsObject, IsMagma );

InstallTrueMethod( IsAssociative, IsMagma and IsTrivial );


#############################################################################
##
#P  IsCommutative( <M> )  . . . . . . . . test whether a magma is commutative
#P  IsAbelian( <M> )
##
##  <#GAPDoc Label="IsCommutative">
##  <ManSection>
##  <Prop Name="IsCommutative" Arg='M'/>
##  <Prop Name="IsAbelian" Arg='M'/>
##
##  <Description>
##  A magma <A>M</A> is <E>commutative</E> if for all elements
##  <M>a, b \in</M> <A>M</A> the
##  equality <M>a</M><C> * </C><M>b = b</M><C> * </C><M>a</M> holds.
##  <Ref Prop="IsAbelian"/> is a synonym of <Ref Prop="IsCommutative"/>.
##  <P/>
##  Note that the commutativity of the <E>addition</E> <Ref Func="\+"/> in an
##  additive structure can be tested with
##  <Ref Func="IsAdditivelyCommutative"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsCommutative", IsMagma );

DeclareSynonymAttr( "IsAbelian", IsCommutative );

InstallTrueMethod( IsCommutative,
    IsCommutativeElementCollection and IsMagma );

InstallSubsetMaintenance( IsCommutative,
    IsMagma and IsCommutative, IsMagma );

InstallFactorMaintenance( IsCommutative,
    IsMagma and IsCommutative, IsObject, IsMagma );

InstallTrueMethod( IsCommutative, IsMagma and IsTrivial );


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
##  <C>One( <A>M</A> )</C>, see&nbsp;<Ref Func="One"/>.
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
##  <Ref Func="Centre"/> returns the <E>centre</E> of the magma <A>M</A>,
##  i.e., the domain of those elements <A>m</A> <M>\in</M> <A>M</A>
##  that commute and associate with all elements of <A>M</A>.
##  That is, the set
##  <M>\{ m \in M; \forall a, b \in M: ma = am,
##  (ma)b = m(ab), (am)b = a(mb), (ab)m = a(bm) \}</M>.
##  <P/>
##  <Ref Func="Center"/> is just a synonym for <Ref Func="Centre"/>.
##  <P/>
##  For associative magmas we have that 
##  <C>Centre( <A>M</A> ) = Centralizer( <A>M</A>, <A>M</A> )</C>,
##  see&nbsp;<Ref Func="Centralizer" Label="for a magma and a submagma"/>.
##  <P/>
##  The centre of a magma is always commutative
##  (see&nbsp;<Ref Func="IsCommutative"/>).
##  (When one installs a new method for <Ref Func="Centre"/>,
##  one should set the <Ref Func="IsCommutative"/> value of the result to
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
##  <Ref Func="IsCentral"/> returns <K>true</K> if the object <A>obj</A>,
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
##  such as given by <Ref Func="ConjugacyClass"/>,
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


#############################################################################
##
#F  FreeMagma( <rank>[, <name>] )
#F  FreeMagma( <name1>, <name2>, ... )
#F  FreeMagma( <names> )
#F  FreeMagma( infinity, <name>, <init> )
##
##  <#GAPDoc Label="FreeMagma">
##  <ManSection>
##  <Heading>FreeMagma</Heading>
##  <Func Name="FreeMagma" Arg='rank[, name]'
##   Label="for given rank"/>
##  <Func Name="FreeMagma" Arg='name1, name2, ...'
##   Label="for various names"/>
##  <Func Name="FreeMagma" Arg='names'
##   Label="for a list of names"/>
##  <Func Name="FreeMagma" Arg='infinity, name, init'
##   Label="for infinitely many generators"/>
##
##  <Description>
##  Called with a positive integer <A>rank</A>,
##  <Ref Func="FreeMagma" Label="for given rank"/> returns
##  a free magma on <A>rank</A> generators.
##  If the optional argument <A>name</A> is given then the generators are
##  printed as <A>name</A><C>1</C>, <A>name</A><C>2</C> etc.,
##  that is, each name is the concatenation of the string <A>name</A> and an
##  integer from <C>1</C> to <A>range</A>.
##  The default for <A>name</A> is the string <C>"m"</C>.
##  <P/>
##  Called in the second form,
##  <Ref Func="FreeMagma" Label="for various names"/> returns
##  a free magma on as many generators as arguments, printed as
##  <A>name1</A>, <A>name2</A> etc.
##  <P/>
##  Called in the third form,
##  <Ref Func="FreeMagma" Label="for a list of names"/> returns
##  a free magma on as many generators as the length of the list
##  <A>names</A>, the <M>i</M>-th generator being printed as
##  <A>names</A><C>[</C><M>i</M><C>]</C>.
##  <P/>
##  Called in the fourth form,
##  <Ref Func="FreeMagma" Label="for infinitely many generators"/>
##  returns a free magma on infinitely many generators, where the first
##  generators are printed by the names in the list <A>init</A>,
##  and the other generators by <A>name</A> and an appended number.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeMagma" );


#############################################################################
##
#F  FreeMagmaWithOne( <rank>[, <name>] )
#F  FreeMagmaWithOne( <name1>, <name2>, ... )
#F  FreeMagmaWithOne( <names> )
#F  FreeMagmaWithOne( infinity, <name>, <init> )
##
##  <#GAPDoc Label="FreeMagmaWithOne">
##  <ManSection>
##  <Heading>FreeMagmaWithOne</Heading>
##  <Func Name="FreeMagmaWithOne" Arg='rank[, name]'
##   Label="for given rank"/>
##  <Func Name="FreeMagmaWithOne" Arg='name1, name2, ...'
##   Label="for various names"/>
##  <Func Name="FreeMagmaWithOne" Arg='names'
##   Label="for a list of names"/>
##  <Func Name="FreeMagmaWithOne" Arg='infinity, name, init'
##   Label="for infinitely many generators"/>
##
##  <Description>
##  Called with a positive integer <A>rank</A>,
##  <Ref Func="FreeMagmaWithOne" Label="for given rank"/> returns
##  a free magma-with-one on <A>rank</A> generators.
##  If the optional argument <A>name</A> is given then the generators are
##  printed as <A>name</A><C>1</C>, <A>name</A><C>2</C> etc.,
##  that is, each name is the concatenation of the string <A>name</A> and an
##  integer from <C>1</C> to <A>range</A>.
##  The default for <A>name</A> is the string <C>"m"</C>.
##  <P/>
##  Called in the second form,
##  <Ref Func="FreeMagmaWithOne" Label="for various names"/> returns
##  a free magma-with-one on as many generators as arguments, printed as
##  <A>name1</A>, <A>name2</A> etc.
##  <P/>
##  Called in the third form,
##  <Ref Func="FreeMagmaWithOne" Label="for a list of names"/> returns
##  a free magma-with-one on as many generators as the length of the list
##  <A>names</A>, the <M>i</M>-th generator being printed as
##  <A>names</A><C>[</C><M>i</M><C>]</C>.
##  <P/>
##  Called in the fourth form,
##  <Ref Func="FreeMagmaWithOne" Label="for infinitely many generators"/>
##  returns a free magma-with-one on infinitely many generators, where the
##  first generators are printed by the names in the list <A>init</A>,
##  and the other generators by <A>name</A> and an appended number.
##  <P/>
##  <Example><![CDATA[
##  gap> FreeMagma( 3 );
##  <free magma on the generators [ x1, x2, x3 ]>
##  gap> FreeMagma( "a", "b" );
##  <free magma on the generators [ a, b ]>
##  gap> FreeMagma( infinity );
##  <free magma with infinity generators>
##  gap> FreeMagmaWithOne( 3 );
##  <free magma-with-one on the generators [ x1, x2, x3 ]>
##  gap> FreeMagmaWithOne( "a", "b" );
##  <free magma-with-one on the generators [ a, b ]>
##  gap> FreeMagmaWithOne( infinity );
##  <free magma-with-one with infinity generators>
##  ]]></Example>
##  <P/>
##  Remember that the names of generators used for printing
##  do not necessarily distinguish letters of the alphabet;
##  so it is possible to create arbitrarily weird
##  situations by choosing strange letter names.
##  <P/>
##  <Example><![CDATA[
##  gap> m:= FreeMagma( "x", "x" );  gens:= GeneratorsOfMagma( m );;
##  <free magma on the generators [ x, x ]>
##  gap> gens[1] = gens[2];
##  false
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
##  is a function that takes two domain arguments <A>D1</A>, <A>D2</A> and checks
##  whether <C><A>GeneratorsStruct1</A>( <A>D1</A> )</C> and <C><A>GeneratorsStruct2</A>( <A>D2</A> )</C>
##  commute.
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


#############################################################################
##
#E

