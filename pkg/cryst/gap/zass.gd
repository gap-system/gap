#############################################################################
##
#A  zass.gd                   Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Routines for the determination of space groups for a given a point group
##

#############################################################################
##
#O  SpaceGroupsByPointGroupOnRight( <grp> [, <norm> [, <orbsflag> ] ] )
##
DeclareOperation("SpaceGroupsByPointGroupOnRight",[IsCyclotomicMatrixGroup]);

#############################################################################
##
#O  SpaceGroupsByPointGroupOnLeft( <grp> [, <norm> [, <orbsflag> ] ] )
##
DeclareOperation("SpaceGroupsByPointGroupOnLeft", [IsCyclotomicMatrixGroup]);

#############################################################################
##
#O  SpaceGroupsByPointGroup( <grp> [, <norm> [, <orbsflag> ] ] )
##
DeclareOperation( "SpaceGroupsByPointGroup", [ IsCyclotomicMatrixGroup ] );

#############################################################################
##
#O  SpaceGroupTypesByPointGroupOnRight( <grp> [, <orbsflag> ] )
##
DeclareOperation("SpaceGroupTypesByPointGroupOnRight", 
                                               [ IsCyclotomicMatrixGroup ] );

#############################################################################
##
#O  SpaceGroupTypesByPointGroupOnLeft( <grp> [, <orbsflag> ] )
##
DeclareOperation("SpaceGroupTypesByPointGroupOnLeft", 
                                               [ IsCyclotomicMatrixGroup ] );

#############################################################################
##
#O  SpaceGroupTypesByPointGroup( <grp> [, <orbsflag> ] )
##
DeclareOperation( "SpaceGroupTypesByPointGroup", [IsCyclotomicMatrixGroup] );

