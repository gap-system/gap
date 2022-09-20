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
# This file is a sample implementation for new style vectors and matrices.
# It stores matrices as a dense flat list.
#

############################################################################
############################################################################
# Matrices:
############################################################################
############################################################################


############################################################################
# Constructors:
############################################################################

InstallMethod( NewMatrix,
  "for IsFlistMatrixRep, a ring, an int, and a list",
  [ IsFlistMatrixRep, IsRing, IsInt, IsList ],
  function( filter, basedomain, nrcols, list_in )
    local obj, filter2, list, rowindex, colindex;

    # If applicable then replace a nested list 'list' by a flat list.
    if Length(list_in) > 0 and (IsVectorObj(list_in[1]) or IsList(list_in[1])) then
        list := [];
        for rowindex in [1..Length(list_in)] do 
            if Length(list_in[i]) <> nrcols then
                Error( "NewMatrix: Each row must have ncols entries." );
            fi;
            for colindex in [1..nrcols] do 
                list[rowindex*nrcols + colindex] := list_in[rowindex][colindex];
            od;
        od;
    else
        if Length(list_in) mod nrcols <> 0 then 
            Error( "NewMatrix: Length of list must be a multiple of ncols." );
        fi;
        list := list_in;
    fi;

    #e := NewVector(IsPlistVectorRep, basedomain, []);
    #m := [basedomain,e,rl,m];
    obj := [basedomain,Length(list)/nrcols,nrcols,list];
    filter2 := IsFlistMatrixRep and IsMutable;
    if HasCanEasilyCompareElements(Representative(basedomain)) and
       CanEasilyCompareElements(Representative(basedomain)) then
        filter2 := filter2 and CanEasilyCompareElements;
    fi;
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter2),  obj);
    return obj;
  end );

InstallMethod( NewZeroMatrix,
  "for IsFlistMatrixRep, a ring, and two ints",
  [ IsFlistMatrixRep, IsRing, IsInt, IsInt ],
  function( filter, basedomain, nr_rows, nr_cols )
    local obj,filter2,list;
    list := Zero(basedomain)*[1..nr_rows*nr_cols];
    m := [basedomain,nr_rows,nr_cols,list];
    Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                       filter and IsMutable), obj );
    return obj;
  end );

InstallMethod( NewIdentityMatrix,
  "for IsFlistMatrixRep, a ring, and an int",
  [ IsFlistMatrixRep, IsRing, IsInt ],
  function( filter, basedomain, dim )
    local mat, one, i;
    mat := NewZeroMatrix(filter, basedomain, dim, dim);
    one := One(basedomain);
    for i in [1..dim] do
        mat[i,i] := one;
    od;
    return mat;
  end );

############################################################################
# The basic attributes:
############################################################################

# BaseDomain, NrRows, NrCols can be directly obatined from the object
InstallMethod( BaseDomain, "for a flist matrix",
  [ IsFlistMatrixRep ],
  function( m )
    return m![FLISTREP_BDPOS];
  end );

InstallMethod( NumberRows, "for a flist matrix",
  [ IsFlistMatrixRep ],
  function( m )
    return m![FLISTREP_NRPOS];
  end );

InstallMethod( NumberColumns, "for a flist matrix",
  [ IsFlistMatrixRep ],
  function( m )
    return m![FLISTREP_NCPOS];
  end );

InstallMethod( DimensionsMat, "for a flist matrix",
  [ IsFlistMatrixRep ],
  function( m )
    return [m![FLISTREP_NRPOS],m![FLISTREP_NCPOS]];
  end );