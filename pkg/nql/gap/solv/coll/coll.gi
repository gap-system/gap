############################################################################
##
#W cohom.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: coll.gi,v 1.1 2010/07/26 05:18:46 gap Exp $
##
Revision.("isopcp/gap/coll/coll_gi"):=
  "@(#)$Id: coll.gi,v 1.1 2010/07/26 05:18:46 gap Exp $";

TEST_ALL := true;

############################################################################
##
#F  Obj_Inverse( <w> ) . . . inverts an external representation of object
##
Obj_Inverse := function ( w )
  local i, n, inv;
  
  n := Length( w ); 
  inv := ListWithIdenticalEntries( n, 0 );

  for i in [n-1,n-3..1] do 
    inv[ n-i ] := w[i];
    inv[n-i+1] := -w[i+1];
  od;

  return( inv );
  end;

############################################################################
##
#F  PushTailVector( ... ) . . . through the stack
##
PushTailVector := function ( A, tail, stp, wst, west, est, sst )
  local word,	# word in the generators of <Q>
	ev,     #
	q,	# the element in <Q> corr. to <word>
	i,j,k;	# loop variables

  word:= [];

  for i in [ stp, stp-1 .. 1 ] do
    j := ShallowCopy( west[ i ] );
    if TEST_ALL and j < 0 then 
      Error("negative word exponent stack at ",stp);
    fi;
    k := ShallowCopy( sst[ i ] );
    if wst[ i ][ k ] <= A.n then 
      Append( word, [ wst[ i ][ k ], est[ i ] ] );
    fi;
    while j <> 0 do
      while IsBound( wst[ i ][ k+2 ] ) do
        k := k+2;
        if wst[ i ][ k ] <= A.n then 
          Append( word, [ wst[ i ][ k ],  wst[ i ][ k+1 ] ] );
        fi;
      od;
      j := j - 1;
      k := -1;                   # s.t. k+2 is the beginning of the next word...
    od;
  od;

  repeat 
    ev := ListWithIdenticalEntries( A.n, 0 );
  until CollectWordOrFail( A.ftlQ, ev, word ) <> fail;

  return( tail * PcpElementByExponents( A.ftlQ, ev ));
end;

############################################################################
##
#F  CollectMyWordOrFail ( <A>, <u>, <v> ) . . . . . . . .  symbolic collecting
##
## similar to the library collector.
##
CollectMyWordOrFail := function( A, u, v )
  local wst, 	# word stack - contains the words as ExtRepOfObj
	stp,	# stack pointer - points to the current word in the word stack
	west, 	# word exponent stack - number of times a word occurs
	sst,	# syllable stack - position in the word 
	est, 	# exponent stack - number of times the gen occurs in syllable 
	ev,eev,	# exponent vectors 
	w, 	# the generators used for collecting
	relsQ, 	# relative orders of <Q>
	tail,	# the tail vector - for pushing tails
        cnj, 	# the conjugates
	icnj,   # the inverse conjugates
	i,k;	# loop variables

  relsQ := RelativeOrders( A.ftlQ );

  wst  := A!.wst;					# word stack
  west := A!.west;					# word exponent stack
  est  := A!.est;					# exponent stack
  sst  := A!.sst;; 					# syllable stack

  tail := ShallowCopy( A.tail_zero );

  wst[1]  := v;
  west[1] := 1;
  est[1]  := wst[1][2];
  stp     := 1;			# stack-pointer
  # new:
  sst[1]  := 1;

  while stp > 0 do 

    if est[ stp ] = 0 then  
      if IsBound( wst[ stp ][ sst[stp] + 2] ) then 
        sst[ stp ] := sst[ stp ] + 2;
        est[ stp ] := wst[ stp ][ sst[ stp ] + 1];
      else                                       # reached the end of wst[ stp ]
        # reduce word exponent stack
        west[ stp ] := west[ stp ] - 1;
        if west[ stp ] = 0 then                  # finished the whole word
          wst[ stp ] := 0;
          sst[ stp ] := 1;
          est[ stp ] := 0;
          stp := stp - 1;
        elif west[ stp ] < 0 then 
          Error("may not occur");
        else
          sst[ stp ] := 1;
          est[ stp ] := wst[ stp ][2];
        fi;
      fi;
    else

#if TEST_ALL then 
#  Print("u=",u,"\n");
#  Print("                tail = ",tail,"\n");
#  PrintCollectionStack( stp, wst, west, sst, est );
#fi;

      # get the next generator
      w := [ wst[ stp ][ sst[stp] ], est[ stp ] ];
      if w[1] > A.n + A.m then 
        # adding a tail
        u[2][ w[1]-(A.n+A.m) ] := u[2][ w[1]-(A.n+A.m) ] + w[2] * A.ZQ_one; 

        est[ stp ] := 0;
      elif w[1] > A.n then 
        # an element of <N>    
        repeat
          ev := ShallowCopy( u[1]{ [ A.n+1 .. A.n+A.m ] } );
        until CollectWordOrFail( A.ftlN, ev, [ w[1] - A.n, w[2] ]) <> fail;
        u[1]{ [ A.n+1 .. A.n+A.m ] } := ev;

        est[ stp ] := 0;
      else
        # an element of <Q>

        # check if its exponent is negative although its rel. order is finite
        # avoid these collections as we don't want to build the inverse
        # conjugacy relations since storing the tail vector might be too much ;)
        if relsQ[ w[1] ] > 0 and w[2] < 0 then 
          stp := stp + 1;
          if not IsBound( wst[ stp ] ) then 
            Append(A!.wst, A!.wst);
            Append(A!.est, A!.est);
            Append(A!.west, A!.west);
            return( fail );
          fi;
          # < a_i ^-1 = a_i ^(r_i-1) [u_ii(..)] ^-1 > 
          wst[ stp ] := Concatenation( [ w[1], relsQ[ w[1] ] - 1], 
                        Obj_Inverse( A.rels[ w[1] ][ w[1] ] ) );
          sst[ stp ] := 1;
          est[ stp ] := wst[ stp ][2];          # exists as power rel got a tail

          # any negative power of a generator of finite order
          west[ stp ] := AbsInt( est[ stp - 1] );
          est[ stp - 1 ] := 0;
        else
          # take a generator from the stack (reduced exponent stack by +/- 1)
          est[ stp ] := est[ stp ] - SignInt( w[2] );

          # push <[ w[1], 1 ]> through the tails 
          u[2] := u[2] * PcpElementByGenExpList( A.ftlQ, [w[1],SignInt(w[2])]);

          # push <[ w[1], 1 ]> through <N> using <A.auts> and <A.autsinv>
          ev := PcpElementByExponents( A.ftlN, u[1]{[A.n+1..A.n+A.m]} );
          if w[2] > 0 then 
            ev := ev ^ ( A.auts[ w[1] ] );
          else
            ev := ev ^ ( A.autsinv[ w[1] ] );
          fi;
          u[1]{ [ A.n+1 .. A.n+A.m ] } := Exponents( ev );
 
          # choose conjugacy relations w.r.t. SignInt( w[2] )
          if w[2] > 0 then 
            cnj := List( [ w[1]+1 .. A.n ],x -> A.rels[ x ][ w[1] ] );
          else
            cnj := List( [ w[1]+1 .. A.n ],x -> A.rels[ x ][ w[1]+x ] );
          fi;

          ev := ObjByExponents( A.ftlQ, Concatenation( 
                ListWithIdenticalEntries(w[1]-1, 0), u[1]{[ w[1] .. A.n ]} ) );
          u[1]{[ w[1]+1 .. A.n ]} := ListWithIdenticalEntries(A.n - w[1], 0);
          u[1][ w[1] ] := u[1][ w[1] ] + SignInt( w[2] );

          if Length(ev) <> 0  or 
             ( relsQ[ w[1] ] <> 0 and u[1][ w[1] ] >= relsQ[ w[1] ] ) then 

            # push tail vector through the stack to the end
            if not IsZero( u[2] ) then 
              tail := tail + PushTailVector(A, u[2], stp, wst, west, est, sst);
              u[2] := A.ZQ_zero * u[2];
            fi;
            
            # add < h_1^f_1...h_m^f_m > to the stack
            eev := ObjByExponents( A.ftlN, u[1]{[A.n+1..A.n+A.m]} );
            if Length(eev) <> 0 then
              for k in [1,3..Length(eev)-1] do
                eev[k] := eev[k] + A.n;
              od;

              stp := stp + 1; 
              if not IsBound( wst[ stp ] ) then 
                Append(A!.wst, A!.wst);
                Append(A!.est, A!.est);
                Append(A!.west, A!.west);
                return( fail );
              fi;
              wst[ stp ]  := eev;
              west[ stp ] := 1;
              est[ stp ]  := wst[ stp ][2];

              u[1]{[ A.n+1 .. A.n+A.m ]} := ListWithIdenticalEntries( A.m, 0 );
            fi;
          fi;

          for i in [Length(ev)-1,Length(ev)-3..1] do
            if w[1] = ev[i] then 
              if relsQ[ w[1] ] <> 0 and u[1][ w[1] ] >= relsQ[ w[1] ] then

                stp := stp + 1;
                if not IsBound( wst[stp] ) then 
                  Append(A!.wst, A!.wst);
                  Append(A!.est, A!.est);
                  Append(A!.west, A!.west);
                  return( fail );
                fi;
                wst[ stp ]  := A.rels[ w[1] ][ w[1] ];
                west[ stp ] := QuoInt( u[1][ w[1] ], relsQ[ w[1] ] );
                est[ stp ]  := wst[ stp ][2];

		u[1][ w[1] ] := u[1][w[1]] mod relsQ[ w[1] ];
              fi;
            else
              stp := stp + 1;
              if not IsBound( wst[stp] ) then 
                Append(A!.wst, A!.wst);
                Append(A!.est, A!.est);
                Append(A!.west, A!.west);
                return( fail );
              fi;
              if ev[i+1] > 0 then 
		# conjugacy relation for < ev[i] ^ w[1] > from A.rels
                wst[ stp ]  := cnj[ ev[i] - w[1] ];
                west[ stp ] := ev[i+1];
                est[ stp ]  := wst[ stp ][2];
              else 
		# conjugating an element with negative exponent 
                wst[ stp ]  := Obj_Inverse( cnj[ ev[i] - w[1] ] );
                west[ stp ] := AbsInt( ev[i+1] );
                est[ stp ]  := wst[ stp ][2];
              fi;
            fi;
          od;
        fi;
      fi;
    fi;
  od;

  u[2] := u[2] + tail;

#Print( " u = ", u, "\n" );
#Print( "... done\n" );

  return(u);
  end;

############################################################################
##
#F  CRRecord( <Q>, <N>, <Coupling> ) . . . . . . . cohomology record :)
##
CRRecord := function( Q, N, Coupling )
  local ftlQ,	# from the left collector of <Q>
	ftlN,	# from the left collector of <N>
	relsQ,	# relative orders of <Q>
	n,m,	# number of generators of <Q> and <N>, respectively
	r, 	# number of generators of the new collector
	A,	# the final record
	w,t,	# a word and a tail ;)
	er,e,	# another word
	l,	# tail-number (stack)
	i,j,k;	# loop variables

  ftlQ := Collector( Q );
  n := ftlQ![ PC_NUMBER_OF_GENERATORS ];
  ftlN := Collector( N );
  m := ftlN![ PC_NUMBER_OF_GENERATORS ];
  relsQ := RelativeOrders( ftlQ );

  # generators of <N> and <Q>
  r := n + m;
  # number of tails
  r := r + Length( Filtered( relsQ, x-> x <> 0) )     # num of power rels of Q
         + Binomial( Length(relsQ), 2)                # num of pos conj rels
         + Sum(List( Filtered( [1..Length(relsQ)], i-> relsQ[i]=0 ), 
                     x-> Length(relsQ)-x )) ;	      # num of neg conj rels

  A := rec ( factor := Q,
	     n := n, m := m,
             module := N, 
             ftlN := ftlN,
             ftlQ := ftlQ,
             auts := List(GeneratorsOfGroup(Q), x-> x^Coupling ),
             ZQ := GroupRing( Integers, Q ) );

  A.autsinv   := List( A.auts, x-> x^-1 );
  A.ZQ_one    := One( A.ZQ );
  A.ZQ_zero   := Zero( A.ZQ );
  A.tail_zero := ListWithIdenticalEntries( r-(n+m), A.ZQ_zero );
  A.One       := [ ListWithIdenticalEntries( n+m, 0 ),
                   ShallowCopy( A.tail_zero ) ];
  MakeImmutable( A.One );

  # word-stack
  A!.wst := ListWithIdenticalEntries( ftlQ![ PC_STACK_SIZE ], 0 );
  # word exponent-stack
  A!.west := ListWithIdenticalEntries( ftlQ![ PC_STACK_SIZE ], 0 );
  # exponent-stack
  A!.est := ListWithIdenticalEntries( ftlQ![ PC_STACK_SIZE ], 0 );
  # syllable stack
  A!.sst := ListWithIdenticalEntries( ftlQ![ PC_STACK_SIZE ], 1 );
  
  # relations for elements in <Q>: a list with the following entries
  #  a_1^r_1 a_1^-1
  #  a_2^a_1 a_2^r_2 a_2^{a_1^-1} a_2^-1 
  #  a_3^a_1 a_3^a_2 a_3^r_3 a_3^{a_1^-1} a_3^{a_2^-1} a_3^-1
  #  etc. ;)  
  #   
  A.rels := List([1..n],x->[]);
  l := (n+m) + 1;      					# tail generator...
  for i in [1..n] do 
    for j in [i..n] do
      # power relation
      if i = j and relsQ[i] > 0 then 
        er := GetPower( ftlQ, i );
        e := A.auts[i] ^ relsQ[i];
	for k in [1,3..Length(er)-1] do
          e := e * A.auts[ er[k] ] ^ er[k+1]; 
        od;
	if not IsInnerAutomorphism(e) then 
          Error("in CRRecord: not an inner automorphism!");
        fi;
        e := ConjugatorOfConjugatorIsomorphism( e );
#       e := ConjugatorOfConjugatorIsomorphism( e ) ^ -1;
        er := ObjByExponents( ftlN, Exponents( e ) );
	for k in [1,3..Length(er)-1] do
 	  er[k] := er[k] + n;
        od;
        A.rels[i][i] := Concatenation( GetPower( ftlQ, i ), er, [l,1] );
        l := l + 1;
      elif i<>j then 
   	er := GetConjugate( ftlQ, j, i );
	e := A.auts[i] ^-1 * A.auts[j] ^-1 * A.auts[i];
        for k in [1,3..Length(er)-1] do
	  e := e * A.auts[ er[k] ] ^ er[k+1];
        od;
	if not IsInnerAutomorphism(e) then 
          Error("in CRRecord: not an inner automorphism!");
        fi;
        e := ConjugatorOfConjugatorIsomorphism( e );
#       e := ConjugatorOfConjugatorIsomorphism( e ) ^ -1;
        er := ObjByExponents( ftlN, Exponents( e ) );
	for k in [1,3..Length(er)-1] do
 	  er[k] := er[k] + n;
        od;
        A.rels[j][i] := Concatenation( GetConjugate( ftlQ, j, i ), er, [l,1] );
	l := l + 1;

        if relsQ[i] = 0 then 
          er := GetConjugate( ftlQ, j, -i );
          e := A.auts[i] * A.auts[j] ^-1 * A.auts[i] ^-1;
          for k in [1,3..Length(er)-1] do
	    e := e * A.auts[ er[k] ] ^ er[k+1];
          od;
	  if not IsInnerAutomorphism(e) then 
            Error("in CRRecord: not an inner automorphism!");
          fi;
          e := ConjugatorOfConjugatorIsomorphism( e );
#         e := ConjugatorOfConjugatorIsomorphism( e ) ^ -1;
          er := ObjByExponents( ftlN, Exponents( e ) );
	  for k in [1,3..Length(er)-1] do
 	    er[k] := er[k] + n;
          od;
          A.rels[j][j+i] := Concatenation(GetConjugate( ftlQ, j, i ),er,[l,1]);
  	  l := l + 1;
        fi;
      fi;
    od;
  od;

  return(A);
  end;

############################################################################
##
#M  MyObjByExponents( )
##
MyObjByExponents := function( A, exps )
  local i,	# loop variable
	w;	# the word

  if Length(exps) > A.n + A.m then 
    Error("not that many generators in <A>");
  fi;

  w := [];
  for i in [1..Length(exps)] do
    if exps[i] <> 0 then 
      Append( w, [ i, exps[i] ] );
    fi;
  od;
  return(w);
  end;
