
#############################################################################
##
#F  SavePqList( <file>, <lst> ) . . . . . . . . .  save a list of descendants
##
SavePqList := function( arg )
    local   file,  list,  appendExp,  entries,  entry,  l,  G,  p,
            i,  w,  str,  word,  j,  r,  gens;

    # check arguments
    if 3 < Length(arg) or Length(arg) < 2  then
        Error( "usage: SavePqList( <file>, <list> )" );
    fi;
    file := arg[1];
    list := arg[2];

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



    # <entries> hold a list of record entries which will be saved
    entries := [ "pqIdent", "exponentLaw", "isAgAutomorphisms",
                 "isCapable", "rank", "nuclearRank" ];
    if Length(arg) = 3  then
        if IsList(arg[3])  then
            Append( entries, arg[3] );
       else
            Add( entries, arg[3] );
       fi;
    fi;

    # print head of file
    PrintTo(  file, "ANUPQgroups := [];\n"    );
    AppendTo( file, "Unbind(ANUPQautos);\n\n" );

    # run through all groups in <list>
    for l  in [ 1 .. Length(list) ]  do
        G    := list[l];
        gens := G.generators;
        p    := RelativeOrderOfPcElement(gens[1]);
        AppendTo( file, "## group number: ", l, "\n"                     );
        AppendTo( file, "ANUPQgroups[", l, "] := function( L )\n"        );
        AppendTo( file, "local   G,  H,  A,  B;\n"                       );
        AppendTo( file, "G := FreeGroup( ", Length(gens), ", \"G\" );\n" );
        AppendTo( file, "G.relators := [\n"                              );

        # at first the power relators
        for i in [ 1 .. Length(gens) ]  do
            if 1 < i  then
                AppendTo( file, ",\n" );
            fi;
            w   := gens[i]^p;
            str := Concatenation( "G.", String(i), "^", String(p) );
            if w <> G.identity  then
                word := ExponentsOfPcElement( Pcgs(G), w );
                str  := Concatenation( str, "/(" );
                str  := appendExp( str,word );
                str  := Concatenation( str, ")" );
            fi;
            AppendTo( file, str );
        od;

        # and now the commutator relators
        for i  in [ 1 .. Length(gens)-1 ]  do
            for j  in [ i+1 .. Length(gens) ]  do
                w := Comm( gens[j], gens[i] );
                if w <> G.identity  then
                    word := ExponentsOfPcElement( Pcgs(G), w );
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
        AppendTo( file, "H := G;\n"                                );
        AppendTo( file, "G := AgGroupFpGroup(G);\n"                );
        AppendTo( file, "G.relators := H.relators;\n"              );
        AppendTo( file, "G.abstractGenerators := H.generators;\n"  );

        # add automorphisms
        if IsBound(G.automorphisms)  then
            AppendTo( file, "A := [];\nB := [" );
    	    for r  in [ 1 .. RankPGroup(G) ]  do
                AppendTo( file, "G.", r );
                if r <> RankPGroup(G)  then
                    AppendTo( file, ", " );
    	    	else
    	    	    AppendTo( file, "];\n" );
                fi;
            od;
            for j  in [ 1 .. Length (G.automorphisms) ]  do
                AppendTo( file, "A[", j, "] := [");
                for r  in [ 1 .. RankPGroup(G) ]  do
                    word := Image( G.automorphisms[j], gens[r] );
                    word := ExponentsOfPcElement( Pcgs(G), word );
                    AppendTo( file, appendExp( "", word ) );
                    if r <> RankPGroup(G)  then
                        AppendTo (file, ", \n");
                    fi;
                od;
                AppendTo( file, "]; \n");
            od;
    	    AppendTo( file, "G.automorphisms := ANUPQautoList( G, B, A );\n" );
        fi;

        # add entries stored in <entries>
        for entry  in entries  do
            if IsBound( G.(entry) )  then
                AppendTo( file, "G.", entry, " := " );
                if IsString(G.(entry))  then
                    AppendTo( file, "\"", G.(entry), "\"" );
                else
                    AppendTo( file, G.(entry) );
                fi;
                AppendTo( file, ";\n" );
            fi;
        od;
        AppendTo( file, "Add( L, G );\n" );
        AppendTo( file, "end;\n\n\n"     );
    od;

    # write a magic string to the files
    AppendTo( file, "ANUPQmagic := \"groups saved to file\";\n" );
end;


