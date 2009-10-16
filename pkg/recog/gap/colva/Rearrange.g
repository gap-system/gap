MyIsInnerAutomorphism := function(grp,name,phi,membershiptest)
# Is phi an inner automorphism (possibly modulo scalars) of the quasisimple matrix group grp or direct product of quasisimple groups of given names?
# membership test is a membership test in grp
 local m,g,gens,ims1,oz,o,z,ims,F,M1,M2,mat,t,i,detmat,z1,j,d
       ,el,t1,k,names,celt,gp,mtest,kappa,bool; 


# Have to deal with each direct product component seperately
 names := SplitString(name,",");
 celt := One(grp);

 for k in [1..Length(names)] do
   if IsDirectProduct(grp) then
     gp := Image(MyProjection(grp,k));
     kappa := GroupHomomorphismByFunction(gp,gp,g->
ImageElm(MyProjection(grp,k),ImageElm(phi,ImageElm(MyEmbedding(grp,k),g))));
     #I'm pretty sure that the following is safe....
     SetIsBijective(kappa, true);
     mtest := g->membershiptest(ImageElm(MyEmbedding(grp,k),g));
   else
     gp := grp;
     kappa := phi;
     mtest := membershiptest;
   fi;
   
  #was falling over with socle factor A_5s cos they became perm grps,
  #hopefully this will catch it.
  if IsPermGroup(gp) then
    bool:= IsInnerAutomorphism(kappa);
    if not bool then 
      return false;
    elif not IsDirectProduct(grp) then
      return ConjugatorOfConjugatorIsomorphism(kappa);
    else
      celt:= celt*ImageElm(MyEmbedding(grp, k), ConjugatorOfConjugatorIsomorphism(kappa));
      break;
    fi;
  fi;

# First construct a generating set of elts of order coprime to the schur multiplier
   m := SchurMultiplierOrder(names[k]);
   g := ElementOfCoprimeOrder(gp,m);
# Compute a number of random conjugates of g to get a probable generating set for gp

   gens := Concatenation([g],List([1..5],i->g^PseudoRandom(gp)));
 
# compute the images of gens under phi
   ims1 := List(gens,x->ImageElm(kappa,x));

# alter images to remove the scalar parts
   oz := List(ims1,x->ProjectiveOrder(x));
   o := List(oz,x->x[1]);
   z := List(oz,x->x[2]);
   m := List([1..Size(z)],i->-1/o[i] mod Order(z[i]));
   ims := List([1..Size(z)],i->ims1[i]*z[i]^m[i]);


# Do we have module isomorphisms?

   F := FieldOfMatrixGroup(gp);
   M1 := GModuleByMats(gens,F);
   M2 := GModuleByMats(ims,F);

   mat := MTX.IsomorphismModules(M1,M2); 
   if not IsMatrix(mat) then return false; fi;



# So we have some scalar matrix z with z*mat in grp?
   z := PrimitiveElement(F);

   d := DimensionOfMatrixGroup(gp);
# This should be included when LogFFE stops returning an error if # there is no solution

   detmat := Determinant(mat);
   j := LogFFE(detmat^-1,z^d);
   if j = fail then return false; fi;
   z1 := z^(GcdInt(Size(F)-1,d));

#   for i in [0..Order(z)-1] do
   for i in [0..Order(z1)-1] do
     t := (z1^i*z^j)*One(gp)*mat;
#     t := (z^i)*One(gp)*mat;
     if IsStraightLineProgram(mtest(t)) then 
       if IsDirectProduct(grp) then
         celt := celt * ImageElm(MyEmbedding(grp,k),t);
         break;
       else
         return t;
       fi;
     fi;
     if i = Order(z1)-1 then return false; fi;
   od;
 od; 
 return celt;
end;

# Can we push past a nonabelian layer? generally used to try to push past the socle.
PastNonAb := function(ri)
 local x,riker,aut,w,preim,t,inns,i,innspreims,y,l,rihom,kerhom
       ,zeta, conj_elt;

 
 x := pregensfac(ri)[1];
 if IsDirectProduct(group(factor(kernel(ri)))) and not IsTrivial(PermAction(GroupWithGenerators([x]),group(kernel(ri)),homom(kernel(ri)),group(factor(kernel(ri))))) then return false;
 fi;

 riker := kernel(ri);
# Consider the automorphism of factor(riker) induced by x
 aut := GroupHomomorphismByFunction(group(factor(riker)),group(factor(riker)),
function(g)
 local w,preim;
 w := slpforelement(factor(riker))(factor(riker),g); 
 preim := ResultOfStraightLineProgram(w,pregensfac(riker));
 return ImageElm(homom(riker),preim^x);
end);
# Is aut inner? - tell it that it's an automorphism.
 SetIsBijective(aut, true);
 t := MyIsInnerAutomorphism(group(factor(riker)),Name(factor(riker)),aut,g->slpforelement(factor(riker))(factor(riker),g));
 if t=false then return false; fi;

# Check that all automorphisms induced by prefacgens induce inner auto's
 inns := [t];
 for i in [2..Length(pregensfac(ri))] do
   x := pregensfac(ri)[i];
   aut := GroupHomomorphismByFunction(group(factor(riker)),group(factor(riker)),
function(g)
 local w,preim;
 w := slpforelement(factor(riker))(factor(riker),g); 
 preim := ResultOfStraightLineProgram(w,pregensfac(riker));
 return ImageElm(homom(riker),preim^x);
end);
   conj_elt:= MyIsInnerAutomorphism(group(factor(riker)),Name(factor(riker)),aut,g->slpforelement(factor(riker))(factor(riker),g));
   if conj_elt = false then return false; fi;
   Add(inns, conj_elt);
 od;


 innspreims := List(inns, t->ResultOfStraightLineProgram(slpforelement(factor(riker))(factor(riker),t),pregensfac(riker)));

# Construct a lifting into the centraliser
 y := List([1..Length(innspreims)],i->pregensfac(ri)[i]*innspreims[i]^-1);
# Define a lifting -
 l := x->ResultOfStraightLineProgram(slpforelement(factor(ri))(factor(ri),x),y);


 rihom := StructuralCopy(homom(ri));
 kerhom := StructuralCopy(homom(riker));
 zeta := GroupHomomorphismByFunction(group(ri),group(factor(riker)),function(g)
 local g1;
 g1 := l(ImageElm(rihom,g));
 return ImageElm(kerhom,g*g1^-1);
 end);

 return zeta;
end;

#returns a function from group(ri) to group(factor(kernel(ri))) if can do so, 
#otherwise returns false.
AbPastAb := function(ri)
## Tries to push an abelian layer past another abelian layer where the layers are over different primes
 local x,riker,i,im,q,l,zeta;

 x := pregensfac(ri)[1];
 riker := kernel(ri);;
# Does x act trivially on factor(riker)
 for i in [1..Length(nicegens(factor(riker)))] do
   im := ImageElm(homom(riker),pregensfac(riker)[i]^x);
   if im <> nicegens(factor(riker))[i] then
     return false; 
   fi;
 od;

# Now we know x acts trivially on factor(riker)
# Construct the new lifting
 q := group(factor(riker))!.Pcgs!.RelativeOrders[1];
 l := GroupHomomorphismByImagesNC(group(factor(ri)),group(ri),List(nicegens(factor(ri)),x->x^q),List(pregensfac(ri),x->x^q));  
 
# Construct the new map
 zeta := GroupHomomorphismByFunction(group(ri),group(factor(riker)),g->ImageElm(homom(riker),g*ImageElm(homom(ri)*l,g)^-1));
 return zeta;
end;   
       

AbPastAbSamePrime := function(ri)
## Tries to push an abelian layer past another abelian layer where the layers are over the same prime. returns a list of homs in this case
 local x,riker,i,im,p,l,psi,checkelts1,checkelts2,D,phi,pregens,
       g,M,CS,maps,zeta,k,AcGens,L,intorikerfac;

 x := pregensfac(ri)[1];
 riker := kernel(ri);;
 if not SanityCheck(ri) then
   Error(179);
 fi;
# Does x act trivially on factor(riker)
 for i in [1..Length(nicegens(factor(riker)))] do
   im := ImageElm(homom(riker),pregensfac(riker)[i]^x);
   if im <> nicegens(factor(riker))[i] then
     return [false]; 
   fi;
 od;

# Construct a map down onto the direct product of the two factor groups
 p := group(factor(riker))!.Pcgs!.RelativeOrders[1];
 l := GroupHomomorphismByImagesNC(group(factor(ri)),group(ri),nicegens(factor(ri)),pregensfac(ri));  
 psi := GroupHomomorphismByFunction(group(ri),group(factor(riker)),g->ImageElm(homom(riker),g*ImageElm(l,ImageElm(homom(ri),g))^-1));
# check generators and relations of facto(ri) map to 1 under psi
 checkelts1 := List(pregensfac(ri),x->x^p);
 if not ForAll(checkelts1,x->IsOne(ImageElm(psi,x))) then return [false]; fi;
 checkelts2 := Concatenation(List([1..Length(pregensfac(ri))],i->List([(i+1)..Length(pregensfac(ri))],j->Comm(pregensfac(ri)[i],pregensfac(ri)[j]))));
 if not ForAll(checkelts2,x->IsOne(ImageElm(psi,x))) then return [false]; fi;
 
 D := DirectProduct(group(factor(ri)),group(factor(riker)));  
 phi := GroupHomomorphismByFunction(group(ri),D,g->ImageElm(homom(ri)*Embedding(D,1),g)*ImageElm(psi*Embedding(D,2),g));
 pregens := Concatenation(pregensfac(ri),pregensfac(riker));
# Construct the action of G on D
 AcGens := [];
 for g in GeneratorsOfGroup(overgroup(ri)) do
   Add(AcGens,List(pregens,x->ExponentsOfPcElement(Pcgs(D),ImageElm(phi,x^g))));
 od;
# Construct the minimal submodules of the module 
 M := GModuleByMats(Z(p)^0*AcGens,GF(p));
 CS := MTX.BasesMinimalSubmodules(M);

# get the list of normal subgroups
  
 L := List(CS,x->
SubgroupNC(D,List(x,v->VectortoPc(v,D))));
 for i in [1..Length(L)] do
   if L[i]=Image(MyEmbedding(D,2)) then Remove(L,i); break; fi;
 od;
 if Length(L)=0 then return [false]; fi;


 maps := List(L,x->NaturalHomomorphismByNormalSubgroupNC(D,x));
 intorikerfac := List(maps,x->IsomorphismGroups(Range(x),group(factor(riker))));


 zeta := List([1..Length(L)],i->GroupHomomorphismByFunction(group(ri),group(factor(riker)),g->ImageElm(intorikerfac[i],ImageElm(maps[i],ImageElm(phi,g)))));
 return zeta;
end;

NonAbPastAb := function(ri)
## Tries to push a non abelian layer past an abelian layer. This algorithm is randomized due to the lack of presentations. 
## Only works if the nonabelian layer is a perm group
 local x,riker,i,target_size,s,im,gens,g,p,words,invims,invims1,gens2,
    zeta,h,lift,g1;

 if not IsPermGroup(group(factor(ri))) then return false; fi;
 x := pregensfac(ri)[1];
 riker := kernel(ri);;
# Does x act trivially on factor(riker)
 for i in [1..Length(nicegens(factor(riker)))] do
   im := ImageElm(homom(riker),pregensfac(riker)[i]^x);
   if im <> nicegens(factor(riker))[i] then
     return false; 
   fi;
 od;
 
# construct a new generating set of elts coprime to p

  p := group(factor(riker))!.Pcgs!.RelativeOrders[1];
  target_size:= Size(factor(ri));
  gens := [];
  #first see if just 4 generators will suffice
  for i in [1..4] do
    repeat
      g := PseudoRandom(group(factor(ri)));
      g := g^(p^Valuation(Order(g),p));
    until not IsOne(g);
    Add(gens,g);
  od;
  #this contains known upper limit target_size for Group(gens);
  s:= StabChain(GroupWithGenerators(gens), rec(random:= 1, 
                                        limit:= target_size));
  #if haven't yet found enough, add extra generators
  #one-by-one and check each time.
  while SizeStabChain(s) < target_size do
    repeat
      g := PseudoRandom(group(factor(ri)));
      g := g^(p^Valuation(Order(g),p));
    until not IsOne(g);
    Add(gens, g);
    s:= StabChain(GroupWithGenerators(gens), rec(random:= 1, 
                limit:= target_size));
  od;
  
 #all of these were PseudoRandom(group(ri)) but since that's a matrix
 #group i presume should be conjugating in factor(ri) - Colva.
 #Add(gens,g^PseudoRandom(group(factor(ri))));  
 #Add(gens,g^PseudoRandom(group(factor(ri)))); 
 #Add(gens,g^PseudoRandom(group(factor(ri))));
 #repeat
 #  g := PseudoRandom(group(factor(ri)));
 #  g := g^(p^Valuation(Order(g),p));
 #until not IsOne(g);
 #Add(gens,g);  
 #Add(gens,g^PseudoRandom(group(factor(ri))));  
 #Add(gens,g^PseudoRandom(group(factor(ri)))); 
 #Add(gens,g^PseudoRandom(group(factor(ri))));

 words := List(gens,x->SLPforElement(factor(ri),x));
 invims1 := List(words,w->ResultOfStraightLineProgram(w,pregensfac(ri)));
 invims := List(invims1,x->x^(p^Valuation(Order(x),p)));
 #should this be invims1 or invims in next line???
 gens2 := List(invims, x->ImageElm(homom(ri),x));
 lift := GroupHomomorphismByImagesNC(group(factor(ri)),group(ri),gens2,invims);
 zeta := GroupHomomorphismByFunction(group(ri),group(factor(riker)),g->ImageElm(homom(riker),g*ImageElm(lift, ImageElm(homom(ri),g))^-1));


# Do some random testing of elts to check that zeta is a hom
 for i in [1..20] do
   g := PseudoRandom(group(ri));   
   g1:= ImageElm(zeta, g);
   h := PseudoRandom(group(ri));
   if g1*ImageElm(zeta,h)<>ImageElm(zeta,g*h) then 
     return false; 
   fi;
 od;
 return zeta;
end;


PushIntoSocle := function(ri,zeta)
# ri is the layer of the tree just above the socle. riker maps into the socle and zeta is a map from group(ri) ino the socle
 local riker,D,phi,im1,im2,nri,nrifac,list,g,overgp;


 riker := kernel(ri);;
# Form the direct product of the socle
 D := DirectProduct(group(factor(ri)),group(factor(riker)));
# and the new map phi from group(ri) -> D
 phi := GroupHomomorphismByFunction(group(ri),D,function(g)
local im1,im2;
im1 := ImageElm(homom(ri),g);
im2 := ImageElm(zeta,g);
return ImageElm(MyEmbedding(D,1),im1)*ImageElm(MyEmbedding(D,2),im2);
end);


 overgp := ShallowCopy(overgroup(ri));

# setup the new record for the factor - this is the product of factor(ri) and factor(riker)
 nrifac := rec();
 Objectify( RecognitionInfoType, nrifac );;

#new factor group is direct product of old factor groups, both are now in the socle.
 Setgroup(nrifac,D);

#map the nicegens for each factor into the direct product, and take both sets of nicegens.
 Setnicegens(nrifac,Concatenation(List(nicegens(factor(ri)),x->ImageElm(MyEmbedding(D,1),x)),List(nicegens(factor(riker)),x->ImageElm(MyEmbedding(D,2),x))));

 SetFilterObj(nrifac,IsLeaf);
 Setfhmethsel(nrifac,"socle"); 
 Setslpforelement(nrifac, function(nrifac,g)

   local list;
   list := [SLPforElement(factor(ri),ImageElm(MyProjection(D,1),g)),SLPforElement(factor(riker),ImageElm(MyProjection(D,2),g))];
   if fail in list then return fail; fi;
   return MyDirectProductOfSLPsList(list);
 end
 );
 SetSize(nrifac,Size(factor(ri))*Size(factor(riker)));
 SetFilterObj(nrifac,IsReady);

# setup the new record for the subgroup - nri will take the place of the old ri, but iwth 
#ker(riker) as its kernel and nrifac, the new socle, as its factor.
 nri := rec();
 Objectify( RecognitionInfoType, nri );;
 Setfactor(nri,nrifac);
 Setgroup(nri,group(ri));
 if Hasparent(ri) then
   Setparent(nri,parent(ri));
   Setkernel(parent(nri),nri);
   if not SanityCheck(parent(nri)) then
     Error(1);
   fi;
 fi;
 if Haskernel(riker) and kernel(riker) = fail then
   Setkernel(nri, fail);
 elif Haskernel(riker) then
   Setkernel(nri,kernel(riker)); 
   Setparent(kernel(nri),nri);
   if not SanityCheck(nri) then
     Error(2);
   fi;
 fi;
 Sethomom(nri,phi);
## Construct the preimages
 Setpregensfac(nri,Concatenation(
List(pregensfac(ri),g->
g*ResultOfStraightLineProgram(SLPforElement(factor(riker),ImageElm(phi*MyProjection(D,2),g)),pregensfac(riker))^-1),
pregensfac(riker)));
 #this was causing problems with the kernel was fail. 
 if Haskernel(nri) and kernel(nri) <> fail then
   Setnicegens(nri,Concatenation(pregensfac(nri),nicegens(kernel(nri))));
 elif Haskernel(nri) then 
 #so the kernel is the trivial group, just need preimages of the socle generators.
   Setnicegens(nri, pregensfac(nri));
 fi;
 Setcalcnicegens(nri,CalcNiceGensHomNode);
 SetName(nrifac,Concatenation(Name(factor(ri)),",",Name(factor(riker))));
 Setslpforelement(nri,SLPforElementGeneric);
 Setovergroup(nri,overgp);
 SetFilterObj(nri,IsReady);
 if not SanityCheck(nri) then
   Error(10001);
 fi;
 return nri;
end;


#this function is used for all position swaps other than pushing a factor
#into the socle.
SwapFactors := function(ri,zeta)
# Swaps the layers of the tree at ri using the map
# zeta : group(ri) -> group(factor(kernel(ri)))


 local riker,rifac,rikerfac,nri,nriker,overgp;

 riker := kernel(ri);;
 rifac := factor(ri);;
 rikerfac := factor(riker);;

# setup the new record for the factor
 nri := rec();
 Objectify( RecognitionInfoType, nri );;
 nriker := rec();
 Objectify( RecognitionInfoType, nriker );;

 Sethomom(nriker,StructuralCopy(homom(ri)));
 Sethomom(nri,zeta);
 Setpregensfac(nri,StructuralCopy(pregensfac(riker)));
 Setpregensfac(nriker,List(pregensfac(ri),x->x*ResultOfStraightLineProgram(SLPforElement(rikerfac,ImageElm(zeta,x)),pregensfac(riker))^-1));  
 Setkernel(nriker,StructuralCopy(kernel(riker)));
 Setparent(kernel(nriker),nriker);
 Setparent(nriker,nri);
 Setkernel(nri, nriker);
 if not SanityCheck(nri) then
   Error(3);
 fi;
 Setfactor(nriker,StructuralCopy(factor(ri)));
 #next two lines had capital p for parent before.
 #if IsBound(ri!.parent) then not sure whether should be checking Hasparent, try that instead.
 if Hasparent(ri) then
   Setparent(nri,StructuralCopy(parent(ri)));
   Setkernel(parent(nri),nri);
   if not SanityCheck(parent(nri)) then
     Error(4);
   fi;
 fi;
 if Haskernel(riker) then
   Setkernel(nriker,kernel(riker)); 
   Setparent(kernel(riker),nriker);
   if not SanityCheck(nri) then
     Error(5);
   fi;
 fi;
 Setfactor(nri,StructuralCopy(factor(riker)));
 #value of nicegens is either the ones of the image on their own if kernel
 #is trivial, or gens for image plus gens for kernel.
 if Haskernel(nriker) and not (kernel(nriker) = fail) then
   Setnicegens(nriker,Concatenation(pregensfac(nriker),nicegens(kernel(nriker))));
 else
   Setnicegens(nriker, pregensfac(nriker));
 fi;
 Setnicegens(nri,Concatenation(pregensfac(nri),nicegens(nriker)));
 Setcalcnicegens(nri,CalcNiceGensHomNode);
 Setcalcnicegens(nriker,CalcNiceGensHomNode);
 Setgroup(nri,StructuralCopy(group(ri)));
 #the group of nriker is the generators of the group of its kernel(if nontrivial) plus the preimages of the factor.
 if Haskernel(nriker) and not kernel(nriker) = fail then
   Setgroup(nriker,GroupWithGenerators(Concatenation(GeneratorsOfGroup(group(kernel(nriker))),pregensfac(nriker))));
 elif Haskernel(nriker) then
   Setgroup(nriker,GroupWithGenerators(pregensfac(nriker)));
 fi;
 Setslpforelement(nri,SLPforElementGeneric);
 Setslpforelement(nriker,SLPforElementGeneric);   
 overgp := ShallowCopy(overgroup(ri));
 Setovergroup(nri,overgp);
 Setovergroup(nriker,overgp);
 SetFilterObj(nri,IsReady);
 SetFilterObj(nriker,IsReady);
 if not SanityCheck(nri) then
   Error(79);
 fi;
 return nri;
end;


#this checks that every factor group in the chief tree is polycyclic, if
#so then group is soluble.
IsSolubleTree := function(ri)
 if not IsBound(group(factor(ri))!.Pcgs) then return false; fi;
 if ri!.kernel <> fail then return IsSolubleTree(kernel(ri));
 else
   return true;
 fi;
end;  


#this is the main function for the rearrangement. We have three nodes, namely pri, 
#priker and ker(priker) with corresponding factor groups prifac and prikerfac, and are trying 
#to either put prifac and prikerfac on the same level (if they are both nonabelian simple and #hence part of the socle), or push prifac past prikerfac.

PushDown := function(pri)
 local priker,prifac,prikerfac,zeta,i,npri,nnpri,knpri;

 priker := kernel(pri);
 prifac := factor(pri);
 prikerfac := factor(priker);

# Compute the push down maps - they depend on which groups are abelian.

 if not IsBound(group(prikerfac)!.Pcgs) then
# prikerfac is nonabelian
   Print("Calling PastNonAb(pri)\n");
   zeta := [PastNonAb(pri)]; 

 elif not IsBound(group(prifac)!.Pcgs) then
# prikerfac is abelian and priker is nonabelian
   Print("Calling NonAbPastAb(pri)\n");
   zeta := [NonAbPastAb(pri)];   

 elif group(prifac)!.Pcgs!.RelativeOrders[1] = group(prikerfac)!.Pcgs!.RelativeOrders[1] then
# prifac and prikerfac are abelian over the same prime, this function returns a list of maps.
  Print("doing AbPastAbSamePrime\n"); 
  zeta := AbPastAbSamePrime(pri);

 else		
#both groups are abelian over different primes.
  Print("Calling AbPastAb");
   zeta := [AbPastAb(pri)];
 fi;

 if zeta = [false] then
   Print("zeta was false, record is now\n");
   View(pri); 
   return false; 
 fi;

# Is factor(priker)) the socle, i.e. are we pushing down into or 
#past the socle?
 if IsBound(prikerfac!.TFordered) and prikerfac!.TFordered="Socle" then
   zeta := zeta[1];
 #if both groups are insoluble then they should both be in the socle together.
   if not IsBound(group(prifac)!.Pcgs) then
     npri := PushIntoSocle(pri,zeta);;
     SetTFordered(factor(npri),"Socle"); 
   else
 #otherwise we should put prifac below prikerfac.
     npri := SwapFactors(pri,zeta);;
   fi;
   View(npri);
   if not SanityCheck(parent(npri)) then
     Error(101);
   fi;
   return npri;
 fi;

#this is the case where factor(priker) is not the socle, we try 
#each of our maps in turn and 
#look to see whether we can push pri down a level, then recurse to 
#try to push it down further. 
#successful recursion terminates once we've pushed it down past or 
#into the socle - the previous paragraph of this code. if we can't 
#do that then there's no point moving it at all.
 for i in [1..Length(zeta)] do
   Print("trying zeta, i is", i, "\n");
   npri := SwapFactors(StructuralCopy(pri),zeta[i]);;
   knpri := PushDown(StructuralCopy(kernel(npri)));;
#having a problem with something believing it's got a parent when it doesn't.
   if knpri <> false and npri <> false then 
#found a map that works.
     Setkernel(npri,knpri);
     Setparent(knpri,npri);
     if not SanityCheck(npri) then
       Error(6);
     fi;
     Setnicegens(npri,Concatenation(pregensfac(npri),nicegens(knpri)));
     View(npri);
     if not SanityCheck(npri) then 
       Error(7);
     fi;
     return npri; 
   fi;
 od;
 return false;
end;
     



OrderTree := function(ri)
# Order the tree as in the TF model
 local lastnonabri,pri,npri;

  ri:= StructuralCopy(ri);
# Is the tree soluble? in that case all is O_{\infty}(G) already.
 if IsSolubleTree(ri) then return ri; fi;
# Is G simple?
 if ((not Haskernel(ri)) or (kernel(ri) = fail)) then return ri; fi;

# Find the last non-abelian chief factor.
 lastnonabri := StructuralCopy(ri);
 while kernel(lastnonabri) <> fail and not IsSolubleTree(kernel(lastnonabri)) do
   lastnonabri := kernel(lastnonabri);
 od;

# Tell that chief factor that it will be where the socle collects.
 SetTFordered(factor(lastnonabri),"Socle");


# Go to socle layer.
 pri:= StructuralCopy(lastnonabri);

# Push the soluble layers down
 while Hasparent(pri) do
   pri := StructuralCopy(parent(pri));
   Setnicegens(pri,Concatenation(pregensfac(pri),nicegens(kernel(pri))));
   npri := PushDown(StructuralCopy(pri));;
   if npri <> false then 
     pri := StructuralCopy(npri);
     if not SanityCheck(pri) then
       Error(75);
     fi; 
   fi;
 od;
 
 #this is kind of messy, but i haven't managed to track down where all the 
 #parent kernel factor not matching up errors are occurring
 while Haskernel(pri) and not kernel(pri) = fail do
   Setparent(kernel(pri), pri);
   Setparent(factor(pri), pri);
   pri:= kernel(pri);
 od;
 while Hasparent(pri) do
   pri:= parent(pri);
 od;
 return pri;
end;

