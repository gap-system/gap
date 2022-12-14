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
##  This file declares the categories and operations for words and
##  nonassociative words.
##
##  1. Categories of Words and Nonassociative Words
##  2. Comparison of Words
##  3. Operations for Words
##  4. Free Magmas
##  5. External Representation for Nonassociative Words
##


#############################################################################
##
##  <#GAPDoc Label="[1]{word}">
##  This chapter describes categories of <E>words</E> and
##  <E>nonassociative words</E>, and operations for them.
##  For information about <E>associative words</E>,
##  which occur for example as elements in free groups,
##  see Chapter&nbsp;<Ref Chap="Associative Words"/>.
##  <#/GAPDoc>
##


#############################################################################
##
##  1. Categories of Words and Nonassociative Words
##


#############################################################################
##
#C  IsWord( <obj> )
#C  IsWordWithOne( <obj> )
#C  IsWordWithInverse( <obj> )
##
##  <#GAPDoc Label="IsWord">
##  <ManSection>
##  <Filt Name="IsWord" Arg='obj' Type='Category'/>
##  <Filt Name="IsWordWithOne" Arg='obj' Type='Category'/>
##  <Filt Name="IsWordWithInverse" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Index>abstract word</Index>
##  Given a free multiplicative structure <M>M</M> that is freely generated
##  by a subset <M>X</M>,
##  any expression of an element in <M>M</M> as an iterated product of
##  elements in <M>X</M> is called a <E>word</E> over <M>X</M>.
##  <P/>
##  Interesting cases of free multiplicative structures are those of
##  free semigroups, free monoids, and free groups,
##  where the multiplication is associative
##  (see&nbsp;<Ref Prop="IsAssociative"/>),
##  which are described in Chapter&nbsp;<Ref Chap="Associative Words"/>,
##  and also the case of free magmas,
##  where the multiplication is nonassociative
##  (see&nbsp;<Ref Filt="IsNonassocWord"/>).
##  <P/>
##  Elements in free magmas
##  (see&nbsp;<Ref Func="FreeMagma" Label="for given rank"/>)
##  lie in the category <Ref Filt="IsWord"/>;
##  similarly, elements in free magmas-with-one
##  (see&nbsp;<Ref Func="FreeMagmaWithOne" Label="for given rank"/>)
##  lie in the category <Ref Filt="IsWordWithOne"/>, and so on.
##  <P/>
##  <Ref Filt="IsWord"/> is mainly a <Q>common roof</Q> for the two
##  <E>disjoint</E> categories
##  <Ref Filt="IsAssocWord"/> and <Ref Filt="IsNonassocWord"/>
##  of associative and nonassociative words.
##  This means that associative words are <E>not</E> regarded as special
##  cases of nonassociative words.
##  The main reason for this setup is that we are interested in different
##  external representations for associative and nonassociative words
##  (see&nbsp;<Ref Sect="External Representation for Nonassociative Words"/>
##  and <Ref Sect="The External Representation for Associative Words"/>).
##  <P/>
##  Note that elements in finitely presented groups and also elements in
##  polycyclic groups in &GAP; are <E>not</E> in <Ref Filt="IsWord"/>
##  although they are usually called words,
##  see Chapters&nbsp;<Ref Chap="Finitely Presented Groups"/>
##  and&nbsp;<Ref Chap="Pc Groups"/>.
##  <P/>
##  Words are <E>constants</E>
##  (see&nbsp;<Ref Sect="Mutability and Copyability"/>),
##  that is, they are not copyable and not mutable.
##  <P/>
##  The usual way to create words is to form them as products of known words,
##  starting from <E>generators</E> of a free structure such as a free magma
##  or a free group (see&nbsp;<Ref Func="FreeMagma" Label="for given rank"/>,
##  <Ref Func="FreeGroup" Label="for given rank"/>).
##  <P/>
##  Words are also used to implement free algebras,
##  in the same way as group elements are used to implement group algebras
##  (see&nbsp;<Ref Sect="Constructing Algebras as Free Algebras"/>
##  and Chapter&nbsp;<Ref Chap="Magma Rings"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> m:= FreeMagmaWithOne( 2 );;  gens:= GeneratorsOfMagmaWithOne( m );
##  [ x1, x2 ]
##  gap> w1:= gens[1] * gens[2] * gens[1];
##  ((x1*x2)*x1)
##  gap> w2:= gens[1] * ( gens[2] * gens[1] );
##  (x1*(x2*x1))
##  gap> w1 = w2;  IsAssociative( m );
##  false
##  false
##  gap> IsWord( w1 );  IsAssocWord( w1 );  IsNonassocWord( w1 );
##  true
##  false
##  true
##  gap> s:= FreeMonoid( 2 );;  gens:= GeneratorsOfMagmaWithOne( s );
##  [ m1, m2 ]
##  gap> u1:= ( gens[1] * gens[2] ) * gens[1];
##  m1*m2*m1
##  gap> u2:= gens[1] * ( gens[2] * gens[1] );
##  m1*m2*m1
##  gap> u1 = u2;  IsAssociative( s );
##  true
##  true
##  gap> IsWord( u1 );  IsAssocWord( u1 );  IsNonassocWord( u1 );
##  true
##  true
##  false
##  gap> a:= (1,2,3);;  b:= (1,2);;
##  gap> w:= a*b*a;;  IsWord( w );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsWord", IsMultiplicativeElement );
DeclareSynonym( "IsWordWithOne", IsWord and IsMultiplicativeElementWithOne );
DeclareSynonym( "IsWordWithInverse",
    IsWord and IsMultiplicativeElementWithInverse );


#############################################################################
##
#C  IsWordCollection( <obj> )
##
##  <#GAPDoc Label="IsWordCollection">
##  <ManSection>
##  <Filt Name="IsWordCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsWordCollection"/> is the collections category
##  (see&nbsp;<Ref Func="CategoryCollections"/>) of <Ref Filt="IsWord"/>.
##  <Example><![CDATA[
##  gap> IsWordCollection( m );  IsWordCollection( s );
##  true
##  true
##  gap> IsWordCollection( [ "a", "b" ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryCollections( "IsWord" );


#############################################################################
##
#C  IsNonassocWord( <obj> )
#C  IsNonassocWordWithOne( <obj> )
##
##  <#GAPDoc Label="IsNonassocWord">
##  <ManSection>
##  <Filt Name="IsNonassocWord" Arg='obj' Type='Category'/>
##  <Filt Name="IsNonassocWordWithOne" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>nonassociative word</E> in &GAP; is an element in a free magma or
##  a free magma-with-one (see&nbsp;<Ref Sect="Free Magmas"/>).
##  <P/>
##  The default methods for <Ref Oper="ViewObj"/> and <Ref Oper="PrintObj"/>
##  show nonassociative words as products of letters,
##  where the succession of multiplications is determined by round brackets.
##  <P/>
##  In this sense each nonassociative word describes a <Q>program</Q> to
##  form a product of generators.
##  (Also associative words can be interpreted as such programs,
##  except that the exact succession of multiplications is not prescribed
##  due to the associativity.)
##  The function <Ref Oper="MappedWord"/> implements a way to
##  apply such a program.
##  A more general way is provided by straight line programs
##  (see&nbsp;<Ref Sect="Straight Line Programs"/>).
##  <P/>
##  Note that associative words
##  (see Chapter&nbsp;<Ref Chap="Associative Words"/>)
##  are <E>not</E> regarded as special cases of nonassociative words
##  (see&nbsp;<Ref Filt="IsWord"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsNonassocWord", IsWord );
DeclareSynonym( "IsNonassocWordWithOne", IsNonassocWord and IsWordWithOne );


#############################################################################
##
#C  IsNonassocWordCollection( <obj> )
#C  IsNonassocWordWithOneCollection( <obj> )
##
##  <#GAPDoc Label="IsNonassocWordCollection">
##  <ManSection>
##  <Filt Name="IsNonassocWordCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsNonassocWordWithOneCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsNonassocWordCollection"/> is the collections category
##  (see&nbsp;<Ref Func="CategoryCollections"/>) of
##  <Ref Filt="IsNonassocWord"/>,
##  and <Ref Filt="IsNonassocWordWithOneCollection"/> is the collections
##  category of <Ref Filt="IsNonassocWordWithOne"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryCollections( "IsNonassocWord" );
DeclareCategoryCollections( "IsNonassocWordWithOne" );


#############################################################################
##
#C  IsNonassocWordFamily( <obj> )
#C  IsNonassocWordWithOneFamily( <obj> )
##
##  <ManSection>
##  <Filt Name="IsNonassocWordFamily" Arg='obj' Type='Category'/>
##  <Filt Name="IsNonassocWordWithOneFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryFamily( "IsNonassocWord" );
DeclareCategoryFamily( "IsNonassocWordWithOne" );


#############################################################################
##
##  2. Comparison of Words
##
##  <#GAPDoc Label="[2]{word}">
##  <ManSection>
##  <Oper Name="\=" Label="for nonassociative words" Arg='w1, w2'/>
##
##  <Description>
##  <Index Subkey="nonassociative words">equality</Index>
##  <P/>
##  Two words are equal if and only if they are words over the same alphabet
##  and with equal external representations
##  (see&nbsp;<Ref Sect="External Representation for Nonassociative Words"/>
##  and <Ref Sect="The External Representation for Associative Words"/>).
##  For nonassociative words, the latter means that the words arise from the
##  letters of the alphabet by the same sequence of multiplications.
##  </Description>
##  </ManSection>
##
##  <ManSection>
##  <Oper Name="\&lt;" Label="for nonassociative words" Arg='w1, w2'/>
##
##  <Description>
##  <Index Subkey="nonassociative words">smaller</Index>
##  Words are ordered according to their external representation.
##  More precisely, two words can be compared if they are words over the same
##  alphabet, and the word with smaller external representation is smaller.
##  For nonassociative words, the ordering is defined
##  in&nbsp;<Ref Sect="External Representation for Nonassociative Words"/>;
##  associative words are ordered by the shortlex ordering via <C>&lt;</C>
##  (see&nbsp;<Ref Sect="The External Representation for Associative Words"/>).
##  <P/>
##  Note that the alphabet of a word is determined by its family
##  (see&nbsp;<Ref Sect="Families"/>),
##  and that the result of each call to
##  <Ref Func="FreeMagma" Label="for given rank"/>,
##  <Ref Func="FreeGroup" Label="for given rank"/> etc. consists of words
##  over a new alphabet.
##  In particular, there is no <Q>universal</Q> empty word,
##  every families of words in <Ref Filt="IsWordWithOne"/> has its own
##  empty word.
##  <P/>
##  <Example><![CDATA[
##  gap> m:= FreeMagma( "a", "b" );;
##  gap> x:= FreeMagma( "a", "b" );;
##  gap> mgens:= GeneratorsOfMagma( m );
##  [ a, b ]
##  gap> xgens:= GeneratorsOfMagma( x );
##  [ a, b ]
##  gap> a:= mgens[1];;  b:= mgens[2];;
##  gap> a = xgens[1];
##  false
##  gap> a*(a*a) = (a*a)*a;  a*b = b*a;  a*a = a*a;
##  false
##  false
##  true
##  gap> a < b;  b < a;  a < a*b;
##  true
##  false
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
##  3. Operations for Words
##  <#GAPDoc Label="[3]{word}">
##  Two words can be multiplied via <C>*</C> only if they are words over the
##  same alphabet (see&nbsp;<Ref Sect="Comparison of Words"/>).
##  <#/GAPDoc>
##


#############################################################################
##
#O  MappedWord( <w>, <gens>, <imgs> )
##
##  <#GAPDoc Label="MappedWord">
##  <ManSection>
##  <Oper Name="MappedWord" Arg='w, gens, imgs'/>
##
##  <Description>
##  <Ref Oper="MappedWord"/> returns the object that is obtained by replacing
##  each occurrence in the word <A>w</A> of a generator in the list
##  <A>gens</A> by the corresponding object in the list <A>imgs</A>.
##  The lists <A>gens</A> and <A>imgs</A> must of course have the same length.
##  <P/>
##  <Ref Oper="MappedWord"/> needs to do some preprocessing to get internal
##  generator numbers etc. When mapping many (several thousand) words, a
##  dedicated loop might be faster.
##  <P/>
##  For example, if the elements in <A>imgs</A> are all
##  <E>associative words</E>
##  (see Chapter&nbsp;<Ref Chap="Associative Words"/>)
##  in the same family as the elements in <A>gens</A>,
##  and some of them are equal to the corresponding generators in <A>gens</A>,
##  then those may be omitted from <A>gens</A> and <A>imgs</A>.
##  In this situation, the special case that the lists <A>gens</A>
##  and <A>imgs</A> have only length <M>1</M> is handled more efficiently by
##  <Ref Oper="EliminatedWord"/>.
##  <P/>
##  If the word is from a free group, it is permitted to give inverses of
##  (some) of the generators as extra generators. This can speed up the
##  execution by removing the need to calculate inverses anew.
##  <Example><![CDATA[
##  gap> m:= FreeMagma( "a", "b" );;  gens:= GeneratorsOfMagma( m );;
##  gap> a:= gens[1];  b:= gens[2];
##  a
##  b
##  gap> w:= (a*b)*((b*a)*a)*b;
##  (((a*b)*((b*a)*a))*b)
##  gap> MappedWord( w, gens, [ (1,2), (1,2,3,4) ] );
##  (2,4,3)
##  gap> a:= (1,2);; b:= (1,2,3,4);;  (a*b)*((b*a)*a)*b;
##  (2,4,3)
##  gap> f:= FreeGroup( "a", "b" );;
##  gap> a:= GeneratorsOfGroup(f)[1];;  b:= GeneratorsOfGroup(f)[2];;
##  gap> w:= a^5*b*a^2/b^4*a;
##  a^5*b*a^2*b^-4*a
##  gap> MappedWord( w, [ a, b ], [ (1,2), (1,2,3,4) ] );
##  (1,3,4,2)
##  gap> MappedWord( w, [ a, b, b^-1 ], [ (1,2), (1,2,3,4), (1,4,3,2) ] );
##  (1,3,4,2)
##  gap> (1,2)^5*(1,2,3,4)*(1,2)^2/(1,2,3,4)^4*(1,2);
##  (1,3,4,2)
##  gap> MappedWord( w, [ a ], [ a^2 ] );
##  a^10*b*a^4*b^-4*a^2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MappedWord", [ IsWord, IsWordCollection, IsList ] );


#############################################################################
##
##  4. Free Magmas
##  <#GAPDoc Label="[4]{word}">
##  The easiest way to create a family of words is to construct the free
##  object generated by these words.
##  Each such free object defines a unique alphabet,
##  and its generators are simply the words of length one over this alphabet;
##  These generators can be accessed via <Ref Attr="GeneratorsOfMagma"/> in
##  the case of a free magma,
##  and via <Ref Attr="GeneratorsOfMagmaWithOne"/> in the case of a free
##  magma-with-one.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsFreeMagma( <obj> )
##
##  <ManSection>
##  <Filt Name="IsFreeMagma" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Func="IsFreeMagma"/> is just a synonym for
##  <C>IsNonassocWordCollection and IsMagma</C>,
##  that is, any magma (see&nbsp;<Ref Func="IsMagma"/>) consisting of
##  nonassociative words (see&nbsp;<Ref Func="IsNonassocWord"/>) is in this
##  category.
##  </Description>
##  </ManSection>
##
DeclareSynonym( "IsFreeMagma", IsNonassocWordCollection and IsMagma );


#############################################################################
##
##  5. External Representation for Nonassociative Words
##  <#GAPDoc Label="[5]{word}">
##  The external representation of nonassociative words is defined
##  as follows.
##  The <M>i</M>-th generator of the family of elements in question has
##  external representation <M>i</M>,
##  the identity (if exists) has external representation <M>0</M>,
##  the inverse of the <M>i</M>-th generator (if exists) has external
##  representation <M>-i</M>.
##  If <M>v</M> and <M>w</M> are nonassociative words with external
##  representations <M>e_v</M> and <M>e_w</M>,
##  respectively then the product <M>v * w</M> has external
##  representation <M>[ e_v, e_w ]</M>.
##  So the external representation of any nonassociative word is either an
##  integer or a nested list of integers and lists, where each list has
##  length two.
##  <P/>
##  One can create a nonassociative word from a family of words and the
##  external representation of a nonassociative word using
##  <Ref Oper="ObjByExtRep"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> m:= FreeMagma( 2 );;  gens:= GeneratorsOfMagma( m );
##  [ x1, x2 ]
##  gap> w:= ( gens[1] * gens[2] ) * gens[1];
##  ((x1*x2)*x1)
##  gap> ExtRepOfObj( w );  ExtRepOfObj( gens[1] );
##  [ [ 1, 2 ], 1 ]
##  1
##  gap>  ExtRepOfObj( w*w );
##  [ [ [ 1, 2 ], 1 ], [ [ 1, 2 ], 1 ] ]
##  gap> ObjByExtRep( FamilyObj( w ), 2 );
##  x2
##  gap> ObjByExtRep( FamilyObj( w ), [ 1, [ 2, 1 ] ] );
##  (x1*(x2*x1))
##  ]]></Example>
##  <#/GAPDoc>
##


#############################################################################
##
#O  NonassocWord( <Fam>, <extrep> )   . .  construct word from external repr.
##
##  <ManSection>
##  <Oper Name="NonassocWord" Arg='Fam, extrep'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "NonassocWord", ObjByExtRep );
