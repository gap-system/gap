#############################################################################
##
#W  teaching.g                GAP library                   Alexander Hulpke
##
#H  @(#)$Id: teaching.g,v 4.4 2010/02/12 21:26:47 gap Exp $
##
#Y  Copyright (C) 2008 The GAP Group
##
##  This  file contains routines that are primarily of interest in a teaching
##  context. It is made part of the general system to ensure it will be
##  always installed with GAP.
##
Revision.teaching_g:=
  "@(#)$Id: teaching.g,v 4.4 2010/02/12 21:26:47 gap Exp $";

DeclareGlobalFunction("ListOfDigits");

DeclareGlobalFunction("RootsOfPolynomial");

DeclareGlobalFunction("ShowGcd");

##  return representatives of all homomorphisms G->H up to H-conjugacy.
DeclareGlobalFunction("AllHomomorphismClasses");

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

BindGlobal("AllSubgroups",
  G->Concatenation(List(ConjugacyClassesSubgroups(G),Elements)));


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
  if Length(arg)=1 and IsString(arg[1]) then
    l:=ShallowCopy(arg[1]);
    l:=Filtered(l,i->not i in "([-)]");
    for i in [1..Length(l)] do
      if l[i] in CHARS_DIGITS then
	l[i]:=Position(CHARS_DIGITS,l[i])-1;
      fi;
    od;
  elif Length(arg)=1 and IsInt(arg[1]) then
    a:=AbsInt(arg[1]);
    l:=[];
    while a<>0 do
      b:=a mod 10;
      Add(l,b);
      a:=(a-b)/10;
    od;
    l:=Reversed(l);
  elif Length(arg)=1 and IsList(arg[1]) 
    and ForAll(arg[1],i->(IsInt(i) and 0<=i and 9>=i) 
     or (i in CHARS_UALPHA)) then
     l:=ShallowCopy(arg[1]);
  elif IsList(arg) and ForAll(arg,i->(IsInt(i) and 0<=i and 9>=i) 
     or (i in CHARS_UALPHA)) then
     l:=ShallowCopy(arg);
  else
    Error("Number must be given as integer, as string or as list of digits");
  fi;
  return l;
end);

BindGlobal("CheckDigitTestFunction",function(len,modulo,scalars)
  return function(arg)
    local l, s, i;
    l:=CallFuncList(ListOfDigits,arg);
    if Length(l)=len or Length(l)=len-1 then
      s:=0;
      for i in [1..len-1] do
	s:=s+scalars[i]*l[i] mod modulo;
      od;
      s:=s/(-scalars[len]) mod modulo;
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
  CheckDigitTestFunction(10,11,[1,2,3,4,5,6,7,8,9,-1]));

BindGlobal("CheckDigitISBN13",
  CheckDigitTestFunction(13,10,[1,3,1,3,1,3,1,3,1,3,1,3,1]));

BindGlobal("CheckDigitPostalMoneyOrder",
  CheckDigitTestFunction(11,9,[1,1,1,1,1,1,1,1,1,1,-1]));

BindGlobal("CheckDigitUPC",
  CheckDigitTestFunction(12,10,[3,1,3,1,3,1,3,1,3,1,3,1]));



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

BindGlobal("AllAutomorphisms",G->Elements(AutomorphismGroup(G)));
BindGlobal("GallianAutoDn",AllAutomorphisms);


# up to G-conjugacy
InstallGlobalFunction(AllHomomorphismClasses,function(H,G)
local cl,cnt,bg,bw,bo,bi,k,gens,go,imgs,params,emb,clg,sg,vsu,c,i;

  if IsAbelian(G) and not IsAbelian(H) then
    k:=NaturalHomomorphismByNormalSubgroup(H,DerivedSubgroup(H));
    return List(AllHomomorphismClasses(Image(k),G),x->k*x);
  fi;

  cl:=ConjugacyClasses(G);

  if IsCyclic(H) then
    k:=SmallGeneratingSet(H)[1];
    c:=Order(k);
    Assert(1,Order(k)=Order(H));
    cl:=List(cl,Representative);
    cl:=Filtered(cl,x->IsInt(c/Order(x)));
    return List(cl,x->GroupHomomorphismByImagesNC(H,G,[k],[x]));
  fi;

  # find a suitable generating system
  bw:=infinity;
  bo:=[0,0];
  cnt:=0;
  repeat
    if cnt=0 then
      # first the small gen syst.
      gens:=SmallGeneratingSet(H);
      sg:=Length(gens);
    else
      # then something random
      repeat
	if Length(gens)>2 and Random([1,2])=1 then
	  # try to get down to 2 gens
	  gens:=List([1,2],i->Random(H));
	else
	  gens:=List([1..sg],i->Random(H));
	fi;
	# try to get small orders
	for k in [1..Length(gens)] do
	  go:=Order(gens[k]);
	  # try a p-element
	  if Random([1..3*Length(gens)])=1 then
	    gens[k]:=gens[k]^(go/(Random(Factors(go))));
	  fi;
	od;

      until Index(H,SubgroupNC(H,gens))=1;
    fi;

    go:=List(gens,Order);
    imgs:=List(go,i->Filtered(cl,j->IsInt(i/Order(Representative(j)))));
    Info(InfoMorph,3,go,":",Product(imgs,i->Sum(i,Size)));
    if Product(imgs,i->Sum(i,Size))<bw then
      bg:=gens;
      bo:=go;
      bi:=imgs;
      bw:=Product(imgs,i->Sum(i,Size));
    elif Set(go)=Set(bo) then
      # we hit the orders again -> sign that we can't be
      # completely off track
      cnt:=cnt+Int(bw/Size(G)*3);
    fi;
    cnt:=cnt+1;
  until bw/Size(G)*3<cnt;

  if bw=0 then
    Error("trivial homomorphism not found");
  fi;

  # skipped verbal business

  Info(InfoMorph,2,"find ",bw," from ",cnt);

  if Length(bg)>2 and cnt>Size(H)^2 and Size(G)<bw then
    Info(InfoPerformance,1,
    "The group tested requires many generators. `IsomorphicSubgroups' often\n",
"#I  does not perform well for such groups -- see the documentation.");
  fi;

  params:=rec(gens:=bg,from:=H);
  # find all embeddings
  emb:=MorClassLoop(G,bi,params,
    # all homs = 1+8
    9); 
  Info(InfoMorph,2,Length(emb)," homomorphisms");
  # skipped removal of duplicate images
  return emb;
end);

BindGlobal("AllHomomorphisms",function(G,H)
local c,i,m,o,j;
  c:=[];
  for i in AllHomomorphismClasses(G,H) do
    m:=MappingGeneratorsImages(i);
    o:=Orbit(H,m[2],OnTuples);
    for j in o do
      Add(c,GroupHomomorphismByImages(G,H,m[1],j));
    od;
  od;
  return c;
end);

BindGlobal("AllEndomorphisms",G->AllHomomorphisms(G,G));
BindGlobal("GallianHomoDn",AllEndomorphisms);

BindGlobal("GallianIntror2",n->RootsOfPolynomial(X(Integers mod n)^2+1));

