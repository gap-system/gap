LengthSortFun := function(a,b)
  if Length(a)=Length(b) then
    return a<b;
  else
    return Length(a)<Length(b);
  fi;
end;

ApproximationNormalizerClasses:=function(u,approx)
  local bas, prm, hashfun, e, cs, pt, classes, p, nosplit, short, better, newclasses, newnosplit, dict, spl, ej, basx, cji, spll, i, j, x, y;

  bas:=Immutable(Set(BaseStabChain(StabChainMutable(u))));
  e:=Maximum(bas)+1;
  prm:=[];
  while Length(prm)<Length(bas) do
    e:=NextPrimeInt(e);
    Add(prm,e);
    e:=e*2+1;
  od;
  MakeImmutable(prm);
  hashfun:=tup->tup*prm;
  e:=Subgroup(Parent(u),GeneratorsOfGroup(u));
  SetSize(e,Size(u));
  e:=AsList(e);
  cs:=List(e,CycleStructurePerm);
  pt:=Set(cs);
  classes:=List(pt,i->[]);
  for i in [1..Length(e)] do
    p:=Position(pt,cs[i]);
    Add(classes[p],e[i]);
  od;

  Info(InfoAli,3,"Classes: ",List(classes,Length));

  if Number(classes,i->Length(i)<10)>2 then
    return classes;
  fi;

  # check which classes are already orbits under approx
  nosplit:=List(classes,i->Length(i)=Length(Orbit(approx,i[1])));
  
  # iterated improval
  short:=true;
  #repeat

    better:=false;
    newclasses:=[];
    newnosplit:=[];

    dict:=SparseHashTable(hashfun);
    for i in [1..Length(classes)] do
      for j in classes[i] do
        AddDictionary(dict,OnTuples(bas,j),i);
      od;
    od;

    spl:=[];
    for i in [1..Length(classes)] do
      Info(InfoAli,5,"loop ",i);

      # if the length is too long, products become expensive
      if nosplit[i] or 
        (ForAny(classes,j->Length(j)>1 and Length(j)<20) 
	 and Length(classes[i])>200) or
	 (short and Length(classes[i])>50) then
	# is one orbit, can't improve
	Add(newclasses,classes[i]);
	Add(newnosplit,not short);
      else
	# test frequency of product types with other classes
	for j in [i..Length(classes)] do
#Print(i," ",j,"\n");
	  pt:=[];
	  if Length(classes[i])*Length(classes[j])<100000 then
	    cs:=[];
	    ej:=List(classes[j],z->List(classes,i->0));
	    for x in classes[i] do
	      e:=List(classes,i->0);
	      basx:=OnTuples(bas,x);

	      cji:=0;
	      for y in classes[j] do
		cji:=cji+1;
		#p:=x*y;
		#p:=PositionProperty(classes,i->p in i);
		p:=OnTuples(basx,y);
		p:=LookupDictionary(dict,p);
		e[p]:=e[p]+1;
		ej[cji][p]:=ej[cji][p]+1;
	      od;

	      p:=Position(pt,e);
	      if p=fail then
		Add(pt,e);
		p:=Length(pt);
	      fi;
	      Add(cs,p);

	    od;

	    if Length(pt)>1 then
	      # a split
	      AddSet(spl,[i,List([1..Length(pt)],
			  k->Filtered([1..Length(classes[i])],
				      l->cs[l]=k))]);
	    fi;

	    # same for classes[j]
	    cs:=[];
	    pt:=[];
	    for e in ej do
	      p:=Position(pt,e);
	      if p=fail then
		Add(pt,e);
		p:=Length(pt);
	      fi;
	      Add(cs,p);
	    od;
	    if Length(pt)>1 then
	      AddSet(spl,[j,List([1..Length(pt)],
			  k->Filtered([1..Length(classes[j])],
				      l->cs[l]=k))]);
	    fi;

	  fi;

	od;
      fi;

    od;

    if Length(spl)>0 then
      better:=true;
      for i in [1..Length(classes)] do
	spll:=List(Filtered(spl,k->k[1]=i),i->i[2]);
	if Length(spll)>0 then
	  #we get a split
	  # take all intersections of spll
	  cs:=[1..Length(classes[i])];
	  if Length(spll)=1 then
	    pt:=spll[1];
	  else
	    pt:=Set(List(cs,i->Filtered(cs,
			      j->ForAll(spll,k->j in First(k,kk->i in kk)))));
	  fi;
	else
	  pt:=[[1..Length(classes[i])]];
	fi;
	  
	pt:=List(pt,j->classes[i]{j});
	for j in pt do
	  Add(newclasses,j);
	  Add(newnosplit,not short and Length(j)=Length(Orbit(approx,j[1])));
	od;
      od;
      nosplit:=newnosplit;
      classes:=newclasses;
      Info(InfoAli,3,"improved to: ",List(classes,Length));
    fi;

    if better=false and short=true then
      # did we try only easy ones?
      short:=false;
      better:=true;
    else
      short:=true; # stay short
    fi;
  #until better=false or
  #      ForAny(classes,i->Length(i)>1 and Length(i)<20); # we did not improve
  return classes;
end;

BADSETLEN:=21;

NormalizerAutomsEAPerm:=function(arg)
local G, grp, isop, pcgs, s, un, e, z, gl, i, c, v, l, b, one, ext, hom,
      grpgens, fun,ngl,sz,sp;
  G:=arg[1];
  grp:=arg[2];

  if not IsElementaryAbelian(grp) then
    Error("grp must be el.ab");
  fi;
  isop:=IsomorphismPcGroup(grp);
  pcgs:=Pcgs(Image(isop));
  s:=Factors(Size(grp));
  gl:=GL(Length(s),s[1]);
  one:=One(GF(s[1]));

#  # include known info
#  if Length(arg)>2 then
#    # take the generators we know already
#    e:=ShallowCopy(arg[3].generators);
#
#    c:=Filtered(Elements(grp),i->i<>());
#    z:=List(c,i->p^Image(hom,i)); #corresponding numbers
#    SortParallel(z,c);
#    # and transfer them to a subgroup of a
#    un:=Subgroup(a,List(e,i->PermList(List(c,
#                                      j->p^Image(hom,j^i)))));
#    e:=arg[3];
#  else
    un:=TrivialSubgroup(gl);
    e:=TrivialSubgroup(grp);
#  fi;

  # sort elements by cycle structures &c.

  z:=ApproximationNormalizerClasses(grp,e);
  z:=Filtered(z,i->not () in i);

  Sort(z,LengthSortFun);
  Info(InfoAli,3,"set lengths: ",List(z,Length));


  # avoid some horrible calculations
  if Length(z[1])>BADSETLEN and Size(gl)>10^30 then
Print("no success !");
    return fail;
  fi;

  if Size(G)*10<Size(gl) and (Length(z)=1 or (Length(z)<4 and z[2]>100)) then
    return fail;
  fi;


  pcgs:=Pcgs(Image(isop));

  # do any sets form a subspace?
  i:=1;
  while i<=Length(z) do
    c:=TrivialSubgroup(grp);
    e:=1;
    while Size(c)<Size(grp) and e<=Length(z[i]) do
      c:=ClosureGroup(c,z[i][e]);
      e:=e+1;
    od;
    if Size(c)<Size(grp) then
      # is smaller -> Subspace stabilizer

      # extend basis
      v:=List(GeneratorsOfGroup(c),i->one*ExponentsOfPcElement(pcgs,Image(isop,i)));
      l:=Length(v);
      v:=BaseSteinitzVectors(One(gl),v);
      v:=Concatenation(v.subspace,v.factorspace); # new basis
      v:=ImmutableMatrix(GF(s[1]),v);
      # form a subspace stabilizer: GL x 1, 1xGL, id with 100.. in lower
      # left block
      b:=[];
      ngl:=GL(l,s[1]);
      sz:=Size(ngl);
      for i in GeneratorsOfGroup(ngl) do
	c:=List(One(gl),ShallowCopy);
	c{[1..l]}{[1..l]}:=i;
	c:=ImmutableMatrix(GF(s[1]),c);
	Add(b,c^v);
      od;
      ngl:=GL(Length(v)-l,s[1]);
      sz:=sz*Size(ngl);
      for i in GeneratorsOfGroup(ngl) do
	c:=List(One(gl),ShallowCopy);
	c{[l+1..Length(v)]}{[l+1..Length(v)]}:=i;
	c:=ImmutableMatrix(GF(s[1]),c);
	Add(b,c^v);
      od;
      c:=List(One(gl),ShallowCopy);
      c[Length(c)][1]:=one;
      c:=ImmutableMatrix(GF(s[1]),c);
      Add(b,c^v);
      gl:=Group(b,One(gl));
      SetSize(gl,sz*s[1]^(l*(Length(v)-l)));
      #if Size(gl)<>sz*s[1]^(l*(Length(v)-l)) then
#	Error("newsize");
#      else
#	Print("size formula confirmed");
#      fi;
      Info(InfoAli,3,"new gl");
      i:=Length(z);
    fi;
    i:=i+1;
  od;

  v:=FullRowSpace(GF(s[1]),Length(s));
  v:=Enumerator(v);
  ext:=ExternalSet(gl,v);
  hom:=ActionHomomorphism(ext,"surjective");
  b:=Image(hom);
  if HasSize(gl) then
    SetSize(b,Size(gl));
  fi;

  for i in z do
    # image elms, trf. to pts
    e:=Set(List(i,j->Position(v,ExponentsOfPcElement(pcgs,Image(isop,j))*one)));

    if ForAll(GeneratorsOfGroup(b),i->OnSets(e,i)=e) then
      c:=b;
#    elif IsBound(LEONERG) then
#      c:=SetStabilizerPermGroup(b,e);
    else
#      c:=PermGroupOps.StabilizerSet(b,e,un);
      c:=Stabilizer(b,e,OnSets);
    fi;
    if Size(b)>Size(c) then
      Info(InfoAli,3,Size(b),"->",Size(c));
    else
      Info(InfoAli,4,"No reduction");
    fi;
    b:=c;
  od;
  # now b contains only those automs, that fix the cycle structures
  # from this, deduce the normalizer

  grpgens:=List(pcgs,i->PreImage(isop,i));
  sp:=Sortex(List(grpgens,i->-NrMovedPoints(i)));
  grpgens:=Permuted(grpgens,sp);

  # a function, which checks if an automorphism is induced by a permutation
  fun:=function(perm)
    local h;
    # convert permutation to matrix=basis vector images, convert these
    # images to pc elements to permutations.
    h:=List(PreImagesRepresentative(hom,perm),
      i->PreImage(isop,PcElementByExponents(pcgs,List(i,IntFFE))));

    h:=Permuted(h,sp); # analogous permutation -- get small centralizers soon
    # Find a permutation that conjugates suitably
    h:=RepresentativeAction(G,grpgens,h,OnTuples);
    
    # as we don't want to do the work twice, we secretly store those
    # elements
    if h<>fail then 
      Add(e,h);
    fi;

    # tell SubgroupProperty about our result
    return h<>fail; 
  end;

  e:=[];

  #if Length(arg)>2 then
  #  e:=ShallowCopy(arg[3].generators);
  #  # use known part for shortening the backtrack
  #  c:=SubgroupProperty(b,fun,un);
  #else
  #Info(InfoAli,4,"in sgp ",Size(b));
  c:=SubgroupProperty(b,fun);
  #Info(InfoAli,4,"out sgp");
  #fi;

  Info(InfoAli,2,"Stabilizer:",Size(b),"=>",Size(c));
  return [Size(c),e];
end;

NormalizerEAPermGroup:=function(arg)
local l,G,U,c,n;
  G:=arg[1];
  U:=arg[2];
  l:=Factors(Size(U));
  #n:=Index(NormalClosure(ClosureGroup(G,U),U),U);
  #Info(InfoAli,3,"NorClosureIndex: ",n);
  if Size(U)=1 then
    return G;
  elif Size(U)=2 then
    return Centralizer(G,U);
  # arbitrary criterion
  else 
#     Size(U)<4000 and n>7 then
#  Maximum(Size(G),10^(24/(
#      # 2->1   3..7 ->2 &c.
#      LogInt(Maximum(OrbitLengths(U,PermGroupOps.MovedPoints(U)))+1,2)  )))
#         >=Size(GL(Length(l),l[1])) then
    if Length(arg)=2 then
      l:=NormalizerAutomsEAPerm(G,U);
    else
      l:=NormalizerAutomsEAPerm(G,U,arg[3]);
    fi;
  fi;

  if l=fail then
    # our special routine gave up or was not even called
    if Length(arg)=2 then
      return Normalizer(G,U);
    else
      return Normalizer(G,U,arg[3]);
    fi;
  fi;

  c:=Centralizer(G,U);
  n:=Group(Concatenation(GeneratorsOfGroup(c),l[2]));
  #n.size:=Size(n)*l[1];
  #if n<>Normalizer(G,U) then
    #Error("missing");
  ##fi;
  return n;
end;

