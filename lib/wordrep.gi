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
##  This  file contains  methods for   associative words in syllable
##  representation.
##
##  Currently,  there are four  representations for objects with the external
##  representation as list of generators  numbers and exponents (so not  only
##  for  associative  words but  perhaps  also for   elements  in a  finitely
##  presented group).
##
##  The   representations differ  w.r.t. the  space  needed   by the internal
##  representation:
##
##  the first three need 8, 16, 32 bits for each generator/exponent pair, and
##  the last  uses the list defined  by  the external representation  also as
##  internal data.
##
##  The    result of an arithmetic    operation  with  objects   of the  same
##  representation  will be also of that  representation if this is possible.
##  The  result  of  an  arithmetic   operation  with  objects  of  different
##  representations  will be the bigger  one of the two  if this is possible.
##  Otherwise `ObjByExtRep' will choose the smallest possible representation.
##  In all cases the representation of the operands is *not* changed.
##


#############################################################################
##
#R  Is8BitsAssocWord( <obj> )
#R  Is16BitsAssocWord( <obj> )
#R  Is32BitsAssocWord( <obj> )
#R  IsInfBitsAssocWord( <obj> )
##

DeclareRepresentation( "Is8BitsAssocWord",
    IsSyllableAssocWordRep and IsDataObjectRep, [] );

DeclareRepresentation( "Is16BitsAssocWord",
    IsSyllableAssocWordRep and IsDataObjectRep, [] );

DeclareRepresentation( "Is32BitsAssocWord",
    IsSyllableAssocWordRep and IsDataObjectRep, [] );

DeclareRepresentation( "IsInfBitsAssocWord",
    IsSyllableAssocWordRep and IsPositionalObjectRep,[]);

#############################################################################
##
#V  AWP_PURE_TYPE
#V  AWP_NR_BITS_EXP
#V  AWP_NR_GENS
#V  AWP_NR_BITS_PAIR
#V  AWP_FUN_OBJ_BY_VECTOR
#V  AWP_FUN_ASSOC_WORD
#V  AWP_FIRST_FREE
##
##  are positions of non-defining data in the types of associative words,
##  namely
##  - the pure type of the object itself, without knowledge features,
##  - the number of bits available for each exponent,
##  - the number of generators,
##  - the number of bits available for each generator/exponent pair,
##  - the construction function to be called by `ObjByVector',
##  - the construction function to be called by `AssocWord',
##  - the first position that can be used for private purposes.
##
##  This data must be provided already in the construction of the family,
##  in order to make sure that calls of `NewType' fetch types that know
##  this data.
##


#############################################################################
##
#F  InfBits_AssocWord( <Type>, <list> )
##
BindGlobal( "InfBits_AssocWord", function( Type, list )

    local n,
          i,
          j;

    # Check that the data is admissible.
    n:= Type![ AWP_NR_GENS ];
    if Length( list ) mod 2 <> 0 then
      Error( "<list> must have even length" );
    fi;
    for i in [ 1 .. Length( list ) / 2 ] do
      j:= 2*i - 1;
      if not ( IsInt( list[j] ) and list[j] > 0 and list[j] <= n ) then
        Error( "value at odd position <j> must denote generator" );
      fi;
      if not IsInt( list[ j+1 ] ) then
        Error( "value at even position <j+1> must be an integer" );
      fi;
    od;
    return Objectify( Type, [ Immutable( list ) ] );
end );


# code for printing words in factored form. This pattern searching clearly
# is improvable
BindGlobal("FindSubstringPowers",function(l,n)
local new,t,i,step,lstep,z,zz,j,a,k,good,bad,lim,plim;
  new:=0;
  t:=[];
  z:=Length(l);
  # first deal with large powers to avoid x^1000 being an obstacle.
  plim:=9; # length for treating large powers-1
  j:=1;
  while j+plim<=Length(l) do
    if ForAll([1..plim],x->l[j]=l[j+x]) then
      k:=j+plim;
      while k<Length(l) and l[j]=l[k+1] do
        k:=k+1;
      od;
      zz:=[0,l[j],k-j+1];
      a:=Position(t,zz);
      if a=fail then
        new:=new+1;
        t[new]:=zz;
        a:=new;
      fi;
      l:=Concatenation(l{[1..j-1]},[a+n],l{[k+1..Length(l)]});
    fi;
    j:=j+1;
  od;
  z:=Length(l);

  # long matches first, we then treat the subpatterns themselves again
  j:=QuoInt(z,2);
  lstep:=j;
  while lstep>=2 do
    step:=lstep;
    zz:=z-2*step+1;
#Print(step," ",z," ",zz,"\n");
    i:=1;
    while i<=zz do
      good:=true;
      bad:=true;
      k:=i;
      lim:=i+step-1;
      while good and k<=lim do
        good:=l[k]=l[k+step];
        if bad and l[k]<>l[i] then bad:=false;fi;
        k:=k+1;
      od;

      if good and not bad then
        # found # step match of nonidentity pattern

        # did we recognize a power of a power only?
        a:=First(Difference(DivisorsInt(step),[1,step]),
          d->ForAll([1..step/d],q->ForAll([0..d-1],x->
            l[i+x]=l[i+q*d+x])));

        if a<>fail then
#Print(i," ",a," ",step," ",z,"\n");
          # a is the length of the subpattern we should have recognized.
          step:=a;
          zz:=z-2*step+1;
        fi;

        # any further match?
        j:=i+step;
        while j<=zz and ForAll([j..j+step-1],x->l[x]=l[x+step]) do
          j:=j+step;
        od;

        new:=new+1;
        t[new]:=l{[i..i+step-1]}; # new unit
        zz:=1+(j-i)/step;

        l:=Concatenation(l{[1..i-1]},ListWithIdenticalEntries(zz,new+n),
                        l{[j+step..z]});
        i:=i+zz-1; # position after the repeat
        z:=Length(l);
        if step<>lstep then
          # we temporarily used a shorter length -- reset
          step:=lstep;
          i:=i;
        fi;
        # we only need to use the *rest* for pattern length. This will help
        # for huge powers of short expressions.
        lstep:=Minimum(lstep,QuoInt(z-zz,2));
        zz:=z-2*step+1;

      fi;
      i:=i+1;
    od;
    lstep:=lstep-1;
  od;

  return [l,t];

end);

# should we try to find subword run lengths? Can be true, false, or a length
# threshold up to which to try.
PRINTWORDPOWERS:=true;

DeclareGlobalName("DoNSAW");
BindGlobal( "DoNSAW", function(l,names,tseed)
local a,n,t,
      word,
      exp,
      i,j,
      str;

  n:=Length(names);
  if (PRINTWORDPOWERS=true
   or (IsInt(PRINTWORDPOWERS) and Length(l)<PRINTWORDPOWERS)) and
     ValueOption("printnopowers")<>true then
    if Length(l)>0 and n=infinity then
      n:=2*(Maximum(List(l,AbsInt))+1);
    fi;
    a:=FindSubstringPowers(l,n+Length(tseed)); # tseed numbers are used already
  else
    a:=[l,[]];
  fi;
  word:=a[1];
  a[2]:=Concatenation(tseed,a[2]);

  i:= 1;
  str:= "";
  while i <= Length(word) do
    if i>1 then
      Add( str, '*' );
    fi;
    exp:=1;
    if word[i]>n then
      t:=a[2][word[i]-n];
      # is it a power stored specially?
      if t[1]=0 then
        if t[2]<0 then
          Append( str, names[ -t[2] ] );
          Append( str, "^-" );
          Append( str, String(t[3]));
        else
          Append( str, names[ t[2] ] );
          Append( str, "^" );
          Append( str, String(t[3]));
        fi;
      else
        # decode longer word -- it will occur as power, so use ()
        Add(str,'(');
        Append(str,DoNSAW(t,names,Filtered(a[2],x->x[1]=0)));
        Add(str,')');
      fi;
    elif word[i]<0 then
      Append( str, names[ -word[i] ] );
      exp:=-1;
    else
      Append( str, names[ word[i] ] );
    fi;
    if i<Length(word) and word[i]=word[i+1] then
      j:=i;
      i:=i+1;
      while i<=Length(word) and word[j]=word[i] do
        i:=i+1;
      od;
      Add( str, '^' );
      Append( str, String(exp*(i-j)) );
    elif exp=-1 then
      Append(str,"^-1");
      i:=i+1;
    else
      # no power -- just normal letter
      i:=i+1;
    fi;
  od;
  ConvertToStringRep( str );
  return str;
end );

BindGlobal("NiceStringAssocWord",function(elm)
local names,word;
  names:= FamilyObj( elm )!.names;
  word:= LetterRepAssocWord( elm );
  if Length(word)=0 then
    return "<identity ...>";
  fi;
  word:=DoNSAW(word,names,[]);
  return word;
end);



#############################################################################
##
#M  Print( <w> )
##
InstallMethod( PrintObj, "for an associative word", true, [ IsAssocWord ], 0,
function( elm )
  Print(NiceStringAssocWord(elm));
end );


#############################################################################
##
#M  String( <w> )
##
InstallMethod( String, "for an associative word", true, [ IsAssocWord ], 0,
  NiceStringAssocWord);

#############################################################################
##
#F  AssocWord( <Type>, <descr> )
##
InstallGlobalFunction( AssocWord, function( Type, descr )
    return Type![ AWP_FUN_ASSOC_WORD ]( Type![ AWP_PURE_TYPE ], descr );
end );


#############################################################################
##
#M  ObjByExtRep( <F>, <descr> )
##
BindGlobal("SyllableWordObjByExtRep",function( F, descr )
local maxexp,   # maximal exponent in `descr'
      i,        # loop over exponents in `descr'
      expbits;  # list of maximal exponents for the four representations

  maxexp:= 0;
  for i in [ 2, 4 .. Length( descr ) ] do
    if maxexp < descr[i] then
      maxexp:= descr[i];
    elif maxexp < - descr[i] then
      maxexp:= - descr[i];
    fi;
  od;
  if IsInfBitsFamily(F) then
    return AssocWord( F!.types[4], descr );
  fi;

  expbits:= F!.expBitsInfo;
  if   maxexp < expbits[2] then
    if maxexp < expbits[1] then
      return AssocWord( F!.types[1], descr );
    else
      return AssocWord( F!.types[2], descr );
    fi;
  elif maxexp < expbits[3] then
      return AssocWord( F!.types[3], descr );
  else
      return AssocWord( F!.types[4], descr );
  fi;
end );

InstallMethod( ObjByExtRep,
    "for a family of associative words, and a homogeneous list", true,
    [ IsAssocWordFamily and IsSyllableWordsFamily, IsHomogeneousList ], 0,
    SyllableWordObjByExtRep);

InstallMethod(SyllableRepAssocWord, "assoc word: via extrep", true,
  [ IsAssocWord ], 0,
  w->SyllableWordObjByExtRep(FamilyObj(w),ExtRepOfObj(w)));

InstallMethod(SyllableRepAssocWord, "assoc word in syllable rep", true,
  [ IsAssocWord and IsSyllableAssocWordRep], 0, w->w);

InstallOtherMethod( ObjByExtRep,
    "for a 8Bits-family of associative words, and a homogeneous list",
    true,
    [ IsAssocWordFamily and Is8BitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[1], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "for a 16Bits-family of associative words, and a homogeneous list",
    true,
    [ IsAssocWordFamily and Is16BitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[2], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "for a 32Bits-family of associative words, and a homogeneous list",
    true,
    [ IsAssocWordFamily and Is32BitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[3], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "for a InfBits-family of associative words, and a homogeneous list",
    true,
    [ IsAssocWordFamily and IsInfBitsFamily, IsHomogeneousList ], 0,
    function( F, descr )
    return AssocWord( F!.types[4], descr );
    end );


#############################################################################
##
#M  ObjByExtRep( <F>, <expbits>, <maxcand>, <descr> )
##
##  is an object that belongs to the smallest possible type that has
##  at least <expbits> bits for the exponent and that allows <maxcand> as
##  exponent.
##
##  If the family itself knows that its objects have (at most) a specified
##  size then objects of the corresponding type are created faster.
##
InstallOtherMethod( ObjByExtRep,
    "for a fam. of assoc. words, a cyclotomic, an int., and a homog. list",
    true,
    [ IsAssocWordFamily and IsSyllableWordsFamily,
      IsCyclotomic, IsInt, IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )

    local info, expbits;

    # Choose the appropriate type.
    if maxcand < 0 then
      maxcand:= - maxcand;
    fi;
    info:= F!.expBitsInfo;
    expbits:= F!.expBits;
    if   exp <= expbits[2] and maxcand < info[2] then
      if exp <= expbits[1] and maxcand < info[1] then
        return AssocWord( F!.types[1], descr );
      else
        return AssocWord( F!.types[2], descr );
      fi;
    elif exp <= expbits[3] and maxcand < info[3] then
        return AssocWord( F!.types[3], descr );
    else
        return AssocWord( F!.types[4], descr );
    fi;
    end );


#############################################################################
##
#M  Install (internal) methods for objects of the 8 bits type
##
InstallMethod( ExtRepOfObj,
    "for an 8 bits assoc. word",
    true,
    [ Is8BitsAssocWord ], 0,
    8Bits_ExtRepOfObj );

InstallMethod( \=,
    "for two 8 bits assoc. words",
    IsIdenticalObj,
    [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Equal );

InstallMethod( \<,
    "for two 8 bits assoc. words",
    IsIdenticalObj,
    [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Less );

InstallMethod( \*,
    "for two 8 bits assoc. words",
    IsIdenticalObj,
    [ Is8BitsAssocWord, Is8BitsAssocWord ], 0,
    8Bits_Product );

InstallMethod( \/,
    "for two 8 bits assoc. words",
    IsIdenticalObj,
    [ Is8BitsAssocWord, Is8BitsAssocWord and IsMultiplicativeElementWithInverse ], 0,
    8Bits_Quotient );

InstallMethod( OneOp,
    "for an 8 bits assoc. word-with-one",
    true,
    [ Is8BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 8Bits_AssocWord( FamilyObj( x )!.types[1], [] ) );


InstallMethod( \^,
    "for an 8 bits assoc. word, and zero (in small integer rep)",
    true,
    [ Is8BitsAssocWord and IsMultiplicativeElementWithOne,
      IsZeroCyc and IsSmallIntRep ], 0,
    8Bits_Power );

InstallMethod( \^,
    "for an 8 bits assoc. word, and a small negative integer",
    true,
    [ Is8BitsAssocWord and IsMultiplicativeElementWithInverse,
      IsInt and IsNegRat and IsSmallIntRep ], 0,
    8Bits_Power );

InstallMethod( \^,
    "for an 8 bits assoc. word, and a small positive integer",
    true,
    [ Is8BitsAssocWord, IsPosInt and IsSmallIntRep ], 0,
    8Bits_Power );


InstallMethod( ExponentSyllable,
    "for an 8 bits assoc. word, and a pos. integer",
    true,
    [ Is8BitsAssocWord, IsPosInt ], 0,
    8Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "for an 8 bits assoc. word, and an integer",
    true,
    [ Is8BitsAssocWord, IsInt ], 0,
    8Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    "for an 8 bits assoc. word",
    true,
    [ Is8BitsAssocWord ], 0,
    NBits_NumberSyllables );

InstallMethod( ExponentSums,
    "for an 8 bits assoc. word",
    true,
    [ Is8BitsAssocWord ], 0,
    8Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "for an 8 bits assoc. word, and two integers",
    true,
    [ Is8BitsAssocWord, IsInt, IsInt ], 0,
    8Bits_ExponentSums3 );

InstallOtherMethod( Length,
    "for an 8 bits assoc. word",
    true,
    [ Is8BitsAssocWord ], 0,
    8Bits_LengthWord );


#############################################################################
##
#M  Install (internal) methods for objects of the 16 bits type
##
InstallMethod( ExtRepOfObj,
    "for a 16 bits assoc. word",
    true,
    [ Is16BitsAssocWord ], 0,
    16Bits_ExtRepOfObj );

InstallMethod( \=,
    "for two 16 bits assoc. words",
    IsIdenticalObj,
    [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Equal );

InstallMethod( \<,
    "for two 16 bits assoc. words",
    IsIdenticalObj,
    [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Less );

InstallMethod( \*,
    "for two 16 bits assoc. words",
    IsIdenticalObj,
    [ Is16BitsAssocWord, Is16BitsAssocWord ], 0,
    16Bits_Product );

InstallMethod( \/,
    "for two 16 bits assoc. words",
    IsIdenticalObj,
    [ Is16BitsAssocWord, Is16BitsAssocWord and IsMultiplicativeElementWithInverse ], 0,
    16Bits_Quotient );

InstallMethod( OneOp,
    "for a 16 bits assoc. word-with-one",
    true,
    [ Is16BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 16Bits_AssocWord( FamilyObj( x )!.types[2], [] ) );


InstallMethod( \^,
    "for a 16 bits assoc. word, and zero (in small integer rep)",
    true,
    [ Is16BitsAssocWord and IsMultiplicativeElementWithOne,
      IsZeroCyc and IsSmallIntRep ], 0,
    16Bits_Power );

InstallMethod( \^,
    "for a 16 bits assoc. word, and a small negative integer",
    true,
    [ Is16BitsAssocWord and IsMultiplicativeElementWithInverse,
      IsInt and IsNegRat and IsSmallIntRep ], 0,
    16Bits_Power );

InstallMethod( \^,
    "for a 16 bits assoc. word, and a small positive integer",
    true,
    [ Is16BitsAssocWord, IsPosInt and IsSmallIntRep ], 0,
    16Bits_Power );


InstallMethod( ExponentSyllable,
    "for a 16 bits assoc. word, and pos. integer",
    true,
    [ Is16BitsAssocWord, IsPosInt ], 0,
    16Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "for a 16 bits assoc. word, and integer",
    true,
    [ Is16BitsAssocWord, IsInt ], 0,
    16Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    "for a 16 bits assoc. word",
    true,
    [ Is16BitsAssocWord ], 0,
    NBits_NumberSyllables );

InstallMethod( ExponentSums,
    "for a 16 bits assoc. word",
    true,
    [ Is16BitsAssocWord ], 0,
    16Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "for a 16 bits assoc. word, and two integers",
    true,
    [ Is16BitsAssocWord, IsInt, IsInt ], 0,
    16Bits_ExponentSums3 );

InstallOtherMethod( Length,
    "for a 16 bits assoc. word",
    true,
    [ Is16BitsAssocWord ], 0,
    16Bits_LengthWord );


#############################################################################
##
#M  Install (internal) methods for objects of the 32 bits type
##
InstallMethod( ExtRepOfObj,
    "for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord ], 0,
    32Bits_ExtRepOfObj );

InstallMethod( \=,
    "for two 32 bits assoc. words",
    IsIdenticalObj,
    [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Equal );

InstallMethod( \<,
    "for two 32 bits assoc. words",
    IsIdenticalObj,
    [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Less );

InstallMethod( \*,
    "for two 32 bits assoc. words",
    IsIdenticalObj,
    [ Is32BitsAssocWord, Is32BitsAssocWord ], 0,
    32Bits_Product );

InstallMethod( \/,
    "for two 32 bits assoc. words",
    IsIdenticalObj,
    [ Is32BitsAssocWord, Is32BitsAssocWord and IsMultiplicativeElementWithInverse ], 0,
    32Bits_Quotient );

InstallMethod( OneOp,
    "for a 32 bits assoc. word-with-one",
    true,
    [ Is32BitsAssocWord and IsAssocWordWithOne ], 0,
    x -> 32Bits_AssocWord( FamilyObj( x )!.types[3], [] ) );


InstallMethod( \^,
    "for a 32 bits assoc. word, and zero (in small integer rep)",
    true,
    [ Is32BitsAssocWord and IsMultiplicativeElementWithOne,
      IsZeroCyc and IsSmallIntRep ], 0,
    32Bits_Power );

InstallMethod( \^,
    "for a 32 bits assoc. word, and a small negative integer",
    true,
    [ Is32BitsAssocWord and IsMultiplicativeElementWithInverse,
      IsInt and IsNegRat and IsSmallIntRep ], 0,
    32Bits_Power );

InstallMethod( \^,
    "for a 32 bits assoc. word, and a small positive integer",
    true,
    [ Is32BitsAssocWord, IsPosInt and IsSmallIntRep ], 0,
    32Bits_Power );


InstallMethod( ExponentSyllable,
    "for a 32 bits assoc. word, and pos. integer",
    true,
    [ Is32BitsAssocWord, IsPosInt ], 0,
    32Bits_ExponentSyllable );

InstallMethod( GeneratorSyllable,
    "for a 32 bits assoc. word, and pos. integer",
    true,
    [ Is32BitsAssocWord, IsPosInt ], 0,
    32Bits_GeneratorSyllable );

InstallMethod( NumberSyllables,
    "for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord ], 0,
    NBits_NumberSyllables );

InstallMethod( ExponentSums,
    "for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord ], 0,
    32Bits_ExponentSums1 );

InstallOtherMethod( ExponentSums,
    "for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord, IsInt, IsInt ], 0,
    32Bits_ExponentSums3 );

InstallOtherMethod( Length,
    "for a 32 bits assoc. word",
    true,
    [ Is32BitsAssocWord ], 0,
    32Bits_LengthWord );


#############################################################################
##
#M  Install methods for objects of the infinity type
##
BindGlobal( "InfBits_ExtRepOfObj", elm->elm![1] );
InstallMethod( ExtRepOfObj,
    "for a inf. bits assoc. word",
    true,
    [ IsInfBitsAssocWord ], 0,
    InfBits_ExtRepOfObj );

BindGlobal( "InfBits_Equal", {x,y} ->  x![1] = y![1] );
InstallMethod( \=,
    "for two inf. bits assoc. words",
    IsIdenticalObj,
    [ IsInfBitsAssocWord, IsInfBitsAssocWord ], 0,
    InfBits_Equal );

BindGlobal( "InfBits_Less", function( u, v )
    local   lu, lv,      # length of u/v as a list
            len,         # difference in length of u/v as words
            i,           # loop variable
            lexico;      # flag for the lexicoghraphic ordering of u and v

    u := u![1]; lu := Length(u);
    v := v![1]; lv := Length(v);

    ##  Discard a common prefix in u and v and decide if u is
    ##  lexicographically smaller than v.
    i := 1; while i <= lu and i <= lv and u[i] = v[i] do
        i := i+1;
    od;

    if i > lu then  ## u is a prefix of v.
        return lu < lv;
    fi;

    if i > lv then  ## v is a prefix of u, but not equal to u.
        return false;
    fi;

    ##  Decide if u is lexicographically smaller than v.
    if i mod 2 = 1 then
        ##  the generators in u and v differ
        lexico := u[i] < v[i];
        i := i+1;
    else
        ##  the exponents in u and v differ
        if u[i] = -v[i] then
            lexico := u[i] < 0;
        else
            ##  Here we have to look at the next generator in the word whose
            ##  syllable has the smaller absolute exponent in order to decide
            ##  which word is smaller.
            if AbsInt(u[i]) > AbsInt(v[i]) then
                if i+1 <= lv then
                    lexico := u[i-1] < v[i+1];
                else
                    ## Ignoring the common prefix, v is empty.
                    return false;
                fi;
            else
                ##  |u[i]| < |v[i]|
                if i+1 <= lu then
                    lexico := u[i+1] < v[i-1];
                else
                    ## Ignoring the common prefix, u is empty.
                    return true;
                fi;
            fi;
        fi;
    fi;

    ##  Now compute the difference of the lengths
    len := 0; while i <= lu and i <= lv do
        len := len + AbsInt(u[i]);
        len := len - AbsInt(v[i]);
        i := i+2;
    od;
    ##  Only one of the following while loops will be executed.
    while i <= lu do
        len := len + AbsInt(u[i]); i := i+2;
    od;
    while i <= lv do
        len := len - AbsInt(v[i]); i := i+2;
    od;

    if len = 0 then
        return lexico;
    fi;

    return len < 0;
end );

InstallMethod( \<,
    "for two inf. bits assoc. words",
    IsIdenticalObj,
    [ IsInfBitsAssocWord, IsInfBitsAssocWord ], 100,
    InfBits_Less );

BindGlobal( "InfBits_One", x -> InfBits_AssocWord( FamilyObj(x)!.types[4],[] ) );
InstallMethod( OneOp,
    "for an inf. bits assoc. word-with-one",
    true,
    [ IsInfBitsAssocWord and IsAssocWordWithOne ], 0,
    InfBits_One );

BindGlobal( "InfBits_ExponentSyllable", function( x, i )
    return x![1][ 2*i ];
end );
InstallMethod( ExponentSyllable,
    "for an inf. bits assoc. word, and a pos. integer",
    true,
    [ IsInfBitsAssocWord, IsPosInt ], 0,
    InfBits_ExponentSyllable );

BindGlobal( "InfBits_GeneratorSyllable", function( x, i )
    return x![1][2*i-1];
end );
InstallMethod( GeneratorSyllable,
    "for an inf. bits assoc. word, and an integer",
    true,
    [ IsInfBitsAssocWord, IsInt ], 0,
    InfBits_GeneratorSyllable );

BindGlobal( "InfBits_NumberSyllables", x -> Length( x![1] ) / 2 );
InstallMethod( NumberSyllables,
    "for an inf. bits assoc. word",
    true,
    [ IsInfBitsAssocWord ], 0,
    InfBits_NumberSyllables );

BindGlobal( "InfBits_ExponentSums1", function( obj )
    local expvec, i;
    #expvec:= [];
    #for i in [ 1 .. TypeObj( obj )![ AWP_NR_GENS ] ] do
    #  expvec[i]:= 0;
    #od;
    expvec:=ListWithIdenticalEntries(TypeObj( obj )![ AWP_NR_GENS ],0);
    obj:= obj![1];
    for i in [ 1, 3 .. Length( obj ) - 1 ] do
      expvec[ obj[i] ]:= expvec[ obj[i] ] + obj[ i+1 ];
    od;
    return expvec;
end );
InstallMethod( ExponentSums,
    "for an inf. bits assoc. word",
    true,
    [ IsInfBitsAssocWord ], 0,
    InfBits_ExponentSums1 );


BindGlobal( "InfBits_ExponentSums3", function( obj, from, to )
    local expvec, i;

    if from < 1 then Error("<from> must be a positive integer"); fi;
    if to < 1 then Error("<to> must be a positive integer"); fi;
    if from > to then return []; fi;

    expvec:=ListWithIdenticalEntries(TypeObj( obj )![ AWP_NR_GENS ],0);

    # the syllable representation is a sparse representation
    obj:= obj![1];
    for i in [ 1, 3.. Length(obj)-1 ] do
        if obj[i] in [from..to] then
            expvec[ obj[i] ]:= expvec[ obj[i] ] + obj[ i+1 ];
        fi;
    od;
    return expvec{[from..to]};
end );
InstallOtherMethod( ExponentSums,
    "for an inf. bits assoc. word, and two integers",
    true,
    [ IsInfBitsAssocWord, IsInt, IsInt ], 1,
    InfBits_ExponentSums3 );

#############################################################################
##
#F  ObjByVector( <Type>, <vector> )
#T  ObjByVector( <Fam>, <vector> )
##
InstallGlobalFunction( ObjByVector, function( Type, vec )
    return Type![ AWP_FUN_OBJ_BY_VECTOR ]( Type![ AWP_PURE_TYPE ], vec );
end );


BindGlobal( "InfBits_ObjByVector", function( type, vec )
    local expr, i;
    expr:= [];
    for i in [ 1 .. Length( vec ) ] do
      if vec[i] <> 0 then
        Add( expr, i );
        Add( expr, vec[i] );
      fi;
    od;
    return ObjByExtRep( FamilyType(type), expr );
end );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <exp>, <maxcand>, <descr> )
##
##  If the family does already know that all only words in a prescribed
##  type will be constructed then we store this in the family,
##  and `ObjByExtRep' will construct only such objects.
##
InstallOtherMethod( ObjByExtRep,
    "for an 8 bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and Is8BitsFamily, IsInt, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return 8Bits_AssocWord( F!.types[1], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "for a 16 bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and Is16BitsFamily, IsInt, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return 16Bits_AssocWord( F!.types[2], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "for a 32 bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and Is32BitsFamily, IsInt, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return 32Bits_AssocWord( F!.types[3], descr );
    end );

InstallOtherMethod( ObjByExtRep,
    "for an inf. bits assoc. words family, two integers, and a list",
    true,
    [ IsAssocWordFamily and IsInfBitsFamily, IsCyclotomic, IsInt,
      IsHomogeneousList ], 0,
    function( F, exp, maxcand, descr )
    return InfBits_AssocWord( F!.types[4], descr );
    end );


#############################################################################
##
#F  StoreInfoFreeMagma( <F>, <names>, <req> )
##
##  does the administrative work in the construction of free semigroups,
##  free monoids, and free groups.
##
##  <F> is the family of objects, <names> is a list of generators names,
##  and <req> is the required category for the elements, that is,
##  `IsAssocWord', `IsAssocWordWithOne', or `IsAssocWordWithInverse'.
##
InstallGlobalFunction( StoreInfoFreeMagma, function( F, names, req )

    local rank,
          rbits,
          K,
          expB,
          typesList;

  # Store the names, initialize the types list.
  typesList := [];
  F!.names := Immutable( names );

  # for letter word families we do not need these types
  if not IsFinite( names ) then

    SetFilterObj( F, IsInfBitsFamily );

  else

    # Install the data (number of bits available for exponents).
    # Note that in the case of the 32 bits representation,
    # at most 28 bits are allowed for the exponents in order to avoid
    # overflow checks.
    rank  := Length( names );
    rbits := 1;
    while 2^rbits < rank do
      rbits:= rbits + 1;
    od;
    expB := [  8 - rbits,
               16 - rbits,
               Minimum( 32 - rbits, 28 ),
               infinity ];

    # Note that one bit of the exponents is needed for the sign,
    # and we disallow the use of a representation if at most two
    # additional bits would be available.
    if expB[1] <= 3 then expB[1]:= 0; fi;
    if expB[2] <= 3 then expB[2]:= 0; fi;
    if expB[3] <= 3 then expB[3]:= 0; fi;

    MakeImmutable(expB);
    F!.expBits := expB;

    F!.expBitsInfo := MakeImmutable([ 2^( F!.expBits[1] - 1 ),
                         2^( F!.expBits[2] - 1 ),
                         2^( F!.expBits[3] - 1 ),
                         infinity          ]);

    # Store the internal types.
    K:= NewType( F, Is8BitsAssocWord and req );
    StrictBindOnce(K, AWP_PURE_TYPE        , K);
    StrictBindOnce(K, AWP_NR_BITS_EXP      , F!.expBits[1]);
    StrictBindOnce(K, AWP_NR_GENS          , rank);
    StrictBindOnce(K, AWP_NR_BITS_PAIR     , 8);
    StrictBindOnce(K, AWP_FUN_OBJ_BY_VECTOR, 8Bits_ObjByVector);
    StrictBindOnce(K, AWP_FUN_ASSOC_WORD   , 8Bits_AssocWord);
    typesList[1]:= K;

    K:= NewType( F, Is16BitsAssocWord and req );
    StrictBindOnce(K, AWP_PURE_TYPE        , K);
    StrictBindOnce(K, AWP_NR_BITS_EXP      , F!.expBits[2]);
    StrictBindOnce(K, AWP_NR_GENS          , rank);
    StrictBindOnce(K, AWP_NR_BITS_PAIR     , 16);
    StrictBindOnce(K, AWP_FUN_OBJ_BY_VECTOR, 16Bits_ObjByVector);
    StrictBindOnce(K, AWP_FUN_ASSOC_WORD   , 16Bits_AssocWord);
    typesList[2]:= K;

    K:= NewType( F, Is32BitsAssocWord and req );
    StrictBindOnce(K, AWP_PURE_TYPE        , K);
    StrictBindOnce(K, AWP_NR_BITS_EXP      , F!.expBits[3]);
    StrictBindOnce(K, AWP_NR_GENS          , rank);
    StrictBindOnce(K, AWP_NR_BITS_PAIR     , 32);
    StrictBindOnce(K, AWP_FUN_OBJ_BY_VECTOR, 32Bits_ObjByVector);
    StrictBindOnce(K, AWP_FUN_ASSOC_WORD   , 32Bits_AssocWord);
    typesList[3]:= K;

  fi;

  K:= NewType( F, IsInfBitsAssocWord and req );
  StrictBindOnce(K, AWP_PURE_TYPE         , K);
  StrictBindOnce(K, AWP_NR_BITS_EXP       , infinity);
  StrictBindOnce(K, AWP_NR_GENS           , Length( names ));
  StrictBindOnce(K, AWP_NR_BITS_PAIR      , infinity);
  StrictBindOnce(K, AWP_FUN_OBJ_BY_VECTOR , InfBits_ObjByVector);
  StrictBindOnce(K, AWP_FUN_ASSOC_WORD    , InfBits_AssocWord);
  typesList[4]:= K;

  F!.types := MakeImmutable(typesList);

  if IsBLetterWordsFamily(F) then
    K:= NewType( F, IsBLetterAssocWordRep and req );
  else
    K:= NewType( F, IsWLetterAssocWordRep and req );
  fi;
  F!.letterWordType:=K;

end );


#############################################################################
##
#R  IsInfiniteListOfNamesRep( <list> )
##
##  is a representation of a list <list> containing at position $i$
##  either the string `<string>$i$' or the string `<init>[$i$]',
##  where the latter holds if and only if $i$ does not exceed the
##  length of the list <init>.
##
##  <string> is stored at position 1 in the positional object <list>,
##  <init> is stored at position 2.
##
DeclareRepresentation( "IsInfiniteListOfNamesRep",
    IsPositionalObjectRep,
    [ 1, 2 ] );

InstallMethod( PrintObj,
    "for an infinite list of names",
    true,
    [ IsList and IsInfiniteListOfNamesRep ], 0,
    function( list )
    Print( "InfiniteListOfNames( \"", list![1], "\", ", list![2], " )" );
    end );

InstallMethod( ViewObj,
    "for an infinite list of names",
    true,
    [ IsList and IsInfiniteListOfNamesRep ], 0,
    function( list )
    Print( "[ ", list[1], ", ", list[2], ", ... ]" );
    end );

InstallMethod( \[\],
    "for an infinite list of names",
    true,
    [ IsList and IsInfiniteListOfNamesRep, IsPosInt ], 0,
    function( list, pos )
    local entry;
    if pos <= Length( list![2] ) then
      entry:= list![2][ pos ];
    else
      entry:= Concatenation( list![1], String( pos ) );
      ConvertToStringRep( entry );
    fi;
    return entry;
    end );

InstallMethod( Length,
    "for an infinite list of names",
    true,
    [ IsList and IsInfiniteListOfNamesRep ], 0,
    list -> infinity );

InstallMethod( Position,
    "for an infinite list of names, an object, and zero",
    true,
    [ IsList and IsInfiniteListOfNamesRep, IsObject, IsZeroCyc ], 0,
    function( list, obj, zero )
    local digits, pos, i;

    # Check whether `obj' is in the initial segment, and if not,
    # whether `obj' matches the names in the rest of the list..
    pos:= Position( list![2], obj );
    if pos <> fail then
      return pos;
    elif  ( not IsString( obj ) )
       or Length( obj ) <= Length( list![1] )
       or obj{ [ 1 .. Length( list![1] ) ] } <> list![1] then
      return fail;
    fi;

    # Convert the suffix to a number if possible.
    digits:= "0123456789";
    pos:= 0;
    for i in [ Length( list![1] ) + 1 .. Length( obj ) ] do
      if obj[i] in digits then
        pos:= 10*pos + Position( digits, obj[i], 0 ) - 1;
      else
        return fail;
      fi;
    od;

    # If the number belongs to a position in the initial segment,
    # `obj' is not in the list.
    if pos <= Length( list![2] ) then
      pos:= fail;
    fi;
    return pos;
    end );


#############################################################################
##
#F  InfiniteListOfNames( <string> )
#F  InfiniteListOfNames( <string>, <init> )
##
InstallGlobalFunction( InfiniteListOfNames, function( arg )
    local string, init, list;

    if Length( arg ) = 1 and IsString( arg[1] ) then
      string := Immutable( arg[1] );
      init   := Immutable( [] );
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsList( arg[2] ) then
      string := Immutable( arg[1] );
      init   := Immutable( arg[2] );
    else
      Error( "usage: InfiniteListOfNames( <string>[, <init>] )" );
    fi;

    list:= Objectify( NewType( CollectionsFamily( FamilyObj( string ) ),
                                   IsList
                               and IsDenseList
                               and IsConstantTimeAccessList
                               and IsInfiniteListOfNamesRep ),
                      [ string, init ] );
    SetIsFinite( list, false );
    SetIsEmpty( list, false );
    if IsHPCGAP then
      MakeReadOnlyObj( list );
    fi;
    SetLength( list, infinity );
#T meaningless since not attribute storing!
    return list;
end );


#############################################################################
##
#R  IsInfiniteListOfGeneratorsRep( <Fam> )
##
##  is a representation used for lists containing at position $i$ the $i$-th
##  generator of the ``free something family'' <Fam>.
##  Note that we have to distinguish the cases of associative words and
##  nonassociative words, since they have different external representations.
##
##  The family <Fam> is stored at position 1 in the list object,
##  at position 2 a (possibly empty) list of initial generators is stored.
##
DeclareRepresentation( "IsInfiniteListOfGeneratorsRep",
    IsPositionalObjectRep,
    [ 1, 2 ] );

InstallMethod( ViewObj,
    "for an infinite list of generators",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep ], 0,
    function( list )
    Print( "[ ", list[1], ", ", list[2], ", ... ]" );
    end );

InstallMethod( PrintObj,
    "for an infinite list of generators",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep ], 0,
    function( list )
    Print( "[ ", list[1], ", ", list[2], ", ... ]" );
    end );

InstallMethod( Length,
    "for an infinite list of generators",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep ], 0,
    list -> infinity );

InstallMethod( \[\],
    "for an infinite list of generators",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep, IsPosInt ], 0,
    function( list, i )
    if i <= Length( list![2] ) then
      return list![2][i];
    elif IsAssocWordFamily( list![1] ) then
      if IsLetterWordsFamily(list![1]) then
        return AssocWordByLetterRep( list![1], [ i ] );
      else
        return ObjByExtRep( list![1], [ i, 1 ] );
      fi;
    else
      return ObjByExtRep( list![1], i );
    fi;
    end );

InstallMethod( Position,
    "for an infinite list of generators, an object, and zero",
    true,
    [ IsList and IsInfiniteListOfGeneratorsRep, IsObject, IsZeroCyc ], 0,
    function( list, obj, zero )
    local ext;

    if FamilyObj( obj ) <> list![1] then
      return fail;
    fi;


    if IsAssocWord( obj ) then
      ext:=LetterRepAssocWord(obj);
      if Length(ext)<> 1 or ext[1]<0 then
        return fail;
      else
        return ext[1];
      fi;
    else
      ext:= ExtRepOfObj( obj );
      if not IsInt( ext ) then
        return fail;
      else
        return ext;
      fi;
    fi;
    end );


#############################################################################
##
#M  Random( <list> )  . . . . . . . . . .  for an infinite list of generators
##
InstallMethodWithRandomSource( Random,
    "for a random source and an infinite list of generators",
    [ IsRandomSource, IsList and IsInfiniteListOfGeneratorsRep ], 0,
    function( rs, list )
    local pos;
    pos:= Random( rs, Integers );
    if 0 <= pos then
      return list[ 2 * pos + 1 ];
    else
      return list[ -2 * pos ];
    fi;
    end );
#T should be moved to list.gi, or?


#############################################################################
##
#F  InfiniteListOfGenerators( <F> )
#F  InfiniteListOfGenerators( <F>, <init> )
##
InstallGlobalFunction( InfiniteListOfGenerators, function( arg )
    local F, init, list;
    if Length( arg ) = 1 and IsFamily( arg[1] ) then
      F    := arg[1];
      init := Immutable( [] );
    elif Length( arg ) = 2 and IsFamily( arg[1] ) and IsList( arg[2] ) then
      F    := arg[1];
      init := Immutable( arg[2] );
    fi;

    list:= Objectify( NewType( CollectionsFamily( F ),
                                   IsList
                               and IsDenseList
                               and IsConstantTimeAccessList
                               and IsInfiniteListOfGeneratorsRep ),
                      [ F, init ] );
    SetIsFinite( list, false );
    SetIsEmpty( list, false );
    if IsHPCGAP then
      MakeReadOnlyObj( list );
    fi;
    SetLength( list, infinity );
#T meaningless since not attribute storing!
    return list;
end );

# letter representation

InstallOtherMethod(LetterRepAssocWord,"syllable rep, generators",
true, #TODO: This should be IsElmsColls once the tietze code is fixed.
  [IsSyllableAssocWordRep,IsList],0,
function ( word, generators )
local ind,n,i,e,l,g;

  ind:=[];
  n:=1;
  for i in generators do
    ind[GeneratorSyllable(i,1)]:=n;
    n:=n+1;
  od;

  e:=ExtRepOfObj(word);
  l:=[];
  for i in [1,3..Length(e)-1] do
    g:=ind[e[i]];
    n:=e[i+1];
    if n<0 then
      g:=-g;
      n:=-n;
    fi;
    Append(l,ListWithIdenticalEntries(n,g));
  od;
  return l;

end );

InstallMethod(LetterRepAssocWord,"syllable rep",true,
  [IsSyllableAssocWordRep],0,
function(word)
local n,i,e,l,g;

  e:=ExtRepOfObj(word);
  l:=[];
  for i in [1,3..Length(e)-1] do
    g:=e[i];
    n:=e[i+1];
    if n<0 then
      g:=-g;
      n:=-n;
    fi;
    Append(l,ListWithIdenticalEntries(n,g));
  od;
  return l;

end );

InstallMethod(AssocWordByLetterRep,"family, list: syllables",true,
  [IsSyllableWordsFamily,IsHomogeneousList],0,
function ( wfam,word )
local e,lg,i,num,mex;

   # first generate an external representation
   e:=[];
   mex:=1;
   lg:=0;
   i:=0;
   for num in word do
     if num<0 then
       if -num=lg then
         # increase exponent
         e[i]:=e[i]-1;
         mex:=Maximum(mex,-e[i]);
       else
         # add new generator/exponent pair
         Append(e,[-num,-1]);
         lg:=-num;
         i:=i+2;
       fi;
     else
       if num=lg then
         # increase exponent
         e[i]:=e[i]+1;
         mex:=Maximum(mex,e[i]);
       else
         # add new generator/exponent pair
         Append(e,[num,1]);
         lg:=num;
         i:=i+2;
       fi;
     fi;
   od;
   # then build a word from it
   e:=ObjByExtRep(wfam,mex,mex,e);
   return e;
end );


InstallOtherMethod(AssocWordByLetterRep,"family, list, gens: syllables",true,
  [IsSyllableWordsFamily,IsHomogeneousList,IsHomogeneousList],0,
function (fam, word, fgens )
local ind,e,lg,i,num,mex;

   # index the generators
   ind:=List(fgens,i->GeneratorSyllable(i,1));

   # first generate an external representation
   e:=[];
   mex:=1;
   lg:=0;
   i:=0;
   for num in word do
     if num<0 then
       if -num=lg then
         # increase exponent
         e[i]:=e[i]-1;
         mex:=Maximum(mex,-e[i]);
       else
         # add new generator/exponent pair
         Append(e,[ind[-num],-1]);
         lg:=-num;
         i:=i+2;
       fi;
     else
       if num=lg then
         # increase exponent
         e[i]:=e[i]+1;
         mex:=Maximum(mex,e[i]);
       else
         # add new generator/exponent pair
         Append(e,[ind[num],1]);
         lg:=num;
         i:=i+2;
       fi;
     fi;
   od;
   # then build a word from it
   e:=ObjByExtRep(fam,mex,mex,e);
   return e;
end );

#############################################################################
##
#M  Length( <w> )
##
InstallOtherMethod( Length, "for an assoc. word in syllable rep", true,
    [ IsAssocWord  and IsSyllableAssocWordRep], 0,
function( w )
local len, i;
  w:= ExtRepOfObj( w );
  len:= 0;
  for i in [ 2, 4 .. Length( w ) ] do
    len:= len + AbsInt( w[i] );
  od;
  return len;
end );


#############################################################################
##
#M  ExponentSyllable( <w>, <n> )
##
InstallMethod( ExponentSyllable,
    "for an assoc. word in syllable rep, and a positive integer", true,
    [ IsAssocWord and IsSyllableAssocWordRep, IsPosInt ], 0,
function( w, n )
  return ExtRepOfObj( w )[ 2*n ];
end );


#############################################################################
##
#M  GeneratorSyllable( <w>, <n> )
##
InstallMethod( GeneratorSyllable,
    "for an assoc. word in syllable rep, and a positive integer", true,
    [ IsAssocWord and IsSyllableAssocWordRep, IsPosInt ], 0,
function( w, n )
  return ExtRepOfObj( w )[ 2*n-1 ];
end );


#############################################################################
##
#M  NumberSyllables( <w> )
##
InstallMethod( NumberSyllables, "for an assoc. word in syllable rep", true,
    [ IsAssocWord  and IsSyllableAssocWordRep], 0,
    w -> Length( ExtRepOfObj( w ) ) / 2 );


#############################################################################
##
#M  ExponentSumWord( <w>, <gen> )
##
InstallMethod( ExponentSumWord, "syllable rep as.word, gen", IsIdenticalObj,
    [ IsAssocWord and IsSyllableAssocWordRep, IsAssocWord ], 0,
function( w, gen )
local n, g, i;
  w:= ExtRepOfObj( w );
  gen:= ExtRepOfObj( gen );
  if Length( gen ) <> 2 or ( gen[2] <> 1 and gen[2] <> -1 ) then
    Error( "<gen> must be a generator" );
  fi;
  n:= 0;
  g:= gen[1];
  for i in [ 1, 3 .. Length( w ) - 1 ] do
    if w[i] = g then
      n:= n + w[ i+1 ];
    fi;
  od;
  if gen[2] = -1 then
    n:= -n;
  fi;
  return n;
end );


#############################################################################
##
#M  ExponentSums( <f>,<w> )
##
InstallOtherMethod( ExponentSums,
    "for a group and an assoc. word in syllable rep", true,
    [ IsGroup, IsAssocWord ], 0,
function( f, w )
local l,gens,g,i,p;

  Info(InfoWarning,2,"obsolete undocumented method");
  gens:=List(FreeGeneratorsOfFpGroup(f),ExtRepOfObj);
  g:=gens{[1..Length(gens)]}[1];
  l:=List(gens,x->0);
  w:= ExtRepOfObj( w );
  for i in [ 1, 3 .. Length( w ) - 1 ] do
    p:=Position(g,w[i]);
    l[p]:=l[p]+w[i+1];
  od;

  for i in [1..Length(l)] do
    if gens[i][2]=-1 then l[i]:=-l[i];fi;
  od;

  return l;

end );

InstallGlobalFunction(FreelyReducedLetterRepWord,function(w)
local i;
  i:=1;
  while i<Length(w) do
    if w[i]=-w[i+1] then
      w:=Concatenation(w{[1..i-1]},w{[i+2..Length(w)]});
      # there could be cancellation of previous
      if i>1 then
        i:=i-1;
      fi;
    else
      i:=i+1;
    fi;
  od;
  return w;
end);

InstallGlobalFunction(WordProductLetterRep,function(arg)
local l,r,i,j,b,p,lc;
  l:=arg[1];
  lc:=false;
  for p in [2..Length(arg)] do
    r:=arg[p];
    b:=Length(r);
    if Length(l)=0 then l:=r;
    elif b>0 then
      # find cancellation
      i:=Length(l);
      j:=1;
      while i>0 and j<=b and l[i]=-r[j] do
        i:=i-1;j:=j+1;
      od;
      if j>b then
        l:=l{[1..i]};
        lc:=true;
      elif i=0 then
        l:=r{[j..b]};
        lc:=true;
      else
        if j=1 and lc then
          # No cancellation, and l was changed already: Append
          Append(l,r);
        else
          l:=Concatenation(l{[1..i]},r{[j..b]});
          lc:=true;
        fi;
      fi;
    fi;
  od;
  return l;
end);
