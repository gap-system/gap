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

InstallMethod(SchurCover,"of fp group",true,[IsSubgroupFpGroup],0,
  SchurCoverFP);

InstallMethod(EpimorphismSchurCover,"generic, via fp group",true,[IsGroup],1,
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


# compute commutators and their images so that we know the image on `mul',
# create out relations v=v^g.
BindGlobal("CommutGenImgs",function(pcgs,g,h,mul)
local u,a,b,i,j,c,x,y;
  u:=TrivialSubgroup(mul);
  a:=[];
  b:=[];
  x:=One(mul);
  y:=One(h[1]);
  repeat
    for i in [1..Length(g)] do
      for j in [1..i-1] do
        c:=Comm(g[i],g[j]^x);
        if not c in u then
          Add(a,c);
          Add(b,Comm(h[i],h[j]^y));
          u:=ClosureGroup(u,c);
          if IsSubgroup(u,mul) then
            a:=CanonicalPcgsByGeneratorsWithImages(pcgs,a,b);
            return List(GeneratorsOfGroup(mul),
                i->i/PcElementByExponentsNC(a[2],ExponentsOfPcElement(a[1],i)));
          fi;
        fi;
      od;
    od;
    #in rare cases we also need commutators of conjugates.
    if Size(mul)=1 then
      return [];
    else
      Info(InfoSchur,2,"the commutators do not generate!");
      i:=Random(1,Length(g));
      x:=x*g[i];
      y:=y*h[i];
    fi;
  until false;
end);

InstallGlobalFunction(SchuMu,function(g,p)
local s,pcgs,n,l,cov,pco,ng,gens,imgs,ran,zer,i,j,e,a,
      rels,de,epi,mul,hom,dc,q,qs;
  s:=SylowSubgroup(g,p);
  if IsCyclic(s) then
    return InverseGeneralMapping(IsomorphismPcGroup(s));
  fi;

  pcgs:=Pcgs(s);
  n:=Normalizer(g,s);
  l:=LogInt(Size(s),p);

  # compute a Darstellungsgruppe as PC-Group
  de:=EpimorphismSchurCover(s);

  # exponent of M(G) is at most p^(n/2)
  epi:=EpimorphismPGroup(Source(de),p,PClassPGroup(s)+Int(l/2));
  cov:=Range(epi);
  mul:=Image(epi,KernelOfMultiplicativeGeneralMapping(de));
  if Size(mul)=1 then
    return InverseGeneralMapping(IsomorphismPcGroup(s));
  fi;

  # get a decent pcgs for the cover
  pco:=List(pcgs,i->Image(epi,PreImagesRepresentative(de,i)));
  Append(pco,Pcgs(mul));
  pco:=PcgsByPcSequenceNC(FamilyObj(One(cov)),pco);

  # the induced action of n on the derived subgroup of the cover:
  # we prescribe images on the commutator factor group. These may not be
  # entirely correct -- multiplicator elements are missing. However on [G,G]
  # they are unique -- the wrong central parts cancel out
  # (use Burnside's basis theorem)

  ng:=GeneratorsOfGroup(n);
  gens:=[];
  imgs:=List(ng,i->[]);;
  ran:=[1..Length(pcgs)];
  zer:=ListWithIdenticalEntries(Length(pco)-Length(pcgs),0);
  for i in pco do
    Add(gens,i);
    a:=PcElementByExponentsNC(pcgs,ExponentsOfPcElement(pco,i){ran});
    for j in [1..Length(ng)] do
      e:=ExponentsOfPcElement(pcgs,a^ng[j]);
      Append(e,zer);
      Add(imgs[j],PcElementByExponentsNC(pco,e));
    od;
  od;

  # now we add new relators: x^g=x for all central x
  rels:=TrivialSubgroup(cov);
  for j in [1..Length(ng)] do
    # extend homomorphically
    rels:=ClosureGroup(rels,CommutGenImgs(pco,gens,imgs[j],mul));
  od;

  if Size(rels)=Size(mul) then
    # total vanish
    return InverseGeneralMapping(IsomorphismPcGroup(s));
  fi;

  # form the quotient, make it the new cover and the new multiplicator.
  hom:=NaturalHomomorphismByNormalSubgroupNC(cov,rels);
  mul:=Image(hom,mul);
  cov:=Image(hom,cov);
  pco:=List(pco{[1..Length(pcgs)]},i->Image(hom,i));
  Append(pco,Pcgs(mul));
  pco:=PcgsByPcSequenceNC(FamilyObj(One(cov)),pco);
  epi:=GroupHomomorphismByImagesNC(cov,s,pco,
         Concatenation(pcgs,List(Pcgs(mul),i->One(s))));
  SetKernelOfMultiplicativeGeneralMapping(epi,mul);

  # now extend to the full group
  rels:=TrivialSubgroup(cov);
  dc:=List(DoubleCosetRepsAndSizes(g,n,n),i->i[1]);
  i:=1;
  while i<=Length(dc) and Index(mul,rels)>1 do
    if Order(dc[i])>1 then # the trivial element will not do anything
      q:=Intersection(s,ConjugateSubgroup(s,dc[i]^-1));
      if Size(q)>1 then
        qs:=PreImage(epi,q);
        # factor generators
        gens:=GeneratorsOfGroup(qs);
        # their conjugates
        imgs:=List(gens,j->PreImagesRepresentative(epi,Image(epi,j)^dc[i]));
        rels:=ClosureGroup(rels,CommutGenImgs(pco,gens,imgs,
                            Intersection(mul,DerivedSubgroup(qs))));
      fi;
    fi;
    i:=i+1;
  od;
  hom:=NaturalHomomorphismByNormalSubgroupNC(cov,rels);
  mul:=Image(hom,mul);
  cov:=Image(hom,cov);
  pco:=List(pco{[1..Length(pcgs)]},i->Image(hom,i));
  Append(pco,Pcgs(mul));
  pco:=PcgsByPcSequenceNC(FamilyObj(One(cov)),pco);
  epi:=GroupHomomorphismByImagesNC(cov,s,pco,
         Concatenation(pcgs,List(Pcgs(mul),i->One(s))));
  SetKernelOfMultiplicativeGeneralMapping(epi,mul);
  return epi;

end);

InstallMethod(AbelianInvariantsMultiplier,"naive",true,
  [IsGroup],1, G->AbelianInvariants(KernelOfMultiplicativeGeneralMapping(EpimorphismSchurCover(G))));

InstallMethod(AbelianInvariantsMultiplier,"via Sylow Subgroups",true,
  [IsGroup],0,
function(G)
local a,f,i;
  Info(InfoWarning,1,"Warning: AbelianInvariantsMultiplier via Sylow subgroups is under construction");
  a:=[];
  f:=Filtered(Collected(Factors(Size(G))),i->i[2]>1);
  for i in f do
    Append(a,AbelianInvariants(KernelOfMultiplicativeGeneralMapping(
               SchuMu(G,i[1]))));
  od;
  return a;
end);

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

InstallGlobalFunction(CorestEval,function(FG,s)
# This has plenty of space for optimization.
local G,H,D,T,i,j,k,l,a,h,nk,evals,rels,gens,r,np,g,invlist,el,elp,TL,rp,pos;

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

  # deal with inverses
  invlist:=[];
  for g in gens do
    h:=One(D);
    for k in T do
      np:=k*g;
      nk:=TL[PositionCanonical(T,np)];
      h:= h*elp[Position(el,np/nk)]*elp[Position(el,nk/g/k)];;
    od;
    Add(invlist,h);
  od;

  evals:=[];

  for rp in [1..Length(rels)] do

    CompletionBar(InfoSchur,2,"Relator Loop: ",rp/Length(rels));
    r:=rels[rp];
    i:=LetterRepAssocWord(r);
    a:=One(D);

    # take care of inverses
    for l in [1..Length(i)] do
      if i[l]<0 then
        #i[l]:=-i[l];
        a:=a*invlist[-i[l]];
      fi;
    od;

    for j in [1..Length(T)] do

      k:=T[j];
      h:=One(D);
      for l in i do
        if l<0 then
          g:=Inverse(gens[-l]);
        else
          g:=gens[l];
        fi;
        np:=k*g;
        nk:=TL[PositionCanonical(T,np)];
        #h:=h*PreImagesRepresentative(s,np/nk);
        h:=h*elp[Position(el,np/nk)];
        k:=nk;
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
      Add(sl,SchuMu(G,p));
      ab:=AbelianInvariants(KernelOfMultiplicativeGeneralMapping(s));
      ms:=ms*Product(ab);
      Add(ngl,ngl[Length(ngl)]+Length(ab));
    fi;
  od;
  Info(InfoSchur,1,"Relevant primes:",pll);
  Info(InfoSchur,1,"Multiplicator size:",ms);
  if Length(pll)=0 then
    return IdentityMapping(G);
  fi;

  #F:=FreeGroup(List([1..ngl[Length(ngl)]],x->Concatenation("@",String(x))));
  F:=FreeGroup(ngl[Length(ngl)]);

  rels:=[];
  rel2:=[];
  for pp in [1..Length(pll)] do
    p:=pll[pp];
    Info(InfoSchur,2,"Cohomology for prime :",p);
    s:=sl[pp];
    mg:=IsomorphismPermGroup(KernelOfMultiplicativeGeneralMapping(s));
    mg:=List(IndependentGeneratorsOfAbelianGroup(Image(mg)),
          i->PreImagesRepresentative(mg,i));
    sdc:=ListWithIdenticalEntries(ngl[Length(ngl)],One(Source(s)));
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
  if AssertionLevel()>0 then
    if Size(q)<>Size(G)*ms then
      Error("oops!");
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

BindGlobal( "DoMulExt", function(arg)
local G,pl;
  G:=arg[1];
  if not IsFinite(G) then
    Error("cover is only defined for finite groups");
  elif IsTrivial(G) then
    return IdentityMapping(G);
  fi;
  Info(InfoWarning,1,"Warning: EpimorphismSchurCover via Holt's algorithm is under construction");
  if Length(arg)>1 then
    pl:=arg[2];
  else
    pl:=PrimeDivisors(Size(G));
  fi;
  return MulExt(G,pl);
end );

InstallMethod(EpimorphismSchurCover,"Holt's algorithm",true,[IsGroup],0,
 DoMulExt);

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
##  Dertermines if $G$ is a central factor of some group $H$ or not.
##
InstallMethod(IsCentralFactor, "Naive method", true, [IsGroup], 0,
    G -> IsTrivial(Epicentre(G)));
