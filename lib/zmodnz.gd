#############################################################################
##
#W  zmodnz.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the design of the rings $Z / n Z$ and their elements.
##
##  The ordering of elements for nonprime $n$ is defined by the ordering of
##  the representatives.
##  For primes smaller than `MAXSIZE_GF_INTERNAL', the ordering of the
##  internal finite field elements must be respected, for larger primes
##  again the ordering of representatives is chosen.
##
Revision.zmodnz_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsZmodnZObj( <obj> )
#C  IsZmodnZObjNonprime( <obj> )
#C  IsZmodpZObj( <obj> )
#C  IsZmodpZObjSmall( <obj> )
#C  IsZmodpZObjLarge( <obj> )
##
##  The elements in the rings $Z / n Z$ are in the category `IsZmodnZObj'.
##  If $n$ is a prime then the elements are of course also in the category
##  `IsFFE' (see~"IsFFE"), otherwise they are in `IsZmodnZObjNonprime'.
##  `IsZmodpZObj' is an abbreviation of `IsZmodnZObj and IsFFE'.  This
##  category is the disjoint union of `IsZmodpZObjSmall' and
##  `IsZmodpZObjLarge', the former containing all elements with $n$ at most
##  `MAXSIZE_GF_INTERNAL'.
##
##  The reasons to distinguish the prime case from the nonprime case are
##  \beginlist
##  \item{-}
##    that objects in `IsZmodnZObjNonprime' have an external representation
##    (namely the residue in the range $[ 0, 1, ... n-1 ]$),
##  \item{-}
##    that the comparison of elements can be defined as comparison of the
##    residues, and
##  \item{-}
##    that the elements lie in a family of type `IsZmodnZObjNonprimeFamily'
##    (note that for prime $n$, the family must be an `IsFFEFamily').
##  \endlist
##
##  The reasons to distinguish the small and the large case are
##  that for small $n$ the elements must be compatible with the internal
##  representation of finite field elements, whereas we are free to define
##  comparison as comparison of residues for large $n$.
##
##  Note that we *cannot* claim that every finite field element of degree 1
##  is in `IsZmodnZObj', since finite field elements in internal
##  representation may not know that they lie in the prime field.
##
DeclareCategory( "IsZmodnZObj", IsScalar );
DeclareCategory( "IsZmodnZObjNonprime", IsZmodnZObj );
DeclareSynonym( "IsZmodpZObj", IsZmodnZObj and IsFFE );
DeclareCategory( "IsZmodpZObjSmall", IsZmodpZObj );
DeclareCategory( "IsZmodpZObjLarge", IsZmodpZObj );


#############################################################################
##
#C  IsZmodnZObjNonprimeFamily( <obj> )
##
DeclareCategoryFamily( "IsZmodnZObjNonprime" );


#############################################################################
##
#C  IsZmodnZObjNonprimeCollection( <obj> )
#C  IsZmodnZObjNonprimeCollColl( <obj> )
#C  IsZmodnZObjNonprimeCollCollColl( <obj> )
##
DeclareCategoryCollections( "IsZmodnZObjNonprime" );
DeclareCategoryCollections( "IsZmodnZObjNonprimeCollection" );
DeclareCategoryCollections( "IsZmodnZObjNonprimeCollColl" );


#############################################################################
##
#M  IsFinite( <R> ) . . . . . . . . . . . . . . . . method for full ring Z/nZ
##
InstallTrueMethod( IsFinite,
    IsZmodnZObjNonprimeCollection and IsDuplicateFree );


#############################################################################
##
#V  Z_MOD_NZ
##
##  is a list of length 2, the first containing at position <i> the <i>-th
##  value <n> for that `ZmodnZ( <n> )' is stored, and the second containing
##  this ring at position <i>.
##
DeclareGlobalVariable( "Z_MOD_NZ",
    "list of lists, at position [1][i] is n s.t. [2][i] is ZmodnZ(n)" );
InstallFlushableValue( Z_MOD_NZ, [ [], [] ] );


#############################################################################
##
#F  ZmodnZ( <n> )
#F  ZmodpZ( <p> )
#F  ZmodpZNC( <p> )
##
##  `ZmodnZ' returns a ring $R$ isomorphic to the residue class ring of the
##  integers modulo the positive integer <n>.
##  The element corresponding to the residue class of the integer $i$ in this
##  ring can be obtained by $i \* `One'( R )$, and a representative of the
##  residue class corresponding to the element $x \in R$ can be computed by
##  $`Int'( x )$.
##
##  `ZmodnZ( <n> )' is equivalent to `Integers mod <n>'.
##
##  `ZmodpZ' does the same if the argument <p> is a prime integer,
##  additionally the result is a field.
##  `ZmodpZNC' omits the check whether <p> is a prime.
##
##  Each ring returned by these functions contains the whole family of its
##  elements
##  if $n$ is not a prime, and is embedded into the family of finite field
##  elements of characteristic $n$ if $n$ is a prime.
##
DeclareGlobalFunction( "ZmodnZ" );
DeclareGlobalFunction( "ZmodpZ" );
DeclareGlobalFunction( "ZmodpZNC" );


#############################################################################
##
#O  ZmodnZObj( <Fam>, <i> )
##
##  creates an object in the residue class family <Fam> whose coset is
##  represented by integer <i>.
##
DeclareOperation( "ZmodnZObj", [ IsZmodnZObjNonprimeFamily, IsInt ] );


#############################################################################
##
#A  ModulusOfZmodnZObj( <obj> )
##
##  For an element <obj> in a residue class ring of integers modulo $n$
##  (see~"IsZmodnZObj"), `ModulusOfZmodnZObj' returns the positive integer
##  $n$.
##
DeclareAttribute( "ModulusOfZmodnZObj", IsZmodnZObj );


#############################################################################
##
#M  IsFinite( <zmodnz-mat-grp> )
##
##  *NOTE*:  The following implication only  holds if there are no infinite
##  dimensional matrices.
##
InstallTrueMethod( IsFinite,
    IsZmodnZObjNonprimeCollCollColl and IsRingElementCollCollColl
                                    and IsGroup
                                    and IsFinitelyGeneratedGroup );


#############################################################################
##
#E

