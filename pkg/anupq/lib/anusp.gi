#############################################################################
####
##
#A  anusp.gi                    ANUPQ package                  Eamonn O'Brien
#A                                                             Alice Niemeyer 
##
#A  @(#)$Id: anusp.gi,v 1.6 2011/11/29 20:00:13 gap Exp $
##
#Y  Copyright 1993-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1993-2001,  School of Mathematical Sciences, ANU,     Australia
##

#############################################################################
##
#F  ANUPQSPerror( <param> )  . . . . . . . . . . . . report illegal parameter
##
InstallGlobalFunction( ANUPQSPerror, function( param )
    Error(
    "Valid Options:\n",
    "    \"ClassBound\", <bound>\n",
    "    \"PcgsAutomorphisms\"\n",
    "    \"Exponent\", <exponent>\n",
    "    \"Metabelian\"\n",
    "    \"OutputLevel\", <level>\n",
    "    \"SetupFile\", <file>\n",
    "Illegal Parameter: \"", param, "\"" );
end );

#############################################################################
##
#F  ANUPQSPextractArgs( <args> )  . . . . . . . . . . . . parse argument list
##
InstallGlobalFunction( ANUPQSPextractArgs, function( args )
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

end );

#############################################################################
##
#V  ANUSPGlobalVariables
##
InstallValue( ANUSPGlobalVariables, 
              [ "ANUPQmagic",
                "ANUPQautos",
                "ANUPQgroups",
                ] );

#############################################################################
##
#F  PqFpGroupPcGroup( <G> ) . . . . . .  corresponding fp group of a pc group
##
InstallGlobalFunction( PqFpGroupPcGroup, 
    G -> Image( IsomorphismFpGroup( G ) )
);

#############################################################################
##
#M  FpGroupPcGroup( <G> ) . . . . . . .  corresponding fp group of a pc group
##
InstallMethod( FpGroupPcGroup, "pc group", [IsPcGroup], 0, PqFpGroupPcGroup );

#############################################################################
##
#F  PQ_EPIMORPHISM_STANDARD_PRESENTATION( <args> ) . (epi. onto) SP for group
##
InstallGlobalFunction( PQ_EPIMORPHISM_STANDARD_PRESENTATION, 
function( args )
    local   datarec, rank, Q, Qclass, automorphisms, generators, x,
            images, i, r, j, aut, result, desc, k;

    datarec := ANUPQ_ARG_CHK("StandardPresentation", args);

    if datarec.calltype = "interactive" and IsBound(datarec.SPepi) then
       # Note: the `pq' binary seg-faults if called twice to 
       # calculate the standard presentation of a group
      return datarec.SPepi;
    fi;

    if VALUE_PQ_OPTION("pQuotient") = fail and
       VALUE_PQ_OPTION("Prime", datarec) <> fail then
       # Ensure a saved value of `Prime' has precedence
       # over a saved value of `pQuotient'.
        Unbind(datarec.pQuotient);
    fi;

    if VALUE_PQ_OPTION("pQuotient", datarec) <> fail then
        PQ_AUT_GROUP( datarec.pQuotient );
        datarec.Prime := PrimePGroup( datarec.pQuotient );
    elif VALUE_PQ_OPTION("Prime", datarec) <> fail then
        rank := Number( List( AbelianInvariants(datarec.group), 
                              x -> Gcd(x, datarec.Prime) ),
                        y -> y = datarec.Prime );

        # construct free group with <rank> generators
        Q := FreeGroup( IsSyllableWordsFamily, rank, "q" );
    
        # construct power-relation
        Q := Q / List( GeneratorsOfGroup(Q), x -> x^datarec.Prime );
    
        # construct pc group
        Q := PcGroupFpGroup(Q);
    
        # construct automorphism
        automorphisms := [];
        generators := GeneratorsOfGroup(Q);
        for x in GeneratorsOfGroup( GL(rank, datarec.Prime) ) do
            images := [];
            for i  in [ 1 .. rank ]  do
                r := One(Q);
                for j  in [ 1 .. rank ]  do
                    r := r * generators[j]^Int(x[i][j]);
                od;
                images[i] := r;
            od;
            aut := GroupHomomorphismByImages( Q, Q, generators, images );
            SetIsBijective( aut, true );
            Add( automorphisms, aut );
        od;
        SetAutomorphismGroup( Q, GroupByGenerators( automorphisms ) );
        datarec.pQuotient := Q;
    fi;
    
    #PushOptions(rec(nonuser := true));
    Qclass := PClassPGroup( datarec.pQuotient );
    if VALUE_PQ_OPTION("ClassBound", 63) <= Qclass then
        Error( "option `ClassBound' must be greater than `pQuotient' class (",
               Qclass, ")\n" );
    fi;
    PQ_PC_PRESENTATION(datarec, "SP" : ClassBound := Qclass);

    PQ_SP_STANDARD_PRESENTATION(datarec);

    PQ_SP_ISOMORPHISM(datarec);

    if datarec.calltype = "non-interactive" then
        PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL(datarec);
        if IsBound( datarec.setupfile ) then
            #PopOptions();
            return true;
        fi;
    fi;

    # try to read output
    result := ANUPQReadOutput( ANUPQData.SPimages, ANUSPGlobalVariables );

    if not IsBound(result.ANUPQmagic)  then
        Error("something wrong with `pq' binary. Please check installation\n");
    fi;

    desc := rec();
    result.ANUPQgroups[Length(result.ANUPQgroups)](desc);
#    if result.ANUPQautos <> fail and 
#       Length( result.ANUPQautos ) = Length( result.ANUPQgroups ) then
#    	result.ANUPQautos[ Length(result.ANUPQgroups) ]( desc.group );
#    fi;

    # revise images to correspond to images of user-supplied generators 
    datarec.SP := desc.group;
    x  := Length( desc.map );
    k  := Length( GeneratorsOfGroup( datarec.group ) );
    # images of user supplied generators are last k entries in .pqImages 

    datarec.SPepi := GroupHomomorphismByImagesNC( 
                         datarec.group, 
                         datarec.SP, 
                         GeneratorsOfGroup(datarec.group),
                         desc.map{[x - k + 1..x]} );
    #PopOptions();
    return datarec.SPepi;
end );

#############################################################################
##
#F  EpimorphismPqStandardPresentation( <arg> ) . . . epi. onto SP for p-group
##
InstallGlobalFunction( EpimorphismPqStandardPresentation, function( arg )
    return PQ_EPIMORPHISM_STANDARD_PRESENTATION( arg );
end );

#############################################################################
##
#F  PqStandardPresentation( <arg> : <options> ) . . . . . . .  SP for p-group
##
InstallGlobalFunction( PqStandardPresentation, function( arg )
    local SPepi;

    SPepi := PQ_EPIMORPHISM_STANDARD_PRESENTATION( arg );
    if SPepi = true then
      return true; # the SetupFile case
    fi;
    return Range( SPepi );
end );

#############################################################################
##
#M  EpimorphismStandardPresentation( <F> ) . . . . . epi. onto SP for p-group
#M  EpimorphismStandardPresentation( [<i>] )
##
InstallMethod( EpimorphismStandardPresentation, 
               "fp group", [IsFpGroup], 0,
               EpimorphismPqStandardPresentation );

InstallMethod( EpimorphismStandardPresentation, 
               "pc group", [IsPcGroup], 0,
               EpimorphismPqStandardPresentation );

InstallMethod( EpimorphismStandardPresentation, 
               "positive integer", [IsPosInt], 0,
               EpimorphismPqStandardPresentation );

InstallOtherMethod( EpimorphismStandardPresentation,
                    "", [], 0,
                    EpimorphismPqStandardPresentation );

#############################################################################
##
#M  StandardPresentation( <F> ) . . . . . . . . . . . . . . .  SP for p-group
#M  StandardPresentation( [<i>] )
##
InstallMethod( StandardPresentation, 
               "fp group", [IsFpGroup], 0,
               PqStandardPresentation );

InstallMethod( StandardPresentation, 
               "pc group", [IsPcGroup], 0,
               PqStandardPresentation );

InstallMethod( StandardPresentation, 
               "positive integer", [IsPosInt], 0,
               PqStandardPresentation );

InstallOtherMethod( StandardPresentation,
                    "", [], 0,
                    PqStandardPresentation );

#############################################################################
##
#F  IsPqIsomorphicPGroup( <G>, <H> )  . . . . . . . . . . .  isomorphism test
##
InstallGlobalFunction( IsPqIsomorphicPGroup, function( G, H )
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

    # check the exponent-p length and the sizes of the groups in the
    # p-central series of both groups 
    if List(PCentralSeries(G,p), Size) <> List(PCentralSeries(H,p), Size) then
        return false;
    fi;

    # if the groups are elementary abelian they are isomorphic
    class := PClassPGroup(G);
    if class = 1  then
        return true;
    fi;
    
    # compute a standard presentation for both
    SG := PqStandardPresentation(PqFpGroupPcGroup(G)
                                 : Prime := p, ClassBound := class);
    SH := PqStandardPresentation(PqFpGroupPcGroup(H)
                                 : Prime := p, ClassBound := class);
    
    # the groups are equal if the presentation are equal
    Ggens := GeneratorsOfGroup( FreeGroupOfFpGroup( SG ) );
    Hgens := GeneratorsOfGroup( FreeGroupOfFpGroup( SH ) );
    return RelatorsOfFpGroup(SG)
           = List( RelatorsOfFpGroup(SH), 
                   x -> MappedWord( x, Hgens, Ggens ) );
    
end );

#############################################################################
##
#M  IsIsomorphicPGroup( <F>, <G> )
##
InstallMethod( IsIsomorphicPGroup, "pc group, pc group",
               [IsPcGroup, IsPcGroup], 0,
               IsPqIsomorphicPGroup );

#E  anusp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
