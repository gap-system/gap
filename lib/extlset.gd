#############################################################################
##
#W  extlset.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareCategory( "IsExtLSet", IsDomain );


#############################################################################
##
#C  IsAssociativeLOpDProd( <D> )
##
##  is 'true' iff $a \* ( x \* y ) = ( a \* x ) \* y$
##  for $a \in E$ and $x, y \in D$.
##
DeclareCategory( "IsAssociativeLOpDProd", IsExtLSet );


#############################################################################
##
#C  IsAssociativeLOpEProd( <D> )
##
##  is 'true' iff $a \* ( b \* x ) = ( a \* b ) \* x$
##  for $a, b \in E$ and $x \in D$.
##
DeclareCategory( "IsAssociativeLOpEProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpDProd( <D> )
##
##  is 'true' iff $a \* ( x \* y ) = ( a \* x ) \* ( a \* y )$
##  for $a \in E$ and $x, y \in D$.
##
DeclareCategory( "IsDistributiveLOpDProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpDSum( <D> )
##
##  is 'true' iff $a \* ( x + y ) = ( a \* x ) + ( a \* y )$
##  for $a \in E$ and $x, y \in D$.
##
DeclareCategory( "IsDistributiveLOpDSum", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpEProd( <D> )
##
##  is 'true' iff $( a \* b ) \* x = ( a \* x ) \* ( b \* x )$
##  for $a, b \in E$ and $x \in D$.
##
DeclareCategory( "IsDistributiveLOpEProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpESum( <D> )
##
##  is 'true' iff $( a + b ) \* x = ( a \* x ) + ( b \* x )$
##  for $a, b \in E$ and $x \in D$.
##
DeclareCategory( "IsDistributiveLOpESum", IsExtLSet );


#############################################################################
##
#C  IsTrivialLOpEOne( <D> )
##
##  is 'true' iff the identity element $e \in E$ acts trivially on $D$,
##  that is, $e \* x = x$ for $x \in D$.
#T necessary?
##
DeclareCategory( "IsTrivialLOpEOne", IsExtLSet );


#############################################################################
##
#C  IsTrivialLOpEZero( <D> )
##
##  is 'true' iff the zero element $z \in E$ acts trivially on $D$,
##  that is, $z \* x = Z$ for $x \in D$ and the zero element $Z$ of $D$.
#T necessary?
##
DeclareCategory( "IsTrivialLOpEZero", IsExtLSet );


#############################################################################
##
#C  IsLeftActedOnByRing( <D> )
##
DeclareCategory( "IsLeftActedOnByRing", IsExtLSet );


#############################################################################
##
#P  IsLeftActedOnByDivisionRing( <D> )
##
##  This is a property because then we need not duplicate code that creates
##  either left modules or left vector spaces.
##
DeclareProperty( "IsLeftActedOnByDivisionRing",
    IsExtLSet and IsLeftActedOnByRing );


#############################################################################
##
#C  IsLeftActedOnBySuperset( <D> )
##
DeclareCategory( "IsLeftActedOnBySuperset",
    IsExtLSet );


#############################################################################
##
#A  GeneratorsOfExtLSet( <D> )
##
DeclareAttribute( "GeneratorsOfExtLSet", IsExtLSet );


#############################################################################
##
#A  LeftActingDomain( <D> )
##
DeclareAttribute( "LeftActingDomain", IsExtLSet );


#############################################################################
##
#E  extlset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



