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
##  The test requires about 750MB of memory and runs about one hour on an 
##  Intel Core 2 Duo / 2.53 GHz machine, and produces an output similar 
##  to the <File>testinstall.g</File> test.
##  <#/GAPDoc>
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 750m'.\n",
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
  [ "alghom.tst",6000000],
  [ "algmat.tst",180800000],
  [ "algsc.tst",59000000],
  [ "arithlst.tst",52558700000],
  [ "boolean.tst",100000],
  [ "bugfix.tst",15319000000*10],
  [ "combinat.tst",5300000],
  [ "ctbl.tst",14300000],
  [ "ctblfuns.tst",3900000],
  [ "ctblmoli.tst",98500000],
  [ "ctblmono.tst",33400000],
  [ "ctblsolv.tst",54000000],
  [ "cyclotom.tst",900000],
  [ "eigen.tst",2500000],
  [ "ffe.tst",3600000],
  [ "ffeconway.tst",50200000],
  [ "fldabnum.tst",13400000],
  [ "float.tst",500000],
  [ "gaussian.tst",300000],
  [ "grpconst.tst",20754500000*10],
  [ "grpfp.tst",146700000],
  [ "grpfree.tst",700000],
  [ "grplatt.tst",971100000],
  [ "grpmat.tst",481000000],
  [ "grppc.tst",45300000],
  [ "grppcnrm.tst",2333400000],
  [ "grpperm.tst",490500000],
  [ "grpprmcs.tst",4153600000],
  [ "hash2.tst",3702400000],
  [ "helpsys.tst",58077900000],
  [ "intarith.tst",2300000],
  [ "listgen.tst",1000000],
  [ "longnumber.tst",100000],
  [ "mapphomo.tst",4800000],
  [ "mapping.tst",37300000],
  [ "matblock.tst",700000],
  [ "matrix.tst",882500000],
  [ "mgmring.tst",1800000],
  [ "modfree.tst",5800000],
  [ "morpheus.tst",87200000],
  [ "onecohom.tst",50600000],
  [ "oprt.tst",2000000],
  [ "package.tst",100000],
  [ "pperm.tst", 6000000],
  [ "primsan.tst",125486700000],
  [ "ratfun.tst",800000],
  [ "reesmat.tst",6000000],
  [ "relation.tst",7700000],
  [ "rwspcgrp.tst",59400000],
  [ "rwspcsng.tst",81100000],
  [ "semicong.tst",7800000],
  [ "semigrp.tst",11200000],
  [ "semirel.tst",10900000],
  [ "set.tst",5600000],
  [ "strings.tst", 100000],
  [ "read.tst", 10000 ],
  [ "trans.tst", 6000000],
  [ "union.tst", 100000],
  [ "unknown.tst",100000],
  [ "varnames.tst",3600000/1000],
  [ "vspchom.tst",10500000],
  [ "vspcmali.tst",11100000],
  [ "vspcmat.tst",8400000],
  [ "vspcrow.tst",47400000],
  [ "weakptr.tst",11500000],
  [ "xgap.tst",1206600000],
  [ "zlattice.tst",100000],
  [ "zmodnz.tst",2300000],
] ); 


#############################################################################
##
#E

