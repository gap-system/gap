#############################################################################
##
#W  grppcnrm.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id: grppcnrm.gd,v 4.8 2002/04/15 10:04:52 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for normalizers of polycylic groups.
##
Revision.grppcnrm_gd :=
    "@(#)$Id: grppcnrm.gd,v 4.8 2002/04/15 10:04:52 sal Exp $";


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
