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
##  1. general methods for Lie elements
##  2. methods for free left modules of Lie elements
##     (there are special methods for Lie matrix spaces)
##  3. methods for FLMLORs (and ideals) of Lie elements
##     (there are special methods for Lie matrix spaces)
##


#############################################################################
##
##  1. general methods for Lie elements
##

#############################################################################
##
#M  LieFamily( <Fam> )
##
##  We need to distinguish families of arbitrary ring elements and families
##  that contain matrices,
##  since in the latter case the Lie elements shall also be matrices.
##  Note that matrices cannot be detected from their family,
##  so we decide that the Lie family of a collections family will consist
##  of Lie matrices.
##
InstallMethod( LieFamily,
    "for family of ring elements",
    true,
    [ IsRingElementFamily ], 0,
    function( Fam )

    local F, filt;

    if HasCharacteristic(Fam) and Characteristic(Fam)>0 then
        filt := IsRestrictedLieObject;
    else
        filt := IsLieObject;
    fi;

    # Make the family of Lie elements.
    F:= NewFamily( "LieFamily(...)", filt,CanEasilySortElements,
                                     CanEasilySortElements);
    SetUnderlyingFamily( F, Fam );

    if HasCharacteristic( Fam ) then
      SetCharacteristic( F, Characteristic( Fam ) );
    fi;
#T maintain other req/imp properties as implied properties of `F'?

    # Enter the type of objects in the image.
    F!.packedType:= NewType( F, filt and IsPackedElementDefaultRep );

    # Return the Lie family.
    return F;
    end );

InstallMethod( LieFamily,
    "for a collections family (special case of Lie matrices)",
    true,
    [ IsCollectionFamily ], 0,
    function( Fam )

    local F, filt;

    if HasCharacteristic(Fam) and Characteristic(Fam)>0 then
        filt := IsRestrictedLieObject;
    else
        filt := IsLieObject;
    fi;

    # Make the family of Lie elements.
    F:= NewFamily( "LieFamily(...)", filt and IsMatrix );
    SetUnderlyingFamily( F, Fam );

    if HasCharacteristic( Fam ) then
      SetCharacteristic( F, Characteristic( Fam ) );
    fi;
#T maintain other req/imp properties as implied properties of `F'?

    # Enter the type of objects in the image.
    F!.packedType:= NewType( F, filt
                                and IsPackedElementDefaultRep
                                and IsLieMatrix );

    # Return the Lie family.
    return F;
    end );


#############################################################################
##
#M  LieObject( <obj> )  . . . . . . . . . . . . . . . . .  for a ring element
##
InstallMethod( LieObject,
    "for a ring element",
    true,
    [ IsRingElement ], 0,
    obj -> Objectify( LieFamily( FamilyObj( obj ) )!.packedType,
                      [ Immutable( obj ) ] ) );


#############################################################################
##
#M  UnderlyingRingElement( <obj> )  . . . . . . . . . . . .   for a Lie object
##
InstallMethod( UnderlyingRingElement,
    "for a Lie object in default representation",
    true,
    [ IsLieObject and IsPackedElementDefaultRep], 0,
    obj -> obj![1] );


#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . .  for a Lie object
##
InstallMethod( PrintObj,
    "for a Lie object in default representation",
    true,
    [ IsLieObject and IsPackedElementDefaultRep ], SUM_FLAGS,
    function( obj )
    Print( "LieObject( ", obj![1], " )" );
    end );


#############################################################################
##
#M  ViewObj( <obj> )  . . . . . . . . . . . . . . . . . . .  for a Lie matrix
##
##  For Lie matrices, we want to override the special `ViewObj' method for
##  lists.
##
InstallMethod( ViewObj,
    "for a Lie matrix in default representation",
    true,
    [ IsLieMatrix and IsPackedElementDefaultRep ], SUM_FLAGS,
    function( obj )
    Print( "LieObject( " ); View( obj![1] ); Print(  " )" );
    end );


#############################################################################
##
#M  \=( <x>, <y> )  . . . . . . . . . . . . . . . . . . . for two Lie objects
#M  \<( <x>, <y> )  . . . . . . . . . . . . . . . . . . . for two Lie objects
##
InstallMethod( \=,
    "for two Lie objects in default representation",
    IsIdenticalObj,
    [ IsLieObject and IsPackedElementDefaultRep,
      IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<,
    "for two Lie objects in default representation",
    IsIdenticalObj,
    [ IsLieObject and IsPackedElementDefaultRep,
      IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y ) return x![1] < y![1]; end );


#############################################################################
##
#M  \+( <x>, <y> )  . . . . . . . . . . . . . . . . . . . for two Lie objects
#M  \-( <x>, <y> )  . . . . . . . . . . . . . . . . . . . for two Lie objects
#M  \*( <x>, <y> )  . . . . . . . . . . . . . . . . . . . for two Lie objects
#M  \^( <x>, <n> )  . . . . . . . . . . . . . . . . . . . for two Lie objects
##
##  The addition, subtraction, and multiplication of Lie objects is obvious.
##  If only one operand is a Lie object then we suspect that the operation
##  for the unpacked object is defined, and that the Lie object shall behave
##  as the unpacked object.
##
InstallMethod( \+,
    "for two Lie objects in default representation",
    IsIdenticalObj,
    [ IsLieObject and IsPackedElementDefaultRep,
      IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y ) return LieObject( x![1] + y![1] ); end );

InstallMethod( \+,
    "for Lie object in default representation, and ring element",
    true,
    [ IsLieObject and IsPackedElementDefaultRep, IsRingElement ], 0,
    function( x, y )
    local z;
    z:= x![1] + y;
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \+,
    "for ring element, and Lie object in default representation",
    true,
    [ IsRingElement, IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y )
    local z;
    z:= x + y![1];
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \-,
    "for two Lie objects in default representation",
    IsIdenticalObj,
    [ IsLieObject and IsPackedElementDefaultRep,
      IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y ) return LieObject( x![1] - y![1] ); end );

InstallMethod( \-,
    "for Lie object in default representation, and ring element",
    true,
    [ IsLieObject and IsPackedElementDefaultRep, IsRingElement ], 0,
    function( x, y )
    local z;
    z:= x![1] - y;
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \-,
    "for ring element, and Lie object in default representation",
    true,
    [ IsRingElement, IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y )
    local z;
    z:= x - y![1];
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \*,
    "for two Lie objects in default representation",
    IsIdenticalObj,
    [ IsLieObject and IsPackedElementDefaultRep,
      IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y ) return LieObject( LieBracket( x![1], y![1] ) ); end );

InstallMethod( \*,
    "for Lie object in default representation, and ring element",
    true,
    [ IsLieObject and IsPackedElementDefaultRep, IsRingElement ], 0,
    function( x, y )
    local z;
    z:= x![1] * y;
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \*,
    "for ring element, and Lie object in default representation",
    true,
    [ IsRingElement, IsLieObject and IsPackedElementDefaultRep ], 0,
    function( x, y )
    local z;
    z:= x * y![1];
    if IsFamLieFam( FamilyObj( z ), FamilyObj( y ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \^,
    "for Lie object in default representation, and positive integer",
    true,
    [ IsLieObject and IsPackedElementDefaultRep, IsPosInt ], 0,
    function( x, n )
    if 1 < n then
      return LieObject( Zero( x![1] ) );
    else
      return x;
    fi;
    end );

#############################################################################
##
#M  PthPowerImage( <lie_obj> ) . . . . . . . . .  for a restricted Lie object
##
InstallMethod(PthPowerImage, "for restricted Lie object",
        [ IsRestrictedLieObject ],
        function(x)
    return LieObject(x![1]^Characteristic(FamilyObj(x)));
end);
InstallMethod(PthPowerImage, "for restricted Lie object and integer",
        [ IsRestrictedLieObject, IsInt ],
        function(x,n)
    local y;
    y := x![1];
    while n>0 do
        y := y^Characteristic(FamilyObj(x));
        n := n-1;
    od;
    return LieObject(y);
end);

#############################################################################
##
#M  ZeroOp( <lie_obj> ) . . . . . . . . . . . . . . . . . .  for a Lie object
##
InstallMethod( ZeroOp,
    "for Lie object in default representation",
    true,
    [ IsLieObject and IsPackedElementDefaultRep ], SUM_FLAGS,
    x -> LieObject( Zero( x![1] ) ) );


#############################################################################
##
#M  OneOp( <lie_obj> )  . . . . . . . . . . . . . . . . . .  for a Lie object
##
InstallOtherMethod( OneOp,
    "for Lie object",
    true,
    [ IsLieObject ], 0,
    ReturnFail );


#############################################################################
##
#M  InverseOp( <lie_obj> )  . . . . . . . . . . . . . . . .  for a Lie object
##
InstallOtherMethod( InverseOp,
    "for Lie object",
    true,
    [ IsLieObject ], 0,
    ReturnFail );


#############################################################################
##
#M  AdditiveInverseOp( <lie_obj> )  . . . . . . . . . . . .  for a Lie object
##
InstallMethod( AdditiveInverseOp,
    "for Lie object in default representation",
    true,
    [ IsLieObject and IsPackedElementDefaultRep ], 0,
    x -> LieObject( - x![1] ) );


#############################################################################
##
#M  \[\]( <mat>, <i> )  . . . . . . . . . . . . . . . . . .  for a Lie matrix
#M  Length( <mat> )
#M  IsBound\[\]( <mat>, <i> )
#M  Position( <mat>, <obj> )
##
InstallOtherMethod( \[\],
    "for Lie matrix in default representation, and positive integer",
    [ IsLieMatrix and IsPackedElementDefaultRep, IsPosInt ],
    function( mat, i ) return mat![1][i]; end );

InstallOtherMethod( Length,
    "for Lie matrix in default representation",
    [ IsLieMatrix and IsPackedElementDefaultRep ],
    mat -> NumberRows( mat![1] ) );

InstallMethod( IsBound\[\],
    "for Lie matrix in default representation, and integer",
    [ IsLieMatrix and IsPackedElementDefaultRep, IsPosInt ],
    function( mat, i ) return IsBound( mat![1][i] ); end );

InstallMethod( Position,
    "for Lie matrix in default representation, row vector, and integer",
    [ IsLieMatrix and IsPackedElementDefaultRep, IsRowVector, IsInt ],
    function( mat, v, pos ) return Position( mat![1], v, pos ); end );


#############################################################################
##
#R  IsLieEmbeddingRep( <map> )
##
##  representation of the embedding of a family into its Lie family
##
DeclareRepresentation( "IsLieEmbeddingRep", IsAttributeStoringRep,
    [ "packedType" ] );


#############################################################################
##
#M  Embedding( <Fam>, <LieFam> )
##
InstallOtherMethod( Embedding,
    "for two families, the first with known Lie family",
    true,
    [ IsFamily and HasLieFamily, IsFamily ], 0,
    function( Fam, LieFam )

    local emb;

    # Is this the right method?
    if not IsFamLieFam( Fam, LieFam ) then
      TryNextMethod();
    fi;

    # Make the mapping object.
    emb := Objectify( TypeOfDefaultGeneralMapping( Fam, LieFam,
                              IsLieEmbeddingRep
                          and IsNonSPGeneralMapping
                          and IsMapping
                          and IsInjective
                          and IsSurjective ),
                      rec() );

    # Enter preimage and image.
    SetPreImagesRange( emb, Fam    );
    SetImagesSource(   emb, LieFam );

    # Return the embedding.
    return emb;
    end );

InstallMethod( ImagesElm,
    "for Lie embedding and object",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsLieEmbeddingRep, IsObject ], 0,
    function( emb, elm )
    return [ LieObject( elm ) ];
    end );

InstallMethod( PreImagesElm,
    "for Lie embedding and Lie object in default representation",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsLieEmbeddingRep,
      IsLieObject and IsPackedElementDefaultRep ], 0,
    function( emb, elm )
    return [ elm![1] ];
    end );


#############################################################################
##
#M  IsUnit( <lie_obj> )
##
InstallOtherMethod( IsUnit,
    "for a Lie object (return `false')",
    true,
    [ IsLieObject ], 0,
    ReturnFalse );


#############################################################################
##
##  2. methods for free left modules of Lie elements
##
##  There are special methods for Lie matrix spaces, both Gaussian and
##  non-Gaussian (see ...).
##  Note that in principle the non-Gaussian Lie matrix spaces could be
##  handled via the generic methods for spaces of Lie elements,
##  but the special methods are more efficient; they avoid one indirection
##  by assigning a row vector to each Lie matrix.
##

#############################################################################
##
#M  MutableBasis( <R>, <lieelms> )
#M  MutableBasis( <R>, <lieelms>, <zero> )
##
##  In general, we choose a mutable basis that stores a mutable basis for a
##  nice module.
##
##  Note that the case of Lie matrices must *not* be treated by these methods
##  since the space may be Gaussian and thus handled in a completely
##  different way.
##
InstallMethod( MutableBasis,
    "for ring and collection of Lie elements",
    function( F1, F2 ) return not IsElmsCollLieColls( F1, F2 ); end,
    [ IsRing, IsLieObjectCollection ], 0,
    MutableBasisViaNiceMutableBasisMethod2 );

InstallOtherMethod( MutableBasis,
    "for ring, (possibly empty) list, and Lie zero",
    function( F1, F2, F3 ) return not IsElmsLieColls( F1, F3 ); end,
    [ IsRing, IsList, IsLieObject ], 0,
    MutableBasisViaNiceMutableBasisMethod3 );


#############################################################################
##
#M  NiceFreeLeftModuleInfo( <liemodule> )
#M  NiceVector( <M>, <lieelm> )
#M  UglyVector( <M>, <vector> ) .  for left module of Lie objects, and vector
##
InstallHandlingByNiceBasis( "IsLieObjectsModule", rec(
    # Note that the case of Lie matrices must *not* be treated by these
    # methods since the space may be Gaussian and thus handled in a
    # completely different way.
    detect := function( R, gens, V, zero )
      if not IsLieObjectCollection( V ) then
        return false;
      elif zero = false then
        return not IsElmsCollLieColls( FamilyObj( R ), FamilyObj( gens ) );
      else
        return not IsElmsLieColls( FamilyObj( R ), FamilyObj( zero ) );
      fi;
      end,

    NiceFreeLeftModuleInfo := ReturnFalse,

    NiceVector := function( M, lieelm )
      if IsPackedElementDefaultRep( lieelm ) then
        return lieelm![1];
      else
        TryNextMethod();
      fi;
      end,

    UglyVector := function( M, vector )
      return LieObject( vector );
      end ) );


#############################################################################
##
#M  TwoSidedIdealByGenerators( <L>, <elms> )
#M  LeftIdealByGenerators( <L>, <elms> )
#M  RightIdealByGenerators( <L>, <elms> )
##
##  For Lie algebras <L>, we construct two-sided ideals in all three cases.
##
BindGlobal( "IdealByGeneratorsForLieAlgebra", function( L, elms )
    local I, lad;

    I:= Objectify( NewType( FamilyObj( L ),
                                IsFLMLOR
                            and IsAttributeStoringRep
                            and IsLieAlgebra ),
                   rec() );

    lad:= LeftActingDomain( L );
    SetLeftActingDomain( I, lad );
    SetGeneratorsOfTwoSidedIdeal( I, elms );
    SetGeneratorsOfLeftIdeal( I, elms );
    SetGeneratorsOfRightIdeal( I, elms );
    SetLeftActingRingOfIdeal( I, L );
    SetRightActingRingOfIdeal( I, L );

    if IsEmpty( elms ) then
      SetIsTrivial( I, true );
      SetDimension( I, 0 );
    fi;

    CheckForHandlingByNiceBasis( lad, elms, I, false );
    return I;
end );

InstallMethod( TwoSidedIdealByGenerators,
    "for Lie algebra and collection of Lie objects",
    IsIdenticalObj,
    [ IsLieAlgebra, IsLieObjectCollection and IsList ], 0,
    IdealByGeneratorsForLieAlgebra );

InstallMethod( LeftIdealByGenerators,
    "for Lie algebra and collection of Lie objects",
    IsIdenticalObj,
    [ IsLieAlgebra, IsLieObjectCollection and IsList ], 0,
    IdealByGeneratorsForLieAlgebra );

InstallMethod( RightIdealByGenerators,
    "for Lie algebra and collection of Lie objects",
    IsIdenticalObj,
    [ IsLieAlgebra, IsLieObjectCollection and IsList ], 0,
    IdealByGeneratorsForLieAlgebra );

InstallMethod( TwoSidedIdealByGenerators,
    "for Lie algebra and empty list",
    true,
    [ IsLieAlgebra, IsList and IsEmpty ], 0,
    IdealByGeneratorsForLieAlgebra );

InstallMethod( LeftIdealByGenerators,
    "for Lie algebra and empty list",
    true,
    [ IsLieAlgebra, IsList and IsEmpty ], 0,
    IdealByGeneratorsForLieAlgebra );

InstallMethod( RightIdealByGenerators,
    "for Lie algebra and empty list",
    true,
    [ IsLieAlgebra, IsList and IsEmpty ], 0,
    IdealByGeneratorsForLieAlgebra );
