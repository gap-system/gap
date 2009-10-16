#############################################################################
##
#W  testall.g                   GAP library                      Frank Celler
##
#H  @(#)$Id: testall.g,v 4.54 2007/01/31 19:02:10 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file lists those files in the directory <F>tst</F> of the &GAP;
##  distribution that are recommended to be read after a &GAP; installation.
##
##  Each entry in the argument list of <C>RunStandardTests</C> is a pair that
##  consists of the filename (relative to the <F>tst</F> directory) and the
##  scaling factor that occurs in the <C>STOP_TEST</C> call at the end of the
##  test file.
##  <P/>
##  The documentation (file <F>doc/build/install.msk</F>) states the
##  following:
##  <P/>
##  <#GAPDoc Label="[1]{testall.g}">
##  If you want to run a more thorough test (this is not required), you
##  can read in a test script that exercises more of &GAP;s capabilities.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testall.g" ) );
##  ]]></Log>
##  <P/>
##  The test requires about 60-70MB of memory and runs about 2 minutes on a
##  Pentium III/1 GHz machine.
##  You will get a large number of lines with output about the progress
##  of the tests.
##  <#/GAPDoc>
##

Print( "You should start GAP4 using:  `gap -N -A -x 80 -r -m 100m'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "You should expect about 100000 GAP4stones on a Pentium III/1 GHz.\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

Reread( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );

RunStandardTests( [
  [ "alghom.tst",63000568],
  [ "algmat.tst",1441013704],
  [ "algsc.tst",296002170],
  [ "combinat.tst", 270000000 ],
  [ "ctblfuns.tst", 31000000 ],
  [ "ctblmoli.tst",416003661],
  [ "ctblmono.tst",274001908],
  [ "ctblsolv.tst",391002100],
  [ "cyclotom.tst",5832500],
  [ "ffe.tst", 18000000 ],
  [ "ffeconway.tst", 270000000 ],
  [ "gaussian.tst", 640000 ],
  [ "grpfree.tst", 5000000 ],
  [ "grpmat.tst",1560006131],
#  [ "grppc.tst",116000670],
  [ "grppcnrm.tst",1532002851],
  [ "listgen.tst", 1440000 ],
  [ "mapping.tst", 31000000 ],
  [ "mgmring.tst", 19000000 ],
  [ "modfree.tst",36000000 ],
  [ "morpheus.tst",634003277],
  [ "onecohom.tst",332001351],
  [ "oprt.tst",23823519],
  [ "ratfun.tst", 9000000 ],
  [ "rwspcgrp.tst",252000906],
  [ "semigrp.tst",135000574],
  [ "semirel.tst",364004597],
  [ "vspchom.tst",74000701],
  [ "vspcmat.tst",52000692],
  [ "vspcrow.tst",195001138],
  [ "xgap.tst",562000888],
  [ "zlattice.tst", 136000 ],
  [ "zmodnz.tst", 2100000 ],
] );


#############################################################################
##
#E

