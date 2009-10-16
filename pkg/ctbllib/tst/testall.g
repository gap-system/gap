#############################################################################
##
#W  testall.g              GAP 4 package `ctbllib'             Thomas Breuer
##
#H  @(#)$Id: testall.g,v 1.9 2005/09/07 16:05:29 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

LoadPackage( "ctbllib" );

dirs:= DirectoriesPackageLibrary( "ctbllib", "tst" );

ReadTest( Filename( dirs, "docxpl.tst" ) );
ReadTest( Filename( dirs, "ambigfus.tst" ) );
ReadTest( Filename( dirs, "ctblcons.tst" ) );
ReadTest( Filename( dirs, "ctbldeco.tst" ) );
ReadTest( Filename( dirs, "ctblj4.tst" ) );
ReadTest( Filename( dirs, "ctbllib.tst" ) );
ReadTest( Filename( dirs, "ctblpope.tst" ) );
ReadTest( Filename( dirs, "multfree.tst" ) );
ReadTest( Filename( dirs, "multfre2.tst" ) );
ReadTest( Filename( dirs, "ctocenex.tst" ) );


#############################################################################
##
#E

