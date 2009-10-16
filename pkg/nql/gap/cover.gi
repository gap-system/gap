############################################################################
##
#W cover.gi 			NQL				René Hartung
##
#H   @(#)$Id: cover.gi,v 1.5 2009/05/06 12:54:47 gap Exp $
##
Revision.("nql/gap/cover_gi"):=
  "@(#)$Id: cover.gi,v 1.5 2009/05/06 12:54:47 gap Exp $";


############################################################################
##
#F  NQL_QSystemOfCoveringGroupByQSystem ( <col>, <weights>, <Defs>, <Imgs> )
## 
## computes a (possibly inconsistent) weighted nilpotent quotient system 
## for the covering group of <col>. 
##
InstallGlobalFunction( NQL_QSystemOfCoveringGroupByQSystem,
  function(pccol,weights,Defs,Imgs)
  local c,		# nilpotency class
	r,		# number of generators <pccol>
	n,		# counter for the tails
	orders,		# relative orders of <pccol>
	NewGens,	# total number of generators of the covering group
	i,j,		# loop variables
	ftl;		# Collector of the covering group
  
  # nilpotency class
  c:=Maximum(weights);
    
  # number of generator 
  r:=Length(weights);

  # number of generators for G/G'
  n:=Length(Filtered(weights,x->x=1));

  orders:=RelativeOrders(pccol);
  
  # determine the number of generators of the covering group:
  # number of new (pseudo-) generators coming from commutator relations
  NewGens:=((r-1)*(r)-(r-n-1)*(r-n))/2-r+n;

  # number of new pseudo-generators coming from power relations
  NewGens:=NewGens+Length(Filtered(orders,x->x<>0));

  # number of new pseudo-generators coming from the epimorphism
  NewGens:=NewGens+Length(Filtered(Imgs,IsList)); 
  
  ftl:=FromTheLeftCollector(r+NewGens);
  
  # counter for the tails
  n:=r+1;

  # new images
  for i in [1..Length(Imgs)] do
    if IsList(Imgs[i]) then 
      Imgs[i]:=Concatenation(Imgs[i],[n,1]);
      Add(weights,c+1);
      Add(Defs,i);
      n:=n+1;
    fi;
  od;
  
  # new power relations
  for i in Filtered([1..Length(orders)],x->orders[x]<>0) do
    SetRelativeOrder(ftl,i,orders[i]);
    SetPower(ftl,i,Concatenation(GetPower(pccol,i),[n,1]));
    Add(weights,c+1);
    Add(Defs,-i);
    n:=n+1;
  od;
  
  # new commutator relations which define pseudo-generators
  for i in Filtered([1..Length(orders)],x->weights[x]=1) do
    for j in Filtered([1..Length(orders)],x-> not [x,i] in Defs
                                       and weights[x]<c and x>i) do
      SetConjugate(ftl,j,i,Concatenation(GetConjugate(pccol,j,i),[n,1]));
      Add(weights,c+1);
      Add(Defs,[j,i]);
      n:=n+1;
    od;
  od; 
  
  # new commutator relations which define gens
  for i in Filtered([1..Length(orders)],x->weights[x]=1) do
    for j in Filtered([1..Length(orders)],x-> not [x,i] in Defs and
                                              weights[x]=c and x>i) do
      SetConjugate(ftl,j,i,Concatenation(GetConjugate(pccol,j,i),[n,1]));
      Add(weights,c+1);
      Add(Defs,[j,i]);
      n:=n+1;
    od;
  od; 
  
  if NQL_TEST_ALL then 
    if not n-1=NumberOfGenerators(ftl) then 
      Error("Number of new generators might be wrong");
    fi;
  fi;
  
  # set the definitions
  for i in [1..Length(Defs{Filtered([1..Length(Defs)], 
                                x->weights[x]<Maximum(weights))})] do 
    if IsList(Defs[i]) then 
      SetConjugate(ftl,Defs[i][1],Defs[i][2],
                       GetConjugate(pccol,Defs[i][1],Defs[i][2]));
    fi;
  od;
  
  # remaining relations (completed by the tails routine)
  for i in [1..Length(orders)-1] do
    for j in [i+1..Length(orders)] do
      if weights[i]>1 and weights[i]+weights[j]<c+1 then 
        SetConjugate(ftl,j,i,GetConjugate(pccol,j,i));
      fi;
      if orders[i]=0 then 
        SetConjugate(ftl,j,-i,GetConjugate(pccol,j,-i));
      fi;
      if orders[j]=0 then 
        SetConjugate(ftl,-j,i,GetConjugate(pccol,-j,i));
      fi;
      if orders[i]+orders[j]=0 then 
        SetConjugate(ftl,-j,-i,GetConjugate(pccol,-j,-i));
      fi;
    od;
  od;
  return(ftl);
  end);

############################################################################
##
#F  NQL_CoveringGroupByQSystem( <col>, <weights>, <Defs>, <Imgs> )
##
## computes a weighted nilpotent presentation for the covering group of
## <col>.
##
InstallGlobalFunction( NQL_CoveringGroupByQSystem,
  function(pccol,weights,Defs,Imgs)
  local c,		# nilpotency class
	r,		# number of generators <pccol>
	n,		# number of generators of G/G'
	orders,		# relative orders of <pccol>
	NewGens,	# total number of generators of the covering group
	i,j,		# loop variables
  	b,		# first generator of weight >1
	HNF,		# Hermite normal form
	ftl;		# Collector of the covering group
  
  
  # nilpotency class
  c:=Maximum(weights);
    
  # number of generator 
  r:=Length(weights);

  # number of generators for G/G'
  n:=Length(Filtered(weights,x->x=1));

  orders:=RelativeOrders(pccol);
  
  # determine the number of generators of the covering group:
  # number of new (pseudo-) generators coming from commutator relations
  NewGens:=((r-1)*(r)-(r-n-1)*(r-n))/2-r+n;

  # number of new pseudo-generators coming from power relations
  NewGens:=NewGens+Length(Filtered(orders,x->x<>0));

  n:=r+1;
  ftl:=FromTheLeftCollector(r+NewGens);

  # new power relations
  for i in Filtered([1..Length(orders)],x->orders[x]<>0) do
    SetRelativeOrder(ftl,i,orders[i]);
    SetPower(ftl,i,Concatenation(GetPower(pccol,i),[n,1]));
    Add(weights,c+1);
    Add(Defs,-i);
    n:=n+1;
  od;
  
  # new commutator relations which define pseudo-generators
  for i in Filtered([1..Length(orders)],x->weights[x]=1) do
    for j in Filtered([1..Length(orders)],x-> not [x,i] in Defs
                                       and weights[x]<c and x>i) do
      SetConjugate(ftl,j,i,Concatenation(GetConjugate(pccol,j,i),[n,1]));
      Add(weights,c+1);
      Add(Defs,[j,i]);
      n:=n+1;
    od;
  od; 
  
  # new commutator relations which define gens
  for i in Filtered([1..Length(orders)],x->weights[x]=1) do
    for j in Filtered([1..Length(orders)],x-> not [x,i] in Defs and
                                              weights[x]=c and x>i) do
      SetConjugate(ftl,j,i,Concatenation(GetConjugate(pccol,j,i),[n,1]));
      Add(weights,c+1);
      Add(Defs,[j,i]);
      n:=n+1;
    od;
  od; 
  
  if not n-1=NumberOfGenerators(ftl) then 
    Error("Number of new generators might be wrong");
  fi;
  
  # set the definitions
  for i in [1..Length(Defs{Filtered([1..Length(Defs)],
                                x->weights[x]<Maximum(weights))})] do
    if IsList(Defs[i]) then 
      SetConjugate(ftl,Defs[i][1],Defs[i][2],
                       GetConjugate(pccol,Defs[i][1],Defs[i][2]));
    fi;
  od;
  
  # remaining relations (completed by the tails routine)
  for i in [1..Length(orders)-1] do
    for j in [i+1..Length(orders)] do
      if weights[i]>1 and weights[i]+weights[j]<c+1 then 
        SetConjugate(ftl,j,i,GetConjugate(pccol,j,i));
      fi;
      if orders[i]=0 then 
        SetConjugate(ftl,j,-i,GetConjugate(pccol,j,-i));
      fi;
      if orders[j]=0 then 
        SetConjugate(ftl,-j,i,GetConjugate(pccol,-j,i));
      fi;
      if orders[i]+orders[j]=0 then 
        SetConjugate(ftl,-j,-i,GetConjugate(pccol,-j,-i));
      fi;
    od;
  od;

  # complete the nilpotent presentation using the tails routine
  UpdateNilpotentCollector(ftl,weights,Defs);

  # position of the first new (pseudo) generator/tail
  b:=Position(weights,Maximum(weights));

  # consistency relations (words in T)
  HNF := NQL_CheckConsistencyRelations(ftl,weights);
  for i in [1..Length(HNF.mat)] do
    if not IsZero(HNF.mat[i]{[1..b-1]}) then
      Error("NQL_CoveringGroupByQSystem: wrong HNF from consistency check");
    fi;
    # forget the first b-1 (zero) entries
    HNF.mat[i]:=HNF.mat[i]{[b..Length(weights)]};
    HNF.Heads[i]:=HNF.Heads[i]-b+1;
  od;
  
 
  if Length(HNF.mat)=0 then 
    if not IsConfluent(ftl) then 
      Error("Inconsistent although HNF is trivial");
    fi;
    return(PcpGroupByCollector(ftl));
  else
#BuildNewCollector
    return(ftl);
  fi;

  end);
