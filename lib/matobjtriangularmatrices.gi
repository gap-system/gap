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

 InstallMethod( DimensionsMat, "for a IsUpperTriangularMatrixRep matrix",
   [ IsUpperTriangularMatrixRep ],
   function( m )
     return [m![UPPERTRIANGULARMATREP_NRPOS],m![UPPERTRIANGULARMATREP_NRPOS]];
end );

 ############################################################################
 # Representation preserving constructors:
 ############################################################################

 # Why are there extra implementations for these in matobjplist.gi?

 ############################################################################
 # A selection of list operations:
 ############################################################################

 # note depending on your particular matrix object implementing these might not
 # make sense.

 InstallOtherMethod( \[\], "for an IsUpperTriangularMatrixRep matrix and a positive integer",
 #T Once the declaration of '\[\]' for 'IsMatrixObj' disappears,
 #T we can use 'InstallMethod'.
   [ IsUpperTriangularMatrixRep, IsPosInt ],
   function( mat, row )
   # could this cause problems if some entries in the vector are not bound?
     local index_start, index_end, vec, i;
     index_start := (row-1)*mat![UPPERTRIANGULARMATREP_NRPOS] + 1;
     index_end := index_start + mat![UPPERTRIANGULARMATREP_NRPOS];
     vec := NewZeroVector(IsPlistVectorRep,mat![UPPERTRIANGULARMATREP_BDPOS],mat![UPPERTRIANGULARMATREP_NRPOS]);
     for i in [row..mat![UPPERTRIANGULARMATREP_NRPOS]] do 
        vec[i] := mat![UPPERTRIANGULARMATREP_ELSPOS][(-row*row+row)/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(row-1) + i];
     od;
     return NewVector(IsPlistVectorRep,mat![UPPERTRIANGULARMATREP_BDPOS],List(vec));
  end );

 # Commenting out... this results in a weird error I don't understand. Must be
 # something weird with filters and stuff.
 #InstallMethod( \[\]\:\=,
 #  "for an flist matrix, a positive integer, and a plist vector",
 #  [ IsUpperTriangularMatrixRep and IsMutable, IsPosInt, IsPlistVectorRep ],
 #  function( mat, row, vec )
 #    local col;
 #    if Length(vec) <> mat![UPPERTRIANGULARMATREP_NRPOS] then 
 #      ErrorNoReturn("The length of the vector must be equal to the number of columns of the matrix.");
 #    fi;
 #    for col in [1..mat![UPPERTRIANGULARMATREP_NRPOS]] do
 #      mat![UPPERTRIANGULARMATREP_ELSPOS][(row-1)*mat![UPPERTRIANGULARMATREP_NRPOS] + col] := vec[col];
 #    od;
 #  end );

 # Could be implemented later
 #InstallMethod( \{\}\:\=, "for an flist matrix, a list, and a plist matrix",
 #  [ IsUpperTriangularMatrixRep and IsMutable, IsList,
 #    IsUpperTriangularMatrixRep ],
 #  function( m, pp, n )
 #    m![UPPERTRIANGULARMATREP_ELSPOS]{pp} := n![UPPERTRIANGULARMATREP_ELSPOS];
 #  end );

 # Same as above: weird error
 #InstallMethod( Append, "for two flist matrices",
 #  [ IsUpperTriangularMatrixRep and IsMutable, IsUpperTriangularMatrixRep ],
 #  function( m, n )
 #    if m![UPPERTRIANGULARMATREP_NRPOS] <> n![UPPERTRIANGULARMATREP_NRPOS] then 
 #      ErrorNoReturn("The number of columns must be equal.");
 #    fi;
 #    if m![UPPERTRIANGULARMATREP_BDPOS] <> n![UPPERTRIANGULARMATREP_BDPOS] then 
 #      Error("The base domains must be equal.");
 #    fi;
 #    Append(m![UPPERTRIANGULARMATREP_ELSPOS],n![UPPERTRIANGULARMATREP_ELSPOS]);
 #    m![UPPERTRIANGULARMATREP_NRPOS] := m![UPPERTRIANGULARMATREP_NRPOS] + n![UPPERTRIANGULARMATREP_NRPOS];
 #  end );

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

 # It is important to implement this method as it is used by a lot of generic methods.
# It is important to implement this method as it is used by a lot of generic methods.
InstallMethod( Unpack, "for an IsUpperTriangularMatrixRep matrix",
[ IsUpperTriangularMatrixRep ],
function( mat )
    local st, row, rowindex, colindex, zeroEle;

    st := [1..mat![UPPERTRIANGULARMATREP_NRPOS]];
    zeroEle := Zero(mat![UPPERTRIANGULARMATREP_BDPOS]);
    for rowindex in [1..mat![UPPERTRIANGULARMATREP_NRPOS]] do
         row := [1..mat![UPPERTRIANGULARMATREP_NRPOS]];
         for colindex in [1..rowindex-1] do
		    row[colindex] := zeroEle;
	     od;
         for colindex in [rowindex..mat![UPPERTRIANGULARMATREP_NRPOS]] do 
            row[colindex] := mat![UPPERTRIANGULARMATREP_ELSPOS][(-rowindex*rowindex+rowindex)/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(rowindex-1) + colindex];
         od;
         st[rowindex] := row;
    od;

    return st;
end );

 InstallMethod( ExtractSubMatrix, "for an IsUpperTriangularMatrixRep matrix, and two lists",
   [ IsUpperTriangularMatrixRep, IsList, IsList ],
   function( mat, rows, cols )
     local row,col,list,hasTriangularForm;
     list := [];
     hasTriangularForm := true;
     for row in [1..Length(rows)] do
       for col in [1..Length(cols)] do 
            if cols[col] < rows[row] then
                list[(row - 1)*Length(cols)+col] :=  Zero(mat![UPPERTRIANGULARMATREP_BDPOS]);
            else
                list[(row - 1)*Length(cols)+col] :=  mat![UPPERTRIANGULARMATREP_ELSPOS][(-rows[row]*rows[row]+rows[row])/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(rows[row]-1) + cols[col]];
                if (col < row) and (list[(row - 1)*Length(cols)+col] <> Zero(mat![UPPERTRIANGULARMATREP_BDPOS])) then
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
     local i,j;
     # This eventually should go into the kernel without creating
     # an intermediate object:
     for i in [1..Length(srcrows)] do
       for j in [1..Length(srccols)] do
            if srccols[j] < srcrows[i] then
                SetMatElm(n,dstrows[i],dstcols[j],Zero(m![UPPERTRIANGULARMATREP_BDPOS]));
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
        return Zero(mat![UPPERTRIANGULARMATREP_BDPOS]);
    else
        return mat![UPPERTRIANGULARMATREP_ELSPOS][(-row*row+row)/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(row-1) + col];
    fi;
 end );

 InstallMethod( SetMatElm, "for an IsUpperTriangularMatrixRep matrix, two positions, and an object",
   [ IsUpperTriangularMatrixRep and IsMutable, IsPosInt, IsPosInt, IsObject ],
   function( mat, row, col, obj )
    if (col < row) then
        if (obj <> Zero(mat![UPPERTRIANGULARMATREP_BDPOS])) then
            Error("SetMatElm: This is not possible for UpperTriangularMatrices");
        fi;
    else
        if not(obj in mat![UPPERTRIANGULARMATREP_BDPOS]) then
            Error("SetMatElm: obj not contained in base domain");
        else
            mat![UPPERTRIANGULARMATREP_ELSPOS][(-row*row+row)/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(row-1) + col] := obj;
        fi;
    fi;
 end );



 ############################################################################
 # Printing and viewing methods:
 ############################################################################

 # Implementing these methods is not mandatory but highly recommended to make
 # working with your new matrix object fun and easy.

 InstallMethod( ViewObj, "for an IsUpperTriangularMatrixRep matrix", [ IsUpperTriangularMatrixRep ],
   function( mat )
     Print("<");
     if not IsMutable(mat) then Print("immutable "); fi;
     Print(mat![UPPERTRIANGULARMATREP_NRPOS],"x",mat![UPPERTRIANGULARMATREP_NRPOS],"-matrix over ",mat![UPPERTRIANGULARMATREP_BDPOS],">");
       end );

 InstallMethod( PrintObj, "for an IsUpperTriangularMatrixRep matrix", [ IsUpperTriangularMatrixRep ],
   function( mat )
     Print("NewMatrix(IsUpperTriangularMatrixRep");
     if IsFinite(mat![UPPERTRIANGULARMATREP_BDPOS]) and IsField(mat![UPPERTRIANGULARMATREP_BDPOS]) then
         Print(",GF(",Size(mat![UPPERTRIANGULARMATREP_BDPOS]),"),");
             else
         Print(",",String(mat![UPPERTRIANGULARMATREP_BDPOS]),",");
     fi;
     Print(mat![UPPERTRIANGULARMATREP_NRPOS],",",Unpack(mat),")");
      end );

 InstallMethod( Display, "for an IsUpperTriangularMatrixRep matrix", [ IsUpperTriangularMatrixRep ],
   function( mat )
     local i,j,m,zeroEle;
     zeroEle := Zero(mat![UPPERTRIANGULARMATREP_BDPOS]);
     Print("<");
     if not IsMutable(mat) then Print("immutable "); fi;
     Print(mat![UPPERTRIANGULARMATREP_NRPOS],"x",mat![UPPERTRIANGULARMATREP_NRPOS],"-matrix over ",mat![UPPERTRIANGULARMATREP_BDPOS],":\n");
     if IsFinite(mat![UPPERTRIANGULARMATREP_BDPOS]) then 
       m := Unpack(mat);
       Display(m);
     else 
       Print("[");
       for i in [1..mat![UPPERTRIANGULARMATREP_NRPOS]] do
            for j in [1..mat![UPPERTRIANGULARMATREP_NRPOS]] do
                if j = 1 then
                    Print("[");
                else
                    Print(" ");
                fi;
                if j < i then
                    Print(zeroEle);
                else
                    Print(mat![UPPERTRIANGULARMATREP_ELSPOS][(-i*i+i)/2+mat![UPPERTRIANGULARMATREP_NRPOS]*(i-1) + j]);
                fi;
                if j = mat![UPPERTRIANGULARMATREP_NRPOS] then 
                    Print("]\n");
                fi;
            od;
       od;
       Print("]");
     fi;
     Print(">\n");
end );

 InstallMethod( String, "for plist matrix", [ IsUpperTriangularMatrixRep ],
   function( m )
     local st;
     st := "NewMatrix(IsUpperTriangularMatrixRep";
     Add(st,',');
     if IsFinite(m![UPPERTRIANGULARMATREP_BDPOS]) and IsField(m![UPPERTRIANGULARMATREP_BDPOS]) then
         Append(st,"GF(");
         Append(st,String(Size(m![UPPERTRIANGULARMATREP_BDPOS])));
         Append(st,"),");
     else
         Append(st,String(m![UPPERTRIANGULARMATREP_BDPOS]));
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

 # Depending on your matrix object you might want to provide arithmetic methods
 # that work with other matrix objects. E.g. we should add an addition method
 # that takes a PListMatrixRep as one of the arguments. Then it must be decided
 # what type the result should have. The generic method returns a matrix object
 # with the constructing filter of the left operand. In some cases this must be
 # avoided to avoid errors. E.g. if you implement a diagonal matrix object by
 # storing the diagonal entries in a list your constructor likely thorws an error
 # when provided with a non diagonal matrix. If one would multiply a diagonal
 # matrix with a non-diagonal one the generic method would call your constructor
 # with a non-diagonal matrix causing an error. Thus, you should implement a
 # tailored (or generic) method to handle such a case.

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

 #todo
 InstallMethod( \*, "for two IsUpperTriangularMatrixRep matrices",
   [ IsUpperTriangularMatrixRep, IsUpperTriangularMatrixRep ],
   function( a, b )
     # Here we do full checking since it is rather cheap!
     local row,col,l,ty,v,w,sum,i;
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
        for col in [row..a![UPPERTRIANGULARMATREP_NRPOS]] do
            sum := Zero(a![UPPERTRIANGULARMATREP_BDPOS]);
            for i in [row..col] do
                sum := sum + a[row,i] * b[i,col];
            od;
            l[(-row*row+row)/2+a![UPPERTRIANGULARMATREP_NRPOS]*(row-1) + col] := sum;
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

   # Further methods one could implement if it offers a significant performance
   # improvement
   # ZeroMutable
   # IsZero
   # IsOne
   # OneSameMutability
   # OneMutable
   # OneImmutable 

   # This method should be implemented with care as e.g. for permutation
   # matrices, diagonal matrices or similar inversion can be achieved cheaply.
   # For sparse matrices on the other hand one must avoid creating large
   # intermediary objects. In this particular implementation the existing method
   # from GAP is called.


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