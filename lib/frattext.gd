#############################################################################
##
#W  frattext.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.frattext_gd :=
    "@(#)$Id$";

#############################################################################
##
#I Infos
##
DeclareInfoClass( "InfoFEMeth" );

#############################################################################
##
#A FrattiniFactor 
##
DeclareAttribute( "FrattiniFactor", IsGroup );

#############################################################################
##
#A FrattExtInfo 
##
DeclareAttribute( "FrattExtInfo", IsGroup, "mutable" );

DeclareGlobalFunction( "RandomIsomorphismTest" );

