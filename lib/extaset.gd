#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for external additive sets.
##


#############################################################################
##
#C  IsExtASet( <D> )
##
##  An external additive set is a domain with an action of a domain via `\+'.
##  Since the operator `\+' in {\GAP} is commutative we do not distinguish
##  actions from left and right.
##
DeclareCategory( "IsExtASet", IsDomain and IsAdditiveElement );


#############################################################################
##
#C  IsAssociativeAOpDSum( <D> )
##
##  is `true' iff $a \+ ( x \+ y ) = ( a \+ x ) \+ y$
##  for $a \in E$ and $x, y \in D$.
##
DeclareCategory( "IsAssociativeAOpDSum", IsExtASet );


#############################################################################
##
#C  IsAssociativeAOpESum( <D> )
##
##  is `true' iff $a \+ ( b \+ x ) = ( a \+ b ) \+ x$
##  for $a, b \in E$ and $x \in D$.
##
DeclareCategory( "IsAssociativeAOpESum", IsExtASet );


#############################################################################
##
#C  IsTrivialAOpEZero( <D> )
##
##  is `true' iff the zero element $z \in E$ acts trivially on $D$,
##  that is, $z \+ x = x$ for $x \in D$.
#T necessary?
##
DeclareCategory( "IsTrivialAOpEZero", IsExtASet );


#############################################################################
##
#A  GeneratorsOfExtASet( <D> )
##
DeclareAttribute( "GeneratorsOfExtASet", IsExtASet );


#############################################################################
##
#A  AdditivelyActingDomain( <D> )
##
DeclareAttribute( "AdditivelyActingDomain",
    IsExtASet );
