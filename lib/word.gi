#############################################################################
##
#W  word.gi                     GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
#H  @(#)$Id$
##
##  This file contains generic methods for associative words.
##
Revision.word_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  \=( <w1>, <w2> )
##
##  The equality operator '=' evaluates to 'true' if the two words <w1> and
##  <w2> are equal and to 'false' otherwise.
##
InstallMethod( \=, IsIdentical, [ IsAssocWord, IsAssocWord ], 0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y );
    end );


#############################################################################
##
#M  \<( <w1>, <w2> )
##
##  Words  are ordered as  follows: a lexicographical   order in the external
##  representation is chosen.
##
InstallMethod( \<,
    IsIdentical,
    [ IsAssocWord,
      IsAssocWord ],
    0,

function( x, y )
    local    n;

    x := ExtRepOfObj( x );
    y := ExtRepOfObj( y );
    for n  in [ 1 .. Minimum(Length(x),Length(y)) ]  do
        if x[n] < y[n]  then
            return true;
        elif y[n] < x[n]  then
            return false;
        fi;
    od;
    return Length(x) < Length(y);
end );


#############################################################################
##
#M  \*( <w1>, <w2> )
##
##  The operator '\*' evaluates to the product of the two words <w1> and
##  <w2>.
##  Multiplication of words is done by concatenating the words
##  and removing adjacent pairs of an abstract generator and its inverse.
##
InstallMethod( \*, IsIdentical, [ IsAssocWord, IsAssocWord ], 0,
    function( x, y )

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
    if yy = [] then
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
      # so the product can be formed as object of the same kind as 'y'.
      return AssocWord( KindObj( y )![ AWP_PURE_KIND ],
                        yy{ [ p .. len+1 ] } );

    elif len < p then

      # The second argument has been eaten up,
      # so the product can be formed as object of the same kind as 'x'.
      return AssocWord( KindObj( x )![ AWP_PURE_KIND ],
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

        # This is the only case where the subkinds of 'x' and 'y'
        # may be too small.
        # So let 'ObjByExtRep' choose the appropriate subkind.
        if    KindObj( x )![ AWP_NR_BITS_EXP ]
              <= KindObj( y )![ AWP_NR_BITS_EXP ] then
          return ObjByExtRep( FamilyObj( x ), KindObj( y )![ AWP_NR_BITS_EXP ],
                                  yy[2], xx );
        else
          return ObjByExtRep( FamilyObj( x ), KindObj( x )![ AWP_NR_BITS_EXP ],
                                  yy[2], xx );
        fi;

      else

        # The exponents of the result do not exceed the exponents
        # of 'x' and 'y'.
        # So the bigger of the two kinds will be sufficient.
        Append( xx, yy );
        if    KindObj( x )![ AWP_NR_BITS_EXP ] <= KindObj( y )![ AWP_NR_BITS_EXP ] then
          return AssocWord( KindObj( y )![ AWP_PURE_KIND ], xx );
        else
          return AssocWord( KindObj( x )![ AWP_PURE_KIND ], xx );
        fi;

      fi;

    fi;
    end );


#############################################################################
##
#M  \^( <w>, <n> )
##
##  The powering operator '\^' returns the <i>-th power of the word <w>,
##  where <i> must be an integer.
##
##  Note that in a family of associative words without inverses no
##  cancellation can occur, and that the algorithm may use this fact.
##  So we must guarantee that words with inverses get the method that handles
##  the case of cancellation.
##
InstallMethod( \^, true, [ IsAssocWord, IsPosRat and IsInt ], 0,
    function( x, n )

    local xx,      # external representation of 'x'
          result,  # external representation of the result
          l,       # actual length of 'xx'
          exp,     # store one exponent value
          tail;    # trailing part in 'xx' (cancels with 'head')

    if 1 < n then

      xx:= ExtRepOfObj( x );
      if xx = [] then
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
        return AssocWord( KindObj( x )![ AWP_PURE_KIND ], result );

      else

        result[2]:= exp;
        Append( result, tail );
        return ObjByExtRep( FamilyObj( x ), KindObj( x )![ AWP_NR_BITS_EXP ],
                                xx[2], result );

      fi;

    elif n = 1 then
      return x;
    fi;
    end );

InstallMethod( \^, true, [ IsAssocWordWithInverse, IsInt ], 0,
    function( x, n )

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
    if xx = [] then
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
      return ObjByExtRep( FamilyObj( x ), KindObj( x )![ AWP_NR_BITS_EXP ], exp, xx );
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
      return AssocWord( KindObj( x )![ AWP_PURE_KIND ], head );

    else

      result[2]:= exp;
      Append( head, result );
      Append( head, tail );
      return ObjByExtRep( FamilyObj( x ), KindObj( x )![ AWP_NR_BITS_EXP ],
                              xx[2], head );

    fi;
    end );

InstallMethod( Inverse, true, [ IsAssocWordWithInverse ], 0,
    function( x )

    local xx,      # external representation of 'x'
          cxx,     # external repres. of the inverse of 'x'
          i,       # loop over 'xx'
          l;       # actual length of 'xx'

    # Consider special cases.
    xx:= ExtRepOfObj( x );
    if xx = [] then
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
    return AssocWord( KindObj( x )![ AWP_PURE_KIND ], cxx );
    end );


#############################################################################
##

#M  LengthWord( <w> )
##
InstallMethod( LengthWord, true, [ IsAssocWord ], 0,
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
InstallMethod( ExponentSyllable, true, [ IsAssocWord, IsInt and IsPosRat ],
    0,
    function( w, n )
    return ExtRepOfObj( w )[ 2*n ];
    end );


#############################################################################
##
#M  GeneratorSyllable( <w>, <n> )
##
InstallMethod( GeneratorSyllable, true, [ IsAssocWord, IsInt and IsPosRat ],
    0,
    function( w, n )
    return ExtRepOfObj( w )[ 2*n-1 ];
    end );


#############################################################################
##
#M  NumberSyllables( <w> )
##
InstallMethod( NumberSyllables, true, [ IsAssocWord ], 0,
    w -> Length( ExtRepOfObj( w ) ) / 2 );


#############################################################################
##
#M  ExponentSums( <w> )
##
InstallMethod( ExponentSums, true, [ IsAssocWord ], 0,
    function( w )
    Error( "what is this?" );
    end );


#############################################################################
##
#M  ExponentSumWord( <w>, <gen> )
##
InstallMethod( ExponentSumWord,
    "method for associative word and generator",
    IsIdentical,
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
    for i in [ 1, 3 .. Length( w ) ] do
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
#M  Subword( <w>, <from>, <to> )
##
InstallMethod( Subword,
    "method for associative word and two positions",
    true,
    [ IsAssocWord, IsPosRat and IsInt, IsPosRat and IsInt ],
    0,
    function( w, from, to )
    local extw, pos, nextexp, sub;

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
      extw[ pos ]:= nextexp;
    else
      extw[ pos ]:= - nextexp;
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
#M  PositionWord( <w>, <sub>, <from> )
##
InstallMethod( PositionWord,
    "method for two associative words and a positive integer",
    true,
    [ IsAssocWord, IsAssocWord, IsPosRat and IsInt ],
    0,
    function( w, sub, from )
    Error( "not yet implemented" );
    end );


#############################################################################
##
#M  SubstitutedWord( <w>, <from>, <to>, <by> )
##
InstallMethod( SubstitutedWord,
    "method for assoc. word, two positive integers, and assoc. word",
    true,
    [ IsAssocWord, IsPosRat and IsInt, IsPosRat and IsInt, IsAssocWord ],
    0,
    function( w, from, to, by )
    Error( "not yet implemented" );
    end );


#############################################################################
##
#M  EliminatedWord( <word>, <gen>, <by> )
##
InstallMethod( EliminatedWord,
    "method for three associative words",
    true,
#T need three argument 'IsIdentical' !
    [ IsAssocWord, IsAssocWord, IsAssocWord ],
    0,
    function( word, gen, by )
    Error( "not yet implemented" );
    end );


#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
IsElmsCollsX := function( F1, F2, F3 )
    return     HasElementsFamily( F2 )
           and IsIdentical( F1, ElementsFamily( F2 ) );
end;

InstallMethod( MappedWord, IsElmsCollsX,
    [ IsAssocWord, IsHomogeneousList, IsList ], 0,
    function( x, gens1, gens2 )

    local i, mapped, exp;

    gens1:= List( gens1, x -> ExtRepOfObj( x )[1] );
    x:= ExtRepOfObj( x );
    if Length( x ) = 0 then

      # This happens for monoid element objects.
      mapped:= gens2[1] ^ 0;

    else
      mapped:= gens2[ Position( gens1, x[1] ) ] ^ x[2];
      for i in [ 2 .. Length( x )/2 ] do
        exp:= x[ 2*i ];
        if exp <> 0 then
          mapped:= mapped * gens2[ Position( gens1, x[ 2*i-1 ] ) ] ^ exp;
        fi;
      od;
    fi;

    return mapped;
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

#E  word.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
