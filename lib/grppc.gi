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
##  This file contains the methods for groups with a polycyclic collector.
##

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
    SetGroupOfPcgs (igs, grp);
    return igs;
end );

InstallMethod( InducedPcgsWrtFamilyPcgs,"whole family", true,
  [ IsPcGroup and IsWholeFamily], 0,
FamilyPcgs);


#############################################################################
##
#M  InducedPcgsWrtHomePcgs( <G> )
##
InstallMethod( InducedPcgsWrtHomePcgs,"from generators", true, [ IsGroup ], 0,
    function( G )
    local   home, ind;

    home := HomePcgs( G );
    if HasPcgs(G) and IsInducedPcgs(Pcgs(G))  then
        if IsIdenticalObj(home,ParentPcgs(Pcgs(G)))  then
            return Pcgs(G);
        fi;
    fi;
    ind := InducedPcgsByGenerators( home, GeneratorsOfGroup( G ) );
    SetGroupOfPcgs (ind, G);
    return ind;
end );

InstallMethod( InducedPcgsWrtHomePcgs,"pc group: home=family", true,
  [ IsPcGroup ], 0,
  InducedPcgsWrtFamilyPcgs);

#############################################################################
##
#M  InducedPcgs( <pcgs>,<G> )
##
InstallGlobalFunction( InducedPcgs, function(pcgs, G)
  local cache, i, igs;

  if not IsPcgs(pcgs) then
     Error("InducedPcgs: <pcgs> must be a pcgs");
  fi;
  if not IsGroup(G) then
     Error("InducedPcgs: <G> must be a group");
  fi;

  pcgs := ParentPcgs (pcgs);
  cache := ComputedInducedPcgses(G);
  i := 1;
  while i <= Length (cache) do
     if cache[i]= pcgs then
        return cache[i+1];
     fi;
     i := i + 2;
  od;

  igs := InducedPcgsOp( pcgs, G );
  SetGroupOfPcgs (igs, G);

  Append (cache, [pcgs, igs]);
  if not HasPcgs(G) then
     SetPcgs (G, igs);
  fi;

  # set home pcgs stuff
  if not HasHomePcgs(G) then
     SetHomePcgs (G, pcgs);
  fi;
  if IsIdenticalObj (HomePcgs(G), pcgs) then
     SetInducedPcgsWrtHomePcgs (G, igs);
  fi;

  return igs;
end );

#############################################################################
##
#M  InducedPcgsOp
##
InstallMethod (InducedPcgsOp, "generic method",
   IsIdenticalObj, [IsPcgs, IsGroup],
   function (pcgs, G)
      return InducedPcgsByGenerators(
          ParentPcgs(pcgs), GeneratorsOfGroup( G ) );
   end);

#############################################################################
##
#M  InducedPcgsOp
##
InstallMethod (InducedPcgsOp, "sift existing pcgs",
   IsIdenticalObj, [IsPcgs, IsGroup and HasPcgs],
   function (pcgs, G)
      local seq,    # pc sequence wrt pcgs (and its parent)
            depths, # depths of this sequence
            len,    # length of the sequence
            pos,    # index
            x,      # a group element
            d;      # depth of x

      pcgs := ParentPcgs (pcgs);
      seq := [];
      depths := [];
      len := 0;
      for x in Reversed (Pcgs (G)) do
         # sift x through seq
         d := DepthOfPcElement (pcgs, x);
         pos := PositionSorted (depths, d);

         while pos <= len and depths[pos] = d do
            x := ReducedPcElement (pcgs, x, seq[pos]);
            d := DepthOfPcElement (pcgs, x);
            pos := PositionSorted (depths, d);
         od;
         if d> Length(pcgs) then
            Error ("Panic: Pcgs (G) does not seem to be a pcgs");
         else
            seq{[pos+1..len+1]} := seq{[pos..len]};
            depths{[pos+1..len+1]} := depths{[pos..len]};
            seq[pos] := x;
            depths[pos] := d;
            len := len + 1;
         fi;
      od;
     return InducedPcgsByPcSequenceNC (pcgs, seq, depths);
   end);


#############################################################################
##
#M  ComputedInducedPcgses
##
InstallMethod (ComputedInducedPcgses, "default method", [IsGroup],
   G -> []);


#############################################################################
##
#F  SetInducedPcgs( <home>,<G>,<pcgs> )
##
InstallGlobalFunction(SetInducedPcgs,function(home,G,pcgs)
  home := ParentPcgs(home);
  if not HasHomePcgs(G) then
    SetHomePcgs(G,home);
  fi;
  if IsIdenticalObj(ParentPcgs(pcgs),home) then
     Append (ComputedInducedPcgses(G), [home, pcgs]);
     if IsIdenticalObj(HomePcgs(G),home) then
        SetInducedPcgsWrtHomePcgs(G,pcgs);
     fi;
  fi;
  SetGroupOfPcgs (pcgs, G);
end);

#############################################################################
##
#M  Pcgs( <G> )
##
InstallMethod( Pcgs, "fail if not solvable", true,
        [ IsGroup and HasIsSolvableGroup ],
        SUM_FLAGS, # for groups for which we know that they are not solvable
                   # this is the best we can do.
    function( G )
    if not IsSolvableGroup( G )  then  return fail;
                                 else  TryNextMethod();  fi;
end );

#############################################################################
##
#M  Pcgs( <pcgrp> )
##
InstallMethod( Pcgs,
    "for a group with known family pcgs",
    true,
    [ IsGroup and HasFamilyPcgs ],
    0,
    InducedPcgsWrtFamilyPcgs );


InstallMethod( Pcgs,
    "for a group with known home pcgs",
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
    "for a group containing the whole family and with known family pcgs",
    true,
    [ IsGroup and HasFamilyPcgs and IsWholeFamily ],
    0,
    FamilyPcgs );


#############################################################################
##
#M  GeneralizedPcgs( <G> )
##
#  This used to be an immediate method. It was replaced by an ordinary
#  method as the attribute is set when creating pc groups.
InstallMethod( GeneralizedPcgs,true,[ IsGroup and HasPcgs], 0, Pcgs );


#############################################################################
##
#M  HomePcgs( <G> )
##
##  BH: changed Pcgs to G -> ParentPcgs (Pcgs(G))
##
InstallMethod( HomePcgs, true, [ IsGroup ], 0, G -> ParentPcgs( Pcgs( G ) ) );

#############################################################################
##
#M  PcgsChiefSeries( <pcgs> )
##
InstallMethod( PcgsChiefSeries,"compute chief series and pcgs",true,
  [IsGroup],0,
function(G)
local p,cs,csi,l,i,pcs,ins,j,u;
  p:=Pcgs(G);
  if p=fail then
    Error("<G> must be solvable");
  fi;
  if not HasParent(G) then
    SetParentAttr(G,Parent(G));
  fi;
  cs:=ChiefSeries(G);
  csi:=List(cs,i->InducedPcgs(p,i));
  l:=Length(cs);
  pcs:=[];
  ins:=[0];
  for i in [l-1,l-2..1] do
    # extend the pc sequence. We have a vector space factor, so we can
    # simply add *some* further generators.
    u:=AsSubgroup(Parent(G),cs[i+1]);
    for j in Reversed(Filtered(csi[i],k->not k in cs[i+1])) do
      if not j in u then
        Add(pcs,j);
        #NC is safe
        u:=ClosureSubgroupNC(u,j);
      fi;
    od;
    if Length(pcs)<>Length(csi[i]) then
      Error("pcgs length!");
    fi;
    Add(ins,Length(pcs));
  od;
  l:=Length(pcs)+1;
  pcs:=PcgsByPcSequenceNC(FamilyObj(OneOfPcgs(p)),Reversed(pcs));
  SetGroupOfPcgs (pcs, G);
  # store the indices
  SetIndicesChiefNormalSteps(pcs,Reversed(List(ins,i->l-i)));
  return pcs;
end);


#############################################################################
##
#M  GroupWithGenerators( <gens> ) . . . . . . . . . . . . group by generators
#M  GroupWithGenerators( <gens>, <id> )
##
##  These methods override the generic code. They are installed for
##  `IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection' and
##  automatically set family pcgs and home pcgs.
##
InstallMethod( GroupWithGenerators,
    "method for pc elements collection",
    true, [ IsCollection and
    IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection and
    IsFinite] ,
    # override methods for `IsList' or `IsEmpty'.
    10,
function( gens )
local G,fam,id,pcgs;

  fam:=FamilyObj(gens);
  pcgs:=DefiningPcgs(ElementsFamily(fam));
  id:=One(gens[1]);

  # pc groups are always finite and gens is finite.
  G:=MakeGroupyObj(fam, IsSolvableGroup and IsFinite,
        AsList(gens),id,
        FamilyPcgs,pcgs,HomePcgs,pcgs,GeneralizedPcgs,pcgs);

  return G;
end );

InstallOtherMethod( GroupWithGenerators,
    "method for pc collection and identity element",
    IsCollsElms, [ IsCollection and
    IsMultiplicativeElementWithInverseByPolycyclicCollectorCollection
    and IsFinite,
    IsMultiplicativeElementWithInverseByPolycyclicCollector] ,
    0,
function( gens, id )
local G,fam,pcgs;

  fam:=FamilyObj(gens);
  pcgs:=DefiningPcgs(ElementsFamily(fam));

  # pc groups are always finite and gens is finite.
  G:=MakeGroupyObj(fam, IsSolvableGroup and IsFinite,
        AsList(gens),id,
        FamilyPcgs,pcgs,HomePcgs,pcgs,GeneralizedPcgs,pcgs);

  return G;
end );

InstallOtherMethod( GroupWithGenerators,
    "method for empty pc collection and identity element",
    true, [ IsList and IsEmpty,
    IsMultiplicativeElementWithInverseByPolycyclicCollector] ,
    # override methods for `IsList' or `IsEmpty'.
    10,
function( empty, id )
local G,fam,pcgs;

  fam:= CollectionsFamily( FamilyObj( id ) );
  pcgs:=DefiningPcgs(ElementsFamily(fam));

  # pc groups are always finite and gens is finite.
  G:=MakeGroupyObj(fam, IsSolvableGroup and IsFinite,
        empty,id,
        FamilyPcgs,pcgs,HomePcgs,pcgs,GeneralizedPcgs,pcgs);

  return G;
end );

#############################################################################
##
#M  <elm> in <pcgrp>
##
InstallMethod( \in,
    "for pc group",
    IsElmsColls,
    [ IsMultiplicativeElementWithInverse,
      IsGroup and HasFamilyPcgs and CanEasilyComputePcgs
    ],
    2, # rank this method higher than the following one

function( elm, grp )
    return SiftedPcElement(InducedPcgsWrtFamilyPcgs(grp),elm) = One(grp);
end );


#############################################################################
##
#M  <elm> in <pcgrp>
##
InstallMethod( \in,
    "for pcgs computable groups with home pcgs",
    IsElmsColls,
    [ IsMultiplicativeElementWithInverse,
      IsGroup and HasInducedPcgsWrtHomePcgs and CanEasilyComputePcgs
    ],
    1, # rank this method higher than the following one

function( elm, grp )
    local pcgs, ppcgs;

    pcgs := InducedPcgsWrtHomePcgs (grp);
    ppcgs := ParentPcgs (pcgs);
    if Length (pcgs) = Length (ppcgs) or not CanEasilyTestMembership (GroupOfPcgs(ppcgs)) then
        TryNextMethod();
    fi;
    if elm in GroupOfPcgs (ppcgs) then
        return SiftedPcElement(InducedPcgsWrtHomePcgs(grp),elm) = One(grp);
    else
        return false;
    fi;
end );


#############################################################################
##
#M  <elm> in <pcgrp>
##
InstallMethod( \in,
    "for pcgs computable groups with induced pcgs",
    IsElmsColls,
    [ IsMultiplicativeElementWithInverse,
      IsGroup and HasComputedInducedPcgses and CanEasilyComputePcgs
    ],
    0,

function( elm, grp )
    local pcgs, ppcgs;

    for pcgs in ComputedInducedPcgses(grp) do
        ppcgs := ParentPcgs (pcgs);
        if Length (pcgs) < Length (ppcgs) and CanEasilyTestMembership (GroupOfPcgs(ppcgs)) then
            if elm in GroupOfPcgs (ppcgs) then
                return SiftedPcElement(pcgs, elm) = One(grp);
            else
                return false;
            fi;
        fi;
    od;
    TryNextMethod();
end );


#############################################################################
##
#M  <pcgrp1> = <pcgrp2>
##
InstallMethod( \=,
    "pcgs computable groups using home pcgs",
    IsIdenticalObj,
    [ IsGroup and HasHomePcgs and HasCanonicalPcgsWrtHomePcgs,
      IsGroup and HasHomePcgs and HasCanonicalPcgsWrtHomePcgs ],
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
    [ IsGroup and HasFamilyPcgs and HasCanonicalPcgsWrtFamilyPcgs,
      IsGroup and HasFamilyPcgs and HasCanonicalPcgsWrtFamilyPcgs ],
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
#M  IsSubset( <pcgrp>, <pcsub> )
##
##  This method is better than calling `\in' for all generators,
##  since one has to fetch the pcgs only once.
##
InstallMethod( IsSubset,
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
    SetSize(U,Product(RelativeOrders(pcgs)));
    SetPcgs( U, pcgs );
    SetGroupOfPcgs (pcgs, U);
    # home pcgs will be inherited
    if HasHomePcgs(U) and IsIdenticalObj(HomePcgs(U),ParentPcgs(pcgs)) then
      SetInducedPcgsWrtHomePcgs(U,pcgs);
    fi;
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
InstallGlobalFunction( VectorSpaceByPcgsOfElementaryAbelianGroup,
    function( arg )
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
    return VectorSpace( field, Immutable( IdentityMat( dim, field ) ) );
end );


#############################################################################
##
#F  LinearActionLayer( <G>, <gens>, <pcgs>  )
##
InstallGlobalFunction( LinearActionLayer, function( arg )
local gens, pcgs, field, m,mat,i,j;

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

# the following code takes too much time, as it has to create obvious pc
# elements again from vectors with 1 nonzero entry.
#    V := Immutable( IdentityMat(Length(pcgs),field) );
#    linear := function( x, g )
#              return ExponentsOfPcElement( pcgs,
#                     PcElementByExponentsNC( pcgs, x )^g ) * One(field);
#              end;
#    return LinearAction( gens, V, linear );

#this is done much quicker by the following direct code:
  m:=[];
  for i in gens do
    mat:=[];
    for j in pcgs do
      Add(mat,ExponentsConjugateLayer(pcgs,j,i)*One(field));
    od;
    mat:=ImmutableMatrix(field,mat,true);
    Add(m,mat);
  od;
  return m;

end );

#############################################################################
##
#F  AffineActionLayer( <G>, <pcgs>, <transl> )
##
InstallGlobalFunction( AffineActionLayer, function( arg )
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
    V:= Immutable( IdentityMat(Length(pcgs),field) );
    linear := function( x, g )
              return ExponentsConjugateLayer(pcgs,
                     PcElementByExponentsNC( pcgs, x ),g ) * One(field);
              end;
    return AffineAction( gens, V, linear, transl );
end );

#############################################################################
##
#M  AffineAction( <gens>, <V>, <linear>, <transl> )
##
InstallMethod( AffineAction,"generators",
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
        mat:=ImmutableMatrix(Characteristic(one),mat,true);
        Add( mats, mat );
    od;
    return mats;

end );

InstallOtherMethod( AffineAction,"group",
    true,
    [ IsGroup,
      IsMatrix,
      IsFunction,
      IsFunction ],
    0,
function( G, V, linear, transl )
    return AffineAction( GeneratorsOfGroup(G), V, linear, transl );
end );

InstallOtherMethod( AffineAction,"group2",
    true,
    [ IsGroup,
      IsList,
      IsMatrix,
      IsFunction,
      IsFunction ],
    0,
function( G, gens, V, linear, transl )
    return AffineAction( gens, V, linear, transl );
end );

InstallOtherMethod( AffineAction,"pcgs",
    true,
    [ IsPcgs,
      IsMatrix,
      IsFunction,
      IsFunction ],
    0,
function( pcgsG, V, linear, transl )
    return AffineAction( AsList( pcgsG ), V, linear, transl );
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
    N := SubgroupByPcgs( GroupOfPcgs( home ), new );
#    SetHomePcgs( N, home );
#    SetInducedPcgsWrtHomePcgs( N, new );
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
        N   := SubgroupByPcgs( GroupOfPcgs(home), new );
#        SetHomePcgs( N, home );
#        SetInducedPcgsWrtHomePcgs( N, new );
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
    SetGroupOfPcgs (pag, N);
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
    local pcgs, home, f, orb, i, L, res, H,ip;

    # check the home pcgs are compatible
    home := HomePcgs(U);
    if home <> HomePcgs(G) then
        TryNextMethod();
    fi;
    H := GroupOfPcgs( home );

    # get a canonical pcgs for <U>
    pcgs := CanonicalPcgsWrtHomePcgs(U);

    # <G> acts on this <pcgs> via conjugation
    f := function( c, g )
        #was: CanonicalPcgs( HomomorphicInducedPcgs( home, c, g ) );
        return CorrespondingGeneratorsByModuloPcgs(home,List(c,i->i^g));
    end;

    # compute the orbit of <G> on <pcgs>
    orb := Orbit( G, pcgs, f );
    res := List( orb, ReturnFalse );
    for i in [1..Length(orb)] do
        L := Subgroup( H, orb[i] );
        SetHomePcgs( L, home );
        if not(IsPcgs(orb[i])) then
          ip:=InducedPcgsByPcSequenceNC(home,orb[i]);
        else
          ip:=orb[i];
        fi;
        SetInducedPcgsWrtHomePcgs( L, ip );
        SetGroupOfPcgs (ip, L);
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
    if IsSubset( U, V ) or IsTrivial(U) or IsTrivial(V)  then
        return U;
    fi;

    # start with <U>.
    C := U;

    # now  compute  intersection with all conjugate subgroups, conjugate with
    # all generators of V and its powers

    for v  in Reversed(pcgsV)  do
        repeat
            N := ConjugateGroup( C, v );
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
            next,  p,  d,  j,  pcgsS,  pcgsN,  pcgsL,  mats,
            modu,  max,  series,  comps,  sub,  new,  index,  order;

    spec := SpecialPcgs( G );
    if Length( spec ) = 0 then return 1; fi;
    first := LGFirst( spec );
    weights := LGWeights( spec );
    m := Length( spec );

    # the first head
    i := 1;
    phi := 1;
    while i <= Length(first)-1 and
          weights[first[i]][1] = 1 and weights[first[i]][2] = 1 do
        start := first[i];
        next  := first[i+1];
        p     := weights[start][3];
        d     := next - start;
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
            mats  := LinearActionLayer( spec, pcgsL );
            modu  := GModuleByMats( mats,  GF(p) );
            max   := MTX.BasesMaximalSubmodules( modu );

            # compute series
            series := [ Immutable( IdentityMat(d, GF(p)) ) ];
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

RedispatchOnCondition(EulerianFunction,true,[IsGroup,IsPosInt],
  [IsSolvableGroup,IsPosInt],
  1 # make the priority higher than the default method computing
    # the table of marks
  );

#############################################################################
##
#M  LinearAction( <gens>, <basisvectors>, <linear>  )
##
InstallMethod( LinearAction,
    true,
    [ IsList,
      IsMatrix,
      IsFunction ],
    0,

function( gens, base, linear )
local  i,mats;

    # catch trivial cases
    if Length( gens ) = 0 then
        return [];
    fi;

    # compute matrices
    if Length(base)>0 then
      mats := List( gens, x -> ImmutableMatrix(Characteristic(base),
                                List( base, y -> linear( y, x ) ),true ));
    else
      mats:=List(gens,i->[]);
    fi;
    MakeImmutable(mats);
    return mats;

end );

InstallOtherMethod( LinearAction,
    true,
    [ IsGroup,
      IsMatrix,
      IsFunction ],
    0,

function( G, base, linear )
    return LinearAction( GeneratorsOfGroup( G ), base, linear );
end );

InstallOtherMethod( LinearAction,
    true,
    [ IsPcgs,
      IsMatrix,
      IsFunction ],
    0,

function( pcgs, base, linear )
    return LinearAction( pcgs, base, linear );
end );

InstallOtherMethod( LinearAction,
    true,
    [ IsGroup,
      IsList,
      IsMatrix,
      IsFunction ],
    0,

function( G, gens, base, linear )
    return LinearAction( gens, base, linear );
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
    gens := Set( gens, x -> SiftedPcElement( pcgs, x ) );

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

    K := SubgroupByPcgs( GroupOfPcgs(home), tmp );
#    SetHomePcgs( K, home );
#    SetInducedPcgsWrtHomePcgs( K, tmp );
    return K;

end );


#############################################################################
##
#M  Random( <pcgrp> )
##
InstallMethodWithRandomSource( Random,
    "for a random source and a pcgs computable groups",
    [ IsRandomSource, IsGroup and CanEasilyComputePcgs and IsFinite ],
function(rs, grp)
    local   p;

    p := Pcgs(grp);
    if Length( p ) = 0 then
        return One( grp );
    else
        return Product( p, x -> x^Random(rs, 1, RelativeOrderOfPcElement(p,x)) );
    fi;
end );

BindGlobal( "CentralizerSolvableGroup", function(H,U,elm)
local  G,  home,  # the supergroup (of <H> and <U>), the home pcgs
       Hp,    # a pcgs for <H>
       inequal, # G<>H flag
       eas,     # elementary abelian series in <G> through <U>
       step,    # counter looping over <eas>
       L,       # members of <eas>
       Kp,Lp, # induced and modulo pcgs's
       KcapH,LcapH, # pcgs's of intersections with <H>
       N,   cent,   # elementary abelian factor, for affine action
       cls,     # classes in range/source of homomorphism
       opr,     # (elm^opr)=cls.representative
       nexpo,indstep,Ldep,allcent;

  # Treat the case of a trivial group.
  if IsTrivial( U )  then
    return H;
  fi;

  if IsSubgroup(H,U) then
    G:=H;
    inequal:=false;
  else
    G:=ClosureGroup( H, U );
    inequal:=true;
  fi;

  home:=HomePcgs(G);
  if not HasIndicesEANormalSteps(home) then
    home:=PcgsElementaryAbelianSeries(G);
  fi;
  # Calculate a (central)  elementary abelian series  with all pcgs induced
  # w.r.t. <home>.

  if IsPGroup( G )  then
    home:=PcgsCentralSeries(G);
    eas:=CentralNormalSeriesByPcgs(home);
    cent:=ReturnTrue;
  else
    home:=PcgsElementaryAbelianSeries(G);
    eas:=EANormalSeriesByPcgs(home);
    cent:=PcClassFactorCentralityTest;

  fi;
  indstep:=IndicesEANormalSteps(home);

  Hp:=InducedPcgs(home,H);

  # Initialize the algorithm for the trivial group.
  step:=1;
  while IsSubset( eas[ step + 1 ], U )  do
    step:=step + 1;
  od;
  L :=eas[ step ];
  Ldep:=indstep[step];
  Lp:=InducedPcgs(home,L);
  if inequal then
    LcapH:=NormalIntersectionPcgs( home, Hp, Lp );
  fi;

  cls:=[rec( representative:=elm,centralizer:=H,
             centralizerpcgs:=InducedPcgs(home,H) )];
  opr:=One( U );

  # Now go back through the factors by all groups in the elementary abelian
  # series.
  for step  in [ step + 1 .. Length( eas ) ]  do

    # We apply the homomorphism principle to the homomorphism G/L -> G/K.
    # The  actual   computations  are all  done   in <G>,   factors are
    # represented by modulo pcgs.
    Kp:=Lp;
    L :=eas[ step ];
    Ldep:=indstep[step];
    Lp:=InducedPcgs(home,L );
    N :=Kp mod Lp;  # modulo pcgs representing the kernel
    allcent:=cent(home,home,N,Ldep);
    if allcent=false then
      nexpo:=LinearActionLayer(home{[1..indstep[step-1]-1]},N);
    fi;

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
    if allcent
       or cent(home, cls[ 1 ].centralizerpcgs, N, Ldep )  then
      cls:=CentralStepClEANS( home,H, U, N, cls[ 1 ],false );
    else
      cls:=GeneralStepClEANS( home,H, U, N, nexpo,cls[ 1 ],false );
    fi;
    opr:=opr * cls[ 1 ].operator;
    if IsModuloPcgs(cls[1].cengen) then
      cls[1].centralizerpcgs:=cls[1].cengen;
    else
      cls[1].centralizerpcgs:=InducedPcgsByPcSequenceNC(home,cls[1].cengen);
    fi;

  od;

  if not IsBound(cls[1].centralizer) then
    cls[1].centralizer:=SubgroupByPcgs(G,cls[1].centralizerpcgs);
  fi;
  cls:=ConjugateSubgroup( cls[ 1 ].centralizer, opr ^ -1 );
  return cls;

end );


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
    return CentralizerSolvableGroup( G, GroupByGenerators( [ g ] ), g );
end );

InstallMethod( CentralizerOp,
    "pcgs computable groups",
    IsIdenticalObj,
    [ IsGroup and CanEasilyComputePcgs and IsFinite,
      IsGroup and CanEasilyComputePcgs and IsFinite ],
    0,  # in solvable permutation groups, backtrack seems preferable

function( G, H )
local   h,P;

  P:=Parent(G);
  for h  in MinimalGeneratingSet( H )  do
      G := CentralizerSolvableGroup( G,H, h );
  od;
  G:=AsSubgroup(P,G);
  Assert(2,ForAll(GeneratorsOfGroup(G),i->ForAll(GeneratorsOfGroup(H),
                                                j->Comm(i,j)=One(G))));
  return G;
end );

#############################################################################
##
#M  RepresentativeAction( <G>, <d>, <e>, OnPoints )   using affine methods
##
InstallOtherMethod( RepresentativeActionOp,
    "element conjugacy in pcgs computable groups", IsCollsElmsElmsX,
    [ IsGroup and CanEasilyComputePcgs and IsFinite,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse,
      IsFunction ],
    0,

function( G, d, e, opr )
    if opr <> OnPoints or not (IsPcGroup(G) or (d in G and e in G)) or
       not (d in G and e in G) then
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
local G,           # common parent
      home,Hp,     # the home pcgs, induced pcgs
      eas, step,   # elementary abelian series in <G> through <U>
      ea2,         # used for factor series
      L,           # members of <eas>
      Kp,Lp,       # induced and modulo pcgs's
      KcapH,LcapH, # pcgs's of intersections with <H>
      N,   cent,   # elementary abelian factor, for affine action
      tra,         # transversal for candidates
      nexpo,indstep,Ldep,allcent,
      cl,  i;  # loop variables

    # Treat trivial cases.
    if Index(H,NT)=1 or (HasAbelianFactorGroup(H,NT) and elm in H)
     or elm in NT then
      return H;
    fi;

    if elm in H then
      G:=H;
    else
      G:=ClosureGroup(H,elm);
      # is the subgroup still normal
      if not IsNormal(G,NT) then
        Error("subgroup not normal!");
      fi;
    fi;

    home := HomePcgs( G );
    if not HasIndicesEANormalSteps(home) then
      home:=PcgsElementaryAbelianSeries(G);
    fi;

    # Calculate a (central) elementary abelian series.

    eas:=fail;
    if IsPGroup( G ) then
        home:=PcgsPCentralSeriesPGroup(G);
        eas:=PCentralNormalSeriesByPcgsPGroup(home);
        if NT in eas then
          cent := ReturnTrue;
        else
          eas:=fail; # useless
        fi;
    fi;

    if eas=fail then
        home:=PcgsElementaryAbelianSeries([G,NT]);
        eas:=EANormalSeriesByPcgs(home);
        cent:=PcClassFactorCentralityTest;
    fi;
    indstep:=IndicesEANormalSteps(home);

    # series to NT
    ea2:=List(eas,i->ClosureGroup(NT,i));
    eas:=[];
    for i in ea2 do
      if not i in eas then
        Add(eas,i);
      fi;
    od;
    for i in eas do
      if not HasHomePcgs(i) then
        SetHomePcgs(i,ParentPcgs(home));
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
                  centralizer := H,
                  centralizerpcgs := InducedPcgs(home,H ));
    tra := One( H );

#    cls := List( candidates, c -> cl );
#    tra := List( candidates, c -> One( H ) );
    tra:=One(H);

    # Now go back through the factors by all groups in the elementary abelian
    # series.
    for step  in [ step + 1 .. Length( eas ) ]  do
        Kp := Lp;
        L  := eas[ step ];
        Ldep:=indstep[step];
        Lp := InducedPcgs(home, L );
        N  := Kp mod Lp;
        #SetFilterObj( N, IsPcgs );
        allcent:=cent(home,home,N,Ldep);
        if allcent=false then
          nexpo:=LinearActionLayer(home{[1..indstep[step-1]-1]},N);
        fi;
        if not IsIdenticalObj( G, H )  then
          KcapH   := LcapH;
          LcapH   := NormalIntersectionPcgs( home, Hp, Lp );
          N!.capH := KcapH mod LcapH;
        else
          N!.capH := N;
        fi;

        cl.candidates := cl.representative;
        if allcent
           or cent(home,cl.centralizerpcgs, N, Ldep)  then
            cl := CentralStepClEANS( home,G, H, N, cl,true )[1];
        else
            cl := GeneralStepClEANS( home,G, H, N,nexpo, cl,true )[1];
        fi;
        tra := tra * cl.operator;
        if IsModuloPcgs(cl.cengen) then
          cl.centralizerpcgs:=cl.cengen;
        else
          cl.centralizerpcgs:=InducedPcgsByPcSequenceNC(home,cl.cengen);
        fi;

    od;

    if not IsBound(cl.centralizer) then
      cl.centralizer:=SubgroupByPcgs(G,cl.centralizerpcgs);
    fi;
    cl:=ConjugateSubgroup( cl.centralizer, tra ^ -1 );
    Assert(2,ForAll(GeneratorsOfGroup(cl),i->Comm(elm,i) in NT));
    Assert(2,IsSubset(G,cl));
    return cl;

end);

InstallMethod(CentralizerModulo,"group centralizer via generators",
  IsFamFamFam,[IsGroup and CanEasilyComputePcgs, IsGroup and
  CanEasilyComputePcgs, IsGroup],0,
function(G,NT,U)
local i,P;
  P:=Parent(G);
  for i in GeneratorsOfGroup(U) do
    G:=CentralizerModulo(G,NT,i);
  od;
  G:=AsSubgroup(P,G);
  return G;
end);

# enforce solvability check.
RedispatchOnCondition(CentralizerModulo,true,[IsGroup,IsGroup,IsObject],
  [IsGroup and IsSolvableGroup,IsGroup and IsSolvableGroup,IsObject],0);

#############################################################################
##
#F  ElementaryAbelianSeries( <list> )
##
InstallOtherMethod( ElementaryAbelianSeries,"list of pcgs computable groups",
  true,[IsList and IsFinite],
  1, # there is a generic groups function with value 0
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
      I.sum:=SubgroupByPcgs(S[1],I.sum);
      I.intersection:=SubgroupByPcgs(S[1],I.intersection);
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
  return N;
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
    Add(lines,"f:=FreeGroup(IsSyllableWordsFamily,");
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
    Add(lines,"Print(\"#I A group of order \",Size(");
    Add(lines,name);
    Add(lines,"),\" has been defined.\\n\");\n");
    Add(lines,"Print(\"#I It is called ");
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
#F  PrintPcPresentation( <grp>, <commBool> )
##
##  Display the pc relations of a pc group.
##  If <commBool> is true, then the commutator presentation is printed,
##  otherwise the power presentation.
##  Trivial commutators / powers are not printed.
##  The generators are named "g<i>".
##  The returned boolean indicates if there are commuting generators.
##
InstallGlobalFunction( PrintPcPresentation, function(G, commBool)
    local pcgs, n, F, gens, i, pis, exp, t, h, commPower, j, trivialCommutators;

    pcgs:=Pcgs(G);
    n:=Length(pcgs);
    F    := FreeGroup( n, "g" );
    gens := GeneratorsOfGroup( F );
    pis  := RelativeOrders( pcgs );

    # compute the orders of the pc-generators
    for i in [1..n] do
        exp := ExponentsOfRelativePower( pcgs, i ){[i+1..n]};
        t   := One( F );
        for h in [i+1..n] do
            t := t * gens[h]^exp[h-i];
        od;
        if IsOne( t ) then
            t := "id";
        fi;
        Print(gens[i], "^", pis[i], " = ", t, "\n");
    od;

    # compute the commutators / conjugation
    # of all pairs of pc-generators
    trivialCommutators := false;
    for i in [1..n] do
        for j in [i+1..n] do
            if pcgs[j] * pcgs[i] = pcgs[i] * pcgs[j] then
                trivialCommutators := true;
                continue;
            fi;
            if commBool then
                commPower := Comm( pcgs[j], pcgs[i] );
            else
                commPower := pcgs[j]^pcgs[i];
            fi;
            exp := ExponentsOfPcElement( pcgs, commPower ){[i+1..n]};
            t   := One( F );
            for h in [i+1..n] do
                t := t * gens[h]^exp[h-i];
            od;
            if commBool then
                Print("[", gens[j], ",", gens[i] , "]");
            else
                Print(gens[j], "^", gens[i]);
            fi;
            Print(" = ", t, "\n");
        od;
    od;

    return trivialCommutators;
end );

#############################################################################
##
#M  Display( <grp> )
##
InstallMethod( Display,
    "for a pc group",
    [ IsPcGroup ],
    function( G )
        local n, trivialCommutators;
        if IsTrivial(G) then
            Print("trivial pc-group\n");
            return;
        fi;
        n := Size(Pcgs(G));
        if IsOne(n) then
            Print("cyclic pc-group with 1 pc-generator and the relation:\n");
        else
            Print("pc-group with ", Size(Pcgs(G)), " pc-generators and relations:\n");
        fi;
        trivialCommutators := PrintPcPresentation( G, false );
        if IsAbelian(G) then
          Print("all generators commute, the groups is abelian\n");
        elif trivialCommutators then
          Print("all other pairs of generators commute\n");
        fi;
    end );

#############################################################################
##
#M  Enumerator( <G> ) . . . . . . . . . . . . . . . . . .  enumerator by pcgs
##
InstallMethod( Enumerator,"finite pc computable groups",true,
        [ IsGroup and CanEasilyComputePcgs and IsFinite ], 0,
    G -> EnumeratorByPcgs( Pcgs( G ) ) );


#############################################################################
##
#M  KnowsHowToDecompose( <G>, <gens> )
##
InstallMethod( KnowsHowToDecompose,
    "pc group and generators: always true",
    IsIdenticalObj,
    [ IsPcGroup, IsList ], 0,
    ReturnTrue);


#############################################################################
##
#F  CanonicalSubgroupRepresentativePcGroup( <G>, <U> )
##
InstallGlobalFunction( CanonicalSubgroupRepresentativePcGroup,
    function(G,U)
local e,        # EAS
      pcgs,     # himself
      iso,      # isomorphism to EAS group
      start,    # index of largest abelian quotient
      i,        # loop
      m,        # e[i+1]
      pcgsm,    # pcgs(m)
      mpcgs,    # pcgs mod pcgsm
      V,        # canon. rep
      fv,       # <V,m>
      fvgens,   # gens(fv)
      no,       # its normalizer
      orb,      # orbit
      o,        # orb index
      nno,      # growing normalizer
      min,
      minrep,   # minimum indicator
  #   p,        # orbit pos.
      one,      # 1
      abc,      # abelian case indicator
      nopcgs,   #pcgs(no)
      te,       # transversal exponents
      opfun,    # operation function
      ce;       # conj. elm

  if not IsSubgroup(G,U) then
    Error("#W  CSR Closure\n");
    G:=Subgroup(Parent(G),Concatenation(GeneratorsOfGroup(G),
                                        GeneratorsOfGroup(U)));
  fi;

  # compute a pcgs fitting the EAS
  pcgs:=PcgsChiefSeries(G);
  e:=ChiefNormalSeriesByPcgs(pcgs);

  if not IsBound(G!.chiefSeriesPcgsIsFamilyInduced) then
    # test whether pcgs is family induced
    m:=List(pcgs,i->ExponentsOfPcElement(FamilyPcgs(G),i));
    G!.chiefSeriesPcgsIsFamilyInduced:=
      ForAll(m,i->Number(i,j->j<>0)=1) and ForAll(m,i->Number(i,j->j=1)=1)
                                       and m=Reversed(Set(m));
    if not G!.chiefSeriesPcgsIsFamilyInduced then
      # compute isom. &c.
      V:=PcGroupWithPcgs(pcgs);
      iso:=GroupHomomorphismByImagesNC(G,V,pcgs,FamilyPcgs(V));
      G!.isomorphismChiefSeries:=iso;
      G!.isomorphismChiefSeriesPcgs:=FamilyPcgs(Image(iso));
      G!.isomorphismChiefSeriesPcgsSeries:=List(e,i->Image(iso,i));
    fi;
  fi;

  if not G!.chiefSeriesPcgsIsFamilyInduced then
    iso:=G!.isomorphismChiefSeries;
    pcgs:=G!.isomorphismChiefSeriesPcgs;
    e:=G!.isomorphismChiefSeriesPcgsSeries;
    U:=Image(iso,U);
    G:=Image(iso);
  else
    iso:=false;
  fi;

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
  one:=One(G);
  ce:=One(G);
  no:=G;

  for i in [start..Length(e)-1] do
    # lift from G/e[i] to G/e[i+1]
    m:=e[i+1];
    pcgsm:=InducedPcgs(pcgs,m);
    mpcgs:=pcgs mod pcgsm;

    # map v,no
    #fv:=ClosureGroup(m,V);
    #img:=CanonicalPcgs(InducedPcgsByGenerators(pcgs,GeneratorsOfGroup(fv)));

#    if true then

    nopcgs:=InducedPcgs(pcgs,no);

    fvgens:=GeneratorsOfGroup(V);
    if true then
      min:=CorrespondingGeneratorsByModuloPcgs(mpcgs,fvgens);
#UU:=ShallowCopy(min);
#      NORMALIZE_IGS(mpcgs,min);
#if UU<>min then
#  Error("hier1");
#fi;
      # trim m-part
      min:=List(min,i->CanonicalPcElement(pcgsm,i));

      # operation function: operate on the cgs modulo m
      opfun:=function(u,e)
        u:=CorrespondingGeneratorsByModuloPcgs(mpcgs,List(u,j->j^e));
#UU:=ShallowCopy(u);
#        NORMALIZE_IGS(mpcgs,u);
#if UU<>u then
#  Error("hier2");
#fi;

        # trim m-part
        u:=List(u,i->CanonicalPcElement(pcgsm,i));
        return u;
      end;
    else
      min:=fv;
      opfun:=OnPoints;
    fi;

    # this function computes the orbit in a well-defined order that permits
    # to find a transversal cheaply
    orb:=Pcgs_OrbitStabilizer(nopcgs,false,min,nopcgs,opfun);

    nno:=orb.stabpcgs;
    abc:=orb.lengths;
    orb:=orb.orbit;
#if Length(orb)<>Index(no,Normalizer(no,fv)) then
#  Error("len!");
#fi;

    # determine minimal conjugate
    minrep:=one;
    for o in [2..Length(orb)] do
      if orb[o]<min then
        min:=orb[o];
        minrep:=o;
      fi;
    od;

    # compute representative
    if IsInt(minrep) then
      te:=ListWithIdenticalEntries(Length(nopcgs),0);
      o:=2;
      while minrep<>1 do
        while abc[o]>=minrep do
          o:=o+1;
        od;
        te[o-1]:=-QuoInt(minrep-1,abc[o]);
        minrep:=(minrep-1) mod abc[o]+1;
      od;
      te:=LinearCombinationPcgs(nopcgs,te)^-1;
      if opfun(orb[1],te)<>min then
        Error("wrong repres!");
      fi;
      minrep:=te;
    fi;

#
#
#     nno:=Normalizer(no,fv);
#
#    rep:=RightTransversal(no,nno);
#    #orb:=List(rep,i->CanonicalPcgs(InducedPcgs(pcgs,fv^i)));
#
#    # try to cope with action on vector space (long orbit)
##    abc:=false;
##    if Index(fv,m)>1 and HasElementaryAbelianFactorGroup(fv,m) then
##      nocl:=NormalClosure(no,fv);
##      if HasElementaryAbelianFactorGroup(nocl,m) then
###        abc:=true; # try el. ab. case
##      fi;;
##    fi;
#
#    if abc then
#      nocl:=InducedPcgs(pcgs,nocl) mod pcgsm;
#      nopcgs:=InducedPcgs(pcgs,no) mod pcgsm;
#      lop:=LinearActionLayer(Group(nopcgs),nocl); #matrices for action
#      fvgens:=List(fvgens,i->ShallowCopy(
#                   ExponentsOfPcElement(nocl,i)*Z(RelativeOrders(nocl)[1])^0));
#      TriangulizeMat(fvgens); # canonize
#      min:=fvgens;
#      minrep:=one;
#      for o in rep do
#        if o<>one then
#          # matrix image of rep
#          orb:=ExponentsOfPcElement(nopcgs,o);
#          orb:=Product([1..Length(orb)],i->lop[i]^orb[i]);
#          orb:=List(fvgens*orb,ShallowCopy);
#          TriangulizeMat(orb);
#          if orb<min then
#            min:=orb;
#            minrep:=o;
#          fi;
#        fi;
#      od;
#
#    else
#      min:=CorrespondingGeneratorsByModuloPcgs(mpcgs,fvgens);
#      NORMALIZE_IGS(mpcgs,min);
#      minrep:=one;
#      for o in rep do
#        if o<>one then
#          if Length(fvgens)=1 then
#            orb:=fvgens[1]^o;
#            orb:=orb^(1/LeadingExponentOfPcElement(mpcgs,orb)
#                      mod RelativeOrderOfPcElement(mpcgs,orb));
#            orb:=[orb];
#          else
#            orb:=CorrespondingGeneratorsByModuloPcgs(mpcgs,List(fvgens,j->j^o));
#            NORMALIZE_IGS(mpcgs,orb);
#          fi;
#          if orb<min then
#            min:=orb;
#            minrep:=o;
#          fi;
#        fi;
#      od;
#    fi;

    # conjugate normalizer to new minimal one
    no:=ClosureGroup(m,List(nno,i->i^minrep));
    ce:=ce*minrep;
    V:=V^minrep;
  od;

  if iso<>false then
    V:=PreImage(iso,V);
    no:=PreImage(iso,no);
    ce:=PreImagesRepresentative(iso,ce);
  fi;
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
      IsConjugacyClassSubgroupsByStabilizerRep),rec());
    SetActingDomain(cl,G);
    SetRepresentative(cl,U);
    SetFunctionAction(cl,OnPoints);
    SetCanonicalRepresentativeDeterminatorOfExternalSet(cl,
        CanonicalSubgroupRepresentativePcGroup);
    return cl;
end);

InstallOtherMethod(RepresentativeActionOp,"pc group on subgroups",true,
  [IsPcGroup,IsPcGroup,IsPcGroup,IsFunction],0,
function(G,U,V,f)
local c1,c2;
  if f<>OnPoints or not (IsSubset(G,U) and IsSubset(G,V)) then
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
  e:=ElementaryAbelianSeriesLargeSteps(G);

  # make the series U-invariant
  ser:=ShallowCopy(e);
  e:=[G];
  n:=G;
  for i in [2..Length(ser)] do
    # check whether we actually stepped down (or did the intersection
    # already do it?
    if Size(ser[i])<Size(n) then
      if not IsNormal(U,ser[i]) then
        # assuming the last was normal we intersect the conjugates and get a
        # new normal with still ea. factor
        ser[i]:=Core(U,ser[i]);
        # intersect the rest of the series.
        for j in [i+1..Length(ser)-1] do
          ser[j]:=Intersection(ser[i],ser[j]);
        od;
      fi;
      Add(e,ser[i]);
      n:=ser[i];
    fi;
  od;

  ser:=[G];
  for i in [2..Length(e)] do
    Info(InfoPcGroup,1,"Step ",i,": ",Index(e[i-1],e[i]));
    if IsPrimeInt(Index(e[i-1],e[i])) then
      Add(ser,e[i]);
    else
      pcgs:=InducedPcgs(home,e[i-1]);
      mpcgs:=pcgs mod InducedPcgs(home,e[i]);
      op:=LinearActionLayer(U,GeneratorsOfGroup(U),mpcgs);
      if ForAll(op,IsOne) then
        m:=op[1]; # identity
        cs:=List([0..Length(m)],x->m{[Length(m)+1-x..Length(m)]});
      else
        m:=GModuleByMats(op,GF(RelativeOrderOfPcElement(mpcgs,mpcgs[1])));
        cs:=MTX.BasesCompositionSeries(m);
      fi;
      Sort(cs,function(a,b) return Length(a)>Length(b);end);
      cs:=cs{[2..Length(cs)]};
      Info(InfoPcGroup,2,Length(cs)-1," compositionFactors");
      for j in cs do
        n:=e[i];
        for k in j do
          n:=ClosureGroup(n,PcElementByExponentsNC(mpcgs,List(k,IntFFE)));
        od;
        Add(ser,n);
      od;
    fi;
  od;
  return ser;
end);

InstallMethod(IsSimpleGroup,"for solvable groups",true,
  [IsSolvableGroup],
  # this is also better for permutation groups, so we increase the value to
  # be above the value for `IsPermGroup'.
  {} -> Maximum(RankFilter(IsSolvableGroup),
          RankFilter(IsPermGroup)+1)
    -RankFilter(IsSolvableGroup),
function(G)
  return IsInt(Size(G)) and IsPrimeInt(Size(G));
end);

#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod(ViewObj,"pc group",true,[IsPcGroup],0,
function(G)
local nrgens;
  nrgens := Length(GeneratorsOfGroup(G));
  if (not HasParent(G)) or
   nrgens*Length(GeneratorsOfGroup(Parent(G)))
     / GAPInfo.ViewLength > 50 then
    Print("<pc group");
    if HasSize(G) then
      Print(" of size ",Size(G));
    fi;
    Print(" with ", Pluralize(nrgens, "generator"), ">");
  else
    Print("Group(");
    ViewObj(GeneratorsOfGroup(G));
    Print(")");
  fi;
end);

#############################################################################
##
#M  CanEasilyComputePcgs( <pcgrp> ) . . . . . . . . . . . . . . . .  pc group
##

InstallTrueMethod( CanEasilyComputePcgs, IsPcGroup );

# InstallTrueMethod( CanEasilyComputePcgs, HasPcgs );
# we cannot guarantee that computations with any pcgs is efficient

InstallTrueMethod( CanEasilyComputePcgs, IsGroup and HasFamilyPcgs );


#############################################################################
##
#M  CanEasilyTestMembership
##

# InstallTrueMethod(CanEasilyTestMembership,CanEasilyComputePcgs);
# we cannot test membership using a pcgs

# InstallTrueMethod(CanComputeSize, CanEasilyComputePcgs); #unnecessary

#############################################################################
##
#M  IsSolvableGroup
##
InstallTrueMethod(IsSolvableGroup, CanEasilyComputePcgs);


#############################################################################
##
#M  CanComputeSizeAnySubgroup
##
InstallTrueMethod( CanComputeSizeAnySubgroup, CanEasilyComputePcgs );

#############################################################################
##
#M  CanEasilyComputePcgs( <grp> ) . . . . . . . . . subset or factor relation
##
##  Since factor groups might be in a different representation,
##  they should *not* inherit `CanEasilyComputePcgs' automatically.
##
#InstallSubsetMaintenance( CanEasilyComputePcgs,
#     IsGroup and CanEasilyComputePcgs, IsGroup );


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
InstallMethod( IsConjugatorIsomorphism,
    "for a pc group general mapping",
    true,
    [ IsGroupGeneralMapping ], 1,
    # There is no filter to test whether source and range of a homomorphism
    # are pc groups.
    # So we have to test explicitly and make this method
    # higher ranking than the default one in `ghom.gi'.
    function( hom )

    local s, r, G, genss, rep;

    s:= Source( hom );
    if not IsPcGroup( s ) then
      TryNextMethod();
    elif not ( IsGroupHomomorphism( hom ) and IsBijective( hom ) ) then
      return false;
    elif IsEndoGeneralMapping( hom ) and IsInnerAutomorphism( hom ) then
      return true;
    fi;
    r:= Range( hom );

    # Check whether source and range are in the same family.
    if FamilyObj( s ) <> FamilyObj( r ) then
      return false;
    fi;

    # Compute a conjugator in the full pc group.
    G:= GroupOfPcgs( FamilyPcgs( s ) );
    genss:= GeneratorsOfGroup( s );
    rep:= RepresentativeAction( G, genss, List( genss,
                    i -> ImagesRepresentative( hom, i ) ), OnTuples );

    # Return the result.
    if rep <> fail then
      Assert( 1, ForAll( genss, i -> Image( hom, i ) = i^rep ) );
      SetConjugatorOfConjugatorIsomorphism( hom, rep );
      return true;
    else
      return false;
    fi;
    end );

#############################################################################
##
#M  CanEasilyComputeWithIndependentGensAbelianGroup( <pcgrp> )
##
InstallTrueMethod(CanEasilyComputeWithIndependentGensAbelianGroup,
    IsGroup and CanEasilyComputePcgs and IsAbelian);

#############################################################################
##
#M  IndependentGeneratorsOfAbelianGroup( <A> )
##
InstallMethod(IndependentGeneratorsOfAbelianGroup,
  "Use Pcgs and NormalFormIntMat to find the independent generators",
        [IsGroup and CanEasilyComputePcgs and IsAbelian],0,
function(G)
local matrix, snf, base, ord, cti, row, g, o, cf, j, i;

  if IsTrivial(G) then return []; fi;

  matrix:=List([1..Size(Pcgs(G))],g->List(ExponentsOfRelativePower(Pcgs(G),g)));
  for i in [1..Size(Pcgs(G))] do
    matrix[i][i]:=-RelativeOrders(Pcgs(G))[i];
  od;
  snf:=NormalFormIntMat(matrix,1+8+16);

  base:=[];
  ord:=[];
  cti:=snf.coltrans^-1;
  for i in [1..Length(cti)] do
    row:=cti[i];
    g:=LinearCombinationPcgs(Pcgs(G),row,One(G));
    if not IsOne(g) then
      # get the involved prime factors
      o:=snf.normal[i][i];
      cf:=Collected(Factors(o));
      if Length(cf)>1 then
        for j in cf do
          j:=j[1]^j[2];
          Add(ord,j);
          Add(base,g^(o/j));
        od;
      else
        Add(base,g);
        Add(ord,o);
      fi;
    fi;
  od;
  SortParallel(ord,base);
  return base;
end);


#############################################################################
##
#M  MinimalGeneratingSet( <A> )
##
InstallMethod(MinimalGeneratingSet,
    "compute via Smith normal form",
        [IsGroup and CanEasilyComputePcgs and IsAbelian], {} -> RankFilter(IsPcGroup),
    function(G)

        local pcgs, matrix, snf, gens, cti, row, g, i;

        if IsTrivial (G) then
            return [];
        fi;

        pcgs := Pcgs (G);
        matrix:=List([1..Length(pcgs)],i->List(ExponentsOfRelativePower(pcgs,i)));
        for i in [1..Length(pcgs)] do
            matrix[i][i]:=-RelativeOrders(pcgs)[i];
        od;
        snf:=NormalFormIntMat(matrix,1+8+16);

        gens:=[];
        cti:=snf.coltrans^-1;
        for i in [1..Length(cti)] do
            row:=cti[i];
            g:=Product( List([1..Length(row)],j->pcgs[j]^row[j]));
            if not IsOne(g) then
                Add(gens,g);
            fi;
        od;

        return gens;
    end);


#############################################################################
##
#M  ExponentOfPGroupAndElm( <G>, <bound> )
##

# Return exponent and probably also an element of high order. If exponent is
# found to be larger than bound, just return the result found so far.
#
# JS: A result of Higman detailed on p564 of C. Sims Computation with
# F. P. Groups shows that an element of maximal order in a p-group
# exists where its weight with respect to a special pcgs is at most
# the p-class of the group.  Furthermore we need only check normed
# row vectors as exponent vectors since every cyclic subgroup has a
# generator with a normed row vector for exponents.
#
# This function just checks all such vectors using a simple backtrack
# method.  It handles the case of the trivial group and a regular
# p-group specially.
#
# Assumed: G is a p-group, of max size p^30 or so.
BindGlobal("ExponentOfPGroupAndElm",
function(G,bound)
        local all,pcgs,monic,weights,pclass,p;
        monic := function(w,p,f)
                local a,ldim,c,M,M1;
                M := [0,0];
                c := Maximum(w);
                for ldim in [1..Size(w)] do
                        a := ListWithIdenticalEntries(Size(w),0);
                        a[ldim] := 1;
                        M1 := all(ldim,a,w,p,c-w[ldim],f);
                        if M1[1] > M[1] then M:=M1; if M[1] > bound then return M; fi; fi;
                od;
                return M;
        end;
        all := function(ldim,a,w,p,c,f)
                local M,M1;
                if ldim = Size(a) then return [f(a),PcElementByExponents(pcgs,a)]; fi;
                M := [0,0];
                a{[ldim+2..Size(a)]} := ListWithIdenticalEntries(Size(a)-ldim-1,0);
                a[ldim+1] := Minimum( p-1, Int(c/w[ldim+1]) );
                while a[ldim+1] >= 0 do
                        M1 := all(ldim+1,a,w,p,c-a[ldim+1]*w[ldim+1],f);
                        if M1[1] > M[1] then M:=M1; if M[1] > bound then return M; fi; fi;
                        a[ldim+1] := a[ldim+1]-1;
                od;
                return M;
        end;
        p := PrimePGroup(G);
        if p = fail then return [1,One(G)]; fi; # handle trivial p-group of size 1
        pcgs := SpecialPcgs(G);
        weights := LGLayers(pcgs);
        pclass := Maximum(weights);
        if pclass < p then # Easily recognized regular p-group
                pclass := Maximum(List(pcgs,Order));
                return [pclass,First(pcgs,g->Order(g)=pclass)];
        fi;
        bound := Minimum(p^(pclass-1),bound);
        return monic(LGLayers(pcgs),PrimePGroup(G),a->Order(PcElementByExponents(pcgs,a)));
end);

InstallMethod( Exponent,"finite solvable group",
  true,[IsGroup and IsSolvableGroup and IsFinite],0,
function(G)
  if IsPGroup(G) then
    return ExponentOfPGroupAndElm(G,Size(G))[1];
  fi;
  TryNextMethod();
end);


#############################################################################
##
#M  AgemoOp( <G> )
##
InstallMethod( AgemoOp, "PGroups",true,[ IsPGroup, IsPosInt, IsPosInt ],0,
function( G, p, n )
local q, pcgs, sub, hom, f, ex, C;

  q := p ^ n;
  # if <G> is abelian,  raise the generators to the q.th power
  if IsAbelian(G)  then
      return SubgroupNC( G,Filtered( List( GeneratorsOfGroup( G ), x ->
      x^q ),i->not IsOne(i)) );
  fi;

  # based on Code by Jack Schmidt
  pcgs:=Pcgs(G);
  ex:=One(G);
  sub:=NormalClosure(G,SubgroupNC(G,Filtered(List(pcgs,i->i^q),x->x<>ex)));
  hom:=NaturalHomomorphismByNormalSubgroup(G,sub);
  f:=Range(hom);
  ex:=ExponentOfPGroupAndElm(f,q);
  while ex[1]>q do
    # take the element of highest order in f and take power of its preimage
    ex:=PreImagesRepresentative(hom,ex[2]^q);
    sub:=NormalClosure(G,ClosureSubgroupNC(sub,ex));
    hom:=NaturalHomomorphismByNormalSubgroup(G,sub);
    f:=Range(hom);
    ex:=ExponentOfPGroupAndElm(f,q);
  od;
  return sub;

  # otherwise compute the conjugacy classes of elements
  C := Set( ConjugacyClasses(G), x -> Representative(x)^q );
  return NormalClosure( G, SubgroupNC( G, C ) );
end );


InstallMethod(Socle,"for p-groups",true,[IsPGroup],0,
function(G)
  if IsTrivial(G) then return G; fi;
  return Omega(Center(G),PrimePGroup(G),1);
end);


#############################################################################
##
#M  OmegaOp( <G>, <p>, <n> )  . . . . . . . . . . . . for p-groups
##
##  The following method is due to Jack Schmidt
##  Omega(G,p,e) is defined to be <g in G: g^(p^e)=1>

# Omega_LowerBound returns a subgroup of Omega(G,p,e)
# Assumed: G is a p-group, e is a positive integer
BindGlobal("Omega_LowerBound_RANDOM",100); # number of random elements to test
BindGlobal("Omega_LowerBound",
function(G,p,e)
local H,fix_order;
  fix_order:=function(g) while not IsOne(g^(p^e)) do g:=g^p; od; return g; end;
  H:=Subgroup(G,List(Pcgs(G),fix_order));
  H:=ClosureGroup(H,List([1..Omega_LowerBound_RANDOM],i->fix_order(Random(G))));
  return H;
end);

# Omega_Search is a brute force search for Omega.
# One can search by coset if Omega(G) = { g in G : g^(p^e) = 1 }
# This is the case in regular p groups.
# Assumed: G is a p-group, e is a positive integer
BindGlobal("Omega_Search",
function(G,p,e)
local g,H,fix_order,T;
  H:=Omega_LowerBound(G,p,e);
  fix_order:=function(g) while not IsOne(g^(p^e)) do g:=g^p; od; return g; end;
  if NilpotencyClassOfGroup(G) < p
  then T:=RightTransversal(G,H);
  else T:=G;
  fi;
  for g in T do
    g:=fix_order(g);
    if(g in H) then continue; fi;
    H:=ClosureSubgroup(H,g);
    if(H=G) then return G; fi;
  od;
  return H;
end);


# Omega_UpperBoundAbelianQuotient(G,p,e) returns a subgroup K<=G
# such that Omega(G,p,e) <= K. Then Omega(K,p,e)=Omega(G,p,e)
# allowing other methods to work on a smaller group.
#
# It is not guaranteed that K is a proper subgroup of G.
#
# In detail: Omega(G/[G,G],p,e) = K/[G,G] and K is returned.
#
# Assumed: G is a p-group, e is a positive integer

BindGlobal("Omega_UpperBoundAbelianQuotient",
function(G,p,e)
local f;
  f:=MaximalAbelianQuotient(G);
  IsAbelian(Image(f));
  return SubgroupByPcgs(G,Pcgs(PreImagesSet(f,Omega(Image(f),p,e))));
end);

# Efficiency notes:
#
# (1) "PreImagesSet" is used to find the preimage of Omega in G/[G,G].
# there may very well be faster ways of doing this.
#
# (2) "SubgroupByPcgs(G,Pcgs(...))" is used to give the returned subgroup
# with natural standard generators. There may be better ways of doing this,
# and this may not be needed at all.


# Omega_UpperBoundCentralQuotient(G,p,e) returns
# a subgroup K with Omega(G,p,e) <= K <= G. The
# algorithm is (moderately) randomized.
#
# The algorithm is NOT fast.
#
# In detail a random central element, z, of order p is
# selected and K is returned where K/<z> = Omega(G/<z>,p,e).
#
# Assumed: G is a p-group, e is a positive integer


BindGlobal("Omega_UpperBoundCentralQuotient",
function(G,p,e)
local z,f;

  z:=One(G); while(IsOne(z)) do z:=Random(Socle(G)); od;

  f:=NaturalHomomorphismByNormalSubgroup(G,Subgroup(G,[z]));
  IsAbelian(Image(f)); # Probably is not, but quick to check
  return SubgroupByPcgs(G,Pcgs(PreImagesSet(f,Omega(Image(f),p,e))));
end);

# Efficiency Points:
#
# (1) "Omega" is used to compute Omega(G/<z>,p,e). |G/<z>| = |G|/p.
# This is a very tiny reduction AND it is very possible for
# Omega(G/<z>)=G/<z> for every nontrivial element z of the socle without
# Omega(G)=G. Hence the calculation of Omega(G/<z>) may take a very
# long time AND may prove worthless.
#
# (2) "PreImagesSet" is used to calculate the preimage of Omega(G/<z>)
# there may be more efficient methods to do this. I have noticed a very
# wide spread of times for the various PreImage functions.

# Omega(G,p,e) is a normal, characteristic, fully invariant subgroup that
# behaves nicely under group homomorphisms. In particular
# if Omega(G/N)=K/N then Omega(G) <= K. If Omega(G) <= K,
# then Omega(G)=Omega(K).
#
# Hence the general strategy is to find good upper bounds K for
# Omega(G), and then compute Omega(K) instead. It is difficult
# to tell when one's upper bound is actually equal to Omega(G),
# so we attempt to terminate early by finding good lower bounds
# H as well.
#
# Assumed: G is a p-group, e is a positive integer
BindGlobal("Omega_Sims_CENTRAL",100);
BindGlobal("Omega_Sims_RUNTIME",5000);


#Choose a central element z of order p.  Suppose that by induction
#we know H = Omega(G/<z>).  Then Omega(G) is contained in the inverse
#image K of H in G.  Compute K/K'.  If that quotient has elements of
#order p^2, then we can cut K down a bit.  Thus we may assume that we
#know a normal subgroup K of G that contains Omega(G), K maps into
#H, and K/K' has exponent p.  One would hope that K is small enough
#that random methods combined with deterministic computations would
#make it possible to compute Omega(K) = Omega(G).
#-Charles Sims
BindGlobal("Omega_Sims",
function(G,p,e)
local H,K,Knew,fails,r, timerFunc;

  timerFunc := GET_TIMER_FROM_ReproducibleBehaviour();

  if(IsTrivial(G)) then return G; fi;

  K:=G;
  H:=Omega_LowerBound(K,p,e);
  if(H=K) then return K; fi;

  # Step 1, reduce until K/K' = Omega(K/K') then Omega(G)=Omega(K)
  while (true) do # there is a `break' below
    Knew:=Omega_UpperBoundAbelianQuotient(K,p,e);
    if(Knew=K) then break; fi;
    K:=Knew;
  od;

  if (H=K) then
    return K;
  fi;

  # Step 2, reduce until we have fail lots of times in a row
  # or waste a lot of time.
  r:=timerFunc();
  fails:=0;
  while(fails<Omega_Sims_CENTRAL and timerFunc()-r<Omega_Sims_RUNTIME) do
    Knew:=Omega_UpperBoundCentralQuotient(K,p,e);
    if(K=Knew) then fails:=fails+1; continue; fi;
    fails:=0;
    K:=Knew;
    if(H=K) then return H; fi;
  od;

  # Step 3: Repeat step 1
  while(true) do
    Knew:=Omega_UpperBoundAbelianQuotient(K,p,e);
    if(Knew=K) then break; fi;
    K:=Knew;
  od;
  if(H=K) then return K; fi;

  # Step 4: If K<G, then we have reduced the problem, so just ask for Omega(K,p,e) directly.
  if(K<>G) then return Omega(K,p,e); fi;

    # Otherwise we try to search.
    if(Size(G)<2^24) then return Omega_Search(G,p,e); fi;

    # If the group is too big to search, just let the user know. If he wants
    # to continue we can try and return a lower bound, but this is too small
    # quite often.
    Error("Inductive method failed. You may 'return;' if you wish to use a\n",
      "(possible incorrect) lower bound ",H," for Omega.");
    return H;
end);

InstallMethod( OmegaOp, "for p groups", true,
        [ IsGroup, IsPosInt, IsPosInt ], 0,
function( G, p, n )
local   gens,  q,  gen,  ord,  o;

  # trivial cases
  if n=0 then return TrivialSubgroup(G);fi;

  if IsAbelian( G )  then
    q := p^n;
    gens := [  ];
    for gen  in IndependentGeneratorsOfAbelianGroup( G )  do
        ord := Order( gen );
        o := GcdInt( ord, q );
        if o <> 1  then
            Add( gens, gen ^ ( ord / o ) );
        fi;
    od;
    return SubgroupNC( G, gens );
  fi;

  if not PrimePGroup(G)=p then
    TryNextMethod();
  fi;

  if ForAll(Pcgs(G),g->IsOne(g^(p^n))) then
    return G;
  elif(Size(G)<2^15) then
    return Omega_Search(G,p,n);
  else
    return Omega_Sims(G,p,n);
  fi;
end);


############################################################################
##
#M  HallSubgroupOp (<grp>, <pi>)
##
InstallMethod (HallSubgroupOp, "via IsomoprhismPcGroup", true,
    [IsGroup and IsSolvableGroup and IsFinite, IsList], 0,
    function (grp, pi)
        local iso;
        iso := IsomorphismPcGroup (grp);
        return PreImagesSet (iso, HallSubgroup (ImagesSource (iso), pi));
    end);


############################################################################
##
#M  HallSubgroupOp (<grp>, <pi>)
##
RedispatchOnCondition(HallSubgroupOp,true,[IsGroup,IsList],
  [IsSolvableGroup and IsFinite,],1);


############################################################################
##
#M  SylowComplementOp (<grp>, <p>)
##
InstallMethod (SylowComplementOp, "via IsomoprhismPcGroup", true,
    [IsGroup and IsSolvableGroup and IsFinite, IsPosInt], 0,
    function (grp, p)
        local iso;
        iso := IsomorphismPcGroup (grp);
        return PreImagesSet (iso, SylowComplement (ImagesSource (iso), p));
    end);


############################################################################
##
#M  SylowComplementOp (<grp>, <p>)
##
RedispatchOnCondition(SylowComplementOp,true,[IsGroup,IsPosInt],
  [IsSolvableGroup and IsFinite,
  IsPosInt ],1);

InstallMethod( FittingFreeLiftSetup, "pc group", true, [ IsPcGroup ],0,
function( G )
local   pcgs;

  pcgs:=PcgsElementaryAbelianSeries(G);
  return rec(pcgs:=pcgs,
             depths:=IndicesEANormalSteps(pcgs),
             radical:=G,
             pcisom:=IdentityMapping(G),
             factorhom:=NaturalHomomorphismByNormalSubgroupNC(G,G));

end );

#############################################################################
##
#M  IsomorphismPermGroup( <G> ) . . . . . . . . .  for solvable group
##
InstallMethod( IsomorphismPermGroup,
    "solvable groups, e.g. Hall action",
    [ IsGroup and IsFinite and IsSolvableGroup and CanEasilyComputePcgs ],
function ( G )
local d,i,j,a,iso,ims,s,p,abovent;
  if IsAbelian(G) then
    # force redispatch on abelian group
    return IsomorphismAbelianGroupViaIndependentGenerators(IsPermGroup,G);
  elif Size(G)<=100 and Size(G)<>64 then
    # for these orders the optimal degree is fast enough
    iso:=MinimalFaithfulPermutationRepresentation(G);
    Info(InfoPcGroup,1,"Use optimal degree ",
      Size(G),":",NrMovedPoints(Range(iso)));
    return iso;
  fi;

  # can be subdirect?
  d:=MinimalNormalSubgroups(G);
  if Length(d)>1 then
    # it can -- find a nice decomposition in two

    # take two largest
    d:=ShallowCopy(d);
    SortBy(d,x->-Size(x));
    abovent:=function(a,b)
    local hom,n;
      hom:=NaturalHomomorphismByNormalSubgroupNC(G,a);
      b:=Image(hom,b);
      n:=NormalSubgroups(Image(hom,a));
      n:=Filtered(n,x->not IsSubset(x,b));
      SortBy(n,x->-Size(x)); # descending order
      return List(n,x->PreImage(hom,x));
    end;

    d:=[abovent(d[1],d[2]),abovent(d[2],d[1])];
    if Size(d[2][1])>Size(d[1][1]) then d:=Reversed(d);fi;
    d:=[d[1][1],First(d[2],x->Size(Intersection(x,d[1][1]))=1)];
    Info(InfoPcGroup,1,"Subdirect ",List(d,x->Size(G)/Size(x)));
    iso:=List(d,x->NaturalHomomorphismByNormalSubgroupNC(G,x));
    d:=List(iso,x->IsomorphismPermGroup(Image(x,G)));
    ims:=List([1,2],x->List(GeneratorsOfGroup(G),
      y->ImagesRepresentative(d[x],ImagesRepresentative(iso[x],y))));
    ims:=SubdirectDiagonalPerms(ims[1],ims[2]);
    d:=Group(ims);
    UseIsomorphismRelation(G,d);
    s:=SmallerDegreePermutationRepresentation(d:cheap);
    if NrMovedPoints(Range(s))<NrMovedPoints(d) then
      ims:=List(ims,x->ImagesRepresentative(s,x));
      d:=Image(s);
      UseIsomorphismRelation(G,d);
    fi;
    iso:=GroupHomomorphismByImagesNC(G,d,GeneratorsOfGroup(G),ims);
    Assert(1,IsBijective(iso));
    SetIsBijective(iso,true);
    return iso;
  fi;

  p:=Collected(Factors(Size(G)));
  if Length(p)>1 then
    d:=Combinations(p);
    SortBy(d,x->-Product(x,y->y[1]^y[2]));
    for i in d do
      s:=HallSubgroup(G,List(i,x->x[1]));
      if Size(Core(G,s))=1 then
        Info(InfoPcGroup,1,"Hall ",List(i,x->x[1]));

        # try normalizer quotient
        d:=Normalizer(G,s);
        if Size(Core(G,d))=1 then
          s:=d;
        else
          d:=ShallowCopy(IntermediateSubgroups(d,s).subgroups);
          SortBy(d,x->-Size(x));
          a:=First(d,x->Size(Core(G,x))=1);
          if a<>fail then s:=a;fi;
        fi;

        iso:=FactorCosetAction(G,s);
        Assert(1,IsBijective(iso));
        SetIsBijective(iso,true);
        d:=Image(iso);
        UseIsomorphismRelation(G,d);
        return iso;
      fi;
    od;

  else
    # p-group, one minimal: try to go from factor permrep
    d:=MinimalNormalSubgroups(G)[1];
    ims:=NaturalHomomorphismByNormalSubgroupNC(G,d);
    iso:=IsomorphismPermGroup(Image(ims,G));
    ims:=ims*iso;
    a:=Image(ims,G);
    Info(InfoPcGroup,1,"Factor ",List(Orbits(a,MovedPoints(a)),Length));
    s:=List(Orbits(a,MovedPoints(a)),x->Stabilizer(a,x[1]));
    s:=List(s,x->PreImage(ims,x));
    SortBy(s,x->-Size(x));
    for j in [1..Length(Factors(Size(s[1])))] do
      for i in [1..Length(s)] do
        p:=LowLayerSubgroups(s[i],j);
        p:=Filtered(p,x->not IsSubset(x,d));
        if Length(p)>0 then
          d:=Maximum(List(p,Size));
          iso:=FactorCosetAction(G,First(p,x->Size(x)=d));
          ims:=[List(GeneratorsOfGroup(G),x->ImagesRepresentative(iso,x)),
            List(GeneratorsOfGroup(G),x->ImagesRepresentative(ims,x))];
          ims:=SubdirectDiagonalPerms(ims[1],ims[2]);
          d:=Group(ims);
          UseIsomorphismRelation(G,d);
          s:=SmallerDegreePermutationRepresentation(d:cheap);
          if NrMovedPoints(Range(s))<NrMovedPoints(d) then
            ims:=List(ims,x->ImagesRepresentative(s,x));
            d:=Image(s);
            UseIsomorphismRelation(G,d);
          fi;
          iso:=GroupHomomorphismByImagesNC(G,d,GeneratorsOfGroup(G),ims);
          Assert(1,IsBijective(iso));
          SetIsBijective(iso,true);
          return iso;
        fi;
      od;
    od;

    Error("should never happen");
  fi;
end);
