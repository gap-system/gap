#############################################################################
##
#W  arithlst.g                  GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  2000,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##

#############################################################################
##
##  Parametrize the output; if `error' has the value `Error' then only the
##  first error in each call is printed in the `Test' run,
##  if the value is `Print' then all errors are printed.
##
error:= Print;;

#############################################################################
##
##  How many times to repeat the same tests? Large values result in longer
##  test runs, but with a higher probability of finding bugs
##
ARITH_LST_REPS := 5;


#############################################################################
##
##  Define auxiliary functions.
##
RandomSquareArray := function( dim, D )
  return List( [ 1 .. dim ], i -> List( [ 1 .. dim ], j -> Random( D ) ) );
end;;
NestingDepthATest := function( obj )
  if not IsGeneralizedRowVector( obj ) then
    return 0;
  elif IsEmpty( obj ) then
    return 1;
  else
    return 1 + NestingDepthATest( obj[ PositionBound( obj ) ] );
  fi;
end;;
NestingDepthMTest := function( obj )
  if not IsMultiplicativeGeneralizedRowVector( obj ) then
    return 0;
  elif IsEmpty( obj ) then
    return 1;
  else
    return 1 + NestingDepthMTest( obj[ PositionBound( obj ) ] );
  fi;
end;;
ImmutabilityLevel2 := function( list )
  if not IsList( list ) then
    if IsMutable( list ) then
      Error( "<list> is not a list" );
    else
      return 0;
    fi;
  elif IsEmpty( list ) then
    # The empty list is defined to have immutability level 0.
    return 0;
  elif IsMutable( list ) then
    return ImmutabilityLevel2( list[ PositionBound( list ) ] );
  else
    return 1 + ImmutabilityLevel2( list[ PositionBound( list ) ] );
  fi;
end;;
ImmutabilityLevel := function( list )
  if IsMutable( list ) then
    return ImmutabilityLevel2( list );
  else
    return infinity;
  fi;
end;;

##  Note that the two-argument version of `List' is defined only for
##  dense lists.
ListWithPrescribedHoles := function( list, func )
  local result, i;

  result:= [];
  for i in [ 1 .. Length( list ) ] do
    if IsBound( list[i] ) then
      result[i]:= func( list[i] );
    fi;
  od;
  return result;
end;;
SumWithHoles := function( list )
  local pos, result, i;

  pos:= PositionBound( list );
  result:= list[ pos ];
  for i in [ pos+1 .. Length( list ) ] do
    if IsBound( list[i] ) then
      result:= result + list[i];
    fi;
  od;
  return result;
end;;
ParallelOp := function( op, list1, list2, mode )
  local result, i;

  result:= [];
  for i in [ 1 .. Maximum( Length( list1 ), Length( list2 ) ) ] do
    if IsBound( list1[i] ) then
      if IsBound( list2[i] ) then
        result[i]:= op( list1[i], list2[i] );
      elif mode = "one" then
        result[i]:= ShallowCopy( list1[i] );
      fi;
    elif IsBound( list2[i] ) and mode = "one" then
      result[i]:= ShallowCopy( list2[i] );
    fi;
  od;
  return result;
end;;
ErrorMessage := function( opname, operands, info, is, should )
  local str, i;

  str:= Concatenation( opname, "( " );
  for i in [ 1 .. Length( operands ) - 1 ] do
    Append( str, operands[i] );
    Append( str, ", " );
  od;
  error( str, operands[ Length( operands ) ], " ):  ", info, ",\n",
         "should be ", should, " but is ", is, "\n" );
end;;
CheckMutabilityStatus := function( opname, list )
  local attr, op, val, sm;

  attr:= ValueGlobal( Concatenation( opname, "Attr" ) );
  if ImmutabilityLevel( attr( list ) ) <> infinity then
    error( opname, "Attr: mutability problem for ", list,
           " (", ImmutabilityLevel( list ), ")\n" );
  fi;
  op:= ValueGlobal( Concatenation( opname, "Op" ) );
  val:= op( list );
  if val <> fail and IsCopyable( val ) and not IsMutable( val ) then
    error( opname, "Op: mutability problem for ", list,
           " (", ImmutabilityLevel( list ), ")\n" );
  fi;
  sm:= ValueGlobal( Concatenation( opname, "SM" ) );
  val:= sm( list );
  if     val <> fail
     and IsCopyable( val )
     and ImmutabilityLevel( sm( list ) ) <> ImmutabilityLevel( list ) then
    error( opname, "SM: mutability problem for ", list,
           " (", ImmutabilityLevel( list ), ")\n" );
  fi;
end;;

##  Check whether a unary operation preserves the compression status.
COMPRESSIONS := [ "Is8BitMatrixRep", "Is8BitVectorRep",
                     "IsGF2VectorRep", "IsGF2MatrixRep" ];;
CheckCompressionStatus := function( opname, list )
  local value, namefilter, filter;

  value:= ValueGlobal( opname )( list );
  if value <> fail then
    for namefilter in COMPRESSIONS do
      filter:= ValueGlobal( namefilter );
      if filter( list ) and not filter( value ) then
        error( opname, " does not preserve `", namefilter, "'\n" );
      fi;
    od;
  fi;
end;;
CompareTest := function( opname, operands, result, desired )
  local i, j, val;

  # Check that the same positions are bound,
  # and that corresponding entries are equal.
  if IsList( result ) and IsList( desired ) then
    if Length( result ) <> Length( desired ) then
      ErrorMessage( opname, operands, "lengths differ",
                    Length( result ), Length( desired ) );
    fi;
    for i in [ 1 .. Length( result ) ] do
      if IsBound( result[i] ) then
        if not IsBound( desired[i] ) then
          ErrorMessage( opname, operands,
                        Concatenation( "bound at ", String( i ) ),
                        result[i], "unbound" );
        elif result[i] <> desired[i] then
          ErrorMessage( opname, operands,
                        Concatenation( "error at ", String( i ) ),
                        result[i], desired[i] );
        fi;
      elif IsBound( desired[i] ) then
          ErrorMessage( opname, operands,
                        Concatenation( "unbound at ", String( i ) ),
                        "unbound", desired[i] );
      fi;
    od;
  elif IsList( result ) or IsList( desired ) then
    ErrorMessage( opname, operands, "list vs. non-list", result, desired );
  elif result <> desired then
    ErrorMessage( opname, operands, "two non-lists", result, desired );
  fi;

  # Check the mutability status.
  if     Length( operands ) = 2
     and IsList( result ) and IsCopyable( result )
     and ImmutabilityLevel( result )
         <> Minimum( List( operands, ImmutabilityLevel ) ) 
     and not (ImmutabilityLevel(result)=infinity and
               NestingDepthM(result) = 
                      Minimum( List( operands, ImmutabilityLevel ) )) then
    error( opname, ": mutability problem for ", operands[1], " (",
           ImmutabilityLevel( operands[1] ), ") and ", operands[2], " (",
           ImmutabilityLevel( operands[2] ), ")\n" );
  fi;
end;;

#############################################################################
##
#F  ZeroTest( <list> )
##
##  The zero of a list $x$ in `IsGeneralizedRowVector' is defined as
##  the list whose entry at position $i$ is the zero of $x[i]$
##  if this entry is bound, and is unbound otherwise.
##
ZeroTest := function( list )
  if IsGeneralizedRowVector( list ) then
    CompareTest( "Zero", [ list ],
                 Zero( list ),
                 ListWithPrescribedHoles( list, Zero ) );
    CheckMutabilityStatus( "Zero", list );
    CheckCompressionStatus( "ZeroAttr", list );
    CheckCompressionStatus( "ZeroSM", list );
  fi;
end;;

#############################################################################
##
#F  AdditiveInverseTest( <list> )
##
##  The additive inverse of a list $x$ in `IsGeneralizedRowVector' is defined
##  as the list whose entry at position $i$ is the additive inverse of $x[i]$
##  if this entry is bound, and is unbound otherwise.
##
AdditiveInverseTest := function( list )
  if IsGeneralizedRowVector( list ) then
    CompareTest( "AdditiveInverse", [ list ],
                 AdditiveInverse( list ),
                 ListWithPrescribedHoles( list, AdditiveInverse ) );
    CheckMutabilityStatus( "AdditiveInverse", list );
    CheckCompressionStatus( "AdditiveInverseAttr", list );
    CheckCompressionStatus( "AdditiveInverseSM", list );
  fi;
end;;

#############################################################################
##
#F  AdditionTest( <left>, <right> )
##
##  If $x$ and $y$ are in `IsGeneralizedRowVector' and have the same
##  additive nesting depth (see~"NestingDepthA"),
##  % By definition, this depth is nonzero.
##  the sum $x + y$ is defined *pointwise*, in the sense that the result is a
##  list whose entry at position $i$ is $x[i] + y[i]$ if these entries are
##  bound,
##  is a shallow copy (see~"ShallowCopy") of $x[i]$ or $y[i]$ if the other
##  argument is not bound at position $i$,
##  and is unbound if both $x$ and $y$ are unbound at position $i$.
##
##  If $x$ is in `IsGeneralizedRowVector' and $y$ is either not a list or is
##  in `IsGeneralizedRowVector' and has lower additive nesting depth,
##  the sum $x + y$ is defined as a list whose entry at position $i$ is
##  $x[i] + y$ if $x$ is bound at position $i$, and is unbound if not.
##  The equivalent holds in the reversed case,
##  where the order of the summands is kept,
##  as addition is not always commutative.
##
##  For two {\GAP} objects $x$ and $y$ of which one is in
##  `IsGeneralizedRowVector' and the other is either not a list or is
##  also in `IsGeneralizedRowVector',
##  $x - y$ is defined as $x + (-y)$.
##
AdditionTest := function( left, right )
  local depth1, depth2, desired;

  if IsGeneralizedRowVector( left ) and IsGeneralizedRowVector( right ) then
    depth1:= NestingDepthATest( left );
    depth2:= NestingDepthATest( right );
    if depth1 = depth2 then
      desired:= ParallelOp( \+, left, right, "one" );
    elif depth1 < depth2 then
      desired:= ListWithPrescribedHoles( right, x -> left + x );
    else
      desired:= ListWithPrescribedHoles( left, x -> x + right );
    fi;
  elif IsGeneralizedRowVector( left ) and not IsList( right ) then
    desired:= ListWithPrescribedHoles( left, x -> x + right );
  elif not IsList( left ) and IsGeneralizedRowVector( right ) then
    desired:= ListWithPrescribedHoles( right, x -> left + x );
  else
    return;
  fi;
  CompareTest( "Addition", [ left, right ], left + right, desired );
  if AdditiveInverse( right ) <> fail then
    CompareTest( "Subtraction", [ left, right ], left - right,
                 left + ( - right ) );
  fi;
end;;

#############################################################################
##
#F  OneTest( <list> )
##
OneTest := function( list )
  if IsOrdinaryMatrix( list ) and Length( list ) = Length( list[1] ) then
    CheckMutabilityStatus( "One", list );
    CheckCompressionStatus( "OneAttr", list );
    CheckCompressionStatus( "OneSM", list );
  fi;
end;;

#############################################################################
##
#F  InverseTest( <obj> )
##
InverseTest := function( list )
  if IsOrdinaryMatrix( list ) and Length( list ) = Length( list[1] ) then
    CheckMutabilityStatus( "Inverse", list );
    CheckCompressionStatus( "InverseAttr", list );
    CheckCompressionStatus( "InverseSM", list );
  fi;
end;;

#############################################################################
##
#F  TransposedMatTest( <obj> )
##
TransposedMatTest := function( list )
  if IsOrdinaryMatrix( list ) then
    CheckCompressionStatus( "TransposedMatAttr", list );
    CheckCompressionStatus( "TransposedMatOp", list );
  fi;
end;;

#############################################################################
##
#F  MultiplicationTest( <left>, <right> )
##
##  There are three possible computations that might be triggered by a
##  multiplication involving a list in
##  `IsMultiplicativeGeneralizedRowVector'.
##  Namely, $x * y$ might be
##  \beginlist
##  \item{(I)}
##      the inner product $x[1] * y[1] + x[2] * y[2] + \cdots + x[n] * y[n]$,
##      where summands are omitted for which the entry in $x$ or $y$ is
##      unbound
##      (if this leaves no summand then the multiplication is an error),
##      or
##  \item{(L)}
##      the left scalar multiple, i.e., a list whose entry at position $i$ is
##      $x * y[i]$ if $y$ is bound at position $i$, and is unbound if not, or
##  \item{(R)}
##      the right scalar multiple, i.e., a list whose entry at position $i$
##      is $x[i] * y$ if $x$ is bound at position $i$, and is unbound if not.
##  \endlist
##  
##  Our aim is to generalize the basic arithmetic of simple row vectors and
##  matrices, so we first summarize the situations that shall be covered.
##  
##  \beginexample
##      | scl   vec   mat
##  ---------------------
##  scl |       (L)   (L)
##  vec | (R)   (I)   (I)
##  mat | (R)   (R)   (R)
##  \endexample
##  
##  This means for example that the product of a scalar (scl)
##  with a vector (vec) or a matrix (mat) is computed according to (L).
##  Note that this is asymmetric.
##  
##  Now we can state the general multiplication rules.
##  
##  If exactly one argument is in `IsMultiplicativeGeneralizedRowVector'
##  then we regard the other argument (which is then not a list) as a scalar,
##  and specify result (L) or (R), depending on ordering.
##  
##  In the remaining cases, both $x$ and $y$ are in
##  `IsMultiplicativeGeneralizedRowVector', and we distinguish the
##  possibilities by their multiplicative nesting depths.
##  An argument with *odd* multiplicative nesting depth is regarded as a
##  vector, and an argument with *even* multiplicative nesting depth is
##  regarded as a scalar or a matrix.
##  
##  So if both arguments have odd multiplicative nesting depth,
##  we specify result (I).
##  
##  If exactly one argument has odd nesting depth,
##  the other is treated as a scalar if it has lower multiplicative nesting
##  depth, and as a matrix otherwise.
##  In the former case, we specify result (L) or (R), depending on ordering;
##  in the latter case, we specify result (L) or (I), depending on ordering.
##  
##  We are left with the case that each argument has even multiplicative
##  nesting depth.
##  % By definition, this depth is nonzero.
##  If the two depths are equal, we treat the computation as a matrix product,
##  and specify result (R).
##  Otherwise, we treat the less deeply nested argument as a scalar and the
##  other as a matrix, and specify result (L) or (R), depending on ordering.
##  
##  For two {\GAP} objects $x$ and $y$ of which one is in
##  `IsMultiplicativeGeneralizedRowVector' and the other is either not a list
##  or is also in `IsMultiplicativeGeneralizedRowVector',
##  $x / y$ is defined as $x * y^{-1}$.
##
MultiplicationTest := function( left, right )
  local depth1, depth2, par, desired;

  if IsMultiplicativeGeneralizedRowVector( left ) and
     IsMultiplicativeGeneralizedRowVector( right ) then
    depth1:= NestingDepthMTest( left );
    depth2:= NestingDepthMTest( right );
    if IsOddInt( depth1 ) then
      if IsOddInt( depth2 ) or depth1 < depth2 then
        # <vec> * <vec> or <vec> * <mat>
        par:= ParallelOp( \*, left, right, "both" );
        if IsEmpty( par ) then
          error( "vector multiplication <left>*<right> with empty ",
                 "support:\n", left, "\n", right, "\n" );
        else
          desired:= SumWithHoles( par );
        fi;
      else
        # <vec> * <scl>
        desired:= ListWithPrescribedHoles( left, x -> x * right );
      fi;
    elif IsOddInt( depth2 ) then
      if depth1 < depth2 then
        # <scl> * <vec>
        desired:= ListWithPrescribedHoles( right, x -> left * x );
      else
        # <mat> * <vec>
        desired:= ListWithPrescribedHoles( left, x -> x * right );
      fi;
    elif depth1 = depth2 then
      # <mat> * <mat>
      desired:= ListWithPrescribedHoles( left, x -> x * right );
    elif depth1 < depth2 then
      # <scl> * <mat>
      desired:= ListWithPrescribedHoles( right, x -> left * x );
    else
      # <mat> * <scl>
      desired:= ListWithPrescribedHoles( left, x -> x * right );
    fi;
  elif IsMultiplicativeGeneralizedRowVector( left ) and
       not IsList( right ) then
    desired:= ListWithPrescribedHoles( left, x -> x * right );
  elif IsMultiplicativeGeneralizedRowVector( right ) and
       not IsList( left ) then
    desired:= ListWithPrescribedHoles( right, x -> left * x );
  else
    return;
  fi;
  CompareTest( "Multiplication", [ left, right ], left * right, desired );
  if     IsMultiplicativeGeneralizedRowVector( right )
     and IsOrdinaryMatrix( right )
     and Length( right ) = Length( right[1] )
     and NestingDepthM( right ) = 2
     and Inverse( right ) <> fail then
    CompareTest( "Division", [ left, right ], left / right,
                 left * ( right^-1 ) );
  fi;
end;;

#############################################################################
##
#F  RunTest( <func>, <arg1>, ... )
##
##  Call <func> for the remaining arguments, or for shallow copies of them
##  or immutable copies.
##
RunTest := function( arg )
  local combinations, i, entry;

  combinations:= [ ];
  for i in [ 2 .. Length( arg ) ] do
    entry:= [ arg[i] ];
    if IsCopyable( arg[i] ) then
      Add( entry, ShallowCopy( arg[i] ) );
    fi;
    if IsMutable( arg[i] ) then
      Add( entry, Immutable( arg[i] ) );
    fi;
    Add( combinations, entry );
  od;
  for entry in Cartesian( combinations ) do
    CallFuncList( arg[1], entry );
  od;
end;;

#############################################################################
##
#F  TestOfAdditiveListArithmetic( <R>, <dim> )
##
##  For a ring or list of ring elements <R> (such that `Random( <R> )'
##  returns an element in <R> and such that not all elements in <R> are
##  zero),
##  `TestOfAdditiveListArithmetic' performs the following tests of additive
##  arithmetic operations.
##  \beginlist
##  \item{1.}
##      If the elements of <R> are in `IsGeneralizedRowVector' then
##      it is checked whether `Zero', `AdditiveInverse', and `\+'
##      obey the definitions.
##  \item{2.}
##      If the elements of <R> are in `IsGeneralizedRowVector' then
##      it is checked whether the sum of elements in <R> and (non-dense)
##      plain lists of integers obeys the definitions.
##  \item{3.}
##      Check `Zero' and `AdditiveInverse' for nested plain lists of elements
##      in <R>, and `\+' for elements in <R> and nested plain lists of
##      elements in <R>.
##  \endlist
##
TestOfAdditiveListArithmetic := function( R, dim )
  local r, i, intlist, j, vec1, vec2, mat1, mat2, row;

  r:= Random( R );
  if IsGeneralizedRowVector( r ) then

    # tests of kind 1.
    for i in [ 1 .. ARITH_LST_REPS ] do
      RunTest( ZeroTest, Random( R ) );
      RunTest( AdditiveInverseTest, Random( R ) );
      RunTest( AdditionTest, Random( R ), Random( R ) );
    od;

    # tests of kind 2.
    for i in [ 1 .. ARITH_LST_REPS ] do
      RunTest( AdditionTest, Random( R ), [] );
      RunTest( AdditionTest, [], Random( R ) );
      r:= Random( R );
      intlist:= List( [ 1 .. Length( r ) + Random( [ -1 .. 1 ] ) ],
                      x -> Random( Integers ) );
      for j in [ 1 .. Int( Length( r ) / 3 ) ] do
        Unbind( intlist[ Random( [ 1 .. Length( intlist ) ] ) ] );
      od;
      RunTest( AdditionTest, r, intlist );
      RunTest( AdditionTest, intlist, r );
    od;

  fi;

  # tests of kind 3.
  for i in [ 1 .. ARITH_LST_REPS ] do

    vec1:= List( [ 1 .. dim ], x -> Random( R ) );
    vec2:= List( [ 1 .. dim ], x -> Random( R ) );

    RunTest( ZeroTest, vec1 );
    RunTest( AdditiveInverseTest, vec1 );
    RunTest( AdditionTest, vec1, Random( R ) );
    RunTest( AdditionTest, Random( R ), vec2 );
    RunTest( AdditionTest, vec1, vec2 );
    RunTest( AdditionTest, vec1, [] );
    RunTest( AdditionTest, [], vec2 );
    Unbind( vec1[ dim ] );
    RunTest( AdditionTest, vec1, vec2 );
    Unbind( vec2[ Random( [ 1 .. dim ] ) ] );
    RunTest( ZeroTest, vec2 );
    RunTest( AdditiveInverseTest, vec1 );
    RunTest( AdditiveInverseTest, vec2 );
    RunTest( AdditionTest, vec1, vec2 );
    Unbind( vec1[ Random( [ 1 .. dim ] ) ] );
    RunTest( AdditionTest, vec1, vec2 );

    mat1:= RandomSquareArray( dim, R );
    mat2:= RandomSquareArray( dim, R );

    RunTest( ZeroTest, mat1 );
    RunTest( AdditiveInverseTest, mat1 );
    RunTest( TransposedMatTest, mat1 );
    RunTest( AdditionTest, mat1, Random( R ) );
    RunTest( AdditionTest, Random( R ), mat2 );
    RunTest( AdditionTest, vec1, mat2 );
    RunTest( AdditionTest, mat1, vec2 );
    RunTest( AdditionTest, mat1, mat2 );
    RunTest( AdditionTest, mat1, [] );
    RunTest( AdditionTest, [], mat2 );
    Unbind( mat1[ dim ] );
    row:= mat1[ Random( [ 1 .. dim-1 ] ) ];
    if not IsLockedRepresentationVector( row ) then
      Unbind( row[ Random( [ 1 .. dim ] ) ] );
    fi;
    RunTest( AdditionTest, mat1, mat2 );
    Unbind( mat2[ Random( [ 1 .. dim ] ) ] );
    RunTest( ZeroTest, mat2 );
    RunTest( AdditiveInverseTest, mat1 );
    RunTest( AdditiveInverseTest, mat2 );
    RunTest( TransposedMatTest, mat2 );
    RunTest( AdditionTest, mat1, mat2 );
    Unbind( mat1[ Random( [ 1 .. dim ] ) ] );
    RunTest( AdditionTest, mat1, mat2 );

  od;
end;;

#############################################################################
##
#F  TestOfMultiplicativeListArithmetic( <R>, <dim> )
##
##  For a ring or list of ring elements <R> (such that `Random( <R> )'
##  returns an element in <R> and such that not all elements in <R> are
##  zero),
##  `TestOfMultiplicativeListArithmetic' performs the following tests of
##  multiplicative arithmetic operations.
##  \beginlist
##  \item{1.}
##      If the elements of <R> are in `IsMultiplicativeGeneralizedRowVector'
##      then it is checked whether `One', `Inverse', and `\*'
##      obey the definitions.
##  \item{2.}
##      If the elements of <R> are in `IsMultiplicativeGeneralizedRowVector'
##      then it is checked whether the product of elements in <R> and
##      (non-dense) plain lists of integers obeys the definitions.
##      (Note that contrary to the additive case, we need not chack the
##      special case of a multiplication with an empty list.)
##  \item{3.}
##      Check `One' and `Inverse' for nested plain lists of elements
##      in <R>, and `\*' for elements in <R> and nested plain lists of
##      elements in <R>.
##  \endlist
##
TestOfMultiplicativeListArithmetic := function( R, dim )
  local r, i, intlist, j, vec1, vec2, mat1, mat2, row;

  r:= Random( R );
  if IsMultiplicativeGeneralizedRowVector( r ) then

    # tests of kind 1.
    for i in [ 1 .. ARITH_LST_REPS ] do
      RunTest( OneTest, Random( R ) );
      RunTest( InverseTest, Random( R ) );
      RunTest( MultiplicationTest, Random( R ), Random( R ) );
    od;

    # tests of kind 2.
    for i in [ 1 .. ARITH_LST_REPS ] do
      r:= Random( R );
      intlist:= List( [ 1 .. Length( r ) + Random( [ -1 .. 1 ] ) ],
                      x -> Random( Integers ) );
      for j in [ 1 .. Int( Length( r ) / 3 ) ] do
        Unbind( intlist[ Random( [ 1 .. Length( intlist ) ] ) ] );
      od;
      RunTest( MultiplicationTest, r, intlist );
      RunTest( MultiplicationTest, intlist, r );
    od;

  fi;

  # tests of kind 3.
  for i in [ 1 .. ARITH_LST_REPS ] do

    vec1:= List( [ 1 .. dim ], x -> Random( R ) );
    vec2:= List( [ 1 .. dim ], x -> Random( R ) );

    RunTest( OneTest, vec1 );
    RunTest( InverseTest, vec1 );
    RunTest( MultiplicationTest, vec1, Random( R ) );
    RunTest( MultiplicationTest, Random( R ), vec2 );
    RunTest( MultiplicationTest, vec1, vec2 );
    Unbind( vec1[ dim ] );
    RunTest( MultiplicationTest, vec1, vec2 );
    Unbind( vec2[ Random( [ 1 .. dim ] ) ] );
    RunTest( OneTest, vec2 );
    RunTest( InverseTest, vec1 );
    RunTest( InverseTest, vec2 );
    RunTest( MultiplicationTest, vec1, vec2 );
    Unbind( vec1[ Random( [ 1 .. dim ] ) ] );
    RunTest( MultiplicationTest, vec1, vec2 );

    mat1:= RandomSquareArray( dim, R );
    mat2:= RandomSquareArray( dim, R );

    RunTest( OneTest, mat1 );
    RunTest( InverseTest, mat1 );
    RunTest( MultiplicationTest, mat1, Random( R ) );
    RunTest( MultiplicationTest, Random( R ), mat2 );
    RunTest( MultiplicationTest, vec1, mat2 );
    RunTest( MultiplicationTest, mat1, vec2 );
    RunTest( MultiplicationTest, mat1, mat2 );
    Unbind( mat1[ dim ] );
    row:= mat1[ Random( [ 1 .. dim-1 ] ) ];
    if not IsLockedRepresentationVector( row ) then
      Unbind( row[ Random( [ 1 .. dim ] ) ] );
    fi;
    RunTest( MultiplicationTest, vec1, mat2 );
    RunTest( MultiplicationTest, mat1, vec2 );
    RunTest( MultiplicationTest, mat1, mat2 );
    Unbind( mat2[ Random( [ 1 .. dim ] ) ] );
    RunTest( OneTest, mat2 );
    RunTest( InverseTest, mat1 );
    RunTest( InverseTest, mat2 );
    RunTest( MultiplicationTest, mat1, mat2 );
    Unbind( mat1[ Random( [ 1 .. dim ] ) ] );
    RunTest( MultiplicationTest, mat1, mat2 );

  od;
end;;

#############################################################################
##
#F  TestOfListArithmetic( <R>, <dimlist> )
##
TestOfListArithmetic := function( R, dimlist )
  local n, len, bools, i;

  len:= 100;
  bools:= [ true, false ];

  for n in dimlist do
    TestOfAdditiveListArithmetic( R, n );
    TestOfMultiplicativeListArithmetic( R, n );
    R:= List( [ 1 .. len ], x -> Random( R ) );
    if IsMutable( R[1] ) and not ForAll( R, IsZero ) then
      for i in [ 1 .. len ] do
        if Random( bools ) then
          R[i]:= Immutable( R[i] );
        fi;
      od;
      TestOfAdditiveListArithmetic( R, n );
      TestOfMultiplicativeListArithmetic( R, n );
    fi;
  od;
end;;

#############################################################################
##
#E
