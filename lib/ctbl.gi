#############################################################################
##
#W  ctbl.gi                     GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains generic methods for character tables.
##
##  1. methods for operations that take a group or a table as argument
##  2. method for character tables only
##
Revision.ctbl_gi :=
    "@(#)$Id$";


#T introduce '\=' and '<' for character tables


#############################################################################
##
##  1. methods for operations that take a group or a table as argument
##
##  The table may delegate to the group.
##  The table may compute without the help of the group.
##  The group may call a method for its ordinary table (but must *not* call
##  the operation for its ordinary table).
##
##  For the following ``groupy'' operations, there are methods that allow
##  an ordinary character table instead of a group.
##
##  'CharacterDegreesAttr',
##  'CharacterTable',
##  'ClassMultiplicationCoefficient',
##  'OrdinaryCharacterTable',
##  'Irr',
##  'NrConjugacyClasses',
##  'Size',
##  'SizesConjugacyClasses',
##  'SizesCentralizers',
##  'OrdersClassRepresentatives'
##
##  For the following ``tably'' operations, there are methods that allow
##  a group instead of an ordinary character table.
##  (The reason to treat them the other way around is that we want to store
##  the info in the table and not in the group; the reason for this is that
##  we can use the stored info also if no underlying group is known.)
##
##  'BrauerCharacterTable',
##  'PowerMap',
##  'FusionConjugacyClasses'
##


#############################################################################
##
#F  CharacterDegrees( <G> ) . . . . . . . . . . . . . . . . . . . for a group
#F  CharacterDegrees( <G>, <p> )  . . . . . . . . . . for a group and a prime
#F  CharacterDegrees( <tbl> ) . . . . . . . . . . . . . for a character table
##
CharacterDegrees := function( arg )
    if     Length( arg ) = 1
       and ( IsGroup( arg[1] ) or IsCharacterTable( arg[1] ) ) then
      return CharacterDegreesAttr( arg[1] );
    elif Length( arg ) = 2 and IsGroup( arg[1] ) and IsInt( arg[2] ) then
      return CharacterDegreesOp( arg[1], arg[2] );
    fi;
    Error( "usage: CharacterDegrees(<G>[,<p>]) or CharacterDegrees(<tbl>)" );
end;


#############################################################################
##
#M  CharacterDegreesAttr( <G> ) . . . . . . . . . . . . . . . . . for a group
#M  CharacterDegreesOp( <G>, <zero> ) . . . . . . . . .  for a group and zero
##
##  The attribute delegates to the operation.
##  The operation delegates to 'Irr'.
##
InstallMethod( CharacterDegreesAttr,
    "method for a group",
    true,
    [ IsGroup ], 0,
    G -> CharacterDegreesOp( G, 0 ) );

InstallOtherMethod( CharacterDegreesOp,
    "method for a group, and zero",
    true,
    [ IsGroup, IsZeroCyc ], 0,
    function( G, zero )
    return Collected( List( Irr( G ), DegreeOfCharacter ) );
    end );

InstallOtherMethod( CharacterDegreesOp,
    "method for a group, and positive integer",
    true,
    [ IsGroup, IsInt and IsPosRat ], 0,
    function( G, p )
    if Size( G ) mod p = 0 then
      return CharacterDegreesAttr( CharacterTable( G, p ) );
    else
      return CharacterDegreesAttr( G );
    fi;
    end );


#############################################################################
##
#M  CharacterDegreesAttr( <tbl> ) . . . . . . . . . . . for a character table
##
##  We delegate to 'Irr' for the table.
##  The ordinary table may ask its group.
##
InstallOtherMethod( CharacterDegreesAttr,
    "method for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> Collected( List( Irr( tbl ), DegreeOfCharacter ) ) );

InstallOtherMethod( CharacterDegreesAttr,
    "method for an ordinary character table with group",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    tbl -> CharacterDegreesAttr( UnderlyingGroup( tbl ) ) );


#############################################################################
##
#M  CharacterDegreesAttr( <G> ) . . . for group handled via nice monomorphism
##
AttributeMethodByNiceMonomorphism( CharacterDegreesAttr,
    [ IsGroup ] );


#############################################################################
##
#M  CharacterTable( <G>, <p> )  . . . . . characteristic <p> table of a group
#M  CharacterTable( <ordtbl>, <p> )
#M  CharacterTable( <G> ) . . . . . . . . . . ordinary char. table of a group
##
##  We delegate to 'OrdinaryCharacterTable' or 'BrauerCharacterTable'.
##
InstallMethod( CharacterTable,
    "method for a group and a prime",
    true,
    [ IsGroup, IsInt ], 0,
    function( G, p )
    if p = 0 then
      return OrdinaryCharacterTable( G );
    else
      return BrauerCharacterTable( OrdinaryCharacterTable( G ), p );
    fi;
    end );

InstallOtherMethod( CharacterTable,
    "method for an ordinary table and a prime",
    true,
    [ IsOrdinaryTable, IsInt and IsPosRat ], 0,
    BrauerCharacterTable );

InstallOtherMethod( CharacterTable,
    "method for a group (delegate to 'OrdinaryCharacterTable')",
    true,
    [ IsGroup ], 0,
    OrdinaryCharacterTable );


#############################################################################
##
#M  ClassMultiplicationCoefficient( <ordtbl>, <c1>, <c2>, <c3> )
##
##  We either delegate to the group or use the irreducibles (if known)
##
InstallOtherMethod( ClassMultiplicationCoefficient,
    "method for an ord. table with group, and three pos. integers",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup,
      IsInt and IsPosRat, IsInt and IsPosRat, IsInt and IsPosRat ], 0,
    function( ordtbl, c1 ,c2, c3 )
    return ClassMultiplicationCoefficient( UnderlyingGroup( ordtbl ),
                                           c1, c2, c3 );
    end );

InstallOtherMethod( ClassMultiplicationCoefficient,
    "method for an ord. table with irreducibles, and three pos. integers",
    true,
    [ IsOrdinaryTable and HasIrr,
      IsInt and IsPosRat, IsInt and IsPosRat, IsInt and IsPosRat ], 10,
    function( ordtbl, c1 ,c2, c3 )

    local res, chi, char, classes;

    res:= 0;
    for chi in Irr( ordtbl ) do
       char:= ValuesOfClassFunction( chi );
       res:= res + char[c1] * char[c2] * GaloisCyc(char[c3], -1) / char[1];
    od;
    classes:= SizesConjugacyClasses( ordtbl );
    return classes[c1] * classes[c2] * res / Size( ordtbl );
    end );


#############################################################################
##
#F  ClassStructureCharTable(<tbl>,<classes>)  . gener. class mult. coefficent
##
ClassStructureCharTable := function( tbl, classes )

    local exp;

    exp:= Length( classes ) - 2;
    if exp < 0 then
      Error( "length of <classes> must be at least 2" );
    fi;

    return Sum( Irr( tbl ),
                chi -> Product( chi{ classes } ) / ( chi[1] ^ exp ) )
           * Product( SizesConjugacyClasses( tbl ){ classes } )
           / Size( tbl );
end;


#############################################################################
##
#F  MatClassMultCoeffsCharTable( <tbl>, <class> )
##
MatClassMultCoeffsCharTable := function( tbl, class )
    local nccl;
    nccl:= NrConjugacyClasses( tbl );
    return List( [ 1 .. nccl ],
                 j -> List( [ 1 .. nccl ],
                 k -> ClassMultiplicationCoefficient( tbl, class, j, k ) ) );
end;


#############################################################################
##
#M  OrdinaryCharacterTable( <G> ) . . . . . . . . . . . . . . . . for a group
#M  OrdinaryCharacterTable( <modtbl> )  . . . .  for a Brauer character table
##
##  In the first case, we setup the table object.
##  In the second case, we delegate to 'OrdinaryCharacterTable' for the
##  group.
##
InstallMethod( OrdinaryCharacterTable,
    "method for a group",
    true,
    [ IsGroup ], 0,
    function( G )
    local tbl;

    # Make the object.
    tbl:= Objectify( NewKind( NearlyCharacterTablesFamily,
                              IsOrdinaryTable and IsAttributeStoringRep ),
                     rec() );

    SetUnderlyingGroup( tbl, G );
    SetUnderlyingCharacteristic( tbl, 0 );

    return tbl;
    end );

InstallOtherMethod( OrdinaryCharacterTable,
    "method for a Brauer character table with group",
    true,
    [ IsBrauerTable and HasUnderlyingGroup ], 0,
    modtbl -> OrdinaryCharacterTable( UnderlyingGroup( modtbl ) ) );


#############################################################################
##
#F  BrauerCharacterTable( <ordtbl>, <p> ) . . . . . . . . . <p>-modular table
#F  BrauerCharacterTable( <G>, <p> )
##
##  Note that Brauer tables are stored in the ordinary table and not in the
##  group.
##
BrauerCharacterTable := function( ordtbl, p )

    local known;
    if IsGroup( ordtbl ) then
      ordtbl:= OrdinaryCharacterTable( ordtbl );
    fi;
    if not IsOrdinaryTable( ordtbl ) then
      Error( "<ordtbl> must be an ordinary character table" );
    elif not IsInt( p ) or not IsPrimeInt( p )  then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedBrauerCharacterTables( ordtbl );

    # compute the <p>-modular table
    if not IsBound( known[p] ) then
      known[p] := BrauerCharacterTableOp( ordtbl, p );
    fi;

    # return the <p>-modular table
    return known[p];
end;


#############################################################################
##
#M  BrauerCharacterTableOp( <ordtbl>, <p> ) . . . . . . . . <p>-modular table
##
##  Note that we do not need a method for the first argument a group,
##  since 'BrauerCharacterTable' delegates this to the ordinary table.
##
InstallMethod( BrauerCharacterTableOp,
    "method for ordinary character table, and positive integer",
    true,
    [ IsOrdinaryTable, IsInt and IsPosRat ], 0,
    function( ordtbl, p )
    local tbl;

    # Make the object.
    tbl:= Objectify( NewKind( NearlyCharacterTablesFamily,
                              IsBrauerTable and IsAttributeStoringRep ),
                     rec() );
 
    SetOrdinaryCharacterTable( tbl, ordtbl );
    SetUnderlyingCharacteristic( tbl, p );

    return tbl;
    end );


#############################################################################
##
#M  ComputedBrauerCharacterTables( <ordtbl> ) . . for an ord. character table
##
InstallMethod( ComputedBrauerCharacterTables,
    "method for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    ordtbl -> [] );


#############################################################################
##
#M  \mod( <ordtbl>, <p> ) . . . . . . . . . . . . . . . . . <p>-modular table
##
InstallMethod( \mod,
    "method for ordinary character table, and positive integer",
    true,
    [ IsOrdinaryTable, IsInt and IsPosRat ], 0,
    BrauerCharacterTableOp );


#############################################################################
##
#F  IBr( <G>, <p> )
#F  IBr( <modtbl> )
##
IBr := function( arg )
    if Length( arg ) = 1 and IsBrauerTable( arg[1] ) then
      return Irr( arg[1] );
    elif Length( arg ) = 2 and IsGroup( arg[1] ) and IsInt( arg[2] )
                           and IsPrimeInt( arg[2] ) then
      return Irr( BrauerCharacterTable( OrdinaryCharacterTable( arg[1] ),
                                        arg[2] ) );
    else
      Error( "usage: IBr( <G>, <p> ) for group <G> and prime <p>" );
    fi;
end;


#############################################################################
##
#F  IBrForPSolvableTable( <modtbl> )
##
##  Compute the modular irreducibles from the ordinary irreducibles
##  using the Fong-Swan theorem.
##
IBrForPSolvableTable := function( modtbl )

    local p,       # characteristic
          ordtbl,  # ordinary character table
          i,       # loop variable
          rest,    # restriction of characters to 'p'-regular classes
          irr,     # list of Brauer characters
          cd,      # list of ordinary character degrees
          degree,  # one character degree
          chars,   # characters of a given degree
          dec;     # decomposition of ordinary characters
                   # into known Brauer characters

    p:= UnderlyingCharacteristic( modtbl );
    ordtbl:= OrdinaryCharacterTable( modtbl );

    rest:= RestrictedClassFunctions( ordtbl, modtbl, Irr( ordtbl ) );
    irr:= Set( Filtered( rest, x -> DegreeOfCharacter( x ) = 1 ) );
    cd:= Set( List( rest, DegreeOfCharacter ) );
    RemoveSet( cd, 1 );

    for degree in cd do
      chars:= Set( Filtered( rest, x -> DegreeOfCharacter( x ) = degree ) );
#T improve this!!!
      dec:= Decomposition( irr, chars, "nonnegative" );
      for i in [ 1 .. Length( dec ) ] do
        if dec[i] = fail then
          Add( irr, chars[i] );
        fi;
      od;
    od;

    return irr;
end;


#############################################################################
##
#M  Irr( <modtbl> ) . . . . . . . . . . . . . for a <p>-solvable Brauer table
##
InstallOtherMethod( Irr,
    "method for a <p>-solvable Brauer table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    if IsPSolvable( OrdinaryCharacterTable( modtbl ) ) then
      return IBrForPSolvableTable( modtbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Irr( <G> )  . . . . . . . . . . . . . . . . . . . . . . . . . for a group
##


#############################################################################
##
#M  Irr( <ordtbl> ) . . . . . . . . . . . . . for an ordinary character table
##
##  We must delegate this to the underlying group.
##
InstallOtherMethod( Irr,
    "method for an ordinary character table",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    ordtbl -> Irr( UnderlyingGroup( ordtbl ) ) );


#############################################################################
##
#M  NrConjugacyClasses( <ordtbl> )  . . . . . for an ordinary character table
#M  NrConjugacyClasses( <modtbl> )  . . . . . .  for a Brauer character table
#M  NrConjugacyClasses( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the centralizer orders or class lengths, however, we use them.
##
##  If the argument is a group, we can use the known class lengths of the
##  known ordinary character table.
##
InstallOtherMethod( NrConjugacyClasses,
    "method for an ordinary character table with underlying group",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    ordtbl -> NrConjugacyClasses( UnderlyingGroup( ordtbl ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "method for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    modtbl -> Length( GetFusionMap( modtbl,
                                    OrdinaryCharacterTable( modtbl ) ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "method for a character table with known centralizer sizes",
    true,
    [ IsNearlyCharacterTable and HasSizesCentralizers ], 0,
    tbl -> Length( SizesCentralizers( tbl ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "method for a character table with known class lengths",
    true,
    [ IsNearlyCharacterTable and HasSizesConjugacyClasses ], 0,
    tbl -> Length( SizesConjugacyClasses( tbl ) ) );

InstallOtherMethod( NrConjugacyClasses,
    "method for a group with known ordinary character table",
    true,
    [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T ?
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasNrConjugacyClasses( tbl ) then
      return NrConjugacyClasses( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Size( <tbl> ) . . . . . . . . . . . . . . . . . . . for a character table
#M  Size( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the centralizer orders, however, we use them.
##
##  If the argument is a group, we can use the known size of the
##  known ordinary character table.
##
InstallOtherMethod( Size,
    "method for a character table with underlying group",
    true,
    [ IsCharacterTable and HasUnderlyingGroup ], 0,
    tbl -> Size( UnderlyingGroup( tbl ) ) );
   

InstallOtherMethod( Size,
    "method for a character table with known centralizer sizes",
    true,
    [ IsNearlyCharacterTable and HasSizesCentralizers ], 100,
    tbl -> SizesCentralizers( tbl )[1] );
#T immediate method ?


InstallOtherMethod( Size,
    "method for a group with known ordinary character table",
    true,
    [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T ?
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasSize( tbl ) then
      return Size( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  SizesConjugacyClasses( <ordtbl> ) . . . . for an ordinary character table
#M  SizesConjugacyClasses( <modtbl> ) . . . . .  for a Brauer character table
#M  SizesConjugacyClasses( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the centralizer orders, however, we use them.
##
##  If the argument is a group, we can use the known class lengths of the
##  known ordinary character table.
##
InstallOtherMethod( SizesConjugacyClasses,
    "method for an ordinary character table with underlying group",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    ordtbl -> SizesConjugacyClasses( UnderlyingGroup( ordtbl ) ) );

InstallOtherMethod( SizesConjugacyClasses,
    "method for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return SizesConjugacyClasses( ordtbl ){ GetFusionMap( modtbl,
                                                          ordtbl ) };
    end );

InstallOtherMethod( SizesConjugacyClasses,
    "method for a character table with known centralizer sizes",
    true,
    [ IsNearlyCharacterTable and HasSizesCentralizers ], 100,
    function( tbl )
    local centsizes, size;
    centsizes:= SizesCentralizers( tbl );
    size:= centsizes[1];
    return List( centsizes, s -> size / s );
    end );

InstallOtherMethod( SizesConjugacyClasses,
    "method for a group with known ordinary character table",
    true,
    [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T ?
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasSizesConjugacyClasses( tbl ) then
      return SizesConjugacyClasses( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  SizesCentralizers( <ordtbl> ) . . . . . . for an ordinary character table
#M  SizesCentralizers( <modtbl> ) . . . . . . .  for a Brauer character table
#M  SizesCentralizers( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the class lengths, however, we use them.
##
##  If the argument is a group, we can use the known centralizer orders of
##  the known ordinary character table.
##
InstallOtherMethod( SizesCentralizers,
    "method for an ordinary character table with underlying group",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    ordtbl -> SizesCentralizers( UnderlyingGroup( ordtbl ) ) );

InstallOtherMethod( SizesCentralizers,
    "method for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return SizesCentralizers( ordtbl ){ GetFusionMap( modtbl, ordtbl ) };
    end );

InstallOtherMethod( SizesCentralizers,
    "method for a character table with known class lengths",
    true,
    [ IsNearlyCharacterTable and HasSizesConjugacyClasses ], 100,
    function( tbl )
    local classlengths, size;
    classlengths:= SizesConjugacyClasses( tbl );
    size:= Sum( classlengths );
    return List( classlengths, s -> size / s );
    end );

InstallOtherMethod( SizesCentralizers,
    "method for a group with known ordinary character table",
    true,
    [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T ?
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasSizesCentralizers( tbl ) then
      return SizesCentralizers( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  OrdersClassRepresentatives( <ordtbl> )  . for an ordinary character table
#M  OrdersClassRepresentatives( <modtbl> )  . .  for a Brauer character table
#M  OrdersClassRepresentatives( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##  If we know the class lengths, however, we use them.
##
##  If the argument is a group, we can use the known centralizer orders of
##  the known ordinary character table.
##
InstallOtherMethod( OrdersClassRepresentatives,
    "method for an ordinary table with underlying group",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup ], 0,
    tbl -> OrdersClassRepresentatives( UnderlyingGroup( tbl ) ) );

InstallOtherMethod( OrdersClassRepresentatives,
    "method for a Brauer character table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return OrdersClassRepresentatives( ordtbl ){ GetFusionMap( modtbl,
                                                               ordtbl ) };
    end );

#T missing: method to compute orders from power maps

InstallOtherMethod( OrdersClassRepresentatives,
    "method for a group with known ordinary character table",
    true,
    [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T ?
    function( G )
    local tbl;
    tbl:= OrdinaryCharacterTable( G );
    if HasOrdersClassRepresentatives( tbl ) then
      return OrdersClassRepresentatives( tbl );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  BlocksInfo( <tbl> )
##
#T missing!


#############################################################################
##
#M  IrredInfo( <tbl> )  . . . . . . . . . method for a nearly character table
##
##  initialize with empty records
##
InstallMethod( IrredInfo,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> List( [ 1 .. NrConjugacyClasses( tbl ) ],
                 i -> rec( indicator:= [], pblock:= [] ) ) );


#############################################################################
##
#M  ComputedClassFusions( <tbl> )
##
##  We do *not* store class fusions in groups,
##  'FusionConjugacyClasses' must store the fusion if the character tables
##  of both groups are known already.
#T !!
##
InstallMethod( ComputedClassFusions,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> [] );


#############################################################################
##
#F  PowerMapByComposition( <tbl>, <n> ) . .  for char. table and pos. integer
##
PowerMapByComposition := function( tbl, n )

    local powermap, nth_powermap, i;

    if not ( IsInt( n ) and IsPosRat( n ) ) then
      Error( "<n> must be a positive integer" );
    fi;
    powermap:= ComputedPowerMaps( tbl );
    nth_powermap:= [ 1 .. NrConjugacyClasses( tbl ) ];

    for i in Factors( n ) do
      if not IsBound( powermap[i] ) then
        return fail;
      fi;
      nth_powermap:= nth_powermap{ powermap[i] };
    od;

    # Return the map;
    return nth_powermap;
end;


#############################################################################
##
#F  PowerMap( <tbl>, <n> )  . . . . . . . . . for character table and integer
#F  PowerMap( <tbl>, <n>, <class> )
#F  PowerMap( <G>, <n> )  . . . . . . . . . . . . . . . for group and integer
#F  PowerMap( <G>, <n>, <class> )
##
##  We do not store power maps in groups, the group delegates to its ordinary
##  character table.
##
PowerMap := function( arg )

    local tbl, n, known;

    if Length( arg ) = 2 and IsInt( arg[2] ) then

      if IsGroup( arg[1] ) then

        return PowerMap( OrdinaryCharacterTable( arg[1] ), arg[2] );

      elif IsNearlyCharacterTable( arg[1] ) then

        tbl := arg[1];
        n   := arg[2];
        known:= ComputedPowerMaps( tbl );

        # compute the <n>-th power map
        if not IsBound( known[n] ) then
          known[n] := PowerMapOp( tbl, n );
        fi;

        # return the <p>-th power map
        return known[n];

      fi;

    elif Length( arg ) = 3 and IsInt( arg[2] ) and IsInt( arg[3] ) then

      if IsGroup( arg[1] ) then

        return PowerMap( OrdinaryCharacterTable( arg[1] ), arg[2], arg[3] );

      elif IsNearlyCharacterTable( arg[1] ) then

        tbl := arg[1];
        n   := arg[2];
        known:= ComputedPowerMaps( tbl );

        if IsBound( known[n] ) then
          return known[n][ arg[3] ];
        else
          return PowerMapOp( tbl, n, arg[3] );
        fi;

      fi;

    else
      Error( "usage: PowerMap( <tbl>, <n>[, <class>] )" );
    fi;

end;


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n> ) . . . . . .  for ord. table, and pos. integer
##
InstallMethod( PowerMapOp,
    "method for ordinary table with group, and positive integer",
    true,
    [ IsOrdinaryTable and HasUnderlyingGroup, IsInt and IsPosRat ], 0,
    function( tbl, n )

    local G, map, p;

    if IsPrimeInt( n ) then

      G:= UnderlyingGroup( tbl );
      map:= PowerMapOfGroup( G, n, ConjugacyClasses( G ) );

    else

      map:= [ 1 .. NrConjugacyClasses( tbl ) ];
      for p in Factors( n ) do
        map:= map{ PowerMap( tbl, p ) };
      od;

    fi;
    return map;
    end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n> ) . . . . . .  for ord. table, and pos. integer
##
InstallMethod( PowerMapOp,
    "method for ordinary table, and positive integer",
    true,
    [ IsOrdinaryTable, IsInt and IsPosRat ], 0,
    function( tbl, n )
    local i, powermap, nth_powermap, range, pmap;

    if HasUnderlyingGroup( tbl ) then
      TryNextMethod();
    fi;

    range:= [ 1 .. NrConjugacyClasses( tbl ) ];
    nth_powermap:= range;
    powermap:= ComputedPowerMaps( tbl );

    for i in Factors( n ) do
      if not IsBound( powermap[i] ) then

        # Compute the missing power map.
        pmap:= PossiblePowerMaps( tbl, i );
        if 1 < Length( pmap ) then
          Error( Ordinal( i ), " power map not determined for <tbl>" );
        fi;
        powermap[i]:= pmap[1];

      fi;
      nth_powermap:= nth_powermap{ powermap[i] };
    od;

    # Return the map;
    return nth_powermap;
    end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n>, <class> )
##
InstallOtherMethod( PowerMapOp,
    "method for ordinary table, and two positive integers",
    true,
    [ IsOrdinaryTable, IsInt and IsPosRat, IsInt and IsPosRat ], 0,
    function( tbl, n, class )

    local i, powermap, image, range, pmap;

    powermap:= ComputedPowerMaps( tbl );
    if n = 1 then
      return class;
    elif IsBound( powermap[n] ) then
      return powermap[n][ class ];
    fi;

    n:= n mod OrdersClassRepresentatives( tbl )[ class ];
    if n = 0 then
      return 1;
    elif n = 1 then
      return class;
    elif IsBound( powermap[n] ) then
      return powermap[n][ class ];
    fi;

    image:= class;
    for i in FactorsInt( n ) do
      if not IsBound( powermap[i] ) then

        # Compute the missing power map.
        powermap[i]:= PowerMap( tbl, i );
#T if the group is available, better ask it directly?
#T (careful: No maps are stored by the three-argument call,
#T this may slow down the computation if many calls are done ...)

      fi;
      image:= powermap[i][ image ];
    od;
    return image;
    end );


#############################################################################
##
#M  PowerMapOp( <tbl>, <n> )
##
InstallMethod( PowerMapOp,
    "method for character table and negative integer",
    true,
    [ IsCharacterTable, IsInt and IsNegRat ], 0,
    function( tbl, n )
    return PowerMap( tbl, -n ){ InverseClasses( tbl ) };
    end );


#############################################################################
##
#M  PowerMapOp( <tbl>, <zero> )
##
InstallMethod( PowerMapOp,
    "method for character table and zero",
    true,
    [ IsCharacterTable, IsZeroCyc ], 0,
    function( tbl, zero )
    return List( [ 1 .. NrConjugacyClasses( tbl ) ], i -> 1 );
    end );


#############################################################################
##
#M  PowerMapOp( <modtbl>, <n> )
##
InstallMethod( PowerMapOp,
    "method for Brauer table and positive integer",
    true,
    [ IsBrauerTable, IsInt and IsPosRat ], 0,
    function( tbl, n )
    local fus, ordtbl;
    ordtbl:= OrdinaryCharacterTable( tbl );
    fus:= GetFusionMap( tbl, ordtbl );
    return InverseMap( fus ){ PowerMap( ordtbl, n ){ fus } };
    end );


#############################################################################
##
#M  PowerMapOp( <modtbl>, <n>, <class> )
##
InstallOtherMethod( PowerMapOp,
    "method for Brauer table and two integers",
    true,
    [ IsBrauerTable, IsInt and IsPosRat, IsInt and IsPosRat ], 0,
    function( tbl, n, class )
    local fus, ordtbl;
#T check whether the map is stored already!
    ordtbl:= OrdinaryCharacterTable( tbl );
    fus:= GetFusionMap( tbl, ordtbl );
    return Position( fus, PowerMap( ordtbl, n, fus[ class ] ) );
    end );


#############################################################################
##
#M  ComputedPowerMaps( <tbl> )  . . . . . . . .  for a nearly character table
##
InstallMethod( ComputedPowerMaps,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> [] );


#############################################################################
##
##  2. method for character tables only
##


#############################################################################
##
#M  IsInternallyConsistent( <tbl> ) . . . . . . . . . . for a character table
##
##  Check consistency of information in the head of the character table
##  <tbl>, and check if the first orthogonality relation is satisfied.
##
InstallMethod( IsInternallyConsistent,
    "method for a character table",
    true,
    [ IsCharacterTable ], 0,
    function( tbl )

    local flag,
          centralizers,
          order,
          nccl,
          classes,
          orders,
          i, j, k, x,
          powermap,
          characters, map, row, sum,
          tbl_irredinfo;

    flag:= true;
    centralizers:= SizesCentralizers( tbl );
    order:= centralizers[1];
    if HasSize( tbl ) then
      if Size( tbl ) <> order then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): centralizer of identity not equal to group order" );
        flag:= false;
      fi;
    fi;

    nccl:= Length( centralizers );
    if HasSizesConjugacyClasses( tbl ) then
      classes:= SizesConjugacyClasses( tbl );
      if classes <> List( centralizers, x -> order / x ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): centralizers and class lengths inconsistent" );
        flag:= false;
      fi;
      if Length( classes ) <> nccl then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): number of classes and centralizers inconsistent" );
        flag:= false;
      fi;
    else
      classes:= List( centralizers, x -> order / x );
    fi;

    if Sum( classes ) <> order then
      Info( InfoWarning, 1,
            "IsInternallyConsistent(", tbl,
            "): sum of class lengths not equal to group order" );
      flag:= false;
    fi;

    if HasOrdersClassRepresentatives( tbl ) then
      orders:= OrdersClassRepresentatives( tbl );
      if nccl <> Length( orders ) then
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): number of classes and orders inconsistent" );
        flag:= false;
      else
        for i in [ 1 .. nccl ] do
          if centralizers[i] mod orders[i] <> 0 then
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl,
                  "): not all representative orders divide the\n",
                  "#I   corresponding centralizer order" );
            flag:= false;
          fi;
        od;
      fi;
    fi;

    if HasComputedPowerMaps( tbl ) then
      powermap:= ComputedPowerMaps( tbl );
      for map in Set( powermap ) do
        if nccl <> Length( map ) then
          Info( InfoWarning, 1,
                "IsInternallyConsistent(", tbl,
                "): lengths of power maps and classes inconsistent" );
          flag:= false;
        fi;
      od;
  
      # If the power maps of all prime divisors of the order are stored,
      # check if they are consistent with the representative orders.
      if     IsBound( orders )
         and ForAll( Set( FactorsInt( order ) ), x -> IsBound(powermap[x]) )
         and orders <> ElementOrdersPowerMap( powermap ) then
        flag:= false;
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): representative orders and power maps inconsistent" );
      fi;
    fi;

    # From here on, we check the irreducible characters.
    if flag = false then
      Info( InfoWarning, 1,
            "IsInternallyConsistent(", tbl,
            "): corrupted table, no test of orthogonality" );
      return false;
    fi;

    if HasIrr( tbl ) then
      characters:= Irr( tbl );
      for i in [ 1 .. Length( characters ) ] do
        row:= [];
        for j in [ 1 .. Length( characters[i] ) ] do
          row[j]:= GaloisCyc( characters[i][j], -1 ) * classes[j];
        od;
        for j in [ 1 .. i ] do
          sum:= row * characters[j];
          if ( i = j and sum <> order ) or ( i <> j and sum <> 0 ) then
            flag:= false;
            Info( InfoWarning, 1,
                  "IsInternallyConsistent(", tbl,
                  "): Scpr( ., X[", i, "], X[", j, "] ) = ",
                  sum / order );
          fi;
        od;
      od;

      if centralizers <> Sum( characters,
                              x -> List( x, y -> y * GaloisCyc(y,-1) ) ) then
        flag:= false;
        Info( InfoWarning, 1,
              "IsInternallyConsistent(", tbl,
              "): centralizer orders inconsistent with irreducibles" );
      fi;

      if HasIrredInfo( tbl ) then

        tbl_irredinfo:= IrredInfo( tbl );

        if IsBound(tbl_irredinfo[1].indicator) then
          for i in [ 2 .. Length( tbl_irredinfo[1].indicator ) ] do
            if IsBound( tbl_irredinfo[1].indicator[i] ) then
              if List( tbl_irredinfo, x -> x.indicator[i] )
                 <> Indicator( tbl, i ) then
                Info( InfoWarning, 1,
                      "IsInternallyConsistent(", tbl,
                      "): ", Ordinal( i ), " indicator not correct" );
                flag:= false;
              fi;
            fi;
          od;
        fi;

      fi;
    fi;

    return flag;
    end );


#############################################################################
##
#F  InverseMap( <paramap> )  . . . . . . . . .  Inverse of a parametrized map
##
##
InverseMap := function( paramap )
    local i, inversemap, im;
    inversemap:= [];
    for i in [ 1 .. Length( paramap ) ] do
      if IsList( paramap[i] ) then
        for im in paramap[i] do
          if IsBound( inversemap[ im ] ) then
            AddSet( inversemap[ im ], i );
          else
            inversemap[ im ]:= [ i ];
          fi;
        od;
      else
        if IsBound( inversemap[ paramap[i] ] ) then
          AddSet( inversemap[ paramap[i] ], i );
        else
          inversemap[ paramap[i] ]:= [ i ];
        fi;
      fi;
    od;
    for i in [ 1 .. Length( inversemap ) ] do
      if IsBound( inversemap[i] ) and Length( inversemap[i] ) = 1 then
        inversemap[i]:= inversemap[i][1];
      fi;
    od;
    return inversemap;
end;


#############################################################################
##
#F  NrPolyhedralSubgroups( <tbl>, <c1>, <c2>, <c3>)  . # polyhedral subgroups
##
NrPolyhedralSubgroups := function(tbl, c1, c2, c3)
    local orders, res, ord;

    orders:= OrdersClassRepresentatives( tbl );

    if orders[c1] = 2 then
       res:= ClassMultiplicationCoefficient(tbl, c1, c2, c3)
             * SizesConjugacyClasses( tbl )[c3];
       if orders[c2] = 2 then
          if orders[c3] = 2 then   # V4
             ord:= Length(Set([c1, c2, c3]));
             if ord = 2 then
                res:= res * 3;
             elif ord = 3 then
                res:= res * 6;
             fi;
             res:= res / 6;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "V4");
          elif orders[c3] > 2 then   # D2n
             ord:= orders[c3];
             if c1 <> c2 then 
                res:= res * 2;
             fi;
             res:= res * Length(ClassOrbitCharTable(tbl,c3))/(ord*Phi(ord));
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, 
                        type:= Concatenation("D" ,String(2*ord)));
          fi;
       elif orders[c2] = 3 then
          if orders[c3] = 3 then   # A4
             res:= res * Length(ClassOrbitCharTable(tbl, c3)) / 24;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "A4");
          elif orders[c3] = 4 then   # S4
             res:= res / 24;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "S4");
          elif orders[c3] = 5 then   # A5
             res:= res * Length(ClassOrbitCharTable(tbl, c3)) / 120;
             if not IsInt(res) then
                Error("noninteger result");
             fi;
             return rec(number:= res, type:= "A5");
          fi;
       fi;
    fi;
end;


#############################################################################
##
#M  ClassParameters( <tbl> )  . . . . . . . . .  for a nearly character table
##
InstallMethod( ClassParameters,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )
    Error( "no default method to compute class parameters" );
    end );


#############################################################################
##
#M  ClassNames( <tbl> )  . . . . . . . . . . class names of a character table
##
##  'ClassNames' computes names for the classes of the character table <tbl>.
##  Each class name is a string consisting of the order of elements of the
##  class and and least one distinguishing letter.
##
InstallMethod( ClassNames,
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )

    local i,        # loop variable
          alpha,    # alphabet
          lalpha,   # length of the alphabet
          number,   # at position <i> the current number of
                    # classes of order <i>
          unknown,  # number of next unknown element order
          names,    # list of classnames, result
          name,     # local function returning right combination of letters
          orders;   # list of representative orders

    alpha:= [ "a","b","c","d","e","f","g","h","i","j","k","l","m",
              "n","o","p","q","r","s","t","u","v","w","x","y","z" ];
    lalpha:= Length( alpha );

    name:= function(n)
       local name;
       name:= "";
       while 0 < n do
          name:= Concatenation( alpha[ (n-1) mod lalpha + 1 ], name );
          n:= QuoInt( n-1, lalpha );
       od;
       return name;
    end;

    names:= [];

    if HasUnderlyingGroup( tbl ) or HasOrdersClassRepresentatives( tbl ) then

      orders:= OrdersClassRepresentatives( tbl );
      number:= [];
      unknown:= 1;
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        if IsInt( orders[i] ) then
          if not IsBound( number[ orders[i] ] ) then
            number[ orders[i] ]:= 1;
          fi;
          names[i]:= Concatenation( String( orders[i] ),
                                    name( number[ orders[i] ] ) );
          number[ orders[i] ]:= number[ orders[i] ] + 1;
        else
          names[i]:= Concatenation( "?", name( unknown ) );
          unknown:= unknown + 1;
        fi;
      od;

    else

      names[1]:= Concatenation( "1", alpha[1] );
      for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
        names[i]:= Concatenation( "?", name( i-1 ) );
      od;

    fi;

    # return the list of classnames
    return names;
    end );


#############################################################################
##
#M  \.( <tbl>, <name> ) . . . . . . . . . position of a class with given name
##
##  If <name> is a class name of the character table <tbl> as computed by
##  'ClassNames', '<tbl>.<name>' is the position of the class with this name.
##
InstallMethod( \.,
    "method for class names of a nearly character table",
    true,
    [ IsNearlyCharacterTable, IsString ], 0,
    function( tbl, name )
    local pos;
    name:= NameRNam( name );
    pos:= Position( ClassNames( tbl ), name );
    if pos = fail then
      TryNextMethod();
    else
      return pos;
    fi;
    end );


#############################################################################
##
#M  DisplayOptions( <tbl> )
##
InstallMethod( DisplayOptions,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> rec() );


#############################################################################
##
#M  Identifier( <tbl> )
##
#T missing!


#############################################################################
##
#M  InfoText( <tbl> ) . . . . . . . . . . . . .  for a nearly character table
##
InstallMethod( InfoText,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> "" );


#############################################################################
##
#M  InverseClasses( <tbl> ) . . .  method for an ord. table with irreducibles
##
InstallMethod( InverseClasses,
    "method for a character table with known irreducibles",
    true,
    [ IsCharacterTable and HasIrr ], 0,
    function( tbl )

    local nccl,
          irreds,
          inv,
          isinverse,
          chi,
          remain,
          i, j;

    nccl:= NrConjugacyClasses( tbl );
    irreds:= Irr( tbl );
    inv:= [ 1 ];

    isinverse:= function( i, j )         # is 'j' the inverse of 'i' ?
    for chi in irreds do
      if not IsRat( chi[i] ) and chi[i] <> GaloisCyc( chi[j], -1 ) then
        return false;
      fi;
    od;
    return true;
    end;

    remain:= [ 2 .. nccl ];
    for i in [ 2 .. nccl ] do
      if i in remain then
        for j in remain do
          if isinverse( i, j ) then
            inv[i]:= j;
            inv[j]:= i;
            SubtractSet( remain, Set( [ i, j ] ) );
            break;
          fi;
        od;
      fi;
    od;
    return inv;
    end );


#############################################################################
##
#M  InverseClasses( <tbl> ) . . . . . . . . . .  method for a character table
##
InstallMethod( InverseClasses,
    "method for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> PowerMap( tbl, -1 ) );
    

#############################################################################
##
#M  NamesOfFusionSources( <tbl> ) . . . . . . .  for a nearly character table
##
InstallMethod( NamesOfFusionSources,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    tbl -> [] );


#############################################################################
##
#M  AutomorphismsOfTable( <tbl> )
##

#T missing!


#############################################################################
##
#M  CharacterTableDirectProduct( <ordtbl1>, <ordtbl2> )
##
InstallMethod( CharacterTableDirectProduct,
    IsIdentical,
    [ IsOrdinaryTable, IsOrdinaryTable ], 0,
    function( tbl1, tbl2 )

    local direct,        # table of the direct product, result
          ncc1,          # no. of classes in 'tbl1'
          ncc2,          # no. of classes in 'tbl2'
          i, j, k,       # loop variables
          vals1,         # list of 'tbl1'
          vals2,         # list of 'tbl2'
          vals_direct,   # corresponding list of the result
          powermap_k,    # 'k'-th power map
          ncc2_i,        # 
          fus;           # projection/embedding map

    direct:= ConvertToOrdinaryTableNC( rec() );
    SetSize( direct, Size( tbl1 ) * Size( tbl2 ) );
    SetIdentifier( direct, Concatenation( Identifier( tbl1 ), "x",
                                          Identifier( tbl2 ) ) );
    SetSizesCentralizers( direct,
                      KroneckerProduct( [ SizesCentralizers( tbl1 ) ],
                                        [ SizesCentralizers( tbl2 ) ] )[1] );

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Compute class parameters, if present in both tables.
    if HasClassParameters( tbl1 ) and HasClassParameters( tbl2 ) then

      vals1:= ClassParameters( tbl1 );
      vals2:= ClassParameters( tbl2 );
      vals_direct:= [];
      for i in [ 1 .. ncc1 ] do
        for j in [ 1 .. ncc2 ] do
          vals_direct[ j + ncc2 * ( i - 1 ) ]:= [ vals1[i], vals2[j] ];
        od;
      od;
      SetClassParameters( direct, vals_direct );
    fi;

    # Compute element orders.
    vals1:= OrdersClassRepresentatives( tbl1 );
    vals2:= OrdersClassRepresentatives( tbl2 );
    vals_direct:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do
        vals_direct[ j + ncc2 * ( i - 1 ) ]:= Lcm( vals1[i], vals2[j] );
      od;
    od;
    SetOrdersClassRepresentatives( direct, vals_direct );
    
    # Compute power maps for all prime divisors of the result order.
    vals_direct:= ComputedPowerMaps( direct );
    for k in Union( FactorsInt( Size( tbl1 ) ),
                    FactorsInt( Size( tbl2 ) ) ) do
      powermap_k:= [];
      vals1:= PowerMap( tbl1, k );
      vals2:= PowerMap( tbl2, k );
      for i in [ 1 .. ncc1 ] do
        ncc2_i:= ncc2 * (i-1);
        for j in [ 1 .. ncc2 ] do
          powermap_k[ j + ncc2_i ]:= vals2[j] + ncc2 * ( vals1[i] - 1 );
        od;
      od;
      vals_direct[k]:= powermap_k;
    od;

    # Compute the irreducibles.
    SetIrr( direct, List( KroneckerProduct(
                                List( Irr( tbl1 ), ValuesOfClassFunction ),
                                List( Irr( tbl2 ), ValuesOfClassFunction ) ),
                          vals -> CharacterByValues( direct, vals ) ) );

    # Form character parameters if they exist for the irreducibles
    # in both tables.
    if HasIrredInfo( tbl1 ) and HasIrredInfo( tbl2 ) then
      vals1:= IrredInfo( tbl1 );
      vals2:= IrredInfo( tbl2 );
      if     IsBound( vals1[1].charparam )
         and IsBound( vals2[1].charparam ) then
        vals_direct:= IrredInfo( direct );
        for i in [ 1 .. ncc1 ] do
          for j in [ 1 .. ncc2 ] do
            vals_direct[ j + ncc2 * ( i - 1 ) ].charparam:=
                                [ vals1[i].charparam, vals2[j].charparam ];
          od;
        od;
      fi;
    fi;

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( direct, tbl1, fus );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( direct, tbl2, fus );

    StoreFusion( tbl1, direct, [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ], "1" );
    StoreFusion( tbl2, direct, [ 1 .. ncc2 ], "2" );

    # Return the table of the direct product.
    return direct;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <modtbl>, <ordtbl> )
##
InstallMethod( CharacterTableDirectProduct,
    "method for one Brauer and one ordinary character table",
    IsIdentical,
    [ IsBrauerTable, IsOrdinaryTable ], 0,
    function( tbl1, tbl2 )

    local ncc1,     # no. of classes in 'tbl1'
          ncc2,     # no. of classes in 'tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if Size( tbl2 ) mod UnderlyingCharacteristic( tbl1 ) <> 0 then
      Error( "no direct product of Brauer table and p-singular ordinary" );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( OrdinaryCharacterTable(tbl1), tbl2 );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl1 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> CharacterByValues( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, tbl1, fus );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, tbl2, fus );

    StoreFusion( tbl1, reg, [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ], "1" );
    StoreFusion( tbl2, reg, [ 1 .. ncc2 ], "2" );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <ordtbl>, <modtbl> )
##
InstallMethod( CharacterTableDirectProduct,
    "method for one ordinary and one Brauer character table",
    IsIdentical,
    [ IsOrdinaryTable, IsBrauerTable ], 0,
    function( tbl1, tbl2 )

    local ncc1,     # no. of classes in 'tbl1'
          ncc2,     # no. of classes in 'tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if Size( tbl1 ) mod UnderlyingCharacteristic( tbl2 ) <> 0 then
      Error( "no direct product of Brauer table and p-singular ordinary" );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( tbl1, OrdinaryCharacterTable(tbl2) );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl2 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> CharacterByValues( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, tbl1, fus );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, tbl2, fus );

    StoreFusion( tbl1, reg, [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ], "1" );
    StoreFusion( tbl2, reg, [ 1 .. ncc2 ], "2" );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  CharacterTableDirectProduct( <modtbl1>, <modtbl2> )
##
InstallMethod( CharacterTableDirectProduct,
    "method for two Brauer character tables",
    IsIdentical,
    [ IsBrauerTable, IsBrauerTable ], 0,
    function( tbl1, tbl2 )

    local ncc1,     # no. of classes in 'tbl1'
          ncc2,     # no. of classes in 'tbl2'
          ord,      # ordinary table of product,
          reg,      # Brauer table of product,
          fus,      # fusion map
          i, j;     # loop variables

    # Check that the result will in fact be a Brauer table.
    if    UnderlyingCharacteristic( tbl1 )
       <> UnderlyingCharacteristic( tbl2 ) then
      Error( "no direct product of Brauer tables in different char." );
    fi;

    ncc1:= NrConjugacyClasses( tbl1 );
    ncc2:= NrConjugacyClasses( tbl2 );

    # Make the ordinary and Brauer table of the product.
    ord:= CharacterTableDirectProduct( OrdinaryCharacterTable( tbl1 ),
                                       OrdinaryCharacterTable( tbl2 ) );
    reg:= CharacterTableRegular( ord, UnderlyingCharacteristic( tbl1 ) );

    # Store the irreducibles.
    SetIrr( reg, List(
       KroneckerProduct( List( Irr( tbl1 ), ValuesOfClassFunction ),
                         List( Irr( tbl2 ), ValuesOfClassFunction ) ),
       vals -> CharacterByValues( reg, vals ) ) );

    # Store projections and embeddings
    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= i; od;
    od;
    StoreFusion( reg, tbl1, fus );

    fus:= [];
    for i in [ 1 .. ncc1 ] do
      for j in [ 1 .. ncc2 ] do fus[ ( i - 1 ) * ncc2 + j ]:= j; od;
    od;
    StoreFusion( reg, tbl2, fus );

    StoreFusion( tbl1, reg, [ 1, ncc2+1 .. (ncc1-1)*ncc2+1 ], "1" );
    StoreFusion( tbl2, reg, [ 1 .. ncc2 ], "2" );

    # Return the table.
    return reg;
    end );


#############################################################################
##
#M  \*( <tbl1>, <tbl2> )  . . . . . . . . . . . . .  direct product of tables
##
InstallOtherMethod( \*,
    "method for two nearly character tables",
    true,
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ], 0,
    CharacterTableDirectProduct );


#############################################################################
##
#M  CharacterTableFactorGroup( <tbl>, <classes> )
##
InstallMethod( CharacterTableFactorGroup,
    "method for an ordinary table, and a list of class positions",
    true,
    [ IsOrdinaryTable, IsList and IsCyclotomicsCollection ], 0,
    function( tbl, classes )

    local F,              # table of the factor group, result
          N,              # classes of the normal subgroup
          chi,            # loop over irreducibles
          ker,            # kernel of a 'chi'
          size,           # size of 'tbl'
          tclasses,       # class lengths of 'tbl'
          suborder,       # order of the normal subgroup
          factirr,        # irreducibles of 'F'
          factorfusion,   # fusion from 'tbl' to 'F'
          nccf,           # no. of classes of 'F'
          cents,          # centralizer orders of 'F'
          i,              # loop over the classes
          inverse,        # inverse of 'factorfusion'
          p;              # loop over prime divisors

    factirr:= [];
    N:= [ 1 .. NrConjugacyClasses( tbl ) ];
    for chi in Irr( tbl ) do
      ker:= KernelChar( chi );
      if IsEmpty( Difference( classes, ker ) ) then
        IntersectSet( N, ker );
        Add( factirr, ValuesOfClassFunction( chi ) );
      fi;
    od;

    # Compute the order of 'N'.
    size:= Size( tbl );
    tclasses:= SizesConjugacyClasses( tbl );
    suborder:= Sum( tclasses{ N } );
    if size mod suborder <> 0 then
      Error( "intersection of kernels of irreducibles containing\n",
             "<classes> has an order not dividing the size of <tbl>" );
    fi;

    # Compute the irreducibles of the factor.
    factirr:= CollapsedMat( factirr, [] );
    factorfusion := factirr.fusion;
    factirr      := factirr.mat;

    # Compute the centralizer orders of the factor group.
    # \[ |C_{G/N}(gN)\| = \frac{|G|/|N|}{|Cl_{G/N}(gN)|}
    #    = \frac{|G|:|N|}{\frac{1}{|N|}\sum_{x fus gN} |Cl_G(x)|}
    #    = \frac{|G|}{\sum_{x fus gN} |Cl_G(x)| \]
    nccf:= Length( factirr[1] );
    cents:= [];
    for i in [ 1 .. nccf ] do
      cents[i]:= 0;
    od;
    for i in [ 1 .. Length( factorfusion ) ] do
      cents[ factorfusion[i] ]:= cents[ factorfusion[i] ] + tclasses[i];
    od;
    for i in [ 1 .. nccf ] do
      cents[i]:= size / cents[i];
    od;
    if not ForAll( cents, IsInt ) then
      Error( "not all centralizer orders of the factor are well-defined" );
    fi;

    F:= Concatenation( Identifier( tbl ), "/", String( N ) );
    ConvertToStringRep( F );
    F:= rec(
             underlyingCharacteristic := 0,
             size                     := size / suborder,
             identifier               := F,
             sizesCentralizers        := cents
            );

    # Transfer necessary power maps of 'tbl' to 'F'.
    inverse:= ProjectionMap( factorfusion );
    F.computedPowerMaps:= [];
    for p in Set( Factors( F.size ) ) do
      F.computedPowerMaps[p]:= factorfusion{ PowerMap( tbl, p ){ inverse } };
    od;

    # Convert the record into a library table.
    ConvertToLibraryCharacterTableNC( F );

    # Store the irreducibles.
    SetIrr( F, List( factirr, vals -> CharacterByValues( F, vals ) ) );

    # Store the factor fusion on 'tbl'.
    StoreFusion( tbl, F, rec( map:= factorfusion, type:= "factor" ) );

    # Return the result.
    return F;
    end );


#############################################################################
##
#M  \/( <tbl>, <list> )  . . . . . . . . .  character table of a factor group
##
InstallOtherMethod( \/,
    "method for character table and list of class positions",
    true,
    [ IsNearlyCharacterTable, IsList and IsCyclotomicsCollection ], 0,
    CharacterTableFactorGroup );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl> ) . . . . . . . . for an ordinary table
##
InstallMethod( CharacterTableIsoclinic,
    "method for an ordinary character table",
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )
    local classes, half, kernel;
    classes:= SizesConjugacyClasses( tbl );
    half:= Size( tbl ) / 2;
    kernel:= Filtered( Irr( tbl ),
                 chi ->     DegreeOfCharacter( chi ) = 1
                        and Sum( classes{ KernelChar( chi ) } ) = half );
    if IsEmpty( kernel ) or 1 < Length( kernel ) then
      Error( "normal subgroup of index 2 not uniquely determined,\n",
             "use CharTableIsoclinic( <tbl>, <classes_of_nsg> )" );
    fi;
    return CharacterTableIsoclinic( tbl, kernel[1] );
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <ordtbl>, <nsg> )  . . . . for an ordinary table
##
InstallOtherMethod( CharacterTableIsoclinic,
    "method for an ordinary character table, and a list of classes",
    true,
    [ IsOrdinaryTable, IsList and IsCyclotomicsCollection ], 0,
    function( tbl, nsg )
    local centralizers,    # attribute of 'tbl'
          classes,         # attribute of 'tbl'
          orders,          # attribute of 'tbl'
          size,            # attribute of 'tbl'
          i,               # 'E(4)'
          j,               # loop variable
          chi,             # one character
          values,          # values of 'chi'
          class,
          map,
          linear,          # linear characters of 'tbl'
          isoclinic,       # the isoclinic table, result
          center,          # nontrivial class(es) contained in the center
          outer,           # classes outside the index 2 subgroup
          nonfaith,        # characters of the factor group modulo 'center'
          irreds,          # characters of 'isoclinic'
          images,
          factorfusion,    # fusion onto factor modulo the central inv.
          p,               # loop over prime divisors of the size of 'tbl'
          reg;             # restriction to regular classes

    centralizers:= SizesCentralizers( tbl );
    classes:= SizesConjugacyClasses( tbl );
    orders:= ShallowCopy( OrdersClassRepresentatives( tbl ) );
    size:= Size( tbl );

    # Check 'nsg'.
    if Sum( classes{ nsg } ) <> size / 2 then
      Error( "normal subgroup described by <nsg> must have index 2" );
    fi;

    # Get the central subgroup of order 2 lying in the above normal subgroup.
    center:= Filtered( nsg, x -> classes[x] = 1 and orders[x] = 2 );
    if Length( center ) <> 1 then
      Error( "central subgroup of order 2 must be unique" );
    fi;
    center:= center[1];

    # Make the isoclinic table.
    isoclinic:= Concatenation( "Isoclinic(", Identifier( tbl ), ")" );
    ConvertToStringRep( isoclinic );

    isoclinic:= rec(
        underlyingCharacteristic   := 0,
        identifier                 := isoclinic,
        size                       := size,
        sizesCentralizers          := centralizers,
        sizesConjugacyClasses      := classes,
        ordersClassRepresentatives := orders,
        computedPowerMaps          := []             );

    # classes outside the normal subgroup
    outer:= Difference( [ 1 .. Length( classes ) ], nsg );

    # Adjust faithful characters in outer classes.
    nonfaith:= [];
    irreds:= [];
    i:= E(4);
    for chi in Irr( tbl ) do
      values:= ValuesOfClassFunction( chi );
      if values[ center ] = values[1] then
        Add( nonfaith, values );
      else
        values:= ShallowCopy( values );
        for class in outer do
          values[ class ]:= i * values[ class ];
        od;
      fi;
      Add( irreds, values );
    od;
    isoclinic.irr:= irreds;

    # Get the fusion map onto the factor group modulo '[ 1, center ]'.
    factorfusion:= CollapsedMat( nonfaith, [] ).fusion;

    # Adjust the power maps.
    for p in Set( Factors( isoclinic.size ) ) do

      map:= PowerMap( tbl, p );

      # For p mod 4 in $\{ 0, 1 \}$, the map remains unchanged,
      # since $g^p = h$ and $(gi)^p = hi^p = hi$ then.
      if p mod 4 = 2 then

        # The squares lie in 'nsg'; for $g^2 = h$,
        # we have $(gi)^2 = hz$, so we must take the other
        # preimage under the factorfusion, if exists.
        map:= ShallowCopy( map );
        for class in outer do
          images:= Filtered( Difference( nsg, [ map[class] ] ),
              x -> factorfusion[x] = factorfusion[ map[ class ] ] );
          if Length( images ) = 1 then
            map[ class ]:= images[1];
            orders[ class ]:= 2 * orders[ images[1] ];
          fi;
        od;

      elif p mod 4 = 3 then
  
        # For $g^p = h$, we have $(gi)^p = hi^p = hiz$, so again
        # we must choose the other preimage under the
        # factorfusion, if exists; the 'p'-th powers lie outside
        # 'nsg' in this case.
        map:= ShallowCopy( map );
        for class in outer do
          images:= Filtered( Difference( outer, [ map[ class ] ] ),
              x -> factorfusion[x] = factorfusion[ map[ class ] ] );
          if Length( images ) = 1 then
            map[ class ]:= images[1];
          fi;
        od;

      fi;

      isoclinic.computedPowerMaps[p]:= map;

    od;

    # Convert the record into a library table.
    ConvertToLibraryCharacterTableNC( isoclinic );

    # Return the result.
    return isoclinic;
    end );


#############################################################################
##
#M  CharacterTableIsoclinic( <modtbl> ) . . . . . . . . .  for a Brauer table
##
##  For the isoclinic table of a Brauer table,
##  we transfer the normal subgroup information to the regular classes,
##  and adjust the irreducibles.
##
InstallMethod( CharacterTableIsoclinic,
    "method for a Brauer table",
    true,
    [ IsBrauerTable ], 0,
    function( tbl )

    local isoclinic,
          reg,
          factorfusion,
          center,
          outer,
          irreducibles,
          i,
          chi,
          values,
          class;

    isoclinic:= CharacterTableIsoclinic( OrdinaryCharacterTable( tbl ) );
    reg:= CharacterTableRegular( isoclinic, Characteristic( tbl ) );
    factorfusion:= GetFusionMap( reg, isoclinic );
    center:= Position( factorfusion, center );
    outer:= Filtered( [ 1 .. NrConjugacyClasses( reg ) ],
                      x -> factorfusion[x] in outer );

    # Compute the irreducibles as for the ordinary isoclinic table.
    irreducibles:= [];
    i:= E(4);
    for chi in Irr( tbl ) do
      values:= ValuesOfClassFunction( chi );
      if values[ center ] <> values[1] then
        values:= ShallowCopy( values );
        for class in outer do
          values[ class ]:= i * values[ class ];
        od;
      fi;
      Add( irreducibles, values );
    od;
    SetIrr( reg, List( irreducibles,
                       vals -> CharacterByValues( reg, vals ) ) );

    # Return the result.
    return reg;
    end );


#############################################################################
##
#F  CharacterTableQuaternionic( <4n> )
##
CharacterTableQuaternionic := function( 4n )

    local quaternionic;

    if 4n mod 4 <> 0 then
      Error( "argument must be a multiple of 4" );
    elif 4n = 4 then
      quaternionic:= CharacterTable( "Cyclic", 4 );
    else
      quaternionic:= CharacterTableIsoclinic(
                         CharacterTable( "Dihedral", 4n ),
                         [ 1 .. 4n / 4 + 1 ] );
    fi;
    SetIdentifier( quaternionic, Concatenation( "Q", String( 4n ) ) );
#T not allowed ...
    return quaternionic;
end;


#############################################################################
##
#M  CharacterTableRegular( <ordtbl>, <p> )  . restriction to <p>-reg. classes
##
InstallMethod( CharacterTableRegular,
    "method for an ordinary character table, and a positive integer",
    true,
    [ IsNearlyCharacterTable, IsInt and IsPosRat ], 0,
    function( ordtbl, prime )

    local fusion,
          inverse,
          orders,
          i,
          regular,
          power;

    if not IsPrimeInt( prime ) then
      Error( "<prime> must be a prime" );
    elif IsBrauerTable( ordtbl ) then
      Error( "<ordtbl> is already a Brauer table" );
    fi;

    fusion:= [];
    inverse:= [];
    orders:= OrdersClassRepresentatives( ordtbl );
    for i in [ 1 .. Length( orders ) ] do
      if orders[i] mod prime <> 0 then
        Add( fusion, i );
        inverse[i]:= Length( fusion );
      fi;
    od;

    regular:= rec(
       identifier                 := Concatenation( Identifier( ordtbl ),
                                         "mod", String( prime ) ),
       underlyingCharacteristic   := prime,
       size                       := Size( ordtbl ),
       ordersClassRepresentatives := orders{ fusion },
       sizesCentralizers          := SizesCentralizers( ordtbl ){ fusion },
       computedPowerMaps          := [],
       ordinaryCharacterTable     := ordtbl
      );

    power:= ComputedPowerMaps( ordtbl );
    for i in [ 1 .. Length( power ) ] do
      if IsBound( power[i] ) then
        regular.computedPowerMaps[i]:= inverse{ power[i]{ fusion } };
      fi;
    od;
    
    regular:= ConvertToBrauerTableNC( regular );
    StoreFusion( regular, ordtbl, rec( map:= fusion, type:= "choice" ) );

    return regular;
    end );


#############################################################################
##
#M  CharacterTableSpecialized( <tbl>, <q> )
##

#T missing!


#############################################################################
##
#F  PossibleClassFusions( <subtbl>, <tbl> )
#F  PossibleClassFusions( <subtbl>, <tbl>, <options> )
##

#T missing!


#############################################################################
##
#F  PossiblePowerMaps( <tbl>, <p> )
#F  PossiblePowerMaps( <tbl>, <p>, <options> )
##

#T missing!


#############################################################################
##
#M  PrintObj( <tbl> ) . . . . . . . . . . . . . . . . print a character table
##
InstallMethod( PrintObj,
    true,
    [ IsOrdinaryTable ], 0,
    function( tbl )
    if HasUnderlyingGroup( tbl ) then
      Print( "CharacterTable( ", UnderlyingGroup( tbl ), " )" );
    else
      Print( "CharacterTable( \"", Identifier( tbl ), "\" )" );
    fi;
    end );

InstallMethod( PrintObj,
    true,
    [ IsBrauerTable ], 0,
    function( tbl )
    if HasUnderlyingGroup( tbl ) then
      Print( "BrauerTable( ", UnderlyingGroup( tbl ), ", ",
             UnderlyingCharacteristic( tbl ), " )" );
    else
      Print( "BrauerTable( \"", Identifier( OrdinaryCharacterTable( tbl ) ),
             "\", ", UnderlyingCharacteristic( tbl ), " )" );
    fi;
    end );


#############################################################################
##
#M  AutomorphismsOfTable( <tbl> ) . . . . . . . . . . . for a character table
##
InstallMethod( AutomorphismsOfTable,
    "method for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> TableAutomorphisms( tbl, Irr( tbl ) ) );


#############################################################################
##
#M  Indicator( <tbl>, <n> )
#M  Indicator( <tbl>, <characters>, <n> )
#M  Indicator( <modtbl>, 2 )
##
InstallMethod( Indicator,
    "method for an ordinary character table and a positive integer",
    true,
    [ IsOrdinaryTable, IsInt and IsPosRat ], 0,
    function( tbl, n )

    local indicator,
          irredinfo,
          i;

    # Compute the indicator.
    indicator:= Indicator( tbl, Irr( tbl ), n );

    # Write the indicator to the table.
    irredinfo:= IrredInfo( tbl );
    for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
      irredinfo[i].indicator[n]:= indicator[i];
    od;
    Info( InfoCharacterTable, 2,
          "Indicator: ", Ordinal( n ), " indicator written to the table" );

    # Return the indicator.
    return indicator;
    end );

InstallOtherMethod( Indicator,
    "method for an ord. character table, a hom. list, and a pos. integer",
    true,
    [ IsOrdinaryTable, IsHomogeneousList, IsInt and IsPosRat ], 0,
    function( tbl, characters, n )

    local principal, map;

    principal:= List( [ 1 .. NrConjugacyClasses( tbl ) ], x -> 1 );
    map:= PowerMap( tbl, n );
    return List( characters,
                 chi -> ScalarProduct( tbl, chi{ map }, principal ) );
    end );

InstallMethod( Indicator,
    "method for a Brauer character table and <n> = 2",
    true,
    [ IsBrauerTable, IsInt and IsPosRat ], 0,
    function( modtbl, n )

    local ordtbl,
          irr,
          ibr,
          ordindicator,
          fus,
          indicator,
          i,
          j,
          odd;

    if n <> 2 then
      Error( "for Brauer table <modtbl> only for <n> = 2" );
    elif Characteristic( modtbl ) = 2 then
      Error( "for Brauer table <modtbl> only in odd characteristic" );
    fi;

    ordtbl:= OrdinaryCharacterTable( modtbl );
    irr:= Irr( ordtbl );
    ibr:= Irr( modtbl );
    ordindicator:= Indicator( ordtbl, irr, 2 );
    fus:= GetFusionMap( modtbl, ordtbl );

    # compute indicators block by block
    indicator:= [];

    for i in BlocksInfo( modtbl ) do
      if not IsBound( i.decmat ) then
        i.decmat:= Decomposition( ibr{ i.modchars },
                         List( irr{ i.ordchars },
                               x -> x{ fus } ), "nonnegative" );
      fi;
      for j in [ 1 .. Length( i.modchars ) ] do
        if ForAny( ibr[ i.modchars[j] ],
                   x -> not IsInt(x) and GaloisCyc(x,-1) <> x ) then

          # indicator of a Brauer character is 0 iff it has
          # at least one nonreal value
          indicator[ i.modchars[j] ]:= 0;

        else

          # indicator is equal to the indicator of any real ordinary
          # character containing it as constituent, with odd multiplicity
          odd:= Filtered( [ 1 .. Length( i.decmat ) ],
                          x -> i.decmat[x][j] mod 2 <> 0 );
          odd:= List( odd, x -> ordindicator[ i.ordchars[x] ] );
          indicator[ i.modchars[j] ]:= First( odd, x -> x <> 0 );

        fi;
      od;
    od;

    return indicator;
    end );


#############################################################################
##
#M  InducedCyclic( <tbl> )
#M  InducedCyclic( <tbl>, \"all\" )
#M  InducedCyclic( <tbl>, <classes> )
#M  InducedCyclic( <tbl>, <classes>, \"all\" )
##
InstallMethod( InducedCyclic,
    "method for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl ->InducedCyclic( tbl, [ 1 .. NrConjugacyClasses( tbl ) ] ) );

InstallOtherMethod( InducedCyclic,
    "method for a character table and a string",
    true,
    [ IsCharacterTable, IsString ], 0,
    function( tbl, all )
    return InducedCyclic( tbl, [ 1 .. NrConjugacyClasses( tbl ) ], all );
    end );

InstallOtherMethod( InducedCyclic,
    "method for a character table and a hom. list",
    true,
    [ IsCharacterTable, IsHomogeneousList ], 0,
    function( tbl, classes )

    local centralizers,
          orders,
          independent,
          inducedcyclic,
          i,
          fusion,
          j,
          single;

    centralizers:= SizesCentralizers( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    independent:= List( orders, x -> true );
    inducedcyclic:= [];
    for i in classes do                         # induce from i-th class
      if independent[i] then
        fusion:= [ i ];
        for j in [ 2 .. orders[i] ] do
          fusion[j]:= PowerMap( tbl, j, i );    # j-th powermap at class i
        od;
        single:= List( [ 1 .. Length( orders ) ], x -> 0 );
        for j in fusion do
          if orders[j] = orders[i] then
            # position is Galois conjugate to 'i'
            independent[j]:= false;
          fi;
          single[j]:= single[j] + 1;
        od;
        for j in [ 1 .. Length( orders ) ] do
          single[j]:= single[j] * centralizers[j] / orders[i];
          if not IsInt( single[j] ) then
            single[j]:= Unknown();
            Info( InfoCharacterTable, 1,
                  "InducedCyclic: subgroup order not dividing sum",
                  " (induce from class ", i, ")" );
          fi;
        od;
        AddSet( inducedcyclic, single );
      fi;
    od;
    return inducedcyclic;
    end );

InstallOtherMethod( InducedCyclic,
    "method for a character table, a hom. list, and a string",
    true,
    [ IsCharacterTable, IsHomogeneousList, IsString ], 0,
    function( tbl, classes, all )

    local centralizers,
          orders,
          independent,
          inducedcyclic,
          i,
          fusion,
          j,
          k,
          single;

    if all <> "all" then
      Error( "<all> must be the string \"all\"" );
    fi;

    centralizers:= SizesCentralizers( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    independent:= List( orders, x -> true );
    inducedcyclic:= [];
    for i in classes do                         # induce from i-th class
      if independent[i] then
        fusion:= [ i ];
        for j in [ 2 .. orders[i] ] do
          fusion[j]:= PowerMap( tbl, j, i );    # j-th powermap at class i
        od;

        for k in [ 0 .. orders[i] - 1 ] do      # induce k-th character
          single:= orders * 0;
          single[i]:= E( orders[i] ) ^ ( k );
          for j in [ 2 .. orders[i] ] do
            if orders[ fusion[j] ] = orders[i] then

              # position is Galois conjugate
              independent[ fusion[j] ]:= false;
            fi;
            single[ fusion[j] ]:=
                single[ fusion[j] ] + E( orders[i] )^( k*j mod orders[i] );
          od;
          for j in [ 1 .. Length( orders ) ] do
            single[j]:= single[j] * tbl.centralizers[j] / orders[i];
            if not IsCycInt( single[j] ) then
              single[j]:= Unknown();
              Info( InfoCharacterTable, 1,
                    "InducedCyclic: subgroup order not dividing sum",
                    " (induce from class ", i, ")" );
            fi;
          od;
          AddSet( inducedcyclic, single );
        od;
      fi;
    od;
    return inducedcyclic;
    end );
#T missing: methods for 'IsCharacterTableInProgress'!!
#T (and for Brauer tables)


#############################################################################
##
#F  GetFusionMap( <source>, <destin> )
#F  GetFusionMap( <source>, <destin>, <specification> )
##
GetFusionMap := function( arg )

    local source,
          destin,
          specification,
          name,
          fus,
          ordsource,
          orddestin;

    # Check the arguments.
    if not ( 2 <= Length( arg ) and IsNearlyCharacterTable( arg[1] )
                                and IsNearlyCharacterTable( arg[2] ) ) then
      Error( "first two arguments must be nearly character tables" );
    elif 3 < Length( arg ) then
      Error( "usage: GetFusionMap( <source>, <destin>[, <specification>" );
    fi;

    source := arg[1];
    destin := arg[2];

    if Length( arg ) = 3 then
      specification:= arg[3];
    fi;

    # First check whether 'source' knows a fusion to 'destin' .
    name:= Identifier( destin );
    for fus in ComputedClassFusions( source ) do
      if fus.name = name then
        if IsBound( specification ) then
          if     IsBound( fus.specification )
             and fus.specification = specification then
            if HasClassPermutation( destin ) then
              return OnTuples( fus.map, ClassPermutation( destin ) );
            else
              return ShallowCopy( fus.map );
            fi;
          fi;
        else
          if IsBound( fus.specification ) then
            Print( "#I GetFusionMap: Used fusion has specification ",
                   fus.specification, "\n");
          fi;
          if HasClassPermutation( destin ) then
            return OnTuples( fus.map, ClassPermutation( destin ) );
          else
            return ShallowCopy( fus.map );
          fi;
        fi;
      fi;
    od;

    # Now check whether the tables are Brauer tables
    # whose ordinary tables know more.
    # (If 'destin' is the ordinary table of 'source' then
    # the fusion has been found already.)
    # Note that 'specification' makes no sense here.
    if IsBrauerTable( source ) and IsBrauerTable( destin ) then
      ordsource:= OrdinaryCharacterTable( source );
      orddestin:= OrdinaryCharacterTable( destin );
      fus:= GetFusionMap( ordsource, orddestin );
      if fus <> fail then
        fus:= InverseMap( GetFusionMap( destin, orddestin ) ){ fus{
                              GetFusionMap( source, ordsource ) } };
        StoreFusion( source, fus, destin );
        return fus;
      fi;
    fi;

    # No fusion map was found.
    return fail;
end;


#############################################################################
##
#F  StoreFusion( <source>, <fusion>, <destination> )
#F  StoreFusion( <source>, <fusionmap>, <destination> )
##
StoreFusion := function( source, fusion, destination )

    local fus;

    # (compatibility with {\GAP}-3)
    if IsList( destination ) or IsRecord( destination ) then
      StoreFusion( source, destination, fusion );
      return;
    fi;

    # Check the arguments.
    if not ( IsList(fusion) or ( IsRecord(fusion) and IsBound(fusion.map) ) )
       then
      Error( "<fusion> must be a list or a record containing at least",
             " <fusion>.map" );
    elif   IsRecord( fusion ) and IsBound( fusion.name )
       and fusion.name <> Identifier( destination ) then
      Error( "identifier of <destination> must be equal to <fusion>.name" );
    fi;

    if IsList( fusion ) then
      fusion:= rec( name:= Identifier( destination ),
                    map:= ShallowCopy( fusion ) );
    else
      fusion:= ShallowCopy( fusion );
      fusion.name:= Identifier( destination );
    fi;

    if HasClassPermutation( destination ) then
      fusion.map:= OnTuples( fusion.map,
                             Inverse( ClassPermutation( destination ) ) );
    fi;

    for fus in ComputedClassFusions( source ) do
      if fus.name = fusion.name then

        if fus.map <> fusion.map
           and ( not IsBound(fusion.specification)
             or ( IsBound( fus.specification )
                  and fusion.specification = fus.specification ) ) then

          # fusion to same destination, with different map,
          # not specified
          Error( "fusion to <destination> already stored on <source>;\n",
             " to store another one, assign different specifications",
             " to both fusions" );

        else

          return;

        fi;

      fi;
    od;

    # The fusion is new, simply add it.
    Add( ComputedClassFusions( source ), fusion );
    Add( NamesOfFusionSources( destination ), Identifier( source ) );
end;


#############################################################################
##
#F  FusionConjugacyClasses( <tbl1>, <tbl2> )  . . . . .  for character tables
#F  FusionConjugacyClasses( <H>, <G> )  . . . . . . . . . . . . .  for groups
##
##  We do not store class fusions in groups, the groups delegates to their
##  ordinary character tables.
##
FusionConjugacyClasses := function( tbl1, tbl2 )

    local fus;

    # Groups delegate to their ordinary tables.
    if IsGroup( tbl1 ) and IsGroup( tbl2 ) then
      tbl1:= OrdinaryCharacterTable( tbl1 );
      tbl2:= OrdinaryCharacterTable( tbl2 );
    fi;

    if     IsNearlyCharacterTable( tbl1 )
       and IsNearlyCharacterTable( tbl1 ) then

      # Check whether the fusion map is stored already.
      fus:= GetFusionMap( tbl1, tbl2 );

      # If not then call the operation.
      if fus = fail then
        fus:= FusionConjugacyClassesOp( tbl1, tbl2 );
        if fus <> fail then
          StoreFusion( tbl1, fus, tbl2 );
        fi;
      fi;
      return fus;

    else
      Error( "<tbl1> and <tbl2> must be nearly character tables" );
    fi;
end;


#############################################################################
##
#M  FusionConjugacyClassesOp( tbl1, tbl2 )
##
InstallMethod( FusionConjugacyClassesOp,
    "method for two ordinary tables with groups",
    IsIdentical,
    [ IsOrdinaryTable and HasUnderlyingGroup,
      IsOrdinaryTable and HasUnderlyingGroup ], 0,
    function( tbl1, tbl2 )
    Error( "not yet implemented!" );
#T !!!
    end );

InstallMethod( FusionConjugacyClassesOp,
    "method for two ordinary tables",
    IsIdentical,
    [ IsOrdinaryTable, IsOrdinaryTable ], 0,
    function( tbl1, tbl2 )

    local fusion;

    if   Size( tbl2 ) < Size( tbl1 ) then

      Error( "cannot compute factor fusion from tables" );

    elif Size( tbl2 ) = Size( tbl1 ) then

      # find a transforming permutation
      fusion:= TransformingPermutationsCharacterTables( tbl1, tbl2 );
      if   fusion = fail then
        return fail;
      elif 1 < Size( fusion.group ) then
        Error( "fusion is not unique" );
      fi;
      if fusion.columns = () then
        fusion:= [];
      else
        fusion:= OnTuples( [ 1 .. LargestMovedPointPerm( fusion.columns ) ],
                           fusion.columns );
      fi;

      Append( fusion,
              [ Length( fusion ) + 1 .. NrConjugacyClasses( tbl1 ) ] );

    else

      # find a subgroup fusion
      fusion:= PossibleClassFusions( tbl1, tbl2 );
      if   fusion = [] then
#T ?
        return fail;
      elif 1 < Length( fusion ) then
        Error( "fusion is not unique" );
      fi;
      fusion:= fusion[1];

    fi;

    return fusion;
    end );

InstallMethod( FusionConjugacyClassesOp,
    "method for two Brauer tables",
    IsIdentical,
    [ IsBrauerTable, IsBrauerTable ], 0,
    function( tbl1, tbl2 )
    local fus, ord1, ord2;

    ord1:= OrdinaryCharacterTable( tbl1 );
    ord2:= OrdinaryCharacterTable( tbl2 );
    fus:= PossibleClassFusions( ord1, ord2 );
    if fus = [] or fus = fail then
#T can 'fail' happen?
      return fail;
    else

      fus:= Set( List( fus, map -> InverseMap( GetFusionMap( tbl2, ord2 ) ){
                                    map{ GetFusionMap( tbl1, ord1 ) } } ) );
      if 1 < Length( fus ) then
        Error( "fusion is not uniquely determined" );
      fi;
      return fus[1];

    fi;
    end );


#############################################################################
##
#M  Display( <tbl> )  . . . . . . . . . . . . .  for a nearly character table
#M  Display( <tbl>, <record> )
##
InstallMethod( Display,
    "method for a nearly character table",
    true,
    [ IsNearlyCharacterTable ], 0,
    function( tbl )
    Display( tbl, rec() );
    end );

InstallMethod( Display,
    "method for a nearly character table with display options",
    true,
    [ IsNearlyCharacterTable and HasDisplayOptions ], 0,
    function( tbl )
    Display( tbl, DisplayOptions( tbl ) );
    end );

InstallOtherMethod( Display,
    "method for a nearly character table and a list",
    true,
    [ IsNearlyCharacterTable, IsList ], 0,
    function( tbl, list )
    Display( tbl, rec( chars:= list ) );
    end );

InstallOtherMethod( Display,
    "method for a nearly character table and a record",
    true,
    [ IsNearlyCharacterTable, IsRecord ], 0,
    function( tbl, options )

    local i, j,              # loop variables
          chars,             # list of characters
          cnr,               # list of character numbers
          cletter,           # character name
          classes,           # list of classes
          powermap,          # list of primes
          centralizers,      # boolean
          cen,               # factorized centralizers
          fak,               # factorization
          prime,             # loop over primes
          primes,            # prime factors of order
          prin,              # column widths
          nam,               # classnames
          col,               # number of columns already printed
          acol,              # nuber of columns on next page
          len,               # width of next page
          ncols,             # total number of columns
          linelen,           # line length
          q,                 # quadratic cyc / powermap entry
          indicator,         # list of primes
          indic,             # indicators
          iw,                # width of indicator column
          letters,           # the alphabet
          ll,                # cardinality of the alphabet
          irrstack,          # list of known cycs
          irrnames,          # list of names for cycs
          colWidth,          # local function
          irrName,           # local function
          stringEntry,       # local function
          cc,                # column number
          charnames,         # list of character names
          charvals,          # matrix of strings of character values
          tbl_powermap,
          tbl_centralizers,
          tbl_irredinfo;

    # compute the width of column 'col'
    colWidth:= function( col )
       local len, width;

       # the class name should fit into the column
       width:= Length( nam[col] );

       # the class names of power classes should fit into the column
       for i in powermap do
         len:= tbl_powermap[i][ col ];
         if IsInt( len ) then
           len:= Length( nam[ len ] );
           if len > width then
             width:= len;
           fi;
         fi;
       od;

       # each character value should fit into the column
       for i in [ 1 .. Length( cnr ) ] do
         len:= Length( charvals[i][ col ] );
         if len > width then
           width:= len;
         fi;
       od;

       # at least one blank should separate the column entries
       return width + 1;

    end;

    # names of irrationalities
    irrName:= function( n )
       local i, name;

       name:= "";
       while 0 < n do
          name:= Concatenation(letters[(n-1) mod ll + 1], name);
          n:= QuoInt(n-1, ll);
       od;
       return name;
    end;

    # function (in one variable) to display a single entry
    if   IsBound( options.StringEntry ) then
      stringEntry:= options.StringEntry;
    else

      # string function as known
      stringEntry:= function( entry )
         local i, val;

         if entry = 0 then
            return ".";
         elif IsCyc( entry ) and not IsInt( entry ) then
            # find shorthand for cyclo
            for i in [ 1 .. Length(irrstack) ] do
               if entry = irrstack[i] then
                  return irrName(i);
               elif entry = -irrstack[i] then
                  return Concatenation("-", irrName(i));
               fi;
               val:= GaloisCyc(irrstack[i], -1);
               if entry = val then
                  return Concatenation("/", irrName(i));
               elif entry = -val then
                  return Concatenation("-/", irrName(i));
               fi;
               val:= StarCyc(irrstack[i]);
               if entry = val then
                  return Concatenation("*", irrName(i));
               elif -entry = val then
                  return Concatenation("-*", irrName(i));
               fi;
               i:= i+1;
            od;
            Add( irrstack, entry );
            Add( irrnames, irrName( Length( irrstack ) ) );
            return irrnames[ Length( irrnames ) ];

         elif ( IsList( entry ) and not IsString( entry ) )
              or IsUnknown( entry ) then
            return "?";
         else
            return String( entry );
         fi;
      end;

    fi;

    irrstack:= [];
    irrnames:= [];
    letters:= [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
                "N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ];
    ll:= Length( letters );

    # default:
    # options
    cletter:= "X";

    # choice of characters
    if IsBound( options.chars ) then
       if IsCyclotomicsCollection( options.chars ) then
          cnr:= options.chars;
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsInt( options.chars ) then
          cnr:= [ options.chars ];
          chars:= List( Irr( tbl ){ cnr }, ValuesOfClassFunction );
       elif IsHomogeneousList( options.chars ) then
          chars:= options.chars;
          cletter:= "Y";
          cnr:= [ 1 .. Length( chars ) ];
       else
          chars:= [];
       fi;
    elif HasIrr( tbl ) then
      chars:= List( Irr( tbl ), ValuesOfClassFunction );
      cnr:= [ 1 .. Length( chars ) ];
    else
      chars:= [];
    fi;

    if IsBound( options.letter ) and options.letter in letters then
       cletter:= options.letter;
    fi;

    # choice of classes
    if IsBound( options.classes ) then
      if IsInt( options.classes ) then
        classes:= [ options.classes ];
      else
        classes:= options.classes;
      fi;
    else
      classes:= [ 1 .. NrConjugacyClasses( tbl ) ];
    fi;

    # choice of power maps
    tbl_powermap:= ComputedPowerMaps( tbl );
    powermap:= Filtered( [ 1 .. Length( tbl_powermap ) ],
                         x -> IsBound( tbl_powermap[x] ) );
    if IsBound( options.powermap ) then
       if IsInt( options.powermap ) then
          IntersectSet( powermap, [ options.powermap ] );
       elif IsList( options.powermap ) then
          IntersectSet( powermap, options.powermap );
       elif options.powermap = false then
          powermap:= [];
       fi;
    fi;

    # print factorized centralizer orders?
    centralizers:=    not IsBound( options.centralizers )
                   or options.centralizers;

    # print Frobenius-Schur indicators?
    indicator:= [];
    if     IsBound( options.indicator )
       and not ( IsBound( options.chars ) and IsMatrix( options.chars ) ) then
       if options.indicator = true then
          indicator:= [2];
       elif IsRowVector( options.indicator ) then
          indicator:= Set( Filtered( options.indicator, IsInt and IsPosRat ) );
       fi;
    fi;

    # (end of options handling)

    # line length
    linelen:= SizeScreen()[1] - 1;

    # A character table has a name.
    Print( Identifier( tbl ), "\n\n" );

    # prepare centralizers
    if centralizers then
       fak:= FactorsInt( Size( tbl ) );
       primes:= Set( fak );
       cen:= [];
       for prime in primes do
          cen[prime]:= [ Number( fak, x -> x = prime ) ];
       od;
    fi;

    # prepare classnames
    nam:= ClassNames( tbl );

    # prepare character names
    charnames:= [];
    if HasIrredInfo( tbl ) then
      tbl_irredinfo:= IrredInfo( tbl );
    fi;
    if HasIrredInfo( tbl ) and not IsBound( options.chars ) then
      for i in [ 1 .. Length( cnr ) ] do
        if IsBound( tbl_irredinfo[ cnr[i] ].charname ) then
          charnames[i]:= tbl_irredinfo[ cnr[i] ].charname;
        else
          charnames[i]:= Concatenation( cletter, ".", String( cnr[i] ) );
        fi;
      od;
    else
      for i in [ 1 .. Length( cnr ) ] do
        charnames[i]:= Concatenation( cletter, ".", String( cnr[i] ) );
      od;
    fi;

    # prepare indicator
    iw:= [0];
    if indicator <> [] and not HasIrredInfo( tbl ) then
       indicator:= [];
    fi;
    if indicator <> [] then
       indic:= [];
       for i in indicator do
          indic[i]:= [];
          for j in cnr do
             if IsBound( tbl_irredinfo[j] ) and
                IsBound( tbl_irredinfo[j].indicator ) and
                IsBound( tbl_irredinfo[j].indicator[i] ) then
                indic[i][j]:= tbl_irredinfo[j].indicator[i];
             fi;
          od;
          if indic[i] = [] then
             Unbind(indic[i]);
          else
             if i = 2 then
                iw[i]:= 2;
             else
                iw[i]:= Maximum( Length(String(Maximum(Set(indic[i])))),
                                 Length(String(Minimum(Set(indic[i])))),
                                 Length(String(i)) )+1;
             fi;
             iw[1]:= iw[1] + iw[i];
          fi;
       od;
       iw[1]:= iw[1] + 1;
       indicator:= Filtered( indicator, x-> IsBound( indic[x] ) );
    fi;

    if Length( cnr ) = 0 then
      prin:= [ 3 ];
    else
      prin:= [ Maximum( List( charnames, Length ) ) + 3 ];
    fi;

    # prepare list for strings of character values
    charvals:= List( chars, x -> [] );

    # Number Of Columns
    ncols:= Length(classes) + 1;

    # Anzahl bereits gedruckter Spalten
    col:= 1;

    while col < ncols do

       # determine number of cols for next page
       acol:= 0;
       if indicator <> [] then
          prin[1]:= prin[1] + iw[1];
       fi;
       len:= prin[1];
       while col+acol < ncols and len < linelen do
          acol:= acol + 1;
          if Length(prin) < col + acol then
             cc:= classes[ col + acol - 1 ];
             for i in [ 1 .. Length( cnr ) ] do
               charvals[i][ cc ]:= stringEntry( chars[i][ cc ] );
             od;
             prin[col + acol]:= colWidth( classes[col + acol - 1] );
          fi;
          len:= len + prin[col+acol];
       od;
       if len >= linelen then
          acol:= acol-1;
       fi;

       # Check whether we are able to print at least one column.
       if acol = 0 then
         Error( "line length too small (perhaps resize with 'SizeScreen')" );
       fi;

       # centralizers
       if centralizers then
          tbl_centralizers:= SizesCentralizers( tbl );
          for i in [col..col+acol-1] do
             fak:= FactorsInt( tbl_centralizers[classes[i]] );
             for prime in Set( fak ) do
                cen[prime][i]:= Number( fak, x -> x = prime );
             od;
          od;
          for j in [1..Length(cen)] do
             if IsBound(cen[j]) then
                for i in [col..col+acol-1] do
                   if not IsBound(cen[j][i]) then
                      cen[j][i]:= ".";
                   fi;
                od;
             fi;
          od;

          for prime in primes do
             Print( FormattedString( prime, prin[1] ) );
             for j in [1..acol] do
               Print( FormattedString( cen[prime][col+j-1], prin[col+j] ) );
             od;
             Print("\n");
          od;
          Print("\n");
       fi;

       # class names
       Print( FormattedString( "", prin[1] ) );
       for i in [ 1 .. acol ] do
         Print( FormattedString( nam[classes[col+i-1]], prin[col+i] ) );
       od;
       Print("\n");

       # power maps
       if powermap <> [] then
          for i in powermap do
             Print( FormattedString( Concatenation( String(i), "P" ),
                                     prin[1] ) );
             for j in [1..acol] do
                q:= tbl_powermap[i][classes[col+j-1]];
                if IsInt(q) then
                   Print( FormattedString( nam[q], prin[col+j] ) );
                else
                   Print( FormattedString( "?", prin[col+j] ) );
                fi;
             od;
             Print("\n");
          od;
       fi;

       # empty column resp. indicators
       if indicator <> [] then
          prin[1]:= prin[1] - iw[1];
          Print( FormattedString( "", prin[1] ) );
          for i in indicator do
             Print( FormattedString( i, iw[i] ) );
          od;
       fi;
       Print("\n");

       # the characters
       for i in [1..Length(chars)] do

          # character name
          Print( FormattedString( charnames[i], -prin[1] ) );

          # indicators
          for j in indicator do
             if IsBound(indic[j][cnr[i]]) then
                if j = 2 then
                   if indic[j][cnr[i]] = 0 then
                      Print( FormattedString( "o", iw[j] ) );
                   elif indic[j][cnr[i]] = 1 then
                      Print( FormattedString( "+", iw[j] ) );
                   elif indic[j][cnr[i]] = -1 then
                      Print( FormattedString( "-", iw[j] ) );
                   fi;
                else
                   if indic[j][cnr[i]] = 0 then
                      Print( FormattedString( "0", iw[j] ) );
                   else
                      Print( FormattedString( stringEntry(indic[j][cnr[i]]),
                                              iw[j]) );
                   fi;
                fi;
             else
                Print( FormattedString( "", iw[j] ) );
             fi;
          od;
          if indicator <> [] then
            Print(" ");
          fi;
          for j in [ 1 .. acol ] do
            Print( FormattedString( charvals[i][ classes[col+j-1] ],
                                    prin[ col+j ] ) );
          od;
          Print("\n");
       od;
       col:= col + acol;
       Print("\n");
       indicator:= [];
    od;

    # print legend for cyclos
    for i in [1..Length(irrstack)] do
       Print( irrName(i), " = ", irrstack[i], "\n" );
       q:= Quadratic( irrstack[i] );
       if q <> fail then
          Print( "  = ", q.display, " = ", q.ATLAS, "\n");
       fi;
    od;
    end );


#T support Cambridge format!
#T (for that, make the legend printing a separate function,
#T and also the handling of the irrats;
#T probably also the 'stringEntry' default function should become a
#T global variable)


#############################################################################
##
#F  ConvertToOrdinaryTable( <record> )  . . . . create character table object
#F  ConvertToOrdinaryTableNC( <record> )  . . . create character table object
##
ConvertToOrdinaryTableNC := function( record )

    local names,    # list of component names
          i;        # loop over 'SupportedOrdinaryTableInfo'

    names:= RecNames( record );

    # Make the object.
    if IsBound( record.characteristic ) and record.characteristic <> 0 then
      ConvertToBrauerTableNC( record );
    else

      Objectify( NewKind( NearlyCharacterTablesFamily,
                          IsCharacterTable and IsAttributeStoringRep ),
                 record );

      # Enter the properties and attributes.
      for i in [ 1, 3 .. Length( SupportedOrdinaryTableInfo ) - 1 ] do
        if SupportedOrdinaryTableInfo[ i+1 ] in names then
          Setter( SupportedOrdinaryTableInfo[i] )( record,
              record!.( SupportedOrdinaryTableInfo[ i+1 ] ) );
        fi;
      od;
  
      # Make the lists of character values into character objects.
      if "irr" in names then
        SetIrr( record, List( record!.irr,
                              chi -> CharacterByValues( record, chi ) ) );
      fi;

    fi;

    # Return the object.
    return record;
end;

ConvertToOrdinaryTable := function( record )
    Error( "not yet implemented!" );
end;


#############################################################################
##
#F  ConvertToBrauerTable( <record> ) . . . . . . . create Brauer table object
#F  ConvertToBrauerTableNC( <record> ) . . . . . . create Brauer table object
##
ConvertToBrauerTableNC := function( record )

    local names,    # list of component names
          i;        # loop over 'SupportedBrauerTableInfo'

    names:= RecNames( record );

    # Make the object.
    Objectify( NewKind( NearlyCharacterTablesFamily,
                        IsBrauerTable and IsAttributeStoringRep ),
               record );

    # Enter the properties and attributes.
    for i in [ 1, 3 .. Length( SupportedBrauerTableInfo ) - 1 ] do
      if SupportedBrauerTableInfo[ i+1 ] in names then
        Setter( SupportedBrauerTableInfo[i] )( record,
            record!.( SupportedBrauerTableInfo[ i+1 ] ) );
      fi;
    od;

    # Make the lists of character values into character objects.
    if "irr" in names then
      SetIrr( record, List( record!.irr,
                            chi -> CharacterByValues( record, chi ) ) );
    fi;

    # Return the object.
    return record;
end;

ConvertToBrauerTable := function( record )
    Error( "not yet implemented!" );
end;


#############################################################################
##
#F  PrintCharacterTable( <tbl>, <varname> )
##
PrintCharacterTable := function( tbl, varname )

    local i, info, comp;

    # Check the arguments.
    if not IsNearlyCharacterTable( tbl ) then
      Error( "<tbl> must be a nearly character table" );
    elif not IsString( varname ) then
      Error( "<varname> must be a string" );
    fi;

    # Print the preamble.
    Print( varname, ":= function()\n" );
    Print( "local tbl;\n" );
    Print( "tbl:=rec();\n" );

    # Print the supported attributes.
    for i in [ 2, 4 .. Length( SupportedOrdinaryTableInfo ) ] do
      if Tester( SupportedOrdinaryTableInfo[i-1] )( tbl ) then
        info:= SupportedOrdinaryTableInfo[i-1]( tbl );
        if IsString( info ) and not IsEmptyString( info ) then
          Print( "tbl.", SupportedOrdinaryTableInfo[i], ":=\n\"",
                 SupportedOrdinaryTableInfo[i-1]( tbl ), "\";\n" );
        else
          Print( "tbl.", SupportedOrdinaryTableInfo[i], ":=\n",
                 SupportedOrdinaryTableInfo[i-1]( tbl ), ";\n" );
        fi;
      fi;
    od;

    # Print the supported components if necessary.
    if IsLibraryCharacterTableRep( tbl ) then
      for comp in SupportedLibraryTableComponents do
        if IsBound( tbl!.( comp ) ) then
#T           if   comp = "cliffordTable" then
#T             Print( "tbl.", comp, ":=\n\"",
#T                    PrintCliffordTable( tbl ), "\";\n" );
#T           elif IsString( tbl!.comp ) and not IsEmptyString( tbl!.comp ) then
          if IsString( tbl!.comp ) and not IsEmptyString( tbl!.comp ) then
            Print( "tbl.", comp, ":=\n\"",
                   tbl!.comp, "\";\n" );
          else
            Print( "tbl.", comp, ":=\n",
                   tbl!.comp, ";\n" );
          fi;
        fi;
      od;
      Print( "ConvertToLibraryCharacterTableNC(tbl);\n" );
    else
      Print( "ConvertToOrdinaryTableNC(tbl);\n" );
    fi;
        
    # Print the rest of the construction.
    Print( "return tbl;\n" );
    Print( "end;\n" );
    Print( varname, ":= ", varname, "();\n" );
end;

PrintCharTable := tbl -> PrintCharacterTable( tbl, "t" );
#T compat3 ?


#T #############################################################################
#T ##
#T #M  IsCommutative( <tbl> )
#T ##
#T InstallOtherMethod( IsCommutative, true, [ IsOrdinaryTable ], 0,
#T     tbl -> NrConjugacyClasses( tbl ) = Size( tbl ) );
#T 
#T 
#T #############################################################################
#T ##
#T #M  IsCyclic( <tbl> )
#T ##
#T InstallOtherMethod( IsCyclic, true, [ IsOrdinaryTable ], 0,
#T     tbl -> Size( tbl ) in OrdersClassRepresentatives( tbl ) );
#T 
#T 
#T #############################################################################
#T ##
#T #M  IsSimple( <tbl> )
#T ##
#T InstallOtherMethod( IsSimple, true, [ IsOrdinaryTable ], 0,
#T     tbl -> Length( NormalSubgroups( tbl ) ) = 2 );
#T 
#T 
#T #############################################################################
#T ##
#T #M  IsPSolvable( <tbl>, <p> )
#T ##
#T InstallOtherMethod( IsPSolvable, true, [ IsOrdinaryTable, IsInt ], 0,
#T     function( tbl, p )
#T 
#T     local nsg,       # list of all normal subgroups
#T           i,         # loop variable, position in 'nsg'
#T           n,         # one normal subgroup
#T           posn,      # position of 'n' in 'nsg'
#T           size,      # size of 'n'
#T           nextsize,  # size of smallest normal subgroup containing 'n'
#T           classes,   # class lengths
#T           facts;     # set of prime factors of a chief factor
#T 
#T     nsg:= NormalSubgroups( tbl );
#T     Sort( nsg, function( x, y ) return Length(x) < Length(y); end );
#T 
#T     # Go up a chief series, starting with the trivial subgroup
#T     i:= 1;
#T     nextsize:= 1;
#T     classes:= SizesConjugacyClasses( tbl );
#T 
#T     while i < Length( nsg ) do
#T 
#T       posn:= i;
#T       n:= nsg[ posn ];
#T       size:= nextsize;
#T 
#T       # Get the smallest normal subgroup containing 'n' \ldots
#T       i:= posn + 1;
#T       while not IsSubsetSet( nsg[ i ], n ) do i:= i+1; od;
#T 
#T       # \ldots and its size.
#T       nextsize:= Sum( classes{ nsg[i] } );
#T 
#T       facts:= Set( FactorsInt( nextsize / size ) );
#T       if 1 < Length( facts ) and ( p = 0 or p in facts ) then
#T 
#T         # The chief factor 'nsg[i] / n' is not a prime power,
#T         # and our 'p' divides its order.
#T         return false;
#T 
#T       fi;
#T 
#T     od;
#T     return true;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  IsSolvable( <tbl> )
#T ##
#T InstallOtherMethod( IsSolvable, true, [ IsOrdinaryTable ], 0,
#T     tbl -> IsPSolvable( tbl, 0 ) );
#T 
#T 
#T #############################################################################
#T ##
#T #M  IsSupersolvable( <tbl> )
#T ##
#T InstallOtherMethod( IsSupersolvable, true, [ IsOrdinaryTable ], 0,
#T     tbl -> Size( SupersolvableResiduum( tbl ) ) = 1 );
#T 
#T 
#T #############################################################################
#T ##
#T #M  SupersolvableResiduum( <tbl> )
#T ##
#T InstallOtherMethod( SupersolvableResiduum, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local nsg,       # list of all normal subgroups
#T           i,         # loop variable, position in 'nsg'
#T           N,         # one normal subgroup
#T           posN,      # position of 'N' in 'nsg'
#T           size,      # size of 'N'
#T           nextsize,  # size of largest normal subgroup contained in 'N'
#T           classes;   # class lengths
#T 
#T     nsg:= NormalSubgroups( tbl );
#T     Sort( nsg, function( x, y ) return Length(x) < Length(y); end );
#T 
#T     # Go down a chief series, starting with the whole group,
#T     # until there is no step of prime order.
#T     i:= Length( nsg );
#T     nextsize:= Size( tbl );
#T     classes:= SizesConjugacyClasses( tbl );
#T 
#T     while i > 1 do
#T 
#T       posN:= i;
#T       N:= nsg[ posN ];
#T       size:= nextsize;
#T 
#T       # Get the largest normal subgroup contained in 'N' \ldots
#T       i:= posN - 1;
#T       while not IsSubsetSet( N, nsg[ i ] ) do i:= i-1; od;
#T 
#T       # \ldots and its size.
#T       nextsize:= Sum( classes{ nsg[i] } );
#T 
#T       if not IsPrimeInt( size / nextsize ) then
#T 
#T         # The chief factor 'N / nsg[i]' is not of prime order,
#T         # i.e., 'N' is the supersolvable residuum.
#T         return N;
#T 
#T       fi;
#T 
#T     od;
#T     return [ 1 ];
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #F  CharacterTable_UpperCentralSeriesFactor( <tbl>, <N> )
#T ##
#T ##  Let <tbl> the character table of the group $G$, and <N> the list of
#T ##  classes contained in the normal subgroup $N$ of $G$.
#T ##  The upper central series $[ Z_1, Z_2, \ldots, Z_n ]$ of $G/N$ is defined
#T ##  by $Z_1 = Z(G/N)$, and $Z_{i+1} / Z_i = Z( G / Z_i )$.
#T ##  'UpperCentralSeriesFactor( <tbl>, <N> )' is a list
#T ##  $[ C_1, C_2, \ldots, C_n ]$ where $C_i$ is the set of positions of
#T ##  $G$-conjugacy classes contained in $Z_i$.
#T ##
#T ##  A simpleminded version of the algorithm can be stated as follows.
#T ##
#T ##  $M_0:= Irr(G);$|
#T ##  |$Z_1:= Z(G);$|
#T ##  |$i:= 0;$|
#T ##  repeat
#T ##    |$i:= i+1;$|
#T ##    |$M_i:= \{ \chi\in M_{i-1} ; Z_i \leq \ker(\chi) \};$|
#T ##    |$Z_{i+1}:= \bigcap_{\chi\in M_i}} Z(\chi);$|
#T ##  until |$Z_i = Z_{i+1};$
#T ##
#T CharacterTable_UpperCentralSeriesFactor := function( tbl, N )
#T 
#T     local Z,      # result list
#T           n,      # number of conjugacy classes
#T           M,      # actual list of pairs kernel/centre of characters
#T           nextM,  # list of pairs in next iteration
#T           kernel, # kernel of a character
#T           centre, # centre of a character
#T           i,      # loop variable
#T           chi;    # loop variable
#T 
#T     n:= NrConjugacyClasses( tbl );
#T     N:= Set( N );
#T 
#T     # instead of the irreducibles store pairs $[ \ker(\chi), Z(\chi) ]$.
#T     # 'Z' will be the list of classes forming $Z_1 = Z(G/N)$.
#T     M:= [];
#T     Z:= [ 1 .. n ];
#T     for chi in Irr( tbl ) do
#T       kernel:= KernelChar( chi );
#T       if IsSubsetSet( kernel, N ) then
#T         centre:= CentreChar( chi );
#T         AddSet( M, [ kernel, centre ] );
#T         IntersectSet( Z, centre );
#T       fi;
#T     od;
#T 
#T     Z:= [ Z ];
#T     i:= 0;
#T 
#T     repeat
#T       i:= i+1;
#T       nextM:= [];
#T       Z[i+1]:= [ 1 .. n ];
#T       for chi in M do
#T         if IsSubsetSet( chi[1], Z[i] ) then
#T           Add( nextM, chi );
#T           IntersectSet( Z[i+1], chi[2] );
#T         fi;
#T       od;
#T       M:= nextM;
#T     until Z[i+1] = Z[i];
#T     Unbind( Z[i+1] );
#T 
#T     return Z;
#T end;
#T 
#T 
#T #############################################################################
#T ##
#T #M  UpperCentralSeries( <tbl> )
#T ##
#T InstallOtherMethod( UpperCentralSeries, true, [ IsOrdinaryTable ], 0,
#T     tbl -> CharacterTable_UpperCentralSeriesFactor( tbl, [1] ) );
#T 
#T 
#T #############################################################################
#T ##
#T #M  LowerCentralSeries( <tbl> )
#T ##
#T ##  Let <tbl> the character table of the group $G$.
#T ##  The lower central series $[ K_1, K_2, \ldots, K_n ]$ of $G$ is defined
#T ##  by $K_1 = G$, and $K_{i+1} = [ K_i, G ]$.
#T ##  'LowerCentralSeries( <tbl> )' is a list
#T ##  $[ C_1, C_2, \ldots, C_n ]$ where $C_i$ is the set of positions of
#T ##  $G$-conjugacy classes contained in $K_i$.
#T ##
#T ##  Given an element $x$ of $G$, then $g\in G$ is conjugate to $[x,y]$ for
#T ##  an element $y\in G$ if and only if
#T ##  $\sum_{\chi\in Irr(G)} \frac{|\chi(x)|^2 \overline{\chi(g)}}{\chi(1)}
#T ##  \not= 0$, or equivalently, if the structure constant
#T ##  $a_{x,\overline{x},g}$ is nonzero..
#T ##
#T ##  Thus $K_{i+1}$ consists of all classes $Cl(g)$ in $K_i$ for that there
#T ##  is an $x\in K_i$ such that $a_{x,\overline{x},g}$ is nonzero.
#T ##
#T InstallOtherMethod( LowerCentralSeries, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local series,     # list of normal subgroups, result
#T           K,          # actual last element of 'series'
#T           inv,        # list of inverses of classes of 'tbl'
#T           mat,        # matrix of structure constants
#T           i, j,       # loop over 'mat'
#T           running,    # loop not yet terminated
#T           new;        # next element in 'series'
#T 
#T     series:= [];
#T     series[1]:= [ 1 .. NrConjugacyClasses( tbl ) ];
#T     K:= DerivedSubgroup( tbl );
#T     if K = series[1] then
#T       return series;
#T     fi;
#T     series[2]:= K;
#T 
#T     # Compute the structure constants $a_{x,\overline{x},g}$ with $g$ and $x$
#T     # in $K_2$.
#T     # Put them into a matrix, the rows indexed by $g$, the columns by $x$.
#T     inv:= PowerMap( tbl, -1 );
#T     mat:= List( K, x -> [] );
#T     for i in [ 2 .. Length( K ) ] do
#T       for j in K do
#T         mat[i][j]:= ClassMultiplicationCoefficient( tbl, K[i], j, inv[j] );
#T       od;
#T     od;
#T 
#T     running:= true;
#T 
#T     while running do
#T 
#T       new:= [ 1 ];
#T       for i in [ 2 .. Length( mat ) ] do
#T         if ForAny( K, x -> mat[i][x] <> 0 ) then
#T           Add( new, i );
#T         fi;
#T       od;
#T 
#T       if Length( new ) = Length( K ) then
#T         running:= false;
#T       else
#T         mat:= mat{ new };
#T         K:= K{ new };
#T         Add( series, new );
#T       fi;
#T 
#T     od;
#T 
#T     return series;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #F  CharacterTable_IsNilpotentFactor( <tbl>, <N> )
#T ##
#T CharacterTable_IsNilpotentFactor := function( tbl, N )
#T     local series;
#T     series:= CharacterTable_UpperCentralSeriesFactor( tbl, N );
#T     return Length( series[ Length( series ) ] ) = NrConjugacyClasses( tbl );
#T end;
#T 
#T 
#T #############################################################################
#T ##
#T #M  IsNilpotent( <tbl> )
#T ##
#T InstallOtherMethod( IsNilpotent, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T     local series;
#T     series:= UpperCentralSeries( tbl );
#T     return Length( series[ Length( series ) ] ) = NrConjugacyClasses( tbl );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #F  CharacterTable_IsNilpotentNormalSubgroup( <tbl>, <N> )
#T ##
#T ##  returns whether the normal subgroup described by the classes in <N> is
#T ##  nilpotent.
#T ##
#T CharacterTable_IsNilpotentNormalSubgroup := function( tbl, N )
#T 
#T     local classlengths,  # class lengths
#T           orders,        # orders of class representatives
#T           ppow,          # list of classes of prime power order
#T           part,          # one pair '[ prime, exponent ]'
#T           classes;       # classes of p power order for a prime p
#T 
#T     # Take the classes of prime power order.
#T     classlengths:= SizesConjugacyClasses( tbl );
#T     orders:= OrdersClassRepresentatives( tbl );
#T     ppow:= Filtered( N, i -> IsPrimePowerInt( orders[i] ) );
#T 
#T     for part in Collected( FactorsInt( Sum( classlengths{ N } ) ) ) do
#T 
#T       # Check whether the Sylow p subgroup of 'N' is normal in 'N',
#T       # i.e., whether the number of elements of p-power is equal to
#T       # the size of a Sylow p subgroup.
#T       classes:= Filtered( ppow, i -> orders[i] mod part[1] = 0 );
#T       if part[1] ^ part[2] <> Sum( classlengths{ classes } ) + 1 then
#T         return false;
#T       fi;
#T 
#T     od;
#T     return true;
#T end;
#T 
#T 
#T ##############################################################################
#T ##
#T #M  AbelianInvariants( <tbl> )
#T ##
#T ##  For all Sylow p subgroups of '<tbl> / DerivedSubgroup( <tbl> )' compute
#T ##  the abelian invariants by repeated factoring by a cyclic group of maximal
#T ##  order.
#T ##
#T InstallOtherMethod( AbelianInvariants,
#T     "method for a character table",
#T     true,
#T     [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local kernel,  # cyclic group to be factored out
#T           inv,     # list of invariants, result
#T           primes,  # list of prime divisors of actual size
#T           max,     # list of actual maximal orders, for 'primes'
#T           pos,     # list of positions of maximal orders
#T           orders,  # list of representative orders
#T           i,       # loop over classes
#T           j;       # loop over primes
#T 
#T     # Do all computations modulo the derived subgroup.
#T     kernel:= ClassesOfDerivedSubgroup( tbl );
#T     if Length( kernel ) > 1 then
#T       tbl:= tbl / kernel;
#T     fi;
#T 
#T     inv:= [];
#T 
#T     while 1 < Size( tbl ) do
#T 
#T       # For all prime divisors $p$ of the size,
#T       # compute the element of maximal $p$ power order.
#T       primes:= Set( FactorsInt( Size( tbl ) ) );
#T       max:= List( primes, x -> 1 );
#T       pos:= [];
#T       orders:= OrdersClassRepresentatives( tbl );
#T       for i in [ 2 .. Length( orders ) ] do
#T         if IsPrimePowerInt( orders[i] ) then
#T           j:= 1;
#T           while orders[i] mod primes[j] <> 0 do
#T             j:= j+1;
#T           od;
#T           if orders[i] > max[j] then
#T             max[j]:= orders[i];
#T             pos[j]:= i;
#T           fi;
#T         fi;
#T       od;
#T         
#T       # Update the list of invariants.
#T       Append( inv, max );
#T 
#T       # Factor out the cyclic subgroup.
#T       tbl:= tbl / ClassesOfNormalClosure( tbl, pos );
#T 
#T     od;
#T 
#T     return AbelianInvariantsOfList( inv );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Agemo( <tbl>, <p> )
#T ##
#T InstallOtherMethod( Agemo, true, [ IsOrdinaryTable, IsInt and IsPosRat ], 0,
#T     function( tbl, p )
#T     return NormalClosure( tbl, Set( PowerMap( tbl, p ) ) );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Centre( <tbl> )
#T ##
#T InstallOtherMethod( Centre, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T     local size, centralizers;
#T     size:= Size( tbl );
#T     centralizers:= SizesCentralizers( tbl );
#T     return Filtered( [ 1 .. NrConjugacyClasses( tbl ) ],
#T                      x -> centralizers[x] = size );
#T     end );
#T #T CentreClasses!
#T 
#T 
#T #############################################################################
#T ##
#T #M  DerivedSubgroup( <tbl> )
#T ##
#T InstallOtherMethod( DerivedSubgroup, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local der,   # derived subgroup, result
#T           chi;   # one irreducible character
#T 
#T     der:= [ 1 .. NrConjugacyClasses( tbl ) ];
#T     for chi in Irr( tbl ) do
#T       if Degree( chi ) = 1 then
#T         IntersectSet( der, KernelChar( chi ) );
#T       fi;
#T     od;
#T     return der;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  ElementaryAbelianSeries( <tbl> )
#T ##
#T InstallOtherMethod( ElementaryAbelianSeries, true,
#T                     [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local elab,         # el. ab. series, result
#T           nsg,          # list of normal subgroups of 'tbl'
#T           actsize,      # size of actual normal subgroup
#T           classes,      # conjugacy class lengths
#T           next,         # next smaller normal subgroup
#T           nextsize;     # size of next smaller normal subgroup
#T 
#T     # Sort normal subgroups according to decreasing number of classes.
#T     nsg:= ShallowCopy( NormalSubgroups( tbl ) );
#T     Sort( nsg, function( x, y ) return Length( x ) < Length( y ); end );
#T 
#T     elab:= [ [ 1 .. NrConjugacyClasses( tbl ) ] ];
#T     Unbind( nsg[ Length( nsg ) ] );
#T 
#T     actsize:= Size( tbl );
#T     classes:= SizesConjugacyClasses( tbl );
#T 
#T     repeat
#T 
#T       next:= nsg[ Length( nsg ) ];
#T       nextsize:= Sum( classes{ next } );
#T       Add( elab, next );
#T       Unbind( nsg[ Length( nsg ) ] );
#T       nsg:= Filtered( nsg, x -> IsSubset( next, x ) );
#T 
#T       if not IsPrimePowerInt( actsize / nextsize ) then
#T         Error( "<tbl> must be table of a solvable group" );
#T       fi;
#T 
#T       actsize:= nextsize;
#T 
#T     until Length( nsg ) = 0;
#T 
#T     return elab;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  Exponent( <tbl> )
#T ##
#T InstallOtherMethod( Exponent, true, [ IsOrdinaryTable ], 0,
#T     tbl -> Lcm( OrdersClassRepresentatives( tbl ) ) );
#T 
#T 
#T #############################################################################
#T ##
#T #M  FittingSubgroup( <tbl> )
#T ##
#T ##  The Fitting subgroup is the maximal nilpotent normal subgroup, that is,
#T ##  the product of all normal subgroups of prime power order.
#T ##
#T InstallOtherMethod( FittingSubgroup, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local nsg,      # all normal subgroups of 'tbl'
#T           classes,  # class lengths
#T           ppord,    # classes in normal subgroups of prime power order
#T           n;        # one normal subgroup of 'tbl'
#T 
#T     # Compute all normal subgroups.
#T     nsg:= NormalSubgroups( tbl );
#T 
#T     # Take the union of classes in all normal subgroups of prime power order.
#T     classes:= SizesConjugacyClasses( tbl );
#T     ppord:= [];
#T     for n in nsg do
#T       if IsPrimePowerInt( Sum( classes{n} ) ) then
#T         UniteSet( ppord, n );
#T       fi;
#T     od;
#T 
#T     # Return the normal closure.
#T     return NormalClosure( tbl, ppord );
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  MaximalNormalSubgroups( <tbl> )
#T ##
#T ##  *Note* that the maximal normal subgroups of a group <G> can be computed
#T ##  easily if the character table of <G> is known.  So if you need the table
#T ##  anyhow, you should compute it before computing the maximal normal
#T ##  subgroups of the group.
#T ##
#T InstallOtherMethod( MaximalNormalSubgroups, true,
#T                     [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local normal,    # list of all kernels
#T           maximal,   # list of maximal kernels
#T           k;         # one kernel
#T 
#T     # Every normal subgroup is an intersection of kernels of characters,
#T     # so maximal normal subgroups are kernels of irreducible characters.
#T     normal:= Set( List( Irr( tbl ), KernelChar ) );
#T 
#T     # Remove non-maximal kernels
#T     RemoveSet( normal, [ 1 .. NrConjugacyClasses( tbl ) ] );
#T     Sort( normal, function(x,y) return Length(x) > Length(y); end );
#T     maximal:= [];
#T     for k in normal do
#T       if ForAll( maximal, x -> not IsSubsetSet( x, k ) ) then
#T 
#T         # new maximal element found
#T         Add( maximal, k );
#T 
#T       fi;
#T     od;
#T 
#T     return maximal;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  NormalClosure( <tbl>, <classes> )
#T ##
#T InstallOtherMethod( NormalClosure, true, [ IsOrdinaryTable, IsList ], 0,
#T     function( tbl, classes )
#T 
#T     local closure,   # classes forming the normal closure, result
#T           chi,       # one irreducible character of 'tbl'
#T           ker;       # classes forming the kernel of 'chi'
#T 
#T     closure:= [ 1 .. NrConjugacyClasses( tbl ) ];
#T     for chi in Irr( tbl ) do
#T       ker:= KernelChar( chi );
#T       if IsSubset( ker, classes ) then
#T         IntersectSet( closure, ker );
#T       fi;
#T     od;
#T 
#T     return closure;
#T     end );
#T 
#T 
#T #############################################################################
#T ##
#T #M  NormalSubgroups( <tbl> )
#T ##
#T InstallOtherMethod( NormalSubgroups, true, [ IsOrdinaryTable ], 0,
#T     function( tbl )
#T 
#T     local kernels,  # list of kernels of irreducible characters
#T           ker1,     # loop variable
#T           ker2,     # loop variable
#T           normal,   # list of normal subgroups, result
#T           inter;    # intersection of two kernels
#T 
#T     # get the kernels of irreducible characters
#T     kernels:= Set( List( Irr( tbl ), KernelChar ) );
#T 
#T     # form all possible intersections of the kernels
#T     normal:= ShallowCopy( kernels );
#T     for ker1 in normal do
#T       for ker2 in kernels do
#T         inter:= Intersection( ker1, ker2 );
#T         if not inter in normal then
#T           Add( normal, inter );
#T         fi;
#T       od;
#T     od;
#T 
#T     # return the list of normal subgroups
#T     return Set( normal );
#T     end );
#T 
#T 
#T ############################################################################
#T ##
#T #V  PreliminaryLatticeOps . . operations record for normal subgroup lattices
#T ##
#T PreliminaryLatticeOps := OperationsRecord( "PreliminaryLatticeOps" );
#T 
#T PreliminaryLatticeOps.Print := function( obj )
#T     Print( "Lattice( ", obj.domain, " )" );
#T     end;
#T 
#T ############################################################################
#T ##
#T #F  Lattice( <tbl> ) . .  lattice of normal subgroups of a c.t.
#T ##
#T Lattice := function( tbl )
#T 
#T     local i, j,       # loop variables
#T           nsg,        # list of normal subgroups
#T           len,        # length of 'nsg'
#T           sizes,      # sizes of normal subgroups
#T           max,        # one maximal subgroup
#T           maxes,      # list of maximal contained normal subgroups
#T           actsize,    # actuel size of normal subgroups
#T           actmaxes,
#T           latt;       # the lattice record
#T 
#T     # Compute normal subgroups and their sizes
#T     if not IsBound( tbl.normalSubgroups ) then
#T       tbl.normalSubgroups:= NormalSubgroups( tbl );
#T     fi;
#T     nsg:= tbl.normalSubgroups;
#T     len:= Length( nsg );
#T     sizes:= List( nsg, x -> Sum( tbl.classes{ x } ) );
#T     SortParallel( sizes, nsg );
#T 
#T     # For each normal subgroup, compute the maximal contained ones.
#T     maxes:= [];
#T     i:= 1;
#T     while i <= len do
#T       actsize:= sizes[i];
#T       actmaxes:= Filtered( [ 1 .. i-1 ], x -> actsize mod sizes[x] = 0 );
#T       while i <= len and sizes[i] = actsize do
#T         max:= Filtered( actmaxes, x -> IsSubset( nsg[i], nsg[x] ) );
#T         for j in Reversed( max ) do
#T           SubtractSet( max, maxes[j] );
#T         od;
#T         Add( maxes, max );
#T         i:= i+1;
#T       od;
#T     od;
#T 
#T     # construct the lattice record
#T     latt:= rec( domain          := tbl,
#T                 normalSubgroups := nsg,
#T                 sizes           := sizes,
#T                 maxes           := maxes,
#T                 XGAP            := rec( vertices := [ 1 .. len ],
#T                                         sizes    := sizes,
#T                                         maximals := maxes ),
#T                 operations      := PreliminaryLatticeOps );
#T 
#T     # return the lattice record
#T     return latt;
#T end;


#############################################################################
##
#F  LowercaseString( <string> ) . . . string consisting of lower case letters
##
#T should be meved eventually to 'string.g?'
LowercaseString := function( str )

    local alp, ALP, result, i, pos;

    alp:= "abcdefghijklmnopqrstuvwxyz";
    ALP:= "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    result:= "";
    for i in str do
      pos:= Position( ALP, i );
      if pos = fail then
        Add( result, i );
      else
        Add( result, alp[ pos ] );
      fi;
    od;
    ConvertToStringRep( result );
    return result;
end;


#############################################################################
##
#F  PermutationToSortCharacters( <tbl>, <chars>, <degree>, <norm> )
##
PermutationToSortCharacters := function( tbl, chars, degree, norm )

    local rational, listtosort, i, len;

    if IsEmpty( chars ) then
      return ();
    fi;

    # Rational characters shall precede irrational ones of same degree,
    # and the trivial character shall be the first one.
    rational := function( chi )
      chi:= ValuesOfClassFunction( chi );
      if ForAll( chi, IsRat ) then
        if ForAll( chi, x -> x = 1 ) then
          return -1;
        else
          return 0;
        fi;
      else
        return 1;
      fi;
    end;

    # Compute the permutation.
    listtosort:= [];
    if degree and norm then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ ScalarProduct( chars[i], chars[i] ),
                          DegreeOfCharacter( chars[i] ),
                          rational( chars[i] ), i ];
      od;
    elif degree then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ DegreeOfCharacter( chars[i] ),
                          rational( chars[i] ), i ];
      od;
    elif norm then
      for i in [ 1 .. Length( chars ) ] do
        listtosort[i]:= [ ScalarProduct( chars[i], chars[i] ),
                          rational( chars[i] ), i ];
      od;
    else
      Error( "<degree> or <norm> must be 'true'" );
    fi;
    Sort( listtosort );
    len:= Length( listtosort[1] );
    for i in [ 1 .. Length( chars ) ] do
      listtosort[i]:= listtosort[i][ len ];
    od;
    return Inverse( PermList( listtosort ) );
end;


#############################################################################
##
#F  RealClassesCharTable( <tbl> ) . . . .  the real-valued classes of a table
##
RealClassesCharTable := function( tbl )
    local inv;
    inv:= PowerMap( tbl, -1 );
    return Filtered( [ 1 .. NrConjugacyClasses( tbl ) ], i -> inv[i] = i );
end;


#############################################################################
##
#M  CharacterTableWithSortedCharacters( <tbl> )
##
InstallMethod( CharacterTableWithSortedCharacters,
    "method for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> CharacterTableWithSortedCharacters( tbl,
             PermutationToSortCharacters( tbl, Irr( tbl ), true, false ) ) );


#############################################################################
##
#M  CharacterTableWithSortedCharacters( <tbl>, <perm> )
##
InstallOtherMethod( CharacterTableWithSortedCharacters,
    "method for an ordinary character table, and a permutation",
    true,
    [ IsOrdinaryTable, IsPerm ], 0,
    function( tbl, perm )

    local new, i;

    # Create the new table.
    new:= rec();
    ConvertToOrdinaryTable( new );

    # Set the permuted attribute values.
    SetIrr( new, Permuted( Irr( tbl ), perm ) );
    SetIrredInfo( new, Permuted( IrredInfo( tbl ), perm ) );

    # Set the other supported values.
    for i in [ 2, 4 .. Length( SupportedOrdinaryTableInfo ) ] do
      if Tester( SupportedOrdinaryTableInfo[ i-1 ] )
         and not SupportedOrdinaryTableInfo[i]
                     in [ "irr", "irredInfo", "underlyingGroup" ] then
        Setter( SupportedOrdinaryTableInfo[ i-1 ] )( new,
            SupportedOrdinaryTableInfo[ i-1 ]( tbl ) );
      fi;
    od;

    # Return the table.
    return new;
    end );


#############################################################################
##
#M  SortedCharacters( <tbl>, <chars> )
##
InstallMethod( SortedCharacters,
    "method for a character table, and a homogeneous list",
    true,
    [ IsNearlyCharacterTable, IsHomogeneousList ], 0,
    function( tbl, chars )
    return Permuted( chars,
               PermutationToSortCharacters( tbl, chars, true, true ) );
    end );


#############################################################################
##
#M  SortedCharacters( <tbl>, <chars>, \"norm\" )
#M  SortedCharacters( <tbl>, <chars>, \"degree\" )
##
InstallOtherMethod( SortedCharacters,
    "method for a character table, a homogeneous list, and a string",
    true,
    [ IsNearlyCharacterTable, IsHomogeneousList, IsString ], 0,
    function( tbl, chars, string )
    if string = "norm" then
      return Permuted( chars,
                 PermutationToSortCharacters( tbl, chars, false, true ) );
    elif string = "degree" then
      return Permuted( chars,
                 PermutationToSortCharacters( tbl, chars, true, false ) );
    else
      Error( "<string> must be \"norm\" or \"degree\"" );
    fi;
    end );


#############################################################################
##
#F  PermutationToSortClasses( <tbl>, <classes>, <orders> )
##
PermutationToSortClasses := function( tbl, classes, orders )

    local listtosort, i, len;

    # Compute the permutation.
    listtosort:= [];
    if classes and orders then
      classes:= SizesConjugacyClasses( tbl );
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ orders[i], classes[i], i ];
      od;
    elif classes then
      classes:= SizesConjugacyClasses( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ classes[i], i ];
      od;
    elif orders then
      orders:= OrdersClassRepresentatives( tbl );
      for i in [ 1 .. NrConjugacyClasses( tbl ) ] do
        listtosort[i]:= [ orders[i], i ];
      od;
    else
      Error( "<classes> or <orders> must be 'true'" );
    fi;
    Sort( listtosort );
    len:= Length( listtosort[1] );
    for i in [ 1 .. Length( listtosort ) ] do
      listtosort[i]:= listtosort[i][ len ];
    od;
    return Inverse( PermList( listtosort ) );
end;


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl> )
##
InstallMethod( CharacterTableWithSortedClasses,
    "method for a character table",
    true,
    [ IsCharacterTable ], 0,
    tbl -> CharacterTableWithSortedClasses( tbl,
               PermutationToSortClasses( tbl, true, true ) ) );


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl>, \"centralizers\" )
#M  CharacterTableWithSortedClasses( <tbl>, \"representatives\" )
##
InstallOtherMethod( CharacterTableWithSortedClasses,
    "method for a character table, and string",
    true,
    [ IsCharacterTable, IsString ], 0,
    function( tbl, string )
    if   string = "centralizers" then
      return CharacterTableWithSortedClasses( tbl,
                 PermutationToSortClasses( tbl, true, false ) );
    elif string = "representatives" then
      return CharacterTableWithSortedClasses( tbl,
                 PermutationToSortClasses( tbl, false, true ) );
    else
      Error( "<string> must be \"centralizers\" or \"representatives\"" );
    fi;
    end );


#############################################################################
##
#M  CharacterTableWithSortedClasses( <tbl>, <permutation> )
##
InstallOtherMethod( CharacterTableWithSortedClasses,
    "method for an ordinary character table, and a permutation",
    true,
    [ IsOrdinaryTable, IsPerm ], 0,
    function( tbl, perm )

    local new, attr, fus, tblmaps, permmap, inverse, k;

    # Create the new table.
    new:= rec();
    ConvertToOrdinaryTable( new );

    # Set the permuted attribute values.
    if 1^perm <> 1 then
      Error( "<perm> must fix the first class" );
    elif Order( perm ) = 1 then
      return tbl;
    fi;

    # Set supported attributes that do not need adjustion.
    for attr in [ Identifier, InfoText, IrredInfo, IsSimpleGroup,
                  Maxes, NamesOfFusionSources, UnderlyingCharacteristic ] do
      if Tester( attr )( tbl ) then
        Setter( attr )( new, attr( new ) );
      fi;
    od;

    # Set known attributes that must be adjusted.
    if HasClassParameters( tbl ) then
      SetClassParameters( new,
          Permuted( ClassParameters( tbl ), perm ) );
    fi;
    if HasIrr( tbl ) then
      SetIrr( new,
          List( Irr( tbl ), chi -> CharacterByValues( new,
                Permuted( ValuesOfClassFunction( chi, perm ) ) ) ) );
    fi;
    if HasOrdersClassRepresentatives( tbl ) then
      SetOrdersClassRepresentatives( new,
          Permuted( OrdersClassRepresentatives( tbl ), perm ) );
    fi;
    if HasSizesCentralizers( tbl ) then
      SetSizesCentralizers( new,
          Permuted( SizesCentralizers( tbl ), perm ) );
    fi;
    for fus in ComputedClassFusions( tbl ) do
      Add( ComputedClassFusions( new ),
           rec( name:= fus.name, map:= Permuted( fus.map, perm ) ) );
    od;

    if HasComputedPowerMaps( tbl ) then

      tblmaps:= ComputedPowerMaps( tbl );
      permmap:= List( perm );
      inverse:= List( perm^(-1) );
      for k in [ Length( permmap ) + 1 .. NrConjugacyClasses( tbl ) ] do
        permmap[k]:= k;
        inverse[k]:= k;
      od;
      for k in [ 1 .. Length( tblmaps ) ] do
        if IsBound( tblmaps[k] ) then
          ComputedPowerMaps( new )[k]:= CompositionMaps( permmap,
              CompositionMaps( tblmaps[k], inverse ) );
        fi;
      od;

    fi;

    # The automorphisms of the sorted table are obtained on conjugation.
    if HasAutomorphismsOfTable( tbl ) then
      SetAutomorphismsOfTable( new, GroupByGenerators(
          List( GeneratorsOfGroup( AutomorphismsOfTable( tbl ) ),
                x -> x^perm ), () ) );
    fi;

    # Set the class permutation (important for fusions).
    if HasClassPermutation( tbl ) then
      SetClassPermutation( new, ClassPermutation( tbl ) * perm );
    else
      SetClassPermutation( new, perm );
    fi;

    # Return the new table.
    return new;
    end );


#############################################################################
##
#F  SortedCharacterTable( <tbl>, <kernel> )
#F  SortedCharacterTable( <tbl>, <normalseries> )
#F  SortedCharacterTable( <tbl>, <facttbl>, <kernel> )
##
SortedCharacterTable := function( arg )

    local i, j, tbl, kernels, list, columns, rows, chi, F, facttbl, kernel,
          trans, ker, fus, new;

    # Check the arguments.
    if not ( Length( arg ) in [ 2, 3 ] and IsOrdinaryTable( arg[1] ) and
             IsList( arg[ Length( arg ) ] ) and
             ( Length( arg ) = 2 or IsOrdinaryTable( arg[2] ) ) ) then
      Error( "usage: SortedCharacterTable( <tbl>, <kernel> ) resp.\n",
             "       SortedCharacterTable( <tbl>, <normalseries> ) resp.\n",
             "       SortedCharacterTable( <tbl>, <facttbl>, <kernel> )" );
    fi;

    tbl:= arg[1];

    if Length( arg ) = 2 then

      # sort w.r. to kernel or series of kernels
      kernels:= arg[2];
      if IsEmpty( kernels ) then
        return tbl;
      fi;

      # regard single kernel as special case of normal series
      if IsInt( kernels[1] ) then
        kernels:= [ kernels ];
      fi;

      # permutation of classes\:
      # 'list[i] = k' if 'i' is contained in 'kernels[k]' but not
      # in 'kernels[k-1]'; only the first position contains a zero
      # to ensure that the identity is not moved.
      # If class 'i' is not contained in any of the kernels we have
      # 'list[i] = ""'.
      list:= [ 0 ];
      for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
        list[i]:= "";
      od;
      for i in [ 1 .. Length( kernels ) ] do
        for j in kernels[i] do
          if not IsInt( list[j] ) then
            list[j]:= i;
          fi;
        od;
      od;
      columns:= Sortex( list );

      # permutation of characters
      # 'list[i] = -(k+1)' if '<tbl>.irreducibles[i]' has 'kernels[k]'
      # in its kernel but not 'kernels[k+1]'; if the 'i'--th irreducible
      # contains none of 'kernels' in its kernel we have 'list[i] = -1',
      # for an irreducible with kernel containing 'kernels[ Length( kernels ) ]
      # the value is '-(Length( kernels ) + 1)'.
      list:= [];
      if HasIrr( tbl ) then
        for chi in Irr( tbl ) do
          i:= 1;
          while     i <= Length( kernels )
                and ForAll( kernels[i], x -> chi[x] = chi[1] ) do
            i:= i+1;
          od;
          Add( list, -i );
        od;
        rows:= Sortex( list );
      else
        rows:= ();
      fi;

    else

      # sort w.r. to table of factor group
      facttbl:= arg[2];
      kernel:= arg[3];
      F:= CharacterTableFactorGroup( tbl, kernel );
      trans:= TransformingPermutationsCharacterTables( F, facttbl );
      if trans = fail then
        Info( InfoCharacterTable, 2,
              "SortedCharacterTable: tables of factors not compatible" );
        return fail;
      fi;

      # permutation of classes\:
      # 'list[i] = k' if 'i' maps to the 'j'--th class of <F>, and
      # 'trans.columns[j] = i'
      list:= OnTuples( GetFusionMap( tbl, F ), trans.columns );
      columns:= Sortex( list );

      # permutation of characters\:
      # divide 'Irr( <tbl> )' into two parts, those containing
      # the kernel of the factor fusion in their kernel (value 0),
      # and the others (value 1); do not forget to permute characters
      # of the factor group with 'trans.rows'.
      if HasIrr( tbl ) then
        ker:= KernelChar( GetFusionMap( tbl, F ) );
        list:= [];
        for chi in Irr( tbl ) do
          if ForAll( ker, x -> chi[x] = chi[1] ) then
            Add( list, 0 );
          else
            Add( list, 1 );
          fi;
        od;
        rows:= Sortex( list ) * trans.rows;
      else
        rows:= ();
      fi;

      # delete the fusion to 'F' on 'tbl'
      fus:= ComputedClassFusions( tbl );
      Unbind( fus[ Length( fus ) ] );
#T better ?

    fi;

    # Sort and return.
    new:= CharacterTableWithSortedClasses( tbl, columns );
    new:= CharacterTableWithSortedCharacters( new, rows );
    return new;
end;


#############################################################################
##
#F  CASString( <tbl> )
##
CASString := function( tbl )

    local ll,                 # line length
          CAS,                # the string, result
          i, j,               # loop variables
          convertcyclotom,    # local function, string of cyclotomic
          convertrow,         # local function, convert a whole list
          column,
          fus,                # loop over fusions
          tbl_irredinfo;

    ll:= SizeScreen()[1];

    if HasIdentifier( tbl ) then                      # name
      CAS:= Concatenation( "'", Identifier( tbl ), "'\n" );
    else
      CAS:= "'NN'\n";
    fi;
    Append( CAS, "00/00/00. 00.00.00.\n" );           # date
    if HasSizesCentralizers( tbl ) then               # nccl, cvw, ctw
      Append( CAS, Concatenation(
              "(", String( Length( SizesCentralizers( tbl ) ) ), ",",
              String( Length( SizesCentralizers( tbl ) ) ), ",0," ) );
    else
      Append( CAS, "(0,0,0," );
    fi;

    if HasIrr( tbl ) then                             # max
      Append( CAS, Concatenation( String( Length( Irr( tbl ) ) ), "," ) );
      if Length( Irr( tbl ) ) = Length( Set( Irr( tbl ) ) ) then
        Append( CAS, "-1," );                         # link
      else
        Append( CAS, "0," );                          # link
      fi;
    fi;
    Append( CAS, "0)\n" );                            # tilt
    if HasInfoText( tbl ) then                        # text
      Append( CAS, Concatenation( "text:\n(#", InfoText( tbl ), "#),\n" ) );
    fi;
    if HasSize( tbl ) then                            # order
      Append( CAS, Concatenation( "order=", String( Size( tbl ) ) ) );
    fi;

    convertcyclotom:= function( cyc )
    local i, str, coeffs;
    coeffs:= COEFFSCYC( cyc );
    str:= Concatenation( "\n<w", String( Length( coeffs ) ), "," );
    if coeffs[1] <> 0 then
      str:= Concatenation( str, String( coeffs[1] ) );
    fi;
    i:= 2;
    while i <= Length( coeffs ) do
      if Length( str ) + Length( String( coeffs[i] ) )
                       + Length( String( i-1 ) ) + 4 >= ll then
        Append( CAS, str );
        Append( CAS, "\n" );
        str:= "";
      fi;
      if coeffs[i] < 0 then
        str:= Concatenation( str, "-" );
        if coeffs[i] <> -1 then
          str:= Concatenation( str, String( -coeffs[i] ) );
        fi;
        str:= Concatenation( str, "w", String( i-1 ) );
      elif coeffs[i] > 0 then
        str:= Concatenation( str, "+" );
        if coeffs[i] <> 1 then
          str:= Concatenation( str, String( coeffs[i] ) );
        fi;
        str:= Concatenation( str, "w", String( i-1 ) );
      fi;
      i:= i+1;
    od;
    Append( CAS, str );
    Append( CAS, "\n>\n" );
    end;

    convertrow:= function( list )
    local i, str;
    if IsCycInt( list[1] ) and not IsInt( list[1] ) then
      convertcyclotom( list[1] );
      str:= "";
    elif IsUnknown( list[1] ) or IsList( list[1] ) then
      str:= "?";
    else
      str:= String( list[1] );
    fi;
    i:= 2;
    while i <= Length( list ) do
      if IsCycInt( list[i] ) and not IsInt( list[i] ) then
        Append( CAS, str );
        Append( CAS, "," );
        convertcyclotom( list[i] );
        str:= "";
      elif IsUnknown( list[i] ) or IsList( list[i] ) then
        if Length( str ) + 4 < ll then
          str:= Concatenation( str, ",?" );
        else
          Append( CAS, str );
          Append( CAS, ",?\n" );
          str:= "";
        fi;
      else
        if Length(str) + Length( String(list[i]) ) + 5 < ll then
          str:= Concatenation( str, ",", String( list[i] ) );
        else
          Append( CAS, str );
          Append( CAS, ",\n" );
          str:= String( list[i] );
        fi;
      fi;
      i:= i+1;
    od;
    Append( CAS, str );
    Append( CAS, "\n" );
    end;

    if HasSizesCentralizers( tbl ) then                 # centralizers
      Append( CAS, ",\ncentralizers:(\n" );
      convertrow( SizesCentralizers( tbl ) );
      Append( CAS, ")" );
    fi;
    if HasOrdersClassRepresentatives( tbl ) then        # orders
      Append( CAS, ",\nreps:(\n" );
      convertrow( OrdersClassRepresentatives( tbl ) );
      Append( CAS, ")" );
    fi;
    if IsBound( tbl!.print ) then                       # print
      Append( CAS, ",\nprint:(\n" );
      convertrow( tbl!.print );
      Append( CAS, ")" );
    fi;
    if HasComputedPowerMaps( tbl ) then                 # power maps
      for i in [ 1 .. Length( ComputedPowerMaps( tbl ) ) ] do
        if IsBound( ComputedPowerMaps( tbl )[i] ) then
          Append( CAS, ",\npowermap:" );
          Append( CAS, String(i) );
          Append( CAS, "(\n" );
          convertrow( ComputedPowerMaps( tbl )[i] );
          Append( CAS, ")" );
        fi;
      od;
    fi;
    if     IsLibraryCharacterTableRep( tbl )
       and IsBound( tbl!.classtext ) then               # classtext
                                                        # (partitions)
      Append( CAS, ",\nclasstext:'part'\n($[" );
      convertrow( tbl!.classtext[1] );
      Append( CAS, "]$" );
      for i in [ 2 .. Length( tbl!.classtext ) ] do
        Append( CAS, "\n,$[" );
        convertrow( tbl!.classtext[i] );
        Append( CAS, "]$" );
      od;
      Append( CAS, ")" );
    fi;
    if HasComputedClassFusions( tbl ) then              # fusions
      for fus in ComputedClassFusions( tbl ) do
        if IsBound( fus.type ) then
          if fus.type = "normal" then
            Append( CAS, ",\nnormal subgroup " );
          elif fus.type = "factor" then
            Append( CAS, ",\nfactor " );
          else
            Append( CAS, ",\n" );
          fi;
        else
          Append( CAS, ",\n" );
        fi;
        Append( CAS, "fusion:'" );
        Append( CAS, fus.name );
        Append( CAS, "'(\n" );
        convertrow( fus.map );
        Append( CAS, ")" );
      od;
    fi;
    if     IsLibraryCharacterTableRep( tbl )
       and IsBound( tbl!.characters ) then             # characters ...
#T why were irreds tested for being different?
      Append( CAS, ",\ncharacters:" );
      for i in tbl!.characters do
        Append( CAS, "\n(" );
        convertrow( i );
        Append( CAS, ",0:0)" );
      od;
    elif HasIrr( tbl ) then                            # ... or irreducibles
      Append( CAS, ",\ncharacters:" );
      for i in Irr( tbl ) do
        Append( CAS, "\n(" );
        convertrow( i );
        Append( CAS, ",0:0)" );
      od;
    fi;
    if HasIrredInfo( tbl ) then                        # indicators, blocks
      tbl_irredinfo:= IrredInfo( tbl );
      if IsBound( tbl_irredinfo[1].block ) then
        for i in [ 2 .. Length( tbl_irredinfo[1].block ) ] do
          if IsBound( tbl_irredinfo[1].block[i] ) then
            column:= [];
            for j in [ 1 .. NrConjugacyClasses( tbl ) ] do
              column[j]:= tbl_irredinfo[j].block[i];
            od;
            Append( CAS, ",\nblocks:" );
            Append( CAS, String( i ) );
            Append( CAS, "(\n" );
            convertrow( column );
            Append( CAS, ")" );
          fi;
        od;
      fi;
      if IsBound( tbl_irredinfo[1].indicator ) then
        for i in [ 2 .. Length( tbl_irredinfo[1].indicator ) ] do
          if IsBound( tbl_irredinfo[1].indicator[i] ) then
            column:= [];
            for j in [ 1 .. Length( Irr( tbl ) ) ] do
              column[j]:= tbl_irredinfo[j].indicator[i];
            od;
            Append( CAS, ",\nindicator:" );
            Append( CAS, String( i ) );
            Append( CAS, "(\n" );
            convertrow( column );
            Append( CAS, ")" );
          fi;
        od;
      fi;
    fi;
    if 27 < ll then
      Append( CAS, ";\n/// converted from GAP" );
    else
      Append( CAS, ";\n///" );
    fi;
    return CAS;
end;


#############################################################################
##
#E  ctbl.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



