#############################################################################
##
#W  arithlst.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the function that is used to create the contents of
##  the file `arithlst.tst'.
##


#############################################################################
##
#F  GenerateTestOfListArithmetic( <R>, <dim>, <preparatory> )
##
##  prints a series of tests for vector and matrix arithmetics over the ring
##  <R>, all vectors and matrices of dimension <dim>.
##  The third argument <preparatory> must be a (possibly empty) list of
##  strings that print the assignments needed to use the `Print' values of
##  nonzero elements in <R> as {\GAP} input.
##  An example is a test for vectors over a quaternion algebra,
##  where <preparatory> may look as follows.
##  \begintt
##  [ "R:= QuaternionAlgebra( Rationals );;",
##    "gens:= GeneratorsOfAlgebraWithOne( R );;",
##    "e:= gens[1];; i:= gens[2];; j:= gens[3];; k:= gens[4];;" ]
##  \endtt
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
GenerateTestOfListArithmetic := function( R, dim, preparatory )

  local PrintVector,
        PrintMatrix,
        PrintUnaryTest,
        PrintBinaryTest,
        i, z, s, int, v1, v2, v3, m1, m2, m3, m4, m5,
        res, count;
  
  count := 1;

  # Create a function that prints a vector of length `dim'.
  # (Some zero elements need special treatment.)
  PrintVector:= function( prefix, vector, suffix )
    local i;
    Print( prefix, "[ " );
    for i in [ 1 .. dim-1 ] do
      if vector[i] = z then
        Print( "z, " );
      else
        Print( vector[i], ", " );
      fi;
    od;
    if vector[ dim ] = z then
      Print( "z ]" );
    else
      Print( vector[ dim ], " ]" );
    fi;
    Print( suffix );
  end;

  # Create a function that prints a square matrix
  # of dimension `dim'.
  PrintMatrix:= function( name, matrix )
    local i;
    PrintVector( Concatenation( "gap> ", name, ":= [ " ),
                 matrix[1], ",\n" );
    for i in [ 2 .. dim-1 ] do
      PrintVector( "> ", matrix[i], ",\n" );
    od;
    PrintVector( "> ", matrix[ dim ], " ];;\n" );
  end;

  # Create a function for testing a unary operation when applied to
  # a mutable and an immutable list.
  # (The result shall be *mutable*.)
  PrintUnaryTest:= function( list, namelist, opr, nameopr )
    local res;

    # Test the operation for the mutable list.
    if not IsMutable( list ) then
      Error( "<list> must be mutable" );
    fi;

    res:= opr( list );
    Print( "gap> res:= ", nameopr, "( ", namelist, " );;  " );
    Print( "Print( res, \"\\n\" );\n" );
    Print( res, "\n" );
    Print( "gap> if not IsMutable( res ) then\n" );
    Print( ">      Print( \"failure in ", nameopr, "( ", namelist, " ),\",\n",
           ">             \" (result must be mutable) \# ",
           count, "\\n\" );\n" );
    Print( ">    fi;\n" );
    count := count +1;      

    # Test the operation for the immutable list.
    res:= opr( Immutable( list ) );
    Print( "gap> res:= ", nameopr, "( Immutable( ", namelist, " ) );;  " );
    Print( "Print( res, \"\\n\" );\n" );
    Print( res, "\n" );
    Print( "gap> if not IsMutable( res ) then\n" );
    Print( ">      Print( \"failure in ", nameopr, "( ", namelist, " ),\",\n",
           ">             \" (result must be mutable) \# ",
           count, "\\n\" );\n" );
    Print( ">    fi;\n" );
    count := count +1;      
  end;

  # Create a function for testing a binary operation when applied to
  # two mutable or immutable lists (all combinations)
  # or applied to one list and one immutable nonlist.
  # (The result shall be *mutable* except if both arguments are immutable.)
  PrintBinaryTest:= function( list1, list2, name1, name2, opr, nameopr )
    local res;

    if IsList( list1 ) and IsList( list2 ) then

      # Test the operation for two mutable lists.
      if not IsMutable( list1 ) or not IsMutable( list2 ) then
        Error( "both <list1> and <list2> must be mutable" );
      fi;

      res:= opr( list1, list2 );
      Print( "gap> res:= ", nameopr, "( ", name1, ", ", name2, " );;  " );
      Print( "Print( res, \"\\n\" );\n" );
      Print( res, "\n" );
      Print( "gap> if not IsMutable( res ) then\n" );
      Print( ">      Print( \"failure in ", nameopr, "( ", name1,
             ", ", name2, " )\",\n",
             ">             \" (result must be mutable) \# ",
             count, "\\n\" );\n" );
      Print( ">    fi;\n" );
      count := count +1;      

      # Test the operation for two immutable lists.
      res:= opr( Immutable( list1 ), Immutable( list2 ) );
      Print( "gap> res:= ", nameopr, "( Immutable( ", name1, " ), ",
             "Immutable( ", name2, " ) );;\n" );
      Print( "gap> Print( res, \"\\n\" );\n" );
      Print( res, "\n" );
      Print( "gap> if IsMutable( res ) then\n" );
      Print( ">      Print( \"failure in ", nameopr, "( Immutable( ", name1,
             " ), Immutable( ", name2, " ) )\",\n",
             ">             \" (result must be immutable) \# ",
             count, "\\n\" );\n" );
      Print( ">    fi;\n" );
      count := count +1;      

    fi;

    if IsList( list1 ) then

      # Test the operation for immutable first argument.
      res:= opr( Immutable( list1 ), list2 );
      Print( "gap> res:= ", nameopr, "( Immutable( ", name1, " ), ",
             name2, " );;  " );
      Print( "Print( res, \"\\n\" );\n" );
      Print( res, "\n" );
      Print( "gap> if IsMutable( res ) <> IsMutable( ", name2, " ) then\n" );
      Print( ">      Print( \"failure in ", nameopr, "( Immutable( ", name1,
             " ), ", name2, " )\",\n",
             ">             \" (result must be " );
      if not IsMutable( list2 ) then
        Print( "im" );
      fi;
      Print( "mutable) \# ",
             count, "\\n\" );\n" );
      Print( ">    fi;\n" );
      count := count +1;      

    fi;

    if IsList( list2 ) then

      # Test the operation for immutable second argument.
      res:= opr( list1, Immutable( list2 ) );
      Print( "gap> res:= ", nameopr, "( ", name1, ", ",
             "Immutable( ", name2, " ) );;  " );
      Print( "Print( res, \"\\n\" );\n" );
      Print( res, "\n" );
      Print( "gap> if IsMutable( res ) <> IsMutable( ", name1, " ) then\n" );
      Print( ">      Print( \"failure in ", nameopr, "( ", name1,
             ", Immutable( ", name2, " ) )\",\n",
             ">             \" (result must be " );
      if not IsMutable( list1 ) then
        Print( "im" );
      fi;
      Print( "mutable) \# ",
             count, "\\n\" );\n" );
      Print( ">    fi;\n" );
      count := count +1;      

    fi;
  end;


  # Print a header.
  for i in [ 1 .. 77 ] do Print( "#" ); od;
  Print( "\n##\n##  Check coefficients in ", R, "\n##\n\n" );
  if not IsEmpty( preparatory ) then
    for i in preparatory do
      Print( "gap> ", i, "\n" );
    od;
  fi;

  # Create some vectors and matrices, and print their construction.
  z:= Zero( R );
  repeat s:= Random( R ); until s <> z;
  if Characteristic( R ) = 0 then
    repeat int:= Random( [ 1 .. 100 ] ); until int <> 0;
  else
    repeat int:= Random( [ 1 .. 100 ] ); until int mod Characteristic(R) <> 0;
  fi;
  v1:= List( [ 1 .. dim ], i -> Random( R ) );
  v2:= List( [ 1 .. dim ], i -> Random( R ) );
  v3:= List( [ 1 .. dim ], i -> Random( R ) );
  m1:= RandomMat( dim, dim, R );
  m2:= RandomMat( dim, dim, R );
  m3:= RandomMat( dim, dim, R );
  m4:= RandomInvertibleMat( dim, R );
  m5:= RandomInvertibleMat( dim, R );

  Print( "gap> z:= ", z, ";\n" );
  View( z );  Print( "\n" );
  Print( "gap> s:= ", s, ";\n" );
  View( s );  Print( "\n" );
  Print( "gap> int:= ", int, ";\n" );
  View( int );  Print( "\n" );
  PrintVector( "gap> v1:= ", v1, ";\n" );
  View( v1 );  Print( "\n" );
  PrintVector( "gap> v2:= ", v2, ";\n" );
  View( v2 );  Print( "\n" );
  PrintVector( "gap> v3:= ", v3, ";\n" );
  View( v3 );  Print( "\n" );
  Print( "gap> ConvertToVectorRep( v3 );;\n" );
  ConvertToVectorRep( v3 );
  Print( "gap> v3;\n" ); View( v3 ); Print( "\n" );
  PrintMatrix( "m1", m1 );
  PrintMatrix( "m2", m2 );
  PrintMatrix( "m3", m3 );
  PrintMatrix( "m4", m4 );
  PrintMatrix( "m5", m5 );
  ConvertToMatrixRep( m3 );
  ConvertToMatrixRep( m5 );
  Print( "gap> ConvertToMatrixRep( m3 );;\n" );
  Print( "gap> m3;\n" ); View( m3 ); Print( "\n" );
  Print( "gap> ConvertToMatrixRep( m5 );;\n" );
  Print( "gap> m5;\n" ); View( m5 ); Print( "\n" );
  Print( "\n" );

  # Start the tests.
  Print( "# Test ZeroOp for vectors.\n" );
  PrintUnaryTest( v1, "v1", ZeroOp, "ZeroOp" );
  PrintUnaryTest( v3, "v3", ZeroOp, "ZeroOp" );
  Print( "\n" );

  Print( "# Test AdditiveInverseOp for vectors.\n" );
  PrintUnaryTest( v1, "v1", AdditiveInverseOp, "AdditiveInverseOp" );
  PrintUnaryTest( v3, "v3", AdditiveInverseOp, "AdditiveInverseOp" );
  Print( "\n" );

  Print( "# Test vector addition.\n" );
  PrintBinaryTest( v1, v2, "v1", "v2", \+, "\\+" );
  PrintBinaryTest( v1, v3, "v1", "v3", \+, "\\+" );
  PrintBinaryTest( v3, v2, "v3", "v2", \+, "\\+" );
  Print( "\n" );

  Print( "# Test vector subtraction.\n" );
  PrintBinaryTest( v1, v2, "v1", "v2", \-, "\\-" );
  PrintBinaryTest( v1, v3, "v1", "v3", \-, "\\-" );
  PrintBinaryTest( v3, v2, "v3", "v2", \-, "\\-" );
  Print( "\n" );

  Print( "# Test addition of scalar and vector.\n" );
  PrintBinaryTest( s, v2, "s", "v2", \+, "\\+" );
  PrintBinaryTest( s, v3, "s", "v3", \+, "\\+" );
  Print( "\n" );

  Print( "# Test addition of vector and scalar.\n" );
  PrintBinaryTest( v2, s, "v2", "s", \+, "\\+" );
  PrintBinaryTest( v3, s, "v3", "s", \+, "\\+" );
  Print( "\n" );

  Print( "# Test scalar multiples of coefficients with vectors.\n" );
  PrintBinaryTest( s, v2, "s", "v2", \*, "\\*" );
  PrintBinaryTest( s, v3, "s", "v3", \*, "\\*" );
  Print( "\n" );

  Print( "# Test scalar multiples of vectors with coefficients.\n" );
  PrintBinaryTest( v2, s, "v2", "s", \*, "\\*" );
  PrintBinaryTest( v3, s, "v3", "s", \*, "\\*" );
  Print( "\n" );

  Print( "# Test scalar multiples of integers with vectors.\n" );
  PrintBinaryTest( int, v2, "int", "v2", \*, "\\*" );
  PrintBinaryTest( int, v3, "int", "v3", \*, "\\*" );
  Print( "\n" );

  Print( "# Test scalar multiples of vectors with integers.\n" );
  PrintBinaryTest( v2, int, "v2", "int", \*, "\\*" );
  PrintBinaryTest( v3, int, "v3", "int", \*, "\\*" );
  Print( "\n" );

  Print( "# Test ZeroOp for matrices.\n" );
  PrintUnaryTest( m1, "m1", ZeroOp, "ZeroOp" );
  PrintUnaryTest( m3, "m3", ZeroOp, "ZeroOp" );
  Print( "\n" );

  Print( "# Test AdditiveInverseOp for matrices.\n" );
  PrintUnaryTest( m1, "m1", AdditiveInverseOp, "AdditiveInverseOp" );
  PrintUnaryTest( m3, "m3", AdditiveInverseOp, "AdditiveInverseOp" );
  Print( "\n" );

  Print( "# Test matrix addition.\n" );
  PrintBinaryTest( m1, m2, "m1", "m2", \+, "\\+" );
  PrintBinaryTest( m1, m3, "m1", "m3", \+, "\\+" );
  PrintBinaryTest( m3, m2, "m3", "m2", \+, "\\+" );
  Print( "\n" );

  Print( "# Test matrix subtraction.\n" );
  PrintBinaryTest( m1, m2, "m1", "m2", \-, "\\-" );
  PrintBinaryTest( m1, m3, "m1", "m3", \-, "\\-" );
  PrintBinaryTest( m3, m2, "m3", "m2", \-, "\\-" );
  Print( "\n" );

  Print( "# Test addition of scalar and vector.\n" );
  PrintBinaryTest( s, m2, "s", "m2", \+, "\\+" );
  PrintBinaryTest( s, m3, "s", "m3", \+, "\\+" );
  Print( "\n" );

  Print( "# Test addition of vector and scalar.\n" );
  PrintBinaryTest( m2, s, "m2", "s", \+, "\\+" );
  PrintBinaryTest( m3, s, "m3", "s", \+, "\\+" );
  Print( "\n" );

  Print( "# Test OneOp for matrices.\n" );
  PrintUnaryTest( m1, "m1", OneOp, "OneOp" );
  PrintUnaryTest( m3, "m3", OneOp, "OneOp" );
  Print( "\n" );

  Print( "# Test InverseOp for matrices.\n" );
  PrintUnaryTest( m4, "m4", InverseOp, "InverseOp" );
  PrintUnaryTest( m5, "m5", InverseOp, "InverseOp" );
  Print( "\n" );

  Print( "# Test matrix multiplication.\n" );
  PrintBinaryTest( m1, m2, "m1", "m2", \*, "\\*" );
  PrintBinaryTest( m1, m3, "m1", "m3", \*, "\\*" );
  PrintBinaryTest( m3, m2, "m3", "m2", \*, "\\*" );
  Print( "\n" );

  Print( "# Test division of matrices.\n" );
  PrintBinaryTest( m1, m4, "m1", "m4", \/, "\\/" );
  PrintBinaryTest( m1, m5, "m1", "m5", \/, "\\/" );
  PrintBinaryTest( m3, m5, "m3", "m5", \/, "\\/" );
  Print( "\n" );

  Print( "# Test conjugation of matrices.\n" );
  PrintBinaryTest( m1, m4, "m1", "m4", \^, "\\^" );
  PrintBinaryTest( m1, m5, "m1", "m5", \^, "\\^" );
  PrintBinaryTest( m3, m5, "m3", "m5", \^, "\\^" );
  Print( "\n" );

  Print( "# Test Comm for matrices.\n" );
  PrintBinaryTest( m4, m4, "m4", "m4", Comm, "Comm" );
  PrintBinaryTest( m4, m5, "m4", "m5", Comm, "Comm" );
  PrintBinaryTest( m5, m4, "m5", "m4", Comm, "Comm" );
  Print( "\n" );

  Print( "# Test LeftQuotient for matrices.\n" );
  PrintBinaryTest( m4, m1, "m4", "m1", LeftQuotient, "LeftQuotient" );
  PrintBinaryTest( m5, m1, "m5", "m1", LeftQuotient, "LeftQuotient" );
  PrintBinaryTest( m5, m3, "m5", "m3", LeftQuotient, "LeftQuotient" );
  Print( "\n" );

  Print( "# Test scalar multiples of coefficients with matrices.\n" );
  PrintBinaryTest( s, m2, "s", "m2", \*, "\\*" );
  PrintBinaryTest( s, m3, "s", "m3", \*, "\\*" );
  Print( "\n" );

  Print( "# Test scalar multiples of matrices with coefficients.\n" );
  PrintBinaryTest( m2, s, "m2", "s", \*, "\\*" );
  PrintBinaryTest( m3, s, "m3", "s", \*, "\\*" );
  Print( "\n" );

  Print( "# Test scalar multiples of integers with matrices.\n" );
  PrintBinaryTest( int, m2, "int", "m2", \*, "\\*" );
  PrintBinaryTest( int, m3, "int", "m3", \*, "\\*" );
  Print( "\n" );

  Print( "# Test scalar multiples of matrices with integers.\n" );
  PrintBinaryTest( m2, int, "m2", "int", \*, "\\*" );
  PrintBinaryTest( m3, int, "m3", "int", \*, "\\*" );
  Print( "\n" );

  Print( "# Test multiplication of vector and matrix.\n" );
  PrintBinaryTest( v1, m2, "v1", "m2", \*, "\\*" );
  PrintBinaryTest( v1, m3, "v1", "m3", \*, "\\*" );
  PrintBinaryTest( v3, m2, "v3", "m2", \*, "\\*" );
  PrintBinaryTest( v3, m3, "v3", "m3", \*, "\\*" );
  Print( "\n" );

  Print( "# Test multiplication of matrix and vector.\n" );
  PrintBinaryTest( m2, v1, "m2", "v1", \*, "\\*" );
  PrintBinaryTest( m3, v1, "m3", "v1", \*, "\\*" );
  PrintBinaryTest( m2, v3, "m2", "v3", \*, "\\*" );
  PrintBinaryTest( m3, v3, "m3", "v3", \*, "\\*" );
  Print( "\n" );

  Print( "# Test LieBracket for matrices.\n" );
  PrintBinaryTest( m1, m2, "m1", "m2", LieBracket, "LieBracket" );
  PrintBinaryTest( m1, m3, "m1", "m3", LieBracket, "LieBracket" );
  PrintBinaryTest( m3, m2, "m3", "m2", LieBracket, "LieBracket" );
  Print( "\n" );
end;


#############################################################################
##
#E

