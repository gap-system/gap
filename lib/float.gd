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
## <#GAPDoc Label="FLOAT_UNARY">
## <ManSection>
##   <Heading>Mathematical operations</Heading>
##   <Attr Name="Cos" Arg="x"/>
##   <Attr Name="Sin" Arg="x"/>
##   <Attr Name="SinCos" Arg="x"/>
##   <Attr Name="Tan" Arg="x"/>
##   <Attr Name="Sec" Arg="x"/>
##   <Attr Name="Csc" Arg="x"/>
##   <Attr Name="Cot" Arg="x"/>
##   <Attr Name="Asin" Arg="x"/>
##   <Attr Name="Acos" Arg="x"/>
##   <Attr Name="Atan" Arg="x"/>
##   <Oper Name="Atan2" Arg="y x"/>
##   <Attr Name="Cosh" Arg="x"/>
##   <Attr Name="Sinh" Arg="x"/>
##   <Attr Name="Tanh" Arg="x"/>
##   <Attr Name="Sech" Arg="x"/>
##   <Attr Name="Csch" Arg="x"/>
##   <Attr Name="Coth" Arg="x"/>
##   <Attr Name="Asinh" Arg="x"/>
##   <Attr Name="Acosh" Arg="x"/>
##   <Attr Name="Atanh" Arg="x"/>
##   <Oper Name="Log" Arg="x"/>
##   <Attr Name="Log2" Arg="x"/>
##   <Attr Name="Log10" Arg="x"/>
##   <Attr Name="Log1p" Arg="x"/>
##   <Attr Name="Exp" Arg="x"/>
##   <Attr Name="Exp2" Arg="x"/>
##   <Attr Name="Exp10" Arg="x"/>
##   <Attr Name="Expm1" Arg="x"/>
##   <Attr Name="CubeRoot" Arg="x"/>
##   <Attr Name="Square" Arg="x"/>
##   <Oper Name="Hypothenuse" Arg="x y"/>
##   <Attr Name="Ceil" Arg="x"/>
##   <Attr Name="Floor" Arg="x"/>
##   <Attr Name="Round" Arg="x"/>
##   <Attr Name="Trunc" Arg="x"/>
##   <Attr Name="Frac" Arg="x"/>
##   <Attr Name="SignFloat" Arg="x"/>
##   <Attr Name="Argument" Arg="x" Label="for complex numbers" />
##   <Attr Name="Erf" Arg="x"/>
##   <Attr Name="Zeta" Arg="x"/>
##   <Attr Name="Gamma" Arg="x"/>
##   <Attr Name="ComplexI" Arg="x"/>
##   <Description>
##     Usual mathematical functions.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="EqFloat" Arg="x y"/>
##   <Returns>Whether the floateans <A>x</A> and <A>y</A> are equal</Returns>
##   <Description>
##     This function compares two floating-point numbers, and returns
##     <K>true</K> if they are equal, and <K>false</K> otherwise; with the
##     exception that <K>NaN</K> is always considered to be different from
##     itself.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="PrecisionFloat" Arg="x"/>
##   <Returns>The precision of <A>x</A></Returns>
##   <Description>
##     This function returns the precision, counted in number of binary digits,
##     of the floating-point number <A>x</A>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Heading>Interval operations</Heading>
##   <Attr Name="Sup" Arg="interval"/>
##   <Attr Name="Inf" Arg="interval"/>
##   <Attr Name="Mid" Arg="interval"/>
##   <Attr Name="AbsoluteDiameter" Arg="interval"/>
##   <Attr Name="RelativeDiameter" Arg="interval"/>
##   <Oper Name="Overlaps" Arg="interval1 interval2"/>
##   <Oper Name="IsDisjoint" Arg="interval1 interval2"/>
##   <Oper Name="IncreaseInterval" Arg="interval delta"/>
##   <Oper Name="BlowupInterval" Arg="interval ratio"/>
##   <Oper Name="BisectInterval" Arg="interval"/>
##   <Description>
##     Most are self-explanatory.
##     <C>BlowupInterval</C> returns an interval with same midpoint but 
##     relative diameter increased by <A>ratio</A>; <C>IncreaseInterval</C>
##     returns an interval with same midpoint but absolute diameter increased
##     by <A>delta</A>; <C>BisectInterval</C> returns a list of two intervals
##     whose union equals <A>interval</A>.
##   </Description>  
## </ManSection>
##
## <ManSection>
##   <Prop Name="IsPInfinity" Arg="x"/>
##   <Prop Name="IsNInfinity" Arg="x"/>
##   <Prop Name="IsXInfinity" Arg="x"/>
##   <Prop Name="IsFinite" Arg="x" Label="float"/>
##   <Prop Name="IsNaN" Arg="x"/>
##   <Description>
##     Returns <K>true</K> if the floating-point number <A>x</A> is
##     respectively <M>+\infty</M>, <M>-\infty</M>, <M>\pm\infty</M>,
##     finite, or `not a number', such as the result of <C>0.0/0.0</C>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Var Name="FLOAT" Label="constants"/>
##   <Description>
##     This record contains useful floating-point constants: <List>
##     <Mark>DECIMAL_DIG</Mark> <Item>Maximal number of useful digits;</Item>
##     <Mark>DIG</Mark> <Item>Number of significant digits;</Item>
##     <Mark>VIEW_DIG</Mark> <Item>Number of digits to print in short view;</Item>
##     <Mark>EPSILON</Mark> <Item>Smallest number such that <M>1\neq1+\epsilon</M>;</Item>
##     <Mark>MANT_DIG</Mark> <Item>Number of bits in the mantissa;</Item>
##     <Mark>MAX</Mark> <Item>Maximal representable number;</Item>
##     <Mark>MAX_10_EXP</Mark> <Item>Maximal decimal exponent;</Item>
##     <Mark>MAX_EXP</Mark> <Item>Maximal binary exponent;</Item>
##     <Mark>MIN</Mark> <Item>Minimal positive representable number;</Item>
##     <Mark>MIN_10_EXP</Mark> <Item>Minimal decimal exponent;</Item>
##     <Mark>MIN_EXP</Mark> <Item>Minimal exponent;</Item>
##     <Mark>INFINITY</Mark> <Item>Positive infinity;</Item>
##     <Mark>NINFINITY</Mark> <Item>Negative infinity;</Item>
##     <Mark>NAN</Mark> <Item>Not-a-number,</Item>
##     </List>
##     as well as mathematical constants <C>E</C>, <C>LOG2E</C>, <C>LOG10E</C>,
##     <C>LN2</C>, <C>LN10</C>, <C>PI</C>, <C>PI_2</C>, <C>PI_4</C>,
##     <C>1_PI</C>, <C>2_PI</C>, <C>2_SQRTPI</C>, <C>SQRT2</C>, <C>SQRT1_2</C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
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
