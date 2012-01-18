#############################################################################
##
#W  cxsc.gi                        GAP library              Laurent Bartholdi
##
#H  @(#)$Id: polynomial.gi,v 1.6 2012/01/17 10:57:03 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file implements polynomials over floats
##
Revision.float.polynomial_gi :=
  "@(#)$Id: polynomial.gi,v 1.6 2012/01/17 10:57:03 gap Exp $";

################################################################
# create generic 0 and 1
################################################################
DeclareCategory("IsFloatConstant", IsFloat and IsAttributeStoringRep);

BindGlobal("FLOAT_0", Objectify(NewType(FloatsFamily, IsFloatConstant and IsZero),rec()));
SetIsOne(FLOAT_0,false);
SetString(FLOAT_0,"0");
BindGlobal("FLOAT_1", Objectify(NewType(FloatsFamily, IsFloatConstant and IsOne),rec()));
SetIsZero(FLOAT_1,false);
SetString(FLOAT_1,"1");
SetZero(FLOAT_0,FLOAT_0);
SetZero(FLOAT_1,FLOAT_0);
SetOne(FLOAT_0,FLOAT_1);
SetOne(FLOAT_1,FLOAT_1);
InstallMethod(AINV, [IsFloatConstant and IsZero], x->x);
InstallMethod(AINV, [IsFloatConstant and IsOne], x->-1.0);
InstallMethod(AINV_MUT, [IsFloatConstant and IsZero], x->x);
InstallMethod(AINV_MUT, [IsFloatConstant and IsOne], x->-1.0);
InstallMethod(EQ, [IsFloat,IsFloatConstant and IsZero],
        function(x,y) return IsZero(x); end);
InstallMethod(EQ, [IsFloat,IsFloatConstant and IsOne],
        function(x,y) return IsOne(x); end);
InstallMethod(EQ, [IsFloatConstant and IsZero,IsFloat],
        function(x,y) return IsZero(y); end);
InstallMethod(EQ, [IsFloatConstant and IsOne,IsFloat],
        function(x,y) return IsOne(y); end);
InstallMethod(PROD, [IsFloatConstant and IsZero,IsFloat],1,
        function(x,y) return Zero(y); end);
InstallMethod(PROD, [IsFloatConstant and IsOne,IsFloat],
        function(x,y) return y; end);
InstallMethod(PROD, [IsFloat,IsFloatConstant and IsZero],1,
        function(x,y) return Zero(x); end);
InstallMethod(PROD, [IsFloat,IsFloatConstant and IsOne],
        function(x,y) return x; end);
InstallMethod(SUM, [IsFloatConstant and IsZero,IsFloat],
        function(x,y) return y; end);
InstallMethod(SUM, [IsFloat,IsFloatConstant and IsZero],
        function(x,y) return x; end);
InstallMethod(SUM, [IsFloatConstant and IsOne,IsFloat],
        function(x,y) return y+1.0; end);
InstallMethod(SUM, [IsFloat,IsFloatConstant and IsOne],
        function(x,y) return x+1.0; end);
InstallMethod(SUM, [IsFloatConstant and IsOne,IsFloatConstant and IsOne],
        function(x,y) return 2.0; end);
InstallMethod(DIFF, [IsFloatConstant and IsZero,IsFloat],
        function(x,y) return -y; end);
InstallMethod(DIFF, [IsFloat,IsFloatConstant and IsZero],
        function(x,y) return x; end);
InstallMethod(DIFF, [IsFloatConstant and IsOne,IsFloat],
        function(x,y) return 1.0-y; end);
InstallMethod(DIFF, [IsFloat,IsFloatConstant and IsOne],
        function(x,y) return x-1.0; end);
InstallMethod(DIFF, [IsFloatConstant and IsOne,IsFloatConstant and IsOne],
        function(x,y) return FLOAT_0; end);
InstallMethod(QUO, [IsFloatConstant and IsOne,IsFloat],
        function(x,y) return Inverse(y); end);
InstallMethod(QUO, [IsFloatConstant and IsZero,IsFloat and IsZero],
        function(x,y) return y/y; end);
InstallMethod(QUO, [IsFloatConstant and IsZero,IsFloatConstant and IsZero],
        function(x,y) return FLOAT.NAN; end);
InstallMethod(QUO, [IsFloatConstant and IsZero,IsFloat],
        function(x,y) return x; end);
InstallMethod(QUO, [IsFloat,IsFloatConstant and IsOne],
        function(x,y) return x; end);
InstallMethod(QUO, "xx", [IsFloat,IsFloatConstant and IsZero],
        function(x,y) return x/Zero(x); end);

InstallMethod(PROD, [IsFloatConstant and IsZero,IsRat],1,
        function(x,y) return 0.0; end);
InstallMethod(PROD, [IsFloatConstant and IsOne,IsRat],
        function(x,y) return Float(y); end);
InstallMethod(PROD, [IsRat,IsFloatConstant and IsZero],1,
        function(x,y) return 0.0; end);
InstallMethod(PROD, [IsRat,IsFloatConstant and IsOne],
        function(x,y) return Float(x); end);
InstallMethod(SUM, [IsFloatConstant and IsZero,IsRat],
        function(x,y) return Float(y); end);
InstallMethod(SUM, [IsRat,IsFloatConstant and IsZero],
        function(x,y) return Float(x); end);
        
InstallOtherMethod(NewFloat, [IsIEEE754FloatRep,IsFloatConstant and IsZero],
        function(filt,x) return NewFloat(filt,0); end);
InstallOtherMethod(NewFloat, [IsIEEE754FloatRep,IsFloatConstant and IsOne],
        function(filt,x) return NewFloat(filt,1); end);
        
SetIsUFDFamily(FloatsFamily,true);
SetZero(FloatsFamily, FLOAT_0);
SetOne(FloatsFamily, FLOAT_1);

################################################################
# domains
################################################################
BindGlobal("FLOAT_PSEUDOFIELD",
        Objectify(NewType(CollectionsFamily(FloatsFamily),
                IsFloatPseudoField and IsAttributeStoringRep),rec()));
SetName(FLOAT_PSEUDOFIELD, FLOAT_REAL_STRING);

SetLeftActingDomain(FLOAT_PSEUDOFIELD,Rationals);
SetCharacteristic(FLOAT_PSEUDOFIELD,0);
SetDimension(FLOAT_PSEUDOFIELD,infinity);
SetSize(FLOAT_PSEUDOFIELD,infinity);
SetIsWholeFamily(FLOAT_PSEUDOFIELD,true);

################################################################
# zeros
################################################################
InstallMethod(FloatCoefficientsOfUnivariatePolynomial, [IsUnivariatePolynomial],
        function(p)
    local model, i, l;
    
    l := CoefficientsOfUnivariatePolynomial(p);
    if ForAny(l,IsFloatConstant) then
        model := First(l,x->not IsFloatConstant(x));
        if model=fail then model := 0.0; fi;
        l := ShallowCopy(l);
        for i in [1..Length(l)] do
            if IsFloatConstant(l[i]) then
                if IsOne(l[i]) then
                    l[i] := One(model);
                elif IsZero(l[i]) then
                    l[i] := Zero(model);
                fi;
            fi;
        od;
    fi;
    return l;
end);

InstallGlobalFunction(RootsFloat, function(arg)
    local l;
    if Length(arg)=1 and IsList(arg[1]) then
        l := arg[1];
    elif ForAll(arg,IsFloat) then
        l := arg;
    elif Length(arg)=1 and IsUnivariatePolynomial(arg[1]) then
        l := FloatCoefficientsOfUnivariatePolynomial(arg[1]);
    else
        Error("RootsFloat: expected coefficients, a list of coefficients, or a polynomial, not ",arg);
    fi;
    if Length(l)=0 then return []; fi;
    return RootsFloatOp(l,l[1]);
end);


#############################################################################
##
#E
