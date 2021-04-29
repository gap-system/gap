# 2013/03/12 (MH)
#
# The following tests used to crash. This is because for compressed FFE
# vectors, we install custom methods for ELMS_LIST (ELMS_VEC8BIT,
# ELMS_GF2VEC...) which return compressed vectors again -- which are not plain
# lists. But the code in ElmsListLevel etc. assumes that its first input is a
# plain list. Indeed, the documentation for ElmsListFuncs states:
#
# > If the result is a list of lists, then it also *must* create a new list
# > that has the same representation as a plain list.
#
# Now, ELMS_VEC8BIT etc. are not wrong: as they do not return a list of lists,
# they are not required to return a plain list. But in the test cases below,
# the code incorrectly is written as if that were the case; i.e., a vector is
# accessed two levels deep, as if it was a matrix. This is wrong, and normally
# (if the input is a regular uncompressed vector) fails because the code ends
# up trying to access a coefficient as a list, which immediately throws an
# error. But before it does that, it tries to recurse through the given list,
# and for that it assumes it is a plain list.
#
# The fix is to add checks to the relevant functions that verify the input
# is indeed a plain list.

# test IsGF2VectorRep
gap> v:=IdentityMat(12,GF(2))[1];
<a GF2 vector of length 12>
gap> v{[1..5]}{[1..5]};
Error, List Elements: <lists> must be a plain list (not a data object)
gap> v{[1..5]}[1];
Error, List Elements: <lists> must be a plain list (not a data object)
gap> v{[1..5]}[1] := 1;
Error, List Assignments: <lists> must be a plain list (not a data object)
gap> v{[1..5]}{[1..5]}:=ListWithIdenticalEntries(5,[1..5]);
Error, List Assignments: <lists> must be a plain list (not a data object)

# test Is8BitVectorRep
gap> v:=IdentityMat(12,GF(3))[1];
< mutable compressed vector length 12 over GF(3) >
gap> v{[1..5]}{[1..5]};
Error, List Elements: <lists> must be a plain list (not a data object)
gap> v{[1..5]}[1];
Error, List Elements: <lists> must be a plain list (not a data object)
gap> v{[1..5]}[1] := 1;
Error, List Assignments: <lists> must be a plain list (not a data object)
gap> v{[1..5]}{[1..5]}:=ListWithIdenticalEntries(5,[1..5]);
Error, List Assignments: <lists> must be a plain list (not a data object)

# for reference, there is a similar error when using e.g. rational matrices
gap> v:=IdentityMat(12,Rationals)[1];
[ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> v{[1..5]}{[1..5]};
Error, List Elements: <list> must be a list (not the integer 1)
gap> v{[1..5]}[1];
Error, List Element: <list> must be a list (not the integer 1)
gap> v{[1..5]}[1] := 1;
Error, List Assignments: <objs> must be a dense list (not the integer 1)
gap> v{[1..5]}{[1..5]}:=ListWithIdenticalEntries(5,[1..5]);
Error, List Assignments: <list> must be a list (not the integer 1)
