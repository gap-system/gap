#############################################################################
##
#W  liefam.gi                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.liefam_gi :=
    "@(#)$Id$";


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
#T maintain other req/imp properties as implied properties of 'F'?

    # Enter the kind of objects in the image.
    F!.packedKind:= NewKind( F, IsLieObject );

    # Return the Lie family.
    return F;
    end );

InstallMethod( LieFamily, true, [ IsFamilyCollections ], 0,
    function( Fam )

    local F;

    # Make the family of Lie elements.
    F:= NewFamily( "LieFamily(...)", IsLieObject and IsMatrix );

    # Enter the kind of objects in the image.
    F!.packedKind:= NewKind( F, IsLieObject and IsMatrix );

    # Return the Lie family.
    return F;
    end );


#############################################################################
##
#M  LieObject( <obj> )
##
InstallMethod( LieObject, true, [ IsRingElement ], 0,
    obj -> Objectify( LieFamily( FamilyObj( obj ) )!.packedKind,
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

InstallMethod( \*, IsIdentical, [ IsLieObject, IsLieObject ], 1,
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
    if IsFamLieFam( FamilyObj( z ), FamilyObj( x ) ) then
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

InstallOtherMethod( One, true, [ IsLieObject ], 0,
    function( x )
    Error( "no identity in Lie families" );
    end );

InstallOtherMethod( Inverse, true, [ IsLieObject ], 0,
    function( x )
    Error( "no inverses in Lie families" );
    end );

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
    IsMapping and IsInjective and IsAttributeStoringRep,
    [ "packedKind" ] );


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
    emb := Objectify( KindOfDefaultGeneralMapping( Fam, LieFam,
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

#T InstallMethod( ImagesSet, CollFamSourceEqFamElms, [ IsLieEmbedding, IsDomain ], 0,
#T     function ( emb, elms )
#T     ...
#T     end );

InstallMethod( PreImagesElm, FamRangeEqFamElm,
    [ IsLieEmbedding, IsObject ], 0,
    function ( emb, elm )
    return [ elm![1] ];
    end );

#T InstallMethod( PreImagesSet, CollFamRangeEqFamElms, [ IsLieEmbedding, IsDomain ], 0,
#T     function ( emb, elms )
#T     ...
#T     end );


#############################################################################
##
#E  liefam.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



