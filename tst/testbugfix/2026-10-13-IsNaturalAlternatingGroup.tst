# IsNaturalAlternatingGroup ran into an infinite loop for a primitive group
# whose socle acts on k-sets and which does not move the point 1, see #6720
gap> G:= Group( (2,5)(3,8)(4,11)(6,9)(7,12)(10,13),
>               (2,10,16)(3,13,11,5,7,15)(4,14)(6,12,8) );;
gap> IsNaturalAlternatingGroup( G );
false
gap> IsNaturalSymmetricGroup( Group( GeneratorsOfGroup( G ) ) );
false
gap> Size( G );
720
