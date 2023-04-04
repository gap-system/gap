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
##  This file contains the methods for the construction of the basic fp group
##  types.
##



#############################################################################
##
#M  TrivialGroupCons( <IsPcGroup> )
##
InstallMethod( TrivialGroupCons,  "fp group",
    [ IsFpGroup and IsTrivial ],
    filter -> FreeGroup(0));


#############################################################################
##
#M  AbelianGroupCons( <IsFpGroup and IsFinite>, <ints> )
##
InstallMethod( AbelianGroupCons, "fp group", true,
    [ IsFpGroup and IsAbelian, IsList ], 0,
function( filter, ints )
local   f,g,i,j,rels,gfam,fam;

  if not ForAll( ints, x -> IsInfinity(x) or (IsInt(x) and x >= 0) )  then
      Error( "<ints> must be a list of integers" );
  fi;

  f   := FreeGroup(IsSyllableWordsFamily, Length(ints));
  g   := GeneratorsOfGroup(f);
  rels:=[];
  for i in [1..Length(ints)] do
    for j in [1..i-1] do
      Add(rels,Comm(g[i],g[j]));
    od;
    if IsPosInt(ints[i]) then
      Add(rels,g[i]^ints[i]);
    fi;
  od;

  g:=f/rels;

  if ForAll(ints,IsPosInt) then
    SetSize( g, Product(ints) );
  else
    SetSize( g, infinity );
  fi;

  fam:=FamilyObj(One(f));
  gfam:=FamilyObj(One(g));
  gfam!.redorders:=ints;
  SetFpElementNFFunction(gfam,function(x)
    local u,e,i,j,n;
    u:=UnderlyingElement(x);
    e:=ExtRepOfObj(u); # syllable form

    # bring in correct order and reduction
    n:=ListWithIdenticalEntries(Length(gfam!.redorders),0);
    for i in [1,3..Length(e)-1] do
      j:=e[i];
      if IsPosInt(gfam!.redorders[j]) then
        n[j]:=n[j]+e[i+1] mod gfam!.redorders[j];
      else
        n[j]:=n[j]+e[i+1];
      fi;
    od;

    e:=[];
    for i in [1..Length(gfam!.redorders)] do
      if n[i]<>0 then
        Add(e,i);
        Add(e,n[i]);
      fi;
    od;

    return ObjByExtRep(fam,e);
  end);

  SetReducedMultiplication(g);
  SetIsAbelian( g, true );

  return g;
end );

#############################################################################
##
#M  CyclicGroupCons( <IsFpGroup>, <n> )
##
InstallOtherMethod( CyclicGroupCons, "fp group", true,
    [ IsFpGroup and IsCyclic, IsObject ], 0,
function( filter, n )
local f,g,fam,gfam;
  if n=infinity then
    return FreeGroup("a");
  elif not IsPosInt(n) then
    TryNextMethod();
  fi;
  f:=FreeGroup( IsSyllableWordsFamily, "a" );
  g:=f/[f.1^n];
  SetSize(g,n);
  fam:=FamilyObj(One(f));
  gfam:=FamilyObj(One(g));
  SetFpElementNFFunction(gfam,function(x)
    local u,e;
    u:=UnderlyingElement(x);
    e:=ExtRepOfObj(u); # syllable form
    if Length(e)=0 or (e[2]>=0 and e[2]<n) then
      return u;
    elif e[2] mod n=0 then
      return One(f);
    else
      e:=[e[1],e[2] mod n];
      return ObjByExtRep(fam,e);
    fi;
  end);

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
  SetSize(g,n);
  SetReducedMultiplication(g);
  return g;

end );

InstallOtherMethod( DihedralGroupCons,
    "fp group",
    true,
    [ IsFpGroup and IsFinite,
      IsInfinity ],
    0,

function( filter, inf )
local f,rels,g;

  f   := FreeGroup( IsSyllableWordsFamily, "r", "s" );
  rels:= [f.2^2,f.1^f.2*f.1];
  g   := f/rels;
  SetSize(g,infinity);
  SetReducedMultiplication(g);
  return g;

end );

#############################################################################
##
#M  DicyclicGroupCons( <IsFpGroup and IsFinite>, <n> )
##
InstallMethod( DicyclicGroupCons,
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
    [ IsFpGroup and IsFinite and IsElementaryAbelian,
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


#############################################################################
##
#M  FreeAbelianGroupCons( <IsFpGroup>, <rank> )
##
InstallMethod( FreeAbelianGroupCons,
    "fp group",
    true,
    [ IsFpGroup and IsAbelian,
      IsInt and IsPosRat ],
    0,

function( filter, rank )
    return AbelianGroupCons( filter, ListWithIdenticalEntries(rank, 0) );
    # TODO: Add the following if it ever moves from Polycyclic to the GAP core:
    #SetIsFreeAbelian( G, true );
end );

