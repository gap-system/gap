#############################################################################
##
#W  suzuki.gi                   GAP library                       Stefan Kohl
##
#H  @(#)$Id$
##
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.suzuki_gi :=
    "@(#)$Id$";

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

  if not IsPrimePowerInt(q) or q < 8 
    or SmallestRootInt(q) <> 2 or LogInt(q,2) mod 2 = 0
  then Error("<q> must be a non - square power of 2 and >= 8"); fi;

  f := GF(q);
  G := GroupByGenerators(
       [ImmutableMatrix(f,
        [[1,                         0,   0,0],
         [1,                         1,   0,0],
         [1+Z(q),                    1,   1,0],
         [1+Z(q)+Z(q)^RootInt(2 * q),Z(q),1,1]] * One(f)),
        ImmutableMatrix(f,
        [[0,0,0,1],
         [0,0,1,0],
         [0,1,0,0],
         [1,0,0,0]] * One(f))]);

  SetName(G,Concatenation("Sz(",String(q),")"));
  SetDimensionOfMatrixGroup(G,4);
  SetFieldOfMatrixGroup(G,f);
  SetIsFinite(G,true);
  SetSize(G,q^2*(q-1)*(q^2+1));
  SetIsSimpleGroup(G,true);
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

  if not IsPrimePowerInt(q) or q < 8 
    or SmallestRootInt(q) <> 2 or LogInt(q,2) mod 2 = 0
  then Error("<q> must be a non - square power of 2 and >= 8"); fi;

  f := GF(q);
  r := RootInt(2 * q);
  v:=[1,0,0,0] * One(f);
  ConvertToVectorRep(v,q);
  MakeImmutable(v);
  Ovoid := [v];
  for a in f do
    for b in f do
      v:=[a^(r+2) + a*b + b^r,b,a,One(f)];
      ConvertToVectorRep(v,q);
      MakeImmutable(v);
      Add(Ovoid,NormedRowVector(v));
    od;
  od;
  Sort(Ovoid);

  G := Operation(SuzukiGroupCons(IsMatrixGroup,q),Ovoid,OnLines);
  SetName(G,Concatenation("Sz(",String(q),")"));
  SetSize(G,q^2*(q-1)*(q^2+1));
  SetIsSimpleGroup(G,true);
  return G;
end );
