#############################################################################
##
#W  adjoint.gd              The CIRCLE package            Alexander Konovalov
##                                                          Panagiotis Soules
##
#H  $Id: adjoint.gd,v 1.2 2007/04/12 16:51:20 alexk Exp $
##
##  Let R be an associative ring, not necessarily with a unit element. The
##  set of all elements of R forms a monoid with neutral element 0 from R
##  under the operation r * s = r + s + rs for all r and s of R. This monoid
##  is called the adjoint semigroup of R and is denoted R^ad. The group of
##  all invertible elements of this monoid is called the adjoint group of R
##  and is denoted by R^*.
##
##  This file contains declarations related with 
##  adoint semigroups and adjoint groups.
##
#############################################################################


#############################################################################
##
#A  IsUnit( <R>, <circle_obj> )
##
##  we declare separate method for IsUnit for circle objects because
##  they are not ring elements for which this method is already declared
##
DeclareOperation( "IsUnit", [ IsRing, IsDefaultCircleObject ] );

    
#############################################################################
##
#A  IsCircleUnit( <obj> )
##
##  Let <obj> be an element of the ring R. Then `IsCircleUnit( <obj> )'
##  determines whether it is invertible with respect to the circle
##  multilpication x+y+xy. This is equivalent to the condition that 1+obj
##  is a unit in R with respect to the ordinary multiplication.
##
DeclareOperation( "IsCircleUnit", [ IsRing, IsRingElement ] );


#############################################################################
##
#A  AdjointSemigroup( <R> )
##
DeclareAttribute( "AdjointSemigroup", IsRing );


#############################################################################
##
#A  AdjointGroup( <R> )
##
DeclareAttribute( "AdjointGroup", IsRing );


#############################################################################
##
#A  UnderlyingRing( <G> )
##
DeclareAttribute( "UnderlyingRing", IsSemigroup );


#############################################################################
##
#E
##