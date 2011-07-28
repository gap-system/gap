############################################################################
##
#W msnf.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: msnf.gi,v 1.1 2010/07/26 05:18:45 gap Exp $
##
Revision.("isopcp/gap/solv/msnf_gi"):=
  "@(#)$Id: msnf.gi,v 1.1 2010/07/26 05:18:45 gap Exp $";

############################################################################
##
#F ModularSNF( <Mat>, <prpw> )
##
############################################################################
ModularSNF := function( A, prpw )
  local n,m, 		# dimension of <A>
 	prime,		# the prime number
	Q,P,		# permutation matrices 
	C,B,		# the transformation matrices
	L,R,		# further transformations (redundant?!)
	PEval,		# a function for computing the <p>-evaluation
	inv,		# a function for inverting modulus <prpw>
	min,new,	# for finding a pivot with minimal <p>-evaluation
	a,		# the invertible part of the pivot element
	Mat, 		# the current matrix
	Rows,Cols,	# row and column entries
	row,col,	# position of the pivot
	TEST,	
	vec,ell,
	i,j,k;

  # initializations
  prime := FactorsInt( prpw )[1];
  n := Length( A[1] );
  m := Length( A );

  # the <p>-evaluation of <a>
  PEval := function( a )
    if IsPosInt( a ) then 
      return( Length( Filtered( FactorsInt( a ), x -> x = prime ) ) );
    else
      return( Length( Filtered( FactorsInt( -a ), x -> x = prime ) ) );
    fi;
  end;

  # inverts modulo <prpw>
  inv := a -> GcdRepresentation( a, prpw )[1];

  # further initializations
  C := IdentityMat( m, m );
  B := IdentityMat( n, n );
  Mat := StructuralCopy( A );

  # permutation matrices
  Q := [];;
  P := [];;

  Rows := [ 1 .. m ];;
  Cols := [ 1 .. n ];;
  k := 1;
  while IsBound( Rows[1] ) and IsBound( Cols[1] ) do

    # find pivot with minimal <p>-evaluation
    Mat[Rows[1]][Cols[1]] := Mat[Rows[1]][Cols[1]] mod prpw;
    if Mat[Rows[1]][Cols[1]] = 0 then 
      min := fail;
    else 
      min := PEval( Mat[Rows[1]][Cols[1]] );
    fi;
    i := 1;; j := 1;; 
    row := 1; col := 1;
    while IsBound( Rows[i] ) do
      if min = 0 and Mat[row][col] <> 0 then break; fi;
      while IsBound( Cols[j] ) do
        Mat[Rows[i]][Cols[j]] := Mat[Rows[i]][Cols[j]] mod prpw;
        if Mat[Rows[i]][Cols[j]] <> 0 then 
          new := PEval( Mat[Rows[i]][Cols[j]] );
          if min = fail or min > new then 
            min := new; row := i;; col := j;;
            if min = 0 then break; fi;
          fi;
        fi;
        j := j + 1;
      od;
      i := i + 1; 
      j := 1;;
    od;
    row := Remove( Rows, row );
    col := Remove( Cols, col );

    Q[k] := row; P[k] := col;  

    # the remaining entries vanish modulo <prpw>
    if Mat[row][col] = 0 then break; fi;

    # determine the invertible part of the pivot element
#   a := Product( Filtered( FactorsInt( Mat[row][col] ), x -> x <> prime ) );
    a := Mat[row][col] / prime ^ min;
    
    # row operations
#   L:=IdentityMat( m, m );
#   L{[1..m]}[row] := - inv(a) / prime ^ min * Mat{[1..m]}[col];
#   L[row][row] := inv( a );
#   C := L * C;
#   Mat := ( L * Mat ) mod prpw;

    # Write L = D + N with D = diag( 1 .. 1, inv(a), 1 .. 1 ) and 
    # N being almost NullMat( m, m ). Then L * C = D * C + N * C, i.e.
    # [ 0..0, vec, 0..0 ] * C = [ C[row][1] * vec .. C[row][n] * vec ]
    ell := inv( a );;
#   vec := - inv(a) / prime ^ min * Mat{[1..m]}[col];;
    vec := - ell / prime ^ min * Mat{[1..m]}[col];;
    for i in Rows do 
      if vec[i] <> 0 then AddRowVector( C[i], C[row], vec[i] ); fi;
    od;
#   C[row] := inv( a ) * C[row];                  # i.e. D * C
    C[row] := ell * C[row];                  # i.e. D * C

    # normalize the <row>-th row
    for j in Cols do
      Mat[row][j] := ( ell * Mat[row][j] ) mod prpw;;
    od;
    Mat[row][col] := prime ^ min;

    # reduce the remaining rows
    for i in Rows do
      ell := Mat[i][col] / prime ^ min;;
      for j in Cols do 
        Mat[i][j] := ( Mat[i][j] - ell * Mat[row][j] ) mod prpw;
      od;
      Mat[i][col] := 0;;
    od;
  
    # column operations
#   R := IdentityMat( n, n );
#   R[col] := - 1 / prime ^ min * Mat[row];
#   R[col][col] := 1;
#   B := B * R;
#   Mat := ( Mat * R ) mod prpw;

    vec := - 1 / prime ^ min * Mat[row];
    for i in Cols do 
      if vec[i] <> 0 then 
        B{[1..n]}[i] := B{[1..n]}[i] + vec[i] * B{[1..n]}[col];
      fi;
    od;

    Mat[row]{Cols} := 0 * Cols; 
 
    k:=k+1;
  od;

  Append( Q, Filtered( [ 1 .. m ], x -> not x in Q ) );
  Append( P, Filtered( [ 1 .. n ], x -> not x in P ) );

  return( rec( normal := Mat{Q}{P},
               rowC := C, rowQ := IdentityMat( m, m ){Q},
               colB := B, colP := IdentityMat( n, n ){[1..n]}{P},
               rowtrans := C{Q}, coltrans := B{[1..n]}{P} ));
  end;
