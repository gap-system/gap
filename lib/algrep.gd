#############################################################################
##
#W  algrep.gd                  GAP library               Willem de Graaf
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for general modules over algebras.
##
Revision.algrep_gd :=
    "@(#)$Id$";

#1
##  An algebra module is a vector space together with an action of an
##  algebra. So a module over an algebra is constructed by giving generators
##  of a vector space, and a function for calculating the action of
##  algebra elements on elements of the vector space. When creating an
##  algebra module, the generators of the vector space are wrapped up and
##  given the category `IsLeftAlgebraModuleElement' or
##  `IsRightModuleElement' if the algebra acts from the left, or right
##  respectively. (So in the case of a bi-module the elements get
##  both categories.) Most linear algebra computations are delegated to
##  the original vector space.
##
##  The transition between the original vector space and the corresponding
##  algebra module is handled by `ExtRepOfObj' and `ObjByExtRep'.
##  For an element `v' of the algebra module, `ExtRepOfObj( v )' returns
##  the underlying element of the original vector space. Furthermore, if `vec'
##  is an element of the original vector space, and `fam' the elements
##  family of the corresponding algebra module, then `ObjByExtRep( fam, vec )'
##  returns the corresponding element of the algebra module. Below is an
##  example of this.
##
##  The action of the algebra on elements of the algebra module is constructed
##  by using the operator `^'. If `x' is an element of an algebra `A', and
##  `v' an element of a left `A'-module, then `x^v' calculates the result
##  of the action of `x' on `v'. Similarly, if `v' is an element of
##  a right `A'-module, then `v^x' calculates the action of `x' on `v'.
##

##############################################################################
##
#C  IsAlgebraModuleElement( <obj> )
#C  IsAlgebraModuleElementCollection( <obj> )
#C  IsAlgebraModuleElementFamily( <fam> )
##
##  Category of algebra module elements. If an object has
##  `IsAlgebraModuleElementCollection', then it is an algebra module.
##  If a family has `IsAlgebraModuleElementFamily', then it is a family
##  of algebra module elements (every algebra module has its own elements
##  family).
##
DeclareCategory( "IsAlgebraModuleElement", IsVector );
DeclareCategoryCollections( "IsAlgebraModuleElement" );
DeclareCategoryFamily( "IsAlgebraModuleElement" );

##############################################################################
##
#C  IsLeftAlgebraModuleElement( <obj> )
#C  IsLeftAlgebraModuleElementCollection( <obj> )
##
##  Category of left algebra module elements. If an object has
##  `IsLeftAlgebraModuleElementCollection', then it is a left-algebra module.
##
DeclareCategory( "IsLeftAlgebraModuleElement", IsAlgebraModuleElement );
DeclareCategoryCollections( "IsLeftAlgebraModuleElement" );

##############################################################################
##
#C  IsRightAlgebraModuleElement( <obj> )
#C  IsRightAlgebraModuleElementCollection( <obj> )
##
##  Category of right algebra module elements. If an object has
##  `IsRightAlgebraModuleElementCollection', then it is a right-algebra module.
##
DeclareCategory( "IsRightAlgebraModuleElement", IsAlgebraModuleElement );
DeclareCategoryCollections( "IsRightAlgebraModuleElement" );

##############################################################################
##
#P   IsAlgebraModule( <M> )
##
##
DeclareProperty( "IsAlgebraModule", IsLeftModule );

##############################################################################
##
#P  IsLeftAlgebraModule( <M> )
##
##
DeclareProperty( "IsLeftAlgebraModule", IsLeftModule );

##############################################################################
##
#P  IsRightAlgebraModule( <M> )
##
##
DeclareProperty( "IsRightAlgebraModule", IsLeftModule );

##############################################################################
##
#A  LeftActingAlgebra( <V> )
##
##  Here <V> is a left-algebra module; this function returns the algebra
##  that acts from the left on <V>.
##
DeclareAttribute( "LeftActingAlgebra", IsAlgebraModule );

#############################################################################
##
#A  RightActingAlgebra( <V> )
##
##  Here <V> is a right-algebra module; this function returns the algebra
##  that acts from the right on <V>.
##
DeclareAttribute( "RightActingAlgebra", IsAlgebraModule );

##############################################################################
##
#O  ActingAlgebra( <V> )
##
##  Here <V> is an algebra module; this function returns the algebra
##  that acts on <V> (this is the same as `LeftActingAlgebra( <V> )' if <V> is
##  a left module, and `RightActingAlgebra( <V> )' if <V> is a right module;
##  it will signal an error if <V> is a bi-module).
##
DeclareOperation( "ActingAlgebra", [ IsAlgebraModule ] );


##############################################################################
##
#A  GeneratorsOfAlgebraModule( <M> )
##
##  A list of elements of <M> that generate <M> as an algebra module.
##
DeclareAttribute( "GeneratorsOfAlgebraModule", IsAlgebraModule );


##############################################################################
##
#O  LeftAlgebraModuleByGenerators( <A>, <op>, <gens> )
##
##  Constructs the left algebra module over <A> generated by the list of
##  vectors
##  <gens>. The action of <A> is described by the function <op>. This must
##  be a function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector; it outputs the result of applying
##  the algebra element to the vector.
##
DeclareOperation( "LeftAlgebraModuleByGenerators", [ IsAlgebra, IS_FUNCTION,
                                           IsHomogeneousList ]);

##############################################################################
##
#O  RightAlgebraModuleByGenerators( <A>, <op>, <gens> )
##
##  Constructs the right algebra module over <A> generated by the list of
##  vectors
##  <gens>. The action of <A> is described by the function <op>. This must
##  be a function of two arguments; the first argument is a vector, and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element to the vector.
##
DeclareOperation( "RightAlgebraModuleByGenerators", [ IsAlgebra, IS_FUNCTION,
                                           IsHomogeneousList ]);


##############################################################################
##
#O  BiAlgebraModuleByGenerators( <A>, <B>, <opl>, <opr>, <gens> )
##
##  Constructs the algebra bi-module over <A> and <B> generated by the list of
##  vectors
##  <gens>. The left action of <A> is described by the function <opl>,
##  and the right action of <B> by the function <opr>. <opl> must be a
##  function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector; it outputs the result of applying
##  the algebra element on the left to the vector. <opr> must
##  be a function of two arguments; the first argument is a vector, and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element on the right to the vector.
##
DeclareOperation( "BiAlgebraModuleByGenerators", [ IsAlgebra, IsAlgebra,
                       IS_FUNCTION, IS_FUNCTION, IsHomogeneousList ]);

##############################################################################
##
#O  LeftAlgebraModule( <A>, <op>, <V> )
##
##  Constructs the left algebra module over <A> with underlying space <V>.
##  The action of <A> is described by the function <op>. This must
##  be a function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector from <V>; it outputs the result of 
##  applying the algebra element to the vector.
##
DeclareOperation( "LeftAlgebraModule", [ IsAlgebra, IS_FUNCTION,
                                           IsVectorSpace ]);

##############################################################################
##
#O  RightAlgebraModule( <A>, <op>, <V> )
##
##  Constructs the right algebra module over <A> with underlying space <V>.
##  The action of <A> is described by the function <op>. This must
##  be a function of two arguments; the first argument is a vector, from <V>
##  and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element to the vector.
##
DeclareOperation( "RightAlgebraModule", [ IsAlgebra, IS_FUNCTION,
                                           IsVectorSpace ]);


##############################################################################
##
#O  BiAlgebraModule( <A>, <B>, <opl>, <opr>, <V> )
##
##  Constructs the algebra bi-module over <A> and <B> with underlying space 
##  <V>. The left action of <A> is described by the function <opl>,
##  and the right action of <B> by the function <opr>. <opl> must be a
##  function of two arguments; the first argument is the algebra element,
##  and the second argument is a vector from <V>; it outputs the result of 
##  applying
##  the algebra element on the left to the vector. <opr> must
##  be a function of two arguments; the first argument is a vector from <V>, 
##  and the
##  second argument is the algebra element; it outputs the result of applying
##  the algebra element on the right to the vector.
##
DeclareOperation( "BiAlgebraModule", [ IsAlgebra, IsAlgebra,
                       IS_FUNCTION, IS_FUNCTION, IsVectorSpace ]);



##############################################################################
##
#C  IsBasisOfAlgebraModuleElementSpace( <B> )
##
##  If a basis <B> lies in the category `IsBasisOfAlgebraModuleElementSpace',
##  then
##  <B> is a basis of a subspace of an algebra module. This means that
##  <B> has the record field `<B>!.delegateBasis' set. This last object
##  is a basis of the corresponding subspace of the vector space underlying
##  the algebra module (i.e., the vector
##  space spanned by all `ExtRepOfObj( v )' for `v' in
##  the algebra module).
##
DeclareCategory( "IsBasisOfAlgebraModuleElementSpace", IsBasis );

##############################################################################
##
#O  SubAlgebraModule( <M>, <gens> [,<"basis">] )
##
##  is the sub-module of the algebra module <M>, generated by the vectors
##  in <gens>. If as an optional argument the string `basis' is added, then
##  it is
##  assumed that the vectors in <gens> form a basis of the submodule.
##
DeclareOperation( "SubAlgebraModule", [ IsAlgebraModule,
                            IsAlgebraModuleElementCollection ] );

##############################################################################
##
#O  LeftModuleByHomomorphismToMatAlg( <A>, <hom> )
##
##  Here <A> is an algebra and <hom> a homomorphism from <A> into a matrix
##  algebra. This function returns the left <A>-module defined by the
##  homomorphism <hom>.
##
DeclareOperation( "LeftModuleByHomomorphismToMatAlg", [ IsAlgebra,
                                                 IsAlgebraHomomorphism ]);

##############################################################################
##
#O  RightModuleByHomomorphismToMatAlg( <A>, <hom> )
##
##  Here <A> is an algebra and <hom> a homomorphism from <A> into a matrix
##  algebra. This function returns the right <A>-module defined by the
##  homomorphism <hom>.
##
DeclareOperation( "RightModuleByHomomorphismToMatAlg", [ IsAlgebra,
                                                 IsAlgebraHomomorphism ]);

##############################################################################
##
#A  AdjointModule( <A> )
##
##  returns the <A>-module defined by the left action of <A> on itself.
##
DeclareAttribute( "AdjointModule", IsAlgebra );

##############################################################################
##
#A  FaithfulModule( <A> )
##
##  returns a faithful finite-dimensional left-module over the algebra <A>.
##  This is only implemented for associative algebras, and for Lie algebras
##  of characteristic $0$. (It may also work for certain Lie algebras
##  of characteristic $p>0$.)
##
DeclareAttribute( "FaithfulModule", IsAlgebra );


##############################################################################
##
#O  ModuleByRestriction( <V>, <sub> )
#O  ModuleByRestriction( <V>, <subl>, <subr> )
##
##  Here <V> is an algebra module and <sub> is a subalgebra
##  of the acting algebra of <V>. This function returns the
##  module that is the restriction of <V> to <sub>. So it has the
##  same underlying vector space as <V>, but the acting algebra is
##  <sub>.  If two subalgebras are given then <V> is assumed to be a
##  bi-module, and <subl> a subalgebra of the algebra acting on the left,
##  and <subr> a subalgebra of the algebra acting on the right.
##
DeclareOperation( "ModuleByRestriction", [ IsAlgebraModule, IsAlgebra ] );


##############################################################################
##
#O  NaturalHomomorphismBySubAlgebraModule( <V>, <W> )
##
##  Here <V> must be a sub-algebra module of <V>. This function returns
##  the projection from <V> onto `<V>/<W>'. It is a linear map, that is
##  also a module homomorphism. As usual images can be formed with
##  `Image( f, v )' and pre-images with `PreImagesRepresentative( f, u )'.
##
##  The quotient module can also be formed
##  by entering `<V>/<W>'.
##
##
DeclareOperation( "NaturalHomomorphismBySubAlgebraModule", [ IsAlgebraModule,
                                                IsAlgebraModule ] );

##############################################################################
##
#O  MatrixOfAction( <B>, <x> )
#O  MatrixOfAction( <B>, <x>, <side> )
##
##  Here <B> is a basis of an algebra module and <x> is an element
##  of the algebra that acts on this module. This function returns
##  the matrix of the action of <x> with respect to <B>. If <x> acts
##  from the left, then the coefficients of the images of the basis
##  elements of <B> (under the action of <x>) are the columns of the output.
##  If <x> acts from the
##  right, then they are the rows of the output.
##
##  If the module is a bi-module, then the third parameter <side> must
##  be specified. This is the string `left', or `right' depending whether
##  <x> acts from the left or the right.
##
DeclareOperation( "MatrixOfAction", [ IsBasisOfAlgebraModuleElementSpace,
                                         IsObject ] );

#############################################################################
##
#C  IsMonomialElement( <obj> )
##
##  If the object <obj> lies in the category `IsMonomialElement', then
##  it is a linear combination of monomials. This category is used to set
##  up some basic functionality and linear algebra for tensor elements,
##  wedge elements, symmetric power elements (in order not to have to copy
##  esentially the same code for all these elements).
##
DeclareCategory( "IsMonomialElement", IsVector );
DeclareCategoryCollections( "IsMonomialElement" );
DeclareCategoryFamily( "IsMonomialElement" );

#############################################################################
##
#O  ConvertToNormalFormMonomialElement( <me> )
##
##  Converts the monomial element to some normal form (e.g., if it is a
##  tensor element v\otimes w, it will expand v and w on a basis of the
##  underlying vector spaces).
##
DeclareOperation( "ConvertToNormalFormMonomialElement",
                                      [ IsMonomialElement ] );

##############################################################################
##
#C  IsTensorElement( <obj> )
##
##  An element of the tensor product of algebra modules lies in the
##  category `IsTensorElement'.
##
DeclareCategory( "IsTensorElement", IsMonomialElement );
DeclareCategoryCollections( "IsTensorElement" );

##############################################################################
##
#O  TensorProduct( <list> )
#O  TensorProduct( <V>, <W> )
##
##  Here <list> must be a list of vector spaces. This function returns
##  the tensor product of the elements in the list. The vector spaces
##  must be defined over the same field.
##
##  In the second form is short for `TensorProduct( [ <V>, <W> ] )'.
##
##  Elements of the tensor product $V_1\otimes \cdots \otimes V_k$ are
##  linear combinations of $v_1\otimes\cdots \otimes v_k$, where
##  the $v_i$ are arbitrary basis elements of $V_i$. In {\GAP} a tensor
##  element like that is printed as
##  \begintt
##     v_1<x> ... <x>v_k
##  \endtt
##  Furthermore, the zero of a tensor product is printed as
##  \begintt
##   <0-tensor>
##  \endtt
##  This does not mean that all tensor products have the
##  same zero element: zeros of different tensor products have different
##  families.
##
DeclareOperation( "TensorProduct", [ IsList ] );


###############################################################################
##
#O  TensorProductOfAlgebraModules( <list> )
#O  TensorProductOfAlgebraModules( <V>, <W> )
##
##  Here the elements of <list> must be algebra modules. 
##  The tensor product is returned as an algebra module. 
##
DeclareOperation( "TensorProductOfAlgebraModules", [ IsList ] );

###############################################################################
##
#C  IsWedgeElement( <obj> )
##
##  An element of an exterior power of an algebra module lies in the
##  category `IsWedgeElement'.
##
DeclareCategory( "IsWedgeElement", IsMonomialElement );
DeclareCategoryCollections( "IsWedgeElement" );


##############################################################################
##
#O  ExteriorPower( <V>, <k> )
##
##  Here <V> must be a vector space. This function returns the <k>-th
##  exterior power of <V>.
##
##  Elements of the exterior power $\bigwedge^k V$ are
##  linear combinations of $v_{i_1}\wedge\cdots \wedge v_{i_k}$, where
##  the $v_{i_j}$ are basis elements of $V$, and
##  $1\leq i_1\<i_2\cdots \<i_k$. In {\GAP} a wedge
##  element like that is printed as
##  \begintt
##     v_1/\ ... /\v_k
##  \endtt
##  Furthermore, the zero of an exterior power is printed as
##  \begintt
##   <0-wedge>
##  \endtt
##  This does not mean that all exterior powers have the
##  same zero element: zeros of different exterior powers have different
##  families.
##
DeclareOperation( "ExteriorPower", [ IsLeftModule, IsInt ] );

##############################################################################
##
#O  ExteriorPowerOfAlgebraModule( <V>, <k> )
##
##  Here <V> must be an algebra module, defined over a Lie algebra. 
##  This function returns the <k>-th exterior power of <V> as an 
##  algebra module.
##
##
DeclareOperation( "ExteriorPowerOfAlgebraModule", [ IsAlgebraModule, IsInt ] );


##############################################################################
##
#C  IsSymmetricPowerElement( <obj> )
##
##  An element of a symmetric power of an algebra module lies in the
##  category `IsSymmetricPowerElement'.
##
DeclareCategory( "IsSymmetricPowerElement", IsMonomialElement );
DeclareCategoryCollections( "IsSymmetricPowerElement" );


##############################################################################
##
#O  SymmetricPower( <V>, <k> )
##
##  Here <V> must be a vector space. This function returns the <k>-th
##  symmetric power of <V>.
##
DeclareOperation( "SymmetricPower", [ IsLeftModule, IsInt ] );

##############################################################################
##
#O  SymmetricPowerOfAlgebraModule( <V>, <k> )
##
##  Here <V> must be an algebra module. This function returns the <k>-th
##  symmetric power of <V> (as an algebra module).
##
DeclareOperation( "SymmetricPowerOfAlgebraModule",[ IsAlgebraModule,IsInt ]);


##############################################################################
##
#C  IsDirectSumElement( <obj> )
##
##  An element of the direct sum of algebra modules lies in the category
##  `IsDirectSumElement'.
##
DeclareCategory( "IsDirectSumElement", IsVector );
DeclareCategoryCollections( "IsDirectSumElement" );
DeclareCategoryFamily( "IsDirectSumElement" );

##############################################################################
##
#O  DirectSumOfAlgebraModules( <list> )
#O  DirectSumOfAlgebraModules( <V>, <W> )
##
##  Here <list> must be a list of algebra modules. This function returns the
##  direct sum of the elements in the list (as an algebra module).
##  The modules must be defined over the same algebras.
##
##  In the second form is short for `DirectSumOfAlgebraModules( [ <V>, <W> ] )'
##
DeclareOperation( "DirectSumOfAlgebraModules", [ IsList ] );

#############################################################################
##
#C  IsSparseRowSpaceElement( <vec> )
#C  IsSparseRowSpaceElementCollection( <coll> )
#C  IsSparseRowSpaceElementFamily( <fam> )
##
##  An object lying in the category `IsSparseRowSpaceElement' is an
##  element of a full row space, of which all elements are sparsely
##  represented.
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


##############################################################################
##
#O  FullSparseRowSpace( <R>, <n> )
##
##  Is the full sparse row space over the ring <R> with dimension <n>.
##
DeclareOperation( "FullSparseRowSpace", [ IsRing, IsInt ] );


#############################################################################
##
#F  IsDirectSumElementsSpace( <V> )
##
##  ...
##
DeclareHandlingByNiceBasis( "IsDirectSumElementsSpace",
    "for free left modules of direct-sum-elements" );

###############################################################################
##
#O   TranslatorSubalgebra( <M>, <U>, <W> )
##
##   Here <M> is an algebra module, and <U> and <W> are two subspaces of <M>. 
##   Let <A> be the algebra acting on <M>. This function returns the subspace
##   of elements of <A> that map <U> into <W>. If <W> is a sub-algebra-module
##   (i.e., closed under the action of <A>), then this space is a subalgebra
##   of <A>. 
##
##   This function works for left, or right modules over a
##   finite-dimensional algebra. We
##   stress that it is not checked whether <U> and <W> are indeed subspaces
##   of <M>. If this is not the case nothing is guaranteed about the behaviour
##   of the function.
##
DeclareOperation( "TranslatorSubalgebra", 
[ IsAlgebraModule, IsFreeLeftModule, IsFreeLeftModule ] );



#############################################################################
##
#E

