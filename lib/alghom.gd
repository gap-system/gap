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
##  This file contains declarations of operations for algebra(-with-one)
##  homomorphisms.
##
##  <#GAPDoc Label="[1]{alghom}">
##  Algebra homomorphisms are vector space homomorphisms that preserve the
##  multiplication.
##  So the default methods for vector space homomorphisms work,
##  and in fact there is not much use of the fact that source and range are
##  algebras, except that preimages and images are algebras (or even ideals)
##  in certain cases.
##  <#/GAPDoc>
##


#############################################################################
##
#O  AlgebraGeneralMappingByImages( <A>, <B>, <gens>, <imgs> )
##
##  <#GAPDoc Label="AlgebraGeneralMappingByImages">
##  <ManSection>
##  <Oper Name="AlgebraGeneralMappingByImages" Arg='A, B, gens, imgs'/>
##
##  <Description>
##  is a general mapping from the <M>F</M>-algebra <A>A</A> to the <M>F</M>-algebra <A>B</A>.
##  This general mapping is defined by mapping the entries in the list <A>gens</A>
##  (elements of <A>A</A>) to the entries in the list <A>imgs</A> (elements of <A>B</A>),
##  and taking the <M>F</M>-linear and multiplicative closure.
##  <P/>
##  <A>gens</A> need not generate <A>A</A> as an <M>F</M>-algebra, and if the
##  specification does not define a linear and multiplicative mapping then
##  the result will be multivalued.
##  Hence, in general it is not a mapping.
##  For constructing a linear map that is not
##  necessarily multiplicative, we refer to
##  <Ref Func="LeftModuleHomomorphismByImages"/>.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> B:= FullMatrixAlgebra( Rationals, 2 );;
##  gap> bA:= BasisVectors( Basis( A ) );; bB:= BasisVectors( Basis( B ) );;
##  gap> f:= AlgebraGeneralMappingByImages( A, B, bA, bB );
##  [ e, i, j, k ] -> [ [ [ 1, 0 ], [ 0, 0 ] ], [ [ 0, 1 ], [ 0, 0 ] ],
##    [ [ 0, 0 ], [ 1, 0 ] ], [ [ 0, 0 ], [ 0, 1 ] ] ]
##  gap> Images( f, bA[1] );
##  <add. coset of <algebra over Rationals, with 16 generators>>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AlgebraGeneralMappingByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  AlgebraHomomorphismByImages( <A>, <B>, <gens>, <imgs> )
##
##  <#GAPDoc Label="AlgebraHomomorphismByImages">
##  <ManSection>
##  <Func Name="AlgebraHomomorphismByImages" Arg='A, B, gens, imgs'/>
##
##  <Description>
##  <Ref Func="AlgebraHomomorphismByImages"/> returns the algebra homomorphism with
##  source <A>A</A> and range <A>B</A> that is defined by mapping the list <A>gens</A> of
##  generators of <A>A</A> to the list <A>imgs</A> of images in <A>B</A>.
##  <P/>
##  If <A>gens</A> does not generate <A>A</A> or if the homomorphism does not exist
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then <K>fail</K> is returned.
##  <P/>
##  One can avoid the checks by calling <Ref Oper="AlgebraHomomorphismByImagesNC"/>,
##  and one can construct multi-valued mappings with
##  <Ref Oper="AlgebraGeneralMappingByImages"/>.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [1,1] ); SetEntrySCTable( T, 2, 2, [1,2] );
##  gap> A:= AlgebraByStructureConstants( Rationals, T );;
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:= 1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:= 1;;
##  gap> B:= AlgebraByGenerators( Rationals, [ m1, m2 ] );;
##  gap> bA:= BasisVectors( Basis( A ) );; bB:= BasisVectors( Basis( B ) );;
##  gap> f:= AlgebraHomomorphismByImages( A, B, bA, bB );
##  [ v.1, v.2 ] -> [ [ [ 1, 0 ], [ 0, 0 ] ], [ [ 0, 0 ], [ 0, 1 ] ] ]
##  gap> Image( f, bA[1]+bA[2] );
##  [ [ 1, 0 ], [ 0, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AlgebraHomomorphismByImages" );


#############################################################################
##
#O  AlgebraHomomorphismByImagesNC( <A>, <B>, <gens>, <imgs> )
##
##  <#GAPDoc Label="AlgebraHomomorphismByImagesNC">
##  <ManSection>
##  <Oper Name="AlgebraHomomorphismByImagesNC" Arg='A, B, gens, imgs'/>
##
##  <Description>
##  <Ref Oper="AlgebraHomomorphismByImagesNC"/> is the operation that is called by the
##  function <Ref Func="AlgebraHomomorphismByImages"/>.
##  Its methods may assume that <A>gens</A> generates <A>A</A> and that the mapping of
##  <A>gens</A> to <A>imgs</A> defines an algebra homomorphism.
##  Results are unpredictable if these conditions do not hold.
##  <P/>
##  For creating a possibly multi-valued mapping from <A>A</A> to <A>B</A> that
##  respects addition, multiplication, and scalar multiplication,
##  <Ref Oper="AlgebraGeneralMappingByImages"/> can be used.
##  <!-- see the comment in the declaration of <Ref Func="GroupHomomorphismByImagesNC"/>!-->
##  <P/>
##  For the definitions of the algebras <C>A</C> and <C>B</C> in the next example we refer
##  to the previous example.
##  <P/>
##  <Example><![CDATA[
##  gap> f:= AlgebraHomomorphismByImagesNC( A, B, bA, bB );
##  [ v.1, v.2 ] -> [ [ [ 1, 0 ], [ 0, 0 ] ], [ [ 0, 0 ], [ 0, 1 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AlgebraHomomorphismByImagesNC",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  AlgebraWithOneGeneralMappingByImages( <A>, <B>, <gens>, <imgs> )
##
##  <#GAPDoc Label="AlgebraWithOneGeneralMappingByImages">
##  <ManSection>
##  <Oper Name="AlgebraWithOneGeneralMappingByImages" Arg='A, B, gens, imgs'/>
##
##  <Description>
##  This function is analogous to <Ref Oper="AlgebraGeneralMappingByImages"/>;
##  the only difference being that the identity of <A>A</A> is automatically
##  mapped to the identity of <A>B</A>.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> B:= FullMatrixAlgebra( Rationals, 2 );;
##  gap> bA:= BasisVectors( Basis( A ) );; bB:= BasisVectors( Basis( B ) );;
##  gap> f:=AlgebraWithOneGeneralMappingByImages(A,B,bA{[2,3,4]},bB{[1,2,3]});
##  [ i, j, k, e ] -> [ [ [ 1, 0 ], [ 0, 0 ] ], [ [ 0, 1 ], [ 0, 0 ] ],
##    [ [ 0, 0 ], [ 1, 0 ] ], [ [ 1, 0 ], [ 0, 1 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AlgebraWithOneGeneralMappingByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  AlgebraWithOneHomomorphismByImages( <A>, <B>, <gens>, <imgs> )
##
##  <#GAPDoc Label="AlgebraWithOneHomomorphismByImages">
##  <ManSection>
##  <Func Name="AlgebraWithOneHomomorphismByImages" Arg='A, B, gens, imgs'/>
##
##  <Description>
##  <Ref Func="AlgebraWithOneHomomorphismByImages"/> returns the
##  algebra-with-one homomorphism with source <A>A</A> and range <A>B</A>
##  that is defined by mapping the list <A>gens</A> of generators of <A>A</A>
##  to the list <A>imgs</A> of images in <A>B</A>.
##  <P/>
##  The difference between an algebra homomorphism and an algebra-with-one
##  homomorphism is that in the latter case,
##  it is assumed that the identity of <A>A</A> is mapped to the identity of
##  <A>B</A>,
##  and therefore <A>gens</A> needs to generate <A>A</A> only as an
##  algebra-with-one.
##  <P/>
##  If <A>gens</A> does not generate <A>A</A> or if the homomorphism does not
##  exist
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then <K>fail</K> is returned.
##  <P/>
##  One can avoid the checks by calling
##  <Ref Oper="AlgebraWithOneHomomorphismByImagesNC"/>,
##  and one can construct multi-valued mappings with
##  <Ref Oper="AlgebraWithOneGeneralMappingByImages"/>.
##  <Example><![CDATA[
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:=1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:=1;;
##  gap> A:= AlgebraByGenerators( Rationals, [m1,m2] );;
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [1,1] );
##  gap> SetEntrySCTable( T, 2, 2, [1,2] );
##  gap> B:= AlgebraByStructureConstants(Rationals, T);;
##  gap> bA:= BasisVectors( Basis( A ) );; bB:= BasisVectors( Basis( B ) );;
##  gap> f:= AlgebraWithOneHomomorphismByImages( A, B, bA{[1]}, bB{[1]} );
##  [ [ [ 1, 0 ], [ 0, 0 ] ], [ [ 1, 0 ], [ 0, 1 ] ] ] -> [ v.1, v.1+v.2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AlgebraWithOneHomomorphismByImages" );


#############################################################################
##
#O  AlgebraWithOneHomomorphismByImagesNC( <A>, <B>, <gens>, <imgs> )
##
##  <#GAPDoc Label="AlgebraWithOneHomomorphismByImagesNC">
##  <ManSection>
##  <Oper Name="AlgebraWithOneHomomorphismByImagesNC" Arg='A, B, gens, imgs'/>
##
##  <Description>
##  <Ref Oper="AlgebraWithOneHomomorphismByImagesNC"/> is the operation that
##  is called by the function
##  <Ref Func="AlgebraWithOneHomomorphismByImages"/>.
##  Its methods may assume that <A>gens</A> generates <A>A</A> and that the
##  mapping of <A>gens</A> to <A>imgs</A> defines an algebra-with-one
##  homomorphism.
##  Results are unpredictable if these conditions do not hold.
##  <P/>
##  For creating a possibly multi-valued mapping from <A>A</A> to <A>B</A>
##  that respects addition, multiplication, identity, and scalar
##  multiplication,
##  <Ref Oper="AlgebraWithOneGeneralMappingByImages"/> can be used.
##  <P/>
##  <!-- see the comment in the declaration of <C>GroupHomomorphismByImagesNC</C>!-->
##  <Example><![CDATA[
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:=1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:=1;;
##  gap> A:= AlgebraByGenerators( Rationals, [m1,m2] );;
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [1,1] );
##  gap> SetEntrySCTable( T, 2, 2, [1,2] );
##  gap> B:= AlgebraByStructureConstants( Rationals, T);;
##  gap> bA:= BasisVectors( Basis( A ) );; bB:= BasisVectors( Basis( B ) );;
##  gap> f:= AlgebraWithOneHomomorphismByImagesNC( A, B, bA{[1]}, bB{[1]} );
##  [ [ [ 1, 0 ], [ 0, 0 ] ], [ [ 1, 0 ], [ 0, 1 ] ] ] -> [ v.1, v.1+v.2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AlgebraWithOneHomomorphismByImagesNC",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  AlgebraHomomorphismByFunction( <A>, <B>, <f> ),
##
##  <#GAPDoc Label="AlgebraHomomorphismbyFunction">
##  <ManSection>
##  <Oper Name="AlgebraHomomorphismByFunction" Arg="A B f"/>
##  <Oper Name="AlgebraWithOneHomomorphismByFunction" Arg="A B f"/>
##  <Description>
##  These functions construct an algebra homomorphism from the algebra
##  <A>A</A> to the algebra <A>B</A> using a one-argument function <A>f</A>.
##  They do not check that the function actually defines a homomorphism.
##  <Example><![CDATA[
##  gap> A := MatrixAlgebra( Rationals, 2 );;
##  gap> f := AlgebraHomomorphismByFunction( Rationals, A, q->[[q,0],[0,0]] );
##  MappingByFunction( Rationals, ( Rationals^[ 2, 2 ] ), function( q ) ... end )
##  gap> 11^f;
##  [ [ 11, 0 ], [ 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AlgebraHomomorphismByFunction",
    [ IsAlgebra, IsAlgebra, IsFunction ] );
DeclareOperation( "AlgebraWithOneHomomorphismByFunction",
    [ IsAlgebraWithOne, IsAlgebraWithOne, IsFunction ] );

#############################################################################
##
#O  OperationAlgebraHomomorphism( <A>, <B>[, <opr>] )
#O  OperationAlgebraHomomorphism( <A>, <V>[, <opr>] )
##
##  <#GAPDoc Label="OperationAlgebraHomomorphism">
##  <ManSection>
##  <Oper Name="OperationAlgebraHomomorphism" Arg='A, B[, opr]'
##   Label="action w.r.t. a basis of the module"/>
##  <Oper Name="OperationAlgebraHomomorphism" Arg='A, V[, opr]'
##   Label="action on a free left module"/>
##
##  <Description>
##  <Ref Oper="OperationAlgebraHomomorphism" Label="action w.r.t. a basis of the module"/>
##  returns an algebra homomorphism from the <M>F</M>-algebra <A>A</A> into
##  a matrix algebra over <M>F</M> that describes the <M>F</M>-linear action
##  of <A>A</A> on the basis <A>B</A> of a free left module
##  respectively on the free left module <A>V</A>
##  (in which case some basis of <A>V</A> is chosen),
##  via the operation <A>opr</A>.
##  <P/>
##  The homomorphism need not be surjective.
##  The default value for <A>opr</A> is <Ref Func="OnRight"/>.
##  <P/>
##  If <A>A</A> is an algebra-with-one then the operation homomorphism is an
##  algebra-with-one homomorphism because the identity of <A>A</A> must act
##  as the identity.
##  <P/>
##  <!--  (Of course this holds especially if <A>D</A> is in the kernel of the action.)-->
##  <Example><![CDATA[
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:= 1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:= 1;;
##  gap> B:= AlgebraByGenerators( Rationals, [ m1, m2 ] );;
##  gap> V:= FullRowSpace( Rationals, 2 );
##  ( Rationals^2 )
##  gap> f:=OperationAlgebraHomomorphism( B, Basis( V ), OnRight );
##  <op. hom. Algebra( Rationals,
##  [ [ [ 1, 0 ], [ 0, 0 ] ], [ [ 0, 0 ], [ 0, 1 ] ]
##   ] ) -> matrices of dim. 2>
##  gap> Image( f, m1 );
##  [ [ 1, 0 ], [ 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "OperationAlgebraHomomorphism",
    [ IsFLMLOR, IsBasis, IsFunction ] );


#############################################################################
##
#F  InducedLinearAction( <basis>, <elm>, <opr> )
##
##  <ManSection>
##  <Func Name="InducedLinearAction" Arg='basis, elm, opr'/>
##
##  <Description>
##  returns the matrix that describe the linear action of the ring element
##  <A>elm</A> via <A>opr</A> on the free left module with basis <A>basis</A>,
##  with respect to this basis.
##  <!-- (Should this replace <C>LinearOperation</C>?)-->
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InducedLinearAction" );


#############################################################################
##
#O  MakePreImagesInfoOperationAlgebraHomomorphism( <ophom> )
##
##  <ManSection>
##  <Oper Name="MakePreImagesInfoOperationAlgebraHomomorphism" Arg='ophom'/>
##
##  <Description>
##  Provide the information for computing preimages, that is, set up
##  the components <C>basisImage</C>, <C>preimagesBasisImage</C>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "MakePreImagesInfoOperationAlgebraHomomorphism",
    [ IsAlgebraGeneralMapping ] );


#############################################################################
##
#A  IsomorphismFpAlgebra( <A> )
##
##  <#GAPDoc Label="IsomorphismFpAlgebra">
##  <ManSection>
##  <Attr Name="IsomorphismFpAlgebra" Arg='A'/>
##
##  <Description>
##  isomorphism from the algebra <A>A</A> onto a finitely presented algebra.
##  Currently this is only implemented for associative algebras with one.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );
##  <algebra-with-one of dimension 4 over Rationals>
##  gap> f:= IsomorphismFpAlgebra( A );
##  [ e, i, j, k, e ] -> [ [(1)*x.1], [(1)*x.2], [(1)*x.3], [(1)*x.4],
##    [(1)*<identity ...>] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismFpFLMLOR", IsFLMLOR );

DeclareSynonymAttr( "IsomorphismFpAlgebra", IsomorphismFpFLMLOR );


#############################################################################
##
#A  IsomorphismMatrixAlgebra( <A> )
##
##  <#GAPDoc Label="IsomorphismMatrixAlgebra">
##  <ManSection>
##  <Attr Name="IsomorphismMatrixAlgebra" Arg='A'/>
##
##  <Description>
##  isomorphism from the algebra <A>A</A> onto a matrix algebra.
##  Currently this is only implemented for associative algebras with one.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [1,1] ); SetEntrySCTable( T, 2, 2, [1,2] );
##  gap> A:= AlgebraByStructureConstants( Rationals, T );;
##  gap> A:= AsAlgebraWithOne( Rationals, A );;
##  gap> f:=IsomorphismMatrixAlgebra( A );
##  <op. hom. AlgebraWithOne( Rationals, ... ) -> matrices of dim. 2>
##  gap> Image( f, BasisVectors( Basis( A ) )[1] );
##  [ [ 1, 0 ], [ 0, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismMatrixFLMLOR", IsFLMLOR );

DeclareSynonymAttr( "IsomorphismMatrixAlgebra", IsomorphismMatrixFLMLOR );


#############################################################################
##
#A  IsomorphismSCAlgebra( <B> )
#A  IsomorphismSCAlgebra( <A> )
##
##  <#GAPDoc Label="IsomorphismSCAlgebra">
##  <ManSection>
##  <Attr Name="IsomorphismSCAlgebra" Arg='B' Label="w.r.t. a given basis"/>
##  <Attr Name="IsomorphismSCAlgebra" Arg='A' Label="for an algebra"/>
##
##  <Description>
##  For a basis <A>B</A> of an algebra <M>A</M>,
##  <Ref Attr="IsomorphismSCAlgebra" Label="w.r.t. a given basis"/> returns
##  an algebra isomorphism from <M>A</M> to an algebra <M>S</M> given by
##  structure constants
##  (see&nbsp;<Ref Sect="Constructing Algebras by Structure Constants"/>),
##  such that the canonical basis of <M>S</M> is the image of <A>B</A>.
##  <P/>
##  For an algebra <A>A</A>,
##  <Ref Attr="IsomorphismSCAlgebra" Label="for an algebra"/> chooses
##  a basis of <A>A</A> and returns the
##  <Ref Attr="IsomorphismSCAlgebra" Label="w.r.t. a given basis"/>
##  value for that basis.
##  <P/>
##  <Example><![CDATA[
##  gap> IsomorphismSCAlgebra( GF(8) );
##  CanonicalBasis( GF(2^3) ) -> CanonicalBasis( <algebra of dimension
##  3 over GF(2)> )
##  gap> IsomorphismSCAlgebra( GF(2)^[2,2] );
##  CanonicalBasis( ( GF(2)^
##  [ 2, 2 ] ) ) -> CanonicalBasis( <algebra of dimension 4 over GF(2)> )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IsomorphismSCFLMLOR", IsBasis );
DeclareAttribute( "IsomorphismSCFLMLOR", IsFLMLOR );

DeclareSynonymAttr( "IsomorphismSCAlgebra", IsomorphismSCFLMLOR );


#############################################################################
##
#O  RepresentativeLinearOperation( <A>, <v>, <w>, <opr> )
##
##  <#GAPDoc Label="RepresentativeLinearOperation">
##  <ManSection>
##  <Oper Name="RepresentativeLinearOperation" Arg='A, v, w, opr'/>
##
##  <Description>
##  is an element of the algebra <A>A</A> that maps the vector <A>v</A>
##  to the vector <A>w</A> under the linear operation described by the function
##  <A>opr</A>. If no such element exists then <K>fail</K> is returned.
##  <P/>
##  <!-- Would it be desirable to put this under <C>RepresentativeOperation</C>?-->
##  <!-- (look at the code before you agree ...)-->
##  <Example><![CDATA[
##  gap> m1:= NullMat( 2, 2 );; m1[1][1]:= 1;;
##  gap> m2:= NullMat( 2, 2 );; m2[2][2]:= 1;;
##  gap> B:= AlgebraByGenerators( Rationals, [ m1, m2 ] );;
##  gap> RepresentativeLinearOperation( B, [1,0], [1,0], OnRight );
##  [ [ 1, 0 ], [ 0, 0 ] ]
##  gap> RepresentativeLinearOperation( B, [1,0], [0,1], OnRight );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RepresentativeLinearOperation",
    [ IsFLMLOR, IsVector, IsVector, IsFunction ] );
