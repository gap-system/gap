############# Zeros
a := Transformation([1,2,1]); 
b := Transformation([1,1,1]);
s := Semigroup([a,b]); 
HasMultiplicativeZero(s);
IsMultiplicativeZero(s,a);
HasMultiplicativeZero(s); 
IsMultiplicativeZero(s,b);
HasMultiplicativeZero(s); 
MultiplicativeZero(s);    


## Adding zero to a magma
###########################################
G := Group((1,2,3));
i := InjectionZeroMagma(G);
G0 := Range(i);   
IsMonoid(G0);
Elements(G0);
g := Elements(G0);
g[1]*g[2];
g[3]*g[2];
g[3]*g[4];
IsZeroGroup(G0);
m := Monoid(g[3],g[4]);
CategoryCollections(IsMultiplicativeElementWithZero)(m);




j := InjectionZeroMagma(G0);
G00 := Range(j);
IsMonoid(G00);    
IsSemigroup(G00);
# IsZeroGroup(G00); # causes no method found (as desired)

