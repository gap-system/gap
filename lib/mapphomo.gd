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
Revision.mapphomo_gd :=
    "@(#)$Id$";


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
#P  IsMonoidGeneralMapping( <mapp> )
##
IsMonoidGeneralMapping := IsGeneralMapping and RespectsMultiplication
                                           and RespectsOne;


#############################################################################
##
#P  IsGroupGeneralMapping( <mapp> )
##
IsGroupGeneralMapping := IsMonoidGeneralMapping and RespectsInverses;


#############################################################################
##
#P  IsMonoidHomomorphism( <mapp> )
##
IsMonoidHomomorphism := IsMapping and RespectsMultiplication and RespectsOne;


#############################################################################
##
#P  IsGroupHomomorphism( <mapp> )
##
IsGroupHomomorphism := IsMonoidHomomorphism and RespectsInverses;


#############################################################################
##
#A  KernelOfMonoidGeneralMapping( <mapp> )
##
##  is the kernel of the monoid general mapping <mapp>,
##  i.e., the set of all those elements in the source of <mapp>
##  that have the identity of the range of <mapp> in their set of images.
##
KernelOfMonoidGeneralMapping := NewAttribute(
    "KernelOfMonoidGeneralMapping", IsMonoidGeneralMapping );
SetKernelOfMonoidGeneralMapping := Setter( KernelOfMonoidGeneralMapping );
HasKernelOfMonoidGeneralMapping := Tester( KernelOfMonoidGeneralMapping );


#############################################################################
##
#A  CoKernelOfMonoidGeneralMapping( <mapp> )
##
##  is the cokernel of the monoid general mapping <mapp>,
##  i.e., the set of all those elements in the range of <mapp>
##  that have the identity of the source of <mapp> in their set of preimages.
##
CoKernelOfMonoidGeneralMapping := NewAttribute(
    "CoKernelOfMonoidGeneralMapping", IsMonoidGeneralMapping );
SetCoKernelOfMonoidGeneralMapping := Setter(
    CoKernelOfMonoidGeneralMapping );
HasCoKernelOfMonoidGeneralMapping := Tester(
    CoKernelOfMonoidGeneralMapping );


#############################################################################
##
#E  mapphomo.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



