#############################################################################
##
#W  tietze.gd                  GAP library                     Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##
Revision.tietze_gd :=
    "@(#)$Id$";


#############################################################################
##
##  Some global symbolic constants.
##
TZ_NUMGENS      :=  1;
TZ_NUMRELS      :=  2;
TZ_TOTAL        :=  3;
TZ_GENERATORS   :=  4;
TZ_INVERSES     :=  5;
TZ_RELATORS     :=  6;
TZ_LENGTHS      :=  7;
TZ_FLAGS        :=  8;
TZ_MODIFIED     := 10;
TZ_NUMREDUNDS   := 11;
TZ_STATUS       := 15;
TZ_LENGTHTIETZE := 20;

TZ_FREEGENS     :=  9;
# TZ_ITERATOR     := 12;

TR_TREELENGTH   :=  3;
TR_PRIMARY      :=  4;
TR_TREENUMS     :=  5;
TR_TREEPOINTERS :=  6;
TR_TREELAST     :=  7;


#############################################################################
##
##  Some global variables.
##
PrintRecIndent  := "  ";

TzOptionNames := [ "eliminationsLimit", "expandLimit", "generatorsLimit",
    "lengthLimit", "loopLimit", "printLevel", "saveLimit",
    "searchSimultaneous" ];


#############################################################################
##
#A  TietzeOrigin( <G> )
##
DeclareAttribute( "TietzeOrigin", IsSubgroupFpGroup );


#############################################################################
##
#F  AbstractWordTietzeWord( <word>, <fgens> )
##
##  `AbstractWordTietzeWord'  assumes  <fgens>  to be  a list  of  free group
##  generators and  <word> to be a Tietze word in these generators,  i. e., a
##  list of positive or negative generator numbers.  It converts <word> to an
##  abstract word,
##
DeclareGlobalFunction("AbstractWordTietzeWord");


#############################################################################
##
#F  AddGenerator( <P> )
##
##  extends the given presentation by a new generator.
##
##  Let  <i>  be the smallest positive integer  which has not yet been used
##  as a generator number  and for which no component  `<P>.<i>'  exists so
##  far in the given  presentation  <P>,  say.  `AddGenerator'  defines  a
##  new  abstract generator `"_xi"'  and adds it, as component `<P>.<i>', to
##  the given presentation.
##
DeclareGlobalFunction("AddGenerator");


#############################################################################
##
#F  AddRelator( <P>, <word> )
##
##  adds the given  relator <word>  to the given  Tietze presentation
##  <P>, probably changing the group defined by <P>.
##
DeclareGlobalFunction("AddRelator");


#############################################################################
##
#F  DecodeTree( <P> )
##
##  applies the tree decoding method to a subgroup presentation provided by
##  the  Reduced Reidemeister-Schreier  or by the  Modified Todd-Coxeter
##  method.
##
DeclareGlobalFunction("DecodeTree");


#############################################################################
##
#F  FpGroupPresentation( <P> )
##
##  constructs an `FpGroup' group as defined by the  given Tietze
##  presentation <P>.
##
DeclareGlobalFunction("FpGroupPresentation");


#############################################################################
##
#M  PresentationFpGroup( <G> [,<printlevel>] ) . . .  create a presentation
##
##  creates a presentation, i.e. a  Tietze object, for the given finitely
##  presented group <G>.
##
##  The  optional <printlevel> parameter can be used to restrict or to
##  extend the amount  of  output provided by  Tietze  transformation
##  commands when being applied to the created presentation.  The
##  default value 1 is designed  for  interactive  use  and  implies
##  explicit  messages  to  be displayed  by most of  these  commands. A
##  <printlevel> value of  0 will suppress these messages, whereas a
##  <printlevel>  value of 2  will enforce some additional output.
##
DeclareGlobalFunction("PresentationFpGroup");


#############################################################################
##
#F  PresentationViaCosetTable(<G>)
#F  PresentationViaCosetTable(<G>,<F>,<words>)
##
##  `PresentationViaCosetTable'   constructs   a  presentation  for  a  given
##  concrete  group.  It applies the relations finding algorithm
##  which has been described in \cite{Can73} and \cite{Neu82}
##
##  If only a group  <G>  has been  specified,  the single stage algorithm is
##  applied.
##
##  If the  two stage algorithm  is to  be used,  `PresentationViaCosetTable'
##  expects a subgroup <H> of <G> to be described by two additional arguments
##  <F>  and  <words>,  where  <F>  is a  free group  with the same number of
##  generators as  <G>,  and  <words> is a list of words in the generators of
##  <F>  which supply  a list of generators of  <H>  if they are evaluated as
##  words in the corresponding generators of <G>.
##
##  Before it is returned, the resulting presentation is being simplified by
##  appropriate calls of the function `SimplifyPresentation' (see "Tietze
##  Transformations"), but   without  allowing  it  to eliminate  any
##  generators. This restriction guarantees that we get a bijection between
##  the list of generators of <G> and  the list of generators in the
##  presentation. Hence, if the generators of <G> are redundant and if you
##  do not care for the bijection, it may be convenient to apply the function
##  `SimplifyPresentation' again.
DeclareGlobalFunction("PresentationViaCosetTable");


#############################################################################
##
#F  RelsViaCosetTable(<G>,<cosets>,<F>)
#F  RelsViaCosetTable(<G>,<cosets>,<F>,<ggens>)
#F  RelsViaCosetTable(<G>,<cosets>,<F>,<words>,<H>,<R1>)
##
##  constructs a defining set of relators  for the given
##  concrete group using the algorithm
##  which has been described in \cite{Can73} and \cite{Neu82}.
##
##  It is a  subroutine  of function  `PresentationViaCosetTable'.  Hence its
##  input and output are specifically designed only for this purpose,  and it
##  does not check the arguments.
##
DeclareGlobalFunction("RelsViaCosetTable");


#############################################################################
##
#F  RemoveRelator( <P>, <n> )
##
##  removes   the  <n>-th  relator   from  the  given   Tietze
##  presentation <P>, probably changing the group defined by <P>.
##
DeclareGlobalFunction("RemoveRelator");


#############################################################################
##
#F  SimplifiedFpGroup( <G> )
##
##  applies Tietze transformations to a copy of the presentation of the
##  given finitely presented group <G> in order to reduce it with respect to
##  the number of generators, the number of relators, and the relator
##  lengths.
##
##  `SimplifiedFpGroup' returns a group  isomorphic to the given one  with a
##  presentation which has been tried to simplify via Tietze
##  transformations.
##
DeclareGlobalFunction("SimplifiedFpGroup");


#############################################################################
##
#F  TietzeWordAbstractWord( <word>, <fgens> )
##
##  `TietzeWordAbstractWord'  assumes  <fgens>  to be a  list  of  free group
##  generators  and  <word>  to be an abstract word  in these generators.  It
##  converts <word> into a Tietze word, i. e., a list of positive or negative
##  generator numbers.
##
DeclareGlobalFunction("TietzeWordAbstractWord");


############################################################################
##
#F  TzCheckRecord
##
DeclareGlobalFunction("TzCheckRecord");


#############################################################################
##
#F  TzEliminate( <P> )
#F  TzEliminate( <P>, <gen> )
#F  TzEliminate( <P>, <n> )
##
##  `TzEliminate' tries to eliminate a generator from a presentation <P> via
##  Tietze transformations.
##  
##  Any relator which contains some generator just once can be used to
##  substitute that generator by a word in the remaining generators. If such
##  generators and relators exist, then `TzEliminate' chooses a generator
##  for which the product of its number of occurrences and the length of the
##  substituting word is minimal, and then it eliminates this generator from
##  the presentation, provided that the resulting total length of the
##  relators does  not exceed the associated Tietze option  parameter
##  `<P>.spaceLimit'.  The default value of `<P>.spaceLimit' is `infinity',
##  but you may alter it appropriately (see "Tietze Options" below).
##
##  If a generator has been specified,  then  `TzEliminate'  eliminates it
##  if possible, i. e. if it can be isolated in some appropriate relator.
##  If no generator  has  been  specified ,   then  `TzEliminate' eliminates
##  some appropriate  generator  if possible  and if the resulting total
##  length of the relators will not exceed the parameter `<P>.lengthLimit'.
##
DeclareGlobalFunction("TzEliminate");


#############################################################################
##
#F  TzEliminateFromTree( <P> )
##
##  `TzEliminateFromTree'  eliminates  the  last  Tietze  generator.  If that
##  generator cannot be isolated in any Tietze relator,  then its definition
##  is  taken  from  the tree  and added  as an  additional  Tietze  relator,
##  extending  the  set  of  Tietze generators  appropriately,  if necessary.
##  However,  the elimination  will not be  performed  if the resulting total
##  length of the relators  cannot be guaranteed  to not exceed the parameter
##  `<P>.lengthLimit'.
##
DeclareGlobalFunction("TzEliminateFromTree");


#############################################################################
##
#F  TzEliminateGen( <P>, <n> )
##
##  eliminates the Tietze generator `<P>.tietze[TZ_GENERATORS][n]'
##  if possible, i. e. if that generator can be isolated  in some appropriate
##  Tietze relator.  However,  the elimination  will not be  performed if the
##  resulting total length of the relators cannot be guaranteed to not exceed
##  the parameter `<P>.lengthLimit'
##
DeclareGlobalFunction("TzEliminateGen");


#############################################################################
##
#F  TzEliminateGen1( <P> )
##
##  tries to  eliminate a  Tietze generator:  If there are
##  Tietze generators which occur just once in certain Tietze relators,  then
##  one of them is chosen  for which the product of the length of its minimal
##  defining word  and the  number of its  occurrences  is minimal.  However,
##  the elimination  will not be performed  if the resulting  total length of
##  the  relators   cannot  be  guaranteed   to  not  exceed   the  parameter
##  `<P>.lengthLimit'.
##
DeclareGlobalFunction("TzEliminateGen1");


#############################################################################
##
#F  TzEliminateGens( <P> [, <decode>] )
##
##  `TzEliminateGens'  repeatedly eliminates generators from the presentation
##  of the given group until at least one  of  the  following  conditions  is
##  violated:
##
##  \beginitems
##  (1)&The  current  number of  generators  is not greater  than  the
##  parameter `<P>.generatorsLimit'.
##
##  (2)&The   number   of   generators   eliminated   so  far  is  less  than
##      the parameter `<P>.eliminationsLimit'.
##
##  (3)&The  total length of the relators  has not yet grown  to a percentage
##      greater than the parameter `<P>.expandLimit'.
##
##  (4)&The  next  elimination  will  not  extend the total length to a value
##      greater than the parameter `<P>.lengthLimit'.
##  \enditems
##
##  If a  second argument  has been  specified,  then it is  assumed  that we
##  are in the process of decoding a tree.
##
##  If not, then the function will not eliminate any protected generators.
##
DeclareGlobalFunction("TzEliminateGens");


#############################################################################
##
#F  TzFindCyclicJoins( <P> )
##
##  `TzFindCyclicJoins'  searches for  power and commutator relators in order
##  to find  pairs of generators  which  generate a  common  cyclic subgroup.
##  It uses these pairs to introduce new relators,  but it does not introduce
##  any new generators as is done by `TzSubstituteCyclicJoins'.
##
##  More precisely: `TzFindCyclicJoins' searches for pairs of generators $a$
##  and $b$ such that (possibly after inverting or conjugating some
##  relators) the set of relators contains the commutator $[a,b]$, a power
##  $a^n$, and a product of the form $a^s b^t$ with $s$ prime to $n$. For
##  each such pair, `TzFindCyclicJoins' uses the Euclidian algorithm to
##  express $a$ as a power of $b$, and then it eliminates $a$.
DeclareGlobalFunction("TzFindCyclicJoins");


############################################################################
##
#F  TzGeneratorExponents(<P>)
##
##  `TzGeneratorExponents'  tries to find exponents for the Tietze generators
##  and return them in a list parallel to the list of the generators.
DeclareGlobalFunction("TzGeneratorExponents");


#############################################################################
##
#F  TzGo( <P> [, <silent>] )
##
##  `TzGo'  automatically  performs  suitable  Tietze transformations  of
##  the presentation in the given presentation.  It is perhaps the most
##  convenient of the interactive Tietze transformation commands. It offers
##  a kind of default strategy which, in general, saves you from explicitly
##  calling the lower-level commands it involves.
##
##  If <silent> is specified as true, then the printing of the status line
##  by `TzGo' in case of `TzOptions(<P>).printLevel = 1' is suppressed.
##
DeclareGlobalFunction("TzGo");

############################################################################
##
#F  SimplifyPresentation(<P>)
##
##  is a synonym for `TzGo'.
SimplifyPresentation := TzGo;


############################################################################
##
#F  TzGoGo(<P>)
##
##  `TzGoGo'  calls  the `TzGo' command  again  and again  until it  does not
##  reduce the presentation any more.  `TzGo' automatically performs suitable
##  Tietze  transformations  of the presentation  in the given presentation.
DeclareGlobalFunction("TzGoGo");


#############################################################################
##
#F  TzHandleLength1Or2Relators( <P> )
##
##  `TzHandleLength1Or2Relators'  searches for  relators of length 1 or 2 and
##  performs suitable Tietze transformations for each of them:
##
##  Generators occurring in relators of length 1 are eliminated.
##
##  Generators  occurring  in square relators  of length 2  are marked  to be
##  involutions.
##
##  If a relator  of length 2  involves two  different  generators,  then the
##  generator with the  larger number is substituted  by the other one in all
##  relators and finally eliminated from the set of generators.
##
DeclareGlobalFunction("TzHandleLength1Or2Relators");

############################################################################# 
##
#O  GeneratorsOfPresentation(<P>)
##
##  returns a list of free generators that is a `ShallowCopy' of the current
##  generators of the presentation <P>. 
DeclareGlobalFunction("GeneratorsOfPresentation");

#############################################################################
##
#F  TzInitGeneratorImages( <P> )
##
##  `TzInitGeneratorImages'  expects  <P>  to  be  a  presentation.
##  It defines the current generators to be the ``old'' generators
##  `OldGeneratorsOfPresentation' and
##  initializes the (pre)image tracing. See `TzImagesOldGens' and
##  `TzPreImagesNewGens' for details.
##
##  You can reinitialize the tracing of the generator images at any later
##  state by just calling the function `TzInitGeneratorImages' again.
##
##  Note:  A subsequent call of the  function DecodeTree  will imply that
##  the images and preimages  are deleted  and reinitialized  after decoding
##  the tree.
##
DeclareGlobalFunction("TzInitGeneratorImages");

#############################################################################
##
#F  OldGeneratorsOfPresentation( <P> )
##
##  is a list of generators initialized by `TzInitGeneratorImages'.
DeclareGlobalFunction("OldGeneratorsOfPresentation");

#############################################################################
##
#F  TzImagesOldGens( <P> )
##
##  returns a list <l> of words in `GeneratorsOfPresentation(<P>)' such that
##  the element represented by the <i>-th generator in
##  `OldGeneratorsOfPresentation( <P> )' before applying the tietze
##  transformations equals the element represented by the word `<l>[<i>]'.
DeclareGlobalFunction("TzImagesOldGens");

#############################################################################
##
#F  TzPreImagesNewGens( <P> )
##
##  returns a list <l> of words in `OldGeneratorsOfPresentation(<P>)' such
##  that
##  the element represented by the <i>-th generator in
##  `GeneratorsOfPresentation( <P> )' after applying the tietze
##  transformations equals the element represented by the word `<l>[<i>]'
##  before the tietze transformations were applied.
DeclareGlobalFunction("TzPreImagesNewGens");


#############################################################################
##
#F  TzMostFrequentPairs( <P>, <n> )
##
##  `TzMostFrequentPairs'  returns a list  describing the  n  most frequently
##  occurring relator subwords of the form  `<g1>*<g2>',  where  <g1>  and
##  <g2> are
##  different generators or their inverses.
##
DeclareGlobalFunction("TzMostFrequentPairs");


############################################################################
##
#F  TzNewGenerator
##
DeclareGlobalFunction("TzNewGenerator");


#############################################################################
##
#F  TzPrint( <P> [,<list>] )
##
##  `TzPrint'  prints the current generators and relators of the given
##  presentation
##  in their  internal representation.  The optional  second parameter
##  can be  used  to specify  the numbers  of the  relators  to  be  printed.
##  Default: all relators are printed.
##
##  In contrast to the commands `TzPrintRelators' and `TzPrintPresentation'
##  `TzPrint' does not convert the lists back to the corresponding {\GAP}
##  words.
DeclareGlobalFunction("TzPrint");


#############################################################################
##
#F  TzPrintGeneratorImages( <P> )
##
##  `TzPrintGeneratorImages'  assumes that  <P>  is a presentation for
##  which the generator images and preimages under the Tietze transformations
##  applied to <P> are being traced. It displays the preimages of the current
##  generators as  Tietze words in the old generators,  and the images of the
##  old generators as Tietze words in the the current generators.
##
DeclareGlobalFunction("TzPrintGeneratorImages");


#############################################################################
##
#F  TzPrintGenerators( <P> [,<list>] )
##
##  `TzPrintGenerators'  prints the generators of the given  Tietze presenta-
##  tion together with the  number of their occurrences.  The optional second
##  parameter  can be used to specify  the numbers  of the  generators  to be
##  printed.  Default: all generators are printed.
##
DeclareGlobalFunction("TzPrintGenerators");


#############################################################################
##
#F  TzPrintLengths( <P> )
##
##  `TzPrintLengths'  prints  a list  of all  relator  lengths  of the  given
##  presentation.
##
DeclareGlobalFunction("TzPrintLengths");

############################################################################# 
##
#A  TzOptions(<P>)
##
##  is a record whose components direct the heuristics applied by the tietze
##  transformation functions. 
##
##  You may alter the value of any of
##  these Tietze options by just assigning a new value to the respective
##  record component.
DeclareAttribute("TzOptions",IsPresentation,"mutable");


#############################################################################
##
#F  TzPrintOptions( <P> )
##
##  `TzPrintOptions'  prints the  components of the presentation <P>,
##  suppressing all those components  which are not options of the Tietze
##  transformations routines.
##
DeclareGlobalFunction("TzPrintOptions");


#############################################################################
##
#F  TzPrintPairs( <P> [,<n>] )
##
##  `TzPrintPairs'  prints the n most often occurring relator subwords of
##  the form  `<a>*<b>', where <a> and <b> are  different generators  or
##  their inverses, together with their numbers of occurrences. The default
##  value of <n> is 10.  If n has been specified to be zero, then it is
##  interpreted as `infinity'.
##
DeclareGlobalFunction("TzPrintPairs");


############################################################################
##
#F  TzPrintPresentation(<P>)
##
##  `TzPrintGenerators'  prints the  generators and the  relators of a Tietze
##  presentation.
DeclareGlobalFunction("TzPrintPresentation");


############################################################################
##
#F  TzPrintRelators(<P>[,<list>])
##
##  prints the relators of the given  Tietze presentation <P>.  The optional
##  second parameter <list> can be used to specify the  numbers of the
##  relators to be printed.  Default: all relators are printed.
DeclareGlobalFunction("TzPrintRelators");


#############################################################################
##
#F  TzPrintStatus( <P> [, <norepeat> ] )
##
##  prints the number of generators, the number of relators,
##  and the total length of all relators in the  Tietze  presentation  of the
##  given group.  If  <norepeat>  is specified as `true',  then the printing is
##  suppressed if none of the three values has changed since the last call.
##
DeclareGlobalFunction("TzPrintStatus");


############################################################################
##
#f  TzRecoverFromFile
##
#T DeclareGlobalFunction("TzRecoverFromFile");
#T up to now no function is installed


############################################################################
##
#F  TzRelator(<P>,<word>)
##
##  `TzRelator' assumes <word> to be an abstract word in the group generators
##  associated  to the  given  presentation,  and  converts it  to a  Tietze
##  relator, i.e. a free and cyclically reduced Tietze word.
DeclareGlobalFunction("TzRelator");


############################################################################
##
#F  TzRemoveGenerators(<P>)
##
##  `TzRemoveGenerators'   deletes  the   redundant  Tietze  generators   and
##  renumbers  the non-redundant ones  accordingly.  The redundant generators
##  are  assumed   to  be   marked   in  the   inverses  list   by  an  entry
##  `invs[numgens+1-i] \<> i'.
DeclareGlobalFunction("TzRemoveGenerators");


############################################################################
##
#F  TzSearch(<P>)
##
##  searches for  relator subwords  which in some  relator have a
##  complement of shorter length  and which occur in other relators, too, and
##  uses them to reduce these other relators.
##
##  The idea is to find pairs of relators $r_1$ and $r_2$ of length $l_1$
##  and $l_2$, respectively, such that $l_1 \le l_2$ and $r_1$ and $r_2$
##  coincide (possibly after inverting or conjugating one of them) in some
##  maximal subword $w$, say, of length greater than $l_1/2$, and then to
##  substitute each copy of $w$ in $r_2$ by the inverse complement of $w$ in
##  $r_1$.
##
DeclareGlobalFunction("TzSearch");


############################################################################
##
#F  TzSearchEqual(<P>)
##
##  searches  for  Tietze relator  subwords  which  in  some
##  relator  have a  complement of  equal length  and which  occur  in  other
##  relators, too, and uses them to modify these other relators.
##
##  The idea is to find pairs of relators $r_1$ and $r_2$ of length $l_1$
##  and $l_2$, respectively, such that $l_1$ is even, $l_1 \le l_2$, and
##  $r_1$ and $r_2$ coincide (possibly after inverting or conjugating one of
##  them) in some maximal subword $w$, say, of length at least $l_1/2$. Let
##  $l$ be the length of $w$.  Then, if $l > l_1/2$, the pair is handled as
##  in `TzSearch'. Otherwise, if $l = l_1/2$, then `TzSearchEqual'
##  substitutes each copy of $w$ in $r_2$ by the inverse complement of $w$
##  in $r_1$.
DeclareGlobalFunction("TzSearchEqual");


############################################################################
##
#F  TzSort(<P>)
##
##  sorts the relators list of the given presentation <P> and,
##  in parallel, the search flags list.  Note:  All relators  of length 0 are
##  removed from the list.
##
##  The sorting algorithm used is the same as in the function `Sort'.
##
DeclareGlobalFunction("TzSort");


#############################################################################
##
#F  TzSubstitute( <P>, <word> [, <gen> ] )
#F  TzSubstitute( <P> [, <n> [,<elim> ] ] )
##
##  In the first form `TzSubstitute' expects <P> to be a presentation and
##  <word> to be either an abstract word or a Tietze word in the generators
##  of <P>. It substitutes the given word as a new generator of <P>. This is
##  done as follows: First, `TzSubstitute' creates a new abstract generator,
##  $g$ say, and adds it to the presentation <P>, then it adds a new relator
##  $g^{-1} \cdot<word>$ to <P>. If a string <string> has been specified as
##  third argument, the new generator $g$ will be named by <string>,
##  otherwise it will get a  default name `"_x<i>"' as  described  with the
##  function `AddGenerator' (see "Changing Presentations").
##
##  In its second form, `TzSubstitute' substitutes a squarefree word of
##  length 2 as a new generator and then eliminates a generator from the
##  extended generator list. We will describe this process in more detail
##  below.
##
##  The parameters <n> and <eliminate> are optional.  If you specify
##  arguments for them, then <n> is expected to be a positive integer, and
##  <eliminate> is expected to be 0, 1, or 2. The default values are $n = 1$
##  and $eliminate = 0$.
##
##  `TzSubstitute' first determines the n most frequently occurring  relator
##  subwords  of the form  `<g1> * <g2>', where <g1> and <g2>  are different
##  generators  or  their inverses,  and sorts  them by  decreasing numbers
##  of occurrences.
##
##  Let  `<a>*<b>' be the  last word  in that list,  and let  <i>  be the
##  smallest positive integer for which there is no component `<P>.i' so far
##  in the given presentation T, then `TzSubstitute' adds to the given
##  presentation a new generator `<P>.i'  and a new relator  `<P>.i^-1 * <a>
##  * <b>',  and it  replaces  all occurrences of  `<a>*<b>' in the relators
##  by  `<P>.i'.  Finally,  if <elim> = 1 or <elim> = 2, it eliminates the
##  generator <a> or <b>, respectively.  Otherwise it eliminates some
##  generator  by just calling  subroutine `TzEliminateGen1'.
##
##  The choice of the generators to be eliminated depends on the actual
##  value of the <eliminate> parameter: 
##
##  If <eliminate> is zero, then the generator to be eliminated is chosen as
##  by the `TzEliminate' command. This means that in this case it may well
##  happen that it is the generator `<P>.<i>' just introduced which is now
##  deleted again so that you do not get any remarkable progress in
##  transforming your presentation.  On the other hand, this procedure
##  guaranties that the total length of the relators will not be increased
##  by a call of `TzSubstitute' with $eliminate = 0$.
##
##  Otherwise, if <eliminate> is 1 or 2, then `TzSubstitute' eliminates the
##  respective factor of the substituted word $ab$, i.e., $a$ for
##  <eliminate> = 1 or $b$ for <eliminate>= 2. In this case, it may well
##  happen that the total length of the relators increases, but sometimes
##  such an intermediate extension is the only way to finally reduce a given
##  presentation.
DeclareGlobalFunction("TzSubstitute");


############################################################################
##
#F  TzSubstituteCyclicJoins(<P>)
##
##  tries to find pairs of  commuting generators <a> and <b>, say, such that
##  the exponent of <a> is prime to the exponent of <b>.  For each such
##  pair, their product `<a>*<b>' is substituted as a new generator,  and
##  <a> and <b> are eliminated.
##
DeclareGlobalFunction("TzSubstituteCyclicJoins");


#############################################################################
##
#F  TzSubstituteWord( <P>, <word> )
##
##  `TzSubstituteWord'  expects <P> to be a presentation  and <word> to be a
##  word in the generators of <P>.  It adds a new generator <gen> and a
##  new relator of the form  `<gen>^-1 * <word>' to <P>.
##
##  The second argument <word> may be  either an abstract word  or a Tietze
##  word, i. e., a list of positive or negative generator numbers.
##
##  More precisely: The effect of a call
##
##     `TzSubstituteWord( T, word );'
##
##  is more or less equivalent to that of
##
##  \begintt
##     AddGenerator( T );
##     gen := T.generators[Length( T.generators )];
##     AddRelator( T, gen^-1 * word );
##  \endtt
##
##  The  essential  difference  is,  that  `TzSubstituteWord',  as  a  Tietze
##  transformation of <P>,  saves and updates the lists of generator images and
##  preimages, in case they are being traced under the Tietze transformations
##  applied to <P>,  whereas a call of the function `AddGenerator' (which  does
##  not perform a Tietze transformation)  will delete  these lists  and hence
##  terminate the tracing.
##
DeclareGlobalFunction("TzSubstituteWord");


#############################################################################
##
#F  TzUpdateGeneratorImage( <P>, <n>, <word> )
##
##  `TzUpdateGeneratorImages'  assumes  that it is called  by a function that
##  performs  Tietze transformations  to a presentation <P>  in which
##  images of the old generators  are being traced as Tietze words in the new
##  generators  as well as preimages of the new generators as Tietze words in
##  the old generators.
##
##  If  <n>  is zero,  it assumes that  a new generator defined by the Tietze
##  word <word> has just been added to the presentation.  It converts  <word>
##  from a  Tietze word  in the new generators  to a  Tietze word  in the old
##  generators and adds that word to the list of preimages.
##
##  If  <n>  is greater than zero,  it assumes that the  <n>-th generator has
##  just been eliminated from the presentation.  It updates the images of the
##  old generators  by replacing each occurrence of the  <n>-th  generator by
##  the given Tietze word <word>.
##
##  If <n> is less than zero,  it terminates the tracing of generator images,
##  i. e., it deletes the corresponding components of <P>.
##
##  Note: `TzUpdateGeneratorImages' is considered to be an internal function.
##  Hence it does not check the arguments.
##
DeclareGlobalFunction("TzUpdateGeneratorImages");


#############################################################################
##
#E  tietze.gd  . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here


