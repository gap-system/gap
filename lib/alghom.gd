#############################################################################
##
#W  alghom.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains declarations of operations for algebra(-with-one)
##  homomorphisms.
##
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
#O  AlgebraHomomorphismByImages( <A>, <B>, <gens>, <imgs> )
##
AlgebraGeneralMappingByImages := NewOperation(
    "AlgebraGeneralMappingByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );

AlgebraHomomorphismByImages := NewOperation(
    "AlgebraHomomorphismByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  AlgebraWithOneGeneralMappingByImages( <A>, <B>, <gens>, <imgs> )
#O  AlgebraWithOneHomomorphismByImages( <A>, <B>, <gens>, <imgs> )
##
AlgebraWithOneGeneralMappingByImages := NewOperation(
    "AlgebraWithOneGeneralMappingByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );

AlgebraWithOneHomomorphismByImages := NewOperation(
    "AlgebraWithOneHomomorphismByImages",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  NaturalHomomorphismByIdeal( <A>, <I> )  . . . . . map onto factor algebra
##
NaturalHomomorphismByIdeal := NewOperation( "NaturalHomomorphismByIdeal",
    [ IsFLMLOR, IsFLMLOR ] );


#############################################################################
##
#O  OperationAlgebraHomomorphism( <A>, <D>[, <opr>] )
##
##  `OperationAlgebraHomomorphism' returns an algebra homomorphism from the
##  algebra <A> into a matrix algebra that describes the linear action of <A>
##  on the free left module resp. basis <D>, via the operation <opr>.
##  The homomorphism need not be surjective.
##
##  The default value for <opr> is `OnRight'.
##
##  If <A> is an algebra-with-one then the operation homomorphism is an
##  algebra-with-one homomorphism because the identity of <A> must act
##  trivially.
##  (Of course this holds especially if <D> is in the kernel of the action.)
##
OperationAlgebraHomomorphism := NewOperation( "OperationAlgebraHomomorphism",
    [ IsFLMLOR, IsBasis, IsFunction ] );


#############################################################################
##
#A  IsomorphismFpFLMLOR( <A> )
##
##  isomorphism from the FLMLOR <A> onto a finitely presented FLMLOR
##
IsomorphismFpFLMLOR := NewAttribute( "IsomorphismFpFLMLOR", IsFLMLOR );
SetIsomorphismFpFLMLOR := Setter( IsomorphismFpFLMLOR );
HasIsomorphismFpFLMLOR := Setter( IsomorphismFpFLMLOR );

IsomorphismFpAlgebra := IsomorphismFpFLMLOR;
SetIsomorphismFpAlgebra := SetIsomorphismFpFLMLOR;
HasIsomorphismFpAlgebra := HasIsomorphismFpFLMLOR;


#############################################################################
##
#A  IsomorphismMatrixFLMLOR( <A> )
##
##  isomorphism from the FLMLOR <A> onto a matrix FLMLOR
##
IsomorphismMatrixFLMLOR := NewAttribute( "IsomorphismMatrixFLMLOR",
    IsFLMLOR );
SetIsomorphismMatrixFLMLOR := Setter( IsomorphismMatrixFLMLOR );
HasIsomorphismMatrixFLMLOR := Setter( IsomorphismMatrixFLMLOR );

IsomorphismMatrixAlgebra := IsomorphismMatrixFLMLOR;
SetIsomorphismMatrixAlgebra := SetIsomorphismMatrixFLMLOR;
HasIsomorphismMatrixAlgebra := HasIsomorphismMatrixFLMLOR;


#############################################################################
##
#O  RepresentativeLinearOperation( <A>, <v>, <w>, <opr> )
##
##  is an element of the FLMLOR <A> that maps the vector <v>
##  to the vector <w> under the linear operation described by the function
##  <opr>.
##
#T Would it be desirable to put this under `RepresentativeOperation'?
#T (look at the code before you agree ...)
##
RepresentativeLinearOperation := NewOperation(
    "RepresentativeLinearOperation",
    [ IsFLMLOR, IsVector, IsVector, IsFunction ] );


#############################################################################
##
#E  alghom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



