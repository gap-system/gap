#############################################################################
##
#W  algsc.gd                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the design of elements of algebras given by structure
##  constants (s.c.).
##
##  An s. c. algebra is a free left module $A$ of fixed dimension $n$, say,
##  over a ring-with-one $R$, with multiplication defined on the vectors of
##  the standard basis $B$ of $A$ by the structure constants table.
##
##  A *full s.c. algebra* is an s.c. algebra that contains $B$.
##  (So a full s.c. algebra need *not* contain the whole family of its
##  elements.)
##
##  The family <Fam> of s.c. algebra elements consists of all linear
##  combinations of the basis vectors of $A$, with coefficients in a
##  suitable set.
##  If the elements family of $R$ has a uniquely determined zero element,
##  this set is the whole element family of $R$, and <Fam> has the
##  category 'IsFamilyOverFullCoefficientsFamily'.
##  Otherwise this set is $R$ itself, stored in the component
##  'coefficientsDomain' of <Fam>.
##  (Note that the zero element is already part of the s.c. table.)
##
##  In any case, the value of the attribute 'CoefficientsFamily' is
##  the elements family of the family of $R$.
##  (This is used in family predicates.)
##
##  S.c. algebra elements have an external representation, which is the
##  coefficients vector w.r.t. the standard basis.
##
##  The constructor for s.c. algebra elements is 'ObjByExtRep'.
##
Revision.algsc_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFamilyOverFullCoefficientsFamily( <Fam> )
##
##  If the family <Fam> has this category, all coefficients tuples over
##  'CoefficientsFamily( <Fam> )' describe valid elements of <Fam>.
##
##  (This tells mainly what 'ObjByExtRep' can assume resp. must test.)
##
IsFamilyOverFullCoefficientsFamily := NewCategory(
    "IsFamilyOverFullCoefficientsFamily", IsFamily );
#T other file?


#############################################################################
##
#C  IsSCAlgebraObj( <obj> )
#C  IsSCAlgebraObjCollection( <obj> )
#C  IsSCAlgebraObjFamily( <obj> )
##
##  S. c. algebra elements may have inverses, in order to allow 'One' and
##  'Inverse' we make them scalars.
##
IsSCAlgebraObj := NewCategory( "IsSCAlgebraObj", IsScalar );

IsSCAlgebraObjCollection := CategoryCollections( "IsSCAlgebraObjCollection",
    IsSCAlgebraObj );

IsSCAlgebraObjFamily := CategoryFamily( "IsSCAlgebraObjFamily",
    IsSCAlgebraObj );


#############################################################################
##
#P  IsFullSCAlgebra( <A> )
##
##  An s. c. algebra is a free left module $A$ of fixed dimension $n$, say,
##  over a ring-with-one $R$, with multiplication defined on the vectors of
##  the standard basis $B$ of $A$ by the structure constants table.
##
##  A *full s.c. algebra* is an s.c. algebra that contains $B$.
##  (So a full s.c. algebra need *not* contain the whole family of its
##  elements.)
##
IsFullSCAlgebra := NewProperty(
    "IsFullSCAlgebra", IsFLMLOR and IsSCAlgebraObjCollection );
SetIsFullSCAlgebra := Setter( IsFullSCAlgebra );
HasIsFullSCAlgebra := Tester( IsFullSCAlgebra );


#############################################################################
##
#P  IsCanonicalBasisFullSCAlgebra( <obj> )
##
##  The canonical basis of a full s.c. algebra consists of elements whose
##  external representations are standard basis vectors.
##
##  The canonical basis of a full s.c. algebra is constructed together with
##  the algebra.
##
IsCanonicalBasisFullSCAlgebra := NewProperty(
    "IsCanonicalBasisFullSCAlgebra", IsCanonicalBasis );


#############################################################################
##
#M  IsFiniteDimensional( <A> )  . . . . .  S.c. algebras are always fin. dim.
##
InstallTrueMethod( IsFiniteDimensional,
    IsFLMLOR and IsSCAlgebraObjCollection );


#############################################################################
##
#E  algsc.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



