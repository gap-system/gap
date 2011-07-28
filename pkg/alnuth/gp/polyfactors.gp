\\ compute factors of poly defined by coeffs over Q_f
f = subst(f,variable(f),'varA);
pol = Pol(vector(#coeffs-1,i,Polrev(coeffs[i],'varA)));
n = poldegree(f);
gettime();
{
  if(type(version)!="t_POL" && lex(version(),[2,4,3])>=0,
    fac = lift(nffactor(f, pol ))
  , if(poldegree(pol)*3<n,
      fac = lift(factornf(pol,f));
    ,
      nf = nfinit([f, nfbasis(f,1)]);
      fac = lift(nffactor(nf, pol ))
  ));
}
zeit = gettime();

p2v(n,b)=vector(n,j,polcoeff(b,j-1));
f2v(n,v)=vector(#v,i,p2v(n,v[i]));

\\ print result
print("[ ");
{
  for(i=1,#fac[,1],
    for(j=1,fac[i,2],
        print(f2v(n, Vec(fac[i,1]) ),",");
    )
  );
}
print1(zeit);
print("];");
