#############################################################################
##
#W  word.gd                     GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareCategory( "IsWord", IsMultiplicativeElement );
DeclareSynonym( "IsWordWithOne", IsWord and IsMultiplicativeElementWithOne );
DeclareSynonym( "IsWordWithInverse",
    IsWord and IsMultiplicativeElementWithInverse );


#############################################################################
##
#C  IsWordCollection( <obj> )
##
DeclareCategoryCollections( "IsWord" );


#############################################################################
##
#C  IsNonassocWord( <obj> )
#C  IsNonassocWordWithOne( <obj> )
##
DeclareCategory( "IsNonassocWord", IsWord );
DeclareSynonym( "IsNonassocWordWithOne", IsNonassocWord and IsWordWithOne );


#############################################################################
##
#C  IsNonassocWordCollection( <obj> )
#C  IsNonassocWordWithOneCollection( <obj> )
##
DeclareCategoryCollections( "IsNonassocWord" );
DeclareCategoryCollections( "IsNonassocWordWithOne" );

DeclareCategoryFamily( "IsNonassocWord" );
DeclareCategoryFamily( "IsNonassocWordWithOne" );


#############################################################################
##
#C  IsFreeMagma( <obj> )
##
##  (Note that we cannot define `IsFreeMagmaWithOne' as
##  `IsNonassocWordWithOneCollection and IsMagma',
##  since then a free magma-with-one would be also a free magma.)
##
DeclareSynonym( "IsFreeMagma", IsNonassocWordCollection and IsMagma );


#############################################################################
##
#O  NonassocWord( <Fam>, <extrep> )   . .  construct word from external repr.
##
DeclareSynonym( "NonassocWord", ObjByExtRep );
#T Note that `InstallGlobalFunction' does not admit to assign an operation.


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
##  `EliminatedWord' (see "EliminatedWord").
##
DeclareOperation( "MappedWord", [ IsWord, IsWordCollection, IsList ] );


#############################################################################
##
#E  word.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
##
