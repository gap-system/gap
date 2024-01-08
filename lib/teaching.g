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
##  This  file contains routines that are primarily of interest in a teaching
##  context. It is made part of the general system to ensure it will be
##  always installed with GAP.
##

#############################################################################
##
#F  RankQGroup( <G> )
##
##  <#GAPDoc Label="RankQGroup">
##  <ManSection>
##  <Func Name="RankQGroup" Arg='G'/>
##
##  <Description>
##  For a <M>p</M>-group <A>G</A> (see&nbsp;<Ref Func="IsQGroup"/>),
##  <Ref Func="RankQGroup"/> returns the <E>rank</E> of <A>G</A>,
##  which is defined as the minimal size of a generating system of <A>G</A>.
##  If <A>G</A> is not a <M>p</M>-group then an error is issued.
##  <Example><![CDATA[
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

#############################################################################
##
#F  ListOfDigits( <G> )
##
##  <#GAPDoc Label="ListOfDigits">
##  <ManSection>
##  <Func Name="ListOfDigits" Arg='n'/>
##
##  <Description>
##  For a positive integer <A>n</A> this function returns a list <A>l</A>,
##  consisting of the digits of <A>n</A> in decimal representation.
##  <Example><![CDATA[
##  gap> ListOfDigits(3142);
##  [ 3, 1, 4, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ListOfDigits");

#############################################################################
##
#F  RootsOfPolynomial( <p> )
##
##  <#GAPDoc Label="RootsOfPolynomial">
##  <ManSection>
##  <Func Name="RootsOfPolynomial" Arg='[R,],p'/>
##
##  <Description>
##  For a univariate polynomial <A>p</A>, this function returns all roots of
##  <A>p</A> over the ring <A>R</A>. If the ring is not specified, it defaults
##  to the ring specified by the coefficients of <A>p</A> via
##  <Ref Func="DefaultRing" Label="for ring elements"/>).
##  <Example><![CDATA[
##  gap> x:=X(Rationals,"x");;p:=x^4-1;
##  x^4-1
##  gap> RootsOfPolynomial(p);
##  [ 1, -1 ]
##  gap> RootsOfPolynomial(CF(4),p);
##  [ 1, -1, E(4), -E(4) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("RootsOfPolynomial");


#############################################################################
##
#F  ShowGcd( <a>,<b> )
##
##  <#GAPDoc Label="ShowGcd">
##  <ManSection>
##  <Func Name="ShowGcd" Arg='a,b'/>
##
##  <Description>
##  This function takes two elements <A>a</A> and <A>b</A> of an Euclidean
##  ring and returns their
##  greatest common divisor. It will print out the steps performed by the
##  Euclidean algorithm, as well as the rearrangement of these steps to
##  express the gcd as a ring combination of <A>a</A> and <A>b</A>.
##  <Example><![CDATA[
##  gap> ShowGcd(192,42);
##  192=4*42 + 24
##  42=1*24 + 18
##  24=1*18 + 6
##  18=3*6 + 0
##  The Gcd is 6
##   = 1*24 -1*18
##   = -1*42 + 2*24
##   = 2*192 -9*42
##  6
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ShowGcd");


#############################################################################
##
#F  ShowAdditionTable( <R> )
#F  ShowMultiplicationTable( <M> )
##
##  <#GAPDoc Label="ShowAdditionTable">
##  <ManSection>
##  <Func Name="ShowAdditionTable" Arg='R'/>
##  <Func Name="ShowMultiplicationTable" Arg='M'/>
##
##  <Description>
##  For a structure <A>R</A> with an addition given by <C>+</C>,
##  respectively a structure <A>M</A> with a multiplication given by <C>*</C>,
##  this command displays the addition (multiplication) table of the structure
##  in a pretty way.
##  <Example><![CDATA[
##  gap> ShowAdditionTable(GF(4));
##  +        | 0*Z(2)   Z(2)^0   Z(2^2)   Z(2^2)^2
##  ---------+------------------------------------
##  0*Z(2)   | 0*Z(2)   Z(2)^0   Z(2^2)   Z(2^2)^2
##  Z(2)^0   | Z(2)^0   0*Z(2)   Z(2^2)^2 Z(2^2)
##  Z(2^2)   | Z(2^2)   Z(2^2)^2 0*Z(2)   Z(2)^0
##  Z(2^2)^2 | Z(2^2)^2 Z(2^2)   Z(2)^0   0*Z(2)
##
##gap> ShowMultiplicationTable(GF(4));
##*        | 0*Z(2)   Z(2)^0   Z(2^2)   Z(2^2)^2
##---------+------------------------------------
##0*Z(2)   | 0*Z(2)   0*Z(2)   0*Z(2)   0*Z(2)
##Z(2)^0   | 0*Z(2)   Z(2)^0   Z(2^2)   Z(2^2)^2
##Z(2^2)   | 0*Z(2)   Z(2^2)   Z(2^2)^2 Z(2)^0
##Z(2^2)^2 | 0*Z(2)   Z(2^2)^2 Z(2)^0   Z(2^2)

##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ShowMultiplicationTable");
DeclareGlobalFunction("ShowAdditionTable");


#############################################################################
##
#F  CosetDecomposition( <G> )
##
##  <#GAPDoc Label="CosetDecomposition">
##  <ManSection>
##  <Func Name="CosetDecomposition" Arg='G,S'/>
##
##  <Description>
##  For a finite group <A>G</A> and a subgroup <M><A>S</A> \leq <A>G</A></M>
##  this function returns a partition of the elements of <A>G</A> according to
##  the (right) cosets of <A>S</A>. The result is a list of lists, each sublist
##  corresponding to one coset. The first sublist is the elements list of the
##  subgroup, the other lists are arranged accordingly.
##  <Example><![CDATA[
##  gap> CosetDecomposition(SymmetricGroup(4),SymmetricGroup(3));
##  [ [ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ],
##    [ (1,4), (1,4)(2,3), (1,2,4), (1,2,3,4), (1,3,2,4), (1,3,4) ],
##    [ (1,4,2), (1,4,2,3), (2,4), (2,3,4), (1,3)(2,4), (1,3,4,2) ],
##    [ (1,4,3), (1,4,3,2), (1,2,4,3), (1,2)(3,4), (2,4,3), (3,4) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("CosetDecomposition");

#############################################################################
##
#F  AllHomomorphismClasses( <G>,<H> )
##
##  <#GAPDoc Label="AllHomomorphismClasses">
##  <ManSection>
##  <Func Name="AllHomomorphismClasses" Arg='G,H'/>
##
##  <Description>
##  For two finite groups <A>G</A> and <A>H</A>, this function returns
##  representatives of all homomorphisms <M><A>G</A> to <A>H</A></M> up to
##  <A>H</A>-conjugacy.
##  <Example><![CDATA[
##  gap> AllHomomorphismClasses(SymmetricGroup(4),SymmetricGroup(3));
##  [ [ (2,4,3), (1,4,2,3) ] -> [ (), () ],
##    [ (2,4,3), (1,4,2,3) ] -> [ (), (1,2) ],
##    [ (2,4,3), (1,4,2,3) ] -> [ (1,2,3), (1,2) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AllHomomorphismClasses");

#############################################################################
##
#F  AllHomomorphisms( <G>,<H> )
##
##  <#GAPDoc Label="AllHomomorphisms">
##  <ManSection>
##  <Func Name="AllHomomorphisms" Arg='G,H'/>
##  <Func Name="AllEndomorphisms" Arg='G'/>
##  <Func Name="AllAutomorphisms" Arg='G'/>
##
##  <Description>
##  For two finite groups <A>G</A> and <A>H</A>, this function returns
##  all homomorphisms <M><A>G</A> to <A>H</A></M>. Since this number will
##  grow quickly, <Ref Func="AllHomomorphismClasses"/> should be used in most
##  cases.
##  <Ref Func="AllEndomorphisms"/> returns all homomorphisms from
##  <A>G</A> to itself,
##  <Ref Func="AllAutomorphisms"/> returns all bijective endomorphisms.
##  <Example><![CDATA[
##  gap> AllHomomorphisms(SymmetricGroup(3),SymmetricGroup(3));
##  [ [ (2,3), (1,2,3) ] -> [ (), () ],
##    [ (2,3), (1,2,3) ] -> [ (1,2), () ],
##    [ (2,3), (1,2,3) ] -> [ (2,3), () ],
##    [ (2,3), (1,2,3) ] -> [ (1,3), () ],
##    [ (2,3), (1,2,3) ] -> [ (2,3), (1,2,3) ],
##    [ (2,3), (1,2,3) ] -> [ (1,3), (1,2,3) ],
##    [ (2,3), (1,2,3) ] -> [ (1,3), (1,3,2) ],
##    [ (2,3), (1,2,3) ] -> [ (1,2), (1,2,3) ],
##    [ (2,3), (1,2,3) ] -> [ (2,3), (1,3,2) ],
##    [ (2,3), (1,2,3) ] -> [ (1,2), (1,3,2) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AllHomomorphisms");

#############################################################################
##
#F  AllSubgroups( <G> )
##
##  <#GAPDoc Label="AllSubgroups">
##  <ManSection>
##  <Func Name="AllSubgroups" Arg='G'/>
##
##  <Description>
##  For a finite group <A>G</A>
##  <Ref Func="AllSubgroups"/> returns a list of all subgroups of <A>G</A>,
##  intended primarily for use in class for small examples.
##  This list will quickly get very long and in general use of
##  <Ref Attr="ConjugacyClassesSubgroups"/> is recommended.
##  <Example><![CDATA[
##  gap> AllSubgroups(SymmetricGroup(3));
##  [ Group(()), Group([ (2,3) ]), Group([ (1,2) ]), Group([ (1,3) ]),
##    Group([ (1,2,3) ]), Group([ (1,2,3), (2,3) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal("AllSubgroups",
function(G)
local cl;
  cl:=ConjugacyClassesSubgroups(G);
  if Sum(cl,Size)>10^5 then
    Info(InfoPerformance,1,"G has ",Sum(cl,Size),
    " subgroups. Writing them all down\n",
    "takes lots of memory and time. Use `ConjugacyClassesSubgroups' to get\n",
    "classes up to conjugaction action, this will be more efficient!");
  fi;
  return Concatenation(List(cl,AsSSortedList));
end);

#############################################################################
##
#F  CheckDigitTestFunction( <l>,<m>,<f> )
##
##  <#GAPDoc Label="CheckDigitTestFunction">
##  <ManSection>
##  <Func Name="CheckDigitTestFunction" Arg='l,m,f'/>
##
##  <Description>
##  This function creates check digit test functions such as
##  <Ref Func="CheckDigitISBN"/> for check digit schemes that use the inner
##  products with a fixed vector modulo a number. The scheme creates will use
##  strings of <A>l</A> digits (including the check digits), the check consists
##  of taking the standard product of the vector of digits with the fixed vector
##  <A>f</A> modulo <A>m</A>; the result needs to be 0.
##
##  The function returns a function that then can be used for testing or
##  determining check digits.
##  <Example><![CDATA[
##  gap> isbntest:=CheckDigitTestFunction(10,11,[1,2,3,4,5,6,7,8,9,-1]);
##  function( arg... ) ... end
##  gap> isbntest("038794680");
##  Check Digit is 2
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("CheckDigitTestFunction");

#############################################################################
##
#F  CheckDigitISBN( <n> )
##
##  <#GAPDoc Label="CheckDigitISBN">
##  <ManSection>
##  <Func Name="CheckDigitISBN" Arg='n'/>
##  <Func Name="CheckDigitISBN13" Arg='n'/>
##  <Func Name="CheckDigitPostalMoneyOrder" Arg='n'/>
##  <Func Name="CheckDigitUPC" Arg='n'/>
##
##  <Description>
##  These functions can be used to compute, or check, check digits for some
##  everyday items. In each case what is submitted as input is either the number
##  with check digit (in which case the function returns <K>true</K> or
##  <K>false</K>), or the number without check digit (in which case the function
##  returns the missing check digit). The number can be specified as integer, as
##  string (for example in case of leading zeros) or as a sequence of arguments,
##  each representing a single digit.
##
##  The check digits tested are the 10-digit ISBN (International Standard Book
##  Number) using <Ref Func="CheckDigitISBN"/> (since arithmetic is module 11, a
##  digit 11 is represented by an X);
##  the newer 13-digit ISBN-13 using <Ref Func="CheckDigitISBN13"/>;
##  the numbers of 11-digit US postal money orders using
##  <Ref Func="CheckDigitPostalMoneyOrder"/>; and
##  the 12-digit UPC bar code found on groceries using
##  <Ref Func="CheckDigitUPC"/>.
##  <Example><![CDATA[
##  gap> CheckDigitISBN("052166103");
##  Check Digit is 'X'
##  'X'
##  gap> CheckDigitISBN("052166103X");
##  Checksum test satisfied
##  true
##  gap> CheckDigitISBN(0,5,2,1,6,6,1,0,3,1);
##  Checksum test failed
##  false
##  gap> CheckDigitISBN(0,5,2,1,6,6,1,0,3,'X'); # note single quotes!
##  Checksum test satisfied
##  true
##  gap> CheckDigitISBN13("9781420094527");
##  Checksum test satisfied
##  true
##  gap> CheckDigitUPC("07164183001");
##  Check Digit is 1
##  1
##  gap> CheckDigitPostalMoneyOrder(16786457155);
##  Checksum test satisfied
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

#############################################################################
##
#F  NumbersString( <S>,<m>[,<table>] )
##
##  <#GAPDoc Label="NumbersString">
##  <ManSection>
##  <Func Name="NumbersString" Arg='s,m [,table]'/>
##
##  <Description>
##  <Ref Func="NumbersString"/> takes a string message <A>s</A> and
##  returns a list of integers, each not exceeding the integer <A>m</A>
##  that encode the
##  message using  the scheme <M>A=11</M>, <M>B=12</M> and so on (and
##  converting lower case to upper case).
##  If a list of characters is given in <A>table</A>,
##  it is used instead for encoding).
##  <Example><![CDATA[
##  gap> l:=NumbersString("Twas brillig and the slithy toves",1000000);
##  [ 303311, 291012, 281922, 221917, 101124, 141030, 181510, 292219,
##    301835, 103025, 321529 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NumbersString");

#############################################################################
##
#F  StringNumbers( <l>,<m>[,<table>] )
##
##  <#GAPDoc Label="StringNumbers">
##  <ManSection>
##  <Func Name="StringNumbers" Arg='l,m [,table]'/>
##
##  <Description>
##  <Ref Func="StringNumbers"/> takes a list <A>l</A> of integers that was
##  encoded using <Ref Func="NumbersString"/> and the size integer <A>m</A>,
##  and returns a
##  message string, using  the scheme <M>A=11</M>, <M>B=12</M> and so on.
##  If a list of characters is given in <A>table</A>,
##  it is used instead for decoding).
##  <Example><![CDATA[
##  gap> StringNumbers(l,1000000);
##  "TWAS BRILLIG AND THE SLITHY TOVES"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("StringNumbers");

#############################################################################
##
#F  SetNameObject( <o>,<s> )
##
##  <#GAPDoc Label="SetNameObject">
##  <ManSection>
##  <Func Name="SetNameObject" Arg='o,s'/>
##
##  <Description>
##  <Ref Func="SetNameObject"/>
##  sets the string <A>s</A> as display name for object <A>o</A> in an
##  interactive session. When applying <Ref Func="View"/> to
##  object <A>o</A>, for example in the system's main loop,
##  &GAP; will print the string <A>s</A>.
##  Calling <Ref Func="SetNameObject"/> for the same object <A>o</A> with
##  <A>s</A> set to <Ref Var="fail"/>
##  deletes the special viewing setup.
##  Since use of this features potentially slows down the whole print
##  process, this function should be used sparingly.
##  <Example><![CDATA[
##  gap> SetNameObject(3,"three");
##  gap> Filtered([1..10],IsPrimeInt);
##  [ 2, three, 5, 7 ]
##  gap> SetNameObject(3,fail);
##  gap> Filtered([1..10],IsPrimeInt);
##  [ 2, 3, 5, 7 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SetNameObject");

##  SetExecutionObject(<o>,<f>)  sets a ``view execution'' for object <o>.
##  When viewing <o>, function <f> will be called on <o>. This can be used
##  to have elements display their action as symmetries of an object.
##  SetExecutionObject(<o>,fail);
##  deletes the special viewing setup.
DeclareGlobalFunction("SetExecutionObject");

InstallGlobalFunction(CosetDecomposition,function(G,S)
local i,l,e;
  e:=AsSSortedList(S);
  l:=[e];
  for i in RightTransversal(G,S) do
    if not i in S then
      Add(l,List(e,x->x*i));
    fi;
  od;
  return l;
end);


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

InstallGlobalFunction(CheckDigitTestFunction,function(len,modulo,scalars)
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

# print tables
BindGlobal("DoPrintTable",function(elm,opstring,operation)
local l,str,m,i,j,p;
  str:=[];
  elm:=ShallowCopy(elm);
  l:=Length(elm);
  for i in [1..l] do
    p:=String(elm[i]);
    Add(str,p);
  od;

  # test closure
  for i in [1..l] do
    for j in [1..l] do
      p:=operation(elm[i],elm[j]);
      if not p in elm then
        Add(elm,p);
        Add(str,String(p));
      fi;
    od;
  od;

  for i in [1..Length(str)] do
    p:=str[i];
    # shorten
    p:=ReplacedString(p,"ZmodnZObj","ZnZ");
    p:=ReplacedString(p,"ZmodpZObj","ZnZ");
    p:=ReplacedString(p,"identity ...","id");
    str[i]:=p;
  od;
  # test closure, if necessary add further elements

  m:=Maximum(List(str,Length));
  m:=Maximum(m,Length(opstring));
  while Length(opstring)<m do
    opstring:=Concatenation(opstring," ");
  od;

  for i in [1..Length(str)] do
    while Length(str[i])<m do
      str[i]:=Concatenation(str[i]," ");
    od;
  od;

  Print(opstring," |\c");
  for i in [1..l] do
    Print(" ",str[i],"\c");
  od;
  p:=ListWithIdenticalEntries((Length(elm)+1)*(m+1)+1,'-');
  p[m+2]:='+';
  Print("\n",p,"\n");
  for i in [1..l] do
    Print(str[i]," |\c");
    for j in [1..l] do
      p:=Position(elm,operation(elm[i],elm[j]));
      p:=str[p];
      Print(" ",p,"\c");
    od;
    Print("\n");
  od;
  Print("\n");
end);

InstallGlobalFunction(ShowMultiplicationTable,function(arg)
local obj,op;
  obj:=arg[1];
  if not IsList(obj) then
    obj:=AsSSortedList(obj);
  fi;
  op:=\*;
  if Length(arg)>1 and IsInt(arg[2]) then
    op:=function(a,b) return a*b mod arg[2];end;
  fi;
  DoPrintTable(obj,"*",op);
end);

InstallGlobalFunction(ShowAdditionTable,function(arg)
local obj,op;
  obj:=arg[1];
  if not IsList(obj) then
    obj:=AsSSortedList(obj);
  fi;
  op:=\+;
  if Length(arg)>1 and IsInt(arg[2]) then
    op:=function(a,b) return a+b mod arg[2];end;
  fi;
  DoPrintTable(obj,"+",op);
end);


#naming of objects

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
      Remove(OBJLIST, p);
    else
      OBJLIST[p][2]:=n;
    fi;
  elif n<>fail then
    Add(OBJLIST,[o,n]);
  fi;
end;
end);

if IsHPCGAP then
    MakeThreadLocal("NAMEDOBJECTS");
    MakeThreadLocal("EXECUTEOBJECTS");
    BindThreadLocal("NAMEDOBJECTS", []);
    BindThreadLocal("EXECUTEOBJECTS", []);
else
    NAMEDOBJECTS:=[];
    EXECUTEOBJECTS:=[];
fi;

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

# special string method for ``named'' objects.
InstallMethod(String,true,[IsObject],SUM_FLAGS,
function(o)
  local i;
  if Length(NAMEDOBJECTS)=0 then
    TryNextMethod();
  fi;

  for i in NAMEDOBJECTS do
    if i[1]=o then
      return String(i[2]);
    fi;
  od;
  TryNextMethod();
end);

# string/number list encoding
InstallGlobalFunction(NumbersString,function(arg)
  local message,modulus,table,tenpow,bound,l,m,i,p;
  message:=arg[1];
  modulus:=arg[2];
  if Length(arg)>2 then
    table:=arg[3];
  else
    table:=Concatenation(ListWithIdenticalEntries(9,0)," ",
             CHARS_UALPHA,CHARS_DIGITS,CHARS_SYMBOLS);
    message:=UppercaseString(message);
  fi;
  if modulus<Length(table) then
    Error("modulus must be at least as large as the translation table");
  fi;
  tenpow:=10^(LogInt(Length(table),10)+1);
  bound:=Int(modulus/tenpow);
  l:=[];
  m:=0;
  for i in message do
    p:=Position(table,i);
    if p=fail then
      Error("Symbol ",i,"is not encodable");
    fi;
    if m<bound then
      m:=m*tenpow+p;
    else
      Add(l,m);
      m:=p;
    fi;
  od;
  Add(l,m);
  return l;
end);

InstallGlobalFunction(StringNumbers,function(arg)
  local message,modulus,table,tenpow,l,i;
  l:=arg[1];
  modulus:=arg[2];
  if Length(arg)>2 then
    table:=arg[3];
  else
    table:=Concatenation(ListWithIdenticalEntries(9,0)," ",
             CHARS_UALPHA,CHARS_DIGITS,CHARS_SYMBOLS);
  fi;
  if modulus<Length(table) then
    Error("modulus must be at least as large as the translation table");
  fi;
  message:="";
  tenpow:=10^(LogInt(Length(table),10)+1);
  l:=Concatenation(List(l,x->Reversed(CoefficientsQadic(x,tenpow))));
  for i in l do
    if not IsBound(table[i]) then
      Error("message uses illegal symbol ",i);
    fi;
    Add(message,table[i]);
  od;
  return message;
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
  return AsSSortedList(Group(a*One(Integers mod n)));
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
      l:=Union(l,AsSSortedList(i));
    fi;
  od;
  return l;
end);


# up to G-conjugacy
InstallGlobalFunction(AllHomomorphismClasses,function(H,G)
local cl,cnt,bg,bw,bo,bi,k,gens,go,imgs,params,emb,sg,c,i;

  if not HasIsFinite(H) then
    Info(InfoPerformance,1,"Forcing finiteness test -- might not terminate");
  fi;
  if not IsFinite(H) then
    Error("the first argument must be a finite group");
  fi;

  if IsAbelian(G) and not IsAbelian(H) then
    k:=NaturalHomomorphismByNormalSubgroup(H,DerivedSubgroup(H));
    return List(AllHomomorphismClasses(Image(k),G),x->k*x);
  fi;

  cl:=ConjugacyClasses(G);

  if IsCyclic(H) then
    if Size(H)=1 then
      k:=One(H);
    else
      k:=MinimalGeneratingSet(H)[1];
    fi;
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
  if IsFinite(H) then
    repeat
      if cnt=0 then
        # first the small gen syst.
        if IsSolvableGroup(H) and CanEasilyComputePcgs(H) then
          gens:=MinimalGeneratingSet(H);
        else
          gens:=SmallGeneratingSet(H);
        fi;
        sg:=Length(gens);
      else
        # then something random
        repeat
          if Length(gens)>2 and Random(1,2)=1 then
            # try to get down to 2 gens
            gens:=List([1,2],i->Random(H));
          else
            gens:=List([1..sg],i->Random(H));
          fi;
          # try to get small orders
          for k in [1..Length(gens)] do
            go:=Order(gens[k]);
            # try a p-element
            if Random(1,3*Length(gens))=1 then
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
  else
    gens:=GeneratorsOfGroup(H);
    bg:=gens;
    imgs:=List(gens,x->cl);
    bi:=imgs;
  fi;

  if bw=0 then
    Error("trivial homomorphism not found");
  fi;

  # skipped verbal business

  Info(InfoMorph,2,"find ",bw," from ",cnt);

  if IsFinite(H) and Length(bg)>2 and cnt>Size(H)^2 and Size(G)<bw then
    Info(InfoPerformance,1,
"The group tested requires many generators. `AllHomomorphismClasses' often\n",
"#I  does not perform well for such groups -- see the documentation.");
  fi;

  params:=rec(gens:=bg,from:=H);
  # find all homs
  emb:=MorClassLoop(G,bi,params,
    # all homs = 1+8
    9);
  Info(InfoMorph,2,Length(emb)," homomorphisms");
  # skipped removal of duplicate images
  return emb;
end);

InstallGlobalFunction(AllHomomorphisms,function(G,H)
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

BindGlobal("AllAutomorphisms",G->AsSSortedList(AutomorphismGroup(G)));

BindGlobal("GallianAutoDn",AllAutomorphisms);

BindGlobal("GallianIntror2",n->RootsOfPolynomial(Indeterminate(Integers mod n)^2+1));



