#############################################################################
##
#W  alghom.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains declarations of operations for algebra(-with-one)
##  homomorphisms.
##
#1
##  Algebra homomorphisms are vector space homomorphisms that preserve the
##  multiplication.
##  So the default methods for vector space homomorphisms work,
##  and in fact there is not much use of the fact that source and range are
##  algebras, except that preimages and images are algebras (or even ideals)
##  in certain cases.
##
Revision.alghom_gd :=
    "@(#)$Id$";


#############################################################################
##
#O  AlgebraGeneralMappingByImages( <A>, <B>, <gens>, <imgs> )
##
##  is a general mapping from the $F$-algebra <A> to the $F$-algebra <B>.
##  This general mapping is defined by mapping the entries in the list <gens>
##  (elements of <A>) to the entries in the list <imgs> (elements of <B>),
##  and taking the $F$-linear and multiplicative closure.
##
##  <gens> need not generate <A> as an $F$-algebra, and if the
##  specification does not define a linear and multiplicative mapping then
##  the result will be multivalued.
##  Hence, in general it is not a mapping.
##  For constructing a linear map that is not
##  necessarily multiplicative, we refer to `LeftModuleHomomorphismByImages'
##  ("ref:leftmodulehomomorphismbyimages").
##
DeclareOperation( "AlgebraGeneralMappingByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  AlgebraHomomorphismByImages( <A>, <B>, <gens>, <imgs> )
##
##  `AlgebraHomomorphismByImages' returns the algebra homomorphism with
##  source <A> and range <B> that is defined by mapping the list <gens> of
##  generators of <A> to the list <imgs> of images in <B>.
##
##  If <gens> does not generate <A> or if the homomorphism does not exist
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then `fail' is returned.
##
##  One can avoid the checks by calling `AlgebraHomomorphismByImagesNC',
##  and one can construct multi-valued mappings with
##  `AlgebraGeneralMappingByImages'.
##
DeclareGlobalFunction( "AlgebraHomomorphismByImages" );


#############################################################################
##
#O  AlgebraHomomorphismByImagesNC( <A>, <B>, <gens>, <imgs> )
##
##  `AlgebraHomomorphismByImagesNC' is the operation that is called by the
##  function `AlgebraHomomorphismByImages'.
##  Its methods may assume that <gens> generates <A> and that the mapping of
##  <gens> to <imgs> defines an algebra homomorphism.
##  Results are unpredictable if these conditions do not hold.
##
##  For creating a possibly multi-valued mapping from <A> to <B> that
##  respects addition, multiplication, and scalar multiplication,
##  `AlgebraGeneralMappingByImages' can be used.
##
#T see the comment in the declaration of `GroupHomomorphismByImagesNC'!
##
DeclareOperation( "AlgebraHomomorphismByImagesNC",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  AlgebraWithOneGeneralMappingByImages( <A>, <B>, <gens>, <imgs> )
##
##  This function is analogous to "AlgebraGeneralMappingByImages";
##  the only difference being that the identity of <A> is automatically
##  mapped to the identity of <B>.
##
DeclareOperation( "AlgebraWithOneGeneralMappingByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  AlgebraWithOneHomomorphismByImages( <A>, <B>, <gens>, <imgs> )
##
##  `AlgebraWithOneHomomorphismByImages' returns the algebra-with-one
##  homomorphism with source <A> and range <B> that is defined by mapping the
##  list <gens> of generators of <A> to the list <imgs> of images in <B>.
##
##  The difference between an algebra homomorphism and an algebra-with-one
##  homomorphism is that in the latter case,
##  it is assumed that the identity of <A> is mapped to the identity of <B>,
##  and therefore <gens> needs to generate <A> only as an
##  algebra-with-one.
##
##  If <gens> does not generate <A> or if the homomorphism does not exist
##  (i.e., if mapping the generators describes only a multi-valued mapping)
##  then `fail' is returned.
##
##  One can avoid the checks by calling
##  `AlgebraWithOneHomomorphismByImagesNC',
##  and one can construct multi-valued mappings with
##  `AlgebraWithOneGeneralMappingByImages'.
##
DeclareGlobalFunction( "AlgebraWithOneHomomorphismByImages" );


#############################################################################
##
#O  AlgebraWithOneHomomorphismByImagesNC( <A>, <B>, <gens>, <imgs> )
##
##  `AlgebraWithOneHomomorphismByImagesNC' is the operation that is called by
##  the function `AlgebraWithOneHomomorphismByImages'.
##  Its methods may assume that <gens> generates <A> and that the mapping of
##  <gens> to <imgs> defines an algebra-with-one homomorphism.
##  Results are unpredictable if these conditions do not hold.
##
##  For creating a possibly multi-valued mapping from <A> to <B> that
##  respects addition, multiplication, identity, and scalar multiplication,
##  `AlgebraWithOneGeneralMappingByImages' can be used.
##
#T see the comment in the declaration of `GroupHomomorphismByImagesNC'!
##
DeclareOperation( "AlgebraWithOneHomomorphismByImagesNC",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  NaturalHomomorphismByIdeal( <A>, <I> )  . . . . . map onto factor algebra
##
##  is the homomorphism of algebras provided by the natural
##  projection map of <A> onto the quotient algebra <A>/<I>.
##  This map can be used to take pre-images in the original algebra from
##  elements in the quotient.
##
DeclareOperation( "NaturalHomomorphismByIdeal",
    [ IsFLMLOR, IsFLMLOR ] );


#############################################################################
##
#O  OperationAlgebraHomomorphism( <A>, <B>[, <opr>] )
#O  OperationAlgebraHomomorphism( <A>, <V>[, <opr>] )
##
##  `OperationAlgebraHomomorphism' returns an algebra homomorphism from the
##  $F$-algebra <A> into a matrix algebra over $F$ that describes the
##  $F$-linear action of <A> on the basis <B> of a free left module
##  respectively on the free left module <V> (in which case some basis of <V>
##  is chosen), via the operation <opr>.
##
##  The homomorphism need not be surjective.
##  The default value for <opr> is `OnRight'.
##
##  If <A> is an algebra-with-one then the operation homomorphism is an
##  algebra-with-one homomorphism because the identity of <A> must act
##  as the identity.
##
#T  (Of course this holds especially if <D> is in the kernel of the action.)
##
DeclareOperation( "OperationAlgebraHomomorphism",
    [ IsFLMLOR, IsBasis, IsFunction ] );


#############################################################################
##
#F  InducedLinearAction( <basis>, <elm>, <opr> )
##
##  returns the matrix that describe the linear action of the ring element
##  <elm> via <opr> on the free left module with basis <basis>,
##  with respect to this basis.
#T (Should this replace `LinearOperation'?)
##
DeclareGlobalFunction( "InducedLinearAction" );


#############################################################################
##
#O  MakePreImagesInfoOperationAlgebraHomomorphism( <ophom> )
##
##  Provide the information for computing preimages, that is, set up
##  the components `basisImage', `preimagesBasisImage'.
##
DeclareOperation( "MakePreImagesInfoOperationAlgebraHomomorphism",
    [ IsAlgebraGeneralMapping ] );


#############################################################################
##
#A  IsomorphismFpAlgebra( <A> )
##
##  isomorphism from the algebra <A> onto a finitely presented algebra.
##
DeclareAttribute( "IsomorphismFpFLMLOR", IsFLMLOR );

DeclareSynonymAttr( "IsomorphismFpAlgebra", IsomorphismFpFLMLOR );


#############################################################################
##
#A  IsomorphismMatrixAlgebra( <A> )
##
##  isomorphism from the algebra <A> onto a matrix algebra. Currently this
##  is only implemented for associative algebras with one.
##
DeclareAttribute( "IsomorphismMatrixFLMLOR", IsFLMLOR );

DeclareSynonymAttr( "IsomorphismMatrixAlgebra", IsomorphismMatrixFLMLOR );


#############################################################################
##
#A  IsomorphismSCAlgebra( <B> )
#A  IsomorphismSCAlgebra( <A> )
##
##  For a basis <B> of an algebra $A$, say, `IsomorphismSCAlgebra' returns an
##  algebra isomorphism from $A$ to an algebra $S$ given by structure
##  constants (see~"Constructing Algebras by Structure Constants"),
##  such that the canonical basis of $S$ is the image of <B>.
##
##  For an algebra <A>, `IsomorphismSCAlgebra' chooses a basis of <A> and
##  returns the `IsomorphismSCAlgebra' value for that basis.
##
DeclareAttribute( "IsomorphismSCFLMLOR", IsBasis );
DeclareAttribute( "IsomorphismSCFLMLOR", IsFLMLOR );

DeclareSynonymAttr( "IsomorphismSCAlgebra", IsomorphismSCFLMLOR );


#############################################################################
##
#O  RepresentativeLinearOperation( <A>, <v>, <w>, <opr> )
##
##  is an element of the algebra <A> that maps the vector <v>
##  to the vector <w> under the linear operation described by the function
##  <opr>. If no such element exists then `fail' is returned.
##
#T Would it be desirable to put this under `RepresentativeOperation'?
#T (look at the code before you agree ...)
##
DeclareOperation( "RepresentativeLinearOperation",
    [ IsFLMLOR, IsVector, IsVector, IsFunction ] );


#############################################################################
##
#E

