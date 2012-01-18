#############################################################################
##
#W    singular.g           Package singular            Willem de Graaf
#W                                                     Marco Costantini
##
#H    @(#)$Id: singular.g,v 1.59 2011/09/10 16:35:13 alexk Exp $
##
#Y    Copyright (C) 2003 Willem de Graaf and Marco Costantini
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##

Revision.("singular/gap/singular.g") :=
    "@(#)$Id: singular.g,v 1.59 2011/09/10 16:35:13 alexk Exp $";

##############################################################################
##############################################################################

## PART 0. Singular executable file, options, directory ##


# <--- This line is for developing/debugging: this allow to do 
# ReadPackage("singular", "gap/singular.g");
# (by the function SingularReloadFile) as much as needed. Simply ignore it. 
if not IsBound( Sing_Proc ) then  



# The full path to the Singular executable file

# Here in this file must be added a line with the full path to the
# Singular executable file on your system (without the '#'), e.g.
# sing_exec := "/home/graaf/Singular/2-0-3/ix86-Linux/Singular";
# or, if the executable is in the system $PATH and has a name which
# is non-standard (e.g. singular in lowercase), just with its name
# as below:

sing_exec := "singular";

# The directory separator is always '/', even under DOS/Windows or
# MacOS, as in the following example:
# sing_exec := "/usr/local/Singular/2-0-4/ix86-Win/Singular.exe";

# If the Singular executable file is the the system $PATH and has
# the standard name "Singular" started in uppercase, then it is not
# necessary adding this line, because the interface should be able to
# find the executable file itself. You can get this path, from within 
# Singular, with the command 
# system( "Singular" );

# Singular command line options

# sing_exec_options a list of command-line options (given as strings)
# that will be passed to Singular at its startup. The option "-t" is
# necessary for proper working, but others can be added. See the
# documentation of Singular, paragraph "3.1.6 Command line options". 
# Similarly, it is possible to supply files to Singular containing user
# defined functions, as in the following example:
# sing_exec_options := [ "-t", "/full_path/my_file" ];

sing_exec_options := [ "-t" ];



# Temporary directory for i/o with Singular 

# You may set it like the following line if you prefer to have the
# temporary files in a specific directory. Examples:
# SingularTempDirectory := Directory( "/tmp" );
# SingularTempDirectory := DirectoryCurrent(  );
# If you don't specify it, the interface will set up a temporary one.

SingularTempDirectory := "";



##############################################################################

# No modification below this line is necessary.

##############################################################################
##############################################################################

## PART 1. Global variables, some of them mirroring Singular globals ##



# The following means that the variables sing_exec, sing_exec_options,
# and SingularTempDirectory need to be checked...
SingularExecutableAndTempDirAreOk := false;

# The Singular i/o process
Sing_Proc := fail; # not yet started

SingularNr := rec(  );
# How many times did Gap (re)start Singular (as InputOutputLocalProcess)?
SingularNr.Session := 0;
# How many times did Gap (re)start Singular (as Process)?
SingularNr.Process := 0;
# How many times did Gap send input to Singular (in this session)?
SingularNr.Input := 0;
# How many times has Gap received output from Singular (in this session)?
SingularNr.Output := 0;

# The limitations of Singular: see the documentation of Singular,
# paragraph "6.1 Limitations".

SingularLimitations := rec(
# the maximal characteristic of a prime field:
max_char_prime_field := 2147483629,
# the maximal size of a finite non prime field:
max_size_nonprime_field := 2^15,
# the maximal exponent of a ring variable:
max_exp_ring_var := 65536,
# the biggest integer (of type "int"):
max_int := 2147483647 );

## You can tell the interface which is the biggest number in Singular of 
## type "int" (it depends also on your hardware and on the version of 
## Singular). If you omit this, the interface will try to autodetermine.
## For safety, you can choose the smallest one.
#
#SingularLimitations.max_int := 2147483647; # on a 32-bit machine
## SingularLimitations.max_int := 9223372036854775807; # on a 64-bit 
## machine, with a new version of Singular
#
### try to autodetect
##if  not IsBound( OBJLEN ) and OBJLEN = 8  then # Gap 4.3
##if  not IsBound( GAPInfo.BytesPerVariable ) and GAPInfo.BytesPerVariable 
## = 8  then # Gap 4.4
##    SingularLimitations.max_int := 9223372036854775807;
##else 
##    SingularLimitations.max_int := 2147483647;
##fi;


# Singular version, an integer, as in the output of the Singular command
# system("version");
# The interface will ask Singular for it.
SingularVersion := 0; # not yet determined;

# The Libraries loaded in Singular
SingularLoadedLibraries := "";

SingularType := function (  ) end; # it will be defined later...
ParseGapRingToSingRing := function (  ) end; # it will be defined later...
ConvertGapObjToSingObj := function (  ) end; # it will be defined later...
SingularInterface := function (  ) end; # it will be defined later...
SingularSetBaseRing := function (  ) end; # it will be defined later...

# The Base Ring in Singular; the provided default should match the
# default of Singular.
SingularBaseRing := PolynomialRing( GF( 32003 ), 3 );

# The SingularBaseRing will be called GAP_ring in Singular;
# ideals will be called GAP_ideal_1, GAP_ideal_2, ... in Singular.
# If SingularNames.ideal = n, then the ideals GAP_ideal_1, ...,
# GAP_ideal_n have been sent to Singular or received from Singular.
#
# It will be checked, with the function
# HasCurrentRingSingularIdentifier, whether the ideal names refers to
# the current SingularBaseRing of Singular or two a previous ring.
# In the latter case, it will be necessary to send again the ideal.
#
# The same for modules.

SingularNames:= rec( ideal := 0, module := 0 );

SingularNamesThisRing := ShallowCopy( SingularNames );


# <--- For debug: see above, the beginning of the file.
fi; 


# This function checks whether the SingularIdentifier of an ideal or
# module refers to the current session of Singular or it is the old
# SingularIdentifier of a previous SingularBaseRing

HasCurrentRingSingularIdentifier := function ( obj )

    local  s, t;

    if not HasSingularIdentifier( obj )  then
        return false;
    fi;

    t := SingularType( obj );
    s := SingularIdentifier( obj );
    if t = "ideal"  and Int( s{[ 11 .. Length( s ) ]} ) > 
                        SingularNamesThisRing.ideal or
       t = "module" and Int( s{[ 12 .. Length( s ) ]} ) > 
                        SingularNamesThisRing.module  then
        return true;
    else
        return false;
    fi;

end;



# The following is the code for compatibility with older Gap versions


if not CompareVersionNumbers( VERSION, "4.4.5" )  then

  if not IsBound( PolynomialByExtRepNC  )  then
      PolynomialByExtRepNC := PolynomialByExtRep;
  fi;

  if not CompareVersionNumbers( VERSION, "4.4" ) then 

    if not IsBound( IsPolynomialRingIdeal )  then
        DeclareSynonym( "IsPolynomialRingIdeal",
         IsRing and IsRationalFunctionCollection and 
         HasLeftActingRingOfIdeal and HasRightActingRingOfIdeal );
    fi;

    if not IsBound( IsMonomialOrdering )  then
        IsMonomialOrdering := ReturnFalse;
        MonomialComparisonFunction := ReturnFail;
    fi;

    if not IsBound(LoadPackage) and IsBound(RequirePackage)  then
        LoadPackage := RequirePackage;
    fi;
    if not IsBound(ReadPackage) and IsBound(ReadPkg)  then
        ReadPackage := ReadPkg;
    fi;

    if not CompareVersionNumbers( VERSION, "4.3" )  then

        InstallOtherMethod( PositionSublist, "for an empty list", true,
         [ IsEmpty, IsList ], 0, ReturnFail );

        InstallOtherMethod( PositionSublist, "for an empty list", true,
         [ IsEmpty, IsList, IsInt ], 0, ReturnFail );

        if not IsBound( NormalizedWhitespace )  then
            NormalizedWhitespace := x -> ReplacedString( x, "\n", " ");
        fi;

        if not IsBound( EvalString )  then
            EvalString := function ( expr )
                  local  tmp;
                  tmp := Concatenation( "return ", expr, ";" );
                  return ReadAsFunction( InputTextString( tmp ) )(  );
              end;
        fi;

        JoinStringsWithSeparator := function ( arg )
              local  str, sep, res, i;
              str := List( arg[1], String );
              if Length( str ) = 0  then
                  return "";
              fi;
              if Length( arg ) > 1  then
                  sep := arg[2];
              else
                  sep := ",";
              fi;
              res := ShallowCopy( str[1] );
              for i  in [ 2 .. Length( str ) ]  do
                  Append( res, sep );
                  Append( res, str[i] );
              od;
              return res;
          end;

    fi;

  fi;

fi;

# It would be possible to add also something like this for backward
# compatibility:
#
# InstallMethod( \=, IsIdenticalObj, [ IsPolynomialRing,
#  IsPolynomialRing ], 0, 
# ...
# function ( V, W )
#    if
#     HasDimension( V ) and HasDimension( W ) and IsIdenticalObj( 
# LeftActingDomain( V ), LeftActingDomain( W ) )  then
#        if Dimension( V ) <> Dimension( W )  then
#            return false;
#        elif IsInt( Dimension( V ) )  then
#            return IsSubset( V, W );
#        fi;
#    fi;
#    return IsSubset( V, W ) and IsSubset( W, V );
# end;




##############################################################################
##############################################################################

## PART 2. Singular interface at low level ##




CheckSingularExecutableAndTempDir := function (  )
    local i, IsExec;

    # check the Singular executable file, and if needed try to
    # autodetermine, or print an appropriate error message

    IsExec := path -> IsString( path ) and IsDirectoryPath( path ) <>
        true and IsExecutableFile( path ) = true;

    # try to correct the string in case that only the directory or the
    # filename was supplied
    if IsBound( sing_exec ) and IsString( sing_exec ) then
         if IsDirectoryPath( sing_exec ) = true  then
            sing_exec := Filename( Directory( sing_exec ), "Singular" );
        elif not IsExecutableFile( sing_exec ) = true and
             not "/" in sing_exec  then
            sing_exec := Filename( DirectoriesSystemPrograms(  ), sing_exec );
        fi;
   fi;

    # try to detect the executable file
    if not IsBound( sing_exec ) or not IsExec( sing_exec )  then
        sing_exec := Filename( DirectoriesSystemPrograms(  ), "Singular" );
        if sing_exec <> fail then
            Info( InfoSingular, 2, "Found Singular executable file ",
                  sing_exec );
        fi;
    fi;

    # check the executable file, if failed print an error message
    while not IsBound( sing_exec ) or not IsExec( sing_exec ) do
        Print( "  Type 'sing_exec:=\"<path>\"; return;' where <path>\n" );
        Print( "  is the path of the Singular executable file on your \
system.\n" );
        if IsBound( sing_exec )  then
            if not IsString( sing_exec )  then
                Print( "  'sing_exec' must be a string.\n" );
            else
                Print( "'", sing_exec, "' is not an executable file.\n" );
            fi;
        fi;
        Error( "Singular executable file not found!\n" );
    od;


    # check the Singular command line options

    # sing_exec_options must be a dense list of strings
    if not (IsList( sing_exec_options ) and IsDenseList( sing_exec_options ) )
         then
        Error( "sing_exec_options must be a (dense) list\n" );
    fi;
    if not ForAll( sing_exec_options, IsString )  then
        Error( "all the components of sing_exec_options must be strings\n" );
    fi;

    # some options are necessary
    for i  in [ "-t" ]  do
        if not i in sing_exec_options  then
            Error( "Singular command line option ", i, " is necessary\n" );
        fi;
    od;

    # some options are not supported
    for i  in [ "-h", "--help", "-e", "--echo" ]  do
        if i in sing_exec_options  then
            Error( "Singular command line option ", i, " is not allowed\n" );
        fi;
    od;


    # check the temporary directory that will be used for i/o with Singular

    if IsBound( SingularTempDirectory ) and IsString( SingularTempDirectory )
       and Length( SingularTempDirectory ) > 0
        then SingularTempDirectory := Directory( SingularTempDirectory );
    fi;

    if not IsBound( SingularTempDirectory![1] ) or 
       not IsDirectoryPath( SingularTempDirectory![1] ) = true or 
#       not IsReadableFile( SingularTempDirectory![1] ) = true or 
       not IsWritableFile( SingularTempDirectory![1] ) = true or 
       not IsExecutableFile( SingularTempDirectory![1] ) = true  then
        SingularTempDirectory := DirectoryTemporary( "Sing" );

        if SingularTempDirectory = fail  then
            Error( "cannot create a temporary directory\n" );
        fi;

        Info( InfoSingular, 2, "Using temporary ", SingularTempDirectory );

    fi;

    SingularExecutableAndTempDirAreOk := true;

end;



# A function for closing (killing) Singular

CloseSingular := function (  )
    if IsStream( Sing_Proc )  then
        if not IsClosedStream( Sing_Proc )  then
            # WriteLine( Sing_Proc, ";quit;" );
            CloseStream( Sing_Proc );
        else
            Info( InfoSingular, 2, "Singular already closed." );
        fi;
    fi;
    # after closing Singular, the names become out of date.
    SingularNamesThisRing := ShallowCopy( SingularNames );
end;


# Kill Singular when Gap terminates
InstallAtExit( CloseSingular );



# The low level function for i/o with Singular. This function splits the
# string with the Singular input into several lines, sends each of them
# to Singular, waiting for the Singular prompt "> " or ". " at end of
# output, relative to that line, before sending the next line. 
# This is necessary because some versions of Singular ignore the input
# that is received before giving the prompt.
# After that, this function calls "GAP_Done ();" (to have a '@' in the 
# output, to be sure that Singular finished), waits to receive the 
# prompt "@\n> ", and then returns all the output of Singular.
# (The char before "> ", ". " or "@\n> " depends on the operating
# system, and on the sing_exec_options "-t".)

SingWriteAndReadUntilDone := function ( string )

    local read_blocking, read_non_blocking, read, out, OUT, s, i;

    read_blocking := ReadAll;

    read_non_blocking := function ( stream )
        local  sl, outl;
        outl := "";
        repeat
            sl := READ_IOSTREAM_NOWAIT( stream![1], 1 );
            if sl <> fail  then
                Append( outl, sl );
            fi;
        until sl = fail;
        return outl;
    end;

    # choose exactly one of the following lines:

    # read := read_non_blocking;
    read := read_blocking;

    # read_blocking: Gap blocks while Singular is running, resulting in
    # a faster execution; Gap cannot be interrupted by <ctrl>-C in case
    # of interface error. Suggested for normal use.
    
    # read_non_blocking: Gap keeps running while Singular is running,
    # resulting in a slower execution; Gap can be interrupted by
    # <ctrl>-C in case of interface error. Suggested for debugging.
    # Requires Gap version at least 4.3.

    if '$' in string  then
        # a '$' would close Singular...
        Print( "Discarding the '$' in the Singular input\n" );
        string := ReplacedString( string, "$", "");
    fi;

    string := SplitString( string, '\n' );
    out := "";
    OUT := "";

    for i  in [ 1 .. Length( string ) ]  do
        if Length( string[i] ) > 4000  then    # max ~4050
            Error( "the command line for Singular is too long, ",
                   "please report\n" );
        fi;

        WriteLine( Sing_Proc, string[i] );

        SingularNr.Input := SingularNr.Input + 1;
        Info( InfoSingular, 3, "input ", SingularNr.Input, ": ", string[i] );

        repeat
            s := read( Sing_Proc );
            Append( out, s );
        until PositionSublist( out, "> ", Length( out ) - 2 ) <> fail
          or PositionSublist( out, ". ", Length( out ) - 2 ) <> fail;

        SingularNr.Output := SingularNr.Output + 1;
        Info( InfoSingular, 3, "output ", SingularNr.Output, ": ", out );

        Append( OUT, out );
        out := "";
    od;

    WriteLine( Sing_Proc, ";GAP_Done ();" );

    SingularNr.Input := SingularNr.Input + 1;
    Info( InfoSingular, 3, "input ", SingularNr.Input, ": ", 
          ";GAP_Done ();" );


    repeat
        s := read( Sing_Proc );
        Append( out, s );

    until PositionSublist( out, "@\n> ", Length( out ) - 4 ) <> fail;

#   with a very old version of Singular replace the previous line with
#   the following ones

#    until PositionSublist( out, "@\n" ) <> fail and
#          PositionSublist( out, "> ", Length( out ) - 2 ) <> fail;

    Append( OUT, out ); # is this needed?

#        # attempt to trap the Singular errors
#        pos := PositionSublist( OUT, "? error occurred in STDIN line " );
#        if pos <> fail  then
#             Error( "Singular error" );
#        fi;

    SingularNr.Output := SingularNr.Output + 1;
    Info( InfoSingular, 3, "output ", SingularNr.Output, ": ", out );

    return OUT;
end;




StartSingular := function (  )

    local  file_in, out, s;


    # is there a previous Singular running?

    if IsStream( Sing_Proc ) and not IsClosedStream( Sing_Proc )  then
        CloseSingular(  );
    fi;


    CheckSingularExecutableAndTempDir(  );


    # We also provide Singular with a function for producing a '@'; this
    # enables us to let Singular write a '@' without putting one in the
    # input; the latter strategy proved to be confusing with some
    # operating system, without the sing_exec_options "-t".
    # (Another possibility would be to send to Singular
    # LIB("general.lib"); proc GAP_Done () { return ( ASCII(64) ) }; .)

    # perhaps could be better using a file in DirectoriesPackageLibrary

    file_in := Filename( SingularTempDirectory, "sing.in" );

    PrintTo( file_in, "proc GAP_Done () { return ( \"@\" ) };\n",
                      "proc GAP_Apostrophe () { return ( \"'\" ) };\n", 
                      "GAP_Done();\n" );


    # this starts Singular, attaches it to the i/o process `Sing_Proc', and
    # reads <file_in> with the commands given above

    Sing_Proc := InputOutputLocalProcess( SingularTempDirectory, 
       sing_exec, Concatenation( sing_exec_options, [ file_in ] ) );


    SingularNr.Session := SingularNr.Session + 1;

    SingularNr.Input := 0;
    SingularNr.Output := 0;


    # We get the Singular banner and discard any output.
    out := ReadAll( Sing_Proc );
    if out = fail  then
        Error( "Singular didn't start!\n",
               "Is correct the value of sing_exec ( ", sing_exec, " )?\n",
               "Does Singular work, when called as a standalone program?\n");
    fi;

    while PositionSublist( out, "@\n> ", Length( out ) - 4 ) = fail do

#   with a very old version of Singular replace the previous line with
#   the following ones

#    while PositionSublist( out, "@\n" ) <> fail and 
#          PositionSublist( out, "> ", Length( out ) - 2 ) = fail do
        s := ReadAll( Sing_Proc );
        Append( out, s );
    od;

#    SingularNr.Output:= SingularNr.Output + 1;
    Info(InfoSingular, 3, "output ", SingularNr.Output, ":\n", out);

    # Now we check that Singular is working, and test the interface
    out := SingWriteAndReadUntilDone( "" );


    # ask Singular, to determine its version
    out := SingWriteAndReadUntilDone( "system(\"version\");" );
    SingularVersion := Int( Filtered( out, IsDigitChar ) );
    # SingularVersion := SingularInterface( "system", [ "version" ], "int" );

    Info( InfoSingular, 2, "Started Singular, version ", SingularVersion );

    # set the base ring in Singular according to the SingularBaseRing in Gap.
    SingularSetBaseRing( SingularBaseRing );


end;






##############################################################################
##############################################################################

## PART 3. Singular interface at medium level ##



# this function writes a Gap string to a file (that will be read by
# Singular) without the '\' at the end of the lines: the '\' confuses
# Singular

AppendStringToFile := function ( file, s )
    local  otf;
    otf := OutputTextFile( file, true );
    SetPrintFormattingStatus( otf, false );
    AppendTo( otf, s );
    CloseStream( otf );
end;


# This function could replace use of NormalizedWhitespace, or could be
# put inside ReadStringFromFile .
RemovedNewline := function ( string )
    if Length( string ) > 0 and string[Length( string )] = '\n'  then
        Unbind( string[Length( string )] );
    fi;
    return ReplacedString( string, "\n", " " );
end;


# This function reads a file (written by Singular), and returns it as a
# string to Gap, without the "\n", that confuse Gap.
ReadStringFromFile := function ( file )
    local  itf, r;
    itf := InputTextFile( file );
    r := ReadAll( itf );
    CloseStream( itf );
    return RemovedNewline( r );
end;



WithoutEndingSemicolon := function ( string )
    local  i;
    i := Length( string );
    while i > 0  do
        if string[i] = ' '  then
            i := i - 1;
        elif string[i] = ';'  then
            string[i] := ' ';
        else
            break;
        fi;
    od;
    return string;
end;



# This function is under construction... maybe it is not needed.
EscapeCharsInString := function ( string )
    string := ReplacedString( string, "\\", "\\\\" );
    string := ReplacedString( string, "\n", "\\\n" );
    string := ReplacedString( string, "\"", "\\\"" );
    string := ReplacedString( string, "'", "\\'" );
    string := ReplacedString( string, "\b", "\\\b" );
    string := ReplacedString( string, "\r", "\\\r" );
    string := ReplacedString( string, "\c", "\\\c" );
    return string;
end;



# In the following functions, 'precommand' is used, for instance, to
# send the SingularBaseRing, then only the output of 'command' will be
# returned. 'command' must be a single command, but 'precommand' may be
# a semicolon-separated list of commands

# "Stream" and "File", in the name of the following functions, refers
# only to the way of sending the mathematical data, all these functions
# use the stream for low-level communications.

SingCommandInStreamOutStream := function ( precommand, command )

    local  singcom, out, pos1, pos2;

    if not IsStream( Sing_Proc ) or IsClosedStream( Sing_Proc )  then
        StartSingular(  );
    fi;

    # test the input
    if '@' in precommand or '@' in command  then
        Error( "please do not use '@' in the commands \n" );
    fi;
    if ''' in precommand or ''' in command  then
        Error( "please do not use ''' in the commands \n" );
    fi;

    # prepare the input to Singular, asking for an output between two '''
    singcom := Concatenation( precommand, ";\nGAP_Apostrophe();",
                              command, ";GAP_Apostrophe();" );

    # send it, and get the output of Singular
    out := SingWriteAndReadUntilDone( singcom );

    pos1 := PositionSublist( out, "'\n" );
    if pos1 = fail  then
        Error( "output of Singular only partially retrieved\n" );
    fi;

    pos2 := PositionSublist( out, "\n'\n", pos1 );
    if pos2 = fail  then
        Error( "output of Singular only partially retrieved\n" );
    fi;

    # return the output, without the ''' and the "\n", 
    return out{[ pos1 + 2 .. pos2 - 1 ]};

end;



SingCommandInFileOutStream := function ( precommand, command )

    local file_in, out, pos1, pos2;

    if not IsStream( Sing_Proc ) or IsClosedStream( Sing_Proc )  then
        StartSingular();
    fi;

    # test the input
    if '@' in precommand or '@' in command  then
        Error( "please do not use '@' in the commands \n" );
    fi;
    if ''' in precommand or ''' in command  then
        Error( "please do not use ''' in the commands \n" );
    fi;

    # the input file
    file_in:= Filename( SingularTempDirectory, "sing.in" );

    # to be safe
    RemoveFile( file_in );

    # write the input for Singular in 'file_in'
    AppendStringToFile( file_in, Concatenation( precommand,
           ";\nGAP_Apostrophe();", command, ";GAP_Apostrophe();" ) );

    # tell Singular to read and execute 'file_in', and get the output
    out := SingWriteAndReadUntilDone( "< \"sing.in\";" );

    pos1 := PositionSublist( out, "'\n" );
    if pos1 = fail  then
        Error( "output of Singular only partially retrieved\n" );
    fi;

    pos2 := PositionSublist( out, "\n'\n", pos1 );
    if pos2 = fail  then
        Error( "output of Singular only partially retrieved\n" );
    fi;

    # the output, without the ''' and the "\n"
    out := out{[ pos1 + 2 .. pos2 - 1 ]};

    if InfoLevel( InfoSingular ) < 3 then
        RemoveFile( file_in );
    fi;

    return out;
end;



SingCommandInFileOutFile := function ( precommand, command )

    local file_in, file_out, string_in, out;


    if not IsStream( Sing_Proc ) or IsClosedStream( Sing_Proc )  then
        StartSingular();
    fi;

    # test the input
    if '@' in precommand or '@' in command  then
        Error( "please do not use '@' in the commands \n" );
    fi;

    # the input and output files
    file_in:= Filename( SingularTempDirectory, "sing.in" );
    file_out:= Filename( SingularTempDirectory, "sing.out" );

    # to be safe
    RemoveFile( file_in );
    RemoveFile( file_out );

    # write the input for Singular in 'file_in'
    string_in := precommand;
    Append( string_in, ";\n" );

    if command <> ""  then
        Append( string_in, "write( \"sing.out\", " );
        Append( string_in, WithoutEndingSemicolon( command ) );
        Append( string_in, " );\n" );
    fi;

    AppendStringToFile( file_in, string_in );

    # tell Singular to read and execute 'file_in', and get the output
    out := SingWriteAndReadUntilDone( "< \"sing.in\";" );

    if command <> ""  then
        if not IsExistingFile( file_out ) then
            Error( "Singular didn't write the output to the file\n" );
        fi;

        out := ReadStringFromFile( file_out );
    fi;

    if InfoLevel( InfoSingular ) < 3 then
        RemoveFile( file_in );
        RemoveFile( file_out );
    fi;

    if command <> ""  then
        return out;
    else
        return "";
    fi;

end;



SingCommandInStreamOutFile := function ( precommand, command )

    local file_out, out, singcom;

    if not IsStream( Sing_Proc ) or IsClosedStream( Sing_Proc )  then
        StartSingular();
    fi;

    # test the input
    if '@' in precommand or '@' in command  then
        Error( "please do not use '@' in the commands \n" );
    fi;

    # the output file
    file_out:= Filename( SingularTempDirectory, "sing.out" );

    # to be safe
    RemoveFile( file_out );

    # send the input to Singular, asking to write it in file_out

    out := SingWriteAndReadUntilDone( precommand );

    if command <> ""  then

        singcom := "write( \"sing.out\", ";
        Append( singcom, WithoutEndingSemicolon( command ) );
        Append( singcom, " );\n" );

        out := SingWriteAndReadUntilDone( singcom );

        if not IsExistingFile( file_out ) then
            Error( "Singular didn't write the output to the file\n" );
        fi;

        out := ReadStringFromFile( file_out );


        if InfoLevel( InfoSingular ) < 3 then
            RemoveFile( file_out );
        fi;

        return out;

    else
        return "";
    fi;

end;



# The following function doesn't use InputOutputLocalProcess,
# so it can be used under Windows with Gap version < 4.4.2

SingCommandUsingProcess := function ( precommand, command )

    local  _in, out, _out, opt, file_in, file_out;


    if not SingularExecutableAndTempDirAreOk  then
        CheckSingularExecutableAndTempDir(  );
    fi;

    # the input and output files
    file_in:= Filename( SingularTempDirectory, "sing.in" );
    file_out:= Filename( SingularTempDirectory, "sing.out" );

    # to be safe
    RemoveFile( file_in );
    RemoveFile( file_out );

    # write the input for Singular in 'file_in'
    AppendStringToFile( file_in, SingularLoadedLibraries );
    AppendStringToFile( file_in, ParseGapRingToSingRing( SingularBaseRing ) );
    AppendStringToFile( file_in, precommand );
    AppendStringToFile( file_in, ";\n" );

    if command <> ""  then
        AppendStringToFile( file_in, "write( \"sing.out\", " );
        AppendStringToFile( file_in, WithoutEndingSemicolon( command ) );
        AppendStringToFile( file_in, " );\n" );
    fi;


    _in := InputTextNone(  );
    _out := OutputTextNone(  );
    opt := Concatenation( "--execute=", "< \"sing.in\";", ";quit;" );

    Process( SingularTempDirectory, sing_exec, _in, _out, 
             Concatenation( sing_exec_options, [ opt ] ) );

    CloseStream( _in );
    CloseStream( _out );

    if command <> ""  then
        if not IsExistingFile( file_out ) then
            Error( "Singular didn't write the output to the file\n" );
        fi;

        out := ReadStringFromFile( file_out );

    fi;

    if InfoLevel( InfoSingular ) < 3 then
        RemoveFile( file_in );
        RemoveFile( file_out );
    fi;

    SingularNr.Process := SingularNr.Process + 1;

    if command <> ""  then

        if not CompareVersionNumbers( VERSION, "4.2" ) and 
        # the output of "Process" contains an extra space at the end
           Length( out ) > 0 and out{[ Length( out ) ]} = " "  then
            out := out{[ 1 .. Length( out ) - 1 ]};
        fi;

        return out;
    else
        return "";
    fi;

end;


if ARCH_IS_UNIX(  ) and CompareVersionNumbers( VERSION, "4.2" ) or
   CompareVersionNumbers( VERSION, "4.4.2" )
 then

    # "InputOutputLocalProcess" is available

    # writing to a i/o stream is slow in windows (but fast in unix)
    if ARCH_IS_WINDOWS(  ) then 
        # choose one
        #SingularCommand := SingCommandInStreamOutStream; # slow with windows
        SingularCommand := SingCommandInFileOutStream;
        #SingularCommand := SingCommandInFileOutFile;
        #SingularCommand := SingCommandInStreamOutFile; # slow with windows
        #SingularCommand := SingCommandUsingProcess; # not recommended!
    else
        # choose one
        SingularCommand := SingCommandInStreamOutStream; # slow with windows
        #SingularCommand := SingCommandInFileOutStream;
        #SingularCommand := SingCommandInFileOutFile;
        #SingularCommand := SingCommandInStreamOutFile; # slow with windows
        #SingularCommand := SingCommandUsingProcess; # not recommended!
    fi;

else

    # "InputOutputLocalProcess" doesn't work yet, "Process" will be used
    SingularCommand := SingCommandUsingProcess;

fi;


if SingularCommand = SingCommandUsingProcess  then
    SingCommandInStreamOutStream := ReturnFail;
    HasCurrentRingSingularIdentifier := ReturnFalse;
#    SingularVersion := Int( SingularCommand( "", "system(\"version\");" ) );
fi;



##############################################################################
##############################################################################

## PART 4. Parsing Gap --> Singular ##

# Some functions to convert Gap objects into strings that represent
# Singular objects.


# This function tells whether a Gap object corresponds to a Singular
# object of type "int"

IsSingularInt := function ( n )
    if IsInt( n )  then
        return - SingularLimitations.max_int <= n and
               n <= SingularLimitations.max_int;
    else
        return false;
    fi;
end;


# This function tells whether a Gap object corresponds to a Singular
# object of type "poly"

IsSingularPoly := p -> IsRationalFunction( p ) and IsPolynomial( p ) 
        and p in SingularBaseRing;



##############################################################################


ParseGapNumberToSingNumber := function ( n )

    local  eroo, str, i;

    if not n in CoefficientsRing( SingularBaseRing )  then
        Error( "the number ", n,
           " is not in the CoefficientsRing of the Singular Base Ring ",
               CoefficientsRing( SingularBaseRing ), "\n" );
    fi;


    if IsPrimeField( CoefficientsRing( SingularBaseRing ) ) or
       IsFFE( n ) and IsZero( n )  then # or DegreeFFE( n ) = 1

        if Characteristic( SingularBaseRing ) = 0  then
            return String( n );
        else
            # without the "number( ", Singular would interpret the
            # finite field element as an integer
            return Concatenation( "number( ", String( IntFFE( n ) ), " )" );
        fi;

    else

        if Characteristic( SingularBaseRing ) = 0 or
           IsAlgebraicExtension( CoefficientsRing( SingularBaseRing ) )  then

            if IsRat( n )  then
                return String( n );
            fi;

            if IsCyc( n ) then
                eroo := CoeffsCyc( n , Conductor( CoefficientsRing( 
                    SingularBaseRing ) ) );
            else
                eroo := ExtRepOfObj( n );
            fi;

            str := "( ";
            for i  in [ 1 .. Length( eroo ) ]  do
                if Characteristic( SingularBaseRing ) = 0  then
                    Append( str, String( eroo[i] ) );
                else
                    Append( str, String( IntFFE( eroo[i] ) ) );
                fi;
                Append( str, "*q^" );
                Append( str, String( i - 1 ) );
                if i < Length( eroo )  then
                    Append( str, "+" );
                fi;
            od;
            Append( str, " )" );
            return str;

        else

            return Concatenation( "q^", String( LogFFE( n,
        PrimitiveRoot( CoefficientsRing( SingularBaseRing ) ) ) ) );

        fi;

    fi;

end;



ParseGapPolyToSingPoly:= function ( pol )

    # pol is a GAP polynomial, we parse it into a string representing
    # a Singular polynomial.

    local   varnums,  str,  mons,  k,  mon,  m,  len;

    if not pol in SingularBaseRing  then
        Error( "the polynomial ", pol, " is not in the Singular Base Ring ",
               SingularBaseRing, "\n" );
    fi;

    if IsZero( pol )  then
        return "poly(0)";
    fi;

    varnums:= IndeterminateNumbers( SingularBaseRing );
    # without the "poly(", Singular would interpret a degree 0
    # polynomial as a number
    str:= "poly(";
    mons:= ExtRepPolynomialRatFun( pol );
    k:= 1;

    len:= 0;

    while k <= Length( mons ) do

        # after 1000 chars we append a "\n", to avoid too long lines
        if Length( str )-len >= 1000 then
            Append( str, "\n" );
            len:= Length( str );
        fi;

        if k > 1 then Add( str, '+' ); fi;

        Append( str, ParseGapNumberToSingNumber( mons[k+1] ) );

        mon:= mons[k];
        m:= 1;
        while m <= Length( mon ) do
            Append( str, "*x_" );
            Append( str, String( Position( varnums, mon[m] ) ) );
            Append( str, "^" );
            if mon[m + 1] >= SingularLimitations.max_exp_ring_var  then
                Error( "Singular supports only exponents of a ring ",
                       "variables smaller than ",
                       SingularLimitations.max_exp_ring_var, "\n" );
            fi;
            Append( str, String( mon[m+1] ) );
            m:=m+2;
        od;
        k:= k+2;
    od;

    Append( str, ")" );
    return str;
end;



ParseGapIdealToSingIdeal := function ( I )

    local  str, pols, k;

    if LeftActingRingOfIdeal( I ) <> SingularBaseRing  then
        SingularSetBaseRing( LeftActingRingOfIdeal( I ) );
    fi;

    str := "ideal(\n";

    pols := GeneratorsOfTwoSidedIdeal( I );
    for k  in [ 1 .. Length( pols ) ]  do
        Append( str, ParseGapPolyToSingPoly( pols[k] ) );
        if k < Length( pols )  then
            Append( str, ",\n" );
        else
            Append( str, ")\n" );
        fi;
    od;

    return str;
end;



ParseGapIntmatToSingIntmat := function ( mat )
    local  str, dim, i, j;
    dim := DimensionsMat( mat );
    str := "intmat (intvec(";
    for i  in [ 1 .. dim[1] ]  do
        Append( str, "\n" );
        for j  in [ 1 .. dim[2] ]  do
            Append( str, String( mat[i][j] ) );
            if not (i = dim[1] and j = dim[2])  then
                Append( str, "," );
            fi;
            if j mod 50 = 0  then
                Append( str, "\n" );
            fi;
        od;
    od;
    Append( str, ")," );
    Append( str, String( dim[1] ) );
    Append( str, "," );
    Append( str, String( dim[2] ) );
    Append( str, ")" );
    return str;
end;



ParseGapIntvecToSingIntvec := function ( vec )
    local  str, dim, i;
    dim := Length( vec );
    str := "intvec(";
    for i  in [ 1 .. dim ]  do
        Append( str, String( vec[i] ) );
        if not i = dim  then
            Append( str, "," );
        fi;
        if i mod 50 = 0  then
            Append( str, "\n" );
        fi;
    od;
    Append( str, ")" );
    return str;
end;




ParseGapModuleToSingModule := function ( M )

    local  str, l_pols, k, k2;

    if LeftActingDomain( M ) <> SingularBaseRing  then
        SingularSetBaseRing( LeftActingDomain( M ) );
    fi;

    str:= "module(\n";

    l_pols := GeneratorsOfLeftOperatorAdditiveGroup( M );
    for k  in [ 1 .. Length( l_pols ) ]  do
        Append( str, "[ " );
        for k2  in [ 1 .. Length( l_pols[k] ) ]  do
            Append( str, ParseGapPolyToSingPoly( l_pols[k][k2] ) );
            if k2 < Length( l_pols[k] )  then
                Append( str, "," );
            fi;
        od;
        if k < Length( l_pols )  then
            Append( str, "],\n" );
        else
            Append( str, "])\n" );
        fi;
    od;

    return str;
end;




ParseGapOrderingToSingOrdering := function( tor )

    # A TermOrdering of a ring R is either a string ( "lp", "dp", "Dp" ),
    # meaning that the corresponding term ordering in Singular is
    # chosen,
    # or a list of the form (e.g.) [ "dp", 3, "lp", 2 ], meaning
    # that the first three indeterminates are ordered by dp, the
    # remaining two by lp.
    # If a weighted ordering is specified ( "wp", "Wp", "ws", "Ws" ),
    # then the next element in the list is not an integer, but the
    # weight vector.
    # A TermOrdering may also be a Gap MonomialOrdering.

    local  to, i, j, name;

    if IsString( tor )  then
        return tor;

    elif IsList( tor )  then
        to := "(";
        for i  in [ 1, 3 .. Length( tor ) - 1 ]  do
            if i <> 1  then
                Append( to, ", " );
            fi;
            Append( to, tor[i] );
            Append( to, "(" );
            if not tor[i] in [ "wp", "Wp", "ws", "Ws" ]  then
                Append( to, String( tor[i + 1] ) );
            else
                for j  in [ 1 .. Length( tor[i + 1] ) ]  do
                    if j <> 1  then
                        Append( to, "," );
                    fi;
                    Append( to, String( tor[i + 1][j] ) );
                od;
            fi;
            Append( to, ")" );
        od;
        Append( to, ")" );


    elif IsMonomialOrdering( tor )  then
        name := Name( tor );
        name := name{[ 1 .. Position( name, '(' ) - 1 ]};
        if name = "MonomialLexOrdering"  then
            to := "lp";
        elif name = "MonomialGrevlexOrdering"  then
            to := "dp";
        elif name = "MonomialGrlexOrdering"  then
            to := "Dp";
        else
            Error( "the ordering ", tor, " is not yet supported\n" );
        fi;

    else
        Error( "the term ordering ", tor,
               ",\nof the Singular base-ring, is not valid\n" );
    fi;

    return to;
end;




ParseGapRingToSingRing := function ( R )

    local F, str, ipr, mcf, varnums, f, ef, i;

    F:= CoefficientsRing( R );


# Check that the field is supported by Singular

    if Characteristic( F ) > 0  then
        if IsPrimeField( F )  then

            if SingularVersion <= 2003  then
                if Characteristic( F ) > 32003 and Characteristic( F ) <=
                  SingularLimitations.max_char_prime_field  then
                    Error( "only prime fields of char <= 32003 are ",
                     "supported by your version of \nSingular: upgrade it ",
                     "to use prime fields of char <= ",
                     SingularLimitations.max_char_prime_field, ". \n" );
                elif Characteristic( F ) >
                  SingularLimitations.max_char_prime_field  then
                    Error( "only prime fields of char <= 32003 are ",
                     "supported by your version of \nSingular (or prime ",
                     "fields of char <= ",
                     SingularLimitations.max_char_prime_field,
                     " by the latest version.)\n" );
                fi;
            else
                if Characteristic( F ) >
                  SingularLimitations.max_char_prime_field  then
                    Error( "only prime fields of char <= ",
                     SingularLimitations.max_char_prime_field,
                     " are supported by Singular \n" );
                fi;
            fi;

        else

            if Size( F ) > SingularLimitations.max_size_nonprime_field  then
                Error( "Singular supports finite but non-prime fields ",
                 "only if \nof size <= ",
                 SingularLimitations.max_size_nonprime_field, "\n" );
            fi;

        fi;
    else

        if not (HasIsCyclotomicField( F ) and IsCyclotomicField( F ) or
    IsAlgebraicExtension( F ) and LeftActingDomain( F ) = Rationals)  then

           Error( "in Characteristic 0, only CyclotomicField's (including ",
             "Rationals) and\nAlgebraicExtension's of Rationals are ",
             "supported by the Singular interface \nand by Singular\n" );

        fi;

    fi;


# In Singular, a ring declaration is of the form
# ring name = (coefficient_field), (names_of_ring_variables), (ordering);
# possibly followed by a
# minpoly = (poly);


    str := "ring GAP_ring = ( ";


# Calculating "coefficient_field"

    Append( str, String( Characteristic( F ) ) );
    if not IsPrimeField( F )  then
        Append( str, ", q" );
    fi;


# Calculating "), (names_of_ring_variables), "

    ipr := ShallowCopy( IndeterminatesOfPolynomialRing( R ) );

    if HasTermOrdering( R ) and IsMonomialOrdering( TermOrdering( R ) )  then
        mcf := MonomialComparisonFunction( TermOrdering( R ) );
        Sort( ipr, mcf );
        ipr := Reversed( ipr );
    fi;

    varnums := List( ipr, x -> ExtRepPolynomialRatFun( x )[1][1] );
    SetIndeterminateNumbers( R, varnums );

    Append( str, " ), (" );

    for i in [1..Length(varnums)] do
        Append( str, "x_" );
        Append( str, String( i ) );
        if i<>Length(varnums) then Append( str, "," ); fi;
    od;

    Append( str, "), " );


# Calculating "(ordering);"

    if HasTermOrdering( R ) then
        Append( str, ParseGapOrderingToSingOrdering( TermOrdering( R ) ) );
    else
        # the default "dp" is used
        Append( str, "dp" );
    fi;

    Append( str, ";" );


# Calculating " minpoly = (poly);" if not IsPrimeField( F )

    if not IsPrimeField( F )  then

        # Compute a string representing the minimum polynomial of a
        # primitive element of F.

        if HasDefiningPolynomial( F ) and
           IsPrimeField( LeftActingDomain( F ) )  then
            f:= DefiningPolynomial( F );
        elif Characteristic( F ) > 0  then
            f:= MinimalPolynomial( PrimeField(F), PrimitiveRoot(F), 1 );
        elif HasIsCyclotomicField( F ) and IsCyclotomicField( F )  then
            f:= MinimalPolynomial( PrimeField(F), PrimitiveElement(F), 1 );
        fi;
        ef:= ExtRepPolynomialRatFun( f );

        Append( str, " minpoly = " );
        for i in [1,3..Length(ef)-1] do
            if i<>1 then Append( str, "+" ); fi;
            if Characteristic( F ) = 0  then
                Append( str, String( ef[i+1] ) );
            else
                Append( str, String( IntFFE( ef[i+1] ) ) );
            fi;
            if ef[i] <> [] then
                Append( str, "*q^" );
                Append( str, String( ef[i][2] ) );
            fi;
        od;
        Append( str, ";" );
    fi;


# Done

    Append( str, "\n" );
    return str;

end;




ParseGapVectorToSingVector := function ( vec )
    local  str, dim, i;
    dim := Length( vec );
    str := "[";
    for i  in [ 1 .. dim ]  do
        Append( str, ParseGapPolyToSingPoly( vec[i] ) );
        if not i = dim  then
            Append( str, "," );
        fi;
        if i mod 50 = 0  then
            Append( str, "\n" );
        fi;
    od;
    Append( str, "]" );
    return str;
end;


ParseGapListToSingList := function ( list )
    local  str, dim, i;
    dim := Length( list );
    str := "list( ";
    for i  in [ 1 .. dim ]  do
        Append( str, ConvertGapObjToSingObj( list[i] ) );
        if i < dim  then
            Append( str, ", " );
        fi;
        if i mod 50 = 0  then
            Append( str, "\n" );
        fi;
    od;
    Append( str, " )" );
    return str;
end;



##############################################################################

## PART 5. Parsing Singular --> Gap ##

# Some functions to convert strings that represent Singular
# objects into Gap objects




ParseSingNumberToGapNumber:= function ( str )

    local   F,  len,  k,  coef,  cf,  exp,  res;

    F := CoefficientsRing( SingularBaseRing );

    if IsPrimeField( F )  then
        return Rat( str ) * One( F );
    fi;

    # get rid of the ()
    if str[1] = '(' and str[Length( str )] = ')'  then
        RemoveElmList( str, 1 );
        RemoveElmList( str, Length( str ) );
    fi;


    # We note that (at least for now) the primitive elements in Singular
    # are always called `q'. That is, for non-prime fields...

    # Here `str' is a string representing a field element of a non-prime
    # field in Singular. This is just a polynomial in `q' over the
    # Rationals. So this function more or less copies the parse function
    # for polynomials, only each time for `q' substituting the primitive
    # root of the ground field.

    res:= Zero( F );

    len:= Length( str );
    k:= 1;

    while k <= len do
        

        # we parse the coefficient of the monomial, and we first discard
        # a possible '+' sign of that coefficient.
    
        coef:="";
        if str[k]='+' then 
            k:=k+1;
        fi;

        # now we get the coefficient itself

        while k <= len and str[k] <> 'q' do
            if str[k] <> '*' then
                Add( coef, str[k] );
            fi;
            k:=k+1;
        od;

        # if the coefficient is 1, then nothing has been done in the
        # previous loop...

        if coef = ""  then
            coef := "1";
        elif coef = "-"  then
            coef := "-1";
        fi;


        cf:= Rat( coef );


        # note that if the monomial only consists of a coefficient
        # (i.e., constant monomial), then we will not enter the next
        # loop, and a [] will be added to mons, just as it should.

        exp:= 0;
        if k <= len and str[k] = 'q' then

            k:= k+1;

            # Now we get the exponent:

            if k <= len and str[k] = '^' then
                exp:= "";
                k:= k+1;
                while k <= len and str[k] in CHARS_DIGITS do
                    Add( exp, str[k] );
                    k:= k+1;
                od;
                exp:= Int( exp );
            else
                exp:= 1;
            fi;
        fi;

        if HasDefiningPolynomial( F ) and
           IsPrimeField( LeftActingDomain( F ) )  then
            res:= res + cf*RootOfDefiningPolynomial( F )^exp;
        elif Characteristic( F ) > 0 then
            res:= res + cf*PrimitiveRoot( F )^exp;
        elif HasIsCyclotomicField( F ) and IsCyclotomicField( F )  then
            res:= res + cf*PrimitiveElement( F )^exp;
        fi;

    od;

    return res;
end;



ParseSingPolyToGapPoly:= function ( str )
    
    # Here `str' is a string representing a polynomial in Singular
    # format, and we parse it into a GAP polynomial. So a substring of
    # the form `x_21' in `str' means the 21st element from
    # `IndeterminateNumbers( SingularBaseRing )'. 

    local   len,  mons,  cfs,  k,  mon,  coef,  ind,  exp,  
            erep, fam;

    if str = "0"  then
        # we want '[  ]' as ExtRepPolynomialRatFun,
        # not '[ [  ], Zero( CoefficientsRing( SingularBaseRing ) ) ]',
        # as the algorithm would return.
        return Zero( SingularBaseRing );
    fi;

    mons:= [ ];
    cfs:= [ ];

    len:= Length( str );
    k:= 1;
    
    while k <= len do
        
        mon:= [ ];

        # we parse the coefficient of the monomial, and we first discard
        # a possible '+' sign of that coefficient.

        coef:="";
        if str[k]='+' then
            k:=k+1;
        fi;

        # now we get the coefficient itself

        while k <= len and str[k] <> 'x' do
            if str[k] <> '*' or str[k+1] <> 'x' then 
                Add( coef, str[k] );
            fi;  
            k:=k+1;
        od;

        # if the coefficient is 1, then nothing has been done in the
        # previous loop...

        if coef = ""  then
            coef := "1";
        elif coef = "-"  then
            coef := "-1";
        fi;


        Add( cfs, ParseSingNumberToGapNumber( coef ) );


        # note that if the monomial only consists of a coefficient
        # (i.e., constant monomial), then we will not enter the next
        # loop, and a [] will be added to mons, just as it should.

        while k <= len and not str[k] in ['-','+'] do

            # At this point we always have str[k] = 'x'.
            # We parse this piece of monomial and add it to mon.
            # Here str = x_!!, where !! is an index, so if we increase k
            # by 2 we jump to the index.

            k:=k+2;
            ind:= "";
            while k <= len and str[k] in CHARS_DIGITS  do
                Add( ind, str[k] );
                k:=k+1;
            od;

            # Now we get the exponent:

            if k <= len and str[k] = '^' then
                exp:= "";
                k:= k+1;
                while k <= len and str[k] in CHARS_DIGITS do
                    Add( exp, str[k] );
                    k:= k+1;
                od;
                exp:= Int( exp );
            else
                exp:= 1;
            fi;

            Add( mon, IndeterminateNumbers( SingularBaseRing )[Int(ind)] );
            Add( mon, exp );

            if k <= len and str[k]='*' then k:= k+1; fi;
        od;

        Add( mons, mon );
    od;

    fam:= ElementsFamily( FamilyObj( SingularBaseRing ) );

    SortParallel( mons, cfs, fam!.zippedSum[1] );

    # merge mons and cfs...

    erep:= [ ];
    for k in [1..Length(mons)] do
        Add( erep, mons[k] );
        Add( erep, cfs[k] );
    od;

    return PolynomialByExtRepNC( fam, erep );

end;



ParseSingProcToGapFunction := function ( string )

    local length, k, parameters, done, pos, pos2, precommand, func;

    length := Length( string );
    if length = 0  then
        return ( function (  ) return; end );
    fi;

    # determine in <string> what are the parameters or arguments, and
    # what is the body of the Singular function
    k := 1;
    parameters := " ";
    done := false;

    repeat
        while string[k] = ' '  do
            k := k + 1;
        od;

        if length > k + 11 and string{[ k .. k + 9 ]} = "parameter "  then
            pos := Position( string, ';' );
            Append( parameters, string{[ k + 10 .. pos - 1 ]} );
            Append( parameters, "," );
            string := string{[ pos + 1 .. length ]};
            length := Length( string );
            k := 1;
        else
            done := true;
        fi;

    until done;
    parameters{[ Length( parameters ) ]} := " ";

# remove Singular comments:
# // comment delimiter. Comment extends to end of line.
# These should not harm
# /* comment delimiter. Starts a comment which ends with */.
# */ comment delimiter. Ends a comment which starts with /*.
# */

    pos := PositionSublist( string, "//" );
    while pos <> fail  do
        pos2 := PositionSublist( string, "\n", pos );
        string := Concatenation( string{[ 1 .. pos - 1 ]}, " \n",
           string{[ pos2 + 1 .. Length( string ) ]} );
        pos := PositionSublist( string, "//" );
    od;

    string := NormalizedWhitespace( string );

    # the next two lines are necessary when the string is sent via a
    # stream
    string := ReplacedString( string, "\"", "\\\"" );
    string := ReplacedString( string, "\\", "\\\\" );
#    string := EscapeCharsInString( string );


    # the definition of the Singular function
    precommand := Concatenation( "proc GAP_proc (", parameters, ") {",
                                 string, "};" );

 if parameters <> " " then
    # the '#' of Singular correspond to the <arg> of Gap (but this may
    # give strange effect when there are both named and unnamed arguments)

    parameters := ReplacedString( parameters, "#", "arg" );

    # change the parameters like "def i, list arg" into "i, arg"
    parameters := SplitString( parameters, "," );
    parameters := List( parameters, x -> SplitString( x, " " ) );
    parameters := List( parameters, x ->Filtered( x, y -> not
                                                     IsEmptyString(y)));
    parameters := List( parameters, x -> x[Length( x )] );
    parameters := JoinStringsWithSeparator( parameters, ", " );
 fi;

    # the definition of the Gap function
    func := Concatenation(
       "function (", parameters, ") \n",
       "    SingularCommand( \"", precommand, "\", \"\" );\n",
       "    return SingularInterface( \"GAP_proc\", [", parameters,
       "] , \"def\" );\n",
       "end;\n" );

    return EvalString( func );

end;



# this function is under construction!
ParseSingRingToGapRing := function ( string )
    local p1, p2, char, variables, coeff, to, R;
    p1 := Position( string, '(' );
    p2 := Position( string, ')', p1 );
    char := Int( string{[ p1 + 1 .. p2 - 1 ]} );

    p1 := Position( string, '(', p2 );
    p2 := Position( string, ')', p1 );
    variables := string{[ p1 + 1 .. p2 - 1 ]};
    variables := SplitString( variables, ',' );

    if char = 0  then
        coeff := Rationals;
    else
        coeff := GF( char );
    fi;
    R := PolynomialRing( coeff, variables : old );

    p1 := Position( string, '(', p2 );
    p2 := Position( string, ')', p1 );
    p2 := Position( string, ')', p2 );
    to := string{[ p1 + 1 .. p2 - 1 ]};
    SetTermOrdering( R, to );

    Print( "The conversion of rings from Singular to Gap is under \
construction!\n" );
    return R;
end;




##############################################################################




# This list contains the data types of Singular in (almost) alphabetical
# order, and for each of then the function that check whether a Gap
# object is of that type.

SingularDataTypes := rec(


  def := [ "Objects may be defined without a specific type",
	ReturnFalse, # makes no sense in Gap
	,
	],


  ideal := [ "Ideal of a polynomial ring",
	IsPolynomialRingIdeal,
	ParseGapIdealToSingIdeal,
	],


  int := [ "Variables of type int represent the machine integers and \
are, therefore, limited in their range (e.g., the range is between \
-2147483647 and 2147483647 on 32-bit machines).",
	IsSingularInt,
	String,
	Int
	],


  intmat := [ "Integer matrices are matrices with integer entries.",
	obj -> IsMatrix( obj ) and
			ForAll( obj, x -> ForAll( x, IsSingularInt ) ),
	ParseGapIntmatToSingIntmat,
	],


  intvec := [ "Variables of type intvec are lists of integers.",
	obj -> IsRowVector( obj ) and ForAll( obj, IsSingularInt ),
	ParseGapIntvecToSingIntvec,
	obj -> List( SplitString( obj, ',' ), Int ),
	 ],


  link := [ "Links are the communication channels of SINGULAR, i.e., \
something SINGULAR can write to and/or read from.",
	ReturnFalse, # not implemented
	,
	],


  map := [ "Maps are ring maps from a preimage ring into the basering.",
	obj -> IsAlgebraGeneralMapping( obj )
		and HasSource( obj ) and IsPolynomialRing( Source( obj ) )
		and HasRange( obj ) and IsPolynomialRing( Range( obj ) )
		and HasMappingGeneratorsImages( obj ),

	function ( obj )
            Error( "sorry: the interface to Singular do not support yet ",
           "the type \"map\".\n(Your code to support it will be welcome!)\n");
            return fail;
	end,
	],


  matrix := [ "Objects of type matrix are matrices with polynomial entries.",
	obj -> IsMatrix( obj ) and ForAll( obj, x ->
			ForAll( x, y -> IsSingularPoly( y ) ) ),

	function ( obj )
            local  module;
            module := LeftModuleByGenerators( SingularBaseRing,
               TransposedMat( obj ) );
            return
             Concatenation( "matrix(", ParseGapModuleToSingModule( module ),
               ")" );
	end,
	],


  module := [ "Modules are submodules of a free module over the basering \
with basis gen(1), gen(2), ... .",
	obj -> HasIsRowModule( obj ) and IsRowModule( obj ) and
			ForAll( GeneratorsOfLeftOperatorAdditiveGroup( obj ),
			x -> ForAll( x, y -> IsPolynomial( y ) ) ),
	ParseGapModuleToSingModule,
	],


  number := [ "Numbers are elements from the coefficient field (or \
ground field).",
	obj -> obj in CoefficientsRing( SingularBaseRing ),
	ParseGapNumberToSingNumber,
	ParseSingNumberToGapNumber
	],


  poly := [ "Polynomials are the basic data for all main algorithms in \
SINGULAR.",
	IsSingularPoly,
	ParseGapPolyToSingPoly,
	ParseSingPolyToGapPoly
	],


  proc := [ "Procedures are sequences of SINGULAR commands in a special \
format.",
	IsFunction,

	function( obj )
        Error( "sorry: the interface to Singular do not support ",
         "the type \"proc\".\n(Any idea to support it will be welcome!)\n" );
        return fail;
	end,
	ParseSingProcToGapFunction
	],


  qring := [
	"SINGULAR offers the opportunity to calculate in quotient rings \
(factor rings), i.e., rings modulo an ideal.",
	ReturnFalse, # not supported by Gap
	,
	],


  resolution := [ "The resolution type is intended as an intermediate \
representation which internally retains additional information obtained \
during computation of resolutions.",
	ReturnFalse, # not supported by Gap
	,
	],


  ring := [ "Rings are used to describe properties of polynomials, ideals \
etc. Almost all computations in SINGULAR require a basering.",
	IsPolynomialRing,

	function( obj )
        if obj <> SingularBaseRing  then
            SingularSetBaseRing( obj );
        fi;
        return "GAP_ring";
	end,
#	ParseSingRingToGapRing
	],


  string := [ "string (7 bit clean)",
	IsString and IsStringRep,
	function(obj)
        # the next two lines are necessary when the string is sent via a
        # stream
        obj := ReplacedString( obj, "\\", "\\\\" );
        obj := ReplacedString( obj, "\"", "\\\"" );
#        obj := EscapeCharsInString( obj );
	return Concatenation("\"", obj,"\"");
	end,
	IdFunc
	],


  vector := [ "Vectors are elements of a free module over the basering \
with basis gen(1), gen(2), ... .",
	obj -> IsRowVector( obj ) and ForAll( obj, y ->
			IsSingularPoly( y ) ),
	ParseGapVectorToSingVector,
	],


# "list" must be done after intmat, intvec, matrix, string, vector
  list := [ "Lists are arrays whose elements can be of any type \
(including ring and qring).",
	obj -> IsDenseList( obj ) and
			ForAll( obj, y -> SingularType(y) <> fail ),
	ParseGapListToSingList,
	],


# other or new types

  \?unknown\ type\? := [ "For internal use only is the type \
\"?unknown type?\".",
	ReturnFalse, # makes no sense in Gap
	],


  none := [ "Functions without a return value are specified there to \
have a return type 'none', see \"3.5.1 General command syntax\".",
	ReturnFalse, # makes no sense in Gap
	],


  bigint := [ "Variables of type bigint represent the arbitrary long \
integers. They can only be contructed from other types (int, number).",
#	obj -> IsInt( obj ) and ( SingularVersion >= 3002 or
#		# because it may be still unknown
#		SingularVersion = 0 ),
#	obj -> Concatenation( "bigint(", String( obj ), ")" ),
ReturnFalse,
,
	Int
	],
	    


  package := [ "The data type package is used to group identifiers into \
collections. Introduced in Singular 3.0.0.",
	ReturnFalse, # makes no sense in Gap
	]

);


# The SingularDataTypes record is traversed in ConvertGapObjToSingObj, and the
# order of the entries is important. We can't guarantee that GAP will present 
# the record entries in the order that we have given them (a change introduced 
# in GAP 4.5). So we here list the order in which they should be tested

SingularDataTypeTestOrder := [ "def", "ideal", "int", "intmat", "intvec", "link", 
  "map", "matrix", "module", "number", "poly", "proc", "qring", "resolution", 
  "ring", "string", "vector", "list", "?unknown type?", "none", "bigint", 
  "package" ];

# And check for sanity that this set is same as the names in the record
if Set(SingularDataTypeTestOrder) <> Set(RecNames(SingularDataTypes)) then
  Error( "Singular<->GAP datatypes database error!\n" );
fi;






##############################################################################


# This function determines the Singular type of a Gap object

SingularType := function ( obj )
    local  i;
    for i  in SingularDataTypeTestOrder  do
        if SingularDataTypes.(i)[2]( obj )  then
            return i;
        fi;
    od;
    return fail;
end;



##############################################################################



ConvertGapObjToSingObj := function ( obj )

    local type;

    if HasCurrentRingSingularIdentifier( obj )  then
        return SingularIdentifier( obj );
    fi;

    # Usually the interface determines the type, but this can be
    # overridden specifying it like the following example:
    # rec( Object := [ 1, 2 ], SingularType := "list" );
    # otherwise [ 1, 2 ] will be of type "intvec".

    if IsRecord( obj ) and IsBound( obj.SingularType ) and
       IsBound( obj.Object )  then
        type := obj.SingularType;
        obj := obj.Object;
    else
        type := SingularType( obj );
    fi;

    if type in RecNames(SingularDataTypes)  and
       IsBound( SingularDataTypes.(type)[3])  then
        return SingularDataTypes.(type)[3]( obj );
    else
       Error( "sorry: Singular, or the interface to Singular, or the ",
              "current \nSingularBaseRing, do not support the object " ,
              obj, ".\nDid you remember to use 'SingularSetBaseRing' ?\n" );
        return fail;
    fi;

end;




##############################################################################


# This function converts the string <obj> (that represent a Singular
# object of type <type_output>) into a Gap object. It may be necessary
# to ask Singular for more information about this object: <singname> is
# the name in Singular of this object.

ConvertSingObjToGapObj := function ( obj, type_output, singname )

    local command, ideal, idealno, module, moduleno, mat, name, list,
         nrows, ncols, r, length, type, string, i;

    if type_output in RecNames( SingularDataTypes ) and 
       IsBound( SingularDataTypes.(type_output)[4])  then
        if NumberArgumentsFunction( SingularDataTypes.(type_output)[4] ) = 2
             then
            return SingularDataTypes.(type_output)[4]( obj, singname );
        else
            return SingularDataTypes.(type_output)[4]( obj );
        fi;
    fi;


    # def
    if type_output = "def"  then
    # in this case ask Singular for the type
        command := Concatenation( "typeof( ", singname, " );" );
        type_output := SingCommandInStreamOutStream( "", command );
        Info( InfoSingular, 1, "Singular output of type \"", type_output,
              "\"" );
        return ConvertSingObjToGapObj( obj, type_output, singname );

    # ideal
    elif type_output = "ideal"  then
        ideal := Ideal( SingularBaseRing, List( SplitString( obj, ',' ),
                                      ParseSingPolyToGapPoly ) );

        if SingularCommand <> SingCommandUsingProcess  then

            # set the SingularIdentifier of the returned ideal
            idealno:= SingularNames.ideal+1;
            SingularNames.ideal:= idealno;
            name:= "GAP_ideal_"; Append( name, String( idealno ) );

            SetSingularIdentifier( ideal, name );

            command:= "ideal GAP_ideal_";
            Append( command, String( idealno ) );
            Append( command, " = " );
            Append( command, singname );
            SingCommandInStreamOutStream( command, "" );

        fi;

        return ideal;


    # intmat
    elif type_output = "intmat"  then
        list:= List( SplitString( obj, ',' ,' '), Int );
        command := Concatenation( "nrows( ", singname, " );" );
        nrows := Int( SingCommandInStreamOutStream( "", command ) );
        command := Concatenation( "ncols( ", singname, " );" );
        ncols := Int( SingCommandInStreamOutStream( "", command ) );
        return List( [ 1 .. nrows ], x ->
                     list{[ (x - 1) * ncols + 1 .. x * ncols ]} );

    # link
    elif type_output = "link"  then
        r := rec( object := "link" );
        command := Concatenation( "status( ", singname, ", \"name\" );" );
        r.name :=SingCommandInStreamOutStream( "", command );
        command := Concatenation( "status( ", singname, ", \"mode\" );" );
        r.mode :=SingCommandInStreamOutStream( "", command );
        command := Concatenation( "status( ", singname, ", \"type\" );" );
        r.type :=SingCommandInStreamOutStream( "", command );
        return r;

    # list
    elif type_output = "list"  then
        list := [  ];
        command := Concatenation( "size( ", singname, " );" );
        length := Int( SingCommandInStreamOutStream( "", command ) );
        for i  in [ 1 .. length ]  do
            name := Concatenation( singname, "[", String( i ), "]" );
            command := Concatenation( "typeof( ", name, " );" );
            type := SingCommandInStreamOutStream( "", command );
            command := Concatenation( "string( ", name, " );" );
            string := SingularCommand( "", command );
            Add( list, ConvertSingObjToGapObj( string, type, name ) );
        od;
        return list;


    # matrix
    elif type_output = "matrix"  then
        list:= List( SplitString( obj, ',', ' ' ), ParseSingPolyToGapPoly );
        command := Concatenation( "nrows( ", singname, " );" );
        nrows := Int( SingCommandInStreamOutStream( "", command ) );
        command := Concatenation( "ncols( ", singname, " );" );
        ncols := Int( SingCommandInStreamOutStream( "", command ) );
        return List( [ 1 .. nrows ], x ->
                     list{[ (x - 1) * ncols + 1 .. x * ncols ]} );

    # module
    elif type_output = "module"  then
    # temporary workaround: using ParseSingVectorToGapVector could be better
        mat := SingularInterface( "matrix", singname, "matrix" );
        module := LeftModuleByGenerators( SingularBaseRing,
           TransposedMat( mat ) );

        if SingularCommand <> SingCommandUsingProcess  then

            # set the SingularIdentifier of the returned module
            moduleno:= SingularNames.module+1;
            SingularNames.module:= moduleno;
            name:= "GAP_module_"; Append( name, String( moduleno ) );

            SetSingularIdentifier( module, name );

            command:= "module GAP_module_";
            Append( command, String( moduleno ) );
            Append( command, " = " );
            Append( command, singname );
            SingCommandInStreamOutStream( command, "" );

        fi;

        return module;


   # vector
    elif type_output = "vector"  then
    # temporary workaround: using ParseSingVectorToGapVector could be better
        mat := SingularInterface( "matrix", singname, "matrix" );
        return TransposedMat( mat )[1];


    # ?unknown type?, none 
    elif type_output = "?unknown type?" or type_output = "none"  
         or type_output = ""  then
        if Length( obj ) > 0 then 
            Info( InfoSingular, 1, "Output of type \"", type_output,
                  "\", returned as string" );
        else
            Print( "No output from Singular\n");
        fi;
        return obj;

    else
        Info( InfoSingular, 1,
               "The conversion from Singular to Gap of objects of type \"", 
               type_output, "\"" );
        Info( InfoSingular, 1, "is not yet implemented. ",
               "The output is returned as a string." );
        Info( InfoSingular, 1, 
               "(Your code to convert it will be welcome!)");
        return obj;
    fi;

end;




##############################################################################
##############################################################################

## PART 6. The general high level interface to Singular ##




# Function that displays the help of Singular

SingularHelp := function ( topic )
    local  browser, precommand, out;

    browser := SingularInterface( "system", [ "--browser" ], "string" );
    if browser in [ "info", "builtin", "lynx", "emacs" ]  then
        Error( "the browser ", browser,
         " is not supported by the interface\n" );
    elif browser = "dummy"  then 
        Print( "Singular says: ",
               "\"? No functioning help browser available.\"\n" );
    fi;

    out := SingularCommand( "", Concatenation( "help ", topic, ";" ) );
    Info( InfoSingular, 1, out );

end;




SingularSetBaseRing := function ( R )
    SingularBaseRing := R;
    SingCommandInStreamOutStream( ParseGapRingToSingRing( R ), "" );
    # after setting the base-ring, the names become out of date.
    SingularNamesThisRing := ShallowCopy( SingularNames );
end;



# Function that loads a Singular library

SingularLibrary := function ( lib )
    if Length( lib ) > 0 and PositionSublist( lib, ".lib" ) = fail  then
        Append( lib, ".lib" );
    fi;
    lib := Concatenation( "LIB \"", lib, "\";" );
    SingCommandInStreamOutStream( lib, "" );

    if PositionSublist( SingularLoadedLibraries, lib ) = fail  then
        Append( SingularLoadedLibraries, lib );
    fi;
end;



SingularInterface := function ( singcom, arguments, type_output )

    local precommand, length, out, i, unsupported, info;

    # some Singular functions are unsupported:
    unsupported := [ "exit", "pause", "setring", "quit" ];
    # others may be added

    # trap them
    if singcom in unsupported then 
        Print( "Singular function ", singcom, 
               " is not supported by the interface,\n" );

        if singcom in [ "exit", "quit" ]  then
            Print( "use CloseSingular instead\n");
        elif singcom = "setring" then 
            Print( "use SingularSetBaseRing instead\n");
        fi;

        return fail;
    fi;

    if not (type_output in RecNames( SingularDataTypes ) or 
         type_output = "")  then
        Error( "Type ", type_output, " not supported by Singular\n" );
    fi;

    # parsing singcom
    precommand := "";
    if type_output <> "" then 
        Append( precommand, type_output );
        Append( precommand, " GAP_" );
        Append( precommand, type_output );
        Append( precommand, " = " );
    fi;

    Append( precommand, singcom );
    Append( precommand, "( " );

    # parsing the arguments
    if IsString( arguments )  then
# are needed the following two lines? (or the other one?)
#        arguments := ReplacedString( arguments, "\\", "\\\\" );
#        arguments := ReplacedString( arguments, "\"", "\\\"" );
##        arguments := EscapeCharsInString( arguments );

        Append( precommand, arguments );

    else

        length := Length( arguments );
        for i  in [ 1 .. length ]  do

            Append( precommand, ConvertGapObjToSingObj( arguments[i] ) ); 
            if i < length  then
                Append( precommand, ", " );
            fi;

        od;

    fi;

    # end of the command for Singular
    Append( precommand, " );\n" );



    # send the commands to singular and get the output

    if InfoLevel( InfoSingular ) >= 2  then
        # inform the user about the types in the arguments
        if IsString( arguments )  then
            info := "\"...\"";
        else
            info := [  ];
            length := Length( arguments );
            for i  in [ 1 .. length ]  do
                Add( info, SingularType( arguments[i] ) );
            od;
        fi;
        Info( InfoSingular, 2, "running SingularInterface( \"", singcom,
              "\", ", info, ", \"", type_output, "\" )..." );
    fi;

    out := SingularCommand( Concatenation( precommand, 
                   "string GAP_output = string ( GAP_", type_output, " );" ), 
               "GAP_output" );

    Info( InfoSingular, 2, "done SingularInterface." );


    if SingularCommand = SingCommandUsingProcess and type_output in 
       [ "def", "intmat", "link", "list", "matrix", "proc",
       # the following can be improved...
       "module", "vector" ]  then

        Print( "Sorry, type ", type_output, " is supported only on ",
               "Unix and Gap version >= 4.2,\nor Windows and Gap version ", 
               ">= 4.4.2. Output returned as a string\n" );
        type_output := "string";

    fi;


    return ConvertSingObjToGapObj( out, type_output,
                                   Concatenation( "GAP_", type_output ) );


end;



GapInterface := function ( func, arg, out )

    local  i, length, sing_obj, gap_obj, gap_arg, type_output;

    length := Length( arg );
    gap_arg := [  ];

    # convert each Singular object into a Gap object
    for i  in [ 1 .. length ]  do
        sing_obj := SingularCommand(
           Concatenation( "def GAP_arg = ", arg[i], "; " ), 
           "string(GAP_arg)" );
        gap_obj := ConvertSingObjToGapObj( sing_obj, "def", "GAP_arg" );
        Add( gap_arg, gap_obj );
    od;

    # Apply the Gap function
    gap_obj := CallFuncList( func, gap_arg );

    # convert the resulting Gap object into a Singular object
    sing_obj := ConvertGapObjToSingObj( gap_obj );

    # assign the Singular object to 'out'
    type_output := SingularType( gap_obj );
    if type_output = fail  then
        Error( "object ", gap_obj, "not supported\n" );
    fi;
    SingularCommand( Concatenation(
       type_output, " ", out, " = ", sing_obj, ";" ), "" );

end;




##############################################################################
##############################################################################

## PART 7. High level interface to some functions of Singular ##


# Groebner basis methods.....
# "GroebnerBasis" calculates a GB via the "groebner" command of Singular;

InstallOtherMethod( GroebnerBasis,
        "for an ideal in a poly ring", true,
        [ IsPolynomialRingIdeal ], 0, 
        
        function ( I )

    local input, out;

    Info( InfoSingular, 2, "running GroebnerBasis..." );


    # preparing the input for Singular
    input := "";

    Append( input, "ideal GAP_groebner = groebner( " );
    Append( input, ParseGapIdealToSingIdeal( I ) );
    Append( input, " );\n" );


    out := SingularCommand( input, "string (GAP_groebner)" );


    Info( InfoSingular, 2, "done GroebnerBasis." );

    return List( SplitString( out, ',' ), ParseSingPolyToGapPoly );
      
end );
    


# something like the following could be used in Singular:
# LIB "general.lib";
# watchdog(1048576, "GAP_groebner==1");



HasTrivialGroebnerBasis:= function ( I )

    local input, out;

    Info( InfoSingular, 2, "running HasTrivialGroebnerBasis..." );


    # preparing the input for Singular
    input := "";

    Append( input, "ideal GAP_groebner = groebner( " );
    Append( input, ParseGapIdealToSingIdeal( I ) );
#    to terminate in a reasonable time the following line can be used...
#    Append( input, ", 60);\n" );
    Append( input, " );\n" );


    out := SingularCommand( input, "GAP_groebner==1" );
    

    Info( InfoSingular, 2, "done HasTrivialGroebnerBasis." );

    if out = "0" then 
        return false;
    elif out = "1" then
        return true;
    else
        Error( "in the Singular interface, please report\n" );
    fi;

end;



SINGULARGBASIS := rec(
  name := "singular interface for GroebnerBasis",
  GroebnerBasis := function ( pols, O )

        local  ipr, mcf, R, I;


        if IsPolynomialRingIdeal( pols )  then
            R := LeftActingRingOfIdeal( pols );
            pols := GeneratorsOfTwoSidedIdeal( pols );
        else
            R := DefaultRing( pols );
        fi;

        if IsMonomialOrdering( O )  then
            ipr := ShallowCopy( IndeterminatesOfPolynomialRing( R ) );
            mcf := MonomialComparisonFunction( O );
            Sort( ipr, mcf );
            ipr := Reversed( ipr );
            R := PolynomialRing( LeftActingDomain( R ), ipr );
        fi;

        if not ( HasTermOrdering( R ) and 
                 IsIdenticalObj( TermOrdering( R ), O ) )  then
            SetTermOrdering( R, O );
            SingularSetBaseRing( R );
        fi;

        I := Ideal( R, pols );
        return GroebnerBasis( I );

    end );



# Make the method provided by this package the default method for
# calculating the Groebner Bases.

# GBASIS:= SINGULARGBASIS;



# to be improved ?
GcdUsingSingular := function ( arg )

    local  i;

    if Length( arg ) = 1 and IsList( arg[1] )  then
        arg := arg[1];
    fi;

    SingularCommand( Concatenation( "poly GAP_gcd = ",
       ParseGapPolyToSingPoly( arg[1] ) ), "" );

    for i  in [ 2 .. Length( arg ) ]  do

        # calculate gcd( gcd( arg[1]..arg[i-1] ), arg[i] ) ...
        if SingularCommand(
         Concatenation( "poly GAP_gcd_ = gcd( GAP_gcd, ",
           ParseGapPolyToSingPoly( arg[i] ), " );\n",
           "poly GAP_gcd = GAP_gcd_;" ),
         
        # ... and ask soon whether it is trivial
            "GAP_gcd == 1" ) = "1"  then
            return One( SingularBaseRing );
        fi;

    od;

    return ParseSingPolyToGapPoly( SingularCommand( "", 
                                       "string( GAP_gcd )" ) );
end;



FactorsUsingSingularNC := function ( poly )

    local list, g, ind, res, i;

    list := SingularInterface( "factorize", [ poly ], "list" );

    g := GeneratorsOfTwoSidedIdeal( list[1] );
    ind := list[2];

    res := [  ];
    for i  in [ 1 .. Length( ind ) ]  do
        Append( res, List( [ 1 .. ind[i] ], x -> g[i] ) );
    od;

    return res;

end;




FactorsUsingSingular := function ( poly )

    local res;

    if not IsPrimeField( CoefficientsRing( SingularBaseRing ) ) and 
       SingularVersion < 2004  then
        Info( InfoSingular, 1, "Your version of Singular has a bug and ",
         "the result may be wrong." );
        Info( InfoSingular, 1, "Singular version at least 2-0-4 is ",
         "recommended." );
    fi;

    res := FactorsUsingSingularNC( poly );

    if Product( res ) <> poly then 
       Print ( "Bug (probably in Singular)!  The result, ", res,
               ", is wrong\n" );
       return fail;
    fi;
 
    return res;

end;



GeneratorsOfInvariantRing:= function( R, G )

    local   g,  n,  F;

    if IsMatrixGroup(G) then
        g:= GeneratorsOfGroup( G );
        if Length(g[1]) > Length( IndeterminatesOfPolynomialRing(R) ) then
            Error("<G> does not act on <R>\n");
        fi;
    elif IsPermGroup(G) then
        n:= Maximum(MovedPoints(G));
        F:= LeftActingDomain( R );
        g:= List( GeneratorsOfGroup( G ), x ->
                  TransposedMat(PermutationMat(x,n,F))  );
        if Maximum(MovedPoints(G)) >
           Length( IndeterminatesOfPolynomialRing(R) ) then
            Error("<G> does not act on <R>\n");
        fi;
    else
        Error("<G> must be a matrix or permutation group\n");
    fi;

    SingularLibrary( "finvar.lib" );

    if R <> SingularBaseRing  then
        SingularSetBaseRing( R );
    fi;

    g:= g*One(R);
    return SingularInterface( "invariant_ring", g, "list" )[1][1];
end;





##############################################################################
##############################################################################

## PART 8. Some final technical stuff ##




    
    

# This functions collects all the information that is useful for a
# report about the Singular Interface

SingularReportInformation := function (  )

    local  string, s, uname, _in, _out;

    string := "";

    s := Concatenation( "Pkg_Revision := \"",
                        Revision.("singular/gap/singular.g"), "\";\n" );
    Print( s );
    Append( string, s );
  

  if IsBound( PackageInfo ) then
    s := Concatenation( "Pkg_Version := \"", 
                         PackageInfo("singular")![1].Version, "\";\n" );
    Print( s );
    Append( string, s );
  fi;

    s := Concatenation( "Gap_Version := \"", VERSION, "\";\n" );
    Print( s );
    Append( string, s );

    s := Concatenation( "Gap_Architecture := \"", GAP_ARCHITECTURE, 
         "\";\n" );
    Print( s );
    Append( string, s );

  if IsBound( GAPInfo ) then

    s := Concatenation( "Gap_BytesPerVariable := ",
       String( GAPInfo.BytesPerVariable ), ";\n" );
    Print( s );
    Append( string, s );

  else

  fi;

    if ARCH_IS_UNIX(  )  then
        s := "";
        _in := InputTextNone(  );
        _out := OutputTextString( s, true );
        uname := Filename( DirectoriesSystemPrograms(  ), "uname" );
        # "var" instead of "uname" under Windows, to be implemented

        Process( DirectoryCurrent(  ), uname, _in, _out, [ "-mrs" ] );

        CloseStream( _in );
        CloseStream( _out );

        s := Concatenation( "uname := \"", NormalizedWhitespace( s ), 
           "\";\n" );
        Print( s );
        Append( string, s );
    fi;

    s := Concatenation( "Singular_Version: := ",
       SingularInterface( "string", "system(\"version\")", "string" ), 
       ";\n" ) ;
    Print( s );
    Append( string, s );

    s := Concatenation( "Singular_Name: := \"",
       String( SingularInterface( "system", [ "Singular" ], "string" ) ),
       "\";\n" );
    Print( s );
    Append( string, s );

    Print( "\n" );

    return string;
end;



# the next functions are for developing/debugging.

SingularReloadFile := function (  )
    return ReadPackage( "singular", "gap/singular.g" );
end;



SingularTest := function (  )
    local  testfile, fn;

    if CompareVersionNumbers( VERSION, "4.5" )  then
        testfile := "test";
    elif CompareVersionNumbers( VERSION, "4.4" )  then
        testfile := "test_4_4";
    else
        testfile := "test_4_3";
    fi;

    fn := Filename( DirectoriesPackageLibrary( "singular", "tst" ), testfile );
    
    return ReadTest( fn );
end;



# If 'Process' is used, ask Singular to get SingularVersion.

if SingularCommand = SingCommandUsingProcess  then
    SingularVersion := Int( SingularCommand( "", "system(\"version\");" ) );
fi;


#############################################################################
#E

