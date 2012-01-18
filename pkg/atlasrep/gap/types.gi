#############################################################################
##
#W  types.gi             GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains implementations of the functions for administrating
##  the data types used in the {\ATLAS} of Group Representations.
##


#############################################################################
##
#F  TOCEntryStringDefault( <typename>, <entry> )
##
BindGlobal( "TOCEntryStringDefault", function( typename, entry )
    return Concatenation( [
    "AGR.TOC(\"", typename, "\",\"", entry[ Length( entry ) ], "\");\n" ] );
end );


#############################################################################
##
#F  AGR.DisplayOverviewInfoDefault( <dispname>, <align>, <compname> )
##
AGR.DisplayOverviewInfoDefault:= function( dispname, align, compname )
    return [ dispname, align, function( conditions )
      local groupname, tocs, std, value, private, toc, record, new;

      groupname:= conditions[1][2];
      tocs:= AGR.TablesOfContents( conditions );
      if Length( conditions ) = 1 or
         not ( IsInt( conditions[2] ) or IsList( conditions[2] ) ) then
        std:= true;
      else
        std:= conditions[2];
        if IsInt( std ) then
          std:= [ std ];
        fi;
      fi;

      value:= false;
      private:= false;
      for toc in tocs do
        if IsBound( toc.( groupname ) ) then
          record:= toc.( groupname );
          if IsBound( record.( compname ) ) then
            new:= ForAny( record.( compname ),
                          x -> std = true or x[1] in std );
            if IsBound( toc.diridPrivate ) and new then
              private:= true;
            fi;
            value:= value or new;
          fi;
        fi;
      od;
      if value then
        value:= "+";
      else
        value:= "";
      fi;
      return [ value, private ];
    end ];
    end;


#############################################################################
##
#F  AGR.TestWordsSLPDefault( <tocid>, <name>, <file>, <type>, <outputs>,
#F                           <verbose> )
##
##  For the straight line program that is returned by
##  <Ref Func="AGR.FileContents"/> when this is called
##  with the first four arguments,
##  it is checked that it is internally consistent and that it can be
##  evaluated at the right number of arguments.
##  If the argument <A>outputs</A> is <K>true</K> then it is additionally
##  checked that the result record has a component <C>outputs</C>,
##  a list whose length equals the number of outputs of the program.
##  (The argument <A>verbose</A> is currently not used,
##  in other <C>TestWords</C> functions the value <K>true</K> triggers that
##  more statements may be printed than just error messages.
##
AGR.TestWordsSLPDefault:= function( tocid, name, file, type, outputs, verbose )
    local filename, prog, prg, gens;

    # Read the program.
    if tocid = "local" then
      tocid:= "dataword";
    fi;
    prog:= AGR.FileContents( tocid, name, file, type );
    if prog = fail then
      Print( "#E  file `", file, "' is corrupted\n" );
      return false;
    fi;

    # Check consistency.
    if prog = fail or not IsInternallyConsistent( prog.program ) then
      Print( "#E  program `", file, "' not internally consistent\n" );
      return false;
    fi;
    prg:= prog.program;

    # Create the list of (trivial) generators.
    gens:= ListWithIdenticalEntries( NrInputsOfStraightLineProgram( prg ),
                                     () );

    # Run the program.
    gens:= ResultOfStraightLineProgram( prg, gens );

    # If the script computes class representatives then
    # check whether there is an `outputs' component of the right length.
    if outputs = true then
      if not IsBound( prog.outputs ) then
        Print( "#E  program `", file, "' without component `outputs'\n" );
        return false;
      elif Length( prog.outputs ) <> Length( gens ) then
        Print( "#E  program `", file, "' with wrong number of `outputs'\n" );
        return false;
      fi;
    fi;

    return true;
    end;


#############################################################################
##
#F  AGR.TestWordsSLDDefault( <tocid>, <name>, <file>, <type>, <format>,
#F                           <verbose> )
##
##  For the straight line decision that is returned by
##  <Ref Func="AGR.FileContents"/> when this is called
##  with the same arguments,
##  it is checked that it is internally consistent and that it can be
##  evaluated in all relevant representations.
##
AGR.TestWordsSLDDefault:= function( tocid, name, file, type, format, verbose )
    local filename, prog, result, gapname, orderfunc, std, entry, gens;

    # Read the program.
    if tocid = "local" then
      tocid:= "dataword"; 
    fi;
    prog:= AGR.FileContents( tocid, name, file, type );
    if prog = fail then
      Print( "#E  file `", file, "' is corrupted\n" );
      return false;
    fi;

    # Check consistency.
    if not IsInternallyConsistent( prog.program ) then
      Print( "#E  program `", file, "' not internally consistent\n" );
      return false;
    fi;
    prog:= prog.program;

    # Evaluate the program in *all* relevant representations.
    result:= true;
    gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                     pair -> name = pair[2] );
    if gapname = fail then
      Print( "#E  problem: no GAP name for `", name, "'\n" );
      return false;
    fi;
    gapname:= gapname[1];

    orderfunc:= function( g )
      if IsMatrix( g ) then
        return OrderMatTrial( g, 10000 );
      else
        return Order( g );
      fi;
    end;

    std:= ParseBackwards( file, format );
    std:= std[3];
    for entry in AllAtlasGeneratingSetInfos( gapname, std ) do
      gens:= AtlasGenerators( entry.identifier );
      if gens <> fail then
        if not ResultOfStraightLineDecision( prog, gens.generators,
                   orderfunc ) then
          Print( "#E  program `", file, "' does not fit to\n#E  `",
                 entry.identifier, "'\n" );
          result:= false;
        fi;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  AGR.TestFileHeadersDefault( <tocid>, <groupname>, <entry>, <type>, <dim>,
#F                              <special> )
##
AGR.TestFileHeadersDefault:= function( tocid, groupname, entry, type, dim, special )
    local filename, name, mats;

    # Try to read the file.
    if tocid = "local" then
      tocid:= "datagens";
    fi;
    dim:= [ dim, dim ];
    filename:= entry[ Length( entry ) ];
    mats:= AGR.FileContents( tocid, groupname, filename, type );

    # Check that the file contains a list of matrices of the right dimension.
    if   mats = fail then
      Print( "#E  filename `", filename, "' not found\n" );
      return false;
    elif not ( IsList( mats ) and ForAll( mats, IsMatrix ) ) then
      Print( "#E  file `", filename,
             "' does not contain a list of matrices\n" );
      return false;
    elif ForAny( mats, mat -> DimensionsMat( mat ) <> dim ) then
      Print( "#E  matrices in `",filename,"' have wrong dimensions\n" );
      return false;
    fi;

    # Check the entries.
    special:= special( entry, mats, filename );
    if IsString( special ) then
      Print( "#E  ", special, "\n" );
      return false;
    fi;

    return true;
    end;


#############################################################################
##
#F  AGRTestFilesMTX( <tocid>, <groupname>, <entry>, <type> )
##
AGR.TestFilesMTX:= function( tocid, groupname, entry, type )
    local result;

    if tocid = "local" then
      tocid:= "datagens";
    fi;
    # Read the file(s).
    result:= AGR.FileContents( tocid, groupname, entry[ Length( entry ) ],
                              type ) <> fail;
    if not result then
      Print( "#E  file(s) `", entry[ Length( entry ) ], "' corrupted\n" );
    fi;
    return result;
    end;


#############################################################################
##
#F  AtlasProgramInfoDefault( <type>, <identifier>, <prefix>, <groupname> )
##
BindGlobal( "AtlasProgramInfoDefault",
    function( type, identifier, prefix, groupname )
    local prog, result;

    if IsString( identifier[2] ) and
       AGR.ParseFilenameFormat( identifier[2], type[2].FilenameFormat )
           <> fail then
      return rec( standardization := identifier[3],
                  identifier      := identifier );
    fi;
    return fail;  
end );


#############################################################################
##
#F  AtlasProgramDefault( <type>, <identifier>, <prefix>, <groupname> )
##
BindGlobal( "AtlasProgramDefault",
    function( type, identifier, prefix, groupname )
    local prog, result;

    if IsString( identifier[2] ) and
       AGR.ParseFilenameFormat( identifier[2], type[2].FilenameFormat )
           <> fail then
      prog:= AGR.FileContents( prefix, groupname, identifier[2], type );
      if prog <> fail then
        result:= rec( program         := prog.program,
                      standardization := identifier[3],
                      identifier      := identifier );
        if IsBound( prog.outputs ) then
          result.outputs:= prog.outputs;
        fi;
        return result;
      fi;
    fi;
    return fail;  
end );


#############################################################################
##
#F  AGR.CheckOneCondition( <func>[, <detect>], <condlist> )
##
##  This function always returns `true'; it changes <condlist> in place.
##
AGR.CheckOneCondition:= function( arg )
    local func, detect, condlist, pos, val;

    func:= arg[1];
    if Length( arg ) = 2 then
      condlist:= arg[2];
    else
      detect:= arg[2];
      condlist:= arg[3];
    fi;
    pos:= Position( condlist, func );
    if   pos = fail then
      # The function does not occur as a condition.
      return true;
    fi;

    while pos <> fail do
      if Length( arg ) = 2 then
        # Support `IsPermGroup' etc. *without* subsequent `true'.
        Unbind( condlist[ pos ] );
      else
        if pos = Length( condlist ) then
          # Keep `condlist' unchanged.
          # If there is a call without <detect> then it will remove the entry.
          return true;
        fi;
        val:= condlist[ pos+1 ];
        if    ( IsString( val ) and detect( val ) )
           or ( not IsList( val ) and detect( val ) )
           or ( IsList( val ) and ForAny( val, detect ) ) then
          Unbind( condlist[ pos ] );
          Unbind( condlist[ pos+1 ] );
        fi;
      fi;
      pos:= Position( condlist, func, pos );
    od;
    return true;
    end;


#############################################################################
##
#F  AGR.DeclareDataType( <kind>, <name>, <record> )
##
##  Check that the necessary components are bound,
##  and add default values if necessary.
##
AGR.DeclareDataType:= function( kind, name, record )
    local types, nam;

    # Check that the type does not yet exist.
    types:= AtlasOfGroupRepresentationsInfo.TableOfContents.types;
    if ForAny( types.( kind ), x -> x[1] = name ) then
      Error( "data type <name> exists already" );
    fi;
    record:= ShallowCopy( record );

    # Check mandatory components.
    for nam in [ "FilenameFormat", "AddFileInfo",
                 "ReadAndInterpretDefault" ] do
      if not IsBound( record.( nam ) ) then
        Error( "the component `", nam, "' must be bound in <record>" );
      fi;
    od;

    # Add default components.
    if not IsBound( record.DisplayOverviewInfo ) then
      record.DisplayOverviewInfo:= fail;
    fi;
    if not IsBound( record.TOCEntryString ) then
      record.TOCEntryString := TOCEntryStringDefault;
    fi;
    if not IsBound( record.PostprocessFileInfo ) then
      record.PostprocessFileInfo := Ignore;
    fi;
    if   kind = "rep" then
      for nam in [ "DisplayGroup", "AddDescribingComponents" ] do
        if not IsBound( record.( nam ) ) then
          Error( "the component `", nam, "' must be bound in <record>" );
        fi;
      od;
      if not IsBound( record.AccessGroupCondition ) then
        record.AccessGroupCondition := ReturnFalse;
      fi;
      if not IsBound( record.TestFileHeaders ) then
        record.TestFileHeaders := ReturnTrue;
      fi;
      if not IsBound( record.TestFiles ) then
        record.TestFiles := ReturnTrue;
      fi;
    elif kind = "prg" then
      if not IsBound( record.DisplayPRG ) then
        record.DisplayPRG := function( tocs, name, std, stdavail )
            return []; end;
      fi;
      if not IsBound( record.AccessPRG ) then
        record.AccessPRG := function( record, std, conditions )
          return fail;
        end;
      fi;
      if not IsBound( record.AtlasProgram ) then
        record.AtlasProgram := AtlasProgramDefault;
      fi;
      if not IsBound( record.AtlasProgramInfo ) then
        record.AtlasProgramInfo := AtlasProgramInfoDefault;
      fi;
    else
      Error( "<kind> must be one of \"rep\", \"prg\"" );
    fi;

    # Add the pair.
    Add( types.( kind ), [ name, record, kind ] );

    # Clear the cache.
    types.cache:= [];
    end;


#############################################################################
##
#F  AGR.DataTypes( <kind1>[, <kind2>] )
##
##  returns the list of pairs <C>[ <A>name</A>, <A>record</A> ]</C>
##  as declared for the kinds in question.
AGR.DataTypes:= function( arg )
    local types, result, kind;

    types:= AtlasOfGroupRepresentationsInfo.TableOfContents.types;
    result:= First( types.cache, x -> x[1] = arg );

    if result = fail then
      result:= [];
      for kind in arg do
        if IsBound( types.( kind ) ) then
          Append( result, types.( kind ) );
        fi;
      od;
      result:= [ arg, result ];
      Add( types.cache, result );
    fi;

    return result[2];
    end;


#############################################################################
##
#E

