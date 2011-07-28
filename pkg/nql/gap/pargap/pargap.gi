############################################################################
##
#W pargap.gi			NQL				René Hartung
##
#H   @(#)$Id: pargap.gi,v 1.5 2010/03/17 12:47:34 gap Exp $
##
Revision.("nql/gap/pargap/pargap_gi"):=
  "@(#)$Id: pargap.gi,v 1.5 2010/03/17 12:47:34 gap Exp $";

############################################################################
##
#M  ExtendQuotientSystem( <QuotSys> )
##
## Extends the quotient system for G/gamma_i(G) to a consistent quotient
## system for G/gamma_{i+1}(G).
##
InstallMethod( ExtendQuotientSystem,
  "using a multiple-core machine with ParGap", true,
  [ IsObject ], 1,
  function( Q )
  local c,		# nilpotency class 
	weights,	# weights of the generators 
	Defs,		# definitions of each generator of the covering group
	Imgs,		# images of the generators in the covering group
	ftl,		# collector of the covering group
	b,		# position of the first tail
	n,		# number of generators of the covering group
	HNF,		# Hermite normal form of the consistency rels/relators
        endo,Endos,	# the induced endomorphisms
        mat,Mats,	# matrix representations of the induced endomorphisms
	stack,		# stack for the spinning algorithm
	ev,evn,		# exponent vectors for the spinning algorithm
	QS,		# the extended quotient system
	i,		# loop variable
	Rels,		# the mapped relations
	IRels,FRels,	# the mapped iterated and fixed relations
	tmpParTrace,	# the old value of <ParTrace>
	time;

  # do not try to call this Master-function on the slaves
  if not IsMaster() then  
    TryNextMethod();
  fi;

  # enable/disable tracing in ParGap w.r.t. InfoNQL
  tmpParTrace := ParTrace;
  if InfoLevel( InfoNQL ) >= 2 then 
    ParTrace := true;
  else
    ParTrace := false;
  fi;

  # just to be sure...
  FlushAllMsgs();

  # initialization
  c       := Maximum( Q.Weights );
  weights := ShallowCopy( Q.Weights );
  Defs    := ShallowCopy( Q.Definitions );
  Imgs    := ShallowCopy( Q.Imgs );
  
  # quotient system of the covering group
  ftl := NQL_QSystemOfCoveringGroupByQSystem(Q.Pccol,weights,Defs,Imgs);

  # use tails-routine to complete the nilpotent presentation
  Info( InfoNQL, 1, "Computing a polycyclic presentation for the covering group..." );
  UpdateNilpotentCollector( ftl, weights, Defs );

  # further initializations
  b := Position( weights, Maximum( weights ) );
  n := ftl![ PC_NUMBER_OF_GENERATORS ];
  
  # Check the consisistency relations
  Info( InfoNQL, 1, "Checking the consistency relations..." );
  HNF := NQLPar_CheckConsistencyRelations( ftl, weights );

  Info( InfoNQL, 1, "Broadcasting the slaves...");
  for i in [1..MPI_Comm_size()-1] do
    Info( InfoNQL, 2, "HOST", i,": ",SendRecvMsg("UNIX_Hostname();",i));
  od;

# ELIMINATE here!

  # build the endomorphisms
  Info( InfoNQL, 1, "Inducing the endomorphisms..." );
  Endos := [];
  for endo in EndomorphismsOfLpGroup( Q.Lpres ) do
    Add( Endos, NQLPar_InduceEndomorphism( 
                       List( FreeGeneratorsOfLpGroup( Q.Lpres ), 
	                     x -> ExtRepOfObj( Image( endo, x ) ) ),
                       Defs, Imgs, weights ) );
  od;

  # compute matrix representation of the endomorphisms 
  Mats := [];
  for endo in Endos do
    mat := List( [b..n], x -> Exponents( Image( endo, 
                              GeneratorsOfGroup( Source( endo ) )[ x ] ) ) );

    for i in [ 1 .. Length( mat ) ] do
      if not IsZero( mat[i]{[ 1 .. b-1 ]} ) then 
        Info( InfoNQL, 3, "not inducing an endomorphism of the multiplier");
        return( fail );
      else
        mat[i] := mat[i]{[b..n]};
      fi;
    od;
    Add( Mats, mat );
  od;
   
  Info( InfoNQL, 1, "Broadcasting the slaves...");
  for i in [1..MPI_Comm_size()-1] do
    Info( InfoNQL, 2, "HOST", i,": ",SendRecvMsg("UNIX_Hostname();",i));
  od;

  ParTrace:=true;
  Info( InfoNQL, 1, "Mapping the relations..." );
  Rels := NQLPar_MapRelations( Imgs, 
          List( FixedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ),
          List( IteratedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ) );

  FRels := Rels{[ 1 .. Length( FixedRelatorsOfLpGroup( Q.Lpres ) ) ]};
  IRels := Rels{[ Length( FixedRelatorsOfLpGroup( Q.Lpres ) ) + 1 .. Length( Rels ) ]};

  if InfoLevel( InfoNQL ) >= 2 then 
    ParTrace := true;
  else
    ParTrace := false;
  fi;

# READ OFF POWER RELATIONS AS HNF FOR THE TAILS...

  Info( InfoNQL, 1, "Start spinning..." );
  # start the spinning algorithm
  for i in [ 1 .. Length( FRels ) ] do
    NQL_AddRow( HNF, FRels[i]{[b..n]} );
  od;

  stack := List( IRels, x -> x{[b..n]} );
  for i in [ 1 .. Length( stack ) ] do 
    NQL_AddRow( HNF, stack[i] );
  od;

  while IsBound( stack[1] ) do
    ev := stack[1];
    Remove( stack, 1 );

    if not IsZero(ev) then 
      for mat in Mats do 
        evn := ev * mat;
        if NQL_AddRow( HNF, evn ) then 
          Add( stack, evn );
        fi;
      od;
    fi;
  od;


  Info( InfoNQL, 1, "Extend the quotient system..." );
  if Length(HNF.mat)=0 then 
    # the presentation ftl satisfy the relations and is consistent
    QS := rec( Lpres       := Q.Lpres,
               Weights     := weights,
	       Definitions := Defs,
               Pccol       := ftl,
               Imgs	   := ShallowCopy( Imgs ) );

    Imgs:=[];
    for i in [ 1 .. Length( QS.Imgs ) ] do 
      if IsInt( QS.Imgs[i] ) then 
        Add( Imgs, PcpElementByGenExpList( QS.Pccol, [ QS.Imgs[i], 1 ] ) );
      else
        Add( Imgs, PcpElementByGenExpList( QS.Pccol, QS.Imgs[i] ) );
      fi;
    od;
    QS.Epimorphism := GroupHomomorphismByImagesNC( Q.Lpres,
                           PcpGroupByCollectorNC( QS.Pccol ),
			   GeneratorsOfGroup( Q.Lpres ), Imgs );

    ParTrace := tmpParTrace;
    ParEval( "Unbind( ftl );" );
    return(QS);
  fi;

  # recover the current setting
  ParTrace := tmpParTrace;
  ParEval( "Unbind(ftl);" );

## MODIFY THE BuildNewCollector-ROUTINE!

  return( NQL_BuildNewCollector( Q, ftl, HNF, weights, Defs, Imgs ) );

  end);

