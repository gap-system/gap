bnf = bnfinit(f,1);
n = poldegree(f);
un = lift(bnf.tufu);

p2v(n,b) = vector(n,j,polcoeff(b,j-1));

\\ print units
print("[ ");
for(i=1,#un, print(p2v(n,un[i]),","));
print("];\n");
