#############################################################################
##
#W  grppcnrm.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for normalizers of polycylic groups.
##
Revision.grppcnrm_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoPcNormalizer
##
DeclareInfoClass( "InfoPcNormalizer" );


#############################################################################
##
#A  NormalizerInHomePcgs( <pcgrp> )
##
DeclareAttribute(
    "NormalizerInHomePcgs",
    IsGroup and HasHomePcgs );


#############################################################################
##

#E  grppcnrm.gd	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
