#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Martin Schönert, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains
##  1. the design of families of general mappings

#############################################################################
##
#M  FamiliesOfGeneralMappingsAndRanges( <Fam> )
##
InstallMethod( FamiliesOfGeneralMappingsAndRanges,
    "for a family (return empty list)",
    true,
    [ IsFamily ], 0,
    function(fam)
  return LockAndMigrateObj(WeakPointerObj( [] ), GENERAL_MAPPING_REGION);
end);

#############################################################################
##
#F  GeneralMappingsFamily( <famsourceelms>, <famrangeelms> )
##
InstallGlobalFunction( GeneralMappingsFamily, function( FS, FR )

    local info, i, len, entry, Fam, freepos;

  atomic readwrite GENERAL_MAPPING_REGION do
    # Check whether this family was already constructed.
    info:= FamiliesOfGeneralMappingsAndRanges( FS );
    len:= LengthWPObj( info );
    for i in [ 1.. len+1 ] do
      entry:=ElmWPObj( info, i );
      if entry=fail then
        if not IsBound( freepos ) then
          freepos:= i;
        fi;
      elif IsIdenticalObj( FamilyRange(entry), FR ) then
        return entry;
      fi;
    od;

    # Construct the family.
    if CanEasilyCompareElementsFamily(FR)
       and CanEasilyCompareElementsFamily(FS) then
      Fam:= NewFamily( "GeneralMappingsFamily", IsGeneralMapping ,
                       CanEasilyCompareElements,
                       CanEasilyCompareElements);
    else
      Fam:= NewFamily( "GeneralMappingsFamily", IsGeneralMapping );
    fi;
    SetFamilyRange(  Fam, FR );
    SetFamilySource( Fam, FS );

    # Store the family in free spot.
    SetElmWPObj( info, freepos, Fam );

    # Return the family.
    return Fam;
  od;
end );

