# Reported by FL on 2010/05/05, added by AK on 2011/01/16
gap> Size(Set(List([1..10],i->Random(1,2^60-1))))=10;
true
gap> Size(Set(List([1..10],i->Random(1,2^60))))=10;  
true
