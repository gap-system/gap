############################################################################
##
#W gauss.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: gauss.gi,v 1.1 2010/07/26 05:18:44 gap Exp $
##
Revision.("isopcp/gap/solv/gauss_gi"):=
  "@(#)$Id: gauss.gi,v 1.1 2010/07/26 05:18:44 gap Exp $";

############################################################################
##
#F SolveOverField( <mat>, <rhs>, <prime> )
##
## IMPROVEMENT: DON'T SEEK FOR THE PIVOT IN THE WHOLE FIRST ROW 
## - use special structure of the matrix instead: <mat> reduces
##   modulo <prime> to block upper-diagonal matrix
## - the block diagonal form has more advantages which may give 
##   an O(n^3) behavior!
##
############################################################################
SolveOverField := function( A, b, prime )
  local n,m,		# dimension of the matrix <A>
	row,col,	# row and column of a matrix 
	Invert,		# function for inversion modulo <prime> 
        inv,mult,	# integers
	vec,		# a vector
	Rows,Cols,	# corner entries 
	ORows,OCols,	# old corner entries
	CRows,pCRows,	# corner entries
	spec,		# special solution
	homs,		# homogeneous solutions
	i,j,k;		# loop variables
  
  # initialization 
  m := Length( A );
  n := Length( A[1] );

  # rows and columns of the corner entries
  Rows := []; CRows := [ 1 .. m ];
  Cols := [];
  
  # inverts an integer modulo <prime>
  Invert :=  a -> GcdRepresentation( a, prime )[1];

  for k in [ 1 .. n ] do 
    row := fail;
    for j in [ 1 .. Length( CRows ) ] do
      A[CRows[j]][k] := A[CRows[j]][k] mod prime;
      if A[CRows[j]][k] <> 0 then 
        row := Remove( CRows, j ); pCRows := j;
        break;
      fi;
    od;

    if row <> fail then 
      Add( Rows, row );
      Add( Cols, k );

      # normalize the <row>-th row
      A[row][k] := A[row][k] mod prime;
      if A[row][k] <> 1 then 
        inv := Invert( A[row][k] );
        A[row][k] := 1;
        for j in [ k+1 .. n ] do 
          A[row][j] := ( inv * A[row][j] ) mod prime;
        od;
        b[row] := ( inv * b[row] ) mod prime;
      fi;
  
      # reduce the remaining rows
      for i in CRows{ [ pCRows .. Length( CRows ) ] } do 
        A[i][k] := A[i][k] mod prime;
        if A[i][k] <> 0  then 
          for j in [ k+1 .. n ] do 
            A[i][j] := ( A[i][j] - A[i][k] * A[row][j] ) mod prime;
          od;
          b[i] := ( b[i] - A[i][k] * b[row] ) mod prime;
          A[i][k] := 0;
        else  
          b[i] := b[i] mod prime; 
        fi;
      od;
    fi;
  od;

  # check if the right-hand-side vanishes
  if ForAny( CRows, i -> b[i] mod prime <> 0 ) then return( fail ); fi;

  # backwards elimination
  ORows := []; OCols := [];
  while IsBound( Rows[1] ) do
    row := Remove( Rows, Length( Rows ) );
    col := Remove( Cols, Length( Cols ) ); 
    Add( ORows, row );
     
    for i in Rows do
      A[i][col] := A[i][col] mod prime;
      if A[i][col] <> 0 then
        for j in Difference( [ col+1 .. n ], OCols ) do
          A[i][j] := ( A[i][j] - A[i][col] * A[row][j] ) mod prime;
        od;
        b[i] := ( b[i] - A[i][col] * b[row] ) mod prime;
        A[i][col] := 0;
      fi;
    od;
    Add( OCols, col );
  od;

  # read off the special solution the equation
  spec := ListWithIdenticalEntries( n, 0 );
  for i in [ 1 .. Length( OCols ) ] do
    spec[OCols[i]] := b[ORows[i]];
  od;

  # read off the homogeneous solutions
  homs := [];
  for i in [ 1 .. n ] do
    if not i in OCols then 
     vec := ListWithIdenticalEntries( n, 0 );
     vec{OCols} := - A{ORows}[i] mod prime;
     vec[i] := 1;
     Add( homs, vec );
    fi;
  od;

  return( rec( special := spec, homogeneous := homs ));
  end;
