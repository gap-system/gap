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
##  Examples are `IsSolvable' and `IsNilpotent' (where we have methods for
##  groups and for algebras), and `Kernel' (which in the case of a group
##  homomorphism means the elements mapped to the identity of the range,
##  in the case of a ring homomorphism means those mapped to the zero,
##  and in the case of a group character means those mapped to the
##  character degree).
##
##  In these examples we seem to be safe, as no object can be both a group
##  and an algebra.
##
##  Such non-qualified operations should be kept to a minimum.
##  (Remember the problems we had with `NewObject'.)
##
##  Note that operations such as `IsCommutative' are not of this type,
##  since the result means the same for any multiplicative structure.
##  
##  The key requirement is that no object ever exists which inherits from
##  two types with distinct meanings.
##  Whenever this happens, there *must* be a method installed for the join
##  of the relevant categories which decides which meaning applies,
##  otherwise the meaning of the operation is at the mercy of the ranking
##  system.
##
##  The guideline for the implementation is the following.
##  Non-qualified operations with one argument aren't attributes or
##  properties.
##  For each different meaning of the argument there are a corresponding
##  attribute (e.g. `IsSolvableGroup') and a method that delegates to this
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
##  additive structure (or both, so we have to check) ...
##
DeclareOperation( "CoKernel", [ IsObject ] );

InstallMethod( CoKernel, true,
    [ IsGeneralMapping ], 0,
    function( map )
    if RespectsAddition( map ) and RespectsZero( map ) then
      return CoKernelOfAdditiveGeneralMapping( map );
    elif RespectsMultiplication( map ) and RespectsOne( map ) then
      return CoKernelOfMultiplicativeGeneralMapping( map );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#O  Degree( <obj> )
##
##  is the degree of a univariate Laurent polynomial, a character ...
##
DeclareOperation( "Degree", [ IsObject ] );

InstallMethod( Degree, true, [ IsClassFunction ], 0, DegreeOfCharacter );
InstallMethod( Degree, true, [ IsRationalFunction ], 0,
    function( ratfun )
    if IsLaurentPolynomial( ratfun ) then
      return DegreeOfLaurentPolynomial( ratfun );
    else
      TryNextMethod();
    fi;
    end );

#############################################################################
##
#O  DerivedSeries( <D> )
##
DeclareOperation( "DerivedSeries", [ IsObject ] );

# DerivedSeriesOfAlgebra no longer exists! (There are the functions 
# LieDerivedSeries and PowerSubalgebraSeries). 
#
InstallMethod( DerivedSeries, true, [ IsAlgebra ], 0,
  function( A )
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error(
"you can't use DerivedSeries( <L> ) for a Lie algebra <L>, you may want to try LieDerivedSeries( <L> ) instead");
    else
      Error(
"you can't use DerivedSeries( <A> ) for an algebra <A>, you may want to try PowerSubalgebraSeries( <A> ) instead");
    fi;
  end
);

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
#O  IsIrreducible( <obj> )
##
##  is `true' if <obj> is an irreducible ring element or an irreducible
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
##  is `true' if <obj> is a monomial group or a monomial character or
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
InstallMethod( IsMonomial, true, [ IsOrdinaryTable ], 0,
    IsMonomialCharacterTable );


#############################################################################
##
#O  IsNilpotent( <obj> )
##
##  is `true' if <obj> is a nilpotent group or a nilpotent algebra or ...
##
DeclareOperation( "IsNilpotent", [ IsObject ] );
Add(SOLVABILITY_IMPLYING_FUNCTIONS,IsNilpotent);

# IsNilpotentAlgebra is now called IsLieNilpotent.
#
InstallMethod( IsNilpotent, true, [ IsAlgebra ], 0,
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error("you can't use IsNilpotent( <L> ) for a Lie algebra <L>, you may want to try IsLieNilpotent( <L> ) instead");
    else
      Error("you can't use IsNilpotent( <A> ) for an algebra <A>");
    fi;
  end
);

InstallMethod( IsNilpotent, true, [ IsGroup ], 0, IsNilpotentGroup   );
InstallMethod( IsNilpotent, true, [ IsOrdinaryTable ], 0,
    IsNilpotentCharacterTable );


#############################################################################
##
#O  IsSimple( <obj> )
##
##  is `true' if <obj> is a simple group or a simple algebra or ...
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
##  is `true' if <obj> is a solvable group or ...
##
DeclareOperation( "IsSolvable", [ IsObject ] );
Add(SOLVABILITY_IMPLYING_FUNCTIONS,IsSolvable);

# IsSolvableAlgebra is now called IsLieSolvable.
#
InstallMethod( IsSolvable, true, [ IsAlgebra ], 0,
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error(
"you can't use IsSolvable( <L> ) for a Lie algebra <L>, you may want to try IsLieSolvable( <L> ) instead");
    else
      Error("you can't use IsSolvable( <A> ) for an algebra <A>");
    fi;
  end
);

InstallMethod( IsSolvable, true, [ IsGroup   ], 0, IsSolvableGroup   );
InstallMethod( IsSolvable, true, [ IsOrdinaryTable ], 0,
    IsSolvableCharacterTable );


#############################################################################
##
#O  IsSupersolvable( <obj> )
##
##  is `true' if <obj> is a supersolvable group or a supersolvable algebra
##  or ...
##
DeclareOperation( "IsSupersolvable", [ IsObject ] );

InstallMethod( IsSupersolvable, true, [ IsGroup ], 0, IsSupersolvableGroup );
InstallMethod( IsSupersolvable, true, [ IsOrdinaryTable ], 0,
    IsSupersolvableCharacterTable );


#############################################################################
##
#O  IsPerfect( <D> )
##
DeclareOperation( "IsPerfect", [ IsObject ] );

InstallMethod( IsPerfect, true, [ IsGroup ], 0, IsPerfectGroup );
InstallMethod( IsPerfect, true, [ IsOrdinaryTable ], 0,
    IsPerfectCharacterTable );


#############################################################################
##
#O  Kernel( <obj> )
##
##  is the kernel of a general mapping that respects multiplicative or
##  additive structure (or both, so we must check),
##  or the kernel of a character ...
##
DeclareOperation( "Kernel", [ IsObject ] );

InstallMethod( Kernel, true,
    [ IsGeneralMapping ], 0,
    function( map )
    if RespectsAddition( map ) and RespectsZero( map ) then
      return KernelOfAdditiveGeneralMapping( map );
    elif RespectsMultiplication( map ) and RespectsOne( map ) then
      return KernelOfMultiplicativeGeneralMapping( map );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( Kernel, true, [ IsClassFunction ], 0, KernelOfCharacter );


#############################################################################
##
#O  LowerCentralSeries( <D> )
##
DeclareOperation( "LowerCentralSeries", [ IsObject ] );

# LowerCentralSeries is now called LieLowerCentralSeries. 
#
InstallMethod( LowerCentralSeries, true, [ IsAlgebra ], 0,
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error("you can't use LowerCentralSeries( <L> ) for a Lie algebra <L>, you may want to try LieLowerCentralSeries( <L> ) instead");
    else
      Error("you can't use LowerCentralSeries( <A> ) for an algebra <A>");
    fi;
  end
);

InstallMethod( LowerCentralSeries, true, [ IsGroup   ], 0,
    LowerCentralSeriesOfGroup   );


#############################################################################
##
#O  Rank( <obj> )
##
##  is the rank of a matrix or a $p$-group or ...
##
DeclareOperation( "Rank", [ IsObject ] );

InstallMethod( Rank, [ IsMatrix ], RankMat );

InstallMethod( Rank, [ IsGroup ], RankPGroup );


#############################################################################
##
#O  UpperCentralSeries( <D> )
##
DeclareOperation( "UpperCentralSeries", [ IsObject ] );

# UpperCentralSeriesOfAlgebra is now called LieUpperCentralSeries.
#
InstallMethod( UpperCentralSeries, true, [ IsAlgebra ], 0,
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error("you can't use UpperCentralSeries( <L> ) for a Lie algebra <L>, you may want to try LieUpperCentralSeries( <L> ) instead");
    else
      Error("you can't use UpperCentralSeries( <A> ) for an algebra <A>");
    fi;
  end
);

InstallMethod( UpperCentralSeries, true, [ IsGroup   ], 0,
    UpperCentralSeriesOfGroup   );


#############################################################################
##
#E

