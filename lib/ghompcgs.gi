#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

# compute the powers of the source pcgs. We cache these to speed up frequent
# mapping.
BindGlobal("PcgsHomSoImPow",function(hom)
local p,q;
  if not IsBound(hom!.sourcePcgsImagesPowers) then
    p:=hom!.sourcePcgs;
    q:=hom!.sourcePcgsImages;
    hom!.sourcePcgsImagesPowers := List([1..Length(p)],
      function (i)
        local pow, j;
        pow := [q[i]];
        for j in [2..RelativeOrders(p)[i]-1] do
            pow[j] := pow[j-1]*q[i];
        od;
        return pow;
      end);
  fi;
  return hom!.sourcePcgsImagesPowers;
end);


#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> )
##
InstallMethod( CompositionMapping2, "method for hom2 from pc group",
  FamSource1EqFamRange2, [ IsGroupHomomorphism,
  IsGroupGeneralMappingByPcgs and IsMapping and IsTotal ], 0,
function( hom1, hom2 )
local hom, pcgs, pcgsimgs, H, filter, G;

    pcgs := hom2!.sourcePcgs;

    pcgsimgs := List( hom2!.sourcePcgsImages,
                      x -> ImageElm( hom1, x ) );

    G := Source( hom2 );
    H := Range( hom1 );

    filter:=IsGroupGeneralMappingByPcgs and IsMapping;
    if IsSubset(Source(hom1),ImagesSource(hom2)) then
      filter:=filter and IsTotal; # we can transfer totality
    fi;

    if IsPcGroup( G ) then
      filter := filter and IsPcGroupGeneralMappingByImages;
    fi;

    if IsPcGroup( H ) then
      filter := filter and IsToPcGroupGeneralMappingByImages;
    fi;

    filter :=filter and HasSource and HasRange and
#             HasCoKernelOfMultiplicativeGeneralMapping and
              HasImagesSource;

    hom:=rec( sourcePcgs       := pcgs,
              sourcePcgsImages := pcgsimgs);

    ObjectifyWithAttributes(hom,
              NewType(
                GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                       ElementsFamily( FamilyObj( H ) ) ),
                filter ),
              Source,G,
              Range,H,
              ImagesSource,SubgroupNC( H, pcgsimgs )
#    ,CoKernelOfMultiplicativeGeneralMapping,TrivialSubgroup(H);
                );

    return hom;
end );

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> )
##
InstallMethod( CompositionMapping2, "method for two pc group automorphisms",
  IsIdenticalObj,
  [ IsPcGroupHomomorphismByImages and IsToPcGroupHomomorphismByImages and
    IsTotal and IsInjective and IsSurjective,
    IsPcGroupHomomorphismByImages and IsToPcGroupHomomorphismByImages and
    IsTotal and IsInjective and IsSurjective],0,

function( hom1, hom2 )
local fam,hom, pcgs, pcgsimgs, G;

  # is it automorphism?
  if Range(hom1)<>Source(hom2) then
    TryNextMethod();
  fi;
  pcgs := hom2!.sourcePcgs;
  pcgsimgs := List( hom2!.sourcePcgsImages,
                    x -> ImageElm(hom1, x ) );

  G := Source( hom2 );

  fam:=FamilyObj(hom1);
  if not IsBound(fam!.defaultAutomorphismType) then
    fam!.defaultAutomorphismType:=NewType(fam,
      IsPcGroupHomomorphismByImages and IsToPcGroupHomomorphismByImages and
      IsTotal and IsInjective and IsSurjective and
      HasSource and HasRange and HasImagesSource and HasPreImagesRange);
  fi;

  hom:=rec( sourcePcgs       := pcgs,
            sourcePcgsImages := pcgsimgs);

  ObjectifyWithAttributes(hom,
            fam!.defaultAutomorphismType,
            Source,G,
            Range,G,
            ImagesSource,G,
            PreImagesRange,G,
            MappingGeneratorsImages,[pcgs,pcgsimgs]
                  );

  return hom;
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . .  via pcgs
##
InstallMethod( ImagesRepresentative,
    "for total GGMBPCGS, and mult.-elm.-with-inverse", FamSourceEqFamElm,
        [ IsGroupGeneralMappingByPcgs and IsTotal,
                                        # ^ because of `ExponentsOfPcElement'
          IsMultiplicativeElementWithInverse ],
        100,  # to override methods for `IsPerm( <elm> )'
function( hom, elm )
local exp, img, i,sp;
  exp  := ExponentsOfPcElement( hom!.sourcePcgs, elm );
  img  := One( Range( hom ) );
  sp:=PcgsHomSoImPow(hom);
  for i in [1..Length(hom!.sourcePcgsImages)] do
    if exp[i]>0 then
      img := img * sp[i][exp[i]];
    fi;
  od;
  return img;
end );

#############################################################################
##
#M  IsSingleValued( <hom> )  . . . . . . . . . . . .  via pcgs
##
InstallMethod( IsSingleValued, "for GMBPCGS: test relations",true,
  [ IsGroupGeneralMappingByPcgs ],0,
function(map)
local pcgs,pcgsimg,r,i,j,k,o,elm,img,exp,sp,mapi;
  pcgs:=map!.sourcePcgs;
  pcgsimg:=map!.sourcePcgsImages;
  r:=RelativeOrders(pcgs);
  sp:=PcgsHomSoImPow(map);
  o:=One(Range(map));
  for i in [1..Length(pcgs)] do
    elm:=pcgs[i]^r[i];
    exp  := ExponentsOfPcElement( pcgs, elm );
    img  := o;
    for k in [1..Length(pcgsimg)] do
      if exp[k]>0 then
        img := img * sp[k][exp[k]];
      fi;
    od;
    if img<>pcgsimg[i]^r[i] then
      return false;
    fi;

    for j in [i+1..Length(pcgs)] do
      elm:=pcgs[j]^pcgs[i];
      exp  := ExponentsOfPcElement( pcgs, elm );
      img  := o;
      for k in [1..Length(pcgsimg)] do
        if exp[k]>0 then
          img := img * sp[k][exp[k]];
        fi;
      od;
      if img<>pcgsimg[j]^pcgsimg[i] then
        return false;
      fi;
    od;
  od;

  # we still need to test any additional generators. (This could happen
  # easily, if the mapping is a general inverse.)
  mapi:=MappingGeneratorsImages(map);
  for i in [1..Length(mapi[1])] do
    if not mapi[2][i] in pcgsimg then
      exp:=ExponentsOfPcElement(pcgs,mapi[1][i]);
      img  := o;
      for k in [1..Length(pcgsimg)] do
        if exp[k]>0 then
          img := img * sp[k][exp[k]];
        fi;
      od;
      if img<>mapi[2][i] then
        return false; # the extra generator would be mapped inconsistently.
      fi;
    fi;
  od;

  return true;
end);

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
  "for GMBPCGS: evaluate relations",true,
  [ IsGroupGeneralMappingByPcgs ],0,
function(map)
local pcgs,pcgsimg,r,i,j,k,o,elm,img,exp,sp,C,mapi;
  C:=TrivialSubgroup(Range(map));
  pcgs:=map!.sourcePcgs;
  pcgsimg:=map!.sourcePcgsImages;
  r:=RelativeOrders(pcgs);
  sp:=PcgsHomSoImPow(map);
  o:=One(Range(map));
  for i in [1..Length(pcgs)] do
    elm:=pcgs[i]^r[i];
    exp  := ExponentsOfPcElement( pcgs, elm );
    img  := o;
    for k in [1..Length(pcgsimg)] do
      if exp[k]>0 then
        img := img * sp[k][exp[k]];
      fi;
    od;
    #NC is safe (init with Triv(range))
    C:=ClosureSubgroupNC(C,img/pcgsimg[i]^r[i]);

    for j in [i+1..Length(pcgs)] do
      elm:=pcgs[j]^pcgs[i];
      exp  := ExponentsOfPcElement( pcgs, elm );
      img  := o;
      for k in [1..Length(pcgsimg)] do
        if exp[k]>0 then
          img := img * sp[k][exp[k]];
        fi;
      od;
      #NC is safe (init with Triv(range))
      C:=ClosureSubgroupNC(C,img/pcgsimg[j]^pcgsimg[i]);
    od;
  od;

  # we still need to test any additional generators. (This could happen
  # easily, if the mapping is a general inverse.)
  mapi:=MappingGeneratorsImages(map);
  for i in [1..Length(mapi[1])] do
    if not mapi[2][i] in pcgsimg then
      exp:=ExponentsOfPcElement(pcgs,mapi[1][i]);
      img  := o;
      for k in [1..Length(pcgsimg)] do
        if exp[k]>0 then
          img := img * sp[k][exp[k]];
        fi;
      od;
      #NC is safe (init with Triv(range))
      C:=ClosureSubgroupNC(C,img/mapi[2][i]);
    fi;
  od;

  C:=NormalClosure(ImagesSource(map),C);
  return C;
end);

#############################################################################
##
#F  InversePcgs( <hom> )
##
BindGlobal( "InversePcgs", function( hom )
    local pcgs, new,
          idR, idD, gensInv, imgsInv, gensKer, gens, imgs, i, u, v,
          uw, tmp, vw, j;

    # if it is known then return
    if IsBound( hom!.rangePcgs ) then return; fi;

    # if it is from an pc group
    if IsBound( hom!.sourcePcgs ) then

        idR := Identity( Range( hom ) );
        idD := Identity( Source( hom ) );

        # Compute kernel and image, this is a Zassenhaus-algorithm.
        gensInv := [];
        imgsInv := [];
        gensKer := [];
        gens := hom!.sourcePcgs;
        imgs := hom!.sourcePcgsImages;
        pcgs := Pcgs( Image( hom ) );
        for i  in Reversed( [ 1 .. Length( imgs ) ] )  do
            u  := imgs[ i ];
            v  := gens[ i ];
            uw := DepthOfPcElement( pcgs, u );
            while u <> idR and IsBound( gensInv[ uw ] )  do
                tmp := LeadingExponentOfPcElement( pcgs, u )
                        /  LeadingExponentOfPcElement( pcgs, gensInv[ uw ] )
                       mod RelativeOrderOfPcElement( pcgs, u );
                u := gensInv[ uw ] ^ -tmp * u;
                v := imgsInv[ uw ] ^ -tmp * v;
                uw := DepthOfPcElement( pcgs, u );
            od;
            if u = idR  then
                vw := DepthOfPcElement( gens, v );
                while v <> idD and IsBound( gensKer[ vw ] )  do
                    v  := ReducedPcElement( gens, v, gensKer[ vw ] );
                    vw := DepthOfPcElement( gens, v );
                od;
                if v <> idD  then
                    gensKer[ vw ] := v;
                fi;
            else
                gensInv[ uw ] := u;
                imgsInv[ uw ] := v;
            fi;
        od;

        # Now  we  have  image  and  kernel
        gensInv := Compacted( gensInv );
        gensKer := Compacted( gensKer );
        imgsInv := Compacted( imgsInv );

        # normalize
        for i  in [ 1 .. Length( gensInv ) ]  do
            tmp :=  1 / LeadingExponentOfPcElement( pcgs, gensInv[ i ] )
                    mod RelativeOrderOfPcElement( pcgs, gensInv[ i ] );
            gensInv[ i ] := gensInv[ i ] ^ tmp;
            imgsInv[ i ] := imgsInv[ i ] ^ tmp;
        od;
        for i  in [ 1 .. Length( gensInv ) - 1 ]  do
            for j  in [ i + 1 .. Length( gensInv ) ]  do
                uw := DepthOfPcElement( pcgs, gensInv[ j ] );
                tmp := ExponentOfPcElement( pcgs, gensInv[ i ], uw );
                if tmp <> 0  then
                    gensInv[i] := gensInv[i] / gensInv[j] ^ tmp;
                    imgsInv[i] := imgsInv[i] / imgsInv[j] ^ tmp;
                fi;
            od;
        od;

        # add it
        hom!.rangePcgs := InducedPcgsByPcSequenceNC( pcgs, gensInv );
        hom!.rangePcgsPreimages := Immutable(imgsInv);

        # we have the kernel also, if needed (or we check).
        if not HasKernelOfMultiplicativeGeneralMapping(hom)
          or InfoLevel(InfoAttributes)>1 then
          #Check whether the Pcgs is for the whole group.
          # Otherwise there is a kernel that will not be visible in
          # the modulo pcgs that the homomorphism uses
          tmp:=DenominatorOfModuloPcgs(hom!.sourcePcgs);
          if tmp=fail then
            gensKer:=AsSubgroup(Source(hom),
              ClosureGroup(hom!.sourcePcgs!.denominator,gensKer));
          elif Length(tmp)>0 then
            gensKer:=SubgroupNC(Source(hom),Concatenation(tmp,gensKer));
          else
            gensKer:=SubgroupNC(Source(hom),gensKer);
          fi;
          SetKernelOfMultiplicativeGeneralMapping( hom, gensKer );
        fi;

        # and return
        return;
      fi;

      # otherwise we have to do some work
      pcgs := Pcgs( Image( hom ) );
      new:=MappingGeneratorsImages(hom);
      new  := CanonicalPcgsByGeneratorsWithImages( pcgs, new[2],
                                                        new[1] );
      hom!.rangePcgs := new[1];
      hom!.rangePcgsPreimages := new[2];
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . .  via images
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
               "method for homs from pc group into pc group or perm group",
               true,
               [ IsPcGroupHomomorphismByImages and
                 IsToPcGroupHomomorphismByImages ],
               0,
function( a )

    local   gensInv, imgsInv, gensKer, u, v, uw, vw, gens, imgs, idR, idD,
            tmp, i, pcgs;

    idR := Identity( Range( a ) );
    idD := Identity( Source( a ) );

    # Compute kernel -- this is a Zassenhaus-algorithm.
    gensInv := [];
    imgsInv := [];
    gensKer := [];
    gens := a!.sourcePcgs;
    imgs := a!.sourcePcgsImages;
    pcgs := Pcgs( Range( a ) );
    for i  in Reversed( [ 1 .. Length( imgs ) ] )  do
        u  := imgs[ i ];
        v  := gens[ i ];
        uw := DepthOfPcElement( pcgs, u );
        while u <> idR and IsBound( gensInv[ uw ] )  do
            tmp := LeadingExponentOfPcElement( pcgs, u )
                    /  LeadingExponentOfPcElement( pcgs, gensInv[ uw ] )
                   mod RelativeOrderOfPcElement( pcgs, u );
            u := gensInv[ uw ] ^ -tmp * u;
            v := imgsInv[ uw ] ^ -tmp * v;
            uw := DepthOfPcElement( pcgs, u );
        od;
        if u = idR  then
            vw := DepthOfPcElement( gens, v );
            while v <> idD and IsBound( gensKer[ vw ] )  do
                v  := ReducedPcElement( v, gensKer[ vw ] );
                vw := DepthOfPcElement( gens, v );
            od;
            if v <> idD  then
                gensKer[ vw ] := v;
            fi;
        else
            gensInv[ uw ] := u;
            imgsInv[ uw ] := v;
        fi;
    od;
    return SubgroupNC( Source( a ), Compacted( gensKer ) );
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . .  via images
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
               "method for homs from pc group",
               true,
               [ IsPcGroupHomomorphismByImages ],
               0,
function( hom )
    local S, idS, ggens, m, sk, im, gexps, x, y, k, l,j;

    S       := Source( hom );
    idS     := Identity( S );
    ggens   := Pcgs( S );
    gexps   := RelativeOrders( ggens );
    m       := Length( ggens );
    sk      := List( [1..m], x -> idS );
    im      := [];
    im[m+1] := TrivialSubgroup( Range( hom ) );

    for j in Reversed( [1..m] ) do
        if Image( hom, ggens[j] ) in im[j+1]  then
            y := ggens[j];
            for k in [j+1..m] do
                if sk[k] = idS then
                    if gexps[k] <> gexps[j] then
                        y := y ^ gexps[k];
                    else
                        l := 0;
                        while l < gexps[k] do
                            x := y * (ggens[k] ^ l);
                            if Image( hom, x ) in im[k+1]  then
                                y := x;
                                l := gexps[k];
                            else
                                l := l + 1;
                            fi;
                        od;
                    fi;
                fi;
            od;
            sk[j] := y;
            im[j] := im[j+1];
        else
            im[j] := ClosureGroup( im[j+1], Image( hom, ggens[j] ) );
        fi;
    od;
    return SubgroupNC( S, sk );
end );

#############################################################################
##
#M  IsInjective( <hom> )
##
InstallMethod( IsInjective, "method for homs from pc group", true,
               [ IsPcGroupHomomorphismByImages ], 0,
function(hom)
  return Size(KernelOfMultiplicativeGeneralMapping(hom))=1;
end);

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . .  via images
##
InstallMethod( PreImagesRepresentative, "method for pcgs hom",
  FamRangeEqFamElm,
  [ IsToPcGroupHomomorphismByImages,IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
    local  pcgsR, exp, imgs, pre, i;

    # precompute pcgs
    InversePcgs( hom );

    pcgsR := hom!.rangePcgs;
    exp := ExponentsOfPcElement( pcgsR, elm );
    imgs := hom!.rangePcgsPreimages;
    pre := Identity( Source( hom ) );
    for i in [1..Length(exp)] do
      if exp[i]>0 then
        pre := pre * imgs[i]^exp[i];
      fi;
    od;
    return pre;
end);

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . . . . . . for pc groups
##
InstallMethod( NaturalHomomorphismByNormalSubgroupOp, IsIdenticalObj,
        [ IsPcGroup, IsPcGroup ], 0,
    function( G, N )
    local   pcgsG,  pcgsN,  pcgsK,  pcgsF,  F,  hom,pF,i,imgs;

    if HasSpecialPcgs(G) and HasInducedPcgsWrtSpecialPcgs(N) then
      pcgsG := SpecialPcgs( G );
      pcgsN := InducedPcgs(pcgsG, N );
      pcgsK:=pcgsN;
    else
      pcgsG := Pcgs( G );
      pcgsN := Pcgs( N );
      if IsInducedPcgs( pcgsN )  then
          if ParentPcgs( pcgsN ) = pcgsG  then
              pcgsK := pcgsN;
          elif     IsInducedPcgs( pcgsG )
              and ParentPcgs( pcgsN ) = ParentPcgs( pcgsG )  then
              pcgsK := NormalIntersectionPcgs( ParentPcgs( pcgsG ),
                              pcgsN, pcgsG );
          fi;
      fi;
      if not IsBound( pcgsK )  then
          pcgsK := InducedPcgsByGenerators( pcgsG, GeneratorsOfGroup( N ) );
      fi;
    fi;

    pcgsF := pcgsG mod pcgsK;
    F := PcGroupWithPcgs( pcgsF );
    pF:=Pcgs(F);
    imgs:=List(pcgsG,i->PcElementByExponents(pF,
              ExponentsOfPcElement(pcgsF,i)));
    hom:=Objectify( NewType( GeneralMappingsFamily
                  ( ElementsFamily( FamilyObj( G ) ),
                    ElementsFamily( FamilyObj( F ) ) ),
                  IsPcgsToPcgsHomomorphism ),
          rec(  sourcePcgs:= pcgsG,
                sourcePcgsImages:= imgs,
# the following components are not really needed but expensive to compute.
#               generators:=pcgsG,
#               genimages:=List(pcgsG,  i->
#                 PcElementByExponentsNC(pF,ExponentsOfPcElement(pcgsF,i))),
                rangePcgs:= pF,
                rangePcgsPreImages:= pcgsF));

    SetSource( hom, G );
    SetRange ( hom, F );
    SetKernelOfMultiplicativeGeneralMapping( hom, GroupOfPcgs( pcgsK ) );
    return hom;
end );


#############################################################################
##
#M  ViewObj( <hom> )  . . . . . . . . . . . . . . . for nat. hom. of pc group
##
InstallMethod( ViewObj,
    "for nat. hom. of pc group",
    true,
    [ IsNaturalHomomorphismPcGroupRep ], 0,
    function( hom )
    View( Source( hom ), " -> ", Range( hom ) );
end );


#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . . . . for nat. hom. of pc group
##
InstallMethod( PrintObj,
    "for nat. hom. of pc group",
    true,
    [ IsNaturalHomomorphismPcGroupRep ], 0,
    function( hom )
    Print( "NaturalHomomorphismByNormalSubgroup( ",
           Source( hom ), ", ",
           KernelOfMultiplicativeGeneralMapping( hom ), " )" );
end );


#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . via depth map
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [ IsPcgsToPcgsHomomorphism, IsMultiplicativeElementWithInverse ],0,
function( hom, elm )
local   exp;
  exp := ExponentsOfPcElement( hom!.sourcePcgs, elm );
  return PcElementByExponentsNC( hom!.sourcePcgsImages, exp );
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . via depth map
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
  [ IsPcgsToPcgsHomomorphism,IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
local   exp;
    exp := ExponentsOfPcElement( hom!.rangePcgs, elm );
    return PcElementByExponentsNC( hom!.rangePcgsPreImages, exp );
end );

#############################################################################
##
#M  <hom1> = <hom2> . . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( \=, "pc group homomorphisms",IsIdenticalObj,
               [ IsPcGroupHomomorphismByImages,
                 IsPcGroupHomomorphismByImages ], 1,
    function( hom1, hom2 )
    if    Source( hom1 ) <> Source( hom2 )
       or Range ( hom1 ) <> Range ( hom2 )  then
        return false;
    fi;
    if hom1!.sourcePcgs<>hom2!.sourcePcgs then
      TryNextMethod();
    fi;
    return hom1!.sourcePcgsImages = hom2!.sourcePcgsImages;
end );

#############################################################################
##
#M  PrintObj( )
##
InstallMethod( PrintObj, "method for a PcGroupHomomorphisms", true,
    [ IsPcGroupHomomorphismByImages ], 0,
function( map )
  Print(map!.sourcePcgs, " -> ", map!.sourcePcgsImages );
end );

#############################################################################
##
#M  NaturalIsomorphismByPcgs( <grp>, <pcgs> ) . . presentation through <pcgs>
##
InstallMethod( NaturalIsomorphismByPcgs,"for group and pcgs", IsIdenticalObj,
    [ IsGroup, IsPcgs ], 0,
function( grp, pcgs )
    local   new;

    # <pcgs> must be a subset of <grp>
    if ForAny( pcgs, x -> not x in grp )  then
        Error( "<pcgs> must be a subset of <grp>" );
    fi;

    # compute a new group and check the size
    new := PcGroupWithPcgs(pcgs);
    if Size(new) <> Size(grp)  then
        Error( "<pcgs> must generate <grp>" );
    fi;

    # return the isomomorphism
    new := GroupHomomorphismByImagesNC( grp, new, pcgs, FamilyPcgs(new) );
    SetIsBijective( new, true );
    return new;

end );


#############################################################################
##
#M  IsomorphismPcGroup( <G> ) . . . .  for pc group (return identity mapping)
##
InstallMethod( IsomorphismPcGroup,
    [ IsPcGroup ], SUM_FLAGS,
    IdentityMapping );
