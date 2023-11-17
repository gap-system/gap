#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Laurent Bartholdi.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with general float functions
##

#############################################################################
##
#C  Floateans
##
DeclareCategory("IsFloat", IsScalar and IsCommutativeElement and IsZDFRE);
DeclareCategory("IsRealFloat", IsFloat);
DeclareCategory("IsFloatInterval", IsFloat and IsCollection);
DeclareCategory("IsComplexFloat", IsFloat);
DeclareCategory("IsComplexFloatInterval", IsComplexFloat and IsFloatInterval);
DeclareCategoryFamily("IsFloat");
DeclareCategoryCollections("IsFloat");
DeclareCategoryCollections("IsFloatCollection");
DeclareConstructor("NewFloat", [IsFloat,IsObject]);
DeclareOperation("MakeFloat", [IsFloat,IsObject]);
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
## <#GAPDoc Label="Float-Math-Commands">
## <ManSection>
##   <Heading>Standard mathematical operations</Heading>
##   <Attr Name="Sin" Arg="f"/>
##   <Attr Name="Cos" Arg="f"/>
##   <Attr Name="Tan" Arg="f"/>
##   <Attr Name="Sec" Arg="f"/>
##   <Attr Name="Csc" Arg="f"/>
##   <Attr Name="Cot" Arg="f"/>
##   <Attr Name="Asin" Arg="f"/>
##   <Attr Name="Acos" Arg="f"/>
##   <Attr Name="Atan" Arg="f"/>
##   <Attr Name="Sinh" Arg="f"/>
##   <Attr Name="Cosh" Arg="f"/>
##   <Attr Name="Tanh" Arg="f"/>
##   <Attr Name="Sech" Arg="f"/>
##   <Attr Name="Csch" Arg="f"/>
##   <Attr Name="Coth" Arg="f"/>
##   <Attr Name="Asinh" Arg="f"/>
##   <Attr Name="Acosh" Arg="f"/>
##   <Attr Name="Atanh" Arg="f"/>
##   <Oper Name="Log" Arg="f"/>
##   <Attr Name="Log2" Arg="f"/>
##   <Attr Name="Log10" Arg="f"/>
##   <Attr Name="Exp" Arg="f"/>
##   <Attr Name="Exp2" Arg="f"/>
##   <Attr Name="Exp10" Arg="f"/>
##   <Attr Name="CubeRoot" Arg="f"/>
##   <Attr Name="Square" Arg="f"/>
##   <Oper Name="Hypothenuse" Arg="x y"/>
##   <Attr Name="Ceil" Arg="f"/>
##   <Attr Name="Floor" Arg="f"/>
##   <Attr Name="Round" Arg="f"/>
##   <Attr Name="Trunc" Arg="f"/>
##   <Attr Name="FrExp" Arg="f"/>
##   <Oper Name="LdExp" Arg="f exp"/>
##   <Attr Name="AbsoluteValue" Arg="f" Label="for floats"/>
##   <Attr Name="Norm" Arg="f" Label="for floats"/>
##   <Attr Name="Frac" Arg="f"/>
##   <Attr Name="Zeta" Arg="f"/>
##   <Attr Name="Gamma" Arg="f"/>
##   <Description>
##     Standard math functions.
##     Functions ending in an integer like <C>Log2</C>, <C>Log10</C>, <C>Exp2</C> and <C>Exp10</C> indicate the base used, in <C>log</C> and <C>exp</C> the natural base is used, i.e. <M>e</M>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("Cos", IsFloat);
DeclareAttribute("Sin", IsFloat);
DeclareAttribute("Tan", IsFloat);
DeclareAttribute("Sec", IsFloat);
DeclareAttribute("Csc", IsFloat);
DeclareAttribute("Cot", IsFloat);
DeclareAttribute("Asin", IsFloat);
DeclareAttribute("Acos", IsFloat);
DeclareAttribute("Atan", IsFloat);
DeclareAttribute("Cosh", IsFloat);
DeclareAttribute("Sinh", IsFloat);
DeclareAttribute("Tanh", IsFloat);
DeclareAttribute("Sech", IsFloat);
DeclareAttribute("Csch", IsFloat);
DeclareAttribute("Coth", IsFloat);
DeclareAttribute("Asinh", IsFloat);
DeclareAttribute("Acosh", IsFloat);
DeclareAttribute("Atanh", IsFloat);
DeclareOperation("Log", [IsFloat]);
DeclareAttribute("Log2", IsFloat);
DeclareAttribute("Log10", IsFloat);
DeclareAttribute("Exp", IsFloat);
DeclareAttribute("Exp2", IsFloat);
DeclareAttribute("Exp10", IsFloat);
DeclareAttribute("CubeRoot", IsFloat);
DeclareAttribute("Square", IsFloat);
DeclareAttribute("Ceil", IsFloat);
DeclareAttribute("Floor", IsFloat);
DeclareAttribute("Round", IsFloat);
DeclareAttribute("Trunc", IsFloat);
DeclareAttribute("FrExp", IsFloat);
DeclareOperation("LdExp", [IsFloat, IsInt]);
DeclareAttribute("AbsoluteValue", IsFloat);
#DeclareAttribute("Norm", IsFloat); # already defined
DeclareOperation("Hypothenuse", [IsFloat, IsFloat]);
DeclareAttribute("Frac", IsFloat);
DeclareAttribute("Zeta", IsFloat);
DeclareAttribute("Gamma", IsFloat);

################################################################
## <#GAPDoc Label="Float-Extra">
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
##   <Attr Name="SignBit" Arg="x"/>
##   <Attr Name="SignFloat" Arg="x"/>
##   <Returns>The sign of <A>x</A>.</Returns>
##   <Description>
##       The first function <C>SignBit</C> returns the sign bit of the
##       floating-point number <A>x</A>: <K>true</K> if <A>x</A> is negative
##       (including <C>-0.</C>) and <K>false</K> otherwise.
##
##       <P/> The second function <C>SignFloat</C> returns the integer
##       <K>-1</K> if <A>x&lt;0</A>, <K>0</K> if <A>x=0</A> and <K>1</K>
##       if <A>x&gt;0</A>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="SinCos" Arg="x"/>
##   <Returns>The list <C>[sin(x), cos(x)]</C>.</Returns>
##   <Description>
##       The function returns a list with <C>sin</C> and <C>cos</C> of <A>x</A>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Atan2" Arg="y x"/>
##   <Returns>The polar angle of <A>(x, y)</A> in the plane as float.</Returns>
##   <Description>
##        Returns the principal value of the argument (polar angle) of <M>(<A>x</A>, <A>y</A>)</M> in the plane.
##        The returned value will always be in <M>(-\pi , \pi]</M> and is not defined on <M>(0,0)</M>.
##        This function is defined in accordance with IEEE 1788-2015 and imported from IEEE 754.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Attr Name="Log1p" Arg="x"/>
##   <Attr Name="Expm1" Arg="x"/>
##   <Returns>The natural logarithm of <M><A>x</A>+1</M> or exponential <M>-1</M> of <A>x</A> respectively.</Returns>
##   <Description>
##       The first function <C>Log1p</C> returns the natural logarithm <M>log(<A>x</A>+1)</M>.
##
##       <P/> The second function <C>Expm1</C> returns the exponential function <M>exp(<A>x</A>)-1</M>
##
##       <P/> These two functions are inverse to each other.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Erf" Arg="x"/>
##   <Returns>The error function given by the Gaussian integral</Returns>
##   <Description>
##        Returns the error function imported from IEEE 754 given by the formula:
##        <Display> Erf(x) := \frac{2}{\sqrt{\pi}} \int_{0}^{x} exp(- t^2 ) dt </Display>
##   </Description>
## </ManSection>
## <#/GAPDoc>
DeclareOperation("EqFloat", [IsFloat, IsFloat]);
DeclareAttribute("PrecisionFloat", IsFloat);
DeclareAttribute("SignBit", IsFloat);
DeclareAttribute("SignFloat", IsFloat);
DeclareAttribute("SinCos", IsFloat);
DeclareOperation("Atan2", [IsFloat, IsFloat]);
DeclareAttribute("Log1p", IsFloat);
DeclareAttribute("Expm1", IsFloat);
DeclareAttribute("Erf", IsFloat);
################################################################

################################################################
##
## <#GAPDoc Label="Float-Infinities">
## <ManSection>
##   <Heading>Infinity testers</Heading>
##   <Prop Name="IsPInfinity" Arg="x"/>
##   <Prop Name="IsNInfinity" Arg="x"/>
##   <Prop Name="IsXInfinity" Arg="x"/>
##   <Prop Name="IsFinite" Arg="x" Label="for floats"/>
##   <Prop Name="IsNaN" Arg="x"/>
##   <Description>
##     Returns <K>true</K> if the floating-point number <A>x</A> is
##     respectively <M>+\infty</M>, <M>-\infty</M>, <M>\pm\infty</M>,
##     finite, or `not a number', such as the result of <C>0.0/0.0</C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareProperty("IsPInfinity", IsFloat);
DeclareProperty("IsNInfinity", IsFloat);
DeclareProperty("IsXInfinity", IsFloat);
DeclareProperty("IsFinite", IsFloat);
DeclareProperty("IsNaN", IsFloat);
################################################################

################################################################
##
## <#GAPDoc Label="Float-Complex">
## <ManSection>
##   <Attr Name="Argument" Arg="z" Label="for complex floats"/>
##   <Description>
##     Returns the argument of the complex number <A>z</A>, namely the value
##     <C>Atan2(ImaginaryPart(z),RealPart(z))</C>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("Argument", IsComplexFloat);
################################################################

################################################################
##
## <#GAPDoc Label="Float-Roots">
## <ManSection>
##   <Func Name="RootsFloat" Arg="p" Label="for a polynomial"/>
##   <Func Name="RootsFloat" Arg="list" Label="for coefficients"/>
##   <Description>
##     Returns the roots of the polynomial <A>p</A>, or of the polynomial
##     given by the list <A>list</A> of its coefficients, with <C>list[i]</C>
##     the coefficient of degree <C>i-1</C>.
##
##    <P/>There is no default implementation of <C>RootsFloat</C> in the
##    &GAP; kernel; these are supplied by packages such as
##    <Package>float</Package>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("RootsFloatOp", [IsList,IsFloat]);
DeclareGlobalFunction("RootsFloat");
################################################################

################################################################
##
## <#GAPDoc Label="Float-Intervals">
## <ManSection>
##   <Attr Name="Sup" Arg="x"/>
##   <Description>
##     Returns the supremum of the interval <A>x</A>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Attr Name="Inf" Arg="x"/>
##   <Description>
##     Returns the infimum of the interval <A>x</A>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Attr Name="Mid" Arg="x"/>
##   <Description>
##     Returns the midpoint of the interval <A>x</A>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Attr Name="AbsoluteDiameter" Arg="x"/>
##   <Oper Name="Diameter" Arg="x"/>
##   <Description>
##     Returns the absolute diameter of the interval <A>x</A>, namely
##     the difference <C>Sup(x)-Inf(x)</C>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Attr Name="RelativeDiameter" Arg="x"/>
##   <Description>
##     Returns the relative diameter of the interval <A>x</A>, namely
##     <C>(Sup(x)-Inf(x))/AbsoluteValue(Min(x))</C>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Oper Name="IsDisjoint" Arg="x1 x2"/>
##   <Description>
##     Returns <K>true</K> if the two intervals <A>x1</A>, <A>x2</A>
##     are disjoint.
##   </Description>
## </ManSection>
## <ManSection>
##   <Oper Name="IsSubset" Arg="x1 x2" Label="for interval floats"/>
##   <Description>
##     Returns <K>true</K> if the interval <A>x1</A> contains <A>x2</A>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Oper Name="IncreaseInterval" Arg="x delta"/>
##   <Description>
##     Returns an interval with same midpoint as <A>x</A> but absolute diameter increased by
##     <A>delta</A>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Oper Name="BlowupInterval" Arg="x ratio"/>
##   <Description>
##     Returns an interval with same midpoint as <A>x</A> but relative diameter increased by
##     <A>ratio</A>.
##   </Description>
## </ManSection>
## <ManSection>
##   <Oper Name="BisectInterval" Arg="x"/>
##   <Description>
##     Returns a list of two intervals whose union equals the interval <A>x</A>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareAttribute("Sup", IsFloatInterval);
DeclareAttribute("Inf", IsFloatInterval);
DeclareAttribute("Mid", IsFloatInterval);
DeclareAttribute("AbsoluteDiameter", IsFloatInterval);
DeclareAttribute("RelativeDiameter", IsFloatInterval);
DeclareOperation("Diameter", [IsFloat]);
DeclareOperation("IsDisjoint", [IsFloatInterval, IsFloatInterval]);
DeclareOperation("IncreaseInterval", [IsFloatInterval, IsFloat]);
DeclareOperation("BlowupInterval", [IsFloatInterval, IsFloat]);
DeclareOperation("BisectInterval", [IsFloatInterval]);
################################################################

#############################################################################
##
#O Constructor
##
## <#GAPDoc Label="Float">
## <ManSection>
##   <Heading>Float creators</Heading>
##   <Func Name="Float" Arg="obj"/>
##   <Constr Name="NewFloat" Arg="filter, obj"/>
##   <Oper Name="MakeFloat" Arg="sample obj, obj"/>
##   <Returns>A new floating-point number, based on <A>obj</A></Returns>
##   <Description>
##     This function creates a new floating-point number.
##
##     <P/> If <A>obj</A> is a rational number, the created number is created
##     with sufficient precision so that the number can (usually) be converted
##     back to the original number (see <Ref Attr="Rat" BookName="ref"/> and
##     <Ref Attr="Rat"/>). For an integer, the precision, if unspecified, is
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
##   <Oper Name="Cyc" Arg="f [degree]" Label="for floats"/>
##   <Returns>A cyclotomic approximation to <A>f</A></Returns>
##   <Description>
##     This command constructs a cyclotomic approximation to the
##     floating-point number <A>f</A>. Of course, it is not guaranteed to
##     return the original rational number <A>f</A> was created from, though
##     it returns the most `reasonable' one given the precision of
##     <A>f</A>. An optional argument <A>degree</A> specifies the maximal
##     degree of the cyclotomic to be constructed.
##
##     <P/> The method used is LLL lattice reduction.
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
DeclareOperation("Cyc", [IsFloat, IsPosInt]);
DeclareOperation("Cyc", [IsFloat]);
#############################################################################

# these variables are read-write
FLOAT := fail; # record holding all float information

# MAX_FLOAT_LITERAL_CACHE_SIZE := 1000; # this could be set to avoid saturating the cache, in case some code evaluates lots of function expressions
