#############################################################################
##
#W  testinst.g          GAP 4 package `ctbllib'                 Thomas Breuer
##
#H  @(#)$Id: testinst.g,v 1.3 2006/09/13 16:14:07 gap Exp $
##
#Y  Copyright (C)  2003,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains those tests for the CTblLib package that are
##  recommended for being executed after the package has been installed.
##  Currently just a few character tables are accessed.
##
##  <#GAPDoc Label="testinst">
##  For checking the installation of the package, you should start &GAP;,
##  load the package (see&nbsp;<Ref Sect="sec:loading"/>,
##  and then call
##  <P/>
##  <Log>
##  gap> ReadPackage( "ctbllib", "tst/testinst.g" );
##  </Log>
##  <P/>
##  If the installation is o.&nbsp;k. then <K>true</K> is printed,
##  and the &GAP; prompt appears again;
##  otherwise the output lines tell you what should be changed.
##  <P/>
##  More testfiles are available in the <F>tst</F> directory of the package.
##  <#/GAPDoc>
##

if not IsCharacterTable( CharacterTable( "A5" ) ) then
  # a simple ATLAS table
  Print( "#E  Package `ctbllib':  ",
         "Ordinary tables cannot be read from the data files.\n",
         "#E  Please check whether the files in `pkg/ctbllib/data' ",
         "are readable.\n" );
fi;
if not IsCharacterTable( CharacterTable( "3.A6.2_2" ) ) then
  # a table encoded by a construction
  Print( "#E  Package `ctbllib':  ",
         "Constructions of library tables from others do not work.\n",
         "#E  Please check whether the files in `pkg/ctbllib/gap4' ",
         "are available.\n" );
fi;
if not IsCharacterTable( CharacterTable( "GL", 2, 4 ) ) then
  # a specialization of a generic table
  Print( "#E  Package `ctbllib':  ",
         "Specialization of generic tables does not work.\n",
         "#E  Please check whether the files in `pkg/ctbllib/gap4' ",
         "are available.\n" );
fi;
if not IsString( OneCharacterTableName( IsSimple, true ) ) then
  # a new function
  Print( "#E  Package `ctbllib':  ",
         "The function `OneCharacterTableName' does not work.\n",
         "#E  Please check whether the files in `pkg/ctbllib/gap4' ",
         "are available.\n" );
fi;


#############################################################################
##
#E

