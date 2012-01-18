#############################################################################
##
#W  testall.g                   GAP library                      Frank Celler
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
       "125000 GAP4stones on an Intel Core 2 Duo / 2.53 GHz machine.\n",
       "For a quick test taking about one minute, use 'testinstall.g'\n",
       "******************************************************************\n",
       "The `next' time is an approximation of the running time ",
       "for the next file.\n\n" );

Reread( Filename( DirectoriesLibrary( "tst" ), "testutil.g" ) );

RunStandardTests( [
  [ "alghom.tst",5300000],
  [ "algmat.tst",287300000],
  [ "algsc.tst",76600000],
  [ "arithlst.tst",48429100000],
  [ "boolean.tst",100000],
  [ "bugfix.tst",14914100000*10],
  [ "combinat.tst",7000000],
  [ "ctbl.tst",15300000],
  [ "ctblfuns.tst",3300000],
  [ "ctblmoli.tst",98500000],
  [ "ctblmono.tst",31000000],
  [ "ctblsolv.tst",54000000],
  [ "cyclotom.tst",1000000],
  [ "eigen.tst",800000],
  [ "ffe.tst",2600000],
  [ "ffeconway.tst",50200000],
  [ "fldabnum.tst",12500000],
  [ "float.tst",800000],
  [ "gaussian.tst",300000],
  [ "grpconst.tst",19528600000*10],
  [ "grpfp.tst",146700000],
  [ "grpfree.tst",700000],
  [ "grplatt.tst",904800000],
  [ "grpmat.tst",426300000],
  [ "grppc.tst",42600000],
  [ "grppcnrm.tst",2333400000],
  [ "grpperm.tst",490500000],
  [ "grpprmcs.tst",4153600000],
  [ "hash2.tst",3702400000],
  [ "helpsys.tst",47567800000],
  [ "listgen.tst",1000000],
  [ "longnumber.tst",300000],
  [ "mapphomo.tst",4300000],
  [ "mapping.tst",33000000],
  [ "matblock.tst",700000],
  [ "matrix.tst",769200000],
  [ "mgmring.tst",1500000],
  [ "modfree.tst",5800000],
  [ "morpheus.tst",82700000],
  [ "onecohom.tst",50600000],
  [ "oprt.tst",1500000],
  [ "package.tst",100000],
  [ "primsan.tst",139570200000],
  [ "ratfun.tst",500000],
  [ "relation.tst",7300000],
  [ "rwspcgrp.tst",59400000],
  [ "rwspcsng.tst",81100000],
  [ "semicong.tst",7800000],
  [ "semigrp.tst",13100000],
  [ "semirel.tst",12400000],
  [ "set.tst",5600000],
  [ "unknown.tst",100000],
  [ "varnames.tst",2011],
  [ "vspchom.tst",9500000],
  [ "vspcmali.tst",9800000],
  [ "vspcmat.tst",10300000],
  [ "vspcrow.tst",47400000],
  [ "weakptr.tst",11500000],
  [ "xgap.tst",1120100000],
  [ "zlattice.tst",100000],
  [ "zmodnz.tst",2800000],
] ); 


#############################################################################
##
#E

