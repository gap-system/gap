############################################################################
##
#W  consist.gi 			NQL				René Hartung
##
#H   @(#)$Id: consist.gi,v 1.3 2009/05/06 12:54:46 gap Exp $
##
Revision.("nql/gap/consist_gi"):=
  "@(#)$Id: consist.gi,v 1.3 2009/05/06 12:54:46 gap Exp $";


############################################################################
##
#F  NQL_CheckConsistencyRelations ( <coll> , <weights> )
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
InstallGlobalFunction( NQL_CheckConsistencyRelations,
  function( coll, weights )
  local   HNF,		# Hermite normal form of the inconsistencies
   	  n, 		# number of generators of coll
	  k,j,i, 	# loop variables 
	  ev1, ev2,	# exponent vectors (rhs and lhs)
	  c,		# nilpotency class
  	  w,		# loop variable (object representation) 
	  I;		# set of indices of generators with power relation

  # number of generators    
  n := coll![ PC_NUMBER_OF_GENERATORS ];

  # Those generators with a power relation
  I:=Filtered([1..n],x->IsBound(coll![PC_EXPONENTS][x]));

  # nilpotency class
  c:=Maximum(weights);

  # initialize the Hermite normal form
  HNF:=rec(mat:=[],Heads:=[]);

  # k (j i) = (k j) i
  for k in [n,n-1..1] do
    for j in [k-1,k-2..1] do
      for i in [1..j-1] do
        if weights[i]+weights[j]+weights[k]<=c then 
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [j,1,i,1] ) <> fail;
  
          w := ObjByExponents( coll, ev1 );
          repeat
              ev1 := ExponentsByObj( coll, [k,1] );
          until CollectWordOrFail( coll, ev1, w )<>fail;
              
          repeat 
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev2, [k,1,j,1,i,1] )<>fail;
              
          NQL_AddRow(HNF,ev1-ev2);
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
      for i in [1..j-1] do
        if weights[j]+weights[i]<=c then 
          repeat 
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [j, coll![ PC_EXPONENTS ][j]-1, 
                                               j, 1, i,1] )<>fail;
              
          repeat
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev2, [j,1,i,1] )<>fail;
  
          w := ObjByExponents( coll, ev2 );
          repeat 
            ev2 := ExponentsByObj( coll, [j,coll![ PC_EXPONENTS ][j]-1] );
          until CollectWordOrFail( coll, ev2, w )<>fail;
  
          NQL_AddRow(HNF,ev1-ev2);
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
      for j in [i+1..n] do
        if weights[i]+weights[j]<=c then 
          if IsBound( coll![ PC_POWERS ][i] ) then
            repeat 
              ev1 := ExponentsByObj( coll, [j,1] );
            until CollectWordOrFail( coll, ev1, coll![ PC_POWERS ][i] );
          else 
            ev1 := ExponentsByObj( coll, [j,1] );
          fi;
          
          repeat
            ev2 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail(coll,ev2,[j,1,i,coll![PC_EXPONENTS][i]] )
		 <>fail;
        
          NQL_AddRow(HNF,ev1-ev2);
        else 
          break;
        fi;
      od;
#   fi;
  od;
  
  # i^m i = i i^m
  for i in [1..n] do
    if IsBound( coll![ PC_EXPONENTS ][i] ) then
      if 2*weights[i]<=c then
        repeat
          ev1 := ListWithIdenticalEntries( n, 0 );
        until CollectWordOrFail(coll,ev1,[i,coll![ PC_EXPONENTS ][i]+1])<>fail;
            
        if IsBound( coll![ PC_POWERS ][i] ) then
          repeat
          ev2 := ExponentsByObj( coll, [i,1] );
          until CollectWordOrFail( coll, ev2, coll![ PC_POWERS ][i] )<>fail;
        else
          ev2 := ExponentsByObj( coll, [i,1] );
        fi;
            
        NQL_AddRow(HNF,ev1-ev2);
      else 
        break;
      fi;
    fi;
  od;
      
  # j = (j -i) i 
  for i in [1..n] do
    if not IsBound( coll![ PC_EXPONENTS ][i] ) then
      for j in [i+1..n] do
        if weights[i]+weights[j]<=c then 
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [j,1,i,-1,i,1] )<>fail;
  
          ev1[j] := ev1[j] - 1;
          NQL_AddRow(HNF,ev1);
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
        if weights[i]+weights[j]<=c then
          repeat
            ev1 := ListWithIdenticalEntries( n, 0 );
          until CollectWordOrFail( coll, ev1, [ j,1,i,1 ] )<>fail;
    
          w := ObjByExponents( coll, ev1 );
          repeat
            ev1 := ExponentsByObj( coll, [j,-1] );
          until CollectWordOrFail( coll, ev1, w )<>fail;
              
          NQL_AddRow(HNF, ev1 - ExponentsByObj( coll, [i,1] ));
            
          # -i = -j (j -i)
          if not IsBound( coll![ PC_EXPONENTS ][i] ) then
            repeat
              ev1 := ListWithIdenticalEntries( n, 0 );
            until CollectWordOrFail( coll, ev1, [ j,1,i,-1 ] )<>fail;
  
            w := ObjByExponents( coll, ev1 );
            repeat
              ev1 := ExponentsByObj( coll, [j,-1] );
            until CollectWordOrFail( coll, ev1, w )<>fail;
                  
            NQL_AddRow( HNF, ExponentsByObj( coll, [i,-1] ) - ev1);
          fi;
        else 
          break;
        fi;
      od;
    fi;
  od;

  return(HNF);
  end);
