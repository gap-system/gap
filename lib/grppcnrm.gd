#############################################################################
##
#W  grppcnrm.gd                 GAP Library                      Frank Celler
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for normalizers of polycylic groups.
##


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
