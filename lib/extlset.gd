#############################################################################
##
#W  extlset.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for external left sets.
##
Revision.extlset_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsExtLSet( <D> )
##
##  An external left set is a domain with an action of a domain
##  from the left.
##
IsExtLSet := NewCategory( "IsExtLSet", IsDomain );


#############################################################################
##
#C  IsAssociativeLOpDProd( <D> )
##
##  is 'true' iff $a \* ( x \* y ) = ( a \* x ) \* y$
##  for $a \in E$ and $x, y \in D$.
##
IsAssociativeLOpDProd := NewCategory( "IsAssociativeLOpDProd", IsExtLSet );


#############################################################################
##
#C  IsAssociativeLOpEProd( <D> )
##
##  is 'true' iff $a \* ( b \* x ) = ( a \* b ) \* x$
##  for $a, b \in E$ and $x \in D$.
##
IsAssociativeLOpEProd := NewCategory( "IsAssociativeLOpEProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpDProd( <D> )
##
##  is 'true' iff $a \* ( x \* y ) = ( a \* x ) \* ( a \* y )$
##  for $a \in E$ and $x, y \in D$.
##
IsDistributiveLOpDProd := NewCategory( "IsDistributiveLOpDProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpDSum( <D> )
##
##  is 'true' iff $a \* ( x + y ) = ( a \* x ) + ( a \* y )$
##  for $a \in E$ and $x, y \in D$.
##
IsDistributiveLOpDSum := NewCategory( "IsDistributiveLOpDSum", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpEProd( <D> )
##
##  is 'true' iff $( a \* b ) \* x = ( a \* x ) \* ( b \* x )$
##  for $a, b \in E$ and $x \in D$.
##
IsDistributiveLOpEProd := NewCategory( "IsDistributiveLOpEProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpESum( <D> )
##
##  is 'true' iff $( a + b ) \* x = ( a \* x ) + ( b \* x )$
##  for $a, b \in E$ and $x \in D$.
##
IsDistributiveLOpESum := NewCategory( "IsDistributiveLOpESum", IsExtLSet );


#############################################################################
##
#C  IsTrivialLOpEOne( <D> )
##
##  is 'true' iff the identity element $e \in E$ acts trivially on $D$,
##  that is, $e \* x = x$ for $x \in D$.
#T necessary?
##
IsTrivialLOpEOne := NewCategory( "IsTrivialLOpEOne", IsExtLSet );


#############################################################################
##
#C  IsTrivialLOpEZero( <D> )
##
##  is 'true' iff the zero element $z \in E$ acts trivially on $D$,
##  that is, $z \* x = Z$ for $x \in D$ and the zero element $Z$ of $D$.
#T necessary?
##
IsTrivialLOpEZero := NewCategory( "IsTrivialLOpEZero", IsExtLSet );


#############################################################################
##
#C  IsLeftActedOnByRing( <D> )
##
IsLeftActedOnByRing := NewCategory( "IsLeftActedOnByRing", IsExtLSet );


#############################################################################
##
#P  IsLeftActedOnByDivisionRing( <D> )
##
##  This is a property because then we need not duplicate code that creates
##  either left modules or left vector spaces.
##
IsLeftActedOnByDivisionRing := NewProperty( "IsLeftActedOnByDivisionRing",
    IsExtLSet and IsLeftActedOnByRing );
SetIsLeftActedOnByDivisionRing := Setter( IsLeftActedOnByDivisionRing );
HasIsLeftActedOnByDivisionRing := Tester( IsLeftActedOnByDivisionRing );


#############################################################################
##
#C  IsLeftActedOnBySuperset( <D> )
##
IsLeftActedOnBySuperset := NewCategory( "IsLeftActedOnBySuperset",
    IsExtLSet );


#############################################################################
##
#A  GeneratorsOfExtLSet( <D> )
##
GeneratorsOfExtLSet := NewAttribute( "GeneratorsOfExtLSet", IsExtLSet );
SetGeneratorsOfExtLSet := Setter( GeneratorsOfExtLSet );
HasGeneratorsOfExtLSet := Tester( GeneratorsOfExtLSet );


#############################################################################
##
#A  LeftActingDomain( <D> )
##
LeftActingDomain := NewAttribute( "LeftActingDomain", IsExtLSet );
SetLeftActingDomain := Setter( LeftActingDomain );
HasLeftActingDomain := Tester( LeftActingDomain );


#############################################################################
##
#E  extlset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



