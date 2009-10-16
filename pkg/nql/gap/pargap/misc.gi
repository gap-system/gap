############################################################################
##
#W pargap/misc.gi		NQL				René Hartung
##
#H   @(#)$Id: misc.gi,v 1.1 2009/05/06 13:12:56 gap Exp $
##
Revision.("nql/gap/pargap/pargap_gi"):=
  "@(#)$Id: misc.gi,v 1.1 2009/05/06 13:12:56 gap Exp $";

############################################################################
##
#F NQLPar_CollectorToFunction( <coll> )
##
InstallGlobalFunction( NQLPar_CollectorToFunction,
  function( coll )
  local file,	# temporary file to store the collector <coll>
	orders,	# relative orders of <coll>
	n,	# number of generators of <coll>
	i,j;	# loop variables

  file := Filename( DirectoryTemporary(), "coll.g" );

  PrintTo( file, "local ftl;\n" );
  
  AppendTo( file, "ftl := FromTheLeftCollector( ",
                          NumberOfGenerators( coll ), " );\n");

  orders := RelativeOrders( coll );
  n := coll![ PC_NUMBER_OF_GENERATORS ];
  for i in Filtered( [ 1 .. n ], x -> orders[x] <> 0 ) do
    AppendTo( file, "SetRelativeOrder( ftl, ", i, ", ", orders[i] ," );\n" );
    AppendTo( file, "SetPower( ftl, ", i, ", ", GetPower( coll , i )," );\n");
    if IsBound( coll![ PC_POWERS ][i] ) then 
      AppendTo( file, "ftl![ PC_INVERSEPOWERS ][", i, "] := ", 
                      coll![ PC_INVERSEPOWERS ][i], ";\n");
    fi;
  od;

  for i in [ 1 .. n-1 ] do
    for j in [ i+1 .. n ] do
      AppendTo( file, "SetConjugate( ftl, ",j,", ",i,", ", 
                       GetConjugate( coll, j, i )," );\n");
      if orders[i] = 0 then 
        AppendTo( file, "SetConjugate( ftl, ",j,", ",-i,", ", 
                         GetConjugate( coll, j, -i )," );\n");
        if orders[j] = 0 then 
          AppendTo( file, "SetConjugate( ftl, ",-j,", ",-i,", ", 
                           GetConjugate( coll, -j, -i )," );\n");
        fi;
      elif orders[j] = 0 then 
        AppendTo( file, "SetConjugate( ftl, ",-j,", ",i,", ", 
                         GetConjugate( coll, -j, i )," );\n");
      fi;
    od;
  od;
  AppendTo( file, "FromTheLeftCollector_SetCommute( ftl );\n");
  AppendTo( file, "SetFeatureObj( ftl, IsUpToDatePolycyclicCollector,true);\n");
  AppendTo( file, "FromTheLeftCollector_CompleteConjugate( ftl );\n");
# redundant due to the < coll![ PC_INVERSEPOWERS ] > above
# AppendTo( file, "FromTheLeftCollector_CompletePowers( ftl );\n");
  AppendTo( file, "SetFeatureObj( ftl, IsUpToDatePolycyclicCollector,true);\n");
  AppendTo( file, "return( ftl );\n" );

  return( ReadAsFunction( file ) ); 

  end);


############################################################################
##
#F  NQLPar_MapRelations
##
ParInstallTOPCGlobalFunction( "NQLPar_MapRelations",
  function( Imgs, frels, irels )
  local F,	# the free group
	fam,	# elements family of the free group <F>
	FRels,	# the fixed relators as elements of <F>
	IRels,	# the iterated relators as elements of <F>
	H,	# the covering group
	Epi,	# the epimorphism onto the covering group
	rels,	# the relations FRels and IRels
	imgs,	# the images of <Rels>
	i, 	# loop variable
	SubmitTaskInput, DoTask, CheckTaskResult; # MasterSlave
	

  # initialize the free group
  F := FreeGroup( Length( Imgs ) );
  fam := ElementsFamily( FamilyObj( F ) );
  FRels := List( frels, x -> ObjByExtRep( fam, x ) );
  IRels := List( irels, x -> ObjByExtRep( fam, x ) );

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

  rels := Concatenation( FRels, IRels );
  imgs := [];
  
  SubmitTaskInput := TaskInputIterator( [ 1 .. Length( rels ) ] );

  DoTask := function( x )
    return( Exponents( Image( Epi, rels[x] ) ) );
    end;
  
  CheckTaskResult := function( input, output )
    if not IsList( output ) then Error("in computing the images"); fi;
    imgs[ input ] := output;
    return NO_ACTION;
    end;

  MasterSlave( SubmitTaskInput, DoTask, CheckTaskResult, Error );

  return( imgs );
  end);
