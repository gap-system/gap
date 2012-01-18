#############################################################################
####
##
#A  anupga.gi                   ANUPQ package                    Frank Celler
#A                                                           & Eamonn O'Brien
#A                                                           & Benedikt Rothe
##
##  Install file for p-group generation of automorphism group  functions  and
##  variables.
##
#A  @(#)$Id: anupga.gi,v 1.9 2011/11/29 20:00:11 gap Exp $
##
#Y  Copyright 1992-1994,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1992-1994,  School of Mathematical Sciences, ANU,     Australia
##

#############################################################################
##
#F  ANUPQerror( <param> ) . . . . . . . . . . . . .  report illegal parameter
##
InstallGlobalFunction( ANUPQerror, function( param )
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
    "    \"SetupFile\", <file>\n",
    "Illegal Parameter: \"", param, "\"" );
end );

#############################################################################
##
#F  ANUPQextractArgs( <args>) . . . . . . . . . . . . . . parse argument list
##
InstallGlobalFunction( ANUPQextractArgs, function( args )
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

end );

#############################################################################
##
#F  ANUPQauto( <G>, <gens>, <imgs> )  . . . . . . . .  construct automorphism
##
InstallGlobalFunction( ANUPQauto, function( G, gens, images )
   local   f;

   f := GroupHomomorphismByImagesNC( G, G, gens, images );
   SetIsBijective( f, true );
   SetKernelOfMultiplicativeGeneralMapping( f, TrivialSubgroup(G) );

   return f;
end );

#############################################################################
##
#F  ANUPQautoList( <G>, <gens>, <L> ) . . . . . . . construct a list of autos
##
InstallGlobalFunction( ANUPQautoList, function( G, gens, automs )
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

end );

#############################################################################
##
#F  ANUPQSetAutomorphismGroup( <G>, <gens>, <automs>, <isSoluble> ) 
##
InstallGlobalFunction( ANUPQSetAutomorphismGroup, 
function( G, gens, centralAutos, otherAutos, relativeOrders, isSoluble )

    SetANUPQAutomorphisms( G, 
            rec( gens := gens, 
                 centralAutos   := centralAutos, 
                 otherAutos     := otherAutos, 
                 relativeOrders := relativeOrders,
                 isSoluble      := isSoluble ) );

    return;

end );

#############################################################################
##
#F  PqSupplementInnerAutomorphisms( <G> ) 
##
##  returns   a   record   analogous   to   what   is   returned    by    the
##  `AutomorphismGroupPGroup' function of the {\AutPGrp} package, except that
##  only  the  fields  `agAutos',  `agOrder'  and  `glAutos'  are  set.   The
##  automorphisms generate a subgroup of the automorphism  group  of  the  pc
##  group <D> that supplements the inner automorphism group  of  <D>  in  the
##  whole automorphism group of <D>. The group of automorphisms returned  may
##  be a proper subgroup of the full automorphism group. The  descendant  <D>
##  must   have   been   computed    by    the    function    `PqDescendants'
##  (see~"PqDescendants").
##

##!!  Muss angepasst werden auf die jetzt besser verstandenen Anforderungen
##!!  an Automorphismen, nämlich der Unterscheideung zwischen solchen, die
##!!  auf der Frattinigruppe treu operieren und solche, die dies nicht tuen.

InstallGlobalFunction( "PqSupplementInnerAutomorphisms",
function( G )
    local   gens,  automs,  A, centralAutos, otherAutos;

#Print( "Attention: the function PqSupplementInnerAutomorphisms()",
#       " is outdated and dangerous\n" );

    if not HasANUPQAutomorphisms( G ) then
        return Error( "group does not carry automorphism information" );
    fi;

    automs := ANUPQAutomorphisms( G );

    gens := automs.gens;

    centralAutos := ANUPQautoList( G, gens, automs.centralAutos );
    otherAutos   := ANUPQautoList( G, gens, automs.otherAutos );
    
    return rec( agAutos := centralAutos,
                agOrder := automs.relativeOrders,
                glAutos := otherAutos );

end );

#############################################################################
##
#F  ANUPQprintExps( <pqi>, <lst> ) . . . . . . . . . . .  print exponent list
##
InstallGlobalFunction( ANUPQprintExps, function( pqi, lst )
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
end );

#############################################################################
##
#V  ANUPGAGlobalVariables
##
InstallValue( ANUPGAGlobalVariables,
              [ "ANUPQgroups", 
                "ANUPQautos", 
                "ANUPQmagic" ] );

#############################################################################
##
#F  PqList( <file> [: SubList := <sub>]) . . . . .  get a list of descendants
##
InstallGlobalFunction( PqList, function( file )
    local   var,  lst,  groups,  autos,  sublist,  func;

    PQ_OTHER_OPTS_CHK("PqList", false);
    # check arguments
    if not IsString(file) then
        Error( "usage: PqList( <file> [: SubList := <sub>])\n" );
    fi;

    for var in ANUPGAGlobalVariables do
        HideGlobalVariables( var );
    od;

    # try to read <file>
    if not READ( file ) or not IsBoundGlobal( "ANUPQmagic" )  then

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

        sublist := VALUE_PQ_OPTION("SubList", [ 1 .. Length( groups ) ]);
        if not IsList(sublist) then
            sublist := [ sublist ];
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

end );

#############################################################################
##
#F  PqLetterInt( <n> ) . . . . . . . . . . . . . . . 
##
InstallGlobalFunction( PqLetterInt, function ( n )
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
end );

#############################################################################
##
#F  PQ_DESCENDANTS( <args> ) . . . . . . . . . construct descendants of group
##
InstallGlobalFunction( PQ_DESCENDANTS, function( args )
    local   datarec, p, class, G, ndescendants;

    datarec := ANUPQ_ARG_CHK("PqDescendants", args);
    if datarec.calltype = "interactive" and IsBound(datarec.descendants) then
        Info(InfoANUPQ, 1, 
             "`PqDescendants' should not be called more than once for the");
        Info(InfoANUPQ, 1, 
             "same process ... returning previously computed descendants.");
        return datarec.descendants;
    elif datarec.calltype = "GAP3compatible" then
        # ANUPQ_ARG_CHK calls PQ_DESCENDANTS itself in this case
        # (so datarec.descendants has already been computed)
        return datarec.descendants;
    fi;

    PQ_AUT_GROUP(datarec.group); # make sure we have the aut. grp.

    # if <G> is not capable and we want to compute something, return
    if HasIsCapable(datarec.group) and not IsCapable(datarec.group) and 
       VALUE_PQ_OPTION("SetupFile") = fail then
        datarec.descendants := [];
        return datarec.descendants;
    fi;

    PushOptions(rec(nonuser := true));
    p     := PrimePGroup(datarec.group);
    class := PClassPGroup(datarec.group);
    if not( IsBound(datarec.pQuotient) and 
            p = PrimePGroup(datarec.pQuotient) and
            class = datarec.class or
            IsBound(datarec.pCover) and
            p = PrimePGroup(datarec.pCover) and
            IsBound(datarec.pcoverclass) and 
            class = datarec.pcoverclass - 1 ) then
        PQ_PC_PRESENTATION( datarec, "pQ" : Prime := p, ClassBound := class );
    fi;
    if not( IsBound(datarec.pCover) and p = PrimePGroup(datarec.pCover) and
            class = datarec.pcoverclass - 1 ) then
        PQ_P_COVER( datarec );
    fi;
    PQ_PG_SUPPLY_AUTS( datarec, "pG" );
    ndescendants := PQ_PG_CONSTRUCT_DESCENDANTS( datarec );
    PopOptions();

    if datarec.calltype = "non-interactive" then
        PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL(datarec);
        if IsBound( datarec.setupfile ) then
            return true;
        fi;
    fi;
        
    if ndescendants = 0 then
        datarec.descendants := [];
        return datarec.descendants;
    fi;

    datarec.descendants 
        := PqList( Filename( ANUPQData.tmpdir, "GAP_library" ) : recursive );
    for G in datarec.descendants do
        if not HasIsCapable(G)  then
            SetIsCapable( G, false );
        fi;
        SetFeatureObj( G, IsPGroup, true );
    od;

    return datarec.descendants;
end );

#############################################################################
##
#F  PqDescendants( <G> ... )  . . . . . . . . .  construct descendants of <G>
#F  PqDescendants( <i> )
#F  PqDescendants()
##
InstallGlobalFunction( PqDescendants, function( arg )
    return PQ_DESCENDANTS(arg);
end );

#############################################################################
##
#F  PqSetPQuotientToGroup( <i> ) . . . set p-quotient as the group of process
#F  PqSetPQuotientToGroup()
##
InstallGlobalFunction( PqSetPQuotientToGroup, function( arg )
local datarec;
    ANUPQ_IOINDEX_ARG_CHK(arg);
    datarec := ANUPQData.io[ ANUPQ_IOINDEX(arg) ];
    if not IsBound(datarec.pQuotient) then
        Error( "p-quotient has not yet been calculated!\n" );
    fi;
    datarec.group := datarec.pQuotient;
end );

#############################################################################
##
#F  SavePqList( <file>, <lst> ) . . . . . . . . .  save a list of descendants
##
InstallGlobalFunction( SavePqList, function( file, list )
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
        p    := PrimePGroup( G );
        AppendTo( file, "## group number: ", l, "\n"                     );
        AppendTo( file, "ANUPQgroups[", l, "] := function( L )\n"        );
        AppendTo( file, "local   G,  A,  B;\n"                           );
        AppendTo( file, "G := FreeGroup( IsSyllableWordsFamily,\n"       );
        AppendTo( file, "                ", Length(pcgs), ", \"G\" );\n" );
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
                AppendTo( file, IsSolvableGroup( G ), " );\n" );
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
end );

#E  anupga.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
