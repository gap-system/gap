#############################################################################
##
#W  wordass.gi                  GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
#H  @(#)$Id$
##
##  This file contains generic methods for associative words.
##
Revision.wordass_gi :=
    "@(#)$Id$";


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
        if    TypeObj( x )![ AWP_NR_BITS_EXP ] <= TypeObj( y )![ AWP_NR_BITS_EXP ] then
          return AssocWord( TypeObj( y )![ AWP_PURE_TYPE ], xx );
        else
          return AssocWord( TypeObj( x )![ AWP_PURE_TYPE ], xx );
        fi;

      fi;

    fi;
end );

InstallMethod( \*,
    "for two assoc. words",
    IsIdenticalObj,
    [ IsAssocWord, IsAssocWord ], 0,
    AssocWord_Product );


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
    "for an assoc. word, and a positive integer",
    true,
    [ IsAssocWord, IsPosInt ], 0,
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
    "for an assoc. word with inverse, and an integer",
    true,
    [ IsAssocWordWithInverse, IsInt ], 0,
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

InstallMethod( Inverse,
    "for an assoc. word with inverse",
    true,
    [ IsAssocWordWithInverse ], 0,
    AssocWordWithInverse_Inverse );


#############################################################################
##

#M  Length( <w> )
##
InstallOtherMethod( Length,
    "for an assoc. word",
    true,
    [ IsAssocWord ], 0,
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
    "for an assoc. word, and a positive integer",
    true,
    [ IsAssocWord, IsPosInt ],
    0,
    function( w, n )
    return ExtRepOfObj( w )[ 2*n ];
    end );


#############################################################################
##
#M  GeneratorSyllable( <w>, <n> )
##
InstallMethod( GeneratorSyllable,
    "for an assoc. word, and a positive integer",
    true,
    [ IsAssocWord, IsPosInt ],
    0,
    function( w, n )
    return ExtRepOfObj( w )[ 2*n-1 ];
    end );


#############################################################################
##
#M  NumberSyllables( <w> )
##
InstallMethod( NumberSyllables,
    "for an assoc. word",
    true,
    [ IsAssocWord ], 0,
    w -> Length( ExtRepOfObj( w ) ) / 2 );


#############################################################################
##
#M  ExponentSumWord( <w>, <gen> )
##
InstallMethod( ExponentSumWord,
    "for associative word and generator",
    IsIdenticalObj,
    [ IsAssocWord, IsAssocWord ],
    0,
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
    "for a group and an assoc. word",
    true,
    [ IsGroup, IsAssocWord ], 0,
    function( f, w )
    local l,gens,g,i,p;
    
    gens:=List(FreeGeneratorsOfFpGroup(f),x->ExtRepOfObj(x));
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


#############################################################################
##
#M  Subword( <w>, <from>, <to> )
##
InstallOtherMethod( Subword,
    "for associative word and two positions",
    true,
    [ IsAssocWord, IsPosInt, IsInt ],
    0,
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
    [ IsAssocWord, IsPosInt, IsPosInt ], 0,
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
InstallMethod( PositionWord,
  "for two associative words and a positive integer, using syllables",
  IsFamFamX, [ IsAssocWord, IsAssocWord, IsPosInt ], 0,
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

	# if from>to or from>|w| or to>|w| then this does not make sense
	if from>to or from>Length(w) or to>Length(w) then
		Error("illegal values for <from> and <to>");	
	fi;
	
	# otherwise there are four possibilities 

	# first if from=1 and to=Length(w) then
	if from=1 and to=Length(w) then
		return by;
	fi;

	# second if from=1 (and to<Length(w))  then
	if from=1 then 	
		return by*Subword(w,to+1,Length(w));
	fi;

	# third if to=1 (and from>1) then
	if to=Length(w) then
		return Subword(w,1,from-1)*by;
	fi;

	# finally 
  return Subword(w,1,from-1)*by*Subword(w,to+1,Length(w));

end );

#############################################################################
##
#M SubstitutedWord(<u>,<v>,<k>,<z>)
##
## for a word u, a subword v of u, an integer i and a word z
##
## it substitutes the first occurence of v in u, starting from
## position k, by z
##
InstallOtherMethod(SubstitutedWord,
 "for three associate words",true,
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
#M  RenumberWord( <word>, <renumber> )  . . . . . . . . .  for an assoc. word
##
InstallMethod( RenumberedWord,
    "associative words",
    true,
    [IsAssocWord, IsList], 0,
function( w, renumber )
    local   t,  i;

    t := TypeObj( w );
    w := ExtRepOfObj( w );

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
BindGlobal( "MappedWordForAssocWord", function( x, gens1, gens2 )

local i, mapped, exp,ex2,p;

    x:= ExtRepOfObj( x );

    # First handle the case of an identity element.
    # This happens for monoid element objects.
    if IsEmpty( x ) then
      return gens2[1] ^ 0;
    fi;

    if     FamilyObj( gens1 ) = FamilyObj( gens2 )
       and IsAssocWordWithInverseCollection( gens2 ) then
      ex2:= List( gens2, ExtRepOfObj );
    else
      # not words, forget special treatment
      ex2:=fail;
    fi;

    gens1:= List( gens1, ExtRepOfObj );
    if not ForAll( gens1, i -> Length( i ) = 2 and i[2] = 1 ) then
      Error( "<gens1> must be proper generators" );
    fi;
    gens1:= List( gens1, x -> x[1] );

    if     ex2 <> fail
       and ForAll( ex2, i -> Length( i ) = 2 and AbsInt( i[2] ) = 1 )
       and Set( List( ex2, i -> i[1] ) ) = Set( gens1 ) then

      # special treatment
      exp:= List( ex2, i -> i[2] );
      ex2:= List( ex2, i -> i[1] );
      mapped:= [];
      for i in [ 2, 4 .. Length( x ) ] do
        p:= Position( gens1, x[ i-1 ] );
        if p = fail then
          Add( mapped, x[ i-1 ] );
          Add( mapped, x[  i  ] );
        else
          Add( mapped, ex2[p] );
          Add( mapped, exp[p] * x[i] );
        fi;
      od;
      mapped:= ObjByExtRep( FamilyObj( gens2[1] ), mapped );

    else

      p:= Position( gens1, x[1] );
      if p = fail then
        mapped:= ObjByExtRep( FamilyObj( gens2[1] ), [ x[1], x[2] ] );
      else
        mapped:= gens2[p] ^ x[2];
      fi;
      for i in [ 4,6 .. Length( x ) ] do
        exp:= x[ i ];
        if exp <> 0 then
          p:= Position( gens1, x[ i-1 ] );
          if p = fail then
            mapped:= mapped * ObjByExtRep( FamilyObj( gens2[1] ),
                                           [ x[ i-1 ], x[i] ] );
          else
            mapped:= mapped * gens2[p] ^ exp;
          fi;
        fi;
      od;

    fi;

    return mapped;
end );

InstallMethod( MappedWord,
    "for an assoc. word, a homogeneous list, and a list",
    IsElmsCollsX,
    [ IsAssocWord, IsAssocWordCollection, IsList ],
    MappedWordForAssocWord );


#############################################################################
##
#M  Reversed( <word> )  . . . . . . . . . . . . . . . . .  for an assoc. word
##
InstallOtherMethod( Reversed,
    "for an assoc. word",
    true,
    [ IsAssocWord ], 0,
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
#M  CyclicReducedWordList( <word>, <gens> )
##
InstallMethod( CyclicReducedWordList,
    "for word and generators list",
    IsElmsColls,
    [ IsAssocWord,
      IsHomogeneousList ],
    0,

function( w, gens )
    local   posg,  invg,  i,  s,  e,  str,  j;

    gens := List( gens, ExtRepOfObj );
    posg := [];
    invg := [];
    for i  in [ 1 .. Length(gens) ]  do
        if 2 <> Length(gens[i]) or not gens[i][2] in [-1,1]  then
            Error( gens[i], " is not a generator" );
        fi;
        if gens[i][2] = 1  then
            posg[gens[i][1]] := i;
            invg[gens[i][1]] := -i;
        else
            posg[gens[i][1]] := -i;
            invg[gens[i][1]] := i;
        fi;
    od;
    w := ExtRepOfObj(w);
    s := 1;
    e := Length(w)-1;
    while s < e and w[s] = w[e] and w[s+1] = -w[e+1]  do
        if not IsBound(posg[w[s]])  then
            return fail;
        fi;
        s := s + 2;
        e := e + 2;
    od;
    if s < e and w[s] = w[e]  then
        w[s+1] := w[s+1] + w[e+1];
        e := e - 2;
    fi;
    str := [];
    for i  in [ s, s+2 .. e ]  do
        if not IsBound(posg[w[i]])  then
            return fail;
        fi;
        if 0 < w[i+1]  then
            for j  in [ 1 .. w[i+1] ]  do
                Add( str, posg[w[i]] );
            od;
        else
            for j  in [ 1 .. -w[i+1] ]  do
                Add( str, invg[w[i]] );
            od;
        fi;
    od;
    return str;

end );


InstallMethod( CyclicReducedWordList,
    "for word and empty generators list",
    true,
    [ IsAssocWord,
      IsEmpty and IsList ],
    0,

function( word, gens )
    if One(word) <> word  then
        return fail;
    else
        return [];
    fi;
end );

#############################################################################
##
#F  IsBasicWreathLessThanOrEqual( <u>, <v> )
##
##  for two associative words <u> and <v>.
##  It returns true if <u> is less than or equal to <v>, with
##  respect to the basic wreath product ordering.
##
##	An ordering is assumed in the alphabet.
##	Plus, u<v if u'<v' where u=xu'y and v=xv'y
##	So, if u and v have no common prefix, u is less than v wrt this ordering if
##	  (i) maxletter(v) > maxletter(u); or	
##	 (ii) maxletter(u) = maxletter(v) and
##			 	#maxletter(u) < #maxletter(v); or
##	(iii)	maxletter(u) = maxletter(v) =b and
##				#maxletter(u) = #maxletter(v) and
##				if u = u1 * b * u2 * b ... b * uk
##					 v = v1 * b * v2 * b ... b * vk
##				then u1<v1 in the basic wreath product ordering.
##
InstallGlobalFunction( IsBasicWreathLessThanOrEqual,
function( u, v )

	local i,n,m,l,length_of_longest_common_prefix;

	#######################################################
	# returns 0 if the words have no common prefix
	# or returns the length of the longest common prefix 
	length_of_longest_common_prefix:=function(a,b)
 
  	local l;

	  #it runs through the words until finding a different letter
  	#and returns the length of that common prefix (or zero)
	  for l in [1..Minimum(Length(a),Length(b))] do
			if Subword(a,l,l)<>Subword(b,l,l) then
    	  return l-1; 
	    fi;
  	od;

	  #here we know that the smallest word is a subword of the other
  	#Hence the smallest word is a prefix of the other
		#and that the length is l
		return l;

	end;

	# start by looking for a common prefix
	l := length_of_longest_common_prefix( u, v);

	if l<>0 then
		# if u is a prefix of v (ie l=|u|) then u<=v
		# but if v is a proper prefix of u then u>v
		if l=Length(u) then 	
			return true;
		elif l=Length(v) then
			return false;
		fi;
			
		# at this stage none of the words is a proper prefix of the other one
		# so remove the common prefix from both words
		u := Subword( u, l+1, Length(u) );
		v := Subword( v, l+1, Length(v) );
	fi;

	m := Length( u );
  n := Length( v );

	# so now u and v have no common prefixes 
	# (in particular they are not equal)
	while m>0 and n>0 do
		
		if Subword( u, m, m) > Subword( v, n, n) then
			n := n - 1;
		elif Subword( v, n, n) > Subword( u, m, m) then
			m := m - 1;
		else 
			m := m - 1;
			n := n - 1;
		fi;

	od;

	if m =0 and n<>0 then
		return true;
	else
		return false;
	fi;

end);

#############################################################################
##
#F  IsShortLexLessThanOrEqual( <u>, <v> )
##
##  for two associative words <u> and <v>.
##  It returns true if <u> is less than or equal to <v>, with
##  respect to the shortlex ordering.
##	(the shortlex ordering is the default one given by u<=v)
##
InstallGlobalFunction( IsShortLexLessThanOrEqual,
function( u, v )
	return u<=v;
end);


#############################################################################
##

#E

