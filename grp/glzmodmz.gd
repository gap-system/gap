#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Stefan Kohl, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for constructing classical groups over
##  residue class rings.

#############################################################################
##
#F  SizeOfGLdZmodmZ( d, m ) . . . . . . . . . .  Size of the group GL(d,Z/mZ)
##
##  Computes the order of the group `GL( <d>, Integers mod <m> )' for
##  positive integers <d> and <m> > 1.
##
DeclareGlobalFunction( "SizeOfGLdZmodmZ" );

#############################################################################
##
#F  ConstructFormPreservingGroup(oper [,sign] d, R )
##
##  constructs the classical group sefined by <A>oper</A> over a prime field
##  over the residue class ring <A>R</A>, which must be modulo an odd prime
##  power.
DeclareGlobalFunction("ConstructFormPreservingGroup");
