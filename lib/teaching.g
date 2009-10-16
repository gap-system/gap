#############################################################################
##
#W  teaching.g                GAP library                   Alexander Hulpke
##
#H  @(#)$Id: teaching.g,v 4.1 2009/01/03 00:22:55 gap Exp $
##
#Y  Copyright (C) 2008 The GAP Group
##
##  This  file contains routines that are primarily of interest in a teaching
##  context. It is made part of the general system to ensure it will be
##  always installed with GAP.
##
Revision.teaching_g:=
  "@(#)$Id: teaching.g,v 4.1 2009/01/03 00:22:55 gap Exp $";

DeclareGlobalFunction("ListOfDigits");

DeclareGlobalFunction("RootsOfPolynomial");

DeclareGlobalFunction("ShowGcd");

##  SetNameObject(<o>,<s>)  set name <s> for object <o>. When viewing the
##  object <o>, {\GAP} will print the string <s>.
##  SetNameObject(<o>,fail);
##  deletes the special viewing setup.
DeclareGlobalFunction("SetNameObject");

##  SetExecutionObject(<o>,<f>)  sets a ``view execution'' for object <o>.
##  When viewing <o>, function <f> will be called on <o>. This can be used
##  to have elements display their action as symmetries of an object.
##  SetExecutionObject(<o>,fail);
##  deletes the special viewing setup.
DeclareGlobalFunction("SetExecutionObject");

BindGlobal("StringLC",function(x,a,y,b)
local s;
  x:=String(x);
  if '+' in x or '-' in x then
    if x[1]<>'-' or '+' in x{[2..Length(x)]} or '-' in x{[2..Length(x)]} then
      x:=Concatenation("(",x,")");
    fi;
  fi;
  a:=String(a);
  if '+' in a or '-' in a then
    a:=Concatenation("(",String(a),")");
  fi;
  s:=Concatenation(x,"*",a);
  if IsOne(y) then
    s:=Concatenation(s," + ",String(b));
    return s;
  fi;
  y:=String(y);
  if '+' in y or '-' in y then
    if y[1]<>'-' or '+' in y{[2..Length(y)]} or '-' in y{[2..Length(y)]} then
      y:=Concatenation("(",y,")");
    fi;
  fi;
  if y[1]<>'-' then
    s:=Concatenation(s," + ");
  else
    s:=Concatenation(s," ");
  fi;

  b:=String(b);
  if '+' in b or '-' in b then
    b:=Concatenation("(",String(b),")");
  fi;
  s:=Concatenation(s,y,"*",b);

  return s;

end);

InstallGlobalFunction(ShowGcd,function(a,b)
local qrs, qr, oa, g, c, d, nd;
  qrs:=[];
  while not IsZero(b) do
    qr:=QuotientRemainder(a,b);
    if not IsZero(qr[1]) then
      Add(qrs,qr); # avoid a first flipping step
    fi;
    Print(a,"=",StringLC(qr[1],b,1,qr[2]),"\n");
    oa:=a;
    a:=b;
    b:=qr[2];
  od;
  Print("The Gcd is ",a,"\n");
  g:=a;

  qrs:=Reversed(qrs{[1..Length(qrs)-1]});
  a:=oa;
  c:=0;
  d:=1;

  for qr in qrs do
    b:=a;
    a:=qr[1]*b+qr[2];
    nd:=c-d*qr[1];
    c:=d;
    d:=nd;
    Print(" = ",StringLC(c,a,d,b),"\n");
  od;
  return g;
end);

InstallGlobalFunction(RootsOfPolynomial,function(arg)
  local p, R;
  p:=arg[Length(arg)];
  if not IsUnivariatePolynomial(p) then
    Error("<p> must be an univariate polynomial");
  fi;

  if IsRationalFunctionsFamilyElement(p) then # UFD
    if Length(arg)>1 then
      return RootsOfUPol(arg[1],p);
    else
      return RootsOfUPol(p);
    fi;
  else
    if Length(arg)>1 then
      R:=arg[1];
    else
      R:=DefaultRing(CoefficientsOfUnivariatePolynomial(p));
    fi;
    if Size(R)>10^7 then
      Error("R is not an UFD and too large to test for roots");
    fi;
    return Filtered(Enumerator(R),x->Value(p,x)=Zero(R));
  fi;
end);

InstallGlobalFunction(ListOfDigits,function(arg)
local a, l, b, i;
  a:=arg[1];
  if IsString(a) then
    l:=ShallowCopy(a);
    l:=Filtered(l,i->not i in "([-)]");
    for i in [1..Length(l)] do
      if l[i] in CHARS_DIGITS then
	l[i]:=Position(CHARS_DIGITS,l[i])-1;
      fi;
    od;
  elif IsInt(a) then
    a:=AbsInt(a);
    l:=[];
    while a<>0 do
      b:=a mod 10;
      Add(l,b);
      a:=(a-b)/10;
    od;
    l:=Reversed(l);
  elif IsList(a) and ForAll(a,i->(IsInt(a) and 0<=a and 9>=a) 
     or (a in CHARS_UALPHA)) then
     l:=ShallowCopy(a);
  else
    Error("Number must be given as integer, as string or as list of digits");
  fi;
  if Length(arg)>1 then
    a:=arg[2];
    if Length(l)<a then
      Info(InfoWarning,1,"Number is too short. Padding with leading zeroes");
      while Length(l)<a do
	l:=Concatenation([0],l);
      od;
    fi;
  fi;
  return l;
end);

BindGlobal("CheckDigitTestFunction",function(len,modulo,scalars)
  return function(a)
    local l, s, i;
    l:=ListOfDigits(a);
    if Length(l)=len or Length(l)=len-1 then
      s:=0;
      for i in [1..len-1] do
	s:=s+scalars[i]*l[i] mod modulo;
      od;
      s:=s*scalars[len] mod modulo;
      if s=10 then
	s:='X';
      fi;
      if Length(l)=len then
	if s=l[len] then
	  Print("Checksum test satisfied\n");
	else
	  Print("Checksum test failed\n");
	fi;
	return s=l[len];
      else # length=l-1
	Print("Check Digit is ",s,"\n");
	return s;
      fi;
    fi;
    Error("number is of wrong length");
  end;
end);

BindGlobal("CheckDigitISBN",
  CheckDigitTestFunction(10,11,[1,2,3,4,5,6,7,8,9,1]));

BindGlobal("CheckDigitISBN13",
  CheckDigitTestFunction(13,10,[1,3,1,3,1,3,1,3,1,3,1,3,-1]));

BindGlobal("CheckDigitPostalMoneyOrder",
  CheckDigitTestFunction(11,9,[1,1,1,1,1,1,1,1,1,1,1]));

BindGlobal("CheckDigitUPC",
  CheckDigitTestFunction(12,10,[3,1,3,1,3,1,3,1,3,1,3,-1]));



BindGlobal("SpecialViewSetupFunction",function(OBJLIST)
return function(o,n)
  local p;
  if not CanEasilyCompareElements(FamilyObj(o)) then
    Error("Element is in family without efficient equality test.\n",
	  "This can cause problems");
  fi;
  p:=PositionProperty(OBJLIST,x->x[1]=o);
  if p<>fail then
    if n=fail then
      # delete
      OBJLIST[p]:=OBJLIST[Length(OBJLIST)];
      Unbind(OBJLIST[Length(OBJLIST)]);
      return;
    else
      OBJLIST[p][2]:=n;
    fi;
  elif n<>fail then
    Add(OBJLIST,[o,n]);
    p:=Length(OBJLIST);
  fi;
end;
end);

NAMEDOBJECTS:=[];
EXECUTEOBJECTS:=[];

InstallGlobalFunction(SetNameObject,SpecialViewSetupFunction(NAMEDOBJECTS));
InstallGlobalFunction(SetExecutionObject,
  SpecialViewSetupFunction(EXECUTEOBJECTS));

# special view method for ``named'' objects or objects that should execute
# something.
InstallMethod(ViewObj,true,[IsObject],SUM_FLAGS,
function(o)
  local i;
  if Length(NAMEDOBJECTS)=0 and Length(EXECUTEOBJECTS)=0 then
    TryNextMethod();
  fi;

  for i in EXECUTEOBJECTS do
    if i[1]=o then
      i[2](o); # EXECUTE
    fi;
  od;

  for i in NAMEDOBJECTS do
    if i[1]=o then
      Print(i[2]);
      return;
    fi;
  od;
  TryNextMethod();
end);

# functions specific to Gallians textbook

BindGlobal("GallianUlist",function(n)
  local o;
  o:=One(Integers mod n);
  return List(Filtered([1..n-1],i->Gcd(i,n)=1),i->i*o);
end);

BindGlobal("GallianCyclic",function(n,a)
  if Gcd(a,n)<>1 then
    Error("a must be coprime to n");
  fi;
  return Elements(Group(a*One(Integers mod n)));
end);

BindGlobal("GallianOrderFrequency",function(G)
local c,l,i,p;
  c:=ConjugacyClasses(G);
  l:=[];
  for i in c do
    p:=First(l,x->x[1]=Order(Representative(i)));
    if p<>fail then
      p[2]:=p[2]+Size(i);
    else
      AddSet(l,[Order(Representative(i)),Size(i)]);
    fi;
  od;
  Print("[Order of element, Number of that order]=");
  return l;
end);

BindGlobal("GallianCstruc",function(G,s)
local c,l,i;
  c:=ConjugacyClasses(G);
  l:=[];
  for i in c do
    if CycleStructurePerm(Representative(i))=s then
      l:=Union(l,Elements(i));
    fi;
  od;
  return l;
end);

BindGlobal("GallianAutoDn",G->Elements(AutomorphismGroup(G)));

BindGlobal("GallianHomoDn",function(G)
   #TODO
end);

