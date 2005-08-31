#############################################################################
##
#W  testall.g                   GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file lists those files in the directory `tst' of the {\GAP}
##  distribution that are recommended to be read after a {\GAP} installation.
##
##  Each entry in the argument list of `RunStandardTests' is a pair that
##  consists of the filename (relative to the `tst' directory) and the
##  scaling factor that occurs in the `STOP_TEST' call at the end of the
##  test file.
##
##  The documentation (file `doc/build/install.msk') states the following:
#1
##  If you want to run a more thorough test (this is not required), you
##  can read in a test script that exercises more of {\GAP}s capabilities.
##
##  \begintt
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testall.g" ) );
##  \endtt
##
##  The test requires about 60-70MB of memory and runs about 2 minutes on a
##  Pentium III/1 GHz machine.
##  You will get a large number of lines with output about the progress
##  of the tests.
##

Print( "You should start GAP4 using:  `gap -N -A -x 80 -r -m 100m'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "You should expect about 100000 GAP4stones on a Pentium III/1 GHz.\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

Reread( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );

RunStandardTests( [
  [ "alghom.tst", 54400000 ],
  [ "algmat.tst", 1469500000 ],
  [ "algsc.tst", 265600000 ],
  [ "combinat.tst", 24000000 ],
  [ "ctblfuns.tst", 23200000 ],
  [ "ctblmoli.tst", 512400000 ],
  [ "ctblmono.tst", 259000000 ],
  [ "ctblsolv.tst", 324300000 ],
  [ "cyclotom.tst", 5700000 ],
  [ "ffe.tst", 19500000 ],
  [ "gaussian.tst", 600000 ],
  [ "grpfree.tst", 4200000 ],
  [ "grpmat.tst", 1952300000 ],
  [ "grppc.tst", 206100000 ],
  [ "grppcnrm.tst", 10376700000 ],
  [ "listgen.tst", 7100000 ],
  [ "mapping.tst", 23200000 ],
  [ "mgmring.tst", 17400000 ],
  [ "modfree.tst", 37100000 ],
  [ "morpheus.tst", 557400000 ],
  [ "onecohom.tst", 303400000 ],
  [ "oprt.tst", 19600000 ],
  [ "ratfun.tst", 5800000 ],
  [ "relation.tst", 38100000 ],
  [ "rwspcgrp.tst", 239900000 ],
  [ "semicong.tst", 39500000 ],
  [ "semigrp.tst", 86300000 ],
  [ "semirel.tst", 120100000 ],
  [ "vspchom.tst", 55100000 ],
  [ "vspcmat.tst", 43400000 ],
  [ "vspcrow.tst", 489900000 ],
  [ "xgap.tst", 533900000 ],
  [ "zlattice.tst", 800000 ],
] );


#############################################################################
##
#E

