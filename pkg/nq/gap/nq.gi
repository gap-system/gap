##############################################################################
##
#A  nq.gi                     Oktober 2002                       Werner Nickel
##
##  This file contains the interface to my NQ program.
##

#############################################################################
##
#F  NqBuildManual( ) . . . . . . . . . . . . . . . . . . . . build the manual
##
##  This function builds the manual of the NQ package in the file formats
##  &LaTeX;, DVI, Postscript, PDF and HTML.
##
##  This is done using the GAPDoc package by Frank L\"ubeck and
##  Max Neunh\"offer.
##
InstallGlobalFunction( NqBuildManual,
function ( ) local  NqDocDir;

  ##  We take the first package directory.  In most cases this is the one 
  ##  loaded by RequirePackage().
  NqDocDir := DirectoriesPackageLibrary( "nq", "doc" )[1];

  MakeGAPDocDoc( NqDocDir, "nqman", [ "../PackageInfo.g" ],
                 "nq", "../../../", "MathJax" );

  ##  Copy CSS files into the doc directory.
  ##  TODO: This function is new in GAPDoc 1.4, which is not yet released,
  ##  hence this call is disabled for now.
  #CopyHTMLStyleFiles( NqDocDir );
end );

#############################################################################
##
#V  NqRuntime . . . . . . . . . . reports the run time used by the nq program
##
##  Initialize the runtime variable.
##
MakeReadWriteGlobal( "NqRuntime" );
NqRuntime := 0;
MakeReadOnlyGlobal( "NqRuntime" );

#############################################################################
##
#V  NqGapOutput
##
MakeReadWriteGlobal( "NqGapOutput" );
NqGapOutput := false;

#############################################################################
##
#V  NqDefaultOptions. . . . . . . . . . .  default options for the nq program
##
##  The default options are:
##      -g      Produce GAP output including a GAP readable presentation of
##              the nilpotent quotient
##      -p      do not print the pc-presentation of the nilpotent quotient
##      -C      use the combinatorial collector
##      -s      check only instances with semigroup words - this is only
##              relevant if one of the Engel options is used
##
InstallValue( NqDefaultOptions,  [ "-g", "-p", "-C", "-s" ] );


#############################################################################
##
#V  NqOneTimeOptions . . . . . . . . . .  one time options for the nq program
##
##  This variable can be used to pass a list of options to the next call of
##  the nq program.
##
MakeReadWriteGlobal( "NqOneTimeOptions" );
NqOneTimeOptions := [];

#############################################################################
##
#V  NqParameterStrings . . . . . . . .  strings for options to the standalone
##
##  This list contains strings for the options that are used by
##  NilpotentQuotient().
##
NqParameterStrings := [ "group",        ##  These three options provide
                        "exptrees",     ##  a way for specifying a 
                        "input_file",   ##  finitely presented group.
                        "input_string",         
                      
                        "output_file",  ##  This option is used to keep 
                                        ##  the output of the standalone.  

                                        ##  Option to specify the
                        "class",        ##  nilpotency class of the
                                        ##  quotient. 

                                        ##  Option to specify identical
                        "idgens",       ##  generators.


                        "engel",        ##  Specifies an Engel law

                        "options",      ##  A list of options to pass to the
                                        ##  standalone.
];

##
##  There are several different ways to specify the finitely presented group
##  for the nilpotent quotient algorithm:
##
##  As 
##      a finitely presented group
##      a finitely presented group given by expression trees
##      an input file for the standalone
##      a string in the input format of the standalone
##
NqPrepareInput := function( params )
    local   str;

    if IsBound( params.group ) then
        str := NqStringFpGroup( params.group, params.idgens );
        params.input_string := str;
        params.input_stream := InputTextString( str );
    fi;

    if IsBound( params.exptrees ) then
        str := NqStringExpTrees( params.exptrees, params.idgens );
        params.input_string := str;
        params.input_stream := InputTextString( str );
    fi;

    if IsBound( params.input_string ) then
        str := params.input_string;
        params.input_string := str;
        params.input_stream := InputTextString( str );
    fi;

    if IsBound( params.input_file ) then
        params.input_stream := InputTextFile( params.input_file );
    fi;
end;

##
##  There are several different ways to specify the output for the nilpotent
##  quotient algorithm: 
##
##  As 
##      an output stream
##      an output file (which is kept for later use)
##
NqPrepareOutput := function( params )

    if IsBound( params.output_file ) then
      params.output_stream := OutputTextFile( params.output_file, false );

    else
      params.output_string := "";
      params.output_stream := OutputTextString( params.output_string, false );
    fi;
end;

NqCompleteParameters := function( params )
    local   opt_rec,  options,  opt;

    if OptionsStack <> [] then
        opt_rec := OptionsStack[ Length(OptionsStack) ];
        options := RecNames( opt_rec );

        for opt in options do
            if not opt in NqParameterStrings then
                Error( "unknown option ", opt );
                return fail;
            fi;
            
            if IsBound( params.(opt) ) then
                Error( "Option ", opt, " already given as argument" );
                return fail;
            fi;
            
            if IsBound( params.(opt) ) then
                InfoWarning( "overwriting parameter with option '", opt, "'" );
            fi;

            if opt = "group" and IsRecord( opt_rec.(opt) ) then
                params.exptrees := opt_rec.(opt);
            else
                params.(opt) := opt_rec.(opt);
            fi;
        od;
    fi;

    if not IsBound( params.idgens ) then
        params.idgens := [];
    fi;

    NqPrepareInput( params );
    NqPrepareOutput( params );

    if not IsBound( params.options ) then
        params.options := [];
    fi;
    if InfoLevel( InfoNQ ) > 0 then
        Add( params.options, "-v" );
    fi;
    params.options := Concatenation( NqDefaultOptions, 
                              params.options,
                              NqOneTimeOptions );
    NqOneTimeOptions := [];

    if IsBound( params.class ) then
        Add( params.options, String(params.class) );
    fi;
    if IsBound( params.engel ) then
        Add( params.options, "-e" );
        Add( params.options, String(params.engel) );
    fi;
end;

#############################################################################
##
#F  NqCallANU_NQ . . . . . . . . . . . the function that calls the nq program
##
NqCallANU_NQ := function( params )
    local   nq,  ret;

    NqCompleteParameters( params );

    nq      := Filename( DirectoriesPackagePrograms("nq") , "nq" );

    Info( InfoNQ, 3, "Calling ANU NQ with: ", params, "\n" );

    ret    := Process( DirectoryCurrent(),           ## executing directory
                      nq,                            ## executable
                      params.input_stream,           ## input  stream
                      params.output_stream,          ## output stream
                      params.options );              ## command line arguments

    Info( InfoNQ, 3, "ANU NQ returns ", ret, "\n" );

    CloseStream( params.input_stream );
    CloseStream( params.output_stream );

    if IsBound( params.output_file ) then
        return NqReadOutput( InputTextFile( params.output_file ) );
    else
        return NqReadOutput( InputTextString( params.output_string ) );
    fi;
end;


#############################################################################
##
#F  NqGlobalVariables . . global variables to communicate with the nq program
##
InstallValue( NqGlobalVariables,
        [ "NqLowerCentralFactors",   ##  factors of the LCS
          "NqNrGenerators",
          "NqClass",
          "NqRanks",
          "NqRelativeOrders",
          "NqImages",                ##  the epimorphism
          "NqPowers",
          "NqConjugates",
          "NqRuntime",
          ] );

#############################################################################
##
#F  NqReadOutput  . . . . . . . . . . . . . . . . read output from nq program
##
InstallGlobalFunction( NqReadOutput,
function( stream )
    local   var,  result,  n;

    for var in NqGlobalVariables do
        HideGlobalVariables( var );
    od;

    Read( stream );

    result := rec();

    for var in NqGlobalVariables do
        n := Length(var);
        if IsBoundGlobal( var ) then
            result.(var{[3..n]}) := ValueGlobal( var );
        else
            result.(var{[3..n]}) := fail;
        fi;
    od;

    for var in NqGlobalVariables do
        UnhideGlobalVariables( var );
    od;
    
    MakeReadWriteGlobal( "NqRuntime" );
    NqRuntime := result.Runtime;
    MakeReadOnlyGlobal( "NqRuntime" );

    if result.NrGenerators = fail then
        Error( "nq program terminated abnormally.\n\n",
               "To return the abelian invariants of the first ",
               Length( result.LowerCentralFactors ), " factors of the\n",
               "lower central series type `return;'",
               " and `quit;' otherwise.\n\n" );
        
        return List( result.LowerCentralFactors, NqElementaryDivisors );
    fi;

    return result;
end );


#############################################################################
##
#F  NqStringFpGroup( <fp> ) . . . . . . .  finitely presented group to string
##
InstallGlobalFunction( NqStringFpGroup,
function( arg )
    local   G,  idgens,  F,  fgens,  str,  newgens,  pos,  i,  r;

    G      := arg[1];
    idgens := [];
    if Length( arg ) = 2 then idgens := arg[2]; fi;

    F     := FreeGroupOfFpGroup( G );
    fgens := GeneratorsOfGroup( F );

    if not IsSubset( fgens, idgens ) then
        Error( "identical generators are not a subset of free generators" );
    fi;

    if Length( fgens ) = 0 then
        # Produce a dummy presentation, since NQ cannot handle presentations
        # without generators.

        str := "< x | x >\n";
        return str;
    fi;

    newgens := GeneratorsOfGroup( FreeGroup( Length( fgens ), "x" ) );
    
    str := "";
    Append( str, "< " );
    
    pos := List( idgens, g->Position( fgens, g ) );
    for i in Difference( [1..Length(fgens)], pos ) do
	Append( str, String( newgens[i] ) );
        Append( str, ", " );
    od;
    Unbind( str[ Length(str) ] ); Unbind( str[ Length(str) ] );

    ##  Insert seperator between free and identical generators.
    Append( str, "; " );

    for i in pos do
	Append( str, String( newgens[i] ) );
        Append( str, ", " );
    od;
    Unbind( str[ Length(str) ] ); Unbind( str[ Length(str) ] );
    
    Append( str, " |\n" );

    for r in RelatorsOfFpGroup( G ) do
        if Length( r ) > 0 then
            Append( str, "    " );
            Append( str, String( MappedWord( r, fgens, newgens ) ) );
            Append( str, ",\n" );
        fi;
    od;
    if str[ Length(str)-1 ] = ',' then
        Unbind( str[ Length(str) ] );
        Unbind( str[ Length(str) ] );
    fi;
        
    Append( str, "\n>\n" );
    return str;
end );

#############################################################################
##
#F  NqStringExpTrees( <fp> ) . . . . . . . . . . . expression trees to string
##
InstallGlobalFunction( NqStringExpTrees,
function( arg )
    local   G,  idgens,  fgens,  str,  g,  r;

    G      := arg[1];
    idgens := [];
    if Length( arg ) = 2 then idgens := arg[2]; fi;

    fgens := G.generators;

    if not IsSubset( fgens, idgens ) then
        Error( "identical generators are not a subset of free generators" );
    fi;
    fgens := Difference( fgens, idgens );

    if Length( fgens ) = 0 then
        # Produce a dummy presentation, since NQ cannot handle presentations
        # without generators.

        str := "< x | x >\n";
        return str;
    fi;
    
    # Set flag to signal the print functions (which are called by String)
    # that we want commutators in square bracket.  I don't like that hack. 
    str := "";
    Append( str, "< " );
    
    for g in fgens do
	Append( str, String( g ) );
        Append( str, ", " );
    od;
    Unbind( str[ Length(str) ] );
    Unbind( str[ Length(str) ] );
    Append( str, "; " );
    for g in idgens do
	Append( str, String( g ) );
        Append( str, ", " );
    od;
    Unbind( str[ Length(str) ] );
    Unbind( str[ Length(str) ] );

    Append( str, " |\n" );

    for r in G.relations do
        Append( str, "    " );
        Append( str, String( r ) );
        Append( str, ",\n" );
    od;
    if str[ Length(str)-1 ] = ',' then
        Unbind( str[ Length(str) ] );
        Unbind( str[ Length(str) ] );
    fi;
        
    Append( str, "\n>\n" );

    # reset flag
    return str;
end );

#############################################################################
##
#F  NqElementaryDivisors( <M> ) . . . . . . . . . . . . . elementary divisors
##
##  The function 'ElementaryDivisorsMat' only returns the non-zero elementary
##  divisors of a matrix. Here zeroes are added in order to make it easier to
##  recognize  the isomorphism  type of  the abelian  group presented  by the
##  integer matrix.  At the same time  strip 1's from the  list of elementary
##  divisors.
##
InstallGlobalFunction( NqElementaryDivisors,
function( M )
    local   ed,  i;

    if M <> [ [] ] then
        ed := ElementaryDivisorsMat( M );
    else
        ed := [];
    fi;

    ed := Concatenation( ed, List( [Length(ed)+1..Length(M[1])], x->0 ) );
    i := 1;
    while i <= Length(ed) and ed[i] = 1  do i := i+1;  od;
    ed := ed{[i..Length(ed)]};

    return ed;
end );


#############################################################################
##
#F  NilpotentQuotient( <F>, <class> ) . . . . . . . nilpotent quotient of <F>
##
##  The interface to the NQ standalone.  
##
##  The operation has methods for the following arguments:
##
##                 fp-group
##     outfile     fp-group
##                 fp-group      ident-gens
##     outfile     fp-group      ident-gens
##                 fp-group                   class
##     outfile     fp-group                   class
##                 fp-group      ident-gens   class
##     outfile     fp-group      ident-gens   class
##                 infile
##     outfile     infile
##                 infile                     class
##     outfile     infile                     class
##
##  If this function is called with an fp-group only, we check for options on
##  the options stack.  The following options are used:
##      output_file
##      input_string
##      nilpotency_class, class
##      identical_generators, idgens
##
##  This should produce a quotient system and not a pcp group.
##
InstallOtherMethod( NilpotentQuotient,
        "no argument",
        true,
        [], 
        0,
function()

    return NqPcpGroupByNqOutput( NqCallANU_NQ( rec() ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group",
        true,
        [ IsFpGroup ], 
        0,
function( G )

    return NqPcpGroupByNqOutput( NqCallANU_NQ( rec( group := G ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group, keep output file",
        true, 
        [ IsString, IsFpGroup ], 
        0,
function( outfile, G )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ( 
                           rec( group := G, 
                                output_file := outfile ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group on file",
        true,
        [ IsString ], 
        0,
function( infile )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ( rec( input_file := infile ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group on file, keep output file",
        true, 
        [ IsString, IsString ], 
        0,
function( outfile, infile )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ( 
                           rec( input_file  := infile,
                                output_file := outfile ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group",
        true,
        [ IsRecord ], 
        0,
function( G )

    return NqPcpGroupByNqOutput( NqCallANU_NQ( rec( exptrees := G ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group with identical relations",
        true,
        [ IsFpGroup, IsList ], 
        0,
function( G, idgens )
    
    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( group  := G,
                                idgens := idgens ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group with identical relations",
        true,
        [ IsRecord, IsList ], 
        0,
function( G, idgens )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( exptrees := G,
                                idgens   := idgens ) ) );
end );

InstallMethod( NilpotentQuotient,
        "of a finitely presented group",
        true,
        [ IsFpGroup, IsPosInt ], 
        0,
function( G, cl )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( group := G,
                                class := cl ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group, keep output file",
        true, 
        [ IsString, IsFpGroup, IsPosInt ], 
        0,
function( outfile, G, cl )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( group := G,
                                class := cl,
                                output_file := outfile ) ) );
end );

InstallMethod( NilpotentQuotient,
        "of a finitely presented group on file",
        true,
        [ IsString, IsPosInt ], 
        0,
function( infile, cl )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( input_file := infile,
                                class      := cl ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group on file, keep output file",
        true, 
        [ IsString, IsString, IsPosInt ], 
        0,
function( outfile, infile, cl )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( input_file := infile,
                                output_file := outfile,
                                class       := cl ) ) );
end );

InstallMethod( NilpotentQuotient,
        "of a finitely presented group",
        true,
        [ IsRecord, IsPosInt ], 
        0,
function( G, cl )

    return NqPcpGroupByNqOutput(
                   NqCallANU_NQ(
                           rec( exptrees := G,
                                class    := cl ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group with identical relations",
        true,
        [ IsFpGroup, IsList, IsPosInt ], 
        0,
function( G, idgens, cl )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( group := G,
                                idgens := idgens,
                                class := cl ) ) );
end );

InstallOtherMethod( NilpotentQuotient,
        "of a finitely presented group with identical relations",
        true,
        [ IsRecord, IsList, IsPosInt ], 
        0,
function( G, idgens, cl )

    return NqPcpGroupByNqOutput( 
                   NqCallANU_NQ(
                           rec( exptrees := G,
                                idgens   := idgens,
                                class    := cl ) ) );
end );


#############################################################################
##
#F  NqEpimorphismNilpotentQuotient
##
##
InstallGlobalFunction( NqEpimorphismByNqOutput,
function( G, nqrec )
    local   coll,  A,  gens,  freegens,  images,  idgens,  U,  phi;

    coll  := NqInitFromTheLeftCollector( nqrec );
    A     := NqPcpGroupByCollector( coll, nqrec );

    ##
    ##  Now we set up the epimorphism.
    ##  We need to be careful about identical generators.
    ##
    gens   := GeneratorsOfGroup( G );
    idgens := ValueOption( "idgens" );

    images   := List( nqrec.Images, w->NqPcpElementByWord( coll, w ) );


    if idgens <> fail then
        freegens := List( gens, UnderlyingElement );
    
        gens := gens{Difference( [1..Length(gens)], 
                        List( idgens, g->Position( freegens, g ) ) )};

        U := Subgroup( G, gens );
        phi := GroupHomomorphismByImagesNC( U, A, gens, images );
    else
        phi := GroupHomomorphismByImagesNC( G, A, gens, images );
    fi;

    SetFeatureObj( phi, IsFromFpGroupStdGensGeneralMappingByImages, true );
    SetIsSurjective( phi, true );

    return phi;
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "no argument",
        true,
        [ ],
        0,
function( )
    local   input_rec,  nqrec,  G;

    input_rec := rec();
    nqrec := NqCallANU_NQ( input_rec );
    G := input_rec.group;

    return NqEpimorphismByNqOutput( G, nqrec );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "fp-group",
        true,
        [ IsFpGroup ],
        0,
function( G )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group := G ) );
    return NqEpimorphismByNqOutput( G, nqrec );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "output-file, fp-group",
        true,
        [ IsString, IsFpGroup ],
        0,
function( outfile, G )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group := G, output_file := outfile ) );

    return NqEpimorphismByNqOutput( G, nqrec );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "fp-group, class",
        true,
        [ IsFpGroup, IsPosInt ],
        0,
function( G, cl )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group := G, class := cl ) );
    return NqEpimorphismByNqOutput( G, nqrec );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "output-file, fp group, class",
        true,
        [ IsString, IsFpGroup, IsPosInt ],
        0,
function( outfile, G, cl )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group := G, 
                                class := cl,
                                output_file := outfile ) );

    return NqEpimorphismByNqOutput( G, nqrec );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "fp-group, id-gens",
        true,
        [ IsFpGroup, IsList ],
        0,
function( G, idgens )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group := G, idgens := idgens ) );
    return NqEpimorphismByNqOutput( G, nqrec : idgens := idgens );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "output-file, fp-group, idgens",
        true,
        [ IsString, IsFpGroup, IsList ],
        0,
function( outfile, G, idgens )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group       := G, 
                                output_file := outfile,
                                idgens      := idgens ) );

    return NqEpimorphismByNqOutput( G, nqrec : idgens := idgens );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "fp-group, idgens, class",
        true,
        [ IsFpGroup, IsList, IsPosInt ],
        0,
function( G, idgens, cl )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group := G, class := cl, idgens := idgens ) );
    return NqEpimorphismByNqOutput( G, nqrec : idgens := idgens );
end );

InstallOtherMethod( NqEpimorphismNilpotentQuotient,
        "output-file, fp group, idgens, class",
        true,
        [ IsString, IsFpGroup, IsList, IsPosInt ],
        0,
function( outfile, G, idgens, cl )
    local   nqrec;

    nqrec := NqCallANU_NQ( rec( group := G, 
                                class := cl,
                                output_file := outfile,
                                idgens := idgens ) );

    return NqEpimorphismByNqOutput( G, nqrec : idgens := idgens );
end );

#############################################################################
##
#F  LowerCentralFactors
##
##
InstallGlobalFunction( LowerCentralFactors,
function( arg )
    local   A;

    A := CallFuncList( NilpotentQuotient, arg );

    return A!.LowerCentralFactors;
end );

#############################################################################
##
#F  NilpotentEngelQuotient( <F>, <engel>, <class> ) . . . . . Engel nq of <F>
##
InstallGlobalFunction( NilpotentEngelQuotient,
function( arg )
    local   n,  i;

    ## The first integer is the Engel parameter.
    n := First( arg, IsInt );
    i := Position( arg, n );

    arg := Concatenation( arg{[1..i-1]}, arg{[i+1..Length(arg)]} );

    NqOneTimeOptions := [ "-e", String(n) ];
    return CallFuncList( NilpotentQuotient, arg );
end );
    
