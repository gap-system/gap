#############################################################################
##
#W  word.gd                     GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for (nonassociative) words.
##
##  A *nonassociative word* in {\GAP} is a word formed from generators under
##  a nonassociative multiplication.
##
##  There is an external representation of nonassociative words, defined as
##  follows.
##  The $i$-th generator has external representation $i$,
##  the identity (if exists) has external representation $0$,
##  the inverse of the $i$-th generator (if exists) has external
##  representation $-i$.
##  If $v$ and $w$ are nonassociative words with external representations
##  $e_v$ and $e_w$, respectively then the product $v * w$ has external
##  representation $[ e_v, e_w ]$.
##
Revision.word_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsWord( <obj> )
#C  IsWordWithOne( <obj> )
#C  IsWordWithInverse( <obj> )
##
IsWord            := NewCategory( "IsWord", IsMultiplicativeElement );
IsWordWithOne     := IsWord and IsMultiplicativeElementWithOne;
IsWordWithInverse := IsWord and IsMultiplicativeElementWithInverse;


#############################################################################
##
#C  IsWordCollection( <obj> )
##
IsWordCollection            := CategoryCollections( IsWord );


#############################################################################
##
#C  IsNonassocWord( <obj> )
#C  IsNonassocWordWithOne( <obj> )
##
IsNonassocWord            := NewCategory( "IsNonassocWord", IsWord );
IsNonassocWordWithOne     := IsNonassocWord and IsWordWithOne;


#############################################################################
##
#C  IsNonassocWordCollection( <obj> )
#C  IsNonassocWordWithOneCollection( <obj> )
##
IsNonassocWordCollection            := CategoryCollections( IsNonassocWord );

IsNonassocWordWithOneCollection     := CategoryCollections(
    IsNonassocWordWithOne );


IsNonassocWordFamily := CategoryFamily( IsNonassocWord );

IsNonassocWordWithOneFamily := CategoryFamily( IsNonassocWordWithOne );


#############################################################################
##
#C  IsFreeMagma( <obj> )
##
IsFreeMagma := IsNonassocWordCollection and IsMagma;


#############################################################################
##
#A  LengthWord( <w> )
##
##  is the number of letters in the word <w>.
##
LengthWord := NewAttribute( "LengthWord", IsWord );


#############################################################################
##
#O  NonassocWord( <Fam>, <extrep> )   . .  construct word from external repr.
##
NonassocWord := NewOperationArgs( "NonassocWord" );


#############################################################################
##
#O  MappedWord( <w>, <gens>, <imgs> )
##
##  is the new object that is obtained by replacing each occurrence
##  in the word <w> of a generator <gen> in the list <gens>
##  by the corresponding object <img> in the list <imgs>.
##  The lists <gens> and <imgs> must of course have the same length.
##
##  If the images in <imgs> are all words, and some of them are equal to the
##  corresponding generators in <gens>, then those may be omitted.
##
##  Note that for associative words, the special case that the list <gens>
##  and <imgs> have only length 1 is handled more efficiently by
##  'EliminatedWord' (see "EliminatedWord").
##
MappedWord := NewOperation( "MappedWord",
    [ IsWord, IsWordCollection, IsList ] );


#############################################################################
##

#E  word.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
##
