#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Alexander Hulpke, Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  1. Functions for creating group general mappings by images
##  2. Functions for creating natural homomorphisms
##  3. Functions for conjugation action
##  4. Functions for ...
##


#############################################################################
##
#F  GroupHomomorphismByImages( <G>, <H>, <Ggens>, <Hgens> )
#F  GroupHomomorphismByImages( <G>, <H>, <Hgens> )
#F  GroupHomomorphismByImages( <G>, <H> )
##
InstallGlobalFunction( GroupHomomorphismByImages,

function( arg )

    local  hom, G, H, Ggens, Hgens,arrgh;

    arrgh:=arg;
    if   not Length(arrgh) in [2..4]
      or not IsGroup(arrgh[1]) #or not IsGroup(arrgh[2])
    then Error("for usage, see ?GroupHomomorphismByImages"); fi;

    if not IsGroup(arrgh[2]) then
      arrgh:=Concatenation([arrgh[1],Group(arrgh[Length(arrgh)])],
                           arrgh{[2..Length(arrgh)]});
    fi;

    G := arrgh[1]; H := arrgh[2];

    if   Length(arrgh) = 2
    then Ggens := GeneratorsOfGroup(G); Hgens := GeneratorsOfGroup(H);
    elif Length(arrgh) = 3
    then Ggens := GeneratorsOfGroup(G); Hgens := arrgh[3];
    elif Length(arrgh) = 4
    then Ggens := arrgh[3]; Hgens := arrgh[4];
    fi;

    if Length(Ggens)>0 then
      if not (IsDenseList(Ggens) and IsHomogeneousList(Ggens) and
        FamilyObj(Ggens)=FamilyObj(G)) then
        Error("The generators do not all belong to the source");
      fi;
    fi;

    if Length(Hgens)>0 then
      if not (IsDenseList(Hgens) and IsHomogeneousList(Hgens) and
        FamilyObj(Hgens)=FamilyObj(H)) then
        Error("The images do not all belong to the range");
      fi;
    fi;

    hom:= GroupGeneralMappingByImages( G, H, Ggens, Hgens );

    if IsMapping( hom ) then
      return hom;
      # was GroupHomomorphismByImagesNC( G, H, Ggens, Hgens ), but why
      # should we create a new object again?;
    else
      return fail;
    fi;

  end );


#############################################################################
##
#M  RestrictedMapping(<hom>,<U>)
##
InstallMethod(RestrictedMapping,"try if restriction is proper",
  CollFamSourceEqFamElms,[IsGroupGeneralMapping,IsGroup],SUM_FLAGS,
function(hom, U)
  if IsSubset (U, Source (hom)) then
      return hom;
  fi;
  TryNextMethod();
end);


#############################################################################
##
#M  RestrictedMapping(<hom>,<U>)
##
InstallMethod(RestrictedMapping,"create new GHBI",
  CollFamSourceEqFamElms,[IsGroupHomomorphism,IsGroup],0,
function(hom,U)
local rest,gens,imgs,imgp;

  gens:=GeneratorsOfGroup(U);
  imgs:=List(gens,i->ImageElm(hom,i));

  if HasImagesSource(hom) then
    imgp:=ImagesSource(hom);
  else
    imgp:=Subgroup(Range(hom),imgs);
  fi;
  rest:=GroupHomomorphismByImagesNC(U,imgp,gens,imgs);
  if HasIsInjective(hom) and IsInjective(hom) then
    SetIsInjective(rest,true);
  fi;
  if HasIsTotal(hom) and IsTotal(hom) then
    SetIsTotal(rest,true);
  fi;

  return rest;
end);


#############################################################################
##
#M  RestrictedMapping(<hom>,<U>)
##
InstallMethod(RestrictedMapping,"injective case: use GeneralRestrictedMapping",
  CollFamSourceEqFamElms,[IsGroupHomomorphism and IsInjective,IsGroup],0,
function(hom,U)

  if IsGroupGeneralMappingByImages(hom) then # restrictions of GHBI should be GHBI
        TryNextMethod();
  fi;

  return GeneralRestrictedMapping (hom, U, Range(hom));
end);


#############################################################################
##
#M  <a> = <b> . . . . . . . . . . . . . . . . . . . . . . . . . .  via images
##
InstallMethod( \=, "compare source generator images", IsIdenticalObj,
    [ IsGroupGeneralMapping, IsGroupGeneralMapping ], 0,
    function( a, b )
    local i;

    # try to fall back on homomorphism routines
    if IsSingleValued(a) and IsSingleValued(b) then
      # As both are single valued (and the appropriate flags are now set)
      # we will automatically fall in the routines for homomorphisms.
      # So this is not an infinite recursion.
#T is this really safe?
      a:=MappingGeneratorsImages(a);
      return a[2]=List(a[1],i->ImagesRepresentative(b,i));
    fi;

    # now do the hard test
    if Source(a)<>Source(b)
       or Range(a)<>Range(b)
       or PreImagesRange(a)<>PreImagesRange(b)
       or ImagesSource(a)<>ImagesSource(b) then
      return false;
    fi;
    for i in PreImagesRange(a) do
      if Set(Images(a,i))<>Set(Images(b,i)) then
        return false;
      fi;
    od;
    return true;
    end );

#############################################################################
##
#M  IsOne( <hom> )
##
InstallMethod(IsOne,"using `MappingGeneratorsImages'",true,
  [IsGroupHomomorphism and HasMappingGeneratorsImages],0,
function(a)
  local m;
  # if a is total it is defined on all of the source, if gens and images are
  # the same it automatically is bijective
  if Source(a)=Range(a) and IsTotal(a) then
    m:=MappingGeneratorsImages(a);
    return ForAll([1..Length(m[1])],i->m[1][i]=m[2][i]);
  fi;
  return false;
end);

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . . . . . . . . . . .  via images
##
##  The composition of two group general mappings can be computed as
##  a group general mapping by images, *provided* that
##  - elements of the source of the first map can be cheaply decomposed
##    in terms of the generators
##    (This is needed for computing images with a
##    group general mapping by images.)
##    and
##  - we are *not* in the situation of the composition of a general mapping
##    with a nice monomorphism.
##    (Here it will usually be better to store the explicit composition
##    of two mappings, think of an isomorphism from a matrix group to a
##    permutation group, where both the action homomorphism and the
##    isomorphism of two permutation groups can compute (pre)images
##    efficiently, contrary to the composition when this is written as
##    homomorphism by images.)
##
##  (If both general mappings know that they are in fact homomorphisms
##  then also the result will be a homomorphism; this is not done
##  here, however, but rather in function CompositionMapping.)
##
InstallMethod( CompositionMapping2,
    "for gp. hom. and gp. gen. mapp., using `MappingGeneratorsImages'",
    FamSource1EqFamRange2,
    [ IsGroupHomomorphism, IsGroupGeneralMapping ], 0,
function( hom1, hom2 )
local mapi;
  if (not KnowsHowToDecompose(Source(hom2))) or IsNiceMonomorphism(hom2) then
    TryNextMethod();
  fi;
  if not IsSubset(Source(hom1),ImagesSource(hom2)) then
    TryNextMethod();
  fi;
  mapi:=MappingGeneratorsImages(hom2);
  return GroupGeneralMappingByImagesNC( Source( hom2 ), Range( hom1 ),
            mapi[1], List( mapi[2], img ->
            ImagesRepresentative( hom1, img ) ) );
end);


InstallOtherMethod( SetInverseGeneralMapping,"transfer the AsGHBI", true,
     [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
       HasAsGroupGeneralMappingByImages,
       IsGeneralMapping ], 0,
function( hom, inv )
   SetInverseGeneralMapping( AsGroupGeneralMappingByImages( hom ), inv );
   TryNextMethod();
end );

InstallOtherMethod( SetRestrictedInverseGeneralMapping,"transfer the AsGHBI", true,
     [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
       HasAsGroupGeneralMappingByImages,
       IsGeneralMapping ], 0,
function( hom, inv )
   SetRestrictedInverseGeneralMapping( AsGroupGeneralMappingByImages( hom ), inv );
   TryNextMethod();
end );


#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . .  via images
##
InstallMethod( ImagesRepresentative, "for `ByAsGroupGeneralMapping' hom",
    FamSourceEqFamElm,
    [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages,
      IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
  return ImagesRepresentative( AsGroupGeneralMappingByImages( hom ), elm );
end );


#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . .  via images
##
InstallMethod( PreImagesRepresentative, "for PBG-Hom", FamRangeEqFamElm,
  [ IsPreimagesByAsGroupGeneralMappingByImages,
    IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
  if HasIsHandledByNiceMonomorphism(Source(hom)) then
    # if we use the `AsGGMBI' directly, it will be a composite through a big
    # group
    return ImagesRepresentative( RestrictedInverseGeneralMapping( hom ), elm );
  else
    return PreImagesRepresentative( AsGroupGeneralMappingByImages( hom ), elm );
  fi;
end );

InstallAttributeMethodByGroupGeneralMappingByImages( CoKernelOfMultiplicativeGeneralMapping );
InstallAttributeMethodByGroupGeneralMappingByImages( KernelOfMultiplicativeGeneralMapping );
InstallAttributeMethodByGroupGeneralMappingByImages( PreImagesRange );
InstallAttributeMethodByGroupGeneralMappingByImages( ImagesSource );
InstallAttributeMethodByGroupGeneralMappingByImages( IsSingleValued );
InstallAttributeMethodByGroupGeneralMappingByImages( IsInjective );
InstallAttributeMethodByGroupGeneralMappingByImages( IsTotal );
InstallAttributeMethodByGroupGeneralMappingByImages( IsSurjective );


#############################################################################
##
#M  GroupGeneralMappingByImages( <G>, <H>, <gens>, <imgs> ) . . . . make GHBI
##
BindGlobal("DoGGMBINC",function( G, H, gens, imgs )
local   filter,  hom,pcgs,mapi,l,obj_args,p;

  hom := rec();
  # generators := Immutable( gens ),
  # genimages  := Immutable( imgs ) );
  if Length(gens)<>Length(imgs) then
    Error("<gens> and <imgs> must be lists of same length");
  fi;

  if not HasIsHandledByNiceMonomorphism(G) and ValueOption("noassert")<>true then
    Assert( 2, ForAll( gens, x -> x in G ) );
  fi;
  if not HasIsHandledByNiceMonomorphism(H) and ValueOption("noassert")<>true then
    Assert( 2, ForAll( imgs, x -> x in H ) );
  fi;

  mapi:=[Immutable(gens),Immutable(imgs)];
  filter := IsGroupGeneralMappingByImages and HasSource and HasRange
            and HasMappingGeneratorsImages;

  if IsPermGroup( G )  then
      filter := filter and IsPermGroupGeneralMappingByImages;
  fi;
  if IsPermGroup( H )  then
      filter := filter and IsToPermGroupGeneralMappingByImages;
  fi;

  pcgs:=false; # default: no pc groups code
  if IsPcGroup( G ) and IsPrimeOrdersPcgs(Pcgs(G))  then
    filter := filter and IsPcGroupGeneralMappingByImages;
    pcgs  := CanonicalPcgsByGeneratorsWithImages( Pcgs(G), mapi[1], mapi[2] );
    if pcgs[1]=Pcgs(G) then
      filter:=filter and IsTotal;
    fi;
  elif IsPcgs( gens )  then
    filter := filter and IsGroupGeneralMappingByPcgs;
    pcgs:=mapi;
  fi;

  if pcgs<>false then
    hom.sourcePcgs       := pcgs[1];
    hom.sourcePcgsImages := pcgs[2];
  fi;

  if IsPcGroup( H )  then
    filter := filter and IsToPcGroupGeneralMappingByImages;
  fi;

  # Do we map a subgroup of a free group or an fp group by a subset of its
  # standard generators?
  # (So we can used MappedWord for mapping)?
  if IsSubgroupFpGroup(G) then
    if HasIsWholeFamily(G) and IsWholeFamily(G)
      # total on free generators
      and Set(FreeGeneratorsOfWholeGroup(G))=Set(gens,UnderlyingElement)
      then
        l:=List(gens,UnderlyingElement);
        p:=List(l,i->Position(FreeGeneratorsOfWholeGroup(G),i));
        # test for duplicate generators, same images
        if Length(gens)=Length(FreeGeneratorsOfWholeGroup(G)) or
          ForAll([1..Length(gens)],x->imgs[x]=imgs[Position(l,l[x])]) then
          filter := filter and IsFromFpGroupStdGensGeneralMappingByImages;
          hom.genpositions:=p;
        else
          filter := filter and IsFromFpGroupGeneralMappingByImages;
        fi;
    else
      filter := filter and IsFromFpGroupGeneralMappingByImages;
    fi;
  fi;
  if IsSubgroupFpGroup(H) then
      filter := filter and IsToFpGroupGeneralMappingByImages;
  fi;

  obj_args := [
    hom,
    , # Here the type will be inserted
    Source, G,
    Range, H,
    MappingGeneratorsImages, mapi ];

  if HasGeneratorsOfGroup(G)
     and IsIdenticalObj(GeneratorsOfGroup(G),mapi[1]) then
    Append(obj_args, [PreImagesRange, G]);
    filter := filter and IsTotal and HasPreImagesRange;
  fi;

  if HasGeneratorsOfGroup(H)
     and IsIdenticalObj(GeneratorsOfGroup(H),mapi[2]) then
    Append(obj_args, [ImagesSource, H]);
    filter := filter and IsSurjective and HasImagesSource;
  elif pcgs <> false then
    # The following code is only guaranteed to be correct if the map is
    # single valued.
    #if RankFilter(filter) = RankFilter(filter and IsSingleValued) then
    #  imgso:=SubgroupNC( H, pcgs[2]);
    #  Append(obj_args, [ImagesSource, imgso]);
    #fi;
  fi;

  obj_args[2] :=
    NewType( GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                    ElementsFamily( FamilyObj( H ) ) ),
             filter );

  CallFuncList(ObjectifyWithAttributes, obj_args);

  return hom;
end );

InstallMethod( GroupGeneralMappingByImagesNC, "for group, group, list, list",
    true, [ IsGroup, IsGroup, IsList, IsList ], 0, DoGGMBINC);

InstallMethod( GroupGeneralMappingByImagesNC, "make onto",
    true, [ IsGroup, IsList, IsList ], 0,
function( G, gens, imgs )
    return GroupGeneralMappingByImagesNC(G,GroupWithGenerators(imgs),gens,imgs);
end);

InstallMethod( GroupGeneralMappingByImages, "for group, group, list, list",
    true, [ IsGroup, IsGroup, IsList, IsList ], 0,
function( G, H, gens, imgs )
    if not ForAll(gens,x->x in G) then
      Error("generators must lie in source group");
    elif not ForAll(imgs,x->x in H) then
      Error("images must lie in range group");
    fi;
    return GroupGeneralMappingByImagesNC(G,H,gens,imgs);
end);

InstallMethod( GroupGeneralMappingByImages, "make onto",
    true, [ IsGroup, IsList, IsList ], 0,
function( G, gens, imgs )
    if not ForAll(gens,x->x in G) then
      Error("generators must lie in source group");
    fi;
    return GroupGeneralMappingByImagesNC(G,gens,imgs);
end);

InstallMethod( GroupHomomorphismByImagesNC, "for group, group, list, list",
    true, [ IsGroup, IsGroup, IsList, IsList ], 0,
function( G, H, gens, imgs )
local   hom;
  hom := GroupGeneralMappingByImagesNC( G, H, gens, imgs );
  if not (HasIsHandledByNiceMonomorphism(G) or
    HasIsHandledByNiceMonomorphism(H))
    and ValueOption("noassert")<>true
    and not IsSubgroupFpGroup(H) then
    Assert( 3, IsMapping( hom ) );
  fi;
  SetIsMapping( hom, true );
  return hom;
end );

InstallMethod( GroupHomomorphismByImagesNC, "for group, list, list",
    true, [ IsGroup, IsList, IsList ], 0,
function( G, gens, imgs )
local   hom;
  hom := GroupGeneralMappingByImagesNC( G, gens, imgs );
  if not HasIsHandledByNiceMonomorphism(G) and ValueOption("noassert")<>true then
    Assert( 3, IsMapping( hom ) );
  fi;
  SetIsMapping( hom, true );
  return hom;
end );

InstallOtherMethod( GroupHomomorphismByImagesNC, "for group, group, list",
                    true, [ IsGroup, IsGroup, IsList ], 0,

  function( G, H, imgs )
    return GroupHomomorphismByImagesNC( G, H, GeneratorsOfGroup(G), imgs );
  end );

InstallOtherMethod( GroupHomomorphismByImagesNC, "for group, group",
                    true, [ IsGroup, IsGroup ], 0,

  function( G, H )
    return GroupHomomorphismByImagesNC( G, H, GeneratorsOfGroup(G),
                                              GeneratorsOfGroup(H) );
  end );

#############################################################################
##
#M  MappingGeneratorsImages( <map> )  . . . . . . . .  for group homomorphism
##
InstallMethod( MappingGeneratorsImages, "for group homomorphism",
    true, [ IsGroupHomomorphism ], 0,
function( map )
local gens;
  # temporary workaround for compatibility with external code.
  if IsBound(map!.generators) and IsBound(map!.genimages) then
    Info(InfoWarning,1,"still using !.gen(erators/images)");
    return [map!.generators,map!.genimages];
  fi;
  gens:= GeneratorsOfGroup( PreImagesRange( map ) );
  return [gens, List( gens, g -> ImagesRepresentative( map, g ) ) ];
end );

RedispatchOnCondition(MappingGeneratorsImages,true,
  [IsGeneralMapping],[IsGroupHomomorphism],0);


#############################################################################
##
#M  AsGroupGeneralMappingByImages( <map> )  . . . . .  for group homomorphism
##
InstallMethod( AsGroupGeneralMappingByImages, "for group homomorphism",
    true, [ IsGroupHomomorphism ], 0,
function( map )
local mapi,hom;
  Range(map); # for surjective action homomorphisms this enforces
              # computation of the MappingGeneratorsImages as well
  mapi:=MappingGeneratorsImages(map);
  hom:=GroupHomomorphismByImagesNC(Source(map),Range(map),mapi[1],mapi[2]);
  CopyMappingAttributes(map,hom);
  return hom;
end );

InstallMethod( AsGroupGeneralMappingByImages, "for group general mapping",
    true, [ IsGroupGeneralMapping ], 0,
function( map )
local mapi, cok,hom;
  mapi:=MappingGeneratorsImages(map);
  cok := GeneratorsOfGroup( CoKernelOfMultiplicativeGeneralMapping( map ) );
  hom:=GroupGeneralMappingByImagesNC( Source( map ), Range( map ),
    Concatenation( mapi[1],List(cok,g->One(Source(map)))),
    Concatenation( mapi[2],cok ) );
  CopyMappingAttributes(map,hom);
  return hom;
end );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . . . . . . . . . . .  for GHBI
##
InstallMethod( AsGroupGeneralMappingByImages, "for GHBI", true,
    [ IsGroupGeneralMappingByImages ],
    SUM_FLAGS, # better than everything else
    IdFunc );

#############################################################################
##
#M  MappingOfWhichItIsAsGGMBI
##
InstallMethod(SetAsGroupGeneralMappingByImages,
  "assign MappingOfWhichItIsAsGGMBI",true,
  [ IsGroupGeneralMapping and IsAttributeStoringRep,
    IsGroupGeneralMapping],0,
function(map,as)
  SetMappingOfWhichItIsAsGGMBI(as,map);
  TryNextMethod();
end);

#############################################################################
##
#M  <hom1> = <hom2> . . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( \=,
    "homomorphism by images with homomorphism: compare generator images",
    IsIdenticalObj,
    [ IsGroupHomomorphism and IsGroupGeneralMappingByImages,
      IsGroupHomomorphism ], 1,
    function( hom1, hom2 )
    local   i,mapi;

    if    Source( hom1 ) <> Source( hom2 )
       or Range ( hom1 ) <> Range ( hom2 )  then
        return false;
    fi;
    mapi:=MappingGeneratorsImages(hom1);
    if   IsGroupGeneralMappingByImages( hom2 )
         and Length(MappingGeneratorsImages(hom2)[1]) < Length(mapi[1])  then
        return hom2 = hom1;
    fi;
    for i  in [ 1 .. Length( mapi[1] ) ]  do
        if ImagesRepresentative( hom2, mapi[1][i] ) <> mapi[2][ i ]  then
          return false;
        fi;
    od;
    return true;
end );

InstallMethod( \=,
    "homomorphism with general mapping: test b=a",
    IsIdenticalObj,
    [ IsGroupHomomorphism,
      IsGroupHomomorphism and IsGroupGeneralMappingByImages ], 0,
    function( hom1, hom2 )
    return hom2 = hom1;
end );

InstallMethod( ImagesSmallestGenerators,"group homomorphisms", true,
 [ IsGroupHomomorphism ], 0,
function(a)
  return List(GeneratorsSmallest(Source(a)),i->Image(a,i));
end);

InstallMethod( \<,"group homomorphisms: Images of smallest generators",
    IsIdenticalObj, [ IsGroupHomomorphism, IsGroupHomomorphism ], 0,
function(a,b)
  if Source(a)<>Source(b) then
    return Source(a)<Source(b);
  elif Range(a)<>Range(b) then
    return Range(a)<Range(b);
  else
    return ImagesSmallestGenerators(a)<ImagesSmallestGenerators(b);
  fi;
end);


#############################################################################
##
#M  ImagesSource( <hom> ) . . . . . . . . . . . . . .  for group homomorphism
##
InstallMethod( ImagesSource, "for group homomorphism", true,
    [ IsGroupHomomorphism ],
    # rank higher than the method for IsGroupGeneralMappingByImages,
    # as we can exploit more structure here
    {} -> RankFilter(IsGroupHomomorphism and IsGroupGeneralMappingByImages)
        - RankFilter(IsGroupHomomorphism),
function(hom)
local gens, G;
  gens := GeneratorsOfGroup(Source(hom));
  if Length(MappingGeneratorsImages(hom)[1]) > 2*Length(gens) then
    gens := List(gens, i->ImageElm(hom,i));
  else
    gens := MappingGeneratorsImages(hom)[2];
  fi;
  G := SubgroupNC(Range(hom), gens);

  # Transfer some knowledge about the source group to its image.
  if HasIsInjective(hom) and IsInjective(hom) then
    UseIsomorphismRelation( Source(hom), G );
  elif HasKernelOfMultiplicativeGeneralMapping(hom) then
    UseFactorRelation( Source(hom), KernelOfMultiplicativeGeneralMapping(hom), G );
  else
    UseFactorRelation( Source(hom), fail, G );
  fi;

  return G;
end);

#############################################################################
##
#M  ImagesSource( <hom> ) . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ImagesSource, "for GHBI", true,
    [ IsGroupGeneralMappingByImages ], 0,
    hom -> SubgroupNC( Range( hom ), MappingGeneratorsImages(hom)[2] ) );

#############################################################################
##
#M  PreImagesRange( <hom> ) . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( PreImagesRange, "for GHBI", true,
    [ IsGroupGeneralMappingByImages ], 0,
    hom -> SubgroupNC( Source( hom ), MappingGeneratorsImages(hom)[1] ) );


#############################################################################
##
#M  InverseGeneralMapping( <hom> )  . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( InverseGeneralMapping, "via generators/images", true,
  [ IsGroupGeneralMapping ], 0,
function( hom )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  mapi:=GroupGeneralMappingByImagesNC( Range( hom ),   Source( hom ),
                                      mapi[2], mapi[1] );
  if HasIsSurjective(hom) then
    SetIsTotal(mapi,IsSurjective(hom));
  fi;
  if HasIsTotal(hom) then
    SetIsSurjective(mapi, IsTotal(hom));
  fi;
  if HasIsSingleValued(hom) then
    SetIsInjective(mapi, IsSingleValued(hom) );
  fi;
  if HasIsInjective(hom) then
    SetIsSingleValued(mapi,IsInjective(hom));
  fi;
  SetInverseGeneralMapping( mapi, hom );
  return mapi;
end );

InstallMethod( InverseGeneralMapping, "for bijective GHBI", true,
  [ IsGroupGeneralMappingByImages and IsBijective ], 0,
function( hom )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  mapi:=GroupHomomorphismByImagesNC( Range( hom ),   Source( hom ),
                                      mapi[2], mapi[1]);
  SetIsBijective( mapi, true );
  return mapi;
end );

#############################################################################
##
#M  RestrictedInverseGeneralMapping( <hom> )  .. . . . . . . . . .  for GHBI
##
InstallMethod( RestrictedInverseGeneralMapping, "via generators/images", true,
  [ IsGroupGeneralMapping ], 0,
function( hom )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  mapi:=GroupGeneralMappingByImagesNC( Image( hom ),   Source( hom ),
                                      mapi[2], mapi[1]:noassert );
  SetIsTotal(mapi,true);
  if HasIsTotal(hom) then
    SetIsSurjective(mapi, IsTotal(hom));
  fi;
  if HasIsSingleValued(hom) then
    SetIsInjective(mapi, IsSingleValued(hom) );
  fi;
  if HasIsInjective(hom) then
    SetIsSingleValued(mapi,IsInjective(hom));
  fi;
  SetRestrictedInverseGeneralMapping( mapi, hom );
  return mapi;
end );

InstallMethod( RestrictedInverseGeneralMapping, "for surjective GHBI", true,
  [ IsGroupGeneralMappingByImages and IsSurjective ], 0,
  InverseGeneralMapping);

InstallMethod( RestrictedInverseGeneralMapping, "inverse exists", true,
  [ IsGroupGeneralMappingByImages and HasInverseGeneralMapping ], 0,
function(hom)
  if IsTotal(InverseGeneralMapping(hom)) then
    return InverseGeneralMapping(hom);
  else
    TryNextMethod();
  fi;
end);


#############################################################################
##
#F  MakeMapping( <hom> )  . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallGlobalFunction( MakeMapping, function( hom )
    local   elms,       # elements of subgroup of '<hom>.source'
            elmr,       # representatives of <elms> in '<hom>.elements'
            homelms,homimgs, # intermediate storage
            imgs,       # elements of subgroup of '<hom>.range'
            imgr,       # representatives of <imgs> in '<hom>.images'
            rep,        # one new element of <elmr> or <imgr>
            mapi,       # generators and images
            i, j, k;    # loop variables

    if HasIsFinite(Source(hom)) and not IsFinite(Source(hom)) then
      Error("cannot enumerate an infinite domain");
    fi;
    # if necessary compute the mapping with a Dimino algorithm
    if not IsBound( hom!.elements )  then

        homelms := [ One( Source( hom ) ) ];
        homimgs   := [ One( Range ( hom ) ) ];
        mapi:=MappingGeneratorsImages(hom);
        for i  in [ 1 .. Length( mapi[1] ) ]  do
            elms := ShallowCopy( homelms );
            elmr := [ One( Source( hom ) ) ];
            imgs := ShallowCopy( homimgs );
            imgr := [ One( Range( hom ) ) ];
            j := 1;
            while j <= Length( elmr )  do
                for k  in [ 1 .. i ]  do
                    rep := elmr[j] * mapi[1][k];
                    if not rep in homelms  then
                        Append( homelms, elms * rep );
                        Add( elmr, rep );
                        rep := imgr[j] * mapi[2][k];
                        Append( homimgs, imgs * rep );
                        Add( imgr, rep );
                    fi;
                od;
                j := j + 1;
            od;
            SortParallel( homelms, homimgs );
            IsSSortedList( homelms );  # give a hint that this is a set
#T MakeImmutable!
        od;
        hom!.elements:=homelms;
        hom!.images:=homimgs;
    fi;
end );

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . .  for GHBI
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping, "for GHBI", true,
    [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    local   C,          # co kernel of <hom>, result
            gen,        # one generator of <C>
            mapi,       # generators/images
            i, k;       # loop variables

    # make sure we have the mapping
    if not IsBound( hom!.elements )  then
      MakeMapping( hom );
    fi;
    mapi:=MappingGeneratorsImages(hom);

    # start with the trivial co kernel
    C := TrivialSubgroup( Range( hom ) );

    # for each element of the source and each generator of the source
    for i  in [ 1 .. Length( hom!.elements ) ]  do
        for k  in [ 1 .. Length( mapi[1] ) ]  do

            # the co kernel must contain the corresponding Schreier generator
            gen := hom!.images[i] * mapi[2][k]
                 / hom!.images[ Position( hom!.elements,
                                         hom!.elements[i]*mapi[1][k])];
            #NC is safe
            C := ClosureSubgroupNC( C, gen );

        od;
    od;

    # return the co kernel
    return C;
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . . .  for GHBI
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    hom -> CoKernelOfMultiplicativeGeneralMapping(
               RestrictedInverseGeneralMapping( hom ) ) );

#############################################################################
##
#M  IsInjective( <hom> )  . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( IsInjective,
    "for GHBI",
    true,
    [ IsGroupGeneralMappingByImages ], 0,
    hom -> IsSingleValued( RestrictedInverseGeneralMapping( hom ) ) );

#############################################################################
##
#F  ImagesRepresentativeGMBIByElementsList( <hom>, <elm> )
##
InstallGlobalFunction( ImagesRepresentativeGMBIByElementsList,
function( hom, elm )
local   p,mapi;
  if not IsBound( hom!.elements )  then
    mapi:=MappingGeneratorsImages(hom);
    # catch a few trivial cases
    if Length(mapi[1])>0 then
      if CanEasilyCompareElements(mapi[1][1]) then
        p:=Position(mapi[1],elm);
        if p<>fail then
          return mapi[2][p];
        fi;
      else
        p:=PositionProperty(mapi[1],i->IsIdenticalObj(i,elm));
        if p<>fail then
          return mapi[2][p];
        fi;
      fi;
    fi;

    MakeMapping( hom );
  fi;
  p := Position( hom!.elements, elm );
  if p <> fail  then  return hom!.images[ p ];
  else  return fail;             fi;
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ImagesRepresentative,
    "parallel enumeration of source and range",
    FamSourceEqFamElm,
    [ IsGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    ImagesRepresentativeGMBIByElementsList);

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . . .  for GHBI
##
InstallMethod( PreImagesRepresentative,
    "for GHBI and mult.-elm.-with-inverse",
    FamRangeEqFamElm,
    [ IsGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    if IsBound( hom!.images )  and elm in hom!.images  then
        return hom!.elements[ Position( hom!.images, elm ) ];
    else
        return ImagesRepresentative( RestrictedInverseGeneralMapping( hom ), elm );
    fi;
end );


#############################################################################
##
#M  ViewObj( <hom> )  . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ViewObj, "for GHBI", true,
    [ IsGroupGeneralMappingByImages ], 0,
function( hom )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  View(mapi[1]);
  Print(" -> ");
  View(mapi[2]);
end );

#############################################################################
##
#M  String( <hom> )  . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( String, "for GHBI", true,
    [ IsGroupGeneralMappingByImages ], 0,
function( hom )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  return Concatenation(String(mapi[1])," -> ",String(mapi[2]));
end );


#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( PrintObj, "for group general mapping b.i.", true,
  [ IsGroupGeneralMappingByImages ], 0,
function( hom )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  Print( "GroupGeneralMappingByImages( ",
          Source( hom ), ", ", Range(  hom ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );

InstallMethod( PrintObj, "for GHBI", true,
  [ IsGroupGeneralMappingByImages and IsMapping ], 0,
function( hom )
local mapi;
  mapi:=MappingGeneratorsImages(hom);
  Print( "GroupHomomorphismByImages( ",
          Source( hom ), ", ", Range(  hom ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );


#############################################################################
##
##  3. Functions for conjugation action
##

#############################################################################
##
#M  ConjugatorOfConjugatorIsomorphism(<hom>)
##
InstallOtherMethod(ConjugatorOfConjugatorIsomorphism,
  "default -- try RepresentativeAction",true,
  [IsGroupHomomorphism and IsConjugatorIsomorphism],0,
function(hom)
local gi,x,p;
  gi:=MappingGeneratorsImages(hom);
  p:=Parent(Source(hom));
  # in the case of permutation group there is the natural parent S_n which
  # is used by `IsConjugatorIsomorphism'.
  if IsPermGroup(p) then
    p:=SymmetricGroup(MovedPoints(p));
  fi;
  x:=RepresentativeAction(p,gi[1],gi[2],OnTuples);
  if x=fail then TryNextMethod();fi;
  return x;
end);


#############################################################################
##
#M  ConjugatorIsomorphism( <G>, <g> )
##
InstallMethod( ConjugatorIsomorphism,
    "for group and mult.-elm.-with-inverse",
    IsCollsElms,
    [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
    function( G, g )
    local fam, hom;

    fam:= ElementsFamily( FamilyObj( G ) );
    hom:= Objectify( NewType( GeneralMappingsFamily( fam, fam ),
                                  IsConjugatorIsomorphism
                              and IsSPGeneralMapping
                              and IsAttributeStoringRep ),
                     rec() );
    SetConjugatorOfConjugatorIsomorphism( hom, g );
    SetSource( hom, G );
    SetRange(  hom, ConjugateGroup( G, g ) );
    return hom;
    end );


#############################################################################
##
#M  ConjugatorAutomorphismNC( <G>, <g> )
##
InstallMethod( ConjugatorAutomorphismNC,
    "group and mult.-elm.-with-inverse",
    IsCollsElms,
    [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
    function( G, g )
    local fam, hom;

    fam:= ElementsFamily( FamilyObj( G ) );
    hom:= Objectify( NewType( GeneralMappingsFamily( fam, fam ),
                                  IsConjugatorAutomorphism
                              and IsSPGeneralMapping
                              and IsAttributeStoringRep ),
                     rec() );
    SetConjugatorOfConjugatorIsomorphism( hom, g );
    SetSource( hom, G );
    SetRange(  hom, G );
    return hom;
    end );


#############################################################################
##
#F  ConjugatorAutomorphism( <G>, <g> )
##
InstallGlobalFunction( ConjugatorAutomorphism, function( G, g )
local rep;
    if     IsCollsElms( FamilyObj( G ), FamilyObj( g ) )
       and IsNormal( Group( g ), G ) then
      # ensure that g is chosen in G if possible
      if not g in G then
        rep:=RepresentativeAction(G,GeneratorsOfGroup(G),
               List(GeneratorsOfGroup(G),x->x^g),OnTuples);
        if rep<>fail then
          Info(InfoPerformance,2,"changed conjugator to make it inner");
          g:=rep;
        fi;
      fi;
      return ConjugatorAutomorphismNC( G, g );
    else
      return fail;
    fi;
end );


#############################################################################
##
#M  InnerAutomorphismNC( <G>, <g> ) . . . . . . . . . . .  inner automorphism
##
InstallMethod( InnerAutomorphismNC,
    "for group and mult.-elm.-with-inverse",
    IsCollsElms,
    [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
    function( G, g )
    local hom;
    hom:= ConjugatorAutomorphismNC( G, g );
    SetIsInnerAutomorphism( hom, true );
    return hom;
    end );


#############################################################################
##
#F  InnerAutomorphism( <G>, <g> )
##
InstallGlobalFunction( InnerAutomorphism, function( G, g )
    if g in G then
      return InnerAutomorphismNC( G, g );
    else
      return fail;
    fi;
end );


#############################################################################
##
#M  MappingGeneratorsImages( <hom> )  . . .  for conjugator isomorphism
##
InstallMethod( MappingGeneratorsImages,
    "for conjugator isomorphism", true, [ IsConjugatorIsomorphism ], 0,
function( hom )
local gens;
  gens:= GeneratorsOfGroup( Source(hom) );
  return [gens,OnTuples( gens, ConjugatorOfConjugatorIsomorphism( hom ) )];
end );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . .  for conjugator isomorphism
##
InstallMethod( AsGroupGeneralMappingByImages,
    "for conjugator isomorphism", true, [ IsConjugatorIsomorphism ], 0,
function( hom )
    local G, gens, map;

    G:= Source( hom );
    gens:= GeneratorsOfGroup( G );
    map:= GroupHomomorphismByImagesNC( G, Range( hom ), gens,
              OnTuples( gens, ConjugatorOfConjugatorIsomorphism( hom ) ) );
    SetIsBijective( map, true );
    return map;
end );


#############################################################################
##
#M  InverseGeneralMapping( <hom> )  . . . . . . .  for conjugator isomorphism
##
InstallMethod( InverseGeneralMapping,
    "for conjugator isomorphism",
    true,
    [ IsConjugatorIsomorphism ], 0,
    hom -> ConjugatorIsomorphism( Range( hom ),
               Inverse( ConjugatorOfConjugatorIsomorphism( hom ) ) ) );


#############################################################################
##
#M  InverseGeneralMapping( <hom> )  . . . . . . . for conjugator automorphism
##
InstallMethod( InverseGeneralMapping,
    "for conjugator automorphism",
    true,
    [ IsConjugatorAutomorphism ], 0,
    hom -> ConjugatorAutomorphismNC( Range( hom ),
               Inverse( ConjugatorOfConjugatorIsomorphism( hom ) ) ) );


#############################################################################
##
#M  InverseGeneralMapping( <inn> )  . . . . . . . . .  for inner automorphism
##
InstallMethod( InverseGeneralMapping,
    "for inner automorphism",
    true,
    [ IsInnerAutomorphism ], 0,
    inn -> InnerAutomorphismNC( Source( inn ),
                     Inverse( ConjugatorOfConjugatorIsomorphism( inn ) ) ) );


#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . for two conjugator isomorphisms
##
InstallMethod( CompositionMapping2,
    "for two conjugator isomorphisms",
    true,
    [ IsConjugatorIsomorphism, IsConjugatorIsomorphism ], 0,
    function( hom1, hom2 )
    if not IsIdenticalObj( Source( hom1 ), Range( hom2 ) )  then
      TryNextMethod();
    fi;
    return ConjugatorIsomorphism( Source( hom2 ),
                 ConjugatorOfConjugatorIsomorphism( hom2 )
               * ConjugatorOfConjugatorIsomorphism( hom1 ) );
    end );


#############################################################################
##
#M  CompositionMapping2( <aut1>, <aut2> ) .  for two conjugator automorphisms
##
InstallMethod( CompositionMapping2,
    "for two conjugator automorphisms",
    true,
    [ IsConjugatorAutomorphism, IsConjugatorAutomorphism ], 0,
    function( aut1, aut2 )
    if not IsIdenticalObj( Source( aut1 ), Range( aut2 ) )  then
      TryNextMethod();
    fi;
    return ConjugatorAutomorphismNC( Source( aut2 ),
                 ConjugatorOfConjugatorIsomorphism( aut2 )
               * ConjugatorOfConjugatorIsomorphism( aut1 ) );
    end );


#############################################################################
##
#M  CompositionMapping2( <inn1>, <inn2> ) . . . . for two inner automorphisms
##
InstallMethod( CompositionMapping2,
    "for two inner automorphisms",
    IsIdenticalObj,
    [ IsInnerAutomorphism, IsInnerAutomorphism ], 0,
    function( inn1, inn2 )
    if not IsIdenticalObj( Source( inn1 ), Source( inn2 ) )  then
      TryNextMethod();
    fi;
    return InnerAutomorphismNC( Source( inn1 ),
                 ConjugatorOfConjugatorIsomorphism( inn2 )
               * ConjugatorOfConjugatorIsomorphism( inn1 ) );
    end );


#############################################################################
##
#M  ImagesRepresentative( <hom>, <g> )  . . . . .  for conjugator isomorphism
##
InstallMethod( ImagesRepresentative,
    "for conjugator isomorphism",
    FamSourceEqFamElm,
    [ IsConjugatorIsomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, g )
    return g ^ ConjugatorOfConjugatorIsomorphism( hom );
    end );


#############################################################################
##
#M  ImagesSet( <hom>, <U> ) . . . . . . . . . . .  for conjugator isomorphism
##
InstallMethod( ImagesSet,
    "for conjugator isomorphism, and group",
    CollFamSourceEqFamElms,
    [ IsConjugatorIsomorphism, IsGroup ], 0,
    function( hom, U )
    return U ^ ConjugatorOfConjugatorIsomorphism( hom );
    end );


#############################################################################
##
#M  PreImagesRepresentative( <hom>, <g> ) . . . .  for conjugator isomorphism
##
InstallMethod( PreImagesRepresentative,
    "for conjugator isomorphism",
    FamRangeEqFamElm,
    [ IsConjugatorIsomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, g )
    return g ^ ( ConjugatorOfConjugatorIsomorphism( hom ) ^ -1 );
    end );


#############################################################################
##
#M  PreImagesSet( <hom>, <U> )  . . . . . . . . .  for conjugator isomorphism
##
InstallMethod( PreImagesSet,
    "for conjugator isomorphism, and group",
    CollFamRangeEqFamElms,
    [ IsConjugatorIsomorphism, IsGroup ], 0,
    function( hom, U )
    return U ^ ( ConjugatorOfConjugatorIsomorphism( hom ) ^ -1 );
    end );


#############################################################################
##
#M  ViewObj( <hom> )  . . . . . . . . . . . . . .  for conjugator isomorphism
##
InstallMethod( ViewObj, "for conjugator isomorphism",
    true, [ IsConjugatorIsomorphism ], 0,
function( hom )
  Print("^");
  View( ConjugatorOfConjugatorIsomorphism( hom ) );
end );

#############################################################################
##
#M  String( <hom> )  . . . . . . . . . . . . . .  for conjugator isomorphism
##
InstallMethod( String, "for conjugator isomorphism",
    true, [ IsConjugatorIsomorphism ], 0,
function( hom )
  return Concatenation("^",String(ConjugatorOfConjugatorIsomorphism( hom ) ));
end );


#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . . .  for conjugator isomorphism
##
InstallMethod( PrintObj,
    "for conjugator isomorphism",
    true,
    [ IsConjugatorIsomorphism ], 0,
    function( hom )
    if IsIdenticalObj( Source( hom ), Range( hom ) ) then
      Print( "ConjugatorAutomorphism( ", Source( hom), ", ",
             ConjugatorOfConjugatorIsomorphism( hom ), " )" );
    else
      Print( "ConjugatorIsomorphism( ", Source( hom ), ", ",
             ConjugatorOfConjugatorIsomorphism( hom ), " )" );
    fi;
    end );


#############################################################################
##
#M  PrintObj( <inn> ) . . . . . . . . . . . . . . . .  for inner automorphism
##
InstallMethod( PrintObj,
    "for inner automorphism",
    true,
    [ IsInnerAutomorphism ], 0,
    function( inn )
    Print( "InnerAutomorphism( ", Source( inn ), ", ",
           ConjugatorOfConjugatorIsomorphism( inn ), " )" );
    end );


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
##  There are methods of higher rank for special kinds of groups.
##  The default method can only check whether <hom> is an inner automorphism,
##  and whether some necessary conditions are satisfied.
##
InstallMethod( IsConjugatorIsomorphism,
    "for a group general mapping",
    true,
    [ IsGroupGeneralMapping ], 0,
    function( hom )
    if not ( IsBijective( hom ) and IsGroupHomomorphism( hom ) ) then
      return false;
    elif IsEndoGeneralMapping( hom ) and IsInnerAutomorphism( hom ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsInnerAutomorphism( <hom> )
##
InstallMethod( IsInnerAutomorphism,
    "for a group general mapping",
    true,
    [ IsGroupGeneralMapping ], 0,
    function( hom )
    local s, gens, rep;
    s:= Source( hom );
    Size(s); # force order to use for stabchain if needed
    if not ( IsEndoGeneralMapping( hom ) and IsBijective( hom )
             and IsGroupHomomorphism( hom ) ) then
      return false;
    fi;
    gens:= GeneratorsOfGroup( s );
    if HasConjugatorOfConjugatorIsomorphism(hom) then
      rep:=ConjugatorOfConjugatorIsomorphism(hom);
      return rep in s;
    else
      rep:= RepresentativeAction( s, gens,
                List( gens, i -> ImagesRepresentative( hom, i ) ), OnTuples );
      if rep <> fail then
        SetConjugatorOfConjugatorIsomorphism( hom, rep );
        return true;
      else
        return false;
      fi;
    fi;
    end );


#############################################################################
##
##  4. Functions for ...
##


#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) check whether N \unlhd G?
##
InstallGlobalFunction( NaturalHomomorphismByNormalSubgroup, function(G,N)
  if not (IsSubgroup(G,N) and IsNormal(G,N)) then
    Error("<N> must be a normal subgroup of <G>");
  fi;
  return NaturalHomomorphismByNormalSubgroupNC(G,N);
end );

InstallMethod( NaturalHomomorphismByNormalSubgroupOp,
  "for group, and trivial group (delegate to `IdentityMapping')",
    IsIdenticalObj, [ IsGroup, IsGroup and IsTrivial ],
    SUM_FLAGS, # better than everything else
function( G, T )
  return IdentityMapping( G );
end );

#############################################################################
##
#M  IsomorphismPermGroup( <G> ) . . . . . . . . .  by right regular operation
##
InstallMethod( IsomorphismPermGroup,
    "right regular operation",
    [ IsGroup and IsFinite ],
function ( G )
  if not HasIsAbelian( G ) and IsAbelian( G ) then
    # Redispatch to give the special methods for abelian groups a chance.
    return IsomorphismPermGroup( G );
  elif (not HasIsSolvableGroup(G)) and IsSolvableGroup(G) then
    # Redispatch to give the special methods for solvable groups a chance.
    return IsomorphismPermGroup( G );

    # MH: Disabled the following code for now, as computing IsNilpotentGroup
    # can be very expensive, depending on the group type. We could
    # re-enable it for e.g. pc groups, but I am not sure whether it is
    # worth the hassle.
#   elif not HasIsNilpotentGroup(G) and IsNilpotentGroup(G) then
#     # Redispatch to give the special methods for nilpotents groups a chance.
#     return IsomorphismPermGroup( G );
  fi;
  return RegularActionHomomorphism( G );
end );

# Since permutation groups are finite, IsomorphismPermGroup can only
# work for finite groups. In order to allow IsomorphismPermGroup
# methods to assume that they are invoked with a finite group, we
# redispatch upon that condition.
RedispatchOnCondition(IsomorphismPermGroup,true,[IsGroup],[IsFinite],0);


#############################################################################
##
## The following function computes a compact permutation or pc representation
## for an abelian group using IndependentGeneratorsOfAbelianGroup and
## IndependentGeneratorExponents.
##
## Since the default method for IndependentGeneratorsOfAbelianGroup uses
## IsomorphismPermGroup, we must take care to not end up in an infinite
## loop. In particular, we cannot just install this method for all
## abelian groups, but rather only for those which can easily compute
## IndependentGeneratorsOfAbelianGroup and IndependentGeneratorExponents.
##
## For the computed isomorphism to be effectively computable, the source
## group should be in either the filter KnowsHowToDecompose or the filter
## CanEasilyComputeWithIndependentGensAbelianGroup.
InstallGlobalFunction(IsomorphismAbelianGroupViaIndependentGenerators, function ( filter, G )
  local gens, imgs, i, g, K, nice;

  if IsTrivial( G ) then
    K := TrivialGroup( filter );
    nice := GroupHomomorphismByImagesNC( G, K, [], [] );
    SetIsBijective( nice, true );
    return nice;
  fi;

  gens := IndependentGeneratorsOfAbelianGroup( G );
  K := AbelianGroup( filter, AbelianInvariants( G ) );
  UseIsomorphismRelation( G, K );
  imgs := IndependentGeneratorsOfAbelianGroup( K );
  if List(gens,Order) <> List(imgs,Order) then
    Error("IndependentGeneratorsOfAbelianGroup results inconsistent");
  fi;

  # Construct the isomorphism.
  if KnowsHowToDecompose( G ) then
    # G knows how decompose elements in terms of generators, so
    # we can use a simple GHBI.
    nice := GroupHomomorphismByImagesNC( G, K, gens, imgs );
  else
    # G does not know how to decompose elements in general. So we
    # assume that IndependentGeneratorExponents works effectively,
    # and use it to construct a homomorphism.
    nice := GroupHomomorphismByFunction( G, K, function ( g )
               local exps;
               exps := IndependentGeneratorExponents( G, g );
               return Product( List( [ 1..Length(exps) ],
                                     i -> imgs[i]^exps[i] ) );
             end);
  fi;
  SetIsBijective( nice, true );
  return nice;
end );

# Apply IsomorphismAbelianGroupViaIndependentGenerators if the group can
# easily compute independent abelian generators, and decompose using them.
InstallMethod( IsomorphismPermGroup,
    [ IsGroup and IsFinite and IsAbelian and CanEasilyComputeWithIndependentGensAbelianGroup ],
    0,
    G -> IsomorphismAbelianGroupViaIndependentGenerators( IsPermGroup, G )
    );


#############################################################################
##
#M  IsomorphismPermGroup( <G> ) . . . . . . . . . for finite nilpotent groups
##
InstallMethod( IsomorphismPermGroup, "for finite nilpotent groups", true,
                [ IsNilpotentGroup and IsFinite and KnowsHowToDecompose ], 0,
function ( G )
  local S, isoS, gens, imgs, H, i, phi, g, nice;

  if IsAbelian(G) and CanEasilyComputeWithIndependentGensAbelianGroup(G) then
    # Use the special method for abelian groups
    return IsomorphismAbelianGroupViaIndependentGenerators( IsPermGroup, G );
  fi;

  # This method works by exploiting that finite nilpotent groups
  # are the direct product of their Sylow subgroups. For p-groups,
  # we for now rely on other code (hopefully) providing a good
  # way to find a small permutation presentation.
  if IsPGroup(G) then
    TryNextMethod();
  fi;

  # Determine all Sylow subgroups and a permutation presentations for each
  S := SylowSystem( G );
  isoS := List( S, IsomorphismPermGroup );

  # Compute isomorphic image H of G from this
  H := DirectProduct( List( isoS, ImagesSource ) );
  UseIsomorphismRelation( G, H );

  # Construct the actual isomorphism
  gens := [];
  imgs := [];
  for i in [ 1 .. Length( S ) ] do
    phi := isoS[i] * Embedding( H, i );
    for g in GeneratorsOfGroup( S[i] ) do
      Add(gens, g);
      Add(imgs, ImageElm(phi, g));
    od;
  od;

  nice := GroupHomomorphismByImagesNC( G, H, gens, imgs );
  SetIsBijective( nice, true );
  return nice;
end );


#############################################################################
##
#M  IsomorphismPcGroup( <G> ) . . . . . . . .  via permutation representation
##
InstallMethod( IsomorphismPcGroup, "via permutation representation", true,
        [ IsGroup and IsFinite ], 0,
function( G )
local p,a;
  p:=IsomorphismPermGroup(G);
  a:=IsomorphismPcGroup(Image(p));
  if a=fail then
    return a;
  else
    return p*a;
  fi;
end);

# Since pc groups are finite, IsomorphismPcGroup can only work for
# finite groups. In order to allow IsomorphismPcGroup methods to assume
# that they are invoked with a finite group, we redispatch upon that
# condition.
RedispatchOnCondition(IsomorphismPcGroup,true,[IsGroup],[IsFinite],0);


#############################################################################
##
#F  GroupHomomorphismByFunction( <D>, <E>, <fun> )
#F  GroupHomomorphismByFunction( <D>, <E>, <fun>, <invfun> )
#F  GroupHomomorphismByFunction( <D>, <E>, <fun>, false, <prefun> )
##
##  The five argument version (independent of the actual value of the fourth
##  argument) creates a mapping that is not necessarily bijective
##  but for which <prefun> can be used to compute preimages.
##
##  For the three argument version,
##  the filter 'IsPreimagesByAsGroupGeneralMappingByImages' is set in the
##  mapping, which means that preimages will be computed by a group
##  homomorphism constructed by mapping generators of <D> to their images
##  under <fun>.
##
InstallGlobalFunction( GroupHomomorphismByFunction, function ( arg )
local map,type,prefun;

    # no inverse function given
    if Length(arg) in [3,5]  then
      type:=IsSPMappingByFunctionRep and IsSingleValued and IsTotal
             and IsGroupHomomorphism;

      if Length(arg)=5 and IsFunction(arg[5]) then
        prefun:=arg[5];
      else
        prefun:=fail;
        type:= type and IsPreimagesByAsGroupGeneralMappingByImages;
      fi;

      # make the general mapping
      map:= Objectify(
        NewType(GeneralMappingsFamily(ElementsFamily(FamilyObj(arg[1])),
        ElementsFamily(FamilyObj(arg[2]))),type),
                       rec( fun:= arg[3] ) );
      if prefun<>fail then
        map!.prefun:=arg[5];
      fi;

    # inverse function given
    elif Length(arg) = 4  then

      # make the mapping
      map:= Objectify(
        NewType(GeneralMappingsFamily(ElementsFamily(FamilyObj(arg[1])),
        ElementsFamily(FamilyObj(arg[2]))),
                               IsSPMappingByFunctionWithInverseRep
                           and IsBijective
                           and IsGroupHomomorphism),
                       rec( fun    := arg[3],
                            invFun := arg[4],
                            prefun := arg[4]) );

    # otherwise signal an error
    else
      Error( "usage: GroupHomomorphismByFunction( <D>, <E>, <fun>[, <inv>] )" );
    fi;

    SetSource(map,arg[1]);
    SetRange(map,arg[2]);
    # return the mapping
    return map;
end );

InstallMethod(RegularActionHomomorphism,"generic",[IsGroup and IsFinite],
function(G)
local hom;
  if HasSize(G) and Size(G) > 10^6 then
    Info(InfoWarning, 1,
    "Trying regular permutation representation of group of order >10^6");
  fi;
  hom:=ActionHomomorphism(G, G, OnRight, "surjective");
  SetIsBijective(hom, true);
  # Do not set IsRegular for the range, as the range has not yet been computed
  # and we should not needlessly trigger this computation.
  # It is comparatively cheap to compute IsRegular anyway.
#  SetIsRegular(Range(hom), true);
  return hom;
end);

# Since permutation groups are finite, RegularActionHomomorphism can only
# work for finite groups. In order to allow RegularActionHomomorphism
# methods to assume that they are invoked with a finite group, we
# redispatch upon that condition.
RedispatchOnCondition(RegularActionHomomorphism,true,[IsGroup],[IsFinite],0);
