#############################################################################
##
#W  csetpc.gi                       GAP library              Alexander Hulpke
##
#H  @(#)$Id:
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for cosets of pc groups
##
Revision.csetpc_gi:=
  "@(#)$Id$";

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
DoubleCosetsPcGroup := function(G,A,B)
local eas,r,st,nr,nst,ind,H,sff,f,m,i,j,ao,Npcgs,v,isi,img,
      wbase,neubas,wproj,wg,W,x,mats,U,flip,dr,en,sf,u,
      Hpcgs,Upcgs,prime,dim,one,zero,iso,affsp,kpcgs,
      wgr,sp,lgf,ll,lgw;

  Info(InfoCoset,1,"A(f)fine version");
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

  sp:=SpecialPcgs(G);
  #eas:=ElementaryAbelianSeries(G);
  lgf:=LGFirst(sp);
  lgw:=LGWeights(sp);
  ll:=Length(lgf);
  #eas:=[];
  #for i in [1..Length(lgf)] do
  #  Add(eas,Subgroup(G,sp{[lgf[i]..Length(sp)]}));
  #od;

  r:=[One(G)];
  st:=[B];
  for ind in [2..ll] do
    kpcgs:=InducedPcgsByPcSequenceNC(sp,sp{[lgf[ind]..Length(sp)]});
    Npcgs:=InducedPcgsByPcSequenceNC(sp,sp{[lgf[ind-1]..Length(sp)]}) mod kpcgs;

    Hpcgs:=InducedPcgsByGenerators(sp,Concatenation(GeneratorsOfGroup(A),
                                                    kpcgs));
    Hpcgs:=CanonicalPcgs(Hpcgs) mod kpcgs;
    sff:=SumFactorizationFunctionPcgs(sp,Hpcgs,Npcgs);

    #fsn:=Factors(Index(eas[ind-1],eas[ind]));
    dim:=lgf[ind]-lgf[ind-1];
    prime:=lgw[lgf[ind-1]][3];

    f:=GF(prime);
    one:=One(f);
    zero:=Zero(f);
    v:=IdentityMat(dim,One(f));

    # compute complement W
    if Length(sff.intersection)=0 then
      isi:=EmptyMatrix(FamilyObj(one),0,dim);
      wbase:=v;
    else
      isi:=List(sff.intersection,
			    i->ExponentsOfPcElement(Npcgs,i)*one);
      wbase:=BaseSteinitzVectors(v,isi);
    fi;

    if Length(wbase)>0 then

      dr:=[1..Length(wbase)]; # 3 for stripping the affine 1
      neubas:=Concatenation(wbase, isi );
      wproj:=List(neubas^(-1), i -> i{[1..Length(wbase)]} );

      wg:=[];
      for i in wbase do
	Add(wg,PcElementByExponents(Npcgs,i));
      od;

      W:=false;

      nr:=[];
      nst:=[];
      for i in [1..Length(r)] do
	x:=r[i];#FactorAgWord(r[i],fgi);
        U:=ConjugateSubgroup(st[i],x^(-1));

	# build matrices
	mats:=[];
	Upcgs:=InducedPcgsByGenerators(sp,GeneratorsOfGroup(U));
        for u in Upcgs do
          m:=[]; 
          for j in wg do
	    Add(m,Concatenation((ExponentsOfPcElement(Npcgs,j^u)*one)*wproj,
	                        [zero])); 
	  od;
	  Add(m,Concatenation((ExponentsOfPcElement(Npcgs,
	                         sff.factorization(u).n)*one)*wproj,[one])); 
	  Add(mats,m);
	od;
	# modify later: if U trivial
	if Length(mats)>0 then

	  affsp:=AffineSpace(FullRowSpace(f,Length(wg)));
	  ao:=ExternalSet(U,affsp,Upcgs,mats);
	  ao:=ExternalOrbits(ao);
	  ao:=rec(representatives:=List(ao,i->
	    PcElementByExponents(Npcgs,(Representative(i){dr})*wbase)),
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
	    Add(nst,ConjugateSubgroup(ao.stabilizers[j],x));
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
      f:=DoubleCoset(B,r[i]^(-1),A);
    else
      f:=DoubleCoset(A,r[i],B);
    fi;
    r[i]:=f;
    #IGNORE_IMMEDIATE_METHODS:=true;
    SetSize(f,sf/Size(st[i]));
    #IGNORE_IMMEDIATE_METHODS:=false;
  od;
  return r;
end;

InstallMethod(DoubleCosetsNC,"Pc",true,
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
#R  IsRightTransversalPcGroup . . . . . . . . . right transversal of pc group
##
IsRightTransversalPcGroup := NewRepresentation
    ( "IsRightTransversalPcGroup", IsRightTransversal,
      [ "group", "subgroup", "transversal", "canonReps" ] );

#############################################################################
##
#M  RightTransversal( <G>, <U> ) . . . . . . . . . for pc groups
##
InstallMethod( RightTransversal, "PC",IsIdentical,
        [ IsSolvableGroup, IsGroup ], 100,
function( G, U )
local elements, g, u, e, i,t,depths,gens,p;

  t := Objectify(NewKind(FamilyObj(G),IsRightTransversalPcGroup),
          rec( group :=G,
            subgroup :=U,
	    canonReps:=[]));

  elements := [One(G)];
  p := Pcgs( G );
  depths:=List( InducedPcgsByGenerators( p, GeneratorsOfGroup( U ) ),
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
  t!.transversal:=elements;
  return t;
end);

InstallMethod(\[\],"RT",true,[IsRightTransversalPcGroup,
        IsPosRat and IsInt ],0,
function(t,num)
  return t!.transversal[num];
end );

InstallMethod(Position,"RT",true,[IsRightTransversalPcGroup,IsObject,
        IsZeroCyc],0,
function(t,elm,zero)
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

#############################################################################
##
#E  csetpc.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
