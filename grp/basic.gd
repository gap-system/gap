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
#1
##  There are several infinite families of groups which are parametrized by
##  numbers.
##  {\GAP} provides various functions to construct these groups.
##  The functions always permit (but do not require) one to indicate
##  a filter (see~"Filters"), for example `IsPermGroup', `IsMatrixGroup' or
##  `IsPcGroup', in which the group shall be constructed.
##  There always is a default filter corresponding to a ``natural'' way
##  to describe the group in question.
##  Note that not every group can be constructed in every filter,
##  there may be theoretical restrictions (`IsPcGroup' only works for
##  solvable groups) or methods may be available only for a few filters.
##
##  Certain filters may admit additional hints.
##  For example, groups constructed in `IsMatrixGroup' may be constructed
##  over a specified field, which can be given as second argument of the
##  function that constructs the group;
##  The default field is `Rationals'.


#############################################################################
##
#O  TrivialGroupCons( <filter> )
##
DeclareConstructor( "TrivialGroupCons", [ IsGroup ] );


#############################################################################
##
#F  TrivialGroup( [<filter>] )  . . . . . . . . . . . . . . . . trivial group
##
##  constructs a trivial group in the category given by the filter <filter>.
##  If <filter> is not given it defaults to `IsPcGroup'.
##
BindGlobal( "TrivialGroup", function( arg )

  if Length( arg ) = 0 then
    return TrivialGroupCons( IsPcGroup );
  elif IsFilter( arg[1] ) and Length( arg ) = 1 then
    return TrivialGroupCons( arg[1] );
  fi;
  Error( "usage: TrivialGroup( [<filter>] )" );

end );


#############################################################################
##
#O  AbelianGroupCons( <filter>, <ints> )
##
DeclareConstructor( "AbelianGroupCons", [ IsGroup, IsList ] );


#############################################################################
##
#F  AbelianGroup( [<filt>, ]<ints> )  . . . . . . . . . . . . . abelian group
##
##  constructs an abelian group in the category given by the filter <filt>
##  which is of isomorphism type $C_{ints[1]} \*  C_{ints[2]} \* \ldots \*
##  C_{ints[n]}$.  <ints> must be a list of positive integers.  If <filt> is
##  not given it defaults to `IsPcGroup'.  The generators of the group
##  returned are the elements corresponding to the integers in <ints>.
##
BindGlobal( "AbelianGroup", function ( arg )

  if Length(arg) = 1  then
    return AbelianGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return AbelianGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
      return AbelianGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: AbelianGroup( [<filter>, ]<ints> )" );

end );


#############################################################################
##
#O  AlternatingGroupCons( <filter>, <deg> )
##
DeclareConstructor( "AlternatingGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  AlternatingGroup( [<filt>, ]<deg> ) . . . . . . . . . . alternating group
#F  AlternatingGroup( [<filt>, ]<dom> ) . . . . . . . . . . alternating group
##
##  constructs the alternating group of degree <deg> in the category given
##  by the filter <filt>.
##  If <filt> is not given it defaults to `IsPermGroup'.
##  In the second version, the function constructs the alternating group on
##  the points given in the set <dom> which must be a set of positive
##  integers.
##
BindGlobal( "AlternatingGroup", function ( arg )

  if Length(arg) = 1  then
    return  AlternatingGroupCons( IsPermGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return  AlternatingGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage:  AlternatingGroup( [<filter>, ]<deg> )" );

end );


#############################################################################
##
#O  CyclicGroupCons( <filter>, <n> )
##
DeclareConstructor( "CyclicGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  CyclicGroup( [<filt>, ]<n> )  . . . . . . . . . . . . . . .  cyclic group
##
##  constructs the cyclic group of size <n> in the category given by the
##  filter <filt>.  If <filt> is not given it defaults to `IsPcGroup'.
##
BindGlobal( "CyclicGroup", function ( arg )

  if Length(arg) = 1  then
    return CyclicGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return CyclicGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
      return CyclicGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: CyclicGroup( [<filter>, ]<size> )" );

end );


#############################################################################
##
#O  DihedralGroupCons( <filter>, <n> )
##
DeclareConstructor( "DihedralGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  DihedralGroup( [<filt>, ]<n> )  . . . . . . . dihedral group of order <n>
##
##  constructs the dihedral group of size <n> in the category given by the
##  filter <filt>.  If <filt> is not given it defaults to `IsPcGroup'.
##
BindGlobal( "DihedralGroup", function ( arg )

  if Length(arg) = 1  then
    return DihedralGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return DihedralGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
      return DihedralGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: DihedralGroup( [<filter>, ]<size> )" );

end );


#############################################################################
##
#O  ElementaryAbelianGroupCons( <filter>, <n> )
##
DeclareConstructor( "ElementaryAbelianGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  ElementaryAbelianGroup( [<filt>, ]<n> ) . . . .  elementary abelian group
##
##  constructs the elementary abelian group of size <n> in the category
##  given by the filter <filt>.
##  If <filt> is not given it defaults to `IsPcGroup'.
##
BindGlobal( "ElementaryAbelianGroup", function ( arg )

  if Length(arg) = 1  then
    return ElementaryAbelianGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return ElementaryAbelianGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
      return ElementaryAbelianGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: ElementaryAbelianGroup( [<filter>, ]<size> )" );

end );


#############################################################################
##
#O  ExtraspecialGroupCons( <filter>, <order>, <exponent> )
##
DeclareConstructor( "ExtraspecialGroupCons", [ IsGroup, IsInt, IsObject ] );


#############################################################################
##
#F  ExtraspecialGroup( [<filt>, ]<order>, <exp> ) . . . .  extraspecial group
##
##  Let <order> be of the form $p^{2n+1}$, for a prime integer $p$ and a
##  positive integer $n$.
##  `ExtraspecialGroup' returns the extraspecial group of order <order>
##  that is determined by <exp>, in the category given by the filter <filt>.
##
##  If $p$ is odd then admissible values of <exp> are the exponent of the
##  group (either $p$ or $p^2$) or one of `{'}+{'}', `\"+\"', `{'}-{'}',
##  `\"-\"'.
##  For $p = 2$, only the above plus or minus signs are admissible.
##
##  If <filt> is not given it defaults to `IsPcGroup'.
##
BindGlobal( "ExtraspecialGroup", function ( arg )

  if Length(arg) = 2  then
    return ExtraspecialGroupCons( IsPcGroup, arg[1], arg[2] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 3  then
      return ExtraspecialGroupCons( arg[1], arg[2], arg[3] );

    elif Length(arg) = 4  then
      return ExtraspecialGroupCons( arg[1], arg[2], arg[3], arg[4] );
    fi;
  fi;
  Error( "usage: ExtraspecialGroup( [<filter>, ]<order>, <exponent> )" );

end );


#############################################################################
##
#O  MathieuGroupCons( <filter>, <degree> )
##
DeclareConstructor( "MathieuGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  MathieuGroup( [<filt>, ]<degree> )  . . . . . . . . . . . . Mathieu group
##
##  constructs the Mathieu group of degree <degree> in the category given by
##  the filter <filt>,
##  where <degree> must be in $\{ 9, 10, 11, 12, 21, 22, 23, 24 \}$.
##  If <filt> is not given it defaults to `IsPermGroup'.
##
BindGlobal( "MathieuGroup", function( arg )

  if Length( arg ) = 1 then
    return MathieuGroupCons( IsPermGroup, arg[1] );
  elif IsOperation( arg[1] ) then

    if Length( arg ) = 2 then
      return MathieuGroupCons( arg[1], arg[2] );

    elif Length( arg ) = 3 then
      return MathieuGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: MathieuGroup( [<filter>, ]<degree> )" );

end );


#############################################################################
##
#O  SymmetricGroupCons( <filter>, <deg> )
##
DeclareConstructor( "SymmetricGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  SymmetricGroup( [<filt>, ]<deg> )
#F  SymmetricGroup( [<filt>, ]<dom> )
##
##  constructs the symmetric group of degree <deg> in the category given by
##  the filter <filt>.
##  If <filt> is not given it defaults to `IsPermGroup'.
##  In the second version, the function constructs the symmetric group on
##  the points given in the set <dom> which must be a set of positive
##  integers.
##
BindGlobal( "SymmetricGroup", function ( arg )

  if Length(arg) = 1  then
    return  SymmetricGroupCons( IsPermGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return  SymmetricGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage:  SymmetricGroup( [<filter>, ]<deg> )" );

end );


#############################################################################
##
#E

