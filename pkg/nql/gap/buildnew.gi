############################################################################
##
#W  buildnew.gi			NQL				René Hartung
##
#H   @(#)$Id: buildnew.gi,v 1.6 2008/08/28 08:04:20 gap Exp $
##
Revision.("nql/gap/buildnew_gi"):=
  "@(#)$Id: buildnew.gi,v 1.6 2008/08/28 08:04:20 gap Exp $";


############################################################################
##
#F  NQL_BuildNewCollector ( )
##
## Builds a new collector with respect to the relations and the consistency
## relations for the covering group.
##
InstallGlobalFunction( NQL_BuildNewCollector,
  function(Q,ftl,HNF,weights,Defs,Imgs)
  local A,		# power relations with attention to the HNF
	orders,		# relative order of the 'old' collector
	Gens,		# new generators
	QS,		# new quotient system
	rhs,rhsTails,	# right hand side of the new relation
	i,j,k,		# loop variables
	c,		# nilpotency class
	b;		# position of the first (pseudo) generator/tail

  # nilpotency class
  c:=Maximum(weights);

  # first new generator/pseudo-generator
  b:=Position(weights,c);

  # relative orders of the old quotient system
  orders:=RelativeOrders(Q.Pccol);

  # power relations from Hermite normal form
  A:=NQL_PowerRelationsOfHNF(HNF);
  
  # find new generators in HNF
  Gens:=HNF.Heads{Filtered([1..Length(HNF.Heads)],
                           x->HNF.mat[x][HNF.Heads[x]]<>1)};
  Append(Gens, Filtered([1..Length(weights)-(b-1)],x->not x in HNF.Heads));
  Sort(Gens);
  
  if Length(Gens)=0 then 
    return(Q);
  fi;
   
  # new quotient system
  QS:=rec();
  QS.Lpres:=Q.Lpres;
  QS.Pccol:=FromTheLeftCollector(b-1+Length(Gens));

  # restore the new images
  QS.Imgs:=[];
  for i in [1..Length(Imgs)] do 
    if IsPosInt(Imgs[i]) then 
      QS.Imgs[i]:=Imgs[i];
    elif IsList(Imgs[i]) then 
      rhs:=ExponentsByObj(ftl,Imgs[i]);
      rhsTails:=rhs{[b..Length(rhs)]};
      rhs:=Concatenation(rhs{[1..b-1]}, NQL_RowReduce(rhsTails,HNF){Gens});
      QS.Imgs[i]:=ObjByExponents(QS.Pccol,rhs);
    else
      Error("Strange entry in Imgs");
    fi;
  od;

  # new definitions and new weights
  QS.Definitions:=Concatenation(Defs{[1..b-1]},  Defs{Gens+(b-1)});
  QS.Weights:=Concatenation(weights{[1..b-1]},weights{Gens+(b-1)});
  
  # set the old power relations
  for i in Filtered([1..Length(orders)],x-> orders[x]<>0) do 
    rhs:=ExponentsByObj(ftl,GetPower(ftl,i));
    rhsTails:=rhs{[b..Length(rhs)]};
    rhs:=Concatenation(rhs{[1..b-1]}, NQL_RowReduce(rhsTails,HNF){Gens});

    SetRelativeOrder(QS.Pccol,i,orders[i]);
    SetPower(QS.Pccol,i,ObjByExponents(QS.Pccol,rhs));
  od;

  # set conjugacy relations
  for i in [1..(b-1)-1] do
    for j in [i+1..b-1] do 
      # a_j a_i = a_i a_j u_ij^++
      rhs:=ExponentsByObj(ftl,GetConjugate(ftl,j,i));
      rhsTails:=rhs{[b..Length(rhs)]};
      if not IsZero(rhsTails) then 
        rhs:=Concatenation(rhs{[1..b-1]}, NQL_RowReduce(rhsTails,HNF){Gens});
      else
        rhs:=Concatenation(rhs{[1..b-1]},
                           ListWithIdenticalEntries(Length(Gens),0));
      fi;
      SetConjugate(QS.Pccol,j,i,ObjByExponents(QS.Pccol,rhs));

      if orders[i]=0 then 
        # a_j a_i^-1 = a_i^-1 a_j u_ij^-+
        rhs:=ExponentsByObj(ftl,GetConjugate(ftl,j,-i));
        rhsTails:=rhs{[b..Length(rhs)]};
        if not IsZero(rhsTails) then 
          rhs:=Concatenation(rhs{[1..b-1]}, NQL_RowReduce(rhsTails,HNF){Gens});
        else
          rhs:=Concatenation(rhs{[1..b-1]},
                             ListWithIdenticalEntries(Length(Gens),0));
        fi;
        SetConjugate(QS.Pccol,j,-i,ObjByExponents(QS.Pccol,rhs));

        if orders[j]=0 then 
          # a_j^-1 a_i^-1 = a_i^-1 a_j^-1 u_ij^--
          rhs:=ExponentsByObj(ftl,GetConjugate(ftl,-j,-i));
          rhsTails:=rhs{[b..Length(rhs)]};
          if not IsZero(rhsTails) then 
            rhs:=Concatenation(rhs{[1..b-1]}, NQL_RowReduce(rhsTails,HNF){Gens});
          else
            rhs:=Concatenation(rhs{[1..b-1]},
                               ListWithIdenticalEntries(Length(Gens),0));
          fi;
          SetConjugate(QS.Pccol,-j,-i,ObjByExponents(QS.Pccol,rhs));
        fi;
      elif orders[j]=0 then 
        # a_j^-1 a_i = a_i a_j^-1 u_ij^+-
        rhs:=ExponentsByObj(ftl,GetConjugate(ftl,-j,i));
        rhsTails:=rhs{[b..Length(rhs)]};
        if not IsZero(rhsTails) then 
          rhs:=Concatenation(rhs{[1..b-1]}, NQL_RowReduce(rhsTails,HNF){Gens});
        else
          rhs:=Concatenation(rhs{[1..b-1]},
                             ListWithIdenticalEntries(Length(Gens),0));
        fi;
        SetConjugate(QS.Pccol,-j,i,ObjByExponents(QS.Pccol,rhs));
      fi;
    od;
  od;

  # set the new power relations for the tails
  for i in Filtered([1..Length(HNF.Heads)],x->HNF.mat[x][HNF.Heads[x]]<>1) do
    k:=Position(Gens,HNF.Heads[i]);
    SetRelativeOrder(QS.Pccol,k+(b-1),HNF.mat[i][HNF.Heads[i]]);
    rhs:=ListWithIdenticalEntries(Length(weights)-(b-1),0);
    rhs[HNF.Heads[i]]:=HNF.mat[i][HNF.Heads[i]];
    rhs:=Concatenation(ListWithIdenticalEntries(b-1,0),
                       NQL_RowReduce(rhs,HNF){Gens});;
    SetPower(QS.Pccol,k+(b-1),ObjByExponents(QS.Pccol,rhs));
  od;

  FromTheLeftCollector_SetCommute(QS.Pccol);

  SetFeatureObj(QS.Pccol,IsUpToDatePolycyclicCollector,true);

  FromTheLeftCollector_CompleteConjugate(QS.Pccol); 
  FromTheLeftCollector_CompletePowers(QS.Pccol); 

  SetFeatureObj(QS.Pccol,IsUpToDatePolycyclicCollector,true);
# SetFeatureObj(QS.Pccol,UseLibraryCollector,true);

  if NQL_TEST_ALL then 
    if not IsConfluent(QS.Pccol) then
      Error("presentation is not confluent");
    fi;
  fi;
  
  # build the mapping QS.Epimorphism
  Imgs:=[];
  for i in [1..Length(QS.Imgs)] do
    if IsInt(QS.Imgs[i]) then 
      Add(Imgs,PcpElementByGenExpList(QS.Pccol,[QS.Imgs[i],1]));
    else
      Add(Imgs,PcpElementByGenExpList(QS.Pccol,QS.Imgs[i]));
    fi;
  od;
  QS.Epimorphism:=GroupHomomorphismByImagesNC(Q.Lpres, 
  			PcpGroupByCollectorNC(QS.Pccol),
   			GeneratorsOfGroup(Q.Lpres),Imgs);
  return(QS);
  end);
