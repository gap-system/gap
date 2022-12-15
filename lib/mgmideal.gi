#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for magma ideals
##


#############################################################################
##
#M  PrintObj( <S> )
##  print a [left, right, two-sided] MagmaIdeal
##

##  left

InstallMethod( PrintObj,
    "for a left magma ideal",
    true,
    [ IsLeftMagmaIdeal ], 0,
    function( S )
    Print( "LeftMagmaIdeal( ... )" );
    end );

InstallMethod( PrintObj,
    "for a left magma ideal with known generators",
    true,
    [ IsLeftMagmaIdeal and HasGeneratorsOfLeftMagmaIdeal ], 0,
    function( S )
    Print( "LeftMagmaIdeal( ", GeneratorsOfLeftMagmaIdeal( S ), " )" );
    end );

##  right

InstallMethod( PrintObj,
    "for a right magma ideal",
    true,
    [ IsRightMagmaIdeal ], 0,
    function( S )
    Print( "RightMagmaIdeal( ... )" );
    end );

InstallMethod( PrintObj,
    "for a right magma ideal with known generators",
    true,
    [ IsRightMagmaIdeal and HasGeneratorsOfRightMagmaIdeal ], 0,
    function( S )
    Print( "RightMagmaIdeal( ", GeneratorsOfRightMagmaIdeal( S ), " )" );
    end );


##  two sided

InstallMethod( PrintObj,
    "for a magma ideal",
    true,
    [ IsMagmaIdeal ], 0,
    function( S )
    Print( "MagmaIdeal( ... )" );
    end );

InstallMethod( PrintObj,
    "for a magma ideal with known generators",
    true,
    [ IsMagmaIdeal and HasGeneratorsOfMagmaIdeal ], 0,
    function( S )
    Print( "MagmaIdeal( ", GeneratorsOfMagmaIdeal( S ), " )" );
    end );

#############################################################################
##
#M  ViewObj( <S> )
##  view a [left,right,two-sided] magma ideal
##

##  left

InstallMethod( ViewObj,
    "for a LeftMagmaIdeal",
    true,
    [ IsLeftMagmaIdeal ], 0,
    function( S )
    Print( "<LeftMagmaIdeal>" );
    end );

InstallMethod( ViewObj,
    "for a LeftMagmaIdeal with generators",
    true,
    [ IsLeftMagmaIdeal and HasGeneratorsOfLeftMagmaIdeal ], 0,
    function( S )
    Print( "<LeftMagmaIdeal with ",
           Pluralize( Length( GeneratorsOfLeftMagmaIdeal( S ) ), "generator" ),
           ">" );
    end );

##  right


InstallMethod( ViewObj,
    "for a RightMagmaIdeal",
    true,
    [ IsRightMagmaIdeal ], 0,
    function( S )
    Print( "<RightMagmaIdeal>" );
    end );

InstallMethod( ViewObj,
    "for a RightMagmaIdeal with generators",
    true,
    [ IsRightMagmaIdeal and HasGeneratorsOfRightMagmaIdeal ], 0,
    function( S )
    Print( "<RightMagmaIdeal with ",
           Pluralize( Length( GeneratorsOfRightMagmaIdeal( S ) ), "generator" ),
           ">" );
    end );


## two sided

InstallMethod( ViewObj,
    "for a MagmaIdeal",
    true,
    [ IsMagmaIdeal ], 0,
    function( S )
    Print( "<MagmaIdeal>" );
    end );

InstallMethod( ViewObj,
    "for a MagmaIdeal with generators",
    true,
    [ IsMagmaIdeal and HasGeneratorsOfMagmaIdeal ], 0,
    function( S )
    Print( "<MagmaIdeal with ",
           Pluralize( Length( GeneratorsOfMagmaIdeal( S ) ), "generator" ),
           ">" );
    end );



#############################################################################
##
#M  LeftMagmaIdealByGenerators( <D>, <gens> )
#M  RightMagmaIdealByGenerators( <D>, <gens> )
#M  MagmaIdealByGenerators( <D>, <gens> )
##
##  ASSUMES that <gens> are a subset of <D>
##
InstallMethod( LeftMagmaIdealByGenerators,
    "for a collection of magma elements",
    IsIdenticalObj,
    [ IsMagma, IsCollection ], 0,
    function( M, gens )
    local S;

    S:= Objectify( NewType( FamilyObj( gens ),
                            IsLeftMagmaIdeal and IsAttributeStoringRep ),
                   rec() );

    SetGeneratorsOfLeftMagmaIdeal( S, AsList( gens ) );
    SetParent(S, M);
    SetLeftActingDomain(S, M);

    if HasGeneratorsOfGroup(M) then
        # Because any ideal of a group the whole group, we should set the
        # generators.
        SetGeneratorsOfGroup(S, GeneratorsOfGroup(M));
    fi;

    return S;
end );

InstallMethod( RightMagmaIdealByGenerators,
    "for a collection of magma elements",
    IsIdenticalObj,
    [ IsMagma, IsCollection ], 0,
    function( M, gens )
    local S;

    S:= Objectify( NewType( FamilyObj( gens ),
                            IsRightMagmaIdeal and IsAttributeStoringRep ),
                   rec() );

    SetGeneratorsOfRightMagmaIdeal( S, AsList( gens ) );
    SetParent(S, M);
    SetRightActingDomain(S, M);

    if HasGeneratorsOfGroup(M) then
        # Because any ideal of a group is the whole group, we should set the
        # generators.
        SetGeneratorsOfGroup(S, GeneratorsOfGroup(M));
    fi;


    return S;
end );


InstallMethod( MagmaIdealByGenerators,
    "for a collection of magma elements",
    IsIdenticalObj,
    [ IsMagma, IsCollection ], 0,
    function( M, gens )
    local S;

    S:= Objectify( NewType( FamilyObj( gens ),
                            IsMagmaIdeal and IsAttributeStoringRep ),
                   rec() );

    SetGeneratorsOfMagmaIdeal( S, AsList( gens ) );
    SetParent(S, M);
    SetActingDomain(S, M);

    if HasGeneratorsOfGroup(M) then
        # Because any ideal of a group is the whole group, we should set the
        # generators.
        SetGeneratorsOfGroup(S, GeneratorsOfGroup(M));
    fi;


    return S;
end );

#############################################################################
##
#F  LeftMagmaIdeal( <gen>, ... )
#F  RightMagmaIdeal( <gens> )
#F  MagmaIdeal( <gens> )
##
##  Unimplemented
##
# InstallGlobalFunction( LeftMagmaIdeal, function( arg )
# InstallGlobalFunction( RightMagmaIdeal, function( arg )
# InstallGlobalFunction( MagmaIdeal, function( arg )

#############################################################################
##
#M  AsLeftMagmaIdeal( <D>, <C> )
##
##  Regard the list <C> of elements as a left ideal of <D>.
##  It is not checked, but assumed, that <C> are all the elements
##  of the ideal and that <C> is a subset of <D>.
##
InstallMethod( AsLeftMagmaIdeal,
    "generic method for a domain and a collection",
    IsIdenticalObj,
    [ IsDomain, IsCollection ], 0,

function( D, C )
    local S;

    S:= LeftMagmaIdealByGenerators( D, AsList(C));
    UseIsomorphismRelation( C, S );
    UseSubsetRelation( C, S );
    return S;
end );

#############################################################################
##
#M  Enumerator( <I> ) . . . . . . . . . . . .  elements of a magma ideal
##
BindGlobal( "EnumeratorOfMagmaIdeal", function( I )

    local   gens,       # magma generators of <I>
            H,          # submagma
            gen,        # generator of <I>
            x,y,        # elements of parent
            M;          # parent

    # handle the case of an empty magma
    gens:= GeneratorsOfMagmaIdeal( I );
    if IsEmpty( gens ) then
      return [];
    fi;

    M := Parent(I); # the magma whose ideal it is

    # start with the empty magma and its element generators list
    H:= Submagma( M, [] );
    SetAsSSortedList( H, Immutable( [ ] ) );

    # Add the generators one after the other.
    # We use a function that maintains the elements list for the closure.
    for gen in gens do
        for x in AsSSortedList(M) do
            for y in AsSSortedList(M) do
                H:= ClosureMagmaDefault( H, x*gen*y );
            od;
        od;
    od;

    # return the list of elements
    Assert( 2, HasAsSSortedList( H ) );
    return AsSSortedList( H );
end );

InstallMethod( Enumerator,
    "generic method for a magma ideal",
    true,
    [ IsMagma and IsAttributeStoringRep and IsMagmaIdeal ], 0,
    EnumeratorOfMagmaIdeal );




#############################################################################
##
#M  AsSSortedList( <R> )  - for a right magma ideal
#M  AsSSortedList( <L> )  - for a left magma ideal
##
##  Lazy methods for listing the elements of a left/right magma ideal
##  assuming the object is finite. Should write enumerators some time...
##
InstallMethod( AsSSortedList,
  "for a right magma ideal", true,
  [IsRightMagmaIdeal and HasGeneratorsOfRightMagmaIdeal],0,
function(I)
  local
    g,    # a generator of the ideal
    x,    # an element of the parent
    plist, # elements of the parent
    genlist, # right ideal generators
    idealelts; # elements of the ideal

  plist := AsSet(Parent(I));
  genlist := AsSet(GeneratorsOfRightMagmaIdeal(I));

  idealelts := ShallowCopy(genlist);

  for g in genlist do
    for x in plist do
      AddSet(idealelts, g*x);
    od;
  od;

  return idealelts;
end);


InstallMethod( AsSSortedList,
  "for a left magma ideal", true,
  [IsLeftMagmaIdeal and HasGeneratorsOfLeftMagmaIdeal],0,
function(I)
  local
    g,    # a generator of the ideal
    x,    # an element of the parent
    plist, # elements of the parent
    genlist, # left ideal generators
    idealelts; # elements of the ideal

  plist := AsSet(Parent(I));
  genlist := AsSet(GeneratorsOfLeftMagmaIdeal(I));

  idealelts := ShallowCopy(genlist);

  for g in genlist do
    for x in plist do
      AddSet(idealelts, x*g);
    od;
  od;

  return idealelts;
end);
