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
 # This file is an implementation for UpperTriangularMatrices as MatObjs.
 # It stores matrices as a dense flat list.

 ############################################################################
 ############################################################################
 # Matrices:
 ############################################################################
 ############################################################################


 ############################################################################
 # Constructors:
 ############################################################################

 # This method is to construct a new matrix object 

 InstallMethod( NewMatrix,
   "for IsUpperTriangularMatrixRep, a ring, an int, and a list",
   [ IsUpperTriangularMatrixRep, IsRing, IsInt, IsList ],
   function( filter, basedomain, nrcols, list_in )
     local obj, filter2, list, rowindex, colindex, zeroEle;

     zeroEle := Zero(basedomain);

     # If applicable then replace a nested list 'list_in' by a flat list 'list'.
     if Length(list_in) > 0 and (IsVectorObj(list_in[1]) or IsList(list_in[1])) then
         list := [];
         if Length(list_in) <> nrcols then
             Error( "NewMatrix: Matrix is not square." );
         fi;
         for rowindex in [1..Length(list_in)] do 
             if Length(list_in[rowindex]) <> nrcols then
                 Error( "NewMatrix: Each row must have nrcols entries." );
             fi;
	     for colindex in [1..rowindex-1] do
		 if list_in[rowindex][colindex] <> zeroEle then
		      Error( "NewMatrix: Matrix is not an upper triangular matrix." );
		 fi;
	     od;
             for colindex in [rowindex..nrcols] do 
                 list[(-rowindex*rowindex+rowindex)/2+nrcols*(rowindex-1) + colindex] := list_in[rowindex][colindex];
             od;
         od;
     else
         list := [];
         if Length(list_in) <> nrcols*nrcols then
             Error( "NewMatrix: Matrix is not square." );
         fi;
         if Length(list_in) mod nrcols <> 0 then 
             Error( "NewMatrix: Length of list must be a multiple of ncols." );
         fi;
         for rowindex in [1..Length(list_in)/nrcols] do 
	         for colindex in [1..rowindex-1] do
                if list_in[(rowindex-1)*nrcols + colindex] <> zeroEle then
                      Error( "NewMatrix: Matrix is not an upper triangular matrix." );
                fi;
             od;
             for colindex in [rowindex..nrcols] do
                 list[(-rowindex*rowindex+rowindex)/2+nrcols*(rowindex-1) + colindex] := list_in[(rowindex-1)*nrcols + colindex];
             od;
	    od;
     fi;

     obj := [basedomain,nrcols,list];
     filter2 := IsUpperTriangularMatrixRep and IsMutable;
     if HasCanEasilyCompareElements(Representative(basedomain)) and
        CanEasilyCompareElements(Representative(basedomain)) then
         filter2 := filter2 and CanEasilyCompareElements;
     fi;
     Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                        filter2),  obj);
     return obj;
end );

 InstallMethod( NewZeroMatrix,
   "for IsUpperTriangularMatrixRep, a ring, and two ints",
   [ IsUpperTriangularMatrixRep, IsRing, IsInt, IsInt ],
   function( filter, basedomain, nr_rows, nr_cols )
     local obj,filter2,list;
     if nr_rows <> nr_cols then
         Error( "NewZeroMatrix: Matrix is not square." );
     fi;
     list := Zero(basedomain)*[1..nr_cols*(nr_cols+1)/2];
     obj := [basedomain,nr_cols,list];
     Objectify( NewType(CollectionsFamily(FamilyObj(basedomain)),
                        filter and IsMutable), obj );
     return obj;
 end );

 InstallMethod( NewIdentityMatrix,
   "for IsUpperTriangularMatrixRep, a ring, and an int",
   [ IsUpperTriangularMatrixRep, IsRing, IsInt ],
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
 InstallMethod( BaseDomain, "for a IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( m )
     return m![UPPERTRIANGULARMATREP_BDPOS];
end );

 InstallMethod( NumberRows, "for a IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( m )
     return m![UPPERTRIANGULARMATREP_NRPOS];
 end );

 InstallMethod( NumberColumns, "for a IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( m )
     return m![UPPERTRIANGULARMATREP_NRPOS];
  end );

 ############################################################################
 # A selection of list operations:
 ############################################################################

 InstallOtherMethod( \[\], "for an IsUpperTriangularMatrixRep matrix and a positive integer",
   [ IsUpperTriangularMatrixRep, IsPosInt ],
   function( mat, row )
     local index_start, index_end, vec, i;
     vec := NewZeroVector(IsPlistVectorRep,BaseDomain(mat),NrCols(mat));
     for i in [row..NrCols(mat)] do 
        vec[i] := mat[row,i];
     od;
     MakeImmutable(vec);
     return vec;
  end );

 InstallMethod( ShallowCopy, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( m )
     local res;
     res := Objectify(TypeObj(m),[m![UPPERTRIANGULARMATREP_BDPOS],m![UPPERTRIANGULARMATREP_NRPOS],
                                  ShallowCopy(m![UPPERTRIANGULARMATREP_ELSPOS])]);
     if not IsMutable(m) then
         SetFilterObj(res,IsMutable);
     fi;
     #T 'ShallowCopy' MUST return a mutable object
     #T if such an object exists at all!
     return res;
  end );

 InstallMethod( PostMakeImmutable, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( m )
     MakeImmutable( m![UPPERTRIANGULARMATREP_ELSPOS] );
 end );

 InstallMethod( MutableCopyMat, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( m )
     local l,res;
     l := List(m![UPPERTRIANGULARMATREP_ELSPOS],ShallowCopy);
     res := Objectify(TypeObj(m),[m![UPPERTRIANGULARMATREP_BDPOS],m![UPPERTRIANGULARMATREP_NRPOS],l]);
     if not IsMutable(m) then
         SetFilterObj(res,IsMutable);
     fi;
     return res;
end);

InstallMethod( Unpack, "for an IsUpperTriangularMatrixRep matrix",
[ IsUpperTriangularMatrixRep ],
function( mat )
    local numberRows, st, row, rowindex, colindex, zeroEle, rowStart;

    numberRows := NrRows(mat);
    st := [1..numberRows];
    zeroEle := Zero(BaseDomain(mat));
    for rowindex in [1..numberRows] do
         row := ListWithIdenticalEntries(numberRows, zeroEle);
         rowStart := (-rowindex*rowindex+rowindex)/2+numberRows*(rowindex-1);
         # copy all (i.e. step 1) the entries from rowStart+rowindex to rowStart+numberRows in the matrix list to rowindex to numberRows in row
         CopyListEntries(mat![UPPERTRIANGULARMATREP_ELSPOS], rowStart+rowindex, 1, row, rowindex, 1, numberRows-rowindex+1);
         st[rowindex] := row;
    od;

    return st;
end );

 InstallMethod( ExtractSubMatrix, "for an IsUpperTriangularMatrixRep matrix, and two lists",
   [ IsUpperTriangularMatrixRep, IsList, IsList ],
   function( mat, rows, cols )
     local row,col,list,hasTriangularForm,zeroEle,ele;
     list := [];
     zeroEle := Zero(BaseDomain(mat));
     hasTriangularForm := true;
     for row in [1..Length(rows)] do
       for col in [1..Length(cols)] do 
            if cols[col] < rows[row] then
                list[(row - 1)*Length(cols)+col] :=  zeroEle;
            else
                ele := mat[row,col];
                list[(row - 1)*Length(cols)+col] :=  ele;
                if (col < row) and (ele <> zeroEle) then
                    hasTriangularForm := false;
                fi;
            fi;
       od;
     od;
     if Length(rows) = Length(cols) and hasTriangularForm then
        for row in Reversed([1..Length(rows)]) do
            for col in Reversed([1..Length(cols)]) do 
                if col < row then
                    Remove(list,(row - 1)*Length(cols)+col);
                fi;
            od;
        od;
        return Objectify(TypeObj(mat),[mat![UPPERTRIANGULARMATREP_BDPOS],Length(rows),list]);
     else
        # Actually we want IsFListRep but thats not here yet.
        # return NewMatrix(IsPlistMatrixRep, mat![UPPERTRIANGULARMATREP_BDPOS],Length(rows),Length(cols),list);
        return NewMatrix(IsPlistMatrixRep, mat![UPPERTRIANGULARMATREP_BDPOS],Length(rows),list);
     fi;
  end );

 InstallMethod( CopySubMatrix, "for two plist matrices and four lists",
   [ IsUpperTriangularMatrixRep, IsUpperTriangularMatrixRep and IsMutable,
     IsList, IsList, IsList, IsList ],
   function( m, n, srcrows, dstrows, srccols, dstcols )
     local i,j,zeroEle;
     zeroEle := Zero(BaseDomain(m));
     # This eventually should go into the kernel without creating
     # an intermediate object:
     for i in [1..Length(srcrows)] do
       for j in [1..Length(srccols)] do
            if srccols[j] < srcrows[i] then
                SetMatElm(n,dstrows[i],dstcols[j],zeroEle);
            else
                SetMatElm(n,dstrows[i],dstcols[j], m[srcrows[i],srccols[j]]);
            fi;
       od;
     od;
 end );

 InstallMethod( MatElm, "for an IsUpperTriangularMatrixRep matrix and two positions",
   [ IsUpperTriangularMatrixRep, IsPosInt, IsPosInt ],
   function( mat, row, col )
    if col < row then
        return Zero(BaseDomain(mat));
    else
        return mat![UPPERTRIANGULARMATREP_ELSPOS][(-row*row+row)/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(row-1) + col];
    fi;
 end );

 InstallMethod( SetMatElm, "for an IsUpperTriangularMatrixRep matrix, two positions, and an object",
   [ IsUpperTriangularMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
   function( mat, row, col, obj )
    if col < row then
        if (obj <> Zero(BaseDomain(mat))) then
            Error("SetMatElm: This is not possible for UpperTriangularMatrices");
        fi;
    else
        if not(obj in BaseDomain(mat)) then
            Error("SetMatElm: obj not contained in base domain");
        else
            mat![UPPERTRIANGULARMATREP_ELSPOS][(-row*row+row)/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(row-1) + col] := obj;
        fi;
    fi;
 end );



 ############################################################################
 # Printing and viewing methods:
 ############################################################################

# not better than the generic interpretation
# InstallMethod( ViewObj, "for an IsUpperTriangularMatrixRep matrix", [ IsUpperTriangularMatrixRep ],
#   function( mat )
#     Print("<");
#     if not IsMutable(mat) then Print("immutable "); fi;
#     Print(NumberRows(mat),"x",NumberColumns(mat),"-matrix over ",BaseDomain(mat),">");
#       end );

# not better than the generic interpretation
# InstallMethod( PrintObj, "for an IsUpperTriangularMatrixRep matrix", [ IsUpperTriangularMatrixRep ],
#   function( mat )
#     Print("NewMatrix(IsUpperTriangularMatrixRep");
#     if IsFinite(mat![UPPERTRIANGULARMATREP_BDPOS]) and IsField(mat![UPPERTRIANGULARMATREP_BDPOS]) then
#         Print(",GF(",Size(mat![UPPERTRIANGULARMATREP_BDPOS]),"),");
#             else
#         Print(",",String(mat![UPPERTRIANGULARMATREP_BDPOS]),",");
#     fi;
#     Print(mat![UPPERTRIANGULARMATREP_NRPOS],",",Unpack(mat),")");
#      end );

 InstallMethod( Display, "for an IsUpperTriangularMatrixRep matrix", [ IsUpperTriangularMatrixRep ],
   function( mat )
     local i,j,m,numberCols,numberRows,baseDom,zeroEle;
     numberRows := NrRows(mat);
     numberCols := NrCols(mat);
     baseDom := BaseDomain(mat);
     zeroEle := Zero(baseDom);
     Print("<");
     if not IsMutable(mat) then Print("immutable "); fi;
     Print(numberRows,"x",numberCols,"-matrix over ",baseDom,":\n");
     if IsFinite(baseDom) then 
       m := Unpack(mat);
       Display(m);
     else 
       Print("[");
       for i in [1..numberRows] do
           for j in [1..numberCols] do
               if j = 1 then
                   Print("[");
               else
                   Print(" ");
               fi;
               Print(mat[i,j]);
           od;
           Print("]\n");
       od;
       Print("]");
     fi;
     Print(">\n");
end );

# not better than the generic interpretation
# InstallMethod( String, "for plist matrix", [ IsUpperTriangularMatrixRep ],
#   function( m )
#     local st;
#     st := "NewMatrix(IsUpperTriangularMatrixRep";
#     Add(st,',');
#     if IsFinite(m![UPPERTRIANGULARMATREP_BDPOS]) and IsField(m![UPPERTRIANGULARMATREP_BDPOS]) then
#         Append(st,"GF(");
#         Append(st,String(Size(m![UPPERTRIANGULARMATREP_BDPOS])));
#         Append(st,"),");
#     else
#         Append(st,String(m![UPPERTRIANGULARMATREP_BDPOS]));
#         Append(st,",");
#     fi;
#     Append(st,String(NumberColumns(m)));
#     Add(st,',');
#     Append(st,String(Unpack(m)));
#     Add(st,')');
#     return st;
#   end );

############################################################################
 # Arithmetical operations:
 ############################################################################

 InstallMethod( \+, "for two IsUpperTriangularMatrixRep matrices",
   [ IsUpperTriangularMatrixRep, IsUpperTriangularMatrixRep ],
   function( a, b )
     local ty;
     if not IsMutable(a) and IsMutable(b) then
         ty := TypeObj(b);
     else
         ty := TypeObj(a);
     fi;
     if not a![UPPERTRIANGULARMATREP_NRPOS] = b![UPPERTRIANGULARMATREP_NRPOS] then
         ErrorNoReturn("\\+: Matrices do not fit together");
     fi;
     if not IsIdenticalObj(a![UPPERTRIANGULARMATREP_BDPOS],b![UPPERTRIANGULARMATREP_BDPOS]) then
         ErrorNoReturn("\\+: Matrices not over same base domain");
     fi;
     return Objectify(ty,[a![UPPERTRIANGULARMATREP_BDPOS],a![UPPERTRIANGULARMATREP_NRPOS],
     SUM_LIST_LIST_DEFAULT(a![UPPERTRIANGULARMATREP_ELSPOS],b![UPPERTRIANGULARMATREP_ELSPOS])]);
 end );

 InstallMethod( \-, "for two IsUpperTriangularMatrixRep matrices",
   [ IsUpperTriangularMatrixRep, IsUpperTriangularMatrixRep ],
   function( a, b )
     local ty;
     if not IsMutable(a) and IsMutable(b) then
         ty := TypeObj(b);
    else
         ty := TypeObj(a);
     fi;
     if not a![UPPERTRIANGULARMATREP_NRPOS] = b![UPPERTRIANGULARMATREP_NRPOS] then
         ErrorNoReturn("\\-: Matrices do not fit together");
     fi;
     if not IsIdenticalObj(a![UPPERTRIANGULARMATREP_BDPOS],b![UPPERTRIANGULARMATREP_BDPOS]) then
         ErrorNoReturn("\\-: Matrices not over same base domain");
     fi;
     return Objectify(ty,[a![UPPERTRIANGULARMATREP_BDPOS],a![UPPERTRIANGULARMATREP_NRPOS],
     DIFF_LIST_LIST_DEFAULT(a![UPPERTRIANGULARMATREP_ELSPOS],b![UPPERTRIANGULARMATREP_ELSPOS])]);
 end );

 #todo: write a kernel function for this (we're currently slower than the traditional lists-of-lists function)
 InstallMethod( \*, "for two IsUpperTriangularMatrixRep matrices",
   [ IsUpperTriangularMatrixRep, IsUpperTriangularMatrixRep ],
   function( a, b )
     # Here we do full checking since it is rather cheap!
     local row,col,l,ty,v,w,i,rowStart,sum;
     if not IsMutable(a) and IsMutable(b) then
         ty := TypeObj(b);
   else
         ty := TypeObj(a);
     fi;
     if not a![UPPERTRIANGULARMATREP_NRPOS] = b![UPPERTRIANGULARMATREP_NRPOS] then
         ErrorNoReturn("\\*: Matrices do not fit together");
     fi;
     if not IsIdenticalObj(a![UPPERTRIANGULARMATREP_BDPOS],b![UPPERTRIANGULARMATREP_BDPOS]) then
         ErrorNoReturn("\\*: Matrices not over same base domain");
     fi;
    # l is the resulting list of entries of the product in row-major formit is
     # constructed by computing the rows one after the other and then setting the
     # respective entries of l.
     l := ListWithIdenticalEntries((a![UPPERTRIANGULARMATREP_NRPOS]*(a![UPPERTRIANGULARMATREP_NRPOS]+1))/2,0);
   # each row of the product is computed 
     for row in [1..a![UPPERTRIANGULARMATREP_NRPOS]] do
        rowStart := (-row*row+row)/2+a![UPPERTRIANGULARMATREP_NRPOS]*(row-1);
        for col in [row..a![UPPERTRIANGULARMATREP_NRPOS]] do
            sum := Zero(a![UPPERTRIANGULARMATREP_BDPOS]);
            for i in [row..col] do
                sum := sum + a[row,i] * b[i,col];
            od;
            l[rowStart + col] := sum;
        od;
     od;
     if not IsMutable(a) and not IsMutable(b) then
         MakeImmutable(l);
     fi;
     return Objectify( ty, [a![UPPERTRIANGULARMATREP_BDPOS],a![UPPERTRIANGULARMATREP_NRPOS],l] );
 end );

   InstallMethod( ConstructingFilter, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( mat )
     return IsUpperTriangularMatrixRep;
  end );

   InstallMethod( \=, "for two IsUpperTriangularMatrixRep matrices",
   [ IsUpperTriangularMatrixRep, IsUpperTriangularMatrixRep ],
   function( a, b )
     return a![UPPERTRIANGULARMATREP_BDPOS] = b![UPPERTRIANGULARMATREP_BDPOS] and a![UPPERTRIANGULARMATREP_NRPOS] = b![UPPERTRIANGULARMATREP_NRPOS] and EQ_LIST_LIST_DEFAULT(a![UPPERTRIANGULARMATREP_ELSPOS],b![UPPERTRIANGULARMATREP_ELSPOS]);
  end );

   InstallMethod( \<, "for two IsUpperTriangularMatrixRep matrices",
   [ IsUpperTriangularMatrixRep, IsUpperTriangularMatrixRep ],
   function( a, b )
     return LT_LIST_LIST_DEFAULT(a![UPPERTRIANGULARMATREP_ELSPOS],b![UPPERTRIANGULARMATREP_ELSPOS]);
  end );

   # The following methods need not ne implemented for any specific MatrixRep as
   # default methods for all MatrixObjects exist
   InstallMethod( AdditiveInverseSameMutability, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( mat )
     local l;
     l := List(mat![UPPERTRIANGULARMATREP_ELSPOS],AdditiveInverseSameMutability);
     if not IsMutable(mat) then
         MakeImmutable(l);
     fi;
     return Objectify( TypeObj(mat), [mat![UPPERTRIANGULARMATREP_BDPOS],mat![UPPERTRIANGULARMATREP_NRPOS],l] );
  end );

   InstallMethod( AdditiveInverseImmutable, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( mat )
     local l,res;
     l := List(mat![UPPERTRIANGULARMATREP_ELSPOS],AdditiveInverseImmutable);
     res := Objectify( TypeObj(mat), [mat![UPPERTRIANGULARMATREP_BDPOS],mat![UPPERTRIANGULARMATREP_NRPOS],l] );
     MakeImmutable(res);
     return res;
  end );

 InstallMethod( AdditiveInverseMutable, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( mat )
     local l,res;
     l := List(mat![UPPERTRIANGULARMATREP_ELSPOS],AdditiveInverseMutable);
     res := Objectify( TypeObj(mat), [mat![UPPERTRIANGULARMATREP_BDPOS],mat![UPPERTRIANGULARMATREP_NRPOS],l] );
     if not IsMutable(mat) then
         SetFilterObj(res,IsMutable);
     fi;
     return res;
 end );

InstallMethod( InverseMutable, "for an IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( mat )
     local i,n,ni,row,col;
     for i in [1..mat![UPPERTRIANGULARMATREP_NRPOS]] do
        if mat[i,i] = Zero(mat![UPPERTRIANGULARMATREP_BDPOS]) or not(IsUnit(mat![UPPERTRIANGULARMATREP_BDPOS],mat[i,i])) then
            Error("InverseMUtable: Matrix is not invertible.");
        fi;
     od;

   # Make a plain list of lists:
     n := Unpack(mat);
     ni := n^(-1);
     return NewMatrix(IsUpperTriangularMatrixRep,mat![UPPERTRIANGULARMATREP_BDPOS],mat![UPPERTRIANGULARMATREP_NRPOS],ni);
  end );
