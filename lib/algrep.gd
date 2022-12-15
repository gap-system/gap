#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Willem de Graaf.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for general modules over algebras.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{algrep}">
##  An algebra module is a vector space together with an action of an
##  algebra. So a module over an algebra is constructed by giving generators
##  of a vector space, and a function for calculating the action of
##  algebra elements on elements of the vector space. When creating an
##  algebra module, the generators of the vector space are wrapped up and
##  given the category <C>IsLeftAlgebraModuleElement</C> or
##  <C>IsRightModuleElement</C> if the algebra acts from the left, or right
##  respectively. (So in the case of a bi-module the elements get
##  both categories.) Most linear algebra computations are delegated to
##  the original vector space.
##  <P/>
##  The transition between the original vector space and the corresponding
##  algebra module is handled by <C>ExtRepOfObj</C> and <C>ObjByExtRep</C>.
##  For an element <C>v</C> of the algebra module, <C>ExtRepOfObj( v )</C> returns
##  the underlying element of the original vector space. Furthermore, if <C>vec</C>
##  is an element of the original vector space, and <C>fam</C> the elements
##  family of the corresponding algebra module, then <C>ObjByExtRep( fam, vec )</C>
##  returns the corresponding element of the algebra module. Below is an
##  example of this.
##  <P/>
##  The action of the algebra on elements of the algebra module is constructed
##  by using the operator <C>^</C>. If <C>x</C> is an element of an algebra <C>A</C>, and
##  <C>v</C> an element of a left <C>A</C>-module, then <C>x^v</C> calculates the result
##  of the action of <C>x</C> on <C>v</C>. Similarly, if <C>v</C> is an element of
##  a right <C>A</C>-module, then <C>v^x</C> calculates the action of <C>x</C> on <C>v</C>.
##  <#/GAPDoc>
##

##############################################################################
##
#C  IsAlgebraModuleElement( <obj> )
#C  IsAlgebraModuleElementCollection( <obj> )
#C  IsAlgebraModuleElementFamily( <fam> )
##
##  <#GAPDoc Label="IsAlgebraModuleElement">
##  <ManSection>
##  <Filt Name="IsAlgebraModuleElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsAlgebraModuleElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsAlgebraModuleElementFamily" Arg='fam' Type='Category'/>
##
##  <Description>
##  Category of algebra module elements. If an object has
##  <C>IsAlgebraModuleElementCollection</C>, then it is an algebra module.
##  If a family has <C>IsAlgebraModuleElementFamily</C>, then it is a family
##  of algebra module elements (every algebra module has its own elements
##  family).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsAlgebraModuleElement", IsVector );
DeclareCategoryCollections( "IsAlgebraModuleElement" );
DeclareCategoryFamily( "IsAlgebraModuleElement" );

##############################################################################
##
#C  IsLeftAlgebraModuleElement( <obj> )
#C  IsLeftAlgebraModuleElementCollection( <obj> )
##
##  <#GAPDoc Label="IsLeftAlgebraModuleElement">
##  <ManSection>
##  <Filt Name="IsLeftAlgebraModuleElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsLeftAlgebraModuleElementCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  Category of left algebra module elements. If an object has
##  <C>IsLeftAlgebraModuleElementCollection</C>, then it is a left-algebra module.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsLeftAlgebraModuleElement", IsAlgebraModuleElement );
DeclareCategoryCollections( "IsLeftAlgebraModuleElement" );

##############################################################################
##
#C  IsRightAlgebraModuleElement( <obj> )
#C  IsRightAlgebraModuleElementCollection( <obj> )
##
##  <#GAPDoc Label="IsRightAlgebraModuleElement">
##  <ManSection>
##  <Filt Name="IsRightAlgebraModuleElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsRightAlgebraModuleElementCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  Category of right algebra module elements. If an object has
##  <C>IsRightAlgebraModuleElementCollection</C>, then it is a right-algebra module.
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];
##  ( Rationals^[ 3, 3 ] )
##  gap> M:= BiAlgebraModuleByGenerators( A, A, \*, \*, [ [ 1, 0, 0 ] ] );
##  <bi-module over ( Rationals^[ 3, 3 ] ) (left) and ( Rationals^
##  [ 3, 3 ] ) (right)>
##  gap> vv:= BasisVectors( Basis( M ) );
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
##  gap> IsLeftAlgebraModuleElement( vv[1] );
##  true
##  gap> IsRightAlgebraModuleElement( vv[1] );
##  true
##  gap> vv[1] = [ 1, 0, 0 ];
##  false
##  gap> ExtRepOfObj( vv[1] ) = [ 1, 0, 0 ];
##  true
##  gap> ObjByExtRep( ElementsFamily( FamilyObj( M ) ), [ 1, 0, 0 ] ) in M;
##  true
##  gap> xx:= BasisVectors( Basis( A ) );;
##  gap> xx[4]^vv[1];  # left action
##  [ 0, 1, 0 ]
##  gap> vv[1]^xx[2];  # right action
##  [ 0, 1, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsRightAlgebraModuleElement", IsAlgebraModuleElement );
DeclareCategoryCollections( "IsRightAlgebraModuleElement" );

##############################################################################
##
#P  IsAlgebraModule( <M> )
##
##  <ManSection>
##  <Prop Name="IsAlgebraModule" Arg='M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsAlgebraModule", IsLeftModule );
InstallTrueMethod( IsLeftModule, IsAlgebraModule );

##############################################################################
##
#P  IsLeftAlgebraModule( <M> )
##
##  <ManSection>
##  <Prop Name="IsLeftAlgebraModule" Arg='M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsLeftAlgebraModule", IsLeftModule );
InstallTrueMethod( IsLeftModule, IsLeftAlgebraModule );

##############################################################################
##
#P  IsRightAlgebraModule( <M> )
##
##  <ManSection>
##  <Prop Name="IsRightAlgebraModule" Arg='M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsRightAlgebraModule", IsLeftModule );

##############################################################################
##
#A  LeftActingAlgebra( <V> )
##
##  <#GAPDoc Label="LeftActingAlgebra">
##  <ManSection>
##  <Attr Name="LeftActingAlgebra" Arg='V'/>
##
##  <Description>
##  Here <A>V</A> is a left-algebra module; this function returns the algebra
##  that acts from the left on <A>V</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LeftActingAlgebra", IsAlgebraModule );

#############################################################################
##
#A  RightActingAlgebra( <V> )
##
##  <#GAPDoc Label="RightActingAlgebra">
##  <ManSection>
##  <Attr Name="RightActingAlgebra" Arg='V'/>
##
##  <Description>
##  Here <A>V</A> is a right-algebra module; this function returns the algebra
##  that acts from the right on <A>V</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RightActingAlgebra", IsAlgebraModule );

##############################################################################
##
#O  ActingAlgebra( <V> )
##
##  <#GAPDoc Label="ActingAlgebra">
##  <ManSection>
##  <Oper Name="ActingAlgebra" Arg='V'/>
##
##  <Description>
##  Here <A>V</A> is an algebra module; this function returns the algebra
##  that acts on <A>V</A> (this is the same as <C>LeftActingAlgebra( <A>V</A> )</C> if <A>V</A> is
##  a left module, and <C>RightActingAlgebra( <A>V</A> )</C> if <A>V</A> is a right module;
##  it will signal an error if <A>V</A> is a bi-module).
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];;
##  gap> M:= BiAlgebraModuleByGenerators( A, A, \*, \*, [ [ 1, 0, 0 ] ] );;
##  gap> LeftActingAlgebra( M );
##  ( Rationals^[ 3, 3 ] )
##  gap> RightActingAlgebra( M );
##  ( Rationals^[ 3, 3 ] )
##  gap> V:= RightAlgebraModuleByGenerators( A, \*, [ [ 1, 0, 0 ] ] );;
##  gap> ActingAlgebra( V );
##  ( Rationals^[ 3, 3 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ActingAlgebra", [ IsAlgebraModule ] );


##############################################################################
##
#A  GeneratorsOfAlgebraModule( <M> )
##
##  <#GAPDoc Label="GeneratorsOfAlgebraModule">
##  <ManSection>
##  <Attr Name="GeneratorsOfAlgebraModule" Arg='M'/>
##
##  <Description>
##  A list of elements of <A>M</A> that generate <A>M</A> as an algebra module.
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];;
##  gap> V:= LeftAlgebraModuleByGenerators( A, \*, [ [ 1, 0, 0 ] ] );;
##  gap> GeneratorsOfAlgebraModule( V );
##  [ [ 1, 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfAlgebraModule", IsAlgebraModule );


##############################################################################
##
#O  LeftAlgebraModuleByGenerators( <A>, <op>, <gens> )
##
##  <#GAPDoc Label="LeftAlgebraModuleByGenerators">
##  <ManSection>
##  <Oper Name="LeftAlgebraModuleByGenerators" Arg='A, op, gens'/>
##
##  <Description>
##  Constructs the left algebra module over <A>A</A> generated by the list of
##  vectors
##  <A>gens</A>. The action of <A>A</A> is described by the function <A>op</A>. This must
##  be a function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector; it outputs the result of applying
##  the algebra element to the vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeftAlgebraModuleByGenerators", [ IsAlgebra, IS_FUNCTION,
                                           IsHomogeneousList ]);

##############################################################################
##
#O  RightAlgebraModuleByGenerators( <A>, <op>, <gens> )
##
##  <#GAPDoc Label="RightAlgebraModuleByGenerators">
##  <ManSection>
##  <Oper Name="RightAlgebraModuleByGenerators" Arg='A, op, gens'/>
##
##  <Description>
##  Constructs the right algebra module over <A>A</A> generated by the list of
##  vectors
##  <A>gens</A>. The action of <A>A</A> is described by the function <A>op</A>. This must
##  be a function of two arguments; the first argument is a vector, and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element to the vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RightAlgebraModuleByGenerators", [ IsAlgebra, IS_FUNCTION,
                                           IsHomogeneousList ]);


##############################################################################
##
#O  BiAlgebraModuleByGenerators( <A>, <B>, <opl>, <opr>, <gens> )
##
##  <#GAPDoc Label="BiAlgebraModuleByGenerators">
##  <ManSection>
##  <Oper Name="BiAlgebraModuleByGenerators" Arg='A, B, opl, opr, gens'/>
##
##  <Description>
##  Constructs the algebra bi-module over <A>A</A> and <A>B</A> generated by the list of
##  vectors
##  <A>gens</A>. The left action of <A>A</A> is described by the function <A>opl</A>,
##  and the right action of <A>B</A> by the function <A>opr</A>. <A>opl</A> must be a
##  function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector; it outputs the result of applying
##  the algebra element on the left to the vector. <A>opr</A> must
##  be a function of two arguments; the first argument is a vector, and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element on the right to the vector.
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];
##  ( Rationals^[ 3, 3 ] )
##  gap> V:= LeftAlgebraModuleByGenerators( A, \*, [ [ 1, 0, 0 ] ] );
##  <left-module over ( Rationals^[ 3, 3 ] )>
##  gap> W:= RightAlgebraModuleByGenerators( A, \*, [ [ 1, 0, 0 ] ] );
##  <right-module over ( Rationals^[ 3, 3 ] )>
##  gap> M:= BiAlgebraModuleByGenerators( A, A, \*, \*, [ [ 1, 0, 0 ] ] );
##  <bi-module over ( Rationals^[ 3, 3 ] ) (left) and ( Rationals^
##  [ 3, 3 ] ) (right)>
##  ]]></Example>
##  <P/>
##  In the above examples, the modules <C>V</C>, <C>W</C>, and <C>M</C> are
##  <M>3</M>-dimensional vector spaces over the rationals.
##  The algebra <C>A</C> acts from the left on <C>V</C>, from the right on
##  <C>W</C>, and from the left and from the right on <C>M</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "BiAlgebraModuleByGenerators", [ IsAlgebra, IsAlgebra,
                       IS_FUNCTION, IS_FUNCTION, IsHomogeneousList ]);

##############################################################################
##
#O  LeftAlgebraModule( <A>, <op>, <V> )
##
##  <#GAPDoc Label="LeftAlgebraModule">
##  <ManSection>
##  <Oper Name="LeftAlgebraModule" Arg='A, op, V'/>
##
##  <Description>
##  Constructs the left algebra module over <A>A</A> with underlying space <A>V</A>.
##  The action of <A>A</A> is described by the function <A>op</A>. This must
##  be a function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector from <A>V</A>; it outputs the result of
##  applying the algebra element to the vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeftAlgebraModule", [ IsAlgebra, IS_FUNCTION,
                                           IsVectorSpace ]);

##############################################################################
##
#O  RightAlgebraModule( <A>, <op>, <V> )
##
##  <#GAPDoc Label="RightAlgebraModule">
##  <ManSection>
##  <Oper Name="RightAlgebraModule" Arg='A, op, V'/>
##
##  <Description>
##  Constructs the right algebra module over <A>A</A> with underlying space <A>V</A>.
##  The action of <A>A</A> is described by the function <A>op</A>. This must
##  be a function of two arguments; the first argument is a vector, from <A>V</A>
##  and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element to the vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RightAlgebraModule", [ IsAlgebra, IS_FUNCTION,
                                           IsVectorSpace ]);


##############################################################################
##
#O  BiAlgebraModule( <A>, <B>, <opl>, <opr>, <V> )
##
##  <#GAPDoc Label="BiAlgebraModule">
##  <ManSection>
##  <Oper Name="BiAlgebraModule" Arg='A, B, opl, opr, V'/>
##
##  <Description>
##  Constructs the algebra bi-module over <A>A</A> and <A>B</A> with underlying space
##  <A>V</A>. The left action of <A>A</A> is described by the function <A>opl</A>,
##  and the right action of <A>B</A> by the function <A>opr</A>. <A>opl</A> must be a
##  function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector from <A>V</A>; it outputs the result of
##  applying
##  the algebra element on the left to the vector. <A>opr</A> must
##  be a function of two arguments; the first argument is a vector from <A>V</A>,
##  and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element on the right to the vector.
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];;
##  gap> V:= Rationals^3;
##  ( Rationals^3 )
##  gap> V:= Rationals^3;;
##  gap> M:= BiAlgebraModule( A, A, \*, \*, V );
##  <bi-module over ( Rationals^[ 3, 3 ] ) (left) and ( Rationals^
##  [ 3, 3 ] ) (right)>
##  gap> Dimension( M );
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "BiAlgebraModule", [ IsAlgebra, IsAlgebra,
                       IS_FUNCTION, IS_FUNCTION, IsVectorSpace ]);


##############################################################################
##
#C  IsBasisOfAlgebraModuleElementSpace( <B> )
##
##  <#GAPDoc Label="IsBasisOfAlgebraModuleElementSpace">
##  <ManSection>
##  <Filt Name="IsBasisOfAlgebraModuleElementSpace" Arg='B' Type='Category'/>
##
##  <Description>
##  If a basis <A>B</A> lies in the category <C>IsBasisOfAlgebraModuleElementSpace</C>,
##  then
##  <A>B</A> is a basis of a subspace of an algebra module. This means that
##  <A>B</A> has the record field <C><A>B</A>!.delegateBasis</C> set. This last object
##  is a basis of the corresponding subspace of the vector space underlying
##  the algebra module (i.e., the vector
##  space spanned by all <C>ExtRepOfObj( v )</C> for <C>v</C> in
##  the algebra module).
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];;
##  gap> M:= BiAlgebraModuleByGenerators( A, A, \*, \*, [ [ 1, 0, 0 ] ] );;
##  gap> B:= Basis( M );
##  Basis( <3-dimensional bi-module over ( Rationals^
##  [ 3, 3 ] ) (left) and ( Rationals^[ 3, 3 ] ) (right)>,
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ] )
##  gap> IsBasisOfAlgebraModuleElementSpace( B );
##  true
##  gap> B!.delegateBasis;
##  SemiEchelonBasis( <vector space of dimension 3 over Rationals>,
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsBasisOfAlgebraModuleElementSpace", IsBasis );

##############################################################################
##
#O  SubAlgebraModule( <M>, <gens> [,<"basis">] )
##
##  <#GAPDoc Label="SubAlgebraModule">
##  <ManSection>
##  <Oper Name="SubAlgebraModule" Arg='M, gens [,"basis"]'/>
##
##  <Description>
##  is the sub-module of the algebra module <A>M</A>, generated by the vectors
##  in <A>gens</A>. If as an optional argument the string <C>basis</C> is added, then
##  it is
##  assumed that the vectors in <A>gens</A> form a basis of the submodule.
##  <Example><![CDATA[
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:= 1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:= 1;;
##  gap> A:= Algebra( Rationals, [ m1, m2 ] );;
##  gap> M:= LeftAlgebraModuleByGenerators( A, \*, [ [ 1, 0 ], [ 0, 1 ] ] );
##  <left-module over <algebra over Rationals, with 2 generators>>
##  gap> bb:= BasisVectors( Basis( M ) );
##  [ [ 1, 0 ], [ 0, 1 ] ]
##  gap> V:= SubAlgebraModule( M, [ bb[1] ] );
##  <left-module over <algebra over Rationals, with 2 generators>>
##  gap> Dimension( V );
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SubAlgebraModule", [ IsAlgebraModule,
                            IsAlgebraModuleElementCollection ] );

##############################################################################
##
#O  LeftModuleByHomomorphismToMatAlg( <A>, <hom> )
##
##  <#GAPDoc Label="LeftModuleByHomomorphismToMatAlg">
##  <ManSection>
##  <Oper Name="LeftModuleByHomomorphismToMatAlg" Arg='A, hom'/>
##
##  <Description>
##  Here <A>A</A> is an algebra and <A>hom</A> a homomorphism from <A>A</A> into a matrix
##  algebra. This function returns the left <A>A</A>-module defined by the
##  homomorphism <A>hom</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeftModuleByHomomorphismToMatAlg", [ IsAlgebra,
                                                 IsAlgebraHomomorphism ]);

##############################################################################
##
#O  RightModuleByHomomorphismToMatAlg( <A>, <hom> )
##
##  <#GAPDoc Label="RightModuleByHomomorphismToMatAlg">
##  <ManSection>
##  <Oper Name="RightModuleByHomomorphismToMatAlg" Arg='A, hom'/>
##
##  <Description>
##  Here <A>A</A> is an algebra and <A>hom</A> a homomorphism from <A>A</A> into a matrix
##  algebra. This function returns the right <A>A</A>-module defined by the
##  homomorphism <A>hom</A>.
##  <P/>
##  First we produce a structure constants algebra with basis elements
##  <M>x</M>, <M>y</M>, <M>z</M> such that <M>x^2 = x</M>, <M>y^2 = y</M>, <M>xz = z</M>, <M>zy = z</M>
##  and all other products are zero.
##  <P/>
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 3, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [ 1, 1 ]);
##  gap> SetEntrySCTable( T, 2, 2, [ 1, 2 ]);
##  gap> SetEntrySCTable( T, 1, 3, [ 1, 3 ]);
##  gap> SetEntrySCTable( T, 3, 2, [ 1, 3 ]);
##  gap> A:= AlgebraByStructureConstants( Rationals, T );
##  <algebra of dimension 3 over Rationals>
##  ]]></Example>
##  <P/>
##  Now we construct an isomorphic matrix algebra.
##  <P/>
##  <Example><![CDATA[
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:= 1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:= 1;;
##  gap> m3:= NullMat( 2, 2 );; m3[1][2]:= 1;;
##  gap> B:= Algebra( Rationals, [ m1, m2, m3 ] );
##  <algebra over Rationals, with 3 generators>
##  ]]></Example>
##  <P/>
##  Finally we construct the homomorphism and the corresponding right module.
##  <P/>
##  <Example><![CDATA[
##  gap> f:= AlgebraHomomorphismByImages( A, B, Basis(A), [ m1, m2, m3 ] );;
##  gap> RightModuleByHomomorphismToMatAlg( A, f );
##  <right-module over <algebra of dimension 3 over Rationals>>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RightModuleByHomomorphismToMatAlg", [ IsAlgebra,
                                                 IsAlgebraHomomorphism ]);

##############################################################################
##
#A  AdjointModule( <A> )
##
##  <#GAPDoc Label="AdjointModule">
##  <ManSection>
##  <Attr Name="AdjointModule" Arg='A'/>
##
##  <Description>
##  returns the <A>A</A>-module defined by the left action of <A>A</A> on itself.
##  <Example><![CDATA[
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:= 1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:= 1;;
##  gap> m3:= NullMat( 2, 2 );; m3[1][2]:= 1;;
##  gap> A:= Algebra( Rationals, [ m1, m2, m3 ] );
##  <algebra over Rationals, with 3 generators>
##  gap> V:= AdjointModule( A );
##  <3-dimensional left-module over <algebra of dimension
##  3 over Rationals>>
##  gap> v:= Basis( V )[3];
##  [ [ 0, 1 ], [ 0, 0 ] ]
##  gap> W:= SubAlgebraModule( V, [ v ] );
##  <left-module over <algebra of dimension 3 over Rationals>>
##  gap> Dimension( W );
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AdjointModule", IsAlgebra );

##############################################################################
##
#A  FaithfulModule( <A> )
##
##  <#GAPDoc Label="FaithfulModule">
##  <ManSection>
##  <Attr Name="FaithfulModule" Arg='A' Label="for Lie algebras"/>
##
##  <Description>
##  returns a faithful finite-dimensional left-module over the algebra <A>A</A>.
##  This is only implemented for associative algebras, and for Lie algebras
##  of characteristic <M>0</M>. (It may also work for certain Lie algebras
##  of characteristic <M>p > 0</M>.)
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> A:= AlgebraByStructureConstants( Rationals, T );
##  <algebra of dimension 2 over Rationals>
##  ]]></Example>
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 3, 0, "antisymmetric" );;
##  gap> SetEntrySCTable( T, 1, 2, [ 1, 3 ]);
##  gap> L:= LieAlgebraByStructureConstants( Rationals, T );
##  <Lie algebra of dimension 3 over Rationals>
##  gap> V:= FaithfulModule( L );
##  <left-module over <Lie algebra of dimension 3 over Rationals>>
##  gap> vv:= BasisVectors( Basis( V ) );
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
##  gap> x:= Basis( L )[3];
##  v.3
##  gap> List( vv, v -> x^v );
##  [ [ 0, 0, 0 ], [ 1, 0, 0 ], [ 0, 0, 0 ] ]
##  ]]></Example>
##  <P/>
##  <C>A</C> is a <M>2</M>-dimensional algebra where all products are zero.
##  <P/>
##  <Example><![CDATA[
##  gap> V:= FaithfulModule( A );
##  <left-module over <algebra of dimension 2 over Rationals>>
##  gap> vv:= BasisVectors( Basis( V ) );
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
##  gap> xx:= BasisVectors( Basis( A ) );
##  [ v.1, v.2 ]
##  gap> xx[1]^vv[3];
##  [ 1, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FaithfulModule", IsAlgebra );


##############################################################################
##
#O  ModuleByRestriction( <V>, <sub1>[, <sub2>] )
##
##  <#GAPDoc Label="ModuleByRestriction">
##  <ManSection>
##  <Oper Name="ModuleByRestriction" Arg='V, sub1[, sub2]'/>
##
##  <Description>
##  Here <A>V</A> is an algebra module and <A>sub1</A> is a subalgebra
##  of the acting algebra of <A>V</A>. This function returns the
##  module that is the restriction of <A>V</A> to <A>sub1</A>.
##  So it has the same underlying vector space as <A>V</A>,
##  but the acting algebra is <A>sub</A>.
##  If two subalgebras <A>sub1</A>, <A>sub2</A> are given then <A>V</A> is
##  assumed to be a bi-module, and <A>sub1</A> a subalgebra of the algebra
##  acting on the left, and <A>sub2</A> a subalgebra of the algebra acting
##  on the right.
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];;
##  gap> V:= LeftAlgebraModuleByGenerators( A, \*, [ [ 1, 0, 0 ] ] );;
##  gap> B:= Subalgebra( A, [ Basis(A)[1] ] );
##  <algebra over Rationals, with 1 generator>
##  gap> W:= ModuleByRestriction( V, B );
##  <left-module over <algebra over Rationals, with 1 generator>>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ModuleByRestriction", [ IsAlgebraModule, IsAlgebra ] );


##############################################################################
##
#O  NaturalHomomorphismBySubAlgebraModule( <V>, <W> )
##
##  <#GAPDoc Label="NaturalHomomorphismBySubAlgebraModule">
##  <ManSection>
##  <Oper Name="NaturalHomomorphismBySubAlgebraModule" Arg='V, W'/>
##
##  <Description>
##  Here <A>V</A> must be a sub-algebra module of <A>V</A>. This function returns
##  the projection from <A>V</A> onto <C><A>V</A>/<A>W</A></C>. It is a linear map, that is
##  also a module homomorphism. As usual images can be formed with
##  <C>Image( f, v )</C> and pre-images with <C>PreImagesRepresentative( f, u )</C>.
##  <P/>
##  The quotient module can also be formed
##  by entering <C><A>V</A>/<A>W</A></C>.
##  <Example><![CDATA[
##  gap> A:= Rationals^[3,3];;
##  gap> B:= DirectSumOfAlgebras( A, A );
##  <algebra over Rationals, with 6 generators>
##  gap> T:= StructureConstantsTable( Basis( B ) );;
##  gap> C:= AlgebraByStructureConstants( Rationals, T );
##  <algebra of dimension 18 over Rationals>
##  gap> V:= AdjointModule( C );
##  <left-module over <algebra of dimension 18 over Rationals>>
##  gap> W:= SubAlgebraModule( V, [ Basis(V)[1] ] );
##  <left-module over <algebra of dimension 18 over Rationals>>
##  gap> f:= NaturalHomomorphismBySubAlgebraModule( V, W );
##  <linear mapping by matrix, <
##  18-dimensional left-module over <algebra of dimension
##  18 over Rationals>> -> <
##  9-dimensional left-module over <algebra of dimension
##  18 over Rationals>>>
##  gap> quo:= ImagesSource( f );  # i.e., the quotient module
##  <9-dimensional left-module over <algebra of dimension
##  18 over Rationals>>
##  gap> v:= Basis( quo )[1];
##  [ 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
##  gap> PreImagesRepresentative( f, v );
##  v.4
##  gap> Basis( C )[4]^v;
##  [ 1, 0, 0, 0, 0, 0, 0, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NaturalHomomorphismBySubAlgebraModule", [ IsAlgebraModule,
                                                IsAlgebraModule ] );

##############################################################################
##
#O  MatrixOfAction( <B>, <x>[, <side>] )
##
##  <#GAPDoc Label="MatrixOfAction">
##  <ManSection>
##  <Oper Name="MatrixOfAction" Arg='B, x[, side]'/>
##
##  <Description>
##  Here <A>B</A> is a basis of an algebra module and <A>x</A> is an element
##  of the algebra that acts on this module. This function returns
##  the matrix of the action of <A>x</A> with respect to <A>B</A>.
##  If <A>x</A> acts from the left, then the coefficients of the images of
##  the basis elements of <A>B</A> (under the action of <A>x</A>) are the
##  columns of the output.
##  If <A>x</A> acts from the right, then they are the rows of the output.
##  <P/>
##  If the module is a bi-module, then the third parameter <A>side</A> must
##  be specified.
##  This is the string <C>"left"</C>, or <C>"right"</C> depending whether
##  <A>x</A> acts from the left or the right.
##  <Example><![CDATA[
##  gap> M:= LeftAlgebraModuleByGenerators( A, \*, [ [ 1, 0, 0 ] ] );;
##  gap> x:= Basis(A)[3];
##  [ [ 0, 0, 1 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ]
##  gap> MatrixOfAction( Basis( M ), x );
##  [ [ 0, 0, 1 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MatrixOfAction", [ IsBasisOfAlgebraModuleElementSpace,
                                         IsObject ] );

#############################################################################
##
#C  IsMonomialElement( <obj> )
##
##  <ManSection>
##  <Filt Name="IsMonomialElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  If the object <A>obj</A> lies in the category <C>IsMonomialElement</C>, then
##  it is a linear combination of monomials. This category is used to set
##  up some basic functionality and linear algebra for tensor elements,
##  wedge elements, symmetric power elements (in order not to have to copy
##  essentially the same code for all these elements).
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsMonomialElement", IsVector );
DeclareCategoryCollections( "IsMonomialElement" );
DeclareCategoryFamily( "IsMonomialElement" );

#
DeclareHandlingByNiceBasis( "IsMonomialElementVectorSpace",
    "for free left modules of monomial elements");


#############################################################################
##
#O  ConvertToNormalFormMonomialElement( <me> )
##
##  <ManSection>
##  <Oper Name="ConvertToNormalFormMonomialElement" Arg='me'/>
##
##  <Description>
##  Converts the monomial element to some normal form (e.g., if it is a
##  tensor element v\otimes w, it will expand v and w on a basis of the
##  underlying vector spaces).
##  </Description>
##  </ManSection>
##
DeclareOperation( "ConvertToNormalFormMonomialElement",
                                      [ IsMonomialElement ] );

##############################################################################
##
#C  IsTensorElement( <obj> )
##
##  <ManSection>
##  <Filt Name="IsTensorElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element of the tensor product of algebra modules lies in the
##  category <C>IsTensorElement</C>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsTensorElement", IsMonomialElement );
DeclareCategoryCollections( "IsTensorElement" );

##############################################################################
##
#O  TensorProduct( <list> )
#O  TensorProduct( <V>, <W>, ... )
##
##  <#GAPDoc Label="TensorProduct">
##  <ManSection>
##  <Oper Name="TensorProduct" Arg='list'
##   Label="for a list of vector spaces"/>
##  <Oper Name="TensorProduct" Arg='V, W, ...' Label="for vector spaces"/>
##
##  <Description>
##  Here <A>list</A> must be a list of vector spaces. This function returns
##  the tensor product of the elements in the list. The vector spaces
##  must be defined over the same field.
##  <P/>
##  In the second form, the vector spaces are given individually.
##  <P/>
##  Elements of the tensor product <M>V_1\otimes \cdots \otimes V_k</M> are
##  linear combinations of <M>v_1\otimes\cdots \otimes v_k</M>, where
##  the <M>v_i</M> are arbitrary basis elements of <M>V_i</M>. In &GAP; a tensor
##  element like that is printed as
##  <Log><![CDATA[
##     v_1<x> ... <x>v_k
##  ]]></Log>
##  Furthermore, the zero of a tensor product is printed as
##  <Log><![CDATA[
##   <0-tensor>
##  ]]></Log>
##  This does not mean that all tensor products have the
##  same zero element: zeros of different tensor products have different
##  families.
##  <Example><![CDATA[
##  gap> V:=TensorProduct(Rationals^2, Rationals^3);
##  <vector space over Rationals, with 6 generators>
##  gap> Basis(V);
##  Basis( <vector space over Rationals, with 6 generators>,
##  [ 1*([ 0, 1 ]<x>[ 0, 0, 1 ]), 1*([ 0, 1 ]<x>[ 0, 1, 0 ]),
##    1*([ 0, 1 ]<x>[ 1, 0, 0 ]), 1*([ 1, 0 ]<x>[ 0, 0, 1 ]),
##    1*([ 1, 0 ]<x>[ 0, 1, 0 ]), 1*([ 1, 0 ]<x>[ 1, 0, 0 ]) ] )
##  ]]></Example>
##  See also <Ref Oper="KroneckerProduct"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TensorProductOp", [ IsList, IsVectorSpace ] );
DeclareGlobalFunction( "TensorProduct" );

###############################################################################
##
#O  TensorProductOfAlgebraModules( <list> )
#O  TensorProductOfAlgebraModules( <V>, <W> )
##
##  <#GAPDoc Label="TensorProductOfAlgebraModules">
##  <ManSection>
##  <Oper Name="TensorProductOfAlgebraModules" Arg='list'
##   Label="for a list of algebra modules"/>
##  <Oper Name="TensorProductOfAlgebraModules" Arg='V, W'
##   Label="for two algebra modules"/>
##
##  <Description>
##  Here the elements of <A>list</A> must be algebra modules.
##  The tensor product is returned as an algebra module.
##  The two-argument version works in the same way and
##  returns the tensor product of its arguments.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra("G",2,Rationals);;
##  gap> V:= HighestWeightModule( L, [ 1, 0 ] );;
##  gap> W:= TensorProductOfAlgebraModules( [ V, V, V ] );
##  <343-dimensional left-module over <Lie algebra of dimension
##  14 over Rationals>>
##  gap> w:= Basis(W)[1];
##  1*(1*v0<x>1*v0<x>1*v0)
##  gap> Basis(L)[1]^w;
##  <0-tensor>
##  gap> Basis(L)[7]^w;
##  1*(1*v0<x>1*v0<x>y1*v0)+1*(1*v0<x>y1*v0<x>1*v0)+1*(y
##  1*v0<x>1*v0<x>1*v0)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TensorProductOfAlgebraModules", [ IsList ] );

###############################################################################
##
#C  IsWedgeElement( <obj> )
##
##  <ManSection>
##  <Filt Name="IsWedgeElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element of an exterior power of an algebra module lies in the
##  category <C>IsWedgeElement</C>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsWedgeElement", IsMonomialElement );
DeclareCategoryCollections( "IsWedgeElement" );


##############################################################################
##
#O  ExteriorPower( <V>, <k> )
##
##  <#GAPDoc Label="ExteriorPower">
##  <ManSection>
##  <Oper Name="ExteriorPower" Arg='V, k'/>
##
##  <Description>
##  Here <A>V</A> must be a vector space. This function returns the <A>k</A>-th
##  exterior power of <A>V</A>.
##  <P/>
##  Elements of the exterior power <M>\bigwedge^k V</M> are
##  linear combinations of <M>v_{i_1}\wedge\cdots \wedge v_{i_k}</M>, where
##  the <M>v_{i_j}</M> are basis elements of <M>V</M>, and
##  <M>1 \leq i_1 &lt; i_2 \cdots &lt; i_k</M>. In &GAP; a wedge
##  element like that is printed as
##  <Log><![CDATA[
##     v_1/\ ... /\v_k
##  ]]></Log>
##  Furthermore, the zero of an exterior power is printed as
##  <Log><![CDATA[
##   <0-wedge>
##  ]]></Log>
##  This does not mean that all exterior powers have the
##  same zero element: zeros of different exterior powers have different
##  families.
##  <Example><![CDATA[
##  gap> V:=ExteriorPower(Rationals^3, 2);
##  <vector space of dimension 3 over Rationals>
##  gap> Basis(V);
##  Basis( <vector space of dimension 3 over Rationals>, [
##    1*([ 0, 1, 0 ]/\[ 0, 0, 1 ]), 1*([ 1, 0, 0 ]/\[ 0, 0, 1 ]),
##    1*([ 1, 0, 0 ]/\[ 0, 1, 0 ]) ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExteriorPower", [ IsLeftModule, IsInt ] );

##############################################################################
##
#O  ExteriorPowerOfAlgebraModule( <V>, <k> )
##
##  <#GAPDoc Label="ExteriorPowerOfAlgebraModule">
##  <ManSection>
##  <Oper Name="ExteriorPowerOfAlgebraModule" Arg='V, k'/>
##
##  <Description>
##  Here <A>V</A> must be an algebra module, defined over a Lie algebra.
##  This function returns the <A>k</A>-th exterior power of <A>V</A> as an
##  algebra module.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra("G",2,Rationals);;
##  gap> V:= HighestWeightModule( L, [ 1, 0 ] );;
##  gap> W:= ExteriorPowerOfAlgebraModule( V, 3 );
##  <35-dimensional left-module over <Lie algebra of dimension
##  14 over Rationals>>
##  gap> w:= Basis(W)[1];
##  1*(1*v0/\y1*v0/\y3*v0)
##  gap> Basis(L)[10]^w;
##  1*(1*v0/\y1*v0/\y6*v0)+1*(1*v0/\y3*v0/\y5*v0)+1*(y1*v0/\y3*v0/\y4*v0)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExteriorPowerOfAlgebraModule", [ IsAlgebraModule, IsInt ] );


##############################################################################
##
#C  IsSymmetricPowerElement( <obj> )
##
##  <ManSection>
##  <Filt Name="IsSymmetricPowerElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element of a symmetric power of an algebra module lies in the
##  category <C>IsSymmetricPowerElement</C>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsSymmetricPowerElement", IsMonomialElement );
DeclareCategoryCollections( "IsSymmetricPowerElement" );


##############################################################################
##
#O  SymmetricPower( <V>, <k> )
##
##  <#GAPDoc Label="SymmetricPower">
##  <ManSection>
##  <Oper Name="SymmetricPower" Arg='V, k'/>
##
##  <Description>
##  Here <A>V</A> must be a vector space. This function returns the <A>k</A>-th
##  symmetric power of <A>V</A>.
##  <Example><![CDATA[
##  gap> V:=SymmetricPower(Rationals^3, 2);
##  <vector space over Rationals, with 6 generators>
##  gap> Basis(V);
##  Basis( <vector space over Rationals, with 6 generators>,
##  [ 1*([ 0, 0, 1 ].[ 0, 0, 1 ]), 1*([ 0, 1, 0 ].[ 0, 0, 1 ]),
##    1*([ 0, 1, 0 ].[ 0, 1, 0 ]), 1*([ 1, 0, 0 ].[ 0, 0, 1 ]),
##    1*([ 1, 0, 0 ].[ 0, 1, 0 ]), 1*([ 1, 0, 0 ].[ 1, 0, 0 ])
##   ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SymmetricPower", [ IsLeftModule, IsInt ] );

##############################################################################
##
#O  SymmetricPowerOfAlgebraModule( <V>, <k> )
##
##  <#GAPDoc Label="SymmetricPowerOfAlgebraModule">
##  <ManSection>
##  <Oper Name="SymmetricPowerOfAlgebraModule" Arg='V, k'/>
##
##  <Description>
##  Here <A>V</A> must be an algebra module. This function returns the
##  <A>k</A>-th symmetric power of <A>V</A> (as an algebra module).
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra("G",2,Rationals);;
##  gap> V:= HighestWeightModule( L, [ 1, 0 ] );;
##  gap> W:= SymmetricPowerOfAlgebraModule( V, 3 );
##  <84-dimensional left-module over <Lie algebra of dimension
##  14 over Rationals>>
##  gap> w:= Basis(W)[1];
##  1*(1*v0.1*v0.1*v0)
##  gap> Basis(L)[2]^w;
##  <0-symmetric element>
##  gap> Basis(L)[7]^w;
##  3*(1*v0.1*v0.y1*v0)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SymmetricPowerOfAlgebraModule",[ IsAlgebraModule,IsInt ]);


##############################################################################
##
#C  IsDirectSumElement( <obj> )
##
##  <ManSection>
##  <Filt Name="IsDirectSumElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element of the direct sum of algebra modules lies in the category
##  <C>IsDirectSumElement</C>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsDirectSumElement", IsVector );
DeclareCategoryCollections( "IsDirectSumElement" );
DeclareCategoryFamily( "IsDirectSumElement" );

##############################################################################
##
#O  DirectSumOfAlgebraModules( <list> )
#O  DirectSumOfAlgebraModules( <V>, <W> )
##
##  <#GAPDoc Label="DirectSumOfAlgebraModules">
##  <ManSection>
##  <Oper Name="DirectSumOfAlgebraModules" Arg='list'
##   Label="for a list of Lie algebra modules"/>
##  <Oper Name="DirectSumOfAlgebraModules" Arg='V, W'
##   Label="for two Lie algebra modules"/>
##
##  <Description>
##  Here <A>list</A> must be a list of algebra modules. This function returns the
##  direct sum of the elements in the list (as an algebra module).
##  The modules must be defined over the same algebras.
##  <P/>
##  In the second form is short for <C>DirectSumOfAlgebraModules( [ <A>V</A>, <A>W</A> ] )</C>
##  <Example><![CDATA[
##  gap> A:= FullMatrixAlgebra( Rationals, 3 );;
##  gap> V:= BiAlgebraModuleByGenerators( A, A, \*, \*, [ [1,0,0] ] );;
##  gap> W:= DirectSumOfAlgebraModules( V, V );
##  <6-dimensional left-module over ( Rationals^[ 3, 3 ] )>
##  gap> BasisVectors( Basis( W ) );
##  [ ( [ 1, 0, 0 ] )(+)( [ 0, 0, 0 ] ), ( [ 0, 1, 0 ] )(+)( [ 0, 0, 0 ] )
##      , ( [ 0, 0, 1 ] )(+)( [ 0, 0, 0 ] ),
##    ( [ 0, 0, 0 ] )(+)( [ 1, 0, 0 ] ), ( [ 0, 0, 0 ] )(+)( [ 0, 1, 0 ] )
##      , ( [ 0, 0, 0 ] )(+)( [ 0, 0, 1 ] ) ]
##  ]]></Example>
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "C", 3, Rationals );;
##  gap> V:= HighestWeightModule( L, [ 1, 1, 0 ] );
##  <64-dimensional left-module over <Lie algebra of dimension
##  21 over Rationals>>
##  gap> W:= HighestWeightModule( L, [ 0, 0, 2 ] );
##  <84-dimensional left-module over <Lie algebra of dimension
##  21 over Rationals>>
##  gap> U:= DirectSumOfAlgebraModules( V, W );
##  <148-dimensional left-module over <Lie algebra of dimension
##  21 over Rationals>>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DirectSumOfAlgebraModules", [ IsList ] );

#############################################################################
##
#C  IsSparseRowSpaceElement( <vec> )
#C  IsSparseRowSpaceElementCollection( <coll> )
#C  IsSparseRowSpaceElementFamily( <fam> )
##
##  <ManSection>
##  <Filt Name="IsSparseRowSpaceElement" Arg='vec' Type='Category'/>
##  <Filt Name="IsSparseRowSpaceElementCollection" Arg='coll' Type='Category'/>
##  <Filt Name="IsSparseRowSpaceElementFamily" Arg='fam' Type='Category'/>
##
##  <Description>
##  An object lying in the category <C>IsSparseRowSpaceElement</C> is an
##  element of a full row space, of which all elements are sparsely
##  represented.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsSparseRowSpaceElement", IsVector );
DeclareCategoryCollections( "IsSparseRowSpaceElement" );
DeclareCategoryFamily( "IsSparseRowSpaceElement" );
#T Can this be clean?
#T Elements of row spaces are row vectors,
#T and these are lists, so their family is obviously the collections family
#T of the list entries.
#T The concept of different *representations* for the same object should be
#T used to implement sparse and dense lists;
#T regarding sparse and dense lists as different (and in the case of different
#T families even incomparable) elements may be easy to implement but is not
#T desirable!
#T TB, January 12th, 2000.


#
DeclareHandlingByNiceBasis( "IsSparseVectorSpace",
    "for free left modules of sparse vectors");


##############################################################################
##
#O  FullSparseRowSpace( <R>, <n> )
##
##  <ManSection>
##  <Oper Name="FullSparseRowSpace" Arg='R, n'/>
##
##  <Description>
##  Is the full sparse row space over the ring <A>R</A> with dimension <A>n</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "FullSparseRowSpace", [ IsRing, IsInt ] );


#############################################################################
##
#F  IsDirectSumElementsSpace( <V> )
##
##  <ManSection>
##  <Func Name="IsDirectSumElementsSpace" Arg='V'/>
##
##  <Description>
##  ...
##  </Description>
##  </ManSection>
##
DeclareHandlingByNiceBasis( "IsDirectSumElementsSpace",
    "for free left modules of direct-sum-elements" );

###############################################################################
##
#O  TranslatorSubalgebra( <M>, <U>, <W> )
##
##  <#GAPDoc Label="TranslatorSubalgebra">
##  <ManSection>
##  <Oper Name="TranslatorSubalgebra" Arg='M, U, W'/>
##
##  <Description>
##   Here <A>M</A> is an algebra module, and <A>U</A> and <A>W</A> are two subspaces of <A>M</A>.
##   Let <A>A</A> be the algebra acting on <A>M</A>. This function returns the subspace
##   of elements of <A>A</A> that map <A>U</A> into <A>W</A>. If <A>W</A> is a sub-algebra-module
##   (i.e., closed under the action of <A>A</A>), then this space is a subalgebra
##   of <A>A</A>.
##  <P/>
##   This function works for left, or right modules over a
##   finite-dimensional algebra. We
##   stress that it is not checked whether <A>U</A> and <A>W</A> are indeed subspaces
##   of <A>M</A>. If this is not the case nothing is guaranteed about the behaviour
##   of the function.
##  <Example><![CDATA[
##  gap> A:= FullMatrixAlgebra( Rationals, 3 );
##  ( Rationals^[ 3, 3 ] )
##  gap> V:= Rationals^[3,2];
##  ( Rationals^[ 3, 2 ] )
##  gap> M:= LeftAlgebraModule( A, \*, V );
##  <left-module over ( Rationals^[ 3, 3 ] )>
##  gap> bm:= Basis(M);;
##  gap> U:= SubAlgebraModule( M, [ bm[1] ] );
##  <left-module over ( Rationals^[ 3, 3 ] )>
##  gap> TranslatorSubalgebra( M, U, M );
##  <algebra of dimension 9 over Rationals>
##  gap> W:= SubAlgebraModule( M, [ bm[4] ] );
##  <left-module over ( Rationals^[ 3, 3 ] )>
##  gap> T:=TranslatorSubalgebra( M, U, W );
##  <algebra of dimension 0 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TranslatorSubalgebra",
[ IsAlgebraModule, IsFreeLeftModule, IsFreeLeftModule ] );
