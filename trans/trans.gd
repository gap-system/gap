#############################################################################
##
#W  trans.gd          GAP transitive groups library          Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for the transitive groups library
##
Revision.trans_gd:=
  "@(#)$Id$";

#############################################################################
##
#F  TransitiveGroup(<deg>,<nr>)
##
##  returns the <nr>-th transitive  group of degree <deg>.  Both  <deg> and
##  <nr> must be  positive integers. The transitive groups of equal  degree
##  are  sorted with  respect to   their  size, so for  example
##  `TransitiveGroup(  <deg>, 1 )' is a  transitive group  of degree and
##  size <deg>, e.g, the cyclic  group  of size <deg>,   if <deg> is a
##  prime.
DeclareGlobalFunction("TransitiveGroup");

#############################################################################
##
#F  NrTransitiveGroups(<deg>)
##
##  returns the number of transitive groups of degree <deg> stored in the
##  library of transitive groups. The function returns `fail' if <deg> is
##  beyond the range of the library.
DeclareGlobalFunction("NrTransitiveGroups");

DeclareGlobalVariable( "TRANSCOMBCACHE", "combinations cache" );
DeclareGlobalVariable( "TRANSARRCACHE", "arrangements cache" );
