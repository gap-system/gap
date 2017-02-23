# 2008/09/10 (TB)
gap> g:= AlternatingGroup( 10 );;
gap> gens:= GeneratorsOfGroup( g );;
gap> hom:= GroupHomomorphismByImagesNC( g, g, gens, gens );;
gap> IsOne( hom ); # This took (almost) forever before the change ...
true
