#############################################################################
##
#A  anupga.g                    GAP share library                Frank Celler
#A                                                           & Eamonn O'Brien
#A                                                           & Benedikt Rothe
##
#A  @(#)$Id: anupga.g,v 1.1.1.1 2001/04/15 13:39:19 werner Exp $
##
#Y  Copyright 1992-1994,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1992-1994,  School of Mathematical Sciences, ANU,     Australia
##
#H  $Log: anupga.g,v $
#H  Revision 1.1.1.1  2001/04/15 13:39:19  werner
#H  Importing the GAP 4 version of ANUPQ.                                    WN
#H
#H  Revision 1.3  2000/07/13 16:16:43  werner
#H  p-group generation now works for soluble automorphism groups and with
#H  the help of GAP3 for insoluble automorphism groups.
#H  We are getting there.                                                   WN
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

#############################################################################
##
#F  InfoANUPQ1  . . . . . . . . . . . . . . . . . . . . . . debug information
#F  InfoANUPQ2  . . . . . . . . . . . . . . . . . . . . . . debug information
##
if not IsBound(InfoANUPQ1)  then InfoANUPQ1 := Print;    fi;
if not IsBound(InfoANUPQ2)  then InfoANUPQ2 := Ignore;   fi;



#############################################################################
##
#F  ANUPQerror( <param> ) . . . . . . . . . . . . . .report illegal parameter
##
ANUPQerror := function( param )
    Error(
    "Valid Options:\n",
    "    \"ClassBound\", <bound>\n",
    "    \"OrderBound\", <order>\n",
    "    \"StepSize\", <size>\n",
    "    \"PcgsAutomorphisms\"\n",
    "    \"RankInitialSegmentSubgroups\", <rank>\n",
    "    \"SpaceEfficient\"\n",
    "    \"AllDescendants\"\n",
    "    \"Exponent\", <exponent>\n",
    "    \"Metabelian\"\n",
    "    \"SubList\"\n",
    "    \"TmpDir\"\n",
    "    \"Verbose\"\n",
    "    \"SetupFile\", <file>\n",
    "Illegal Parameter: \"", param, "\"" );
end;


#############################################################################
##
#F  ANUPQextractArgs( <args>) . . . . . . . . . . . . . . parse argument list
##
ANUPQextractArgs := function( args )
    local   CR,  i,  act,  G,  match;

    # allow to give only a prefix
    match := function( g, w )
    	return 1 < Length(g) and 
            Length(g) <= Length(w) and 
            w{[1..Length(g)]} = g;
     end;

    # extract arguments
    G  := args[1];
    CR := rec( group := G );
    i  := 2;
    while i <= Length(args)  do
        act := args[i];

        # "ClassBound", <class>
        if match( act, "ClassBound" )  then
            i := i + 1;
            CR.ClassBound := args[i];
            if CR.ClassBound <= PClassPGroup(G) then
                Error( "\"ClassBound\" must be at least ", PClassPGroup(G)+1 );
            fi;

        # "OrderBound", <order>
        elif match( act, "OrderBound" )  then
            i := i + 1;
            CR.OrderBound := args[i];

        # "StepSize", <size>
        elif match( act, "StepSize" )  then
            i := i + 1;
            CR.StepSize := args[i];

        # "PcgsAutomorphisms"
        elif match( act, "PcgsAutomorphisms" )  then
            CR.PcgsAutomorphisms := true;

        # "RankInitialSegmentSubgroups", <rank>
        elif match( act, "RankInitialSegmentSubgroups" )  then
            i := i + 1;
            CR.RankInitialSegmentSubgroups := args[i];

        # "SpaceEfficient"
        elif match( act, "SpaceEfficient" ) then
            CR.SpaceEfficient := true;

        # "AllDescendants"
        elif match( act, "AllDescendants" )  then
            CR.AllDescendants := true;

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

        # "SubList"
        elif match( act, "SubList" )  then
            i := i + 1;
            CR.SubList := args[i];

        # temporary directory
        elif match( act, "TmpDir" )  then
            i := i + 1;
            CR.TmpDir := args[i];

        # "SetupFile", <file>
        elif match( act, "SetupFile" )  then
            i := i + 1;
            CR.SetupFile := args[i];

        # signal an error
        else
            ANUPQerror( act );
        fi;
        i := i + 1;
    od;
    return CR;

end;


#############################################################################
##
#F  ANUPQinstructions( <pqi>, <param>, <p> )  . . . . . .  construct PQ input
##
ANUPQinstructions := function( pqi, param, p )
    local   G, firstStep,  ANUPQbool,  CR,  f,  i,  RF1,  RF2;

    G := param.group;
    firstStep := 0;

    # function to print boolean value
    ANUPQbool := function(b)
        if b  then
            return 1;
        else
            return 0;
        fi;
    end;

    # <CR> will hold the parameters
    CR := rec ();
    CR.ClassBound                  := PClassPGroup(G) + 1;
    CR.StepSize                    := -1;
    CR.OrderBound                  := -1;
    CR.PcgsAutomorphisms           := false;
    CR.Verbose                     := false;
    CR.RankInitialSegmentSubgroups := 0;
    CR.SpaceEfficient              := false;
    CR.AllDescendants              := false;
    CR.ExpSet                      := false;
    CR.Exponent                    := 0;
    CR.Metabelian                  := false;
    CR.group                       := G;
    CR.SubList                     := -1; 

    # merge arguments with default parameters
    RF1 := REC_NAMES(CR);
    RF2 := REC_NAMES(param);
    for f  in RF2  do
        if not f in RF1  then
            ANUPQerror(f);
        else
            CR.(f) := param.(f);
        fi;
    od;

    # sanity check
    if CR.OrderBound <> -1 and CR.OrderBound <= LogInt(Size(G), p)  then
        return [false];
    fi;
    if CR.SpaceEfficient and not CR.PcgsAutomorphisms  then
        f := "\"SpaceEfficient\" is only allowed in conjunction with ";
        f := Concatenation( f, "\"PcgsAutomorphisms\"" );
        return f;
    fi;
    if CR.StepSize <> -1 and CR.OrderBound <> -1  then
        f := "\"StepSize\" and \"OrderBound\" must not be set ";
        f := Concatenation( f, "simultaneously" );
        return f;
    fi;

    # generate instructions
    AppendTo( pqi, "5\n", CR.ClassBound, "\n" );
    if CR.StepSize <> -1  then
        AppendTo( pqi, "0\n" );
        if CR.ClassBound = PClassPGroup(G) + 1  then
            if IsList(CR.StepSize)  then
                if Length(CR.StepSize) <> 1  then
                    return "Only one \"StepSize\" must be given";
                else
                    CR.StepSize := CR.StepSize[1];
                fi;
            fi;
            AppendTo( pqi, CR.StepSize, "\n" );
            firstStep := CR.StepSize;
        else
            if IsList(CR.StepSize)  then
                if Length (CR.StepSize) <> CR.ClassBound - PClassPGroup(G)  then
                    f := "The difference between maximal class and class ";
                    f := Concatenation(f, 
                      "of the starting group is ", 
                      String(CR.ClassBound-PClassPGroup(G)),
                      ".\nTherefore you must supply ",
                      String(CR.ClassBound-PClassPGroup(G)),
                      " step-sizes in the \"StepSize\" list \n" );
                    return f;
                fi;
                AppendTo( pqi, "0\n" );
                for i  in CR.StepSize  do
                    AppendTo( pqi, i, " " );
                od;
                AppendTo( pqi, "\n" );
                firstStep := CR.StepSize[1];
            else
                AppendTo( pqi, "1\n", CR.StepSize, "\n" );
            fi;
        fi;
    elif CR.OrderBound <> -1  then
        AppendTo( pqi, "1\n1\n", CR.OrderBound, "\n" );
    else
        AppendTo( pqi, "1\n0\n" );
    fi;    
    AppendTo( pqi, ANUPQbool(CR.PcgsAutomorphisms), "\n0\n",
                   CR.RankInitialSegmentSubgroups, "\n" );
    if CR.PcgsAutomorphisms  then
        AppendTo( pqi, ANUPQbool(CR.SpaceEfficient), "\n" );
    fi;
    if HasNuclearRank(G) and firstStep <> 0  and
        firstStep > NuclearRank(G) then
            f := Concatenation( "\"StepSize\" (=", String(firstStep),
                   ") must be smaller or equal the \"Nuclear Rank\" (=",
                   String(NuclearRank(G)), ")" );
            return f;
    fi;
    AppendTo( pqi, ANUPQbool(CR.AllDescendants), "\n" );
    AppendTo( pqi, CR.Exponent, "\n" );
    AppendTo( pqi, ANUPQbool(CR.Metabelian), "\n", "1\n" );

    # return success
    return [true, CR];

end;


#############################################################################
##
#F  ANUPQauto( <G>, <gens>, <imgs> )  . . . . . . . .  construct automorphism
##
ANUPQauto := function( G, gens, images )
   local   f;

   f := GroupHomomorphismByImagesNC( G, G, gens, images );
   SetIsBijective( f, true );
   SetKernelOfMultiplicativeGeneralMapping( f, TrivialSubgroup(G) );

   return f;
end;


#############################################################################
##
#F  ANUPQautoList( <G>, <gens>, <L> ) . . . . . . . construct a list of autos
##
ANUPQautoList := function( G, gens, automs )
    local   D,  g,  igs,  auts,  i;

    # construct direct product elements
    D := [];
    for g  in [ 1 .. Length(gens) ]  do
	Add( D, Tuple( automs{[1..Length(automs)]}[g] ) );
    od;

    # and compute the abstract igs simultaneously
    igs := InducedPcgsByGeneratorsWithImages( Pcgs(G), gens, D );
    gens := igs[1];
    D := igs[2];


    # construct the automorphisms
    auts := [];
    for i in [ 1 .. Length(automs) ]  do
	Add( auts, ANUPQauto( G, gens, D{[1..Length(gens)]}[i] ) );
    od;

    # and then the automorphisms
    return auts;

end;


ANUPQSetAutomorphismGroup := function( G, gens, automs, isSoluble )
    local   A;

    automs := ANUPQautoList( G, gens, automs );
    
    if automs <> [] then
        A := GroupByGenerators( automs );
    else
        A := GroupByGenerators( [ ANUPQauto( G, GeneratorsOfGroup(G),
                     GeneratorsOfGroup(G) ) ] );
    fi;

    SetIsAutomorphismGroup( A, true );
    SetIsFinite( A, true );

    if isSoluble then SetPcgs( A, automs ); fi;

    SetAutomorphismGroup( G, A );

end;

#############################################################################
##
#F  ANUPQprintExps( <pqi>, <lst> ) . . . . . . . . . . .  print exponent list
##
ANUPQprintExps := function( pqi, lst )
    local   first,  l,  j;

    l := Length(lst);
    first := true;
    for j  in [1 .. l]  do
        if lst[j] <> 0  then
          if not first  then
              AppendTo( pqi, "*" );
          fi;
          first := false;
          AppendTo( pqi, "g", j, "^", lst[j] );
        fi;
    od;
end;

ANUPGAGlobalVariables := [ "ANUPQgroups", 
                           "ANUPQautos", 
                           "ANUPQmagic" 
                           ];

#############################################################################
##
#F  PqList( <file> ) . . . . . . . . . . . . . . .  get a list of descendants
##
PqList := function( arg )
    local   var,  lst,  groups,  autos,  sublist,  func;

    # check arguments
    if 2 < Length(arg) or Length(arg) < 1  then
        Error( "usage: PqList( <file> )" );
    fi;

    for var in ANUPGAGlobalVariables do
        HideGlobalVariables( var );
    od;

    # try to read <file>
    if not READ(arg[1]) or not IsBoundGlobal( "ANUPQmagic" )  then

        for var in ANUPGAGlobalVariables do
            UnhideGlobalVariables( var );
        od;
        return false;
    fi;

    # <lst> will hold the groups
    lst := [];
    if IsBoundGlobal( "ANUPQgroups" ) then
        groups := ValueGlobal( "ANUPQgroups" );
        if IsBoundGlobal( "ANUPQautos" ) then
            autos := ValueGlobal( "ANUPQautos" );
        fi;

        if Length(arg) = 2  then
            if IsList(arg[2])  then
                sublist := arg[2];
            else
                sublist := [arg[2]];
            fi;
        else
            sublist := [ 1 .. Length( groups ) ];
        fi;
        for func  in sublist  do
            groups[func](lst);
            if IsBound( autos) and IsBound( autos[func] )  then
                autos[func]( lst[Length(lst)] );
            fi;
        od;
    fi;
    
    for var in ANUPGAGlobalVariables do
        UnhideGlobalVariables( var );
    od;

    # return the groups
    return lst;

end;

LetterInt := function ( n )
    local  letters, str, x, d;
    letters := [ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", 
        "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" ]
     ;
    if n < 1  then
        Error( "number must be positive" );
    elif n <= Length( letters )  then
        return letters[n];
    fi;
    str := "";
    n := n - 1;
    d := 1;
    repeat
        x := n mod Length( letters ) + d;
        str := Concatenation( letters[x], str );
        n := QuoInt( n, Length( letters ) );
        if n < 26  then
            d := 0;
        fi;
    until n < 1;
    return str;
end;

#############################################################################
##
#F  PqDescendants( <G>, ... ) . . . . . . . . .  construct descendants of <G>
##
PqDescendants := function( arg )
    local   G,  CR,  p,  rank,  pqi,  dir,  i,  pcgs,  lst,  j,  
            auto_pcgs,  gens,  aut,  g,  res,  pq,  input,  output,  
            desc;

    # check arguments, return if <G> is not capable
    if 0 = Length (arg)  then
        Error( "usage: PqDescendants( <G>, ... )" );
    fi;
    G := arg[1];
    if not IsPcGroup(G)  then
        Error( "<G> must be a pc-group" );
    fi;

    # extract arguments in case the second arg is not a argument record
    if Length(arg) < 2 or not IsRecord(arg[2])  then
        CR := ANUPQextractArgs( arg );
    else
        CR := ShallowCopy(arg[2]);
        CR.group := G;
    fi;

    p    := PrimePGroup( G );
    rank := RankPGroup( G );

    # if automorphisms are not supplied and group has p-class 1, 
    # construct automorphisms, else signal Error 
    if not HasAutomorphismGroup(G) then 
        if (PClassPGroup(G) = 1) then 
            AutomorphismGroup( G );
        else 
            Error ("<G> must have class 1 or ",
                   "<G>'s automorphism group must be known\n");
        fi;
    fi;

    # if <G> is not capable and we want to compute something, return
    if HasIsCapable(G) and not IsCapable(G) and not IsBound(CR.SetupFile) then
        return [];
    fi;

    # we only want to set up an input file for ANU pq
    if IsBound(CR.SetupFile)  then
        pqi := CR.SetupFile;
        Unbind(CR.SetupFile);

    # otherwise construct a temporary directory
    elif not IsBound(CR.TmpDir) and ANUPQtmpDir = "ThisIsAHack"  then
        dir := TmpName();

        # create the directory
        Exec( Concatenation( "mkdir ", dir ) );
        pqi := Concatenation( dir, "/PQ_INPUT" );

    # use a given directory and try to construct a random subdir
    else
        if IsBound(CR.TmpDir)  then
            dir := CR.TmpDir;
            Unbind(CR.TmpDir);
        else
            dir := ANUPQtmpDir;
        fi;

        # try to get a random directory name
        i := Runtime();
        i := i + RandomList( [ 1 .. 2^16 ] ) * RandomList( [ 1 .. 2^16 ] );
        i := i * Runtime();
        i := i mod 19^8;
        dir := Concatenation( dir, "/", LetterInt(i), ".apq" );

        # create the directory
        Exec( Concatenation( "mkdir ", dir ) );
        pqi := Concatenation( dir, "/PQ_INPUT" );
    fi;

    # write first instruction to start ANU pq p-group generation
    PrintTo(  pqi, "1\n"                     );
    AppendTo( pqi, "prime ", p, " \n"        );
    AppendTo( pqi, "class ", PClassPGroup(G), "\n" );

    pcgs := PcgsPCentralSeriesPGroup(G);

    # print generators of <G>
    AppendTo( pqi, "generators {" );
    for i  in [ 1 .. Length(pcgs) ]  do
        AppendTo( pqi, "g", i );
        if i <> Length(pcgs)  then
            AppendTo( pqi, ", " );
        fi;
    od;
    AppendTo( pqi, " }\n" );

    # print relators of <G>
    AppendTo( pqi, "relations {" );
    for i  in [ 1 .. Length(pcgs) ]  do
        if i <> 1  then
            AppendTo( pqi, ", " );
        fi;
        lst := ExponentsOfPcElement( pcgs, pcgs[i]^p );
        AppendTo( pqi, "g", i, "^", p );
        if ForAny( lst, x -> x<>0 )  then
            AppendTo( pqi, "=" );
            ANUPQprintExps( pqi, lst );
        fi;
    od;
    for j  in [ 1 .. Length(pcgs) ]  do
        for i  in [ 1 .. j-1 ]  do
            lst := ExponentsOfPcElement( pcgs, Comm( pcgs[j], pcgs[i] ) );
            AppendTo( pqi, ", [g", j, ", g", i, "]" );
            if ForAny( lst, x -> x<>0 )  then
                AppendTo( pqi, "=" );
                ANUPQprintExps( pqi, lst );
            fi;
        od;
    od;
    AppendTo( pqi, "} \n" );

   
    # enter p-group generation
    AppendTo( pqi, "; \n7\n9\n1\n" );

    # print automorphisms of <G>, 
    # check if the automorphism group has a pcgs
    if IsBound(CR.PcgsAutomorphisms) and CR.PcgsAutomorphisms then
        auto_pcgs := Pcgs( AutomorphismGroup(G) );
        if auto_pcgs = fail then
            Error( "\"PcgsAutomorphisms\" used with insoluble", 
                   " automorphism group" );
        fi;
        gens := Reversed( auto_pcgs );
    else
        gens := GeneratorsOfGroup( AutomorphismGroup(G) );
    fi;
    AppendTo( pqi, Length( gens ), "\n" );
    for aut in gens do
        for g  in [ 1 .. rank ]  do
            for i in ExponentsOfPcElement( pcgs, Image(aut, pcgs[g]) )  do
                AppendTo( pqi, i, " " );
            od;
            AppendTo( pqi, "\n" );
        od;
    od;

    # now construct the instruction from the args
    res := ANUPQinstructions( pqi, CR, p );
    if IsString(res)  then
        if IsBound(dir)  then
            Exec( Concatenation( "rm -rf ", dir ) );
        fi;
        Error(res);
    elif not res[1]  then
        if IsBound(dir)  then
            Exec( Concatenation( "rm -rf ", dir ) );
            return [];
        fi;
        return;
    fi;

    # the next two lines were added by EOB 
    CR := res[2];
    res := CR.Verbose;

    AppendTo( pqi, "0\n0\n" );

    # return if we only want to set up a input file
    if not IsBound(dir)  then
    	Print( "#I  input file '", pqi, "' written, ",
    	       "run 'pq' with '-k' flag\n" );
        return true;
    fi;

    # Find the pq executable
    pq := Filename( DirectoriesPackagePrograms( "anupq" ), "pq" );
    if pq = fail then
        Error( "Could not find the pq executable" );
    fi;

#    Print( "pqi: ", pqi, "\n" );

    # and finally start the pq
    input := InputTextFile( pqi );
    if res then 
        output := OutputTextFile( "*stdout*", false );
    else 
        output := OutputTextFile( "PQ_LOG", false );
    fi;

    # Call pq, ignore exit status.
    Process( Directory( dir ), pq, input, output, [ "-k", "-g"  ] );
    CloseStream( output );
    CloseStream( input );
    
    # read in the library file written by pq
    if CR.SubList <> -1 then 
       desc := PqList( Concatenation(dir,"/GAP_library"), CR.SubList );
    else 
       desc := PqList( Concatenation(dir,"/GAP_library") );
    fi;
    if desc = false  then
        Exec( Concatenation( "rm -rf ", dir ) );
        Error( "cannot execute ANU pq,  please check installation" );
    fi;

    # add 'isCapable'
    for G  in desc  do
        if not HasIsCapable(G)  then
           SetIsCapable( G, false );
        fi;
    od;

    # remove temporary directory and return
    Exec( Concatenation( "rm -rf ", dir ) );
    return desc;

end;


#############################################################################
##
#F  SavePqList( <file>, <lst> ) . . . . . . . . .  save a list of descendants
##
SavePqList := function( file, list )
    local   appendExp,  l,  G,  pcgs,  p,  i,  w,  str,  word,  j,  
            automorphisms,  r;

    # function to add exponent vector
    appendExp := function( str, word )
        local   first, s, oldLen, i, w;

        first  := true;
        s      := str;
        oldLen := 0;
        for i  in [ 1 .. Length (word) ]  do
            if word[i] <> 0 then
                w := Concatenation( "G.", String (i) );
                if word[i] <> 1  then
                    w := Concatenation( w, "^", String(word[i]) );
                fi;
                if not first  then
                    w := Concatenation( "*", w );
                fi;
                if Length(s)+Length(w)-oldLen >= 77  then
                    s := Concatenation( s, "\n" );
                    oldLen := Length(s);
                fi;
                s := Concatenation( s, w );
                first := false;
            fi;
        od;
        if first  then
            s := Concatenation( s, "G.1^0" );
        fi;
        return s;
    end;

    # print head of file
    PrintTo(  file, "ANUPQgroups := [];\n"    );
    AppendTo( file, "Unbind(ANUPQautos);\n\n" );

    # run through all groups in <list>
    for l  in [ 1 .. Length(list) ]  do
        G    := list[l];
        pcgs := PcgsPCentralSeriesPGroup( G );
        p    := PrimeOfPGroup( G );
        AppendTo( file, "## group number: ", l, "\n"                     );
        AppendTo( file, "ANUPQgroups[", l, "] := function( L )\n"        );
        AppendTo( file, "local   G,  A,  B;\n"                           );
        AppendTo( file, "G := FreeGroup( ", Length(pcgs), ", \"G\" );\n" );
        AppendTo( file, "G := G / [\n"                                   );

        # at first the power relators
        for i in [ 1 .. Length(pcgs) ]  do
            if 1 < i  then
                AppendTo( file, ",\n" );
            fi;
            w   := pcgs[i]^p;
            str := Concatenation( "G.", String(i), "^", String(p) );
            if w <> One(G) then
                word := ExponentsOfPcElement( pcgs, w );
                str  := Concatenation( str, "/(" );
                str  := appendExp( str,word );
                str  := Concatenation( str, ")" );
            fi;
            AppendTo( file, str );
        od;

        # and now the commutator relators
        for i  in [ 1 .. Length(pcgs)-1 ]  do
            for j  in [ i+1 .. Length(pcgs) ]  do
                w := Comm( pcgs[j], pcgs[i] );
                if w <> One(G) then
                    word := ExponentsOfPcElement( pcgs, w );
                    str  := Concatenation(
                                ",\nComm( G.", String(j),
                                ", G.", String(i), " )/(" );
                    str := appendExp( str, word );
                    AppendTo( file, str, ")" );
                fi;
            od;
        od;
        AppendTo( file, "];\n" );

        # convert group into an ag group, save presentation
        AppendTo( file, "G := PcGroupFpGroupNC(G);\n"              );

        # add automorphisms
        if HasAutomorphismGroup(G) then
            AppendTo( file, "A := [];\nB := [" );
    	    for r  in [ 1 .. RankPGroup(G) ]  do
                AppendTo( file, "G.", r );
                if r <> RankPGroup(G)  then
                    AppendTo( file, ", " );
    	    	else
    	    	    AppendTo( file, "];\n" );
                fi;
            od;
            automorphisms := GeneratorsOfGroup( AutomorphismGroup( G ) );
            for j  in [ 1 .. Length(automorphisms) ]  do
                AppendTo( file, "A[", j, "] := [");
                for r  in [ 1 .. RankPGroup(G) ]  do
                    word := Image( automorphisms[j], pcgs[r] );
                    word := ExponentsOfPcElement( pcgs, word );
                    AppendTo( file, appendExp( "", word ) );
                    if r <> RankPGroup(G)  then
                        AppendTo (file, ", \n");
                    fi;
                od;
                AppendTo( file, "]; \n");
            od;
    	    AppendTo( file, "ANUPQSetAutomorphismGroup( G, B, A, " );
            if HasIsSolvableGroup( AutomorphismGroup(G) ) then
                AppendTo( file, IsSolvable( G ), " );\n" );
            else
                AppendTo( file, false, " );\n" );
            fi;
        fi;

        if HasNuclearRank( G ) then
            AppendTo( file, "SetNuclearRank( G, ", NuclearRank(G), " );\n" );
        fi;
        if HasIsCapable( G ) then
            AppendTo( file, "SetIsCapable( G, ", IsCapable(G), " );\n" );
        fi;
        if HasANUPQIdentity( G ) then
            AppendTo( file, "SetANUPQIdentity( G, ", 
                    ANUPQIdentity(G), " );\n" );
        fi;

        AppendTo( file, "Add( L, G );\n" );
        AppendTo( file, "end;\n\n\n"     );
    od;

    # write a magic string to the files
    AppendTo( file, "ANUPQmagic := \"groups saved to file\";\n" );
end;
