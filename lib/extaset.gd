#############################################################################
##
#W  extaset.gd                  GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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


#############################################################################
##
#E  extaset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



