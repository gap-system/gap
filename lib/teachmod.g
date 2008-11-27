#############################################################################
##
#W  teachmod.g                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C) 2008 The GAP Group
##
##  This  file contains rotines that enable simplified display and turn on
##  some naive routines, which are primarily of interest in a teaching
##  context. It is made part of the general system to ensure it will be
##  always installed with GAP.
##
Revision.teachmod_g:=
  "@(#)$Id$";


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
  p:=MinimalPolynomial(Rationals,x,1);
  if DegreeOfUnivariateLaurentPolynomial(p)>2 then
    TryNextMethod();
  fi;
  p:=CoefficientsOfUnivariateLaurentPolynomial(p)[1];
  d:=p[2]^2-4*p[1];
  e:=1;
  if d<0 then
    e:=-e;
    d:=-d;
  fi;
  if not IsInt(d) then
    a:=DenominatorRat(d);
    d:=NumeratorRat(d)*a;
    a:=1/(2*a);
  else
    a:=1/2;
  fi;
  d:=Collected(Factors(d));
  for i in d do
    b:=QuoInt(i[2],2);
    a:=a*i[1]^b;
    if (i[2] mod 2)=1 then
      e:=e*i[1];
    fi;
  od;
  if not IsRat(x-a*ER(e)) then
    a:=-a;
  fi;

  p:=-p[2]/2;
  if p<>0 then
    Print(p);
    if a>0 then
      Print("+");
    fi;
  fi;
  if a=-1 then
    Print("-");
  elif a<>1 then 
    Print(a,"*");
  fi;
  Print("ER(",e,")");
end);

