############################################################################
##
#W nq_non.gi			NQL				René Hartung
##
#H   @(#)$Id: nq_non.gi,v 1.6 2009/05/06 12:54:47 gap Exp $
##
Revision.("nql/gap/nq_non_gi"):=
  "@(#)$Id: nq_non.gi,v 1.6 2009/05/06 12:54:47 gap Exp $";


############################################################################
##
#M  NilpotentQuotient ( <LpGroup>, <int> ) . . . for non-inv LpGroups 
##
## computes a polycyclic presentation for the class-<int> quotient of 
## <LpGroup>.
##
InstallOtherMethod( NilpotentQuotient,
  "for an L-presented group and a positive integer",
  true,
  [ IsLpGroup, IsPosInt ],0,
  function(G,c)
  local InvLp,	# ascending L-presentation
	i,	# loop variable
	Q,	# current quotient system
	QS,	# old quotient system
	time,	# runtime
	NQs;	# nilpotent quotients of <G> (NilpotentQuotients)

  # InitQuotientSystem works also for non-invariantly LpGroups
  Q:=InitQuotientSystem(G);
  NQs:= [ Q.Epimorphism ];
  SetNilpotentQuotients(G,NQs);

  # an underlying invariant L-presentation
  InvLp:=UnderlyingInvariantLPresentation(G);

  # if the underlying invariant L-presentation was set manually
  if not HasIsInvariantLPresentation( InvLp ) then
    SetIsInvariantLPresentation( InvLp, true );
  fi;

  # if the underlying invariant L-presentation is <G> itself
  if Length( FixedRelatorsOfLpGroup( G ) ) = 
     Length( FixedRelatorsOfLpGroup( InvLp ) )  then 
    SetIsInvariantLPresentation( G, true );
    return( NilpotentQuotient( G, c ) );
  fi;

  time := Runtime();

  # a weighted nilpotent quotient system for the abelian quotient of <InvLp>
  Q:=InitQuotientSystem(InvLp);

  # store the largest nilpotent quotient system of <InvLp>
  SetNilpotentQuotientSystem(InvLp,Q);

  if c > 1 then 
    if Length(Q.Weights) > InfoNQL_MAX_GENS then 
      Info(InfoNQL, 1,"Class InvLpGroup ", Maximum(Q.Weights),": ",
			Length(Q.Weights), " generators");
    else
      Info(InfoNQL, 1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
 			Length(Q.Weights),
			" generators with relative orders: ",
			RelativeOrders(Q.Pccol));
    fi;
  fi;
  Info(InfoNQL,2,"Runtime for the invariant step ",StringTime(Runtime()-time));

  for i in [2..c] do 
    QS:=ShallowCopy(Q);

    time := Runtime();

    # extend the weighted nilpotent quotient system of <InvLp>/\gamma_i(<InvLp>)
    # to a weighted nilpotent quotient system of <InvLp>/\gamma_{i+1}(<InvLp>)
    Q:=ExtendQuotientSystem(Q);
    if Q = fail then
      Error("the underlying invariant LpGroup is not invariant");
    fi;

    if QS.Weights <> Q.Weights then 
      if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
        Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights), " generators");
      else
        Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights),
			" generators with relative orders: ",
			RelativeOrders(Q.Pccol)
			{[Length(QS.Weights)+1..Length(Q.Weights)]});
      fi;
    fi;
    Info(InfoNQL,2,"Runtime for the invariant step ",StringTime(Runtime()-time));
    
    if QS.Weights = Q. Weights then 
      # quotient system of the invariant L-presentation terminated
      if not IsBound(NilpotentQuotients(G)[i-1]) then 
        Error("unbound entry in NilpotentQuotients");
      else
        SetLargestNilpotentQuotient(G, Range(NilpotentQuotients(G)[i-1]) );
        Info(InfoNQL,1,"Largest nilpotent quotient of class ", 
	                Maximum(Q.Weights));
        return( LargestNilpotentQuotient(G) );
      fi;
    elif NQL_TerminatedNonInvariantNQ(G,Q) then 
      if not IsBound(NilpotentQuotients(G)[i-1]) then 
        Error("unbound entry in NilpotentQuotients");
      else
        SetLargestNilpotentQuotient(G, Range(NilpotentQuotients(G)[i-1]));
        Info(InfoNQL,1,"Largest nilpotent quotient of class ", 
             NilpotencyClassOfGroup( Range(NilpotentQuotients(G)[i-1])));
        return(LargestNilpotentQuotient(G));
      fi;
    else 
      # largest quotient system of the invariant L-presentation 
      ResetFilterObj(UnderlyingInvariantLPresentation(G),
 		NilpotentQuotientSystem);
      SetNilpotentQuotientSystem(UnderlyingInvariantLPresentation(G),Q);
    fi;
    Info(InfoNQL,2,"Runtime for the whole step ",StringTime(Runtime()-time));
  od;

  return( Range(NilpotentQuotients(G)[c]) ); 
  end);

############################################################################
##
#M  NilpotentQuotient ( <LpGroup>, <int> ) . .  for non-inv. LpGroups 
##
## computes a polycyclic presentation for the class-<int> quotient of 
## <LpGroup> if the group has NilpotentQuotients as attribute.
##
InstallOtherMethod( NilpotentQuotient,
  "for an L-presented group with a quotient system and a positive integer",
  true,
  [ IsLpGroup and HasNilpotentQuotients, IsPosInt ], 0,
  function(G,c)
  local Q,	# largest known quotient system
	i,	# loop variable
	QS,	# smaller quotient system
     	EpiInv,	# epimorphism from the ascending LpGroup into <H>
 	H,	# nilpotent quotient of <InvLp>
        fam,	# family of elements in <G>
	U,	# normal subgroup of the images of the (unit.) relators
     	Epi,MGI,# epimorphism from the LpGroup <G> into <H>/<U>
	NQs,	# nilpotent quotients of <G> (NilpotentQuotients)
 	n, 	# nilpotency class of the largest known quotient system
	time,	# runtime
	nat;	# natural homomorphism <H> -> <H>/<U>

  # check whether this quotient is already known
  if IsBound(NilpotentQuotients(G)[c]) then
    return(Range(NilpotentQuotients(G)[c]));
  elif HasLargestNilpotentQuotient(G) and Length(NilpotentQuotients(G)) < c then
    Info( InfoNQL, 1, "The group has a largest nilpotent quotient of class ",
                      NilpotencyClassOfGroup(LargestNilpotentQuotient(G)) );
    return( LargestNilpotentQuotient(G) );
  fi;

  # restore the largest known quotient system of the underlying invariant L-pres
  Q:=NilpotentQuotientSystem(UnderlyingInvariantLPresentation(G));

  # nilpotency class of <Q>
  n:=Maximum(Q.Weights);

  NQs:=NilpotentQuotients(G);
  if NilpotencyClassOfGroup( Range( NQs[Length(NQs)] ) ) < n then 
    Error("may not occur");
  fi;
  
  if n < c then 
    if HasLargestNilpotentQuotient(G) then 
      Info(InfoNQL,1,"Largest nilpotent quotient of class ",
	              NilpotencyClassOfGroup(LargestNilpotentQuotient(G)));
      return(LargestNilpotentQuotient(G));
    fi;
    for i in [n+1..c] do
      QS:=ShallowCopy(Q);

      time := Runtime();

      # extend the weighted nilpotent quotient system of InvLp/\gamma_i(InvLp)
      # to a weighted nilpotent quotient system of InvLp/\gamma_{i+1}(InvLp)
      Q:=ExtendQuotientSystem(Q);
      if Q = fail then 
        Error("the underlying invariant LpGroup is not invariant");
      fi;

      if QS.Weights <> Q.Weights then 
        if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
          Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights), " generators");
        else
          Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights),
			" generators with relative orders: ",
			RelativeOrders(Q.Pccol)
			{[Length(QS.Weights)+1..Length(Q.Weights)]});
        fi;
      fi;
      Info(InfoNQL,2,"Runtime for the invariant step ",StringTime(Runtime()-time));

      if QS.Weights = Q.Weights then 
        # the quotient system of the ascending presentation terminated
        if not IsBound(NilpotentQuotients(G)[i-1]) then 
          Error("unbound entry in NilpotentQuotients");
        else
	  SetLargestNilpotentQuotient(G,Range(NilpotentQuotients(G)[i-1]));
 	  Info(InfoNQL,1,"Largest nilpotent quotient of class ",
			  Maximum(Q.Weights));
 	  return(LargestNilpotentQuotient(G));
        fi;
      elif NQL_TerminatedNonInvariantNQ(G,Q) then 
        if not IsBound(NilpotentQuotients(G)[i-1]) then 
          Error("unbound entry in NilpotentQuotients");
        else
	  SetLargestNilpotentQuotient(G,Range(NilpotentQuotients(G)[i-1]));
 	  Info(InfoNQL,1,"Largest nilpotent quotient of class ",
	       NilpotencyClassOfGroup( Range( NilpotentQuotients(G)[i-1]) ) );
 	  return(LargestNilpotentQuotient(G));
        fi;
      else
        # largest quotient system of the underl. invariant L-presentation
        ResetFilterObj(UnderlyingInvariantLPresentation(G),
				NilpotentQuotientSystem);
        SetNilpotentQuotientSystem(UnderlyingInvariantLPresentation(G),Q);
      fi;
      Info(InfoNQL,2,"Runtime for the whole step ",StringTime(Runtime()-time));
    od;

    return( Range(NilpotentQuotients(G)[c]) ); 
  else 
    # all known smaller quotients are stored in `NilpotentQuotients'
    Error(" may not occur (redundant in NQL 0.03) ");
  fi;
  end);

############################################################################
##
#M  NilpotentQuotient( <LpGroup> ) . . . . for non-invariant LpGroups
##
## attempts to compute the largest nilpotent quotient of <LpGroup>.
## Note that this method will only terminate if <LpGroup> has a largest
## nilpotent quotient!
##
InstallOtherMethod( NilpotentQuotient,
  "for L-presented groups",
  true,
  [ IsLpGroup ],0,
  function(G)
  local InvLp,	# ascending L-presentation
        Q,	# current quotient system
	QS,	# old quotient system
     	EpiInv,	# epimorphism from the ascending LpGroup into <H>
	H,	# nilpotent quotient of <InvLp>
        fam,	# family of elements in <G>
	U,	# normal subgroup of the images of the (unit.) relators
  	nat,	# natural homomorphism <H> -> <H>/<U>
     	Epi,MGI,# epimorphism from the ascending LpGroup into <H>/<U>
      	c,	# nilpotency class of the largest nilpotent quotient 
        NQs,	# nilpotent quotients with epimorphisms (NilpotentQuotients)
	time;	# runtime

  
  # InitQuotientSystem works also for non-invariantly LpGroups
  Q:=InitQuotientSystem(G);
  NQs:=[ Q.Epimorphism ];
  SetNilpotentQuotients(G,NQs);

  # an underlying invariant L-presentation
  InvLp := UnderlyingInvariantLPresentation(G);

  # if the underlying invariant L-presentation was set manually
  if not HasIsInvariantLPresentation( InvLp ) then
    SetIsInvariantLPresentation( InvLp, true );
  fi;

  # if the underlying invariant L-presentation is <G> itself
  if Length( FixedRelatorsOfLpGroup( G ) ) = 
     Length( FixedRelatorsOfLpGroup( InvLp ) )  then 
    SetIsInvariantLPresentation( G, true );
    return( NilpotentQuotient( G ) );
  fi;
  
  time:=Runtime();

  # a weighted nilpotent quotient system for the abelian quotient of <InvLp>
  Q:=InitQuotientSystem(InvLp);

  # store the largest nilpotent quotient system of <InvLp>
  SetNilpotentQuotientSystem(InvLp,Q);

  if Length(Q.Weights) > InfoNQL_MAX_GENS then 
    Info(InfoNQL, 1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights), " generators");
  else
    Info(InfoNQL, 1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights),
			" generators with relative orders: ",
			RelativeOrders(Q.Pccol));
  fi;
  Info(InfoNQL,2,"Runtime for the invariant step ",StringTime(Runtime()-time));

  repeat 
    QS:=ShallowCopy(Q);

    time := Runtime();

    # extend the weighted nilpotent quotient system of <InvLp>/\gamma_i(<InvLp>)
    # to a weighted nilpotent quotient system of <InvLp>/\gamma_{i+1}(<InvLp>)
    Q:=ExtendQuotientSystem(Q);
    if Q = fail then 
      Error("the underlying invariant LpGroup is not invariant");
    fi;
  
    if QS.Weights <> Q.Weights then 
      if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
        Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights), " generators");
      else
        Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights),
			" generators with relative orders: ",
			RelativeOrders(Q.Pccol)
			{[Length(QS.Weights)+1..Length(Q.Weights)]});
      fi;
    fi;
    Info(InfoNQL,2,"Runtime for the invariant step ",StringTime(Runtime()-time));
    
    if NQL_TerminatedNonInvariantNQ(G,Q) then 
      Info(InfoNQL,1,"Largest nilpotent quotient of class ",
		      NilpotencyClassOfGroup(
		      Range(NilpotentQuotients(G)[Maximum(Q.Weights)-1])));
      SetLargestNilpotentQuotient(G,Range(NilpotentQuotients(G)
					 [Maximum(Q.Weights)-1]));
      return(LargestNilpotentQuotient(G));
    fi;
    Info(InfoNQL,2,"Runtime for the whole step  ",StringTime(Runtime()-time));

  until QS.Weights = Q.Weights;

  Info(InfoNQL,1,"Largest nilpotent quotient of class ", 
		  Maximum(Q.Weights));

  SetLargestNilpotentQuotient( G, Range(NilpotentQuotients(G)
 					[Maximum(Q.Weights)]));
  return(LargestNilpotentQuotient(G));
  end);

############################################################################
##
#M  NilpotentQuotient( <LpGroup> ) . . . . . . . for non-inv LpGroups
##
## attempts to compute the largest nilpotent quotient of <LpGroup> if 
## it has the attribute `NilpotentQuotients'.
## Note that this method only terminates if <LpGroup> has a largest
## nilpotent quotient.
##
InstallOtherMethod( NilpotentQuotient,
  "for an L-presented group with a quotient system",
  true,
  [ IsLpGroup and HasNilpotentQuotients ], 0,
  function(G)
  local Q,	# current quotient system
	InvLp,	# the underlying invariant L-presentation
	QS,	# old quotient system
	time,	# runtime
        NQs;	# nilpotent quotients with epimorphisms (NilpotentQuotients)

  # the largest nilpotent quotient has been computed
  if HasLargestNilpotentQuotient(G) then
    Info(InfoNQL,1,"Largest nilpotent quotient of class ",
 		NilpotencyClassOfGroup(LargestNilpotentQuotient(G)));
    return(LargestNilpotentQuotient(G));
  fi;

  # largest known nilpotent quotient system of the underlying invariant LpGroup
  InvLp:=UnderlyingInvariantLPresentation(G);
  Q:=NilpotentQuotientSystem(InvLp);

  # is the nilpotency class of the largest quotient system too large
  NQs := NilpotentQuotients(G);
  if NilpotencyClassOfGroup(Range(NQs[Length(NQs)])) < Maximum(Q.Weights) then 
    Error("may not occur");
  fi;

  repeat 
    QS:=ShallowCopy(Q);

    time := Runtime();

    # extend the weighted nilpotent quotient system of <InvLp>/\gamma_i(<InvLp>)
    # to a weighted nilpotent quotient system of <InvLp>/\gamma_{i+1}(<InvLp>)
    Q:=ExtendQuotientSystem(Q);
    if Q = fail then 
      Error("the underlying invariant LpGroup is not invariant");
    fi;

    if QS.Weights <> Q.Weights then 
      if Length(Q.Weights)-Length(QS.Weights) > InfoNQL_MAX_GENS then 
        Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights), " generators");
      else
        Info(InfoNQL,1,"Class InvLpGroup ",Maximum(Q.Weights),": ",
			Length(Q.Weights)-Length(QS.Weights),
			" generators with relative orders: ",
			RelativeOrders(Q.Pccol)
			{[Length(QS.Weights)+1..Length(Q.Weights)]});
      fi;
    fi;
    Info(InfoNQL,2,"Runtime for the invariant step ",StringTime(Runtime()-time));

    if NQL_TerminatedNonInvariantNQ(G,Q) then 
      if not IsBound(NilpotentQuotients(G)[Maximum(Q.Weights)-1]) then 
        Error( "unbound entry in NilpotentQuotients");
      else 
        SetLargestNilpotentQuotient(G,
           Range(NilpotentQuotients(G)[Maximum(Q.Weights)-1]));
        Info( InfoNQL,1 ,"Largest nilpotent quotient of class ",
	      NilpotencyClassOfGroup( LargestNilpotentQuotient(G) ) );
        return(LargestNilpotentQuotient(G));
      fi;
    fi;
  
  until QS.Weights = Q.Weights;
  
  Info(InfoNQL,1,"Largest nilpotent quotient of class ", 
		  Maximum(Q.Weights));

  SetLargestNilpotentQuotient(G,
     Range(NilpotentQuotients(G)[Maximum(Q.Weights)]));
  return(LargestNilpotentQuotient(G));
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup>, <int> )
##
## computes an epimorphism from <LpGroup> onto its class-<int> quotient.
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an L-presented group",
  true,  
  [ IsLpGroup, IsPosInt ], 0,
  function(G,c)
  local H;	# nilpotent quotient of G

  H:=NilpotentQuotient(G,c);   
  if not HasLargestNilpotentQuotient( G ) then 
    return(NilpotentQuotients(G)[c]);
  else
    return(NilpotentQuotients(G)[Length(NilpotentQuotients(G))]);
  fi;
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup>, <int> )
##
## computes an epimorphism from <LpGroup> onto its class-<int> quotient
## if <LpGroup> has the attribute `NilpotentQuotients'.
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an L-presented group with a quotient system",
  true,  
  [ IsLpGroup and HasNilpotentQuotients, IsPosInt ], 0,
  function(G,c)
  local Q,	# largest known nilpotent quotient system of <G>
	H, 	# nilpotent quotient of <G>
        n,	# nilpotency class of the largest nilp. qs. of <G>
 	NQs;	# all known nilpotent quotients of <G>

  if IsBound(NilpotentQuotients(G)[c]) then 
    return(NilpotentQuotients(G)[c]);
  elif HasLargestNilpotentQuotient(G) and Length(NilpotentQuotients(G)) < c then
    Info( InfoNQL, 1, "The group has a largest nilpotent quotient of class ",
          NilpotencyClassOfGroup(LargestNilpotentQuotient(G)) );
    return(LargestNilpotentQuotient(G));
  else
    H:=NilpotentQuotient(G,c);
    if not HasLargestNilpotentQuotient( G ) then 
      return(NilpotentQuotients(G)[c]);
    else
      return(NilpotentQuotients(G)[Length(NilpotentQuotients(G))]);
    fi;
  fi;
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup>, <PcpGroup> )
##
## computes an epimorphism from <LpGroup> onto its nilpotent quotient 
## <PcpGroup>. The <PcpGroup> must be an image of an epimorphism from
## the list `NilpotentQuotients'.
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an L-presented group",
  true,  
  [ IsLpGroup and HasNilpotentQuotients, IsPcpGroup ], 0,
  function(G,H)
  local i, 	# loop variable
	NQs;	# all known nilpotent quotients of <G>

  # the known nilpotent quotients of the group <G>
  NQs:=NilpotentQuotients(G);

  for i in [1..Length(NQs)] do
    if IsBound( NQs[i] ) and Range(NQs[i]) = H then 
      return( NQs[i] );
    fi;
  od;
  Error("<H> must be nilpotent quotient of <G>");
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup> )
##
## computes an epimorphism from <LpGroup> onto its largest nilpotent quotient
## if it exists; otherwise, this method will not terminate!
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for an L-presented group",
  true,  
  [ IsLpGroup ], 0,
  function(G)
  local c;	# nilpotency class of the largest nilpotent quotient

  c:=NilpotencyClassOfGroup(LargestNilpotentQuotient(G));
  return(NilpotentQuotients(G)[c]);
  end);

############################################################################
##
#M  NqEpimorphismNilpotentQuotient ( <LpGroup> )
##
## computes an epimorphism from <LpGroup> onto the largest nilpotent
## quotient. 
## Note that this method will only terminate if <LpGroup> has a largest
## nilpotent quotient.
##
InstallOtherMethod( NqEpimorphismNilpotentQuotient,
  "for L-presented groups",
  true,  
  [ IsLpGroup and HasNilpotentQuotients ], 0,
  function(G)
  local c;	# nilpotency class of the largest nilpotent quotient 

  c:=NilpotencyClassOfGroup(LargestNilpotentQuotient(G));   
  return(NilpotentQuotients(G)[c]);
  end);

############################################################################
##
#F  NQL_TerminatedNonInvariantNQ( <LpGroup>, <QS> )
##
## checks whether the non-invariant NQ already terminated.
##
InstallGlobalFunction( NQL_TerminatedNonInvariantNQ,
  function(G,Q)
  local H,	# nilpotent quotient of the invariant LpGroup
	EpiInv,	# epimorphism G->H
	fam,	# family of LpGroup-elements
	U,	# normal subgroup of H generated by the images of the fixed rels
	nat,	# natural homomorphism H->H/U
	c,	# nilpotency class of <Q>
	MGI,	# mapping generators images of EpiInv*nat
	Epi,	# epimorphism G->H/U
	NQs;	# new NilpotentQuotients

   # largest quotient system of the invariant L-presentation 
   ResetFilterObj(UnderlyingInvariantLPresentation(G),NilpotentQuotientSystem);
   SetNilpotentQuotientSystem(UnderlyingInvariantLPresentation(G),Q);

   # nilpotent quotient of the ascending L-presentation
   H:=PcpGroupByCollectorNC(Q.Pccol);

   # the epimorphism from the non-ascending presentation into <H> 
   EpiInv:=GroupHomomorphismByImagesNC(G,H,
  		  GeneratorsOfGroup(G),
                  MappingGeneratorsImages(Q.Epimorphism)[2]);
    
   # relators of G are objects of the free group of G
   fam:=ElementsFamily(FamilyObj(G));
  
   # determine the quotient of the non-ascending presentation
   U:=NormalClosure(H,Subgroup(H,List(FixedRelatorsOfLpGroup(G),
       	  			x->ElementOfLpGroup(fam,x)^EpiInv)));
  
   # natural homomorphism H -> H/U
   nat:=NaturalHomomorphism(H,U);

   # nilpotency class of <Q>
   c:=Maximum(Q.Weights);

   if NilpotencyClassOfGroup( Image(nat) ) < c then 
     return(true); 
   fi;

   # the epimorphism G -> H/U
   MGI:=MappingGeneratorsImages(EpiInv*nat);
   Epi:=GroupHomomorphismByImagesNC(G,Image(nat),MGI[1],MGI[2]);
 
   # store the epimorphism and the nilpotent quotient in NilpotentQuotients
   NQs:=ShallowCopy(NilpotentQuotients(G));
   NQs[c]:= Epi;
   ResetFilterObj(G,NilpotentQuotients);
   SetNilpotentQuotients(G,NQs);

   return(false);
   end);
