
ElementInNormalSubgroup := function(G,N,g,Projective)
 # Is g in the normal closure of N (projectively)??
 # This algorithm can return a false negative with small possiblity
  local O,nmr,m,n,i;
 # if the GCD of |g|,|n_1g|,...,|n_rg| = 1 then g is in N
 # if not then g probably is not in n

 if Projective = true then 
   O := function(g)
     return ProjectiveOrder(g)[1];
   end;
 else O := Order;
 fi;

 nmr := 100;
 m := O(g);
 for i in [1..nmr] do 
   n := PseudoRandom(N);
   m := GcdInt(m, O(n*g));
   if m=1 then return true; fi;
 od;

 return false;
end;



ElementInNormalClosure := function(G,N,g,Projective)
 # Is g in the normal closure of N (projectively)??
 # This algorithm can return a false negative with small possiblity
  local O,nmr,m,n,i;
 # if the GCD of |g|,|n_1g|,...,|n_rg| = 1 then g is in N
 # if not then g probably is not in n

 if Projective = true then 
   O := function(g)
     return ProjectiveOrder(g)[1];
   end;
 else O := Order;
 fi;

 nmr := 100;
 m := O(g);
 for i in [1..nmr] do 
   n := PseudoRandomNormalClosureElement(G,N);
   m := GcdInt(m, O(n*g));
   if m=1 then return true; fi;
 od;

 return false;
end;

StableDerivative := function(G)
 # Computes the stable derivative of G, i.e. the last group in the derived series of G
 local gens,Ggens,n,i,j,H,r;

 H := ShallowCopy(G);
 repeat
   gens := [];
   Ggens := GeneratorsOfGroup(G);
   n := Size(Ggens);
   for i in [1..n] do
       r := PseudoRandomNormalClosureElement(G,H);
       Add(gens,Ggens[i]^-1*r^-1*Ggens[i]*r);
   od;
   gens := FastNormalClosure(G,gens,1);
   H := GroupWithGenerators(gens);
   G := ShallowCopy(H);
  until IsProbablyPerfect(G);
  return G;
end;
   
ConstructCosets := function(G,N,Projective)
 # Constructs coset representatives of N in G

 local O,gens,C,t,x,g,i,j;

 if Projective = true then 
   O := function(g)
     return ProjectiveOrder(g)[1];
   end;
 else O := Order;
 fi;
 
 gens := GeneratorsOfGroup(G);
 C := [One(G)];
 t := 1;
 while t <= Size(C) do
   x := C[t];
   for i in [1..Size(gens)] do
     g := x*gens[i];
     for j in [1..Size(C)] do
       if ElementInNormalSubgroup(G,N,C[j]*g^-1,Projective)=true then break; fi;
       if j=Size(C) then Add(C,g); fi;
     od;
   od;
   t := t+1;
 od;       

 return C;
end;

ImageInQuotient := function(G,N,C,g,Projective)
 # Constructs the image of G in G/N < Sym(C)
 local O,k,im,i,j,elts,m,x,temp,done,count;

 if Projective = true then 
   O := function(g)
     return ProjectiveOrder(g)[1];
   end;
 else O := Order;
 fi;

 k := Size(C);
 im := [];

# construct a big list of elts of the form C[i]*g*c[j]^-1
 elts := [ ];
 m := [ ];
 for i in [1..k] do
   elts[i] := [];
   m[i] := [];
   temp := C[i]*g;
   for j in [1..k] do     
     elts[i][j]:=temp*C[j]^-1;
     m[i][j] := O(elts[i][j]);
   od;
 od; 
# One of C[i]*gC[j]^-1 is in N for each i and the corresponding j will be the image of the point i under g

 im := [ ];
 done := [];
 count :=0 ;
 for i in [1..k] do
   for j in [1..k] do
     if m[i][j]=1 then im[i] := j; Add(done,i); count := count+1; break; fi;
   od;
 od;

 repeat
   x := PseudoRandom(N);
   for i in Difference([1..k],done) do
     for j in Difference([1..k],im) do
       m[i][j]:=GcdInt(m[i][j],O(elts[i][j]*x));
       m[i][j]:=GcdInt(m[i][j],O(elts[i][j]*x^-1));
       m[i][j]:=GcdInt(m[i][j],O(x*elts[i][j]));
       m[i][j]:=GcdInt(m[i][j],O(x^-1*elts[i][j]));
     od;
   od;
   for i in Difference([1..k],done) do
     for j in Difference([1..k],im) do
       if m[i][j]=1 then im[i] := j; Add(done,i); count := count +1; break; fi;
     od;
   od;
 until count >= k-1;
 
 if count=k-1 then
# work out the remaining point 
   im[Difference([1..k],done)[1]]:=Difference([1..k],im)[1];
 fi;

 return PermList(im);

end;
 
ImageInPerfectGroup := function(HZ,H,g,z,k)
# H is perfect, HZ = <H,z> and there exists 1 <= i <= k with gz^i in H - find the i
 local d,q,detg,detz,j,l,SLscalars,divs,elts,m,i,count,relt,ipos;
# Make the search smaller by forcing det(gz^i) to be 1
 d := DimensionOfMatrixGroup(H);
 q := Size(FieldOfMatrixGroup(H));
 detg := Determinant(g); 
 detz := z[1][1]^d;
 j := LogFFE(detg^-1,detz);
 l := (q-1) / GcdInt(q-1,d); 
 SLscalars := z^l;
 z := z^j;

# i must now divide k / gcd(l,k)
 divs := DivisorsInt(k / GcdInt(k,l));

 elts := List(divs, i->SLscalars^i*z*g);
 m := List(elts, x->Order(x));

# Find an element elts that is in H

 count := 0;
 repeat
   count := count + 1;
   relt := PseudoRandom(H);
   elts := List(elts, x->relt*x);
   m := List([1..Size(m)], i->GcdInt(m[i],Order(elts[i])));
   ipos := First(m,i->i=1);
   if count=500 then
     return false;
   fi;
 until not ipos=fail;   
 i := divs[ipos];
 return SLscalars^i*z*g;
end;

# Now some 
