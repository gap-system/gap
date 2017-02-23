# Reported by Sohail Iqbal on 2008/10/15, added by AK on 2010/10/03
gap> f:=FreeGroup("s","t");; s:=f.1;; t:=f.2;;
gap> g:=f/[s^4,t^4,(s*t)^2,(s*t^3)^2];;
gap> CharacterTable(g);
CharacterTable( <fp group of size 16 on the generators [ s, t ]> )
gap> Length(Irr(g));
10
