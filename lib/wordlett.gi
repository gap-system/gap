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
##  This  file contains  methods for   associative words  in letter
##  representation

InstallMethod(AssocWordByLetterRep, "W letter words family", true,
    [ IsWLetterWordsFamily, IsHomogeneousList ], 0,
function( F, l )
  return Objectify(F!.letterWordType,[Immutable(l)]);
end);

InstallMethod(AssocWordByLetterRep, "B letter words family", true,
    [ IsBLetterWordsFamily, IsHomogeneousList ], 0,
function( F, l )
  return Objectify(F!.letterWordType,[Immutable(STRING_SINTLIST(l))]);
end);

InstallOtherMethod(AssocWordByLetterRep, "letter words family", true,
    [ IsLetterWordsFamily, IsHomogeneousList, IsHomogeneousList ], 0,
function( F, l,gens )
local t,n,i,nl;
  n:=Length(gens);
  t:=[];
  for i in [1..n] do
    t[i]:=GeneratorSyllable(gens[i],1);
  od;
  if n>0 and (not IsRange(t) or t[1]<>1 or t[n]<>n) then
    # translate
    nl:=[];
    for i in l do
      if i<0 then Add(nl,-t[-i]);
             else Add(nl,t[i]);
      fi;
    od;
    l:=nl;
    MakeImmutable(l);
  fi;
  return AssocWordByLetterRep(F,l);
end);

InstallMethod(LetterRepAssocWord,"W letter rep",true,
  [IsWLetterAssocWordRep],0,w->w![1]);

InstallMethod(LetterRepAssocWord,"B letter rep",true,
[IsBLetterAssocWordRep],0,w->INTLIST_STRING(w![1],-1));

InstallOtherMethod(LetterRepAssocWord,"letter rep,gens",
true, #TODO: This should be IsElmsColls once the tietze code is fixed.
  [IsLetterAssocWordRep,IsHomogeneousList],0,
function(w,gens)
local n,t,i,l;
  t:=[];
  n:=Length(gens);
  for i in [1..n] do
    t[GeneratorSyllable(gens[i],1)]:=i;
  od;
  if not IsRange(t) or t[1]<>1 or t[n]<>n then
    l:=[];
    for i in LetterRepAssocWord(w) do
      if i<0 then Add(l,-t[-i]);
             else Add(l,t[i]);
      fi;
    od;
    MakeImmutable(l);
    return l;
  fi;
  return LetterRepAssocWord(w);
end);

# Earlier, seemingly slower method:
# InstallMethod( ObjByExtRep, "letter rep family", true,
#     [ IsAssocWordFamily and IsLetterWordsFamily, IsHomogeneousList ], 0,
# function( F, e )
# local n,i,l,g;
#   l:=[];
#   for i in [1,3..Length(e)-1] do
#     g:=e[i];
#     n:=e[i+1];
#     if n<0 then
#       g:=-g;
#       n:=-n;
#     fi;
#     Append(l,ListWithIdenticalEntries(n,g));
#   od;
#   return AssocWordByLetterRep(F,l);
# end);

InstallMethod( ObjByExtRep, "letter rep family", true,
    [ IsAssocWordFamily and IsLetterWordsFamily, IsHomogeneousList ], 0,
function( F, e )
local n,i,l,g;
  l:=AssocWordByLetterRep(F,[]);
  for i in [1,3..Length(e)-1] do
    g:=e[i];
    n:=e[i+1];
    if n<0 then
      g:=-g;
      n:=-n;
    fi;
    l := l * AssocWordByLetterRep(F,[g])^n;
  od;
  return l;
end);

InstallOtherMethod( ObjByExtRep, "letter rep family,integers (ignored)", true,
  [IsAssocWordFamily and IsLetterWordsFamily,IsInt,IsInt,IsHomogeneousList],0,
function( F, a,b,e )
  return ObjByExtRep(F,e);
end);


#############################################################################
##
#M  ExtRepOfObj(<wor> )
##
##  We cache the last three external representations. Thus we can use them
##  also for syllable access.
LETTER_WORD_EREP_CACHE:=[1,1,1]; # initialization with dummys
LETTER_WORD_EREP_CACHEVAL:=[1,1,1]; # initialization with dummys
LETTER_WORD_EREP_CACHEPOS:=1;

if IsHPCGAP then
  MakeThreadLocal( "LETTER_WORD_EREP_CACHE" );
  MakeThreadLocal( "LETTER_WORD_EREP_CACHEVAL" );
  MakeThreadLocal( "LETTER_WORD_EREP_CACHEPOS" );
fi;

BindGlobal("ERepLettWord",function(w)
local  i,r,elm,len,g,h,e;
  for i in [1..3] do
    if IsIdenticalObj(LETTER_WORD_EREP_CACHE[i],w) then
      return LETTER_WORD_EREP_CACHEVAL[i];
    fi;
  od;
  r:=[];
  elm:=LetterRepAssocWord(w);
  len:= Length( elm );
  if len=0 then
    return r;
  fi;
  i:= 2;
  g:=AbsInt(elm[1]);
  e:=SignInt(elm[1]);
  while i <= len do
    h:=AbsInt(elm[i]);
    if h=g then
      e:=e+SignInt(elm[i]);
    else
      Add(r,g);
      Add(r,e);
      g:=h;
      e:=SignInt(elm[i]);
    fi;
    i:=i+1;
  od;
  Add(r,g);
  Add(r,e);

  LETTER_WORD_EREP_CACHE[LETTER_WORD_EREP_CACHEPOS]:=w;
  LETTER_WORD_EREP_CACHEVAL[LETTER_WORD_EREP_CACHEPOS]:=Immutable(r);
  LETTER_WORD_EREP_CACHEPOS:=(LETTER_WORD_EREP_CACHEPOS mod 3)+1;
  return r;
end);

InstallMethod(ExtRepOfObj,"assoc word in letter rep",true,
  [IsAssocWord and IsLetterAssocWordRep],0,ERepLettWord);

InstallMethod(NumberSyllables,"assoc word in letter rep",true,
  [IsAssocWord and IsLetterAssocWordRep],0,
  w->Length(ERepLettWord(w))/2);

InstallMethod(GeneratorSyllable,"assoc word in W letter rep",true,
  [IsAssocWord and IsWLetterAssocWordRep,IsPosInt],0,
function(w,n)
  if n=1 then return AbsInt(w![1][1]);fi;
  return ERepLettWord(w)[2*n-1];
end);

InstallMethod(GeneratorSyllable,"assoc word in B letter rep",true,
  [IsAssocWord and IsBLetterAssocWordRep,IsPosInt],0,
function(w,n)
  if n=1 then return AbsInt(SINT_CHAR(w![1][1]));fi;
  return ERepLettWord(w)[2*n-1];
end);

InstallMethod(ExponentSyllable,"assoc word in letter rep",true,
  [IsAssocWord and IsLetterAssocWordRep,IsPosInt],0,
function(w,n)
  return ERepLettWord(w)[2*n];
end);

#############################################################################
##
#M  ExponentSumWord( <w>, <gen> )
##
InstallMethod( ExponentSumWord, "letter rep as.word, gen", IsIdenticalObj,
    [ IsAssocWord and IsLetterAssocWordRep, IsAssocWord ], 0,
function( w, gen )
local n, g, i;
  w:= LetterRepAssocWord( w );
  gen:= LetterRepAssocWord( gen );
  if Length( gen ) <> 1 then
    Error( "<gen> must be a generator" );
  fi;
  n:= 0;
  g:= AbsInt(gen[1]);
  for i in w do
    if i=g then
      n:=n+1;
    elif
      i=-g then
      n:=n-1;
    fi;
  od;
  if gen[1] < 0 then
    n:= -n;
  fi;
  return n;
end );

InstallMethod(ExponentSums,"assoc word in letter rep",true,
  [IsAssocWord and IsLetterAssocWordRep],0,
function(w)
local e,i;
  e:=ListWithIdenticalEntries(Length(FamilyObj(w)!.names),0);
  for i in  LetterRepAssocWord(w) do
    if i>0 then e[i]:=e[i]+1;
    else e[-i]:=e[-i]-1;
    fi;
  od;
  return e;
end);

InstallOtherMethod(ExponentSums,"assoc word in letter rep,ints",true,
  [IsAssocWord and IsLetterAssocWordRep,IsInt,IsInt],0,
function(w,from,to)
local e,i;
  if from < 2 then from:= 1; else from:= 2 * from - 1; fi;
  e:=ListWithIdenticalEntries(Length(FamilyObj(w)!.names),0);
  w:=ERepLettWord(w);
  to:= 2 * to - 1;
  if to>Length(w) then
    to:=Length(w)-1;
  fi;
  for i in [ from, from + 2 .. to ] do
    e[ w[i] ]:= e[ w[i] ] + w[ i+1 ];
  od;
  return e;
end);

InstallMethod(Length,"assoc word in letter rep",true,
  [IsAssocWord and IsLetterAssocWordRep],0,
  e->Length(e![1]));

InstallMethod(OneOp,"assoc word in W letter rep",true,
  [IsAssocWord and IsWLetterAssocWordRep and IsMultiplicativeElementWithOne],0,
  e->Objectify(FamilyObj(e)!.letterWordType,[Immutable([])]));

InstallMethod(OneOp,"assoc word in B letter rep",true,
  [IsAssocWord and IsBLetterAssocWordRep and IsMultiplicativeElementWithOne],0,
  e->Objectify(FamilyObj(e)!.letterWordType,[Immutable("")]));

InstallMethod(InverseOp,"assoc word in W letter rep",true,
  [ IsAssocWord and IsWLetterAssocWordRep and
    IsMultiplicativeElementWithInverse],0,
function(a)
local l,e;
  e:=a![1];
  l:=Length(e);
  return Objectify(FamilyObj(a)!.letterWordType,
          # invert and revert
          [-Immutable(e{[l,l-1..1]})]);
end);

InstallMethod(InverseOp,"assoc word in B letter rep",true,
  [ IsAssocWord and IsBLetterAssocWordRep and
    IsMultiplicativeElementWithInverse],0,
function(a)
local e;
  e:=REVNEG_STRING(a![1]);
  MakeImmutable(e);
  return Objectify(FamilyObj(a)!.letterWordType,[e]);
end);

InstallMethod(PrintObj,"assoc word in letter rep",true,
  [IsAssocWord and IsLetterAssocWordRep],0,
function(elm)
  Print(NiceStringAssocWord(elm));
end);


# operations for two associative words
InstallMethod(\=,"assoc words in letter rep",IsIdenticalObj,
  [IsAssocWord and IsLetterAssocWordRep,
   IsAssocWord and IsLetterAssocWordRep],0,
function(a,b)
  return a![1]=b![1];
end);

InstallMethod(\<,"assoc words in letter rep",IsIdenticalObj,
  [IsAssocWord and IsLetterAssocWordRep,
   IsAssocWord and IsLetterAssocWordRep],0,
function(a,b)
local l,m,p,q,i;
  a:=LetterRepAssocWord(a);
  b:=LetterRepAssocWord(b);
  l:=Length(a);
  m:=Length(b);
  # implement lenlex order
  if l<m then
    return true;
  elif l>m then
    return false;
  fi;
  for i in [1..l] do
    p:=AbsInt(a[i]);
    q:=AbsInt(b[i]);
    if p<q then
      return true;
    elif p>q then
      return false;
    elif a[i]<b[i] then
      return true;
    elif a[i]>b[i] then
      return false;
    fi;
  od;
  return false;
end);

# operations for two associative words
InstallMethod(\*,"assoc words in W letter rep",IsIdenticalObj,
  [IsAssocWord and IsWLetterAssocWordRep,
   IsAssocWord and IsWLetterAssocWordRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  a:=a![1];
  b:=b![1];
  # call the kernel multiplication routine
  a:=MULT_WOR_LETTREP(a,b);
  if a=false then
    return One(fam);
  else
    MakeImmutable(a);
    return Objectify(fam!.letterWordType,[a]);
  fi;
end);

# operations for two associative words
InstallMethod(\*,"assoc words in B letter rep",IsIdenticalObj,
  [IsAssocWord and IsBLetterAssocWordRep,
   IsAssocWord and IsBLetterAssocWordRep],0,
function(a,b)
local fam;
  fam:=FamilyObj(a);
  a:=a![1];
  b:=b![1];
  # call the kernel multiplication routine
  a:=MULT_BYT_LETTREP(a,b);
  if a=false then
    return One(fam);
  else
    MakeImmutable(a);
    return Objectify(fam!.letterWordType,[a]);
  fi;
end);

# power: exponent must be not equal zero.
BindGlobal( "AssocWWorLetRepPow", function(w,e)
local fam,a,l,i,j,mp,pt,head,tail,mid;
  fam:=FamilyObj(w);
  a:=w![1];
  l:=Length(a);
  if e=1 or l=0 then
    return w;
  elif e=-1 then
    return Inverse(w);
  # now e is guaranteed to be at least two
  elif e<0 then
    a:=-a{[l,l-1..1]};
    e:=-e;
  fi;

  # find overlap of word with itself
  i:=1;
  j:=l;
  while i<=j and a[i]=-a[j] do
    i:=i+1;
    j:=j-1;
  od;

  if i>j then
    Error("self-overlap over length half cannot happen");
  fi;

  head:=a{[1..j]};
  tail:=a{[i..l]};
  if e>2 then
    # get the middle part
    mid:=a{[i..j]};
    # repeat it e-2 times
    e:=e-1;
    l:=LogInt(e,2)+1;
    mp:=[mid];

    pt:=1;
    for i in [2..l] do
      pt:=pt*2;
      mp[i]:=Concatenation(mp[i-1],mp[i-1]);
    od;

    mid:=[];
    for i in [l,l-1..1] do
      if e>pt then
        e:=e-pt;
        Append(mid,mp[i]);
      fi;
      pt:=QuoInt(pt,2);
    od;

    a:=Concatenation(head,mid,tail);
  else
    a:=Concatenation(head,tail);
  fi;
  MakeImmutable(a);
  return Objectify(fam!.letterWordType,[a]);
end );

InstallMethod(\^,"assoc word in W letter rep and positive integer",true,
  [IsAssocWord and IsWLetterAssocWordRep,IsPosInt],0,AssocWWorLetRepPow);

InstallMethod(\^,"assoc word in W letter rep and negative integer",true,
  [IsAssocWord and IsWLetterAssocWordRep,IsNegRat and IsInt],0,
  AssocWWorLetRepPow);

# power: exponent must be not equal zero.
BindGlobal( "AssocBWorLetRepPow", function(w,e)
local fam,a,l,i,j,mp,pt,head,tail,mid;
  fam:=FamilyObj(w);
  a:=w![1];
  l:=Length(a);
  if e=1 or l=0 then
    return w;
  elif e=-1 then
    return Inverse(w);
  # now e is guaranteed to be at least two
  elif e<0 then
    a:=REVNEG_STRING(a);
    e:=-e;
  fi;

  # find overlap of word with itself
  i:=1;
  j:=l;
  while i<=j and SINT_CHAR(a[i])=-SINT_CHAR(a[j]) do
    i:=i+1;
    j:=j-1;
  od;

  if i>j then
    Error("self-overlap over length half cannot happen");
  fi;

  head:=a{[1..j]};
  tail:=a{[i..l]};
  if e>2 then
    # get the middle part
    mid:=a{[i..j]};
    # repeat it e-2 times
    e:=e-1;
    l:=LogInt(e,2)+1;
    mp:=[mid];

    pt:=1;
    for i in [2..l] do
      pt:=pt*2;
      mp[i]:=Concatenation(mp[i-1],mp[i-1]);
    od;

    mid:="";
    for i in [l,l-1..1] do
      if e>pt then
        e:=e-pt;
        mid:=Concatenation(mid,mp[i]);
      fi;
      pt:=QuoInt(pt,2);
    od;

    a:=Concatenation(head,mid,tail);
  else
    a:=Concatenation(head,tail);
  fi;
  MakeImmutable(a);
  return Objectify(fam!.letterWordType,[a]);
end );

InstallMethod(\^,"assoc word in B letter rep and positive integer",true,
  [IsAssocWord and IsBLetterAssocWordRep,IsPosInt],0,AssocBWorLetRepPow);

InstallMethod(\^,"assoc word in B letter rep and negative integer",true,
  [IsAssocWord and IsBLetterAssocWordRep,IsNegRat and IsInt],0,
  AssocBWorLetRepPow);

#############################################################################
##
#M  ReversedOp( <word> )
##
InstallOtherMethod( ReversedOp, "for an assoc. word in letter rep", true,
    [ IsAssocWord and IsLetterAssocWordRep], 0,
function( word )
local l;
  l:=Reversed(word![1]);
  MakeImmutable(l);
  return Objectify(FamilyObj(word)!.letterWordType,[l]);
end );

#############################################################################
##
#M  Subword( <w>, <from>, <to> )
##
InstallOtherMethod( Subword,"for letter associative word and two positions",
    true, [ IsAssocWord and IsLetterAssocWordRep, IsPosInt, IsInt ], 0,
function( w, from, to )
local l;
  if to<from then
    if IsMultiplicativeElementWithOne(w) then
      return One(FamilyObj(w));
    else
      Error("<from> must be less than or equal to <to>");
    fi;
  fi;
  l:=w![1]{[from..to]};
  MakeImmutable(l);
  return Objectify(FamilyObj(w)!.letterWordType,[l]);
end);

#############################################################################
##
#M  PositionWord( <w>, <sub>, <from> )
##
InstallMethod( PositionWord,
  "for two associative words and a positive integer, using letters",
  IsFamFamX,[IsAssocWord and IsLetterAssocWordRep,IsAssocWord,IsPosInt],0,
function( w, sub, from )
  # the from index is handled differently between PositionWord and
  # PositionSublist!
  return PositionSublist(w![1],sub![1],from-1);
end);

#TODO: EliminatedWord method (but its nowhere used, so low priority

#############################################################################
##
#M  RenumberedWord( <word>, <renumber> )
##
InstallMethod( RenumberedWord, "associative words in letter rep", true,
    [IsAssocWord and IsLetterAssocWordRep, IsList], 0,
function( w, renumber )
local   f,  i;

  f := FamilyObj(w);
  w := ShallowCopy(LetterRepAssocWord(w));

  for i in [1..Length(w)-1] do
    if w[i]<0 then
      w[i] := -renumber[ -w[i] ];
    else
      w[i] := renumber[ w[i] ];
    fi;
  od;
  return AssocWordByLetterRep(f,w);
end );

#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
InstallMethod( MappedWord,
  "for a letter assoc. word, a homogeneous list, and a list",IsElmsCollsX,
  [ IsAssocWord and IsLetterAssocWordRep, IsAssocWordCollection, IsList ],
function( x, gens1, gens2 )
local i,l,fam,e,m,mm,p,inv;

  if IsEmpty( gens1) then
    return x;
  elif Length( x )=0 then
    return gens2[1] ^ 0;
  fi;

  fam:=FamilyObj(x);
  x:=LetterRepAssocWord(x);
  l:=Length(x);

  gens1:= List( gens1, LetterRepAssocWord );
  if not ForAll( gens1, i -> Length( i ) = 1 ) then
    Error( "<gens1> must be proper generators or inverses" );
  fi;
  gens1:= List( gens1, i -> i[1] );
  IsSSortedList(gens1);

  # are the genimages simple generators themselves?
  if IsAssocWordWithInverseCollection(gens2)
     and ForAll(gens2,i->Length(i)=1 and not IsStraightLineProgElm(i)) then
    e:= List( gens2, i->LetterRepAssocWord(i)[1] );
    if Length(e)=Length(Set(e,AbsInt)) then
      # all images are different, no overlap. Try to form the image word
      # directly
      m:=ShallowCopy(x);
      i:=1;
      while i<=l and IsList(m) do
        p:=Position(gens1,AbsInt(m[i]));
        if p=fail then
          m:=fail; # extra generators in word -- could be overlap, dangerous
        else
          m[i]:=e[p]*SignInt(m[i]);
        fi;
        i:=i+1;
      od;
      # all worked?
      if IsList(m) then
        return AssocWordByLetterRep(FamilyObj(gens2[1]),m);
      fi;
      #no -- go the long way
    fi;
  fi;

  # List of given, or computed, inverses
  inv:=[];
  for i in [1..Length(gens1)] do
    p:=Position(gens1,-gens1[i]);
    if p<>fail then
      inv[i]:=gens2[p];
    elif gens1[i]>0 then
      if x[1]=-gens1[i] or Number(x,j->j=-gens1[i])>1 then
        # if it is a generator and its inverse occurs at least twice,
        # or its inverse occurs in the first position, then
        # (pre)-compute the inverse (otherwise just rely on the / operator
        # which can be slightly faster than inverse+product)
        inv[i]:=Inverse(gens2[i]);
      fi;
    fi;
  od;

  m:=fail;
  for i in [1..Length(x)] do
    p:= Position(gens1,x[i]);
    if p<>fail then
      mm:=gens2[p];
    elif x[i]<0 then
      # was the inverse give/precomputed
      p:= Position(gens1,-x[i]);
      if p=fail then
        # unmapped letter gen
        mm:=AssocWordByLetterRep(fam,[x[i]]);
      elif IsBound(inv[p]) then
        mm:=inv[p];
      else
        mm:=fail; # to flag that division will happen
      fi;
    else
      # unmapped letter gen
      mm:=AssocWordByLetterRep(fam,[x[i]]);
    fi;

    if m=fail then
      m:=mm;
    elif mm<>fail then
      m:=m*mm;
    else
      m:=m/gens2[p];
    fi;
  od;

  return m;
end );
