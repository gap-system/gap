#############################################################################
##
#W  float.gi                       GAP library                   Steve Linton
##                                                          Laurent Bartholdi 
##
##
#Y  Copyright (C) 2011 The GAP Group
##
##  This file deals with floats, and sets up a default interface, within GAP,
##  to deal with floateans.
##



MAX_FLOAT_LITERAL_CACHE_SIZE := 0; # cache all float literals by default.

FLOAT_DEFAULT_REP := fail;
FLOAT_STRING := fail;
FLOAT := fail; # holds the constants
FLOAT_OBJBYEXTREP := fail;
BindGlobal("EAGER_FLOAT_LITERAL_CONVERTERS", rec());

InstallGlobalFunction(SetFloats, function(arg)
    local i, r;
    if arg=[] or not IsRecord(arg[1]) or Length(arg)>2 or (Length(arg)=2 and not IsPosInt(arg[2])) then
        Error("Unknown argument to SetFloats: ",arg);
    fi;
    r := arg[1];
    if IsBound(r.filter) then
        FLOAT_DEFAULT_REP := r.filter;
    fi;
    if IsBound(r.objbyextrep) then
        FLOAT_OBJBYEXTREP := r.objbyextrep;
    else
        FLOAT_OBJBYEXTREP := fail;
    fi;
    if IsBound(r.constants) then
        FLOAT := r.constants;
    fi;
    if IsBound(r.creator) then
        FLOAT_STRING := r.creator;
        if IsBound(r.eager) then
            EAGER_FLOAT_LITERAL_CONVERTERS.([r.eager]) := r.creator;
        fi;
    fi;
    
    UNBIND_GLOBAL("FLOAT_LITERAL_CACHE");

    if Length(arg)=2 then
        FLOAT.MANT_DIG := arg[2];
        if IsBound(FLOAT.recompute) then
            FLOAT.recompute(FLOAT,arg[2]);
        fi;
    fi;
end);

################################################################
# creators
################################################################
InstallGlobalFunction(Float, function(obj)
    if not IsString(obj) and IsList(obj) then
        return List(obj,Float);
    else
        return NewFloat(FLOAT_DEFAULT_REP,obj);
    fi;
end);

BindGlobal("INSTALLFLOATCONSTRUCTORS", function(arg)
    local filter, float, constants, i;
    
    if IsRecord(arg[1]) then
        filter := arg[1].filter;
    else
        filter := arg[1];
    fi;
    
    InstallMethod(NewFloat, [filter,IsRat], -1, function(filter,obj)
        return NewFloat(filter,NumeratorRat(obj))/NewFloat(filter,DenominatorRat(obj));
    end);
    
    InstallMethod(NewFloat, [filter,IsInfinity], -1, function(filter,obj)
        return Inverse(NewFloat(filter,0));
    end);
    
    InstallMethod(NewFloat, [filter,IsList], -1, function(filter,mantexp)
        if mantexp[1]=0 then
            if mantexp[2]=0 then return NewFloat(filter,0);
            elif mantexp[2]=1 then return Inverse(-Inverse(NewFloat(filter,0)));
            elif mantexp[2]=2 then return Inverse(NewFloat(filter,0));
            elif mantexp[2]=3 then return -Inverse(NewFloat(filter,0));
            else return NewFloat(filter,0)/NewFloat(filter,0);
            fi;
        fi;
        return NewFloat(filter,mantexp[1])*2^(mantexp[2]-LogInt(AbsoluteValue(mantexp[1]),2)-1);
    end);
    
    InstallMethod(NewFloat, [filter,filter], -1, function(filter,obj)
        return obj; # floats are immutable, no harm to return the same one
    end);
    
    InstallMethod(MakeFloat, [filter,IsRat], -1, function(filter,obj)
        return MakeFloat(filter,NumeratorRat(obj))/MakeFloat(filter,DenominatorRat(obj));
    end);
    
    InstallMethod(MakeFloat, [filter,IsInfinity], -1, function(filter,obj)
        return Inverse(MakeFloat(filter,0));
    end);
    
    InstallMethod(MakeFloat, [filter,IsList], -1, function(filter,mantexp)
        if mantexp[1]=0 then 
            if mantexp[2]=0 then return MakeFloat(filter,0); 
            elif mantexp[2]=1 then return Inverse(-Inverse(MakeFloat(filter,0)));
            elif mantexp[2]=2 then return Inverse(MakeFloat(filter,0));
            elif mantexp[2]=3 then return -Inverse(MakeFloat(filter,0));
            else return MakeFloat(filter,0)/MakeFloat(filter,0);
            fi;
        fi;
        return MakeFloat(filter,mantexp[1])*2^(mantexp[2]-LogInt(AbsoluteValue(mantexp[1]),2)-1);
    end);
    
    InstallMethod(MakeFloat, [filter,filter], -1, function(filter,obj)
        return obj; # floats are immutable, no harm to return the same one
    end);
    
    if IsRecord(arg[1]) and IsBound(arg[1].constants) then
        float := arg[1].constants;
        constants := [["E","2.7182818284590452354"],
                      ["LOG2E", "1.4426950408889634074"],
                      ["LOG10E", "0.43429448190325182765"],
                      ["LN2", "0.69314718055994530942"],
                      ["LN10", "2.30258509299404568402"],
                      ["PI", "3.14159265358979323846"],
                      ["2PI", "6.28318530717958647692"],
                      ["PI_2", "1.57079632679489661923"],
                      ["PI_4", "0.78539816339744830962"],
                      ["1_PI", "0.31830988618379067154"],
                      ["2_PI", "0.63661977236758134308"],
                      ["2_SQRTPI", "1.12837916709551257390"],
                      ["SQRT2", "1.41421356237309504880"],
                      ["SQRT1_2", "0.70710678118654752440"]];
        for i in constants do
            if not IsBound(float.(i[1])) then
                float.(i[1]) := NewFloat(filter,i[2]);
            fi;
        od;
    fi;
end);
################################################################
# inner converter from string to float
################################################################
BindGlobal("CONVERT_FLOAT_LITERAL", function(s)
    local i,l,f,s1,s2;
    f:= FLOAT_STRING(s);
    if f <> fail then
        return f;
    fi;
    l := LENGTH(s);
    s1 := "";
    for i in [1..LENGTH(s)] do
        if s[i] in ".0123456789eE+-" then
            s1[i] := s[i];
        elif s[i] in "dDqQ" then
            s1[i] := 'e';
        else
            return fail;
        fi;
    od;
    return FLOAT_STRING(s1);
end);

BindGlobal("CONVERT_FLOAT_LITERAL_EAGER", function(s,mark)
    local f;
    if mark = '\000' then
        return CONVERT_FLOAT_LITERAL(s);
    else
        if not IsBound(EAGER_FLOAT_LITERAL_CONVERTERS.([mark])) then
            Error("Unknown float literal conversion ",mark);
        else
            f := EAGER_FLOAT_LITERAL_CONVERTERS.([mark]);
            if not IsFunction(f) then
                Error("Float literal conversion for ",mark," bound to non-function");
            fi;
            return f(s);
        fi;
    fi;
end);

#############################################################################
## Default methods
#############################################################################
InstallMethod( AbsoluteValue, "for floats", [ IsFloat ], -1,
        function ( x )
    if x < Zero(x) then return -x; else return x; fi;
end );

InstallMethod( Norm, "for floats", [ IsFloat ], -1,
        function ( x )
    return x*x;
end );

InstallMethod( Argument, "for floats", [ IsFloat ], -1,
        function ( x )
    return Zero(x);
end );

InstallMethod( SignFloat, "for floats", [ IsFloat ], -1,
        function ( x )
    if x < Zero(x) then return -1; elif IsZero(x) then return 0; else return 1; fi;
end );

InstallMethod( Exp2, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(Log(MakeFloat(x,2))*x);
end );

InstallMethod( Exp10, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(Log(MakeFloat(x,10))*x);
end );

InstallMethod( Expm1, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(x)-MakeFloat(x,1);
end );


InstallMethod( Log2, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(x) / Log(MakeFloat(x,2));
end );

InstallMethod( Log10, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(x) / Log(MakeFloat(x,10));
end );

InstallMethod( Log1p, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(MakeFloat(x,1)+x);
end );

InstallMethod( Sec, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Cos(x));
end );

InstallMethod( Csc, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Sin(x));
end );

InstallMethod( Cot, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Tan(x));
end );

InstallMethod( Sech, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Cosh(x));
end );

InstallMethod( Csch, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Sinh(x));
end );

InstallMethod( Coth, "for floats", [ IsFloat ], -1,
        function ( x )
    return Inverse(Tanh(x));
end );

InstallMethod( CubeRoot, "for floats", [ IsFloat ], -1,
        function ( x )
    if x>Zero(x) then
        return Exp(Log(x)/3);
    elif IsZero(x) then
        return x;
    else
        return -Exp(Log(-x)/3);
    fi;
end );

InstallMethod( Square, "for floats", [ IsFloat ], -1,
        function ( x )
    return x*x;
end );

InstallMethod( Hypothenuse, "for floats", [ IsFloat, IsFloat ], -1,
        function ( x, y )
    return Sqrt(x*x+y*y);
end );

InstallMethod( Ceil, "for floats", [ IsFloat ], -1,
        function ( x )
    return -Floor(-x);
end );

InstallMethod( Round, "for floats", [ IsFloat ], -1,
        function ( x )
    return Floor(x+MakeFloat(x,1/2));
end );

InstallMethod( Trunc, "for floats", [ IsFloat ], -1,
        function ( x )
    if x>Zero(x) then
        return Floor(x);
    else
        return -Floor(-x);
    fi;
end );

InstallMethod( Frac, "for floats", [ IsFloat ], -1,
        function ( x )
    return x-Floor(x);
end );

InstallMethod( SinCos, "for floats", [ IsFloat ], -1,
        function ( x )
    return [Sin(x), Cos(x)];
end );

InstallMethod( Hypothenuse, "for floats", [ IsFloat, IsFloat ], -1,
        function ( x, y )
    return Sqrt(x*x+y*y);
end );

InstallMethod( FrExp, "for floats", [ IsFloat ], -1,
        function(obj)
    local m, e, s;
    if IsZero(obj) then return [0,0]; fi;
    if obj>Zero(obj) then s := 1; else s := -1; obj := -obj; fi;
    e := Int(Log2(obj))+1;
    m := obj/2^e;
    return [m,e];
end);

InstallMethod( LdExp, "for floats", [ IsFloat, IsInt ], -1,
        function(m,e)
    return m*2^e;
end);
    
InstallMethod( ExtRepOfObj, "for floats", [ IsFloat ], -1,
        function(obj)
    local p, v, sgn;
    if IsZero(obj) then # special treatment for 0 and -0
        if 1/obj > Zero(obj) then
            return [0,0];
        else
            return [0,1];
        fi;
    elif IsPInfinity(obj) then
        return [0,2];
    elif IsNInfinity(obj) then
        return [0,3];
    elif IsNaN(obj) then
        return [0,4];
    fi;
            
    p := FrExp(obj);
    v := p[1];
    while v mod One(v) <> Zero(v) do v := 2*v; od;
    return [Int(v),p[2]];
end);
    
InstallMethod( ObjByExtRep, "for floats", [ IsFloatFamily, IsList ], -1,
        function(fam,obj)
    if FLOAT_OBJBYEXTREP<>fail then
        return FLOAT_OBJBYEXTREP(obj);
    fi;
    if obj[1]=0 then
        if obj[2]=0 then
            return 0.0; # 0
        elif obj[2]=1 then
            return 1/(-(1.0/0.0)); # -0
        elif obj[2]=2 then
            return 1.0/0.0; # inf
        elif obj[2]=3 then
            return -1.0/0.0; # -inf
        elif obj[2]=4 then
            return 0.0/0.0; # NaN
        elif obj[2]=5 then
            return -0.0/0.0; # -NaN
        else
            Error("Unknown external float representation ",obj);
        fi;
    fi;
    return LdExp(Float(obj[1]),obj[2]-LogInt(obj[1],2)-1);
end);

InstallMethod( ViewObj, "for floats", [ IsFloat ],
        function ( x )
    Print(ViewString(x));
end);

InstallMethod( Display, "for floats", [ IsFloat ],
        function ( x )
    Print(DisplayString(x));
end);

InstallMethod( PrintObj, "for floats", [ IsFloat ],
        function ( x )
    Print(String(x));
end);

InstallMethod( DisplayString, "for floats", [ IsFloat ], f->Concatenation(String(f),"\n"));

InstallMethod( ViewString, "for floats", [ IsFloat ], String );

InstallMethod( IsPInfinity, "for floats", [ IsFloat ], -1,
        x->x=x+x and x>-x);

InstallMethod( IsNInfinity, "for floats", [ IsFloat ], -1,
        x->x=x+x and x<-x);

InstallMethod( IsXInfinity, "for floats", [ IsFloat ], -1,
        x->x=x+x and x<>-x);

InstallMethod( IsFinite, "for floats", [ IsFloat ], -1,
        x->not IsXInfinity(x) and not IsNaN(x));

InstallMethod( IsNaN, "for floats", [ IsFloat ], -1, # IEEE754, not GAP standard
        x->x<>x+Zero(x));

InstallMethod( EqFloat, "for floats", [ IsFloat, IsFloat ], -1,
        function(x,y)
    return (not IsNaN(x)) and x=y;
end);

InstallMethod( Zero, "for floats", [ IsFloat ], -1,
        function(x)
    return MakeFloat(x,0);
end);

InstallMethod( One, "for floats", [ IsFloat ], -1,
        function(x)
    return MakeFloat(x,1);
end);
#############################################################################
##
#M  Rat( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for macfloats
##
InstallOtherMethod( Rat, "for floats", [ IsFloat ],
        function ( x )

    local  M, a_i, i, sign, maxdenom, maxpartial;

    i := 0; M := [[1,0],[0,1]];
    maxdenom := ValueOption("maxdenom");
    maxpartial := ValueOption("maxpartial");
    if maxpartial=fail then maxpartial := 10000; fi;
    if maxdenom=fail then maxdenom := 10^QuoInt(FLOAT.DECIMAL_DIG,2); fi;

    if x < Zero(x) then sign := -1; x := -x; else sign := 1; fi;
    repeat
      a_i := Int(x);
      if i >= 2 and M[1][1] * a_i > maxpartial then break; fi;
      M := M * [[a_i,1],[1,0]];
      if x = Float(a_i) then break; fi;
      x := 1 / (x - a_i);
      i := i+1;
    until M[2][1] > maxdenom;
    return sign * M[1][1]/M[2][1];
end );

InstallOtherMethod( Rat, "for float intervals", [ IsFloatInterval ],
        function ( x )
    local M, a;

    if x < Zero(x) then
        M := [[-1,0],[0,1]]; x := -x;
    else
        M := [[1,0],[0,1]];
    fi;
    repeat
        a := Int(Sup(x));
        M := M * [[a,1],[1,0]];
        x := x-a;
        if Zero(x) in x then break; fi;
        x := Inverse(x);
    until AbsoluteDiameter(x) >= One(x);
    return M[1][1]/M[2][1];
end);

BindGlobal("CYC_FLOAT_DEGREE", function(x,n,prec)
    local i, m, b, phi;
    
    phi := Phi(n);
    m := IdentityMat(phi+1);
    b := [];
    for i in [1..phi] do
        Add(m[i],Int(LdExp(Cos(FLOAT.2PI*(i-1)/n),prec)));
        Add(m[i],Int(LdExp(Sin(FLOAT.2PI*(i-1)/n),prec)));
        b[i] := E(n)^(i-1);
    od;
    Add(m[phi+1],Int(LdExp(RealPart(x),prec)));
    Add(m[phi+1],Int(LdExp(ImaginaryPart(x),prec)));

    m := First(LLLReducedBasis(m).basis,r->r[phi+1]<>0);

    return -b*m{[1..phi]}/m[phi+1];
end);
    
BindGlobal("CYC_FLOAT", function(x,prec)
    local n, len, e, minlen, minn, mine;
    
    n := 2;
    minlen := infinity;
    repeat
        e := CYC_FLOAT_DEGREE(x,n,prec);
        len := n*Norm(DenominatorCyc(e)*e)^2;
        if len < minlen then
            Info(InfoWarning,2,"Degree ",n,": ",e);
            minlen := len;
            minn := n;
            mine := e;
        fi;
        n := n+1;
    until n > 2*minn+4;
    return mine;
end);

InstallMethod( Cyc, "for floats, degree", [ IsFloat, IsPosInt ], -1,
        function(x,n)
    local prec;
    
    prec := ValueOption("bits");
    if not IsPosInt(prec) then prec := PrecisionFloat(x); fi;
    
    return CYC_FLOAT_DEGREE(x,n,prec);
end);

InstallMethod( Cyc, "for intervals, degree", [ IsFloatInterval, IsPosInt ], -1,
        function(x,n)
    local diam;
    
    diam := AbsoluteDiameter(x);
    if IsZero(diam) then
        return CYC_FLOAT_DEGREE(Mid(x),n,PrecisionFloat(x));
    else
        return CYC_FLOAT_DEGREE(Mid(x),n,1+LogInt(1+Int(Inverse(diam)),2));
    fi;
end);

InstallMethod( Cyc, "for floats", [ IsFloat ], -1,
        function(x)
    local n, len, e, minlen, minn, mine, prec;
    
    prec := ValueOption("bits");
    if not IsPosInt(prec) then prec := PrecisionFloat(x); fi;
    
    return CYC_FLOAT(x,prec);
end);

InstallMethod( Cyc, "for intervals", [ IsFloatInterval ], -1,
        function(x)
    local diam;
    
    diam := AbsoluteDiameter(x);
    if IsZero(diam) then
        return CYC_FLOAT(Mid(x),PrecisionFloat(x));
    else
        return CYC_FLOAT(Mid(x),1+LogInt(1+Int(Inverse(diam)),2));
    fi;
end);

BindGlobal("FLOAT_MINIMALPOLYNOMIAL", function(x,n,ind,prec)
    local z, i, m;
    
    m := IdentityMat(n);
    z := LdExp(One(x),prec);
    for i in [1..n] do
        Add(m[i],Int(RealPart(z)));
        Add(m[i],Int(ImaginaryPart(z)));
        z := z*x;
    od;

    m := LLLReducedBasis(m).basis[1];

    return UnivariatePolynomialByCoefficients(CyclotomicsFamily,m{[n,n-1..1]},ind);
end);

InstallMethod( MinimalPolynomial, "for floats", [ IsRationals, IsFloat, IsPosInt ],
        function(ring,x,ind)
    local n, len, p, lastlen, lastp, prec;
    
    prec := ValueOption("bits");
    if not IsPosInt(prec) then
        prec := PrecisionFloat(x);
        if IsFloatInterval(x) then
            p := AbsoluteDiameter(x);
            if not IsZero(x) then
                prec := 1+LogInt(1+Int(Inverse(p)),2);
            fi;
        fi;
    fi;
    if IsFloatInterval(x) then
        x := Mid(x);
    fi;
    
    n := ValueOption("degree");
    if IsPosInt(n) then
        return FLOAT_MINIMALPOLYNOMIAL(x,n+1,ind,prec);
    fi;
    n := 1;
    len := infinity;
    p := fail;
    repeat
        lastlen := len;
        lastp := p;
        p := FLOAT_MINIMALPOLYNOMIAL(x,n+1,ind,prec);
        len := (CoefficientsOfUnivariatePolynomial(p)^2)^n;
        n := n+1;
    until len > lastlen;
    return lastp;
end);

#############################################################################
##
#M  \<, \+, ... for float and rat
##

# we say that all floateans are after all rationals, to sort them
BindGlobal("COMPARE_FLOAT_ANY", function(x,y)
    local z;
    if IsFloat(x) then z := y; else z := x; fi;
    Error("Comparison of float and ",z," is not supported. Please refer to the manual section on floats for details");
end);

InstallMethod( \<, "for rational and float", [ IsRat, IsFloat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \<, "for float and rational", [ IsFloat, IsRat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \<, "for floats", [ IsFloat, IsFloat ], -1,
        function(x,y) return x < MakeFloat(x,y); end);

InstallMethod( \=, "for rational and float", [ IsRat, IsFloat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \=, "for float and rational", [ IsFloat, IsRat ], -1, COMPARE_FLOAT_ANY );
InstallMethod( \=, "for floats", [ IsFloat, IsFloat ], -1,
        function(x,y) return x = MakeFloat(x,y); end);

InstallMethod( \+, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) + y; end );
InstallMethod( \+, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x + MakeFloat(x,y); end );
InstallMethod( \+, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x + MakeFloat(x,y); end );
        
InstallMethod( \-, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) - y; end );
InstallMethod( \-, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x - MakeFloat(x,y); end );
InstallMethod( \-, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x - MakeFloat(x,y); end );
        
InstallMethod( \*, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) * y; end );
InstallMethod( \*, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x * MakeFloat(x,y); end );
InstallMethod( \*, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x * MakeFloat(x,y); end );

InstallMethod( \/, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) / y; end );
InstallMethod( \/, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return x / MakeFloat(x,y); end );
InstallMethod( \/, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x / MakeFloat(x,y); end );

InstallMethod( LQUO, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return LQUO(MakeFloat(y,x),y); end );
InstallMethod( LQUO, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y ) return LQUO(x,MakeFloat(x,y)); end );
InstallMethod( LQUO, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return LQUO(x,MakeFloat(x,y)); end );

InstallMethod( \^, "for rational and float", ReturnTrue, [ IsRat, IsFloat ], -1,
        function ( x, y ) return MakeFloat(y,x) ^ y; end );
InstallMethod( \^, "for float and rational", ReturnTrue, [ IsFloat, IsRat ], -1,
        function ( x, y )
    if IsInt(y) then TryNextMethod(); fi;
    return x ^ MakeFloat(x,y);
end );
InstallMethod( \^, "for floats", ReturnTrue, [ IsFloat, IsFloat ], -1,
        function ( x, y ) return x ^ MakeFloat(x,y); end );
        
#############################################################################
##
#E
