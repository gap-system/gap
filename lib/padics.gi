#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Jens Hollmann.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementation part of the padic numbers.
##


#############################################################################
##
#F  PrintPadicExpansion( <ppower>, <int>, <prime>, <precision> )
##
##  PrintPadicsExpansion prints   a pure p-adic  number x,  which is given as
##  <ppower> and <int> such  that  x =  <prime>^<ppower>*<int> as the  p-adic
##  expansion in the  pure p-adic numbers with   <precision> "digits".  <int>
##  may be  divisible by <prime>.  Each "digit"  ranges from  0 to <prime>-1.
##  If a "digit" has more  than one decimal digit  it  is embraced in  single
##  quotes.
##
##  For Example:
##      153.0(17) is  1*17^(-2) + 5*17^(-1) + 3*17^0 and
##    '15'3.0(17) is 15*17^(-1) + 3*17^0
##
BindGlobal( "PrintPadicExpansion", function( ppower, int, prime, precision )
    local   pos,  flag,  z,  k,  r;

    if int = 0  then
        Print( "0" );
    else

        # <int> might be divisible by <prime>
        while int mod prime = 0 do
            int := int / prime;
            ppower := ppower + 1;
        od;
        if ppower > 0 then

            # leading zeros
            for pos in [0..ppower-1] do
                if pos = 1 then
                    Print( "." );
                fi;
                Print( "0" );
            od;
        fi;
        pos := ppower;
        flag := false;

        # print the <int>
        z := int;
        k := 1;
        r := z mod prime;
        while (pos < 1) or ((k<=precision) and (z<>0)) do
            if pos = 1 then
                Print( "." );
            fi;
            if prime >= 10 then
                if flag then
                    Print( r, "'" );
                else
                    Print( "'" , r, "'" );
                fi;
                flag := true;
            else
                Print( r );
                flag := false;
            fi;
            z := (z - r) / prime;
            r := z mod prime;
            k := k + 1;
            pos := pos + 1;
        od;
    fi;
    Print( "(", prime, ")" );
end );


#############################################################################
##
#F  PadicExpansionByRat( <a>, <prime>, <precision>)
##
##  PadicExpansionByRat takes a rational <a> and returns a list [ppart, erg],
##  such  that  <a>  is <prime>^ppart*erg in   the pure  p-adic numbers  over
##  <prime> with <precision> "digits".
##
##  For Example:
##    PadicExpansionByRat(5, 3, 4)   -> [0,  5] = 12.00(3)
##    PadicExpansionByRat(1/2, 3, 4) -> [0, 41] = 2.111(3)
##
BindGlobal( "PadicExpansionByRat", function( a, prime, precision )
    local   c,  flag,  ppart,  z,  step,  erg,  ppot,  l,  digit;

    if a = 0 then
        c := [0,0];
    else

        # extract the p-part (num and den of rationals are coprime)
        flag := false;
        ppart := 0;
        if NumeratorRat(a) mod prime = 0 then
            z := NumeratorRat(a) / prime;
            step := 1;
            flag := true;
        fi;
        if DenominatorRat(a) mod prime = 0 then
            z := DenominatorRat(a) / prime;
            step := -1;
            flag := true;
        fi;
        if flag then

            # extract the <prime>-part
            ppart := step;
            while z mod prime = 0 do
                z := z / prime;
                ppart := ppart + step;
            od;
        fi;
        a := a / prime^ppart;
        erg := 0;
        ppot := 1;
        l := 1;
        while( l<= precision) and (a <> 0) do
            digit := a mod prime;
            erg := erg + digit * ppot;
            a := (a - digit) / prime;
            ppot := ppot * prime;
            l := l + 1;
        od;
        c := [ppart, erg];
    fi;
    return c;
end );


#############################################################################
##
#F  MultMatrixPadicNumbersByCoefficientsList( <list> )
##
##  MultMatrix...List  takes  the coeff.-list  <list>   of  a polynomial  and
##  returns  a (n  x   2*n-1)-matrix if n  is the   degree of  the polynomial
##  i.e. the length of <list> minus 1.  If you have an extension L of a field
##  K by a given polynomial f (i.e. L = K[X]/(f(X))) with coeff.-list <list>,
##  than the i-th row of the returned matrix gives the coeff.-presentation of
##  X^(i-1) in the basis {X^0, ..., X^n-1} of L.
##
##  For example:
##    Mult...List( [-1,5,-2,1] ) -> [1      ]
##      so the polynomial is        [   1   ]
##      X^3-2X^2+5X-1               [      1]
##                                  [1 -5  2]
##                                  [2 -9 -1]
##
##  So multiplying two elements of L (polynomials in X) is simply multiplying
##  the  polynomials and then multiplying the  resulting coeff.-list with the
##  matrix and get the  coeff.-presentation of the result  in the right basis
##  of L.
##
BindGlobal( "MultMatrixPadicNumbersByCoefficientsList", function ( list )
    local   n,  F,  zero,  one,  mat,  i,  j;

    n := Length(list) - 1;
    F := FamilyObj(list[1]);
    zero := Zero(F);
    one  := One(F);
    if n <= 1 then
        return [[one]];
    fi;
    # prepare a zero-matrix with ones on the main diagonal:
    mat := [  ];
    for i in [1..2*n-1] do
        mat[i] := [ ];
        for j in [1..n] do
            mat[i][j] := zero;
        od;
    od;
    for i in [1..n] do
        mat[i][i] := one;
    od;
    # the n+1-th row is simple:
    for j in [1..n] do
        mat[n+1][j] := - list[j];
    od;
    # the rest is a little more complex. Regard the fact, that
    # x^i is x*x^(i-1) and the coeff.presentation of x^(i-1) is
    # already known.
    for i in [n+2..2*n-1] do
        mat[i] := ShiftedCoeffs(mat[i-1],1) + mat[i-1][n] * mat[n+1];
    od;
    return mat;
end );


#############################################################################
##
#F  StructureConstantsPadicNumbers( <e>, <f> )
##
##  An  extended  p-adic field  is   given by  two polynomials.  One  for the
##  ramified  part g with  degree <e> and one for  the unramified part h with
##  degree <f>. The extended p-adic field is then the extension of Q_p i.e. L
##  = Q_p[x,y]/(g(y),h(x)).
##
##  L has a basis in x^i*y^j. This basis is ordered as follows:
##    {1, x, x^2, ..., y, x y, x^2 y, ..., y^2, x y^2, x^2 y^2, ...}
##
##  Let B_i be  the i-th basiselement.   StructureConstantsPadicNumbers takes
##  the two degrees <e> and <f> and returns a (n x n)-matrix (n = <e> * <f>).
##  In this matrix stands  at  position (i,j) the  index  of the row  of  the
##  multiplication-matrix that gives the coeff.-presentation of B_i * B_j The
##  mult.-matrix   of  an   extended   p-adic  field    is   given  as    the
##  Kronecker-product of the mult.-matrices  of the two  polynomials returned
##  by        MultMatrixPadicNumbersByCoefficientsList.        (see        in
##  PadicExtensionNumberFamily)
##
##  So I get the structure-constants m_ijk if
##    B_i*B_j = SUM(k=1,...,n) m_ijk B_k
##  simply by M[ B[i,j], k].
##
##  M is the mult.-matrix and B is the matrix returned by this function.
##
BindGlobal( "StructureConstantsPadicNumbers", function( e, f )
    local   mat,  i,  j,  a1,  a2,  b1,  b2;

    # there are <e>*<f> basis-elements and according to the above ordering
    # B_i is simply x^((i-1) mod f)*y^((i-1) div f)
    mat := [];
    for i in [1..e*f] do
        mat[i] := [];
        for j in [1..e*f] do
            a1 := (i-1) mod f;
            a2 := (j-1) mod f;
            b1 := QuoInt(i-1, f);
            b2 := QuoInt(j-1, f);
            mat[i][j] := (a1+a2) + (b1+b2)*(2*f-1) + 1;
        od;
    od;
    return mat;
end );


#############################################################################
##
#M  ShiftedPadicNumber( <padic>, <shift> )
##
##  ShiftedPadicNumber  takes a p-adic number <padic>  and an integer <shift>
##  and returns the  p-adic number   c, that is   <padic> *  p^<shift>.   The
##  <shift> is just added to the p-part.
##
InstallMethod( ShiftedPadicNumber,
    true,
    [ IsPadicNumber, IsInt ],
    0,

function( x, shift )
    local   fam,  c;

    fam := FamilyObj(x);
    c := Immutable( [ x![1]+shift, x![2] ] );
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <padic> * <rat>
##
InstallMethod( \*,
     true,
     [ IsPadicNumber, IsRat ],
     0,

function( a, b )
    local   fam;

    fam := FamilyObj( a );
    return a * PadicNumber( fam, b );
end );


#############################################################################
##
#M  <rat> * <padic>
##
InstallMethod( \*,
     true,
     [ IsRat, IsPadicNumber ],
     0,

function( a, b )
    local   fam;

    fam := FamilyObj( b );
    return PadicNumber( fam, a ) * b;
end );


#############################################################################
##
#M  <padic-list> * <rat>
##
InstallMethod( \*,
     true,
     [ IsPadicNumberList, IsRat ],
     0,

function( a, b )
    b := PadicNumber( FamilyObj(a[1]), b );
    return List( a, x -> x * b );
end );


#############################################################################
##
#M  <rat> * <padic-list>
##
InstallMethod( \*,
     true,
     [ IsRat, IsPadicNumberList ],
     0,

function( a, b )
    a := PadicNumber( FamilyObj(b[1]), a );
    return List( b, x -> a * x );
end );


#############################################################################
##
#M  ZeroOp( <padic> )
##
InstallMethod( ZeroOp,
    "for a p-adic number",
    true,
    [ IsPadicNumber ],
    0,

function( padic )
    return Zero( FamilyObj( padic ) );
end );


#############################################################################
##
#M  OneOp( <padic> )
##
InstallMethod( OneOp,
    "for a p-adic number",
    true,
    [ IsPadicNumber ],
    0,

function( padic )
    return One( FamilyObj( padic ) );
end );


#############################################################################
##
#M  PurePadicNumberFamily( <p>, <precision> )
##
##  PurePadicNumberFamily returns the family of pure p-adic numbers over the
##  prime  <p> with  <precision>  "digits".  For the  representation  of pure
##  p-adic numbers see "PadicNumber" below.
##

BindGlobal("PADICS_FAMILIES", []);


InstallGlobalFunction( PurePadicNumberFamily, function( p, precision )
    local   str,  fam;

    if not IsPrimeInt( p ) then
        Error( "<p> must be a prime" );
    fi;
    if (not IsInt( precision )) or (precision < 0) then
        Error( "<precision> must be a positive integer" );
    fi;
    if not IsBound(PADICS_FAMILIES[p]) then
        PADICS_FAMILIES[p] := [];
    fi;
    if not IsBound(PADICS_FAMILIES[p][precision]) then
        str := "PurePadicNumberFamily(";
        Append( str, String(p) );
        Append( str, "," );
        Append( str, String(precision) );
        Append( str, ")" );
        fam := NewFamily( str, IsPurePadicNumber );
        fam!.prime:= p;
        fam!.precision:= precision;
        fam!.modulus:= p^precision;
        fam!.printPadicSeries:= true;
        fam!.defaultType := NewType( fam, IsPurePadicNumber and IsPositionalObjectRep );
        PADICS_FAMILIES[p][precision] := fam;
    fi;
    return PADICS_FAMILIES[p][precision];
end );


#############################################################################
##
#M  PadicNumber( <pure-padic-family>, <list> )
##
##  Make  a pure  p-adic number  out of  a list.    A pure  p-adic  number is
##  represented as a list of  length 2 such  that the  number is p^list[1]  *
##  list[2].  It is easily guaranteed that  list[2] is never divisible by the
##  prime p.  By that we have always maximum precision.
##
InstallMethod( PadicNumber, "for a pure p-adic family and a list",
    true,
    [ IsPurePadicNumberFamily,
      IsCyclotomicCollection ],
    0,

function( fam, list )
    if Length(list) <> 2 then
        Error( "<list> must have length 2" );
    elif not IsInt(list[1]) then
        Error( "<list>[1] must be an integer" );
    elif not IsInt(list[2]) or list[2] < 0 or list[2] >= fam!.modulus then
        Error( "<list>[2] must be an integer in {0..p^precision}" );
    fi;
    return Objectify( fam!.defaultType, list );
end );


#############################################################################
##
#M  PadicNumber( <pure-padic-family>, <rat> )
##
##  Make a pure p-adic number out of a rational.
##
InstallMethod( PadicNumber, "for a pure p-adic family and a rational",
    true,
    [ IsPurePadicNumberFamily,
      IsRat ],
    0,

function( fam, rat )
    local   c;

    c := Immutable( PadicExpansionByRat( rat, fam!.prime, fam!.precision ) );
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  PrintObj( <pure-padic> )
##
InstallMethod( PrintObj,
    true,
    [ IsPurePadicNumber ],
    0,

function ( x )
    local   fam;

    fam := FamilyObj(x);
    # printPadicSeries is just a boolean variable. Handy for checking
    # what REALLY happens if set to false.
    if fam!.printPadicSeries then
        PrintPadicExpansion( x![1], x![2], fam!.prime, fam!.precision );
    else
        Print( fam!.prime, "^", x![1], "*", x![2], "(" , fam!.prime , ")" );
    fi;
end );


#############################################################################
##
#M  Random( <pure-padic-family> )
##
##  This is just  something that actually returns  a pure p-adic number.  The
##  range of the  p-part is not totally covered  as it is  infinity.  But you
##  may get two pure p-adic  numbers that have no  "digit"  in common, so  by
##  adding them, one of the two vanishes.
##
InstallOtherMethodWithRandomSource( Random, "for a random source and a pure p-adic family",
    true,
    [ IsRandomSource, IsPurePadicNumberFamily ],
    0,

function ( rg, fam )
    local c;

    c := [];
    c[1] := Random( rg, -fam!.precision, fam!.precision );
    c[2] := Random( rg, 0, fam!.modulus-1 );
    while c[2] mod fam!.prime = 0  do
        c[1] := c[1] + 1;
        c[2] := c[2] / fam!.prime;
    od;
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  Zero( <pure-padic-family> )
##
InstallOtherMethod( Zero,
    true,
    [ IsPurePadicNumberFamily ],
    0,

function ( fam )
    return PadicNumber( fam, [0,0] );
end );


#############################################################################
##
#M  IsZero( <pure-padic> )
##
InstallMethod( IsZero,
    true,
    [ IsPurePadicNumber ],
    0,

function ( x )
    return x![2] = 0;
end );


########################################################################
##
#M  One( <pure-padic-family> )
##
InstallOtherMethod( One,
    true,
    [ IsPurePadicNumberFamily ],
    0,

function ( fam )
    return PadicNumber( fam, [0,1] );
end );


#############################################################################
##
#M  Valuation( <pure-padic>
##
##  The Valuation is the p-part of the p-adic number.
##
InstallMethod( Valuation,
    true,
    [ IsPurePadicNumber ],
    0,

function( x )
    if IsZero(x) then
        return infinity;
    fi;
    return x![1];
end );


#############################################################################
##
#M  AdditiveInverseOp( <pure-padic> )
##
InstallMethod( AdditiveInverseOp,
     true,
     [ IsPurePadicNumber ],
     0,

function( a )
    local   fam,  c;

    fam := FamilyObj( a );
    c := [ a![1], -a![2] mod fam!.modulus];
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  InverseOp( <pure-padic> )
##
InstallMethod( InverseOp,
     true,
     [ IsPurePadicNumber ],
     0,

function( a )
    local   fam,  c;

    if IsZero(a)  then
        Error("division by zero");
    fi;
    fam:= FamilyObj( a );
    c:= [ -a![1] , 1/a![2] mod fam!.modulus ];
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <pure-padic> + <pure-padic>
##
InstallMethod( \+,
     IsIdenticalObj,
     [ IsPurePadicNumber, IsPurePadicNumber ],
     0,

function( a, b )
    local   fam,  c,  r;

    # if <a> or <b> is zero, return the other one
    if IsZero(a) then
        return b;
    fi;
    if IsZero(b) then
        return a;
    fi;
    fam:= FamilyObj( a );

    # different valuation: c[2] is NOT divisible by p!
    if a![1] < b![1] then
        c := [ a![1],
               (a![2]+fam!.prime^(b![1]-a![1])*b![2]) mod fam!.modulus ];

    # equal valuation: c[2] MAY BE divisible by p! So check that.
    elif a![1] = b![1] then
        c := [];
        c[1] := a![1];
        c[2] := (a![2] + b![2]) mod fam!.modulus;

        # c[2] might be divisible by p
        r := c[2] mod fam!.prime;
        while (r=0) and (c[2]>1) do
            c[1] := c[1] + 1;
            c[2] := c[2] / fam!.prime;
            r := c[2] mod fam!.prime;
        od;

    # different valuation: again c[2] is NOT divisible by p!
    else
        c:= [ b![1],
              (fam!.prime^(a![1]-b![1])*a![2]+b![2]) mod fam!.modulus ];
    fi;
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <pure-padic> * <pure-padic>
##
InstallMethod( \*,
     IsIdenticalObj,
     [ IsPurePadicNumber, IsPurePadicNumber ],
     0,

function( a, b )
    local   fam,  c;

    fam:= FamilyObj( a );
    if IsZero(a) then
        c:= [0, 0];
    elif IsZero(b) then
        c:= [0, 0];
    else
        c:= [ a![1]+b![1] , a![2]*b![2] mod fam!.modulus ];
    fi;
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <pure-padic> / <pure-padic>
##
InstallMethod( \/,
     IsIdenticalObj,
     [ IsPurePadicNumber, IsPurePadicNumber ],
     0,

function( a, b )
    local   fam,  c;

    if IsZero(b) then
        Error("division by zero");
    fi;
    fam:= FamilyObj( a );
    c:= [ a![1]-b![1] , a![2]/b![2] mod fam!.modulus ];
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <pure-padic> = <pure-padic>
##
InstallMethod( \=,
     IsIdenticalObj,
     [ IsPurePadicNumber, IsPurePadicNumber ],
     0,

function( a, b )
    return (a![1] = b![1]) and (a![2] = b![2]);
end );


#############################################################################
##
#M  <pure-padic> < <pure-padic>
##
##  This is just something to keep GAP quiet
##
InstallMethod( \<,
     IsIdenticalObj,
     [ IsPurePadicNumber, IsPurePadicNumber ],
     0,

function( a, b )
    if a![1] = b![1]  then
        return a![2] < b![2];
    else
        return a![1] < b![1];
    fi;
end );


#############################################################################
##
#M  PadicExtensionNumberFamily( <p>, <precision>, <unram>, <ram> )
##
##  An   extended p-adic field  L  is given by two   polynomials h and g with
##  coeff.-lists   <unram> (for  the  unramified  part)  and <ram>  (for  the
##  ramified part). Then L  is Q_p[x,y]/(h(x),g(y)).  This function takes the
##  prime number  <p> and the two coeff.-lists  <unram> and <ram> for the two
##  polynomials.  It   is  not checked  BUT <unram>   should be  a cyclotomic
##  polynomial and <ram> should be  an Eisenstein-polynomial or [1,1].  Every
##  number  out   of  L is  represented   as   a coeff.-list   for  the basis
##  {1,x,x^2,...,y,xy,x^2y,...} of L.   <precision> is the number of "digits"
##  that all the coeff. have.
##
InstallGlobalFunction( PadicExtensionNumberFamily,
    function( p, precision, unram, ram )
    local   str,  fam,  yem1;

    if not IsPrimeInt( p ) then
        Error( "<p> must be a prime" );
    fi;
    if (not IsInt( precision )) or (precision < 0) then
        Error( "<precision> must be a positive integer" );
    fi;
    str := "PadicExtensionNumberFamily(";
    Append( str, String(p) );
    Append( str, "," );
    Append( str, String(precision) );
    Append( str, ",...)" );
    fam := NewFamily( str, IsPadicExtensionNumber );
    fam!.defaultType := NewType( fam, IsPadicExtensionNumber and IsPositionalObjectRep );
    fam!.prime       := p;
    fam!.precision   := precision;
    fam!.modulus     := p^precision;
    fam!.unramified  := unram;
    fam!.f           := Length(unram)-1;
    fam!.ramified    := ram;
    fam!.e           := Length(ram)-1;
    fam!.n           := fam!.e * fam!.f;
    fam!.M           := KroneckerProduct(
                         MultMatrixPadicNumbersByCoefficientsList(ram),
                         MultMatrixPadicNumbersByCoefficientsList(unram) );
    fam!.B           := StructureConstantsPadicNumbers(fam!.e, fam!.f);

    yem1 := List( [1..fam!.n], i->0 );
    yem1[ (fam!.e-1) * fam!.f + 1 ] := 1;
    fam!.yem1 := Objectify( fam!.defaultType, [0, yem1] );

    fam!.printPadicSeries := true;

    return fam;
end );


#############################################################################
##
##  General  comment:    In  PadicExtensionNumberFamily  you  give   the two
##  polynomials,  that define  the  extension of  Q_p.  You have  to care for
##  yourself, that these polynomials  are  really irreducible over Q_p!   Try
##  PadicExtensionNumberFamily(3, 4, [1,1,1], [1,1]) for example.  You think
##  this is ok? It is not, because  x^2+x+1 is NOT  irreducible over Q_p. The
##  result being,  that you get non-invertible extended  p-adic numbers.  So,
##  if that happens, check your polynomials!
##


#############################################################################
##
#M  PadicNumber( <extended-padic-family>, <list> )
##
##  Make an extended p-adic number out of  a list.  An extended p-adic number
##  is represented as a list L of length 2.
##
##  L[2] is  the list of coeff. for  the  Basis {1,..,x^(f-1)*y^(e-1)} of the
##  extended p-adic field.
##
##  L[1] is a common p-part of all the coeff.
##
##  It is  NOT  guaranteed that all  or  at least one   of the coeff.  is not
##  divisible by the prime p.
##
##  For example: in PadicExtensionNumberFamily(3, 5, [1,1,1], [1,1])
##    the number (1.2000, 0.1210)(3) may be
##      [ 0, [ 1.2000, 0.1210 ] ]   or
##      [-1, [ 12.000, 1.2100 ] ]  here the coeff. have to be multiplied
##                                 by p^(-1)
##
##    so there may be a number (1.2, 2.2)(3) and you may ask: "Where are my 5
##    digits? There  are only two! Where  is the complain  department!"  But
##    the number is  intern: [-3, [ 0.0012, 0.0022  ] ]  and  so has in  fact
##    maximum precision.
##
##  So watch it!
##
InstallMethod( PadicNumber, "for a p-adic extension family and a list",
    true,
    [ IsPadicExtensionNumberFamily,
      IsList ],
    0,

function( fam, list )
    local   range;

    range := [ 0 .. fam!.modulus-1 ];
    if not IsInt(list[1]) then
        Error( "<list>[1] must be an integer" );
    elif not IsList(list[2]) or Length(list[2]) <> fam!.n  then
        Error( "<list>[2] must be a list of length ", fam!.n );
    elif not ForAll( list[2], x -> x in range )  then
        Error( "<list>[2] must be a list of integers in ", range );
    fi;
    return Objectify( fam!.defaultType, list );
end );


#############################################################################
##
#M  PadicNumber( <extended-padic-family>, <rat> )
##
##  Make an extended p-adic number  out of a rational.   That means take  the
##  result of PadicExpansionByRat  and put it at  the  first position of  the
##  coeff.list.
##
InstallMethod( PadicNumber, "for a p-adic extension family and a rational",
    true,
    [ IsPadicExtensionNumberFamily,
      IsRat ],
    0,

function( fam, rat )
    local   c,  erg;

    c := PadicExpansionByRat( rat, fam!.prime, fam!.precision );
    erg    := List( [1..fam!.n], i->0 );
    erg[1] := c[2];
    c      := [ c[1], erg ];
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  PrintObj( <extended-padic> )
##
InstallMethod( PrintObj,
    true,
    [ IsPadicExtensionNumber ],
    0,

function( x )
    local   fam,  l;

    fam := FamilyObj(x);
    if fam!.printPadicSeries then
        Print( "padic(" );
        for l in [1..fam!.n-1] do
            PrintPadicExpansion( x![1], x![2][l], fam!.prime, fam!.precision );
            Print( "," );
        od;
        PrintPadicExpansion( x![1], x![2][fam!.n], fam!.prime, fam!.precision );
        Print( ")" );
    else
        Print( "padic(", fam!.prime, "^", x![1], "*", x![2], ")" );
    fi;
end );


#############################################################################
##
#M  Random( <extended-padic-family>
##
##  Again this is just something that returns an extended p-adic number.  The
##  p-part is not totally covered (just ranges from -precision to precision).
##
InstallOtherMethodWithRandomSource( Random, "for a random source and p-adic extension family",
    true,
    [ IsRandomSource, IsPadicExtensionNumberFamily ],
    0,

function ( rg, fam )
    local   c,  l;

    c := [];
    c[1] := Random( rg, -fam!.precision, fam!.precision );
    c[2] := [];
    for l  in [ 1 .. fam!.n ] do
        c[2][l] := Random( rg, 0, fam!.modulus-1 );
    od;
    while ForAll( c[2], x-> x mod fam!.prime = 0 ) do
        c[1] := c[1] + 1;
        c[2] := c[2] / fam!.prime;
    od;
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  Zero( <extended-padic-family> )
##
InstallOtherMethod( Zero,
    true,
    [ IsPadicExtensionNumberFamily ],
    0,

function( fam )
    return Objectify( fam!.defaultType, [0, List( [1..fam!.n], i->0 )] );
end );


########################################################################
##
#M  IsZero( <extended-padic> )
##
InstallMethod( IsZero,
    true,
    [ IsPadicExtensionNumber ],
    0,

function ( x )
    if PositionNonZero( x![2] ) > Length( x![2] ) then
        return true;
    fi;
    return false;
end );


#############################################################################
##
#M  One( <extended-padic-family> )
##
InstallOtherMethod( One,
    true,
    [ IsPadicExtensionNumberFamily ],
    0,

function( fam )
    local   c;

    c := List( [ 1 .. fam!.n ], i -> 0 );
    c[1] := 1;
    return Objectify( fam!.defaultType, [0, c] );
end );


#############################################################################
##
#M  Valuation( <extended-padic>
##
##  In an  extended p-adic field the  prime p has  valuation e (the degree of
##  the totally ramified part) and y has valuation 1. y^e  is p so this makes
##  sense.
##
##  The valuation of a sum is (in this case) the minimum of the valuations of
##  the summands. As an extended p-adic number is
##
##    SUM(i=0..(f-1)) SUM(j=0..(e-1)) a_ij x^i y^j
##
##  the valuation nu of that number is the minimum over i and j of
##
##    nu(a_ij x^i y^j)
##
##  The valuation of a product is the sum of the single valuations, so
##
##    nu(a_ij x^i y^j) = nu(a_ij) + nu(x^i) + nu(y^j)
##                     = nu(a_ij) + j
##
InstallMethod( Valuation,
    true,
    [ IsPadicExtensionNumber ],
    0,

function ( x )
    local   fam,  min,  j,  wert;

    fam := FamilyObj(x);
    min := Minimum( List([1..fam!.f], i -> Valuation(x![2][i],fam!.prime)) );
    if min <> infinity then
        min := fam!.e * min;
    fi;
    for j in [1..fam!.e-1] do
        wert := Minimum( List( [1..fam!.f], i ->
                    Valuation(x![2][i+j*fam!.f], fam!.prime) ) );
        if wert <> infinity then
            wert := fam!.e * wert + j;
        fi;
        if wert < min then
            min := wert;
        fi;
    od;
    if min <> infinity then
        min := min + x![1] * fam!.e;
    fi;
    return min;
end );


#############################################################################
##
#M  AdditiveInverseOp( <extended-padic> )
##
InstallMethod( AdditiveInverseOp,
     true,
     [ IsPadicExtensionNumber ],
     0,

function( a )
    local   fam,  c;

    fam := FamilyObj( a );
    c := [ a![1], List( a![2], x -> (-x) mod fam!.modulus ) ];
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  InverseOp( <extended-padic> )
##
InstallMethod( InverseOp,
    true,
    [ IsPadicExtensionNumber ],
    0,

function(x)
    local   fam,  val,  coeffppart,  coeffypart,  ppart,  z,  L,  k,  j,
            Lp,  E,  Beta,  ppot,  Beta_k,  c,  addppart;

    if IsZero(x)  then
        Error( "<x> must be non-zero" );
    fi;
    fam := FamilyObj(x);
    # need a copy of x later:
    z := Objectify( fam!.defaultType, [x![1], ShallowCopy(x![2])] );

    # if x = [ppart, [x_1,...,x_n]] then
    # Valuation(x) = ppart*fam!.e + coeffppart*fam!.e + coeffypart
    val := Valuation(x);
    if fam!.e > 1 then
        coeffypart := val mod fam!.e;
    else
        coeffypart := 0;
    fi;
    ppart := x![1];
    coeffppart := (val - ppart*fam!.e - coeffypart) / fam!.e;
    # so x = p^(ppart + coeffppart) * y^coeffypart * z
    # and z is divisible neither by y nor by p, so it has Valuation 0
    # and can be inverted.
    # We don't have y^(-1) but y^(e-1) which is p*y^(-1)
    # so z = x * y^(e-1)^coeffypart * p^(-ppart-coeffppart-coeffypart).
    # at least there is the coeffppart in z![2]:
    if coeffppart > 0 then
        z![1] := z![1] + coeffppart;
        z![2] := z![2] / fam!.prime^coeffppart;
    fi;
    addppart := 0;
    if coeffypart > 0 then
        z := z * fam!.yem1^coeffypart;
        # BUT by multiplying with y^(e-1) one may get additional p-parts
        # in the coeffs
        while ForAll( z![2], y -> y mod fam!.prime = 0 ) do
            addppart := addppart + 1;
            z![1] := z![1] + 1;
            z![2] := z![2] / fam!.prime;
        od;
    fi;
    # z![1] := z![1] - ppart - coeffppart - coeffypart - addppart;

    # NOW z![2] has an entry that is not divisible by p and L should be
    # invertible
    L := [];
    for k in [1..fam!.n] do
        L[k] := [];
        for j in [1..fam!.n] do
            L[k][j]:=Sum(List([1..fam!.n],
                             i -> z![2][i] * fam!.M[ fam!.B[i][j] ][ k ] ));
        od;
    od;

    Lp := InverseMatMod(L, fam!.prime);

    # E is the right side (1,0,...,0) and Beta is just (0,...,0)
    E := List([1..fam!.n], i->0);
    Beta := ShallowCopy(E);
    E[1] := 1;
    ppot := 1;

    # now solve L * Beta = E mod p:
    for k in [0..fam!.precision-1-coeffppart] do
        Beta_k := List( Lp * E, x -> x mod fam!.prime );
        Beta := Beta + Beta_k * ppot;
        E := (E - L * Beta_k) / fam!.prime;
        ppot := ppot * fam!.prime;
    od;
    c := [];
    c[1] := -z![1];
    c[2] := Beta;

    # as z^(-1) is now calculated, the formula above gives
    # x^(-1) = z^(-1) * y^(e-1)^m * p^(-ppart-coeffppart-coeffypart)
    c[1] := c[1] - coeffppart - addppart;
    c[2] := c[2] * fam!.prime^(coeffppart + addppart);
    c[2] := List( c[2], x -> x mod fam!.modulus );
    Objectify( fam!.defaultType, c );
    return ( c * fam!.yem1^coeffypart );
end );


#############################################################################
##
#M  <extended-padic> + <extended-padic>
##
InstallMethod( \+,
     IsIdenticalObj,
     [ IsPadicExtensionNumber,
       IsPadicExtensionNumber ],
     0,

function( x, y )
    local   fam,  ppot,  c;

    if IsZero(y) then
        return x;
    elif IsZero(x) then
        return y;
    fi;
    fam:= FamilyObj( x );
    ppot := Minimum( x![1], y![1] );
    c := [];
    c[1] := ppot;
    c[2] := fam!.prime^(x![1]-ppot)*x![2] + fam!.prime^(y![1]-ppot)*y![2];
    c[2] := List( c[2], x -> x mod fam!.modulus );
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <extended-padic> - <extended-padic>
##
InstallMethod( \-,
     IsIdenticalObj,
     [ IsPadicExtensionNumber,
       IsPadicExtensionNumber ],
     0,

function( x, y )
    local   fam,  ppot,  c;

    if IsZero(y) then
        return x;
    elif IsZero(x) then
        return y;
    fi;
    fam:= FamilyObj( x );
    ppot := Minimum( x![1], y![1] );
    c := [];
    c[1] := ppot;
    c[2] := fam!.prime^(x![1]-ppot)*x![2] - fam!.prime^(y![1]-ppot)*y![2];
    c[2] := List( c[2], x -> x mod fam!.modulus );
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <pure-padic> * <extended-padic>
##
InstallMethod( \*,
     true,
     [ IsPurePadicNumber,
       IsPadicExtensionNumber ],
     0,

function( a, x )
    local   Qpxy,  Qp,  c;

    Qpxy := FamilyObj(x);
    Qp   := FamilyObj(a);
    if Qpxy!.prime <> Qp!.prime then
        Error( "different primes" );
    fi;
    if Qpxy!.precision <> Qp!.precision  then
        Error( "different precision" );
    fi;
    c := [ a![1] + x![1] ];
    c[2] := List( a![2] * x![2], x -> x mod Qpxy!.modulus );
    return Objectify( Qpxy!.defaultType, c );
end );


#############################################################################
##
#M  <extended-padic> * <pure-padic>
##
InstallMethod( \*,
     true,
     [ IsPadicExtensionNumber,
       IsPurePadicNumber ],
     0,

function( x, a )
    local   Qpxy,  Qp,  c;

    Qpxy := FamilyObj(x);
    Qp   := FamilyObj(a);
    if Qpxy!.prime <> Qp!.prime then
        Error( "different primes" );
    fi;
    if Qpxy!.precision <> Qp!.precision  then
        Error( "different precision" );
    fi;
    c := [ a![1] + x![1] ];
    c[2] := List( x![2] * a![2], x -> x mod Qpxy!.modulus );
    return Objectify( Qpxy!.defaultType, c );
end );


#############################################################################
##
#M  <extended-padic> * <extended-padic>
##
InstallMethod( \*,
     IsIdenticalObj,
     [ IsPadicExtensionNumber,
       IsPadicExtensionNumber ],
     0,

function (a, b)
    local   fam,  vec,  addvec,  bj,  bi,  aj,  ai,  c;

    fam := FamilyObj( a );

    ## zwei Nullvektoren der Laenge (2f-1)(2e-1):
    vec := List( [1..(2*fam!.f-1)*(2*fam!.e-1)], i->0 );
    addvec := List( [1..(2*fam!.f-1)*(2*fam!.e-1)], i->0 );

    ## Koeff. von b eintragen
    for bj in [1..fam!.e] do
        for bi in [1..fam!.f] do
            vec[ (bj-1)*(2*fam!.f-1) + bi ] := b![2][ (bj-1)*fam!.f + bi ];
        od;
    od;

    ## Das eigentliche Multiplizieren:
    for aj in [1..fam!.e] do
        for ai in [1..fam!.f] do
            addvec := addvec + vec * a![2][ (aj-1)*fam!.f + ai ];
            vec := ShiftedCoeffs( vec, 1 );
        od;
        vec := ShiftedCoeffs( vec, fam!.f-1 );
    od;
    c := [ a![1] + b![1], List(addvec * fam!.M, x -> x mod fam!.modulus) ];
    return Objectify( fam!.defaultType, c );
end );


#############################################################################
##
#M  <extended-padic> = <extended-padic>
##
InstallMethod( \=,
     IsIdenticalObj,
     [ IsPadicExtensionNumber,
       IsPadicExtensionNumber ],
     0,

function( a, b )
    local   fam;

    if IsZero(a)  then
        return IsZero(b);
    elif IsZero(b)  then
        return false;
    fi;
    # A little work is needed, because p^1 * 10 is equal to one
    fam := FamilyObj(a);
    a := [ a![1], ShallowCopy(a![2]) ];
    b := [ b![1], ShallowCopy(b![2]) ];
    while ForAll( a[2], z -> z mod fam!.prime = 0 ) do
        a[2] := a[2] / fam!.prime;
        a[1] := a[1] + 1;
    od;
    while ForAll( b[2], z -> z mod fam!.prime = 0 ) do
        b[2] := b[2] / fam!.prime;
        b[1] := b[1] + 1;
    od;
    return (a[1] = b[1]) and (a[2] = b[2]);
end );


#############################################################################
##
#M  <extended-padic> < <extended-padic>
##
##  Again just something to have it.
##
InstallMethod( \<,
     IsIdenticalObj,
     [ IsPadicExtensionNumber,
       IsPadicExtensionNumber ],
     0,

function( a, b )
    local   fam;

    if IsZero(a)  then
        return not IsZero(b);
    elif IsZero(b)  then
        return false;
    fi;
    fam := FamilyObj(a);
    a := [ a![1], ShallowCopy(a![2]) ];
    b := [ b![1], ShallowCopy(b![2]) ];
    while ForAll( a[2], z -> z mod fam!.prime = 0 ) do
        a[2] := a[2] / fam!.prime;
        a[1] := a[1] + 1;
    od;
    while ForAll( b[2], z -> z mod fam!.prime = 0 ) do
        b[2] := b[2] / fam!.prime;
        b[1] := b[1] + 1;
    od;
    if a[1] = b[1]  then
        return a[2] < b[2];
    else
        return a[1] < b[1];
    fi;
end );
