#############################################################################
##
#W  rss.gd			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: rss.gd,v 4.4 2002/04/15 10:05:15 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  The random Schreier-Sims algorithm for permutation groups and matrix 
##  groups.
##
##  Requires: chain
##  Exports: functions RandomSchreierSims and ChangedBaseGroup
##
Revision.rss_gd :=
    "@(#)$Id: rss.gd,v 4.4 2002/04/15 10:05:15 sal Exp $";

DeclareInfoClass( "InfoRSS" );

#############################################################################
##
#F  SetValueOption( <fieldname>, <value> )
##
##  Set the value of an option.
##
DeclareGlobalFunction( "SetValueOption" );

#############################################################################
##
#F  ReturnPopOptions( <> )
##
##  Pop an option and return it.
##
DeclareGlobalFunction( "ReturnPopOptions" );

#############################################################################
##
#F  RandomSchreierSims( <G> )
##
##  The random Schreier-Sims algorithm.
##
DeclareGlobalFunction( "RandomSchreierSims" );

#############################################################################
##
#F  ChangedBaseGroup( <G> )
##
##  We assume we have a chain for <G>, which gives a complete BSGS.
##  We are given a new base <newBase> and wish to find strong generators for 
##  it. Options are the same as for random Schreier-Sims.  
##  Note that this function does not modify <G>, but returns a new group,
##  isomorphic to <G> with the specified base.
##
DeclareGlobalFunction( "ChangedBaseGroup" );

#############################################################################
##
#F  RSSDefaultOptions( <G>, <opt> )
##
##  Return the default options for random Schreier-Sims.
##
DeclareGlobalFunction( "RSSDefaultOptions" );

#############################################################################
##
#F  SiftForStrongGenerator( <G>, <newsg> )
##
##
##  Sift the group element <newsg> and, if it does not sift to the identity
##  add it to the strong generators.  Add a new base point (if necessary)
##  and recompute orbits.
##
DeclareGlobalFunction( "SiftForStrongGenerator" );

#############################################################################
##
#F  StopNumSift( <n> )
##
##  Stop when <n> elements have been sifted
##
DeclareGlobalFunction( "StopNumSift" );

#############################################################################
##
#F  StopNumConsecSiftToOne( <n> )
##
##  Stop when <n> consecutive elements sift to 1.
##
DeclareGlobalFunction( "StopNumConsecSiftToOne" );

#############################################################################
##
#F  StopSize( <> )
##
##  Stop when the size of the group is the same as the size of the chain.
##
DeclareGlobalFunction( "StopSize" );

#############################################################################
##
#F  ReturnNextBasePoint( <G>, <newsg> )
##
##  Return a new base point which is fixed by <newsg>.
##
DeclareGlobalFunction( "ReturnNextBasePoint" );

#############################################################################
##
#F  PermNewBasePoint( <G>, <newsg> )
##
##  Return a new base point which is fixed by <newsg> for perm groups.
##
DeclareGlobalFunction( "PermNewBasePoint", [ IsGroup, IsPerm ] );

#############################################################################
##
#F  MatrixNewBasePoint( <G>, <newsg> )
##
##  Return a new base point which is fixed by <newsg> for matrix groups.
##
DeclareGlobalFunction( "MatrixNewBasePoint", [ IsGroup, IsMatrix ] );


#############################################################################
#############################################################################
##
##  Matrix group base point functions
##
#############################################################################
#############################################################################

#############################################################################
##
#O  EspaceBasePoints( <G> )
##
##  Intersections of eigenspaces to use as base points.
##
DeclareOperation( "EspaceBasePoints", [ IsFFEMatrixGroup ] );

#############################################################################
##
#O  EvectBasePoints( <G> )
##
##  Eigenvectors to use as base points.
##
DeclareOperation( "EvectBasePoints", [ IsFFEMatrixGroup ] );

#E
