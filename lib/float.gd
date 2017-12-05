#############################################################################
##
#W  float.gd                       GAP library              Laurent Bartholdi
##
##
#Y  Copyright (C) 2011 Laurent Bartholdi
##
##  This file deals with general float functions
##

#############################################################################
##
#C  Floateans
##
DeclareCategory("IsFloat", IsScalar and IsCommutativeElement and IsZDFRE);
DeclareCategory("IsFloatInterval", IsFloat and IsCollection);
DeclareCategory("IsComplexFloat", IsFloat);
DeclareCategory("IsComplexFloatInterval", IsComplexFloat and IsFloatInterval);
DeclareCategoryFamily("IsFloat");
DeclareCategoryCollections("IsFloat");
DeclareCategoryCollections("IsFloatCollection");
DeclareConstructor("NewFloat",[IsFloat,IsObject]);
DeclareOperation("MakeFloat",[IsFloat,IsObject]);
#############################################################################

BindGlobal("DECLAREFLOATCREATOR", function(arg)
    DeclareConstructor("NewFloat",arg);
    DeclareOperation("MakeFloat",arg);
end);

BindGlobal("INSTALLFLOATCREATOR", function(arg)
    if Length(arg)=3 then
        InstallMethod(NewFloat,arg[1],arg[2],arg[3]);
        InstallMethod(MakeFloat,arg[1],arg[2],arg[3]);
    elif Length(arg)=4 then
        InstallMethod(NewFloat,arg[1],arg[2],arg[3],arg[4]);
        InstallMethod(MakeFloat,arg[1],arg[2],arg[3],arg[4]);
    else
        Error("INSTALLFLOATCREATOR only coded for 3-argument or 4-argument version");
    fi;        
end);

#############################################################################
##
#O Unary operations
##
DeclareAttribute("Cos",IsFloat);
DeclareAttribute("Sin",IsFloat);
DeclareAttribute("Tan",IsFloat);
DeclareAttribute("Sec",IsFloat);
DeclareAttribute("Csc",IsFloat);
DeclareAttribute("Cot",IsFloat);
DeclareAttribute("Asin",IsFloat);
DeclareAttribute("Acos",IsFloat);
DeclareAttribute("Atan",IsFloat);
DeclareAttribute("Cosh",IsFloat);
DeclareAttribute("Sinh",IsFloat);
DeclareAttribute("Tanh",IsFloat);
DeclareAttribute("Sech",IsFloat);
DeclareAttribute("Csch",IsFloat);
DeclareAttribute("Coth",IsFloat);
DeclareAttribute("Asinh",IsFloat);
DeclareAttribute("Acosh",IsFloat);
DeclareAttribute("Atanh",IsFloat);
DeclareOperation("Log",[IsFloat]);
DeclareAttribute("Log2",IsFloat);
DeclareAttribute("Log10",IsFloat);
DeclareAttribute("Log1p",IsFloat);
DeclareAttribute("Exp",IsFloat);
DeclareAttribute("Exp2",IsFloat);
DeclareAttribute("Exp10",IsFloat);
DeclareAttribute("Expm1",IsFloat);
DeclareAttribute("CubeRoot",IsFloat);
DeclareAttribute("Square",IsFloat);
DeclareAttribute("Ceil",IsFloat);
DeclareAttribute("Floor",IsFloat);
DeclareAttribute("Round",IsFloat);
DeclareAttribute("Trunc",IsFloat);
DeclareOperation("Atan2", [IsFloat,IsFloat]);
DeclareAttribute("FrExp", IsFloat);
DeclareOperation("LdExp", [IsFloat,IsInt]);
DeclareAttribute("Argument", IsFloat);
DeclareAttribute("AbsoluteValue", IsFloat);
#DeclareAttribute("Norm", IsFloat); #already defined
DeclareOperation("Hypothenuse", [IsFloat,IsFloat]);
DeclareAttribute("Frac",IsFloat);
DeclareAttribute("SinCos",IsFloat);
DeclareAttribute("Erf",IsFloat);
DeclareAttribute("Zeta",IsFloat);
DeclareAttribute("Gamma",IsFloat);
DeclareAttribute("ComplexI",IsFloat);

DeclareAttribute("PrecisionFloat",IsFloat);
DeclareAttribute("SignFloat",IsFloat);

DeclareAttribute("Sup", IsFloat);
DeclareAttribute("Inf", IsFloat);
DeclareAttribute("Mid", IsFloat);
DeclareAttribute("AbsoluteDiameter", IsFloat);
DeclareAttribute("RelativeDiameter", IsFloat);
#DeclareOperation("Diameter", IsFloat);
DeclareOperation("Overlaps", [IsFloat,IsFloat]);
DeclareOperation("IsDisjoint", [IsFloat,IsFloat]);
DeclareOperation("EqFloat", [IsFloat,IsFloat]);
DeclareOperation("IncreaseInterval", [IsFloat,IsFloat]);
DeclareOperation("BlowupInterval", [IsFloat,IsFloat]);
DeclareOperation("BisectInterval", [IsFloat,IsFloat]);

DeclareProperty("IsPInfinity", IsFloat);
DeclareProperty("IsNInfinity", IsFloat);
DeclareProperty("IsXInfinity", IsFloat);
DeclareProperty("IsFinite", IsFloat);
DeclareProperty("IsNaN", IsFloat);
#############################################################################

#############################################################################
# roots
#############################################################################
#! document (LB)
#############################################################################

#############################################################################
##
#O Constructor
##
## <#GAPDoc Label="Float">
## <ManSection>
##   <Func Name="Float" Arg="obj"/>
##   <Oper Name="NewFloat" Arg="filter, obj"/>
##   <Oper Name="MakeFloat" Arg="sample obj, obj"/>
##   <Returns>A new floating-point number, based on <A>obj</A></Returns>
##   <Description>
##     This function creates a new floating-point number.
##
##     <P/> If <A>obj</A> is a rational number, the created number is created
##     with sufficient precision so that the number can (usually) be converted
##     back to the original number (see <Ref Oper="Rat" BookName="ref"/> and
##     <Ref Oper="Rat"/>). For an integer, the precision, if unspecified, is
##     chosen sufficient so that <C>Int(Float(obj))=obj</C> always holds, but
##     at least 64 bits.
##
##     <P/> <A>obj</A> may also be a string, which may be of the form
##     <C>"3.14e0"</C> or <C>".314e1"</C> or <C>".314@1"</C> etc.
##
##     <P/> An option may be passed to specify, it bits, a desired precision.
##     The format is <C>Float("3.14":PrecisionFloat:=1000)</C> to create
##     a 1000-bit approximation of <M>3.14</M>.
##
##     <P/> In particular, if <A>obj</A> is already a floating-point number,
##     then <C>Float(obj:PrecisionFloat:=prec)</C> creates a copy of
##     <A>obj</A> with a new precision.
##     prec
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="Rat" Arg="f" Label="for floats"/>
##   <Returns>A rational approximation to <A>f</A></Returns>
##   <Description>
##     This command constructs a rational approximation to the
##     floating-point number <A>f</A>. Of course, it is not guaranteed to
##     return the original rational number <A>f</A> was created from, though
##     it returns the most `reasonable' one given the precision of
##     <A>f</A>.
##
##     <P/> Two options control the precision of the rational approximation:
##     In the form <C>Rat(f:maxdenom:=md,maxpartial:=mp)</C>, the rational
##     returned is such that the denominator is at most <A>md</A> and the
##     partials in its continued fraction expansion are at most <A>mp</A>.
##     The default values are <C>maxpartial:=10000</C> and
##     <C>maxdenom:=2^(precision/2)</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="SetFloats" Arg="rec [bits] [install]"/>
##   <Description>
##     Installs a new interface to floating-point numbers in &GAP;, optionally
##     with a desired precision <A>bits</A> in binary digits. The last
##     optional argument <A>install</A> is a boolean value; if false, it
##     only installs the eager handler and the precision for the floateans,
##     without making them the default.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("Float");
DeclareGlobalFunction("SetFloats");
#############################################################################

DeclareOperation("Cyc", [IsFloat, IsPosInt]);
DeclareOperation("Cyc", [IsFloat]);

# these variables are read-write
FLOAT := fail; # record holding all float information

# MAX_FLOAT_LITERAL_CACHE_SIZE := 1000; # this could be set to avoid saturating the cache, in case some code evaluates lots of function expressions

#############################################################################
##
#E
