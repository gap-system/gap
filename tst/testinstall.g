#############################################################################
##
#W  testinstall.g               GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file lists those files in the directory <F>tst</F> of the &GAP;
##  distribution that are recommended to be read after a &GAP; installation.
##
##  Each entry in the argument list of <C>RunStandardTests</C> is a pair that
##  consists of the filename (relative to the <F>tst</F> directory) and the
##  scaling factor that occurs in the <C>STOP_TEST</C> call at the end of the
##  test file.
##  <P/>
##  The documentation states the following:
##  <P/>
##  <#GAPDoc Label="[1]{testinstall.g}">
##  If you want to run a quick test of your &GAP; installation 
##  (though this is not required), you can read in a test script 
##  that exercises some &GAP;'s capabilities.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) );
##  ]]></Log>
##  <P/>
##  The test requires about 512MB of memory and runs about one 
##  minute on an Intel Core 2 Duo / 2.53 GHz machine.
##  You will get a large number of lines with output about the progress
##  of the tests.
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -N -A -x 80 -r -m 100m -o 512m'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "You should expect the test to take about one minute and show about\n",
       "100000 GAP4stones on an Intel Core 2 Duo / 2.53 GHz machine.\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

Reread( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );

RunStandardTests( [
  [ "alghom.tst", 5300000 ],
  [ "algmat.tst", 287300000 ],
  [ "algsc.tst", 76600000 ],
  [ "combinat.tst", 7000000 ],
  [ "ctblfuns.tst", 3300000 ],
  [ "ctblmoli.tst", 98500000 ],
  [ "ctblmono.tst", 31000000 ],
  [ "ctblsolv.tst", 54000000 ],
  [ "cyclotom.tst", 1000000 ],
  [ "ffe.tst", 2600000 ],
  [ "ffeconway.tst", 50200000 ],
  [ "gaussian.tst", 300000 ],
  [ "grpfp.tst", 146700000 ],
  [ "grpfree.tst", 700000 ],
  [ "grpmat.tst", 426300000 ],
  [ "grppc.tst", 42600000 ],
  [ "grppcnrm.tst", 2333400000 ],
  [ "listgen.tst", 1000000 ],
  [ "mapping.tst", 33000000 ],
  [ "mgmring.tst", 1500000 ],
  [ "modfree.tst", 5800000 ],
  [ "morpheus.tst", 82700000 ],
  [ "onecohom.tst", 50600000 ],
  [ "oprt.tst", 1500000 ],
  [ "ratfun.tst", 500000 ],
  [ "relation.tst", 7300000 ],
  [ "rwspcgrp.tst", 59400000 ],
  [ "semicong.tst", 7800000 ],
  [ "semigrp.tst", 13100000 ],
  [ "semirel.tst", 12400000 ],
  [ "vspchom.tst", 9500000 ],
  [ "vspcmat.tst", 10300000 ],
  [ "vspcrow.tst", 47400000 ],
  [ "xgap.tst", 1120100000 ],
  [ "zlattice.tst", 100000 ],
  [ "zmodnz.tst", 2800000 ],
] );


#############################################################################
##
#E

