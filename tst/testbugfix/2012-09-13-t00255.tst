# Check of the membership test after fixing a method for coefficients 
# to check after Gaussian elimination that the coefficients actually 
# lie in the left-acting-domain of the vector space. 
# Reported by Kevin Watkins, fixed by TB (via AK) on 2012-09-13
gap> Sqrt(5)*IdentityMat(2) in VectorSpace(Rationals,[IdentityMat(2)]);
false
