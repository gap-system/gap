###########################################################################
##
#W  algfld.gi                   GAP Library                  Alexander Hulpke
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the methods for algebraic elements and their families
##

#############################################################################
##
#R  IsAlgebraicExtensionDefaultRep    Representation of algebraic extensions
##
DeclareRepresentation(
  "IsAlgebraicExtensionDefaultRep", IsAlgebraicExtension and
  IsComponentObjectRep and IsAttributeStoringRep,
  ["extFam"]);

#############################################################################
##
#R  IsAlgBFRep        Representation for embedded base field
##
DeclareRepresentation("IsAlgBFRep",
  IsPositionalObjectRep and IsAlgebraicElement,[]);

#############################################################################
##
#R  IsKroneckerConstRep       Representation for true extension elements
##
##  This representation describes elements that are represented in a formal
##  extension as polynomials modulo an ideal.
DeclareRepresentation("IsKroneckerConstRep",
  IsPositionalObjectRep and IsAlgebraicElement,[]);

DeclareSynonym("IsAlgExtRep",IsKroneckerConstRep);

#############################################################################
##
#M  AlgebraicElementsFamilies       Initializing method
##
InstallMethod(AlgebraicElementsFamilies,true,[IsUnivariatePolynomial],0,
              f -> []);

#############################################################################
##
#F  StoreAlgExtFam(<pol>,<field>,<fam>)  store fam as Alg.Ext.Fam. for p
##                                       over field
##
StoreAlgExtFam := function(p,f,fam)
local   aef;
  aef:=AlgebraicElementsFamilies(p);
  if not ForAny(aef,i->i[1]=f) then
    Add(aef,[f,fam]);
  fi;
end;

#############################################################################
##
#M  AlgebraicElementsFamily      generic method
##
InstallMethod(AlgebraicElementsFamily,"generic",true,
  [IsField,IsUnivariatePolynomial,IsBool],0,
function(f,p,check)
local fam,i,cof,red,rchar,impattr,deg;
  if check and not IsIrreducibleRingElement(PolynomialRing(f,
             [IndeterminateNumberOfLaurentPolynomial(p)]),p) then
    Error("<p> must be irreducible over f");
  fi;
  fam:=AlgebraicElementsFamilies(p);
  i:=PositionProperty(fam,i->i[1]=f);
  if i<>fail then
    return fam[i][2];
  fi;

  impattr:=IsAlgebraicElement and CanEasilySortElements and IsZDFRE;
  fam:=NewFamily("AlgebraicElementsFamily(...)",IsAlgebraicElement,
	 impattr,
	 IsAlgebraicElementFamily and CanEasilySortElements);

  # The two types
  fam!.baseType := NewType(fam,IsAlgBFRep);
  fam!.extType := NewType(fam,IsKroneckerConstRep);

  # Important trivia
  fam!.baseField:=f;
  fam!.zeroCoefficient:=Zero(f);
  fam!.oneCoefficient:=One(f);
  if Size(f)<=256 then
    rchar:=Size(f);
  else
    rchar:=0;
  fi;
  fam!.rchar:=rchar;

  fam!.poly:=p;
  fam!.polCoeffs:=CoefficientsOfUnivariatePolynomial(p);
  deg:=DegreeOfLaurentPolynomial(p);
  fam!.deg:=deg;
  i:=List([1..DegreeOfLaurentPolynomial(p)],i->fam!.zeroCoefficient);
  i[2]:=fam!.oneCoefficient;
  i:=ImmutableVector(Size(f),i,true);
  fam!.primitiveElm:=MakeImmutable(ObjByExtRep(fam,i));
  fam!.indeterminateName:=MakeImmutable("a");

  # reductions
  #red:=IdentityMat(deg,fam!.oneCoefficient);
  red:=[];
  for i in [deg..2*deg-2] do
    cof:=ListWithIdenticalEntries(i,fam!.zeroCoefficient);
    Add(cof,fam!.oneCoefficient);
    if rchar>0 then
      if IsHPCGAP then
        cof := CopyToVectorRep(cof,rchar); # rchar is <= 256
      else
        ConvertToVectorRep(cof,rchar);
      fi;
    fi;
    ReduceCoeffs(cof,fam!.polCoeffs);
    while Length(cof)<deg do
      Add(cof,fam!.zeroCoefficient);
    od;
    Add(red,cof{[1..deg]});
  od;
  red:=ImmutableMatrix(fam!.baseField,red);
  fam!.reductionMat:=red;
  fam!.prodlen:=Length(red);
  fam!.entryrange:=MakeImmutable([1..deg]);

  red:=[];
  for i in [deg..2*deg-1] do
    red[i]:=[deg+1..i];
  od;
  fam!.mulrange:=MakeImmutable(red);

  SetIsUFDFamily(fam,true);
  SetCoefficientsFamily(fam,FamilyObj(One(f)));

  # and set one and zero
  SetZero(fam,ObjByExtRep(fam,Zero(f)));
  SetOne(fam,ObjByExtRep(fam,One(f)));

  StoreAlgExtFam(p,f,fam);

  return fam;
end);

#############################################################################
##
#M  AlgebraicExtension      generic method
##
DoAlgebraicExt:=function(f,p,extra...)
local nam,e,fam,colf,check;

if Length(extra)>0 and IsString(extra[1]) then
    nam:=extra[1];
  else
    nam:="a";
  fi;
  if DegreeOfLaurentPolynomial(p)<=1 then
    return f;
  fi;

  if true in extra then
    check := true;
  else
    check := false;
  fi;
  fam:=AlgebraicElementsFamily(f,p,check);
  SetCharacteristic(fam,Characteristic(f));
  fam!.indeterminateName:=nam;
  colf:=CollectionsFamily(fam);
  e:=Objectify(NewType(colf,IsAlgebraicExtensionDefaultRep),
               rec());

  fam!.wholeField:=e;
  e!.extFam:=fam;
  SetCharacteristic(e,Characteristic(f));
  SetDegreeOverPrimeField(e,
               DegreeOfLaurentPolynomial(p)*DegreeOverPrimeField(f));
  SetIsFiniteDimensional(e,true);
  SetLeftActingDomain(e,f);
  SetGeneratorsOfField(e,[fam!.primitiveElm]);
  SetIsPrimeField(e,false);
  SetPrimitiveElement(e,fam!.primitiveElm);
  SetDefiningPolynomial(e,p);
  SetRootOfDefiningPolynomial(e,fam!.primitiveElm);

  if HasIsFinite(f) then
    if IsFinite(f) then
      SetIsFinite(e,true);
      if HasSize(f) then
	SetSize(e,Size(f)^fam!.deg);
      fi;
    else
      SetIsNumberField(e,true);
      SetIsFinite(e,false);
      SetSize(e,infinity);
    fi;
  fi;

  # AH: Noch VR-Eigenschaften!
  SetDimension( e, DegreeOfUnivariateLaurentPolynomial( p ) );

  SetOne(e,One(fam));
  SetZero(e,Zero(fam));
  fam!.wholeExtension:=e;

  return e;
end;

InstallMethod(AlgebraicExtension,"generic",true,
  [IsField,IsUnivariatePolynomial],0,
function(k,f) return DoAlgebraicExt(k,f,true);
end);
InstallMethod(AlgebraicExtensionNC,"generic",true,
  [IsField,IsUnivariatePolynomial],0,
function(k,f) return DoAlgebraicExt(k,f,false);
end);

RedispatchOnCondition(AlgebraicExtension,true,[IsField,IsRationalFunction],
  [IsField,IsUnivariatePolynomial],0);

RedispatchOnCondition(AlgebraicExtensionNC,true,[IsField,IsRationalFunction],
  [IsField,IsUnivariatePolynomial],0);

InstallOtherMethod(AlgebraicExtension,"with name",true,
  [IsField,IsUnivariatePolynomial,IsString],0,
function(k,f,nam) return DoAlgebraicExt(k,f,nam,true);
end);

InstallOtherMethod(AlgebraicExtensionNC,"with name",true,
  [IsField,IsUnivariatePolynomial,IsString],0,
function(k,f,nam) return DoAlgebraicExt(k,f,nam,false);
end);

RedispatchOnCondition(AlgebraicExtension,true,
  [IsField,IsRationalFunction,IsString],
  [IsField,IsUnivariatePolynomial,IsString],0);

RedispatchOnCondition(AlgebraicExtensionNC,true,
  [IsField,IsRationalFunction,IsString],
  [IsField,IsUnivariatePolynomial,IsString],0);

#############################################################################
##
#M  FieldExtension     generically default on `AlgebraicExtension'.
##
InstallMethod(FieldExtension,"generic",true,
  [IsField,IsUnivariatePolynomial],0,AlgebraicExtension);

#############################################################################
##
#M  PrintObj
#M  ViewObj
##
InstallMethod( PrintObj, "for algebraic extension", true,
[IsNumberField and IsAlgebraicExtension], 0,
function( F )
    Print( "<algebraic extension over the Rationals of degree ",
           DegreeOverPrimeField( F ), ">" );
end );

InstallMethod( ViewObj, "for algebraic extension", true,
[IsNumberField and IsAlgebraicExtension], 0,
function( F )
    Print("<algebraic extension over the Rationals of degree ",
          DegreeOverPrimeField( F ), ">" );
end );

#############################################################################
##
#M  ExtRepOfObj     
##
##  The external representation of an algebraic element is a coefficient
##  list (in the primitive element)
##
InstallMethod(ExtRepOfObj,"baseFieldElm",true,
  [IsAlgebraicElement and IsAlgBFRep],0,
function(e)
local f,l;
  f:=FamilyObj(e);
  l:=[e![1]];
  while Length(l)<f!.deg do
    Add(l,f!.zeroCoefficient);
  od;
  return l;
end);

InstallMethod(ExtRepOfObj,"ExtElm",true,
  [IsAlgebraicElement and IsKroneckerConstRep],0,
function(e)
  return e![1];
end);

#############################################################################
##
#M  ObjByExtRep          embedding of elements of base field
##
InstallMethod(ObjByExtRep,"baseFieldElm",true,
  [IsAlgebraicElementFamily,IsRingElement],0,
function(fam,e)
  e:=[e];
  Objectify(fam!.baseType,e);
  return e;
end);

#############################################################################
##
#M  ObjByExtRep          extension elements
##
InstallMethod(ObjByExtRep,"ExtElm",true,
  [IsAlgebraicElementFamily,IsList],0,
function(fam,e)
  MakeImmutable(e);
  e:=[e];
  Objectify(fam!.extType,e);
  return e;
end);

#############################################################################
##
#F  AlgExtElm      A `nicer' ObjByExtRep, that shrinks/grows a list to the 
##                 correct length and tries to get to the BaseField
##                 representation
##
BindGlobal("AlgExtElm",function(fam,e)
  if IsList(e) then
    if Length(e)<fam!.deg then
      e:=ShallowCopy(e);
      while Length(e)<fam!.deg do
        Add(e,fam!.zeroCoefficient);
      od;
    fi;
    # try to get into small rep
    if ForAll(e{[2..fam!.deg]},i->i=fam!.zeroCoefficient) then
      e:=e[1];
    elif Length(e)>fam!.deg then
      e:=e{[1..fam!.deg]};
    fi;
  fi;
  return ObjByExtRep(fam,e);
end);

#############################################################################
##
#M  PrintObj
##
InstallMethod(PrintObj,"BFElm",true,[IsAlgBFRep],0,
function(a)
  Print("!",String(a![1]));
end);

InstallMethod(PrintObj,"AlgElm",true,[IsKroneckerConstRep],0,
function(a)
local fam;
  fam:=FamilyObj(a);
  Print(StringUnivariateLaurent(fam,a![1],0,fam!.indeterminateName));
end);

#############################################################################
##
#M  String
##
InstallMethod(String,"BFElm",true,[IsAlgBFRep],0,
function(a)
  return Concatenation("!",String(a![1]));
end);

InstallMethod(String,"AlgElm",true,[IsKroneckerConstRep],0,
function(a)
local fam;
  fam:=FamilyObj(a);
  return StringUnivariateLaurent(fam,a![1],0,fam!.indeterminateName);
end);

#############################################################################
##
#M  \+  for all combinations of A.E.Elms and base field elms.
##
InstallMethod(\+,"AlgElm+AlgElm",IsIdenticalObj,[IsKroneckerConstRep,IsKroneckerConstRep],0,
function(a,b)
  local e,i,fam;
  fam:=FamilyObj(a);
  e:=a![1]+b![1];
  i:=2;
  while i<=fam!.deg do
    if e[i]<>fam!.zeroCoefficient then
      # still extension
      return Objectify(fam!.extType,[e]);
    fi;
    i:=i+1;
  od;
  return Objectify(fam!.baseType,[e[1]]);
  #return AlgExtElm(FamilyObj(a),a![1]+b![1]);
end);

InstallMethod(\+,"AlgElm+BFElm",IsIdenticalObj,[IsKroneckerConstRep,IsAlgBFRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  a:=ShallowCopy(a![1]);
  a[1]:=a[1]+b![1];
  return Objectify(fam!.extType,[a]);
end);

InstallMethod(\+,"BFElm+AlgElm",IsIdenticalObj,[IsAlgBFRep,IsKroneckerConstRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  b:=ShallowCopy(b![1]);
  b[1]:=b[1]+a![1];
  return Objectify(fam!.extType,[b]);
  #return ObjByExtRep(FamilyObj(a),b);
end);

InstallMethod(\+,"BFElm+BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
local e,fam;
  fam:=FamilyObj(a);
  e:=a![1]+b![1];
  return Objectify(fam!.baseType,[e]);
  #return ObjByExtRep(FamilyObj(a),a![1]+b![1]);
end);

InstallMethod(\+,"AlgElm+FElm",IsElmsCoeffs,[IsKroneckerConstRep,IsRingElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  a:=ShallowCopy(a![1]);
  a[1]:=a[1]+(b*fam!.oneCoefficient);
  return Objectify(fam!.extType,[a]);
  #return ObjByExtRep(fam,a);
end);

InstallMethod(\+,"FElm+AlgElm",IsCoeffsElms,[IsRingElement,IsKroneckerConstRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  b:=ShallowCopy(b![1]);
  b[1]:=b[1]+(a*fam!.oneCoefficient);
  return Objectify(fam!.extType,[b]);
  #return ObjByExtRep(fam,b);
end);

InstallMethod(\+,"BFElm+FElm",IsElmsCoeffs,[IsAlgBFRep,IsRingElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  b:=a![1]+b;
  return Objectify(fam!.baseType,[b]);
  #return AlgExtElm(FamilyObj(a),b);
end);

InstallMethod(\+,"FElm+BFElm",IsCoeffsElms,[IsRingElement,IsAlgBFRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  a:=b![1]+a;
  return Objectify(fam!.baseType,[a]);
  #return AlgExtElm(FamilyObj(b),a);
end);

#############################################################################
##
#M  AdditiveInverseOp
##
InstallMethod( AdditiveInverseOp, "AlgElm",true,[IsKroneckerConstRep],0,
function(a)
  return Objectify(FamilyObj(a)!.extType,[-a![1]]);
end);

InstallMethod( AdditiveInverseOp, "BFElm",true,[IsAlgBFRep],0,
function(a)
  return Objectify(FamilyObj(a)!.baseType,[-a![1]]);
end);

#############################################################################
##
#M  \*  for all combinations of A.E.Elms and base field elms.
##
InstallMethod(\*,"AlgElm*AlgElm",IsIdenticalObj,[IsKroneckerConstRep,IsKroneckerConstRep],0,
function(x,y)
local fam,b,d,i;
  fam:=FamilyObj(x);
  b:=ProductCoeffs(x![1],y![1]);
  while Length(b)<fam!.deg do
    Add(b,fam!.zeroCoefficient);
  od;
  b:=b{fam!.entryrange}+b{fam!.mulrange[Length(b)]}*fam!.reductionMat;
  #d:=ReduceCoeffs(b,fam!.polCoeffs);

  # check whether we are in the base field
  i:=2;
  while i<=fam!.deg do
    if b[i]<>fam!.zeroCoefficient then
      # and whether the vector is too short.
      i:=Length(b)+1;
      while i<=fam!.deg do
	if not IsBound(b[i]) then
	  b[i]:=fam!.zeroCoefficient;
	fi;
	i:=i+1;
      od;
      return Objectify(fam!.extType,[b]);
    fi;
    i:=i+1;
  od;
  return Objectify(fam!.baseType,[b[1]]);

end);

InstallMethod(\*,"AlgElm*BFElm",IsIdenticalObj,[IsKroneckerConstRep,IsAlgBFRep],0,
function(a,b)
  if IsZero(b![1]) then
    return b;
  else
    a:=a![1]*b![1];
    return Objectify(FamilyObj(b)!.extType,[a]);
  fi;
end);

InstallMethod(\*,"BFElm*AlgElm",IsIdenticalObj,[IsAlgBFRep,IsKroneckerConstRep],0,
function(a,b)
  if IsZero(a![1]) then
    return a;
  else
    b:=b![1]*a![1];
    return Objectify(FamilyObj(a)!.extType,[b]);
  fi;
end);

InstallMethod(\*,"BFElm*BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
  return Objectify(FamilyObj(a)!.baseType,[a![1]*b![1]]);
end);

InstallMethod(\*,"Alg*FElm",IsElmsCoeffs,[IsAlgebraicElement,IsRingElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  b:=a![1]*(b*fam!.oneCoefficient);
  return AlgExtElm(fam,b);
end);

InstallMethod(\*,"FElm*Alg",IsCoeffsElms,[IsRingElement,IsAlgebraicElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  a:=b![1]*(a*fam!.oneCoefficient);
  return AlgExtElm(fam,a);
end);

InstallOtherMethod(\*,"Alg*List",true,[IsAlgebraicElement,IsList],0,
function(a,b)
  return List(b,i->a*i);
end);

InstallOtherMethod(\*,"List*Alg",true,[IsList,IsAlgebraicElement],0,
function(a,b)
  return List(a,i->i*b);
end);

#############################################################################
##
#M  InverseOp
##
InstallMethod( InverseOp, "AlgElm",true,[IsKroneckerConstRep],0,
function(a)
local i,fam,f,g,t,h,rf,rg,rh,z;
  fam:=FamilyObj(a);
  f:=a![1];
  g:=ShallowCopy(fam!.polCoeffs);
  rf:=[fam!.oneCoefficient];
  z:=fam!.zeroCoefficient;
  rg:=[];
  while g<>[] do
    t:=QuotRemPolList(f,g);
    h:=g;
    rh:=rg;
    g:=t[2];
    if Length(t[1])=0 then
      rg:=[];
    else
      rg:=ShallowCopy(-ProductCoeffs(t[1],rg));
    fi;
    for i in [1..Length(rf)] do
      if IsBound(rg[i]) then
        rg[i]:=rg[i]+rf[i];
      else
        rg[i]:=rf[i];
      fi;
    od;
    f:=h;
    rf:=rh;
    ShrinkRowVector(g);
    #t:=Length(g);
    #while t>0 and g[t]=z do
    #  Unbind(g[t]);
    #  t:=t-1;
    #od;
  od;
  rf:=1/f[Length(f)]*rf;
  rf:=ImmutableVector(fam!.rchar, rf, true);
  return AlgExtElm(fam,rf);
end);

InstallMethod( InverseOp, "BFElm",true,[IsAlgBFRep],0,
function(a)
  return ObjByExtRep(FamilyObj(a),Inverse(a![1]));
end);


#############################################################################
##
#M  \<  for all combinations of A.E.Elms and base field elms.
##      Comparison is by the coefficient lists of the External
##      representation. The base field is naturally embedded
##
InstallMethod(\<,"AlgElm<AlgElm",IsIdenticalObj,[IsKroneckerConstRep,IsKroneckerConstRep],0,
function(a,b)
  return a![1]<b![1];
end);

InstallMethod(\<,"AlgElm<BFElm",IsIdenticalObj,[IsKroneckerConstRep,IsAlgBFRep],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b![1] then
    i:=2;
    while i<=fam!.deg and a![1][i]=fam!.zeroCoefficient do
      i:=i+1;
    od;
    if i<=fam!.deg and a![1][i]<fam!.zeroCoefficient then
      return true;
    fi;
    return false;
  else
    return a![1][1]<b![1];
  fi;
end);

InstallMethod(\<,"BFElm<AlgElm",IsIdenticalObj,[IsAlgBFRep,IsKroneckerConstRep],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a![1] then
    i:=2;
    while i<=fam!.deg and b![1][i]=fam!.zeroCoefficient do
      i:=i+1;
    od;
    if i<=fam!.deg and b![1][i]<fam!.zeroCoefficient then
      return false;
    fi;
    return true;
  else
    return a![1]<b![1][1];
  fi;
end);

InstallMethod(\<,"BFElm<BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
  return a![1]<b![1];
end);

InstallMethod(\<,"AlgElm<FElm",true,[IsKroneckerConstRep,IsRingElement],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b then
    i:=2;
    while i<=fam!.deg and a![1][i]=fam!.zeroCoefficient do
      i:=i+1;
    od;
    if i<=fam!.deg and a![1][i]<fam!.zeroCoefficient then
      return true;
    fi;
    return false;
  else
    return a![1][1]<b;
  fi;
end);

InstallMethod(\<,"FElm<AlgElm",true,[IsRingElement,IsKroneckerConstRep],0,
function(a,b)
local fam,i;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a then
    i:=2;
    while i<=fam!.deg and b![1][i]=fam!.zeroCoefficient do
      i:=i+1;
    od;
    if i<=fam!.deg and b![1][i]<fam!.zeroCoefficient then
      return false;
    fi;
    return true;
  else
    return a<b![1][1];
  fi;
end);

InstallMethod(\<,"BFElm<FElm",true,[IsAlgBFRep,IsRingElement],0,
function(a,b)
  return a![1]<b;
end);

InstallMethod(\<,"FElm<BFElm",true,[IsRingElement,IsAlgBFRep],0,
function(a,b)
  return a<b![1];
end);

#############################################################################
##
#M  \=  for all combinations of A.E.Elms and base field elms.
##      Comparison is by the coefficient lists of the External
##      representation. The base field is naturally embedded
##
InstallMethod(\=,"AlgElm=AlgElm",IsIdenticalObj,[IsKroneckerConstRep,IsKroneckerConstRep],0,
function(a,b)
  return a![1]=b![1];
end);

InstallMethod(\=,"AlgElm=BFElm",IsIdenticalObj,[IsKroneckerConstRep,IsAlgBFRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b![1] then
    return ForAll([2..fam!.deg],i->a![1][i]=fam!.zeroCoefficient);
  else
    return false;
  fi;
end);

InstallMethod(\=,"BFElm<AlgElm",IsIdenticalObj,[IsAlgBFRep,IsKroneckerConstRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a![1] then
    return ForAll([2..fam!.deg],i->b![1][i]=fam!.zeroCoefficient);
  else
    return false;
  fi;
end);

InstallMethod(\=,"BFElm=BFElm",IsIdenticalObj,[IsAlgBFRep,IsAlgBFRep],0,
function(a,b)
  return a![1]=b![1];
end);

InstallMethod(\=,"AlgElm=FElm",true,[IsKroneckerConstRep,IsRingElement],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  # simulate comparison of lists
  if a![1][1]=b then
    return ForAll([2..fam!.deg],i->a![1][i]=fam!.zeroCoefficient);
  else
    return false;
  fi;
end);

InstallMethod(\=,"FElm=AlgElm",true,[IsRingElement,IsKroneckerConstRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(b);
  # simulate comparison of lists
  if b![1][1]=a then
    return ForAll([2..fam!.deg],i->b![1][i]=fam!.zeroCoefficient);
  else
    return false;
  fi;
end);

InstallMethod(\=,"BFElm=FElm",true,[IsAlgBFRep,IsRingElement],0,
function(a,b)
  return a![1]=b;
end);

InstallMethod(\=,"FElm=BFElm",true,[IsRingElement,IsAlgBFRep],0,
function(a,b)
  return a=b![1];
end);

InstallMethod(\mod,"AlgElm",IsElmsCoeffs,[IsAlgebraicElement,IsPosInt],0,
function(a,m)
  return AlgExtElm(FamilyObj(a),List(ExtRepOfObj(a),i->i mod m));
end);

#############################################################################
##
#M  \in      base field elements are considered to lie in the algebraic
##           extension
##
InstallMethod(\in,"Alg in Ext",true,[IsAlgebraicElement,IsAlgebraicExtension],
  0,
function(a,b)
  return FamilyObj(a)=b!.extFam;
end);

InstallMethod(\in,"FElm in Ext",true,[IsRingElement,IsAlgebraicExtension],
  0,
function(a,b)
  return a in b!.extFam!.baseField;
end);

#############################################################################
##
#M  MinimalPolynomial
##
InstallMethod(MinimalPolynomial,"AlgElm",true,
  [IsField,IsAlgebraicElement,IsPosInt],0,
function(f,e,inum)
local fam,c,m;
  fam:=FamilyObj(e);
  if ElementsFamily(FamilyObj(f))<>CoefficientsFamily(FamilyObj(e)) 
    or fam!.baseField<>f then
    TryNextMethod();
  fi;
  c:=One(e);
  m:=[];
  repeat
    Add(m,ShallowCopy(ExtRepOfObj(c)));
    c:=c*e;
  until RankMat(m)<Length(m);
  m:=NullspaceMat(m)[1];
  # make monic
  m:=m/m[Length(m)];
  return UnivariatePolynomialByCoefficients(FamilyObj(fam!.zeroCoefficient),m,inum);
end);

#T  The method might be installed since it avoids the computations with
#T  a basis (used in the generic method).
#T  But note:
#T  In GAP 4, `MinimalPolynomial( <F>, <z> )' is a polynomial with
#T  coefficients in <F>, *not* the min. pol. of an element <z> in <F>
#T  with coefficients in `LeftActingDomain( <F> )'.
#T  So the first argument will in general be `Rationals'!


#############################################################################
##
#M  CharacteristicPolynomial
##
#InstallMethod(CharacteristicPolynomial,"Alg",true,
#  [IsAlgebraicExtension,IsScalar],0,
#function(f,e)
#local fam,p;
#  fam:=FamilyObj(One(f));
#  p:=MinimalPolynomial(f,e);
#  return p^(fam!.deg/DegreeOfLaurentPolynomial(p));
#end);
#T  See the comment about `MinimalPolynomial' above!


# #############################################################################
# ##
# #M  Trace
# ##
# InstallMethod(Trace,"Alg",true,
#   [IsAlgebraicExtension,IsScalar],0,
# function(f,e)
# local   p;
#   p:=CharacteristicPolynomial(f,f,e);
#   p:=CoefficientsOfUnivariatePolynomial(p);
#   return -p[Length(p)-1];
# end);
# 
# #############################################################################
# ##
# #M  Norm
# ##
# InstallMethod(Norm,"Alg",true,
#   [IsAlgebraicExtension,IsScalar],0,
# function(f,e)
# local   p;
#   p:=CharacteristicPolynomial(f,f,e);
#   p:=CoefficientsOfUnivariatePolynomial(p);
#   return p[1]*(-1)^(Length(p)-1);
# end);
#T The above two installations are obsolete since now the default methods
#T for `Trace' and `Norm' use `TracePolynomial';
#T the ``old'' default to use `Conjugates' is now restricted to the special
#T case that the field has `IsFieldControlledByGaloisGroup'.


#############################################################################
##
#M  Random
##
InstallMethodWithRandomSource( Random,
  "for a random source and an algebraic extension",
  [IsRandomSource, IsAlgebraicExtension],
function(rs,e)
local fam,l;
  fam:=e!.extFam;
  l:=List([1..fam!.deg],i->Random(rs,fam!.baseField));
  l:=ImmutableVector(fam!.rchar,l,true);
  return AlgExtElm(fam,l);
end);

#############################################################################
##
#F  MaxNumeratorCoeffAlgElm(<a>)
##
InstallMethod(MaxNumeratorCoeffAlgElm,"rational",true,[IsRat],0,
function(e)
  return AbsInt(NumeratorRat(e));
end);

InstallMethod(MaxNumeratorCoeffAlgElm,"algebraic element",true,
  [IsAlgebraicElement and IsAlgBFRep],0,
function(e)
  return MaxNumeratorCoeffAlgElm(e![1]);
end);

InstallMethod(MaxNumeratorCoeffAlgElm,"algebraic element",true,
  [IsAlgebraicElement and IsKroneckerConstRep],0,
function(e)
  return Maximum(List(e![1],MaxNumeratorCoeffAlgElm));
end);


#############################################################################
##
##  Supply a canonical basis for algebraic extensions.
##  (Subspaces of algebraic extensions could be easily handled via
##  the nice/ugly vectors mechanism.)
##


#############################################################################
##
#M  Basis( <algext> )
##
InstallMethod( Basis,
    "for an algebraic extension (delegate to `CanonicalBasis')",
    [ IsAlgebraicExtension ], CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#R  IsCanonicalBasisAlgebraicExtension( <algext> )
##
DeclareRepresentation( "IsCanonicalBasisAlgebraicExtension",
    IsBasis and IsCanonicalBasis and IsAttributeStoringRep, [] );


#############################################################################
##
#M  CanonicalBasis( <algext> )  . . . . . . . . . . . for algebraic extension
##
##  The basis vectors are the first powers of the primitive element.
##
InstallMethod( CanonicalBasis,
    "for an algebraic extension",
    true,
    [ IsAlgebraicExtension ], 0,
    function( F )
    local B;
    B:= Objectify( NewType( FamilyObj( F ),
                            IsCanonicalBasisAlgebraicExtension ),
                   rec() );
    SetUnderlyingLeftModule( B, F );
    return B;
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . . . . . . . . . for canon. basis of alg. ext.
##
InstallMethod( BasisVectors,
    "for canon. basis of an algebraic extension",
    [ IsCanonicalBasisAlgebraicExtension ],
    function( B )
    local F;
    F:= UnderlyingLeftModule( B );
    return List( [ 0 .. Dimension( F ) - 1 ], i -> PrimitiveElement( F )^i );
    end );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . . . . for canon. basis of alg. ext.
##
InstallMethod( Coefficients,
    "for canon. basis of an algebraic extension, and alg. element",
    IsCollsElms,
    [ IsCanonicalBasisAlgebraicExtension, IsAlgebraicElement ], 0,
    function( B, v )
    return ExtRepOfObj( v );
    end );

InstallMethod( Coefficients,
    "for canon. basis of an algebraic extension, and scalar",
    true,
    [ IsCanonicalBasisAlgebraicExtension, IsScalar ], 0,
    function( B, v )
    B:= UnderlyingLeftModule( B );
    if v in LeftActingDomain( B ) then
      return Concatenation( [ v ], Zero( v ) * [ 1 .. Dimension( B )-1 ] );
    else
      TryNextMethod();
    fi;
    end );

#############################################################################
##
#M  Characteristic( <algelm> )
##
InstallMethod(Characteristic,"alg elm",true,[IsAlgebraicElement],0,
function(e);
  return Characteristic(FamilyObj(e)!.baseField);
end);

#############################################################################
##
#M  DefaultFieldByGenerators( <elms> )
##
InstallMethod(DefaultFieldByGenerators,"alg elms",
  [IsList and IsAlgebraicElementCollection],0,
function(elms)
local fam;
  if Length(elms)>0 then
    fam:=FamilyObj(elms[1]);
    if ForAll(elms,i->FamilyObj(i)=fam) then
      if IsBound(fam!.wholeExtension) then
	return fam!.wholeExtension;
      fi;
    fi;
  fi;
  TryNextMethod();
end);

#############################################################################
##
#M  DefaultFieldOfMatrixGroup( <elms> )
##
InstallMethod(DefaultFieldOfMatrixGroup,"alg elms",
  [IsGroup and IsAlgebraicElementCollCollColl and HasGeneratorsOfGroup],0,
function(g)
local l,f,i,j,k,gens;
  l:=GeneratorsOfGroup(g);
  if Length(l)=0 then
    l:=[One(g)];
  fi;
  gens:=l[1][1];
  f:=DefaultFieldByGenerators(gens); # ist row
  # are all elts in this?
  for i in l do
    for j in i do
      for k in j do
        if not k in f then
	  gens:=Concatenation(gens,[k]);
	  f:=DefaultFieldByGenerators(gens);
	fi;
      od;
    od;
  od;
  return f;
end);

InstallGlobalFunction(AlgExtEmbeddedPol,function(ext,pol)
local f, cof;
   cof:=CoefficientsOfUnivariatePolynomial(pol);
   return UnivariatePolynomial(ext,cof*One(ext),
             IndeterminateNumberOfUnivariateRationalFunction(pol));
end);

#############################################################################
##
#M  FactorsSquarefree( <R>, <algextpol>, <opt> )
##
##  The function uses Algorithm~3.6.4 in~\cite{Coh93}.
##  (The record <opt> is ignored.)
##
BindGlobal("AlgExtFactSQFree",
function( R, U, opt )
local coeffring, basring, theta, xind, yind, x, y, coeffs, G, c, val, k, T,
      N, factors, i, j,xe,Re,one,kone;

    # Let $K = \Q(\theta)$ be a number field,
    # $T \in \Q[X]$ the minimal monic polynomial of $\theta$.
    # Let $U(X) be a monic squarefree polynomial in $K[x]$.
    coeffring:= CoefficientsRing( R );
    one:=One(coeffring);
    basring:=LeftActingDomain(coeffring);
    theta:= PrimitiveElement( coeffring );

    xind:= IndeterminateNumberOfUnivariateRationalFunction( U );
    if xind = 1 then
      yind:= 2;
    else
      yind:= 1;
    fi;
    x:= Indeterminate( basring, xind );
    xe:= Indeterminate( coeffring, xind );
    y:= Indeterminate( basring, yind );

    Re:=PolynomialRing(coeffring,[xind]);

    # Let $U(X) = \sum_{i=0}^m u_i X^i$ and write $u_i = g_i(\theta)$
    # for some polynomial $g_i \in \Q[X]$.
    # Set $G(X,Y) = \sum_{i=0}^m g_i(Y) X^i \in \Q[X,Y]$.
    coeffs:= CoefficientsOfUnivariatePolynomial( U );

    G:= Zero( basring );
    for i in [ 1 .. Length( coeffs ) ] do
      if IsAlgBFRep( coeffs[i] ) then
	G:= G + coeffs[i]![1] * x^i;
      else
	c:= coeffs[i]![1];
	val:= c[1];
	for j in [ 2 .. Length( c ) ] do
	  val:= val + c[j] * y^(j-1);
	od;
	G:= G + val * x^i;
      fi;
    od;

    # Set $k = 0$.
    k:= 0;

    # Compute $N(X) = R_Y( T(Y), G(X - kY,Y) )$
    # where $R_Y$ denotes the resultant with respect to the variable $Y$.
    # If $N(X)$ is not squarefree, increase $k$.
    #T:= MinimalPolynomial( Rationals, theta, yind );
    T:= CoefficientsOfUnivariatePolynomial(DefiningPolynomial(coeffring));
    T:=UnivariatePolynomial(basring,T,yind);
    repeat
      k:= k+1;
      N:= Resultant( T, Value( G, [ x, y ], [ x-k*y, y ] ), y );
    until DegreeOfUnivariateLaurentPolynomial( Gcd( N, Derivative(N) ) ) = 0;

    # Let $N = \prod_{i=1}^g N_i$ be a factorization of $N$.
    # For $1 \leq i \leq g$, set $A_i(X) = \gcd( U(X), N_i(X + k \theta) )$.
    # The desired factorization of $U(X)$ is $\prod_{i=1}^g A_i$.
    factors:= Factors( PolynomialRing( basring, [ xind ] ), N );
    factors:= List( factors,f -> AlgExtEmbeddedPol(coeffring,f));

    # over finite field alg ext we cannot multiply with Integers
    kone:=Zero(one); for j in [1..k] do kone:=kone+one; od;
    factors:= List( factors,f -> Value( f, xe + kone*theta ,one) );
    factors:= List( factors,f -> Gcd( Re, U, f ) );
    factors:=Filtered( factors,
                     x -> DegreeOfUnivariateLaurentPolynomial( x ) <> 0 );
    if IsBound(opt.testirred) and opt.testirred=true then
      return Length(factors)=1;
    fi;
    return factors;
end );

#############################################################################
##
#M  DefectApproximation(<e>)
##
InstallMethod(DefectApproximation,"Algebraic Extension",true,
  [IsAlgebraicExtension],0,
function(e)
local f, d, def, w, i, dr, g, g1, cf, f0, f1, h, p;

  if LeftActingDomain(e)<>Rationals then
    Error("DefectApproximation is only for extensions of the rationals");
  fi;
  f:=DefiningPolynomial(e);
  f:=f*Lcm(List(CoefficientsOfUnivariatePolynomial(f),DenominatorRat));
  d:=Discriminant(f);
  # largest square, that divides discriminant
  if d>=0 and RootInt(d)^2=d then
    def:=RootInt(d);
  else
    def:=Factors(AbsInt(d));
    w:=[];
    for i in def do
      if not IsPrimeInt(i) then
        i:=RootInt(i);
        Add(w,i);
      fi;
      Add(w,i);
    od;
    def:=Product(Collected(w),i->i[1]^QuoInt(i[2],2));
  fi; 
  # reduced discriminant (c.f. Bradford's thesis)
  dr:=Lcm(Union(List(GcdRepresentation(f,Derivative(f)),
          i->List(CoefficientsOfUnivariatePolynomial(i),DenominatorRat))));
  def:=Gcd(def,dr);
  for p in Filtered(Factors(def),i->i<65536 and IsPrime(i)) do
    # test, whether we can drop i:
    ##  Apply the Dedekind-Kriterion by Zassenhaus(1975), cf. Bradford's thesis.
    g:=Collected(Factors(PolynomialModP(f,p)));
    g1:=[];
    for i in g do
      cf:=CoefficientsOfUnivariateLaurentPolynomial(i[1]);
      Add(g1,LaurentPolynomialByCoefficients(FamilyObj(1),
        List(cf[1],Int),cf[2],
	IndeterminateNumberOfLaurentPolynomial(i[1])));
    od;
    f0:=Product(g1);
    f1:=Product(List([1..Length(g)],i->g1[i]^(g[i][2]-1)));
    h:=(f-f0*f1)/p;
    g:=Gcd(PolynomialModP(f1,p),PolynomialModP(h,p));

    if DegreeOfLaurentPolynomial(g)=0 then
      while IsInt(def/p) do
        def:=def/p;
      od;
    fi;
  od;
  return def;
end);


#############################################################################
##
#F  ChaNuPol(<pol>,<alphamod>,<alpha>,<modfieldbase>,<field> . reverse modulo
##  transfer pol from modfield with alg. root alphamod to field with
##  alg. root alpha by taking the standard preimages of the coefficients
##  mod p
##
BindGlobal("ChaNuPol",function(f,alm,alz,coeffun,fam,inum)
local b,p,r,nu,w,i,z,fnew;
  p:=Characteristic(alm);
  z:=Z(p);
  r:=PrimitiveRootMod(p);
  nu:=0*alm;
  b:=IsPolynomial(f);
  if b then
    f:=CoefficientsOfUnivariateLaurentPolynomial(f);
    f:=ShiftedCoeffs(f[1],f[2]);
  else
    f:=[f];
  fi;
  fnew:=[]; # f could be compressed vector, so we cannot assign to it.
  for i in [1..Length(f)] do
    w:=f[i];
    if w=nu then
      w:=Zero(alz);
    else
      if IsFFE(w) and DegreeFFE(w)=1 then
        w:=PowerModInt(r,LogFFE(w,z),p)*One(alz);
      else
        w:=ValuePol(List(coeffun(w),IntFFE),alz);
      fi;
    fi;
    #f[i]:=w;
    fnew[i]:=w;
  od;
  return UnivariatePolynomialByCoefficients(fam,fnew,inum);
end);


#############################################################################
##
#F  AlgebraicPolynomialModP(<field>,<pol>,<indetimage>,<prime>) . .  internal
##      reduces <pol> mod <prime> to a polynomial over <field>, mapping 
##      'alpha' of f to <indetimage>
##
BindGlobal("AlgebraicPolynomialModP",function(fam,f,a,p)
local fk, w, cf, i, j;
  fk:=[];
  for i in CoefficientsOfUnivariatePolynomial(f) do
    if IsRat(i) then
      Add(fk,One(fam)*(i mod p));
    else
      w:=Zero(fam);
      cf:=ExtRepOfObj(i);
      for j in [1..Length(cf)] do
        w:=w+(cf[j] mod p)*a^(j-1);
      od;
      Add(fk,w);
    fi;
  od;
  return
  UnivariatePolynomialByCoefficients(fam,fk,
    IndeterminateNumberOfUnivariateLaurentPolynomial(f));
end);

#############################################################################
##
#F  AlgFacUPrep( <f> ) . . . . Hensel preparation: f=\prod ff, \sum h_i u_i=1
##
BindGlobal("AlgFacUPrep",function(R,f)
local ff,h,u,i,j,ggt,ggr;
  h:=[];
  ff:=Factors(R,f);
  for i in [1..Length(ff)] do
    h[i]:=f/ff[i];
  od;
  u:=[One(CoefficientsFamily(FamilyObj(f)))]; 
  ggt:=h[1];
  for i in [2..Length(ff)] do
    ggr:=GcdRepresentation(ggt,h[i]);
    ggt:=Gcd(ggt,h[i]);
    for j in [1..i-1] do
      u[j]:=u[j]*ggr[1];
    od;
    u[i]:=ggr[2];
  od;
  return u;
end);

#############################################################################
##
#F  TransferedExtensionPol(<ext>,<polynomial>[,<minpol>]) 
##  interpret polynomial over different algebraic extension. If minpol
##  is given, the algebraic elements are reduced according to minpol.
##
BindGlobal("TransferedExtensionPol",function(arg)
local atc, kl, inum, alfam, red, c, operations, i;
  atc:=CoefficientsOfUnivariateLaurentPolynomial(arg[2]);
  kl:=ShallowCopy(atc[1]);
  inum:=arg[Length(arg)];
  alfam:=ElementsFamily(FamilyObj(arg[1]));
  if Length(arg)>3 then
    red:=CoefficientsOfUnivariatePolynomial(arg[3]);
    # Rational case, reduce according to Minpol
    for i in [1..Length(kl)] do
      if IsAlgebraicElement(kl[i]) then
        #c:=RemainderCoeffs(kl[i].coefficients,red);
	c:=QuotRemPolList(ExtRepOfObj(kl[i]),red)[2];
        if Length(red)=2 then
          kl[i]:=c[1];
        else
          while Length(c)<Length(red)-1 do
            Add(c,0*red[1]);
          od;
          kl[i]:=AlgExtElm(alfam,c);
        fi;
      fi;
    od;
  else
    for i in [1..Length(kl)] do
      if IsAlgebraicElement(kl[i]) then
	kl[i]:=AlgExtElm(alfam,ExtRepOfObj(kl[i]));
      fi;
    od;
  fi;
  return LaurentPolynomialByExtRepNC(RationalFunctionsFamily(alfam),
           kl,atc[2],inum);
end);

#############################################################################
##
#F  OrthogonalityDefectEuclideanLattice(<lattice>,<latticebase>)
##
BindGlobal("OrthogonalityDefectEuclideanLattice",function(bas)
  return AbsInt(Product(List(bas,i->RootInt(i*i,2)+1))/ DeterminantMat(bas));
end);

#############################################################################
##
##  AlgExtSquareHensel( <ring>, <pol> )   hensel factorization over alg.
##                    extension. Suppose f is squarefree, has valuation 0
##                  Lenstra's or Weinberger's method
##
InstallGlobalFunction(AlgExtSquareHensel,function(R,f,opt)
local K, inum, fact, degf, m, degm, dis, def, cf, d, avoid, bw, zaehl, p,
      mm, pr, mmf, nm, dm, al, kp, ff, i, gut, w, bp, bpr, bff, bkp, bal,
      bmm, kpcoeffun, fff, degs, bounds, numbound, yet, ordef, lenstra,
      weinberger, method, pex, actli, lbound, U, u, rfunfam, ext, fam, q,
      max, M, newq, a, ef, bound, Mi, ind, perm, alfam, dl, sel, act, len,
      degsm, comb, v, dd, cbn, l, ps, z, wc, j, k,methname;

  K:=CoefficientsRing(R);
  inum:=IndeterminateNumberOfUnivariateLaurentPolynomial(f);

  fact:=[];

  degf:=DegreeOfLaurentPolynomial(f);

  m:=DefiningPolynomial(K);
  if IndeterminateNumberOfUnivariateLaurentPolynomial(m)<>inum then
    m:=Value(m,Indeterminate(LeftActingDomain(K),inum));
  fi;
  degm:=DegreeOfLaurentPolynomial(m);

  dis:=Discriminant(m);

  def:=DefectApproximation(K);

  # find lcm of Denominators
  cf:=CoefficientsOfUnivariateLaurentPolynomial(f)[1];
  d:=Lcm(Concatenation(Flat(List(cf,i->List(ExtRepOfObj(i),DenominatorRat))),
	List(CoefficientsOfUnivariateLaurentPolynomial(m)[1],DenominatorRat)));

  # find prime which does not divide the denominator and minpol is sqarefree
  # mod p. This is obviously satisfied, if we take d to be the Lcm of
  # the denominators and the discriminant
 
  avoid:=Lcm(d,dis*DenominatorRat(dis)^2,def);

  bw:="infinity";
  zaehl:=1;
  p:=1;

  repeat
    p:=NextPrimeInt(p);
    while DenominatorRat(avoid/p)=1 do
      p:=NextPrimeInt(p);
    od;
    mm:=PolynomialModP(m,p);
    pr:=PolynomialRing(GF(p),[inum]);
    mmf:=Factors(pr,mm);
    nm:=Length(mmf);
    Sort(mmf,function(a,b)
               return DegreeOfLaurentPolynomial(a)>DegreeOfLaurentPolynomial(b);
             end);

    dm:=List(mmf,DegreeOfLaurentPolynomial);

    if dm[1]>1 
       # don't even risk problems with the @#$%&! valuation!
       and ForAll(mmf,i->CoefficientsOfUnivariateLaurentPolynomial(i)[2]=0) then
      al:=[];
      kp:=[];
      ff:=[];
      i:=1;
      gut:=true;
      while gut and i<=nm do

        # cope with the too small range of finite fields in GAP
        if p^DegreeOfLaurentPolynomial(mmf[i])<=65536 then
	  kp[i]:=GF(GF(p),CoefficientsOfUnivariatePolynomial(mmf[i]));
	  if DegreeOfLaurentPolynomial(mmf[i])>1 then
	    al[i]:=RootOfDefiningPolynomial(kp[i]);
	  else
	    al[i]:=CoefficientsOfUnivariateLaurentPolynomial(-mmf[i])[1][1];
	  fi;
	  kp[i]!.myBasis:=Basis(kp[i],List([0..DegreeOfLaurentPolynomial(mmf[i])-1],j->al[i]^j));
	  kp[i]!.myCoeffun:=x->Coefficients(kp[i]!.myBasis,x);
	elif (IsRat(bw) and Length(Factors(bpr,bmm))=1 and zaehl>2) then
	  # avoid our extensions if not necc.
	  gut:=false;
	  zaehl:=zaehl+1;
        else
          kp[i]:=AlgebraicExtension(GF(p),mmf[i]);
	  al[i]:=RootOfDefiningPolynomial(kp[i]);
	  kp[i]!.myCoeffun:=ExtRepOfObj;
        fi;

	if gut<>false then
	  ff[i]:=AlgebraicPolynomialModP(ElementsFamily(FamilyObj(kp[i])),f,al[i],p);

	  gut:=DegreeOfLaurentPolynomial(Gcd(ff[i],Derivative(ff[i])))<1;
	  i:=i+1;
        fi;
      od;
      if gut then
	Info(InfoPoly,2,"trying prime ",p,": ",nm," factors of minpol, ",
	Length(Factors(PolynomialRing(kp[1]),ff[1]))," factors");
        # Wert ist Produkt der Cofaktorgrade des Polynoms (wir wollen
        # m"oglichst wenig gro"se Faktoren haben) sowie des
        # Kofaktorgrades des Minimalpolynoms (wir wollen bereits
        # akzeptabel approximieren) im Kubik (da es dominieren soll).
        w:=(degm/dm[1])^3*
	    Product(List(Factors(PolynomialRing(kp[1]),ff[1]),i->DegreeOfLaurentPolynomial(f)-DegreeOfLaurentPolynomial(i)));
        if w<bw then
          bw:=w;
          bp:=p;
	  bpr:=pr;
          bff:=ff;
          bkp:=kp;
          bal:=al;
          bmm:=mm;
        fi;
        zaehl:=zaehl+1;
      fi;
    fi;

  # teste 5 Primzahlen zu Anfang
  until zaehl=6;

  # beste Werte holen
  p:=bp;
  ff:=bff;
  kp:=bkp;
  kpcoeffun:=List(kp,i->i!.myCoeffun);
  al:=bal;
  mm:=bmm;
  mmf:=Factors(bpr,mm); #is stored in pol
  nm:=Length(mmf);
  dm:=List(mmf,DegreeOfLaurentPolynomial);

  # multiply denominator by defect to be sure, that \Z[\alpha] includes the
  # algebraic integers to obtain 'result' denominator

  d:=d*def;

  fff:=List([1..Length(ff)],i->Factors(PolynomialRing(bkp[i]),ff[i]));
  Info(InfoPoly,1,"using prime ",p,": ",nm," factors of minpol, ",
           List(fff,Length)," factors");

  # check possible Degrees

  degs:=Intersection(List(fff,i->List(Combinations(List(i,DegreeOfLaurentPolynomial)),Sum)));

  degs:=Difference(degs,[0]);
  degs:=Filtered(degs,i->2*i<=degf);
  IsRange(degs);
  Info(InfoPoly,1,"possible degrees: ",degs);

  # are we lucky? 
  if Length(degs)>0 then

    bounds:=HenselBound(f,m,d);
    numbound:=bounds[Maximum(degs)];

    Info(InfoPoly,1,"Bound for factor coefficients coefficients is:",numbound);

    # first suppose we get the lattice reduced to orthogonality defect 2

    yet:=0;
    ordef:=3;
    if IsBound(opt.ordef) then ordef:=opt.ordef;fi;

    #NOCH: verwende bessere beim zweiten mal bereits bekanntes
    # geliftes

    # compute bounds and select method

    lenstra:=1;
    weinberger:=2;
    methname:=["Lenstra","Weinberger"];
    method:=weinberger;
    pex:=LogInt(2*numbound-1,p)+1;
    actli:=[1..nm];

    if nm>1 then
      w:=CoefficientsOfUnivariatePolynomial(m);
      lbound:=
	# obere Absch"atzung f"ur ||F||^(m-1)
	(w*w)^(Maximum(degs)-1)

	*(2*numbound)^degf;
      w:=Int(lbound*ordef^degf)+1;
      if LogInt(w,10)<800 then
	method:=lenstra;
	pex:=LogInt(w-1,p)+1-dm[1];
	actli:=[1];
      fi;
    fi;

    Info(InfoPoly,1,"using method ",methname[method]);

    # prep U for mm Hensel

    U:=AlgFacUPrep(bpr,mm);
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));

    # prepare u for ff Hensel
    u:=List([1..Length(ff)],i->AlgFacUPrep(PolynomialRing(bkp[i]),ff[i]));

    # alles in Charakteristik 0 transportieren

    Info(InfoPoly,1,"transporting in characteristic zero");

    rfunfam:=RationalFunctionsFamily(FamilyObj(1));
    for i in [1..nm] do
      if IsPolynomial(mmf[i]) then
	cf:=CoefficientsOfUnivariateLaurentPolynomial(mmf[i]);
	mmf[i]:=LaurentPolynomialByExtRepNC(rfunfam,List(cf[1],Int),cf[2],inum);
      else
	mmf[i]:=Int(mmf[i]);
      fi;
      if IsPolynomial(U[i]) then
	cf:=CoefficientsOfUnivariateLaurentPolynomial(U[i]);
	U[i]:=LaurentPolynomialByExtRepNC(rfunfam, List(cf[1],Int),cf[2],inum);
      else
	U[i]:=Int(U[i]);
      fi;
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));
    od;

    # dabei repr"asentieren wir die Wurzel \alpha als alg. Erweiterung mit
    # dem entsprechenden Polynom als Minpol.

    ext:=[];
    for i in actli do
      if EuclideanDegree(mmf[i])>1 then
	ext[i]:=AlgebraicExtension(Rationals,mmf[i]);
      else
	ext[i]:=Rationals;
      fi;
      if DegreeOverPrimeField(ext[i])>1 then
	w:=RootOfDefiningPolynomial(ext[i]);
      else
	w:=One(ext[i]);
      fi;
      fam:=ElementsFamily(FamilyObj(ext[i]));
      fff[i]:=List(fff[i],j->ChaNuPol(j,al[i],w,kpcoeffun[i],fam,inum));
      u[i]:=List(u[i],j->ChaNuPol(j,al[i],w,kpcoeffun[i],fam,inum));
    od;

    repeat
      # jetzt hochHenseln
      q:=p^(2^yet);

      # how many square iterations needed for bound (the p-exponent)?

      max:=p^pex;

      M:=LogInt(pex-1,2)+1;
      pex:=2^M; # the new pex

      Info(InfoPoly,1,M," quadratic steps necessary");
      for i in [1..M-yet] do
        # now lift q->q^2 (or appropriate smaller number)
        # avoid modulus too large, since the computation afterwards becomes
        # harder
	if method=lenstra then
	  newq:=q^2; # we might need the better lift.
	else
	  newq:=Minimum(q^2,max);
        fi;

        Info(InfoPoly,1,"quadratic Hensel Lifting, step ",i,", ",q,"->",newq);

        if Length(mmf)>1 then
          # more than 1 factor: actual lift necessary

          if i>1 then
            # now lift the U's

            Info(InfoPoly,2,"correcting U-inverses");
            for j in [1..nm] do
              a:=ProductMod(mmf{Difference([1..nm],[j])},q) mod mmf[j] mod q;
              U[j]:=BPolyProd(U[j], (2-APolyProd(U[j],a,q)), mmf[j], q);
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));
              #a:=a*U[j] mod mmf[j] mod q;
              #if a<>a^0 then
                #Error("U-rez");
              #fi;
            od;

          fi;

          for j in [1..nm] do
            a:=(m mod mmf[j] mod newq);
            if IsPolynomial(a) and IsPolynomial(U[j]) then
              mmf[j]:=mmf[j]+BPolyProd(U[j],a,mmf[j],newq);
            else
              mmf[j]:=mmf[j]+(U[j]*a mod mmf[j] mod newq);
            fi;
          od;

          #a:=(m-ProductMod(mmf,newq)) mod newq;
          #InfoAlg2("#I  new F-discrepancy mod ",p,"^",2^i," is ",a,
                   #"(should be 0)\n");
          #if a<>0*a then
            #Error("uh-oh");
          #fi;

        else
          mmf:=[m mod newq];
        fi;

        # transport fff etc. into the new (lifted) extension fields

        ef:=[];
        for k in actli do
          ext[k]:=AlgebraicExtension(Rationals,mmf[k]);
          # also to provoke the binding of the Ring
          w:=Indeterminate(ext[k],"X");

          for j in [1..Length(fff[k])] do
            fff[k][j]:=TransferedExtensionPol(ext[k],fff[k][j],inum);
            u[k][j]:=TransferedExtensionPol(ext[k],u[k][j],inum);
          od;

          ef[k]:=TransferedExtensionPol(ext[k],f,mmf[k],inum);
        od;
        
        # lift u's
        if i>1 then

          Info(InfoPoly,2,"correcting u-inverses");
          for k in actli do
            for j in [1..Length(u[k])] do
              a:=ProductMod(fff[k]{Difference([1..Length(u[k])],[j])},q)
                         mod fff[k][j] mod q;
              u[k][j]:=BPolyProd(u[k][j],(2-APolyProd(a,u[k][j],q)),
                                 fff[k][j],q);
              #a:=a*u[k][j] mod fff[k][j] mod q;
              #if a<>a^0 then
              #  Error("u-rez");
              #fi;
            od;
          od;

        fi;

        for k in actli do
          for j in [1..Length(fff[k])] do
            a:=(ef[k] mod fff[k][j] mod newq);
            fff[k][j]:=fff[k][j]+BPolyProd(u[k][j],a,fff[k][j],newq) mod newq;
          od;

          #a:=(ef[k]-ProductMod(fff[k],newq)) mod newq;
          #InfoAlg2("#I new discrepancy mod ",p,"^",2^i," is ",a,
                   #"(should be 0)\n");
          #if a<>0*a then
            #Error("uh-oh");
          #fi;
        od;

        # now all is fine mod newq;
        q:=newq;
      od;
 
      yet:=M;
      bound:=q/2;

      if method=lenstra then
        # prepare Lattice for mmf[1]
        
        M:=[];
        for i in [0..dm[1]-1] do
          M[i+1]:=0*[1..degm];
          M[i+1][i+1]:=p^pex;
        od;
        for i in [dm[1]..degm-1] do
	  cf:=CoefficientsOfUnivariateLaurentPolynomial(mmf[1]);
          M[i+1]:=ShiftedCoeffs(cf[1],
                                cf[2]+i-dm[1]);
          while Length(M[i+1])<degm do
            Add(M[i+1],0);
          od;
        od;

        M:=LLLint(M);
        #M:=Concatenation(M.irreducibles,M.remainders);

        w:=OrthogonalityDefectEuclideanLattice(M);
	Info(InfoPoly,1,"Orthogonality defect: ",Int(w*1000)/1000);
	a:=LogInt(Int(lbound*w^degf),p)+1-dm[1];

	# check, whether we really did not lift good enough..
        if w>ordef and a>pex then
	  Info(InfoWarning,1,"'ordef' was set too small, iterating");
          ordef:=Maximum(w,ordef+1);
	  # call again
	  opt:=ShallowCopy(opt);
	  opt.ordef:=ordef;
	  return AlgExtSquareHensel(R,f,opt);
        else
          ordef:=Int(w)+1;
        fi;
      elif method=weinberger then
        w:=ordef-1; # to skip the loop
      fi;

    until w<=ordef;

    if method=lenstra then
      M:=TransposedMat(M);
      Mi:=M^(-1);

    elif method=weinberger then
      # Prepare for Chinese remainder
      if Length(mmf)>1 then
        U:=[];
        for i in [1..nm] do
          a:=ProductMod(mmf{Difference([1..nm],[i])},q);
          U[i]:=a*(GcdRepresentation(mmf[i],a)[2] mod q) mod q;
#Assert(1,ForAll(U,i->IndeterminateNumberOfUnivariateLaurentPolynomial(i)=inum));
        od;
      else
        U:=[Indeterminate(Rationals,inum)^0];
      fi;
      # sort according to the number of factors:
      # Our 'starting' factorisation is the one with the fewest factors,
      # because this one allows the fewest number of combinations.

      ind:=[1..nm];
      Sort(ind,function(a,b)
                 return Length(fff[a])<Length(fff[b]);
               end);
      perm:=PermList(ind);
      Permuted(mmf,perm);
      Permuted(fff,perm);

      # We will start with small degrees, in a hope that there are some
      # factors of small degrees. These small degree factors are better suited
      # for trying, because we will have fewer combinations of the other
      # factorisations to try, to obtain the according one.
      # Thus sort first factorisation according to degree

      Sort(fff[1],function(a,b)
                    return
		    DegreeOfLaurentPolynomial(a)<DegreeOfLaurentPolynomial(b);
                  end);

      # For the corresponding factors, we take on the other hand large
      # degree factors first. The hard case is the one with relative large
      # factors. If in one component, the relative large factor remains
      # irreducible, we will be thus ready a bit sooner (hopefully).

      for i in [2..nm] do
        Sort(fff[i],function(a,b)
                      return
		      DegreeOfLaurentPolynomial(a)>DegreeOfLaurentPolynomial(b);
                    end);
      od;

    fi;

    al:=RootOfDefiningPolynomial(K);
    alfam:=ElementsFamily(FamilyObj(K));

    # now the hard part starts: We try all possible combinations, whether
    # they factor.

    dl:=[];
    sel:=[];
    for k in actli do
      # 'available' factors (not yet used up)
      sel[k]:=[1..Length(fff[k])];
      dl[k]:=List(fff[k],DegreeOfLaurentPolynomial);
      Info(InfoPoly,1,"Degrees[",k,"] :",dl[k]);
    od;

    act:=1;
    len:=0;

    dm:=[];
    for i in actli do
      dm[i]:=List(fff[i],DegreeOfLaurentPolynomial);
    od;

    repeat
      # factors of larger than half remaining degree we will find as
      # final cofactor
      degf:=DegreeOfLaurentPolynomial(f);
      degs:=Filtered(degs,i->2*i<=degf);

      if Length(degs)>0 and act in sel[1] then
        # all combinations of sel[1] of length len+1, that contain act:

        degsm:=degs-dm[1][act];
        comb:=Filtered(Combinations(Filtered(sel[1],i->i>act),len),
              i->Sum(dm[1]{i}) in degsm);

        # sort according to degree
        Sort(comb,function(a,b) return Sum(dm[1]{a})<Sum(dm[1]{b});end);

        comb:=List(comb,i->Union([act],i));

        gut:=true;

        i:=1;
        while gut and i<=Length(comb) do
	  Info(InfoPoly,2,"trying ",comb[i]);

          if method=lenstra then
            a:=d*ProductMod(fff[1]{comb[i]},q) mod q;
            a:=CoefficientsOfUnivariatePolynomial(a);
            v:=[];
            for j in a do
              if IsAlgebraicElement(j) then
		w:=ShallowCopy(ExtRepOfObj(j));
              else
                w:=[j];
              fi;
              while Length(w)<degm do
                Add(w,0);
              od;
              Add(v,w); 
            od;
            w:=List(v,i->Mi*i);
            w:=List(w,i->List(i,j->SignInt(j)*Int(AbsInt(j)+1/2)));
            w:=List(w,i->M*i);
            v:=(v-w)/d;
            a:=UnivariatePolynomialByCoefficients(alfam,
		List(v,i->AlgExtElm(alfam,i)),inum);

            #Print(a,"\n");
            w:=TrialQuotientRPF(f,a,bounds);
            if w<>fail then
              Info(InfoPoly,1,"factor found");
              f:=w;
              Add(fact,a);
              sel[1]:=Difference(sel[1],comb[i]);
              #fff[1]:=fff[1]{Difference([1..Length(fff[1])],comb[i])};
              gut:=false;
            fi;

          elif method=weinberger then
            # now select all other combinations of same degree
            dd:=Sum(dl[1]{comb[i]});
            #NOCH: Combinations nach Grad ordnen. Nur neue listen
            #bestimmen, wenn der Grad sich ge"andert hat.
            cbn:=[comb{[i]}];
            for j in [2..nm] do
              # all combs in component nm of desired degree
              cbn[j]:=Concatenation(List([1..QuoInt(dd,Minimum(dl[j]))],
                      i->Filtered(Combinations(sel[j],i),
                                  i->Sum(dl[j]{i})=dd)));
            od;
            if ForAny(cbn,i->Length(i)=0) then
              gut:=false;
            else
              l:=List([1..nm],i->1); # the great variable for-Loop 
              #ff:=List([1..nm],i->ProductMod(fff[i]{cbn[i][1]},q).coefficients);
	      ff:=List([1..nm],i->CoefficientsOfUnivariatePolynomial(ProductMod(fff[i]{cbn[i][1]},q)));
            fi;

            ps:=nm;
            while gut and ps>=1 do
              a:=[];
              for j in [1..dd+1] do
                w:=0;
                for k in [1..nm] do
                  z:=ff[k][j];
                  if IsAlgebraicElement(z) then
                    z:=UnivariatePolynomial(Rationals,
			 ExtRepOfObj(z),inum);
                  fi;
                  w:=w+U[k]*z mod m mod q;
                od;
                w:=d*w mod m mod q;
		wc:=ShallowCopy(CoefficientsOfUnivariatePolynomial(w));
                for k in [1..Length(wc)] do
                  if wc[k]>q/2 then
                    wc[k]:=wc[k]-q;
                  fi;
                od;
		w:=UnivariateLaurentPolynomialByCoefficients(
                     CoefficientsFamily(FamilyObj(w)),
		     wc,0,IndeterminateNumberOfUnivariateLaurentPolynomial(w));
                a[j]:=1/d*Value(w,al);
              od;

              # now try the Factor
              a:=UnivariateLaurentPolynomialByCoefficients(alfam,a,0,inum);

              Info(InfoPoly,3,"trying subcombination ",
	        List([2..nm],i->cbn[i][l[i]]));
              w:=TrialQuotientRPF(f,a,bounds);
              if w<>fail then
                Info(InfoPoly,1,"factor found");
                Add(fact,a);
                for j in [1..nm] do
                  sel[j]:=Difference(sel[j],cbn[j][l[j]]);
                od;
                f:=w;
                gut:=false;
              fi;

              # increase and update factors
              while ps>1 and l[ps]=Length(cbn[ps]) do
                l[ps]:=1;
                a:=ProductMod(fff[ps]{cbn[ps][1]},q);
                ff[ps]:=CoefficientsOfUnivariateLaurentPolynomial(a)[1];
                ps:=ps-1;
              od;
              if ps>1 then
                l[ps]:=l[ps]+1;
                a:=ProductMod(fff[ps]{cbn[ps][l[ps]]},q);
                ff[ps]:=CoefficientsOfUnivariateLaurentPolynomial(a)[1];
              fi;

              if ps>1 then
                ps:=nm;
              else
                ps:=0;
              fi;

            od;
          fi;

          i:=i+1;
        od;

        if comb=[] then
          i:=0;
        else
          # the len minimal lengths
          i:=ShallowCopy(dm[1]);
          Sort(i);
          i:=Sum(i{[1..Minimum(Length(i),len)]});
        fi;

        if gut and dm[1][act]+i>=Maximum(degs) then
          # the actual factor will always yield factors too large, thus we
          # can avoid it furthermore
	  Info(InfoPoly,2,"factor ",act," can be further neglected");
          sel[1]:=Difference(sel[1],[act]);
          gut:=false;
        fi;

      fi;

      act:=act+1;
      if sel[1]<>[] and act>Maximum(sel[1]) then
       len:=len+1;
       act:=sel[1][1];
      fi;
      
    until ForAny(sel,i->Length(i)=0)
          or Length(sel[1])<len; #nothing left to check

  fi;

  # aufr"aumen

  if f<>f^0 then
    Add(fact,f);
  fi;

  return fact;
end);

InstallMethod( FactorsSquarefree, "polynomial/alg. ext.",IsCollsElmsX,
    [ IsAlgebraicExtensionPolynomialRing, IsUnivariatePolynomial, IsRecord ],
function(r,pol,opt)

  # the second algorithm seem to have problems -- temp. disable
  if true or
 ( 
  (Characteristic(r)=0 and DegreeOverPrimeField(CoefficientsRing(r))<=4
    and DegreeOfLaurentPolynomial(pol)
          *DegreeOverPrimeField(CoefficientsRing(r))<=20) 
     or Characteristic(r)>0)
     
     then
     return AlgExtFactSQFree(r,pol,opt);
  else
    return AlgExtSquareHensel(r,pol,opt);
  fi;
end);

#############################################################################
##
#M  Factors( <R>, <algextpol> )  .  for a polynomial over a field of cyclotomics
##

InstallMethod( Factors,"alg ext polynomial",IsCollsElms,
  [IsAlgebraicExtensionPolynomialRing,IsUnivariatePolynomial],0,
function(R,pol)
local opt,irrfacs, coeffring, i, factors, ind, coeffs, val,
      lc, der, g, factor, q;

  opt:=ValueOption("factoroptions");
  PushOptions(rec(factoroptions:=rec())); # options do not hold for
                                          # subsequent factorizations
  if opt=fail then
    opt:=rec();
  fi;

  # Check whether the desired factorization is already stored.
  irrfacs:= IrrFacsPol( pol );
  coeffring:= CoefficientsRing( R );
  i:= PositionProperty( irrfacs, pair -> pair[1] = coeffring );
  if i <> fail then
    PopOptions();
    return ShallowCopy(irrfacs[i][2]);
  fi;

  # Handle (at most) linear polynomials.
  if DegreeOfLaurentPolynomial( pol ) < 2  then
    factors:= [ pol ];
    StoreFactorsPol( coeffring, pol, factors );
    PopOptions();
    return factors;
  fi;

  # Compute the valuation, split off the indeterminate as a zero.
  ind:= IndeterminateNumberOfLaurentPolynomial( pol );
  coeffs:= CoefficientsOfLaurentPolynomial( pol );
  val:= coeffs[2];
  coeffs:= coeffs[1];
  factors:= ListWithIdenticalEntries( val,
		IndeterminateOfUnivariateRationalFunction( pol ) );

  if Length( coeffs ) = 1 then

    # The polynomial is a power of the indeterminate.
    factors[1]:= coeffs[1] * factors[1];
    StoreFactorsPol( coeffring, pol, factors );
    PopOptions();
    return factors;

  elif Length( coeffs ) = 2 then

    # The polynomial is a linear polynomial times a power of the indet.
    factors[1]:= coeffs[2] * factors[1];
    factors[ val+1 ]:= LaurentPolynomialByExtRepNC( FamilyObj( pol ),
			    [coeffs[1] / coeffs[2], One(coeffring)],0,ind );
    StoreFactorsPol( coeffring, pol, factors );
    PopOptions();
    return factors;

  fi;

  # We really have to compute the factorization.
  # First split the polynomial into leading coefficient and monic part.
  lc:= coeffs[ Length( coeffs ) ];
  if not IsOne( lc ) then
    coeffs:= coeffs / lc;
  fi;
  if val = 0 then
    pol:= pol / lc;
  else
    pol:= LaurentPolynomialByExtRepNC( FamilyObj( pol ), coeffs, 0, ind );
  fi;

  # Now compute the quotient of `pol' by the g.c.d. with its derivative,
  # and factorize the squarefree part.
  der:= Derivative( pol );
  g:= Gcd( R, pol, der );
  if DegreeOfLaurentPolynomial( g ) = 0 then
    Append( factors, FactorsSquarefree( R, pol, rec() ) );
  else
    for factor in FactorsSquarefree( R, Quotient( R, pol, g ), opt ) do
      Add( factors, factor );
      q:= Quotient( R, g, factor );
      while q <> fail do
	Add( factors, factor );
	g:= q;
	q:= Quotient( R, g, factor );
      od;
    od;
  fi;

  # Adjust the first factor by the constant term.
  Assert( 2, DegreeOfLaurentPolynomial(g) = 0 );
  if not IsOne( g ) then
    lc:= g * lc;
  fi;
  if not IsOne( lc ) then
    factors[1]:= lc * factors[1];
  fi;

  # Store the factorization.
  if not IsBound(opt.stopdegs) then
    Assert( 2, Product( factors ) = pol );
    StoreFactorsPol( coeffring, pol, factors );
  fi;

  # Return the factorization.
    PopOptions();
  return factors;
end );

#############################################################################
##
#M  IsIrreducibleRingElement(<pol>)
##
InstallMethod(IsIrreducibleRingElement,"AlgPol",true,
  [IsAlgebraicExtensionPolynomialRing,IsUnivariatePolynomial],0,
function(R,pol)
local irrfacs, coeffring, i, ind, coeffs, der, g;

  # Check whether the desired factorization is already stored.
  irrfacs:= IrrFacsPol( pol );
  coeffring:= CoefficientsRing( R );
  i:= PositionProperty( irrfacs, pair -> pair[1] = coeffring );
  if i <> fail then
    return Length(irrfacs[i][2])=1;
  fi;

  # Handle (at most) linear polynomials.
  if DegreeOfLaurentPolynomial( pol ) < 2  then
    return true;
  fi;

  ind:= IndeterminateNumberOfLaurentPolynomial( pol );
  coeffs:= CoefficientsOfLaurentPolynomial( pol );
  if coeffs[2]>0 then
    return false; 
  fi;

  # Now compute the quotient of `pol' by the g.c.d. with its derivative,
  # and factorize the squarefree part.
  der:= Derivative( pol );
  g:= Gcd( R, pol, der );
  if DegreeOfLaurentPolynomial( g ) = 0 then
    return AlgExtFactSQFree( R, pol, rec(testirred:=true));
  else
    return false;
  fi;
end);


#############################################################################
##
#F  DecomPoly( <f> [,"all"] )  finds (all) ideal decompositions of rational f
##                       This is equivalent to finding subfields of K(alpha).
##
DecomPoly := function(arg)
local f,n,e,ff,p,ffp,ffd,roots,allroots,nowroots,fm,fft,comb,combi,k,h,i,j,
      gut,avoid,blocks,g,m,decom,z,R,scale,allowed,hp,hpc,a,kfam;
  f:=arg[1];
  n:=DegreeOfUnivariateLaurentPolynomial(f);
  if IsPrime(n) then
    return [];
  fi;
  if Length(Factors(f))>1 then
    Error("<f> must be irreducible");
  fi;
  allowed:=Difference(DivisorsInt(n),[1,n]);
  avoid:=Discriminant(f);
  p:=1;
  fm:=[];
  repeat
    p:=NextPrimeInt(p);
    if avoid mod p<>0 then
      fm:=Factors(PolynomialModP(f,p));
      ffd:=List(fm,DegreeOfUnivariateLaurentPolynomial);
      Sort(ffd);
      if ffd[1]=1 then
        allowed:=Intersection(allowed,List(Combinations(ffd{[2..Length(ffd)]}),
                                           i->Sum(i)+1));
      fi;
    fi;
  until Length(fm)=n or Length(allowed)=0;
  if Length(allowed)=0 then
    return [];
  fi;
  Info(InfoPoly,2,"Possible sizes: ",allowed);
  e:=AlgebraicExtension(Rationals,f);
  a:=PrimitiveElement(e);
  # lin. faktor weg
  ff:=Value(f,X(e))/(X(e)-a);
  ff:=Factors(ff);
  ffd:=List(ff,DegreeOfUnivariateLaurentPolynomial);
  Info(InfoPoly,2,Length(ff)," factors, degrees: ",ffd);
  #avoid:=Lcm(Union([avoid],
#            List(ff,i->Lcm(List(i.coefficients,NewDenominator)))));
  h:=f;
  allowed:=allowed-1;
  comb:=Filtered(Combinations([1..Length(ff)]),i->Sum(ffd{i}) in allowed);
  Info(InfoPoly,2,Length(comb)," combinations");
  k:=GF(p);
  kfam:=FamilyObj(One(k));
  Info(InfoPoly,2,"selecting prime ",p);
  #zeros;
  fm:=List(fm,i->RootsOfUPol(i)[1]);
  # now search for block:
  blocks:=[];
  gut:=false;
  h:=1;
  while h<=Length(comb) and gut=false do
    combi:=comb[h];
    Info(InfoPoly,2,"testing combination ",combi,": ");
    fft:=ff{combi};
    ffp:=List(fft,i->AlgebraicPolynomialModP(kfam,i,fm[1],p));
    roots:=Filtered(fm,i->ForAny(ffp,j->Value(j,i)=Zero(k)));
  if Length(roots)<>Sum(ffd{combi}) then
    Error("serious error");
  fi;
    allroots:=Union(roots,[fm[1]]);
    gut:=true;
    j:=1;
    while j<=Length(roots) and gut do
      ffp:=List(fft,i->AlgebraicPolynomialModP(kfam,i,roots[j],p));
      nowroots:=Filtered(allroots,i->ForAny(ffp,j->Value(j,i)=Zero(k)));
      gut := Length(nowroots)=Sum(ffd{combi});
      j:=j+1; 
    od;
    if gut then
      Info(InfoPoly,2,"block found");
      Add(blocks,combi);
      if Length(arg)>1 then
        gut:=false;
      fi;
    fi;
    h:=h+1;
  od;

  if Length(blocks)>0  then
    if Length(blocks)=1 then
      Info(InfoPoly,2,"Block of Length ",Sum(ffd{blocks[1]})+1," found");
    else
      Info(InfoPoly,2,"Blocks of Lengths ",List(blocks,i->Sum(ffd{i})+1),
                " found");
    fi;
    decom:=[];
    # compute decompositions
    for i in blocks do
      # compute h 
      hp:=(X(e)-a)*Product(ff{i});
      hpc:=Filtered(CoefficientsOfUnivariatePolynomial(hp),i->not IsAlgBFRep(i));
      gut:=0;
      repeat
        if gut=0 then
          h:=hpc[1];
        else
          h:=List(hpc,i->RandomList([-2^20..2^20]));
          Info(InfoPoly,2,"combining ",h);
          h:=h*hpc;
        fi;
        h:=UnivariatePolynomial(Rationals,h![1]);
        h:=h*Lcm(List(CoefficientsOfUnivariatePolynomial(h),DenominatorRat));
        if LeadingCoefficient(h)<0 then
          h:=-h;
        fi;
        # compute g
        j:=0;
        m:=[];
        repeat
          z:=PowerMod(h,j,f);
          z:=ShallowCopy(CoefficientsOfUnivariatePolynomial(z));
          while Length(z)<Length(CoefficientsOfUnivariatePolynomial(f))-1 do
            Add(z,0);
          od;
          Add(m,z);
          j:=j+1;
        until RankMat(m)<Length(m);
        g:=UnivariatePolynomial(Rationals,NullspaceMat(m)[1]);
        g:=g*Lcm(List(CoefficientsOfUnivariatePolynomial(g),DenominatorRat));
        if LeadingCoefficient(g)<0 then
          g:=-g;
        fi;
        gut:=gut+1;
      until DegreeOfUnivariateLaurentPolynomial(g)*DegreeOfUnivariateLaurentPolynomial(hp)=n;
      #z:=f.integerTransformation;
      #z:=f;
      #h:=Value(h,X(Rationals)*z);
      Add(decom,[g,h]);
    od;
    if Length(arg)=1 then
      decom:=decom[1];
    fi;
    return decom;
  else
    Info(InfoPoly,2,"primitive");
    return [];
  fi;
end;

#############################################################################
##
#E

