#############################################################################
##
#W  types.gi             GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: types.gi,v 1.28 2009/07/29 14:18:33 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains implementations of the functions for administrating
##  the data types used in the {\ATLAS} of Group Representations.
##
Revision.( "atlasrep/gap/types_gi" ) :=
    "@(#)$Id: types.gi,v 1.28 2009/07/29 14:18:33 gap Exp $";


#############################################################################
##
#F  TOCEntryStringDefault( <typename>, <entry> )
##
BindGlobal( "TOCEntryStringDefault", function( typename, entry )
    return Concatenation( [
    "AGRTOC(\"", typename, "\",\"", entry[ Length( entry ) ], "\");\n" ] );
end );


#############################################################################
##
#F  DisplayOverviewInfoDefault( <dispname>, <align>, <compname> )
##
BindGlobal( "DisplayOverviewInfoDefault",
    function( dispname, align, compname )
    return [ dispname, align, function( tocs, groupname )
      local value, private, j, toc, record, new;

      value:= false;
      private:= false;
      for j in [ 1 .. Length( tocs ) ] do
        toc:= tocs[j];
        if IsBound( toc.( groupname ) ) then
          record:= toc.( groupname );
          if IsBound( record.( compname ) ) then
            new:= not IsEmpty( record.( compname ) );
            if 1 < j and new then
              private:= true;
            fi;
            value:= value or new;
          fi;
        fi;
      od;
      if value then
        value:= "+";
      else
        value:= "-";
      fi;
      return [ value, private ];
    end ];
end );


#############################################################################
##
#F  AGRTestWordsSLPDefault( <tocid>, <name>, <file>, <type>, <outputs>,
#F                          <verbose> )
##
##  For the straight line program that is returned by
##  <Ref Func="AGRFileContents"/> when this is called
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
BindGlobal( "AGRTestWordsSLPDefault",
    function( tocid, name, file, type, outputs, verbose )
    local filename, prog, prg, gens;

    # Read the program.
    if tocid = "local" then
      tocid:= "dataword";
    fi;
    prog:= AGRFileContents( tocid, name, file, type );
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
end );


#############################################################################
##
#F  AGRTestWordsSLDDefault( <tocid>, <name>, <file>, <type>, <format>,
#F                          <verbose> )
##
##  For the straight line decision that is returned by
##  <Ref Func="AGRFileContents"/> when this is called
##  with the same arguments,
##  it is checked that it is internally consistent and that it can be
##  evaluated in all relevant representations.
##
BindGlobal( "AGRTestWordsSLDDefault",
    function( tocid, name, file, type, format, verbose )
    local filename, prog, result, gapname, orderfunc, std, entry, gens;

    # Read the program.
    if tocid = "local" then
      tocid:= "dataword"; 
    fi;
    prog:= AGRFileContents( tocid, name, file, type );
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
end );


#############################################################################
##
#F  AGRTestFileHeadersDefault( <tocid>, <groupname>, <entry>, <type>, <dim>,
#F                             <special> )
##
BindGlobal( "AGRTestFileHeadersDefault",
    function( tocid, groupname, entry, type, dim, special )
    local filename, name, mats;

    # Try to read the file.
    if tocid = "local" then
      tocid:= "datagens";
    fi;
    dim:= [ dim, dim ];
    filename:= entry[ Length( entry ) ];
    mats:= AGRFileContents( tocid, groupname, filename, type );

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
end );


#############################################################################
##
#F  AGRTestFilesMTX( <tocid>, <groupname>, <entry>, <type> )
##
BindGlobal( "AGRTestFilesMTX", function( tocid, groupname, entry, type )
    local result;

    if tocid = "local" then
      tocid:= "datagens";
    fi;
    # Read the file(s).
    result:= AGRFileContents( tocid, groupname, entry[ Length( entry ) ],
                              type ) <> fail;
    if not result then
      Print( "#E  file(s) `", entry[ Length( entry ) ], "' corrupted\n" );
    fi;
    return result;
end );


#############################################################################
##
#F  AtlasProgramDefault( <type>, <identifier>, <prefix>, <groupname> )
##
BindGlobal( "AtlasProgramDefault",
    function( type, identifier, prefix, groupname )
    local prog, result;

    if IsString( identifier[2] ) and
       AGRParseFilenameFormat( identifier[2], type[2].FilenameFormat )
           <> fail then
      prog:= AGRFileContents( prefix, groupname, identifier[2], type );
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
#F  AGRCheckOneCondition( <func>[, <detect>], <condlist> )
##
BindGlobal( "AGRCheckOneCondition", function( arg )
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
      return true;
    elif Length( arg ) = 2 then
      Unbind( condlist[ pos ] );
      return true;
    elif pos = Length( condlist ) then
      return true;
    fi;
    val:= condlist[ pos+1 ];
    if    ( IsString( val ) and detect( val ) )
       or ( not IsList( val ) and detect( val ) )
       or ( IsList( val ) and ForAny( val, detect ) ) then
      Unbind( condlist[ pos ] );
      Unbind( condlist[ pos+1 ] );
      return true;
    fi;
    return true;
end );


#############################################################################
##
#F  AGRDeclareDataType( <kind>, <name>, <record> )
##
##  Check that the necessary components are bound,
##  and add default values if necessary.
##
InstallGlobalFunction( AGRDeclareDataType, function( kind, name, record )
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
    else
      Error( "<kind> must be one of \"rep\", \"prg\"" );
    fi;

    # Add the pair.
    Add( types.( kind ), [ name, record, kind ] );

    # Clear the cache.
    types.cache:= [];
end );


#############################################################################
##
#F  AGRDataTypes( <kind1>[, <kind2>] )
##
InstallGlobalFunction( AGRDataTypes, function( arg )
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
end );


#############################################################################
##
#E

