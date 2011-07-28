############################################################################
##
#W hensel.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: hensel.gi,v 1.1 2010/07/26 05:18:45 gap Exp $
##
Revision.("isopcp/gap/solv/hensel_gi"):=
  "@(#)$Id: hensel.gi,v 1.1 2010/07/26 05:18:45 gap Exp $";

############################################################################
##
#F LiftSolutionByHensel( <mat>, <rhs>, <sols>, <prpw> )
##
LiftSolutionByHensel := function( Sys, ell )
  local n,m,		# dimension of the matrix <A>
	Rows,Cols,R,C,	# row and column positions of the corner entries
	row,col,	# position of the corner entry
	prime,		# THE prime ;)
	prpw, prpwo,	# prime powers
        modulus, 	# the current modulus (for testing only)
	A, b, 		# the modified linear system
	pos,Pos,	# position(s)
 	MySols, 	# the current solutions
	vec,		# a vector for lifting
	sol,		# a single solution
	inv,		# an inverse
	LMS,		# current length of <MySols>
	i,j,k,l;  	# loop variables

  # initialization 
  A := StructuralCopy( Sys.matrix );      #... in row echelon form
  b := StructuralCopy( Sys.rhs );         # as we modify the matrix
  Rows := Sys.rows;
  Cols := Sys.cols;

  # dimension of <A>
  n := Length( A[1] );
  m := Length( A );
  prime := Sys.prime;
  prpw  := prime ^ ell;;
  prpwo := prime ^ ( ell - 1 );

# Print("# Lifting solution to ",prime," ^ ", ell, ".\n");

  # the current solutions
  MySols := Concatenation( [ Sys.solutions.special ],
                             Sys.solutions.homogeneous );

  # first solution to lift
  pos :=  First( [ 1 .. n ], x -> prime ^ ell <= Sys.modulus[x] );
# modulus := List( Sys.modulus, x -> Minimum( x, prpwo ) );

  # determine those solutions which need to be lifted
  R := Difference( [ 1 .. m ], Rows );
  C := Difference( [ pos .. n ], Cols );
  for i in [ 1 .. Length( Cols ) ] do 
    if A[Rows[i]][Cols[i]] mod prime = 0 then 
      Add( R, Rows[i] ); 
      Add( C, Cols[i] );
    fi;
  od;

  # start lifting those which do not lift uniquely
  for i in [ 1 .. Length( R ) ] do
    A[R[i]][C[i]] := A[R[i]][C[i]] mod prpw;;
    j := First( [ 1 .. pos-1 ], x -> A[R[i]][x] <> 0 );
    if A[R[i]][C[i]] <> 0 or j <> fail then 

      Pos := Concatenation( [ 1 ..  pos - 1 ], [ C[i] .. n ] );;
      vec := List( MySols, x -> x{Pos} * A[R[i]]{Pos} );
if vec <> A[R[i]] * TransposedMat( MySols ) then Error("hallo welt"); fi;
      vec[1] := vec[1] - b[R[i]];
      vec := ( 1 / prpwo * vec ) mod prime;

      LMS := Length( vec );
      k := First( [ LMS, LMS - 1 .. 1 ], x -> vec[x] <> 0 );

      if k = fail then                                 # this solution lifts
        vec := ListWithIdenticalEntries( n, 0 ); 
        vec[C[i]] := prpwo;
        Add( MySols, vec );
      elif k = 1 then 
        # there is not free variable to restrict (and vec[1] <> 0 holds) 
        return( fail );
      else
        if vec[k] <> 1 then 
          inv := GcdRepresentation( vec[k], prime )[1];
          vec{[1..k]} := ( - inv * vec{[1..k]} ) mod prime;
        else 
          vec{[1..k]} := ( - vec{[1..k]} ) mod prime;
        fi;

        Remove( vec, k );
        sol := Remove( MySols, k );
        for l in [ 1 .. k-1 ] do 
          AddRowVector( MySols[l], sol, vec[l] );
        od;

        # lift this solution
        vec := ListWithIdenticalEntries( n, 0 ); 
        vec[C[i]] := prpwo;
        Add( MySols, vec );
      fi;
    else   # if A[R[i]][C[i]] <> 0 or j <> fail then 
      # row vanishes modulo <prime ^ ell>

      if not IsZero( b[R[i]] mod prpw ) then return( fail ); fi;

      vec := ListWithIdenticalEntries( n, 0 );
      vec[C[i]] := prpwo;
      Add( MySols, vec );
    fi;
#   modulus[C[i]] := prpw;
  od;

  # lift the remaining solutions uniquely
  for i in [ 1 .. Length( Cols ) ] do
    if not Cols[i] in C then 
      vec := ( MySols * A[Rows[i]] );
      vec[1] := ( vec[1] - b[Rows[i]] );
      vec := ( - 1 / prpwo * vec ) mod prime;
      vec := prpwo * vec;

      MySols{[1..Length(MySols)]}[Cols[i]] :=
      MySols{[1..Length(MySols)]}[Cols[i]] + vec;
    fi;
  od;

  Sys.solutions := rec( special := MySols[1],
                        homogeneous := MySols{[ 2 .. Length( MySols ) ]} );
  return( Sys.solutions );
  end;
