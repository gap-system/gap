#############################################################################
##
#W  addmagma.gi                 GAP library                     Thomas Breuer
##
#W  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.addmagma_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  Print( <A> )  . . . . . . . . . . . . . . . . . . print an additive magma
##
InstallMethod( PrintObj, true, [ IsAdditiveMagma ], 0,
    function( A )
    Print( "AdditiveMagma( ... )" );
    end );

InstallMethod( PrintObj, true,
    [ IsAdditiveMagma and HasGeneratorsOfAdditiveMagma ], 0,
    function( A )
    Print( "AdditiveMagma( ", GeneratorsOfAdditiveMagma( A ), " )" );
    end );


#############################################################################
##
#M  IsTrivial( <A> )  . . . . . . . test whether an additive magma is trivial
##
InstallImmediateMethod( IsTrivial,
    IsAdditiveMagmaWithZero and HasGeneratorsOfAdditiveMagmaWithZero , 0,
    function( A )
    if IsEmpty( GeneratorsOfAdditiveMagmaWithZero( A ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallImmediateMethod( IsTrivial,
    IsAdditiveMagmaWithInverses
    and HasGeneratorsOfAdditiveMagmaWithInverses, 0,
    function( A )
    if IsEmpty( GeneratorsOfAdditiveMagmaWithInverses( A ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  GeneratorsOfAdditiveMagma( <A> )
#M  GeneratorsOfAdditiveMagmaWithZero( <A> )
#M  GeneratorsOfAdditiveMagmaWithInverses( <A> )
##
##  If nothing special is known about the additive magma <A> we have
##  no chance to get the required generators.
##
##  If we know 'GeneratorsOfAdditiveMagma',
##  they are also 'GeneratorsOfAdditiveMagmaWithZero'.
##  If we know 'GeneratorsOfAdditiveMagmaWithZero',
##  they are also 'GeneratorsOfAdditiveMagmaWithInverses'.
##
InstallImmediateMethod( GeneratorsOfAdditiveMagmaWithZero,
    IsAdditiveMagmaWithZero and HasGeneratorsOfAdditiveMagma, 0,
    A -> GeneratorsOfAdditiveMagma( A ) );

InstallImmediateMethod( GeneratorsOfAdditiveMagmaWithInverses,
    IsAdditiveMagmaWithInverses and HasGeneratorsOfAdditiveMagmaWithZero, 0,
    A -> GeneratorsOfAdditiveMagmaWithZero( A ) );


InstallMethod( GeneratorsOfAdditiveMagma, true,
    [ IsAdditiveMagmaWithZero and HasGeneratorsOfAdditiveMagmaWithZero ], 0,
    A -> Concatenation( GeneratorsOfAdditiveMagmaWithZero( A ),
              [ Zero( A ) ] ) );

InstallMethod( GeneratorsOfAdditiveMagma, true,
    [     IsAdditiveMagmaWithInverses
      and HasGeneratorsOfAdditiveMagmaWithInverses ], 0,
    A -> Concatenation( GeneratorsOfAdditiveMagmaWithInverses( A ),
              [ Zero( A ) ],
              List( GeneratorsOfAdditiveMagmaWithInverses( A ),
                    AdditiveInverse ) ) );

InstallMethod( GeneratorsOfAdditiveMagmaWithZero, true,
    [     IsAdditiveMagmaWithInverses
      and HasGeneratorsOfAdditiveMagmaWithInverses ], 0,
    A -> Concatenation( GeneratorsOfAdditiveMagmaWithInverses( A ),
              List( GeneratorsOfAdditiveMagmaWithInverses( A ),
                    AdditiveInverse ) ) );


#############################################################################
##
#M  Representative( <A> ) . . . . . . . . .  one element of an additive magma
##
InstallMethod( Representative,
    "method for additive magma with known generators",
    true,
    [ IsAdditiveMagma and HasGeneratorsOfAdditiveMagma ], 0,
    RepresentativeFromGenerators( GeneratorsOfAdditiveMagma ) );

InstallMethod( Representative,
    "method for additive-magma-with-zero with known generators",
    true,
    [ IsAdditiveMagmaWithZero and HasGeneratorsOfAdditiveMagmaWithZero ], 0,
    RepresentativeFromGenerators( GeneratorsOfAdditiveMagmaWithZero ) );

InstallMethod( Representative,
    "method for additive-magma-with-inverses with known generators",
    true,
    [ IsAdditiveMagmaWithInverses
      and HasGeneratorsOfAdditiveMagmaWithInverses ], 0,
    RepresentativeFromGenerators( GeneratorsOfAdditiveMagmaWithInverses ) );

InstallMethod( Representative,
    "method for additive-magma-with-zero with known zero",
    true,
    [ IsAdditiveMagmaWithZero and HasZero ], SUM_FLAGS,
    Zero );


#############################################################################
##
#M  AdditiveNeutralElement( <A> ) . . . . . . . . . zero of an additive magma
##
InstallMethod( AdditiveNeutralElement, true, [ IsAdditiveMagma ], 0,
    function( M )
    local m;
    if IsFinite( M ) then
      for m in M do
        if ForAll( M, n -> n + m = n ) then
          return m;
        fi;
      od;
      return fail;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Zero( <A> ) . . . . . . . . . . . . . . . . . . zero of an additive magma
##
InstallOtherMethod( Zero,
    "method for additive magma",
    true, [ IsAdditiveMagma ], 0,
    function( A )
    local zero;
    zero:= Zero( Representative( A ) );
    if zero <> fail and zero in A then
      return zero;
    else
      return fail;
    fi;
    end );

InstallOtherMethod( Zero,
    "method for additive magma with zero (look at family)",
    true, [ IsAdditiveMagmaWithZero ], SUM_FLAGS,
    function( A )
    A:= ElementsFamily( FamilyObj( A ) );
    if HasZero( A ) then
      return Zero( A );
    else
      TryNextMethod();
    fi;
    end );
#T immediate?

InstallOtherMethod( Zero, true, [ IsAdditiveMagmaWithZero and HasParent ], 0,
    A -> Zero( Parent( A ) ) );
#T really ask the parent for such information?

InstallOtherMethod( Zero,
    "method for additive magma with zero",
    true, [ IsAdditiveMagmaWithZero ], 0,
    A -> Zero( Representative( A ) ) );


#############################################################################
##
#M  Enumerator( <A> ) . . . .  enumerator of trivial additive magma with zero
#M  EnumeratorSorted( <A> ) .  enumerator of trivial additive magma with zero
##
EnumeratorOfTrivialAdditiveMagmaWithZero := A -> Immutable( [ Zero( A ) ] );

InstallMethod( Enumerator,
    true, [ IsAdditiveMagmaWithZero and IsTrivial ], 0,
    EnumeratorOfTrivialAdditiveMagmaWithZero );

InstallMethod( EnumeratorSorted,
    true, [ IsAdditiveMagmaWithZero and IsTrivial ], 0,
    EnumeratorOfTrivialAdditiveMagmaWithZero );


#############################################################################
##
#M  IsSubset( <M>, <N> )  . . . . . . . . . . . . . . for two additive magmas
##
InstallMethod( IsSubset,
    "method for two additive magmas",
    IsIdentical,
    [ IsAdditiveMagma, IsAdditiveMagma ], 0,
    function( M, N )
    return IsSubset( M, GeneratorsOfAdditiveMagma( N ) );
    end );


#############################################################################
##
#M  IsSubset( <M>, <N> )  . . . . . . . . . for two additive magmas with zero
##
InstallMethod( IsSubset,
    "method for two additive magmas with zero",
    IsIdentical,
    [ IsAdditiveMagmaWithZero, IsAdditiveMagmaWithZero ], 0,
    function( M, N )
    return IsSubset( M, GeneratorsOfAdditiveMagmaWithZero( N ) );
    end );


#############################################################################
##
#M  IsSubset( <M>, <N> )  . . . . . . . for two additive magmas with inverses
##
InstallMethod( IsSubset,
    "method for two additive magmas with inverses",
    IsIdentical,
    [ IsAdditiveMagmaWithInverses, IsAdditiveMagmaWithInverses ], 0,
    function( M, N )
    return IsSubset( M, GeneratorsOfAdditiveMagmaWithInverses( N ) );
    end );


#############################################################################
##
#E  addmagma.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



