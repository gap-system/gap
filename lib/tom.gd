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
##
Revision.tom_gd :=
    "@(#)$Id$";

#############################################################################
##
#V  InfoTom
##
DeclareInfoClass("InfoTom");

#############################################################################
##

##
##  All tables of marks belong to the same category.
DeclareCategory("IsTableOfMarks", IsObject);

#############################################################################
##
#V  TableOfMarksFamily
##
##  All tables of marks belong to the same family.
TableOfMarksFamily := NewFamily("TableOfMarksFamily", IsTableOfMarks);

#############################################################################
##
## 1) Methods to construct tables of marks
##
#############################################################################
##
#O  TableOfMarks( <G> )
#O  TableOfMarks( <string> )
#0  TableOfMarks( <matrix> )
##
##  In the first form 'TableOfMarks' constructs the table from the group.
##
##  In the second form it gets the table with name <string> from the 
##  library.
##
##  In the third form it converts the matrix <matrix> into a table of marks.
##
#A  TableOfMarksGroup( <G> )
#M  TableOfMarksByLattice( <G> )
##  
##  'TableOfMarksGroup' is the attribute to store the table of marks on
##  the group <G>
##  
##  'TableOfMarksByLattice' computes the table of marks of <G> if the
##  lattice of <G> is known.
DeclareOperation("TableOfMarks",[IsGroup]);

DeclareAttribute("TableOfMarksGroup",IsGroup);

DeclareGlobalFunction("TableOfMarksByLattice");

#############################################################################
##
#O  TableOfMarksCyclic( <n> )
#O  TableOfMarksFrobenius( <p>, <q> )
#O  TableOfMarksDihedral( <n> )
##
##  The three operations construct a table of marks for a cyclic, frobenius
##  or dihedral group only from the data given, i.e. without underlying
##  group.
DeclareOperation("TableOfMarksCyclic",[IsPosInt]);

DeclareOperation("TableOfMarksFrobenius", [IsPosInt,IsPosInt]);

DeclareOperation("TableOfMarksDihedral", [IsPosInt]);

#############################################################################
##
##  2) Methods and functions dealing with tables of marks
##
#############################################################################
##
#A  SubsTom (<tom> ) .  .  .  .  .  .  .  .  .  .  .  .  .  . main attributes
#A  MarksTom( <tom> )
#A  NrSubsTom( <tom> 
#A  OrdersTom( <tom> )
#A  LengthsTom( <tom> )
##
##  The matrix of the table of marks is represented in a compressed form, 
##  i.e. zeros are omitted.
##  'SubsTom' contains at position $i$ a list wich includes all positions
##  of non zero entries of the $i$th row of the matrix <tom> and 
##  'MarksTom' the corresponding values.
##
##  Instead of the marks one can use a matrix which contains at position
##  $(i,j)$ the number of subgroups of conjugacy class $j$ contained in 
##  one member of the conjugacy class $i$. These values are stored in the
##  attribute 'NrSubsTom' in the same way as the marks.
##
##  'OrdersTom' contains at position $i$ the order of a representative of
##  the conjugacy class of subgroups $i$
##
##  One can compute 'NrSubsTom' and 'OrdersTom' from 'MarksTom' and vice
##  versa.
##
##  'LengthsTom' contains the lengths of the conjugacy classes of subgroups.
DeclareAttribute("SubsTom", IsTableOfMarks);

DeclareAttribute("MarksTom",IsTableOfMarks);

DeclareAttribute("NrSubsTom", IsTableOfMarks);

DeclareAttribute("OrdersTom", IsTableOfMarks);

DeclareAttribute("LengthsTom", IsTableOfMarks);

#############################################################################
##
#A IdentifierOfTom( <tom> )
##
DeclareAttribute("IdentifierOfTom",IsTableOfMarks);

#############################################################################
##
#A  NormalizersTom( <tom> )
##
##  attribute for the normalizers of <tom>
DeclareAttribute("NormalizersTom", IsTableOfMarks);

#############################################################################
##
#F  DerivedSubgroupsTom( <tom> )
#F  DerivedSubgroupTom( <tom>, <sub> )
#O  DerivedSubgroupsTomOp( <tom> )
#O  DerivedSubgroupTomOp( <tom>, <sub> )
#A  ComputedDerivedSubgroupsTom( <tom> )
#A  ComputedDerivedSubgroupsTomMut( <tom> )
##
##  attribute for the derived subgroups of <tom>
DeclareGlobalFunction( "DerivedSubgroupsTom");
DeclareAttribute( "ComputedDerivedSubgroupsTom", IsTableOfMarks);
DeclareOperation( "DerivedSubgroupsTomOp", [IsTableOfMarks] );
DeclareAttribute( "ComputedDerivedSubgroupsTomMut", 
                                                IsTableOfMarks, "mutable");
DeclareGlobalFunction("DerivedSubgroupTom");
DeclareOperation("DerivedSubgroupTomOp",[IsTableOfMarks, IsPosInt]);

#############################################################################
##
#A  FusionsTom(tom)
##
##  attribute for the fusions into other tables of marks
DeclareAttribute("FusionsTom", IsTableOfMarks, "mutable");

#############################################################################
##
#O  WeightsTom( <tom> )
##
##  the diagonal of <tom>
DeclareOperation("WeightsTom",[IsTableOfMarks]);

#############################################################################
##
#O  ContainedTom( <tom>, <sub1>, <sub2> )
##
##  returns the number of subgroups in <sub1> contained in one fixed member
##  of <sub2>
DeclareOperation("ContainedTom",[IsTableOfMarks, IsPosInt,IsPosInt]);

#############################################################################
##
#O  ContainingTom( <tom>, <sub1>, <sub2> )
##
##  returns the numbers of subgroups in <sub2> containing one fixed member 
##  of <sub1>
DeclareOperation("ContainingTom",[IsTableOfMarks, IsPosInt,IsPosInt]);

#############################################################################
##
#O  MaximalSubgroupsTom( <tom> )
#O  MaximalSubgroupsTom( <tom>, <sub> )
##
##  In the first form MaximalSubgroupsTom returns the maximal subgroups of
##  the whole group.
##  In the second form those of the subgroup <sub>.
##
DeclareOperation("MaximalSubgroupsTom",[IsTableOfMarks]);

#############################################################################
##
#O  MinimalSupergroupsTom( <tom> , <sub> )
##
##  'MinimalSupergroupsTom' computes the minimal supergroups of the subgroup
##  <sub>
DeclareOperation("MinimalSupergroupsTom", [IsTableOfMarks,IsPosInt]);

#############################################################################
##
#O  MatTom( < tom > )
##
##  converts <tom> into a matrix.
DeclareOperation("MatTom",[IsTableOfMarks]);  

#############################################################################
##
#O  DecomposedFixedPointVectorTom( <tom>, <fix> )
##
##  'DecomposedFixedPointVectorTom' decomposes a vector of fixed point 
##  number <fix> into rows of the table of marks <tom>.
DeclareOperation("DecomposedFixedPointVectorTom", [IsTableOfMarks,IsList]);

#############################################################################
##
#O  TestTom( <tom> )
##
##  'TestTom' tests the table of marks <tom>.
##  The condition tested is not necessary.
DeclareOperation("TestTom",[IsTableOfMarks]);

#############################################################################
##
#O  IntersectionsTom( <tom>, <sub1>, <sub2> )
##
##  'IntersectionTom' computes the intesections of <sub1> and  <sub2>.
DeclareOperation("IntersectionsTom",[IsTableOfMarks,IsPosInt,IsPosInt]);

#############################################################################
##
#O  IsCyclicTom( <tom>, <sub> )
##
##  'IsCyclicTom' tests if <sub> is cyclic or not.
DeclareOperation("IsCyclicTom",[IsTableOfMarks,IsPosInt]);

#############################################################################
##
#O  CyclicExtensionsTom( <tom>, <p> )
##   
##  According to Dress two columns of a table of  marks mod <p> are equal  if
##  and  only  if  the  corresponding subgroups are  connected by a  chain of
##  normal  extensions  of  order  <p>.   'CyclicExtensionsTom'  returns  the
##  classes of this equivalence relation.
DeclareOperation("CyclicExtensionsTom",[IsTableOfMarks, IsList]);

DeclareOperation("CyclicExtensionsTomOp",[IsTableOfMarks,IsList]);

DeclareAttribute("ComputedCyclicExtensionsTom", IsTableOfMarks, "mutable");

InstallMethod(ComputedCyclicExtensionsTom,true,[IsTableOfMarks],0, x->[]);

#############################################################################
##
#O  IdempotentsTom( <tom> ) 
##
##  'IdempotentsTom' returns the list of idempotents of the Burnside ring 
##   described by <tom>.
DeclareOperation( "IdempotentsTom", [IsTableOfMarks]); 

#############################################################################
##
#O  IsAbelianTom( <tom> , <sub>)
##
##  'IsAbelianTom' tests if the underlying group of <tom> is abelian.
DeclareOperation("IsAbelianTom", [IsTableOfMarks, IsPosInt]);

#############################################################################
##
#O  FactorGroupTom( <tom>, <nor> )
##
##  'FactorGroupTom' returns the table of marks of the factor 
##  group <G>/<nor>.
DeclareOperation("FactorGroupTom",[IsTableOfMarks, IsPosInt]);

#############################################################################
##
#O  IsPerfectTom( <tom> )
##
##  IsPerfectTom tests if the underlying group of <tom> is perfect.
DeclareOperation("IsPerfectTom", [IsTableOfMarks, IsPosInt]);
 
#############################################################################
##
#O  MoebiusTom( <tom> )
##
##  'MoebiusTom' computes the moebius function of the subgroup lattice of 
##   the underlying group of <tom>.
##  table of marks <tom>.
DeclareOperation( "MoebiusTom", [IsTableOfMarks]);

#############################################################################
##
#A  ClassNamesTom( <tom> )
#O  ClassTypesTom( <tom> )
##
##  'ClassTypesTom'   distinguishes  isomorphism  types  of  the  classes  of
##  subgroups of the  table of marks <tom> as  far  as this is possible.  
##
##  'ClassNamesTom'  constructs generic names  for  the  conjugacy classes of
##  subgroups of the table of marks <tom>.  
DeclareAttribute("ClassNamesTom", IsTableOfMarks);
DeclareOperation("ClassTypesTom", [IsTableOfMarks]);

#############################################################################
##
#O  PermCharsTom( <fus>, <tom> )
#O  PermCharsTom( <tbl>, <tom> )
##
##  'PermCharsTom' reads the list of permutation characters from the table of
##  marks <tom>.  It therefore has to  know  the fusion map <fus> which sends
##  each conjugacy  class of elements  of the group to the conjugacy class of
##  subgroups that they generate.
##  In the fist form the fusion map must be given, in the second form the 
##  fusion map will be constructed from the table of marks and the character
##  table
##
DeclareOperation("PermCharsTom", [IsList, IsTableOfMarks]);

#############################################################################
##
#O  FusionCharTableTom( <tbl>, <tom> )
##
##  'FusionCharTableTom' determines  the fusion of the  classes  of  elements
##  from  the  character table <tbl> into classes of cyclic subgroups  on the
##  table of marks <tom>.
DeclareOperation("FusionCharTableTom", [IsOrdinaryTable, IsTableOfMarks]);

#############################################################################
##
#A  GroupOfTom( <tom> )
#A  GeneratorsSubgroupsTom( <tom> )
#A  WordsTom( <tom> )
#F  EvaluateWordsTom( <genslist>, <wordslist> ), 
#F  ConvWordsTom( <wordlist> , <fam> )
#P  IsTableOfMarksWithGens( <tom> )
##
##  'GroupOfTom' is used to store an underlying group on the table of marks
##  <tom>
##
##  There are two possibilities to store generators for a representative of
##  each conjugacy class of subgroups on <tom>, both with respect to the
##  group stored in 'GroupOfTom': 
##  1) 'GeneratorsSubgroupsTom' is a list with two elements:
##     The first is simply a list of elements of the group stored in 
##     'GroupOfTom', used as generators for the representatives.
##     The second is a list that contains at position $i$ a list which
##     describe which generators are two be used to generate a representative
##     of the conjugacy class of subgroups $i$.
##
##  2) 'WordsTom' is a list that contains at position $i$ a list of 
##     generators as "words" in the generators of 'GroupOfTom', to generate 
##     the representative of the conjugacy class $i$. These "words" that are
##     in fact wordlists are evaluated by 'EvaluateWordsTom'. 
##
##   The property 'IsTableOfMarks' indicates that one of these two
##   attributes is set.
##
##  Tables of marks from the library use 'WordsTom'.
##
##  'EvaluateTom' evaluate the words stored on the table of marks.
##  Each word is in fact a wordlist <wordlist>. The evaluation looks like
##  a little straight line program:
##  First evaluate the first word of <wordlist> using <genslist>,
##  usually the generators of 'GroupOfTom' ore equivalent ones.
##  Then evaluate the second word using <genslist> and the previous result, 
##  then the third using <genslist> and the previous results and so on.
##  The last word of <wordlist> gives the result.
##
##  'ConvWordsTom' converts the whole list of words from external to
##  internal representation. This mainly used by library table of marks
DeclareAttribute("GroupOfTom",IsTableOfMarks);

DeclareAttribute("GeneratorsSubgroupsTom",IsTableOfMarks);

DeclareAttribute("WordsTom",IsTableOfMarks);

DeclareGlobalFunction("EvaluateWordTom") ;

DeclareGlobalFunction("ConvWordsTom");

DeclareProperty("IsTableOfMarksWithGens",IsTableOfMarks);
InstallTrueMethod(IsTableOfMarksWithGens,IsTableOfMarks and HasWordsTom);
InstallTrueMethod(IsTableOfMarksWithGens,IsTableOfMarks and 
                                    HasGeneratorsSubgroupsTom);

#############################################################################
##
#V  TableOfMarksComponents
#F  TOM( <arglist> )
#F  ConvertToTableOfMarks( <record> )
##
##  'TableOfMarksComponents' is used to create tables of marks from records.
##  It contains the attributes that usually have library table of marks or
##  newly constructed tables of marks, more precisely:
##  'TableOfMarksComponent' contains at position $2i-1$ a name of an 
##  attribute and at position $2i$ the corresponding attribute getter 
##  function.
##  
##  'ConvertToTableOfMarks' converts a record with components from 
##  'TableOfMarksComponents' into a table of marks object with the
##  corresponding attributes.
##
##  'TOM' returns such a record from a list <arglist> which must contain
##  the values of the components in the correct order.
TableOfMarksComponents:=["IdentifierOfTom",          IdentifierOfTom,
                         "SubsTom",                 SubsTom,
                         "MarksTom",                MarksTom,
                         "NrSubsTom",               NrSubsTom,
                         "OrdersTom",               OrdersTom,
                         "NormalizersTom",          NormalizersTom,
                         "ComputedDerivedSubgroupsTom",     
                                               ComputedDerivedSubgroupsTom,
                         "GroupOfTom",              GroupOfTom,
                         "WordsTom",                WordsTom,
                         "GeneratorsSubgroupsTom",  GeneratorsSubgroupsTom];

DeclareGlobalFunction("TOM");

DeclareGlobalFunction( "ConvertToTableOfMarks" );

#############################################################################
##
#O  RepresentativeTom( <tom> );
#O  RepresentativeTom( <tom>, <sub>)
#O  RepresentativeTomByGroup( <tom>, <sub>, <group> )
#O  RepresentativeTomByGroupNC( <tom>, <sub>, <group> )
##
##  In the first form 'RepresentativeTom' returns the group stored on the
##  table of marks <tom>.
##
##  In the second form it returns a representative of the conjugacy class
##  of subgroups <sub>.
##
##  'RepresentativeTomByGroup' returns the representative of the conjugacy
##  class of subgroups <sub> as a subgroup of <group>.
##  The generators of < group > and the generators of the group stored on
##  the table of marks <tom> (attribute 'GroupOfTom') must set up an 
##  isomorphism. This will be checked.
##
##  'RepresentativeTomByGroupNC' does the same as 'RepresentativeTomByGroup'
##  except that it does not check the isomorphism property.
DeclareOperation("RepresentativeTom",[IsTableOfMarks,
                   IsPosInt]);

DeclareOperation(
            "RepresentativeTomByGroup",[IsTableOfMarks and HasWordsTom,
             IsPosInt,IsGroup]);

DeclareOperation(
            "RepresentativeTomByGroupNC",[IsTableOfMarks and HasWordsTom,
             IsPosInt,IsGroup]);

#############################################################################
##
#O  SortTom( <tom>, <perm> )
##
##  'SortTom' sorts the rows of the table of marks according to perm
##
##  The rows of the table of marks must be sorted according the following 
##  rule:
##  if the subgroup U_i corrsponding to row i is contained in the subgroup
##  U_j corresponding to row j then i <= j.
##  <perm>  must be a permutation that does not violate this rule, this is not
##  checked!!
##  'SortTom' returns a new table of marks and sorts only the components
##  of 'TableOfMarksComponents' if present on <tom>.
DeclareOperation("SortTom",[IsTableOfMarks,IsPerm]);

#############################################################################
##
#O  EulerianFunctionByTom( <tom>, <s> )
#0  EulerianFunctionByTom( <tom>, <s>, <sub> )
##
##  In the first form 'EulerianFunctionByTom' computes the eulerian
##  function of the underlying group of <tom>.
##  In the secon form it computes the eulerian function for the subgroup
##  <sub>.

DeclareOperation("EulerianFunctionByTom",[IsTableOfMarks, IsPosInt]);

#############################################################################
##
#M  LatticeSubgroupsByTom( <G> )
##
##  'LatticeSubgroupsByTom' computes the lattice of subgroups if <G> if
##  the <G> knows its table of marks.
DeclareGlobalFunction("LatticeSubgroupsByTom");


#############################################################################
##
#R  IsLibTomRep
##
##  Library tables of marks have their own representation.
DeclareRepresentation("IsLibTomRep", IsAttributeStoringRep,["sortperm"]);

#############################################################################
##
#O  IsNilpotentTom( <tom )
#O  IsNilpotentTom( <tom>, <sub> )
##
DeclareOperation("IsNilpotentTom", [IsTableOfMarks, IsPosInt]);

#############################################################################
##
#O  IsSolvableTom( <tom>, <sub> )
##
DeclareOperation("IsSolvableTom", [IsTableOfMarks, IsPosInt]);

#############################################################################
##
#E  tom.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


