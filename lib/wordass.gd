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


#############################################################################
##
##  1. Categories of Associative Words
##
##  <#GAPDoc Label="[1]{wordass}">
##  Associative words are used to represent elements in free groups,
##  semigroups and monoids in &GAP;
##  (see&nbsp;<Ref Sect="Free Groups, Monoids and Semigroups"/>).
##  An associative word is just a sequence of letters,
##  where each letter is an element of an alphabet (in the following called a
##  <E>generator</E>) or its inverse.
##  Associative words can be multiplied;
##  in free monoids also the computation of an identity is permitted,
##  in free groups also the computation of inverses
##  (see&nbsp;<Ref Sect="Operations for Associative Words"/>).
##  <P/>
##  Different alphabets correspond to different families of associative words.
##  There is no relation whatsoever between words in different families.
##  <P/>
##  <Example><![CDATA[
##  gap> f:= FreeGroup( "a", "b", "c" );
##  <free group on the generators [ a, b, c ]>
##  gap> gens:= GeneratorsOfGroup(f);
##  [ a, b, c ]
##  gap> w:= gens[1]*gens[2]/gens[3]*gens[2]*gens[1]/gens[1]*gens[3]/gens[2];
##  a*b*c^-1*b*c*b^-1
##  gap> w^-1;
##  b*c^-1*b^-1*c*b^-1*a^-1
##  ]]></Example>
##  <P/>
##  Words are displayed as products of letters.
##  The letters are usually printed like <C>f1</C>, <C>f2</C>, <M>\ldots</M>,
##  but it is possible to give user defined names to them,
##  which can be arbitrary strings.
##  These names do not necessarily identify a unique letter (generator),
##  it is possible to have several letters
##  &ndash;even in the same family&ndash; that are displayed in the same way.
##  Note also that
##  <E>there is no relation between the names of letters and variable names</E>.
##  In the example above, we might have typed
##  <P/>
##  <Example><![CDATA[
##  gap> a:= f.1;; b:= f.2;; c:= f.3;;
##  ]]></Example>
##  <P/>
##  (<E>Interactively</E>, the function
##  <Ref Oper="AssignGeneratorVariables"/> provides a shorthand for this.)
##  This allows us to define <C>w</C> more conveniently:
##  <P/>
##  <Example><![CDATA[
##  gap> w := a*b/c*b*a/a*c/b;
##  a*b*c^-1*b*c*b^-1
##  ]]></Example>
##  <P/>
##  Using homomorphisms it is possible to express elements of a group as words
##  in terms of generators,
##  see&nbsp;<Ref Sect="Expressing Group Elements as Words in Generators"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsAssocWord( <obj> )
#C  IsAssocWordWithOne( <obj> )
#C  IsAssocWordWithInverse( <obj> )
##
##  <#GAPDoc Label="IsAssocWord">
##  <ManSection>
##  <Filt Name="IsAssocWord" Arg='obj' Type='Category'/>
##  <Filt Name="IsAssocWordWithOne" Arg='obj' Type='Category'/>
##  <Filt Name="IsAssocWordWithInverse" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsAssocWord"/> is the category of associative words
##  in free semigroups,
##  <Ref Filt="IsAssocWordWithOne"/> is the category of associative words
##  in free monoids
##  (which admit the operation <Ref Attr="One"/> to compute an identity),
##  <Ref Filt="IsAssocWordWithInverse"/> is the category of associative words
##  in free groups (which have an inverse).
##  See&nbsp;<Ref Filt="IsWord"/> for more general categories of words.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Filt Name="IsAssocWordCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsAssocWordWithOneCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsAssocWordWithInverseCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="IsSyllableWordsFamily">
##  <ManSection>
##  <Filt Name="IsSyllableWordsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  A syllable word family stores words by default in syllable form.
##  There are also different versions of syllable representations, which
##  compress a generator exponent pair in 8, 16 or 32 bits or use a pair of
##  integers.
##  Internal mechanisms try to make this as memory efficient as possible.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsSyllableWordsFamily", IsAssocWordFamily );


#############################################################################
##
#C  Is8BitsFamily( <obj> )
#C  Is16BitsFamily( <obj> )
#C  Is32BitsFamily( <obj> )
#C  IsInfBitsFamily( <obj> )
##
##  <#GAPDoc Label="Is8BitsFamily">
##  <ManSection>
##  <Filt Name="Is16BitsFamily" Arg='obj' Type='Category'/>
##  <Filt Name="Is32BitsFamily" Arg='obj' Type='Category'/>
##  <Filt Name="IsInfBitsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  Regardless of the internal representation used, it is possible to convert
##  a word in a list of numbers in letter or syllable representation and vice
##  versa.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "Is8BitsFamily", IsSyllableWordsFamily );
DeclareCategory( "Is16BitsFamily", IsSyllableWordsFamily );
DeclareCategory( "Is32BitsFamily", IsSyllableWordsFamily );
DeclareCategory( "IsInfBitsFamily", IsSyllableWordsFamily );

#############################################################################
##
#R  IsSyllableAssocWordRep( <obj> )
##
##  <#GAPDoc Label="IsSyllableAssocWordRep">
##  <ManSection>
##  <Filt Name="IsSyllableAssocWordRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  A word in syllable representation stores generator/exponents pairs (as
##  given by <Ref Oper="ExtRepOfObj"/>.
##  Syllable access is fast, letter access is slow for such words.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsSyllableAssocWordRep",
                       IsAssocWord and IsPositionalObjectRep, [] );

#############################################################################
##
#R  IsLetterAssocWordRep( <obj> )
##
##  <#GAPDoc Label="IsLetterAssocWordRep">
##  <ManSection>
##  <Filt Name="IsLetterAssocWordRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  A word in letter representation stores a list of generator/inverses
##  numbers (as given by <Ref Oper="LetterRepAssocWord"/>).
##  Letter access is fast, syllable access is slow for such words.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
if IsHPCGAP then
DeclareRepresentation( "IsLetterAssocWordRep",
                       IsAssocWord and IsAtomicPositionalObjectRep, [] );
else
DeclareRepresentation( "IsLetterAssocWordRep",
                       IsAssocWord and IsPositionalObjectRep, [] );
fi;

#############################################################################
##
#R  IsBLetterAssocWordRep( <obj> )
#R  IsWLetterAssocWordRep( <obj> )
##
##  <#GAPDoc Label="IsBLetterAssocWordRep">
##  <ManSection>
##  <Filt Name="IsBLetterAssocWordRep" Arg='obj' Type='Representation'/>
##  <Filt Name="IsWLetterAssocWordRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  these two subrepresentations of <Ref Filt="IsLetterAssocWordRep"/>
##  indicate whether the word is stored as a list of bytes (in a string)
##  or as a list of integers).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsBLetterAssocWordRep", IsLetterAssocWordRep, [] );
DeclareRepresentation( "IsWLetterAssocWordRep", IsLetterAssocWordRep, [] );

#############################################################################
##
#C  IsLetterWordsFamily( <obj> )
##
##  <#GAPDoc Label="IsLetterWordsFamily">
##  <ManSection>
##  <Filt Name="IsLetterWordsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  A letter word family stores words by default in letter form.
##  <P/>
##  Internally, there are letter representations that use integers (4 Byte)
##  to represent a generator and letter representations that use single bytes
##  to represent a character.
##  The latter are more memory efficient, but can only be used if there are
##  less than 128 generators (in which case they are used by default).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsLetterWordsFamily", IsAssocWordFamily );

#############################################################################
##
#C  IsBLetterWordsFamily( <obj> )
#C  IsWLetterWordsFamily( <obj> )
##
##  <#GAPDoc Label="IsBLetterWordsFamily">
##  <ManSection>
##  <Filt Name="IsBLetterWordsFamily" Arg='obj' Type='Category'/>
##  <Filt Name="IsWLetterWordsFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  These two subcategories of <Ref Filt="IsLetterWordsFamily"/> specify the
##  type of letter representation to be used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsBLetterWordsFamily", IsLetterWordsFamily );
DeclareCategory( "IsWLetterWordsFamily", IsLetterWordsFamily );


#############################################################################
##
#F  WordProductLetterRep( <w1>,<w2>,... ) . construct word from external repr.
##
##  <ManSection>
##  <Func Name="WordProductLetterRep" Arg='<w1>,<w2>,...'/>
##
##  <Description>
##  Given lists that are letter representations of words, this function
##  calculates the product, maintaining that the result is freely reduced
##  if the input is.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "WordProductLetterRep" );

#############################################################################
##
#F  FreelyReducedLetterRepWord( <w> ) . free reduction
##
##  <ManSection>
##  <Func Name="FreelyReducedLetterRepWord" Arg='<w1>,<w2>,...'/>
##
##  <Description>
##  Given lists that is the  letter representation of a word, this function
##  returns a freely reduced version.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "FreelyReducedLetterRepWord" );


#############################################################################
##
#T  IsFreeSemigroup( <obj> )
#T  IsFreeMonoid( <obj> )
#C  IsFreeGroup( <obj> )
##
##  <#GAPDoc Label="IsFreeGroup">
##  <ManSection>
##  <Filt Name="IsFreeGroup" Arg='obj' Type='Category'/>
##
##  <Description>
##  Any group consisting of elements in <Ref Filt="IsAssocWordWithInverse"/>
##  lies in the filter <Ref Filt="IsFreeGroup"/>;
##  this holds in particular for any group created with
##  <Ref Func="FreeGroup" Label="for given rank"/>,
##  or any subgroup of such a group.
##  <P/>
##  <!--  Note that we cannot define <C>IsFreeMonoid</C> as-->
##  <!--  <C>IsAssocWordWithOneCollection and IsMonoid</C> because then-->
##  <!--  every free group would be a free monoid, which is not true!-->
##  <!--  Instead we just make it a property and set it at creation-->
##  Also see Chapter&nbsp;<Ref Chap="Finitely Presented Groups"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsFreeSemigroup", IsAssocWordCollection and IsSemigroup);
InstallTrueMethod(IsSemigroup, IsFreeSemigroup);

DeclareProperty("IsFreeMonoid", IsAssocWordWithOneCollection and IsMonoid);
InstallTrueMethod(IsMonoid, IsFreeMonoid);

DeclareSynonym( "IsFreeGroup",
    IsAssocWordWithInverseCollection and IsGroup );
InstallTrueMethod(IsGroup, IsFreeGroup);

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
##  <#GAPDoc Label="AssignGeneratorVariables">
##  <ManSection>
##  <Oper Name="AssignGeneratorVariables" Arg='G'/>
##
##  <Description>
##  If <A>G</A> is a group, whose generators are represented by symbols (for
##  example a free group, a finitely presented group or a pc group) this
##  function assigns these generators to global variables with the same
##  names.
##  <P/>
##  The aim of this function is to make it easy in interactive use to work
##  with (for example) a free group. It is a shorthand for a sequence of
##  assignments of the form
##  <P/>
##  <Log><![CDATA[
##  var1:=GeneratorsOfGroup(G)[1];
##  var2:=GeneratorsOfGroup(G)[2];
##  ...
##  varn:=GeneratorsOfGroup(G)[n];
##  ]]></Log>
##  <P/>
##  However, since overwriting global variables can be very dangerous,
##  <E>it is not permitted to use this function within a function</E>.
##  (If &ndash;despite this warning&ndash; this is done,
##  the result is undefined.)
##  <P/>
##  If the assignment overwrites existing variables a warning is given, if
##  any of the variables is write protected, or any of the generator names
##  would not be a proper variable name, an error is raised.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AssignGeneratorVariables", [IsDomain] );

#############################################################################
##
##  2. Comparison of Associative Words
##
##  <#GAPDoc Label="[2]{wordass}">
##  <ManSection>
##  <Oper Name="\=" Arg='w1, w2' Label="for associative words"/>
##
##  <Description>
##  <Index Subkey="associative words">equality</Index>
##  Two associative words are equal if they are words over the same alphabet
##  and if they are sequences of the same letters.
##  This is equivalent to saying that the external representations of the
##  words are equal,
##  see&nbsp;<Ref Sect="The External Representation for Associative Words"/>
##  and <Ref Sect="Comparison of Words"/>.
##  <P/>
##  There is no <Q>universal</Q> empty word,
##  every alphabet (that is, every family of words) has its own empty word.
##  <Example><![CDATA[
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
##  ]]></Example>
##  </Description>
##  </ManSection>
##
##  <ManSection>
##  <Oper Name="\&lt;" Arg='w1, w2' Label="for associative words"/>
##
##  <Description>
##  <Index Subkey="associative words">smaller</Index>
##  The ordering of associative words is defined by length and lexicography
##  (this ordering is called <E>short-lex</E> ordering),
##  that is, shorter words are smaller than longer words,
##  and words of the same length are compared w.r.t.&nbsp;the lexicographical
##  ordering induced by the ordering of generators.
##  Generators are sorted according to the order in which they were created.
##  If the generators are invertible then each generator <A>g</A> is larger
##  than its inverse <A>g</A><C>^-1</C>,
##  and <A>g</A><C>^-1</C> is larger than every generator that is smaller
##  than <A>g</A>.
##  <Example><![CDATA[
##  gap> f:= FreeGroup( 2 );;  gens:= GeneratorsOfGroup( f );;
##  gap> a:= gens[1];;  b:= gens[2];;
##  gap> One(f) < a^-1;  a^-1 < a;  a < b^-1;  b^-1 < b; b < a^2;  a^2 < a*b;
##  true
##  true
##  true
##  true
##  true
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
##  3. Operations for Associative Words
##
##  <#GAPDoc Label="[3]{wordass}">
##  The product of two given associative words is defined as the freely
##  reduced concatenation of the words.
##  <Index Subkey="of words">product</Index>
##  <Index Subkey="of words">quotient</Index>
##  <Index Subkey="of words">power</Index>
##  <Index Subkey="of a word">conjugate</Index>
##  Besides the multiplication <Ref Oper="\*"/>, the arithmetical operators
##  <Ref Attr="One"/> (if the word lies in a family with identity)
##  and (if the generators are invertible) <Ref Attr="Inverse"/>,
##  <Ref Oper="\/"/>,<Ref Oper="\^"/>,
##  <Index Key="Comm" Subkey="for words"><C>Comm</C></Index>
##  <Ref Oper="Comm"/>, and
##  <Index Key="LeftQuotient" Subkey="for words"><C>LeftQuotient</C></Index>
##  <Ref Oper="LeftQuotient"/> are applicable to associative words,
##  see&nbsp;<Ref Sect="Arithmetic Operations for Elements"/>.
##  <P/>
##  See also <Ref Oper="MappedWord"/>, an operation that is applicable to
##  arbitrary words.
##  <P/>
##  See Section <Ref Sect="Representations for Associative Words"/>
##  for a discussion of the internal representations of associative words
##  that are supported by &GAP;.
##  Note that operations to extract or act on parts of words
##  (letter or syllables) can carry substantially different
##  costs, depending on the representation the words are in.
##  <#/GAPDoc>
##


#############################################################################
##
#A  Length( <w> )
##
##  <#GAPDoc Label="Length:wordass">
##  <ManSection>
##  <Attr Name="Length" Arg='w' Label="for an associative word"/>
##
##  <Description>
##  <Index Subkey="of a word">length</Index>
##  For an associative word <A>w</A>,
##  <Ref Attr="Length" Label="for an associative word"/> returns
##  the number of letters in <A>w</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> f := FreeGroup("a","b");; gens := GeneratorsOfGroup(f);;
##  gap> a := gens[1];; b := gens[2];;w := a^5*b*a^2*b^-4*a;;
##  gap>  w; Length( w );  Length( a^17 );  Length( w^0 );
##  a^5*b*a^2*b^-4*a
##  13
##  17
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Length", IsAssocWord );


#############################################################################
##
#O  Subword( <w>, <from>, <to> )
##
##  <#GAPDoc Label="Subword">
##  <ManSection>
##  <Oper Name="Subword" Arg='w, from, to'/>
##
##  <Description>
##  For an associative word <A>w</A> and two positive integers <A>from</A>
##  and <A>to</A>,
##  <Ref Oper="Subword"/> returns the subword of <A>w</A> that begins
##  at position <A>from</A> and ends at position <A>to</A>.
##  Indexing is done with origin 1.
##  <Example><![CDATA[
##  gap> w;  Subword( w, 3, 7 );
##  a^5*b*a^2*b^-4*a
##  a^3*b*a
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Subword", [ IsAssocWord, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  PositionWord( <w>, <sub>, <from> )
##
##  <#GAPDoc Label="PositionWord">
##  <ManSection>
##  <Oper Name="PositionWord" Arg='w, sub, from'/>
##
##  <Description>
##  Let <A>w</A> and <A>sub</A> be associative words,
##  and <A>from</A> a positive integer.
##  <Ref Oper="PositionWord"/> returns the position of the first occurrence
##  of <A>sub</A> as a subword of <A>w</A>, starting at position <A>from</A>.
##  If there is no such occurrence, <K>fail</K> is returned.
##  Indexing is done with origin 1.
##  <P/>
##  In other words, <C>PositionWord( <A>w</A>, <A>sub</A>, <A>from</A> )</C>
##  is the smallest integer <M>i</M> larger than or equal to <A>from</A> such
##  that <C>Subword( <A>w</A>, </C><M>i</M><C>,</C>
##  <M>i</M><C>+Length( <A>sub</A> )-1 ) =</C>
##  <A>sub</A>, see&nbsp;<Ref Oper="Subword"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> w;  PositionWord( w, a/b, 1 );
##  a^5*b*a^2*b^-4*a
##  8
##  gap> Subword( w, 8, 9 );
##  a*b^-1
##  gap> PositionWord( w, a^2, 1 );
##  1
##  gap> PositionWord( w, a^2, 2 );
##  2
##  gap> PositionWord( w, a^2, 6 );
##  7
##  gap> PositionWord( w, a^2, 8 );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionWord", [ IsAssocWord, IsAssocWord, IsPosInt ] );


#############################################################################
##
#O  SubstitutedWord( <w>, <from>, <to>, <by> )
#O  SubstitutedWord( <w>, <sub>, <from>, <by> )
##
##  <#GAPDoc Label="SubstitutedWord">
##  <ManSection>
##  <Heading>SubstitutedWord</Heading>
##  <Oper Name="SubstitutedWord" Arg='w, from, to, by'
##   Label="replace an interval by a given word"/>
##  <Oper Name="SubstitutedWord" Arg='w, sub, from, by'
##   Label="replace a subword by a given word"/>
##
##  <Description>
##  Let <A>w</A> be an associative word.
##  <P/>
##  In the first form,
##  <Ref Oper="SubstitutedWord" Label="replace an interval by a given word"/>
##  returns the associative word obtained by replacing the subword of
##  <A>w</A> that begins at position <A>from</A> and ends at position
##  <A>to</A> by the associative word <A>by</A>.
##  <A>from</A> and <A>to</A> must be positive integers,
##  indexing is done with origin 1.
##  In other words,
##  <C>SubstitutedWord( <A>w</A>, <A>from</A>, <A>to</A>, <A>by</A> )</C>
##  is the product of the three words
##  <C>Subword( <A>w</A>, 1, <A>from</A>-1 )</C>, <A>by</A>,
##  and <C>Subword( <A>w</A>, <A>to</A>+1, Length( <A>w</A> ) )</C>,
##  see&nbsp;<Ref Oper="Subword"/>.
##  <P/>
##  In the second form,
##  <Ref Oper="SubstitutedWord" Label="replace a subword by a given word"/>
##  returns the associative word obtained by replacing the first occurrence
##  of the associative word <A>sub</A> of <A>w</A>, starting at position
##  <A>from</A>, by the associative word <A>by</A>;
##  if there is no such occurrence, <K>fail</K> is returned.
##  <Example><![CDATA[
##  gap> w;  SubstitutedWord( w, 3, 7, a^19 );
##  a^5*b*a^2*b^-4*a
##  a^22*b^-4*a
##  gap> SubstitutedWord( w, a, 6, b^7 );
##  a^5*b^8*a*b^-4*a
##  gap> SubstitutedWord( w, a*b, 6, b^7 );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SubstitutedWord",
    [ IsAssocWord, IsPosInt, IsPosInt, IsAssocWord ] );

DeclareOperation( "SubstitutedWord",
    [ IsAssocWord, IsAssocWord, IsPosInt, IsAssocWord ] );


#############################################################################
##
#O  EliminatedWord( <w>, <gen>, <by> )
##
##  <#GAPDoc Label="EliminatedWord">
##  <ManSection>
##  <Oper Name="EliminatedWord" Arg='w, gen, by'/>
##
##  <Description>
##  For an associative word <A>w</A>, a generator <A>gen</A>,
##  and an associative word <A>by</A>, <Ref Oper="EliminatedWord"/> returns
##  the associative word obtained by replacing each occurrence of <A>gen</A>
##  in <A>w</A> by <A>by</A>.
##  <Example><![CDATA[
##  gap> w;  EliminatedWord( w, a, a^2 );  EliminatedWord( w, a, b^-1 );
##  a^5*b*a^2*b^-4*a
##  a^10*b*a^4*b^-4*a^2
##  b^-11
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EliminatedWord",
    [ IsAssocWord, IsAssocWord, IsAssocWord ] );


#############################################################################
##
#O  ExponentSumWord( <w>, <gen> )
##
##  <#GAPDoc Label="ExponentSumWord">
##  <ManSection>
##  <Oper Name="ExponentSumWord" Arg='w, gen'/>
##
##  <Description>
##  For an associative word <A>w</A> and a generator <A>gen</A>,
##  <Ref Oper="ExponentSumWord"/> returns the number of times <A>gen</A>
##  appears in <A>w</A> minus the number of times its inverse appears in
##  <A>w</A>.
##  If both <A>gen</A> and its inverse do not occur in <A>w</A> then <M>0</M>
##  is returned.
##  <A>gen</A> may also be the inverse of a generator.
##  <Example><![CDATA[
##  gap> w;  ExponentSumWord( w, a );  ExponentSumWord( w, b );
##  a^5*b*a^2*b^-4*a
##  8
##  -3
##  gap> ExponentSumWord( (a*b*a^-1)^3, a );  ExponentSumWord( w, b^-1 );
##  0
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentSumWord", [ IsAssocWord, IsAssocWord ] );


#############################################################################
##
##  4. Operations for Associative Words by their Syllables
##  <#GAPDoc Label="[5]{wordass}">
##  For an associative word
##  <A>w</A> <M>= x_1^{{n_1}} x_2^{{n_2}} \cdots x_k^{{n_k}}</M>
##  over an alphabet containing <M>x_1, x_2, \ldots, x_k</M>,
##  such that <M>x_i \neq x_{{i+1}}^{{\pm 1}}</M> for
##  <M>1 \leq i \leq k-1</M>,
##  the subwords <M>x_i^{{e_i}}</M> are uniquely determined;
##  these powers of generators are called the <E>syllables</E> of <M>w</M>.
##  <#/GAPDoc>
##


#############################################################################
##
#A  NumberSyllables( <w> )
##
##  <#GAPDoc Label="NumberSyllables">
##  <ManSection>
##  <Attr Name="NumberSyllables" Arg='w'/>
##
##  <Description>
##  <Ref Attr="NumberSyllables"/> returns the number of syllables of the
##  associative word <A>w</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NumberSyllables", IsAssocWord );
DeclareSynonymAttr( "NrSyllables", NumberSyllables );


#############################################################################
##
#O  ExponentSyllable( <w>, <i> )
##
##  <#GAPDoc Label="ExponentSyllable">
##  <ManSection>
##  <Oper Name="ExponentSyllable" Arg='w, i'/>
##
##  <Description>
##  <Ref Oper="ExponentSyllable"/> returns the exponent of the <A>i</A>-th
##  syllable of the associative word <A>w</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExponentSyllable", [ IsAssocWord, IsPosInt ] );


#############################################################################
##
#O  GeneratorSyllable( <w>, <i> )
##
##  <#GAPDoc Label="GeneratorSyllable">
##  <ManSection>
##  <Oper Name="GeneratorSyllable" Arg='w, i'/>
##
##  <Description>
##  <Ref Oper="GeneratorSyllable"/> returns the number of the generator that
##  is involved in the <A>i</A>-th syllable of the associative word <A>w</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "GeneratorSyllable", [ IsAssocWord, IsInt ] );


#############################################################################
##
#O  SubSyllables( <w>, <from>, <to> )
##
##  <#GAPDoc Label="SubSyllables">
##  <ManSection>
##  <Oper Name="SubSyllables" Arg='w, from, to'/>
##
##  <Description>
##  <Ref Oper="SubSyllables"/> returns the subword of the associative word
##  <A>w</A> that consists of the syllables from positions <A>from</A> to
##  <A>to</A>, where <A>from</A> and <A>to</A> must be positive integers,
##  and indexing is done with origin 1.
##  <Example><![CDATA[
##  gap> w;  NumberSyllables( w );
##  a^5*b*a^2*b^-4*a
##  5
##  gap> ExponentSyllable( w, 3 );
##  2
##  gap> GeneratorSyllable( w, 3 );
##  1
##  gap> SubSyllables( w, 2, 3 );
##  b*a^2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SubSyllables", [ IsAssocWord, IsInt, IsInt ] );


#############################################################################
##
##  5. Operations for Associative Words by their Letters


#############################################################################
##
#O  LetterRepAssocWord( <w>[, <gens>] )
##
##  <#GAPDoc Label="LetterRepAssocWord">
##  <ManSection>
##  <Oper Name="LetterRepAssocWord" Arg='w[, gens]'/>
##
##  <Description>
##  The <E>letter representation</E> of an associated word is as a list of
##  integers, each entry corresponding to a group generator. Inverses of the
##  generators are represented by negative numbers. The generator numbers
##  are as associated to the family.
##  <P/>
##  This operation returns the letter representation of the associative word
##  <A>w</A>.
##  <P/>
##  In the call with two arguments, the generator numbers correspond to the
##  generator order given in the list <A>gens</A>.
##  <P/>
##  (For words stored in syllable form the letter representation has to be
##  computed.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LetterRepAssocWord", [ IsAssocWord ] );


#############################################################################
##
#O  AssocWordByLetterRep( <Fam>, <lrep>[, <gens>] )
##
##  <#GAPDoc Label="AssocWordByLetterRep">
##  <ManSection>
##  <Oper Name="AssocWordByLetterRep" Arg='Fam, lrep[, gens]'/>
##
##  <Description>
##  takes a letter representation <A>lrep</A>
##  (see <Ref Oper="LetterRepAssocWord"/>) and returns an associative word in
##  family <A>fam</A> corresponding to this letter representation.
##  <P/>
##  If <A>gens</A> is given, the numbers in the letter
##  representation correspond to <A>gens</A>.
##  <Example><![CDATA[
##  gap> w:=AssocWordByLetterRep( FamilyObj(a), [-1,2,1,-2,-2,-2,1,1,1,1]);
##  a^-1*b*a*b^-3*a^4
##  gap> LetterRepAssocWord( w^2 );
##  [ -1, 2, 1, -2, -2, -2, 1, 1, 1, 2, 1, -2, -2, -2, 1, 1, 1, 1 ]
##  ]]></Example>
##  <P/>
##  The external representation
##  (see section&nbsp;<Ref Sect="The External Representation for Associative Words"/>)
##  can be used if a syllable representation is needed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AssocWordByLetterRep",[IsFamily,IsList] );


#############################################################################
##
#O  SyllableRepAssocWord( <w> )
##
##  <ManSection>
##  <Oper Name="SyllableRepAssocWord" Arg='w'/>
##
##  <Description>
##  returns a word equal to <A>w</A> in syllable representation.
##  This is needed for the use of words for pc groups.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SyllableRepAssocWord", [ IsAssocWord ] );

#############################################################################
##
##  6. External Representation for Associative Words
##  <#GAPDoc Label="[6]{wordass}">
##  The external representation of the associative word <M>w</M> is defined
##  as follows.
##  If
##  <M>w = g_{{i_1}}^{{e_1}} * g_{{i_2}}^{{e_2}} * \cdots * g_{{i_k}}^{{e_k}}</M>
##  is a word over the alphabet <M>g_1, g_2, \ldots</M>,
##  i.e., <M>g_i</M> denotes the <M>i</M>-th generator of the family of
##  <M>w</M>, then <M>w</M> has external representation
##  <M>[ i_1, e_1, i_2, e_2, \ldots, i_k, e_k ]</M>.
##  The empty list describes the identity element (if exists) of the family.
##  Exponents may be negative if the family allows inverses.
##  The external representation of an associative word is guaranteed to be
##  freely reduced;
##  for example,
##  <M>g_1 * g_2 * g_2^{{-1}} * g_1</M> has the external representation
##  <C>[ 1, 2 ]</C>.
##  <P/>
##  Regardless of the family preference for letter or syllable
##  representations
##  (see&nbsp;<Ref Sect="Representations for Associative Words"/>),
##  <C>ExtRepOfObj</C> and <C>ObjByExtRep</C> can be used and interface to
##  this <Q>syllable</Q>-like representation.
##  <P/>
##  <Example><![CDATA[
##  gap> w:= ObjByExtRep( FamilyObj(a), [1,5,2,-7,1,3,2,4,1,-2] );
##  a^5*b^-7*a^3*b^4*a^-2
##  gap> ExtRepOfObj( w^2 );
##  [ 1, 5, 2, -7, 1, 3, 2, 4, 1, 3, 2, -7, 1, 3, 2, 4, 1, -2 ]
##  ]]></Example>
##  <#/GAPDoc>
##


#############################################################################
##
##  7. Some Undocumented Functions
##


#############################################################################
##
#O  ExponentSums( <w>[, <from>, <to>] )
##
##  <ManSection>
##  <Oper Name="ExponentSums" Arg='w[, from, to]'/>
##
##  <Description>
##  returns the exponent sums in <A>w</A>.
##  The three argument version loops over the
##  syllables <A>from</A> to <A>to</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "ExponentSums", [ IsAssocWord ] );


#############################################################################
##
#O  RenumberedWord( <word>, <renumber> )  . . . renumber generators of a word
##
##  <ManSection>
##  <Oper Name="RenumberedWord" Arg='word, renumber'/>
##
##  <Description>
##  accepts an associative word <A>word</A> and a list <A>renumber</A> of
##  positive integers.
##  The result is a new word obtained from <A>word</A> by replacing each
##  occurrence of generator number <M>g</M> by <A>renumber</A><M>[g]</M>.
##  The list <A>renumber</A> need not be dense, but it must have a positive
##  integer for each generator number occurring in <A>word</A>.
##  That integer must not exceed the number of generators in the elements
##  family of <A>word</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "RenumberedWord", [IsAssocWord, IsList] );


#############################################################################
##
#O  AssocWord( <Fam>, <extrep> )  . . . .  construct word from external repr.
#O  AssocWord( <Type>, <extrep> ) . . . .  construct word from external repr.
##
##  <ManSection>
##  <Oper Name="AssocWord" Arg='Fam, extrep'/>
##  <Oper Name="AssocWord" Arg='Type, extrep'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AssocWord" );


#############################################################################
##
#O  ObjByVector( <Fam>, <exponents> )
#O  ObjByVector( <Type>, <exponents> )
##
##  <ManSection>
##  <Oper Name="ObjByVector" Arg='Fam, exponents'/>
##  <Oper Name="ObjByVector" Arg='Type, exponents'/>
##
##  <Description>
##  is the associative word in the family <A>Fam</A> that has
##  exponents vector <A>exponents</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ObjByVector" );


#############################################################################
##
#F  StoreInfoFreeMagma( <F>, <names>, <req> )
##
##  <ManSection>
##  <Func Name="StoreInfoFreeMagma" Arg='F, names, req'/>
##
##  <Description>
##  <Ref Func="StoreInfoFreeMagma"/> does the administrative work
##  in the construction of free semigroups, free monoids, and free groups.
##  <P/>
##  <A>F</A> is the family of objects,
##  <A>names</A> is a list of generators names,
##  and <A>req</A> is the required category for the elements, that is,
##  <Ref Func="IsAssocWord"/>, <Ref Func="IsAssocWordWithOne"/>,
##  or <Ref Func="IsAssocWordWithInverse"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "StoreInfoFreeMagma" );


#############################################################################
##
#F  InfiniteListOfNames( <string>[, <initnames>] )
##
##  <ManSection>
##  <Func Name="InfiniteListOfNames" Arg='string[, initnames]'/>
##
##  <Description>
##  If the only argument is a string <A>string</A> then
##  <Ref Func="InfiniteListOfNames"/> returns an infinite list with the
##  string <A>string</A><M>i</M> at position <M>i</M>.
##  If a finite list <A>initnames</A> of length <M>n</M>
##  is given as second argument,
##  the <M>i</M>-th entry of the returned infinite list is equal to
##  <A>initnames</A><C>[</C><M>i</M><C>]</C> if <M>i \leq n</M>,
##  and equal to <A>string</A><M>i</M> if <M>i &gt; n</M>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InfiniteListOfNames" );


#############################################################################
##
#F  InfiniteListOfGenerators( <F>[, <init>] )
##
##  <ManSection>
##  <Func Name="InfiniteListOfGenerators" Arg='F[, init]'/>
##
##  <Description>
##  If the only argument is a family <A>Fam</A> then
##  <Ref Func="InfiniteListOfGenerators"/> returns an infinite list
##  containing at position <M>i</M> the element in <A>Fam</A>
##  obtained as <C>ObjByExtRep( <A>Fam</A>, [ </C><M>i</M><C>, 1 ] )</C>.
##  If a finite list <A>init</A> of length <M>n</M>
##  is given as second argument, the <M>i</M>-th entry of the returned
##  infinite list is equal to
##  <A>init</A><C>[</C><M>i</M><C>]</C> if <M>i \leq n</M>,
##  and equal to <C>ObjByExtRep( <A>Fam</A>, </C><M>i</M><C> )</C>
##  if <M>i &gt; n</M>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InfiniteListOfGenerators" );

#############################################################################
##
#F  ERepAssWorProd( <l>,<r> )
##
##  <ManSection>
##  <Func Name="ERepAssWorProd" Arg='l,r'/>
##
##  <Description>
##  multiplies two associative words in the external representation.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ERepAssWorProd");

#############################################################################
##
#F  ERepAssWorInv( <w> )
##
##  <ManSection>
##  <Func Name="ERepAssWorInv" Arg='w'/>
##
##  <Description>
##  returns the inverse of the associative word <A>w</A> given in external
##  representation.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ERepAssWorInv");
