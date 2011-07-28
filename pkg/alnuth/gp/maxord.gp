\\ compute basis of maximal order
b = nfbasis( f );

p2v(n,b)=vector(n,j,polcoeff(b,j-1));

\\ print result 
print("[ ");
for(i=1,#b, print(p2v(#b,b[i]),","));
print("];");

