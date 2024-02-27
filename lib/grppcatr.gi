#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for attributes of polycyclic groups.
##


#############################################################################
##
#M  AsSSortedList( <pcgrp> )
##
InstallMethod( AsSSortedListNonstored,"pcgs computable groups",true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],0,
function( grp )
    local   elms,  pcgs,  g,  u,  e,  i;

    elms := [ One(grp) ];
    pcgs := Pcgs(grp);

    for g  in pcgs  do
        u := One(grp);
        e := ShallowCopy(elms);
        for i  in [ 1 .. RelativeOrderOfPcElement(pcgs,g)-1 ]  do
            u := u * g;
            UniteSet( elms, e * u );
        od;
    od;

    return elms;

end );

InstallMethod( AsSSortedList,"pcgs computable groups",true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],0,
  AsSSortedListNonstored);

#############################################################################
##
#M  AsList(<G>)
##
InstallMethod(AsList,"pc group",true,[IsPcGroup],0,AsSSortedListNonstored);


#############################################################################
##
#M  CompositionSeries( <G> )
##
InstallMethod( CompositionSeries, "pcgs computable groups", true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ], 0,
function( G )
    local   pcgsG,  m,  S,  parent,  i,  igs,  U;

    # get a pcgs of <G>
    pcgsG := Pcgs(G);
    m     := Length(pcgsG);
    S     := [];

    # if <pcgsG> is induced use the parent
    parent := ParentPcgs(pcgsG);
    #if IsInducedPcgs(pcgsG)  then
    #    parent := ParentPcgs(pcgsG);
    #else
    #    parent := pcgsG;
    #fi;

    # compute the pcgs of the composition subgroups
    for i  in [ 1 .. m+1 ]  do
        igs := InducedPcgsByPcSequenceNC( parent, pcgsG{[i..m]} );
        U   := SubgroupByPcgs( G, igs );
        Add( S, U );
    od;

    # and return
    return S;

end );


#############################################################################
##
#M  DerivedSubgroup( <G> )
##
InstallMethod( DerivedSubgroup,
    "pcgs computable groups",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,

function( U )
    local   pcgsU,  parent,  C,  i,  j,  tmp;

    # compute the commutators of the elements of a pcgs
    pcgsU := Pcgs(U);
    parent := ParentPcgs( pcgsU );
    C := [];
    for i  in [ 1 .. Length(pcgsU) ]  do
        for j  in [ i+1 .. Length(pcgsU) ]  do
            AddSet( C, Comm( pcgsU[j], pcgsU[i] ) );
        od;
    od;

    # if <pcgsU> is induced use the parent
    tmp := InducedPcgsByGeneratorsNC( parent, C );
    C := SubgroupByPcgs( U, tmp );
    return C;
end);


#############################################################################
##
#M  ElementaryAbelianSeries( <G> )
##
InstallMethod( ElementaryAbelianSeries,
    "pcgs computable groups using `PcgsElementaryAbelianSeries'", true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ], 0,
  G->EANormalSeriesByPcgs(PcgsElementaryAbelianSeries(G)));


#############################################################################
##
#M  FrattiniSubgroup( <G> )
##
InstallMethod( FrattiniSubgroup,
    "pcgs computable groups using prefrattini and core",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,

function( G )
    G := Core( G, PrefrattiniSubgroup( G ) );
    Assert( 2, IsNilpotentGroup( G) );
    SetIsNilpotentGroup( G, true );
    return G;
end);


#############################################################################
##
#M  HallSubgroupOp( <G>, <pi> )
##
##  compute and use special pcgs of <G>.
##
InstallMethod( HallSubgroupOp,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite, IsList ],
    0,

function( G, pi )
    local spec, weights, gens, i, S;

    spec := SpecialPcgs( G );
    weights := LGWeights( spec );
    gens := [];
    for i in [1..Length(spec)] do
        if weights[i][3] in pi then Add( gens, spec[i] ); fi;
    od;
    gens := InducedPcgsByPcSequenceNC( spec, gens );
    S := SubgroupByPcgs( G, gens );
    return S;
end );

RedispatchOnCondition(HallSubgroupOp,true,[IsGroup,IsList],
  [IsGroup and IsSolvableGroup and CanEasilyComputePcgs and IsFinite,
  IsList ],0);


#############################################################################
##
#M  PrefrattiniSubgroup( <G> )
##
InstallMethod( PrefrattiniSubgroup,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,

function( G )
    local   spec,  first,  weights,  m,  pref,  i,  start,
            next,  p,  pcgsS,  pcgsN,  pcgsL,  mats,  modu,  rad,
            elms,  P;

    spec    := SpecialPcgs( G );
    first   := LGFirst( spec );
    weights := LGWeights( spec );
    m       := Length( spec );
    pref    := [];
    for i in [1..Length(first)-1] do
        start := first[i];
        next  := first[i+1];
        p     := weights[start][3];
        if weights[start][1] > 1 and weights[start][2] = 1 and
           next-start > 1 then

            pcgsS := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
            pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
            pcgsL := pcgsS mod pcgsN;

            mats  := LinearOperationLayer( spec, pcgsL );
            modu  := GModuleByMats( mats, GF(p) );
            rad   := MTX.BasisRadical( modu );
            elms  := List( rad, x -> PcElementByExponentsNC( pcgsL, x ) );
            Append( pref, elms );

        elif weights[start][2] > 1 then
            Append(pref, spec{[start..next-1]} );
        fi;
    od;
    pref := InducedPcgsByPcSequenceNC( spec, pref );
    P    := SubgroupByPcgs( G, pref );
    return P;
end);

#############################################################################
##
#M  IsFinite( <pcgrp> )
##
InstallMethod( IsFinite,
    "pcgs computable groups",
    true,
    [ IsGroup and CanEasilyComputePcgs ],
    0,
    grp -> not 0 in RelativeOrders( Pcgs( grp ) ) );
#T is this method necessary at all?


#############################################################################
##
#M  Size( <pcgrp> )
##
InstallMethod( Size, "pcgs computable groups", true,
    [ IsGroup and CanEasilyComputePcgs ], 0,

function( grp )
    local   ords;

    ords := RelativeOrders(Pcgs(grp));
    if 0 in ords  then
        return infinity;
    else
        return Product(ords);
    fi;
end );


#############################################################################
##
#M  SylowComplementOp( <G>, <p> )
##
##  compute and use special pcgs of <G>.
##
InstallMethod( SylowComplementOp,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite,
      IsPosInt ],
    80,

function( G, p )
    local   spec,  weights,  gens,  i,  S,  pi;

    spec := SpecialPcgs( G );
    weights := LGWeights( spec );
    gens := [];
    pi := [];
    for i in [1..Length(spec)] do
        if weights[i][3] <> p then
            Add( gens, spec[i] );
            AddSet( pi, weights[i][3] );
        fi;
    od;
    gens := InducedPcgsByPcSequenceNC( spec, gens );
    S := SubgroupByPcgs( G, gens );
    SetHallSubgroup( G, pi, S );
    if Length( pi ) = 1 then
        SetSylowSubgroup( G, pi[1], S );
    fi;
    return S;
end );

RedispatchOnCondition(SylowComplementOp,true,[IsGroup,IsPosInt],
  [IsGroup and IsSolvableGroup and CanEasilyComputePcgs and IsFinite,
  IsPosInt ],0);


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> )
##
##  compute and use special pcgs of <G>.
##
InstallMethod( SylowSubgroupOp,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite,
      IsPosInt ],
    100,

function( G, p )
    local   spec,  weights,  gens,  i,  S;

    spec := SpecialPcgs( G );
    weights := LGWeights( spec );
    gens := [];
    for i  in [1..Length(spec)]  do
        if weights[i][3] = p then Add( gens, spec[i] ); fi;
    od;
    gens := InducedPcgsByPcSequenceNC( spec, gens );
    S := SubgroupByPcgs( G, gens );
    if Size(S) > 1 then
        SetIsPGroup( S, true );
        SetPrimePGroup( S, p );
        SetHallSubgroup(G, [p], S);
    fi;
    return S;
end );


#############################################################################
##
#F  MaximalSubgroupClassesRepsLayer( <pcgs>, <layer> )
##
BindGlobal( "MaximalSubgroupClassesRepsLayer", function( pcgs, l )
    local first, weights, m, start, next, pcgsS, pcgsN, pcgsL, p, mats,
          modu, maxi, i, elms, sub, M, G;

    first   := LGFirst( pcgs );
    weights := LGWeights( pcgs );
    m       := Length( pcgs );
    start   := first[l];
    next    := first[l+1];
    G       := GroupOfPcgs( pcgs );

    # catch the trivial case
    if weights[start][2] <> 1 then
        return [];
    fi;

    pcgsS := InducedPcgsByPcSequenceNC( pcgs, pcgs{[start..m]} );
    pcgsN := InducedPcgsByPcSequenceNC( pcgs, pcgs{[next..m]} );
    pcgsL := pcgsS mod pcgsN;
    p     := weights[start][3];

    mats  := LinearOperationLayer( pcgs, pcgsL );
    modu  := GModuleByMats( mats,  GF(p) );
    maxi  := MTX.BasesMaximalSubmodules( modu );

    for i in [1..Length( maxi )] do
        maxi[i] := ShallowCopy( maxi[i] );
        TriangulizeMat( maxi[i] );
        elms := List( maxi[i], x -> PcElementByExponentsNC( pcgsL, x ) );
        sub  := Concatenation( pcgs{[1..start-1]}, elms, pcgsN );
        sub  := InducedPcgsByPcSequenceNC( pcgs, sub );
        M    := SubgroupByPcgs( G, sub );
        maxi[i] := M;
    od;
    return maxi;
end );


BindGlobal( "MAXSUBS_BY_PCGS", function( G )
    local spec, first, max, i, new;

    spec  := SpecialPcgs(G);
    first := LGFirst( spec );
    max   := [];
    for i in [1..Length(first)-1] do
        new := MaximalSubgroupClassesRepsLayer( spec, i );
        Append( max, new );
    od;
    return max;

end );

#############################################################################
##
#M  MaximalSubgroupClassReps( <G> )
##
InstallMethod( CalcMaximalSubgroupClassReps,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,
    MAXSUBS_BY_PCGS);

#fallback
InstallMethod( CalcMaximalSubgroupClassReps,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and IsSolvableGroup and IsFinite ],
    0,
    MAXSUBS_BY_PCGS);

#############################################################################
##
#M  MaximalSubgroups( <G> )
##
InstallMethod( MaximalSubgroups,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and HasFamilyPcgs and IsFinite ],
    0,

function( G )
    local spec, first, m, max, i, U, new, M;

    spec  := SpecialPcgs(G);
    first := LGFirst( spec );
    m     := Length( spec );
    max   := [];
    for i in [1..Length(first)-1] do
        U   := Subgroup( G, spec{[first[i]..m]} );
        new := MaximalSubgroupClassesRepsLayer( spec, i );
        for M in new do
            if IsNormal( G, M ) then
                Add( max, M );
            else
                Append( max, ConjugateSubgroups( U, M ) );
            fi;
        od;
    od;
    return max;

end );


#############################################################################
##
#M  ConjugacyClassesMaximalSubgroups( <G> )
##
#T InstallMethod( ConjugacyClassesMaximalSubgroups,
#T     "generic method for groups with pcgs",
#T    true,
#T    [ IsGroup and CanEasilyComputePcgs ],
#T    0,
#T
#T function( G )
#T    return List( MaximalSubgroupClassReps(G),
#T           x -> ConjugacyClassSubgroup( G, x ) );
#T end);


#############################################################################
##
#M  NormalMaximalSubgroups( <G> )
##
InstallMethod( NormalMaximalSubgroups,
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,

function( G )
    local   spec,  first,  weights,  max,  i,  new;

    spec    := SpecialPcgs( G );
    first   := LGFirst( spec );
    weights := LGWeights( spec );
    max     := [];
    for i in [1..Length(first)-1] do
        if weights[first[i]][1] = 1 then
            new := MaximalSubgroupClassesRepsLayer( spec, i );
            Append( max, new );
        fi;
    od;
    return max;

end );


#############################################################################
##
#M  MaximalNormalSubgroups( <G> )
##
InstallMethod( MaximalNormalSubgroups, "for abelian groups",
               [ IsGroup and IsAbelian ],
               # IsGroup and IsFinite ranks higher than IsGroup and IsAbelian,
               # so we have to increase the rank, otherwise the method for
               # normal subgroup computation is selected.
               {} -> RankFilter( IsGroup and IsFinite and IsAbelian )
               - RankFilter( IsGroup and IsAbelian ),
function( G )
    local Gf,     # FactorGroup of G
          hom,    # homomorphism from G to Gf
          MaxGf,  # MaximalNormalSubgroups of Gf
          AbInv;  # abelian invariants of G
    if not IsPcGroup(G) then
        AbInv := AbelianInvariants(G);
        if 0 in AbInv then
            # (p) is a maximal normal subgroup in Z for every prime p
            Error("number of maximal normal subgroups is infinity");
        else
            # convert it to an abelian PcGroup with same invariants
            hom := IsomorphismPcGroup(G);
            Gf := Image(hom);
            # for abelian groups all maximal normal subgroup are also
            # normal maximal subgroups and vice-versa
            MaxGf := NormalMaximalSubgroups(Gf);
            return List(MaxGf, N -> PreImage(hom, N));
        fi;
    else
        # for abelian groups all maximal normal subgroup are also
        # normal maximal subgroups and vice-versa
        # for abelian pc groups return all maximal subgroups
        # NormalMaximalSubgroups seems to omit some unnecessary checks,
        # hence faster than MaximalSubgroups
        return NormalMaximalSubgroups(G);
    fi;
end);

InstallMethod( MaximalNormalSubgroups, "for solvable groups",
              [ IsGroup and IsSolvableGroup ],
               # IsGroup and IsFinite ranks higher than
               # IsGroup and IsSolvableGroup, so we have to increase the
               # rank, otherwise the method for normal subgroup computation
               # is selected.
               {} -> RankFilter( IsGroup and IsFinite and IsSolvableGroup )
               - RankFilter( IsGroup and IsSolvableGroup ),
function( G )
    local Gf,     # FactorGroup of G
          hom,    # homomorphism from G to Gf
          MaxGf;  # MaximalNormalSubgroups of Gf
    # every maximal normal subgroup is above the derived subgroup
    hom := MaximalAbelianQuotient(G);
    Gf := Image(hom);
    # One would hope this is true
    SetIsAbelian(Gf, true);
    MaxGf := MaximalNormalSubgroups(Gf);
    return List(MaxGf, N -> PreImage(hom, N));
end);

RedispatchOnCondition( MaximalNormalSubgroups, true,
    [ IsGroup ],
    [ IsSolvableGroup ], 0);


#############################################################################
##
#F  ModifyMinGens( <pcgsG>, <pcgsS>, <pcgsL>, <min> )
##
BindGlobal( "ModifyMinGens", function( pcgs, pcgsS, pcgsL, min )
    local pcgsF, g, i, new, pcgsT;

    # set up
    pcgsF := pcgsS mod pcgsL;

    # try to modify mingens
    for g in pcgsF do
        for i in [1..Length( min )] do
            new := ShallowCopy( min );
            new[i] := min[i] * g;
            pcgsT := InducedPcgsByPcSequenceAndGenerators(pcgs, pcgsL, new);
            pcgsT := Pcgs( ZassenhausIntersection( pcgs, pcgsS, pcgsT ) );
            if Length( pcgsT ) > Length( pcgsL ) then
                min[i] := new[i];
                return;
            fi;
        od;
    od;

    # mingens cannot be modified - add new generator
    Add( min, pcgsF[1] );
end );

#############################################################################
##
#F  MinimalGensLayer( <pcgsG>, <pcgsS>, <pcgsN>, <min> )
##
BindGlobal( "MinimalGensLayer", function( pcgs, pcgsS, pcgsN, min )
    local series, pcgsL, pcgsU, pcgsV, pcgsM;

    series := [pcgsN];

    # set up
    pcgsL  := pcgsN;
    pcgsU  := InducedPcgsByPcSequenceAndGenerators( pcgs, pcgsN, min );
    pcgsV  := pcgsU;

    # loop
    while Length( pcgsU ) < Length( pcgs ) do

        # get intersection of V with layer
        pcgsM := Pcgs( ZassenhausIntersection( pcgs, pcgsS, pcgsV ) );
        if Length( pcgsM ) <> Length( pcgsL ) then
            Add( series, pcgsM );
        fi;
        pcgsL := Last(series);

        # modify minimal gens
        ModifyMinGens( pcgs, pcgsS, pcgsL, min );
        pcgsV := InducedPcgsByPcSequenceAndGenerators( pcgs, pcgsL, min );
        pcgsU := InducedPcgsByPcSequenceAndGenerators( pcgs, pcgsN, min );
        if Length( pcgs ) = Length( pcgsV ) then
            pcgsS := pcgsL;
            Remove(series);
        fi;
    od;
    return min;
end );

#############################################################################
##
#M  MinimalGeneratingSet( <G> )
##
InstallMethod( MinimalGeneratingSet,
    "pcgs computable groups using special pcgs",
    true, [ IsSolvableGroup and IsFinite and CanEasilyComputePcgs], 0,

function( G )
    local spec, weights, first, m, mingens, i, start, next, j,
          pcgsN, pcgsS;

    if IsTrivial(G)  then
        return [];
    fi;
    spec    := SpecialPcgs( G );
    weights := LGWeights( spec );
    first   := LGFirst( spec );
    m       := Length( spec );

    # the first head
    mingens := spec{[1..first[2]-1]};
    i := 2;
    while i <= Length( first ) -1 and
        weights[first[i]][1] = 1 and weights[first[i]][2] = 1 do
        start := first[i];
        next  := first[i+1];
        for j in [1..next-start]  do
            if j <= Length(mingens)  then
                mingens[j] := mingens[j] * spec[ start+j-1 ];
            else
                Add(mingens, spec[ start+j-1 ] );
            fi;
        od;
        i := i + 1;
    od;

    # the other heads
    while i <= Length( first ) -1 do
        if weights[first[i]][2] = 1 then
            start := first[i];
            next  := first[i+1];
            pcgsS := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
            pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
            mingens := MinimalGensLayer( spec, pcgsS, pcgsN, mingens );
        fi;
        i := i + 1;
    od;
    return Set(mingens);
end );

#############################################################################
##
#M  SmallGeneratingSet(<G>)
##
InstallMethod(SmallGeneratingSet,"using minimal generating set",true,
  [IsSolvableGroup and IsFinite and CanEasilyComputePcgs],0,
  MinimalGeneratingSet);

#############################################################################
##
#M  GeneratorsSmallest(<pcgrp>)
##
InstallMethod(GeneratorsSmallest,"group of pc words which is full family",
  true, [IsGroup and HasFamilyPcgs],0,
function(G)
local pcgs,gens,U,e,i,j,pa,ros,smallpcgs,exp;

  # the smallest generating system is obtained from the
  # family pcgs by throwing out redundant generators.
  pcgs:=InducedPcgsWrtFamilyPcgs(G);

  # normalize leading exponent to one
  pa  := ParentPcgs(pcgs);
  ros := RelativeOrders(pcgs);
  smallpcgs := [];
  for i  in [ 1 .. Length(pcgs) ]  do
      exp := LeadingExponentOfPcElement( pa, pcgs[i] );
      smallpcgs[i] := pcgs[i] ^ (1/exp mod ros[i]);
  od;


  # make entry 1 above the diagonal
  for i  in [ 1 .. Length(smallpcgs)-1 ]  do
      for j  in [ i+1 .. Length(smallpcgs) ]  do
          exp := ExponentOfPcElement( pa, smallpcgs[i], DepthOfPcElement(
              pa, smallpcgs[j] ) );
          if exp <> 1  then
              smallpcgs[i]:=smallpcgs[i]*smallpcgs[j]^(ros[j]-exp+1);
          fi;
      od;
  od;

  gens:=[];
  U:=TrivialSubgroup(G);
  for i in [1..Length(smallpcgs)] do
    e:=Product(smallpcgs{[1..i]});
    if not e in U then
      Add(gens,e);
      U:=ClosureGroup(U,e);
    fi;
  od;
  return gens;

end);


#############################################################################
##
#F  NextStepCentralizer( <gens>, <cent>, <pcgsF>, <field> )
##
BindGlobal( "NextStepCentralizer", function( gens, cent, pcgsF, field )
    local g, matlist, null;

    for g in gens do
        if Length( cent ) = 0 then return []; fi;
        matlist := List( cent, x -> ExponentsOfPcElement(pcgsF, Comm(x,g)));
        null := TriangulizedNullspaceMat(matlist*One(field));
        cent := List( null, x -> PcElementByExponentsNC(pcgsF, cent, x));
    od;

    return cent;
end );


#############################################################################
##
#F  GeneratorsCentrePGroup( <U> )
##
InstallGlobalFunction( GeneratorsCentrePGroup, function( U )
    local pcgs, spec, n, firs, p, field, ser, gens, cent, i, pcgsF;

    # catch the trivial case
    pcgs := Pcgs(U);
    if Length( pcgs ) = 0 then return []; fi;

    # set up series
    spec  := SpecialPcgs( U );
    n     := Length( spec );
    firs  := LGFirst( spec );
    p     := PrimePGroup( U );
    field := GF(p);
    ser   := List( firs, x ->
                   InducedPcgsByPcSequenceNC( spec, spec{[x..n]} ) );
    gens  := spec{[1..firs[2]-1]};
    cent  := gens;
    for i in [2..Length(ser)-1] do
        pcgsF := ser[i] mod ser[i+1];
        cent := NextStepCentralizer( gens, cent, pcgsF, field );
        Append( cent, AsList( pcgsF ) );
    od;
    return cent;
end );


#############################################################################
##
#F  CentrePcGroup( <G> )
##
InstallGlobalFunction (CentrePcGroup, function( G )
    local   spec,  first,  weights,  m,  primes,  cent,  i,  gens,
            start,  next,  p,  j,  field,  pcgsS,  pcgsN,  pcgsF,  q,
            U,  newgens,  matlist,  g,  conj,  expo,  order,  eigen,
            null,  n,  elm, r, ksi, large, pcgsH, H, oper;

    # get special pcgs
    spec    := SpecialPcgs( G );
    first   := LGFirst( spec );
    weights := LGWeights( spec );
    m       := Length( spec );

    # get primes and set up
    primes   := Set( weights, x -> x[3] );
    cent     := List( primes, x -> [] );

    # the first nilpotent factor
    i := 1;
    gens := [];
    while i <= Length( first ) - 1 and weights[first[i]][1] = 1 do
        start := first[i];
        next  := first[i+1];
        p     := weights[start][3];
        j     := Position( primes, p );
        if weights[start][2] = 1 then
            gens[j] := spec{[start..next-1]};
            cent[j] := spec{[start..next-1]};
        elif weights[start][3] = p then
            field   := GF(p);
            pcgsS   := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
            pcgsN   := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
            pcgsF   := pcgsS mod pcgsN;
            cent[j] := NextStepCentralizer( gens[j], cent[j], pcgsF, field );
            Append( cent[j], AsList( pcgsF ) );
        fi;
        i := i + 1;
    od;

    # the remaining layers
    while i <= Length( first ) - 1 do
        start := first[i];
        next  := first[i+1];
        q     := weights[start][3];
        field := GF(q);
        pcgsS := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
        pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
        pcgsF := pcgsS mod pcgsN;

        for j in [1..Length(primes)] do
            p := primes[j];
            if p = q and (weights[start][2] > 1 or Length( cent[j] ) > 0) then

                pcgsH := spec mod pcgsN;
                H := GroupByPcgs( pcgsH );
                gens := List(cent[j], x->MappedPcElement(x, pcgsH, Pcgs(H)));
                Append( gens, Pcgs(H){[start..next-1]} );

                # calculate centre of centF
                U    := Subgroup( H, gens );
                gens := GeneratorsCentrePGroup( U );
                gens := List( gens, x -> MappedPcElement(x,Pcgs(H),pcgsH));

                # get centralizer
                oper := spec{Filtered([1..start-1], x -> weights[x][2] = 1)};
                cent[j] := NextStepCentralizer( oper, gens, pcgsF, field );

            # case p <> q
            elif Length( cent[j] ) > 0 then
                # get operation of centF on M
                newgens := [];
                matlist := [];
                for g in cent[j] do
                    conj := List( pcgsF,
                            x -> ExponentsOfPcElement( pcgsF, x^g ) )
                            * One( field );
                    if conj = conj^0  then
                        AddSet( newgens, g );
                    else
                        Add( matlist, conj );
                    fi;
                od;
                cent[j] := Filtered( cent[j], g -> not g in newgens );

                if Length( matlist ) > 0  then

                    # get exponent of <cent[j]> mod N
                    expo := 1;
                    for g in cent[j] do
                        order := 1;
                        while SiftedPcElement( pcgsN, g ) <> Identity(G) do
                            g := g ^ p;
                            order := order * p;
                        od;
                        expo := Maximum( expo, order );
                    od;

                    # get splitting field
                    r := 1;
                    while EuclideanRemainder( q^r - 1, expo ) <> 0  do
                        r := r+1;
                    od;
                    if q^r >= 2^16 then
                        TryNextMethod();
                    fi;
                    large := GF(q^r);
                    ksi   := GeneratorsOfField(large)[1]^((q^r - 1) / expo);

                    # calculate simultaneous eigenvalues
                    eigen := SimultaneousEigenvalues( matlist, expo, ksi );

                    # solve system
                    null := BasisNullspaceModN( eigen, expo );

                    # calculate elements corresponding to null
                    for n in null do
                        elm := PcElementByExponentsNC( pcgsF, cent[j], n );
                        if elm <> Identity( G ) then
                            AddSet( newgens, elm );
                        fi;
                    od;
                fi;
                cent[j] := newgens;
            fi;
        od;
        i := i + 1;
    od;

   # return centre as direct product of p-parts
    G:= SubgroupNC( G, Concatenation( cent ) );
    Assert( 1, IsAbelian( G ) );
    SetIsAbelian( G, true );
    return G;
end);

#############################################################################
##
#M  Centre( <G> )
##

InstallMethod( Centre,
   "pcgs computable groups using special pcgs",
   [ IsGroup and CanEasilyComputePcgs and IsFinite ],
   CentrePcGroup);


#############################################################################
##
#M  OmegaSeries( G )
##
InstallMethod( OmegaSeries,
               "for p-groups",
               true,
               [IsGroup and CanEasilyComputePcgs and IsFinite],
               0,
function( G )
    local pcgs, cl, U, series, exp, sub, p, M;

    pcgs := Pcgs( G );
    if Length( pcgs ) = 0 then return [G]; fi;
    if Length( pcgs ) = 1 then return [G,TrivialSubgroup(G)]; fi;

    U      := TrivialSubgroup( G );
    series := [U];
    p      := PrimePGroup( G );
    cl     := ConjugacyClasses( G );
    exp    := 1;
    while Size( U ) < Size( G ) do
        sub := Filtered( cl, x -> Order( Representative( x ) ) = p ^ exp );
        sub := Concatenation( List( sub, AsList ) );
        sub := InducedPcgsByPcSequenceAndGenerators( pcgs, Pcgs(U), sub );
        M   := SubgroupByPcgs( G, sub );
        if Size( M ) > Size( U ) then
            Add( series, M );
        fi;
        U := M;
        exp := exp + 1;
    od;
    return Reversed( series );
end);

#############################################################################
##
#M  PCentralSeriesOp( <G>, <p> )  . . . . . .  . . . . . . <p>-central series
##
InstallMethod( PCentralSeriesOp,
    "method for pc groups and prime",
    true,
    [ IsPcGroup and IsFinite, IsPosInt ],
    0,

function( G, p )
    local spec, weig, firs, ser, int, i, t, s, w, sub, N;

    spec := SpecialPcgs(G);
    weig := LGWeights( spec );
    firs := LGFirst( spec );
    ser  := [G];
    int  := [];
    for i in [1..Length(firs)-1] do
        t := firs[i];
        s := firs[i+1];
        w := weig[t];
        if w[1] = 1 and w[3] = p then
            sub := Concatenation( int, spec{[s..Length(spec)]} );
            sub := InducedPcgsByPcSequenceNC( spec, sub );
            N := SubgroupByPcgs( G, sub );
            Add( ser, N );
        else
            Append( int, spec{[t..s-1]} );
        fi;
    od;
    return ser;
end );
