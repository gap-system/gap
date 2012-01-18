#############################################################################
##
#W  testinst.g          GAP 4 package AtlasRep                  Thomas Breuer
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains those tests for the AtlasRep package that are
##  recommended for being executed after the package has been installed.
##  Currently just a few file transfers are tried in the case that
##  <C>AtlasOfGroupRepresentationsInfo.remote</C> is <K>true</K>,
##  and <C>AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates</C> is
##  called.
##
##  <#GAPDoc Label="[1]{testinst.g}">
##  For checking the installation of the package, you should start &GAP;
##  and call
##  <P/>
##  <Log><![CDATA[
##  gap> ReadPackage( "atlasrep", "tst/testinst.g" );
##  ]]></Log>
##  <P/>
##  If the installation is o.k.&nbsp;then the &GAP; prompt appears without
##  anything else being printed;
##  otherwise the output lines tell you what should be changed.
##  <P/>
##  More test files are available in the <F>tst</F> directory of the package,
##  see Section&nbsp;
##  <Ref Sect="sect:AGR Sanity Checks"/> for details.
##  <#/GAPDoc>
##

LoadPackage( "atlasrep" );

if AtlasOfGroupRepresentationsInfo.remote = true then

  # Test whether the data directories are writable.
  dir:= DirectoriesPackageLibrary( "atlasrep", "dataword" );
  if not IsWritableFile( Filename( dir, "" ) ) then
    Print( "#I  Package `atlasrep':  ",
           "The package directory `dataword' is not writable.\n" );
  fi;
  dir:= DirectoriesPackageLibrary( "atlasrep", "datagens" );
  if not IsWritableFile( Filename( dir, "" ) ) then
    Print( "#I  Package `atlasrep':  ",
           "The package directory `datagens' is not writable.\n" );
  fi;

  # Check whether the requirements for transferring files are satisfied.
  io:= LoadPackage( "io" ) = true;
  wgetpath:= Filename( DirectoriesSystemPrograms(), "wget" );
  wget:= IsExecutableFile( wgetpath );
  bad:= false;
  if not ( io or wget ) then
    bad:= true;
    msg:= Concatenation(
       "#I  The system program `wget' and the GAP package `IO' ",
       "are not available.\n",
       "#I  Please set `AtlasOfGroupRepresentationsInfo.remote' ",
       "to `false'\n" );
  elif IsBound( AtlasOfGroupRepresentationsInfo.wget ) then
    if AtlasOfGroupRepresentationsInfo.wget = true then
      if not wget then
        bad:= true;
        msg:= Concatenation(
          "#I  The system program `wget' is not available.\n",
          "#I  Please remove the component ",
          "`AtlasOfGroupRepresentationsInfo.wget'\n" );
      fi;
    elif AtlasOfGroupRepresentationsInfo.wget = false then
      if not io then
        bad:= true;
        msg:= Concatenation(
          "#I  The GAP package `IO' is not available.\n",
          "#I  Please remove the component ",
          "`AtlasOfGroupRepresentationsInfo.wget'\n" );
      fi;
    fi;
  fi;

  if bad then
    Print( "#I  Package `atlasrep':\n", msg );
  else
    # Test transferring group generators in MeatAxe text format.
    # (Remove some files if necessary and access them again.)
    filenames:= [];
    dirs:= DirectoriesPackageLibrary( "atlasrep", "datagens" );
    id1:= OneAtlasGeneratingSet( "A5", Characteristic, 2 );
    if id1 <> fail then
      Append( filenames,
              List( id1.identifier[2], name -> Filename( dirs, name ) ) );
    fi;
    id2:= OneAtlasGeneratingSet( "A5", Characteristic, 0 );
    if id2 <> fail then
      Add( filenames, Filename( dirs, id2.identifier[2] ) );
    fi;
    filenames:= Filtered( filenames, x -> x <> fail );
    if IsEmpty( filenames ) then
      Print( "#I  Package `atlasrep':  ",
             "Transferring data files seems not to work.\n",
             "#I  Perhaps `AtlasOfGroupRepresentationsInfo.remote' ",
             "should be set to `false'.\n" );
    else
      oldfiles:= List( filenames, StringFile  );
      for file in filenames do
        RemoveFile( file );
      od;
      newid1:= OneAtlasGeneratingSet( "A5", Characteristic, 2 );
      newid2:= OneAtlasGeneratingSet( "A5", Characteristic, 0 );
      if    newid1 = fail or newid2 = fail
         or id1 <> newid1 or id2 <> newid2 then
        # Restore the files.
        for i in [ 1 .. Length( filenames ) ] do
          FileString( filenames[i], oldfiles[i] );
        od;
        Print( "#I  Package `atlasrep':  ",
               "Transferring data files does not work.\n",
               "#I  Perhaps `AtlasOfGroupRepresentationsInfo.remote' ",
               "should be set to `false'.\n" );
      else
        # Print information about data files to be removed/updated.
        # (This is for those who had installed an earlier package version.)
        upd:= AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates();
        if upd <> fail and not IsEmpty( upd ) then
          Print( "#I  Remove the following files:\n", upd, "\n" );
        fi;
      fi;
    fi;
  fi;
fi;


#############################################################################
##
#E

