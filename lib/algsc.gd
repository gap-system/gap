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
##  This file contains the design of elements of algebras given by structure
##  constants (s.~c.).
##
##  An s.~c. algebra is a free left module $A$ of fixed dimension $n$
##  over a ring-with-one $R$, with multiplication defined on the vectors of
##  the standard basis $B$ of $A$ by the structure constants table.
##
##  A *full s.~c. algebra* is an s.c. algebra that contains $B$.
##  (So a full s.~c. algebra need *not* contain the whole family of its
##  elements.)
##
##  The family <Fam> of s.~c. algebra elements consists of all linear
##  combinations of the basis vectors of $A$, with coefficients in a
##  suitable set.
##  If the elements family of $R$ has a uniquely determined zero element,
##  this set is the whole element family of $R$, and <Fam> has the
##  category `IsFamilyOverFullCoefficientsFamily'.
##  Otherwise this set is $R$ itself, stored in the component
##  `coefficientsDomain' of <Fam>.
##  (Note that the zero element is already part of the s.~c. table.)
##
##  In any case, the value of the attribute `CoefficientsFamily' is
##  the elements family of the family of $R$.
##  (This is used in family predicates.)
##
##  S.~c. algebra elements have an external representation, which is the
##  coefficients vector w.r.t. the standard basis.
##
##  The constructor for s.~c. algebra elements is `ObjByExtRep'.
##


#############################################################################
##
#F  SCTableEntry
##
DeclareSynonym( "SCTableEntry", SC_TABLE_ENTRY );


#############################################################################
##
#F  SCTableProduct
##
DeclareSynonym( "SCTableProduct", SC_TABLE_PRODUCT );


#############################################################################
##
#C  IsFamilyOverFullCoefficientsFamily( <Fam> )
##
##  If the family <Fam> has this category, all coefficients tuples over
##  `CoefficientsFamily( <Fam> )' describe valid elements of <Fam>.
##
##  (This tells mainly what `ObjByExtRep' can assume resp. must test.)
##
DeclareCategory( "IsFamilyOverFullCoefficientsFamily", IsFamily );
#T other file?


#############################################################################
##
#C  IsSCAlgebraObj( <obj> )
#C  IsSCAlgebraObjCollection( <obj> )
#C  IsSCAlgebraObjFamily( <obj> )
##
##  S.~c. algebra elements may have inverses, in order to allow `One' and
##  `Inverse' we make them scalars.
##
DeclareCategory( "IsSCAlgebraObj", IsScalar );
DeclareCategoryCollections( "IsSCAlgebraObj" );
DeclareCategoryCollections( "IsSCAlgebraObjCollection" );
DeclareCategoryCollections( "IsSCAlgebraObjCollColl" );
DeclareCategoryFamily( "IsSCAlgebraObj" );


#############################################################################
##
#P  IsFullSCAlgebra( <A> )
##
##  An s.~c. algebra is a free left module $A$ over a ring-with-one $R$,
##  with multiplication defined on the vectors of the standard basis $B$
##  of an algebra $\hat{A}$ containing $A$ by the structure constants table
##  of $\hat{A}$.
##
##  $A$ is a *full s.~c. algebra* if it contains $B$.
##  (So a full s.~c. algebra need *not* contain the whole family of its
##  elements.)
#T Do we really need this in addition to `IsFullFPAlgebra',
#T or would it be misuse to take `IsFullFPAlgebra' here?
##
DeclareProperty( "IsFullSCAlgebra", IsFLMLOR and IsSCAlgebraObjCollection );


#############################################################################
##
#P  IsCanonicalBasisFullSCAlgebra( <B> )
##
##  is `true' if the underlying free left module of the basis <B> is a full
##  s.~c. algebra and <B> is equal to its canonical basis,
##  and `false' otherwise.
##
##  The canonical basis of a full s.~c. algebra consists of elements whose
##  external representations are standard basis vectors.
##
##  (The canonical basis of a full s.~c. algebra is constructed together with
##  the algebra.)
##
DeclareProperty( "IsCanonicalBasisFullSCAlgebra", IsBasis );

InstallTrueMethod( IsCanonicalBasis, IsCanonicalBasisFullSCAlgebra );


#############################################################################
##
#F  IsSCAlgebraObjSpace( <V> )
##
##  If an $F$-vector space <V> is in the filter `IsSCAlgebraObjSpace' then
##  this expresses that <V> consists of elements in a s.c. algebra,
##  and that <V> can be handled via the mechanism of nice bases
##  (see~"Vector Spaces Handled By Nice Bases"), in the following way.
##  The `NiceFreeLeftModuleInfo' value of <V> is irrelevant,
##  and the `NiceVector' value of $v \in <V>$ is defined as
##  $`ExtRepOfObj'( v )$.
##
DeclareHandlingByNiceBasis( "IsSCAlgebraObjSpace",
    "for free left modules of s.c. algebra elements" );


#############################################################################
##
#M  IsFiniteDimensional( <A> )  . . . . . S.~c. algebras are always fin. dim.
##
InstallTrueMethod( IsFiniteDimensional,
    IsFreeLeftModule and IsSCAlgebraObjCollection );
