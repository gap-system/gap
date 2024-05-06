###########################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  contains declarations for Morpheus
##

#############################################################################
##
#V  MORPHEUSELMS . . . .  limit up to which size to store element lists
##
MORPHEUSELMS := 50000;

# this method calculates a chief series invariant under `hom` and calculates
# orders of group elements in factors of this series under action of `hom`.
# Every time an orbit length is found, `hom` is replaced by the appropriate
# power. Initially small chief factors are preferred. In the end all
# generators are used while stepping through the series descendingly, thus
# ensuring the proper order is found.
InstallMethod(Order,"for automorphisms",true,[IsGroupHomomorphism],0,
function(hom)
local map,phi,o,lo,i,j,start,img,d,nat,ser,jord,first;
  d:=Source(hom);
  if not (HasIsFinite(d) and IsFinite(d)) then
    TryNextMethod();
  fi;
  if Size(d)<=10000 then
    ser:=[d,TrivialSubgroup(d)]; # no need to be clever if small
  else
    if HasAutomorphismGroup(d) then
      if IsBound(d!.characteristicSeries) then
        ser:=d!.characteristicSeries;
      else
        ser:=ChiefSeries(d); # could try to be more clever, introduce attribute
        # `CharacteristicSeries`.
        ser:=Filtered(ser,x->ForAll(GeneratorsOfGroup(AutomorphismGroup(d)),
          a->ForAll(GeneratorsOfGroup(x),y->ImageElm(a,y) in x)));
        d!.characteristicSeries:=ser;
      fi;
    else
      ser:=ChiefSeries(d); # could try to be more clever, introduce attribute
      # `CharacteristicSeries`.
      ser:=Filtered(ser,
            x->ForAll(GeneratorsOfGroup(x),y->ImageElm(hom,y) in x));
    fi;
  fi;

  # try to do factors in ascending order in the hope to get short orbits
  # first
  jord:=[2..Length(ser)]; # order in which we go through factors
  if Length(ser)>2 then
    i:=List(jord,x->Size(ser[x-1])/Size(ser[x]));
    SortParallel(i,jord);
  fi;

  o:=1;
  phi:=hom;
  map:=MappingGeneratorsImages(phi);

  first:=true;
  while map[1]<>map[2] do
    for j in jord do
      i:=1;
      while i<=Length(map[1]) do
        # the first time, do only the generators from prior layer
        if (not first)
           or (map[1][i] in ser[j-1] and not map[1][i] in ser[j]) then

          lo:=1;
          if j<Length(ser) then
            nat:=NaturalHomomorphismByNormalSubgroup(d,ser[j]);
            start:=ImagesRepresentative(nat,map[1][i]);
            img:=map[2][i];
            while ImagesRepresentative(nat,img)<>start do
              img:=ImagesRepresentative(phi,img);
              lo:=lo+1;

              # do the bijectivity test only if high local order, then it
              # does not matter. IsBijective is cached, so second test is
              # cheap.
              if lo=1000 and not IsBijective(hom) then
                Error("<hom> must be bijective");
              fi;

            od;

          else
            start:=map[1][i];
            img:=map[2][i];
            while img<>start do
              img:=ImagesRepresentative(phi,img);
              lo:=lo+1;

              # do the bijectivity test only if high local order, then it
              # does not matter. IsBijective is cached, so second test is
              # cheap.
              if lo=1000 and not IsBijective(hom) then
                Error("<hom> must be bijective");
              fi;

            od;
          fi;

          if lo>1 then
            o:=o*lo;
            #if i<Length(map[1]) then
              phi:=phi^lo;
              map:=MappingGeneratorsImages(phi);
              i:=0; # restart search, as generator set may have changed.
            #fi;
          fi;
        fi;
        i:=i+1;
      od;
    od;

    # if iterating make `jord` standard to we don't skip generators
    jord:=[2..Length(ser)];
    first:=false;
  od;

  return o;
end);

#############################################################################
##
#M  AutomorphismDomain(<G>)
##
##  If <G> consists of automorphisms of <H>, this attribute returns <H>.
InstallMethod( AutomorphismDomain, "use source of one",true,
  [IsGroupOfAutomorphisms],0,
function(G)
  return Source(One(G));
end);

DeclareRepresentation("IsActionHomomorphismAutomGroup",
  IsActionHomomorphismByBase,["basepos"]);

#############################################################################
##
#M  IsGroupOfAutomorphisms(<G>)
##
InstallMethod( IsGroupOfAutomorphisms, "test generators and one",true,
  [IsGroup],0,
function(G)
local s;
  if IsGeneralMapping(One(G)) then
    s:=Source(One(G));
    if Range(One(G))=s and ForAll(GeneratorsOfGroup(G),
      g->IsGroupGeneralMapping(g) and IsSPGeneralMapping(g) and IsMapping(g)
         and IsInjective(g) and IsSurjective(g) and Source(g)=s
         and Range(g)=s) then
      SetAutomorphismDomain(G,s);
      # imply finiteness
      if IsFinite(s) then
        SetIsFinite(G,true);
      fi;
      return true;
    fi;
  fi;
  return false;
end);

#############################################################################
##
#M  IsGroupOfAutomorphismsFiniteGroup(<G>)
##
InstallMethod( IsGroupOfAutomorphismsFiniteGroup,"default",true,
  [IsGroup],0,
  G->IsGroupOfAutomorphisms(G) and IsFinite(AutomorphismDomain(G)));

# Try to embed automorphisms into wreath product.
BindGlobal("AutomorphismWreathEmbedding",function(au,g)
local gens, inn,out, nonperm, syno, orb, orbi, perms, free, rep, i, maxl, gen,
      img, j, conj, sm, cen, n, w, emb, ge, no,reps,synom,ginn,oemb,act,
      ogens,genimgs,oo,op;

  gens:=GeneratorsOfGroup(g);
  if Size(Centre(g))>1 then
    return fail;
  fi;
  #sym:=SymmetricGroup(MovedPoints(g));
  #syno:=Normalizer(sym,g);

  inn:=Filtered(GeneratorsOfGroup(au),i->IsInnerAutomorphism(i));
  out:=Filtered(GeneratorsOfGroup(au),i->not IsInnerAutomorphism(i));
  nonperm:=Filtered(out,i->not IsConjugatorAutomorphism(i));
  syno:=g;
  #syno:=Group(List(Filtered(GeneratorsOfGroup(au),IsInnerAutomorphism),
#        ConjugatorOfConjugatorIsomorphism),One(g));
  for i in Filtered(out,IsConjugatorAutomorphism) do
    syno:=ClosureGroup(syno,ConjugatorOfConjugatorIsomorphism(i));
  od;
  #nonperm:=Filtered(out,i->not IsInnerAutomorphism(i));
  # enumerate cosets of subgroup of conjugator isomorphisms
  orb:=[IdentityMapping(g)];
  orbi:=[IdentityMapping(g)];
  perms:=List(nonperm,i->[]);
  free:=FreeGroup(Length(nonperm));
  rep:=[One(free)];
  i:=1;
  maxl:=NrMovedPoints(g);
  while i<=Length(orb) and Length(orb)<maxl do
    for w in [1..Length(nonperm)] do
      gen:=nonperm[w];
      img:=orb[i]*gen;
      j:=1;
      conj:=fail;
      while conj=fail and j<=Length(orb) do
        sm:=img*orbi[j];
        if IsConjugatorAutomorphism(sm) then
          conj:=ConjugatorOfConjugatorIsomorphism(sm);
        else
          j:=j+1;
        fi;
      od;
      #j:=First([1..Length(orb)],k->IsConjugatorAutomorphism(img*orbi[k]));
      if conj=fail then
        Add(orb,img);
        Add(orbi,InverseGeneralMapping(img));
        Add(rep,rep[i]*GeneratorsOfGroup(free)[w]);
        perms[w][i]:=Length(orb);
      else
        perms[w][i]:=j;
        if not conj in syno then
          syno:=ClosureGroup(syno,conj);
        fi;
      fi;
    od;
    i:=i+1;
  od;

  if not IsTransitive(syno,MovedPoints(syno)) then
    return fail;
    # # characteristic product?
    # w:=Orbits(syno,MovedPoints(syno));
    # n:=List(w,x->Stabilizer(g,Difference(MovedPoints(g),x),OnTuples));
    # if ForAll(n,x->ForAll(GeneratorsOfGroup(au),y->Image(y,x)=x)) then
    #   Error("WR5");
    # fi;
  fi;
  if Length(GeneratorsOfGroup(syno))>5 then
    syno:=Group(SmallGeneratingSet(syno));
  fi;

  cen:=Centralizer(syno,g);
  Info(InfoMorph,2,"|syno|=",Size(syno)," |cen|=",Size(cen));
  if Size(cen)>1 then
    w:=syno;
    syno:=ComplementClassesRepresentatives(syno,cen);
    if Length(syno)=0 then
      return fail; # not unique permauts
    fi;
    syno:=syno[1];
    synom:=GroupHomomorphismByImagesNC(w,syno,
            Concatenation(GeneratorsOfGroup(syno),GeneratorsOfGroup(cen)),
            Concatenation(GeneratorsOfGroup(syno),List(GeneratorsOfGroup(cen),x->One(syno))));
  else
    synom:=IdentityMapping(syno);
  fi;

  # try wreath embedding
  if Length(orb)<maxl then
    Info(InfoMorph,1,Length(orb)," copies");
    perms:=List(perms,PermList);
    Info(InfoMorph,2,List(rep,i->MappedWord(i,GeneratorsOfGroup(free),perms)));
    n:=Length(orb);
    w:=WreathProduct(syno,SymmetricGroup(n));
    no:=KernelOfMultiplicativeGeneralMapping(Projection(w));
    gens:=SmallGeneratingSet(g);
    emb:=List(gens,
          i->Product(List([1..n],j->Image(Embedding(w,j),Image(synom,Image(orbi[j],i))))));
    ge:=SubgroupNC(w,emb);
    emb:=GroupHomomorphismByImagesNC(g,ge,gens,emb);
    reps:=[];
    oo:=List(Orbits(no,MovedPoints(no)),Set);
    ForAll(oo,IsRange);
    act:=[];
    for i in out do

      # how does it permute the components?
      conj:=List(orb,x->x*i);
      conj:=List(conj,x->PositionProperty(orb,
        y->IsConjugatorAutomorphism(x/y)));
      conj:=PermList(conj);
      if conj=fail then return fail;fi;
      conj:=ImagesRepresentative(Embedding(w,n+1),conj);

      #gen:=RepresentativeAction(no,GeneratorsOfGroup(ge),
      #  List(gens,j->Image(emb,ImagesRepresentative(i,j))^(conj^-1)),OnTuples);
      ogens:=GeneratorsOfGroup(ge);
      genimgs:=List(gens,j->Image(emb,ImagesRepresentative(i,j))^(conj^-1));
      gen:=One(no);
      for op in [1..Length(oo)] do
        if not IsBound(act[op]) then
          Info(InfoMorph,2,"oo=",op,oo[op]);
          act[op]:=Group(List(GeneratorsOfGroup(no),x->RestrictedPerm(x,oo[op])));
          SetSize(act,Size(syno));
        fi;

        sm:=RepresentativeAction(act[op],
          List(ogens,x->RestrictedPerm(x,oo[op])),
          List(genimgs,x->RestrictedPerm(x,oo[op])),OnTuples);
        if not IsPerm(sm) then return fail;fi;
        #ogens:=List(ogens,x->x^sm);
        gen:=gen*sm;
      od;

      if not OnTuples(ogens,gen)=genimgs then
        Error("conjugation error!");
      fi;

      #if not IsPerm(gen) then return fail;fi;
      gen:=gen*conj;
      Add(reps,gen);
    od;

    #no:=Normalizer(w,ge);
    #no:=ClosureGroup(ge,reps);
    ginn:=List(inn,ConjugatorOfConjugatorIsomorphism);
    no:=Group(List(ginn,i->Image(emb,i)), One(w));
    oemb:=emb;
    if Size(no)<Size(ge) then
      emb:=RestrictedMapping(emb,Group(ginn,()));
    fi;
    no:=ClosureGroup(no,reps);
    cen:=Centralizer(no,ge);
    if Size(no)/Size(cen)<Length(orb) then
      return fail;
    fi;

    if Size(cen)>1 then
      no:=ComplementClassesRepresentatives(no,cen);
      if Length(no)>0 then
        no:=no[1];
      else
        return fail;
      fi;
    fi;
    #
    #if Size(no)/Size(syno)<>Length(orb) then
    #  Error("wreath embedding failed");
    #fi;
    sm:=SmallerDegreePermutationRepresentation(ClosureGroup(ge,no):cheap);
    no:=Image(sm,no);
    if IsIdenticalObj(emb,oemb) then
      emb:=emb*sm;
      return [no,emb,emb,Image(emb,ginn)];
    else
      emb:=emb*sm;
      oemb:=oemb*sm;
      return [no,emb,oemb,Group(Image(oemb,ginn),One(w))];
    fi;
  fi;
  return fail;
end);

#############################################################################
##
#F  AssignNiceMonomorphismAutomorphismGroup(<autgrp>,<g>)
##
# try to find a small faithful action for an automorphism group
InstallGlobalFunction(AssignNiceMonomorphismAutomorphismGroup,function(au,g)
local hom, gens, c, ran, r, cen, img, u, orbs,
      ser,pos, o, i, j, best,actbase,action,finish,
      bestdeg,deg,baddegree,auo,of,cl,store, offset,claselms,fix,new,
      preproc,postproc;

  finish:=function(hom)
    SetIsGroupHomomorphism(hom,true);
    SetIsBijective(hom,true);
    SetFilterObj(hom,IsNiceMonomorphism);
    SetNiceMonomorphism(au,hom);
    SetIsHandledByNiceMonomorphism(au,true);
  end;

  # avoid storing list of class elements anew
  claselms:=function(clas)
    if HasAsSSortedList(clas) then
      return AsSSortedList(clas);
    else
      return MakeImmutable(Set(Orbit(g,Representative(clas))));
    fi;
  end;

  hom:=fail;

  if not IsFinite(g) then
    Error("can't do!");
  else
    SetIsFinite(au,true);
  fi;

  if IsFpGroup(g) then
    # no sane person should work with automorphism groups of fp groups, as
    # this is doubly inefficient, but if someone really does, this is a
    # shortcut that avoids canonization issues.
    c:=Filtered(Elements(g),x->not IsOne(x));
    hom:=ActionHomomorphism(au,c,
           function(e,a) return Image(a,e);end,"surjective");
    finish(hom); return;
  elif IsAbelian(g) or (Size(g)<50000 and Size(DerivedSubgroup(g))^2<Size(g)) then
    # for close to abelian groups, just act on orbits of generators
    if IsAbelian(g) then
      gens:=IndependentGeneratorsOfAbelianGroup(g);
    else
      gens:=SmallGeneratingSet(g);
    fi;
    c:=[];
    for i in gens do
      c:=Union(c,Orbit(au,i));
    od;
    hom:=NiceMonomorphismAutomGroup(au,c,gens);
    finish(hom); return;
  fi;

  # if no centre and all automorphism conjugator, try to extend exiting permrep
  if Size(Centre(g))=1 and IsPermGroup(g) and
     ForAll(GeneratorsOfGroup(au),IsConjugatorAutomorphism) then
    ran:= Group( List( GeneratorsOfGroup( au ),
                      ConjugatorOfConjugatorIsomorphism ),
                One( g ) );
    Info(InfoMorph,1,"All automorphisms are conjugator");
    Size(ran); #enforce size calculation

    # if `ran' has a centralizing bit, we're still out of luck.
    # TODO: try whether there is a centralizer complement into which we
    # could go.

    if Size(Centralizer(ran,g))=1 then
      r:=ran; # the group of conjugating elements so far
      cen:=TrivialSubgroup(r);

      hom:=GroupHomomorphismByFunction(au,ran,
        function(auto)
          if not IsConjugatorAutomorphism(auto) then
            return fail;
          fi;
          img:=ConjugatorOfConjugatorIsomorphism( auto );
          if not img in ran then
            # There is still something centralizing left.
            if not img in r then
              # get the cenralizing bit
              r:=ClosureGroup(r,img);
              cen:=Centralizer(r,g);
            fi;
            # get the right coset element
            img:=First(List(Enumerator(cen),i->i*img),i->i in ran);
          fi;
          return img;
        end,
        function(elm)
          return ConjugatorAutomorphismNC( g, elm );
        end);
      SetRange( hom,ran );
      finish(hom); return;
    fi;
  fi;

  actbase:=ValueOption("autactbase");

  bestdeg:=infinity;
  # what degree would we consider immediately acceptable?
  if actbase<>fail then
    if ForAny(actbase,x->not IsSubset(g,x)) then
      Error("illegal actbase given!");
    fi;
    baddegree:=RootInt(Sum(actbase,Size)^2,3);
  else
    baddegree:=RootInt(Size(g)^3,4);
  fi;
  if IsPermGroup(g) then baddegree:=Minimum(baddegree,Maximum(2000,NrMovedPoints(g)*10));fi;
    Info(InfoMorph,4,"degree limit ",baddegree);

  ser:=StructuralSeriesOfGroup(g);
  # eliminate very small subgroups -- there are just very few elements in
  r:=RootInt(Size(ser),4);
  ser:=Filtered(ser,x->Size(x)=1 or Size(x)>r);
  ser:=List(ser,x->SubgroupNC(g,SmallGeneratingSet(x)));

  pos:=2;

  # try action on elements, through orbits on classes
  auo:=Group(Filtered(GeneratorsOfGroup(au),x->not IsInnerAutomorphism(x)),One(au));

  if IsPermGroup(g) and Size(SolvableRadical(g))^2>Size(g) then
    FittingFreeLiftSetup(g);
    preproc:=x->TFCanonicalClassRepresentative(g,[Representative(x)])[1][2];
    postproc:=rep->ConjugacyClass(g,rep);
    action:=function(crep,aut)
      return TFCanonicalClassRepresentative(g,[ImagesRepresentative(aut,crep)])[1][2];
    end;
  else
    action:=function(class,aut)
      local c,s;
      c:=ConjugacyClass(g,ImagesRepresentative(aut,Representative(class)));
      if HasSize(class) then
        SetSize(c,Size(class));
      fi;
      if HasStabilizerOfExternalSet(class) then
        Size(StabilizerOfExternalSet(class)); # force size known to transfer
        s:=Image(aut,StabilizerOfExternalSet(class));
        SetStabilizerOfExternalSet(c,s);
      fi;
      return c;
    end;
    preproc:=fail;
    postproc:=fail;
  fi;

  # first try classes that generate, starting with small ones
  if actbase<>fail then
    c:=Concatenation(List(actbase,GeneratorsOfGroup));
  else
    c:=GeneratorsOfGroup(g);
  fi;
  # split c into prime power parts
  c:=Concatenation(List(c,PrimePowerComponents));

  c:=Unique(List(c,x->ConjugacyClass(g,x)));
  SortBy(c,Size);
  r:=Filtered([1..Length(c)],x->Representative(c[x]) in ser[pos]);
  c:=c{Concatenation(Difference([1..Length(c)],r),r)};
  o:=[];
  fix:=Filtered(List(c,Representative),
    x->ForAll(GeneratorsOfGroup(au),z->ImagesRepresentative(z,x)=x));
  u:=SubgroupNC(g,fix);

  while Size(u)<Size(g) do
    if Size(u)>1 then SortBy(c,Size);fi; # once an outside class is known, sort
    of:=First(c,x->not Representative(x) in u);

    if of=fail then
      # rarely reps are in u
      of:=First(c,
        x->ForAny(GeneratorsOfGroup(g),y->not Representative(x)^y in u));
    fi;
    if MemoryUsage(Representative(of))*Size(of)
      # if a single class only requires
      <10000
      # for element storage, just store its elements
      then
      of:=Orbit(auo,claselms(of),OnSets);
    elif preproc<>fail then
      of:=List(Orbit(auo,preproc(of),action),postproc);
    else
      of:=Orbit(auo,of,action);
    fi;
    Info(InfoMorph,4,"Genclass orbit ",Length(of)," size ",Sum(of,Size));
    Append(o,of);
    u:=ClosureGroup(u,List(of,Representative));
    u:=NormalClosure(g,u);
  od;

  bestdeg:=Sum(o,Size);
  Info(InfoMorph,4,"Generators degree ",bestdeg);
  store:=o;
  best:=[function() return Union(List(store,claselms));end,OnPoints];
  if bestdeg<baddegree then
    hom:=ActionHomomorphism(au,Union(List(o,claselms)),"surjective");
    finish(hom); return;
  fi;

  # fuse classes under g
  if actbase<>fail then
    if HasConjugacyClasses(g) then
      cl:=Filtered(ConjugacyClasses(g),x->ForAny(actbase,y->Representative(x) in y));
    else
      cl:=Concatenation(List(actbase,x->Filtered(ConjugacyClasses(x),y->Order(Representative(y))>1)));

      o:=cl;
      cl:=[];
      for i in o do
# test to avoid duplicates is more expensive than it is worth
#        if not ForAny(cl,x->Order(Representative(i))=Order(Representative(x))
#          and (Size(x) mod Size(i)=0) and Representative(i) in x) then
          r:=ConjugacyClass(g,Representative(i));
          Add(cl,r);
#        fi;
      od;

      Info(InfoMorph,2,"actbase ",Length(cl), " classes");
    fi;
  else
    cl:=ShallowCopy(ConjugacyClasses(g));
    Info(InfoMorph,2,Length(cl)," classes");
  fi;
  SortBy(cl,Size);

  # split classes in patterns
  o:=[];
  offset:=0; # degree that comes for minimum generating just factor
  i:=First([1..Length(cl)],x->not Representative(cl[x]) in ser[pos]);
  while i<>fail do
    r:=[Order(Representative(cl[i])),Size(cl[i])];
    u:=Filtered([1..Length(cl)],
      x->[Order(Representative(cl[x])),Size(cl[x])]=r and not Representative(cl[x]) in ser[pos]);
    c:=cl{u};
    cl:=cl{Difference([1..Length(cl)],u)};
    if Length(c)>0
      # no need to process classes that will not improve
      and Size(c[1])<bestdeg-offset then
      if Length(c)>1 then
        if Size(c[1])<250 and
          MemoryUsage(Representative(c[1]))*Size(c[1])*Length(c)
          # at most
          <10^7
          # bytes storage
          then
          c:=List(c,claselms);
          Sort(c);
          Info(InfoMorph,4,"Element sets");
          if actbase<>fail then
            of:=Orbits(auo,c,OnSets); # not necc. domain
          else
            of:=OrbitsDomain(auo,c,OnSets);
          fi;
        else
          if actbase<>fail then
            if preproc<>fail then
              of:=List(Orbits(auo,List(c,preproc),action),
                x->List(x,postproc));
            else
              of:=Orbits(auo,c,action); # not necc. domain
            fi;
          else
            if preproc<>fail then
              of:=List(OrbitsDomain(auo,List(c,preproc),action),
                x->List(x,postproc));
            else
              of:=OrbitsDomain(auo,c,action);
            fi;
          fi;
        fi;
      else
        of:=[c];
      fi;
      u:=List(of,x->rec(siz:=Size(x[1])*Length(x),clas:=x,reps:=[Representative(x[1])],
        closure:=NormalClosure(g,SubgroupNC(g,
          Concatenation(List(x,Representative),fix))) ));
      of:=[];
      for j in u do
        if j.siz>1 and j.siz<bestdeg
            and ForAll(o,x->x.siz>j.siz or x.closure<>j.closure)
            and ForAll(of,x->x.siz>j.siz or x.closure<>j.closure) then
          Add(of,j);
        fi;
      od;


      of:=Filtered(of,x->x.siz<bestdeg and x.siz>1);

      Info(InfoMorph,4,"Local ",Length(of)," orbits from ",Length(c),
        " sizes=",Collected(List(of,x->x.siz)));

      # combine with previous
      u:=[];
      for j in o do
        for r in of do
          if j.siz+r.siz<bestdeg
            and not ForAny(j.reps,x-> x in r.closure)
            and not ForAny(r.reps,x-> x in j.closure)
              then
                new:=rec(siz:=j.siz+r.siz,clas:=Concatenation(j.clas,r.clas),
                  reps:=Concatenation(j.reps,r.reps),
                  closure:=ClosureGroup(j.closure,r.closure));
                # don't add if known closure but no better price
                if ForAll(o,x->x.siz>new.siz or x.closure<>new.closure)
                    and ForAll(of,x->x.siz>new.siz or x.closure<>new.closure)
                    and ForAll(u,x->x.siz>new.siz or x.closure<>new.closure)
                     then
                  Add(u,new);
                fi;
          fi;
        od;
      od;
      Append(of,u);

      SortBy(of,x->x.siz);

      u:=First(of,x->Size(x.closure)=Size(g));

      if u<>fail and u.siz<bestdeg then
        if u.siz<baddegree then
          hom:=ActionHomomorphism(au,Union(List(u.clas,claselms)),"surjective");
          finish(hom); return;
        else
          store:=u;
          best:=[function() return Union(List(store.clas,claselms));end,
            OnPoints];
          bestdeg:=u.siz;
          Info(InfoMorph,4,"Improved bestdeg to ",bestdeg);
        fi;
      fi;

      Append(o,of);
      SortBy(o,x->x.siz);
    fi;

    i:=First([1..Length(cl)],x->not Representative(cl[x]) in ser[pos]);
    while i=fail and bestdeg>10*baddegree and pos<Length(ser) do
      u:=First(o,x->Size(ClosureGroup(ser[pos],x.closure))=Size(g));
      if u<>fail then
        offset:=u.siz;
      fi;
      pos:=pos+1;
      i:=First([1..Length(cl)],x->not Representative(cl[x]) in ser[pos]);
      if (bestdeg-offset)/bestdeg<
      # don't bother if all but
        1/4
      # of the points are needed anyhow for the factor. In that case abort
      then  i:=fail;
      fi;

    od;
  od;

  Info(InfoMorph,3,Length(o)," class orbits");

  if Size(SolvableRadical(g))=1 and IsNonabelianSimpleGroup(Socle(g)) then
    Info(InfoMorph,2,"Try ARG");
    img:=AutomorphismRepresentingGroup(g,GeneratorsOfGroup(au));
    # make a hom from auts to perm group
    ran:=Image(img[2],g);
    deg:=NrMovedPoints(ran);
    if deg<bestdeg then
      bestdeg:=deg;
      r:=List(GeneratorsOfGroup(g),i->Image(img[2],i));
      store:=[ran,r];
      hom:=GroupHomomorphismByFunction(au,img[1],
        function(auto)
          if IsInnerAutomorphism(auto) then
            return Image(img[2],ConjugatorOfConjugatorIsomorphism(auto));
          fi;
          return RepresentativeAction(img[1],store[2],
                    List(GeneratorsOfGroup(g),i->Image(img[2],Image(auto,i))),
                    OnTuples);
        end,
        function(perm)
          if perm in store[1] then
            return ConjugatorAutomorphismNC(g,
                      PreImagesRepresentative(img[2],perm));
          fi;
          return GroupHomomorphismByImagesNC(g,g,GeneratorsOfGroup(g),
                    List(store[2],i->PreImagesRepresentative(img[2],i^perm)));
        end);
      if bestdeg<baddegree then
        finish(hom); return;
      fi;
      best:=hom;
    fi;
  fi;

  # try to embed into wreath according to non-conjugator
  if IsPermGroup(g) then
    img:=AutomorphismWreathEmbedding(au,g);
  else
    img:=fail;
  fi;
  if img<>fail and NrMovedPoints(img[4])<bestdeg then
    Info(InfoMorph,2,"AWE succeeds");
    # make a hom from auts to perm group
    ran:=img[4];
    deg:=NrMovedPoints(ran);
    bestdeg:=deg;
    r:=List(GeneratorsOfGroup(g),i->Image(img[3],i));
    store:=[img[1],img[2],img[3],r,ran];
    hom:=GroupHomomorphismByFunction(au,img[1],
      function(auto)
        if IsConjugatorAutomorphism(auto) and
          ConjugatorOfConjugatorIsomorphism(auto) in Source(store[2]) then
          return Image(store[2],ConjugatorOfConjugatorIsomorphism(auto));
        fi;
        return RepresentativeAction(store[1],store[4],
                  List(GeneratorsOfGroup(g),i->Image(img[3],Image(auto,i))),OnTuples);
      end,
      function(perm)
        if perm in store[5] then
          return ConjugatorAutomorphismNC(g,
                    PreImagesRepresentative(store[2],perm));
        fi;
        return GroupHomomorphismByImagesNC(g,g,GeneratorsOfGroup(g),
                  List(store[4],i->PreImagesRepresentative(store[3],i^perm)));
      end);
    if bestdeg<baddegree then
      finish(hom); return;
    fi;
    best:=hom;
  fi;

  # if no centre and permgroup, try to blow up perm rep
  if Size(Centre(g))=1 and IsPermGroup(g) then

    orbs:=List(Orbits(g,MovedPoints(g)),Set);
    SortBy(orbs,Length);

    # we act on lists of [orbits,group]. This way comparison becomes
    # cheap, as typically the orbits suffice to identify

    if IsPermGroup(g) then
      action:=function(obj,hom)
              local img;
                img:=Image(hom,obj[2]);
                SetSize(img,Size(obj[2]));
                return Immutable([OrbitsMovedPoints(img),img]);
              end;
    else
      action:=function(sub,autom)
        local img;
        img:=Image(autom,sub);
        SetSize(img,Size(sub));
        return img;
      end;
    fi;

    for o in orbs do
      r:=Stabilizer(g,o,OnTuples);
      if hom=fail and #have not yet found any
        not ForAll(GeneratorsOfGroup(au),x->Image(x,r)=r or
        Difference(MovedPoints(g),MovedPoints(Image(x,r))) in orbs) then
        u:=Size(r);
        r:=Subgroup(Parent(r),SmallGeneratingSet(r));
        SetSize(r,u);
        if IsPermGroup(g) then
          r:=Orbit(au,Immutable([OrbitsMovedPoints(r),r]),action);
          r:=List(r,x->x[2]);
        else
          r:=Orbit(au,r,action);
        fi;

        u:=Stabilizer(g,o[1]);
        if Size(Intersection(r))=1 and
          # this orbit and automorphism images represent all of g, so can
          # be used to represent automorphisms
          u=Normalizer(g,u) then
          # point stabilizer is self-normalizing, so action on
          # cosets=action by conjugation
          u:=Group(SmallGeneratingSet(u));
          if IsPermGroup(g) then
            u:=Orbit(au,Immutable([OrbitsMovedPoints(u),u]),action);
          else
            u:=Orbit(au,u,action);
          fi;
          deg:=Length(u);
          if deg<bestdeg then
            bestdeg:=deg;
            if bestdeg<baddegree then
              hom:=ActionHomomorphism(au,u,action,"surjective");
              finish(hom); return;
            fi;
            store:=u;
            best:=[function() return store;end,action];
          fi;

        fi;
      fi;
    od;
  fi;

#if bestdeg>10*baddegree then Error("bad degree");fi;

  Info(InfoMorph,1,"Go back to best rep so far ",bestdeg);
  # go back to what we had before
  if IsList(best) then
    hom:=ActionHomomorphism(au,best[1](),best[2],"surjective");
  else
    hom:=best;
  fi;
  finish(hom);return;

#  # fall back on element sets
#  Info(InfoMorph,1,"General Case");
#
#
#  # general case: compute small domain
#  gens:=[];
#  dom:=[];
#  u:=TrivialSubgroup(g);
#  subs:=[];
#  orbs:=[];
#  while Size(u)<Size(g) do
#    # find a reasonable element
#    cnt:=0;
#    br:=false;
#    bv:=0;
#
#    # use classes from before --
#    #if HasConjugacyClasses(g) then
#    for r in cl do
#      if IsPrimePowerInt(Order(Representative(r))) and
#          not Representative(r) in  u then
#        v:=ClosureGroup(u,Representative(r));
#        if allinner then
#          val:=Size(Centralizer(r))*Size(NormalClosure(g,v));
#        else
#          val:=Size(Centralizer(r))*Size(v);
#        fi;
#        if val>bv then
#          br:=Representative(r);
#          bv:=val;
#        fi;
#      fi;
#    od;
#
##    else
##      if actbase=fail then
###        actbase:=[g];
##      fi;
##      repeat
##        cnt:=cnt+1;
##        repeat
##          r:=Random(Random(actbase));
##        until not r in u;
##        # force small prime power order
##        if not IsPrimePowerInt(Order(r)) then
##          v:=List(Collected(Factors(Order(r))),x->r^(x[1]^x[2]));
##          v:=Filtered(v,x->not x in u);;
##          v:=List(v,x->x^First(Reversed(DivisorsInt(Order(x))),
##            y->not x^y in u)); # small order power not in u
##          SortBy(v,Order);
##          r:=First(v,x->not x in u); # if all are in u, r would be as well
##        fi;
##
##        v:=ClosureGroup(u,r);
##        #if allinner then
##        #  val:=Size(Centralizer(g,r))*Size(NormalClosure(g,v));
##        #else
##          val:=Size(Centralizer(g,r));
##        #fi;
##        if val>bv then
##          br:=r;
##          bv:=val;
##        fi;
##      until bv>Size(g)/2^Int(cnt/50);
##    fi;
#
#    r:=br;
#    Info(InfoMorph,4,"Element class length ",Index(g,Centralizer(g,r))," after ",cnt);
#
#    #if Index(g,Centralizer(g,r))>2*10^4 then Error("big degree debug");fi;
#
#    if allinner then
#      u:=NormalClosure(g,ClosureGroup(u,r));
#    else
#      u:=ClosureGroup(u,r);
#    fi;
#
#    #calculate orbit and closure
#    o:=Orbit(au,r);
#    v:=TrivialSubgroup(g);
#    i:=1;
#    while i<=Length(o) do
#      if not o[i] in v then
#        if allinner then
#          v:=NormalClosure(g,ClosureGroup(v,o[i]));
#        else
#          v:=ClosureGroup(v,o[i]);
#        fi;
#        if Size(v)=Size(g) then
#          i:=Length(o);
#        fi;
#      fi;
#      i:=i+1;
#    od;
#    u:=ClosureGroup(u,v);
#
#    i:=1;
#    while Length(o)>0 and i<=Length(subs) do
#      if IsSubset(subs[i],v) then
#        o:=[];
#      elif IsSubset(v,subs[i]) then
#        subs[i]:=v;
#        orbs[i]:=o;
#        gens[i]:=r;
#        o:=[];
#      fi;
#      i:=i+1;
#    od;
#    if Length(o)>0 then
#      Add(subs,v);
#      Add(orbs,o);
#      Add(gens,r);
#    fi;
#  od;
#
#  # now find the smallest subset of domains
#  comb:=Filtered(Combinations([1..Length(subs)]),i->Length(i)>0);
#  bv:=infinity;
#  for i in comb do
#    val:=Sum(List(orbs{i},Length));
#    if val<bv then
#      v:=subs[i[1]];
#      for r in [2..Length(i)] do
#        v:=ClosureGroup(v,subs[i[r]]);
#      od;
#      if Size(v)=Size(g) then
#        best:=i;
#        bv:=val;
#      fi;
#    fi;
#  od;
#  gens:=gens{best};
#  dom:=Union(orbs{best});
#  Unbind(orbs);
#
#  if Length(dom)>bestdeg then
#    # go back to what we had before
#    if IsList(best) then
#      hom:=ActionHomomorphism(au,best[1](),best[2],"surjective");
#    else
#      hom:=best;
#    fi;
#    finish(hom);return;
#  fi;
#
#  u:=SubgroupNC(g,gens);
#  while Size(u)<Size(g) do
#    repeat
#      r:=Random(dom);
#    until not r in u;
#    Add(gens,r);
#    u:=ClosureSubgroupNC(u,r);
#  od;
#  Info(InfoMorph,1,"Found generating set of ",Length(gens)," elements",
#        List(gens,Order));
#  hom:=NiceMonomorphismAutomGroup(au,dom,gens);
#
#  finish(hom);
#
end);

#############################################################################
##
#F  NiceMonomorphismAutomGroup
##
InstallGlobalFunction(NiceMonomorphismAutomGroup,
function(aut,elms,elmsgens)
local xset,fam,hom;
  One(aut); # to avoid infinite recursion once the niceo is set

  elmsgens:=Filtered(elmsgens,i->i in elms); # safety feature
  #if Size(Group(elmsgens))<>Size(Source(One(aut))) then Error("holler1"); fi;
  xset:=ExternalSet(aut,elms);
  SetBaseOfGroup(xset,elmsgens);
  fam := GeneralMappingsFamily( ElementsFamily( FamilyObj( aut ) ),
                                PermutationsFamily );
  hom := rec(  );
  hom:=Objectify(NewType(fam,
                IsActionHomomorphismAutomGroup and IsSurjective ),hom);
  SetIsInjective(hom,true);
  SetUnderlyingExternalSet( hom, xset );
  hom!.basepos:=List(elmsgens,i->Position(elms,i));
  SetRange( hom, Image( hom ) );
  Setter(SurjectiveActionHomomorphismAttr)(xset,hom);
  Setter(IsomorphismPermGroup)(aut,ActionHomomorphism(xset,"surjective"));
  hom:=ActionHomomorphism(xset,"surjective");
  SetFilterObj(hom,IsNiceMonomorphism);
  return hom;

end);

#############################################################################
##
#M  PreImagesRepresentative   for OpHomAutomGrp
##
InstallMethod(PreImagesRepresentative,"AutomGroup Niceomorphism",
  FamRangeEqFamElm,[IsActionHomomorphismAutomGroup,IsPerm],0,
function(hom,elm)
local xset,g,imgs;
  xset:= UnderlyingExternalSet( hom );
  g:=Source(One(ActingDomain(xset)));
  imgs:=OnTuples(hom!.basepos,elm);
  imgs:=Enumerator(xset){imgs};
  #if g<>Group(BaseOfGroup(xset)) then Error("holler"); fi;
  elm:=GroupHomomorphismByImagesNC(g,g,BaseOfGroup(xset),imgs);
  SetIsBijective(elm,true);
  return elm;
end);


#############################################################################
##
#F  MorFroWords(<gens>) . . . . . . create some pseudo-random words in <gens>
##                                                featuring the MeatAxe's FRO
InstallGlobalFunction(MorFroWords,function(gens)
local list,a,b,ab,i;
  list:=[];
  ab:=gens[1];
  for i in [2..Length(gens)] do
    a:=ab;
    b:=gens[i];
    ab:=a*b;
    list:=Concatenation(list,
         [ab,ab^2*b,ab^3*b,ab^4*b,ab^2*b*ab^3*b,ab^5*b,ab^2*b*ab^3*b*ab*b,
         ab*(ab*b)^2*ab^3*b,a*b^4*a,ab*a^3*b]);
  od;
  return list;
end);


#############################################################################
##
#F  MorRatClasses(<G>) . . . . . . . . . . . local rationalization of classes
##
InstallGlobalFunction(MorRatClasses,function(GR)
local r,c,u,j,i;
  Info(InfoMorph,2,"RationalizeClasses");
  r:=[];
  for c in RationalClasses(GR) do
    u:=Subgroup(GR,[Representative(c)]);
    j:=DecomposedRationalClass(c);
    Add(r,rec(representative:=u,
                class:=j[1],
                classes:=j,
                size:=Size(c)));
  od;

  for i in r do
    i.size:=Sum(i.classes,Size);
  od;
  return r;
end);

#############################################################################
##
#F  MorMaxFusClasses(<l>) . .  maximal possible morphism fusion of classlists
##
InstallGlobalFunction(MorMaxFusClasses,function(r)
local i,j,flag,cl;
  # cl is the maximal fusion among the rational classes.
  cl:=[];
  for i in r do
    j:=0;
    flag:=true;
    while flag and j<Length(cl) do
      j:=j+1;
      flag:=not(Size(i.class)=Size(cl[j][1].class) and
                  i.size=cl[j][1].size and
                  Size(i.representative)=Size(cl[j][1].representative));
    od;
    if flag then
      Add(cl,[i]);
    else
      Add(cl[j],i);
    fi;
  od;

  # sort classes by size
  SortBy(cl,a->Sum(a,i->i.size));
  return cl;
end);

#############################################################################
##
#F  SomeVerbalSubgroups
##
## correspond simultaneously some verbal subgroups in g and h
BindGlobal("SomeVerbalSubgroups",function(g,h)
local l,m,i,j,cg,ch,pg;
  l:=[g];
  m:=[h];
  i:=1;
  while i<=Length(l) do
    for j in [1..i] do
      cg:=CommutatorSubgroup(l[i],l[j]);
      ch:=CommutatorSubgroup(m[i],m[j]);
      pg:=Position(l,cg);
      if pg=fail then
        Add(l,cg);
        Add(m,ch);
      else
        while m[pg]<>ch do
          pg:=Position(l,cg,pg+1);
          if pg=fail then
            Add(l,cg);
            Add(m,ch);
            pg:=Length(m);
          fi;
        od;
      fi;
    od;
    i:=i+1;
  od;
  return [l,m];
end);

#############################################################################
##
#F  MorClassLoop(<range>,<classes>,<params>,<action>)  loop over classes list
##     to find generating sets or Iso/Automorphisms up to inner automorphisms
##
##  classes is a list of records like the ones returned from
##  MorMaxFusClasses.
##
##  params is a record containing optional components:
##  gens  generators that are to be mapped
##  from  preimage group (that contains gens)
##  to    image group (as it might be smaller than 'range')
##  free  free generators
##  rels  some relations that hold in from, given as list [word,order]
##  dom   a set of elements on which automorphisms act faithful
##  aut   Subgroup of already known automorphisms
##  condition function that must return `true' on the homomorphism.
##  setrun  If set to true approximate a run through sets by having the
##          class indices increasing.
##
##  action is a number whose bit-representation indicates the action to be
##  taken:
##  1     homomorphism
##  2     injective
##  4     surjective
##  8     find all (in contrast to one)
##
BindGlobal( "MorClassOrbs", function(G,C,R,D)
local i,cl,cls,rep,x,xp,p,b,g;
  i:=Index(G,C);
  if i>20000 or i<Size(D) then
    return List(DoubleCosetRepsAndSizes(G,C,D),j->j[1]);
  else
    if not IsBound(C!.conjclass) then
      cl:=[R];
      cls:=[R];
      rep:=[One(G)];
      i:=1;
      while i<=Length(cl) do
        for g in GeneratorsOfGroup(G) do
          x:=cl[i]^g;
          if not x in cls then
            Add(cl,x);
            AddSet(cls,x);
            Add(rep,rep[i]*g);
          fi;
        od;
        i:=i+1;
      od;
      SortParallel(cl,rep);
      C!.conjclass:=cl;
      C!.conjreps:=rep;
    fi;
    cl:=C!.conjclass;
    rep:=[];
    b:=BlistList([1..Length(cl)],[]);
    p:=1;
    repeat
      while p<=Length(cl) and b[p] do
        p:=p+1;
      od;
      if p<=Length(cl) then
        b[p]:=true;
        Add(rep,p);
        cls:=[cl[p]];
        for i in cls do
          for g in GeneratorsOfGroup(D) do
            x:=i^g;
            xp:=PositionSorted(cl,x);
            if not b[xp] then
              Add(cls,x);
              b[xp]:=true;
            fi;
          od;
        od;
      fi;
      p:=p+1;
    until p>Length(cl);

    return C!.conjreps{rep};
  fi;
end );

InstallGlobalFunction(MorClassLoop,function(range,clali,params,action)
local id,result,rig,dom,tall,tsur,tinj,thom,gens,free,rels,len,ind,cla,m,
      mp,cen,i,j,imgs,ok,size,l,hom,cenis,reps,repspows,sortrels,genums,wert,p,
      e,offset,pows,TestRels,pop,mfw,derhom,skip,cond,outerorder,setrun,
      finsrc;

  finsrc:=IsBound(params.from) and HasIsFinite(params.from)
          and IsFinite(params.from);
  len:=Length(clali);
  if ForAny(clali,i->Length(i)=0) then
    return []; # trivial case: no images for generator
  fi;

  id:=One(range);
  if IsBound(params.aut) then
    result:=params.aut;
    rig:=true;
    if IsBound(params.dom) then
      dom:=params.dom;
    else
      dom:=false;
    fi;
  else
    result:=[];
    rig:=false;
  fi;

  if IsBound(params.outerorder) then
    outerorder:=params.outerorder;
  else
    outerorder:=false;
  fi;

  if IsBound(params.setrun) then
    setrun:=params.setrun;
  else
    setrun:=false;
  fi;


  # extra condition?
  if IsBound(params.condition) then
    cond:=params.condition;
  else
    cond:=fail;
  fi;

  tall:=action>7; # try all
  if tall then
    action:=action-8;
  fi;
  derhom:=fail;
  tsur:=action>3; # test surjective
  if tsur then
    size:=Size(params.to);
    action:=action-4;
    if Index(range,DerivedSubgroup(range))>1 then
      derhom:=NaturalHomomorphismByNormalSubgroup(range,DerivedSubgroup(range));
    fi;
  fi;
  tinj:=action>1; # test injective
  if tinj then
    action:=action-2;
  fi;
  thom:=action>0; # test homomorphism

  if IsBound(params.gens) then
    gens:=params.gens;
  fi;

  if IsBound(params.rels) then
    free:=params.free;
    rels:=params.rels;
    if Length(rels)=0 then
      rels:=false;
    fi;
  elif thom then
    free:=GeneratorsOfGroup(FreeGroup(Length(gens)));
    mfw:=MorFroWords(free);
    # get some more
    if finsrc and Product(List(gens,Order))<2000 then
      for i in Cartesian(List(gens,i->[1..Order(i)])) do
        Add(mfw,Product(List([1..Length(gens)],z->free[z]^i[z])));
      od;
    fi;
    rels:=[];
    for i in mfw do
      p:=Order(MappedWord(i,free,gens));
      if p<>infinity then
        Add(rels,[i,p]);
      fi;
    od;
    if Length(rels)=0 then
      rels:=false;
    fi;
  else
    rels:=false;
  fi;

  pows:=[];
  if rels<>false then
    # sort the relators according to the generators they contain
    genums:=List(free,i->GeneratorSyllable(i,1));
    genums:=List([1..Length(genums)],i->Position(genums,i));
    sortrels:=List([1..len],i->[]);
    pows:=List([1..len],i->[]);
    for i in rels do
      l:=len;
      wert:=0;
      m:=[];
      for j in [1..NrSyllables(i[1])] do
        p:=genums[GeneratorSyllable(i[1],j)];
        e:=ExponentSyllable(i[1],j);
        Append(m,[p,e]); # modified extrep
        AddSet(pows[p],e);
        if p<len then
          wert:=wert+2; # conjugation: 2 extra images
          l:=Minimum(l,p);
        fi;
        wert:=wert+AbsInt(e);
      od;
      Add(sortrels[l],[m,i[2],i[2]*wert,[1,3..Length(m)-1],i[1]]);
    od;
    # now sort by the length of the relators
    for i in [1..len] do
      SortBy(sortrels[i],x->x[3]);
    od;
    if Length(pows)>0 then
      offset:=1-Minimum(List(Filtered(pows,i->Length(i)>0),
                            i->i[1])); # smallest occurring index
    fi;
    # test the relators at level tlev and set imgs
    TestRels:=function(tlev)
    local rel,k,j,p,start,gn,ex;

      if Length(sortrels[tlev])=0 then
        imgs:=List([tlev..len-1],i->reps[i]^(m[i][mp[i]]));
        imgs[Length(imgs)+1]:=reps[len];
        return true;
      fi;

      if IsPermGroup(range) then
        # test by tracing points
        for rel in sortrels[tlev] do
          start:=1;
          p:=start;
          k:=0;
          repeat
            for j in rel[4] do
              gn:=rel[1][j];
              ex:=rel[1][j+1];
              if gn=len then
                p:=p^repspows[gn][ex+offset];
              else
                p:=p/m[gn][mp[gn]];
                p:=p^repspows[gn][ex+offset];
                p:=p^m[gn][mp[gn]];
              fi;
            od;
            k:=k+1;
          # until we have the power or we detected a smaller potential order.
          until k>=rel[2] or (p=start and IsInt(rel[2]/k));
          if p<>start then
            return false;
          fi;
        od;
      fi;

      imgs:=List([tlev..len-1],i->reps[i]^(m[i][mp[i]]));
      imgs[Length(imgs)+1]:=reps[len];

      if tinj then
        return ForAll(sortrels[tlev],i->i[2]=Order(MappedWord(i[5],
                                      free{[tlev..len]}, imgs)));
      else
        return ForAll(sortrels[tlev],
                      i->IsInt(i[2]/Order(MappedWord(i[5],
                                          free{[tlev..len]}, imgs))));
      fi;

    end;
  else
    TestRels:=x->true; # to satisfy the code below.
  fi;

  pop:=false; # just to initialize

  # backtrack over all classes in clali
  l:=ListWithIdenticalEntries(len,1);
  ind:=len;
  while ind>0 do
    ind:=len;
    Info(InfoMorph,3,"step ",l);
    # test class combination indicated by l:
    cla:=List([1..len],i->clali[i][l[i]]);
    reps:=List(cla,Representative);
    skip:=false;
    if derhom<>fail then
      if not Size(Group(List(reps,i->Image(derhom,i))))=Size(Image(derhom)) then
#T The group `Image( derhom )' is abelian but initially does not know this;
#T shouldn't this be set?
#T Then computing the size on the l.h.s. may be sped up using `SubgroupNC'
#T w.r.t. the (abelian) group.
        skip:=true;
        Info(InfoMorph,3,"skipped");
      fi;
    fi;

    if pows<>fail and not skip then
      if rels<>false and IsPermGroup(range) then
        # and precompute the powers
        repspows:=List([1..len],i->[]);
        for i in [1..len] do
          for j in pows[i] do
            repspows[i][j+offset]:=reps[i]^j;
          od;
        od;
      fi;

      #cenis:=List(cla,i->Intersection(range,Centralizer(i)));
      # make sure we get new groups (we potentially add entries)
      cenis:=[];
      for i in cla do
        cen:=Intersection(range,Centralizer(i));
        if IsIdenticalObj(cen,Centralizer(i)) then
          m:=Size(cen);
          cen:=SubgroupNC(range,GeneratorsOfGroup(cen));
          SetSize(cen,m);
        fi;
        Add(cenis,cen);
      od;

      # test, whether a gen.sys. can be taken from the classes in <cla>
      # candidates.  This is another backtrack
      m:=[];
      m[len]:=[id];
      # positions
      mp:=[];
      mp[len]:=1;
      mp[len+1]:=-1;
      # centralizers
      cen:=[];
      cen[len]:=cenis[len];
      cen[len+1]:=range; # just for the recursion
      i:=len-1;

      # set up the lists
      while i>0 do
        #m[i]:=List(DoubleCosetRepsAndSizes(range,cenis[i],cen[i+1]),j->j[1]);
        m[i]:=MorClassOrbs(range,cenis[i],reps[i],cen[i+1]);
        mp[i]:=1;

        pop:=true;
        while pop and i<=len do
          pop:=false;
          while mp[i]<=Length(m[i]) and TestRels(i)=false do
            mp[i]:=mp[i]+1; #increment because of relations
            Info(InfoMorph,4,"early break ",i);
          od;
          if i<=len and mp[i]>Length(m[i]) then
            Info(InfoMorph,3,"early pop");
            pop:=true;
            i:=i+1;
            if i<=len then
              mp[i]:=mp[i]+1; #increment because of pop
            fi;
          fi;
        od;

        if pop then
          i:=-99; # to drop out of outer loop
        elif i>1 then
          cen[i]:=Centralizer(cen[i+1],reps[i]^(m[i][mp[i]]));
        fi;
        i:=i-1;
      od;

      if pop then
        Info(InfoMorph,3,"allpop");
        i:=len+2; # to avoid the following `while' loop
      else
        i:=1;
        Info(InfoMorph,3,"loop");
      fi;

      while i<len do
        if rels=false or TestRels(1) then
          if rels=false then
            # otherwise the images are set by `TestRels' as a side effect.
            imgs:=List([1..len-1],i->reps[i]^(m[i][mp[i]]));
            imgs[len]:=reps[len];
          fi;
          Info(InfoMorph,4,"orders: ",List(imgs,Order));

          # computing the size can be nasty. Thus try given relations first.
          ok:=true;

          if rels<>false then
            if tinj then
              ok:=ForAll(rels,i->i[2]=Order(MappedWord(i[1],free,imgs)));
            else
              ok:=ForAll(rels,i->IsInt(i[2]/Order(MappedWord(i[1],free,imgs))));
            fi;
          fi;

          # check surjectivity
          if tsur and ok then
            ok:= Size( SubgroupNC( range, imgs ) ) = size;
          fi;

          if ok and thom then
            Info(InfoMorph,3,"testing");
            imgs:=GroupGeneralMappingByImagesNC(params.from,range,gens,imgs);
            SetIsTotal(imgs,true);
            if tsur then
              SetIsSurjective(imgs,true);
            fi;
            ok:=IsSingleValued(imgs);
            if ok and tinj then
              ok:=IsInjective(imgs);
            fi;
          fi;

          if ok and cond<>fail then
            ok:=cond(imgs);
          fi;

          if ok then
            Info(InfoMorph,2,"found");
            # do we want one or all?
            if tall then
              if rig then
                if not imgs in result then
                  result:= GroupByGenerators( Concatenation(
                              GeneratorsOfGroup( result ), [ imgs ] ),
                              One( result ) );
                  # note its niceo
                  hom:=NiceMonomorphismAutomGroup(result,dom,gens);
                  SetNiceMonomorphism(result,hom);
                  SetIsHandledByNiceMonomorphism(result,true);

                  Size(result);
                  Info(InfoMorph,2,"new ",Size(result));
                fi;
              else
                Add(result,imgs);
                # can we deduce we got all?
                if outerorder<>false and Lcm(Concatenation([1],List(
                  Filtered(result,x->not IsInnerAutomorphism(x)),
                  x->First([2..outerorder],y->IsInnerAutomorphism(x^y)))))
                    =outerorder
                  then
                    Info(InfoMorph,1,"early break");
                    return result;
                fi;
              fi;
            else
              return imgs;
            fi;
          fi;
        fi;

        mp[i]:=mp[i]+1;
        while i<=len and mp[i]>Length(m[i]) do
          mp[i]:=1;
          i:=i+1;
          if i<=len then
            mp[i]:=mp[i]+1;
          fi;
        od;

        while i>1 and i<=len do
          while i<=len and TestRels(i)=false do
            Info(InfoMorph,4,"intermediate break ",i);
            mp[i]:=mp[i]+1;
            while i<=len and mp[i]>Length(m[i]) do
              Info(InfoMorph,3,"intermediate pop ",i);
              i:=i+1;
              if i<=len then
                mp[i]:=mp[i]+1;
              fi;
            od;
          od;

          if i<=len then # i>len means we completely popped. This will then
                        # also pop us out of both `while' loops.
            cen[i]:=Centralizer(cen[i+1],reps[i]^(m[i][mp[i]]));
            i:=i-1;
            #m[i]:=List(DoubleCosetRepsAndSizes(range,cenis[i],cen[i+1]),j->j[1]);
            m[i]:=MorClassOrbs(range,cenis[i],reps[i],cen[i+1]);
            mp[i]:=1;

          else
            Info(InfoMorph,3,"allpop2");
          fi;
        od;

      od;
    fi;

    # 'free for increment'
    l[ind]:=l[ind]+1;
    while ind>0 and l[ind]>Length(clali[ind]) do
      if setrun and ind>1 then
        # if we are running through sets, approximate by having the
        # l-indices increasing
        l[ind]:=Minimum(l[ind-1]+1,Length(clali[ind]));
      else
        l[ind]:=1;
      fi;
      ind:=ind-1;
      if ind>0 then
        l[ind]:=l[ind]+1;
      fi;
    od;
  od;

  return result;
end);


#############################################################################
##
#F  MorFindGeneratingSystem(<G>,<cl>) . .  find generating system with as few
##                      as possible generators from the first classes in <cl>
##
InstallGlobalFunction(MorFindGeneratingSystem,function(arg)
local G,cl,lcl,len,comb,combc,com,a,alltwo;
  G:=arg[1];
  cl:=arg[2];
  Info(InfoMorph,1,"FindGenerators");
  # throw out the 1-Class
  cl:=Filtered(cl,i->Length(i)>1 or Size(i[1].representative)>1);
  alltwo:=PrimeDivisors(Size(G))=[2];

  #create just a list of ordinary classes.
  lcl:=List(cl,i->Concatenation(List(i,j->j.classes)));
  len:=1;
  len:=Maximum(1,AbelianRank(G)-1);
  while true do
    len:=len+1;
    Info(InfoMorph,2,"Trying length ",len);
    # now search for <len>-generating systems
    comb:=UnorderedTuples([1..Length(lcl)],len);
    combc:=List(comb,i->List(i,j->lcl[j]));

    # test all <comb>inations
    com:=0;
    while com<Length(comb) do
      com:=com+1;
      # don't try only order 2 generators unless it's a 2-group
      if Set(Flat(combc[com]),i->Order(Representative(i)))<>[2] or
        alltwo then
        a:=MorClassLoop(G,combc[com],rec(to:=G),4);
        if Length(a)>0 then
          return a;
        fi;
      fi;
    od;
  od;
end);

#############################################################################
##
#F  Morphium(<G>,<H>,<DoAuto>) . . . . . . . .Find isomorphisms between G and H
##       modulo inner automorphisms. DoAuto indicates whether all
##       automorphism are to be found
##       This function thus does the main combinatoric work for creating
##       Iso- and Automorphisms.
##       It needs, that both groups are not cyclic.
##
InstallGlobalFunction(Morphium,function(G,H,DoAuto)
local combi,Gr,Gcl,Ggc,Hr,Hcl,bg,bpri,x,dat,
      gens,i,c,hom,elms,price,result,inns,bcl,vsu;

  if IsSolvableGroup(G) and CanEasilyComputePcgs(G) then
    gens:=MinimalGeneratingSet(G);
  else
    gens:=SmallGeneratingSet(G);
  fi;
  Gr:=MorRatClasses(G);
  Gcl:=MorMaxFusClasses(Gr);

  Ggc:=List(gens,i->First(Gcl,j->ForAny(j,j->ForAny(j.classes,k->i in k))));
  combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
  price:=Product(combi,i->Sum(i,Size));
  Info(InfoMorph,1,"generating system ",Sum(Flat(combi),Size),
       " of price:",price,"");

  if ((not HasMinimalGeneratingSet(G) and price/Size(G)>10000)
     or Sum(Flat(combi),Size)>Size(G)/10 or IsSolvableGroup(G))
     and ValueOption("nogensyssearch")<>true then
    if IsSolvableGroup(G) then
      gens:=IsomorphismPcGroup(G);
      gens:=List(MinimalGeneratingSet(Image(gens)),
                 i->PreImagesRepresentative(gens,i));
      Ggc:=List(gens,i->First(Gcl,j->ForAny(j,j->ForAny(j.classes,k->i in k))));
      combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
      bcl:=ShallowCopy(combi);
      SortBy(bcl,a->Sum(a,Size));
      bg:=gens;
      bpri:=Product(combi,i->Sum(i,Size));
      for i in [1..7*Length(gens)-12] do
        repeat
          for c in [1..Length(gens)] do
            if Random(1,3)<2 then
              gens[c]:=Random(G);
            else
              x:=bcl[Random(Filtered([1,1,1,1,2,2,2,3,3,4],k->k<=Length(bcl)))];
              gens[c]:=Random(Random(x));
            fi;
          od;
        until Index(G,SubgroupNC(G,gens))=1;
        Ggc:=List(gens,i->First(Gcl,
                  j->ForAny(j,j->ForAny(j.classes,k->i in k))));
        combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
        Append(bcl,combi);
        SortBy(bcl,a->Sum(a,Size));
        price:=Product(combi,i->Sum(i,Size));
        Info(InfoMorph,3,"generating system of price:",price,"");
        if price<bpri then
          bpri:=price;
          bg:=gens;
        fi;
      od;

      gens:=bg;

    else
      gens:=MorFindGeneratingSystem(G,Gcl);
    fi;

    Ggc:=List(gens,i->First(Gcl,j->ForAny(j,j->ForAny(j.classes,k->i in k))));
    combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
    price:=Product(combi,i->Sum(i,Size));
    Info(InfoMorph,1,"generating system of price:",price,"");
  fi;

  if not DoAuto then
    Hr:=MorRatClasses(H);
    Hcl:=MorMaxFusClasses(Hr);
  fi;

  vsu:=SomeVerbalSubgroups(G,H);
  if List(vsu[1],Size)<>List(vsu[2],Size) then
    # cannot be candidates
    return [];
  fi;

  # now test, whether it is worth, to compute a finer congruence
  # then ALSO COMPUTE NEW GEN SYST!
  # [...]

  if not DoAuto then
    combi:=[];
    for i in Ggc do
      c:=Filtered(Hcl,
           j->Set(j,k->k.size)=Set(i,k->k.size)
                and Length(j[1].classes)=Length(i[1].classes)
                and Size(j[1].class)=Size(i[1].class)
                and Size(j[1].representative)=Size(i[1].representative)
      # This test assumes maximal fusion among the rat.classes. If better
      # congruences are used, they MUST be checked here also!
        );
      if Length(c)<>1 then
        # Both groups cannot be isomorphic, since they lead to different
        # congruences!
        Info(InfoMorph,2,"different congruences");
        return fail;
      else
        Add(combi,c[1]);
      fi;
    od;
    combi:=List(combi,i->Concatenation(List(i,i->i.classes)));
  fi;

  # filter by verbal subgroups
  for i in [1..Length(gens)] do
    c:=Filtered([1..Length(vsu[1])],j->gens[i] in vsu[1][j]);
    c:=Filtered(combi[i],k->
         c=Filtered([1..Length(vsu[2])],j->Representative(k) in vsu[2][j]));
    if Length(c)<Length(combi[i]) then
      Info(InfoMorph,1,"images improved by verbal subgroup:",
      Sum(combi[i],Size)," -> ",Sum(c,Size));
      combi[i]:=c;
    fi;
  od;

  # combi contains the classes, from which the
  # generators are taken.

  #free:=GeneratorsOfGroup(FreeGroup(Length(gens)));
  #rels:=MorFroWords(free);
  #rels:=List(rels,i->[i,Order(MappedWord(i,free,gens))]);
  #result:=rec(gens:=gens,from:=G,to:=H,free:=free,rels:=rels);
  result:=rec(gens:=gens,from:=G,to:=H);

  if DoAuto then

    inns:=List(GeneratorsOfGroup(G),i->InnerAutomorphism(G,i));
    if Sum(Flat(combi),Size)<=MORPHEUSELMS then
      elms:=[];
      for i in Flat(combi) do
        if not ForAny(elms,j->Representative(i)=Representative(j)) then
          # avoid duplicate classes
          Add(elms,i);
        fi;
      od;
      elms:=Union(List(elms,AsList));
      Info(InfoMorph,1,"permrep on elements: ",Length(elms));

      Assert(2,ForAll(GeneratorsOfGroup(G),i->ForAll(elms,j->j^i in elms)));
      result.dom:=elms;
      inns:= GroupByGenerators( inns, IdentityMapping( G ) );

      hom:=NiceMonomorphismAutomGroup(inns,elms,gens);
      SetNiceMonomorphism(inns,hom);
      SetIsHandledByNiceMonomorphism(inns,true);

      result.aut:=inns;
    else
      elms:=false;
    fi;

    # catch case of simple groups to get outer automorphism orders
    # automorphism suffices.
    if IsNonabelianSimpleGroup(H) then
      dat:=DataAboutSimpleGroup(H);
      if IsBound(dat.fullAutGroup) then
        if dat.fullAutGroup[1]=1 then
          # all automs are inner.
          result:=rec(aut:=result.aut);
        else
          result.outerorder:=dat.fullAutGroup[1];
          result:=rec(aut:=MorClassLoop(H,combi,result,15));
        fi;
      else
        result:=rec(aut:=MorClassLoop(H,combi,result,15));
      fi;
    else
      result:=rec(aut:=MorClassLoop(H,combi,result,15));
    fi;

    if elms<>false then
      result.elms:=elms;
      result.elmsgens:=Filtered(gens,i->i<>One(G));
      inns:=SubgroupNC(result.aut,GeneratorsOfGroup(inns));
    fi;
    result.inner:=inns;
  else
    result:=MorClassLoop(H,combi,result,7);
  fi;

  return result;

end);

#############################################################################
##
#F  AutomorphismGroupAbelianGroup(<G>)
##
InstallGlobalFunction(AutomorphismGroupAbelianGroup,function(G)
local i,j,k,l,m,o,nl,nj,max,r,e,au,p,gens,offs;

  # trivial case
  if Size(G)=1 then
    au:= GroupByGenerators( [], IdentityMapping( G ) );
    i:=NiceMonomorphismAutomGroup(au,[One(G)],[One(G)]);
    SetNiceMonomorphism(au,i);
    SetIsHandledByNiceMonomorphism(au,true);
    SetIsAutomorphismGroup( au, true );
    SetIsFinite(au,true);
    return au;
  fi;

  # get standard generating system
  gens:=IndependentGeneratorsOfAbelianGroup(G);

  au:=[];
  # run by primes
  p:=PrimeDivisors(Size(G));
  for i in p do
    l:=Filtered(gens,j->IsInt(Order(j)/i));
    nl:=Filtered(gens,i->not i in l);

    #sort by exponents
    o:=List(l,j->LogInt(Order(j),i));
    e:=[];
    for j in Set(o) do
      Add(e,[j,l{Filtered([1..Length(o)],k->o[k]=j)}]);
    od;

    # construct automorphisms by components
    for j in e do
      nj:=Concatenation(List(Filtered(e,i->i[1]<>j[1]),i->i[2]));
      r:=Length(j[2]);

      # the permutations and addition
      if r>1 then
        Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
            #(1,2)
            Concatenation(nl,nj,j[2]{[2]},j[2]{[1]},j[2]{[3..Length(j[2])]})));
        Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
            #(1,..,n)
            Concatenation(nl,nj,j[2]{[2..Length(j[2])]},j[2]{[1]})));
        #for k in [0..j[1]-1] do
        k:=0;
          Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
              #1->1+i^k*2
              Concatenation(nl,nj,[j[2][1]*j[2][2]^(i^k)],
                                  j[2]{[2..Length(j[2])]})));
        #od;
      fi;

      # multiplications

      for k in List( Flat( GeneratorsPrimeResidues(i^j[1])!.generators ),
              Int )  do

        Add(au,GroupHomomorphismByImagesNC(G,G,Concatenation(nl,nj,j[2]),
            #1->1^k
            Concatenation(nl,nj,[j[2][1]^k],j[2]{[2..Length(j[2])]})));
      od;

    od;

    # the mixing ones
    for j in [1..Length(e)] do
      for k in [1..Length(e)] do
        if k<>j then
          nj:=Concatenation(List(e{Difference([1..Length(e)],[j,k])},i->i[2]));
          offs:=Maximum(0,e[k][1]-e[j][1]);
          if Length(e[j][2])=1 and Length(e[k][2])=1 then
            max:=Minimum(e[j][1],e[k][1])-1;
          else
            max:=0;
          fi;
          for m in [0..max] do
            Add(au,GroupHomomorphismByImagesNC(G,G,
               Concatenation(nl,nj,e[j][2],e[k][2]),
               Concatenation(nl,nj,[e[j][2][1]*e[k][2][1]^(i^(offs+m))],
                                    e[j][2]{[2..Length(e[j][2])]},e[k][2])));
          od;
        fi;
      od;
    od;
  od;

  if IsFpGroup(G) and IsWholeFamily(G) then
    # rewrite to standard generators
    gens:=GeneratorsOfGroup(G);
    au:=List(au,x->GroupHomomorphismByImagesNC(G,G,gens,List(gens,y->Image(x,y))));
  fi;

  for i in au do
    SetIsBijective(i,true);
    j:=MappingGeneratorsImages(i);
    if j[1]<>j[2] then
      SetIsInnerAutomorphism(i,false);
    fi;
    SetFilterObj(i,IsMultiplicativeElementWithInverse);
  od;

  au:= GroupByGenerators( au, IdentityMapping( G ) );
  SetIsAutomorphismGroup(au,true);
  SetIsFinite(au,true);

  SetInnerAutomorphismsAutomorphismGroup(au,TrivialSubgroup(au));

  if IsFinite(G) then
    SetIsFinite(au,true);
    SetIsGroupOfAutomorphismsFiniteGroup(au,true);
  fi;

  return au;
end);

#############################################################################
##
#F  IsomorphismAbelianGroups(<G>)
##
InstallGlobalFunction(IsomorphismAbelianGroups,function(G,H)
local o,p,gens,hens;

  # get standard generating system
  gens:=IndependentGeneratorsOfAbelianGroup(G);
  gens:=ShallowCopy(gens);

  # get standard generating system
  hens:=IndependentGeneratorsOfAbelianGroup(H);
  hens:=ShallowCopy(hens);

  o:=List(gens,Order);
  p:=List(hens,Order);

  SortParallel(o,gens);
  SortParallel(p,hens);

  if o<>p then
    return fail;
  fi;

  o:=GroupHomomorphismByImagesNC(G,H,gens,hens);
  SetIsBijective(o,true);

  return o;
end);

BindGlobal("OuterAutomorphismGeneratorsSimple",function(G)
local d,id,H,iso,aut,auts,i,all,hom,field,dim,P,diag,mats,gens,gal;
  if not IsNonabelianSimpleGroup(G) then
    return fail;
  fi;
  gens:=GeneratorsOfGroup(G);
  d:=DataAboutSimpleGroup(G);
  id:=d.idSimple;
  all:=false;
  if id.series="A" then
    if id.parameter=6 then
      # A6 is easy enough
      return fail;
    else
      H:=AlternatingGroup(id.parameter);
      if G=H then
        iso:=IdentityMapping(G);
      else
        iso:=IsomorphismGroups(G,H);
      fi;
      aut:=GroupGeneralMappingByImages(G,G,gens,
            List(gens,
              x->PreImagesRepresentative(iso,Image(iso,x)^(1,2))));
      auts:=[aut];
      all:=true;
    fi;

  elif id.series in ["L","2A"] or (id.series="C" and id.parameter[1]>2) then
    hom:=EpimorphismFromClassical(G);
    if hom=fail then return fail;fi;
    field:=FieldOfMatrixGroup(Source(hom));
    dim:=DimensionOfMatrixGroup(Source(hom));
    auts:=[];
    if Size(field)>2 then
      gal:=GaloisGroup(field);
      # Diagonal automorphisms
      if id.series="L" then
        P:=GL(dim,field);
      elif id.series="2A" then
        P:=GU(dim,id.parameter[2]);
        #gal:=GaloisGroup(GF(GF(id.parameter[2]),2));
      elif id.series="C" then
        if IsEvenInt(Size(field)) then
          P:=Source(hom);
        else
          P:=List(One(Source(hom)),ShallowCopy);
          for i in [1..Length(P)/2] do
            P[i][i]:=PrimitiveRoot(field);
          od;
          P:=ImmutableMatrix(field,P);
          if not ForAll(GeneratorsOfGroup(Source(hom)),
                     x->x^P in Source(hom)) then
            Error("changed shape!");
          elif P in Source(hom) then
            Error("P is in!");
          fi;

          P:=Group(Concatenation([P],GeneratorsOfGroup(Source(hom))));
          SetSize(P,Size(Source(hom))*2);
        fi;
      else
        Error("not yet done");
      fi;
      # Sufficiently many elements to get the mult. group
      aut:=Size(P)/Size(Source(hom));
      P:=GeneratorsOfGroup(P);
      if id.series="C" then
        # we know it's the first
        mats:=P{[1]};
        P:=P{[2..Length(P)]};
      else
        diag:=Group(One(field));
        mats:=[];
        while Size(diag)<aut do
          if not DeterminantMat(P[1]) in diag then
            diag:=ClosureGroup(diag,DeterminantMat(P[1]));
            Add(mats,P[1]);
          fi;
          P:=P{[2..Length(P)]};
        od;
      fi;
      auts:=Concatenation(auts,
        List(mats,s->GroupGeneralMappingByImages(G,G,gens,List(gens,x->
                  Image(hom,PreImagesRepresentative(hom,x)^s)))));

    else
      gal:=Group(()); # to force trivial
    fi;

    if Size(gal)>1 then
      # Galois
      auts:=Concatenation(auts,
        List(MinimalGeneratingSet(gal),
                s->GroupGeneralMappingByImages(G,G,gens,List(gens,x->
                  Image(hom,
                    List(PreImagesRepresentative(hom,x),r->List(r,y->Image(s,y))))))));
    fi;

    # graph
    if id.series="L" and id.parameter[1]>2 then
      Add(auts, GroupGeneralMappingByImages(G,G,gens,List(gens,x->
                  Image(hom,Inverse(TransposedMat(PreImagesRepresentative(hom,x)))))));
      all:=true;
    elif id.series="L" and id.parameter[1]=2 then
      # note no graph
      all:=true;
    elif id.series in ["2A","C"] then
      # no graph
      all:=true;
    fi;

  else
    return fail;
  fi;

  for i in auts do
    SetIsMapping(i,true);
    SetIsBijective(i,true);
  od;
  return [auts,all];
end);

BindGlobal("AutomorphismGroupMorpheus",function(G)
local a,b,c,p;
  if IsNonabelianSimpleGroup(G) then
    c:=DataAboutSimpleGroup(G);
    b:=List(GeneratorsOfGroup(G),x->InnerAutomorphism(G,x));
    a:=OuterAutomorphismGeneratorsSimple(G);
    if IsBound(c.fullAutGroup) and c.fullAutGroup[1]=1 then
      # no outer automorphisms
      a:=rec(aut:=[],inner:=b,sizeaut:=Size(G));

    elif a=fail then
      a:=Morphium(G,G,true);
    else
      if a[2]=true then
        a:=a[1];
        a:=rec(aut:=a,inner:=b,sizeaut:=Size(G)*c.fullAutGroup[1]);
      else
        Info(InfoWarning,1,"Only partial list given");
        a:=Morphium(G,G,true);
      fi;
    fi;
  else
    a:=Morphium(G,G,true);
  fi;
  if IsList(a.aut) then
    a.aut:= GroupByGenerators( Concatenation( a.aut, a.inner ),
                               IdentityMapping( G ) );
    if IsBound(a.sizeaut) then SetSize(a.aut,a.sizeaut);fi;
    a.inner:=SubgroupNC(a.aut,a.inner);
  elif HasConjugacyClasses(G) then
    # test whether we really want to keep the stored nice monomorphism
    b:=Range(NiceMonomorphism(a.aut));
    p:=LargestMovedPoint(b); # degree of the nice rep.

    # first class sizes for non central generators. Their sum is what we
    # admit as domain size
    c:=Filtered(List(ConjugacyClasses(G),Size),i->i>1);
    Sort(c);
    c:=c{[1..Minimum(Length(c),Length(GeneratorsOfGroup(G)))]};

    if p>100 and ((not IsPermGroup(G)) or (p>4*LargestMovedPoint(G)
      and (p>1000 or p>Sum(c)
           or ForAll(GeneratorsOfGroup(a.aut),IsConjugatorAutomorphism)
           or Size(a.aut)/Size(G)<p/10*LargestMovedPoint(G)))) then
      # the degree looks rather big. Can we do better?
      Info(InfoMorph,2,"test automorphism domain ",p);
      c:=GroupByGenerators(GeneratorsOfGroup(a.aut),One(a.aut));
      AssignNiceMonomorphismAutomorphismGroup(c,G:autactbase:=fail);
      if IsPermGroup(Range(NiceMonomorphism(c))) and
        LargestMovedPoint(Range(NiceMonomorphism(c)))<p then
        Info(InfoMorph,1,"improved domain ",
             LargestMovedPoint(Range(NiceMonomorphism(c))));
        a.aut:=c;
        a.inner:=SubgroupNC(a.aut,GeneratorsOfGroup(a.inner));
      fi;
    fi;
  fi;
  SetInnerAutomorphismsAutomorphismGroup(a.aut,a.inner);
  SetIsAutomorphismGroup( a.aut, true );
  if HasIsFinite(G) and IsFinite(G) then
    SetIsFinite(a.aut,true);
    SetIsGroupOfAutomorphismsFiniteGroup(a.aut,true);
  fi;
  return a.aut;
end);

InstallGlobalFunction(AutomorphismGroupFittingFree,function(g)
  local s, c, acts, ttypes, ttypnam, act, t, j, iso, w, wemb, a, au,
  auph, aup, n, wl, genimgs, thom, ahom, emb, lemb, d, ge, stbs, orb, base,
  newbas, obas, p, r, orpo, imgperm, invmap, hom, i, gen,gens,tty,count;
  #write g in a nice form
  count:=ValueOption("count");if count=fail then count:=0;fi;
  s:=Socle(g);
  if IsNonabelianSimpleGroup(s) then
    return AutomorphismGroupMorpheus(g);
  fi;
  c:=ChiefSeriesThrough(g,[s]);
  acts:=[];
  ttypes:=[];
  ttypnam:=[];
  for i in [1..Length(c)-1] do
    if IsSubset(s,c[i]) and not HasAbelianFactorGroup(c[i],c[i+1]) then
      act:=WreathActionChiefFactor(g,c[i],c[i+1]);
      Add(acts,act);
      t:=act[4];
      tty:=IsomorphismTypeInfoFiniteSimpleGroup(t);
      j:=1;
      while j<=Length(ttypes) do
        if ttypnam[j]=tty then
          iso:=IsomorphismGroups(t,acts[ttypes[j][1]][4]);
          Add(ttypes[j],[Length(acts),iso]);
          j:=Length(ttypes)+10;
        fi;
        j:=j+1;
      od;
      if j<Length(ttypes)+2 then
        Add(ttypes,[Length(acts)]);
        Add(ttypnam,tty);
        Info(InfoMorph,1,"New isomorphism type: ",
          ttypnam[Length(ttypnam)].name);
      fi;
    fi;
  od;

  # now build the wreath products
  w:=[];
  wemb:=[];
  for i in ttypes do
    t:=acts[i[1]][4];
    a:=acts[i[1]][3];
    au:=AutomorphismGroupMorpheus(t);
    auph:=IsomorphismPermGroup(au);
    aup:=Image(auph);
    n:=acts[i[1]][5];
    for j in [2..Length(i)] do
      n:=n+acts[i[j][1]][5];
    od;
    #T replace symmetric group by a suitable wreath product
    wl:=WreathProduct(aup,SymmetricGroup(n));
    # now embed all

    n:=1;
    # first is slightly special
    genimgs:=[];
    for gen in GeneratorsOfGroup(a) do
      thom:=GroupHomomorphismByImagesNC(t,t,GeneratorsOfGroup(t),
              List(GeneratorsOfGroup(t),j->j^gen));
      thom:=Image(auph,thom);
      Add(genimgs,thom);
    od;

    ahom:=GroupHomomorphismByImagesNC(a,aup,GeneratorsOfGroup(a),genimgs);

    emb:=acts[i[1]][2]*EmbeddingWreathInWreath(wl,acts[i[1]][1],ahom,n);
    n:=n+acts[i[1]][5];
    lemb:=[emb];

    for j in [2..Length(i)] do
      a:=acts[i[j][1]][3];
      genimgs:=[];
      for gen in GeneratorsOfGroup(a) do
        thom:=i[j][2];
        thom:=GroupHomomorphismByImagesNC(t,t,GeneratorsOfGroup(t),
          List(GeneratorsOfGroup(t),
          j->Image(thom,PreImagesRepresentative(thom,j)^gen)));
        thom:=Image(auph,thom);
        Add(genimgs,thom);
      od;

      ahom:=GroupHomomorphismByImagesNC(a,aup,GeneratorsOfGroup(a),genimgs);

      emb:=acts[i[j][1]][2]*EmbeddingWreathInWreath(wl,acts[i[j][1]][1],ahom,n);
      n:=n+acts[i[j][1]][5];
      Add(lemb,emb);

    od;
    # now map into wl by combining
    emb:=[];
    for gen in GeneratorsOfGroup(g) do
      Add(emb,Product(lemb,i->Image(i,gen)));
    od;
    emb:=GroupHomomorphismByImagesNC(g,wl,GeneratorsOfGroup(g),emb);
    Add(w,wl);
    Add(wemb,emb);

  od;

  # finally form a direct product for the different types
  d:=DirectProduct(w);
  emb:=[];
  for gen in GeneratorsOfGroup(g) do
    Add(emb,
      Product([1..Length(w)],i->Image(Embedding(d,i),Image(wemb[i],gen))));
  od;
  emb:=GroupHomomorphismByImagesNC(g,d,GeneratorsOfGroup(g),emb);

  aup:=Normalizer(d,Image(emb,g));

  #reduce degree -- avoid redundant fixed points
  if count>1 then
    p:=aup;
    s:=IdentityMapping(p);
    repeat
      i:=SmallerDegreePermutationRepresentation(p);
      if NrMovedPoints(Range(i))<NrMovedPoints(p) then
        p:=Image(i,p);
        s:=s*i;
      fi;
    until NrMovedPoints(Source(i))=NrMovedPoints(Range(i));
  else
    s:=SmallerDegreePermutationRepresentation(aup:cheap);
  fi;
  emb:=emb*s;
  aup:=Image(s,aup);
  ge:=Image(emb,g);

  # translate back into automorphisms
  a:=[];
  gens:=SmallGeneratingSet(aup);
  for i in gens do
    au:=GroupHomomorphismByImages(g,g,GeneratorsOfGroup(g),
         List(GeneratorsOfGroup(g),
           j->PreImagesRepresentative(emb,Image(emb,j)^i)));
    Add(a,au);
  od;
  au:=Group(a);

  #cleanup
  Unbind(acts);Unbind(act);Unbind(ttypes);Unbind(w);Unbind(wl);
  Unbind(wemb);Unbind(lemb);Unbind(ahom);Unbind(thom);Unbind(d);

  # produce data to map from au to aup:
  lemb:=MovedPoints(aup);
  stbs:=[];
  orb:=Orbits(aup,MovedPoints(aup));
  base:=BaseStabChain(StabChainMutable(aup));
  newbas:=[];
  for i in orb do
    obas:=Filtered(base,x->x in i);
    Append(newbas,obas);
    p:=obas[1];
    # get a set of elements that uniquely describes the point p
    s:=SmallGeneratingSet(Stabilizer(ge,p));
    if ForAny(Difference(i,[p]),j->ForAll(s,x->j^x=j)) then
      # try once more -- there is some randomeness involved
      if count<10 then
        return AutomorphismGroupFittingFree(g:count:=count+1);
      fi;
      Error("repeated further fixpoint -- ambiguity");
    fi;
    stbs[p]:=s;
    for j in [2..Length(obas)] do
      r:=RepresentativeAction(aup,p,obas[j]);
      stbs[obas[j]]:=List(s,i->i^r);
    od;
  od;
  orpo:=List(MovedPoints(aup),x->First([1..Length(orb)],y->x in orb[y]));

  imgperm:=function(autom)
  local bi, s, i;
    bi:=[];
    for i in newbas do
      s:=List(stbs[i],
              x->Image(emb,Image(autom,PreImagesRepresentative(emb,x))));
      s:=First(orb[orpo[i]],x->ForAll(s,j->x^j=x));
      Add(bi,s);
    od;
    return RepresentativeAction(aup,newbas,bi,OnTuples);
  end;

  invmap:=GroupHomomorphismByImagesNC(aup,au,gens,a);
  hom:=GroupHomomorphismByFunction(au,aup,imgperm,
         function(x)
           return Image(invmap,x);
         end);
  SetInverseGeneralMapping(hom,invmap);
  SetInverseGeneralMapping(invmap,hom);
  SetIsAutomorphismGroup(au,true);
  SetIsGroupOfAutomorphismsFiniteGroup(au,true);
  SetNiceMonomorphism(au,hom);
  SetIsHandledByNiceMonomorphism(au,true);

  return au;
end);

#############################################################################
##
#M  AutomorphismGroup(<G>) . . group of automorphisms, given as Homomorphisms
##
InstallMethod(AutomorphismGroup,"finite groups",true,[IsGroup and IsFinite],0,
function(G)
local A;
  # since the computation is expensive, it is worth to test some properties first,
  # instead of relying on the method selection
  if IsAbelian(G) then
    A:=AutomorphismGroupAbelianGroup(G);
  elif (not HasIsPGroup(G)) and IsPGroup(G) then
    #if G did not yet know to be a P-group, but is -- redispatch to catch the
    #`autpgroup' package method. This will be called at most once.
    #LoadPackage("autpgrp"); # try to load the package if it exists
    return AutomorphismGroup(G);
  elif IsNilpotentGroup(G) and not IsPGroup(G) then
    #LoadPackage("autpgrp"); # try to load the package if it exists
    A:=AutomorphismGroupNilpotentGroup(G);
  elif IsSolvableGroup(G) then
    if HasIsFrattiniFree(G) and IsFrattiniFree(G) then
      A:=AutomorphismGroupFrattFreeGroup(G);
    else
      # currently autactbase does not work well, as the representation might
      # change.
      A:=AutomorphismGroupSolvableGroup(G);
    fi;
  elif Size(SolvableRadical(G))=1 and IsPermGroup(G) then
    # essentially a normalizer when suitably embedded
    A:=AutomorphismGroupFittingFree(G);
  elif Size(SolvableRadical(G))>1 and CanComputeFittingFree(G) then
    A:=AutomGrpSR(G);
  else
    A:=AutomorphismGroupMorpheus(G);
  fi;
  SetIsAutomorphismGroup(A,true);
  SetIsGroupOfAutomorphismsFiniteGroup(A,true);
  SetIsFinite(A,true);
  SetAutomorphismDomain(A,G);
  return A;
end);

#############################################################################
##
#M  AutomorphismGroup(<G>) . . abelian case
##
InstallMethod(AutomorphismGroup,"test abelian",true,[IsGroup and IsFinite],
  {} -> RankFilter(IsSolvableGroup and IsFinite),
function(G)
local A;
  if not IsAbelian(G) then
    TryNextMethod();
  fi;
  A:=AutomorphismGroupAbelianGroup(G);
  SetIsAutomorphismGroup(A,true);
  SetIsGroupOfAutomorphismsFiniteGroup(A,true);
  SetIsFinite(A,true);
  SetAutomorphismDomain(A,G);
  return A;
end);

#############################################################################
##
#M  AutomorphismGroup(<G>) . . abelian case
##
InstallMethod(AutomorphismGroup,"test abelian",true,[IsGroup and IsFinite],
  {} -> RankFilter(IsSolvableGroup and IsFinite),
function(G)
local A;
  if not IsAbelian(G) then
    TryNextMethod();
  fi;
  A:=AutomorphismGroupAbelianGroup(G);
  SetIsAutomorphismGroup(A,true);
  SetIsGroupOfAutomorphismsFiniteGroup(A,true);
  SetIsFinite(A,true);
  SetAutomorphismDomain(A,G);
  return A;
end);

# just in case it does not know to be finite
RedispatchOnCondition(AutomorphismGroup,true,[IsGroup],
    [IsGroup and IsFinite],0);

#############################################################################
##
#M NiceMonomorphism
##
InstallMethod(NiceMonomorphism,"for automorphism groups",true,
              [IsGroupOfAutomorphismsFiniteGroup],0,
function( A )
local G;

    if not IsGroupOfAutomorphismsFiniteGroup(A) then
      TryNextMethod();
    fi;

    G  := Source( Identity(A) );

    # this stores the niceo
    AssignNiceMonomorphismAutomorphismGroup(A,G);

    # as `AssignNice...' will have stored an attribute value this cannot cause
    # an infinite recursion:
    return NiceMonomorphism(A);
end);


#############################################################################
##
#M  InnerAutomorphismsAutomorphismGroup( <A> )
##
InstallMethod( InnerAutomorphismsAutomorphismGroup,
    "for automorphism groups",
    true,
    [ IsAutomorphismGroup and IsFinite ], 0,
    function( A )
    local G, gens;
    G:= Source( Identity( A ) );
    gens:= GeneratorsOfGroup( G );
    # get the non-central generators
    gens:= Filtered( gens, i -> not ForAll( gens, j -> i*j = j*i ) );
    return SubgroupNC( A, List( gens, i -> InnerAutomorphism( G, i ) ) );
    end );


#############################################################################
##
#M  InnerAutomorphismGroup( <G> )
##
InstallMethod( InnerAutomorphismGroup,
    "for groups",
    true,
    [ IsGroup and HasGeneratorsOfGroup ], 0,
    function( G )
    local gens, A;
    if HasAutomorphismGroup( G ) or IsTrivial( G ) then
        return InnerAutomorphismsAutomorphismGroup( AutomorphismGroup( G ) );
    fi;
    gens:= GeneratorsOfGroup( G );
    # get the non-central generators
    gens:= Filtered( gens, i -> not ForAll( gens, j -> i*j = j*i ) );
    A := Group( List( gens, i -> InnerAutomorphism( G, i ) ) );
    SetIsGroupOfAutomorphismsFiniteGroup( A, true );
    return A;
    end );


InstallGlobalFunction(IsomorphismSimpleGroups,function(g,h)
local d,iso,a,b,c,o,s,two,rt,r,z,e,y,re,m,gens,cnt,lim,p,
  rootClasses,findElm,isFull,trans,prim;

  rootClasses:=function(tbl,a)
  local p,r,i,j;
    p:=List(Set(Factors(Size(tbl))),x->PowerMap(tbl,x));
    r:=[a];
    for i in [1..NrConjugacyClasses(tbl)] do
      for j in p do
        if j[i] in r then
          AddSet(r,i);
        fi;
      od;
    od;
    return r;
  end;

  findElm:=function(gp,o,z,r)
  local a,e;
    repeat
      if IsSubgroupFpGroup(gp) then
        a:=Random(gp);
      else
        a:=PseudoRandom(gp);
      fi;
      e:=Order(a);
      if e in r then
        a:=a^QuoInt(e,o);
        if z=fail or Size(Centralizer(gp,a))=z then
          return a;
        fi;
      fi;
    until false;
  end;

  isFull:=function(gp)
    if trans and not IsTransitive(gp,MovedPoints(g)) then return false;fi;
    if prim and not IsPrimitive(gp,MovedPoints(g)) then return false;fi;
    return Size(gp)=Size(g);
  end;

  # work in perm if possible
  if IsPermGroup(h) and not IsPermGroup(g) then
    iso:=IsomorphismSimpleGroups(h,g);
    if iso<>fail then iso:=InverseGeneralMapping(iso);fi;
    return iso;
  fi;

  if not (Size(g)=Size(h) and IsSimpleGroup(g) and IsSimpleGroup(h)) then
    return fail;
  fi;
  d:=DataAboutSimpleGroup(g);
  if d.idSimple<>DataAboutSimpleGroup(h).idSimple then
    return false;
  fi;

  trans:=IsPermGroup(g) and IsTransitive(g,MovedPoints(g));
  prim:=IsPermGroup(g) and IsPrimitive(g,MovedPoints(g));

  # is a standard generator finder known?
  if IsPackageMarkedForLoading("atlasrep","")=true
    and ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
    p:=CallFuncList(ValueGlobal("AtlasProgram"),[d.tomName,1,"find"]);
    if p<>fail then
      Info(InfoMorph,1,"Isomorphism simple: Atlas");
      a:=CallFuncList(ValueGlobal("ResultOfBBoxProgram"),[p.program,g]);
      b:=CallFuncList(ValueGlobal("ResultOfBBoxProgram"),[p.program,h]);
      iso:=GroupHomomorphismByImagesNC(g,h,a,b);
      Assert(2,IsMapping(iso));
      SetIsInjective(iso,true);
      SetIsSurjective(iso,true);
      return iso;
    fi;
  fi;
  gens:=fail;
  if IsPackageMarkedForLoading("ctbllib","")=true then
    c:=CharacterTable(d.tomName);
    if c<>fail then
      Info(InfoMorph,1,"Isomorphism simple: ctbl");
      o:=OrdersClassRepresentatives(c);
      s:=SizesConjugacyClasses(c);
      # order two, unique class order, smallest
      two:=Filtered([1..Length(o)],x->o[x]=2);
      a:=s{two};
      a:=Collected(a);
      if ForAny(a,x->x[2]=1) then
        a:=List(Filtered(a,x->x[2]=1),x->x[1]);
        two:=Filtered(two,x->s[x] in a);
      fi;
      SortBy(two,x->s[x]);
      two:=two[1];
      z:=Size(c)/s[two]; # centralizer order
      r:=rootClasses(c,two);
      rt:=Set(o{r});
      e:=fail;

      a:=Set(o); # orders
      m:=Concatenation(Reversed(Filtered(a,x->IsPrimeInt(x) and x<100)),
                       Reversed(Filtered(a,x->not IsPrimeInt(x) and x<100)),
                       Filtered(a,x->x>100));

      while gens=fail do
        e:=m[1];
        a:=Filtered([1..Length(o)],x->o[x]=e);
        m:=m{[2..Length(m)]};
        # only largest class order for this element order
        SortBy(a,x->-s[x]);
        a:=Filtered(a,x->s[x]=s[a[1]]);
        if (Length(Set(s{a}))=1 and Size(c)/Sum(s{a})<100) then
          y:=Size(c)/s[a[1]]; # centralizer order
          r:=rootClasses(c,a[1]);
          re:=Set(o{r});
          gens:=[findElm(g,2,z,rt),findElm(g,e,y,re)];
          cnt:=0;
          while not isFull(SubgroupNC(g,gens)) and cnt<20 do
            if IsSubgroupFpGroup(g) then
              gens[2]:=gens[2]^Random(g);
            else
              gens[2]:=gens[2]^PseudoRandom(g);
            fi;
            cnt:=cnt+1;
          od;
          if cnt=20 then gens:=fail;fi;
        fi;
      od;
    fi;
  fi;
  if gens=fail then
    Info(InfoMorph,1,"Isomorphism simple: ad-hoc");
    # not found by table or other -- try a 2/something ad-hoc
    rt:=[2,4..Size(g)];
    gens:=[findElm(g,2,fail,rt)];
    z:=Size(Centralizer(g,gens[1]));

    # try a larger, but not huge prime. Thus avoid Singer cycles
    # which have small centralizers and thus long orbits
    m:=Maximum(Filtered(Factors(Size(g)),x->x<100));
    cnt:=0;
    repeat
      gens[2]:=findElm(g,m,fail,[m,2*m..Size(g)]);
      if isFull(SubgroupNC(g,gens)) then
        b:=gens;
        y:=Size(Centralizer(g,gens[2]));
      else
        b:=fail;
      fi;
      cnt:=cnt+1;
    until b<>fail or 2^cnt>Size(g);

    cnt:=2;
    while b=fail or y>z*2^(QuoInt(cnt,2)) do
      cnt:=cnt+1;
      if IsSubgroupFpGroup(g) then
        gens[2]:=Random(g);
      else
        gens[2]:=PseudoRandom(g);
      fi;
      if isFull(SubgroupNC(g,gens)) then
        b:=gens;
        y:=Size(Centralizer(g,gens[2]));
      fi;
    od;
    gens:=b;
    e:=Order(gens[2]);
    re:=[e,2*e..Size(g)];
    y:=Size(Centralizer(g,gens[2]));
  fi;
  Info(InfoMorph,1,"generators ",List(gens,Order));
  o:=List(MorFroWords(gens),Order);
  lim:=QuoInt(Size(g),z*y); # how many try unless fails
  if e>100 then
    lim:=lim*QuoInt(e,100)*Phi(e);
  fi;

  # now try at most 10 times for a pair as given
  for cnt in [1..4*LogInt(Size(g),10)] do
    Info(InfoMorph,1,"Try pair ",cnt);
    a:=findElm(h,2,z,rt);
    c:=0;
    repeat
      repeat
        # the centralizer test is more expensive than element orders
        b:=findElm(h,e,fail,re);
        c:=c+1;
        m:=MorFroWords([a,b]);
      until (ForAll([1..Length(o)],x->Order(m[x])=o[x])
        and Size(Centralizer(h,b))=y) or c>lim;
      if c<=lim then
        Info(InfoMorph,2,"testing ...");
        iso:=GroupHomomorphismByImages(g,h,gens,[a,b]);
        if IsMapping(iso) then
          SetIsInjective(iso,true);
          SetIsSurjective(iso,true);
          return iso;
        fi;
      elif lim<2000 then
        lim:=lim*2;
      fi;
    until c>lim;
  od;

  return fail;
end);


BindGlobal("IsomorphismPGroups",function(G,H)
local s,p,eG,eH,fG,fH,pc,imgs,pre,post;
  s:=Size(G);
  if Size(H)<>s then return fail;fi;
  p:=Collected(Factors(s));
  if Length(p)>1 then TryNextMethod();fi;
  p:=p[1][1];
  if IsFpGroup(G) then
    pre:=fail;
  else
    pre:=IsomorphismFpGroup(G);
    G:=Image(pre,G);
  fi;

  if IsFpGroup(H) then
    post:=fail;
  else
    post:=IsomorphismFpGroup(H);
    H:=Image(post,H);
  fi;


  eG:=CallFuncList(ValueGlobal("EpimorphismPqStandardPresentation"),[G]:
    Prime:=p);
  eH:=CallFuncList(ValueGlobal("EpimorphismPqStandardPresentation"),[H]:
    Prime:=p);

  # check presentations
  fG:=Range(eG);
  fH:=Range(eH);
  if List(RelatorsOfFpGroup(fG),
    x->MappedWord(x,FreeGeneratorsOfFpGroup(fG),FreeGeneratorsOfFpGroup(fH)))
      <>RelatorsOfFpGroup(fH) then
    return fail;
  fi;

  # move to pc pres
  pc:=PcGroupFpGroup(fG);

  # new maps to pc
  imgs:=List(MappingGeneratorsImages(eG)[2],
    x->MappedWord(UnderlyingElement(x),
      FreeGeneratorsOfFpGroup(fG),GeneratorsOfGroup(pc)));

  eG:=GroupHomomorphismByImages(G,pc,MappingGeneratorsImages(eG)[1],imgs);

  imgs:=List(MappingGeneratorsImages(eH)[2],
    x->MappedWord(UnderlyingElement(x),
      FreeGeneratorsOfFpGroup(fH),GeneratorsOfGroup(pc)));
  eH:=GroupHomomorphismByImages(H,pc,MappingGeneratorsImages(eH)[1],imgs);

  s:=eG*InverseGeneralMapping(eH);
  if pre<>fail then s:=pre*s;fi;
  if post<>fail then s:=s*InverseGeneralMapping(post);fi;
  s:=AsGroupGeneralMappingByImages(s);

  return s;
end);

#############################################################################
##
#F  IsomorphismGroups(<G>,<H>) . . . . . . . . . .  isomorphism from G onto H
##
InstallGlobalFunction(IsomorphismGroups,function(G,H)
local m;

  if not HasIsFinite(G) or not HasIsFinite(H) then
    Info(InfoWarning,1,"Forcing finiteness test");
    IsFinite(G);
    IsFinite(H);
  fi;
  if not IsFinite(G) and not IsFinite(H) then
    Error("cannot test isomorphism of infinite groups");
  fi;
  if IsFinite(G) <> IsFinite(H) then
    return fail;
  fi;

  #AH: Spezielle Methoden ?
  if Size(G)=1 then
    if Size(H)<>1 then
      return fail;
    else
      return GroupHomomorphismByImagesNC(G,H,[],[]);
    fi;
  fi;
  if IsAbelian(G) then
    if not IsAbelian(H) then
      return fail;
    else
      return IsomorphismAbelianGroups(G,H);
    fi;
  fi;

  if Size(G)<>Size(H) then
    return fail;
  fi;

  if IsSimpleGroup(G) then
    m:=IsomorphismSimpleGroups(G,H);
    if m=false then return fail;fi;
    if m<>fail then return m;fi;
  fi;

  # 2000 is the limit for using the small groups code
  if Size(G)>2000 and IsPGroup(G) and
    IsPackageMarkedForLoading("anupq","")=true then
    return IsomorphismPGroups(G,H);
  fi;

  if Size(SolvableRadical(G))>1 and CanComputeFittingFree(G)
    and not (IsSolvableGroup(G) and Size(G)<=2000
       and ID_AVAILABLE(Size(G))<>fail)
    and (AbelianRank(G)>2 or Length(SmallGeneratingSet(G))>2
      # the solvable radical method got better, so force if the radical of
      # the group is a good part
      # sizeable radical
      or Size(SolvableRadical(G))^2>Size(G)
      or ValueOption("forcetest")=true) and
      ValueOption("forcetest")<>"old" then
    # In place until a proper implementation of Cannon/Holt isomorphism is
    # done
    return PatheticIsomorphism(G,H);
  fi;

  if ID_AVAILABLE(Size(G)) <> fail
    and ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
    Info(InfoPerformance,2,"Using Small Groups Library");
    if IdGroup(G)<>IdGroup(H) then
      return fail;
    elif ValueOption("hard")=fail
      and IsSolvableGroup(G) and Size(G) <= 2000 then
      return IsomorphismSolvableSmallGroups(G,H);
    fi;
  elif AbelianInvariants(G)<>AbelianInvariants(H) then
    return fail;
  elif Collected(List(ConjugacyClasses(G),
          x->[Order(Representative(x)),Size(x)]))
        <>Collected(List(ConjugacyClasses(H),
          x->[Order(Representative(x)),Size(x)])) then
    return fail;
  fi;

  m:=Morphium(G,H,false);
  if IsList(m) and Length(m)=0 then
    return fail;
  else
    return m;
  fi;

end);


#############################################################################
##
#F  GQuotients(<F>,<G>)  . . . . . epimorphisms from F onto G up to conjugacy
##
InstallMethod(GQuotients,"for groups which can compute element orders",true,
  [IsGroup,IsGroup and IsFinite],
  # override `IsFinitelyPresentedGroup' filter.
  1,
function (F,G)
local Fgens,    # generators of F
      cl,       # classes of G
      u,        # trial generating set's group
      vsu,      # verbal subgroups
      pimgs,    # possible images
      val,      # its value
      best,     # best generating set
      bestval,  # its value
      sz,       # |class|
      i,        # loop
      h,        # epis
      len,      # nr. gens tried
      fak,      # multiplication factor
      cnt;      # countdown for finish

  # if we have a pontentially infinite fp group we cannot be clever
  if IsSubgroupFpGroup(F) and
    (not HasSize(F) or Size(F)=infinity) then
    TryNextMethod();
  fi;

  Fgens:=GeneratorsOfGroup(F);

  # if a verbal subgroup is trivial in the image, it must be in the kernel
  vsu:=SomeVerbalSubgroups(F,G);
  vsu:=vsu[1]{Filtered([1..Length(vsu[2])],j->IsTrivial(vsu[2][j]))};
  vsu:=Filtered(vsu,i->not IsTrivial(i));
  if Length(vsu)>1 then
    fak:=vsu[1];
    for i in [2..Length(vsu)] do
      fak:=ClosureGroup(fak,vsu[i]);
    od;
    Info(InfoMorph,1,"quotient of verbal subgroups :",Size(fak));
    h:=NaturalHomomorphismByNormalSubgroup(F,fak);
    fak:=Image(h,F);
    u:=GQuotients(fak,G);
    cl:=[];
    for i in u do
      i:=GroupHomomorphismByImagesNC(F,G,Fgens,
             List(Fgens,j->Image(i,Image(h,j))));
      Add(cl,i);
    od;
    return cl;
  fi;

  if Size(G)=1 then
    return [GroupHomomorphismByImagesNC(F,G,Fgens,
                          List(Fgens,i->One(G)))];
  elif IsCyclic(F) then
    Info(InfoMorph,1,"Cyclic group: only one quotient possible");
    # a cyclic group has at most one quotient
    if not IsCyclic(G) or not IsInt(Size(F)/Size(G)) then
      return [];
    else
      # get the cyclic gens
      u:=First(AsList(F),i->Order(i)=Size(F));
      h:=First(AsList(G),i->Order(i)=Size(G));
      # just map them
      return [GroupHomomorphismByImagesNC(F,G,[u],[h])];
    fi;
  fi;

  if IsFinite(F) and not IsPerfectGroup(G) and
    CanMapFiniteAbelianInvariants(AbelianInvariants(F),
                                  AbelianInvariants(G))=false then
    return [];
  fi;

  if IsAbelian(G) then
    fak:=5;
  else
    fak:=50;
  fi;

  cl:=ConjugacyClasses(G);

  # first try to find a short generating system
  best:=false;
  bestval:=infinity;
  if Size(F)<10000000 and Length(Fgens)>2 then
    len:=Maximum(2,Length(SmallGeneratingSet(
                 Image(NaturalHomomorphismByNormalSubgroup(F,
                   DerivedSubgroup(F))))));
  else
    len:=2;
  fi;
  cnt:=0;
  repeat
    u:=List([1..len],i->Random(F));
    if Index(F,Subgroup(F,u))=1 then

      # find potential images
      pimgs:=[];
      for i in u do
        sz:=Index(F,Centralizer(F,i));
        Add(pimgs,Filtered(cl,j->IsInt(Order(i)/Order(Representative(j)))
                             and IsInt(sz/Size(j))));
      od;

      # sort u in descending order -> large reductions when centralizing
      SortParallel(pimgs,u,function(a,b)
                             return Sum(a,Size)>Sum(b,Size);
                           end);

      val:=Product(pimgs,i->Sum(i,Size));
      if val<bestval then
        Info(InfoMorph,2,"better value: ",List(u,Order),
              "->",val);
        best:=[u,pimgs];
        bestval:=val;
      fi;

    fi;
    cnt:=cnt+1;
    if cnt=len*fak and best=false then
      cnt:=0;
      Info(InfoMorph,1,"trying one generator more");
      len:=len+1;
    fi;
  until best<>false and (cnt>len*fak or bestval<3*cnt);

  if ValueOption("findall")=false then
    # only one
    h:=MorClassLoop(G,best[2],rec(gens:=best[1],to:=G,from:=F),5);
    # get the same syntax for the object returned
    if IsList(h) and Length(h)=0 then
      return h;
    else
      return [h];
    fi;
  else
    h:=MorClassLoop(G,best[2],rec(gens:=best[1],to:=G,from:=F),13);
  fi;
  cl:=[];
  u:=[];
  for i in h do
    if not KernelOfMultiplicativeGeneralMapping(i) in u then
      Add(u,KernelOfMultiplicativeGeneralMapping(i));
      Add(cl,i);
    fi;
  od;

  Info(InfoMorph,1,Length(h)," found -> ",Length(cl)," homs");
  return cl;
end);

#############################################################################
##
#F  IsomorphicSubgroups(<G>,<H>)
##
InstallMethod(IsomorphicSubgroups,"for finite groups",true,
  [IsGroup and IsFinite,IsGroup and IsFinite],
  # override `IsFinitelyPresentedGroup' filter.
  1,
function(G,H)
local cl,cnt,bg,bw,bo,bi,k,gens,go,imgs,params,emb,clg,sg,vsu,c,i,ranfun;

  if not IsInt(Size(G)/Size(H)) then
    Info(InfoMorph,1,"sizes do not permit embedding");
    return [];
  fi;

  if IsTrivial(H) then
    return [GroupHomomorphismByImagesNC(H,G,[],[])];
  fi;

  if IsAbelian(G) then
    if not IsAbelian(H) then
      return [];
    fi;
    if IsCyclic(G) then
      if IsCyclic(H) then
        return [GroupHomomorphismByImagesNC(H,G,[MinimalGeneratingSet(H)[1]],
          [MinimalGeneratingSet(G)[1]^(Size(G)/Size(H))])];
      else
        return [];
      fi;
    fi;
  fi;

  cl:=ConjugacyClasses(G);
  if IsCyclic(H) then
    cl:=List(RationalClasses(G),Representative);
    cl:=Filtered(cl,i->Order(i)=Size(H));
    return List(cl,i->GroupHomomorphismByImagesNC(H,G,
                      [MinimalGeneratingSet(H)[1]],
                      [i]));
  fi;
  cl:=ConjugacyClasses(G);


  # test whether there is a chance to embed
  cnt:=0;
  while cnt<20 do
    bg:=Order(Random(H));
    if not ForAny(cl,i->Order(Representative(i))=bg) then
      return [];
    fi;
    cnt:=cnt+1;
  od;

  # "random element" function, possibly biased towards smaller orders
  ranfun:=x->Random(H);
  if Size(H)<10^5 and Length(AbelianInvariants(H))<4 then
    # classes that are not contained in normal
    vsu:=ConjugacyClasses(H);
    vsu:=Filtered(vsu,x->Size(H)
      =Size(NormalClosure(H,SubgroupNC(H,[Representative(x)]))));
    if Length(vsu)>0 then
      SortBy(vsu,x->Order(Representative(x)));
      ranfun:=function(x)
        # random element of a class, selected with bias for smaller orders
        return Random(vsu[Random([1..Random([1..Length(vsu)])])]);
      end;
    fi;
  fi;

  # find a suitable generating system
  bw:=infinity;
  bo:=[0,0];
  cnt:=0;
  repeat
    if cnt=0 then
      # first the small gen syst.
      gens:=SmallGeneratingSet(H);
      sg:=Length(gens);
    else
      # then something random
      repeat
        if Length(gens)>2 and Random(1,2)=1 then
          # try to get down to 2 gens
          gens:=List([1,2],i->ranfun(1));
        else
          gens:=List([1..sg],i->ranfun(1));
        fi;
        # try to get small orders
        for k in [1..Length(gens)] do
          go:=Order(gens[k]);
          # try a p-element
          if Random(1,3*Length(gens))=1 then
            gens[k]:=gens[k]^(go/(Random(Factors(go))));
          fi;
        od;

      until Index(H,SubgroupNC(H,gens))=1;
    fi;

    go:=List(gens,Order);
    imgs:=List(go,i->Filtered(cl,j->Order(Representative(j))=i));
    Info(InfoMorph,3,go,":",Product(imgs,i->Sum(i,Size)));
    if Product(imgs,i->Sum(i,Size))<bw then
      bg:=gens;
      bo:=go;
      bi:=imgs;
      bw:=Product(imgs,i->Sum(i,Size));
    elif Set(go)=Set(bo) then
      # we hit the orders again -> sign that we can't be
      # completely off track
      cnt:=cnt+Int(bw/Size(G)/20);
    fi;
    cnt:=cnt+1;
  until bw/Size(G)*3<cnt;

  if bw=0 then
    return [];
  fi;

  vsu:=SomeVerbalSubgroups(H,G);
  # filter by verbal subgroups
  for i in [1..Length(bg)] do
    c:=Filtered([1..Length(vsu[1])],j->bg[i] in vsu[1][j]);

#Print(List(bi[i],k->
#     Filtered([1..Length(vsu[2])],j->Representative(k) in vsu[2][j])),"\n");

    cl:=Filtered(bi[i],k->ForAll(c,j->Representative(k) in vsu[2][j]));
    if Length(cl)<Length(bi[i]) then
      Info(InfoMorph,1,"images improved by verbal subgroup:",
      Sum(bi[i],Size)," -> ",Sum(cl,Size));
      bi[i]:=cl;
    fi;
  od;

  Info(InfoMorph,2,"find ",bw," from ",cnt);

  if Length(bg)>2 and cnt>Size(H)^2 and Size(G)<bw then
    Info(InfoPerformance,1,
    "The group tested requires many generators. `IsomorphicSubgroups' often\n",
"#I  does not perform well for such groups -- see the documentation.");
  fi;

  params:=rec(gens:=bg,from:=H);
  # find all embeddings
  if ValueOption("findall")=false then
    # only one
    emb:=MorClassLoop(G,bi,params,
      # one injective homs = 1+2
      3);
      if IsList(emb) and Length(emb)=0 then
        return emb;
      fi;
    emb:=[emb];
  else
    emb:=MorClassLoop(G,bi,params,
      # all injective homs = 1+2+8
      11);
  fi;
  Info(InfoMorph,2,Length(emb)," embeddings");
  cl:=[];
  clg:=[];
  for k in emb do
    bg:=Image(k,H);
    if not ForAny(clg,i->RepresentativeAction(G,i,bg)<>fail) then
      Add(cl,k);
      Add(clg,bg);
    fi;
  od;
  Info(InfoMorph,1,Length(emb)," found -> ",Length(cl)," homs");
  return cl;
end);
