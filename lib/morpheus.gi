#############################################################################
##
#W  morpheus.gi                GAP library                   Alexander Hulpke
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This  file  contains declarations for Morpheus
##

#############################################################################
##
#V  MORPHEUSELMS . . . .  limit up to which size to store element lists
##
MORPHEUSELMS := 50000;

InstallMethod(Order,"for automorphisms",true,[IsGroupHomomorphism],0,
function(hom)
local map,phi,o,lo,i,start,img;
  o:=1;
  phi:=hom;
  map:=MappingGeneratorsImages(phi);
  i:=1;
  while i<=Length(map[1]) do
    lo:=1;
    start:=map[1][i];
    img:=map[2][i];
    while img<>start do
      img:=ImagesRepresentative(phi,img);
      lo:=lo+1;
      # do the bijectivity test only if high local order, then it does not
      # matter
      if lo=1000 and not IsBijective(hom) then
	Error("<hom> must be bijective");
      fi;
    od;
    if lo>1 then
      o:=o*lo;
      if i<Length(map[1]) then
	phi:=phi^lo;
	map:=MappingGeneratorsImages(phi);
        i:=0; # restart search, as generator set may have changed.
      fi;
    fi;
    i:=i+1;
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
      img, j, conj, sm, cen, n, w, emb, ge, no,reps,synom,ginn,oemb;

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
#	 x->ConjugatorOfConjugatorIsomorphism(x)),One(g));
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
    emb:=List(GeneratorsOfGroup(g),
	  i->Product(List([1..n],j->Image(Embedding(w,j),Image(synom,Image(orbi[j],i))))));
    ge:=Subgroup(w,emb);
    emb:=GroupHomomorphismByImagesNC(g,ge,GeneratorsOfGroup(g),emb);
    reps:=List(out,i->RepresentativeAction(w,GeneratorsOfGroup(ge),
      List(GeneratorsOfGroup(g),j->Image(emb,Image(i,j))),OnTuples));
    if not ForAll(reps,IsPerm) then
      return fail;
    fi;
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
    sm:=SmallerDegreePermutationRepresentation(ClosureGroup(ge,no));
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
local hom, allinner, gens, c, ran, r, cen, img, dom, u, subs, orbs, cnt, br, bv,
v, val, o, i, comb, best,actbase;

  hom:=fail;
  allinner:=HasIsAutomorphismGroup(au) and IsAutomorphismGroup(au);

  if not IsFinite(g) then
    Error("can't do!");

  elif IsAbelian(g) then

    SetIsFinite(au,true);
    gens:=IndependentGeneratorsOfAbelianGroup(g);
    c:=[];
    for i in gens do
      c:=Union(c,Orbit(au,i));
    od;
    hom:=NiceMonomorphismAutomGroup(au,c,gens);

  elif Size(Centre(g))=1 and IsPermGroup(g) then
    # if no centre, try to use exiting permrep
    if ForAll(GeneratorsOfGroup(au),IsConjugatorAutomorphism) then
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
	SetIsGroupHomomorphism(hom,true);
	SetRange( hom,ran );
	SetIsBijective(hom,true);
      fi;
    else
      # permrep does not extend. Try larger permrep.
      img:=AutomorphismWreathEmbedding(au,g);
      if img<>fail then
	Info(InfoMorph,1,"AWE succeeds");
	# make a hom from auts to perm group
	ran:=img[4];
	r:=List(GeneratorsOfGroup(g),i->Image(img[3],i));
	hom:=GroupHomomorphismByFunction(au,img[1],
          function(auto)
	    if IsConjugatorAutomorphism(auto) and
	      ConjugatorOfConjugatorIsomorphism(auto) in Source(img[2]) then
	      return Image(img[2],ConjugatorOfConjugatorIsomorphism(auto));
	    fi;
	    return RepresentativeAction(img[1],r,
	             List(GeneratorsOfGroup(g),i->Image(img[3],Image(auto,i))),OnTuples);
	  end,
	  function(perm)
	    if perm in ran then
	      return ConjugatorAutomorphismNC(g,
	               PreImagesRepresentative(img[2],perm));
	    fi;
	    return GroupHomomorphismByImagesNC(g,g,GeneratorsOfGroup(g),
	             List(r,i->PreImagesRepresentative(img[3],i^perm)));
	  end);

      elif not IsAbelian(Socle(g)) and IsSimpleGroup(Socle(g)) then
	Info(InfoMorph,1,"Try ARG");
	img:=AutomorphismRepresentingGroup(g,GeneratorsOfGroup(au));
	# make a hom from auts to perm group
	ran:=Image(img[2],g);
	r:=List(GeneratorsOfGroup(g),i->Image(img[2],i));
	hom:=GroupHomomorphismByFunction(au,img[1],
          function(auto)
	    if IsInnerAutomorphism(auto) then
	      return Image(img[2],ConjugatorOfConjugatorIsomorphism(auto));
	    fi;
	    return RepresentativeAction(img[1],r,
	             List(GeneratorsOfGroup(g),i->Image(img[2],Image(auto,i))),
		     OnTuples);
	  end,
	  function(perm)
	    if perm in ran then
	      return ConjugatorAutomorphismNC(g,
	               PreImagesRepresentative(img[2],perm));
	    fi;
	    return GroupHomomorphismByImagesNC(g,g,GeneratorsOfGroup(g),
	             List(r,i->PreImagesRepresentative(img[2],i^perm)));
	  end);
      fi;
    fi;
  fi;

  if hom=fail then
    Info(InfoMorph,1,"General Case");
    SetIsFinite(au,true);

    # general case: compute small domain
    gens:=[];
    dom:=[];
    u:=TrivialSubgroup(g);
    subs:=[];
    orbs:=[];
    while Size(u)<Size(g) do
      # find a reasonable element
      cnt:=0;
      br:=false;
      bv:=0;
      if HasConjugacyClasses(g) then
        for r in ConjugacyClasses(g) do
	  if IsPrimePowerInt(Order(Representative(r))) and
	      not Representative(r) in  u then
	    v:=ClosureGroup(u,Representative(r));
	    if allinner then
	      val:=Size(Centralizer(r))*Size(NormalClosure(g,v));
	    else
	      val:=Size(Centralizer(r))*Size(v);
	    fi;
	    if val>bv then
	      br:=Representative(r);
	      bv:=val;
	    fi;
	  fi;
	od;
      else
	actbase:=ValueOption("autactbase");
	if actbase=fail then
	  actbase:=[g];
	fi;
	repeat
	  cnt:=cnt+1;
	  repeat
	    r:=Random(Random(actbase));
	  until not r in u;
	  # force prime power order
	  if not IsPrimePowerInt(Order(r)) then
	    v:=List(Collected(Factors(Order(r))),x->r^(x[1]^x[2]));
	    r:=First(v,x->not x in u); # if all are in u, r would be as well
	  fi;

	  v:=ClosureGroup(u,r);
	  if allinner then
	    val:=Size(Centralizer(g,r))*Size(NormalClosure(g,v));
	  else
	    val:=Size(Centralizer(g,r))*Size(v);
	  fi;
	  if val>bv then
	    br:=r;
	    bv:=val;
	  fi;
	until bv>2^cnt;
      fi;
      r:=br;

      if allinner then
	u:=NormalClosure(g,ClosureGroup(u,r));
      else
	u:=ClosureGroup(u,r);
      fi;

      #calculate orbit and closure
      o:=Orbit(au,r);
      v:=TrivialSubgroup(g);
      i:=1;
      while i<=Length(o) do
	if not o[i] in v then
          if allinner then
	    v:=NormalClosure(g,ClosureGroup(v,o[i]));
	  else
	    v:=ClosureGroup(v,o[i]);
	  fi;
	  if Size(v)=Size(g) then
	    i:=Length(o);
	  fi;
	fi;
	i:=i+1;
      od;
      u:=ClosureGroup(u,v);

      i:=1;
      while Length(o)>0 and i<=Length(subs) do
	if IsSubset(subs[i],v) then
	  o:=[];
	elif IsSubset(v,subs[i]) then
	  subs[i]:=v;
	  orbs[i]:=o;
	  gens[i]:=r;
	  o:=[];
	fi;
	i:=i+1;
      od;
      if Length(o)>0 then
	Add(subs,v);
	Add(orbs,o);
	Add(gens,r);
      fi;
    od;

    # now find the smallest subset of domains
    comb:=Filtered(Combinations([1..Length(subs)]),i->Length(i)>0);
    bv:=infinity;
    for i in comb do
      val:=Sum(List(orbs{i},Length));
      if val<bv then
	v:=subs[i[1]];
	for r in [2..Length(i)] do
	  v:=ClosureGroup(v,subs[i[r]]);
	od;
	if Size(v)=Size(g) then
	  best:=i;
	  bv:=val;
	fi;
      fi;
    od;
    gens:=gens{best};
    dom:=Union(orbs{best});
    Unbind(orbs);

    u:=SubgroupNC(g,gens);
    while Size(u)<Size(g) do
      repeat
	r:=Random(dom);
      until not r in u;
      Add(gens,r);
      u:=ClosureSubgroupNC(u,r);
    od;
    Info(InfoMorph,1,"Found generating set of ",Length(gens)," elements",
         List(gens,Order));
    hom:=NiceMonomorphismAutomGroup(au,dom,gens);

  fi;

  SetFilterObj(hom,IsNiceMonomorphism);
  SetNiceMonomorphism(au,hom);
  SetIsHandledByNiceMonomorphism(au,true);
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
  Sort(cl,function(a,b) return
    Sum(a,i->i.size)
      <Sum(b,i->i.size);end);
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
MorClassOrbs:=function(G,C,R,D)
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
end;

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
      Sort(sortrels[i],function(x,y) return x[3]<y[3];end);
    od;
    if Length(pows)>0 then
      offset:=1-Minimum(List(Filtered(pows,i->Length(i)>0),
			    i->i[1])); # smallest occuring index
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
local G,cl,lcl,len,comb,combc,com,a,cnt,s,alltwo;
  G:=arg[1];
  cl:=arg[2];
  Info(InfoMorph,1,"FindGenerators");
  # throw out the 1-Class
  cl:=Filtered(cl,i->Length(i)>1 or Size(i[1].representative)>1);
  alltwo:=Set(Factors(Size(G)))=[2];

  #create just a list of ordinary classes.
  lcl:=List(cl,i->Concatenation(List(i,j->j.classes)));
  len:=1;
  len:=Maximum(1,Length(MinimalGeneratingSet(
		    Image(IsomorphismPcGroup((G/DerivedSubgroup(G))))))-1);
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
      # don't try only order 2 generators unless its a 2-group
      if Set(List(Flat(combc[com]),i->Order(Representative(i))))<>[2] or
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
## 	 automorphism are to be found
##       This function thus does the main combinatoric work for creating 
##       Iso- and Automorphisms.
##       It needs, that both groups are not cyclic.
##
InstallGlobalFunction(Morphium,function(G,H,DoAuto)
local len,combi,Gr,Gcl,Ggc,Hr,Hcl,bg,bpri,x,dat,
      gens,i,c,hom,free,elms,price,result,rels,inns,bcl,vsu;

  IsSolvableGroup(G); # force knowledge
  gens:=SmallGeneratingSet(G);
  len:=Length(gens);
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
      Sort(bcl,function(a,b) return Sum(a,Size)<Sum(b,Size);end);
      bg:=gens;
      bpri:=Product(combi,i->Sum(i,Size));
      for i in [1..7*Length(gens)-12] do
	repeat
	  for c in [1..Length(gens)] do
	    if Random([1,2,3])<2 then
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
	Sort(bcl,function(a,b) return Sum(a,Size)<Sum(b,Size);end);
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
	   j->Set(List(j,k->k.size))=Set(List(i,k->k.size))
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
    if IsSimpleGroup(H) then
      dat:=DataAboutSimpleGroup(H);
      if IsBound(dat.fullAutGroup) then
	if dat.fullAutGroup[1]=1 then
	  # all automs are inner.
	  result:=rec(aut:=result.aut);
	else
	  result.outerorder:=dat.fullAutGroup[1];
	  result:=rec(aut:=MorClassLoop(H,combi,result,15));
	fi;
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
  p:=Set(Factors(Size(G)));
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

  o:=List(gens,i->Order(i));
  p:=List(hens,i->Order(i));

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
  if not IsSimpleGroup(G) then
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

  elif id.series in ["L","2A","C"] then
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
  if IsSimpleGroup(G) then
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
      AssignNiceMonomorphismAutomorphismGroup(c,G); 
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
  local s, c, acts, ttypes, ttypnam, k, act, t, j, iso, w, wemb, a, au,
  auph, aup, n, wl, genimgs, thom, ahom, emb, lemb, d, ge, stbs, orb, base,
  newbas, obas, p, r, orpo, imgperm, invmap, hom, i, gen,gens,tty,count;
  #write g in a nice form
  count:=ValueOption("count");if count=fail then count:=0;fi;
  s:=Socle(g);
  if IsSimpleGroup(s) then
    return AutomorphismGroupMorpheus(g);
  fi;
  c:=ChiefSeriesThrough(g,[s]);
  acts:=[];
  ttypes:=[];
  ttypnam:=[];
  k:=g;
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
    # now embedd all

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

  #reduce degree
  s:=SmallerDegreePermutationRepresentation(aup);
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

  # produce data to map fro au to aup:
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
  elif Size(RadicalGroup(G))=1 and IsPermGroup(G) then
    # essentially a normalizer when suitably embedded 
    A:=AutomorphismGroupFittingFree(G);
  elif Size(RadicalGroup(G))>1 and CanComputeFittingFree(G) then
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
  RankFilter(IsSolvableGroup and IsFinite),
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
#F  IsomorphismGroups(<G>,<H>) . . . . . . . . . .  isomorphism from G onto H
##
InstallGlobalFunction(IsomorphismGroups,function(G,H)
local m;

  if not HasIsFinite(G) or not HasIsFinite(H) then
    Info(InfoWarning,1,"Forcing finiteness test");
    IsFinite(G);
    IsFinite(H);
  fi;
  if not IsFinite(G) and IsFinite(H) then
    Error("cannot test isomorphism of infinite groups");
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
  elif ID_AVAILABLE(Size(G)) <> fail
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

  if (Length(AbelianInvariants(G))>2 or Length(SmallGeneratingSet(G))>2) and Size(RadicalGroup(G))>1 then
    # In place until a proper implementation of Cannon/Holt automorphism is
    # made available.
    return PatheticIsomorphism(G,H);
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
local Fgens,	# generators of F
      cl,	# classes of G
      u,	# trial generating set's group
      vsu,	# verbal subgroups
      pimgs,	# possible images
      val,	# its value
      best,	# best generating set
      bestval,	# its value
      sz,	# |class|
      i,	# loop
      h,	# epis
      len,	# nr. gens tried
      fak,	# multiplication factor
      cnt;	# countdown for finish

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
	Info(InfoMorph,2,"better value: ",List(u,i->Order(i)),
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
local cl,cnt,bg,bw,bo,bi,k,gens,go,imgs,params,emb,clg,sg,vsu,c,i;

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
	if Length(gens)>2 and Random([1,2])=1 then
	  # try to get down to 2 gens
	  gens:=List([1,2],i->Random(H));
	else
	  gens:=List([1..sg],i->Random(H));
	fi;
	# try to get small orders
	for k in [1..Length(gens)] do
	  go:=Order(gens[k]);
	  # try a p-element
	  if Random([1..3*Length(gens)])=1 then
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
      cnt:=cnt+Int(bw/Size(G)*3);
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


#############################################################################
##
#E

