#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Scott Murray, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for mappings between groups and additive
##  groups.
##


#############################################################################
##
#F  GroupToAdditiveGroupHomomorphismByFunction( <S>, <R>, <fun> )
#F  GroupToAdditiveGroupHomomorphismByFunction( <S>, <R>, <fun>, <invfun> )
##
##  `GroupToAdditiveGroupHomomorphismByFunction' returns a
##  group-to-additive-group homomorphism <hom> with
##  source <S> and range <R>, such that each element <s> of <S> is mapped to
##  the element `<fun>( <s> )', where <fun> is a {\GAP} function.
##
##  If the argument <invfun> is bound then <hom> is a bijection between <S>
##  and <R>, and the preimage of each element <r> of <R> is given by
##  `<invfun>( <r> )', where <invfun> is a {\GAP}  function.
##
##  No test is performed on whether the functions actually give an
##  homomorphism between both groups because this would require testing the
##  full multiplication table.
##
##  `GroupToAdditiveGroupHomomorphismByFunction' creates a mapping which
##  `IsSPGeneralMapping'.
##
DeclareGlobalFunction("GroupToAdditiveGroupHomomorphismByFunction");
