#############################################################################
##
#W  circle.gi               The CIRCLE package            Alexander Konovalov
##                                                          Panagiotis Soules
##
#H  $Id: circle.gi,v 1.6 2008/01/21 15:40:46 alexk Exp $
##
##  This file contains an implementation of circle objects.
##
#############################################################################

    
#############################################################################
##
#M  CircleFamily( <Fam> )
##
##  is a family $F$ in bijection with the family <Fam>,
##  but with the circle multiplication as infix multiplication.
##  That is, for $x$, $y$ in <Fam>, the product of the images in $F$ will be
##  the image of $ x + y + x \* y $.
##
##  The standard type of objects in a Circle family <F> is `<F>!.CircleType'.
##
InstallMethod(CircleFamily,
    "for a family",
    [ IsFamily ],
function( Fam )
local F;

  # create the family of circle elements
  F:= NewFamily( "CircleFamily(...)", IsCircleObject );

  if HasCharacteristic( Fam ) then
    SetCharacteristic( F, Characteristic( Fam ) );
  fi;

  # store the type of objects in the output
  F!.CircleType:= NewType( F, IsDefaultCircleObject );

  # Return the circle family
  return F;
end );


#############################################################################
##
#M  CircleObject( <obj> )
##
##  Let <obj> be a ring element. Then `CircleObject( <obj> )' is the
##  corresponding circle object. If <obj> lies in the family <F>,
##  then `CircleObject( <obj> )' lies in the family CircleFamily( <F> )
##  (see~"CircleFamily").
##
InstallMethod( CircleObject,
    "for a ring element",
    [ IsRingElement ],
    obj -> Objectify( CircleFamily( FamilyObj( obj ) )!.CircleType,
                      [ Immutable( obj ) ] ) );


#############################################################################
##
#M  PrintObj( <obj> )
##
InstallMethod( PrintObj,
    "for object in `IsCircleObject'",
    [ IsDefaultCircleObject ],
    function( obj )
    Print( "CircleObject( ", obj![1], " )" );
    end );


#############################################################################
##
#O  UnderlyingRingElement( <obj> )
##
##  Let <obj> be a circle object. Then `UnderlyingRingElement( <obj> )' 
##  is the corresponding ring element. 
##
InstallMethod( UnderlyingRingElement,
    "for a circle object", 
    [ IsCircleObject ],
    obj -> obj![1] );

                      
#############################################################################
##
#M  \=( <x>, <y> )  . .  . . . . . . . . . . . . . . . for two circle objects
##
InstallMethod( \=,
    "for two objects in `IsCircleObject'",
    IsIdenticalObj,
    [ IsDefaultCircleObject, IsDefaultCircleObject ],
    function( a, b )
    return a![1] = b![1];
    end );


#############################################################################
##
#M  \<( <x>, <y> )  . .  . . . . . . . . . . . . . . . for two circle objects
##
InstallMethod( \<,
    "for two objects in `IsCircleObject'",
    IsIdenticalObj,
    [ IsDefaultCircleObject, IsDefaultCircleObject ],
    function( a, b )
    return a![1] < b![1];
    end );


#############################################################################
##
#M  \*( <x>, <y> )  . .  . . . . . . . . . . . . . . . for two circle objects
##
InstallMethod( \*,
    "for two objects in `IsCircleObject'",
    IsIdenticalObj,
    [ IsDefaultCircleObject, IsDefaultCircleObject ],
    function( a, b )
    return CircleObject( a![1] + b![1] + a![1]*b![1] );
    end );


#############################################################################
##
#M  OneOp( <circle_obj> )  . . . . . . . . . . . . . . .  for a circle object
##
InstallMethod( OneOp,
    "for an object in `IsCircleObject'",
    [ IsDefaultCircleObject ],
    a -> CircleObject( Zero( a![1] ) ) );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <elms> ) a collection of magma by 
##   multiplication table elements will always be acceptable
##   as generators, provided each one individually has an inverse.    
##    

InstallMethod( IsGeneratorsOfMagmaWithInverses, 
        "for a collection of circle objects",
        [ IsCollection ],
        function(c)
    if ForAll(c, x-> IsDefaultCircleObject(x) and IsMultiplicativeElementWithInverse(x)) then
        return true;
    fi;
    TryNextMethod();
end);


#############################################################################
##
#M  InverseOp( <circle_obj> )  . . . . . . . . . . . . .  for a circle object
##
InstallMethod( InverseOp,
    "for an object in `IsCircleObject'",
    [ IsDefaultCircleObject ],
    function( a )
    local x;
    x := Inverse( One( a![1] ) + a![1] );
    if x = fail then
      return fail;
    else
      return CircleObject( -a![1] * x );
    fi;
    end );


#############################################################################
##
#E
##