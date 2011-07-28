#############################################################################
##
#M  IsConfluent . . . . . . . . . . . . . . . . . . . polycyclic presentation
##
##  This method checks the confluence (or consistency) of a polycyclic
##  presentation.  It implements the checks from Sims: Computation
##  with Finitely Presented Groups, p. 424:
##
##		k (j i) = (k j) i               k > j > i
##		j^m i   = j^(m-1) (j i)		j > i,        j in I
##		j * i^m = (j i) * i^(m-1)	j > i,        i in I
##		i^m i   = i i^m			              i in I
##		      j = (j -i) i 		j > i,    i not in I
##		      i = -j (j i)		j > i,    j not in I
##		     -i = -j (j -i)             j > i,  i,j not in I
##

############################################################################
##
## includes a decomposition into free abelian and p-Sylow sections
##
############################################################################
GunnarsIsConfluent := function( coll, deco )
    local   n,  k,  j,  i,  ev1,  w,  ev2, s, A, l, exps;
   
    n := coll![ PC_NUMBER_OF_GENERATORS ];

    # k (j i) = (k j) i
    for k in [n,n-1..1] do
        for j in [k-1,k-2..1] do
            for i in [j-1,j-2..1] do
#               InfoConsistency( "checking ", k, " ", j, " ", i, "\n" );
                ev1 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev1, [j,1,i,1] );
                w := ObjByExponents( coll, ev1 );
                ev1 := ExponentsByObj( coll, [k,1] );
                CollectWordOrFail( coll, ev1, w );
                
                ev2 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev2, [k,1,j,1,i,1] );
                
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", k, " ", j, " ", i, "\n" );
                    return false;
                fi;
            od;
        od;
    od;
    
    # j^m i = j^(m-1) (j i)
    for j in [n,n-1..1] do
        for i in [j-1,j-2..1] do
            if IsBound(coll![ PC_EXPONENTS ][j]) then
#               InfoConsistency( "checking ", j, "^m ", i, "\n" );
                ev1 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev1, [j, coll![ PC_EXPONENTS ][j]-1, 
                                               j, 1, i,1] );
                
                ev2 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev2, [j,1,i,1] );
                w := ObjByExponents( coll, ev2 );
                ev2 := ExponentsByObj( coll, [j,coll![ PC_EXPONENTS ][j]-1] );
                CollectWordOrFail( coll, ev2, w );

                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, "^m ", i, "\n" );
                    return false;
                fi;
            fi;
        od;
    od;
    
    # j * i^m = (j i) * i^(m-1)
    for i in [n,n-1..1] do
        if IsBound(coll![ PC_EXPONENTS ][i]) then
            for j in [n,n-1..i+1] do
#               InfoConsistency( "checking ", j, " ", i, "^m\n" );
                ev1 := ExponentsByObj( coll, [j,1] );
                if IsBound( coll![ PC_POWERS ][i] ) then
                    CollectWordOrFail( coll, ev1, coll![ PC_POWERS ][i] );
                fi;
                
                ev2 := ListWithIdenticalEntries( n, 0 );
                CollectWordOrFail( coll, ev2,
                        [ j,1,i,coll![ PC_EXPONENTS ][i] ] );
                
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, " ", i, "^m\n" );
                    return false;
                fi;
            od;
        fi;
    od;
    
    # i^m i = i i^m
    for i in [n,n-1..1] do
        if IsBound( coll![ PC_EXPONENTS ][i] ) then
            ev1 := ListWithIdenticalEntries( n, 0 );
            CollectWordOrFail( coll, ev1, [ i,coll![ PC_EXPONENTS ][i]+1 ] );
            
            ev2 := ExponentsByObj( coll, [i,1] );
            if IsBound( coll![ PC_POWERS ][i] ) then
                CollectWordOrFail( coll, ev2, coll![ PC_POWERS ][i] );
            fi;
            
            if ev1 <> ev2 then
                Print( "Inconsistency at ", i, "^(m+1)\n" );
                return false;
            fi;
        fi;
    od;


# Gunnar's method

   exps := [];
   for i in [ 1 .. Length( deco ) ] do
     if IsBound( coll![ PC_EXPONENTS ][ deco[i][1]] ) then
       exps[i] := FactorsInt( coll![ PC_EXPONENTS ][ deco[i][1] ] )[1];
     else
       exps[i] := 0;;
     fi;
   od;
    
   for k in Filtered( [ 1 .. Length( deco ) ], x -> exps[x] = 0 ) do
     for i in deco[k] do
       for l in [ k+1 .. Length( deco ) ] do 
         # construct matrix representation of <a_i> acting on this section
         A := [];
         for j in deco[l]  do 
           ev1 := ListWithIdenticalEntries( n, 0 );
           CollectWordOrFail( coll, ev1, [j,1,i,1] );
           Add( A, ev1{deco[l]} );
         od;

         if exps[l] = 0 then 
           if not AbsInt( DeterminantIntMat( A ) ) = 1 then return( false ); fi;
         else
           if DeterminantIntMat( A ) mod exps[l] = 0 then return( false ); fi;
         fi;
       od;
     od;
   od;

   return true;
end;

############################################################################
##
## including a weight function for power-commutator presentations
##
############################################################################
IsConfluentPowComm := function( coll, weights )
  local   n, 		# number of generators of coll
	  k,j,i, 	# loop variables 
	  ev1, ev2,	# exponent vectors (rhs and lhs)
	  c,		# nilpotency class
  	  w,		# loop variable (object representation) 
	  I;		# set of indices of generators with power relation

  # number of generators    
  n := coll![ PC_NUMBER_OF_GENERATORS ];

  # those generators with a power relation
  I := Filtered( [ 1 .. n ], x -> IsBound( coll![ PC_EXPONENTS ][x] ) );

  # nilpotency class
  c := Maximum( weights );

  # k (j i) = (k j) i
  for k in [ n, n-1 .. 1 ] do
    for j in [ k-1, k-2 .. 1 ] do
      for i in [ 1 .. j-1 ] do
        if weights[i] + weights[j] + weights[k] <= c then 
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [j,1,i,1] ) <> fail;
  
          w := ObjByExponents( coll, ev1 );
          repeat
              ev1 := ExponentsByObj( coll, [k,1] );
          until CollectWordOrFail( coll, ev1, w ) <> fail;
              
          repeat 
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev2, [k,1,j,1,i,1] ) <> fail;
              
          if ev1 <> ev2 then return( false ); fi;
        else 
          # the weight function is an increasing function! 
          break;
        fi;
      od;
    od;
  od;
  
  # j^m i = j^(m-1) (j i)
# for j in [n,n-1..1] do
#   if IsBound(coll![ PC_EXPONENTS ][j]) then
  for j in Reversed( I ) do 
      for i in [ 1 .. j-1 ] do
        if weights[j] + weights[i] <= c then 
          repeat 
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1,
                             [j,coll![ PC_EXPONENTS ][j]-1,j,1,i,1] ) <> fail;
              
          repeat
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev2, [j,1,i,1] ) <> fail;
  
          w := ObjByExponents( coll, ev2 );
          repeat 
            ev2 := ExponentsByObj( coll, [j,coll![ PC_EXPONENTS ][j]-1] );
          until CollectWordOrFail( coll, ev2, w ) <> fail;
  
          if ev1 <> ev2 then return( false ); fi;
        else 
          break;
        fi;
      od;
#   fi;
  od;
  
  # j i^m = (j i) i^(m-1)
# for i in [1..n] do
#   if IsBound(coll![ PC_EXPONENTS ][i]) then
  for i in I do 
      for j in [ i+1 .. n ] do
        if weights[i] + weights[j] <= c then 
          if IsBound( coll![ PC_POWERS ][i] ) then
            repeat 
              ev1 := ExponentsByObj( coll, [j,1] );
            until CollectWordOrFail( coll, ev1, coll![ PC_POWERS ][i] );
          else 
            ev1 := ExponentsByObj( coll, [j,1] );
          fi;
          
          repeat
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail(coll,ev2,
                                  [j,1,i,coll![PC_EXPONENTS][i]] ) <> fail;
        
          if ev1 <> ev2 then return( false ); fi;
        else 
          break;
        fi;
      od;
#   fi;
  od;
  
  # i^m i = i i^m
  for i in [ 1 .. n ] do
    if IsBound( coll![ PC_EXPONENTS ][i] ) then
      if 2 * weights[i] <= c then
        repeat
          ev1 := ListWithIdenticalEntries( n, 0 );
        until CollectWordOrFail(coll,ev1,[i,coll![ PC_EXPONENTS ][i]+1])<>fail;
            
        if IsBound( coll![ PC_POWERS ][i] ) then
          repeat
          ev2 := ExponentsByObj( coll, [i,1] );
          until CollectWordOrFail( coll, ev2, coll![ PC_POWERS ][i] ) <> fail;
        else
          ev2 := ExponentsByObj( coll, [i,1] );
        fi;
            
        if ev1 <> ev2 then return( false ); fi;
      else 
        break;
      fi;
    fi;
  od;
      
  # j = (j -i) i 
  for i in [ 1 .. n ] do
    if not IsBound( coll![ PC_EXPONENTS ][i] ) then
      for j in [ i+1 .. n ] do
        if weights[i] + weights[j] <= c then 
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [j,1,i,-1,i,1] ) <> fail;
  
          ev1[j] := ev1[j] - 1;
          if ev1 <> ListWithIdenticalEntries( n, 0 ) then 
            return( false );
          fi;
        else 
          break;
        fi;
      od;
    fi;
  od;
    
  # i = -j (j i)
  for j in [1..n] do
    if not IsBound( coll![ PC_EXPONENTS ][j] ) then
      for i in [1..j-1] do
        if weights[i] + weights[j] <= c then
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [ j,1,i,1 ] ) <> fail;
    
          w := ObjByExponents( coll, ev1 );
          repeat
            ev1 := ExponentsByObj( coll, [j,-1] );
          until CollectWordOrFail( coll, ev1, w ) <> fail;
              
          if ev1 <> ExponentsByObj( coll, [i,1] ) then 
            return( false );
          fi;
            
          # -i = -j (j -i)
          if not IsBound( coll![ PC_EXPONENTS ][i] ) then
            repeat
              ev1 := ListWithIdenticalEntries( n, 0 );
            until CollectWordOrFail( coll, ev1, [ j,1,i,-1 ] ) <> fail;
  
            w := ObjByExponents( coll, ev1 );
            repeat
              ev1 := ExponentsByObj( coll, [j,-1] );
            until CollectWordOrFail( coll, ev1, w ) <> fail;
                  
            if ev1 <> ExponentsByObj( coll, [i,-1] ) then return( false ); fi;
          fi;
        else 
          break;
        fi;
      od;
    fi;
  od;

  return( true );
  end;

############################################################################
##
## including both, a decomposition and a weight function
##
############################################################################
GunnarsIsConfluentPowComm := function( coll, weights, deco )
  local   n, 		# number of generators of coll
	  exps,		# exponent vector
	  A,		# matrix representation
	  l,k,j,i, 	# loop variables 
	  ev1, ev2,	# exponent vectors (rhs and lhs)
	  c,		# nilpotency class
  	  w,		# loop variable (object representation) 
	  I;		# set of indices of generators with power relation

  # number of generators    
  n := coll![ PC_NUMBER_OF_GENERATORS ];

  # those generators with a power relation
  I := Filtered( [ 1 .. n ], x -> IsBound( coll![ PC_EXPONENTS ][x] ) );

  # nilpotency class
  c := Maximum( weights );

  # k (j i) = (k j) i
  for k in [ n, n-1 .. 1 ] do
    for j in [ k-1, k-2 .. 1 ] do
      for i in [ 1 .. j-1 ] do
        if weights[i] + weights[j] + weights[k] <= c then 
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [j,1,i,1] ) <> fail;
  
          w := ObjByExponents( coll, ev1 );
          repeat
              ev1 := ExponentsByObj( coll, [k,1] );
          until CollectWordOrFail( coll, ev1, w ) <> fail;
              
          repeat 
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev2, [k,1,j,1,i,1] ) <> fail;
              
          if ev1 <> ev2 then return( false ); fi;
        else 
          # the weight function is an increasing function! 
          break;
        fi;
      od;
    od;
  od;
  
  # j^m i = j^(m-1) (j i)
# for j in [n,n-1..1] do
#   if IsBound(coll![ PC_EXPONENTS ][j]) then
  for j in Reversed( I ) do 
      for i in [ 1 .. j-1 ] do
        if weights[j] + weights[i] <= c then 
          repeat 
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1,
                             [j,coll![ PC_EXPONENTS ][j]-1,j,1,i,1] ) <> fail;
              
          repeat
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev2, [j,1,i,1] ) <> fail;
  
          w := ObjByExponents( coll, ev2 );
          repeat 
            ev2 := ExponentsByObj( coll, [j,coll![ PC_EXPONENTS ][j]-1] );
          until CollectWordOrFail( coll, ev2, w ) <> fail;
  
          if ev1 <> ev2 then return( false ); fi;
        else 
          break;
        fi;
      od;
#   fi;
  od;
  
  # j i^m = (j i) i^(m-1)
# for i in [1..n] do
#   if IsBound(coll![ PC_EXPONENTS ][i]) then
  for i in I do 
      for j in [ i+1 .. n ] do
        if weights[i] + weights[j] <= c then 
          if IsBound( coll![ PC_POWERS ][i] ) then
            repeat 
              ev1 := ExponentsByObj( coll, [j,1] );
            until CollectWordOrFail( coll, ev1, coll![ PC_POWERS ][i] );
          else 
            ev1 := ExponentsByObj( coll, [j,1] );
          fi;
          
          repeat
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail(coll,ev2,
                                  [j,1,i,coll![PC_EXPONENTS][i]] ) <> fail;
        
          if ev1 <> ev2 then return( false ); fi;
        else 
          break;
        fi;
      od;
#   fi;
  od;
  
  # i^m i = i i^m
  for i in [ 1 .. n ] do
    if IsBound( coll![ PC_EXPONENTS ][i] ) then
      if 2 * weights[i] <= c then
        repeat
          ev1 := ListWithIdenticalEntries( n, 0 );
        until CollectWordOrFail(coll,ev1,[i,coll![ PC_EXPONENTS ][i]+1])<>fail;
            
        if IsBound( coll![ PC_POWERS ][i] ) then
          repeat
          ev2 := ExponentsByObj( coll, [i,1] );
          until CollectWordOrFail( coll, ev2, coll![ PC_POWERS ][i] ) <> fail;
        else
          ev2 := ExponentsByObj( coll, [i,1] );
        fi;
            
        if ev1 <> ev2 then return( false ); fi;
      else 
        break;
      fi;
    fi;
  od;
      
  # j = (j -i) i 
  for i in [ 1 .. n ] do
    if not IsBound( coll![ PC_EXPONENTS ][i] ) then
      for j in [ i+1 .. n ] do
        if weights[i] + weights[j] <= c then 
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [j,1,i,-1,i,1] ) <> fail;
  
          ev1[j] := ev1[j] - 1;
          if ev1 <> ListWithIdenticalEntries( n, 0 ) then 
            return( false );
          fi;
        else 
          break;
        fi;
      od;
    fi;
  od;
    
# Gunnar's method

   exps := [];
   for i in [ 1 .. Length( deco ) ] do
     if IsBound( coll![ PC_EXPONENTS ][ deco[i][1]] ) then
       exps[i] := FactorsInt( coll![ PC_EXPONENTS ][ deco[i][1] ] )[1];
     else
       exps[i] := 0;;
     fi;
   od;
    
   for k in Filtered( [ 1 .. Length( deco ) ], x -> exps[x] = 0 ) do
     for i in deco[k] do
       for l in [ k+1 .. Length( deco ) ] do 
         # construct matrix representation of <a_i> acting on this section
         A := [];
         for j in deco[l]  do 
           ev1 := ListWithIdenticalEntries( n, 0 );
           CollectWordOrFail( coll, ev1, [j,1,i,1] );
           Add( A, ev1{deco[l]} );
         od;

         if exps[l] = 0 then 
           if not AbsInt( DeterminantIntMat( A ) ) = 1 then return( false ); fi;
         else
           if DeterminantIntMat( A ) mod exps[l] = 0 then return( false ); fi;
         fi;
       od;
     od;
   od;

  return( true );
  end;
