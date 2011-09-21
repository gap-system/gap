#############################################################################
##
#W  testall.g                   GAP library                      Frank Celler
##
#H  @(#)$Id$
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
##  <#GAPDoc Label="[1]{testall.g}">
##  If you want to run a more advanced check (this is not required and 
##  make take up to an hour), you can read <File>testall.g</File>
##  which is an extended test script performing all tests from the 
##  <File>tst</File> directory.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testall.g" ) );
##  ]]></Log>
##  <P/>
##  The test requires about 512MB of memory and runs about one hour on an 
##  Intel Core 2 Duo / 2.53 GHz machine, and produces an output similar 
##  to the <File>testinstall.g</File> test.
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -N -A -x 80 -r -m 100m -o 512m'.\n",
       "The more GAP4stones you get, the faster your system is.\n",
       "The runtime of the following tests (in general) increases.\n",
       "******************************************************************\n",
       "You should expect the test to take about *ONE HOUR* and show about\n",
       "100000 GAP4stones on an Intel Core 2 Duo / 2.53 GHz machine.\n",
       "For a quick test taking about one minute, use 'testinstall.g'\n",
       "******************************************************************\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

Reread( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );

RunStandardTests( [
  [ "alghom.tst",63000568],
  [ "algmat.tst",1441013704],
  [ "algsc.tst",296002170],
  [ "arithlst.tst", 2000000 ],
  [ "boolean.tst", 39000 ],
  [ "bugfix.tst", 7621100000 ],
  [ "combinat.tst", 270000000 ],
  [ "ctbl.tst", 2250828729 ],
  [ "ctblfuns.tst", 31000000 ],
  [ "ctblmoli.tst",416003661],
  [ "ctblmono.tst",274001908],
  [ "ctblsolv.tst",391002100],
  [ "cyclotom.tst",5832500],
  [ "eigen.tst", 17000000 ],
  [ "ffe.tst", 18000000 ],
  [ "ffeconway.tst", 270000000 ],
  [ "fldabnum.tst",74000378],
  [ "float.tst", 1000000 ],
  [ "gaussian.tst", 640000 ],
  [ "grpconst.tst", 130921000000 ],
  [ "grpfp.tst", 5000000 ],
  [ "grpfree.tst", 5000000 ],
  [ "grplatt.tst",4630000839],
  [ "grpmat.tst",1560006131],
  [ "grppc.tst",116000670],
  [ "grppcnrm.tst",1532002851],
  [ "grpperm.tst",1894002856],
  [ "grpprmcs.tst",12735051238],
  [ "hash2.tst", 20000000 ],
  [ "helpsys.tst", 79318448],
  [ "listgen.tst", 1440000 ],
  [ "longnumber.tst", 2000000 ],
  [ "mapphomo.tst", 9000000 ],
  [ "mapping.tst", 31000000 ],
  [ "matblock.tst", 1200000 ],
  [ "matrix.tst",3721017553],
  [ "mgmring.tst", 19000000 ],
  [ "modfree.tst",36000000 ],
  [ "morpheus.tst", 524900000 ],
  [ "onecohom.tst",332001351],
  [ "oprt.tst",23823519],
  [ "package.tst", 4711 ],
  [ "primsan.tst", 105797500 ],
  [ "ratfun.tst", 9000000 ],
  [ "relation.tst", 48010000 ],
  [ "rwspcgrp.tst",252000906],
  [ "rwspcsng.tst",346001450],
  [ "semicong.tst", 46000000 ],
  [ "semigrp.tst",135000574],
  [ "semirel.tst",364004597],
  [ "set.tst", 21000000 ],
  [ "unknown.tst", 170000 ],
  [ "varnames.tst", 2000 ],
  [ "vspchom.tst",74000701],
  [ "vspcmali.tst",56000263],
  [ "vspcmat.tst",52000692],
  [ "vspcrow.tst",195001138],
  [ "weakptr.tst", 24477500 ],
  [ "xgap.tst",562000888],
  [ "zlattice.tst", 136000 ],
  [ "zmodnz.tst", 2100000 ],
] ); 


#############################################################################
##
#E

