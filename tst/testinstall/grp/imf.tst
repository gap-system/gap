gap> DisplayImfInvariants(3,1);
#I Z-class 3.1.1:  Solvable, size = 2^4*3
#I   isomorphism type = C2 wr S3 = C2 x S4 = W(B3)
#I   elementary divisors = 1^3
#I   orbit size = 6, minimal norm = 1
gap> DisplayImfInvariants(3,1,0);
#I Z-class 3.1.1:  Solvable, size = 2^4*3
#I   isomorphism type = C2 wr S3 = C2 x S4 = W(B3)
#I   elementary divisors = 1^3
#I   orbit size = 6, minimal norm = 1
#I Z-class 3.1.2:  Solvable, size = 2^4*3
#I   isomorphism type = C2 wr S3 = C2 x S4 = C2 x W(A3)
#I   elementary divisors = 1*4^2
#I   orbit size = 8, minimal norm = 3
#I Z-class 3.1.3:  Solvable, size = 2^4*3
#I   isomorphism type = C2 wr S3 = C2 x S4 = C2 x W(A3)
#I   elementary divisors = 1^2*4
#I   orbit size = 12, minimal norm = 2
gap> DisplayImfInvariants(3,1,1);
#I Z-class 3.1.1:  Solvable, size = 2^4*3
#I   isomorphism type = C2 wr S3 = C2 x S4 = W(B3)
#I   elementary divisors = 1^3
#I   orbit size = 6, minimal norm = 1
gap> DisplayImfInvariants(3,1,2);
#I Z-class 3.1.2:  Solvable, size = 2^4*3
#I   isomorphism type = C2 wr S3 = C2 x S4 = C2 x W(A3)
#I   elementary divisors = 1*4^2
#I   orbit size = 8, minimal norm = 3

#
gap> DisplayImfInvariants(-1,1);
Error, dimension out of range
gap> DisplayImfInvariants(0,3);
Error, Q-class number out of range
gap> DisplayImfInvariants(0,1,3);
Error, Z-class number out of range
gap> DisplayImfInvariants(3,1,4);
Error, Z-class number out of range
gap> DisplayImfInvariants(3,2);
Error, Q-class number out of range

#
gap> DisplayImfInvariants(4,0);
#I -----------------------------------------------------------------------
#I Z-class 4.1.1:  Solvable, size = 2^7*3^2
#I   isomorphism type = W(F4)
#I   elementary divisors = 1^2*2^2
#I   orbit size = 24, minimal norm = 2
#I -----------------------------------------------------------------------
#I Z-class 4.2.1:  Solvable, size = 2^5*3^2
#I   isomorphism type = D12 wr C2 = (C2 x W(A2)) wr C2
#I   elementary divisors = 1^2*3^2
#I   orbit size = 12, minimal norm = 2
#I -----------------------------------------------------------------------
#I Z-class 4.3.1:  Size = 2^4*3*5
#I   isomorphism type = C2 x S5 = C2 x W(A4)
#I   elementary divisors = 1^3*5
#I   orbit size = 20, minimal norm = 2
#I -----------------------------------------------------------------------
#I Z-class 4.4.1:  Solvable, size = 2^7*3
#I   isomorphism type = C2 wr S4 = W(B4)
#I   elementary divisors = 1^4
#I   orbit size = 8, minimal norm = 1
#I   not maximal finite in GL(4,Q), rational imf class is 4.1
#I -----------------------------------------------------------------------
#I Z-class 4.5.1:  Solvable, size = 2^4*3^2
#I   isomorphism type = (D12 Y D12):C2
#I   elementary divisors = 1*3^2*9
#I   orbit size = 18, minimal norm = 4
#I   not maximal finite in GL(4,Q), rational imf class is 4.2
#I -----------------------------------------------------------------------

#
gap> List([1..31], ImfNumberQQClasses);
[ 1, 2, 1, 3, 2, 6, 2, 9, 2, 8, 2, 19, 4, 12, 6, 31, 3, 17, 2, 31, 8, 12, 4, 
  65, 5, 16, 5, 37, 2, 33, 4 ]
gap> ImfNumberQQClasses(32);
Error, dimension out of range

#
gap> List([1..31], ImfNumberQClasses);
[ 1, 2, 1, 5, 2, 9, 3, 16, 8, 21, 2, 19, 4, 12, 6, 31, 6, 17, 2, 31, 8, 12, 
  7, 65, 5, 16, 5, 37, 2, 33, 4 ]
gap> ImfNumberQClasses(32);
Error, dimension out of range

#
gap> List([1..31], d->ImfNumberZClasses(d,1));
[ 1, 1, 3, 1, 3, 3, 3, 3, 3, 3, 3, 1, 3, 1, 1, 1, 3, 1, 3, 1, 1, 1, 8, 1, 1, 
  1, 1, 1, 1, 1, 1 ]
gap> List([4..31], d->ImfNumberZClasses(d,2));
[ 1, 4, 1, 2, 1, 4, 6, 6, 1, 4, 1, 1, 1, 6, 1, 6, 1, 1, 1, 3, 1, 1, 1, 1, 1, 
  1, 1, 1 ]
gap> ImfNumberZClasses(0, 1);
Error, dimension out of range
gap> ImfNumberZClasses(1, 0);
Error, Q-class number out of range
gap> ImfNumberZClasses(3, 2);
Error, Q-class number out of range

#
gap> ImfInvariants(3,1);
rec( elementaryDivisors := [ 1, 1, 1 ], isSolvable := true, 
  isomorphismType := "C2 wr S3 = C2 x S4 = W(B3)", minimalNorm := 1, 
  size := 48, sizesOrbitsShortVectors := [ 6 ] )
gap> ImfInvariants(3, 1, 3);
rec( elementaryDivisors := [ 1, 1, 4 ], isSolvable := true, 
  isomorphismType := "C2 wr S3 = C2 x S4 = C2 x W(A3)", minimalNorm := 2, 
  size := 48, sizesOrbitsShortVectors := [ 12 ] )
gap> ImfInvariants(3, 1, 4);
Error, Z-class number out of range
gap> ImfInvariants(3,2);
Error, Q-class number out of range
gap> ImfInvariants(32,2);
Error, dimension out of range
