#############################################################################
##
#W  obsolete.g                  GAP library                     Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains a number of functions, or extensions of
##  functions to certain numbers or combinations of arguments, which
##  are now considered "deprecated" or "obsolescent", but which are presently
##  included in the system to maintain backwards compatibility.
##
##  Procedures for dealing with this functionality are not yet completely
##  agreed, but it will probably be removed from the system over
##  several releases.
##
##  These functions should *NOT* be used in the library.
##
##  The current contents of the file was added after the release of
##  {\GAP}~4.3, is regarded as ``obsolescent'' in {\GAP}~4.4,
##  and is expected to be removed with the release of {\GAP}~4.5.
##  (After the release of {\GAP}~4.4, the code will be added that
##  is regarded as ``obsolescent'' in {\GAP}~4.5.
##
Revision.obsolete_g :=
    "@(#)$Id$";


##### Declarations from `utils.gd' which unfortuynately are used in packages

DeclareSynonym( "PrimeOfPGroup", PrimePGroup );

##  Underlying field of a vector space or algebra.
DeclareAttribute( "UnderlyingField", IsVectorSpace );
InstallMethod(UnderlyingField,"vector space",true,[IsVectorSpace],0,
  LeftActingDomain);
DeclareAttribute( "UnderlyingField", IsFFEMatrixGroup );
InstallMethod(UnderlyingField,"generic",true,[IsVectorSpace],0,
  FieldOfMatrixGroup);

##  Dimension of matrices in an algebra.
DeclareSynonym( "MatrixDimension", DimensionOfMatrixGroup);

#####

# monomial ordering: the function was badly defined, name is now obsolete
DeclareSynonym( "MonomialTotalDegreeLess", MonomialExtGrlexLess );

#############################################################################
##
#F  SmithNormalFormSQ( mat )
##
##  returns D = diagonalised form, D = P * M * Q, I = Q^-1
##
BindGlobal("SmithNormalFormSQ", function( M )
local r;
  Info(InfoWarning,1,"Obsolete function  `SmithNormalFormSQ',\n",
  "use `NormalFormIntMat' instead");
  r:=NormalFormIntMat(M,15);
  return rec(P:=r.rowtrans,Q:=r.coltrans,D:=r.normal,I:=r.coltrans^-1);
end );

#############################################################################
##
#F  DiagonalizeIntMatNormDriven(<mat>)  . . . . diagonalize an integer matrix
##
##  'DiagonalizeIntMatNormDriven'  diagonalizes  the  integer  matrix  <mat>.
##
##  It tries to keep the entries small  through careful  selection of pivots.
##
##  First it selects a nonzero entry for which the  product of row and column
##  norm is minimal (this need not be the entry with minimal absolute value).
##  Then it brings this pivot to the upper left corner and makes it positive.
##
##  Next it subtracts multiples of the first row from the other rows, so that
##  the new entries in the first column have absolute value at most  pivot/2.
##  Likewise it subtracts multiples of the 1st column from the other columns.
##
##  If afterwards not  all new entries in the  first column and row are zero,
##  then it selects a  new pivot from those  entries (again driven by product
##  of norms) and reduces the first column and row again.
##
##  If finally all offdiagonal entries in the first column  and row are zero,
##  then it  starts all over again with the submatrix  '<mat>{[2..]}{[2..]}'.
##
##  It is  based  upon  ideas by  George Havas  and code by  Bohdan Majewski.
##  G. Havas and B. Majewski, Integer Matrix Diagonalization, JSC, to appear
##
#T  Should this test for mutability? SL

BindGlobal("DiagonalizeIntMatNormDriven", function ( mat )
    local   nrrows,     # number of rows    (length of <mat>)
            nrcols,     # number of columns (length of <mat>[1])
            rownorms,   # norms of rows
            colnorms,   # norms of columns
            d,          # diagonal position
            pivk, pivl, # position of a pivot
            norm,       # product of row and column norms of the pivot
            clear,      # are the row and column cleared
            row,        # one row
            col,        # one column
            ent,        # one entry of matrix
            quo,        # quotient
            h,          # gap width in shell sort
            k, l,       # loop variables
            max, omax;  # maximal entry and overall maximal entry

    # give some information
    Info( InfoMatrix, 1, "DiagonalizeMat called" );
    omax := 0;

    # get the number of rows and columns
    nrrows := Length( mat );
    if nrrows <> 0  then
        nrcols := Length( mat[1] );
    else
        nrcols := 0;
    fi;
    rownorms := [];
    colnorms := [];

    # loop over the diagonal positions
    d := 1;
    Info( InfoMatrix, 2, "  divisors:" );

    while d <= nrrows and d <= nrcols  do

        # find the maximal entry
        Info( InfoMatrix, 3, "    d=", d );
        if 3 <= InfoLevel( InfoMatrix ) then
            max := 0;
            for k  in [ d .. nrrows ]  do
                for l  in [ d .. nrcols ]  do
                    ent := mat[k][l];
                    if   0 < ent and max <  ent  then
                        max :=  ent;
                    elif ent < 0 and max < -ent  then
                        max := -ent;
                    fi;
                od;
            od;
            Info( InfoMatrix, 3, "    max=", max );
            if omax < max  then omax := max;  fi;
        fi;

        # compute the Euclidean norms of the rows and columns
        for k  in [ d .. nrrows ]  do
            row := mat[k];
            rownorms[k] := row * row;
        od;
        for l  in [ d .. nrcols ]  do
            col := mat{[d..nrrows]}[l];
            colnorms[l] := col * col;
        od;
        Info( InfoMatrix, 3, "    n" );

        # push rows containing only zeroes down and forget about them
        for k  in [ nrrows, nrrows-1 .. d ]  do
            if k < nrrows and rownorms[k] = 0  then
                row         := mat[k];
                mat[k]      := mat[nrrows];
                mat[nrrows] := row;
                norm             := rownorms[k];
                rownorms[k]      := rownorms[nrrows];
                rownorms[nrrows] := norm;
            fi;
            if rownorms[nrrows] = 0  then
                nrrows := nrrows - 1;
            fi;
        od;

        # quit if there are no more nonzero entries
        if nrrows < d  then
            #N  1996/04/30 mschoene should 'break'
            Info( InfoMatrix, 3, "  overall maximal entry ", omax );
            Info( InfoMatrix, 1, "DiagonalizeMat returns" );
            return;
        fi;

        # push columns containing only zeroes right and forget about them
        for l  in [ nrcols, nrcols-1 .. d ]  do
            if l < nrcols and colnorms[l] = 0  then
                col                      := mat{[d..nrrows]}[l];
                mat{[d..nrrows]}[l]      := mat{[d..nrrows]}[nrcols];
                mat{[d..nrrows]}[nrcols] := col;
                norm             := colnorms[l];
                colnorms[l]      := colnorms[nrcols];
                colnorms[nrcols] := norm;
            fi;
            if colnorms[nrcols] = 0  then
                nrcols := nrcols - 1;
            fi;
        od;

        # sort the rows with respect to their norms
        h := 1;  while 9 * h + 4 < nrrows-(d-1)  do h := 3 * h + 1;  od;
        while 0 < h  do
            for l  in [ h+1 .. nrrows-(d-1) ]  do
                norm := rownorms[l+(d-1)];
                row := mat[l+(d-1)];
                k := l;
                while h+1 <= k  and norm < rownorms[k-h+(d-1)]  do
                    rownorms[k+(d-1)] := rownorms[k-h+(d-1)];
                    mat[k+(d-1)] := mat[k-h+(d-1)];
                    k := k - h;
                od;
                rownorms[k+(d-1)] := norm;
                mat[k+(d-1)] := row;
            od;
            h := QuoInt( h, 3 );
        od;

        # choose a pivot in the '<mat>{[<d>..]}{[<d>..]}' submatrix
        # the pivot must be the topmost nonzero entry in its column,
        # now that the rows are sorted with respect to their norm
        pivk := 0;  pivl := 0;
        norm := Maximum(rownorms) * Maximum(colnorms) + 1;
        for l  in [ d .. nrcols ]  do
            k := d;
            while mat[k][l] = 0  do
                k := k + 1;
            od;
            if rownorms[k] * colnorms[l] < norm  then
                pivk := k;  pivl := l;
                norm := rownorms[k] * colnorms[l];
            fi;
        od;
        Info( InfoMatrix, 3, "    p" );

        # move the pivot to the diagonal and make it positive
        if d <> pivk  then
            row       := mat[d];
            mat[d]    := mat[pivk];
            mat[pivk] := row;
        fi;
        if d <> pivl  then
            col                    := mat{[d..nrrows]}[d];
            mat{[d..nrrows]}[d]    := mat{[d..nrrows]}[pivl];
            mat{[d..nrrows]}[pivl] := col;
        fi;
        if mat[d][d] < 0  then
            MultRowVector(mat[d],-1);
        fi;

        # now perform row operations so that the entries in the
        # <d>-th column have absolute value at most pivot/2
        clear := true;
        row := mat[d];
        for k  in [ d+1 .. nrrows ]  do
            quo := BestQuoInt( mat[k][d], mat[d][d] );
            if quo = 1  then
                AddRowVector(mat[k], row, -1);
            elif quo = -1  then
                AddRowVector(mat[k], row);
            elif quo <> 0  then
                AddRowVector(mat[k], row, -quo);
            fi;
            clear := clear and mat[k][d] = 0;
        od;
        Info( InfoMatrix, 3, "    c" );

        # now perform column operations so that the entries in
        # the <d>-th row have absolute value at most pivot/2
        col := mat{[d..nrrows]}[d];
        for l  in [ d+1 .. nrcols ]  do
            quo := BestQuoInt( mat[d][l], mat[d][d] );
            if quo = 1  then
                mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - col;
            elif quo = -1  then
                mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] + col;
            elif quo <> 0  then
                mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - quo * col;
            fi;
            clear := clear and mat[d][l] = 0;
        od;
        Info( InfoMatrix, 3, "    r" );

        # repeat until the <d>-th row and column are totally cleared
        while not clear  do

            # compute the Euclidean norms of the rows and columns
            # that have a nonzero entry in the <d>-th column resp. row
            for k  in [ d .. nrrows ]  do
                if mat[k][d] <> 0  then
                    row := mat[k];
                    rownorms[k] := row * row;
                fi;
            od;
            for l  in [ d .. nrcols ]  do
                if mat[d][l] <> 0  then
                    col := mat{[d..nrrows]}[l];
                    colnorms[l] := col * col;
                fi;
            od;
            Info( InfoMatrix, 3, "    n" );

            # choose a pivot in the <d>-th row or <d>-th column
            pivk := 0;  pivl := 0;
            norm := Maximum(rownorms) * Maximum(colnorms) + 1;
            for l  in [ d+1 .. nrcols ]  do
                if 0 <> mat[d][l] and rownorms[d] * colnorms[l] < norm  then
                    pivk := d;  pivl := l;
                    norm := rownorms[d] * colnorms[l];
                fi;
            od;
            for k  in [ d+1 .. nrrows ]  do
                if 0 <> mat[k][d] and rownorms[k] * colnorms[d] < norm  then
                    pivk := k;  pivl := d;
                    norm := rownorms[k] * colnorms[d];
                fi;
            od;
            Info( InfoMatrix, 3, "    p" );

            # move the pivot to the diagonal and make it positive
            if d <> pivk  then
                row       := mat[d];
                mat[d]    := mat[pivk];
                mat[pivk] := row;
            fi;
            if d <> pivl  then
                col                    := mat{[d..nrrows]}[d];
                mat{[d..nrrows]}[d]    := mat{[d..nrrows]}[pivl];
                mat{[d..nrrows]}[pivl] := col;
            fi;
            if mat[d][d] < 0  then
                MultRowVector(mat[d],-1);
            fi;

            # now perform row operations so that the entries in the
            # <d>-th column have absolute value at most pivot/2
            clear := true;
            row := mat[d];
            for k  in [ d+1 .. nrrows ]  do
                quo := BestQuoInt( mat[k][d], mat[d][d] );
	        if quo = 1  then
                    AddRowVector(mat[k],row,-1);
                elif quo = -1  then
                    AddRowVector(mat[k],row);
                elif quo <> 0  then
                    AddRowVector(mat[k], row, -quo);
                fi;
                clear := clear and mat[k][d] = 0;
            od;
            Info( InfoMatrix, 3, "    c" );

            # now perform column operations so that the entries in
            # the <d>-th row have absolute value at most pivot/2
            col := mat{[d..nrrows]}[d];
            for l  in [ d+1.. nrcols ]  do
                quo := BestQuoInt( mat[d][l], mat[d][d] );
                if quo = 1  then
                    mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - col;
                elif quo = -1  then
                    mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] + col;
                elif quo <> 0  then
                    mat{[d..nrrows]}[l] := mat{[d..nrrows]}[l] - quo * col;
                fi;
                clear := clear and mat[d][l] = 0;
            od;
            Info( InfoMatrix, 3, "    r" );

        od;

        # print the diagonal entry (for information only)
        Info( InfoMatrix, 3, "    div=" );
        Info( InfoMatrix, 2, "      ", mat[d][d] );

        # go on to the next diagonal position
        d := d + 1;

    od;

    # close with some more information
    Info( InfoMatrix, 3, "  overall maximal entry ", omax );
    Info( InfoMatrix, 1, "DiagonalizeMat returns" );
end );


#############################################################################
##
#F  DeclarePackage( <name>, <version>, <tester> )
#F  DeclareAutoPackage( <name>, <version>, <tester> )
#F  DeclarePackageDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
#F  DeclarePackageAutoDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
#F  ReadPkg( ... )
#F  RereadPkg( ... )
#F  DoReadPkg( ... )
#F  DoRereadPkg( ... )
##
##  Up to {\GAP}~4.3, these functions were needed inside the `init.g' files
##  of {\GAP} packages, whereas from {\GAP}~4.4 on, the `PackageInfo.g' files
##  are used instead.
##  So they are needed only for those packages which have a `PackageInfo.g'
##  file as well as an `init.g' file that works also with {\GAP}~4.3
##  (or older).
##  They can be removed as soon as none of the available packages calls them.
##
BindGlobal( "DeclarePackage", Ignore );
BindGlobal( "DeclareAutoPackage", Ignore );
BindGlobal( "DeclarePackageAutoDocumentation", Ignore );
BindGlobal( "DeclarePackageDocumentation", Ignore );
BindGlobal( "ReadPkg", ReadPackage );
BindGlobal( "RereadPkg", RereadPackage );
BindGlobal( "DoReadPkg", function( arg )
    ReadPackage( arg[1] );
    return true;
    end );
BindGlobal( "DoRereadPkg", function( arg )
    RereadPackage( arg[1] );
    return true;
    end );


#############################################################################
##
#V  KERNEL_VERSION
#V  VERSION
#V  GAP_ARCHITECTURE
#V  GAP_ROOT_PATHS
#V  USER_HOME
#V  GAP_RC_FILE
#V  DO_AUTOLOAD_PACKAGES
#V  DEBUG_LOADING
#V  CHECK_FOR_COMP_FILES
#V  BANNER
#V  QUIET
#V  AUTOLOAD_PACKAGES
#V  LOADED_PACKAGES
##
##  Up to {\GAP}~4.3, these global variables were used instead of the new
##  record `GAPInfo'.
##
##  Note that also `AUTOLOAD_PACKAGES' gets bound in `init.g'.
##
BindGlobal( "KERNEL_VERSION", GAPInfo.KernelVersion );
BindGlobal( "VERSION", GAPInfo.Version );
BindGlobal( "GAP_ARCHITECTURE", GAPInfo.Architecture );
BindGlobal( "GAP_ROOT_PATHS", GAPInfo.RootPaths );
BindGlobal( "USER_HOME", GAPInfo.UserHome );
BindGlobal( "GAP_RC_FILE", GAPInfo.gaprc );
BindGlobal( "DO_AUTOLOAD_PACKAGES", not GAPInfo.CommandLineOptions.A );
BindGlobal( "DEBUG_LOADING", GAPInfo.CommandLineOptions.D );
BindGlobal( "CHECK_FOR_COMP_FILES", not GAPInfo.CommandLineOptions.N );
BindGlobal( "BANNER", not GAPInfo.CommandLineOptions.b );
BindGlobal( "QUIET", GAPInfo.CommandLineOptions.q );
BindGlobal( "LOADED_PACKAGES", GAPInfo.PackagesLoaded );


#############################################################################
##
#F  P( <obj> )
##
##  This was defined in `init.g' before `banner.g' was read.
##
P := function(a) Print("   ", a, "\n" );  end;


#############################################################################
##
#F  ListSorted( <coll> )
#F  AsListSorted(<coll>)
##
##  These operations are obsolete and will vanish in future versions. They
##  are included solely for temporary compatibility with beta releases but
##  should *never* be used. Use `SSortedList' and `AsSSortedList' instead!
ListSorted := function(coll)
  Info(InfoWarning,1,"The command `ListSorted' will *not* be supported in",
        "further versions!");
  return SSortedList(coll);
end;

AsListSorted := function(coll)
  Info(InfoWarning,1,"The command `AsListSorted' will *not* be supported in",
        "further versions!");
  return AsSSortedList(coll);
end;


#############################################################################
##
#A  NormedVectors( <V> )
##
DeclareSynonymAttr( "NormedVectors", NormedRowVectors );


#############################################################################
##
#F  SameBlock( <tbl>, <p>, <omega1>, <omega2>, <relevant>, <exponents> )
##
##  Let <tbl> be an ordinary character table, <p> a prime integer, <omega1>
##  and <omega2> two central characters (or their values lists) of <tbl>.
##  The remaining arguments <relevant> and <exponents> are lists as stored in
##  the components `relevant' and `exponents' of a record returned by
##  `PrimeBlocks' (see~"PrimeBlocks").
##
##  `SameBlock' returns `true' if <omega1> and <omega2> are equal modulo any
##  maximal ideal in the ring of complex algebraic integers containing the
##  ideal spanned by <p>, and `false' otherwise.
##
##  The above syntax was supported and documented in {\GAP}~4.3.
##  In {\GAP}~4.4, the first and the last argument were omitted because they
##  turned out to be unnecessary.  (The record returned by `PrimeBlocks' does
##  no longer have a component `exponents'.)
##  From {\GAP}~4.5 on, only the four argument version will be supported.
##  


#############################################################################
##
#F  TryConwayPolynomialForFrobeniusCharacterValue( <p>, <n> )
##
##  This name is needed just for backwards compatibility with {\GAP}~4.4.
##  Now one should better use `IsCheapConwayPolynomial' directly.
##
DeclareSynonym( "TryConwayPolynomialForFrobeniusCharacterValue",
    IsCheapConwayPolynomial );


#############################################################################
##
#E

