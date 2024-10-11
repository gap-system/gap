# Fix a bug reported by Leonard Soicher caused by a bug in
# the hash function for lists of small positive integers.
gap> n:=280;;
gap> G:=OnePrimitiveGroup(NrMovedPoints,n,Size,604800*2);
J_2.2
gap> blocks := [ [ 1, 2, 3, 28, 108, 119, 155, 198, 216, 226 ],
>  [ 1, 2, 3, 118, 119, 140, 193, 213, 218, 226 ] ];;
gap> Append(blocks[2],[1..1000]); for i in [1..1000] do Remove(blocks[2]); od;
gap> Append(blocks[2],[1..1000]); for i in [1..1000] do Remove(blocks[2]); od;
gap> ForAll(blocks,IsSet);
true
gap> orb1:=Orbit(G,blocks[1],OnSets);;
gap> Length(orb1);
12096
gap> orb2:=Orbit(G,blocks[2],OnSets);;
gap> Length(orb2);
1008
gap> orbs:=Orbits(G,blocks,OnSets);;
gap> List(orbs,Length); # this code gave wrong results
[ 12096, 1008 ]
