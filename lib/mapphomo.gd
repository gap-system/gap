#############################################################################
##
#W  mapphomo.gd                 GAP library                     Thomas Breuer
#W                                                         and Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the definitions of properties of mappings preserving
##  algebraic structure.
##
##  1. properties and attributes of gen. mappings that respect multiplication
##  2. properties and attributes of gen. mappings that respect addition
##  3. properties and attributes of gen. mappings that respect scalar mult.
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##
Revision.mapphomo_gd :=
    "@(#)$Id$";


#############################################################################
##
##  1. properties and attributes of gen. mappings that respect multiplication
##

#############################################################################
##
#P  RespectsMultiplication( <mapp> )
##
##  Let <mapp> be a general mapping, viewed as a set $F \subseteq S \times R$
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then 'RespectsMultiplication' returns 'true' if
##  $S$ and $R$ are magmas such that
##  $(s_1,r_1), (s_2,r_2) \in F$ implies $(s_1 \* s_2,r_1 \* r_2) \in F$,
##  and 'false' otherwise.
##
##  If <mapp> is single-valued then 'RespectsMultiplication' returns 'true'
##  if and only if the equation
##  '<s1>^<mapp> * <s2>^<mapp> = (<s1>*<s2>)^<mapp>'
##  holds for all <s1>, <s2> in $S$.
##
RespectsMultiplication := NewProperty( "RespectsMultiplication",
    IsGeneralMapping );
SetRespectsMultiplication := Setter( RespectsMultiplication );
HasRespectsMultiplication := Tester( RespectsMultiplication );


#############################################################################
##
#P  RespectsOne( <mapp> )
##
##  Let <mapp> be a general mapping, viewed as a set $F \subseteq S \times R$
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then 'RespectsOne' returns 'true' if
##  $S$ and $R$ are magmas-with-one such that
##  $( 'One('S'), One('R')' ) \in F$,
##  and 'false' otherwise.
##
##  If <mapp> is single-valued then 'RespectsOne' returns 'true'
##  if and only if the equation
##  'One( S )^<mapp> = One( R )'
##  holds.
##
RespectsOne := NewProperty( "RespectsOne", IsGeneralMapping );
SetRespectsOne := Setter( RespectsOne );
HasRespectsOne := Tester( RespectsOne );


#############################################################################
##
#P  RespectsInverses( <mapp> )
##
##  Let <mapp> be a general mapping, viewed as a set $F \subseteq S \times R$
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then 'RespectsInverses' returns 'true' if
##  $S$ and $R$ are magmas-with-inverses such that
##  $(s,r) \in F$ implies $(s^{-1},r^{-1}) \in F$,
##  and 'false' otherwise.
##
##  If <mapp> is single-valued then 'RespectsInverses' returns 'true'
##  if and only if the equation
##  'Inverse( <s> )^<mapp> = Inverse( <s>^<mapp> )'
##  holds for all <s> in $S$.
##
RespectsInverses := NewProperty( "RespectsInverses", IsGeneralMapping );
SetRespectsInverses := Setter( RespectsInverses );
HasRespectsInverses := Tester( RespectsInverses );


#############################################################################
##
#M  RespectsOne( <mapp> )
##
InstallTrueMethod( RespectsOne,
    RespectsMultiplication and RespectsInverses );


#############################################################################
##
#P  IsGroupGeneralMapping( <mapp> )
#P  IsGroupHomomorphism( <mapp> )
##
IsGroupGeneralMapping :=
    IsGeneralMapping and RespectsMultiplication and RespectsInverses;

IsGroupHomomorphism := IsGroupGeneralMapping and IsMapping;


#############################################################################
##
#A  KernelOfMultiplicativeGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping that respects multiplication and one.
##  Then 'KernelOfMultiplicativeGeneralMapping' returns the set of all
##  elements in the source of <mapp> that have the identity of the range in
##  their set of images.
##
##  (This is a monoid if the source of <mapp> is associative.)
##
KernelOfMultiplicativeGeneralMapping := NewAttribute(
    "KernelOfMultiplicativeGeneralMapping",
    IsGeneralMapping and RespectsMultiplication and RespectsOne );
SetKernelOfMultiplicativeGeneralMapping := Setter(
    KernelOfMultiplicativeGeneralMapping );
HasKernelOfMultiplicativeGeneralMapping := Tester(
    KernelOfMultiplicativeGeneralMapping );


#############################################################################
##
#A  CoKernelOfMultiplicativeGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping that respects multiplication and one.
##  Then 'CoKernelOfMultiplicativeGeneralMapping' returns the set of all
##  elements in the range of <mapp> that have the identity of the source in
##  their set of preimages.
##
##  (This is a monoid if the range of <mapp> is associative.)
##
CoKernelOfMultiplicativeGeneralMapping := NewAttribute(
    "CoKernelOfMultiplicativeGeneralMapping",
    IsGeneralMapping and RespectsMultiplication and RespectsOne );
SetCoKernelOfMultiplicativeGeneralMapping := Setter(
    CoKernelOfMultiplicativeGeneralMapping );
HasCoKernelOfMultiplicativeGeneralMapping := Tester(
    CoKernelOfMultiplicativeGeneralMapping );


#############################################################################
##
##  2. properties and attributes of gen. mappings that respect addition
##

#############################################################################
##
#P  RespectsAddition( <mapp> )
##
##  Let <mapp> be a general mapping, viewed as a set $F \subseteq S \times R$
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then 'RespectsAddition' returns 'true' if
##  $S$ and $R$ are additive magmas such that
##  $(s_1,r_1), (s_2,r_2) \in F$ implies $(s_1 + s_2,r_1 + r_2) \in F$,
##  and 'false' otherwise.
##
##  If <mapp> is single-valued then 'RespectsAddition' returns 'true'
##  if and only if the equation
##  '<s1>^<mapp> + <s2>^<mapp> = (<s1>+<s2>)^<mapp>'
##  holds for all <s1>, <s2> in $S$.
##
RespectsAddition := NewProperty( "RespectsAddition", IsGeneralMapping );
SetRespectsAddition := Setter( RespectsAddition );
HasRespectsAddition := Tester( RespectsAddition );


#############################################################################
##
#P  RespectsZero( <mapp> )
##
##  Let <mapp> be a general mapping, viewed as a set $F \subseteq S \times R$
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then 'RespectsZero' returns 'true' if
##  $S$ and $R$ are additive-magmas-with-zero such that
##  $( 'Zero('S'), Zero('R')' ) \in F$,
##  and 'false' otherwise.
##
##  If <mapp> is single-valued then 'RespectsZero' returns 'true'
##  if and only if the equation
##  'Zero( S )^<mapp> = Zero( R )'
##  holds.
##
RespectsZero := NewProperty( "RespectsZero", IsGeneralMapping );
SetRespectsZero := Setter( RespectsZero );
HasRespectsZero := Tester( RespectsZero );


#############################################################################
##
#P  RespectsAdditiveInverses( <mapp> )
##
##  Let <mapp> be a general mapping, viewed as a set $F \subseteq S \times R$
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then 'RespectsAdditiveInverses' returns 'true' if
##  $S$ and $R$ are additive-magmas-with-inverses such that
##  $(s,r) \in F$ implies $(-s,-r) \in F$,
##  and 'false' otherwise.
##
##  If <mapp> is single-valued then 'RespectsAdditiveInverses' returns 'true'
##  if and only if the equation
##  'AdditiveInverse( <s> )^<mapp> = AdditiveInverse( <s>^<mapp> )'
##  holds for all <s> in $S$.
##
RespectsAdditiveInverses := NewProperty( "RespectsAdditiveInverses",
    IsGeneralMapping );
SetRespectsAdditiveInverses := Setter( RespectsAdditiveInverses );
HasRespectsAdditiveInverses := Tester( RespectsAdditiveInverses );


#############################################################################
##
#M  RespectsZero( <mapp> )
##
InstallTrueMethod( RespectsZero,
    RespectsAddition and RespectsAdditiveInverses );


#############################################################################
##
#P  IsAdditiveGroupGeneralMapping( <mapp> )
#P  IsAdditiveGroupHomomorphism( <mapp> )
##
IsAdditiveGroupGeneralMapping :=
    IsGeneralMapping and RespectsAddition and RespectsAdditiveInverses;

IsAdditiveGroupHomomorphism := IsAdditiveGroupGeneralMapping and IsMapping;


#############################################################################
##
#A  KernelOfAdditiveGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping that respects addition and zero.
##  Then 'KernelOfAdditiveGeneralMapping' returns the set of all
##  elements in the source of <mapp> that have the zero of the range in
##  their set of images.
##
KernelOfAdditiveGeneralMapping := NewAttribute(
    "KernelOfAdditiveGeneralMapping",
    IsGeneralMapping and RespectsAddition and RespectsZero );
SetKernelOfAdditiveGeneralMapping := Setter(
    KernelOfAdditiveGeneralMapping );
HasKernelOfAdditiveGeneralMapping := Tester(
    KernelOfAdditiveGeneralMapping );


#############################################################################
##
#A  CoKernelOfAdditiveGeneralMapping( <mapp> )
##
##  Let <mapp> be a general mapping that respects addition and zero.
##  Then 'KernelOfAdditiveGeneralMapping' returns the set of all
##  elements in the source of <mapp> that have the zero of the range in
##  their set of images.
##
CoKernelOfAdditiveGeneralMapping := NewAttribute(
    "CoKernelOfAdditiveGeneralMapping",
    IsGeneralMapping and RespectsAddition and RespectsZero );
SetCoKernelOfAdditiveGeneralMapping := Setter(
    CoKernelOfAdditiveGeneralMapping );
HasCoKernelOfAdditiveGeneralMapping := Tester(
    CoKernelOfAdditiveGeneralMapping );


#############################################################################
##
##  3. properties and attributes of gen. mappings that respect scalar mult.
##

#############################################################################
##
#P  RespectsScalarMultiplication( <mapp> )
##
##  Let <mapp> be a general mapping, viewed as a set $F \subseteq S \times R$
##  where $S$ and $R$ are the source and the range of <mapp>, respectively.
##  Then 'RespectsScalarMultiplication' returns 'true' if
##  $S$ and $R$ are left modules with the left acting domain $D$ of $S$
##  contained in the left acting domain of $R$ and such that
##  $(s,r) \in F$ implies $(c \* s,c \* r) \in F$ for all $c \in D$,
##  and 'false' otherwise.
##
##  If <mapp> is single-valued then 'RespectsScalarMultiplication' returns
##  'true' if and only if the equation
##  '<c> \* <s>^<mapp> = (<c> \* <s>)^<mapp>'
##  holds for all <c> in $D$ and <s> in $S$.
##
RespectsScalarMultiplication := NewProperty( "RespectsScalarMultiplication",
    IsGeneralMapping );
SetRespectsScalarMultiplication := Setter( RespectsScalarMultiplication );
HasRespectsScalarMultiplication := Tester( RespectsScalarMultiplication );


#############################################################################
##
#P  IsLeftModuleGeneralMapping( <mapp> )
#P  IsLeftModuleHomomorphism( <mapp> )
##
IsLeftModuleGeneralMapping := IsAdditiveGroupGeneralMapping
    and RespectsScalarMultiplication;

IsLeftModuleHomomorphism := IsLeftModuleGeneralMapping and IsMapping;


#############################################################################
##
#O  IsLinearMapping( <F>, <mapp> )
##
##  is 'true' if <mapp> is an <F>-linear general mapping,
##  and 'false' otherwise.
##
IsLinearMapping := NewOperation( "IsLinearMapping",
    [ IsDomain, IsGeneralMapping ] );


#############################################################################
##
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##

#############################################################################
##
#P  IsRingGeneralMapping( <mapp> )
#P  IsRingHomomorphism( <mapp> )
##
IsRingGeneralMapping := IsGeneralMapping and RespectsMultiplication
    and IsAdditiveGroupGeneralMapping;

IsRingHomomorphism := IsRingGeneralMapping and IsMapping;


#############################################################################
##
#P  IsRingWithOneGeneralMapping( <mapp> )
#P  IsRingWithOneHomomorphism( <mapp> )
##
IsRingWithOneGeneralMapping := IsRingGeneralMapping and RespectsOne;

IsRingWithOneHomomorphism := IsRingWithOneGeneralMapping and IsMapping;


#############################################################################
##
#P  IsAlgebraGeneralMapping( <mapp> )
#P  IsAlgebraHomomorphism( <mapp> )
##
IsAlgebraGeneralMapping := IsRingGeneralMapping
    and IsLeftModuleGeneralMapping;

IsAlgebraHomomorphism := IsAlgebraGeneralMapping and IsMapping;


#############################################################################
##
#P  IsAlgebraWithOneGeneralMapping( <mapp> )
#P  IsAlgebraWithOneHomomorphism( <mapp> )
##
IsAlgebraWithOneGeneralMapping := IsAlgebraGeneralMapping and RespectsOne;

IsAlgebraWithOneHomomorphism := IsAlgebraWithOneGeneralMapping and IsMapping;


#############################################################################
##
#P  IsFieldHomomorphism( <mapp> )
##
##  A general mapping is a field homomorphism if and only if it is
##  a ring homomorphism with source a field.
##
IsFieldHomomorphism := NewProperty( "IsFieldHomomorphism",
    IsGeneralMapping );

InstallTrueMethod( IsAlgebraHomomorphism, IsFieldHomomorphism );


#############################################################################
##
#E  mapphomo.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



