#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##
##  This file contains generic methods for associative words.
##

#############################################################################
##
#F  AssignGeneratorVariables(<G>)
##
BindGlobal("DoAssignGenVars",function(gens)
local g,s;
  # test whether the variable name would be a proper identifier
  for g in gens do
     s := String(g);
     # remove < > enclosures
     s:=Filtered(s,x->x<>'<' and x<>'>');
     if not IsValidIdentifier(s) then
       Error("Variable `", s, "' would not be a proper identifier");
     fi;
     if IS_READ_ONLY_GLOBAL(s) then
       Error("Variable `", s, "' is write protected.");
     fi;
  od;
  for g in gens do
    s := String(g);
    s:=Filtered(s,x->x<>'<' and x<>'>');
    if ISBOUND_GLOBAL(s) then
      Info(InfoWarning + InfoGlobal, 1, "Global variable `", s,
           "' is already defined and will be overwritten");
    fi;
    UNBIND_GLOBAL(s);
    ASS_GVAR(s, g);
  od;
  Info(InfoWarning + InfoGlobal, 1, "Assigned the global variables ", gens);
end);

InstallMethod(AssignGeneratorVariables, "default method for a group",
        [IsGroup],
        function(G)
local gens;
  gens := GeneratorsOfGroup(G);
  DoAssignGenVars(gens);
end);

#############################################################################
##
#F  AssignGeneratorVariables(<R>)
##
InstallMethod(AssignGeneratorVariables, "default method for a ring",
        [IsRing and HasGeneratorsOfRing],
        function(G)
local gens;
  gens := GeneratorsOfRing(G);
  DoAssignGenVars(gens);
end);

#############################################################################
##
#F  AssignGeneratorVariables(<A>)
##
InstallMethod(AssignGeneratorVariables, "default method for a LOR",
        [IsLeftOperatorRing],
        function(G)
local gens;
  if IsLeftOperatorRingWithOne(G) then
    gens := GeneratorsOfLeftOperatorRingWithOne(G);
  else
    gens := GeneratorsOfLeftOperatorRing(G);
  fi;
  DoAssignGenVars(gens);
end);

# functions for syllable representation

InstallGlobalFunction(ERepAssWorProd,function(x,y)
local l,p,len,e;
  if IsEmpty(y) then
    return x;
  elif IsEmpty(x) then
    return y;
  fi;
  len:=Length(y);
  l:=Length(x)-1;
  p:=1;
  while 0<l and p<len
    and x[l]=y[p] and x[l+1]=-y[p+1] do
    l:=l-2;
    p:=p+2;
  od;

  if l<0 then
    # first argument is gone
    return y{[p..len]};
  elif len<p then
    # the second is gone
    return x{[1..l+1]};
  else
    if x[l]=y[p] then
      e:=x[l+1]+y[p+1];
      if e=0 then
        return Concatenation(x{[1..l-1]},y{[p+2..len]});
      else
        return Concatenation(x{[1..l-1]},[x[l],e],y{[p+2..len]});
      fi;
    else
      return Concatenation(x{[1..l+1]},y{[p..len]});
    fi;
  fi;
end);

InstallGlobalFunction(ERepAssWorInv,function(w)
local i,e;
  e:=[];
  # invert
  for i in [Length(w),Length(w)-2..2] do
    Add(e,w[i-1]);
    Add(e,-w[i]);
  od;
  return e;
end);

#############################################################################
##
#M  \<( <w1>, <w2> )  . . . . . . . . . . . . . . . . . . . . . . . for words
##
##  Associative words are ordered by the shortlex order of their external
##  representation.
##
InstallMethod(\<,"assoc words",IsIdenticalObj,[IsAssocWord,IsAssocWord],0,
function( x, y )
local n,m;

  x:= ExtRepOfObj( x );
  y:= ExtRepOfObj( y );
  n:=Sum([2,4..Length(x)],i->AbsInt(x[i]));
  m:=Sum([2,4..Length(y)],i->AbsInt(y[i]));
  # first length
  if n<m then
    return true;
  elif n>m then
    return false;
  fi;
  # then lex
  m:= Minimum( Length( x ), Length( y ) );
  n:=1;
  while n<=m and x[n]=y[n] do # common prefix
    n:=n+1;
  od;


  if n>Length(x) then
    return x<y; # x is a prefix of y. They could be same
  elif n>Length(y) then
    return false; # y is a prefix of x
  elif not IsInt(n/2) then
    # discrepancy at generator
    return x[n]<y[n];
  fi;

  # so the exponents disagree.
  if SignInt(x[n])<>SignInt(y[n]) then
    #they have different sign: The smaller wins
    return x[n]<y[n];
  fi;
  # but have the same sign. We need to compare the generators with the next
  # one
  if AbsInt(x[n])<AbsInt(y[n]) then
    # x runs out first
    if Length(x)<=n then
      return true;
    else
      return x[n+1]<y[n-1];
    fi;
  else
    # y runs out first
    if Length(y)<=n then
      return false;
    else
      return x[n-1]<y[n+1];
    fi;
  fi;

end );


#############################################################################
##
#M  \*( <w1>, <w2> )
##
##  Multiplication of associative words is done by concatenating the words
##  and removing adjacent pairs of an abstract generator and its inverse.
##
BindGlobal( "AssocWord_Product", function( x, y )

    local xx,    # external representation of 'x'
          l,     # current length of 'xx', minus 1
          yy,    # external representation of 'y'
          p,     # current first valid position in 'yy'
          len;   # total length of 'yy' minus 1

    # Treat the special cases that one argument is trivial.
    xx:= ExtRepOfObj( x );
    l:= Length( xx ) - 1;
    if l < 0 then
      return y;
    fi;
    yy:= ExtRepOfObj( y );
    if IsEmpty( yy ) then
      return x;
    fi;

    # Treat the case of cancellation.
    p:= 1;
    len:= Length( yy ) - 1;
    while     0 < l and p <= len
          and xx[l] = yy[p] and xx[ l+1 ] = - yy[ p+1 ] do
      l:= l-2;
      p:= p+2;
    od;

    if l < 0 then

      # The first argument has been eaten up,
      # so the product can be formed as object of the same type as 'y'.
      return AssocWord( TypeObj( y )![ AWP_PURE_TYPE ],
                        yy{ [ p .. len+1 ] } );

    elif len < p then

      # The second argument has been eaten up,
      # so the product can be formed as object of the same type as 'x'.
      return AssocWord( TypeObj( x )![ AWP_PURE_TYPE ],
                        xx{ [ 1 .. l+1 ] } );

    else

      if 1 < p then
        yy:= yy{ [ p .. len+1 ] };
        xx:= xx{ [ 1 .. l+1 ] };
      fi;

      xx:= ShallowCopy( xx );

      if xx[l] = yy[1] then

        # We have the same generator at the gluing position.
        yy:= ShallowCopy( yy );
        yy[2]:= xx[ l+1 ] + yy[2];
        Unbind( xx[l] );
        Unbind( xx[ l+1 ] );
        Append( xx, yy );

        # This is the only case where the subtypes of 'x' and 'y'
        # may be too small.
        # So let 'ObjByExtRep' choose the appropriate subtype.
        if    TypeObj( x )![ AWP_NR_BITS_EXP ]
              <= TypeObj( y )![ AWP_NR_BITS_EXP ] then
          return ObjByExtRep( FamilyObj( x ), TypeObj( y )![ AWP_NR_BITS_EXP ],
                                  yy[2], xx );
        else
          return ObjByExtRep( FamilyObj( x ), TypeObj( x )![ AWP_NR_BITS_EXP ],
                                  yy[2], xx );
        fi;

      else

        # The exponents of the result do not exceed the exponents
        # of 'x' and 'y'.
        # So the bigger of the two types will be sufficient.
        Append( xx, yy );
        if TypeObj( x )![ AWP_NR_BITS_EXP ] <= TypeObj( y )![ AWP_NR_BITS_EXP ] then
          return AssocWord( TypeObj( y )![ AWP_PURE_TYPE ], xx );
        else
          return AssocWord( TypeObj( x )![ AWP_PURE_TYPE ], xx );
        fi;

      fi;

    fi;
end );

InstallMethod( \*, "for two assoc. words in syllable rep", IsIdenticalObj,
    [ IsAssocWord and IsSyllableAssocWordRep,
      IsAssocWord and IsSyllableAssocWordRep], 0, AssocWord_Product );

InstallMethod( \*, "for two assoc. words: force syllable rep", IsIdenticalObj,
    [ IsAssocWord, IsAssocWord], 0,
function(a,b)
  return SyllableRepAssocWord(a)*SyllableRepAssocWord(b);
end);

#############################################################################
##
#M  \^( <w>, <n> )
##
##  Note that in a family of associative words without inverses no
##  cancellation can occur, and that the algorithm may use this fact.
##  So we must guarantee that words with inverses get the method that handles
##  the case of cancellation.
##
InstallMethod( \^,
    "for an assoc. word in syllable rep, and a positive integer",
    true,
    [ IsAssocWord and IsSyllableAssocWordRep, IsPosInt ], 0,
    function( x, n )

    local xx,      # external representation of 'x'
          result,  # external representation of the result
          l,       # actual length of 'xx'
          exp,     # store one exponent value
          tail;    # trailing part in 'xx' (cancels with 'head')

    if 1 < n then

      xx:= ExtRepOfObj( x );
      if IsEmpty( xx ) then
        return x;
      fi;

      l:= Length( xx );
      if l = 2 then
        n:= n * xx[2];
        return ObjByExtRep( FamilyObj( x ), 1, n, [ xx[1], n ] );
      fi;

      xx:= ShallowCopy( xx );
      if xx[1] = xx[ l-1 ] then

        # Treat the case of gluing.
        tail:= [ xx[1], xx[l] ];
        exp:= xx[2];
        xx[2]:= xx[2] + xx[l];
        Unbind( xx[  l  ] );
        Unbind( xx[ l-1 ] );

      else
        exp:= 0;
      fi;

      # Compute the 'n'-th power of 'xx'.
      result:= ShallowCopy( xx );
      n:= n - 1;
      while n <> 0 do
        if n mod 2 = 1 then
          Append( result, xx );
          n:= (n-1)/2;
        else
          n:= n/2;
        fi;
        Append( xx, xx );
      od;

      if exp = 0 then

        # The exponents in the power do not exceed the exponents in 'x'.
        return AssocWord( TypeObj( x )![ AWP_PURE_TYPE ], result );

      else

        result[2]:= exp;
        Append( result, tail );
        return ObjByExtRep( FamilyObj( x ), TypeObj( x )![ AWP_NR_BITS_EXP ],
                                xx[2], result );

      fi;

    elif n = 1 then
      return x;
    fi;
    end );

BindGlobal( "AssocWordWithInverse_Power", function( x, n )

    local xx,      # external representation of 'x'
          cxx,     # external repres. of the inverse of 'x'
          i,       # loop over 'xx'
          result,  # external representation of the result
          l,       # actual length of 'xx'
          p,       # actual position in 'xx'
          len,     # length of 'xx' minus 1
          head,    # initial part of 'xx'
          exp,     # store one exponent value
          tail;    # trailing part in 'xx' (cancels with 'head')

    # Consider special cases.
    if n = 0 then
      return One( FamilyObj( x ) );
    elif n = 1 then
      return x;
    fi;

    xx:= ExtRepOfObj( x );
    if IsEmpty( xx ) then
      return x;
    fi;

    l:= Length( xx );
    if l = 2 then
      n:= n * xx[2];
      return ObjByExtRep( FamilyObj( x ), 1, n, [ xx[1], n ] );
    fi;

    # Invert the internal representation of 'x' if necessary.
    if n < 0 then
      i:= 1;
      cxx:= [];
      while i < l do
        cxx[  l-i  ] :=   xx[  i  ];
        cxx[ l-i+1 ] := - xx[ i+1 ];
        i:= i+2;
      od;
      xx:= cxx;
      n:= -n;
    else
      xx:= ShallowCopy( xx );
    fi;

    # Treat the case of cancellation.
    # The word is split into three parts, namely
    # 'head' (1 to 'p-1'), 'xx' ('p' to 'l+1'), and 'tail' ('l+2' to 'len').
    p:= 1;
    len:= l;
    l:= l - 1;
    while xx[l] = xx[p] and xx[ l+1 ] = - xx[ p+1 ] do
      l:= l-2;
      p:= p+2;
    od;

    # Again treat a special case.
    if l = p then
      exp:= n * xx[ l+1 ];
      xx[ l+1 ]:= exp;
      return ObjByExtRep( FamilyObj( x ), TypeObj( x )![ AWP_NR_BITS_EXP ], exp, xx );
    fi;

    head:= xx{ [ 1 .. p-1 ] };
    tail:= xx{ [ l+2 .. len ] };
    xx:= xx{ [ p .. l+1 ] };
    l:= l - p + 2;

    if xx[1] = xx[ l-1 ] then

      # Treat the case of gluing.
      tail:= Concatenation( [ xx[1], xx[l] ], tail );
      exp:= xx[2];
      xx[2]:= xx[2] + xx[l];
      Unbind( xx[  l  ] );
      Unbind( xx[ l-1 ] );

    else
      exp:= 0;
    fi;

    # Compute the 'n'-th power of 'xx'.
    result:= ShallowCopy( xx );
    n:= n - 1;
    while n <> 0 do
      if n mod 2 = 1 then
        Append( result, xx );
        n:= (n-1)/2;
      else
        n:= n/2;
      fi;
      Append( xx, xx );
    od;

    # Put the three parts together.
    if exp = 0 then

      # The exponents in the power do not exceed the exponents in 'x'.
      Append( head, result );
      Append( head, tail );
      return AssocWord( TypeObj( x )![ AWP_PURE_TYPE ], head );

    else

      result[2]:= exp;
      Append( head, result );
      Append( head, tail );
      return ObjByExtRep( FamilyObj( x ), TypeObj( x )![ AWP_NR_BITS_EXP ],
                              xx[2], head );

    fi;
end );

InstallMethod( \^,
    "for an assoc. word with inverse in syllable rep, and an integer",
    true,
    [ IsAssocWordWithInverse and IsSyllableAssocWordRep, IsInt ], 0,
    AssocWordWithInverse_Power );


BindGlobal( "AssocWordWithInverse_Inverse", function( x )

    local xx,      # external representation of 'x'
          cxx,     # external repres. of the inverse of 'x'
          i,       # loop over 'xx'
          l;       # actual length of 'xx'

    # Consider special cases.
    xx:= ExtRepOfObj( x );
    if IsEmpty( xx ) then
      return x;
    fi;

    l:= Length( xx );
    if l = 2 then
      l:= - xx[2];
      return ObjByExtRep( FamilyObj( x ), 1, l, [ xx[1], l ] );
    fi;

    # Invert the internal representation of 'x'.
    i:= 1;
    cxx:= [];
    while i < l do
      cxx[  l-i  ] :=   xx[  i  ];
      cxx[ l-i+1 ] := - xx[ i+1 ];
      i:= i+2;
    od;

    # The exponents in the inverse do not exceed the exponents in 'x'.
#T ??
    return AssocWord( TypeObj( x )![ AWP_PURE_TYPE ], cxx );
end );

InstallMethod( InverseOp,
    "for an assoc. word with inverse in syllable rep",
    true,
    [ IsAssocWordWithInverse  and IsSyllableAssocWordRep], 0,
    AssocWordWithInverse_Inverse );

#############################################################################
##
#M  ReversedOp( <word> )
##
InstallOtherMethod( ReversedOp, "for an assoc. word in syllable rep", true,
    [ IsAssocWord and IsSyllableAssocWordRep], 0,
function( word )
local extrep, len, rev, i;

  extrep:= ExtRepOfObj( word );
  if IsEmpty( extrep ) then
    return word;
  fi;
  len:= Length( extrep );
  rev:= [];
  for i in [ len-1, len-3 .. 1 ] do
    Add( rev, extrep[  i  ] );
    Add( rev, extrep[ i+1 ] );
  od;

  return AssocWord( TypeObj( word )![ AWP_PURE_TYPE ], rev );
end );


#############################################################################
##
#M  Subword( <w>, <from>, <to> )
##
InstallOtherMethod( Subword,"for syllable associative word and two positions",
    true, [ IsAssocWord and IsSyllableAssocWordRep, IsPosInt, IsInt ], 0,
function( w, from, to )
local extw, pos, nextexp, firstexp, sub;
    if to<from then
      if IsMultiplicativeElementWithOne(w) then
          return One(FamilyObj(w));
      else
        Error("<from> must be less than or equal to <to>");
      fi;
    fi;

    extw:= ExtRepOfObj( w );
    to:= to - from + 1;

    # The relevant part is 'extw{ [ pos-1 .. Length( extw ) ] }'.
    pos:= 2;
    nextexp:= AbsInt( extw[ pos ] );
    while nextexp < from do
      pos:= pos + 2;
      from:= from - nextexp;
      nextexp:= AbsInt( extw[ pos ] );
    od;

    # Throw away 'Subword( w, 1, from-1 )'.
    nextexp:= nextexp - from + 1;
    if 0 < extw[ pos ] then
      firstexp:= nextexp;
    else
      firstexp:= - nextexp;
    fi;

    # Fill the subword.
    sub:= [];
    while nextexp < to do
      Add( sub, extw[ pos-1 ] );
      Add( sub, extw[ pos   ] );
      pos:= pos+2;
      to:= to - nextexp;
      nextexp:= AbsInt( extw[ pos ] );
    od;

    # Adjust the first exponent.
    if not IsEmpty( sub ) then
      sub[2]:= firstexp;
    fi;

    # Add the trailing pair.
    if 0 < to then
      Add( sub, extw[ pos-1 ] );
      if extw[ pos ] < 0 then
        Add( sub, -to );
      else
        Add( sub, to );
      fi;
    fi;

    return ObjByExtRep( FamilyObj( w ), sub );
end );

#############################################################################
##
#M  SubSyllables( <w>, <from>, <to> )
##
InstallMethod( SubSyllables,
  "for associative word and two positions, using ext rep.",true,
    [ IsAssocWord, IsPosInt, IsInt ], 0,
function( w, from, to )
local e;
  e:=ExtRepOfObj(w);
  if to<from or 2*from>Length(e) then
    return One(w);
  else
    e:=e{[2*from-1..Minimum(Length(e),2*to)]};
    return ObjByExtRep(FamilyObj(w),e);
  fi;
end);

#############################################################################
##
#M  PositionWord( <w>, <sub>, <from> )
##
InstallOtherMethod( PositionWord,"for two associative words,start at 1",
  IsIdenticalObj,[IsAssocWord ,IsAssocWord], 0,
function( w, sub )
  return PositionWord(w,sub,1);
end);

InstallMethod( PositionWord,
  "for two associative words and a positive integer, using syllables",
  IsFamFamX,[IsAssocWord and IsSyllableAssocWordRep,IsAssocWord,IsPosInt], 0,
function( w, sub, from )
local i,j,m,n,l,s,e,f,li,nomatch;

  from:=from-1; # make skip number from `from'

  i:=1; #syllableindex in w
  j:=1; #syllableindex in sub
  n:=NumberSyllables(w);
  m:=NumberSyllables(sub);


  # skip `from' letters
  l:=from+1; # index in w
  s:=0;  # the number of generators to be skipped if a supposed match did
         # not work.

  while from>0 and i<=n do
    e:=ExponentSyllable(w,i);
    if AbsInt(e)<=from then
      # skip a full syllable
      from:=from-AbsInt(e);
      i:=i+1;
    else
      f:=ExponentSyllable(sub,1);
      # skip only part of syllable. Now the behavior will differ depending
      # on whether sub could start here
      if GeneratorSyllable(w,i)=GeneratorSyllable(sub,1)
       and AbsInt(e)-from>=AbsInt(f)
       and SignInt(e)=SignInt(f) then
        # special treatment for len(sub)=1
        if m=1 then
          return l;
        fi;

        s:=AbsInt(f);
        # offset to make the syllables end fit
        l:=l+AbsInt(e)-from-s;
        li:=i;
        j:=2;
      else
        # sub cannot start here, just skip the full syllable
        l:=l+AbsInt(e)-from;
        j:=1;
      fi;

      i:=i+1;
      from:=0; #break the loop
    fi;
  od;

  while i<=n do
    nomatch:=true;
    e:=ExponentSyllable(w,i);
    if GeneratorSyllable(w,i)=GeneratorSyllable(sub,j) then
      f:=ExponentSyllable(sub,j);
      if SignInt(e)=SignInt(f) and AbsInt(e)>=AbsInt(f) then
        if j=m then
          # we are at the end and it fits nicely
          return l;
        elif AbsInt(e)=AbsInt(f) then
          # we are in the word, so the exponents must match perfectly
          if j=1 then
            # just start, set up a new possible match
            li:=i;
            s:=AbsInt(e);
          fi;
          j:=j+1;
          nomatch:=false;
        elif j=1 then
          # now AbsInt(e)>AbsInt(f) but we are just at the start and may
          # offset:
          s:=AbsInt(f);
          l:=l+AbsInt(e)-s;
          li:=i;
          j:=j+1;
          nomatch:=false;
        fi;
      fi;
    fi;

    if nomatch then
      j:=1;
      if s=0 then
        l:=l+AbsInt(e);
      else
        # there was a partial match, go one on
        l:=l+s;
        s:=0;
        i:=li;
      fi;
    fi;
    i:=i+1;

    # do we have a chance of hitting?
    if n-i<m-j then
      # no, we would run out.
      return fail;
    fi;

  od;
  return fail;
end );

#############################################################################
##
#M  SubstitutedWord( <w>, <from>, <to>, <by> )
##
InstallMethod( SubstitutedWord,
    "for assoc. word, two positive integers, and assoc. word", true,
    [ IsAssocWord, IsPosInt, IsPosInt, IsAssocWord ], 0,
function( w, from, to, by )
local lw;

  lw:=Length(w);
  # if from>to or from>|w| or to>|w| then this does not make sense
  if from>to or from>lw or to>lw then
    Error("illegal values for <from> and <to>");
  fi;

  # otherwise there are four possibilities

  # first if from=1 and to=Length(w) then
  if from=1 and to=lw then
    return by;
  # second if from=1 (and to<Length(w))  then
  elif from=1 then
      return by*Subword(w,to+1,lw);
  # third if to=1 (and from>1) then
  elif to=lw then
    return Subword(w,1,from-1)*by;
  fi;

  # finally
  return Subword(w,1,from-1)*by*Subword(w,to+1,lw);

end );

#############################################################################
##
#M SubstitutedWord(<u>,<v>,<k>,<z>)
##
## for a word u, a subword v of u, an integer i and a word z
##
## it substitutes the first occurrence of v in u, starting from
## position k, by z
##
InstallOtherMethod(SubstitutedWord,
 "for three associative words",true,
        [IsAssocWord, IsAssocWord, IsPosInt, IsAssocWord], 0,
function(u,v,k,z)
local i;
  i := PositionWord(u,v,k);
  # if i= fail then it means that v is not a subword of u after position k
  if i= fail then
    return fail;
  fi;
  return SubstitutedWord(u,i,i+Length(v)-1,z);
end);

#############################################################################
##
#M  EliminatedWord( <word>, <gen>, <by> )
##
InstallMethod( EliminatedWord,
  "for three associative words, using the external rep.",IsFamFamFam,
    [ IsAssocWord, IsAssocWord, IsAssocWord ],0,
function( word, gen, by )
local e,l,i,j,app,s;
  e:=ExtRepOfObj(word);
  gen:=GeneratorSyllable(gen,1);
  l:=[];
  for i in [1,3..Length(e)-1] do
    if e[i]=gen then
      app:=ExtRepOfObj(by^e[i+1]);
    else
      app:=e{[i,i+1]};
    fi;
    j:=Length(l)-1;
    while j>0 and Length(app)>0 and l[j]=app[1] do
      s:=l[j+1]+app[2];
      if s=0 then
        j:=j-2;
      else
        l[j+1]:=s;
      fi;
      app:=app{[3..Length(app)]};
    od;

    if j+1<Length(l) then
      l:=l{[1..j+1]};
    fi;

    if Length(app)>0 then
      Append(l,app);
    fi;
  od;
  return ObjByExtRep(FamilyObj(word),l);
end );


#############################################################################
##
#M  RenumberedWord( <word>, <renumber> )
##
InstallMethod( RenumberedWord, "associative words in syllable rep", true,
    [IsAssocWord and IsSyllableAssocWordRep, IsList], 0,
function( w, renumber )
local   t,  i;

  t := TypeObj( w );
  w := ShallowCopy(ExtRepOfObj( w ));

  for i in [1,3..Length(w)-1] do
    w[i] := renumber[ w[i] ];
  od;
  return AssocWord( t, w );
end );


#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
##  This method performs the obvious multiplications of image powers
##  except if <gens1> and <gens2> are lists of associative words in the
##  same family
##  such that additionally no cancellation happens when replacing a
##  generator power by the corresponding power of the image;
##  this special treatment is restricted to the case that the words in
##  the list <gens2> are powers of pairwise different generators in <gens1>.
##  (Note that if a generator appears in <gens2> that has been left out
##  from <gens1>, we may have cancellation.)
##
##  In the case of the above special treatment, the external representation
##  of the image word is constructed without multiplications.
##
BindGlobal( "MappedWordSyllableAssocWord", function( x, gens1, gens2 )

local i, mapped, exp,ex2,p,fameq,invimg,sel,elm;

    x:= ExtRepOfObj( x );

    # First handle the case of an identity element.
    # This happens for monoid element objects.
    if IsEmpty( x ) then
      return gens2[1] ^ 0;
    fi;

    # are the genimages simple generators themselves?
    if IsAssocWordWithInverseCollection( gens2 )
      and ForAll(gens2,i->Length(i)=1) then
      ex2:= List( gens2, ExtRepOfObj );
    else
      # not words, forget special treatment
      ex2:=fail;
    fi;

    fameq:=FamilyObj(gens1[1])=FamilyObj(gens2[1]);

    gens1:= List( gens1, ExtRepOfObj );
    sel:=Filtered([1..Length(gens1)],i->Length(gens1[i])=2 and gens1[i][2]=1);
    p:=Difference([1..Length(gens1)],sel);
    if not ForAll( gens1{p},i -> Length( i ) = 2 and i[2] = -1 ) then
      Error( "<gens1> must be proper generators or inverses" );
    fi;
    mapped:=gens2{p};
    p:=gens1{p};
    gens1:=gens1{sel};
    gens2:=gens2{sel};

    gens1:= List( gens1, x -> x[1] );
    IsSSortedList(gens1);

    if ex2 <> fail then
      ex2:=ex2{sel};

      # special treatment for words. No need to do inverses extra
      exp:= List( ex2, i -> i[2] );
      ex2:= List( ex2, i -> i[1] );
      mapped:= [];
      # to be quick, we need there are no duplications among the images:
      if Length(ex2)=Length(Set(ex2)) and not fameq then
        for i in [ 2, 4 .. Length( x ) ] do
          p:= Position( gens1, x[ i-1 ] );
          Add( mapped, ex2[p] );
          Add( mapped, exp[p] * x[i] );
        od;
      else
        for i in [ 2, 4 .. Length( x ) ] do
          p:= Position( gens1, x[ i-1 ] );
          if p = fail then
            if fameq then
              mapped:=ERepAssWorProd(mapped,[x[i-1],x[i]]);
            else
              Error("generator image not defined");
            fi;
          else
            mapped:=ERepAssWorProd(mapped,[ex2[p],exp[p]*x[i]]);
          fi;
        od;

      fi;

      mapped:= ObjByExtRep( FamilyObj( gens2[1] ), mapped );
      return mapped;
    fi;

    invimg:=List(gens1,x->fail);
    if Length(p)>0 then
      for i in [1..Length(p)] do
        invimg[Position(gens1,p[i][1])]:=mapped[i];
      od;
    fi;

    # the hard case
    p:= Position( gens1, x[1] );
    exp:=x[2];
    elm:=gens2[p];
    if exp<0 and p<>fail and invimg[p]<>fail then
      exp:=-exp;
      elm:=invimg[p];
    fi;
    if p = fail then
      mapped:= ObjByExtRep( FamilyObj( gens2[1] ), [ x[1], x[2] ] );
    else
      mapped:= elm ^ exp;
    fi;
    for i in [ 4,6 .. Length( x ) ] do
      exp:= x[ i ];
      if exp <> 0 then
        p:= Position( gens1, x[ i-1 ] );
        elm:=gens2[p];
      fi;
      if exp<0 and p<>fail and invimg[p]<>fail then
        exp:=-exp;
        elm:=invimg[p];
      fi;
      if exp <> 0 then
        if p = fail then
          mapped:= mapped * ObjByExtRep( FamilyObj( gens2[1] ),
                                          [ x[ i-1 ], x[i] ] );
        else
          mapped:= mapped * elm ^ exp;
        fi;
      fi;
    od;

    return mapped;
end );

InstallMethod( MappedWord,
  "for a syllable assoc. word, a homogeneous list, and a list",IsElmsCollsX,
  [ IsAssocWord and IsSyllableAssocWordRep, IsAssocWordCollection, IsList ],
  MappedWordSyllableAssocWord );


#############################################################################
##
#B  LengthOfLongestCommonPrefixOfTwoAssocWords(<a>,<b>)
##
##  returns the length of the longest common prefix of two
##  assoc words.
##  This is here because will be used by both
##  the BasicWreathProductOrdering and the
##  WreathProductOrdering
BindGlobal("LengthOfLongestCommonPrefixOfTwoAssocWords",
function(a,b)

  local l,i,ea,eb;

  #it runs through the words until finding a different letter
  #and returns the length of that common prefix (or zero)

  l:=0;

  # this is code which presumably has to be very fast. `Subword' is very
  # slow. So better run over syllables. (ahulpke 4/17/00)

  for i in [1..Minimum(NrSyllables(a),NrSyllables(b))] do
    ea:=ExponentSyllable(a,i);
    eb:=ExponentSyllable(b,i);
    if GeneratorSyllable(a,i)<>GeneratorSyllable(b,i)
     or SignInt(ea)<>SignInt(eb) then
      return l;
    elif ea<>eb then
      # the minimum of the exponents (both have the same sign) is the
      # largest common prefix.
      return l+Minimum(ea,eb);
    fi;
    # now generators and exponents are the same
    l:=l+ea;
  od;

  #here we know that the smallest word is a subword of the other
  #Hence the smallest word is a prefix of the other
  #and that the length is l
  return l;

end);

# functions to read a presentation as written in print
# actual evaluation function
BindGlobal("PPVWCD",Immutable(Union(CHARS_DIGITS,"+-")));
BindGlobal("PPValWord",function(gens,nams,s)
local ValNum, DoValWord, w;

  Info(InfoFpGroup,2,"Parse ",s);
  ValNum:=function(p)
  local w;
    w:="";
    while p<=Length(s) and s[p] in PPVWCD do
      Add(w,s[p]);
      p:=p+1;
    od;
    return [p,Int(w)];
  end;

  DoValWord:=function(start)
  local w, eps, p, c, g, h;
    #Print("DVV ",start," ",s,"\n");
    w:=One(gens[1]);
    eps:=1;
    p:=start;
    while p<=Length(s) do
      #Print("Loop ",p,"\n");
      c:=s[p];
      if c in ",)]^*/" then
        # separator -- stop local parsing
        return [p,w];
      elif c='(' then
        # open parenthesis
        g:=DoValWord(p+1);
        p:=g[1];
        if s[p]<>')' then
          Error("missing )");
        fi;
        p:=p+1;
        g:=g[2];
      elif c='[' then
        # commutator
        g:=DoValWord(p+1);
        p:=g[1];
        if s[p]<>',' then
          Error("missing ,");
        fi;
        h:=DoValWord(p+1);
        p:=h[1];
        if s[p]<>']' then
          Error("missing ]");
        fi;
        p:=p+1;
        g:=Comm(g[2],h[2]);
      else
        g:=PositionProperty(nams,i->i[1]=c);
        if g=fail then
          Error("missing generator ",[c]);
        fi;
        g:=gens[g];
        p:=p+1;
      fi;

      if p<=Length(s) and s[p]='^' then
        # exponentiation
        p:=p+1;
        if s[p] in "(" then
          h:=DoValWord(p+1);
          p:=h[1];
          if s[p]<>')' then
            Error("missing )");
          fi;
          p:=p+1;
          g:=g^h[2];
        elif s[p] in CHARS_LALPHA or s[p] in CHARS_UALPHA then
          h:=PositionProperty(nams,i->i[1]=s[p]);
          if h=fail then
            if IsBoundGlobal(s{[p]}) and IsInt(ValueGlobal(s{[p]})) then;
              h:=ValueGlobal(s{[p]});
              Info(InfoWarning,1,"parsing non-generator`",s{[p]},
                   "' as global variable value ",h);
              p:=p+1;
              g:=g^h;
            else
              Error("missing generator `",s{[p]},"'");
            fi;
          else
            h:=gens[h];
            p:=p+1;
            g:=g^h;
          fi;
        else
          # should be number
          h:=ValNum(p);
          p:=h[1];
          g:=g^h[2];
        fi;
      elif p<=Length(s) and s[p] in PPVWCD then
        # should be number
        h:=ValNum(p);
        p:=h[1];
        g:=g^h[2];
      fi;
      w:=w*g^eps;
      eps:=1;

      # product/quotient?
      while p<=Length(s) and s[p]='*' do
        p:=p+1;
      od;
      while p<=Length(s) and s[p]='.' do
        p:=p+1;
      od;
      while p<=Length(s) and s[p]='/' do
        p:=p+1;
        eps:=-eps;
      od;
    od;
    return [p,w];
  end;

  if s="1" then
    return One(gens[1]);
  fi;

  w:=DoValWord(1);
  return w[2];
end);

InstallGlobalFunction(ParseRelators,function(gens,r)
local invname, nams, rels, p, a, b, z, i,br;
  invname:=function(s)
  local w, i;
    w:="";
    for i in s do
      if i in CHARS_UALPHA then
        Add(w,CHARS_LALPHA[Position(CHARS_UALPHA,i)]);
      elif i in CHARS_LALPHA then
        Add(w,CHARS_UALPHA[Position(CHARS_LALPHA,i)]);
      else
        Add(w,i);
      fi;
    od;
    return w;
  end;

  if IsGroup(gens) then
    gens:=GeneratorsOfGroup(gens);
  fi;
  gens:=ShallowCopy(gens);
  nams:=List(gens,String);
  if ForAny(nams,x->Length(x)>1) then
    Error("generator names must have length 1");
  fi;
  Append(gens,List(gens,i->i^-1));
  Append(nams,List(nams,invname));
  SortParallel(nams,gens);

  rels:=[];
  while Length(r)>0 do
    p:=1;
    br:=0;
    a:=false;
    while p<=Length(r) do
      if r[p]='[' then
        br:=br+1;
      elif r[p]=']' then
        br:=br-1;
      elif r[p]=',' and br=0 then
        a:=r{[1..p-1]};
        r:=r{[p+1..Length(r)]};
        p:=Length(r)+1;
      fi;
      p:=p+1;
    od;
    if a=false then
      a:=r;
      r:="";
    fi;

    # remove fill
    a:=Filtered(a,x->not x in "\n ");

    # now check a -- does it contain equal signs?
    b:=SplitString(a,"=");


    if Length(b)=1 then
      Add(rels,PPValWord(gens,nams,b[1]));
    else
      SortBy(b, Length);
      z:=PPValWord(gens,nams,b[1]);
      for i in [2..Length(b)] do
        Add(rels,PPValWord(gens,nams,b[i])/z);
      od;
    fi;

  od;
  return rels;
end);

InstallGlobalFunction(StringFactorizationWord,function(word)
local wu, l, n, no, translate, findpatterns, nams, invnams, r, wordout, j;
  wu:=UnderlyingElement(word);
  l:=LetterRepAssocWord(wu);
  if Length(l)=0 then
    return "<identity>";
  fi;
  n:=Maximum(1,Maximum(l)+1);
  no:=n;
  translate:=[];

  findpatterns:=function(l)
  local p, c, notfound, jm, j, r, lr, z, a;
    p:=1;
    while p<Length(l) do
      c:=l[p];
      # does a repetitive phrase start?
      notfound:=true;
      jm:=p+QuoInt((Length(l)-p+1),2);
      j:=p+1;
      while j<=jm and notfound do
        if l[j]=c and l{[p..j-1]}=l{[j..2*j-p-1]} then
          notfound:=false;
        else
          j:=j+1;
        fi;
      od;
      if not notfound then
        # repetition found, define it as macro
        r:=l{[p..j-1]};
        lr:=j-p;
        z:=1; # number of extras
        while p+(z+1)*lr-1<=Length(l) and r=l{[p+z*lr..p+(z+1)*lr-1]} do
          z:=z+1;
        od;
        z:=z-1;

        # does `r' have any internal repetition?
        r:=findpatterns(r);

        a:=Position(translate,[r,z]);
        if a=fail then
          a:=n;
          translate[n]:=[r,z];
          n:=n+1;
        fi;
        # replace the word
        l:=Concatenation(l{[1..p-1]},[a],l{[j+(z)*lr..Length(l)]});
      fi;
      p:=p+1;
    od;
    return l;
  end;

  l:=findpatterns(l);

  # write out the word
  nams:=FamilyObj(wu)!.names;
  invnams:=[];
  for j in nams do
    r:=ShallowCopy(j);
    if j[1] in CHARS_LALPHA then
      r[1]:=CHARS_UALPHA[Position(CHARS_LALPHA,j[1])];
    elif j[1] in CHARS_UALPHA then
      r[1]:=CHARS_LALPHA[Position(CHARS_UALPHA,j[1])];
    else
      Error("name does not start with letter");
    fi;
    Add(invnams,r);
  od;
  r:="";
  wordout:=function(k)
  local i;
    if k>=no then
      if Length(translate[k][1])=1 and
        translate[k][1][1]<no then
          # original generator
          wordout(translate[k][1][1]);
      else
        # translated
        Add(r,'(');
        for i in translate[k][1] do
          wordout(i);
        od;
        Add(r,')');
      fi;
      Append(r,String(translate[k][2]+1));
    elif k<1 then
      Append(r,invnams[-k]);
    else
      Append(r,nams[k]);
    fi;
  end;
  for j in l do
    wordout(j);
  od;
  return r;
end);
