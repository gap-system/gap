#############################################################################
##
#W  liefam.gi                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  1. general methods for Lie elements
##  2. methods for free left modules of Lie elements
##     (there are special methods for Lie matrix spaces)
##  3. methods for FLMLORs of Lie elements
##     (there are special methods for Lie matrix spaces)
##
Revision.liefam_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. general methods for Lie elements
##

#############################################################################
##
#M  LieFamily( <Fam> )
##
##  We need a method for families of arbitrary ring elements and a method for
##  families that contain matrices, since in the latter case the Lie elements
##  shall also be matrices.
##  Matrices cannot be detected because of their family, so we decide that
##  the Lie family of a collections family will consist of matrices.
##
InstallMethod( LieFamily, true, [ IsFamilyRingElements ], 0,
    function( Fam )

    local F;

    # Make the family of Lie elements.
    F:= NewFamily( "LieFamily(...)", IsLieObject );
    SetUnderlyingFamily( F, Fam );

    if HasCharacteristic( Fam ) then
      SetCharacteristic( F, Characteristic( Fam ) );
    fi;
#T maintain other req/imp properties as implied properties of 'F'?

    # Enter the type of objects in the image.
    F!.packedType:= NewType( F, IsLieObject );

    # Return the Lie family.
    return F;
    end );

InstallMethod( LieFamily, true, [ IsFamilyCollections ], 0,
    function( Fam )

    local F;

    # Make the family of Lie elements.
    F:= NewFamily( "LieFamily(...)", IsLieObject and IsMatrix );
    SetUnderlyingFamily( F, Fam );

    if HasCharacteristic( Fam ) then
      SetCharacteristic( F, Characteristic( Fam ) );
    fi;
#T maintain other req/imp properties as implied properties of 'F'?

    # Enter the type of objects in the image.
    F!.packedType:= NewType( F, IsLieObject and IsMatrix );

    # Return the Lie family.
    return F;
    end );


#############################################################################
##
#M  LieObject( <obj> )
##
InstallMethod( LieObject, true, [ IsRingElement ], 0,
    obj -> Objectify( LieFamily( FamilyObj( obj ) )!.packedType,
                      [ Immutable( obj ) ] ) );


#############################################################################
##
#M  PrintObj( <obj> )
##
InstallMethod( PrintObj, true, [ IsLieObject ], 0,
    function( obj )
    Print( "LieObject( ", obj![1], " )" );
    end );


#############################################################################
##
#M  \=( <x>, <y> )
#M  \<( <x>, <y> )
##
InstallMethod( \=, IsIdentical, [ IsLieObject, IsLieObject ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<, IsIdentical, [ IsLieObject, IsLieObject ], 0,
    function( x, y ) return x![1] < y![1]; end );


#############################################################################
##
#M  \+( <x>, <y> )
#M  \-( <x>, <y> )
#M  \*( <x>, <y> )
#M  \^( <x>, <n> )
##
##  The addition, subtraction, and multiplication of Lie objects is obvious.
##  If only one operand is a Lie object then we suspect that the operation
##  for the unpacked object is defined, and that the Lie object shall behave
##  as the unpacked object.
##
InstallMethod( \+, IsIdentical, [ IsLieObject, IsLieObject ], 1,
    function( x, y ) return LieObject( x![1] + y![1] ); end );

InstallMethod( \+, true, [ IsLieObject, IsRingElement ], 0,
    function( x, y )
    local z;
    z:= x![1] + y;
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \+, true, [ IsRingElement, IsLieObject ], 0,
    function( x, y )
    local z;
    z:= x + y![1];
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \-, IsIdentical, [ IsLieObject, IsLieObject ], 1,
    function( x, y ) return LieObject( x![1] - y![1] ); end );

InstallMethod( \-, true, [ IsLieObject, IsRingElement ], 0,
    function( x, y )
    local z;
    z:= x![1] - y;
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \-, true, [ IsRingElement, IsLieObject ], 0,
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
    "method for two Lie objects in the same family",
    IsIdentical,
    [ IsLieObject, IsLieObject ], SUM_FLAGS,
    function( x, y ) return LieObject( LieBracket( x![1], y![1] ) ); end );

InstallMethod( \*, true, [ IsLieObject, IsRingElement ], 0,
    function( x, y )
    local z;
    z:= x![1] * y;
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \*, true, [ IsRingElement, IsLieObject ], 0,
    function( x, y )
    local z;
    z:= x * y![1];
    if IsFamLieFam( FamilyObj( z ), FamilyObj( y ) ) then
      return LieObject( z );
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( \^, true, [ IsLieObject, IsPosRat and IsInt ], 0,
    function( x, n )
    if 1 < n then
      return LieObject( 0 * x![1] );
    else
      return x;
    fi;
    end );


#############################################################################
##
#M  Zero( <lie_obj> )
##
InstallMethod( Zero, true, [ IsLieObject ], SUM_FLAGS,
    x -> LieObject( Zero( x![1] ) ) );


#############################################################################
##
#M  One( <lie_obj> )
##
InstallOtherMethod( One, true, [ IsLieObject ], 0,
    function( x )
    Error( "no identity in Lie families" );
    end );


#############################################################################
##
#M  Inverse( <lie_obj> )
##
InstallOtherMethod( Inverse, true, [ IsLieObject ], 0,
    function( x )
    Error( "no inverses in Lie families" );
    end );


#############################################################################
##
#M  AdditiveInverse( <lie_obj> )
##
InstallMethod( AdditiveInverse, true, [ IsLieObject ], 0,
    x -> LieObject( - x![1] ) );


#############################################################################
##
#M  \[\]( <mat>, <i> )
#M  Length( <mat> )
#M  IsBound\[\]( <mat>, <i> )
#M  Position( <mat>, <obj> )
##
##  Lie objects of matrices shall themselves be matrices.
##
InstallMethod( \[\], true,
    [ IsLieObject and IsMatrix, IsPosRat and IsInt ], 0,
    function( mat, i ) return mat![1][i]; end );

InstallMethod( Length, true, [ IsLieObject and IsMatrix ], 0,
    function( mat ) return Length( mat![1] ); end );

InstallMethod( IsBound\[\], true,
    [ IsLieObject and IsMatrix, IsPosRat and IsInt ], 0,
    function( mat, i ) return IsBound( mat![1][i] ); end );

InstallMethod( Position, true, [ IsLieObject and IsMatrix, IsRowVector,
    IsInt ], 0,
    function( mat, v, pos ) return Position( mat![1], v, pos ); end );


#############################################################################
##
#R  IsLieEmbedding( <map> )
##
IsLieEmbedding := NewRepresentation( "IsLieEmbedding",
        IsNonSPGeneralMapping
    and IsMapping
    and IsInjective
    and IsAttributeStoringRep,
    [ "packedType" ] );


#############################################################################
##
#M  Embedding( <Fam>, <LieFam> )
##
InstallOtherMethod( Embedding, true, [ IsFamily and HasLieFamily,
    IsFamily ], 0,
    function( Fam, LieFam )

    local   emb;

    # Is this the right method?
    if not IsFamLieFam( Fam, LieFam ) then
      TryNextMethod();
    fi;

    # Make the mapping object.
    emb := Objectify( TypeOfDefaultGeneralMapping( Fam, LieFam,
                                                   IsLieEmbedding ),
                      rec() );

    # Enter preimage and image.
    SetPreImagesRange( emb, Fam    );
    SetImagesSource(   emb, LieFam );

    # We know that this mapping is a bijection.
    SetIsSurjective( emb, true );

    # Return the embedding.
    return emb;
    end );

InstallMethod( ImagesElm, FamSourceEqFamElm,
    [ IsLieEmbedding, IsObject ], 0,
    function ( emb, elm )
    return [ LieObject( elm ) ];
    end );

InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsLieEmbedding, IsObject ], 0,
    function ( emb, elm )
    return [ elm![1] ];
    end );


#############################################################################
##
#M  IsUnit( <lie_obj> )
##
InstallOtherMethod( IsUnit,
    "method for a Lie object (return 'false')",
    true,
    [ IsLieObject ], 0,
    ReturnFalse );


#############################################################################
##
##  2. methods for free left modules of Lie elements
##
##  There are special methods for Lie matrix spaces, both Gaussian and
##  non-Gaussian.
##  Note that in principle the non-Gaussian Lie matrix spaces could be
##  handled via the generic methods for spaces of Lie elements,
##  but the special methods are more efficient; they avoid one indirection
##  by assigning a row vector to each Lie matrix.
##

#############################################################################
##
#R  IsLieObjectsModuleRep
##
IsLieObjectsModuleRep := NewRepresentation(
    "IsLieObjectsModuleRep",
    IsAttributeStoringRep and IsHandledByNiceBasis,
    [] );


#############################################################################
##
#M  MutableBasisByGenerators( <R>, <lieelms> )
#M  MutableBasisByGenerators( <R>, <lieelms>, <zero> )
##
##  In general, we choose a mutable basis that stores a mutable basis for a
##  nice module.
##
##  Note that the case of Lie matrices must *not* be treated by these methods
##  since the space may be Gaussian and thus handled in a completely
##  different way.
##
InstallMethod( MutableBasisByGenerators,
    "method for ring and collection of Lie elements",
    function( F1, F2 ) return not IsElmsCollLieColls( F1, F2 ); end,
    [ IsRing, IsLieObjectCollection ], 0,
    MutableBasisViaNiceMutableBasisMethod2 );

InstallOtherMethod( MutableBasisByGenerators,
    "method for ring, (possibly empty) list, and Lie zero",
    function( F1, F2, F3 ) return not IsElmsLieColls( F1, F3 ); end,
    [ IsRing, IsList, IsLieObject ], 0,
    MutableBasisViaNiceMutableBasisMethod3 );


#############################################################################
##
#M  LeftModuleByGenerators( <R>, <lieelms> )  . . . . . . . . for Lie objects 
#M  LeftModuleByGenerators( <R>, <empty>, <zero> )  . . . . . for Lie objects
#M  LeftModuleByGenerators( <R>, <lieelms>, <zero> )  . . . . for Lie objects
##
##  Note that the case of Lie matrices must *not* be treated by these methods
##  since the space may be Gaussian and thus handled in a completely
##  different way.
##
InstallMethod( LeftModuleByGenerators,
    "method for ring and list of Lie objects",
    function( F1, F2 ) return not IsElmsCollLieColls( F1, F2 ); end,
    [ IsRing, IsLieObjectCollection and IsList ], 0,
    function( R, lieelms )
    local dims, V;

    V:= Objectify( NewType( FamilyObj( lieelms ),
                                IsFreeLeftModule
                            and IsLieObjectsModuleRep ),
                   rec() );

    SetLeftActingDomain( V, R );
    SetGeneratorsOfLeftModule( V, AsList( lieelms ) );

    return V;
    end );

InstallOtherMethod( LeftModuleByGenerators,
    "method for ring, empty list, and Lie object",
    function( F1, F2, F3 ) return not IsElmsLieColls( F1, F3 ); end,
    [ IsRing, IsList and IsEmpty, IsLieObject ], 0,
    function( R, empty, zero )
    local V;

    V:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                IsFreeLeftModule
                            and IsLieObjectsModuleRep ),
                   rec() );
    SetLeftActingDomain( V, R );
    SetGeneratorsOfLeftModule( V, empty );
    SetZero( V, zero );

    return V;
    end );

InstallOtherMethod( LeftModuleByGenerators,
    "method for ring, list of Lie objects, and Lie object",
    function( F1, F2, F3 ) return not IsElmsCollLieColls( F1, F2 ); end,
    [ IsRing, IsLieObjectCollection and IsList, IsLieObject ], 0,
    function( R, lieelms, zero )
    local V;

    V:= Objectify( NewType( FamilyObj( lieelms ),
                                IsFreeLeftModule
                            and IsLieObjectsModuleRep ),
                   rec() );

    SetLeftActingDomain( V, R );
    SetGeneratorsOfLeftModule( V, AsList( lieelms ) );
    SetZero( V, zero );

    return V;
    end );


#############################################################################
##
#M  PrepareNiceFreeLeftModule( <liemodule> )
##
##  Nothing is to do \ldots
##
InstallMethod( PrepareNiceFreeLeftModule,
    "method for free module of Lie objects",
    true,
    [ IsFreeLeftModule and IsLieObjectsModuleRep ], 0,
    Ignore );


#############################################################################
##
#M  NiceVector( <M>, <lieelm> )
##
InstallMethod( NiceVector,
    "method for free module of Lie objects, and Lie object",
    IsCollsElms,
    [ IsFreeLeftModule and IsLieObjectsModuleRep, IsLieObject ], 0,
    function( M, lieelm )
    return lieelm![1];
    end );


#############################################################################
##
#M  UglyVector( <M>, <vector> ) .  for left module of Lie objects, and vector
##
InstallMethod( UglyVector,
    "method for free module of Lie objects, and vector",
    true,
    [ IsFreeLeftModule and IsLieObjectsModuleRep, IsVector ], 0,
    function( M, vector )
    return LieObject( vector );
    end );


#############################################################################
##
##  3. methods for FLMLORs of Lie elements
##     (there are special methods for Lie matrix spaces)
##

#############################################################################
##
#M  FLMLORByGenerators( <F>, <lie-elms> )
#M  FLMLORByGenerators( <F>, <empty>, <lie-zero> )
#M  FLMLORByGenerators( <F>, <lie-elms>, <lie-zero> )
##
InstallMethod( FLMLORByGenerators,
    "method for ring and list of Lie elements",
    true,
    [ IsRing, IsLieObjectCollection and IsList ], 0,
    function( R, elms )
    local A;

    A:= Objectify( NewType( FamilyObj( elms ),
                                IsFLMLOR
                            and IsLieAlgebra
                            and IsLieObjectsModuleRep ),
                     rec() );

    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftOperatorRing( A, AsList( elms ) );

    # Return the result.
    return A;
    end );

InstallOtherMethod( FLMLORByGenerators,
    "method for ring, empty list, and Lie object",
    true,
    [ IsRing, IsList and IsEmpty, IsLieObject ], 0,
    function( R, empty, zero )
    local A;

    A:= Objectify( NewType( CollectionsFamily( FamilyObj( zero ) ),
                                IsFLMLOR
                            and IsLieObjectsModuleRep
                            and IsTrivial ),
                   rec() );
    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftModule( A, empty );
    SetZero( A, zero );

    # Return the result.
    return A;
    end );

InstallOtherMethod( FLMLORByGenerators,
    "method for ring, list of Lie objects, and Lie object",
    true,
    [ IsRing, IsLieObjectCollection and IsList, IsLieObject ], 0,
    function( R, elms, zero )
    local A;

    A:= Objectify( NewType( FamilyObj( elms ),
                                IsFLMLOR
                            and IsLieAlgebra
                            and IsLieObjectsModuleRep ),
                   rec() );

    SetLeftActingDomain( A, R );
    SetGeneratorsOfLeftOperatorRing( A, AsList( elms ) );
    SetZero( A, zero );

    # Return the result.
    return A;
    end );


#############################################################################
##
#E  liefam.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



