#############################################################################
##
#W  arithlst.tst                GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");


#############################################################################
##
#F  TestOfListArithmetic( <R>, <dim>, <preparatory> )
##
##  performs a series of tests for vector and matrix arithmetics over the
##  ring <R>, all vectors and matrices of dimension <dim>.
##
##  One aim of these tests is to check whether the mutability rule holds.
##  Another aim is to check whether the arithmetic operations with vectors
##  and matrices over <R> work at all,
##  also for possibly existing special representations that can be forced
##  with `ConvertToVectorRep' and `ConvertToMatrixRep'.
##
##  The result of an arithmetic operation is mutable except if the operation
##  is binary and both arguments are immutable
##  (see Section~"Copyability and Mutability" in the Reference Manual).
##
gap> TestOfListArithmetic := function( R, dim )
> 
>   local UnaryTest,
>         BinaryTest,
>         z, s, int, v1, v2, v3, m1, m2, m3, m4, m5, res;
>   
>   # Create a function for testing a unary operation when applied to
>   # a mutable and an immutable list.
>   # (The result shall be *mutable*.)
>   UnaryTest:= function( list, opr, nameopr )
>     local res;
> 
>     # Test the operation for the mutable list.
>     if not IsMutable( list ) then
>       Error( "<list> must be mutable" );
>     fi;
>     res:= opr( list );
>     if not IsMutable( res ) then
>       Print( "# failure in\n",
>              nameopr, "( ", list , " )\n",
>              "# (result must be mutable)\n" );
>     fi;
> 
>     # Test the operation for the immutable list.
>     res:= opr( Immutable( list ) );
>     if not IsMutable( res ) then
>       Print( "# failure in\n",
>              nameopr, "( ", list, " )\n",
>              "# (result must be mutable)\n" );
>     fi;
>   end;
> 
>   # Create a function for testing a binary operation when applied to
>   # two mutable or immutable lists (all combinations)
>   # or applied to one list and one immutable nonlist.
>   # (The result shall be *mutable* except if both arguments are immutable.)
>   BinaryTest:= function( list1, list2, opr, nameopr )
>     local res;
> 
>     if IsList( list1 ) and IsList( list2 ) then
> 
>       # Test the operation for two mutable lists.
>       if not IsMutable( list1 ) or not IsMutable( list2 ) then
>         Error( "both <list1> and <list2> must be mutable" );
>       fi;
> 
>       res:= opr( list1, list2 );
>       if not IsMutable( res ) then
>         Print( "# failure in\n",
>                nameopr, "( ", list1, ", ", list2, " )\n",
>                "# (result must be mutable)\n" );
>       fi;
> 
>       # Test the operation for two immutable lists.
>       res:= opr( Immutable( list1 ), Immutable( list2 ) );
>       if IsMutable( res ) then
>         Print( "# failure in\n",
>                nameopr, "( Immutable( ", list1,
>                " ), Immutable( ", list2, " ) )\n",
>                "# (result must be immutable)\n" );
>       fi;
> 
>     fi;
> 
>     if IsList( list1 ) then
> 
>       # Test the operation for immutable first argument.
>       res:= opr( Immutable( list1 ), list2 );
>       if IsMutable( res ) <> IsMutable( list2 ) then
>         Print( "# failure in ", nameopr, "( Immutable( ", list1,
>                " ), ", list2, " )\n",
>                "# (result must be " );
>         if not IsMutable( list2 ) then
>           Print( "im" );
>         fi;
>         Print( "mutable)\n" );
>       fi;
> 
>     fi;
> 
>     if IsList( list2 ) then
> 
>       # Test the operation for immutable second argument.
>       res:= opr( list1, Immutable( list2 ) );
>       if IsMutable( res ) <> IsMutable( list1 ) then
>         Print( "# failure in\n",
>                nameopr, "( ", list1,
>                ", Immutable( ", list2, " ) )\n",
>                "# (result must be " );
>         if not IsMutable( list1 ) then
>           Print( "im" );
>         fi;
>         Print( "mutable)\n" );
>       fi;
> 
>     fi;
>   end;
> 
> 
>   # Create some vectors and matrices.
>   z:= Zero( R );
>   repeat
>     s:= Random( R );
>   until s <> z;
>   if Characteristic( R ) = 0 then
>     repeat
>       int:= Random( [ 1 .. 100 ] );
>     until int <> 0;
>   else
>     repeat
>       int:= Random( [ 1 .. 100 ] );
>     until int mod Characteristic(R) <> 0;
>   fi;
>   v1:= List( [ 1 .. dim ], i -> Random( R ) );
>   v2:= List( [ 1 .. dim ], i -> Random( R ) );
>   v3:= List( [ 1 .. dim ], i -> Random( R ) );
>   m1:= RandomMat( dim, dim, R );
>   m2:= RandomMat( dim, dim, R );
>   m3:= RandomMat( dim, dim, R );
>   m4:= RandomInvertibleMat( dim, R );
>   m5:= RandomInvertibleMat( dim, R );
>   ConvertToMatrixRep( m3 );
>   ConvertToMatrixRep( m5 );
> 
>   # Start the tests.
>   # Test ZeroOp for vectors.
>   UnaryTest( v1, ZeroOp, "ZeroOp" );
>   UnaryTest( v3, ZeroOp, "ZeroOp" );
> 
>   # Test AdditiveInverseOp for vectors.
>   UnaryTest( v1, AdditiveInverseOp, "AdditiveInverseOp" );
>   UnaryTest( v3, AdditiveInverseOp, "AdditiveInverseOp" );
> 
>   # Test vector addition.
>   BinaryTest( v1, v2, \+, "\\+" );
>   BinaryTest( v1, v3, \+, "\\+" );
>   BinaryTest( v3, v2, \+, "\\+" );
> 
>   # Test vector subtraction.
>   BinaryTest( v1, v2, \-, "\\-" );
>   BinaryTest( v1, v3, \-, "\\-" );
>   BinaryTest( v3, v2, \-, "\\-" );
> 
>   # Test addition of scalar and vector.
>   BinaryTest( s, v2, \+, "\\+" );
>   BinaryTest( s, v3, \+, "\\+" );
> 
>   # Test addition of vector and scalar.
>   BinaryTest( v2, s, \+, "\\+" );
>   BinaryTest( v3, s, \+, "\\+" );
> 
>   # Test scalar multiples of coefficients with vectors.
>   BinaryTest( s, v2, \*, "\\*" );
>   BinaryTest( s, v3, \*, "\\*" );
> 
>   # Test scalar multiples of vectors with coefficients.
>   BinaryTest( v2, s, \*, "\\*" );
>   BinaryTest( v3, s, \*, "\\*" );
> 
>   # Test scalar multiples of integers with vectors.
>   BinaryTest( int, v2, \*, "\\*" );
>   BinaryTest( int, v3, \*, "\\*" );
> 
>   # Test scalar multiples of vectors with integers.
>   BinaryTest( v2, int, \*, "\\*" );
>   BinaryTest( v3, int, \*, "\\*" );
> 
>   # Test ZeroOp for matrices.
>   UnaryTest( m1, ZeroOp, "ZeroOp" );
>   UnaryTest( m3, ZeroOp, "ZeroOp" );
> 
>   # Test AdditiveInverseOp for matrices.
>   UnaryTest( m1, AdditiveInverseOp, "AdditiveInverseOp" );
>   UnaryTest( m3, AdditiveInverseOp, "AdditiveInverseOp" );
> 
>   # Test matrix addition.
>   BinaryTest( m1, m2, \+, "\\+" );
>   BinaryTest( m1, m3, \+, "\\+" );
>   BinaryTest( m3, m2, \+, "\\+" );
> 
>   # Test matrix subtraction.
>   BinaryTest( m1, m2, \-, "\\-" );
>   BinaryTest( m1, m3, \-, "\\-" );
>   BinaryTest( m3, m2, \-, "\\-" );
> 
>   # Test addition of scalar and vector.
>   BinaryTest( s, m2, \+, "\\+" );
>   BinaryTest( s, m3, \+, "\\+" );
> 
>   # Test addition of vector and scalar.
>   BinaryTest( m2, s, \+, "\\+" );
>   BinaryTest( m3, s, \+, "\\+" );
> 
>   # Test OneOp for matrices.
>   UnaryTest( m1, OneOp, "OneOp" );
>   UnaryTest( m3, OneOp, "OneOp" );
> 
>   # Test InverseOp for matrices.
>   UnaryTest( m4, InverseOp, "InverseOp" );
>   UnaryTest( m5, InverseOp, "InverseOp" );
> 
>   # Test matrix multiplication.
>   BinaryTest( m1, m2, \*, "\\*" );
>   BinaryTest( m1, m3, \*, "\\*" );
>   BinaryTest( m3, m2, \*, "\\*" );
> 
>   # Test division of matrices.
>   BinaryTest( m1, m4, \/, "\\/" );
>   BinaryTest( m1, m5, \/, "\\/" );
>   BinaryTest( m3, m5, \/, "\\/" );
> 
>   # Test conjugation of matrices.
>   BinaryTest( m1, m4, \^, "\\^" );
>   BinaryTest( m1, m5, \^, "\\^" );
>   BinaryTest( m3, m5, \^, "\\^" );
> 
>   # Test Comm for matrices.
>   BinaryTest( m4, m4, Comm, "Comm" );
>   BinaryTest( m4, m5, Comm, "Comm" );
>   BinaryTest( m5, m4, Comm, "Comm" );
> 
>   # Test LeftQuotient for matrices.
>   BinaryTest( m4, m1, LeftQuotient, "LeftQuotient" );
>   BinaryTest( m5, m1, LeftQuotient, "LeftQuotient" );
>   BinaryTest( m5, m3, LeftQuotient, "LeftQuotient" );
> 
>   # Test scalar multiples of coefficients with matrices.
>   BinaryTest( s, m2, \*, "\\*" );
>   BinaryTest( s, m3, \*, "\\*" );
> 
>   # Test scalar multiples of matrices with coefficients.
>   BinaryTest( m2, s, \*, "\\*" );
>   BinaryTest( m3, s, \*, "\\*" );
> 
>   # Test scalar multiples of integers with matrices.
>   BinaryTest( int, m2, \*, "\\*" );
>   BinaryTest( int, m3, \*, "\\*" );
> 
>   # Test scalar multiples of matrices with integers.
>   BinaryTest( m2, int, \*, "\\*" );
>   BinaryTest( m3, int, \*, "\\*" );
> 
>   # Test multiplication of vector and matrix.
>   BinaryTest( v1, m2, \*, "\\*" );
>   BinaryTest( v1, m3, \*, "\\*" );
>   BinaryTest( v3, m2, \*, "\\*" );
>   BinaryTest( v3, m3, \*, "\\*" );
> 
>   # Test multiplication of matrix and vector.
>   BinaryTest( m2, v1, \*, "\\*" );
>   BinaryTest( m3, v1, \*, "\\*" );
>   BinaryTest( m2, v3, \*, "\\*" );
>   BinaryTest( m3, v3, \*, "\\*" );
> 
>   # Test LieBracket for matrices.
>   BinaryTest( m1, m2, LieBracket, "LieBracket" );
>   BinaryTest( m1, m3, LieBracket, "LieBracket" );
>   BinaryTest( m3, m2, LieBracket, "LieBracket" );
> end;;

# Here the tests themselves start.
gap> TestOfListArithmetic( GF(2), 5 );
gap> TestOfListArithmetic( GF(25), 5 );
gap> TestOfListArithmetic( GF( NextPrimeInt( MAXSIZE_GF_INTERNAL ) ), 5 );
gap> TestOfListArithmetic( Rationals, 2 );
gap> TestOfListArithmetic( QuaternionAlgebra( Rationals ), 2 );


gap> STOP_TEST( "arithlst.tst", 2000000 );


#############################################################################
##
#E

