# 2006/04/07 (TB)
gap> G:= SymmetricGroup(3);;
gap> m:= InnerAutomorphism( G, (1,2) );;
gap> n:= TransformationRepresentation( InnerAutomorphism( G, (1,2,3) ) );;
gap> m * n;;  n * m;;
