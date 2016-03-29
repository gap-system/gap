#############################################################################
##
#W  xgap.tst                   GAP-4 library                  Max Neunhöffer 
##
##
#Y  Copyright 1999,    Lehrstuhl D für Mathematik,   RWTH Aachen,    Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("xgap.tst");
gap> f := FreeGroup(2); 
<free group on the generators [ f1, f2 ]>
gap> FactorGroup(f,f);  
Group(())
gap> Size(last);
1
gap> f := FreeGroup( "a", "b" );;  a := f.1;;  b := f.2;; 
gap> c2 := f / [ a*b*a^-2*b*a/b, (b^-1*a^3*b^-1*a^-3)^2*a ];; 
gap> e := GQuotients(c2,PSL(2,11));; 
gap> Length(e);
1
gap> e := e[1];; 
gap> i := Image(e);; 
gap> Stabilizer(i,1);; 
gap> g := PreImage(e,last);; 
gap> l := LowIndexSubgroupsFpGroup(g,TrivialSubgroup(g),5);; 
gap> Filtered(last,x->IndexInWholeGroup(x)=60);;            
gap> gg := last[5];; 
gap> n := Normalizer(c2,gg);; 
gap> Index(c2,n) = Index(c2,gg); 
false
gap> Index(c2,n);
12
gap> Index(c2,gg);
60
gap> k := Kernel(e);; 
gap> LowIndexSubgroupsFpGroup(c2,k,11); 
[ Group(<fp, no generators known>), Group(<fp, no generators known>), 
  Group(<fp, no generators known>) ]
gap> Length(last);
3
gap> l := LowIndexSubgroupsFpGroup(c2,TrivialSubgroup(c2),11);; 
gap> List(l,x->ConjugacyClassSubgroups(c2,x));;
gap> Length(last);
11
gap> f := FreeGroup(2); 
<free group on the generators [ f1, f2 ]>
gap> t := TrivialSubgroup(f); 
Group([  ])
gap> CanComputeSize(t); 
true
gap> HasSize(t); 
true
gap> Size(t); 
1
gap> f := FreeGroup(2);;
gap> g:=f/[f.1^2,f.2^3];;
gap> g.1^5=g.1;
true
gap> STOP_TEST( "xgap.tst", 63840000);

#############################################################################
##
#E
