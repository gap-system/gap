#############################################################################
##
##  classical.gi        recog package                    Alice Niemeyer
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  The classical groups recognition.
##
##  $Id: classical.gi,v 1.9 2006/10/06 14:03:25 gap Exp $
##
#############################################################################

BindGlobal( "ClassicalMethDb", [] );

#############################################################################
##
#F  PPDPartPDM1( <d>, <p> ) . . . . . . . . compute the ppd part in <p>^<d>-1
##
PPDPartPDM1B := function( d, p )
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

end;


#############################################################################
##
#F  PPDIrreducibleFactor( <R>, <f>, <d>, <q> )  . . . .  large factors of <f>
##
PPDIrreducibleFactor := function ( R, f, d, q )
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

end;


#############################################################################
##
#F  IsPpdElement( <F>, <m>, <d>, <p>, <a> )
##
IsPpdElement := function( F, m, d, p, a )
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
    # pm.ppd is the prime
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

end;


#############################################################################
##
#F  PPDIrreducibleFactorD2(  <f>, <d>, <q> )  . . . .  d/2-factors of <f>
##
PPDIrreducibleFactorD2 := function ( f, d, q )

	local i;

	if d mod 2 <> 0 then 
            Print( "d must be divisible by 2\n" );
            return false; 
        fi;

	f := Factors( f );

        for i in [ 1 .. Length(f) ] do
            if Degree( f[i] ) = d/2 then
		return f[i];
            fi;
	od;

        return false;

end;

#############################################################################
##
#F  IsPpdElementD2( <F>, <m>, <d>, <p>, <a> )
##
IsPpdElementD2 := function( F, m, d, p, a )
    local   c,  R,  pm,  g;

    # compute the characteristic polynomial
    if IsMatrix(m)  then
        c := CharacteristicPolynomial( m );
    else
        c := m;
    fi;

    # try to find a large factor
    c := PPDIrreducibleFactorD2(  c, d, p^a );

    # return if we failed to find one
    if c = false  then
        return false;
    fi;

    # find the ppd and lppd parts
    pm := PPDPartPDM1B( Degree(c)*a, p );

    # get rid of the non-ppd part
    g := PowerMod( Indeterminate(F), pm.quo, c );

    # if it is one there is no ppd involved
    if g = g^0  then
        return false;
    fi;

    # check if there is a non-large ppd involved
    if 1 < pm.ppd  then
        g := PowerMod( g, pm.ppd, c );
        if g = g^0  then
            return [ Degree(c), false, pm.ppd ];
        else
            return [ Degree(c), true, pm.ppd ];
        fi;
    elif 1 < pm.lppd  then
        return [ Degree(c), true, pm.lppd ];
    else
        Error( "should not happen" );
    fi;

end;

###
## Test whether n is a power of the prime p
##
IsPowerOfPrime := function( n, p )

    local x;

    if n <= 0 then return false; fi;

    repeat
        x := QuotientRemainder( n, p );
        if x[2] <> 0 then return false; fi;
        n := x[1];
    until n = 1;

    return true;

end;

KroneckerFactors := function(g)

    local a, b, c, d, A, B, C, D, I;

    A := g{[1,2]}{[1,2]};
    B := g{[1,2]}{[3,4]};
    C := g{[3,4]}{[1,2]};
    D := g{[3,4]}{[3,4]};
    if IsZero(Determinant(A)) then
        return false;
    fi;
    b := (B * A^-1); b := b[1][1];
    c := (C * A^-1); c := c[1][1];
    d := (D * A^-1); d := d[1][1];
    I := A^0;

    if B*A^-1 <> I*b or C*A^-1 <> I*c or D*A^-1 <> I*d then
        return false;
    fi;

    return [ [[I[1][1] , b],[ c, d]], A];
end;
           

######################################################################
##
#F  FindBase (d, q, phi) . . . . . . . . . . . find appropriate basis
##
##  The following function returns a matrix B such that B phi B^T has
##  the form ( 0, 0, 0, -1), ( 0, 0, 1, 0 ) (0, 1, 0, 0), (-1, 0, 0, 0)
##
FindBase := function( d, q, phi )

    local FindVec, V, v1, v2, v3, v4;

FindVec := function()

    local v;

    v := Random( V );
    while v * phi * v <> 0 * v[1]  or v = Zero(V) do
        v := Random( V );
    od;

    return v;
end;

    V := GF(q)^d;

#    if phi = [[ 0,0,0,-1],[ 0,0,1,0],[0,1,0,0],[-1,0,0,0]]*GF(q).one then
#        return IdentityMat(d, GF(q));
#    fi;
    
    Info( InfoClassical, 2, "finding v1\n");
    v1 := FindVec();
    Info( InfoClassical, 2, "finding v4\n");
    v4 := FindVec();
    while v1 * phi * v4 = 0 * v1[1] do
        v4 := FindVec();
    od;
    v4 := -v4/(v1*phi*v4);
    Info( InfoClassical, 2, "finding v2\n");
    v2 := FindVec();
    while v1 * phi * v2 <> 0 * v1[1] or 
          v4 * phi * v2 <> 0 * v1[1] do
        v2 := FindVec();
    od;
    Info( InfoClassical, 2, "finding v3\n");
    v3 := FindVec();
    while v1 * phi * v3 <> 0 * v1[1] or 
          v2 * phi * v3 = 0*v1[1] or
          v4 * phi * v3 <> 0 * v1[1] do
        v3 := FindVec();
    od;
    v3 := v3/(v2*phi*v3);

    return [v1, v2, v3, v4];

end;



FindBaseC2 := function( d, q, qf )

    local FindVec, V, v1, v2, v3, v4;

FindVec := function()

    local v;

    v := Random( V );
    while v * qf * v <> 0 * v[1]  or v = Zero(V) do
        v := Random( V );
    od;

    return v;
end;

    V := GF(q)^d;

#    if phi = [[ 0,0,0,-1],[ 0,0,1,0],[0,1,0,0],[-1,0,0,0]]*GF(q).one then
#        return IdentityMat(d, GF(q));
#    fi;
    
    Info( InfoClassical, 2, "finding v1\n");
    v1 := FindVec();
    v3 := FindVec();
    while (v1+v3) * qf * (v1+v3) = 0 * v1[1] do
        v3 := FindVec();
    od;
    v3 := v3/((v1+v3)*qf*(v1+v3));
    
    v2 := FindVec();
    while (v1+v2) * qf * (v1+v2) <> 0 * v1[1] or
          (v2+v3) * qf * (v2+v3) <> 0 * v1[1] do
        v2 := FindVec();
    od;
    
    Info( InfoClassical, 2, "finding v4\n");
    v4 := FindVec();
    while (v1+v4) * qf * (v1+v4) <> 0 * v1[1] or
          (v2+v4) * qf * (v2+v4) = 0 * v1[1] or
          (v3+v4) * qf * (v3+v4) <> 0 * v1[1] do
        v4 := FindVec();
    od;
    v4 := v4/((v2+v4)*qf*(v2+v4));

    return [v1, v2, v4, v3];

end;

###################################
### The ppd stuff up there should go in the package
####################################


# Test to check whether the group contains both a large ppd element
# and a basic ppd element 
# TODO: Better comments... 
RECOG.IsGenericParameters := function( recognise, grp )
    
    local fact, d, q, hint;
    
    hint := recognise.hint;

    d := recognise.d;
    q := recognise.q;

    if hint = "unknown"  then 
        return false;
    
    elif hint = "linear" and d <= 2 then
        recognise.isGeneric := false;
        return false;
        
    elif hint = "linear" and d = 3 then
        #q = 2^s-1
        if IsPowerOfPrime( q+1, 2 ) then 
            recognise.isGeneric := false;
        fi;
        return false;
        
    elif hint = "symplectic" and 
      (d < 6 or (d mod 2 <> 0) or
       [d,q] in [[6,2],[6,3],[8,2]]) then
        recognise.isGeneric := false;
        return false;
        
    elif hint = "unitary" and
      (d < 5 or d = 6 or [d,q] = [5,4]) then
        recognise.isGeneric := false;
        return false;
        
    elif hint = "orthogonalplus" and 
      (d mod 2 <> 0 or d < 10
       or (d = 10 and q = 2)) then
        recognise.isGeneric := false;
        return false;
        
    elif hint = "orthogonalminus" and
      (d mod 2 <> 0 or d < 6 
       or [d,q] in [[6,2],[6,3],[8,2]]) then
        recognise.isGeneric := false;
        return false;
        
    elif hint = "orthogonalcircle" then
        if d < 7 or [d,q] = [7,3] then
            recognise.isGeneric := false;
            return false;
        fi;
        if d mod 2 = 0 then
            recognise.isGeneric := false;
            return false;
        fi;
        if q mod 2 = 0 then
            #TODO: INFORECOG1 ... not irreducible
            #TODO: INFORECOG2 ... d odd --> q odd
            recognise.isReducible := true;
            recognise.isGeneric := false;
            return false;
        fi;
    fi;
    
    return false;
end;


# Generate elements until we find the required ppd type
# elements...monte  yes 
# TODO: Better comments

RECOG.IsGeneric := function (recognise, grp)

    if recognise.isGeneric = false then
        return false;
    fi;
    
    if Length(recognise.E) < 2 then return fail; fi;
    if Length(recognise.LE) < 1 then return fail; fi;
    if Length(recognise.BE) < 1 then return fail; fi;

    recognise.isGeneric := true;
    
    return false;
end;

#enough info to rule out extension field groups...?
#TODO: comments...
RECOG.RuledOutExtField := function (recognise, grp)
    
    local differmodfour, d, q, E, b, bx, hint;
    
    hint := recognise.hint;
    d := recognise.d;
    q := recognise.q;
    E := recognise.E;
    
    differmodfour := function(E)
        local e;
        for e in E do
            if E[1] mod 4 <> e mod 4 then
                return true;
            fi;
        od;
        return false;
    end;
    
    b := recognise.currentgcd;
    
    if hint in ["linear","unitary","orthogonalcircle"] then
        bx := 1;
    else
        bx := 2;
    fi;
    

    if b < bx then 
        if hint <> "unknown" then
           recognise.hintIsWrong := true;
           # raeume auf + komme nie wieder
           return true;
        fi;
        recognise.isNotExt := true; 
        return false; 
    fi;
    if b > bx then return fail; fi;

    if hint = "linear" then
        if not IsPrime(d)
           or E <> [d-1,d]
           or d-1 in recognise.LE then
            recognise.isNotExt  := true;
            return false;
        fi;
        
    elif hint = "unitary" then
        recognise.isNotExt  := true;
        return false;
        
    elif hint = "symplectic" then
        if d mod 4 = 2 and q mod 2 = 1 then
             recognise.isNotExt := 
            (PositionProperty(E, x -> (x mod 4 = 0)) <> fail);
        elif  d mod 4 = 0 and q mod 2 = 0 then
             recognise.isNotExt := 
             (PositionProperty( E, x -> (x mod 4 = 2)) <> fail);
        elif d mod 4 = 0 and q mod 2 = 1 then
             recognise.isNotExt := differmodfour(E);
        elif d mod 4 = 2 and q mod 2 = 0 then
            recognise.isNotExt :=  (Length(E) > 0);
        else
           Info( InfoClassical, 2, "d cannot be odd in hint Sp");
           recognise.hintIsWrong := true;
           # raeume auf + komme nie wieder
           return true;
        fi;
        
    elif hint = "orthogonalplus" then
        if d mod 4 = 2  then
            recognise.isNotExt  := 
           (PositionProperty (E, x -> (x mod 4 = 0 )) <> fail);
        elif d mod 4 = 0  then
            recognise.isNotExt  := differmodfour(E);
        else  
           Info( InfoClassical, 2, "d cannot be odd in hint O+");
           recognise.hintIsWrong := true;
           # raeume auf + komme nie wieder
           return true;
        fi;

     
    elif hint = "orthogonalminus" then
        if d mod 4 = 0  then
            recognise.isNotExt  := 
            (PositionProperty ( E, x -> (x mod 4 = 2)) <> fail);
        elif d mod 4 = 2  then
            recognise.isNotExt  := differmodfour(E);
        else 
           Info( InfoClassical, 2, "d cannot be odd in hint O-");
           recognise.hintIsWrong := true;
           # raeume auf + komme nie wieder
           return true;
        fi;
    
    elif hint = "orthogonalcircle" then
        recognise.isNotExt  := true;
        return false;
    fi;
    
    if recognise.isNotExt = true then return false; 
    else return fail;
    fi;
end;

RECOG.IsNotAlternating := function( recognise, grp )

    local V, P, i, g ,q, o;

    q := recognise.q;
    
#   if recognise.hint <> "unknown" and recognise.hint <> "linear" then
#       Info( InfoClassical, 2, "G' not an AlternatingGroup;"); 
#       recognise.isNotAlternating := true;
#       return false;
#   fi;

    if Length(recognise.ClassicalForms) > 0 and not "linear" in 
        recognise.ClassicalForms then 
       recognise.isNotAlternating := true;
       return false;
    fi;

    if recognise.d <> 4 or q <> recognise.p or (3 <= q and q < 23) then
       Info( InfoClassical, 2, "G is not an alternating group" );
       recognise.isNotAlternating := true;
       return false;
    fi;

    if q = 2 then
       if Size(grp) <> 3*4*5*6*7 then
           Info( InfoClassical, 2, "G is not an alternating group" );
           recognise.isNotAlternating := true;
           return false;
       else 
           Info( InfoClassical, 2, "G' might be A7;");
           AddSet(recognise.possibleNearlySimple,"A7");
           return true;
       fi;
    fi;

    
    if q >= 23 then
        # TODO Check Magma Code
       o := Order( recognise.g );
       if o mod 25 = 0 then
           Info( InfoClassical, 2, "G' not alternating;");
           recognise.isNotAlternating := true;
           return false;
       fi;
       o := Collected( Factors (o) );
       for i in o do
           if i[1] >= 11 then
               Info( InfoClassical, 2, "G' not alternating;");
               recognise.isNotAlternating := true;
               return false;
           fi;
       od;
  
       if recognise.n > 15 then     
           AddSet (recognise.possibleNearlySimple, "2.A7");
           Info( InfoClassical, 2, "G' might be 2.A7;");
           return  fail;
       fi;
   fi;

   return fail;
   
end;



RECOG.IsNotMathieu := function( recognise, grp )

   local i, fn, g, d, q, E, ord;

   d := recognise.d;
   q := recognise.q;
   E := recognise.E;
   g := recognise.g;

#   if recognise.hint <> "unknown" and recognise.hint <> "linear" then
#       Info( InfoClassical, 2, "G' not a Mathieu Group;");
#       recognise.isNotMathieu := true;
#       return false;
#   fi;

    if Length(recognise.ClassicalForms) > 0 and not "linear" in 
        recognise.ClassicalForms then 
       recognise.isNotMathieu := true;
       return false;
    fi;

   if not [d, q]  in [ [5, 3], [6,3], [11, 2] ] then
       Info( InfoClassical, 2, "G' is not a Mathieu group;\n");
       recognise.isNotMathieu := true;
       return false;
   fi;

   if d  in [5, 6] then
       ord := Order(g);
       if (ord mod 121=0 or (d=5 and ord=13) or (d=6 and ord=7)) then
          Info( InfoClassical, 2, "G' is not a Mathieu group;\n");
          recognise.isNotMathieu := true; 
          return false;
       fi;
   else
       if ForAny([6,7,8,9],m-> m in E) then
          Info( InfoClassical, 2, "G' is not a Mathieu group;\n");
           recognise.isNotMathieu := true; 
           return false;
       fi;
   fi;

 
# TODO Check how big n should be
    if d = 5 then
        if recognise.n > 15 then
            AddSet(recognise.possibleNearlySimple, "M_11" );
            Info( InfoClassical, 2, "G' might be M_11;");
            return fail;
        fi;
    elif d = 6 then
        if recognise.n > 15 then
            AddSet(recognise.possibleNearlySimple, "2M_12" );
            Info( InfoClassical, 2, "G' might be 2M_12;");
            return fail;
        fi;
    else
        if recognise.n > 15 then
            AddSet(recognise.possibleNearlySimple, "M_23" );
            AddSet(recognise.possibleNearlySimple, "M_24" );
            Info( InfoClassical, 2, "G' might be M_23 or M_24;");
            return fail;
        fi;
    fi;
 
   return fail;

end;


RECOG.IsNotPSL := function (recognise, grp)

   local i, E, LE, d, p, a, q,  str, fn, ord;

    E := recognise.E;
    LE := recognise.LE;
    d := recognise.d;
    q := recognise.q;
    a := recognise.a;
    p := recognise.p;

#    if recognise.hint <> "unknown" and recognise.hint <> "linear" then
#        Info( InfoClassical, 2, "G' not PSL(2,r);");
#        recognise.isNotPSL := true;
#        return false;
#    fi;
    if Length(recognise.ClassicalForms) > 0 and not "linear" in 
        recognise.ClassicalForms  then 
       recognise.isNotPSL := true;
       return false;
    fi;

    if d = 3 and (q = 5 or q = 2) then
        Info( InfoClassical, 2,  "G' is not PSL(2,7)");
        recognise.isNotPSL := true;
        return false;
    fi;

    if d = 6 and q = 2 then
        Info( InfoClassical, 2,  "G' is not PSL(2,11)");
        recognise.isNotPSL := true;
        return false;
    fi;

    # test whether e_2 = e_1 + 1 and
    # e_1 + 1 and 2* e_2 + 1 are primes
    if  Length(E) >= 2 then
        if E[2]-1<>E[1] or 
            not IsPrimeInt(E[1]+1) or not IsPrimeInt(2*E[2]+1) then
            Info(InfoClassical, 2, " G' is not PSL(2,r)");
            recognise.isNotPSL := true;
            return false;
        fi;
    fi;
   
   if d = 3 then
       # q = 3*2^s-1 and q^2-1 has no large ppd.
       # TODO recheck this 
       if (q = 2 or ((q+1) mod 3 = 0 and IsPowerOfPrime((q+1)/3,2))) then
            ord := Order(recognise.g);
            if (ord mod 8 <> 0 or (p^(2*a)-1) mod ord = 0) then
                Info( InfoClassical, 2, "G' not PSL(2,7);");
                recognise.isNotPSL := true;
                return false;
           fi;
       else
           if p = 3 or p = 7 or 2 in LE then  
                Info( InfoClassical, 2, "G' not PSL(2,7);");
                recognise.isNotPSL := true;
                return false;
           fi;
       fi;
   elif [d, q]  = [5,3] then
       ord := Order(recognise.g);
       if (ord mod 11^2 = 0  or ord mod 20 = 0) then
           Info( InfoClassical, 2, "G' not PSL(2,11);");
           recognise.isNotPSL := true;
           return false;
       fi;
   elif d = 5  and p <> 5 and p <> 11 then
       if (3 in LE or 4 in LE) then
           Info( InfoClassical, 2, "G' not PSL(2,11);");
           recognise.isNotPSL := true;
           return false;
       fi;
   elif [d, q]  = [6, 3] then
       ord := Order(recognise.g);
       if (ord mod (11^2)=0 or 6 in E) then
           Info( InfoClassical, 2, "G' not PSL(2,11);");
           recognise.isNotPSL := true;
           return false;
       fi;
   elif d = 6 and p <> 5 and p <> 11 then
       if  (6 in E or 4 in LE) then
           Info( InfoClassical, 2, "G' not PSL(2,11);");
           recognise.isNotPSL := true;
           return false;
       fi;
   else
       Info( InfoClassical, 2, "G' not PSL(2,r);");
       recognise.isNotPSL := true;
       return false;
   fi;


   if recognise.n > 15  and Length(recognise.E) > 2 then
       str := Concatenation("PSL(2,",Int(2*E[2]+1));
       str := Concatenation(str, ")");
       Info( InfoClassical, 2, "G' might be ", str);
       AddSet( recognise.possibleNearlySimple, str );
       return fail;
   fi;
   return fail;
end;


# generate the next random element and its char polynomial
RECOG.TestRandomElement := function (recognise, grp)

    local g, ppd, bppd, d, q, cpol, f, deg, facs, r, s, h, gmod, str,
    ord, bc, phi, kf, o1, o2;

    recognise.g := PseudoRandom(grp);
    recognise.cpol := CharacteristicPolynomial(recognise.g); 
    recognise.n := recognise.n + 1;

    d := recognise.d;
    q := recognise.q;
    f := recognise.field;
    g := recognise.g;
    cpol := recognise.cpol;

    if recognise.needOrders then
        ord := Order(g);
        recognise.ord := ord;
        AddSet( recognise.orders, ord );
    fi;
    if recognise.needPOrders then
        ord := ProjectiveOrder(g);
        AddSet( recognise.porders, ord );
    fi;
        
    ppd := IsPpdElement (f, cpol, d, recognise.q, 1); 
    # if the element is no ppd we get out
    if ppd = false then 
        recognise.isppd := false;
    else    
        AddSet(recognise.E,ppd[1]);
        recognise.currentgcd := Gcd( recognise.currentgcd, ppd[1] );
        if ppd[2] = true then
            AddSet(recognise.LE,ppd[1]);
        fi;
        recognise.ppd := [ ppd[1], ppd[2], "unknown" ];
        if Length(recognise.BE) < 1 or recognise.needLB then
            #We only need one basic ppd-element
            #Also, each basic ppd element is a ppd-element
            bppd := IsPpdElement (f, cpol, d, recognise.p, recognise.a);
            if bppd <> false then
                AddSet(recognise.BE, bppd[1]);
                if ppd[2] = true and ppd[1] = bppd[1] then
                    AddSet( recognise.LB, ppd[1] );
                    recognise.ppd[3] := true;
                fi;
            fi;
        fi;
    fi;
    if recognise.needE2 = true then
        ppd := IsPpdElementD2(f, cpol, d, recognise.q, 1); 
        if ppd <> false then 
            AddSet( recognise.E2, ppd[1] );
            if ppd[2] = true then
        
            ## first we test whether the characteristic polynomial has
            ## two factors of degree d/2. 
            facs := Factors( cpol );
            deg := List(facs, EuclideanDegree );
            if Length(deg) = 2 and deg[1] = deg[2] and deg[1] = d/2 then

            ## Now we compute the r-part h of g
            r := ppd[3];
            s := Order(g);
            while s mod r = 0 do s := Int (s/r); od;
            str := "  Found a large and special ppd(";
            str := Concatenation(str, String(recognise.d));
            str := Concatenation(str, ", " );
            str := Concatenation(str, String(recognise.q));
            str := Concatenation(str, "; " );
            str := Concatenation(str, String(ppd[1]));
            str := Concatenation(str,  ")-element");
	    if s = 1 and Length(facs) = 2 then 
                Info(InfoClassical,2, str );
                AddSet(recognise.LS, ppd[1] );
            else
                h := g^s;
                gmod := GModuleByMats([h], recognise.field);
	        if Length(MTX.CollectedFactors(gmod ))  = 2 then
                    Info(InfoClassical,2, str );
                    AddSet(recognise.LS, ppd[1] );
                fi;
            fi;
            fi;
          fi;
        fi;
    fi;


    if PositionProperty(recognise.E, x->(x mod 2 <> 0)) <> fail then
        recognise.IsSpContained := false;
        recognise.IsSOContained := false;
    fi;
    if PositionProperty(recognise.E, x ->(x mod 2 = 0)) <> fail then
        recognise.IsSUContained := false;
    fi;

    if recognise.needBaseChange = true and recognise.bc = "unknown" then     
        if Length(recognise.ClassicalForms) = 0 then    
            recognise.needForms := true;
            return NotApplicable;
        fi;
        if "orthogonalplus" in recognise.ClassicalForms then
            phi := recognise.InvariantDualForm;
            if IsOddInt (q) then 
                Info(InfoClassical, 2,"Performing base change");
                bc := FindBase (d, q, phi);
                Info(InfoClassical, 2,"Computed base change matrix");
                bc := bc^-1;
                recognise.bc := bc;
            else 
                bc := FindBaseC2 (d, q, recognise.QuadraticForm);
                Info(InfoClassical,2,
                     "Computed base change matrix for char 2\n");
                bc := bc^-1;
                recognise.bc := bc;
            fi;
        else
            Info(InfoClassical, 2, "need basechange only in O+");
            return fail;
         fi;
     fi;

     if recognise.needKF  = true  then
            if recognise.bc = "unknown" then
                recognise.needBaseChange := true;
            else
                kf := KroneckerFactors( g^recognise.bc );
                if kf = false then 
                    kf := KroneckerFactors( (g^2)^recognise.bc );
                fi;
                recognise.kf  := kf;
            fi;
      fi;

      if recognise.needPlusMinus = true then
            if recognise.kf = "unknown" then  
                recognise.needKF := true;
                return fail;
            fi;
            if recognise.kf = false then  
                return fail;
            fi;
            kf := recognise.kf;
            o1 := Order( kf[1] );
            o2 := Order( kf[2] );
            Info(InfoClassical,2,o1, " ", o2, "\n");
            if ( (q+1) mod o1 = 0 and (q+1) mod o2 = 0) then 
                Add( recognise.plusminus, [1,1] );
            fi;
            if ( (q+1) mod o1 = 0 and (q-1) mod o2 = 0) then 
                Add( recognise.plusminus, [1,-1] );
            fi;
            if ( (q-1) mod o1 = 0 and (q+1) mod o2 = 0) then 
                Add( recognise.plusminus, [1,-1] );
            fi;
            if ( (q-1) mod o1 = 0 and (q-1) mod o2 = 0) then 
                Add( recognise.plusminus, [-1,-1] );
            fi;
        fi;

        if recognise.needDecompose = true then        
            if recognise.kf = "unknown" then  
                recognise.needKF := true;
                return fail;
            fi;
            if recognise.kf = false then  
                return fail;
            fi;
            kf := recognise.kf;     
                
            if not kf[1] in Group(recognise.sq1) then
                AddSet(recognise.sq1,kf[1]);
            fi;
            if not kf[2] in Group(recognise.sq2) then
                AddSet(recognise.sq2,kf[2]);
            fi;
       fi;

    return fail;

end;



# Compute the degrees of the irreducible factors of
# the characteristic polynomial <cpol>
RECOG.IsReducible := function( recognise, grp )
    
    local deg, dims, g;
  
    # compute the degrees of the irreducible factors
    deg := List(Factors(recognise.cpol), i-> Degree(i));

    # compute all possible dimensions
    dims := [0];
    for g in deg do
        UniteSet(dims,dims+g);
    od;

    # intersect it with recognise.dimsReducible
    if IsEmpty(recognise.dimsReducible) then
        recognise.dimsReducible := dims;
    else
        IntersectSet(recognise.dimsReducible,dims);
    fi;

    # G acts irreducibly if only 0 and d are possible
    if Length(recognise.dimsReducible)=2 then
        recognise.isReducible := false;
        return false;
    fi;
  
    return fail;
end;

RECOG.NoClassicalForms := function( recognise, grp )

        PossibleClassicalForms( grp, recognise.g, recognise );

        if recognise.maybeDual = false and 
           recognise.maybeFrobenius = false then  
            recognise.ClassicalForms := ["linear"];
            return false;
        fi;

        return fail;

end;



RECOG.ClassicalForms := function( recognise, grp)
    local   field,  z,  d,  i,  qq,  A,  c,  I,  t,  i0,  
            a,  l,  g,  module,  forms,  dmodule,  fmodule,  form;

    if recognise.n > 15 then
        recognise.needForms := true;
    fi;

    if recognise.needForms <> true then
        return NotApplicable;
    fi;

    # the group has to be absolutely irreducible
    if recognise.isReducible = "unknown"  then
        recognise.needMeataxe := true;
        return fail;
    fi;
     
    # set up the field and other information
    field := recognise.field;
    d := recognise.d;
    z := Zero(field);
    module := recognise.module;

    if recognise.maybeFrobenius  = true then
        qq := Characteristic(field) ^ (LogInt( Size(field),
              Characteristic(field))/2 );
    fi;

    # try to find generators without scalars
    if recognise.maybeDual = true then
        dmodule := ClassicalForms_GeneratorsWithoutScalarsDual(grp);
        if dmodule = false  then
            Add( recognise.ClassicalForms,  "unknown"  );
            recognise.maybeDual := false;
        fi;
    fi;
    if recognise.maybeFrobenius = true then
        fmodule := ClassicalForms_GeneratorsWithoutScalarsFrobenius(grp);
        if fmodule = false  then
            Add( recognise.ClassicalForms,  "unknown" );
            recognise.maybeFrobenius := false;
        fi;
    fi;

    # now try to find an invariant form
    if recognise.maybeDual  = true then
        form := ClassicalForms_InvariantFormDual(module,dmodule);
        if form <> false  then
            Add( recognise.ClassicalForms, form[1] );
            recognise.InvariantDualForm := form[2];
            if Length(form) = 4 then
                recognise.QuadraticForm := form[4];
            fi;
        else
            Add( recognise.ClassicalForms, "dual"  );
        fi;
    fi;

    if recognise.maybeFrobenius = true then
        form := ClassicalForms_InvariantFormFrobenius(module,fmodule);
        if form <> false  then
            Add( recognise.ClassicalForms, form[1] );
            recognise.InvariantFrobeniusForm := form[2];
        else
            Add( recognise.ClassicalForms, "frobenius"  );
        fi;
    fi;
    return false;

end;


RECOG.MeatAxe := function( recognise, grp )

    if recognise.n > 15 then
        recognise.needMeataxe := true;
    fi;

    if recognise.needMeataxe <> true then
        return NotApplicable;
    fi;

    
    if MTX.IsIrreducible(recognise.module) then
        recognise.isReducible := false;
        return false;
    else
        Info( InfoClassical, 2, 
        "The group acts reducibly and thus doesn't contain a classical group");
        recognise.isReducible := true;
        recognise.isSLContained := false;
        recognise.isSpContained := false;
        recognise.isSUContained := false;
        recognise.isSOContained := false;
        return true;
    fi;
end;

## Main function to test whether group contains SL
RECOG.IsSLContained := function( recognise, grp )


    if recognise.isGeneric <> true or
       recognise.isNotExt <> true or
       recognise.isNotPSL <> true  or
       recognise.isReducible = true or
       recognise.isNotMathieu <> true or 
       recognise.isNotAlternating <> true  then
          return fail;
    fi;

    
    if recognise.isReducible = "unknown" then 
        recognise.needMeataxe := true;
        return NotApplicable; 
    fi;

    
    # if we reach this point the natural module is irreducible
    # since the MeatAxe Method aborts in the reducible case.
    # Also we know that the module is absolutely irreducible,
    # since we are in the generic case.
    if Length(recognise.ClassicalForms)=0 then
        recognise.needForms := true;
        return NotApplicable;
    fi;
        
    if "linear" in recognise.ClassicalForms then
        recognise.IsSLContained := true;
        Info(InfoClassical,2,"The group contains SL(", recognise.d, ", ",
        recognise.q, ");");
        return true;
    else
        recognise.IsSLContained := false;
        Info(InfoClassical,2,"The group does not contain SL(", 
        recognise.d, ", ", recognise.q, ");");
        return false;
    fi;

end;

## Main function to test whether group contains Sp
RECOG.IsSpContained := function( recognise, grp )

    # if the dimension is not even, the group cannot be symplectic
    if recognise.d mod 2 <> 0 then
        recognise.IsSpContained := false;
        return false;
    fi;

    if recognise.IsSpContained = false then
        return false;
    fi;

    if recognise.isGeneric <> true or
       recognise.isReducible = true or
       recognise.currentgcd <> 2 or
       recognise.isNotPSL <> true  or
       recognise.isNotMathieu <> true or 
       recognise.isNotAlternating <> true  then
          return fail;
    fi;


    
    if recognise.isReducible = "unknown" then 
        recognise.needMeataxe := true;
        return NotApplicable; 
    fi;

    # if we reach this point the natural module is irreducible
    # since the MeatAxe Method aborts in the reducible case.
    # Also we know that the module is absolutely irreducible,
    # since we are in the generic case.
    if Length(recognise.ClassicalForms)=0 then
        recognise.needForms := true;
        return NotApplicable;
    fi;
        
    if "symplectic" in recognise.ClassicalForms then
        recognise.IsSpContained := true;
        recognise.isNotExt := true;
        Info(InfoClassical,2,"The group contains Sp(", recognise.d, ", ",
        recognise.q, ");");
        return true;
    else
        recognise.IsSpContained := false;
        Info(InfoClassical,2,"The group does not contain Sp(", 
        recognise.d, ", ", recognise.q, ");");
        return false;
    fi;
end;


## Main function to test whether group contains SU
RECOG.IsSUContained := function( recognise, grp )

    local f;

    f := recognise.field;

    # if size of field not a square, the group cannot be unitary
    if LogInt(Size(f),Characteristic(f))  mod 2 <> 0 then
        recognise.IsSUContained := false;
        return false;
    fi;
 


    if recognise.IsSUContained = false then
        return false;
    fi;

    if recognise.isGeneric <> true or
       recognise.isReducible = true or
       recognise.isNotExt <> true or
       recognise.isNotPSL <> true  or
       recognise.isNotMathieu <> true or 
       recognise.isNotAlternating <> true  then
          return fail;
    fi;


    
    if recognise.isReducible = "unknown" then 
        recognise.needMeataxe := true;
        return NotApplicable; 
    fi;

    # if we reach this point the natural module is irreducible
    # since the MeatAxe Method aborts in the reducible case.
    # Also we know that the module is absolutely irreducible,
    # since we are in the generic case.
    if Length(recognise.ClassicalForms)=0 then
        recognise.needForms := true;
        return NotApplicable;
    fi;
        
    if "unitary" in recognise.ClassicalForms then
        recognise.IsSUContained := true;
        Info(InfoClassical,2,"The group contains SU(", recognise.d, ", ",
        recognise.q, ");");
        return true;
    else
        recognise.IsSUContained := false;
        Info(InfoClassical,2,"The group does not contain SU(", 
        recognise.d, ", ", recognise.q, ");");
        return false;
    fi;
end;



## Main function to test whether group contains SO
RECOG.IsSOContained := function( recognise, grp )

    local f;

    if recognise.IsSOContained = false then
        return false;
    fi;


    if IsOddInt(recognise.d) and not IsOddInt(recognise.q) then 
        return false; 
    fi;

    if recognise.isGeneric <> true or
       not recognise.currentgcd in [1,2] or
       recognise.isNotPSL <> true  or
       recognise.isReducible = true or
       recognise.isNotMathieu <> true or 
       recognise.isNotAlternating <> true  then
          return fail;
    fi;


    if recognise.isReducible = "unknown" then 
        recognise.needMeataxe := true;
        return NotApplicable; 
    fi;

    # if we reach this point the natural module is irreducible
    # since the MeatAxe Method aborts in the reducible case.
    # Also we know that the module is absolutely irreducible,
    # since we are in the generic case.
    if Length(recognise.ClassicalForms)=0 then
        recognise.needForms := true;
        return NotApplicable;
    fi;
        
    if "orthogonalcircle" in recognise.ClassicalForms then
        if recognise.d mod 2 = 0 then return false; fi;
        if recognise.currentgcd <> 1 then return fail; fi;
        recognise.isNotExt := true;
        recognise.IsSOContained := true;
        Info(InfoClassical,2,"The group contains SO^o(", recognise.d, ", ",
        recognise.q, ");");
        return true;

    elif "orthogonalplus" in recognise.ClassicalForms then
        if recognise.d mod 2 <> 0 then return false; fi;
        if recognise.currentgcd <> 2 then return fail; fi;
        recognise.isNotExt := true;
        recognise.IsSOContained := true;
        Info(InfoClassical,2,"The group contains SO+(", recognise.d, ", ",
        recognise.q, ");");
        return true;

    elif "orthogonalminus" in recognise.ClassicalForms then
        if recognise.d mod 2 <> 0 then return false; fi;
        if recognise.currentgcd <> 2 then return fail; fi;
        recognise.isNotExt := true;
        recognise.IsSOContained := true;
        Info(InfoClassical,2,"The group contains SO-(", recognise.d, ", ",
        recognise.q, ");");
        return true;
    else
        recognise.IsSOContained := false;
        Info(InfoClassical,2,"The group does not contain SO(", 
        recognise.d, ", ", recognise.q, ");");
        return false;
    fi;
end;




HasElementsMultipleOf := function(orders, ord )

    local o;

    for o in ord do
       if PositionProperty(orders, i->(i mod o = 0 )) = fail then
           return false;
       fi;
    od;

    return true;

end;

############################################################################/
##
##  The following functions deal with the Non-generic cases. See [3].
##

############################################################################/
##
##  NonGenericLinear (recognise, grp)  . . . . . . . non-generic linear case
##
##  Recognise non-generic linear matrix groups over finite fields:
##  In order to prove that a group G <= GL( 3, 2^s-1) contains SL, we need to
##  find an element of order a multiple of 4 and a large and basic ppd(3,q;3)-
##  element
##
RECOG.NonGenericLinear := function( recognise, grp )

    local CheckFlag;

    CheckFlag := function( )
        if recognise.isReducible = "unknown" then
           recognise.needMeataxe := true;
           return fail;
        fi;
        if  Length(recognise.ClassicalForms) = 0 then
            recognise.needForms :=  true;
            return fail;
        fi;
        Info(InfoClassical,2,"The group is not generic");
        Info(InfoClassical,2,"and contains SL(", recognise.d, ", ",
        recognise.q, ");");
        recognise.IsSLContained := true;
        return true;
    end;
                 
    if recognise.d > 3 then return false; fi;

    if recognise.isReducible = true then
       return false;
    fi;

    if Length( recognise.ClassicalForms ) > 0 and 
       not "linear" in recognise.ClassicalForms then
       return false;
    fi;

    if recognise.n <= 5 then
        return fail;
    elif recognise.n = 6 then
        recognise.needOrders := true;
        return fail;
    fi;

    if 3 in recognise.LE and 3 in recognise.BE 
       and HasElementsMultipleOf(recognise.orders, [4]) then
           return CheckFlag();        
    fi;
    
    return fail;
end;

############################################################################/
##
##  Recognise non-generic symplectic matrix groups over finite fields
##
RECOG.NonGenericSymplectic := function(recognise, grp)

    local d, q, CheckFlag;

    CheckFlag := function( )
        if recognise.isReducible = "unknown" then
           recognise.needMeataxe := true;
           return fail;
        fi;
        if  Length(recognise.ClassicalForms) = 0 then
            recognise.needForms :=  true;
            return fail;
        fi;
        Info(InfoClassical,2,"The group is not generic");
        Info(InfoClassical,2,"and contains Sp(", recognise.d, ", ",
        recognise.q, ");");
        recognise.IsSpContained := true;
        return true;
    end;
                 
    d := recognise.d;
    q := recognise.q;

    if not IsEvenInt(recognise.d) then return false; fi;

    if recognise.isReducible = true then
       return false;
    fi;

    if Length( recognise.ClassicalForms ) > 0 and 
       not "symplectic" in recognise.ClassicalForms then
       return false;
    fi;

    if d > 8 then  return false; fi;

    if recognise.n <= 5 then
        return NotApplicable;
    elif recognise.n = 6 then
        recognise.needOrders := true;
        if d = 4 then
            recognise.needLB := true;
            recognise.needE2 := true;
        fi;
        return fail;
    fi;


    if d = 8 and q = 2 then
        if not HasElementsMultipleOf(recognise.orders, [5,9,17]) then
            return fail; 
        fi;
    elif d = 6 and q = 2 then
        if not HasElementsMultipleOf(recognise.orders, [5,7,9]) then
            return fail; 
        fi;
    elif d = 6 and q = 3 then
        if not HasElementsMultipleOf(recognise.orders, [5,7]) then
            return fail; 
        fi;
    elif d = 4 and q = 3 then
        if not HasElementsMultipleOf(recognise.orders, [5,9]) then
            return fail; 
        fi;
    elif d = 4 and q = 2 then
        if Size(grp) mod (3*4*5*6) <> 0 then
            Info(InfoClassical,2,"group does not contain Sp(", 
                 recognise.d, ", ", recognise.q, ");");
           recognise.isSpContained := false;
           return false;
        fi;
    elif d = 4 and q = 5 then
        if not HasElementsMultipleOf(recognise.orders, [13,15]) then
            return fail; 
        fi;
    elif d = 4 and not IsPowerOfPrime(q+1,2) and not ((q+1) mod 3 = 0 and
                   IsPowerOfPrime((q+1)/3, 2)) and q<>2 then
        if not 4 in recognise.LB then 
            return fail; 
        fi;
        if not 2 in  recognise.LS then return fail; fi;
    elif d = 4  and q >= 7 and IsPowerOfPrime(q+1,2) then
        if not 4 in recognise.LB then return fail; fi;
        if not HasElementsMultipleOf(recognise.orders, [4]) then
            return fail; 
        fi;

    elif d = 4 and q >= 11 and IsPowerOfPrime((q+1)/3, 2) then
        if not HasElementsMultipleOf(recognise.orders, [3,4]) then
            return fail; 
        fi;
        if not 4 in recognise.LB then return fail; fi;
    else
        Info(InfoClassical,2,
             "NonGenericSymplectic: d and q must have been be generic");
        return false;
    fi;

    return CheckFlag();    
    
end;

############################################################################/
##
##  Recognise non-generic unitary matrix groups over finite fields
##
RECOG.NonGenericUnitary := function(recognise, grp)

    local d, q, q0, g, f1, f2, o, CheckFlag;

    CheckFlag := function( )
        if recognise.isReducible = "unknown" then
           recognise.needMeataxe := true;
           return fail;
        fi;
        if  Length(recognise.ClassicalForms) = 0 then
            recognise.needForms :=  true;
            return fail;
        fi;
         Info(InfoClassical,2,"group contains SU(", 
          recognise.d, ", ", recognise.q, ");");
        recognise.isSpContained := true;

        recognise.IsSUContained := true;
        return true;
    end;

    d := recognise.d;
    q := recognise.q;

    if d > 6 then  return false; fi;

    if recognise.isReducible = true then
       return false;
    fi;

    if Length( recognise.ClassicalForms ) > 0 and 
       not "unitary" in recognise.ClassicalForms then
       return false;
    fi;

    if recognise.n <= 5 then
        return NotApplicable;
    elif recognise.n = 6 then
        recognise.needOrders := true;
        if d = 6 or d = 4 then
            recognise.needLB := true;
            recognise.needE2 := true;
        fi;
        if d = 3 then
            recognise.needPOrders := true;
            if q >= 49 then
               recognise.needLB := true;
            fi;
        fi;
        return fail;
    fi;

    if d = 6 and q = 4 then
        if not HasElementsMultipleOf(recognise.orders, [7,10,11]) then
            return fail; 
        fi;
    elif d = 6 and q >= 9 then
        if not 3 in recognise.E2 then return fail; fi;
        if not 5 in recognise.LB then return fail; fi;
    elif d = 5 and q = 4 then 
        if not HasElementsMultipleOf(recognise.orders, [11,12]) then
            return fail; 
        fi;
    elif d = 4 and q = 4 then 
        #TO DO : check this is same in Magma
        if not HasElementsMultipleOf(recognise.orders, [5,9]) then
            return fail; 
        fi;
    elif d = 4 and q = 9 then 
        if not HasElementsMultipleOf(recognise.orders, [5,7,9]) then
            return fail; 
        fi;
    elif d = 4 and q > 9 then 
        if not 3 in recognise.LB then 
            return fail; 
        fi;
        if not 2 in recognise.E2  then return fail; fi;
        f1 := Collected(Factors( q^3-1 ));
        f2 := Collected(Factors( q^2-1 ));
        # check if we have a prime at least 11
        if PositionProperty( f1, i-> (i[1] >= 11)) <> fail then
            return CheckFlag();
        fi;
        if PositionProperty( f2, i-> (i[1] >= 11)) <> fail then
            return CheckFlag();
        fi;
        # Now we know that q^3-1 and q^2-1 only contain primes
        # at most 7
        if not q^3 mod 7 = 1 or q^2 mod 7 = 1 or q mod 7 = 1 then
            # 7 is not ppd of q^3-1
            return CheckFlag();
        fi;
        # Now we know 7 is ppd of q^3 -1 
        if not q^2 mod 5 = 1 or q mod 5 = 1 then
            # 5 is not ppd of q^2-1
            return CheckFlag();
        fi;
        if PositionProperty( recognise.orders, i -> 
        (i mod 7 = 0 and     # order divisible by 7
         i <> 7 and          # but not equal to 7
         q^3 mod i = 1 and   # order divides q^3-1
        (7*(q-1)) mod i <> 0 # order does not divide 7*(q-1)
         )) <> fail then 
            # 5 is not ppd of q^2-1
            return CheckFlag();
        fi;
    elif d = 3 and q = 4 then
        if Order(grp) mod 216 = 0 then 
            return CheckFlag();
        else
            recognise.IsSUContained := false;
            return false;
        fi;
    elif d = 3 and q = 9 then 
        if not HasElementsMultipleOf(recognise.orders, [7]) then
            return fail; 
        fi;
        if recognise.hasSpecialEle = false then
            if not Order( recognise.g ) mod 6 = 0 then return fail; fi;
            if PositionProperty( GeneratorsOfGroup(grp), 
                h-> (Comm(h,recognise.g^3) <> One(grp))) <> fail then
                Info( InfoClassical,2, 
            "Cube of element of order div by 6 is not central" );
                 recognise.hasSpecialEle := true;
                return CheckFlag();
             fi;
        else return CheckFlag();
        fi;
    elif d = 3 and q = 16 then 
        if not HasElementsMultipleOf(recognise.orders, [5,13]) then
            return fail; 
        fi;
        if recognise.hasSpecialEle = false then
            if not Order(recognise.g) mod 5  = 0 then return fail; fi;
            if PositionProperty( GeneratorsOfGroup(grp), 
            h-> (Comm(h,recognise.g) <> One(grp))) <> fail then
                Info( InfoClassical,2, 
                "The element of order 5 is not central" );
                 recognise.hasSpecialEle := true;
                 return CheckFlag();
            fi;
        else return CheckFlag();
        fi;
    elif d = 3 and q = 25 then 
        if not HasElementsMultipleOf(recognise.orders, [5,7,8]) then
            return fail; 
        fi;
        if recognise.hasSpecialEle = false then
            if Order(recognise.g) mod 8 <> 0 then return fail; fi;
            g := recognise.g^(Order(recognise.g)/2);
            if PositionProperty( GeneratorsOfGroup(grp), 
                h-> (Comm(h,g) <> One(grp))) <> fail then
                Info( InfoClassical,2, 
                "involution in cyclic subgroup  of order 8 is not central" );
                recognise.hasSpecialEle := true;
                return CheckFlag();
             fi;
        else return CheckFlag();
        fi;        
    elif d = 3 and q >= 49  then 
        if not 3 in recognise.LE or not 3 in recognise.BE then
           return fail;
        fi;
        if not recognise.ppd[1] = 3 or not recognise.ppd[2]=true
           or not recognise.ppd[3]=true then 
            return fail; 
        fi;
        if recognise.hasSpecialEle = false then
            g := recognise.g;
            o := Order(g);
            q0 := Characteristic(recognise.field)^
             (LogInt(q,Characteristic(recognise.field))/2);
            if not ((q0^2 - q0 + 1)/Gcd(3,q0+1)) mod o = 0 then
                return fail;
            fi;
            if not o > 7* Gcd(3,q0+1) then
                return fail;
            fi;
            if PositionProperty(recognise.porders,
               i->(i[1]>3 and q mod i[1]=1))=fail then
                return fail;
            fi;
            recognise.hasSpeccialEle := true;
            return CheckFlag();
         else 
            return CheckFlag();
         fi;
    else
        Info(InfoClassical,2, 
            "NonGenericUnitary: d and q must have been be generic");
        return false;
    fi;


    return CheckFlag();
end;
        

RECOG.NonGenericOrthogonalPlus := function(recognise,grp)

    local d, q, gp1, gp2, CheckFlag, pgrp, orbs;

    CheckFlag := function( )
        if recognise.isReducible = "unknown" then
           recognise.needMeataxe := true;
           return fail;
        fi;
        if  Length(recognise.ClassicalForms) = 0 then
            recognise.needForms :=  true;
            return fail;
        fi;
        Info(InfoClassical,2,"group contains SO+(", 
        recognise.d, ", ", recognise.q, ");");

        recognise.IsSOContained := true;
        return true;
    end;

    d := recognise.d;
    q := recognise.q;

    if not d in [4,6,8,10] then return false; fi;
    if d = 10 and q <> 2 then return false; fi;

    if recognise.isReducible = true then
       return false;
    fi;

    if Length( recognise.ClassicalForms ) > 0 and 
       not "orthogonalplus" in recognise.ClassicalForms then
       return false;
    fi;

    if recognise.n <= 5 then
        return NotApplicable;
    elif recognise.n = 6 then
        recognise.needOrders := true;
        if d = 8 then
           recognise.needE2 := true;
        fi;
        return fail;
    fi;

    if d = 10 and q = 2 then
        if not HasElementsMultipleOf( recognise.orders, [17,31])  then
            return fail; 
        fi;
    elif d = 8 and q = 2 then
        if not IsSubset(recognise.orders,[7, 9, 10, 15]) then 
            return fail;
        fi;
        pgrp := ProjectiveActionOnFullSpace( grp, recognise.field, d );
        orbs := Orbits( pgrp, MovedPointsPerms( GeneratorsOfGroup(pgrp)));   

        if Set(List(orbs,Length)) <> [ 120, 135 ] then 	
           recognise.isSOContained := false;
           return false; 
        fi;
	if Size(pgrp) mod  174182400 = 0 then
           return CheckFlag();
           recognise.isSOContained := true;
        else
           recognise.isSOContained := false;
           return false; 
         fi;
    elif d = 8 and q = 3 then
        if not HasElementsMultipleOf( recognise.orders, [7,13])  then
            return fail; 
        fi;
        pgrp := ProjectiveActionOnFullSpace( grp, recognise.field, d );
        orbs := Orbits( pgrp, MovedPointsPerms( GeneratorsOfGroup(pgrp)));   
	if Set(List(orbs, Length)) <> [ 1080, 1120] then
             recognise.isSOContained := false;
             return false; 
        fi;
        if Size(pgrp) mod 4952179814400 = 0 then 
             return CheckFlag();
        else
             recognise.isSOContained := false;
             return false;
        fi;
    elif d = 8 and  q =  5 then 
        if not HasElementsMultipleOf( recognise.orders, [7,13])  then
            return fail; 
        fi;
    elif d = 8 and (q = 4 or q > 5) then 
        if not 6 in recognise.LB then return fail; fi;
        if not 4 in recognise.LS then return fail; fi;
    elif d = 6 and q = 2 then
        if not IsSubset( recognise.orders, [7,15] ) then return fail; fi;
    elif d = 6 and q = 3 then
        if not HasElementsMultipleOf( recognise.orders, [5])  then
            return fail; 
        fi;
        if not 13 in recognise.orders then return fail; fi;
    elif d = 6 and q >= 4 then
        if not 4 in recognise.LB then return fail; fi;
        if not 3 in recognise.E2 then return fail; fi;
    elif d = 4 and (q = 8 or q >= 11) then
        if recognise.needPlusMinus = false then 
            recognise.needPlusMinus := true;
            return NotApplicable;
        fi;
        if not IsSubset(recognise.plusminus,[[1,1],[1,-1],[-1,-1]]) then
            return fail;
        fi;
    elif d = 4 and q = 2 then
        if Size(grp) mod 36 <> 0 then 
            recognise.isSOContained := false;
            return false; 
        fi;
        if recognise.needDecompose = false then 
           recognise.needDecompose := true;
           return fail;
        fi;
        gp1 := Group(recognise.sq1);
        gp2 := Group(recognise.sq2);
        Info(InfoClassical,2,"Group projects to group of order ",
        Size(gp1/recognise.scalars), "x", Size(gp2/recognise.scalars),"\n");
        if Size(gp1/recognise.scalars) mod 6 = 0 and
           Size(gp2/recognise.scalars) mod 6 = 0 then
                return CheckFlag();
        fi;
    elif d = 4 and q = 3 then
        if Size(grp) mod 288 <> 0 then 
            recognise.isSOContained := false;
            return false; 
        fi;
        if recognise.needDecompose = false then 
           recognise.needDecompose := true;
           return fail;
        fi;
        gp1 := Group(recognise.sq1);
        gp2 := Group(recognise.sq2);
        Info(InfoClassical,2,"Group projects to group of order ",
        Size(gp1/recognise.scalars), "x", Size(gp2/recognise.scalars),"\n");
        if Size(gp1/recognise.scalars) mod 12 = 0 and
           Size(gp2/recognise.scalars) mod 12 = 0 then
                return CheckFlag();
        fi;
    elif d = 4 and q =  4 then
        pgrp := ProjectiveActionOnFullSpace( grp, recognise.field, d );
        orbs := Orbits( pgrp, MovedPointsPerms(
           GeneratorsOfGroup(pgrp)));   
        # TODO Check this in MAGMA
        if Size(pgrp) mod 3600 <> 0 then 
             recognise.isSOContained := false;
             return false; 
        fi;
        if recognise.needDecompose = false then 
           recognise.needDecompose := true;
           return fail;
        fi;
        gp1 := Group(recognise.sq1);
        gp2 := Group(recognise.sq2);
        Info(InfoClassical,2,"Group projects to group of order ",
        Size(gp1/recognise.scalars), "x", Size(gp2/recognise.scalars),"\n");
        if Size(gp1/recognise.scalars) mod 3 = 0 and
           Size(gp2/recognise.scalars) mod 3 = 0 then
                return CheckFlag();
        fi;
    elif d = 4 and q = 5 then
        pgrp := ProjectiveActionOnFullSpace( grp, recognise.field, d );
        if Size(pgrp) mod 7200 <> 0 then 
            recognise.isSOContained := false;
            return false;
        else
            return CheckFlag();
        fi;
    elif d = 4 and q = 7 then
        pgrp := ProjectiveActionOnFullSpace( grp, recognise.field, d );
        if Size(pgrp) mod 56448  <> 0 then 
            recognise.isSOContained := false;
            return false;
        fi;
        if recognise.needDecompose = false then 
           recognise.needDecompose := true;
           return fail;
        fi;
        gp1 := Group(recognise.sq1);
        gp2 := Group(recognise.sq2);
        Info(InfoClassical,2,"Group projects to group of order ",
        Size(gp1/recognise.scalars), "x", Size(gp2/recognise.scalars),"\n");
        if Size(gp1/recognise.scalars) mod 168 = 0 and
           Size(gp2/recognise.scalars) mod 168 = 0 then
                return CheckFlag();
        fi;
    elif d = 4 and q = 9 then
        pgrp := ProjectiveActionOnFullSpace( grp, recognise.field, d );
        if Size(pgrp) mod 259200 <> 0 then 
            recognise.isSOContained := false;
            return false;
        else
            return CheckFlag();
        fi;
    else
        Info(InfoClassical, 2,
           "NonGenericO+: d and q must have  been be generic");  
        return false;
    fi;
     
     return CheckFlag();

end;

RECOG.NonGenericOrthogonalMinus := function(recognise, grp)

    local d, q,  orbs, pgrp, h,  g, ppd,  CheckFlag;


    CheckFlag := function( )
        if recognise.isReducible = "unknown" then
           recognise.needMeataxe := true;
           return fail;
        fi;
        if  Length(recognise.ClassicalForms) = 0 then
            recognise.needForms :=  true;
            return fail;
        fi;
        Info(InfoClassical,2,"group contains SO-(", 
        recognise.d, ", ", recognise.q, ");");
        recognise.IsSOContained := true;
        return true;
    end;

    d := recognise.d;
    q := recognise.q;

    if not d in [4,6,8] then return false; fi;
    if d = 8 and q <> 2 then return false; fi;
    if d = 6 and q > 3 then return false; fi;

    if recognise.isReducible = true then
       return false;
    fi;

    if Length( recognise.ClassicalForms ) > 0 and 
       not "orthogonalminus" in recognise.ClassicalForms then
       return false;
    fi;

    if recognise.n <= 5 then
        return NotApplicable;
    elif recognise.n = 6 then
        recognise.needOrders := true;
        return fail;
    fi;

    
    if d = 8 and q = 2 then
        if not HasElementsMultipleOf( recognise.orders, [9,17])  then
            return fail; 
        fi;
    elif d = 6 and q = 3 then
        if not HasElementsMultipleOf( recognise.orders, [5,7,9])  then
            return fail; 
        fi;
    elif d = 6 and q = 2 then 
        if not HasElementsMultipleOf( recognise.orders, [5,9])  then
            return fail; 
        fi;
    elif d = 4 and q = 2 then 
        if not HasElementsMultipleOf( recognise.orders, [3,5])  then
            return fail; 
        fi;
    elif d = 4 and q = 3 then
        if not HasElementsMultipleOf( recognise.orders, [5])  then
            return fail; 
        fi;
        pgrp := ProjectiveActionOnFullSpace( grp, GF(3), 4 );       
        orbs := Orbits( pgrp, MovedPointsPerms( GeneratorsOfGroup(pgrp)));
        if Length(orbs) <>  3 then
            recognise.isSOContained := false;
            return false;
         fi;
    elif d = 4 and q >=  4 then
         # TODO check this in Magma
        ppd := IsPpdElement( recognise.field, recognise.cpol, d, q, 1 );
        if ppd = false or ppd[1] <> 4 then return fail; fi;
        # found a ppd( 4, q; 4)-element
        g := recognise.g;
        for h in GeneratorsOfGroup(grp) do
            if Comm(h,g) <> One(grp) or Comm(Comm(h,g),g) <> One(grp) then
                        return CheckFlag();
            fi;
        od;
        Info(InfoClassical, 2, "grp contained in O-(2,", q,  "^2)\n" );
        recognise.isNotExt := false;
        recognise.isSOContained := false;
        return false;
    else
      Info(InfoClassical, 2, "NonGenericO-: d and q must be generic\n" );
        return false;
    fi;

     return CheckFlag();

end;

RECOG.NonGenericOrthogonalCircle := function( recognise, grp )


    local d, q, g, s, CheckFlag;


    if not IsOddInt(recognise.d) then return false; fi;
    if not IsOddInt(recognise.q) then return false; fi;
    
    CheckFlag := function( )
        if recognise.isReducible = "unknown" then
           recognise.needMeataxe := true;
           return fail;
        fi;
        if  Length(recognise.ClassicalForms) = 0 then
            recognise.needForms :=  true;
            return fail;
        fi;
        Info(InfoClassical,2,"group contains SOo(", 
        recognise.d, ", ", recognise.q, ");");
        recognise.IsSOContained := true;
        return true;
    end;

    d := recognise.d;
    q := recognise.q;

    if recognise.isReducible = true then
       return false;
    fi;

    if Length( recognise.ClassicalForms ) > 0 and 
       not "orthogonalcircle" in recognise.ClassicalForms then
       return false;
    fi;

    if recognise.n <= 5 then
        return NotApplicable;
    elif recognise.n = 6 then
        recognise.needOrders := true;
        return fail;
    fi;


    if d = 7 and q = 3 then
        if not HasElementsMultipleOf( recognise.orders, [5,7,13])  then
            return fail; 
        fi;
    elif d = 5 and q = 3 then
        if not HasElementsMultipleOf( recognise.orders, [5,9])  then
            return fail; 
        fi;
    elif d = 5 and q >= 5 then 
        if not 4 in recognise.LE then return fail; fi;
    elif d = 3 and q = 3 then 
        if not HasElementsMultipleOf( recognise.orders, [3])  then
            return fail; 
        fi;
    elif d = 3 and q = 5 then 
        if not HasElementsMultipleOf( recognise.orders, [3,5])  then
            return fail; 
        fi;
    elif d = 3 and q = 7 then 
        if not HasElementsMultipleOf( recognise.orders, [4,7])  then
            return fail; 
        fi;
    elif d = 3 and q = 9 then 
        if not HasElementsMultipleOf( recognise.orders, [3,5])  then
            return fail; 
        fi; 
        if recognise.hasSpecialEle = false then
            if not Order(recognise.g) in [4,8] then return fail; fi;
            g := recognise.g^2;
            if PositionProperty(GeneratorsOfGroup(grp), 
               h->(Comm(h,g)<>One(grp))) <> fail then 
               recognise.hasSpecialEle := true;
               return CheckFlag();
            fi;
        else
               return CheckFlag();
        fi; 
        recognise.IsSOContained := false;
        return false;
    elif d = 3 and q = 11 then 
        if not HasElementsMultipleOf( recognise.orders, [3,11])  then
            return fail; 
        fi; 
    elif d = 3 and q = 19 then 
        if not HasElementsMultipleOf( recognise.orders, [5,9,19])  then
            return fail; 
        fi; 
    elif d = 3 and q >=31 and IsPowerOfPrime(q+1,2) then 
        s := LogInt(q+1,2);
        if PositionProperty(recognise.orders,
            i->(i > 2 and (q-1) mod i = 0))=fail then 
            return fail; 
        fi; 
        if PositionProperty(recognise.orders, 
            i-> i mod 2^(s-1) = 0 ) = fail then
            return fail; 
        fi; 
    elif d = 3 and q>11 and ((q+1) mod 3=0 and
        IsPowerOfPrime((q+1)/3,2)) then 
        # TO DO Check this in Magma
        s := LogInt( (q+1)/3, 2);
        if PositionProperty(recognise.orders, 
            i-> i mod (3*2^(s-1)) = 0 ) = fail then
            return fail; 
        fi; 
        if PositionProperty(recognise.orders,
            i->(i > 2 and (q-1) mod i = 0))=fail then 
            return fail; 
        fi; 
    elif d = 3 and ((q+1) mod 3 <> 0 or not IsPowerOfPrime((q+1)/3,2)) and
                   not IsPowerOfPrime(q+1,2) then 
        if not 2 in recognise.LB then return fail; fi;
        if PositionProperty(recognise.orders,
            i->(i > 2 and (q-1) mod i = 0))=fail then 
            return fail; 
        fi; 
    else
       Info(InfoClassical, 2, "NonGenericOo: d and q must be generic\n" );
        return false;
    fi;


     return CheckFlag();

end;

########

# 100 Test Random
#
#  50 - 99 Conclusions
#
#  10 - 49 Termination Conditions
#
# 1 - 10 Workers 

AddMethod( ClassicalMethDb, RECOG.TestRandomElement, 100, "TestRandomElement",
           "makes new random element and stores it and its char poly" );

AddMethod( ClassicalMethDb, RECOG.IsGenericParameters,90,"IsGenericParameters",
           "tests whether grp has  generic parameters" );

AddMethod( ClassicalMethDb, RECOG.IsGeneric, 89, "IsGeneric",
           "tests whether grp is generic" );

AddMethod( ClassicalMethDb, RECOG.IsReducible, 80, "IsReducible",
           "tests whether current random element rules out reducible" );

AddMethod( ClassicalMethDb, RECOG.RuledOutExtField, 81,
           "RuledOutExtField", 
           "tests whether extension field case is ruled out" );

AddMethod( ClassicalMethDb, RECOG.IsNotMathieu, 82,
           "IsNotMathieu", 
           "tests whether Mathieu Groups are ruled out" );

AddMethod( ClassicalMethDb, RECOG.IsNotAlternating, 83,
           "IsNotAlternating", 
           "tests whether Alternating Groups are ruled out" );

AddMethod( ClassicalMethDb, RECOG.IsNotPSL, 84,
           "IsNotPSL", 
           "tests whether PSL groups are ruled out" );


AddMethod( ClassicalMethDb, RECOG.NoClassicalForms, 85,
           "NoClassicalForms", 
           "tests whether we can rule out certain forms" );

AddMethod( ClassicalMethDb, RECOG.MeatAxe, 9,
           "MeatAxe", "Test irreducibility" );

AddMethod( ClassicalMethDb, RECOG.ClassicalForms, 8 ,
           "ClassicalForms", "Find the invariant forms" );

AddMethod( ClassicalMethDb, RECOG.NonGenericLinear, 10, "NonGenericLinear",
           "tests whether group is non-generic Linear" );

AddMethod( ClassicalMethDb, RECOG.NonGenericUnitary, 11, "NonGenericUnitary",
           "tests whether group is non-generic Unitary" );

AddMethod( ClassicalMethDb, RECOG.NonGenericSymplectic, 12, 
            "NonGenericSymplectic",
           "tests whether group is non-generic Symplectic" );

AddMethod( ClassicalMethDb, RECOG.NonGenericOrthogonalPlus, 13, 
           "NonGenericOrthogonalPlus",
           "tests whether group is non-generic O+" );


AddMethod( ClassicalMethDb, RECOG.NonGenericOrthogonalMinus, 14, 
           "NonGenericOrthogonalMinus",
           "tests whether group is non-generic O-" );


AddMethod( ClassicalMethDb, RECOG.NonGenericOrthogonalCircle, 15, 
           "NonGenericOrthogonalCircle",
           "tests whether group is non-generic Oo" );

AddMethod( ClassicalMethDb, RECOG.IsSLContained, 16, "IsSLContained",
           "tests whether group contains SL" );

AddMethod( ClassicalMethDb, RECOG.IsSpContained, 17, "IsSpContained",
           "tests whether group contains Sp" );

AddMethod( ClassicalMethDb, RECOG.IsSUContained, 18, "IsSUContained",
           "tests whether group contains SU" );

AddMethod( ClassicalMethDb, RECOG.IsSOContained, 19, "IsSOContained",
           "tests whether group contains SO" );



InstallGlobalFunction( RecogniseClassical,
function( arg )
  local ret, recognise, grp, case, nrrandels, i, f, q;

  if Length( arg ) < 1 or Length( arg ) > 3 then
      Error( "Usage: RecogniseClassical( grp [,nrrandels][,case] )" );
      return;
  fi;
  grp := arg[1];
  nrrandels := 20;
  case := "unknown";
  for i in [2..Length(arg)] do
      if IsInt(arg[i]) then
          nrrandels := arg[i];
      else
          if arg[i] in ["linear", "symplectic", "unitary", 
           "orthogonalplus", "orthogonalcircle", "unknown" ] then
              case := arg[i];
	  else
	      Info(InfoClassical,2,"Unknown case ",arg[i]," - ignored.");
	  fi;
      fi;
  od;

  # init record recognition...
  f := FieldOfMatrixGroup(grp);
  q := Characteristic(f)^DegreeOverPrimeField(f);
  recognise := rec( field :=  f,
                   d := DimensionOfMatrixGroup(grp),
                   p := Characteristic(f),
                   a := DegreeOverPrimeField(f),
                   q := Characteristic(f)^DegreeOverPrimeField(f),
                   E := [], LE := [], BE := [], LB := [], 
                   LS := [], E2 := [], LE2 := [], BE2 := [],
                   g := fail,
                   cpol := fail,
                   isppd := fail,
                   n := 0,
                   module := GModuleByMats(GeneratorsOfGroup(grp),f),
                   currentgcd := DimensionOfMatrixGroup(grp),
                   isReducible := "unknown",
                   isGeneric := "unknown",
                   isNotExt  := "unknown",
                   hint := case,
                   hintIsWrong := false,
                   isNotMathieu := "unknown",
                   isNotAlternating := "unknown",
                   isNotPSL := "unknown",
                   possibleNearlySimple := [],
                   dimsReducible := [],
                   orders := [],
                   porders := [],
                   hasSpecialEle := false,
                   bc := "unknown",
                   kf := "unknown",
                   plusminus := [],
                   sq1 := [Z(q)*One(GL(2,q))],
                   sq2 := [Z(q)*One(GL(2,q))],
                   scalars := Group(Z(q)*One(GL(2,q))),
                   needMeataxe := false,
                   needForms := false,
                   needOrders := false,
                   needPOrders := false,
                   needBaseChange := false,
                   needKF := false,
                   needPlusMinus := false,
                   needDecompose := false,
                   needLB := false,
                   needE2 := false,
                   maybeDual := true,
                   maybeFrobenius := (LogInt(Size(f),Characteristic(f)) mod 2=0),
                   ClassicalForms := [],
                   IsSLContained := "unknown",
                   IsSpContained := "unknown",
                   IsSUContained := "unknown",
                   IsSOContained := "unknown",
                  );
  ret := CallMethods( ClassicalMethDb, nrrandels, recognise, grp );
  # fail: bedeutet, dass entnervt aufgegeben wurde
  # true: bedeutet, dass eine Methode "erfolgreich" war
  
  return recognise;
  # return result
end);

DisplayRecog := function( r )

           Print("Reducible : ", r.isReducible, "\n" );
           Print("Forms : ", r.ClassicalForms, "\n" );
           if Length(r.E) > 0 then
               Print("E : ", r.E, "\n" );
           fi;
           if Length(r.LE) > 0 then
               Print("LE : ", r.LE, "\n" );
           fi;
           if Length(r.BE) > 0 then
               Print("BE : ", r.BE, "\n" );
           fi;
           if Length(r.LS) > 0 then
               Print("LS : ", r.LS, "\n" );
           fi;
           if Length(r.LB) > 0 then
               Print("LB : ", r.LB, "\n" );
           fi;
           if Length(r.E2) > 0 then
               Print("E2 : ", r.E2, "\n" );
           fi;
           if Length(r.LE2) > 0 then
               Print("LE2 : ", r.LE2, "\n" );
           fi;
           if Length(r.BE2) > 0 then
               Print("BE2 : ", r.BE2, "\n" );
           fi;
           if r.isNotMathieu <> "unknown" then
               Print( "Mathieu ruled out: ", r.isNotMathieu, "\n");
           fi;
           if r.isNotAlternating <> "unknown" then
               Print( "An ruled out: ", r.isNotAlternating, "\n");
           fi;
           if r.isNotPSL <> "unknown" then
               Print( "PSL ruled out: ", r.isNotPSL, "\n");
           fi;
#           if Length(r.dimsReducible) > 0 then
#               Print( "dimsred ", r.dimsReducible, "\n");
#           fi;

           if Length(r.orders) > 0 then
               Print( "orders ", r.orders, "\n");
           fi;
           if Length(r.porders) > 0 then
               Print( "porders ", r.porders, "\n");
           fi;

            if r.IsSLContained = true then
                Print("--------> contains SL(", r.d, ",", r.q, ")\n");
            fi;

            if r.IsSpContained = true then
                Print("--------> contains Sp(", r.d, ",", r.q, ")\n");
            fi;


            if r.IsSUContained = true then
                Print("--------> contains SU(", r.d, ",", r.q, ")\n");
            fi;

            if r.IsSOContained = true then
                Print("--------> contains SO(", r.d, ",", r.q, ")\n");
            fi;

            if r.isReducible = true then
                Print("--------> reducible + not classical \n");
            fi;

end;
