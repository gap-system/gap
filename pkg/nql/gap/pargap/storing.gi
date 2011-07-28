############################################################################
##
#W storing.gi			NQL				René Hartung
##
#H   @(#)$Id: storing.gi,v 1.2 2010/03/17 12:47:34 gap Exp $
##
Revision.("nql/gap/pargap/storing_gi"):=
  "@(#)$Id: storing.gi,v 1.2 2010/03/17 12:47:34 gap Exp $";

############################################################################
##
#M  ExtendQuotientSystem( <QuotSys> )
##
## Extends the quotient system for G/gamma_i(G) to a consistent quotient
## system for G/gamma_{i+1}(G).
##
InstallMethod( ExtendQuotientSystem,
  "using a multiple-core machine with ParGap; storing results", true,
  [ IsObject ], 2,
  function( Q )
  local c,		# nilpotency class 
	weights,	# weights of the generators 
	Defs,		# definitions of each generator of the covering group
	Imgs,		# images of the generators in the covering group
	ftl,		# collector of the covering group
	b,		# position of the first tail
	n,		# number of generators of the covering group
	HNF,		# Hermite normal form of the consistency rels/relators
        endo,Endo,	# the induced endomorphisms
        mat,Mats,	# matrix representations of the induced endomorphisms
	stack,		# stack for the spinning algorithm
	ev,evn,		# exponent vectors for the spinning algorithm
	QS,		# the extended quotient system
	i,		# loop variable
	Rels,		# the mapped relations
	IRels,FRels,	# the mapped iterated and fixed relations
	tmpParTrace,	# the old value of <ParTrace>
	dir,file,	# for storing the results
	time;

  if not NQLPar_StoreResults or not IsMaster() then
    TryNextMethod();
  fi;

  # storing the result
  dir  := DirectoryTemporary();
  file := Filename( dir, "NQLPar.g" );
  Info( InfoNQL, 1, "Storing results in \"", file, "\"" );

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
  Info( InfoNQL, 1, "Computing a polycyclic presentation ",
                    "for the covering group..." );
  UpdateNilpotentCollector( ftl, weights, Defs );

  # store the completed collector (incl. weights etc.)
  AppendTo( file, "func := ", NQLPar_CollectorToFunction( ftl ), ";\n");
  AppendTo( file, "weights := ", weights, ";\n" );
  AppendTo( file, "Defs := ", Defs, ";\n" );
  AppendTo( file, "Imgs := ", Imgs, ";\n" );

  # further initializations
  b := Position( weights, Maximum( weights ) );
  n := ftl![ PC_NUMBER_OF_GENERATORS ];
  
  # Check the consisistency relations
  Info( InfoNQL, 1, "Checking the consistency relations..." );
  HNF := NQLPar_CheckConsistencyRelations( ftl, weights );
 
  # store the HNF of the consistency-checks...
  AppendTo( file, "HNF := rec( Heads := ", HNF.Heads, ", mat := ", 
                   HNF.mat, " );\n");

  Info( InfoNQL, 1, "Broadcasting the slaves...");
  for i in [1..MPI_Comm_size()-1] do
    Info( InfoNQL, 2, "HOST", i,": ",SendRecvMsg("UNIX_Hostname();",i));
  od;

  # induce the endomorphisms to the cover
  Info( InfoNQL, 1, "Inducing the endomorphisms..." );
  Mats  := [];
  AppendTo( file, "Mats := [];;\n");
  for endo in EndomorphismsOfLpGroup( Q.Lpres ) do
    Endo := NQLPar_InduceEndomorphism( 
                       List( FreeGeneratorsOfLpGroup( Q.Lpres ), 
	                     x -> ExtRepOfObj( Image( endo, x ) ) ),
                       Defs, Imgs, weights );

    mat := List( [b..n], x -> Exponents( Image( Endo, 
                              GeneratorsOfGroup( Source( Endo ) )[ x ] ) ) );

    for i in [ 1 .. Length( mat ) ] do
      if not IsZero( mat[i]{[ 1 .. b-1 ]} ) then 
        Info( InfoNQL, 3, "not inducing an endomorphism of the multiplier");
        return( fail );
      else
        mat[i] := mat[i]{[b..n]};
      fi;
    od;
    Add( Mats, mat );
    AppendTo( file, "Add( Mats, ", mat , " );;\n" );
  od;

  Info( InfoNQL, 1, "Broadcasting the slaves...");
  for i in [1..MPI_Comm_size()-1] do
    Info( InfoNQL, 2, "HOST", i,": ",SendRecvMsg("UNIX_Hostname();",i));
  od;

  ParTrace:=true;
  Info( InfoNQL, 1, "Mapping the relations..." );
  AppendTo( file, "Rels := [];;\n" );
  Rels := NQLPar_MapRelationsStoring( Imgs, 
          Concatenation( List( FixedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ),
          List( IteratedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ) ), file );

  FRels := Rels{[ 1 .. Length( FixedRelatorsOfLpGroup( Q.Lpres ) ) ]};
  IRels := Rels{[ Length( FixedRelatorsOfLpGroup( Q.Lpres ) ) + 1 .. Length( Rels ) ]};

  if InfoLevel( InfoNQL ) >= 2 then 
    ParTrace := true;
  else
    ParTrace := false;
  fi;

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

  return( NQL_BuildNewCollector( Q, ftl, HNF, weights, Defs, Imgs ) );

  end);

############################################################################
##
#M  ExtendQuotientSystem( <QuotSys>, <func>, <HNF>, <mats>, <rels> )
##
## Extends the quotient system for G/gamma_i(G) to a consistent quotient
## system for G/gamma_{i+1}(G).
##
InstallOtherMethod( ExtendQuotientSystem,
  "using a multiple-core machine with ParGap; recovering results", true,
  [ IsObject, IsRecord, IsList, IsList ], 1,
  function( Q, HNF, Mats, Rels )
  local c,		# nilpotency class 
	weights,	# weights of the generators 
	Defs,		# definitions of each generator of the covering group
	Imgs,		# images of the generators in the covering group
	ftl,		# collector of the covering group
	b,		# position of the first tail
	n,		# number of generators of the covering group
        endo,Endo,	# the induced endomorphisms
        mat,		# matrix representations of the induced endomorphisms
	stack,		# stack for the spinning algorithm
	ev,evn,		# exponent vectors for the spinning algorithm
	QS,		# the extended quotient system
	i,		# loop variable
	IRels, FRels,	# the mapped iterated and fixed relations
	rels,		# the union of <IRels> and <FRels>
	nIRels,nFRels,	# number of mapped fixed relations
	tmpParTrace,	# the old value of <ParTrace>
	Defects,defects,# defects in <Rels>
   	dir,file,	# for storing the results
	time;

  if not IsMaster() then 
    TryNextMethod();
  fi;
 
  Info( InfoNQL, 1, "Continue calculations..." );

  # storing the results
  dir  := DirectoryTemporary();
  file := Filename( dir, "NQLPar.g" );
  Info( InfoNQL, 1, "Storing results in \"", file, "\"" );

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
# if IsFunction( func ) then 
#   ftl := func();;
# fi;

# if not IsFunction( func ) or not IsBound( ftl ) or 
#    not IsFromTheLeftCollectorRep( ftl ) then

    ftl := NQL_QSystemOfCoveringGroupByQSystem(Q.Pccol,weights,Defs,Imgs);

    # use tails-routine to complete the nilpotent presentation
    Info( InfoNQL, 1, "Computing a polycyclic presentation ",
                      "for the covering group..." );
    UpdateNilpotentCollector( ftl, weights, Defs );
# fi;

  # store the completed collector
# AppendTo( file, "func := ", NQLPar_CollectorToFunction( ftl ), ";\n");

  # further initializations
  b := Position( weights, Maximum( weights ) );
  n := ftl![ PC_NUMBER_OF_GENERATORS ];
  
  # Check the consisistency relations
  if Length( HNF.Heads ) = 0 then 
    Info( InfoNQL, 1, "Checking the consistency relations..." );
    HNF := NQLPar_CheckConsistencyRelations( ftl, weights );
  else 
    # broadcast the collector...
    ParEval( PrintToString( "fnc:=", NQLPar_CollectorToFunction( ftl ) ) );
    ParEval( "ftl := fnc();");
    ParEval( "Unbind( fnc );" );
  fi;
 
  # store the HNF of the consistency-checks...
  AppendTo( file, "HNF := rec( Heads := ", HNF.Heads, ", mat := ", 
                   HNF.mat, " );\n");

  Info( InfoNQL, 1, "Broadcasting the slaves...");
  for i in [1..MPI_Comm_size()-1] do
    Info( InfoNQL, 2, "HOST", i,": ",SendRecvMsg("UNIX_Hostname();",i));
  od;

  # store the induced matrices...
  AppendTo( file, "Mats := [];;\n");
  for mat in Mats do 
    AppendTo( file, "Add( Mats, ", mat , " );;\n" );
  od;

  # induce the endomorphisms to the cover
  if Length( Mats ) <> Length( EndomorphismsOfLpGroup( Q.Lpres ) ) then 
    Info( InfoNQL, 1, "Inducing the endomorphisms..." );
    for endo in EndomorphismsOfLpGroup( Q.Lpres ){[ Length( Mats ) + 1 .. Length( EndomorphismsOfLpGroup( Q.Lpres ) )]} do
      Endo := NQLPar_InduceEndomorphism( 
                         List( FreeGeneratorsOfLpGroup( Q.Lpres ), 
	                       x -> ExtRepOfObj( Image( endo, x ) ) ),
                         Defs, Imgs, weights );

      # computing matrix representation...
      mat := List( [b..n], x -> Exponents( Image( Endo, 
                                GeneratorsOfGroup( Source( Endo ) )[ x ] ) ) );

      for i in [ 1 .. Length( mat ) ] do
        if not IsZero( mat[i]{[ 1 .. b-1 ]} ) then 
          Info( InfoNQL, 3, "not inducing an endomorphism of the multiplier");
          return( fail );
        else
          mat[i] := mat[i]{[b..n]};
        fi;
      od;
      Add( Mats, mat );
      AppendTo( file, "Add( Mats, ", mat , " );;\n" );
    od;
  fi;
   
  Info( InfoNQL, 1, "Broadcasting the slaves...");
  for i in [1..MPI_Comm_size()-1] do
    Info( InfoNQL, 2, "HOST", i,": ",SendRecvMsg("UNIX_Hostname();",i));
  od;

  # store the mapped relations...
  AppendTo( file, "Rels := [ ];;\n" );
  nFRels := Length( FixedRelatorsOfLpGroup( Q.Lpres ) );
  nIRels := Length( IteratedRelatorsOfLpGroup( Q.Lpres ) );
  rels := Concatenation( FixedRelatorsOfLpGroup( Q.Lpres ),
                         IteratedRelatorsOfLpGroup( Q.Lpres ) );
  Defects := [];
  for i in [ 1 .. nFRels + nIRels ] do 
    if not IsBound( Rels[i] ) then
      Defects[i] := ExtRepOfObj( rels[i] );
    else
      AppendTo( file, "Rels[ ", i, " ] := ", Rels[i], ";;\n" );
    fi;
  od;

  ParTrace:=true;
  Info( InfoNQL, 1, "Mapping the relations..." );
 
  # fill up the mapped relations <Rels>
  defects := NQLPar_MapRelationsStoring( Imgs, Defects, file );
  for i in [ 1 .. Length( Defects ) ] do
    if IsBound( Defects[i] ) then 
      Rels[i] := defects[i];
    fi;
  od;
  FRels := Rels{[ 1 .. nFRels ]};
  IRels := Rels{[ nFRels + 1 .. Length( Rels ) ]};

  if InfoLevel( InfoNQL ) >= 2 then 
    ParTrace := true;
  else
    ParTrace := false;
  fi;

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

  return( NQL_BuildNewCollector( Q, ftl, HNF, weights, Defs, Imgs ) );

  end);


############################################################################
##
#F  NQLPar_MapRelationsStoring
##
ParInstallTOPCGlobalFunction( "NQLPar_MapRelationsStoring",
  function( Imgs, Rels, file )
  local F,	# the free group
	fam,	# elements family of the free group <F>
	H,	# the covering group
	Epi,	# the epimorphism onto the covering group
	rels,	# the relations FRels and IRels
	imgs,	# the images of <Rels>
	i, 	# loop variable
	SubmitTaskInput, DoTask, CheckTaskResult; # MasterSlave
	

  # initialize the free group
  F    := FreeGroup( Length( Imgs ) );
  fam  := ElementsFamily( FamilyObj( F ) );
  rels := [];
  for i in [ 1 .. Length( Rels ) ] do
    if IsBound( Rels[i] ) then 
      rels[i] := ObjByExtRep( fam, Rels[i] );
    fi;
  od;

  # initialize the covering group
  H := PcpGroupByCollectorNC( ReadEvalFromString( "ftl" ) );

  # initialize the epimorphism
  imgs := [];
  for i in [ 1 .. Length( Imgs ) ] do
    if IsInt( Imgs[i] ) then 
      imgs[i] := PcpElementByGenExpList( ReadEvalFromString( "ftl" ), 
                                        [ Imgs[i], 1 ] );
    else
      imgs[i] := PcpElementByGenExpList( ReadEvalFromString( "ftl" ), Imgs[i] );
    fi;
  od;
  Epi := GroupHomomorphismByImagesNC( F, H, GeneratorsOfGroup( F ), imgs );
  Unbind( imgs );

  # initialize the images
  imgs := [];
  
  SubmitTaskInput := TaskInputIterator( Filtered( [ 1 .. Length( rels ) ],
                                        i -> IsBound( rels[i] ) ) );

  DoTask := function( x )
    return( Exponents( Image( Epi, rels[x] ) ) );
    end;
  
  CheckTaskResult := function( input, output )
    if not IsList( output ) then Error("in computing the images"); fi;
    AppendTo( file, "Rels[",input,"] := ", output, ";;\n" );
    imgs[ input ] := output;
    return NO_ACTION;
    end;

  MasterSlave( SubmitTaskInput, DoTask, CheckTaskResult, Error );

  return( imgs );
  end);
