#############################################################################
##
#W  wordass.gd                  GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright 1997,    Lehrstuhl D fuer Mathematik,   RWTH Aachen,    Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for associative words.
##
##  1. Categories of Associative Words
##  2. Comparison of Associative Words
##  3. Operations for Associative Words
##  4. Operations for Associative Words by their Syllables
##  5. Free Groups, Monoids, and Semigroups
##  6. External Representation for Associative Words
##  7. Some Undocumented Functions
##
Revision.wordass_gd :=
    "@(#)$Id$";


#############################################################################
##
##  1. Categories of Associative Words
#1
##  Associative words are used to represent elements in free groups,
##  semigroups and monoids in {\GAP}
##  (see~"Free Groups, Monoids and Semigroups").
##  An associative word is just a sequence of letters,
##  where each letter is an element of an alphabet (in the following called a
##  *generator*) or its inverse.
##  Associative words can be multiplied;
##  in free monoids also the computation of an identity is permitted,
##  in free groups also the computation of inverses
##  (see~"Operations for Associative Words").
##


#############################################################################
##
#C  IsAssocWord( <obj> )
#C  IsAssocWordWithOne( <obj> )
#C  IsAssocWordWithInverse( <obj> )
##
##  `IsAssocWord' is the category of associative words in free semigroups,
##  `IsAssocWordWithOne' is the category of associative words in free monoids
##  (which admit the operation `One' to compute an identity),
##  `IsAssocWordWithInverse' is the category of associative words in free
##  groups (which have an inverse).
##  See~"IsWord" for more general categories of words.
##
DeclareSynonym( "IsAssocWord", IsWord and IsAssociativeElement );

DeclareSynonym( "IsAssocWordWithOne", IsAssocWord and IsWordWithOne );

DeclareSynonym( "IsAssocWordWithInverse",
    IsAssocWord and IsWordWithInverse );


#############################################################################
##
#C  IsAssocWordCollection( <obj> )
#C  IsAssocWordWithOneCollection( <obj> )
#C  IsAssocWordWithInverseCollection( <obj> )
##
DeclareCategoryCollections( "IsAssocWord" );
DeclareCategoryCollections( "IsAssocWordWithOne" );
DeclareCategoryCollections( "IsAssocWordWithInverse" );

DeclareCategoryFamily( "IsAssocWord" );
DeclareCategoryFamily( "IsAssocWordWithOne" );
DeclareCategoryFamily( "IsAssocWordWithInverse" );


#############################################################################
##
#C  IsSyllableWordsFamily( <obj> )
##
##  A syllable word family stores words by default in syllable form.
DeclareCategory( "IsSyllableWordsFamily", IsAssocWordFamily );

#C  Is8BitsFamily( <obj> )
#C  Is16BitsFamily( <obj> )
#C  Is32BitsFamily( <obj> )
#C  IsInfBitsFamily( <obj> )
##
DeclareCategory( "Is8BitsFamily", IsSyllableWordsFamily );
DeclareCategory( "Is16BitsFamily", IsSyllableWordsFamily );
DeclareCategory( "Is32BitsFamily", IsSyllableWordsFamily );
DeclareCategory( "IsInfBitsFamily", IsSyllableWordsFamily );

#############################################################################
##
#R  IsSyllableAssocWordRep( <obj> )
##
##  A word in syllable representation stores generator/exponents pairs (as
##  given by `ExtRepOfObj'. Syllable access is fast, letter access is slow
##  for such words.
DeclareRepresentation( "IsSyllableAssocWordRep", IsAssocWord, [] );

#############################################################################
##
#R  IsLetterAssocWordRep( <obj> )
##
##  A word in letter representation stores a list of generator/inverses
##  numbers (as given by `LetterRepAssocWord'). Letter access is fast,
##  syllable access is slow for such words.
##
DeclareRepresentation( "IsLetterAssocWordRep", IsAssocWord, [] );

#############################################################################
##
#R  IsBLetterAssocWordRep( <obj> )
#R  IsWLetterAssocWordRep( <obj> )
##
##  these two subrepresentations of `IsLetterAssocWordRep' indicate whether
##  the word is stored as a list of bytes (in a string) or as a list of
##  integers)
##
DeclareRepresentation( "IsBLetterAssocWordRep", IsLetterAssocWordRep, [] );
DeclareRepresentation( "IsWLetterAssocWordRep", IsLetterAssocWordRep, [] );

#############################################################################
##
#C  IsLetterWordsFamily( <obj> )
##
##  A letter word family stores words by default in letter form. 
##
DeclareCategory( "IsLetterWordsFamily", IsAssocWordFamily );

#############################################################################
##
#C  IsBLetterWordsFamily( <obj> )
#C  IsWLetterWordsFamily( <obj> )
##
##  These two subcategories of `IsLetterWordsFamily' specify the type of
##  letter representation to be used.
##
DeclareCategory( "IsBLetterWordsFamily", IsLetterWordsFamily );
DeclareCategory( "IsWLetterWordsFamily", IsLetterWordsFamily );


#############################################################################
##
#T  IsFreeSemigroup( <obj> )
#T  IsFreeMonoid( <obj> )
#C  IsFreeGroup( <obj> )
##
##  Any group consisting of elements in `IsAssocWordWithInverse' lies in the
##  filter `IsFreeGroup';
##  this holds in particular for any group created with `FreeGroup'
##  (see~"FreeGroup"), or any subgroup of such a group.
##
#T  Note that we cannot define `IsFreeMonoid' as
#T  `IsAssocWordWithOneCollection and IsMonoid' because then
#T  every free group would be a free monoid, which is not true!
#T  Instead we just make it a property and set it at creation
##
DeclareProperty("IsFreeSemigroup", IsAssocWordCollection and IsSemigroup);
DeclareProperty("IsFreeMonoid", IsAssocWordWithOneCollection and IsMonoid);
DeclareSynonym( "IsFreeGroup",
    IsAssocWordWithInverseCollection and IsGroup );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <coll> )
##
InstallTrueMethod( IsGeneratorsOfMagmaWithInverses,
    IsAssocWordWithInverseCollection );


#############################################################################
##
#F  AssignGeneratorVariables(<G>)
##
##  If <G> is a group, whose generators are represented by symbols (for 
##  example a free group, a finitely presented group or a pc group) this
##  function assigns these generators to global variables with the same 
##  names.
##
##  The aim of this function is to make it easy in interactive use to work
##  with (for example) a free group. It is a shorthand for a sequence of
##  assignments of the form
##
##  \begintt
##  var1:=GeneratorsOfGroup(G)[1];
##  var2:=GeneratorsOfGroup(G)[2];
##  ...
##  varn:=GeneratorsOfGroup(G)[n];
##  \endtt
##
##  However, since overwriting global variables can be very dangerous, *it
##  is not permitted to use this function within a function*. (If -- despite
##  this warning -- this is done, the result is undefined.)
##  
##  If the assignment overwrites existing variables a warning is given, if
##  any of the variables if write protected, or any of the generator names   
##  would not be a proper variable name, an error is raised.
##
DeclareGlobalFunction( "AssignGeneratorVariables" );

#############################################################################
##
##  2. Comparison of Associative Words
#2
##  \>`<w1> = <w2>'{equality!associative words}
##
##  Two associative words are equal if they are words over the same alphabet
##  and if they are sequences of the same letters.
##  This is equivalent to saying that the external representations of the
##  words are equal, see~"The External Representation for Associative Words" and
##  "Comparison of Words".
##
##  There is no ``universal'' empty word,
##  every alphabet (that is, every family of words) has its own empty word.
##  \beginexample
##  gap> f:= FreeGroup( "a", "b", "b" );;
##  gap> gens:= GeneratorsOfGroup(f);
##  [ a, b, b ]
##  gap> gens[2] = gens[3];
##  false
##  gap> x:= gens[1]*gens[2];
##  a*b
##  gap> y:= gens[2]/gens[2]*gens[1]*gens[2];
##  a*b
##  gap> x = y;
##  true
##  gap> z:= gens[2]/gens[2]*gens[1]*gens[3];
##  a*b
##  gap> x = z;
##  false
##  \endexample
##
##  \>`<w1> \< <w2>'{smaller!associative words}
##
##  The ordering of associative words is defined by length and lexicography
##  (this ordering is called *short-lex* ordering),
##  that is, shorter words are smaller than longer words,
##  and words of the same length are compared w.r.t.~the lexicographical
##  ordering induced by the ordering of generators.
##  Generators are sorted according to the order in which they were created.
##  If the generators are invertible then each generator <g> is larger than
##  its inverse `<g>^-1',
##  and `<g>^-1' is larger than every generator that is smaller than <g>.
##  \beginexample
##  gap> f:= FreeGroup( 2 );;  gens:= GeneratorsOfGroup( f );;
##  gap> a:= gens[1];;  b:= gens[2];;
##  gap> One(f) < a^-1;  a^-1 < a;  a < b^-1;  b^-1 < b; b < a^2;  a^2 < a*b;
##  true
##  true
##  true
##  true
##  true
##  true
##  \endexample
##


#############################################################################
##
##  3. Operations for Associative Words
#3
##  The product of two given associative words is defined as the freely
##  reduced concatenation of the words;
##  so adjacent pairs of a generator and its inverse never occur in words.
##  Besides the multiplication `\*', the arithmetical operators
##  `One' (if the word lies in a family with identity)
##  and (if the generators are invertible) `Inverse', `/',`^', `Comm',
##  and `LeftQuotient' are applicable to associative words
##  (see~"Arithmetic Operations for Elements").
##
##  For the operation `MappedWord', which is applicable to arbitrary words,
##  see~"MappedWord".
##


#############################################################################
##
#A  Length( <w> )
##
##  For an associative word <w>,
##  `Length' returns the number of letters in <w>.
##
DeclareAttribute( "Length", IsAssocWord );


#############################################################################
##
#O  Subword( <w>, <from>, <to> )
##
##  For an associative word <w> and two positive integers <from> and <to>,
##  `Subword' returns the subword of <w> that begins at position <from>
##  and ends at position <to>.
##  Indexing is done with origin 1.
##
DeclareOperation( "Subword", [ IsAssocWord, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  PositionWord( <w>, <sub>, <from> )
##
##  Let <w> and <sub> be associative words, and <from> a positive integer.
##  `PositionWord' returns the position of the first occurrence of <sub>
##  as a subword of <w>, starting at position <from>.
##  If there is no such occurrence, `fail' is returned.
##  Indexing is done with origin 1.
##
##  In other words, `PositionWord( <w>, <sub>, <from> )' is the smallest
##  integer <i> larger than or equal to <from> such that
##  `Subword( <w>, <i>, <i>+Length( <sub> )-1 ) = <sub>', see~"Subword".
##
DeclareOperation( "PositionWord", [ IsAssocWord, IsAssocWord, IsPosInt ] );


#############################################################################
##
#O  SubstitutedWord( <w>, <from>, <to>, <by> )
#O  SubstitutedWord( <w>, <sub>, <from>, <by> )
##
##  Let <w> be an associative word.
##
##  In the first form, `SubstitutedWord' returns the associative word
##  obtained by replacing the subword of <w> that begins at position <from>
##  and ends at position <to> by the associative word <by>.
##  <from> and <to> must be positive integers,
##  indexing is done with origin 1.
##  In other words, `SubstitutedWord( <w>, <from>, <to>, <by> )' is the
##  product of the three words `Subword( <w>, 1, <from>-1 )', <by>,
##  and `Subword( <w>, <to>+1, Length( <w> ) )', see~"Subword".
##
##  In the second form, `SubstitutedWord' returns the associative word
##  obtained by replacing the first occurrence of the associative word <sub>
##  of <w>, starting at position <from>, by the associative word <by>;
##  if there is no such occurrence, `fail' is returned.
##
DeclareOperation( "SubstitutedWord",
    [ IsAssocWord, IsPosInt, IsPosInt, IsAssocWord ] );

DeclareOperation( "SubstitutedWord",
    [ IsAssocWord, IsAssocWord, IsPosInt, IsAssocWord ] );


#############################################################################
##
#O  EliminatedWord( <w>, <gen>, <by> )
##
##  For an associative word <w>, a generator <gen>, and an associative word
##  <by>, `EliminatedWord' returns the associative word obtained by
##  replacing each occurrence of <gen> in <w> by <by>.
##
DeclareOperation( "EliminatedWord",
    [ IsAssocWord, IsAssocWord, IsAssocWord ] );


#############################################################################
##
#O  ExponentSumWord( <w>, <gen> )
##
##  For an associative word <w> and a generator <gen>,
##  `ExponentSumWord' returns the number of times <gen> appears in <w>
##  minus the number of times its inverse appears in <w>.
##  If both <gen> and its inverse do not occur in <w> then $0$ is returned.
##  <gen> may also be the inverse of a generator.
##
DeclareOperation( "ExponentSumWord", [ IsAssocWord, IsAssocWord ] );

#4
##  There are two internal representations of associative words: By letters
##  and by syllables (see~"Representations for Associative Words"). Unless
##  something else is specified, words are stored in the letter
##  representation. Note, however, that operations to extract or act on
##  parts of words (letter or syllables) can carry substantially different
##  costs, depending on the representation the words are in.

#############################################################################
##
##  4. Operations for Associative Words by their Syllables
#5
##  For an associative word $<w> = x_1^{n_1} x_2^{n_2} \cdots x_k^{n_k}$
##  over an alphabet containing $x_1, x_2, \ldots, x_k$,
##  such that $x_i \not= x_{i+1}^{\pm 1}$ for $1 \leq i \leq k-1$,
##  the subwords $x_i^{e_i}$ are uniquely determined;
##  these powers of generators are called the *syllables* of $w$.
##


#############################################################################
##
#A  NumberSyllables( <w> )
##
##  `NumberSyllables' returns the number of syllables of the associative
##  word <w>.
##
DeclareAttribute( "NumberSyllables", IsAssocWord );
DeclareSynonymAttr( "NrSyllables", NumberSyllables );


#############################################################################
##
#O  ExponentSyllable( <w>, <i> )
##
##  `ExponentSyllable' returns the exponent of the <i>-th syllable of the
##  associative word <w>.
##
DeclareOperation( "ExponentSyllable", [ IsAssocWord, IsPosInt ] );


#############################################################################
##
#O  GeneratorSyllable( <w>, <i> )
##
##  `GeneratorSyllable' returns the number of the generator that is involved
##  in the <i>-th syllable of the associative word <w>.
##
DeclareOperation( "GeneratorSyllable", [ IsAssocWord, IsInt ] );


#############################################################################
##
#O  SubSyllables( <w>, <from>, <to> )
##
##  `SubSyllables' returns the subword of the associative word <w>
##  that consists of the syllables from positions <from> to <to>,
##  where <from> and <to> must be positive integers,
##  and indexing is done with origin 1.
##
DeclareOperation( "SubSyllables", [ IsAssocWord, IsInt, IsInt ] );


#############################################################################
##
##  5. Operations for Associative Words by their Letters


#############################################################################
##
#O  LetterRepAssocWord( <w> )
#O  LetterRepAssocWord( <w>, <gens> )
##
##  The *letter representation* of an associated word is as a list of
##  integers, each entry corresponding to a group generator. Inverses of the
##  generators are represented by negative numbers. The generator numbers
##  are as associated to the family.
##  
##  This operation returns the letter representation of the associative word
##  <w>.
##
##  In the second variant, the generator numbers correspond to the
##  generator order given in the list <gens>.
##
##  (For words stored in syllable form the letter representation has to be
##  comnputed.)
##
DeclareOperation( "LetterRepAssocWord", [ IsAssocWord ] );


#############################################################################
##
#O  AssocWordByLetterRep( <Fam>, <lrep> [,<gens>] )
##
##  takes a letter representation <lrep> (see `LetterRepAssocWord',
##  section~"LetterRepAssocWord") and returns an associative word in
##  family <fam>. corresponding to this letter representation.
##
##  If <gens> is given, the numbers in the letter
##  rerpresentation correspond to <gens>.
DeclareOperation( "AssocWordByLetterRep",[IsFamily,IsList] );


#############################################################################
##
#O  SyllableRepAssocWord( <w> )
##
##  returns a word equal to <w> in syllable representation. This is needed
##  for the use of words for pc groups.
DeclareOperation( "SyllableRepAssocWord", [ IsAssocWord ] );

#############################################################################
##
##  6. External Representation for Associative Words
#6
##  The external representation of the associative word $w$ is defined as
##  follows.
##  If $w = g_{i_1}^{e_1} * g_{i_2}^{e_2} * \cdots * g_{i_k}^{e_k}$
##  is a word over the alphabet $g_1, g_2, \ldots$,
##  i.e., $g_i$ denotes the $i$-th generator of the family of $w$,
##  then $w$ has external representation
##  $[ i_1, e_1, i_2, e_2, \ldots, i_k, e_k ]$.
##  The empty list describes the identity element (if exists) of the family.
##  Exponents may be negative if the family allows inverses.
##  The external representation of an associative word is guaranteed to be
##  freely reduced;
##  for example, $g_1 * g_2 * g_2^{-1} * g_1$ has the external representation
##  `[ 1, 2 ]'.
##
##  Regardless of the family preference for letter or syllable
##  representations (see~"Representations for Associative Words"),
##  `ExtRepOfObj' and `ObjByExtRep' can be used and interface to this
##  ``syllable''-like representation.
##


#############################################################################
##
##  7. Some Undocumented Functions
##


#############################################################################
##
#O  ExponentSums( <w> )
#O  ExponentSums( <w>, <from>, <to> )
##
##  returns the exponent sums in <w>. The second version loops over the
##  syllables <from> to <to>.
DeclareOperation( "ExponentSums", [ IsAssocWord ] );


#############################################################################
##
#O  RenumberedWord( <word>, <renumber> )  . . . renumber generators of a word
##
##  accepts an associative word <word> and a list <renumber> of positive
##  integers.  The result is a new word obtained from <word> by replacing
##  each occurrence of generator number $g$ by <renumber>[g].  The list
##  <renumber> need not be dense, but it must have a positive integer for
##  each  generator number occurring in <word>.  That integer must not exceed
##  the number of generators in the elements family of <word>.
##
DeclareOperation( "RenumberedWord", [IsAssocWord, IsList] );


#############################################################################
##
#O  AssocWord( <Fam>, <extrep> )  . . . .  construct word from external repr.
#O  AssocWord( <Type>, <extrep> ) . . . .  construct word from external repr.
##
DeclareGlobalFunction( "AssocWord" );


#############################################################################
##
#O  ObjByVector( <Fam>, <exponents> )
#O  ObjByVector( <Type>, <exponents> )
##
##  is the associative word in the family <Fam> that has exponents vector
##  <exponents>.
##
DeclareGlobalFunction( "ObjByVector" );


# is not used anywhere
# #############################################################################
# ##
# #O  CyclicReducedWordList( <word>, <gens> )
# ##
# DeclareOperation( "CyclicReducedWordList", [ IsAssocWord, IsList ] );


#############################################################################
##
#F  StoreInfoFreeMagma( <F>, <names>, <req> )
##
##  `StoreInfoFreeMagma' does the administrative work in the construction of
##  free semigroups, free monoids, and free groups.
##
##  <F> is the family of objects, <names> is a list of generators names,
##  and <req> is the required category for the elements, that is,
##  `IsAssocWord', `IsAssocWordWithOne', or `IsAssocWordWithInverse'.
##
DeclareGlobalFunction( "StoreInfoFreeMagma" );


#############################################################################
##
#F  InfiniteListOfNames( <string>[, <initnames>] )
##
##  If the only argument is a string <string> then `InfiniteListOfNames'
##  returns an infinite list with the string $<string>i$ at position $i$.
##  If a finite list <initnames> of length $n$, say,
##  is given as second argument,
##  the $i$-th entry of the returned infinite list is equal to
##  `<initnames>[$i$]' if $i \leq n$, and equal to $<string>i$ if $i > n$.
##
DeclareGlobalFunction( "InfiniteListOfNames" );


#############################################################################
##
#F  InfiniteListOfGenerators( <F>[, <init>] )
##
##  If the only argument is a family <Fam> then `InfiniteListOfGenerators'
##  returns an infinite list containing at position $i$ the element in <Fam>
##  obtained as `ObjByExtRep( <Fam>, [ $i$, 1 ] )'.
##  If a finite list <init> of length $n$, say, is given as second argument,
##  the $i$-th entry of the returned infinite list is equal to
##  `<init>[$i$]' if $i \leq n$, and equal to `ObjByExtRep( <Fam>, $i$ )'
##  if $i > n$.
##
DeclareGlobalFunction( "InfiniteListOfGenerators" );

#############################################################################
##
#F  ERepAssWorProd( <l>,<r> )
##
##  multiplies two associative words in the external representation.
DeclareGlobalFunction("ERepAssWorProd");

#############################################################################
##
#F  ERepAssWorInv( <w> )
##
##  returns the inverse of the associative word <w> given in external
##  representation.
DeclareGlobalFunction("ERepAssWorInv");


#############################################################################
##
#E

