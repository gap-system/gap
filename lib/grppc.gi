#############################################################################
##
#W  grppc.gi                    GAP Library                      Frank Celler
#W                                                             & Bettina Eick
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for groups with a polycyclic collector.
##
Revision.grppc_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  CanonicalPcgsWrtFamilyPcgs( <grp> )
##
InstallMethod( CanonicalPcgsWrtFamilyPcgs,
    true,
    [ IsGroup and HasFamilyPcgs ],
    0,

function( grp )
    local   cgs;

    cgs := CanonicalPcgs( InducedPcgsWrtFamilyPcgs(grp) );
    if cgs = FamilyPcgs(grp)  then
        SetIsWholeFamily( grp, true );
    fi;
    return cgs;
end );


#############################################################################
##
#M  CanonicalPcgsWrtHomePcgs( <grp> )
##
InstallMethod( CanonicalPcgsWrtHomePcgs,
    true,
    [ IsGroup and HasHomePcgs ],
    0,

function( grp )
    return CanonicalPcgs( InducedPcgsWrtHomePcgs(grp) );
end );


#############################################################################
##
#M  InducedPcgsWrtFamilyPcgs( <grp> )
##
InstallMethod( InducedPcgsWrtFamilyPcgs,
    true,
    [ IsGroup and HasFamilyPcgs ],
    0,

function( grp )
    local   pa,  igs;

    pa := FamilyPcgs(grp);
    if HasPcgs(grp) and IsInducedPcgs(Pcgs(grp))  then
        if pa = ParentPcgs(Pcgs(grp))  then
            return Pcgs(grp);
        fi;
    fi;
    igs := InducedPcgsByGenerators( pa, GeneratorsOfGroup(grp) );
    if igs = pa  then
        SetIsWholeFamily( grp, true );
    fi;
    return igs;
end );


#############################################################################
##
#M  InducedPcgsWrtHomePcgs( <G> )
##
InstallMethod( InducedPcgsWrtHomePcgs, true, [ IsGroup ], 0,
    function( G )
    local   home;
    
    home := HomePcgs( G );
    if HasPcgs(G) and IsInducedPcgs(Pcgs(G))  then
        if IsIdenticalObj(home,ParentPcgs(Pcgs(G)))  then
            return Pcgs(G);
        fi;
    fi;
    return InducedPcgsByGenerators( home, GeneratorsOfGroup( G ) );
end );


#############################################################################
##
#M  InducedPcgs( <pcgs>,<G> )
##
InstallMethod( InducedPcgs, true, [ IsPcgs,IsGroup ], 0,
function(pcgs, G )
  if IsIdenticalObj(ParentPcgs(HomePcgs(G)),ParentPcgs(pcgs)) then
    return InducedPcgsWrtHomePcgs(G);
  else
    return InducedPcgsByGenerators( ParentPcgs(pcgs), GeneratorsOfGroup( G ) );
  fi;
end );


#############################################################################
##
#M  Pcgs( <G> )
##
InstallMethod( Pcgs, "fail if insolvable", true,
        [ HasIsSolvableGroup ], SUM_FLAGS,
    function( G )
    if not IsSolvableGroup( G )  then  return fail;
                                 else  TryNextMethod();  fi;
end );

#############################################################################
##
#M  Pcgs( <pcgrp> )
##
InstallMethod( Pcgs,
    true,
    [ IsGroup and HasFamilyPcgs ],
    0,
    InducedPcgsWrtFamilyPcgs );


InstallMethod( Pcgs,
    true,
    [ IsGroup and HasHomePcgs ],
    1,
    InducedPcgsWrtHomePcgs );


InstallMethod( Pcgs, "take induced pcgs", true,
    [ IsGroup and HasInducedPcgsWrtHomePcgs ], SUM_FLAGS,
    InducedPcgsWrtHomePcgs );

#############################################################################
##
#M  Pcgs( <whole-family-grp> )
##
InstallMethod( Pcgs,
    true,
    [ IsGroup and HasFamilyPcgs and IsWholeFamily ],
    0,

function( grp )
    return FamilyPcgs(grp);
end );

#############################################################################
##
#M  HomePcgs( <G> )
##
InstallMethod( HomePcgs, true, [ IsGroup ], 0, Pcgs );


#############################################################################
##
#M  GroupByRws Methods
##
InstallGroupByRwsMethod(
    IsPolycyclicCollector,
    IsObject,

function( rws, grp )
    SetFamilyPcgs( grp, DefiningPcgs( ElementsFamily(FamilyObj(grp)) ) );
    SetHomePcgs( grp, DefiningPcgs( ElementsFamily(FamilyObj(grp)) ) );
end );


#############################################################################
##
#M  Group Methods
##
InstallGroupMethod(
    IsList,
    IsPcGroup,

function( coll, grp )
    SetFamilyPcgs( grp, DefiningPcgs( FamilyObj( One(grp) ) ) );
    SetHomePcgs( grp, DefiningPcgs( FamilyObj( One(grp) ) ) );
end );


#############################################################################
##

#M  <elm> in <pcgrp>
##
InstallMethod( \in,
    "for pcgs computable groups",
    IsElmsColls,
    [ IsMultiplicativeElementWithInverse,
      IsGroup and HasFamilyPcgs and CanEasilyComputePcgs
    ],
    0,

function( elm, grp )
    return SiftedPcElement(InducedPcgsWrtFamilyPcgs(grp),elm) = One(grp);
end );


#############################################################################
##
#M  <pcgrp1> = <pcgrp2>
##
InstallMethod( \=,
    "pcgs computable groups using home pcgs",
    IsIdenticalObj,
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( left, right )
    if HomePcgs(left) <> HomePcgs(right)  then
        TryNextMethod();
    fi;
    return CanonicalPcgsWrtHomePcgs(left) = CanonicalPcgsWrtHomePcgs(right);
end );


#############################################################################
##
#M  <pcgrp1> = <pcgrp2>
##
InstallMethod( \=,
    "pcgs computable groups using family pcgs",
    IsIdenticalObj,
    [ IsGroup and HasFamilyPcgs,
      IsGroup and HasFamilyPcgs ],
    0,

function( left, right )
    if FamilyPcgs(left) <> FamilyPcgs(right)  then
        TryNextMethod();
    fi;
    return CanonicalPcgsWrtFamilyPcgs(left)
         = CanonicalPcgsWrtFamilyPcgs(right);
end );


#############################################################################
##
#M  IsSubgroup( <pcgrp>, <pcsub> )
##
InstallMethod( IsSubgroup,
    "pcgs computable groups",
    IsIdenticalObj,
    [ IsGroup and HasFamilyPcgs and CanEasilyComputePcgs,
      IsGroup ],
    0,

function( grp, sub )
    local   pcgs,  id,  g;

    pcgs := InducedPcgsWrtFamilyPcgs(grp);
    id   := One(grp);
    for g  in GeneratorsOfGroup(sub)  do
        if SiftedPcElement( pcgs, g ) <> id  then
            return false;
        fi;
    od;
    return true;

end );

#############################################################################
##
#M  SubgroupByPcgs( <G>, <pcgs> )
##
InstallMethod( SubgroupByPcgs, "subgroup with pcgs", 
               true, [IsGroup, IsPcgs], 0,
function( G, pcgs )
    local U;
    U := SubgroupNC( G, AsList( pcgs ) );
    SetPcgs( U, pcgs );
    if HasIsInducedPcgsWrtSpecialPcgs( pcgs ) and
       IsInducedPcgsWrtSpecialPcgs( pcgs ) and
       HasSpecialPcgs( G ) then
        SetInducedPcgsWrtSpecialPcgs( U, pcgs );
    fi;
    return U;
end);

#############################################################################
##

#F  VectorSpaceByPcgsOfElementaryAbelianGroup( <pcgs>, <f> )
##
InstallGlobalFunction( VectorSpaceByPcgsOfElementaryAbelianGroup, function( arg )
    local   pcgs,  dim,  field;

    pcgs := arg[1];
    dim  := Length( pcgs );
    if IsBound( arg[2] ) then
        field := arg[2];
    elif dim > 0 then 
        field := GF( RelativeOrderOfPcElement( pcgs, pcgs[1] ) );
    else
        Error("trivial vectorspace, need field \n");
    fi;
    return VectorSpace( field, IdentityMat( dim, field ) );
end );


#############################################################################
##
#F  LinearOperationLayer( <G>, <gens>, <pcgs>  )
##
InstallGlobalFunction( LinearOperationLayer, function( arg )
local gens, pcgs, V, field, linear;

    # catch arguments
    if Length( arg ) = 2 then
        if IsGroup( arg[1] ) then
            gens := GeneratorsOfGroup( arg[1] );
        elif IsPcgs( arg[1] ) then
            gens := AsList( arg[1] );
        else 
            gens := arg[1];
        fi;
        pcgs := arg[2];
    elif Length( arg ) = 3 then
        gens := arg[2];
        pcgs := arg[3];
    fi;

    # in case the layer is trivial
    if Length( pcgs ) = 0 then
        Error("pcgs is trivial - no field defined ");
    fi;

    # construct matrix rep
    field := GF( RelativeOrderOfPcElement( pcgs, pcgs[1] ) );
    V := IdentityMat(Length(pcgs),field);
    linear := function( x, g ) 
              return ExponentsOfPcElement( pcgs,
                     PcElementByExponents( pcgs, x )^g ) * One(field);
              end;
    return LinearOperation( gens, V, linear );
end );
    
#############################################################################
##
#F  AffineOperationLayer( <G>, <pcgs>, <transl> )
##
InstallGlobalFunction( AffineOperationLayer, function( arg )
    local gens, pcgs, transl, V, field, linear;

    # catch arguments
    if Length( arg ) = 3 then
        if IsPcgs( arg[1] ) then
            gens := AsList( arg[1] );
        elif IsGroup( arg[1] ) then
            gens := GeneratorsOfGroup( arg[1] );
        else
            gens := arg[1];
        fi;
        pcgs := arg[2];
        transl := arg[3];
    elif Length( arg ) = 4 then
        gens := arg[2];
        pcgs := arg[3];
        transl := arg[4];
    fi;
       
    # in the trivial case we cannot do anything
    if Length( pcgs ) = 0 then 
        Error("layer is trivial . . . field is not defined \n");
    fi;

    # construct matrix rep
    field := GF( RelativeOrderOfPcElement( pcgs, pcgs[1] ) );
    V:=IdentityMat(Length(pcgs),field);
    linear := function( x, g ) 
              return ExponentsOfPcElement( pcgs, 
                     PcElementByExponents( pcgs, x )^g ) * One(field);
              end;
    return AffineOperation( gens, V, linear, transl );
end );

#############################################################################
##
#M  AffineOperation( <gens>, <V>, <linear>, <transl> )
##
InstallMethod( AffineOperation,"generators",
    true, 
    [ IsList,
      IsMatrix,
      IsFunction,
      IsFunction ],
    0,

function( Ggens, V, linear, transl )
local mats, gens, zero,one, g, mat, i, vec;

    mats := [];
    gens:=V;
    zero:=Zero(V[1][1]);
    one:=One(zero);
    for g  in Ggens do
        mat := List( gens, x -> linear( x, g ) );
        vec := ShallowCopy( transl(g) );
        for i  in [ 1 .. Length(mat) ]  do
            mat[i] := ShallowCopy( mat[i] );
            Add( mat[i], zero );
        od;
        Add( vec, one );
        Add( mat, vec );
        Add( mats, mat );
    od;
    return mats;

end );

InstallOtherMethod( AffineOperation,"group",
    true, 
    [ IsGroup, 
      IsMatrix,
      IsFunction,
      IsFunction ],
    0,
function( G, V, linear, transl )
    return AffineOperation( GeneratorsOfGroup(G), V, linear, transl );
end );

InstallOtherMethod( AffineOperation,"group2",
    true, 
    [ IsGroup, 
      IsList,
      IsMatrix,
      IsFunction,
      IsFunction ],
    0,
function( G, gens, V, linear, transl )
    return AffineOperation( gens, V, linear, transl );
end );

InstallOtherMethod( AffineOperation,"pcgs",
    true, 
    [ IsPcgs, 
      IsMatrix,
      IsFunction,
      IsFunction ],
    0,
function( pcgsG, V, linear, transl )
    return AffineOperation( AsList( pcgsG ), V, linear, transl );
end );

#############################################################################
##
#M  ClosureGroup( <U>, <H> )
##
##  use home pcgs
##
InstallMethod( ClosureGroup,
    "groups with home pcgs",
    IsIdenticalObj, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( U, H )
    local   home,  pcgsU,  pcgsH,  new,  N;

    home := HomePcgs( U );
    if home <> HomePcgs( H ) then
        TryNextMethod();
    fi;
    pcgsU := InducedPcgs(home,U);
    pcgsH := InducedPcgs(home,H);
    if Length( pcgsU ) < Length( pcgsH )  then
        new := InducedPcgsByPcSequenceAndGenerators( home, pcgsH, 
               GeneratorsOfGroup( U ) );
    else
        new := InducedPcgsByPcSequenceAndGenerators( home, pcgsU,
               GeneratorsOfGroup( H ) );
    fi;
    N := Subgroup( GroupOfPcgs( home ), new );
    SetHomePcgs( N, home );
    SetInducedPcgsWrtHomePcgs( N, new );
    return N;

end );


#############################################################################
##
#M  ClosureGroup( <U>, <g> )
##
##  use home pcgs
##
InstallMethod( ClosureGroup,
    "groups with home pcgs",
    IsCollsElms,
    [ IsGroup and HasHomePcgs,
      IsMultiplicativeElementWithInverse ],
    0,

function( U, g )
    local   home,  pcgsU,  new,  N;

    home  := HomePcgs( U );
    pcgsU := InducedPcgsWrtHomePcgs( U );
    if not g in GroupOfPcgs( home ) then
        TryNextMethod();
    fi;
    if g in U  then
        return U;
    else
        new := InducedPcgsByPcSequenceAndGenerators( home, pcgsU, [g] );
        N   := Subgroup( GroupOfPcgs(home), new );
        SetHomePcgs( N, home );
        SetInducedPcgsWrtHomePcgs( N, new );
        return N;
    fi;

end );


#############################################################################
##
#M  CommutatorSubgroup( <U>, <V> )
##
InstallMethod( CommutatorSubgroup,
    "groups with home pcgs",
    true, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( U, V )
    local   pcgsU,  pcgsV,  home,  C,  u,  v;

    # check 
    home := HomePcgs(U);
    if home <> HomePcgs( V ) then
        TryNextMethod();
    fi;
    pcgsU := InducedPcgsWrtHomePcgs(U);
    pcgsV := InducedPcgsWrtHomePcgs(V);

    # catch trivial cases
    if Length(pcgsU) = 0 or Length(pcgsV) = 0  then
        return TrivialSubgroup( GroupOfPcgs(home) );
    fi;
    if U = V  then
        return DerivedSubgroup(U);
    fi;

    # compute commutators
    C := [];
    for u  in pcgsU  do
        for v  in pcgsV  do
            AddSet( C, Comm( v, u ) );
        od;
    od;
    C := Subgroup( GroupOfPcgs( home ), C );
    C := NormalClosure( ClosureGroup(U,V), C );

    # that's it
    return C;

end );


#############################################################################
##
#M  ConjugateGroup( <U>, <g> )
##
InstallMethod( ConjugateGroup,
    "groups with home pcgs",
    IsCollsElms,
    [ IsGroup and HasHomePcgs,
      IsMultiplicativeElementWithInverse ],
    0,

function( U, g )
    local   home,  pcgs,  id,  pag,  h,  d,  N;

    # <g> must lie in the home
    home := HomePcgs(U);
    if not g in GroupOfPcgs(home)  then
        TryNextMethod();
    fi;

    # shift <g> through <U>
    pcgs := InducedPcgsWrtHomePcgs( U );
    id   := Identity( U );
    g    := SiftedPcElement( pcgs, g );

    # catch trivial case
    if IsEmpty(pcgs) or g = id then
        return U;
    fi;

    # conjugate generators
    pag := [];
    for h  in Reversed( pcgs ) do
        h := h ^ g;
        d := DepthOfPcElement( home, h );
        while h <> id and IsBound( pag[d] )  do
            h := ReducedPcElement( home, h, pag[d] );
            d := DepthOfPcElement( home, h );
        od;
        if h <> id  then
            pag[d] := h;
        fi;
    od;

    # <pag> is an induced system
    pag := Compacted( pag );
    N   := Subgroup( GroupOfPcgs(home), pag );
    SetHomePcgs( N, home );
    pag := InducedPcgsByPcSequenceNC( home, pag );
    SetInducedPcgsWrtHomePcgs( N, pag );

    # maintain useful information
    UseIsomorphismRelation( U, N );

    return N;

end );


#############################################################################
##
#M  ConjugateSubgroups( <G>, <U> )
##
InstallMethod( ConjugateSubgroups, 
    "groups with home pcgs",
    IsIdenticalObj, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( G, U )
    local pcgs, home, f, orb, i, L, res;

    # check the home pcgs are compatible
    home := HomePcgs(U);
    if home <> HomePcgs(G) then
        TryNextMethod();
    fi;

    # get a canonical pcgs for <U>
    pcgs := CanonicalPcgsWrtHomePcgs(U);

    # <G> operates on this <pcgs> via conjugation
    f := function( c, g )
        return CanonicalPcgs( HomomorphicInducedPcgs( home, c, g ) );
    end;

    # compute the orbit of <G> on <pcgs>
    orb := Orbit( G, pcgs, f );
    res := List( orb, x -> false );
    for i in [1..Length(orb)] do
        L := Subgroup( G, orb[i] );
        SetHomePcgs( L, home );
        SetInducedPcgsWrtHomePcgs( L, orb[i] );
        res[i] := L;
    od;
    return res;

end );


#############################################################################
##
#M  Core( <U>, <V> )
##
InstallMethod( CoreOp,
    "pcgs computable groups",
    true, 
    [ IsGroup and CanEasilyComputePcgs,
      IsGroup ],
    0,

function( V, U )
    local pcgsV, C, v, N;

    # catch trivial cases
    pcgsV := Pcgs(V);
    if IsSubgroup( U, V ) or IsTrivial(U) or IsTrivial(V)  then
        return U;
    fi;

    # start with <U>.
    C := U;

    # now  compute  intersection with all conjugate subgroups, conjugate with
    # all generators of V and its powers

    for v  in Reversed(pcgsV)  do
        repeat
            N := ConjugateSubgroup( C, v );
            if C <> N  then
                C := Intersection( C, N );
            fi;
        until C = N;
        if IsTrivial(C)  then
            return C;
        fi;
    od;
    return C;

end );


#############################################################################
##
#M  EulerianFunction( <G>, <n> )
##
InstallMethod( EulerianFunction,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and CanEasilyComputePcgs,
      IsPosInt ],
    0,

function( G, n )
    local   spec,  first,  weights,  m,  i,  phi,  start,  
            next,  p,  d,  r,  j,  pcgsS,  pcgsN,  pcgsL,  mats,  
            modu,  max,  series,  comps,  sub,  new,  index,  order;

    spec := SpecialPcgs( G );
    if Length( spec ) = 0 then
        return 1;
    fi;
    first := LGFirst( spec );
    weights := LGWeights( spec );
    m := Length( spec );

    # the first head
    i := 1;
    phi := 1;
    while weights[first[i]][1] = 1 and weights[first[i]][2] = 1 do
        start := first[i];
        next  := first[i+1];
        p     := weights[start][3];
        d     := next - start;
        r     := Length( Filtered( weights, x -> x[1] = 1 and x[3] = p ) );
        phi   := phi * p^( n * ( r - d ) ); 
        for j in [0..d-1] do
            phi := phi * (p^n - p^j);
        od;
        if phi = 0 then return 0; fi;
        i := i + 1;
    od;

    # the rest
    while i <= Length( first ) - 1 do
        start := first[i];
        next  := first[i+1];
        p := weights[start][3];
        d := next - start;
        if weights[start][2] = 1 then
            pcgsS := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
            pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
            pcgsL := pcgsS mod pcgsN;
            mats  := LinearOperationLayer( spec, pcgsL );
            modu  := GModuleByMats( mats,  GF(p) );
            max   := MTX.BasesMaximalSubmodules( modu );
            
            # compute series
            series := [IdentityMat(d, GF(p))];
            comps  := [];
            sub    := series[1];
            while Length( max ) > 0 do
                sub := SumIntersectionMat( sub, max[1] )[2];
                if Length( sub ) = 0 then
                    new := max;
                else
                    new := Filtered( max, x -> 
                                  RankMat( Concatenation( x, sub ) ) < d );
                fi;
                Add( comps, Sum( List( new, x -> p^(d - Length(x)) ) ) ); 
                Add( series, sub );
                max := Difference( max, new );
            od;

            # run down series
            for j in [1..Length( series )-1] do
                index := Length( series[j] ) - Length( series[j+1] );
                order := p^index;
                phi   := phi * ( order^n - comps[j] );
                if phi = 0 then return phi; fi;
            od;

            # only the radical is missing now
            index := Length( series[Length(series)] );
            order := p^index;
            phi := phi * (order^n);
            if phi = 0 then return 0; fi;
        else
            order := p^d;
            phi := phi * ( order^n );
            if phi = 0 then return 0; fi;
        fi;
        i := i + 1;
    od;
    return phi;

end );


#############################################################################
##
#M  LinearOperation( <gens>, <basisvectors>, <linear>  )
##
InstallMethod( LinearOperation,
    true, 
    [ IsList,
      IsMatrix,
      IsFunction ],
    0,

function( gens, base, linear )
    local  mats;

    # catch trivial cases
    if Length( gens ) = 0 then 
        return [];
    fi;

    # compute matrices
    mats := List( gens, x -> List( base, y -> linear( y, x ) ) );
    return mats;

end );

InstallOtherMethod( LinearOperation,
    true, 
    [ IsGroup, 
      IsMatrix,
      IsFunction ],
    0,

function( G, base, linear )
    return LinearOperation( GeneratorsOfGroup( G ), base, linear );
end );

InstallOtherMethod( LinearOperation,
    true, 
    [ IsPcgs, 
      IsMatrix,
      IsFunction ],
    0,

function( pcgs, base, linear )
    return LinearOperation( pcgs, base, linear );
end );

InstallOtherMethod( LinearOperation,
    true, 
    [ IsGroup, 
      IsList,
      IsMatrix,
      IsFunction ],
    0,

function( G, gens, base, linear )
    return LinearOperation( gens, base, linear );
end );


#############################################################################
##
#M  NormalClosure( <G>, <U> )
##
InstallMethod( NormalClosureOp,
    "groups with home pcgs",
    true, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( G, U )
    local   pcgs,  home,  gens,  subg,  id,  K,  M,  g,  u,  tmp;

    # catch trivial case
    pcgs := InducedPcgsWrtHomePcgs(U);
    if Length(pcgs) = 0 then
        return U;
    fi;
    home := HomePcgs(U);
    if home <> HomePcgs(G) then 
        TryNextMethod();
    fi;

    # get operating elements
    gens := GeneratorsOfGroup( G );
    gens := Set( List( gens, x -> SiftedPcElement( pcgs, x ) ) );

    subg := GeneratorsOfGroup( U );
    id   := Identity( G );
    K    := ShallowCopy( pcgs );
    repeat
        M := [];
        for g  in gens  do
            for u  in subg  do
                tmp := Comm( g, u );
                if tmp <> id  then
                    AddSet( M, tmp );
                fi;
            od;
        od;
        tmp  := InducedPcgsByPcSequenceAndGenerators( home, K, M );
        tmp  := CanonicalPcgs( tmp );
        subg := Filtered( tmp, x -> not x in K );
        K    := tmp;
    until 0 = Length(subg);

    K := Subgroup( GroupOfPcgs(home), tmp );
    SetHomePcgs( K, home );
    SetInducedPcgsWrtHomePcgs( K, tmp );
    return K;

end );


#############################################################################
##
#M  Random( <pcgrp> )
##
InstallMethod( Random,
    "pcgs computable groups",
    true,
    [ IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,

function(grp)
    local   p;

    p := Pcgs(grp);
    if Length( p ) = 0 then 
        return One( grp );
    else
        return Product( p, x -> x^Random(1,RelativeOrderOfPcElement(p,x)) );
    fi;
end );

CentralizerSolvableGroup:=function(H,U,elm)
local  G,  home,  # the supergroup (of <H> and <U>), the home pcgs
       Upcgs,    # induced Pcgs of U
       Hp,    # a pcgs for <H>
       inequal,	# G<>H flag
       eas,     # elementary abelian series in <G> through <U>
       step,    # counter looping over <eas>
       K,  L,   # members of <eas>
       Kp,Lp, # induced and modulo pcgs's
       KcapH,LcapH, # pcgs's of intersections with <H>
       N,   cent,   # elementary abelian factor, for affine action
       cls,  # classes in range/source of homomorphism
       opr,     # (elm^opr)=cls.representative
       p,       # prime dividing $|G|$
       ord;     # order of a rational class modulo <L>

  # Treat the case of a trivial group.
  if IsTrivial( U )  then
    return H;
  fi;
  
  if H=U then
    G:=H;
    inequal:=false;
  else
    G:=ClosureGroup( H, U );
    inequal:=true;
  fi;

  home:=HomePcgs(G);
  # Calculate a (central)  elementary abelian series  with all pcgs induced
  # w.r.t. <home>.

  if IsPrimePowerInt( Size( G ) )  then
    p:=FactorsInt( Size( G ) )[ 1 ];
    home:=PcgsCentralSeries(G);
    eas:=NormalSeriesByPcgs(home);
    cent:=ReturnTrue;
  else
    home:=PcgsElementaryAbelianSeries(G);
    eas:=NormalSeriesByPcgs(home);
    cent:=function( cl, N, L )
      return ForAll( N, k -> ForAll
        ( InducedPcgs( home,cl.centralizer ),
#T  was: Only those elements form the induced PCGS. The subset seemed to
#T enforce taking only the elements up, but the ordering of the series used
#T may be different then the ordering in the PCGS. So this will fail. AH
#T one might pick the right ones, but this would be almost the same work.
#T { [ 1 .. Length( InducedPcgsWrtHomePcgs( cl.centralizer ) )
#T - Length( InducedPcgsWrtHomePcgs( L ) ) ] },
           c -> Comm( k, c ) in L ) );
    end;
  fi;

  Upcgs:=InducedPcgs(home,U);
  Hp:=InducedPcgs(home,H);

  # Initialize the algorithm for the trivial group.
  step:=1;
  while IsSubset( eas[ step + 1 ], U )  do
    step:=step + 1;
  od;
  L :=eas[ step ];
  Lp:=InducedPcgs(home,L);
  if inequal then
    LcapH:=NormalIntersectionPcgs( home, Hp, Lp );
  fi;

  cls:=[rec( representative:=elm,centralizer:=H )];
  opr:=One( U );

  # Now go back through the factors by all groups in the elementary abelian
  # series.
  for step  in [ step + 1 .. Length( eas ) ]  do

    # We apply the homomorphism principle to the homomorphism G/L -> G/K.
    # The  actual   computations  are all  done   in <G>,   factors are
    # represented by modulo pcgs.
    K :=L;
    Kp:=Lp;
    L :=eas[ step ];
    Lp:=InducedPcgs(home,L );
    N :=Kp mod Lp;  # modulo pcgs representing the kernel

#    #T What is this? Obviously it is needed somewhere, but it is
#    #T certainly not good programming style. AH
#    SetFilterObj( N, IsPcgs );

    if inequal then
      KcapH  :=LcapH;
      LcapH  :=NormalIntersectionPcgs( home, Hp, Lp );
      N!.capH:=KcapH mod LcapH;
      #T See above
#      SetFilterObj( N!.capH, IsPcgs );
    else
      N!.capH:=N;
    fi;
    
    cls[ 1 ].candidates:=cls[ 1 ].representative;
    if cent( cls[ 1 ], N, L )  then
      cls:=CentralStepClEANS( home,H, U, N, cls[ 1 ] );
    else
      cls:=GeneralStepClEANS( home,H, U, N, cls[ 1 ] );
    fi;
    opr:=opr * cls[ 1 ].operator;

  od;

  return ConjugateSubgroup( cls[ 1 ].centralizer, opr ^ -1 );

end;


#############################################################################
##
#M  Centralizer( <G>, <g> ) . . . . . . . . . . . . . .  using affine methods
##
InstallMethod( CentralizerOp,
    "pcgs computable group and element",
    IsCollsElms,
    [ IsGroup and CanEasilyComputePcgs and IsFinite,
      IsMultiplicativeElementWithInverse ],
    0,  # in solvable permutation groups, backtrack seems preferable
        
function( G, g )
    return CentralizerSolvableGroup( G, Group( g ), g );
end );

InstallMethod( CentralizerOp,
    "pcgs computable groups",
    IsIdenticalObj,
    [ IsGroup and CanEasilyComputePcgs and IsFinite,
      IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,  # in solvable permutation groups, backtrack seems preferable

function( G, H )
    local   h;
    
    for h  in MinimalGeneratingSet( H )  do
        G := CentralizerSolvableGroup( G, H, h );
    od;
    return G;
end );

#############################################################################
##
#M  RepresentativeOperation( <G>, <d>, <e>, OnPoints )   using affine methods
##
InstallOtherMethod( RepresentativeOperationOp,
    "element conjugacy in pcgs computable groups", IsCollsElmsElmsX,
    [ IsGroup and CanEasilyComputePcgs and IsFinite,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse,
      IsFunction ],
    0,

function( G, d, e, opr )
    if opr <> OnPoints or not (IsPcGroup(G) or (d in G and e in G)) then
        TryNextMethod();
    fi;
    return ClassesSolvableGroup( G, 4,rec(candidates:= [ d, e ] ));
end );

#############################################################################
##
#M  CentralizerModulo(<H>,<N>,<elm>)   full preimage of C_(H/N)(elm.N)
##
InstallMethod(CentralizerModulo,"pcgs computable groups, for elm",
  IsCollsCollsElms,[IsGroup and CanEasilyComputePcgs, IsGroup and
  CanEasilyComputePcgs, IsMultiplicativeElementWithInverse],0,
function(H,NT,elm)
local G,	   # common parent
      home,Hp,     # the home pcgs, induced pcgs
      eas, step,   # elementary abelian series in <G> through <U>
      ea2,	   # used for factor series
      K,    L,     # members of <eas>
      Kp,mK,Lp,    # induced and modulo pcgs's
      KcapH,LcapH, # pcgs's of intersections with <H>
      N,   cent,   # elementary abelian factor, for affine action
      tra,         # transversal for candidates
      team,        # team of candidates with same image under homomorphism
      blist,pos,q, # these control grouping of <cls> into <team>s
      p,           # prime dividing $|G|$
      ord,         # order of a rational class modulo <modL>
      new, power,  # auxiliary variables for determination of power tree
      cl,  c,  i;  # loop variables

    # Treat trivial cases.
    if Index(H,NT)=1 or (HasAbelianFactorGroup(H,NT) and elm in H)
     or elm in NT then
      return H;
    fi;

    if elm in H then 
      G:=H;
    else
      G:=ClosureGroup(H,elm);
    fi;

    home := HomePcgs( G );

    # Calculate a (central) elementary abelian series.

    if IsPrimePowerInt( Size( G ) )  then
        p := FactorsInt( Size( G ) )[ 1 ];
	home:=PcgsCentralSeries(G);
	eas:=NormalSeriesByPcgs(home);
        cent := ReturnTrue;
    else
	home:=PcgsElementaryAbelianSeries(G);
	eas:=NormalSeriesByPcgs(home);
        cent := function( cl, N, L )
            return ForAll( N, k -> ForAll
              ( InducedPcgs( home,cl.centralizer )
                   { [ 1 .. Length( InducedPcgs(home, cl.centralizer ) )
                          - Length( InducedPcgs(home, L ) ) ] },
                   c -> Comm( k, c ) in L ) );
        end;
    fi;

    # series to NT
    ea2:=List(eas,i->ClosureGroup(NT,i));
    eas:=[];
    for i in ea2 do
      if not i in eas then
	Add(eas,i);
      fi;
    od;

    Hp:=InducedPcgs(home,H);

    # Initialize the algorithm for the trivial group.
    step := 1;
    while IsSubset( eas[ step + 1 ], H )  do
        step := step + 1;
    od;
    L  := eas[ step ];
    Lp := InducedPcgs(home, L );
    if not IsIdenticalObj( G, H )  then
        LcapH := NormalIntersectionPcgs( home, Hp, Lp );
    fi;

    cl := rec( representative := elm,
		  centralizer := H );
    tra := One( H );

#    cls := List( candidates, c -> cl );
#    tra := List( candidates, c -> One( H ) );
    tra:=One(H);
    
    # Now go back through the factors by all groups in the elementary abelian
    # series.
    for step  in [ step + 1 .. Length( eas ) ]  do
        K  := L;
        Kp := Lp;
        L  := eas[ step ];
        Lp := InducedPcgs(home, L );
        N  := Kp mod Lp;
        SetFilterObj( N, IsPcgs );
	if not IsIdenticalObj( G, H )  then
	  KcapH   := LcapH;
	  LcapH   := NormalIntersectionPcgs( home, Hp, Lp );
	  N!.capH := KcapH mod LcapH;
        else
	  N!.capH := N;
        fi;
    
	cl.candidates := cl.representative;
	if cent( cl, N, L )  then
	    cl := CentralStepClEANS( home,G, H, N, cl )[1];
	else
	    cl := GeneralStepClEANS( home,G, H, N, cl )[1];
	fi;
	tra := tra * cl.operator;
	
    od;

    cl:=ConjugateSubgroup( cl.centralizer, tra ^ -1 );
    Assert(2,ForAll(GeneratorsOfGroup(cl),i->Comm(elm,i) in NT));
    Assert(2,IsSubgroup(G,cl));
    return cl;

end);

InstallMethod(CentralizerModulo,"group centralizer via generators",
  IsFamFamFam,[IsGroup and CanEasilyComputePcgs, IsGroup and
  CanEasilyComputePcgs, IsGroup],0,
function(G,NT,U)
local i;
  for i in GeneratorsOfGroup(U) do
    G:=CentralizerModulo(G,NT,i);
  od;
  return G;
end);

#############################################################################
##
#F  ElementaryAbelianSeries( <list> )
##
InstallOtherMethod( ElementaryAbelianSeries,"list of pcgs computable groups",
  true,[IsList],10, # there is a generic groups function with value 0
function( S )
local   home,i,  N,  O,  I,  E,  L;

  if Length(S)=0 or not CanEasilyComputePcgs(S[1]) then 
    TryNextMethod();
  fi;

  # typecheck arguments
  if 1 < Size(S[Length(S)])  then
      S := ShallowCopy( S );
      Add( S, TrivialSubgroup(S[1]) );
  fi;

  # start with the elementary series of the first group of <S>
  L := ElementaryAbelianSeries( S[ 1 ] );
  # enforce the same parent for 'HomePcgs' purposes.
  home:=HomePcgs(S[1]);

  N := [ S[ 1 ] ];
  for i  in [ 2 .. Length( S ) - 1 ]  do
    O := L;
    L := [ S[ i ] ];
    for E  in O  do
      I := IntersectionSumPcgs(home, InducedPcgs(home,E),
	InducedPcgs(home,S[ i ]) );
      I.sum:=SubgroupNC(S[1],I.sum);
      I.intersection:=SubgroupNC(S[1],I.intersection);
      if not I.sum in N  then
	  Add( N, I.sum );
      fi;
      if not I.intersection in L  then
	  Add( L, I.intersection );
      fi;
    od;
  od;
  for E  in L  do
      if not E in N  then
	  Add( N, E );
      fi;
  od;

  # remove spurious factors
  L:=[N[1]];
  I:=N[1];
  i:=2;
  repeat
    while i<Length(N) and HasElementaryAbelianFactorGroup(I,N[i+1]) 
      and (IsIdenticalObj(I,N[i]) or not N[i] in S) do
      i:=i+1;
    od;
    I:=N[i];
    Add(L,I);
  until Size(I)=1;

  # return it.
  return L;

end);

#############################################################################
##
#M  \<(G,H) . . . . . . . . . . . . . . . . .  comparison of pc groups by CGS
##
InstallMethod(\<,"cgs comparison",IsIdenticalObj,[IsPcGroup,IsPcGroup],0,
function( G, H )
  return Reversed( CanonicalPcgsWrtFamilyPcgs(G) ) 
       < Reversed( CanonicalPcgsWrtFamilyPcgs(H) );
end);

#############################################################################
##
#F  GapInputPcGroup( <U>, <name> )  . . . . . . . . . . . .  gap input string
##
##  Compute  the  pc-presentation for a finite polycyclic group as gap input.
##  Return  this  input  as  string.  The group  will  be  named  <name>,the
##  generators "g<i>".
##
InstallGlobalFunction( GapInputPcGroup, function(U,name)

    local   gens,
            wordString,
            newLines,
            lines,
	    ne,
            i,j;


    # <lines>  will  hold  the  various  lines of the input for gap,they are
    # concatenated later.
    lines:=[];

    # Get the generators for the group <U>.
    gens:=InducedPcgsWrtHomePcgs(U);

    # Initialize the group and the generators.
    Add(lines,name);
    Add(lines,":=function()\nlocal ");
    for i in [1 .. Length(gens)]  do
        Add(lines,"g");
        Add(lines,String(i));
        Add(lines,",");
    od;
    Add(lines,"r,f,g,rws,x;\n");
    Add(lines,"f:=FreeGroup(");
    Add(lines,String(Length(gens)));
    Add(lines,");\ng:=GeneratorsOfGroup(f);\n");

    for i  in [1 .. Length(gens)]  do
        Add(lines,"g"          );
        Add(lines,String(i)  );
        Add(lines,":=g[");
        Add(lines,String(i)  );
        Add(lines,"];\n"    );
    od;

    Add(lines,"rws:=SingleCollector(f,");
    Add(lines,String(List(gens,i->RelativeOrderOfPcElement(gens,i))));
    Add(lines,");\n");

    Add(lines,"r:=[\n");
    # A function will yield the string for a word.
    wordString:=function(a)
        local k,l,list,str,count;
        list:=ExponentsOfPcElement(gens,a);
        k:=1;
        while k <= Length(list) and list[k] = 0  do k:=k + 1;  od;
        if k > Length(list)  then return "IdWord";  fi;
        if list[k] <> 1  then
            str:=Concatenation("g",String(k),"^",
                String(list[k]));
        else
            str:=Concatenation("g",String(k));
        fi;
        count:=Length(str) + 15;
        for l  in [k + 1 .. Length(list)]  do
            if count > 60  then
                str  :=Concatenation(str,"\n    ");
                count:=4;
            fi;
            count:=count - Length(str);
            if list[l] > 1  then
                str:=Concatenation(str,"*g",String(l),"^",
                    String(list[l]));
            elif list[l] = 1  then
                str:=Concatenation(str,"*g",String(l));
            fi;
            count:=count + Length(str);
        od;
        return str;
    end;

    # Add the power presentation part.
    for i  in [1 .. Length(gens)]  do
      ne:=gens[i]^RelativeOrderOfPcElement(gens,gens[i]);
      if ne<>One(U) then
        Add(lines,Concatenation("[",String(i),",",
            wordString(ne),"]"));
	if i<Length(gens) then
	  Add(lines,",\n");
	else
	  Add(lines,"\n");
	fi;
      fi;
    od;
    Add(lines,"];\nfor x in r do SetPower(rws,x[1],x[2]);od;\n");

    Add(lines,"r:=[\n");

    # Add the commutator presentation part.
    for i  in [1 .. Length(gens) - 1]  do
        for j  in [i + 1 .. Length(gens)]  do
	  ne:=Comm(gens[j],gens[i]);
	  if ne<>One(U) then
            if i <> Length(gens) - 1 or j <> i + 1  then
                Add(lines,Concatenation("[",String(j),",",String(i),",",
                    wordString(ne),"],\n"));
            else
                Add(lines,Concatenation("[",String(j),",",String(i),",",
                    wordString(ne),"]\n"));
            fi;
         fi;
       od;
    od;
    Add(lines,"];\nfor x in r do SetCommutator(rws,x[1],x[2],x[3]);od;\n");
    Add(lines,"return GroupByRwsNC(rws);\n");
    Add(lines,"end;\n");
    Add(lines,name);
    Add(lines,":=");
    Add(lines,name);
    Add(lines,"();\n");
    Add(lines,"Print(\"A group of order \",Size(");
    Add(lines,name);
    Add(lines,"),\" has been defined.\\n\");\n");
    Add(lines,"Print(\"It is called ");
    Add(lines,name);
    Add(lines,"\\n\");\n");

    # Concatenate all lines and return.
    while Length(lines) > 1  do
        if Length(lines) mod 2 = 1  then
            Add(lines,"");
        fi;
        newLines:=[];
        for i  in [1 .. Length(lines) / 2]  do
            newLines[i]:=Concatenation(lines[2*i-1],lines[2*i]);
        od;
        lines:=newLines;
    od;
    IsString(lines[1]);
    return lines[1];

end );

#############################################################################
##
#M  Enumerator( <G> ) . . . . . . . . . . . . . . . . . .  enumerator by pcgs
##
InstallMethod( Enumerator, true,
        [ IsGroup and CanEasilyComputePcgs and IsFinite ], 0,
    G -> EnumeratorByPcgs( Pcgs( G ), [ 1 .. Length( Pcgs( G ) ) ] ) );

InstallMethod(KnowsHowToDecompose,"pc group: always true",IsIdenticalObj,
  [IsPcGroup,IsList],0,ReturnTrue);

InstallOtherMethod(KnowsHowToDecompose,"pc group: always true",true,
  [IsPcGroup],0,ReturnTrue);


#############################################################################
##
#F  CanonicalSubgroupRepresentativePcGroup( <G>, <U> )
##
InstallGlobalFunction( CanonicalSubgroupRepresentativePcGroup,
    function(G,U)
local e,	# EAS
      pcgs,     # himself
      home,	# homepcgs
  #   hom,	# isomorphism to EAS group
      start,	# index of largest abelian quotient
      i,	# loop
      n,	# e[i]
      m,        # e[i+1]
      V,	# canon. rep
      fv,	# <V,m>
      no,	# its normalizer
      orb,rep,	# orbit, repres.
      o,	# orb index
      nno,	# growing normalizer
      min,
      minrep,	# minimum indicator
  #   p,	# orbit pos.
      ce;	# conj. elm

  if not IsSubgroup(G,U) then
    Error("#W  CSR Closure\n");
    G:=Subgroup(Parent(G),Concatenation(GeneratorsOfGroup(G),
                                        GeneratorsOfGroup(U)));
  fi;
  home:=HomePcgs(G);
  #if not IsParent(G) or not IsElementaryAbelianAgSeries(G) then
  #  e:=ElementaryAbelianSeries(G);
  #  hom:=IsomorphismAgGroup(e);
  #  G:=Image(hom,G);
  #  U:=Image(hom,U);
  #else
  #  hom:=false;
  #fi;

  # compute a pcgs fitting the EAS
  pcgs:=PcgsElementaryAbelianSeries(G);
  e:=NormalSeriesByPcgs(pcgs);
  #pcgs:=Concatenation(List([1..Length(e)-1],i->
  #  InducedPcgs(home,e[i]) mod InducedPcgs(home,e[i+1])));
  #pcgs:=PcgsByPcSequence(ElementsFamily(FamilyObj(G)),pcgs);
  ##AH evtl. noch neue Gruppe

  # find the largest abelian quotient
  start:=2;
  while start<Length(e) and HasAbelianFactorGroup(G,e[start+1]) do
    start:=start+1;
  od;

  #initialize
  V:=U;
  ce:=One(G);
  no:=G;

  for i in [start..Length(e)-1] do
    # lift from G/e[i] to G/e[i+1]
    n:=e[i];
    m:=e[i+1];

    # map v,no
    fv:=ClosureGroup(m,V);
    #img:=CanonicalPcgs(InducedPcgsByGenerators(pcgs,GeneratorsOfGroup(fv)));
    no:=ClosureGroup(m,no);
    
#    if true then

    nno:=Normalizer(no,fv);
    rep:=RightTransversal(no,nno);
    orb:=List(rep,i->CanonicalPcgs(InducedPcgs(pcgs,fv^i)));
    min:=orb[1];
    minrep:=rep[1];
    for o in [2..Length(orb)] do
      if orb[o]<min then
	min:=orb[o];
	minrep:=rep[o];
      fi;
    od;

    #else
    #  # minimize the Cgs, orbit/stabilizer/repres. alg
    #  orb:=[img];
    #  rep:=[f.identity];
    #  min:=img;
    #  minrep:=f.identity;
    #  nno:=TrivialSubgroup(f);
#
      o:=1;
#      while o<=Length(orb) do
#	for g in no.generators do
#	  img:=Cgs(Subgroup(f,OnTuples(orb[o],g)));
#	  p:=Position(orb,img);
#	  if p=false then
#	    # new orbit element
#	    Add(orb,img);
#	    Add(rep,rep[o]*g);
#	    if img<min then
#	      min:=img;
#	      minrep:=rep[o]*g;
#	    fi;
#	  else
#	    # old element, grow normalizer
#	    nno:=Closure(nno,rep[o]*g/rep[p]);
#	  fi;
#	od;
#	o:=o+1;
#      od;
#    fi;

    # conjugate normalizer to new minimal one
    no:=nno^minrep;
    ce:=ce*minrep;
    V:=V^minrep;
  od;

  #if hom<>false then 
  #  V:=PreImage(hom,V);
  #  no:=PreImage(hom,no);
  #  ce:=PreImagesRepresentative(hom,ce);
  #fi;
  return [V,no,ce];
end );


#############################################################################
##
#M  ConjugacyClassSubgroups(<G>,<g>) . . . . . . .  constructor for pc groups
##  This method installs 'CanonicalSubgroupRepresentativePcGroup' as
##  CanonicalRepresentativeDeterminator
##
InstallMethod(ConjugacyClassSubgroups,IsIdenticalObj,[IsPcGroup,IsPcGroup],0,
function(G,U)
local cl;

    cl:=Objectify(NewType(CollectionsFamily(FamilyObj(G)),
      IsConjugacyClassSubgroupsRep),rec());
    SetActingDomain(cl,G);
    SetRepresentative(cl,U);
    SetFunctionOperation(cl,OnPoints);
    SetCanonicalRepresentativeDeterminatorOfExternalSet(cl,
	CanonicalSubgroupRepresentativePcGroup);
    return cl;
end);

InstallOtherMethod(RepresentativeOperationOp,"pc group on subgroups",true,
  [IsPcGroup,IsPcGroup,IsPcGroup,IsFunction],0,
function(G,U,V,f)
local c1,c2;
  if f<>OnPoints or not (IsSubgroup(G,U) and IsSubgroup(G,V)) then
    TryNextMethod();
  fi;
  if Size(U)<>Size(V) then
    return fail;
  fi;
  c1:=CanonicalSubgroupRepresentativePcGroup(G,U);
  c2:=CanonicalSubgroupRepresentativePcGroup(G,V);
  if c1[1]<>c2[1] then
    return fail;
  fi;
  return c1[3]/c2[3];
end);

#############################################################################
##
#F  ChiefSeriesUnderAction( <U>, <G> )
##
InstallMethod( ChiefSeriesUnderAction,
    "method for a pcgs computable group",
    IsIdenticalObj,
    [ IsGroup, IsGroup and CanEasilyComputePcgs ], 0,
function( U, G )
local home,e,ser,i,j,k,pcgs,mpcgs,op,m,cs,n;
  home:=HomePcgs(G);
  e:=ElementaryAbelianSeries(G);
  ser:=[G];
  for i in [2..Length(e)] do
    Info(InfoPcGroup,1,"Step ",i,": ",Index(e[i-1],e[i]));
    if IsPrimeInt(Index(e[i-1],e[i])) then
      Add(ser,e[i]);
    else
      pcgs:=InducedPcgs(home,e[i-1]);
      mpcgs:=pcgs mod InducedPcgs(home,e[i]);
      op:=LinearOperationLayer(U,GeneratorsOfGroup(U),mpcgs);
      m:=GModuleByMats(op,GF(RelativeOrderOfPcElement(pcgs,pcgs[1])));
      cs:=MTX.BasesCompositionSeries(m);
      Sort(cs,function(a,b) return Length(a)>Length(b);end);
      cs:=cs{[2..Length(cs)]};
      Info(InfoPcGroup,2,Length(cs)-1," compositionFactors");
      for j in cs do
	n:=e[i];
	for k in j do
	  n:=ClosureGroup(n,PcElementByExponents(mpcgs,List(k,IntFFE)));
	od;
	Add(ser,n);
      od;
    fi;
  od;
  return ser;
end);

InstallMethod(IsSimpleGroup,"for solvable groups",true,
  [IsSolvableGroup],
  # this is also better for permutation groups, so we increse the value to
  # be above the value for `IsPermGroup'.
  Maximum(SIZE_FLAGS(FLAGS_FILTER(IsSolvableGroup)),
          SIZE_FLAGS(FLAGS_FILTER(IsPermGroup))+1)
    -SIZE_FLAGS(FLAGS_FILTER(IsSolvableGroup))+1,
function(G)
  return IsInt(Size(G)) and (Size(G)=1 or IsPrimeInt(Size(G)));
end);

#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod(ViewObj,"pc group",true,[IsPcGroup],0,
function(G)
  if (not HasParent(G)) or
   Length(GeneratorsOfGroup(G))*Length(GeneratorsOfGroup(Parent(G)))
     /VIEWLEN>50 then
    Print("<pc group");
    if HasSize(G) then
      Print(" of size ",Size(G));
    fi;
    Print(" with ",Length(GeneratorsOfGroup(G)),
          " generators>");
  else
    Print("Group(");
    ViewObj(GeneratorsOfGroup(G));
    Print(")");
  fi;
end);

#############################################################################
##
#E  grppc.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
