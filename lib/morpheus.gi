#############################################################################
##
#W  morpheus.gi                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains declarations for Morpheus
##
Revision.morpheus_gi:=
  "@(#)$Id$";

DecomposedRationalClass := function( cl )
    local   G,  C,  rep,  gal,  T,  cls,  e,  c;

    G := ActingDomain( cl );
    C := StabilizerOfExternalSet( cl );
    rep := Representative( cl );
    gal := GaloisGroup( cl );
    T := RightTransversal( Parent( gal ), gal );
    cls := [  ];
    for e  in T  do
        c := ConjugacyClass( G, rep ^ ( 1 ^ e ) );
        SetStabilizerOfExternalSet( c, C );
        Add( cls, c );
    od;
    return cls;
end;

#############################################################################
##
#V  MORPHEUSELMS . . . .  limit up to which size to store element lists
##
MORPHEUSELMS := 50000;

IsOperationHomomorphismAutomGroup := NewRepresentation(
  "IsOperationHomomorphismAutomGroup",
  IsOperationHomomorphismDirectly and IsOperationHomomorphismByBase,
  ["basepos"]);

#############################################################################
##
#F  StoreNiceMonomorphismAutomGroup    for small automorphism groups
##
StoreNiceMonomorphismAutomGroup := function(aut,elms,elmsgens)
local xset,fam,hom;
  xset:=ExternalSet(aut,elms);
  SetBase(xset,elmsgens);
  fam := GeneralMappingsFamily( ElementsFamily( FamilyObj( aut ) ),
				PermutationsFamily );
  hom := rec( externalSet := xset );
  hom:=Objectify(NewKind(fam,IsOperationHomomorphismAutomGroup ),hom);
  hom!.basepos:=List(elmsgens,i->Position(elms,i));
  SetIsInjective(hom,true);
  Setter(OperationHomomorphismAttr)(xset,hom);
  SetNiceMonomorphism(aut,OperationHomomorphism(xset));
  SetIsHandledByNiceMonomorphism(aut,true);
end;

#############################################################################
##
#M  PreImagesRepresentative   for OpHomAutomGrp
##
InstallMethod(PreImagesRepresentative,"AutomGroup Niceomorphism",
  FamRangeEqFamElm,[IsOperationHomomorphismAutomGroup,IsPerm],0,
function(hom,elm)
local xset,g,imgs;
  xset:=hom!.externalSet;
  g:=ActingDomain(xset);
  imgs:=OnTuples(hom!.basepos,elm);
  imgs:=Enumerator(xset){imgs};
  elm:=GroupHomomorphismByImages(g,g,Base(xset),imgs);
  SetIsBijective(elm,true);
  return elm;
end);

#############################################################################
##
#M  \*( <map1>, <map2> )  . . . . . . . . . . . . .  for two automorphisms
##
InstallMethod( \*,
    "method for two automorphisms",
    FamSource2EqFamRange1,
    [ IsGeneralMapping and IsMultiplicativeElementWithInverse,
      IsGeneralMapping and IsMultiplicativeElementWithInverse ], 0,
function( map1, map2 )
local com;
  com:=CompositionMapping2( map2, map1 );
  SetFilterObj(com,IsMultiplicativeElementWithInverse);
  return com;
end );


#############################################################################
##
#F  MorFroWords(<gens>) . . . . . . create some pseudo-random words in <gens>
##                                                featuring the MeatAxe's FRO
MorFroWords := function(gens)
local list,a,b,ab,i;
  list:=[];
  ab:=gens[1];
  for i in [2..Length(gens)] do
    a:=ab;
    b:=gens[i];
    ab:=a*b;
    list:=Concatenation(list,
	 [ab,ab^2*b,ab^3*b,ab^4*b,ab^2*b*ab^3*b,ab^5*b,ab^2*b*ab^3*b*ab*b,
	 ab*(ab*b)^2*ab^3*b]);
  od;
  return list;
end;


#############################################################################
##
#F  MorRatClasses(<G>) . . . . . . . . . . . local rationalization of classes
##
MorRatClasses := function(GR)
local r,c,u,j,i,flag;
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
end;

#############################################################################
##
#F  MorMaxFusClasses(<l>) . .  maximal possible morphism fusion of classlists
##
MorMaxFusClasses := function(r)
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
end;

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
##  free  free generators
##  rels  some relations that hold in from, given as list [word,order]
##  dom   a set of elements on which automorphisms act faithful
##  aut   Subgroup of already known automorphisms
##
##  action is a number whose bit-representation indicates the action to be
##  taken:
##  1     homomorphism
##  2     injective
##  4     surjective
##  8     find all (in contrast to one)
##
MorClassLoop := function(range,clali,params,action)
local id,result,rig,dom,tall,tsur,tinj,thom,gens,free,rels,len,el,ind,cla,m,
      mp,cen,i,imgs,ok,size,l;

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

  tall:=action>7; # try all
  if tall then
    action:=action-8;
  fi;
  tsur:=action>3; # test surjective
  if tsur then
    size:=Size(params.to);
    action:=action-4;
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
  else
    rels:=false;
  fi;

  len:=Length(clali);
  # backtrack over all classes in clali
  l:=0*[1..len]+1;
  ind:=len;
  while ind>0 do
    ind:=len;
    # test class combination indicated by l:
    cla:=List([1..len],i->clali[i][l[i]]); 
    # test, whether a gen.sys. can be taken from the classes in <cla>
    # candidates.  This is another backtrack
    m:=[];
    m[len]:=[Representative(cla[len])];
    # positions
    mp:=[];
    mp[len]:=1;
    mp[len+1]:=-1;
    # centralizers
    cen:=[];
    cen[len]:=Intersection(range,Centralizer(cla[len]));
    cen[len+1]:=range; # just for the recursion
    i:=len-1;

    # set up the lists
    while i>0 do
      m[i]:=List(DoubleCosets(range,Intersection(range,Centralizer(cla[i])),
                 cen[i+1]),j->Representative(cla[i])^Representative(j));
      mp[i]:=1;
      if i>1 then
	cen[i]:=Centralizer(cen[i+1],m[i][1]);
      fi;
      i:=i-1;
    od;
    i:=1; 

    while i<len do
      imgs:=List([1..len],i->m[i][mp[i]]);

      # computing the size can be nasty. Thus try given relations first.
      ok:=true;
      if rels<>false then
        ok:=ForAll(rels,i->Order(MappedWord(i[1],free,imgs))=i[2]);
      fi;

      # check surjectivity
      if tsur and ok then
        ok:=Size(Group(imgs,id))=size;
      fi;

      if thom then
        imgs:=GroupGeneralMappingByImages(params.from,range,gens,imgs);
	SetIsTotal(imgs,true);
	Info(InfoMorph,3,"testing");
	ok:=IsSingleValued(imgs);
	if ok and tinj then
	  ok:=IsInjective(imgs);
	fi;
      fi;
      
      if ok then
	Info(InfoMorph,2,"found");
	# do we want one or all?
	if tall then
	  if tinj and tsur then
	    #AH: Geht das gut ?
	    SetFilterObj(imgs,IsMultiplicativeElementWithInverse);
	  fi;
	  if rig then
	    if not imgs in result then
	      result:=Group(Concatenation(GeneratorsOfGroup(result),[imgs]),
			    One(result));
	      StoreNiceMonomorphismAutomGroup(result,dom,gens);
	      Size(result);
	      Info(InfoMorph,2,"new ",Size(result));
	    fi;
	  else
	    Add(result,imgs);
	  fi;
	else
	  return imgs;
        fi;
      fi;

      mp[i]:=mp[i]+1;
      while i<=len and mp[i]>Length(m[i]) do
	mp[i]:=1;
	i:=i+1;
	mp[i]:=mp[i]+1;
      od;
      if i<=len then
	while i>1 do
	  cen[i]:=Centralizer(cen[i+1],m[i][mp[i]]);
	  i:=i-1;
	  m[i]:=List(DoubleCosets(range,Intersection(range,
	                                             Centralizer(cla[i])),
                 cen[i+1]),j->Representative(cla[i])^Representative(j));
	  mp[i]:=1;
	od;
      fi;
    od;

    # 'free for increment'
    l[ind]:=l[ind]+1;
    while ind>0 and l[ind]>Length(clali[ind]) do
      l[ind]:=1;
      ind:=ind-1;
      if ind>0 then
	l[ind]:=l[ind]+1;
      fi;
    od;
  od;

  return result;
end;


#############################################################################
##
#F  MorFindGeneratingSystem(<G>,<cl>) . .  find generating system with an few 
##                      as possible generators from the first classes in <cl>
##
MorFindGeneratingSystem := function(G,cl)
local lcl,len,comb,combc,com,a;
  Info(InfoMorph,1,"FindGenerators");
  # throw out the 1-Class
  cl:=Filtered(cl,i->Length(i)>1 or Size(i[1].representative)>1);

  #create just a list of ordinary classes.
  lcl:=List(cl,i->Concatenation(List(i,j->j.classes)));
  len:=1;
  Print("#W  no IrreducibleGeneratingSet implemented\n");
  #len:=Maximum(1,Length(IrreducibleGeneratingSet(
#		    AgGroup((G/DerivedSubgroup(G)))))-1);
  while true do
    len:=len+1;
    # now search for <len>-generating systems
    comb:=UnorderedTuples([1..Length(lcl)],len); 
    combc:=List(comb,i->List(i,j->lcl[j]));

    # test all <comb>inations
    com:=0;
    while com<Length(comb) do
      com:=com+1;
      a:=MorClassLoop(G,combc[com],rec(to:=G),4);
      if Length(a)>0 then
        return a;
      fi;
    od;
  od;
end;

#############################################################################
##
#F  Morphium(<G>,<H>,<DoAuto>) . . . . . . . .Find isomorphisms between G and H
##       modulo inner automorphisms. DoAuto indicates whetehra all
## 	 automorphism are to be found
##       This function thus does the main combinatoric work for creating 
##       Iso- and Automorphisms.
##       It needs, that both groups are not cyclic.
##
Morphium := function(G,H,DoAuto)
local 
      len,comb,combc,com,combi,l,m,mp,cen,Gr,Gcl,Ggc,Hr,Hcl,
      ind,gens,i,j,c,cla,u,lcl,hom,isom,free,elms,price,result,rels,inns;

  # try the given generating system
  #if IsAgGroup(G) then
  #  gens:=IrreducibleGeneratingSet(G);
  #else
    gens:=GeneratorsOfGroup(G);
  #fi;
  len:=Length(gens);
  Gr:=MorRatClasses(G);
  Gcl:=MorMaxFusClasses(Gr);

  Ggc:=List(gens,i->First(Gcl,j->ForAny(j,j->ForAny(j.classes,k->i in k))));
  combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
  price:=Product(combi,i->Sum(i,Size));
  Info(InfoMorph,1,"generating system of price:",price,"");

  if #not IsAgGroup(G) and 
    price>20000  then

    #if IsSolvable(G) and what=2 then
    #  gens:=AgGroup(G);
    #  gens:=List(IrreducibleGeneratingSet(gens),i->Image(gens.bijection,i));
    #else
      gens:=MorFindGeneratingSystem(G,Gcl);
    #fi;

    Ggc:=List(gens,i->First(Gcl,j->ForAny(j,j->ForAny(j.classes,k->i in k))));
    combi:=List(Ggc,i->Concatenation(List(i,i->i.classes)));
    price:=Product(combi,i->Sum(i,Size));
    Info(InfoMorph,1,"generating system of price:",price,"");
  fi;

  if not DoAuto then
    Hr:=MorRatClasses(H);
    Hcl:=MorMaxFusClasses(Hr);
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
	return false;
      else
	Add(combi,c[1]);
      fi;
    od;
    combi:=List(combi,i->Concatenation(List(i,i->i.classes)));
  fi;

  # combi contains the classes, from which the
  # generators are taken.

  free:=GeneratorsOfGroup(FreeGroup(Length(gens)));
  rels:=MorFroWords(free);
  rels:=List(rels,i->[i,Order(MappedWord(i,free,gens))]);
  result:=rec(gens:=gens,from:=G,to:=H,free:=free,rels:=rels);

  if DoAuto then

    inns:=List(GeneratorsOfGroup(G),i->InnerAutomorphism(G,i));
    if Size(G)<=MORPHEUSELMS then
      elms:=Union(List(Set(List(Flat(combi),Representative)),i->Orbit(G,i)));
      result.dom:=elms;
      inns:=Group(inns,IdentityMapping(G));
      StoreNiceMonomorphismAutomGroup(inns,elms,gens);
      result.aut:=inns;
    else
      elms:=false;
    fi;

    result:=rec(aut:=MorClassLoop(H,combi,result,15));

    if elms<>false then
      result.elms:=elms;
      result.elmsgens:=gens;
      inns:=SubgroupNC(result.aut,GeneratorsOfGroup(inns));
    fi;
    result.inner:=inns;
  else
    result:=MorClassLoop(H,combi,result,7);
  fi;

  return result;

end;

#############################################################################
##
#F  AutomorphismGroupAbelianGroup(<G>)
##
AutomorphismGroupAbelianGroup := function(G)
local i,j,k,l,m,o,nl,nj,max,r,e,au,p,gens,offs;

  # get standard generating system
  if not IsPermGroup(G) then
    p:=IsomorphismPermGroup(G);
    gens:=IndependentGeneratorsAbelianPermGroup(Image(p));
    gens:=List(gens,i->PreImagesRepresentative(p,i));
  else
    gens:=IndependentGeneratorsAbelianPermGroup(G);
  fi;

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
	Add(au,GroupHomomorphismByImages(G,G,Concatenation(nl,nj,j[2]),
	    #(1,2)
	    Concatenation(nl,nj,j[2]{[2]},j[2]{[1]},j[2]{[3..Length(j[2])]})));
	Add(au,GroupHomomorphismByImages(G,G,Concatenation(nl,nj,j[2]),
	    #(1,..,n)
	    Concatenation(nl,nj,j[2]{[2..Length(j[2])]},j[2]{[1]})));
	#for k in [0..j[1]-1] do
        k:=0;
	  Add(au,GroupHomomorphismByImages(G,G,Concatenation(nl,nj,j[2]),
	      #1->1+i^k*2
	      Concatenation(nl,nj,[j[2][1]*j[2][2]^(i^k)],
	                          j[2]{[2..Length(j[2])]})));
        #od;
      fi;
  
      # multiplications

      for k in List(GeneratorsOfGroup(PrimeResidueClassGroup(i^j[1])),
                    i->1^i) do

	Add(au,GroupHomomorphismByImages(G,G,Concatenation(nl,nj,j[2]),
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
	    Add(au,GroupHomomorphismByImages(G,G,
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
    SetFilterObj(i,IsMultiplicativeElementWithInverse);
  od;

  au:=Group(au,IdentityMapping(G));

  if Size(G)<MORPHEUSELMS then
    # note permutation action
    StoreNiceMonomorphismAutomGroup(au,
      Filtered(AsList(G),i->Order(i)>1),
      GeneratorsOfGroup(G));
  fi;
  SetInnerAutomorphismsAutomorphismGroup(au,TrivialSubgroup(au));

  return au;
end;

#############################################################################
##
#F  IsomorphismAbelianGroups(<G>)
##
IsomorphismAbelianGroups := function(G,H)
local o,p,gens,hens;

  # get standard generating system
  if not IsPermGroup(G) then
    p:=IsomorphismPermGroup(G);
    gens:=IndependentGeneratorsAbelianPermGroup(Image(p));
    gens:=List(gens,i->PreImagesRepresentative(p,i));
  else
    gens:=IndependentGeneratorsAbelianPermGroup(G);
  fi;

  # get standard generating system
  if not IsPermGroup(H) then
    p:=IsomorphismPermGroup(H);
    hens:=IndependentGeneratorsAbelianPermGroup(Image(p));
    hens:=List(hens,i->PreImagesRepresentative(p,i));
  else
    hens:=IndependentGeneratorsAbelianPermGroup(H);
  fi;

  o:=List(gens,i->Order(i));
  p:=List(hens,i->Order(i));

  SortParallel(o,gens);
  SortParallel(p,hens);

  if o<>p then
    return false;
  fi;

  o:=GroupHomomorphismByImages(G,H,gens,hens);
  SetIsBijective(o,true);

  return o;
end;

#############################################################################
##
#M  AutomorphismGroup(<G>) . . group of automorphisms, given as Homomorphisms
##
InstallMethod(AutomorphismGroup,"Group",true,[IsGroup],0,
function(G)
local a;
  if IsAbelian(G) then
    return AutomorphismGroupAbelianGroup(G);
  fi;
  a:=Morphium(G,G,true);
  if IsList(a.aut) then
    a.aut:=Group(a.aut,IdentityMapping(G));
    a.inner:=SubgroupNC(a.aut,a.inner);
  fi;
  SetInnerAutomorphismsAutomorphismGroup(a.aut,a.inner);
  return a.aut;
end);


#############################################################################
##
#F  IsomorphismGroups(<G>,<H>) . . . . . . . . . .  isomorphism from G onto H
##
IsomorphismGroups := function(G,H)
local m,n;

  #AH: Spezielle Methoden ?
  if Size(G)=1 then
    return GroupHomomorphismByImages(G,H,[],[]);
  fi;
  if IsAbelian(G) then
    if not IsAbelian(H) then
      return false;
    else
      return IsomorphismAbelianGroups(G,H);
    fi;
  fi;

  Print("GroupId not yet implemented\n");
  if Size(G)<>Size(H) or
     Length(ConjugacyClasses(G))<>Length(ConjugacyClasses(H))
     #or (Size(G)<=100 and GroupId(G)<>GroupId(H))
     then
   return false;
  fi;

  m:=Morphium(G,H,false);
  if IsList(m) and Length(m)=0 then
    return false;
  else
    return m;
  fi;

end;

#############################################################################
##
#E  morpheus.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
