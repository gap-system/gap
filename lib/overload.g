#############################################################################
##
#W  overload.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
##  Note that operations such as 'IsCommutative' are not of this type,
##  since the result means the same for any multiplicative structure.
##  
##  The key requirement is that no object ever exists which inherits from
##  two types with distinct meanings.
##  Whenever this happens, there *must* be a method installed for the join
##  of the relevant categories which decides which meaning applies,
##  otherwise the meaning of the operation is at the mercy of the ranking
##  system.
##  Examples for this are `Kernel' and `CoKernel' for general mappings
##  that respect both addition and  multiplication.
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
DeclareOperation( "CoKernel", [ IsObject ] );

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
DeclareOperation( "Degree", [ IsObject ] );

InstallMethod( Degree, true, [ IsClassFunction ], 0, DegreeOfCharacter );


#############################################################################
##
#O  DerivedSeries( <D> )
##
DeclareOperation( "DerivedSeries", [ IsObject ] );

InstallMethod( DerivedSeries, true, [ IsAlgebra ], 0,
    DerivedSeriesOfAlgebra );
InstallMethod( DerivedSeries, true, [ IsGroup   ], 0,
    DerivedSeriesOfGroup   );


#############################################################################
##
#O  Determinant( <obj> )
##
##  is the determinant of a matrix, a linear mapping, a character ...
##
DeclareOperation( "Determinant", [ IsObject ] );

InstallMethod( Determinant, true, [ IsMatrix ], 0, DeterminantMat );
InstallMethod( Determinant, true, [ IsClassFunction ], 0,
    DeterminantOfCharacter );


#############################################################################
##
#O  Eigenvalues( <obj> )
##
DeclareOperation( "Eigenvalues", [ IsObject ] );

InstallOtherMethod( Eigenvalues, true,
    [ IsClassFunction, IsPosInt ], 0,
    EigenvaluesChar );


#############################################################################
##
#O  Induced( <chi>, <G> )
#O  Induced( <chi>, <tbl> )
#O  Induced( <chars>, <G> )
#O  Induced( <chars>, <tbl> )
#O  Induced( <subtbl>, <tbl>, <chars> )
#O  Induced( <subtbl>, <tbl>, <chars>, <specification> )
#O  Induced( <subtbl>, <tbl>, <chars>, <fusionmap> )
##
##  delegates to 'InducedClassFunction' or ...
##
DeclareOperation( "Induced", [ IsObject, IsObject ] );

InstallMethod( Induced, true,
    [ IsClassFunctionWithGroup, IsGroup ], 0,
    InducedClassFunction );

InstallMethod( Induced, true,
    [ IsClassFunction, IsNearlyCharacterTable ], 0,
    InducedClassFunction );

InstallMethod( Induced, true,
    [ IsList and IsEmpty, IsGroup ], 0,
    InducedClassFunctions );

InstallMethod( Induced, true,
    [ IsClassFunctionWithGroupCollection, IsGroup ], 0,
    InducedClassFunctions );

InstallMethod( Induced, true,
    [ IsClassFunctionCollection, IsNearlyCharacterTable ], 0,
    InducedClassFunctions );

InstallOtherMethod( Induced, true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsHomogeneousList ], 0,
    InducedClassFunctions );

InstallOtherMethod( Induced, true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable,
      IsHomogeneousList, IsString ], 0,
    InducedClassFunctions );

InstallOtherMethod( Induced, true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable,
      IsHomogeneousList, IsHomogeneousList and IsCyclotomicCollection ], 0,
    InducedClassFunctions );


#############################################################################
##
#O  IsIrreducible( <obj> )
##
##  is 'true' if <obj> is an irreducible ring element or an irreducible
##  character or an irreducible module ...
##
##  (Note that we must be careful since characters are also ring elements,
##  and for example linear characters are irreducible as characters but not
##  as ring elements since they are units.)
##
DeclareOperation( "IsIrreducible", [ IsObject ] );

#T InstallMethod( IsIrreducible, true, [ IsAModule ], 0,
#T     IsIrreducibleModule );
InstallMethod( IsIrreducible, true, [ IsClassFunction ], 0,
    IsIrreducibleCharacter );
InstallMethod( IsIrreducible, true, [ IsRingElement ], 0,
    function( r )
    if IsClassFunction( r ) then
      TryNextMethod();
    fi;
    return IsIrreducibleRingElement( r );
    end );


#############################################################################
##
#O  IsMonomial( <obj> )
##
##  is 'true' if <obj> is a monomial group or a monomial character or
##  a monomial representation or a monomial matrix or a monomial number ...
##
DeclareOperation( "IsMonomial", [ IsObject ] );

InstallMethod( IsMonomial, true, [ IsClassFunction ], 0,
    IsMonomialCharacter );
InstallMethod( IsMonomial, true, [ IsGroup ], 0,
    IsMonomialGroup );
InstallMethod( IsMonomial, true, [ IsMatrix ], 0,
    IsMonomialMatrix );
InstallMethod( IsMonomial, true, [ IsPosInt ], 0,
    IsMonomialNumber );


#############################################################################
##
#O  IsNilpotent( <obj> )
##
##  is 'true' if <obj> is a nilpotent group or a nilpotent algebra or ...
##
DeclareOperation( "IsNilpotent", [ IsObject ] );

InstallMethod( IsNilpotent, true, [ IsAlgebra ], 0, IsNilpotentAlgebra );
InstallMethod( IsNilpotent, true, [ IsGroup   ], 0, IsNilpotentGroup   );


#############################################################################
##
#O  IsSimple( <obj> )
##
##  is 'true' if <obj> is a simple group or a simple algebra or ...
##
DeclareOperation( "IsSimple", [ IsObject ] );

InstallMethod( IsSimple, true, [ IsAlgebra ], 0, IsSimpleAlgebra );
#T InstallMethod( IsSimple, true, [ IsAModule ], 0,
#T     IsSimpleModule );
InstallMethod( IsSimple, true, [ IsGroup   ], 0, IsSimpleGroup   );
InstallMethod( IsSimple, true, [ IsOrdinaryTable ], 0,
    IsSimpleCharacterTable );


#############################################################################
##
#O  IsSolvable( <obj> )
##
##  is 'true' if <obj> is a solvable group or a solvable algebra or ...
##
DeclareOperation( "IsSolvable", [ IsObject ] );

InstallMethod( IsSolvable, true, [ IsAlgebra ], 0, IsSolvableAlgebra );
InstallMethod( IsSolvable, true, [ IsGroup   ], 0, IsSolvableGroup   );
InstallMethod( IsSolvable, true, [ IsOrdinaryTable ], 0,
    IsSolvableCharacterTable );


#############################################################################
##
#O  IsSupersolvable( <obj> )
##
##  is 'true' if <obj> is a supersolvable group or a supersolvable algebra
##  or ...
##
DeclareOperation( "IsSupersolvable", [ IsObject ] );

InstallMethod( IsSupersolvable, true, [ IsGroup ], 0, IsSupersolvableGroup );


#############################################################################
##
#O  IsPerfect( <D> )
##
DeclareOperation( "IsPerfect", [ IsObject ] );

InstallMethod( IsPerfect, true, [ IsGroup ], 0, IsPerfectGroup );


#############################################################################
##
#O  Kernel( <obj> )
##
##  is the kernel of a general mapping that respects multiplicative or
##  additive structure (but not both),
##  or the kernel of a character ...
##
DeclareOperation( "Kernel", [ IsObject ] );

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

InstallMethod( Kernel, true, [ IsClassFunction ], 0, KernelOfCharacter );


#############################################################################
##
#O  LowerCentralSeries( <D> )
##
DeclareOperation( "LowerCentralSeries", [ IsObject ] );

InstallMethod( LowerCentralSeries, true, [ IsAlgebra ], 0,
    LowerCentralSeriesOfAlgebra );
InstallMethod( LowerCentralSeries, true, [ IsGroup   ], 0,
    LowerCentralSeriesOfGroup   );


#############################################################################
##
#O  Restricted( <chi>, <H> )
#O  Restricted( <chi>, <tbl> )
#O  Restricted( <chars>, <H> )
#O  Restricted( <chars>, <tbl> )
##
##  delegates to 'RestrictedClassFunction' or ...
##
DeclareOperation( "Restricted", [ IsObject, IsObject ] );

Inflated := Restricted;

InstallMethod( Restricted, true,
    [ IsClassFunction, IsGroup ], 0,
    RestrictedClassFunction );

InstallMethod( Restricted, true,
    [ IsClassFunction, IsNearlyCharacterTable ], 0,
    RestrictedClassFunction );

InstallMethod( Restricted, true,
    [ IsClassFunctionCollection, IsGroup ], 0,
    RestrictedClassFunctions );

InstallMethod( Restricted, true,
    [ IsClassFunctionCollection, IsNearlyCharacterTable ], 0,
    RestrictedClassFunctions );

InstallOtherMethod( Restricted, true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsHomogeneousList ], 0,
    RestrictedClassFunctions );

InstallOtherMethod( Restricted, true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsMatrix,
      IsString ], 0,
    RestrictedClassFunctions );

InstallOtherMethod( Restricted, true,
    [ IsMatrix, IsList and IsCyclotomicCollection ], 0,
    RestrictedClassFunctions );


#############################################################################
##
#O  UpperCentralSeries( <D> )
##
DeclareOperation( "UpperCentralSeries", [ IsObject ] );

InstallMethod( UpperCentralSeries, true, [ IsAlgebra ], 0,
    UpperCentralSeriesOfAlgebra );
InstallMethod( UpperCentralSeries, true, [ IsGroup   ], 0,
    UpperCentralSeriesOfGroup   );


#############################################################################
##
#E  overload.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



