DeclareGlobalFunction("RecogniseLeaf");

MyOrder := function(g)
# returns projective order if g is a matrix - regular order otherwise

 if IsMatrix(g) then return ProjectiveOrder(g)[1];
 else return Order(g);
 fi;
end;

IdTest := function(g)
# returns true if g is a scalar matrix or a tirival perm
  if IsMatrix(g) then return IsScalarMatrix(g);
  else return IsOne(g);
  fi;
end;

MyProjection := function(I,i)
# Takes projection info from the parent group
 if HasDirectProductInfo(I) then
   return Projection(I,i);
 elif HasDirectProductInfo(I!.ParentAttr) then
   return Projection(I!.ParentAttr,i);
 else
   Error("Unable to compute projection");
 fi;
end;


MyEmbedding := function(I,i)
# Takes projection info from the parent group
 if HasDirectProductInfo(I) then
   return Embedding(I,i);
 elif HasDirectProductInfo(I!.ParentAttr) then
   return Embedding(I!.ParentAttr,i);
 else
   Error("Unable to compute projection");
 fi;
end;

NumberOfDPComponents := function(I)
 if HasDirectProductInfo(I) then
   return  Length(I!.DirectProductInfo!.groups);
 elif HasDirectProductInfo(I!.ParentAttr) then
   return Length(I!.ParentAttr!.DirectProductInfo!.groups);
 else
   Error("Unable to compute projection");
 fi;
end;


RefineMap := function(H,phi,I)
## Refines the map phi by considering (projective) element order ## on the projections
  local O,n,k,projs,blocks,newblocks,b,B,h,x,r,c,i,j,
newI,newphi,im1,list,g,y,o;

  O := MyOrder;
  n := NumberOfDPComponents(I);
  k := 100; 
  projs := List([1..n],i->MyProjection(I,i));

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
  newI := DirectProduct(List(blocks,i->Image(projs[1])));

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
  local O,n,k,projs,H1,c,gens,h,x,lp,lc,g,i,j;

  O := MyOrder;    n := NumberOfDPComponents(I);
  projs := List([1..n],i->MyProjection(I,i));
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

  O := MyOrder;
  n := NumberOfDPComponents(I);
  projs := List([1..n],i->MyProjection(I,i));
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
  if a = fail or b = fail then return fail; fi;
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
 if fail in list then return fail; fi;
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
 local m,g,gens,ims1,oz,o,z,ims,F,M1,M2,mat,t,old; 


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

SolveLeafDP := function(ri,rifac,name)
# Solves the constructive membership problem in a Direct Product 
# of nonabelian simple groups
 local I,phi,R,k,projs,blk,bool,permrep,invhom,econj,gens,
       H1,H1toblk,riH1,blkdata,invims,Yhat,blktoH1,Y,YY,r,i,
       j,t,mat,qr,gamma,gammainv,list,e,h,z,y;

 I := group(rifac);
 phi := homom(ri);
 R := RefineMap(group(ri),phi,I);
 phi := R[1]; I := R[2];
 Sethomom(ri,phi); Setgroup(rifac,I);

 k := NumberOfDPComponents(I);
 projs := List([1..k],i->MyProjection(I,i));

# Have we refined down to only one block?
 if k=1 then
   blk := Image(projs[1]);
   #**error here - was only two parameters, tried to fix it by adding ri as first.
   rifac := RecogniseLeaf(ri,blk,name[1]);
   if not bool then return fail; fi;
   Sethomom(ri,GroupHomomorphismByFunction(group(ri),blk,g->ImageElm(projs[1],ImageElm(homom(ri),g))));
   return true;
 fi;

# Unable to do this right now
# Need SLP's in G for generators of H 


 permrep := PermAction(overgroup(ri),group(ri),phi,I);
 invhom := GroupHomomorphismByImagesNC(permrep,overgroup(ri),GeneratorsOfGroup(permrep),GeneratorsOfGroup(overgroup(ri)));
 e := List([1..k],i-> ImageElm(invhom,RepresentativeAction(permrep,1,i)));
 econj := List([1..Size(e)],i->GroupHomomorphismByFunction(group(ri),group(ri),g->g^e[i]));

 gens := List([1..3],i->FindPoint(group(ri),phi,1,I));  
 H1 := SubgroupNC(group(ri),FastNormalClosure(group(ri),gens,1));
 H1toblk := phi*projs[1];
 H1toblk!.Source := H1;
 blk := GroupWithGenerators(List(GeneratorsOfGroup(H1),x->ImageElm(H1toblk,x)));
 
 riH1 := rec();
 Objectify(RecognitionInfoType,riH1);;
 
 Setgroup(riH1,H1);
 blkdata := RecogniseLeaf(riH1,blk,name);;

# Get the inverse images of the nice generators of blk in H1
 invims := CalcNiceGens(blkdata,GeneratorsOfGroup(H1));
 Yhat := ShallowCopy(invims);
 blktoH1 := GroupHomomorphismByFunction(blk,group(ri),g->
ResultOfStraightLineProgram( SLPforElement(blkdata,g),invims));
 
 Y := nicegens(blkdata);
 YY := List(Y,y->ImageElm(MyEmbedding(I,1),y));
 r := Length(Y);

 for i in [2..k] do

#   gamma := blktoH1*econj[i]*phi*projs[i];

# This is stupid - fix it later

   gamma := GroupHomomorphismByFunction(blk,blk,
g->ImageElm(projs[i],phi!.fun(econj[i]!.fun(blktoH1!.fun(g)))));

  if IsMatrixGroup(blk) then
# find t such that gamma^t is a module isomorphism#
# should do something similar for perm groups
   t := WhichPowerIsModuleIsoModScalars(blk,name[1],gamma);
   mat := t[2]; t := t[1];
   qr := QuotientRemainder(Order(mat)*t-1,t);
   gammainv := GroupHomomorphismByFunction(blk,blk,g->ImageElm(gamma^qr[2],g^(mat^qr[1])));
  fi;

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

 Setpregensfac(ri,Yhat);
 Setnicegens(rifac,YY);
 Setslpforelement(rifac, function(rifac,g)

   local list;
   list := List([1..k],i->slpforelement(blkdata)(blkdata,ImageElm(projs[i],g)));
   if fail in list then return fail; fi;
   return MyDirectProductOfSLPsList(list);
 end
 );
 SetName(rifac,name[1]);
 SetSize(I,Size(blk)^k);
 SetFilterObj(rifac,IsReady);
 return true;
end;
 



