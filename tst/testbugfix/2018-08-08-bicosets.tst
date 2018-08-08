# We used to allow multiplying and inverting right cosets for which this
# was not valid. This test verifies this is not the case anymore.
# See <https://github.com/gap-system/gap/issues/2555>
gap> G := SymmetricGroup(3);;
gap> U := Group( (1,2) );;
gap> cos1 := RightCoset(U, (1,2));;
gap> cos2 := RightCoset(U, (1,3));;
gap> IsBiCoset(cos1);
true
gap> IsBiCoset(cos2);
false

#
gap> cos1*cos1 = cos1;
true
gap> cos1*cos2 = cos2;
true
gap> cos2*cos1;
Error, right cosets can only be multiplied if the left operand is a bicoset

#
gap> cos1^-1 = cos1;
true
gap> cos2^-1;
Error, only right cosets which are bicosets can be inverted
