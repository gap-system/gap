#############################################################################
##
#W  suzuki.gi                   GAP library                       Stefan Kohl
##
##
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
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
  if q > 2 then SetIsSimpleGroup(G,true); fi;
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
  v:=[1,0,0,0] * One(f);
  if q <= 256 then
    ConvertToVectorRepNC(v,q);
  fi;  
  MakeImmutable(v);
  Ovoid := [v];
  for a in f do
    for b in f do
      v:=[a^(r+2) + a*b + b^r,b,a,One(f)];
      if q <= 256 then
        v := CopyToVectorRepNC(v,q);
      fi;  
      MakeImmutable(v);
      Add(Ovoid,NormedRowVector(v));
    od;
  od;
  Sort(Ovoid);

  G := Action(SuzukiGroupCons(IsMatrixGroup,q),Ovoid,OnLines);
  SetName(G,Concatenation("Sz(",String(q),")"));
  SetSize(G,q^2*(q-1)*(q^2+1));
  if q > 2 then SetIsSimpleGroup(G,true); fi;
  return G;
end );

#############################################################################
##
#E  suzuki.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
