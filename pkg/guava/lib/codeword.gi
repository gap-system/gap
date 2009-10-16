#############################################################################
##
#A  codeword.gi             GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains functions for working with codewords
##  Codeword is a record with the following field:
##  !.treatAsPoly
##
##  Codeword can have the following attributes: 
##	VectorCodeword
##	PolyCodeword 
##	Weight 
##	WordLength 
##	Support 
## 	
#H  @(#)$Id: codeword.gi,v 1.11 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codeword_gi") :=
    "@(#)$Id: codeword.gi,v 1.11 2004/12/20 21:26:06 gap Exp $";

DeclareRepresentation("IsCodewordRep", 
			    IsAttributeStoringRep and IsComponentObjectRep, 
			    ["treatAsPoly"]);

BindGlobal("CodewordFamily",
        NewFamily("CodewordFamily", IsCodeword,IsCodeword and IsCodewordRep)); 

BindGlobal("CodewordType",NewType(CodewordFamily, IsCodeword ));


# Function to objectify codeword using input 
# vector, length, and field or ffe 
MakeCodeword := function(vec, n, F) 
	local v;
	if Length(vec) > n then 
		vec := vec{[1..n]};
    elif Length(vec) < n then 
		vec := Concatenation(vec, [1..n-Length(vec)]*Zero(F)); 
    fi;
	vec := vec * One(F);
	v := Objectify(CodewordType, rec());
	SetVectorCodeword(v, vec);
	SetWordLength(v, n);
	return v;
end;


## Function to select an appropriate field based on contents of list. 
SelectField := function(list) 
	local f;
	f := Maximum(list) + 1;
	while not IsPrimePowerInt(f) do 
		f := f + 1;
	od;
	return GF(f);
end;

#############################################################################
##
#F  Codeword( <list> [, <F>] or . . . . . . . . . . . .  creates new codeword
#F  Codeword( <P> [, <n>] [, <F>] ) . . . . . . . . . . . . . . . . . . . . .
##  Codeword( <P>, Code)  . . . . . . . . . . . . . . . . . . . . . . . . . . 
##

InstallMethod(Codeword, "list,n,FFE", true, [IsList, IsInt, IsFFE], 1, 
function(list, n, ffe)
	local c;
	if Length(list) > 0 and not (IsRat(list[1]) or IsFFE(list[1])) then 
		return List(list, i->Codeword(i, n, ffe)); 
	fi; 
	c := MakeCodeword(list, n, ffe);  
	TreatAsVector(c);
	return c;
end);

InstallOtherMethod(Codeword, "list,n,Field", true, [IsList, IsInt, IsField], 1, 
function(list, n, F)
  	local i;
	if Length(list) > 0 and not (IsRat(list[1]) or IsFFE(list[1])) then 
  		return List(list, i->Codeword(i, n, F)); 
	fi;
	if Length(list) > 0 and IsRat(list[1]) and not IsPrime(Size(F)) then 
		list := List(list, i->AsSSortedList(F)[Int(i)mod Size(F) + 1]);
	fi;
	return Codeword(list,n,One(F));
end);

InstallOtherMethod(Codeword, "list,FFE", true, [IsList, IsFFE], 1, 
function(list, ffe)
	if Length(list) > 0 and not (IsRat(list[1]) or IsFFE(list[1])) then 
		return List(list, i->Codeword(i, ffe)); 
	fi;
	return Codeword(list, Length(list), ffe);
end);

InstallOtherMethod(Codeword, "list,Field", true, [IsList, IsField], 1, 
function(list, F)
	if Length(list) > 0 and not (IsRat(list[1]) or IsFFE(list[1])) then 
		return List(list, i->Codeword(i, F)); 
	fi;
		return Codeword(list, Length(list), F);
end);

InstallOtherMethod(Codeword, "list,n", true, [IsList, IsInt], 1, 
function(list, n)
local o;
  if Length(list)=0 then
	o:=Z(2);
  elif IsRat(list[1]) then 
 	o:=SelectField(list);
  elif IsFFE(list[1]) then 
	o:=Maximum(list);
  else 
    return List(list, i->Codeword(i, n)); 
  fi;
  return Codeword(list,n,o);
end);

InstallOtherMethod(Codeword,"list",true,[IsList],1,
function(list)
local o;
  if Length(list)=0 then  
	o:=Z(2);
  elif IsRat(list[1]) then 
  	o:= SelectField(list);
  elif  IsFFE(list[1]) then  
	o:= Maximum(list);
  else  
  	return List(list, i->Codeword(i)); 
  fi;
  return Codeword(list,Length(list),o);
end);

InstallOtherMethod(Codeword, "list,Code", true, [IsList, IsCode], 0, 
function(l, C) 
	return Codeword(l, WordLength(C), LeftActingDomain(C));
end);


## Methods with a string provided ##

## helper function to convert string to list/vector.  Digits go to approp.
## digit.  Other characters go to 0.
StringToVec := function(s)
	local val, i, S; 
	S := [];
	for i in s do 
		val := Position("0123456789", i);
		if val = fail then 
			val := 0;
		else 
			val := val-1;
		fi;
		Add(S, val);
	od;
	return S;
end;


InstallOtherMethod(Codeword,"string,n,FFE",true,[IsString,IsInt,IsFFE],0,
function(s,n,ffe)
	s:=StringToVec(s);
	return Codeword(s,n,ffe);
end);

InstallOtherMethod(Codeword,"string,n,Field",true,[IsString,IsInt,IsField],0,
function(s,n,F)
	s := StringToVec(s);
	return Codeword(s, n, F);
end);

InstallOtherMethod(Codeword, "string,FFE", true, [IsString, IsFFE], 0, 
function(s, ffe)
	return Codeword(s, Length(s), ffe);
end);

InstallOtherMethod(Codeword, "string,Field", true, [IsString, IsField], 0, 
function(s, F) 
	return Codeword(s, Length(s), F);
end);

InstallOtherMethod(Codeword, "string,n", true, [IsString, IsInt], 0, 
function(s, n)
	local F;
	s := StringToVec(s);
	F := SelectField(s); 
	return Codeword(s, n, F);
end);

InstallOtherMethod(Codeword, "string", true, [IsString], 0, 
function(s) 
	return Codeword(s, Length(s)); 
end);

InstallOtherMethod(Codeword, "string,Code", true, [IsString, IsCode], 0, 
function(s, C)
	return Codeword(s, WordLength(C), LeftActingDomain(C));
end);


## Methods with a poly provided ##
InstallOtherMethod(Codeword,"poly,n,FFE", 
  	function(pf, inf, ff)
  		return IsIdenticalObj(CoefficientsFamily(pf), ff);
	end, 
	[IsUnivariatePolynomial,IsInt,IsFFE],0,
function(p,n,ffe)
  	local c;
	p := CoefficientsOfLaurentPolynomial(p);
  	p := ShiftedCoeffs(p[1],p[2]);
  	c := Codeword(p,n,ffe);
    TreatAsPoly(c);
	return c;
end);

InstallOtherMethod(Codeword, "poly,n,Field",  
	function(pf,inf,ff)
		return IsIdenticalObj(CoefficientsFamily(pf), ElementsFamily(ff));
	end,
	[IsUnivariatePolynomial, IsInt, IsField], 0, 
function(p, n, F)
	return Codeword(p, n, One(F));
end);

InstallOtherMethod(Codeword, "poly,FFE",  
	function(pf, ff)
		return IsIdenticalObj(CoefficientsFamily(pf), ff);
	end,
	[IsUnivariatePolynomial, IsFFE], 0, 
function(p, ffe)
	local c;
	p := CoefficientsOfLaurentPolynomial; 
	p := ShiftedCoeffs(p[1],p[2]);
	c := Codeword(p, Length(p), ffe);
	TreatAsPoly(c); 
	return c;
end);

InstallOtherMethod(Codeword, "poly,Field",  
	function(pf,ff)
		return IsIdenticalObj(CoefficientsFamily(pf), ElementsFamily(ff));
	end,
	[IsUnivariatePolynomial, IsField], 0, 
function(p, F)
	local c;
	p := CoefficientsOfLaurentPolynomial(p);
	p := ShiftedCoeffs(p[1],p[2]); 
	c := Codeword(p, Length(p), One(F));
	TreatAsPoly(c);
	return c;
end);

InstallOtherMethod(Codeword, "poly,n", true, 
	[IsUnivariatePolynomial, IsInt], 0, 
function(p, n)
	local c, F;
	F := CoefficientsRing(DefaultRing(p)); 
	p := CoefficientsOfLaurentPolynomial(p);
	p := ShiftedCoeffs(p[1],p[2]); 
	c := Codeword(p, n, F); 
	TreatAsPoly(c);
	return c;
end);

InstallOtherMethod(Codeword, "poly", true, 
	[IsUnivariatePolynomial], 0, 
function(p)
	local c, F; 
	F := CoefficientsRing(DefaultRing(p));
	p := CoefficientsOfLaurentPolynomial(p); 
	p := ShiftedCoeffs(p[1],p[2]); 
	c := Codeword(p, Length(p), F);
	TreatAsPoly(c);
	return c;
end);

InstallOtherMethod(Codeword, "poly,Code", true, 
	[IsUnivariatePolynomial, IsCode], 0, 
function(p, C)
	return Codeword(p, WordLength(C), LeftActingDomain(C));
end);


## Methods with a codeword provided ##
InstallOtherMethod(Codeword,"codeword,n",true,[IsCodeword,IsInt],0,
function(w,n)
  return Codeword(VectorCodeword(w),n, Field(VectorCodeword(w)));
end);

InstallOtherMethod(Codeword, "codeword", true, [IsCodeword], 0,
function(w)
	return Codeword(VectorCodeword(w), WordLength(w), Field(VectorCodeword(w)));
end);

InstallOtherMethod(Codeword, "codeword,n,Field", true, 
	[IsCodeword, IsInt, IsField], 0, 
function(w, n, F)
	return Codeword(VectorCodeword(w),n,F);
end);

InstallOtherMethod(Codeword, "codeword,n,FFE", true, 
	[IsCodeword, IsInt, IsFFE], 0, 
function(w, n, ffe) 
	return Codeword(VectorCodeword(w), n, ffe);
end);

InstallOtherMethod(Codeword, "codeword,Field", true, [IsCodeword, IsField], 0,
function(w, F)
	return Codeword(VectorCodeword(w),WordLength(w), F);
end);

InstallOtherMethod(Codeword, "codeword,FFE", true, [IsCodeword, IsFFE], 0, 
function(w, ffe)
	return Codeword(VectorCodeword(w), WordLength(w), ffe);
end);

InstallOtherMethod(Codeword, "codeword,Code", true, [IsCodeword, IsCode], 0, 
function(w, C)
	return Codeword(VectorCodeword(w), WordLength(C), LeftActingDomain(C));
end);


#############################################################################
##
#F  Field( <c> )
##
#InstallOtherMethod(FieldByGenerators,"codewords",true,[IsCodewordCollection],0,
#function(l)
#  return FieldByGenerators(VectorCodeword(l[1]));
#end);

#############################################################################
##
#M  Print( <v> )  . . . . . . . . . . . . . . . . . . . . . prints a codeword
##
PrintViewCodeword:=function(w)
local v, q, isclear, i, l, power;
  if w!.treatAsPoly then 
    v := VectorCodeword(w);
    if Length(v) > 0 then 
      q := Size(Field(v));
    else 
      Print("[ ]");
      return;
    fi;
    isclear := true;
    for power in Reversed([0..WordLength(w)-1]) do 
      if v[power+1] <> 0*Z(q) then 
	if not isclear then 
		Print(" + "); 
	fi;
	isclear := false; 
	if power = 0 or v[power+1] <> Z(q)^0 then 
		if IsPrime(q) then 
			Print(String(Int(v[power+1])));
		else
			i := LogFFE(v[power+1], Z(q));
			if i = 0 then 
				Print("1");
			elif i = 1 then 
				Print("a");
			else
				Print("(a^",String(i),")");
			fi;
		fi;
	fi;
	if power > 0 then 
		Print("x");
		if power > 1 then 
			Print("^", String(power));
		fi;
	fi;
      fi;
    od;
    if isclear then 
      Print("0");
    fi; 
  else
    Print("[ ");
    v := VectorCodeword(w);
    if Length(v) > 0 then 
	    q := Size(Field(v));
    else 
	    Print("]");
	    return;
    fi;
    if not IsPrime(q) then 
	    for i in v do 
		    if i = 0 * Z(q) then 
			    Print("0 ");
		    else
			    l := LogFFE(i, Z(q));
			    if l = 0 then 
				    Print("1 ");
			    elif l = 1 then 
				    Print("a ");
			    else
				    Print("a^", String(l), " ");
			    fi;
		    fi;
	    od;
    else
	    for i in IntVecFFE(v) do 
		    Print(i, " ");
	    od;
    fi;
    Print("]");
  fi;
end;

InstallMethod(PrintObj, "codeword", true, [IsCodeword], 0, 
  PrintViewCodeword);

InstallMethod(ViewObj, "codeword", true, [IsCodeword], 0, 
  PrintViewCodeword);

#############################################################################
##
## list methods for codewords (to permit codeword+list...)
InstallOtherMethod(Length,"codeword",true,[IsCodeword],0,
  w->Length(VectorCodeword(w)));

InstallOtherMethod(\[\],"codeword",true,[IsCodeword,IsPosInt],0,
function(w,i)
  return VectorCodeword(w)[i];
end);

#############################################################################
##
#F  \+( <l>, <r> )  . . . . . . . . . . . . . . . . . . . .  sum of codewords
##

InstallOtherMethod(\+, "codeword+codeword", true, [IsCodeword, IsCodeword], 0, 
function(a, b) 
	return Codeword(VectorCodeword(a) + VectorCodeword(b));
end);

InstallOtherMethod(\+, "codeword+list", true, [IsCodeword, IsList], 0, 
function(w, l)
	return Codeword(VectorCodeword(w) + l); 
end);

InstallOtherMethod(\+, "list+codeword", true, [IsList,IsCodeword], 0, 
function(l, w)
	return Codeword(l+VectorCodeword(w)); 
end);

InstallOtherMethod(\+, "poly+codeword", true, 
	[IsUnivariatePolynomial, IsCodeword], 0, 
function(p, w)
	return Codeword(p) + w;
end);

InstallOtherMethod(\+, "codeword+poly", true, 
	[IsCodeword, IsUnivariatePolynomial], 0, 
function(w, p)
	return w + Codeword(p);
end);

InstallOtherMethod(\+, "string+codeword", true, [IsString, IsCodeword], 0, 
function(s, w)
	return Codeword(s) + w;
end);

InstallOtherMethod(\+, "codeword+string", true, [IsCodeword, IsString], 0, 
function(w, s)
	return w + Codeword(s);
end);

InstallOtherMethod(\+, "Rat+codeword", true, [IsRat, IsCodeword], 0, 
function(r, w)
	return Codeword(r + VectorCodeword(w));
end);

InstallOtherMethod(\+, "codeword+Rat", true, [IsCodeword, IsRat], 0, 
function(w, r)
	return Codeword(VectorCodeword(w) + r);
end);

InstallOtherMethod(\+, "FFE+codeword", true, [IsFFE, IsCodeword], 0, 
function(ffe, w)
	return Codeword(ffe + VectorCodeword(w));
end);

InstallOtherMethod(\+, "codeword+FFE", true, [IsCodeword, IsFFE], 0, 
function(w, ffe)
	return Codeword(VectorCodeword(w) + ffe);
end);


#############################################################################
##
#F  \*( <l>, <r> )  . . . . . . . . . . . .  product of codewords
##

InstallOtherMethod(\*, "codeword*codeword", true, [IsCodeword, IsCodeword], 0, 
function(a, b)
	return VectorCodeword(a) * VectorCodeword(b);
end);

InstallOtherMethod(\*, "matrix*codeword", true, [IsMatrix, IsCodeword], 0, 
function(m, w)
	return Codeword(m * VectorCodeword(w));
end);

InstallOtherMethod(\*, "codeword*matrix", true, [IsCodeword, IsMatrix], 0, 
function(w, m)
	return Codeword(VectorCodeword(w) * m);
end);

InstallOtherMethod(\*, "FFE*codeword", true, [IsFFE, IsCodeword], 0, 
function(ffe, w)
	return Codeword(ffe * VectorCodeword(w));
end);

InstallOtherMethod(\*, "codeword*FFE", true, [IsCodeword, IsFFE], 0, 
function(w, ffe)
	return Codeword(VectorCodeword(w) * ffe);
end);

InstallOtherMethod(\*, "Rat*codeword", true, [IsRat, IsCodeword], 0, 
function(r, w)
	return Codeword(r * VectorCodeword(w));
end);

InstallOtherMethod(\*, "codeword*Rat", true, [IsCodeword, IsRat], 0, 
function(w, r)
	return Codeword(VectorCodeword(w) * r);
end);


#############################################################################
##
#F  \-( <l>, <r> )  . . . . . . . . . . . . . . . . . difference of codewords
##

InstallOtherMethod(\-, "codeword-codeword", true, [IsCodeword, IsCodeword], 0, 
function(a, b)
	return Codeword(VectorCodeword(a) - VectorCodeword(b)); 
end);

InstallOtherMethod(\-, "vector-codeword", true, [IsVector, IsCodeword], 0, 
function(v, w)
	return Codeword(v - VectorCodeword(w));
end);

InstallOtherMethod(\-, "codeword-vector", true, [IsCodeword, IsVector], 0, 
function(w,v)
	return Codeword(VectorCodeword(w) - v);
end);

InstallOtherMethod(\-, "poly-codeword", true, 
	[IsUnivariatePolynomial, IsCodeword], 0, 
function(p, w)
	return Codeword(p) - w;
end);

InstallOtherMethod(\-, "codeword-poly", true, 
	[IsCodeword, IsUnivariatePolynomial], 0, 
function(w, p)
	return w - Codeword(p);
end);

InstallOtherMethod(\-, "string-codeword", true, [IsString, IsCodeword], 0, 
function(s, w)
	return Codeword(s) - w;
end);

InstallOtherMethod(\-, "codeword-string", true, [IsCodeword, IsString], 0, 
function(w, s)
	return w - Codeword(s);
end);

InstallOtherMethod(\-, "Rat-codeword", true, [IsRat, IsCodeword], 0, 
function(r, w)
	return Codeword(r - VectorCodeword(w));
end);

InstallOtherMethod(\-, "codeword-Rat", true, [IsCodeword, IsRat], 0, 
function(w, r)
	return Codeword(VectorCodeword(w) - r);
end);

InstallOtherMethod(\-, "FFE-codeword", true, [IsFFE, IsCodeword], 0, 
function(ffe, w)
	return Codeword(ffe - VectorCodeword(w));
end);

InstallOtherMethod(\-, "codeword-FFE", true, [IsCodeword, IsFFE], 0, 
function(w, ffe)
	return Codeword(VectorCodeword(w) - ffe);
end);


#############################################################################
##
#F  \=( <l>, <r> )  . . . . . . . . . . . . . . . . . . equality of codewords
##

InstallMethod(\=, "codeword=codeword", true, [IsCodeword, IsCodeword], 0, 
function(a, b)
	return VectorCodeword(a) = VectorCodeword(b);
end);

InstallMethod(\=, "vector=codeword", true, [IsVector, IsCodeword], 0, 
function(v, w)
	return v = VectorCodeword(w);
end);

InstallMethod(\=, "codeword=vector", true, [IsCodeword, IsVector], 0, 
function(w, v)
	return VectorCodeword(w) = v;
end);

InstallMethod(\=, "poly=codeword", true, 
	[IsUnivariatePolynomial, IsCodeword], 0, 
function(p, w)
	return VectorCodeword(Codeword(p)) = VectorCodeword(w);
end);

InstallMethod(\=, "codeword=poly", true, 
	[IsCodeword, IsUnivariatePolynomial], 0, 
function(w, p)
	return VectorCodeword(w) = VectorCodeword(Codeword(p));
end);

InstallMethod(\=, "string=codeword", true, 
	[IsString, IsCodeword], 0, 
function (s, w)
	return VectorCodeword(Codeword(s)) = VectorCodeword(w);
end);

InstallMethod(\=, "codeword=string", true, 
	[IsCodeword, IsString], 0, 
function(w, s)
	return VectorCodeword(w) = VectorCodeword(Codeword(s));
end);


#############################################################################
##
#F  \<( <l>, <r> )  . . . . . . . . . . . . . . . . less than for codewords
##

InstallMethod(\<, "codeword<codeword", IsIdenticalObj, 
	[IsCodeword, IsCodeword], 0, 
function(a,b)
	return VectorCodeword(a) < VectorCodeword(b);
end);


#############################################################################
##
#F  Support( <v> )  . . . . . . . set of coordinates in which <v> is not zero
##

InstallMethod(Support, "codeword", true, [IsCodeword], 0, 
function (c)
	local i, S, zero;
	S := [];
	zero := Zero(VectorCodeword(c)[1]);   
	for i in [1..WordLength(c)] do 
		if VectorCodeword(c)[i] <> zero then 
			Add(S, i);
		fi;
	od;
	return S;
end);


#############################################################################
##
#F  TreatAsPoly( <v> )  . . . . . . . . . . . .  treat codeword as polynomial
##
##  The codeword <v> will be treated as a polynomial
##

InstallMethod(TreatAsPoly, "codeword", true, [IsCodeword], 0, 
function(c)
	c!.treatAsPoly := true;
end);

InstallOtherMethod(TreatAsPoly, "list of codewords", true, [IsList], 0, 
function(list)
local i;
  if IsCodeword(list) then
    TryNextMethod(); # codeword is list
  fi;
  for i in list do 
    TreatAsPoly(i);
  od;
end);


#############################################################################
##
#F  TreatAsVector( <v> )  . . . . . . . . . . . .  treat codeword as a vector
##
##  The codeword <v> will be treated as a vector
##

InstallMethod(TreatAsVector, "codeword", true, [IsCodeword], 0, 
function(c)
	c!.treatAsPoly := false;
end);

InstallOtherMethod(TreatAsVector, "list of codewords", true, [IsList], 0, 
function(list) 
local i;
  if IsCodeword(list) then
    TryNextMethod(); # codeword is list
  fi;
  for i in list do 
    TreatAsVector(i);
  od;
end);


#############################################################################
##
#F  PolyCodeword( <arg> ) . . . . . . . . . . converts input to polynomial(s)
##
## Input may be codeword, polynomial, vector or a list of those
##  -currently only codeword or list of 

InstallMethod(PolyCodeword, "poly from codeword", true, [IsCodeword], 0, 
function(w)
	local fam, cf, F;
	cf := VectorCodeword(w);
	if Length(cf) > 0 then 
		F := Field(cf);
	else 
		F := GF(2);
	fi;
	fam := ElementsFamily(FamilyObj(F)); 
	return LaurentPolynomialByCoefficients(fam, cf, 0);
end);

InstallOtherMethod(PolyCodeword, "polys from codeword list", true, [IsList], 0, 
function(l)
	return List(l, i->PolyCodeword(Codeword(i)));	
end);


#############################################################################
##
#F  VectorCodeword( <arg> ) . . . . . . . . . . . .  converts input to vector
##
## Input may be codeword, polynomial, vector or a list of those
##  - currently only codeword or list of!

InstallMethod(VectorCodeword, "vector from codeword", true, [IsCodeword], 0, 
function(w)
	local p;
	if HasPolyCodeword(w) then 
		p := PolyCodeword(w);
	else
		Error("VectorCodeword and PolyCodeword both unknown");
	fi;
	p := CoefficientsOfLaurentPolynomial(p);
	p := ShiftedCoeffs(p[1], p[2]);
	return p; 
end);

InstallOtherMethod(VectorCodeword, "vectors from codeword list", true, 
	[IsList], 0, 
function(l)
	return List(l, i->VectorCodeword(Codeword(i)));
end);


#############################################################################
##
#F  Weight( <v> ) . . . . . . . . . . . calculates the weight of codeword <v>
##

InstallMethod(Weight, "codeword", true, [IsCodeword], 0, 
function(w)
    local vec; 
    vec := VectorCodeword(w);
    return DistanceVecFFE( 0*vec, vec );  
end );


#############################################################################
##
#F  DistanceCodeword( <a>, <b> )  . the distance between codeword <a> and <b>
##

InstallMethod(DistanceCodeword, "two codewords", true, 
	[IsCodeword, IsCodeword], 0, 
function(w1, w2)
	return DistanceVecFFE(VectorCodeword(w1), VectorCodeword(w2));
end);


#############################################################################
##
#F  NullWord( <C> ) or NullWord( <n>, <F> ) . . . . . . . . . . all zero word
##

InstallMethod(NullWord, "n-FFE", true, [IsInt, IsFFE], 0, 
function(n,ffe)
	return Codeword(List([1..n], i->0), n, ffe);
end);

InstallOtherMethod(NullWord, "n-Field", true, [IsInt, IsField], 0, 
function(n, F)
	return Codeword(List([1..n], i->0), n, One(F));
end);

InstallOtherMethod(NullWord, "n", true, [IsInt], 0, 
function(n)
	return Codeword(List([1..n], i->0), n, One(GF(2)));
end);

InstallOtherMethod(NullWord, "Code", true, [IsCode], 0, 
function(C)
	local n;
	n := WordLength(C); 
	return Codeword(List([1..n], i->0),n,One(LeftActingDomain(C)));
end);


#############################################################################
##
## Zero(<w>) .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  zero codeword 
##
InstallOtherMethod(Zero, "method for codewords", true, [IsCodeword], 0, 
function(w) 
	return Zero(VectorCodeword(w)[1]) * w; 
end); 


