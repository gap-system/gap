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
##  Whenever this happens, there *must* be a method installed for the meet
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


#############################################################################
##
#O  CoKernel( <obj> )
##
##  is the cokernel of a general mapping that respects multiplicative or
##  additive structure (or both, so we have to check) ...
##
DeclareOperation( "CoKernel", [ IsObject ] );

InstallMethod( CoKernel,
    [ IsGeneralMapping ],
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

InstallMethod( Degree, [ IsClassFunction ], DegreeOfCharacter );
InstallMethod( Degree, [ IsRationalFunction ],
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
InstallMethod( DerivedSeries, [ IsAlgebra ],
  function( A )
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error(
"you can't use DerivedSeries( <L> ) for a Lie algebra <L>, you may want to try LieDerivedSeries( <L> ) instead");
    else
      Error(
"you can't use DerivedSeries( <A> ) for an algebra <A>, you may want to try PowerSubalgebraSeries( <A> ) instead");
    fi;
  end );

InstallMethod( DerivedSeries, [ IsGroup ], DerivedSeriesOfGroup );


#############################################################################
##
#O  Determinant( <obj> )
##
##  is the determinant of a matrix, a linear mapping, a character ...
##
DeclareOperation( "Determinant", [ IsObject ] );

InstallMethod( Determinant, [ IsMatrixOrMatrixObj ], DeterminantMat );
InstallMethod( Determinant, [ IsClassFunction ], DeterminantOfCharacter );


#############################################################################
##
#O  Eigenvalues( <obj> )
##
DeclareOperation( "Eigenvalues", [ IsObject ] );

InstallOtherMethod( Eigenvalues, [ IsClassFunction, IsPosInt ],
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

#T InstallMethod( IsIrreducible, [ IsAModule ], IsIrreducibleModule );
InstallMethod( IsIrreducible, [ IsClassFunction ], IsIrreducibleCharacter );
InstallMethod( IsIrreducible, [ IsRingElement ],
    function( r )
    if IsClassFunction( r ) then
      TryNextMethod();
    fi;
    return IsIrreducibleRingElement( r );
    end );

InstallOtherMethod(IsIrreducible,"polynomial",IsCollsElms,
  [IsPolynomialRing,IsPolynomial],0,IsIrreducibleRingElement);


#############################################################################
##
#O  IsMonomial( <obj> )
##
##  is `true' if <obj> is a monomial group or a monomial character or
##  a monomial representation or a monomial matrix or a monomial number ...
##
DeclareOperation( "IsMonomial", [ IsObject ] );

InstallMethod( IsMonomial, [ IsClassFunction ], IsMonomialCharacter );
InstallMethod( IsMonomial, [ IsGroup ], IsMonomialGroup );
InstallMethod( IsMonomial, [ IsMatrix ], IsMonomialMatrix );
InstallMethod( IsMonomial, [ IsPosInt ], IsMonomialNumber );
InstallMethod( IsMonomial, [ IsOrdinaryTable ], IsMonomialCharacterTable );


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
InstallMethod( IsNilpotent, [ IsAlgebra ],
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error("you can't use IsNilpotent( <L> ) for a Lie algebra <L>, you may want to try IsLieNilpotent( <L> ) instead");
    else
      Error("you can't use IsNilpotent( <A> ) for an algebra <A>");
    fi;
  end
);

InstallMethod( IsNilpotent, [ IsGroup ], IsNilpotentGroup   );
InstallMethod( IsNilpotent, [ IsOrdinaryTable ], IsNilpotentCharacterTable );


#############################################################################
##
#O  IsSimple( <obj> )
##
##  is `true' if <obj> is a simple group or a simple algebra or ...
##
DeclareOperation( "IsSimple", [ IsObject ] );

InstallMethod( IsSimple, [ IsAlgebra ], IsSimpleAlgebra );
#T InstallMethod( IsSimple, [ IsAModule ], IsSimpleModule );
InstallMethod( IsSimple, [ IsGroup   ], IsSimpleGroup   );
InstallMethod( IsSimple, [ IsOrdinaryTable ], IsSimpleCharacterTable );


#############################################################################
##
#O  IsAlmostSimple( <obj> )
##
##  is `true' if <obj> is an almost simple group
##  or an almost simple character table or ...
##
DeclareOperation( "IsAlmostSimple", [ IsObject ] );

InstallMethod( IsAlmostSimple, [ IsGroup   ], IsAlmostSimpleGroup   );
InstallMethod( IsAlmostSimple, [ IsOrdinaryTable ],
    IsAlmostSimpleCharacterTable );


#############################################################################
##
#O  IsQuasisimple( <obj> )
##
##  is `true' if <obj> is a quasisimple group
##  or a quasisimple character table or ...
##
DeclareOperation( "IsQuasisimple", [ IsObject ] );

DeclareSynonym( "IsQuasiSimple", IsQuasisimple );

InstallMethod( IsQuasisimple, [ IsGroup ], IsQuasisimpleGroup );
InstallMethod( IsQuasisimple, [ IsOrdinaryTable ],
    IsQuasisimpleCharacterTable );


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
InstallMethod( IsSolvable, [ IsAlgebra ],
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error(
"you can't use IsSolvable( <L> ) for a Lie algebra <L>, you may want to try IsLieSolvable( <L> ) instead");
    else
      Error("you can't use IsSolvable( <A> ) for an algebra <A>");
    fi;
  end );

InstallMethod( IsSolvable, [ IsGroup   ], IsSolvableGroup   );
InstallMethod( IsSolvable, [ IsOrdinaryTable ], IsSolvableCharacterTable );


#############################################################################
##
#O  IsSporadicSimple( <obj> )
##
##  is `true' if <obj> is a sporadic simple group or character table or ...
##
DeclareOperation( "IsSporadicSimple", [ IsObject ] );

InstallMethod( IsSporadicSimple, [ IsGroup ], IsSporadicSimpleGroup );
InstallMethod( IsSporadicSimple, [ IsOrdinaryTable ],
    IsSporadicSimpleCharacterTable );


#############################################################################
##
#O  IsSupersolvable( <obj> )
##
##  is `true' if <obj> is a supersolvable group or a supersolvable algebra
##  or ...
##
DeclareOperation( "IsSupersolvable", [ IsObject ] );

InstallMethod( IsSupersolvable, [ IsGroup ], IsSupersolvableGroup );
InstallMethod( IsSupersolvable, [ IsOrdinaryTable ],
    IsSupersolvableCharacterTable );


#############################################################################
##
#O  IsPerfect( <D> )
##
DeclareOperation( "IsPerfect", [ IsObject ] );

InstallMethod( IsPerfect, [ IsGroup ], IsPerfectGroup );
InstallMethod( IsPerfect, [ IsOrdinaryTable ], IsPerfectCharacterTable );


#############################################################################
##
#O  Kernel( <obj> )
##
##  is the kernel of a general mapping that respects multiplicative or
##  additive structure (or both, so we must check),
##  or the kernel of a character ...
##
DeclareOperation( "Kernel", [ IsObject ] );

InstallMethod( Kernel,
    [ IsGeneralMapping ],
    function( map )
    if RespectsAddition( map ) and RespectsZero( map ) then
      return KernelOfAdditiveGeneralMapping( map );
    elif RespectsMultiplication( map ) and RespectsOne( map ) then
      return KernelOfMultiplicativeGeneralMapping( map );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( Kernel, [ IsClassFunction ], KernelOfCharacter );


#############################################################################
##
#O  LowerCentralSeries( <D> )
##
DeclareOperation( "LowerCentralSeries", [ IsObject ] );

# LowerCentralSeries is now called LieLowerCentralSeries.
#
InstallMethod( LowerCentralSeries, [ IsAlgebra ],
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error("you can't use LowerCentralSeries( <L> ) for a Lie algebra <L>, you may want to try LieLowerCentralSeries( <L> ) instead");
    else
      Error("you can't use LowerCentralSeries( <A> ) for an algebra <A>");
    fi;
  end
);

InstallMethod( LowerCentralSeries, [ IsGroup ], LowerCentralSeriesOfGroup );


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
InstallMethod( UpperCentralSeries, [ IsAlgebra ],
  function(A)
    if HasIsLieAlgebra(A) and IsLieAlgebra(A) then
      Error("you can't use UpperCentralSeries( <L> ) for a Lie algebra <L>, you may want to try LieUpperCentralSeries( <L> ) instead");
    else
      Error("you can't use UpperCentralSeries( <A> ) for an algebra <A>");
    fi;
  end
);

InstallMethod( UpperCentralSeries, [ IsGroup ], UpperCentralSeriesOfGroup );


DeclareGlobalFunction( "InsertElmList" );

InstallGlobalFunction(InsertElmList, function (list, pos, elm)
    Add(list,elm,pos);
end);

DeclareSynonym( "RemoveElmList", Remove);

if IsHPCGAP then
    MakeImmutable(SOLVABILITY_IMPLYING_FUNCTIONS);
fi;
