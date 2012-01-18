#############################################################################
##
#W  test.g               GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions to test the data available in the
##  ATLAS of Group Representations.
##


#############################################################################
##
##  <#GAPDoc Label="tests">
##  The fact that the &ATLAS; of Group Representations is designed as an
##  open database
##  (see Section&nbsp;<Ref Subsect="subsect:Local or remote access"/>)
##  makes it especially desirable to have consistency checks available
##  which can be run automatically
##  whenever new data are added by the developers of the &ATLAS;.
##  The tests described in Section
##  <Ref Subsect="subsect:AGR sanity checks by toc"/> can be used
##  also for data from private extensions of the package
##  (see Chapter&nbsp;<Ref Chap="chap:Private Extensions"/>),
##  Section <Ref Subsect="subsect:AGR other sanity checks"/> lists tests
##  which do not have this property.
##  <P/>
##  All these tests apply only to the <E>local</E> table of contents
##  (see Section&nbsp;<Ref Sect="sect:The Tables of Contents of the AGR"/>)
##  or to private extensions.
##  So only those data files are checked that are actually available
##  in the local &GAP; installation.
##  No files are fetched from servers during these tests.
##  The required space and time for running these tests
##  depend on the amount of locally available data.
##  <P/>
##  The file <F>tst/testall.g</F> of the package
##  contains <Ref Func="ReadTest" BookName="ref"/> statements
##  for executing a collection of such sanity checks;
##  one can run them by calling
##  <C>ReadPackage( "AtlasRep", "tst/testall.g" )</C>.
##  If no problem occurs then &GAP; prints only lines starting with one of
##  the following.
##  <P/>
##  <Log><![CDATA[
##  + Input file:
##  + GAP4stones:
##  ]]></Log>
##  <P/>
##  Some of the checks compute and verify additional data,
##  such as information about point stabilizers of permutation
##  representations.
##  In these cases, output lines starting with <C>#E</C> are error messages
##  that point to inconsistencies,
##  whereas output lines starting with <C>#I</C> inform about data that have
##  been computed and were not yet stored, or about stored data that were not
##  verified.
##  <P/>
##  The examples in the package manual form a part of the tests,
##  they are collected in the file <F>tst/docxpl.tst</F> of the package.
##
##  <Subsection Label="subsect:AGR sanity checks by toc">
##  <Heading>Sanity Checks for a Table of Contents</Heading>
##
##  The following tests can be used to check the data that belong to a given
##  table of contents.
##  Each of these tests is given by a function with optional argument
##  <A>tocid</A>, the identifying string that had been entered as the second
##  argument of
##  <Ref Func="AtlasOfGroupRepresentationsNotifyPrivateDirectory"/>.
##  The contents of the local <F>dataword</F> directory can be checked by
##  entering <C>"local"</C>, which is also the default for <A>tocid</A>.
##  The function returns <K>false</K> if an error occurs,
##  otherwise <K>true</K>.
##  Currently the following tests of this kind are available.
##  <P/>
##  <List>
##  <#Include Label="test:AGR.Test.Words">
##  <#Include Label="test:AGR.Test.FileHeaders">
##  <#Include Label="test:AGR.Test.Files">
##  <#Include Label="test:AGR.Test.BinaryFormat">
##  <#Include Label="test:AGR.Test.Primitivity">
##  <#Include Label="test:AGR.Test.Characters">
##  </List>
##
##  </Subsection>
##
##  <Subsection Label="subsect:AGR other sanity checks">
##  <Heading>Other Sanity Checks</Heading>
##
##  The tests described in this section are not intended for checking data
##  from private extensions of the <Package>AtlasRep</Package> package.
##  Each of the tests is given by a function without arguments that
##  returns <K>false</K> if a contradiction was found during the test,
##  and <K>true</K> otherwise.
##  Additionally, certain messages are printed
##  when contradictions between stored and computed data are found,
##  when stored data cannot be verified computationally,
##  or when the computations yield improvements of the stored data.
##  Currently the following tests of this kind are available.
##  <P/>
##  <List>
##  <#Include Label="test:AGR.Test.GroupOrders">
##  <#Include Label="test:AGR.Test.MaxesOrders">
##  <#Include Label="test:AGR.Test.MaxesStructure">
##  <#Include Label="test:AGR.Test.StdCompatibility">
##  <#Include Label="test:AGR.Test.CompatibleMaxes">
##  <#Include Label="test:AGR.Test.ClassScripts">
##  <#Include Label="test:AGR.Test.CycToCcls">
##  <#Include Label="test:AGR.Test.Standardization">
##  <#Include Label="test:AGR.Test.StdTomLib">
##  <#Include Label="test:AGR.Test.KernelGenerators">
##  <#Include Label="test:AGR.Test.MinimalDegrees">
##  </List>
##
##  </Subsection>
##  <#/GAPDoc>
##

if not IsPackageMarkedForLoading( "TomLib", "" ) then
  HasStandardGeneratorsInfo:= "dummy";
  IsStandardGeneratorsOfGroup:= "dummy";
  LIBTOMKNOWN:= "dummy";
  StandardGeneratorsInfo:= "dummy";
fi;

if not IsPackageMarkedForLoading( "CTblLib", "" ) then
  ConstructionInfoCharacterTable:= "dummy";
  HasConstructionInfoCharacterTable:= "dummy";
  LibInfoCharacterTable:= "dummy";
fi;

if IsBound( StructureDescriptionCharacterTableName ) then
  AGR.StructureDescriptionCharacterTableName:=
      StructureDescriptionCharacterTableName;
else
  AGR.StructureDescriptionCharacterTableName:= name -> name;
fi;


#############################################################################
##
#V  AGR.Test
##
AGR.Test:= rec();


#############################################################################
##
#V  AGR.Test.HardCases
#V  AGR.Test.HardCases.MaxNumberMaxes
#V  AGR.Test.HardCases.MaxNumberStd
#V  AGR.Test.MaxTestDegree
##
##  This is a record whose components belong to the various tests,
##  and list data which shall be omitted from the tests
##  because they would be too space or time consuming.
##
##  In the test loops, we assume upper bounds on the numbers of available
##  maximal subgroups and standardizations,
##  and we perform some tests only if a sufficiently small permutation
##  representation is available.
##
AGR.Test.HardCases:= rec();
AGR.Test.HardCases.MaxNumberMaxes:= 50;
AGR.Test.HardCases.MaxNumberStd:= 2;
AGR.Test.MaxTestDegree:= 10^5;


#############################################################################
##
#F  AGR.Test.Words( [<tocid>[, <groupname>]][,][<verbose>] )
##
##  <#GAPDoc Label="test:AGR.Test.Words">
##  <Mark><C>AGR.Test.Words( [<A>tocid</A>] )</C></Mark>
##  <Item>
##    processes all straight line programs that are stored in the directory
##    with identifier <A>tocid</A>,
##    using the function stored in the <C>TestWords</C> component of the
##    data type in question.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.HardCases.TestWords:= [
    [ "find", [ "B", "HN", "S417", "F24d2" ] ],
    [ "check", [ "B" ] ],
    [ "maxes", [ "Co1" ] ],
  ];

AGR.Test.Words:= function( arg )
    local result, maxdeg, tocid, verbose, types, toc, name, r, type, omit,
          entry, prg, gens, grp, size;

    # Initialize the result.
    result:= true;

    maxdeg:= AGR.Test.MaxTestDegree;

    if Length( arg ) = 0 then
      return AGR.Test.Words( "local", false );
    elif Length( arg ) = 1 and IsBool( arg[1] ) then
      return AGR.Test.Words( "local", arg[1] );
    elif Length( arg ) = 1 and IsString( arg[1] ) then
      return AGR.Test.Words( arg[1], false );
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      return AGR.Test.Words( arg[1], arg[2], false );
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsBool( arg[2] ) then
      for name in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AGR.Test.Words( arg[1],
                     name[3], arg[2] ) and result;
      od;
      return result;
    elif not ( Length( arg ) = 3 and IsString( arg[1] )
                                 and IsString( arg[2] )
                                 and IsBool( arg[3] ) ) then
      Error( "usage: AGR.Test.Words( [<tocid>[, ",
             "<groupname>]][,][<verbose>] )" );
    fi;

    tocid:= arg[1];
    verbose:= arg[3];

    # Check only straight line programs.
    types:= AGR.DataTypes( "prg" );

    toc:= AtlasTableOfContents( tocid );
    if toc = fail then
      # No test is reasonable.
      return true;
    fi;

    name:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                  x -> x[2] = arg[2] );
    if IsBound( toc.TableOfContents.( name[2] ) ) then
      r:= toc.TableOfContents.( name[2] );

      # Note that the ordering in the `and' statement must not be
      # changed, in order to execute all tests!
      for type in types do
        omit:= First( AGR.Test.HardCases.TestWords,
                      pair -> pair[1] = type[1] );
        if IsBound( r.( type[1] ) ) then
          if IsList( omit ) and name[2] in omit[2] then
            if verbose then
              Print( "#I  omit TestWords for ", type[1], " and ", name[2],
                     "\n" );
            fi;
          else
            for entry in r.( type[1] ) do
              result:= type[2].TestWords( tocid, name[2],
                           entry[ Length( entry ) ], type, verbose )
                       and result;
            od;
          fi;
        fi;
      od;

      # Check also the `maxext' scripts (which do not form a data type
      # and which are stored in the remote table of contents only).
      r:= AtlasTableOfContents( "remote" ).TableOfContents.( name[2] );
      if IsBound( r.maxext ) then
        for entry in r.maxext do
          prg:= AtlasProgram( name[1], entry[1], "maxes", entry[2] );
          if prg = fail then
            if verbose then
              Print( "#I  omit TestWords for maxext no. ", entry[2], " and ",
                     name[2], "\n" );
            fi;
          elif not IsInternallyConsistent( prg.program )  then
            Print( "#E  program `", entry[3],
                   "' not internally consistent\n" );
            result:= false;
          else
            # Get a representation if available, and map the generators.
            gens:= OneAtlasGeneratingSetInfo( prg.groupname,
                       prg.standardization, NrMovedPoints, [ 2 .. maxdeg ] );
            if gens = fail then
              if verbose then
                Print( "#I  no perm. repres. for `", prg.groupname,
                       "', no check for `", entry[3], "'\n" );
              fi;
            else
              gens:= AtlasGenerators( gens );
              grp:= Group( gens.generators );
              if IsBound( gens.size ) then
                SetSize( grp, gens.size );
              fi;
              gens:= ResultOfStraightLineProgram( prg.program,
                         gens.generators );
              size:= Size( SubgroupNC( grp, gens ) );
              if IsBound( prg.size ) and size <> prg.size then
                Print( "#E  program `", entry[3], "' for group of order ",
                       size, " not ", prg.size, "\n" );
                result:= false;
              fi;
            fi;
          fi;
        od;
      fi;

    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.FileHeaders( [<tocid>[,<groupname>]] )
##
##  <#GAPDoc Label="test:AGR.Test.FileHeaders">
##  <Mark><C>AGR.Test.FileHeaders( [<A>tocid</A>] )</C></Mark>
##  <Item>
##    checks whether all &MeatAxe; text format data files in the directory
##    with identifier <A>tocid</A> have a header line that is consistent with
##    the filename, and whether the contents of all &GAP; format data files
##    in this directory is consistent with the contents of the file.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.FileHeaders:= function( arg )
    local result, toc, record, type, entry, test, triple;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 2 then

      toc:= AtlasTableOfContents( arg[1] );
      if toc = fail then
        # No test is reasonable.
        return true;
      fi;
      toc:= toc.TableOfContents;
      if IsBound( toc.( arg[2] ) ) then
        record:= toc.( arg[2] );
        for type in AGR.DataTypes( "rep" ) do
          if IsBound( record.( type[1] ) ) then
            for entry in record.( type[1] ) do
              test:= type[2].TestFileHeaders( arg[1], arg[2], entry, type );
              if not IsBool( test ) then
                Print( "#E  ", test, " for ", entry[ Length( entry ) ],
                       "\n" );
                test:= false;
              fi;
              result:= test and result;
            od;
          fi;
        od;
      fi;

    elif Length( arg ) = 1 then

      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AGR.Test.FileHeaders( arg[1], triple[3] ) and result;
      od;

    elif Length( arg ) = 0 then
      result:= AGR.Test.FileHeaders( "local" );
    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.BinaryFormat( [<tocid>] )
##
##  <#GAPDoc Label="test:AGR.Test.BinaryFormat">
##  <Mark><C>AGR.Test.BinaryFormat( [<A>tocid</A>] )</C></Mark>
##  <Item>
##    checks whether all &MeatAxe; text format data files in the directory
##    with identifier <A>tocid</A> satisfy that applying first
##    <Ref Func="CMtxBinaryFFMatOrPerm"/> and then
##    <Ref Func="FFMatOrPermCMtxBinary"/> yields the same object.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.BinaryFormat:= function( arg )
    local tmpfile, tocid, result, r, gens, gen, test, cnv;

    # Create one temporary file.
    tmpfile:= Filename( DirectoryTemporary(), "testfile" );

    # Get the data directory.
    if IsEmpty( arg ) then
      tocid:= "local";
    else
      tocid:= arg[1];
    fi;

    result:= true;

    for r in Concatenation( AllAtlasGeneratingSetInfos( "contents", tocid,
                                IsPermGroup, true ),
                            AllAtlasGeneratingSetInfos( "contents", tocid,
                                Characteristic, IsPosInt ) ) do
      gens:= AtlasGenerators( r );
      if gens <> fail then
        gens:= gens.generators;
        for gen in gens do
          test:= false;
          if IsPerm( gen ) then
            CMtxBinaryFFMatOrPerm( gen, LargestMovedPoint( gen ), tmpfile );
            test:= true;
          elif IsMatrix( gen ) then
            cnv:= ConvertToMatrixRep( gen );
            if IsInt( cnv ) then
              CMtxBinaryFFMatOrPerm( gen, cnv, tmpfile );
              test:= true;
            fi;
          else
            Print( "#E  not permutation or matrix for ", r, "\n" );
            test:= false;
            result:= false;
          fi;
          if test and gen <> FFMatOrPermCMtxBinary( tmpfile ) then
            Print( "#E  AGR.Test.BinaryFormat: differences for `", r,
                   "'\n" );
            result:= false;
          fi;
        od;
      fi;
    od;

    # Remove the temporary file.
    RemoveFile( tmpfile );

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.Standardization( [<gapname>] )
##
##  <#GAPDoc Label="test:AGR.Test.Standardization">
##  <Mark><C>AGR.Test.Standardization()</C></Mark>
##  <Item>
##    checks whether all generating sets corresponding to the same set of
##    standard generators have the same element orders; for the case that
##    straight line programs for computing certain class representatives are
##    available, also the orders of these representatives are checked
##    w.&nbsp;r.&nbsp;t.&nbsp;all generating sets.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.Standardization:= function( arg )
    local result, name, gapname, gensorders, cclorders, cycorders, tbl, info,
          gens, std, ords, pair, prg, names, choice;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 0 then

      for name in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AGR.Test.Standardization( name[1] ) and result;
      od;

    elif Length( arg ) = 1 and IsString( arg[1] ) then

      gapname:= arg[1];
      if AGR.InfoForName( gapname ) = fail then
        Print( "#E  AGR.Test.Standardization: no group with GAP name `",
               gapname, "'\n" );
        return false;
      fi;

      gensorders:= [];
      cclorders:= [];
      cycorders:= [];

      tbl:= CharacterTable( gapname );

      # Loop over the relevant representations.
      for info in AllAtlasGeneratingSetInfos( gapname ) do
        gens:= AtlasGenerators( info.identifier );
        std:= gens.standardization;

        # Check that the generators are invertible,
        # and that the orders are equal in all representations.
        if ForAll( gens.generators, x -> Inverse( x ) <> fail ) then
          ords:= List( gens.generators, Order );
        else
          ords:= [ fail ];
        fi;
        if not ForAll( ords, IsInt ) then
          Print( "#E  representation `", gens.identifier[2],
                 "': non-finite order\n" );
          result:= false;
        elif IsBound( gensorders[ std+1 ] ) then
          if gensorders[ std+1 ] <> ords then
            Print( "#E  '", gapname, "': representation '",
                   gens.identifier[2],
                   "':\n#E  incompatible generator orders ",
                   ords, " and ", gensorders[ std+1 ], "\n" );
            result:= false;
          fi;
        else
          gensorders[ std+1 ]:= ords;
        fi;

        # If scripts for computing representatives of cyclic subgroups
        # or representatives of conjugacy classes are available
        # then check that their orders are equal in all representations.
        for pair in [ [ cclorders, "classes" ], [ cycorders, "cyclic" ] ] do
          if not IsBound( pair[1][ std+1 ] ) then
            prg:= AtlasProgram( gapname, std, pair[2] );
            if prg = fail then
              pair[1][ std+1 ]:= fail;
            else
              pair[1][ std+1 ]:= [ prg.program,
                                   List( ResultOfStraightLineProgram(
                                     prg.program, gens.generators ), Order ) ];
              if tbl <> fail then
                names:= AtlasClassNames( tbl );
                if IsBound( prg.outputs ) then
                  choice:= List( prg.outputs, x -> Position( names, x ) );
                  if ( not fail in choice ) and pair[1][ std+1 ][2]
                         <> OrdersClassRepresentatives( tbl ){ choice } then
                    Print( "#E  '", gapname, "': representation '",
                           gens.identifier[2], "':\n#E  ", pair[2],
                           " orders differ from character table\n" );
                    result:= false;
                  fi;
                else
                  Print( "#E  no component `outputs' in `", pair[2],
                         "' for `", gapname, "'\n" );
                fi;
              fi;
            fi;
          elif pair[1][ std+1 ] <> fail then
            if pair[1][ std+1 ][2] <> List( ResultOfStraightLineProgram(
                   pair[1][ std+1 ][1], gens.generators ), Order ) then
              Print( "#E  '", gapname, "': representation '",
                     gens.identifier[2],
                     "':\n#E  incompatible ", pair[2], " orders\n" );
              result:= false;
            fi;
          fi;
        od;
      od;

    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.StdTomLib( [<gapname>] )
##
##  <#GAPDoc Label="test:AGR.Test.StdTomLib">
##  <Mark><C>AGR.Test.StdTomLib()</C></Mark>
##  <Item>
##    checks whether the standard generators are compatible with those that
##    occur in the <Package>TomLib</Package> package.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.StdTomLib:= function( arg )
    local result, name, tomnames, tbl, tom, gapname, info, allgens, stdavail,
          verified, falsified, G, i, type, prg, res, gens, G2,
          fitstotom, fitstohom;

    if TestPackageAvailability( "TomLib", "1.0" ) <> true then
      Print( "#E  TomLib not loaded, cannot verify ATLAS standardizations\n" );
      return false;
    fi;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 0 then

      for name in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AGR.Test.StdTomLib( name[1] ) and result;
      od;

      # Check also that all tables of marks which provide a standardization
      # info with an `ATLAS' component belong to ATLAS groups.
#T ... with a `standardization' component ...
      tomnames:= Set( List( Filtered( LIBTOMKNOWN.STDGEN, x -> x[2] <> "N" ),
                            x -> x[1] ) );
      for name in AtlasOfGroupRepresentationsInfo.GAPnames do
        tbl:= CharacterTable( name[1] );
        if tbl <> fail then
          tom:= TableOfMarks( tbl );
          if tom <> fail then
            RemoveSet( tomnames, Identifier( tom ) );
          fi;
        fi;
      od;

      if not IsEmpty( tomnames ) then
        Print( "#E  cannot verify ATLAS standardizations for tables of ",
               "marks in ", tomnames, "\n" );
        result:= false;
      fi;

    elif Length( arg ) = 1 and IsString( arg[1] ) then

      gapname:= arg[1];
      if AGR.InfoForName( gapname ) = fail then
        Print( "#E  AGR.Test.Standardization: no group with GAP name `",
               gapname, "'\n" );
        return false;
      fi;

      tbl:= CharacterTable( gapname );

      # Check the ATLAS standardization against the TomLib standardization.
      # (We consider only ATLAS permutation representations.)
      if tbl = fail then
        tom:= fail;
      else
        tom:= TableOfMarks( tbl );
      fi;
      if tom <> fail then

        if HasStandardGeneratorsInfo( tom ) then
          info:= StandardGeneratorsInfo( tom )[1];
#T can be a longer list???
        else
          info:= fail;
        fi;

        allgens:= AllAtlasGeneratingSetInfos( gapname, IsPermGroup, true );
        stdavail:= Set( List( allgens, x -> x.standardization ) );
        allgens:= List( stdavail,
                        i -> First( allgens, x -> x.standardization = i ) );

        verified:= [];
        falsified:= [];
        G:= UnderlyingGroup( tom );

        # Apply `pres' and `check' scripts to the TomLib generators.
        for i in stdavail do
          for type in [ "pres", "check" ] do
            prg:= AtlasProgram( gapname, i, type );
            if prg <> fail then
              res:= ResultOfStraightLineDecision( prg.program,
                        GeneratorsOfGroup( G ) );
              if res = true then
                AddSet( verified, i );
                if info = fail then
                  Print( "#I  ", gapname,
                         ": extend TomLib standardization info, ",
                         "standardization = ", i, "\n" );
                elif IsBound( info.standardization ) and
                     info.standardization <> i then
                  Print( "#E  ", gapname,
                         ": set TomLib standardization info to ",
                         i, " not ", info.standardization, "\n" );
                  result:= false;
                fi;
              else
                AddSet( falsified, i );
                if info <> fail and IsBound( info.standardization )
                                and info.standardization = i then
                  Print( "#E  ", gapname,
                         ": TomLib standardization info is not ",
                         info.standardization, "\n" );
                  result:= false;
                fi;
              fi;
            fi;
          od;
        od;

        if info <> fail then
          # Compare the ATLAS generators with the TomLib standardization.
          for gens in allgens do
            gens:= AtlasGenerators( gens.identifier );
if info.script = fail then
  Print( "#E  ", gapname, ": fail script in TomLib standardization\n" );
else
            G2:= Group( gens.generators );
            fitstotom:= IsStandardGeneratorsOfGroup( info, G2, gens.generators );
            fitstohom:= GroupHomomorphismByImages( G, G2, GeneratorsOfGroup( G ), gens.generators ) <> fail;
            if fitstotom <> fitstohom then
              Print( "#E  ", gapname, ": IsStandardGeneratorsOfGroup and homom. construction for standardization ", gens.standardization, " inconsistent\n" );
            fi;

            if fitstotom then
              AddSet( verified, gens.standardization );
              if IsBound( info.standardization ) then
                if info.standardization <> gens.standardization then
                  Print( "#I  ", gapname,
                         ": TomLib standardization is ",
                         gens.standardization, " not ", info.standardization,
                         "\n" );
                  result:= false;
                fi;
              else
                Print( "#I  ", gapname,
                       ": TomLib standardization is ",
                       gens.standardization, "\n" );
              fi;
            else
              AddSet( falsified, gens.standardization );
              if IsBound( info.standardization ) and info.standardization = gens.standardization then
                Print( "#E  ", gapname,
                       ": TomLib standardization is not ",
                       info.standardization, "\n" );
              fi;
            fi;
fi;
          od;
        elif not IsEmpty( stdavail ) then
          Print( "#I  ", gapname, ": extend STDGEN info\n" );
        fi;

        if verified = [] and falsified = stdavail then
          if info = fail then
            Print( "#I  ", gapname,
                   ": extend TomLib standardization info, ",
                   "ATLAS = \"N\"\n" );
          elif info.ATLAS = true then
            Print( "#E  ", gapname,
                   ": TomLib standardization info must be ATLAS = \"N\"\n" );
          fi;
        elif info <> fail and info.ATLAS = false then
          Print( "#E  ", gapname,
                 ": cannot verify TomLib info ATLAS = \"N\"\n" );
        fi;

      fi;

    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.Files( [<tocid>[, <groupname>]] )
##
##  <#GAPDoc Label="test:AGR.Test.Files">
##  <Mark><C>AGR.Test.Files( [<A>tocid</A>] )</C></Mark>
##  <Item>
##    checks whether the &MeatAxe; text files that are stored in the
##    directory with identifier <A>tocid</A> can be read with
##    <Ref Func="ScanMeatAxeFile"/> such that the result is not <K>fail</K>.
##    The function does not check whether the first line of a &MeatAxe; text
##    file is consistent with the filename, since this can be tested with
##    <C>AGR.Test.FileHeaders</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.Files:= function( arg )
    local result, toc, record, type, entry, triple;

    # Initialize the result.
    result:= true;

    if IsEmpty( arg ) then
      result:= AGR.Test.Files( "local" );
    elif Length( arg ) = 1 then
      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AGR.Test.Files( arg[1], triple[3] ) and result;
      od;
    elif Length( arg ) = 2 then
      toc:= AtlasTableOfContents( arg[1] );
      if toc = fail then
        return false;
      fi;
      toc:= toc.TableOfContents;
      if IsBound( toc.( arg[2] ) ) then
        record:= toc.( arg[2] );
        for type in AGR.DataTypes( "rep" ) do
          if IsBound( record.( type[1] ) ) then
            for entry in record.( type[1] ) do
              result:= type[2].TestFiles( arg[1], arg[2], entry, type )
                       and result;
            od;
          fi;
        od;
      fi;
    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.ClassScripts( [<groupname>] )
##
##  <#GAPDoc Label="test:AGR.Test.ClassScripts">
##  <Mark><C>AGR.Test.ClassScripts()</C></Mark>
##  <Item>
##    checks whether the straight line programs that compute representatives
##    of certain conjugacy classes are consistent with information stored on
##    the &GAP; character table of the group in question, in the sense that
##    the given class names really occur in the character table and that
##    the element orders and centralizer orders for the classes are correct.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.ClassScripts:= function( arg )
    local result, maxdeg, groupname, gapname, toc, record, std, name, prg,
          tbl, outputs, ident, classnames, map, gens, roots, grp, reps,
          orders1, orders2, cents1, cents2, triple, pos, pos2, cycscript;

    # Initialize the result.
    result:= true;
    maxdeg:= AGR.Test.MaxTestDegree;

    if Length( arg ) = 1 and IsString( arg[1] ) then

      groupname:= arg[1];
      gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                       pair -> pair[2] = groupname );
      if gapname = fail then
        Print( "#E  no group with name `", groupname, "'\n" );
        return false;
      fi;
      gapname:= gapname[1];
      toc:= AtlasTableOfContents( "local" );
      if toc = fail then
        return false;
      fi;
      toc:= toc.TableOfContents;
#T admit also private tables of contents!
      if IsBound( toc.( groupname ) ) then
        record:= toc.( groupname );
        for name in [ "cyclic", "classes", "cyc2ccl" ] do
          if IsBound( record.( name ) ) then
            for std in Set( List( record.( name ), x -> x[1] ) ) do

              prg:= AtlasProgram( gapname, std, name );
              if prg = fail then
                Print( "#E  inconsistent program `", name, "' for `",
                       gapname, "'\n" );
                result:= false;
              else

                # Fetch the character table of the group.
                # (No further tests are possible if it is not available.)
                tbl:= CharacterTable( gapname );
                if tbl <> fail then

                  ident:= prg.identifier[2];
                  classnames:= AtlasClassNames( tbl );
                  if IsBound( prg.outputs ) then
                    outputs:= prg.outputs;
                    map:= List( outputs, x -> Position( classnames, x ) );
                  else
                    Print( "#E  no component `outputs' in `", name,
                           "' for `", gapname, "'\n" );
                    result:= false;
                    outputs:= [ "-" ];
                    map:= [ fail ];
                  fi;
                  prg:= prg.program;

                  # (If `-' signs occur then we cannot test the names,
                  # but the number of outputs can be checked.)
                  roots:= ClassRoots( tbl );
                  roots:= Filtered( [ 1 .. Length( roots ) ],
                                    i -> IsEmpty( roots[i] ) );
                  roots:= Set( List( roots, x -> ClassOrbit( tbl, x ) ) );

                  if ForAll( outputs, x -> not '-' in x ) then

                    # Check the class names.
                    if fail in map then
                      Print( "#E  strange class names ",
                             Difference( outputs, classnames ),
                             " for `dataword/", ident, "'\n" );
                      result:= false;
                    fi;
                    if     name in [ "classes", "cyc2ccl" ]
                       and Set( classnames ) <> Set( outputs ) then
                      Print( "#E  class names ",
                             Difference( classnames, outputs ),
                             " not hit for `dataword/", ident, "'\n" );
                      result:= false;
                    fi;
                    if name = "cyclic" then
                      # Check whether all maximally cyclic subgroups
                      # are covered.
                      roots:= Filtered( roots,
                                 list -> IsEmpty( Intersection( outputs,
                                             classnames{ list } ) ) );
                      if not IsEmpty( roots ) then
                        Print( "#E  maximally cyclic subgroups ",
                               List( roots, x -> classnames{ x } ),
                               " not hit for `dataword/", ident, "'\n" );
                        result:= false;
                      fi;
                    fi;

                  elif name = "cyclic" and
                       Length( outputs ) <> Length( roots ) then
                    Print( "#E  no. of outputs and cyclic subgroups differ",
                           " for `dataword/", ident, "'\n" );
                  fi;

                  if not fail in map then

                    # Compute the representatives in a representation.
                    # (No further tests are possible if none is available.)
                    gens:= OneAtlasGeneratingSetInfo( gapname, std,
                               NrMovedPoints, [ 2 .. maxdeg ] );
                    if gens <> fail then

                      gens:= AtlasGenerators( gens.identifier );
                      if gens <> fail then
                        gens:= gens.generators;
                      fi;
                      if fail in gens then
                        gens:= fail;
                      fi;

                      if not name in [ "cyclic", "classes" ] then

                        # The input consists of the images of the standard
                        # generators under the `cyc' script.
                        pos:= Position( ident, '-' ) - 1;
                        pos2:= pos;
                        while ident[ pos2 ] <> 'W' do
                          pos2:= pos2 - 1;
                        od;
                        cycscript:= Concatenation( groupname, "G",
                                        String( std ), "-cycW",
                                        ident{ [ pos2+1 .. pos ] } );
                        cycscript:= AtlasProgram(
                            [ gapname, cycscript, std ] );
                        if cycscript = fail then
                          gens:= fail;
                          Print( "#E  no script `", cycscript,
                                 "' available\n" );
                          result:= false;
                        else
                          gens:= ResultOfStraightLineProgram(
                                     cycscript.program, gens );
                        fi;
                      fi;

                    fi;

                    if gens <> fail then

                      grp:= Group( gens );
                      reps:= ResultOfStraightLineProgram( prg, gens );

                      if Length( reps ) <> Length( outputs ) then

                        Print( "#E  inconsistent output numbers for ",
                               "`dataword/", ident, "'\n" );
                        result:= false;

                      else

                        # Check element orders and centralizer orders.
                        orders1:= OrdersClassRepresentatives( tbl ){ map };
                        orders2:= List( reps, Order );
                        if orders1 <> orders2 then
                          Print( "#E  element orders of ",
                              outputs{ Filtered( [ 1 .. Length( outputs ) ],
                                           i -> orders1[i] <> orders2[i] ) },
                              " differ for `dataword/", ident, "'\n" );
                          result:= false;
                        fi;
                        cents1:= SizesCentralizers( tbl ){ map };
                        cents2:= List( reps, x -> Size( Centralizer(grp,x) ) );
                        if    cents1 <> cents2 then
                          Print( "#E  centralizer orders of ",
                              outputs{ Filtered( [ 1 .. Length( outputs ) ],
                                           i -> cents1[i] <> cents2[i] ) },
                              " differ for `dataword/", ident, "'\n" );
                          result:= false;
                        fi;

                      fi;

                    fi;

                  fi;

                fi;
              fi;

            od;
          fi;
        od;
      fi;

    elif IsEmpty( arg ) then
      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AGR.Test.ClassScripts( triple[3] ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.CycToCcls( [<groupname>] )
##
##  <#GAPDoc Label="test:AGR.Test.CycToCcls">
##  <Mark><C>AGR.Test.CycToCcls()</C></Mark>
##  <Item>
##    checks whether some straight line program that computes representatives
##    of conjugacy classes of a group can be computed from the ordinary
##    &GAP; character table of that group and a straight line program that
##    computes representatives of cyclic subgroups.
##    In this case the missing scripts are printed if the level of
##    <Ref InfoClass="InfoAtlasRep"/> is at least <M>1</M>.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.CycToCcls:= function( arg )
    local result, groupname, gapname, toc, tbl, record, datadirs, entry,
          tomatch, cyc2ccl, str, prg, triple;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 and IsString( arg[1] ) then

      groupname:= arg[1];
      gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                       pair -> pair[2] = groupname );
      if gapname = fail then
        Print( "#E  no group with name `", groupname, "'\n" );
        return false;
      fi;
      gapname:= gapname[1];
      toc:= AtlasTableOfContents( "local" );
      if toc = fail then
        return false;
      fi;
      toc:= toc.TableOfContents;

      # Fetch the character table of the group.
      # (No test is possible if it is not available.)
      tbl:= CharacterTable( gapname );
      if   tbl = fail then
        Print( "#I  no character table of `", gapname, "' is available\n" );
        return true;
      elif not IsBound( toc.( groupname ) ) then
        return true;
      fi;

      record:= toc.( groupname );
      if IsBound( record.cyclic ) then
        if IsBound( record.cyc2ccl ) then
          cyc2ccl:= List( record.cyc2ccl, x -> SplitString( x[2], "-" ) );
        else
          cyc2ccl:= [];
        fi;

        datadirs:= DirectoriesPackageLibrary( "atlasrep", "dataword" );

        for entry in record.cyclic do

          # Check the `cyc2ccl' scripts available.
          tomatch:= Filtered( entry[2], x -> x <> '-' );
          cyc2ccl:= Filtered( cyc2ccl, x -> x[1] = tomatch );
          if IsEmpty( cyc2ccl ) then

            # There is no `cyc2ccl' script but perhaps we can create it.
            str:= StringOfAtlasProgramCycToCcls(
                      StringFile( Filename( datadirs, entry[2] ) ),
                      tbl, "names" );
            if str <> fail then
              prg:= ScanStraightLineProgram( str, "string" );
              if prg = fail then
                Print( "#E  automatically created script for `", tomatch,
                       "-cclsW1' would be incorrect" );
              fi;
              prg:= prg.program;
#T check the composition?
              Print( "#I  add the following script, in the new file `",
                     tomatch, "-cclsW1':\n",
                     str, "\n" );
              result:= false;
            fi;

          fi;
        od;
      fi;

    elif IsEmpty( arg ) then
      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AGR.Test.CycToCcls( triple[3] ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  AGR.Test.GroupOrders( [true] )
##
##  <#GAPDoc Label="test:AGR.Test.GroupOrders">
##  <Mark><C>AGR.Test.GroupOrders()</C></Mark>
##  <Item>
##    checks whether the group orders stored in the <C>GAPnames</C> component
##    of <Ref Var="AtlasOfGroupRepresentationsInfo"/> coincide with the
##    group orders computed from an &ATLAS; permutation representation of
##    degree up to <C>AGR.Test.MaxTestDegree</C>,
##    from the character table or the table of marks with the given name,
##    or from the structure of the name.
##    Supported is a splitting of the name at the first dot (<C>.</C>),
##    where the two parts of the name are examined with the same criteria in
##    order to derive the group order.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.GroupOrders:= function( arg )
    local verbose, formats, maxdeg, SizesFromName, result, entry, size;

    verbose:= ( Length( arg ) <> 0 and arg[1] = true );

    formats:= [
      [ [ "L", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> Size( PSL( l[2], l[4] ) ) ],
      [ [ "2.L", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> 2 * Size( PSL( l[2], l[4] ) ) ],
      [ [ "S", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> Size( PSp( l[2], l[4] ) ) ],
      [ [ "2.S", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> 2 * Size( PSp( l[2], l[4] ) ) ],
      [ [ "U", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> Size( PSU( l[2], l[4] ) ) ],
    ];

    maxdeg:= AGR.Test.MaxTestDegree;

    SizesFromName:= function( name )
      local result, pair, parse, tbl, tom, flag, data, pos, size1, size2;

      result:= [];

      # Deal with the case of integers.
      if ForAll( name, x -> IsDigitChar( x ) or x = '^' ) then
#T improve: admit also brackets and '+' (problem of *matching* brackets)
        # No other criterion matches with this format, so we return.
        return [ EvalString( name ) ];
      fi;

      for pair in formats do
        parse:= ParseBackwards( name, pair[1] );
        if parse <> fail then
          AddSet( result, pair[2]( parse ) );
        fi;
      od;

      # Try to use the character table information.
      tbl:= CharacterTable( name );
      if tbl <> fail then
        AddSet( result, Size( tbl ) );
      fi;

      # Try to use the table of marks information.
      tom:= TableOfMarks( name );
      if tom <> fail then
        AddSet( result, Size( UnderlyingGroup( tom ) ) );
      fi;

      # Try to use the (locally available) database.
      flag:= AtlasOfGroupRepresentationsInfo.remote;
      AtlasOfGroupRepresentationsInfo.remote:= false;
      data:= OneAtlasGeneratingSetInfo( name,
                 NrMovedPoints, [ 1 .. maxdeg ] );
      AtlasOfGroupRepresentationsInfo.remote:= flag;
   #  if data = fail then
   #    data:= OneAtlasGeneratingSetInfo( name,
   #               Dimension, [ 1 .. 10 ] );
   #  fi;
      if data <> fail then
        data:= AtlasGenerators( data );
        if data <> fail then
          AddSet( result, Size( Group( data.generators ) ) );
        fi;
      fi;

      # Try to evaluate the name structure.
      pos:= Position( name, '.' );
#T improve: split also at ':'
      if pos <> fail then
        size1:= SizesFromName( name{ [ 1 .. pos-1 ] } );
        size2:= SizesFromName( name{ [ pos+1 .. Length( name ) ] } );
        if Length( size1 ) = 1 and Length( size2 ) = 1 then
          AddSet( result, size1[1] * size2[1] );
        elif Length( size1 ) > 1 or Length( size2 ) > 1 then
          Print( "#E  group orders: problem with `", name, "'\n" );
        fi;
      fi;

      return result;
    end;

    result:= true;

    for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
      size:= SizesFromName( entry[1] );
      if 1 < Length( size ) then
        Print( "#E  AGR.Test.GroupOrders: several group orders for `",
               entry[1], "':\n#E  ", size, "\n" );
        result:= false;
      elif not IsBound( entry[3].size ) then
        if Length( size ) = 0 then
          if verbose then
            Print( "#I  AGR.Test.GroupOrders: group order for `", entry[1],
                   "' unknown\n" );
          fi;
        else
          entry[3].size:= size[1];
          Print( "#I  AGR.Test.GroupOrders: set group order for `", entry[1],
                 "'\n",
                 "AGR.GRS(\"", entry[1], "\",", size[1], ");\n" );
        fi;
      elif Length( size ) = 0 then
        if verbose then
          Print( "#I  AGR.Test.GroupOrders: cannot verify group order for `",
                 entry[1], "'\n" );
        fi;
      elif size[1] <> entry[3].size then
        Print( "#E  AGR.Test.GroupOrders: wrong group order for `",
               entry[1], "'\n" );
        result:= false;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  AGR.IsKernelInFrattiniSubgroup( <tbl>, <factfus> )
##
##  We try to deduce the orders of maximal subgroups from those of factor
##  groups.
##  Namely, if <M>K</M> is a normal subgroup in <M>G</M> such that <M>K</M>
##  is contained in the Frattini subgroup <M>\Phi(G)</M> of <M>G</M>
##  (i. e., contained in any maximal subgroup of <M>G</M>)
##  then the maximal subgroups of <M>G</M> are exactly the preimages of the
##  maximal subgroups of <M>G/K</M> under the natural epimorphism.
##  <P/>
##  Since <M>G' \cap Z(G) \leq \Phi(G)</M>, this situation occurs in the case
##  of central extensions of perfect groups,
##  for example the orders of the maximal subgroups of <M>3.A_6</M> are
##  the orders of the maximal subgroups of <M>A_6</M>, multiplied by the
##  factor three.
##  <P/>
##  Since <M>\Phi(N) \leq \Phi(G)</M> holds for any normal subgroup <M>N</M>
##  of <M>G</M>
##  (see <Cite Key="Hup67" SubKey="Kap. III, §3, Hilfssatz 3.3 b)"/>),
##  this situation occurs in the case of upward extensions of central
##  extensions of perfect groups,
##  for example the orders of the maximal subgroups of <M>3.A_6.2_1</M> are
##  the orders of the maximal subgroups of <M>A_6.2_1</M>, multiplied by the
##  factor three.
##
AGR.IsKernelInFrattiniSubgroup:= function( tbl, factfus )
    local ker, nam, subtbl, subfus, subker;

    # Compute the kernel <M>K</M> of the epimorphism.
    ker:= ClassPositionsOfKernel( factfus.map );
    if Length( ker ) = 1 or not
       IsSubset( ClassPositionsOfDerivedSubgroup( tbl ), ker ) then
      return false;
    elif IsSubset( ClassPositionsOfCentre( tbl ), ker ) then
      # We have <M>K \leq G' \cap Z(G)</M>,
      # so the maximal subgroups are exactly the preimages of the
      # maximal subgroups in the factor group.
      return true;
    fi;

    # Look for a suitable normal subgroup <M>N</M> of <M>G</M>.
    for nam in NamesOfFusionSources( tbl ) do
      subtbl:= CharacterTable( nam );
      subfus:= GetFusionMap( subtbl, tbl );
      if Size( subtbl ) = Sum( SizesConjugacyClasses( tbl ){
                                 Set( subfus ) } ) and
         IsSubset( subfus, ker ) then
        # <M>N</M> is normal in <M>G</M>, with <M>K \leq N</M>
        subker:= Filtered( [ 1 .. Length( subfus ) ],
                           i -> subfus[i] in ker );
        if IsSubset( ClassPositionsOfDerivedSubgroup( subtbl ),
                   subker ) and
             IsSubset( ClassPositionsOfCentre( subtbl ), subker ) then
          # We have <M>K \leq N' \cap Z(N)</M>.
          return true;
        fi;
      fi;
    od;

    return false;
    end;


#############################################################################
##
#F  AGR.Test.MaxesOrders( [true] )
##
##  <#GAPDoc Label="test:AGR.Test.MaxesOrders">
##  <Mark><C>AGR.Test.MaxesOrders()</C></Mark>
##  <Item>
##    checks whether the orders of maximal subgroups stored in the component
##    <C>GAPnames</C> of <Ref Var="AtlasOfGroupRepresentationsInfo"/>
##    coincide with the orders computed from the restriction of an &ATLAS;
##    permutation representation of degree up to
##    <C>AGR.Test.MaxTestDegree</C>,
##    from the character table, or the table of marks with the given name,
##    or from the information about maximal subgroups of a factor group
##    modulo a normal subgroup that is contained in the Frattini subgroup.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.MaxesOrders:= function( arg )
    local verbose, maxdeg, maxmax, MaxesInfoForName, result, toc, entry,
          info, size, struct;

    verbose:= ( Length( arg ) <> 0 and arg[1] = true );
    maxdeg:= AGR.Test.MaxTestDegree;
    maxmax:= AGR.Test.HardCases.MaxNumberMaxes;

    MaxesInfoForName:= function( name )
      local result, nrmaxes, tbl, oneresult, i,
            subtbl, tom, std, data, prg, gens, factfus, recurs, good;

      result:= [];
      nrmaxes:= [];

      # Try to use the character table information.
      tbl:= CharacterTable( name );
      if tbl <> fail then
        if HasMaxes( tbl ) then
          AddSet( nrmaxes, Length( Maxes( tbl ) ) );
          AddSet( result, List( Maxes( tbl ),
                                 nam -> Size( CharacterTable( nam ) ) ) );
        else
          # Try whether individual maxes are supported.
          oneresult:= [];
          if tbl <> fail then
            for i in [ 1 .. maxmax ] do
              subtbl:= CharacterTable( Concatenation( Identifier( tbl ), "M",
                                                      String( i ) ) );
              if subtbl <> fail then
                oneresult[i]:= Size( subtbl );
              fi;
            od;
          fi;
          if not IsEmpty( oneresult ) then
            AddSet( result, oneresult );
          fi;
        fi;
      fi;

      # Try to use the table of marks information.
# more tests: how to identify FusionsToLibTom( tom )?
      tom:= TableOfMarks( name );
      if tom <> fail then
        AddSet( nrmaxes, Length( MaximalSubgroupsTom( tom )[1] ) );
        AddSet( result, Reversed( SortedList( OrdersTom( tom ){
                             MaximalSubgroupsTom( tom )[1] } ) ) );
      fi;

      # Try to use the database.
      for std in [ 1 .. AGR.Test.HardCases.MaxNumberStd ] do
        data:= OneAtlasGeneratingSetInfo( name, std,
                                          NrMovedPoints, [ 1 .. maxdeg ] );
     #  if data = fail then
     #    data:= OneAtlasGeneratingSetInfo( name, std,
     #               Dimension, [ 1 .. 10 ] );
     #  fi;
        if data <> fail then
          data:= AtlasGenerators( data );
          if data <> fail then
            oneresult:= [];
            for i in [ 1 .. maxmax ] do
              prg:= AtlasProgram( name, std, "maxes", i );
              if prg <> fail then
                gens:= ResultOfStraightLineProgram( prg.program,
                                                    data.generators );
                oneresult[i]:= Size( Group( gens ) );
              fi;
            od;
            if not IsEmpty( oneresult ) then
              AddSet( result, oneresult );
            fi;
          fi;
        fi;
      od;

      # Try to deduce the orders of maximal subgroups from those of factors.
      if tbl <> fail then
        for factfus in ComputedClassFusions( tbl ) do
          if AGR.IsKernelInFrattiniSubgroup( tbl, factfus ) then
            recurs:= MaxesInfoForName( factfus.name );
            UniteSet( nrmaxes, recurs.nrmaxes );
            UniteSet( result,
              recurs.maxesorders * Sum( SizesConjugacyClasses( tbl ){
                  ClassPositionsOfKernel( factfus.map ) } ) );
          fi;
        od;
      fi;

      # Compact the partial results.
      good:= true;
      for oneresult in result{ [ 2 .. Length( result ) ] } do
        for i in [ 1 .. Length( oneresult ) ] do
          if   IsBound( result[1][i] ) then
            if IsBound( oneresult[i] ) then
              if result[1][i] <> oneresult[i] then
                good:= false;
              fi;
            fi;
          elif IsBound( oneresult[i] ) then
            result[1][i]:= oneresult[i];
          fi;
        od;
      od;
      if good and not IsEmpty( result ) then
        result:= [ result[1] ];
      fi;

      return rec( maxesorders:= result,
                  nrmaxes:= Set( nrmaxes ) );
    end;

    result:= true;
    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents.remote;

    for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
      info:= MaxesInfoForName( entry[1] );

      if not IsBound( entry[3].nrMaxes ) then
        if Length( info.nrmaxes ) = 1 then
          Print( "#I  AGR.MXN: set maxes number for `", entry[1], "':\n",
                 "AGR.MXN(\"", entry[1], "\",", info.nrmaxes[1], ");\n" );
        fi;
      elif Length( info.nrmaxes ) <> 1 then
        if verbose then
          Print( "#I  AGR.MXN: cannot verify stored maxes number ",
                 "for `", entry[1], "'\n" );
        fi;
      fi;

      size:= info.maxesorders;
      if 1 < Length( size ) then
        Print( "#E  AGR.Test.MaxesOrders: several maxes orders for `",
               entry[1], "':\n#E  ", size, "\n" );
        result:= false;
      elif not IsBound( entry[3].sizesMaxes )
           or IsEmpty( entry[3].sizesMaxes ) then
        # No maxes orders are stored yet.
        if Length( size ) = 0 then
          if verbose or ( IsBound( toc.( entry[2] ) ) and
                          IsBound( toc.( entry[2] ).maxes ) and
                          not IsEmpty( toc.( entry[2] ).maxes ) ) then
            Print( "#I  AGR.Test.MaxesOrders: maxes orders for `", entry[1],
                   "' unknown\n" );
          fi;
        else
          if IsBound( entry[3].size ) then
            if entry[3].size in size[1] then
              Print( "#E  AGR.Test.MaxesOrders: group order in maxes ",
                     "orders list for `", entry[1], "'\n" );
              result:= false;
            fi;
            if ForAny( size[1], x -> entry[3].size mod x <> 0 ) then
              Print( "#E  AGR.Test.MaxesOrders: strange subgp. order for `",
                     entry[1], "'\n" );
              result:= false;
            fi;
          fi;
          if IsSortedList( - Compacted( size[1] ) ) then
            entry[3].sizesMaxes:= size[1];
            Print( "#I  AGR.Test.MaxesOrders: set maxes orders for `",
                   entry[1], "':\n" );
            Print( "AGR.MXO(\"", entry[1], "\",",
                   Filtered( String( size[1] ), x -> x <> ' ' ), ");\n" );
          else
            Print( "#E  AGR.Test.MaxesOrders: computed maxes orders for `",
                   entry[1], "' are not sorted:\n", size[1], "\n" );
          fi;
        fi;
      elif Length( size ) = 0 then
        if verbose then
          Print( "#I  AGR.Test.MaxesOrders: cannot verify stored ",
                 "maxes orders for `", entry[1], "'\n" );
        fi;
      elif not IsSortedList( - Compacted( size[1] ) ) then
        Print( "#E  AGR.Test.MaxesOrders: computed maxes orders for `",
               entry[1], "' are not sorted:\n", size[1], "\n" );
      elif size[1] <> entry[3].sizesMaxes then
        Print( "#E  AGR.Test.MaxesOrders: computed and stored ",
               "maxes orders for `", entry[1], "' differ:\n" );
        Print( "#E  ", size[1], " vs. ", entry[3].sizesMaxes, "\n" );
        result:= false;
      fi;

    od;

    return result;
    end;


#############################################################################
##
#F  AGR.Test.MaxesStructure( [true] )
##
##  <#GAPDoc Label="test:AGR.Test.MaxesStructure">
##  <Mark><C>AGR.Test.MaxesStructure()</C></Mark>
##  <Item>
##    checks whether the names of maximal subgroups stored in the component
##    <C>GAPnames</C> of <Ref Var="AtlasOfGroupRepresentationsInfo"/>
##    coincide with the names computed from the &GAP; character table with
##    the given name.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.MaxesStructure:= function( arg )
    local verbose, maxdeg, maxmax, MaxesInfoForName, result, toc, entry,
          info, size, struct;

    verbose:= ( Length( arg ) <> 0 and arg[1] = true );
    maxdeg:= AGR.Test.MaxTestDegree;
    maxmax:= AGR.Test.HardCases.MaxNumberMaxes;

    MaxesInfoForName:= function( name )
      local result, tbl, oneresult, i,
            subtbl, tom, std, data, prg, gens, factfus, recurs, good;

      result:= [];

      # Try to use the character table information.
      tbl:= CharacterTable( name );
      if tbl <> fail then
        if HasMaxes( tbl ) then
          AddSet( result,
              List( Maxes( tbl ),
                    AGR.StructureDescriptionCharacterTableName ) );
        else
          # Try whether individual maxes are supported.
          oneresult:= [];
          if tbl <> fail then
            for i in [ 1 .. maxmax ] do
              subtbl:= CharacterTable( Concatenation( Identifier( tbl ), "M",
                                                      String( i ) ) );
              if subtbl <> fail then
                oneresult[i]:= AGR.StructureDescriptionCharacterTableName(
                                    Identifier( subtbl ) );
              fi;
            od;
          fi;
          if not IsEmpty( oneresult ) then
            AddSet( result, oneresult );
          fi;
        fi;
      fi;

      # Compact the partial results.
      good:= true;
      for oneresult in result{ [ 2 .. Length( result ) ] } do
        for i in [ 1 .. Length( oneresult ) ] do
          if   IsBound( result[1][i] ) then
            if IsBound( oneresult[i] ) then
              if result[1][i] <> oneresult[i] then
                good:= false;
              fi;
            fi;
          elif IsBound( oneresult[i] ) then
            result[1][i]:= oneresult[i];
          fi;
        od;
      od;
      if good and not IsEmpty( result ) then
        result:= [ result[1] ];
      fi;

      return rec( maxesstructure:= result );
    end;

    result:= true;
    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents.remote;

    for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
      info:= MaxesInfoForName( entry[1] );
      struct:= info.maxesstructure;
      if 1 < Length( struct ) then
        Print( "#E  AGR.Test.MaxesStructure: several maxes structures for `",
               entry[1], "':\n#E  ", struct, "\n" );
        result:= false;
      elif not IsBound( entry[3].structureMaxes ) then
        # No maxes structures are stored yet.
        if Length( struct ) = 0 then
          if verbose or ( IsBound( toc.( entry[2] ) ) and
                          IsBound( toc.( entry[2] ).maxes ) and
                          not IsEmpty( toc.( entry[2] ).maxes ) ) then
            Print( "#I  AGR.Test.MaxesStructure: maxes structures for `",
                   entry[1], "' unknown\n" );
          fi;
        elif Length( struct ) = 1 then
          Print( "#I  AGR.Test.MaxesStructure: set maxes structures for `",
                 entry[1], "':\n",
                 "AGR.MXS(\"", entry[1], "\",",
                 Filtered( String( struct[1] ), x -> x <> ' ' ), ");\n" );
        fi;
      elif Length( struct ) = 0 then
        if verbose then
          Print( "#I  AGR.Test.MaxesStructure: cannot verify stored ",
                 "maxes structures for `", entry[1], "'\n" );
        fi;
      elif struct[1] <> entry[3].structureMaxes then
        if ForAll( [ 1 .. Length( entry[3].structureMaxes ) ],
                   i -> ( not IsBound( entry[3].structureMaxes[i] ) ) or
                        ( IsBound( struct[1][i] ) and
                          entry[3].structureMaxes[i] = struct[1][i] ) ) then
          # New maximal subgroups were identified.
          Print( "#I  AGR.Test.MaxesStructure: replace maxes structures for `",
                 entry[1], "':\n",
                 "AGR.MXS(\"", entry[1], "\",",
                 Filtered( String( struct[1] ), x -> x <> ' ' ), ");\n" );
        else
          # There is really a contradiction.
          Print( "#E  AGR.Test.MaxesStructure: computed and stored ",
                 "maxes structures for `", entry[1], "' differ:\n" );
          Print( "#E  ", struct[1], " vs. ", entry[3].structureMaxes, "\n" );
          result:= false;
        fi;
      fi;

    od;

    return result;
    end;


#############################################################################
##
#F  AGR.Test.StdCompatibility( [[<entry>, ]<verbose>] )
##
##  <#GAPDoc Label="test:AGR.Test.StdCompatibility">
##  <Mark><C>AGR.Test.StdCompatibility()</C></Mark>
##  <Item>
##    checks whether the information about the compatibility of
##    standard generators of a group and its factor groups that is stored in
##    the <C>GAPnames</C> component of
##    <Ref Var="AtlasOfGroupRepresentationsInfo"/>
##    coincides with computed values.
##    <P/>
##    The following criterion is used for computing the value for a group
##    <M>G</M>.
##    Use the &GAP; Character Table Library to determine factor groups
##    <M>F</M> of <M>G</M> for which standard generators are defined and
##    moreover a presentation in terms of these standard generators is known.
##    Evaluate the relators of the presentation in the standard generators of
##    <M>G</M>, and let <M>N</M> be the normal closure of these elements in
##    <M>G</M>.
##    Then mapping the standard generators of <M>F</M> to the <M>N</M>-cosets
##    of the standard generators of <M>G</M> is an epimorphism.
##    If <M>|G/N| = |F|</M> holds then <M>G/N</M> and <M>F</M> are
##    isomorphic, and the standard generators of <M>G</M> and <M>F</M> are
##    compatible in the sense that mapping the standard generators of
##    <M>G</M> to their <M>N</M>-cosets yields standard generators of
##    <M>F</M>.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.StdCompatibility:= function( arg )
    local verbose, maxstd, CompInfoForEntry, result, entry, info, l;

    verbose:= ( Length( arg ) <> 0 and arg[ Length( arg ) ] = true );
    maxstd:= AGR.Test.HardCases.MaxNumberStd;

    CompInfoForEntry:= function( entry )
      local result, tbl, flag, fus, factstd, pres, std, gens, prg, res, ker,
            j, G, F, hom,
facttbl;

      result:= [];
      tbl:= CharacterTable( entry[1] );
      if tbl <> fail then
        flag:= AtlasOfGroupRepresentationsInfo.remote;
        AtlasOfGroupRepresentationsInfo.remote:= false;
        for fus in ComputedClassFusions( tbl ) do
          if 1 < Length( ClassPositionsOfKernel( fus.map ) ) then
            if AGR.InfoForName( fus.name ) <> fail then
              for factstd in [ 1 .. maxstd ] do
                pres:= AtlasProgram( fus.name, factstd, "presentation" );
                if pres <> fail then
                  # The two sets of generators are compatible iff the
                  # relators in terms of the generators of the big group
                  # generate the kernel of the epimorphism.
                  for std in [ 1 .. maxstd ] do
                    gens:= OneAtlasGeneratingSet( entry[1], std );
                    if gens <> fail then
                      prg:= StraightLineProgramFromStraightLineDecision(
                                pres.program );
                      res:= ResultOfStraightLineProgram( prg,
                                gens.generators );
                      ker:= Group( res );
                      # `ker' is assumed to be a very small group.
                      if Size( tbl ) / Size( CharacterTable( fus.name ) )
                         = Size( ker ) then
                        Add( result, [ std, fus.name, factstd, true ] );
                      else
                        Add( result, [ std, fus.name, factstd, false ] );
                      fi;
                    fi;
                  od;
                else
                  # Try to form the homomorphism object in GAP,
                  # by mapping generators of the big group to generators
                  # of the factor group.
                  # If this defines a homomorphism and if this is surjective
                  # then the generators are compatible.
                  for std in [ 1 .. maxstd ] do
facttbl:= CharacterTable( fus.name );
if ClassPositionsOfFittingSubgroup( facttbl ) = [1] then
# currently classes scripts are available only for these tables,
# so other cases are not really interesting at the moment ...
                    G:= AtlasGroup( entry[1], std, IsPermGroup, true );
                    F:= AtlasGroup( fus.name, factstd, IsPermGroup, true );
                    if G <> fail and F <> fail then
if NrMovedPoints( G ) <= AGR.Test.MaxTestDegree and NrMovedPoints( F ) <= AGR.Test.MaxTestDegree then
#Print( "#I trying hom. ", entry[1], " ->> ", fus.name, "\n" );
                      hom:= GroupHomomorphismByImages( G, F,
                                GeneratorsOfGroup( G ),
                                GeneratorsOfGroup( F ) );
                      if hom <> fail then
                        Add( result, [ std, fus.name, factstd, true ] );
                      else
                        Add( result, [ std, fus.name, factstd, false ] );
                      fi;
else
#Print( "#I omit hom. ", entry[1], " ->> ", fus.name, ", too many points ...\n" );
fi;
elif std = 1 and factstd = 1 then
#Print( "#I no hom. ", entry[1], " ->> ", fus.name, " to try?\n" );
                    fi;
fi;
                  od;
                fi;
              od;
            fi;
          fi;
        od;
        AtlasOfGroupRepresentationsInfo.remote:= flag;
      fi;
      return result;
    end;

    result:= true;

    if Length( arg ) = 0 or ( Length( arg ) = 1 and IsBool( arg[1] ) ) then
      for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AGR.Test.StdCompatibility( entry, verbose ) and result;
      od;
    else
      entry:= arg[1];
      info:= CompInfoForEntry( entry );
      if not IsBound( entry[3].factorCompatibility ) then
        entry[3].factorCompatibility:= [];
      fi;
      if info <> entry[3].factorCompatibility then
        if verbose then
          Print( "#I  AGR.Test.StdCompatibility: change compatibility info\n" );
          for l in info do
#T can be empty!
            Print( "AGR.STDCOMP(\"", entry[1], "\",",
                   Filtered( String( l ), x -> x <> ' ' ), ");\n" );
          od;
        fi;
      fi;
      if verbose then
        for l in Difference( entry[3].factorCompatibility, info ) do
          Print( "#I  AGR.Test.StdCompatibility: cannot verify compatibility ",
                 "info `", l, "' for `", entry[1], "'\n" );
        od;
      fi;

      if ForAny( entry[3].factorCompatibility, l1 -> ForAny( info,
           l2 -> l1{[1..3]} = l2{[1..3]} and ( l1[4] <> l2[4] ) ) ) then
        Print( "#E  AGR.Test.StdCompatibility: contradiction of ",
               "compatibility info for `", entry[1], "'\n" );
        result:= false;
      fi;
    fi;

    return result;
    end;


#############################################################################
##
#F  AGR.Test.CompatibleMaxes( [[<entry>, ]<verbose>] )
##
##  <#GAPDoc Label="test:AGR.Test.CompatibleMaxes">
##  <Mark><C>AGR.Test.CompatibleMaxes()</C></Mark>
##  <Item>
##    checks whether the information about deriving straight line programs
##    for restricting to subgroups from straight line programs that belong
##    to a factor group coincide with computed values.
##    <P/>
##    The following criterion is used for computing the value for a group
##    <M>G</M>.
##    If <M>F</M> is a factor group of <M>G</M> such that the standard
##    generators of <M>G</M> and <M>F</M> are compatible
##    (see the test function <C>AGR.Test.StdCompatibility</C>)
##    and if there are a presentation for <M>F</M> and a permutation
##    representation of <M>G</M> then it is checked whether the
##    <C>"maxes"</C> type straight line programs for <M>F</M> can be used to
##    compute generators for the maximal subgroups of <M>G</M>;
##    if not then generators of the kernel of the natural epimorphism from
##    <M>G</M> to <M>F</M>, must be added.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.CompatibleMaxes:= function( arg )
    local verbose, maxdeg, maxmax, CompMaxForEntry, result, toc, entry, info,
          stored, entry2, filt;

    verbose:= Length( arg ) <> 0 and arg[ Length( arg ) ] = true;
    maxdeg:= AGR.Test.MaxTestDegree;
    maxmax:= AGR.Test.HardCases.MaxNumberMaxes;

    CompMaxForEntry:= function( entry )
      local result, tbl, l, factname, factstd, gens, i, prg, max;

      result:= [];
      tbl:= CharacterTable( entry[1] );
      if tbl <> fail and IsBound( entry[3].sizesMaxes )
                     and IsBound( entry[3].factorCompatibility ) then
        # Maxes orders info and compatibility info are known.
        for l in Filtered( entry[3].factorCompatibility,
                           x -> x[4] = true ) do
          # Check whether the maxes of the two groups are in bijection.
          factname:= l[2];
          factstd:= l[3];
          if ForAny( ComputedClassFusions( tbl ),
                     fus -> fus.name = factname and
                            AGR.IsKernelInFrattiniSubgroup( tbl, fus ) ) then
            gens:= OneAtlasGeneratingSet( entry[1], l[1],
                                          NrMovedPoints, [ 1 .. maxdeg ] );
            if gens <> fail then
              for i in [ 1 .. maxmax ] do
                prg:= AtlasProgram( factname, factstd, "maxes", i );
                if prg <> fail and IsBound( entry[3].sizesMaxes[i] ) then
                  # try the program for the ext. gp.
                  max:= ResultOfStraightLineProgram( prg.program,
                            gens.generators );
                  max:= Group( max );
                  if Size( max ) = entry[3].sizesMaxes[i] then
                    # The program for the factor group is sufficient.
                    Add( result,
                         [ entry[2], factstd, i, [ prg.identifier[2] ] ] );
                  elif not IsBound( entry[3].kernelPrograms )
                       or ForAll( entry[3].kernelPrograms,
                                  x -> x[2] <> factname ) then

                    Print( "#I  SLP for kernel generators of ",
                           entry[1], " ->> ", factname, " missing ",
                           "\n#I  (needed for max. ", i, ")\n" );
                  fi;
                fi;
              od;
            fi;
          fi;
        od;
      fi;
      return result;
    end;

    result:= true;
    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents.remote;

    if Length( arg ) = 0 or ( Length( arg ) = 1 and IsBool( arg[1] ) ) then
      for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AGR.Test.CompatibleMaxes( entry, verbose ) and result;
      od;
    else
      entry:= arg[1];
      info:= CompMaxForEntry( entry );
      stored:= [];
      if IsBound( toc.( entry[2] ) ) and
         IsBound( toc.( entry[2] ).maxext ) then
        stored:= List( toc.( entry[2] ).maxext,
                       x -> Concatenation( [ entry[2] ], x ) );
      fi;
      for entry2 in info do
        filt:= Filtered( stored,
                         x ->     x{ [ 1 .. 3 ] } = entry2{ [ 1 .. 3 ] }
                              and x[4][1] = entry2[4][1] );
        if IsEmpty( filt ) then
          # The entry is new.
          if Length( entry2[4] ) = 1 then
            # The script for restricting the repres. of the factor group
            # is good enough for the group.
            Print( "#I  AGR.TOCEXT: set entry\nAGR.TOCEXT(\"", entry2[1],
                   "\",", entry2[2], ",", entry2[3], ",[\"",
                   entry2[4][1], "\"]);\n" );
          else
            # For restricting a repres. of the group, one needs the script
            # for the factor group plus some kernel elements.
            Print( "#I  AGR.TOCEXT: set entry\nAGR.TOCEXT(\"", entry2[1],
                   "\",", entry2[2], ",", entry2[3], ",[\"",
                   entry2[4][1], "\",\"", entry2[4][2], "\"]);\n" );
          fi;
        elif Length( entry2[4] ) <> Length( filt[1][4] ) then
          if Length( entry2[4] ) = 3 and Length( filt[1][4] ) = 2 then
            if entry2[4]{ [ 1, 2 ] } <> filt[1][4] then
              # We have already such an entry but it is different.
              Print( "#E  AGR.TOCEXT: difference ", entry2, " vs. ", filt[1],
                     "\n" );
              result:= false;
            fi;
#T check also equality of the script with a stored one if applicable!
          else
            # We have already such an entry but it is different.
            Print( "#E  AGR.TOCEXT: difference ", entry2, " vs. ", filt[1],
                   "\n" );
            result:= false;
          fi;
        fi;
      od;
      for entry2 in stored do
        filt:= Filtered( info,
                         x ->     x{ [ 1 .. 3 ] } = entry2{ [ 1 .. 3 ] }
                              and x[4][1] = entry2[4][1] );
        if IsEmpty( filt ) then
          Print( "#I  AGR.TOCEXT: cannot verify stored value ", entry2, "\n" );
        fi;
      od;
    fi;

    return result;
    end;


#############################################################################
##
#F  AGR.IsEquivalentSLP( <lines1>, <lines2> )
##
##  simpleminded function; eventually better evaluate standard generators
##  of the group in question
##
AGR.IsEquivalentSLP:= function( lines1, lines2 )
    local n, slp1, slp2, f, gens;

    if lines1 = lines2 then
      return true;
    fi;

    n:= 2;
    slp1:= StraightLineProgram( lines1, n );
    slp2:= StraightLineProgram( lines2, n );
    f:= FreeGroup( n );
    gens:= GeneratorsOfGroup( f );
    if ResultOfStraightLineProgram( slp1, gens )
       = ResultOfStraightLineProgram( slp2, gens ) then
      return true;
    else
      return false;
    fi;
    end;


#############################################################################
##
#F  AGR.Test.KernelGenerators( [[<entry>, ]<verbose>] )
##
##  <#GAPDoc Label="test:AGR.Test.KernelGenerators">
##  <Mark><C>AGR.Test.KernelGenerators()</C></Mark>
##  <Item>
##    checks whether the information stored in the <C>GAPnames</C> component
##    of <Ref Var="AtlasOfGroupRepresentationsInfo"/> about
##    straight line programs for computing generators of the kernels of
##    natural epimorphisms between &ATLAS; groups
##    coincides with computed values.
##    <P/>
##    The following criterion is used for computing the value for a group
##    <M>G</M>.
##    Use the &GAP; Character Table Library to determine factor groups
##    <M>F</M> of <M>G</M> for which standard generators are defined
##    such that mapping standard generators of <M>G</M> to those of
##    <M>F</M> defines a homomorphism, and such that a presentation of
##    <M>F</M> in terms of its standard generators is known.
##    Evaluating the relators of the presentation in the standard generators
##    of <M>G</M> yields normal subgroup generators for the kernel.
##    <P/>
##    A message is printed for each group name
##    for which some straight line program for computing kernel generators
##    was not stored but now was computed,
##    or for which the stored info cannot be verified,
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.KernelGenerators:= function( arg )
    local verbose, maxstd, CompInfoForEntry, result, pos, entry, new, old, i,
          l;

    verbose:= ( Length( arg ) <> 0 and arg[ Length( arg ) ] = true );
    maxstd:= AGR.Test.HardCases.MaxNumberStd;

    CompInfoForEntry:= function( entry )
      local result, info, std, factname, factstd, pres, gens, prg, res, ker,
            perm, words, kergens, sub, j, lines, G, F, hom, free, freegens,
            freestrs, iter, addprgs, w, ord, elm,
facttbl;

      result:= [];
      for info in Filtered( entry[3].factorCompatibility,
                            x -> x[4] = true ) do
#T compute kernel generators also in other cases?
#T where does this happen? and how do we get the homomorphism then?
        std:= info[1];
        factname:= info[2];
        factstd:= info[3];
        if AGR.InfoForName( factname ) <> fail then
          pres:= AtlasProgram( factname, factstd, "presentation" );
          if pres <> fail then
            # The two sets of generators are compatible.
            gens:= OneAtlasGeneratingSet( entry[1], std );
            if gens <> fail then
              prg:= StraightLineProgramFromStraightLineDecision(
                        pres.program );
              res:= ResultOfStraightLineProgram( prg, gens.generators );
              ker:= Group( res );
              # `ker' is assumed to be a very small group.
              # Create a script for generators of the kernel.
              perm:= Sortex( -List( res, Order ) );
              res:= Permuted( res, perm );
              words:= Permuted( [ 1 .. Length( res ) ], perm );
              kergens:= [ words[1] ];
              sub:= SubgroupNC( ker, [ res[1] ] );
              j:= 1;
              while j <= Length( words ) and Size( sub ) <> Size( ker ) do
                j:= j+1;
                Add( kergens, words[j] );
                sub:= ClosureGroup( sub, res[j] );
              od;
              if Size( sub ) = Size( ker ) then
                lines:= LinesOfStraightLineProgram(
                            RestrictOutputsOfSLP( prg, kergens ) );
                Add( result, [ std, factname, lines ] );
              else
                Print( "#I  ", entry[1],
                       ": not enough generators for the kernel found\n" );
              fi;
            fi;
          else
            # Try to form the homomorphism object in GAP,
            # by mapping generators of the big group to generators
            # of the factor group.
            # If this defines a homomorphism and if this is surjective
            # then the generators are compatible.
            # For example, both 2.J2.2 and Isoclinic(2.J2.2) map to J2.2;
            # then also the maxes can be identified etc.
facttbl:= CharacterTable( factname );
if ClassPositionsOfFittingSubgroup( facttbl ) = [1] then
# currently classes scripts are available only for these tables,
# so other cases are not really interesting at the moment ...
            G:= AtlasGroup( entry[1], std, IsPermGroup, true );
            F:= AtlasGroup( factname, factstd, IsPermGroup, true );
            if G <> fail and F <> fail then
if NrMovedPoints( G ) <= AGR.Test.MaxTestDegree and
   NrMovedPoints( F ) <= AGR.Test.MaxTestDegree then
#Print( "#I trying hom. ", entry[1], " ->> ", factname, "\n" );
              hom:= GroupHomomorphismByImagesNC( G, F,
                        GeneratorsOfGroup( G ), GeneratorsOfGroup( F ) );
              if hom <> fail then
                # Find a script for generators of the kernel.
                free:= FreeSemigroup( Length( GeneratorsOfGroup( G ) ) );
                freegens:= GeneratorsOfSemigroup( free );
                freestrs:= List( freegens, String );
                iter:= Iterator( free );
                ker:= TrivialSubgroup( G );
                addprgs:= [];
                while Size( ker ) * Size( F ) <> Size( G ) do
                  w:= NextIterator( iter );
                  ord:= Order( MappedWord( w, freegens,
                                   GeneratorsOfGroup( F ) ) );
                  elm:= MappedWord( w, freegens,
                                    GeneratorsOfGroup( G ) )^ord;
                  if not elm in ker then
                    Add( addprgs, CompositionOfStraightLinePrograms(
                          StraightLineProgram( [ [ [ 1, ord ], 2 ] ] ),
                          StraightLineProgramNC( String( w ), freestrs ) ) );
                    ker:= ClosureGroup( ker, elm );
                  fi;
                od;
                lines:= LinesOfStraightLineProgram(
                    IntegratedStraightLineProgram( addprgs ) );
                Add( result, [ std, factname, lines ] );
              fi;
else
#Print( "#I omit hom. ", entry[1], " ->> ", factname, ", too many points ...\n" );
fi;
elif std = 1 and factstd = 1 then
#Print( "#I no hom. ", entry[1], " ->> ", factname, " to try?\n" );
          #   fi;
fi;
            fi;
          fi;
        fi;
      od;
      return result;
    end;

    result:= true;

    if Length( arg ) = 0 or ( Length( arg ) = 1 and IsBool( arg[1] ) ) then
      for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AGR.Test.KernelGenerators( entry, verbose ) and result;
      od;
    elif IsBound( arg[1][3].factorCompatibility ) then
      entry:= arg[1];
      new:= CompInfoForEntry( entry );
      if IsBound( entry[3].kernelPrograms ) then
        old:= ShallowCopy( entry[3].kernelPrograms );
      else
        old:= [];
      fi;
      for i in [ 1 .. Length( old ) ] do
        pos:= Position( new, old[i] );
        if pos <> fail then
          Unbind( old[i] );
          Unbind( new[ pos ] );
        else
          pos:= PositionProperty( new, l -> old[i]{[1..2]} = l{[1..2]} );
          if pos <> fail then
            if AGR.IsEquivalentSLP( old[i][3], new[ pos ][3] ) then
              Unbind( old[i] );
              Unbind( new[ pos ] );
            else
              Print( "#E  AGR.Test.KernelGenerators: contradiction of ",
                     "kernel info for `", entry[1], "' at\n",
                     "#E  ", old[i], "\n" );
              result:= false;
            fi;
          fi;
        fi;
      od;

      for l in new do
        Print( "#I  AGR.Test.KernelGenerators: add kernel info\n",
               "AGR.KERPRG(\"", entry[1], "\",",
               Filtered( String( l ), x -> x <> ' ' ), ");\n" );
      od;
      for l in old do
        Print( "#I  AGR.Test.KernelGenerators: cannot verify kernel ",
               "info `", l, "' for `", entry[1], "'\n" );
      od;
    fi;

    return result;
    end;


#############################################################################
##
#F  AGR.CharacterNameFromMultiplicities( <tbl>, <mults> )
##
##  - to be used for tables of perfect groups only;
##    in other cases, relative names should be used
##  - see also `MFER.PermCharInfo_ATLAS_FromCoefficients'
##    (which works only for mult.-free characters)
##
AGR.CharacterNameFromMultiplicities:= function( tbl, mults )
    local degrees, degreeset, positions, irrnames, i, alp, ATL, j, n, pair;

    if UnderlyingCharacteristic( tbl ) = 0 then
      if not IsPerfectCharacterTable( tbl ) then
        return fail;
      fi;
    elif not IsPerfectCharacterTable( OrdinaryCharacterTable( tbl ) ) then
      return fail;
    fi;

    degrees:= List( Irr( tbl ), x -> x[1] );
    degreeset:= Set( degrees );
    positions:= List( degreeset, x -> [] );
    irrnames:= [];
    for i in [ 1 .. Length( degrees ) ] do
      Add( positions[ PositionSorted( degreeset, degrees[i] ) ], i );
    od;

    alp:= List( "abcdefghijklmnopqrstuvwxyz", x -> [ x ] );
    while Length( alp ) < Maximum( List( positions, Length ) ) do
      Append( alp, List( alp{ [ 1 .. 26 ] },
                         x -> Concatenation( "(", x, "')" ) ) );
    od;

    if IsInt( mults ) then
      mults:= [ mults ];
    fi;

    ATL:= [];
    for i in [ 1 .. Length( degreeset ) ] do
      ATL[i]:= "";
      for j in [ 1 .. Length( positions[i] ) ] do
        n:= positions[i][j];
        if n in mults then
          # appears once
          Append( ATL[i], alp[j] );
        else
          pair:= First( mults, x -> IsList( x ) and x[1] = n );
          if pair <> fail then
            # appears with larger mult.
            Append( ATL[i], alp[j] );
            Append( ATL[i], "^" );
            Append( ATL[i], String( pair[2] ) );
          fi;
        fi;
      od;
      if ATL[i] <> "" then
        ATL[i]:= Concatenation( String( degreeset[i] ), ATL[i] );
      fi;
    od;

    return JoinStringsWithSeparator( Filtered( ATL, x -> x <> "" ), "+" );
    end;


#############################################################################
##
#F  AGR.Test.Characters( [<tocid>[, <name>[, <cond>]]] )
##
##  <#GAPDoc Label="test:AGR.Test.Characters">
##  <Mark><C>AGR.Test.Characters( [<A>tocid</A>] )</C></Mark>
##  <Item>
##    checks the stored character information for the matrix and permutation
##    representations that are stored in the directory with identifier
##    <A>tocid</A>.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.Characters:= function( arg )
    local result, name, toc, cond, grpname, tbl, classnames, ccl, cyc, entry,
          outputs1, std, prg1, poss, nam, ord, parts, outputs, prgs2,
          info, p, id, modtbl, fus, phi, gens, galoisfams, choice, i, pos,
          prgs, prg2, repprg, rep, val, dec, j, map, parsed, charpos, test;

    # Initialize the result.
    result:= true;

    if IsEmpty( arg ) then
      return AGR.Test.Characters( "local" );
    elif Length( arg ) = 1 then
      for name in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AGR.Test.Characters( arg[1], name[1] ) and result;
      od;
      return result;
    elif Length( arg ) = 2 then
      toc:= AtlasTableOfContents( arg[1] );
      name:= arg[2];
      cond:= [];
    elif Length( arg ) = 3 then
      toc:= AtlasTableOfContents( arg[1] );
      name:= arg[2];
      cond:= arg[3];
    fi;

    if toc = fail then
      return true;
    fi;
    toc:= toc.TableOfContents;
    grpname:= AGR.InfoForName( name );
    if grpname = fail then
      Print( "#E  no AtlasRep info stored for ", name, "\n" );
      return false;
    elif not IsBound( toc.( grpname[2] ) ) then
      # This table of contents has no info for `name'.
      return true;
    fi;
    tbl:= CharacterTable( name );
    if tbl = fail then
      # There is nothing to identify.
      return true;
    fi;

    classnames:= AtlasClassNames( tbl );
    ccl:= AtlasProgram( name, "classes" );
    cyc:= AtlasProgram( name, "cyclic" );

    if ccl <> fail then
      if not IsBound( ccl.outputs ) then
        Print( "#E  no component `outputs' in ccl script for ", name, "\n" );
        return false;
      fi;
      outputs1:= ccl.outputs;
      std:= ccl.standardization;
      prg1:= ccl.program;
      cyc:= fail;
    elif cyc <> fail then
      if not IsBound( cyc.outputs ) then
        Print( "#E  no component `outputs' in cyc script for ", name, "\n" );
        return false;
      fi;
      outputs1:= cyc.outputs;
      std:= cyc.standardization;
      prg1:= cyc.program;

      # Form all possibilities for proper class names.
      poss:= [];
      for nam in outputs1 do
        if nam in classnames then
          Add( poss, [ nam ] );
        else
          # Assume that only single letters appear.
# L216d4G1-cycW1:echo "Classes 15ABCD 17EFGH 10AB 8A 12A'"
# Sz32d5G1-cycW1:echo "Classes 25A-E 31A-O 41A-J 20A-B'''' 25F-F''''"
# TD42d3G1-cycW1:echo "Classes  6B 12A 13ABC 18ABC 21ABC 28ABC  6D 12C' 12E 18D' 21D 24A 24B"
          ord:= nam{ [ 1 .. PositionProperty( nam, IsAlphaChar ) - 1 ] };
          if '-' in nam then
            parts:= SplitString( nam{ [ Length( ord ) + 1 .. Length( nam ) ] },
                                 "-" );
            Add( poss, List( Filtered( List( CHARS_UALPHA, x -> [ x ] ),
                                       x -> parts[1] <= x and x <= parts[2] ),
                             y -> Concatenation( ord, y ) ) );
          else
            Add( poss, List( nam{ [ Length( ord ) + 1 .. Length( nam ) ] },
                             y -> Concatenation( ord, [ y ] ) ) );
          fi;
        fi;
      od;
      if ForAny( poss, IsEmpty ) then
        Print( "#E  not all classes identified in cyc script for ",
               name, "\n" );
        return false;
      fi;
      outputs:= List( Cartesian( poss ), names -> Concatenation( [
          "oup ", String( Length( names ) ), " ",
                  JoinStringsWithSeparator( names, " " ), "\n",
          "echo \"Classes ",
                  JoinStringsWithSeparator( names, " " ), "\"" ] ) );
      outputs:= List( outputs, prgstring ->
                  StringOfAtlasProgramCycToCcls( prgstring, tbl, "names" ) );
      outputs:= List( outputs, x -> ScanStraightLineProgram( x, "string" ) );
      prgs2:= List( outputs,
                    x -> rec( program:= CompositionOfStraightLinePrograms(
                                            x.program, prg1 ),
                              outputs:= x.outputs ) );
    else
      # We have no script for computing enough class representatives.
      return true;
    fi;

    for info in CallFuncList( AllAtlasGeneratingSetInfos,
                              Concatenation( [ name, std ], cond ) ) do
      if IsBound( info.p ) then
        # a permutation representation
        p:= 0;
        id:= info.identifier[2][1];
        modtbl:= tbl;
        fus:= [ 1 .. Length( classnames ) ];
      elif Characteristic( info.ring ) = 0 then
        p:= 0;
        id:= info.identifier[2];
        modtbl:= tbl;
        fus:= [ 1 .. Length( classnames ) ];
      else
        p:= Characteristic( info.ring );
        id:= info.identifier[2][1];
        modtbl:= tbl mod p;
        if modtbl <> fail then
          fus:= GetFusionMap( modtbl, tbl );
        else
          fus:= fail;
        fi;
      fi;
      id:= id{ [ 1 .. Position( id, '.' )-1 ] };

      phi:= fail;
      if fus = fail then
        Print( "#I  no Brauer table available for identifying ", id, "\n" );
      else
        gens:= AtlasGenerators( info );
        if gens <> fail then

          # Determine representatives of Galois orbits.
          galoisfams:= GaloisMat( TransposedMat( Irr( modtbl ) ) ).galoisfams;
          choice:= Filtered( [ 1 .. Length( galoisfams ) ],
                             i -> galoisfams[i] <> 0 );
          phi:= [];
# Print( "# need ", Length( choice ), " values\n#\c" );
          for i in [ 1 .. Length( choice ) ] do
            pos:= fus[ choice[i] ];
            if classnames[ pos ] in outputs1 then
              # The character value is uniquely determined.
              prgs:= [ rec( program:= prg1, outputs:= outputs1 ) ];
            else
              # We have to check several possibilities.
              prgs:= prgs2;
            fi;
            for prg2 in prgs do
              repprg:= RestrictOutputsOfSLP( prg2.program,
                           Position( prg2.outputs, classnames[ pos ] ) );
              rep:= ResultOfStraightLineProgram( repprg, gens.generators );
              if IsBound( info.p ) then
                val:= info.p - NrMovedPoints( rep );
              elif Characteristic( info.ring ) = 0 then
                val:= TraceMat( rep );
              else
                val:= BrauerCharacterValue( rep );
              fi;
              if not IsBound( phi[i] ) then
                phi[i]:= val;
              elif phi[i] <> val then
                Print( "#I  representation ", id,
                       " yields information about class ",
                       classnames[ pos ], "\n" );
                phi:= fail;
                break;
              fi;
            od;
            if phi = fail then
              break;
            fi;
# Print( i, " \c");
          od;
# Print("\n# have them!\n");
          if phi = fail then
            Print( "#I  cannot write down character for ",
                   gens.identifier, "\n" );
          else
            dec:= Decomposition( List( Irr( modtbl ), x -> x{ choice } ),
                                 [ phi ], "nonnegative" )[1];
            if dec = fail then
              Print( "#I  not decomposable character for ", id, ":\n",
                     phi, "\n" );
              phi:= fail;
            else
              pos:= [];
              for i in [ 1 .. Length( dec ) ] do
                if dec[i] = 1 then
                  Add( pos, i );
                elif 1 < dec[i] then
                  Add( pos, [ i, dec[i] ] );
                fi;
              od;
              if Length( pos ) = 1 and IsInt( pos[1] ) then
                pos:= pos[1];
              fi;
            fi;
          fi;
        fi;
      fi;

      # Check the character data stored for this representation.
      map:= AtlasOfGroupRepresentationsInfo.characterinfo;
      if not IsBound( map.( name ) ) then
        map.( name ):= [];
      fi;
      map:= map.( name );
      if p = 0 then
        charpos:= 1;
      else
        charpos:= p;
      fi;
      if not IsBound( map[ charpos ] ) then
        map[ charpos ]:= [ [], [] ];
      fi;
      map:= map[ charpos ];
      if phi = fail then
        # Test that NO character info is stored.
        if id in map[2] then
          Print( "#E  cannot verify stored character info for ", id,
                 "\n" );
        fi;
      elif id in map[2] then
        # Test that NO OTHER character info is stored.
        if map[1][ Position( map[2], id ) ] <> pos then
          Print( "#E  stored and computed character info for `", id,
                 "' differ\n" );
        fi;
      else
        nam:= AGR.CharacterNameFromMultiplicities( modtbl, pos );
        if nam <> fail then
          # Test whether the character name is compatible with `id'.
          if IsInt( pos ) then
            parsed:= AGR.ParseFilenameFormat( id,
                         [ [ [ IsChar ],
                             [ "f", IsDigitChar, "r", IsDigitChar,
                               AGR.IsLowerAlphaOrDigitChar,
                               "B", IsDigitChar, ".m", IsDigitChar ] ],
                           [ ParseBackwards, ParseForwards ] ] );
            if ( parsed[8] = "" and
                 nam <> Concatenation( String( parsed[7] ), "a" ) ) or
               ( parsed[8] <> "" and
                 nam <> Concatenation( String( parsed[7] ), parsed[8] ) ) then
              Print( "#E  character name `", nam, "' contradicts `", id,
                     "'\n" );
            fi;
          fi;
        fi;
        pos:= ReplacedString( String( pos ), " ", "" );
        Print( "#I  add new info\n",
               "AGR.CHAR(\"", name, "\",\"", id, "\",", p, ",", pos );
        if nam <> fail then
          Print( ",\"", nam, "\"" );
        fi;
        Print( ");\n" );
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  AGR.PrimitivityInfo( <inforec> )
##
##  <inforec> is a record as returned by `OneAtlasGeneratingSetInfo',
##  for a permutation representation.
##
##  - If a perm. repres. is intransitive then just compute the orbit lengths.
##  - For a transitive perm. repres. of degree n, say, check primitivity:
##    - If the restriction to a maximal subgroup fixes a point then
##      this maximal subgroup is identified as the point stabilizer.
##    - If the the degree is not an index of a maximal subgroup then we know
##      that the repres. is not primitive.
##    - If the restriction from G to a maximal subgroup M of G has an orbit
##      of length n / [G:M] then M contains the point stabilizer; so if the
##      restriction to M does not fix a point then the repres. is not
##      primitive, and we know a maximal overgroup of the point stabilizer.
##
AGR.PrimitivityInfo:= function( inforec )
    local gens, gapname, orbs, G, tr, rk, atlasinfo, size, indices, cand,
          result, i, prg, rest, filt, tbl, max, stab, maxmax, maxcand;

    gens:= AtlasGenerators( inforec );
    if gens <> fail then
      gens:= gens.generators;
      gapname:= inforec.groupname;

      # Check whether the group is transitive.
      orbs:= OrbitsPerms( gens, [ 1 .. inforec.p ] );
      if 1 < Length( orbs ) then
        return rec( isPrimitive:= false,
                    transitivity:= 0,
                    orbitLengths:= SortedList( List( orbs, Length ) ),
                    comment:= "explicit computation of orbits" );
      fi;

      atlasinfo:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                         x -> x[1] = gapname );

      # Compute transitivity and primitivity.
      G:= Group( gens );
      if IsBound( atlasinfo[3].size ) then
        SetSize( G, atlasinfo[3].size );
      fi;
      tr:= Transitivity( G );
      rk:= RankAction( G );

      if IsBound( atlasinfo[3].nrMaxes ) and
         IsBound( atlasinfo[3].sizesMaxes ) and
         Number( atlasinfo[3].sizesMaxes ) = atlasinfo[3].nrMaxes then
        size:= Size( G );
        indices:= List( atlasinfo[3].sizesMaxes, x -> size / x );
        cand:= Filtered( [ 1 .. Length( indices ) ],
                         i -> inforec.p mod indices[i] = 0 );
        if inforec.p in indices and Length( cand ) = 1 then
          # The point stabilizer is contained in a unique class of maxes,
          # and since the degree occurs as index of a maximal subgroup,
          # this representation is necessarily primitive.
          # Moreover, we know the class of maximal subgroups that are
          # the point stabilizers.
          result:= rec( isPrimitive:= true,
                        transitivity:= tr,
                        rankAction:= rk,
                        class:= cand[1],
                        comment:= "unique class of maxes for given degree" );
          if IsBound( atlasinfo[3].structureMaxes ) and
             IsBound( atlasinfo[3].structureMaxes[ cand[1] ] ) then
            result.structure:= atlasinfo[3].structureMaxes[ cand[1] ];
          fi;
          return result;
        fi;
      else
        cand:= [ 1 .. AGR.Test.HardCases.MaxNumberMaxes ];
      fi;

      # Check explicit restrictions to maximal subgroups M.
      # (If we know their orders then we check only those that can contain
      # the point stabilizer U.)
      for i in cand do
        prg:= AtlasStraightLineProgram( gapname, "maxes", i );
        if prg <> fail then
          rest:= ResultOfStraightLineProgram( prg.program, gens );

          if NrMovedPoints( rest ) < inforec.p then
            # If the restriction to M fixes a point then M is equal to U.
            result:= rec( isPrimitive:= true,
                          transitivity:= tr,
                          rankAction:= rk,
                          class:= i,
                          comment:= "restriction fixes a point" );
            if IsBound( atlasinfo[3].structureMaxes ) and
               IsBound( atlasinfo[3].structureMaxes[i] ) then
              result.structure:= atlasinfo[3].structureMaxes[i];
            fi;
            return result;
          elif IsBound( atlasinfo[3].sizesMaxes ) and
               IsBound( atlasinfo[3].sizesMaxes[i] ) then
            if inforec.p * atlasinfo[3].sizesMaxes[i] / Size( G ) in
               OrbitLengths( Group( rest ) ) then
              # The length of the M-orbit of a point is equal to the quotient
              # |M|/|U|, thus U is a proper subgroup of M.
              result:= rec( isPrimitive:= false,
                            transitivity:= tr,
                            rankAction:= rk,
                            class:= i,
                            comment:= "restriction contains point stab." );
              if IsBound( atlasinfo[3].structureMaxes ) and
                 IsBound( atlasinfo[3].structureMaxes[i] ) then
                # We know a maximal overgroup M of the stabilizer U.
                # Try to identify also U itself:
                # - If U is trivial then nothing is to do.
                # - If [M:U] is the index of the largest maximal subgroup of M
                #   then take the description of it.
                # - If [M:U] = 2 and [M:M']_2 = 2 then U is the unique index
                #   two subgroup of M.
                result.overgroup:= atlasinfo[3].structureMaxes[i];
                if inforec.p = Size( G ) then
                  result.subgroup:= "1";
                else
                  tbl:= CharacterTable( inforec.groupname );
                  if tbl <> fail then
                    max:= CharacterTable( result.overgroup );
                    if max <> fail then
                      if inforec.p * atlasinfo[3].sizesMaxes[i] / Size( G )
                         = 2 and
                         Length( LinearCharacters( max ) ) mod 4 = 2 then
                        stab:= Filtered( NamesOfFusionSources( max ),
                                   u -> Size( CharacterTable( u ) ) = Size( max ) / 2 );
                        if Length( stab ) = 1 then
                          result.subgroup:= stab[1];
                        elif HasConstructionInfoCharacterTable( max ) and
                             [ "Cyclic", 2 ] in ConstructionInfoCharacterTable( max )[2] then
  Error("!");
                          stab:= Difference( ConstructionInfoCharacterTable( max )[2], [ [ "Cyclic", 2 ] ] );
                          if Length( stab ) = 1 and Length( stab[1] ) = 1 and
                             IsString( stab[1][1] ) then
                            result.subgroup:= stab[1][1];
  Print( "identify ", result.subgroup, "\n\n" );
                          fi;
                        fi;
                      else
                        maxmax:= CharacterTable( Concatenation( Identifier( max ), "M1" ) );
                        if maxmax <> fail and inforec.p * atlasinfo[3].sizesMaxes[i] / Size( G )
                           = Size( max ) / Size( maxmax ) then
                          result.subgroup:= Identifier( maxmax );
                        fi;
                      fi;
                    fi;
                  fi;
                fi;
              fi;
              return result;
            fi;
          fi;
        fi;
      od;

      if IsBound( atlasinfo[3].nrMaxes ) and
         IsBound( atlasinfo[3].sizesMaxes ) and
         Number( atlasinfo[3].sizesMaxes ) = atlasinfo[3].nrMaxes and
         not inforec.p in indices then
        # This representation is not primitive
        # but we do not know overgroups.
        return rec( isPrimitive:= false,
                    transitivity:= tr,
                    rankAction:= rk,
                    comment:= "degree is not an index of a max. subgroup" );
      fi;

      # Check explictly whether the action is primitive.
      if not IsPrimitive( G, MovedPoints( G ) ) then
        return rec( isPrimitive:= false,
                    transitivity:= tr,
                    rankAction:= rk,
                    comment:= "explicit check of primitivity" );
      fi;

      # Now we know that the action is primitive.
      if IsBound( atlasinfo[3].nrMaxes ) and
         IsBound( atlasinfo[3].sizesMaxes ) and
         Number( atlasinfo[3].sizesMaxes ) = atlasinfo[3].nrMaxes then
        maxcand:= Filtered( [ 1 .. Length( indices ) ],
                            i -> inforec.p = indices[i] );
        if Length( maxcand ) = 1 then
          # We know the class.
          result:= rec( isPrimitive:= true,
                        transitivity:= tr,
                        rankAction:= rk,
                        class:= maxcand[1],
                        comment:=
           "unique class of maxes for the given degree and prim. action" );
          if IsBound( atlasinfo[3].structureMaxes ) and
             IsBound( atlasinfo[3].structureMaxes[ maxcand[1] ] ) then
            result.structure:= atlasinfo[3].structureMaxes[ maxcand[1] ];
          fi;
          return result;
        fi;
      fi;
    fi;

    # We do not know how to deal with this case.
    return rec( isPrimitive:= fail );
    end;


#############################################################################
##
#F  AGR.Test.Primitivity( [<tocid>[, <name>]] )
##
##  <#GAPDoc Label="test:AGR.Test.Primitivity">
##  <Mark><C>AGR.Test.Primitivity( [<A>tocid</A>] )</C></Mark>
##  <Item>
##    checks the stored primitivity information for the permutation
##    representations that are stored in the directory with identifier
##    <A>tocid</A>.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.Primitivity:= function( arg )
    local result, name, tocid, tblid, arec, repname, info, maxid, tbl,
          maxname, res, permrepinfo, stored, str, entry;

    # Initialize the result.
    result:= true;

    if IsEmpty( arg ) then
      return AGR.Test.Primitivity( "local" );
    elif Length( arg ) = 1 then
      for name in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AGR.Test.Primitivity( arg[1], name[1] ) and result;
      od;
      return result;
    elif Length( arg ) = 2 then
      tocid:= arg[1];
      name:= arg[2];
    fi;

    tblid:= fail;
    if TestPackageAvailability( "CTblLib", "1.0" ) = true then
      tblid:= LibInfoCharacterTable( name );
      if tblid <> fail then
        tblid:= tblid.firstName;
      fi;
    fi;

    for arec in AllAtlasGeneratingSetInfos( name, "contents", tocid,
                    IsPermGroup, true ) do
      repname:= arec.identifier[2][1];
      repname:= repname{ [ 1 .. Position( repname, '.' )-1 ] };
      info:= AGR.PrimitivityInfo( arec );
      if IsBound( info.transitivity ) and info.transitivity = 0 then
        res:= [ repname, [ 0, info.orbitLengths ] ];
      elif info.isPrimitive = true then
        if IsBound( info.structure ) then
          res:= [ repname, [ info.transitivity, info.rankAction, "prim",
                             info.structure, info.class ] ];
        elif IsBound( info.class ) then
          if tblid <> fail then
            maxid:= Concatenation( tblid, "M", String( info.class ) );
            tbl:= CharacterTable( maxid );
          else
            tbl:= fail;
          fi;
          if tbl <> fail then
            maxname:= AGR.StructureDescriptionCharacterTableName(
                          Identifier( tbl ) );
          else
            maxname:= "???";
          fi;
          res:= [ repname, [ info.transitivity, info.rankAction, "prim",
                             maxname, info.class ] ];
        else
          res:= [ repname, [ info.transitivity, info.rankAction, "prim",
                             "???", info.possclass ] ];
        fi;
      elif info.isPrimitive = false then
        if IsBound( info.overgroup ) then
          if IsBound( info.subgroup ) then
            res:= [ repname, [ info.transitivity, info.rankAction, "imprim",
                               Concatenation( info.subgroup, " < ",
                                              info.overgroup ) ] ];
          else
            res:= [ repname, [ info.transitivity, info.rankAction, "imprim",
                               Concatenation( "??? < ", info.overgroup ) ] ];
          fi;
        else
          res:= [ repname, [ info.transitivity, info.rankAction, "imprim",
                             "???" ] ];
        fi;
      else
        res:= fail;
      fi;

      # Compare the computed info with the stored one.
      permrepinfo:= AtlasOfGroupRepresentationsInfo.permrepinfo;
      if IsBound( permrepinfo.( repname ) ) then
        stored:= permrepinfo.( repname );
        if stored.transitivity = 0 then
          str:= [ stored.transitivity, stored.orbits ];
        else
          str:= [ stored.transitivity, stored.rankAction,, stored.stabilizer ];
          if stored.isPrimitive then
            str[3]:= "prim";
            str[5]:= stored.maxnr;
            if '<' in stored.stabilizer then
              Print( "#E  prim. repres. with '<' in stabilizer string ",
                     "for ", repname, "?\n" );
              result:= false;
            fi;
          else
            str[3]:= "imprim";
            if stored.stabilizer <> "???" and not '<' in stored.stabilizer then
              Print( "#E  imprim. repres. without '<' in stabilizer string ",
                     "for ", repname, "?\n" );
              result:= false;
            fi;
          fi;
        fi;
      else
        stored:= fail;
      fi;

      if stored = fail then
        if res <> fail then
          Print( "#I  new AGR.API value:\n" );
          if "???" in res[2] then
            Print( "# " );
          fi;
          str:= [];
          for entry in res[2] do
            if IsString( entry ) then
              Add( str, Concatenation( "\"", entry, "\"" ) );
            else
              Add( str, String( entry ) );
            fi;
          od;
          Print( "AGR.API(\"", res[1], "\",[",
                 JoinStringsWithSeparator( str, "," ), "]);\n" );
        fi;
      elif res = fail then
        Print( "#I  cannot verify stored value `", str, "' for ", repname,
               "\n" );
      elif res[2] <> str then
        # We have a computed and a stored value.
        # Report an error if the two values are not compatible,
        # report a difference if some part was not identified.
        if Length( str ) <> Length( res[2] ) or Length( str ) = 2 or
           str{ [ 1 .. 3 ] } <> res[2]{ [ 1 .. 3 ] } then
          Print( "#E  difference stored <-> computed for ", repname,
                 ":\n#E  ", str, " <-> ", res[2], "\n" );
          result:= false;
        elif 4 <= Length( str ) and res[2][4] = "???" then
          Print( "#I  cannot identify stabilizer `", str[4], "' for ",
                 repname, "\n" );
        elif 4 <= Length( str ) and 6 < Length( res[2][4] ) and
             res[2][4]{ [ 1 .. 6 ] } = "??? < " then
          if '<' in str[4] and
              str[4]{ [ Position( str[4], '<' ) .. Length( str[4] ) ] }
              = res[2][4]{ [ Position( res[2][4], '<' )
                             .. Length( res[2][4] ) ] } then
            Print( "#I  cannot identify subgroup in stabilizer `", str[4],
                   "' for ", repname, "\n" );
          else
            Print( "#E  difference stored <-> computed for ", repname,
                   ":\n#E  ", str, " <-> ", res[2], "\n" );
            result:= false;
          fi;
        else
          Print( "#E  difference stored <-> computed for ", repname,
                 ":\n#E  ", str, " <-> ", res[2], "\n" );
          result:= false;
        fi;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  AGR.Test.MinimalDegrees( [<verbose>] )
##
##  <#GAPDoc Label="test:AGR.Test.MinimalDegrees">
##  <Mark><C>AGR.Test.MinimalDegrees()</C></Mark>
##  <Item>
##    checks that the (permutation and matrix) representations available in
##    the &ATLAS; of Group Representations do not have smaller degree than
##    the claimed minimum.
##  </Item>
##  <#/GAPDoc>
##
AGR.Test.MinimalDegrees:= function( arg )
    local result, verbose, info, grpname, known, knownzero, deg, mindeg,
          knownfinite, chars_and_sizes, size, p, knowncharp, q, knownsizeq;

    result:= true;
    verbose:= ( Length( arg ) <> 0 );
    for info in AtlasOfGroupRepresentationsInfo.GAPnames do

      grpname:= info[1];

      # Check permutation representations.
      known:= AllAtlasGeneratingSetInfos( grpname, IsPermGroup, true );
      if not IsEmpty( known ) then
        deg:= Minimum( List( known, r -> r.p ) );
        mindeg:= MinimalRepresentationInfo( grpname, NrMovedPoints,
                     "lookup" );
        if   mindeg = fail then
          if verbose then
            Print( "#I  `", grpname, "': degree ", deg,
                   " perm. repr. known but no minimality info stored\n" );
          fi;
        elif deg < mindeg.value then
          Print( "#E  `", grpname, "': smaller perm. repr. (", deg,
                 ") than minimal degree (", mindeg.value, ")\n" );
          result:= false;
        fi;
      fi;

      # Check matrix representations over fields in characteristic zero.
      known:= AllAtlasGeneratingSetInfos( grpname, Ring, IsField );
      knownzero:= Filtered( known,
                      r -> IsBound( r.ring ) and not IsFinite( r.ring ) );
      if not IsEmpty( knownzero ) then
        deg:= Minimum( List( knownzero, r -> r.dim ) );
        mindeg:= MinimalRepresentationInfo( grpname, Characteristic, 0,
                     "lookup" );
        if   mindeg = fail then
          if verbose then
            Print( "#I  `", grpname, "': degree ", deg, " char. 0 ",
                   "matrix repr. known but no minimality info stored\n" );
          fi;
        elif deg < mindeg.value then
          Print( "#E  `", grpname, "': smaller char. 0 matrix repr. (", deg,
                 ") than minimal degree (", mindeg.value, ")\n" );
          result:= false;
        fi;
      fi;

      # Check matrix representations over finite fields.
      knownfinite:= Filtered( known, r -> IsFinite( r.ring ) );
      chars_and_sizes:= [];
      for size in Set( List( knownfinite, r -> Size( r.ring ) ) ) do
        p:= SmallestRootInt( size );
        info:= First( chars_and_sizes, pair -> pair[1] = p );
        if info = fail then
          Add( chars_and_sizes, [ p, [ size ] ] );
        else
          Add( info[2], size );
        fi;
      od;
      for info in chars_and_sizes do
        p:= info[1];
        knowncharp:= Filtered( knownfinite,
                               r -> Characteristic( r.ring ) = p );
        deg:= Minimum( List( knowncharp, r -> r.dim ) );
        mindeg:= MinimalRepresentationInfo( grpname, Characteristic, p,
                     "lookup" );
        if   mindeg = fail then
          if verbose then
            Print( "#I  `", grpname, "': degree ", deg, " char. ", p,
                   " matrix repr. known but no minimality info stored\n" );
          fi;
        elif deg < mindeg.value then
          Print( "#E  `", grpname, "': smaller char. ", p, " matrix repr. (",
                 deg, ") than minimal degree (", mindeg.value, ")\n" );
          result:= false;
        fi;
        for q in info[2] do
          knownsizeq:= Filtered( knownfinite,
                                 r -> Size( r.ring ) = q );
          deg:= Minimum( List( knownsizeq, r -> r.dim ) );
          mindeg:= MinimalRepresentationInfo( grpname, Size, q,
                       "lookup" );
          if   mindeg = fail then
            if verbose then
              Print( "#I  `", grpname, "': degree ", deg, " size ", q,
                     " matrix repr. known but no minimality info stored\n" );
            fi;
          elif deg < mindeg.value then
            Print( "#E  `", grpname, "': smaller size ", q,
                   " matrix repr. (", deg, ") than minimal degree (",
                   mindeg.value, ")\n" );
            result:= false;
          fi;
        od;
      od;

    od;
    return result;
    end;


if not IsPackageMarkedForLoading( "TomLib", "" ) then
  Unbind( HasStandardGeneratorsInfo );
  Unbind( IsStandardGeneratorsOfGroup );
  Unbind( LIBTOMKNOWN );
  Unbind( StandardGeneratorsInfo );
fi;

if not IsPackageMarkedForLoading( "CTblLib", "" ) then
  Unbind( ConstructionInfoCharacterTable );
  Unbind( HasConstructionInfoCharacterTable );
  Unbind( LibInfoCharacterTable );
fi;


#############################################################################
##
#E

