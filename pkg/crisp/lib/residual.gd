#############################################################################
##
##  residual.gd                      CRISP                   Burkhard Höfling
##
##  @(#)$Id: residual.gd,v 1.7 2011/05/15 19:17:58 gap Exp $
##
##  Copyright (C) 2000-2002, 2006 by Burkhard Höfling
##
Revision.residual_gd :=
    "@(#)$Id: residual.gd,v 1.7 2011/05/15 19:17:58 gap Exp $";


#############################################################################
##
#A  Residual (<grp>, <class>)
##
KeyDependentOperation ("Residual", IsGroup, IsGroupClass, ReturnTrue);
DeclareOperation ("Residuum", [IsGroup, IsGroupClass]);


#############################################################################
##
#A  CharacteristicSubgroups (<grp>)
##
##  See the manual.
##
DeclareAttribute ("CharacteristicSubgroups", IsGroup);


#############################################################################
##
#O  OneInvariantSubgroupMinWrtQProperty 
#O                                  (<act>, <grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("OneInvariantSubgroupMinWrtQProperty", 
   [IsListOrCollection, IsGroup, IsFunction, IsFunction, IsObject]);


############################################################################
##
#O  AllInvariantSubgroupsWithQProperty 
#O                                 (<act>, <grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("AllInvariantSubgroupsWithQProperty", 
   [IsListOrCollection, IsGroup, IsFunction, IsFunction, IsObject]);


#############################################################################
##
#O  OneNormalSubgroupMinWrtQProperty (<grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("OneNormalSubgroupMinWrtQProperty", 
   [IsGroup, IsFunction, IsFunction, IsObject]);


############################################################################
##
#O  AllNormalSubgroupsWithQProperty <grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("AllNormalSubgroupsWithQProperty", 
   [IsGroup, IsFunction, IsFunction, IsObject]);


############################################################################
##
#E
##
