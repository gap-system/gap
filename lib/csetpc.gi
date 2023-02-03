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
##  This file contains the operations for cosets of pc groups
##

#############################################################################
##
#M  CanonicalRightCosetElement( <U>, <g> )  . . . . . . . .  cce for pcgroups
##
##  Main part of the computation of a canonical coset representative in a
##  PcGroup. This is done by factoring with the canonical generators of the
##  subgroup to set the appropriate exponents to zero. Since the
##  representation as an PcWord is "from left to right", we can multiply with
##  subgroup elements from _right_, without changing exponents of the
##  generators with lower depth (that are supposedly in canonical form yet).
##  Since we want _right_ cosets, everything is done with the _inverse_
##  elements, which are representatives for the left cosets.  The routine
##  supposes, that an Cgs has been set up and the relative orders of the
##  generators have been computed by the calling routine.
##
InstallMethod(CanonicalRightCosetElement,"Pc",IsCollsElms,
  [IsPcGroup,IsObject],0,
function(U,g)
local p,ro,a,d1,d,u,e;
  p:=HomePcgs(U);
  ro:=RelativeOrders(p);
  a:=g^(-1);
  d1:=DepthOfPcElement(p,a);
  for u in CanonicalPcgsWrtHomePcgs(U) do
    d:=DepthOfPcElement(p,u);
    if d>=d1 then
      e:=ExponentOfPcElement(p,a,d);
      a:=a*u^(ro[d]-e);
      d1:=DepthOfPcElement(p,a);
    fi;
  od;
  return a^(-1);
end);

#############################################################################
##
#F  DoubleCosetsPcGroup( <G>, <L>, <R> ) .. . . .  double cosets for Pcgroups
##
##  Double Coset calculation for PcGroups, inductive scheme, according to
##  Mike Slattery
##
BindGlobal("DoubleCosetsPcGroup",function(G,A,B)
local r,st,nr,nst,ind,sff,f,m,i,j,ao,Npcgs,v,isi,
      wbase,neubas,wproj,wg,W,x,mats,U,flip,dr,en,sf,u,
      Hpcgs,Upcgs,prime,dim,one,zero,affsp,
      wgr,sp,lgf,ll,Aind;

  Info(InfoCoset,1,"Affine version");
  # if a is small and b large, compute cosets b\G/a and take inverses of the
  # representatives: Since we compute stabilizers in B and a chain down to
  # A, this is remarkable faster

  if 3*Size(A)<2*Size(B) then
    m:=B;
    B:=A;
    A:=m;
    flip:=true;
    Info(InfoCoset,1,"DoubleCosetFlip");
  else
    flip:=false;
  fi;

  # force elementary abelian Series

  sp:=PcgsElementaryAbelianSeries(G);
  lgf:=IndicesEANormalSteps(sp);
  ll:=Length(lgf);
  #eas:=[];
  #for i in [1..Length(lgf)] do
  #  Add(eas,Subgroup(G,sp{[lgf[i]..Length(sp)]}));
  #od;

  r:=[One(G)];
  st:=[B];
  Aind:=InducedPcgs(sp,A);
  for ind in [2..ll] do
    Info(InfoCoset,2,"step ",ind);
    #kpcgs:=InducedPcgsByPcSequenceNC(sp,sp{[lgf[ind]..Length(sp)]});
    #Npcgs:=InducedPcgsByPcSequenceNC(sp,sp{[lgf[ind-1]..Length(sp)]}) mod kpcgs;
    Npcgs:=ModuloTailPcgsByList(sp,sp{[lgf[ind-1]..lgf[ind]-1]},
                                   [lgf[ind]..Length(sp)]);

    #Hpcgs:=InducedPcgsByGenerators(sp,Concatenation(GeneratorsOfGroup(A),
    #                                                kpcgs));
    #Hpcgs:=CanonicalPcgs(Hpcgs) mod kpcgs;

    Hpcgs:=Filtered(Aind,i->DepthOfPcElement(sp,i)<lgf[ind]);

    sff:=SumFactorizationFunctionPcgs(sp,Hpcgs,Npcgs,
       #negative depth: clean out
       -lgf[ind]);

    #fsn:=Factors(Index(eas[ind-1],eas[ind]));
    dim:=lgf[ind]-lgf[ind-1];
    prime:=RelativeOrders(sp)[lgf[ind-1]];

    f:=GF(prime);
    one:=One(f);
    zero:=Zero(f);
    v:= Immutable( IdentityMat(dim,one) );

    # compute complement W
    if Length(sff.intersection)=0 then
      isi:=[];
      wbase:=v;
    else
      isi:=List(sff.intersection,
                            i->ExponentsOfPcElement(Npcgs,i)*one);
      wbase:=BaseSteinitzVectors(v,isi).factorspace;
    fi;

    if Length(wbase)>0 then

      dr:=[1..Length(wbase)]; # 3 for stripping the affine 1
      neubas:=Concatenation(wbase, isi );
      wproj:=List(neubas^(-1), i -> i{[1..Length(wbase)]} );

      wg:=[];
      for i in wbase do
        Add(wg,PcElementByExponentsNC(Npcgs,i));
      od;

      W:=false;

      nr:=[];
      nst:=[];
      for i in [1..Length(r)] do
        x:=r[i];#FactorAgWord(r[i],fgi);
        U:=ConjugateGroup(st[i],x^(-1));

        # build matrices
        mats:=[];
        Upcgs:=InducedPcgs(sp,U);
        for u in Upcgs do
          m:=[];
          for j in wg do
            Add(m,Concatenation((ExponentsConjugateLayer(Npcgs,j,u)*one)*wproj,
                                [zero]));
          od;
          Add(m,Concatenation((ExponentsOfPcElement(Npcgs,
                                 sff.factorization(u).n)*one)*wproj,[one]));
          m:=ImmutableMatrix(prime,m);
          Add(mats,m);
        od;
        # modify later: if U trivial
        if Length(mats)>0 then

          affsp:=ExtendedVectors(FullRowSpace(f,Length(wg)));
          ao:=ExternalSet(U,affsp,Upcgs,mats);
          ao:=ExternalOrbits(ao);
          ao:=rec(representatives:=List(ao,i->
            PcElementByExponentsNC(Npcgs,(Representative(i){dr})*wbase)),
                  stabilizers:=List(ao,StabilizerOfExternalSet));

        else

          if W=false then
            if Length(wg)=0 then
              W:=[One(G)];
            else
              en:=Enumerator(FullRowSpace(f,Length(wg)));
              W:=[];
              wgr:=[1..Length(wg)];
              for u in en do
                Add(W,Product(wgr,j->wg[j]^IntFFE(u[j])));
              od;
            fi;
          fi;

          ao:=rec(
                  representatives:=W,
                  stabilizers:=List(W,i->U)
              );
        fi;

        for j in [1..Length(ao.representatives)] do
          Add(nr,ao.representatives[j]*x);
          # we will finally just need the stabilizers size and not the
          # stabilizer
          if ind<ll then
            Add(nst,ConjugateGroup(ao.stabilizers[j],x));
          else
            Add(nst,ao.stabilizers[j]);
          fi;
        od;
      od;
      r:=nr;
      st:=nst;
    #else
    #  Print(ind,"\n");
    fi;
  od;
  sf:=Size(A)*Size(B);

  for i in [1..Length(r)] do
    if flip then
      f:=[r[i]^(-1),sf/Size(st[i])];
    else
      f:=[r[i],sf/Size(st[i])];
    fi;
    r[i]:=f;
  od;
  return r;
end);

InstallMethod(DoubleCosetRepsAndSizes,"Pc",true,
  [IsPcGroup,IsPcGroup,IsPcGroup],0,
function(G,U,V)
  if Size(G)<=500 then
    TryNextMethod();
  else
    return DoubleCosetsPcGroup(G,U,V);
  fi;
end);


#############################################################################
##
#R  IsRightTransversalPcGroupRep  . . . . . . . right transversal of pc group
##
DeclareRepresentation( "IsRightTransversalPcGroupRep", IsRightTransversalRep,
    [ "transversal", "canonReps" ] );


#############################################################################
##
#M  RightTransversal( <G>, <U> ) . . . . . . . . . for pc groups
##
BindGlobal( "DoRightTransversalPc", function( G, U )
local elements, g, u, e, i,t,depths,gens,p;

  t := Objectify( NewType( FamilyObj( G ),
                               IsList and IsDuplicateFreeList
                           and IsRightTransversalPcGroupRep ),
          rec( group :=G,
            subgroup :=U,
            canonReps:=[]));

  elements := [One(G)];
  p := Pcgs( G );
  depths:=List( InducedPcgs( p,  U  ),
                i->DepthOfPcElement(p,i));
  gens:=Filtered(p, i->not DepthOfPcElement(p,i) in depths);
  for g in Reversed(gens ) do
      u := One(G);
      e := ShallowCopy( elements );
      for i  in [1..RelativeOrderOfPcElement(p,g)-1]  do
          u := u * g;
          UniteSet( elements, e * u );
      od;
  od;
  Assert(1,Length(elements)=Index(G,U));
  t!.transversal:=elements;
  return t;
end );

InstallMethod(RightTransversalOp,"pc groups",IsIdenticalObj,
        [ IsPcGroup, IsGroup ],0,DoRightTransversalPc);

InstallMethod(RightTransversalOp,"pc groups",IsIdenticalObj,
        [ CanEasilyComputePcgs and HasPcgs, IsGroup ],0,DoRightTransversalPc);

InstallMethod(\[\],"for Pc transversals",true,
    [ IsList and IsRightTransversalPcGroupRep, IsPosInt ],0,
function(t,num)
  return t!.transversal[num];
end );

InstallMethod(AsList,"for Pc transversals",true,
    [ IsList and IsRightTransversalPcGroupRep ],0,
function(t)
  return t!.transversal;
end );

InstallMethod(PositionCanonical,"RT",IsCollsElms,
    [ IsList and IsRightTransversalPcGroupRep,
    IsMultiplicativeElementWithInverse ],0,
function(t,elm)
local i;
  elm:=CanonicalRightCosetElement(t!.subgroup,elm);
  i:=1;
  while i<=Length(t) do
    if not IsBound(t!.canonReps[i]) then
      t!.canonReps[i]:=
        CanonicalRightCosetElement(t!.subgroup,t!.transversal[i]);
    fi;
    if elm=t!.canonReps[i] then
      return i;
    fi;
    i:=i+1;
  od;
  return fail;
end);
