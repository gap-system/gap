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
##  This file contains generic methods for rings.
##


#############################################################################
##
#M  PrintObj( <R> ) . . . . . . . . . . . . . . . . . . . . . .  print a ring
##
InstallMethod( PrintObj,
    "for a ring",
    true,
    [ IsRing ], 0,
    function( R )
    Print( "Ring( ... )" );
    end );

InstallMethod( PrintObj,
    "for a ring with generators",
    true,
    [ IsRing and HasGeneratorsOfRing ], 0,
    function( R )
    Print( "Ring( ", GeneratorsOfRing( R ), " )" );
    end );


#############################################################################
##
#M  PrintObj( <R> ) . . . . . . . . . . . . . . . . . . print a ring-with-one
##
InstallMethod( PrintObj,
    "for a ring-with-one",
    true,
    [ IsRingWithOne ], 0,
    function( R )
    Print( "RingWithOne( ... )" );
    end );

InstallMethod( PrintObj,
    "for a ring-with-one with generators",
    true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    function( R )
    Print( "RingWithOne( ", GeneratorsOfRingWithOne( R ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <R> )  . . . . . . . . . . . . . . . . . . . . . . . view a ring
##
InstallMethod( ViewObj,
    "for a ring",
    true,
    [ IsRing ], 0,
    function( R )
    Print( "<ring>" );
    end );

InstallMethod( ViewObj,
    "for a ring with known generators",
    true,
    [ IsRing and HasGeneratorsOfRing ], 0,
    function( R )
    Print( "<ring with ",
           Pluralize( Length( GeneratorsOfRing( R ) ), "generator" ), ">" );
    end );


#############################################################################
##
#M  ViewObj( <R> )  . . . . . . . . . . . . . . . . . .  view a ring-with-one
##
InstallMethod( ViewObj,
    "for a ring-with-one",
    true,
    [ IsRingWithOne ], 0,
    function( R )
    Print( "<ring-with-one>" );
    end );

InstallMethod( ViewObj,
    "for a ring-with-one with known generators",
    true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    function( R )
    local nrgens;
    nrgens := Length( GeneratorsOfRingWithOne( R ) );
    Print( "<ring-with-one, with ", Pluralize(nrgens, "generator" ), ">" );
    end );


#############################################################################
##
#M  IsAnticommutative( <R> ) . . . . . . . . . for a ring in characteristic 2
##
InstallImmediateMethod( IsAnticommutative,
    IsRing and IsCommutative and HasCharacteristic, 0,
    function( R )
    if Characteristic( R ) <> 2 then
      TryNextMethod();
    fi;
    return true;
    end );


#############################################################################
##
#M  IsAnticommutative( <R> ) . . . . . test whether a ring is anticommutative
##
InstallMethod( IsAnticommutative,
    "generic method for rings",
    true,
    [ IsRing ], 0,
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
#M  IsZeroSquaredRing(<R>)  . . . .  for anticomm. ring in odd characteristic
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
#M  IsZeroSquaredRing(<R>)  . test whether the square of each element is zero
##
InstallMethod( IsZeroSquaredRing,
    "for a ring",
    true,
    [ IsRing ], 0,
    function( R )
    local zero;
    zero:= Zero( R );
    return ForAll( R, r -> r^2 = zero );
    end );


#############################################################################
##
#M  IsZeroMultiplicationRing(<R>)
##
InstallImmediateMethod( IsZeroMultiplicationRing,
    IsRingWithOne and HasIsTrivial, 0,
    IsTrivial );


#############################################################################
##
#M  IsCentral( <R>, <U> )  . . . . . . . .  test if <U> is centralized by <R>
##
##  For associative rings, we have to check $u a = a u$ only for ring
##  generators $a$ and $u$ of $A$ and $U$, respectively.
##
InstallMethod( IsCentral,
    "for two associative rings",
    IsIdenticalObj,
    [ IsRing and IsAssociative, IsRing and IsAssociative ],
    IsCentralFromGenerators( GeneratorsOfRing, GeneratorsOfRing ) );

InstallMethod( IsCentral,
    "for two associative rings-with-one",
    IsIdenticalObj,
    [ IsRingWithOne and IsAssociative,
      IsRingWithOne and IsAssociative ],
    IsCentralFromGenerators( GeneratorsOfRingWithOne,
                             GeneratorsOfRingWithOne ) );

#############################################################################
##
#M  IsCentral( <R>, <x> )  . . . . . . . .  test if <x> is centralized by <R>
##
InstallMethod( IsCentral,
    "for an associative ring and an element",
    IsCollsElms,
    [ IsRing and IsAssociative, IsObject ],
    IsCentralElementFromGenerators( GeneratorsOfRing ) );

InstallMethod( IsCentral,
    "for an associative ring-with-one and an element",
    IsCollsElms,
    [ IsRingWithOne and IsAssociative, IsObject ],
    IsCentralElementFromGenerators( GeneratorsOfRingWithOne ) );


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
    "for an associative ring",
    true,
    [ IsRing and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfRing ) );

InstallMethod( IsCommutative,
    "for an associative ring-with-one",
    true,
    [ IsRingWithOne and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfRingWithOne ) );


#############################################################################
##
#M  GeneratorsOfRing( <R> )
#M  GeneratorsOfRingWithOne( <R> )
##
##  `GeneratorsOfMagma' of a ring
##  are also `GeneratorsOfRing'.
##  `GeneratorsOfAdditiveMagmaWithInverses' of a ring
##  are also `GeneratorsOfRing'.
##
##  `GeneratorsOfMagmaWithOne' of a ring
##  are also `GeneratorsOfRingWithOne'.
##  `GeneratorsOfRing' of a ring-with-one
##  are also `GeneratorsOfRingWithOne'.
##
InstallImmediateMethod( GeneratorsOfRing,
    IsRing and HasGeneratorsOfMagma and IsAttributeStoringRep, 0,
    GeneratorsOfMagma );

InstallImmediateMethod( GeneratorsOfRing,
    IsRing and HasGeneratorsOfAdditiveMagmaWithInverses
           and IsAttributeStoringRep, 0,
    GeneratorsOfAdditiveMagmaWithInverses );

InstallImmediateMethod( GeneratorsOfRingWithOne,
    IsRingWithOne and HasGeneratorsOfMagmaWithOne
                  and IsAttributeStoringRep, 0,
    GeneratorsOfMagmaWithOne );

InstallImmediateMethod( GeneratorsOfRingWithOne,
    IsRingWithOne and HasGeneratorsOfRing and IsAttributeStoringRep, 0,
    GeneratorsOfRing );


InstallMethod( GeneratorsOfRing,
    "for a ring",
    true,
    [ IsRing ], 0,
    GeneratorsOfMagma );

InstallMethod( GeneratorsOfRing,
    "for a ring-with-one with generators",
    true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    R -> Concatenation( GeneratorsOfRingWithOne( R ), [ One(R) ] ) );


#############################################################################
##
#M  Representative( <R> ) . . . . . . . . . . . . . . . one element of a ring
##
InstallMethod( Representative,
    "for a ring with generators",
    true,
    [ IsRing and HasGeneratorsOfRing ], 0,
    RepresentativeFromGenerators( GeneratorsOfRing ) );

InstallMethod( Representative,
    "for a ring-with-one with generators",
    true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    RepresentativeFromGenerators( GeneratorsOfRingWithOne ) );


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
    "for a collection",
    true,
    [ IsCollection ], 0,
    function( gens )
    local R;
    R:= Objectify( NewType( FamilyObj( gens ),
                            IsRing and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfRing( R, gens );
    return R;
    end );


#############################################################################
##
#M  DefaultRingByGenerators( <gens> )   . . . .  ring containing a collection
##
InstallMethod( DefaultRingByGenerators,
    "for a collection",
    true,
    [ IsCollection ], 0,
    RingByGenerators );


#############################################################################
##
#F  Ring( <z>, ... ) . . . . . . . . . . . . . ring generated by a collection
#F  Ring( [ <z>, ... ] ) . . . . . . . . . . . ring generated by a collection
##
InstallGlobalFunction( Ring, function ( arg )
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
end );


#############################################################################
##
#F  DefaultRing( <z>, ... )  . . . . . . default ring containing a collection
#F  DefaultRing( [ <z>, ... ] )  . . . . default ring containing a collection
##
InstallGlobalFunction( DefaultRing, function ( arg )
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
end );


#############################################################################
##
#F  Subring( <R>, <gens> ) . . . . . . . . subring of <R> generated by <gens>
#F  SubringNC( <R>, <gens> )
##
InstallGlobalFunction( Subring, function( R, gens )
    local S;
    if IsEmpty( gens ) then
      Error( "<gens> must be a nonempty list" );
    elif     IsHomogeneousList( gens )
         and IsIdenticalObj( FamilyObj(R), FamilyObj( gens ) )
         and ForAll( gens, g -> g in R ) then
      S:= RingByGenerators( gens );
      SetParent( S, R );
      return S;
    fi;
    Error( "<gens> must be a list of elements in <R>" );
end );

InstallGlobalFunction( SubringNC, function( R, gens )
    local S;
    S:= RingByGenerators( gens );
    SetParent( S, R );
    return S;
end );


#############################################################################
##
#F  SubringWithOne( <R>, <gens> )  . . . . subring of <R> generated by <gens>
#F  SubringWithOneNC( <R>, <gens> )
##
InstallGlobalFunction( SubringWithOne, function( R, gens )
    local S;
    if IsEmpty( gens ) then
      S:= RingWithOneByGenerators( [ One( R ) ] );
      SetParent( S, R );
      return S;
    elif     IsHomogeneousList( gens )
         and IsIdenticalObj( FamilyObj(R), FamilyObj( gens ) )
         and ForAll( gens, g -> g in R ) then
      S:= RingWithOneByGenerators( gens );
      SetParent( S, R );
      return S;
    fi;
    Error( "<gens> must be a list of elements in <R>" );
end );

InstallGlobalFunction( SubringWithOneNC, function( R, gens )
    local S;
    if IsEmpty( gens ) then
      S:= Objectify( NewType( FamilyObj( R ),
                              IsRingWithOne and IsAttributeStoringRep ),
                     rec() );
      SetGeneratorsOfRingWithOne( S, AsList( gens ) );
    else
      S:= RingWithOneByGenerators( gens );
    fi;
    SetParent( S, R );
    return S;
end );


#############################################################################
##
#M  RingWithOneByGenerators( <gens> ) . .  ring-with-one gen. by a collection
##
InstallMethod( RingWithOneByGenerators,
    "for a collection",
    true,
    [ IsCollection ], 0,
    function( gens )
    local R;
    R:= Objectify( NewType( FamilyObj( gens ),
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
InstallGlobalFunction( RingWithOne, function ( arg )
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
end );


#############################################################################
##
#M  IsAssociated( <R>, <r>, <s> ) .  test if two ring elements are associated
##
InstallMethod( IsAssociated,
    "for a ring and two ring elements",
    IsCollsElmsElms,
    [ IsRing, IsRingElement, IsRingElement ], 0,
    function( R, r, s )
    local q;

    # if a list of the units is already known, use it
    if HasUnits( R ) then
      return ForAny( Units( R ), u -> r = u * s );

    elif s = Zero( R ) then
      return r = Zero( R );

    # or check if the quotient is a unit
    else
      q:= Quotient( R, r, s );
      if q <> fail then return IsUnit( R, q ); fi;
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsAssociated( <r>, <s> )  . . .  test if two ring elements are associated
##
InstallOtherMethod( IsAssociated,
    "for two ring elements",
    IsIdenticalObj,
    [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return IsAssociated( DefaultRingByGenerators( [ r, s ] ), r, s );
    end );


#############################################################################
##
#M  IsSubset( <R>, <S> )  . . . . . . . . . . . . . . . . . . . for two rings
##
InstallMethod( IsSubset,
    "for two rings",
    IsIdenticalObj,
    [ IsRing, IsRing and HasGeneratorsOfRing ],
    function( R, S )
    return IsSubset( R, GeneratorsOfRing( S ) );
    end );


#############################################################################
##
#M  IsSubset( <R>, <S> )  . . . . . . . . . . . . . .  for two rings-with-one
##
InstallMethod( IsSubset,
    "for two rings-with-one",
    IsIdenticalObj,
    [ IsRing, IsRingWithOne and HasGeneratorsOfRingWithOne ],
    function( R, S )
    local gens;

    gens:= GeneratorsOfRingWithOne( S );
    return IsSubset( R, gens ) and
           ( ( IsRingWithOne( R ) and not IsEmpty( gens ) )
             or One( S ) in R );
    end );


#############################################################################
##
#M  Enumerator( <R> ) . . . . . . . . . . . . . set of the elements of a ring
##
##  We must be careful to call `GeneratorsOfRing' only if ring generators are
##  known; if we have only ideal generators then a different `Enumerator'
##  method is used.
##
BindGlobal( "EnumeratorOfRing", function( R )

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
                new := gen * elm;
                if not new in set  then
                    Add( elms, new );
                    AddSet( set, new );
                fi;
            od;
        od;
    fi;
    return set;
end );

InstallMethod( Enumerator,
    "generic method for a ring with known generators",
    true,
    [ IsRing and HasGeneratorsOfRing ], 0,
    EnumeratorOfRing );


InstallMethod( Enumerator,
    "generic method for a ring-with-one with known generators",
    true,
    [ IsRingWithOne and HasGeneratorsOfRingWithOne ], 0,
    EnumeratorOfRing );


#############################################################################
##
#M  Size( <R> ) . . . . . . . . . . . .  characteristic zero ring is infinite
##
InstallMethod( Size,
    "characteristic zero ring is infinite",
    [ IsRing and HasGeneratorsOfRing and HasCharacteristic ],
    function( R )
    if Characteristic( R ) <> 0 then
      TryNextMethod();
    elif ForAll( GeneratorsOfRing( R ), IsZero ) then
      return 1;
    fi;
    return infinity;
    end );


#############################################################################
##
#M  IsIntegralRing( <D> ) . . . . . . . .  test if a ring is an integral ring
##
InstallMethod( IsIntegralRing,
    "for a ring",
    true,
    [ IsRing ], 0,
    function ( R )
    local   elms, zero, i, k;

    if IsFinite( R )  then
        if IsTrivial( R ) or not IsCommutative( R )  then
            return false;
        fi;
        elms := Enumerator( R );
        zero := Zero( R );
        for i  in [1..Length(elms)]  do
            if elms[i] = zero then continue; fi;
            for k  in [i+1..Length(elms)]  do
                if elms[k] = zero then continue; fi;
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
#M  ClosureRing( <R>, <r> ) . . . . . . . . . . . . . closure with an element
##
InstallMethod( ClosureRing,
    "for a ring and a ring element",
    IsCollsElms,
    [ IsRing, IsRingElement ], 0,
    function( R, r )

    # if possible test if the element lies in the ring already,
    if     HasGeneratorsOfRing( R )
       and r in GeneratorsOfRing( R ) then
      return R;

    # otherwise make a new ring
    else
      return Ring( Concatenation( GeneratorsOfRing( R ), [ r ] ) );
    fi;
    end );

InstallMethod( ClosureRing,
    "for a ring-with-one and a ring element",
    IsCollsElms,
    [ IsRingWithOne, IsRingElement ], 0,
    function( R, r )

    # if possible test if the element lies in the ring already,
    if     HasGeneratorsOfRingWithOne( R )
       and r in GeneratorsOfRingWithOne( R ) then
      return R;

    # otherwise make a new ring-with-one
    else
      return RingWithOne( Concatenation( GeneratorsOfRingWithOne( R ),
                                         [ r ] ) );
    fi;
    end );

InstallMethod( ClosureRing,
    "for a ring containing the whole family, and a ring element",
    IsCollsElms,
    [ IsRing and IsWholeFamily, IsRingElement ],
    SUM_FLAGS, # can't do better
    ReturnFirst );


#############################################################################
##
#M  ClosureRing( <R>, <S> ) . . . . . . . . . . . . . .  closure of two rings
##
InstallMethod( ClosureRing,
    "for two rings",
    IsIdenticalObj,
    [ IsRing, IsRing ], 0,
    function( R, S )
    local   r;          # one generator

    for r in GeneratorsOfRing( S ) do
      R := ClosureRing( R, r );
    od;
    return R;
    end );

InstallMethod( ClosureRing,
    "for two rings-with-one",
    IsIdenticalObj,
    [ IsRingWithOne, IsRingWithOne ], 0,
    function( R, S )
    local   r;          # one generator

    for r in GeneratorsOfRingWithOne( S ) do
      R := ClosureRing( R, r );
    od;
    return R;
    end );

InstallMethod( ClosureRing,
    "for a ring cont. the whole family, and a collection",
    IsIdenticalObj,
    [ IsRing and IsWholeFamily, IsCollection ],
    SUM_FLAGS, # can't do better
    ReturnFirst );


#############################################################################
##
#M  ClosureRing( <R>, <C> ) . . . . . . . . . . . . . . . . . closure of ring
##
InstallMethod( ClosureRing,
    "for a ring and a collection of elements",
    IsIdenticalObj,
    [ IsRing, IsCollection ], 0,
    function( R, list )
    local   r;          # one generator
    for r in list do
      R:= ClosureRing( R, r );
    od;
    return R;
    end );


#############################################################################
##
#M  Quotient( <r>, <s> )  . . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( Quotient,
    "for two ring elements (delegate to three argument version",
    IsIdenticalObj,
    [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return Quotient( DefaultRing( [ r, s ] ), r, s );
    end );

InstallMethod( Quotient,
    "for a ring and two ring elements",
    IsCollsElmsElms,
    [ IsRing, IsRingElement, IsRingElement ], 0,
    function( R, r, s )
    local quo;
    quo:= Inverse( s );
    if quo = fail then
      TryNextMethod();
    fi;
    quo:= r * quo;
    if not quo in R then
      quo:= fail;
    fi;
    return quo;
    end );


#############################################################################
##
#M  IsUnit( <r> ) . . . . . . . . . . . . . . .  delegate to the default ring
#M  IsUnit( <R>, <r> )  . . . . . . . . . . . .  test if an element is a unit
##
InstallOtherMethod( IsUnit,
    "for a ring element",
    true,
    [ IsRingElement ], 0,
    r -> IsUnit( DefaultRing( [ r ] ), r ) );

InstallMethod( IsUnit,
    "for a ring with known units and a ring element",
    IsCollsElms,
    [ IsRing and HasUnits, IsRingElement ], 0,
    function ( R, r )
    return r in Units( R );
    end );

InstallMethod( IsUnit,
    "for a ring and a ring element",
    IsCollsElms,
    [ IsRing, IsRingElement ], 0,
    function ( R, r )
    local one;
    one:= One( R );
    if one =  fail then
      return false;
    else

      # simply try to compute the inverse
      return r <> Zero( R ) and Quotient( R, one, r ) <> fail;
#T allowed?
    fi;
    end );


#############################################################################
##
#M  Units( <R> )  . . . . . . . . . . . . . . . . . . . . . . units of a ring
##
InstallMethod( Units,
    "for a (finite) ring",
    true,
    [ IsRing ], 0,
    function ( R )
    local one,
          units,
          pow,elm,idemp,expo,case,idempo;

    expo:=1;
    one:= One( R );
    if one = fail then
      return [];
    elif not IsFinite( R ) then
      TryNextMethod();
    fi;

    # what power until you get idempotent (counting 1/0 as idempotent)
    idempo:=function(elm)
    local a,i;
      i:=1;
      a:=elm;
      repeat
        a:=a*elm;
        i:=i+1;
      until a=a*a;
      return i;
    end;

    if IsAssociative(R) then
      expo:=1;

      units:= GroupByGenerators( [], one );
      idemp:=[];
      for elm in Enumerator( R ) do
        # Hope that the existing units group gives a good part of the exponent
        # thus hope power is one or an idempotent
        # (In a finite ring every element is a unit, or has a
        # idempotent power, considering zero as idempotent.)
        pow:=elm^expo;
        if pow=one then
          case:=1;
        elif pow in idemp then
          case:=0;
        elif IsUnit(R,pow) then
          case:=1;
          expo:=Lcm(expo,idempo(elm));
        elif pow=pow*pow then
          case:=0;
          AddSet(idemp,pow);
        else
          case:=0;
          expo:=Lcm(expo,idempo(elm));
        fi;

        if case=1 and not elm in units then
          units:= ClosureGroupDefault( units, elm );
        fi;
      od;
    else
      units:=Magma(one);
      for elm in Enumerator(R) do
        if IsUnit( R, elm ) and not elm in units then
          units:= ClosureMagmaDefault( units, elm );
        fi;
      od;
    fi;

    return units;
    end );


#############################################################################
##
#M  StandardAssociate( <r> )
##
InstallOtherMethod( StandardAssociate,
    "for a ring element",
    true,
    [ IsRingElement ],
    r -> StandardAssociate( DefaultRing( [ r ] ), r ) );

InstallMethod( StandardAssociate,
    "for a ring and its zero element",
    IsCollsElms,
    [ IsRing, IsRingElement and IsZero ],
    SUM_FLAGS, # can't do better
    function ( R, r )
    return r;
    end );

InstallMethod( StandardAssociate,
    "for a ring and a ring element (using StandardAssociateUnit)",
    IsCollsElms,
    [ IsRing, IsRingElement ],
    function ( R, r )
      local u;
      u := StandardAssociateUnit( R, r );
      if u <> fail then return u * r; fi;
      TryNextMethod();
    end );


#############################################################################
##
#M  StandardAssociateUnit( <r> )
##
InstallOtherMethod( StandardAssociateUnit,
    "for a ring element",
    true,
    [ IsRingElement ],
    r -> StandardAssociateUnit( DefaultRing( [ r ] ), r ) );

InstallMethod( StandardAssociateUnit,
    "for a ring and its zero element",
    IsCollsElms,
    [ IsRing, IsRingElement and IsZero ],
    SUM_FLAGS, # can't do better
    function ( R, r )
    return One( R );
    end );


#############################################################################
##
#M  Associates( <r> ) . . . . . . . . . . . . .  delegate to the default ring
#M  Associates( <R>, <r> )  . . . . . . . . . .  associates of a ring element
##
InstallOtherMethod( Associates,
    "for a ring element",
    true,
    [ IsRingElement ], 0,
    r -> Associates( DefaultRing( [ r ] ), r ) );

InstallMethod( Associates,
    "for a ring and a ring element",
    IsCollsElms,
    [ IsRing, IsRingElement ], 0,
    function( R, r )
    return AsSSortedList( Enumerator( Units( R ) ) * r );
    end );


#############################################################################
##
#M  IsPrime( <r> )  . . . . . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( IsPrime,
    "for a ring element",
    true,
    [ IsRingElement ], 0,
    r -> IsPrime( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#M  IsIrreducibleRingElement( <r> )   . . . . .  delegate to the default ring
##
InstallOtherMethod( IsIrreducibleRingElement,
    "for a ring element",
    true,
    [ IsRingElement ], 0,
    r -> IsIrreducibleRingElement( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#M  Factors( <r> )  . . . . . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( Factors,
    "for a ring element",
    true, [ IsRingElement ], 0,
    r -> Factors( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#M  EuclideanDegree( <r> )  . . . . . . . . . .  delegate to the default ring
##
InstallOtherMethod( EuclideanDegree,
    "for a ring element",
    true, [ IsRingElement ], 0,
    r -> EuclideanDegree( DefaultRing( [ r ] ), r ) );


#############################################################################
##
#F  EuclideanRemainder( <r>, <m> )  . . . . . .  delegate to the default ring
#F  EuclideanRemainder( <R>, <r>, <m> ) . . . . . . . . . euclidean remainder
##
InstallOtherMethod( EuclideanRemainder,
    "for two ring elements",
    IsIdenticalObj, [ IsRingElement, IsRingElement ], 0,
    function( r, m )
    return EuclideanRemainder( DefaultRing( [ r, m ] ), r, m );
    end );

InstallMethod( EuclideanRemainder,
    "for a Euclidean ring and two ring elements",
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
    "for two ring elements",
    IsIdenticalObj, [ IsRingElement, IsRingElement ], 0,
    function( r, m )
    return EuclideanQuotient( DefaultRing( [ r, m ] ), r, m );
    end );

InstallMethod( EuclideanQuotient,
    "for a Euclidean ring and two ring elements",
    IsCollsElmsElms, [ IsEuclideanRing, IsRingElement, IsRingElement ], 0,
    function( R, r, m )
    return QuotientRemainder( R, r, m )[1];
    end );


#############################################################################
##
#M  QuotientRemainder( <r>, <m> ) . . . . . . .  delegate to the default ring
##
InstallOtherMethod( QuotientRemainder,
    "for two ring elements",
    IsIdenticalObj, [ IsRingElement, IsRingElement ], 0,
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
    "for three ring elements",
    IsFamFamFam,
    [ IsRingElement, IsRingElement, IsRingElement ], 0,
    function( r, s, m )
    return QuotientMod( DefaultRing( [ r, s, m ] ), r, s, m );
    end );

InstallMethod( QuotientMod,
    "for a Euclidean ring and three ring elements",
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
    "for ring element, integer, and ring element",
    true, [ IsRingElement, IsInt, IsRingElement ], 0,
    function( r, e, m )
    return PowerMod( DefaultRing( [ r, m ] ), r, e, m );
    end );

InstallMethod( PowerMod,
    "for Euclidean ring, ring element, integer, and ring element",
    true,
    [ IsEuclideanRing, IsRingElement, IsInt, IsRingElement ], 0,
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
#F  Gcd( <r1>, <r2>, ... )
#F  Gcd( <list> )
#F  Gcd( <R>, <r1>, <r2>, ... )
#F  Gcd( <R>, <list> )
##
InstallGlobalFunction( Gcd, function ( arg )
    local tested, R, ns, i, gcd;

    # get and check the arguments (what a pain)
    tested:= false;
    if Length(arg)=2 and (not IsRing(arg[1])) and
     IsIdenticalObj(FamilyObj(arg[1]),FamilyObj(arg[2]))
      then # quick dispatch for two ring elements. There is a
       # fallback method that still supplies the ring if nothing special
      return GcdOp(arg[1],arg[2]);
    elif   Length(arg) = 0  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := arg{ [2..Length(arg)] };
    else
        R := DefaultRing( arg );
        ns := arg;
        tested:= true;
    fi;
    if not IsList( ns )  or IsEmpty(ns)  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    elif not tested then
        if not IsSubset( R, ns ) then
            Error("<ns> must be a subset of <R>");
        fi;
    fi;
#T We do not want to require `R' to be euclidean,
#T for example multivariate polynomial rings are legal rings here.
#T (Perhaps a weaker test would be appropriate, for example for UFD?)
#T    if not IsEuclideanRing( R )  then
#T        Error("<R> must be a Euclidean ring");
#T    fi;


    # compute the gcd by iterating
    gcd := StandardAssociate(R,ns[1]);
    for i  in [2..Length(ns)]  do
        gcd := GcdOp( R, gcd, ns[i] );
    od;

    # return the gcd
    return gcd;
end );


#############################################################################
##
#M  GcdOp( <r>, <s> ) . . . . . . . . . . . . .  delegate to the default ring
#M  GcdOp( <R>, <r>, <s> )  . . . .  greatest common divisor of ring elements
##
InstallOtherMethod( GcdOp,
    "for two ring elements",
    IsIdenticalObj,
    [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return Gcd( DefaultRing( [ r, s ] ), r, s );
    end );

InstallMethod( GcdOp,
    "for a Euclidean ring and two ring elements",
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
#F  GcdRepresentation( <r1>, <r2>, ... )
#F  GcdRepresentation( <list> )
#F  GcdRepresentation( <R>, <r1>, <r2>, ... )
#F  GcdRepresentation( <R>, <list> )
##
InstallGlobalFunction( GcdRepresentation, function ( arg )
    local   R, ns, i, gcd, rep, tmp;

    # get and check the arguments (what a pain)
    if   Length(arg) = 0  then
        Error("usage: GcdRepresentation( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := arg{ [2..Length(arg)] };
    else
        R := DefaultRing( arg );
        ns := arg;
    fi;
    if not IsList( ns )  or IsEmpty(ns)  then
        Error("usage: GcdRepresentation( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    else
        if not IsSubset( R, ns )  then
            Error("<ns> must be a subset of <R>");
        fi;
    fi;
    if not IsEuclideanRing( R )  then
        Error("<R> must be a Euclidean ring");
    fi;

    # compute the gcd by iterating
    gcd := ns[1];
    rep := [ One( R ) ];
    for i  in [2..Length(ns)]  do
        tmp := GcdRepresentationOp ( R, gcd, ns[i] );
        gcd := tmp[1] * gcd + tmp[2] * ns[i];
        rep := List( rep, x -> x * tmp[1] );
        Add( rep, tmp[2] );
    od;

    # return the gcd representation
    return rep;
end );


#############################################################################
##
#M  GcdRepresentationOp( <r>, <s> ) . . . . . .  delegate to the default ring
#M  GcdRepresentationOp( <R>, <r>, <s> )  . . . . . representation of the gcd
##
InstallOtherMethod( GcdRepresentationOp,
    "for two ring elements",
    IsIdenticalObj, [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return GcdRepresentation( DefaultRing( [ r, s ] ), r, s );
    end );

InstallMethod( GcdRepresentationOp,
    "for a Euclidean ring and two ring elements",
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
    q := StandardAssociateUnit(R, f);
    if y = Zero( R ) then
        return [ q * fx, Zero( R ) ];
    else
        return [ q * fx, Quotient( R, q * (f - fx * x), y ) ];
    fi;
    end );


#############################################################################
##
#F  Lcm( <r1>, <r2>, ... )
#F  Lcm( <list> )
#F  Lcm( <R>, <r1>, <r2>, ... )
#F  Lcm( <R>, <list> )
##
InstallGlobalFunction( Lcm, function ( arg )
    local tested, ns,  R,  lcm,  i;

    # get and check the arguments (what a pain)
    tested:= false;
    if   Length(arg) = 0  then
        Error("usage: Lcm( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := arg{ [2..Length(arg)] };
    else
        R := DefaultRing( arg );
        ns := arg;
        tested:= true;
    fi;
    if not IsList( ns )  or IsEmpty(ns)  then
        Error("usage: Lcm( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    elif not tested then
        if not IsSubset( R, ns ) then
            Error("<ns> must be a subset of <R>");
        fi;
    fi;
#T We do not want to require `R' to be euclidean,
#T for example multivariate polynomial rings are legal rings here.
#T (Perhaps a weaker test would be appropriate, for example for UFD?)
#T    if not IsEuclideanRing( R )  then
#T        Error("<R> must be a Euclidean ring");
#T    fi;

    # compute the least common multiple
    lcm := StandardAssociate(R,ns[1]);
    for i  in [2..Length(ns)]  do
        lcm := LcmOp( R, lcm, ns[i] );
    od;

    # return the lcm
    return lcm;
end );


#############################################################################
##
#M  LcmOp( <r>, <s> ) . . . . . . . . . . . . .  delegate to the default ring
#M  LcmOp( <R>, <r>, <s> )  . . .  least common multiple of two ring elements
##
InstallOtherMethod( LcmOp,
    "for two ring elements",
    IsIdenticalObj,
    [ IsRingElement, IsRingElement ], 0,
    function( r, s )
    return LcmOp( DefaultRing( [ r, s ] ), r, s );
    end );

InstallMethod( LcmOp,
    "for a Euclidean ring and two ring elements",
    IsCollsElmsElms,
    [ IsUniqueFactorizationRing, IsRingElement, IsRingElement ], 0,
    function( R, r, s )

    # compute the least common multiple
    if r = Zero( R ) and s = Zero( R ) then
      return r;
    elif r in R and s in R then
      return StandardAssociate( R, Quotient( R, r, GcdOp( R, r, s ) ) * s );
    else
      Error( "<r> and <s> must lie in <R>" );
    fi;
    end );


#############################################################################
##
#M  \=( <R>, <S> )  . . . . . . . . . . . . . . . test if two rings are equal
##
InstallMethod( \=,
    "for two rings with known generators",
    IsIdenticalObj,
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


# moved here from `integers` to avoid reading order change

#############################################################################
##
#M  GcdOp( Integers, <n>, <m> ) . . . . . . . . . . . . . gcd of two integers
##
InstallRingAgnosticGcdMethod("integers", true,true,
    [ IsIntegers, IsInt, IsInt ], 0,GcdInt);
