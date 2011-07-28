############################################################################
##
#W echelon.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: echelon.gi,v 1.1 2010/07/26 05:18:44 gap Exp $
##
Revision.("isopcp/gap/solv/echelon_gi"):=
  "@(#)$Id: echelon.gi,v 1.1 2010/07/26 05:18:44 gap Exp $";


############################################################################
##
#F EchelonizeHomcycBlock( <mat>, <rhs>, <prpw> )
##
EchelonizeHomcycBlock := function( A, b, prime, prpw, S )
  local n,m,		# dimension of the matrix <A>
	gcd,rep,lcm,	# gcd and its representation, least common multiple
	pos,		# position in a list
	row,col,ell,	# current row and column 
	fac, mult,inv,	# some integers
	Rows,Cols,	# the rows and columns already considered
	CRows,pCRows,	# rows to consider
	ORows,OCols,	# the rows and columns already considered
	Invert,		# inverts a positive integer modulo <prpw> if possible
	ev,		# exponent vector
	i,j,k;		# loop variables

  # initialization
  m := Length( A );
  n := Length( A[1] );

  Invert := a -> GcdRepresentation( a, prpw )[1];

  CRows := [ 1 .. m ];
  Rows := [];;
  Cols := [];;

  for k in [ S .. n ] do
    # determine first <row> with non-trivial <A[row][k]>
    row := fail;
    for j in [ 1 .. Length( CRows ) ] do 
      A[CRows[j]][k] := A[CRows[j]][k] mod prpw;
      if A[CRows[j]][k] <> 0 then
        row := Remove( CRows, j ); pCRows := j;
        break; 
      fi;
    od;

    if row <> fail then 
      Add( Rows, row );
      Add( Cols, k ); 

      if not IsInt( A[row][k] / prime ) then 
        # this row is invertible modulo <prpw>

        # normalize this row
        if A[row][k] <> 1 then 
          inv := Invert( A[row][k] );
          A[row][k] := 1;;
          for j in [ 1 .. S-1 ] do 
            A[row][j] := ( A[row][j] * inv ) mod prpw;
          od;
          for j in [ k+1 .. n ] do  # avoid Concatenation
            A[row][j] := ( A[row][j] * inv ) mod prpw;
          od;
          b[row] := ( b[row] * inv ) mod prpw;
        fi;
        
        # reduce the remaining rows
#       for i in Difference( [ row+1 .. m ], Rows ) do 
        for i in Difference( CRows{[pCRows..Length(CRows)]}, Rows ) do 
          A[i][k] := A[i][k] mod prpw;
          if A[i][k] <> 0 then 
            for j in [ 1 .. S-1 ] do 
              A[i][j] := ( A[i][j] - A[i][k] * A[row][j] ) mod prpw;
            od;
            for j in [ k+1 .. n ] do
              A[i][j] := ( A[i][j] - A[i][k] * A[row][j] ) mod prpw;
            od;
            b[i] := ( b[i] - A[i][k] * b[row] ) mod prpw;
            A[i][k] := 0;;
          else
            b[i] := b[i] mod prpw;
          fi;
        od;
      else
        # use GcdRepresentation and integral multiples (Euclidean algorithm)
#       for i in Difference( [ row+1 .. m ], Rows ) do
        for i in Difference( CRows{[pCRows..Length(CRows)]}, Rows ) do
          A[i][k] := A[i][k] mod prpw;
          if A[i][k] <> 0 then 
            if not IsInt( A[i][k] / prime ) and A[i][k] <> 1 then 
              # the <i>-th row is invertible 

              mult := Invert( A[i][k] );
              A[i][k] := 1;
              for j in [ 1 .. S-1 ] do
                A[i][j] := ( mult * A[i][j] ) mod prpw;
              od;
              for j in [ k+1 .. n ] do
                A[i][j] := ( mult * A[i][j] ) mod prpw;
              od;
              b[i] := ( mult * b[i] ) mod prpw;
            fi;

            mult := A[i][k] / A[row][k];;
            if IsInt( mult ) then 
              A[i][k] := 0;
              for j in [ 1 .. S-1 ] do
                A[i][j] := ( A[i][j] - mult * A[row][j] ) mod prpw;
              od;
              for j in [ k+1 .. n ] do
                A[i][j] := ( A[i][j] - mult * A[row][j] ) mod prpw;
              od;
              b[i] := ( b[i] - mult * b[row] ) mod prpw;
            elif NumeratorRat( mult ) = 1 then 
              mult := DenominatorRat( mult );
              A[row][k] := 0;;
              for j in [ 1 .. S-1 ] do 
                A[row][j] := ( A[row][j] - mult * A[i][j] ) mod prpw;
              od;
              for j in [ k+1 .. n ] do 
                A[row][j] := ( A[row][j] - mult * A[i][j] ) mod prpw;
              od;
              b[row] := ( b[row] - mult * b[i] ) mod prpw;

              # replace <row> by <i> in the list <Rows>
              Rows[ Length(Rows) ] := i; 
              pos := Position( CRows, i );
              CRows[pos] := row;
              pCRows := pos;
              row := i;
            else
              rep := Gcdex( A[row][k], A[i][k] );
              lcm := Lcm( A[row][k], A[i][k] );
              for j in [ 1 .. S-1 ] do 
                # change simultaneously!
                A{[i,row]}[j] := [  lcm / A[row][k] * A[row][j] 
                                  - lcm / A[i][k] * A[i][j] , 
                                    rep.coeff1 * A[row][j] 
                                  + rep.coeff2 * A[i][j] ];
              od;
              for j in [ k+1 .. n ] do 
                # change simultaneously!
                A{[i,row]}[j] := [  lcm / A[row][k] * A[row][j] 
                                  - lcm / A[i][k] * A[i][j], 
                                    rep.coeff1 * A[row][j] 
                                  + rep.coeff2 * A[i][j] ];
              od;

              # change simultaneously!
              b{[i,row]} := [ lcm / A[row][k] * b[row] - lcm / A[i][k] * b[i],
                              rep.coeff1 * b[row] + rep.coeff2 * b[i] ];
 
              A[row][k] := rep.gcd;
              A[i][k] := 0;
            fi;
          fi;
        od;
      fi;
    fi;
  od;

  # backwards elimination (for corner entries 1)
  ORows := []; OCols := [];
  while IsBound( Rows[1] ) do 
    row := Remove( Rows, Length( Rows ) );
    col := Remove( Cols, Length( Cols ) );
    Add( ORows, row );
    Add( OCols, col );
 
    if A[row][col] mod prpw = 1 then
      for i in Rows do 
        mult := A[i][col] mod prpw;
        if mult <> 0 then
          A[i][col] := 0;;
          for j in Concatenation( [ 1 .. S-1 ], [ col+1 .. n ] ) do 
            A[i][j] := ( A[i][j] - mult * A[row][j] ) mod prpw;
          od;
          b[i] := ( b[i] - mult * b[row] ) mod prpw;
        fi;
      od;
    fi;
  od;

  return( rec( matrix := A, 
               rhs    := b, 
               rows   := ORows, 
               cols   := OCols ) );
  end;
