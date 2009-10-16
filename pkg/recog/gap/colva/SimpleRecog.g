IsImageTrivial := function(I)
# Is the group I trivial or a direct product of scalars?
 local n,L,i;

 if IsPermGroup(I) then return IsTrivial(I); fi;

 if IsMatrixGroup(I) then return IsScalarGroup(I); fi;

 n := Size(I!.DirectProductInfo!.groups);
 L := List([1..n],i->Image(Projection(I,i)));
 for i in [1..n] do
   if not IsScalarGroup(L[i]) then return false; fi;
 od;
 return true;
end;


RecogniseTrivialGroup := function(H,phi,I)
# Recognises the trivial group possibly modulo scalars
 local T,recdata,x,n,g;

 T := GroupWithGenerators([One(CyclicGroup(1))]); 
 recdata := rec(Group := T);
 recdata!.NiceGens := GeneratorsOfGroup(T); 
 recdata!.NiceGensSlps := [StraightLineProgramNC([[1,0]],1)]; 
 recdata!.GtoSlp := g->StraightLineProgramNC([[1,0]],1); 
 recdata!.SlptoG := w->ResultOfStraightLineProgram(w,recdata!.NiceGens);

# Need to create a hom into T that returns fail if the element is not "trivial"
 if IsPermGroup(I) then
   recdata!.newmap := GroupHomomorphismByFunction(H,T,
function(g)
local x;
 x := ImageElm(phi,g);
 if not IsOne(x) then return fail; fi;
 return GeneratorsOfGroup(T)[1];
end);      
 
 elif IsMatrixGroup(I) then
   recdata!.newmap := GroupHomomorphismByFunction(H,T,
function(g)
local x;
 x := ImageElm(phi,g);
 if not IsScalarMatrix(x) then return fail; fi;
 return GeneratorsOfGroup(T)[1];
end);      
 
 else
   recdata!.newmap := GroupHomomorphismByFunction(H,T,
function(g)
local x,n;
 x := ImageElm(phi,g);
 n := Size(I!.DirectProductInfo!.groups);

 if not ForAll([1..n],i->IsScalarMatrix(ImageElm(Projection(I,i),x))) then return fail; fi;
 return GeneratorsOfGroup(T)[1];
end);      

 fi;

 return recdata;
end;


RecognisePcGroup := function(G)
# Performs constructive recognition on a PC group
 local recdata,gens,n,trivgens,T,rho,P,T2,GtoT2,g,x,w;

 recdata := rec(Group := G,name := "Pc group");
 if IsTrivial(G) then
   recdata!.NiceGens := [One(G)];
   recdata!.NiceGensSlps := [StraightLineProgramNC([[1,0]],1)]; 
   recdata!.GtoSlp := function(g)
  if IsOne(g) then return StraightLineProgramNC([[1,0]],1); 
  else return fail;
  fi;
  end;
   recdata!.SlptoG := w->ResultOfStraightLineProgram(w,recdata!.NiceGens);
   return recdata;
 fi;

 gens := GeneratorsOfGroup(G);
 n := Size(gens);

# Set up a hom into a trivial group with memory
 trivgens := GeneratorsWithMemory(List(gens,x->()));
 T := GroupWithGenerators(trivgens);
 rho := GroupHomomorphismByImages(G,T,gens,trivgens);

# Compute a Pcgs of G and use it!!
 P := Pcgs(G);
 recdata!.NiceGens := AsList(P);
 recdata!.NiceGensSlps := List(AsList(P),x->SLPOfElm(ImageElm(rho,x))); 

# Solving the rewriting problem
 T2 := GroupWithMemory(GroupWithGenerators(List(AsList(P),x->())));
 GtoT2 := GroupHomomorphismByImages(G,T2,AsList(P),GeneratorsOfGroup(T2)); 
 recdata!.GtoSlp := function(g)
   return SLPOfElm(ImageElm(GtoT2,g));
 end;  
 recdata!.SlptoG := function(g)
   return ResultOfStraightLineProgram(w,AsList(P));
 end;

 return recdata;
end;


RecogniseQuasiSimple := function(G,name)
# Calls a bunch of other functions to do constructive recognition
# in the quasisimple group G with a given name
 local recdata,Gm,n,re,ims,GtoP,P,Pmem,S,im;

 recdata := rec(Group := G, name := name);


 if name[1]='A' and Int(SplitString(name,"_")[2])>11 then
# G is an alternating group - use the recogSnAnBB code
   Gm := GroupWithMemory(G);
   n := Int(SplitString(name,"_")[2]);
   re := RecogniseSnAn(n,Gm,1/100);   
   recdata!.NiceGens := [StripMemory(re[2][2]),StripMemory(re[2][1])]; 
   recdata!.NiceGensSlps := [SLPOfElm(re[2][2]),SLPOfElm(re[2][1])];    
   ims := List(recdata!.NiceGens,g->FindImageAn( n, g, re[2][1], re[2][2], re[3][1], re[3][2] ));
   recdata!.Gold := GroupWithGenerators(ims);
   recdata!.GtoGold := GroupHomomorphismByFunction(G,recdata.Gold,g->FindImageAn( n, g, re[2][1], re[2][2], re[3][1], re[3][2] ));

   recdata!.GtoSlp := function(g)
     return SLPforAn( n, ImageElm(recdata.GtoGold,g) );
   end;
   recdata!.SlptoG := function(w)
     return ResultOfStraightLineProgram(w,recdata.NiceGens);
   end;
   recdata!.GoldtoG := function(x)
     return ResultOfStraightLineProgram(SLPforAn(n,x),recdata.NiceGens);
   end;


# elif name[1]='L'
# G is SL / PSL - use the Kantor-Serres algorithm
#   GBB := GpAsBBGp (G);
#   GBBm := GroupWithMemory(GBB);
#   npe := findnpe(name);
#   re := SLDataStructure(GBBm,npe[2],npe[3],npe[1]); 
#   if re=fail then 
#     Error("Failure in recognition of SL");
#   fi;
#   recdata!.NiceGens := List(re.gens,x->StripMemory(x[1])![1]);
#   recdata!.NiceGensSlps := List(re.gens,x->SLPOfElm(x[1]));

   

#   recdata!.Gold := G;
#   recdata!.GtoGold := GroupHomomorphismByFunction(G,G,g->g);
#   recdata!.GoldtoG := GroupHomomorphismByFunction(G,G,g->g);
#   recdata!.GtoSlp := function(g)
#     return SLSLP( re, g, npe[1]);
#   end;   
#   recdata!.SlptoG := function(w)
#     return ResultOfStraightLineProgram(w,recdata.NiceGens);
#   end;

 elif IsPermGroup(G) then
   Pmem := GroupWithMemory(G);
   S := StabChainOp(Pmem,rec(random := 900));
   DoSafetyCheckStabChain(S);
   recdata!.NiceGensSlps := List(S.labels,x->SLPOfElm(x));
   recdata!.NiceGens := List(recdata!.NiceGensSlps,x->ResultOfStraightLineProgram(x,GeneratorsOfGroup(G)));
   StripStabChain(S);
   MakeImmutable(S);
   SetStabChainImmutable(G,S);

# Have no gold group in this case
   recdata!.Gold := G;
   recdata!.GtoGold := GroupHomomorphismByFunction(G,G,g->g);
   recdata!.GoldtoG := GroupHomomorphismByFunction(G,G,g->g);
   recdata!.GtoSlp := function(g)
     return SLPinLabels(S,g);
   end;   
   recdata!.SlptoG := function(w)
     return ResultOfStraightLineProgram(w,recdata.NiceGens);
   end;



 else
# Use Shortotbits and consider the group as a perm grp
   re := rec();
   Objectify(RecognitionInfoType,re);;
   FindHomMethodsMatrix.ShortOrbits(re,G);
# Perm Image
   GtoP := homom(re);
#   GtoP := re!.homom;
   P := Image(GtoP);
Print(String(Size(G)));
Print(String(Size(P)));

   Pmem := GroupWithMemory(P);
   S := StabChainOp(Pmem,rec(random := 900));
   DoSafetyCheckStabChain(S);
   recdata!.NiceGensSlps := List(S.labels,x->SLPOfElm(x));
   recdata!.NiceGens := List(recdata!.NiceGensSlps,x->ResultOfStraightLineProgram(x,GeneratorsOfGroup(G)));
   StripStabChain(S);
   MakeImmutable(S);
   SetStabChainImmutable(P,S);

# Have no gold group in this case
   recdata!.Gold := G;
   recdata!.GtoGold := GroupHomomorphismByFunction(G,G,g->g);
   recdata!.GoldtoG := GroupHomomorphismByFunction(G,G,g->g);
   recdata!.GtoSlp := function(g)
     local im;
     if not g in G then 
Print("g not in G");
return fail; fi;
Print("elt in in G");
     im := ImageElm(GtoP,g);
     if not im in P then 
Print("Image not in P");
Print(String(im));
return fail; fi;
Print("image in in P");
     return SLPinLabels(S,im);
   end;   
   recdata!.SlptoG := function(w)
     return ResultOfStraightLineProgram(w,recdata.NiceGens);
   end;
 fi;

 recdata!.Name := [name,1];
 return recdata;
end;  


RefineMap := function(H,phi,I)
## Refines the map phi by considering (projective) element order ## on the projections
  local O,n,k,projs,blocks,newblocks,b,B,h,x,r,c,i,j,
newI,newphi,im1,list,g,y,o;

  if IsMatrixGroup(I!.DirectProductInfo!.groups[1]) then
    O := function(g)
      return ProjectiveOrder(g)[1];
    end;
  else
    O := Order;
  fi;
  n := Size(I!.DirectProductInfo!.groups);
  k := 100; 
  projs := List([1..n],i->Projection(I,i));

  blocks:=[[1..n]];
  for i in [1..k] do
    h:=PseudoRandom(H);
    x:=ImageElm(phi,h);
    o := List([1..n],i->O(ImageElm(projs[i],x)));
    newblocks := Filtered(blocks, r-> Size(r)=1);
    for B in Filtered(blocks, r-> Size(r)>1) do
      b:=B;
      while Size(b)>0 do
        r:=b[1];
        c := Filtered(b,y->o[r]=o[y]);
        Add(newblocks,c);
        b:=Filtered(b,i->not i in c);
      od;
    od;
    blocks:=newblocks;
    if Size(blocks)=n then return [phi,I]; fi;
  od;
  blocks := List(blocks,x->x[1]);
  
# Construct new map and image
  newI := DirectProduct(List(blocks,i->I!.DirectProductInfo!.groups[1]));

  newphi := GroupHomomorphismByFunction(H,newI,
function(g)
  im1 := ImageElm(phi,g);
  list := List([1..Size(blocks)],i->ImageElm(Embedding(newI,i),ImageElm(Projection(I,blocks[i]),im1)));
  return Product(list);
  end);

  return [newphi,newI];
end;
    
FindPoint := function(H,phi,point,I)
# Find a point in H corresponding to point
  local O,n,k,projs,H1,c,gens,h,x,lp,lc,g,i,j,IdTest;

  if IsMatrixGroup(I!.DirectProductInfo!.groups[1]) then
    O := function(g)
      return ProjectiveOrder(g)[1];
    end;
    IdTest := IsScalarMatrix;
  else
    O := Order; IdTest := IsOne;
  fi;
  n := Size(I!.DirectProductInfo!.groups);
  projs := List([1..n],i->Projection(I,i));
  H1 := ShallowCopy(H);

  for c in [1..n] do
    if c <> point then
      gens := [];
      for k in [1..3] do
        repeat
          h:=PseudoRandom(H1)^PseudoRandom(H);
          x:=ImageElm(phi,h);
          lp := O(ImageElm(projs[point],x));
          lc := O(ImageElm(projs[c],x));
        until lp <> 1 and GcdInt(lp,lc)=1;
        Add(gens,h^lc);
      od;
      H1 := GroupWithGenerators(gens);
    fi;
  od;
  for g in GeneratorsOfGroup(H1) do
    if not IdTest(ImageElm(projs[point],ImageElm(phi,g))) then return g; fi;
  od;	

# Process has failed :-(
 Error("Error in finding a point");

end; 
  
PermAction := function(G,H,phi,I)
# Constructs the permutation action of G on I
  local O,n,projs,points,reps,ims,point,h,x,y,l,def,repims,rep,i,j,g;

  if IsMatrixGroup(I!.DirectProductInfo!.groups[1]) then
    O := function(g)
      return ProjectiveOrder(g)[1];
    end;
  else
    O := Order;
  fi;
  n := Size(I!.DirectProductInfo!.groups);
  projs := List([1..n],i->Projection(I,i));
  points:=[1..n];
  reps:=[];
  ims := List([1..Size(GeneratorsOfGroup((G)))],i->[]);
  while Size(points)>0 do
    point := Random(points);
    h:=FindPoint(H,phi,point,I);    
    reps[point]:=h;
    repeat
      for i in [1..Size(GeneratorsOfGroup((G)))] do
        for j in [1..Size(reps)] do
          if IsBound(reps[j]) and not IsBound(ims[i][j]) then
            y := reps[j]^GeneratorsOfGroup(G)[i];
            x:=ImageElm(phi,y);      
            l := First([1..n],k->O(ImageElm(projs[k],x))<>1);

#            l := First([1..n],k->(IsMatrixGroup#(I!.DirectProductInfo!.groups[1]) and not IsScalarMatrix(ImageElm#(projs[k],x))) and not IsOne(ImageElm(projs[k],x)));; 
            ims[i][j]:=l;
            if not IsBound(reps[l]) then reps[l]:=y; fi;
          fi;
        od;
      od;
      def:=Filtered([1..Size(reps)],i->IsBound(reps[i]));
    until ForAll( def , 
i-> ForAll([1..Size(GeneratorsOfGroup(G))],j-> IsBound(ims[j][i])))=true;
    SubtractSet(points,def);
  od;
  repims := List(ims,i->PermList(i));
  rep:=GroupWithGenerators(repims);
  return rep;
end;



FindGammaInv := function(gamma,g)
# Find x such that gamma(x)=g
 local IdTest,gi,old,count,new;
 
 if IsMatrix(g) then IdTest := IsScalarMatrix; 
 elif IsPerm(g) then IdTest := IsOne;
 else
   Error("g is not a matrix or a permutation");
 fi;
 gi := g^-1;
 old := g;
 count := 0;
 repeat
   count := count+1;
   new := ImageElm(gamma,old);
   if IdTest(new*gi) then return old; fi;
   old := new;
 until count=1000000;

 Error("Failed to find gammainv(g)");
end;

MyDirectProductOfSLPs := function(a,b)
  # assume a and b produce exactly one result
  # we return only one result, namely the product of the two results
  local ia,ib,l,la,lb,r,r2;
  ia := NrInputsOfStraightLineProgram(a);
  ib := NrInputsOfStraightLineProgram(b);
  la := LinesOfStraightLineProgram(a);
  lb := LinesOfStraightLineProgram(b);
  l := [];
  r := RewriteStraightLineProgram(a,l,ia+ib,[1..ia],[ia+1..ia+ib]);
  r2 := RewriteStraightLineProgram(b,r.l,r.lsu,[ia+1..ia+ib],r.results);
  Add(r2.l,[r.results[1],1,r2.results[1],1]);
  return StraightLineProgramNC(r2.l,ia+ib);
end;

MyDirectProductOfSLPsList := function(list)
# Does the above function only with a list
 local i,r;
 r := list[1];
 for i in [2..Length(list)] do
   r := MyDirectProductOfSLPs(r,list[i]);
 od;
 return r;
end;

ElementOfCoprimeOrder := function(grp,o)
# Find an element g in grp of order coprime to o
 local divs,ps,count,g,og,v;

 divs := PrimePowersInt(o);
 ps := List([1..Size(divs)/2],i->divs[2*i-1]);
 count := 0;
 repeat
   count := count+1;
   g := PseudoRandom(grp);
   og := Order(g);   
   v := Product(List(ps,x->x^Valuation(og,x)));
   if og/v <> 1 then return g^(v); fi;
 until count > 1000;   
 Error ("Failed to find an element of coprime order");
end;



WhichPowerIsModuleIsoModScalars := function(grp,name,gamma)
# Find t such that gamma^t a module automorphism (modulo scalars) of the quasisimple matrix group defined by name?
# membership test is a membership test in grp
 local m,g,gens,ims1,oz,o,z,ims,F,M1,M2,mat,t; 


# First construct a generating set of elts of order coprime to the schur multiplier
 m := SchurMultiplierOrder(name);
 g := ElementOfCoprimeOrder(grp,m); 
# Compute a number of random conjugates of g to get a probable generating set for grp

 gens := Concatenation([g],List([1..5],i->g^PseudoRandom(grp)));
 F := FieldOfMatrixGroup(grp);
 M1 := GModuleByMats(gens,F);
 
 old := gens; 
 t := 0;
 repeat 
   t := t+1;
# compute the images of gens under phi
   ims1 := List(old,x->ImageElm(gamma,x));

# alter images to remove the scalar parts
   oz := List(ims1,x->ProjectiveOrder(x));
   o := List(oz,x->x[1]);
   z := List(oz,x->x[2]);
   m := List([1..Size(z)],i->-1/o[i] mod Order(z[i]));

   ims := List([1..Size(z)],i->ims1[i]*z[i]^m[i]);
   M2 := GModuleByMats(ims,F);

# Do we have a module isomorphism
   mat := MTX.IsomorphismModules(M1,M2); 
   old := ims;
 until IsMatrix(mat);
 return [t,mat];


end;



RecogniseQuasiSimpleDP := function(G,H,phi,I,name)
# Recognises the DP of quasisimple groups I, where H is normal in # G and phi : H -> I
 local R,projs,recdata,permrep,invims,e,econj,
       H1,gens,H1toblk,blk,blkdata,Yhat,blktoH1,Y,YY,r,i,k,gamma,
       z,h,y,invhom,j,w,t,qr,mat;

# Is the image trivial?
 if IsImageTrivial(I) then return RecogniseTrivialGroup(H,phi,I); fi;
  

# Do we only have one copy of a nonab simple group??
 if IsMatrixGroup(I) or (IsPermGroup(I) and Size(Orbits(I))=1) then
   return RecogniseQuasiSimple(I,name);
 fi;

# We now have a direct product on nonabelian simple groups

 R := RefineMap(H,phi,I);
 phi := R[1]; I := R[2];

# Have we refined down to only one block?
 k := Size(I!.DirectProductInfo!.groups);
 projs := List([1..k],i->Projection(I,i));

 if k=1 then
   blk := Image(projs[1]);
   recdata := RecogniseQuasiSimple(blk,name);
   recdata!.newmap := GroupHomomorphismByFunction(H,blk,g->ImageElm(projs[1],ImageElm(phi,g)));
   return recdata;
 fi;

 permrep := PermAction(G,H,phi,I);
 invhom := GroupHomomorphismByImagesNC(permrep,G,GeneratorsOfGroup(permrep),GeneratorsOfGroup(G));
 e := List([1..k],i-> ImageElm(invhom,RepresentativeAction(permrep,1,i)));
 econj := List([1..Size(e)],i->GroupHomomorphismByFunction(H,H,g->g^e[i]));

# Find generators for one block
 gens := List([1..3],i->FindPoint(H,phi,1,I));  
 H1 := SubgroupNC(H,FastNormalClosure(H,gens,1));
 H1toblk := phi*projs[1];
 H1toblk!.Source := H1;
 blk := GroupWithGenerators(List(GeneratorsOfGroup(H1),x->ImageElm(H1toblk,x)));
 blkdata := RecogniseQuasiSimple(blk,name);

 invims := List(blkdata!.NiceGensSlps,w->ResultOfStraightLineProgram(w,GeneratorsOfGroup(H1))); 
 Yhat := ShallowCopy(invims);
 blktoH1 := GroupHomomorphismByFunction(blk,H,g->
ResultOfStraightLineProgram(blkdata!.GtoSlp(g),invims));



 
 Y := blkdata!.NiceGens;
 YY := List(Y,y->ImageElm(Embedding(I,1),y));
 r := Length(Y);

 for i in [2..k] do
# This is stupid - fix it later
   gamma := GroupHomomorphismByFunction(blk,blk,
g->ImageElm(projs[i],phi!.fun(econj[i]!.fun(blktoH1!.fun(g)))));

  if IsMatrixGroup(blk) then
# find t such that gamma^t is a module isomorphism#
# should do something similar for perm groups
   t := WhichPowerIsModuleIsoModScalars(blk,name,gamma);
   mat := t[2]; t := t[1];
   qr := QuotientRemainder(Order(mat)*t-1,t);
   gammainv := GroupHomomorphismByFunction(blk,blk,g->ImageElm(gamma^qr[2],g^(mat^qr[1])));
  fi;

#   gamma := blktoH1*econj[i]*phi*projs[i];
   for j in [1..r] do
     if IsMatrixGroup(blk) then
       z := ImageElm(gammainv,Y[j]);
     else
       z := FindGammaInv(gamma,Y[j]);
     fi;
     h := ImageElm(blktoH1,z)^e[i]; 
     y := ImageElm(phi,h);
     Add(YY,y);
     Add(Yhat,h);
   od;
 od;    

## Set up the data structure
 recdata:=rec(Group := I, Name := [name,k]);
 recdata!.GtoSlp := function(g)
   local list;
   list := List([1..k],i->blkdata!.GtoSlp(ImageElm(projs[i],g)));
   if fail in list then return fail; fi;
   return MyDirectProductOfSLPsList(list);
 end;

 recdata!.SlptoG := function(w)
   return ResultOfStraightLineProgram(w,YY);
 end;

 recdata!.Gold := DirectProduct(List([1..k],i->blkdata!.Gold));
 recdata!.GtoGold := GroupHomomorphismByFunction(I,recdata!.Gold,
function(g)
 local list;
 list := List([1..k],i->ImageElm(Embedding(recdata!.Gold,i),ImageElm(Projection(I,i),g)));
 return Product(list);
 end);     

 recdata!.NiceGens := List(YY,x->StripMemory(x));
 recdata!.invims := Yhat;


 recdata!.GoldtoG := GroupHomomorphismByFunction(recdata!.Gold,I,
function(g)
 local list;
 list := List([1..k],i->ImageElm(Embedding(I,i),ImageElm(Projection(recdata!.Gold,i),g)));
 return Product(list);
 end);     

 recdata!.newmap := phi;

 return recdata;
end;

