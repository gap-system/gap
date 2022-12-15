#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Stefan Kohl.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains constructors for the Suzuki groups.
##
##  The generators are taken from
##
##    Michio Suzuki. On a Class of Doubly Transitive Groups,
##    Ann. Math. 75 (1962), 105-145.
##
##  See the middle of page 140, in the proof of Theorem 12.
##

#############################################################################
##
#M  SuzukiGroupCons( <IsMatrixGroup>, <q> )
##
InstallMethod( SuzukiGroupCons,
    "matrix group for finite field size",
    true,
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function ( filter, q )

  local G,f;

  if not IsPrimePowerInt(q)
    or SmallestRootInt(q) <> 2 or LogInt(q,2) mod 2 = 0
  then Error("<q> must be a non-square power of 2"); fi;

  f := GF(q);
  G := GroupByGenerators(
       [ImmutableMatrix(f,
        [[1,                         0,   0,0],
         [1,                         1,   0,0],
         [1+Z(q),                    1,   1,0],
         [1+Z(q)+Z(q)^RootInt(2 * q),Z(q),1,1]] * One(f),true),
        ImmutableMatrix(f,
        [[0,0,0,1],
         [0,0,1,0],
         [0,1,0,0],
         [1,0,0,0]] * One(f),true)]);

  SetName(G,Concatenation("Sz(",String(q),")"));
  SetDimensionOfMatrixGroup(G,4);
  SetFieldOfMatrixGroup(G,f);
  SetIsFinite(G,true);
  SetSize(G,q^2*(q-1)*(q^2+1));
  SetIsSimpleGroup(G, q > 2);
  SetIsPerfectGroup(G, q > 2);
  return G;
end );


#############################################################################
##
#M  SuzukiGroupCons( <IsPermGroup>, <q> )
##
InstallMethod( SuzukiGroupCons,
    "permutation group for finite field size",
    true,
    [ IsPermGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function ( filter, q )

  local G,Ovoid,f,r,a,b,v;

  if not IsPrimePowerInt(q)
    or SmallestRootInt(q) <> 2 or LogInt(q,2) mod 2 = 0
  then Error("<q> must be a non-square power of 2"); fi;

  f := GF(q);
  r := RootInt(2 * q);
  v := [1,0,0,0] * One(f);
  v := ImmutableVector(f, v);
  Ovoid := [v];
  for a in f do
    for b in f do
      v:=[a^(r+2) + a*b + b^r,b,a,One(f)];
      v := ImmutableVector(f, v);
      Add(Ovoid,NormedRowVector(v));
    od;
  od;
  Sort(Ovoid);

  G := Action(SuzukiGroupCons(IsMatrixGroup,q),Ovoid,OnLines);
  SetName(G,Concatenation("Sz(",String(q),")"));
  SetSize(G,q^2*(q-1)*(q^2+1));
  SetIsSimpleGroup(G, q > 2);
  SetIsPerfectGroup(G, q > 2);
  return G;
end );
