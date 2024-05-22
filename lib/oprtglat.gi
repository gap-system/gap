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
##  This  file  contains methods for orbits on subgroups
##

#############################################################################
##
#M  GroupOnSubgroupsOrbit(G,H) . . . . . . . . . . . . . . orbit of H under G
##
InstallGlobalFunction( GroupOnSubgroupsOrbit, function(G,H)
  return Enumerator(ConjugacyClassSubgroups(G,H));
end );

#############################################################################
##
#M  MinimumGroupOnSubgroupsOrbit(G,H [,N_G(H)]) minimum of orbit of H under G
##
InstallGlobalFunction( MinimumGroupOnSubgroupsOrbit, function(arg)
local cont,lim,s,i,j,m,Hc,o;
  # try some orbit calculation first (at most orbit of length 20) to avoid
  # normalizer calculations.
  cont:=true;
  lim:=QuoInt(Size(arg[1]),Size(arg[2]));
  if lim>20 then
    cont:=lim<200000; # otherwise give up at once
    lim:=20;
  fi;

  if cont then
    o:=[arg[2]];
  else
    o:=[];
  fi;
  m:=arg[2];
  i:=1;
  while cont and i<=Length(o) do
    for j in GeneratorsOfGroup(arg[1]) do
      if not ForAny(o,x->ForAll(GeneratorsOfGroup(o[i]),y->y^j in x)) then
        Hc:=o[i]^j;
        Add(o,Hc);
        if Hc<m then
          m:=Hc;
        fi;
        cont:=Length(o)<lim;
      fi;
    od;
    i:=i+1;
  od;

  if not cont then
    # orbit is longer -- have to work
    s:=ConjugacyClassSubgroups(arg[1],arg[2]);
    if Length(arg)>2 then
      SetStabilizerOfExternalSet(s,arg[3]);
    fi;
    s:=Enumerator(s);
    if Length(s)>2*lim then
      o:=[]; # the orbit is not worth keeping -- test would be too expensive
    fi;
    for i in [1..Length(s)] do
      Hc:=s[i];
      if not ForAny(o,x->ForAll(GeneratorsOfGroup(Hc),y-> y in x)) then
        if Hc<m then
          m:=Hc;
        fi;
      fi;
    od;
  fi;
  return m;
end );

InstallMethod(SubgroupsOrbitsAndNormalizers,"generic on list",true,
  [IsGroup,IsList,IsBool],0,
function(G,dom,all)
local  n,l,o,b,r,p,cl,i,sel,selz,gens,ti,t,tl;

  n:=Length(dom);
  l:=n;
  o:=[];
  b:=BlistList([1..l],[1..n]);
  while n>0 do
    p:=Position(b,true);
    b[p]:=false;
    n:=n-1;
    r:=rec(representative:=dom[p],pos:=p);
    cl:=ConjugacyClassSubgroups(G,r.representative);
    gens:=GeneratorsOfGroup(r.representative);
    r.normalizer:=StabilizerOfExternalSet(cl);
    t:=RightTransversal(G,r.normalizer);
    tl:=Length(t);
    sel:=Filtered([1..l],i->b[i]);
    selz:=Filtered(sel,i->Size(dom[i])=Size(r.representative));
    if Length(selz)>0 then
      i:=1;
      while Length(sel)>0 and i<=tl do;
        ti:=t[i];
        p:=PositionProperty(sel,
                            j->j in selz and ForAll(gens,k->k^ti in dom[j]));
        if p<>fail then
          p:=sel[p];
          b[p]:=false;
          n:=n-1;
          RemoveSet(sel,p);
        fi;
        i:=i+1;
      od;
    fi;
    if all then
      cl:=Enumerator(cl);
      r.elements:=cl;
    fi;
    Add(o,r);
  od;
  return o;
end);


# prepare list of subgroups of a permgroup G for conjugacy test and cluster
# accordingly. returns list with entries
# clusters (index lists)
# actors (for each cluster the subgroup that is still acting. Set to trivial
# if groups are fully conjugated)
# gps (groups already conjugates so the action is reduced to acts for each
# cluster)
# conjugators (for subgroups in list, elements conjugationg to gps)
# normalizers: if not `false` normalizers of cluster rep in gps
#

# Another orbit algorithm variant...
BindGlobal("CCPOSA",function(G,p,q,act)
local o,s,rep,i,j,img,pos;
  o:=[p];
  s:=TrivialSubgroup(G);
  rep:=[One(G)];
  i:=1;
  while i<=Length(o) do
    for j in GeneratorsOfGroup(G) do
      img:=act(o[i],j);
      pos:=Position(o,img);
      if pos=fail then
        Add(o,img);
        Add(rep,rep[i]*j);
      else
        s:=ClosureSubgroupNC(s,rep[i]*j/rep[pos]);
      fi;
    od;
    i:=i+1;
  od;
  pos:=Position(o,q);
  if pos=fail then return fail;
  else return [s,rep[pos]];fi;
end);

InstallGlobalFunction(ClusterConjugacyPermgroups,function(G,l)
local acts,gps,clusters,conj,ncl,nacts,i,j,new,q,hom,lhom,c,n,r,len,
      pat,oa,ob,orbs,k,gens,nnors,m,kk,perm,fur,ooa,oob,lan,subset;

  acts:=[G];
  gps:=ShallowCopy(l);
  subset:=ForAll(l,x->IsSubset(G,x));
  clusters:=[[1..Length(gps)]];
  conj:=List(gps,x->One(G));

  # orders
  ncl:=[];
  nacts:=[];
  for i in [1..Length(clusters)] do
    new:=Set(List(gps{clusters[i]},Size));
    for q in new do
      c:=Filtered(clusters[i],x->Size(gps[x])=q);
      Add(ncl,c);
      Add(nacts,acts[i]);
    od;
  od;
  clusters:=ncl;
  acts:=nacts;

  # find a homomorphism (already existing)
  hom:=fail;
  c:=NaturalHomomorphismsPool(G);
  new:=Filtered([1..Length(c.ker)],
    x->IsMapping(c.ops[x]) and c.cost[x]<NrMovedPoints(G));
  q:=Difference(List(c.ker{new},Size),[1,Size(G)]);
  if Length(q)>0 then
    q:=Minimum(q);
    q:=First(new,x->Size(c.ker[x])=q);
    hom:=c.ops[q];
  fi;

  if hom<>fail then # work in factor
    if Size(Source(hom))>Size(G) then
      hom:=RestrictedMapping(hom,G);
    fi;
    Info(InfoLattice,5,"Factor: ",Size(Range(hom)),"/",
      Size(KernelOfMultiplicativeGeneralMapping(hom)));
    ncl:=[];
    nacts:=[];
    for i in [1..Length(clusters)] do
      if Size(Source(hom))=Size(acts[i]) then
        lhom:=hom;
      else
        lhom:=RestrictedMapping(hom,acts[i]);
      fi;
      c:=clusters[i];
      q:=Image(lhom,acts[i]);
      m:=List(c,x->Image(lhom,gps[x]));
      new:=ClusterConjugacyPermgroups(q,m);
      new:=RefineClusterConjugacyPermgroups(new);
      for j in [1..Length(new.clusters)] do
        Add(ncl,c{new.clusters[j]});
        if new.normalizers[j]<>false then
          n:=new.normalizers[j];
        else
          n:=new.actors[j];
        fi;
        Info(InfoLattice,5,"reduced (factor) by ",Size(q)/Size(n));
        Add(nacts,PreImage(lhom,n));
        for k in new.clusters[j] do
          r:=PreImagesRepresentative(lhom,new.conjugators[k]);
          conj[c[k]]:=conj[c[k]]*r;
          gps[c[k]]:=gps[c[k]]^r;
        od;
      od;
    od;
    clusters:=ncl;
    acts:=nacts;
  fi;

  # same orbits
  ncl:=[];
  nacts:=[];
  for i in [1..Length(clusters)] do
    c:=clusters[i];
    q:=MovedPoints(acts[i]);
    orbs:=[];
    for j in c do
      orbs[j]:=List(Orbits(gps[j],q),Set);
    od;
    while Length(c)>0 do
      new:=[c[1]];
      pat:=Collected(List(orbs[c[1]],Length));

      len:=List(pat,x->x[1]);
      # TODO: Wreath
      oa:=List(len,x->Union(Filtered(orbs[c[1]],y->Length(y)=x)));
      perm:=Sortex(List(oa,Length));
      oa:=Permuted(oa,perm);
      len:=Permuted(len,perm);
      n:=[acts[i]];
      for j in oa do
        q:=n[Length(n)];
        if ForAny(GeneratorsOfGroup(q),x->OnSets(j,x)<>j) then
          q:=Stabilizer(q,j,OnSets);
        fi;
        Add(n,q);
      od;
      lan:=n[Length(n)];
      fur:=Length(Orbits(lan,MovedPoints(acts[i])))
          <>Length(orbs[c[1]]);
      if Size(lan)=Size(acts[i]) and not fur then
        # already all the same
        Add(ncl,c);
        Add(nacts,acts[i]);
        c:=[];
      else
        Info(InfoLattice,5,"reduced (orb) by ",Size(acts[i])/Size(n[Length(n)]));
        for j in [2..Length(c)] do
          if Collected(List(orbs[c[j]],Length))=pat then
            r:=One(acts[i]);
            # already for changed len!
            ob:=List(len,x->Union(Filtered(orbs[c[j]],y->Length(y)=x)));
            for k in [1..Length(oa)] do
              if r<>fail then
                q:=RepresentativeAction(n[k],ob[k],oa[k],OnSets);
                if q=fail then r:=fail;
                else
                  r:=r*q;
                  for kk in [k+1..Length(oa)] do
                    ob[kk]:=OnSets(ob[kk],q);
                  od;
                  if fur then
                    ooa:=Set(Filtered(orbs[c[1]],y->Length(y)=len[k]));
                    oob:=Set(List(Filtered(orbs[c[j]],y->Length(y)=len[k])),
                      x->OnSets(x,r));
                    if ooa<>oob then
                      q:=CCPOSA(n[k],ooa,oob,OnSetsSets);
                      if q=fail then r:=fail;
                      else
                        Add(n,q[1]); # partition stabilizer
                        q:=q[2]^-1; # mapping oob to ooa
                        r:=r*q;
                        for kk in [k+1..Length(oa)] do
                          ob[kk]:=OnSets(ob[kk],q);
                        od;
                      fi;
                    fi;

                  fi;
                fi;
              fi;
            od;
            if r<>fail then
              q:=c[j];
              Add(new,q);
              conj[q]:=conj[q]*r;
              gps[q]:=gps[q]^r;
            fi;
          fi;
        od;
        Add(ncl,new);
        Add(nacts,n[Length(n)]);
        c:=Difference(c,new);
      fi;
    od;
  od;
  clusters:=ncl;
  acts:=nacts;

  # small enough index
  ncl:=[];
  nacts:=[];
  nnors:=[];
  for i in [1..Length(clusters)] do
    c:=clusters[i];
    if Length(c)=1 or Size(acts[i])/Size(gps[c[1]])>1000 then
      Add(ncl,c);
      Add(nacts,acts[i]);
      Add(nnors,false); # no normalizer computed
    elif Size(acts[i])=Size(gps[c[1]]) then
      Add(ncl,c);
      Add(nacts,acts[i]);
      Add(nnors,acts[i]); # no normalizer computed
    else
      Info(InfoLattice,5,"reduced (transversal) by ",Size(acts[i])/Size(gps[c[1]]));
      while Length(c)>0 do
        n:=gps[c[1]];
        ob:=n;
        gens:=GeneratorsOfGroup(n);
        if HasSolvableRadical(acts[i]) then
          k:=Filtered([1..Length(gens)],x->gens[x] in SolvableRadical(acts[i]));
          gens:=gens{Concatenation(Difference([1..Length(gens)],k),k)};
        fi;
        new:=[c[1]];
        c:=c{[2..Length(c)]};
        if subset then
          oa:=RightTransversal(acts[i],n);
        else
          n:=Normalizer(acts[i],n);
          oa:=RightTransversal(acts[i],n);
        fi;
        k:=1;
        while k<=Length(oa) do
          r:=oa[k];
          if (not r in n) and ForAll(gens,x->x^r in ob) then
            n:=ClosureGroup(n,r);
          fi;
          for j in c do
            if ForAll(gens,x->x^r in gps[j]) then # same size
              Add(new,j);
              c:=Difference(c,[j]);
              conj[j]:=conj[j]/r;
              gps[j]:=ob;
            fi;
          od;
          k:=k+1;
        od;
        Add(ncl,new);
        Add(nacts,fail);
        nnors[Length(ncl)]:=n;
      od;
    fi;
  od;
  clusters:=ncl;
  acts:=nacts;

  return rec(
    clusters:=clusters,
    actors:=acts,
    conjugators:=conj,
    gps:=gps,
    normalizers:=nnors
    );

end);

InstallGlobalFunction(RefineClusterConjugacyPermgroups,function(A)
local acts,nacts,clusters,ncl,c,conj,gps,nors,nnors,i,j,r,n,new;
  acts:=A.actors;
  clusters:=A.clusters;
  conj:=ShallowCopy(A.conjugators);
  gps:=ShallowCopy(A.gps);
  nors:=A.normalizers;
  nacts:=[];
  ncl:=[];
  nnors:=[];
  for i in [1..Length(clusters)] do
    c:=clusters[i];
    if Length(c)=1 or ForAll([2..Length(c)],x->gps[c[1]]=gps[c[x]]) then
      # all groups in cluster are already the same
      Add(ncl,c);
      Add(nacts,acts[i]);
      if nors[i]=false then
        if acts[i]=gps[c[1]] then
          Add(nnors,gps[c[1]]); # do not duplicate the acts, but the subgroup
        else
          Add(nnors,Normalizer(acts[i],gps[c[1]]));
        fi;
      else
        Add(nnors,nors[i]);
      fi;
    else
      # need to do hard conjugacy tests
      while Length(c)>0 do
        new:=[c[1]];
        n:=Normalizer(acts[i],gps[c[1]]);
        for j in [2..Length(c)] do
          r:=ConjugatorPermGroup(acts[i],gps[c[j]],gps[c[1]]);
          if r<>fail then
            Add(new,c[j]);
            conj[c[j]]:=conj[c[j]]*r;
            gps[c[j]]:=gps[c[j]]^r;
          fi;
        od;
        c:=Difference(c,new);
        Add(ncl,new);
        Add(nacts,n);
        Add(nnors,n);
      od;
    fi;
  od;

  return rec(
    clusters:=ncl,
    actors:=nacts,
    conjugators:=conj,
    gps:=gps,
    normalizers:=nnors
    );

end);

InstallMethod(SubgroupsOrbitsAndNormalizers,"perm group on list",true,
  [IsPermGroup,IsList,IsBool],0,
function(G,dom,all)
local n,l, o, b, t, r,sub;

  if Length(dom)=0 then
    return dom;
  elif Length(dom)=1 then
    return [rec(pos:=1,
      representative:=dom[1],
      normalizer:=Normalizer(G,dom[1]))];
  fi;

  # new code -- without `all` option

  n:=Length(dom);
  sub:=ForAll(dom,x->IsSubset(G,x));
  if n>20 and sub and NrMovedPoints(G)>1000 then
    #and NrMovedPoints(G)*1000>Size(G) then

    b:=SmallerDegreePermutationRepresentation(G:cheap);
    if NrMovedPoints(Range(b))*13/10<NrMovedPoints(G) then
      l:=SubgroupsOrbitsAndNormalizers(Image(b,G),
        List(dom,x->Image(b,x)),all);
      dom:=List(l,x->rec(pos:=x.pos,normalizer:=PreImage(b,x.normalizer),
        representative:=dom[x.pos]));
      return dom;
    fi;
  fi;

  if not sub then TryNextMethod();fi;

  l:=ClusterConjugacyPermgroups(G,ShallowCopy(dom));
  l:=RefineClusterConjugacyPermgroups(l);
  o:=[];
  for b in [1..Length(l.clusters)] do
    t:=l.clusters[b];
      r:=rec(representative:=dom[t[1]],pos:=t[1]);
      n:=l.normalizers[b];
      if n=false then
        if Size(l.actors[b])=Size(r.representative) then
          n:=r.representative;
        else
          n:=Normalizer(l.actors[b]^(l.conjugators[t[1]]^-1),r.representative);
        fi;
      else
        n:=n^(l.conjugators[t[1]]^-1);
      fi;
      r.normalizer:=n;
      Add(o,r);

  od;

  return o;

end);

InstallMethod(SubgroupsOrbitsAndNormalizers,"pc group on list",true,
  [IsPcGroup,IsList,IsBool],0,
function(G,dom,all)
local  n,l,o,b,r,p,cl,i,sel,selz,allcano,cano,can2,p1;

  allcano:=[];
  n:=Length(dom);
  l:=n;
  o:=[];
  b:=BlistList([1..l],[1..n]);
  while n>0 do
    p:=Position(b,true);
    p1:=p;
    b[p]:=false;
    n:=n-1;
    r:=rec(representative:=dom[p],pos:=p);

    sel:=Filtered([1..l],i->b[i]);
    selz:=Filtered(sel,i->Size(dom[i])=Size(r.representative));

    if Length(selz)>0 then

      if IsBound(allcano[p1]) then
        cano:=allcano[p1];
      else
        cano:=CanonicalSubgroupRepresentativePcGroup(G,r.representative);
      fi;
      r.normalizer:=ConjugateSubgroup(cano[2],cano[3]^-1);

      cano:=cano[1];

      for i in selz do
        if IsBound(allcano[i]) then
          can2:=allcano[i];
        else
          can2:=CanonicalSubgroupRepresentativePcGroup(G,dom[i]);
        fi;
        if can2[1]=cano then
          b[i]:=false;
          n:=n-1;
          RemoveSet(sel,i);
          Unbind(allcano[i]);
        else
          allcano[i]:=can2;
        fi;
      od;
    else
      r.normalizer:=Normalizer(G,r.representative);
    fi;

    if all then
      cl:=ConjugacyClassSubgroups(G,r.representative);
      SetStabilizerOfExternalSet(cl,r.normalizer);
      r.elements:=Enumerator(cl);
    fi;

    Add(o,r);
    Unbind(allcano[p1]);
  od;
  return o;
end);

# destructive version
# this method takes the component 'list' from the record and shrinks the
# list to save memory
InstallMethod(SubgroupsOrbitsAndNormalizers,"generic on record with list",true,
  [IsGroup,IsRecord,IsBool],0,
function(G,r,all)
local  n,o,dom,cl,i,s,j,t,ti,tl,gens;

  dom:=r.list;
  Unbind(r.list);

  n:=Length(dom);
  o:=[];
  while n>0 do
    r:=rec(representative:=dom[1]);
    gens:=GeneratorsOfGroup(dom[1]);
    s:=Size(dom[1]);
    cl:=ConjugacyClassSubgroups(G,r.representative);
    r.normalizer:=StabilizerOfExternalSet(cl);
    cl:=Enumerator(cl);
    t:=RightTransversal(G,r.normalizer);
    tl:=Length(t);

    i:=1;
    while i<=tl and Length(dom)>0 do
      ti:=t[i];
      j:=2;
      while j<=Length(dom) do
        if Size(dom[j])=s and ForAll(gens,k->k^ti in dom[j]) then
          # hit
          dom[j]:=dom[Length(dom)];
          Unbind(dom[Length(dom)]);
        else
          j:=j+1;
        fi;
      od;
      i:=i+1;
    od;

    if all then
      r.elements:=cl;
    fi;
    Add(o,r);
  od;
  return o;
end);

#############################################################################
##
#M  StabilizerOp( <G>, <D>, <subgroup>, <U>, <V>, <OnPoints> )
##
##  subgroup stabilizer
InstallMethod( StabilizerOp, "with domain, use normalizer", true,
    [ IsGroup, IsList, IsGroup, IsList, IsList, IsFunction ],
    # raise over special methods for pcgs et. al.
    200,
function( G, D, sub, U, V, op )
    if not U=V or op<>OnPoints then
      TryNextMethod();
    fi;
    return Normalizer(G,sub);
end );

InstallOtherMethod( StabilizerOp, "use normalizer", true,
    [ IsGroup, IsGroup, IsList, IsList, IsFunction ],
    # raise over special methods for pcgs et. al.
    200,
function( G, sub, U, V, op )
    if not U=V or op<>OnPoints then
      TryNextMethod();
    fi;
    return Normalizer(G,sub);
end );

InstallGlobalFunction(PermPreConjtestGroups,function(G,l)
local pats,spats,lpats,result,pa,lp,lens,h,orbs,p,rep,cln,allorbs,
      allco,panu,gpcl,i,j,k,Gm,a,corbs,dict,norb,m,ornums,sornums,
      ssornums,sel,sela,statra,lrep,gpcl2,je,lrep1,partimg,nobail,cnt,hpos;

  if not IsPermGroup(G) then
    return [[G,l]];
  fi;

  pats:=List(l,x->Collected(List(Orbits(x,MovedPoints(x)),Length)));
  spats:=Set(pats);
  Info(InfoLattice,2,Length(spats)," patterns");
  result:=[];
  for pa in [1..Length(spats)] do
    lp:=Filtered([1..Length(pats)],x->pats[x]=spats[pa]);
    lp:=l{lp};
    Info(InfoLattice,3,"Pattern ",pa,": ",Length(lp)," groups");
    lens:=List(spats[pa],x->x[1]);

    # now try to move the orbits always to the same
    allorbs:=[];
    allco:=[];
    panu:=0;
    gpcl:=[];

    for h in lp do
      orbs:=Orbits(h,MovedPoints(h));
      orbs:=List(lens,x->Union(Filtered(orbs,y->Length(y)=x)));
      p:=Position(allorbs,orbs);
      if p<>fail then
        rep:=allco[p][1];
        cln:=allco[p][2];
      else
        Add(allorbs,orbs);
        # try to map to a known one
        j:=1;
        while j<>fail and j<Length(allorbs) do
          if orbs=allorbs[j] then
            rep:=One(G);
          else
            Gm:=G;
            rep:=One(G);
            corbs:=List(orbs,ShallowCopy);
            for k in [1..Length(orbs)] do
              if rep<>fail then
                a:=RepresentativeAction(Gm,corbs[k],allorbs[j][k],OnSets);
                if a<>fail then
                  rep:=rep*a;
                  corbs:=List(corbs,x->OnSets(x,a));
                  Gm:=Stabilizer(Gm,allorbs[j][k],OnSets);
                else
                  rep:=fail;
                fi;
              fi;
            od;
          fi;
          if rep<>fail then
            # found a conjugator -- join to class
            cln:=allco[j][2];
            Add(allco,[rep,cln]);
            j:=fail;
          else
            j:=j+1;
          fi;

        od;
        if j<>fail then
          # none found -- new class
          panu:=panu+1;
          Add(allco,[One(G),panu]);
          Gm:=G;
          for k in orbs do
            Gm:=Stabilizer(Gm,k,OnSets);
          od;
          Add(gpcl,[Gm,[]]);
          cln:=panu;
          rep:=One(G);
        fi;
      fi;

      h:=h^rep;
      Add(gpcl[cln][2],h);

    od;
    Info(InfoLattice,3,Length(gpcl)," orbit lengths classes ");
    Info(InfoLattice,5,List(gpcl,x->Length(x[2])));

    # split according to orbits. First orbits as they are orbits under j[1],
    # then as partitions.
    panu:=[];
    for j in gpcl do
      if Length(j[2])=1 then
        Add(panu,j);
      else
        allorbs:=[];
        lpats:=[];
        cnt:=Minimum(1000,Binomial(Length(j[2]),2)); # pairs
        nobail:=true;
        dict:=NewDictionary(MovedPoints(j[1]),true);
        norb:=0;
        hpos:=1;
        while nobail and hpos<=Length(j[2]) do
          h:=j[2][hpos];
          orbs:=Set(Orbits(h,MovedPoints(h)),Set);
          MakeImmutable(orbs);List(orbs,IsSet);IsSet(orbs);
          lp:=[];
          for k in orbs do
            rep:=LookupDictionary(dict,k);
            if nobail and rep=fail then
              a:=Orbit(j[1],k,OnSets);
              cnt:=cnt-Length(a);
              if cnt<0 then
                nobail:=false; # stop this orbit listing as too expensive.
              else
                MakeImmutable(a);List(a,IsSet);
                norb:=norb+1;
                rep:=norb;
                for m in a do
                  AddDictionary(dict,m,norb);
                od;
              fi;
            fi;
            Add(lp,rep);
          od;
          Sort(lp); # orbit pattern as numbers
          rep:=Position(allorbs,lp);
          if rep=fail then
            Add(allorbs,lp);
            Add(lpats,[j[1],[h]]);
          else
            Add(lpats[rep][2],h);
          fi;
          hpos:=hpos+1;
        od;

        if nobail then
          # now lpats are local patterns, but we still have the dictionary to
          # make the orbit conjugation tests cheaper.
          gpcl2:=lpats;

          for je in gpcl2 do
            if Length(je[2])=1 then
              Add(panu,je);
            else
              allorbs:=[];
              lpats:=[];
              for h in je[2] do
                orbs:=Set(Orbits(h,MovedPoints(h)),Set);
                MakeImmutable(orbs);List(orbs,IsSet);IsSet(orbs);
                ornums:=List(orbs,x->LookupDictionary(dict,x));
                sornums:=ShallowCopy(ornums);Sort(sornums);
                ssornums:=Set(sornums);
                a:=Filtered([1..Length(allorbs)],x->allorbs[x][2]=sornums);
                rep:=fail;
                k:=0;
                while rep=fail and k<Length(a) do
                  k:=k+1;
                  lrep:=One(je[1]);
                  m:=1;
                  while lrep<>fail and m<=Length(ssornums) do
                    sel:=Filtered([1..Length(ornums)],x->ornums[x]=ssornums[m]);
                    sela:=Filtered([1..Length(ornums)],
                      x->allorbs[k][4][x]=ssornums[m]);
                    partimg:=OnSetsSets(orbs{sel},lrep^-1);
                    # only try to map these indexed orbits
                    if allorbs[k][1]{sela}=partimg then
                      lrep1:=One(je[1]);
                    elif Size(allorbs[k][5][m][1])/
                          Size(allorbs[k][5][m+1][1])>50 then
                      if allorbs[k][5][m][2]=0 then
                        # delayed transversal
                        allorbs[k][5][m][2]:=
                          RightTransversal(allorbs[k][5][m][1],
                            allorbs[k][5][m+1][1]);
                      fi;
                      lrep1:=First(allorbs[k][5][m][2],
                        x->OnSetsSets(allorbs[k][1]{sela},x)=partimg);
                    else
                      lrep1:=RepresentativeAction(allorbs[k][5][m][1],
                        allorbs[k][1]{sela},partimg,OnSetsSets);
                    fi;
                    if lrep1=fail then
                      lrep:=fail;
                    else
                      lrep:=lrep1*lrep;
                    fi;

                    m:=m+1;
                  od;

                  rep:=lrep;
                od;
                if rep=fail then

                  a:=je[1];
                  statra:=[];
                  for m in ssornums do
                    sel:=Filtered([1..Length(ornums)],x->ornums[x]=m);
                    Add(statra,[a,0]); # 0 is delayed transversal
                    a:=Stabilizer(a,orbs{sel},OnSetsSets);
                  od;
                  Add(statra,[a,0]);

                  Add(allorbs,[orbs,sornums,a,ornums,statra]);
                  Add(lpats,[a,[h]]);
                else
                  Add(lpats[k][2],h^(rep^-1));
                fi;
              od;
              Append(panu,lpats);
            fi;
          od;
        else
          # if bailed
          Add(panu,j);
        fi;
      fi;
    od;
    gpcl:=panu;
    Info(InfoLattice,3,Length(gpcl)," orbit classes ");
    Info(InfoLattice,5,List(gpcl,x->Length(x[2])));

    # now split by cycle structures
    panu:=[];
    for j in gpcl do
      if Size(j[2][1])<1000 then
        if Size(j[2][1])<=100 or IsAbelian(j[2][1]) then
          allorbs:=List(j[2],x->Collected(List(Enumerator(x),CycleStructurePerm)));
        else
          allorbs:=List(j[2],x->Collected(List(ConjugacyClasses(x),
            y->Concatenation([Size(y)],
                   CycleStructurePerm(Representative(y))))));
        fi;

        allco:=Set(allorbs);
        for k in allco do
          a:=Filtered([1..Length(allorbs)],x->allorbs[x]=k);
          orbs:=[];
          for i in j[2]{a} do
            if not ForAny(orbs,x->ForAll(GeneratorsOfGroup(i),y->y in x)) then
              Add(orbs,i);
            fi;
          od;
          Add(result,[j[1],orbs]);
          Add(panu,Length(orbs));
        od;

      else
        Add(result,j);
        Add(panu,1);
      fi;

    od;
    Info(InfoLattice,3," to ",Length(panu)," cyclestruct classes ");

  od;
  return result;

end);
