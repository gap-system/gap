#############################################################################
##
#W  tom.gd                   GAP library                       Goetz Pfeiffer
#W                                                          & Thomas Merkwitz
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations of the category and family of tables
##  of marks, and their properties, attributes, operations and functions.
##
##  1. Tables of Marks
##  2. More about Tables of Marks
##  3. Table of Marks Objects in {\GAP}
##  4. Constructing Tables of Marks
##  5. Printing Tables of Marks
##  6. Sorting Tables of Marks
##  7. Technical Details about Tables of Marks
##  8. Attributes of Tables of Marks
##  9. Properties of Tables of Marks
##  10. Other Operations for Tables of Marks
##  11. Accessing Subgroups via Tables of Marks
##  12. The Interface between Tables of Marks and Character Tables
##  13. Generic Construction of Tables of Marks
##
Revision.tom_gd :=
    "@(#)$Id$";


#############################################################################
##
##  1. Tables of Marks
#1
##  The concept of a *table of marks* was introduced by W.~Burnside in his
##  book ``Theory of Groups of Finite  Order'', see~\cite{Bur55}.
##  Therefore a table of marks is sometimes called a *Burnside matrix*.
##
##  The table of marks of a finite group $G$ is a matrix whose rows and
##  columns are labelled by the conjugacy classes of subgroups of $G$
##  and where for two subgroups $A$ and $B$ the $(A, B)$--entry is
##  the number of fixed points of $B$ in the transitive action of $G$
##  on the cosets of $A$ in $G$.
##  So the table of marks characterizes the set of all permutation
##  representations of $G$.
##
##  Moreover, the table of marks gives a compact description of the subgroup
##  lattice of $G$, since from the numbers of fixed points the numbers of
##  conjugates of a subgroup $B$ contained in a subgroup $A$ can be derived.
##
##  A table of marks of a given group $G$ can be constructed from the
##  subgroup lattice of $G$ (see~"Constructing Tables of Marks").
##  For several groups, the table of marks can be restored from the {\GAP}
##  library of tables of marks (see~"The Library of Tables of Marks").
##
##  Given the table of marks of $G$, one can display it
##  (see~"Printing Tables of Marks")
##  and derive information about $G$ and its Burnside ring from it
##  (see~"Attributes of Tables of Marks", "Properties of Tables of Marks",
##  "Other Operations for Tables of Marks").
##  Moreover, tables of marks in {\GAP} provide an easy access to the classes
##  of subgroups of their underlying groups
##  (see~"Accessing Subgroups via Tables of Marks").
##


#############################################################################
##
##  2. More about Tables of Marks
#2
##  Let $G$ be a finite group with $n$ conjugacy classes of subgroups
##  $C_1, C_2, \ldots, C_n$ and representatives $H_i \in  C_i$,
##  $1 \leq i \leq n$.
##  The *table of marks* of $G$ is defined to be the $n \times n$ matrix
##  $M = (m_{ij})$ where the *mark* $m_{ij}$ is the number of fixed points
##  of the subgroup $H_j$ in the action of $G$ on the right cosets of $H_i$
##  in $G$.
##
##  Since $H_j$ can only have fixed points if it is contained in a point
##  stablizer the matrix $M$ is lower triangular if the classes $C_i$ are
##  sorted according to the condition that if $H_i$ is contained in a
##  conjugate of $H_j$ then $i \leq j$.
##
##  Moreover, the diagonal entries $m_{ii}$ are nonzero since $m_{ii}$ equals
##  the index of $H_i$ in its normalizer in $G$.  Hence $M$ is invertible.
##  Since any transitive action of $G$ is equivalent to an action on the
##  cosets of a subgroup of $G$, one sees that the table of marks completely
##  characterizes the set of all permutation representations of $G$.
##
##  The marks $m_{ij}$ have further meanings.
##  If $H_1$ is the trivial subgroup of $G$ then each mark $m_{i1}$ in the
##  first column of $M$ is equal to the index of $H_i$ in $G$
##  since the trivial subgroup fixes all cosets of $H_i$.
##  If $H_n = G$ then each $m_{nj}$ in the last row of $M$ is equal to $1$
##  since there is only one coset of $G$ in $G$.
##  In general, $m_{ij}$ equals the number of conjugates of $H_i$ containing
##  $H_j$, multiplied by the index of $H_i$ in its normalizer in $G$.
##  Moreover, the number $c_{ij}$ of conjugates of $H_j$ which are contained
##  in $H_i$ can be derived from the marks $m_{ij}$ via the formula
##  $$
##  c_{ij} = \frac{m_{ij} m_{j1}}{m_{i1} m_{jj}}\.
##  $$
##
##  Both the marks $m_{ij}$  and the numbers of subgroups $c_{ij}$ are needed
##  for the functions described in this chapter.
##
##  A brief survey of properties of tables of marks and a description of
##  algorithms for the interactive construction of tables of marks using
##  {\GAP} can be found in~\cite{Pfe97}.
##


#############################################################################
##
##  3. Table of Marks Objects in {\GAP}
#3
##  A table of marks of a group $G$ in {\GAP} is represented by an immutable
##  (see~"Mutability and Copyability") object <tom> in the category
##  `IsTableOfMarks' (see~"IsTableOfMarks"), with defining attributes
##  `SubsTom' (see~"SubsTom") and `MarksTom' (see~"MarksTom").
##  These two attributes encode the matrix of marks in a compressed form.
##  The `SubsTom' value of <tom> is a list where for each conjugacy class of
##  subgroups the class numbers of its subgroups are stored.
##  These are exactly the positions in the corresponding row of the matrix of
##  marks which have nonzero entries.
##  The marks themselves are stored via the `MarksTom' value of <tom>,
##  which is a list that contains for each entry in `SubsTom( <tom> )' the
##  corresponding nonzero value of the table of marks.
##
##  It is possible to create table of marks objects that do not store a
##  group, moreover one can create a table of marks object from a matrix of
##  marks (see~"TableOfMarks").
##  So it may happen that a table of marks object in {\GAP} is in fact *not*
##  the table of marks of a group.
##  To some extent, the consistency of a table of marks object can be checked
##  (see~"Other Operations for Tables of Marks"),
##  but {\GAP} knows no general way to prove or disprove that a given matrix
##  of nonnegative  integers is the matrix of marks for a group.
##  Many functions for tables of marks work well without access to the group
##  --this is one of the arguments why tables of marks are so useful--,
##  but for example normalizers (see~"NormalizerTom")
##  and derived subgroups (see~"DerivedSubgroupTom") of subgroups
##  are in general not uniquely determined by the matrix of marks.
##
##  {\GAP} tables of marks are assumed to be in lower triangular form,
##  that is, if a subgroup from the conjugacy class corresponding to the
##  $i$-th row is contained in a subgroup from the class corresponding to the
##  $j$-th row j then $i \leq j$.
##
##  The `MarksTom' information can be computed from the values of the
##  attributes `NrSubsTom', `LengthsTom', `OrdersTom', and `SubsTom'
##  (see~"NrSubsTom", "LengthsTom", "OrdersTom").
##  `NrSubsTom' stores a list containing for each entry in the `SubsTom'
##  value the corresponding number of conjugates that are contained
##  in a subgroup, `LengthsTom' a list containing for each conjugacy class
##  of subgroups its length, and `OrdersTom' a list containing for each
##  class of subgroups their order.
##  So the `MarksTom' value of <tom> may be missing provided that the values
##  of `NrSubsTom', `LengthsTom', and `OrdersTom' are stored in <tom>.
##
##  Additional information about a table of marks is needed by some
##  functions.
##  The class numbers of normalizers in $G$ and the number of the derived
##  subgroup of $G$ can be stored via appropriate attributes
##  (see~"NormalizersTom", "DerivedSubgroupTom").
##
##  If <tom> stores its group $G$ and a bijection from the rows and columns
##  of the matrix of marks of <tom> to the classes of subgroups of $G$ then
##  clearly normalizers, derived subgroup etc.~can be computed from this
##  information.
##  But in general a table of marks need not have access to $G$,
##  for example <tom> might have been constructed from a generic table of
##  marks (see~"Generic Construction of Tables of Marks"),
##  or as table of marks of a factor group from a given table of marks
##  (see~"FactorGroupTom").
##  Access to the group $G$ is provided by the attribute `UnderlyingGroup'
##  (see~"UnderlyingGroup!for tables of marks") if this value is set.
##  Access to the relevant information about conjugacy classes of subgroups
##  of $G$ --compatible with the ordering of rows and columns of the marks in
##  <tom>-- is signalled by the filter `IsTableOfMarksWithGens'
##  (see~"Accessing Subgroups via Tables of Marks").
##


#############################################################################
##
##  4. Constructing Tables of Marks
##


#############################################################################
##
#A  TableOfMarks( <G> )
#A  TableOfMarks( <string> )
#A  TableOfMarks( <matrix> )
##
##  In the first form, <G> must be a finite group, and `TableOfMarks'
##  constructs the table of marks of <G>.
##  This computation requires the knowledge of the complete subgroup lattice
##  of <G> (see~"LatticeSubgroups").
##  If the lattice is not yet stored then it will be constructed.
##  This may take a while if <G> is large.
##  The result has the `IsTableOfMarksWithGens' value `true'
##  (see~"Accessing Subgroups via Tables of Marks").
##
##  In the second form, <string> must be a string, and `TableOfMarks' gets
##  the table of marks with name <string> from the {\GAP} library
##  (see "The Library of Tables of Marks").
##  If no table of marks with this name is contained in the library then
##  `fail' is returned.
##
##  In the third form, <matrix> must be a matrix or a list of rows describing
##  a lower triangular matrix where the part above the diagonal is omitted.
##  For such an argument <matrix>, `TableOfMarks' returns
##  a table of marks object (see~"Table of Marks Objects in GAP")
##  for which <matrix> is the matrix of marks.
##  Note that not every matrix
##  (containing only nonnegative integers and having lower triangular shape)
##  describes a table of marks of a group.
##  Necessary conditions are checked with `IsInternallyConsistent'
##  (see~"Other Operations for Tables of Marks"), and `fail' is returned if
##  <matrix> is proved not to describe a matrix of marks;
##  but if `TableOfMarks' returns a table of marks object created from a
##  matrix then it may still happen that this object does not describe the
##  table of marks of a group.
##
DeclareAttribute( "TableOfMarks", IsGroup );
DeclareAttribute( "TableOfMarks", IsString );
DeclareAttribute( "TableOfMarks", IsTable );


#############################################################################
##
#4
##  The following `TableOfMarks' methods for a group are installed.
##  \beginlist
##  \item{-}
##      If the group is known to be cyclic then `TableOfMarks' constructs the
##      table of marks essentially without the group, instead the knowledge
##      about the structure of cyclic groups is used.
##  \item{-}
##      If the lattice of subgroups is already stored in the group then
##      `TableOfMarks' computes the table of marks from the lattice
##      (see~"TableOfMarksByLattice").
##  \item{-}
##      If the group is known to be solvable then `TableOfMarks' takes the
##      lattice of subgroups (see~"LatticeSubgroups") of the group
##      --which means that the lattice is computed if it is not yet stored--
##      and then computes the table of marks from it.
##      This method is also accessible via the global function
##      `TableOfMarksByLattice' (see~"TableOfMarksByLattice").
##  \item{-}
##      If the group doesn't know its lattice of subgroups or its conjugacy
##      classes of subgroups then the table of marks and the conjugacy
##      classes of subgroups are computed at the same time by the cyclic
##      extension method.
##      Only the table of marks is stored because the conjugacy classes of
##      subgroups or the lattice of subgroups can be easily read off
##      (see~"LatticeSubgroupsByTom").
##  \endlist
##
##  Conversely, the lattice of subgroups of a group with known table of marks
##  can be computed using the table of marks, via the function
##  `LatticeSubgroupsByTom'.
##  This is also installed as a method for `LatticeSubgroups'.
##


#############################################################################
##
#F  TableOfMarksByLattice( <G> )
##
##  `TableOfMarksByLattice' computes the table of marks of the group <G> from
##  the lattice of subgroups of <G>.
##  This lattice is computed via `LatticeSubgroups' (see~"LatticeSubgroups")
##  if it is not yet stored in <G>.
##  The function `TableOfMarksByLattice' is installed as a method for
##  `TableOfMarks' for solvable groups and groups with stored subgroup
##  lattice, and is available as a global variable only in order to provide
##  explicit access to this method.
##
DeclareGlobalFunction( "TableOfMarksByLattice" );


#############################################################################
##
#F  LatticeSubgroupsByTom( <G> )
##
##  `LatticeSubgroupsByTom' computes the lattice of subgroups of <G> from the
##  table of marks of <G>, using `RepresentativeTom'
##  (see~"RepresentativeTom").
##
DeclareGlobalFunction( "LatticeSubgroupsByTom" );


#############################################################################
##
##  5. Printing Tables of Marks
#5
##  \indextt{ViewObj!for tables of marks}
##  The default `ViewObj' (see~"ViewObj") method for tables of  marks  prints
##  the string `\"TableOfMarks\"', followed by --if  known--  the  identifier
##  (see~"Identifier!for tables of marks") or the group of the table of marks
##  enclosed in brackets; if neither group nor identifier are known then just
##  the number of conjugacy classes of subgroups is printed instead.
##
##  \indextt{PrintObj!for tables of marks}
##  The default `PrintObj' (see~"PrintObj") method for tables of marks
##  does the same as `ViewObj',
##  except that the group is is `Print'-ed instead of `View'-ed.
##
##  \indextt{Display!for tables of marks}
##  The default `Display' (see~"Display") method for a table of marks <tom>
##  produces a formatted output of the marks in <tom>.
##  Each line of output begins with the number of the corresponding class of
##  subgroups.
##  This number is repeated if the output spreads over several pages.
##  The number of columns printed at one time depends on the actual
##  line length, which can be accessed and changed by the function
##  `SizeScreen' (see~"SizeScreen").
##
##  The optional second argument <arec> of `Display' can be used to change
##  the default style for displaying a character as shown above.
##  <arec> must be a record, its relevant components are the following.
##
##  \beginitems
##  `classes' &
##      a list of class numbers to select only the rows and columns of the
##      matrix that correspond to this list for printing,
##
##  `form' &
##      one of the strings `\"subgroups\"', `\"supergroups\"';
##      in the former case, at position $(i,j)$ of the matrix the number of
##      conjugates of $H_j$ contained in $H_i$ is printed,
##      and in the latter case, at position $(i,j)$ the number of conjugates
##      of $H_i$ which contain $H_j$ is printed.
##  \enditems
##


#############################################################################
##
##  6. Sorting Tables of Marks
##


#############################################################################
##
#C  IsTableOfMarks( <obj> )
##
##  Each table of marks belongs to this category.
##
DeclareCategory( "IsTableOfMarks", IsObject );


#############################################################################
##
#O  SortedTom( <tom>, <perm> )
##
##  `SortedTom' returns a table of marks where the rows and columns of the
##  table of marks <tom> are reordered according to the permutation <perm>.
##
##  *Note* that in each table of marks in {\GAP},
##  the matrix of marks is assumed to have lower triangular shape
##  (see~"Table of Marks Objects in GAP").
##  If the permutation <perm> does *not* have this property then the
##  functions for tables of marks might return wrong results when applied to
##  the output of `SortedTom'.
##
##  The returned table of marks has only those attribute values stored that
##  are known for <tom> and listed in `TableOfMarksComponents'
##  (see~"TableOfMarksComponents").
##
DeclareOperation( "SortedTom", [ IsTableOfMarks, IsPerm ] );


#############################################################################
##
#A  PermutationTom( <tom> )
##
##  For the table of marks <tom> of the group $G$ stored as `UnderlyingGroup'
##  value of <tom> (see~"UnderlyingGroup!for tables of marks"),
##  `PermutationTom' is a permutation $\pi$ such that the $i$-th conjugacy
##  class of subgroups of $G$ belongs to the $i^\pi$-th column and row of
##  marks in <tom>.
##
##  This attribute value is bound only if <tom> was obtained from another
##  table of marks by permuting with `SortedTom' (see~"SortedTom"),
##  and there is no default method to compute its value.
##
##  The attribute is necessary because the original and the sorted table of
##  marks have the same identifier and the same group,
##  and information computed from the group may depend on the ordering of
##  marks, for example the fusion from the ordinary character table of $G$
##  into <tom>.
##
DeclareAttribute( "PermutationTom", IsTableOfMarks );


#############################################################################
##
##  7. Technical Details about Tables of Marks
##


#############################################################################
##
#V  InfoTom
##
##  is the info class for computations concerning tables of marks.
##
DeclareInfoClass( "InfoTom" );


#############################################################################
##
#V  TableOfMarksFamily
##
##  Each table of marks belongs to this family.
##
BindGlobal( "TableOfMarksFamily",
    NewFamily( "TableOfMarksFamily", IsTableOfMarks ) );


#############################################################################
##
#F  ConvertToTableOfMarks( <record> )
##
##  `ConvertToTableOfMarks' converts a record with components from
##  `TableOfMarksComponents' into a table of marks object with the
##  corresponding attributes.
##
DeclareGlobalFunction( "ConvertToTableOfMarks" );


#############################################################################
##
##  8. Attributes of Tables of Marks
##


#############################################################################
##
#A  MarksTom( <tom> ) . . . . . . . . . . . . . . . . . .  defining attribute
#A  SubsTom( <tom> )  . . . . . . . . . . . . . . . . . .  defining attribute
##
##  The matrix of marks (see~"More about Tables of Marks") of the table of
##  marks <tom> is stored in a compressed form where zeros are omitted,
##  using the attributes `MarksTom' and `SubsTom'.
##  If $M$ is the square matrix of marks of <tom> (see~"MatTom") then the
##  `SubsTom' value of <tom> is a list that contains at position $i$ the list
##  of all positions of nonzero entries of the $i$-th row of $M$, and the
##  `MarksTom' value of <tom> is a list that contains at position $i$ the
##  list of the corresponding marks.
##
##  `MarksTom' and `SubsTom' are defining attributes of tables of marks
##  (see~"Table of Marks Objects in GAP").
##  There is no default method for computing the `SubsTom' value,
##  and the default `MarksTom' method needs the values of `NrSubsTom' and
##  `OrdersTom' (see~"NrSubsTom", "OrdersTom").
##
DeclareAttribute( "MarksTom", IsTableOfMarks );
DeclareAttribute( "SubsTom", IsTableOfMarks );


#############################################################################
##
#A  NrSubsTom( <tom> )
#A  OrdersTom( <tom> )
##
##  Instead of storing the marks (see~"MarksTom") of the table of marks <tom>
##  one can use a matrix which contains at position $(i,j)$ the number of
##  subgroups of conjugacy class $j$ that are contained in one member of the
##  conjugacy class $i$.
##  These values are stored in the `NrSubsTom' value in the same way as
##  the marks in the `MarksTom' value.
##
##  `OrdersTom' returns a list that contains at position $i$ the order of a
##  representative of the $i$-th conjugacy class of subgroups of <tom>.
##
##  One can compute the `NrSubsTom' and `OrdersTom' values from the
##  `MarksTom' value of <tom> and vice versa.
##
DeclareAttribute( "NrSubsTom", IsTableOfMarks );
DeclareAttribute( "OrdersTom", IsTableOfMarks );


#############################################################################
##
#A  LengthsTom( <tom> )
##
##  For a table of marks <tom>, `LengthsTom' returns a list of the lengths of
##  the conjugacy classes of subgroups.
##
DeclareAttribute( "LengthsTom", IsTableOfMarks );


#############################################################################
##
#A  ClassTypesTom( <tom> )
##
##  `ClassTypesTom' distinguishes isomorphism types of the classes of
##  subgroups of the table of marks <tom> as far as this is possible
##  from the `SubsTom' and `MarksTom' values of <tom>.
##
##  Two subgroups are clearly not isomorphic if they have different orders.
##  Moreover, isomorphic subgroups must contain the same number of subgroups
##  of each type.
##
##  Each type is represented by a positive integer.
##  `ClassTypesTom' returns the list which contains for each class of
##  subgroups its corresponding type.
##
DeclareAttribute( "ClassTypesTom", IsTableOfMarks );


#############################################################################
##
#A  ClassNamesTom( <tom> )
##
##  `ClassNamesTom' constructs generic names for the conjugacy classes of
##  subgroups of the table of marks <tom>.
##  In general, the generic name of a class of non--cyclic subgroups consists
##  of three parts and has the form `\"(<o>)_{<t>}<l>\"',
##  where <o> indicates the order of the subgroup,
##  <t> is a number that distinguishes different types of subgroups of the
##  same order, and <l> is a letter that distinguishes classes of subgroups
##  of the same type and order.
##  The type of a subgroup is determined by the numbers of its subgroups of
##  other types (see~"ClassTypesTom").
##  This is slightly weaker than isomorphism.
##
##  The letter is omitted if there is only one class of subgroups of that
##  order and type,
##  and the type is omitted if there is only one class of that order.
##  Moreover, the braces `{}'  around the type are omitted if the type number
##  has only one digit.
##
##  For classes of cyclic subgoups, the parentheses round the order and the
##  type are omitted.
##  Hence the most general form of their generic names is `\"<o>,<l>\"'.
##  Again, the letter is omitted if there is only one class of cyclic
##  subgroups of that order.
##
DeclareAttribute( "ClassNamesTom", IsTableOfMarks );


#############################################################################
##
#A  FusionsTom( <tom> )
##
##  For a table of marks <tom>, `FusionsTom' is a list of fusions into  other
##  tables of marks. Each fusion is a list of length  two,  the  first  entry
##  being the `Identifier' (see~"Identifier!for tables of  marks")  value  of
##  the image table, the second entry being the list of images of  the  class
##  positions of <tom> in the image table.
##
##  This attribute is mainly used for tables of marks in the {\GAP} library
##  (see~"The Library of Tables of Marks").
##
DeclareAttribute( "FusionsTom", IsTableOfMarks, "mutable" );


#############################################################################
##
#A  UnderlyingGroup( <tom> )
##
##  `UnderlyingGroup' is used to access an underlying group that is stored on
##  the table of marks <tom>.
##  There is no default method to compute an underlying group if it is not
##  stored.
##
DeclareAttribute( "UnderlyingGroup", IsTableOfMarks );


#############################################################################
##
#A  IdempotentsTom( <tom> )
#A  IdempotentsTomInfo( <tom> )
##
##  `IdempotentsTom' encodes the idempotents of the integral Burnside ring
##  described by the table of marks <tom>.
##  The return value is a list $l$ of positive integers such that each row
##  vector describing a primitive idempotent has value $1$ at all positions
##  with the same entry in $l$, and $0$ at all other positions.
##
##  According to A.~Dress~\cite{Dre69} (see also~\cite{Pfe97}),
##  these idempotents correspond to the classes of perfect subgroups,
##  and each such idempotent is the characteristic function of all those
##  subgroups that arise by cyclic extension from the corresponding perfect
##  subgroup (see~"CyclicExtensionsTom").
##
##  `IdempotentsTomInfo' returns a record with components `fixpointvectors'
##  and `primidems', both bound to lists.
##  The $i$-th entry of the `fixpointvectors' list is the $0-1$-vector
##  describing the $i$-th primitive idempotent,
##  and the $i$-th entry of `primidems' is the decomposition of this
##  idempotent in the rows of <tom>.
##
DeclareAttribute( "IdempotentsTom", IsTableOfMarks );
DeclareAttribute( "IdempotentsTomInfo", IsTableOfMarks );


#############################################################################
##
#A  Identifier( <tom> )
##
##  The identifier of a table of marks <tom> is a string.
##  It is used for printing the table of marks
##  (see~"Printing Tables of Marks")
##  and in fusions between tables of marks (see~"FusionsTom").
##
##  If <tom> is a table of marks from the {\GAP} library of tables of marks
##  (see~"The Library of Tables of Marks") then it has an identifier,
##  and if <tom> was constructed from a group with `Name' value (see~"Name")
##  then this name is chosen as `Identifier' value.
##  There is no default method to compute an identifier in all other cases.
##
DeclareAttribute( "Identifier", IsTableOfMarks );


#############################################################################
##
#A  MatTom( <tom> )
##
##  `MatTom' returns the square matrix of marks
##  (see~"More about Tables of Marks") of the table of marks <tom> which is
##  stored in a compressed form using the attributes `MarksTom' and `SubsTom'
##  (see~"MarksTom").
##  This may need substantially more space than the values of `MarksTom' and
##  `SubsTom'.
##
DeclareAttribute( "MatTom", IsTableOfMarks );


#############################################################################
##
#A  MoebiusTom( <tom> )
##
##  `MoebiusTom' computes the M{\accent127 o}bius values both of the subgroup
##  lattice of the group $G$ with table of marks <tom> and of the poset of
##  conjugacy classes of subgroups of $G$.
##  It returns a record where the component
##  `mu' contains the M{\accent127 o}bius values of the subgroup lattice,
##  and the component `nu' contains the M{\accent127 o}bius values of the
##  poset.
##
##  Moreover, according to an observation of Isaacs et al.~(see~\cite{HIO89},
##  \cite{Pah93}), the values on the subgroup lattice often can be derived
##  from those of the poset of conjugacy classes.
##  These ``expected values'' are returned in the component `ex',
##  and the list of numbers of those subgroups where the expected value does
##  not coincide with the actual value are returned in the component `hyp'.
##  For the computation of these values, the position of the derived subgroup
##  of $G$ is needed (see~"DerivedSubgroupTom").
##  If it is not uniquely determined then the result does not have the
##  components `ex' and `hyp'.
##
DeclareAttribute( "MoebiusTom", IsTableOfMarks );


#############################################################################
##
#A  WeightsTom( <tom> )
##
##  `WeightsTom' extracts the *weights* from the table of marks <tom>,
##  i.e., the diagonal entries of the matrix of marks (see~"MarksTom"),
##  indicating the index of a subgroup in its normalizer.
##
DeclareAttribute( "WeightsTom", IsTableOfMarks );


#############################################################################
##
##  9. Properties of Tables of Marks
#6
##  For a table of marks <tom> of a group $G$, the following properties
##  have the same meaning as the corresponding properties for $G$.
##  Additionally, if a positive integer <sub> is given as the second argument
##  then the value of the corresponding property for the <sub>-th class of
##  subgroups of <tom> is returned.
##  \beginlist
##  \item{}
##      `IsAbelianTom( <tom>[, <sub>] )'\indextt{IsAbelianTom}
##  \item{}
##      `IsCyclicTom( <tom>[, <sub>] )'\indextt{IsCyclicTom}
##  \item{}
##      `IsNilpotentTom( <tom>[, <sub>] )'\indextt{IsNilpotentTom}
##  \item{}
##      `IsPerfectTom( <tom>[, <sub>] )'\indextt{IsPerfectTom}
##  \item{}
##      `IsSolvableTom( <tom>[, <sub>] )'\indextt{IsSolvableTom}
##  \endlist
##


#############################################################################
##
#A  IsAbelianTom( <tom> )
#O  IsAbelianTom( <tom>, <sub> )
##
##  `IsAbelianTom' tests if the underlying group of the table of marks
##  <tom> is abelian.
##  If a second argument <sub> is given then `IsAbelianTom' returns whether
##  the groups in the <sub>-th class of subgroups in <tom> are abelian.
##
DeclareAttribute( "IsAbelianTom", IsTableOfMarks );
DeclareOperation( "IsAbelianTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#A  IsCyclicTom( <tom> )
#O  IsCyclicTom( <tom>, <sub> )
##
##  `IsCyclicTom' tests if the underlying group of the table of marks
##  <tom> is cyclic.
##  If a second argument <sub> is given then `IsCyclicTom' returns whether
##  the groups in the <sub>-th class of subgroups in <tom> are cyclic.
##  A subgroup is cyclic if and only if the sum over the corresponding row of
##  the inverse table of marks is nonzero (see~\cite{Ker91}, page 125).
##  Thus we only have to decompose the corresponding idempotent.
##
DeclareAttribute( "IsCyclicTom", IsTableOfMarks );
DeclareOperation( "IsCyclicTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#A  IsNilpotentTom( <tom )
#O  IsNilpotentTom( <tom>, <sub> )
##
##  `IsNilpotentTom' tests if the underlying group of the table of marks
##  <tom> is nilpotent.
##  If a second argument <sub> is given then `IsNilpotentTom' returns whether
##  the groups in the <sub>-th class of subgroups in <tom> are nilpotent.
##
DeclareAttribute( "IsNilpotentTom", IsTableOfMarks );
DeclareOperation( "IsNilpotentTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#A  IsPerfectTom( <tom> )
#O  IsPerfectTom( <tom>, <sub> )
##
##  `IsPerfectTom' tests if the underlying group of the table of marks
##  <tom> is perfect.
##  If a second argument <sub> is given then `IsPerfectTom' returns whether
##  the groups in the <sub>-th class of subgroups in <tom> are perfect.
##
DeclareAttribute( "IsPerfectTom", IsTableOfMarks );
DeclareOperation( "IsPerfectTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#A  IsSolvableTom( <tom> )
#O  IsSolvableTom( <tom>, <sub> )
##
##  `IsSolvableTom' tests if the underlying group of the table of marks
##  <tom> is solvable.
##  If a second argument <sub> is given then `IsSolvableTom' returns whether
##  the groups in the <sub>-th class of subgroups in <tom> are solvable.
##
DeclareAttribute( "IsSolvableTom", IsTableOfMarks );
DeclareOperation( "IsSolvableTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
##  10. Other Operations for Tables of Marks
#7
##  \>IsInternallyConsistent( <tom> )!{for tables of marks} O
##
##  For a table of marks <tom>, `IsInternallyConsistent'
##  decomposes all tensor products of rows of <tom>.
##  It returns `true' if all decomposition numbers are nonnegative integers,
##  and `false' otherwise.
##  This provides a strong consistency check for a table of marks.
##


#############################################################################
##
#O  DerivedSubgroupTom( <tom>, <sub> )
#F  DerivedSubgroupsTom( <tom> )
##
##  For a table of marks <tom> and a positive integer <sub>,
##  `DerivedSubgroupTom' returns either a positive integer $i$ or a list $l$
##  of positive integers.
##  In the former case, the result means that the derived subgroups of the
##  subgroups in the <sub>-th class of <tom> lie in the $i$-th class.
##  In the latter case, the class of the derived subgroups could not be
##  uniquely determined, and the position of the class of derived subgroups
##  is an entry of $l$.
##
##  Values computed with `DerivedSubgroupTom' are stored using the attribute
##  `DerivedSubgroupsTomPossible' (see~"DerivedSubgroupsTomPossible").
##
##  `DerivedSubgroupsTom' is just the list of `DerivedSubgroupTom' values for
##  all values of <sub>.
##
DeclareOperation( "DerivedSubgroupTom", [ IsTableOfMarks, IsPosInt ] );

DeclareGlobalFunction( "DerivedSubgroupsTom");


#############################################################################
##
#A  DerivedSubgroupsTomPossible( <tom> )
#A  DerivedSubgroupsTomUnique( <tom> )
##
##  Let <tom> be a table of marks.
##  The value of the attribute `DerivedSubgroupsTomPossible' is a list
##  in which the value at position $i$ --if bound-- is a positive integer or
##  a list; the meaning of the entry is the same as in `DerivedSubgroupTom'
##  (see~"DerivedSubgroupTom").
##
##  If the value of the attribute `DerivedSubgroupsTomUnique' is known for
##  <tom> then it is a list of positive integers, the value at position $i$
##  being the position of the class of derived subgroups of the $i$-th class
##  of subgroups in <tom>.
##  The derived subgroups are in general not uniquely determined by the table
##  of marks if no `UnderlyingGroup' value is stored,
##  so there is no default method for `DerivedSubgroupsTomUnique'.
##  But in some cases the derived subgroups are explicitly set when the table
##  of marks is constructed.
##  The `DerivedSubgroupsTomUnique' value is automatically set when the last
##  missing unique value is entered in the `DerivedSubgroupsTomPossible' list
##  by `DerivedSubgroupTom'.
##
DeclareAttribute( "DerivedSubgroupsTomPossible", IsTableOfMarks, "mutable" );
DeclareAttribute( "DerivedSubgroupsTomUnique", IsTableOfMarks );


#############################################################################
##
#O  NormalizerTom( <tom>, <sub> )
#A  NormalizersTom( <tom> )
##
##  Let <tom> be the table of marks of a group $G$, say.
##  `NormalizerTom' tries to find the conjugacy class of the normalizer $N$
##  in $G$ of a subgroup $U$ in the <sub>-th class of <tom>.
##  The return value is either the list of class numbers of those subgroups
##  that have the right size and contain the subgroup and all subgroups that
##  clearly contain it as a normal subgroup, or the class number of the
##  normalizer if it is uniquely determined by these conditions.
##  If <tom> knows the subgroup lattice of $G$ (see~"IsTableOfMarksWithGens")
##  then all normalizers are uniquely determined.
##  `NormalizerTom' should never return an empty list.
##
##  `NormalizersTom' returns the list of positions of the classes of
##  normalizers of subgroups in <tom>.
##  In addition to the criteria for a single class of subgroup used by
##  `NormalizerTom', the approximations of normalizers for several classes
##  are used and thus `NormalizersTom' may return better approximations
##  than `NormalizerTom'.
##
DeclareOperation( "NormalizerTom", [ IsTableOfMarks, IsPosInt ] );
DeclareAttribute( "NormalizersTom", IsTableOfMarks );


#############################################################################
##
#O  ContainedTom( <tom>, <sub1>, <sub2> )
##
##  `ContainedTom' returns the number of subgroups in class <sub1> of the
##  table of marks <tom> that are contained in one fixed member of the class
##  <sub2>.
##
DeclareOperation( "ContainedTom", [IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  ContainingTom( <tom>, <sub1>, <sub2> )
##
##  `ContainingTom' returns the number of subgroups in class <sub2> of the
##  table of marks <tom> that contain one fixed member of the class <sub1>.
##
DeclareOperation( "ContainingTom", [ IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#A  CyclicExtensionsTom( <tom> )
#O  CyclicExtensionsTom( <tom>, <p> )
#O  CyclicExtensionsTom( <tom>, <list> )
##
##  According to A.~Dress~\cite{Dre69}, two columns of the table of marks
##  <tom> are equal modulo the prime <p> if and only if the corresponding
##  subgroups are connected by a chain of normal extensions of order <p>.
##
##  In the second form, `CyclicExtensionsTom' returns the classes of this
##  equivalence relation.
##  In the third form, <list> must be a list of primes, and the return value
##  is the list of classes of the relation obtained by considering chains of
##  normal extensions of prime order where all primes are in <list>.
##  In the first form, the result is the same as in the third form,
##  with second argument the set of prime divisors of the size of the group
##  of <tom>.
##
##  (This information is not used by `NormalizerTom' (see~"NormalizerTom")
##  although it might give additional restrictions in the search of
##  normalizers.)
##
DeclareAttribute( "CyclicExtensionsTom", IsTableOfMarks );
DeclareOperation( "CyclicExtensionsTom", [ IsTableOfMarks, IsPosInt ] );
DeclareOperation( "CyclicExtensionsTom", [ IsTableOfMarks, IsList ] );


#############################################################################
##
#A  ComputedCyclicExtensionsTom( <tom> )
#O  CyclicExtensionsTomOp( <tom>, <p> )
#O  CyclicExtensionsTomOp( <tom>, <list> )
##
##  The attribute `ComputedCyclicExtensionsTom' is used by the default
##  `CyclicExtensionsTom' method to store the computed equivalence classes
##  for the table of marks <tom> and access them in subsequent calls.
##
##  The operation `CyclicExtensionsTomOp' does the real work for
##  `CyclicExtensionsTom'.
##
DeclareAttribute( "ComputedCyclicExtensionsTom", IsTableOfMarks, "mutable" );
DeclareOperation( "CyclicExtensionsTomOp", [ IsTableOfMarks, IsPosInt ] );
DeclareOperation( "CyclicExtensionsTomOp", [ IsTableOfMarks, IsList ] );


#############################################################################
##
#O  DecomposedFixedPointVector( <tom>, <fix> )
##
##  Let <tom> be the table of marks of the group $G$, say,
##  and let <fix> be a vector of fixed point numbers w.r.t.~an action of $G$,
##  i.e., a vector which contains for each class of subgroups the number of
##  fixed points under the given action.
##  `DecomposedFixedPointVector' returns the decomposition of <fix> into rows
##  of the table of marks.
##  This decomposition  corresponds to a decomposition of the action into
##  transitive constituents.
##  Trailing zeros in <fix> may be omitted.
##
DeclareOperation( "DecomposedFixedPointVector",
    [ IsTableOfMarks, IsList ] );


#############################################################################
##
#O  EulerianFunctionByTom( <tom>, <n>[, <sub>] )
##
##  In the first form `EulerianFunctionByTom' computes the Eulerian
##  function (see~"EulerianFunction") of the underlying group $G$ of the
##  table of marks <tom>,
##  that is, the number of <n>-tuples of elements in $G$ that generate $G$.
##  In the secon form `EulerianFunctionByTom' computes the Eulerian function
##  of each subgroup in the <sub>-th class of subgroups of <tom>.
##
##  For a group $G$ whose table of marks is known, `EulerianFunctionByTom'
##  is installed as a method for `EulerianFunction' (see~"EulerianFunction").
##
DeclareOperation( "EulerianFunctionByTom", [ IsTableOfMarks, IsPosInt ] );
DeclareOperation( "EulerianFunctionByTom",
    [ IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  IntersectionsTom( <tom>, <sub1>, <sub2> )
##
##  The intersections of the groups in the <sub1>-th conjugacy class of
##  subgroups of the table of marks <tom> with the groups in the <sub2>-th
##  conjugacy classes of subgroups of <tom> are determined up to conjugacy by
##  the decomposition of the tensor product of their rows of marks.
##  `IntersectionsTom' returns a list $l$ that describes this decomposition.
##  The $i$-th entry in $l$ is the multiplicity of groups in the
##  $i$-th conjugacy class as an intersection.
##
DeclareOperation( "IntersectionsTom",
    [ IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  FactorGroupTom( <tom>, <n> )
##
##  For a table of marks <tom> of the group $G$, say,
##  and the normal subgroup $N$ of $G$ corresponding to the <n>-th class of
##  subgroups of <tom>,
##  `FactorGroupTom' returns the table of marks of the factor
##  group $G / N$.
##
DeclareOperation( "FactorGroupTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#A  MaximalSubgroupsTom( <tom> )
#O  MaximalSubgroupsTom( <tom>, <sub> )
##
##  In the first form `MaximalSubgroupsTom' returns a list of length two,
##  the first entry being the list of positions of the classes of maximal
##  subgroups of the whole group of the table of marks <tom>,
##  the second entry being the list of class lengths of these groups.
##  In the second form the same information for the <sub>-th class of
##  subgroups is returned.
##
DeclareAttribute( "MaximalSubgroupsTom", IsTableOfMarks );
DeclareOperation( "MaximalSubgroupsTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#O  MinimalSupergroupsTom( <tom>, <sub> )
##
##  For a table of marks <tom>, `MinimalSupergroupsTom' returns a list of
##  length two, the first entry being the list of positions of the classes
##  containing the minimal supergroups of the groups in the <sub>-th class
##  of subgroups of <tom>,
##  the second entry being the list of class lengths of these groups.
##
DeclareOperation( "MinimalSupergroupsTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
##  11. Accessing Subgroups via Tables of Marks
#8
##  Let <tom> be the table of marks of the group $G$,
##  and assume that <tom> has access to $G$ via the `UnderlyingGroup' value
##  (see~"UnderlyingGroup!for tables of marks").
##  Then it makes sense to use <tom> and its ordering of conjugacy classes of
##  subgroups of $G$ for storing information for constructing representatives
##  of these classes.
##  The group $G$ is in general not sufficient for this,
##  <tom> needs more information;
##  this is available if and only if the `IsTableOfMarksWithGens' value of
##  <tom> is `true' (see~"IsTableOfMarksWithGens").
##  In this case, `RepresentativeTom' (see~"RepresentativeTom") can be used
##  to get a subgroup of the $i$-th class, for all $i$.
##
##  {\GAP} provides two different possibilities to store generators of the
##  representatives of classes of subgroups.
##  The first is implemented by the attribute `GeneratorsSubgroupsTom'
##  (see~"GeneratorsSubgroupsTom"), which uses explicit generators.
##  The second, more general, possibility is implemented by the attributes
##  `StraightLineProgramsTom' (see~"StraightLineProgramsTom") and
##  `StandardGeneratorsInfo' (see~"StandardGeneratorsInfo!for tables of marks").
##  The `StraightLineProgramsTom' value encodes the generators as 
##  straight line programs (see~"Straight Line Programs") that evaluate to
##  the generators in question when applied to standard generators of $G$.
##  This means that on the one hand, standard generators of $G$ must be known
##  in order to use `StraightLineProgramsTom'.
##  On the other hand, the straight line programs allow one to compute easily
##  generators not only of a subgroup $U$ of $G$ but also generators of the
##  image of $U$ in any representation of $G$, provided that one knows
##  standard generators of the image of $G$ under this representation
##  (see~"RepresentativeTomByGenerators" for details and an example).
##


#############################################################################
##
#A  GeneratorsSubgroupsTom( <tom> )
##
##  Let <tom> be a table of marks with `IsTableOfMarksWithGens' value `true'.
##  Then `GeneratorsSubgroupsTom' returns a list of length two,
##  the first entry being a list $l$ of elements of the group stored as
##  `UnderlyingGroup' value of <tom>,
##  the second entry being a list that contains at position $i$ a list of
##  positions in $l$ of generators of a representative of a subgroup in class
##  $i$.
##
##  The `GeneratorsSubgroupsTom' value is known for all tables of marks that
##  have been computed with `TableOfMarks' (see~"TableOfMarks") from a group,
##  and there is a method to compute the value for a table of marks that
##  admits `RepresentativeTom' (see~"RepresentativeTom").
##
DeclareAttribute( "GeneratorsSubgroupsTom", IsTableOfMarks );


#############################################################################
##
#A  StraightLineProgramsTom( <tom> )
##
##  For a table of marks <tom> with `IsTableOfMarksWithGens' value `true',
##  `StraightLineProgramsTom' returns a list that contains at position $i$
##  either a list of straight line programs or a straight line program
##  (see~"Straight Line Programs"), encoding the generators of
##  a representative of the $i$-th conjugacy class of subgroups of
##  `UnderlyingGroup( <tom> )';
##  in the former case, each straight line program returns a generator,
##  in the latter case, the program returns the list of generators.
##
##  There is no default method to compute the `StraightLineProgramsTom' value
##  of a table of marks if they are not yet stored.
##  The value is known for all tables of marks that belong to the
##  {\GAP} library of tables of marks (see~"The Library of Tables of Marks").
##
DeclareAttribute( "StraightLineProgramsTom", IsTableOfMarks );


#############################################################################
##
#A  WordsTom( <tom> )
##
##  Let <tom> be a table of marks with `IsTableOfMarksWithGens' value `true'.
##  Then `WordsTom' returns a list that contains at position $i$ a list of
##  words in abstract generators that encode generators of a representative
##  of the $i$-th conjugacy class of subgroups of `UnderlyingGroup( <tom> )'.
#T No!
#T These "words" that are in fact wordlists are evaluated by
#T `ResultOfStraightLineProgram'.
##
##  *WordsTom is obsolete, use StraightLineProgramsTom instead!*
##
DeclareAttribute( "WordsTom", IsTableOfMarks );


#############################################################################
##
#A  StandardGeneratorsInfo( <tom> )
##
##  For a table of marks <tom>, a stored  value  of  `StandardGeneratorsInfo'
##  equals  the  value  of  this   attribute   for   the   underlying   group
##  (see~"UnderlyingGroup!for     tables     of     marks")     of     <tom>,
##  cf.~Section~"Standard Generators of Groups".
##
##  In this case, the `GeneratorsOfGroup' value of the underlying group $G$
##  of <tom> is assumed to be in fact a list of standard generators for $G$;
##  So one should be careful when setting the `StandardGeneratorsInfo' value
##  by hand.
##
##  There is no default method to compute the `StandardGeneratorsInfo' value
##  of a table of marks if it is not yet stored.
##
DeclareAttribute( "StandardGeneratorsInfo", IsTableOfMarks );


#############################################################################
##
#F  IsTableOfMarksWithGens( <tom> )
##
##  This filter shall express the union of the filters
##  `IsTableOfMarks and HasStraightLineProgramsTom' and
##  `IsTableOfMarks and HasGeneratorsSubgroupsTom'.
##  If a table of marks <tom> has this filter set then <tom> can be asked to
##  compute information that is in general not uniquely determined by a table
##  of marks,
##  for example the positions of derived subgroups or normalizers of
##  subgroups (see~"DerivedSubgroupTom", "NormalizerTom").
##
DeclareFilter( "IsTableOfMarksWithGens" );

InstallTrueMethod( IsTableOfMarksWithGens,
    IsTableOfMarks and HasStraightLineProgramsTom );
InstallTrueMethod( IsTableOfMarksWithGens,
    IsTableOfMarks and HasGeneratorsSubgroupsTom);


#############################################################################
##
#O  RepresentativeTom( <tom>, <sub> )
#O  RepresentativeTomByGenerators( <tom>, <sub>, <gens> )
#O  RepresentativeTomByGeneratorsNC( <tom>, <sub>, <group> )
##
##  Let <tom> be a table of marks with `IsTableOfMarksWithGens' value `true'
##  (see~"IsTableOfMarksWithGens"), and <sub> a positive integer.
##  `RepresentativeTom' returns a representative of the <sub>-th conjugacy
##  class of subgroups of <tom>.
##
##  `RepresentativeTomByGenerators' and `RepresentativeTomByGeneratorsNC'
##  return a representative of the <sub>-th conjugacy class of subgroups of
##  <tom>, as a subgroup of the group generated by <gens>.
##  This means that the standard generators of <tom> are replaced by <gens>.
##
##  `RepresentativeTomByGenerators' checks whether mapping the standard
##  generators of <tom> to <gens> extends to a group isomorphism,
##  and returns `fail' if not.
##  `RepresentativeTomByGeneratorsNC' omits all checks.
##  So `RepresentativeTomByGenerators' is thought mainly for debugging
##  purposes;
##  note that when several representatives are constructed, it is cheaper to
##  construct (and check) the isomorphism once, and to map the groups
##  returned by `RepresentativeTom' under this isomorphism.
##  The idea behind `RepresentativeTomByGeneratorsNC', however, is to avoid
##  the overhead of using isomorphisms when <gens> are known to be standard
##  generators.
##
DeclareOperation( "RepresentativeTom", [ IsTableOfMarks, IsPosInt ] );

DeclareOperation( "RepresentativeTomByGenerators",
    [ IsTableOfMarks and HasStraightLineProgramsTom, IsPosInt,
      IsHomogeneousList ] );

DeclareOperation( "RepresentativeTomByGeneratorsNC",
    [ IsTableOfMarks and HasStraightLineProgramsTom, IsPosInt,
      IsHomogeneousList ] );


#############################################################################
##
##  12. The Interface between Tables of Marks and Character Tables
##


#############################################################################
##
#O  FusionCharTableTom( <tbl>, <tom> )  . . . . . . . . . . .  element fusion
#O  PossibleFusionsCharTableTom( <tbl>, <tom>[, <quick>] )  .  element fusion
##
##  Let <tbl> be the ordinary character table of the group $G$, and <tom> the
##  table of marks of $G$.
##  `FusionCharTableTom' determines the fusion of the classes of elements
##  from <tbl> to the classes of cyclic subgroups on <tom>, that is,
##  a list that contains at position $i$ the position of the class of cyclic
##  subgroups in <tom> that are generated by elements in the $i$-th conjugacy
##  class of elements in <tbl>.
##
##  Three cases are handled differently.
##  \beginlist
##  \item{1.}
##       The fusion is explicitly stored on <tbl>.
##       Then nothing has to be done.
##       This happens only if both <tbl> and <tom> are tables from the {\GAP}
##       library (see~"The Library of Tables of Marks" and the manual of
##       the {\GAP} Character Table Library).
##  \item{2.}
##       The `UnderlyingGroup' values of <tbl> and <tom> are known and
##       equal.
##       Then the group is used to compute the fusion.
##  \item{3.}
##       There is neither fusion nor group information available.
##       In this case only necessary conditions can be checked,
##       and if they are not sufficient to detemine the fusion uniquely then
##       `fail' is returned by `FusionCharTableTom'.
##  \endlist
##
##  `PossibleFusionsCharTableTom' computes the list of possible fusions from
##  <tbl> to <tom>, according to the criteria that have been checked.
##  So if `FusionCharTableTom' returns a unique fusion then the list returned
##  by `PossibleFusionsCharTableTom' for the same arguments contains exactly
##  this fusion,
##  and if `FusionCharTableTom' returns `fail' then the length of this list
##  is different from $1$.
##  The optional argumanet <quick>, a boolean, indicates whether a unique
##  fusion shall be returned as soon as it has been determined,
##  without further checks.
##  The default value of <quick> is `false'.
##
DeclareOperation( "FusionCharTableTom",
    [ IsOrdinaryTable, IsTableOfMarks ] );

DeclareOperation( "PossibleFusionsCharTableTom",
    [ IsOrdinaryTable, IsTableOfMarks ] );

DeclareOperation( "PossibleFusionsCharTableTom",
    [ IsOrdinaryTable, IsTableOfMarks, IsBool ] );


#############################################################################
##
#O  PermCharsTom( <fus>, <tom> )
#O  PermCharsTom( <tbl>, <tom> )
##
##  `PermCharsTom' returns the list of transitive permutation characters
##  from the table of marks <tom>.
##  In the first form, <fus> must be the fusion map from the ordinary
##  character table of the group of <tom> to <tom>
##  (see~"FusionCharTableTom").
##  In the second form, <tbl> must be the character table of the group of
##  which <tom> is the table of marks.
##  If the fusion map is not uniquely determined (see~"FusionCharTableTom")
##  then `fail' is returned.
##
##  If the fusion map <fus> is given as first argument then each transitive
##  permutation character is represented by its values list.
##  If the character table <tbl> is given then the permutation characters are
##  class function objects (see Chapter~"Class Functions").
##
DeclareOperation( "PermCharsTom", [ IsList, IsTableOfMarks ] );
DeclareOperation( "PermCharsTom", [ IsOrdinaryTable, IsTableOfMarks ] );


#############################################################################
##
##  13. Generic Construction of Tables of Marks
#9
##  The following three operations construct a table of marks only from the
##  data given, i.e., without underlying group.
##


#############################################################################
##
#O  TableOfMarksCyclic( <n> )
##
##  `TableOfMarksCyclic' returns the table of marks of the cyclic group
##  of order <n>.
##
##  A cyclic group of order <n> has as its subgroups for each divisor $d$
##  of <n> a cyclic subgroup of order $d$.
##
DeclareOperation( "TableOfMarksCyclic", [ IsPosInt ] );


#############################################################################
##
#O  TableOfMarksDihedral( <n> )
##
##  `TableOfMarksDihedral' returns the table of marks of the dihedral group
##  of order <m>.
##
##  For each divisor $d$ of <m>, a dihedral group of order $m = 2n$ contains
##  subgroups of order $d$ according to the following rule.
##  If $d$ is odd and divides $n$ then there is only one cyclic subgroup of
##  order $d$.
##  If $d$ is even and divides $n$ then there are a cyclic subgroup of order
##  $d$ and two classes of dihedral subgroups of order $d$
##  (which are cyclic, too, in the case $d = 2$, see the example below).
##  Otherwise (i.e., if $d$ does not divide $n$) there is just one class of
##  dihedral subgroups of order $d$.
##
DeclareOperation( "TableOfMarksDihedral", [ IsPosInt ] );


#############################################################################
##
#O  TableOfMarksFrobenius( <p>, <q> )
##
##  `TableOfMarksFrobenius' computes the table of marks of a Frobenius group
##  of order $p q$, where $p$ is a prime and $q$ divides $p-1$.
##
DeclareOperation( "TableOfMarksFrobenius", [ IsPosInt, IsPosInt ] );


#############################################################################
##
#V  TableOfMarksComponents
##
##  The list `TableOfMarksComponents' is used when a table of marks object is
##  created from a record via `ConvertToTableOfMarks'
##  (see~"ConvertToTableOfMarks").
##  `TableOfMarksComponents' contains at position $2i-1$ a name of an
##  attribute and at position $2i$ the corresponding attribute getter
##  function.
##
BindGlobal( "TableOfMarksComponents", [
      "Identifier",                 Identifier,
      "SubsTom",                    SubsTom,
      "MarksTom",                   MarksTom,
      "NrSubsTom",                  NrSubsTom,
      "OrdersTom",                  OrdersTom,
      "NormalizersTom",             NormalizersTom,
      "DerivedSubgroupsTomUnique",  DerivedSubgroupsTomUnique,
      "UnderlyingGroup",            UnderlyingGroup,
      "WordsTom",                   WordsTom,
      "StraightLineProgramsTom",    StraightLineProgramsTom,
      "GeneratorsSubgroupsTom",     GeneratorsSubgroupsTom,
      "StandardGeneratorsInfo",     StandardGeneratorsInfo,
      "PermutationTom",             PermutationTom,
      "ClassNamesTom",              ClassNamesTom,
    ] );


#############################################################################
##
#E

