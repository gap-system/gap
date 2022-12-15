#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file contains rotines that enable simplified display and turn on
##  some naive routines, which are primarily of interest in a teaching
##  context. It is made part of the general system to ensure it will be
##  always installed with GAP.
##


## FFE Display

InstallMethod(ViewObj,true,[IsFFE],100,
function(x)
  local p,d;
  if TEACHMODE<>true then
    TryNextMethod();
  fi;
  d:=DegreeFFE(x);
  p:=Characteristic(x);
  if d=1 then
    Print("ZmodnZObj(",Int(x),",",p,")");
  else
    Print("Z(",p^d,")^",LogFFE(x,Z(p^d)));
  fi;
end);

InstallMethod(String,true,[IsFFE],100,
function(x)
  local p,d;
  if TEACHMODE<>true then
    TryNextMethod();
  fi;
  d:=DegreeFFE(x);
  p:=Characteristic(x);
  if d=1 then
    return Concatenation("ZmodnZObj(",String(Int(x)),",",String(p),")");
  else
    return Concatenation("Z(",String(p^d),")^",String(LogFFE(x,Z(p^d))));
  fi;
end);

InstallMethod( ZmodnZObj, "for prime residues convert to GF(p)",
  [ IsInt, IsPosInt ],100,
function( residue, n )
  if TEACHMODE<>true then
    TryNextMethod();
  fi;
  if not IsPrimeInt(n) then
    return ZmodnZObj( ElementsFamily( FamilyObj( ZmodnZ( n ) )), residue );
  else
    return residue*Z(n)^0;
  fi;
end );


## Cyclotomics display
## Careful, this can affect the rationals!

InstallMethod(ViewObj,true,[IsCyc],100,
function(x)
local a;
  if IsRat(x) or TEACHMODE<>true or Conductor(x)=4 then
    TryNextMethod();
  fi;
  a:=Quadratic(x,true);
  if a=fail then
    TryNextMethod();
  fi;
  Print(a.display);
end);

# basic constructors -- if teaching mode they will default to fp groups


#############################################################################
##
#F  AbelianGroup( [<filt>, ]<ints> )  . . . . . . . . . . . . . abelian group
##
BindGlobal( "AbelianGroup", function ( arg )

  if Length(arg) = 1  then
    if ForAny(arg[1],x->x=0) or TEACHMODE=true then
      return AbelianGroupCons( IsFpGroup, arg[1] );
    else
      return AbelianGroupCons( IsPcGroup, arg[1] );
    fi;
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
#F  CyclicGroup( [<filt>, ]<n> )  . . . . . . . . . . . . . . .  cyclic group
##
BindGlobal( "CyclicGroup", function ( arg )

  if Length(arg) = 1  then
    if arg[1]=infinity or TEACHMODE=true then
      return CyclicGroupCons(IsFpGroup,arg[1]);
    fi;
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
#F  DihedralGroup( [<filt>, ]<n> )  . . . . . . . dihedral group of order <n>
##
BindGlobal( "DihedralGroup", function ( arg )

  if Length(arg) = 1  then
    if TEACHMODE=true then
      return DihedralGroupCons( IsFpGroup, arg[1] );
    else
      return DihedralGroupCons( IsPcGroup, arg[1] );
    fi;
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
#F  ElementaryAbelianGroup( [<filt>, ]<n> ) . . . .  elementary abelian group
##
BindGlobal( "ElementaryAbelianGroup", function ( arg )

  if Length(arg) = 1  then
    if TEACHMODE=true then
      return ElementaryAbelianGroupCons( IsFpGroup, arg[1] );
    else
      return ElementaryAbelianGroupCons( IsPcGroup, arg[1] );
    fi;
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return ElementaryAbelianGroupCons( arg[1], arg[2] );

    elif Length(arg) = 3  then
      return ElementaryAbelianGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: ElementaryAbelianGroup( [<filter>, ]<size> )" );

end );
