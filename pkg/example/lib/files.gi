#############################################################################
##
#W  files.gi                   Example Package                  Werner Nickel
##
##  Installation file for functions of the Example package.
##
#Y  Copyright (C) 1999,2001 University of St. Andrews, North Haugh,
#Y                          St. Andrews, Fife KY16 9SS, Scotland
##

#############################################################################
##
#F  EgSeparatedString( <str>, <c> ) . . . . . . . .  cut a string into pieces
##
InstallGlobalFunction( EgSeparatedString, function( str, c )
    local   pieces,  start,  i;

    pieces := [];
    start := 1;
    for i in [1..Length(str)] do
        if str[i] = c then
            if start <= i-1 then
                Add( pieces, str{[start..i-1]} );
            fi;
            start := i+1;
        fi;
    od;
    if start <= Length(str) then
        Add( pieces, str{[start..Length(str)]} );
    fi;
    
    return pieces;
end );

#############################################################################
##
#F  ListDirectory([<dir>])  . . . . . . . . . . list the files in a directory
##
InstallGlobalFunction( ListDirectory, function( arg )
    local   dir,  str,  ls,  out;

    if Length( arg ) = 0 then
        dir := "./";
    elif Length( arg ) <> 1 then
        return Error( "ListDirectory( [<dirname>] )" );
    else
        dir := arg[1];
    fi;

    str := "";

    if IsDirectoryPath( dir ) = true then
        dir := Directory( dir );
        ls  := Filename( DirectoriesSystemPrograms(), "ls" );
        out := OutputTextString( str, true );
        Process( dir, ls, InputTextNone(), out, [] );
        CloseStream( out );
        return EgSeparatedString( str, '\n' );
    else
        return Error( "Directory <dirname> does not exist" );
    fi;
end );

#############################################################################
##
#F  FindFile( <dir>, <file> ) . . . . . . . . find a file in a directory tree
##
InstallGlobalFunction( FindFile, function( dir, file )
    local   files,  try,  res;

    files := ListDirectory( dir );
    if file in files then
        return [ Concatenation( dir, "/", file ) ];
    fi;

    res := [];
    for try in files do
        try := Concatenation( dir, "/", try );
        if IsDirectoryPath( try ) then
            Append( res, FindFile( try, file ) );
        fi;
    od;

    return res;
end );


#############################################################################
##
#F  LoadedPackages() . . . . . . . . . . . . . which GAP packages are loaded?
##
InstallGlobalFunction( LoadedPackages, function()

    return RecNames( GAPInfo.PackagesLoaded );
end );

#############################################################################
##
#F  Which( <prg> )  . . . . . . . . . . . . which program would Exec execute?
##
InstallGlobalFunction( Which, function( prg )

    if prg[1] <> '/' then
        prg := Filename( DirectoriesSystemPrograms(), prg );
    fi;
    
    if prg <> fail and IsExistingFile( prg ) and IsExecutableFile( prg ) then
        return prg;
    else
        return fail;
    fi;
end );

#############################################################################
##
#F  WhereIsPkgProgram( <prg> ) . . . . the paths of any matching pkg programs
##
InstallGlobalFunction( WhereIsPkgProgram, function( prg )
local paths;

    paths := List( LoadedPackages(), 
                   pkg -> Filename(DirectoriesPackagePrograms(pkg), prg) );

    return Filtered(paths, path -> path <> fail);   
end );

#############################################################################
##
#F  HelloWorld() . . . . . . . . . . . . . . . . . . . . . . . . . . . guess!
##
InstallGlobalFunction( HelloWorld, function()
local hello;

    hello := Filename(DirectoriesPackagePrograms("example"), "hello");

    Exec(hello);
end );

#############################################################################
##
#V  FruitCake . . . . . . . . . . . . . things one needs to make a fruit cake
##
InstallValue( FruitCake, rec( 
    name        := "Fruit Cake",
    ovenTemp    := "160 C then 150 C",
    cookingTime := "2/3 + 1 1/2 hours",
    tin         := "18cm square or 20cm round, greased and papered",
    ingredients := [ 
        "3/4_cup sugar (optional)",
        "1/3_bottle brandy",
        "2 1/2 + 1/3_cups mixed fruit + mixed peel + glace cherries + figs",
        "1_tsp nutmeg (or mixed spice)",
        "1_tsp bicarbonate of soda (NaHCO3)",
        "1/2 - 3/4_cup butter (125g - 200g)",
        "2_beaten eggs",
        "1_cup SR flour (i.e. flour with yeast added)",
        "1_cup plain flour" ],
    method      := [
        "Preheat oven to 160 C.",
        "Collect ingredients.",
        ["In a saucepan place (sugar,) water, fruit, peel,  cherries,  diced",
         "figs, nutmeg, soda, brandy and butter and stir them until boiling.",
         "Allow to cool for 5 minutes."],
        "Sift flours and stir in the flour and eggs, and mix thoroughly.",
        ["Place in  tin  and  bake  at 160 C  for  40 minutes.  Then reduce",
         "temperature to 150 C and continue to bake cake for 1 1/2 hours."],
        "Allow to stand in tin for 15 mins. Then turn on to cake rack to cool."
        ],
    notes       := [
        "1 cup is approx. 225ml",
        "1 bottle is 750ml" ]
    )
);

#############################################################################
##
#M  Recipe( <cake> ) . . . . . . . . . . . . . . . . . . . . display a recipe
##
InstallMethod( Recipe, "record", [ IsRecord ],
    function( cake )
    local field, blanks, str, ingredient, pos, step, lines, line;
      Print( "\n" );
      blanks := "                                ";
      for field in RecNames( cake ) do
        if field <> "name" then
          str := ReplacedString(field, "T", " T");
          Print( CHARS_UALPHA{[ Position(CHARS_LALPHA, str[1]) ]},
                 str{[2 .. Length(str)]}, ":" );
        fi;
        if IsString( cake.(field) ) then
          if field = "name" then
            str := Concatenation( cake.(field), " Recipe" );
            Print( blanks{[1 .. Int( ( 80 - Length(str) ) / 2 )]}, str);
          else
            Print( " ", cake.(field), "." );
          fi;
          Print( "\n\n" );
        else
          Print( "\n" );
          if field = "ingredients" then
            for ingredient in cake.ingredients do
              pos := Position(ingredient, '_');
              Print( blanks{[1 .. 16 - pos]}, 
                     ingredient{[1 .. pos - 1]}, " ",
                     ingredient{[pos + 1 .. Length(ingredient)]}, "\n" );
            od;
          else
            for step in [1 .. Length( cake.(field) )] do
              Print( step, ". " );
              lines := cake.(field)[step];
              if IsString( lines ) then
                Print( lines, "\n" );
              else
                Print( lines[1], "\n" );
                for line in lines{[2 .. Length( lines )]} do
                  Print( "   ", line, "\n" );
                od;
              fi;
            od;
          fi;
          Print( "\n" );
        fi;
      od;
    end );

#E  files.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
