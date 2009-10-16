#############################################################################
##
#A  anusp.g                    GAP share library               Eamonn O'Brien
##                                                             Alice Niemeyer 
##
#Y  Copyright 1993-1995,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1993-1995,  School of Mathematical Sciences, ANU,     Australia
##
#A  @(#)$Id: anusp.g,v 1.1.1.1 2001/04/15 13:39:19 werner Exp $
##
#H  $Log: anusp.g,v $
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
#F  InfoANUPQSP1  . . . . . . . . . . . . . . . . . . . . . debug information
#F  InfoANUPQSP2  . . . . . . . . . . . . . . . . . . . . . debug information
##
if not IsBound(InfoANUPQSP1)  then InfoANUPQSP1 := Print;    fi;
if not IsBound(InfoANUPQSP2)  then InfoANUPQSP2 := Ignore;   fi;


#############################################################################
##
#F  ANUPQSPerror( <param> ) . . . . . . . . . . . . . report illegal parameter
##
ANUPQSPerror := function( param )
    Error(
    "Valid Options:\n",
    "    \"ClassBound\", <bound>\n",
    "    \"PcgsAutomorphisms\"\n",
    "    \"Exponent\", <exponent>\n",
    "    \"Metabelian\"\n",
    "    \"OutputLevel\", <level>\n",
    "    \"TmpDir\"\n",
    "    \"Verbose\"\n",
    "    \"SetupFile\", <file>\n",
    "Illegal Parameter: \"", param, "\"" );
end;


#############################################################################
##
#F  ANUPQSPextractArgs( <args> )  . . . . . . . . . . . . parse argument list
##
ANUPQSPextractArgs := function( args )
    local   CR,  i,  act,  G,  match;

    # allow to give only a prefix
    match := function( g, w )
    	return 1 < Length(g) and 
            Length(g) <= Length(w) and 
            w{[1..Length(g)]} = g;
    end;

    # extract arguments
    G  := args[2];
    CR := rec( group := G );
    i  := 3;
    while i <= Length(args)  do
        act := args[i];

        # "ClassBound", <class>
        if match( act, "ClassBound" )  then
            i := i + 1;
            CR.ClassBound := args[i];
            if CR.ClassBound <= PClassPGroup(G)  then
                Error( "\"ClassBound\" must be at least ", PClassPGroup(G)+1 );
            fi;

        # "PcgsAutomorphisms"
        elif match( act, "PcgsAutomorphisms" )  then
            CR.PcgsAutomorphisms := true;

        #this may be available later
        # "SpaceEfficient"
        #elif match( act, "SpaceEfficient" ) then
        #    CR.SpaceEfficient := true;

        # "Exponent", <exp>
        elif match( act, "Exponent" )  then
            i := i + 1;
            CR.Exponent := args[i];

        # "Metabelian"
        elif match( act, "Metabelian" ) then
            CR.Metabelian := true;

        # "Verbose"
        elif match( act, "Verbose" )  then
            CR.Verbose := true;

        # "SetupFile", <file>
        elif match( act, "SetupFile" )  then
            i := i + 1;
            CR.SetupFile := args[i];

    	# "TmpDir", <dir>
    	elif match( act, "TmpDir" )  then
    	    i := i + 1;
    	    CR.TmpDir := args[i];

        # "Output", <level>
        elif match( act, "OutputLevel" )  then
            i := i + 1;
            CR.OutputLevel := args[i];
            CR.Verbose     := true;

        # signal an error
        else
            ANUPQSPerror(act);
        fi;
        i := i + 1;
    od;
    return CR;

end;

ANUSPGlobalVariables := [ "ANUPQmagic",
                          "ANUPQautos",
                          "ANUPQgroups",
];

##  ANUPQtmpDir can be used to supply a name for a temporary directory.
if not IsBound( ANUPQtmpDir ) then ANUPQtmpDir := "ThisIsAHack"; fi;

FpGroupPcGroup := function( G )
    local   r;

    r := FpGroupPcGroupSQ( G );

    return r.group / r.relators;
end;

#############################################################################
##
#F  StandardPresentation( <F>, <G>, ... ) . . . . . . .  compute a SP for <F>
##
EpimorphismStandardPresentation := function( arg )
    local   F,  rank,  G,  automorphisms,  generators,  x,  images,  
            i,  r,  j,  aut,  p,  CR,  dir,  file,  string,  n,  
            newgens,  gens,  g,  pq,  input,  output,  proc,  result,  
            desc,  sp,  k;

    if Length(arg) = 1 and IsList(arg[1]) then
        arg := arg[1];
    fi;

    # check arguments
    if Length(arg) < 1  then
    	Error( "usage: StandardPresentation( <F>, <G>, <ctrl>, ... )" );
    fi;
    F := arg[1];
    if not IsFpGroup(F)  then
    	Error( "<F> must be a finitely presented group" );
    fi;

    # <G> must be an ag group or a prime
    if IsInt(arg[2])  then
    	p := arg[2];
        if not IsPrimeInt(p)  then
            Error( "<p> must be a prime" );
        fi;
        rank := Number( List( AbelianInvariants(F), x->Gcd(x,p) ), y->y=p );

        # construct free group with <rank> generators
        G := FreeGroup( rank, "g" );
    
        # construct power-relation
        G := G / List( GeneratorsOfGroup(G), x -> x^p );
    
        # construct ag group
        G := PcGroupFpGroup(G);
    
        # construct automorphism
        automorphisms := [];
        generators := GeneratorsOfGroup(G);
        for x in GeneratorsOfGroup( GL(rank,p) ) do
            images := [];
            for i  in [ 1 .. rank ]  do
                r := One(G);
                for j  in [ 1 .. rank ]  do
                    r := r * generators[j]^Int(x[i][j]);
                od;
                images[i] := r;
            od;
            aut := GroupHomomorphismByImages( G, G, generators, images );
            SetIsBijective( aut, true );
            Add( automorphisms, aut );
        od;
        SetAutomorphismGroup( G, GroupByGenerators( automorphisms ) );
        arg[2] := G;
    else
        G := arg[2];
        if not IsPcGroup(G)  then
            Error( "<G> must be a pc-group" );
        elif not HasAutomorphismGroup(G)  then
            Error( "The automorphism group of <G> must be known" );
        fi;
    fi;
    
    # get exponent-p class
    p := PrimeOfPGroup( G );

    # extract arguments in case the third arg is not an argument record
    if Length(arg) < 3 or not IsRecord(arg[3])  then
        CR := ANUPQSPextractArgs(arg);
    else
        CR := ShallowCopy(arg[3]);
        CR.group := G;
    fi;

    # set default values
    if not IsBound(CR.Exponent)  then 
    	CR.Exponent := 0;
    fi;
    if not IsBound(CR.Verbose) then 
    	CR.Verbose := false;
    fi;
    if not IsBound(CR.PcgsAutomorphisms) then 
    	CR.PcgsAutomorphisms := false;
    fi;
    CR.Prime := p;

    # create tmp directory
    if IsBound(CR.SetupFile)  then 
    	file := CR.SetupFile;

    # otherwise construct a temporary directory
    elif not IsBound(CR.TmpDir) and ANUPQtmpDir = "ThisIsAHack"  then
        dir := TmpName();

        # create the directory
        Exec( Concatenation( "mkdir ", dir ) );
        file := Concatenation( dir, "/PQ_INPUT" );

    # use a given directory and try to construct a random subdir
    else
        if IsBound(CR.TmpDir)  then
            dir := CR.TmpDir;
            Unbind(CR.TmpDir);
        else
            dir := ANUPQtmpDir;
        fi;

        # try to get a random number
        i := Runtime();
        i := i + RandomList( [ 1 .. 2^16 ] ) * RandomList( [ 1 .. 2^16 ] );
        i := i * Runtime();
        i := i mod 19^8;
        dir := Concatenation( dir, "/", LetterInt(i), ".apq" );

        # create the directory
        Exec( Concatenation( "mkdir ", dir ) );
        file := Concatenation( dir, "/PQ_INPUT" );
    fi;

    # setup input file
    string := "#Standard Presentation input\n";
    if IsBound(CR.OutputLevel)  then
    	Append( string, "5\n", CR.OutputLevel, " \n" );
    fi;
    Append( string, "1\n" );
    Append( string, Concatenation( "prime ", String(CR.Prime), "\n" ) );
    Append( string, Concatenation( "class ", String(PClassPGroup(G)), "\n" ) );
    if CR.Exponent <> 0  then
        Append( string,
                Concatenation( "exponent ", String(CR.Exponent), "\n" ) );
    fi;
    if IsBound(CR.Metabelian)  then
        Append( string, "metabelian\n" );
    fi;

    # create generic generators "g1" ... "gn"
    n := Length( GeneratorsOfGroup( F ) );
    newgens := GeneratorsOfGroup( FreeGroup( n, "g" ) );
    Append( string, "generators {" );
    for x in newgens  do  
        Append( string, String(x) ); 
        Append( string, ", " );
    od;
    Append( string, " }\n" );

    # write the presentation using these generators
    Append( string, "relations {" );
    gens := GeneratorsOfGroup( FreeGroupOfFpGroup(F) );
    for r  in RelatorsOfFpGroup( F ) do
        Append( string, String(MappedWord( r, gens, newgens ) ) );
        Append( string, ",\n" );
    od;
    Append( string, "}\n;\n" );
    Append( string, "2\nSPres\n" );

    if not IsBound (CR.ClassBound) then 
       CR.ClassBound := 63;
    fi;
    Append( string, String(CR.ClassBound) );
    Append( string, "\n" );

    # print automorphisms of <G>
    rank := RankPGroup( G );
    gens := PcgsPCentralSeriesPGroup( G );
    automorphisms := GeneratorsOfGroup( AutomorphismGroup( G ) );
    Append( string, String(Length(automorphisms)) );
    Append( string, "\n" );
    for aut in automorphisms  do
        for g in gens do
            for i in ExponentsOfPcElement( gens, Image( aut, g ) ) do
                Append( string, String(i) );
                Append( string, " " );
            od;
            Append( string, "\n" );
        od;
    od;
    if CR.PcgsAutomorphisms  then 
       Append( string, "1\n");
    else 
       Append( string, "0\n");
    fi;

    #new option EOB February 1995 
    Append( string, "8\n" );
    Append( string, "\n0\n" );

    # if we only want to setup the file we are ready now
    if IsBound(CR.SetupFile)  then
        PrintTo( CR.SetupFile, string );
    	Print( "#I  input file '", CR.SetupFile, "' written,\n",
    	       "#I    run 'pq' with '-i -k' flags\n");
    	return true;
    fi;
#    Print( string );    Print( dir, "\n" );

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
    proc := Process( Directory(dir), pq, input, output, 
                    [ "-i", "-k", "-g"  ] );
    CloseStream( output );
    CloseStream( input );
    if proc <> 0 then
        Error( "process did not succeed" );
    fi;
    
    # try to read <file>
    file := Concatenation( dir, "/GAP_library" );
    
    result := ANUPQReadOutput( file, ANUSPGlobalVariables );

    if not IsBound(result.ANUPQmagic)  then
        Exec( Concatenation( "rm -rf ", dir ) );
        Error( "cannot execute ANU pq,  please check installation" );
    fi;

    # remove intermediate files and return
    Exec( Concatenation( "rm -rf ", dir ) );

    # last presentation in file is the Standard Presentation
    
    desc := rec();
    result.ANUPQgroups[Length(result.ANUPQgroups)](desc);
#    if result.ANUPQautos <> fail and 
#       Length( result.ANUPQautos ) = Length( result.ANUPQgroups ) then
#    	result.ANUPQautos[ Length(result.ANUPQgroups) ]( desc.group );
#    fi;

    # revise images to correspond to images of user-supplied generators 
    sp := desc.group;
    x  := Length( desc.map );
    k  := Length( GeneratorsOfGroup( F ) );
    # images of user supplied generators are last k entries in .pqImages 

    return GroupHomomorphismByImagesNC( F, sp, 
                   GeneratorsOfGroup(F),
                   desc.map{[x - k + 1..x]} );

end;

StandardPresentation := function( arg )

    return Range( EpimorphismStandardPresentation( arg ) );
end;

#############################################################################
##
#F  IsIsomorphicPGroup( <G>, <H> )  . . . . . . . . . . . .  isomorphism test
##
IsIsomorphicPGroup := function( G, H )
    local   p,  class,  SG,  SH,  Ggens,  Hgens;
    
    # <G> and <H> must both be pc groups and p-groups
    if not IsPcGroup(G)  then
        Error( "<G> must be a pc group" );
    fi;
    if not IsPcGroup(H)  then
        Error( "<H> must be a pc group" );
    fi;
    if Size(G) <> Size(H)  then
        return false;
    fi;
    p := SmallestRootInt(Size(G));
    if not IsPrimeInt(p)  then
        Error( "<G> must be a p-group" );
    fi;
    
    # check the Frattini factor
    if RankPGroup(G) <> RankPGroup(H)  then
        return false;
    fi;

    # check the exponent-p-length
    class := Length(PCentralSeries(G,p))-1;
    if class <> Length(PCentralSeries(H,p))-1  then
        return false;
    fi;
    
    # if the groups are elementary abelian they are isomorphic
    if class = 1  then
        return true;
    fi;
    
    # compute a standard presentation for both
    SG := StandardPresentation( FpGroupPcGroup(G), p, "ClassBound", class );
    SH := StandardPresentation( FpGroupPcGroup(H), p, "ClassBound", class );
    
    # the groups are equal if the presentation are equal
    Ggens := GeneratorsOfGroup( FreeGroupOfFpGroup( SG ) );
    Hgens := GeneratorsOfGroup( FreeGroupOfFpGroup( SH ) );
    return RelatorsOfFpGroup(SG)
           = List( RelatorsOfFpGroup(SH), 
                   x -> MappedWord( x, Hgens, Ggens ) );
    
end;
