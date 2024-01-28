#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#R  IsEmptyRowVectorRep( <obj> )
##
DeclareRepresentation( "IsEmptyRowVectorRep",
    IsPositionalObjectRep and IsConstantTimeAccessList,
    [] );


#############################################################################
##
#M  EmptyRowVector( <F> ) . . . . . . . . . . . . . . . . . . .  for a family
##
InstallMethod( EmptyRowVector,
    "for a family",
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
#M  ViewObj( <emptyvec> ) . . . . . . . . . . . . . . .  for empty row vector
##
InstallMethod( ViewObj,
    "for an empty row vector",
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
    "for an empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    emptyvec -> 0 );


#############################################################################
##
#M  IsBound\[\]( <emptyvec>, <pos> ) . for empty row vector, and pos. integer
##
InstallMethod( IsBound\[\],
    "for an empty row vector, and a positive integer",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsPosInt ], 0,
    ReturnFalse);


#############################################################################
##
#M  ShallowCopy( <emptyvec> ) . . . . . . . . . . . . for an empty row vector
##
InstallMethod( ShallowCopy,
    "for an empty row vector",
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
    "for an empty row vector, and a collection in the same family",
    IsIdenticalObj,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep, IsCollection ], 0,
    function( emptyvec, coll )
    return IsEmpty( coll );
    end );


#############################################################################
##
#M  \=( <coll>, <emptyvec> )  . . . . . . for collection and empty row vector
##
InstallMethod( \=,
    "for a collection, and an empty row vector in the same family",
    IsIdenticalObj,
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
    "for two empty row vectors in the same family",
    IsIdenticalObj,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    ReturnFirst );


#############################################################################
##
#M  AdditiveInverseOp( <emptyvec> ) . . . . . . . . . .  for empty row vector
##
InstallMethod( AdditiveInverseOp,
    "for empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    IdFunc );


#############################################################################
##
#M  ZeroOp( <emptyvec> )  . . . . . . . . . . . . . . .  for empty row vector
##
InstallMethod( ZeroOp,
    "for empty row vector",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    IdFunc );


#############################################################################
##
#M  \*( <coeff>, <emptyvec> ) . . . .  for mult. element and empty row vector
##
InstallMethod( \*,
    "for multiplicative element, and empty row vector",
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
    "for empty row vector, and multiplicative element",
    IsCollsElms,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsMultiplicativeElement ], 0,
    ReturnFirst );


#############################################################################
##
#M  \*( <int>, <emptyvec> ) . . . . . . . . for integer, and empty row vector
##
InstallMethod( \*,
    "for integer, and empty row vector",
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
    "for empty row vector, and integer",
    true,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep, IsInt ], 0,
    ReturnFirst );


#############################################################################
##
#M  \*( <emptyvec>, <emptyvec> )  . . . . . . . . . for two empty row vectors
##
InstallMethod( \*,
    "for two empty row vectors in the same family",
    IsIdenticalObj,
    [ IsRowVector and IsEmpty and IsEmptyRowVectorRep,
      IsRowVector and IsEmpty and IsEmptyRowVectorRep ], 0,
    function( emptyvec1, emptyvec2 )
    return Zero( ElementsFamily( FamilyObj( emptyvec1 ) ) );
    end );
