# The GL and SL constructors did not correctly handle GL(filter,dim,ring).
# Reported and fixed by JS on 2012-06-24
gap> GL(IsMatrixGroup,3,GF(2));;
gap> SL(IsMatrixGroup,3,GF(2));;
