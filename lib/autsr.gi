#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke, Soley Jonsdottir.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  contains an implementation of the Cannon/Holt automorphism
##  group algorithm:
##    Automorphism group computation and isomorphism testing in finite groups.
##    J. Symb. Comput. 35, No. 3, 241-267 (2003)

# call as big,perm,aut (the latter two can be groups or generator lists,
# optional permiso.
# returns two groups with corresponding generators
BindGlobal( "AGSRReducedGens", function(arg)
local big,bp,A,permgens,s,auts,sel,i,sub;
  big:=arg[1];
  bp:=arg[2];
  A:=arg[3];

  if IsGroup(bp) then
    permgens:=GeneratorsOfGroup(bp);
  else
    permgens:=bp;
    bp:=SubgroupNC(Parent(big),permgens);
  fi;
  SetSize(bp,Size(big));
  if IsGroup(A) then
    auts:=GeneratorsOfGroup(A);
  else
    auts:=A;
    A:=fail;
  fi;
  if Length(permgens)<>Length(auts) then Error("correspondence!");fi;
  s:=SmallGeneratingSet(big);
  if Length(s)+2>=Length(permgens) then
    return fail;
  fi;

  # first try to reduce by dropping generators
  sel:=[1..Length(permgens)];
  for i in [1..Length(permgens)] do
    sub:=SubgroupNC(Parent(big),permgens{Difference(sel,[i])});
    if Size(sub)=Size(big) then
      RemoveSet(sel,i);
      bp:=sub;
    fi;
  od;
  # good enough?
  if Length(s)+2<Length(sel) then
    if Length(arg)>3 then
      i:=InverseGeneralMapping(arg[4]);
    else
      i:=GroupHomomorphismByImagesNC(big,Group(auts),permgens,auts);
    fi;
    auts:=List(s,x->ImagesRepresentative(i,x));
    bp:=SubgroupNC(Parent(big),s);
    SetSize(bp,Size(big));
    auts:=Group(auts);
  else
    auts:=Group(auts{sel});
  fi;
  SetIsGroupOfAutomorphismsFiniteGroup(auts,true);
  SetIsFinite(auts,true);
  SetSize(auts,Size(bp));
  if A<>fail then
    if HasInnerAutomorphismsAutomorphismGroup(A) then
      SetInnerAutomorphismsAutomorphismGroup(auts,
        InnerAutomorphismsAutomorphismGroup(A));
    fi;
    if HasNiceMonomorphism(A) then
      SetNiceMonomorphism(auts,NiceMonomorphism(A));
      SetNiceObject(auts,NiceObject(A));
    fi;
  fi;
  return [bp,auts];
end );

# If M<=Frat(C_G(M)), try to find relators for C/M that in G evaluate to
# generators of M and for which exponent sums are multiples of p. In this
# case the values of the relators on pre-images in G do not depend on choice
# of representatives and can be used to deduce the module automorphism
# belonging to a factor group automorphism.
BindGlobal("AGSRFindRels",function(nat,newgens)
local C,M,p,all,gens,sub,q,hom,fp,rels,new,pre,i,free,cnt;
  M:=KernelOfMultiplicativeGeneralMapping(nat);
  C:=Centralizer(Source(nat),M);
  if not IsSubset(FrattiniSubgroup(C),M) then
    return fail;
  fi;
  p:=SmallestPrimeDivisor(Size(M));
  all:=[];
  if newgens=true then
    # so generators new
    sub:=TrivialSubgroup(Image(nat));
    while Size(sub)<Size(Image(nat)) do
      sub:=ClosureGroup(sub,ImagesRepresentative(nat,Random(C)));
    od;
  else
    sub:=Image(nat,C);
  fi;

  gens:=SmallGeneratingSet(sub);

  free:=FreeGroup(Length(gens));
  sub:=TrivialSubgroup(M);
  cnt:=0;
  while Size(sub)<Size(M) do
    q:=Group(gens);
    SetSize(q,Size(Image(nat,C)));
    # use `ByGenerators` to force more random relators
    hom:=IsomorphismFpGroupByGenerators(q,gens);
    fp:=Range(hom);
    rels:=Filtered(RelatorsOfFpGroup(fp),x->ForAll(ExponentSums(x),x->x mod p=0));
    rels:=List(rels,x->ElementOfFpGroup(FamilyObj(One(fp)),x));
    new:=RestrictedMapping(nat,C)*hom;
    pre:=List(rels,x->PreImagesRepresentative(new,x));
    for i in [1..Length(rels)] do
      if not pre[i] in sub then
        Add(all,MappedWord(rels[i],
          GeneratorsOfGroup(fp),GeneratorsOfGroup(free)));
        sub:=ClosureGroup(sub,pre[i]);
      fi;
    od;
    cnt:=cnt+1;
    if cnt>5 then return fail;fi;
  od;
  return rec(gens:=gens,free:=free,rels:=all);
end);

BindGlobal("AGSRPrepareAutomLift",function(G,pcgs,nat)
local ocr,fphom,fpg,free,len,dim,tmp,L0,R,rels,mat,r,RS,i,g,v,cnt;

  ocr:=rec(group:=G,modulePcgs:=pcgs);
  fphom:=IsomorphismFpGroup(G);
  ocr.identity := One(ocr.modulePcgs[1]);
  fpg:=FreeGeneratorsOfFpGroup(Range(fphom));
  ocr.factorpres:=[fpg,RelatorsOfFpGroup(Range(fphom))];
  ocr.generators:=List(GeneratorsOfGroup(Range(fphom)),
                        i->PreImagesRepresentative(fphom,i));
  OCAddMatrices(ocr,ocr.generators);
  OCAddRelations(ocr,ocr.generators);
  OCAddSumMatrices(ocr,ocr.generators);
  OCAddToFunctions(ocr);

  ocr.module:=GModuleByMats(
    LinearActionLayer(G,ocr.generators,ocr.modulePcgs),ocr.field);
  ocr.moduleauts:=MTX.ModuleAutomorphisms(ocr.module);

  if Size(ocr.moduleauts)>
      # Finding the relations comes at a cost that needs to be plausible
      # with searching multiple times through the automorphism group. This
      # order bound is a heuristic that seems to be OK by magnitude.
      100
    then
    cnt:=0;
    repeat
      ocr.trickrels:=AGSRFindRels(nat,cnt>3);
      cnt:=cnt+1;
    until ocr.trickrels<>fail or 2^cnt>100*Size(ocr.moduleauts);
  if ocr.trickrels=fail then Info(InfoMorph,1,"trickrels fails");fi;
  else
    ocr.trickrels:=fail;
  fi;

  ocr.factorgens:=List(ocr.generators,i->Image(nat,i));
  free:=FreeGroup(Length(ocr.generators),"f");
  ocr.free:=free;
  ocr.decomp:=GroupGeneralMappingByImages(Image(nat,G),free,
        ocr.factorgens,GeneratorsOfGroup(free));

  # Initialize system.
  len:=Length(ocr.generators);
  dim:=Length(pcgs);
  tmp := ocr.moduleMap( ocr.identity );
  L0  := Concatenation( List( [ 1 .. len ], x -> tmp ) );
  ConvertToVectorRep(L0,ocr.field);
  R := ListWithIdenticalEntries( len * dim,Zero( ocr.field ) );
  ConvertToVectorRep(R,ocr.field);

  rels:=ocr.relators;
  mat:=List([1..len*dim],x->[]);
  for i in mat do
    ConvertToVectorRep(i,ocr.field);
  od;
  for i in [1..Length(rels)] do
    Info(InfoCoh,2,"  relation ", i, " (",Length(rels),")");
    r:=1;
    for g  in [1..len]  do
      RS:=OCEquationMatrix(ocr,rels[i],g);
      for v in RS do
        Append(mat[r],v);
        r:=r+1;
      od;
    od;
  od;
  ocr.matrix:=ImmutableMatrix(ocr.field,mat);
  ocr.semiech:=ShallowCopy(SemiEchelonMatTransformation(ocr.matrix));
  ocr.semiech.numrows:=NrRows(ocr.matrix);
  return ocr;
end);

# solve using the stored LR decomposition
BindGlobal("AGSRSolMat",function(sem,vec)
local i,vno,x,z,sol;
  z := ZeroOfBaseDomain(sem.vectors);
  sol := ListWithIdenticalEntries(sem.numrows,z);
  ConvertToVectorRepNC(sol);
  for i in [1..Length(vec)] do
    vno := sem.heads[i];
    if vno <> 0 then
      x := vec[i];
      if x <> z then
        AddRowVector(vec, sem.vectors[vno], -x);
        AddRowVector(sol, sem.coeffs[vno], x);
      fi;
    fi;
  od;
  if IsZero(vec) then
    return sol;
  else
    return fail;
  fi;
end);

#############################################################################
##
#F  OCEquationVectorAutom(<ocr>,<r>,<genimages>)
##
BindGlobal("OCEquationVectorAutom",function(ocr,r,genimages)
local n,i;

  # If <r> has   an entry 'conjugated'   the records is  no relator  for  a
  # presentation,but belongs to relation
  #       (g_i n_i) ^ s_j =<r>
  # which is  used to determinate  normal  complements.   [i,j] is bound to
  # <conjugated>.
  if IsBound(r.conjugated)  then
    Error("not yet implemented");
  fi;
  n:=ocr.identity;

  for i in [1 .. Length(r.generators)] do
    n:=n*genimages[r.generators[i]]^r.powers[i];
  od;

  Assert(1,n in GroupByGenerators(NumeratorOfModuloPcgs(ocr.modulePcgs)));

  return ShallowCopy(ocr.moduleMap(n));

end);

BindGlobal("AGSRAutomLift",function(ocr,nat,fhom,miso)
  local v, rels, genimages, v1, psim, w, s, t, l, hom, i, e, j,ep,phom,enum;

  v:=[];
  rels:=ocr.relators;
  genimages:=List(ocr.factorgens,i->MappedWord(
                ImagesRepresentative(ocr.decomp,Image(fhom,i)),
                GeneratorsOfGroup(ocr.free),
                ocr.generators));
  for i in [1..Length(rels)] do
    v1:=OCEquationVectorAutom(ocr,rels[i],genimages);
    Add(v,v1);
  od;

  #for ep in Enumerator(ocr.moduleauts) do
  if ocr.trickrels<>fail then
    # special case for M<=Frat(C_G(M)). Use special relators for factor that
    # allow to deduce corresponding module aut.
    t:=ocr.trickrels;
    phom:=IdentityMapping(ocr.moduleauts);
    s:=List(t.gens,x->PreImagesRepresentative(nat,x));
    l:=List(t.gens,x->PreImagesRepresentative(nat,ImagesRepresentative(fhom,x)));
    s:=List(t.rels,x->MappedWord(x,GeneratorsOfGroup(t.free),s));
    l:=List(t.rels,x->MappedWord(x,GeneratorsOfGroup(t.free),l));

    s:=List(s,x->ExponentsOfPcElement(ocr.modulePcgs,x))*One(ocr.field);
    l:=List(l,x->ExponentsOfPcElement(ocr.modulePcgs,x))*One(ocr.field);
    Info(InfoMorph,5,"Deduced corresponding module automorphism");
    if RankMat(l)<Length(l) then
      return fail;
    fi;
    enum:=[s^-1*l];

  else
    phom:=IsomorphismPermGroup(ocr.moduleauts);
    enum:=Enumerator(Image(phom,ocr.moduleauts));
    Info(InfoMorph,5,"Search through module automorphisms of size ",
      Size(Image(phom)));
  fi;
  for ep in enum do
    e:=PreImagesRepresentative(phom,ep);
    psim:=e*miso;
    psim:=psim^-1;
    w:=-List(v,i->i*psim);
    #s:=SolutionMat(ocr.matrix,Concatenation(w));
    s:=AGSRSolMat(ocr.semiech,Concatenation(w));
    if s<>fail then
      psim:=psim^-1;
      t:=[];
      ConvertToVectorRep(t,ocr.field);
      l:=Length(ocr.modulePcgs);
      for i in [1..Length(genimages)] do
        v1:=s{[(i-1)*l+1..(i*l)]}*psim;
          for j in [1..Length(v1)] do
            t[(i-1)*l+j]:=v1[j];
          od;
      od;
      s:=ocr.cocycleToList(t);
      for i in [1..Length(genimages)] do
        genimages[i]:=genimages[i]*s[i];
      od;

      # later use NC version
      hom:=GroupHomomorphismByImagesNC(ocr.group,ocr.group,
              ocr.generators,genimages);
      Assert(2,IsBijective(hom));
      return hom;
    fi;
  od;
  return fail;

end);


# Find a larger subgroup that satisfies a condition, when testing
# the condition can become expensive.
# First try `SubgroupProperty`, but when it stalls attempt to find
# minimal supergroups and prove that none of them satisfies.
BindGlobal("SubgroupConditionAboveAux",function(G,cond,S1,avoid)
local S,c,hom,q,a,b,i,t,have,ups,new,u,good,abort,clim,worked,pp,
  cnt,locond,tstcnt,setupc,havetest;

  setupc:=function()
    hom:=NaturalHomomorphismByNormalSubgroupNC(G,u);
    q:=Image(hom,G);
    ups:=Image(hom,avoid);
    # aim for zuppos that cannot intersect avoid
    c:=ConjugacyClasses(q);
    c:=Filtered(c,x->IsPrimePowerInt(Order(Representative(x))) and
      not Representative(x) in ups);
    # elements that do not have prime-order power in the subgroup avoid
    c:=Filtered(c,x->not Representative(x)^
      (Order(Representative(x))/SmallestPrimeDivisor(Order(Representative(x))))
      in ups);
    # this also implies prime powers after the respective primes
    SortBy(c,Size);

    Info(InfoMorph,3,Length(c)," classes with ",Sum(c,Size)," subgroups");
  end;

  S:=S1;
  Info(InfoMorph,2,"SubgroupAbove ",IndexNC(G,S));

  # Strategy: First try `SubgroupProperty` with a bailout limit, just in
  # case it finds (enough) elements. The bailout limit is set smaller if the
  # factor is solvable, as it will be cheaper to find complementing zuppos
  # in this case.

  u:=Intersection(S,avoid);
  if IsNormal(G,u) and IsNormal(G,avoid)
    and HasSolvableFactorGroup(G,u) then
    setupc();
    clim:=Minimum(Maximum(QuoInt(Sum(c,Size),4),10),1000);
  else
    hom:=fail;
    # if less than 1/100 percent of elements succeed, assume close
    # to the subgroup has been found, and rather aim to prove there
    # will not be more.
    c:=fail;
    clim:=Maximum(QuoInt(IndexNC(G,S),10000),1000);
  fi;




  # first try, how far `SubgroupProperty` goes
  b:=0;
  tstcnt:=0;
  abort:=false;
  havetest:=[];

  if IsPermGroup(G) then
    worked:=SubgroupProperty(G,
      function(elm)
        if abort then
          return true; # are we bailing out since it behaves too badly?
        fi;
        # would it contribute to avoid outside S?
        if elm in avoid or
          ForAny(Set(Factors(Order(elm))),e->elm^e in avoid and not elm^e in S)
        then
          # cannot be good
          return false;
        fi;

        tstcnt:=tstcnt+1;
        AddSet(havetest,elm);
        if cond(elm) then
          S:=ClosureGroup(S,elm); # remember
          Info(InfoMorph,3,"New element ",IndexNC(G,S));
          b:=0;
          return true;
        else
          b:=b+1;
          if b>clim then
            abort:=true;
          fi;
          return false;
        fi;
      end,S);
  else
    worked:=S;
    abort:=true;
  fi;

  if abort=false then
    # we actually found the subgroup
    Info(InfoMorph,2,"SubgroupProperty finds index ",IndexNC(G,worked));
    return worked;
  fi;

  Info(InfoMorph,2,"SubgroupProperty did ",tstcnt," tests and improved by ",
    IndexNC(S,S1));

  if not (IsNormal(G,u) and IsNormal(G,avoid)) then
    Error("may only call if normalizing");
  fi;

  if c=fail then setupc();fi;
  havetest:=Set(List(havetest,x->ImagesRepresentative(hom,x)));

  locond:=function(elm)
            tstcnt:=tstcnt+1;
            return cond(elm);
          end;

  clim:=
    # avoid writing down a permutation representation on more than
    150000;
    #cosets, as it gets too memory expensive.


  worked:=[]; # indicate whether class worked


  # now run over all Zuppos (Conjugates of class representatives) in factor  that do
  # not intersect (the image of) avoid. These, that saisfy, will span the correct subgroup.
  i:=1;
  while worked<>fail and i<=Length(c) do

    #should we abort?
    if Sum(c{[i..Length(c)]},Size)>IndexNC(G,S) and IndexNC(G,S)<=clim then
      a:=Normalizer(G,S);
      # if the normalizer index is large, there will be many subgroups above
      if IndexNC(a,S)<200 then
        worked:=fail; # abort and go to other method
      fi;
    fi;

    # if prime powers, the primes must have worked
    a:=Representative(c[i]);

    # no coprime power in earlier class?
    have:=worked<>fail and
      ForAll(Filtered([2..Order(a)-1],o->Gcd(o,Order(a))=1),
        o->PositionProperty(c{[1..i-1]},x->a^o in x)=fail);

    pp:=false;
    if have and not IsPrimeInt(Order(a)) then
      pp:=SmallestPrimeDivisor(Order(a));
      a:=a^(Order(a)/pp);
      have:=worked[PositionProperty(c,x->a in x)];
    fi;

    if have then
      have:=false;
      a:=Representative(c[i]);
      t:=Orbit(q,a);
      t:=Filtered(t,x->not x in havetest);

      cnt:=0;
      for b in t do
        new:=PreImagesRepresentative(hom,b);
        if (pp=false or new^pp in S) and locond(new) then
          S:=ClosureGroup(S,new);
          have:=true;
          cnt:=cnt+1;
        fi;
      od;
      Info(InfoMorph,4,"Did class ",i," order =",Order(Representative(c[i])),
            ", len=",Size(c[i])," newtest=", Length(t),
            " found ",cnt,": ",Size(S));
    fi;
    if worked<>fail then Add(worked,have);fi;
    i:=i+1;
  od;

  if worked=fail then
    # still need to test
    Info(InfoMorph,2,"Go to blocks test");

    if Index(G,S)>clim then Error("clim"); fi;

    a:=SmallGeneratingSet(G);
    if Length(GeneratorsOfGroup(G))>Length(a) then
      b:=Size(G);
      G:=Group(a);
      SetSize(G,b);
    fi;

    repeat
      good:=false;
      u:=Filtered(GeneratorsOfGroup(G),x->cond(x) and not x in S);
      for i in u do
        S:=ClosureGroup(S,i);
      od;

      # try to prove no supergroup works
      t:=RightTransversal(G,S:noascendingchain); # don't try to be clever in
      # decomposing transversal, as this could be hard
      a:=Action(G,t,OnRight); # coset action, don't need homomorphism
      b:=RepresentativesMinimalBlocks(a,MovedPoints(a));
      Info(InfoMorph,3,"Above are ",Length(b)," blocks");

      if IsPermGroup(G) and Length(b)*10>IndexNC(G,S) then
        # there are too many blocks. Direct test is cheaper!
        S:=SubgroupProperty(G,locond,S);
      else

        for i in [1..Length(b)] do
          CompletionBar(InfoMorph,3,"SubgroupsAboveBlocks ",i/Length(b));
          c:=First(b[i],x->x>1);
          if cond(t[c]) then
            S:=ClosureGroup(S,t[c]);
            good:=true;
          fi;
        od;
        CompletionBar(InfoMorph,3,"SubgroupsAboveBlocks ",false);
      fi;
    until good=false;

  fi;

  Info(InfoMorph,3,"Did ",tstcnt," tests, grow by ",Index(S,S1));
  return S;

end);

# Same syntax as `SubgroupProperty`, but assumption that the tests are
# expensive. Thus minimize number of tests by doing more group calculations
InstallGlobalFunction(SubgroupConditionAbove,function(G,cond,Sorig)
local cs,nr,u,no,un,S,rad,res,ise,uno;


  # first, try to find a few elements that work (and catch the case that the
  # subgroup has small index. Ensure we test at least once for each possible
  # step.
  nr:=2^LogInt(Size(G),1000)+Length(Factors(Size(G)));
  u:=[];
  if IsPermGroup(G) then
    S:=SubgroupProperty(G,
      function(elm)
        if nr<0 then return true;fi;
        nr:=nr-1;
        if cond(elm) then
          Add(u,elm);
          return true;
        else
          return false;
        fi;
      end,Sorig);
  else
    u:=Filtered(GeneratorsOfGroup(G),cond);
    nr:=-1;
  fi;

  if nr>=0 then # succeeded (small index case)
    return S;
  elif Length(u)>0 then
    S:=ClosureGroup(Sorig,u);
  else
    S:=Sorig;
  fi;

  # now build along composition series

  rad:=SolvableRadical(G);
  # composition series through perfect residuum seems to work better
  # Possible reason: Simple composition factors arise as inner
  # automorphisms. Moving the perfect residuum (if smaller) in the series,
  # thus increases the chance that much of the subgroup is found early (and
  # does not need to be found through search through complements)
  res:=PerfectResiduum(G);

  nr:=[Core(G,S),NormalClosure(G,S)];
  if Size(nr[1])=Size(nr[2]) then nr:=nr{[1]};fi;

  # refine with perfect residuum
  no:=Intersection(nr[1],res);
  if not no in nr then nr:=Concatenation([no],nr);fi;
  if Length(nr)>1 then
    no:=ClosureGroup(nr[Length(nr)],res);
    if not no in nr then Add(nr,no);fi;
  fi;

  cs:=CompositionSeriesThrough(G,nr);

  nr:=First([1..Length(cs)],x->IsSubset(S,cs[x]));
  uno:=false;
  while nr>1 do
    nr:=nr-1;
    if IsSubset(cs[nr+1],S) then

      u:=S;
      ise:=u;
      if uno=false then
        # if the group is huge use the radical-based normalizer
        if Size(rad)>10^13 and IndexNC(G,ise)>10^5 then
          Info(InfoMorph,4,"Radical-based Normalizer:",IndexNC(G,u));
          uno:=NormalizerViaRadical(G,ise);
        else
          Info(InfoMorph,4,"Ordinary Normalizer:",IndexNC(G,u));
          uno:=Normalizer(G,ise);
        fi;
      fi;
      no:=Intersection(uno,cs[nr]);
    else

      u:=Intersection(cs[nr],S);
      ise:=Intersection(cs[nr+1],u);

      # if the group is huge use the radical-based normalizer
      if Size(Intersection(rad,cs[nr]))>10^13 and IndexNC(cs[nr],ise)>10^5 then
        Info(InfoMorph,4,"Radical-based Normalizer:",IndexNC(cs[nr],ise),
          " of ",Index(cs[nr],cs[nr+1]));
        no:=NormalizerViaRadical(cs[nr],ise);
      else
        Info(InfoMorph,4,"Ordinary Normalizer:",IndexNC(cs[nr],ise),
          " of ",Index(cs[nr],cs[nr+1]));
        no:=Normalizer(cs[nr],ise);
      fi;
    fi;

    un:=Size(no);
    no:=Group(SmallGeneratingSet(no));
    SetSize(no,un);

    un:=SubgroupConditionAboveAux(no,cond,u,Intersection(no,cs[nr+1]));
    Info(InfoMorph,2,
      "Step ",nr,": ",IndexNC(cs[nr],cs[nr+1])," to ",IndexNC(un,u));
    if not IsSubset(S,un) then
      S:=ClosureGroup(S,un);
      uno:=false;
    fi;
  od;
  return S;
end);

# find classes of normal subgroups
BindGlobal("AGSRNormalSubgroupClasses",function(G)
local fp,n,pat,pools,i,sel;
  # fingerprint
  fp:=function(x)
  local l;
    if ID_AVAILABLE(Size(x)) <> fail
      and ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
      return IdGroup(x);
    fi;
    l:=[Size(x)];
    Add(l,Collected(List(ConjugacyClasses(x),
      y->[Order(Representative(y)),Size(y)])));
    Add(l,AbelianInvariants(x));
    return l;
  end;
  n:=ValueOption("directs");
  if n<>fail then
    # avoid large number of normals in direct product
    n:=Concatenation(List(n,
      x->Filtered(NormalSubgroups(x),y->Size(y)>1 and Size(y)<Size(x))));
  else
    n:=NormalSubgroups(G);
  fi;
  pat:=List(n,fp);
  pools:=[];
  for i in Set(pat) do
    sel:=Filtered([1..Length(n)],x->pat[x]=i);
    Add(pools,n{sel});
  od;
  return pools;
end);

# form a characterististic series through radical with elab factors
BindGlobal("AGSRCharacteristicSeries",function(G,r)
local somechar,d,i,j,u,v;
  d:=Filtered(StructuralSeriesOfGroup(G),x->IsSubset(r,x));
  # refine
  d:=RefinedSubnormalSeries(d,Centre(G));
  d:=RefinedSubnormalSeries(d,Centre(r));
  somechar:=ValueOption("someCharacteristics");
  if somechar<>fail then
    if IsRecord(somechar) then
      somechar:=somechar.subgroups;
    fi;
    for i in somechar do
      d:=RefinedSubnormalSeries(d,i);
    od;
  fi;

  if not ForAll([1..Length(d)-1],
    x->HasElementaryAbelianFactorGroup(d[x],d[x+1])) then
    for i in PrimeDivisors(Size(r)) do
      u:=PCore(r,i);
      if Size(u)>1 then
        d:=RefinedSubnormalSeries(d,u);
        j:=1;
        repeat
          v:=Agemo(u,i,j);
          if Size(v)>1 then
            d:=RefinedSubnormalSeries(d,v);
          fi;
          j:=j+1;
        until Size(v)=1;
        j:=1;
        repeat
          if Size(u)>=2^24 then
            v:=u; # bail out as method for `Omega` will do so.
          else
            v:=Omega(u,i,j);
            if Size(v)<Size(u) then
              d:=RefinedSubnormalSeries(d,v);
            fi;
            j:=j+1;
          fi;

      until Size(v)=Size(u);
    fi;
    od;
  fi;
  Assert(1,ForAll([1..Length(d)-1],x->Size(d[x])<>Size(d[x+1])));
  return d;
end);

# main automorphism method -- currently still using factor groups, but
# nevertheless faster..

# option somechar may be a list of characteristic subgroups, or a record with
# component subgroups, orbits
BindGlobal("AutomGrpSR",function(G)
local ff,r,d,ser,u,v,i,j,k,p,bd,e,gens,lhom,M,N,hom,Q,Mim,q,ocr,split,MPcgs,
      b,fratsim,AQ,OQ,Zm,D,innC,oneC,imgs,C,maut,innB,tmpAut,imM,a,A,B,
      cond,sub,AQI,AQP,AQiso,rf,res,resperm,proj,Aperm,Apa,precond,ac,
      comiso,extra,mo,rada,makeaqiso,ind,lastperm,actbase,somechar,stablim,
      scharorb,asAutom,jorb,jorpo,substb,isBadPermrep,ma,nosucl,nosuf,rlgf;

  # criterion for when to force degree reduction
  isBadPermrep:=function(g)
    return NrMovedPoints(g)^3>Size(g)*Index(g,DerivedSubgroup(g));
  end;

  asAutom:=function(sub,hom) return Image(hom,sub);end;

  actbase:=ValueOption("autactbase");
  nosucl:=fail;

  makeaqiso:=function()
  local a,b;
    Info(InfoMorph,3,"enter makeaqiso");
    if HasIsomorphismPermGroup(AQ) then
      AQiso:=IsomorphismPermGroup(AQ);
    elif HasNiceMonomorphism(AQ) and IsPermGroup(Range(NiceMonomorphism(AQ))) then
      AQiso:=NiceMonomorphism(AQ:autactbase:=fail);
    else
      a:=Filtered(GeneratorsOfGroup(AQ),HasConjugatorOfConjugatorIsomorphism);
      if Length(a)>2 then
        a:=List(a,ConjugatorOfConjugatorIsomorphism);
        b:=SmallGeneratingSet(Group(a));
        if Length(b)<Length(a) then
          a:=List(b,x->ConjugatorAutomorphism(Source(AQ.1),x));
          b:=Filtered(GeneratorsOfGroup(AQ),x->not HasConjugatorOfConjugatorIsomorphism(x));
          a:=Concatenation(a,b);
          b:=InnerAutomorphismsAutomorphismGroup(AQ);
          AQ:=Group(a,One(AQ));
          SetInnerAutomorphismsAutomorphismGroup(AQ,b);
          SetIsGroupOfAutomorphismsFiniteGroup(AQ,true);
        fi;
      fi;
      if actbase<>fail then
        AQiso:=IsomorphismPermGroup(AQ:autactbase:=List(actbase,x->Image(hom,x)));
      else
        AQiso:=IsomorphismPermGroup(AQ);
      fi;
    fi;
    AQP:=Image(AQiso,AQ);
    Info(InfoMorph,3,"Permrep of AQ ",Size(AQ),", deg:",NrMovedPoints(AQP));

    if Length(GeneratorsOfGroup(AQP))=Length(GeneratorsOfGroup(AQ)) then
      a:=AGSRReducedGens(AQP,AQP,AQ,AQiso);
      if a<>fail then
        AQP:=a[1];
        AQ:=a[2];
      fi;
    fi;

    # force degree down
    if isBadPermrep(AQP) then
      a:=SmallerDegreePermutationRepresentation(AQP:cheap);
      if NrMovedPoints(Image(a))<NrMovedPoints(AQP) then
        Info(InfoMorph,3,"Permdegree reduced ",
              NrMovedPoints(AQP),"->",NrMovedPoints(Image(a)));
        AQiso:=AQiso*a;
        b:=Image(a,AQP);
        if Length(GeneratorsOfGroup(b))>Length(GeneratorsOfGroup(AQP)) then
          b:=Group(List(GeneratorsOfGroup(AQP),x->ImagesRepresentative(a,x)));
          SetSize(b,Size(AQP));
        fi;
        AQP:=b;
      fi;
    fi;

  end;

  stablim:=function(gp,cond,lim)
  local no,same,sz,ac,i,sub;
    same:=true;
    repeat
      sz:=Size(Aperm);
      if Size(gp)/Size(Aperm)>lim then
        no:=Normalizer(gp,Aperm);
        if Size(no)>Size(Aperm) and Size(no)<Size(gp) then
          stablim(no,cond,lim);
        fi;
      else
        no:=Aperm;
      fi;
      if Size(gp)/Size(Aperm)>lim then
        ac:=AscendingChain(gp,Aperm);
        List(Union(List(ac,GeneratorsOfGroup)),cond); # try generators...
        if Size(Aperm)>sz then
          ac:=Unique(List(ac,x->ClosureGroup(Aperm,x)));
        fi;

        i:=First([Length(ac),Length(ac)-1..1],x->Size(ac[x])/sz<=lim);
        sub:=ac[i];
      else
        sub:=gp;
      fi;
      if Size(sub)>Size(Aperm) and not IsSubset(no,sub) then
        SubgroupProperty(sub,cond,Aperm);
      fi;
      same:=Size(Aperm)=sz;
      if not same then
        Info(InfoMorph,3,"stablim improves by ",Size(Aperm)/sz,
        " remaining ",Size(gp)/Size(Aperm));
      fi;
    until same;
    return sub=gp;
  end;

  ff:=FittingFreeLiftSetup(G);
  r:=ff.radical;
  rlgf:=LGFirst(SpecialPcgs(r));


  # find series through r
  somechar:=ValueOption("someCharacteristics");

  # derived and then primes and then elementary abelian
  d:=ValueOption("series");
  if d=fail then
    d:=AGSRCharacteristicSeries(G,r:someCharacteristics:=somechar);
    d:=Reversed(d);
  else
    d:=ShallowCopy(d);
    SortBy(d,Size); # in case reversed order....
  fi;

  scharorb:=fail;
  if somechar<>fail then
    if IsRecord(somechar) then
      if IsBound(somechar.orbits) then
        scharorb:=somechar.orbits;
      fi;
      somechar:=somechar.subgroups;
    fi;
  fi;

  # now go up in series if elementary abelian to avoid too many tiny steps
  u:=1; # last group in the series to be used
  i:=2;
  while i<Length(d) do
    p:=IndexNC(d[i+1],d[u]);
    # should we skip group i?
    if p<100 and IsPrimePowerInt(p) and
       HasElementaryAbelianFactorGroup(d[i+1],d[u]) then
       d:=Concatenation(d{[1..i-1]},d{[i+1..Length(d)]});
       # i stays the same, as it now is the next subgroup
    else
      u:=i;
      i:=i+1;
    fi;
  od;

  # avoid small central subgroups, as the factor will be hard to represent
  u:=Centre(G);
  if Size(u)>1 then
    p:=SmallestPrimeDivisor(Size(u));
    u:=SylowSubgroup(u,p);
    u:=Omega(u,p,1);
    i:=Position(d,u);
    if i<>fail and i>2 then
      d:=d{Union([1],[i..Length(d)])};
    fi;
  fi;

  ser:=[TrivialSubgroup(G)];
  for i in d{[2..Length(d)]} do
    u:=ser[Length(ser)];
    for p in PrimeDivisors(Size(i)/Size(u)) do
      bd:=PValuation(Size(i)/Size(u),p); # max p-exponent
      u:=ClosureSubgroup(u,SylowSubgroup(i,p));
      v:=ser[Length(ser)];
      while not HasElementaryAbelianFactorGroup(u,v) do
        gens:=Filtered(GeneratorsOfGroup(u),x->not x in v);
        e:=List(gens,x->First([1..bd],a->x^(p^a) in v));
        e:=p^(Maximum(e)-1);
        for j in gens do
          v:=ClosureSubgroup(v,j^e);
        od;
        Add(ser,v);
      od;
      Add(ser,u);
    od;
  od;

  rada:=fail;

  ser:=Reversed(ser);
  hom:=ff.factorhom;
  Q:=Image(hom,G);
  if IsPermGroup(Q) and NrMovedPoints(Q)/Size(Q)*Size(Socle(Q))
        >SufficientlySmallDegreeSimpleGroupOrder(Size(Q)) then
    # just in case the radical factor hom is inherited.
    Q:=SmallerDegreePermutationRepresentation(Q:cheap);
    Info(InfoMorph,3,"Radical factor degree reduced ",NrMovedPoints(Range(hom)),
              " -> ",NrMovedPoints(Range(Q)));
    hom:=hom*Q;
    Q:=Image(hom,G);
  fi;

  ma:=MaximalSubgroupClassesSol(G);

  AQ:=AutomorphismGroupFittingFree(Q:someCharacteristics:=fail);
  AQI:=InnerAutomorphismsAutomorphismGroup(AQ);
  lastperm:=fail;
  # preseed natural homs in ascending form (as the largest one might help
  # for smaller ones)
  for i in [Length(ser),Length(ser)-1..2] do
    lhom:=NaturalHomomorphismByNormalSubgroup(G,ser[i]);
  od;
  i:=1;
  while i<Length(ser) do
    Assert(2,ForAll(GeneratorsOfGroup(AQ),x->Size(Source(x))=Size(Q)));
    # ensure that the step is OK
    lhom:=hom;
    OQ:=Q;
    repeat
      Info(InfoMorph,4,List(ser,Size)," ",i);
      Info(InfoMorph,1,"Step ",i," ",Size(ser[i]),"->",Size(ser[i+1]));
      M:=ser[i];
      N:=ser[i+1];
      hom:=NaturalHomomorphismByNormalSubgroup(G,N);

      Q:=Image(hom,G);
      # degree reduction called for?
      if IsPermGroup(Q) and Size(N)>1
        and (isBadPermrep(Q) or NrMovedPoints(Q)>1000) then
        q:=SmallerDegreePermutationRepresentation(Q:cheap);
        if NrMovedPoints(Q)>1000
          and NrMovedPoints(Q)=NrMovedPoints(Image(q)) then
          q:=SmallerDegreePermutationRepresentation(Q);
        fi;
        if NrMovedPoints(Range(q))<NrMovedPoints(Q) then
          Info(InfoMorph,3,"reduced permrep Q ",NrMovedPoints(Q)," -> ",
              NrMovedPoints(Range(q)));
          hom:=hom*q;
          Q:=Image(hom,G);
        fi;
      fi;

      # inherit radical factor map
      q:=GroupHomomorphismByImagesNC(Q,Range(ff.factorhom),
        List(GeneratorsOfGroup(G),x->ImagesRepresentative(hom,x)),
        List(GeneratorsOfGroup(G),x->ImagesRepresentative(ff.factorhom,x)));
      b:=Image(hom,ff.radical);
      SetSolvableRadical(Q,b);
      AddNaturalHomomorphismsPool(Q,b,q);

      # Use known maximals for Frattini
      for j in ma do
        D:=Image(hom,j);
        if not IsSubset(D,b) then
          b:=Core(Q,NormalIntersection(b,D));
        fi;
      od;
      SetIsNilpotentGroup(b,true);
      SetFrattiniSubgroup(Q,b);

      # M-factor
      Mim:=Image(hom,M);
      MPcgs:=Pcgs(Mim);
      q:=GroupHomomorphismByImagesNC(Q,OQ,
        List(GeneratorsOfGroup(G),x->ImagesRepresentative(hom,x)),
        List(GeneratorsOfGroup(G),x->ImagesRepresentative(lhom,x)));
      AddNaturalHomomorphismsPool(Q,Mim,q);

      mo:=GModuleByMats(LinearActionLayer(GeneratorsOfGroup(Q),MPcgs),GF(RelativeOrders(MPcgs)[1]));
      # is the extension split?
      ocr:=OneCocycles(Q,Mim);
      split:=ocr.isSplitExtension;
      if not split then
        # test: Semisimple and Frattini
        b:=MTX.BasisRadical(mo);
        fratsim:=Length(b)=0;
        if not fratsim then
          b:=List(b,x->PreImagesRepresentative(hom,PcElementByExponents(MPcgs,x)));
          for j in b do
            N:=ClosureSubgroup(N,b);
          od;
          # insert in series
          for j in [Length(ser),Length(ser)-1..i+1] do
            ser[j+1]:=ser[j];
          od;
          ser[i+1]:=N;
          Info(InfoMorph,2,"insert1");
        else
          # Frattini?
          fratsim:=IsSubset(FrattiniSubgroup(Q),Mim);
          if not fratsim then
            N:=Intersection(FrattiniSubgroup(Q),Mim);
            # insert
            for j in [Length(ser),Length(ser)-1..i+1] do
              ser[j+1]:=ser[j];
            od;
            ser[i+1]:=PreImage(hom,N);
            Info(InfoMorph,2,"insert2");
          fi;
          N:=ser[i+1]; # the added normal
        fi;
        if rada<>fail
            and ForAny(GeneratorsOfGroup(rada),x->N<>Image(x,N)) then
          Info(InfoMorph,3,"radical automorphism stabilizer");
          SetIsGroupOfAutomorphismsFiniteGroup(rada,true);
          NiceMonomorphism(rada:autactbase:=fail,someCharacteristics:=fail);
          rada:=Stabilizer(rada,N,asAutom);
        fi;
      fi;
    until split or fratsim;

    # Use cocycles
    b:=BasisVectors(Basis(ocr.oneCocycles));

    # find D
    Zm:=PreImage(q,Centre(OQ));
    D:=Centralizer(Zm,Mim);

    innC:=List(GeneratorsOfGroup(D),d->InnerAutomorphism(Q,d));

    D:=List(innC,inn->List(ocr.generators,o->Image(inn,o)));
    D:=List(D,d->List([1..Length(ocr.generators)],i->ocr.generators[i]^-1*d[i]));
    D:=List(D,d->ocr.listToCocycle(d));
    TriangulizeMat(D);
    D:=Filtered(D,x->x<>0*x);

    b:=BaseSteinitzVectors(b,D).factorspace;

    C:=[];
    if Size(Group(ocr.generators))<Size(Q) then
      extra:=MPcgs;
    else
      extra:=[];
    fi;
    for j  in b  do
      oneC := ocr.cocycleToList( j );
      imgs:=List([1..Length(ocr.generators)],i->ocr.generators[i]*oneC[i]);
      oneC:=GroupHomomorphismByImagesNC(Q,Q,Concatenation(ocr.generators,extra),Concatenation(imgs,extra));
      Assert(2,IsBijective(oneC));
      Add(C,oneC);
    od;

    B:=[];

    if lastperm<>fail then
      AQiso:=lastperm;
      AQP:=Group(List(GeneratorsOfGroup(AQ),x->ImagesRepresentative(AQiso,x)));
    else
      makeaqiso();
    fi;

    if split then
      maut:=MTX.ModuleAutomorphisms(mo);
      # find noninner of B
      innB:=List(SmallGeneratingSet(Zm),z->InnerAutomorphism(Q,z));
      innB:=Group(One(DefaultFieldOfMatrixGroup(maut))*
                      List(innB,inn->List(MPcgs,m->ExponentsOfPcElement(MPcgs,Image(inn,m)))));

      tmpAut:=SubgroupNC(maut,Filtered(GeneratorsOfGroup(maut),aut->not aut in innB));

      gens:=GeneratorsOfGroup(ocr.complement);
      for a  in GeneratorsOfGroup(tmpAut)  do
        imM:=List(a,i->PcElementByExponents(MPcgs,i));
        imM:=GroupHomomorphismByImagesNC(Q,Q,Concatenation(MPcgs,gens),Concatenation(imM,gens));
        Assert(2,IsBijective(imM));
        Add(B,imM);
      od;

      # test condition for lifting, also add corresponding automorphism
      comiso:=GroupHomomorphismByImagesNC(ocr.complement,OQ,gens,List(gens,x->ImagesRepresentative(q,x)));

      precond:=fail;
      mo:=GModuleByMats(LinearActionLayer(gens,MPcgs),mo.field);
      cond:=function(perm)
      local aut,newgens,mo2,iso,a;
        if perm in Aperm then
          return true;
        fi;
        aut:=PreImagesRepresentative(AQiso,perm);
        newgens:=List(gens,x->PreImagesRepresentative(comiso,
          ImagesRepresentative(aut,ImagesRepresentative(comiso,x))));

        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
        iso:=MTX.IsomorphismModules(mo,mo2);
        if iso=fail then
          return false;
        else
          # build associated auto

          a:=GroupHomomorphismByImagesNC(Q,Q,Concatenation(gens,MPcgs),
                  Concatenation(newgens,
                   List(MPcgs,x->PcElementByExponents(MPcgs,
                     (ExponentsOfPcElement(MPcgs,x)*One(mo.field))*iso  ))));
         Assert(2,IsBijective(a));
         Add(A,a);
         Add(Apa,perm);
         Aperm:=ClosureGroup(Aperm,perm);
         return true;
        fi;
      end;

    else
      # there is no B in the nonsplit case
      B:=[];

      ocr:=AGSRPrepareAutomLift( Q, MPcgs, q );

      precond:=function(perm)
      local aut,newgens,mo2;
        if perm in Aperm then
          return true;
        fi;
        aut:=PreImagesRepresentative(AQiso,perm);
        newgens:=List(GeneratorsOfGroup(Q),
          x->PreImagesRepresentative(q,Image(aut,ImagesRepresentative(q,x))));
        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
        return MTX.IsomorphismModules(mo,mo2)<>fail;
      end;

      cond:=function(perm)
      local aut,newgens,mo2,iso,a;
        if perm in Aperm then
          return true;
        fi;
        aut:=PreImagesRepresentative(AQiso,perm);
        newgens:=List(GeneratorsOfGroup(Q),
          x->PreImagesRepresentative(q,Image(aut,ImagesRepresentative(q,x))));
        mo2:=GModuleByMats(LinearActionLayer(newgens,MPcgs),mo.field);
        iso:=MTX.IsomorphismModules(mo,mo2);
        if iso=fail then
          return false;
        else
          # build associated auto
          a:=AGSRAutomLift(ocr,q,aut,iso);
          if a=fail then
            #Print("test failed\n");
            return false;
          else
            Add(A,a);
            Add(Apa,perm);
            Aperm:=ClosureGroup(Aperm,perm);
            #Print("test succeeded\n");
            return true;
          fi;
        fi;
      end;

    fi;

    # find A using the set condition
    A:=[];
    Apa:=[];
    # note: we do not include AQI here, so might need to add later
    Aperm:=SubgroupNC(AQP,List(GeneratorsOfGroup(AQI),
            x->ImagesRepresentative(AQiso,x)));

    # try to find some further generators
    if Size(AQP)/Size(Aperm)>100 then
      for j in SpecialPcgs(SolvableRadical(AQP)) do
        cond(j);
      od;
      for j in GeneratorsOfGroup(AQP) do
        cond(j);
      od;
    fi;

    sub:=AQP;
    if precond<>fail and not ForAll(GeneratorsOfGroup(sub),precond) then
      # compatible pairs condition
      sub:=SubgroupProperty(sub,precond,Aperm);
    fi;

    if IndexNC(sub,Aperm)>10^6 then
      # try to find characteristic subgroups
      Info(InfoMorph,2,"Use normal subgroup classes");
      if nosucl=fail then nosucl:=AGSRNormalSubgroupClasses(G);fi;
      nosuf:=List(nosucl,x->Set(List(x,y->Image(lhom,y))));
      nosuf:=Filtered(nosuf,x->Size(x[1])>1 and Size(x[1])<Size(OQ));
      SortBy(nosuf,Length);
      for j in nosuf do
        # stabilize class
        k:=SmallGeneratingSet(sub);
        ac:=OrbitStabilizerAlgorithm(sub,false,false,
          k,List(k,x->PreImagesRepresentative(AQiso,x)),
          rec(pnt:=j,
          act:=
          function(set,phi)
          #local phi;
            #phi:=PreImagesRepresentative(AQiso,perm);
            return Set(List(set,x->Image(phi,x)));
          end,
          onlystab:=true));
        Info(InfoMorph,3,"Improved index ",IndexNC(sub,ac.stabilizer));
        if Size(ac.stabilizer)<Size(sub) then
          sub:=ac.stabilizer;
        fi;
      od;
    fi;

    j:=Size(sub);
    Info(InfoMorph,2,"start search ",IndexNC(sub,Aperm));
    sub:=SubgroupConditionAbove(sub,cond,Aperm);
    Info(InfoMorph,2,"end search ",j/Size(sub));

    # Note: Aperm is larger than what is generated by Apa
    j:=1;
    while Size(Aperm)<Size(sub) do
      ac:=InnerAutomorphism(OQ,Image(q,GeneratorsOfGroup(Q)[j]));
      k:=ImagesRepresentative(AQiso,ac);
      if not k in Aperm then
        Add(Apa,k);
        Aperm:=ClosureGroup(Aperm,k);
        Add(A,InnerAutomorphism(Q,GeneratorsOfGroup(Q)[j]));
      fi;
      j:=j+1;
    od;

    # remove redundant generators. Note that Aperm could be to big, thus
    # make group from Apa
    ac:=AGSRReducedGens(SubgroupNC(Parent(sub),Apa),Apa,A);
    if ac<>fail then
      Apa:=GeneratorsOfGroup(ac[1]);
      A:=GeneratorsOfGroup(ac[2]);
    fi;

    Info(InfoMorph,2,"Lift Index ",Size(AQP)/Size(sub));

    # now make the new automorphism group
    innB:=List(SmallGeneratingSet(Q),x->InnerAutomorphism(Q,x));
    gens:=ShallowCopy(innB);
    Info(InfoMorph,2,"|gens|=",Length(gens),"+",Length(C),
      "+",Length(B),"+",Length(A));
    Append(gens,C);
    Append(gens,B);
    Append(gens,A);

    Assert(2,ForAll(gens,IsBijective));
    for j in gens do
      SetIsBijective(j,true);
    od;
    A:=Group(gens);
    SetIsAutomorphismGroup(A,true);
    SetIsGroupOfAutomorphismsFiniteGroup(A,true);
    SetIsFinite(A,true);

    AQI:=SubgroupNC(A,innB);
    SetInnerAutomorphismsAutomorphismGroup(A,AQI);
    AQ:=A;
    if Size(KernelOfMultiplicativeGeneralMapping(hom))>1
      or ValueOption("delaypermrep")<>true then
      makeaqiso();
      if not IsIdenticalObj(A,AQ) then
        A:=AQ;
      fi;
    else
      A!.makeaqiso:=makeaqiso;
    fi;

    # do we use induced radical automorphisms to help next step?
    if Size(KernelOfMultiplicativeGeneralMapping(hom))>1 and
      Size(A)>10^8
      #(
      ## potentially large GL
      #Size(GL(Length(MPcgs),RelativeOrders(MPcgs)[1]))>10^10 and
      ## automorphism size really grew from B/C-bit
      ##Size(A)/Size(AQP)*Index(AQP,sub)>10^10) )
      ## do so for all factors
     and ForAll([2..Length(rlgf)],x->rlgf[x]-rlgf[x-1]<10)
     and ValueOption("noradicalaut")<>true then

      if rada=fail then
        if IsElementaryAbelian(r) and Size(r)>1 then
          B:=Pcgs(r);
          rf:=GF(RelativeOrders(B)[1]);
          ind:=Filtered(ser,x->IsSubset(r,x) and Size(x)>1 and Size(x)<Size(r));
          ind:=List(ind,x->List(GeneratorsOfGroup(x),y->ExponentsOfPcElement(B,y)));
          ind:=List(ind,x->x*One(rf));
          ind:=SpaceAndOrbitStabilizer(Length(B),rf,ind,[]);
          rada:=List(GeneratorsOfGroup(ind),x->
            GroupHomomorphismByImagesNC(r,r,B,List(x,y->PcElementByExponents(B,List(y,Int)))));
          rada:=Group(rada);
          SetIsGroupOfAutomorphismsFiniteGroup(rada,true);
          NiceMonomorphism(rada:autactbase:=fail,someCharacteristics:=fail);
        else
          ind:=IsomorphismPcGroup(r);
          rada:=AutomorphismGroup(Image(ind,r):someCharacteristics:=fail,autactbase:=fail);
          # we only consider those homomorphism that stabilize the series we use
          for k in List(ser,x->Image(ind,x)) do
            if ForAny(GeneratorsOfGroup(rada),x->Image(x,k)<>k) then
              Info(InfoMorph,3,"radical automorphism stabilizer");
              NiceMonomorphism(rada:autactbase:=fail,someCharacteristics:=fail);
              SetIsGroupOfAutomorphismsFiniteGroup(rada,true);
              rada:=Stabilizer(rada,k,asAutom);
            fi;
          od;
          # move back to bad degree
          rada:=Group(List(GeneratorsOfGroup(rada),
            x-> InducedAutomorphism(InverseGeneralMapping(ind),x)));
        fi;
      fi;

      rf:=Image(hom,r);
      Info(InfoMorph,2,"Use radical automorphisms for reduction");

      makeaqiso();
      B:=MappingGeneratorsImages(AQiso);
      res:=List(B[1],x->
        GroupHomomorphismByImagesNC(rf,rf,GeneratorsOfGroup(rf),
          List(GeneratorsOfGroup(rf),y->ImagesRepresentative(x,y))));

      ind:=[];
      for j in GeneratorsOfGroup(rada) do
        k:=GroupHomomorphismByImagesNC(rf,rf,
          GeneratorsOfGroup(rf),
          List(GeneratorsOfGroup(rf),
            y->ImagesRepresentative(hom,ImagesRepresentative(j,
                 PreImagesRepresentative(hom,y)))));
        Assert(2,IsBijective(k));
        Add(ind,k);
      od;

      C:=Group(Unique(Concatenation(res,ind))); # to guarantee common parent
      SetIsFinite(C,true);
      SetIsGroupOfAutomorphismsFiniteGroup(C,true);
      Size(C:autactbase:=fail,someCharacteristics:=fail); # disable autactbase transfer
      res:=SubgroupNC(C,res);
      ind:=SubgroupNC(C,ind);
      # this should now go via the niceo of C
      Size(ind:autactbase:=fail,someCharacteristics:=fail);
      Size(res:autactbase:=fail,someCharacteristics:=fail);
      ind:=Intersection(res,ind); # only those we care about

      if Size(ind)<Size(res) then
        # reduce to subgroup that induces valid automorphisms
        Info(InfoMorph,1,"Radical autos reduce by factor ",Size(res)/Size(ind));
        resperm:=IsomorphismPermGroup(C);
        proj:=GroupHomomorphismByImagesNC(AQP,Image(resperm),
          B[2],List(GeneratorsOfGroup(res),x->ImagesRepresentative(resperm,x)));
        C:=PreImage(proj,Image(resperm,ind));
        C:=List(SmallGeneratingSet(C),x->PreImagesRepresentative(AQiso,x));
        AQ:=Group(C);
        SetIsFinite(AQ,true);
        SetIsGroupOfAutomorphismsFiniteGroup(AQ,true);
        makeaqiso();
      fi;

      # # hook for using existing characteristics to reduce for next step
      if somechar<>fail then
        u:=Filtered(Unique(List(somechar,x->Image(hom,x))),x->Size(x)>1);
        u:=Filtered(u,s->ForAny(GeneratorsOfGroup(AQ),h->Image(h,s)<>s));
        SortBy(u,Size);
        Info(InfoMorph,1,"Forced characteristics ",List(u,Size));

        if scharorb<>fail then
          # these are subgroups for which certain orbits must be stabilized.
          C:=List(Reversed(scharorb),x->List(x,y->Image(hom,y)));
          C:=Filtered(C,x->Size(x[1])>1 and Size(x[1])<Size(Q));
          Info(InfoMorph,1,"Forced orbits ",List(C,x->Size(x[1])));
          Append(u,C);
        fi;

        if Length(u)>0 then
          C:=MappingGeneratorsImages(AQiso);
          if C[2]<>GeneratorsOfGroup(AQP) then
            C:=[List(GeneratorsOfGroup(AQP),
                     x->PreImagesRepresentative(AQiso,x)),
                 GeneratorsOfGroup(AQP)];
          fi;
          for j in u do
            if IsList(j) then
              # stabilizer set of subgroups
              jorb:=ShallowCopy(Orbit(AQP,j[1],C[2],C[1],asAutom));
              jorpo:=[Position(jorb,j[1]),Position(jorb,j[2])];
              if jorpo[2]=fail then
                Append(jorb,Orbit(AQP,j[1],C[2],C[1],asAutom));
            jorpo[2]:=Position(jorb,j[2]);
              fi;
              if Length(jorb)>Length(j) then
            B:=ActionHomomorphism(AQP,jorb,C[2],C[1],asAutom);
            substb:=Group(List(C[2],x->ImagesRepresentative(B,x)),());
            substb:=Stabilizer(substb,Set(jorpo),OnSets);
            substb:=PreImage(B,substb);
            Info(InfoMorph,2,"Stabilize characteristic orbit ",Size(j[1]),
              " :",Size(AQP)/Size(substb) );
              else
                substb:=AQP;
              fi;


        else
          substb:=Stabilizer(AQP,j,C[2],C[1],asAutom);
          Info(InfoMorph,2,"Stabilize characteristic subgroup ",Size(j),
        " :",Size(AQP)/Size(substb) );
        fi;
        if Size(substb)<Size(AQP) then
          B:=Size(substb);
          substb:=SmallGeneratingSet(substb);
          AQP:=Group(substb);
          SetSize(AQP,B);
          C:=[List(substb,x->PreImagesRepresentative(AQiso,x)),substb];
        fi;

      od;
      AQ:=Group(C[1]);
      SetIsFinite(AQ,true);
      SetIsGroupOfAutomorphismsFiniteGroup(AQ,true);
      SetSize(AQ,Size(AQP));
      #AQP:=Group(C[2]); # ensure small gen set
      #SetSize(AQP,Size(AQ));
      makeaqiso();
    fi;
      fi;

      lastperm:=AQiso;
    else
      lastperm:=fail;
    fi;

    i:=i+1;
  od;

  return AQ;

end);

# find characteristic subgroups by splitting into elementary abelian,
# homogeneous layers
BindGlobal("AGSRModuleLayerSeries",function(g)
local s,l,r,i,j,sy,hom,p,pcgs;
  s:=ShallowCopy(DerivedSeriesOfGroup(g));
  r:=SolvableRadical(s[Length(s)]);
  if Size(r)>1 then # cannot be last, as solvable
    Append(s,DerivedSeriesOfGroup(r));
  fi;
  i:=2;
  while i<=Length(s) do
    if HasAbelianFactorGroup(s[i-1],s[i]) then
      p:=Factors(IndexNC(s[i-1],s[i]))[1];
      # is it a single prime?
      if not IsPrimePowerInt(IndexNC(s[i-1],s[i])) then
        hom:=NaturalHomomorphismByNormalSubgroupNC(s[i-1],s[i]);
        sy:=SylowSystem(Image(hom));
        l:=[sy[1]];
        for j in [2..Length(sy)-1] do
          Add(l,ClosureGroup(l[Length(l)],sy[j]));
        od;
        l:=Reversed(l);
        l:=List(l,x->PreImage(hom,x));
        Info(InfoMorph,6,"insert prime @",i);
        s:=Concatenation(s{[1..i-1]},l,s{[i..Length(s)]});
      elif not HasElementaryAbelianFactorGroup(s[i-1],s[i]) then
        # not elementary abelian -- pth powers suffice as abelian
        l:=s[i];
        for j in GeneratorsOfGroup(s[i-1]) do
          l:=ClosureGroup(l,j^p);
        od;
        Info(InfoMorph,6,"insert ppower @",i);
        s:=Concatenation(s{[1..i-1]},[l],s{[i..Length(s)]});
      else
        # make module
        pcgs:=ModuloPcgs(s[i-1],s[i]);
        l:=LinearActionLayer(g,pcgs);
        l:=GModuleByMats(l,GF(p));
        # check for characteristic submodules
        r:=MTX.BasisRadical(l);
        if Length(r)=0 then
          r:=MTX.BasisSocle(l);
          if Length(r)=l.dimension then
            # semisimple -- use homogeneous
            sy:=List(MTX.CollectedFactors(l),x->x[1]);
            if Length(sy)>1 then
              r:=Minimum(List(sy,x->x.dimension));
              sy:=Filtered(sy,x->x.dimension=r);
              r:=[];
              for j in sy do
                Append(r,MTX.Homomorphisms(j,l));
              od;
              r:=Concatenation(r);
              r:=Filtered(TriangulizedMat(r),x->not IsZero(x));
            else
              r:=fail;
            fi;
          fi;
        fi;

        if r=fail then
          i:=i+1;
        else
          l:=s[i];
          for j in r do;
            l:=ClosureGroup(l,PcElementByExponents(pcgs,j));
          od;
          if Size(l)<Size(s[i-1]) and Size(l)>Size(s[i]) then
            Info(InfoMorph,6,"insert module @",i);
            s:=Concatenation(s{[1..i-1]},[l],s{[i..Length(s)]});
          else
            i:=i+1;
          fi;
        fi;
      fi;
    else
      i:=i+1;
    fi;
  od;
  return s;
end);

# find corresponding characteristic subgroups
BindGlobal("AGSRMatchedCharacteristics",function(g,h)
local a,props,cg,ch,clg,clh,ng,nh,coug,couh,pg,ph,i,j,stop,coinc;
  props:=function(a)
  local p,b;

    if ID_AVAILABLE(Size(a))<>fail then
      p:=ShallowCopy(-IdGroup(a)); # negative avoids clash with others
    else
      p:=[Size(a)];
      b:=ShallowCopy(AbelianInvariants(a));
      Sort(b);
      Add(p,b);
      Add(p,List(DerivedSeriesOfGroup(a),Size));
    fi;
#    # intersections
#    for i in [1..Length(chars)] do
#      for j in AGSRModuleLayerSeries(chars[i]) do
#        der(Intersection(j,a));
#        der(ClosureGroup(j,a));
#      od;
#    od;
    return p;
  end;

  coinc:=function(i,j)
  local a,b,sa,sb,sel,p,q;
    a:=cg[i];
    b:=ch[j];
    Add(ng,a);
    Add(nh,b);
    sel:=Difference([1..Length(cg)],[i]);
    cg:=cg{sel};
    pg:=pg{sel};
    sel:=Difference([1..Length(ch)],[j]);
    ch:=ch{sel};
    ph:=ph{sel};
    sa:=AGSRModuleLayerSeries(a);
    sb:=AGSRModuleLayerSeries(b);
    if List(sa,Size)<>List(sb,Size) then return true;fi;
    for i in [1..Length(sa)] do
      p:=Position(cg,sa[i]);
      q:=Position(ch,sb[i]);
      if p=fail then
        if q<>fail then return true;fi;
      elif q=fail then return true;
      else
        if coinc(p,q) then return true;fi;
      fi;
    od;
    return false;
  end;

  ng:=[];
  nh:=[];

  cg:=ShallowCopy(CharacteristicSubgroups(g));
  ch:=ShallowCopy(CharacteristicSubgroups(h));
  SortBy(cg,x->-Size(x));
  SortBy(ch,x->-Size(x));

  pg:=List(cg,props);
  ph:=List(ch,props);
  if Collected(pg)<>Collected(ph) then return fail;fi;

  stop:=false;
  while Length(cg)>0 and not stop do
    i:=First([1..Length(pg)],x->Number(pg,y->y=pg[x])=1);
    if i<>fail then
      # found a unique one -- process
      j:=Position(ph,pg[i]);
      if coinc(i,j) then return fail;fi;
    else
      stop:=true; # give up, for the moment
      # try clusters
      j:=Set(pg);
      clg:=List(j,x->cg{Filtered([1..Length(cg)],y->pg[y]=x)});
      clh:=List(j,x->ch{Filtered([1..Length(ch)],y->ph[y]=x)});
      # also use classes of size 1 for compare
      Append(clg,List(ng,x->[x]));
      Append(clh,List(nh,x->[x]));
      # sort larger first
      SortParallel(clg,clh,function(a,b) return Size(a[1])>Size(b[1]);end);
      i:=1;
      while i<=Length(clg) do
        if Length(clg[i])>1 then
          j:=i+1;
          while j<=Length(clg) do
            coug:=List(clg[i],x->Number(clg[j],y->IsSubset(x,y)));
            couh:=List(clh[i],x->Number(clh[j],y->IsSubset(x,y)));
            if Collected(coug)<>Collected(couh) then return fail;fi;
            a:=First(Collected(coug),x->x[2]=1);
            if a<>fail then
              # unique number -- split
              a:=a[1];
              if coinc(Position(cg,clg[i][Position(coug,a)]),
                    Position(ch,clh[i][Position(couh,a)])) then return fail;fi;
              i:=Length(clg); j:=Length(clg); # break out of loops
              stop:=false;
            fi;
            j:=j+1;
          od;
        fi;
        i:=i+1;
      od;
    fi;
  od;

  j:=Set(pg);
  return rec(
    ng:=ng,nh:=nh,
    cg:=List(j,x->cg{Filtered([1..Length(cg)],y->pg[y]=x)}),
    ch:=List(j,x->ch{Filtered([1..Length(ch)],y->ph[y]=x)})
    );
end);

BindGlobal("AGBoundedOrbrep",function(G,from,to,act,bound)
local orb,rep,S,i,g,img,p;
  orb:=[from];
  rep:=[One(G)];
  S:=[];
  i:=1;
  while i<=Length(orb) do
    for g in GeneratorsOfGroup(G) do
      img:=act(orb[i],g);
      p:=Position(orb,img);
      if p=fail then
        if Length(orb)>=bound then return fail;fi; # length bailout
        Add(orb,img);
        Add(rep,rep[i]*g);
      else
        img:=rep[i]*g/rep[p];
        if not (img in S or img^-1 in S) then
          Add(S,img);
        fi;
      fi;
    od;
    i:=i+1;
  od;
  p:=Position(orb,to);
  if p=fail then return false;fi; # not in orbit
  return rec(rep:=rep[p],orblen:=Length(orb),stabgens:=S);
end);


# pathetic isomorphism test, based on the automorphism group of GxH. This is
# only of use as long as we don't yet have a Cannon/Holt version of
# isomorphism available and there are many generators
InstallGlobalFunction(PatheticIsomorphism,function(G,H)
local d,a,map,cG,nG,nH,i,j,u,v,asAutomorphism,K,L,conj,e1,e2,
      iso,api,gens,pre,aab,as,somechar;

  asAutomorphism:=function(sub,hom)
    return Image(hom,sub);
  end;

  # TODO: use matgrp package
  if not (IsPermGroup(G) or IsPcGroup(G))  then
    i:=IsomorphismPermGroup(G);
    iso:=PatheticIsomorphism(Image(i,G),H);
    if iso=fail then
      return iso;
    else
      return i*iso;
    fi;
  fi;

  # TODO: use matgrp package
  if not (IsPermGroup(H) or IsPcGroup(H)) then
    i:=IsomorphismPermGroup(H);
    iso:=PatheticIsomorphism(G,Image(i,H));
    if iso=fail then
      return iso;
    else
      return iso*InverseGeneralMapping(i);
    fi;
  fi;

  # go through factors of characteristic series to keep orbits short.
  AutomorphismGroup(G:someCharacteristics:=fail);
  AutomorphismGroup(H:someCharacteristics:=fail);

  d:=AGSRMatchedCharacteristics(G,H);
  if d=fail then return fail;fi; # characteristics do not match
  nG:=d.ng;
  nH:=d.nh;
  for i in [1..Length(d.cg)] do
    u:=TrivialSubgroup(G);
    for j in d.cg[i] do
      u:=ClosureGroup(u,j);
    od;
    if not u in nG then
      Add(nG,u);
      u:=TrivialSubgroup(H);
      for j in d.ch[i] do
        u:=ClosureGroup(u,j);
      od;
      Add(nH,u);
    fi;
  od;

  d:=DirectProduct(G,H);
  e1:=Embedding(d,1);
  e2:=Embedding(d,2);
  # combine images of characteristic factors, reverse order
  cG:=[];
  nG:=Reversed(nG);
  nH:=Reversed(nH);
  for i in [1..Length(nG)] do
    Add(cG,ClosureGroup(Image(e1,nG[i]),Image(e2,nH[i])));
  od;
  nG:=Concatenation([TrivialSubgroup(G)],nG);
  nH:=Concatenation([TrivialSubgroup(H)],nH);
  SortParallel(nG,nH,function(a,b) return Size(a)<Size(b);end);
  if List(nG,Size)<>List(nH,Size) then return fail;fi;

  for i in [2..Length(nG)] do
    K:=Filtered([1..Length(nG)],x->Size(nG[x])*2=Size(nG[i])
          and IsSubset(nG[i],nG[x]));
    if Length(K)>0 then
      K:=K[1];
      # We are seeking an isomorphism, not the full automorphism group of
      # GxG. It is thus sufficient, if we find the subgroup Aut(G)\wr 2.


      # We now found that G and H have two characteristic subgroups A<B with
      # [B:A]=2. An isomorphism swapping G and H will need to map B to B and
      # A to A. Furthermore, in the factor modulo A_G xA_H, a generator of
      # B_G must be swappes with a generator of B_H.
      # This implies that A_G\times A_H, together with the diagonal of B is
      # characteristic in Aut(A)\wr 2. We thus may add this subgroup as
      # ``characteristic'' to improve the series.

      Add(cG,ClosureGroup(
        ClosureGroup(Image(e1,nG[K]),Image(e2,nH[K])),
          Image(e1,First(GeneratorsOfGroup(nG[i]),x->not x in nG[K]))
         *Image(e2,First(GeneratorsOfGroup(nH[i]),x->not x in nH[K]))));

    fi;
  od;

  aab:=[Image(e1,G),Image(e2,H)];
  # we also fix the *pairs* of the characteristic subgroups as orbits. Again
  # this must happen in Aut(G)\wr 2, and reduces the size of the group.
  somechar:=rec(subgroups:=cG,
        orbits:=List([1..Length(nG)],x->[Image(e1,nG[x]),Image(e2,nH[x])]));
  a:=AutomorphismGroup(d:autactbase:=aab,someCharacteristics:=somechar,
    directs:=aab,
    delaypermrep:=true );
  for i in cG do
    if not ForAll(GeneratorsOfGroup(a),x->Image(x,i)=i) then
      a:=Stabilizer(a,i,asAutomorphism);
    fi;
  od;

  iso:=fail;
  #if NrMovedPoints(api)>5000 then
  #  K:=SmallerDegreePermutationRepresentation(api);
  #  Info(InfoMorph,2,"Permdegree reduced ",
#         NrMovedPoints(api),"->",NrMovedPoints(Image(K)));
#    iso:=iso*K;
#    api:=Image(iso);
#  fi;

  # now work in reverse through the characteristic factors
  conj:=One(a);
  K:=Image(e1,G);
  L:=Image(e2,H);
  map:=AGBoundedOrbrep(a,K,L,asAutomorphism,20);
  if map=false then
    Info(InfoMorph,1,"Shortorb test noniso");
    return fail;
  elif map<>fail then
    conj:=map.rep;
    Info(InfoMorph,1,"Shortorb test iso found");
  else

    as:=a;
    Add(cG,TrivialSubgroup(d));

    SortBy(cG,x->-Size(x));
    for i in cG do
      u:=ClosureGroup(i,K);
      v:=ClosureGroup(i,L);
      if u<>v then

        # try cheap orbit stabilizer first
        if iso<>fail then
          map:=fail;
        else
          map:=AGBoundedOrbrep(as,u,v,asAutomorphism,100);
        fi;
        if map=false then
          Info(InfoMorph,1,"Shortorb factor noniso");
          return fail;
        elif map<>fail then
          Info(InfoMorph,1,"Shortorb factor reduce ",map.orblen);
          as:=SubgroupNC(Parent(as),map.stabgens);
          map:=map.rep;
          conj:=conj*map;
          K:=Image(map,K);
          as:=as^map;
        else
          if iso=fail then
            Info(InfoMorph,1,"Shortorb failed, get delayed permrep");
            if IsBound(a!.makeaqiso) then a!.makeaqiso();fi;
            iso:=IsomorphismPermGroup(a:autactbase:=aab);
            api:=Image(iso,as);
          fi;

          if IsSolvableGroup(api) then
            gens:=Pcgs(api);
          else
            gens:=SmallGeneratingSet(api);
          fi;
          pre:=List(gens,x->PreImagesRepresentative(iso,x));
          map:=RepresentativeAction(SubgroupNC(a,pre),u,v,asAutomorphism);
          if map=fail then
            return fail;
          fi;
          conj:=conj*map;
          K:=Image(map,K);

          if Size(i)>1 then
            u:=Stabilizer(api,v,gens,pre,asAutomorphism);
            Info(InfoMorph,1,"Factor ",Size(d)/Size(i),": ",
                "reduce by ",Size(api)/Size(u));
            api:=u;
          fi;
        fi;
      fi;
    od;

  fi;

  return GroupHomomorphismByImagesNC(G,H,GeneratorsOfGroup(G),
    List(GeneratorsOfGroup(G),x->PreImagesRepresentative(e2,
         Image(conj,Image(e1,x)))));
end);
