#############################################################################
##
#W  grppcnrm.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for normalizers of polycylic groups.
##
Revision.grppcnrm_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoPcNormalizer
##
InfoPcNormalizer := NewInfoClass( "InfoPcNormalizer" );


#############################################################################
##
#A  NormalizerInHomePcgs( <pcgrp> )
##
NormalizerInHomePcgs := NewAttribute(
    "NormalizerInHomePcgs",
    IsGroup and HasHomePcgs );


#############################################################################
##

#E  grppcnrm.gd	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
