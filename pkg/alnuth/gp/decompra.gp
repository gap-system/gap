bnf = bnfinit(f,1);
n = poldegree(f);
un = lift(bnf.tufu);
r = #un;

p2v(n,b) = vector(n,j,polcoeff(b,j-1));

\\print units
print("[[ ");
for(i=1,#un, print(p2v(n,un[i]),","));
print("],\n");

\\print exponents
print("[ ");
{
  for(i=1,#elms-1,
    c = bnfisunit(bnf, Polrev(elms[i]));
    if (#c==0, error("element must be a unit"));
    c = vector(r,j,if(j==1,lift(c[r]),c[j-1]));
    print(c,",");
  );
}
print("],\n");

\\ get the rank of the group
rank=bnf.tu[1];

print(rank,"];");
