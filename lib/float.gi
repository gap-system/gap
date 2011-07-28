#############################################################################
##
#W  float.gi                       GAP library                   Steve Linton
##                                                          Laurent Bartholdi 
##
#H  @(#)$Id: float.gi,v 4.7 2011/06/20 21:55:23 gap Exp $
##
#Y  Copyright (C) 2011 The GAP Group
##
##  This file deals with floats, and sets up a default interface, within GAP,
##  to deal with floateans.
##

Revision.float_gi :=
  "@(#)$Id: float.gi,v 4.7 2011/06/20 21:55:23 gap Exp $";


MAX_FLOAT_LITERAL_CACHE_SIZE := 0; # cache all float literals by default.

FLOAT_DEFAULT_REP := fail;
FLOAT_STRING := fail;
FLOAT := fail; # holds the constants
BindGlobal("EAGER_FLOAT_LITERAL_CONVERTERS", rec());

InstallGlobalFunction(InstallFloatsHandler, function(arg)
    local i, r;
    if Length(arg)=1 and IsRecord(arg[1]) then
        r := arg[1];
        if IsBound(r.filter) then
            FLOAT_DEFAULT_REP := r.filter;
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
    else
        for i in arg do
            if IsFilter(i) then
                FLOAT_DEFAULT_REP := i;
            elif IsFunction(i) then
                FLOAT_STRING := i;
            else
                Error("Unknown argument to InstallFloatsHandler: ",i);
            fi;
        od;
    fi;
    UNBIND_GLOBAL("FLOAT_LITERAL_CACHE");
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

InstallGlobalFunction(InstallFloatsConstructors, function(arg)
    local filter, float, constants, i;
    
    if IsRecord(arg[1]) then
        filter := arg[1].filter;
    else
        filter := arg[1];
    fi;
    InstallMethod(NewFloat, [filter,IsRat], -1, function(filter,obj)
        return NewFloat(filter,NumeratorRat(obj))/NewFloat(filter,DenominatorRat(obj));
    end);
    
    InstallMethod(NewFloat, [filter,IsCyclotomic], -10, function(filter,obj)
        Error("NewFloat(Cyclotomic): implement using complex roots of unity");
    end);
    
    InstallMethod(NewFloat, [filter,IsList], -1, function(filter,mantexp)
        return NewFloat(filter,mantexp[1])*2^(mantexp[2]-LogInt(mantexp[1],2)-1);
    end);
    
    InstallMethod(NewFloat, [filter,filter], -1, function(filter,obj)
        return obj;
    end);
    
    if IsRecord(arg[1]) and IsBound(arg[1].constants) then
        float := arg[1].constants;
        constants := [["E","2.7182818284590452354"],
                      ["LOG2E", "1.4426950408889634074"],
                      ["LOG10E", "0.43429448190325182765"],
                      ["LN2", "0.69314718055994530942"],
                      ["LN10", "2.30258509299404568402"],
                      ["PI", "3.14159265358979323846"],
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
    if x < 0.0 then return -x; else return x; fi;
end );

InstallMethod( Norm, "for floats", [ IsFloat ], -1,
        function ( x )
    return x*x;
end );

InstallMethod( Argument, "for floats", [ IsFloat ], -1,
        function ( x )
    return 0.0;
end );

InstallMethod( SignFloat, "for floats", [ IsFloat ], -1,
        function ( x )
    if x < 0.0 then return -1; elif x > 0.0 then return 1; else return 0; fi;
end );

InstallMethod( Exp2, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(Log(2.0)*x);
end );

InstallMethod( Exp10, "for floats", [ IsFloat ], -1,
        function ( x )
    return Exp(Log(10.0)*x);
end );

InstallMethod( Log2, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(x) / Log(2.0);
end );

InstallMethod( Log10, "for floats", [ IsFloat ], -1,
        function ( x )
    return Log(x) / Log(10.0);
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
    if x>0.0 then
        return Exp(Log(x)/3.0);
    elif x=0.0 then
        return 0.0;
    else
        return -Exp(Log(-x)/3.0);
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
    return Floor(x+0.5);
end );

InstallMethod( Trunc, "for floats", [ IsFloat ], -1,
        function ( x )
    if x>0.0 then
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
    if obj=0.0 then return [0,0]; fi;
    if obj>0.0 then s := 1; else s := -1; obj := -obj; fi;
    e := Int(Log2(obj))+1;
    m := obj/2^e;
    while m<>Int(m) do m := m*2.0; od;
    return [Int(m),e];
end);

InstallMethod( LdExp, "for floats", [ IsFloat, IsInt ], -1,
        function(m,e)
    return m*2^e;
end);
    
InstallMethod( ExtRepOfObj, "for floats", [ IsFloat ], -1,
        function(obj)
    local p, v, i, sgn;
    p := FrExp(obj);
    v := p[1];
    while v mod 1.0 <> 0.0 do v := 2.0*v; od;
    p[1] := Int(v);
    return p;
end);
    
InstallMethod( ObjByExtRep, "for floats", [ IsFloatFamily, IsList ], -1,
        function(fam,obj)
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
        x->x>FLOAT.MAX);

InstallMethod( IsNInfinity, "for floats", [ IsFloat ], -1,
        x->x<-FLOAT.MAX);

InstallMethod( IsXInfinity, "for floats", [ IsFloat ], -1,
        x->x<-FLOAT.MAX or x>FLOAT.MAX);

InstallMethod( IsFinite, "for floats", [ IsFloat ], -1,
        x->x>=-FLOAT.MAX and x<=FLOAT.MAX);

InstallMethod( IsNaN, "for floats", [ IsFloat ], -1,
        x->x<>x+0.0);

#############################################################################
##
#M  Rat( x ) . . . . . . . . . . . . . . . . . . . . . . . . . . . for macfloats
##
InstallOtherMethod( Rat, "for macfloats", [ IsFloat ],
        function ( x )

    local  M, a_i, i, sign, maxdenom, maxpartial;

    i := 0; M := [[1,0],[0,1]];
    maxdenom := ValueOption("maxdenom");
    maxpartial := ValueOption("maxpartial");
    if maxpartial=fail then maxpartial := 10000; fi;
    if maxdenom=fail then maxdenom := 10^FLOAT.DECIMAL_DIG; fi;

    if x < 0.0 then sign := -1; x := -x; else sign := 1; fi;
    repeat
      a_i := Int(x);
      if i > 0 and M[1][1] * a_i > maxpartial then break; fi;
      M := M * [[a_i,1],[1,0]];
      if x = Float(a_i) then break; fi;
      x := 1.0 / (x - a_i);
      i := i+1;
    until M[2][1] > maxdenom;
    return sign * M[1][1]/M[2][1];
end );

#############################################################################
##
#M  \<, \+, ... for float and rat
##

# we say that all floateans are after all rationals, to sort them
InstallMethod( \<, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y )
    Info(InfoWarning, 1, "Potentially dangerous comparison of rational and float");
    return true;
    return Float(x) < y;
end );
InstallMethod( \<, "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
        function ( x, y )
    Info(InfoWarning, 1, "Potentially dangerous comparison of float and rational");
    return false;
    return x < Float(y);
end );
InstallMethod( \=, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y )
    Info(InfoWarning, 1, "Potentially dangerous comparison of rational and float");
    return false;
    return Float(x) = y;
end);
InstallMethod( \=, "for float and rational", ReturnTrue, [ IsFloat, IsCyc ],
        function ( x, y )
    Info(InfoWarning, 1, "Potentially dangerous comparison of float and rational");
    return false;
    return x = Float(y);
end);
InstallMethod( \+, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y ) return Float(x) + y; end );
InstallMethod( \+, "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
        function ( x, y ) return x + Float(y); end );
InstallMethod( \-, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y ) return Float(x) - y; end );
InstallMethod( \-, "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
        function ( x, y ) return x - Float(y); end );
InstallMethod( \*, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y ) return Float(x) * y; end );
InstallMethod( \*, "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
        function ( x, y ) return x * Float(y); end );
InstallMethod( \/, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y ) return Float(x) / y; end );
InstallMethod( \/, "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
        function ( x, y ) return x / Float(y); end );
InstallMethod( LQUO, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y ) return LQUO(Float(x),y); end );
InstallMethod( LQUO, "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
        function ( x, y ) return LQUO(x,Float(y)); end );
InstallMethod( \^, "for rational and float", ReturnTrue, [ IsRat, IsFloat ],
        function ( x, y ) return Float(x) ^ y; end );
InstallMethod( \^, "for float and rational", ReturnTrue, [ IsFloat, IsRat ],
        function ( x, y ) return x ^ Float(y); end );
        
# install the default floateans
InstallFloatsHandler(IEEE754FLOAT);
InstallFloatsConstructors(IEEE754FLOAT);
        
#############################################################################
##
#E
