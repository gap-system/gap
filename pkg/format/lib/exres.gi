#############################################################################
##
#W  exres.gi                        FORMAT                       Bettina Eick
#W                                      conversion from GAP3 by C.R.B. Wright 
##
Revision.("format/lib/exres.gi") :=
    "@(#)$Id: exres.gi,v 1.5 2000/10/31 17:16:29 gap Exp $";


#############################################################################
#M  PResidualOp( <group>, <prime> ). . . . . . . . . . . . . . . . . . O^p(G)
##

InstallMethod( PResidualOp, "generic", true, [IsGroup, IsPosInt], 0,
function(G,prime)
  local lcs, resid, gens, g;
  
  if not IsPrimeInt( prime ) then
    Error( prime, " must be a prime in PResidualOp.");
  fi;
  
  if (not HasIsSolvableGroup(G) and IsSolvableGroup(G)) then
    return PResidualOp(G,prime);
  fi;
  
  if Size(G) = 1 then return G; fi;
  
  lcs := LowerCentralSeriesOfGroup(G);
  resid := lcs[Length(lcs)];
  gens := ShallowCopy(GeneratorsOfGroup(resid));
  for g in GeneratorsOfGroup(G) do
    if not PPrimePart(g, prime) = One(G) then
      Add(gens, PPrimePart(g, prime));
    fi;
  od;
  return SubgroupNC(G, gens);
end);

#############################################################################
#M  PResidualOp( <group>, <prime> ). . . . . . . . . . . . . . . . . . O^p(G)
##  

InstallMethod( PResidualOp, "pcgs", true, [IsGroup and IsFinite 
    and CanEasilyComputePcgs, IsPosInt], 0,
function(G,prime)
  local gens, g, p, y;
  
  if not IsPrimeInt( prime ) then
    Error( prime, " must be a prime in PResidualOp.");
  fi;
  
  if Size(G) = 1 then return G; fi;
  
  gens := [];
  if IsPrimeOrdersPcgs( Pcgs( G ) ) then
    for g in Pcgs(G) do
      p := RelativeOrderOfPcElement(Pcgs(G), g);
      if p <> prime then
        y := PrimePowerComponent(g, p);
        if not (y = One(G)) then
          Add(gens, y);
        fi;
      fi;
    od;
  else
    for g in Pcgs(G) do
      y := PPrimePart(g, prime);
      if not (y = One(G)) then
        Add(gens, y);
      fi;
    od;
  fi;
  return NormalClosure(G, SubgroupNC(G, gens));
end);

#############################################################################
#M  PResidualOp( <group>, <prime> ). . . . . . . . . . . . . . . . . . O^p(G)
##

InstallMethod( PResidualOp, "special pcgs", true,
[IsGroup and HasSpecialPcgs, IsPosInt], 0,
function(G,prime)
  local gens, i;
  
  if not IsPrimeInt( prime ) then
    Error( prime, " must be a prime in PPrimePart.");
  fi;
  
  if Size(G) = 1 then return G; fi;
  
  gens := [];
  for i in [1..Length(SpecialPcgs(G))] do
    if LGWeights(SpecialPcgs(G))[i][1] > 1 or
        LGWeights(SpecialPcgs(G))[i][3] <> prime then
      Add(gens, SpecialPcgs(G)[i] );
    fi;
  od;
  return SubgroupByPcgs(G, InducedPcgsByPcSequenceNC(SpecialPcgs(G), gens));
end);

#############################################################################
#M  PResidualOp( <group>, <prime> ). . . . . . . . . . . . . . . . . . O^p(G)
##

SubgpMethodByNiceMonomorphismCollOther(PResidualOp, [IsGroup, IsPosInt]);

#############################################################################
#M  PiResidualOp( <group>, <list of primes> ). . . . . . . . . . . . .O^pi(G)
##

InstallMethod( PiResidualOp, "generic", true, [IsGroup, IsList], 0,
function(G, pi)
  local gens, p;
  
  if pi = [] then return G; fi;
  
  if Length(pi) = 1 then
    return PResidual(G, pi[1]);
  fi;
  
  for p in pi do
    if not IsPrimeInt(p) then
      Error(p, " in ", pi, " is not a prime.\n");
    fi;
  od;
  
  if (not HasIsSolvableGroup(G) and IsSolvableGroup(G)) then
    return PiResidualOp(G, pi);
  fi;
  
  if Size(G) = 1 then return G; fi;
  
  gens := [];
  
  for p in Set(Factors(Size(G))) do
    if not p in pi then
      Append(gens, GeneratorsOfGroup(SylowSubgroup(G, p)));
    fi;
  od;
  
  return NormalClosure(G, SubgroupNC(G, gens));
end);

#############################################################################
#M  PiResidualOp( <group>, <list of primes> ). . . . . . . . . . . . .O^pi(G)
##  

InstallMethod( PiResidualOp, "pcgs", true, [IsGroup and IsFinite 
    and CanEasilyComputePcgs, IsList], 0,
function(G, pi)
  local gens, g, p, y;
  
  if pi = [] then return G; fi;
  
  if Size(G) = 1 then return G; fi;
  
  if Length(pi) = 1 then
    return PResidual(G, pi[1]);
  fi;
  
  for p in pi do
    if not IsPrimeInt(p) then
      Error(p, " in ", pi, " is not a prime.\n");
    fi;
  od;
  
  gens := [];
  
  if IsPrimeOrdersPcgs(Pcgs(G)) then
    for g in Pcgs(G) do
      p := RelativeOrderOfPcElement(Pcgs(G), g);
      if not p in pi then
        Add( gens, PrimePowerComponent(g,p));
      fi;
    od;
  else
    for g in Pcgs(G) do 
      Add(gens, PiPrimePart(g, pi));
    od;
  fi;
  
  return NormalClosure(G, SubgroupNC(G, gens));
end);

#############################################################################
#M  PiResidualOp( <group>, <list of primes> ). . . . . . . . . . . . .O^pi(G)
##

SubgpMethodByNiceMonomorphismCollOther(PiResidualOp, [IsGroup, IsList]);

#############################################################################
#M  CoprimeResidual( <group>, <list of primes> ). . . . . . . . . . .O^pi'(G)
##

InstallMethod( CoprimeResidual, "generic", true, [IsGroup, IsList], 0,
function(G, pi)
  local primes;
  
  if Size(G) = 1 then return G; fi;
  
  primes := Set( Factors( Size( G ) ) );
  SubtractSet( primes, pi );
  return PiResidual(G, primes);
end);

#############################################################################
#M  NilpotentResidual( <group> ). . . . . . . . . . . . . . . . . . . .G^Nilp
##  

InstallMethod( NilpotentResidual, "generic", true, [IsGroup ], 0,
function( G )
 
  if IsFinite(G) and not HasIsSolvableGroup(G) and IsSolvableGroup(G) then
      # test solvability without looping
    return NilpotentResidual(G);
  fi;

  # now catch trivial case. Earlier test might have set HasIsSolvableGroup.
  if Size( G ) = 1 then return G; fi;

  return LowerCentralSeriesOfGroup(G)
      [Length(LowerCentralSeriesOfGroup(G))];

end);

#############################################################################
#M  NilpotentResidual( <group> ). . . . . . . . . . . . . . . . . . . .G^Nilp
##  

InstallMethod( NilpotentResidual, "pcgs", true, [IsGroup and IsFinite 
  and CanEasilyComputePcgs], 0,
function( G )
  local base, gens, i, j, p, q;

  # catch trivial case
  if Size( G ) = 1 then return G; fi;
  
  base := List(Pcgs(G), x -> PrimePowerComponent(x, 
      RelativeOrderOfPcElement( Pcgs(G), x )));
  gens := [];
  for i in [1..Length(base)-1]  do
    p := RelativeOrderOfPcElement( Pcgs(G), base[i] );
    for j in [i+1..Length(base)] do 
      q := RelativeOrderOfPcElement( Pcgs(G), base[j] );
      if q <> p and not Comm( base[i], base[j] ) = One(G) then
        Add( gens, Comm( base[i], base[j] ) );
      fi;
    od;
  od;
  return NormalClosure( G, SubgroupNC( G, gens ) );
end);

#############################################################################
#M  NilpotentResidual( <group> ). . . . . . . . . . . . . . . . . . . .G^Nilp
##  

InstallMethod( NilpotentResidual, "special pcgs", true, [IsGroup and IsFinite 
  and HasSpecialPcgs], 0,
function( G )
  local spec;

  # catch trivial case
  if Size( G ) = 1 then return G; fi;

  spec := SpecialPcgs( G );
  return SubgroupNC( G, spec{ [ LGHeads(spec)[2] .. Length( spec ) ] } );
end);

#############################################################################
#M  NilpotentResidual( <group> ). . . . . . . . . . . . . . . . . . . .G^Nilp
##  

SubgpMethodByNiceMonomorphism( NilpotentResidual, [IsGroup] );

#############################################################################
#M  ElementaryAbelianProductResidual( <group> )
##  Smallest normal subgroup with factor a direct product of elem abelians

InstallMethod( ElementaryAbelianProductResidual, "generic", true, 
  [IsGroup], 0,
function( G )
  local pi, prod, gens, g, y;
    
  if IsFinite(G) and not HasIsSolvableGroup(G) and IsSolvableGroup(G) then
      # test solvability without looping
    return NilpotentResidual(G);
  fi;

  # now catch trivial case. Earlier might have set HasIsSolvableGroup.
  if Size( G ) = 1 then return G; fi;

  pi := Set(Factors(Index(G, DerivedSubgroup(G))));
  prod := Product(pi);
  gens := ShallowCopy(GeneratorsOfGroup( DerivedSubgroup(G)));
  for g in GeneratorsOfGroup(G) do
    y := g^prod;
    if not y = One(G) then
      Add(gens, y);
    fi;
  od;
  return SubgroupNC(G, gens);
end);

#############################################################################
#M  ElementaryAbelianProductResidual( <group> )
##  Smallest normal subgroup with factor a direct product of elem abelians

InstallMethod( ElementaryAbelianProductResidual, "solvable", true, 
  [IsGroup and IsFinite and IsSolvableGroup], 0,
function( G )

  if CanEasilyComputePcgs(G) then
    return ElementaryAbelianProductResidual(G);
  fi;

  TryNextMethod();   # This can happen. E.g., SL(2,3)xGL(2,3).
end);

#############################################################################
#M  ElementaryAbelianProductResidual( <group> )
##  Smallest normal subgroup with factor a direct product of elem abelians

InstallMethod( ElementaryAbelianProductResidual, "pcgs", true, 
  [IsGroup and IsFinite and CanEasilyComputePcgs], 0,
function( G )
  local par, fac, gens;

  # catch trivial case
  if Size( G ) = 1 then return G; fi;

  par := ParentPcgs(Pcgs(G));
  fac := Pcgs(G) mod InducedPcgs(par, DerivedSubgroup(G));
  gens := List(fac, x -> x^RelativeOrderOfPcElement(Pcgs(G), x));
  return SubgroupByPcgs(G, InducedPcgsByPcSequenceAndGenerators(par,
      DenominatorOfModuloPcgs(fac),gens));
end);

#############################################################################
#M  ElementaryAbelianProductResidual( <group> )
##  Smallest normal subgroup with factor a direct product of elem abelians

InstallMethod( ElementaryAbelianProductResidual, "special pcgs", true, 
  [IsGroup and IsFinite and HasSpecialPcgs], 0,
function( G )
  local spec, lgw, pos, pos2;

  # catch trivial case
  if Size( G ) = 1 then return G; fi;

  spec := SpecialPcgs(G);
  lgw := LGWeights(spec);
  pos := Position(List(lgw, x -> x[1]), 2);
  if pos = fail then     # G is nilpotent
    pos2 := Position(List(lgw, x -> x[2]), 2);
    if pos2 = fail then  # G is product of elem abelians already
      return TrivialSubgroup(G);
    fi;
  else
    pos2 := Position(List(lgw{[1..(pos - 1)]}, x -> x[2]), 2);
    if pos2 = fail then
      pos2 := pos;
    fi;
  fi;
  return SubgroupByPcgs(G, InducedPcgsByPcSequence( spec, 
      spec{[pos2..Length(spec)]}));
end);

#############################################################################
#M  ElementaryAbelianProductResidual( <group> )
##  Smallest normal subgroup with factor a direct product of elem abelians

SubgpMethodByNiceMonomorphism( ElementaryAbelianProductResidual, 
    [IsGroup] );

#############################################################################
#M  AbelianExponentResidualOp( <group>, <integer> )
##  This operation computes the smallest normal subgroup of <group>
##  whose factor group is abelian of exponent dividing <integer>-1.

InstallMethod( AbelianExponentResidualOp, "generic", true, 
  [IsGroup, IsPosInt], 0,
function( G, p )
  local pi, prod, gens, g, y;
    
  if IsFinite(G) and not HasIsSolvableGroup(G) and IsSolvableGroup(G) then
      # test solvability without looping
    return AbelianExponentResidualOp(G,p);
  fi;

  # now catch trivial case. Earlier might have set HasIsSolvableGroup.
  if Size( G ) = 1 then return G; fi;

  Info( InfoForm, 1, "shouldn't ever be using this here\n");
  gens := List(GeneratorsOfGroup(G), x -> x^(p-1));
  Append(gens, GeneratorsOfGroup(DerivedSubgroup(G)));
  return SubgroupNC(G, gens);
end);

#############################################################################
#M  AbelianExponentResidualOp( <group>, <integer> )
##  This operation computes the smallest normal subgroup of <group>
##  whose factor group is abelian of exponent dividing <integer>-1.

InstallMethod( AbelianExponentResidualOp, "solvable", true, 
  [IsGroup and IsFinite and IsSolvableGroup, IsPosInt], 0,
function( G, p )

  if CanEasilyComputePcgs(G) then
    return AbelianExponentResidualOp(G,p);
  fi;

  TryNextMethod();   # This can happen. E.g., SL(2,3)xGL(2,3).
end);

#############################################################################
#M  AbelianExponentResidualOp( <group>, <integer> )
##  This operation computes the smallest normal subgroup of <group>
##  whose factor group is abelian of exponent dividing <integer>-1.

InstallMethod( AbelianExponentResidualOp, "pcgs", true, 
  [IsGroup and IsFinite and CanEasilyComputePcgs, IsPosInt], 0,
function( G, p)
  local par, fac, gens, npcgs;

  # catch trivial case
  if Size( G ) = 1 then return G; fi;

  par := ParentPcgs(Pcgs(G));
  fac := Pcgs(G) mod InducedPcgs(par, DerivedSubgroup(G));
  gens := List(fac, x -> x^(p-1));
  npcgs := InducedPcgsByPcSequenceAndGenerators(par,
      DenominatorOfModuloPcgs(fac),gens);
  return SubgroupByPcgs(G,npcgs);
end);

#############################################################################
#M  AbelianExponentResidualOp( <group>, <integer> )
##  This operation computes the smallest normal subgroup of <group>
##  whose factor group is abelian of exponent dividing <integer>-1.

SubgpMethodByNiceMonomorphismCollOther( AbelianExponentResidualOp, 
  [IsGroup, IsPosInt] );

#E  End of exres.g
