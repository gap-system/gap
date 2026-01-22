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
# for matrix objects. This is intended for testing and as an example.
# The assertions in the code can help catch errors. It it up to the programmer
# whether or not wrong inputs are always caught, never caught or only handled
# via assertions as is done here. 

InstallMethod( NewMatrix,
  "for IsMinimalExampleMatrixRep, a ring, an int, and a list",
  [ IsMinimalExampleMatrixRep, IsRing, IsInt, IsList ],
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
                Assert(2, list_in[rowindex][colindex] in basedomain); 
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
    filter2 := IsMinimalExampleMatrixRep and IsMutable;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter2 := filter2 and CanEasilyCompareElements;
    fi;
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter2),  obj);
    return obj;
end );

InstallMethod( BaseDomain, "for a minimal example matrix rep",
  [ IsMinimalExampleMatrixRep ],
  function( m )
    return m![MINREP_BDPOS];
  end );

InstallMethod( NumberRows, "for a minimal example matrix rep",
  [ IsMinimalExampleMatrixRep ],
  function( m )
    return m![MINREP_NRPOS];
  end );

InstallMethod( NumberColumns, "for a minimal example matrix rep",
  [ IsMinimalExampleMatrixRep ],
  function( m )
    return m![MINREP_NCPOS];
  end );

InstallMethod( MatElm, "for an minimal example matrix rep and two positions",
  [ IsMinimalExampleMatrixRep, IsPosInt, IsPosInt ],
  function( mat, row, col )
    Assert(2, 1 <= row and row <= mat![MINREP_NRPOS]);
    Assert(2, 1 <= col and col <= mat![MINREP_NCPOS]);
    return mat![MINREP_ELSPOS][(row-1)*mat![MINREP_NCPOS]+col];
end );

InstallMethod( SetMatElm, "for an minimal example matrix rep, two positions, and an object",
  [ IsMinimalExampleMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
  function( mat, row, col, obj )
    Assert(2, 1 <= row and row <= mat![MINREP_NRPOS]);
    Assert(2, 1 <= col and col <= mat![MINREP_NCPOS]);
    Assert(2, obj in mat![MINREP_BDPOS]);
    mat![MINREP_ELSPOS][(row-1)*mat![MINREP_NCPOS]+col] := obj;
end );

InstallMethod( \<, "for two minimal example matrices",
  [ IsMinimalExampleMatrixRep, IsMinimalExampleMatrixRep ],
  function( a, b )
    return LT_LIST_LIST_DEFAULT(a![MINREP_ELSPOS],b![MINREP_ELSPOS]);
end );

InstallMethod( ConstructingFilter, "for a minimal example matrix rep",
  [ IsMinimalExampleMatrixRep ],
  function( mat )
    return IsMinimalExampleMatrixRep;
end );

InstallMethod( CompatibleVectorFilter, [ IsMinimalExampleMatrixRep ],
  M -> IsPlistVectorRep );
  