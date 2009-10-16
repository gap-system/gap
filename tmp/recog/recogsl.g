##############################################################################
##                                                                          ##
#I This is the implementation of the Kantor-Seress algorithm for PSL(d,q)   ##
##                                                                          ##
############################################################################## 

##############################################################################
##
#F BoundedOrder( <bbgroup> , <elt> , <power>, <primes> )
##
## This is a subroutine needed in the sequel which takes as input an element
## $r$ of bbg and a positive integer $n$ such that $r^n=1$ and will return
## the flag "true" if and only if $n$ is the order of $r$.

BoundedOrder:=function( bbg, r, n, primes)
   local      prime;     #an element of primes
 
   for prime in primes do
     if r^(n/prime) = One(bbg) then return(false);
     fi;
   od;
   return(true);
end;

#############################################################################
##
#F BinFunc ( <integer> )
##
## BinFunc takes an integer $n$ and returns a list containing the binary
## representation of $n$.

BinFunc:=function(n)
  local l,   #length
        i,   #index
       new,  #the number being examined
       bin;  #the list

       bin := [];
       new:=n;
       repeat 
          Add(bin, new mod 2); 
          new := (new - (new mod 2) )/2;
       until new = 0;

       return(bin);
    end;



###########################################################################
##
#F NtoPadic( <prime> , <power>, <number> )
##
## Writes a number 0 <= n < p^e in base p

NtoPadic := function(p,e,n)

     local j,       # loop variable
           output;  # output vector


  output := [];
  for j in [1..e] do
      output[j] := (n mod p)*Z(p)^0;
      n := (n - (n mod p) )/p;
  od;

  return output;

end;
###########################################################################
##
#F PadictoN( <prime> , <power>, <vector> )
##
## Writes a vector in GF(p)^e as a number 0 <= n < p^e 

PadictoN := function(p,e,vector)

     local j,       # loop variable
           output;  # output number


  output := 0;
  for j in [1..e] do
      output := output + p^(j-1)*IntFFE(vector[j]);
  od;

  return output;

end;

##############################################################################
##
#F IS_IN_CENTRE( <bbgroup> , <elt> )
##
## In case the group we are dealing with is a PSL instead of an SL, we 
## will need to check with certain elements lie in the centre of our group.

IS_IN_CENTRE:=function( bbg , x )
   local   gen, gens;
     
     gens := GeneratorsOfGroup(bbg);
     
     for gen in gens do
       if not One(bbg) = Comm(x,gen) then return (false);
       fi;
     od;
     return(true);
end;       
   

                   
##############################################################################
##
#F AppendTran( <bbg> , <H> , <x> , <p> )
##
## The idea here is that $H$ is a proper subgroup (subspace) of a transvection
## group $T$ with parent group $bbg$. $x$ is a verified element of $T$, and
## $dim$ is the dimension of the new subspace of $T$ spanned by $H$ and $x$.
## The subroutine will return this new $H$ and alter the vectors of its elms.

AppendTran:=function( bbg , H , x , p )
   local    new,      #a new element of $H$
           length,    #the length of $H$
            tau,      #power of the transvection $x$
             i,j,     #indeces
             y;       #an element of $H$

     tau:= One(bbg);
     length:=Length(H);

     for i in [1..p-1] do    
       tau:=tau*x;
       for j in [1..length] do
         y:=H[j]; 
         new:=y*tau;
         Add(H,new);
       od;
     od;
end;

#############################################################################
##
#F IsInTranGroup ( <bbgroup> , <listedgroup> , <tran> )
##
## This subroutine takes a list (which will actually be a subgroup of a
## transvection group) which is contained in bbgroup, together with a
## transvection, and outputs `true' iff tran is in list.

IsInTranGroup:=function( bbg , H , x)
    local h,i;
      for h in H do
        if h=x then return(true);
        fi;
      od;
      return(false);
end;


#############################################################################
##
#F MatrixOfEndo( <group>, <elem.ab.subgp>, <prime>, <dimension>, <automorph> )
##
## Computes the matrix of the linear transformation $s$ 
## in terms of ## the standard basis of $T$. The routine assumes 
## that $T$ is listed in the order as in AppendTran.
## $|T|=p^e$, $T \le bbg$

MatrixOfEndo := function(bbg,T,p,e,s)

    local i,j,         # loop variables
          conj,        # image of basis vector
          stop,        # boolean; becomes true when conj is found in T
          matrixofs;   # output

     # construct the matrix of the conjugation by s
     matrixofs := [];
     for i in [0 .. e-1] do
       # the basis vectors of T are in positions p^i +1
       conj := T[p^i +1]^s;
       # find conj in T
       stop := false; 
       j := 0;
       repeat 
         j := j+1;
         if conj = T[j] then
            stop := true;
         fi;
       until stop or j=p^e; 
       if not stop then 
          return (fail); 
       fi;
       Add(matrixofs, NtoPadic(p,e,j-1));
     od;

     return matrixofs;

end;


############################################     
# 
   extractgen:=function(matrixofs,endo,p,e,weights,limit)
      local prod,power,conj,j,stop,temp,ans,k;

   conj:=IdentityMat(e,GF(p));
   stop := false;
   j := 0;

   repeat
      temp := [];
      for k  in [ 1 .. e ]  do
         temp[k] := 0*Z(p);
      od;
      ans:= [Z(p)^0];
      for k  in [ 2 .. e ]  do
         ans[k] := 0*Z(p);
      od;
      for k in [1..e-1] do
          ans := ans*conj*endo;
          temp := ShallowCopy(temp);
          temp[1] := temp[1] + weights[e+1-k];
          temp:=temp*conj*endo;
      od;
      ans:=ans*conj*endo;
      temp := ShallowCopy(temp);
      temp[1] := temp[1] + weights[1];
      if ans =temp then 
          stop := true;
      else
          j := j+1;
          conj:=conj*matrixofs;
      fi;
   until stop or (j = limit);
   
   return j;

   end;        
            

    
##############################################################################
##
#F FindGoodElement ( <bbgroup> , <prime> , <power> , <dim> , <limit> )
##
## This function will take as input a bbgroup which is somehow known to be 
## isomorphic to $SL(d,q)$ or $PSL(d,q)$ where $q=p^e$. The function will 
## (if anything) output a bbgroup element r of order p*ppd#(p;e(d-2)).

FindGoodElement:=function( bbg, p, e, d, limit )
     local    r,     # random element of bbg
              q,     # the field size
              v,     #the candidate ppd#
           primes,   #a list of the prime factors of d-2
          collect2s, #a function, the 2-part of the input 
          z,i,a,c,w,
             phi,    #prod of prim prime divisors of z
             psi;    #prod of non-prim prime divisors of z

   q := p^e;
   if d=3 and q=4 then
      i := 1;
      repeat 
        r := PseudoRandom(bbg); 
        if (r^12 = One(bbg)) and ( not (r^6 = One(bbg))) then 
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
           return r^6;
        fi; 
        i := i+1;
      until i = limit;
   elif d=3 and q=2 then 
      i := 1; 
      repeat
        r := PseudoRandom(bbg);
        if r^4 = One(bbg) then 
           if r^2 = One(bbg) then 
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
              return r;
           else 
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
              return r^2;
           fi;
        fi;
        i := i+1;
      until i = limit;
   else 
       z:=p^(e*(d-2))-1;
       primes:=Set(FactorsInt(e*(d-2)));
            
       collect2s:=function( n )
       # the 2-part of n
       local i, prod;
              prod:=1; 
              i := n;
              while (i mod 2) = 0 do
                  i := i/2;
                  prod := prod * 2;
              od;
              return prod;
       end;                        

       psi:=1; phi:=z;
       
       if e*(d-2)>1 then       
         for c in primes do 
            a:=Gcd(phi, p^(e*(d-2)/c)-1);
            while a>1 do
              psi:=a*psi;
              phi:=phi/a;
              a:=Gcd(phi,a);
            od;
         od;
       fi;
      
       i:=1;
       repeat 
         r:=PseudoRandom(bbg);
         v:=r^p;
         if One(bbg)=v^z and not One(bbg)=r^z  then
         
            if p = 2 and e*(d-2) = 6 then
               if ((not One(bbg) = v^7) and (not One(bbg) = v^9)) or
                  ((not One(bbg) = v^3) and (One(bbg) = v^9)) then
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
                  return( r );
               fi;   
            elif (e*(d-2) = 2) and (p+1 = 2^(Log(p+1,2))) then
               # p is Mersenne prime
               w:=2*z/collect2s( z );
               if not One(bbg) = v^w   then #4/|v|
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
                   return( r );
               fi;
            elif not One(bbg) = v^psi then 
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
               return( r );
            fi;
            
         fi;           
            
         i:=i + 1;
       until i = limit;
   fi; # the big loop with cases
   
       return(fail);
end;


##############################################################################
##
#F SL4FindGoodElement ( <bbgroup> , <prime> , <power> , <limit> )
##
## This function will take as input a bbgroup which is somehow known to be 
## isomorphic to $SL(4,q)$ or $PSL(4,q)$ where $q=p^e$. The function will 
## (if anything) output a bbgroup element r of order p*ppd#(p;2e).

SL4FindGoodElement:=function( bbg, p, e, limit )
     local    r,     # random element of bbg
              q,     # the field size
              i;     # loop variable

   q := p^e;
   if q=2 then 
      i := 1; 
      repeat
        r := PseudoRandom(bbg);
        if r^6=One(bbg) and ( not (r^3 = One(bbg)))
           and ( not (r^2 = One(bbg)))  then
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
           return r;
        fi; 
        i := i+1;
      until i = limit;
   elif q=3 then 
      i := 1;
      repeat
        r := PseudoRandom(bbg);
        if (r^12=One(bbg)) and ( not (r^4 = One(bbg)) )
                       and ( not IS_IN_CENTRE(bbg,r^6) )  then
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
           return r;
        fi; 
        i := i+1;
      until i = limit;

   elif q=5 then 
      i := 1; 
      repeat
        r := PseudoRandom(bbg);
        r := r^4;
        if (r^15=One(bbg)) and ( not (r^3 = One(bbg)))
                       and ( not (r^5 = One(bbg)))  then
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
           return r;
        fi; 
        i := i+1;
      until i = limit;
   elif q=9 then 
      i := 1; 
      repeat
        r := PseudoRandom(bbg);
        r := r^8;
        if (r^15=One(bbg)) and ( not (r^3 = One(bbg)))
                       and ( not (r^5 = One(bbg)))  then
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
           return r;
        fi; 
        i := i+1;
      until i = limit;
   elif q=17 then 
      i := 1; 
      repeat
        r := PseudoRandom(bbg);
        r := r^16;
        if r^153=One(bbg) and ( not (r^9 = One(bbg)))
                 and ( not (r^17 = One(bbg)))  then
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
           return r;
        fi; 
        i := i+1;
      until i = limit;
   else
      i := 1; 
      repeat 
        r := PseudoRandom(bbg);
        if (r^(p*(q^2-1))=One(bbg)) and (not (r^(q^2-1)=One(bbg))) 
                and (not (r^(8*p*(q+1))=One(bbg))) 
                and (not (r^(p*(q-1))=One(bbg))) then 
Print("FindGoodElement with i=",i,"  limit=",limit,"\n");
           return r; 
        fi; 
        i := i+1;
      until i = limit;
   fi;

   return(fail);

end;


###############################################################################
##
#F CommutesWith( <bbgroup> , <set> , <x> )
##
## This short routine, needed in the sequel, returns true if and only if <x>
## commutes with every element in the set <set>.

CommutesWith:=function( bbg , S , x )
   local s;
   
   for s in S do
   
      if not One(bbg) = Comm( s , x )  then
         
         return( false );
         
      fi;
      
   od;
   
   return( true );
end;         



################################################################################
##
#F EvaluateBBGp( <data> , <slp> )
##
## This routine will evaluate a straightline program from the black box
## group piece of gens.

EvaluateBBGp:=function( data , slp )
   local   eval,    # list of evaluations
           i,       # loop variable
	   bbg,gens;

   bbg:=data.bbg;
   gens:=data.gens;
   if Length(slp) = 0 then
      return One(bbg);
   fi;

   eval := [];
   for i in [1..Length(slp)] do
     if slp[i][1] = "g" then
       eval[i] := gens[slp[i][2]][1];
     elif slp[i][1] = "p" then
       eval[i] := eval[slp[i][2][1]]*eval[slp[i][2][2]];
     else
       eval[i] := eval[slp[i][2]]^(-1);
     fi;
   od;

   return eval[Length(slp)];

end;


############################################################################
##
#F EvaluateMat( <gens> , <slp>, <dim>, <field size> )
##
## This is in all respects identical to the above, except that we evaluate
## from the matrix group piece of gens.

EvaluateMat:=function( data, slp )
   local    eval,   # list of evaluations
            i,k,    # loop variables
	    one,gens;

   gens:=data.gens;
   one:=One(data.matrixgroup);

   if Length(slp) = 0 then
      return one;
   fi;

   eval := [];
   for i in [1..Length(slp)] do
     if slp[i][1] = "g" then
       eval[i] := List(one,ShallowCopy);
       for k in [1..Length(gens[slp[i][2]][2])] do
          eval[i][ gens[slp[i][2]][2][k][1] ] [ gens[slp[i][2]][2][k][2] ] :=
                gens[slp[i][2]][2][k][3];
       od;
     elif slp[i][1] = "p" then
       eval[i] := eval[slp[i][2][1]]*eval[slp[i][2][2]];
     else
       eval[i] := eval[slp[i][2]]^(-1);
     fi;
   od;

   return ImmutableMatrix(data.field,eval[Length(slp)]);

end;


############################################################################
##
#F ProdProg( <slp1> , <slp2> )
##
## This routine will take two straightline programs and compute a
## straightline program representing the product of the evaluations.

ProdProg:=function( slp1 , slp2 )
   local   slp,    # the output
           new,    # copy of slp2 with changed labels
             i,    # an index
          l1, l2,   # the lengths of slp1 and 2
             w;    # a piece to be added to slp

   if Length( slp1 ) = 0 then
      return( StructuralCopy(slp2) );
   fi;

   if Length( slp2 ) = 0 then
      return( StructuralCopy(slp1) );
   fi;

   l1:=Length(slp1);
   l2:=Length(slp2);

   w:=[];
   w[1]:="p";
   w[2]:=[];
   w[2][1]:=l1;

   new:= StructuralCopy(slp2);

   for i in [1..l2] do
      if new[i][1]="p" then
         new[i][2][1]:=new[i][2][1]+l1;
         new[i][2][2]:=new[i][2][2]+l1;

      elif new[i][1]="i" then
           new[i][2]:=new[i][2]+l1;
      fi;


   od;

   slp:=Concatenation( slp1 , new );
   w[2][2]:=Length( slp );
   Add( slp , w );

   return( slp );
end;

############################################################################
##
#F InvProg( <slp> )
##
## This routine returns a straightline program representing the inverse of slp

InvProg:=function( slp )
   local   new, w, l;

   if Length( slp ) = 0 then
      return( slp );
   fi;

   new:=StructuralCopy( slp );
   l:=Length( slp );
   w:=[];
   w[1]:="i";
   w[2]:=l;
   Add( new , w );

   return( new );
end;

############################################################################
##
#F PowerProg( <slp> , <n> )
##
## This routine takes a straightline program and $n$ and returns a
## straightline program representing the evaluation to the power $n$.

PowerProg:=function( slp , n )
   local   nslp,    # the output
            bin,    # the binary expansion of $n$
           last,    # the current length of slp
            pos,    # a pointer to the things that need evaluating
              w,    # something to be added to nslp
              l,    # the length of bin
              i;    # an index

   if (n=0) then
      return( [] );
   fi;
   bin:= BinFunc( n );
   l:=Length( bin );

   if l=1 then
      return( StructuralCopy(slp) );
   fi;

   nslp:=StructuralCopy( slp );
   pos:=[];

   if bin[1] = 1 then
      Add( pos , Length( nslp ) );
   fi;

   for i in [2..l] do
      last:=Length( nslp );
      w:=[];
      w[1]:="p";
      w[2]:=[ last , last ];
      Add( nslp , w );

      if bin[i] = 1 then
         Add( pos , last + 1 );
      fi;

   od;

   if Length( pos ) = 1 then   # this means $n=2^l$
      return( nslp );

   else
      for i in [1..Length( pos ) - 1] do
         last:=Length( nslp );
         w:=[];
         w[1]:="p";
         w[2]:=[ pos[i], last ];
         Add( nslp , w );
      od;

   fi;

   return( nslp );
end;


PowerofElmtProg:=function( slpelmt , n, seed )
   # slpelmt is the last element of a straight-line program, in position
   # seed. This routine computes what one has to append to the slp,
   # with last element slpelmt^n. n must be positive.
   local   nslp,    # the output
            bin,    # the binary expansion of $n$
           last,    # the current length of slp
              w,    # something to be added to nslp
              l,    # the length of bin
              i;    # an index

   bin:= BinFunc( n );
   l:=Length( bin );

   if l=1 then
      return( [] );
   fi;

   nslp := [];
   for i in [1..l-1] do
      w:=[];
      w[1]:="p";
      w[2]:=[ seed+i-1 , seed+i-1 ];
      Add( nslp , w );
   od;

   for i in [1..l - 1] do
      if bin[i] = 1 then
         last:=Length( nslp );
         w:=[];
         w[1]:="p";
         w[2]:=[ seed+i-1, seed+last ];
         Add( nslp , w );
      fi;
   od;

   return( nslp );
end;

################################################################################
##
#F evaluate_slp( <grp> , <gens> , <slp> )
##
## This routine will evaluate a straightline program from the set <gens> inside <grp>

evaluate_slp:=function( grp , gens , slp )
   local   eval,    # list of evaluations
           i;       # loop variable

   if Length(slp) = 0 then
      return One(grp);
   fi;

   eval := [];
   for i in [1..Length(slp)] do
     if slp[i][1] = "g" then
       eval[i] := gens[slp[i][2]];
     elif slp[i][1] = "p" then
       eval[i] := eval[slp[i][2][1]]*eval[slp[i][2][2]];
     else
       eval[i] := eval[slp[i][2]]^(-1);
     fi;
   od;

   return eval[Length(slp)];

end;



#############################################################################
##
#F SL2Search ( <bbgroup> , <prime> , <power> [, <transvection> ] )
##
## This function will take as input a bbgroup known to be isomorphic to
## $PSL(2,q)$ for known $q=p^e$ and will output an element of order $p$
## and one of order q-1 or (q-1)/(2,q-1) with
## probablility at least 0.94.
## We may already have a transvection in the input

SL2Search:=function( arg )
   local     bbg,   # the input group
             p,     # the characteristic
             e,     # dimension of the field
             r,     #a random element of $G$
             m,     #the number of random elements chosen
           rand,    #the random function for bbg
           primes,  # prime factors of p^e -1
           count,   #number of tries
           out;     #a record containing the output

   bbg := arg[1];
   p := arg[2];
   e := arg[3];
   out := rec();
   if Length(arg) = 4 then
      out.tran := arg[4];
   fi;

   primes := Set(FactorsInt(p^e -1));
   m:=6*(p^e);
   count:=1;

   while count<m do
     r:=PseudoRandom(bbg);
     if not One(bbg) =r then
       if not IsBound(out.tran) and One(bbg)=r^p then
              out.tran:=r;
       fi;
       if not IsBound(out.gen) then
          if p=2 then
             if One(bbg)=r^(p^e-1) and
                BoundedOrder(bbg,r,p^e-1,primes) then
                out.gen:=r;
             fi;
          elif p^e mod 4 = 3 then
             # enough to find r of order (q-1)/2
             r := r*r;
             primes := Difference(primes,[2]);
             if One(bbg)=r^((p^e-1)/2) and
                         BoundedOrder(bbg,r,(p^e-1)/2,primes) then
                out.gen:=r;
             fi;
          else
             if One(bbg)=r^(p^e-1) and
                         BoundedOrder(bbg,r,p^e-1,primes) then
                out.gen:=r;
             elif One(bbg)=r^((p^e-1)/2) and
                         BoundedOrder(bbg,r,(p^e-1)/2,primes) and
                  not IS_IN_CENTRE(bbg,r^((p^e-1)/4)) then
                out.gen:=r;
             fi;
          fi; # p=2

       fi; # IsBound(out.gen)

     fi;  # One(bbg)=r


     count:=count+1;

     if IsBound(out.tran) and IsBound(out.gen) then return(out);
     fi;
   od;

   return(fail);
end;


##############################################################################
##
#F ConstructTranGroup( <bbgroup> , <tran> , <prime> , <power> )
##
## Given a bbgroup purportedly isomorphic to $SL(2,q)$ or $PSL(2,q)$ where
## q=p^e, this will return the full transvection group $T$ containing $tran$
## or report failure. In the case that bbgroup is what it should be, then
## success is highly probable.
##
ConstructTranGroup:=function( bbg , tran , p , e )
    local    t,         #the input transvection $tran$
             tinv,      # the inverse of t
             B,         #list containing a basis for $H$
             H,         #approx of the eventual output
             m,         #total number of tries
             x,         #random transvection
             y,         #element of $H$
             q,         #field size
           count,       #keeps track of how many random elms have been tried
            new,        #newly created element of $H$
            tau,        #powers of a new transvection
           i, j;        #indeces

     t:=ShallowCopy(tran);
     m:=128*(p^e+1)*e;


     #initialize output lists
     B:=[t];
     H:=[One(bbg)];

     tau := One(bbg);
     for i in [1..p-1] do
       tau := tau*t;
       Add(H,tau);
     od;

     count:=1;
     tinv := t^(-1);

     while count<m do

       x:= t^PseudoRandom(bbg);

       if not x=tinv*x*t then
          count:=count+1;
       elif IsInTranGroup(bbg,H,x) then
          count:=count+1;
       else Add(B,x);
            AppendTran(bbg,H,x,p);
            count:=count+1;
       fi;
       if Length(H) = p^e then
          return(H);
       fi;

     od;
     return(fail);

end;

##########################################################################
##
#F Dislodge( <bbgroup> , <trangroup> )
##
## returns a generator of $G$ which does not normalize $T$

Dislodge:=function( bbg , T )
   local   j,     #an element of $G$ which doesn't normalize $T$
           t,     #our starting transvection
           tinv,  # the inverse of t
           i,     #index
          gens,   #generators of bbg
          tconj,  # t^gen
          gen;    #an element of gens

   gens:=GeneratorsOfGroup(bbg);

   t:=T[2];
   tinv := t^(-1);
   j:=One(bbg);

   for gen in gens do
     if One(bbg)=j then
       tconj := t^gen;
       if not tconj = tinv*tconj*t then
              j:=gen;
       fi;
     fi;
   od;

   if One(bbg)=j then
      return fail;
   fi;

   return(j);
end;

###########################################################################
##
#F Standardize( <bbgroup> , <trangroup> , <conj> , <gen> )
##
## We found <gen> in SL2Search to be an element of order $(q-1)$ or $(q-1)/2$
## <gen> will normalize two transvection groups (conjugates of $T$). We wish
## to conjugate <gen> to an $s$ which will normalize $T$ and $T^<conj>$.

Standardize:=function( bbg , T , j , s)
   local    fixed,    #is a list informing us of which groups are fixed by s
             out,     #the output record
               t,     #our transvection
             sinv,    # inverse of s
          firstconj,  # t^s
             ytos,    # y^s
               y,     #an element of $Y$ above
               u,     #elements of $T$
               z,     #group elements
               c;     #group element

    t:=T[2];
    out:=rec();
    sinv := s^(-1);

    firstconj := sinv*t*s;
    if firstconj=firstconj^t then
       out.gen:=s;
       for u in T do
          y:=t^(j*u);
          ytos := sinv*y*s;
          if y = y^ytos then
             out.conj:= j*u;
             return(out);
          fi;
       od;
       return fail;

    else fixed:=[];
       for u in T do
         if Length(fixed) < 2 then
           y := t^(j*u);
           ytos := sinv * y * s;
           if y = y^ytos then
             Add(fixed,u);
           fi;
         fi;
       od;
       if Length(fixed) < 2 then
          return fail;
       fi;
       c := (j*fixed[1])^(-1);
       out.gen := s^c;
       z := j * fixed[2];
       out.conj := z * c;
       return(out);
    fi;
end;



#############################################################################
##
#F SL2ReOrder( <bbgroup> , <trangroup> , <s> , <j> , <prime> , <power> )
##
## The idea of this subroutine is to reorder $T$ and more importantly, the
## permutation domain $Y$, so as to be compatible with our labelling of the
## projective line $PG(1)$. This will then enable us to determine up to
## scalar, the matrix image of an $x$ in our bbgroup.

SL2ReOrder:=function( bbg , T , s , j , p , e )

   local    auto,     #an automorphism of $T$
            newT,     #our relabelled $T$
            Tgamma,   # newT^j
               B,     #GF(p)-basis for GF(q)
             images,  #a list of $<s>$-conjugates of $t$ in coordinate-form
           matrixofs, # the matrix of conjugation by s
         matrixofpow, # the matrix of conjugation by pow
           row,       # first row of images
           count,     # number of tries
          autom,      # a vector of length $e$
         setofimages, # boolean, the ordered set of images coded as numbers
         position,    # index in setofimages
         good,        # index which power of s defines the GF(q)* generator
         stop,        # boolean loop variable
             pow,     # a power of $s$
            conj,     # a power of $s$
           weights,   # vector of rho^e wrt B
             rho,     # generator of GF(q)*
            tnew,     # a new transvection to be added to newT
             out,     # the output record
               t,     # the transvection with coordinates [1,0,...,0]
               u,     # a conjugate of T[2]
            uinv,     # inverse of u
       newTgamma,     # a re-ordered version of Tgamma
             i,k;     # loop variables

   t:=T[2];

   # handle the case of prime field first
   if e = 1 then
     auto := function(bbg,x,pow,conj)
        return x^IntFFE(Z(p));
     end;

     # define dummy variables
     pow := 0;
     conj := 0;
   else
     rho:=PrimitiveRoot(GF(p^e));
     B:=[];
     for i in [1..e] do
         B[i] := rho^(i-1);
     od;
     B:=Basis(GF(p^e),B);
     weights:=Coefficients(B,rho^e);

     #first we define the correct automorphism of $T$
     matrixofs := MatrixOfEndo(bbg,T,p,e,s);
     if matrixofs = fail then
        return fail;
     fi;

     if (p mod 2) =1 then

       # list and order the images of t under s
       setofimages := BlistList([1..p^e],[]);
       row := [ Z(p)^0 ];
       for i  in [ 2 .. e ]  do
          row[i] := 0*Z(p);
       od;
       images := [ row ];
       setofimages[1] := true;
       for i in [1 .. (p^e -3)/2] do
          images[i+1] := images[i] * matrixofs;
          setofimages[PadictoN(p,e,images[i+1])] := true;
       od;

       # find an endomorphism which does not fix the list images
       stop:=false;
       count := 0; # 30 tries for an event with prob ~ 1/2
       repeat
           i:=Random([1..Length(images)]);
           autom := ShallowCopy(images[i]);
           autom[1] := autom[1] + Z(p)^0;
           position := PadictoN(p,e,autom);
           if (position > 0) and (not setofimages[position]) then
              stop:=true;
           fi;
           count := count + 1;
       until stop or (count = 30);
       if count = 30 then
          return fail;
       fi;

       matrixofpow := matrixofs^(i-1);
       pow := s^(i-1);

       good := extractgen(matrixofs,matrixofpow+IdentityMat(e,GF(p)),
                        p,e,weights,(p^e-1)/2);
       if good = (p^e -1)/2 then
          return fail;
       fi;
       conj := s^good;

       auto := function(bbg,x,pow,conj)
       local firstconj;
         firstconj := x^conj;
         return(firstconj*(firstconj^pow));
       end;

     else # case of p=2

       good := extractgen(matrixofs,IdentityMat(e,GF(p)),p,e,weights,p^e-1);
       if good = p^e-1 then
          return fail;
       fi;
       conj := s^good;
       pow := One(bbg);

       auto := function(bbg,x,pow,conj)
         return x^conj;
       end;

     fi; # p mod 2 = 1
   fi; # e = 1

   #now re-order according to auto

   newT:=[One(bbg), t];
   Tgamma := [One(bbg), t^j];
   tnew:=t;
   for i in [1..p^e-2] do
     tnew:=auto(bbg,tnew,pow,conj);
     Add(newT,tnew);
     Add(Tgamma, tnew^j);
   od;

   # shift Tgamma so that the first nontriv. element is mapped to
   # [[1,1],[0,1]]
   # what we do below is to compute the label of the point alpha^Tgamma[2]
   # and replace Tgamma[2] by an element of its transvection group
   u := newT[2]^Tgamma[2];
   uinv := u^(-1);
   i := 2;
   stop := false;
   repeat
     if Tgamma[2]^newT[i] = uinv * (Tgamma[2]^newT[i]) * u   then
        stop := true;
        if i>2 then
           newTgamma := [One(bbg)];
           Append(newTgamma, Tgamma{[i..p^e]});
           Append(newTgamma, Tgamma{[2..i-1]});
        else
           newTgamma := Tgamma;
        fi;
     else
        i := i+1;
     fi;
   until stop or (i=p^e+1);
   if not stop then
      return fail;
   fi;

   out:=rec(trangp:=newT,trangpgamma:=newTgamma);

   return(out);
end;


#############################################################################
##
#F SLSprog( <data>, <dim> )
##
## The output is a straight-line program to an element which
## is almost the identity matrix of dimension d, but
## upper left corner = rho^(-1), lower right corner = rho

SLSprog := function(data, d)
   local p,e,rho,               # as usual
         coeff1,coeff2,         # coefficients of field element
         i,                     # loop variable
         slp,                   # the output straight-line program
         len,seed;              # position in slp

   p := data.prime;
   e := data.power;
   rho := Z(p^e);
   # coeff1 sounds silly, but it is nontrivial information if e=1
   coeff1 := data.FB[ LogFFE(rho, rho) + 1];
   coeff2 := data.FB[ LogFFE(-rho^(-1), rho) + 1];
   slp := [];

   for i in [1..e] do
     if coeff1[i] > 0 then
        Add(slp, ["g", (d-1)*(d-2)*e + i]);
        seed := Length(slp);
        Append(slp, PowerofElmtProg(slp[seed],coeff1[i],seed));
        if seed > 1 then
           Add(slp, ["p", [seed - 1, Length(slp)] ]);
        fi;
     fi;
   od;
   len := Length(slp);
   # so far [[1,0],[rho,1]]

   for i in [1..e] do
     if coeff2[i] > 0 then
        Add(slp, ["g", (d-1)*(d-1)*e + i]);
        seed := Length(slp);
        Append(slp, PowerofElmtProg(slp[seed],coeff2[i],seed));
        if seed > 1 then
           Add(slp, ["p", [seed - 1, Length(slp)] ]);
        fi;
     fi;
   od;
   # so far [[1,-rho^(-1)],[rho,0]]

   Add(slp, ["p", [ Length(slp), len]]);
   # so far [[0,-rho^(-1)],[rho,0]]

   Add(slp, ["g", (d-1)*(d-2)*e + 1]);
   Add(slp, ["i", Length(slp)]);
   Add(slp, ["p", [ Length(slp)-2, Length(slp) ]]);
   # so far [[rho^(-1),-rho^(-1)],[rho,0]]

   Add(slp, ["g", (d-1)^2*e + 1]);
   Add(slp, ["p", [ Length(slp)-1, Length(slp) ]]);
   # so far [[rho^(-1),0],[rho,rho]]

   Add(slp, ["p", [ Length(slp), Length(slp)-3 ]]);
   # so far [[rho^(-1),0],[0,rho]]

   return slp;

end;


############################################################################
##
#F EqualPoints( <bbgroup> , <x> , <y> , <Qalpha> )
##
## The most commonly used application of this routine will be to decide
## whether $Q(alpha)^x=Q(alpha)^y$, but it can also be used to determine
## whether or not an element of G normalizes Q. Note that this test can
## be used in any dimension without specification; d=|Qalpha|+1.

EqualPoints:=function( bbg , x , y , Qalpha )
   local    g, len,  yinv, i;


   len:=Length( Qalpha );
   g :=  Qalpha[1]^x;
   yinv := y^(-1);

   for i in [1..len] do
      if not One(bbg) = Comm( g , yinv*Qalpha[i]*y ) then
         return false;
      fi;
   od;

   return true;
end;

############################################################################
##
#F IsOnAxis( <bbgroup> , <x> , <Qalpha> , <Q> )
##
## Tests whether the `point' $Q(alpha)^x$ `is on' the hyperplane $Q$.

IsOnAxis:=function( bbg , x , Qalpha , Q )
   local    g, len, i;


   len:=Length( Q );
   g := Qalpha[1]^x ;

   for i in [1..len] do

     if not One(bbg) = Comm( Comm(g,Q[i]), Q[i]) then
         return false;
     fi;

  od;

  return true;
end;

###########################################################################
##
#F IsInQ( <bbgroup> , <x> , <Q> )
##
## This is a simple test to see if a given element is in Q. It can also be
## used to test whether such is in a conjugate of Qa if needed.

IsInQ:=function( bbg , x , Q )
   return CommutesWith(bbg, Q, x);
end;

############################################################################
##
#F SLConjInQ( <bbg>, <y>, <Qgamma>, <Q>, <Tgamma>, <T>, <something>, <p>, <e> )
##
## Finds an element of Q conjugating $Q(gamma)$ to $Q(gamma)^y$ whenever
## these points are not on Q.
## Qgamma and Q are given by GF(q)-bases
## <something> is the concatenation of GF(p)-bases of the transvection
## groups in Q (if we are in 3.3, and no nice basis yet) or the conjugating
## element c (if we are after 3.4)
## we consider only the case conjugating Q(gamma) to somewhere

SLConjInQ:=function( bbg, y, Qgamma, Q, Tgamma, T, j, p, e )
   local       U,    # transvection group
             len,    # length of Q
         lengamma,   # length of Qgamma
      c,a0,z,b,u,    # transvections
            stop,    # loop command
            q,       # field size
            jj,      # a power of j (if applicable)
            conj,    # a power of $c$ (or $j$ in dim3)
               i,k;  # loop variables


   # handle trivial case
   if EqualPoints(bbg, One(bbg), y, Qgamma) then
      return One(bbg);
   fi;

   len:=Length( Q );
   lengamma := Length(Qgamma);
   q := p^e;
   a0:= Qgamma[1];;

   if not EqualPoints( bbg , y , y*a0 , Qgamma ) then

      b:= Qgamma[1]^y ;
      stop:=false;
      i:=1;
      repeat
         z:= b^Tgamma[i] ;
         if EqualPoints( bbg , One(bbg) , z , Q ) then
            if not IsInQ( bbg , z , Q ) then
               stop:=true;
            else
               b:= Qgamma[2]^y ;
               k:=1;
               repeat
                  z:= b^Tgamma[k] ;
                  if EqualPoints( bbg , One(bbg) , z , Q ) then
                     stop:=true;
                  fi;
                  k:=k + 1;
               until stop or (k=q+1);
               if not stop then
                  return fail;
               fi;
            fi;
         fi;
         i:=i + 1;
      until stop or (i=q+1);
      if not stop then
          return fail;
      fi;


   else # a0 normalizes Qgamma^y

      stop:=false;
      i:=1;
      repeat
         c:=Comm( a0 , Qgamma[i]^y );
         if not One(bbg) = c  then
            stop:=true;
         fi;
         i:=i + 1;
      until stop or (i=lengamma+1);
      if not stop then
          return fail;
      fi;

      stop:=false;
      i:=1;
      repeat
         z:= c * Tgamma[i] ;
         if EqualPoints( bbg , One(bbg) , z , Q ) then
            stop:=true;
         fi;
         i:=i + 1;
      until stop or (i=q+1);
      if not stop then
          return fail;
      fi;

   fi;

   stop:=false;
   i:=1;
   repeat
      if not One(bbg) = Comm( Q[i], z )  then
         stop:=true;
      fi;
      i:=i + 1;
   until stop or (i= len + 1);
   if not stop then
      return fail;
   fi;

   if not IsMultiplicativeElement(j)  then
   # we are at the construction of L
     U:= [ One(bbg) ];
     for k in [e*(i-2)+1 .. e*(i-1)] do
         AppendTran(bbg, U, j[k], p);
     od;
   else
   # j is a conjugating element
     jj := j^(i-2);
     U:= [ One(bbg) ];
     for k in [2..e+1] do
         AppendTran(bbg, U, T[k]^jj, p);
     od;
   fi;

   # in any case, U is the listing of the trans group in Q not commuting
   # with z

   stop:=false;
   i:=1;
   repeat
      u:= Comm(U[i],z);
      if EqualPoints( bbg , u , y , Qgamma ) then
         stop:=true;
      fi;
      i:=i + 1;
   until stop or (i=q+1);
   if not stop then
      return fail;
   fi;

   return u;
end;


############################################################################
#F SLLinearCombQ(<trangp>, <transv>, <c>, <dim>, <w>)
## <trangp> is the listed transvection group in <Q>
## t21, c as in section 3.4.1
## <w> is the vector to decompose
## to apply the routine in Qgamma, we need the inverse transpose of <transv>

SLLinearCombQ := function(T,t21,c,d,w)
   local cinv,      # the inverse of c
         wconj,     # conjugate of w
         copyw,     # used to find first coordinate
         cpower,    # power of c
         coord,     # a component of w
         i,k,stop,  # loop variables
         vec,       # output vector
         q,         # field size
         rho;       # generator of GF(q)^*

   cinv := c^(-1);
   q := Length(T);
   rho := Z(q);
   wconj := w;
   copyw := w;
   cpower := c;
   vec := [];
   for i in [2..d-1] do
      coord := Comm(wconj, t21);
      stop := false;
      k := 1;
      repeat
        if T[k] = coord then
           stop := true;
           if k = 1 then
              vec[i] := 0*rho;
           else
              vec[i] := rho^(k-2);
           fi;
        else
           k := k+1;
        fi;
      until stop or (k=q+1);
      if not stop then
         return fail;
      fi;
      # divide out component just found and get next component into position
      wconj := wconj * cinv * coord^(-1) * c;
      wconj := c * wconj * cinv;
      copyw := copyw * (coord^cpower)^(-1);
      cpower := cpower * c;
   od;

   # find the coordinate of the first component
   stop := false;
   k := 1;
   wconj := c * wconj * cinv;
   repeat
     if T[k] = copyw then
       stop := true;
       if k = 1 then
          vec[1] := 0*rho;
       else
          vec[1] := rho^(k-2);
       fi;
     else
       k := k+1;
     fi;
   until stop or (k=q+1);
   if not stop then
      return fail;
   fi;

   return vec;

end;


#########################################################################
##
#F SLRecWriteSLP ( <data structure for bbg>, <bbg element or matrix>, <dimension>
##         <input elm is in group to be recog'd>
##
## writes a straight-line program reaching the given element from the
## generators in the data structure

SLRecWriteSLP := function(data,x,d,isrecog)
   local p,e,q,bbg,    # as usual; q=p^e
         W,            # copy of x to modify
         leftslp,      #
         rightslp,     # the modifying slp's
         i,j,k,stop,   # loop variables
         seed,         # position in a slp
         sprog,        # element of data.sprog
         a,b,          # elements of GF(q)
         FB,           # list of coeff of linear combinations in GF(q)
         gens,         # generator list in data
         coeffs,       # an element of FB
         xinv,         # inverse of x
         Q,Qgamma,     # GF(q) basis for Q and Q(gamma)
         y,            # element of Qgamma
         u,            # generator of Q or One(bbg)
         vec,          # coordinate vector of an element of Q or Q(gamma)
         mat,          # matrix of the action on Q
         det,          # determinant of the action on Q
         exp,          # integer, which power of s is needed to make det=1
         slprog,       # slp to s^exp
         smat,         # the matrix of s^exp
         slp,          # slp to mat^(-1)
         W2,           # power of W
         gcd,          # Gcd(q-1,d)
         cent,         # generator of the centre of bbg
         centprog;     # an slp to cent


   p := data.prime;
   e := data.power;
   q := p^e;
   FB := data.FB;
   gens := data.gens;
   bbg := data.bbg;

   if not isrecog then
     if not (Determinant(x) = Z(q)^0) then
        return fail;
     fi;
     leftslp := [];
     rightslp := [];
     # in leftslp, we collect an slp for the INVERSE of the matrix
     # we multiply with from the left.
     # in rightslp we collect an slp for the right multiplier matrix

     W:= List(x, ShallowCopy);
     for i in [0..d-2] do
         # put non-zero element in lower right corner
         if W[d-i][d-i] = 0*Z(q) then
            j := First([1..d-i], a -> not (W[a][d-i] = 0*Z(q)));
            Add(leftslp,["g",(d-i-1)*(d-i-2)*e+(j-1)*e+1]);
            if Length(leftslp) > 1 then
              Add(leftslp,["p",[Length(leftslp) -1,Length(leftslp)]]);
            fi;
            for k in [1..d-i] do
              W[d-i][k] := W[d-i][k]- W[j][k];
            od;
         fi;
         # clear last column
         for j in [1..d-i-1] do
          if not W[j][d-i] = 0*Z(q) then
           # a is the nontriv element of the multiplying matrix
           a := -W[j][d-i]/W[d-i][d-i];
           # b is what we have to express as a linear combination
           # in the standard basis of GF(q)
           b := -a;
           coeffs := FB[LogFFE(b,Z(q))+1];
           for k in [1..e] do
             if coeffs[k] <> 0 then
               Add(leftslp, ["g", (d-i-1)^2*e + (j-1)*e + k]);
               seed := Length(leftslp);
               Append(leftslp, PowerofElmtProg(leftslp[seed], coeffs[k],seed));
               if seed > 1 then
                 Add(leftslp, ["p", [seed -1, Length(leftslp)]]);
               fi;
             fi;
           od;
           for k in [1..d-i] do
              W[j][k] := W[j][k] + a * W[d-i][k];
           od;
          fi; # W[j][d-i] = 0*Z(q);
         od;
         # clear last row
         for j in [1..d-i-1] do
          if not W[d-i][j] = 0*Z(q) then
           # a is the nontriv element of the multiplying matrix
           a := -W[d-i][j]/W[d-i][d-i];
           # no inverse is taken here
           coeffs := FB[LogFFE(a,Z(q))+1];
           for k in [1..e] do
             if coeffs[k] <> 0 then
               Add(rightslp, ["g", (d-i-1)*(d-i-2)*e + (j-1)*e + k]);
               seed := Length(rightslp);
            Append(rightslp, PowerofElmtProg(rightslp[seed], coeffs[k],seed));
               if seed > 1 then
                  Add(rightslp, ["p", [seed -1, Length(rightslp)]]);
               fi;
             fi;
           od;
           for k in [1..d-i] do
              W[k][j] := W[k][j] + a * W[k][d-i];
           od;
          fi;
         od;
     od; # i-loop
     # now we have a diagonal matrix
     for i in [0 .. d-2] do
        if not W[d-i][d-i] = Z(q)^0 then
           k := LogFFE(W[d-i][d-i], Z(q));
           sprog := PowerProg(data.sprog[d-i],k);
           leftslp := ProdProg(leftslp, sprog);
        fi;
     od;
     if Length(rightslp) > 0 then
        Add(rightslp, ["i", Length(rightslp)]);
     fi;

     return ProdProg(leftslp,rightslp);

   else # we have a bbg element

     rightslp := [];
     xinv := x^(-1);
     Q := List([1..d-1], j -> gens[(d-1)*(d-2)*e + (j-1)*e +1][1]);
     Qgamma := List([1..d-1], j -> gens[(d-1)^2*e + (j-1)*e +1][1]);

     # first modify x to normalize Q
     if not ForAll(Q, j -> IsInQ(bbg, xinv*j*x, Q)) then
        i := 1;
        stop := false;
        repeat
          if not IsOnAxis(bbg, Q[i]^(-1)*xinv, Qgamma, Q) then
             stop := true;
             Add(rightslp, ["g", (d-1)*(d-2)*e + (i-1)*e +1]);
             u := Q[i];
          else
             i := i+1;
          fi;
        until stop or i=d;
        if not stop then
          if not IsOnAxis(bbg, xinv, Qgamma, Q) then
             u := One(bbg);
          else
             return fail;
          fi;
        fi;

        # y will be in <Qgamma>, conjugating Q to Q^(x*u)
        # we apply SLConjInQ in the dual situation
        if d > 2 then
           y := SLConjInQ(bbg,x*u,Q,Qgamma,data.trangp[d-1],
                       data.trangpgamma[d-1],data.c[d-1],p,e);
        else
           k := 1;
           stop := false;
           repeat
             if EqualPoints(bbg,data.trangpgamma[1][k],x*u,Q)
                    then
                stop := true;
             else
                k := k+1;
             fi;
           until stop or k=q+1;
           if stop then
              y := data.trangpgamma[1][k];
           else
              y := fail;
           fi;
        fi;
        if y = fail then
          return fail;
        fi;

        # x*u*y^(-1) normalizes Q
        vec := SLLinearCombQ(data.trangpgamma[d-1],data.t21invtran,
                             data.c[d-1],d,y^(-1));
        if vec = fail then
           return fail;
        fi;
        for j in [1..d-1] do
          if not (vec[j] = 0*Z(q)) then
             coeffs := FB[LogFFE(vec[j],Z(q))+1];
             for k in [1..e] do
               if coeffs[k] <> 0 then
                 Add(rightslp, ["g", (d-1)^2*e + (j-1)*e + k]);
                 seed := Length(rightslp);
             Append(rightslp, PowerofElmtProg(rightslp[seed], coeffs[k],seed));
                 if seed > 1 then
                   Add(rightslp, ["p", [seed -1, Length(rightslp)]]);
                 fi;
               fi;
             od;
          fi;
        od;
        W := x * u * y^(-1);
     else
        W := x;
     fi; # if x does not normalize Q
     # compute the matrix for the action of W on Q
     mat := [];
     for j in [1..d-1] do
        vec := SLLinearCombQ(data.trangp[d-1],data.t21,data.c[d-1],d,Q[j]^W);
        if vec = fail then
           return fail;
        else
           Add(mat, vec);
        fi;
     od;
     det := Determinant(mat);
     if not (det = Z(q)^0) then
        gcd := Gcd(d,q-1);
        exp := (LogFFE(det, Z(q))/gcd) / (d/gcd) mod ((q-1)/gcd);
        slprog := PowerProg(data.sprog[d],exp);
        rightslp := ProdProg(rightslp, slprog);
        W := W * EvaluateBBGp(data,slprog);
        smat := Z(q)^(- exp)*IdentityMat(d-1,GF(q));
        smat[1][1] := Z(q)^(-2* exp);
        mat := mat * smat;
     fi;
     if d > 2 then
        slp := SLRecWriteSLP(data, mat^(-1), d-1,false);
        rightslp := ProdProg(rightslp, slp);
        W := W * EvaluateBBGp(data,slp);
     fi;
     # now W acts trivially on Q
     W2 := W^(-q);
     if not (One(bbg) = W2) then
        i := 1;
        stop := false;
        cent := data.centre;
        gcd := Gcd(q-1,d);
        repeat
          if W2 = cent then
             stop := true;
          else
             i := i+1;
             cent := cent * data.centre;
          fi;
        until stop or (i = gcd);
        if not stop then
           return fail;
        fi;
        centprog := PowerProg(data.centreprog,i);
        rightslp := ProdProg(rightslp, centprog);
        W := W * W2;
     fi;
     # now W is in Q
     vec := SLLinearCombQ(data.trangp[d-1],data.t21,data.c[d-1],d,W^(-1));
     if vec = fail then
        return fail;
     fi;
     for j in [1..d-1] do
        if not vec[j] = 0*Z(q) then
           coeffs := FB[LogFFE(vec[j],Z(q))+1];
           for k in [1..e] do
             if coeffs[k] <> 0 then
               Add(rightslp, ["g", (d-1)*(d-2)*e + (j-1)*e + k]);
               seed := Length(rightslp);
            Append(rightslp, PowerofElmtProg(rightslp[seed], coeffs[k],seed));
               if seed > 1 then
                  Add(rightslp, ["p", [seed -1, Length(rightslp)]]);
               fi;
             fi;
           od;
        fi;
     od;
     if Length(rightslp) > 0 then
        Add(rightslp, ["i", Length(rightslp)]);
     fi;

     return rightslp;

   fi; # IsMatrix( x )

end;



##############################################################################
##
#F SL2DataStructure( <bbg> , <prime> , <power> [ , <transv.grp> , <gen> ] )
##
## We now want to group these subroutines together in order to get the
## permutation domain of $G$ acting on 1-spaces. This information alone will
## allow us to compute the matrix image of an $x$ in bbg.

SL2DataStructure:=function( arg )
   local      bbg,      # the input group
               p,       # characteristic
               e,       # dimension of field
              data,     # the output
             data1,     # info on transvection and $s$
             data2,     # new $j$ and new $s$
             data3,     # Trangp and new gens ordered by $rho$
             s, s1,     # elts of order $q-1$
             j, j1,     # elts not normalizing $T$
                 t,     # starting transvection
                 T,     # initial trangp
                 i,     # loop variable
               rho,     # generator of GF(q)*
        fieldbasis,     # basis of GF(q)
       coeffmatrix,     # field elements expressed in fieldbasis
              cmat,     # 2x2 matrix
              cslp,     # straight-line program to cmat
              gens;     # the final generating set of transvections

   data:=rec();
   bbg := arg[1];
   p := arg[2];
   e := arg[3];

   if Length(arg) = 3 then
      # we suppose that p^e > 3
      data1:=SL2Search( bbg , p , e );
      if data1 = fail then
         return fail;
      fi;
      t:=data1.tran;
      s1:=data1.gen;

      T:=ConstructTranGroup( bbg , t , p , e);
      if T = fail then
         return fail;
      fi;

      j1:=Dislodge( bbg , T );
      if j1 = fail then
         return fail;
      fi;
   else
      # it is a recursive call and we already have T and j1
      T := arg[4];
      j1 := arg[5];
      if p^e > 3 then
         data1 := SL2Search( bbg , p , e , T[2]);
         if data1 = fail then
           return fail;
         fi;
         s1 := data1.gen;
      else
         s1 := One(bbg);
      fi;
      t := T[2];
   fi;

   data2:=Standardize( bbg , T , j1 , s1 );
   if data2 = fail then
      return fail;
   fi;

   j:=data2.conj;
   s:=data2.gen;

   data3:=SL2ReOrder( bbg , T , s , j , p , e );
   if data3 = fail then
      return fail;
   fi;

   data.bbg:=bbg;
   data.prime:=p;
   data.power:=e;

   rho:= Z(p^e);
   data.gens:=[];
   for i in [1..e] do
     data.gens[i] := [ data3.trangp[i+1], [[2,1,rho^(i-1)]] ];
     data.gens[e+i] := [ data3.trangpgamma[i+1], [[1,2,rho^(i-1)]] ];
   od;

   fieldbasis := Basis( GF(p^e), List([1..e], x -> rho^(x-1)) );
   coeffmatrix := [];
   for i in [1..p^e-1] do
      Add(coeffmatrix,IntVecFFE(Coefficients(fieldbasis, rho^(i-1))));
   od;
   data.FB := coeffmatrix;

   data.sprog := [];
   data.sprog[2] := SLSprog(data, 2);
   data.trangp := [];
   data.trangp[1] := data3.trangp;
   data.trangpgamma := [];
   data.trangpgamma[1] := data3.trangpgamma;

   if p=2 then
     data.centre := One(bbg);
     data.centreprog := [];
   else
     cslp := PowerProg(data.sprog[2], (p^e -1)/2);
     data.centre := EvaluateBBGp( data, cslp );
     if data.centre = One(bbg) then
        data.centreprog := [];
     else
        data.centreprog := cslp;
     fi;
   fi;

   # the following components will be used in recursion
   data.c := [];
   data.c[1] := One(bbg);
   data.cprog := [];
   data.cprog[1] := [];
   data.cprog[2] := [ ["g",1],["i",1],["g",e+1],["p",[2,3]],["p",[4,2]] ];
   data.c[2] :=(data.gens[1][1])^(-1)*data.gens[e+1][1]*(data.gens[1][1])^(-1);
   data.t21 := data.gens[1][1];
   data.t21invtran := data.t21^data.c[2];
   # in section 3.4.2, we need the inverse of the s computed here;
   # that's why it is called sinv
   data.sinv := EvaluateBBGp( data, data.sprog[2] );

   data.field:=GF(p^e);
   data.dimension:=2;
   data.matrixgroup:=SL(2,p^e);

   return(data);
end;





###############################################################################
##
#F SL3ConstructQ( <bbgroup> , <t> , <prime> , <power> )
##
## Now that we have a transvection, we wish to construct the group $Q$ of all
## transvections having the same centre or axis as $t$. In fact, we will be
## assuming that $Q$ is the latter. The output will consist of a record
## whose fields are
##     <tran> and <tran1> - GF(p) bases for two tran gps spanning $Q$
##           <conj>       - an elt of bbg interchanging the tran gps of $Q$
SL3ConstructQ:=function( bbg , t , pp , e )
   local      out,    #the output record
                p,    # the characteristic
             tinv,    # the inverse of t
               u,     #transvection
             cand,    #a candidate element of $Q$
                f,    #the first conjugating elt accepted
               u1,    # $t^f$
            t1new,    #transvections
               t1,    #
               i,     # number of random elements
               m,     # limit on iteration
               r,     #a random element of bbg
               T1,    #a listing of a transvection group
               S;     #a generating set for $Q$


   tinv := t^(-1);
   S:=[t];
   T1:=[ One( bbg ) ];
   # from QuickSL3DataStructure, we call with the value pp=-p, to distinguish
   # from the genuine input case. Reason: with reasonable probability,
   # QuickSL may have incorrect input, and we don't want to waste time here
   # to construct the non-existing T1. The tighter limit still has >96%
   # probability for success, if the input is correct.
   if pp < 0 then
      p := -pp;
      m := Int( (p^e+1)*(p^(2*e)+p^e+1)*4*e*p/((p-1)*2*p^(2*e)) );
   else
      p := pp;
      m := 8 * p^e * e;
   fi;

   i := 1;
   repeat
      r:=PseudoRandom(bbg);
      u:= t^r;
      cand:= tinv * (u^(-1)) * t * u;
      if not One(bbg)= cand  and CommutesWith( bbg , S , cand ) then
         if Length(S) = 1 then
            f := r;
            u1 := u;
            t1:= (u1^(-1)) * tinv * u1 * t;
            AppendTran( bbg , T1 , t1 , p );
            Add( S , t1 );
         else
            t1new:=Comm(u1 , cand );
            if not IsInTranGroup( bbg , T1 , t1new ) then
               AppendTran( bbg , T1 , t1new , p );
            fi;
         fi;
      fi;
      i := i+1;
   until  Length(T1) = p^e or i = m;
   if Length(T1) < p^e then
      return fail;
   fi;


   out:=rec( tran:=t , trangp1:=T1 , conj:=f );

   return( out );

end;

# So we now have a listing of T1, bases B and B1 for the tran groups T and T1,
# and the element f = conj.
#
#       $Q$                  <-------->              < B , B1 >
#   $Q(alpha)$               <-------->         < B , B1^(f^(-1)) >
# $Q(beta)$ = $Q(alpha)^f$   <-------->            < B^f , B1 >
#      $L$                   <-------->        < B^f , B1^(f^(-1)) >
#
# We now want to regard $L$ as a black box group in its own right, and make
# a recursive call to dimension 2. Note we don't need to compute everything
# in the data structure here, since we already have $t1$ so we don't need to
# compute a transvection. We don't have $s$, and we don't have $j$, but we do
# have the effect of conjugation by $j$, since we have B^f. Also, we have
# a complete listing of $T1^(f^(-1))$, which will be the eventual primary
# transvection group, so we don't need `ConstructTranGroup'. So we need to use
# a shortcut `SL2Search' to find $s$, we need `Standardize' and we need the
# full `SL2Reorder'.
# The truncated call to SL2DataStructure will take as input the (listed)
# principal transvection group (which will be T1^(f^(-1)), together with a
# tran of L not in T1^(f^(-1)) (this will be t^f)

#############################################################################
##
#F LDataStructure( <bbg> , <prime> , <power> , <trangp> , <t> )
##
## Here L = < T1^(f^(-1)) , t^f > is an SL(2,q).
## The output will be a reordered T, together with bases (with their matrix
## images) of T and T^j. We will also have straightline line programs to $s$
## normalizing T and T^j of order q-1 and to $j$.
## <trangp> will actually be T1^(f^(-1)), and <t> will be t^f.

LDataStructure:=function( bbg , p , e , T , x )
   local    gens,    # the generators for lbbg
            lbbg;    # the sub-bbg of bbg representing L

   gens:=Concatenation( List([1..e],y->T[p^(y-1)+1]) , [x] );
   lbbg:=SubgroupNC( bbg , gens );

   return( SL2DataStructure( lbbg , p , e , T , x ) );
end;

##########################################################################
##
#F ComputeGamma( <bbgroup> , <f> , <Q> , <trangp> )
##
## Note. This construction will only be used in dimension 3.
## Q, Qalpha are given by GF(q)-generators, trangp is listed,
## f is in the paper, section 3.6.3
## We construct an element 'test' which conjugates alpha to gamma.
## At this stage, we do not need a transvection to do the job.

ComputeGamma:=function( bbg , f , Q , T )
   local   U, # GF(q)-generators for Q^f
           t, # our favorite transvection
           q, # field size
     stop, i, # loop variables
        test; #, # candidate for element conjugating alpha to gamma
#      target, # a transvection with center gamma
#      jgamma; # transvection conjugating alpha to gamma; output

   U:=List( Q , x -> x^f );
   t:=T[2];
   q := Length(T);

   i:=1;
   stop:=false;
   repeat
      test:=  (f^(-1)) * T[i] ;
      if One(bbg) = Comm( Comm( U[1], t^test) , U[1] )  and
         One(bbg) =  Comm( Comm( U[2], t^test ) , U[2] )  then
           stop:=true;
      fi;
      i:=i + 1;
   until stop or i > q;
   if not stop then
      return fail;
   fi;

return test;
end;



############################################################################
##
#F SLConstructBasisQ( <bbg>, <data>, <Q>, <Qgamma>, <dim>, <field size> )
##
## <data> is the data structure of L to construct straight-line programs

SLConstructBasisQ := function(bbg,data, Q, Qgamma, d, q)
   local t21,         # transvection in 3.4.1
         t21invtran,  # its inverse transpose
         c,           # as in 3.4.1
         baseQ,       # GF(q)-basis of Q
         baseQgamma,  # GF(q)-basis of Qgamma
         i,stop,      # loop variables
         s,           # as in 3.4.2
         sinv,        # the inverse of s
         T,           # first transvection group of Q
         Tgamma,      # first transvection group of Qgamma
         b1,          # first basis vector of Q
         b1prime;     # first basis vector of Qgamma

   t21 := data.t21;
   t21invtran := data.t21invtran;
   sinv := data.sinv;
   s := sinv^(-1);
   c := data.c[d-1];

   # find a nontrivial element of the first transvection group of Q
   stop := false;
   i := 1;
   repeat
     b1 := Comm(Q[i],t21);
     if not One(bbg) = b1 then
        stop := true;
     else
        i := i+1;
     fi;
   until stop or (i > Length(Q));
   if not stop then
      return fail;
   fi;

   # find a nontrivial element of the first transvection group of Qgamma
   stop := false;
   i := 1;
   repeat
     b1prime := Comm(Qgamma[i],t21invtran);
     if not One(bbg) = b1prime then
        stop := true;
     else
        i := i+1;
     fi;
   until stop or (i > Length(Qgamma));
   if not stop then
      return fail;
   fi;

   # list the transvection groups and bases
   T := [One(bbg),b1];
   for i in [3..q] do
       T[i] := sinv * T[i-1] * s;
   od;

   baseQ := [b1];
   for i in [2..d-1] do
      baseQ[i] := baseQ[i-1]^c;
   od;

   Tgamma := [One(bbg),b1prime];
   for i in [3..q] do
       Tgamma[i] := s * Tgamma[i-1] * sinv;
   od;

   baseQgamma := [b1prime];
   for i in [2..d-1] do
      baseQgamma[i] := baseQgamma[i-1]^c;
   od;

    return rec(trangpQ:=T, baseQ:=baseQ,
             baseQgamma:=baseQgamma,
             trangpQgamma:=Tgamma, conj:=c,
             lincombQ:=t21, lincombQgamma:=t21invtran);

end;



##########################################################################
##
#F SLLabelPoint( <bbg> , <h> , <basisrecord> , <prime> , <power> , <dim> )
##
## Given a group element <h> we wish to label the `point' corresponding to
## the group <Qgamma>^<h>, given the required info.
## <basisrecord> is the output of SLConstructBasisQ

SLLabelPoint:=function( bbg , h , data , p , e , d  )
   local  vec,      # the output label
          Q,        # GF(q)-basis for Q
          Qgamma,   # GF(q)-basis for Qgamma
          T,        # transvection group in Q
          Tgamma,   # transvection group in Qgamma
          t21,      # transvection needed for linear combinations
          c,        # conjugating element needed for linear combinations
          i,stop,   # loop variables
          w,        # an element of Q
          rho,      # generator of GF(q)
          a;        # generator of Qgamma^y

   rho:=PrimitiveRoot( GF( p^e ) );
   Q := data.baseQ;
   Qgamma := data.baseQgamma;
   T := data.trangpQ;
   Tgamma := data.trangpQgamma;
   c := data.conj;
   t21 := data.lincombQ;


   if EqualPoints( bbg , One(bbg) , h , Qgamma ) then
      vec:=[];
      for i in [1..d-1] do
         vec[i]:=0*rho;
      od;
      vec[d]:=rho^0;

   elif not IsOnAxis( bbg , h , Qgamma , Q ) then
      w:=SLConjInQ( bbg, h, Qgamma, Q, Tgamma, T, c, p, e );
      if w = fail then
         return fail;
      fi;
      vec:=SLLinearCombQ( T, t21, c, d, w );
      if vec = fail then
         return fail;
      fi;
      vec[d]:=rho^0;

   else # label an element of Q
      stop:=false;
      i:=1;
      repeat
         a:= Qgamma[i]^h ;
         if not One(bbg) = Comm(  a , Q[1] ) then
            w:=Comm(  a , Q[1] );
            stop:=true;
         elif not One(bbg) = Comm( a , Q[2] )  then
            w:=Comm( a , Q[2] );
            stop:=true;
         fi;
         i:=i + 1;
      until stop or (i=d);
      if not stop then
         return fail;
      fi;
      vec:=SLLinearCombQ( T, t21, c, d, w );
      if vec = fail then
         return fail;
      fi;
      vec[d]:=0*rho;

   fi;
   return vec;

end;


##########################################################################
##
#F SLConstructGammaTransv( <bbgrp>, <transv grp>, <point> )
##
## Given the transvection group T and and a basis for Q(gamma)
## find a transvection conjugating T into Q(gamma)

SLConstructGammaTransv := function( bbg, T, Qgamma )
  local q, i, stop, jgamma;

   q := Length(T);
   # T^Qgamma[1] has an element conjugating alpha to gamma
   i := 2;
   stop := false;
   repeat
     jgamma := T[i]^Qgamma[1];
     if EqualPoints( bbg, T[2]^jgamma, One(bbg), Qgamma ) then
         stop := true;
     fi;
     i := i + 1;
   until stop or (i = q+1);
   if not stop then
      return fail;
   fi;

   return jgamma;

end;


###########################################################################
##
#F SLExchangeL(<data>, <GF(q) basis>, <GF(q) basis>, <GF(p) basis>, <dim> )
##
## After recursion, we have to choose between Llambda and its inverse
## transpose. In fact, we shall exchange Q and Qgamma

SLExchangeL := function(data, Q, Qgamma, pQ, d)
   local i,j,stop,         # loop variables
         p,e,q,            # as usual
         bbg,              # the black box group we deal with
         t21,t21invtran,   # the transvections stored in data
         b1,b1prime,       # the output transvections in groups of Q and Qgamma
#         mat,              # matrix to be pulled back
         trangp,           # a listed transvection group of Q
         t31,              # the preimage of mat
         comm,             # an element of trangp
         temp;             # temporary to help exchange Q and Qgamma

   bbg := data.bbg;
   t21 := data.t21;
   t21invtran := data.t21invtran;
   p := data.prime;
   e := data.power;
   q := p^e;

   # find a nontrivial element of the first transvection group of Q
   stop := false;
   i := 1;
   repeat
     b1 := Comm(Q[i],t21);
     if not One(bbg) = b1 then
        stop := true;
     else
        i := i+1;
     fi;
   until stop or (i > Length(Q));
   if not stop then
      return fail;
   fi;

   # construct the transvection subgroup of Q containing b1
   j := 1;
   trangp := [One(bbg)];
   repeat
     comm := Comm( pQ[(i-1)*e+j], t21 );
     if not IsInTranGroup(bbg, trangp, comm) then
        AppendTran(bbg, trangp, comm, p);
     fi;
     j := j+1;
   until Length(trangp) = q or j>e;
   if Length(trangp) < q then
      return fail;
   fi;

   t31 := data.gens[2*e+1][1];
   if not ForAll(Q, x->IsInTranGroup( bbg, trangp, Comm(x,t31) ) ) then
      temp := Q;
      Q := Qgamma;
      Qgamma := temp;
   fi;

   return [Q,Qgamma];

end;


#########################################################################
##
#F AttachSLNewgens( <SLdatastr>, <basisrecord>, <dim>, <jgamma> )
##
## Attaches (bboxgenerator,matrix) pairs to the list obtained from
## recursion. No output, only the side effect on the input generator list.
## <SLdatastr> is the record of SL, <basisrecord> is the output of
## SLConstructBasisQ

AttachSLNewgens := function(data, data3, d, jgamma)
   local e, rho,      # as usual
         i,j,         # loop variables
         conj,        # power of c, c as in 3.4.1
         vec,         # label of a point
           a,         # exponent in a power of rho
         newTgamma;   # re-listing of Tgamma

   # We wish to keep the same format as SL2DataStructure. We attach
   # GF(p)-generators for Q, then for Qgamma.
   # From the matrices, we store only the unique nondiagonal, nonzero entry
   # and its position.
   # <data> is the main data structure; <data3> is the output of
   # SLConstructBasisQ .

   e := data.power;
   rho := Z(data.prime^e);
   conj := One(data.bbg);
   vec := SLLabelPoint( data.bbg, jgamma^(-1)*data3.trangpQgamma[2],
                           data3, data.prime, e, d  );
   if vec = fail or (vec[1]=0*rho) then
       return;
   fi;
   a := LogFFE(vec[1],rho);
   if a > 0 then
      newTgamma := [One(data.bbg)];
      Append(newTgamma, data3.trangpQgamma{[a+2..data.prime^e]});
      Append(newTgamma, data3.trangpQgamma{[2..a+1]});
      data3.trangpQgamma := newTgamma;
   fi;

   for j in [1..d-1] do
     for i in [1..e] do
       data.gens[(d-1)*(d-2)*e+(j-1)*e+i] :=
           [ data3.trangpQ[i+1]^conj, [[d, j, rho^(i-1)]] ];
       data.gens[(d-1)^2*e+(j-1)*e+i] :=
           [ data3.trangpQgamma[i+1]^conj, [[j, d, rho^(i-1)]] ];
     od;
     conj := conj*data.c[d-1];
   od;

end;


###########################################################################
##
#F SLFinishConstruction( <bbgroup>, <data>, <basisrecord>, <dim> )
##
## last steps of the SL data structure construction
## <data> is the data structure already constructed,
## <basisrecord> is the output of SLConstructBasisQ

SLFinishConstruction := function(bbg, data2, data3, d)
   local  p,e,q,      # as usual
          jgamma,     # transvection conjugating alpha to gamma
          cprog,      # straight-line program used for constructing c in 3.4.1
          mat,        # matrix used for constructing c in 3.4.1
          gcd,        # Gcd(q-1,d)
          centgen,    # generator of center of bbg in matrix form
          centslp;    # a straight-line program to centgen

   p := data2.prime;
   e := data2.power;
   q := p^e;

   # we construct a transvection for jgamma
   jgamma := SLConstructGammaTransv( bbg, data3.trangpQ, data3.baseQgamma );
   if jgamma = fail then
      return fail;
   fi;

   AttachSLNewgens(data2, data3, d, jgamma);
   if Length(data2.gens) < d * (d-1) * e then
      Print("failed in Attach in dim=", d, "\n");
Error("attach");

      return fail;
   fi;

   data2.bbg := bbg;
   data2.sprog[d] := SLSprog(data2, d);
   mat := IdentityMat(d, GF(q));
   mat[1][1] := 0 * Z(q);
   mat[d][d] := 0 * Z(q);
   mat[1][d] := (-1)^d*Z(q)^0;
   mat[d][1] := (-1)^(d-1)*Z(q)^0;;
   cprog := SLRecWriteSLP(data2,mat,d,false);
   data2.cprog[d] := ProdProg(data2.cprog[d-1], cprog);
   data2.c[d] := data2.c[d-1] * EvaluateBBGp(data2,cprog);
   data2.trangp[d-1] := data3.trangpQ;
   data2.trangpgamma[d-1] := data3.trangpQgamma;

   gcd := Gcd(q-1,d);
   if gcd = 1 then
      data2.centre := One(bbg);
      data2.centreprog := [];
   else
      centgen := Z(q)^( (q-1)/gcd ) * IdentityMat(d, GF(q));
      centslp := SLRecWriteSLP(data2, centgen, d,false);
      data2.centre := EvaluateBBGp(data2,centslp);
      if data2.centre = One(bbg) then
         data2.centreprog := [];
      else
         data2.centreprog := centslp;
      fi;
   fi;


   return data2;
end;


##########################################################################
##
#F SL3DataStructure( <bbgroup> , <prime> , <power> )
##
## Gather together all of the necessary information.

SL3DataStructure:=function( bbg , p , e )
   local r,          # random element of bbg
         t,          # the transvection in r
         rho,        # generator of the field
         data1,      # data structure for generators of Q
         T1,         # a transvection group in Q
         t1,         # element of T1
         t1inv,      # inverse of t1
         f,          # element of bbg (as in 3.6.3)
         finv,       # inverse of f
         T1finv,     # T1^(finv)
         T,          # the transvection group in Q containing t
         jgamma,     # element of bbg (as in 3.6.3)
         Qgamma,     # GF(q)-basis for Qgamma
         data2,      # data structure for L
         data3,      # data structure for basis of Q,Qgamma
         mat,        # image matrix
         cprog,      # straigth-line program to c in 3.4.1
         i;          # loop variable

   rho := Z(p^e);
   r:=FindGoodElement( bbg , p , e , 3 , 14*p^e);
   if r=fail then
Print("FindGoodElement could not find r \n");
      return( fail );
   fi;

   t:= r^(p^e -1);

   data1:=SL3ConstructQ( bbg , t , p , e );
   if data1=fail then
      return( fail );
   fi;
   T1:=data1.trangp1;
   # T1 was listed by AppendTran => generators in positions p^i + 1
   t1 := T1[2];
   t1inv := t1^(-1);
   f:=data1.conj;
   finv := f^(-1);
   T1finv := List( T1 , x-> f*x*finv);
   T := List( T1finv, x -> x^(-1) * t1inv * x * t1 );
   jgamma:=ComputeGamma( bbg , f , [t,t1] , T );
   if jgamma = fail then
      return fail;
   fi;

   data2:=LDataStructure( bbg , p , e , T1finv , t^f );
   if data2 = fail then
      return fail;
   fi;
   Qgamma := [t^jgamma];
   Add(Qgamma, Qgamma[1]^data2.c[2]);

   data3:=SLConstructBasisQ( bbg, data2, [t,t1], Qgamma, 3, p^e );

   data2 := SLFinishConstruction(bbg,data2,data3,3);

   data2.field:=GF(p^e);
   data2.dimension:=3;
   data2.matrixgroup:=SL(3,p^e);

   return data2;

end;


##########################################################################
##
#F QuickSL3DataStructure( <bbgroup> , <prime> , <power> )
##
## info needed in section 3.2.2

QuickSL3DataStructure:=function( bbg , p , e )
   local data,       # bbg record in case p^e=2
         r,          # random element of bbg
         t,          # the transvection in r
         data1,      # data structure for generators of Q
         T1,         # a transvection group in Q
         t1,         # element of T1
         t1inv,      # inverse of t1
         f,          # element of bbg (as in 3.6.3)
         finv,       # inverse of f
         T1finv,     # T1^(finv)
         T,          # the transvection group in Q containing t
         jgamma,     # element of bbg (as in 3.6.3)
         B,          # basis for T
         B1,         # basis for T1
         B1finv;     # basis for T1finv

   t:= GeneratorsOfGroup(bbg)[1];

   data1:=SL3ConstructQ( bbg , t , -p , e );
   # We call SL3ConstructQ with a negative value so that routine knows
   # that the call is from here and not from SL3DataStructure.
   if data1=fail then
      return( fail );
   fi;

   T1:=data1.trangp1;
   # T1 was listed by AppendTran => generators in positions p^i + 1
   t1 := T1[2];
   t1inv := t1^(-1);
   f:=data1.conj;
   finv := f^(-1);
   T1finv := List( T1 , x-> f*x*finv);
   T := List( T1finv, x -> x^(-1) * t1inv * x * t1 );
   jgamma:=ComputeGamma( bbg , f , [t,t1] , T );
   if jgamma = fail then
      return fail;
   fi;

   B := List([1..e], x -> T[p^(x-1) +1]);
   B1 := List([1..e], x -> T1[p^(x-1) +1]);
   B1finv := List([1..e], x -> T1finv[p^(x-1) +1]);

   return rec( T:=T,T1 := T1,B:=B,B1:=B1,B1finv:=B1finv,
               jgamma:=jgamma,Lgen:=B[1]^f );

end;


###########################################################################
## SLFindGenerators(<bbg>,<J data str.>,<random elmt>,<prime>,<power>,<dim>)
##
## given J as in sec. 3.2.2, we create generators for L, Q, Qgamma

SLFindGenerators := function(bbg, data1, r, p, e, d)
local   i,j,stop,   # loop variables
        q,          # p^e
        limit,      # number of iterations
        tau,        # r^p
        tauinv,     # inverse of tau
        jgamma,     # conjugating element in data1
        jgammainv,  # its inverse
        qalpha,     # element of GF(q)-basis for Qalpha
        Q,          # GF(q)-basis for Q
        pQ,         # GF(p)-generators for Q
        Lgen,       # generators for L
        Qgamma,     # GF(q)-basis for Qgamma
        pQalpha,    # GF(p)-generators for Qalpha
        Tgamma,     # listing of first transvection group of Qgamma
        u;          # element of Q modifying generators for L

   q := p^e;
   tau := r^p;
   tauinv := tau^(-1);
   jgamma := data1.jgamma;
   jgammainv := jgamma^(-1);
   Q := [ data1.B[1], data1.B1[1] ];
   Qgamma := [ jgammainv*data1.B[1]*jgamma, jgammainv*data1.B1finv[1]*jgamma ];
   qalpha := data1.B1finv[1];
   pQ := Concatenation ( data1.B, data1.B1 );
   pQalpha := Concatenation( data1.B, data1.B1finv );
   Lgen := [data1.Lgen];
   if (d mod 2 =0) then
      limit := d-2;
   else
     if q=2 then
        limit := d+1;
     else
        limit := d-1;
     fi;
   fi;
   for i in [2..limit] do
       Q[i+1] := tauinv*Q[i]*tau;
       qalpha := tauinv * qalpha * tau;
       Qgamma[i+1] :=  jgammainv * qalpha * jgamma;
       Lgen[i] := Lgen[i-1]^tau;
       for j in [1..e] do
           Add(pQ, tauinv*pQ[(i-1)*e+j]*tau);
           Add(pQalpha, pQalpha[ (i-1)*e+j]^tau);
       od;
   od;
   # H as in 3.3.1 is generated by pQ and Lgen and pQalpha
   # LQ/Q is generated by Lgen and all but first e elements of pQalpha

   Tgamma := [ One(bbg) ];
   for i in [1..e] do
       AppendTran(bbg, Tgamma, jgammainv * pQalpha[i] * jgamma, p);
   od;

   for i in [e+1 .. Length(pQalpha)] do
     j := 1;
     stop := false;
     repeat
       if EqualPoints(bbg, pQalpha[i], data1.T[j], Qgamma) then
          u := data1.T[j];
          stop := true;
       else
          j := j+1;
       fi;
     until stop or j=q+1;
     if not stop then
Print(" failed modifying L \n");
        return fail;
     else
        pQalpha[i] := pQalpha[i] * u^(-1) ;
     fi;
   od;

   for i in [1..Length(Lgen)] do
     u := SLConjInQ(bbg, Lgen[i], Qgamma, Q, Tgamma, data1.T, pQ, p, e);
     if u = fail then
Print(" failed modifying L,2 \n");
        return fail;
     else
        Lgen[i] := Lgen[i] * u^(-1) ;
     fi;
   od;

   # we conjugate the L-generators in pQalpha so that PseudoRandom
   # does not get an input overwhelmingly in a small subgroup
   for i in [1..limit] do
     for j in [1..e] do
        Add(Lgen, pQalpha[i*e+j]^Lgen[i]);
     od;
   od;

   return rec(Lgen:=Lgen,Q:=Q,Qgamma:=Qgamma,pQ:=pQ);

end;



#########################################################################
##
#F SLDataStructure( <bbg>, <prime>, <power>, <dim>
##
## Main function to compute constructive isomorphism

SLDataStructure := function( bbg, p, e, d )
local   i,j,stop,   # loop variables
        q,          # field size
        r,          # random element of bbg
        t,          # transvection in r
        u1,u2,      # random conjugates of t
        sl3,        # alleged subgroup \cong SL(3,q)
        data1,      # output from sl3
        Q,          # GF(q)-basis for Q
        pQ,         # GF(p)-generators for Q
        Lgen,       # generators for L
        Qgamma,     # GF(q)-basis for Qgamma
        genrec,     # record containing generators for L,Q,Qgamma
        L,          # subgroup \cong SL(d-1,q)
        data2,      # data structure for L
        vectors,    # list containing Q and Qgamma
        data3;      # output of SLConstructQ

Print("with ", d, "\n");
   if d=2 then
     return SL2DataStructure( bbg, p, e );
   fi;

   if d=3 then
     return SL3DataStructure( bbg, p, e );
   fi;

   # start general case
   q := p^e;

   if d=4 and (q in [2,3,5,9,17]) then
      # We cannot guarantee that the p-part of the random r is a transvection.
      # The probability for that is at least 2/3, so going back to
      # FindGoodElement 8 times ensures success w/ prob > 1-1/2^8, since with
      # good input, we have success with prob well above 3/4.
      # We work with a tighter limit on the number of triples tried, so
      # we do not waste too much time in case of a bad $r$.
      j := 1;
      stop := false;
      repeat
        r:=SL4FindGoodElement( bbg , p , e , 30*q );
        if r = fail then
           j := j+1;
        else
           i := 1;
           t:= r^(p^(e*(d-2)) -1);
           repeat
              u1 := t^PseudoRandom(bbg);
              if (not (Comm(t,u1)^p=One(bbg))) then
                 u2 := t^PseudoRandom(bbg);
                 sl3 := SubgroupNC(bbg,[t,u1,u2]);
                 data1 := QuickSL3DataStructure( sl3, p, e );
                 if not data1 = fail then
Print("constructed L with j=",j,"   i=",i,"  limit=",Int(2*(1- 1/q)^(-5)),"\n");
                    stop := true;
                 fi;
              else
                 i := i+1;
              fi;
           until stop or i > 2 * (1- 1/q)^(-5);
           if not stop then
              j := j+1;
           else
              genrec := SLFindGenerators(bbg,data1,r,p,e,d);
              if genrec = fail then
                 stop := false;
                 j := j+1;
              fi;
           fi;
        fi; # r = fail
      until stop or j=9;
      if not stop then
Print("could not construct L \n");
         return fail;
      fi;
   else # d>4 or q is not one of the bad values
      # now r is guaranteed to be a transvection, if bbg is really SL(d,q)
      if d>4 then
         r:=FindGoodElement( bbg , p , e , d , 4 * q * (d-2) * Log(d,2) );
      else
         r:=SL4FindGoodElement( bbg , p , e , 16 * q );
      fi;
      if r=fail then
Print("FindGoodElement could not find r \n");
         return( fail );
      fi;

      t:= r^(p^(e*(d-2)) -1);

      stop := false;
      i := 1;
      repeat
        u1 := t^PseudoRandom(bbg);
        if (not (Comm(t,u1)^p=One(bbg))) then
              u2 := t^PseudoRandom(bbg);
              sl3 := SubgroupNC(bbg,[t,u1,u2]);
              data1 := QuickSL3DataStructure( sl3, p, e );
              if not data1 = fail then
Print("constructed L with i=",i,"  limit=",Int((1- 1/q)^(-5)* Log(8*d^2,2)),"\n");
                 stop := true;
              fi;
        else
           i := i+1;
        fi;
      until stop or (i > (1- 1/q)^(-5) * Log(8*d^2,2));
      if not stop then
Print("could not construct L \n");
         return fail;
      fi;
      genrec := SLFindGenerators(bbg,data1,r,p,e,d);
      if genrec = fail then
         return fail;
      fi;

   fi; # d=4 and q in [2,3,5,9,17]

   Lgen := genrec.Lgen;
   Q := genrec.Q;
   Qgamma := genrec.Qgamma;
   pQ := genrec.pQ;

   L := SubgroupNC(bbg,Lgen);

   data2 := SLDataStructure(L, p, e, d-1);
   if data2 = fail then
      return fail;
   fi;

   vectors := SLExchangeL(data2, Q, Qgamma, pQ, d);
   if vectors = fail then
      return fail;
   fi;

   data3 := SLConstructBasisQ(bbg, data2, vectors[1], vectors[2], d, q);

   data2 := SLFinishConstruction(bbg,data2,data3,d);

   data2.field:=GF(p^e);
   data2.dimension:=d;
   data2.matrixgroup:=SL(d,p^e);

   return data2;

end;


InstallRecognitionMethod("L",# type: Linear
  ReturnTrue, # take any dimension
  ReturnTrue, # take any characteristic
  false, # no natural characteristic required
  false, # no natural rep required
function(G,type,recogdata)
local d, q, p, data, imgfun, prefun, gcd, hom, rou, ker;
  d:=type[2];
  q:=type[3];
  # recogdata is not yet used here
  p:=Factors(type[3]);
  data:=SLDataStructure(G,p[1],Length(p),d);
  if data=fail then return fail;fi;
  imgfun:=function(elm)
    local slp;
    slp:=SLRecWriteSLP(data,elm,d,false);
    return EvaluateBBGp(data,slp);
  end;
  prefun:=function(elm)
    local slp;
    slp:=SLRecWriteSLP(data,elm,d,true);
    return EvaluateMat(data,slp);
  end;

  gcd:=Gcd(d,q-1);
  if Order(data.centre)=gcd then
    # isomorphism
    hom:=GroupHomomorphismByFunction(data.matrixgroup,data.bbg,imgfun,prefun);
    SetIsBijective(hom,true);
  else
    # epimorphism
    hom:=GroupHomomorphismByFunction(data.matrixgroup,data.bbg,imgfun,
	  false,prefun);
    SetIsSurjective(hom,true);
    rou:=RootsOfUPol((X(GF(q))^gcd)-1);
    rou:=First(rou,i->not ForAny([1..gcd-1],j->IsOne(i^j)));
    ker:=Subgroup(data.matrixgroup,[IdentityMat(d,rou)*rou]);
    SetKernelOfMultiplicativeGeneralMapping(hom,ker);
  fi;
  return hom;
end);
