#############################################################################
##
#W  basic.gd                    GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for the construction of the basic group
##  types.
##
Revision.basic_gd :=
    "@(#)$Id$";


#############################################################################
##

#O  AbelianGroupCons( <filter>, <ints> )
##
AbelianGroupCons := NewConstructor(
    "AbelianGroupCons",
    [ IsGroup, IsList ] );


#############################################################################
##
#F  AbelianGroup( <ints> )  . . . . . . . . . . . . . . . . . . abelian group
##
AbelianGroup := function ( arg )

    if Length(arg) = 1  then
        return AbelianGroupCons( IsPcGroup, arg[1] );

    elif Length(arg) = 2  then
        return AbelianGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
        return AbelianGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: AbelianGroupCons( <ints> )" );
    fi;

end;


#############################################################################
##

#O  AlternatingGroupCons( <filter>, <deg> )
##
AlternatingGroupCons := NewConstructor(
    "AlternatingGroupCons",
    [ IsGroup, IsInt ] );


#############################################################################
##
#P  IsNaturalAlternatingGroup( <group> )
##
##  A   group is a  natural  alternating group if  it is  a permutation group
##  acting as alternating group on its moved points.
##
IsNaturalAlternatingGroup := NewProperty(
    "IsNaturalAlternatingGroup",
    IsPermGroup );

SetIsNaturalAlternatingGroup := Setter(IsNaturalAlternatingGroup);
HasIsNaturalAlternatingGroup := Tester(IsNaturalAlternatingGroup);


#############################################################################
##
#P  IsAlternatingGroup( <group> )
##
##  A group is a group isomorphic to a natural alterning group.
##
IsAlternatingGroup := NewProperty(
    "IsAlternatingGroup",
    IsGroup );

SetIsAlternatingGroup := Setter(IsAlternatingGroup);
HasIsAlternatingGroup := Tester(IsAlternatingGroup);


#############################################################################
##
#M  IsAlternatingGroup( <nat-alt-grp> )
##
InstallTrueMethod(
    IsAlternatingGroup,
    IsNaturalAlternatingGroup );


#############################################################################
##
#F  AlternatingGroup( <deg> ) . . . . . . . . . . . . . . . alternating group
##
AlternatingGroup := function ( arg )

    if Length(arg) = 1  then
        return AlternatingGroupCons( IsPermGroup, arg[1] );

    elif Length(arg) = 2  then
        return AlternatingGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
        return AlternatingGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: AlternatingGroupCons( <deg> )" );
    fi;

end;


#############################################################################
##
#P  IsOneGeneratorGroup
##
IsOneGeneratorGroup := NewProperty(
    "IsOneGeneratorGroup",
    IsGroup );


#############################################################################
##
#O  CyclicGroupCons( <filter>, <n> )
##
CyclicGroupCons := NewConstructor(
    "CyclicGroupCons",
    [ IsGroup, IsInt ] );


#############################################################################
##
#F  CyclicGroup( <n> )	. . . . . . . . . . . . . . . . . . . .  cyclic group
##
CyclicGroup := function ( arg )

    if Length(arg) = 1  then
        return CyclicGroupCons( IsPcGroup, arg[1] );

    elif Length(arg) = 2  then
        return CyclicGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
        return CyclicGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: CyclicGroup( <n> )" );
    fi;

end;


#############################################################################
##

#O  DihedralGroupCons( <filter>, <n> )
##
DihedralGroupCons := NewConstructor(
    "DihedralGroupCons",
    [ IsGroup, IsInt ] );


#############################################################################
##
#F  DihedralGroup( <n> )  . . . . . . . . . . . . dihedral groug of order <n>
##
DihedralGroup := function ( arg )

    if Length(arg) = 1  then
        return DihedralGroupCons( IsPcGroup, arg[1] );

    elif Length(arg) = 2  then
        return DihedralGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
        return DihedralGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: DihedralGroup( <n> )" );
    fi;

end;


#############################################################################
##

#O  ElementaryAbelianGroupCons( <filter>, <n> )
##
ElementaryAbelianGroupCons := NewConstructor(
    "ElementaryAbelianGroupCons",
    [ IsGroup, IsInt ] );


#############################################################################
##
#F  ElementaryAbelianGroup( <n> ) . . . . . . . . .  elementary abelian group
##
ElementaryAbelianGroup := function ( arg )

    if Length(arg) = 1  then
        return ElementaryAbelianGroupCons( IsPcGroup, arg[1] );

    elif Length(arg) = 2  then
        return ElementaryAbelianGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
        return ElementaryAbelianGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: ElementaryAbelianGroup( <n> )" );
    fi;

end;


#############################################################################
##

#O  ExtraspecialGroupCons( <filter>, <order>, <exponent> )
##
ExtraspecialGroupCons := NewConstructor(
    "ExtraspecialGroupCons",
    [ IsGroup, IsInt, IsObject ] );


#############################################################################
##
#F  ExtraspecialGroup( <order>, <exponent> )  . . . . . .  extraspecial group
##
ExtraspecialGroup := function ( arg )

    if Length(arg) = 2  then
        return ExtraspecialGroupCons( IsPcGroup, arg[1], arg[2] );

    elif Length(arg) = 3  then
        return ExtraspecialGroupCons( arg[1], arg[2], arg[3] );

    elif Length(arg) = 4  then
        return ExtraspecialGroupCons( arg[1], arg[2], arg[3], arg[4] );

    else
        Error( "usage: ExtraspecialGroup( <order>, <exponent> )" );
    fi;

end;


#############################################################################
##

#O  GeneralLinearGroupCons( <filter>, <d>, <q> )
##
GeneralLinearGroupCons := NewConstructor(
    "GeneralLinearGroupCons",
    [ IsGroup, IsInt, IsInt ] );


#############################################################################
##
#F  GeneralLinearGroup( <d>, <q> )  . . . . . . . . . .  general linear group
##
GeneralLinearGroup := function ( arg )

    if Length(arg) = 2  then
        return GeneralLinearGroupCons( IsMatrixGroup, arg[1], arg[2] );

    elif Length(arg) = 3  then
        return GeneralLinearGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: GeneralLinearGroup( <d>, <q> )" );
    fi;

end;

GL := GeneralLinearGroup;


#############################################################################
##

#O  SpecialLinearGroupCons( <filter>, <d>, <q> )
##
SpecialLinearGroupCons := NewConstructor(
    "SpecialLinearGroupCons",
    [ IsGroup, IsInt, IsInt ] );


#############################################################################
##
#F  SpecialLinearGroup( <d>, <q> )  . . . . . . . . . .  special linear group
##
SpecialLinearGroup := function ( arg )

    if Length(arg) = 2  then
        return SpecialLinearGroupCons( IsMatrixGroup, arg[1], arg[2] );

    elif Length(arg) = 3  then
        return SpecialLinearGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: SpecialLinearGroup( <d>, <q> )" );
    fi;

end;

SL := SpecialLinearGroup;


#############################################################################
##

#O  SymmetricGroupCons( <filter>, <deg> )
##
SymmetricGroupCons := NewConstructor(
    "SymmetricGroupCons",
    [ IsGroup, IsInt ] );


#############################################################################
##
#P  IsNaturalSymmetricGroup( <group> )
##
##  A group is a natural symmetric group if it is  a permutation group acting
##  as symmetric group on its moved points.
##
IsNaturalSymmetricGroup := NewProperty(
    "IsNaturalSymmetricGroup",
    IsPermGroup );

SetIsNaturalSymmetricGroup := Setter(IsNaturalSymmetricGroup);
HasIsNaturalSymmetricGroup := Tester(IsNaturalSymmetricGroup);


#############################################################################
##
#P  IsSymmetricGroup( <group> )
##
##  A group is a group isomorphic to a natural symmetric group.
##
IsSymmetricGroup := NewProperty(
    "IsSymmetricGroup",
    IsGroup );

SetIsSymmetricGroup := Setter(IsSymmetricGroup);
HasIsSymmetricGroup := Tester(IsSymmetricGroup);


#############################################################################
##
#M  IsSymmetricGroup( <nat-sym-grp> )
##
InstallTrueMethod(
    IsSymmetricGroup,
    IsNaturalSymmetricGroup );


#############################################################################
##
#F  SymmetricGroup( <deg> ) . . . . . . . . . . . . . . . . . symmetric group
##
SymmetricGroup := function ( arg )

    if Length(arg) = 1  then
        return SymmetricGroupCons( IsPermGroup, arg[1] );

    elif Length(arg) = 2  then
        return SymmetricGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
        return SymmetricGroupCons( arg[1], arg[2], arg[3] );

    else
        Error( "usage: SymmetricGroupCons( <deg> )" );
    fi;

end;


#############################################################################
##

#E  basic.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
