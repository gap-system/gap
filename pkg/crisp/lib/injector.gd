#############################################################################
##
##  injector.gd                      CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: injector.gd,v 1.1 2000/05/23 15:01:46 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
Revision.injector_gd :=
    "@(#)$Id: injector.gd,v 1.1 2000/05/23 15:01:46 gap Exp $";


#############################################################################
##
#V  InfoInjector
##
DeclareInfoClass ("InfoInjector");


#############################################################################
##
#A  Injector (<grp>, <class>)
##
KeyDependentOperation ("Injector", IsGroup, IsClass, ReturnTrue);


#############################################################################
##
#F  InjectorFromRadicalFunction (<grp>, <func>, <hom>)
##
##  compute an F-injector of <grp>, from a function func which computes the 
##  F-radical for any subgroup of <grp>. If <hom> is true, computations are
##  carried out in factor groups wherever possible.
##
DeclareGlobalFunction ("InjectorFromRadicalFunction");


############################################################################
##
#E
##
