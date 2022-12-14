#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Götz Pfeiffer, Thomas Merkwitz.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations of the category and family of tables
##  of marks, and their properties, attributes, operations and functions.
##
##  1. Tables of Marks
##  2. More about Tables of Marks
##  3. Table of Marks Objects in &GAP;
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


#############################################################################
##
##  1. Tables of Marks
##
##  <#GAPDoc Label="[1]{tom}">
##  The concept of a <E>table of marks</E> was introduced by W.&nbsp;Burnside
##  in his book <Q>Theory of Groups of Finite Order</Q>,
##  see&nbsp;<Cite Key="Bur55"/>.
##  Therefore a table of marks is sometimes called a <E>Burnside matrix</E>.
##  <P/>
##  The table of marks of a finite group <M>G</M> is a matrix whose rows and
##  columns are labelled by the conjugacy classes of subgroups of <M>G</M>
##  and where for two subgroups <M>A</M> and <M>B</M> the <M>(A, B)</M>-entry
##  is the number of fixed points of <M>B</M> in the transitive action of
##  <M>G</M> on the cosets of <M>A</M> in <M>G</M>.
##  So the table of marks characterizes the set of all permutation
##  representations of <M>G</M>.
##  <P/>
##  Moreover, the table of marks gives a compact description of the subgroup
##  lattice of <M>G</M>, since from the numbers of fixed points the numbers
##  of conjugates of a subgroup <M>B</M> contained in a subgroup <M>A</M>
##  can be derived.
##  <P/>
##  A table of marks of a given group <M>G</M> can be constructed from the
##  subgroup lattice of <M>G</M>
##  (see&nbsp;<Ref Sect="Constructing Tables of Marks"/>).
##  For several groups, the table of marks can be restored from the &GAP;
##  library of tables of marks
##  (see&nbsp;<Ref Sect="The Library of Tables of Marks"/>).
##  <P/>
##  Given the table of marks of <M>G</M>, one can display it
##  (see&nbsp;<Ref Sect="Printing Tables of Marks"/>)
##  and derive information about <M>G</M> and its Burnside ring from it
##  (see&nbsp;<Ref Sect="Attributes of Tables of Marks"/>,
##  <Ref Sect="Properties of Tables of Marks"/>,
##  <Ref Sect="Other Operations for Tables of Marks"/>).
##  Moreover, tables of marks in &GAP; provide an easy access to the classes
##  of subgroups of their underlying groups
##  (see&nbsp;<Ref Sect="Accessing Subgroups via Tables of Marks"/>).
##  <#/GAPDoc>
##


#############################################################################
##
##  2. More about Tables of Marks
##
##  <#GAPDoc Label="[2]{tom}">
##  Let <M>G</M> be a finite group with <M>n</M> conjugacy classes of
##  subgroups <M>C_1, C_2, \ldots, C_n</M> and representatives
##  <M>H_i \in C_i</M>, <M>1 \leq i \leq n</M>.
##  The <E>table of marks</E> of <M>G</M> is defined to be the
##  <M>n \times n</M> matrix <M>M = (m_{ij})</M> where the
##  <E>mark</E> <M>m_{ij}</M> is the number of fixed points of the subgroup
##  <M>H_j</M> in the action of <M>G</M> on the right cosets of <M>H_i</M>
##  in <M>G</M>.
##  <P/>
##  Since <M>H_j</M> can only have fixed points if it is contained in a point
##  stabilizer the matrix <M>M</M> is lower triangular if the classes
##  <M>C_i</M> are sorted according to the condition that if <M>H_i</M>
##  is contained in a conjugate of <M>H_j</M> then <M>i \leq j</M>.
##  <P/>
##  Moreover, the diagonal entries <M>m_{ii}</M> are nonzero
##  since <M>m_{ii}</M> equals the index of <M>H_i</M> in its normalizer
##  in <M>G</M>.  Hence <M>M</M> is invertible.
##  Since any transitive action of <M>G</M> is equivalent to an action on the
##  cosets of a subgroup of <M>G</M>, one sees that the table of marks
##  completely characterizes the set of all permutation representations of
##  <M>G</M>.
##  <P/>
##  The marks <M>m_{ij}</M> have further meanings.
##  If <M>H_1</M> is the trivial subgroup of <M>G</M> then each mark
##  <M>m_{i1}</M> in the first column of <M>M</M> is equal to the index of
##  <M>H_i</M> in <M>G</M> since the trivial subgroup fixes all cosets of
##  <M>H_i</M>.
##  If <M>H_n = G</M> then each <M>m_{nj}</M> in the last row of <M>M</M> is
##  equal to <M>1</M> since there is only one coset of <M>G</M> in <M>G</M>.
##  In general, <M>m_{ij}</M> equals the number of conjugates of <M>H_i</M>
##  containing <M>H_j</M>, multiplied by the index of <M>H_i</M> in its
##  normalizer in <M>G</M>.
##  Moreover, the number <M>c_{ij}</M> of conjugates of <M>H_j</M> which are
##  contained in <M>H_i</M> can be derived from the marks <M>m_{ij}</M> via
##  the formula
##  <Display Mode="M">
##  c_{ij} = ( m_{ij} m_{j1} ) / ( m_{i1} m_{jj} )
##  </Display>.
##  <P/>
##  Both the marks <M>m_{ij}</M>  and the numbers of subgroups <M>c_{ij}</M>
##  are needed for the functions described in this chapter.
##  <P/>
##  A brief survey of properties of tables of marks and a description of
##  algorithms for the interactive construction of tables of marks using
##  &GAP; can be found in&nbsp;<Cite Key="Pfe97"/>.
##  <#/GAPDoc>
##


#############################################################################
##
##  3. Table of Marks Objects in &GAP;
##
##  <#GAPDoc Label="[3]{tom}">
##  A table of marks of a group <M>G</M> in &GAP; is represented by an
##  immutable (see&nbsp;<Ref Sect="Mutability and Copyability"/>) object
##  <A>tom</A> in the category <Ref Filt="IsTableOfMarks"/>,
##  with defining attributes <Ref Attr="SubsTom"/> and
##  <Ref Attr="MarksTom"/>.
##  These two attributes encode the matrix of marks in a compressed form.
##  The <Ref Attr="SubsTom"/> value of <A>tom</A> is a list where for each
##  conjugacy class of subgroups the class numbers of its subgroups are
##  stored.
##  These are exactly the positions in the corresponding row of the matrix of
##  marks which have nonzero entries.
##  The marks themselves are stored via the <Ref Attr="MarksTom"/> value of
##  <A>tom</A>, which is a list that contains for each entry in
##  <C>SubsTom( <A>tom</A> )</C> the corresponding nonzero value of the
##  table of marks.
##  <P/>
##  It is possible to create table of marks objects that do not store a
##  group, moreover one can create a table of marks object from a matrix of
##  marks (see&nbsp;<Ref Attr="TableOfMarks" Label="for a matrix"/>).
##  So it may happen that a table of marks object in &GAP; is in fact
##  <E>not</E> the table of marks of a group.
##  To some extent, the consistency of a table of marks object can be checked
##  (see&nbsp;<Ref Sect="Other Operations for Tables of Marks"/>),
##  but &GAP; knows no general way to prove or disprove that a given matrix
##  of nonnegative integers is the matrix of marks for a group.
##  Many functions for tables of marks work well without access to the group
##  &ndash;this is one of the arguments why tables of marks are so
##  useful&ndash;,
##  but for example normalizers (see&nbsp;<Ref Oper="NormalizerTom"/>)
##  and derived subgroups (see&nbsp;<Ref Oper="DerivedSubgroupTom"/>) of
##  subgroups are in general not uniquely determined by the matrix of marks.
##  <P/>
##  &GAP; tables of marks are assumed to be in lower triangular form,
##  that is, if a subgroup from the conjugacy class corresponding to the
##  <M>i</M>-th row is contained in a subgroup from the class corresponding
##  to the <M>j</M>-th row j then <M>i \leq j</M>.
##  <P/>
##  The <Ref Attr="MarksTom"/> information can be computed from the values of
##  the attributes <Ref Attr="NrSubsTom"/>, <Ref Attr="LengthsTom"/>,
##  <Ref Attr="OrdersTom"/>, and <Ref Attr="SubsTom"/>.
##  <Ref Attr="NrSubsTom"/> stores a list containing for each entry in the
##  <Ref Attr="SubsTom"/> value the corresponding number of conjugates that
##  are contained in a subgroup,
##  <Ref Attr="LengthsTom"/> a list containing for each conjugacy class
##  of subgroups its length,
##  and <Ref Attr="OrdersTom"/> a list containing for each class of subgroups
##  their order.
##  So the <Ref Attr="MarksTom"/> value of <A>tom</A> may be missing
##  provided that the values of <Ref Attr="NrSubsTom"/>,
##  <Ref Attr="LengthsTom"/>, and <Ref Attr="OrdersTom"/> are stored in
##  <A>tom</A>.
##  <P/>
##  Additional information about a table of marks is needed by some
##  functions.
##  The class numbers of normalizers in <M>G</M> and the number of the
##  derived subgroup of <M>G</M> can be stored via appropriate attributes
##  (see&nbsp;<Ref Attr="NormalizersTom"/>,
##  <Ref Oper="DerivedSubgroupTom"/>).
##  <P/>
##  If <A>tom</A> stores its group <M>G</M> and a bijection from the rows and
##  columns of the matrix of marks of <A>tom</A> to the classes of subgroups
##  of <M>G</M> then clearly normalizers, derived subgroup etc.&nbsp;can be
##  computed from this information.
##  But in general a table of marks need not have access to <M>G</M>,
##  for example <A>tom</A> might have been constructed from a generic table
##  of marks
##  (see&nbsp;<Ref Sect="Generic Construction of Tables of Marks"/>),
##  or as table of marks of a factor group from a given table of marks
##  (see&nbsp;<Ref Oper="FactorGroupTom"/>).
##  Access to the group <M>G</M> is provided by the attribute
##  <Ref Attr="UnderlyingGroup" Label="for tables of marks"/>
##  if this value is set.
##  Access to the relevant information about conjugacy classes of subgroups
##  of <M>G</M>
##  &ndash;compatible with the ordering of rows and columns of the marks in
##  <A>tom</A>&ndash; is signalled by the filter
##  <Ref Filt="IsTableOfMarksWithGens"/>.
##  <#/GAPDoc>
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
##  <#GAPDoc Label="TableOfMarks">
##  <ManSection>
##  <Attr Name="TableOfMarks" Arg='G' Label="for a group"/>
##  <Attr Name="TableOfMarks" Arg='string' Label="for a string"/>
##  <Attr Name="TableOfMarks" Arg='matrix' Label="for a matrix"/>
##
##  <Description>
##  In the first form, <A>G</A> must be a finite group,
##  and <Ref Attr="TableOfMarks" Label="for a group"/>
##  constructs the table of marks of <A>G</A>.
##  This computation requires the knowledge of the complete subgroup lattice
##  of <A>G</A> (see&nbsp;<Ref Attr="LatticeSubgroups"/>).
##  If the lattice is not yet stored then it will be constructed.
##  This may take a while if <A>G</A> is large.
##  The result has the <Ref Filt="IsTableOfMarksWithGens"/> value
##  <K>true</K>.
##  <P/>
##  In the second form, <A>string</A> must be a string,
##  and <Ref Attr="TableOfMarks" Label="for a string"/> gets
##  the table of marks with name <A>string</A> from the &GAP; library
##  (see <Ref Sect="The Library of Tables of Marks"/>).
##  If no table of marks with this name is contained in the library then
##  <K>fail</K> is returned.
##  <P/>
##  In the third form, <A>matrix</A> must be a matrix or a list of rows
##  describing a lower triangular matrix where the part above the diagonal is
##  omitted.
##  For such an argument <A>matrix</A>,
##  <Ref Attr="TableOfMarks" Label="for a matrix"/> returns
##  a table of marks object
##  (see&nbsp;<Ref Sect="Table of Marks Objects in GAP"/>)
##  for which <A>matrix</A> is the matrix of marks.
##  Note that not every matrix
##  (containing only nonnegative integers and having lower triangular shape)
##  describes a table of marks of a group.
##  Necessary conditions are checked with
##  <Ref Meth="IsInternallyConsistent" Label="for tables of marks"/>
##  (see&nbsp;<Ref Sect="Other Operations for Tables of Marks"/>),
##  and <K>fail</K> is returned if <A>matrix</A> is proved not to describe a
##  matrix of marks;
##  but if <Ref Attr="TableOfMarks" Label="for a matrix"/> returns a table of
##  marks object created from a matrix then it may still happen that this
##  object does not describe the table of marks of a group.
##  <P/>
##  For an overview of operations for table of marks objects,
##  see the introduction to Chapter&nbsp;<Ref Chap="Tables of Marks"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> tom:= TableOfMarks( AlternatingGroup( 5 ) );
##  TableOfMarks( Alt( [ 1 .. 5 ] ) )
##  gap> TableOfMarks( "J5" );
##  fail
##  gap> a5:= TableOfMarks( "A5" );
##  TableOfMarks( "A5" )
##  gap> mat:=
##  > [ [ 60, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 30, 2, 0, 0, 0, 0, 0, 0, 0 ],
##  >   [ 20, 0, 2, 0, 0, 0, 0, 0, 0 ], [ 15, 3, 0, 3, 0, 0, 0, 0, 0 ],
##  >   [ 12, 0, 0, 0, 2, 0, 0, 0, 0 ], [ 10, 2, 1, 0, 0, 1, 0, 0, 0 ],
##  >   [ 6, 2, 0, 0, 1, 0, 1, 0, 0 ], [ 5, 1, 2, 1, 0, 0, 0, 1, 0 ],
##  >   [ 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ];;
##  gap> TableOfMarks( mat );
##  TableOfMarks( <9 classes> )
##  ]]></Example>
##  <P/>
##  The following <Ref Attr="TableOfMarks" Label="for a group"/> methods
##  for a group are installed.
##  <List>
##  <Item>
##    If the group is known to be cyclic then
##    <Ref Attr="TableOfMarks" Label="for a group"/> constructs the
##    table of marks essentially without the group, instead the knowledge
##    about the structure of cyclic groups is used.
##  </Item>
##  <Item>
##    If the lattice of subgroups is already stored in the group then
##    <Ref Attr="TableOfMarks" Label="for a group"/> computes the
##    table of marks from the lattice
##    (see&nbsp;<Ref Func="TableOfMarksByLattice"/>).
##  </Item>
##  <Item>
##    If the group is known to be solvable then
##    <Ref Attr="TableOfMarks" Label="for a group"/> takes the
##    lattice of subgroups (see&nbsp;<Ref Attr="LatticeSubgroups"/>) of the
##    group &ndash;which means that the lattice is computed if it is not yet
##    stored&ndash;
##    and then computes the table of marks from it.
##    This method is also accessible via the global function
##    <Ref Func="TableOfMarksByLattice"/>.
##  </Item>
##  <Item>
##    If the group doesn't know its lattice of subgroups or its conjugacy
##    classes of subgroups then the table of marks and the conjugacy
##    classes of subgroups are computed at the same time by the cyclic
##    extension method.
##    Only the table of marks is stored because the conjugacy classes of
##    subgroups or the lattice of subgroups can be easily read off
##    (see&nbsp;<Ref Func="LatticeSubgroupsByTom"/>).
##  </Item>
##  </List>
##  <P/>
##  Conversely, the lattice of subgroups of a group with known table of marks
##  can be computed using the table of marks, via the function
##  <Ref Func="LatticeSubgroupsByTom"/>.
##  This is also installed as a method for <Ref Attr="LatticeSubgroups"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TableOfMarks", IsGroup );
DeclareAttribute( "TableOfMarks", IsString );
DeclareAttribute( "TableOfMarks", IsTable );


#############################################################################
##
#F  TableOfMarksByLattice( <G> )
##
##  <#GAPDoc Label="TableOfMarksByLattice">
##  <ManSection>
##  <Func Name="TableOfMarksByLattice" Arg='G'/>
##
##  <Description>
##  <Ref Func="TableOfMarksByLattice"/> computes the table of marks of the
##  group <A>G</A> from the lattice of subgroups of <A>G</A>.
##  This lattice is computed via <Ref Attr="LatticeSubgroups"/>
##  if it is not yet stored in <A>G</A>.
##  The function <Ref Func="TableOfMarksByLattice"/> is installed as a method
##  for <Ref Attr="TableOfMarks" Label="for a group"/> for solvable groups
##  and groups with stored subgroup lattice,
##  and is available as a global variable only in order to provide
##  explicit access to this method.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TableOfMarksByLattice" );


#############################################################################
##
#F  LatticeSubgroupsByTom( <G> )
##
##  <#GAPDoc Label="LatticeSubgroupsByTom">
##  <ManSection>
##  <Func Name="LatticeSubgroupsByTom" Arg='G'/>
##
##  <Description>
##  <Ref Func="LatticeSubgroupsByTom"/> computes the lattice of subgroups of
##  <A>G</A> from the table of marks of <A>G</A>,
##  using <Ref Oper="RepresentativeTom"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LatticeSubgroupsByTom" );


#############################################################################
##
##  5. Printing Tables of Marks
##
##  <#GAPDoc Label="[5]{tom}">
##  <ManSection>
##  <Meth Name="ViewObj" Arg='tom' Label="for a table of marks"/>
##
##  <Description>
##  The default <Ref Oper="ViewObj"/> method for tables of marks prints
##  the string <C>"TableOfMarks"</C>,
##  followed by &ndash;if known&ndash; the identifier
##  (see&nbsp;<Ref Attr="Identifier" Label="for tables of marks"/>)
##  or the group of the table of marks enclosed in brackets;
##  if neither group nor identifier are known then just
##  the number of conjugacy classes of subgroups is printed instead.
##  </Description>
##  </ManSection>
##
##  <ManSection>
##  <Meth Name="PrintObj" Arg='tom' Label="for a table of marks"/>
##
##  <Description>
##  The default <Ref Oper="PrintObj"/> method for tables of marks
##  does the same as <Ref Oper="ViewObj"/>,
##  except that <Ref Oper="PrintObj"/> is used for the group instead of
##  <Ref Oper="ViewObj"/>.
##  </Description>
##  </ManSection>
##
##  <ManSection>
##  <Meth Name="Display" Arg='tom[, arec]' Label="for a table of marks"/>
##
##  <Description>
##  The default <Ref Oper="Display"/> method for a table of marks <A>tom</A>
##  produces a formatted output of the marks in <A>tom</A>.
##  Each line of output begins with the number of the corresponding class of
##  subgroups.
##  This number is repeated if the output spreads over several pages.
##  The number of columns printed at one time depends on the actual
##  line length, which can be accessed and changed by the function
##  <Ref Func="SizeScreen"/>.
##  <P/>
##  An interactive variant of <Ref Oper="Display"/> is the
##  <Ref Oper="Browse" BookName="browse"/> method for tables of marks
##  that is provided by the &GAP; package <Package>Browse</Package>,
##  see <Ref Meth="Browse" Label="for tables of marks"
##  BookName="browse"/>.
##  <P/>
##  The optional second argument <A>arec</A> of <Ref Oper="Display"/> can be
##  used to change the default style for displaying a table of marks.
##  <A>arec</A> must be a record, its relevant components are the following.
##  <P/>
##  <List>
##  <Mark><C>classes</C></Mark>
##  <Item>
##    a list of class numbers to select only the rows and columns of the
##    matrix that correspond to this list for printing,
##  </Item>
##  <Mark><C>form</C></Mark>
##  <Item>
##    one of the strings <C>"subgroups"</C>, <C>"supergroups"</C>;
##    in the former case, at position <M>(i,j)</M> of the matrix the number
##    of conjugates of <M>H_j</M> contained in <M>H_i</M> is printed,
##    and in the latter case, at position <M>(i,j)</M> the number of
##    conjugates of <M>H_i</M> which contain <M>H_j</M> is printed.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> tom:= TableOfMarks( "A5" );;
##  gap> Display( tom );
##  1:  60
##  2:  30 2
##  3:  20 . 2
##  4:  15 3 . 3
##  5:  12 . . . 2
##  6:  10 2 1 . . 1
##  7:   6 2 . . 1 . 1
##  8:   5 1 2 1 . . . 1
##  9:   1 1 1 1 1 1 1 1 1
##
##  gap> Display( tom, rec( classes:= [ 1, 2, 3, 4, 8 ] ) );
##  1:  60
##  2:  30 2
##  3:  20 . 2
##  4:  15 3 . 3
##  8:   5 1 2 1 1
##
##  gap> Display( tom, rec( form:= "subgroups" ) );
##  1:  1
##  2:  1  1
##  3:  1  .  1
##  4:  1  3  . 1
##  5:  1  .  . . 1
##  6:  1  3  1 . .  1
##  7:  1  5  . . 1  . 1
##  8:  1  3  4 1 .  . . 1
##  9:  1 15 10 5 6 10 6 5 1
##
##  gap> Display( tom, rec( form:= "supergroups" ) );
##  1:   1
##  2:  15 1
##  3:  10 . 1
##  4:   5 1 . 1
##  5:   6 . . . 1
##  6:  10 2 1 . . 1
##  7:   6 2 . . 1 . 1
##  8:   5 1 2 1 . . . 1
##  9:   1 1 1 1 1 1 1 1 1
##
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
##  6. Sorting Tables of Marks
##


#############################################################################
##
#C  IsTableOfMarks( <obj> )
##
##  <#GAPDoc Label="IsTableOfMarks">
##  <ManSection>
##  <Filt Name="IsTableOfMarks" Arg='obj' Type='Category'/>
##
##  <Description>
##  Each table of marks belongs to this category.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsTableOfMarks", IsObject );


#############################################################################
##
#O  SortedTom( <tom>, <perm> )
##
##  <#GAPDoc Label="SortedTom">
##  <ManSection>
##  <Oper Name="SortedTom" Arg='tom, perm'/>
##
##  <Description>
##  <Ref Oper="SortedTom"/> returns a table of marks where the rows and
##  columns of the table of marks <A>tom</A> are reordered according to the
##  permutation <A>perm</A>.
##  <P/>
##  <E>Note</E> that in each table of marks in &GAP;,
##  the matrix of marks is assumed to have lower triangular shape
##  (see&nbsp;<Ref Sect="Table of Marks Objects in GAP"/>).
##  If the permutation <A>perm</A> does <E>not</E> have this property then
##  the functions for tables of marks might return wrong results when applied
##  to the output of <Ref Oper="SortedTom"/>.
##  <P/>
##  The returned table of marks has only those attribute values stored that
##  are known for <A>tom</A> and listed in
##  <Ref Var="TableOfMarksComponents"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> tom:= TableOfMarksCyclic( 6 );;  Display( tom );
##  1:  6
##  2:  3 3
##  3:  2 . 2
##  4:  1 1 1 1
##
##  gap> sorted:= SortedTom( tom, (2,3) );;  Display( sorted );
##  1:  6
##  2:  2 2
##  3:  3 . 3
##  4:  1 1 1 1
##
##  gap> wrong:= SortedTom( tom, (1,2) );;  Display( wrong );
##  1:  3
##  2:  . 6
##  3:  . 2 2
##  4:  1 1 1 1
##
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SortedTom", [ IsTableOfMarks, IsPerm ] );


#############################################################################
##
#A  PermutationTom( <tom> )
##
##  <#GAPDoc Label="PermutationTom">
##  <ManSection>
##  <Attr Name="PermutationTom" Arg='tom'/>
##
##  <Description>
##  For the table of marks <A>tom</A> of the group <M>G</M> stored as
##  <Ref Attr="UnderlyingGroup" Label="for tables of marks"/>
##  value of <A>tom</A>,
##  <Ref Attr="PermutationTom"/> is a permutation <M>\pi</M> such that the
##  <M>i</M>-th conjugacy class of subgroups of <M>G</M> belongs to the
##  <M>i^\pi</M>-th column and row of marks in <A>tom</A>.
##  <P/>
##  This attribute value is bound only if <A>tom</A> was obtained from
##  another table of marks by permuting with <Ref Oper="SortedTom"/>,
##  and there is no default method to compute its value.
##  <P/>
##  The attribute is necessary because the original and the sorted table of
##  marks have the same identifier and the same group,
##  and information computed from the group may depend on the ordering of
##  marks, for example the fusion from the ordinary character table of
##  <M>G</M> into <A>tom</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> MarksTom( tom )[2];
##  [ 3, 3 ]
##  gap> MarksTom( sorted )[2];
##  [ 2, 2 ]
##  gap> HasPermutationTom( sorted );
##  true
##  gap> PermutationTom( sorted );
##  (2,3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="InfoTom">
##  <ManSection>
##  <InfoClass Name="InfoTom"/>
##
##  <Description>
##  is the info class for computations concerning tables of marks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoTom" );


#############################################################################
##
#V  TableOfMarksFamily
##
##  <#GAPDoc Label="TableOfMarksFamily">
##  <ManSection>
##  <Fam Name="TableOfMarksFamily"/>
##
##  <Description>
##  Each table of marks belongs to this family.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "TableOfMarksFamily",
    NewFamily( "TableOfMarksFamily", IsTableOfMarks ) );


#############################################################################
##
#F  ConvertToTableOfMarks( <record> )
##
##  <#GAPDoc Label="ConvertToTableOfMarks">
##  <ManSection>
##  <Func Name="ConvertToTableOfMarks" Arg='record'/>
##
##  <Description>
##  <Ref Func="ConvertToTableOfMarks"/> converts a record with components
##  from <Ref Var="TableOfMarksComponents"/> into a table of marks object
##  with the corresponding attributes.
##  <P/>
##  <Example><![CDATA[
##  gap> record:= rec( MarksTom:= [ [ 4 ], [ 2, 2 ], [ 1, 1, 1 ] ],
##  >  SubsTom:= [ [ 1 ], [ 1, 2 ], [ 1, 2, 3 ] ] );;
##  gap> ConvertToTableOfMarks( record );;
##  gap> record;
##  TableOfMarks( <3 classes> )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="MarksTom">
##  <ManSection>
##  <Attr Name="MarksTom" Arg='tom'/>
##  <Attr Name="SubsTom" Arg='tom'/>
##
##  <Description>
##  The matrix of marks (see&nbsp;<Ref Sect="More about Tables of Marks"/>)
##  of the table of marks <A>tom</A> is stored in a compressed form
##  where zeros are omitted,
##  using the attributes <Ref Attr="MarksTom"/> and <Ref Attr="SubsTom"/>.
##  If <M>M</M> is the square matrix of marks of <A>tom</A>
##  (see&nbsp;<Ref Attr="MatTom"/>) then the <Ref Attr="SubsTom"/> value of
##  <A>tom</A> is a list that contains at position <M>i</M> the list
##  of all positions of nonzero entries of the <M>i</M>-th row of <M>M</M>,
##  and the <Ref Attr="MarksTom"/> value of <A>tom</A> is a list
##  that contains at position <M>i</M> the list of the corresponding marks.
##  <P/>
##  <Ref Attr="MarksTom"/> and <Ref Attr="SubsTom"/> are defining attributes
##  of tables of marks (see&nbsp;<Ref Sect="Table of Marks Objects in GAP"/>).
##  There is no default method for computing the <Ref Attr="SubsTom"/> value,
##  and the default <Ref Attr="MarksTom"/> method needs the values of
##  <Ref Attr="NrSubsTom"/> and <Ref Attr="OrdersTom"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> a5:= TableOfMarks( "A5" );
##  TableOfMarks( "A5" )
##  gap> MarksTom( a5 );
##  [ [ 60 ], [ 30, 2 ], [ 20, 2 ], [ 15, 3, 3 ], [ 12, 2 ],
##    [ 10, 2, 1, 1 ], [ 6, 2, 1, 1 ], [ 5, 1, 2, 1, 1 ],
##    [ 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ]
##  gap> SubsTom( a5 );
##  [ [ 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 2, 4 ], [ 1, 5 ], [ 1, 2, 3, 6 ],
##    [ 1, 2, 5, 7 ], [ 1, 2, 3, 4, 8 ], [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MarksTom", IsTableOfMarks );
DeclareAttribute( "SubsTom", IsTableOfMarks );


#############################################################################
##
#A  NrSubsTom( <tom> )
#A  OrdersTom( <tom> )
##
##  <#GAPDoc Label="NrSubsTom">
##  <ManSection>
##  <Attr Name="NrSubsTom" Arg='tom'/>
##  <Attr Name="OrdersTom" Arg='tom'/>
##
##  <Description>
##  Instead of storing the marks (see&nbsp;<Ref Attr="MarksTom"/>) of the
##  table of marks <A>tom</A> one can use a matrix which contains at position
##  <M>(i,j)</M> the number of subgroups of conjugacy class <M>j</M>
##  that are contained in one member of the conjugacy class <M>i</M>.
##  These values are stored in the <Ref Attr="NrSubsTom"/> value in the same
##  way as the marks in the <Ref Attr="MarksTom"/> value.
##  <P/>
##  <Ref Attr="OrdersTom"/> returns a list that contains at position <M>i</M>
##  the order of a representative of the <M>i</M>-th conjugacy class of
##  subgroups of <A>tom</A>.
##  <P/>
##  One can compute the <Ref Attr="NrSubsTom"/> and <Ref Attr="OrdersTom"/>
##  values from the <Ref Attr="MarksTom"/> value of <A>tom</A>
##  and vice versa.
##  <P/>
##  <Example><![CDATA[
##  gap> NrSubsTom( a5 );
##  [ [ 1 ], [ 1, 1 ], [ 1, 1 ], [ 1, 3, 1 ], [ 1, 1 ], [ 1, 3, 1, 1 ],
##    [ 1, 5, 1, 1 ], [ 1, 3, 4, 1, 1 ], [ 1, 15, 10, 5, 6, 10, 6, 5, 1 ]
##   ]
##  gap> OrdersTom( a5 );
##  [ 1, 2, 3, 4, 5, 6, 10, 12, 60 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NrSubsTom", IsTableOfMarks );
DeclareAttribute( "OrdersTom", IsTableOfMarks );


#############################################################################
##
#A  LengthsTom( <tom> )
##
##  <#GAPDoc Label="LengthsTom">
##  <ManSection>
##  <Attr Name="LengthsTom" Arg='tom'/>
##
##  <Description>
##  For a table of marks <A>tom</A>,
##  <Ref Attr="LengthsTom"/> returns a list of the lengths of
##  the conjugacy classes of subgroups.
##  <P/>
##  <Example><![CDATA[
##  gap> LengthsTom( a5 );
##  [ 1, 15, 10, 5, 6, 10, 6, 5, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LengthsTom", IsTableOfMarks );


#############################################################################
##
#A  ClassTypesTom( <tom> )
##
##  <#GAPDoc Label="ClassTypesTom">
##  <ManSection>
##  <Attr Name="ClassTypesTom" Arg='tom'/>
##
##  <Description>
##  <Ref Attr="ClassTypesTom"/> distinguishes isomorphism types of the
##  classes of subgroups of the table of marks <A>tom</A>
##  as far as this is possible from the <Ref Attr="SubsTom"/> and
##  <Ref Attr="MarksTom"/> values of <A>tom</A>.
##  <P/>
##  Two subgroups are clearly not isomorphic if they have different orders.
##  Moreover, isomorphic subgroups must contain the same number of subgroups
##  of each type.
##  <P/>
##  Each type is represented by a positive integer.
##  <Ref Attr="ClassTypesTom"/> returns the list which contains for each
##  class of subgroups its corresponding type.
##  <P/>
##  <Example><![CDATA[
##  gap> a6:= TableOfMarks( "A6" );;
##  gap> ClassTypesTom( a6 );
##  [ 1, 2, 3, 3, 4, 5, 6, 6, 7, 7, 8, 9, 10, 11, 11, 12, 13, 13, 14, 15,
##    15, 16 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassTypesTom", IsTableOfMarks );


#############################################################################
##
#A  ClassNamesTom( <tom> )
##
##  <#GAPDoc Label="ClassNamesTom">
##  <ManSection>
##  <Attr Name="ClassNamesTom" Arg='tom'/>
##
##  <Description>
##  <Ref Attr="ClassNamesTom"/> constructs generic names for the conjugacy
##  classes of subgroups of the table of marks <A>tom</A>.
##  In general, the generic name of a class of non-cyclic subgroups consists
##  of three parts and has the form
##  <C>"(</C><A>o</A><C>)_{</C><A>t</A><C>}</C><A>l</A><C>"</C>,
##  where <A>o</A> indicates the order of the subgroup,
##  <A>t</A> is a number that distinguishes different types of subgroups of
##  the same order, and <A>l</A> is a letter that distinguishes classes of
##  subgroups of the same type and order.
##  The type of a subgroup is determined by the numbers of its subgroups of
##  other types (see&nbsp;<Ref Attr="ClassTypesTom"/>).
##  This is slightly weaker than isomorphism.
##  <P/>
##  The letter is omitted if there is only one class of subgroups of that
##  order and type,
##  and the type is omitted if there is only one class of that order.
##  Moreover, the braces <C>{}</C>  around the type are omitted
##  if the type number has only one digit.
##  <P/>
##  For classes of cyclic subgroups, the parentheses round the order and the
##  type are omitted.
##  Hence the most general form of their generic names is
##  <C>"<A>o</A>,<A>l</A>"</C>.
##  Again, the letter is omitted if there is only one class of cyclic
##  subgroups of that order.
##  <P/>
##  <Example><![CDATA[
##  gap> ClassNamesTom( a6 );
##  [ "1", "2", "3a", "3b", "5", "4", "(4)_2a", "(4)_2b", "(6)a", "(6)b",
##    "(8)", "(9)", "(10)", "(12)a", "(12)b", "(18)", "(24)a", "(24)b",
##    "(36)", "(60)a", "(60)b", "(360)" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ClassNamesTom", IsTableOfMarks );


#############################################################################
##
#A  FusionsTom( <tom> )
##
##  <#GAPDoc Label="FusionsTom">
##  <ManSection>
##  <Attr Name="FusionsTom" Arg='tom'/>
##
##  <Description>
##  For a table of marks <A>tom</A>,
##  <Ref Attr="FusionsTom"/> is a list of fusions into other tables of marks.
##  Each fusion is a list of length  two, the  first  entry being the
##  <Ref Attr="Identifier" Label="for tables of marks"/>) value
##  of the image table, the second entry being the list of images of
##  the class positions of <A>tom</A> in the image table.
##  <P/>
##  This attribute is mainly used for tables of marks in the &GAP; library
##  (see&nbsp;<Ref Sect="The Library of Tables of Marks"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> fus:= FusionsTom( a6 );;
##  gap> fus[1];
##  [ "L3(4)",
##    [ 1, 2, 3, 3, 14, 5, 9, 7, 15, 15, 24, 26, 27, 32, 33, 50, 57, 55,
##        63, 73, 77, 90 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FusionsTom", IsTableOfMarks, "mutable" );


#############################################################################
##
#A  UnderlyingGroup( <tom> )
##
##  <#GAPDoc Label="UnderlyingGroup:tom">
##  <ManSection>
##  <Attr Name="UnderlyingGroup" Arg='tom' Label="for tables of marks"/>
##
##  <Description>
##  <Ref Attr="UnderlyingGroup" Label="for tables of marks"/> is used
##  to access an underlying group that is stored on the table of marks
##  <A>tom</A>.
##  There is no default method to compute an underlying group if it is not
##  stored.
##  <P/>
##  <Example><![CDATA[
##  gap> UnderlyingGroup( a6 );
##  Group([ (1,2)(3,4), (1,2,4,5)(3,6) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingGroup", IsTableOfMarks );


#############################################################################
##
#A  IdempotentsTom( <tom> )
#A  IdempotentsTomInfo( <tom> )
##
##  <#GAPDoc Label="IdempotentsTom">
##  <ManSection>
##  <Attr Name="IdempotentsTom" Arg='tom'/>
##  <Attr Name="IdempotentsTomInfo" Arg='tom'/>
##
##  <Description>
##  <Ref Attr="IdempotentsTom"/> encodes the idempotents of the integral
##  Burnside ring described by the table of marks <A>tom</A>.
##  The return value is a list <M>l</M> of positive integers such that each
##  row vector describing a primitive idempotent has value <M>1</M> at all
##  positions with the same entry in <M>l</M>, and <M>0</M> at all other
##  positions.
##  <P/>
##  According to A.&nbsp;Dress&nbsp;<Cite Key="Dre69"/>
##  (see also&nbsp;<Cite Key="Pfe97"/>),
##  these idempotents correspond to the classes of perfect subgroups,
##  and each such idempotent is the characteristic function of all those
##  subgroups that arise by cyclic extension from the corresponding perfect
##  subgroup
##  (see&nbsp;<Ref Oper="CyclicExtensionsTom" Label="for a prime"/>).
##  <P/>
##  <Ref Attr="IdempotentsTomInfo"/> returns a record with components
##  <C>fixpointvectors</C> and <C>primidems</C>, both bound to lists.
##  The <M>i</M>-th entry of the <C>fixpointvectors</C> list is the
##  <M>0-1</M>-vector describing the <M>i</M>-th primitive idempotent,
##  and the <M>i</M>-th entry of <C>primidems</C> is the decomposition of this
##  idempotent in the rows of <A>tom</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> IdempotentsTom( a5 );
##  [ 1, 1, 1, 1, 1, 1, 1, 1, 9 ]
##  gap> IdempotentsTomInfo( a5 );
##  rec(
##    fixpointvectors := [ [ 1, 1, 1, 1, 1, 1, 1, 1, 0 ],
##        [ 0, 0, 0, 0, 0, 0, 0, 0, 1 ] ],
##    primidems := [ [ 1, -2, -1, 0, 0, 1, 1, 1 ],
##        [ -1, 2, 1, 0, 0, -1, -1, -1, 1 ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IdempotentsTom", IsTableOfMarks );
DeclareAttribute( "IdempotentsTomInfo", IsTableOfMarks );


#############################################################################
##
#A  Identifier( <tom> )
##
##  <#GAPDoc Label="Identifier:tom">
##  <ManSection>
##  <Attr Name="Identifier" Arg='tom' Label="for tables of marks"/>
##
##  <Description>
##  The identifier of a table of marks <A>tom</A> is a string.
##  It is used for printing the table of marks
##  (see&nbsp;<Ref Sect="Printing Tables of Marks"/>)
##  and in fusions between tables of marks
##  (see&nbsp;<Ref Attr="FusionsTom"/>).
##  <P/>
##  If <A>tom</A> is a table of marks from the &GAP; library of tables of
##  marks (see&nbsp;<Ref Sect="The Library of Tables of Marks"/>)
##  then it has an identifier,
##  and if <A>tom</A> was constructed from a group with <Ref Attr="Name"/>
##  then this name is chosen as
##  <Ref Attr="Identifier" Label="for tables of marks"/> value.
##  There is no default method to compute an identifier in all other cases.
##  <P/>
##  <Example><![CDATA[
##  gap> Identifier( a5 );
##  "A5"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Identifier", IsTableOfMarks );


#############################################################################
##
#A  MatTom( <tom> )
##
##  <#GAPDoc Label="MatTom">
##  <ManSection>
##  <Attr Name="MatTom" Arg='tom'/>
##
##  <Description>
##  <Ref Attr="MatTom"/> returns the square matrix of marks
##  (see&nbsp;<Ref Sect="More about Tables of Marks"/>) of the table of marks
##  <A>tom</A> which is stored in a compressed form using the attributes
##  <Ref Attr="MarksTom"/> and <Ref Attr="SubsTom"/>
##  This may need substantially more space than the values of
##  <Ref Attr="MarksTom"/> and <Ref Attr="SubsTom"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> MatTom( a5 );
##  [ [ 60, 0, 0, 0, 0, 0, 0, 0, 0 ], [ 30, 2, 0, 0, 0, 0, 0, 0, 0 ],
##    [ 20, 0, 2, 0, 0, 0, 0, 0, 0 ], [ 15, 3, 0, 3, 0, 0, 0, 0, 0 ],
##    [ 12, 0, 0, 0, 2, 0, 0, 0, 0 ], [ 10, 2, 1, 0, 0, 1, 0, 0, 0 ],
##    [ 6, 2, 0, 0, 1, 0, 1, 0, 0 ], [ 5, 1, 2, 1, 0, 0, 0, 1, 0 ],
##    [ 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MatTom", IsTableOfMarks );


#############################################################################
##
#A  MoebiusTom( <tom> )
##
##  <#GAPDoc Label="MoebiusTom">
##  <ManSection>
##  <Attr Name="MoebiusTom" Arg='tom'/>
##
##  <Description>
##  <Ref Attr="MoebiusTom"/> computes the Möbius values both of the subgroup
##  lattice of the group <M>G</M> with table of marks <A>tom</A>
##  and of the poset of conjugacy classes of subgroups of <M>G</M>.
##  It returns a record where the component
##  <C>mu</C> contains the Möbius values of the subgroup lattice,
##  and the component <C>nu</C> contains the Möbius values of the poset.
##  <P/>
##  Moreover, according to an observation of Isaacs et al.
##  (see&nbsp;<Cite Key="HIO89"/>, <Cite Key="Pah93"/>),
##  the values on the subgroup lattice often can be derived
##  from those of the poset of conjugacy classes.
##  These <Q>expected values</Q> are returned in the component <C>ex</C>,
##  and the list of numbers of those subgroups where the expected value does
##  not coincide with the actual value are returned in the component
##  <C>hyp</C>.
##  For the computation of these values, the position of the derived subgroup
##  of <M>G</M> is needed (see&nbsp;<Ref Oper="DerivedSubgroupTom"/>).
##  If it is not uniquely determined then the result does not have the
##  components <C>ex</C> and <C>hyp</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> MoebiusTom( a5 );
##  rec( ex := [ -60, 4, 2,,, -1, -1, -1, 1 ], hyp := [  ],
##    mu := [ -60, 4, 2,,, -1, -1, -1, 1 ],
##    nu := [ -1, 2, 1,,, -1, -1, -1, 1 ] )
##  gap> tom:= TableOfMarks( "M12" );;
##  gap> moebius:= MoebiusTom( tom );;
##  gap> moebius.hyp;
##  [ 1, 2, 4, 16, 39, 45, 105 ]
##  gap> moebius.mu[1];  moebius.ex[1];
##  95040
##  190080
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MoebiusTom", IsTableOfMarks );


#############################################################################
##
#A  WeightsTom( <tom> )
##
##  <#GAPDoc Label="WeightsTom">
##  <ManSection>
##  <Attr Name="WeightsTom" Arg='tom'/>
##
##  <Description>
##  <Ref Attr="WeightsTom"/> extracts the <E>weights</E> from the table of
##  marks <A>tom</A>, i.e., the diagonal entries of the matrix of marks
##  (see&nbsp;<Ref Attr="MarksTom"/>),
##  indicating the index of a subgroup in its normalizer.
##  <P/>
##  <Example><![CDATA[
##  gap> wt:= WeightsTom( a5 );
##  [ 60, 2, 2, 3, 2, 1, 1, 1, 1 ]
##  ]]></Example>
##  <P/>
##  This information may be used to obtain the numbers of conjugate
##  supergroups from the marks.
##  <Example><![CDATA[
##  gap> marks:= MarksTom( a5 );;
##  gap> List( [ 1 .. 9 ], x -> marks[x] / wt[x] );
##  [ [ 1 ], [ 15, 1 ], [ 10, 1 ], [ 5, 1, 1 ], [ 6, 1 ], [ 10, 2, 1, 1 ],
##    [ 6, 2, 1, 1 ], [ 5, 1, 2, 1, 1 ], [ 1, 1, 1, 1, 1, 1, 1, 1, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "WeightsTom", IsTableOfMarks );


#############################################################################
##
##  9. Properties of Tables of Marks
##
##  <#GAPDoc Label="[6]{tom}">
##  For a table of marks <A>tom</A> of a group <M>G</M>,
##  the following properties have the same meaning as the corresponding
##  properties for <M>G</M>.
##  Additionally, if a positive integer <A>sub</A> is given
##  as the second argument
##  then the value of the corresponding property for the <A>sub</A>-th class
##  of subgroups of <A>tom</A> is returned.
##  <P/>
##  <ManSection>
##  <Prop Name="IsAbelianTom" Arg='tom[, sub]'/>
##  <Prop Name="IsCyclicTom" Arg='tom[, sub]'/>
##  <Prop Name="IsNilpotentTom" Arg='tom[, sub]'/>
##  <Prop Name="IsPerfectTom" Arg='tom[, sub]'/>
##  <Prop Name="IsSolvableTom" Arg='tom[, sub]'/>
##
##  <Description>
##  <Example><![CDATA[
##  gap> tom:= TableOfMarks( "A5" );;
##  gap> IsAbelianTom( tom );  IsPerfectTom( tom );
##  false
##  true
##  gap> IsAbelianTom( tom, 3 );  IsNilpotentTom( tom, 7 );
##  true
##  false
##  gap> IsPerfectTom( tom, 7 );  IsSolvableTom( tom, 7 );
##  false
##  true
##  gap> for i in [ 1 .. 6 ] do
##  > Print( i, ": ", IsCyclicTom(a5, i), "  " );
##  > od;  Print( "\n" );
##  1: true  2: true  3: true  4: false  5: true  6: false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#P  IsAbelianTom( <tom>[, <sub>] )
##
##  <ManSection>
##  <Prop Name="IsAbelianTom" Arg='tom[, sub]'/>
##
##  <Description>
##  <Ref Func="IsAbelianTom"/> tests if the underlying group of the table of
##  marks <A>tom</A> is abelian.
##  If a second argument <A>sub</A> is given then <Ref Func="IsAbelianTom"/>
##  returns whether the groups in the <A>sub</A>-th class of subgroups in
##  <A>tom</A> are abelian.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsAbelianTom", IsTableOfMarks );
DeclareOperation( "IsAbelianTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#P  IsCyclicTom( <tom>[, <sub>] )
##
##  <ManSection>
##  <Prop Name="IsCyclicTom" Arg='tom[, sub]'/>
##
##  <Description>
##  <Ref Func="IsCyclicTom"/> tests if the underlying group of the table of
##  marks <A>tom</A> is cyclic.
##  If a second argument <A>sub</A> is given then <Ref Func="IsCyclicTom"/>
##  returns whether the groups in the <A>sub</A>-th class of subgroups in
##  <A>tom</A> are cyclic.
##  <P/>
##  A subgroup is cyclic if and only if the sum over the corresponding row of
##  the inverse table of marks is nonzero
##  (see&nbsp;<Cite Key="Ker91" Where="page 125"/>).
##  Thus we only have to decompose the corresponding idempotent.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsCyclicTom", IsTableOfMarks );
DeclareOperation( "IsCyclicTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#P  IsNilpotentTom( <tom>[, <sub>] )
##
##  <ManSection>
##  <Prop Name="IsNilpotentTom" Arg='tom[, sub]'/>
##
##  <Description>
##  <Ref Func="IsNilpotentTom"/> tests if the underlying group of the table
##  of marks <A>tom</A> is nilpotent.
##  If a second argument <A>sub</A> is given then
##  <Ref Func="IsNilpotentTom"/> returns whether the groups in the
##  <A>sub</A>-th class of subgroups in <A>tom</A> are nilpotent.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsNilpotentTom", IsTableOfMarks );
DeclareOperation( "IsNilpotentTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#P  IsPerfectTom( <tom>[, <sub>] )
##
##  <ManSection>
##  <Prop Name="IsPerfectTom" Arg='tom[, sub]'/>
##
##  <Description>
##  <Ref Func="IsPerfectTom"/> tests if the underlying group of the table of
##  marks <A>tom</A> is perfect.
##  If a second argument <A>sub</A> is given then <Ref Func="IsPerfectTom"/>
##  returns whether the groups in the <A>sub</A>-th class of subgroups in
##  <A>tom</A> are perfect.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsPerfectTom", IsTableOfMarks );
DeclareOperation( "IsPerfectTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#P  IsSolvableTom( <tom>[, <sub>] )
##
##  <ManSection>
##  <Prop Name="IsSolvableTom" Arg='tom[, sub]'/>
##
##  <Description>
##  <Ref Func="IsSolvableTom"/> tests if the underlying group of the table of
##  marks <A>tom</A> is solvable.
##  If a second argument <A>sub</A> is given then <Ref Func="IsSolvableTom"/>
##  returns whether the groups in the <A>sub</A>-th class of subgroups in
##  <A>tom</A> are solvable.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsSolvableTom", IsTableOfMarks );
DeclareOperation( "IsSolvableTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
##  10. Other Operations for Tables of Marks
##
##  <#GAPDoc Label="[7]{tom}">
##  <ManSection>
##  <Meth Name="IsInternallyConsistent"
##   Arg='tom' Label="for tables of marks"/>
##
##  <Description>
##  For a table of marks <A>tom</A>,
##  <Ref Meth="IsInternallyConsistent" Label="for tables of marks"/>
##  decomposes all tensor products of rows of <A>tom</A>.
##  It returns <K>true</K> if all decomposition numbers are nonnegative
##  integers, and <K>false</K> otherwise.
##  This provides a strong consistency check for a table of marks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#O  DerivedSubgroupTom( <tom>, <sub> )
#F  DerivedSubgroupsTom( <tom> )
##
##  <#GAPDoc Label="DerivedSubgroupTom">
##  <ManSection>
##  <Oper Name="DerivedSubgroupTom" Arg='tom, sub'/>
##  <Func Name="DerivedSubgroupsTom" Arg='tom'/>
##
##  <Description>
##  For a table of marks <A>tom</A> and a positive integer <A>sub</A>,
##  <Ref Oper="DerivedSubgroupTom"/> returns either a positive integer
##  <M>i</M> or a list <M>l</M> of positive integers.
##  In the former case, the result means that the derived subgroups of the
##  subgroups in the <A>sub</A>-th class of <A>tom</A> lie in the
##  <M>i</M>-th class.
##  In the latter case, the class of the derived subgroups could not be
##  uniquely determined, and the position of the class of derived subgroups
##  is an entry of <M>l</M>.
##  <P/>
##  Values computed with <Ref Oper="DerivedSubgroupTom"/> are stored
##  using the attribute <Ref Attr="DerivedSubgroupsTomPossible"/>.
##  <P/>
##  <Ref Func="DerivedSubgroupsTom"/> is just the list of
##  <Ref Oper="DerivedSubgroupTom"/> values for all values of <A>sub</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DerivedSubgroupTom", [ IsTableOfMarks, IsPosInt ] );

DeclareGlobalFunction( "DerivedSubgroupsTom");


#############################################################################
##
#A  DerivedSubgroupsTomPossible( <tom> )
#A  DerivedSubgroupsTomUnique( <tom> )
##
##  <#GAPDoc Label="DerivedSubgroupsTomPossible">
##  <ManSection>
##  <Attr Name="DerivedSubgroupsTomPossible" Arg='tom'/>
##  <Attr Name="DerivedSubgroupsTomUnique" Arg='tom'/>
##
##  <Description>
##  Let <A>tom</A> be a table of marks.
##  The value of the attribute <Ref Attr="DerivedSubgroupsTomPossible"/> is
##  a list in which the value at position <M>i</M> &ndash;if bound&ndash;
##  is a positive integer or a list; the meaning of the entry is the same as
##  in <Ref Oper="DerivedSubgroupTom"/>.
##  <P/>
##  If the value of the attribute <Ref Attr="DerivedSubgroupsTomUnique"/> is
##  known for <A>tom</A> then it is a list of positive integers,
##  the value at position <M>i</M> being the position of the class of derived
##  subgroups of the <M>i</M>-th class of subgroups in <A>tom</A>.
##  <P/>
##  The derived subgroups are in general not uniquely determined by the table
##  of marks if no <Ref Attr="UnderlyingGroup" Label="for tables of marks"/>
##  value is stored, so there is no default method for
##  <Ref Attr="DerivedSubgroupsTomUnique"/>.
##  But in some cases the derived subgroups are explicitly set when the table
##  of marks is constructed.
##  In this case, <Ref Oper="DerivedSubgroupTom"/> does not set values in
##  the <Ref Attr="DerivedSubgroupsTomPossible"/> list.
##  <P/>
##  The <Ref Attr="DerivedSubgroupsTomUnique"/> value is automatically set
##  when the last missing unique value is entered in the
##  <Ref Attr="DerivedSubgroupsTomPossible"/> list by
##  <Ref Oper="DerivedSubgroupTom"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Currently the `DerivedSubgroupsTomUnique' value seems to be set
##  automatically in all cases.
##  Therefore, no example is shown.
##
DeclareAttribute( "DerivedSubgroupsTomPossible", IsTableOfMarks, "mutable" );
DeclareAttribute( "DerivedSubgroupsTomUnique", IsTableOfMarks );


#############################################################################
##
#O  NormalizerTom( <tom>, <sub> )
#A  NormalizersTom( <tom> )
##
##  <#GAPDoc Label="NormalizerTom">
##  <ManSection>
##  <Oper Name="NormalizerTom" Arg='tom, sub'/>
##  <Attr Name="NormalizersTom" Arg='tom'/>
##
##  <Description>
##  Let <A>tom</A> be the table of marks of a group <M>G</M>.
##  <Ref Oper="NormalizerTom"/> tries to find the conjugacy class of the
##  normalizer <M>N</M> in <M>G</M> of a subgroup <M>U</M> in the
##  <A>sub</A>-th class of <A>tom</A>.
##  The return value is either the list of class numbers of those subgroups
##  that have the right size and contain the subgroup and all subgroups that
##  clearly contain it as a normal subgroup, or the class number of the
##  normalizer if it is uniquely determined by these conditions.
##  If <A>tom</A> knows the subgroup lattice of <M>G</M>
##  (see&nbsp;<Ref Filt="IsTableOfMarksWithGens"/>)
##  then all normalizers are uniquely determined.
##  <Ref Oper="NormalizerTom"/> should never return an empty list.
##  <P/>
##  <Ref Attr="NormalizersTom"/> returns the list of positions of the classes
##  of normalizers of subgroups in <A>tom</A>.
##  In addition to the criteria for a single class of subgroup used by
##  <Ref Oper="NormalizerTom"/>,
##  the approximations of normalizers for several classes are used and thus
##  <Ref Attr="NormalizersTom"/> may return better approximations than
##  <Ref Oper="NormalizerTom"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> NormalizerTom( a5, 4 );
##  8
##  gap> NormalizersTom( a5 );
##  [ 9, 4, 6, 8, 7, 6, 7, 8, 9 ]
##  ]]></Example>
##  <P/>
##  The example shows that a subgroup with class number 4 in <M>A_5</M>
##  (which is a Kleinian four group)
##  is normalized by a subgroup in class 8.
##  This class contains the subgroups of <M>A_5</M> which are isomorphic to
##  <M>A_4</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NormalizerTom", [ IsTableOfMarks, IsPosInt ] );
DeclareAttribute( "NormalizersTom", IsTableOfMarks );


#############################################################################
##
#O  ContainedTom( <tom>, <sub1>, <sub2> )
##
##  <#GAPDoc Label="ContainedTom">
##  <ManSection>
##  <Oper Name="ContainedTom" Arg='tom, sub1, sub2'/>
##
##  <Description>
##  <Ref Oper="ContainedTom"/> returns the number of subgroups in class
##  <A>sub1</A> of the table of marks <A>tom</A> that are contained in one
##  fixed member of the class <A>sub2</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> ContainedTom( a5, 3, 5 );  ContainedTom( a5, 3, 8 );
##  0
##  4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ContainedTom", [IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  ContainingTom( <tom>, <sub1>, <sub2> )
##
##  <#GAPDoc Label="ContainingTom">
##  <ManSection>
##  <Oper Name="ContainingTom" Arg='tom, sub1, sub2'/>
##
##  <Description>
##  <Ref Oper="ContainingTom"/> returns the number of subgroups in class
##  <A>sub2</A> of the table of marks <A>tom</A> that contain one fixed
##  member of the class <A>sub1</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> ContainingTom( a5, 3, 5 );  ContainingTom( a5, 3, 8 );
##  0
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ContainingTom", [ IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  CyclicExtensionsTom( <tom>, <p> )
#A  CyclicExtensionsTom( <tom>[, <list>] )
##
##  <#GAPDoc Label="CyclicExtensionsTom">
##  <ManSection>
##  <Oper Name="CyclicExtensionsTom" Arg='tom, p' Label="for a prime"/>
##  <Attr Name="CyclicExtensionsTom" Arg='tom[, list]'
##   Label="for a list of primes"/>
##
##  <Description>
##  According to A.&nbsp;Dress&nbsp;<Cite Key="Dre69"/>,
##  two columns of the table of marks <A>tom</A> are equal modulo the prime
##  <A>p</A> if and only if the corresponding subgroups are connected by a
##  chain of normal extensions of order <A>p</A>.
##  <P/>
##  Called with <A>tom</A> and <A>p</A>,
##  <Ref Oper="CyclicExtensionsTom" Label="for a prime"/>
##  returns the classes of this equivalence relation.
##  <P/>
##  In the second form, <A>list</A> must be a list of primes,
##  and the return value is the list of classes of the relation obtained by
##  considering chains of normal extensions of prime order where all primes
##  are in <A>list</A>.
##  The default value for <A>list</A> is the set of prime divisors of the
##  order of the group of <A>tom</A>.
##  <P/>
##  (This information is <E>not</E> used by <Ref Oper="NormalizerTom"/>
##  although it might give additional restrictions in the search of
##  normalizers.)
##  <P/>
##  <Example><![CDATA[
##  gap> CyclicExtensionsTom( a5, 2 );
##  [ [ 1, 2, 4 ], [ 3, 6 ], [ 5, 7 ], [ 8 ], [ 9 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Attr Name="ComputedCyclicExtensionsTom" Arg='tom'/>
##  <Oper Name="CyclicExtensionsTomOp" Arg='tom, p'/>
##  <Oper Name="CyclicExtensionsTomOp" Arg='tom, list'/>
##
##  <Description>
##  The attribute <Ref Func="ComputedCyclicExtensionsTom"/> is used by the
##  default <Ref Func="CyclicExtensionsTom"/> method to store the computed
##  equivalence classes for the table of marks <A>tom</A> and access them in
##  subsequent calls.
##  <P/>
##  The operation <Ref Func="CyclicExtensionsTomOp"/> does the real work for
##  <Ref Func="CyclicExtensionsTom"/>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "ComputedCyclicExtensionsTom", IsTableOfMarks, "mutable" );
DeclareOperation( "CyclicExtensionsTomOp", [ IsTableOfMarks, IsPosInt ] );
DeclareOperation( "CyclicExtensionsTomOp", [ IsTableOfMarks, IsList ] );


#############################################################################
##
#O  DecomposedFixedPointVector( <tom>, <fix> )
##
##  <#GAPDoc Label="DecomposedFixedPointVector">
##  <ManSection>
##  <Oper Name="DecomposedFixedPointVector" Arg='tom, fix'/>
##
##  <Description>
##  Let <A>tom</A> be the table of marks of a group <M>G</M>
##  and let <A>fix</A> be a vector of fixed point numbers w.r.t.&nbsp;an
##  action of <M>G</M>, i.e., a vector which contains for each class of
##  subgroups the number of fixed points under the given action.
##  <Ref Oper="DecomposedFixedPointVector"/> returns the decomposition of
##  <A>fix</A> into rows of the table of marks.
##  This decomposition  corresponds to a decomposition of the action into
##  transitive constituents.
##  Trailing zeros in <A>fix</A> may be omitted.
##  <P/>
##  <Example><![CDATA[
##  gap> DecomposedFixedPointVector( a5, [ 16, 4, 1, 0, 1, 1, 1 ] );
##  [ 0, 0, 0, 0, 0, 1, 1 ]
##  ]]></Example>
##  <P/>
##  The vector <A>fix</A> may be any vector of integers.
##  The resulting decomposition, however, will not be integral, in general.
##  <Example><![CDATA[
##  gap> DecomposedFixedPointVector( a5, [ 0, 0, 0, 0, 1, 1 ] );
##  [ 2/5, -1, -1/2, 0, 1/2, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DecomposedFixedPointVector",
    [ IsTableOfMarks, IsList ] );


#############################################################################
##
#O  EulerianFunctionByTom( <tom>, <n>[, <sub>] )
##
##  <#GAPDoc Label="EulerianFunctionByTom">
##  <ManSection>
##  <Oper Name="EulerianFunctionByTom" Arg='tom, n[, sub]'/>
##
##  <Description>
##  Called with two arguments, <Ref Oper="EulerianFunctionByTom"/> computes
##  the Eulerian function (see&nbsp;<Ref Oper="EulerianFunction"/>) of the
##  underlying group <M>G</M> of the table of marks <A>tom</A>,
##  that is, the number of <A>n</A>-tuples of elements in <M>G</M> that
##  generate <M>G</M>.
##  If the optional argument <A>sub</A> is given then
##  <Ref Oper="EulerianFunctionByTom"/> computes the Eulerian function
##  of each subgroup in the <A>sub</A>-th class of subgroups of <A>tom</A>.
##  <P/>
##  For a group <M>G</M> whose table of marks is known,
##  <Ref Oper="EulerianFunctionByTom"/>
##  is installed as a method for <Ref Oper="EulerianFunction"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> EulerianFunctionByTom( a5, 2 );
##  2280
##  gap> EulerianFunctionByTom( a5, 3 );
##  200160
##  gap> EulerianFunctionByTom( a5, 2, 3 );
##  8
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EulerianFunctionByTom", [ IsTableOfMarks, IsPosInt ] );
DeclareOperation( "EulerianFunctionByTom",
    [ IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  IntersectionsTom( <tom>, <sub1>, <sub2> )
##
##  <#GAPDoc Label="IntersectionsTom">
##  <ManSection>
##  <Oper Name="IntersectionsTom" Arg='tom, sub1, sub2'/>
##
##  <Description>
##  The intersections of the groups in the <A>sub1</A>-th conjugacy class of
##  subgroups of the table of marks <A>tom</A> with the groups in the
##  <A>sub2</A>-th conjugacy classes of subgroups of <A>tom</A>
##  are determined up to conjugacy by the decomposition of the tensor product
##  of their rows of marks.
##  <Ref Oper="IntersectionsTom"/> returns a list <M>l</M> that describes
##  this decomposition.
##  The <M>i</M>-th entry in <M>l</M> is the multiplicity of groups in the
##  <M>i</M>-th conjugacy class as an intersection.
##  <P/>
##  <Example><![CDATA[
##  gap> IntersectionsTom( a5, 8, 8 );
##  [ 0, 0, 1, 0, 0, 0, 0, 1 ]
##  ]]></Example>
##  Any two subgroups of class number 8 (<M>A_4</M>) of <M>A_5</M> are either
##  equal and their intersection has again class number 8,
##  or their intersection has class number <M>3</M>,
##  and is a cyclic subgroup of order 3.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IntersectionsTom",
    [ IsTableOfMarks, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  FactorGroupTom( <tom>, <n> )
##
##  <#GAPDoc Label="FactorGroupTom">
##  <ManSection>
##  <Oper Name="FactorGroupTom" Arg='tom, n'/>
##
##  <Description>
##  For a table of marks <A>tom</A> of a group <M>G</M>
##  and the normal subgroup <M>N</M> of <M>G</M> corresponding to the
##  <A>n</A>-th class of subgroups of <A>tom</A>,
##  <Ref Oper="FactorGroupTom"/> returns the table of marks of the factor
##  group <M>G / N</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> s4:= TableOfMarks( SymmetricGroup( 4 ) );
##  TableOfMarks( Sym( [ 1 .. 4 ] ) )
##  gap> LengthsTom( s4 );
##  [ 1, 3, 6, 4, 1, 3, 3, 4, 3, 1, 1 ]
##  gap> OrdersTom( s4 );
##  [ 1, 2, 2, 3, 4, 4, 4, 6, 8, 12, 24 ]
##  gap> s3:= FactorGroupTom( s4, 5 );
##  TableOfMarks( Group([ f1, f2 ]) )
##  gap> Display( s3 );
##  1:  6
##  2:  3 1
##  3:  2 . 2
##  4:  1 1 1 1
##
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FactorGroupTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#A  MaximalSubgroupsTom( <tom>[, <sub>] )
##
##  <#GAPDoc Label="MaximalSubgroupsTom">
##  <ManSection>
##  <Attr Name="MaximalSubgroupsTom" Arg='tom[, sub]'/>
##
##  <Description>
##  Called with a table of marks <A>tom</A>,
##  <Ref Attr="MaximalSubgroupsTom"/> returns a list of length two,
##  the first entry being the list of positions of the classes of maximal
##  subgroups of the whole group of <A>tom</A>,
##  the second entry being the list of class lengths of these groups.
##  <P/>
##  Called with a table of marks <A>tom</A> and a position <A>sub</A>,
##  the same information for the <A>sub</A>-th class of subgroups is
##  returned.
##  <P/>
##  <Example><![CDATA[
##  gap> MaximalSubgroupsTom( s4 );
##  [ [ 10, 9, 8 ], [ 1, 3, 4 ] ]
##  gap> MaximalSubgroupsTom( s4, 10 );
##  [ [ 5, 4 ], [ 1, 4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MaximalSubgroupsTom", IsTableOfMarks );
DeclareOperation( "MaximalSubgroupsTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
#O  MinimalSupergroupsTom( <tom>, <sub> )
##
##  <#GAPDoc Label="MinimalSupergroupsTom">
##  <ManSection>
##  <Oper Name="MinimalSupergroupsTom" Arg='tom, sub'/>
##
##  <Description>
##  For a table of marks <A>tom</A>,
##  <Ref Oper="MinimalSupergroupsTom"/> returns a list of length two,
##  the first entry being the list of positions of the classes
##  containing the minimal supergroups of the groups in the <A>sub</A>-th
##  class of subgroups of <A>tom</A>,
##  the second entry being the list of class lengths of these groups.
##  <P/>
##  <Example><![CDATA[
##  gap> MinimalSupergroupsTom( s4, 5 );
##  [ [ 9, 10 ], [ 3, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MinimalSupergroupsTom", [ IsTableOfMarks, IsPosInt ] );


#############################################################################
##
##  11. Accessing Subgroups via Tables of Marks
##
##  <#GAPDoc Label="[8]{tom}">
##  Let <A>tom</A> be the table of marks of the group <M>G</M>,
##  and assume that <A>tom</A> has access to <M>G</M> via the
##  <Ref Attr="UnderlyingGroup" Label="for tables of marks"/> value.
##  Then it makes sense to use <A>tom</A> and its ordering of conjugacy
##  classes of subgroups of <M>G</M> for storing information for constructing
##  representatives of these classes.
##  The group <M>G</M> is in general not sufficient for this,
##  <A>tom</A> needs more information;
##  this is available if and only if the <Ref Filt="IsTableOfMarksWithGens"/>
##  value of <A>tom</A> is <K>true</K>.
##  In this case, <Ref Oper="RepresentativeTom"/> can be used
##  to get a subgroup of the <M>i</M>-th class, for all <M>i</M>.
##  <P/>
##  &GAP; provides two different possibilities to store generators of the
##  representatives of classes of subgroups.
##  The first is implemented by the attribute
##  <Ref Attr="GeneratorsSubgroupsTom"/>, which uses explicit generators
##  of the subgroups.
##  The second, more general, possibility is implemented by the attribute
##  <Ref Attr="StraightLineProgramsTom"/>, which encodes the generators as
##  straight line programs (see&nbsp;<Ref Sect="Straight Line Programs"/>)
##  that evaluate to the generators in question when applied to
##  <E>standard generators</E> of <M>G</M>.
##  <!--, see <Ref Sect="Standard Generators of Groups" BookName="tomlib"/>. -->
##  This means that on the one hand, standard generators of <M>G</M> must be
##  known in order to use <Ref Attr="StraightLineProgramsTom"/>.
##  On the other hand, the straight line programs allow one to compute easily
##  generators not only of a subgroup <M>U</M> of <M>G</M> but also
##  generators of the image of <M>U</M> in any representation of <M>G</M>,
##  provided that one knows standard generators of the image of <M>G</M>
##  under this representation.
##  See the manual of the package <Package>TomLib</Package> for details
##  and an example.
##  <#/GAPDoc>
##


#############################################################################
##
#A  GeneratorsSubgroupsTom( <tom> )
##
##  <#GAPDoc Label="GeneratorsSubgroupsTom">
##  <ManSection>
##  <Attr Name="GeneratorsSubgroupsTom" Arg='tom'/>
##
##  <Description>
##  Let <A>tom</A> be a table of marks with
##  <Ref Filt="IsTableOfMarksWithGens"/> value <K>true</K>.
##  Then <Ref Attr="GeneratorsSubgroupsTom"/> returns a list of length two,
##  the first entry being a list <M>l</M> of elements of the group stored as
##  <Ref Attr="UnderlyingGroup" Label="for tables of marks"/> value of
##  <A>tom</A>,
##  the second entry being a list that contains at position <M>i</M> a list
##  of positions in <M>l</M> of generators of a representative of a subgroup
##  in class <M>i</M>.
##  <P/>
##  The <Ref Attr="GeneratorsSubgroupsTom"/> value is known for all tables of
##  marks that have been computed with
##  <Ref Attr="TableOfMarks" Label="for a group"/> from a group,
##  and there is a method to compute the value for a table of marks that
##  admits <Ref Oper="RepresentativeTom"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsSubgroupsTom", IsTableOfMarks );


#############################################################################
##
#A  StraightLineProgramsTom( <tom> )
##
##  <#GAPDoc Label="StraightLineProgramsTom">
##  <ManSection>
##  <Attr Name="StraightLineProgramsTom" Arg='tom'/>
##
##  <Description>
##  For a table of marks <A>tom</A> with <Ref Filt="IsTableOfMarksWithGens"/>
##  value <K>true</K>,
##  <Ref Attr="StraightLineProgramsTom"/> returns a list that contains at
##  position <M>i</M> either a list of straight line programs or a
##  straight line program (see&nbsp;<Ref Sect="Straight Line Programs"/>),
##  encoding the generators of a representative of the <M>i</M>-th conjugacy
##  class of subgroups of <C>UnderlyingGroup( <A>tom</A> )</C>;
##  in the former case, each straight line program returns a generator,
##  in the latter case, the program returns the list of generators.
##  <P/>
##  There is no default method to compute the
##  <Ref Attr="StraightLineProgramsTom"/> value
##  of a table of marks if they are not yet stored.
##  The value is known for all tables of marks that belong to the
##  &GAP; library of tables of marks
##  (see&nbsp;<Ref Sect="The Library of Tables of Marks"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "StraightLineProgramsTom", IsTableOfMarks );


#############################################################################
##
#F  IsTableOfMarksWithGens( <tom> )
##
##  <#GAPDoc Label="IsTableOfMarksWithGens">
##  <ManSection>
##  <Filt Name="IsTableOfMarksWithGens" Arg='tom'/>
##
##  <Description>
##  This filter shall express the union of the filters
##  <C>IsTableOfMarks and HasStraightLineProgramsTom</C> and
##  <C>IsTableOfMarks and HasGeneratorsSubgroupsTom</C>.
##  If a table of marks <A>tom</A> has this filter set then <A>tom</A> can be
##  asked to compute information that is in general not uniquely determined
##  by a table of marks,
##  for example the positions of derived subgroups or normalizers of
##  subgroups
##  (see&nbsp;<Ref Oper="DerivedSubgroupTom"/>, <Ref Oper="NormalizerTom"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> a5:= TableOfMarks( "A5" );;  IsTableOfMarksWithGens( a5 );
##  true
##  gap> HasGeneratorsSubgroupsTom( a5 );  HasStraightLineProgramsTom( a5 );
##  false
##  true
##  gap> alt5:= TableOfMarks( AlternatingGroup( 5 ) );;
##  gap> IsTableOfMarksWithGens( alt5 );
##  true
##  gap> HasGeneratorsSubgroupsTom(alt5); HasStraightLineProgramsTom(alt5);
##  true
##  false
##  gap> progs:= StraightLineProgramsTom( a5 );;
##  gap> OrdersTom( a5 );
##  [ 1, 2, 3, 4, 5, 6, 10, 12, 60 ]
##  gap> IsCyclicTom( a5, 4 );
##  false
##  gap> Length( progs[4] );
##  2
##  gap> progs[4][1];
##  <straight line program>
##  gap> # first generator of an el. ab group of order 4:
##  gap> Display( progs[4][1] );
##  # input:
##  r:= [ g1, g2 ];
##  # program:
##  r[3]:= r[2]*r[1];
##  r[4]:= r[3]*r[2]^-1*r[1]*r[3]*r[2]^-1*r[1]*r[2];
##  # return value:
##  r[4]
##  gap> x:= [ [ Z(2)^0, 0*Z(2) ], [ Z(2^2), Z(2)^0 ] ];;
##  gap> y:= [ [ Z(2^2), Z(2)^0 ], [ 0*Z(2), Z(2^2)^2 ] ];;
##  gap> res1:= ResultOfStraightLineProgram( progs[4][1], [ x, y ] );
##  [ [ Z(2)^0, 0*Z(2) ], [ Z(2^2)^2, Z(2)^0 ] ]
##  gap> res2:= ResultOfStraightLineProgram( progs[4][2], [ x, y ] );
##  [ [ Z(2)^0, 0*Z(2) ], [ Z(2^2), Z(2)^0 ] ]
##  gap> w:= y*x;;
##  gap> res1 = w*y^-1*x*w*y^-1*x*y;
##  true
##  gap> subgrp:= Group( res1, res2 );;  Size( subgrp );  IsCyclic( subgrp );
##  4
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
#O  RepresentativeTomByGeneratorsNC( <tom>, <sub>, <gens> )
##
##  <#GAPDoc Label="RepresentativeTom">
##  <ManSection>
##  <Oper Name="RepresentativeTom" Arg='tom, sub'/>
##  <Oper Name="RepresentativeTomByGenerators" Arg='tom, sub, gens'/>
##  <Oper Name="RepresentativeTomByGeneratorsNC" Arg='tom, sub, gens'/>
##
##  <Description>
##  Let <A>tom</A> be a table of marks with
##  <Ref Filt="IsTableOfMarksWithGens"/> value <K>true</K>,
##  and <A>sub</A> a positive integer.
##  <Ref Oper="RepresentativeTom"/> returns a representative of the
##  <A>sub</A>-th conjugacy class of subgroups of <A>tom</A>.
##  <P/>
##  If the attribute <Ref Attr="StraightLineProgramsTom"/> is set in
##  <A>tom</A> then methods for the operations
##  <Ref Oper="RepresentativeTomByGenerators"/> and
##  <Ref Oper="RepresentativeTomByGeneratorsNC"/> are available, which
##  return a representative of the <A>sub</A>-th conjugacy class of subgroups
##  of <A>tom</A>, as a subgroup of the group generated by <A>gens</A>.
##  This means that the standard generators of <A>tom</A> are replaced by
##  <A>gens</A>.
##  <P/>
##  <Ref Oper="RepresentativeTomByGenerators"/> checks whether mapping the
##  standard generators of <A>tom</A> to <A>gens</A> extends to a group
##  isomorphism, and returns <K>fail</K> if not.
##  <Ref Oper="RepresentativeTomByGeneratorsNC"/> omits all checks.
##  So <Ref Oper="RepresentativeTomByGenerators"/> is thought mainly for
##  debugging purposes;
##  note that when several representatives are constructed, it is cheaper to
##  construct (and check) the isomorphism once, and to map the groups
##  returned by <Ref Oper="RepresentativeTom"/> under this isomorphism.
##  The idea behind <Ref Oper="RepresentativeTomByGeneratorsNC"/>, however,
##  is to avoid the overhead of using isomorphisms when <A>gens</A> are known
##  to be standard generators.
##  In order to proceed like this, the attribute
##  <Ref Attr="StraightLineProgramsTom"/> is needed.
##  <P/>
##  <Example><![CDATA[
##  gap> RepresentativeTom( a5, 4 );
##  Group([ (2,3)(4,5), (2,4)(3,5) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
#O  PossibleFusionsCharTableTom( <tbl>, <tom>[, <options>] ) .  element fusion
##
##  <#GAPDoc Label="FusionCharTableTom">
##  <ManSection>
##  <Oper Name="FusionCharTableTom" Arg='tbl, tom'/>
##  <Oper Name="PossibleFusionsCharTableTom" Arg='tbl, tom[, options]'/>
##
##  <Description>
##  Let <A>tbl</A> be the ordinary character table of the group <M>G</M>,
##  say, and <A>tom</A> the table of marks of <M>G</M>.
##  <Ref Oper="FusionCharTableTom"/> determines the fusion of the classes of
##  elements from <A>tbl</A> to the classes of cyclic subgroups on
##  <A>tom</A>, that is, a list that contains at position <M>i</M> the
##  position of the class of cyclic subgroups in <A>tom</A> that are
##  generated by elements in the <M>i</M>-th conjugacy class of elements in
##  <A>tbl</A>.
##  <P/>
##  Three cases are handled differently.
##  <Enum>
##  <Item>
##    The fusion is explicitly stored on <A>tbl</A>.
##    Then nothing has to be done.
##    This happens only if both <A>tbl</A> and <A>tom</A> are tables from the
##    &GAP; library (see&nbsp;<Ref Sect="The Library of Tables of Marks"/>
##    and the manual of the &GAP; Character Table Library).
##  </Item>
##  <Item>
##    The <Ref Attr="UnderlyingGroup" Label="for tables of marks"/> values of
##    <A>tbl</A> and <A>tom</A> are known and equal.
##    Then the group is used to compute the fusion.
##  </Item>
##  <Item>
##    There is neither fusion nor group information available.
##    In this case only necessary conditions can be checked,
##    and if they are not sufficient to determine the fusion uniquely then
##    <K>fail</K> is returned by <Ref Oper="FusionCharTableTom"/>.
##  </Item>
##  </Enum>
##  <P/>
##  <Ref Oper="PossibleFusionsCharTableTom"/> computes the list of possible
##  fusions from <A>tbl</A> to <A>tom</A>,
##  according to the criteria that have been checked.
##  So if <Ref Oper="FusionCharTableTom"/> returns a unique fusion then the
##  list returned by <Ref Oper="PossibleFusionsCharTableTom"/> for the same
##  arguments contains exactly this fusion,
##  and if <Ref Oper="FusionCharTableTom"/> returns <K>fail</K> then the
##  length of this list is different from <M>1</M>.
##  <!-- this is fishy!-->
##  <P/>
##  The optional argument <A>options</A> must be a record that may have the
##  following components.
##  <List>
##  <Mark><C>fusionmap</C></Mark>
##  <Item>
##    a parametrized map which is an approximation of the desired map,
##  </Item>
##  <Mark><C>quick</C></Mark>
##  <Item>
##    a Boolean;
##    if <K>true</K> then as soon as only one possibility remains
##    this possibility is returned immediately;
##    the default value is <K>false</K>.
##  </Item>
##  </List>
##  <P/>
##  <Example><![CDATA[
##  gap> a5c:= CharacterTable( "A5" );;
##  gap> fus:= FusionCharTableTom( a5c, a5 );
##  [ 1, 2, 3, 5, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FusionCharTableTom",
    [ IsOrdinaryTable, IsTableOfMarks ] );

DeclareOperation( "PossibleFusionsCharTableTom",
    [ IsOrdinaryTable, IsTableOfMarks ] );

DeclareOperation( "PossibleFusionsCharTableTom",
    [ IsOrdinaryTable, IsTableOfMarks, IsRecord ] );


#############################################################################
##
#O  PermCharsTom( <fus>, <tom> )
#O  PermCharsTom( <tbl>, <tom> )
##
##  <#GAPDoc Label="PermCharsTom">
##  <ManSection>
##  <Oper Name="PermCharsTom" Arg='fus, tom' Label="via fusion map"/>
##  <Oper Name="PermCharsTom" Arg='tbl, tom' Label="from a character table"/>
##
##  <Description>
##  <Ref Oper="PermCharsTom" Label="via fusion map"/> returns the list of
##  transitive permutation characters from the table of marks <A>tom</A>.
##  In the first form, <A>fus</A> must be the fusion map from the ordinary
##  character table of the group of <A>tom</A> to <A>tom</A>
##  (see&nbsp;<Ref Oper="FusionCharTableTom"/>).
##  In the second form, <A>tbl</A> must be the character table of the group
##  of which <A>tom</A> is the table of marks.
##  If the fusion map is not uniquely determined
##  (see&nbsp;<Ref Oper="FusionCharTableTom"/>) then <K>fail</K> is returned.
##  <P/>
##  If the fusion map <A>fus</A> is given as first argument then each
##  transitive permutation character is represented by its values list.
##  If the character table <A>tbl</A> is given then the permutation
##  characters are class function objects
##  (see Chapter&nbsp;<Ref Chap="Class Functions"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> PermCharsTom( a5c, a5 );
##  [ Character( CharacterTable( "A5" ), [ 60, 0, 0, 0, 0 ] ),
##    Character( CharacterTable( "A5" ), [ 30, 2, 0, 0, 0 ] ),
##    Character( CharacterTable( "A5" ), [ 20, 0, 2, 0, 0 ] ),
##    Character( CharacterTable( "A5" ), [ 15, 3, 0, 0, 0 ] ),
##    Character( CharacterTable( "A5" ), [ 12, 0, 0, 2, 2 ] ),
##    Character( CharacterTable( "A5" ), [ 10, 2, 1, 0, 0 ] ),
##    Character( CharacterTable( "A5" ), [ 6, 2, 0, 1, 1 ] ),
##    Character( CharacterTable( "A5" ), [ 5, 1, 2, 0, 0 ] ),
##    Character( CharacterTable( "A5" ), [ 1, 1, 1, 1, 1 ] ) ]
##  gap> PermCharsTom( fus, a5 )[1];
##  [ 60, 0, 0, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PermCharsTom", [ IsList, IsTableOfMarks ] );
DeclareOperation( "PermCharsTom", [ IsOrdinaryTable, IsTableOfMarks ] );


#############################################################################
##
##  13. Generic Construction of Tables of Marks
##
##  <#GAPDoc Label="[9]{tom}">
##  The following three operations construct a table of marks only from the
##  data given, i.e., without underlying group.
##  <#/GAPDoc>
##


#############################################################################
##
#O  TableOfMarksCyclic( <n> )
##
##  <#GAPDoc Label="TableOfMarksCyclic">
##  <ManSection>
##  <Oper Name="TableOfMarksCyclic" Arg='n'/>
##
##  <Description>
##  <Ref Oper="TableOfMarksCyclic"/> returns the table of marks of the cyclic
##  group of order <A>n</A>.
##  <P/>
##  A cyclic group of order <A>n</A> has as its subgroups for each divisor
##  <M>d</M> of <A>n</A> a cyclic subgroup of order <M>d</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> Display( TableOfMarksCyclic( 6 ) );
##  1:  6
##  2:  3 3
##  3:  2 . 2
##  4:  1 1 1 1
##
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TableOfMarksCyclic", [ IsPosInt ] );


#############################################################################
##
#O  TableOfMarksDihedral( <n> )
##
##  <#GAPDoc Label="TableOfMarksDihedral">
##  <ManSection>
##  <Oper Name="TableOfMarksDihedral" Arg='n'/>
##
##  <Description>
##  <Ref Oper="TableOfMarksDihedral"/> returns the table of marks of the
##  dihedral group of order <A>m</A>.
##  <P/>
##  For each divisor <M>d</M> of <A>m</A>, a dihedral group of order
##  <M>m = 2n</M> contains subgroups of order <M>d</M> according to the
##  following rule.
##  If <M>d</M> is odd and divides <M>n</M> then there is only one cyclic
##  subgroup of order <M>d</M>.
##  If <M>d</M> is even and divides <M>n</M> then there are a cyclic subgroup
##  of order <M>d</M> and two classes of dihedral subgroups of order <M>d</M>
##  (which are cyclic, too, in the case <M>d = 2</M>, see the example below).
##  Otherwise (i.e., if <M>d</M> does not divide <M>n</M>) there is just one
##  class of dihedral subgroups of order <M>d</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> Display( TableOfMarksDihedral( 12 ) );
##   1:  12
##   2:   6 6
##   3:   6 . 2
##   4:   6 . . 2
##   5:   4 . . . 4
##   6:   3 3 1 1 . 1
##   7:   2 2 . . 2 . 2
##   8:   2 . 2 . 2 . . 2
##   9:   2 . . 2 2 . . . 2
##  10:   1 1 1 1 1 1 1 1 1 1
##
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TableOfMarksDihedral", [ IsPosInt ] );


#############################################################################
##
#O  TableOfMarksFrobenius( <p>, <q> )
##
##  <#GAPDoc Label="TableOfMarksFrobenius">
##  <ManSection>
##  <Oper Name="TableOfMarksFrobenius" Arg='p, q'/>
##
##  <Description>
##  <Ref Oper="TableOfMarksFrobenius"/> computes the table of marks of a
##  Frobenius group of order <M>p q</M>, where <M>p</M> is a prime and
##  <M>q</M> divides <M>p-1</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> Display( TableOfMarksFrobenius( 5, 4 ) );
##  1:  20
##  2:  10 2
##  3:   5 1 1
##  4:   4 . . 4
##  5:   2 2 . 2 2
##  6:   1 1 1 1 1 1
##
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TableOfMarksFrobenius", [ IsPosInt, IsPosInt ] );


#############################################################################
##
#V  TableOfMarksComponents
##
##  <#GAPDoc Label="TableOfMarksComponents">
##  <ManSection>
##  <Var Name="TableOfMarksComponents"/>
##
##  <Description>
##  The list <Ref Var="TableOfMarksComponents"/> is used when a
##  table of marks object is created from a record via
##  <Ref Func="ConvertToTableOfMarks"/>.
##  <Ref Var="TableOfMarksComponents"/> contains at position <M>2i-1</M>
##  a name of an attribute and at position <M>2i</M> the corresponding
##  attribute getter function.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "TableOfMarksComponents", MakeImmutable([
      "Identifier",                 Identifier,
      "SubsTom",                    SubsTom,
      "MarksTom",                   MarksTom,
      "NrSubsTom",                  NrSubsTom,
      "OrdersTom",                  OrdersTom,
      "NormalizersTom",             NormalizersTom,
      "DerivedSubgroupsTomUnique",  DerivedSubgroupsTomUnique,
      "UnderlyingGroup",            UnderlyingGroup,
      "StraightLineProgramsTom",    StraightLineProgramsTom,
      "GeneratorsSubgroupsTom",     GeneratorsSubgroupsTom,
      "PermutationTom",             PermutationTom,
      "ClassNamesTom",              ClassNamesTom,
    ]) );
