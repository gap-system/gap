############################################################################
##
#W nq.gi			NQL				René Hartung
##
#H   @(#)$Id: nq.gi,v 1.5 2009/05/06 13:00:40 gap Exp $
##
Revision.("nql/gap/nq_gi"):=
  "@(#)$Id: nq.gi,v 1.5 2009/05/06 13:00:40 gap Exp $";

############################################################################
##
#M  NilpotentQuotient ( <LpGroup>, <int> ) . . for invariant LpGroups
##
## computes a weighted nilpotent presentation for the class-<int> quotient
## of the invariant <LpGroup> if it already has a nilpotent quotient system.
##
InstallOtherMethod( NilpotentQuotient,
  "for invariantly L-presented groups (with qs) and positive integer",
  true,
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation
    and HasNilpotentQuotientSystem, IsPosInt], 0,
  function(G,c)
  local Q, 	# current quotient system
        QS,	# old quotient system
	H,	# the nilpotent quotient of <G>
      	i,	# loop variable
	time,	# runtime
        j;	# nilpotency class

  # known quotient system of <G>
  Q:=NilpotentQuotientSystem(G);
 
  # nilpotency class
  j:=Maximum(Q.Weights);
 
  if c=j then 
    # the given nilpotency class <j> is already known
    H:=PcpGroupByCollectorNC(Q.Pccol);
    SetLowerCentralSeriesOfGroup(H,NQL_LCS(Q));

    return(H);
  elif c<j then
    # the given nilpotency class <c> is already computed 
    QS:=SmallerQuotientSystem(Q,c);

    # build the nilpotent quotient with lcs
    H:=PcpGroupByCollectorNC(QS.Pccol);
    SetLowerCentralSeriesOfGroup(H,NQL_LCS(QS));

    return(H);
  else
    if HasLargestNilpotentQuotient(G) then 
      return(LargestNilpotentQuotient(G));
    fi;

    # extend the largest known quotient system
    for i in [j+1..c] do
      QS:=ShallowCopy(Q);

      time := Runtime();

      # extend the quotient system of G/\gamma_i to G/\gamma_{i+1}
      Q:=ExtendQuotientSystem(Q);
      if Q = fail then 
        return(fail);
      fi;

      # if we couldn't extend the quotient system any more, we're finished
      if QS.Weights=Q.Weights then 
        SetLargestNilpotentQuotient(G,PcpGroupByCollectorNC(Q.Pccol));
        break;
      fi;

      if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
        Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
	               Length(Q.Weights)-Length(QS.Weights), " generators");
      else
        Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
	               Length(Q.Weights)-Length(QS.Weights),
		       " generators with relative orders: ",
		       RelativeOrders(Q.Pccol)
		       {[Length(QS.Weights)+1..Length(Q.Weights)]});
      fi;
      Info(InfoNQL,2,"Runtime for this step ",StringTime(Runtime()-time) );
    od;

    # store the largest nilpotent quotient system
    ResetFilterObj(G,NilpotentQuotientSystem);
    SetNilpotentQuotientSystem(G,Q);

    # build the nilpotent quotient with its lower central series attribute
    H:=PcpGroupByCollectorNC(Q.Pccol);
    SetLowerCentralSeriesOfGroup(H,NQL_LCS(Q));

    return(H);
  fi;
  end);

############################################################################
##
#M  NilpotentQuotient ( <LpGroup>, <int> ) . . for invariant LpGroups 
##
## computes a weighted nilpotent presentation for the class-<int> quotient
## of the invariant <LpGroup>.
##
InstallOtherMethod( NilpotentQuotient,
  "for an invariantly L-presented group and a positive integer",
  true,
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation,
    IsPosInt ], 0,
  function(G,c)
  local Q,	# current quotient system
	H,	# the nilpotent quotient of <G>
	QS,	# old quotient system
	i,	# loop variable
	time;	# runtime

  time:=Runtime();
  # Compute a confluent nilpotent presentation for G/G'
  Q:=InitQuotientSystem(G);

  if Length(Q.Weights) > InfoNQL_MAX_GENS then
    Info(InfoNQL,1,"Class ",1,": ",Length(Q.Weights), " generators");
  else
    Info(InfoNQL,1,"Class ",1,": ",Length(Q.Weights),
		     " generators with relative orders: ",
		     RelativeOrders(Q.Pccol));
  fi;
  Info(InfoNQL,2,"Runtime for this step ", StringTime(Runtime()-time));
  
  for i in [1..c-1] do 
    # copy the old quotient system to compare with the extended qs.
    QS:=ShallowCopy(Q);

    time:=Runtime();
    # extend the quotient system of G/\gamma_i to G/\gamma_{i+1}
    Q:=ExtendQuotientSystem(Q);
    if Q = fail then 
      return(fail);
    fi;
   
    # if we couldn't extend the quotient system any more, we're finished
    if QS.Weights=Q.Weights then 
      SetLargestNilpotentQuotient(G,PcpGroupByCollectorNC(Q.Pccol));
      break;
    fi;

    if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
      Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
			 Length(Q.Weights)-Length(QS.Weights), " generators");
    else
      Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
			 Length(Q.Weights)-Length(QS.Weights),
			 " generators with relative orders: ",
			 RelativeOrders(Q.Pccol)
			   {[Length(QS.Weights)+1..Length(Q.Weights)]});
    fi;
    Info(InfoNQL,2,"Runtime for this step ", StringTime(Runtime()-time));
  od;
  
  # store the largest known nilpotent quotient of <G>
  ResetFilterObj(G,NilpotentQuotientSystem);
  SetNilpotentQuotientSystem(G,Q);

  # build the nilpotent quotient with lcs
  H:=PcpGroupByCollectorNC(Q.Pccol);
  SetLowerCentralSeriesOfGroup(H,NQL_LCS(Q));

  return(H);
  end);

############################################################################
##
#M  NilpotentQuotient ( <LpGroup> ) . . . . . . for invariant LpGroups
##
## attempts to compute the largest nilpotent quotient of <LpGroup>.
## Note that this method only terminates if <LpGroup> has a largest 
## nilpotent quotient.
##
InstallOtherMethod( NilpotentQuotient,
  "for an invariantly L-presented group with a quotient system",
  true,
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation
    and HasNilpotentQuotientSystem ], 0,
  function(G)
  local Q,	# current quotient system
	H,	# largest nilpotent quotient of <G>
	QS,	# old quotient system
	time,	# runtime
	i;	# loop variable

  if HasLargestNilpotentQuotient(G) then 
    return(LargestNilpotentQuotient(G));
  fi;

  # Compute a confluent nilpotent presentation for G/G'
  Q:=NilpotentQuotientSystem(G);
  
  repeat
    QS:=ShallowCopy(Q);
    
    time := Runtime();
    # extend the quotient system of G/\gamma_i to G/\gamma_{i+1}
    Q:=ExtendQuotientSystem(Q);
    if Q = fail then 
      return(fail);
    fi;
  
    if QS.Weights <> Q.Weights then 
      if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
        Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
	                Length(Q.Weights)-Length(QS.Weights), " generators");
      else
        Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
			 Length(Q.Weights)-Length(QS.Weights),
			 " generators with relative orders: ",
			 RelativeOrders(Q.Pccol)
			   {[Length(QS.Weights)+1..Length(Q.Weights)]});
      fi; 
    else 
      Info(InfoNQL,1,"the group has a maximal nilpotent quotient of class ",
                      Maximum(Q.Weights) );
    fi;
    Info(InfoNQL,2,"Runtime for this step ", StringTime(Runtime()-time));

  until QS.Weights = Q.Weights;
  
  SetLargestNilpotentQuotient(G,PcpGroupByCollectorNC(Q.Pccol));

  # store the largest known nilpotent quotient of <G>
  ResetFilterObj(G,NilpotentQuotientSystem);
  SetNilpotentQuotientSystem(G,Q);

  # build the nilpotent quotient with lcs
  H:=PcpGroupByCollectorNC(Q.Pccol);
  SetLowerCentralSeriesOfGroup(H,NQL_LCS(Q));

  return(H);
  end);

############################################################################
##
#M  NilpotentQuotient( <LpGroup> ) . . . . . . for invariant LpGroups
##
## determines the largest nilpotent quotient of <LpGroup> if it 
## has a nilpotent quotient system as an attribute.
## Note that this method only terminates if <LpGroup> has a largest 
## nilpotent quotient.
##
InstallOtherMethod( NilpotentQuotient,
  "for an invariantly L-presented group",
  true,
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation ], 0,
  function(G)
  local Q,	# current quotient system
	H,	# largest nilpotent quotient of <G>
	QS,	# old quotient system
	i,	# loop variable
	time;	# runtime

  time:=Runtime();

  # Compute a confluent nilpotent presentation for G/G'
  Q:=InitQuotientSystem(G);

  if Length(Q.Weights) > InfoNQL_MAX_GENS then 
    Info(InfoNQL,1,"Class ",1,": ", Length(Q.Weights), " generators");
  else
    Info(InfoNQL,1,"Class ",1,": ", Length(Q.Weights),
               " generators with relative orders: ", RelativeOrders(Q.Pccol));
  fi;
  Info(InfoNQL,2,"Runtime for this step ", StringTime(Runtime()-time));
  
  repeat
    QS:=ShallowCopy(Q);
    
    time := Runtime();
    # extend the quotient system of G/\gamma_i to G/\gamma_{i+1}
    Q:=ExtendQuotientSystem(Q);
    if Q = fail then
      return(fail);
    fi;
  
    if QS.Weights <> Q.Weights then 
      if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
        Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
			 Length(Q.Weights)-Length(QS.Weights), " generators");
      else
        Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
			 Length(Q.Weights)-Length(QS.Weights),
			 " generators with relative orders: ",
			 RelativeOrders(Q.Pccol)
			   {[Length(QS.Weights)+1..Length(Q.Weights)]});
      fi;
    fi;
    Info(InfoNQL,2,"Runtime for this step ", StringTime(Runtime()-time));

  until QS.Weights = Q.Weights;
  
  SetLargestNilpotentQuotient(G,PcpGroupByCollectorNC(Q.Pccol));

  # store the largest known nilpotent quotient of <G>
  ResetFilterObj(G,NilpotentQuotientSystem);
  SetNilpotentQuotientSystem(G,Q);

  # build the nilpotent quotient with lcs
  H:=PcpGroupByCollectorNC(Q.Pccol);
  SetLowerCentralSeriesOfGroup(H,NQL_LCS(Q));

  return(H);
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup>, <int> )
##
## computes an epimorphism from <LpGroup> onto its class-<int> quotient 
## if a nilpotent quotient system of <LpGroup> is already known.
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an invariantly L-presented group with a quotient system and an integer",
  true,
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation
    and HasNilpotentQuotientSystem,
    IsPosInt], 0,
  function(G,c)
  local Q, 	# current quotient system
        QS,	# old quotient system
      	i,	# loop variable
	time,	# runtime
        n;	# nilpotency class

  # known quotient system of <G>
  Q:=NilpotentQuotientSystem(G);
 
  # nilpotency class of <Q>
  n:=Maximum(Q.Weights);
 
  if c=n then 
    # the given nilpotency class <n> is already known
    return(Q.Epimorphism);
  elif c<n then
    # the given nilpotency class <c> is already computed 
    QS:=SmallerQuotientSystem(Q,c);
    return(QS.Epimorphism);
  else
    if HasLargestNilpotentQuotient(G) then 
      Info(InfoNQL,1,"Largest nilpotent quotient of class ",
		     NilpotencyClassOfGroup(LargestNilpotentQuotient(G)));
      return(Q.Epimorphism);
    fi;

    # extend the largest known quotient system
    for i in [n+1..c] do
      QS:=ShallowCopy(Q);

      time := Runtime();
      # extend the quotient system of G/\gamma_i to G/\gamma_{i+1}
      Q:=ExtendQuotientSystem(Q);
      if Q = fail then 
        return(fail);
      fi;
  
      # if we couldn't extend the quotient system any more, we're finished
      if QS.Weights = Q.Weights then 
        SetLargestNilpotentQuotient(G,PcpGroupByCollectorNC(Q.Pccol));
        Info(InfoNQL,1,"Largest nilpotent quotient of class ",
                        Maximum(Q.Weights));
		     
        break;
      else 
        if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
          Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
 			 Length(Q.Weights)-Length(QS.Weights), " generators");
        else
          Info(InfoNQL,1,"Class ",Maximum(Q.Weights),": ",
			 Length(Q.Weights)-Length(QS.Weights),
			 " generators with relative orders: ",
			 RelativeOrders(Q.Pccol)
			   {[Length(QS.Weights)+1..Length(Q.Weights)]});
        fi;
      fi;
      Info(InfoNQL,2,"Runtime for this step ", StringTime(Runtime()-time));
  
    od;

    # store the largest nilpotent quotient system
    ResetFilterObj(G,NilpotentQuotientSystem);
    SetNilpotentQuotientSystem(G,Q);

    return(Q.Epimorphism); 
  fi;
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup>, <int> )
##
## computes an epimorphism from <LpGroup> onto its class-<int> quotient.
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an invariantly L-presented group",
  true,
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation,
    IsPosInt], 0,
  function(G,c)
  local H; 	# nilpotent quotient <G>/gamma_<c>(<G>)

  # compute the nilpotent quotient of <G>
  H:=NilpotentQuotient(G,c);
 
  return(NilpotentQuotientSystem(G).Epimorphism);
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup> , <PcpGroup> ) 
##
## computes an epimorphism from the invariant LpGroup into the nilpotent 
## quotient <PcpGroup>.
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an L-presented group and its nilpotent quotient",
  true,  
  [ IsLpGroup and HasIsInvariantLPresentation and IsInvariantLPresentation
    and HasNilpotentQuotientSystem, IsPcpGroup ], 0,
  function(G,H)
  local ftl,	# collector of the PcpGroup <H>
	Q,	# largest known nilpotent quotient system of G
     	QS, 	# nilpotent quotient system of <H>
   	imgs,	# images of the epimorphism
        i,	# loop variable
        c,	# nilpotency class of <H>
	n;	# number of generators of G/gamma_c(G)

  # number of generators of the Pcp group (used to determine its qs.)
  ftl:=Collector(H);
  n:=NumberOfGenerators(ftl);

  # the largest known quotient system
  Q:=NilpotentQuotientSystem(G);
  
  # nilpotency class of <H>
  c:=Q.Weights[n];

  # determine the quotient system of <H>
  QS:=SmallerQuotientSystem(Q,c);
 
  imgs:=[];
  for i in [1..Length(QS.Imgs)] do
    if IsInt(QS.Imgs[i]) then 
      imgs[i]:=[QS.Imgs[i],1];
    else
      imgs[i]:=QS.Imgs[i];
    fi;
  od;
  imgs:=List(imgs,x->PcpElementByGenExpList(ftl,x));
  return(GroupHomomorphismByImagesNC(G,H,GeneratorsOfGroup(G),imgs));
  end);

############################################################################
##
#F  NQL_LCS( <QS> )
##
## computes the lower central series of a nilpotent quotient given by a 
## quotient system <QS>.
##
InstallGlobalFunction( NQL_LCS,
  function(Q)
  local weights,	# weights-function of <Q>
  	i,		# loop variable
  	c, 		# nilpotency class of <Q>
 	H,		# nilpotent presentation corr. to <Q>
  	gens,		# generators of <H>
 	lcs;		# lower central series of <H>

  # nilpotent presentation group corr. to <Q>
  H:=PcpGroupByCollectorNC(Q.Pccol);

  # generators of <H>
  gens:=GeneratorsOfGroup(H);

  # weights function of the given quotient system
  weights:=Q.Weights;

  # nilpotency class of <Q>
  c:=Maximum(weights);

  # build the lower central series
  lcs:=[];
  lcs[c+1]:=SubgroupByIgs(H,[]);
  lcs[1]:=H;
 
  for i in [2..c] do
    # the lower central series as subgroups by an induced generating system
    # with weights at least <i>
    lcs[i]:=SubgroupByIgs(H,gens{Filtered([1..Length(gens)],x->weights[x]>=i)});
  od;

  return(lcs);
  end);

############################################################################
##
#A  LargestNilpotentQuotient( <LpGroup> )
##
InstallMethod( LargestNilpotentQuotient,
  "for an L-presented group",
  true,
  [ IsLpGroup ], 0,
  NilpotentQuotient);

############################################################################
##
#A  NilpotentQuotients( <LpGroup> ) .  .  .  .  . for invariant LpGroups
##
InstallMethod( NilpotentQuotients,
  "for an invariantly L-presented group with a quotient system",
  true,
  [ IsLpGroup and HasNilpotentQuotientSystem ], 0,
  function ( G )
  local c;	# nilpotency class of the known quotient system
   
  c:=Maximum(NilpotentQuotientSystem(G).Weights); 
  return( List([1..c], i -> NqEpimorphismNilpotentQuotient(G,i) ) );
  end);

############################################################################
##
#M  NilpotentQuotient( <FpGroup> )
##
InstallOtherMethod( NilpotentQuotient,
  "for an FpGroup using the NQL-package", true,
  [ IsFpGroup, IsPosInt ], 0, 
  function( G, c )
  return( NilpotentQuotient( Range( IsomorphismLpGroup( G ) ), c ) );
  end);

InstallOtherMethod( NilpotentQuotient,
  "for an FpGroup using the NQL-package", true,
  [ IsFpGroup ], 0, 
  G -> NilpotentQuotient( Range( IsomorphismLpGroup( G ) ) ) );

############################################################################
##
#M  NqEpimorphismNilpotentQuotient( <FpGroup> )
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an FpGroup using the NQL-package", true,
  [ IsFpGroup, IsPosInt ], 0,
  function( G, c )
  local iso, 	# isomorphism from FpGroup to LpGroup
	mapi,	# MappingGeneratorsImages of <iso>
	epi;	# epimorphism from LpGroup onto its nilpotent quotient

  iso  := IsomorphismLpGroup( G );
  mapi := MappingGeneratorsImages( iso );
  epi  := NqEpimorphismNilpotentQuotient( Range( iso ), c );
  return( GroupHomomorphismByImages( G, Range( epi ), mapi[1], 
                        List( mapi[1], x -> Image( epi, Image( iso, x ) ) ) ) );
  end);
