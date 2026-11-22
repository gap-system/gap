#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

############################################################################
#
# This file is a minimal implementation for new style vectors and matrices.
# It stores matrices as a dense flat list.
# This implementation implements only the methods required by the specification
# for matrix objects. This is intended for testing.

InstallMethod( NewMatrix,
  "for IsMinimalBROKENMatrixRep, a ring, an int, and a list",
  [ IsMinimalBROKENMatrixRep, IsRing, IsInt, IsList ],
  function( filter, basedomain, nrcols, list_in )
    local obj, filter2, list, rowindex, colindex;

    # If applicable then replace a nested list 'list_in' by a flat list 'list'.
    if Length(list_in) > 0 and (IsVectorObj(list_in[1]) or IsList(list_in[1])) then
        list := [];
        for rowindex in [1..Length(list_in)] do 
            if Length(list_in[rowindex]) <> nrcols then
                Error( "NewMatrix: Each row must have nrcols entries." );
            fi;
            for colindex in [1..nrcols] do 
                list[(rowindex-1)*nrcols + colindex] := list_in[rowindex][colindex];
            od;
        od;
    else
        if Length(list_in) mod nrcols <> 0 then 
            Error( "NewMatrix: Length of list must be a multiple of ncols." );
        fi;
        list := list_in;
    fi;

    obj := [basedomain,Length(list)/nrcols,nrcols,list];
    filter2 := IsMinimalBROKENMatrixRep and IsMutable;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter2 := filter2 and CanEasilyCompareElements;
    fi;
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter2),  obj);
    return obj;
end );

InstallMethod( BaseDomain, "for a minimal example matrix rep",
  [ IsMinimalBROKENMatrixRep ],
  function( m )
    return GF(3);#m![MINREP_BDPOS];
  end );

InstallMethod( NumberRows, "for a minimal example matrix rep",
  [ IsMinimalBROKENMatrixRep ],
  function( m )
    return m![MINREP_NRPOS]-1;
  end );

InstallMethod( NumberColumns, "for a minimal example matrix rep",
  [ IsMinimalBROKENMatrixRep ],
  function( m )
    return m![MINREP_NCPOS]+1;
  end );

InstallMethod( MatElm, "for an minimal example matrix rep and two positions",
  [ IsMinimalBROKENMatrixRep, IsPosInt, IsPosInt ],
  function( mat, row, col )
    return mat![MINREP_ELSPOS][(row-1)*mat![MINREP_NCPOS]+col-1];
end );

InstallMethod( SetMatElm, "for an minimal example matrix rep, two positions, and an object",
  [ IsMinimalBROKENMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
  function( mat, row, col, obj )
    mat![MINREP_ELSPOS][(row-1)*mat![MINREP_NCPOS]+col] := Zero(mat![MINREP_BDPOS]);
end );

InstallMethod( \<, "for two minimal example matrices",
  [ IsMinimalBROKENMatrixRep, IsMinimalBROKENMatrixRep ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![MINREP_ELSPOS],b![MINREP_ELSPOS]);
end );

InstallMethod( ConstructingFilter, "for a minimal example matrix rep",
  [ IsMinimalBROKENMatrixRep ],
  function( mat )
    return IsMinimalExampleMatrixRep;
end );

InstallMethod( CompatibleVectorFilter, [ IsMinimalBROKENMatrixRep ],
  M -> IsPlistVectorRep );
  