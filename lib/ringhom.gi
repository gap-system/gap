#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for ring general mappings and homomorphisms.
##  It is based on alghom.gi
##


#############################################################################
##
#R  IsRingGeneralMappingByImagesDefaultRep
#R  IsSCRingGeneralMappingByImagesDefaultRep
##
##
DeclareRepresentation( "IsRingGeneralMappingByImagesDefaultRep",
    IsRingGeneralMapping and IsAdditiveElementWithInverse
    and IsAttributeStoringRep, [] );

DeclareRepresentation( "IsSCRingGeneralMappingByImagesDefaultRep",
    IsRingGeneralMappingByImagesDefaultRep,[]);


#############################################################################
##
#M  RingGeneralMappingByImages( <S>, <R>, <gens>, <imgs> )
##
InstallMethod( RingGeneralMappingByImages,
    "for two rings and two homogeneous lists",
    [ IsRing, IsRing, IsHomogeneousList, IsHomogeneousList ],
function( S, R, gens, imgs )
  local filter,map;        # general mapping from <S> to <R>, result

  # Check the arguments.
  if   Length( gens ) <> Length( imgs )  then
    Error( "<gens> and <imgs> must have the same length" );
  elif not IsSubset( S, gens ) then
    Error( "<gens> must lie in <S>" );
  elif not IsSubset( R, imgs ) then
    Error( "<imgs> must lie in <R>" );
  fi;
  filter:=IsSPGeneralMapping and IsRingGeneralMapping;

  if IsSubringSCRing(S) then
    filter:=filter and IsSCRingGeneralMappingByImagesDefaultRep;
  fi;

  # Make the general mapping.
  map:= Objectify( TypeOfDefaultGeneralMapping( S, R,
                            IsSPGeneralMapping
                        and IsRingGeneralMapping
                        and IsSCRingGeneralMappingByImagesDefaultRep ),
                    rec(
                        ) );

    SetMappingGeneratorsImages(map,[Immutable(gens),Immutable(imgs)]);
    # return the general mapping
    return map;
    end );

#############################################################################
##
#M  RingHomomorphismByImagesNC( <S>, <R>, <gens>, <imgs> )
##
InstallMethod( RingHomomorphismByImagesNC,
    "for two rings and two homogeneous lists",
    [ IsRing, IsRing, IsHomogeneousList, IsHomogeneousList ],
    function( S, R, gens, imgs )
    local map;        # homomorphism from <source> to <range>, result
    map:= RingGeneralMappingByImages( S, R, gens, imgs );
    SetIsSingleValued( map, true );
    SetIsTotal( map, true );
    return map;
    end );


#############################################################################
##
#F  RingHomomorphismByImages( <S>, <R>, <gens>, <imgs> )
##
InstallGlobalFunction( RingHomomorphismByImages,
    function( S, R, gens, imgs )
    local hom;
    hom:= RingGeneralMappingByImages( S, R, gens, imgs );
    if IsMapping( hom ) then
      return RingHomomorphismByImagesNC( S, R, gens, imgs );
    else
      return fail;
    fi;
end );

#############################################################################
##
#M  ViewObj( <map> )  . . . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( ViewObj, "for a ring g.m.b.i", true,
    [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  View(mapi[1]);
  Print(" -> ");
  View(mapi[2]);
end );


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( PrintObj, "for a ring hom. b.i.", true,
    [     IsMapping
      and IsRingGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  Print( "RingHomomorphismByImages( ",
          Source( map ), ", ", Range( map ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );

InstallMethod( PrintObj, "for a ring g.m.b.i", true,
    [     IsGeneralMapping
      and IsRingGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  Print( "RingGeneralMappingByImages( ",
          Source( map ), ", ", Range( map ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );

#############################################################################
##
#M  IsTotal( <map> ) . . . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( IsTotal,
    "for ring g.m.b.i.",
    [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function(map)
local mapi,t;
  mapi:=MappingGeneratorsImages(map);
  if Length(mapi[1])=0 then
    t:=Ring(Zero(Source(map)));
  else
    t:=Ring(mapi[1]);
  fi;
  return Source(map)=t;
end);

#############################################################################
##
#M  MakeSCRingMapping( <map> )
##
BindGlobal( "MakeSCRingMapping",
function(map)
local mapi;
  if not IsBound(map!.stdgens) then
    mapi:=MappingGeneratorsImages(map);
    map!.stdgens:=
      StandardGeneratorsImagesSubringSCRing(FamilyObj(Zero(Source(map))),
        mapi[1],mapi[2]);
  fi;
end);

#############################################################################
##
#M  IsSingleValued( <map> ) . . . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( IsSingleValued,
    "for sc ring g.m.b.i.",
    [ IsGeneralMapping and IsSCRingGeneralMappingByImagesDefaultRep ],
function(map)
  local r, moduli, std, stdi, sel, o, elm, elmi, i, j, k;
  r:=Source(map);
  moduli:=FamilyObj(Zero(r))!.moduli;

  MakeSCRingMapping(map);
  std:=map!.stdgens;
  # check additive relations
  for i in [1..Length(std[4])] do
    stdi:=std[1][i];
    sel:=Filtered([1..Length(stdi)],x->stdi[x]<>0);
    if not 0 in moduli{sel} then
      o:=1;
      for j in sel do
        o:=Lcm(o,moduli[j]/Gcd(stdi[j],moduli[j]));
      od;
      if not IsZero(o*std[4][i]) then
        Info(InfoRingHom,2,"Additive order ",o," of generator ",i," failed");
        return false;
      else
        Info(InfoRingHom,3,"Additive order ",o," of generator ",i," OK");
      fi;
    else
      Info(InfoRingHom,3,"Generator ",i,": ",std[1][i]," has order infinity");
    fi;
  od;

  # check multiplicative relations
  for i in [1..Length(std[4])] do
    for j in [1..Length(std[4])] do
      elm:=std[3][i]*std[3][j];
      elm:=SCRingDecompositionStandardGens(std,elm);
      elmi:=Zero(Range(map));
      for k in [1..Length(std[4])] do
        elmi:=elmi+elm[k]*std[4][k];
      od;
      if elmi<>std[4][i]*std[4][j] then
        Info(InfoRingHom,2,"Product ",i," x ",j," failed: ",elm,elmi);
        return false;
      fi;
    od;
  od;
  return true;
end);


#############################################################################
##
#M  ImagesSource( <map> ) . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( ImagesSource,
    "for a ring g.m.b.i.",
    [ IsRingGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function( map )
  return Subring(Range(map),MappingGeneratorsImages(map)[2]);
end );

#############################################################################
##
#M  PreImagesRange( <map> ) . . . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( PreImagesRange,
    "for a ring g.m.b.i.",
    [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function( map )
  return Subring(Source(map),MappingGeneratorsImages(map)[1]);
end );

#############################################################################
##
#M  InverseGeneralMapping( <map> ) . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( InverseGeneralMapping,
    "for a ring g.m.b.i.",
    [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  return RingGeneralMappingByImages(Range(map),Source(map),mapi[2],mapi[1]);
end );

#############################################################################
##
#M  AdditiveInverseOp( <map> )  . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( AdditiveInverseOp, "for ring g.m.b.i.",
  [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function(map)
local mapi;
  mapi:=MappingGeneratorsImages(map);
  return RingGeneralMappingByImages(Source(map),Range(map),mapi[1],
    List(mapi[2],AdditiveInverse));
end);

#############################################################################
##
#M  \+( <map1>, map2> ) . . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
##
InstallOtherMethod( \+,
    "for ring g.m.b.i. and ring general mapping",
    IsIdenticalObj,
    [ IsRingGeneralMapping and IsRingGeneralMappingByImagesDefaultRep,
      IsRingGeneralMapping],
function( map1, map2 )
local mapi,map;
  mapi:=MappingGeneratorsImages(map1);
  map:=RingGeneralMappingByImages(Source(map1),Range(map1),mapi[1],
    List([1..Length(mapi[1])],
          x->mapi[2][x]+ImagesRepresentative(map2,mapi[1][x])));
  return map;
end );

#############################################################################
##
#M  \+( <map1>, map2> ) . . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
##
InstallOtherMethod( \+,
    "for ring general mapping and ring g.m.b.i.",
    IsIdenticalObj,
    [ IsRingGeneralMapping,
      IsRingGeneralMapping and IsRingGeneralMappingByImagesDefaultRep],
function( map2, map1 )
local mapi,map;
  mapi:=MappingGeneratorsImages(map1);
  map:=RingGeneralMappingByImages(Source(map1),Range(map1),mapi[1],
    List([1..Length(mapi[1])],
          x->mapi[2][x]+ImagesRepresentative(map2,mapi[1][x])));
  return map;
end );

#############################################################################
##
#M  \=( <map1>, map2> ) . . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
##
InstallOtherMethod( \=,
    "for ring g.m.b.i. and ring general mapping",
    IsIdenticalObj,
    [ IsRingGeneralMapping and IsRingGeneralMappingByImagesDefaultRep,
      IsRingGeneralMapping],
function( map1, map2 )
local mapi;
  mapi:=MappingGeneratorsImages(map1);
  return ForAll([1..Length(mapi[1])],
          x->mapi[2][x]=ImagesRepresentative(map2,mapi[1][x]));
end );

#############################################################################
##
#M  \=( <map1>, map2> ) . . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
##
InstallOtherMethod( \=,
    "for ring general mapping and ring g.m.b.i.",
    IsIdenticalObj,
    [ IsRingGeneralMapping,
      IsRingGeneralMapping and IsRingGeneralMappingByImagesDefaultRep],
function( map2, map1 )
local mapi;
  mapi:=MappingGeneratorsImages(map1);
  return ForAll([1..Length(mapi[1])],
          x->mapi[2][x]=ImagesRepresentative(map2,mapi[1][x]));
end );

#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <map> ) . . . . .  for ring g.m.b.i.
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "for ring g.m.b.i.",
    [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function(map)
local r, moduli, std, gens, stdi, sel, o, elm, elmi, i, j, k;
  r:=Source(map);
  moduli:=FamilyObj(Zero(r))!.moduli;

  MakeSCRingMapping(map);
  std:=map!.stdgens;
  gens:=[];
  # run through additive relations
  for i in [1..Length(std[4])] do
    stdi:=std[1][i];
    sel:=Filtered([1..Length(stdi)],x->stdi[x]<>0);
    if not 0 in moduli{sel} then
      o:=1;
      for j in sel do
        o:=Lcm(o,moduli[j]/Gcd(stdi[j],moduli[j]));
      od;
      Add(gens,o*std[4][i]);
    fi;
  od;

  # check multiplicative relations
  for i in [1..Length(std[4])] do
    for j in [1..Length(std[4])] do
      elm:=std[3][i]*std[3][j];
      elm:=SCRingDecompositionStandardGens(std,elm);
      elmi:=Zero(Range(map));
      for k in [1..Length(std[4])] do
        elmi:=elmi+elm[k]*std[4][k];
      od;
      Add(gens,elmi-std[4][i]*std[4][j]);
    od;
  od;
  gens:=Filtered(gens,i->not IsZero(i));
  if Length(gens)=0 then Add(gens,Zero(Range(map)));fi;
  return Subring(Range(map),gens);
end);



#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> ) . . . . . .  for ring g.m.b.i.
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "for ring g.m.b.i.",
    [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function( map )
  local ker, mapi, i;
  ker:=ShallowCopy(GeneratorsOfRing(
      CoKernelOfAdditiveGeneralMapping(InverseGeneralMapping(map))));
  mapi:=MappingGeneratorsImages(map);
  for i in [1..Length(mapi[1])] do
    if IsZero(mapi[2][i]) then
      Add(ker,mapi[1][i]);
    fi;
  od;
  return Subring(Source(map),ker);
end );


#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . . .  for ring g.m.b.i.
##
InstallMethod( IsInjective,
    "for ring g.m.b.i.",
    [ IsGeneralMapping and IsRingGeneralMappingByImagesDefaultRep ],
function(map)
  return Size(KernelOfAdditiveGeneralMapping(map))=1;
end);


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . . . . .  for ring g.m.b.i.
##
InstallMethod( ImagesRepresentative, "for SC ring g.m.b.i., and element",
    FamSourceEqFamElm,
    [ IsRingGeneralMapping and IsSCRingGeneralMappingByImagesDefaultRep,
      IsObject ],
function( map, elm )
local std, elmi, k;
  MakeSCRingMapping(map);
  std:=map!.stdgens;
  elm:=SCRingDecompositionStandardGens(std,elm);
  elmi:=Zero(Range(map));
  for k in [1..Length(std[4])] do
    elmi:=elmi+elm[k]*std[4][k];
  od;
  return elmi;
end );

#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> ) . . . . . .  for ring g.m.b.i.
##
InstallMethod( PreImagesRepresentative,
    "for ring g.m.b.i., and element",
    FamRangeEqFamElm,
    [ IsRingGeneralMapping and IsRingGeneralMappingByImagesDefaultRep,
      IsObject ],
function( map, elm )
  return ImagesRepresentative(InverseGeneralMapping(map),elm);
end );

BindGlobal("IsomorphismSCRing",function(R)
local e, z, one, o, sel, g, go, elms, dec, p, cands, m, a, b, nr, hom, i, j;
  if Size(R)>100000 then
    Error("R is too big");
  fi;
  # find generators
  e:=AsSet(R);
  z:=Zero(R);
  one:=One(R);
  one:=Position(e,one);
  o:=List(e,i->First([1..Size(R)],x->x*i=z));
  sel:=[1..Length(e)];
  g:=[];
  go:=[];
  elms:=[z];
  dec:=[];
  p:=Position(e,z);
  dec[p]:=[];
  RemoveSet(sel,p);
  cands:=ShallowCopy(sel);
  while Length(cands)>0 do

    # element of maximal order. If possible pick ``one'' to be among the
    # generators
    m:=Maximum(o{cands});
    if one in cands and o[one]=m then
      a:=one;
    else
      a:=First(cands,i->o[i]=m);
    fi;
    RemoveSet(cands,a);
    a:=e[a];
    Add(g,a);
    Add(go,m);
    # all combinations
    for i in [1..Length(elms)] do
      for j in [1..m-1] do
        b:=elms[i]+j*a;
        p:=Position(e,b);
        if p in sel then
          RemoveSet(sel,p);
          Add(elms,b);
          Add(dec,Concatenation(dec[i],[j]));
        fi;
      od;
    od;

    # the remaining candidates must be complements
    for i in ShallowCopy(cands) do
      if ForAny([1..o[i]-1],j->j*e[i] in elms) then
        RemoveSet(cands,i);
      fi;
    od;

    # update dec
    m:=Length(g);
    for i in dec do
      while Length(i)<m do
        Add(i,0);
      od;
    od;
  od;
  m:=EmptySCTable(Length(go),0);
  for i in [1..Length(g)] do
    for j in [1..Length(g)] do
      p:=g[i]*g[j];
      if p<>z then
        p:=Position(elms,p);
        p:=dec[p];
        nr:=[];
        for b in [1..Length(p)] do
          if p[b]<>0 then
            Add(nr,p[b]);
            Add(nr,b);
          fi;
        od;
        SetEntrySCTable(m,i,j,nr);
      fi;
    od;
  od;
  nr:=RingByStructureConstants(go,m);
  hom:=RingHomomorphismByImages(R,nr,g,GeneratorsOfRing(nr));
  return hom;
end);

#############################################################################
##
#M  NaturalHomomorphismByIdeal(<R>,<I>)
##
InstallMethod( NaturalHomomorphismByIdeal,"sc rings",IsIdenticalObj,
    [ IsSubringSCRing,IsSubringSCRing],
function( R, I )
  local hom, R2, nat, std, moduli, newmod, posi, q, t, dec, x, i, j,
  k,rels,genwords;
  if not IsIdeal(R,I) then
    Error("I is not an ideal!");
  fi;
  if not IsWholeFamily(R) then
    hom:=IsomorphismSCRing(R);
    R2:=Range(hom);
    I:=Subring(R2,List(GeneratorsOfRing(I),x->Image(hom,x)));
    nat:=NaturalHomomorphismByIdeal(R2,I);
    return RingHomomorphismByImages(R,Range(nat),GeneratorsOfRing(R),
             List(GeneratorsOfRing(R),x->Image(nat,Image(hom,i))));
  fi;

  if I=R then
    # catch trivial case
    q:=SmallRing(1,1);
    return RingHomomorphismByImages(R,q,GeneratorsOfRing(R),
      List(GeneratorsOfRing(R),x->Zero(q)));
  fi;


  # old relations -- standard form
  moduli:=FamilyObj(Zero(R))!.moduli;
  rels:=[];
  for i in [1..Length(moduli)] do
    q:=List(moduli,x->0);
    q[i]:=moduli[i];
    Add(rels,q);
  od;

  # extra kernel generators
  std:=StandardGeneratorsSubringSCRing(I);
  for i in std[1] do
    Add(rels,ShallowCopy(i));
  od;

  # now rels is a relator matrix for the quotient. Use SNF to find
  # structure
  rels:=SmithNormalFormIntegerMatTransforms(rels);

  # Let x,y be ring generators and M the original relator matrix. Then
  # M*(x,y)^T=0 by definition of relators.
  # SNF gives R*M*C=D, so $R^-1*D*C^-1*(x,y)^T=0$, implying that D are
  # relations that hold amongst C^-1*(x,y). Thus:
  # The rows of C^-1 express the new generators in terms of the old, i.e.
  # are base chance new-> old as row vectors.
  # the rows of C convert old->new
  # Thus the rows of C give coefficients for images of old generators

  genwords:=Inverse(rels.coltrans)*GeneratorsOfRing(R);
  # nontrivial generators
  newmod:=[];
  posi:=[];
  for i in [1..Length(moduli)] do
    if rels.normal[i][i]>1 then
      Add(newmod,rels.normal[i][i]);
      Add(posi,i);
    fi;
  od;


  # now determine the multiplication
  t:=EmptySCTable(Length(posi),0);
  for i in [1..Length(posi)] do
    for j in [1..Length(posi)] do
      # product of generators
      q:=genwords[posi[i]]*genwords[posi[j]];
      q:=q![1]; # the coefficients
      q:=ShallowCopy(q*rels.coltrans); # coefficients wrt factor basis
      dec:=[];
      for k in [1..Length(posi)] do
        x:=q[posi[k]] mod newmod[k];
        if x<>0 then
          Add(dec,x);
          Add(dec,k);
        fi;
      od;
      if Length(dec)>0 then
        SetEntrySCTable(t,i,j,dec);
      fi;
    od;
  od;

  q:=RingByStructureConstants(newmod,t,"q");
  # image list: Generators are mapped to their images
  # rows of coltrans give expressions in new basis, but only posi indices
  # count.
  x:=(rels.coltrans{[1..Length(rels.coltrans)]}{posi})*GeneratorsOfRing(q);
  hom:=RingHomomorphismByImages(R,q,GeneratorsOfRing(R),x);
  SetIsSurjective(hom,true);
  SetKernelOfAdditiveGeneralMapping(hom,I);
  return hom;
end );

InstallOtherMethod( \/,
    "generic method for two rings",
    IsIdenticalObj,
    [ IsRing, IsRing ],
    function( R, I )
    return ImagesSource( NaturalHomomorphismByIdeal( R, I ) );
    end );

