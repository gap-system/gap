#############################################################################
##
#W  basicfp.gi                 GAP Library                   Alexander Hulpke
##
#Y  Copyright (C)  2009,  The GAP group
##
##  This file contains the methods for the construction of the basic fp group
##  types.
##
Revision.basicfp_gi :=
    "@(#)$Id$";


    
#############################################################################
##
#M  AbelianGroupCons( <IsFpGroup and IsFinite>, <ints> )
##
InstallMethod( AbelianGroupCons, "fp group", true,
    [ IsFpGroup and IsFinite, IsList ], 0,
function( filter, ints )
local   f,g,i,j,rels;

  if Length(ints)=0 or not ForAll( ints, IsInt )  then
      Error( "<ints> must be a list of integers" );
  fi;

  f   := FreeGroup( Length(ints));
  g   := GeneratorsOfGroup(f);
  rels:=[];
  for i in [1..Length(ints)] do
    for j in [1..i-1] do
      Add(rels,Comm(g[i],g[j]));
    od;
    if ints[i]<>0 then
      Add(rels,g[i]^ints[i]);
    fi;
  od;

  g:=f/rels;

  if ForAll(ints,IsPosInt) then
    SetSize( g, Product(ints) );
  fi;
  SetReducedMultiplication(g);
  SetIsAbelian( g, true );

  return g;
end );

#############################################################################
##
#M  CyclicGroupCons( <IsFpGroup>, <n> )
##
InstallOtherMethod( CyclicGroupCons, "fp group", true,
    [ IsFpGroup,IsObject ], 0,
function( filter, n )
local f,g;
  if n=infinity then
    return FreeGroup("a");
  elif not IsPosInt(n) then
    TryNextMethod();
  fi;
  f:=FreeGroup( IsSyllableWordsFamily, "a" );
  g:=f/[f.1^n];
  SetSize(g,n);
  SetReducedMultiplication(g);
  return g;
end );


#############################################################################
##
#M  DihedralGroupCons( <IsFpGroup and IsFinite>, <n> )
##
InstallMethod( DihedralGroupCons,
    "fp group",
    true,
    [ IsFpGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
local f,rels,g;

  if n mod 2 = 1  then
      TryNextMethod();
  elif n = 2 then return
      CyclicGroup( IsFpGroup, 2 );
  fi;
  f   := FreeGroup( IsSyllableWordsFamily, "r", "s" );
  rels:= [f.1^(n/2),f.2^2,f.1^f.2*f.1];
  g   := f/rels;
  SetReducedMultiplication(g);
  SetSize(g,n);
  return g;

end );

#############################################################################
##
#M  QuaternionGroupCons( <IsFpGroup and IsFinite>, <n> )
##
InstallMethod( QuaternionGroupCons,
    "fp group",
    true,
    [ IsFpGroup and IsFinite,
      IsInt and IsPosRat ],
    0,
function( filter, n )
local f,rels,g;
  if 0 <> n mod 4  then
      TryNextMethod();
  elif n = 4 then return
      CyclicGroup( IsFpGroup, 4 );
  fi;
  f   := FreeGroup( IsSyllableWordsFamily, "r", "s" );
  rels:= [ f.1^2/f.2^(n/4), f.2^(n/2), f.2^f.1*f.2 ];
  g   := f/rels;
  SetSize(g,n);
  if n <= 10^4 then SetReducedMultiplication(g); fi;
  return g;
end );

#############################################################################
##
#M  ElementaryAbelianGroupCons( <IsFpGroup and IsFinite>, <n> )
##
InstallMethod( ElementaryAbelianGroupCons,
    "fp group",
    true,
    [ IsFpGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    if n = 1  then
        return CyclicGroupCons( IsFpGroup, 1 );
    elif not IsPrimePowerInt(n)  then
        Error( "<n> must be a prime power" );
    fi;
    n:= AbelianGroupCons( IsFpGroup, Factors(n) );
    SetIsElementaryAbelian( n, true );
    return n;
end );

