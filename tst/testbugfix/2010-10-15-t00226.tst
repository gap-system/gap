# Reported by Laurent Bartholdi on 2008/11/14, added by AK on 2010/10/15
gap> f := FreeGroup(0);; g := FreeGroup(1);;
gap> phi := GroupHomomorphismByImages(f,g,[],[]);;
gap> One(f)^phi = One(g);
true
gap> One(f)^phi=One(f);
false
