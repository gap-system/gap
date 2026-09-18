# 2006/07/25 (AH)
# g = TransitiveGroup(10,8)
gap> g := Group([ (2,7)(5,10), (1,3,5,7,9)(2,4,6,8,10) ]);;
gap> ConjugatorOfConjugatorIsomorphism(ConjugatorAutomorphism(g,(4,9)));
(1,6)(2,7)(3,8)(5,10)
