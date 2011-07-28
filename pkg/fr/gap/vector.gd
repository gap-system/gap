#############################################################################
##
#W vector.gd                                                Laurent Bartholdi
##
#H   @(#)$Id: vector.gd,v 1.19 2011/06/13 22:54:36 gap Exp $
##
#Y Copyright (C) 2007, Laurent Bartholdi
##
#############################################################################
##
##  This file declares the category of linear machines and elements
##
#############################################################################

#############################################################################
##
#C IsLinearFRMachine
#C IsLinearFRElement
##
## <#GAPDoc Label="IsLinearFRMachine">
## <ManSection>
##   <Filt Name="IsLinearFRMachine" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a linear machine.</Returns>
##   <Description>
##     This function is the acceptor for the <E>linear
##     machine</E> subcategory of <E>FR machine</E>s.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Filt Name="IsLinearFRElement" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a linear element.</Returns>
##   <Description>
##     This function is the acceptor for the <E>linear
##     element</E> subcategory of <E>FR element</E>s.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareCategory("IsLinearFRMachine", IsFRMachine);
DeclareCategory("IsLinearFRElement", IsFRElement and IsMultiplicativeElementWithZero);
DeclareCategoryCollections("IsLinearFRElement");

#DeclareCategory("IsTransitionTensor", CategoryCollections(CategoryCollections);
DeclareSynonym("IsTransitionTensor", IsList);
#############################################################################

#############################################################################
##
#R IsVectorFRMachineRep
##
## <#GAPDoc Label="IsVectorFRMachineRep">
## <ManSection>
##   <Filt Name="IsVectorFRMachineRep" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is a vector machine</Returns>
##   <Description>
##     A <E>vector machine</E> is a representation of a linear machine by
##     a finite-dimensional vector space (implicit in the structure), a
##     transition tensor (represented as a matrix of matrices), and an
##     output vector (represented as a list).
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareRepresentation("IsVectorFRMachineRep",
        IsComponentObjectRep and IsAttributeStoringRep,
        ["input","transitions","output"]);

DeclareHandlingByNiceBasis("IsVectorFRElementSpace",
        "(FR) for free left modules of vector FR elements");

DeclareHandlingByNiceBasis("IsLinearFRElementSpace",
        "(FR) for free left modules of linear FR elements");
#############################################################################

#############################################################################
##
#R Transitions
##
## <#GAPDoc Label="Transitions">
## <ManSection>
##   <Oper Name="Transition" Arg="m, s, a, b" Label="Linear machine"/>
##   <Returns>An element of <A>m</A>'s stateset.</Returns>
##   <Description>
##     This function returns the state reached by <A>m</A> when
##     started in state <A>s</A> and performing output <M>a\to b</M>.
## <Example><![CDATA[
## gap> M := AsVectorMachine(Rationals,FRMachine(GuptaSidkiGroup.2));
## <Linear machine on alphabet Rationals^3 with 4-dimensional stateset>
## gap> Transition(M,[1,0,0,0],[1,0,0],[1,0,0]);
## [ 0, 1, 0, 0 ]
## gap> Transition(M,[1,0,0,0],[0,1,0],[0,1,0]);
## [ 0, 0, 1, 0 ]
## gap> Transition(M,[1,0,0,0],[0,0,1],[0,0,1]);
## [ 1, 0, 0, 0 ]
## gap> A := AsVectorElement(Rationals,GuptaSidkiGroup.2);
## <Linear element on alphabet Rationals^3 with 4-dimensional stateset>
## gap> Transition(A,[1,0,0],[1,0,0]);
## [ 0, 1, 0, 0 ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Transitions" Arg="m, s, a"/>
##   <Returns>An vector of elements of <A>m</A>'s stateset.</Returns>
##   <Description>
##     This function returns the state reached by <A>m</A> when
##     started in state <A>s</A> and receiving input <A>a</A>.
##     The output is a vector, indexed by the alphabet's basis, of output
##     states.
## <Example><![CDATA[
## gap> M := AsVectorMachine(Rationals,FRMachine(GuptaSidkiGroup.2));
## <Linear machine on alphabet Rationals^3 with 4-dimensional stateset>
## gap> Transitions(M,[1,0,0,0],[1,0,0]);
## [ [ 0, 1, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ]
## gap> A := AsVectorElement(Rationals,GuptaSidkiGroup.2);
## <Linear element on alphabet Rationals^3 with 4-dimensional stateset>
## gap> Transitions(A,[1,0,0]);
## [ [ 0, 1, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="NestedMatrixState" Arg="e, i, j"/>
##   <Oper Name="NestedMatrixCoefficient" Arg="e, i, j"/>
##   <Returns>A coefficent of an iterated decomposition of <A>e</A>.</Returns>
##   <Description>
##     The first form returns the entry at position <M>(i,j)</M> of
##     <A>e</A>'s decomposition. Both of <A>i,j</A> are lists. The second
##     form returns the output of the state.
##
##     <P/> In particular, <C>e=NestedMatrixState(e,[],[])</C>, and
##     <Br/><C>Activity(e,1)[i][j]=NestedMatrixCoefficient(e,[i],[j])</C>, and
##     <Br/><C>DecompositionOfFRElement(e,1)[i][j]=NestedMatrixState(e,[i],[j])</C>.
## <Example><![CDATA[
## gap> A := AsVectorElement(Rationals,GuptaSidkiGroup.2);;
## gap> A=NestedMatrixState(A,[3,3],[3,3]);
## true
## gap> IsOne(NestedMatrixState(A,[3,3,3,3,1,1],[3,3,3,3,1,2]));
## true
## gap> List([1..3],i->List([1..3],j->NestedMatrixCoefficient(A,[i],[j])))=Activity(A,1);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="ActivitySparse" Arg="m, i"/>
##   <Returns>A sparse matrix.</Returns>
##   <Description>
##     <C>Activity(m,i)</C> returns an <M>n^i\times n^i</M> matrix describing
##     the action on the <M>i</M>-fold tensor power of the alphabet. This
##     matrix can also be returned as a sparse matrix, and this is performed
##     by this command. A sparse matrix is described as a list of expressions of
##     the form <C>[[i,j],c]</C>, representing the elementary matrix with entry
##     <M>c</M> at position <M>(i,j)</M>. The activity matrix is then the sum
##     of these elementary matrices.
## <Example><![CDATA[
## gap> A := AsVectorElement(Rationals,GuptaSidkiGroup.2);;
## gap> Display(Activity(A,2));
## [ [  0,  1,  0,  0,  0,  0,  0,  0,  0 ],
##   [  0,  0,  1,  0,  0,  0,  0,  0,  0 ],
##   [  1,  0,  0,  0,  0,  0,  0,  0,  0 ],
##   [  0,  0,  0,  0,  0,  1,  0,  0,  0 ],
##   [  0,  0,  0,  1,  0,  0,  0,  0,  0 ],
##   [  0,  0,  0,  0,  1,  0,  0,  0,  0 ],
##   [  0,  0,  0,  0,  0,  0,  1,  0,  0 ],
##   [  0,  0,  0,  0,  0,  0,  0,  1,  0 ],
##   [  0,  0,  0,  0,  0,  0,  0,  0,  1 ] ]
## gap> ActivitySparse(A,2);
## [ [ [ 1, 2 ], 1 ], [ [ 2, 3 ], 1 ], [ [ 3, 1 ], 1 ], [ [ 4, 6 ], 1 ],
## [ [ 5, 4 ], 1 ], [ [ 6, 5 ], 1 ], [ [ 7, 7 ], 1 ], [ [ 8, 8 ], 1 ],
## [ [ 9, 9 ], 1 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Activities" Arg="m, i"/>
##   <Returns>Activities of <A>m</A> on the first <A>i</A> levels.</Returns>
##   <Description>
##     <C>Activity(m,i)</C> returns an <M>n^i\times n^i</M> matrix describing
##     the action on the <M>i</M>-fold tensor power of the alphabet. This
##     command returns <C>List([0..i-1],j->Activity(m,j))</C>.
## <Example><![CDATA[
## gap> A := AsVectorElement(Rationals,GrigorchukGroup.2);;
## gap> Activities(A,3);
## [ [ [ 1 ] ],
##   [ [ 1, 0 ], [ 0, 1 ] ],
##   [ [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsConvergent" Arg="e"/>
##   <Returns>Whether the linear element <A>e</A> is convergent.</Returns>
##   <Description>
##     A linear element is <E>convergent</E> if its state at position
##     <M>(1,1)</M> is equal to itself.
## <Example><![CDATA[
## gap> n := 3;;
## gap> shift := VectorElement(CyclotomicField(n), [[[[1,0],[0,0]],
##      [[0,0],[0,1]]],[[[0,1],[0,0]],[[1,0],[0,0]]]],[1,E(n)],[1,0]);
## <Linear element on alphabet CF(3)^2 with 2-dimensional stateset>
## gap> IsConvergent(shift);
## true
## gap> Display(Activity(shift,2));
## [ [     1,     0,     0,     0 ],
##   [  E(3),     1,     0,     0 ],
##   [     0,  E(3),     1,     0 ],
##   [     0,     0,  E(3),     1 ] ]
## gap> Display(Activity(shift,3));
## [ [     1,     0,     0,     0,     0,     0,     0,     0 ],
##   [  E(3),     1,     0,     0,     0,     0,     0,     0 ],
##   [     0,  E(3),     1,     0,     0,     0,     0,     0 ],
##   [     0,     0,  E(3),     1,     0,     0,     0,     0 ],
##   [     0,     0,     0,  E(3),     1,     0,     0,     0 ],
##   [     0,     0,     0,     0,  E(3),     1,     0,     0 ],
##   [     0,     0,     0,     0,     0,  E(3),     1,     0 ],
##   [     0,     0,     0,     0,     0,     0,  E(3),     1 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="TransposedFRElement" Arg="e"/>
##   <Prop Name="IsSymmetricFRElement" Arg="e"/>
##   <Prop Name="IsAntisymmetricFRElement" Arg="e"/>
##   <Prop Name="IsLowerTriangularFRElement" Arg="e"/>
##   <Prop Name="IsUpperTriangularFRElement" Arg="e"/>
##   <Prop Name="IsDiagonalFRElement" Arg="e"/>
##   <Returns>The elementary matrix operation/property.</Returns>
##   <Description>
##     Since linear FR elements may be interpreted as infinite matrices,
##     it makes sense to transpose them, test whether they're symmetric,
##     antisymmetric, diagonal, or triangular.
## <Example><![CDATA[
## gap> n := 3;;
## gap> shift := VectorElement(CyclotomicField(n), [[[[1,0],[0,0]],
##      [[0,0],[0,1]]],[[[0,1],[0,0]],[[1,0],[0,0]]]],[1,E(n)],[1,0]);
## <Linear element on alphabet CF(3)^2 with 2-dimensional stateset>
## gap> Display(Activity(shift,2));
## [ [     1,     0,     0,     0 ],
##   [  E(3),     1,     0,     0 ],
##   [     0,  E(3),     1,     0 ],
##   [     0,     0,  E(3),     1 ] ]
## gap> Display(Activity(TransposedFRElement(shift),2));
## [ [     1,  E(3),     0,     0 ],
##   [     0,     1,  E(3),     0 ],
##   [     0,     0,     1,  E(3) ],
##   [     0,     0,     0,     1 ] ]
## gap> IsSymmetricFRElement(shift);
## false
## gap> IsSymmetricFRElement(shift+TransposedFRElement(shift));
## true
## gap> IsLowerTriangularFRElement(shift);
## true
## gap> IsUpperTriangularFRElement(shift);
## false
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="LDUDecompositionFRElement" Arg="e"/>
##   <Returns>A factorization <M>e=LDU</M>.</Returns>
##   <Description>
##     Given a linear element <A>e</A>, this command attempts to find a
##     decomposition of the form <M>e=LDU</M>, where <M>L</M> is lower
##     triangular, <M>D</M> is diagonal, and <M>U</M> is upper triangular
##     (see <Ref Prop="IsLowerTriangularFRElement"/> etc.).
##
##     <P/> The result is returned thas a list with entries <M>L,D,U</M>.
##     Note that it is not guaranteed to succeed. For more examples, see
##     Section <Ref Label="bacher"/>.
## <Example><![CDATA[
## gap> List([0..7],s->List([0..7],t->E(4)^ValuationInt(Binomial(s+t,s),2)));;
## gap> A := GuessVectorElement(last);
## <Linear element on alphabet GaussianRationals^2 with 2-dimensional stateset>
## gap> LDU := LDUDecompositionFRElement(A);
## [ <Linear element on alphabet GaussianRationals^2 with 4-dimensional stateset>,
##   <Linear element on alphabet GaussianRationals^2 with 3-dimensional stateset>,
##   <Linear element on alphabet GaussianRationals^2 with 4-dimensional stateset> ]
## gap> IsLowerTriangularFRElement(LDU[1]); IsDiagonalFRElement(LDU[2]);
## true
## true
## gap> TransposedFRElement(LDU[1])=LDU[3];
## true
## gap> Product(LDU)=A;
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="GuessVectorElement" Arg="m"/>
##   <Returns>A vector element that acts like <A>m</A>.</Returns>
##   <Description>
##     The arguments to this function include a matrix or list of matrices,
##     and an optional ring. The return value is a vector element, over the
##     ring if it was specified, that acts like the sequence of matrices.
##
##     <P/> If a single matrix is specified, then it is assumed to represent
##     a convergent element (see <Ref Prop="IsConvergent"/>).
##
##     <P/> This function returns <K>fail</K> if it believes that it does not
##     have enough information to make a reasonable guess.
## <Example><![CDATA[
## gap> n := 3;;
## gap> shift := VectorElement(CyclotomicField(n), [[[[1,0],[0,0]],
##      [[0,0],[0,1]]],[[[0,1],[0,0]],,[[1,0],[0,0]]]],[1,E(n)],[1,0]);;
## <Linear element on alphabet CF(3)^2 with 2-dimensional stateset>
## gap> GuessVectorElement(Activity(shift,3)); last=shift;
## <Linear element on alphabet CF(3)^2 with 2-dimensional stateset>
## true
## gap> GuessVectorElement(Inverse(Activity(shift,4)));
## fail
## gap> GuessVectorElement(Inverse(Activity(shift,5)));
## <Linear element on alphabet CF(3)^2 with 4-dimensional stateset>
## gap> IsOne(last*shift);
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("Transitions", [IsLinearFRMachine, IsVector, IsVector]);
DeclareOperation("Transition", [IsLinearFRMachine, IsVector, IsVector, IsVector]);

DeclareOperation("NestedMatrixState", [IsLinearFRElement, IsList, IsList]);
DeclareOperation("NestedMatrixCoefficient", [IsLinearFRElement, IsList, IsList]);

DeclareOperation("ActivitySparse", [IsLinearFRElement, IsInt]);
DeclareOperation("Activities", [IsLinearFRElement, IsInt]);
DeclareGlobalFunction("GuessVectorElement");

DeclareProperty("IsConvergent", IsLinearFRElement);
DeclareOperation("TransposedFRElement", [IsLinearFRElement]);
DeclareProperty("IsSymmetricFRElement", IsLinearFRElement);
DeclareProperty("IsAntisymmetricFRElement", IsLinearFRElement);
DeclareProperty("IsLowerTriangularFRElement", IsLinearFRElement);
DeclareProperty("IsUpperTriangularFRElement", IsLinearFRElement);
DeclareProperty("IsDiagonalFRElement", IsLinearFRElement);

DeclareOperation("LDUDecompositionFRElement", [IsLinearFRElement]);
#############################################################################

#############################################################################
##
#O VectorMachineNC(IsFamily,IsTransitionTensor,IsVector)
#O VectorElementNC(IsFamily,IsTransitionTensor,IsVector,IsVector)
#O VectorMachine(IsRing,IsTransitionTensor,IsVector)
#O VectorElement(IsRing,IsTransitionTensor,IsVector,IsVector[,category])
#O VectorElement(IsRing,IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector)
##
## <#GAPDoc Label="VectorMachine">
## <ManSection>
##   <Oper Name="VectorMachine" Arg="domain, transitions, output"/>
##   <Oper Name="VectorElement" Arg="domain, transitions, output, init"/>
##   <Oper Name="VectorMachineNC" Arg="fam, transitions, output"/>
##   <Oper Name="VectorElementNC" Arg="fam, transitions, output, init, category"/>
##   <Returns>A new vector machine/element.</Returns>
##   <Description>
##     This function constructs a new linear machine or element, of vector type.
##
##     <P/> <A>transitions</A> is a matrix of matrices; for <C>a,b</C> indices
##     of basis vectors of the alphabet, <C>transitions[a][b]</C> is a square
##     matrix indexed by the stateset, which is the transition to be effected
##     on the stateset upon the output <M>a\to b</M>.
##
##     <P/> The optional last argument <A>category</A> specifies a category
##     (<Ref Filt="IsAssociativeElement" BookName="ref"/>,
##     <Ref Filt="IsJacobianElement" BookName="ref"/>,...) to which the new element
##     should belong.
##
##     <P/> <A>output</A> and <A>init</A> are vectors in the stateset.
##
##     <P/> In the "NC" version, no tests are performed to check that the
##     arguments contain values within bounds, or even of the right type
##     (beyond the simple checking performed by &GAP;'s method selection
##     algorithms). The first argument should be the family of the resulting
##     object. These "NC" methods are mainly used internally by the package.
## <Example><![CDATA[
## gap> M := VectorMachine(Rationals,[[[[1]],[[2]]],[[[3]],[[4]]]],[1]);
## <Linear machine on alphabet Rationals^2 with 1-dimensional stateset>
## gap> Display(M);
##  Rationals | 1 | 2 |
## -----------+---+---+
##          1 | 1 | 2 |
## -----------+---+---+
##          2 | 3 | 4 |
## -----------+---+---+
## Output: 1
## gap> A := VectorElement(Rationals,[[[[1]],[[2]]],[[[3]],[[4]]]],[1],[1]);
## <Linear element on alphabet Rationals^2 with 1-dimensional stateset>
## gap> Display(Activity(A,2));
## [ [   1,   2,   2,   4 ],
##   [   3,   4,   6,   8 ],
##   [   3,   6,   4,   8 ],
##   [   9,  12,  12,  16 ] ]
## gap> DecompositionOfFRElement(A);
## [ [ <Linear element on alphabet Rationals^2 with 1-dimensional stateset>,
##       <Linear element on alphabet Rationals^2 with 1-dimensional stateset> ],
##   [ <Linear element on alphabet Rationals^2 with 1-dimensional stateset>,
##       <Linear element on alphabet Rationals^2 with 1-dimensional stateset> ] ]
## gap> last=[[A,2*A],[3*A,4*A]];
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AssociativeObject" Arg="x"/>
##   <Returns>An associative object related to <A>x</A>.</Returns>
##   <Description>
##     If <A>x</A> belongs to a family that admits a non-associative and
##     an associative product, and the product of <A>x</A> is non-associative,
##     this function returns the object corresponding to <A>x</A>, but with
##     associative product.
##
##     <P/> A typical example is that <A>x</A> is a derivation of a vector
##     space. The product of derivations is <M>a\circ b-b\circ a</M>, and is
##     not associative; but derivations are endomorphisms of the vector space,
##     and as such can be composed associatively.
## <Example><![CDATA[
## gap> A := VectorElement(Rationals,[[[[0]],[[1]]],[[[1]],[[0]]]],[1],[1],IsJacobianElement);
## <Linear element on alphabet Rationals^2 with 1-dimensional stateset->
## gap> A^2;
## <Zero linear element on alphabet Rationals^2->
## gap> AssociativeObject(A)^2;
## <Identity linear element on alphabet Rationals^2>
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("VectorMachineNC", [IsFamily,IsTransitionTensor,IsVector]);
DeclareOperation("VectorElementNC", [IsFamily,IsTransitionTensor,IsVector,IsVector]);

DeclareOperation("VectorMachine", [IsRing,IsTransitionTensor,IsVector]);
DeclareOperation("VectorElement", [IsRing,IsTransitionTensor,IsVector,IsVector]);
DeclareOperation("VectorElement", [IsRing,IsTransitionTensor,IsVector,IsVector,IsOperation]);

DeclareOperation("TopElement", [IsRing, IsMatrix]);

DeclareAttribute("AssociativeObject",IsObject);
#############################################################################

#############################################################################
##
#O AsLinearMachine
#O AsLinearElement
#O AsVectorMachine
#O AsVectorElement
#O AsAlgebraMachine
#O AsAlgebraElement
##
## <#GAPDoc Label="AsLinearMachine">
## <ManSection>
##   <Oper Name="AsLinearMachine" Arg="r, m"/>
##   <Oper Name="AsLinearElement" Arg="r, m"/>
##   <Returns>The linear machine/element associated with <A>m</A>.</Returns>
##   <Description>
##     This command accepts a domain and an ordinary machine/element, and
##     constructs the corresponding linear machine/element, defined by
##     extending linearly the action on <M>[1..d]</M> to an action on
##     <M>r^d</M>.
##
##     <P/> If <A>m</A> is a Mealy machine/element, the result is a vector
##     machine/element. If <A>m</A> is a group/monoid/semigroup
##     machine/element, the result is an algebra machine/element.
##
##     To obtain explicitly a vector or algebra machine/element, see
##     <Ref Oper="AsVectorMachine"/> and <Ref Oper="AsAlgebraMachine"/>.
## <Example><![CDATA[
## gap> Display(I4Machine);
##    |  1     2
## ---+-----+-----+
##  a | c,2   c,1
##  b | a,1   b,1
##  c | c,1   c,2
## ---+-----+-----+
## gap> A := AsLinearMachine(Rationals,I4Machine);
## <Linear machine on alphabet Rationals^2 with 3-dimensional stateset>
## Correspondence(A);
## [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
## gap> Display(A);
##  Rationals |   1   |   2   |
## -----------+-------+-------+
##          1 | 0 0 0 | 0 0 1 |
##            | 1 0 0 | 0 0 0 |
##            | 0 0 1 | 0 0 0 |
## -----------+-------+-------+
##          2 | 0 0 1 | 0 0 0 |
##            | 0 1 0 | 0 0 0 |
##            | 0 0 0 | 0 0 1 |
## -----------+-------+-------+
## Output: 1 1 1
## gap> B := AsLinearMachine(Rationals,AsMonoidFRMachine(I4Machine));
## <Linear machine on alphabet Rationals^2 with generators [ (1)*m1, (1)*m2 ]>
## gap> Correspondence(B);
## MappingByFunction( <free monoid on the generators [ m1, m2 ]>,
## <algebra-with-one over Rationals, with 2 generators>, function( w ) ... end )
## gap> Display(B);
##  Rationals | 1  | 2  |
## -----------+----+----+
##          1 |  0 |  1 |
##            | m1 |  0 |
## -----------+----+----+
##          2 |  1 |  0 |
##            | m2 |  0 |
## -----------+----+----+
## Output: 1 1
## gap> AsLinearElement(Rationals,I4Monoid.1)*AsLinearElement(Rationals,I4Monoid.2);
## <Linear element on alphabet Rationals^2 with 4-dimensional stateset>
## gap> last=AsLinearElement(Rationals,I4Monoid.1*I4Monoid.2);
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AsVectorMachine" Arg="r, m"/>
##   <Oper Name="AsVectorElement" Arg="r, m"/>
##   <Returns>The vector machine/element associated with <A>m</A>.</Returns>
##   <Description>
##     This command accepts a domain and an ordinary machine/element, and
##     constructs the corresponding linear machine/element, defined by
##     extending linearly the action on <M>[1..d]</M> to an action on
##     <M>r^d</M>.
##
##     For this command to succeed, the machine/element <A>m</A> must be
##     finite state. For examples see <Ref Oper="AsLinearMachine"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AsAlgebraMachine" Arg="r, m"/>
##   <Oper Name="AsAlgebraElement" Arg="r, m"/>
##   <Returns>The algebra machine/element associated with <A>m</A>.</Returns>
##   <Description>
##     This command accepts a domain and an ordinary machine/element, and
##     constructs the corresponding linear machine/element, defined by
##     extending linearly the action on <M>[1..d]</M> to an action on
##     <M>r^d</M>.
##
##     For examples see <Ref Oper="AsLinearMachine"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AsVectorMachine" Arg="m" Label="Linear machine"/>
##   <Oper Name="AsVectorElement" Arg="m" Label="Linear machine"/>
##   <Returns>The machine/element <A>m</A> in vector form.</Returns>
##   <Description>
##     This command accepts a linear machine, and converts it to
##     vector form. This command is not guaranteed to terminate.
## <Example><![CDATA[
## gap> A := AsLinearElement(Rationals,I4Monoid.1);
## <Linear element on alphabet Rationals^2 with 2-dimensional stateset>
## gap> B := AsAlgebraElement(A);
## <Rationals^2|(1)*x.1>
## gap> C := AsVectorElement(B);
## gap> A=B; B=C;
## true
## true
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AsAlgebraMachine" Arg="m" Label="Linear machine"/>
##   <Oper Name="AsAlgebraElement" Arg="m" Label="Linear machine"/>
##   <Returns>The machine/element <A>m</A> in algebra form.</Returns>
##   <Description>
##     This command accepts a linear machine, and converts it to
##     algebra form.
## <Example><![CDATA[
## gap> A := AsLinearElement(Rationals,I4Monoid.1);
## <Linear element on alphabet Rationals^2 with 2-dimensional stateset>
## gap> AsAlgebraElement(A)=AsAlgebraElement(Rationals,I4Monoid.1);
## true
## gap> A=AsAlgebraElement(A);
## true
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("AsLinearMachine", [IsRing,IsFRMachine]);
DeclareOperation("AsLinearElement", [IsRing,IsFRElement]);

DeclareOperation("AsVectorMachine", [IsRing,IsFRMachine]);
DeclareOperation("AsVectorElement", [IsRing,IsFRElement]);
DeclareOperation("AsVectorMachine", [IsLinearFRMachine]);
DeclareOperation("AsVectorMachine", [IsVectorSpace and IsFRElementCollection]);
DeclareOperation("AsVectorElement", [IsLinearFRElement]);

DeclareOperation("AsAlgebraMachine", [IsRing,IsFRMachine]);
DeclareOperation("AsAlgebraElement", [IsRing,IsFRElement]);
DeclareOperation("AsAlgebraMachine", [IsLinearFRMachine]);
DeclareOperation("AsAlgebraElement", [IsLinearFRElement]);
#############################################################################

#############################################################################
##
#R IsAlgebraFRMachineRep
##
## <#GAPDoc Label="IsAlgebraFRMachineRep">
## <ManSection>
##   <Filt Name="IsAlgebraFRMachineRep" Arg="obj"/>
##   <Returns><K>true</K> if <A>obj</A> is an algebra machine</Returns>
##   <Description>
##     An <E>algebra machine</E> is a representation of a linear machine by
##     a finitely generated free algebra, a tensor of transitions, indexed
##     by generator index and two alphabet indices, and an output vector,
##     indexed by a generator index.
##
##     <P/> The transition tensor's last two entries are the 0 and 1 matrix
##     over the free algebra, and the output tensor's last two entries are
##     the 0 and 1 elements of the left acting domain.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareRepresentation("IsAlgebraFRMachineRep",
        IsComponentObjectRep and IsAttributeStoringRep,
        ["free","transitions","output"]);
#############################################################################

#############################################################################
##
#O AlgebraMachineNC(IsFamily,IsFreeMagmaRing,IsTransitionTensor,IsVector)
#O AlgebraElementNC(IsFamily,IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector)
#O AlgebraMachine(IsRing,IsFreeMagmaRing,IsTransitionTensor,IsVector)
#O AlgebraMachine(IsFreeMagmaRing,IsTransitionTensor,IsVector)
#O AlgebraElement(IsRing,IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector)
#O AlgebraElement(IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector)
##
## <#GAPDoc Label="AlgebraMachine">
## <ManSection>
##   <Oper Name="AlgebraMachine" Arg="[domain] ring, transitions, output"/>
##   <Oper Name="AlgebraElement" Arg="[domain] ring, transitions, output, init"/>
##   <Oper Name="AlgebraMachineNC" Arg="fam, ring, transitions, output"/>
##   <Oper Name="AlgebraElementNC" Arg="fam, ring, transitions, output, init"/>
##   <Returns>A new algebra machine/element.</Returns>
##   <Description>
##     This function constructs a new linear machine or element, of algebra type.
##
##     <P/> <A>ring</A> is a free associative algebra, optionally with one.
##     <A>domain</A> is the vector space on which the alphabet is defined. If
##     absent, this argument defaults to the <Ref Meth="LeftActingDomain"
##     BookName="ref"/> of <A>ring</A>.
##
##     <P/> <A>transitions</A> is a list of matrices; for each generator
##     number <M>i</M> of <A>ring</A>, the matrix <C>transitions[i]</C>,
##     with entries in <A>ring</A>, describes the decomposition of generator
##     <M>i</M> as a matrix.
##
##     <P/> <A>output</A> is a vector over <A>domain</A>, and <A>init</A>
##     is a vector over <A>ring</A>.
##
##     <P/> In the "NC" version, no tests are performed to check that the
##     arguments contain values within bounds, or even of the right type
##     (beyond the simple checking performed by &GAP;'s method selection
##     algorithms). The first argument should be the family of the resulting
##     object. These "NC" methods are mainly used internally by the package.
## <Example><![CDATA[
## gap> F := FreeAssociativeAlgebraWithOne(Rationals,1);;
## gap> A := AlgebraMachine(F,[[[F.1,F.1^2+F.1],[One(F),Zero(F)]]],[1]);
## <Linear machine on alphabet Rationals^2 with generators [ (1)*x.1 ]>
## gap> Display(A);
##  Rationals |     1     |     2     |
## -----------+-----------+-----------+
##          1 |       x.1 | x.1+x.1^2 |
## -----------+-----------+-----------+
##          2 |         1 |         0 |
## -----------+-----------+-----------+
## Output: 1
## gap> M := AlgebraElement(F,[[[F.1,F.1^2+F.1],[One(F),Zero(F)]]],[1],F.1);
## <Rationals^2|(1)*x.1>
## gap> Display(Activity(M,2));
## [ [  1,  2,  4,  4 ],
##   [  1,  0,  2,  2 ],
##   [  1,  0,  0,  0 ],
##   [  0,  1,  0,  0 ] ]
## ]]></Example>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("AlgebraMachineNC", [IsFamily,IsFreeMagmaRing,IsTransitionTensor,IsVector]);
DeclareOperation("AlgebraElementNC", [IsFamily,IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector]);

DeclareOperation("AlgebraMachine", [IsRing,IsFreeMagmaRing,IsTransitionTensor,IsVector]);
DeclareOperation("AlgebraMachine", [IsFreeMagmaRing,IsTransitionTensor,IsVector]);
DeclareOperation("AlgebraElement", [IsRing,IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector]);
DeclareOperation("AlgebraElement", [IsRing,IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector,IsOperation]);
DeclareOperation("FRElement", [IsFRMachine,IsObject,IsOperation]);
DeclareOperation("AlgebraElement", [IsFreeMagmaRing,IsTransitionTensor,IsVector,IsVector]);
#############################################################################

#E vector.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here
