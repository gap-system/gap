############################################################################
##
#W homcyc.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: homcyc.gi,v 1.1 2010/07/26 05:18:45 gap Exp $
##
Revision.("isopcp/gap/solv/homcyc_gi"):=
  "@(#)$Id: homcyc.gi,v 1.1 2010/07/26 05:18:45 gap Exp $";

MSNF_RHS := function( Mat, rhs, prpw ); return( fail ); end;

############################################################################
##
#F SolutionPGroup_Homcyc( <Mat>, <rhs>, <mod> )
##
##  - use modular Smith normal form to solve the homocyclic system 
##
############################################################################
SolutionPGroup_Homcyc := function( Mat, rhs, modulus )
  local n,m,M,	# dimensions of <Mat>
	prpw,	# the prime power
	prime,	# the prime
	PEval,	# function for computing the <prime>-evaluation
	inv,	# function for inverting
	b, 	# modified right-hand-side <rhs>
	SNF,snf,# the modular Smith normal form
	diag,	# the diagonal of SNF.normal
	L,R,	# transformations so that LAR = SNF.normal
	K,	# the kernel
	y,	# a solution of Dy=Lb
	vec,	# a vector
	alpha,  # a <prime>-evaluation
	mult,	# some factor
	sol,	# the final solution record
	i,ell;	# loop variables

  # initializations
  n := Length( Mat[1] );;
  m := Length( modulus );;
  M := Minimum( n, m );;

  prpw := modulus[1];;
  prime := FactorsInt( prpw )[1];;
  if ForAny( [ 2 .. m ], x -> modulus[x] <> prpw ) then 
    Error("not a homocyclic system"); 
  fi;

  # the <p>-evaluation of <a>
  PEval := function( a )
    if IsPosInt( a ) then 
      return( Length( Filtered( FactorsInt( a ), x -> x = prime ) ) );
    else
      return( Length( Filtered( FactorsInt( -a ), x -> x = prime ) ) );
    fi;
  end;

  # inverts modulo <prpw>
  inv := a -> GcdRepresentation( a, prpw )[1];;

  # the modular Smith normal form algorithm 
  SNF := MSNF_RHS( Mat, ShallowCopy( rhs ), prpw );;
  b   := SNF.rhs;
  R   := SNF.coltrans;

  diag := List( [ 1 .. M ], x -> SNF.normal[x][x] mod prpw);
  ell  := First( [ 1 .. M ], x -> diag[x] = 0 );
  if ell = fail then ell := m; else ell := ell - 1;; fi;

  for i in [ ell+1 .. M ] do 
    if diag[i] = 0 and b[i] mod prpw <> 0 then return( fail ); fi;
  od;

  # the kernel
  K := [];

  # the solutions <y> of Dy = Lb.
  y := [];;
  for i in [ 1 .. n ] do
    if not IsBound( diag[i] ) then 
      Add( K, [ i, 1 ] );
    elif diag[i] = 0 then 
      Add( K, [ i, 1 ] );
    else
      alpha := PEval( diag[i] );
      if alpha <> 0 then  
        # diagonal entry contains some prime powers...
        mult := b[i] / prime ^ alpha;

        # the system Dy = Lb has no solution
        if not IsInt( mult ) then return( fail ); fi; 
 
        y[i] := GcdRepresentation( diag[i] / prime ^ alpha, 
                                   prpw / prime ^ alpha )[1] * mult;

        # kernel element from solving ax = c mod p^l...
        Add( K, [ i, prpw / prime ^ alpha ] );
      else
        # diagonal entry is invertible ( = 1 )! 
        if diag[i] = 1 then  
          y[i] := b[i];;
        else 
          Error("should not appear in <homcyc.gi>!");
          y[i] := GcdRepresentation( diag[i], prpw )[1] * b[i];
        fi;
      fi;
    fi;
  od;
  
  if ell = 0 then 
    sol := rec( special := 0 * [ 1 .. n ],
                homogeneous := [] );
  else
    sol := rec( special := ( R{[ 1 .. n ]}{[ 1 .. ell ]} * y ) mod prpw,
                homogeneous := [] );
  fi;
  for i in [ 1 .. Length( K ) ] do
    Add( sol.homogeneous, K[i][2] * R{[1..n]}[ K[i][1] ] mod prpw );
  od;

  return( sol );
  end;


############################################################################
##
#F MSNF_RHS( <Mat>, <rhs>, <prpw> )
##
## computes the modular Smith normal form and applies the row operations
## to <rhs> directly.
##
############################################################################
MSNF_RHS := function( A, b, prpw )
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
	vec,ell,
	rhs,
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
  B := IdentityMat( n, n );
  Mat := StructuralCopy( A );

  # permutation matrices
  Q := [];; P := [];;

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
    a := Mat[row][col] / prime ^ min;

    # normalize the <row>-th row
    ell := inv( a );;
    for j in Cols do
      Mat[row][j] := ( ell * Mat[row][j] ) mod prpw;;
    od;
    Mat[row][col] := prime ^ min;
    b[row] := ( ell * b[row] ) mod prpw;

    # reduce the remaining rows
    for i in Rows do
      ell := Mat[i][col] / prime ^ min;;
      for j in Cols do 
        Mat[i][j] := ( Mat[i][j] - ell * Mat[row][j] ) mod prpw;
      od;
      Mat[i][col] := 0;;
      b[i] := ( b[i] - ell * b[row] ) mod prpw;;
    od;

    # column operations
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
	       rhs := b{Q},
               colB := B, colP := IdentityMat( n, n ){[1..n]}{P},
               coltrans := B{[1..n]}{P} ));
  end;
