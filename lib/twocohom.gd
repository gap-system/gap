#############################################################################
##
#W  twocohom.gd                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.twocohom_gd :=
    "@(#)$Id$";

#############################################################################
##
#F  CollectedWordSQ( <C>, <u>, <v> ) 
##
DeclareGlobalFunction( "CollectedWordSQ" );

#############################################################################
##
#F  CollectorSQ( <G>, <M>, <isSplit> )
##
DeclareGlobalFunction( "CollectorSQ" );

#############################################################################
##
#F  AddEquationsSQ( <eq>, <t1>, <t2> )
##
DeclareGlobalFunction( "AddEquationsSQ" );

#############################################################################
##
#F  SolutionSQ( <C>, <eq> )
##
DeclareGlobalFunction( "SolutionSQ" );

#############################################################################
##
#F  TwoCocyclesSQ( <C>, <G>, <M> )
##
DeclareGlobalFunction( "TwoCocyclesSQ" );

#############################################################################
##
#F  TwoCoboundariesSQ( <C>, <G>, <M> )
##
DeclareGlobalFunction( "TwoCoboundariesSQ" );

#############################################################################
##
#F  TwoCohomologySQ( <C>, <G>, <M> )
##
DeclareGlobalFunction( "TwoCohomologySQ" );

#############################################################################
##
#O  TwoCocycles( <G>, <M> )
##
##  returns the group of 2-cocycles of <G> by the <G>-module <M>. This group
##  is given as vector space over the field underlying <M>.
DeclareOperation( "TwoCocycles", [ IsPcGroup, IsObject ] );

#############################################################################
##
#O  TwoCoboundaries( <G>, <M> )
##
##  returns the group of 2-coboundaries of <G> by the <G>-module <M>. This
##  group is given as vector space over the field underlying <M>.
DeclareOperation( "TwoCoboundaries", [ IsPcGroup, IsObject ] );

#############################################################################
##
#O  TwoCohomology( <G>, <M> )
##
##  returns a record defining the second cohomology group as factor space of 
##  the space of cocycles by the space of coboundaries.
DeclareOperation( "TwoCohomology", [ IsPcGroup, IsObject ] );

