#############################################################################
##
#W  methods.gi             Interface to Carat                   Franz G"ahler
##
#Y  Copyright (C) 1999-1006,  Franz G"ahler,       ITAP, Stuttgart University
##
##  Methods for high level functions using Carat
##

#############################################################################
##
#M  BravaisGroup( grp )  . . . . . . . . . . . . . . . . Bravais group of grp
##
InstallMethod( BravaisGroup, 
    "with Carat function Bravais_grp",
    true, [ IsCyclotomicMatrixGroup ], 0,
function( grp )

    local grpfile, resfile, gen, data, res;

    # group must be integer and finite
    if not IsIntegerMatrixGroup( grp ) then
        Error( "grp must be an integer matrix group" );
    fi;
    if not IsFinite( grp ) then
        Error( "grp must be finite" );
    fi;

    # get temporary file names
    grpfile := CaratTmpFile( "grp" );  
    resfile := CaratTmpFile( "res" );

    # write Carat input to temporary file
    gen := GeneratorsOfGroup( grp );
    if gen = [] then
        gen := [ One(grp) ];
    fi;
    data := rec( generators := gen, size := Size( grp ) );
    CaratWriteBravaisFile( grpfile, data );

    # execute Carat program
    CaratCommand( "Bravais_grp", grpfile, resfile );

    # read back result, and remove temporary files
    data := CaratReadBravaisFile( resfile );
    RemoveFile( grpfile );
    RemoveFile( resfile );

    # convert result to appropriate format
    res := GroupByGenerators( data.generators, One( grp ) );
    if IsBound( data.size ) then
        SetSize( res, data.size );
    fi;
    return res;

end );


#############################################################################
##
#F  CaratBravaisInclusions( grp, opt ) . . . . .Bravais inclusions (internal)
##
CaratBravaisInclusions := function( grp, opt )

    local grpfile, resfile, gen, data, args, output, grps, str, res, g, r;

    # get temporary file names
    grpfile := CaratTmpFile( "grp" );  
    resfile := CaratTmpFile( "res" );

    # write Carat input to file
    gen := GeneratorsOfGroup( grp );
    if gen = [] then
        gen := [ One(grp) ];
    fi;
    data := rec( generators := gen, size := Size( grp ) );
    CaratWriteBravaisFile( grpfile, data );

    # execute Carat program
    args := Concatenation( grpfile, " -G", opt );
    CaratCommand( "Bravais_inclusions", args, resfile );

    # read Carat result from file, and remove temporary files
    data := CaratReadMultiBravaisFile( resfile );
    grps := data.groups;
    RemoveFile( grpfile );
    RemoveFile( resfile );

    # convert result into desired format
    res := [];
    for r in grps do
      g := GroupByGenerators( r.generators, One(grp) );
      SetSize( g, r.size );
      Add( res, g );
    od;
    return res;

end;


#############################################################################
##
#M  BravaisSubgroups( grp ) . . . . Bravais subgroups of Bravais group of grp
##
InstallMethod( BravaisSubgroups, 
    "with Carat function Bravais_inclusions",
    true, [ IsCyclotomicMatrixGroup ], 0,
function( grp )
    if DimensionOfMatrixGroup( grp ) > 6 then
        Error( "sorry, only groups of dimension up to 6 are supported" );
    fi;
    return CaratBravaisInclusions( BravaisGroup( grp ), "" );
end );


#############################################################################
##
#M  BravaisSupergroups( grp ) . . Bravais supergroups of Bravais group of grp
##
InstallMethod( BravaisSupergroups, 
    "with Carat function Bravais_inclusions",
    true, [ IsCyclotomicMatrixGroup ], 0,
function( grp )
    if DimensionOfMatrixGroup( grp ) > 6 then
        Error( "sorry, only groups of dimension up to 6 are supported" );
    fi;
    return CaratBravaisInclusions( BravaisGroup( grp ), " -S" );
end );


#############################################################################
##
#F  CaratNormalizerInGLnZFunc( G, opt ) . . . . .  normalizer of G in GL(n,Z)
##
CaratNormalizerInGLnZFunc := function( grp, opt )

    local grpfile, resfile, gen, data, output, res, args;

    # group must be integer and finite
    if not IsIntegerMatrixGroup( grp ) then
        Error( "grp must be an integer matrix group" );
    fi;
    if not IsFinite( grp ) then
        Error( "grp must be finite" );
    fi;

    # get temporary files
    grpfile := CaratTmpFile( "grp" );  
    resfile := CaratTmpFile( "res" );

    # write input data
    gen := GeneratorsOfGroup(grp);
    if gen = [] then
        gen := [ One(grp) ];
    fi;
    data := rec( generators := gen, size := Size( grp ) );
    CaratWriteBravaisFile( grpfile, data );

    # execute Carat command
    args    := Concatenation( grpfile, opt );
    CaratCommand( "Normalizer", args, resfile );

    # read back the data
    data := CaratReadBravaisFile( resfile );
    RemoveFile( grpfile );
    RemoveFile( resfile );

    # construct result
    gen := Concatenation( data.generators, data.normalizer );
    res := GroupByGenerators( gen, One( grp ) );

    return res;

end;


#############################################################################
##
#M  NormalizerInGLnZ( G ) . . . Normalizer of integer matrix group in GL(n,Z)
##
InstallMethod( NormalizerInGLnZ, "with Carat function Normalizer",
    true, [ IsCyclotomicMatrixGroup ], 0, 
    G -> CaratNormalizerInGLnZFunc( G, "" ) );

InstallMethod( NormalizerInGLnZ, "with Carat function Normalizer",
    true, [ IsCyclotomicMatrixGroup and IsBravaisGroup ], 0, 
    NormalizerInGLnZBravaisGroup );

InstallMethod( NormalizerInGLnZ, "via Bravais group", 
    true, [ IsCyclotomicMatrixGroup and HasBravaisGroup ], 0,
    G -> Normalizer( NormalizerInGLnZ( BravaisGroup( G ) ), G ) );



#############################################################################
##
#M  NormalizerInGLnZBravaisGroup( G )  norm. of Bravais group of G in GL(n,Z)
##
InstallMethod( NormalizerInGLnZBravaisGroup, 
    "with Carat function Normalizer",
    true, [ IsCyclotomicMatrixGroup ], 0, 
function(G)
    local N;
    N := CaratNormalizerInGLnZFunc( G, " -b" );
    if HasBravaisGroup( G ) then
        SetNormalizerInGLnZ( BravaisGroup( G ), N );
    fi;
    return N;
end );


#############################################################################
##
#M  CentralizerInGLnZ( G ) . . . . . . . . . . . . . . Centralizer in GL(n,Z)
##
InstallMethod( CentralizerInGLnZ, "via NormalizerInGLnZ", 
    true, [ IsCyclotomicMatrixGroup ], 0,
function( G )
    local N;
    if HasBravaisGroup( G ) and not HasNormalizerInGLnZ( G ) then
        N := NormalizerInGLnZ( BravaisGroup( G ) );
    else
        N := NormalizerInGLnZ( G );
    fi;
    return Centralizer( N, G );
end );


#############################################################################
##
#M  RepresentativeAction( GL( n, Integers), G1, G2 )  . . . . . . . . . . . . 
#M                                   returns m in GL(n,Z) with m*G1*m^-1 = G2
##
InstallOtherMethod( RepresentativeActionOp, 
    "with Carat function Z_equiv", true, 
    [ IsNaturalGLnZ, IsCyclotomicMatrixGroup, IsCyclotomicMatrixGroup,
      IsFunction ], 0,

function( glnz, grp1, grp2, opr )

    local grp1file, grp2file, resfile, args, gen, data, input, line, res;

    # groups must be integer
    if not IsIntegerMatrixGroup( grp1 ) then
        Error( "grp1 must be an integer matrix group" );
    fi;
    if not IsIntegerMatrixGroup( grp2 ) then
        Error( "grp2 must be an integer matrix group" );
    fi;

    # groups must be finite
    if not IsFinite( grp1 ) then
        Error( "grp1 must be finite" );
    fi;
    if not IsFinite( grp2 ) then
        Error( "grp2 must be finite" );
    fi;

    # catch the trivial case
    if grp1 = grp2 then
        return IdentityMat( DimensionOfMatrixGroup( grp1 ) );
    fi;

    # get temporary file names
    grp1file := CaratTmpFile( "grp1" );  
    grp2file := CaratTmpFile( "grp2" );
    resfile  := CaratTmpFile( "res"  );

    # write Carat input to temporary files
    gen := GeneratorsOfGroup( grp1 );
    if gen = [] then
        gen := [ One(grp1) ];
    fi;
    data := rec( generators := gen, size := Size(grp1) );
    CaratWriteBravaisFile( grp1file, data );

    gen := GeneratorsOfGroup( grp2 );
    if gen = [] then
        gen := [ One(grp2) ];
    fi;
    data := rec( generators := gen, size := Size(grp2) );
    CaratWriteBravaisFile( grp2file, data );

    # execute Carat program
    args := Concatenation( grp2file, " ", grp1file );
    CaratCommand( "Z_equiv", args, resfile );

    # read back the result
    input := InputTextFile( resfile );
    line := CaratReadLine( input );
    if line = "the groups are not conjugated in GL_n(Z)\n" then
        res := fail;
    else
        res := CaratReadMatrix( input, line );        
    fi;
    CloseStream( input );

    # remove temporary files
    RemoveFile( grp1file );
    RemoveFile( grp2file );
    RemoveFile( resfile );

    return res;

end );


#############################################################################
##
#M  ZClassRepsQClass( grp )  . . . . . . . . . Z-class reps in Q-class of grp
##
InstallMethod( ZClassRepsQClass, 
    "with Carat function QtoZ",
    true, [ IsCyclotomicMatrixGroup ], 0,
function( grp )

    local grpfile, resfile, gen, data, output, str, res, g, r;

    # group must be rational and finite
    if not IsRationalMatrixGroup( grp ) then
        Error( "grp must be a rational matrix group" );
    fi;
    if not IsFinite( grp ) then
        Error( "grp must be finite" );
    fi;

    # get temporary file names
    grpfile := CaratTmpFile( "grp" );  
    resfile := CaratTmpFile( "res" );

    # write Carat input to file
    gen := GeneratorsOfGroup( grp );
    if gen = [] then
        gen := [ One(grp) ];
    fi;
    data := rec( generators := gen, size := Size(grp) );
    CaratWriteBravaisFile( grpfile, data );

    # execute Carat program
    CaratCommand( "QtoZ", Concatenation( grpfile, " -q" ), resfile );

    # read Carat result from file, and remove temporary files
    data := CaratReadMultiBravaisFile( resfile );
    RemoveFile( grpfile );
    RemoveFile( resfile );

    # convert result into desired format
    res := [];
    for r in data.groups do
        g := GroupByGenerators( r.generators );
        SetSize( g, r.size );
        Add( res, g );
    od;

    return res;

end ); 


#############################################################################
##
#M  CaratCrystalFamilies . . . . . . . . . . .crystal family symbols in Carat
##
InstallValue( CaratCrystalFamilies, [ 
[ "1" ], 
[ "1,1", "1;1", "2-1", "2-2"],
[ "1,1,1", "1,1;1", "1;1;1", "2-1;1", "2-2;1", "3" ],
[ "1,1,1,1", "1,1,1;1", "1,1;1,1", "1,1;1;1", "1;1;1;1", "2-1',2-1'",
  "2-1,2-1", "2-1;1,1", "2-1;1;1", "2-1;2-1", "2-1;2-2", "2-2',2-2'",
  "2-2,2-2", "2-2;1,1", "2-2;1;1", "2-2;2-2", "3;1", "4-1", "4-1'",
  "4-2", "4-2'", "4-3", "4-3'" ],
[ "1,1,1,1,1", "1,1,1,1;1", "1,1,1;1,1", "1,1,1;1;1", "1,1;1,1;1",
  "1,1;1;1;1", "1;1;1;1;1", "2-1',2-1';1", "2-1,2-1;1", "2-1;1,1,1",
  "2-1;1,1;1", "2-1;1;1;1", "2-1;2-1;1", "2-1;2-2;1", "2-2',2-2';1",
  "2-2,2-2;1", "2-2;1,1,1", "2-2;1,1;1", "2-2;1;1;1", "2-2;2-2;1",
  "3;1,1", "3;1;1", "3;2-1", "3;2-2", "4-1';1", "4-1;1", "4-2';1",
  "4-2;1", "4-3';1", "4-3;1", "5-1", "5-2" ],
[ "1,1,1,1,1,1", "1,1,1,1,1;1", "1,1,1,1;1,1", "1,1,1,1;1;1", "1,1,1;1,1,1",
  "1,1,1;1,1;1", "1,1,1;1;1;1", "1,1;1,1;1,1", "1,1;1,1;1;1", "1,1;1;1;1;1",
  "1;1;1;1;1;1", "2-1',2-1',2-1'", "2-1',2-1';1,1", "2-1',2-1';1;1",
  "2-1',2-1';2-1", "2-1',2-1';2-2", "2-1,2-1,2-1", "2-1,2-1;1,1",
  "2-1,2-1;1;1", "2-1,2-1;2-1", "2-1,2-1;2-2", "2-1;1,1,1,1", "2-1;1,1,1;1",
  "2-1;1,1;1,1", "2-1;1,1;1;1", "2-1;1;1;1;1", "2-1;2-1;1,1", "2-1;2-1;1;1",
  "2-1;2-1;2-1", "2-1;2-1;2-2", "2-1;2-2',2-2'", "2-1;2-2,2-2", 
  "2-1;2-2;1,1", "2-1;2-2;1;1", "2-1;2-2;2-2", "2-2',2-2',2-2'",
  "2-2',2-2';1,1", "2-2',2-2';1;1", "2-2',2-2';2-2", "2-2,2-2,2-2",
  "2-2,2-2;1,1", "2-2,2-2;1;1", "2-2,2-2;2-2", "2-2;1,1,1,1", 
  "2-2;1,1,1;1", "2-2;1,1;1,1", "2-2;1,1;1;1", "2-2;1;1;1;1",
  "2-2;2-2;1,1", "2-2;2-2;1;1", "2-2;2-2;2-2", "3,3", "3;1,1,1", "3;1,1;1",
  "3;1;1;1", "3;2-1;1", "3;2-2;1", "3;3", "4-1';1,1", "4-1';1;1", "4-1';2-1",
  "4-1';2-2", "4-1;1,1", "4-1;1;1", "4-1;2-1", "4-1;2-2", "4-2';1,1", 
  "4-2';1;1", "4-2';2-1", "4-2';2-2", "4-2;1,1", "4-2;1;1", "4-2;2-1",
  "4-2;2-2", "4-3';1,1", "4-3';1;1", "4-3';2-1", "4-3';2-2", "4-3;1,1", 
  "4-3;1;1", "4-3;2-1", "4-3;2-2", "5-1;1", "5-2;1", "6-1", "6-2", "6-2'",
  "6-3", "6-3'", "6-4", "6-4'" ]
] );


#############################################################################
##
#M  CaratCrystalFamiliesFlat . . flat list of crystal family symbols in Carat
##
CaratPermutedSymbols := function( symb )

    local str, lst, pos, new, l, i;

    str := symb;
    lst := [];
    pos := Position( str, ';' );
    while pos <> fail do
        Add( lst, str{[1..pos-1]} );
        str := str{[pos+1..Length(str)]};
        pos := Position( str, ';' );
    od;
    Add( lst, str );

    lst := PermutationsList( lst );
    
    new := [];
    for l in lst do
        str := l[1];
        for i in [2..Length(l)] do
            str := Concatenation( str, ";", l[i] );
        od;
        Add( new, str );
    od;

    return new;

end;

InstallValue( CaratCrystalFamiliesFlat, Concatenation( 
    List( Concatenation( CaratCrystalFamilies ), CaratPermutedSymbols ) ) ); 


#############################################################################
##
#M  BravaisGroupsCrystalFamily( symb ) . . . Bravais groups in crystal family
##
InstallGlobalFunction( BravaisGroupsCrystalFamily, function( symb )

    local resfile, outfile, input, command, program, output, 
          err, data, str, res, g, r;

    if not symb in CaratCrystalFamiliesFlat then
        Error("invalid crystal family symbol - please consult Carat manual");
    fi;

    # get temporary file name
    resfile := CaratTmpFile( "res" );
    outfile := CaratTmpFile( "out" );

    input := InputTextString( Concatenation( symb, "\ny\n", resfile, "\na\n"));

    # find executable
    command := "Bravais_catalog";
    program := Filename( CARAT_BIN_DIR, command );    
    if program = fail then
        Error( Concatenation( "Carat program ", command, " not found." ) );
    fi;

    # execute command
    output := OutputTextFile( outfile, false );
    err    := Process( DirectoryCurrent(), program, input, output, [ ] );
    CloseStream( output );

    # did it work?
    if err = 2  then                   # we used wrong arguments
        CaratShowFile( resfile );      # contains usage advice
    fi;
    if err < 0  then
        Error( Concatenation( "Carat program ", command,
                              " failed with error code ", String(err) ) );
    fi;

    # read Carat result from file, and remove temporary file
    data := CaratReadMultiBravaisFile( resfile );
    RemoveFile( resfile );

    # convert result into desired format
    res := [];
    for r in data.groups do
        g := GroupByGenerators( r.generators );
        SetSize( g, r.size );
        Add( res, g );
    od;

    return res;

end ); 


#############################################################################
##
#F  CaratQClassCatalog( grp, mode )  . . . . . . . . .  access QClass catalog
##
##  Takes a finite unimodular group <grp> and an integer <mode>, and
##  returns a record with one or several of the following components,
##  depending on the decomposition of <mode> = <n0> + <n1> * 2 + <n2> * 4
##  into powers of 2:
##
##    qclass        Q-class symbol             - always present
##    familysymb    crystal family symbol      - present if <n0> <> 0
##    trans         trafo to standard rep.     - present if <n1> <> 0
##    group         standard representation    - present if <n2> <> 0
##
InstallGlobalFunction( CaratQClassCatalog, function( grp , mode )

    local rem, with_symb, with_trans, with_group, grpfile, resfile, gen,
          res, data, args, input, str;

    # check options
    rem := mode mod 2; mode := (mode - rem) / 2; with_symb  := rem <> 0;
    rem := mode mod 2; mode := (mode - rem) / 2; with_trans := rem <> 0;
    rem := mode mod 2; mode := (mode - rem) / 2; with_group := rem <> 0;

    # group must be integer and finite
    if not IsIntegerMatrixGroup( grp ) then
        Error( "grp must be an integer matrix group" );
    fi;
    if not IsFinite( grp ) then
        Error( "grp must be finite" );
    fi;

    # get temporary file names
    grpfile := CaratTmpFile( "grp" );  
    resfile := CaratTmpFile( "res" );

    # write Carat input to temporary file
    gen := GeneratorsOfGroup( grp );
    if gen = [] then
        gen := [ One(grp) ];
    fi;
    data := rec( generators := gen, size := Size( grp ) );
    CaratWriteBravaisFile( grpfile, data );

    # add options
    args := grpfile;
    if with_symb  then
        args := Concatenation( args, " -s" );
    fi;
    if with_trans then
        args := Concatenation( args, " -T" );
    fi;
    if with_group then
        args := Concatenation( args, " -i" );
    fi;

    # execute Carat program
    CaratCommand( "Q_catalog", args, resfile );

    # parse the result file
    res := rec();
    input := InputTextFile( resfile );

    # get the QClass name
    str   := CaratReadLine( input );
    if str{[1..22]} <> "Name of this Q-class: " then
        Error( Concatenation( 
               "Carat program Q_catalog failed with message\n", str ) );
    fi;
    res.qclass := str{[23..Length(str)-1]};

    # get the family symbol
    if with_symb then
        str := CaratReadLine( input );
        res.familysymb := str{[21..Length(str)-1]};
    fi;

    # get the transformation matrix
    if with_trans then
        str := CaratReadLine( input );
        res.trans := CaratReadMatrix( input, str );
    fi;

    # get the equivalent catalog group
    if with_group then
        str := CaratReadLine( input );
        data := CaratReadBravaisRecord( input, str );
        res.group := GroupByGenerators( data.generators, One( grp ) );
        if IsBound( data.size ) then
            SetSize( res.group, data.size );
        fi;
    fi;

    return res;

end );

#############################################################################
##
#F  ConjugatorQClass( G1, G2 ) . . . . . .returns C in GL(n,Q) with G1^C = G2 
##
InstallGlobalFunction( "ConjugatorQClass", function( G1, G2 )

    local R1, R2;

    if not IsIntegerMatrixGroup( G1 ) or not IsFinite( G1 ) then
        Error( "G1 must be a finite integer matrix group" );
    fi;
    if not IsIntegerMatrixGroup( G2 ) or not IsFinite( G2 ) then
        Error( "G2 must be a finite integer matrix group" );
    fi;

    if DimensionOfMatrixGroup( G1 ) <> DimensionOfMatrixGroup( G2 ) then
        return fail;
    fi;
    if Size( G1 ) <> Size( G2 ) then
        return fail;
    fi;
    if DimensionOfMatrixGroup(G1) > 6 or DimensionOfMatrixGroup(G2) > 6 then
        Error( "ConjugatorQClass: only dimensions up to 6 are supported ");
    fi;

    R1 := CaratQClassCatalog( G1, 2 );
    R2 := CaratQClassCatalog( G2, 2 );
    if R1.qclass <> R2.qclass then
        return fail;
    else
        return R2.trans^-1*R1.trans;
    fi;

end );

#############################################################################
##
#F  CaratInvariantFormSpace( grp [, opts] ) . . . .  space of invariant forms 
##
CaratInvariantFormSpace := function( arg )

    local grp, opts, optstring, gens, lat, ilat, tilat, 
          grpfile, resfile, forms;

    # check arguments
    grp := arg[1];
    if not IsRationalMatrixGroup( grp ) then
        Error( "grp must be a rational matrix group" );
    fi;
    if Length( arg ) > 1 then
        opts := arg[2];
        if not IsRecord( opts ) then
            Error( "opts must be a record" );
        fi;
    else
        opts := rec();
    fi;

    # process options
    optstring := "";
    if IsBound( opts.mode ) then
        if opts.mode = "all" then
            Append( optstring, " -a" );
        elif opts.mode = "skew" then
            Append( optstring, " -s" );
        elif opts.mode <> "sym" then
            Error( "opts.mode must be \"sym\", \"skew\", or \"all\"" );
        fi;
    fi;
    if IsBound( opts.prime ) then
        if not IsPrime( opts.prime ) then
            Error( "opts.prime must be a prime" );
        fi;
        Append( optstring, " -p=" );
        Append( optstring, String( opts.prime ) );
    fi;

    # convert to integer matrix group
    gens := GeneratorsOfGroup( grp );
    if not IsIntegerMatrixGroup( grp ) then
        lat := InvariantLattice( grp );
        if IsBool( lat ) then
            return fail;
        fi;
        ilat := lat^-1;
        gens := List( gens, m -> TransposedMat( lat * m * ilat ) );
    else
        gens := List( gens, m -> TransposedMat( m ) );
    fi;

    # get temporary file names
    grpfile   := CaratTmpFile( "grp"  );
    resfile   := CaratTmpFile( "res" );
    optstring := Concatenation( grpfile, optstring );

    # write Carat input to temporary file
    CaratWriteBravaisFile( grpfile, rec( generators := gens ) );

    # execute Carat program
    CaratCommand( "Form_space", optstring, resfile );

    # read back result, and remove temporary files
    forms := CaratReadMatrixFile( resfile );
    RemoveFile( grpfile );
    RemoveFile( resfile );

    # convert to original basis
    if not IsIntegerMatrixGroup( grp ) then
       tilat := TransposedMat( ilat );
       forms := List( forms, m -> ilat * m * tilat );
    fi;
    return forms;

end;
