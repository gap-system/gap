############################################################################
##
#W extqs.gi			NQL				René Hartung
##
#H   @(#)$Id: extqs.gi,v 1.7 2009/07/02 12:34:34 gap Exp $
##
Revision.("nql/gap/extqs_gi"):=
  "@(#)$Id: extqs.gi,v 1.7 2009/07/02 12:34:34 gap Exp $";


############################################################################
##
#M  ExtendQuotientSystem ( <quo> )
##
## Extends the quotient system for G/gamma_i(G) to a consistent quotient
## system for G/gamma_{i+1}(G).
##
InstallMethod( ExtendQuotientSystem,
  "using a single-core machine", true,
  [ IsObject ], 0, 
  function(Q)
  local c,		# nilpotency class 
	weights,	# weight of the generators 
	Defs,		# definitions of each (pseudo) generator and tail
	Imgs,		# images of the generators of the LpGroup 
	ftl,		# collector of the covering group
	b,		# number of "old" generators + 1 
	HNF,		# Hermite normal form of the consistency rels/relators
        A,		# record: endos as matrices and (it.) rels as exp.vecs
	i,		# loop variable
	stack,		# stack for the spinning algorithm
	ev,evn,		# exponent vectors for the spinning algorithm
	QS,		# (confluent) quotient system for G/\gamma_i+1(G)
	time;


  # nilpotency class
  c:=Maximum(Q.Weights);

  # weights of the (old) generators
  weights:=ShallowCopy(Q.Weights);

  # old definitions and images
  Defs:=ShallowCopy(Q.Definitions);
  Imgs:=ShallowCopy(Q.Imgs);
  
  # build a (possibly inconsistent) nilpotent presentation for the 
  # covering group of Q
  ftl:=NQL_QSystemOfCoveringGroupByQSystem(Q.Pccol,weights,Defs,Imgs);

  # complete the nilpotent presentation using the tails routine
  UpdateNilpotentCollector(ftl,weights,Defs);
  
  # position of the first new (pseudo) generator/tail
  b:=Position(weights,Maximum(weights));
  
  # consistency relations (words in T)
  HNF := NQL_CheckConsistencyRelations(ftl,weights);
  for i in [1..Length(HNF.mat)] do
    if not IsZero(HNF.mat[i]{[1..b-1]}) then 
      Error("in ExtendQuotientSystem: wrong HNF from consistency check");
    fi;
    # forget the first b-1 (zero) entries
    HNF.mat[i]:=HNF.mat[i]{[b..Length(weights)]};
    HNF.Heads[i]:=HNF.Heads[i]-b+1;
  od;
  
  # build the endomorphisms
  A:=NQL_EndomorphismsOfCover( Q.Lpres, ftl, Imgs, Defs, weights );

  # if the endomorphisms do not induces endomorphisms of the multiplier
  if A = fail then 
    return(fail);
  fi;
  
  time:=Runtime();
    
  # spinning algorithm
  stack:=A.IteratedRelations;
  for i in [1..Length(stack)] do 
    NQL_AddRow(HNF,stack[i]);
  od;
  while not Length(stack)=0 do
    ev:=stack[1];
    Remove( stack, 1 );
    if not IsZero(ev) then 
      for i in [1..Length(A.Endomorphisms)] do 
        evn:=ev*A.Endomorphisms[i];
        if NQL_AddRow(HNF,evn) then 
          Add(stack,evn);
        fi;
      od;
    fi;
  od;
  
  # add the non-iterated relations
  for i in [1..Length(A.Relations)] do
    NQL_AddRow(HNF,A.Relations[i]);
  od;
  
  Info(InfoNQL,2,"Time spent for spinning algorithm: ",
			StringTime(Runtime()-time));
  
  if Length(HNF.mat)=0 then 
    # the presentation ftl satisfy the relations and is consistent
    QS:=rec();
    QS.Lpres:=Q.Lpres;
    QS.Weights:=weights;
    QS.Definitions:=Defs;
    QS.Pccol:=ftl;
    QS.Imgs:=ShallowCopy(Imgs);
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
  else 
    # use the Hermite normal form to compute a consistent presentation 
    # that satisfy the relations
    return(NQL_BuildNewCollector(Q,ftl,HNF,weights,Defs,Imgs));
  fi;
  end);
