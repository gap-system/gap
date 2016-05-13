#############################################################################
##
#W  extrset.gd                  GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for external right sets.
##


#############################################################################
##
#C  IsExtRSet( <D> )
##
##  An external right set is a domain with an action of a domain
##  from the right.
##
DeclareCategory( "IsExtRSet", IsDomain );


#############################################################################
##
#C  IsAssociativeROpDProd( <D> )
##
##  is `true' iff $( x \* y ) \* a = x \* ( y \* a )$
##  for $a \in E$ and $x, y \in D$.
##
DeclareCategory( "IsAssociativeROpDProd", IsExtRSet );


#############################################################################
##
#C  IsAssociativeROpEProd( <D> )
##
##  is `true' iff $( x \* a ) \* b = x \* ( a \* b )$
##  for $a, b \in E$ and $x \in D$.
##
DeclareCategory( "IsAssociativeROpEProd", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpDProd( <D> )
##
##  is `true' iff $( x \* y ) \* a = ( x \* a ) \* ( y \* a )$
##  for $a \in E$ and $x, y \in D$.
##
DeclareCategory( "IsDistributiveROpDProd", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpDSum( <D> )
##
##  is `true' iff $( x + y ) \* a = ( x \* a ) + ( y \* a )$
##  for $a \in E$ and $x, y \in D$.
##
DeclareCategory( "IsDistributiveROpDSum", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpEProd( <D> )
##
##  is `true' iff $x \* ( a \* b ) = ( x \* a ) \* ( x \* b )$
##  for $a, b \in E$ and $x \in D$.
##
DeclareCategory( "IsDistributiveROpEProd", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpESum( <D> )
##
##  is `true' iff $x \* ( a + b ) = ( x \* a ) + ( x \* b )$
##  for $a, b \in E$ and $x \in D$.
##
DeclareCategory( "IsDistributiveROpESum", IsExtRSet );


#############################################################################
##
#C  IsTrivialROpEOne( <D> )
##
##  is `true' iff the identity element $e \in E$ acts trivially on $D$,
##  that is, $x \* e = x$ for $x \in D$.
#T necessary?
##
DeclareCategory( "IsTrivialROpEOne", IsExtRSet );


#############################################################################
##
#C  IsTrivialROpEZero( <D> )
##
##  is `true' iff the zero element $z \in E$ acts trivially on $D$,
##  that is, $x \* z = Z$ for $x \in D$ and the zero element $Z$ of $D$.
#T necessary?
##
DeclareCategory( "IsTrivialROpEZero", IsExtRSet );


#############################################################################
##
#C  IsRightActedOnByRing( <D> )
##
DeclareCategory( "IsRightActedOnByRing", IsExtRSet );


#############################################################################
##
#C  IsRightActedOnByDivisionRing( <D> )
##
DeclareCategory( "IsRightActedOnByDivisionRing",
    IsRightActedOnByRing );


#############################################################################
##
#C  IsRightActedOnBySuperset( <D> )
##
DeclareCategory( "IsRightActedOnBySuperset",
    IsExtRSet );


#############################################################################
##
#A  GeneratorsOfExtRSet( <D> )
##
DeclareAttribute( "GeneratorsOfExtRSet", IsExtRSet );


#############################################################################
##
#A  RightActingDomain( <D> )
##
DeclareAttribute( "RightActingDomain", IsExtRSet );


#############################################################################
##
#E  extrset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



