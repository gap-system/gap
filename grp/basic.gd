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
#F  AbelianGroup( [<cat>,]<ints> ). . . . . . . . . . . . . . . abelian group
##
##  constructs an  abelian group in the category <cat> which is of isomorphism
##  type $C_{ints[1]} *  C_{ints[2]} * \ldots  *   C_{ints[n]}$.
##  <ints>  must   be a  list  of positive integers. If <cat> is not given
##  it defaults to `IsPcGroup'.
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
#F  AlternatingGroup( [<cat>,] <deg> )  . . . . . . . . . . alternating group
##
##  constructs the alternating group of degree <deg> in the category <cat>.
##  If <cat> is not given it defaults to `IsPermGroup'.
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
#O  CyclicGroupCons( <filter>, <n> )
##
CyclicGroupCons := NewConstructor(
    "CyclicGroupCons",
    [ IsGroup, IsInt ] );


#############################################################################
##
#F  CyclicGroup( [<cat>,]  <n> )  . . . . . . . . . . . . . . .  cyclic group
##
##  constructs the cyclic group of size <n> in the category <cat>.
##  If <cat> is not given it defaults to `IsPcGroup'.
CyclicGroup := function ( arg )

    if Length(arg) = 1  then
        if arg[1] = 1 then
            return FreeGroup( 0 );
        fi;
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
##  constructs the dihedral group of size <n> in the category <cat>.
##  If <cat> is not given it defaults to `IsPcGroup'.
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
#F  ElementaryAbelianGroup( [<cat>,]<n> ) . . . . .  elementary abelian group
##
##  constructs the elementary abelian group of size <n> in the category <cat>.
##  If <cat> is not given it defaults to `IsPcGroup'.
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
#F  ExtraspecialGroup( [<cat>,] <order>, <exponent> ) . .  extraspecial group
##
##  constructs the extraspecial group of size <order> and exponent
##  <exponent> in the category <cat>.
##  If <cat> is not given it defaults to `IsPcGroup'.
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
#F  GeneralLinearGroup( [<cat>,] <d>, <q> ) . . . . . .  general linear group
#F  GL( [<cat>,] <d>, <q> )
##
##  constructs the general linear group GL(<d>,<q>)
##  in the category <cat>.
##  If <cat> is not given it defaults to `IsMatrixGroup'.
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
#F  SpecialLinearGroup( [<cat>,] <d>, <q> ) . . . . . .  special linear group
#F  SL( [<cat>,] <d>, <q> )
##
##  constructs the special linear group SL(<d>,<q>)
##  in the category <cat>.
##  If <cat> is not given it defaults to `IsMatrixGroup'.
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
#F  SymmetricGroup( <deg> ) . . . . . . . . . . . . . . . . . symmetric group
##
##  constructs the symmetric group of degree <deg> in the category <cat>.
##  If <cat> is not given it defaults to `IsPermGroup'.
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
