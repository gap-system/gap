############################################################################
##
#W consist.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: cons.gi,v 1.1 2010/07/26 05:18:46 gap Exp $
##
Revision.("isopcp/gap/coll/consist_gi"):=
  "@(#)$Id: cons.gi,v 1.1 2010/07/26 05:18:46 gap Exp $";


############################################################################
##
#F  ConsistencyChecks ( <CRRecord> )
##
## This function checks the local confluence (or consistency) of a weighted 
## nilpotent presentation. It implements the check from Nickel: "Computing 
## nilpotent quotients of finitely presented groups"
##
##	k ( j i ) = ( k j ) i,	          i < j < k, w_i=1, w_i+w_j+w_k <= c
##          j^m i = j^(m-1) ( j i ),      i < j, j in I,   w_j+w_i <= c
##          j i^m = ( j i ) i^(m-1),      i < j, i in I,   w_j+w_i <= c
##          i i^m = i^m i,                i in I, 2 w_i <= c
##            j   = ( j i^-1 ) i,         i < j, i not in I, w_i+w_j <= c
## 
ConsistencyChecks :=  function( A )
  local T,		# conditions for the tails
   	n, 		# number of generators of coll
	k,j,i,	 	# loop variables 
	ev1, ev2,	# exponent vectors (rhs and lhs)
	ev,		# exponent vector of an element of <Center(N)>
	tail,		# tail vector 
	c,		# nilpotency class
  	w,		# loop variable (object representation) 
	I;		# set of indices of generators with power relation

  # number of generators of <Q> 
  n := A.n;

  # those generators of <Q> with finite relative order
  I := Filtered( [1..n], x -> IsBound( A.ftlQ![ PC_EXPONENTS ][x] ) );

  T := [];

  # k (j i) = (k j) i
  for k in [n,n-1..1] do
    for j in [k-1,k-2..1] do
      for i in [j-1,j-2..1] do

        repeat 
          ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
                   ShallowCopy( A.tail_zero) ];
        until CollectMyWordOrFail( A, ev1, [j,1,i,1] ) <> fail;
        tail := ev1[2];

        w := MyObjByExponents( A, ev1[1] );
        repeat 
          ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
                   ShallowCopy( A.tail_zero) ];
          ev1[1][k] := 1;
        until CollectMyWordOrFail( A, ev1, w ) <> fail;
        ev1[2] := ev1[2] + tail;

        repeat 
          ev2 := [ ListWithIdenticalEntries( A.n+A.m, 0 ), 
	           ShallowCopy( A.tail_zero) ];
        until CollectMyWordOrFail( A, ev2, [k,1,j,1,i,1] ) <> fail;
 
        if ev1[1]{[1..A.n]} <> ev2[1]{[1..A.n]} then 
          Error("Input-presentation of <Q> wasn't confluent");
        fi;

        # determine the element in Z(N) (rhs of the system of equations)
        repeat 
          repeat
            ev := ListWithIdenticalEntries( A.m, 0 );
          until CollectWordOrFail( A.ftlN, ev, Obj_Inverse(
                     ObjByExponents(A.ftlN, ev1[1]{[A.n+1..A.n+A.m]}))) <> fail;
        until CollectWordOrFail( A.ftlN, ev, 
                     ObjByExponents(A.ftlN, ev2[1]{[A.n+1..A.n+A.m]}) ) <> fail;
   
        if not PcpElementByExponents( A.ftlN, ev ) in Center( A.module ) then
          Error("element not contained in the center of the module");
        fi;
        
        Add( T, [ ev, ev1[2] - ev2[2] ] );
      od;
    od;
  od;
  
  # j^m i = j^(m-1) (j i)
  for j in Reversed( I ) do
    for i in [1..j-1] do
      repeat 
        ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
		 ShallowCopy( A.tail_zero) ];
      until CollectMyWordOrFail( A, ev1, [j, A.ftlQ![ PC_EXPONENTS ][j]-1, 
                                          j, 1, i,1] ) <> fail;
          
      repeat
        ev2 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
                 ShallowCopy( A.tail_zero) ];
      until CollectMyWordOrFail( A, ev2, [j,1,i,1] ) <> fail;
      tail := ShallowCopy( ev2[2] );

      w := MyObjByExponents( A, ev2[1] );
      repeat 
        ev2 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
                 ShallowCopy( A.tail_zero ) ];
        ev2[1][j] := A.ftlQ![ PC_EXPONENTS ][j] - 1;
      until CollectMyWordOrFail( A, ev2, w ) <> fail;
      ev2[2] := ev2[2] + tail;

      if ev1[1]{[1..A.n]} <> ev2[1]{[1..A.n]} then 
        Error("Input-presentation of <Q> wasn't confluent");
      fi;

      # determine the element in Z(N) (rhs of the system of equations)
      repeat
        repeat
          ev := ListWithIdenticalEntries( A.m, 0 );
        until CollectWordOrFail( A.ftlN, ev, Obj_Inverse(
                   ObjByExponents(A.ftlN, ev1[1]{[A.n+1..A.n+A.m]}))) <> fail;
      until CollectWordOrFail( A.ftlN, ev, 
                 ObjByExponents(A.ftlN, ev2[1]{[A.n+1..A.n+A.m]})) <> fail;
   
      if not PcpElementByExponents( A.ftlN, ev ) in Center( A.module ) then
        Error("element not contained in the center of the module");
      fi;
        
      Add( T, [ ev, ev1[2] - ev2[2] ] );
    od;
  od;
  
  # j i^m = (j i) i^(m-1)
  for i in I do 
    for j in [i+1..n] do
      if IsBound( A.rels[i][i] ) then 
        repeat 
          ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0), 
                   ShallowCopy( A.tail_zero ) ]; 
          ev1[1][j] := 1;
        until CollectMyWordOrFail( A, ev1, A.rels[i][i] ) <> fail;
      else 
        ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0), 
                 ShallowCopy( A.tail_zero ) ]; 
        ev1[1][j] := 1;
      fi;
      
      repeat
        ev2 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
                 ShallowCopy( A.tail_zero ) ];
        ev2[1][j] := 1;
      until CollectMyWordOrFail( A, ev2, [i,1,i,A.ftlQ![ PC_EXPONENTS ][i]-1] )
            <> fail;

      if ev1[1]{[1..A.n]} <> ev2[1]{[1..A.n]} then 
        Error("Input-presentation of <Q> wasn't confluent");
      fi;

      # determine the element in Z(N) (rhs of the system of equations)
      repeat
        repeat
          ev := ListWithIdenticalEntries( A.m, 0 );
        until CollectWordOrFail( A.ftlN, ev, Obj_Inverse(
                     ObjByExponents(A.ftlN, ev1[1]{[A.n+1..A.n+A.m]}))) <> fail;
      until CollectWordOrFail( A.ftlN, ev, 
                   ObjByExponents(A.ftlN, ev2[1]{[A.n+1..A.n+A.m]})) <> fail;
   
      if not PcpElementByExponents( A.ftlN, ev ) in Center( A.module ) then
        Error("element not contained in the center of the module");
      fi;
        
      Add( T, [ ev, ev1[2] - ev2[2] ] );
    od;
  od;
  
  # i^m i = i i^m
  for i in I do 
    repeat
      ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
               ShallowCopy( A.tail_zero ) ];
    until CollectMyWordOrFail( A, ev1, [ i, A.ftlQ![ PC_EXPONENTS ][i] + 1] ) 
          <> fail;
            
    repeat
      ev2 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
               ShallowCopy( A.tail_zero ) ];
      ev2[1][i] := 1;
    until CollectMyWordOrFail( A, ev2, A.rels[i][i] )<>fail;

    if ev1[1]{[1..A.n]} <> ev2[1]{[1..A.n]} then 
      Error("Input-presentation of <Q> wasn't confluent");
    fi;

    # determine the element in Z(N) (rhs of the system of equations)
    repeat
      repeat
        ev := ListWithIdenticalEntries( A.m, 0 );
      until CollectWordOrFail( A.ftlN, ev, Obj_Inverse(
                   ObjByExponents(A.ftlN, ev1[1]{[A.n+1..A.n+A.m]}))) <> fail;
    until CollectWordOrFail(A.ftlN, ev,
                 ObjByExponents(A.ftlN, ev2[1]{[A.n+1..A.n+A.m]})) <> fail;
   
    if not PcpElementByExponents( A.ftlN, ev ) in Center( A.module ) then
      Error("element not contained in the center of the module");
    fi;

    Add( T, [ ev, ev1[2] - ev2[2] ] );
  od;

  # j = (j -i) i 
  for i in Difference( [1..n], I ) do
    for j in [i+1..n] do
      repeat
        ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ),
                 ShallowCopy( A.tail_zero ) ];
      until CollectMyWordOrFail( A, ev1, [j,1,i,-1,i,1] ) <> fail;

      ev2 := ListWithIdenticalEntries( A.n, 0);
      ev2[j] := 1;
      if ev1[1]{[1..A.n]} <> ev2 then 
        Error("Input-presentation of <Q> wasn't confluent");
      fi;

      # determine the element in Z(N) (rhs of the system of equations)
      repeat
        ev := ListWithIdenticalEntries( A.m, 0 );
      until CollectWordOrFail( A.ftlN, ev, Obj_Inverse( 
                   ObjByExponents(A.ftlN, ev1[1]{[A.n+1..A.n+A.m]}))) <> fail;
   
      if not PcpElementByExponents( A.ftlN, ev ) in Center( A.module ) then
        Error("element not contained in the center of the module");
      fi;
        
      Add( T, [ ev, ev1[2] ] );  
    od;
  od;

  # i = -j (j i)
  for j in Difference( [1..n], I ) do
    for i in [1..j-1] do
      repeat
        ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ), 
                 ShallowCopy( A.tail_zero ) ];
      until CollectMyWordOrFail( A, ev1, [ j,1,i,1 ] ) <> fail;
      tail := ShallowCopy( ev1[2] );

      w := MyObjByExponents( A, ev1[1] );
      repeat
        ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ), 
                 ShallowCopy( A.tail_zero ) ];
        ev1[1][j] := -1;
      until CollectMyWordOrFail( A, ev1, w ) <> fail;
      ev1[2] := ev1[2] + tail;
          
      ev2 := ListWithIdenticalEntries( A.n, 0);
      ev2[i] := 1;
      if ev1[1]{[1..A.n]} <> ev2 then 
        Error("Input-presentation of <Q> wasn't confluent");
      fi;

      # determine the element in Z(N) (rhs of the system of equations)
      repeat
        ev := ListWithIdenticalEntries( A.m, 0 );
      until CollectWordOrFail( A.ftlN, ev, Obj_Inverse( 
                   ObjByExponents(A.ftlN, ev1[1]{[A.n+1..A.n+A.m]}))) <> fail;
   
      if not PcpElementByExponents( A.ftlN, ev ) in Center( A.module ) then
        Error("element not contained in the center of the module");
      fi;
        
      Add( T, [ ev, ev1[2] ] );  
        
      # -i = -j (j -i)
      if not i in I then 
        repeat
          ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ), 
                   ShallowCopy( A.tail_zero) ];
        until CollectMyWordOrFail( A, ev1, [ j, 1, i, -1 ] ) <> fail;
        tail := ShallowCopy( ev1[2] );

        w := MyObjByExponents( A, ev1[1] );
        repeat
          ev1 := [ ListWithIdenticalEntries( A.n+A.m, 0 ), 
                   ShallowCopy( A.tail_zero ) ];
          ev1[1][j] := -1;
        until CollectMyWordOrFail( A, ev1, w ) <> fail;
        ev1[2] := ev1[2] + tail;

        ev2 := ListWithIdenticalEntries( A.n, 0 );
        ev2[i] := -1;
        if ev1[1]{[1..A.n]} <> ev2 then 
          Error("Input-presentation of <Q> wasn't confluent");
        fi;

        # determine the element in Z(N) (rhs of the system of equations)
        repeat
          ev := ListWithIdenticalEntries( A.m, 0 );
        until CollectWordOrFail( A.ftlN, ev, Obj_Inverse( 
                     ObjByExponents(A.ftlN, ev1[1]{[A.n+1..A.n+A.m]}))) <> fail;
     
        if not PcpElementByExponents( A.ftlN, ev ) in Center( A.module ) then
          Error("element not contained in the center of the module");
        fi;
          
        Add( T, [ ev, ev1[2] ] );  
      fi;
    od;
  od;

  return(T);
  end;
