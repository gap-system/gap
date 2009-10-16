#############################################################################
##
#W  float.gd                       GAP library              Laurent Bartholdi
##
#H  @(#)$Id: float.gd,v 1.1 2008/06/14 15:45:40 gap Exp $
##
#Y  Copyright (C) 2008 Laurent Bartholdi
##
##  This file deals with general float functions
##
Revision.float_gd :=
  "@(#)$Id: float.gd,v 1.1 2008/06/14 15:45:40 gap Exp $";

#############################################################################
##
#C  Floateans
##
DeclareCategory("IsFloat", IsScalar and IsCommutativeElement);
#############################################################################

#############################################################################
##
#O Unary operations
##
## <#GAPDoc Label="AINV">
## <ManSection>
##   <Oper Name="Cos" Arg="x"/>
##   <Oper Name="Sin" Arg="x"/>
##   <Oper Name="Tan" Arg="x"/>
##   <Oper Name="Sec" Arg="x"/>
##   <Oper Name="Csc" Arg="x"/>
##   <Oper Name="Cot" Arg="x"/>
##   <Oper Name="Asin" Arg="x"/>
##   <Oper Name="Acos" Arg="x"/>
##   <Oper Name="Atan" Arg="x"/>
##   <Oper Name="Atan2" Arg="x y"/>
##   <Oper Name="Cosh" Arg="x"/>
##   <Oper Name="Sinh" Arg="x"/>
##   <Oper Name="Tanh" Arg="x"/>
##   <Oper Name="Sech" Arg="x"/>
##   <Oper Name="Csch" Arg="x"/>
##   <Oper Name="Coth" Arg="x"/>
##   <Oper Name="Asinh" Arg="x"/>
##   <Oper Name="Acosh" Arg="x"/>
##   <Oper Name="Atanh" Arg="x"/>
##   <Oper Name="Log" Arg="x"/>
##   <Oper Name="Log2" Arg="x"/>
##   <Oper Name="Log10" Arg="x"/>
##   <Oper Name="Exp" Arg="x"/>
##   <Oper Name="Exp2" Arg="x"/>
##   <Oper Name="Exp10" Arg="x"/>
##   <Oper Name="Cuberoot" Arg="x"/>
##   <Oper Name="Square" Arg="x"/>
##   <Oper Name="Ceil" Arg="x"/>
##   <Oper Name="Floor" Arg="x"/>
##   <Oper Name="Round" Arg="x"/>
##   <Oper Name="Trunc" Arg="x"/>
##   <Oper Name="SignFloat" Arg="x"/>
##   <Description>
##     Usual mathematical functions.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="PrecisionFloat" Arg="x"/>
##   <Returns>The precision of <A>x</A></Returns>
##   <Description>
##     This function returns the precision, counted in number of bits,
##     of the floating-point number <A>x</A>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("Cos",[IsFloat]);
DeclareOperation("Sin",[IsFloat]);
DeclareOperation("Tan",[IsFloat]);
DeclareOperation("Sec",[IsFloat]);
DeclareOperation("Csc",[IsFloat]);
DeclareOperation("Cot",[IsFloat]);
DeclareOperation("Asin",[IsFloat]);
DeclareOperation("Acos",[IsFloat]);
DeclareOperation("Atan",[IsFloat]);
DeclareOperation("Cosh",[IsFloat]);
DeclareOperation("Sinh",[IsFloat]);
DeclareOperation("Tanh",[IsFloat]);
DeclareOperation("Sech",[IsFloat]);
DeclareOperation("Csch",[IsFloat]);
DeclareOperation("Coth",[IsFloat]);
DeclareOperation("Asinh",[IsFloat]);
DeclareOperation("Acosh",[IsFloat]);
DeclareOperation("Atanh",[IsFloat]);
DeclareOperation("Log",[IsFloat]);
DeclareOperation("Log2",[IsFloat]);
DeclareOperation("Log10",[IsFloat]);
DeclareOperation("Exp",[IsFloat]);
DeclareOperation("Exp2",[IsFloat]);
DeclareOperation("Exp10",[IsFloat]);
DeclareOperation("CubeRoot",[IsFloat]);
DeclareOperation("Square",[IsFloat]);
DeclareOperation("Ceil",[IsFloat]);
DeclareOperation("Floor",[IsFloat]);
DeclareOperation("Round",[IsFloat]);
DeclareOperation("Trunc",[IsFloat]);
DeclareOperation("Atan2", [IsFloat,IsFloat]);
  
DeclareOperation("PrecisionFloat",[IsFloat]);
DeclareOperation("SignFloat",[IsFloat]);
#############################################################################

#############################################################################
##
#O Constructor
##
## <#GAPDoc Label="Float">
## <ManSection>
##   <Oper Name="NewFloat" Arg="obj"/>
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
##   <Oper Name="Rat" Arg="f"/>
##   <Oper Name="Rat" Arg="f, max"/>
##   <Returns>A rational approximation to <A>f</A></Returns>
##   <Description>
##     This command constructs a rational approximation to the
##     floating-point number <A>f</A>. Of course, it is not guaranteed to
##     return the original rational number <A>f</A> was created from, though
##     it returns the most `reasonable' one given the precision of
##     <A>f</A>.
##
##     <P/> If used with a second argument <A>max</A>, the rational returned is
##     the first one with denominator at least <A>max</A>.
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
DeclareOperation("SelectFloat", [IsRecord]);
#############################################################################

#############################################################################
##
#E
