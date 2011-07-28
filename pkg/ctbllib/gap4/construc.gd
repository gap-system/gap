#############################################################################
##
#W  construc.gd           GAP 4 package `ctbllib'               Thomas Breuer
##
#H  @(#)$Id: construc.gd,v 1.25 2011/02/11 16:04:44 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  1. Character Tables of Groups of Structure $M.G.A$
##  2. Character Tables of Groups of Structure $G.S_3$
##  3. Character Tables of Groups of Structure $G.2^2$
##  4. Character Tables of Groups of Structure $2^2.G$
##  5. Character Tables of Subdirect Products of Index Two
##  6. Brauer Tables of Extensions by $p$-regular Automorphisms
##  7. Construction Functions used in the Character Table Library
##  8. Character Tables of Coprime Central Extensions
##  9. Miscellaneous
##
Revision.( "ctbllib/gap4/construc_gd" ) :=
    "@(#)$Id: construc.gd,v 1.25 2011/02/11 16:04:44 gap Exp $";


#############################################################################
##
##  <#GAPDoc Label="construc:intro">
##  The functions in this chapter deal with the construction of character
##  tables from other character tables.
##  So they fit to the functions in
##  Section&nbsp;<Ref Sect="Constructing Character Tables from Others"
##  BookName="ref"/>.
##  But since they are used in situations that are typical for the &GAP;
##  Character Table Library, they are described here.
##  <P/>
##  An important ingredient of the constructions is the description of the
##  action of a group automorphism on the classes by a permutation.
##  In practice, these permutations are usually chosen from the group of
##  table automorphisms of the character table in question,
##  see&nbsp;<Ref Func="AutomorphismsOfTable" BookName="ref"/>.
##  <P/>
##  Section&nbsp;<Ref Sect="sec:construc:MGA"/> deals with
##  groups of the structure <M>M.G.A</M>,
##  where the upwards extension <M>G.A</M> acts suitably
##  on the central extension <M>M.G</M>.
##  Section&nbsp;<Ref Sect="sec:construc:GS3"/> deals with
##  groups that have a factor group of type <M>S_3</M>.
##  Section&nbsp;<Ref Sect="sec:construc:GV4"/> deals with
##  upward extensions of a group by a Klein four group.
##  Section&nbsp;<Ref Sect="sec:construc:V4G"/> deals with
##  downward extensions of a group by a Klein four group.
##  Section&nbsp;<Ref Sect="sec:construc:preg"/> describes
##  the construction of certain Brauer tables.
##  Section&nbsp;<Ref Sect="sec:construc:cenex"/> deals with
##  special cases of the construction of character tables of central
##  extensions from known character tables of suitable factor groups.
##  Section&nbsp;<Ref Sect="sec:construc:functions"/> documents
##  the functions used to encode certain tables in the &GAP;
##  Character Table Library.
##  <P/>
##  Examples can be found in <Cite Key="Auto"/> and <Cite Key="CCE"/>.
##  <#/GAPDoc>
##


#############################################################################
##
##  1. Character Tables of Groups of Structure <M>M.G.A</M>
##


#############################################################################
##
#F  PossibleCharacterTablesOfTypeMGA( <tblMG>, <tblG>, <tblGA>, <orbs>,
#F      <identifier> )
##
##  <#GAPDoc Label="PossibleCharacterTablesOfTypeMGA">
##  <ManSection>
##  <Func Name="PossibleCharacterTablesOfTypeMGA"
##  Arg="tblMG, tblG, tblGA, orbs, identifier"/>
##
##  <Description>
##  Let <M>H</M> be a group with normal subgroups <M>N</M> and <M>M</M>
##  such that <M>H/N</M> is cyclic, <M>M \leq N</M> holds,
##  and such that each irreducible character of <M>N</M>
##  that does not contain <M>M</M> in its kernel
##  induces irreducibly to <M>H</M>.
##  (This is satisfied for example if <M>N</M> has prime index in <M>H</M>
##  and <M>M</M> is a group of prime order that is central in <M>N</M>
##  but not in <M>H</M>.)
##  Let <M>G = N/M</M> and <M>A = H/N</M>,
##  so <M>H</M> has the structure <M>M.G.A</M>.
##  <P/>
##  Let <A>tblMG</A>, <A>tblG</A>, <A>tblGA</A> be the ordinary character
##  tables of the groups <M>M.G = N</M>, <M>G</M>, and <M>G.A = H/M</M>,
##  respectively,
##  and <A>orbs</A> be the list of orbits on the class positions of
##  <A>tblMG</A> that is induced by the action of <M>H</M> on <M>M.G</M>.
##  Furthermore, let the class fusions from <A>tblMG</A> to <A>tblG</A>
##  and from <A>tblG</A> to <A>tblGA</A> be stored on <A>tblMG</A>
##  and <A>tblG</A>, respectively
##  (see&nbsp;<Ref Func="StoreFusion" BookName="ref"/>).
##  <P/>
##  <Ref Func="PossibleCharacterTablesOfTypeMGA"/> returns a list of records
##  describing all possible ordinary character tables
##  for groups <M>H</M> that are compatible with the arguments.
##  Note that in general there may be several possible groups <M>H</M>,
##  and it may also be that <Q>character tables</Q> are constructed
##  for which no group exists.
##  <P/>
##  Each of the records in the result has the following components.
##  <List>
##  <Mark>table</Mark>
##  <Item>
##    a possible ordinary character table for <M>H</M>, and
##  </Item>
##  <Mark>MGfusMGA</Mark>
##  <Item>
##    the fusion map from <A>tblMG</A> into the table stored in <C>table</C>.
##  </Item>
##  </List>
##  The possible tables differ w.&nbsp;r.&nbsp;t. some power maps,
##  and perhaps element orders and table automorphisms;
##  in particular, the <C>MGfusMGA</C> component is the same in all records.
##  <P/>
##  The returned tables have the <Ref Attr="Identifier" BookName="ref"/>
##  value <A>identifier</A>.
##  The classes of these tables are sorted as follows.
##  First come the classes contained in <M>M.G</M>,
##  sorted compatibly with the classes in <A>tblMG</A>,
##  then the classes in <M>H \setminus M.G</M> follow,
##  in the same ordering as the classes of <M>G.A \setminus G</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PossibleCharacterTablesOfTypeMGA" );


#############################################################################
##
#F  BrauerTableOfTypeMGA( <modtblMG>, <modtblGA>, <ordtblMGA> )
##
##  <#GAPDoc Label="BrauerTableOfTypeMGA">
##  <ManSection>
##  <Func Name="BrauerTableOfTypeMGA" Arg="modtblMG, modtblGA, ordtblMGA"/>
##
##  <Description>
##  Let <M>H</M>, <M>N</M>, and <M>M</M> be as described for
##  <Ref Func="PossibleCharacterTablesOfTypeMGA"/>,
##  let <A>modtblMG</A> and <A>modtblGA</A> be the <M>p</M>-modular character
##  tables of the groups <M>N</M> and <M>H/M</M>, respectively, and let
##  <A>ordtblMGA</A> be the <M>p</M>-modular Brauer table of <M>H</M>,
##  for some prime integer <M>p</M>.
##  Furthermore, let the class fusions from the ordinary character table of
##  <A>modtblMG</A> to <A>ordtblMGA</A> and from <A>ordtblMGA</A> to the
##  ordinary character table of <A>modtblGA</A> be stored.
##  <P/>
##  <Ref Func="BrauerTableOfTypeMGA"/> returns the <M>p</M>-modular character
##  table of <M>H</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BrauerTableOfTypeMGA" );


#############################################################################
##
#F  PossibleActionsForTypeMGA( <tblMG>, <tblG>, <tblGA> )
##
##  <#GAPDoc Label="PossibleActionsForTypeMGA">
##  <ManSection>
##  <Func Name="PossibleActionsForTypeMGA" Arg="tblMG, tblG, tblGA"/>
##
##  <Description>
##  Let the arguments be as described for
##  <Ref Func="PossibleCharacterTablesOfTypeMGA"/>.
##  <Ref Func="PossibleActionsForTypeMGA"/> returns the set of
##  orbit structures <M>\Omega</M> on the class positions of <A>tblMG</A>
##  that can be induced by the action of <M>H</M> on the classes of
##  <M>M.G</M> in the sense that <M>\Omega</M> is the set of orbits
##  of a table automorphism of <A>tblMG</A>
##  (see&nbsp;<Ref Func="AutomorphismsOfTable" BookName="ref"/>)
##  that is compatible with the stored class fusions from <A>tblMG</A>
##  to <A>tblG</A> and from <A>tblG</A> to <A>tblGA</A>.
##  Note that the number of these orbit structures can be smaller than the
##  number of the underlying table automorphisms.
##  <P/>
##  Information about the progress is reported if the info level of
##  <Ref InfoClass="InfoCharacterTable" BookName="ref"/> is at least <M>1</M>
##  (see&nbsp;<Ref Func="SetInfoLevel" BookName="ref"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PossibleActionsForTypeMGA" );


#############################################################################
##
##  2. Character Tables of Groups of Structure <M>G.S_3</M>
##


#############################################################################
##
#F  CharacterTableOfTypeGS3( <tbl>, <tbl2>, <tbl3>, <aut>, <identifier> )
#F  CharacterTableOfTypeGS3( <modtbl>, <modtbl2>, <modtbl3>, <ordtbls3>,
#F                           <identifier> )
##
##  <#GAPDoc Label="CharacterTableOfTypeGS3">
##  <ManSection>
##  <Func Name="CharacterTableOfTypeGS3"
##  Arg="tbl, tbl2, tbl3, aut, identifier"/>
##  <Func Name="CharacterTableOfTypeGS3"
##  Arg="modtbl, modtbl2, modtbl3, ordtbls3, identifier"
##  Label="for Brauer tables"/>
##
##  <Description>
##  Let <M>H</M> be a group with a normal subgroup <M>G</M>
##  such that <M>H/G \cong S_3</M>, the symmetric group on three points,
##  and let <M>G.2</M> and <M>G.3</M> be preimages of subgroups of order
##  <M>2</M> and <M>3</M>, respectively,
##  under the natural projection onto this factor group.
##  <P/>
##  In the first form, let <A>tbl</A>, <A>tbl2</A>, <A>tbl3</A> be
##  the ordinary character tables of the groups <M>G</M>, <M>G.2</M>,
##  and <M>G.3</M>, respectively,
##  and <A>aut</A> be the permutation of classes of <A>tbl3</A>
##  induced by the action of <M>H</M> on <M>G.3</M>.
##  Furthermore assume that the class fusions from <A>tbl</A> to <A>tbl2</A>
##  and <A>tbl3</A> are stored on <A>tbl</A>
##  (see&nbsp;<Ref Func="StoreFusion" BookName="ref"/>).
##  <P/>
##  In the second form, let <A>modtbl</A>, <A>modtbl2</A>, <A>modtbl3</A> be
##  the <M>p</M>-modular character tables of the groups <M>G</M>, <M>G.2</M>,
##  and <M>G.3</M>, respectively,
##  and <A>ordtbls3</A> be the ordinary character table of <M>H</M>.
##  <P/>
##  <Ref Func="CharacterTableOfTypeGS3"/> returns a record with the following
##  components.
##  <List>
##  <Mark>table</Mark>
##  <Item>
##    the ordinary or <M>p</M>-modular character table of <M>H</M>,
##    respectively,
##  </Item>
##  <Mark>tbl2fustbls3</Mark>
##  <Item>
##    the fusion map from <A>tbl2</A> into the table of <M>H</M>, and
##  </Item>
##  <Mark>tbl3fustbls3</Mark>
##  <Item>
##    the fusion map from <A>tbl3</A> into the table of <M>H</M>.
##  </Item>
##  </List>
##  <P/>
##  The returned table of <M>H</M> has the
##  <Ref Attr="Identifier" BookName="ref"/> value <A>identifier</A>.
##  The classes of the table of <M>H</M> are sorted as follows.
##  First come the classes contained in <M>G.3</M>,
##  sorted compatibly with the classes in <A>tbl3</A>,
##  then the classes in <M>H \setminus G.3</M> follow,
##  in the same ordering as the classes of <M>G.2 \setminus G</M>.
##  <P/>
##  In fact the code is applicable in the more general case that <M>H/G</M>
##  is a Frobenius group <M>F = K C</M> with abelian kernel <M>K</M>
##  and cyclic complement <M>C</M> of prime order,
##  see&nbsp;<Cite Key="Auto"/>.
##  Besides <M>F = S_3</M>,
##  e.&nbsp;g., the case <M>F = A_4</M> is interesting.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterTableOfTypeGS3" );


#############################################################################
##
#F  PossibleActionsForTypeGS3( <tbl>, <tbl2>, <tbl3> )
##
##  <#GAPDoc Label="PossibleActionsForTypeGS3">
##  <ManSection>
##  <Func Name="PossibleActionsForTypeGS3" Arg="tbl, tbl2, tbl3"/>
##
##  <Description>
##  Let the arguments be as described for
##  <Ref Func="CharacterTableOfTypeGS3"/>.
##  <Ref Func="PossibleActionsForTypeGS3"/> returns the set of those
##  table automorphisms
##  (see&nbsp;<Ref Func="AutomorphismsOfTable" BookName="ref"/>)
##  of <A>tbl3</A> that can be induced by the action of <M>H</M>
##  on the classes of <A>tbl3</A>.
##  <P/>
##  Information about the progress is reported if the info level of
##  <Ref InfoClass="InfoCharacterTable" BookName="ref"/> is at least <M>1</M>
##  (see&nbsp;<Ref Func="SetInfoLevel" BookName="ref"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PossibleActionsForTypeGS3" );


#############################################################################
##
##  3. Character Tables of Groups of Structure <M>G.2^2</M>
##
##  <#GAPDoc Label="construc:GV4">
##  The following functions are thought for constructing the possible
##  ordinary character tables of a group of structure <M>G.2^2</M>
##  from the known tables of the three normal subgroups of type <M>G.2</M>.
##  <#/GAPDoc>
##


#############################################################################
##
#F  PossibleCharacterTablesOfTypeGV4( <tblG>, <tblsG2>, <acts>, <identifier>
#F                                    [, <tblGfustblsG2>] )
#F  PossibleCharacterTablesOfTypeGV4( <modtblG>, <modtblsG2>, <ordtblGV4> )
##
##  <#GAPDoc Label="PossibleCharacterTablesOfTypeGV4">
##  <ManSection>
##  <Func Name="PossibleCharacterTablesOfTypeGV4"
##  Arg="tblG, tblsG2, acts, identifier[, tblGfustblsG2]"/>
##  <Func Name="PossibleCharacterTablesOfTypeGV4"
##  Arg="modtblG, modtblsG2, ordtblGV4" Label="for Brauer tables"/>
##
##  <Description>
##  Let <M>H</M> be a group with a normal subgroup <M>G</M>
##  such that <M>H/G</M> is a Klein four group,
##  and let <M>G.2_1</M>, <M>G.2_2</M>, and <M>G.2_3</M> be
##  the three subgroups of index two in <M>H</M> that contain <M>G</M>.
##  <P/>
##  In the first version, let <A>tblG</A> be the ordinary character table
##  of <M>G</M>,
##  let <A>tblsG2</A> be a list containing the three character tables of the
##  groups <M>G.2_i</M>, and
##  let <A>acts</A> be a list of three permutations describing
##  the action of <M>H</M> on the conjugacy classes
##  of the corresponding tables in <A>tblsG2</A>.
##  If the class fusions from <A>tblG</A> into the tables in <A>tblsG2</A>
##  are not stored on <A>tblG</A>
##  (for example, because the three tables are equal)
##  then the three maps must be entered in the list <A>tblGfustblsG2</A>.
##  <P/>
##  In the second version, let <A>modtblG</A> be the <M>p</M>-modular
##  character table of <M>G</M>, <A>modtblsG</A> be the list of
##  <M>p</M>-modular character tables of the groups <M>G.2_i</M>,
##  and <A>ordtblGV4</A> be the ordinary character table of <M>H</M>.
##  <P/>
##  <Ref Func="PossibleCharacterTablesOfTypeGV4"/> returns a list of records
##  describing all possible (ordinary or <M>p</M>-modular) character tables
##  for groups <M>H</M> that are compatible with the arguments.
##  Note that in general there may be several possible groups <M>H</M>,
##  and it may also be that <Q>character tables</Q> are constructed
##  for which no group exists.
##  Each of the records in the result has the following components.
##  <P/>
##  <List>
##  <Mark>table</Mark>
##  <Item>
##    a possible (ordinary or <M>p</M>-modular) character table for <M>H</M>,
##    and
##  </Item>
##  <Mark>G2fusGV4</Mark>
##  <Item>
##    the list of fusion maps from the tables in <A>tblsG2</A> into the
##    <C>table</C> component.
##  </Item>
##  </List>
##  <P/>
##  The possible tables differ w.r.t. the irreducible characters and perhaps
##  the table automorphisms;
##  in particular, the <C>G2fusGV4</C> component is the same in all records.
##  <P/>
##  The returned tables have the
##  <Ref Attr="Identifier" BookName="ref"/> value <A>identifier</A>.
##  The classes of these tables are sorted as follows.
##  First come the classes contained in <M>G</M>, sorted compatibly with the
##  classes in <A>tblG</A>,
##  then the outer classes in the tables in <A>tblsG2</A> follow,
##  in the same ordering as in these tables.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PossibleCharacterTablesOfTypeGV4" );


#############################################################################
##
#F  PossibleActionsForTypeGV4( <tblG>, <tblsG2> )
##
##  <#GAPDoc Label="PossibleActionsForTypeGV4">
##  <ManSection>
##  <Func Name="PossibleActionsForTypeGV4" Arg="tblG, tblsG2"/>
##
##  <Description>
##  Let the arguments be as described for
##  <Ref Func="PossibleCharacterTablesOfTypeGV4"/>.
##  <Ref Func="PossibleActionsForTypeGV4"/> returns the list of those triples
##  <M>[ \pi_1, \pi_2, \pi_3 ]</M> of permutations
##  for which a group <M>H</M> may exist
##  that contains <M>G.2_1</M>, <M>G.2_2</M>, <M>G.2_3</M>
##  as index <M>2</M> subgroups
##  which intersect in the index <M>4</M> subgroup <M>G</M>.
##  <P/>
##  Information about the progress is reported if the level of
##  <Ref InfoClass="InfoCharacterTable" BookName="ref"/> is at least <M>1</M>
##  (see&nbsp;<Ref Func="SetInfoLevel" BookName="ref"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PossibleActionsForTypeGV4" );


#############################################################################
##
##  4. Character Tables of Groups of Structure <M>2^2.G</M>
##
##  <#GAPDoc Label="construc:V4G">
##  The following functions are thought for constructing the possible
##  ordinary or Brauer character tables of a group of structure <M>2^2.G</M>
##  from the known tables of the three factor groups
##  modulo the normal order two subgroups in the central Klein four group.
##  <P/>
##  Note that in the ordinary case, only a list of possibilities can be
##  computed whereas in the modular case, where the ordinary character table
##  is assumed to be known, the desired table is uniquely determined.
##  <#/GAPDoc>
##


#############################################################################
##
#F  PossibleCharacterTablesOfTypeV4G( <tblG>, <tbls2G>, <id>[, <fusions>] )
#F  PossibleCharacterTablesOfTypeV4G( <tblG>, <tbl2G>, <aut>, <id> )
##
##  <#GAPDoc Label="PossibleCharacterTablesOfTypeV4G">
##  <ManSection>
##  <Heading>PossibleCharacterTablesOfTypeV4G</Heading>
##  <Func Name="PossibleCharacterTablesOfTypeV4G"
##  Arg="tblG, tbls2G, id[, fusions]"/>
##  <Func Name="PossibleCharacterTablesOfTypeV4G"
##  Arg="tblG, tbl2G, aut, id"
##  Label="for conj. ordinary tables, and an autom."/>
##
##  <Description>
##  Let <M>H</M> be a group with a central subgroup <M>N</M>
##  of type <M>2^2</M>,
##  and let <M>Z_1</M>, <M>Z_2</M>, <M>Z_3</M> be
##  the order <M>2</M> subgroups of <M>N</M>.
##  <P/>
##  In the first form, let <A>tblG</A> be the ordinary character table
##  of <M>H/N</M>,
##  and <A>tbls2G</A> be a list of length three,
##  the entries being the ordinary character tables
##  of the groups <M>H/Z_i</M>.
##  In the second form, let <A>tbl2G</A> be the ordinary character table of
##  <M>H/Z_1</M> and <A>aut</A> be a permutation;
##  here it is assumed that the groups <M>Z_i</M> are permuted under an
##  automorphism <M>\sigma</M> of order <M>3</M> of <M>H</M>,
##  and that <M>\sigma</M> induces the permutation <A>aut</A>
##  on the classes of <A>tblG</A>.
##  <P/>
##  The class fusions onto <A>tblG</A> are assumed to be stored
##  on the tables in <A>tbls2G</A> or <A>tbl2G</A>, respectively,
##  except if they are explicitly entered  via the optional argument
##  <A>fusions</A>.
##  <P/>
##  <Ref Func="PossibleCharacterTablesOfTypeV4G"/> returns the list of all
##  possible character tables for <M>H</M> in this situation.
##  The returned tables have the
##  <Ref Attr="Identifier" BookName="ref"/> value <A>id</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#T which criteria are used?
##
DeclareGlobalFunction( "PossibleCharacterTablesOfTypeV4G" );


#############################################################################
##  
#F  BrauerTableOfTypeV4G( <ordtblV4G>, <modtbls2G> )
#F  BrauerTableOfTypeV4G( <ordtblV4G>, <modtbl2G>, <aut>[, <ker>] )
##
##  <#GAPDoc Label="BrauerTableOfTypeV4G">
##  <ManSection>
##  <Heading>BrauerTableOfTypeV4G</Heading>
##  <Func Name="BrauerTableOfTypeV4G" Arg="ordtblV4G, modtbls2G"
##  Label="for three factors"/>
##  <Func Name="BrauerTableOfTypeV4G" Arg="ordtblV4G, modtbl2G, aut[, ker]"
##  Label="for one factor and an autom."/>
##
##  <Description>
##  Let <M>H</M> be a group with a central subgroup <M>N</M>
##  of type <M>2^2</M>,
##  and let <A>ordtblV4G</A> be the ordinary character table of <M>H</M>.
##  Let <M>Z_1</M>, <M>Z_2</M>, <M>Z_3</M> be
##  the order <M>2</M> subgroups of <M>N</M>.
##  In the first form,
##  let <A>modtbls2G</A> be the list of the <M>p</M>-modular Brauer tables
##  of the factor groups <M>H/Z_1</M>, <M>H/Z_2</M>, and <M>H/Z_3</M>,
##  for some prime integer <M>p</M>.
##  In the second form, let <A>modtbl2G</A> be the <M>p</M>-modular Brauer
##  table of <M>H/Z_1</M> and <A>aut</A> be a permutation;
##  here it is assumed that the groups <M>Z_i</M> are permuted under an
##  automorphism <M>\sigma</M> of order <M>3</M> of <M>H</M>,
##  and that <M>\sigma</M> induces the permutation <A>aut</A>
##  on the classes of the ordinary character table of <M>H</M> that is stored
##  in <A>ordtblV4G</A>.
##  <P/>
##  The class fusions from <A>ordtblV4G</A> to the ordinary character tables
##  of the tables in <A>modtbls2G</A> or <A>modtbl2G</A> are assumed to be
##  stored.
##  <P/>
##  <Ref Func="BrauerTableOfTypeV4G" Label="for three factors"/> returns
##  the <M>p</M>-modular character table of <M>H</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BrauerTableOfTypeV4G" );


#############################################################################
##
##  5. Character Tables of Subdirect Products of Index Two
##
##  <#GAPDoc Label="construc:subdirindex2">
##  The following function is thought for constructing the (ordinary or
##  Brauer) character tables of certain subdirect products
##  from the known tables of the factor groups and normal subgroups involved.
##  <#/GAPDoc>
##


#############################################################################
##
#F  CharacterTableOfIndexTwoSubdirectProduct( <tblH1>, <tblG1>,
#F       <tblH2>, <tblG2>, <identifier> )
##
##  <#GAPDoc Label="CharacterTableOfIndexTwoSubdirectProduct">
##  <ManSection>
##  <Func Name="CharacterTableOfIndexTwoSubdirectProduct"
##        Arg='tblH1, tblG1, tblH2, tblG2, identifier'/>
##
##  <Returns>
##  a record containing the character table of the subdirect product <M>G</M>
##  that is described by the first four arguments.
##  </Returns>
##
##  <Description>
##  Let <A>tblH1</A>, <A>tblG1</A>, <A>tblH2</A>, <A>tblG2</A> be the
##  character tables of groups <M>H_1</M>, <M>G_1</M>, <M>H_2</M>,
##  <M>G_2</M>, such that <M>H_1</M> and <M>H_2</M> have index two
##  in <M>G_1</M> and <M>G_2</M>, respectively, and such that the class
##  fusions corresponding to these embeddings are stored on <A>tblH1</A> and
##  <A>tblH1</A>, respectively.
##  <P/>
##  In this situation, the direct product of <M>G_1</M> and <M>G_2</M>
##  contains a unique subgroup <M>G</M> of index two
##  that contains the direct product of <M>H_1</M> and <M>H_2</M>
##  but does not contain any of the groups <M>G_1</M>, <M>G_2</M>.
##  <P/>
##  The function <Ref Func="CharacterTableOfIndexTwoSubdirectProduct"/>
##  returns a record with the following components.
##  <List>
##  <Mark><C>table</C></Mark>
##  <Item>
##    the character table of <M>G</M>,
##  </Item>
##  <Mark><C>H1fusG</C></Mark>
##  <Item>
##    the class fusion from <A>tblH1</A> into the table of <M>G</M>, and
##  </Item>
##  <Mark><C>H2fusG</C></Mark>
##  <Item>
##    the class fusion from <A>tblH2</A> into the table of <M>G</M>.
##  </Item>
##  </List>
##  <P/>
##  If the first four arguments are <E>ordinary</E> character tables
##  then the fifth argument <A>identifier</A> must be a string;
##  this is used as the <Ref Attr="Identifier" BookName="ref"/> value of the
##  result table.
##  <P/>
##  If the first four arguments are <E>Brauer</E> character tables for the
##  same characteristic then the fifth argument must be the ordinary
##  character table of the desired subdirect product.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterTableOfIndexTwoSubdirectProduct" );


#############################################################################
##
#F  ConstructIndexTwoSubdirectProduct( <tbl>, <tblH1>, <tblG1>, <tblH2>,
#F      <tblG2>, <permclasses>, <permchars> )
##
##  <#GAPDoc Label="ConstructIndexTwoSubdirectProduct">
##  <ManSection>
##  <Func Name="ConstructIndexTwoSubdirectProduct"
##        Arg='tbl, tblH1, tblG1, tblH2, tblG2, permclasses, permchars'/>
##
##  <Description>
##  <Ref Func="ConstructIndexTwoSubdirectProduct"/> constructs the
##  irreducible characters of the ordinary character table <A>tbl</A> of the
##  subdirect product of index two in the direct product of <A>tblG1</A> and
##  <A>tblG2</A>, which contains the direct product of <A>tblH1</A> and
##  <A>tblH2</A> but does not contain any of the direct factors <A>tblG1</A>,
##  <A>tblG2</A>.
##  W.&nbsp;r.&nbsp;t.&nbsp;the default ordering obtained from that given by
##  <Ref Oper="CharacterTableDirectProduct" BookName="ref"/>,
##  the columns and the rows of the matrix of irreducibles are permuted with
##  the permutations <A>permclasses</A> and <A>permchars</A>, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructIndexTwoSubdirectProduct" );


#############################################################################
##
#F  ConstructIndexTwoSubdirectProductInfo( <tbl>[, <tblH1>, <tblG1>,
#F      <tblH2>, <tblG2>] )
##
##  <#GAPDoc Label="ConstructIndexTwoSubdirectProductInfo">
##  <ManSection>
##  <Func Name="ConstructIndexTwoSubdirectProductInfo"
##        Arg='tbl[, tblH1, tblG1, tblH2, tblG2 ]'/>
##
##  <Returns>
##  a list of constriction descriptions, or a construction description,
##  or <K>fail</K>.
##  </Returns>
##  <Description>
##  Called with one argument <A>tbl</A>, an ordinary character table of the
##  group <M>G</M>, say,
##  <Ref Func="ConstructIndexTwoSubdirectProductInfo"/> analyzes the
##  possibilities to construct <A>tbl</A> from character tables of subgroups
##  <M>H_1</M>, <M>H_2</M> and factor groups <M>G_1</M>, <M>G_2</M>,
##  using <Ref Func="CharacterTableOfIndexTwoSubdirectProduct"/>.
##  The return value is a list of records with the following components.
##  <List>
##  <Mark><C>kernels</C></Mark>
##  <Item>
##    the list of class positions of <M>H_1</M>, <M>H_2</M> in <A>tbl</A>,
##  </Item>
##  <Mark><C>kernelsizes</C></Mark>
##  <Item>
##    the list of orders of <M>H_1</M>, <M>H_2</M>,
##  </Item>
##  <Mark><C>factors</C></Mark>
##  <Item>
##    the list of <Ref Attr="Identifier" BookName="ref"/> values of the
##    &GAP; library tables of the factors <M>G_2</M>, <M>G_1</M> of <M>G</M>
##    by <M>H_1</M>, <M>H_2</M>;
##    if no such table is available then the entry is <K>fail</K>, and
##  </Item>
##  <Mark><C>subgroups</C></Mark>
##  <Item>
##    the list of <Ref Attr="Identifier" BookName="ref"/> values of the
##    &GAP; library tables of the subgroups <M>H_2</M>, <M>H_1</M> of
##    <M>G</M>;
##    if no such tables are available then the entries are <K>fail</K>.
##  </Item>
##  </List>
##  <P/>
##  If the returned list is empty then either <A>tbl</A> does not have the
##  desired structure as a subdirect product,
##  <E>or</E> <A>tbl</A> is in fact a nontrivial direct product.
##  <P/>
##  Called with five arguments, the ordinary character tables of <M>G</M>,
##  <M>H_1</M>, <M>G_1</M>, <M>H_2</M>, <M>G_2</M>, 
##  <Ref Func="ConstructIndexTwoSubdirectProductInfo"/> returns a list that
##  can be used as the <Ref Attr="ConstructionInfoCharacterTable"/> value
##  for the character table of <M>G</M> from the other four character tables
##  using <Ref Func="CharacterTableOfIndexTwoSubdirectProduct"/>;
##  if this is not possible then <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructIndexTwoSubdirectProductInfo" );


#############################################################################
##
##  6. Brauer Tables of Extensions by <M>p</M>-regular Automorphisms
##
##  <#GAPDoc Label="construc:preg">
##  As for the construction of Brauer character tables from known tables,
##  the functions <Ref Func="PossibleCharacterTablesOfTypeMGA"/>,
##  <Ref Func="CharacterTableOfTypeGS3"/>,
##  and <Ref Func="PossibleCharacterTablesOfTypeGV4"/>
##  work for both ordinary and Brauer tables.
##  The following function is designed specially for Brauer tables.
##  <#/GAPDoc>
##


#############################################################################
##
#F  IBrOfExtensionBySingularAutomorphism( <modtbl>, <perm> )
#F  IBrOfExtensionBySingularAutomorphism( <modtbl>, <orbits> )
#F  IBrOfExtensionBySingularAutomorphism( <modtbl>, <ordexttbl> )
##
##  <#GAPDoc Label="IBrOfExtensionBySingularAutomorphism">
##  <ManSection>
##  <Func Name="IBrOfExtensionBySingularAutomorphism" Arg="modtbl, act"/>
##
##  <Description>
##  Let <A>modtbl</A> be a <M>p</M>-modular Brauer table
##  of the group <M>G</M>, say,
##  and suppose that the group <M>H</M>, say,
##  is an upward extension of <M>G</M> by an automorphism of order <M>p</M>.
##  <P/>
##  The second argument <A>act</A> describes the action of this automorphism.
##  It can be either a permutation of the columns of <A>modtbl</A>,
##  or a list of the <M>H</M>-orbits on the columns of <A>modtbl</A>,
##  or the ordinary character table of <M>H</M>
##  such that the class fusion from the ordinary table of <A>modtbl</A> into
##  this table is stored.
##  In all these cases, <Ref Func="IBrOfExtensionBySingularAutomorphism"/>
##  returns the values lists of the irreducible <M>p</M>-modular
##  Brauer characters of <M>H</M>.
##  <P/>
##  Note that the table head of the <M>p</M>-modular Brauer table of
##  <M>H</M>, in general without the <Ref Attr="Irr" BookName="ref"/>
##  attribute, can be obtained
##  by applying <Ref Func="CharacterTableRegular" BookName="ref"/> to the
##  ordinary character table of <M>H</M>,
##  but <Ref Func="IBrOfExtensionBySingularAutomorphism"/> can be used
##  also if the ordinary character table of <M>H</M> is not known,
##  and just the <M>p</M>-modular character table of <M>G</M> and the action
##  of <M>H</M> on the classes of <M>G</M> are given.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IBrOfExtensionBySingularAutomorphism" );


#############################################################################
##
##  7. Construction Functions used in the Character Table Library
##
##  <#GAPDoc Label="construc:functions">
##  The following functions are used in the &GAP; Character Table Library,
##  for encoding table constructions via the mechanism that is based on the
##  attribute <Ref Attr="ConstructionInfoCharacterTable"/>.
##  All construction functions take as their first argument a record that
##  describes the table to be constructed, and the function adds only those
##  components that are not yet contained in this record.
##  <#/GAPDoc>
##


#############################################################################
##
#F  ConstructMGA( <tbl>, <subname>, <factname>, <plan>, <perm> )
##
##  <#GAPDoc Label="ConstructMGA">
##  <ManSection>
##  <Func Name="ConstructMGA" Arg="tbl, subname, factname, plan, perm"/>
##
##  <Description>
##  <Ref Func="ConstructMGA"/> constructs the irreducible characters of the
##  ordinary character table <A>tbl</A> of a group <M>m.G.a</M>
##  where the automorphism <M>a</M> (a group of prime order) of <M>m.G</M>
##  acts notrivially on the central subgroup <M>m</M> of <M>m.G</M>.
##  <A>subname</A> is the name of the subgroup <M>m.G</M> which is a
##  (not necessarily cyclic) central extension of the
##  (not necessarily simple) group <M>G</M>,
##  <A>factname</A> is the name of the factor group <M>G.a</M>.
##  Then the faithful characters of <A>tbl</A> are induced from <M>m.G</M>.
##  <P/>
##  <A>plan</A> is a list, each entry being a list containing positions of
##  characters of <M>m.G</M> that form an orbit under the action of <M>a</M>
##  (the induction of characters is encoded this way).
##  <P/>
##  <A>perm</A> is the permutation that must be applied to the list of
##  characters that is obtained on appending the faithful characters to the
##  inflated characters of the factor group.
##  A nonidentity permutation occurs for example for groups of structure
##  <M>12.G.2</M> that are encoded via the subgroup <M>12.G</M>
##  and the factor group <M>6.G.2</M>,
##  where the faithful characters of <M>4.G.2</M> shall precede those
##  of <M>6.G.2</M>.
##  <P/>
##  Examples where <Ref Func="ConstructMGA"/> is used
##  to encode library tables are the tables of <M>3.F_{{3+}}.2</M>
##  (subgroup <M>3.F_{{3+}}</M>, factor group <M>F_{{3+}}.2</M>)
##  and <M>12_1.U_4(3).2_2</M>
##  (subgroup <M>12_1.U_4(3)</M>, factor group <M>6_1.U_4(3).2_2</M>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructMGA" );

DeclareSynonym( "ConstructMixed", ConstructMGA );


#############################################################################
##
#F  ConstructMGAInfo( <tblmGa>, <tblmG>, <tblGa> )
##
##  <#GAPDoc Label="ConstructMGAInfo">
##  <ManSection>
##  <Func Name="ConstructMGAInfo" Arg="tblmGa, tblmG, tblGa"/>
##
##  <Description>
##  Let <A>tblmGa</A> be the ordinary character table of a group of structure
##  <M>m.G.a</M>
##  where the factor group of prime order <M>a</M> acts nontrivially on
##  the normal subgroup of order <M>m</M> that is central in <M>m.G</M>,
##  <A>tblmG</A> be the character table of <M>m.G</M>,
##  and <A>tblGa</A> be the character table of the factor group <M>G.a</M>.
##  <P/>
##  <Ref Func="ConstructMGAInfo"/> returns the list that is to be stored
##  in the library version of <A>tblmGa</A>:
##  the first entry is the string <C>"ConstructMGA"</C>,
##  the remaining four entries are the last four arguments for the call to
##  <Ref Func="ConstructMGA"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructMGAInfo" );


#############################################################################
##
#F  ConstructGS3( <tbls3>, <tbl2>, <tbl3>, <ind2>, <ind3>, <ext>, <perm> )
#F  ConstructGS3Info( <tbl2>, <tbl3>, <tbls3> )
##
##  <#GAPDoc Label="ConstructGS3">
##  <ManSection>
##  <Func Name="ConstructGS3"
##  Arg="tbls3, tbl2, tbl3, ind2, ind3, ext, perm"/>
##  <Func Name="ConstructGS3Info" Arg="tbl2, tbl3, tbls3"/>
##
##  <Description>
##  <Ref Func="ConstructGS3"/> constructs the irreducibles
##  of an ordinary character table <A>tbls3</A> of type <M>G.S_3</M>
##  from the tables with names <A>tbl2</A> and <A>tbl3</A>,
##  which correspond to the groups <M>G.2</M> and <M>G.3</M>, respectively.
##  <A>ind2</A> is a list of numbers referring to irreducibles of
##  <A>tbl2</A>.
##  <A>ind3</A> is a list of pairs, each referring to irreducibles of
##  <A>tbl3</A>.
##  <A>ext</A> is a list of pairs, each referring to one irreducible
##  character of <A>tbl2</A> and one of <A>tbl3</A>.
##  <A>perm</A> is a permutation that must be applied to the irreducibles
##  after the construction.
##  <P/>
##  <Ref Func="ConstructGS3Info"/> returns a record with the components
##  <C>ind2</C>, <C>ind3</C>, <C>ext</C>, <C>perm</C>, and <C>list</C>,
##  as are needed for <Ref Func="ConstructGS3"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructGS3" );

DeclareGlobalFunction( "ConstructGS3Info" );


#############################################################################
##
#F  ConstructV4G( <tbl>, <facttbl>, <aut>[, <ker>] )
#F  ConstructV4GInfo( <tbl>, <facttbl>, <aut> )
##
##  <#GAPDoc Label="ConstructV4G">
##  <ManSection>
##  <Func Name="ConstructV4G" Arg="tbl, facttbl, aut[, ker]"/>
##
##  <Description>
##  Let <A>tbl</A> be the character table of a group of type <M>2^2.G</M>
##  where an outer automorphism of order <M>3</M> permutes
##  the three involutions in the central <M>2^2</M>.
##  Let <A>aut</A> be the permutation of classes of <A>tbl</A>
##  induced by that automorphism,
##  and <A>facttbl</A> be the name of the character table
##  of the factor group <M>2.G</M>.
##  Then <Ref Func="ConstructV4G"/> constructs the irreducible characters
##  of <A>tbl</A> from that information.
##  <P/>
##  The optional argument <A>ker</A> is an integer denoting the position
##  of the nontrivial class of the table of <M>2.G</M>
##  that lies in the kernel of the epimorphism onto <M>G</M>;
##  the default for <A>ker</A> is <M>2</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  `ConstructV4GInfo' returns a list that is needed for `ConstructV4G'.
##  The arguments are the character tables <tbl> and <facttbl> of $2^2.G$ and
##  $2.G$, respectively, and the permutation <aut> of classes of <tbl> that
##  is induced by the outer automorphism of order $3$.
##
DeclareGlobalFunction( "ConstructV4G" );

DeclareGlobalFunction( "ConstructV4GInfo" );


#############################################################################
##
#F  ConstructProj( <tbl>, <irrinfo> )
#F  ConstructProjInfo( <tbl>, <kernel> )
##
##  <#GAPDoc Label="ConstructProj">
##  <ManSection>
##  <Func Name="ConstructProj" Arg="tbl, irrinfo"/>
##  <Func Name="ConstructProjInfo" Arg="tbl, kernel"/>
##
##  <Description>
##  <Ref Func="ConstructProj"/> constructs the irreducible characters
##  of the record encoding the ordinary character table <A>tbl</A>
##  from projective characters of tables of factor groups,
##  which are stored in the <Ref Func="ProjectivesInfo"/> value
##  of the smallest factor;
##  the information about the name of this factor and the projectives to
##  take is stored in <A>irrinfo</A>.
##  <P/>
##  <Ref Func="ConstructProjInfo"/> takes an ordinary character table
##  <A>tbl</A> and a list <A>kernel</A> of class positions of a cyclic kernel
##  of order dividing <M>12</M>,
##  and returns a record with the components
##  <P/>
##  <List>
##  <Mark>tbl</Mark>
##  <Item>
##    a character table that is permutation isomorphic with <A>tbl</A>,
##    and sorted such that classes that differ only by multiplication with
##    elements in the classes of <A>kernel</A> are consecutive,
##  </Item>
##  <Mark>projectives</Mark>
##  <Item>
##    a record being the entry for the <C>projectives</C> list of the table
##    of the factor of <A>tbl</A> by <A>kernel</A>,
##    describing this part of the irreducibles of <A>tbl</A>, and
##  </Item>
##  <Mark>info</Mark>
##  <Item>
##    the value of <A>irrinfo</A>.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  <P/>
##
##  rewrite the following!
##
##  In order to encode a library table <M>t</M> as a <Q>projective table</Q>
##  relative to another library table <M>f</M>, say,
##  one has to do the following.
##  First the factor fusion from <M>t</M> to <M>f</M> must be stored on the
##  table of <M>t</M>, and <M>t</M> is written to a library file.
##  Then the result of <Ref Func="ConstructProjInfo"/>,
##  called for <M>t</M> and the kernel of the factor fusion,
##  is used as follows.
##  The list containing <C>"ConstructProj"</C> at its first position and the
##  <C>info</C> component is added as last entry
##  of the <C>MOT</C> call for this library version.
##  The <C>projectives</C> component is added to the
##  <Ref Func="ProjectivesInfo"/>
##  list of <M>f</M>, and a new library version of <M>f</M> is produced
##  (this contains the new projectives via an <C>ARC</C> call).
##  Finally, <F>etc/maketbl</F> is called in order to store the projection
##  for the factor fusion in the <F>ctprimar.tbl</F> data.
##
DeclareGlobalFunction( "ConstructProj" );

DeclareGlobalFunction( "ConstructProjInfo" );


#############################################################################
##
#F  ConstructDirectProduct( <tbl>, <factors>[, <permclasses>, <permchars>] )
##
##  <#GAPDoc Label="ConstructDirectProduct">
##  <ManSection>
##  <Func Name="ConstructDirectProduct"
##  Arg="tbl, factors[, permclasses, permchars]"/>
##
##  <Description>
##  The direct product of the library character tables described by the list
##  <A>factors</A> of table names is constructed using
##  <Ref Func="CharacterTableDirectProduct" BookName="ref"/>,
##  and all its components that are not yet stored on <A>tbl</A> are
##  added to <A>tbl</A>.
##  <P/>
##  The <Ref Attr="ComputedClassFusions" BookName="ref"/> value of <A>tbl</A>
##  is enlarged by the factor fusions from the direct product to the factors.
##  <P/>
##  If the optional arguments <A>permclasses</A>, <A>permchars</A> are given
##  then the classes and characters of the result are sorted accordingly.
##  <P/>
##  <A>factors</A> must have length at least two;
##  use <Ref Func="ConstructPermuted"/> in the case of only one factor.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructDirectProduct" );


#############################################################################
##
#F  ConstructSubdirect( <tbl>, <factors>, <choice> )
##
##  <#GAPDoc Label="ConstructSubdirect">
##  <ManSection>
##  <Func Name="ConstructSubdirect" Arg="tbl, factors, choice"/>
##
##  <Description>
##  The library table <A>tbl</A> is completed with help of the table
##  obtained by taking the direct product of the tables with names in the
##  list <A>factors</A>, and then taking the table consisting of the classes
##  in the list <A>choice</A>.
##  <P/>
##  Note that in general, the restriction to the classes of a normal subgroup
##  is not sufficient for describing the irreducible characters of this
##  normal subgroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructSubdirect" );


#############################################################################
##
#F  ConstructWreathSymmetric( <tbl>, <subname>, <n>
#F                            [, <permclasses>, <permchars>] )
##
##  <#GAPDoc Label="ConstructWreathSymmetric">
##  <ManSection>
##  <Func Name="ConstructWreathSymmetric"
##  Arg="tbl, subname, n[, permclasses, permchars]"/>
##
##  <Description>
##  The wreath product of the library character table with identifier value
##  <A>subname</A> with the symmetric group on <A>n</A> points is constructed
##  using <Ref Func="CharacterTableWreathSymmetric" BookName="ref"/>,
##  and all its components that are not yet stored on <A>tbl</A> are
##  added to <A>tbl</A>.
##  <P/>
##  If the optional arguments <A>permclasses</A>, <A>permchars</A> are given
##  then the classes and characters of the result are sorted accordingly.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructWreathSymmetric" );


#############################################################################
##
#F  ConstructIsoclinic( <tbl>, <factors>[, <nsg>[, <centre>]]
#F                      [, <permclasses>, <permchars>] )
##
##  <#GAPDoc Label="ConstructIsoclinic">
##  <ManSection>
##  <Func Name="ConstructIsoclinic"
##  Arg="tbl, factors[, nsg[, centre]][, permclasses, permchars]"/>
##
##  <Description>
##  constructs first the direct product of library tables as given by the
##  list <A>factors</A> of admissible character table names,
##  and then constructs the isoclinic table of the result
##  using <Ref Func="CharacterTableIsoclinic" BookName="ref"/>.
##  The arguments <A>nsg</A> and <A>centre</A>, if present, are passed to
##  <Ref Func="CharacterTableIsoclinic" BookName="ref"/>.
##  <P/>
##  If the optional arguments <A>permclasses</A>, <A>permchars</A> are given
##  then the classes and characters of the result are sorted accordingly.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructIsoclinic" );


#############################################################################
##
#F  ConstructPermuted( <tbl>, <libnam>[, <prmclasses>, <prmchars>] )
##
##  <#GAPDoc Label="ConstructPermuted">
##  <ManSection>
##  <Func Name="ConstructPermuted"
##  Arg="tbl, libnam[, prmclasses, prmchars]"/>
##
##  <Description>
##  The library table <A>tbl</A> is computed from
##  the library table with the name <A>libnam</A>,
##  by permuting the classes and the characters by the permutations
##  <A>prmclasses</A> and <A>prmchars</A>, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructPermuted" );


#############################################################################
##
#F  ConstructFactor( <tbl>, <libnam>, <kernel> )
##
##  <#GAPDoc Label="ConstructFactor">
##  <ManSection>
##  <Func Name="ConstructFactor" Arg="tbl, libnam, kernel"/>
##
##  <Description>
##  The library table <A>tbl</A> is completed with help of the library table
##  with name <A>libnam</A>,
##  by factoring out the classes in the list <A>kernel</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConstructFactor" );


#############################################################################
##
#F  ConstructClifford( <tbl>, <cliffordtable> )
##
##  constructs the irreducibles of the ordinary character table <tbl> from
##  the Clifford matrices stored in `<tbl>.cliffordTable'.
##
DeclareGlobalFunction( "ConstructClifford" );


#############################################################################
##
##  8. Character Tables of Coprime Central Extensions
##


#############################################################################
##
#F  CharacterTableOfCommonCentralExtension( <tblG>, <tblmG>, <tblnG>, <id> )
##
##  <#GAPDoc Label="CharacterTableOfCommonCentralExtension">
##  <ManSection>
##  <Func Name="CharacterTableOfCommonCentralExtension"
##  Arg="tblG, tblmG, tblnG, id"/>
##  
##  <Description>
##  Let <A>tblG</A> be the ordinary character table of a group <M>G</M>, say,
##  and let <A>tblmG</A> and <A>tblnG</A> be the ordinary character tables
##  of central extensions <M>m.G</M> and <M>n.G</M> of <M>G</M>
##  by cyclic groups of prime orders <M>m</M> and <M>n</M>, respectively,
##  with <M>m \not= n</M>.
##  We assume that the factor fusions from <A>tblmG</A> and <A>tblnG</A>
##  to <A>tblG</A> are stored on the tables.
##  <Ref Func="CharacterTableOfCommonCentralExtension"/> returns a record
##  with the following components.
##  <P/>
##  <List>
##  <Mark>tblmnG</Mark>
##  <Item>
##    the character table <M>t</M>, say, of the corresponding central
##    extension of <M>G</M> by a cyclic group of order <M>m n</M>
##    that factors through <M>m.G</M> and <M>n.G</M>;
##    the <Ref Attr="Identifier" BookName="ref"/> value of this table is
##    <A>id</A>,
##  </Item>
##  <Mark>IsComplete</Mark>
##  <Item>
##    <K>true</K> if the <Ref Attr="Irr" BookName="ref"/> value is stored
##    in <M>t</M>, and <K>false</K> otherwise,
##  </Item>
##  <Mark>irreducibles</Mark>
##  <Item>
##    the list of irreducibles of <M>t</M> that are known;
##    it contains the inflated characters of the factor groups <M>m.G</M> and
##    <M>n.G</M>, plus those irreducibles that were found in tensor
##    products of characters of these groups.
##  </Item>
##  </List>
##  <P/>
##  Note that the conjugacy classes and the power maps of <M>t</M>
##  are uniquely determined by the input data.
##  Concerning the irreducible characters, we try to extract them from the
##  tensor products of characters of the given factor groups by reducing
##  with known irreducibles and applying the LLL algorithm
##  (see&nbsp;<Ref Func="ReducedClassFunctions" BookName="ref"/>
##  and&nbsp;<Ref Func="LLL" BookName="ref"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CharacterTableOfCommonCentralExtension" );


#############################################################################
##
#F  IrreduciblesForCharacterTableOfCommonCentralExtension(
#F      <tblmnG>, <factirreducibles>, <zpos>, <needed> )
##
##  This function implements a heuristic for finding the missing irreducible
##  characters of a character table whose table head is constructed with
##  `CharacterTableOfCommonCentralExtension'
##  (see~"CharacterTableOfCommonCentralExtension").
##  Currently reducing tensor products and applying the LLL algorithm are
##  the only ingredients.
##
DeclareGlobalFunction(
    "IrreduciblesForCharacterTableOfCommonCentralExtension" );


#############################################################################
##
##  9. Miscellaneous
##


#############################################################################
##
#F  PossibleActionsForTypeGA( <tblG>, <tblGA> )
##
##  Let <tblG> and <tblGA> be the ordinary character tables of a group
##  <M>G</M> and of an extension <M>\tilde{G}</M> of <M>G</M>
##  by an automorphism of order <M>A</M>, say.
##
##  `PossibleActionsForTypeGA' returns the list of all those permutations
##  that may describe the action of <M>\tilde{G}</M> on the classes
##  of <tblG>, that is, all table automorphisms of <tblG> that have order
##  dividing <M>A</M> and permute the classes of <tblG>
##  compatibly with the fusion from <tblG> into <tblGA>.
##
DeclareGlobalFunction( "PossibleActionsForTypeGA" );
#T Replace the function by one that takes a perm. group and a fusion map!

#T The following two functions belong to the package for interactive
#T character table constructions;
#T but they are needed for `CharacterTableOfCommonCentralExtension'.

#############################################################################
##
#F  ReducedX( <tbl>, <redresult>, <chars> )
##
##  Let <tbl> be an ordinary character table, <redresult> be a result record
##  returned by `Reduced' when called with first argument <tbl>, and <chars>
##  be a list of characters of <tbl>.
##  `ReducedX' first reduces <chars> with the `irreducibles' component of
##  <redresult>; if new irreducibles are obtained this way then the
##  characters in the `remainders' component of <redresult> are reduced with
##  them; this process is iterated until no more irreducibles are found.
##  The function returns a record with the following components.
##
##  \beginitems
##  `irreducibles' &
##      all irreducible characters found during the process, including the
##      `irreducibles' component of <redresult>,
##
##  `remainders' &
##      the reducible characters that are left from <chars> and the
##      `remainders' component of <redresult>.
##  \enditems
##
DeclareGlobalFunction( "ReducedX" );


#############################################################################
##
#F  TensorAndReduce( <tbl>, <chars1>, <chars2>, <irreducibles>, <needed> )
##
##  Let <tbl> be an ordinary character table, <chars1> and <chars2> be two
##  lists of characters of <tbl>, <irreducibles> be a list of irreducible
##  characters of <tbl>, and <needed> be a nonnegative integer.
##  `TensorAndReduce' forms the tensor products of the characters in <chars1>
##  with the characters in <chars2>, and reduces them with the characters in
##  <irreducibles> and with all irreducible characters that are found this
##  way.
##  The function returns a record with the following components.
##
##  \beginitems
##  `irreducibles' &
##      all new irreducible characters found during the process,
##
##  `remainders' &
##      the reducible characters that are left from the tensor products.
##  \enditems
##
##  When at least <needed> new irreducibles are found then the process is
##  stopped immediately, without forming more tensor products.
##
##  For example, <chars1> and <chars2> can be chosen as lists of irreducible
##  characters with prescribed kernels such that the tensor products have a
##  prescribed kernel, too.
##  In this situation, <irreducibles> can be restricted to the list of those
##  known irreducible characters that can be constituents of the tensor
##  products, and <needed> can be chosen as the number of all missing
##  irreducibles of that kind.
##
DeclareGlobalFunction( "TensorAndReduce" );


#############################################################################
##
#E

