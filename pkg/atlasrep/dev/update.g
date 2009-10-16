#############################################################################
##
#W  update.g             GAP 4 package AtlasRep                 Thomas Breuer
##
##  ``Observer of the server ...''
##
##  This file is used as input for the `update' target in `Makefile',
##  it first updates the table of contents,
##  then moves the local files to the `archive' directory which are no longer
##  available on the server or for which the server provides a new version,
##  then fetches the server files which are not yet in the local directories.
##
##  A logfile is saved in the `log' directory, and is mailed to me.
##
##  (Note that `etc/maketoc' updates just the table of contents
##  and checks the local data directories for consistency with the server;
##  it does not fetch data files or archive outdated files.)
##

# Initialize some technical variables.
thispkg:= "atlasrep";;

# Create the name for the logfile.
LoadPackage( thispkg );  # currently needed for `CurrentDateTimeString'
dirname:= DirectoriesPackageLibrary( thispkg, "dev/log" );
datestring:= CurrentDateTimeString( [ "-u", "+%Y-%m-%d-%H-%M" ] );
logfile:= Filename( dirname[1], Concatenation( "update_", datestring ) );

# Start logging.
LogTo( logfile );

# Initialize some technical variables.
thispkg:= "atlasrep";;

# Set the path to the mirror.
str:= "";;
out:= OutputTextString( str, true );;
hostname:= Filename( DirectoriesSystemPrograms(), "hostname" );;
Process( DirectoryCurrent(), hostname, InputTextNone(), out, [] );
CloseStream( out );
if str = "heiner2\n" then
  localmirror:= "/WWWAtlas/Atlas/";
else
  localmirror:= "/home3/beteigeuze/gap/WWWAtlas/Atlas/";;
fi;
if not IsExistingFile( localmirror ) then
  Print( "server mirror not reachable\n" );
  quit;
fi;

# sudo mount -o nolock,hard,intr,rsize=8192,wsize=8192,ro beteigeuze:/export3/home/gap/WWWAtlas /WWWAtlas
# -> afterwards accessible under /WWWAtlas
# do not forget to umount!

# Save the time when the update process started.
CurrentDateTimeString();

# Load the package.
LoadPackage( thispkg );
LoadPackage( "ctbllib" );

# Set the directories for the HTML overview (before reading `maintain.g').
HTMLDataDirectory := Directory(
    "/usr/local/www-homes/Thomas.Breuer/atlasrep/htm/data" );
HTMLDataDirectoryLocal := DirectoriesPackageLibrary( thispkg, "htm/data" )[1];
ReadPackage( "ctbllib", "ctbltoc/gap/htmlutil.g" );
ReadPackage( thispkg, "dev/maintain.g" );

SetInfoLevel( InfoAtlasRep, 3 );

# Compare MeatAxe text files, MeatAxe binaries, and GAP format files.
AGRTestCompareMTXBinariesAndTextFiles( localmirror );

# Update the table of contents, using a local mirror of the server.
todo:= RecomputeAtlasTableOfContents( localmirror );;

# Archive the local files for which the server provides new versions,
# or which are no longer available on the server.
AtlasOfGroupRepresentationsArchiveOutdatedFiles( todo[1],
    Concatenation( "_remove_", datestring ) );
AtlasOfGroupRepresentationsArchiveOutdatedFiles( todo[2],
    Concatenation( "_", datestring ) );

# Enter the documentation lines about the server updates.
AtlasOfGroupRepresentationsUpdateChangesFile( todo );

# If necessary then switch the compression status.
compress:= Filename( DirectoriesPackageLibrary( thispkg, "dev" ),
                     "COMPRESS" );;
if compress <> fail then
  compress:= StringFile( compress );
  if 4 < Length( compress ) and compress{ [ 1 .. 4 ] } = "true" then
    AtlasOfGroupRepresentationsInfo.compress:= true;
  fi;
fi;
AtlasOfGroupRepresentationsInfo.compress;

# Transfer the new files to the local installation.
AtlasOfGroupRepresentationsUpdateData();

# Replace the `ringinfo' part if necessary (must be after the update).
AtlasOfGroupRepresentationsReplaceRingInfo();

# Create an updated version of the HTML overview of the package.
AtlasRepCreateHTMLOverview();

# #T from here on not yet checked again ...
# # Consider the new Magma format files on the server.
# newmagma:= UpdateNewMagmaFormatFiles();
# TestAfterMTOG( newmagma );
# 
# # Check whether the files in `dev/gap0' coincide with those in `datagens'.
# CompareFilesInDatagensAndDev();

# Create the starter archive for the package homepage.
AtlasOfGroupRepresentationsCreateDataArchive();

# Check the XML format Atlas bibliographies.
ReadPackage( "atlasrep", "bibl/bibutils.g" );
dirs:= DirectoriesPackageLibrary( "atlasrep", "bibl" );;
fnames:= [
           Filename( dirs, "Atlas1bib.xml" ),
           Filename( dirs, "Atlas2bib.xml" ),
           Filename( dirs, "ABCapp2bbib.xml" ),
           Filename( dirs, "ABCbiblbib.xml" ),
         ];;
CheckBibFiles( fnames, [ "sporsimp" ] );

# Create the HTML files with the Atlas bibliographies.
AddHandlersBibliography();
CreateAtlasBibliographyHTML();
CreateABCBibliographyHTML();

# Save the time when this update process finished.
CurrentDateTimeString();

LogTo();

# Send me a message.
SendMail( [ "sam@math.rwth-aachen.de" ], [],
    Concatenation( thispkg, " update" ), StringFile( logfile ) );

#T did not work: sendmail is not available!

#############################################################################
##
#E

