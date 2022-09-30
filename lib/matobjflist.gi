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
    obj := [basedomain,nr_rows,nr_cols,list];
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

############################################################################
# Representation preserving constructors:
############################################################################

# Why are there extra implementations for these in matobjplist.gi?

############################################################################
# A selection of list operations:
############################################################################

InstallOtherMethod( \[\], "for an flist matrix and a positive integer",
#T Once the declaration of '\[\]' for 'IsMatrixObj' disappears,
#T we can use 'InstallMethod'.
  [ IsFlistMatrixRep, IsPosInt ],
  function( mat, row )
  # could this cause problems if some entries in the vector are not bound?
    local index_start, index_end;
    index_start := (row-1)*mat![FLISTREP_NCPOS] + 1;
    index_end := index_start + mat![FLISTREP_NCPOS];
    return NewVector(IsPlistVectorRep,mat![FLISTREP_BDPOS],mat![FLISTREP_ELSPOS]{[index_start..index_end]});
  end );

# Commenting out... this results in a weird error I don't understand. Must be
# something weird with filters and stuff.
#InstallMethod( \[\]\:\=,
#  "for an flist matrix, a positive integer, and a plist vector",
#  [ IsFlistMatrixRep and IsMutable, IsPosInt, IsPlistVectorRep ],
#  function( mat, row, vec )
#    local col;
#    if Length(vec) <> mat![FLISTREP_NCPOS] then 
#      ErrorNoReturn("The length of the vector must be equal to the number of columns of the matrix.");
#    fi;
#    for col in [1..mat![FLISTREP_NCPOS]] do
#      mat![FLISTREP_ELSPOS][(row-1)*mat![FLISTREP_NCPOS] + col] := vec[col];
#    od;
#  end );

# Could be implemented later
#InstallMethod( \{\}\:\=, "for an flist matrix, a list, and a plist matrix",
#  [ IsFlistMatrixRep and IsMutable, IsList,
#    IsFlistMatrixRep ],
#  function( m, pp, n )
#    m![FLISTREP_ELSPOS]{pp} := n![FLISTREP_ELSPOS];
#  end );

# Same as above: weird error
#InstallMethod( Append, "for two flist matrices",
#  [ IsFlistMatrixRep and IsMutable, IsFlistMatrixRep ],
#  function( m, n )
#    if m![FLISTREP_NCPOS] <> n![FLISTREP_NCPOS] then 
#      ErrorNoReturn("The number of columns must be equal.");
#    fi;
#    if m![FLISTREP_BDPOS] <> n![FLISTREP_BDPOS] then 
#      Error("The base domains must be equal.");
#    fi;
#    Append(m![FLISTREP_ELSPOS],n![FLISTREP_ELSPOS]);
#    m![FLISTREP_NRPOS] := m![FLISTREP_NRPOS] + n![FLISTREP_NRPOS];
#  end );

InstallMethod( ShallowCopy, "for an flist matrix",
  [ IsFlistMatrixRep ],
  function( m )
    local res;
    res := Objectify(TypeObj(m),[m![FLISTREP_BDPOS],m![FLISTREP_NRPOS],m![FLISTREP_NCPOS],
                                 ShallowCopy(m![FLISTREP_ELSPOS])]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
#T 'ShallowCopy' MUST return a mutable object
#T if such an object exists at all!
    return res;
  end );

InstallMethod( PostMakeImmutable, "for an flist matrix",
  [ IsFlistMatrixRep ],
  function( m )
    MakeImmutable( m![FLISTREP_ELSPOS] );
  end );

InstallMethod( MutableCopyMat, "for an flist matrix",
  [ IsFlistMatrixRep ],
  function( m )
    local l,res;
    l := List(m![FLISTREP_ELSPOS],ShallowCopy);
    res := Objectify(TypeObj(m),[m![FLISTREP_BDPOS],m![FLISTREP_NRPOS],m![FLISTREP_NCPOS],l]);
    if not IsMutable(m) then
        SetFilterObj(res,IsMutable);
    fi;
    return res;
  end);

InstallMethod( Unpack, "for an flist matrix",
[ IsFlistMatrixRep ],
function( mat )
  return List([1..mat![FLISTREP_NRPOS]],row->ShallowCopy(mat![FLISTREP_ELSPOS]{[(row-1)*mat![FLISTREP_NCPOS]+1..row*mat![FLISTREP_NCPOS]]}));
end );

InstallMethod( ExtractSubMatrix, "for an flist matrix, and two lists",
  [ IsFlistMatrixRep, IsList, IsList ],
  function( mat, rows, cols )
    local row,col,list;
    list := [];
    for row in [1..Length(rows)] do
      for col in [1..Length(cols)] do 
        list[(row - 1)*Length(cols)+col] := mat![FLISTREP_ELSPOS][(rows[row] - 1)*mat![FLISTREP_NCPOS] + cols[col]];
      od;
    od;
    return Objectify(TypeObj(mat),[mat![FLISTREP_BDPOS],Length(rows),Length(cols),list]);
  end );

InstallMethod( CopySubMatrix, "for two plist matrices and four lists",
  [ IsFlistMatrixRep, IsFlistMatrixRep and IsMutable,
    IsList, IsList, IsList, IsList ],
  function( m, n, srcrows, dstrows, srccols, dstcols )
    local i,j;
    # This eventually should go into the kernel without creating
    # an intermediate object:
    for i in [1..Length(srcrows)] do
      for j in [1..Length(srccols)] do
          n![FLISTREP_ELSPOS][(dstrows[i]-1)*n![FLISTREP_NCPOS]+dstcols[j]] := m![FLISTREP_ELSPOS][(srcrows[i]-1)*m![FLISTREP_NCPOS]+srccols[j]];
      od;
    od;
  end );

InstallMethod( MatElm, "for an flist matrix and two positions",
  [ IsFlistMatrixRep, IsPosInt, IsPosInt ],
  function( mat, row, col )
    return mat![FLISTREP_ELSPOS][(row-1)*mat![FLISTREP_NCPOS]+col];
  end );

InstallMethod( SetMatElm, "for an flist matrix, two positions, and an object",
  [ IsFlistMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
  function( mat, row, col, obj )
    mat![FLISTREP_ELSPOS][(row-1)*mat![FLISTREP_NCPOS]+col] := obj;
  end );

############################################################################
# Printing and viewing methods:
############################################################################

InstallMethod( ViewObj, "for an flist matrix", [ IsFlistMatrixRep ],
  function( mat )
    Print("<");
    if not IsMutable(mat) then Print("immutable "); fi;
    Print(mat![FLISTREP_NRPOS],"x",mat![FLISTREP_NCPOS],"-matrix over ",mat![FLISTREP_BDPOS],">");
  end );

InstallMethod( PrintObj, "for an flist matrix", [ IsFlistMatrixRep ],
  function( mat )
    Print("NewMatrix(IsFlistMatrixRep");
    if IsFinite(mat![FLISTREP_BDPOS]) and IsField(mat![FLISTREP_BDPOS]) then
        Print(",GF(",Size(mat![FLISTREP_BDPOS]),"),");
    else
        Print(",",String(mat![FLISTREP_BDPOS]),",");
    fi;
    Print(mat![FLISTREP_NCPOS],",",Unpack(mat),")");
  end );

InstallMethod( Display, "for an flist matrix", [ IsFlistMatrixRep ],
  function( mat )
    local i,m;
    Print("<");
    if not IsMutable(mat) then Print("immutable "); fi;
    Print(Length(mat![FLISTREP_NRPOS]),"x",mat![FLISTREP_NCPOS],"-matrix over ",mat![FLISTREP_BDPOS],":\n");
    if IsFinite(mat![FLISTREP_BDPOS]) then 
      m := Unpack(mat);
      Display(m);
    else 
      Print("[");
      for i in [1..Length(mat![FLISTREP_ELSPOS])] do
          if i mod mat![FLISTREP_NCPOS] = 1 then
              Print("[");
          else
              Print(" ");
          fi;
          Print(mat![FLISTREP_ELSPOS][i]);
          if i mod mat![FLISTREP_NCPOS] = 0 then 
            Print("]\n");
          fi;
      od;
      Print("]");
    fi;
    Print(">\n");
  end );

InstallMethod( String, "for plist matrix", [ IsFlistMatrixRep ],
  function( m )
    local st;
    st := "NewMatrix(IsFlistMatrixRep";
    Add(st,',');
    if IsFinite(m![FLISTREP_BDPOS]) and IsField(m![FLISTREP_BDPOS]) then
        Append(st,"GF(");
        Append(st,String(Size(m![FLISTREP_BDPOS])));
        Append(st,"),");
    else
        Append(st,String(m![FLISTREP_BDPOS]));
        Append(st,",");
    fi;
    Append(st,String(NumberColumns(m)));
    Add(st,',');
    Append(st,String(Unpack(m)));
    Add(st,')');
    return st;
  end );

############################################################################
# Arithmetical operations:
############################################################################

InstallMethod( \+, "for two flist matrices",
  [ IsFlistMatrixRep, IsFlistMatrixRep ],
  function( a, b )
    local ty;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,[a![FLISTREP_BDPOS],a![FLISTREP_NRPOS],a![FLISTREP_NCPOS],
    SUM_LIST_LIST_DEFAULT(a![FLISTREP_ELSPOS],b![FLISTREP_ELSPOS])]);
  end );

InstallMethod( \-, "for two flist matrices",
  [ IsFlistMatrixRep, IsFlistMatrixRep ],
  function( a, b )
    local ty;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    return Objectify(ty,[a![FLISTREP_BDPOS],a![FLISTREP_NRPOS],a![FLISTREP_NCPOS],
    DIFF_LIST_LIST_DEFAULT(a![FLISTREP_ELSPOS],b![FLISTREP_ELSPOS])]);
  end );
#todo
InstallMethod( \*, "for two flist matrices",
  [ IsFlistMatrixRep, IsFlistMatrixRep ],
  function( a, b )
    # Here we do full checking since it is rather cheap!
    local i,j,l,ty,v,w;
    if not IsMutable(a) and IsMutable(b) then
        ty := TypeObj(b);
    else
        ty := TypeObj(a);
    fi;
    if not a![RLPOS] = Length(b![FLISTREP_ELSPOS]) then
        ErrorNoReturn("\\*: Matrices do not fit together");
    fi;
    if not IsIdenticalObj(a![FLISTREP_BDPOS],b![FLISTREP_BDPOS]) then
        ErrorNoReturn("\\*: Matrices not over same base domain");
    fi;
    l := ListWithIdenticalEntries(Length(a![FLISTREP_ELSPOS]),0);
    for i in [1..Length(l)] do
        if b![RLPOS] = 0 then
            l[i] := b![EMPOS];
        else
            v := a![FLISTREP_ELSPOS][i];
            w := ZeroVector(b![RLPOS],b![EMPOS]);
            for j in [1..a![RLPOS]] do
                AddRowVector(w,b![FLISTREP_ELSPOS][j],v[j]);
            od;
            l[i] := w;
        fi;
    od;
    if not IsMutable(a) and not IsMutable(b) then
        MakeImmutable(l);
    fi;
    return Objectify( ty, [a![FLISTREP_BDPOS],a![EMPOS],b![RLPOS],l] );
  end );