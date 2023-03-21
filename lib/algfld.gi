#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
BindGlobal( "StoreAlgExtFam", function(p,f,fam)
local   aef;
  aef:=AlgebraicElementsFamilies(p);
  if not ForAny(aef,i->i[1]=f) then
    Add(aef,[f,fam]);
  fi;
end );

#############################################################################
##
#M  AlgebraicElementsFamily      generic method
##
InstallMethod(AlgebraicElementsFamily,"generic",true,
  [IsField,IsUnivariatePolynomial,IsBool],0,
function(f,p,check)
  local fam, i, impattr, deg, neg, red, z, new, c;
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

  fam!.poly:=p;
  fam!.polCoeffs:=CoefficientsOfUnivariatePolynomial(p);
  deg:=DegreeOfLaurentPolynomial(p);
  fam!.deg:=deg;
  i:=List([1..DegreeOfLaurentPolynomial(p)],i->fam!.zeroCoefficient);
  i[2]:=fam!.oneCoefficient;
  i:=ImmutableVector(f,i,true);
  fam!.primitiveElm:=MakeImmutable(ObjByExtRep(fam,i));
  fam!.indeterminateName:=MakeImmutable("a");

  # reductions
  neg := -fam!.polCoeffs{[1..deg]};
  if not IsOne(fam!.polCoeffs[deg+1]) then
    neg := fam!.polCoeffs[deg+1]^-1 * neg;
  fi;
  red := [neg];
  z := 0*neg;
  for i in [1..deg-2] do
    new := ShiftedCoeffs(red[i], 1);
    if Length(new) > deg then
      c := Remove(new);
      if not IsZero(c) then
        new := new + c*neg;
      fi;
    elif Length(new) < deg then
      Append(new, z{[1..deg-Length(new)]});
    fi;
    Add(red, new);
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
BindGlobal( "DoAlgebraicExt", function(f,p,extra...)
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
  e:=Objectify(NewType(colf,
      IsAlgebraicExtensionDefaultRep and IsAlgebraicExtension),
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
end );

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
  if ForAll(e{[2..fam!.deg]}, i -> i = fam!.zeroCoefficient) then
    return Objectify(fam!.baseType, [e[1]]);
  fi;
  MakeImmutable(e);
  return Objectify(fam!.extType, [e]);
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
local fam,b,i;
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
local i,fam,f,g,t,h,rf,rg,rh;
  fam:=FamilyObj(a);
  f:=a![1];
  g:=ShallowCopy(fam!.polCoeffs);
  rf:=[fam!.oneCoefficient];
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
  rf:=ImmutableVector(fam!.baseField, rf, true);
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
  l:=ImmutableVector(fam!.baseField,l,true);
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
local cof;
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


InstallMethod( FactorsSquarefree, "polynomial/alg. ext.",IsCollsElmsX,
    [ IsAlgebraicExtensionPolynomialRing, IsUnivariatePolynomial, IsRecord ],
    AlgExtFactSQFree);

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
local irrfacs, coeffring, i, coeffs, der, g;

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
#F  IdealDecompositionsOfPolynomial( <f> [,"onlyone"] )  finds ideal decompositions of rational f
##                       This is equivalent to finding subfields of K(alpha).
##
InstallGlobalFunction(IdealDecompositionsOfPolynomial,function(f)
local n,e,ff,p,ffp,ffd,roots,allroots,nowroots,fm,fft,comb,combi,k,h,i,j,
      gut,avoid,blocks,g,m,decom,z,allowed,hp,hpc,a,kfam,only;

  only:=ValueOption("onlyone")=true;
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
      if only<>true then gut:=false; fi;
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
    return decom;
  else
    Info(InfoPoly,2,"primitive");
    return [];
  fi;
end);
