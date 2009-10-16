#############################################################################
##
#F  PPDPartPDM1( <d>, <p> ) . . . . . . . . compute the ppd part in <p>^<d>-1
##
InstallGlobalFunction(PPDPartPDM1B,function( d, p )
    local   n,  q,  i,  m,  x,  y;

    # compute the (repeated) gcd with p^d-1
    n := p^d - 1;
    x := 1;
    q := 1;
    for i  in [ 1 .. d-1 ]  do
        q := q * p;
        if d mod i = 0  then
            repeat
                m := GcdInt( n, q-1 );
                n := n / m;
                x := x * m;
            until m = 1;
        fi;
    od;

    # compute the possible gcd with <d>+1
    y := 1;
    if IsPrimeInt(d+1) and (n mod (d+1)) = 0 and (n mod (d+1)^2) <> 0  then
        y := d+1;
        n := n / (d+1);
    fi;

    # and return
    return rec( ppd := y,  lppd := n,  quo := x );

end);


#############################################################################
##
#F  PPDIrreducibleFactor( <R>, <f>, <d>, <q> )  . . . .  large factors of <f>
##
InstallGlobalFunction(PPDIrreducibleFactor,function ( R, f, d, q )
    local  px,  pow,  i,  cyc,  gcd,  a;

    # handle trivial case
    if Degree(f) <= 2  then
        return false;
    fi;

    # compute the deriviative
    a := Derivative( f );

    # if the derivative is nonzero then $f / Gcd(f,a)$ is squarefree
    if not IsZero(a)  then

        # compute the gcd of <f> and the derivative <a>
        f := Quotient( R, f, Gcd( R, f, a ) );

        # $deg(f) <= d/2$ implies that there is no large factor
        if Degree(f) <= d/2  then
            return false;
        fi;

        # remove small irreducible factors
        px  := X(LeftActingDomain(R));
        pow := PowerMod( px, q, f );
        for i  in [ 1 .. QuoInt(d,2) ]  do

            # next cyclotomic polynomial x^(q^i)-x
            cyc := pow - px;

            # compute the gcd of <f> and <cyc>
            gcd := Gcd(f, cyc );
            if 0 < Degree(gcd)  then
                f := Quotient( f, gcd );
                if Degree(f) <= d/2  then
                    return false;
                fi;
            fi;

            # replace <pow> by x^(q^(i+1))
            pow := PowerMod( pow, q, f );
        od;
        return StandardAssociate( R, f );

    # otherwise <f> is the <p>-th power of another polynomial <r>
    else
        return false;
    fi;

end);


#############################################################################
##
#F  IsPpdElement( <F>, <m>, <d>, <p>, <a> )
##
InstallGlobalFunction(IsPpdElement,function( F, m, d, p, a )
    local   c,  R,  pm,  g;

    # compute the characteristic polynomial
    if IsMatrix(m)  then
      c := CharacteristicPolynomial( m );
    else
      c := m;
    fi;

    # try to find a large factor
    R := PolynomialRing(F);
    c := PPDIrreducibleFactor( R, c, d, p^a );

    # return if we failed to find one
    if c = false  then
        return false;
    fi;

    # find the ppd and lppd parts
    pm := PPDPartPDM1B( Degree(c)*a, p );

    # get rid of the non-ppd part
    g := PowerMod( Indeterminate(F), pm.quo, c );

    # if it is one there is no ppd involved
    if IsOne(g)  then
        return false;
    fi;

    # check if there is a non-large ppd involved
    if 1 < pm.ppd  then
        g := PowerMod( g, pm.ppd, c );
        if IsOne(g)  then
	  return [ Degree(c), false ];
        else
	  return [ Degree(c), true ];
        fi;
    elif 1 < pm.lppd  then
      return [ Degree(c), true ];
    else
      Error( "should not happen" );
    fi;

end);

