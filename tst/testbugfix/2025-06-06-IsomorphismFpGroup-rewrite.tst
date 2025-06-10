# From https://github.com/gap-system/gap/issues/6001
#
gap> G:= SymplecticGroup( IsPermGroup, 6, 2 );;
gap> iso:=IsomorphismFpGroup( G, "F" );; # always worked
gap> Image(iso, G.1);;

#
gap> G:= SymplecticGroup( IsPermGroup, 6, 2 );;
gap> iso:=IsomorphismFpGroup( G, "F" : rewrite );; # used to give an error
gap> Image(iso, G.1);;
