#############################################################################
##
#W  ring.gi                     GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright 1996,    Lehrstuhl D fuer Mathematik,   RWTH Aachen,    Germany
##
##  This file contains generic methods for rings.
##
Revision.ring_gi :=
    "@(#)$Id$";


#T ##########################################################################
#T ##
#T #M  \^( <R>, <n> )
#T ##
#T ##  returns the free module of rank <n> over the ring <R>.
#T ##
#T InstallMethod( \^, true, [ IsRing, IsInt ], 0, FreeModule );


#############################################################################
##
#M  Print( <R> )  . . . . . . . . . . . . . . . . . . . . . . .  print a ring
##
InstallMethod( PrintObj, true,
    [ IsRing and HasParent and HasGeneratorsOfRing ], 0,
    function( R )
    Print( "Subring( ", Parent( R ), ", ",
           GeneratorsOfRing( R ), " )" );
    end );

InstallMethod( PrintObj, true,
    [ IsRing and HasParent ], 0,
    function( R )
    Print( "Subring( ", Parent( R ), ", ... )" );
    end );

InstallMethod( PrintObj, true,
    [ IsRing and HasGeneratorsOfRing ], 0,
    function( R )
    Print( "Ring( ", GeneratorsOfRing( R ), " )" );
    end );

InstallMethod( PrintObj, true,
    [ IsRing ], 0,
    function( R )
    Print( "Ring( ... )" );
    end );


#############################################################################
##
#M  PrintObj( <R> ) . . . . . . . . . . . . . . . . . . print a ring-with-one
##
InstallMethod( PrintObj, true,
    [ IsRingWithOne and HasParent and HasGeneratorsOfRingWithOne ], 0,
    function( R )
    Print( "Subring( ", Parent( R ), ", ",
           GeneratorsOfRingWithOne( R ), " )" );
    end );

InstallMethod( PrintObj, true,
    [ IsRingWithOne and HasParent ], 0,
    function( R )
    Print( "Subring( ", Parent( R ), ", ... )" );
    end );

InstallMethod( PrintObj, true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    function( R )
    Print( "RingWithOne( ", GeneratorsOfRingWithOne( R ), " )" );
    end );

InstallMethod( PrintObj, true,
    [ IsRingWithOne ], 0,
    function( R )
    Print( "RingWithOne( ... )" );
    end );


#############################################################################
##
#M  IsAnticommutative( <R> ) . . . . . test whether a ring is anticommutative
##
InstallImmediateMethod( IsAnticommutative,
    IsRing and IsCommutative and HasCharacteristic, 0,
    function( R )
    if Characteristic( R ) <> 2 then
      TryNextMethod();
    fi;
    return true;
    end );

InstallMethod( IsAnticommutative,
    "generic method for rings",
    true, [ IsRing ], 0,
    function( R )

    local elms,   # list of elements
          i, j;   # loop variables

    # Test if every element anti-commutes with all the others.
    elms:= Enumerator( R );
    for i in [ 2 .. Length( elms) ] do
      for j in [ 1 .. i-1 ] do
        if elms[i] * elms[j] <> AdditiveInverse( elms[j] * elms[i] ) then
          return false;
        fi;
      od;
    od;

    # All elements anti-commute.
    return true;
    end );


#############################################################################
##
#M  IsZeroSquaredRing(<R>)  . test whether the square of each element is zero
##
##  In odd characteristic, any anticommutative ring is zero squared.
##
InstallImmediateMethod( IsZeroSquaredRing,
    IsRing and IsAnticommutative and HasCharacteristic, 0,
    function( R )
    if Characteristic( R ) = 2 then
      TryNextMethod();
    fi;
    return true;
    end );


#############################################################################
##
#M  IsCentral( <R>, <U> )  . . . . . . . .  test if <U> is centralized by <R>
##
##  For associative rings, we have to check $u a = a u$ only for ring
##  generators $a$ and $u$ of $A$ and $U$, respectively.
##
InstallMethod( IsCentral,
    "method for two associative rings",
    IsIdentical,
    [ IsRing and IsAssociative, IsRing and IsAssociative ], 0,
    IsCentralFromGenerators( GeneratorsOfRing, GeneratorsOfRing ) );

InstallMethod( IsCentral,
    "method for two associative rings-with-one",
    IsIdentical,
    [ IsRingWithOne and IsAssociative,
      IsRingWithOne and IsAssociative ], 0,
    IsCentralFromGenerators( GeneratorsOfRingWithOne,
                             GeneratorsOfRingWithOne ) );


#############################################################################
##
#M  IsCommutative( <R> )  . . . . . . . . check whether a ring is commutative
##
##  In characteristic 2, commutativity is the same as anticommutativity.
##
##  If <R> is associative then we can restrict the check to ring generators.
##
InstallImmediateMethod( IsCommutative,
    IsRing and IsAnticommutative and HasCharacteristic, 0,
    function( R )
    if Characteristic( R ) <> 2 then
      TryNextMethod();
    fi;
    return true;
    end );

InstallMethod( IsCommutative,
    "method for an associative ring",
    true,
    [ IsRing and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfRing ) );

InstallMethod( IsCommutative,
    "method for an associative ring-with-one",
    true,
    [ IsRingWithOne and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfRingWithOne ) );


#############################################################################
##
#M  GeneratorsOfRing( <R> )
#M  GeneratorsOfRingWithOne( <R> )
##
##  'GeneratorsOfMagma' of a ring
##  are also 'GeneratorsOfRing'.
##  'GeneratorsOfAdditiveMagmaWithInverses' of a ring
##  are also 'GeneratorsOfRing'.
##
##  'GeneratorsOfMagmaWithOne' of a ring
##  are also 'GeneratorsOfRingWithOne'.
##  'GeneratorsOfRing' of a ring-with-one
##  are also 'GeneratorsOfRingWithOne'.
##
InstallImmediateMethod( GeneratorsOfRing,
    IsRing and HasGeneratorsOfMagma, 0,
    GeneratorsOfMagma );

InstallImmediateMethod( GeneratorsOfRing,
    IsRing and HasGeneratorsOfAdditiveMagmaWithInverses, 0,
    GeneratorsOfAdditiveMagmaWithInverses );

InstallImmediateMethod( GeneratorsOfRingWithOne,
    IsRingWithOne and HasGeneratorsOfMagmaWithOne, 0,
    GeneratorsOfMagmaWithOne );

InstallImmediateMethod( GeneratorsOfRingWithOne,
    IsRingWithOne and HasGeneratorsOfRing, 0,
    GeneratorsOfRing );


InstallMethod( GeneratorsOfRing, true, [ IsRing ], 0,
    GeneratorsOfMagma );

InstallMethod( GeneratorsOfRing, true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    R -> Set( Concatenation( GeneratorsOfRingWithOne( R ), [ One(R) ] ) ) );


#############################################################################
##
#M  Representative( <R> ) . . . . . . . . . . . . . . . one element of a ring
##
InstallMethod( Representative,
    "method for a ring with generators",
    true,
    [ IsRing and HasGeneratorsOfRing ], 0,
    RepresentativeFromGenerators( GeneratorsOfRing ) );

InstallMethod( Representative,
    "method for a ring-with-one with generators",
    true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    RepresentativeFromGenerators( GeneratorsOfRingWithOne ) );


#############################################################################
##
#M  IdealByGenerators( <R>, <gens> ) . . . . . . .  create an ideal in a ring
##
InstallMethod( IdealByGenerators,
    "method for ring and collection",
    IsIdentical,
    [ IsRing, IsCollection ], 0,
    function( R, gens )
    local I;
    I:= Objectify( NewKind( FamilyObj( R ),
                                IsRing
                            and IsIdealInParent
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfIdeal( I, gens );
    SetParent( I, R );
    return I;
    end );


#############################################################################
##
#M  LeftIdealByGenerators( <R>, <gens> ) . . .  create a left ideal in a ring
##
InstallMethod( LeftIdealByGenerators,
    "method for ring and collection",
    IsIdentical,
    [ IsRing, IsCollection ], 0,
    function( R, gens )
    local I;
    I:= Objectify( NewKind( FamilyObj( R ),
                                IsRing
                            and IsLeftIdealInParent
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfLeftIdeal( I, gens );
    SetParent( I, R );
    return I;
    end );


#############################################################################
##
#M  RightIdealByGenerators( <R>, <gens> ) . .  create a right ideal in a ring
##
InstallMethod( RightIdealByGenerators,
    "method for ring and collection",
    IsIdentical,
    [ IsRing, IsCollection ], 0,
    function( R, gens )
    local I;
    I:= Objectify( NewKind( FamilyObj( R ),
                                IsRing
                            and IsRightIdealInParent
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfRightIdeal( I, gens );
    SetParent( I, R );
    return I;
    end );


#############################################################################
##
#F  Ideal( <R>, <gens> )
#F  Ideal( <R>, <gens>, "basis" )
##
Ideal := function( arg )
    local I;
    if    Length( arg ) <= 1
       or not IsRing( arg[1] )
       or not IsHomogeneousList( arg[2] ) then
      Error( "first argument must be a ring,\n",
             "second argument must be a list of generators" );

    elif IsEmpty( arg[2] ) then

      return IdealNC( arg[1], arg[2] );

    elif     IsIdentical( FamilyObj( arg[1] ),
                          FamilyObj( arg[2] ) )
         and ForAll( arg[2], v -> v in arg[1] ) then

      I:= IdealByGenerators( LeftActingDomain( arg[1] ), arg[2] );
      SetParent( I, arg[1] );
      if Length( arg ) = 3 and arg[3] = "basis" then
        UseBasis( I, arg[2] );
      fi;
      return I;

    fi;
    Error( "usage: Ideal( <R>, <gens> [, \"basis\"] )" );
end;


#############################################################################
##
#F  IdealNC( <R>, <gens>, "basis" )
#F  IdealNC( <R>, <gens> )
##
IdealNC := function( arg )
    local I;
    if IsEmpty( arg[2] ) then

      # If <R> is a FLMLOR then also the ideal is a FLMLOR.
      if IsFLMLOR( arg[1] ) then
        I:= Objectify( NewKind( FamilyObj( arg[1] ),
                                    IsFLMLOR
                                and IsTrivial
                                and IsAttributeStoringRep ),
                       rec() );
        SetLeftActingDomain( I, LeftActingDomain( arg[1] ) );
        SetGeneratorsOfLeftModule( I, AsList( arg[2] ) );
      else
        I:= Objectify( NewKind( FamilyObj( arg[1] ),
                                    IsRing
                                and IsTrivial
                                and IsAttributeStoringRep ),
                       rec() );
      fi;
      SetGeneratorsOfRing( I, AsList( arg[2] ) );

    else

      I:= IdealByGenerators( arg[1], arg[2] );

    fi;
    if Length( arg ) = 3 and arg[3] = "basis" then
      UseBasis( I, arg[2] );
    fi;
    SetParent( I, arg[1] );
    return I;
end;


#############################################################################
##
#F  LeftIdeal( <R>, <gens> )
#F  LeftIdeal( <R>, <gens>, "basis" )
##
LeftIdeal := function( arg )
    local I;
    if    Length( arg ) <= 1
       or not IsRing( arg[1] )
       or not IsHomogeneousList( arg[2] ) then
      Error( "first argument must be a ring,\n",
             "second argument must be a list of generators" );

    elif IsEmpty( arg[2] ) then

      return IdealNC( arg[1], arg[2] );

    elif     IsIdentical( FamilyObj( arg[1] ),
                          FamilyObj( arg[2] ) )
         and ForAll( arg[2], v -> v in arg[1] ) then

      I:= LeftIdealByGenerators( LeftActingDomain( arg[1] ), arg[2] );
      SetParent( I, arg[1] );
      if Length( arg ) = 3 and arg[3] = "basis" then
        UseBasis( I, arg[2] );
      fi;
      return I;

    fi;
    Error( "usage: LeftIdeal( <R>, <gens> [, \"basis\"] )" );
end;


#############################################################################
##
#F  LeftIdealNC( <R>, <gens>, "basis" )
#F  LeftIdealNC( <R>, <gens> )
##
LeftIdealNC := function( arg )
    local I;
    if IsEmpty( arg[2] ) then
      return IdealNC( arg[1], arg[2] );
    fi;

    I:= LeftIdealByGenerators( arg[1], arg[2] );
    if Length( arg ) = 3 and arg[3] = "basis" then
      UseBasis( I, arg[2] );
    fi;

    SetParent( I, arg[1] );
    return I;
end;


#############################################################################
##
#F  RightIdeal( <R>, <gens> )
#F  RightIdeal( <R>, <gens>, "basis" )
##
RightIdeal := function( arg )
    local I;
    if    Length( arg ) <= 1
       or not IsRing( arg[1] )
       or not IsHomogeneousList( arg[2] ) then
      Error( "first argument must be a ring,\n",
             "second argument must be a list of generators" );

    elif IsEmpty( arg[2] ) then

      return IdealNC( arg[1], arg[2] );

    elif     IsIdentical( FamilyObj( arg[1] ),
                          FamilyObj( arg[2] ) )
         and ForAll( arg[2], v -> v in arg[1] ) then

      I:= RightIdealByGenerators( RightActingDomain( arg[1] ), arg[2] );
      SetParent( I, arg[1] );
      if Length( arg ) = 3 and arg[3] = "basis" then
        UseBasis( I, arg[2] );
      fi;
      return I;

    fi;
    Error( "usage: RightIdeal( <R>, <gens> [, \"basis\"] )" );
end;


#############################################################################
##
#F  RightIdealNC( <R>, <gens>, "basis" )
#F  RightIdealNC( <R>, <gens> )
##
RightIdealNC := function( arg )
    local I;
    if IsEmpty( arg[2] ) then
      return IdealNC( arg[1], arg[2] );
    fi;

    I:= RightIdealByGenerators( arg[1], arg[2] );
    if Length( arg ) = 3 and arg[3] = "basis" then
      UseBasis( I, arg[2] );
    fi;

    SetParent( I, arg[1] );
    return I;
end;


#############################################################################
##
#M  IsIdealInParent( <I> )
##
InstallImmediateMethod( IsIdealInParent,
    IsLeftIdealInParent and HasParent, 10,
    function( I )
    I:= Parent( I );
    if    ( HasIsCommutative( I ) and IsCommutative( I ) )
       or ( HasIsAnticommutative( I ) and IsAnticommutative( I ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallImmediateMethod( IsIdealInParent,
    IsRightIdealInParent and HasParent, 10,
    function( I )
    I:= Parent( I );
    if    ( HasIsCommutative( I ) and IsCommutative( I ) )
       or ( HasIsAnticommutative( I ) and IsAnticommutative( I ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  InterpolatedPolynomial( <R>, <x>, <y> ) . . . . . . . . . . interpolation
##
InstallOtherMethod( InterpolatedPolynomial, true,
    [ IsRing, IsObject, IsObject ], 0,
    function( R, x, y )
    local   a,  t,  k,  i,  p;

    a := [];
    t := ShallowCopy(y);
    for i  in [ 1 .. Length(x) ]  do
        for k  in [ i-1, i-2 .. 1 ]  do
            t[k] := ( t[k+1] - t[k] ) / ( x[i] - x[k] );
        od;
        a[i] := t[1];
    od;
    p := a[Length(x)];
    for i  in [ Length(x)-1, Length(x)-2 .. 1 ]  do
        p := p * (Indeterminate(R)-x[i]) + a[i];
    od;
    return p;
    end );


#############################################################################
##
#M  RingByGenerators( <gens> )  . . . . . . .  ring generated by a collection
##
InstallMethod( RingByGenerators,
    "method for a collection",
    true,
    [ IsCollection ], 0,
    function( gens )
    local R;
    R:= Objectify( NewKind( FamilyObj( gens ),
                            IsRing and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfRing( R, gens );
    return R;
    end );


#############################################################################
##
#M  DefaultRingByGenerators( <gens> )   . . . .  ring containing a collection
##
InstallMethod( DefaultRingByGenerators, true, [ IsRingElementCollection ], 0,
    RingByGenerators );


#############################################################################
##
#F  Ring( <z>, ... ) . . . . . . . . . . . . . ring generated by a collection
#F  Ring( [ <z>, ... ] ) . . . . . . . . . . . ring generated by a collection
##
Ring := function ( arg )
    local   R;          # ring containing the elements of <arg>, result

    # special case for one square matrix
    if      Length(arg) = 1
        and IsMatrix( arg[1] ) and Length( arg[1] ) = Length( arg[1][1] )
    then
        R := RingByGenerators( arg );

    # special case for list of elements
    elif Length(arg) = 1  and IsList(arg[1])  then
        R := RingByGenerators( arg[1] );

    # other cases
    else
        R := RingByGenerators( arg );
    fi;

    # return the ring
    return R;
end;


#############################################################################
##
#F  DefaultRing( <z>, ... )  . . . . . . default ring containing a collection
#F  DefaultRing( [ <z>, ... ] )  . . . . default ring containing a collection
##
DefaultRing := function ( arg )
    local   R;          # ring containing the elements of <arg>, result

    # special case for one square matrix
    if    Length(arg) = 1
        and IsMatrix( arg[1] ) and Length( arg[1] ) = Length( arg[1][1] )
    then
        R := DefaultRingByGenerators( arg );

    # special case for list of elements
    elif Length(arg) = 1  and IsList(arg[1])  then
        R := DefaultRingByGenerators( arg[1] );

    # other cases
    else
        R := DefaultRingByGenerators( arg );
    fi;

    # return the default ring
    return R;
end;


#############################################################################
##
#F  Subring( <R>, <gens> ) . . . . . . . . subring of <R> generated by <gens>
#F  SubringNC( <R>, <gens> )
##
Subring := function( R, gens )
    local S;
    if IsEmpty( gens ) then
      Error( "<gens> must be a nonempty list" );
    elif     IsHomogeneousList( gens )
         and IsIdentical( ElementsFamily( FamilyObj(R) ), FamilyObj( gens ) )
         and ForAll( gens, g -> g in R ) then
      S:= RingByGenerators( gens );
      SetParent( S, R );
      return S;
    fi;
    Error( "<gens> must be a list of elements in <R>" );
end;

SubringNC := function( R, gens )
    local S;
    if Length( gens ) = 0 then
      S:= Objectify( NewKind( FamilyObj( R ),
                              IsRing and IsAttributeStoringRep ),
                     rec() );
      SetGeneratorsOfRing( S, AsList( gens ) );
    else
      S:= RingByGenerators( gens );
    fi;
    SetParent( S, R );
    return S;
end;


#############################################################################
##
#M  RingWithOneByGenerators( <gens> ) . .  ring-with-one gen. by a collection
##
InstallMethod( RingWithOneByGenerators,
    "method for a collection",
    true,
    [ IsCollection ], 0,
    function( gens )
    local R;
    R:= Objectify( NewKind( FamilyObj( gens ),
                            IsRingWithOne and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfRingWithOne( R, gens );
    return R;
    end );


#############################################################################
##
#F  RingWithOne( <z>, ... ) . . . . . ring-with-one generated by a collection
#F  RingWithOne( [ <z>, ... ] ) . . . ring-with-one generated by a collection
##
RingWithOne := function ( arg )
    local   R;          # ring containing the elements of <arg>, result

    # special case for one square matrix
    if      Length(arg) = 1
        and IsMatrix( arg[1] ) and Length( arg[1] ) = Length( arg[1][1] )
    then
        R := RingWithOneByGenerators( arg );

    # special case for list of elements
    elif Length(arg) = 1  and IsList(arg[1])  then
        R := RingWithOneByGenerators( arg[1] );

    # other cases
    else
        R := RingWithOneByGenerators( arg );
    fi;

    # return the ring
    return R;
end;


#############################################################################
##
#M  IsRingHomomorphism( <fun> ) . . . . . . . .  is <fun> a ring homomorphism
##
InstallOtherMethod( IsRingHomomorphism, true, [ IsGeneralMapping ], 0,
    function ( fun )

    # check that <fun> is a function
    if not IsMapping( fun )  then
        Error("<fun> must be a single valued mapping");
    fi;

    # test that source and range are rings
    if not IsRing( Source( fun ) )  then
        Error( "source of <fun> must be a ring" );
#T return false;
    fi;
    if not IsRing( Range( fun ) )  then
        Error( "range of <fun> must be a ring" );
#T return false;
    fi;

    # test the linearity explicitly if the source is finite
    if IsFinite( Source( fun ) )  then
        return ForAll( Source( fun ),
                       x -> ForAll( Source( fun ),
                                  y -> Image( fun, x * y )
                                     = Image( fun, x ) * Image( fun, y )
                                   and Image( fun, x + y )
                                     = Image( fun, x ) + Image( fun, y ) ) );

    # otherwise give up
    else
        TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsAssociated( <R>, <r>, <s> ) .  test if two ring elements are associated
##
InstallMethod( IsAssociated,
    "method for ring and two ring elements",
    IsCollsElmsElms,
    [ IsRing, IsRingElement, IsRingElement ], 0,
    function( R, r, s )
    local q;

    # if a list of the units is already known, use it
    if HasUnits( R ) then
      return r in Units( R ) * s;

    elif s = Zero( R ) then
      return r = Zero( R );

    # or check if the quotient is a unit
    else
      q:= Quotient( R, r, s );
      return q <> fail and IsUnit( R, q );
    fi;
    end );


#############################################################################
##
#M  IsAssociated( <r>, <s> )  . . .  test if two ring elements are associated
##
InstallOtherMethod( IsAssociated,
    "method for two ring elements",
    IsIdentical, 
    [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return IsAssociated( DefaultRingByGenerators( [ r, s ] ), r, s );
    end );


#############################################################################
##
#M  IsSubset( <R>, <S> )  . . . . . . . . . . . . . . . . . . . for two rings
##
InstallMethod( IsSubset,
    "method for two rings",
    IsIdentical,
    [ IsRing, IsRing and HasGeneratorsOfRing ], 0,
    function( R, S )
    return IsSubset( R, GeneratorsOfRing( S ) );
    end );


#############################################################################
##
#M  IsSubset( <R>, <S> )  . . . . . . . . . . . . . .  for two rings-with-one
##
InstallMethod( IsSubset,
    "method for two rings-with-one",
    IsIdentical,
    [ IsRingWithOne, IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    function( R, S )
    return IsSubset( R, GeneratorsOfRingWithOne( S ) );
    end );


#############################################################################
##
#M  Enumerator( <G> ) . . . . . . . . . . . . . set of the elements of a ring 
#M  EnumeratorSorted( <G> ) . . . . . . . . . . set of the elements of a ring
##
EnumeratorOfRing := function( R )

    local   elms,       # elements of <R>, result
            set,        # set corresponding to <elms>
            gens,       # ring generators of <R>
            elm,        # one element of <elms>
            gen,        # one generator of <R>
            new;        # product or sum of <elm> and <gen>

    # check that we can handle this ring
    if HasIsFinite( R ) and not IsFinite( R ) then
        TryNextMethod();

    # otherwise use an orbit like algorithm
    else
        elms := [ Zero( R ) ];
        set  := ShallowCopy( elms );
        gens := GeneratorsOfRing( R );
        for elm  in elms  do
            for gen  in gens  do
                new := elm + gen;
                if not new in set  then
                    Add( elms, new );
                    AddSet( set, new );
                fi;
                new := elm * gen;
                if not new in set  then
                    Add( elms, new );
                    AddSet( set, new );
                fi;
            od;
        od;
    fi;
    return set;
end;

InstallMethod( Enumerator,
    "generic method for a ring",
    true, [ IsRing and IsAttributeStoringRep ], 0,
    EnumeratorOfRing );

InstallMethod( EnumeratorSorted,
    "generic method for a ring",
    true, [ IsRing and IsAttributeStoringRep ], 0,
    EnumeratorOfRing );


#############################################################################
##
#M  IsIntegralRing( <D> ) . . . . . . . .  test if a ring is an integral ring
##
InstallMethod( IsIntegralRing,
    "method for a ring",
    true,
    [ IsRing ], 0,
    function ( R )
    local   elms, zero, i, k;

    if IsFinite( R )  then
        if not IsCommutative( R )  then
            return false;
        fi;
        elms := Enumerator( R );
        zero := Zero( R );
        for i  in [1..Length(elms)]  do
            for k  in [i+1..Length(elms)]  do
                if elms[i] * elms[k] = zero then
                    return false;
                fi;
            od;
        od;
        return true;
    else
        TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Quotient( <r>, <s> )  . . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( Quotient,
    "method for two ring elements",
    IsIdentical,
    [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return Quotient( DefaultRing( [ r, s ] ), r, s );
    end );


#############################################################################
##
#M  IsUnit( <r> ) . . . . . . . . . . . . . . .  delegate to the default ring
#M  IsUnit( <R>, <r> )  . . . . . . . . . . . .  test if an element is a unit
##
InstallOtherMethod( IsUnit,
    "method for a ring element",
    true,
    [ IsRingElement ], 0,
    r -> IsUnit( DefaultRing( [ r ] ), r ) );

InstallMethod( IsUnit,
    "method for a ring with known units and a ring element",
    IsCollsElms,
    [ IsRing and HasUnits, IsRingElement ], 0,
    function ( R, r )
    return r in Units( R );
    end );

InstallMethod( IsUnit,
    "method for a ring and a ring element",
    IsCollsElms,
    [ IsRing, IsRingElement ], 0,
    function ( R, r )
    # simply try to compute the inverse
    return r <> Zero( R ) and Quotient( R, One( R ), r ) <> fail;
    end );


#############################################################################
##
#M  Units( <R> )  . . . . . . . . . . . . . . . . . . . . . . units of a ring
##
InstallMethod( Units,
    "method for a finite ring",
    true, [ IsRing ], 0,
    function ( R )
    local units,
          elm;

    if not IsFinite( R ) then
      TryNextMethod();
    fi;

    units:= GroupByGenerators( [], One( R ) );
    for elm in Enumerator( R ) do
      if IsUnit( R, elm ) and not elm in units then
        units:= ClosureGroupDefault( units, elm );
      fi;
    od;
    return units;
    end );


#############################################################################
##
#M  StandardAssociate( <r> )  . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( StandardAssociate,
    "method for a ring element",
    true, [ IsRingElement ], 0,
    r -> StandardAssociate( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#M  Associates( <r> ) . . . . . . . . . . . . .  delegate to the default ring
#M  Associates( <R>, <r> )  . . . . . . . . . .  associates of a ring element
##
InstallOtherMethod( Associates,
    "method for a ring element",
    true, [ IsRingElement ], 0,
    r -> Associates( DefaultRing( [ r ] ), r ) );

InstallMethod( Associates,
    "method for a ring and a ring element",
    IsCollsElms, [ IsRing, IsRingElement ], 0,
    function( R, r );
    return AsListSorted( Enumerator( Units( R ) ) * r );
    end );


#############################################################################
##
#M  IsPrime( <r> )  . . . . . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( IsPrime,
    "method for a ring element",
    true, [ IsRingElement ], 0,
    r -> IsPrime( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#M  Factors( <r> )  . . . . . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( Factors,
    "method for a ring element",
    true, [ IsRingElement ], 0,
    r -> Factors( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#M  EuclideanDegree( <r> )  . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( EuclideanDegree,
    "method for a ring element",
    true, [ IsRingElement ], 0,
    r -> EuclideanDegree( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#F  EuclideanRemainder( <r>, <m> )  . . . . . .  delegate to the default ring
#F  EuclideanRemainder( <R>, <r>, <m> ) . . . . . . . . . euclidean remainder
##
InstallOtherMethod( EuclideanRemainder,
    "method for two ring elements",
    IsIdentical, [ IsRingElement, IsRingElement ], 0,
    function( r, m )
    return EuclideanRemainder( DefaultRing( [ r, m ] ), r, m );
    end );

InstallMethod( EuclideanRemainder,
    "method for a Euclidean ring and two ring elements",
    IsCollsElmsElms, [ IsEuclideanRing, IsRingElement, IsRingElement ], 0,
    function( R, r, m )
    return QuotientRemainder( R, r, m )[2];
    end );


#############################################################################
##
#F  EuclideanQuotient( <r>, <m> ) . . . . . . .  delegate to the default ring
#F  EuclideanQuotient( <R>, <r>, <m> )  . . . . . . . . . euclidean remainder
##
InstallOtherMethod( EuclideanQuotient,
    "method for two ring elements",
    IsIdentical, [ IsRingElement, IsRingElement ], 0,
    function( r, m )
    return EuclideanQuotient( DefaultRing( [ r, m ] ), r, m );
    end );

InstallMethod( EuclideanQuotient,
    "method for a Euclidean ring and two ring elements",
    IsCollsElmsElms, [ IsEuclideanRing, IsRingElement, IsRingElement ], 0,
    function( R, r, m )
    return QuotientRemainder( R, r, m )[1];
    end );


#############################################################################
##
#M  QuotientRemainder( <r>, <m> ) . . . . . . .  delegate to the default ring
##
InstallOtherMethod( QuotientRemainder,
    "method for two ring elements",
    IsIdentical, [ IsRingElement, IsRingElement ], 0,
    function( r, m )
    return QuotientRemainder( DefaultRing( [ r, m ] ), r, m );
    end );


#############################################################################
##
#M  QuotientMod( <r>, <s>, <m> )  . . . . . . .  delegate to the default ring
#M  QuotientMod( <R>, <r>, <s>, <m> ) . . . . . quotient of two ring elements
#M                                                             modulo another
##
InstallOtherMethod( QuotientMod,
    "method for three ring elements",
    function( F1, F2, F3 )
    return IsIdentical( F1, F2 ) and IsIdentical( F2, F3 );
    end,
#T allow 'IsIdentical' for more than two arguments!!
    [ IsRingElement, IsRingElement, IsRingElement ], 0,
    function( r, s, m )
    return QuotientMod( DefaultRing( [ r, s, m ] ), r, s, m );
    end );

InstallMethod( QuotientMod,
    "method for a Euclidean ring and three ring elements",
    IsCollsElmsElmsElms,
    [ IsEuclideanRing, IsRingElement, IsRingElement, IsRingElement ], 0,
    function( R, r, s, m )
    local  f, g, h, fs, gs, hs, q, t;

    if not IsSubset( R, [ r, s, m ] ) then
      Error( "<r>, <s>, <m> must lie in <R>" );
    fi;

    f := s;  fs := 1;
    g := m;  gs := 0;
    while g <> Zero( R ) do
    	t := QuotientRemainder( R, f, g );
        h := g;          hs := gs;
        g := t[2];       gs := fs - t[1] * gs;
        f := h;          fs := hs;
    od;
    q := Quotient( R, r, f );
    if q = fail  then
        return fail;
    else
        return EuclideanRemainder( R, fs * q, m );
    fi;
    end );


#############################################################################
##
#M  PowerMod( <r>, <e>, <m> ) . . . . . . . . .  delegate to the default ring
#M  PowerMod( <R>, <r>, <e>, <m> )  . . . power of a ring element mod another
##
InstallOtherMethod( PowerMod,
    "method for ring element, integer, and ring element",
    true, [ IsRingElement, IsInt, IsRingElement ], 0,
    function( r, e, m )
    return PowerMod( DefaultRing( [ r, m ] ), r, e, m );
    end );

InstallMethod( PowerMod,
    "method for Euclidean ring, ring element, integer, and ring element",
    true,
    [ IsRing, IsRingElement, IsInt, IsRingElement ], 0,
    function( R, r, e, m )
    local   pow, f;

    # handle special case
    if e = 0  then
        return One( R );
    fi;

    # reduce r initially
    r := EuclideanRemainder( R, r, m );

    # if e is negative then invert n modulo m with Euclids algorithm
    if e < 0  then
        r := QuotientMod( R, One( R ), r, m );
        if r = fail  then
            Error( "<r> must be invertible modulo <m>" );
        fi;
        e := -e;
    fi;

    # now use the repeated squaring method (right-to-left)
    pow := One( R );
    f := 2 ^ (LogInt( e, 2 ) + 1);
    while 1 < f  do
        pow := EuclideanRemainder( R, pow * pow, m );
        f := QuoInt( f, 2 );
        if f <= e  then
            pow := EuclideanRemainder( R, pow * r, m );
            e := e - f;
        fi;
    od;

    # return the power
    return pow;
    end );


#############################################################################
##
#M  Gcd( <r>, <s> ) . . . . . . . . . . . . . .  delegate to the default ring
#M  Gcd( <R>, <r>, <s> )  . . . . .  greatest common divisor of ring elements
##
InstallOtherMethod( Gcd,
    "method for two ring elements",
    IsIdentical, [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return Gcd( DefaultRing( [ r, s ] ), r, s );
    end );

InstallMethod( Gcd,
    "method for a Euclidean ring and two ring elements",
    IsCollsElmsElms,
    [ IsEuclideanRing, IsRingElement, IsRingElement ], 0,
    function( R, r, s )
    local   gcd, u, v, w;

    if not ( r in R and s in R ) then
      Error( "<r> and <s> must lie in <R>" );
    fi;

    # perform a Euclidean algorithm
    u := r;
    v := s;
    while v <> Zero( R ) do
        w := v;
        v := EuclideanRemainder( R, u, v );
        u := w;
    od;
    gcd := u;

    # norm the element
    gcd := StandardAssociate( R, gcd );

    # return the gcd
    return gcd;
    end );


#############################################################################
##
#M  Gcd( <ring>, <list> ) . . . . . . . . . . . . . for list of ring elements
##
InstallOtherMethod( Gcd,
    "method for Euclidean ring and list of ring elements",
    IsIdentical,
    [ IsEuclideanRing, IsHomogeneousList ], 0,
    function( R, list )
    local i,g;
    if not IsSubset( R, list ) then
      Error( "all entries in <list> must lie in <R>" );
    fi;
    g:= list[1];
    for i in [ 2 .. Length( list ) ] do
      g:= Gcd( R, g, list[i] );
    od;
    return g;
    end );


#############################################################################
##
#M  GcdRepresentation( <r>, <s> ) . . . . . . .  delegate to the default ring
#M  GcdRepresentation( <R>, <r>, <s> )  . . . . . . representation of the gcd
##
InstallOtherMethod( GcdRepresentation,
    "method for two ring elements",
    IsIdentical, [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return GcdRepresentation( DefaultRing( [ r, s ] ), r, s );
    end );

InstallMethod( GcdRepresentation,
    "method for a Euclidean ring and two ring elements",
    IsCollsElmsElms,
    [ IsEuclideanRing, IsRingElement, IsRingElement ], 0,
    function( R, x, y )
    local   f, g, h, fx, gx, hx, q, t;
    f := x;  fx := One( R );
    g := y;  gx := Zero( R );
    while g <> Zero( R ) do
    	t := QuotientRemainder( R, f, g );
        h := g;          hx := gx;
        g := t[2];       gx := fx - t[1] * gx;
        f := h;          fx := hx;
    od;
    q := Quotient(R, StandardAssociate(R, f), f);
    if y = Zero( R ) then
        return [ q * fx, Zero( R ) ];
    else
        return [ q * fx, Quotient( R, q * (f - fx * x), y ) ];
    fi;
    end );


#############################################################################
##
#M  GcdRepresentation( <ring>, <list> ) . . . . . . for list of ring elements
##
InstallOtherMethod( GcdRepresentation,
    "method for Euclidean ring and list of ring elements",
    IsIdentical,
    [ IsEuclideanRing, IsHomogeneousList ], 0,
    function( R, list )
    local gcd, rep, i, tmp;
    if not IsSubset( R, list ) then
      Error( "all entries in <list> must lie in <R>" );
    fi;

    # compute the gcd by iterating
    gcd := list[1];
    rep := [ One( R ) ];
    for i  in [ 2 .. Length( list ) ] do
        tmp := GcdRepresentation( R, gcd, list[i] );
        gcd := tmp[1] * gcd + tmp[2] * list[i];
        rep := List( rep, x -> x * tmp[1] );
        Add( rep, tmp[2] );
    od;

    # return the gcd representation
    return rep;
    end );


#############################################################################
##
#M  Lcm( <r>, <s> ) . . . . . . . . . . . . . .  delegate to the default ring
#M  Lcm( <R>, <r>, <s> )  . . . .  least common multiple of two ring elements
##
InstallOtherMethod( Lcm,
    "method for two ring elements",
    IsIdentical, [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return Lcm( DefaultRing( [ r, s ] ), r, s );
    end );

InstallMethod( Lcm,
    "method for a Euclidean ring and two ring elements",
    IsCollsElmsElms,
    [ IsEuclideanRing, IsRingElement, IsRingElement ], 0,
    function( R, r, s )

    # compute the least common multiple
    if r = Zero( R ) and s = Zero( R ) then
      return Zero( R );
    elif r in R and s in R then
      return StandardAssociate( R, Quotient( R, r, Gcd( R, r, s ) ) * s );
    else
      Error( "<r> and <s> must lie in <R>" );
    fi;
    end );


#############################################################################
##
#M  Lcm( <ring>, <list> ) . . . . . . . . . . . . . for list of ring elements
##
InstallOtherMethod( Lcm,
    "method for Euclidean ring and list of ring elements",
    IsIdentical,
    [ IsEuclideanRing, IsHomogeneousList ], 0,
    function( R, list )
    local i,g;
    if not IsSubset( R, list ) then
      Error( "all entries in <list> must lie in <R>" );
    fi;
    g:= list[1];
    for i in [ 2 .. Length( list ) ] do
      g:= Lcm( R, g, list[i] );
    od;
    return g;
    end );


#############################################################################
##
#M  \=( <R>, <S> )  . . . . . . . . . . . . . . . test if two rings are equal
##
InstallMethod( \=,
    "method for two rings with known generators",
    IsIdentical,
    [ IsRing and HasGeneratorsOfRing, IsRing and HasGeneratorsOfRing ], 0,
    function ( R, S )
    if IsFinite( R )  then
      if IsFinite( S )  then
#T really test this?
        return     Size( R ) = Size( S )
               and IsSubset( S, GeneratorsOfRing( R ) );
      else
        return false;
      fi;
    elif IsFinite( S )  then
      return false;
    else
      return     IsSubset( S, GeneratorsOfRing( R ) )
             and IsSubset( R, GeneratorsOfRing( S ) );
    fi;
    end );


#############################################################################
##
#M  ``in parent'' attributes
##
InstallInParentMethod( IsLeftIdealInParent,  IsRing, IsLeftIdeal  );
InstallInParentMethod( IsRightIdealInParent, IsRing, IsRightIdeal );

#############################################################################
##
#E  ring.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



