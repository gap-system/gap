#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file   contains the methods  for polycyclic  generating systems of pc
##  groups.
##


#############################################################################
##
#R  IsUnsortedPcgsRep
##
DeclareRepresentation( "IsUnsortedPcgsRep", IsPcgsDefaultRep, [] );

#############################################################################
##
#R  IsSortedPcgsRep
##
##  the pc sequence is in different depth in the same order as the sorting
##  pcgs (so in particular depths are the same).
DeclareRepresentation( "IsSortedPcgsRep", IsUnsortedPcgsRep, [] );


#############################################################################
##
#M  PcgsByPcSequenceNC( <fam>, <pcs> )
##


#############################################################################
InstallMethod( PcgsByPcSequenceNC,
    "elements family by rws with defining pcgs",
    true,
    [ IsElementsFamilyByRws and HasDefiningPcgs,
      IsHomogeneousList ],
    0,

function( efam, pcs )
    local   rws,  pfa,  pcgs,  pag,  id,  g,  dg,  i,  new,
    ord,codepths,pagpow,sorco;

    # quick check
    if not IsIdenticalObj( efam, ElementsFamily(FamilyObj(pcs)) )  then
        Error( "elements family of <pcs> does not match <efam>" );
    fi;

    # check if it is the defining sequence
    rws := efam!.rewritingSystem;
    pfa := DefiningPcgs(efam);
    if List( pcs, UnderlyingElement ) = GeneratorsOfRws(rws)  then
        pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs and IsFamilyPcgs,
                    efam,
                    pcs,[]);
    SetRelativeOrders(pcgs,RelativeOrders(rws));


#T We should not use `InducedPcgs' because `PcgsByPcSequence' is guaranteed
#T to return a new, noninduced pcgs each time! AH
    # otherwise check if we can used an induced system
#    elif IsSSortedList( List( pcs, x -> DepthOfPcElement(pfa,x) ) )  then
#        pcgs := InducedPcgsByPcSequenceNC( pfa, pcs );


    # make an unsorted pcgs
    else

        # sort the elements according to the depth wrt pfa
        pag := [];
        new := [];
        ord := [];
        id  := One(pcs[1]);
        for i  in [ Length(pcs), Length(pcs)-1 .. 1 ]  do
            g  := pcs[i];
            dg := DepthOfPcElement( pfa, g );
            while g <> id and IsBound(pag[dg])  do
                g  := ReducedPcElement( pfa, g, pag[dg] );
                dg := DepthOfPcElement( pfa, g );
            od;
            if g <> id  then
                pag[dg] := g;
                new[dg] := i;
                ord[i]  := RelativeOrderOfPcElement( pfa, g );
            fi;
        od;
        if not IsHomogeneousList(ord) then
          Error("not all relative orders given");
        fi;

        if IsSSortedList(new) and Length(new)=Length(pfa) then
          # we have the same sequence, same depths, just changed by
          # multiplying elements of a lower level
          pcgs := PcgsByPcSequenceCons(
                      IsPcgsDefaultRep,
                      IsPcgs and IsSortedPcgsRep,
                      efam,
                      pcs,[] );
        else
          pcgs := PcgsByPcSequenceCons(
                      IsPcgsDefaultRep,
                      IsPcgs and IsUnsortedPcgsRep,
                      efam,
                      pcs,[] );
        fi;

        pcgs!.sortedPcSequence := pag;
        pcgs!.newDepths        := new;
        pcgs!.sortingPcgs      := pfa;

        # Precompute the leading coeffs and the powers of pag up to the
        # relative order
        pagpow:=[];
        sorco:=[];
        for i in [1..Length(pag)] do
          if IsBound(pag[i]) then
            pagpow[i]:=
              List([1..RelativeOrderOfPcElement(pfa,pag[i])-1],j->pag[i]^j);
            sorco[i]:=LeadingExponentOfPcElement(pfa,pag[i]);
          fi;
        od;
        pcgs!.sortedPcSeqPowers:=pagpow;
        pcgs!.sortedPcSequenceLeadCoeff:=sorco;

        # codepths[i]: the minimum pcgs-depth that can be implied by pag-depth i
        codepths:=[];
        for dg in [1..Length(new)] do
          g:=Length(new)+1;
          for i in [dg..Length(new)] do
            if IsBound(new[i]) and new[i]<g then
              g:=new[i];
            fi;
          od;
          codepths[dg]:=g;
        od;
        pcgs!.minimumCodepths:=codepths;
        SetRelativeOrders( pcgs, ord );
        if IsSortedPcgsRep(pcgs) then
          pcgs!.inversePowers:=
                        List([1..Length(pfa)],i->(1/sorco[i]) mod ord[i]);
        fi;
    fi;

    # that it
    return pcgs;

end );


#############################################################################
InstallMethod( PcgsByPcSequenceNC,
    "elements family by rws",
    true,
    [ IsElementsFamilyByRws,
      IsHomogeneousList ],
    0,

function( efam, pcs )
    local   pcgs,  rws;

    # quick check
    if not IsIdenticalObj( efam, ElementsFamily(FamilyObj(pcs)) )  then
        Error( "elements family of <pcs> does not match <efam>" );
    fi;

    # check if it is the defining sequence
    rws := efam!.rewritingSystem;
    if List( pcs, UnderlyingElement ) = GeneratorsOfRws(rws)  then
        pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs and IsFamilyPcgs,
                    efam,
                    pcs,[]);
      SetRelativeOrders(pcgs,RelativeOrders(rws));

    # make an ordinary pcgs
    else
        pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs,
                    efam,
                    pcs,[] );
    fi;

    # that it
    return pcgs;

end );


#############################################################################
InstallMethod( PcgsByPcSequenceNC,
    "elements family by rws, empty sequence",
    true,
    [ IsElementsFamilyByRws,
      IsList and IsEmpty ],
    0,

function( efam, pcs )
    local   pcgs,  rws;

    # construct a pcgs
    pcgs := PcgsByPcSequenceCons(
                IsPcgsDefaultRep,
                IsPcgs,
                efam,
                pcs,[] );

    # check if it is the defining sequence
    rws := efam!.rewritingSystem;
    if 0 = NumberGeneratorsOfRws(rws)  then
        SetIsFamilyPcgs( pcgs, true );
        SetRelativeOrders( pcgs, []   );
    fi;

    # that it
    return pcgs;

end );


#############################################################################
##
#M  PcgsByPcSequence( <fam>, <pcs> )
##


#############################################################################
InstallMethod( PcgsByPcSequence,
    true,
    [ IsElementsFamilyByRws,
      IsHomogeneousList ],
    0,

function( efam, pcs )
    #T  96/09/26 fceller  do some checks
    return PcgsByPcSequenceNC( efam, pcs );
end );


#############################################################################
InstallMethod( PcgsByPcSequence,
    true,
    [ IsElementsFamilyByRws,
      IsList and IsEmpty ],
    0,

function( efam, pcs )
    #T  96/09/26 fceller  do some checks
    return PcgsByPcSequenceNC( efam, pcs );
end );


#############################################################################
##
#M  SiftedPcElement( <fam-pcgs>, <elm> )
##
InstallMethod( SiftedPcElement, "family pcgs", IsCollsElms,
    [ IsPcgs and IsFamilyPcgs, IsMultiplicativeElementWithInverse ], 0,
function(p,x)
  return OneOfPcgs(p);
end);

#############################################################################
##
#M  DepthOfPcElement( <fam-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( pcgs, elm )
    local   rep;

    rep := ExtRepOfObj( UnderlyingElement(elm) );
    if 0 = Length(rep)  then
        return Length(pcgs)+1;
    else
        return rep[1];
    fi;

end );


#############################################################################
##
#M  ExponentsOfPcElement( <fam-pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement,
    "family pcgs",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( pcgs, elm )
    local   exp,  rep,  i;

    exp := ListWithIdenticalEntries( Length( pcgs ), 0 );
    rep := ExtRepOfObj( UnderlyingElement(elm) );
    for i  in [ 1, 3 .. Length(rep)-1 ]  do
        exp[rep[i]] := rep[i+1];
    od;
    return exp;

end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <fam-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( pcgs, elm )
    local   rep;

    rep := ExtRepOfObj( UnderlyingElement(elm) );
    if 0 = Length(rep)  then
        return fail;
    else
        return rep[2];
    fi;

end );

# methods for `PcElementByExponent' that use the family pcgs directly
#############################################################################
##
#M  PcElementByExponentsNC( <family pcgs>, <list> )
##
InstallMethod( PcElementByExponentsNC, "family pcgs", true,
    [ IsPcgs and IsFamilyPcgs, IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs, list )
  #Assert(1,ForAll(list,i->i>=0));
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),list);
end );

InstallMethod( PcElementByExponentsNC, "family pcgs, FFE", true,
    [ IsPcgs and IsFamilyPcgs, IsRowVector and IsFFECollection ], 0,
function( pcgs, list )
  list:=IntVecFFE(list);
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),list);
end );

InstallOtherMethod( PcElementByExponentsNC, "family pcgs, index", true,
    [ IsPcgs and IsFamilyPcgs, IsRowVector and IsCyclotomicCollection,
      IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs,ind, list )
local l;
  l:=ShallowCopy(pcgs!.zeroVector);
  l{ind}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),l);
end );

InstallOtherMethod( PcElementByExponentsNC, "family pcgs, basisind, FFE", true,
    [ IsPcgs and IsFamilyPcgs, IsRowVector and IsCyclotomicCollection,
    IsRowVector and IsFFECollection ], 0,
function( pcgs,ind, list )
local l;
  l:=ShallowCopy(pcgs!.zeroVector);
  l{ind}:=IntVecFFE(list);
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),l);
end );

#############################################################################
##
#M  PcElementByExponentsNC( <family pcgs induced>, <list> )
##
InstallMethod( PcElementByExponentsNC, "subset induced wrt family pcgs", true,
    [ IsPcgs and IsParentPcgsFamilyPcgs and IsSubsetInducedPcgsRep
      and IsPrimeOrdersPcgs, IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs, list )
local exp;
  #Assert(1,ForAll(list,i->i>=0));
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

InstallOtherMethod( PcElementByExponentsNC,
    "subset induced wrt family pcgs, index", true,
    [ IsPcgs and IsParentPcgsFamilyPcgs and IsSubsetInducedPcgsRep
      and IsPrimeOrdersPcgs, IsRowVector and IsCyclotomicCollection,
      IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs, ind,list )
local exp;
  #Assert(1,ForAll(list,i->i>=0));
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent{ind}}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

#############################################################################
##
#M  PcElementByExponentsNC( <family pcgs induced>, <list> )
##
InstallMethod( PcElementByExponentsNC,
    "subset induced wrt family pcgs, FFE", true,
    [ IsPcgs and IsParentPcgsFamilyPcgs and IsSubsetInducedPcgsRep
      and IsPrimeOrdersPcgs,
      IsRowVector and IsFFECollection ], 0,
function( pcgs, list )
local exp;
  list:=IntVecFFE(list);
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

InstallOtherMethod( PcElementByExponentsNC,
    "subset induced wrt family pcgs, FFE,index", true,
    [ IsPcgs and IsParentPcgsFamilyPcgs and IsSubsetInducedPcgsRep
      and IsPrimeOrdersPcgs, IsRowVector and IsCyclotomicCollection,
      IsRowVector and IsFFECollection ], 0,
function( pcgs,ind, list )
local exp;
  list:=IntVecFFE(list);
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent{ind}}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

#############################################################################
##
#M  ExponentsConjugateLayer( <mpcgs>,<elm>,<e> )
##
# this algorithm does not compute any conjugates but only looks them up and
# adds vectors mod p.

InstallGlobalFunction(DoExponentsConjLayerFampcgs,function(p,m,e,c)
local d,q,l,i,j,k,n,g,v,res;
  c:=ExtRepOfObj(c);
  d:=m!.depthsInParent;
  q:=RelativeOrders(m)[1];
  l:=Length(d);
  e:=ExponentsOfPcElement(p,e){d}; # exponent vector
  for i in [1,3..Length(c)-1] do
    g:=c[i];
    if g<d[1] then
      for j in [1..c[i+1]] do
        # conjugate the vector once by summing the conjugates in each entry
        res:=ShallowCopy(m!.zeroVector);
        for k in [1..l] do
          if e[k]>0 then
            v:=ExponentsOfConjugate(p,d[k],g);
            for n in [1..l] do
              res[n]:=(res[n]+e[k]*v[d[n]]) mod q;
            od;
          fi;
        od;
        e:=res;
      od;
    fi;
  od;
  return e;
end);

InstallMethod( ExponentsConjugateLayer,"subset induced pcgs",
  IsCollsElmsElms,
  [ IsTailInducedPcgsRep and IsParentPcgsFamilyPcgs,
  IsMultiplicativeElementWithInverse,IsMultiplicativeElementWithInverse],0,
function(m,e,c)
local a,p;
  p:=ParentPcgs(m);
  # need to test whether pcgs is normal in parent -- otherwise fail
  if not IsBound(m!.expConjNormalInParent) then
    a:=Difference([1..Length(p)],m!.depthsInParent);
    m!.expConjNormalInParent:=ForAll(p,x->ForAll(m,
      y->ForAll(ExponentsOfPcElement(p,y^x){a},IsZero)));
#Print("Tested eligibility for cheap test ",m!.expConjNormalInParent,"\n");
  fi;
  if m!.expConjNormalInParent=false then
    TryNextMethod();
  fi;
  return DoExponentsConjLayerFampcgs(p,m,e,c);
end);


#############################################################################
##
#M  CanonicalPcElement( <igs>, <8bits-word> )
##
InstallMethod( CanonicalPcElement,
    "tail induced pcgs, 8bits word",
    IsCollsElms,
    [ IsInducedPcgs and IsTailInducedPcgsRep and IsParentPcgsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep ],
    0,

function( pcgs, elm )
    return 8Bits_HeadByNumber( elm, pcgs!.tailStart );
end );


#############################################################################
##
#M  DepthOfPcElement( <8bits-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs (8 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep ],
    0,
    8Bits_DepthOfPcElement );


#############################################################################
##
#M  ExponentOfPcElement( <8bits-pcgs>, <elm> )
##
InstallMethod( ExponentOfPcElement,
    "family pcgs (8bits)",IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep,
      IsPosInt ],
    0,
    8Bits_ExponentOfPcElement );

#############################################################################
##
#M  ExponentsOfPcElement( <8bits-pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement, "family pcgs/8 bit",IsCollsElms,
     [ IsPcgs and IsFamilyPcgs, Is8BitsPcWordRep ], 0,
  8Bits_ExponentsOfPcElement);
#function ( pcgs, elm )
#    local  exp, rep, i;
#    exp := ListWithIdenticalEntries( Length( pcgs ), 0 );
#    rep := 8Bits_ExtRepOfObj( elm );
#    for i  in [ 1, 3 .. Length( rep ) - 1 ]  do
#        exp[rep[i]] := rep[i + 1];
#    od;
#    return exp;
#end);

#############################################################################
##
#M  ExponentsOfPcElement( <8bits-pcgs>, <elm>,<range> )
##
InstallOtherMethod( ExponentsOfPcElement, "family pcgs/8 bit",IsCollsElmsX,
     [ IsPcgs and IsFamilyPcgs, Is8BitsPcWordRep,IsList ], 0,
function( pcgs, elm,range )
  return 8Bits_ExponentsOfPcElement(pcgs,elm){range};
end);
#local   exp,  rep,  i,rp,lr;
#    lr:=Length(range);
#    exp := ListWithIdenticalEntries( lr, 0 );
#    rep := 8Bits_ExtRepOfObj(elm);
#    rp:=1; # position in range
#    # assume the ext rep is always ordered.
#    for i  in [ 1, 3 .. Length(rep)-1 ]  do
#      # do we have to get up through the range?
#      while rp<=lr and range[rp]<rep[i] do
#        rp:=rp+1;
#      od;
#      if rp>lr then
#        break; # we have reached the end of the range
#      fi;
#      if rep[i]=range[rp] then
#        exp[rp] := rep[i+1];
#        rp:=rp+1;
#        fi;
#    od;
#    return exp;
#end );

#############################################################################
##
#M  HeadPcElementByNumber( <8bits-pcgs>, <8bits-word>, <num> )
##
InstallMethod( HeadPcElementByNumber, "family pcgs (8bits)",
  IsCollsElmsX, [ IsPcgs and IsFamilyPcgs,
    IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep, IsInt ], 0,
function( pcgs, elm, pos )
    return 8Bits_HeadByNumber( elm, pos );
end );

#############################################################################
##
#M  CleanedTailPcElement( <8bits-pcgs>, <8bits-word>, <num> )
##
InstallMethod( CleanedTailPcElement, "family pcgs (8bits)",
  IsCollsElmsX, [ IsPcgs and IsFamilyPcgs,
    IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep, IsInt ], 0,
function( pcgs, elm, pos )
    return 8Bits_HeadByNumber( elm, pos );
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <8bits-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs (8 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep ],
    0,
    8Bits_LeadingExponentOfPcElement );


#############################################################################
##
#M  CanonicalPcElement( <igs>, <16bits-word> )
##
InstallMethod( CanonicalPcElement,
    "tail induced pcgs, 16bits word",
    IsCollsElms,
    [ IsInducedPcgs and IsTailInducedPcgsRep and IsParentPcgsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep ],
    0,

function( pcgs, elm )
    return 16Bits_HeadByNumber( elm, pcgs!.tailStart );
end );


#############################################################################
##
#M  DepthOfPcElement( <16bits-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs (16 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep ],
    0,
    16Bits_DepthOfPcElement );


#############################################################################
##
#M  ExponentOfPcElement( <16bits-pcgs>, <elm> )
##
InstallMethod( ExponentOfPcElement,
    "family pcgs (16bits)",IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep,
      IsPosInt ],
    0,
    16Bits_ExponentOfPcElement );

#############################################################################
##
#M  ExponentsOfPcElement( <16bits-pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement, "family pcgs/16 bit",IsCollsElms,
     [ IsPcgs and IsFamilyPcgs, Is16BitsPcWordRep ], 0,
     16Bits_ExponentsOfPcElement);

#############################################################################
##
#M  ExponentsOfPcElement( <16bits-pcgs>, <elm>,<range> )
##
InstallOtherMethod( ExponentsOfPcElement, "family pcgs/16 bit",IsCollsElmsX,
     [ IsPcgs and IsFamilyPcgs, Is16BitsPcWordRep,IsList ],
     0,
function( pcgs, elm,range )
  return 16Bits_ExponentsOfPcElement(pcgs,elm){range};
end );

#############################################################################
##
#M  HeadPcElementByNumber( <16bits-pcgs>, <16bits-word>, <num> )
##
InstallMethod( HeadPcElementByNumber,
    "family pcgs (16bits)",
    IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep,
      IsInt ],
    0,
function( pcgs, elm, pos )
    return 16Bits_HeadByNumber( elm, pos );
end );

#############################################################################
##
#M  CleanedTailPcElement( <16bits-pcgs>, <16bits-word>, <num> )
##
InstallMethod( CleanedTailPcElement,
    "family pcgs (16bits)",
    IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep,
      IsInt ],
    0,
function( pcgs, elm, pos )
    return 16Bits_HeadByNumber( elm, pos );
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <16bits-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs (16 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep ],
    0,
    16Bits_LeadingExponentOfPcElement );


#############################################################################
##
#M  CanonicalPcElement( <igs>, <32bits-word> )
##
InstallMethod( CanonicalPcElement,
    "tail induced pcgs, 32bits word",
    IsCollsElms,
    [ IsInducedPcgs and IsTailInducedPcgsRep and IsParentPcgsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep ],
    0,

function( pcgs, elm )
    return 32Bits_HeadByNumber( elm, pcgs!.tailStart-1 );
end );


#############################################################################
##
#M  DepthOfPcElement( <32bits-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs (32 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep ],
    0,
    32Bits_DepthOfPcElement );


#############################################################################
##
#M  ExponentOfPcElement( <32bits-pcgs>, <elm> )
##
InstallMethod( ExponentOfPcElement,
    "family pcgs (32bits)",
    IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep,
      IsPosInt ],
    0,
    32Bits_ExponentOfPcElement );

#############################################################################
##
#M  ExponentsOfPcElement( <32bits-pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement, "family pcgs/32 bit",IsCollsElms,
     [ IsPcgs and IsFamilyPcgs, Is32BitsPcWordRep ], 0,
  32Bits_ExponentsOfPcElement);

#############################################################################
##
#M  ExponentsOfPcElement( <32bits-pcgs>, <elm>,<range> )
##
InstallOtherMethod( ExponentsOfPcElement, "family pcgs/32 bit",IsCollsElmsX,
     [ IsPcgs and IsFamilyPcgs, Is32BitsPcWordRep,IsList ], 0,
function( pcgs, elm,range )
  return 32Bits_ExponentsOfPcElement(pcgs,elm){range};
end);


#############################################################################
##
#M  HeadPcElementByNumber( <32bits-pcgs>, <32bits-word>, <num> )
##
InstallMethod( HeadPcElementByNumber,
    "family pcgs (32bits)",
    IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep,
      IsInt ],
    0,

function( pcgs, elm, pos )
    return 32Bits_HeadByNumber( elm, pos );
end );

#############################################################################
##
#M  CleanedTailPcElement( <32bits-pcgs>, <32bits-word>, <num> )
##
InstallMethod( CleanedTailPcElement,
    "family pcgs (32bits)",
    IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep,
      IsInt ],
    0,

function( pcgs, elm, pos )
    return 32Bits_HeadByNumber( elm, pos );
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <32bits-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs (32 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep ],
    0,
    32Bits_LeadingExponentOfPcElement );

#############################################################################
##
#M  ExponentsOfConjugate( <pcgs>, <i>, <j> )
##
InstallMethod( ExponentsOfConjugate,"family pcgs: look up",true,
    [ IsPcgs and IsFamilyPcgs, IsPosInt,IsPosInt], 0,
function( pcgs, i, j )
  if not IsBound(pcgs!.conjugates[i][j]) then
    pcgs!.conjugates[i][j]:=ExponentsOfPcElement(pcgs,pcgs[i]^pcgs[j]);
  fi;
  return pcgs!.conjugates[i][j];
end );

#############################################################################
##
#M  ExponentsOfRelativePower( <pcgs>, <i> )
##
InstallMethod( ExponentsOfRelativePower,"family pcgs: look up",true,
    [ IsPcgs and IsFamilyPcgs, IsPosInt], 0,
function( pcgs, i )
  if not IsBound(pcgs!.powers[i]) then
    # happens rarely!
    return ExponentsOfPcElement(pcgs,pcgs[i]^RelativeOrders(pcgs)[i]);
  else
    return pcgs!.powers[i];
  fi;
end );

#############################################################################
##
#M  CleanedTailPcElement( <family pcgs>, <elm>,<dep> )
##
InstallMethod( CleanedTailPcElement, "family pcgs", IsCollsElmsX,
    [ IsPcgs and IsFamilyPcgs, IsMultiplicativeElementWithInverse, IsPosInt ],
     0,
function( pcgs, elm,dep )
  elm:=ExponentsOfPcElement(pcgs,elm);
  elm{[dep..Length(elm)]}:= 0*[dep..Length(elm)];
  return PcElementByExponentsNC(pcgs,elm);
end);


#############################################################################
##
#M  DepthOfPcElement( <unsorted-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement, "unsorted pcgs", IsCollsElms,
    [ IsPcgs and IsUnsortedPcgsRep, IsObject ], 0,
function( pcgs, elm )
    local   pfa,  pcs,  new,  dep,  id,  dg;

    if not IsBound(pcgs!.sortingPcgs) then TryNextMethod();fi;
    pfa := pcgs!.sortingPcgs;
    pcs := pcgs!.sortedPcSequence;
    new := pcgs!.newDepths;
    dep := Length(pcgs)+1;
    id  := OneOfPcgs(pcgs);

    # if <elm> is the identity return the composition length plus one
    if elm = id  then
        return Length(pcgs)+1;
    fi;

    # sift element through the sorted system
    while elm <> id  do
        dg := DepthOfPcElement( pfa, elm );
        if IsBound(pcs[dg])  then
            elm := ReducedPcElement( pfa, elm, pcs[dg] );
            if new[dg] < dep  then
                dep := new[dg];
            fi;
        else
            Error( "<elm> must lie in group defined by <pcgs>" );
        fi;
    od;
    return dep;
end );

#############################################################################
##
#M  DepthOfPcElement( <sorted-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement, "sorted pcgs", IsCollsElms,
    [ IsPcgs and IsSortedPcgsRep, IsObject ], 0,
function( pcgs, elm )
  return DepthOfPcElement(pcgs!.sortingPcgs,elm);
end );

#############################################################################
##
#M  ExponentOfPcElement( <unsorted-pcgs>, <elm>, <pos> )
##
InstallMethod( ExponentOfPcElement, "unsorted pcgs", IsCollsElmsX,
    [ IsPcgs and IsUnsortedPcgsRep, IsObject, IsPosInt ], 0,

function( pcgs, elm, pos )
    local   pfa,  pcs,  new,  dep,  id,  g,  dg,  ll,  lr,  ord,
            led,pcsl,relords,pcspow,codepths,step;

    id  := OneOfPcgs(pcgs);
    # if <elm> is the identity return the null
    if elm = id  then
        return 0;
    fi;

    if not IsBound(pcgs!.sortingPcgs) then TryNextMethod();fi;
    pfa := pcgs!.sortingPcgs;
    relords:=RelativeOrders(pfa);
    pcs := pcgs!.sortedPcSequence;
    pcsl:= pcgs!.sortedPcSequenceLeadCoeff;
    pcspow := pcgs!.sortedPcSeqPowers;
    new := pcgs!.newDepths;
    codepths:=pcgs!.minimumCodepths;

    # sift element through the sorted system
    step:=0; # the index in pcgs up to which we have already computed exponents
    while elm <> id  do
        #compute the next depth `dep' at which we have an exponent in pcgs.
        g   := elm;
        dep := Length(pcgs)+1;
        while g <> id  do
            # do this by stepping down in pag
            dg := DepthOfPcElement( pfa, g );

            if codepths[dg]>dep then
              # once we have reached pfa-depth dg, we cannot achieve `dep'
              # any longer. So we may stop the descent through pfa here
              g:=id;
            elif IsBound(pcs[dg])  then
                ll  := LeadingExponentOfPcElement( pfa, g );
                #lr  := LeadingExponentOfPcElement( pfa, pcs[dg]);
                lr  := pcsl[dg]; # precomputed value
                #ord := RelativeOrderOfPcElement( pfa, g );
                # the relative order is of course the rel. ord. in pfa
                # at depth dg.
                ord:=relords[dg];
                ll  := (ll/lr mod ord);
                #g   := LeftQuotient( pcs[dg]^ll, g );
                g   := LeftQuotient( pcspow[dg][ll], g ); #precomputed

                if new[dg] < dep  then
                    dep := new[dg];
                    led := ll;
                    if dep<=step+1 then
                      # this is the minimum possible pcgs-depth at this
                      # point
                      g:=id;
                    fi;
                fi;
            else
                Error( "<elm> must lie in group defined by <pcgs>" );
            fi;
        od;
        step:=dep;
        if dep = pos  then
            return led;
        fi;
        #elm := LeftQuotient( pcgs[dep]^led, elm );
        elm := LeftQuotientPowerPcgsElement( pcgs,dep,led, elm );
    od;
    return 0;
end );

#############################################################################
##
#M  ExponentOfPcElement( <sorted-pcgs>, <elm>,<pos> )
##
InstallMethod( ExponentOfPcElement, "sorted pcgs", IsCollsElmsX,
    [ IsPcgs and IsSortedPcgsRep, IsObject,IsPosInt ], 0,
function( pcgs, elm,pos )
local pfa,relords,invpow,step,e,p,pcspow;
  pfa := pcgs!.sortingPcgs;
  relords:=RelativeOrders(pfa);
  invpow := pcgs!.inversePowers;
  pcspow := pcgs!.sortedPcSeqPowers;

  for step in [1..pos] do
    e:=ExponentOfPcElement(pfa,elm,step);
    p:=(e*invpow[step]) mod relords[step];
    if e<>0 and step<pos then
      elm:=LeftQuotient(pcspow[step][p],elm);
    fi;
  od;
  return p;
end);

#############################################################################
##
#M  ExponentsOfPcElement( <unsorted-pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement,
    "unsorted pcgs",
    IsCollsElms,
    [ IsPcgs and IsUnsortedPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   pfa,  pcs,  new,  dep,  id,  exp,  g,  dg,  ll,  lr,  ord,
            led,pcsl,relords,pcspow,codepths,step;

    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length(pcgs),0);

    # if <elm> is the identity return the null vector
    if elm = id  then
        return exp;
    fi;

    if not IsBound(pcgs!.sortingPcgs) then TryNextMethod();fi;
    pfa := pcgs!.sortingPcgs;
    relords:=RelativeOrders(pfa);
    pcs := pcgs!.sortedPcSequence;
    pcsl:= pcgs!.sortedPcSequenceLeadCoeff;
    pcspow := pcgs!.sortedPcSeqPowers;
    new := pcgs!.newDepths;
    codepths:=pcgs!.minimumCodepths;

    # sift element through the sorted system
    step:=0; # the index in pcgs up to which we have already computed exponents
    while elm <> id  do
        #compute the next depth `dep' at which we have an exponent in pcgs.
        g   := elm;
        dep := Length(pcgs)+1;
        while g <> id  do
            # do this by stepping down in pag
            dg := DepthOfPcElement( pfa, g );
            if codepths[dg]>dep then
              # once we have reached pfa-depth dg, we cannot achieve `dep'
              # any longer. So we may stop the descent through pfa here
              g:=id;
            elif IsBound(pcs[dg])  then
                ll  := LeadingExponentOfPcElement( pfa, g );
                #lr  := LeadingExponentOfPcElement( pfa, pcs[dg]);
                lr  := pcsl[dg]; # precomputed value
                #ord := RelativeOrderOfPcElement( pfa, g );
                # the relative order is of course the rel. ord. in pfa
                # at depth dg.
                ord:=relords[dg];
                ll  := (ll/lr mod ord);
                #g   := LeftQuotient( pcs[dg]^ll, g );
                g   := LeftQuotient( pcspow[dg][ll], g ); #precomputed
                if new[dg] < dep  then
                    dep := new[dg];
                    led := ll;
                    if dep<=step+1 then
                      # this is the minimum possible pcgs-depth at this
                      # point
                      g:=id;
                    fi;
                fi;
            else
                Error( "<elm> must lie in group defined by <pcgs>" );
            fi;
        od;
        exp[dep] := led;
        step:=dep;
        #elm := LeftQuotient( pcgs[dep]^led, elm );
        elm := LeftQuotientPowerPcgsElement( pcgs,dep,led, elm );
    od;
    return exp;
end );

#############################################################################
##
#M  ExponentsOfPcElement( <unsorted-pcgs>, <elm>, <range> )
##

InstallOtherMethod( ExponentsOfPcElement,
    "unsorted pcgs/range",
    IsCollsElmsX,
    [ IsPcgs and IsUnsortedPcgsRep,
      IsObject,IsList ],
    0,
function( pcgs, elm,range )
    local   pfa,  pcs,  new,  dep,  id,  exp,  g,  dg,  ll,  lr,  ord,
            led,pcsl,max,step,codepths,pcspow,relords;

    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length(pcgs),0);

    # if <elm> is the identity return the null vector
    if elm = id or Length(range)=0  then
        return exp{range};
    fi;

    if not IsBound(pcgs!.sortingPcgs) then TryNextMethod();fi;
    max:=Maximum(range);
    pfa := pcgs!.sortingPcgs;
    relords:=RelativeOrders(pfa);
    pcs := pcgs!.sortedPcSequence;
    pcsl:= pcgs!.sortedPcSequenceLeadCoeff;
    pcspow := pcgs!.sortedPcSeqPowers;
    new := pcgs!.newDepths;
    codepths:=pcgs!.minimumCodepths;

    # sift element through the sorted system
    step:=0; # the index in pcgs up to which we have already computed exponents
    while elm <> id  do
        #compute the next depth `dep' at which we have an exponent in pcgs.
        g   := elm;
        dep := Length(pcgs)+1;
        while g <> id  do
            # do this by stepping down in pag
            dg := DepthOfPcElement( pfa, g );

            if codepths[dg]>dep then
              # once we have reached pfa-depth dg, we cannot achieve `dep'
              # any longer. So we may stop the descent through pfa here
              g:=id;
            elif IsBound(pcs[dg])  then
                ll  := LeadingExponentOfPcElement( pfa, g );
                #lr  := LeadingExponentOfPcElement( pfa, pcs[dg]);
                lr  := pcsl[dg]; # precomputed value
                #ord := RelativeOrderOfPcElement( pfa, g );
                # the relative order is of course the rel. ord. in pfa
                # at depth dg.
                ord:=relords[dg];
                ll  := (ll/lr mod ord);
                #g   := LeftQuotient( pcs[dg]^ll, g );
                g   := LeftQuotient( pcspow[dg][ll], g ); #precomputed
                if new[dg] < dep  then
                    dep := new[dg];
                    led := ll;
                    if dep<=step+1 then
                      # this is the minimum possible pcgs-depth at this
                      # point
                      g:=id;
                    fi;
                fi;
            else
                Error( "<elm> must lie in group defined by <pcgs>" );
            fi;
        od;

        exp[dep] := led;
        step:=dep;
        if dep>=max then
          # we have found all exponents, may stop
          break;
        fi;
        #elm := LeftQuotient( pcgs[dep]^led, elm );
        elm := LeftQuotientPowerPcgsElement( pcgs,dep,led, elm );
    od;
    return exp{range};
end);

#############################################################################
##
#M  ExponentsOfPcElement( <sorted-pcgs>, <elm> )
##
BindGlobal( "ExpPcElmSortedFun", function( pcgs, elm,ran )
local exp,pfa,relords,invpow,max,step,e,p,pcspow;
  exp := [];
  pfa := pcgs!.sortingPcgs;
  relords:=RelativeOrders(pfa);
  invpow := pcgs!.inversePowers;
  pcspow := pcgs!.sortedPcSeqPowers;

  if ran=true then
    max:=Length(pfa);
  elif Length(ran)=0 then
    return [];
  else
    max:=Maximum(ran);
  fi;

  for step in [1..max] do
    e:=ExponentOfPcElement(pfa,elm,step);
    p:=(e*invpow[step]) mod relords[step];
    Add(exp,p);
    if e<>0 and step<max then
      elm:=LeftQuotient(pcspow[step][p],elm);
    fi;
  od;
  if ran<>true then
    return exp{ran};
  else
    return exp;
  fi;
end );

InstallMethod( ExponentsOfPcElement, "sorted pcgs", IsCollsElms,
    [ IsPcgs and IsSortedPcgsRep, IsObject ], 0,
function(pcgs,elm)
  return ExpPcElmSortedFun(pcgs,elm,true);
end);

InstallOtherMethod( ExponentsOfPcElement, "sorted pcgs/range", IsCollsElmsX,
    [ IsPcgs and IsSortedPcgsRep, IsObject,IsList ], 0,
  ExpPcElmSortedFun);

#############################################################################
##
#M  LeadingExponentOfPcElement( <unsorted-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "unsorted pcgs",
    IsCollsElms,
    [ IsPcgs and IsUnsortedPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   pfa,  pcs,  new,  dep,  id,  dg,  ll,  lr,  ord, led,pcsl,
            relords,pcspow,codepths;

    id  := OneOfPcgs(pcgs);
    # if <elm> is the identity return fail
    if elm = id  then
        return fail;
    fi;

    if not IsBound(pcgs!.sortingPcgs) then TryNextMethod();fi;
    pfa := pcgs!.sortingPcgs;
    relords:=RelativeOrders(pfa);
    pcs := pcgs!.sortedPcSequence;
    pcsl:= pcgs!.sortedPcSequenceLeadCoeff;
    pcspow := pcgs!.sortedPcSeqPowers;
    new := pcgs!.newDepths;
    codepths:=pcgs!.minimumCodepths;
    dep := Length(pcgs)+1;

    # sift element through the sorted system
    while elm <> id  do
        # do this by stepping down in pag
        dg := DepthOfPcElement( pfa, elm );

        if codepths[dg]>dep then
          # once we have reached pfa-depth dg, we cannot achieve `dep'
          # any longer. So we may stop the descent through pfa here
          elm:=id;
        elif IsBound(pcs[dg])  then
            ll  := LeadingExponentOfPcElement( pfa, elm );
            #lr  := LeadingExponentOfPcElement( pfa, pcs[dg]);
            lr  := pcsl[dg]; # precomputed value
            #ord := RelativeOrderOfPcElement( pfa, elm );
            # the relative order is of course the rel. ord. in pfa
            # at depth dg.
            ord:=relords[dg];
            ll  := (ll/lr mod ord);
            #elm := LeftQuotient( pcs[dg]^ll, elm);
            elm := LeftQuotient( pcspow[dg][ll], elm ); #precomputed

            if new[dg] < dep  then
                dep := new[dg];
                led := ll;
            fi;
        else
            Error( "<elm> must lie in group defined by <pcgs>" );
        fi;
    od;
    return led;
end );

#############################################################################
##
#M  ExponentOfPcElement( <sorted-pcgs>, <elm>,<pos> )
##
InstallMethod( LeadingExponentOfPcElement, "sorted pcgs", IsCollsElms,
    [ IsPcgs and IsSortedPcgsRep, IsObject ], 0,
function( pcgs, elm )
local d;
  d:=DepthOfPcElement(pcgs!.sortingPcgs,elm);
  return (LeadingExponentOfPcElement(pcgs!.sortingPcgs,elm)
          *pcgs!.inversePowers[d]) mod RelativeOrders(pcgs)[d];
end);

#############################################################################
##
#M  CleanedTailPcElement( <sorted pcgs>, <elm>,<dep> )
##
InstallMethod( CleanedTailPcElement, "sorted pcgs - defer to sorting pcgs",
  IsCollsElmsX,
  [IsPcgs and IsSortedPcgsRep,IsMultiplicativeElementWithInverse,IsPosInt],0,
function( pcgs, elm,dep )
  return CleanedTailPcElement(pcgs!.sortingPcgs,elm,dep);
end);

#############################################################################
##
#M  Order( <obj> )  . . . . . . . . . . . . . . . . . . order of a pc-element
##

#############################################################################
InstallMethod( Order,
        "method for a pc-element",
        HasDefiningPcgs,
        [ IsMultiplicativeElementWithOne ], 3,
        function( g )
    local   pcgs,  rorders,  one,  ord,  d,  rord;

    pcgs := DefiningPcgs( FamilyObj( g ) );
    rorders := RelativeOrders( pcgs );

    one := g^0;
    ord := 1;

    if IsPrimeOrdersPcgs( pcgs ) then
        while g <> one do
            d    := DepthOfPcElement( pcgs, g );
            rord := rorders[ d ];
            ord  := ord * rord;
            g    := g^rord;
        od;
    else
        while g <> one do
            d    := DepthOfPcElement( pcgs, g );
            if not IsBound( rorders[d] ) or rorders[ d ] = 0 then
                return infinity;
            fi;
            rord := rorders[ d ];
            rord := rord / Gcd( ExponentOfPcElement( pcgs, g, d ), rord );
            ord  := ord * rord;
            g    := g^rord;
        od;
    fi;
    return ord;
end );

#############################################################################
InstallMethod( PrimePowerComponents, "method for a pc element",
        HasDefiningPcgs, [ IsMultiplicativeElementWithOne ], 0,
function( el )
local   pcgs, g,ord,cord,ppc,q,r,gcd,p1,p2,i,j,e1,pows,exps,rord;

  pcgs := DefiningPcgs( FamilyObj( el ) );
  if not IsPrimeOrdersPcgs( pcgs ) then
    TryNextMethod(); # don't bother with optimizing the other case
  fi;

  g:=el;
  ord := 1;
  exps:=[];
  pows:=[];

  # first get the order and remember the powers computed
  rord:=RelativeOrderOfPcElement(pcgs,g);
  while rord>1 do
    ord  := ord * rord;
    g    := g^rord;
    Add(exps,ord);
    Add(pows,g);
    rord:=RelativeOrderOfPcElement(pcgs,g);
  od;

  if ord=1 then
    return [g];
  fi;

  g:=el;
  ppc:=[];
  cord:=Collected(Factors(Integers,ord));
  for i in [1..Length(cord)-1] do
    q:=cord[i][1]^cord[i][2];
    r:=ord/q;
    gcd:=Gcdex(q,r);
    p2:=gcd.coeff1*q mod ord;
    p1:=gcd.coeff2*r mod ord;

    # try to find the powers
    j:=Length(exps);
    e1:=false;
    while e1=false and j>0 do
      if IsInt(p1/exps[j]) then
        e1:=pows[j]^(p1/exps[j]);
      fi;
      j:=j-1;
    od;
    if e1=false then
      if Length(exps)>0 then
        # compose from the exponents in exps:
        e1:=OneOfPcgs(pcgs);
        while p1>1 and ForAny(exps,i->i<p1 and i^3>p1) do
          j:=First([Length(exps),Length(exps)-1..1],i->exps[i]<p1
                                                       and exps[i]^3>p1);
          q:=QuoInt(p1,exps[j]);
          e1:=e1*pows[j]^q;
          p1:=p1 mod exps[j];
        od;
        e1:=e1*g^p1;
      else
        e1:=g^p1;
      fi;
    fi;

    Add(ppc,e1);

    ord:=r; # new order
    # try to find the powers
    j:=Length(exps);
    e1:=false;
    while e1=false and j>0 do
      if IsInt(p2/exps[j]) then
        q:=p2/exps[j];
        e1:=pows[j]^q;

        # the remaining powers in case they can be used
        r:=Filtered([j..Length(exps)],k->IsInt(exps[k]/p2));
        pows:=pows{r};
        exps:=exps{r}/p2;
        Assert(1,ForAll([1..Length(exps)],x->e1^exps[x]=pows[x]));
      fi;
      j:=j-1;
    od;
    if e1=false then
      if Length(exps)>0 then
        # compose from the exponents in exps;
        e1:=OneOfPcgs(pcgs);
        while p2>1 and ForAny(exps,i->i<p2 and i^3>p2) do
          j:=First([Length(exps),Length(exps)-1..1],i->exps[i]<p2
                                                       and exps[i]^3>p2);
          q:=QuoInt(p2,exps[j]);
          e1:=e1*pows[j]^q;
          p2:=p2 mod exps[j];
        od;
        e1:=e1*g^p2;
      else
        e1:=g^p2;
      fi;
      exps:=[]; # we can't use any of the precomputed powers
    fi;
    g:=e1;
  od;

  Add(ppc,g);

  return ppc;
end );
