#############################################################################
##
#W  extrset.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for external right sets.
##
Revision.extrset_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsExtRSet( <D> )
##
##  An external right set is a domain with an action of a domain
##  from the right.
##
IsExtRSet := NewCategory( "IsExtRSet", IsDomain );


#############################################################################
##
#C  IsAssociativeROpDProd( <D> )
##
##  is 'true' iff $( x \* y ) \* a = x \* ( y \* a )$
##  for $a \in E$ and $x, y \in D$.
##
IsAssociativeROpDProd := NewCategory( "IsAssociativeROpDProd", IsExtRSet );


#############################################################################
##
#C  IsAssociativeROpEProd( <D> )
##
##  is 'true' iff $( x \* a ) \* b = x \* ( a \* b )$
##  for $a, b \in E$ and $x \in D$.
##
IsAssociativeROpEProd := NewCategory( "IsAssociativeROpEProd", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpDProd( <D> )
##
##  is 'true' iff $( x \* y ) \* a = ( x \* a ) \* ( y \* a )$
##  for $a \in E$ and $x, y \in D$.
##
IsDistributiveROpDProd := NewCategory( "IsDistributiveROpDProd", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpDSum( <D> )
##
##  is 'true' iff $( x + y ) \* a = ( x \* a ) + ( y \* a )$
##  for $a \in E$ and $x, y \in D$.
##
IsDistributiveROpDSum := NewCategory( "IsDistributiveROpDSum", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpEProd( <D> )
##
##  is 'true' iff $x \* ( a \* b ) = ( x \* a ) \* ( x \* b )$
##  for $a, b \in E$ and $x \in D$.
##
IsDistributiveROpEProd := NewCategory( "IsDistributiveROpEProd", IsExtRSet );


#############################################################################
##
#C  IsDistributiveROpESum( <D> )
##
##  is 'true' iff $x \* ( a + b ) = ( x \* a ) + ( x \* b )$
##  for $a, b \in E$ and $x \in D$.
##
IsDistributiveROpESum := NewCategory( "IsDistributiveROpESum", IsExtRSet );


#############################################################################
##
#C  IsTrivialROpEOne( <D> )
##
##  is 'true' iff the identity element $e \in E$ acts trivially on $D$,
##  that is, $x \* e = x$ for $x \in D$.
#T necessary?
##
IsTrivialROpEOne := NewCategory( "IsTrivialROpEOne", IsExtRSet );


#############################################################################
##
#C  IsTrivialROpEZero( <D> )
##
##  is 'true' iff the zero element $z \in E$ acts trivially on $D$,
##  that is, $x \* z = Z$ for $x \in D$ and the zero element $Z$ of $D$.
#T necessary?
##
IsTrivialROpEZero := NewCategory( "IsTrivialROpEZero", IsExtRSet );


#############################################################################
##
#C  IsRightActedOnByRing( <D> )
##
IsRightActedOnByRing := NewCategory( "IsRightActedOnByRing", IsExtRSet );


#############################################################################
##
#C  IsRightActedOnByDivisionRing( <D> )
##
IsRightActedOnByDivisionRing := NewCategory( "IsRightActedOnByDivisionRing",
    IsRightActedOnByRing );


#############################################################################
##
#C  IsRightActedOnBySuperset( <D> )
##
IsRightActedOnBySuperset := NewCategory( "IsRightActedOnBySuperset",
    IsExtRSet );


#############################################################################
##
#A  GeneratorsOfExtRSet( <D> )
##
GeneratorsOfExtRSet := NewAttribute( "GeneratorsOfExtRSet", IsExtRSet );
SetGeneratorsOfExtRSet := Setter( GeneratorsOfExtRSet );
HasGeneratorsOfExtRSet := Tester( GeneratorsOfExtRSet );


#############################################################################
##
#A  RightActingDomain( <D> )
##
RightActingDomain := NewAttribute( "RightActingDomain", IsExtRSet );
SetRightActingDomain := Setter( RightActingDomain );
HasRightActingDomain := Tester( RightActingDomain );


#############################################################################
##
#E  extrset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



