#############################################################################
####
##
#W  anupqhead.gi               ANUPQ package                    Werner Nickel
#W                                                                Greg Gamble
##
##  `Head' file for the GAP interface to the ANU pq binary by Eamonn O'Brien.
##    
#H  @(#)$Id: anupqhead.gi,v 1.1 2006/01/24 04:42:40 gap Exp $
##
#Y  Copyright (C) 2006  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqhead_gi :=
    "@(#)$Id: anupqhead.gi,v 1.1 2006/01/24 04:42:40 gap Exp $";


#############################################################################
##
#V  ANUPQData . . record used by various functions of the ANUPQ package
##
##  The fields of ANUPQData are:
##
##    "binary"  . . the path of the pq binary
##    "tmpdir"  . . the path of the temporary directory for pq i/o files
##    "io"  . . . . list of data records for PqStart IO Streams
##    "outfile" . . the path of the pq output file
##    "SPimages"  . the path of the pq GAP_library file
##    "version" . . the version of the current pq binary
##
InstallValue( ANUPQData,
  rec( binary := Filename( DirectoriesPackagePrograms( "anupq" ), "pq"),
       tmpdir := DirectoryTemporary(),
       ni := rec(), # record for non-interactive functions
       io := []     # list of records for PqStart IO Streams,
                    #  of which, there are initially none
       )
);
ANUPQData.outfile  := Filename( ANUPQData.tmpdir, "PQ_OUTPUT" );
ANUPQData.SPimages := Filename( ANUPQData.tmpdir, "GAP_library" );

# Fire up the pq binary to get its version
Exec( Concatenation( ANUPQData.binary, " -v >", ANUPQData.outfile ) );
ANUPQData.version := StringFile( ANUPQData.outfile );
ANUPQData.version := 
    ANUPQData.version{[PositionSublist( ANUPQData.version, "Version" ) + 8 ..
                       Length(ANUPQData.version) - 1] };

#############################################################################
##  
#I  InfoClass
##
# Set the default level of InfoANUPQ
SetInfoLevel( InfoANUPQ, 1 );

#############################################################################
##
#V  ANUPQWarnOfOtherOptions . if true user is warned of non-ANUPQ-f'n options
##
ANUPQWarnOfOtherOptions := false;

#############################################################################
##
##  Ensure no zombie `pq' processes from interactive (`PqStart') sessions are 
##  left lying around when user quits GAP.
##
InstallAtExit( PqQuitAll );

#E  anupqhead.gi . . . . . . . . . . . . . . . . . . . . . . . . .  ends here 
