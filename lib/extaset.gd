#############################################################################
##
#W  extaset.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for external additive sets.
##
Revision.extaset_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsExtASet( <D> )
##
##  An external additive set is a domain with an action of a domain via '\+'.
##  Since the operator '\+' in {\GAP} is commutative we do not distinguish
##  actions from left and right.
##
IsExtASet := NewCategory( "IsExtASet", IsDomain and IsAdditiveElement );


#############################################################################
##
#C  IsAssociativeAOpDSum( <D> )
##
##  is 'true' iff $a \+ ( x \+ y ) = ( a \+ x ) \+ y$
##  for $a \in E$ and $x, y \in D$.
##
IsAssociativeAOpDSum := NewCategory( "IsAssociativeAOpDSum", IsExtASet );


#############################################################################
##
#C  IsAssociativeAOpESum( <D> )
##
##  is 'true' iff $a \+ ( b \+ x ) = ( a \+ b ) \+ x$
##  for $a, b \in E$ and $x \in D$.
##
IsAssociativeAOpESum := NewCategory( "IsAssociativeAOpESum", IsExtASet );


#############################################################################
##
#C  IsTrivialAOpEZero( <D> )
##
##  is 'true' iff the zero element $z \in E$ acts trivially on $D$,
##  that is, $z \+ x = x$ for $x \in D$.
#T necessary?
##
IsTrivialAOpEZero := NewCategory( "IsTrivialAOpEZero", IsExtASet );


#############################################################################
##
#A  GeneratorsOfExtASet( <D> )
##
GeneratorsOfExtASet := NewAttribute( "GeneratorsOfExtASet", IsExtASet );
SetGeneratorsOfExtASet := Setter( GeneratorsOfExtASet );
HasGeneratorsOfExtASet := Tester( GeneratorsOfExtASet );


#############################################################################
##
#A  AdditivelyActingDomain( <D> )
##
AdditivelyActingDomain := NewAttribute( "AdditivelyActingDomain",
    IsExtASet );
SetAdditivelyActingDomain := Setter( AdditivelyActingDomain );
HasAdditivelyActingDomain := Tester( AdditivelyActingDomain );


#############################################################################
##
#E  extaset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



