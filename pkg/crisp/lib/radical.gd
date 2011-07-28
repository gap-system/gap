#############################################################################
##
##  radical.gd                      CRISP                   Burkhard Höfling
##
##  @(#)$Id: radical.gd,v 1.5 2011/05/15 19:17:58 gap Exp $
##
##  Copyright (C) 2000, 2002 Burkhard Höfling
##
Revision.radical_gd :=
    "@(#)$Id: radical.gd,v 1.5 2011/05/15 19:17:58 gap Exp $";


#############################################################################
##
#A  Radical (<grp>, <class>)
##
##  this is defined for arbitrary classes to allow radicals wrt. Fitting sets
##
KeyDependentOperation ("Radical", IsGroup, IsClass, ReturnTrue);


#############################################################################
##
#O  OneInvariantSubgroupMaxWrtNProperty
#O                           (<act>, <grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("OneInvariantSubgroupMaxWrtNProperty", 
   [IsListOrCollection, IsGroup, IsFunction, IsFunction, IsObject]);


#############################################################################
##
#O  AllInvariantSubgroupsWithNProperty 
#O                           (<act>, <grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("AllInvariantSubgroupsWithNProperty",
    [IsListOrCollection, IsGroup, IsFunction, IsFunction, IsObject]);
   

#############################################################################
##
#O  OneNormalSubgroupMaxWrtNProperty
#O                           (<act>, <grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("OneNormalSubgroupMaxWrtNProperty", 
   [IsGroup, IsFunction, IsFunction, IsObject]);


#############################################################################
##
#O  AllNormalSubgroupsWithNProperty
#O                           (<grp>, <pretest>, <test>, <data>)
##
##  See the manual.
##
DeclareOperation ("AllNormalSubgroupsWithNProperty",
    [IsGroup, IsFunction, IsFunction, IsObject]);
   

#############################################################################
##
#F  InvariantSubgroupsCA (
#F                          act, ser, avoid, cover, property, max) . . . local
##
##  ser must be a series invariant under act, and act must generate the full 
##  inner automorphism group on ser[1].
##  if all is true, InvariantSubgroupsCA computes the act-invariant 
##  subgroups N of ser[1] such that ser[cover] equals the intersection of N
##  and ser[avoid], N contains ser[cover] properly, and property(N) returns 
##  true. 
##  If all is false, InvariantSubgroupsCA only returns the 
##  subgroups N
##  which are maximal subject to the above conditions. property must be
##  inherited by act-invariant subgroups, and property(ser[cover])
##  is assumed to be true
##
DeclareGlobalFunction ("InvariantSubgroupsCA");


############################################################################
##
#E
##
