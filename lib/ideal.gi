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
##


#############################################################################
##
#F  TwoSidedIdeal( <R>, <gens> )
#F  TwoSidedIdeal( <R>, <gens>, "basis" )
##
InstallGlobalFunction( TwoSidedIdeal, function( arg )
    local I;
    if    Length( arg ) <= 1
       or not IsRing( arg[1] )
       or not IsHomogeneousList( arg[2] ) then
      Error( "first argument must be a ring,\n",
             "second argument must be a list of generators" );

    elif IsEmpty( arg[2] ) then

      return TwoSidedIdealNC( arg[1], arg[2] );

    elif     IsIdenticalObj( FamilyObj( arg[1] ),
                          FamilyObj( arg[2] ) )
         and ForAll( arg[2], v -> v in arg[1] ) then

      I:= IdealByGenerators( arg[1], arg[2] );
      if Length( arg ) = 3 and arg[3] = "basis" then
        UseBasis( I, arg[2] );
      fi;
      UseSubsetRelation( arg[1], I );
      return I;

    fi;
    Error( "usage: TwoSidedIdeal( <R>, <gens> [, \"basis\"] )" );
end );


#############################################################################
##
#F  TwoSidedIdealNC( <R>, <gens>, "basis" )
#F  TwoSidedIdealNC( <R>, <gens> )
##
InstallGlobalFunction( TwoSidedIdealNC, function( arg )
    local I;
    if IsEmpty( arg[2] ) then

      # If <R> is a FLMLOR then also the ideal is a FLMLOR.
      if IsFLMLOR( arg[1] ) then
        I:= SubFLMLORNC( arg[1], arg[2] );
      else
        I:= Objectify( NewType( FamilyObj( arg[1] ),
                                    IsRing
                                and IsTrivial
                                and IsAttributeStoringRep ),
                       rec() );
      fi;
      SetGeneratorsOfRing( I, AsList( arg[2] ) );
      SetLeftActingRingOfIdeal( I, arg[1] );
      SetRightActingRingOfIdeal( I, arg[1] );

    else

      I:= TwoSidedIdealByGenerators( arg[1], arg[2] );

    fi;
    if Length( arg ) = 3 and arg[3] = "basis" then
      UseBasis( I, arg[2] );
    fi;
    UseSubsetRelation( arg[1], I );
    return I;
end );


#############################################################################
##
#F  LeftIdeal( <R>, <gens> )
#F  LeftIdeal( <R>, <gens>, "basis" )
##
InstallGlobalFunction( LeftIdeal, function( arg )
    local I;
    if    Length( arg ) <= 1
       or not IsRing( arg[1] )
       or not IsHomogeneousList( arg[2] ) then
      Error( "first argument must be a ring,\n",
             "second argument must be a list of generators" );

    elif IsEmpty( arg[2] ) then

      return TwoSidedIdealNC( arg[1], arg[2] );

    elif     IsIdenticalObj( FamilyObj( arg[1] ),
                          FamilyObj( arg[2] ) )
         and ForAll( arg[2], v -> v in arg[1] ) then

      I:= LeftIdealByGenerators( arg[1], arg[2] );
      if Length( arg ) = 3 and arg[3] = "basis" then
        UseBasis( I, arg[2] );
      fi;
      UseSubsetRelation( arg[1], I );
      return I;

    fi;
    Error( "usage: LeftIdeal( <R>, <gens> [, \"basis\"] )" );
end );


#############################################################################
##
#F  LeftIdealNC( <R>, <gens>, "basis" )
#F  LeftIdealNC( <R>, <gens> )
##
InstallGlobalFunction( LeftIdealNC, function( arg )
    local I;
    if IsEmpty( arg[2] ) then
      return TwoSidedIdealNC( arg[1], arg[2] );
    fi;

    I:= LeftIdealByGenerators( arg[1], arg[2] );
    if Length( arg ) = 3 and arg[3] = "basis" then
      UseBasis( I, arg[2] );
    fi;
    UseSubsetRelation( arg[1], I );

    return I;
end );


#############################################################################
##
#F  RightIdeal( <R>, <gens> )
#F  RightIdeal( <R>, <gens>, "basis" )
##
InstallGlobalFunction( RightIdeal, function( arg )
    local I;
    if    Length( arg ) <= 1
       or not IsRing( arg[1] )
       or not IsHomogeneousList( arg[2] ) then
      Error( "first argument must be a ring,\n",
             "second argument must be a list of generators" );

    elif IsEmpty( arg[2] ) then

      return TwoSidedIdealNC( arg[1], arg[2] );

    elif     IsIdenticalObj( FamilyObj( arg[1] ),
                          FamilyObj( arg[2] ) )
         and ForAll( arg[2], v -> v in arg[1] ) then

      I:= RightIdealByGenerators( arg[1], arg[2] );
      if Length( arg ) = 3 and arg[3] = "basis" then
        UseBasis( I, arg[2] );
      fi;
      UseSubsetRelation( arg[1], I );
      return I;

    fi;
    Error( "usage: RightIdeal( <R>, <gens> [, \"basis\"] )" );
end );


#############################################################################
##
#F  RightIdealNC( <R>, <gens>, "basis" )
#F  RightIdealNC( <R>, <gens> )
##
InstallGlobalFunction( RightIdealNC, function( arg )
    local I;
    if IsEmpty( arg[2] ) then
      return TwoSidedIdealNC( arg[1], arg[2] );
    fi;

    I:= RightIdealByGenerators( arg[1], arg[2] );
    if Length( arg ) = 3 and arg[3] = "basis" then
      UseBasis( I, arg[2] );
    fi;
    UseSubsetRelation( arg[1], I );

    return I;
end );


#############################################################################
##
#M  TwoSidedIdealByGenerators( <R>, <gens> ) . . .  create an ideal in a ring
##
InstallMethod( TwoSidedIdealByGenerators,
    "for ring and collection",
    IsIdenticalObj,
    [ IsRing, IsCollection ], 0,
    function( R, gens )
    local I;
    I:= Objectify( NewType( FamilyObj( R ),
                                IsRing
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfTwoSidedIdeal( I, gens );
    SetLeftActingRingOfIdeal( I, R );
    SetRightActingRingOfIdeal( I, R );
    return I;
    end );


#############################################################################
##
#M  LeftIdealByGenerators( <R>, <gens> ) . . .  create a left ideal in a ring
##
InstallMethod( LeftIdealByGenerators,
    "for ring and collection",
    IsIdenticalObj,
    [ IsRing, IsCollection ], 0,
    function( R, gens )
    local I;
    I:= Objectify( NewType( FamilyObj( R ),
                                IsRing
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfLeftIdeal( I, gens );
    SetLeftActingRingOfIdeal( I, R );
    return I;
    end );


#############################################################################
##
#M  RightIdealByGenerators( <R>, <gens> ) . .  create a right ideal in a ring
##
InstallMethod( RightIdealByGenerators,
    "for ring and collection",
    IsIdenticalObj,
    [ IsRing, IsCollection ], 0,
    function( R, gens )
    local I;
    I:= Objectify( NewType( FamilyObj( R ),
                                IsRing
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfRightIdeal( I, gens );
    SetRightActingRingOfIdeal( I, R );
    return I;
    end );


#############################################################################
##
#M  LeftIdealByGenerators(  <R>, <gens> )  . . . . . .  for commutative rings
#M  RightIdealByGenerators( <R>, <gens> )  . . . . . .  for commutative rings
##
##  If R is a commutative ring, then we create a two-sided ideal in a ring R
##  instead of its left or right ideal
##
InstallMethod( LeftIdealByGenerators,
    "to construct ideals of commutative rings",
    true,
    [ IsFLMLOR and IsCommutative, IsCollection ],
    0,
    function( R, gens )
    return TwoSidedIdealByGenerators( R, gens );
    end );

InstallMethod( RightIdealByGenerators,
    "to construct ideals of commutative rings",
    true,
    [ IsFLMLOR and IsCommutative, IsCollection ],
    0,
    function( R, gens )
    return TwoSidedIdealByGenerators( R, gens );
    end );


#############################################################################
##
#M  IsIdealInParent(<I>)  . for left resp. right ideals in a commutative ring
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
#M  PrintObj( <I> ) . . . . . . . . . . . . . . . . . . . . . .  for an ideal
##
InstallMethod( PrintObj,
    "for a left ideal with known generators",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasGeneratorsOfLeftIdeal ],
    0,
    function( I )
    Print( "LeftIdeal( ", LeftActingRingOfIdeal( I ), ", ",
           GeneratorsOfLeftIdeal( I ), " )" );
    end );

InstallMethod( PrintObj,
    "for a right ideal with known generators",
    true,
    [ IsRing and HasRightActingRingOfIdeal and HasGeneratorsOfRightIdeal ],
    0,
    function( I )
    Print( "RightIdeal( ", RightActingRingOfIdeal( I ), ", ",
           GeneratorsOfRightIdeal( I ), " )" );
    end );

InstallMethod( PrintObj,
    "for a two-sided ideal with known generators",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal
             and HasGeneratorsOfTwoSidedIdeal ],
    0,
    function( I )
    Print( "TwoSidedIdeal( ", RightActingRingOfIdeal( I ), ", ",
           GeneratorsOfTwoSidedIdeal( I ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <I> )  . . . . . . . . . . . . . . . . . . . . . .  for an ideal
##
InstallMethod( ViewObj,
    "for a left ideal with known generators",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasGeneratorsOfLeftIdeal ],
    100,  # stronger than methods for the different kinds of algebras
    function( I )
    Print( "\>\><left ideal in \>\>" );
    View( LeftActingRingOfIdeal( I ) );
    if HasDimension( I ) then
      Print( "\<,\< \>\>(dimension ", Dimension( I ), "\<\<\<\<)>" );
    else
      Print( "\<,\< \>\>(",
             Pluralize( Length( GeneratorsOfLeftIdeal( I ) ), "generator" ),
             ")\<\<\<\<>" );
    fi;
    end );

InstallMethod( ViewObj,
    "for a right ideal with known generators",
    true,
    [ IsRing and HasRightActingRingOfIdeal and HasGeneratorsOfRightIdeal ],
    100,  # stronger than methods for the different kinds of algebras
    function( I )
    Print( "\>\><right ideal in \>\>" );
    View( RightActingRingOfIdeal( I ) );
    if HasDimension( I ) then
      Print( "\<,\< \>\>(dimension ", Dimension( I ), "\<\<\<\<)>" );
    else
      Print( "\<,\< \>\>(",
             Pluralize( Length( GeneratorsOfRightIdeal( I ) ), "generator" ),
             ")\<\<\<\<>" );
    fi;
    end );

InstallMethod( ViewObj,
    "for a two-sided ideal with known generators",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal
             and HasGeneratorsOfTwoSidedIdeal ],
    100,  # stronger than methods for the different kinds of algebras
    function( I )
    Print( "\>\><two-sided ideal in \>\>" );
    View( RightActingRingOfIdeal( I ) );
    if HasDimension( I ) then
      Print( "\<,\< \>\>(dimension ", Dimension( I ), "\<\<\<\<)>" );
    else
      Print( "\<,\< \>\>(",
             Pluralize( Length( GeneratorsOfTwoSidedIdeal( I ) ), "generator" ),
             ")\<\<\<\<>" );
    fi;
    end );


#############################################################################
##
#M  Representative( <I> ) . . . . one element of a left/right/two sided ideal
##
InstallMethod( Representative,
    "for left ideal with known generators",
    [ IsRing and HasGeneratorsOfLeftIdeal ],
    RepresentativeFromGenerators( GeneratorsOfLeftIdeal ) );

InstallMethod( Representative,
    "for right ideal with known generators",
    [ IsRing and HasGeneratorsOfRightIdeal ],
    RepresentativeFromGenerators( GeneratorsOfRightIdeal ) );

InstallMethod( Representative,
    "for two-sided ideal with known generators",
    [ IsRing and HasGeneratorsOfTwoSidedIdeal ],
    RepresentativeFromGenerators( GeneratorsOfTwoSidedIdeal ) );


#############################################################################
##
#M  Zero( <I> ) . . . . . . . . . . . . . . . . . . . . . . . .  for an ideal
##
InstallOtherMethod( Zero,
    "for a left ideal",
    true,
    [ IsRing and HasLeftActingRingOfIdeal ], 0,
    I -> Zero( LeftActingRingOfIdeal( I ) ) );


InstallOtherMethod( Zero,
    "for a right ideal",
    true,
    [ IsRing and HasRightActingRingOfIdeal ], 0,
    I -> Zero( RightActingRingOfIdeal( I ) ) );


#############################################################################
##
#M  Enumerator( <I> ) . . . . . . . . . . . . . . . . . . . . .  for an ideal
##
BindGlobal( "EnumeratorOfIdeal", function( I )

    local   left,       # we must multiply with ring elements from the left
            right,      # we must multiply with ring elements from the right
            elms,       # elements of <I>, result
            set,        # set corresponding to <elms>
            Igens,      # ideal generators of <I>
            R,          # the acting ring
            Rgens,      # ring generators of `R'
            elmsgens,   # additive generators
            elm,        # one element of <elms>
            gen,        # one generator of <I>
            new;        # product or sum of <elm> and <gen>

    # check that we can handle this ideal
    if HasIsFinite( I ) and not IsFinite( I ) then
        TryNextMethod();
    fi;

    # Check from what sides we must multiply with ring elements.
    if   HasGeneratorsOfLeftIdeal( I ) then
      Igens := GeneratorsOfLeftIdeal( I );
      R     := LeftActingRingOfIdeal( I );
      left  := true;
      right := false;
    elif HasGeneratorsOfRightIdeal( I ) then
      Igens := GeneratorsOfRightIdeal( I );
      R     := RightActingRingOfIdeal( I );
      left  := false;
      right := true;
    elif HasGeneratorsOfTwoSidedIdeal( I ) then
      Igens := GeneratorsOfTwoSidedIdeal( I );
      R     := LeftActingRingOfIdeal( I );
      left  := true;
      right := true;
    else
      TryNextMethod();
    fi;


    # the elements of the ideal are sums of elements of the form r*g*s where
    # g is an ideal generator and r and s are ring elements. Therefore
    # *first* compute the ring multiples of the generators and then form the
    # additive closure.
    elms := Set(ShallowCopy(Igens));
    set  := ShallowCopy( elms );

    # Compute the closure under the action of the acting ring
    # from the left and from the right.
    # If this ring is associative then it is sufficient to multiply
    # with generators, otherwise we act with all elements.
    if HasIsAssociative( R ) and IsAssociative( R ) then
      Rgens:= GeneratorsOfRing( R );
    else
      Rgens:= Enumerator( R );
    fi;
    for elm  in elms  do
        for gen  in Rgens  do
            if left then
              new := gen * elm;
              if not new in set  then
                  Add( elms, new );
                  AddSet( set, new );
              fi;
            fi;
            if right then
              new := elm * gen;
              if not new in set  then
                  Add( elms, new );
                  AddSet( set, new );
              fi;
            fi;
        od;
    od;

    elms := set;
    elmsgens:=ShallowCopy(elms);
    set  := ShallowCopy( elms );

    # Use an orbit like algorithm.
    # Compute the additive closure of elms
    for elm  in elms  do
        for gen  in elmsgens  do
            new := elm + gen;
            if not new in set  then
                Add( elms, new );
                AddSet( set, new );
            fi;
        od;
    od;

    return set;
end );

InstallMethod( Enumerator,
    "generic method for a left ideal with known generators",
    true,
    [ IsRing and HasGeneratorsOfLeftIdeal ], 0,
    EnumeratorOfIdeal );

InstallMethod( Enumerator,
    "generic method for a right ideal with known generators",
    true,
    [ IsRing and HasGeneratorsOfRightIdeal ], 0,
    EnumeratorOfIdeal );

InstallMethod( Enumerator,
    "generic method for a two-sided ideal with known generators",
    true,
    [ IsRing and HasGeneratorsOfIdeal ], 0,
    EnumeratorOfIdeal );



#############################################################################
##
#M  GeneratorsOfRing( <I> ) . . . . . . . . . . . . . . . . . .  for an ideal
##
BindGlobal( "GeneratorsOfRingForIdeal", function( I )

    local   left,       # we must multiply with ring elements from the left
            right,      # we must multiply with ring elements from the right
            Igens,      # ideal generators of <I>
            R,          # the acting ring
            Rgens,      # ring generators of `R'
            gens,       # generators list, result
            S,          # subring generated by `gens'
            s, r,       # loop over lists
            prod;       # product of `s' and `r'

    # check that we can handle this ideal
    if HasIsFinite( I ) and not IsFinite( I ) then
        TryNextMethod();
    fi;

    # Check from what sides we must multiply with elements
    # of the acting ring.
    if   HasGeneratorsOfLeftIdeal( I ) then
      Igens := GeneratorsOfLeftIdeal( I );
      R     := LeftActingRingOfIdeal( I );
      left  := true;
      right := false;
    elif HasGeneratorsOfRightIdeal( I ) then
      Igens := GeneratorsOfRightIdeal( I );
      R     := RightActingRingOfIdeal( I );
      left  := false;
      right := true;
    elif HasGeneratorsOfTwoSidedIdeal( I ) then
      Igens := GeneratorsOfTwoSidedIdeal( I );
      R     := LeftActingRingOfIdeal( I );
      left  := true;
      right := true;
    else
      Error( "no ideal generators of <I> known" );
    fi;

    # Handle the case of trivial ideals.
    if IsEmpty( Igens ) then
      return [];
    fi;

    # Start with the ring generated by the ideal generators,
    # and close it until it becomes stable.
    S     := SubringNC( R, Igens );
    gens  := ShallowCopy( Igens );
    Rgens := GeneratorsOfRing( R );
    for s in gens do
      for r in Rgens do
        if left then
          prod:= r * s;
          if not prod in S then
            S:= ClosureRing( S, prod );
            Add( gens, prod );
          fi;
        fi;
        if right then
          prod:= s * r;
          if not prod in S then
            S:= ClosureRing( S, prod );
            Add( gens, prod );
          fi;
        fi;
      od;
    od;

    return gens;
end );


InstallMethod( GeneratorsOfRing,
    "generic method for a left ideal with known generators",
    true,
    [ IsRing and HasGeneratorsOfLeftIdeal ], 0,
    GeneratorsOfRingForIdeal );

InstallMethod( GeneratorsOfRing,
    "generic method for a right ideal with known generators",
    true,
    [ IsRing and HasGeneratorsOfRightIdeal ], 0,
    GeneratorsOfRingForIdeal );

InstallMethod( GeneratorsOfRing,
    "generic method for a two-sided ideal with known generators",
    true,
    [ IsRing and HasGeneratorsOfTwoSidedIdeal ], 0,
    GeneratorsOfRingForIdeal );


#############################################################################
##
#M  GeneratorsOfTwoSidedIdeal( <I> )  . . .  for known left/right ideal gens.
#M  GeneratorsOfLeftIdeal( <I> )  . . . . . . for known two-sided ideal gens.
#M  GeneratorsOfRightIdeal( <I> ) . . . . . . for known two-sided ideal gens.
##
InstallMethod( GeneratorsOfTwoSidedIdeal,
    "for a two-sided ideal with known `GeneratorsOfLeftIdeal'",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal
             and HasGeneratorsOfLeftIdeal ], 0,
    GeneratorsOfLeftIdeal );

InstallMethod( GeneratorsOfTwoSidedIdeal,
    "for a two-sided ideal with known `GeneratorsOfRightIdeal'",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal
             and HasGeneratorsOfRightIdeal ], 0,
    GeneratorsOfRightIdeal );

InstallMethod( GeneratorsOfLeftIdeal,
    "for an ideal with known `GeneratorsOfTwoSidedIdeal'",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal
             and HasGeneratorsOfTwoSidedIdeal ], 0,
    GeneratorsOfRing );

InstallMethod( GeneratorsOfRightIdeal,
    "for an ideal with known `GeneratorsOfTwoSidedIdeal'",
    true,
    [ IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal
             and HasGeneratorsOfTwoSidedIdeal ], 0,
    GeneratorsOfRing );


#############################################################################
##
#M  \+( <I1>, <I2> )  . . . . . . . . . . . . . . . . . . . sum of two ideals
##
InstallMethod( \+,
    "method for two left ideals",
    IsIdenticalObj,
    [ IsRing and HasLeftActingRingOfIdeal,
      IsRing and HasLeftActingRingOfIdeal ], 0,
    function( I1, I2 )
    if LeftActingRingOfIdeal( I1 ) <> LeftActingRingOfIdeal( I2 ) then
      TryNextMethod();
    else
      return LeftIdealByGenerators( LeftActingRingOfIdeal( I1 ),
                 Concatenation( GeneratorsOfLeftIdeal( I1 ),
                                GeneratorsOfLeftIdeal( I2 ) ) );
    fi;
    end );

InstallMethod( \+,
    "method for two right ideals",
    IsIdenticalObj,
    [ IsRing and HasRightActingRingOfIdeal,
      IsRing and HasRightActingRingOfIdeal ], 0,
    function( I1, I2 )
    if RightActingRingOfIdeal( I1 ) <> RightActingRingOfIdeal( I2 ) then
      TryNextMethod();
    else
      return RightIdealByGenerators( RightActingRingOfIdeal( I1 ),
                 Concatenation( GeneratorsOfRightIdeal( I1 ),
                                GeneratorsOfRightIdeal( I2 ) ) );
    fi;
    end );

InstallMethod( \+,
    "method for two two-sided ideals",
    IsIdenticalObj,
    [ IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal,
      IsRing and HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal ], 0,
    function( I1, I2 )
    if RightActingRingOfIdeal( I1 ) <> RightActingRingOfIdeal( I2 ) then
      TryNextMethod();
    else
      return TwoSidedIdealByGenerators( RightActingRingOfIdeal( I1 ),
                 Concatenation( GeneratorsOfTwoSidedIdeal( I1 ),
                                GeneratorsOfTwoSidedIdeal( I2 ) ) );
    fi;
    end );


#############################################################################
##
#M  \*( <r>, <R> )  . . . . . . . . . . . . . . . . . construct a right ideal
#M  \*( <R>, <r> )  . . . . . . . . . . . . . . . . .  construct a left ideal
##
##  If <r> is an element in <R> then the result is the right or left ideal in
##  <R> spanned by <r>.
##  If <r> is not contained in <R> then the product is in general not closed
##  under multiplication, and the default is to return the strictly sorted
##  (note that the result shall be regarded as equal to the result of a
##  method that returns a domain object) list of elements.
##  (If <R> is trivial then the result is also trivial.)
##
InstallMethod( \*,
    "for ring element and ring (construct a right ideal)",
    IsElmsColls,
    [ IsRingElement, IsRing ], 0,
    function( r, R )
    local z;
    if r in R then
      return RightIdealByGenerators( R, [ r ] );
    fi;
    if IsTrivial( R ) then
      z:= Zero( R );
      if r * z = z then
        return R;
      else
        return [ r * z ];
      fi;
    elif IsFinite( R ) then
      return Set( Enumerator( R ), elm -> r * elm );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \*,
    "for ring and ring element (construct a left ideal)",
    IsCollsElms,
    [ IsRing, IsRingElement ], 0,
    function( R, r )
    local z;
    if r in R then
      return LeftIdealByGenerators( R, [ r ] );
    fi;
    if IsTrivial( R ) then
      z:= Zero( R );
      if z * r = z then
        return R;
      else
        return [ z * r ];
      fi;
    elif IsFinite( R ) then
      return Set( Enumerator( R ), elm -> elm * r );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \*( <I>, <R> )  . . . . . . . . . . . . . . . construct a two-sided ideal
#M  \*( <R>, <I> )  . . . . . . . . . . . . . . . construct a two-sided ideal
##
InstallMethod( \*,
    "for left ideal and ring (construct a two-sided ideal)",
    IsIdenticalObj,
    [ IsRing and HasLeftActingRingOfIdeal, IsRing ], 0,
    function( I, R )
    if HasRightActingRingOfIdeal( I ) then
      if IsSubset( RightActingRingOfIdeal( I ), R ) and One(R) <> fail then
        return I;
      fi;
    elif LeftActingRingOfIdeal( I ) = R then
      return TwoSidedIdealByGenerators( R, GeneratorsOfLeftIdeal( I ) );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \*,
    "for ring and right ideal (construct a two-sided ideal)",
    IsCollsElms,
    [ IsRing, IsRing and HasRightActingRingOfIdeal ], 0,
    function( R, I )
    if HasLeftActingRingOfIdeal( I ) then
      if IsSubset( LeftActingRingOfIdeal( I ), R ) and One(R) <> fail then
        return I;
      fi;
    elif RightActingRingOfIdeal( I ) = R then
      return TwoSidedIdealByGenerators( R, GeneratorsOfRightIdeal( I ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  AsLeftIdeal( <R>, <S> ) . . . . . . . . . . . . . . . . . . for two rings
#M  AsRightIdeal( <R>, <S> )  . . . . . . . . . . . . . . . . . for two rings
#M  AsTwoSidedIdeal( <R>, <S> ) . . . . . . . . . . . . . . . . for two rings
##
InstallMethod( AsLeftIdeal,
    "for two rings",
    IsIdenticalObj,
    [ IsRing, IsRing ], 0,
    function( R, S )
    local I, gens;
    if not IsLeftIdeal( R, S ) then
      I:= fail;
    else
      gens:= GeneratorsOfRing( S );
      I:= LeftIdealByGenerators( R, gens );
      SetGeneratorsOfRing( I, gens );
    fi;
    return I;
    end );

InstallMethod( AsRightIdeal,
    "for two rings",
    IsIdenticalObj,
    [ IsRing, IsRing ], 0,
    function( R, S )
    local I, gens;
    if not IsRightIdeal( R, S ) then
      I:= fail;
    else
      gens:= GeneratorsOfRing( S );
      I:= RightIdealByGenerators( R, gens );
      SetGeneratorsOfRing( I, gens );
    fi;
    return I;
    end );

InstallMethod( AsTwoSidedIdeal,
    "for two rings",
    IsIdenticalObj,
    [ IsRing, IsRing ], 0,
    function( R, S )
    local I, gens;
    if not IsTwoSidedIdeal( R, S ) then
      I:= fail;
    else
      gens:= GeneratorsOfRing( S );
      I:= TwoSidedIdealByGenerators( R, gens );
      SetGeneratorsOfRing( I, gens );
    fi;
    return I;
    end );

InstallMethod(IsSubset,"2-sided ideal in ring, naive",IsIdenticalObj,
  [IsRing,IsRing and HasRightActingRingOfIdeal and HasLeftActingRingOfIdeal],
  2*SIZE_FLAGS(FLAGS_FILTER(IsFLMLOR)),
function(R,I)
  if IsIdenticalObj(R,RightActingRingOfIdeal(I)) and
     IsIdenticalObj(R,LeftActingRingOfIdeal(I)) then
     return IsSubset(R,GeneratorsOfTwoSidedIdeal(I));
   fi;
   TryNextMethod();
end);

InstallMethod(IsLeftIdeal,"left ideal in ring, naive",IsIdenticalObj,
  [IsRing,IsRing and HasLeftActingRingOfIdeal],
  2*SIZE_FLAGS(FLAGS_FILTER(IsFLMLOR)),
function(R,I)
  if IsIdenticalObj(LeftActingRingOfIdeal(I),R) then
    return true;
  else
    TryNextMethod();
  fi;
end);
