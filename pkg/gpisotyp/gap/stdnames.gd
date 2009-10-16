#############################################################################
##
#W  stdnames.gd          GAP 4 package `gpisotyp'               Thomas Breuer
##
#H  @(#)$Id: stdnames.gd,v 1.6 2002/07/10 16:32:46 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for name translation objects and
##  for the special case of standard names of groups.
##
##  0. Global variables for the package
##  1. Translated Names, Admissible Names, and Composed Names
##  2. Name Translator Objects
##  3. Standard Names, Admissible Names, and Second Level Synonyms
##  4. Name Standardizer Objects
##  5. Admissible Names and Standard Names of Groups
##  6. A utility for names of finite simple groups
##  7. Markup Names of Groups
##  8. Internal Structure of Name Translator Objects
##
Revision.( "gpisotyp/gap/stdnames_gd" ) :=
    "@(#)$Id: stdnames.gd,v 1.6 2002/07/10 16:32:46 gap Exp $";

#T - define also the alphabet for each name translator object
#T - mention the shortcut that <poss1> may be an integer instead of a list
#T   of length 1
#T - mention the automatic replacement of strings by integers
#T - mention the possibility to write down strings instead of functions
#T   (evaluated with `EvalString')
#T - rewrite `CompareFormatsOfParametrizedNames' in order to support the
#T   four parse functions, and improve the function
#T - add composed names
#T - add "second level synonyms"

#############################################################################
##
##  0. Global variables for the package
##


#############################################################################
##
#V  InfoGpIsoTyp
##
##  If the info level of `InfoGpIsoTyp' is at least $1$ then messages are
##  printed whenever translated names are notified more than once.
##
##  The default level is $0$, no information is printed on this level.
##
DeclareInfoClass( "InfoGpIsoTyp" );


#############################################################################
##
#F  ReadGpIsoTyp( <name> )  . . . . . . . . . . . . data files of the package
#F  RereadGpIsoTyp( <name> )  . . . . . . . . . . . data files of the package
##
##  These functions are used to read data files of the package `gpisotyp'.
##
DeclareGlobalFunction( "ReadGpIsoTyp" );
DeclareGlobalFunction( "RereadGpIsoTyp" );


#############################################################################
##
#V  GpIsoTypGlobals
##
##  This is the global record used by the GpIsoTyp package,
##  see for example~"StandardizerForNamesOfGroups"
##  and "CompareFormatsOfParametrizedNames".
##
DeclareGlobalVariable( "GpIsoTypGlobals" );


#############################################################################
##
##  1. Translated Names, Admissible Names, and Composed Names
#1
##  Each name translator object <nametransobj> defines a set of strings,
##  called the *admissible names* w.r.t. <nametransobj>,
##  and for each such string a unique string which is called its
##  *translation* w.r.t. <nametransobj>;
##  the translation is computed with `TranslatedName' (see~"TranslatedName").
##
##  Here are two examples of name translator objects where the admissible
##  names are names of groups, such as `"M12"'.
##  In the first case, the translation of each name is a markup format for
##  it, for example `"M\<sub>12\</sub>"';
##  from these translations, one can compute La{\TeX} and HTML formats,
##  which may be used in tables (that are composed by appropriate {\GAP}
##  functions) for being included into La{\TeX} and HTML documents
##  (see Section~"Markup Names of Groups").
##  In the second case, the translation of each name is a desciptions of the
##  Schur multiplier of the group in question, for example `"2"';
##  from that one can compute a name for the Schur cover
##  (see Section~"Names of Schur Multipliers of Groups").
##
##  We distinguish two kinds of admissible names for name translator objects.
##  First, there are (finitely many) *individual admissible names*,
##  which have been explicitly notified, such as names for the sporadic
##  simple groups.
##  Second, there are (finitely many) *parametrized admissible names*,
##  each for a whole series of names, such as `"A<n>.2"' for `"S<n>"'
##  (for $<n> \geq 4$, $<n> \not= 6$).
##
##  A series of parametrized admissible names and their translations are
##  described by *format patterns*, additional *match conditions*,
##  and a *mapping pattern*, together with the *parse function* of the
##  name translator object.
##
##  A format pattern is a list of strings and *characteristic functions* of
##  subsets of the ASCII characters (that is, unary functions that return
##  `true' or `false' when applied to ASCII characters).
##  Examples for characteristic functions are `IsAlphaChar' and `IsDigitChar'
##  (see~"ref:IsAlphaChar" and~"ref:IsDigitChar" in the {\GAP} Reference
##  Manual).
##
##  A string <name> is defined to *match* the format pattern <namefmt>
##  if the parse function of the name translator object (which is chosen
##  upon creation of the name translator object) does not return `fail' when
##  applied to <name> and <namefmt>; in this case the return value is a
#T well, don't we apply `NormalizedName' to <name> and <namefmt>?
##  list <list> of substrings of <name> whose concatenation is again <name>,
##  and such that the entries of <list> correspond to those in <namefmt>
##  in the sense that strings in <namefmt> appear in the same positions in
##  <list>, and for the other entries in <list>,
##  the corresponding characteristic function in <namefmt> returns `true'
##  for each contained character.
##
##  For example, `"A5.2"' matches the format pattern
##  `[ "A", IsDigitChar, ".2" ]' if the parse function is one of those
##  introduced in Section~"Internal Structure of Name Translator Objects",
##  and <list> is `[ "A", "5", ".2" ]'.
##  Note that it may depend on the parse function whether a given string
##  matches, and what exactly the function returns.
##
##  If <name> matches <namefmt>, and <list> is the result of the parse
##  function, we apply the match conditions in order to decide whether
##  <name> is admissible.
##  They are given by a list <conditions> whose entries are lists of positive
##  integers at its odd positions, and functions at the subsequent even
##  positions; the functions are applied to the subset of <list> given by the
##  lists of integers, and if each of the results is `true' then <name> is an
##  admissible name in the series in question.
##
##  As a continuation of the above example, the match conditions
##  `[ 2, n -> n >= 4 and n \<> 6 ]' mean that the second entry in <list>
##  denotes an integer larger than $3$ and different from $6$.
##
##  Now the translation of <name> is defined by the format pattern
##  <translatedfmt> of the translation, and the mapping pattern,
##  which is a list <map> of the form `[ <poss1>, <func>, <pos2>, ... ]',
##  where <poss1> is a list of positive integers, <pos2> is a positive
##  integer, and <func> is a function.
##  We take a shallow copy of <translatedfmt>, and replace the value at
##  position <pos2> by the value of <func> applied to the sublist of <list>
##  at <pos1>.
##
##  Again continuing the example, we take `[ "S", IsDigitChar ]' as the
##  format pattern of the translation, and `[ 2, x -> x, 2 ]' as the mapping
##  pattern, and get `"S5"' as the translation of `"A5.2"'.
##
#T add composed names!!
##


#############################################################################
##
##  2. Name Translator Objects
##


#############################################################################
##
#F  TranslatedName( <nametransobj>, <name> )
##
##  If <name> is an admissible name w.r.t. the name translator object
##  <nametransobj>, `TranslatedName' returns the corresponding translation;
##  otherwise `fail' is returned.
##
DeclareGlobalFunction( "TranslatedName" );


#############################################################################
##
#F  EmptyNameTranslatorObject( <arec> )
##
##  This function returns a new name translator object with no names being
##  admissible yet.
##  The components of the result are listed in
##  Section~"Internal Structure of Name Translator Objects".
##
##  The default values for the components `ParseFunction' and
##  `NormalizedName' are `ParseForwardsWithSuffix' and `IdFunc',
##  respectively,
##  the default value for `SortNames' and `TestNotificationsOfNames' is
##  `true';
##  these defaults are overwritten by the components in the argument record
##  <arec>.
##
DeclareGlobalFunction( "EmptyNameTranslatorObject" );


#############################################################################
##
#F  NotifyIndividualTranslatedName( <nametransobj>, <name>, <translation> )
##
##  For a name translator object <nametransobj> and two strings <name> and
##  <translation>,
##  `NotifyIndividualTranslatedName' makes <name> an admissible name w.r.t.
##  <nametransobj>, with translation <translation>.
##
##  If `<nametransobj>.TestNotificationsOfNames' is `true' then it is checked
##  before whether <name> is already admissible,
##  and if so and if its translation differs from <translation>,
##  an error is signalled.
##
DeclareGlobalFunction( "NotifyIndividualTranslatedName" );


#############################################################################
##
#F  NotifyParametrizedTranslatedName( <nametransobj>, <namefmt>,
#F      <translatedfmt>, <conditions>, <map> )
##
##  Let <nametransobj> be a name translator object,
##  the lists <namefmt> and <translatedfmt> be format patterns,
##  the list <conditions> be the match conditions,
##  and the list <map> be a mapping pattern
##  (see~"Translated Names, Admissible Names, and Standard Names").
##
##  `NotifyParametrizedTranslatedName' notifies a series of admissible names
##  and their translations.
##
DeclareGlobalFunction( "NotifyParametrizedTranslatedName" );


#############################################################################
##
##  3. Standard Names, Admissible Names, and Second Level Synonyms
#3
##  If a name translator object
##  (see~"Translated Names, Admissible Names, and Composed Names")
##  is a *name standardizer object* <stdobj> then additionally
##  the translation of an admissible name <name> w.r.t. <stdobj> is itself an
##  admissible name w.r.t. <stdobj>,
##  and is called the *standard name* of <name>, w.r.t. <stdobj>.
##  A typical situation where a name standardizer object can be used is the
##  case of a database where it shall be possible to access an object via
##  several names, but internally we want to deal only with one fixed name;
##  after declaring a standard name, we can notify as many admissible
##  names for it as we want.
##
##  add second level synonyms!
##


#############################################################################
##
##  4. Name Standardizer Objects
##


#############################################################################
##
#F  StandardName( <stdobj>, <name> )
##
##  If <name> is an admissible name w.r.t. the name standardizer object
##  <stdobj>, `StandardName' returns the corresponding standard name;
##  otherwise `fail' is returned.
##
##  (This is a synonym of `TranslatedName', see~"TranslatedName".)
##
DeclareSynonym( "StandardName", TranslatedName );


#############################################################################
##
#F  EmptyNameStandardizerObject( <arec> )
##
##  This function returns the same as `EmptyNameTranslatorObject'
##  (see~"EmptyNameTranslatorObject"), except that additionally the component
##  `IsNameStandardizer' of the result is set to `true'.
##
DeclareGlobalFunction( "EmptyNameStandardizerObject" );


#############################################################################
##
#F  NotifyIndividualStandardName( <stdobj>, <name> )
##
##  For a name standardizer object <stdobj> and a string <name>,
##  `NotifyIndividualStandardName' makes <name> a standard name w.r.t.
##  <stdobj>.
##  (That is, <name> is made an admissible name w.r.t. <stdobj>, with
##  translation <name>.)
##
##  Concerning the checks made, see~"NotifyIndividualTranslatedName".
##
DeclareGlobalFunction( "NotifyIndividualStandardName" );


#############################################################################
##
#F  NotifyIndividualAdmissibleName( <stdobj>, <stdname>, <admname> )
##
##  For a name standardizer object <stdobj> and two strings <stdname> and
##  <admname>, `NotifyIndividualAdmissibleName' makes <admname> an admissible
##  name w.r.t. <stdobj>, for the name `StandardName( <stdname> )'.
##
##  If `<stdobj>.TestNotificationsOfNames' is `true' then it is checked
##  before whether <stdname> is admissible,
##  and if not then an error is signalled.
##
DeclareGlobalFunction( "NotifyIndividualAdmissibleName" );


#############################################################################
##
#F  NotifyParametrizedStandardName( <stdobj>, <namefmt>, <conditions> )
##
##  Let <stdobj> be a name standardizer object.
##  `NotifyParametrizedStandardName' does the same as
##  `NotifyParametrizedTranslatedName'
##  (see~"NotifyParametrizedTranslatedName"), with its argument
##  <translatedfmt> equal to <namefmt>, and a trivial argument <map>.
##
DeclareGlobalFunction( "NotifyParametrizedStandardName" );


#############################################################################
##
#F  NotifyParametrizedAdmissibleName( <stdobj>, <stdfmt>, <admfmt>,
#F      <conditions>, <map> )
##
##  Let <stdobj> be a name standardizer object.
##  `NotifyParametrizedAdmissibleName' does the same as
##  `NotifyParametrizedTranslatedName'
##  (see~"NotifyParametrizedTranslatedName"),
##  its arguments <namefmt> and <translatedfmt> being equal to
##  <admfmt> and <stdfmt>, respectively.
##
DeclareGlobalFunction( "NotifyParametrizedAdmissibleName" );


#############################################################################
##
##  5. Admissible Names and Standard Names of Groups
##


#############################################################################
##
#V  StandardizerForNamesOfGroups
##
##  This is the common name standardizer object used by the {\GAP} Character
##  Table Library, the {\GAP} Library of Tables of Marks, and
##  the {\GAP} package AtlasRep (see the documentation of these packages).
##
##  The component `NormalizedName' has the value `LowercaseString', so
##  the admissible names are not case sensitive;
##  the component `ParseFunction' has the value `ParseForwardsWithSuffix'.
##  The default names of `StandardizerForNamesOfGroups' are added in the
##  file `data/stdnames.dat' of the GpIsoTyp package,
##  this file is read when `StandardizerForNamesOfGroups' is accessed for the
##  first time;
##  the values of the components `SortNames' and `TestNotificationsOfNames'
##  during reading this file are given by the components with these names in
##  `GpIsoTypGlobals' (see~"GpIsoTypGlobals"), the components are set to
##  `false' after reading the file.
##
# DeclareGlobalVariable( "StandardizerForNamesOfGroups" );

AUTO( ReadGpIsoTyp, "stdnames.dat", "StandardizerForNamesOfGroups" );


#############################################################################
##
#F  StandardNameOfGroup( <name> )
##
##  This is a shorthand for the more general function `StandardName',
##  where the first argument is `StandardizerForNamesOfGroups'.
##  So `StandardNameOfGroup( <name> )' is equal to
##  `StandardName( StandardizerForNamesOfGroups, <name> )'.
##
DeclareGlobalFunction( "StandardNameOfGroup" );


#############################################################################
##
##  6. A utility for names of finite simple groups
##


#############################################################################
##
#F  StandardNameOfFiniteSimpleGroupFromSeriesInfo( <info> )
##
##  This function provides an interface between the (somewhat strange) name
##  information returned by `IsomorphismTypeInfoFiniteSimpleGroup'
##  (see~"ref:IsomorphismTypeInfoFiniteSimpleGroup" in the {\GAP} Reference
##  Manual) and the standard names of groups understood by
##  `StandardNameOfGroup' (see~"StandardNameOfGroup").
##
##  For a record <info> with the components `series' and `parameters', as
##  returned by `IsomorphismTypeInfoFiniteSimpleGroup',
##  `StandardNameOfFiniteSimpleGroupFromSeriesInfo' returns the standard name
##  of the group in question, according to the {\GAP} object
##  `StandardizerForNamesOfGroups' (see~"StandardizerForNamesOfGroups").
##
##  For a list <info> of records as described above,
##  `StandardNameOfFiniteSimpleGroupFromSeriesInfo' returns the list of these
##  standard names.
##
DeclareGlobalFunction( "StandardNameOfFiniteSimpleGroupFromSeriesInfo" );


#############################################################################
##
##  7. Markup Names of Groups
##
#T Use a better markup approach, where subscripts, superscripts,
#T direct products, split extensions (what else?) are supported,
#T and where the names can be easily converted to La{\TeX} and HTML
#T via a {\GAP} function!
##


#############################################################################
##
#V  MarkupNamesOfGroups
##
##  This is the name translator object that assigns markup format names
##  to the admissible names of `StandardizerForNamesOfGroups'
##  (see~"StandardizerForNamesOfGroups").
##  Such a translation can then be used as an argument for the functions
##  `LaTeXNameOfGroup' and `HTMLNameOfGroup' (see~"LaTeXNameOfGroup").
##
##  The component `NormalizedName' has the value `LowercaseString', so
##  the admissible names are not case sensitive;
##  the component `ParseFunction' has the value `ParseForwardsWithSuffix'.
##  The default names of `MarkupNamesOfGroups' are added in the
##  file `data/texnames.dat' of the GpIsoTyp package,
##  this file is read when `MarkupNamesOfGroups' is accessed for the
##  first time;
##  the values of the components `SortNames' and `TestNotificationsOfNames'
##  during reading this file are given by the components with these names in
##  `GpIsoTypGlobals' (see~"GpIsoTypGlobals"), the components are set to
##  `false' after reading the file.
##
# DeclareGlobalVariable( "MarkupNamesOfGroups" );

AUTO( ReadGpIsoTyp, "mkupname.dat", "MarkupNamesOfGroups" );


#############################################################################
##
#F  LaTeXNameOfGroup( <markupname> )
#F  HTMLNameOfGroup( <markupname> )
##

#T  , in order to get a name in
##  La{\TeX} or HTML format, respectively.
##  The La{\TeX} names are thought for use inside maths mode, but the enclosing
##  dollar signs are omitted in order to make it easier to compose larger
##  maths mode strings (e.g., arrays) involving the names.
##

##
DeclareGlobalFunction( "LaTeXNameOfGroup" );
DeclareGlobalFunction( "HTMLNameOfGroup" );


#############################################################################
##
#V  TranslatorForNamesOfSchurMultipliersOfGroups
##
##  ...
##
##  currently covers finite simple groups, symmetric groups,
##
# DeclareGlobalVariable( "TranslatorForNamesOfSchurMultipliersOfGroups" );

AUTO( ReadGpIsoTyp, "schurnam.dat",
      "TranslatorForNamesOfSchurMultipliersOfGroups" );


#############################################################################
##
##  8. Internal Structure of Name Translator Objects
#8
##  The data needed to describe the relations between admissible names and
##  their translations are stored in certain {\GAP} records
##  with the following components.
##
##  `IndividualAdmissibleNames' and `IndividualTranslatedNames':
##
##  These are two lists, containing the individual admissible names and their
##  translations at corresponding positions.
##  Entries are added to these lists via `NotifyIndividualTranslatedName'
##  (see~"NotifyIndividualTranslatedName") and
##  `NotifyIndividualAdmissibleName' (see~"NotifyIndividualAdmissibleName").
##
##  `ParametrizedNamesInfo':
##
##  The value is a list of records, each with the following components.
##  \beginitems
##  `adm' &
##      a list of strings and functions describing admissible names,
##
##  `trn' &
##      a list of strings and functions describing the corresponding
##      translated names,
##
##  `cond' &
##      a list of conditions for the admissible name,
##      of the form `[ <poss>, <func>, ... ]' where <poss> is a list of
##      positions in the `adm' entry, and <func> is a function that returns
##      `true' or `false'; the parsed name matches only if the functions applied
##      to the entries in the positions <poss> return `true',
##
##  `map' &
##      a list of the form `[ <pos1>, <func>, <pos2>, ... ]' where
##      <pos1> is a position in the `adm' entry, <func> is a function to be
##      applied to the corresponding value in the parsed name, and <pos2>
##      is the position in the `std' entry where the function value shall be
##      entered.
##  \enditems
##  Entries are added to these lists via `NotifyParametrizedTranslatedName'
##  (see~"NotifyParametrizedTranslatedName")
##  and `NotifyParametrizedAdmissibleName'
##  (see~"NotifyParametrizedAdmissibleName").
##
##  `IsNameStandardizer':
##
##  If this component is bound and has the value `true' then the record
##  represents a name standardizer object, otherwise it does not.
##
##  `NormalizedName':
##
##  The value is a unary function <normfunc>;
##  before the name <name> is translated with `TranslatedName' or
##  `StandardName', <name> is replaced by `<normfunc>( <name> )';
##  analogously, in the declaration of an admissible name, the strings in the
##  format pattern list are replaced by their values under <normfunc>.
##  The idea is is that the translation can be made case independent by
##  using `LowercaseString' or that leading and trailing white space in names
##  may be ignored by using `NormalizedWhiteSpace' (see~"ref:LowercaseString"
##  and "ref:NormalizeWhitespace" in the {\GAP} Reference Manual);
##  if no such normalization is desired, one can use `IdFunc'.
##
##  `ParseFunction':
##
##  The value is the function that defines when a string matches a format of
##  parametrized names; this function must take two arguments <admname> and
##  <fmt>, and return either `fail' or the splitting of <admname>
##  according to <fmt>
##  (see~"Translated Names, Admissible Names, and Standard Names").
##  Typical values are `ParseForwards', `ParseForwardsWithSuffix',
##  `ParseBackwards', and `ParseBackwardsWithPrefix' (see~"ParseForwards").
##
##  `SortNames':
##
##  If the value is `true' then the list of individual admissible names is
##  known to be strictly sorted, and is kept strictly sorted after each
##  addition of a new individual admissible name.
##  (This is useful when the name translator object is accessed for
##  translations more probably than for additions of new names to it,
##  whereas the value should be set to `false' before a larger number of
##  additions, and afterwards the individual admissible names and their
##  translations should be sorted via `SortParallel', and the component
##  `SortNames' can be set to `true'.)
##
##  `TestNotificationsOfNames':
##
##  If the value is `false' then the consistency checks for standard names
##  and admissible names are omitted.
##


#############################################################################
##
#F  ParseBackwards( <string>, <fmt> )
#F  ParseBackwardsWithPrefix( <string>, <fmt> )
#F  ParseForwards( <string>, <fmt> )
#F  ParseForwardsWithSuffix( <string>, <fmt> )
##
##  These are predefined parse functions
##  (see~"Translated Names, Admissible Names, and Standard Names")
##  for name translator objects.
##  They return `fail' if the string <string> does not match the format
##  pattern <fmt>, and otherwise a splitting of <string> according to
##  <fmt>.
##
##  All four functions parse <string> in one direction, and take the longest
##  possible substring for each characteristic function that occurs in
##  <fmt>.
##  `ParseBackwards' and `ParseForwards' start from the last and from the
##  first character of <string>, respectively.
##  `ParseBackwardsWithPrefix' and `ParseForwardsWithSuffix' do the same,
##  except that they first remove common string parts from the beginning
##  and the end, respectively, of both <string> and <fmt>.
##
DeclareGlobalFunction( "ParseBackwards" );
DeclareGlobalFunction( "ParseBackwardsWithPrefix" );
DeclareGlobalFunction( "ParseForwards" );
DeclareGlobalFunction( "ParseForwardsWithSuffix" );


#############################################################################
##
#F  CompareFormatsOfParametrizedNames( <fmt1>, <cond1>, <fmt2>, <cond2> )
##
##  Given two format patterns <fmt1> and <fmt2> and corresponding match
##  conditions <cond1> and <cond2>
##  (see~"Translated Names, Admissible Names, and Standard Names"),
##  `CompareFormatsOfParametrizedNames' checks whether there are strings
##  that match the two format patterns and satisfy the two match
##  conditions.
##
##  The return value is `true' if such a string exists, `false' if no such
##  string exists, and `fail' if the function is not able to decide this
##  question.
##
##  This function is used when new parametrized translated names are defined,
##  in order to avoid that one name can be translated via different
##  parametrized admissible names.
##  In the case of name standardizer objects it is also used when new
##  parametrized admissible names are defined, in order to make sure that the
##  translation in question is really a standard name.
##
##  (Currently this is still experimental.)
##
##  The global variable `GpIsoTypGlobals.ContradictoryConditions' is used
##  for deciding whether the two match conditions are compatible;
##  the value of this variable is a list of pairs `[ <fun1>, <fun2> ]'
##  where <fun1> and <fun2> are unary functions such that there is no string
##  for which both return `true'.
##  (In cases where `CompareFormatsOfParametrizedNames' returns `fail',
##  extending this list might help to improve the behaviour.)
##
DeclareGlobalFunction( "CompareFormatsOfParametrizedNames" );


#############################################################################
##
#E

