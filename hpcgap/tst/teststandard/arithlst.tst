#############################################################################
##
#W  arithlst.tst                GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  2000,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testinstall.g because it runs too long.
##
gap> START_TEST("arithlst.tst");

#
gap> ReadGapRoot("tst/teststandard/arithlst.g");

#############################################################################
##
##  Here the tests start.
##  (The dimension should always be at least 4,
##  in order to avoid errors in inner products of non-dense lists.)
##

# over `GF(2)', `GF(3)', `GF(4)' (compressed elements)
gap> stddims:= [ 4, 5, 6, 8, 17, 32, 33 ];;
gap> TestOfListArithmetic( GF(2), stddims );
gap> TestOfListArithmetic( GF(3), stddims );
gap> TestOfListArithmetic( GF(4), stddims );

# over another small finite field (compressed elements)
gap> TestOfListArithmetic( GF(25), stddims );

# over a big finite (prime) field
gap> p:= NextPrimeInt( MAXSIZE_GF_INTERNAL );;
gap> TestOfListArithmetic( GF( p ), [ 4, 5, 6, 8 ] );

# over the rationals
gap> TestOfListArithmetic( Rationals, [ 4 ] );

# over a residue class ring
gap> TestOfListArithmetic( Integers mod 12, [ 4 ] );

# over a ring of non-internal objects
gap> A:= QuaternionAlgebra( Rationals );;
gap> TestOfListArithmetic( A, [ 4 ] );

# over a matrix space/algebra over `GF(2)' (compressed elements)
gap> TestOfListArithmetic( GF(2)^[2,3], [ 4, 5, 6 ] );

# over a matrix space/algebra over another small finite field
# (compressed elements)
gap> TestOfListArithmetic( GF(5)^[2,3], [ 4, 5, 6 ] );

# over a matrix space/algebra over a big finite (prime) field
gap> p:= NextPrimeInt( MAXSIZE_GF_INTERNAL );;
gap> TestOfListArithmetic( GF( p )^[2,3], [ 4 ] );

# over a matrix space/algebra over the rationals
gap> TestOfListArithmetic( Rationals^[2,3], [ 4, 5, 6 ] );

# over a class function space (the elements are not mult. grvs)
gap> TestOfAdditiveListArithmetic( Irr( SymmetricGroup( 4 ) ), 4 );

# over a space of Lie matrices (the elements are not mult. grvs)
gap> TestOfAdditiveListArithmetic( LieAlgebra( GF(3)^[2,2] ), 4 );

# # over a group of block matrices
# gap> hom:= IrreducibleRepresentations( SymmetricGroup( 4 ) )[3];;
# gap> ind:= InducedRepresentation( hom, SymmetricGroup( 5 ) );;
# gap> blockmats:= Elements( Image( ind ) );;
# gap> # Note that `Random' for the matrix group would construct a matrix
# gap> # via the homomorphism to a perm. group, and this would not be a
# gap> # block matrix!
# gap> TestOfAdditiveListArithmetic( blockmats, 4 );
# gap> TestOfMultiplicativeListArithmetic( blockmats, 4 );
gap> STOP_TEST( "arithlst.tst", 1);

#############################################################################
##
#E
