############################################################################
##
#W tails.gi			NQL				René Hartung
##
#H   @(#)$Id: tails.gi,v 1.2 2008/08/28 08:04:20 gap Exp $
##
## based on Werner Nickel's "/pkg/nq/src/tails.c"
##
Revision.("nql/gap/tails_gi"):=
  "@(#)$Id: tails.gi,v 1.2 2008/08/28 08:04:20 gap Exp $";


############################################################################
## 
#F  NQL_Tails_lji ( <coll> , <Def of k> , <l> , <k>) 
##
## computes t_{kl}^{++}
##
InstallGlobalFunction( NQL_Tails_lji,
  function(coll,Defs,l,k)
  local ev1,ev2, 	# exponent vectors of the consistency relation
	i,j,		# definition of k as commutator [a_j,a_i]
	rhs;		# rhs of a_j^{a_i}
  
  j:=Defs[1];
  i:=Defs[2];
  
  # (l j) i
  repeat 
    repeat
      ev1:=ExponentsByObj(coll,[AbsInt(l),SignInt(l)]);
    until CollectWordOrFail(coll,ev1,[AbsInt(j),SignInt(j)])<>fail;
  until CollectWordOrFail(coll,ev1,[AbsInt(i),SignInt(i)])<>fail;
  
  # l (j i) = (l i) j^i 
  rhs:=GetConjugate(coll,j,i);
  repeat
    repeat
      ev2:=ExponentsByObj(coll,[AbsInt(l),SignInt(l)]);
    until CollectWordOrFail(coll,ev2,[AbsInt(i),SignInt(i)])<>fail;
  until CollectWordOrFail(coll,ev2,rhs)<>fail;
  
  return(ObjByExponents(coll,ev1-ev2));
  end);

############################################################################
## 
#F  NQL_Tails_lkk ( <coll> , <l> , <k>) 
##
## computes t_{kl}^{-+}
##
InstallGlobalFunction( NQL_Tails_lkk,
  function(coll,l,k)
  local ev1; 	# exponent vector

  repeat 
    repeat 
      ev1:=ExponentsByObj(coll,[AbsInt(l),SignInt(l)]);
    until CollectWordOrFail(coll,ev1,[AbsInt(k),SignInt(k)])<>fail;
  until CollectWordOrFail(coll,ev1,[AbsInt(k),-SignInt(k)])<>fail;
  
  if not ev1[AbsInt(l)]=1 then 
    Error("in NQL_Tails_lkk\n");
  fi;
  
  ev1[AbsInt(l)]:=0;
  
  return(Concatenation(GetConjugate(coll,l,k),ObjByExponents(coll,-ev1)));
  end);

############################################################################
##  
#F  NQL_Tails_llk ( <coll> , <l> , <k>)
##
## computes t_{kl}^{+-} AND t_{kl}^{--}
##
InstallGlobalFunction( NQL_Tails_llk,
  function(coll,l,k)
  local ev1,	# exponent vector
	rhs;	# rhs of the relation a_l^{a_k}
  
  rhs:=GetConjugate(coll,AbsInt(l),k);
  repeat 
    repeat 
      ev1:=ExponentsByObj(coll,[AbsInt(l),-1]);
    until CollectWordOrFail(coll,ev1,[AbsInt(k),SignInt(k)])<>fail;
  until CollectWordOrFail(coll,ev1,rhs)<>fail;
  
  if not ev1[AbsInt(k)]=SignInt(k) then
    Error("in NQL_Tails_llk\n");
  fi;
  
  ev1[AbsInt(k)]:=0;
  return(Concatenation(GetConjugate(coll,l,k),ObjByExponents(coll,-ev1)));
  end);

############################################################################
##
#M  UpdateNilpotentCollector( <coll>, <weights>, <defs> ) 
##
## completes the (weighted) nilpotent presentation <coll> using the tails
## routine
##
InstallMethod( UpdateNilpotentCollector,
  "for a weighted nilpotent presentation",
  true,
  [ IsFromTheLeftCollectorRep, IsList, IsList ], 0,
  function(coll,weights,Defs)
  local rhs,		# rhs of the relations
	orders,		# relative order of <coll>
	i,j,k,a,b,	# loop variables
	c;		# nilpotency class

  # relative order of <coll>
  orders:=RelativeOrders(coll);

  # nilpotency class
  c:=Maximum(weights);
  
  if NQL_TEST_ALL then 
    for i in [1..Length(orders)-1] do 
      for k in [i+1..Length(orders)] do 
        if not GetConjugate(coll,k,i){[1,2]}=[k,1] then 
          Error("no nilpotent presentation (input)");
        fi;
      od;
    od;
  fi;
  
  FromTheLeftCollector_SetCommute(coll);
  SetFeatureObj(coll, IsUpToDatePolycyclicCollector,true);
# SetFeatureObj(coll, UseLibraryCollector,true);
  FromTheLeftCollector_CompletePowers(coll);
  
  # conjugates
  b:=c;
  while b>1 do
    for i in [1..Length(weights)-1] do
      for j in [i+1..Length(weights)] do 
        if weights[i]+weights[j]=b then 
          if not weights[i]=1 then
            rhs:=NQL_Tails_lji(coll,Defs[i],j,i);
            for a in [1,3..Length(rhs)-1] do
              if orders[rhs[a]]<>0 and rhs[a+1]<0 then 
                if not GetPower(coll,a)=[] then 
                  Error("rhs not trivial at tails.g");
                else
                  rhs[a+1]:=rhs[a+1] mod orders[rhs[a]];
                fi;
              fi;
            od;
            rhs:=Concatenation(GetConjugate(coll,j,i),rhs);
            if NQL_TEST_ALL then 
              if not rhs{[1,2]}=[j,1] then 
                Error("no nilpotent presentation j i");
              fi;
            fi;
            SetConjugateNC(coll,j,i,rhs);
            SetFeatureObj(coll,IsUpToDatePolycyclicCollector,true);
            FromTheLeftCollector_SetCommute(coll);
          fi;
          if orders[i]=0 then 
            repeat
              rhs:=ListWithIdenticalEntries(Length(weights),0);
            until CollectWordOrFail(coll,rhs,NQL_Tails_lkk(coll,j,-i))<>fail;
            rhs:=ObjByExponents(coll,rhs);
            if NQL_TEST_ALL then 
              if not rhs{[1,2]}=[j,1] then 
                Error("no nilpotent presentation j -i");
              fi;
            fi;
            SetConjugateNC(coll,j,-i,rhs);
            SetFeatureObj(coll,IsUpToDatePolycyclicCollector,true);
          fi;
          if orders[j]=0 then  
            repeat
              rhs:=ListWithIdenticalEntries(Length(weights),0);
            until CollectWordOrFail(coll,rhs,NQL_Tails_llk(coll,-j,i))<>fail;
            rhs:=ObjByExponents(coll,rhs);
            if NQL_TEST_ALL then
              if not rhs{[1,2]}=[j,-1] then 
                Error("no nilpotent presentation -j i");
              fi;
            fi;
            SetConjugateNC(coll,-j,i,rhs);
            SetFeatureObj(coll,IsUpToDatePolycyclicCollector,true);
          fi;
          if orders[i]+orders[j]=0 then
            repeat
              rhs:=ListWithIdenticalEntries(Length(weights),0);
            until CollectWordOrFail(coll,rhs,NQL_Tails_llk(coll,-j,-i))<>fail;
            rhs:=ObjByExponents(coll,rhs);
            if NQL_TEST_ALL then
              if not rhs{[1,2]}=[j,-1] then 
                Error("no nilpotent presentation -j -i");
              fi;
            fi;
            SetConjugateNC(coll,-j,-i,rhs);
            SetFeatureObj(coll,IsUpToDatePolycyclicCollector,true);
          fi;
        elif weights[i]+weights[j]>b then 
          break;
        fi;
      od; 
    od; 
   
    b:=b-1;
  od;
  
  end);
