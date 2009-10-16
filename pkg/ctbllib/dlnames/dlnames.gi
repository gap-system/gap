#############################################################################
##
#W  dlnames.gi            GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: dlnames.gi,v 1.1 2005/05/17 08:51:03 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains implementations concerning Deligne-Lusztig names of
##  unipotent characters of finite groups of Lie type.
##
Revision.( "ctbllib/dlnames/dlnames_gi" ) :=
    "@(#)$Id: dlnames.gi,v 1.1 2005/05/17 08:51:03 gap Exp $";


#############################################################################
##
#A  DeligneLusztigNames( <tbl> )
#A  DeligneLusztigNames( <string> )
#A  DeligneLusztigNames( <record> )
##
InstallMethod( DeligneLusztigNames, 
    "IsCharacterTable",
    [ IsCharacterTable ], 
    tbl -> DeligneLusztigNames( DeltigLibGetRecord( Identifier( tbl ) ) ) );

InstallMethod( DeligneLusztigNames, 
    "IsString",
    [ IsString ],
    str -> DeligneLusztigNames( CharacterTable( str ) ) );

InstallMethod( DeligneLusztigNames, 
    "IsRecord",
    [ IsRecord ],
    function( record )
    local tbl, dlnames, warnings, elem, tbl0, dlnamestbl0, pos, chi, 
    unipotcharstbl0, map, projchars, position;

    if not IsBound( record.labeling )
       and not IsBound( record.labelingfrom ) then
      record:= DeltigLibGetRecord( record );
    fi;
    tbl:= CharacterTable( record.identifier );
    dlnames:= [  ];
    if IsBound( record.labeling ) then  
      ####Labeling from Library for adjoint groups
      warnings:= [  ];
      for elem in record.labeling do
        dlnames[ elem.index ]:= elem.label;
        if IsBound( elem.warn ) then
          Add( warnings, elem.label );
        fi;
      od;
      if not warnings = [  ] then
        Display( "Labeling is not unique:" );
        for elem in warnings do
          Display( elem );
        od;
      fi;
    elif IsBound( record.labelingfrom ) and "simple" in record.isot then
      ####Labeling from adjoint groups for simple groups
      tbl0:= CharacterTable( record.labelingfrom );
      dlnamestbl0:= DeligneLusztigNames( tbl0 );
      for elem in dlnamestbl0 do
        pos:= Position( dlnamestbl0, elem );
        chi:= RestrictedClassFunction( Irr( tbl0 )[ pos ], tbl );
        dlnames[ Position( Irr( tbl ), chi ) ]:= elem;
      od;
    elif IsBound( record.labelingfrom ) and "sc" in record.isot then
      ####Labeling from simple groups for simply connected groups
      tbl0:= CharacterTable( record.labelingfrom );
      dlnamestbl0:= DeligneLusztigNames( tbl0 );
      unipotcharstbl0:= ShallowCopy( dlnamestbl0 );
      for elem in dlnamestbl0 do
        unipotcharstbl0[ Position( dlnamestbl0, elem ) ]:= 
            UnipotentCharacter( tbl0, elem );
      od;
      for elem in ProjectivesInfo( tbl0 ) do
        if elem.name = Identifier( tbl ) then
          map:= elem.map;
        fi;
      od;
      projchars:= List( Irr( tbl ), chi -> chi{ map } );
      for elem in dlnamestbl0 do
        pos:= Position( dlnamestbl0, elem );
        position:= Position( projchars, unipotcharstbl0[ pos ] );
        dlnames[ position ]:= elem;
      od;
    fi;

    SetDeligneLusztigNames( tbl, dlnames );
    for elem in dlnames do
      SetDeligneLusztigName( Irr( tbl )[ Position( dlnames, elem ) ], elem );
    od;

    return dlnames;
    end );


#############################################################################
##
#M  DeligneLusztigName( <chi> )
##
InstallMethod( DeligneLusztigName,
    [ IsCharacter ],
    function( chi )
    DeligneLusztigNames( UnderlyingCharacterTable( chi ) );
    if not HasDeligneLusztigName( chi ) then
      return fail;
    fi;
    return DeligneLusztigName( chi );
    end );


#############################################################################
##
#M  UnipotentCharacter( <tbl>, <label> )
##
InstallMethod( UnipotentCharacter,
    [ IsCharacterTable, IsObject ],
    function( tbl, label )
    local names;

    names:= DeligneLusztigNames( tbl );
    if names <> fail and label in names then
      return Irr( tbl )[ Position( names, label ) ];
    fi;
    return fail;
    end );


#############################################################################
##
#E

