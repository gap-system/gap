#############################################################################
##  
#W Normal.gd                   FGA package                  Christian Sievers
##
## The declaration file for the computation of normalizers in free groups
##
#H @(#)$Id: Normal.gd,v 1.1 2003/03/21 14:38:01 gap Exp $
##
#Y 2003
##
Revision.("fga/lib/Normal_gd") :=
    "@(#)$Id: Normal.gd,v 1.1 2003/03/21 14:38:01 gap Exp $";


#############################################################################
##
#A  NormalizerInWholeGroup( <group> )
##
##  returns the normalizer of <group> in the group of the whole family
##
DeclareAttribute( "NormalizerInWholeGroup", IsFreeGroup );


#############################################################################
##
#E

