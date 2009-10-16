#############################################################################
##
#A  anupq.g                     GAP share library              Eamonn O'Brien
#A                                                             & Frank Celler
##
#A  @(#)$Id: anupq.g,v 1.1.1.1 2001/04/15 13:39:19 werner Exp $
##
#Y  Copyright 1992-1994,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1992-1994,  School of Mathematical Sciences, ANU,     Australia
##
#H  $Log: anupq.g,v $
#H  Revision 1.1.1.1  2001/04/15 13:39:19  werner
#H  Importing the GAP 4 version of ANUPQ.                                    WN
#H
#H  Revision 1.2  2000/07/12 17:00:06  werner
#H  Further work towards completing the GAP 4 interface to the ANU PQ.
#H                                                                      WN
#H
#H  Revision 1.1.1.1  1998/08/12 18:50:54  gap
#H  First attempt at adapting the ANU pq to GAP 4. 
#H
##


#############################################################################
##
##  ANUPQoptions[]  . . . . . . . . . . . . . . . . . . .  admissible options
##
ANUPQoptions := [ "Prime", 
                  "ClassBound", 
                  "Exponent", 
                  "Metabelian", 
                  "OutputLevel", 
                  "Verbose", 
                  "SetupFile" ] ;

#############################################################################
##
#F  ANUPQerrorPq( <param> ) . . . . . . . . . . . . . . . . . report an error
##
ANUPQerrorPq := function( param )
    Error(
    "Valid Options:\n",
    "    \"ClassBound\", <bound>\n",
    "    \"Prime\", <prime>\n",
    "    \"Exponent\", <exponent>\n",
    "    \"Metabelian\"\n",
    "    \"OutputLevel\", <level>\n",
    "    \"Verbose\"\n",
    "    \"SetupFile\", <file>\n",
    "Illegal Parameter: \"", param, "\"" );
end;


#############################################################################
##
#F  ANUPQextractPqArgs( <args> )  . . . . . . . . . . . . . extract arguments
##
ANUPQextractPqArgs := function( args )
    local   CR,  i,  act,  match;

    # allow to give only a prefix
    match := function( g, w )
    	return 1 < Length(g) 
               and Length(g) <= Length(w) 
               and w{[1..Length(g)]} = g;
    end;

    # extract arguments
    CR := rec();
    i  := 2;
    while i <= Length(args)  do
        act := args[i];
        if not IsString( act ) then ANUPQerrorPq( act ); fi;

    	# "ClassBound", <class>
        if match( act, "ClassBound" ) then
            i := i + 1;
            CR.ClassBound := args[i];

    	# "Prime", <prime>
        elif match( act, "Prime" )  then
            i := i + 1;
            CR.Prime := args[i];

    	# "Exponent", <exp>
        elif match( act, "Exponent" )  then
            i := i + 1;
            CR.Exponent := args[i];

        # "Metabelian"
        elif match( act, "Metabelian" ) then
            CR.Metabelian := true;

    	# "Output", <level>
        elif match( act, "OutputLevel" )  then
            i := i + 1;
            CR.OutputLevel := args[i];
    	    CR.Verbose     := true;

    	# "SetupFile", <file>
        elif match( act, "SetupFile" )  then
    	    i := i + 1;
            CR.SetupFile := args[i];

    	# "Verbose"
        elif match( act, "Verbose" ) then
            CR.Verbose := true;

    	# signal an error
    	else
            ANUPQerrorPq( act );

    	fi; 
    	i := i + 1; 
    od;
    return CR;

end;

ANUPQGlobalVariables := [ "F",          #  a free group
                          "MapImages",  #  images of the generators in G
                          ];

#############################################################################
##
#F  ANUPQReadOutput . . . . read pq output without affecting global variables
##
ANUPQReadOutput := function( file, globalvars )
    local   var,  result;

    for var in globalvars do
        HideGlobalVariables( var );
    od;

    Read( file );

    result := rec();

    for var in globalvars do
        if IsBoundGlobal( var ) then
            result.(var) := ValueGlobal( var );
        else
            result.(var) := fail;
        fi;
    od;

    for var in globalvars do
        UnhideGlobalVariables( var );
    od;
    
    return result;
end;


#############################################################################
##
#F  PqEpimorphism   . . . . . . . . . . . . . . .  epimorphism onto a p-group
##
PqEpimorphism := function( arg )
    local   F,  Fgens,  gens,  x,  r,  outname,  pq,  input,  phi,
            output,  proc,  result,  images,  CR,  string,  cmd;

    # check arguments
    if Length(arg) < 1  then
    	Error( "usage: Pq( <F>, <control-args>, ... )" );
    fi;
    F := arg[1];
    if not IsFpGroup( F ) then
    	Error( "<F> must be a finitely presented group" );
    fi;
    if Length(arg) < 2 or not IsRecord(arg[2])  then
    	CR := ANUPQextractPqArgs( arg );
    else
    	CR := ShallowCopy(arg[2]);
    	x := Set( REC_NAMES(CR) );
    	SubtractSet( x, Set( ANUPQoptions ) );
    	if 0 < Length(x)  then
    	    ANUPQerrorPq(x);
    	fi;
    fi;

    # at least "Prime" and "Class" must be given
    if not IsBound(CR.Prime)  then
    	Error( "you must supply a prime" );
    fi;
    if not IsBound(CR.ClassBound)  then
    	Error( "you must supply a class bound" );
    fi;

    # set default values
    if not IsBound(CR.Exponent)  then 
    	CR.Exponent := 0;
    fi;
    if not IsBound(CR.Verbose) then 
    	CR.Verbose := false;
    fi;

    string := "#input file for pq\n";

    # setup input string
    Append( string, "1\n" );
    cmd := Concatenation( "prime ", String(CR.Prime), " \n" );
    Append( string, cmd );
    cmd := Concatenation( "class ", String(CR.ClassBound), " \n" );
    Append( string, cmd );
    if CR.Exponent <> 0  then
        cmd := Concatenation( "exponent ", String(CR.Exponent), "\n" );
        Append( string, cmd );
    fi;
    if IsBound(CR.Metabelian)  then 
        Append( string, "metabelian\n" );
    fi;
    if IsBound(CR.OutputLevel)  then
        cmd := Concatenation( "output ", CR.OutputLevel, " \n" );
    	Append( string, cmd );
    fi;

    # create generic generators "g1" ... "gn"
    Fgens := GeneratorsOfGroup( FreeGroupOfFpGroup(F) );
    gens := GeneratorsOfGroup( FreeGroup( Length( Fgens ), "g" ) );
    Append( string, "generators {" );
    for x  in gens  do
    	Append( string, String(x) );
        Append( string, ", " );
    od;
    Append( string, " }\n" );

    # write the presentation using these generators
    Append( string, "relations {" );
    for r  in RelatorsOfFpGroup(F)  do
        Append( string, String( MappedWord(r,Fgens,gens) ) );
        Append( string, ",\n" );
    od;
    Append( string, "}\n;\n" );
    
    # if we only want to setup the file we are ready now
    if IsBound(CR.SetupFile)  then
        Append( string, "8\n25\nPQ_OUTPUT\n2\n0\n0\n" );
    	Print( "#I  input file '", CR.SetupFile, "' written,\n",
    	       "#I    run 'pq' with '-k' flag, the result will be saved in ",
    	       "'PQ_OUTPUT'\n" );
        PrintTo( CR.SetupFile, string );
    	return true;
    fi;

    # otherwise append code to save the output in a temporary file
    outname := TmpName();
    Append( string, Concatenation( "8\n25\n", outname, "\n2\n0\n" ) );
    Append( string, "0\n" );

    # Find the pq executable
    pq := Filename( DirectoriesPackagePrograms( "anupq" ), "pq" );
    if pq = fail then
        Error( "Could not find the pq executable" );
    fi;

    # and finally start the pq
    input := InputTextString( string );
    if CR.Verbose  then 
        output := OutputTextFile( "*stdout*", false );
    else 
        output := OutputTextNone();
    fi;
    proc := Process( DirectoryCurrent(), pq, input, output, [ "-k",  ] );
    CloseStream( output );
    CloseStream( input );
    if proc <> 0 then
        Error( "process did not succeed" );
    fi;
    
    # read group and images from file
    result := ANUPQReadOutput( outname, ANUPQGlobalVariables );

    # remove intermediate files
    Exec( Concatenation( "rm -f ", outname ) );

    phi := GroupHomomorphismByImages( F, result.F, 
                   GeneratorsOfGroup( F ), result.MapImages );
    SetFeatureObj( phi, IsSurjective, true );

    return phi;

end;


#############################################################################
##
#F  Pq( <G>, ... )  . . . . . . . . . . . . . . . . . . . . .  prime quotient
##
Pq := function( arg )
    local   phi,  x,  CR,  F;

    # check arguments
    if Length(arg) < 1  then
    	Error( "usage: Pq( <F>, <control-args>, ... )" );
    fi;
    F := arg[1];
    if not IsFpGroup( F ) then
    	Error( "<F> must be a finitely presented group" );
    fi;
    if Length(arg) < 2 or not IsRecord(arg[2])  then
    	CR := ANUPQextractPqArgs( arg );
    else
    	CR := ShallowCopy(arg[2]);
    	x := Set( REC_NAMES(CR) );
    	SubtractSet( x, Set( ANUPQoptions ) );
    	if 0 < Length(x)  then
    	    ANUPQerrorPq(x);
    	fi;
    fi;

    phi := PqEpimorphism( F, CR );
    return Image( phi );
end;

#############################################################################
##
#F  PqRecoverDefinitions( <G> ) . . . . . . . . . . . . . . . . . definitions
##
##  This function finds a definition for each generator of the p-group <G>.
##  These definitions need not be the same as the ones used by pq.  But
##  they serve the purpose of defining each generator as a commutator or
##  power of earlier ones.  This is useful for extending an automorphism that
##  is given on a set of minimal generators of <G>.
##
PqRecoverDefinitions := function( G )
    local   col,  gens,  definitions,  h,  g,  rhs,  gen;

    col  := ElementsFamily( FamilyObj( G ) )!.rewritingSystem;
    gens := GeneratorsOfRws( col );

    definitions := [];

    for h in [1..NumberGeneratorsOfRws( col )] do
        rhs := GetPowerNC( col, h );
        if Length( rhs ) = 1 then
            gen := Position( gens, rhs );
            if not IsBound( definitions[gen] ) then
                definitions[gen] := h;
            fi;
        fi;
        
        for g in [1..h-1] do
            rhs := GetConjugateNC( col, h, g );
            if Length( rhs ) = 2 then
                gen := SubSyllables( rhs, 2, 2 );
                gen := Position( gens, gen );
                if not IsBound( definitions[gen] ) then
                    definitions[gen] := [h, g];
                fi;
            fi;
        od;
    od;
    return definitions;
end;


                
#############################################################################
##
#F  PqAutomorphism( <epi>, images ) . . . . . . . . . . . . . . . definitions
##
##  Take an automorphism of the preimage and produce the induced automorphism
##  of the image of the epimorphism.
##
PqAutomorphism := function( epi, autoimages )
    local   G,  p,  gens,  definitions,  d,  epimages,  i,  pos,  def,  
            phi;

    G      := Image( epi );
    p      := PrimeOfPGroup( G );
    gens   := GeneratorsOfGroup( G );
    
    autoimages := List( autoimages, im->Image( epi, im ) );

    ##  Get a definition for each generator.
    definitions := PqRecoverDefinitions( G );
    d := Number( [1..Length(definitions)], 
                 i->not IsBound( definitions[i] ) );

    ##  Find the images for the defining generators of G under the
    ##  automorphism.  We have to be careful, as some of the generators for
    ##  the source might be redundant as generators of G.
    epimages := List( GeneratorsOfGroup(Source(epi)), g->Image(epi,g) );
    for i in [1..d] do
        ##  Find G.i ...
        pos := Position( epimages, G.(i) );
        if pos = fail then 
            Error( "generators ", i, "not image of a generators" );
        fi;
        ##  ... and set its image.
        definitions[i] := autoimages[pos];
    od;
        
    ##  Replace each definition by its image under the automorphism.
    for i in [d+1..Length(definitions)] do
        def := definitions[i];
        if IsInt( def ) then
            definitions[i] := definitions[ def ]^p;
        else
            definitions[i] := Comm( definitions[ def[1] ],
                                    definitions[ def[2] ] );
        fi;
    od;
            
    phi := GroupHomomorphismByImages( G, G, gens, definitions );
    SetFeatureObj( phi, IsBijective, true );

    return phi;
end;
