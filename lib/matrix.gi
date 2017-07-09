#############################################################################
##
#W  matrix.gi                   GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Alexander Hulpke
#W                                                           & Heiko Theißen
#W                                                         & Martin Schönert
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains methods for matrices.
##


#
# Kernel method for computing
#

InstallMethod(Zero,
        [IsRectangularTable and IsAdditiveElementWithZeroCollColl and IsInternalRep],
        ZERO_ATTR_MAT);

#############################################################################
##
#F  PrintArray( <array> ) . . . . . . . . . . . . . . . . pretty print matrix
##
InstallGlobalFunction(PrintArray,function( array )
    local   arr,  max,  l,  k,maxp,compact,bl;

    compact:=ValueOption("compact")=true;
    if compact then 
      maxp:=0;
      bl:="";
    else 
      maxp:=1;
      bl:=" ";
    fi;
    if not IsDenseList( array ) then
        Error( "<array> must be a dense list" );
    elif Length( array ) = 0  then
        Print( "[ ]\n" );
    elif array = [[]]  then
        Print( "[ [ ] ]\n" );
    elif not ForAll( array, IsList )  then
        arr := List( array, String );
        max := Maximum( List( arr, Length ) );
        Print( "[ ", String( arr[ 1 ], max + maxp ) );
        for l  in [ 2 .. Length( arr ) ]  do
            Print( ", ", String( arr[ l ], max + 1 ) );
        od;
        Print( " ]\n" );
    else
        arr := List( array, x -> List( x, String ) );
	if compact then
	  max:=List([1..Length(arr[1])],
	    x->Maximum(List([1..Length(arr)],y->Length(arr[y][x]))));
	else
	  max := Maximum( List( arr, 
                    function(x)
                         if Length(x) = 0 then
                             return 1;
                         else
                             return Maximum( List(x,Length) );
                         fi;
                         end) );
	fi;

        Print( "[",bl );
        for l in [ 1 .. Length( arr ) ] do
            if l > 1 then
                Print(bl," ");
            fi;
            Print( "[",bl );
            if Length(arr[ l ]) = 0 then
                Print(bl,bl,"]" );
            else
                for k  in [ 1 .. Length( arr[ l ] ) ]  do
		  if compact then
		    Print( String( arr[ l ][ k ], max[k] + maxp ) );
		  else
		    Print( String( arr[ l ][ k ], max + maxp ) );
		  fi;
		  if k = Length( arr[ l ] )  then
		      Print( bl,"]" );
		  else
		      Print( ", " );
		  fi;
                od;
            fi;
            if l = Length( arr )  then
                Print( bl,"]\n" );
            else
                Print( ",\n" );
            fi;
        od;
    fi;
end);


##########################################################################
##
#M  Display( <mat> )
##
InstallMethod( Display,
    "for a matrix",
    [IsMatrix ],
    PrintArray );


#############################################################################
##
#M  IsGeneralizedCartanMatrix( <A> )
##
InstallMethod( IsGeneralizedCartanMatrix,
    "for a matrix",
    [ IsMatrix ],
    function( A )

    local n, i, j;

    if Length( A ) <> Length( A[1] ) then
      Error( "<A> must be a square matrix" );
    fi;

    n:= Length( A );
    for i in [ 1 .. n ] do
      if A[i][i] <> 2 then
        return false;
      fi;
    od;
    for i in [ 1 .. n ] do
      for j in [ i+1 .. n ] do
        if not IsInt( A[i][j] ) or not IsInt( A[j][i] )
           or 0 < A[i][j] or 0 < A[j][i] then
          return false;
        elif  ( A[i][j] = 0 and A[j][i] <> 0 )
           or ( A[j][i] = 0 and A[i][j] <> 0 ) then
          return false;
        fi;
      od;
    od;
    return true;
    end );


#############################################################################
##
#M  IsDiagonalMat(<mat>)
##
InstallMethod( IsDiagonalMat,
    "for a matrix",
    [ IsMatrix ],
    function( mat )
   local  i, j,z;
    if IsEmpty(mat) then return true;fi;
    z:=Zero(mat[1][1]);
    for i  in [ 1 .. Length( mat ) ]  do
        for j  in [ 1 .. Length( mat[i] ) ]  do
            if mat[i][j] <> z and i <> j  then
                return false;
            fi;
        od;
    od;
    return true;
    end);

InstallOtherMethod( IsDiagonalMat, [ IsEmpty ], ReturnTrue );


#############################################################################
##
#M  IsUpperTriangularMat(<mat>)
##
InstallMethod( IsUpperTriangularMat,
    "for a matrix",
    [ IsMatrix ],
    function( mat )
    local  i, j,z;
    if IsEmpty(mat) then return true;fi;
    z:=Zero(mat[1][1]);
    for i  in [ 1 .. Length( mat ) ]  do
        for j  in [ 1 .. i-1]  do
            if mat[i][j] <> z  then
                return false;
            fi;
        od;
    od;
    return true;
    end);

#############################################################################
##
#M  IsLowerTriangularMat(<mat>)
##
InstallMethod( IsLowerTriangularMat,
    "for a matrix",
    [ IsMatrix ],
    function( mat )
    local  i, j,z;
    if IsEmpty(mat) then return true;fi;
    z:=Zero(mat[1][1]);
    for i  in [ 1 .. Length( mat ) ]  do
        for j  in [ i+1 .. Length( mat[i] ) ]  do
            if mat[i][j] <> z  then
                return false;
            fi;
        od;
    od;
    return true;
    end);

#############################################################################
##
#M  DiagonalOfMat(<mat>)  . . . . . . . . . . . . . . . .  diagonal of matrix
##
InstallGlobalFunction( DiagonalOfMat, function ( mat )
    local   diag, i;

    diag := [];
    i := 1;
    while i <= Length(mat) and i <= Length(mat[1]) do
        diag[i] := mat[i][i];
        i := i + 1;
    od;
    while 1 <= Length(mat) and i <= Length(mat[1]) do
        diag[i] := mat[1][1] - mat[1][1];
        i := i + 1;
    od;
    return diag;
end );


#############################################################################
##
#R  IsNullMapMatrix . . . . . . . . . . . . . . . . . . .  null map as matrix
##
DeclareRepresentation( "IsNullMapMatrix", IsMatrix, [  ] );

BindGlobal( "NullMapMatrix",
    Objectify( NewType( ListsFamily, IsNullMapMatrix ), MakeImmutable([  ]) ) );

InstallMethod( Length,
    "for null map matrix",
    [ IsNullMapMatrix ],
    null -> 0 );

InstallMethod( IsZero,
    "for null map matrix",
    [ IsNullMapMatrix ],
    x -> true);

InstallMethod( ZERO,
    "for null map matrix",
    [ IsNullMapMatrix ],
    null -> null );

InstallMethod( \+,
    "for two null map matrices",
    [ IsNullMapMatrix, IsNullMapMatrix ],
    function(null,null2)
    return null;
end );

InstallMethod( AINV,
    "for a null map matrix",
    [ IsNullMapMatrix ],
    null -> null );

InstallMethod( AdditiveInverseOp,
    "for a null map matrix",
    [ IsNullMapMatrix ],
    null -> null );    

InstallMethod( \*,
    "for two null map matrices",
    [ IsNullMapMatrix, IsNullMapMatrix ],
    function(null,null2)
    return null;
end );

InstallMethod( \*,
    "for a scalar and a null map matrix",
    [ IsScalar, IsNullMapMatrix ],
    function(s,null)
    return null;
end );

InstallMethod( \*,
    "for a null map matrix and a scalar",
    [ IsNullMapMatrix, IsScalar ],
    function(null,s)
    return null;
end );

InstallMethod( \*,
    "for vector and null map matrix",
    [ IsVector, IsNullMapMatrix ],
    function( v, null )
    return [  ];
end );

InstallOtherMethod( \*,
    "for empty list and null map matrix",
    [ IsList and IsEmpty, IsNullMapMatrix ],
    function( v, null )
    return [  ];
end );

InstallMethod( \*,
    "for matrix and null map matrix",
    [ IsMatrix, IsNullMapMatrix ],
    function( A, null )
    return List( A, row -> [  ] );
end );

InstallOtherMethod( \*,
    "for list and null map matrix",
    [ IsList, IsNullMapMatrix ],
    function( A, null )
    return List( A, row -> [  ] );
end );

InstallMethod( ViewObj,
    "for null map matrix",
    [ IsNullMapMatrix ],
    function( null )
    Print( "<null map>" );
end );

InstallMethod( PrintObj,
    "for null map matrix",
    [ IsNullMapMatrix ],
    function( null )
    Print( "NullMapMatrix" );
end );

#############################################################################
##
#F  Matrix_OrderPolynomialInner( <fld>, <mat>, <vec>, <spannedspace> )
##
##  Returns the coefficients of the order polynomial of <mat> at <vec>
##  modulo <spannedspace>. No conversions are attempted on <mat> or
##  <vec>, which should usually be immutable and compressed for best
##  results. <spannedspace> should be a semi-echelonized basis, stored
##  as a list with holes with the vector with pivot <i> in position <i>
##  Vectors are added to <spannedspace> so that it also spans all the images
##  of <vec> under the algebra generated by <mat>
##
##  The result, and any vectors added to <spannedspace> are compressed
##  and immutable
##
#N  In characteristic zero, or for structured sparse matrices, the naive
#N  Gaussian elimination here may not be optimal
##
#N  Shift to using ClearRow once we have kernel methods that give a
#N  performance benefit
##
BindGlobal( "Matrix_OrderPolynomialInner", function( fld, mat, vec, vecs)
    local d, w, p, one, zero, zeroes, piv,  pols, x, t;
    Info(InfoMatrix,2,"Order Polynomial Inner on ",Length(mat[1]),
         " x ",Length(mat)," matrix over ",fld," with ",
         Number(vecs)," basis vectors already given");
    d := Length(vec);
    pols := [];
    one := One(fld);
    zero := Zero(fld);
    zeroes := [];

    # this loop runs images of <vec> under powers of <mat>
    # trying to reduce them with smaller powers (and tracking the polynomial)
    # or with vectors from <spannedspace> as passed in
    # when we succeed, we know the order polynomial

    repeat
        w := ShallowCopy(vec);
        p := ShallowCopy(zeroes);
        Add(p,one);
        ConvertToVectorRepNC(p,fld);
        piv := PositionNonZero(w,0);

        #
        # Strip as far as we can
        #

        while piv <= d and IsBound(vecs[piv]) do
            x := -w[piv];
            if IsBound(pols[piv]) then
                AddCoeffs(p, pols[piv], x);
            fi;
            AddRowVector(w, vecs[piv],  x, piv, d);
            piv := PositionNonZero(w,piv);
        od;

        #
        # if something is left then we don't have the order poly yet
        # update tables etc.
        #

        if piv <=d  then
            x := Inverse(w[piv]);
            MultRowVector(p, x);
            MakeImmutable(p);
            pols[piv] := p;
            MultRowVector(w, x );
            MakeImmutable(w);
            vecs[piv] := w;
            vec := vec*mat;
            Add(zeroes,zero);
        fi;
    until piv > d;
    MakeImmutable(p);
    Info(InfoMatrix,2,"Order Polynomial returns ",p);
    return p;
end );

#############################################################################
##
#F  Matrix_OrderPolynomialSameField( <fld>, <mat>, <vec>, <ind> )
##
##  Compute the order polynomial, all the work is done in the
##  routine above
##
BindGlobal( "Matrix_OrderPolynomialSameField", function( fld, mat, vec, ind )
    local imat, ivec, coeffs;
    imat:=ImmutableMatrix(fld,mat);
    ivec := Immutable(vec);
    ConvertToVectorRepNC(ivec, fld);
    coeffs := Matrix_OrderPolynomialInner( fld, imat, ivec, []);
    return UnivariatePolynomialByCoefficients(ElementsFamily(FamilyObj(fld)), coeffs, ind );
end );


#############################################################################
##
#F  Matrix_CharacteristicPolynomialSameField( <fld>, <mat>, <ind> )
##
BindGlobal( "Matrix_CharacteristicPolynomialSameField",
    function( fld, mat, ind)
    local i, n, ords, base, imat, vec, one,cp,op,zero,fam;
    Info(InfoMatrix,1,"Characteristic Polynomial called on ",
         Length(mat[1])," x ",Length(mat)," matrix over ",fld);
    imat := ImmutableMatrix(fld,mat);
    n := Length(mat);
    base := [];
    vec := ZeroOp(mat[1]);
    one := One(fld);
    zero := Zero(fld);
    fam := ElementsFamily(FamilyObj(fld));
    cp:=[one];
    if Is8BitMatrixRep(mat) and Length(mat)>0 then
      # stay in the same field as matrix
      ConvertToVectorRepNC(cp,Q_VEC8BIT(mat[1]));
    fi;
    cp := UnivariatePolynomialByCoefficients(fam,cp,ind);
    for i in [1..n] do
        if not IsBound(base[i]) then
            vec[i] := one;
            op := Matrix_OrderPolynomialInner( fld, imat, vec, base);
            cp := cp *  UnivariatePolynomialByCoefficients( fam,op,ind);
            vec[i] := zero;
        fi;
    od;
    Assert(3, IsZero(Value(cp,imat)));
    Assert(2, Length(CoefficientsOfUnivariatePolynomial(cp)) = n+1);
    Info(InfoMatrix,1,"Characteristic Polynomial returns ", cp);
    return cp;
end );


##########################################################################
##
#F  Matrix_MinimalPolynomialSameField( <fld>, <mat>, <ind> )
##
BindGlobal( "Matrix_MinimalPolynomialSameField", function( fld, mat, ind )
    local i, n, ords, base, imat, vec, one,cp,zero, fam,
          processVec, mp, dim, span,op,w, piv,j,ring;

    Info(InfoMatrix,1,"Minimal Polynomial called on ",
         Length(mat[1])," x ",Length(mat)," matrix over ",fld);
    imat := ImmutableMatrix(fld,mat);
    n := Length(imat);
    base := [];
    dim := 0; # should be number of bound positions in base
    one := One(fld);
    zero := Zero(fld);
    fam := ElementsFamily(FamilyObj(fld));
    mp:=[one];
    if Is8BitMatrixRep(mat) and Length(mat)>0 then
      # stay in the same field as matrix
      ConvertToVectorRepNC(mp,Q_VEC8BIT(mat[1]));
    fi;
    #keep coeffs
    #mp := UnivariatePolynomialByCoefficients( fam, mp,ind);
    while dim < n do
        vec := ShallowCopy(mat[1]);
        for i in [1..n] do
          #Add(vec,Random([one,zero]));
          vec[i]:=Random([one,zero]);
        od;
        vec[Random([1..n])] := one; # make sure it's not zero
        #ConvertToVectorRepNC(vec,fld);
        MakeImmutable(vec);
        span := [];
        op := Matrix_OrderPolynomialInner( fld, imat, vec, span);
        #op := UnivariatePolynomialByCoefficients(fam, op, ind);
        #mp := Lcm(mp, op);
        # this command takes much time since a polynomial ring is created.
        # Instead use the quick gcd-based method (avoiding the dispatcher):
        #mp := (mp*op)/GcdOp(mp, op);
        #mp:=mp/LeadingCoefficient(mp);
        mp:=QUOTREM_LAURPOLS_LISTS(ProductCoeffs(mp,op),GcdCoeffs(mp,op))[1];
        mp:=mp/mp[Length(mp)];

        for j in [1..Length(span)] do
            if IsBound(span[j]) then
                if dim < n then
                    if not IsBound(base[j]) then
                        base[j] := span[j];
                        dim := dim+1;
                    else
                        w := ShallowCopy(span[j]);
                        piv := j;
                        repeat
                            AddRowVector(w,base[piv],-w[piv], piv, n);
                            piv := PositionNot(w, zero, piv);
                        until piv > n or not IsBound(base[piv]);
                        if piv <= n then
                            MultRowVector(w,Inverse(w[piv]));
                            MakeImmutable(w);
                            base[piv] := w;
                            dim := dim+1;
                        fi;
                    fi;
                fi;
            fi;
        od;
    od;
    mp := UnivariatePolynomialByCoefficients( fam, mp,ind);
    Assert(3, IsZero(Value(mp,imat)));
    Info(InfoMatrix,1,"Minimal Polynomial returns ", mp);
    return mp;
end );


##########################################################################
##
#M  Display( <ffe-mat> )
##
InstallMethod( Display,
    "for matrix of FFEs",
    [ IsFFECollColl and IsMatrix ],
function( m )
    local   deg,  chr,  zero,  w,  t,  x,  v,  f,  z,  y;

    if Length(m[1]) = 0 then
        TryNextMethod();
    fi;
    if  IsZmodnZObj(m[1][1]) then
      # this case mostly applies to large characteristic, in
      # which the regular code for FFE elements does not work
      # (e.g. it tries to create the range [2..chr], which
      # means chr may be at most 2^28 resp. 2^60).
      Print("ZmodnZ matrix:\n");
      t:=List(m,i->List(i,i->i![1]));
      Display(t);
      Print("modulo ",Characteristic(m[1][1]),"\n");
    else
      # get the degree and characteristic
      deg  := Lcm( List( m, DegreeFFE ) );
      chr  := Characteristic(m[1][1]);
      zero := Zero(m[1][1]);

      # if it is a finite prime field,  use integers for display
      if deg = 1  then

        # compute maximal width
        w := LogInt( chr, 10 ) + 2;

        # create strings
        t := [];
        for x  in [ 2 .. chr ]  do
            t[x] := String( x-1, w );
        od;
#T useful only for (very) small characteristic, or?
        t[1] := String( ".", w );

        # print matrix
        for v  in m  do
            for x  in List( v, IntFFE )  do
#T !
                Print( t[x+1] );
            od;
            Print( "\n" );
        od;

      # if it a finite,  use mixed integers/z notation
#T ...
      else
          Print( "z = Z(", chr^deg, ")\n" );

        # compute maximal width
        w := LogInt( chr^deg-1, 10 ) + 4;

        # create strings
        t := [];
        f := GF(chr^deg);
        z := Z(chr^deg);
        for x  in [ 0 .. Size(f)-2 ]  do
            y := z^x;
            if DegreeFFE(y) = 1  then
                t[x+2] := String( IntFFE(y), w );
#T !
            else
                t[x+2] := String(Concatenation("z^",String(x)),w);
            fi;
        od;
        t[1] := String( ".", w );

        # print matrix
        for v  in m  do
            for x  in v  do
                if x = zero  then
                    Print( t[1] );
                else
                    Print( t[LogFFE(x,z)+2] );
                fi;
            od;
            Print( "\n" );
        od;

      fi;
    fi;
end );


##########################################################################
##
#M  Display( <ZmodnZ-mat> )
##
InstallMethod( Display,
    "for matrix over Integers mod n",
    [ IsZmodnZObjNonprimeCollColl and IsMatrix ],
    function( m )
    Print( "matrix over Integers mod ", Characteristic( m[1][1] ),
           ":\n" );
    Display( List( m, i -> List( i, i -> i![1] ) ) );
    end );


#############################################################################
##
#M  CharacteristicPolynomial( <mat> )
##
InstallMethod( CharacteristicPolynomial,
    "supply field and indeterminate 1",
    [ IsMatrix ],
    mat -> CharacteristicPolynomialMatrixNC( 
            DefaultFieldOfMatrix( mat ), mat, 1 ) );


#############################################################################
##
#M  CharacteristicPolynomial( <F>, <E>, <mat> )
##
InstallMethod( CharacteristicPolynomial,
    "supply indeterminate 1",
    function (famF, famE, fammat)
        local fam;
        if HasElementsFamily (fammat) then
            fam := ElementsFamily (fammat);
            return IsIdenticalObj (famF, fam) and IsIdenticalObj (famE, fam);
        fi;
        return false;
    end,
    [ IsField, IsField, IsMatrix ],
    function( F, E, mat )
    return CharacteristicPolynomial( F, E, mat, 1);
    end );


#############################################################################
##
#M  CharacteristicPolynomial( <mat>, <indnum> )
##
InstallMethod( CharacteristicPolynomial,
    "supply field",
    [ IsMatrix, IsPosInt ],
    function( mat, indnum )
        local F;
        F := DefaultFieldOfMatrix( mat );
        return CharacteristicPolynomial( F, F, mat, indnum );
    end );


#############################################################################
##
#M  CharacteristicPolynomial( <subfield>, <field>, <matrix>, <indnum> )
##
InstallMethod( CharacteristicPolynomial, "spinning over field",
    function (famF, famE, fammat, famid)
        local fam;
        if HasElementsFamily (fammat) then
            fam := ElementsFamily (fammat);
            return IsIdenticalObj (famF, fam) and IsIdenticalObj (famE, fam);
        fi;
        return false;
    end,
    [ IsField, IsField, IsOrdinaryMatrix, IsPosInt ],
    function( F, E, mat, inum )
        local fld, B;

        if not IsSubset (E, F) then
            Error ("<F> must be a subfield of <E>.");
        elif F <> E then
          # Replace the matrix by a matrix with the same char. polynomial
          # but with entries in `F'.
          B:= Basis( AsVectorSpace( F, E ) );
          mat:= BlownUpMat( B, mat );
        fi;

        return CharacteristicPolynomialMatrixNC( F, mat, inum);
    end );


InstallMethod( CharacteristicPolynomialMatrixNC, "spinning over field",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ],
  Matrix_CharacteristicPolynomialSameField);


#############################################################################
##
#M  MinimalPolynomial( <field>, <matrix>, <indnum> )
##
InstallMethod( MinimalPolynomial,
    "spinning over field",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ],
function( F, mat,inum )
    local fld, B;

    fld:= DefaultFieldOfMatrix( mat );

    if fld <> fail and not IsSubset( F, fld ) then

      # Replace the matrix by a matrix with the same minimal polynomial
      # but with entries in `F'.
      if not IsSubset( fld, F ) then
        fld:= ClosureField( fld, F );
      fi;
      B:= Basis( AsField( F, fld ) );
      mat:= BlownUpMat( B, mat );

    fi;

    return MinimalPolynomialMatrixNC( F, mat,inum);
end );

InstallOtherMethod( MinimalPolynomial,
    "supply field",
    [ IsMatrix,IsPosInt ],
function(m,n)
  return MinimalPolynomial( DefaultFieldOfMatrix( m ), m, n );
end);

InstallOtherMethod( MinimalPolynomial,
    "supply field and indeterminate 1",
    [ IsMatrix ],
function(m)
  return MinimalPolynomial( DefaultFieldOfMatrix( m ), m, 1 );
end);

InstallMethod( MinimalPolynomialMatrixNC, "spinning over field",
    IsElmsCollsX,
    [ IsField, IsOrdinaryMatrix, IsPosInt ],
  Matrix_MinimalPolynomialSameField);


#############################################################################
##
#M  Order( <mat> )  . . . . . . . . . . . . . . . . . . . . order of a matrix
##
OrderMatLimit := 1000;

InstallOtherMethod( Order,
    "generic method for ordinary matrices",
    [ IsOrdinaryMatrix ],
function ( mat )
    local   m, rank;

    # check that the argument is an invertible square matrix
    m := Length(mat);
    if m <> Length(mat[1])  then
        Error( "Order: <mat> must be a square matrix" );
    fi;
    rank:= RankMat( mat );
    if rank = fail then
      if not IsUnit( DeterminantMat( mat ) ) then
        Error( "Order: <mat> must be invertible" );
      fi;
    elif rank <> m  then
      Error( "Order: <mat> must be invertible" );
#T also test here that the determinant is in fact a unit in the ring
#T that is generated by the matrix entries?
#T (Do we need `IsPossiblyInvertibleMat' and `IsSurelyInvertibleMat',
#T the first meaning that the inverse in some ring exists,
#T the second meaning that the inverse exists in the ring generated by the
#T matrix entries?
#T For `Order', it is `IsSurelyInvertibleMat' that one wants to check;
#T then one can return `infinity' if the determinant is not a unit in the
#T ring generated by the matrix entries.)
    fi;

    # loop over the standard basis vectors
    return OrderMatTrial(mat,infinity);
end );


#############################################################################
##
#F  OrderMatTrial( <mat>,<lim> )
##
InstallGlobalFunction(OrderMatTrial,function(mat,lim)
local ord,i,vec,v,o;

  # loop over the standard basis vectors
  ord := 1;
  for i  in [1..Length(mat)]  do

    # compute the length of the orbit of the <i>th standard basis vector
    # (equivalently, of the orbit of `mat[<i>]',
    # the image of the standard basis vector under `mat')
    vec := mat[i];
    v   := vec * mat;
    o   := 1;
    while v <> vec  do
      v := v * mat;
      o := o + 1;
      if o>lim then
        return fail;
      elif OrderMatLimit = o  and Characteristic(v[1])=0 then
        Info( InfoWarning, 1,
              "Order: warning, order of <mat> might be infinite" );
      fi;
    od;

    # raise the matrix to this length (new mat will fix basis vector)
    if o>1 then
      mat := mat ^ o;
      ord := ord * o;
    fi;
  od;
  if IsOne(mat) then return ord; else return fail; fi;
end);


# #############################################################################
# ##
# #M  Order( <cycmat> ) . . . . . . . . . . .  order of a matrix of cyclotomics
# ##
# ##  The idea is to compute the minimal polynomial of the matrix,
# ##  and to decompose this polynomial into cyclotomic polynomials.
# ##  This is due to R. Beals, who used it in his `grim' package for {\GAP}~3.
# ##
# InstallMethod( Order,
#     "ordinary matrix of cyclotomics",
#     [ IsOrdinaryMatrix and IsCyclotomicCollColl ],
#     function( cycmat )
#     local m,       # dimension of the matrix
#           trace,   # trace of the matrix
#           minpol,  # minimal polynomial of the matrix
#           n,       # degree of `minpol'
#           p,       # loop over small primes
#           t,       # product of the primes `p'
#           l,       # product of the values `p-1'
#           ord,     # currently known factor of the order
#           d,       # loop over the indices of cyclotomic polynomials
#           phi,     # `Phi( d )'
#           c,       # `d'-th cyclotomic polynomial
#           q;       # quotient and remainder
# 
#     # Before we start with expensive calculations,
#     # we check whether the matrix has a *small* order.
#     ord:= OrderMatTrial( cycmat, OrderMatLimit - 1 );
#     if ord <> fail then
#       return ord;
#     fi;
# 
#     # Check that the argument is an invertible square matrix.
#     m:= Length( cycmat );
#     if m <> Length( cycmat[1] ) then
#       Error( "Order: <cycmat> must be a square matrix" );
#     elif RankMat( cycmat ) <> m  then
#       Error( "Order: <cycmat> must be invertible" );
#     fi;
# #T Here I could compute the inverse;
# #T its trace could be checked, too.
# #T Additionally, if `mat' consists of (algebraic) integers
# #T and the inverse does not then the order of `mat' is infinite.
# 
#     # If the order is finite then the trace must be an algebraic integer.
#     trace:= TraceMat( cycmat );
#     if not IsIntegralCyclotomic( trace ) then
#       return infinity;
#     fi;
# 
#     # If the order is finite then the absolute value of the trace
#     # is bounded by the dimension of the matrix.
# #T compute this (approximatively) for arbitrary cyclotomics
# #T (by the way: why isn't this function called `AbsRat'?)
#     if IsInt( trace ) and Length( cycmat ) < AbsInt( trace ) then
#       return infinity;
#     fi;
# 
#     # Compute the minimal polynomial of the matrix.
#     minpol:= MinimalPolynomial( Rationals, cycmat );
#     n:= DegreeOfLaurentPolynomial( minpol );
# 
#     # The order is finite if and only if the minimal polynomial
#     # is a product of cyclotomic polynomials.
#     # (Note that cyclotomic polynomials over the rationals are irreducible.)
# 
#     # A necessary condition is that the constant term of the polynomial
#     # is $\pm 1$, since this holds for every cyclotomic polynomial.
#     if AbsInt( Value( minpol, 0 ) ) <> 1 then
#       return infinity;
#     fi;
# 
#     # Another necessary condition is that no irreducible factor
#     # may occur more than once.
#     # (Note that the minimal polynomial divides $X^{ord} - 1$.)
#     if not IsOne( Gcd( minpol, Derivative( minpol ) ) ) then
#       return infinity;
#     fi;
# 
#     # Compute an upper bound `t' for the numbers $i$ with the property
#     # that $\varphi(i) \leq n$ holds.
#     # (Let $p_k$ denote the $k$-th prime divisor of $i$,
#     # and $q_k$ the $k$-th prime; then clearly $q_k \leq p_k$ holds.
#     # Now let $h$ be the smallest *positive* integer --be careful that the
#     # products considered below are not empty-- such that
#     # $\prod_{k=1}^h ( q_k - 1 ) \geq n$, and set $t = \prod_{k=1}^h q_k$.
#     # If $i$ has the property $\varphi(i) \leq n$ then
#     # $i \leq n \frac{i}{\varphi(i)} = n \prod_{k} \frac{p_k}{p_k-1}$.
#     # Replacing $p_k$ by $q_k$ means to replace the factor
#     # $\frac{p_k}{p_k-1}$ by a larger factor,
#     # and if $i$ has less than $h$ prime divisors then
#     # running over the first $h$ primes increases the value of the product
#     # again, so we get $i \leq n \prod_{k=1}^h \frac{q_k}{q_k-1} \leq t$.)
#     p:= 2;
#     t:= 2;
#     l:= 1;
#     while l < n do
#       p:= NextPrimeInt( p );
#       t:= t * p;
#       l:= l * ( p - 1 );
#     od;
# 
#     # Divide by each possible cyclotomic polynomial.
#     ord:= 1;
#     for d in [ 1 .. t ] do
# 
#       phi:= Phi( d );
#       if phi <= n then
#         c:= CyclotomicPolynomial( Rationals, d );
#         q:= QuotientRemainder( minpol, c );
#         if IsZero( q[2] ) then
#           minpol:= q[1];
#           n:= n - phi;
#           ord:= Lcm( ord, d );
#           if n = 0 then
# 
#             # The minimal polynomial is a product of cyclotomic polynomials.
#             return ord;
# 
#           fi;
#         fi;
#       fi;
# 
#     od;
# 
#     # The matrix has infinite order.
#     return infinity;
#     end );


#############################################################################
##
#M  Order( <mat> )  . . . . . . . . . . . .  order of a matrix of cyclotomics
##
InstallMethod( Order,
               "for a matrix of cyclotomics, with Minkowski kernel",
               [ IsOrdinaryMatrix and IsCyclotomicCollColl ],

  function ( mat )

    local dim, F, tracemat, lat, red, det, trace, order, orddet, powdet,
          ordpowdet, I;

    # Check that the argument is an invertible square matrix.
    dim:= Length( mat );
    if dim <> Length( mat[1] ) then
      Error( "Order: <mat> must be a square matrix" );
    fi;

    # Before we start with expensive calculations,
    # we check whether the matrix has a *very small* order.
    order:= OrderMatTrial( mat, 6 );
    if order <> fail then return order; fi;

    # We compute the determinant <det>, issue an error message in case <mat>
    # is not invertible, compute the order <orddet> of <det> and check
    # whether <mat>^<orddet> has small order.
    det := DeterminantMat( mat );
    if det = 0 then Error( "Order: <mat> must be invertible" ); fi;
    orddet := Order(det);
    if orddet = infinity then return infinity; fi;
    powdet := mat^orddet;
    ordpowdet := OrderMatTrial( powdet, 12 );
    if ordpowdet <> fail then return orddet * ordpowdet; fi;

    # If the order is finite then the trace must be an algebraic integer.
    trace := TraceMat( mat );
    if not IsIntegralCyclotomic( trace ) then return infinity; fi;

    # If the order is finite then the absolute value of the trace
    # is bounded by the dimension of the matrix.
    if IsInt( trace ) and Length( mat ) < AbsInt( trace ) then
      return infinity;
    fi;

    F:= DefaultFieldOfMatrix( mat );

    # Convert to a rational matrix if necessary.
    if 1 < Conductor( F ) then

      # Check whether the trace is larger than the dimension.
      tracemat := BlownUpMat( Basis(F), [[ trace ]] );
      if   AbsInt(Trace(tracemat)) > Length(mat) * Length(tracemat)
      then return infinity; fi;

      mat:= BlownUpMat( Basis( F ), mat );
      dim:= Length( mat );
    fi;

    # Convert to an integer matrix if necessary.
    if not ForAll( mat, row -> ForAll( row, IsInt ) ) then

      # The following checks trace and determinant.
      lat:= InvariantLattice( GroupWithGenerators( [ mat ] ) );
      if lat = fail then
        return infinity;
      fi;
      mat:= lat * mat * Inverse( lat );

    fi;

    # Compute the order of the reduction modulo $2$.
    red:= mat * Z(2);
    ConvertToMatrixRep(red,2);
    order:= Order( red );
#T if OrderMatTrial was used above then call `ProjectiveOrder' directly?

    # Now use the theorem (see Morris Newman, Integral Matrices)
    # that `mat' has infinite order if the `2 * order'-th
    # power is not equal to the identity matrix.
    I:= IdentityMat( dim );
#T supply better `IsOne' method for matrices, without constructing an object!
    mat:= mat ^ order;
    if mat = I then
      return order;
    elif mat ^ 2 = I then
      return 2 * order;
    else
      return infinity;
    fi;
  end );

#############################################################################
##
#M  Order( <ffe-mat> )  . . . . .  order of a matrix of finite field elements
##
InstallMethod( Order, "ordinary matrix of finite field elements", true,
    [ IsOrdinaryMatrix and IsFFECollColl ], 0,
        function( mat )
    local   o;
    # catch the (unlikely in GL but likely in group theory...) case that mat
    # has a small order
    
    # the following limit is very crude but seems to work OK. It picks small
    # orders but still does not cost too much if the order gets larger.
    if Length(mat) <> Length(mat[1]) then
        Error("Order of non-square matrix is not defined");
    fi;
    o:=Characteristic(mat[1][1])^DegreeFFE(mat[1][1]); # size of field of
                                                     # first entry
    o:=QuoInt(Length(mat),o)*5; 

    o:=OrderMatTrial(mat,o);
    if o<>fail then
        return o;
    fi;
    
    o := ProjectiveOrder(mat);
    return o[1] * Order( o[2] );
end );


#############################################################################
##
#M  IsZero( <mat> )
##
InstallMethod( IsZero,
    "method for a matrix",
    [ IsMatrix ],
    function( mat )
    local ncols,  # number of columns
          zero,   # zero coefficient
          row;    # loop over rows in 'obj'

    ncols:= DimensionsMat( mat )[2];
    zero:= Zero( mat[1][1] );
    for row in mat do
      if PositionNot( row, zero ) <= ncols then
        return false;
      fi;
    od;
    return true;
    end );

#############################################################################
##
#M  BaseMat( <mat> )  . . . . . . . . . .  base for the row space of a matrix
##
InstallMethod( BaseMatDestructive,
    "generic method for matrices",
    [ IsMatrix ],
    mat -> SemiEchelonMatDestructive( mat ).vectors );

InstallMethod( BaseMat,
    "generic method for matrices",
    [ IsMatrix ],
    function ( mat )
    return BaseMatDestructive( MutableCopyMat( mat ) );
    end );


#############################################################################
##
#M  DefaultFieldOfMatrix( <mat> )
##
InstallMethod( DefaultFieldOfMatrix,
    "default method for a matrix (return `fail')",
    [ IsMatrix ],
    ReturnFail );


#############################################################################
##
#M  DefaultFieldOfMatrix( <ffe-mat> )
##
InstallMethod( DefaultFieldOfMatrix,
    "method for a matrix over a finite field",
    [ IsMatrix and IsFFECollColl ],
function( mat )
    local   deg,  j;

    deg := 1;
    for j  in mat  do
        deg := LcmInt( deg, DegreeFFE(j) );
    od;
    return GF( Characteristic(mat[1]), deg );
end );


#############################################################################
##
#M  DefaultFieldOfMatrix( <cyc-mat> )
##
InstallMethod( DefaultFieldOfMatrix,
    "method for a matrix over the cyclotomics",
    [ IsMatrix and IsCyclotomicCollColl ],
function( mat )
    local   deg,  j;

    deg := 1;
    for j  in mat  do
        deg := LcmInt( deg, Conductor(j) );
    od;
    return CF( deg );
end );


#############################################################################
##
#M  DepthOfUpperTriangularMatrix( <mat> )
##
InstallMethod( DepthOfUpperTriangularMatrix,
    [ IsMatrix ],
function( mat )
    local   dim,  zero,  i,  j;

    # find the correct layer of <m>
    dim  := Length(mat);
    zero := Zero(mat[1][1]);
    for i  in [ 1 .. dim-1 ]  do
        for j  in [ 1 .. dim-i ]  do
            if mat[j][i+j] <> zero  then
                return i;
            fi;
        od;
    od;
    return dim;

end);

InstallOtherMethod( SumIntersectionMat,
    [ IsEmpty, IsMatrix ],
function(a,b)
  b:=MutableCopyMat(b);
  TriangulizeMat(b);
  b:=Filtered(b,i->not IsZero(i));
  return [b,a];
end);

InstallOtherMethod( SumIntersectionMat,
    [ IsMatrix, IsEmpty ],
function(a,b)
  a:=MutableCopyMat(a);
  TriangulizeMat(a);
  a:=Filtered(a,i->not IsZero(i));
  return [a,b];
end);

InstallOtherMethod( SumIntersectionMat,
    IsIdenticalObj,
    [ IsEmpty, IsEmpty ],
function(a,b)
  return [a,b];
end);


#############################################################################
##
#M  DeterminantMat( <mat> )
##
## Fractions free method, will never introduce denominators
##
## This method is better for cyclotomics, but pivotting is really needed
##
InstallMethod( DeterminantMatDestructive,
    "fraction-free method",
    [ IsOrdinaryMatrix and IsMutable],
    function ( mat )
    local   det, sgn, row, zero, m, i, j, k, mult, row2, piv;

    # check that the argument is a square matrix and get the size
    m := Length(mat);
    zero := Zero(mat[1][1]);
    if m <> Length(mat[1])  then
        Error("DeterminantMat: <mat> must be a square matrix");
    fi;

    # run through all columns of the matrix
    i := 0;  det := 1;  sgn := 1;
    for k  in [1..m]  do

        # find a nonzero entry in this column
        #N  26-Oct-91 martin if <mat> is a rational matrix look for a pivot
        j := i + 1;
        while j <= m and mat[j][k] = zero  do j := j+1;  od;

        # if there is a nonzero entry
        if j <= m  then

            # increment the rank
            i := i + 1;

            # make its row the current row
            if i <> j  then
                row := mat[j];  mat[j] := mat[i];  mat[i] := row;
                sgn := -sgn;
            else
                row := mat[j];
            fi;
            piv := row[k];

            # clear all entries in this column
            # Then divide through by det, this, amazingly, works, due
            #  to a theorem about 3x3 determinants
            for j  in [i+1..m]  do
                row2 := mat[j];
                mult := -row2[k];
                if  mult <> zero then
                    MultRowVector( row2, piv );
                    AddRowVector( row2, row, mult, k, m );
                    MultRowVector( row2, Inverse(det) );
                else
                    MultRowVector( row2, piv/det);
                fi;
            od;

            det := piv;
        else
            return zero;
        fi;

    od;

    # return the determinant
    return sgn * det;
end);


#############################################################################
##
#M  DeterminantMat( <mat> )
##
## direct Gaussian elimination, not avoiding denominators
#T  This method at the moment is  better for finite fields
##  another method is installed for cyclotomics. Anything else falls
##  through here also.
##
InstallMethod( DeterminantMatDestructive,"non fraction free",
    [ IsOrdinaryMatrix and IsFFECollColl and IsMutable],
function( mat )
    local   m,  zero,  det,  sgn,  k,  j,  row,  l,  norm,
            row2, x;

    Info( InfoMatrix, 1, "DeterminantMat called" );

    # check that the argument is a square matrix, and get the size
    m := Length(mat);
    if m = 0 or m <> Length(mat[1])  then
        Error( "<mat> must be a square matrix at least 1x1" );
    fi;
    zero := Zero(mat[1][1]);

    # normalize rows using the inverse
    if IsFFECollColl(mat)  then
        norm := true;
    else
        norm := false;
    fi;

    det := One(zero);
    sgn := det;

    # run through all columns of the matrix
    for k  in [ 1 .. m ]  do

        # look for a nonzero entry in this column
        j := k;
        while j <= m and mat[j][k] = zero  do
            j := j+1;
        od;

        # if there is a nonzero entry
        if j <= m  then

            # increment the rank, ...
            Info( InfoMatrix, 2, "  nonzero columns: ", k );

            # ... make its row the current row, ...
            if k <> j then
                row    := mat[j];
                mat[j] := mat[k];
                mat[k] := row;
                sgn    := -sgn;
            else
                row := mat[j];
            fi;

            # ... and normalize the row.
            x := row[k];
            det := det * x;
            MultRowVector( mat[k], Inverse(x) );

            # clear all entries in this column, adjust only columns > k
            # (Note that we need not clear the rows from 'k+1' to 'j'.)
            for l  in [ j+1 .. m ]  do
                row2 := mat[l];
                x := row2[k];
                if x <> zero then
                    AddRowVector( row2, row, -x, k+1, m );
                fi;
            od;

        # the determinant is zero
        else
            Info( InfoMatrix, 1, "DeterminantMat returns ", zero );
            return zero;
        fi;
    od;
    det := sgn * det;
    Info( InfoMatrix, 1, "DeterminantMat returns ", det );

    # return the determinant
    return det;

end );

InstallMethod( DeterminantMat,
    "for matrices",
    [ IsMatrix ],
    function( mat )
    return DeterminantMatDestructive( MutableCopyMat( mat ) );
    end );

InstallMethod( DeterminantMatDestructive,"nonprime residue rings",
    [ IsOrdinaryMatrix and
    CategoryCollections(CategoryCollections(IsZmodnZObjNonprime)) and IsMutable],
  DeterminantMatDivFree);

#############################################################################
##
#M  DeterminantMatDivFree( <M> )
##
##  Division free method. This is an alternative to the fraction free method
##  when division of matrix entries is expensive or not possible.
##
##  This method implements a division free algorithm found in
##  Mahajan and Vinay \cite{MV97}.
##
##  The run time is $O(n^4)$
##  Auxillary storage size $n^2+n + C$
##
##  Our implementation has two runtime optimizations (both noted
##  by Mahajan and Vinay)
##    1. Partial monomial sums, subtractions, and products are done at
##       each level.
##    2. Prefix property is maintained allowing for a pruning of many
##       vertices at each level
##
##  and two auxillary storage size optimizations
##    1. only the upper triangular and diagonal portion of the
##       auxillary storage is used.
##    2. Level information storage is reused (2 levels).
##
##  This code was implemented by:
##    Timothy DeBaillie
##    Robert Morse
##    Marcus Wassmer
##
InstallMethod( DeterminantMatDivFree,
    "Division-free method",
    [ IsMatrix ],
    function ( M )
        local u,v,w,i,   ## indices
              a,b,c,x,y, ## temp indices
              temp,      ## temp variable
              nlevel,    ## next level
              clevel,    ## current level
              pmone,     ## plus or minus one
              zero,      ## zero of the ring
              n,         ## size of the matrix
              Vs,        ## final sum
              V;         ## graph

        # check that the argument is a square matrix and set the size
        n := Length(M);
        if not n = Length(M[1]) or not IsRectangularTable(M)  then
            Error("DeterminantMatDivFree: <mat> must be a square matrix");
        fi;

        ## initialze the final sum, the vertex set, initial parity
        ## and level indexes
        ##
        zero := Zero(M[1][1]);
        Vs := zero;
        V := [];
        pmone := (-One(M[1][1]))^((n mod 2)+1);
        clevel := 1; nlevel := 2;

        ##  Vertices are indexed [u,v,i] holding the (partial) monomials
        ##  whose sums will form the determinant
        ##    where i = depth in the tree (current and next reusing
        ##              level storage)
        ##          u,v indices in the matrix
        ##
        ##  Only the upper triangular portion of the storage space is
        ##  needed. It is easier to create lower triangular data type
        ##  which we do here and index via index arithmetic.
        ##
        for u in [1..n] do
            Add(V,[]);
            for v in [1..u] do
                Add(V[u],[zero,zero]);
            od;
            ## Initialize the level 0 nodes with +/- one, depending on
            ## the initial parity determined by the size of the matrix
            ##
            V[u][u][clevel] := pmone;
        od;

        ##  Here are the $O(n^4)$ edges labeled by the elements of
        ##  the matrix $M$. We build up products of the labels which form
        ##  the monomials which make up the determinant.
        ##
        ##  1. Parity of monomials are maintained implicitly.
        ##  2. Partial sums for some vertices are not part of the final
        ##     answer and can be pruned.
        ##
        for i in [0..n-2] do
            for u in [1..i+2] do  ## <---- pruning of vertices
                for v in [u..n] do         ## (maintains the prefix property)
                    for w in [u+1..n] do

                        ## translate indices to lower triangluar coordinates
                        ##
                        a := n-u+1; b := n-w+1; c := n-v+1;
                        V[a][b][nlevel]:= V[a][b][nlevel]+
                            V[a][c][clevel]*M[v][w];
                        V[b][b][nlevel]:= V[b][b][nlevel]-
                            V[a][c][clevel]*M[v][u];
                    od;
                od;
            od;

            ## set the new current and next level. The new next level
            ## is intialized to zero
            ##
            temp   := nlevel; nlevel := clevel; clevel := temp;
            for x in [1..n] do
                for y in [1..x] do
                    V[x][y][nlevel] := zero;
                od;
            od;
        od;

        ##  with the final level, we form the last monomial product and then
        ##  sum these monomials (parity has been accounted for)
        ##  to find the determinant.
        ##
        for u in [1..n] do
            for v in [u..n] do
                Vs := Vs + V[n-u+1][n-v+1][clevel]*M[v][u];
            od;
        od;

        ##  Return the final sum
        ##
        return Vs;

    end);

#############################################################################
##
#M  DimensionsMat( <mat> )
##
InstallMethod( DimensionsMat,
    [ IsMatrix ],
    function( A )
    if IsRectangularTable(A) then
        return [ Length(A), Length(A[1]) ];
    else
        return fail;
    fi;
    end );

BindGlobal("DoDiagonalizeMat",function(arg)
local R,M,transform,divide,swaprow, swapcol, addcol, addrow, multcol, multrow, l, n, start, d,
      typ, ed, posi,posj, a, b, qr, c, i,j,left,right,cleanout, alldivide,basmat,origtran;

  R:=arg[1];
  M:=arg[2];
  transform:=arg[3];
  divide:=arg[4];

  l:=Length(M);
  n:=Length(M[1]);

  basmat:=fail;
  if transform then
    left:=IdentityMat(l,R);
    right:=IdentityMat(n,R);
    if Length(arg)>4 then
      origtran:=arg[5];
      basmat:=IdentityMat(l,R); # for RCF -- transpose of P' in D&F, sec. 12.2
    fi;
  fi;

  swaprow:=function(a,b)
  local r;
    r:=M[a];
    M[a]:=M[b];
    M[b]:=r;
    if transform then
      r:=left[a];
      left[a]:=left[b];
      left[b]:=r;
      if basmat<>fail then
	r:=basmat[a];
	basmat[a]:=basmat[b];
	basmat[b]:=r;
      fi;
    fi;
  end;

  swapcol:=function(a,b)
  local c;
    c:=M{[1..l]}[a];
    M{[1..l]}[a]:=M{[1..l]}[b];
    M{[1..l]}[b]:=c;
    if transform then
      c:=right{[1..n]}[a];
      right{[1..n]}[a]:=right{[1..n]}[b];
      right{[1..n]}[b]:=c;
    fi;
  end;

  addcol:=function(a,b,m)
  local i;
    for i in [1..l] do
      M[i][a]:=M[i][a]+m*M[i][b];
    od;
    if transform then
      for i in [1..n] do
        right[i][a]:=right[i][a]+m*right[i][b];
      od;
    fi;
  end;

  addrow:=function(a,b,m)
    AddCoeffs(M[a],M[b],m);
    if transform then
      AddCoeffs(left[a],left[b],m);
      if basmat<>fail then
        basmat[b]:=basmat[b]-basmat[a]*Value(m,origtran);
      fi;
    fi;
  end;

  multcol:=function(a,m)
  local i;
    for i in [1..l] do
      M[i][a]:=M[i][a]*m;
    od;
    if transform then
      for i in [1..n] do
        right[i][a]:=right[i][a]*m;
      od;
    fi;
  end;

  multrow:=function(a,m)
    MultRowVector(M[a],m);
    if transform then
      MultRowVector(left[a],m);
      if basmat<>fail then
	MultRowVector(basmat[a],1/m);
      fi;
    fi;
  end;

  # clean out row and column
  cleanout:=function()
  local a,i,b,c,qr;
    repeat
      # now do the GCD calculations only in row/column
      for i in [start+1..n] do
        a:=i;
        b:=start;
        if not IsZero(M[start][b]) then
          repeat
            qr:=QuotientRemainder(R,M[start][a],M[start][b]);
            addcol(a,b,-qr[1]);
            c:=a;a:=b;b:=c;
          until IsZero(qr[2]);
          if b=start then
            swapcol(start,i);
          fi;
        fi;

        # normalize
        qr:=StandardAssociateUnit(R,M[start][start]);
        multcol(start,qr);

      od;

      for i in [start+1..l] do
        a:=i;
        b:=start;
        if not IsZero(M[b][start]) then
          repeat
            qr:=QuotientRemainder(R,M[a][start],M[b][start]);
            addrow(a,b,-qr[1]);
            c:=a;a:=b;b:=c;
          until IsZero(qr[2]);
          if b=start then
            swaprow(start,i);
          fi;
        fi;

        qr:=StandardAssociateUnit(R,M[start][start]);
        multrow(start,qr);

      od;
    until ForAll([start+1..n],i->IsZero(M[start][i]));
  end;

  start:=1;
  while start<=Length(M) and start<=n do

    # find element of lowest degree and move it into pivot
    # hope is this will reduce the total number of iterations by making
    # it small in the first place
    d:=infinity;

    for i in [start..l] do
      for j in [start..n] do
        if not IsZero(M[i][j]) then
          ed:=EuclideanDegree(R,M[i][j]);
          if ed<d then
            d:=ed;
            posi:=i;
            posj:=j;
          fi;
        fi;
      od;
    od;

    if d<>infinity then # there is at least one nonzero entry

      if posi<>start then
        swaprow(start,posi);
      fi;
      if posj<>start then
        swapcol(start,posj);
      fi;
      cleanout();

      if divide then
        repeat
          alldivide:=true;
          #make sure the pivot also divides the rest
          for i in [start+1..l] do
            for j in [start+1..n] do
              if Quotient(M[i][j],M[start][start])=fail then
                alldivide:=false;
                # do gcd
                addrow(start,i,One(R));
                cleanout();
              fi;
            od;
          od;
        until alldivide;

      fi;

      # normalize
      qr:=StandardAssociateUnit(R,M[start][start]);
      multcol(start,qr);

    fi;
    start:=start+1;
  od;

  if transform then
   M:=rec(rowtrans:=left,coltrans:=right,normal:=M);
   if basmat<>fail then
     M.basmat:=basmat;
   fi;
   return M;
  else
    return M;
  fi;
end);

#############################################################################
##
#M  DiagonalizeMat(<euclring>,<mat>)
##
# this is a very naive implementation but it should work for any euclidean
# ring.
InstallMethod( DiagonalizeMat, 
  "method for general Euclidean Ring",
  true, [ IsEuclideanRing,IsMatrix and IsMutable], 0,function(R,M)
  return DoDiagonalizeMat(R,M,false,false);
end);


#############################################################################
##
#M  ElementaryDivisorsMat(<mat>)  . . . . . . elementary divisors of a matrix
##
##  'ElementaryDivisors' returns a list of the elementary divisors, i.e., the
##  unique <d> with '<d>[<i>]' divides '<d>[<i>+1]' and <mat>  is  equivalent
##  to a diagonal matrix with the elements '<d>[<i>]' on the diagonal.
##

InstallGlobalFunction(ElementaryDivisorsMatDestructive,function(ring,mat)
    # diagonalize the matrix
    DoDiagonalizeMat(ring, mat,false,true );

    # get the diagonal elements
    return DiagonalOfMat(mat);
end );

InstallMethod( ElementaryDivisorsMat,
    "generic method for euclidean rings",
    [ IsEuclideanRing,IsMatrix ],
function ( ring,mat )
  # make a copy to avoid changing the original argument
  mat := MutableCopyMat( mat );
  if IsIdenticalObj(ring,Integers) then
    DiagonalizeMat(Integers,mat);
    return DiagonalOfMat(mat);
  fi;
  return ElementaryDivisorsMatDestructive(ring,mat);
end);

InstallOtherMethod( ElementaryDivisorsMat,
    "compatibility method -- supply ring",
    [ IsMatrix ],
function(mat)
local ring;
  if ForAll(mat,row->ForAll(row,IsInt)) then
    return ElementaryDivisorsMat(Integers,mat);
  fi;
  ring:=DefaultRing(Flat(mat));
  return ElementaryDivisorsMat(ring,mat);
end);

#############################################################################
##
#M  ElementaryDivisorsTransformationsMat(<mat>) elem. divisors of a matrix
##
##  'ElementaryDivisorsTransformationsMat' does not only compute the
##  elementary divisors, but also transforming matrices.

InstallGlobalFunction(ElementaryDivisorsTransformationsMatDestructive,
function(ring,mat)

    # diagonalize the matrix
    return DoDiagonalizeMat(ring, mat,true,true );

end );

InstallMethod( ElementaryDivisorsTransformationsMat,
    "generic method for euclidean rings",
    [ IsEuclideanRing,IsMatrix ],
function ( ring,mat )
  # make a copy to avoid changing the original argument
  mat := MutableCopyMat( mat );
  return ElementaryDivisorsTransformationsMatDestructive(ring,mat);
end);

InstallOtherMethod( ElementaryDivisorsTransformationsMat,
    "compatibility method -- supply ring",
    [ IsMatrix ],
function(mat)
local ring;
  if ForAll(mat,row->ForAll(row,IsInt)) then
    return ElementaryDivisorsTransformationsMat(Integers,mat);
  fi;
  ring:=DefaultRing(Flat(mat));
  return ElementaryDivisorsTransformationsMat(ring,mat);
end);

#############################################################################
##
#M  MutableCopyMat( <mat> )
##
InstallMethod( MutableCopyMat, "generic method", [IsList],
  mat -> List( mat, ShallowCopy ) );


#############################################################################
##
#M  MutableTransposedMat( <mat> ) . . . . . . . . . .  transposed of a matrix
##
InstallMethod( MutableTransposedMat,
    "generic method",
    [ IsRectangularTable and IsMatrix ],
    function( mat )
    local trn, n, m, j;

    m:= Length( mat );
    if m = 0 then return []; fi;

    # initialize the transposed
    m:= [ 1 .. m ];
    n:= [ 1 .. Length( mat[1] ) ];
    trn:= [];

    # copy the entries
    for j in n do
      trn[j]:= mat{ m }[j];
#      ConvertToVectorRepNC( trn[j] );
    od;

    # return the transposed
    return trn;
end );

#############################################################################
##
#M  MutableTransposedMat( <mat> ) . . . . . . . . . .  transposed of a matrix
##
InstallOtherMethod( MutableTransposedMat,
    "for arbitrary lists of lists",
    [ IsList ],
    function( t )
  local   res,  m,  i,  j;
  res := [];
  if Length(t)>0 and IsDenseList(t) and ForAll(t, IsDenseList) then
        # special case with dense list of dense lists
      m := Maximum(List(t, Length));
      for i in [m,m-1..1] do
          res[i] := [];
      od;
      for i in [1..Length(t)] do
          res{[1..Length(t[i])]}[i] := t[i];
      od;
  else
        # general case, non dense lists allowed
      for i in [1..Length(t)] do
          if IsBound(t[i]) then
              if IsList(t[i]) then
                  for j in [1..Length(t[i])] do
                      if IsBound(t[i][j]) then
                          if not IsBound(res[j]) then
                              res[j] := [];
                          fi;
                          res[j][i] := t[i][j];
                      fi;
                  od;
              else
                  Error("bound entries must be lists");
              fi;
          fi;
      od;
  fi;
  return res;
end);




#############################################################################
##
#M  MutableTransposedMatDestructive( <mat> ) . . . . . transposed of a matrix
##                                                     may destroy `mat'.
##
InstallMethod( MutableTransposedMatDestructive,
    "generic method",
    [IsMatrix and IsMutable],
    function( mat )

    local   m,  n,  min,  i,  j,  store;


    m:= Length( mat );
    if m = 0 then return []; fi;

    n:= Length( mat[1] );
    min:= Minimum( m, n );

    # swap the entries in the "square part" of the matrix.
    for i in [1..min] do
        for j in [i+1..min] do
            store:= mat[i][j];
            mat[i][j]:= mat[j][i];
            mat[j][i]:= store;
        od;
    od;

    # if the matrix is not square, then we have to adjust some rows or
    # columns.
    if m < n then
        for i in [1..n-m] do
            store:= [ ];
            for j in [1..m] do
                store[j]:= mat[j][m+i];
                Unbind( mat[j][m+i] );
            od;
            Add( mat, store );
        od;
        for i in [1..m] do
            mat[i]:= Filtered( mat[i], x -> IsBound(x) );
        od;
    fi;

    if m > n then
        for i in [n+1..m] do
            for j in [1..n] do
                mat[j][i]:= mat[i][j];
            od;
            Unbind( mat[i] );
        od;
        mat:= Filtered( mat, x -> IsBound( x ) );
    fi;

    # return the transposed
    return mat;
end );


#############################################################################
##
#M  NullspaceMat( <mat> ) . . . . . . basis of solutions of <vec> * <mat> = 0
##
InstallMethod( NullspaceMat,
    "generic method for ordinary matrices",
    [ IsOrdinaryMatrix ],
    mat -> SemiEchelonMatTransformation(mat).relations );

InstallMethod( NullspaceMatDestructive,
    "generic method for ordinary matrices",
    [ IsOrdinaryMatrix  and IsMutable],
    mat -> SemiEchelonMatTransformationDestructive(mat).relations );

InstallMethod( TriangulizedNullspaceMat,
    "generic method for ordinary matrices",
    [ IsOrdinaryMatrix ],
    mat -> TriangulizedNullspaceMatDestructive( MutableCopyMat( mat ) ) );

InstallMethod( TriangulizedNullspaceMatDestructive,
    "generic method for ordinary matrices",
    [ IsOrdinaryMatrix and IsMutable],
    function( mat )
    local ns;
    ns := SemiEchelonMatTransformationDestructive(mat).relations;
    TriangulizeMat(ns);
    return ns;
end );

InstallMethod( TriangulizedNullspaceMatNT,
    "generic method",
    [ IsOrdinaryMatrix ],
    function( mat )
    local   nullspace, m, n, min, empty, i, k, row, zero, one;#

    TriangulizeMat( mat );
    m := Length(mat);
    n := Length(mat[1]);
    zero := Zero( mat[1][1] );
    one  := One( mat[1][1] );
    min := Minimum( m, n );

    # insert empty rows to bring the leading term of each row on the diagonal
    empty := 0*mat[1];
    i := 1;
    while i <= Length(mat)  do
        if i < n  and mat[i][i] = zero  then
            for k in Reversed([i..Minimum(Length(mat),n-1)])  do
                mat[k+1] := mat[k];
            od;
            mat[i] := empty;
        fi;
        i := i+1;
    od;
    for i  in [ Length(mat)+1 .. n ]  do
        mat[i] := empty;
    od;

    # 'mat' now  looks  like  [ [1,2,0,2], [0,0,0,0], [0,0,1,3], [0,0,0,0] ],
    # and the solutions can be read in those columns with a 0 on the diagonal
    # by replacing this 0 by a -1, in  this  example  [2,-1,0,0], [2,0,3,-1].
    nullspace := [];
    for k  in Reversed([1..n]) do
        if mat[k][k] = zero  then
            row := [];
            for i  in [1..k-1]  do row[n-i+1] := -mat[i][k];  od;
            row[n-k+1] := one;
            for i  in [k+1..n]  do row[n-i+1] := zero;  od;
            ConvertToVectorRepNC( row );
            Add( nullspace, row );
        fi;
    od;

    return nullspace;
end );

#InstallMethod(TriangulizedNullspaceMat,"generic method",
#    [IsOrdinaryMatrix],
#    function ( mat )
#    # triangulize the transposed of the matrix
#    return TriangulizedNullspaceMatNT(
#                   MutableTransposedMat( Reversed( mat ) ) );
#end );

#InstallMethod(TriangulizedNullspaceMatDestructive,"generic method",
#    [IsOrdinaryMatrix],
#    function ( mat )
#    # triangulize the transposed of the matrix
#    return TriangulizedNullspaceMatNT(
#                   MutableTransposedMatDestructive( Reversed( mat ) ) );
#end );


#############################################################################
##
#M  GeneralisedEigenvalues( <F>, <A> )
##
InstallMethod( GeneralisedEigenvalues,
    "for a matrix",
    [ IsField, IsMatrix ],
    function( F, A )
        return Set( Factors( UnivariatePolynomialRing(F), MinimalPolynomial(F, A,1) ) );
    end );

#############################################################################
##
#M  GeneralisedEigenspaces( <F>, <A> )
##
InstallMethod( GeneralisedEigenspaces,
    "for a matrix",
    [ IsField, IsMatrix ],
    function( F, A )
        return List( GeneralisedEigenvalues( F, A ), eval ->
            VectorSpace( F, TriangulizedNullspaceMat( Value( eval, A ) ) ) );
    end );

#############################################################################
##
#M  Eigenvalues( <F>, <A> )
##
InstallMethod( Eigenvalues,
    "for a matrix",
    [ IsField, IsMatrix ],
    function( F, A )
        return List( Filtered( GeneralisedEigenvalues(F,A),
                               eval -> DegreeOfLaurentPolynomial(eval) = 1 ),
                     eval -> -1 * Value(eval,0) );
    end );

#############################################################################
##
#M  Eigenspaces( <F>, <A> )
##
InstallMethod( Eigenspaces,
    "for a matrix",
    [ IsField, IsMatrix ],
    function( F, A )
        return List( Eigenvalues(F,A), eval ->
            VectorSpace( F, TriangulizedNullspaceMat(A - eval*One(A)) ) );
    end );

#############################################################################
##
#M  Eigenvectors( <F>, <A> )
##
InstallMethod( Eigenvectors,
    "for a matrix",
    [ IsField, IsMatrix ],
    function( F, A )
        return Concatenation( List( Eigenspaces(F,A),
                                    esp -> AsList(Basis(esp)) ) );
    end );



#############################################################################
##
#M  ProjectiveOrder( <mat> )  . . . . . . . . . . . . . . . order mod scalars
##
InstallMethod( ProjectiveOrder,
    "ordinary matrix of finite field elements",
    [ IsOrdinaryMatrix and IsFFECollColl ],
function( mat )
    local   p,  c;

    # construct the minimal polynomial of <A>
    p := MinimalPolynomialMatrixNC( DefaultFieldOfMatrix(mat), mat,1 );

    # check if <A> is invertible
    c := CoefficientsOfUnivariatePolynomial(p);
    if c[1] = Zero(c[1])  then
        Error( "matrix <mat> must be invertible" );
    fi;

    # compute the order of <p>
    return ProjectiveOrder(p);
end );


#############################################################################
##
#M  RankMat( <mat> )  . . . . . . . . . . . . . . . . . . .  rank of a matrix
##
InstallMethod( RankMatDestructive,
    "generic method for mutable matrices",
    [ IsMatrix and IsMutable ],
    function( mat )
    mat:= SemiEchelonMatDestructive( mat );
    if mat <> fail then
      mat:= Length( mat.vectors );
    fi;
    return mat;
    end );

InstallMethod( RankMat,
    "generic method for matrices",
    [ IsMatrix ],
    mat -> RankMatDestructive( MutableCopyMat( mat ) ) );


#############################################################################
##
#M  SemiEchelonMat( <mat> )
##
InstallMethod( SemiEchelonMatDestructive,
    "generic method for matrices",
    [ IsMatrix and IsMutable ],
    function( mat )
    local zero,      # zero of the field of <mat>
          nrows,     # number of rows in <mat>
          ncols,     # number of columns in <mat>
          vectors,   # list of basis vectors
          heads,     # list of pivot positions in `vectors'
          i,         # loop over rows
          j,         # loop over columns
          x,         # a current element
          nzheads,   # list of non-zero heads
          row,       # the row of current interest
          inv;       # inverse of a matrix entry

    nrows:= Length( mat );
    ncols:= Length( mat[1] );

    zero:= Zero( mat[1][1] );

    heads:= ListWithIdenticalEntries( ncols, 0 );
    nzheads := [];
    vectors := [];

    for i in [ 1 .. nrows ] do

        row := mat[i];
        # Reduce the row with the known basis vectors.
        for j in [ 1 .. Length(nzheads) ] do
            x := row[nzheads[j]];
            if x <> zero then
              AddRowVector( row, vectors[ j ], - x );
            fi;
        od;

        j := PositionNot( row, zero );
        if j <= ncols then

            # We found a new basis vector.
            inv:= Inverse( row[j] );
            if inv = fail then
              return fail;
            fi;
            MultRowVector( row, inv );
            Add( vectors, row );
            Add( nzheads, j );
            heads[j]:= Length( vectors );

        fi;

    od;

    return rec( heads   := heads,
                vectors := vectors );
    end );

InstallMethod( SemiEchelonMat,
    "generic method for matrices",
    [ IsMatrix ],
    function( mat )
    local copymat, v, vc, f;
    copymat := [];
    f := DefaultFieldOfMatrix(mat);
    for v in mat do
        vc := ShallowCopy(v);
        ConvertToVectorRepNC(vc,f);
        Add(copymat, vc);
    od;
    return SemiEchelonMatDestructive( copymat );
end );


#############################################################################
##
#M  SemiEchelonMatTransformation( <mat> )
##
InstallMethod( SemiEchelonMatTransformation,
    "generic method for matrices",
    [ IsMatrix ],
    function( mat )
    local copymat, v, vc, f;
    copymat := [];
    f := DefaultFieldOfMatrix(mat);
    for v in mat do
        vc := ShallowCopy(v);
        ConvertToVectorRepNC(vc,f);
        Add(copymat, vc);
    od;
    return SemiEchelonMatTransformationDestructive( copymat );
end);

InstallMethod( SemiEchelonMatTransformationDestructive,
    "generic method for matrices",
    [ IsMatrix and IsMutable],
    function( mat )
    local zero,      # zero of the field of <mat>
          nrows,     # number of rows in <mat>
          ncols,     # number of columns in <mat>
          vectors,   # list of basis vectors
          heads,     # list of pivot positions in 'vectors'
          i,         # loop over rows
          j,         # loop over columns
          T,         # transformation matrix
          coeffs,    # list of coefficient vectors for 'vectors'
          relations, # basis vectors of the null space of 'mat'
          row, head, x, row2,f;

    nrows := Length( mat );
    ncols := Length( mat[1] );
    
    f := DefaultFieldOfMatrix(mat);
    if f = fail then
        f := mat[1][1];
    fi;
    zero := Zero(f);
    
    heads   := ListWithIdenticalEntries( ncols, 0 );
    vectors := [];

    T         := IdentityMat( nrows, f );
    coeffs    := [];
    relations := [];

    for i in [ 1 .. nrows ] do

        row := mat[i];
        row2 := T[i];

        # Reduce the row with the known basis vectors.
        for j in [ 1 .. ncols ] do
            head := heads[j];
            if head <> 0 then
                x := - row[j];
                if x <> zero then
                    AddRowVector( row2, coeffs[ head ],  x );
                    AddRowVector( row,  vectors[ head ], x );
                fi;
            fi;
        od;

        j:= PositionNot( row, zero );
        if j <= ncols then

            # We found a new basis vector.
            x:= Inverse( row[j] );
            if x = fail then
              TryNextMethod();
            fi;
            Add( coeffs,  row2 * x );
            Add( vectors, row  * x );
            heads[j]:= Length( vectors );

        else
            Add( relations, row2 );
        fi;

    od;

    return rec( heads     := heads,
                vectors   := vectors,
                coeffs    := coeffs,
                relations := relations );
end );




#############################################################################
##
#M  SemiEchelonMats( <mats> )
##
InstallGlobalFunction( SemiEchelonMatsNoCo, function( mats )
    local zero,      # zero coefficient
          m,         # number of rows
          n,         # number of columns
          v,
          vectors,   # list of matrices in the echelonized basis
          heads,     # list with info about leading entries
          mat,       # loop over generators of 'V'
          i, j,      # loop over rows and columns of the matrix
          k, l,
          mij,
          scalar,
          x;

    zero:= Zero( mats[1][1][1] );
    m:= Length( mats[1]    );
    n:= Length( mats[1][1] );

    # Compute an echelonized basis.
    vectors := [];
    heads   := ListWithIdenticalEntries( n, 0 );
    heads   := List( [ 1 .. m ], x -> ShallowCopy( heads ) );

    for mat in mats do

      # Reduce the matrix modulo 'ech'.
      for i in [ 1 .. m ] do
        for j in [ 1 .. n ] do
          if heads[i][j] <> 0 and mat[i][j] <> zero then

            # Compute 'mat:= mat - mat[i][j] * vectors[ heads[i][j] ];'
            scalar:= - mat[i][j];
            v:= vectors[ heads[i][j] ];
            for k in [ 1 .. m ] do
              AddRowVector( mat[k], v[k], scalar );
            od;

          fi;
        od;
      od;

      # Get the first nonzero column.
      i:= 1;
      j:= PositionNot( mat[1], zero );
      while n < j and i < m do
        i:= i + 1;
        j:= PositionNot( mat[i], zero );
      od;

      if j <= n then

        # We found a new basis vector.
        mij:= mat[i][j];
        for k in [ 1 .. m ] do
          for l in [ 1 .. n ] do
            x:= Inverse( mij );
            if x = fail then
              TryNextMethod();
            fi;
            mat[k][l]:= mat[k][l] * x;
          od;
        od;

        Add( vectors, mat );
        heads[i][j]:= Length( vectors );

      fi;

    od;

    # Return the result.
    return rec(
                vectors := vectors,
                heads   := heads
               );
end );

InstallMethod( SemiEchelonMats,
        "for list of matrices",
        [ IsList ],
        function( mats )
    return SemiEchelonMatsNoCo( List( mats, x -> MutableCopyMat(x) ) );
end );

InstallMethod( SemiEchelonMatsDestructive,
        "for list of matrices",
        [ IsList ],
        function( mats )
    return SemiEchelonMatsNoCo( mats );
end );



#############################################################################
##
#M  TransposedMat( <mat> )  . . . . . . . . . . . . .  transposed of a matrix
##
InstallOtherMethod( TransposedMat,
    "generic method for matrices and lists",
    [ IsList ],
    MutableTransposedMat );

#############################################################################
##
#M  TransposedMatDestructive( <mat> )  . . . . . . . . transposed of a matrix
##
InstallMethod( TransposedMatDestructive,
    "generic method for matrices",
    [ IsMatrix ],
    MutableTransposedMatDestructive );

InstallOtherMethod(TransposedMatDestructive,
  "method for empty matrices",[IsList],
function(mat)
  if mat<>[] and mat<>[[]] then
    TryNextMethod();
  fi;
  return mat;
end);


############################################################################
##

#M  IsMonomialMatrix( <mat> )
##
InstallMethod( IsMonomialMatrix,
    "generic method for matrices",
    [ IsMatrix ],
    function( M )
    local zero,  # zero of the base ring
          len,   # length of rows
          found, # store positions of nonzero elements
          row,   # loop over rows
          j;     # position of first non-zero element

    zero:= Zero(M[1][1]);
    len:= Length( M[1] );
    if Length( M ) <> len  then
        return false;
    fi;
    found:= BlistList( M, [] );
    for row  in M  do
        j := PositionNot( row, zero );
        if len < j or found[j]  then
            return false;
        fi;
        if PositionNot( row, zero, j ) <= len  then
            return false;
        fi;
        found[j] := true;
    od;
    return true;
end );


##########################################################################
##
#M  InverseMatMod( <cyc-mat>, <integer> )
##
InstallMethod( InverseMatMod,
    "generic method for matrix and integer",
    IsCollCollsElms,
    [ IsMatrix, IsInt ],
function( mat, m )
    local   n,  MM, inv,  perm,  i,  pj,  elem,  liste,  l;

    if Length(mat) <> Length(mat[1])  then
        Error( "<mat> must be a square matrix" );
    fi;

    MM := List( mat, x -> List( x, y -> y mod m ) );
    n  := Length(MM);

    # construct the identity matrix
    inv := IdentityMat( n, Cyclotomics );
    perm := [];

    # loop over the rows
    for i  in [ 1 .. n ]  do

        pj := 1;
        while MM[i][pj] = 0  do
            pj := pj + 1;
            if pj > n then
              # <mat> is not invertible mod <m>
              return fail;
            fi;
        od;
        perm[pj] := i;
        elem   := MM[i][pj];
        MM[i]  := List( MM[i],  x -> (x/elem) mod m );
        inv[i] := List( inv[i], x -> (x/elem) mod m );

        liste  := [ 1 .. i-1 ];
        Append( liste, [i+1..n] );
        for l in liste do
            elem   := MM[l][pj];
            MM[l]  := MM[l] - MM[i] * elem;
            MM[l]  := List( MM[l], x -> x mod m );
            inv[l] := inv[l] - inv[i] * elem;
            inv[l] := List( inv[l], x -> x mod m );
        od;
    od;
    return List( perm, i->inv[i] );
end );


#############################################################################
##
#M  KroneckerProduct( <mat1>, <mat2> )
##
InstallMethod( KroneckerProduct,
    "generic method for matrices",
    IsIdenticalObj,
    [ IsMatrix, IsMatrix ],
function ( mat1, mat2 )
    local i, row1, row2, row, kroneckerproduct;
    kroneckerproduct := [];
    for row1  in mat1  do
        for row2  in mat2  do
            row := [];
            for i  in row1  do
                Append( row, i * row2 );
            od;
#T application of the new 'AddRowVector' function?
            ConvertToVectorRepNC( row );
            Add( kroneckerproduct, row );
        od;
    od;
    return kroneckerproduct;
end );

## symmetric and alternating parts of the kronecker product
## code is due to Jean Michel

#############################################################################
##
#M  ExteriorPower( <mat1>, <mat2> )
##
InstallOtherMethod(ExteriorPower,
  "for matrices", true,[IsMatrix,IsPosInt],
function ( A, m )
local  basis;
  basis := Combinations( [ 1 .. Length( A ) ], m );
  return List( basis, i->List( basis, j->DeterminantMat( A{i}{j} )));
end);

#############################################################################
##
#M  SymmetricPower( <mat1>, <mat2> )
##
InstallOtherMethod(SymmetricPower,
  "for matrices", true,[IsMatrix,IsPosInt],
function ( A, m )
local  basis, f;
  f := j->Product( List( Collected( j ), x->x[2]), Factorial );
  basis := UnorderedTuples( [ 1 .. Length( A ) ], m );
  return List( basis, i-> List( basis, j->Permanent( A{i}{j}) / f( i )));
end);



#############################################################################
##
#M  SolutionMat( <mat>, <vec> ) . . . . . . . . . .  one solution of equation
##
##  One solution <x> of <x> * <mat> = <vec> or `fail'.
##
InstallMethod( SolutionMatDestructive,
        "generic method",
    IsCollsElms,
    [ IsOrdinaryMatrix and IsMutable,
      IsRowVector and IsMutable],
        function( mat, vec )
    local i,ncols,sem, vno, z,x, row, sol;
    ncols := Length(vec);
    z := Zero(mat[1][1]);
    sol := ListWithIdenticalEntries(Length(mat),z);
    ConvertToVectorRepNC(sol);
    if ncols <> Length(mat[1]) then
        Error("SolutionMat: matrix and vector incompatible");
    fi;
    sem := SemiEchelonMatTransformationDestructive(mat);
    for i in [1..ncols] do
        vno := sem.heads[i];
        if vno <> 0 then
            x := vec[i];
            if x <> z then
                AddRowVector(vec, sem.vectors[vno], -x);
                AddRowVector(sol, sem.coeffs[vno], x);
            fi;
        fi;
    od;
    if IsZero(vec) then
        return sol;
    else
        return fail;
    fi;
end);


#InstallMethod( SolutionMatNoCo,
#    "generic method for ordinary matrix and vector",
#    IsCollsElms,
#    [ IsOrdinaryMatrix,
#      IsRowVector ],
#function ( mat, vec )
#    local   h, v, tmp, i, l, r, s, c, zero;
#
#    # solve <mat> * x = <vec>.
#    vec  := ShallowCopy( vec );
#    l    := Length( mat );
#    r    := 0;
#    zero := Zero( mat[1][1] );
#    Info( InfoMatrix, 1, "SolutionMat called" );
#
#    # Run through all columns of the matrix.
#    c := 1;
#    while c <= Length( mat[ 1 ] ) and r < l  do
#
#        # Find a nonzero entry in this column.
#        s := r + 1;
#        while s <= l and mat[ s ][ c ] = zero  do s := s + 1;  od;
#
#        # If there is a nonzero entry,
#        if s <= l  then
#
#            # increment the rank.
#            Info( InfoMatrix, 2, "  nonzero columns ", c );
#            r := r + 1;
#
#            # Make its row the current row and normalize it.
#            tmp := mat[ s ][ c ] ^ -1;
#            v := mat[ s ];  mat[ s ] := mat[ r ];  mat[ r ] := tmp * v;
#            v := vec[ s ];  vec[ s ] := vec[ r ];  vec[ r ] := tmp * v;
#
#            # Clear all entries in this column.
#            for s  in [ 1 .. Length( mat ) ]  do
#                if s <> r and mat[ s ][ c ] <> zero  then
#                    tmp := mat[ s ][ c ];
#                    mat[ s ] := mat[ s ] - tmp * mat[ r ];
#                    vec[ s ] := vec[ s ] - tmp * vec[ r ];
#                fi;
#            od;
#        fi;
#        c := c + 1;
#    od;
#
#    # Find a solution.
#    for i  in [ r + 1 .. l ]  do
#        if vec[ i ] <> zero  then return fail;  fi;
#    od;
#    h := [];
#    s := Length( mat[ 1 ] );
#    v := Zero( mat[ 1 ][ 1 ] );
#    r := 1;
#    c := 1;
#    while c <= s and r <= l  do
#        while c <= s and mat[ r ][ c ] = zero  do
#            c := c + 1;
#            Add( h, v );
#        od;
#        if c <= s  then
#            Add( h, vec[ r ] );
#            r := r + 1;
#            c := c + 1;
#        fi;
#    od;
#    while c <= s  do Add( h, v );  c := c + 1;  od;
#
#    Info( InfoMatrix, 1, "SolutionMat returns" );
#    return h;
#end );
#

InstallMethod( SolutionMat,
    "generic method for ordinary matrix and vector",
    IsCollsElms,
    [ IsOrdinaryMatrix,
      IsRowVector ],
        function ( mat, vec )
          return SolutionMatDestructive( MutableCopyMat( mat ), ShallowCopy(vec) );
end );

#InstallMethod( SolutionMatDestructive,
#    "generic method for ordinary matrix and vector",
#    IsCollsElms,
#    [ IsOrdinaryMatrix,
#      IsRowVector ],
#        function ( mat, vec )
#          return SolutionMatNoCo( MutableTransposedMatDestructive( mat ),
#                   vec );
#end );

############################################################################
##
#M  SumIntersectionMat( <M1>, <M2> )  . .  sum and intersection of two spaces
##
##  performs  Zassenhaus' algorithm to  compute bases   for the  sum and  the
##  intersection of spaces generated by the rows of the matrices <M1>, <M2>.
##
##  returns a   list of length 2,   at first position  a base  of the sum, at
##  second position   a base  of    the intersection.   Both bases    are  in
##  semi-echelon form.
##
InstallMethod( SumIntersectionMat,
    IsIdenticalObj,
    [ IsMatrix, IsMatrix ],
function( M1, M2 )
    local n,      # number of columns
          mat,    # matrix for Zassenhaus algorithm
          zero,   # zero vector
          v,      # loop over 'M1' and 'M2'
          heads,  # list of leading positions
          sum,    # base of the sum
          i,      # loop over rows of 'mat'
          int;    # base of the intersection

    if   Length( M1 ) = 0 then
      return [ M2, M1 ];
    elif Length( M2 ) = 0 then
      return [ M1, M2 ];
    elif Length( M1[1] ) <> Length( M2[1] ) then
      Error( "dimensions of matrices are not compatible" );
    elif Zero( M1[1][1] ) <> Zero( M2[1][1] ) then
      Error( "fields of matrices are not compatible" );
    fi;

    n:= Length( M1[1] );
    mat:= [];
    zero:= Zero( M1[1] );

    # Set up the matrix for Zassenhaus' algorithm.
    mat:= [];
    for v in M1 do
      v:= ShallowCopy( v );
      Append( v, v );
      ConvertToVectorRepNC( v );
      Add( mat, v );
    od;
    for v in M2 do
      v:= ShallowCopy( v );
      Append( v, zero );
      ConvertToVectorRepNC( v );
      Add( mat, v );
    od;

    # Transform `mat' into semi-echelon form.
    mat   := SemiEchelonMatDestructive( mat );
    heads := mat.heads;
    mat   := mat.vectors;

    # Extract the bases for the sum \ldots
    sum:= [];
    for i in [ 1 .. n ] do
      if heads[i] <> 0 then
        Add( sum, mat[ heads[i] ]{ [ 1 .. n ] } );
      fi;
    od;

    # \ldots and the intersection.
    int:= [];
    for i in [ n+1 .. Length( heads ) ] do
      if heads[i] <> 0 then
        Add( int, mat[ heads[i] ]{ [ n+1 .. 2*n ] } );
      fi;
    od;

    # return the result
    return [ sum, int ];
end );


#############################################################################
##
#M  TriangulizeMat( <mat> ) . . . . . bring a matrix in upper triangular form
##
InstallMethod( TriangulizeMat,
    "generic method for mutable matrices",
    [ IsMatrix and IsMutable ],
    function ( mat )
    local m, n, i, j, k, row, zero, x, row2;

    Info( InfoMatrix, 1, "TriangulizeMat called" );

    if not IsEmpty( mat ) then

       # get the size of the matrix
       m := Length(mat);
       n := Length(mat[1]);
       zero := Zero( mat[1][1] );

       # make sure that the rows are mutable
       for i in [ 1 .. m ] do
         if not IsMutable( mat[i] ) then
           mat[i]:= ShallowCopy( mat[i] );
         fi;
       od;

       # run through all columns of the matrix
       i := 0;
       for k  in [1..n]  do

           # find a nonzero entry in this column
           j := i + 1;
           while j <= m and mat[j][k] = zero  do j := j + 1;  od;

           # if there is a nonzero entry
           if j <= m  then

               # increment the rank
               Info( InfoMatrix, 2, "  nonzero columns: ", k );
               i := i + 1;

               # make its row the current row and normalize it
               row    := mat[j];
               mat[j] := mat[i];
               x:= Inverse( row[k] );
               if x = fail then
                 TryNextMethod();
               fi;
               MultRowVector( row, x );
               mat[i] := row;

               # clear all entries in this column
               for j  in [1..i-1] do
                   row2 := mat[j];
                   x := row2[k];
                   if   x <> zero  then
                       AddRowVector( row2, row, - x );
                   fi;
               od;
               for j  in [i+1..m] do
                   row2 := mat[j];
                   x := row2[k];
                   if   x <> zero  then
                       AddRowVector( row2, row, - x );
                   fi;
               od;

           fi;

       od;

    fi;

    Info( InfoMatrix, 1, "TriangulizeMat returns" );
end );


InstallOtherMethod( TriangulizeMat,
    "for an empty list",
    [ IsList and IsEmpty],
    function( m ) return; end );

InstallMethod( TriangulizedMat, "generic method for matrices", [ IsMatrix ],
function ( mat )
local m;
  m:=List(mat,ShallowCopy);
  TriangulizeMat(m);
  return m;
end);

#############################################################################
##
#M  UpperSubdiagonal( <mat>, <pos> )
##
InstallMethod( UpperSubdiagonal,
    [ IsMatrix,
      IsPosInt ],
function( mat, l )
    local   dim,  exp,  i;

    # collect exponents in <e>
    dim := Length(mat);
    exp := [];

    # run through the diagonal
    for i  in [ 1 .. dim-l ]  do
        Add( exp, mat[i][l+i] );
    od;

    # and return
    return exp;
end );


#############################################################################
##
#F  BaseFixedSpace( <mats> )  . . . . . . . . . . . .  calculate fixed points
##
##  'BaseFixedSpace' returns a base of the vector space $V$ such that
##  $M v = v$ for all $v$ in $V$ and all matrices $M$ in the list <mats>.
##
InstallGlobalFunction( BaseFixedSpace, function( matrices )
    local I,            # identity matrix
          size,         # dimension of vector space
          E,            # linear system
          M,            # one matrix of 'matrices'
          N,            # M - I
          j;

    I := matrices[1]^0;
    size := Length(I);
    E := List( [ 1 .. size ], x -> [] );
    for M  in matrices  do
        N := M - I;
        for j  in [ 1..size ]  do
            Append( E[ j ], N[ j ] );
        od;
    od;
    return NullspaceMatDestructive( E );
end );


##########################################################################
##
#F  BaseSteinitzVectors( <bas>, <mat> )
##
##  find vectors extending mat to a basis spanning the span of <bas>.
##  'BaseSteinitz'  returns a
##  record  describing  a base  for the factorspace   and ways   to decompose
##  vectors:
##
##  zero:           zero of <V> and <U>
##  factorzero:     zero of complement
##  subspace:       triangulized basis of <mat>
##  factorspace:    base of a complement of <U> in <V>
##  heads:          a list of integers i_j, such that  if i_j>0 then a vector
##                  with head j is at position i_j  in factorspace.  If i_j<0
##                  then the vector is in subspace.
##
InstallGlobalFunction( BaseSteinitzVectors, function(bas,mat)
local z,l,b,i,j,k,stop,v,dim,h,zv;

  # catch trivial case
  if Length(bas)=0 then
    return rec(subspace:=[],factorspace:=[]);
  fi;

  z:=Zero(bas[1][1]);
  zv:=Zero(bas[1]);
  if Length(mat)>0 then
    mat:=MutableCopyMat(mat);
    TriangulizeMat(mat);
  fi;
  bas:=MutableCopyMat(bas);
  dim:=Length(bas[1]);
  l:=Length(bas)-Length(mat); # missing dimension
  b:=[];
  h:=[];
  i:=1;
  j:=1;
  while Length(b)<l do
    stop:=false;
    repeat
      if j<=dim and (Length(mat)<i or mat[i][j]=z) then
        # Add vector from bas with j-th component not zero (if any exists)
        v:=PositionProperty(bas,k->k[j]<>z);
        if v<>fail then
          # add the vector
          v:=bas[v];
          v:=1/v[j]*v; # normed
          Add(b,v);
          h[j]:=Length(b);
        # if fail, then this dimension is only dependent (and not needed)
        fi;
      else
        stop:=true;
        # check whether we are running to fake zero columns
        if i<=Length(mat) then
          # has a step, clean with basis vector
          v:=mat[i];
          v:=1/v[j]*v; # normed
          h[j]:=-i;
        else
          v:=fail;
        fi;
      fi;
      if v<>fail then
        # clean j-th component from bas with v
        for k in [1..Length(bas)] do
	  if not IsZero(bas[k][j]) then
	    bas[k]:=bas[k]-bas[k][j]/v[j]*v;
	  fi;
        od;
        v:=Zero(v);
        bas:=Filtered(bas,k->k<>v);
      fi;
      j:=j+1;
    until stop;
    i:=i+1;
  od;
  # add subspace indices
  while i<=Length(mat) do
    if mat[i][j]<>z then
      h[j]:=-i;
      i:=i+1;
    fi;
    j:=j+1;
  od;
  return rec(factorspace:=b,
             factorzero:=zv,
             subspace:=mat,
             heads:=h);
end );


#############################################################################
##
#F  BlownUpMat( <B>, <mat> )
##
InstallGlobalFunction( BlownUpMat, function ( B, mat )
    local result,  # blown up matrix, result
          vectors, # basis vectors of 'B'
          row,     # loop over rows of 'mat'
          b,       # loop over 'vectors'
          resrow,  # one row of 'result'
          entry;   # loop over 'row'

    vectors:= BasisVectors( B );
    result:= [];
    for row in mat do
      for b in vectors do
        resrow:= [];
        for entry in row do
          entry := Coefficients( B, entry * b );
          if entry = fail then return fail; fi;
          Append( resrow, entry );
        od;
        ConvertToVectorRepNC( resrow );
        Add( result, resrow );
      od;
    od;

    # Return the result.
    return result;
end );


#############################################################################
##
#F  BlownUpVector( <B>, <vector> )
##
InstallGlobalFunction( BlownUpVector, function ( B, vector )
    local result,  # blown up vector, result
          entry;   # loop over 'vector'

    result:= [];
    for entry in vector do
      Append( result, Coefficients( B, entry ) );
    od;
    ConvertToVectorRepNC( result );

    # Return the result.
    return result;
end );



#############################################################################
##
#F  IdentityMat( <m>[, <F>] ) . . . . . . . . identity matrix of a given size
##
InstallGlobalFunction( IdentityMat, function ( arg )
    local   id, m, zero, one, row, i, f;

    # check the arguments and get dimension, zero and one
    if Length(arg) = 1  then
        m    := arg[1];
        zero := 0;
        one  := 1;
        f    := Rationals;
    elif Length(arg) = 2  and IsRing(arg[2])  then
        m    := arg[1];
        zero := Zero( arg[2] );
        one  := One( arg[2] );
        f    := arg[2];
        if one = fail then
            Error( "ring must be a ring-with-one" );
        fi;
    elif Length(arg) = 2  then
        m    := arg[1];
        zero := Zero( arg[2] );
        one  := One( arg[2] );
        f    := Ring( one, arg[2] );
    else
        Error("usage: IdentityMat( <m>[, <R>] )");
    fi;

    # special treatment for 0-dimensional spaces
    if m=0 then
      return NullMapMatrix;
    fi;

    # make an empty row
    row := ListWithIdenticalEntries(m,zero);
    ConvertToVectorRepNC(row,f);

    # make the identity matrix
    id := [];
    for i  in [1..m]  do
        id[i] := ShallowCopy( row );
        id[i][i] := one;
    od;

    # We do *not* call ConvertToMatrixRep here, as that can cause
    # unexpected problems for the user (e.g. if a matrix over GF(2) is
    # created, and the user then tries to change an entry to Z(4),

    return id;
end );


#############################################################################
##
#F  NullMat( <m>, <n> [, <F>] ) . . . . . . . . . null matrix of a given size
##
InstallGlobalFunction( NullMat, function ( arg )
    local   null, m, n, zero, row, i, k, f;

    if Length(arg) = 2  then
        m    := arg[1];
        n    := arg[2];
        f    := Rationals;
    elif Length(arg) = 3  and IsRing(arg[3])  then
        m    := arg[1];
        n    := arg[2];
        f    := arg[3];
    elif Length(arg) = 3  then
        m    := arg[1];
        n    := arg[2];
        f    := Ring(One(arg[3]), arg[3]);
    else
        Error("usage: NullMat( <m>, <n> [, <R>] )");
    fi;
    zero := Zero(f);

    # make an empty row
    row := ListWithIdenticalEntries(n,zero);
    ConvertToVectorRepNC( row, f );

    # make the null matrix
    null := [];
    for i  in [1..m]  do
        null[i] := ShallowCopy( row );
    od;

    # We do *not* call ConvertToMatrixRep here, as that can cause
    # unexpected problems for the user (e.g. if a matrix over GF(2) is
    # created, and the user then tries to change an entry to Z(4),

    return null;
end );


#############################################################################
##
#F  NullspaceModQ( <E>, <q> ) . . . . . . . . . . .  nullspace of <E> mod <q>
##
##  <E> must be a matrix of integers modulo <q> and <q>  a prime power.  Then
##  'NullspaceModQ' returns  the set of  all vectors of  integers modulo <q>,
##  which solve the homogeneous equation system given by <E> modulo <q>.
##
InstallGlobalFunction( NullspaceModQ, function( E, q )
    local  facs,         # factors of <q>
           p,            # prime of facs
           pex,          # p-power
           n,            # <q> = p^n
           field,        # field with p elements
           B,            # E over GF(p)
           null,         # basis of nullspace of B
           elem,         # all elements solving E mod p^i-1
           e,            # one elem
           r,            # inhomogenous part mod p^i-1
           newelem,      # all elements solving E mod p^i
           sol,          # solution of E * x = r mod p^i
           ran,
           new, o,
           j, i,k;

    # factorize q
    facs  := FactorsInt( q );
    p     := facs[1];
    n     := Length( facs );
    field := GF(p);

    # solve homogeneous system mod p
    B    := One( field ) * E;
    null := NullspaceMat( B );
    if null = []  then
        return [ListWithIdenticalEntries (Length(E),0)];
    fi;

    # set up
    elem := List( AsList( FreeLeftModule(field,null,"basis") ),
            x -> List( x, IntFFE ) );
#T !
    newelem := [ ];
    o := One( field );

    ran:=[1..Length(null[1])];
    # run trough powers
    for i  in [ 2..n ]  do
        pex:=p^(i-1);
        for e  in elem  do
            #r   := o * ( - (e * E) / (p ^ ( i - 1 ) ) );
            r   := o * ( - (e * E) / pex );
            sol := SolutionMat( B, r );
            if sol <> fail then

                # accessing the elements of the compact vector `sol'
                # frequently would be very expensive
                sol:=List(sol,IntFFE);

                for j  in [ 1..Length( elem ) ]  do
                    #new := e + ( p^(i-1) * List( o * elem[j] + sol, IntFFE ) );
                    new:=ShallowCopy(e);
                    for k in ran do
                      #new[k]:=new[k]+pex * IntFFE(o*elem[j][k]+ sol[k]);
                      new[k]:=new[k]+pex * ((elem[j][k]+ sol[k]) mod p);
                    od;
#T !
                    MakeImmutable(new); # otherwise newelem does not remember
                                        # it is sorted!
                    AddSet( newelem, new );
                od;
            fi;
        od;
        if Length( newelem ) = 0  then
            return [];
        fi;
        elem    := newelem;
        newelem := [ ];
    od;
    return elem;
end );


#############################################################################
##
#F  BasisNullspaceModN( <M>, <n> ) . . . . . . .  .  nullspace of <E> mod <n>
##
##  <M> must be a matrix of integers modulo <n> and <n> a positive integer.
##  Then 'NullspaceModQ' returns a set <B> of vectors such that every <v>
##  such that <v> <M> = 0 modulo <n> can be expressed by a Z-linear combination
##  of elements of <M>.
##
InstallGlobalFunction (BasisNullspaceModN, function (M, n)
    local snf, null, nullM, i, gcdex;

    # if n is a  prime, Gaussian elimination is fastest
    if IsPrimeInt (n) then
       return List (NullspaceMat (M*One(GF(n))),
          v -> List (v, IntFFE));
    fi;
    
    # compute the Smith normal form S for M, i.e., S = R M C
    snf := NormalFormIntMat (M, 1+4);

    # compute the nullspace of S mod n
    null := IdentityMat (Length (M));
    
    for i in [1..snf.rank] do
        null[i][i] := n/GcdInt (n, snf.normal[i][i]);
    od;
    
    # nullM = null*R is the nullspace of M C mod n
    # since solutions do not change under elementary matrices
    # nullM is also the nullspace for M
    
    nullM := null*snf.rowtrans mod n;
    Assert (1, ForAll (nullM, v -> v*M mod n =0*M[1]));
    return nullM;
end);


#############################################################################
##
#F  PermutationMat( <perm>, <dim> [, <F> ] ) . . . . . .  permutation matrix
##
InstallGlobalFunction( PermutationMat, function( arg )
    local i,       # loop variable
          perm,    # permutation
          dim,     # desired dimension of the permutation matrix
          F,       # field of the matrix entries (defauled to 'Rationals')
          mat;     # matrix corresponding to 'perm', result

    if not ( ( Length( arg ) = 2 or Length( arg ) = 3 )
             and IsPerm( arg[1] ) and IsInt( arg[2] ) ) then
      Error( "usage: PermutationMat( <perm>, <dim> [, <F> ] )" );
    fi;

    perm:= arg[1];
    dim:= arg[2];
    if Length( arg ) = 2 then
      F:= Rationals;
    else
      F:= arg[3];
    fi;

    mat:= NullMat( dim, dim, F );

    for i in [ 1 .. dim ] do
        mat[i][ i^perm ]:= One( F );
    od;

    return mat;
end );


#############################################################################
##
#F  DiagonalMat( <vector> )
##
InstallGlobalFunction( DiagonalMat, function( vector )
    local zerovec,
          M,
          i;

    M:= [];
    zerovec:= Zero( vector[1] );
    zerovec:= List( vector, x -> zerovec );

    for i in [ 1 .. Length( vector ) ] do
      M[i]:= ShallowCopy( zerovec );
      M[i][i]:= vector[i];
      ConvertToVectorRepNC(M[i]);
    od;

    # We do *not* call ConvertToMatrixRep here, as that can cause
    # unexpected problems for the user (e.g. if a matrix over GF(2) is
    # created, and the user then tries to change an entry to Z(4),

    return M;
end );


#############################################################################
##
#F  ReflectionMat( <coeffs> )
#F  ReflectionMat( <coeffs>, <root> )
#F  ReflectionMat( <coeffs>, <conj> )
#F  ReflectionMat( <coeffs>, <conj>, <root> )
##
InstallGlobalFunction( ReflectionMat, function( arg )
    local coeffs,     # coefficients vector, first argument
          w,          # root of unity, second argument (optional)
          conj,       # conjugation function, third argument (optional)
          M,          # matrix of the reflection, result
          n,          # length of 'coeffs'
          one,        # identity of the ring over that 'coeffs' is written
          c,          # coefficient of 'M'
          i,          # loop over rows of 'M'
          j,          # loop over columns of 'M'
          row;        # one row of 'M'

    # Get and check the arguments.
    if    Length( arg ) < 1 or 3 < Length( arg )
       or not IsList( arg[1] ) then
      Error( "usage: ReflectionMat( <coeffs> [, <conj> ] [, <k> ] )" );
    fi;
    coeffs:= arg[1];
    if   Length( arg ) = 1 then
      w:= -1;
      conj:= List( coeffs, ComplexConjugate );
    elif Length( arg ) = 2 then
      if not IsFunction( arg[2] ) then
        w:= arg[2];
        conj:= List( coeffs, ComplexConjugate );
      else
        w:= -1;
        conj:= arg[2];
        if not IsFunction( conj ) then
          Error( "<conj> must be a function" );
        fi;
        conj:= List( coeffs, conj );
      fi;
    elif Length( arg ) = 3 then
      conj:= arg[2];
      if not IsFunction( conj ) then
        Error( "<conj> must be a function" );
      fi;
      conj:= List( coeffs, conj );
      w:= arg[3];
    fi;

    # Construct the matrix.
    M:= [];
    one:= coeffs[1] ^ 0;
    w:= w * one;
    n:= Length( coeffs );
    c:= ( w - one ) / ( coeffs * conj );
    for i in [ 1 .. n ] do
      row:= [];
      for j in [ 1 .. n ] do
        row[j]:= conj[i] * c * coeffs[j];
      od;
      row[i]:= row[i] + one;
      ConvertToVectorRepNC( row );
      M[i]:= row;
    od;

    # We do *not* call ConvertToMatrixRep here, as that can cause
    # unexpected problems for the user (e.g. if a matrix over GF(2) is
    # created, and the user then tries to change an entry to Z(4),

    return M;
end );


#########################################################################
##
#F  RandomInvertibleMat( <m> [, <R>] )  . . . make a random invertible matrix
##
##  'RandomInvertibleMat' returns a invertible   random matrix with  <m> rows
##  and columns  with elements  taken from  the  ring <R>, which defaults  to
##  'Integers'.
##
InstallGlobalFunction( RandomInvertibleMat, function ( arg )
    local   mat, m, R, i, row, k;

    # check the arguments and get the list of elements
    if Length(arg) = 1  then
        m := arg[1];
        R := Integers;
    elif Length(arg) = 2  then
        m := arg[1];
        R := arg[2];
    else
        Error("usage: RandomInvertibleMat( <m> [, <R>] )");
    fi;

    # now construct the random matrix
    mat := [];
    for i  in [1..m]  do
        repeat
            row := [];
            for k  in [1..m]  do
                row[k] := Random( R );
            od;
            ConvertToVectorRepNC( row, R );
            mat[i] := row;
        until NullspaceMat( mat ) = [];
    od;

    # We do *not* call ConvertToMatrixRep here, as that can cause
    # unexpected problems for the user (e.g. if a matrix over GF(2) is
    # created, and the user then tries to change an entry to Z(4),

    return mat;
end );


#############################################################################
##
#F  RandomMat( <m>, <n> [, <R>] ) . . . . . . . . . . .  make a random matrix
##
##  'RandomMat' returns a random matrix with <m> rows and  <n>  columns  with
##  elements taken from the ring <R>, which defaults to 'Integers'.
##
InstallGlobalFunction( RandomMat, function ( arg )
    local   mat, m, n, R, i, row, k;

    # check the arguments and get the list of elements
    if Length(arg) = 2  then
        m := arg[1];
        n := arg[2];
        R := Integers;
    elif Length(arg) = 3  then
        m := arg[1];
        n := arg[2];
        R := arg[3];
    else
        Error("usage: RandomMat( <m>, <n> [, <F>] )");
    fi;

    # now construct the random matrix
    mat := [];
    for i  in [1..m]  do
        row := [];
        for k  in [1..n]  do
            row[k] := Random( R );
        od;
        ConvertToVectorRepNC( row, R );
        mat[i] := row;
    od;

    # We do *not* call ConvertToMatrixRep here, as that can cause
    # unexpected problems for the user (e.g. if a matrix over GF(2) is
    # created, and the user then tries to change an entry to Z(4),

    return mat;
end );


#############################################################################
##
#F  RandomUnimodularMat( <m> )  . . . . . . . . . .  random unimodular matrix
##
InstallGlobalFunction( RandomUnimodularMat, function ( m )
    local  mat, c, i, j, k, l, a, b, v, w, gcd;

    # start with the identity matrix
    mat := IdentityMat( m );

    for c  in [1..m]  do

        # multiply two random rows with a random? unimodular 2x2 matrix
        i := Random([1..m]);
        repeat
            j := Random([1..m]);
        until j <> i;
        repeat
            a := Random( Integers );  b := Random( Integers );
            gcd := Gcdex( a, b );
        until gcd.gcd = 1;
        v := mat[i];  w := mat[j];
        mat[i] := ShallowCopy(gcd.coeff1 * v + gcd.coeff2 * w);
        mat[j] := ShallowCopy(gcd.coeff3 * v + gcd.coeff4 * w);

        # multiply two random cols with a random? unimodular 2x2 matrix
        k := Random([1..m]);
        repeat
            l := Random([1..m]);
        until l <> k;
        repeat
            a := Random( Integers );  b := Random( Integers );
            gcd := Gcdex( a, b );
        until gcd.gcd = 1;
        for i  in [1..m]  do
            v := mat[i][k];  w := mat[i][l];
            mat[i][k] := gcd.coeff1 * v + gcd.coeff2 * w;
            mat[i][l] := gcd.coeff3 * v + gcd.coeff4 * w;
            ConvertToVectorRepNC( mat[i] );
        od;

    od;

    return mat;
end );


#############################################################################
##
#F  SimultaneousEigenvalues( <matlist>, <expo> ) . . . . . . . . .eigenvalues
##
##  The matgroup  generated  by  <matlist>  must be  an   abelian p-group  of
##  exponent <expo>.  The matrices in  matlist must be  matrices over GF(<q>)
##  for some prime <q>. Then the eigenvalues of <mat>  in the splitting field
##  GF(<q>^r) for some r are powers of an element ksi in the splitting field,
##  which is of order <expo>.
##
##  'SimultaneousEigenspaces'  returns a matrix  of intergers mod <expo>, say
##  (a_{i,j}), such that the  power ksi^a_{i,j} is an  eigenvalue of the i-th
##  matrix in <matlist> and the eigenspaces of  the different matrices to the
##  eigenvalues ksi^a_{i,j} for fixed j are equal.
##
InstallGlobalFunction( SimultaneousEigenvalues,
    function( arg )
    local matlist, expo,
            q,       # characteristic of field of matrices
            r,       # such that <q>^r is splitting field
            field,   # GF(<q>^r)
            ksi,     # <expo>-root of field
            eival,   # exponents of eigenvalues of the matrices
            eispa,   # eigenspaces of the matrices
            eigen,   # exponents of simultaneous eigenvalues
            I,       # identity matrix
            w,       # ksi^w is candidate for a eigenvalue
            null,    # basis of nullspace
            i, Split;

    Split := function( space, i )
        local   int,   # intersection of two row spaces
                j;

        for j  in [1..Length(eival[i])]  do
            if 0 < Length( eispa[i][j] )  then
                int := SumIntersectionMat( space, eispa[i][j] )[2];
                if 0 < Length( int ) then
                    Append( eigen[i],
                            List( int, x -> eival[i][j] ) );
                    if i < Length( matlist )  then
                        Split( int, i+1 );
                    fi;
                fi;
            fi;
        od;
    end;

    matlist := arg[1];
    expo    := arg[2];

    # compute ksi
    if Length( arg ) = 2 then
        q := Characteristic( matlist[1][1][1] );

        # get splitting field
        r := 1;
        while EuclideanRemainder( q^r - 1, expo ) <> 0  do
            r := r+1;
        od;
        field := GF(q^r);
        ksi   := GeneratorsOfField(field)[1]^((q^r - 1) / expo);
    else
        ksi := arg[3];
    fi;

    # set up eigenvalues and spaces and Idmat
    eival  := List( matlist, x -> [] );
    eispa  := List( matlist, x -> [] );
    I      := matlist[1]^0;

    # calculate eigenvalues and spaces for each matrix
    for i in [1..Length(matlist)]  do
        for w in [0..expo-1]  do
            null := NullspaceMat( matlist[i] - (ksi^w * I) );
            if 0 < Length(null)  then
                Add( eival[i], w );
                Add( eispa[i], null );
            fi;
        od;
    od;

    # now make the eigenvalues simultaneous
    eigen := List( matlist, x -> [] );
    for i  in [1..Length(eival[1])]  do
        Append( eigen[1], List( eispa[1][i], x -> eival[1][i] ) );
        if Length( matlist ) > 1  then
            Split( eispa[1][i], 2 );
        fi;
    od;

    # return
    return eigen;
end );

#############################################################################
##
#F  FlatBlockMat( <blockmat> ) . . . . . . . . . . . convert block mat to mat
##
InstallGlobalFunction( FlatBlockMat, function( block )
    local d, l, mat, i, j, h, k, a, b;

    d := Length( block );
    l := Length( block[1][1] );
    mat := List( [1..d*l], x -> List( [1..d*l], y -> false ) );
    for i in [1..d] do
        for j in [1..d] do
            for h in [1..l] do
                for k in [1..l] do
                    a := (i-1)*l + h;
                    b := (j-1)*l + k;
                    mat[a][b] := block[i][j][h][k];
                od;
            od;
        od;
    od;
    return mat;
end );

#############################################################################
##
#F  DirectSumMat( <matlist> ) . . . . . . . . . . . create block diagonal mat
#F  DirectSumMat( mat1,..,matn )  . . . . . . . . . create block diagonal mat
##
InstallGlobalFunction( DirectSumMat, function (arg)
    local  c, r, res, m, f, F;
    if Length(arg)=1 and not IsMatrix(arg[1]) then
        arg:=arg[1];
    fi;
    f:=function(m)
        if Length(m)=0 then
            return 0;
        else
            return Length(m[1]);
        fi;
    end;
    r:=1; m:=[ ];
    while m = [ ] and r <= Length( arg ) do
      m:= arg[r]; r:=r+1;
    od;
    if m <> [ ] then
      F:= DefaultField( m[1][1] );
    else
      F:= Rationals;
    fi;
    res:=List(NullMat(Sum(arg,Length),Sum(arg,f),F),ShallowCopy);
    r:=0;
    c:=0;
    for m in arg do
        res{r+[1..Length(m)]}{c+[1..f(m)]}:=m;
        r:=r+Length(m);
        c:=c+f(m);
    od;
    return res;
end );


#############################################################################
##
#F  TraceMat( <mat> ) . . . . . . . . . . . . . . . . . . . trace of a matrix
##
InstallMethod( TraceMat, "method for lists", [ IsList ],
    function ( mat )
    local   trc, m, i;

    # check that the element is a square matrix
    m := Length(mat);
    if m <> Length(mat[1])  then
        Error("TraceMat: <mat> must be a square matrix");
    fi;

    # sum all the diagonal entries
    trc := mat[1][1];
    for i  in [2..m]  do
        trc := trc + mat[i][i];
    od;

    # return the trace
    return trc;
end );


#############################################################################
##
#M  Trace( <mat> )  . . . . . . . . . . . . . . . . . . . . . .  for a matrix
##
InstallOtherMethod( Trace,
    "generic method for matrices",
    [ IsMatrix ],
    TraceMat );


#############################################################################
##
#M JordanDecomposition( <mat> )
##
InstallMethod( JordanDecomposition,
           "method for matrices",
           [IsMatrix],
function( mat )

  local F,p,B,f,g,fac,ff,h,w;

# The algorithm is due to R. Beals

  F:= DefaultFieldOfMatrix( mat );
  if F = fail then
    TryNextMethod();
  fi;
  p:= Characteristic( F );

# First we determine a squarefree polynomial 'g' such that 'g^d(mat)=0'.

  f:= CharacteristicPolynomial( F, F, mat );
  if p = 0 or p > Length( mat ) then
    g:= f/Gcd( f, Derivative( f ) );
  else
    fac:= Factors(f);
    g:= One( F );
    ff:= [ ];
    for h in fac do
      if not h in ff then
        g:= g*h;
        Add( ff, h );
      fi;
    od;
  fi;

  if f=g then return [ mat, 0*mat ]; fi;

# Now 'B' will be the semisimple part of the matrix 'mat'.

  w:= GcdRepresentation( g, Derivative( g ) )[2];
  w:= w*g;
  B:= ShallowCopy( mat );
  while Value( g, B ) <> 0*B do
    B:= B - Value( w, B );
  od;

  return [ B, mat-B ];

end );

#############################################################################
##
#F  OnSubspacesByCanonicalBasis(<bas>,<mat>)
##
InstallGlobalFunction(OnSubspacesByCanonicalBasis,function( mat, obj )
    local row;
    mat:=mat*obj;
    if not IsMutable(mat) then
        mat := MutableCopyMat(mat);
    else
        for row in [1..Length(mat)] do
            if not IsMutable(mat[row]) then
                mat[row] := ShallowCopy(mat[row]);
            fi;
        od;
    fi;
    TriangulizeMat(mat);
    return mat;
end);

#############################################################################
##
#F  OnSubspacesByCanonicalBasisConcatenations(<basvec>,<mat>)
##
InstallGlobalFunction(OnSubspacesByCanonicalBasisConcatenations,
function( bvec, obj )
  local n,a,mat,r;
  n:=Length(obj); # acting dimension
  mat:=[];
  a:=1;
  while a<Length(bvec) do
    r:=bvec{[a..a+n-1]}*obj;
    if not IsMutable(r) then r:=ShallowCopy(r);fi;
    Add(mat,r);
    a:=a+n;
  od;
  TriangulizeMat(mat);
  return Concatenation(mat);
end);

#############################################################################
##
#M  FieldOfMatrixList
##
InstallMethod(FieldOfMatrixList,"generic: form field",
  [IsListOrCollection],
function(l)
local i,j,k,fg,f;
  # try to find out the field
  if Length(l)=0 or ForAny(l,i->not IsMatrix(i)) then
    Error("<l> must be a list of matrices");
  fi;
  fg:=[l[1][1][1]];
  f:=Field(fg);
  for i in l do
    for j in i do
      for k in j do
        if not k in f then
          Add(fg,k);
          f:=Field(fg);
        fi;
      od;
    od;
  od;
  return f;
end);

#############################################################################
##
#M  DefaultScalarDomainOfMatrixList
##
InstallMethod(DefaultScalarDomainOfMatrixList, "generic: form ring",
  [IsListOrCollection],
function(l)
local i,j,k,fg,f;
  # try to find out the field
  if Length(l)=0 or ForAny(l,i->not IsMatrix(i)) then
    Error("<l> must be a list of matrices");
  fi;
  fg:=[l[1][1][1]];
  if Characteristic(fg)=0 then
    f:=DefaultField(fg);
  else
    f:=DefaultRing(fg);
  fi;
  for i in l do
    for j in i do
      for k in j do
        if not k in f then
          Add(fg,k);
          f:=DefaultRing(fg);
        fi;
      od;
    od;
  od;
  return f;
end);


#############################################################################
##
#F  NOT READY: BaseNullspace( <struct> )
##
#T BaseNullspace := function( struct )
#T     if   IsMat( struct ) then
#T       return NullspaceMat( struct );
#T     elif IsRecord( struct ) then
#T       if not IsBound( struct.baseNullspace ) then
#T         if not IsBound( struct.operations ) then
#T           Error( "<struct> must have 'operations' entry" );
#T         fi;
#T         struct.baseNullspace:=
#T             struct.operations.BaseNullspace( struct );
#T       fi;
#T       return struct.baseNullspace;
#T     else
#T       Error( "<struct> must be a matrix or a record" );
#T     fi;
#T     end;


##########################################################################
##
#F  NOT READY: MatricesOps.InvariantForm( <D> )
##
#T MatricesOps.InvariantForm := function( D )
#T     local F,          # field
#T           q,          # size of 'F'
#T           A,          # 'F'-algebra generated by 'D'
#T           nr,         # word number
#T           word,       # loop over algebra elements
#T           i,          # loop variable
#T           ns,         # file for a nullspace
#T           sb1,        # standard basis of 'D'
#T           T,          # contragredient representation
#T           sb2,        # standard basis of 'T'
#T           M;          # invariant form, result
#T
#T     if   not ( IsList( D ) and ForAll( D, IsMatrix ) ) then
#T       Error( "<D> must be a list of matrices" );
#T     elif Length( D ) = 0 then
#T       Error( "need at least one matrix" );
#T     fi;
#T
#T     F:= Field( Flat( D ) );
#T     if not IsFinite( F ) then
#T       Error( "sorry, for finite fields only" );
#T     fi;
#T     q:= Size( F );
#T
#T     # Search for an algebra element of nullity 1.
#T     # Use normed words only, that is, words of the form $I + w$.
#T     # Write the 'D' nullspace of the nullity 1 word to 'ns'.
#T     A:= Algebra( F, D );
#T     nr:= 1;
#T     repeat
#T       nr:= nr + q;
#T       word:= ElementAlgebra( A, nr );
#T       ns:= NullspaceMat( word );
#T     until Length( ns ) = 1;
#T
#T     # Compute the standard basis for the natural module of 'D',
#T     # starting with the word of nullity 1, write output to 'sb1'
#T     sb1:= BasisVectors( StandardBasis( Module( A, ns ) ) );
#T
#T     # Check whether the whole space is spanned.
#T     if Length( sb1 ) < Length( ns[1] ) then
#T       Error( "representation is reducible" );
#T     fi;
#T
#T     # Make the contragredient representation 'T'.
#T     T:= Algebra( A.field, List( D, x -> TransposedMat( x^-1 ) ) );
#T
#T     # Write the 'T' nullspace of the nullity 1 word to 'ns'.
#T     ns:= NullspaceMat( ElementAlgebra( T, nr ) );
#T
#T     # Compute the standard basis for the natural module of 'T',
#T     # starting with the word of nullity 1, write output to 'sb2'
#T     sb2:= BasisVectors( StandardBasis( Module( T, ns ) ) );
#T
#T     # If 'D' and 'T' are equivalent then
#T     # the invariant matrix is 'M = sb1^(-1) * sb2',
#T     # since 'sb1 * D[i] * sb1^(-1) = sb2 * T[i] * sb2^(-1)' implies
#T     # that 'D[i] * M * D[i]^{tr} = M'.
#T     M:= sb1^-1 * sb2;
#T
#T     # Check for equality.
#T     for i in [ 1 .. Length( D ) ] do
#T       if D[i] * M * TransposedMat( D[i] ) <> M then
#T         return false;
#T       fi;
#T     od;
#T
#T     # Return the result.
#T     return M;
#T     end;


#############################################################################
##
#F  BaseOrthogonalSpaceMat( <mat> )
##
InstallMethod( BaseOrthogonalSpaceMat,
    "for a matrix",
    [ IsMatrix ],
    mat -> NullspaceMat( TransposedMat( mat ) ) );

# simplex method, code by Ken Monks, AH

#in matrix M, row reduce to get 1s
#in exactly the columns given by 
#L a list of indices
BindGlobal("TriangulizeMatPivotColumns",function(M,L)
local idx,i;

   if L=[1..Length(L)] then
     TriangulizeMat(M);
   else
     idx:=Concatenation(L,Filtered([1..Length(M[1])],x->not x in L));
     for i in [1..Length(M)] do M[i]:=M[i]{idx}; od;
     TriangulizeMat(M);
     idx:=ListPerm(PermList(idx)^-1,Length(M[1]));
     for i in [1..Length(M)] do M[i]:=M[i]{idx}; od;
   fi;

end);

#inputs a linear form c and maximizes it subject to 
#the constraints Ax <= b where all entries of b are nonnegative.
InstallGlobalFunction(SimplexMethod,function(A,b,c)
local M, n, p, vars, slackVars, i, id, bestMove,
  newNonzero, len, ratios, newZero, positiveRatios, point, value,Val;

  Val:=function(M,vars,slackVars,len,x) 
      if x in vars then 
          return 0; 
      else return M[Position(slackVars,x)+1][len]; 
      fi; 
  end;

   #check the size of the data is legit

   n:=Size(c);
   p:=Size(b);
   if not (IsMatrix(A) and Size(A)=p and ForAny(A,R->Size(R)=n)) then
       Error( "usage: SimplexMethod( <A>, <b>, <c>)");
   fi;

   id:=IdentityMat(p,Rationals);

   #build the augmented matrix
   
   #first row   
   M:=[Concatenation([1],-c,List([1..p+1],x->0))];
   #the rest of the rows
   for i in [1..p] do 
       Add(M,Concatenation([0],A[i],id[i],[b[i]]));
   od;
      
   len:=Size(M[1]);

   #initialize the feasible starting vertex
   if ForAll(b,x->not x<0) then 
       vars:=[2..2+n-1];      
       slackVars:=[2+n..n+p+1];
   else
       return "Invalid data: not all constraints nonnegative!";
   fi;
   
   #Print("slackVars are ",slackVars ,"\n");
   #Print("vars are ",vars,"\n");
   #Display(M);
   
   TriangulizeMatPivotColumns(M,Concatenation([1],slackVars));
   #Display(M);
   #bestMove is the coeff var that will become nonzero
   bestMove:=Minimum(List(vars,i->M[1][i]));
   newNonzero:=vars[Position(List(vars,i->M[1][i]),bestMove)];
   
   #Print(newNonzero, " is the new nonzero guy \n");
   
   while bestMove<0  do
        
       #see if figure is unbounded
       #Print("about to do some ratios \n");
       #Print(List([1..p],x-> M[x+1][newNonzero]), " is what we're going to divide by \n");
       ratios:=List([1..p], function(x) if M[x+1][newNonzero]=0 then return infinity; else return M[x+1][len]/M[x+1][newNonzero]; fi; end);
       #Print("done doing some ratios");
       positiveRatios:=Filtered(ratios,x -> x>0);
       if Size(positiveRatios)=0 then return "Feasible region unbounded!"; fi;
       
       #Print("Feasible region still looks bounded. \n");

       #figure out who will become zero
       newZero:=slackVars[Position(ratios,Minimum(positiveRatios))];       
       
       #Print(newZero, " is the new zero guy \n");       
       
       Remove(slackVars,Position(slackVars,newZero));
       Remove(vars,Position(vars,newNonzero));
       Add(vars,newZero);
       Add(slackVars,newNonzero);
       
       slackVars:=Set(slackVars);
       vars:=Set(vars);

       #Print("slackVars are ",slackVars,"\n");
       #Print("vars are ",vars,"\n");

       TriangulizeMatPivotColumns(M,Concatenation([1],slackVars));
       #Display(M);
       bestMove:=Minimum(List(vars,i->M[1][i]));
       
       newNonzero:=vars[Position(List(vars,i->M[1][i]),bestMove)];
       #Print(newNonzero," is the new nonzero guy");

   od;
   
   #calculate the original point and the max value there
   
   point:=List([2..2+n-1],x -> Val(M,vars,slackVars,len,x));
   value:=point*c;
   
   return [point,value];
end);


# can do better for matrices and large exponents, preliminary improvement,
# will be further improved (FL)
##  InstallMethod( \^,
##      "for matrices, use char. poly. for large exponents",
##      [ IsMatrix, IsPosInt ],
##  function(mat, n)
##    local pol, indet;
##    # generic method for small n, break even point probably a bit lower,
##    # needs rethinking and some experiments.
##    if n < 2^Length(mat) then
##      return POW_OBJ_INT(mat, n);
##    fi;
##    pol := CharacteristicPolynomial(mat);
##    indet := IndeterminateOfUnivariateRationalFunction(pol);
##    # cost of this needs to be investigated
##    pol := PowerMod(indet, n, pol);
##    # now we are sure that we need at most Length(mat) matrix multiplications
##    return Value(pol, mat);
##  end);
##  
# next iteration, conjugate matrix such that it is often very sparse 
# (a companion matrix), could still be improved, maybe with kernel functions
# for compact matrices (FL)
BindGlobal("POW_MAT_INT", function(mat, n)
  local d, addb, trafo, value, t, ti, mm, pol, ind;
  d := Length(mat);
  # finding a better break even point probably also depends on q
  if n < 2^QuoInt(3*d,4) then
    return POW_OBJ_INT(mat, n);
  fi;
  # helper function to build up a semi-echelon basis
  addb := function(seb, v)
    local rows, pivots, len, vv, c, pos, i;
    rows := seb.vectors;
    pivots := seb.pivots;
    len := Length(rows);
    vv := ShallowCopy(v);
    for i in [1..len] do
      c := vv[pivots[i]];
      if not IsZero(c) then
        AddRowVector(vv, rows[i], -c);
      fi;
    od;
    pos := PositionNonZero(vv);
    if pos <= Length(vv) then
      if not IsOne(vv[pos]) then
        vv := vv/vv[pos];
      fi;
      Add(rows, vv);
      Add(pivots, pos);
      seb.heads[pos] := len + 1;
      return true;
    else
      return false;
    fi;
  end;
  # this returns a base change matrix such that t*m*t^-1 is block triangular
  # with companion matrices along the diagonal
  # (could/should? be improved to return t^-1, t*m*t^-1 and the
  # characteristic polynomial of m at the same time)
  trafo := function(m)
    local id, b, t, r, a;
    id := m^0;
    b := rec(vectors := [], pivots := [], heads := []);
    t := [];
    # maybe better start with a random vector?
    for a in id do
      r := addb(b,a);
      if r = true then
        repeat 
          Add(t, a);
          a := a*m;
          r := addb(b,a);
        until r <> true;
      fi;
    od;
    t := Matrix(t, m);
    return t;
  end;
  # compared to standard method, we avoid some zero or identity matrices
  # and we multiply with mat from left to take advantage of sparseness of mat
  value := function(pol, mat)
    local f, c, i, val, j;
    f := CoefficientsOfLaurentPolynomial(pol);
    c := f[1];
    i := Length(c);
    if i = 0 then
      return 0*mat;
    fi;
    if i = 1 then
      val := POW_OBJ_INT(mat, f[2]);
      return c[1] * val;
    fi;
    val := c[i] * mat;
    if not IsMutable(val[1]) then
      val := MutableCopyMat(val);
    fi;
    i := i-1;
    for j in [1..Length(mat)] do
      val[j][j] := val[j][j]+c[i];
    od;
    while 1 < i  do
      val := mat * val;
      i := i - 1;
      for j in [1..Length(mat)] do
        val[j][j] := val[j][j]+c[i];
      od;
    od;
    if 0 <> f[2]  then
      val := val * POW_OBJ_INT(mat, f[2]);
    fi;
    return val;
  end;
  t := trafo(mat);
  ti := t^-1;
  mm := t * mat * ti;
  pol := CharacteristicPolynomial(mm);
  ind := IndeterminateOfUnivariateRationalFunction(pol);
  pol := PowerMod(ind, n, pol);
  mm := value(pol, mm);
  return ti * mm * t;
end);

InstallMethod( \^,
    "for matrices, use char. poly. for large exponents",
    [ IsMatrix, IsPosInt ], POW_MAT_INT );

InstallGlobalFunction(RationalCanonicalFormTransform,function(mat)
local cr,R,x,com,nf,matt,p,i,j,di,d,v;
  matt:=TransposedMat(mat);
  cr:=DefaultFieldOfMatrix(mat);
  R:=PolynomialRing(cr,1);
  x:=IndeterminatesOfPolynomialRing(R)[1];
  com:=x*mat^0-mat;
  com:=List(com,ShallowCopy);
  nf:=DoDiagonalizeMat(R,com,true,true,matt);
  di:=DiagonalOfMat(nf.normal);
  p:=[];
  for i in [1..Length(di)] do
    d:=DegreeOfUnivariateLaurentPolynomial(di[i]);
    if d>0 then
      v:=List(nf.basmat[i],x->Value(x,Zero(cr))); # move in base ring
      Add(p,v);
      for j in [1..d-1] do
        v:=v*matt;
	Add(p,v);
      od;
    fi;
  od;
  return TransposedMat(p);
end);


#############################################################################
##  
#E
