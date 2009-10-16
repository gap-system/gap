#############################################################################
##
#W  Iterated.gd             FGA package                    Christian Sievers
##
##  Declarations for variants of Iterated
##
##  Maybe this should move to the GAP library
##
#H  @(#)$Id: Iterated.gd,v 1.1 2003/03/21 14:38:01 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/Iterated_gd") :=
    "@(#)$Id: Iterated.gd,v 1.1 2003/03/21 14:38:01 gap Exp $";


#############################################################################
##
#O  IteratedF( <list>, <func> )
##
##  applies <func> to <list> iteratively as Iterated does, but stops
##  and returns fail when <func> returns fail.
##
DeclareOperation( "IteratedF", [ IsList, IsFunction ] );


#############################################################################
##
#E
