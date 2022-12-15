#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#M  DirectProductOp( <list>, <G> )
##
InstallMethod( DirectProductOp,
    "for a list (of pc groups), and a pc group",
    true,
    [ IsList, IsPcGroup ], 0,
    function( list, pcgp )
    local len, F, gensF, relsF, s, G, pcgsG, isoG, FG, relsG, gensG, n, D,
          info, first;

    # Check the arguments.
    if ForAny( list, G -> not IsPcGroup( G ) ) then
      TryNextMethod();
    fi;

    len := Sum( List( list, x -> Length( Pcgs( x ) ) ) );
    F   := FreeGroup(IsSyllableWordsFamily, len );
    gensF := GeneratorsOfGroup( F );
    relsF := [];

    s := 0;
    first := [1];
    for G in list do

        pcgsG := Pcgs( G );
        isoG  := IsomorphismFpGroupByPcgs( pcgsG, "F" );
        FG    := Range( isoG );
        relsG := RelatorsOfFpGroup( FG );
        gensG := GeneratorsOfGroup( FreeGroupOfFpGroup( FG ) );
        n     := s + Length( pcgsG );
        Append( relsF, List( relsG,
                       x -> MappedWord( x, gensG, gensF{[s+1..n]} ) ) );
        s := n;
        Add( first, n+1 );
    od;

    # create direct product
    D := PcGroupFpGroup( F / relsF );

    # create info
    info := rec( groups := list,
                 first  := first,
                 embeddings := [],
                 projections := [] );
    SetDirectProductInfo( D, info );
    return D;
end );


#############################################################################
##
#A Embedding
##
InstallMethod( Embedding,
        "of pc group and integer",
         true,
         [ IsPcGroup and HasDirectProductInfo, IsPosInt ],
         0,
    function( D, i )
    local info, G, imgs, hom, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then
        return info.embeddings[i];
    fi;

    # compute embedding
    G   := info.groups[i];
    gens := Pcgs( G );
    imgs := Pcgs(D){[info.first[i] .. info.first[i+1]-1]};
    hom := GroupHomomorphismByImagesNC( G, D, gens, imgs );
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A Projection
##
InstallMethod( Projection,
        "of pc group and integer",
         true,
         [ IsPcGroup and HasDirectProductInfo, IsPosInt ],
         0,
    function( D, i )
    local info, G, imgs, hom, N, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then
        return info.projections[i];
    fi;

    # compute projection
    G    := info.groups[i];
    gens := Pcgs( D );
    imgs := Concatenation( List( [1..info.first[i]-1], x -> One( G ) ),
                           Pcgs( G ),
                           List( [info.first[i+1]..Length(gens)], x -> One(G)));
    hom := GroupHomomorphismByImagesNC( D, G, gens, imgs );
    N := SubgroupNC( D, gens{Concatenation( [1..info.first[i]-1],
                           [info.first[i+1]..Length(gens)] )} );
    SetIsSurjective( hom, true );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections[i] := hom;
    return hom;
end );

#############################################################################
##
#M SemidirectProduct
##
InstallMethod( SemidirectProduct,
    "generic method for pc groups",
    true,
    [ CanEasilyComputePcgs, IsGroupHomomorphism, CanEasilyComputePcgs ],
    {} -> 2*RankFilter(IsFinite), # ensure this is ranked higher than the generic method
function( G, aut, N )
    local info, H;
    H := SplitExtension( G, aut, N );
    info := rec( groups := [G, N],
                 lenlist := [0, Length(Pcgs(G)), Length(Pcgs(H))],
                 embeddings := [],
                 projections := true );
    SetSemidirectProductInfo( H, info );
    return H;
end );

InstallOtherMethod( SemidirectProduct,
    "generic method for pc groups",
    true,
    [ IsPcGroup, IsRecord],
    0,
function( G, M )
    local H, info;
    H := Extension( G, M, 0 );
    info := rec( groups := [G, AbelianGroup(
                 List([1..M.dimension], x -> Characteristic(M.field)) )],
                 lenlist := [0, Length(Pcgs(G)), Length(Pcgs(H))],
                 embeddings := [],
                 projections := true );
    SetSemidirectProductInfo( H, info );
    return H;
end );

InstallOtherMethod( SemidirectProduct,
    "generic method for pc groups",
    true,
    [ IsPcGroup, IsGroupHomomorphism],
    0,
function( G, pr )
    local U, M;
    U := Image( pr );
    M := rec( dimension  := DimensionOfMatrixGroup( U ),
              field      := FieldOfMatrixGroup( U ),
              generators := List( Pcgs( G ), x -> Image( pr, x ) ) );
    return SemidirectProduct( G, M );
end );

#############################################################################
##
#A Embedding
##
InstallMethod( Embedding,
        "of semidirect pc group and integer",
         true,
         [ IsPcGroup and HasSemidirectProductInfo, IsPosInt ],
         0,
    function( D, i )
    local info, G, imgs, hom;

    # check
    info := SemidirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then
        return info.embeddings[i];
    fi;

    # compute embedding
    G := info.groups[i];
    imgs := Pcgs(D){[info.lenlist[i]+1 .. info.lenlist[i+1]]};
    hom := GroupHomomorphismByImagesNC( G, D, AsList( Pcgs(G) ), imgs );
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A Projection
##
InstallOtherMethod( Projection,"of semidirect pc group",true,
         [ IsPcGroup and HasSemidirectProductInfo ],
         0,
    function( D )
    local info, G, imgs, hom, N, list;

    # check
    info := SemidirectProductInfo( D );
    if not IsBool( info.projections ) then
        return info.projections;
    fi;

    # compute projection
    G    := info.groups[1];
    list := info.lenlist;
    imgs := Concatenation( AsList( Pcgs(G) ),
                           List( [list[2]+1..list[3]], x -> One(G)) );
    hom := GroupHomomorphismByImagesNC( D, G, AsList( Pcgs(D) ), imgs );
    N := SubgroupNC( D, Pcgs(D){[list[2]+1..list[3]]});
    SetIsSurjective( hom, true );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections := hom;
    return hom;
end );

##
InstallGlobalFunction(SubdirProdPcGroups,function(G,gi,H,hi)
local mg,mh,kg,kh,pkg,pkh,fp,fh,F,coll,gens,fpgens,pggens,phgens,i,j,
      e,w,pow,b2,b3,comm,id;
  mg:=GroupGeneralMappingByImagesNC(G,H,gi,hi);
  kh:=CoKernelOfMultiplicativeGeneralMapping(mg);
  mh:=GroupGeneralMappingByImagesNC(H,G,hi,gi);
  kg:=CoKernelOfMultiplicativeGeneralMapping(mh);

  #trivial cases?
  if Size(kh)=1 then
    return [G,gi];
  elif Size(kg)=1 then
    return [H,hi];
  fi;


  # get a new pcgs for g through kg
  pkg:=InducedPcgs(FamilyPcgs(G),kg);
  pkh:=InducedPcgs(FamilyPcgs(H),kh);
  fp:=FamilyPcgs(G) mod pkg;
  b2:=Length(fp);
  b3:=Length(fp)+Length(pkg);
  fh:=List(fp,i->ImagesRepresentative(mg,i));
  F:=FreeGroup(IsSyllableWordsFamily,Length(fp)+Length(pkg)+Length(pkh));
  gens:=GeneratorsOfGroup(F);
  fpgens:=gens{[1..b2]};
  pggens:=gens{[b2+1..b3]};
  phgens:=gens{[b3+1..Length(gens)]};
  coll:=SingleCollector(F,Concatenation(
                        RelativeOrders(fp),
                        RelativeOrders(pkg),
                        RelativeOrders(pkh)
                        ));
  id:=One(F);


  # power relations

  # for fp
  for i in [1..Length(fp)] do
    pow:=fp[i]^RelativeOrders(fp)[i];
    e:=ExponentsOfPcElement(fp,pow);
    w:=LinearCombinationPcgs(fpgens,e,One(F));

    # the rest in kg
    pow:=LeftQuotient(PcElementByExponentsNC(fp,e),pow);
    w:=w*LinearCombinationPcgs(pggens,ExponentsOfPcElement(pkg,pow),One(F));

    # rest in kh
    pow:=LeftQuotient(LinearCombinationPcgs(fh,e,One(H)),fh[i]^RelativeOrders(fp)[i]);
    w:=w*LinearCombinationPcgs(phgens,ExponentsOfPcElement(pkh,pow),One(F));

    if w<>id then
      SetPower(coll,i,w);
    fi;
  od;

  # for pkg
  for i in [1..Length(pkg)] do
    pow:=pkg[i]^RelativeOrders(pkg)[i];
    e:=ExponentsOfPcElement(pkg,pow);
    w:=LinearCombinationPcgs(pggens,e,One(F));
    if w<>id then
      SetPower(coll,i+b2,w);
    fi;
  od;

  # for pkh
  for i in [1..Length(pkh)] do
    pow:=pkh[i]^RelativeOrders(pkh)[i];
    e:=ExponentsOfPcElement(pkh,pow);
    w:=LinearCombinationPcgs(phgens,e,One(F));
    if w<>id then
      SetPower(coll,i+b3,w);
    fi;
  od;

  # commutator relations
  # for fp
  for i in [1..Length(fp)] do
    # on fp
    for j in [i+1..Length(fp)] do
      comm:=Comm(fp[j],fp[i]);
      e:=ExponentsOfPcElement(fp,comm);
      w:=LinearCombinationPcgs(fpgens,e,One(F));

      # the rest in kg
      comm:=LeftQuotient(PcElementByExponentsNC(fp,e),comm);
      w:=w*LinearCombinationPcgs(pggens,ExponentsOfPcElement(pkg,comm),One(F));

      # rest in kh
      comm:=LeftQuotient(LinearCombinationPcgs(fh,e,One(H)),Comm(fh[j],fh[i]));
      w:=w*LinearCombinationPcgs(phgens,ExponentsOfPcElement(pkh,comm),One(F));

      if w<>id then
        SetCommutator(coll,j,i,w);
      fi;
    od;

    #on pkg
    for j in [1..Length(pkg)] do
      comm:=Comm(pkg[j],fp[i]);
      w:=LinearCombinationPcgs(pggens,ExponentsOfPcElement(pkg,comm),One(F));

      if w<>id then
        SetCommutator(coll,j+b2,i,w);
      fi;
    od;

    #on pkh
    for j in [1..Length(pkh)] do
      comm:=Comm(pkh[j],fh[i]);
      w:=LinearCombinationPcgs(phgens,ExponentsOfPcElement(pkh,comm),One(F));

      if w<>id then
        SetCommutator(coll,j+b3,i,w);
      fi;
    od;

  od;

  # for pkg
  for i in [1..Length(pkg)] do
    for j in [i+1..Length(pkg)] do
      comm:=Comm(pkg[j],pkg[i]);
      e:=ExponentsOfPcElement(pkg,comm);
      w:=LinearCombinationPcgs(pggens,e,One(F));

      if w<>id then
        SetCommutator(coll,j+b2,i+b2,w);
      fi;
    od;
  od;

  # for pkh
  for i in [1..Length(pkh)] do
    for j in [i+1..Length(pkh)] do
      comm:=Comm(pkh[j],pkh[i]);
      e:=ExponentsOfPcElement(pkh,comm);
      w:=LinearCombinationPcgs(phgens,e,One(F));

      if w<>id then
        SetCommutator(coll,j+b3,i+b3,w);
      fi;
    od;
  od;

  w:=GroupByRwsNC(coll);

  # compute the corresponding images
  gens:=FamilyPcgs(w);
  fpgens:=gens{[1..b2]};
  pggens:=gens{[b2+1..b3]};
  phgens:=gens{[b3+1..Length(gens)]};
  comm:=[];
  for i in [1..Length(gi)] do
    e:=ExponentsOfPcElement(fp,gi[i]);
    Add(comm,LinearCombinationPcgs(fpgens,e,One(w))
            *LinearCombinationPcgs(pggens,ExponentsOfPcElement(pkg,
              LeftQuotient(LinearCombinationPcgs(fp,e,One(G)),gi[i])),One(w))
            *LinearCombinationPcgs(phgens,ExponentsOfPcElement(pkh,
              LeftQuotient(LinearCombinationPcgs(fh,e,One(H)),hi[i])),One(w)));
  od;

  return [w,comm];

end);

#############################################################################
##
#M  SubdirectProduct( <G1>, <G2>, <phi1>, <phi2> )
##
InstallMethod( SubdirectProductOp,"pcgroup", true,
  [ IsPcGroup, IsPcGroup, IsGroupHomomorphism, IsGroupHomomorphism ], 0,
function( G, H, gh, hh )
local pg,ph,kg,kh,ig,ih,mg,mh,S,info;
  pg:=Pcgs(G);
  ph:=Pcgs(H);
  kg:=KernelOfMultiplicativeGeneralMapping(gh);
  kh:=KernelOfMultiplicativeGeneralMapping(hh);
  ig:=InducedPcgs(pg,kg);
  ih:=InducedPcgs(ph,kh);
  mg:=pg mod ig;
  mh:=List(mg,i->PreImagesRepresentative(hh,Image(gh,i)));
  pg:=Concatenation(mg,ig,List(ih,i->One(G)));
  ph:=Concatenation(mh,List(ig,i->One(H)),ih);
  S:=SubdirProdPcGroups(G,pg,H,ph);
  pg:=GroupHomomorphismByImagesNC(S[1],G,S[2],pg);
  ph:=GroupHomomorphismByImagesNC(S[1],H,S[2],ph);
  S:=S[1];
  info:=rec(groups:=[G,H],
            homomorphisms:=[gh,hh],
            projections:=[pg,ph]);
  SetSubdirectProductInfo(S,info);
  return S;
end);
