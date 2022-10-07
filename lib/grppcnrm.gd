#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for normalizers of polycyclic groups.
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
