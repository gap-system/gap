#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for free magmas and free magma-with-ones.
##
##  Element objects of free magmas are nonassociative words.
##  For the external representation of elements, see the file `word.gi'.
##
##  (Note that a free semigroup is not a free magma, so we must not deal
##  with objects in `IsWord' here but with objects in `IsNonassocWord'.)
##


#############################################################################
##
#M  IsWholeFamily( <M> )  . . . . . . . . .  is a free magma the whole family
##
##  <M> contains the whole family of its elements if and only if all
##  magma generators of the family are among the magma generators of <M>.
##
InstallMethod( IsWholeFamily,
    "for a free magma",
    [ IsMagma and IsNonassocWordCollection ],
    M -> IsSubset( MagmaGeneratorsOfFamily( ElementsFamily( FamilyObj(M) ) ),
                   GeneratorsOfMagma( M ) ) );


#############################################################################
##
#T  Iterator( <M> ) . . . . . . . . . . . . . . . . iterator for a free magma
##


#############################################################################
##
#M  Enumerator( <M> ) . . . . . . . . . . . . . . enumerator for a free magma
##
##  Let <M> be a free magma on $N$ generators $x_1, x_2, \ldots, x_N$.
##  Each element in <M> is uniquely determined by an element in a free
##  semigroup $S$ over $s_1, s_2, \ldots, s_N$ (which is obtained by mapping
##  $x_i$ to $s_i$) plus the ``bracketing of the element.
##  Thus we can describe each element $x$ in <M> by a quadruple $[N,l,p,q]$
##  where $l$ is the length of the corresponding associative word $s$,
##  $p$ is the position of $s$ among the associative words of length $l$ in
##  $S$ (so $0 \leq p < N^l$),
##  and $q$ is the position of the bracketing of $x$
##  (so $0 \leq q < C(l-1)$),
##  where the ordering of these bracketings is defined below,
##  and $C(n) = {2n \choose n} / (n+1)$ is the $n$-th *Catalan number*.
##  See the On-Line Encyclopedia of Integer Sequences for more on Catalan
##  numbers.
##  Here we use the identity
##  $C(l-1) = \sum_{i=1}^{l-2} C(i-1) \cdot C(l-i-1)$
##  to define the ordering of bracketings recursively:
##  The product of a word of length $k$ with one of length $l-k$ comes
##  before the product of a word of length $k'$ with one of length $l-k'$
##  if $k' < k$ or if $k = k'$ and either the bracketing of the first factor
##  in the first word comes before that of the first factor in the second
##  or they are equal and the bracketing of the second factor in the first
##  word comes before that of the second factor in the second.
##
##  We set $x = w([N,l,p,q])$ and assign the position
##  $\sum_{i=1}^{l-1} N^i \cdot C(i-1) + p \cdot C(l-1) + q + 1$ to it.
##  If $x_1 = w([N, l_1, p_1, q_1])$ and $x_2 = w([N, l_2, p_2, q_2])$ then
##  $x_1 x_2 = w([N, l_1 + l_2, p_1 + N^{l_1} \cdot (p_2-1),
##               \sum_{i=1}^{l_1-1} C(i-1) \cdot C(l_1+l_2-i-1)
##               + (q_1-1) \cdot C(l_2-1) + q_2])$
##  holds.
##  Conversely, the word at position $M$ is $w([N,l,p,q])$ where $l$ is given
##  by the relation
##  $\sum_{i=1}^{l-1} N^i \cdot C(i-1) < M
##      \leq \sum_{i=1}^l N^i \cdot C(i-1)$;
##  if we set $M' = M - \sum_{i=1}^{l-1} N^i \cdot C(i-1)$ then
##  $q = (M'-1) \bmod C(l-1)$ and $p = (M'-q-1 ) / C(l-1)$.
##
BindGlobal( "ShiftedCatalan", MemoizePosIntFunction(
function( n )
    return Binomial( 2*n-2, n-1 ) / n;
end ));

BindGlobal( "ElementNumber_FreeMagma", function( enum, nr )
    local WordFromInfo, n, l, summand, NB, q, p;

    # Create the external representation (recursively).
    WordFromInfo:= function( N, l, p, q )
      local k, NB, summand, Nk, p1, p2, q1, q2;;

      if l = 1 then
        return p + 1;
      fi;

      k:= 0;
      while 0 <= q do
        k:= k+1;
        NB:= ShiftedCatalan( l-k );
        summand:= ShiftedCatalan( k ) * NB;
        q:= q - summand;
      od;
      q:= q + summand;

      Nk:= N^k;
      p1:= p mod Nk;
      p2:= ( p - p1 ) / Nk;

      q2:= q mod NB;
      q1:= ( q - q2 ) / NB;

      return [ WordFromInfo( N, k,   p1, q1 ),
               WordFromInfo( N, l-k, p2, q2 ) ];
    end;

    n:= enum!.nrgenerators;
    l:= 0;
    nr:= nr - 1;
    while 0 <= nr do
      l:= l+1;
      NB:= ShiftedCatalan( l );
      summand:= n^l * NB;
      nr:= nr - summand;
    od;
    nr:= nr + summand;

    q:= nr mod NB;
    p:= ( nr - q ) / NB;

    return ObjByExtRep( enum!.family, WordFromInfo( n, l, p, q ) );
end );

BindGlobal( "NumberElement_FreeMagma", function( enum, elm )
    local WordInfo, n, info, pos, i;

    if not IsCollsElms( FamilyObj( enum ), FamilyObj( elm ) ) then
      return fail;
    fi;

    # Analyze the structure (recursively).
    WordInfo:= function( ngens, obj )
      local info1, info2, N;

      if IsInt( obj ) then
        return [ ngens, 1, obj-1, 0 ];
      else
        info1:= WordInfo( ngens, obj[1] );
        info2:= WordInfo( ngens, obj[2] );
        N:= info1[2] + info2[2];
        return [ ngens, N,
                 info1[3]+ ngens^info1[2] * info2[3],
                 Sum( List( [ 1 .. info1[2]-1 ],
                      i -> ShiftedCatalan( i ) * ShiftedCatalan( N-i ) ), 0 )
                 + info1[4] * ShiftedCatalan( info2[2] ) + info2[4] ];
      fi;
    end;

    # Calculate the length, the number of the corresponding assoc. word,
    # and the number of the bracketing.
    n:= enum!.nrgenerators;
    info:= WordInfo( n, ExtRepOfObj( elm ) );

    # Compute the position.
    pos:= 0;
    for i in [ 1 .. info[2]-1 ] do
      pos:= pos + n^i * ShiftedCatalan( i );
    od;
    return pos + info[3] * ShiftedCatalan( info[2] ) + info[4] + 1;
end );

InstallMethod( Enumerator,
    "for a free magma",
    [ IsWordCollection and IsWholeFamily and IsMagma ],
    function( M )

    # A free associative structure needs another method.
    if IsAssocWordCollection( M ) then
      TryNextMethod();
    fi;

    return EnumeratorByFunctions( M, rec(
               ElementNumber := ElementNumber_FreeMagma,
               NumberElement := NumberElement_FreeMagma,

               family       := ElementsFamily( FamilyObj( M ) ),
               nrgenerators := Length( ElementsFamily(
                                           FamilyObj( M ) )!.names ) ) );
    end );


#############################################################################
##
#M  IsFinite( <M> ) . . . . . . . . . . . . .  for a magma of nonassoc. words
##
InstallMethod( IsFinite,
    "for a magma of nonassoc. words",
    [ IsMagma and IsNonassocWordCollection ],
    IsTrivial );


#############################################################################
##
#M  IsAssociative( <M> )  . . . . . . . . . .  for a magma of nonassoc. words
##
InstallMethod( IsAssociative,
    "for a magma of nonassoc. words",
    [ IsMagma and IsNonassocWordCollection ],
    IsTrivial );


#############################################################################
##
#M  Size( <M> ) . . . . . . . . . . . . . . . . . . . .  size of a free magma
##
InstallMethod( Size,
    "for a free magma",
    [ IsMagma and IsNonassocWordCollection ],
    function( M )
    if IsTrivial( M ) then
      return 1;
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  Random( <S> ) . . . . . . . . . . . . . .  random element of a free magma
##
#T use better method for the whole family
##
InstallMethodWithRandomSource( Random,
    "for a random source and a free magma",
    [ IsRandomSource, IsMagma and IsNonassocWordCollection ],
    function( rs, M )
    local len, result, gens, i;

    # Get a random length for the word.
    len:= Random( rs, Integers );
    if 0 <= len then
      len:= 2 * len;
    else
      len:= -2 * len - 1;
    fi;

    # Multiply $'len' + 1$ random generators.
    gens:= GeneratorsOfMagma( M );
    result:= Random( rs, gens );
    for i in [ 1 .. len ] do
      if Random( rs, 0, 1 ) = 0 then
        result:= result * Random( rs, gens );
      else
        result:= Random( rs, gens ) * result;
      fi;
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#M  MagmaGeneratorsOfFamily( <F> )  . . . . for family of free magma elements
##
InstallMethod( MagmaGeneratorsOfFamily,
    "for a family of free magma elements",
    [ IsNonassocWordFamily ],
    F -> List( [ 1 .. Length( F!.names ) ], i -> ObjByExtRep( F, i ) ) );


#############################################################################
##  Currently used by:
##    FreeGroup, FreeMonoid, FreeSemigroup, FreeMagmaWithOne, FreeMagma
InstallGlobalFunction( FreeXArgumentProcessor,
function(
  func,               # The name of the calling function
  name,               # The default prefix to use for generator names
  arg,                # The list of args passed to <func>; to be processed
  optional_first_arg, # Whether <func> allows filter as optional 1st arg
  allow_rank_zero     # Whether <func> support rank-zero objects
)
  local wfilt,   # a filter for letter or syllable words family
        err,     # string; helpful error message
        form,    # string: surmised argument form of the call to <func>
        names,   # list of generators names
        rank,    # Length( names )
        opt,
        init,
        x, y1, y2;

  # Set up defaults.
  wfilt := IsLetterWordsFamily;
  err   := "";
  form  := fail;
  names := fail;

  # Legacy documented feature to give filter for words family with an option.
  if func = "FreeGroup" and ValueOption( "FreeGroupFamilyType" ) = "syllable" then
    wfilt := IsSyllableWordsFamily; # optional -- used in PQ.
  fi;

  # The usual way is to give filter in the optional first argument.
  if not IsEmpty( arg ) and IsFilter( arg[1] ) then
    if not optional_first_arg then
      ErrorNoReturn( "the first argument must not be a filter" );
    fi;
    wfilt := arg[1];
    Remove( arg, 1 );
  fi;

  # Process and validate the argument list, constructing names as necessary.

  if Length( arg ) = 0 or arg[1] = 0
      or ( Length( arg ) = 1 and IsList( arg[1] ) and IsEmpty( arg[1] ) ) then

    # We recognise this function call as a request for a zero-generator object.
    if allow_rank_zero then
      names := [];
    else
      Info( InfoWarning, 1, func, " cannot make an object with no generators" );
    fi;

  # Validate call of form: func( <rank>[, <name> ] ).
  elif Length( arg ) <= 2 and IsPosInt( arg[1] ) then

    rank := arg[1];

    # Documented feature which allows generators to be given custom names in
    # objects created by constructors like DihedralGroup or AbelianGroup.
    opt := ValueOption( "generatorNames" ); # Note, may be overwritten by arg[2].
    if Length( arg ) = 1 and opt <> fail then
      if IsString( opt ) then
        names := List( [ 1 .. rank ], i -> Concatenation( opt, String( i ) ) );
        MakeImmutable( names );
      elif ( IsList and IsFinite )( opt ) and rank <= Length( opt )
          and ForAll( [ 1 .. rank ],
                      s -> IsString( opt[s] ) and not IsEmpty( opt[s] ) ) then
        names := MakeImmutable( opt{[ 1 .. rank ]} );
      else
        ErrorNoReturn( Concatenation(
          "Cannot process the `generatorNames` option: ",
          "the value must be either a single string, or a list ",
          "of sufficiently many nonempty strings ",
          "(at least ", String( rank ), ", in this case)" ) );
      fi;

    else
      if Length( arg ) = 2 then
        name := arg[2];
      fi;
      if not IsString( name ) then
        form := "<rank>, <name>";
        err  := "<name> must be a string";
      else
        names := List( [ 1 .. rank ], i -> Concatenation( name, String( i ) ) );
        MakeImmutable( names );
      fi;
    fi;

  # Validate call of form: func( <name1>[, <name2>, ...] ), or a list of such.
  elif ForAll( arg, IsString ) or Length( arg ) = 1 and IsList( arg[1] ) then

    if Length( arg ) = 1 and not IsString( arg[1] ) then
      form  := "[<name1>, <name2>, ...]";
      names := arg[1];
    else
      form  := "<name1>, <name2>, ...";
      names := arg;
    fi;

    # Error checking
    if not IsFinite( names ) then
      err := "there must be only finitely many names";
    elif not ForAll( names, s -> IsString( s ) and not IsEmpty( s ) ) then
      err := "the names must be nonempty strings";
    fi;

  # Validate call of form: func( infinity[, <name>][, <init>] ).
  elif Length( arg ) <= 3 and arg[1] = infinity then

    init := [];
    if Length( arg ) = 3 then
      form := "infinity, <name>, <init>";
      name := arg[2];
      init := arg[3];
    elif Length( arg ) = 2 then
      if IsList( arg[2] ) and IsFinite( arg[2] ) and not IsEmpty( arg[2] )
          and ForAll( arg[2], IsString ) then
        form := "infinity, <init>";
        init := arg[2];
      else
        form := "infinity, <name>";
        name := arg[2];
      fi;
    fi;

    # Error checking
    if not IsString( name ) then
      err := "<name> must be a string";
    elif not ( IsList( init ) and IsFinite( init ) ) then
      err := "<init> must be a finite list";
    elif not ForAll( init, s -> IsString( s ) and not IsEmpty( s ) ) then
      err := "<init> must consist of nonempty strings";
    fi;
    if IsEmpty( err ) then
      names := InfiniteListOfNames( name, init );
    fi;
  fi;

  # Call to <func> was recognised as having a particular form, but was invalid.
  if not IsEmpty( err ) then
    ErrorNoReturn( StringFormatted( "{}( {} ): {}", func, form, err ) );
  fi;

  # Unrecognised call to <func>.
  if names = fail then

    # Adapt the error message slightly depending on whether the optional
    # first argument is supported, and whether at least one argument must be
    # given (i.e. whether objects of rank zero are supported).
    x := ""; y1 := ""; y2 := "";
    if optional_first_arg then
      x := "[<wfilt>, ]";
    fi;
    if allow_rank_zero then
      y1 := "["; y2 := "]";
    fi;

    ErrorNoReturn( StringFormatted( Concatenation(
      #"Error,
              "usage: {}( {}<rank>[, <name>] )\n",
       "              {}( {}{}<name1>[, <name2>[, ...]]{} )\n",
       "              {}( {}<names> )\n",
       "              {}( {}infinity[, <name>][, <init>] )"
      ), func, x, func, x, y1, y2, func, x, func, x ) );
  fi;

  # Process words family options now that we know how many generators there are.
  if optional_first_arg then
    if not wfilt in [ IsSyllableWordsFamily, IsLetterWordsFamily,
                      IsWLetterWordsFamily, IsBLetterWordsFamily ] then
      ErrorNoReturn( Concatenation(
        "the optional first argument <wfilt> must be one of ",
        "IsSyllableWordsFamily, IsLetterWordsFamily, IsWLetterWordsFamily, ",
        "and IsBLetterWordsFamily" ) );
    fi;
    if wfilt <> IsSyllableWordsFamily then
      if Length( names ) > 127 then
        wfilt := IsWLetterWordsFamily;
      elif wfilt = IsLetterWordsFamily then
        wfilt := IsBLetterWordsFamily;
      fi;
    fi;
  fi;

  return rec(
    names := names,
    lesy  := wfilt,
  );
end );


#############################################################################
##
#F  FreeMagma( <rank>[, <name>] )
#F  FreeMagma( <name1>[, <name2>[, ...]] )
#F  FreeMagma( <names> )
#F  FreeMagma( infinity[, <name>][, <init>] )
##
InstallGlobalFunction( FreeMagma, function( arg )
    local processed,
          F,          # family of free magma element objects
          M;          # free magma, result

    processed := FreeXArgumentProcessor( "FreeMagma", "x", arg, false, false );

    # Construct the family of element objects of our magma.
    F:= NewFamily( "FreeMagmaElementsFamily", IsNonassocWord );

    # Store the names and the default type.
    F!.names:= processed.names;
    F!.defaultType:= NewType( F, IsNonassocWord and IsBracketRep );

    # Make the magma.
    if IsFinite( processed.names ) then
      M:= MagmaByGenerators( MagmaGeneratorsOfFamily( F ) );
    else
      M:= MagmaByGenerators( InfiniteListOfGenerators( F ) );
    fi;

    SetIsWholeFamily( M, true );
    SetIsTrivial( M, false );
    return M;
end );


#############################################################################
##
#F  FreeMagmaWithOne( <rank>[, <name>] )
#F  FreeMagmaWithOne( [<name1>[, <name2>[, ...]]] )
#F  FreeMagmaWithOne( <names> )
#F  FreeMagmaWithOne( infinity[, <name>][, <init>] )
##
InstallGlobalFunction( FreeMagmaWithOne,
    function( arg )
    local names,      # list of generators names
          F,          # family of free magma element objects
          M,          # free magma, result
          processed;

    processed := FreeXArgumentProcessor( "FreeMagmaWithOne", "x", arg, false, true );
    names := processed.names;

    # Handle the trivial case.
    if IsEmpty( names ) then
      return FreeGroup( 0 );
    fi;

    # Construct the family of element objects of our magma-with-one.
    F:= NewFamily( "FreeMagmaWithOneElementsFamily", IsNonassocWordWithOne );

    # Store the names and the default type.
    F!.names:= names;
    F!.defaultType:= NewType( F, IsNonassocWordWithOne and IsBracketRep );

    # Make the magma.
    if IsFinite( names ) then
      M:= MagmaWithOneByGenerators( MagmaGeneratorsOfFamily( F ) );
    else
      M:= MagmaWithOneByGenerators( InfiniteListOfGenerators( F ) );
    fi;

    SetIsWholeFamily( M, true );
    SetIsTrivial( M, false );
    return M;
end );


#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . .  for a free magma
##
InstallMethod( ViewObj,
    "for a free magma containing the whole family",
    [ IsMagma and IsWordCollection and IsWholeFamily ],
    function( M )
    if GAPInfo.ViewLength * 10 < Length( GeneratorsOfMagma( M ) ) then
      Print( "<free magma with ", Length( GeneratorsOfMagma( M ) ),
             " generators>" );
    else
      Print( "<free magma on the generators ", GeneratorsOfMagma( M ), ">" );
    fi;
end );


#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . for a free magma-with-one
##
InstallMethod( ViewObj,
    "for a free magma-with-one containing the whole family",
    [ IsMagmaWithOne and IsWordCollection and IsWholeFamily ],
    function( M )
    if GAPInfo.ViewLength * 10 < Length( GeneratorsOfMagmaWithOne( M ) ) then
      Print( "<free magma-with-one with ",
             Length( GeneratorsOfMagmaWithOne( M ) ), " generators>" );
    else
      Print( "<free magma-with-one on the generators ",
             GeneratorsOfMagmaWithOne( M ), ">" );
    fi;
end );


#############################################################################
##
#M  \.( <F>, <n> )  . . . . . . . . . .  access to generators of a free magma
#M  \.( <F>, <n> )  . . . . . . access to generators of a free magma-with-one
##
InstallAccessToGenerators( IsMagma and IsWordCollection and IsWholeFamily,
                           "free magma containing the whole family",
                           GeneratorsOfMagma );

InstallAccessToGenerators( IsMagmaWithOne and IsWordCollection
                                          and IsWholeFamily,
                           "free magma-with-one containing the whole family",
                           GeneratorsOfMagmaWithOne );
