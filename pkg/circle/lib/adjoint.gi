#############################################################################
##
#W  adjoint.gi              The CIRCLE package            Alexander Konovalov
##                                                          Panagiotis Soules
##
#H  $Id: adjoint.gi,v 1.2 2007/04/12 16:51:20 alexk Exp $
##
##  This file contains implementations related with 
##  adoint semigroups and adjoint groups.
##
#############################################################################

 
#############################################################################
##
#M  IsUnit( <R>, <circle_obj> )
##
InstallMethod( IsUnit,
    "for a circle object in the given ring",
    [ IsRing, IsDefaultCircleObject ],
    function( R, a )
    return IsUnit( R, One( a![1] ) + a![1] );
    end );


#############################################################################
##
#M  IsUnit( <circle_obj> )
##
InstallOtherMethod( IsUnit,
    "for a circle object in the default ring",
    [ IsDefaultCircleObject ],
    a -> IsUnit( One( a![1] ) + a![1] ) );


#############################################################################
##
#M  IsCircleUnit( <R>,<obj> )
##
InstallMethod( IsCircleUnit,
    "for a ring element in the given ring",
    [ IsRing, IsRingElement ],
    function( R, a )
    return IsUnit( R, One( a ) + a );
    end );


#############################################################################
##
#M  IsCircleUnit( <obj> )
##
InstallOtherMethod( IsCircleUnit,
    "for a ring element in the default ring",
    [ IsRingElement ],
    a -> IsUnit( One( a ) + a ) );


#############################################################################
##
#M  AdjointSemigroup( <R> )
##
##  Let R be an associative ring, not necessarily with a unit element. The 
##  set of all elements of R forms a monoid with neutral element 0 from R 
##  under the operation r * s = r + s + rs for all r and s of R. This monoid
##  is called the adjoint semigroup of R and is denoted R^ad. 
##
InstallMethod(AdjointSemigroup,
    "for a ring",
    [ IsRing ],
    function( R )

    local S;

    if not IsFinite( R ) then
      Error("Adjoint semigroups for infinite rings are not implemented yet !!!");
    fi;

    if not IsAssociative( R ) then
      # To enforce the associativity test for rings of the form 
      # Ring( [ ZmodnZObj( 2, 8 ) ] );
      Error("The ring <R> is non-associative !!!");
    fi;
    
    if IsRingWithOne(R) then 
      Print("\nWARNING: usage of AdjointSemigroup for associative ring <R> with one!!! \n",
            "The adjoint semigroup is isomorphic to the multiplicative semigroup! \n\n");
    fi;
    
    # Enumeration of R must be feasible to do this:
    S := Monoid( List( R, CircleObject ) );
    
    SetIsFinite( S, IsFinite( R ) );
    SetUnderlyingRing( S, R );

    return S;

    end );


#############################################################################
##
#M  AdjointGroup( <R> )
##
##  Let R be an associative ring, not necessarily with a unit element. The 
##  set of all elements of R forms a monoid with neutral element 0 from R 
##  under the operation r * s = r + s + rs for all r and s of R. This monoid
##  is called the adjoint semigroup of R and is denoted R^ad. The group of 
##  all invertible elements of this monoid is called the adjoint group of R 
##  and is denoted by R^*.
##
##  If R is a radical algebra, that all its elements form a group with
##  respect to the circle multiplication x*y = x + y + xy. Therefore
##  its adjoint group coincides with R elementwise. We use this condition
##  to determine whether the chosen set of generators is enough to generate
##  the adjoint group. Note that the set of generators of the returned 
##  group is not required to be a generating set of minimal possible order.
##
##  (I tested also the loop over all elements of R instead of the random
##  selection. In my examples this was less efficient. But whether it is
##  better to avoid randomness in the general method ???).
##
##  If R has a unity 1, then 1+R^ad coincides with the multiplicative 
##  semigroup R^mult of R, and the map r -> 1+r with r in R is an isomorphism 
##  from R^ad onto R^mult. Similarly, 1+R^* coincides with the unit group of
##  R, which we denote U(R), and the map r -> 1+r with r in R is an 
##  isomorphism from R^* onto U(R).
##
##  If R is not a radical, then we compute all circle units of R, and then 
##  form a group of circle units, using the approach similar to the case of 
##  a radical algebra (this will work only for rings for which enummeration 
##  of all elements is feasible)
##
InstallMethod(AdjointGroup,
    "for a ring",
    [ IsRing ],
    function( R )

    local CircleUnits, G, h, h1, H;

    if not IsFinite( R ) then
      Error("Adjoint groups for infinite rings are not implemented yet !!!");
    fi;

    if IsRingWithOne(R) then 
      Print("\nWARNING: usage of AdjointGroup for associative ring <R> with one!!! \n",
            "In this case the adjoint group is isomorphic to the unit group \n",
            "Units(<R>), which possibly may be computed faster!!! \n\n");
    fi;
    
    if IsAlgebra( R ) and R = RadicalOfAlgebra( R ) then
      Info( InfoCircle, 1, "Circle : <R> is a radical algebra, all elements are circle units");
      CircleUnits := R;
    else
      Info( InfoCircle, 1, "Circle : <R> is not a radical algebra, computing circle units ...");
      CircleUnits := [ ];
      for h in R do
        h1 := CircleObject( h )^-1;
        if h1 <> fail then
	      if UnderlyingRingElement( h1 ) in R then
	        Add( CircleUnits, h );
	      fi;
	    fi;
      od;
    fi;

    Info( InfoCircle, 1, "Circle : searching generators for adjoint group ...");

    repeat
      h := Random( CircleUnits );
    until h <> Zero( R );

    G := Group( CircleObject( h ) );

    while Size( G ) < Size( CircleUnits ) do
      h := Random( CircleUnits );
      if h <> Zero( R ) then
        H := ClosureGroup( G, CircleObject( h ) );
        if Size( G ) < Size( H ) then
          G := H;
        fi;
      fi;
    od;

    SetUnderlyingRing( G, R );
    return G;

    end );


#############################################################################
##
#E
##