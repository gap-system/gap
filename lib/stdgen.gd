#############################################################################
##
#W  stdgen.gd                GAP library                        Thomas Breuer
##
#H  @(#)$Id$
##
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations needed for dealing with standard
##  generators of finite groups.
##
Revision.stdgen_gd :=
    "@(#)$Id$";


#T TO DO:
#T - a function that can be used to *define* standard generators,
#T   using the character table with underlying group (perhaps also the
#T   table of marks or an explicit description of all maximal subgroups)


#############################################################################
##
##  Standard Generators of Groups
#1
##  An $s$-tuple of *standard generators* of a given group $G$ is a vector
##  $(g_1, g_2, \ldots, g_s)$ of elements $g_i \in G$ satisfying certain
##  conditions (depending on the isomorphism type of $G$) such that
##  \beginlist
##  \item{1.}
##      $\langle g_1, g_2, \ldots, g_s \rangle = G$ and
##  \item{2.}
##      the vector is unique up to automorphisms of $G$,
##      i.e., for two vectors $(g_1, g_2, \ldots, g_s)$ and
##      $(h_1, h_2, \ldots, h_s)$ of standard generators,
##      the map $g_i \mapsto h_i$ extends to an automorphism of $G$.
##  \endlist
##  For details about standard generators, see~\cite{Wil96}.
##


#############################################################################
##
#A  StandardGeneratorsInfo( <G> )
##
##  When called with the group <G>,
##  `StandardGeneratorsInfo' returns a list of records with at least one of
##  the components `script' and `description'.
##  Each such record defines *standard generators* of groups isomorphic
##  to <G>, the $i$-th record is referred to as the $i$-th set of
##  standard generators for such groups.
##  The value of `script' is a dense list of lists, each encoding a command
##  that has one of the following forms.
##  \beginitems
##  A *definition* $[ i, n, k ]$ or $[ i, n ]$ &
##      means to search for an element of order $n$,
##      and to take its $k$-th power as candidate for the $i$-th standard
##      generator (the default for $k$ is $1$),
##
##  a *relation* $[ i_1, k_1, i_2, k_2, \ldots, i_m, k_m, n ]$ with $m > 1$ &
##      means a check whether the element
##      $g_{i_1}^{k_1} g_{i_2}^{k_2} \cdots g_{i_m}^{k_m}$ has order $n$;
##      if $g_j$ occurs then of course the $j$-th generator must have been
##      defined before,
##
##  a *relation* $[ [ i_1, i_2, \ldots, i_m ], <slp>, n ]$ &
##      means a check whether the result of the straight line program <slp>
##      (see~"Straight Line Programs") applied to the candidates
##      $g_{i_1}, g_{i_2}, \ldots, g_{i_m}$ has order $n$,
##      where the candidates $g_j$ for the $j$-th standard generators
##      must have been defined before,
##
##  a *condition* $[ [ i_1, k_1, i_2, k_2, \ldots, i_m, k_m ], f, v ]$ &
##      means a check whether the {\GAP} function in the global list
##      `StandardGeneratorsFunctions' (see "StandardGeneratorsFunctions")
##      that is followed by the list $f$ of strings returns the value $v$
##      when it is called with $G$ and
##      $g_{i_1}^{k_1} g_{i_2}^{k_2} \cdots g_{i_m}^{k_m}$.
##  \enditems
##  Optional components of the returned records are
##  \beginitems
##  `generators' &
##      a string of names of the standard generators,
##
##  `description' &
##      a string describing the `script' information in human readable form,
##      in terms of the `generators' value,
##
##  `classnames' &
##      a list of strings, the $i$-th entry being the name of the conjugacy
##      class containing the $i$-th standard generator,
##      according to the {\ATLAS} character table of the group
##      (see~"ClassNames"), and
#T function that tries to compute the classes from the `description' value
#T and the character table?
##
##  `ATLAS' &
##      a boolean; `true' means that the standard generators coincide with
##      those defined in Rob Wilson's {\ATLAS} of Group Representations
##      (see~\cite{AGR}), and `false' means that this property is not
##      guaranteed.
##  \enditems
##
##  There is no default method for an arbitrary isomorphism type,
##  since in general the definition of standard generators is not obvious.
##
##  The function `StandardGeneratorsOfGroup'
##  (see~"StandardGeneratorsOfGroup")
##  can be used to find standard generators of a given group isomorphic
##  to <G>.
##
##  The `generators' and `description' values, if not known, can be computed
##  by `HumanReadableDefinition' (see~"HumanReadableDefinition").
##
DeclareAttribute( "StandardGeneratorsInfo", IsGroup );
#T make this an operation also for strings?


#############################################################################
##
#F  HumanReadableDefinition( <info> )
#F  ScriptFromString( <string> )
##
##  Let <info> be a record that is valid as value of `StandardGeneratorsInfo'
##  (see~"StandardGeneratorsInfo!for groups").
##  `HumanReadableDefinition' returns a string that describes the definition
##  of standard generators given by the `script' component of <info> in
##  human readable form.
##  The names of the generators are taken from the `generators' component
##  (default names `\"a\"', `\"b\"' etc.~are computed if necessary),
##  and the result is stored in the `description' component.
##
##  `ScriptFromString' does the converse of `HumanReadableDefinition', i.e.,
##  it takes a string <string> as returned by `HumanReadableDefinition',
##  and returns a corresponding `script' list.
##
##  If ``condition'' lines occur in the script
##  (see~"StandardGeneratorsInfo!for groups")
##  then the functions that occur must be contained in
##  `StandardGeneratorsFunctions' (see~"StandardGeneratorsFunctions").
##
DeclareGlobalFunction( "HumanReadableDefinition" );

DeclareGlobalFunction( "ScriptFromString" );


#############################################################################
##
#V  StandardGeneratorsFunctions
##
##  `StandardGeneratorsFunctions' is a list of even length.
##  At position $2i-1$, a function of two arguments is stored,
##  which are expected to be a group and a group element.
##  At position $2i$ a list of strings is stored such that first inserting a
##  generator name in all holes and then forming the concatenation yields
##  a string that describes the function at the previous position;
##  this string must contain the generator enclosed in round brackets `('
##  and `)'.
##
##  This list is used by the functions `StandardGeneratorsInfo'
##  (see~"StandardGeneratorsInfo!for groups"), `HumanReadableDefinition', and
##  `ScriptFromString' (see~"HumanReadableDefinition").
##  Note that the lists at even positions must be pairwise different.
##
DeclareGlobalVariable( "StandardGeneratorsFunctions",
    "list of functions used in scripts, and their translations to strings" );


#############################################################################
##
#F  IsStandardGeneratorsOfGroup( <info>, <G>, <gens> )
##
##  Let <info> be a record that is valid as value of `StandardGeneratorsInfo'
##  (see~"StandardGeneratorsInfo!for groups"), <G> a group, and <gens> a list
##  of generators for <G>.
##  In this case, `IsStandardGeneratorsOfGroup' returns `true' if <gens>
##  satisfies the conditions of the `script' component of <info>,
##  and `false' otherwise.
##
##  Note that the result `true' means that <gens> is a list of standard
##  generators for <G> only if <G> has the isomorphism type for which <info>
##  describes standard generators.
##
DeclareGlobalFunction( "IsStandardGeneratorsOfGroup" );


#############################################################################
##
#F  StandardGeneratorsOfGroup( <info>, <G>[, <randfunc>] )
##
##  Let <info> be a record that is valid as value of `StandardGeneratorsInfo'
##  (see~"StandardGeneratorsInfo!for groups"),
##  and <G> a group of the isomorphism type for which <info> describes
##  standard generators.
##  In this case, `StandardGeneratorsOfGroup' returns a list of standard
##  generators (see~Section~"Standard Generators of Groups") of <G>.
##
##  The optional argument <randfunc> must be a function that returns an
##  element of <G> when called with <G>; the default is `PseudoRandom'.
##
##  In each call to `StandardGeneratorsOfGroup',
##  the `script' component of <info> is scanned line by line.
##  <randfunc> is used to find an element of the prescribed order
##  whenever a definition line is met,
##  and for the relation and condition lines in the `script' list,
##  the current generator candidates are checked;
##  if a condition is not fulfilled, all candidates are thrown away,
##  and the procedure starts again with the first line.
##  When the conditions are fulfilled after processing the last line
##  of the `script' list, the standard generators are returned.
##
#T Admit the possibility to specify the desired classes?
#T For example, if there is only one class of a given order of a standard
#T generator then this element may be taken first and kept also after
#T failure for a partial vector of candidates.
#T  (then the first element of right order may be kept, for example)
##
##  Note that if <G> has the wrong isomorphism type then
##  `StandardGeneratorsOfGroup' returns a list of elements in <G>
##  that satisfy the conditions of the `script' component of <info>
##  if such elements exist, and does not terminate otherwise.
##  In the former case, obviously the returned elements need not be standard
##  generators of <G>.
##
DeclareGlobalFunction( "StandardGeneratorsOfGroup" );


#############################################################################
##
#E

