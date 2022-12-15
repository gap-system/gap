#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of operations for magma ideals.
##

#############################################################################
#############################################################################
##
##
##               Left Magma Ideals
##
##
#############################################################################
#############################################################################

#############################################################################
##
#P  IsLeftMagmaIdeal( <D> )
##
##  A *left magma ideal* is a submagma (see~"Magmas") which is closed under
##  left multiplication by elements of its parent magma.
##
DeclareSynonym("IsLeftMagmaIdeal", IsMagma and IsLeftActedOnBySuperset);

##  As a sub magma, a left magma ideal has a Parent (the enclosing magma)
##  and as LeftActedOnBySuperset it has a  LeftActingDomain.
##  We must ensure that these two are the same object when the
##  left magma ideal is created.
##

#############################################################################
##
#F  LeftMagmaIdeal(<D>, <gens> )
##
##  `LeftMagmaIdeal' returns the magma containing the elements in the
##  homogeneous list <gens> and closed under left multiplication by elements
##  of the magma <D> in which it embeds.
##

##  This has to put in the parent and left acting set. Although it is a
##  submagma, we can't call the generic submagma creation since that
##  requires *magma* generators.
##
##
DeclareGlobalFunction( "LeftMagmaIdeal" );


#############################################################################
##
#O  AsLeftMagmaIdeal( <D>, <C> )
##
##  Let <D> be a domain and <C> a collection.
##  If <C> is a subset of <D>
##  `AsLeftMagmaIdeal' returns the LeftMagmaIdeal with generators <C>,
##  and with parent <D>.
##  Otherwise `fail' is returned.
##  Probably more desirable would be to regard <C> as the set of
##  elements of <D>.
##
DeclareOperation( "AsLeftMagmaIdeal", [ IsDomain, IsCollection ] );





#############################################################################
##
#A  GeneratorsOfLeftMagmaIdeal( <I> )
##
##  These are left ideal generators, not magma generators.
##
DeclareSynonymAttr( "GeneratorsOfLeftMagmaIdeal", GeneratorsOfExtLSet );


#############################################################################
##
#O  LeftMagmaIdealByGenerators(<D>, <gens> )
##
##  is the underlying operation of `LeftMagmaIdeal'
##
DeclareOperation( "LeftMagmaIdealByGenerators", [IsMagma, IsCollection ] );



#############################################################################
#############################################################################
##
##
##               Right Magma Ideals
##
##
#############################################################################
#############################################################################

#############################################################################
##
#P  IsRightMagmaIdeal( <D> )
##
##  A *right magma ideal* is a submagma (see~"Magmas") which is closed under
##  right multiplication by elements of its parent magma.
##
DeclareSynonym("IsRightMagmaIdeal", IsMagma and IsRightActedOnBySuperset);

##  As a sub magma, a right magma ideal has a Parent (the enclosing magma)
##  and as RightActedOnBySuperset it has a  RightActingDomain.
##  We must ensure that these two are the same object when the
##  right magma ideal is created.
##

#############################################################################
##
#F  RightMagmaIdeal(<D>, <gens> ) . . . . . . . . . .
##
##  `RightMagmaIdeal' returns the magma containing the elements in the
##  homogeneous list <gens> and closed under right multiplication by elements
##  of the parent magma <D>  in which it embeds.
##
##
DeclareGlobalFunction( "RightMagmaIdeal" );


#############################################################################
##
#O  AsRightMagmaIdeal( <D>, <C> )
##
##  Let <D> be a domain and <C> a collection.
##  If <C> is a subset of <D> that forms a RightMagmaIdeal then
##  `AsRightMagmaIdeal' returns this RightMagmaIdeal, with parent <D>.
##  Otherwise `fail' is returned.
##
DeclareOperation( "AsRightMagmaIdeal", [ IsDomain, IsCollection ] );





#############################################################################
##
#A  GeneratorsOfRightMagmaIdeal( <I> )
##
##  These are right ideal generators, not magma generators.
##
DeclareSynonymAttr( "GeneratorsOfRightMagmaIdeal", GeneratorsOfExtRSet );



#############################################################################
##
#O  RightMagmaIdealByGenerators(<D>, <gens> )
##
##  is the underlying operation of `RightMagmaIdeal'
##
DeclareOperation( "RightMagmaIdealByGenerators", [IsMagma, IsCollection ] );



#############################################################################
#############################################################################
##
##
##               Two Sided Magma Ideals
##
##
#############################################################################
#############################################################################


#############################################################################
##
#P  IsMagmaIdeal( <D> )
##
##  A *magma ideal* is a submagma (see~"Magmas") which is closed under
##  left and right multiplication by elements of its parent magma.
##
DeclareSynonym("IsMagmaIdeal", IsLeftMagmaIdeal and IsRightMagmaIdeal);

##  As a sub magma, a magma ideal has a Parent (the enclosing magma)
##  and as LeftActedOnBySuperset it has a  LeftActingDomain,
##  and as RightActedOnBySuperset it has a  RightActingDomain.
##  We must ensure that these three are the same object when the
##  magma ideal is created.
##

#############################################################################
##
#F  MagmaIdeal(<D>, <gens> )
##
##  `MagmaIdeal' returns the magma containing the elements in the homogeneous
##  list <gens> and closed under left  and right multiplication by elements
##  of the parent magma <D> in which it emeds.
##
##
DeclareGlobalFunction( "MagmaIdeal" );


#############################################################################
##
#O  AsMagmaIdeal( <D>, <C> )
##
##  Let <D> be a domain and <C> a collection.
##  If <C> is a subset of <D> that forms a MagmaIdeal then
##  `AsMagmaIdeal' returns this MagmaIdeal, with parent <D>.
##  Otherwise `fail' is returned.
##
DeclareOperation( "AsMagmaIdeal", [ IsDomain, IsCollection ] );


#############################################################################
##
#A  GeneratorsOfMagmaIdeal( <I> )
##
##  These are ideal generators, not magma generators.
##
DeclareAttribute( "GeneratorsOfMagmaIdeal", IsMagmaIdeal );




#############################################################################
##
#O  MagmaIdealByGenerators( <D>, <gens> )
##
##  is the underlying operation of `MagmaIdeal'
##
DeclareOperation( "MagmaIdealByGenerators", [IsMagma, IsCollection ] );
