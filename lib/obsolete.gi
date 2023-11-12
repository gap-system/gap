#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  See the comments in `lib/obsolete.gd'.
##


#############################################################################
##
#F  DiagonalizeIntMatNormDriven(<mat>)  . . . . diagonalize an integer matrix
##
#T  Should this test for mutability? SL
##
# InstallGlobalFunction( DiagonalizeIntMatNormDriven, function ( mat )
#     local   nrrows,     # number of rows    (length of <mat>)
#             nrcols,     # number of columns (length of <mat>[1])
#             rownorms,   # norms of rows
#             colnorms,   # norms of columns
#             d,          # diagonal position
#             pivk, pivl, # position of a pivot
#             norm,       # product of row and column norms of the pivot
#             clear,      # are the row and column cleared
#             row,        # one row
#             col,        # one column
#             ent,        # one entry of matrix
#             quo,        # quotient
#             h,          # gap width in shell sort
#             k, l,       # loop variables
#             max, omax;  # maximal entry and overall maximal entry
#
#     # give some information
#     Info( InfoMatrix, 1, "DiagonalizeMat called" );
#     omax := 0;
#
#     # get the number of rows and columns
#     nrrows := Length( mat );
#     if nrrows <> 0  then
#         nrcols := Length( mat[1] );
#     else
#         nrcols := 0;
#     fi;
#     rownorms := [];
#     colnorms := [];
#
#     # loop over the diagonal positions
#     d := 1;
#     Info( InfoMatrix, 2, "  divisors:" );
#
#     while d <= nrrows and d <= nrcols  do
#
#         # find the maximal entry
#         Info( InfoMatrix, 3, "    d=", d );
#         if 3 <= InfoLevel( InfoMatrix ) then
#             max := 0;
#             for k  in [ d .. nrrows ]  do
#                 for l  in [ d .. nrcols ]  do
#                     ent := mat[k][l];
#                     if   0 < ent and max <  ent  then
#                         max :=  ent;
#                     elif ent < 0 and max < -ent  then
#                         max := -ent;
#                     fi;
#                 od;
#             od;
#             Info( InfoMatrix, 3, "    max=", max );
#             if omax < max  then omax := max;  fi;
#         fi;
#
#         # compute the Euclidean norms of the rows and columns
#         for k  in [ d .. nrrows ]  do
#             row := mat[k];
#             rownorms[k] := row * row;
#         od;
#         for l  in [ d .. nrcols ]  do
#             col := mat{[d..nrrows]}[l];
#             colnorms[l] := col * col;
#         od;
#         Info( InfoMatrix, 3, "    n" );
#
#         # push rows containing only zeroes down and forget about them
#         for k  in [ nrrows, nrrows-1 .. d ]  do
#             if k < nrrows and rownorms[k] = 0  then
#                 row         := mat[k];
#                 mat[k]      := mat[nrrows];
#                 mat[nrrows] := row;
#                 norm             := rownorms[k];
#                 rownorms[k]      := rownorms[nrrows];
#                 rownorms[nrrows] := norm;
#             fi;
#             if rownorms[nrrows] = 0  then
#                 nrrows := nrrows - 1;
#             fi;
#         od;
#
#         # quit if there are no more nonzero entries
#         if nrrows < d  then
#             #N  1996/04/30 mschoene should 'break'
#             Info( InfoMatrix, 3, "  overall maximal entry ", omax );
#             Info( InfoMatrix, 1, "DiagonalizeMat returns" );
#             return;
#         fi;
#
#         # push columns containing only zeroes right and forget about them
#         for l  in [ nrcols, nrcols-1 .. d ]  do
#             if l < nrcols and colnorms[l] = 0  then
#                 col                      := mat{[d..nrrows]}[l];
#                 mat{[d..nrrows]}[l]      := mat{[d..nrrows]}[nrcols];
#                 mat{[d..nrrows]}[nrcols] := col;
#                 norm             := colnorms[l];
#                 colnorms[l]      := colnorms[nrcols];
#                 colnorms[nrcols] := norm;
#             fi;
#             if colnorms[nrcols] = 0  then
#                 nrcols := nrcols - 1;
#             fi;
#         od;
#
#         # sort the rows with respect to their norms
#         h := 1;  while 9 * h + 4 < nrrows-(d-1)  do h := 3 * h + 1;  od;
#         while 0 < h  do
#             for l  in [ h+1 .. nrrows-(d-1) ]  do
#                 norm := rownorms[l+(d-1)];
#                 row := mat[l+(d-1)];
#                 k := l;
#                 while h+1 <= k  and norm < rownorms[k-h+(d-1)]  do
#                     rownorms[k+(d-1)] := rownorms[k-h+(d-1)];
#                     mat[k+(d-1)] := mat[k-h+(d-1)];
#                     k := k - h;
#                 od;
#                 rownorms[k+(d-1)] := norm;
#                 mat[k+(d-1)] := row;
#             od;
#             h := QuoInt( h, 3 );
#         od;
#
#         # choose a pivot in the '<mat>{[<d>..]}{[<d>..]}' submatrix
#         # the pivot must be the topmost nonzero entry in its column,
#         # now that the rows are sorted with respect to their norm
#         pivk := 0;  pivl := 0;
#         norm := Maximum(rownorms) * Maximum(colnorms) + 1;
#         for l  in [ d .. nrcols ]  do
#             k := d;
#             while mat[k][l] = 0  do
#                 k := k + 1;
#             od;
#             if rownorms[k] * colnorms[l] < norm  then
#                 pivk := k;  pivl := l;
#                 norm := rownorms[k] * colnorms[l];
#             fi;
#         od;
#         Info( InfoMatrix, 3, "    p" );
#
#         # move the pivot to the diagonal and make it positive
#         if d <> pivk  then
#             row       := mat[d];
#             mat[d]    := mat[pivk];
#             mat[pivk] := row;
#         fi;
#         if d <> pivl  then
#             col                    := mat{[d..nrrows]}[d];
#             mat{[d..nrrows]}[d]    := mat{[d..nrrows]}[pivl];
#             mat{[d..nrrows]}[pivl] := col;
#         fi;
#         if mat[d][d] < 0  then
#             MultVector(mat[d],-1);
#         fi;
#
#         # now perform row operations so that the entries in the
#         # <d>-th column have absolute value at most pivot/2
#         clear := true;
#         row := mat[d];
#         for k  in [ d+1 .. nrrows ]  do
#             quo := BestQuoInt( mat[k][d], mat[d][d] );
#             if quo = 1  then
#                 AddRowVector(mat[k], row, -1);
#             elif quo = -1  then
#                 AddRowVector(mat[k], row);
#             elif quo <> 0  then
#                 AddRowVector(mat[k], row, -quo);
#             fi;
#             clear := clear and mat[k][d] = 0;
#         od;
#         Info( InfoMatrix, 3, "    c" );
#
#         # now perform column operations so that the entries in
#         # the <d>-th row have absolute value at most pivot/2
#         col := mat{[d..nrrows]}[d];
#         for l  in [ d+1 .. nrcols ]  do
#             quo := BestQuoInt( mat[d][l], mat[d][d] );
#             if quo = 1  then
#                 mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - col;
#             elif quo = -1  then
#                 mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] + col;
#             elif quo <> 0  then
#                 mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - quo * col;
#             fi;
#             clear := clear and mat[d][l] = 0;
#         od;
#         Info( InfoMatrix, 3, "    r" );
#
#         # repeat until the <d>-th row and column are totally cleared
#         while not clear  do
#
#             # compute the Euclidean norms of the rows and columns
#             # that have a nonzero entry in the <d>-th column resp. row
#             for k  in [ d .. nrrows ]  do
#                 if mat[k][d] <> 0  then
#                     row := mat[k];
#                     rownorms[k] := row * row;
#                 fi;
#             od;
#             for l  in [ d .. nrcols ]  do
#                 if mat[d][l] <> 0  then
#                     col := mat{[d..nrrows]}[l];
#                     colnorms[l] := col * col;
#                 fi;
#             od;
#             Info( InfoMatrix, 3, "    n" );
#
#             # choose a pivot in the <d>-th row or <d>-th column
#             pivk := 0;  pivl := 0;
#             norm := Maximum(rownorms) * Maximum(colnorms) + 1;
#             for l  in [ d+1 .. nrcols ]  do
#                 if 0 <> mat[d][l] and rownorms[d] * colnorms[l] < norm  then
#                     pivk := d;  pivl := l;
#                     norm := rownorms[d] * colnorms[l];
#                 fi;
#             od;
#             for k  in [ d+1 .. nrrows ]  do
#                 if 0 <> mat[k][d] and rownorms[k] * colnorms[d] < norm  then
#                     pivk := k;  pivl := d;
#                     norm := rownorms[k] * colnorms[d];
#                 fi;
#             od;
#             Info( InfoMatrix, 3, "    p" );
#
#             # move the pivot to the diagonal and make it positive
#             if d <> pivk  then
#                 row       := mat[d];
#                 mat[d]    := mat[pivk];
#                 mat[pivk] := row;
#             fi;
#             if d <> pivl  then
#                 col                    := mat{[d..nrrows]}[d];
#                 mat{[d..nrrows]}[d]    := mat{[d..nrrows]}[pivl];
#                 mat{[d..nrrows]}[pivl] := col;
#             fi;
#             if mat[d][d] < 0  then
#                 MultVector(mat[d],-1);
#             fi;
#
#             # now perform row operations so that the entries in the
#             # <d>-th column have absolute value at most pivot/2
#             clear := true;
#             row := mat[d];
#             for k  in [ d+1 .. nrrows ]  do
#                 quo := BestQuoInt( mat[k][d], mat[d][d] );
#                 if quo = 1  then
#                     AddRowVector(mat[k],row,-1);
#                 elif quo = -1  then
#                     AddRowVector(mat[k],row);
#                 elif quo <> 0  then
#                     AddRowVector(mat[k], row, -quo);
#                 fi;
#                 clear := clear and mat[k][d] = 0;
#             od;
#             Info( InfoMatrix, 3, "    c" );
#
#             # now perform column operations so that the entries in
#             # the <d>-th row have absolute value at most pivot/2
#             col := mat{[d..nrrows]}[d];
#             for l  in [ d+1.. nrcols ]  do
#                 quo := BestQuoInt( mat[d][l], mat[d][d] );
#                 if quo = 1  then
#                     mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - col;
#                 elif quo = -1  then
#                     mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] + col;
#                 elif quo <> 0  then
#                     mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - quo * col;
#                 fi;
#                 clear := clear and mat[d][l] = 0;
#             od;
#             Info( InfoMatrix, 3, "    r" );
#
#         od;
#
#         # print the diagonal entry (for information only)
#         Info( InfoMatrix, 3, "    div=" );
#         Info( InfoMatrix, 2, "      ", mat[d][d] );
#
#         # go on to the next diagonal position
#         d := d + 1;
#
#     od;
#
#     # close with some more information
#     Info( InfoMatrix, 3, "  overall maximal entry ", omax );
#     Info( InfoMatrix, 1, "DiagonalizeMat returns" );
# end );


#############################################################################
##
#M  CharacteristicPolynomial( <F>, <mat> )
#M  CharacteristicPolynomial( <field>, <matrix>, <indnum> )
##
##  The documentation of these usages of CharacteristicPolynomial was
##  ambiguous, leading to surprising results if mat was over F but
##  DefaultField (mat) properly contained F.
##  Now there is a four argument version which allows to specify the field
##  which specifies the linear action of mat, and another which specifies
##  the vector space which mat acts upon.
##
##  In the future, the versions above could be given a different meaning,
##  where the first argument simply specifies both fields in the case
##  when they are the same.
##
##  The following provides backwards compatibility with  {\GAP}~4.4. in the
##  cases where there is no ambiguity.
##
InstallOtherMethod( CharacteristicPolynomial,
     "supply indeterminate 1",
    [ IsField, IsMatrix ],
    function( F, mat )
        return CharacteristicPolynomial (F, mat, 1);
    end );

InstallOtherMethod( CharacteristicPolynomial,
    "check default field, print error if ambiguous",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ],
function( F, mat, inum )
        if IsSubset (F, DefaultFieldOfMatrix (mat)) then
            Info (InfoObsolete, 1, "This usage of `CharacteristicPolynomial' is no longer supported. ",
                "Please specify two fields instead.");
            return CharacteristicPolynomial (F, F, mat, inum);
        else
            Error ("this usage of `CharacteristicPolynomial' is no longer supported, ",
                "please specify two fields instead.");
        fi;
end );


#############################################################################
##
#M  ShrinkCoeffs( <list> )
##
# InstallMethod( ShrinkCoeffs,"call `ShrinkRowVector'",
#     [ IsList and IsMutable ],
# function( l1 )
#     Info( InfoObsolete, 1,
#         "the operation `ShrinkCoeffs' is not supported anymore,\n",
#         "#I  use `ShrinkRowVector' instead" );
#     ShrinkRowVector(l1);
#     return Length(l1);
# end );
#
# InstallOtherMethod( ShrinkCoeffs,"error if immutable",
#     [ IsList ],
#     L1_IMMUTABLE_ERROR);

#############################################################################
##
#M  ShrinkCoeffs( <vec> )
##
# InstallMethod( ShrinkCoeffs, "8 bit vector",
#         [IsMutable and IsRowVector and Is8BitVectorRep ],
#         function(vec)
#     local r;
#     Info( InfoObsolete, 1,
#         "the operation `ShrinkCoeffs' is not supported anymore,\n",
#         "#I  use `ShrinkRowVector' instead" );
#     r := RIGHTMOST_NONZERO_VEC8BIT(vec);
#     RESIZE_VEC8BIT(vec, r);
#     return r;
# end);

#############################################################################
##
#M  ShrinkCoeffs( <gf2vec> )  . . . . . . . . . . . . . . shrink a GF2 vector
##
# InstallMethod( ShrinkCoeffs,
#     "for GF2 vector",
#     [ IsMutable and IsRowVector and IsGF2VectorRep ],
# function( l1 )
#     Info( InfoObsolete, 1,
#         "the operation `ShrinkCoeffs' is not supported anymore,\n",
#         "#I  use `ShrinkRowVector' instead" );
#     return SHRINKCOEFFS_GF2VEC(l1);
# end );


#############################################################################
##
#F  TeX( <obj1>, ... )  . . . . . . . . . . . . . . . . . . . . . TeX objects
##
##  <ManSection>
##  <Func Name="TeX" Arg='obj1, ...'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
##  Not used in any redistributed package (07/2022)
# BIND_GLOBAL( "TeX", function( arg )
#     local   str,  res,  obj;
#
#     str := "";
#     for obj  in arg  do
#         res := TeXObj(obj);
#         APPEND_LIST_INTR( str, res );
#         APPEND_LIST_INTR( str, "%\n" );
#     od;
#     CONV_STRING(str);
#     return str;
# end );


#############################################################################
##
#F  LaTeX( <obj1>, ... )  . . . . . . . . . . . . . . . . . . . LaTeX objects
##
##  <#GAPDoc Label="LaTeX">
##
##  <ManSection>
##  <Func Name="LaTeX" Arg='obj1, obj2, ...'/>
##
##  <Description>
##  Returns a LaTeX string describing the objects <A>obj1</A>, <A>obj2</A>, ... .
##  This string can for example be pasted to a &LaTeX; file, or one can use
##  it in composing a temporary &LaTeX; file,
##  which is intended for being &LaTeX;'ed afterwards from within &GAP;.
##  <P/>
##  <Example><![CDATA[
##  gap> LaTeX(355/113);
##  "\\frac{355}{113}%\n"
##  gap> LaTeX(Z(9)^5);
##  "Z(3^{2})^{5}%\n"
##  gap> Print(LaTeX([[1,2,3],[4,5,6],[7,8,9]]));
##  \left(\begin{array}{rrr}%
##  1&2&3\\%
##  4&5&6\\%
##  7&8&9\\%
##  \end{array}\right)%
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Not used in any redistributed package (11/2018)
# BIND_GLOBAL( "LaTeX", function( arg )
#     local   str,  res,  obj;
#
#     str := "";
#     for obj  in arg  do
#         res := LaTeXObj(obj);
#         APPEND_LIST_INTR( str, res );
#         APPEND_LIST_INTR( str, "%\n" );
#     od;
#     CONV_STRING(str);
#     return str;
# end );


#############################################################################
##
#M  LaTeXObj( <ffe> ) . . . . . .  convert a finite field element into a string
##
# InstallMethod(LaTeXObj,"for an internal FFE",true,[IsFFE and IsInternalRep],0,
# function ( ffe )
# local   str, log,deg,char;
#   char:=Characteristic(ffe);
#   if   IsZero( ffe )  then
#     str := Concatenation("0*Z(",String(char),")");
#   else
#     str := Concatenation("Z(",String(char));
#     deg:=DegreeFFE(ffe);
#     if deg <> 1  then
#       str := Concatenation(str,"^{",String(deg),"}");
#     fi;
#     str := Concatenation(str,")");
#     log:= LogFFE(ffe,Z( char ^ deg ));
#     if log <> 1 then
#       str := Concatenation(str,"^{",String(log),"}");
#     fi;
#   fi;
#   ConvertToStringRep( str );
#   return str;
# end );


#############################################################################
##
#M  LaTeXObj( <elm> ) . . . . . . . for packed word in default representation
##
# InstallMethod( LaTeXObj,"for an element of an f.p. group (default repres.)",
#   true, [ IsElementOfFpGroup and IsPackedElementDefaultRep ],0,
# function( obj )
#   return LaTeXObj( obj![1] );
# end );
#

#############################################################################
##
#M  LaTeXObj
##
# InstallMethod(LaTeXObj,"matrix",
#   [IsMatrix],
# function(m)
# local i,j,l,n,s;
#   l:=Length(m);
#   n:=Length(m[1]);
#   s:="\\left(\\begin{array}{";
#   for i in [1..n] do
#     Add(s,'r');
#   od;
#   Append(s,"}%\n");
#   for i in [1..l] do
#     for j in [1..n] do
#       Append(s,LaTeXObj(m[i][j]));
#       if j<n then
#         Add(s,'&');
#       fi;
#     od;
#     Append(s,"\\\\%\n");
#   od;
#   Append(s,"\\end{array}\\right)");
#   return s;
# end);
#
#
# InstallMethod( LaTeXObj,"polynomial",true, [ IsPolynomial ],0,function(pol)
# local fam, ext, str, zero, one, mone, le, c, s, ind, i, j;
#
#   fam:=FamilyObj(pol);
#   ext:=ExtRepPolynomialRatFun(pol);
#   str:="";
#   zero := fam!.zeroCoefficient;
#   one := fam!.oneCoefficient;
#   mone := -one;
#   le:=Length(ext);
#
#   if le=0 then
#     return String(zero);
#   fi;
#   for i  in [ le-1,le-3..1] do
#     if i<le-1 then
#       # this is the second summand, so arithmetic will occur
#     fi;
#
#     if ext[i+1]=one then
#       if i<le-1 then
#         Add(str,'+');
#       fi;
#       c:=false;
#     elif ext[i+1]=mone then
#       Add(str,'-');
#       c:=false;
#     else
#       if IsRat(ext[i+1]) and ext[i+1]<0 then
#         s:=Concatenation("-",LaTeXObj(-ext[i+1]));
#       else
#         s:=LaTeXObj(ext[i+1]);
#       fi;
#
#       if '+' in s and s[1]<>'(' then
#         s:=Concatenation("(",s,")");
#       fi;
#
#       if i<le-1 and s[1]<>'-' then
#         Add(str,'+');
#       fi;
#       Append(str,s);
#       c:=true;
#     fi;
#
#     if Length(ext[i])<2 then
#       # trivial monomial. Do we have to add a '1'?
#       if c=false then
#         Append(str,String(one));
#       fi;
#     else
#       #if c then
# #       Add(str,'*');
# #      fi;
#       for j  in [ 1, 3 .. Length(ext[i])-1 ]  do
# #       if 1 < j  then
# #         Add(str,'*');
# #       fi;
#         ind:=ext[i][j];
#         if HasIndeterminateName(fam,ind) then
#           Append(str,IndeterminateName(fam,ind));
#         else
#           Append(str,"x_{");
#           Append(str,String(ind));
#           Add(str,'}');
#         fi;
#         if 1 <> ext[i][j+1]  then
#           Append(str,"^{");
#           Append(str,String(ext[i][j+1]));
#           Add(str,'}');
#         fi;
#       od;
#     fi;
#   od;
#
#   return str;
# end);


#############################################################################
##
#M  LaTeXObj
##
# InstallMethod(LaTeXObj,"rational",
#   [IsRat],
# function(r)
# local n,d;
#   if IsInt(r) then
#     return String(r);
#   fi;
#   n:=NumeratorRat(r);
#   d:=DenominatorRat(r);
#   if AbsInt(n)<5 and AbsInt(d)<5 then
#     return Concatenation(String(n),"/",String(d));
#   else
#     return Concatenation("\\frac{",String(n),"}{",String(d),"}");
#   fi;
# end);
#
#
# InstallMethod(LaTeXObj,"assoc word in letter rep",true,
#   [IsAssocWord and IsLetterAssocWordRep],0,
# function(elm)
# local names,len,i,g,h,e,s;
#
#   names:= ShallowCopy(FamilyObj( elm )!.names);
#   for i in [1..Length(names)] do
#     s:=names[i];
#     e:=Length(s);
#     while e>0 and s[e] in CHARS_DIGITS do
#       e:=e-1;
#     od;
#     if e<Length(s) then
#       if e=Length(s)-1 then
#         s:=Concatenation(s{[1..e]},"_",s{[e+1..Length(s)]});
#       else
#         s:=Concatenation(s{[1..e]},"_{",s{[e+1..Length(s)]},"}");
#       fi;
#       names[i]:=s;
#     fi;
#   od;
#
#   s:="";
#   elm:=LetterRepAssocWord(elm);
#   len:= Length( elm );
#   i:= 2;
#   if len = 0 then
#     return( "id" );
#   else
#     g:=AbsInt(elm[1]);
#     e:=SignInt(elm[1]);
#     while i <= len do
#       h:=AbsInt(elm[i]);
#       if h=g then
#         e:=e+SignInt(elm[i]);
#       else
#         Append(s, names[g] );
#         if e<>1 then
#           Append(s,"^{");
#           Append(s,String(e));
#           Append(s,"}");
#         fi;
#         g:=h;
#         e:=SignInt(elm[i]);
#       fi;
#       i:=i+1;
#     od;
#     Append(s, names[g] );
#     if e<>1 then
#       Append(s,"^{");
#       Append(s,String(e));
#       Append(s,"}");
#     fi;
#   fi;
#   return s;
# end);
#

#############################################################################
##
#F  CharacterTableDisplayPrintLegendDefault( <data> )
##
##  for backwards compatibility only ...
##
# BindGlobal( "CharacterTableDisplayPrintLegendDefault",
#     function( data )
#     Info( InfoObsolete, 1,
#         "the function `CharacterTableDisplayPrintLegendDefault' is no longer\n",
#         "#I  supported and may be removed from future versions of GAP" );
#     Print( CharacterTableDisplayLegendDefault( data ) );
#     end );


#############################################################################
##
#F  ConnectGroupAndCharacterTable( <G>, <tbl>[, <arec>] )
#F  ConnectGroupAndCharacterTable( <G>, <tbl>, <bijection> )
##
# InstallGlobalFunction( ConnectGroupAndCharacterTable, function( arg )
#     local G, tbl, arec, ccl, compat;
#
#     Info( InfoObsolete, 1,
#         "the function `ConnectGroupAndCharacterTable' is not supported anymore,\n",
#         "#I  use `CharacterTableWithStoredGroup' instead" );
#
#     # Get and check the arguments.
#     if   Length( arg ) = 2 and IsGroup( arg[1] )
#                            and IsOrdinaryTable( arg[2] ) then
#       arec:= rec();
#     elif Length( arg ) = 3 and IsGroup( arg[1] )
#                            and IsOrdinaryTable( arg[2] )
#                            and ( IsRecord( arg[3] ) or IsList(arg[3]) ) then
#       arec:= arg[3];
#     else
#       Error( "usage: ConnectGroupAndCharacterTable(<G>,<tbl>[,<arec>])" );
#     fi;
#
#     G   := arg[1];
#     tbl := arg[2];
#
#     if HasUnderlyingGroup( tbl ) then
#       Error( "<tbl> has already underlying group" );
#     elif HasOrdinaryCharacterTable( G ) then
#       Error( "<G> has already a character table" );
#     fi;
#
#     ccl:= ConjugacyClasses( G );
# #T How to exploit the known character table
# #T if the conjugacy classes of <G> are not yet computed?
#
#     if IsList( arec ) then
#       compat:= arec;
#     else
#       compat:= CompatibleConjugacyClasses( G, ccl, tbl, arec );
#     fi;
#
#     if IsList( compat ) then
#
#       # Permute the classes if necessary.
#       if compat <> [ 1 .. Length( compat ) ] then
#         ccl:= ccl{ compat };
#       fi;
#
#       # The identification is unique, store attribute values.
#       SetUnderlyingGroup( tbl, G );
#       SetOrdinaryCharacterTable( G, tbl );
#       SetConjugacyClasses( tbl, ccl );
#       SetIdentificationOfConjugacyClasses( tbl, compat );
#
#       return true;
#
#     else
#       return false;
#     fi;
#
#     end );


#############################################################################
##
#F  ViewLength( <len> )
##
##  <Ref Func="View"/> will usually display objects in short form if they
##  would need more than <A>len</A> lines. The default is 3.
##  This function was moved to obsoletes before GAP 4.7 beta release,
##  since there is now a user preference mechanism to specify it:
##  GAPInfo.ViewLength:= UserPreference( "ViewLength" ) is the maximal
##  number of lines that are reasonably printed in `ViewObj' methods.
##
# BIND_GLOBAL( "ViewLength", function(arg)
#   Info (InfoObsolete, 1, "The function `ViewLength' is no longer supported. ",
#                         "Please use user preference `ViewLength' instead.");
#   if LEN_LIST( arg ) = 0 then
#     return GAPInfo.ViewLength;
#   else
#     GAPInfo.ViewLength:= arg[1];
#   fi;
# end );
#


#############################################################################
##
#M  MultVector( <list1>, <poss1>, <list2>, <poss2>, <mult> )
##
InstallOtherMethod( MultVector, "obsolete five argument method",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsDenseList,
      IsDenseList,
      IsObject ],
    0,
function( l1, p1, l2, p2, m )
    Info(InfoObsolete, 1, "This usage of `MultVector` is no longer ",
           "supported and will be removed eventually." );
    l1{p1} := m * l2{p2};
end );

InstallOtherMethod( MultVector, "error if immutable", true,
    [ IsList,IsObject,IsObject,IsObject,IsObject],0,
    L1_IMMUTABLE_ERROR);

#############################################################################
##
#F  SetUserPreferences
##
##  Set the defaults of `GAPInfo.UserPreferences'.
##
##  We locate the first file `gap.ini' in GAP root directories,
##  and read it if available.
##  This must be done before `GAPInfo.UserPreferences' is used.
##  Some of the preferences require an initialization,
##  but this cannot be called before the complete library has been loaded.
##
BindGlobal( "SetUserPreferences", function( arg )
    local name, record;

    Info( InfoObsolete, 1, "");
    Info( InfoObsolete, 1, Concatenation( [
          "The call to 'SetUserPreferences' (probably in a 'gap.ini' file)\n",
          "#I  should be replaced by individual 'SetUserPreference' calls,\n",
          "#I  which are package specific.\n",
          "#I  Try 'WriteGapIniFile()'." ] ) );

    # Set the new values.
    if Length( arg ) = 1 then
      record:= arg[1];
      if not IsBound(GAPInfo.UserPreferences.gapdoc) then
        GAPInfo.UserPreferences.gapdoc := rec();
      fi;
      if not IsBound(GAPInfo.UserPreferences.gap) then
        GAPInfo.UserPreferences.gap := rec();
      fi;
      for name in RecNames( record ) do
        if name in [ "HTMLStyle", "TextTheme", "UseMathJax" ] then
          GAPInfo.UserPreferences.gapdoc.( name ):= record.( name );
        else
          GAPInfo.UserPreferences.gap.( name ):= record.( name );
        fi;
      od;
    fi;
    end );

#############################################################################
##
#F  SetFeatureObj( <obj>, <filter>, <val> )
##
##  Moved to obsoletes in October 2018 for GAP 4.11.
##
##  Not used in any redistributed package (04/2019)
# BIND_GLOBAL( "SetFeatureObj", function ( obj, filter, val )
#     Info( InfoObsolete, 1, "'SetFeatureObj' is obsolete, use 'SetFilterObj' or 'ResetFilterObj' instead" );
#     if val then
#         SetFilterObj( obj, filter );
#     else
#         ResetFilterObj( obj, filter );
#     fi;
# end );

#############################################################################
##
#F  TemporaryGlobalVarName( [<prefix>] )   name of an unbound global variable
##
##  TemporaryGlobalVarName ( [<prefix>]  ) returns a string  that can be used
##  as the  name  of a global  variable  that is not bound   at the time when
##  TemporaryGlobalVarName()  is called.    The optional  argument prefix can
##  specify a string with which the name of the global variable starts.
##

InstallGlobalFunction( TemporaryGlobalVarName,
        function( arg )
    local   prefix,  nr,  gvar;

  Info(InfoObsolete, 2, "This usage of `TemporaryGlobalVarName` is no longer ",
         "supported and will be removed eventually." );

    if Length(arg) = 0 then
        prefix := "TEMP";
    elif Length(arg) = 1 and IsString( arg[1] ) then
        prefix := arg[1];
        CheckGlobalName( prefix );
    else
        return Error( "usage: TemporaryGlobalVarName( [<prefix>] )" );
    fi;

    nr := 0;
    gvar:= prefix;
    while ISBOUND_GLOBAL( gvar ) do
        nr := nr + 1;
        gvar := Concatenation( prefix, String(nr) );
    od;

    return gvar;
end );


if IsHPCGAP then
    BindThreadLocal("HIDDEN_GVARS",[]);
else
    HIDDEN_GVARS:=[];
fi;

InstallGlobalFunction(HideGlobalVariables,function(arg)
local p,i;

  Info(InfoObsolete, 2, "This usage of `HideGlobalVariables` is no longer ",
         "supported and will be removed eventually." );

  p:=Length(HIDDEN_GVARS);
  for i in arg do
    if IsString(i) then
      p:=p+1;
      HIDDEN_GVARS[p]:=i;
      p:=p+2;
      if ISBOUND_GLOBAL(i) then
        # variable is assigned
        HIDDEN_GVARS[p-1]:=VALUE_GLOBAL(i);
        if IS_READ_ONLY_GLOBAL(i) then
          HIDDEN_GVARS[p]:=true;
          MAKE_READ_WRITE_GLOBAL(i);
        else
          HIDDEN_GVARS[p]:=false;
        fi;
      else
        HIDDEN_GVARS[p-1]:=fail; # needs to be assigned
        HIDDEN_GVARS[p]:=fail;
      fi;
      # temporarily remove the variable
      UNBIND_GLOBAL(i);
    else
      Error("HideGlobalVariables requires the names as strings");
    fi;
  od;
end);

InstallGlobalFunction(UnhideGlobalVariables,function(arg)
local p,str,all,l,which;

  Info(InfoObsolete, 2, "This usage of `UnhideGlobalVariables` is no longer ",
         "supported and will be removed eventually." );

  all:=Length(arg)=0; # doe we want to unhide all?
  which:=arg;
  l:=Length(HIDDEN_GVARS);
  p:=l-2;
  while p>0 do
    str:=HIDDEN_GVARS[p];
    # do we want to unhide the variable?
    if all or str in which then
      # remove the value
      if ISBOUND_GLOBAL(str) then
        if IS_READ_ONLY_GLOBAL(str) then
          MAKE_READ_WRITE_GLOBAL(str);
        fi;
        UNBIND_GLOBAL(str);
      fi;

      if HIDDEN_GVARS[p+2]<>fail then
        #reassign a value
        ASS_GVAR(str,HIDDEN_GVARS[p+1]);
        if HIDDEN_GVARS[p+2]=true then
          MAKE_READ_ONLY_GLOBAL(str);
        fi;
      fi;

      # remove the corresponding "HIDDEN_GVARS" entry
      if not all then
        if p+2<l then
          # move
          HIDDEN_GVARS{[p..l-3]}:=HIDDEN_GVARS{[p+3..l]};
        fi;
        # remove
        Unbind(HIDDEN_GVARS[l-2]);
        Unbind(HIDDEN_GVARS[l-1]);
        Unbind(HIDDEN_GVARS[l]);
        l:=l-3;
        which:=Filtered(which,i->i<>str);
      fi;
    fi;
    p:=p-3;
  od;
  if all then
    HIDDEN_GVARS:=[];
  fi;
end);

#############################################################################
##
#F  RANDOM_SEED( <list> )
##
##  Moved to obsoletes in August 2019 for GAP 4.11.
##
##  Still used in gbnp, recog -- but only in the package tests (08/2019)
BindGlobal("RANDOM_SEED", function ( n )
    Init(GlobalRandomSource, n);
end );

##
##  The variables R_N and R_X used to part of the state of GAP's random number
##  generator, and even were mentioned in the documentation of GAP 4.4, albeit
##  only in a parenthesis, and as an alternative to StateRandom /
##  RestoreStateRandom, which in turn were made obsolete in GAP 4.5.
##
##  No code is known to use these, anywhere. But hypothetically, somebody might
##  have ancient GAP code sitting somewhere which tries to access these two
##  in some way. We thus try hard to make sure this leads to an error, instead
##  of possibly working silently, and leading to an erroneous computations.
##
BindGlobal("R_N", fail);
BindGlobal("R_X", fail);

# Moved to obsolete in Nov. 2021 for 4.12
InstallMethod( NaturalHomomorphism, "for a group with natural homomorphism stored",
    [ IsGroup ],
function(G)
  Info(InfoWarning,0,"The use of `NaturalHomomorphism` for a `FactorGroup`\n",
    "has been deprecated, as it caused side-effects.\n",
    "Proceed at risk!");

  if IsBound(G!.nathom) then
    return G!.nathom;
  else
    Error("no natural homomorphism stored");
  fi;
end);


#############################################################################
##
#F  TmpNameAllArchs( )
##
##  Still used in guava (10/2019)
DeclareObsoleteSynonym( "TmpNameAllArchs", "TmpName" );

#############################################################################
##
#F  ZERO
##
##  Not used in any redistributed package (07/2022)
#BindGlobal( "ZERO", ZeroSameMutability );

#############################################################################
##
#F  AINV
##
##  Not used in any redistributed package (07/2022)
#BindGlobal( "AINV", AdditiveInverseSameMutability );

#############################################################################
##
#F  ONE_MUT
##
##  Not used in any redistributed package (07/2022)
#BindGlobal( "ONE_MUT", OneSameMutability );

#############################################################################
##
#F  INV_MUT
##
##  Not used in any redistributed package (07/2022)
#BindGlobal( "INV_MUT", InverseSameMutability );
