#############################################################################
##
#W  rvecempt.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.rvecempt_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsEmptyRowVectorRep( <obj> )
##
IsEmptyRowVectorRep := NewRepresentation( "IsEmptyRowVectorRep",
    IsPositionalObjectRep and IsConstantTimeAccessList,
    [] );


#############################################################################
##
#M  EmptyRowVector( <F> ) . . . . . . . . . . . . . . . . . . .  for a family
##
InstallMethod( EmptyRowVector,
    "method for a family",
    true,
    [ IsFamily ], 0,
    function( F )
    return Objectify( NewType( CollectionsFamily( F ),
                                   IsRowVector
                               and IsEmpty
                               and IsEmptyRowVectorRep ),
                      [] );
    end );


#############################################################################
##
#M  PrintObj( <emptyvec> )  . . . . . . . . . . . . . .  for empty row vector
##
InstallMethod( PrintObj,
    "method for an empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( emptyvec )
    Print( "<empty row vector>" );
    end );


#############################################################################
##
#M  Length( <emptyvec> )  . . . . . . . . . . . . . . .  for empty row vector
##
InstallMethod( Length,
    "method for an empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    emptyvec -> 0 );


#############################################################################
##
#M  IsBound\[\]( <emptyvec>, <pos> ) . for empty row vector, and pos. integer
##
InstallMethod( IsBound\[\],
    "method for an empty row vector, and a positive integer",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsInt and IsPosRat ], 0,
    function( emptyvec, pos )
    return false;
    end );


#############################################################################
##
#M  ShallowCopy( <emptyvec> ) . . . . . . . . . . . . for an empty row vector
##
InstallMethod( ShallowCopy,
    "method for an empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( emptyvec )
    Error( "mutable empty row vectors are not yet supported" );
#T !!
    end );


#############################################################################
##
#M  \=( <emptyvec>, <coll> )  . . . . . . for empty row vector and collection
##
InstallMethod( \=,
    "method for an empty row vector, and a collection in the same family",
    IsIdentical,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep, IsCollection ], 0,
    function( emptyvec, coll )
    return IsEmpty( coll );
    end );


#############################################################################
##
#M  \=( <coll>, <emptyvec> )  . . . . . . for collection and empty row vector
##
InstallMethod( \=,
    "method for a collection, and an empty row vector in the same family",
    IsIdentical,
    [ IsCollection, IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( coll, emptyvec )
    return IsEmpty( coll );
    end );


#############################################################################
##
#T  \<( <emptyvec>, <coll> )  . . . . . . for empty row vector and collection
#T  \<( <coll>, <emptyvec> )  . . . . . . for collection and empty row vector
##


#############################################################################
##
#M  \+( <emptyvec>, <emptyvec> )  . . . . . . . . . for two empty row vectors
##
InstallMethod( \+,
    "method for two empty row vectors in the same family",
    IsIdentical,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( emptyvec1, emptyvec2 )
    return emptyvec1;
    end );


#############################################################################
##
#M  AdditiveInverse( <emptyvec> ) . . . . . . . . . . .  for empty row vector
##
InstallMethod( AdditiveInverse,
    "method for empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    IdFunc );


#############################################################################
##
#M  Zero( <emptyvec> )  . . . . . . . . . . . . . . . .  for empty row vector
##
InstallMethod( Zero,
    "method for empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    IdFunc );


#############################################################################
##
#M  \*( <coeff>, <emptyvec> ) . . . .  for mult. element and empty row vector
##
InstallMethod( \*,
    "method for multiplicative element, and empty row vector",
    IsElmsColls,
    [ IsMultiplicativeElement,
      IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( coeff, emptyvec )
    return emptyvec;
    end );


#############################################################################
##
#M  \*( <emptyvec>, <coeff> ) . . . .  for empty row vector and mult. element
##
InstallMethod( \*,
    "method for empty row vector, and multiplicative element",
    IsCollsElms,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsMultiplicativeElement ], 0,
    function( emptyvec, coeff )
    return emptyvec;
    end );


#############################################################################
##
#M  \*( <int>, <emptyvec> ) . . . . . . . . for integer, and empty row vector
##
InstallMethod( \*,
    "method for integer, and empty row vector",
    true,
    [ IsInt, IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( int, emptyvec )
    return emptyvec;
    end );


#############################################################################
##
#M  \*( <emptyvec>, <int> ) . . . . . . . . for empty row vector, and integer
##
InstallMethod( \*,
    "method for empty row vector, and integer",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep, IsInt ], 0,
    function( emptyvec, int )
    return emptyvec;
    end );


#############################################################################
##
#M  \*( <emptyvec>, <emptyvec> )  . . . . . . . . . for two empty row vectors
##
InstallMethod( \*,
    "method for two empty row vectors in the same family",
    IsIdentical,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( emptyvec1, emptyvec2 )
    return Zero( ElementsFamily( FamilyObj( emptyvec1 ) ) );
    end );


#############################################################################
##
#E  rvecempt.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



