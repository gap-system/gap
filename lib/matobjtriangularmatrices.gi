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
 # In order to implement another matrix object you can use this file as a guide
 # on what methods need to be implemented. In general you can take a look at
 # 'matobj.gi'. In that file all methods available for matrix objects are
 # implemented. For most methods, if you do not povide a tailored implementation
 # the generic implementation in 'matobj.gi' is used. Thus, you can take a look
 # at the generic method and decide whether you can provide a significant
 # improvement by writing a custom method for your particular object. However,
 # there are a few methods you must implement for any new matrix object.
 # For the methods you must implement see the Reference Manual 26.13. This list
 # is not complete however e.g. in generic methods an 'unpack' method is often
 # used but none is generically provided. Thus you should implement this method too.

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
   "for IsFlistMatrixRep, a ring, and two ints",
   [ IsUpperTriangularMatrixRep, IsRing, IsInt, IsInt ],
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




 ############################################################################
 # Printing and viewing methods:
 ############################################################################

 # Implementing these methods is not mandatory but highly recommended to make
 # working with your new matrix object fun and easy.

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
     Print(mat![FLISTREP_NRPOS],"x",mat![FLISTREP_NCPOS],"-matrix over ",mat![FLISTREP_BDPOS],":\n");
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


# It is important to implement this method as it is used by a lot of generic methods.
InstallMethod( Unpack, "for an flist matrix",
[ IsUpperTriangularMatrixRep ],
function( mat )
    return List([1..mat![FLISTREP_NRPOS]],row->ShallowCopy(mat![FLISTREP_ELSPOS]{[(row-1)*mat![FLISTREP_NCPOS]+1..row*mat![FLISTREP_NCPOS]]}));
end );
