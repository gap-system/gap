#############################################################################
##
#W  overload.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration and methods of ``overloaded''
##  operations, that is, operations for which the meaning of the result
##  depends on the arguments.
##
##  Examples are 'IsSolvable' and 'IsNilpotent' (where we have methods for
##  groups and for algebras), and 'Kernel' (which in the case of a group
##  homomorphism means the elements mapped to the identity of the range,
##  in the case of a ring homomorphism means those mapped to the zero,
##  and in the case of a group character means those mapped to the
##  character degree).
##
##  In these examples we seem to be safe, as no object can be both a group
##  and an algebra.
##
##  Such non-qualified operations should be kept to a minimum.
##  (Remember the problems we had with 'NewObject'.)
##
##  Note that operations such as 'IsCommutative' are not of this kind,
##  since the result means the same for any multiplicative structure.
##  
##  The key requirement is that no object ever exists which inherits from
##  two kinds with distinct meanings.
##  If this ever happens, there *must* be a method installed for the join
##  of the relevant categories which decides which meaning applies,
##  otherwise the meaning of the operation is at the mercy of the ranking
##  system.
##
##  The guideline for the implementation is the following.
##  Non-qualified operations with one argument aren't attributes or
##  properties.
##  For each different meaning of the argument there are a corresponding
##  attribute (e.g. 'IsSolvableGroup') and a method that delegates to this
##  attribute.
##  In the library one calls the attributes directly, and the non-qualified
##  operation is thought only as a shorthand for the user.
##
##  (So this file should be read after all the other library files.)
##
#T Shall we print warnings when the shorthands are used?
##
Revision.overload_g :=
    "@(#)$Id$";


#############################################################################
##
#O  CoKernel( <obj> )
##
##  is the cokernel of a general mapping that respects multiplicative or
##  additive structure (but not both) ...
##
CoKernel := NewOperation( "CoKernel", [ IsObject ] );

InstallMethod( CoKernel, true,
    [ IsGeneralMapping and RespectsMultiplication and RespectsOne ], 0,
    CoKernelOfMultiplicativeGeneralMapping );

InstallMethod( CoKernel, true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero ], 0,
    CoKernelOfAdditiveGeneralMapping );

InstallMethod( CoKernel, true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero
                       and RespectsMultiplication and RespectsOne ], 0,
    map -> Error( "specify additive or multiplicative cokernel of <map>" ) );


#############################################################################
##
#O  Degree( <obj> )
##
##  is the degree of a polynomial, a character ...
##
Degree := NewOperation( "Degree", [ IsObject ] );

#T InstallMethod( Degree, true, [ IsCharacter ], 0, DegreeOfCharacter );


#############################################################################
##
#O  DerivedSeries( <D> )
##
DerivedSeries := NewOperation( "DerivedSeries", [ IsObject ] );

InstallMethod( DerivedSeries, true, [ IsAlgebra ], 0,
    DerivedSeriesOfAlgebra );
InstallMethod( DerivedSeries, true, [ IsGroup   ], 0,
    DerivedSeriesOfGroup   );


#############################################################################
##
#O  Determinant( <obj> )
##
##  is the determinant of a matrix, a linear maapping, a character ...
##
Determinant := NewOperation( "Determinant", [ IsObject ] );

InstallMethod( Determinant, true, [ IsMatrix ], 0, DeterminantMat );


#############################################################################
##
#O  IsMonomial( <obj> )
##
##  is 'true' if <obj> is a monomial group or a monomial character or
##  a monomial representation or a monomial matrix or a monomial number ...
##
IsMonomial := NewOperation( "IsMonomial", [ IsObject ] );

InstallMethod( IsMonomial, true, [ IsGroup  ], 0, IsMonomialGroup  );
InstallMethod( IsMonomial, true, [ IsMatrix ], 0, IsMonomialMatrix );


#############################################################################
##
#O  IsNilpotent( <obj> )
##
##  is 'true' if <obj> is a nilpotent group or a nilpotent algebra or ...
##
IsNilpotent := NewOperation( "IsNilpotent", [ IsObject ] );

InstallMethod( IsNilpotent, true, [ IsAlgebra ], 0, IsNilpotentAlgebra );
InstallMethod( IsNilpotent, true, [ IsGroup   ], 0, IsNilpotentGroup   );


#############################################################################
##
#O  IsSimple( <obj> )
##
##  is 'true' if <obj> is a simple group or a simple algebra or ...
##
IsSimple := NewOperation( "IsSimple", [ IsObject ] );

InstallMethod( IsSimple, true, [ IsAlgebra ], 0, IsSimpleAlgebra );
InstallMethod( IsSimple, true, [ IsGroup   ], 0, IsSimpleGroup   );


#############################################################################
##
#O  IsSolvable( <obj> )
##
##  is 'true' if <obj> is a solvable group or a solvable algebra or ...
##
IsSolvable := NewOperation( "IsSolvable", [ IsObject ] );

InstallMethod( IsSolvable, true, [ IsAlgebra ], 0, IsSolvableAlgebra );
InstallMethod( IsSolvable, true, [ IsGroup   ], 0, IsSolvableGroup   );


#############################################################################
##
#O  IsSupersolvable( <obj> )
##
##  is 'true' if <obj> is a supersolvable group or a supersolvable algebra
##  or ...
##
IsSupersolvable := NewOperation( "IsSupersolvable", [ IsObject ] );

InstallMethod( IsSupersolvable, true, [ IsGroup ], 0, IsSupersolvableGroup );


#############################################################################
##
#O  IsPerfect( <D> )
##
IsPerfect := NewOperation( "IsPerfect", [ IsObject ] );

InstallMethod( IsPerfect, true, [ IsGroup ], 0, IsPerfectGroup );


#############################################################################
##
#O  Kernel( <obj> )
##
##  is the kernel of a general mapping that respects multiplicative or
##  additive structure (but not both),
##  or the kernel of a character ...
##
Kernel := NewOperation( "Kernel", [ IsObject ] );

InstallMethod( Kernel, true,
    [ IsGeneralMapping and RespectsMultiplication and RespectsOne ], 0,
    KernelOfMultiplicativeGeneralMapping );

InstallMethod( Kernel, true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero ], 0,
    KernelOfAdditiveGeneralMapping );

InstallMethod( Kernel, true,
    [ IsGeneralMapping and RespectsAddition and RespectsZero
                       and RespectsMultiplication and RespectsOne ], 0,
    map -> Error( "specify additive or multiplicative kernel of <map>" ) );


#############################################################################
##
#O  LowerCentralSeries( <D> )
##
LowerCentralSeries := NewOperation( "LowerCentralSeries", [ IsObject ] );

InstallMethod( LowerCentralSeries, true, [ IsAlgebra ], 0,
    LowerCentralSeriesOfAlgebra );
InstallMethod( LowerCentralSeries, true, [ IsGroup   ], 0,
    LowerCentralSeriesOfGroup   );


#############################################################################
##
#O  UpperCentralSeries( <D> )
##
UpperCentralSeries := NewOperation( "UpperCentralSeries", [ IsObject ] );

InstallMethod( UpperCentralSeries, true, [ IsAlgebra ], 0,
    UpperCentralSeriesOfAlgebra );
InstallMethod( UpperCentralSeries, true, [ IsGroup   ], 0,
    UpperCentralSeriesOfGroup   );


#############################################################################
##
#E  overload.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



