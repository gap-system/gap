#############################################################################
##
#A  anusp.g                    GAP share library               Eamonn O'Brien
##                                                             Alice Niemeyer 
##
#Y  Copyright 1993-1995,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1993-1995,  School of Mathematical Sciences, ANU,     Australia
##
#A  @(#)$Id: anusp.g,v 1.3 2001/06/15 07:37:29 werner Exp $
##
#H  $Log: anusp.g,v $
#H  Revision 1.3  2001/06/15 07:37:29  werner
#H  Fixing revision number. WN
#H
#H  Revision 1.1.1.1  2001/04/15 15:09:32  werner
#H  Try again to import ANUPQ. WN
#H
#H  Revision 1.2  2000/07/12 17:00:06  werner
#H  Further work towards completing the GAP 4 interface to the ANU PQ.
#H                                                                      WN
#H
#H  Revision 1.1.1.1  1998/08/12 18:50:54  gap
#H  First attempt at adapting the ANU pq to GAP 4. 
#H
##
if IsBound(ANUPQtmpDir)  then
    ThisIsAHack := ANUPQtmpDir;
else
    ThisIsAHack := "ThisIsAHack";
fi;
ANUPQtmpDir := ThisIsAHack;

if IsBound(ANUPQgroups)  then
    ThisIsAHack := ANUPQgroups;
else
    ThisIsAHack := [];
fi;
ANUPQgroups := ThisIsAHack;

if IsBound(ANUPQautos)  then
    ThisIsAHack := ANUPQautos;
else
    ThisIsAHack := [];
fi;
ANUPQautos := ThisIsAHack;

if IsBound(ANUPQmagic)  then
    ThisIsAHack := ANUPQmagic;
else
    ThisIsAHack := "ThisIsAHack";
fi;
ANUPQmagic := ThisIsAHack;


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
    "    \"AgAutomorphisms\"\n",
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
            w{[1..LengthString(g)]} = g;
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
            if CR.ClassBound <= G.pClass  then
                Error( "\"ClassBound\" must be at least ", G.pClass+1 );
            fi;

        # "AgAutomorphisms"
        elif match( act, "AgAutomorphisms" )  then
            CR.AgAutomorphisms := true;

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

#############################################################################
##
#F  StandardPresentation( <F>, <G>, ... ) . . . . . . .  compute a SP for <F>
##
if IsBound(G)  then ThisIsAHack := G;  else ThisIsAHack := "G";  fi;
G := ThisIsAHack;

StandardPresentation := function( arg )
    local   CR,  F,  file,  out,  oldG,  newG,  x,  gens,  cmd,  r,
            Images,  SPrecord, desc,  rank,  i,  j,  k, p,  aut,  
            dir,  help1,  help2,  G;

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
    	if not IsBound(F.relators) or 0 = Length(F.relators)  then
    	    rank := Length(F.generators);
    	else
    	    rank := Number( List(
                        AbelianInvariants(CommutatorFactorGroup(F)),
    	    	        x -> Gcd(x,p) ),
    	    	      y -> y = p );
        fi;

        # construct free group with <rank> generators
        G := FreeGroup( rank, "g" );
    
        # construct power-relation
        G.relators := List( G.generators, x -> x^p );
    
        # construct ag group
        G := AgGroupFpGroup(G);
    
        # construct automorphism
        G.automorphisms := [];
        for x  in GeneralLinearGroup(rank,p).generators  do
            aut := [];
            for i  in [ 1 .. rank ]  do
                r := G.identity;
                for j  in [ 1 .. rank ]  do
                    r := r * G.generators[j]^Int(x[i][j]);
                od;
                aut[i] := r;
            od;
            Add( G.automorphisms, GroupHomomorphismByImages( G, G,
                    G.generators, aut ) );
        od;
        arg[2] := G;
    else
        G := arg[2];
        if not IsAgGroup(G)  then
            Error( "<G> must be an ag group" );
        elif not IsBound(G.automorphisms)  then
            Error( "<G>.automorphisms must be bound" );
        fi;
    fi;
    
    # get exponent-p class
    p := Order( G, G.generators[Length(G.generators)] );
    if not IsBound(G.pClass)  then
        G.pClass := Length( PCentralSeries( G, p ) ) - 1;
    fi;

    # extract arguments in case the third arg is not a argument record
    if Length(arg) < 3 or not IsRec(arg[3])  then
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
    if not IsBound(CR.AgAutomorphisms) then 
    	CR.AgAutomorphisms := false;
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

    # use a giving directory and try to construct a random subdir
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
        Exec( ConcatenationString( "mkdir ", dir ) );
        file := ConcatenationString( dir, "/PQ_INPUT" );
    fi;

    # setup input file
    PrintTo( file, "#Standard Presentation input file\n" );
    if IsBound(CR.OutputLevel)  then
    	AppendTo( file, "5\n", CR.OutputLevel, " \n" );
    fi;
    AppendTo( file, "1\n" );
    AppendTo( file, "prime ", CR.Prime, " \n" );
    AppendTo( file, "class ", G.pClass, " \n" );
    if CR.Exponent <> 0  then
        AppendTo( file, "exponent ", CR.Exponent, "\n" );
    fi;
    if IsBound(CR.Metabelian)  then
        AppendTo( file, "metabelian\n" );
    fi;

    # create generic generators "g1" ... "gn"
    gens := WordList( Length(F.generators), "g" );
    AppendTo( file, "generators {" );
    for x  in gens  do
    	AppendTo( file, x, ", " );
    od;
    AppendTo( file, " }\n" );

    # write the presentation using these generators
    AppendTo( file, "relations {" );
    if IsBound(F.relators)  then
    	for r  in F.relators  do
    	    AppendTo( file, MappedWord(r,F.generators,gens), ",\n" );
    	od;
    fi;
    AppendTo( file, "}\n;\n" );
    AppendTo( file, "2\nSPres\n" );

    if not IsBound (CR.ClassBound) then 
       CR.ClassBound := 63;
    fi;
    AppendTo( file, CR.ClassBound, "\n" );

    # print automorphisms of <G>
    rank := RankPGroup( G );
    AppendTo( file, Length(G.automorphisms), "\n" );
    for aut  in G.automorphisms  do
        for gens  in [ 1 .. rank ]  do
            for i in ExponentsAgWord(Image(aut, G.generators[gens]))  do
                AppendTo( file, i, " " );
            od;
            AppendTo( file, "\n" );
        od;
    od;
    if CR.AgAutomorphisms  then 
       AppendTo( file, 1, "\n");
    else 
       AppendTo( file, 0, "\n");
    fi;

    #new option EOB February 1995 
    AppendTo( file, "8\n" );
    AppendTo( file, "\n0\n" );

    # if we only want to setup the file we are ready now
    if IsBound(CR.SetupFile)  then
    	Print( "#I  input file '", CR.SetupFile, "' written,\n",
    	       "#I    run 'pq' with '-i -k' flag\n");
    	return true;
    fi;

    # and finally start the pq
    if CR.Verbose  then 
        #cmd := Concatenation( "pq -i -k -g < ", file );
        cmd := Concatenation( "-i -k -g < ", file );
    else 
        #cmd := Concatenation("pq -i -k -g < ",file," > /dev/null");
        cmd := Concatenation( "-i -k -g < ", file, " > /dev/null" );
    fi;
    ExecPkg( "anupq", "bin/pq", cmd, dir );
    #Exec( cmd );

    # save <ANUPQgroups> in case somebody has defined this variable
    if IsBound(ANUPQgroups)  then help1 := ANUPQgroups;  fi;
    Unbind( ANUPQgroups );
   
    # save <ANUPQautos> in case somebody has defined this variable
    if IsBound(ANUPQautos)  then help2 := ANUPQautos;  fi;
    Unbind( ANUPQautos );
   
    # try to read <file>
    Unbind(ANUPQmagic);
    file := Concatenation( dir, "/GAP_library" );
    if not READ(file) or not IsBound(ANUPQmagic)  then
        Unbind(ANUPQgroups);
        Unbind(ANUPQautos);
        if IsBound(help1)  then ANUPQgroups := help1;  fi;
        if IsBound(help2)  then ANUPQautos  := help2;  fi;
        Exec( Concatenation( "rm -rf ", dir ) );
        Error( "cannot execute ANU pq,  please check installation" );
    fi;

    # remove intermediate files and return
    Exec( Concatenation( "rm -rf ", dir ) );

    # last presentation in file is the Standard Presentation
    desc := [];
    ANUPQgroups[Length(ANUPQgroups)](desc);
    if IsBound(ANUPQautos) and IsBound(ANUPQautos[Length(ANUPQgroups)])  then
    	ANUPQautos[Length(ANUPQgroups)](desc[1]);
    fi;

    #return desc[1];

    #next 5 lines are new EOB February 1995 
    #revise .pqImages to correspond to images of user-supplied generators 
    SPrecord := desc[1];
    x := Length (SPrecord.pqImages);
    k := Length (F.generators);
    #images of user supplied generators are last k entries in .pqImages 
    Images := SPrecord.pqImages{[x - k + 1..x]};
    SPrecord.pqImages := Images;

    return SPrecord;

end;


#############################################################################
##
#F  IsIsomorphicPGroup( <G>, <H> )  . . . . . . . . . . . .  isomorphism test
##
IsIsomorphicPGroup := function( G, H )
    local   SG,  SH,  p,  class;
    
    # <G> and <H> must both be ag group and p-groups
    if not IsAgGroup(G)  then
        Error( "<G> must be an ag group" );
    fi;
    if not IsAgGroup(H)  then
        Error( "<H> must be an ag group" );
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
    SG := StandardPresentation( FpGroup(G), p, "ClassBound", class );
    SH := StandardPresentation( FpGroup(H), p, "ClassBound", class );
    
    # the groups are equal if the presentation are equal
    return SG.relators = List( SH.relators, x -> MappedWord( x,
                   SH.abstractGenerators, SG.abstractGenerators ) );
    
end;

#############################################################################
##
#F  IsomorphismPcpStandardPcp ( <H>, <S> )  . . . . . . . . . . . . . . . .
##
## return the isomorphism from the pcp H to the standard pcp S 
##  
IsomorphismPcpStandardPcp := function ( H, S )

	return GroupHomomorphismByImages( H, S, 
               H.generators{[ 1 .. S.rank]}, 
               S.pqImages{[ 1 .. S.rank ]} );

end;

#############################################################################
##
#F  AutomorphismsPGroup ( <H>)  . . . . . . return automorphisms of a p-group 
##
AutomorphismsPGroup := function (arg)

	local Out, Inn, phi, phiinv, S, Hfp, f, H, ol;
 
        H := arg[1];
        if not IsAgGroup(H) then
	    Error("<H> must be an AgGroup");
        fi;
        if Length(arg) > 2 then
	    Error("usage: AutomorphismsPGroup( <H> [, <output level>] )" );
        fi;

	Hfp := FpGroup(H);
        f := Set(Factors(Size(H)));
        if Length(f) > 1 then
            Error("<H> has to be a p-group");
        fi;

        if Length(arg) = 2 then
            ol := arg[2]; 
            if ol < 0 or ol > 2 then 
               Error("<level> needs to be positive and less than 2"); 
            fi; 
            S := StandardPresentation ( Hfp, f[1],  "OutputLevel", ol ); 
        else
	    S := StandardPresentation ( Hfp, f[1] );
        fi;

	phi :=  GroupHomomorphismByImages( H, S, 
               H.generators{[ 1 .. S.rank]}, 
               S.pqImages{[ 1 .. S.rank ]} );
 
	phiinv := phi^-1;

        Out := List( S.automorphisms, x -> phi*x*phiinv );

        #include the inner automorphisms of H 
        Inn := Set (List (Cgs (H), g -> GroupHomomorphismByImages 
                                   (H, H, Cgs (H), List (Cgs (H), x->x^g))));   
        RemoveSet (Inn, IdentityMapping (H));

        return Concatenation (Inn, Out); 
end;
