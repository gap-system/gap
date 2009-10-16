#############################################################################
##
#W  magmact.gd                  GAP library                   Andrew Solomon
##
#H  @(#)$Id: magmact.gd,v 1.1 1999/04/24 11:46:31 andrews Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of operations for magma ideals.
##
Revision.magmact_gd :=
    "@(#)$Id: magmact.gd,v 1.1 1999/04/24 11:46:31 andrews Exp $";


#############################################################################
##
#C  IsMagmaAction( <D> )
##
##  A Magma Action comprises a magma M, a set X, and a function
##	M x X --> X 
##
DeclareCategory("IsMagmaAction", IsObject);

#############################################################################
##
#F  MagmaAction(<magma>, <set>, <function>)
##
##  Function to create a magma action.
##  if arg = [Magma, Set, Function] - just create the 
##  magma action described by these.
##
DeclareGlobalFunction("MagmaAction");

#############################################################################
##
#A  MagmaActionMagma( <MagmaAction> )
#A  MagmaActionFunction( <MagmaAction> )
#A  MagmaActionSet( <MagmaAction> )
##
DeclareAttribute("MagmaActionMagma", IsMagmaAction);
DeclareAttribute("MagmaActionFunction", IsMagmaAction);
DeclareAttribute("MagmaActionSet", IsMagmaAction);


#############################################################################
##
#P  IsStronglyTransitiveMagmaAction( <MagmaAction> )
#P  IsWeaklyTransitiveMagmaAction( <MagmaAction> )
##
##  A strongly transitive magma action is one where 
##  for every two elements x, x' of the set being acted upon, there are 
##  m, m' in the magma with f(x,m) = x' and f(x', m') = x.
##
##  A weakly transitive magma action is one where 
##  for every two elements x, x' of the set, there is some 
##  m in the magma with f(x,m) = x' or f(x', m) = x.
##  
##
DeclareProperty("IsStronglyTransitiveMagmaAction", IsMagmaAction);
DeclareProperty("IsWeaklyTransitiveMagmaAction", IsMagmaAction);

#############################################################################
##
#O  MagmaActionStrongOrbit( <MagmaAction>, x )
#O  MagmaActionWeakOrbit( <MagmaAction>, x )
##
##  A strong orbit of a point is the set of points to
##  which it can be moved under the magma action and from
##  which it can also be obtained. i.e. for all y in the strong 
##  orbit of x, there are m, n in the magma with 
##  f(x,m) = y and f(y,n) = x.
##
##  A weak orbit of a point is the set of points to
##  which it can be moved under the magma action 
##

DeclareOperation("MagmaActionStrongOrbit",[IsMagmaAction, IsObject]);
DeclareOperation("MagmaActionWeakOrbit", [IsMagmaAction, IsObject]);

#############################################################################
##
#O  MagmaActionImage( <MagmaAction M>, <magmaelt m>, <point x> )
##  
##  returns MagmaActionFunction(M)(m,x)
##  
##

DeclareOperation("MagmaActionImage",
			[IsMagmaAction, IsMultiplicativeElement, IsObject]);


#############################################################################
##
#O  MagmaActionPointStabilizer( <MagmaAction A>, <set U> )
#O  MagmaActionSetStabilizer( <MagmaAction A>, <set U> )
##  
##  MagmaActionPointStabilizer returns the set of elements of the magma 
##  which stabilize the points of the set U.
##  
##  MagmaActionSetStabilizer returns the set of elements of the magma 
##  which map U into itself (not necessarily injectively).

DeclareOperation("MagmaActionPointStabilizer", [IsMagmaAction, IsObject]);
DeclareOperation("MagmaActionSetStabilizer", [IsMagmaAction, IsObject]);


#############################################################################
##
#O  DefaultMagmaAction( <Magma M> )
##
##  Many magmas (for example transformation semigroups, or matrix groups)
##  admit or are defined by  a natural action on  some set (a set of points,
##  a vector space). In these cases,  a method may be supplied in order to
##  render these objects as magma actions.
##
##  Note: In Goetz Pfeiffer's MONOID package, monoids of relations on a finite
##  set are implemented. If it were implemented in GAP4 then this operation 
##  would return the action of a transformation monoid on the power set.

DeclareOperation("DefaultMagmaAction",[IsMagma]);

