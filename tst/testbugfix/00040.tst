## bug 10 for fix 2
gap> g:= GU(3,4);;  g.1 in g;
true
gap> ForAll( GeneratorsOfGroup( Sp(4,4) ), x -> x in SP(4,2) );
false
