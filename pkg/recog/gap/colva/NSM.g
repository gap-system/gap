DeclareGlobalFunction("NSM");

ScalarMap := function(F)
# Returns a function that extracts mat[1][1] and returns it as an element in the multiplicative group of the field
 local q,C,x,z,Sclfunc,i,mat;

 q := Size(F);
 C := CyclicGroup(q-1); 
 if q > 2 then
   x := C.1;
 else
   x:= Identity(C);
 fi;
 z := PrimitiveRoot(F);

 Sclfunc := function(mat)
   if not IsScalar(mat) then return false; fi;
   i := LogFFE(mat[1][1],z);
   return x^i;
 end;

 return Sclfunc;
end;
   


AlmostSimpleMaps := function(G, ri)
# Construct a sequence of maps for the almost simple group G
 local L,name,H,d,F,z,G1,H1,C,alpha,I,beta,q,gcd,k1,z1,k2,
k,Scls,SclMap,gamma,divs,i,y,ZH,IPc,ItoPc,alpha1,SclsPC,e1,e2,f1,f2, cp1;

 if IsBound(ri.ASName) then
   name:=ri.ASName;
 else
   L := IdentifySimple(G);
   if L[1]=false then return false; fi;
   if not IsString(L[2]) then name := L[2][1];
   else
     name := L[2];
   fi;
 fi;
# Compute the stable derivative
 H := StableDerivative(G);
# Reduce the number of generators of H
# Take 2 none similar elts and spin up with some conjugates -
 e1 := PseudoRandom(H);
 cp1:= CharacteristicPolynomial(e1);
 repeat
   e2 := PseudoRandom(H);
 until cp1 <> CharacteristicPolynomial(e2);
 H := GroupWithGenerators([e1,e1^PseudoRandom(G),e1^PseudoRandom(G),e2,e2^PseudoRandom(G),e2^PseudoRandom(G)]);


# Throw in all scalars 
 
 d := DimensionOfMatrixGroup(G);
 F := FieldOfMatrixGroup(G); 
 z := PrimitiveElement(F) * One(G);
 L := ShallowCopy(GeneratorsOfGroup(G));
 Add(L,z);
 G1 := GroupWithGenerators(L);
 L := ShallowCopy(GeneratorsOfGroup(H));
 Add(L,z);
 H1 := GroupWithGenerators(L);
 
# Construct the cosets of H1 in G1 using projective order
 C := ConstructCosets(G1, H1, true);
 alpha := GroupHomomorphismByFunction(G,SymmetricGroup(Size(C)),g -> ImageInQuotient(G1,H1,C,g,true));
 I := Image(alpha);
 ItoPc := IsomorphismPcGroup(I);
 IPc := Image(ItoPc);
 alpha1 := GroupHomomorphismByFunction(G,IPc,g->ImageElm(ItoPc,ImageElm(alpha,g)));


# Find the centre of H
 q := Size(F);
 gcd :=  GcdInt(q-1,d);
 k1 := (q-1)/gcd;
 z1 := z^k1;
 divs := DivisorsInt(gcd);
 for i in divs do
   if ElementInNormalSubgroup(H1,H,z1^i,false)=true then y:=z1^i; k2:=i; break; fi;
 od; 
 k := k1*k2;
 ZH := GroupWithGenerators([z^k]);
 
# Construct ismorphism (modulo scalars) from H1 -> H
 beta := GroupHomomorphismByFunction(H1,H,g->ImageInPerfectGroup(H1,H,g,z,k)); 

 Scls := GroupWithGenerators([z]);
 SclMap := ScalarMap(F);
 SclsPC := GroupWithGenerators([SclMap(z)]);
 gamma := GroupHomomorphismByFunction(Scls,SclsPC,g->SclMap(g)); 

# Pass all the information to the record
 ri!.Maps := [alpha1,beta,gamma];
 ri!.MapImages := [IPc,H,SclsPC];
 ri!.Class := "AlmostSimple";
 ri!.COB := One(G);
 ri!.Names := [Size(I),[name,1],q-1];
 ri!.Scalars := [0,ZH,0];
 ri!.TFlevels := [2,3,5];
 return true;

end;





ReducibleCOB := function(M,F,B)
# Constructs the matrix that conjugates G into a form that exhibits the composition series of the module M

 local mat,i,V,W,L,v;

 mat := [];
 for i in [1..Size(B[2])] do
   Add(mat,B[2][i]);
 od;
 for i in [2..(Size(B)-1)] do
   V := VectorSpace(F,B[i]);
   W := VectorSpace(F,B[i+1]);
   for v in Basis(W) do
     if (v in V)=false then
       L := List(Basis(V));
       Add(L,v);
       V := VectorSpace(F,L);
       Add(mat,v);
     fi;
     if Size(mat)=Dimension(W) then break; fi;
   od;
 od;
 return mat^-1;
end;
     
ExtractBlockMap := function(g,t,d,c)
# extracts the block of g^t from (d,d) -> (d+c,d+c)
  local x,m;
  x := g^t; 
  m := x{[d..(d+c-1)]}{[d..(d+c-1)]};
  return m;
end;
 

ReducibleMaps := function(G,ri)
# Computes a sequence of maps for a reducible group G
 local gens,F,M,isirred,B,dims,t,psi,c,l,mapdata,i,j,A,Ari,x,g,
D,injs,maptoD,ims;
	

 gens:=GeneratorsOfGroup(G);
 F:=FieldOfMatrixGroup(G);
 M := GModuleByMats(gens,F);
 isirred := MTX.IsIrreducible(M);
 if isirred then return false; fi;

#Construct change of basis matrix
 
 B := MTX.BasesCompositionSeries(M);
 dims := List(B,x->Size(x));
 t := ReducibleCOB(M,F,B);
 ri!.Class := "Reducible";
 ri!.COB := t;
 
 
# Construct maps onto blocks

 psi := List([1..(Size(dims)-1)],i->GroupHomomorphismByFunction(G,GL(dims[i+1]-dims[i],F),g -> ExtractBlockMap(g,t,dims[i]+1,dims[i+1]-dims[i])));


# Sort psi by dimension but remember the origional ordering
 
 c :=  List([1..(Size(dims)-1)],i->dims[i+1]-dims[i]);
 psi := Permuted(psi,Sortex(c));

# recurse in images
 A := List([1..Size(c)],i->Image(psi[i]));
 Ari := List([1..Size(c)],i->NSM(A[i]));

 
# Glue the maps together

 l := List([1..Size(c)],x->1);
 mapdata := [];
 for i in [1..4] do
   for j in [1..Size(c)] do
     while Size(Ari[j].Maps) >= l[j] and Ari[j].TFlevels[l[j]]=i do
       Add(mapdata, [j,l[j]]);
       l[j]:=l[j]+1;
     od; 
   od;
 od;
 ri!.Maps := List(mapdata,x->GroupHomomorphismByFunction(G,Ari[x[1]].MapImages[x[2]],g->ImageElm(Ari[x[1]].Maps[x[2]],ImageElm(psi[x[1]],g))));

# This should work but it doesn't!
# ri!.Maps := List(mapdata,x->psi[x[1]]*Ari[x[1]].Maps[x[2]]);

 ri!.Names := List(mapdata,x->Ari[x[1]].Names[x[2]]);
 ri!.TFlevels := List(mapdata,x->Ari[x[1]].TFlevels[x[2]]);
 ri!.Scalars := List(mapdata,x->Ari[x[1]].Scalars[x[2]]);
 ri!.MapImages := List(mapdata,x->Ari[x[1]].MapImages[x[2]]);

# Do last map containing all scalars in the domain
 D := DirectProduct(List([1..Size(c)],i->Ari[i].MapImages[l[i]]));
 injs := List([1..Size(c)],i->Embedding(D,i));
 maptoD := function(g)
   ims := List([1..Size(c)],i->ImageElm(injs[i],ImageElm(Ari[i].Maps[l[i]],ImageElm(psi[i],g)))); 
   return Product(ims);
 end;
 Add(ri.Maps,GroupHomomorphismByFunction(G,D,g->maptoD(g)));
 Add(ri.Scalars,0);
 Add(ri.TFlevels,5);
 Add(ri.MapImages,D);
 Add(ri.Names,Product(List([1..Size(c)],i->Ari[i].Names[l[i]])));

 return true;
end;


UnipotentMaps:=function(G,ri)
# Is G unipotent?
 local F,gens,M,f,CompFacs,x,B,t;

 F := FieldOfMatrixGroup(G);   
 gens := GeneratorsOfGroup(G);
 M := GModuleByMats (gens,F);
 CompFacs := MTX.CompositionFactors(M);
 for f in CompFacs do
   if f.dimension > 1 then return false; fi;
   if not First(f.generators,x-> not x=One(GL(1,F)))=fail then return false; fi;
 od;

 B := MTX.BasesCompositionSeries(M);
 t := ReducibleCOB(M,F,B);
 ri!.Class := "Unipotent";
 ri!.COB := t;
 ri!.Maps := [];
 ri!.Names := [];
 ri!.Scalars := [];
 ri!.TFlevels := [];
 ri!.MapImages := [];
 return true; 

end;

IsScalarMatrix := function(x)
# Is x a scalar matrix?
 local d,i;

 if not IsDiagonalMat(x) then return false; fi;
 d := Size(x[1]);
 for i in [2..d] do
   if x[i][i] <> x[1][1] then return false; fi;
 od;
 return true;
end;
 
IsScalarGroup := function(G)
# Is G a group of scalars?
 local g;

 for g in GeneratorsOfGroup(G) do
   if not IsScalarMatrix(g) then return false; fi;
 od;
 return true;
end;

ScalarGroupMaps := function(G,ri)
 local F,z,gamma,I;

 if not IsScalarGroup(G) then return false; fi;
 F := FieldOfMatrixGroup(G);
 z := PrimitiveElement(F)*One(G);
 gamma := ScalarMap(F);
 I := GroupWithGenerators([gamma(z)]);  
 ri!.Maps := [GroupHomomorphismByFunction(G,I,gamma)];
 ri!.MapImages := [I];
 ri!.Names := [Size(I)];
 ri!.Scalars := [0];
 ri!.TFlevels := [5];
 ri!.Class := "Scalars";
 return true;
end;

# Give a list of non-(quasi)simple classical groups
IsNonSimpleClassical := function(name)
 local v1,v2,v3,type,n,q;

 v1 := SplitString(name,"_");
 type := v1[1];
 v2 := SplitString(v1[2],"(");
 n := Int(v2[1]);
 v3 := SplitString(v2[2],")");
 q := Int(v3[1]);

 if (type="L" and n=2 and q=2) or (type="L" and n=2 and q=3) or (type="U" and n=3 and q=2) or (type="S" and n=4 and q=2) or (type="O" and n=3 and q=3) or (type="O" and n=3 and q=2) or (type="O" and n=5 and q=2) or (type="O^+" and n=4) then return true; 
 fi;
 return false;
end;



ClassicalNametoStandardName := function(G,name)

 local n,q,stdname;

 n := DimensionOfMatrixGroup(G);
 q := Size(FieldOfMatrixGroup(G));
 if name="linear" then 
   stdname:=Concatenation("L_",String(n),"(",String(q),")");
 elif name="symplectic" then
   stdname:=Concatenation("S_",String(n),"(",String(q),")");
 elif name="orthogonalcircle" then
   stdname:=Concatenation("O_",String(n),"(",String(q),")");
 elif name="orthogonalplus" then
   stdname:=Concatenation("O^+_",String(n),"(",String(q),")");
 elif name="orthogonalminus" then
   stdname:=Concatenation("O^-	_",String(n),"(",String(q),")");
 elif name="unitary" then
   stdname:=Concatenation("U^-	_",String(n),"(",String(Sqrt(q)),")");
 else
   Error("Error in Classical Names");
 fi;
 return stdname;
end;  	 

IsGroupClassical := function(G,classicalrec)
# Looks in the classicalrec for what I want!
 
 if classicalrec.IsSLContained=true then
   return ClassicalNametoStandardName(G,"linear");
 elif classicalrec.IsSpContained=true then
   return ClassicalNametoStandardName(G,"symplectic");
 elif classicalrec.IsSUContained=true then
   return ClassicalNametoStandardName(G,"unitary");
 elif classicalrec.IsSOContained=true then
   return ClassicalNametoStandardName(G,classicalrec.ClassicalForms[1]);
 else
   return false;
 fi;
end;

LowIndexMaps := function(G,ri)
# Computes a sequence of maps for G when G has a small homomorphic image
 local F,rho,P,rhoinv,Pri,kgens,kims,s1gens,G1,G1toA,A,Ari,m,e,i,I,D,injs
,homfunc,alpha,ims,hom,_,maxnmrblks,x;

 ri!.Class := "LowIndex";
 F := FieldOfMatrixGroup(G);
 rho := ri.Firsthom;
 P := Image(rho);
 Pri := rec( Group:=P );
# recurse in P
 _:=PermGrpMaps(P,Pri);
 rhoinv := GroupHomomorphismByImagesNC(P,G,GeneratorsOfGroup(P),GeneratorsOfGroup(G));
# Find some generators of the kernel
 kgens := List([1..15],i->PseudoRandom(G));
 kims := List(kgens,x->ImageElm(rho,x));
 kgens := List([1..15],i->kgens[i]*ImageElm(rhoinv,kims[i])^-1);
 kgens := FastNormalClosure(G,kgens,3);
 
# Compute the stabilizer of 1 in P
 s1gens := List(GeneratorsOfGroup(Stabiliser(P,1)),x->ImageElm(rhoinv,x));

 G1 := GroupWithGenerators(Concatenation(kgens,s1gens));

# Extract A
 G1toA := GroupHomomorphismByFunction(G1,GL(ri.blockdim,F),g->ImageElm(ri.ActionOnFirstSubspace,g)); 
 A := Image(G1toA);

# recurse in A 
 Ari := NSM(A);
 
 m := NrMovedPoints(P);
 maxnmrblks := Minimum(QuotientRemainder(DimensionOfMatrixGroup(G),2)[1],m); 
 e := List([1..m],i-> ImageElm(rhoinv,RepresentativeAction(P,i,1)));

# Glue together
  

 ri!.MapImages := Concatenation(Pri.MapImages, List([1..Size(Ari.Maps)],i->
DirectProduct(List([1..m],j->Ari.MapImages[i]))));


 ri!.Maps := Concatenation(
List([1..Size(Pri!.Maps)],i->GroupHomomorphismByFunction(G,ri.MapImages[i],g->ImageElm(Pri!.Maps[i],ImageElm(rho,g)))),

List([1..Size(Ari.Maps)],i->
GroupHomomorphismByFunction(G,ri!.MapImages[Length(Pri.MapImages)+i],
function(g)
local D,injs,ims;
 D := ri!.MapImages[Length(Pri.MapImages)+i];
 injs := List([1..m],j->Embedding(D,j));
 ims := List([1..m],j->ImageElm(Ari.Maps[i],ImageElm(G1toA,g^e[j])));
 return Product(List([1..m],j->ImageElm(injs[j],ims[j])));
 end)));

 ri!.Scalars := Concatenation(Pri.Scalars,Ari.Scalars);

 ri!.Names := Pri.Names;
 ri!.TFlevels := List([1..Size(Pri.Maps)],i->1);
 ri!.Scalars := Pri.Scalars;


 for i in [1..Size(Ari.Maps)] do
   Add(ri!.Scalars,Ari.Scalars[i]);
   Add(ri!.TFlevels,Ari.TFlevels[i]); 
   if IsInt(Ari.Names[i]) then
     Add(ri!.Names,(Ari.Names[i])^maxnmrblks);
   else
     Add(ri!.Names,[Ari.Names[i][1],maxnmrblks*Ari.Names[i][2]]);
   fi;
  od;
  return true;
end;
   

MaptoEAGroup := function(r,q,A,list,g)
# Function used for C6 groups
# Works for normalisers of extraspecial groups and of 2-groups of symplectic type
# Map from EZ_G to E/Z_E
 local z,x,j,i,c;

 z := Z(q)^((q-1)/r);
 x := GeneratorsOfGroup(A);
 j := [];

 for i in [1..Size(x)] do
   c := Comm(g,list[i]);
# c=z^j[i] for some j[i]
   if not IsScalar(c) then return false; fi;
   j[i] := LogFFE(c[1][1],z);
 od;
 return Product(List([1..Size(x)],i->x[i]^j[i]));
end;


C6Maps := function (G, ri, re)
# Computes a sequence of maps for a C6 group G
# re is the record from RECOG.New2RecogniseC6(G)

 local hom,H,r,n,q,data,Hri,list,A,homtoEA,z,Scls,SclMap,
       SclsPC,gamma,F,x;


# 1st get the map into the symplectic group
 hom := GroupHomByFuncWithData(G,GroupWithGenerators(re.igens),
                 RECOG.HomFuncrewriteones, 
                 rec(r := re.r,n := re.n,q := re.q,data := re.basis.basis));
 H := Image(hom);

# recurse in H
 Hri :=NSM(H);
# Can't make this construction work!!
# ri!.Maps := List(Hri!.Maps,x->hom*x);
 ri!.Maps := List([1..Size(Hri!.Maps)],i->GroupHomomorphismByFunction(G,Hri!.MapImages[i],g->ImageElm(Hri!.Maps[i],ImageElm(hom,g)))); 
 ri!.MapImages := Hri!.MapImages;
 ri!.Scalars := Hri!.Scalars;
 ri!.Names := Hri!.Names;
 ri!.Class := "C6";
 ri!.TFlevels := Hri!.TFlevels;
#Scalars of H do not correspond to scalars of G
 ri.TFlevels[Size(ri.TFlevels)] := 4;
 
# map onto Elementary Abelian group
 list := re.basis.basis.sympl;
 A := ElementaryAbelianGroup(re.r^Size(list));
 homtoEA := GroupHomomorphismByFunction(G,A,g->MaptoEAGroup(re.r,re.q,A,list,g));
 Add(ri.Maps,homtoEA);
 Add(ri.Scalars,0);
 Add(ri.TFlevels,4);
 Add(ri.MapImages,A);
 Add(ri.Names,Size(A));

# Now the scalar map
 F := FieldOfMatrixGroup(G);
 z := PrimitiveElement(F)*One(G);
 Scls := GroupWithGenerators([z]);
 SclMap := ScalarMap(F);
 SclsPC := GroupWithGenerators([SclMap(z)]);
 gamma := GroupHomomorphismByFunction(Scls,SclsPC,g->SclMap(g)); 
 Add(ri.Maps,gamma);
 Add(ri.Scalars,0);
 Add(ri.TFlevels,5);
 Add(ri.MapImages,SclsPC);
 Add(ri.Names,Size(F)-1);
 
 return true;
end;


TensorMaps := function(G,ri)
# Trys to find maps in the tensor case
 local d,F,N,r,conjgensG,gens1,gens2,list,z,A,GtoA,c,l,
       mapdata,i,j,D,injs,maptoD,ims,Ari,g,c1;

 d := DimensionOfMatrixGroup(G);
 if IsPrime(d) then
   return false;
 fi;
 F := FieldOfMatrixGroup(G);
 # Now assume a tensor factorization exists:
 N := RECOG.FindTensorKernel(G,true);
 r := RECOG.FindTensorDecomposition(G,N);
 if r = fail then
     return fail;
 fi;
# Construct the two tensor factors
 conjgensG := List(GeneratorsOfGroup(G),x->r.basis * x * r.basisi);
 gens1 := [];
 gens2 := [];
 for g in conjgensG do
   list:=RECOG.IsKroneckerProduct(g,r.blocksize);
   if list[1]=false then return fail; fi;
   Add(gens1,ShallowCopy(list[2])); Add(gens2,ShallowCopy(list[3]));
 od; 

 z := PrimitiveElement(F);
 A := []; GtoA := [];
 A[1] := GroupWithGenerators(Concatenation(gens1,[z*One(GL(Length(gens1[1]),F))]));
 GtoA[1] := GroupHomomorphismByFunction(G,A[1],g->RECOG.IsKroneckerProduct(r.basis * g * r.basisi,r.blocksize)[2]);

 
 A[2] := GroupWithGenerators(Concatenation(gens2,[z*One(GL(Length(gens2[1]),F))]));
 GtoA[2] := GroupHomomorphismByFunction(G,A[2],g->RECOG.IsKroneckerProduct(r.basis * g * r.basisi,r.blocksize)[3]);

# Order by increasing dimension
 c :=  List([1..2],i->DimensionOfMatrixGroup(A[i]));
 c1 := StructuralCopy(c);
 A := Permuted(A,Sortex(c));
 GtoA := Permuted(GtoA,Sortex(c1));

# Recurse
 Ari := List(A,x->NSM(x)); 

# Glue the maps together

 l := List([1..2],x->1);
 mapdata := [];
 for i in [1..4] do
   for j in [1..2] do
     while Size(Ari[j].Maps) >= l[j] and Ari[j].TFlevels[l[j]]=i do
       Add(mapdata, [j,l[j]]);
       l[j]:=l[j]+1;
     od; 
   od;
 od;
 ri!.Maps := List(mapdata,x->GroupHomomorphismByFunction(G,Ari[x[1]].MapImages[x[2]],g->ImageElm(Ari[x[1]].Maps[x[2]],ImageElm(GtoA[x[1]],g))));
# ri!.Maps := List(mapdata,x->GtoA(x[1])*Ari[x[1]].Maps[x[2]]);

 ri!.Names := List(mapdata,x->Ari[x[1]].Names[x[2]]);
 ri!.TFlevels := List(mapdata,x->Ari[x[1]].TFlevels[x[2]]);
 ri!.Scalars := List(mapdata,x->Ari[x[1]].Scalars[x[2]]);
 ri!.MapImages := List(mapdata,x->Ari[x[1]].MapImages[x[2]]);

# Do last map containing all scalars in the domain
 D := DirectProduct(List([1..Size(c)],i->Ari[i].MapImages[l[i]]));
 injs := List([1..Size(c)],i->Embedding(D,i));
 maptoD := function(g)
   ims := List([1..Size(c)],i->ImageElm(injs[i],ImageElm(Ari[i].Maps[l[i]],ImageElm(GtoA[i],g)))); 
   return Product(ims);
 end;
 Add(ri.Maps,GroupHomomorphismByFunction(G,D,g->maptoD(g)));
 Add(ri.Scalars,0);
 Add(ri.TFlevels,5);
 Add(ri.MapImages,D);
 Add(ri.Names,Product(List([1..Size(c)],i->Ari[i].Names[l[i]])));

 return true;

end;

#this is the main worker function for the first stage of constructing the tree, it 
#computes a sequence of maps for a normal series of G

InstallGlobalFunction(NSM,
 function(G)
# the return value is a record, containing some of the following fields:
# Group - the input group
# Class - the first Aschbacher class that G was found to lie in
# COB - if G is reducible, a change of basis matrix that displays G in block lower triangular
# form
# Maps - the list of maps
# Names - list of group names of composition factors
# TFLevels - no idea.
# Scalars - a list of scalar matrices at various levels of the decomposition. haven't yet
# fully understood this.
# MapImages - a list of groups that are the images of the maps
# Firsthom - the homomorphism from G to mapimages[1] created by lowindex or C6 routines
# Blockdim - returned by low index, gives dimension of subspace being permuted
# maybe a few more fields.

 local ri,F,classicalrec,name,flag,C6rec,subdim,subtemp,
sub,subbasis,LowIndexri,test;

# Initialise the record
 ri := rec();
 ri!.Group := G;
 F := FieldOfMatrixGroup(G);

# Go through the classes in turn
 flag := ScalarGroupMaps(G,ri);
 if flag=true then return ri; fi;

 Info(ChiefTreeInfo, 2, "testing for reducibility");
 if UnipotentMaps(G,ri)=true then return ri; fi;
 if ReducibleMaps(G,ri)=true then return ri; fi;
 Info(ChiefTreeInfo, 2, "irreducible"); 

# Is G a C8 group - i.e. Is G a classical group
 Info(ChiefTreeInfo, 2, "testing for classical group");
 classicalrec := RecogniseClassical(G);
 name := IsGroupClassical(G,classicalrec);

 if name <> false and not IsNonSimpleClassical(name) then
# We have a classical group in its natural representation
# What is it's standard name?
   ri!.ASName:=name;
   flag:=AlmostSimpleMaps(G,ri);
   return ri;
 fi;
 Info(ChiefTreeInfo, 2, "not a classical group");
   
# Now C6 - may recognise a C6 group or find a block system
 Info(ChiefTreeInfo, 2, "Looking for C6 or a block system");
 C6rec := RECOG.New2RecogniseC6(G);
 if not (C6rec=fail or C6rec=false) then

   #second condition added 3/10/06 by CMRD as was crashing when igens was trivial.
   if C6rec.basis.basis = rec() and not GroupWithGenerators(C6rec.igens) = Group(()) then 
# Have found a block system, G imprimitive - deal with using same #ideas as low index
     ri!.Firsthom := GroupHomByFuncWithData(G,GroupWithGenerators(C6rec.igens),
                 RECOG.HomFuncActionOnBlocks, 
                 rec(r := C6rec.r,n := C6rec.n,q := C6rec.q,blks := C6rec.basis.blocks));
   # Get the maps that extract the action on the first subspaces     
     subdim := DimensionOfMatrixGroup(G) / C6rec.basis.blocks.ell;
     subtemp := List([1..subdim],j->C6rec.basis.blocks.blocks[j]);
     sub := VectorSpace(F,subtemp);
     subbasis := Basis(sub);
     ri!.blockdim := subdim;
     ri!.ActionOnFirstSubspace := GroupHomomorphismByFunction(G,GL(subdim,F),g->MyActionOnSubspace(StructuralCopy(subbasis),g));

     #bug here.
     flag := LowIndexMaps(G,ri);
     if flag=true then return ri; fi;
   elif not C6rec.basis.basis = rec() then
# G normalises an extra special group or 2-group of symplectic type
     flag := C6Maps(G, ri, C6rec);          
     if flag=true then return ri; fi;
   fi;
 fi;
 Info(ChiefTreeInfo, 2, "Failed to find C6 or a block system");

# Now trying LowIndex
 Info(ChiefTreeInfo, 2, "Trying the low index routine");
 LowIndexri := RECOG.SmallHomomorphicImageMatrixGroup(G);
 if LowIndexri <> false and LowIndexri <> fail then
# Similar to imprimitive case
   Info(ChiefTreeInfo, 3, "Small homomorphic image matrix group worked");
   ri!.Firsthom := LowIndexri[1].hom;
   subdim := Size(LowIndexri[1].orb[1]);
   sub := VectorSpace(F,LowIndexri[1].orb[1]);
   subbasis := Basis(sub);
   ri!.blockdim := subdim;
   ri!.ActionOnFirstSubspace := GroupHomomorphismByFunction(G,GL(subdim,F),g->MyActionOnSubspace(StructuralCopy(subbasis),g));
   flag := LowIndexMaps(G,ri);
   if flag=true then return ri; fi;
 fi;
 Info(ChiefTreeInfo, 2, "Low index found nothing"); 
  
# Is the group tensor?
 Info(ChiefTreeInfo, 2, "Testing for a tensor product");
 flag := TensorMaps(G,ri);
 if flag=true then return ri; fi;
 Info(ChiefTreeInfo, 2, "Failed to find a tensor product");


# Group is probably now almost simple
 Info(ChiefTreeInfo, 2, "Testing AlmostSimple");
 flag := AlmostSimpleMaps(G,ri);

 if flag then return ri; fi;

 Error("Failed to find any maps");

end
);
      

      
   

 

 
#       
