#############################################################################
##
#W  teachmod.g                GAP library                   Alexander Hulpke
##
#H  @(#)$Id: teachmod.g,v 4.3 2009/01/03 00:22:55 gap Exp $
##
#Y  Copyright (C) 2008 The GAP Group
##
##  This  file contains rotines that enable simplified display and turn on
##  some naive routines, which are primarily of interest in a teaching
##  context. It is made part of the general system to ensure it will be
##  always installed with GAP.
##
Revision.teachmod_g:=
  "@(#)$Id: teachmod.g,v 4.3 2009/01/03 00:22:55 gap Exp $";


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
    Print("ZmodnZObj( ",Int(x),", ",p," )");
  else
    Print("Z(",p^d,")^",LogFFE(x,Z(p^d)));
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
local a,p, d, e, b, i;
  if IsRat(x) or TEACHMODE<>true or Conductor(x)=4 then
    TryNextMethod();
  fi;
  a:=Quadratic(x,true);
  if a=fail then
    TryNextMethod();
  fi;
  Print(a.display);
end);

