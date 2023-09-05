#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares operations related to discrete logarithms.
##


#############################################################################
##
#F  _DLog( <base>, <x>[, <m>] )
##
##  <ManSection>
##  <Func Name="_DLog" Arg='base, x[, m]'/>
##
##  <Description>
##  <Index Subkey="discrete">logarithm</Index>
##  returns a discrete logarithm of <A>x</A> w.r.t. the basis <A>base</A>,
##  i. e., an integer <M>l</M> such that <M><A>base</A>^l = <A>x</A></M>
##  holds, if such a number exists.
##  Otherwise <K>fail</K> is returned.
##  <P/>
##  The order of <A>base</A> or its factorization can be given as <A>m</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "_DLog" );

DeclareGlobalFunction( "_DLogShanks" );
