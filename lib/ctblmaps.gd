#############################################################################
##
#W  ctblmaps.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of those functions that are used
##  to construct maps (mostly fusion maps and power maps).
##
Revision.ctblmaps_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  CharacterString( <char>, <str> )
##
CharacterString := NewOperationArgs( "CharacterString" );


#############################################################################
##
#F  UpdateMap( <char>, <paramap>, <indirected> )
##
##  improves <paramap> using that <indirected> is the indirection (possibly
##  parametrized) of <char> by <paramap>.
##
##  If no contradictions were detected, 'true' is returned,
##  otherwise 'false'.
##
UpdateMap := NewOperationArgs( "UpdateMap" );


#############################################################################
##
#F  NonnegIntScalarProducts( <tbl>, <chars>, <candidate> )
##
##  is 'true' if all scalar products of the character values list <candidate>
##  with the character values lists in the list <chars> are nonnegative
##  integers, and 'false' otherwise.
##
NonnegIntScalarProducts := NewOperationArgs( "NonnegIntScalarProducts" );


#############################################################################
##
#F  IntScalarProducts( <tbl>, <chars>, <candidate> )
##
##  is 'true' if all scalar products of the character values list <candidate>
##  with the character values lists in the list <chars> are
##  integers, and 'false' otherwise.
##
IntScalarProducts := NewOperationArgs( "IntScalarProducts" );


#############################################################################
##
#F  ContainedSpecialVectors( <tbl>, <chars>, <paracharacter>, <func> )
##
##  is the list of all elements <vec> of <paracharacter> which have
##  integral norm and integral scalar product with the principal character
##  of <tbl> and which satisfy <func>( <tbl>, <chars>, <vec> )
##
ContainedSpecialVectors := NewOperationArgs( "ContainedSpecialVectors" );


#############################################################################
##
#F  ContainedPossibleCharacters( <tbl>, <chars>, <paracharacter> )
##
##  is the list of all elements <vec> of <paracharacter> which have
##  integral norm, integral scalar product with the principal character
##  of <tbl> and nonnegative integral scalar product with all elements
##  of <chars>.
##
##  (This is a special case of 'ContainedSpecialVectors'.)
##
ContainedPossibleCharacters := NewOperationArgs(
    "ContainedPossibleCharacters" );


#############################################################################
##
#F  ContainedPossibleVirtualCharacters( <tbl>, <chars>, <paracharacter> )
##
##  is the list of all elements <vec> of <paracharacter> which have
##  integral norm, integral scalar product with the principal character
##  of <tbl> and integral scalar product with all elements of <chars>.
##
##  (This is a special case of 'ContainedSpecialVectors'.)
##
ContainedPossibleVirtualCharacters := NewOperationArgs(
    "ContainedPossibleVirtualCharacters" );


#############################################################################
##
#F  InitFusion( <subtbl>, <tbl> )
##
##  is the (probably parametrized) map of the subgroup fusion from
##  <subtbl> to <tbl> using the following properties:
##
##  For any class 'i' of <subtbl> the centralizer of the image must be
##  a multiple of the centralizer of 'i', and
##
##  the representative order of 'i' is equal to the representative order
##  of its image (only used if representative orders are stored).
##
##  If no fusion map is possible, 'fail' is returned.
##
InitFusion := NewOperationArgs( "InitFusion" );


#############################################################################
##
#F  CheckPermChar( <subtbl>, <tbl>, <fusionmap>, <permchar> )
##
##  tries to improve the parametrized fusion <fusionmap> from the character
##  table <subtbl> into the character table <tbl> using the permutation
##  character <permchar> that belongs to the required fusion\:
##
##  An upper bound for the number of elements fusing into each class is
##  $'upper[i]'=
##           '<subtbl>.size' \* '<permchar>[i]' / '<tbl>.centralizers[i]'$.
##
##  We first subtract from that the number of all elements which {\em must}
##  fuse into that class:
##  $'upper[i]':= 'upper[i]' -
##                      \sum_{'fusionmap[i]'='i'} '<subtbl>.classes[i]'$.
##
##  After that, we delete all those possible images 'j' in 'initfusion[i]'
##  which do not satisfy $'<subtbl>.classes[i]' \leq 'upper[j]'$
##  (local function 'deletetoolarge').
##
##  At last, if there is a class 'j' with
##  $'upper[j]' = \sum_{'j' \in 'initfusion[i]'}' <subtbl>.classes[i]'$,
##  then 'j' must be the image for all 'i' with 'j' in 'initfusion[i]'
##  (local function 'takealliffits').
##
##  'CheckPermChar' returns 'true' if no inconsistency occurred, and 'false'
##  otherwise.
##
##  ('CheckPermChar' is used as subroutine of 'PossibleClassFusions'.)
##
CheckPermChar := NewOperationArgs( "CheckPermChar" );


#############################################################################
##
#F  MeetMaps( <map1>, <map2> )
##
##  improves <map1> such that the image of class $i$ is the intersection with
##  the image of class $i$ under <map2>.
##  If this implies that no images remain for class $i$, the number $i$ is
##  returned.
##  If no such inconsistency occurs, 'MeetMaps' returns 'true'.
##
MeetMaps := NewOperationArgs( "MeetMaps" );


#############################################################################
##
#F  ImproveMaps( <map2>, <map1>, <composition>, <class> )
##
##  'ImproveMaps' is a utility for 'CommutativeDiagram' and
##  'TestConsistencyMaps'.
##
##  <composition> must be a set that is known to be an upper bound for the
##  composition $( <map2> \circ <map1> )[ <class> ]$;
##  if $'<map1>[ <class> ]' = x$ is unique then $<map2>[ x ]$ must be a set,
##  it will be replaced by its intersection with <composition>;
##  if <map1>[ <class> ] is a set then all elements 'x' with
##  'Intersection( <map2>[ x ], <composition> ) = []' are excluded.
##
##  'ImproveMaps' returns     0 if no improvement was found
##                           -1 if <map1>[ <class> ] was improved
##                          <x> if <map2>[ <x> ] was improved
##
ImproveMaps := NewOperationArgs( "ImproveMaps" );


#############################################################################
##
#F  CompositionMaps( <paramap2>, <paramap1> )
#F  CompositionMaps( <paramap2>, <paramap1>, <class> )
##
##  'CompositionMaps( <paramap2>, <paramap1> )' is a parametrized map with
##  image 'CompositionMaps( <paramap2>, <paramap1>, <class> )' at position
##  <class>. If '<paramap1>[<class>]' is unique,
##  'CompositionMaps( <paramap2>, <paramap1>, <class> ) =
##  <paramap2>[ <paramap1>[ <class> ] ]', otherwise it is the union of
##  '<paramap2>[i]' for 'i' in '<paramap1>[ <class> ]'.
##
CompositionMaps := NewOperationArgs( "CompositionMaps" );


#############################################################################
##
#F  ProjectionMap( <fusionmap> ) . . projection corresponding to a fusion map
##
##  We have 'CompositionMaps( <fusionmap>,ProjectionMap( <fusionmap> ) )' the
##  identity map, i.e. first projecting and then fusing yields the identity.
##  Note that <fusionmap> must not be a parametrized map.
##
ProjectionMap := NewOperationArgs( "ProjectionMap" );


#############################################################################
##
#F  CommutativeDiagram( <paramap1>, <paramap2>, <paramap3>, <paramap4> )
#F  CommutativeDiagram( <paramap1>, <paramap2>, <paramap3>, <paramap4>,
#F                      <improvements> )
##
##  If 'CompositionMaps( <paramap2>, <paramap1> ) =
##      CompositionMaps( <paramap4>, <paramap3> )'
##  shall hold, the consistency is checked and the four maps
##  will be improved according to this condition.
##
##  If a record <improvements> with fields 'imp1', 'imp2', 'imp3', 'imp4' is
##  specified, only diagrams containing elements of 'imp<i>' as preimages of
##  <paramapi> are considered.
##
##  'CommutativeDiagram' returns 'fail' if an inconsistency was found,
##  otherwise a record is returned that contains four lists 'imp1', \ldots,
##  'imp4':
##  'imp<i>' is the list of classes where <paramap_i> was improved.
##
##    i ---------> map1[i]
##    |              |
##    |              v
##    |          map2[ map1[i] ]
##    v
##  map3[i] ---> map4[ map3[i] ]
##
CommutativeDiagram := NewOperationArgs( "CommutativeDiagram" );


#############################################################################
##
#F  CheckFixedPoints( <inside1>, <between>, <inside2> )
##
##  tries to improve <between> using that <between> must map fixed points
##  under <inside1> to fixed points under <inside2> 
##
##  If no inconsistency occurs, 'CheckFixedPoints' returns the list of
##  classes where improvements were found; otherwise 'fail' is returned.
##
CheckFixedPoints := NewOperationArgs( "CheckFixedPoints" );


#############################################################################
##
#F  TransferDiagram( <inside1>, <between>, <inside2> )
#F  TransferDiagram( <inside1>, <between>, <inside2>, <improvements> )
##
##  Like in 'CommutativeDiagram', it is checked that
##  'CompositionMaps( <between>, <inside1> ) =
##  CompositionMaps( <inside2>, <between> )', that means
##  <between> occurs twice in each commutative diagram
##
##     i   -----> between[i]
##     |            |
##     |            v
##     |         inside2[ between[i] ]
##     v
##  inside1[i] ----> between[ inside1[i] ]
##
##  If a record <improvements> with fields 'impinside1', 'impbetween' and
##  'impinside2' is specified, only those diagrams with elements of
##  'impinside1' as preimages of <inside1>, elements of 'impbetween' as
##  preimages of <between> or elements of 'impinside2' as preimages of
##  <inside2> are considered.
##
##  When an inconsistency occurs, the program immediately returns 'fail';
##  else it returns a record with lists 'impinside1', 'impbetween' and
##  'impinside2' of found improvements.
##
##  (calls 'CheckFixedPoints')
##
TransferDiagram := NewOperationArgs( "TransferDiagram" );


#############################################################################
##
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2> )
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2>, <fus_imp> )
##
##  Like in 'TransferDiagram', it is checked that maps are commutative:
##  For all positions 'i' where both '<powermap1>[i]' and '<powermap2>[i]'
##  are bound, it must hold 'CompositionMaps( <fusionmap>, <powermap1>[i] ) =
##  CompositionMaps( <powermap2>[i], <fusionmap> )', that means
##  1. <fusionmap> occurs twice in each commutative diagram and
##  2. <fusionmap> is common for all considered elements of <powermap1> resp.
##     <powermap2>.
##
##  If a list <fus_imp> is specified, only those diagrams with
##  elements of <fus_imp> as preimages of <fusionmap> are considered.
##
##  When an inconsistency occurs, the program immediately returns 'false';
##  otherwise 'true' is returned.
##
TestConsistencyMaps := NewOperationArgs( "TestConsistencyMaps" );


#############################################################################
##
#F  InitPowermap( <tbl>, <prime> )
##
##  is a (parametrized) map that is a first approximation of the <prime>-th
##  powermap of <tbl>.
##  The following properties are used:
##
##  1. For each class 'i', the centralizer order of the <prime>-th power must
##     be a multiple of the centralizer order of 'i'; if the representative
##     order of 'i' is relative prime to <prime>, the centralizer orders of
##     i and its image must be equal.
##
##  2. If <prime> divides the representative order <x> of the class 'i', the
##     representative order of its image must be $<x> / <prime>$; otherwise
##     the representative orders of 'i' and its image must be equal.
##
##  If there are classes for which no images are possible,
##  'fail' is returned.
##
InitPowermap := NewOperationArgs( "InitPowermap" );


#############################################################################
##
#F  Congruences( <tbl>, <chars>, <prime_powermap>, <prime> )
#F  Congruences( <tbl>, <chars>, <prime_powermap>, <prime>, \"quick\" )
#F  Congruences( <tbl>, <chars>, <prime_powermap>, <prime>, true )
##
##  improves <prime_powermap> which is an approximation for the <prime>-th
##  powermap of <tbl> using the property that for each element <chi> of
##  <chars> the congruence
##  $'Gal'( <chi>(g), <prime> ) \equiv <chi>(g^{<prime>}) \pmod{<prime>}$ holds;
##  if the representative order of $g$ is relative prime to <prime> we have
##  $'GaloisCyc( <chi>(g), <prime> ) = <chi>(g^{<prime>})$.
##  
##  If \"quick\" is specified, only those classes with ambiguous images are
##  considered.
##
##  If there are classes for which no images are possible, the value is the
##  empty list (not undefined!)
##
##  'Congruences' returns 'true' if no inconsistencies were detected, and
##  'false' otherwise.
##
Congruences := NewOperationArgs( "Congruences" );


#############################################################################
##
#F  ConsiderKernels( <tbl>, <chars>, <prime_powermap>, <prime> )
#F  ConsiderKernels( <tbl>, <chars>, <prime_powermap>, <prime>, \"quick\" )
#F  ConsiderKernels( <tbl>, <chars>, <prime_powermap>, <prime>, true )
##
##  improves <prime_powermap> which is an approximation of the <prime>-th
##  powermap of <tbl> using the property that for each element <chi> of
##  <chars> the kernel of <chi> is a normal subgroup of <tbl>.
##  So for every $g \in 'KernelChar( <chi> )'$ we have
##  $g^{<prime>} \in 'KernelChar( <chi> )'$;
##
##  Depending on the order of the factor group modulo 'KernelChar( <chi> )',
##  there are two further properties:
##  If the order is relative prime to <prime>, for each
##  $g \notin 'KernelChar( <chi> )'$ the <prime>-th power is not contained in
##  'KernelChar( <chi> )'.
##  If the order is equal to <prime>, the <prime>-th powers of all elements
##  lie in 'KernelChar( <chi> )'.
##
##  If 'KernelChar( <chi> )' has an order not dividing the order of <tbl>,
##  'false' is returned.
##  Also if no image is left for a class, 'false' is returned.
##  In case of no inconsistencies, 'true' is returned.
##
##  If '\"quick\"' is specified, only those classes are considered where
##  <prime_powermap> is ambiguous.
##
ConsiderKernels := NewOperationArgs( "ConsiderKernels" );


#############################################################################
##
#F  ConsiderSmallerPowerMaps( <tbl>, <prime_powermap>, <prime> )
#F  ConsiderSmallerPowerMaps( <tbl>, <prime_powermap>, <prime>, \"quick\" )
#F  ConsiderSmallerPowerMaps( <tbl>, <prime_powermap>, <prime>, true )
##
##  If $<prime> > 'orders[i]'$, try to improve the <prime>-th powermap at
##  class 'i' using that $g_i^{'prime'} = g_i^{'prime mod orders[i]'}$;
##  so try to calculate the '( prime mod orders[i] )'-th powermap at class
##  'i'.
##
##  If no representative orders of <tbl> are stored, 'true' is returned
##  without any tests.
##
##  If \"quick\" is specified only check those classes where <prime_powermap>
##  is not unique.
##
##  The returned value is 'false' if there are classes for which no image
##  is possible, otherwise 'true'.
##
ConsiderSmallerPowerMaps := NewOperationArgs( "ConsiderSmallerPowerMaps" );


#############################################################################
##
#F  PowerMapsAllowedBySymmetrisations( <tbl>, <subchars>, <chars>, <pow>,
#F                                     <prime>, <parameters> )
##
##  <parameters> must be a record with fields <maxlen> (int), <contained>,
##  <minamb>, <maxamb> and <quick> (boolean).
##
##  First, for all $\chi \in <chars>$ let
##  'minus:= MinusCharacter( $\chi$, <pow>, <prime> )'. If
##  '<minamb> \< Indeterminateness( minus ) \< <maxamb>', construct
##  'poss:= contained( <tbl>, <subchars>, minus )'.
##  (<contained> is a function that will be 'ContainedCharacters' or
##  'ContainedPossibleCharacters'.)
##  If 'Indeterminateness( minus ) \< <minamb>', delete this character;
##  for unique minus-characters, if '<parameters>.quick = false', the
##  scalar products with <subchars> are checked.
##  (especially if the minus-character is unique, i.e.\ it is not quecked if
##  the symmetrizations of such a character decompose correctly).
##  Improve <pow> if possible.
##
##  If the minus character af a character *becomes* unique during the
##  processing, its scalar products with <subchars> are checked.
##
##  If no further improvement is possible, delete all characters with unique
##  minus-character, and branch:
##  If there is a character left with less or equal <maxlen> possible
##  minus-characters, compute the union of power maps allowed by these
##  characters;
##  otherwise choose a class 'c' which is significant for some character,
##  and compute the union of all allowed power maps with image 'x' on
##  'c', where 'x' runs over '<pow>[c]'.
##
##  By recursion, one gets the list of power maps that are parametrized
##  on all classes where no element of <chars> is significant,
##  and that yield nonnegative integer scalar products for the
##  minus-characters of <chars> with <subchars>.
##
##  If '<parameters>.quick = true', unique minus characters are never
##  considered.
##
PowerMapsAllowedBySymmetrisations := NewOperationArgs(
    "PowerMapsAllowedBySymmetrisations" );
  

#############################################################################
##
#F  ConsiderTableAutomorphisms( <parafus>, <grp> )
##
##  improves the parametrized subgroup fusion map <parafus> so that
##  afterwards exactly one representative of fusion maps (that is contained
##  in <parafus>) in every orbit under the action of the permutation group
##  <grp> is contained in <parafus>.
##
##  The list of positions where improvements were found is returned.
##
ConsiderTableAutomorphisms := NewOperationArgs(
    "ConsiderTableAutomorphisms" );


#############################################################################
##
#F  OrbitFusions( <subtblautomorphisms>, <fusionmap>, <tblautomorphisms> )
##
##  returns the orbit of the subgroup fusion map <fusionmap> under the
##  actions of maximal admissible subgroups of the table automorphisms
##  <subtblautomorphisms> of the subgroup table and <tblautomorphisms> of
##  the supergroup table.
##  The table automorphisms must be both permutation groups.
##
OrbitFusions := NewOperationArgs( "OrbitFusions" );


#############################################################################
##
#F  OrbitPowerMaps( <powermap>, <matautomorphisms> )
##
##  returns the orbit of the powermap <powermap> under the action of the
##  maximal admissible subgroup of the matrix automorphisms
##  <matautomorphisms> of the considered character table.
##  The matrix automorphisms must be a permutation group.
##
OrbitPowerMaps := NewOperationArgs( "OrbitPowerMaps" );


#############################################################################
##
#F  RepresentativesFusions( <subtblautomorphisms>, <listoffusionmaps>,
#F                          <tblautomorphisms> )
#F  RepresentativesFusions( <subtbl>, <listoffusionmaps>, <tbl> )
##
##  returns a list of representatives of subgroup fusions in the list
##  <listoffusionmaps> under the action of maximal admissible subgroups
##  of the table automorphisms <subtblautomorphisms> of the subgroup table
##  and <tblautomorphisms> of the supergroup table.
##  The table automorphisms must be both permutation groups.
##
RepresentativesFusions := NewOperationArgs( "RepresentativesFusions" );


#############################################################################
##
#F  RepresentativesPowerMaps( <listofpowermaps>, <matautomorphisms> )
##
##  returns a list of representatives of power maps in the list
##  <listofpowermaps> under the action of the maximal admissible subgroup
##  of the matrix automorphisms <matautomorphisms> of the considered
##  character matrix.
##  The matrix automorphisms must be a permutation group.
##
RepresentativesPowermaps := NewOperationArgs( "RepresentativesPowermaps" );
    

#############################################################################
##
#F  FusionsAllowedByRestrictions( <subtbl>, <tbl>, <subchars>, <chars>,
#F                                <fus>, <parameters> )
##
##  <parameters> must be a record with fields <maxlen> (int), <contained>,
##  <minamb>, <maxamb> and <quick> (boolean).
##
##  First, for all $\chi \in <chars>$ let
##  'restricted:= CompositionMaps( $\chi$, <fus> )'.
##  If '<minamb> \< Indeterminateness( restricted ) \< <maxamb>', construct
##  'poss:= contained( <subtbl>, <subchars>, restricted )'.
##  (<contained> is a function that will be 'ContainedCharacters' or
##  'ContainedPossibleCharacters'.)
##  Improve <fus> if possible.
##
##  If 'Indeterminateness( restricted ) \< <minamb>', delete this character;
##  for unique restrictions and '<parameters>.quick = false', the scalar
##  products with <subchars> are checked.
##
##  If the restriction of a character *becomes* unique during the
##  processing, its scalar products with <subchars> are checked.
##
##  If no further improvement is possible, delete all characters with unique
##  restrictions or, more general, indeterminateness at most <minamb>,
##  and branch:
##  If there is a character left with less or equal <maxlen> possible
##  restrictions, compute the union of fusions allowed by these restrictions;
##  otherwise choose a class 'c' of <subgroup> which is significant for some
##  character, and compute the union of all allowed fusions with image 'x' on
##  'c', where 'x' runs over '<fus>[c]'.
##
##  By recursion, one gets the list of fusions which are parametrized on all
##  classes where no element of <chars> is significant, and which yield
##  nonnegative integer scalar products for the restrictions of <chars>
##  with <subchars> (or additionally decomposability).
##
##  If '<parameters>.quick = true', unique restrictions are never considered.
##
FusionsAllowedByRestrictions := NewOperationArgs(
    "FusionsAllowedByRestrictions" );


#############################################################################
##
#F  Indeterminateness( <paramap> ) . . . . the indeterminateness of a paramap
##
Indeterminateness := NewOperationArgs( "Indeterminateness" );


#############################################################################
##
#F  PrintAmbiguity( <list>, <paramap> ) . . . .  ambiguity of characters with
##                                                       respect to a paramap
##
##  prints for each character in <list> the position, the indeterminateness
##  with respect to <paramap> and the list of ambiguous classes
##
PrintAmbiguity := NewOperationArgs( "PrintAmbiguity" );


#############################################################################
##
#F  Parametrized( <list> )
##
##  is the smallest parametrized map containing all elements of <list>.
##  These elements may be maps or parametrized maps.
##
Parametrized := NewOperationArgs( "Parametrized" );


#############################################################################
##
#F  ContainedMaps( <paramap> )
##
##  is the set of all contained maps of <paramap>
##
ContainedMaps := NewOperationArgs( "ContainedMaps" );


#############################################################################
##
#F  Indirected( <character>, <paramap> )
##
##  'Indirected( <character>, <paramap> )[i]' = <character>[ <paramap>[i] ]',
##  if this value is unique; otherwise it is set undefined.
##  
Indirected := NewOperationArgs( "Indirected" );


#############################################################################
##
#F  ElementOrdersPowerMap( <powermap> )
##
##  is the list of element orders given by the maps in the power map
##  <powermap>.
##  The entries at positions where the power maps do not uniquely determine
##  the element orders are set to an unknown.
##
ElementOrdersPowerMap := NewOperationArgs( "ElementOrdersPowerMap" );


#############################################################################
##
#F  CollapsedMat( <mat>, <maps> )
##
##  is a record with components
##
##  'fusion'
##     fusion that collapses those columns of <mat> that are equal in <mat>
##     and also for all maps in the list <maps>,
##
##  'mat'
##     the image of <mat> under that fusion.
##
CollapsedMat := NewOperationArgs( "CollapsedMat" );


#############################################################################
##
#F  StepModGauss( <matrix>, <moduls>, <nonzerocol>, <col> )
##
##  performs Gaussian elimination for column <col> of the matrix <matrix>,
##  where the entries of column 'i' are taken modulo '<moduls>[i]',
##  and only those columns 'i' with '<nonzerocol>[i] = true' (may) have
##  nonzero entries.
##
##  Afterwards the only row containing a nonzero entry in column <col> will
##  be the first row of <matrix>, and again Gaussian elimination is done
##  for that row and the row $\delta_{<'col'>}$;
##  if there is a row with nonzero entry in column <col> then this row is
##  returned, otherwise 'fail' is returned.
##
StepModGauss := NewOperationArgs( "StepModGauss" );


#############################################################################
##
#F  ModGauss( <matrix>, <moduls> )
##
##  <matrix> is transformed to an upper triangular matrix generating the same
##  lattice modulo that generated by
##  $\{<moduls>[i] \cdot \delta_i; 1 \leq i \leq \|<moduls>\|\}$.
##
##  <matrix> is changed, the triangular matrix is returned.
##
ModGauss := NewOperationArgs( "ModGauss" );


#############################################################################
##
#F  ContainedDecomposables( <constituents>, <moduls>, <parachar>, <func> )
##
##  <constituents> must be rational vectors, <parachar> a
##  parametrized rational vector.
##  Using 'StepModGauss', all elements $\chi$ of <parachar> are
##  calculated that modulo <moduls> lie in the lattice spanned by
##  <constituents> and satisfy $<func>( \chi )$.
##
ContainedDecomposables := NewOperationArgs( "ContainedDecomposables" );


#############################################################################
##
#F  ContainedCharacters( <tbl>, <constituents>, <parachar> )
##
##  the list of all characters in <parachar> which lie in the linear
##  span of the rational characters <constituents> (modulo centralizer
##  orders) and have nonegative scalar products with all elements of
##  <constituents>.
##
##  (The elements of the returned list are *not* necessary linear
##  combinations of <constituents>.)
##
ContainedCharacters := NewOperationArgs( "ContainedCharacters" );


#############################################################################
##
#E  ctblmaps.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



