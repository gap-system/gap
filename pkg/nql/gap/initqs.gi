############################################################################
##
#W initqs.gi			NQL				René Hartung
##
#H   @(#)$Id: initqs.gi,v 1.5 2009/05/06 12:54:47 gap Exp $
##
Revision.("nql/gap/initqs_gi"):=
  "@(#)$Id: initqs.gi,v 1.5 2009/05/06 12:54:47 gap Exp $";


############################################################################
##
#M  InitQuotientSystem ( <LpGroup> )
##
## computes a weighted nilpotent quotient system for the abelian quotient 
## of <LpGroup>.
##
InstallMethod( InitQuotientSystem,
  "for an L-presented group", 
  true,
  [ IsLpGroup ], 0,
  function(G)
  local ftl,		# FromTheLeftCollector for G/G'
          A,		# power relations from Hermite normal form
          Q,		# new quotient system
          n,		# number of generators of L
          ev,evn,	# exponent vectors for spinning algorithm
          rel,		# loop variable for (iterated) relators 
          map,		# loop variable for endomorphisms 
          i,j,k,	# loop variables
          HNF,		# Hermite normal form of the relations
          stack,	# stack for the spinning algorithm
          endos,	# endomorphisms as matrices 
          obj, mat,	# loop variables to determine the matrices
	  Gens,		# position of new gens in the HNF
	  Imgs;		# loop variable to build the endomorphism

  # number of new generators
  n:=Length(GeneratorsOfGroup(G));
  
  # determine the iterated relators
  stack:=[];
  HNF:=rec(mat:=[],Heads:=[]);
  for rel in IteratedRelatorsOfLpGroup(G) do 
    ev:=ListWithIdenticalEntries(n,0);
    obj:=ExtRepOfObj(rel);
    for i in [1,3..Length(obj)-1] do 
      ev[obj[i]]:=ev[obj[i]]+obj[i+1];
    od;
    Add(stack,ShallowCopy(ev));
    NQL_AddRow(HNF,ev);
  od;
  
  # determine the endomorphisms
  endos:=[];
  for map in EndomorphismsOfLpGroup(G) do
    mat:=NullMat(n,n);

    # UnderlyingElement: map is an endomorphism of the free group;
    # x an object of the L-presented group
    obj:=List(GeneratorsOfGroup(G),x->ExtRepOfObj(UnderlyingElement(x)^map));
    for j in [1..n] do 
      for k in [1,3..Length(obj[j])-1] do 
        mat[j][obj[j][k]]:=mat[j][obj[j][k]]+obj[j][k+1];
      od;
    od;
    Add(endos,mat);
  od;
  
  # spinning algorithm
  while not Length(stack)=0 do
    ev:=stack[1];
    Remove( stack, 1);
    if not IsZero(ev) then 
      for i in [1..Length(endos)] do 
        evn:=ev*endos[i];
        if NQL_AddRow(HNF,evn) then 
          Add(stack,evn);
        fi;
      od;
    fi;
  od;
  
  # add the (fixed) relators
  for rel in FixedRelatorsOfLpGroup(G) do
    ev:=ListWithIdenticalEntries(n,0);
    obj:=ExtRepOfObj(rel);
    for i in [1,3..Length(obj)-1] do 
      ev[obj[i]]:=ev[obj[i]]+obj[i+1];
    od;
    NQL_AddRow(HNF,ev);
  od;
  
  # translate the Hermite normal form to power relations
  A:=NQL_PowerRelationsOfHNF(HNF);
  
  # generators with power relation
  Gens:=HNF.Heads{Filtered([1..Length(HNF.Heads)],
                           x->HNF.mat[x][HNF.Heads[x]]<>1)};
  
  # infinite generators;
  Append(Gens,Filtered([1..n],x->not x in HNF.Heads));
  Sort(Gens);
  
  # if the group is perfect
  if Length(Gens)=0 then 
    Q := rec( Lpres       := G, 
              Pccol       := FromTheLeftCollector( 0 ),
              Imgs        := ListWithIdenticalEntries( n, [] ),
              Weights     := [],
              Definitions := [] );
    UpdatePolycyclicCollector( Q.Pccol );
    Imgs := List( Q.Imgs, x -> PcpElementByGenExpList( Q.Pccol, x ) );
    Q.Epimorphism := GroupHomomorphismByImagesNC( Q.Lpres, 
                                        PcpGroupByCollectorNC( Q.Pccol), 
                                        GeneratorsOfGroup( Q.Lpres), Imgs );
                                        
    return( Q );
  fi;
  
  # build quotient system
  Q:=rec();
  Q.Lpres:=G;
  
  # the new collector
  Q.Pccol:=FromTheLeftCollector(Length(Gens));
  for i in [1..Length(Gens)] do 
    k:=Position(HNF.Heads,Gens[i]);
    if k<>fail then 
      SetRelativeOrder(Q.Pccol,i, A[k][Gens[i]]);
      ev:=ShallowCopy(A[k]{Gens});
      ev[i]:=0;
      if not IsZero(ev) then 
        SetPower(Q.Pccol,i,ObjByExponents(Q.Pccol,-ev));
      fi;
    fi;
  od;
  UpdatePolycyclicCollector(Q.Pccol);
  
  # the natural homomorphism onto the new presentation
  Q.Imgs:=[];
  for i in [1..n] do 
    if i in Gens then 
      k:=i-Length(Filtered([1..Length(HNF.Heads)],x->HNF.mat[x][HNF.Heads[x]]=1
                                                     and HNF.Heads[x]<i));
      Add(Q.Imgs,k);
    else
      Add(Q.Imgs,ObjByExponents(Q.Pccol,-A[Position(HNF.Heads,i)]{Gens}));
    fi;
  od;
  
  # the epimorphism into the new presentation
  Imgs:=[];
  for i in [1..Length(Q.Imgs)] do
    if IsInt(Q.Imgs[i]) then 
      Add(Imgs,PcpElementByGenExpList(Q.Pccol,[Q.Imgs[i],1]));
    else
      Add(Imgs,PcpElementByGenExpList(Q.Pccol,Q.Imgs[i]));
    fi;
  od;
  Q.Epimorphism:=GroupHomomorphismByImagesNC(Q.Lpres,
                      PcpGroupByCollectorNC(Q.Pccol),
			GeneratorsOfGroup(Q.Lpres),Imgs);
  
  Q.Weights:=List([1..Length(Gens)],x->1);
  Q.Definitions:=Filtered([1..Length(Q.Imgs)],x->not IsList(Q.Imgs[x]));
  
  return(Q);
  end);

############################################################################
##
#M  AbelianInvariants ( <LpGroup> )
##
## computes the abelian invariants of <LpGroup>.
##
InstallMethod( AbelianInvariants,
  "for an L-presented group",
  [ IsLpGroup ],0,
  G -> AbelianInvariants( NilpotentQuotient(G,1) ) );
