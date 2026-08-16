#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementation of the methods for SchurMultiplier
##  and Darstellungsgruppen.
##

##    Take a finite presentation F/R for a group G and compute a presentation
##    of one of G's representation groups (Darstellungsgruppen, Schur covers).
##    This is done by assembling a presentation for F/[R,F] and then finding a
##    generating set for a complement C/[R,F] for the intersection of R and
##    [F,F] in R/[R,F].
##
##    No attempt is made to reduce the number of generators in the
##    presentation.  This can be done using the Tietze routines from the GAP
##    library.

BindGlobal("SchurCoverFP",function( G )
local g, i, m, n, r, D, M, M2,fgens,rels,gens,Drels,nam;

  fgens:=FreeGeneratorsOfFpGroup(G);
  rels:=RelatorsOfFpGroup(G);
  n := Length( fgens );
  m := Length( rels );
  nam:=List(fgens,String);
  if not ForAny(nam,x->'k' in x) then
    r:="k";
  else
    r:=First(Concatenation(CHARS_LALPHA,CHARS_UALPHA),
      x->not ForAny(nam,y->x in y));
    if r=fail then
      r:="extra"; # unlikely to have the same name, will just print weirdly
      # but not calculate wrongly
    else
      r:=[r];
    fi;
  fi;

  for i in [1..m] do
    Add(nam,Concatenation(r,String(i)));
  od;

  D := FreeGroup(nam);
  gens:=GeneratorsOfGroup(D);
  Drels := [];
  for i in [1..m] do
    r := rels[i];
    Add(Drels, MappedWord( r, fgens, gens{[1..n]} ) / gens[n+i] );
  od;
  for g in gens{[1..n]} do
    for r in gens{[n+1..n+m]} do
      Add( Drels, Comm( r, g ) );
    od;
  od;

  M := [];
  for r in rels do
    Add( M, List( fgens, g->ExponentSumWord( r, g ) ) );
  od;

  M{[1..m]}{[n+1..n+m]} := IdentityMat(m);
  M := HermiteNormalFormIntegerMat( M );
  M:=Filtered(M,i->not IsZero(i));

  r := 1; i := 1;
  while r <= m and i <= n do
    while i <= n and M[r][i] = 0 do
      i := i+1;
    od;
    if i <= n then  r := r+1; fi;
  od;
  r := r-1;

  if r > 0 then
    M2 := M{[1..r]}{[n+1..n+m]};
    M2 := HermiteNormalFormIntegerMat( M2 );
    M2:=Filtered(M2,i->not IsZero(i));
    for i in [1..Length(M2)] do
      Add(Drels,LinearCombinationPcgs(gens{[n+1..n+m]},M2[i]));
    od;
  fi;

  # make the group
  D:=D/Drels;
  return D;
end);

##  Works for any finite group, but Tietze simplification of the cover makes
##  it practical only for small ones.
BindGlobal("EpimorphismSchurCoverFP",
    function(G)
    local iso,
          hom,
          F,D,p,gens,Fgens,Dgens;

    ## Check to see if G is trivial -- if so then just return
    ## the map from the trivial FP group and G.
    if IsTrivial(G) then
        F := FreeGroup(1);
        D := F/[F.1];
        return GroupHomomorphismByImages(
                   D,  G,
                   GeneratorsOfGroup(D), AsSSortedList(G));
    fi;
    ##
    ##
    iso:=IsomorphismFpGroup(G);
    F:=ImagesSource(iso);
    Fgens:=GeneratorsOfGroup(F);
    D:=SchurCoverFP(F);

  # simplify the fp group
  p:=PresentationFpGroup(D);
  Dgens:=GeneratorsOfPresentation(p);
  TzInitGeneratorImages(p);
  TzOptions(p).printLevel:=0;
  TzGo(p);
  D:=FpGroupPresentation(p);
  gens:=TzPreImagesNewGens(p);
  Dgens:=List(gens,i->MappedWord(i,Dgens,
    Concatenation(Fgens,List([1..(Length(Dgens)-Length(Fgens))],
                             j->One(F)))));

  hom:=GroupHomomorphismByImagesNC(D,G,GeneratorsOfGroup(D),
   List(Dgens,i->PreImagesRepresentative(iso,i)));
  Dgens:=TzImagesOldGens(p);
  Dgens:=List(Dgens{[Length(Fgens)+1..Length(Dgens)]},
           i->MappedWord(i,p!.generators,GeneratorsOfGroup(D)));
  SetKernelOfMultiplicativeGeneralMapping(hom,SubgroupNC(D,Dgens));

  return hom;
end);

InstallMethod(EpimorphismSchurCover,"generic, via fp group",true,[IsGroup],0,
  EpimorphismSchurCoverFP);

##  Schur cover of a non-trivial p-group <G>, as a pc group. `SchurCoverFP' of
##  a power-commutator presentation is again a finite p-group, so the
##  p-quotient algorithm turns it back into a pc group, avoiding the coset
##  enumeration that `EpimorphismSchurCoverFP' needs to make its result usable.
BindGlobal("EpimorphismSchurCoverPGroup",function(G)
local pcgs,n,D,gens,iso,pq,img,epi,cov,mul,pco;
  pcgs:=Pcgs(G);
  n:=Length(pcgs);
  D:=SchurCoverFP(Image(IsomorphismFpGroupByPcgs(pcgs,"f")));
  gens:=GeneratorsOfGroup(D);
  # `SchurCoverFP' introduces one generator per relator; simplifying first
  # pays for itself several times over in the p-quotient
  iso:=IsomorphismSimplifiedFpGroup(D);
  pq:=EpimorphismPGroup(Image(iso),PrimePGroup(G));
  cov:=Range(pq);
  img:=i->ImagesRepresentative(pq,ImagesRepresentative(iso,i));
  # the generators of D beyond the first n generate the kernel of D -> G
  mul:=SubgroupNC(cov,List(gens{[n+1..Length(gens)]},img));
  pco:=List(gens{[1..n]},img);
  Append(pco,Pcgs(mul));
  pco:=PcgsByPcSequenceNC(FamilyObj(One(cov)),pco);
  epi:=GroupHomomorphismByImagesNC(cov,G,pco,
         Concatenation(pcgs,List(Pcgs(mul),i->One(G))));
  SetKernelOfMultiplicativeGeneralMapping(epi,mul);
  return epi;
end);


##  For P a Sylow p-subgroup of G, the map H_2(P) -> H_2(G) is onto on p-parts
##  with kernel generated by the ``fusion'' relations
##    cor^P_Q(y) - cor^P_{Q^g}((c_g)_*(y)),   Q = P \cap P^{g^-1}, y in H_2(Q)
##  (the homology analogue of the Cartan-Eilenberg stable element theorem).
##
##  To evaluate one: given a presentation F -> Q with relators r_i and a
##  central extension <epi>: C -> P with kernel M, a lift of F -> Q <= P to
##  F -> C maps each r_i into M. For an integer vector a with
##  sum_i a_i*(exponent sums of r_i) = 0 the product of the r_i-images to the
##  a_i is independent of the lift, and these products are exactly the image
##  of cor^P_Q; lifting F -> Q -> Q^g <= P instead gives the other side.
##
##  Running y only over the image of cor^P_Q -- as the pre-4.5 code did --
##  misses the relations from its kernel and overestimates the multiplier.

# Q is a p-group, so use its (short) power-commutator presentation.
BindGlobal("SCHUR_FusionSetup",function(Q)
local iso,F;
  iso:=IsomorphismFpGroupByPcgs(Pcgs(Q),"f");
  F:=Image(iso);
  return rec(
    gens:=List(GeneratorsOfGroup(F),i->PreImagesRepresentative(iso,i)),
    free:=FreeGeneratorsOfFpGroup(F),
    rels:=RelatorsOfFpGroup(F),
    null:=NullspaceIntMat(List(RelatorsOfFpGroup(F),
            r->List(FreeGeneratorsOfFpGroup(F),i->ExponentSumWord(r,i)))));
end);

# Images of a generating set of H_2(Q) under cor^P_{Q^act} o act_*, as
# elements of the kernel of <epi>. <data> comes from `SCHUR_FusionSetup' for
# Q; <act> is a function mapping Q into P by conjugation.
BindGlobal("SCHUR_CorestrictionValues",function(epi,data,act)
local lift,val,res,a,i,x;
  lift:=List(data.gens,i->PreImagesRepresentative(epi,act(i)));
  val:=List(data.rels,r->MappedWord(r,data.free,lift));
  res:=[];
  for a in data.null do
    x:=One(Source(epi));
    for i in [1..Length(a)] do
      if a[i]<>0 then
        x:=x*val[i]^a[i];
      fi;
    od;
    Add(res,x);
  od;
  return res;
end);

InstallGlobalFunction(SchuMu,function(g,p)
local s,iso,S,pcgs,n,cov,pco,i,d,q,data,base,img,
      rels,epi,mul,hom,dc;
  s:=SylowSubgroup(g,p);
  if IsCyclic(s) then
    # the multiplier of a cyclic group is trivial
    return InverseGeneralMapping(IsomorphismPcGroup(s));
  fi;

  # Do the work inside an isomorphic pc group: building the presentations
  # below is an order of magnitude cheaper there than in, say, a matrix group.
  if IsPcGroup(s) then
    iso:=IdentityMapping(s);
  else
    iso:=IsomorphismPcGroup(s);
  fi;
  S:=Image(iso);
  pcgs:=Pcgs(S);
  n:=Normalizer(g,s);

  epi:=EpimorphismSchurCoverPGroup(S);
  cov:=Source(epi);
  mul:=KernelOfMultiplicativeGeneralMapping(epi);
  Info(InfoSchur,1,"multiplier of Sylow subgroup: ",AbelianInvariants(mul));
  if IsTrivial(mul) then
    return InverseGeneralMapping(IsomorphismPcGroup(s));
  fi;

  # It suffices to consider double coset representatives of n in g, provided
  # we also use the full action of n on s: if x=a*d*b with a,b in n, the
  # fusion induced by x is the composite of the fusions induced by a, d, b.
  rels:=TrivialSubgroup(cov);
  data:=SCHUR_FusionSetup(S);
  base:=SCHUR_CorestrictionValues(epi,data,x->x);
  for i in GeneratorsOfGroup(n) do
    img:=SCHUR_CorestrictionValues(epi,data,
           x->ImagesRepresentative(iso,PreImagesRepresentative(iso,x)^i));
    rels:=ClosureGroup(rels,List([1..Length(base)],j->base[j]/img[j]));
  od;
  Info(InfoSchur,2,"normalizer fusion leaves ",Index(mul,rels));
  if Index(mul,rels)=1 then
    # nothing survives, so skip the (potentially costly) double cosets
    return InverseGeneralMapping(IsomorphismPcGroup(s));
  fi;

  dc:=List(DoubleCosetRepsAndSizes(g,n,n),i->i[1]);
  i:=1;
  while i<=Length(dc) and Index(mul,rels)>1 do
    d:=dc[i];
    # the double coset of the identity is already dealt with above
    if not d in n then
      q:=Intersection(s,ConjugateSubgroup(s,d^-1));
      # cyclic groups have trivial multiplier, so contribute no relations
      if not IsCyclic(q) then
        data:=SCHUR_FusionSetup(Image(iso,q));
        base:=SCHUR_CorestrictionValues(epi,data,x->x);
        img:=SCHUR_CorestrictionValues(epi,data,
               x->ImagesRepresentative(iso,PreImagesRepresentative(iso,x)^d));
        rels:=ClosureGroup(rels,List([1..Length(base)],j->base[j]/img[j]));
      fi;
    fi;
    i:=i+1;
  od;
  Info(InfoSchur,1,"p-part of the multiplier has order ",Index(mul,rels));

  # form the quotient, make it the new cover and the new multiplicator; the
  # result must map onto the Sylow subgroup of g, not onto its pc copy
  hom:=NaturalHomomorphismByNormalSubgroupNC(cov,rels);
  pco:=List(pcgs,i->Image(hom,PreImagesRepresentative(epi,i)));
  mul:=Image(hom,mul);
  cov:=Image(hom,cov);
  Append(pco,Pcgs(mul));
  pco:=PcgsByPcSequenceNC(FamilyObj(One(cov)),pco);
  epi:=GroupHomomorphismByImagesNC(cov,s,pco,
         Concatenation(List(pcgs,i->PreImagesRepresentative(iso,i)),
                       List(Pcgs(mul),i->One(s))));
  SetKernelOfMultiplicativeGeneralMapping(epi,mul);
  return epi;

end);

InstallMethod(AbelianInvariantsMultiplier,"generic: via Schur cover",true,
  [IsGroup],0,
  G->AbelianInvariants(KernelOfMultiplicativeGeneralMapping(
       EpimorphismSchurCover(G))));

BindGlobal("SCHUR_MultiplierBySylow",function(G)
local a,i;
  if not (IsPermGroup(G) or IsPcGroup(G)) then
    # the Sylow subgroup and double coset computations below work through a
    # permutation image anyway; going there once is markedly faster
    return AbelianInvariantsMultiplier(Image(IsomorphismPermGroup(G)));
  fi;
  a:=[];
  for i in Filtered(Collected(Factors(Size(G))),i->i[2]>1) do
    Append(a,AbelianInvariants(KernelOfMultiplicativeGeneralMapping(
               SchuMu(G,i[1]))));
  od;
  Sort(a);
  return a;
end);

##  `SchuMu' needs Sylow subgroups, their normalizers and double cosets, so
##  install it for the representations which supply these rather than for all
##  finite groups. Groups shipping their own methods -- pcp groups in the
##  polycyclic package, say -- then keep them without any need to fiddle with
##  method ranks.
InstallMethod(AbelianInvariantsMultiplier,"via Sylow subgroups",true,
  [IsPermGroup],0,SCHUR_MultiplierBySylow);

InstallMethod(AbelianInvariantsMultiplier,"via Sylow subgroups",true,
  [IsPcGroup],0,SCHUR_MultiplierBySylow);

InstallMethod(AbelianInvariantsMultiplier,"via Sylow subgroups",true,
  [IsGroup and IsFinite and IsHandledByNiceMonomorphism],0,
  SCHUR_MultiplierBySylow);

# <hom> is a homomorphism from a finite group onto an fp group. It returns
# an isomorphism from the same group onto an isomorphic fp group <F>, such
# that no negative exponent occurs in the relators of <F>.
#
BindGlobal("PositiveExponentsPresentationFpHom",function(hom)
local G,F,geni,ro,fam,r,i,j,rel,n,e;
  G:=Image(hom);
  F:=FreeGeneratorsOfFpGroup(G);
  geni:=List(GeneratorsOfGroup(G),i->PreImagesRepresentative(hom,i));
  ro:=List(geni,Order);
  fam:=FamilyObj(F[1]);
  r:=[];
  for i in RelatorsOfFpGroup(G) do
    rel:=[];
    for j in [1..NrSyllables(i)] do
      n:=GeneratorSyllable(i,j);
      Add(rel,n);
      e:=ExponentSyllable(i,j);
      if e<0 then
        e:=e mod ro[n];
      fi;
      Add(rel,e);
    od;
    Add(r,ObjByExtRep(fam,rel));
  od;
  # ensure the relative orders are relators.
  for i in [1..Length(ro)] do
    if not F[i]^ro[i] in r then
      Add(r,F[i]^ro[i]);
    fi;
  od;
  # new fp group
  F:=FreeGroupOfFpGroup(G)/r;
  hom:=GroupHomomorphismByImagesNC(Source(hom),F,geni,GeneratorsOfGroup(F));
  return hom;
end);

##  Evaluate each relator of the presentation <FG> of G as a product over a
##  transversal of the Sylow subgroup, i.e. apply the transfer G -> M_p. The
##  result records, per relator, the obstruction to lifting <FG> over M_p.
InstallGlobalFunction(CorestEval,function(FG,s)
local G,H,D,T,i,j,l,a,h,jj,nk,evals,rels,gens,r,np,g,invlist,el,elp,TL,rp,pos,
      act,val,ainv,vinv,one;

  G:=Image(FG);
  H:=Image(s);
  D:=Source(s);
  Info(InfoSchur,2,"lift index:",Index(G,H));
  T:=RightTransversal(G,H);
  TL:=List(T,i->i); # we need to refer to the elements very often

  rels:=RelatorsOfFpGroup(Source(FG));
  gens:=List(GeneratorsOfGroup(Source(FG)),i->Image(FG,i));

  # this will guarantee we always take the same preimages
  el:=AsSSortedListNonstored(H);
  elp:=List(el,i->PreImagesRepresentative(s,i));
  #ensure the preimage of identity is one
  if IsOne(el[1]) then
    pos:=1;
  else
    pos:=Position(el,One(H));
  fi;
  elp[pos]:=One(elp[pos]);
  one:=One(D);

  # Tabulate, for every generator and its inverse, the induced permutation of
  # the transversal together with the preimage of the resulting Schreier
  # element. The relator loop below then does no arithmetic in G at all, which
  # is what made it expensive -- in particular for matrix groups. Building the
  # tables costs Length(gens)*Index(G,H) steps, the loop they serve
  # Index(G,H) times the total length of the relators.
  act:=[]; val:=[]; ainv:=[]; vinv:=[];
  for i in [1..Length(gens)] do
    g:=gens[i];
    act[i]:=[]; val[i]:=[]; ainv[i]:=[]; vinv[i]:=[];
    for j in [1..Length(TL)] do
      np:=TL[j]*g;
      nk:=PositionCanonical(T,np);
      act[i][j]:=nk;
      val[i][j]:=elp[Position(el,np/TL[nk])];
      np:=TL[j]/g;
      nk:=PositionCanonical(T,np);
      ainv[i][j]:=nk;
      vinv[i][j]:=elp[Position(el,np/TL[nk])];
    od;
  od;

  # deal with inverses
  invlist:=[];
  for i in [1..Length(gens)] do
    h:=one;
    for j in [1..Length(TL)] do
      h:=h*val[i][j]*vinv[i][act[i][j]];
    od;
    Add(invlist,h);
  od;

  evals:=[];

  for rp in [1..Length(rels)] do

    CompletionBar(InfoSchur,2,"Relator Loop: ",rp/Length(rels));
    r:=rels[rp];
    i:=LetterRepAssocWord(r);
    a:=one;

    # take care of inverses
    for l in [1..Length(i)] do
      if i[l]<0 then
        a:=a*invlist[-i[l]];
      fi;
    od;

    for j in [1..Length(TL)] do

      jj:=j;
      h:=one;
      for l in i do
        if l<0 then
          h:=h*vinv[-l][jj];
          jj:=ainv[-l][jj];
        else
          h:=h*val[l][jj];
          jj:=act[l][jj];
        fi;
      od;

      #Print(PreImagesRepresentative(s,Image(s,h))*h,"\n");
      #a:=a/PreImagesRepresentative(s,Image(s,h))*h;
      a:=a/h*elp[Position(el,Image(s,h))];

    od;
    Add(evals,[r,a]);
  od;
  CompletionBar(InfoSchur,2,"Relator Loop: ",false);
  return evals;
end);

InstallGlobalFunction(RelatorFixedMultiplier,function(hom,p)
local G,B,P,s,D,i,j,v,ri,rank,bas,basr,row,rel,sol,snf,mat;
  G:=Source(hom);
  rank:=Length(GeneratorsOfGroup(G));
  B:=ImagesSource(hom);
  P:=SylowSubgroup(B,p);

  s:=SchuMu(B,p);
  D:=Source(s);
  ri:=CorestEval(hom,s);

  # now rel is a list of relators and their images in M(B).
  # find relator relations in F/F' and evaluate these in M(B) to find
  # M_R(B).
  bas := [];
  basr := [];
  mat:=[];
  for rel in ri do
    row := ListWithIdenticalEntries(rank,0);
    for i  in [1..NrSyllables(rel[1])]  do
      j := GeneratorSyllable(rel[1],i);
      row[j]:=row[j]+ExponentSyllable(rel[1],i);
    od;
    Add(mat,row);
  od;
  # SNF
  snf:=NormalFormIntMat(mat,15);
  mat:=mat*snf.coltrans; # changed coordinates (parent presentation)
  bas:=snf.rowtrans*mat;
  v:=Filtered([1..Length(bas)],i-> not IsZero(bas[i]));
  # express the basis elements
  bas:=bas{v};
  basr:=[];
  for i in v do
    rel:=One(Source(s));
    for j in [1..Length(mat)] do
      rel:=rel*ri[j][2]^snf.rowtrans[i][j];
    od;
    Add(basr,rel);
  od;

  # now collect relations
  v:=TrivialSubgroup(D);
  for i in [1..Length(mat)] do
    sol:=SolutionMat(bas,mat[i]);
    rel:=ri[i][2];
    for j in [1..Length(sol)] do
      rel:=rel/basr[j]^sol[j];
    od;
    if not rel in v then
      #NC is safe
      v:=ClosureSubgroupNC(v,rel);
    fi;
  od;

  for i in basr do
    for j in basr do
      # NC is safe
      v:=ClosureSubgroupNC(v,Comm(i,j));
    od;
  od;

  Info(InfoSchur,1,"Extra central part:",
       Index(KernelOfMultiplicativeGeneralMapping(s),v));
  # form the quotient
  j:=NaturalHomomorphismByNormalSubgroupNC(D,v);
  i:=GeneratorsOfGroup(Image(j));
  i:=GroupHomomorphismByImagesNC(Image(j),P,i,
       List(i,k->ImageElm(s,PreImagesRepresentative(j,k))));
  SetKernelOfMultiplicativeGeneralMapping(i,
    Image(j,KernelOfMultiplicativeGeneralMapping(s)));
  return i;

end);

##  Build a Schur cover of <G> as an fp group: take a presentation of <G>,
##  adjoin central generators for the multiplier of each relevant prime (from
##  `SchuMu'), and correct each relator by its transfer value (from
##  `CorestEval'), which is precisely what makes the extension a stem one.
BindGlobal("MulExt",function(G,pl)
local hom,      #isomorphism fp
      ng,ngl,   # nr generators,list
      s,sl,     # SchuMu,list
      ab,ms,    # abelian invariants, multiplier size
      pll,      # relevant primes
      F,        # free group
      rels,     # relators
      rel2,     # cohomology relators
      ce,       # corestriction
      p,pp,     # prime, index
      mg,       # multiplier generators
      sdc,      # decomposition function
      gens,free,# generators
      i,j,      # loop
      q,qhom;   # quotient



  # eliminate useless primes
  pl:=Intersection(pl,
        List(Filtered(Collected(Factors(Size(G))),i->i[2]>1),i->i[1]));

  hom:=IsomorphismFpGroup(G);
  hom:=hom*IsomorphismSimplifiedFpGroup(Image(hom));
  Info(InfoSchur,2,Length(RelatorsOfFpGroup(Range(hom)))," relators");

  # think positive...
  #if SYF then
  #  hom:=PositiveExponentsPresentationFpHom(hom);
  #fi;

  hom:=InverseGeneralMapping(hom);
  ng:=Length(GeneratorsOfGroup(Source(hom)));

  sl:=[];
  ngl:=[ng];
  pll:=[];
  ms:=1;
  for p in pl do
    s:=SchuMu(G,p);
    if Size(KernelOfMultiplicativeGeneralMapping(s))>1 then
      Add(pll,p);
      Add(sl,s);
      ab:=AbelianInvariants(KernelOfMultiplicativeGeneralMapping(s));
      ms:=ms*Product(ab);
      Add(ngl,Last(ngl)+Length(ab));
    fi;
  od;
  Info(InfoSchur,1,"Relevant primes:",pll);
  Info(InfoSchur,1,"Multiplicator size:",ms);
  if Length(pll)=0 then
    return IdentityMapping(G);
  fi;

  #F:=FreeGroup(List([1..Last(ngl)],x->Concatenation("@",String(x))));
  F:=FreeGroup(Last(ngl));

  rels:=[];
  rel2:=[];
  for pp in [1..Length(pll)] do
    p:=pll[pp];
    Info(InfoSchur,2,"Cohomology for prime :",p);
    s:=sl[pp];
    mg:=IsomorphismPermGroup(KernelOfMultiplicativeGeneralMapping(s));
    mg:=List(IndependentGeneratorsOfAbelianGroup(Image(mg)),
          i->PreImagesRepresentative(mg,i));
    sdc:=ListWithIdenticalEntries(Last(ngl),One(Source(s)));
    sdc{[ngl[pp]+1..ngl[pp+1]]}:=mg;

    sdc:=GroupHomomorphismByImagesNC(F,KernelOfMultiplicativeGeneralMapping(s),
          GeneratorsOfGroup(F),sdc);

    gens:=GeneratorsOfGroup(F){[ngl[pp]+1..ngl[pp+1]]};
    ce:=CorestEval(hom,s);

    for i in gens do
      Add(rels,i^Order(Image(sdc,i)));
      for j in GeneratorsOfGroup(F) do
        if i<>j then
          Add(rels,Comm(i,j));
        fi;
      od;
    od;

    q:=[];
    for i in ce do
      Add(q,PreImagesRepresentative(sdc,i[2]));
    od;
    rel2[pp]:=q;
  od;

  # now run through the last ce
  gens:=GeneratorsOfGroup(F){[1..ng]};
  free:=FreeGeneratorsOfFpGroup(Source(hom));
  for i in [1..Length(ce)] do
    q:=One(F);
    for j in [1..Length(pll)] do
      q:=q*rel2[j][i];
    od;
    Add(rels,MappedWord(ce[i][1],free,gens)/q);
  od;

  q:=F/rels;
  # Checking the order means enumerating the cosets of the trivial subgroup of
  # q, which for larger groups costs far more than the whole computation.
  if AssertionLevel()>0 then
    if Size(q)<>Size(G)*ms then
      Error("inconsistent multiplier size");
    fi;
  else
    SetSize(q,Size(G)*ms);
  fi;
  qhom:=GroupHomomorphismByImages(q,G,GeneratorsOfGroup(q),
          Concatenation(List(GeneratorsOfGroup(Source(hom)),i->Image(hom,i)),
            List([ng+1..Length(GeneratorsOfGroup(q))],
                 i->One(G)) ));
  SetIsSurjective(qhom,true);
  SetSize(Source(qhom),Size(G)*ms);

  return qhom;
end);

BindGlobal( "SCHUR_CoverForPrimes", function(G,pl)
  if IsPGroup(G) then
    # base case of the recursion: `MulExt' would call `SchuMu', which in turn
    # asks for a Schur cover of a Sylow subgroup, i.e. of G
    if PrimePGroup(G) in pl then
      return EpimorphismSchurCoverPGroup(G);
    fi;
    return IdentityMapping(G);
  fi;
  return MulExt(G,pl);
end );

BindGlobal( "DoMulExt", function(arg)
local G,pl,iso,hom,D,gens,ker;
  G:=arg[1];
  if not IsFinite(G) then
    Error("cover is only defined for finite groups");
  elif IsTrivial(G) then
    return IdentityMapping(G);
  fi;
  if Length(arg)>1 then
    pl:=arg[2];
  else
    pl:=PrimeDivisors(Size(G));
  fi;
  if IsSubgroupFpGroup(G) then
    # the generic method below simplifies the presentation of the cover, but
    # only exists for one argument
    if Length(arg)=1 then
      TryNextMethod();
    fi;
    return SCHUR_CoverForPrimes(G,pl);
  elif not (IsPermGroup(G) or IsPcGroup(G)) then
    # `CorestEval' runs over a transversal of a Sylow subgroup, which is far
    # cheaper in a permutation image; transport the cover back afterwards
    iso:=IsomorphismPermGroup(G);
    hom:=SCHUR_CoverForPrimes(Image(iso),pl);
    D:=Source(hom);
    gens:=GeneratorsOfGroup(D);
    ker:=KernelOfMultiplicativeGeneralMapping(hom);
    hom:=GroupHomomorphismByImagesNC(D,G,gens,
           List(gens,
                i->PreImagesRepresentative(iso,ImagesRepresentative(hom,i))));
    SetKernelOfMultiplicativeGeneralMapping(hom,ker);
    SetIsSurjective(hom,true);
    return hom;
  fi;
  return SCHUR_CoverForPrimes(G,pl);
end );

# installed for the same filters as the method for AbelianInvariantsMultiplier,
# see the comment there
InstallMethod(EpimorphismSchurCover,"Holt's algorithm",true,
  [IsPermGroup],0,DoMulExt);

InstallMethod(EpimorphismSchurCover,"Holt's algorithm",true,
  [IsPcGroup],0,DoMulExt);

InstallMethod(EpimorphismSchurCover,"Holt's algorithm",true,
  [IsGroup and IsFinite and IsHandledByNiceMonomorphism],0,DoMulExt);

InstallOtherMethod(EpimorphismSchurCover,"Holt's algorithm, primes",true,
  [IsGroup,IsList],0,DoMulExt);

InstallMethod(SchurCover,"general: Holt's algorithm",true,[IsGroup],0,
  G->Source(EpimorphismSchurCover(G)));

############################################################################
############################################################################
##
##  Additional attributes and properties                     Robert F. Morse
##  derived from computing the Schur Cover
##  of a group.
##
##  A Epicentre
##  O NonabelianExteriorSquare
##  O EpimorphismNonabelianExteriorSquare
##  P IsCapable
##
############################################################################
##
#A  Epicentre(<G>)
##
##  There are various ways of describing the epicentre of a group. It is
##  the smallest normal subgroup $N$ of $G$ such that $G/N$ is a central
##  quotient of some group $H$. It is also the exterior center of a group.
##
InstallMethod(Epicentre,"Naive Method",true,[IsGroup],0,
    function(G)
        local epi;
        epi := EpimorphismSchurCover(G);
        return Image(epi,Center(Source(epi)));
    end
);

#############################################################################
##
#A  Epicentre(G,N)
##
##  Place holder attribute for computing the epicentre relative to a normal
##  subgroup $N$. This is an attribute of $N$.
##
InstallOtherMethod(Epicentre,"Naive method",true,[IsGroup,IsGroup],0,
    function(G,N)
        TryNextMethod();
    end
);

#############################################################################
##
#O  NonabelianExteriorSquare
##
##  Computes the Nonabelian Exterior Square $G\wedge G$ of a group $G$.
##  For finitely generated groups this is the derived subgroup of the
##  Schur cover -- which is an invariant for all Schur covers of group.
##
InstallMethod(NonabelianExteriorSquare, "Naive method", true, [IsGroup],0,
    G->DerivedSubgroup(SchurCover(G)));

#############################################################################
##
#O  EpimorphismNonabelianExteriorSquare(<G>)
##
##  Computes the mapping $G\wedge G \to G$. The kernel of this
##  mapping is isomorphic to the Schur Multiplicator.
##
InstallMethod(EpimorphismNonabelianExteriorSquare, "Naive method", true,
    [IsGroup],0,
    function(G)
        local epi, ## Epimorphism from the Schur cover to G
              D;   ## Derived subgroup of the Schur Cover

        epi := EpimorphismSchurCover(G);
        D   := DerivedSubgroup(Source(epi));

        ## Compute the restricted mapping of epi from
        ## D --> G
        ##
        ## Need to check that D is trivial i.e. has no generators.
        ## In this case we create the homomorphism using the group's
        ## elements rather than generators.
        ##
        if IsTrivial(D) then

            return GroupHomomorphismByImages(
                       D, Image(epi,D),
                       AsSSortedList(D), AsSSortedList(Image(epi,D)));
        fi;

        return GroupHomomorphismByImages(
                   D, Image(epi,D),
                   GeneratorsOfGroup(D),
                   List(GeneratorsOfGroup(D),x->Image(epi,x)));

    end
);

#############################################################################
##
#P  IsCentralFactor(<G>)
##
##  Determines if $G$ is a central factor of some group $H$ or not.
##
InstallMethod(IsCentralFactor, "Naive method", true, [IsGroup], 0,
    G -> IsTrivial(Epicentre(G)));
