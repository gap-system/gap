#############################################################################
##
#W  polyfinf.gi                 GAP Library                      Frank Celler
#W                                                         & Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions for polynomials over finite fields
##
Revision.polyfinf_gi :=
    "@(#)$Id$";


#############################################################################
##

#F  FactorsCommonDegreePol( <R>, <f>, <d> ) . . . . . . . . . . . . . factors
##
##  <f> must be a  square free product of  irreducible factors of  degree <d>
##  and leading coefficient 1.  <R>  must be a polynomial  ring over a finite
##  field of size p^k.
##
FactorsCommonDegreePol := function( R, f, d )
    local   c,  ind,  br,  g,  h,  k,  i;

    c   := CoefficientsOfUnivariateLaurentPolynomial(f);
    ind := IndeterminateNumberOfUnivariateLaurentPolynomial(f);
    br  := CoefficientsRing(R);

    # if <f> has a trivial constant term signal an error
    if c[2] <> 0  then
        Error("<f> must have a non-trivial constant term");
    fi;

    # if <f> has degree 0, return f
    if DegreeOfUnivariateLaurentPolynomial(f)=0  then
        return [];

    # if <f> has degree <d>, return irreducible <f>
    elif Length(c[1])-1=d  then
        return [f];
    fi;

    # choose a random polynomial <g> of degree less than 2*<d>
    repeat
      g := RandomPol(br,2*d-1);
    until DOULP(g)<>infinity;

    # if p = 2 take <g> + <g>^2 + <g>^(2^2) + ... + <g>^(2^(k*<d>-1))
    if Characteristic(br) = 2  then
        g := CoefficientsOfUnivariateLaurentPolynomial(g);
        h := ShiftedCoeffs(g[1],g[2]);
        k := ShiftedCoeffs(c[1],c[2]);
        g := g[1];
        for i  in [1..DegreeOverPrimeField(br)*d-1]  do
            g := ProductCoeffs(g,g);
            ReduceCoeffs(g,k);
            ShrinkCoeffs(g);
            AddCoeffs(h,g);
        od;
        h := UnivariateLaurentPolynomialByCoefficients(
                 FamilyObj(h[1]), h, 0, ind );

    # if p > 2 take <g> ^ ((p ^ (k*<d>) - 1) / 2) - 1
    else
        h := PowerMod( R, g,
               (Characteristic(br)^(DegreeOverPrimeField(br)*d)-1)/2, f )
             - One(br);
    fi;

    # gcd of <f> and <h> is with probability > 1/2 a proper factor
    g := Gcd(R,f,h);
    return Concatenation(
        FactorsCommonDegreePol( R, Quotient(R,f,g), d ),
        FactorsCommonDegreePol( R, g, d ) );
end;


#############################################################################
##
#F  RootsRepresentative( <R>, <f>, <n> )  . . . .  . . . . . . . . . . a root
##
RootsRepresentative := function( R, f, n )
    local   r,  br,  nu,  ind,  p,  d,  z,  v,  o,  i,  e;

    r   := [];
    br  := CoefficientsRing(R);
    nu  := Zero(br);
    ind := IndeterminateNumberOfUnivariateLaurentPolynomial(f);

    p := Characteristic(br);
    d := DegreeOverPrimeField(br);
    z := GeneratorsOfField(br)[1];
    f := CoefficientsOfUnivariateLaurentPolynomial(f);
    v := f[2];
    f := f[1];
    o := p^d-1;
    for i  in [0..(Length(f)-1)/n] do
        e := f[i*n+1];
        if e = nu then
            r[i+1] := nu;
        else
            r[i+1] := z ^ ((LogFFE(e,z) / n) mod o);
        fi;
    od;
    return UnivariateLaurentPolynomialByCoefficients(
               FamilyObj(nu), r, v/n, ind );

end;

#############################################################################
##

#M  FactorsSquarefree( <R>, <f>, <opt> )  . . . . . . . . . . . . . . factors
##
##  <f> must be square free and must have  leading coefficient 1. <R> must be
##  a polynomial ring over a finite field of size q.
##
InstallOtherMethod( FactorsSquarefree,
    "univariate polynomial over finite field",
    true,
    [ IsFiniteFieldPolynomialRing,
      IsRationalFunction,
      IsRecord ],
    RankFilter(IsRationalFunction and IsUnivariatePolynomial)
    - RankFilter(IsRationalFunction),

function( R, f, opt )
    local   br,  ind,  c,  facs,  deg,  px,  pow,  cyc,  gcd;

    if not IsUnivariatePolynomial(f)  then
        TryNextMethod();
    fi;
    br  := CoefficientsRing(R);
    ind := IndeterminateNumberOfUnivariateLaurentPolynomial(f);
    c   := CoefficientsOfUnivariateLaurentPolynomial(f);

    # if <f> has a trivial constant term signal an error
    if c[2] <> 0  then
        Error("<f> must have a non-trivial constant term");
    fi;

    # <facs> will contain factorisation
    facs := [];

    # in the following <pow> = x ^ (q ^ (<deg>+1))
    deg := 0;
    px  := UnivariatePolynomialByCoefficients(
               FamilyObj(One(br)), [Zero(br),One(br)], ind );
    pow := PowerMod( R, px, Size(br), f );

    # while <f> could still have two irreducible factors
    while 2*(deg+1) <= DegreeOfUnivariateLaurentPolynomial(f)  do

        # next degree and next cyclotomic polynomial x^(q^(<deg>+1))-x
        deg := deg + 1;
        cyc := pow - px;
        pow := PowerMod(R,pow,Size(br),f);

        if not IsBound(opt.onlydegs) or deg in opt.onlydegs  then

            # compute the gcd of <f> and <cyc>
            gcd := Gcd( R, f, cyc );

            # split the gcd with 'FactorsCommonDegree'
            if 0 < DegreeOfUnivariateLaurentPolynomial(gcd)  then
                Append(facs,FactorsCommonDegreePol(R,gcd,deg));
                f := Quotient(R,f,gcd);
            fi;
        fi;
    od;

    # if neccessary add irreducible <f> to the list of factors
    if 0 < DegreeOfUnivariateLaurentPolynomial(f)  then
        Add(facs,f);
    fi;

    # return the factorisation
    return facs;

end );


#############################################################################
##
#M  Factors( <R>, <f> [,<opt>] )  . . . . . . . . . . . . . .  factors of <f>
##
FFPFactors := function (arg)
    local   R,  cr,  f,  opt,  irf,  i,  ind,  v,  l,  g,  k,  d,  
            facs,  h,  q,  char,  r,  fam;

    # parse the arguments
    R  := arg[1];
    cr := CoefficientsRing(R);
    f  := arg[2];
    if Length(arg) > 2  then
        opt := arg[3];
    else
        opt := rec();
    fi;

    # check if we already know a factorisation
    irf := IrrFacsPol(f);
    i   := PositionProperty(irf,i->i[1]=R);
    if i <> fail  then
        return irf[i][2];
    fi;

    # handle the trivial cases
    ind := IndeterminateNumberOfUnivariateLaurentPolynomial(f);
    v   := CoefficientsOfUnivariateLaurentPolynomial(f);
    fam := FamilyObj(v[1][1]);

    if DegreeOfUnivariateLaurentPolynomial(f) < 2  then
        Add( irf, [cr,[f]] );
        return [f];

    elif Length(v[1]) = 1  then
        l := List( [ 1 .. v[2] ],
                   x -> IndeterminateOfUnivariateLaurentPolynomial(f) );
        l[1] := l[1]*v[1][1];
        Add( irf, [cr,l] );
        return l;
    fi;

    # make the polynomial normed,remember the leading coefficient for later
    g   := StandardAssociate(R,f);
    l   := Quotient(R,f,g);
    v   := CoefficientsOfUnivariateLaurentPolynomial(g);
    k   := UnivariatePolynomialByCoefficients( fam, v[1], ind );
    ind := IndeterminateOfUnivariateLaurentPolynomial(f);
    v   := v[2];

    # compute the derivative
    d := Derivative(k);

    # if the derivative is nonzero then $k / Gcd(k,d)$ is squarefree
    if d <> Zero(R)  then

        # compute the gcd of <k> and the derivative <d>
        g := Gcd( R, k, d );

        # factor the squarefree quotient and the remainder
        facs := FactorsSquarefree( R, Quotient(R,k,g), opt );
        for h in ShallowCopy(facs)  do
            if not IsBound(opt.onlydegs)  then
                StoreFactorsPol(cr,h,[h]);
            fi;
            q := Quotient( R, g, h );
            while q <> fail  do
                Add( facs, h );
                g := q;
                q := Quotient( R, g, h );
            od;
        od;
        if 0 < DegreeOfUnivariateLaurentPolynomial(g)  then
            Append( facs, Factors(R,g,opt) );
        fi;

    # otherwise <k> is the <p>-th power of another polynomial <r>
    else

        # compute the <p>-th root of <f>
        char := Characteristic(cr);
        r    := RootsRepresentative( R, k, char );

        # factor this polynomial
        h := Factors( R, r, opt );

        # each factor appears <p> times in <k>
        facs := [];
        for i  in [ 1 .. char ]  do
            Append( facs, h );
        od;

    fi;

    # Sort the factorization
    Append( facs, List( [ 1 .. v ], x -> ind ) );
    Sort(facs);

    # return the factorization and store it
    facs[1] := facs[1]*l;
    if not IsBound(opt.onlydegs)  then
        StoreFactorsPol(cr,f,facs);
    fi;
    return facs;

end;


InstallMethod( Factors,
    "polynomial over a finite field",
    true,
    [ IsFiniteFieldPolynomialRing,
      IsRationalFunction ],
    RankFilter(IsRationalFunction and IsUnivariatePolynomial)
    - RankFilter(IsRationalFunction),

function( R, f )
    if not IsUnivariatePolynomial(f)  then
        TryNextMethod();
    fi;
    return FFPFactors( R, f );
end );


InstallOtherMethod( Factors,
    "poylnomial over a finite field",
    true,
    [ IsFiniteFieldPolynomialRing,
      IsRationalFunction,
      IsRecord ],
    RankFilter(IsRationalFunction and IsUnivariatePolynomial)
    - RankFilter(IsRationalFunction),

function( R, f, opt )
    if not IsUnivariatePolynomial(f)  then
        TryNextMethod();
    fi;
    return FFPFactors( R, f, opt );
end );


#############################################################################
##

#F  ProductPP( <l>, <r> ) . . . . . . . . . . . . product of two prime powers
##
ProductPP := function( l, r )
    local   res, p1, p2, ps, p, i, n;

    if IsEmpty(l)  then
	return r;
    elif IsEmpty(r)  then
	return l;
    fi;
    res := [];
    p1  := l{ 2 * [ 1 .. Length( l ) / 2 ] - 1 };
    p2  := r{ 2 * [ 1 .. Length( r ) / 2 ] - 1 };
    ps  := Set( Union( p1, p2 ) );
    for p  in ps  do
    	n := 0;
	Add( res, p );
        i := Position( p1, p );
        if i <> fail   then
	    n := l[ 2*i ];
        fi;
        i := Position( p2, p );
        if i <> fail  then
	    n := n + r[ 2*i ];
        fi;
        Add( res, n );
    od;
    return res;

end;


#############################################################################
##
#F  LcmPP( <l>, <r> ) . . . . . . . . . . . . lcm of prime powers <l> and <r>
##
LcmPP := function( l, r )
    local   res, p1, p2, ps, p, i, n;

    if l = []  then
	return r;
    elif r = []  then
	return l;
    fi;
    res := [];
    p1  := l{ 2 * [ 1 .. Length( l ) / 2 ] - 1 };
    p2  := r{ 2 * [ 1 .. Length( r ) / 2 ] - 1 };
    ps  := Set( Union( p1, p2 ) );
    for p  in ps  do
    	n := 0;
	Add( res, p );
        i := Position( p1, p );
        if i <> false   then
	    n := l[ 2*i ];
        fi;
        i := Position( p2, p );
        if i <> false and n < r[ 2*i ]  then
	    n := r[ 2*i ];
        fi;
        Add( res, n );
    od;
    return res;

end;


#############################################################################
##
#F  OrderKnownDividendList( <l>, <pp> )	. . . . . . . . . . . . . . . . local
##
##  Computes  an  integer  n  such  that  OnSets( <l>, n ) contains  only one
##  element e.  <pp> must be a list of prime powers of an integer d such that
##  n divides d. The functions returns the integer n and the element e.
##
OrderKnownDividendList := function( l, pp )

    local   pp1,	# first half of <pp>
    	    pp2,        # second half of <pp>
    	    a,          # half exponent of first prime power
    	    k,          # power of <l>
    	    o,  o1,     # computed order of <k>
    	    i;          # loop

    # if <pp> contains no element return order 1
    if Length(pp) = 0  then
    	return [ 1, l[1] ];

    # if <l> contains only one element return order 1
    elif Length(l) = 1  then
    	return [ 1, l[1] ];

    # if the dividend is a prime return
    elif Length(pp) = 2 and pp[2] = 1  then
    	return [ pp[1], l[1]^pp[1] ];

    # if the dividend is a prime power divide and conquer
    elif Length(pp) = 2  then
    	pp := ShallowCopy(pp);
    	a  := QuoInt( pp[2], 2 );
    	k  := OnSets( l, pp[1]^a );

    	# if <k> is trivial try smaller dividend
    	if Length(k) = 1  then
    	    pp[2] := a;
    	    return OrderKnownDividendList( l, pp );

    	# otherwise try to find order of <h>
    	else
    	    pp[2] := pp[2] - a;
    	    o := OrderKnownDividendList( k, pp );
    	    return [ pp[1]^a*o[1], o[2] ];
    	fi;

    # split different primes into two parts
    else
    	a   := 2 * QuoInt( Length(pp), 4 );
    	pp1 := pp{[ 1 .. a ]};
    	pp2 := pp{[ a+1 .. Length(pp) ]};

    	# compute the order of <l>^<pp1>
    	k := l;
    	for i  in [ 1 .. Length(pp2)/2 ]  do
    	    k := OnSets( k, pp2[2*i-1]^pp2[2*i] );
    	od;
    	o1 := OrderKnownDividendList( k, pp1 );

    	# compute the order of <l>^<o1> and return
    	o := OrderKnownDividendList( OnSets( l, o1[1] ), pp2 );
    	return [ o1[1]*o[1], o[2] ];
    fi;

end;


#############################################################################
##
#F  FFPPowerModCheck( <R>, <g>, <pp>, <f> ) . . . . . . . . . . . . . . local
##
FFPPowerModCheck := function( R, g, pp, f )
    local   qq,  i;

    qq := [];
    for i  in [ 1 .. Length(pp)/2 ]  do
        Add( qq, pp[2*i-1] );
        Add( qq, pp[2*i] );
        g := PowerMod( R, g, pp[2*i-1] ^ pp[2*i], f );
        if DegreeOfUnivariateLaurentPolynomial(g) = 0  then
            return [ g, qq ];
        fi;
    od;
    return [ g, qq ];

end;


#############################################################################
##
#F  FFPOrderKnownDividend( <R>, <g>, <f>, <pp> )  . . . . . . . . . . . local
##
##  Computes an integer n such that <g>^n = const  mod <f> where <g>  and <f>
##  are polynomials in <R> and <pp> is list  of prime powers of  an integer d
##  such that n divides  d.   The  functions  returns  the integer n  and the
##  element const.
##
FFPOrderKnownDividend := function ( R, g, f, pp )
    local   old,  l,  a,  h,  n1,  pp1,  pp2,  k,  o,  q;

    Info( InfoPoly, 3, "FFPOrderKnownDividend started with:" );
    Info( InfoPoly, 3, "  <g>  = ", g );
    Info( InfoPoly, 3, "  <f>  = ", f );
    Info( InfoPoly, 3, "  <pp> = ", pp );

    # if <g> is constant return order 1
    if 0 = DegreeOfUnivariateLaurentPolynomial(g)  then
        Info( InfoPoly, 3, "  <g> is constant" );
        l := CoefficientsOfUnivariatePolynomial(g);
        l := [ 1, l[1] ];
        Info( InfoPoly, 3, "FFPOrderKnownDividend returns ", l );
    	return l;

    # if the dividend is a prime, we must compute g^pp[1] to get the constant
    elif Length(pp) = 2 and pp[2] = 1  then
    	k := PowerMod( g, pp[1], f );
        l := CoefficientsOfUnivariatePolynomial(k);
    	l := [ pp[1], l[1] ];
        Info( InfoPoly, 3, "FFPOrderKnownDividend returns ", l );
        return l;

    # if the dividend is a prime power find the necessary power
    elif Length(pp) = 2  then
        Info( InfoPoly, 3, "prime power, divide and conquer" );
        pp := ShallowCopy( pp );
        a  := QuoInt( pp[2], 2 );
	q  := pp[1] ^ a;
        h  := PowerMod( R, g, q, f );

	# if <h> is constant try again with smaller dividend
        if 0 = DegreeOfUnivariateLaurentPolynomial(h)  then
	    pp[2] := a;
	    o := FFPOrderKnownDividend( R, g, f, pp );
        else
	    pp[2] := pp[2] - a;
	    l := FFPOrderKnownDividend( R, h, f, pp );
	    o := [ q*l[1], l[2] ];
        fi;
        Info( InfoPoly, 3, "FFPOrderKnownDividend returns ", o );
	return o;

    # split different primes.
    else

    	# divide primes
        Info( InfoPoly, 3, "  ", Length(pp)/2, " different primes" );
        n1  := QuoInt( Length(pp), 4 );
        pp1 := pp{[ n1*2+1 .. Length(pp) ]};
        pp2 := pp{[ 1 .. n1*2 ]};
        Info( InfoPoly, 3, "    <pp1> = ", pp1 );
        Info( InfoPoly, 3, "    <pp2> = ", pp2 );

        # raise <g> to the power <pp2>
        k   := FFPPowerModCheck( R, g, pp2, f );
        pp2 := k[2];
        k   := k[1];

        # compute order for <pp1>
	o := FFPOrderKnownDividend( R, k, f, pp1 );

        # compute order for <pp2>
    	k := PowerMod( R, g, o[1], f );
	l := FFPOrderKnownDividend( R, k, f, pp2 );
    	o := [ o[1]*l[1], l[2] ];
        Info( InfoPoly, 3, "FFPOrderKnownDividend returns ", o );
        return o;
    fi;

end;


#############################################################################
##
#F  FFPUpperBoundOrder( <R>, <f> )  . . . . . . . . . . . . . . . . . . local
##
##  Computes the  irreducible factors f_i  of a polynomial  <f>  over a field
##  with  p^n  elements.  It returns a list  l of triples (f_i,a_i,pp_i) such
##  that the p-part  of x  mod  f_i is p^a_i and  the p'-part divides d_i for
##  which the prime powers pp_i are given.
##
FFPUpperBoundOrder := function( R, f )
    local   fs,  F,  L,  phi,  B,  i,  d,  pp,  a,  deg;

    # factorize <f> into irreducible factors
    fs := Collected( Factors( R, f ) );

    # get the field over which the polynomials are written
    F := CoefficientsRing(R);

    # <phi>(m) gives ( minpol of 1^(1/m) )( F.char )
    L := [ PrimePowersInt( Characteristic(F)-1 ) ];
    phi := function( m )
        local	x, d, pp, i;
        if not IsBound( L[m] )  then
	    x := Characteristic(F)^m-1;
            for d  in Difference( DivisorsInt( m ), [m] )  do
	        pp := phi( d );
                for i  in [ 1 .. Length(pp)/2 ]  do
	            x := x / pp[2*i-1]^pp[2*i];
                od;
            od;
            L[m] := PrimePowersInt( x );
        fi;
        return L[m];
    end;

    # compute a_i and pp_i
    B := [];
    for i  in [ 1 .. Length(fs) ]  do

    	# p-part is p^Roof(Log_p(e_i)) where e_i is the multiplicity of f_i
    	a := 0;
    	if fs[i][2] > 1  then
    	    a := 1+LogInt(fs[i][2]-1,Characteristic(F));
    	fi;

    	# p'-part: (p^n)^d_i-1/(p^n-1) where d_i is the degree of f_i
    	d   := DegreeOfUnivariateLaurentPolynomial(fs[i][1]);
	pp  := [];
        deg := DegreeOverPrimeField(F);
        for f  in DivisorsInt( d*deg )  do
    	    if deg mod f <> 0  then
	    	pp := ProductPP( phi(f), pp );
    	    fi;
        od;

	# add <a> and <pp> to <B>
    	Add( B, [fs[i][1],a,pp] );
    od;

    # OK, that's it
    return B;

end;


#############################################################################
##

#M  ProjectiveOrder( <f> )  . . . . . . . . . . . . . projective order of <f>
##
##  Return an  integer n  and a finite field element  const  such that x^n  =
##  const mod <f>.
##
InstallOtherMethod( ProjectiveOrder,
    "divide and conquer for univariate polynomials",
    true,
    [ IsRationalFunction ],
    RankFilter(IsRationalFunction and IsUnivariatePolynomial)
    - RankFilter(IsRationalFunction),

function( f )
    local   v,  R,  U,  x,  O,  n,  g,  q,  o;

    # <f> must be a univariate polynomial
    if not IsUnivariatePolynomial(f)  then
        TryNextMethod();
    fi;

    # <f> must not be divisible by x.
    v := CoefficientsOfUnivariateLaurentPolynomial(f);
    if 0 < v[2]  then
    	Error( "<f> must have a non zero constant term" );
    fi;

    # if degree is zero, return
    if 0 = DegreeOfUnivariateLaurentPolynomial(f)  then
    	return [ 1, v[1][1] ];
    fi;

    # use 'UpperBoundOrder' to split <f> into irreducibles
    R := DefaultRing(f);
    U := FFPUpperBoundOrder( R, f );

    # run through the irrducibles and compute their order
    x := IndeterminateOfUnivariateLaurentPolynomial(f);
    O := [];
    n := 1;
    for g  in U  do
    	o := FFPOrderKnownDividend(R,EuclideanRemainder(x,g[1]),g[1],g[3]);
    	q := Characteristic(CoefficientsRing(R))^g[2];
    	n := Lcm( n, o[1]*q );
	Add( O, [ o[1]*q, o[2]^q ] );
    od;

    # try to get the same constant in each block
    U := [];
    q := Size( CoefficientsRing(R) ) - 1;
    for g  in O  do
    	AddSet( U, g[2]^((n/g[1]) mod q) );
    od;

    # return the order <n> times the order of <U>
    o := OrderKnownDividendList( U, PrimePowersInt(q) );
    return [ n*o[1], o[2] ];

end );


#############################################################################
##

#E  polyfinf.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
