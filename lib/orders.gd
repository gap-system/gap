#############################################################################
##
#W  orders.gd           GAP library                           Isabel Araujo 
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  These file contains declarations for orderings.
##
Revision.orders_gd :=
    "@(#)$Id$";

#1
##  In {\GAP} an ordering is a relation defined on a family, which is 
##  reflexive, anti-symmetric and transitive.

#############################################################################
##
#C  IsOrdering( <ord>) 
##
##  returns `true' if and only if the object <ord> is an ordering.
##
DeclareCategory( "IsOrdering" ,IsObject);

#############################################################################
##
#A  OrderingsFamily( <fam> )  . . . . . . . . . . make an orderings  family
##
##  for a family <fam>, returns the family of all
##  orderings on elements of <fam>.
##
DeclareAttribute( "OrderingsFamily", IsFamily );


#############################################################################
##
##  General Properties for orderings  
##

#############################################################################
##
#P  IsWellFoundedOrdering( <ord>) 
##
##  for an ordering <ord>,
##  returns `true' if and only if the ordering is well founded.
##  An ordering <ord> is well founded if it admits no infinite descending
##  chains.
##  Normally this property is set at the time of creation of the ordering
##  and there is no general method to check whether a certain ordering
##  is well founded.
##
DeclareProperty( "IsWellFoundedOrdering" ,IsOrdering);

#############################################################################
##
#P  IsTotalOrdering( <ord> )
##
##  for an ordering <ord>,
##  returns true if and only if the ordering is total.
##  An ordering <ord> is total if any two elements of the family 
##  are comparable under <ord>. 
##  Normally this property is set at the time of creation of the ordering
##  and there is no general method to check whether a certain ordering
##  is total.
##
DeclareProperty( "IsTotalOrdering" ,IsOrdering);


#############################################################################
##
##  General attributes and operations 
##

#############################################################################
##
#A  FamilyForOrdering( <ord> )
##  
##  for an ordering <ord>,
##  returns the family of elements that the ordering <ord> compares.
##
DeclareAttribute( "FamilyForOrdering" ,IsOrdering);

#############################################################################
##
#A  LessThanFunction( <ord> )
##
##  for an ordering <ord>, 
##  returns a function <f> which takes two elements <el1>, <el2> in the 
##  `FamilyForOrdering'(<ord>) and returns `true' if <el1> is 
##  strictly less than <el2> (with respect to <ord>) and returns `false' 
##  otherwise.
##
DeclareAttribute( "LessThanFunction" ,IsOrdering);

#############################################################################
##
#A  LessThanOrEqualFunction( <ord> )
##
##  for an ordering <ord>,
##  returns a function that takes two elements <el1>, <el2> in the 
##  `FamilyForOrdering'(<ord>) and returns `true' if <el1> is 
##  less than *or equal to* <el2> (with respect to <ord>) and returns `false' 
##  otherwise.
##
DeclareAttribute( "LessThanOrEqualFunction" ,IsOrdering);

#############################################################################
##
#O  IsLessThanUnder( <ord>, <el1>, <el2> )
##
##  for an ordering <ord> on the elements of the family of <el1> and <el2>,
##  returns `true' if <el1> is (strictly) less than <el2> with
##  respect to <ord>, and `false' otherwise.
##
DeclareOperation( "IsLessThanUnder" ,[IsOrdering,IsObject,IsObject]);

#############################################################################
##
#O  IsLessThanOrEqualUnder( <ord>, <el1>, <el2> )
##
##  for an ordering <ord> on the elements of the family of <el1> and <el2>,
##  returns `true' if <el1> is less than or equal to <el2> with
##  respect to <ord>, and `false' otherwise.
## 
DeclareOperation( "IsLessThanOrEqualUnder" ,[IsOrdering,IsObject,IsObject]);

#############################################################################
##
#O  IsIncomparableUnder( <ord>, <el1>, <el2> )
##
##  for an ordering <ord> on the elements of the family of <el1> and <el2>,
##  returns `true' if $el1\neq el2$ and  `IsLessThanUnder'(<ord>,<el1>,<el2>), 
##  `IsLessThanUnder'(<ord>,<el2>,<el1>) are both false; and
##  returns `false' otherwise.
##
DeclareOperation( "IsIncomparableUnder" ,[IsOrdering,IsObject,IsObject]);

#############################################################################
##
##  Building new orderings
##

#############################################################################
##
#O  OrderingByLessThanFunctionNC( <fam>,<lt> )
#O  OrderingByLessThanFunctionNC( <fam>,<lt>,<l> )
##
##  In the first form, `OrderingByLessThanFunctionNC' returns the ordering on
##  the elements of the  elements  of  the  family  <fam>  according  to  the
##  `LessThanFunction' given by <lt>, where <lt> is a function that takes two
##  arguments in <fam> and returns `true' or `false'.
##
##  In the second form, for a family <fam>, a function <lt> that takes 
##  two arguments in <fam> and returns `true' or `false', and a list <l>
##  of properties of orderings, `OrderingByLessThanFunctionNC'
##  returns the ordering on the elements of <fam> with
##  `LessThanFunction' given by <lt> and with the properties
##  from <l> set to `true'.
##
DeclareOperation( "OrderingByLessThanFunctionNC" ,[IsFamily,IsFunction]);

#############################################################################
##
#O  OrderingByLessThanOrEqualFunctionNC( <fam>,<lteq> )
#O  OrderingByLessThanOrEqualFunctionNC( <fam>,<lteq>,<l> )
##
##  In the  first  form,  `OrderingByLessThanOrEqualFunctionNC'  returns  the
##  ordering on the elements of the elements of the family <fam> according to
##  the `LessThanOrEqualFunction' given by <lteq>, where <lteq> is a function
##  that takes two arguments in <fam> and returns `true' or `false'.
##
##  In the second form, for a family <fam>, a function <lteq> that takes 
##  two arguments in <fam> and returns `true' or `false', and a list <l>
##  of properties of orderings, `OrderingByLessThanOrEqualFunctionNC'
##  returns the ordering on the elements of <fam> with
##  `LessThanOrEqualFunction' given by <lteq> and with the properties
##  from <l> set to `true'.
##
##  Notice that these functions do not check whether <fam> and <lt> or <lteq>
##  are compatible, and whether the properties listed in <l> are indeed
##  true.
##
DeclareOperation( "OrderingByLessThanOrEqualFunctionNC" ,
    [IsFamily,IsFunction]);



############################################################################
##
##  Orderings on families of associative words
##

#2  
##  We now consider orderings on families of associative words.

#3
##  Examples of families of associative words are the families of elements
##  of a free semigroup or a free monoid;
##  these are the two cases that we consider mostly.
##  Associated with those families is
##  an alphabet, which is the semigroup (resp. monoid) generating set
##  of the correspondent free semigroup (resp. free monoid).
##  For definitions of the orderings considered see Sims \cite{Sims94}.

#4
##  The ordering on the letters of the alphabet is important when
##  defining an order in such a family.
##  An alphabet has a default ordering: the generators of a free semigroup
##  or free monoid are indexed on $[1,2,\ldots,n]$, where $n$ is the size of
##  the alphabet. Another ordering on the alphabet will always be given in terms
##  of this one, either in terms of a list of length $n$, where position
##  $i$ ($1\leq i\leq n$) indicates what is the $i$-th generator in the 
##  ordering, or else as a list of the generators, starting from the
##  smallest one.
##

#############################################################################
##
#P  IsOrderingOnFamilyOfAssocWords( <ord>)
##
##  for an ordering <ord>,
##  returns true if <ord> is an ordering over a family of associative
##  words.
##
DeclareProperty("IsOrderingOnFamilyOfAssocWords",IsOrdering);

#############################################################################
##
#A  LetterRepWordsLessFunc( <ord> )
##
##  If <ord> is an ordering for associative words, this attribute (if known)
##  will hold a function which implements a ``less than'' function for words
##  given by a list of letters (see~"LetterRepAssocWord").
##
DeclareAttribute( "LetterRepWordsLessFunc" ,IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#P  IsTranslationInvariantOrdering( <ord> )
##
##  for an ordering <ord> on a family of associative words,
##  returns `true' if and only if the ordering is translation invariant.
##  This is a property of orderings on families of associative words.
##  An ordering <ord> over a family <fam>, with alphabet <X> is
##  translation invariant if
##  `IsLessThanUnder(<ord>, <u>, <v>)' implies that for any $a,b\in X^\*$
##  `IsLessThanUnder(<ord>, $a*u*b, a*v*b$)'.
##
DeclareProperty( "IsTranslationInvariantOrdering" ,IsOrdering and 
                                    IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#P  IsReductionOrdering( <ord> )
##
##  for an ordering <ord> on a family of associative words,
##  returns `true' if and only if the ordering is a reduction ordering.
##  An ordering <ord> is a reduction ordering 
##  if it is founded and translation invariant.
##
DeclareSynonym( "IsReductionOrdering",
    IsTranslationInvariantOrdering and IsWellFoundedOrdering );

#4
##  The ordering on the letters of the alphabet is important when
##  defining an order in a family of associative words.
##  An alphabet has a default ordering: the generators of a free semigroup
##  or free monoid are indexed on $[1,2,\ldots,n]$, where $n$ is the size of
##  the alphabet. Another ordering on the alphabet will always be given in terms
##  of this one, either in terms of a list <gensord> of length $n$, 
##  where position $i$ ($1\leq i\leq n$) indicates what is the $i$-th 
##  generator in the ordering, or else as a list <alphabet> of the generators, 
##  starting from the smallest one.

#############################################################################
##
#A  OrderingOnGenerators( <ord>)
##  
##  for an ordering <ord> on a family of associative words,
##  returns a list <alphabet> in which the generators are considered.
##  This could be indeed the ordering of the generators in the ordering,
##  but, for example, if a weight is associated to each generator
##  then this is not true anymore. See the example for `WeightLexOrdering'
##  ("WeightLexOrdering").
##
DeclareAttribute("OrderingOnGenerators",IsOrdering and
                    IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#O  LexicographicOrdering( <fam> )
#O  LexicographicOrdering( <fam>, <gensord> )
#O  LexicographicOrdering( <fam>, <alphabet> )
#O  LexicographicOrdering( <f> )
#O  LexicographicOrdering( <f>, <alphabet> )
#O  LexicographicOrdering( <f>, <gensord> )
##
##  In the first form, for a family <fam> of associative words,
##  `LexicographicOrdering'
##  returns the lexicographic ordering on the elements of <fam>.
##
##  In the second form, for a family <fam> of associate words and
##  a list <alphabet> which is the actual list of generators in the
##  desired order, `LexicographicOrdering' 
##  returns the lexicographic ordering on the elements of
##  <fam> with the ordering on the alphabet as given.
##
##  In the third form, for a family <fam> of associative words and
##  a list <gensorder> of the length of the alphabet,
##  `LexicographicOrdering' returns the lexicographic 
##  ordering on the elements of <fam> with the order on the alphabet
##  given by <gensord>.
##
##  In the fourth form, for a free semigroup of a free monoid <f>,
##  `LexicographicOrdering'
##  returns the lexicographic ordering on the family of the elements of <f>
##  with the order in the alphabet being the default one.
##
##  In the fifth form, for a free semigroup or a free monoid <f> and
##  a list <alphabet> which is the actual list of generators in the
##  desired order, `LexicographicOrdering'
##  returns the lexicographic ordering on the elements of
##  <f> with the ordering on the alphabet as given.
##
##  In the sixth form, for a free semigroup of a free monoid <f>,
##  and a list <gensorder>, `LexicographicOrdering'
##  returns the lexicographic ordering on the elements of <f> with the order
##  on the alphabet given by <gensord>.
##
DeclareOperation("LexicographicOrdering", [IsFamily and IsAssocWordFamily,
IsList and IsAssocWordCollection]);


#############################################################################
##
#O  ShortLexOrdering( <fam>)
#O  ShortLexOrdering( <fam>, <alphabet> )
#O  ShortLexOrdering( <fam>, <gensord>)
#O  ShortLexOrdering( <f>)
#O  ShortLexOrdering( <f>, <alphabet> )
#O  ShortLexOrdering( <f>, <gensord>)
##
##  In the first form, for a family <fam> of associative words,
##  `ShortLexOrdering'
##  returns the ShortLex ordering on the elements of <fam>
##  with the order in the alphabet being the default one.
##  
##  In the second form, for a family <fam> of associate words and
##  a list <alphabet> which is the actual list of generators in the 
##  desired order, `ShortLexOrdering'
##  returns the ShortLex ordering on the elements of
##  <fam> with the ordering on the alphabet as given.
##
##  In the third form, for a family <fam> of associative words and
##  a list <gensorder> of the length of the alphabet,
##  `ShortLexOrdering' returns the ShortLex
##  ordering on the elements of <fam> with the order on the alphabet
##  given by <gensord>. 
##
##  In the fourth form, for a free semigroup of a free monoid <f>,
##  `ShortLexOrdering'
##  returns the ShortLex ordering on the family of the elements of <f> 
##  with the order in the alphabet being the default one.
##
##  In the fifth form, for a free semigroup or a free monoid <f> and
##  a list <alphabet> which is the actual list of generators in the 
##  desired order, `ShortLexOrdering'
##  returns the ShortLex ordering on the elements of
##  <f> with the ordering on the alphabet as given.
##
##  In the sixth form, for a free semigroup of a free monoid <f>,
##  and a list <gensorder>, `ShortLexOrdering' 
##  returns the ShortLex ordering on the elements of <f> with the order 
##  on the alphabet given by <gensord>.
##
DeclareOperation("ShortLexOrdering",[IsFamily and IsAssocWordFamily,
                                     IsList and IsAssocWordCollection]);

#############################################################################
##
#P  IsShortLexOrdering( <ord>) 
##
##  for an ordering <ord> of a family of associative words,
##  returns `true' if and only if <ord> is a ShortLex ordering.
##
DeclareProperty("IsShortLexOrdering",IsOrdering and 
                          IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#F  IsShortLexLessThanOrEqual( <u>, <v> )
##
##  returns `IsLessThanOrEqualUnder(<ord>, <u>, <v>)' where <ord> is the 
##  short less ordering for the family of <u> and <v>.
##  (This is here for compatibility with {\GAP}~4.2.)
##
DeclareGlobalFunction( "IsShortLexLessThanOrEqual" );

#############################################################################
##
#O  WeightLexOrdering( <fam>,<alphabet>,<wt>)
#O  WeightLexOrdering( <fam>,<gensord>,<wt>)
#O  WeightLexOrdering( <f>,<alphabet>,<wt>)
#O  WeightLexOrdering( <f>,<gensord>,<wt>)
##
##  In the first form, for a family <fam> of associative words
##  and a list <wt>, `WeightLexOrdering'
##  returns the WeightLex ordering on the elements of <fam>
##  with the order in the alphabet being the default one
##  and the weights of the letters in the alphabet being given
##  by <wt>.
##
##  In the second form, for a family <fam> of associative words,
##  a list <wt> and a list <gensorder> of the length of the alphabet, 
##  `WeightLexOrdering' returns the WeightLex  
##  ordering on the elements of <fam> with the order on the alphabet
##  given by <gensord> and the weights of the letters in the alphabet 
##  being given by <wt>. 
##
##  In the third form, for a free semigroup of a free monoid <f>
##  and a list <wt>, `WeightLexOrdering'
##  returns the WeightLex ordering on the family of the elements of <f>
##  with the order in the alphabet being the default one
##  and  the weights of the letters in the alphabet being given
##  by <wt>.
##
##  In the fourth form, for a free semigroup of a free monoid <f>,
##  a list <wt> and a list <gensorder> of the length of the alphabet,
##  `WeightLexOrdering' returns the WeightLex  
##  ordering on the elements of <f> with the order on the alphabet
##  given by <gensord> and the weights of the letters in the alphabet 
##  being given by <wt>. 
##
DeclareOperation("WeightLexOrdering",
  [IsFamily and IsAssocWordFamily,IsList and IsAssocWordCollection,IsList]);

#############################################################################
##
#A  WeightOfGenerators( <ord>)
##
##  for a WeightLex ordering <ord>,
##  returns a list <l> with length the size of the alphabet of the family.
##  This list gives the weight of each of the letters of the alphabet
##  which are used for WeightLex orderings with respect to the
##  ordering given by `OrderingOnGenerators' (see~"OrderingOnGenerators").
##  
DeclareAttribute("WeightOfGenerators",IsOrdering and 
                    IsOrderingOnFamilyOfAssocWords);

#############################################################################
##  
#P  IsWeightLexOrdering( <ord>)
##
##  for an ordering <ord> on a family of associative words,
##  returns `true' if and only if <ord> is a WeightLex ordering.
##
DeclareProperty("IsWeightLexOrdering",IsOrdering and
                      IsOrderingOnFamilyOfAssocWords);

#############################################################################
##
#O  BasicWreathProductOrdering( <fam>)
#O  BasicWreathProductOrdering( <fam>, <alphabet>)
#O  BasicWreathProductOrdering( <fam>, <gensord>)
#O  BasicWreathProductOrdering( <f>)
#O  BasicWreathProductOrdering( <f>, <alphabet>) 
#O  BasicWreathProductOrdering( <f>, <gensord>)
##
##  In the first form, for a family of associative words,
##  `BasicWreathProductOrdering'
##  returns the basic wreath product ordering on the elements of <fam>
##  with the order in the alphabet being the default one.
##
##  In the second form, for a family of associative words and
##  a list <alphabet>, `BasicWreathProductOrdering' returns the
##  basic wreath product ordering on the elements of <fam> with the order 
##  on the alphabet given by <alphabet>. 
##
##  In the third form, for a family of associative words and
##  a list <gensorder> of the length of the alphabet,
##  `BasicWreathProductOrdering' returns the 
##  basic wreath product ordering on the elements of <fam> with the order 
##  on the alphabet given by <gensord>. 
##
##  In the fourth form, for a free semigroup of a free monoid <f>,
##  `BasicWreathProductOrdering'
##  returns the basic wreath product ordering on the family of the 
##  elements of <f> with the order in the alphabet being the default one.
##
##  In the fifth form, for a free semigroup or a free monoid <f>,
##  and a list <alphabet> of generators, `BasicWreathProductOrdering' 
##  returns the basic wreath product ordering on the family of the elements 
##  of <f> with the order on the alphabet given by <alphabet>. 
##
##  In the sixth form, for a free semigroup or a free monoid <f>,
##  and a list <gensorder>, `BasicWreathProductOrdering' 
##  returns the basic wreath product ordering on the family of the elements 
##  of <f> with the order on the alphabet given by <gensord>. 
##
DeclareOperation("BasicWreathProductOrdering",[IsAssocWordFamily,IsList]);

#############################################################################
##
#P  IsBasicWreathProductOrdering( <ord>)
##
DeclareProperty("IsBasicWreathProductOrdering",IsOrdering);

#############################################################################
##
#F  IsBasicWreathLessThanOrEqual( <u>, <v> )
##  
##  returns `IsLessThanOrEqualUnder(<ord>, <u>, <v>)' where <ord> is the
##  basic wreath product ordering for the family of <u> and <v>.
##  (This is here for compatibility with {\GAP}~4.2.)
##  
DeclareGlobalFunction( "IsBasicWreathLessThanOrEqual" );

#############################################################################
##
#O  WreathProductOrdering( <fam>, <levels>) 
#O  WreathProductOrdering( <fam>, <alphabet>, <levels>)
#O  WreathProductOrdering( <fam>, <gensord>, <levels>)
#O  WreathProductOrdering( <f>, <levels>)      
#O  WreathProductOrdering( <f>, <alphabet>, <levels>)
#O  WreathProductOrdering( <f>, <gensord>, <levels>)
##
##  returns the wreath product ordering of the
##  family <fam> of associative words or a free semigroup/monoid <f>.
##  The ordering on the generators may be omitted (in which case the default
##  one is considered), or may be given either by a list
##  <alphabet> consisting of the alphabet of the family in the appropriate
##  ordering, or by a list <gensord>  giving the permutation of the alphabet. 
##  It also needs a list <levels> giving the levels of each generator.
##  Notice that this list gives the levels of the generators in the new 
##  ordering (not necessarily the default one),
##  i.e. `<levels>[<i>]' is the level of the generator that comes <i>-th
##  in the ordering of generators given by <alphabet> or <gensord>.
##
DeclareOperation("WreathProductOrdering",[IsFamily,IsList,IsList]);

#############################################################################
##
#P  IsWreathProductOrdering( <ord>)
##
DeclareProperty("IsWreathProductOrdering",IsOrdering);

#############################################################################
##
#A  LevelsOfGenerators( <ord>)
##
##  for a wreath product ordering <ord>, returns the levels 
##  of the generators as given at creation (with
##  respect to `OrderingOnGenerators'; see~"OrderingOnGenerators").
##
DeclareAttribute("LevelsOfGenerators",IsOrdering and IsWreathProductOrdering);

