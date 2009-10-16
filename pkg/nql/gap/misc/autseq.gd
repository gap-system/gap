############################################################################
##
#W  autseq.gd			NQL				René Hartung
## 								Bettina Eick
##
#H   @(#)$Id: autseq.gd,v 1.1 2009/07/02 12:50:59 gap Exp $
##
Revision.("nql/misc/autseq_gd"):=
  "@(#)$Id: autseq.gd,v 1.1 2009/07/02 12:50:59 gap Exp $";

############################################################################
##
#O AutomorphismGroupSequence( <PcpGroup> )
##
############################################################################
DeclareOperation( "AutomorphismGroupSequence", [ IsGroup ] );


############################################################################
##
#F NQL_AutGroupPGroup
##
############################################################################
DeclareGlobalFunction( "NQL_AutGroupPGroup" );
