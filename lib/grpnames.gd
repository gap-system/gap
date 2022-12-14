#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Gábor Horváth, Stefan Kohl, Markus Püschel, Sebastian Egner.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations of attributes, operations and functions
##  related to the determination of structure descriptions for finite groups.
##
##  It also includes comments from corresponding GAP3 code written by
##  Markus Püschel and Sebastian Egner.
##

#############################################################################
##
#O  IsTrivialNormalIntersection( <G>, <U>, <V> ) . . . . . . . generic method
##
##  <ManSection>
##  <Oper Name="IsTrivialNormalIntersection" Arg="G, U, V"/>
##
##  <Description>
##    For normal subgroups <A>U</A> and <A>V</A> of <A>G</A>,
##    <Ref Oper="IsTrivialNormalIntersection"/> returns <K>true</K> if
##    <A>U</A> and <A>V</A> intersect trivially, and <K>false</K> otherwise.
##    The result is undefined if either <A>U</A> or <A>V</A> is not a normal
##    subgroup of G.
##  </Description>
##  </ManSection>
##
DeclareOperation( "IsTrivialNormalIntersection",
                  [ IsGroup, IsGroup, IsGroup ] );

#############################################################################
##
#F  IsTrivialNormalIntersectionInList( <MinNs>, <U>, <V> ) . . generic method
##
##  <ManSection>
##  <Func Name="IsTrivialNormalIntersectionInList" Arg="MinNs, U, V"/>
##
##  <Description>
##    For groups <A>U</A> and <A>V</A>,
##    <Ref Func="IsTrivialNormalIntersectionInList"/> returns <K>false</K>
##    if for any group <M>H</M> in list <A>MinNs</A> both <A>U</A> and
##    <A>V</A> contains the first nontrivial generator of <M>H</M>.
##    Otherwise, the result is <K>true</K>.
##    This function is useful if it is already known that the intersection
##    of <A>U</A> and <A>V</A> is either trivial, or contains at least one
##    group from <A>MinNs</A>.
##    For example if <A>U</A> and <A>V</A> are normal subgroups of a group
##    <M>G</M> and
##    <A>MinNs</A>=<Ref Attr="MinimalNormalSubgroups"/>(<M>G</M>).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "IsTrivialNormalIntersectionInList" );

#############################################################################
##
#F  UnionIfCanEasilySortElements( <L1>[, <L2>, ... ] ) . . . . generic method
##
##  <ManSection>
##  <Func Name="UnionIfCanEasilySortElements" Arg="L1[, L2, ... ]"/>
##
##  <Description>
##    Returns the <Ref Func="Union"/> of <A>Li</A> if
##    <Ref Prop="CanEasilySortElements"/> is <K>true</K> for all elements
##    of all <A>Li</A>, and the <Ref Func="Concatenation"/> of them,
##    otherwise.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "UnionIfCanEasilySortElements" );

#############################################################################
##
#F  AddSetIfCanEasilySortElements( <list>, <object> ) . . . . generic method
##
##  <ManSection>
##  <Func Name="AddSetIfCanEasilySortElements" Arg="list, obj"/>
##
##  <Description>
##    Adds the <A>obj</A> to the list <A>list</A>. If
##    <Ref Prop="CanEasilySortElements"/> is <K>true</K> for <A>list</A>
##    and <A>list</A> is a set, then <Ref Oper="AddSet"/> is used instead
##    of <Ref Oper="Add"/>. Does not return anything, but changes
##    <A>list</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AddSetIfCanEasilySortElements" );

#############################################################################
##
#O  NormalComplement( <G>, <N> ) . . . . . . . . . . . generic method
##
##  <#GAPDoc Label="NormalComplement">
##  <ManSection>
##  <Oper Name="NormalComplement" Arg="G, N"/>
##
##  <Description>
##    Gives a normal complement to the normal subgroup <A>N</A> in <A>G</A>
##    if exists, <K>fail</K> otherwise.
##    In theory it finds the normal complement for infinite <A>G</A>,
##    but can have an infinite loop if <A>G</A>/<A>N</A> is abelian and
##    <A>N</A> is infinite.
##    <C>NormalComplementsNC</C> does not check if <A>N</A> is a normal
##    subgroup of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##    This is the implementation of the algorithm described in
##    Neeraj Kayal and Timur Nezhmetdinov, Factoring Groups Efficiently,
##    in International Colloquium on Automata, Languages and Programming
##    (ICALP), Lecture Notes in Computer Science 5555, 585-596,
##    Springer Verlag, Berlin Heidelberg 2009.
##
DeclareOperation( "NormalComplement", [IsGroup, IsGroup]);
DeclareOperation( "NormalComplementNC", [IsGroup, IsGroup]);

#############################################################################
##
#A  DirectFactorsOfGroup( <G> ) . . . . . decomposition into a direct product
##
##  <#GAPDoc Label="DirectFactorsOfGroup">
##  <ManSection>
##  <Attr Name="DirectFactorsOfGroup" Arg="G"/>
##
##  <Description>
##    A (sorted if possible) list of factors [<M>G_1</M>, .., <M>G_r</M>] such
##    that <A>G</A> = <M>G_1</M> x .. x <M>G_r</M> and none of the <M>G_i</M>
##    is a direct product.
##    If <A>G</A> is an infinite abelian group, then it returns an unsorted
##    list of the factors. DirectFactorsOfGroup currently cannot compute the
##    direct factors of a nonabelian infinite group.
##
##    The option <Q>useKN</Q> forces to use the function
##    DirectFactorsOfGroupKN based on
##    Neeraj Kayal and Timur Nezhmetdinov, Factoring Groups Efficiently,
##    in International Colloquium on Automata, Languages and Programming
##    (ICALP), Lecture Notes in Computer Science 5555, 585-596,
##    Springer Verlag, Berlin Heidelberg 2009.
##    This algorithm never computes normal subgroups, and performs slower in
##    practice than the default method.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DirectFactorsOfGroup", IsGroup );

#############################################################################
##
#A  CharacteristicFactorsOfGroup( <G> ) . decomposition into a direct product
##
##  <#GAPDoc Label="CharacteristicFactorsOfGroup">
##  <ManSection>
##  <Attr Name="CharacteristicFactorsOfGroup" Arg="G"/>
##
##  <Description>
##    For a finite group this function returns a list
##    of characteristic subgroups [<M>G_1</M>, .., <M>G_r</M>] such
##    that <A>G</A> = <M>G_1</M> x .. x <M>G_r</M> and none of the <M>G_i</M>
##    is a direct product of characteristic subgroups.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CharacteristicFactorsOfGroup", IsGroup );

#############################################################################
##
#F  DirectFactorsOfGroupFromList( <G>, <Ns>, <MinNs> )
##
##  <ManSection>
##  <Func Name="DirectFactorsOfGroup" Arg="G, Ns, MinNs"/>
##
##  <Description>
##    A (sorted if possible) list of factors [<M>G_1</M>, .., <M>G_r</M>] such
##    that <A>G</A> = <M>G_1</M> x .. x <M>G_r</M> and none of the <M>G_i</M>
##    is a direct product, and all the factors <M>G_i</M> are from the list
##    <A>Ns</A>. The list <A>MinNs</A> is supposed to be a list such that the
##    intersection of any two groups from <A>Ns</A> is either trivial or
##    contains a group from <A>MinNs</A>.
##  </Description>
##  </ManSection>
##
##  The following hold:
##
##    (1) <Gi> is a normal subgroup of <G>.
##    (2) <i> <= <j> ==> Size(<Gi>) <= Size(<Gj>).
##    (3) Size(<Gi>) > 1 unless <r> = 1 and <G> = 1.
##    (4) <G> = <G1> * .. * <Gr> as the complex product.
##    (5) $Gi \cap (G1 * .. * G_{i-1} * G_{i+1} * .. * Gr) = 1$.
##
##  Factorization of a permutation group into a direct product
##  ==========================================================
##
##  Def.: Seien G1, .., Gr endliche Gruppen, dann ist
##        G := (G1 x .. x Gr, *) eine Gruppe mit der Operation
##          (g1, .., gr)*(h1, .., hr) := (g1 h1, .., gr hr).
##        Wir sagen dann G ist das ("au"sere) direkte Produkt
##        der Gruppen G1, .., Gr und schreiben G = G1 x .. x Gr.
##
##  Lemma: Seien G1, .., Gr Normalteiler der endlichen Gruppe G
##         mit den Eigenschaften
##           (1) |G| = |G1| * .. * |Gr|
##           (2) |Gi meet (Gi+1 * .. * Gr)| = 1
##         Dann ist G = G1 x .. x Gr.
##  Bew.:  M. Hall, Th. 2.5.2.
##
##  Lemma: Seien G = G1 x .. x Gr = H1 x .. x Hs zwei Zerlegungen
##         von G in direkt unzerlegbare Faktoren. Dann gilt
##         (1) r = s
##         (2) Es gibt ein Permutation p der Faktoren, so
##             da"s G[i] ~= H[p(i)] f"ur alle i.
##  Bew.: Satz von Krull-Remak-Schmidt, Huppert I.
##
##  Statements needed for DirectFactorsGroup
##  ========================================
##
##  Lemma:
##  If G1, G2 are normal subgroups in G and (G1 meet G2) = 1
##  then G = G1 x G2 <==> |G| = |G1|*|G2|.
##  Proof:
##    "==>": trivial.
##    "<==": Use G1*G2/G1 ~= G2/(G1 meet G2) = G2/1 ==>
##           |G1*G2|/|G1| = |G2|/|1|. q.e.d.
##
##  Remark:
##   The normal subgroup lattice of G does not contain
##   all the information needed for the normal subgroup lattice
##   of G2 for a decomposition G = G1 x G2. However let
##   G = G1 x .. x Gr be finest direct product decomposition
##   then all Gi are normal subgroups in G. Thus all Gi occur in
##   the set NormalSubgroups(G) and we may split G recursively
##   without recomputing normal subgroup lattices for factors.
##
##  Method to enumerate factorizations given the divisors:
##   Consider a strictly increasing chain
##     1  <  a1 < a2 < .. < a_n  <  A
##   of positive divisors of an integer A.
##   The task is to enumerate all pairs 1 <= i <= j <= n
##   such that a_i*a_j = A. This is done by
##
##   i := 1;
##   j := n;
##   while i <= j do
##     while j > i and a_i*a_j > A do
##       j := j-1;
##     end while;
##     if a_i*a_j = A then
##       "found i <= j with a_i*a_j = A"
##     end if;
##     i := i+1;
##   end while;
##
##   which is based on the following fact:
##   Lemma:
##      Let i1 <= j1, i2 <= j2 be such that
##      a_i1*a_j1 = a_i2*a_j2 = A, then
##        i2 > i1 ==> j2 < j1.
##   Proof:
##      i2 > i1
##      ==> a_i2 > a_i1  by strictly increasing a's
##      ==> a_i1*a_j1 = A = a_i2*a_j2 > a_i1*a_j2 by *a_j2
##      ==> a_j1 > a_j2 by /a_i1
##      ==> j1 > j2. q.e.d
##
##   Now consider two strictly increasing chains
##     1 <= a1 < a2 < .. < a_n <= A
##     1 <= b1 < b2 < .. < b_m <= A
##   of positive divisors of an integer A.
##   The task is to enumerate all pairs i, j with
##   1 <= i <= n, 1 <= j <= m such that a_i*b_j = A.
##      This is done by merging the two sequences into
##   a single increasing sequence of pairs <c_i, which_i>
##   where which_i indicates where c_i is in the a-sequence
##   and where it is in the b-sequence if any. Then the
##   linear algorithm above may be used.
##
DeclareGlobalFunction( "DirectFactorsOfGroupFromList" );

#############################################################################
##
#F  DirectFactorsOfGroupByKN( <G> ) . . . decomposition into a direct product
##
##  <ManSection>
##  <Func Name="DirectFactorsOfGroupKN" Arg="G"/>
##
##  <Description>
##    A (sorted if possible) list of factors [<M>G_1</M>, .., <M>G_r</M>] such
##    that <M>G</M> = <M>G_1</M> x .. x <M>G_r</M> and none of the <M>G_i</M>
##    is a direct product.
##    This is the implementation of the algorithm described in
##    Neeraj Kayal and Timur Nezhmetdinov, Factoring Groups Efficiently,
##    in International Colloquium on Automata, Languages and Programming
##    (ICALP), Lecture Notes in Computer Science 5555, 585-596,
##    Springer Verlag, Berlin Heidelberg 2009.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "DirectFactorsOfGroupByKN" );

#############################################################################
##
#F  SemidirectDecompositionsOfFiniteGroup( <G>[, <L>][, <method>] )
##
##  <ManSection>
##  <Func Name="SemidirectDecompositionsOfFiniteGroup" Arg="G[, L][, method]"/>
##
##  <Description>
##    Computes all conjugacy classes of complements to the normal subgroups
##    in the list <A>L</A>. If <A>L</A> is not given, then it is considered
##    to be the list of all normal subgroups of G.
##
##    Sometimes it is not desirable to compute complements to all normal
##    subgroups, but rather to some. The user can express such a wish by
##    using the <A>method</A> <Q>"any"</Q>.
##
##    With the <A>method</A> <Q<"all"</Q>,
##    SemidirectDecompositionsOfFiniteGroup computes all conjugacy classes
##    of complement subgroups to all normal subgroups in <A>L</A>, and
##    returns a list [[<M>N1</M>, <M>H1</M>], .., [<M>Nr</M>, <M>Hr</M>]] of
##    all direct or semidirect decompositions, where <M>Ni</M> are from
##    <A>L</A>.
##
##    If <A>method</A> <Q>"any"</Q> is used, then
##    SemidirectDecompositionsOfFiniteGroup returns [ <M>N</M>, <M>H</M> ]
##    for some nontrivial <M>N</M> in <A>L</A> if exists, and returns
##    <K>fail</K> otherwise. In particular, it first looks if $<A>G</A> is
##    defined as a nontrivial semidirect product, and if yes, then it
##    returns the two factors. Second, it looks for a nontrivial normal
##    Hall subgroup, and if finds any, then will compute a complement to
##    it. Otherwise it goes through the list <A>L</A>.
##
##    The <A>method</A> <Q>"str"</Q> differs from the <A>method</A>
##    <Q>"any</Q> by not computing normal complement to a normal Hall
##    subgroup <M>N</M>, and in this case returns
##    [ <M>N</M>, <M><A>G</A>/N</M> ].
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "SemidirectDecompositionsOfFiniteGroup" );

#############################################################################
##
#A  SemidirectDecompositions( <G> )
##
##  <ManSection>
##  <Attr Name="SemidirectDecompositions" Arg="G"/>
##
##  <Description>
##    A list [[<M>N_1</M>, <M>H_1</M>], .., [<M>N_r</M>, <M>H_r</M>]] of all
##    direct or semidirect decompositions up to conjugacy classes of
##    <M>H_i</M>. Note that this function also recognizes direct products,
##    and it may take a very long time to run for particular groups.
##  </Description>
##  </ManSection>
##
##  Literatur:
##    [1] Huppert Bd. I, Springer 1983.
##    [2] M. Hall: Theory of Groups. 2nd ed.,
##        Chelsea Publ. Co., 1979 NY.
##
##  Zerlegung eines semidirekten Produkts, Grundlagen
##  =================================================
##
##  Def.: Seien H, N Gruppen und f: H -> Aut(N) ein Gr.-Hom.
##        Dann wird G := (H x N, *) eine Gruppe mit der Operation
##        (h1, n1)*(h2, n2) := (h1 h2, f(h2)(n1)*n2).
##        Wir nennen G das ("au"sere) semidirekte Produkt von H und N
##        und schreiben G = H semidirect[f] N.
##
##  Lemma1:
##    Sei G eine endliche Gruppe, N ein Normalteiler und H eine
##    Untergruppe von G mit den Eigenschaften
##      (1) |H| * |N| = |G| und
##      (2) |H meet N| = 1.
##    Dann gibt es ein f mit G = H semidirect[f] N.
##  Bew.: [2], Th. 6.5.3.
##
##  Lemma2:
##    Sei G = H semidirect[phi] N und h in H, n in N, dann ist auch
##    G = H^(h n) semidirect[psi] N mit
##    psi = inn_n o phi o inn_h^-1 o inn_n^-1.
##  Bew.:
##    1. |H^(h n)| = |H| ==> |H^(h n)|*|N| = |G| und
##       |H^(h n) meet N| = 1 <==> |H meet N| = 1, weil N normal ist.
##       Daher ist G = H^(h n) semidirect[psi] N mit einem
##       psi : H^(h n) -> Aut(N).
##    2. Das psi ist durch H und N eindeutig bestimmt.
##    3. Die Form von psi wie oben angegeben kann durch berechnen
##       von psi(h)(n) nachgepr"uft werden.
##
DeclareAttribute( "SemidirectDecompositions", IsGroup );

#############################################################################
##
#A  DecompositionTypesOfGroup( <G> ) . .  descriptions of decomposition types
#A  DecompositionTypes( <G> )
##
##  <ManSection>
##  <Attr Name="DecompositionTypesOfGroup" Arg="G"/>
##  <Attr Name="DecompositionTypes" Arg="G"/>
##
##  <Description>
##    A list of all possible decomposition types of the group
##    into direct/semidirect products of non-splitting factors. <P/>
##
##    A <E>decomposition type</E> <A>type</A> is denoted by a specification
##    of the form
##    <Log><![CDATA[
##    <type> ::=
##      <integer>                 ; cyclic group of prime power order
##    | ["non-split", <integer>]  ; non-split extension; size annotated
##    | ["x", <type>, .., <type>] ; non-trivial direct product (ass., comm.)
##    | [":", <type>, <type>]     ; non-direct, non-trivial split extension
##    ]]></Log>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "DecompositionTypesOfGroup", IsGroup );
DeclareSynonym( "DecompositionTypes", DecompositionTypesOfGroup );

#############################################################################
##
#P  IsDihedralGroup( <G> )
#A  DihedralGenerators( <G> )
##
##  <#GAPDoc Label="IsDihedralGroup">
##  <ManSection>
##  <Prop Name="IsDihedralGroup" Arg="G"/>
##  <Attr Name="DihedralGenerators" Arg="G"/>
##
##  <Description>
##    <Ref Prop="IsDihedralGroup"/> indicates whether the group <A>G</A> is a
##   dihedral group. If it is, methods may set the attribute
##    <Ref Attr="DihedralGenerators" /> to
##    [<A>t</A>,<A>s</A>], where <A>t</A> and <A>s</A> are two elements such
##    that <A>G</A> = <M>\langle t, s | t^2 = s^n = 1, s^t = s^{-1} \rangle</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsDihedralGroup", IsGroup );
DeclareAttribute( "DihedralGenerators", IsGroup );

InstallTrueMethod( IsGroup, IsDihedralGroup );
InstallTrueMethod( IsDihedralGroup, HasDihedralGenerators );


#############################################################################
##
#P  IsQuaternionGroup( <G> )
#A  QuaternionGenerators( <G> )
##
##  <#GAPDoc Label="IsQuaternionGroup">
##  <ManSection>
##  <Prop Name="IsGeneralisedQuaternionGroup" Arg="G"/>
##  <Prop Name="IsQuaternionGroup" Arg="G"/>
##  <Attr Name="GeneralisedQuaternionGenerators" Arg="G"/>
##  <Attr Name="QuaternionGenerators" Arg="G"/>
##
##  <Description>
##    <Ref Prop="IsGeneralisedQuaternionGroup"/> indicates whether the group
##    <A>G</A> is a generalized quaternion group of size <M>N = 2^(k+1)</M>,
##    <M>k >= 2</M>.
##    If it is, methods may set the attribute <Ref Attr="GeneralisedQuaternionGenerators" />
##    to [<A>t</A>,<A>s</A>], where <A>t</A> and <A>s</A> are two elements such that <A>G</A> =
##    <M>\langle t, s | s^{(2^k)} = 1, t^2 = s^{(2^k-1)}, s^t = s^{-1} \rangle</M>.
##    <Ref Prop="IsQuaternionGroup"/> and <Ref Attr="QuaternionGenerators" /> are
##    provided for backwards compatibility with existing code.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsGeneralisedQuaternionGroup", IsGroup );
DeclareAttribute( "GeneralisedQuaternionGenerators", IsGroup );
# Backwards compatibility
DeclareSynonymAttr( "IsQuaternionGroup", IsGeneralisedQuaternionGroup );
DeclareSynonymAttr( "QuaternionGenerators", GeneralisedQuaternionGenerators );

InstallTrueMethod( IsGroup, IsQuaternionGroup );
InstallTrueMethod( IsGeneralisedQuaternionGroup, HasGeneralisedQuaternionGenerators );


#############################################################################
##
#P  IsQuasiDihedralGroup( <G> )
#A  QuasiDihedralGenerators( <G> )
##
##  <ManSection>
##  <Prop Name="IsQuasiDihedralGroup" Arg="G"/>
##  <Attr Name="QuasiDihedralGenerators" Arg="G"/>
##
##  <Description>
##    Indicates whether the group <A>G</A> is a quasidihedral group
##    of size <M>N = 2^(k+1)</M>, <M>k >= 2</M>. If it is, methods may set
##    the attribute <C>QuasiDihedralGenerators</C> to [<A>t</A>,<A>s</A>],
##    where <A>t</A> and <A>s</A> are two elements such that <A>G</A> =
##    <M><A>t, s | s^(2^k) = t^2 = 1, s^t = s^(-1 + 2^(k-1))</A></M>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsQuasiDihedralGroup", IsGroup );
DeclareAttribute( "QuasiDihedralGenerators", IsGroup );

InstallTrueMethod( IsGroup, IsQuasiDihedralGroup );

#############################################################################
##
#P  IsPSL( <G> )
##
##  <ManSection>
##  <Prop Name="IsPSL" Arg="G"/>
##
##  <Description>
##    Indicates whether the group <A>G</A> is isomorphic to the projective
##    special linear group PSL(<A>n</A>,<A>q</A>) for some integer <A>n</A>
##    and some prime power <A>q</A>. If it is, methods may set the attribute
##    <C>ParametersOfGroupViewedAsPSL</C>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsPSL", IsGroup );
InstallTrueMethod( IsGroup, IsPSL );

#############################################################################
##
#A  ParametersOfGroupViewedAsPSL
#A  ParametersOfGroupViewedAsSL
#A  ParametersOfGroupViewedAsGL
##
##  triples (n,p,e) such that the group is isomorphic to PSL(n,p^e), SL(n,p^e)
##  and GL(n,p^e) respectively
##
##  <ManSection>
##  <Attr Name="ParametersOfGroupViewedAsPSL" Arg="G"/>
##  <Attr Name="ParametersOfGroupViewedAsSL" Arg="G"/>
##  <Attr Name="ParametersOfGroupViewedAsGL" Arg="G"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "ParametersOfGroupViewedAsPSL", IsGroup );
DeclareAttribute( "ParametersOfGroupViewedAsSL", IsGroup );
DeclareAttribute( "ParametersOfGroupViewedAsGL", IsGroup );

#############################################################################
##
#A  AlternatingDegree . . . .  degree of isomorphic natural alternating group
#A  SymmetricDegree . . . . . .  degree of isomorphic natural symmetric group
#A  PSLDegree . . . . . .  (one possible) degree of an isomorphic natural PSL
#A  PSLUnderlyingField . . (one possible) underlying field   "      "      "
#A  SLDegree  . . . . . .  (one possible) degree of an isomorphic natural SL
#A  SLUnderlyingField . .  (one possible) underlying field   "      "      "
#A  GLDegree  . . . . . .  (one possible) degree of an isomorphic natural GL
#A  GLUnderlyingField . .  (one possible) underlying field   "      "      "
##
##  <Attr Name="AlternatingDegree" Arg="G"/>
##  <Attr Name="SymmetricDegree" Arg="G"/>
##  <Attr Name="PSLDegree" Arg="G"/>
##  <Attr Name="PSLUnderlyingField" Arg="G"/>
##  <Attr Name="SLDegree" Arg="G"/>
##  <Attr Name="SLUnderlyingField" Arg="G"/>
##  <Attr Name="GLDegree" Arg="G"/>
##  <Attr Name="GLUnderlyingField" Arg="G"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AlternatingDegree", IsGroup );
DeclareAttribute( "SymmetricDegree", IsGroup );
DeclareAttribute( "PSLDegree", IsGroup );
DeclareAttribute( "PSLUnderlyingField", IsGroup );
DeclareAttribute( "SLDegree", IsGroup );
DeclareAttribute( "SLUnderlyingField", IsGroup );
DeclareAttribute( "GLDegree", IsGroup );
DeclareAttribute( "GLUnderlyingField", IsGroup );

#############################################################################
##
#F  SizeGL(  <n>, <q> )
#F  SizeSL(  <n>, <q> )
#F  SizePSL( <n>, <q> )
##
##  <ManSection>
##  <Func Name="SizeGL" Arg="n, q"/>
##  <Func Name="SizeSL" Arg="n, q"/>
##  <Func Name="SizePSL" Arg="n, q"/>
##
##  <Description>
##    Computes the size of the group GL(<A>n</A>,<A>p</A>^<A>e</A>),
##    SL(<A>n</A>,<A>p</A>^<A>e</A>) or PSL(<A>n</A>,<A>p</A>^<A>e</A>),
##    respectively.
##  </Description>
##  </ManSection>
##
##  The following formulas are used:
##
##      |GL(n, p, e)|  = Product(p^(e n) - p^(e k) : k in [0..n-1])
##      |SL(n, p, e)|  = |GL(n, p, e)| / (p^e - 1)
##      |PSL(n, p, e)| = |SL(n, p, e)| / gcd(p^e - 1, n)
##
DeclareGlobalFunction( "SizeGL" );
DeclareGlobalFunction( "SizeSL" );
DeclareGlobalFunction( "SizePSL" );

#############################################################################
##
#F  LinearGroupParameters( <N> )
##
##  <ManSection>
##  <Func Name="LinearGroupParameters" Arg="N"/>
##
##  <Description>
##    Determines all parameters <A>n</A> >= 2, <A>p</A> prime, <A>e</A> >= 1,
##    such that the given number is the size of one of the linear groups
##    GL(<A>n</A>,<A>p</A>^<A>e</A>), SL(<A>n</A>,<A>p</A>^<A>e</A>) or
##    PSL(<A>n</A>,<A>p</A>^<A>e</A>). <P/>
##    A record with the fields <C>npeGL</C>, <C>npeSL</C>, <C>npePSL</C> is
##    returned, which contains the lists of possible triples
##    [<A>n</A>,<A>p</A>,<A>e</A>].
##  </Description>
##  </ManSection>
##
##  Lemma (o.B.):
##  Es bezeichne
##
##    gl(n, p, e)  = Product(p^(e n) - p^(e k) : k in [0..n-1])
##    sl(n, p, e)  = gl(n, p, e) / (p^e - 1)
##    psl(n, p, e) = sl(n, p, e) / gcd(p^e - 1, n)
##
##  die Gr"o"sen der Gruppen GL, SL, PSL mit den Parametern
##  n, p, e. Dann gilt
##
##    gl(n, p, e)  = sl(n, p, e)  <==>  p^e = 2
##    sl(n, p, e)  = psl(n, p, e) <==>  gcd(p^e - 1, n) = 1
##    psl(n, p, e) = gl(n, p, e)  <==>  p^e = 2
##
##  und in diesen F"allen sind die dazugeh"origen Gruppen auch
##  isomorph. Dar"uberhinaus existieren genau die folgenden
##  sporadischen "Ubereinstimmungen
##
##    psl(2, 2, 2) = psl(2, 5, 1) = 60    ; PSL(2, 4) ~= PSL(2, 5) ~= A5
##    psl(2, 7, 1) = psl(3, 2, 1) = 168   ; PSL(2, 7) ~= PSL(3, 2)
##    psl(4, 2, 1) = psl(3, 2, 2) = 20160 ; PSL(4, 2) not~= PSL(3, 4)
##
##  wobei in den ersten beiden F"allen die dazugeh"origen Gruppen
##  isomorph sind, im letzten Fall aber nicht! Die Gruppen PSL(4, 2)
##  und PSL(3, 4) sind "uber das Zentrum ihrer 2-Sylowgruppen
##  unterscheidbar (Huppert: S.185).
##  Es bezeichne Z1, Z2 die Zentren der 2-Sylowgruppen von PSL(4, 2)
##  bzw. PSL(3, 4). Dann ist |Z1| = 2 und |Z2| = 4.
##
##  Die Aussage des Lemmas wurde rechnerisch bis zur Gruppenordnung 10^100
##  getestet.
##
DeclareGlobalFunction( "LinearGroupParameters" );

#############################################################################
##
#A  StructureDescription( <G> )
##
##  <#GAPDoc Label="StructureDescription">
##  <ManSection>
##  <Attr Name="StructureDescription" Arg="G"/>
##
##  <Description>
##  The method for <Ref Attr="StructureDescription"/> exhibits a structure
##  of the given group <A>G</A> to some extent, using the strategy outlined
##    below. The idea is to return a possibly short string which gives some
##    insight in the structure of the considered group. It is intended
##  primarily for small groups (order less than 100) or groups with few normal
##  subgroups, in other cases, in particular large <M>p</M>-groups, it can
##  be very costly. Furthermore, the string returned is -- as the action on
##  chief factors is not described -- often not the most useful way to describe
##  a group.<P/>
##
##  The string returned by <Ref Attr="StructureDescription"/> is
##  <B>not</B> an isomorphism invariant: non-isomorphic groups can have the
##  same string value, and two isomorphic groups in different representations
##  can produce different strings.
##
##  The value returned by <Ref Attr="StructureDescription"/> is a string of
##  the following form: <P/>
##  <Listing><![CDATA[
##    StructureDescription(<G>) ::=
##        1                                 ; trivial group
##      | C<size>                           ; finite cyclic group
##      | Z                                 ; infinite cyclic group
##      | A<degree>                         ; alternating group
##      | S<degree>                         ; symmetric group
##      | D<size>                           ; dihedral group
##      | Q<size>                           ; quaternion group
##      | QD<size>                          ; quasidihedral group
##      | PSL(<n>,<q>)                      ; projective special linear group
##      | SL(<n>,<q>)                       ; special linear group
##      | GL(<n>,<q>)                       ; general linear group
##      | PSU(<n>,<q>)                      ; proj. special unitary group
##      | O(2<n>+1,<q>)                     ; orthogonal group, type B
##      | O+(2<n>,<q>)                      ; orthogonal group, type D
##      | O-(2<n>,<q>)                      ; orthogonal group, type 2D
##      | PSp(2<n>,<q>)                     ; proj. special symplectic group
##      | Sz(<q>)                           ; Suzuki group
##      | Ree(<q>)                          ; Ree group (type 2F or 2G)
##      | E(6,<q>) | E(7,<q>) | E(8,<q>)    ; Lie group of exceptional type
##      | 2E(6,<q>) | F(4,<q>) | G(2,<q>)
##      | 3D(4,<q>)                         ; Steinberg triality group
##      | M11 | M12 | M22 | M23 | M24
##      | J1 | J2 | J3 | J4 | Co1 | Co2
##      | Co3 | Fi22 | Fi23 | Fi24' | Suz
##      | HS | McL | He | HN | Th | B
##      | M | ON | Ly | Ru                  ; sporadic simple group
##      | 2F(4,2)'                          ; Tits group
##      | PerfectGroup(<size>,<id>)         ; the indicated group from the
##                                          ; library of perfect groups
##      | A x B                             ; direct product
##      | N : H                             ; semidirect product
##      | C(G) . G/C(G) = G' . G/G'         ; non-split extension
##                                          ; (equal alternatives and
##                                          ; trivial extensions omitted)
##      | Phi(G) . G/Phi(G)                 ; non-split extension:
##                                          ; Frattini subgroup and
##                                          ; Frattini factor group
##  ]]></Listing>
##  <P/>
##  Note that the <Ref Attr="StructureDescription"/> is only <E>one</E>
##  possible way of building up the given group from smaller pieces. <P/>
##
##  The option <Q>short</Q> is recognized - if this option is set, an
##  abbreviated output format is used (e.g. <C>"6x3"</C> instead of
##  <C>"C6 x C3"</C>). <P/>
##
##  If the <Ref Attr="Name"/> attribute is not bound, but
##  <Ref Attr="StructureDescription"/> is, <Ref Func="View"/> prints the
##  value of the attribute <Ref Attr="StructureDescription"/>.
##  The <Ref Func="Print"/>ed representation of a group is not affected
##  by computing a <Ref Attr="StructureDescription"/>. <P/>
##
##  The strategy used to compute a <Ref Attr="StructureDescription"/> is
##  as follows:
##  <P/>
##  <List>
##  <Mark>1.</Mark>
##  <Item>
##    Lookup in a precomputed list, if the order of <A>G</A> is not
##    larger than 100 and not equal to 64 or 96.
##  </Item>
##  <Mark>2.</Mark>
##  <Item>
##    If <A>G</A> is abelian, then decompose it into cyclic factors
##    in <Q>elementary divisors style</Q>. For example,
##    <C>"C2 x C3 x C3"</C> is <C>"C6 x C3"</C>.
##    For infinite abelian groups, <C>"Z"</C> denotes the group of integers.
##  </Item>
##  <Mark>3.</Mark>
##  <Item>
##    Recognize alternating groups, symmetric groups,
##    dihedral groups, quasidihedral groups, quaternion groups,
##    PSL's, SL's, GL's and simple groups not listed so far
##    as basic building blocks.
##  </Item>
##  <Mark>4.</Mark>
##  <Item>
##    Decompose <A>G</A> into a direct product of irreducible factors.
##  </Item>
##  <Mark>5.</Mark>
##  <Item>
##    Recognize semidirect products <A>G</A>=<M>N</M>:<M>H</M>,
##    where <M>N</M> is normal.
##    Select a pair <M>N</M>, <M>H</M> with the following preferences:
##    <List>
##    <Mark>1.</Mark>
##    <Item>
##      if <A>G</A> is defined as a semidirect product of <M>N</M>, <M>H</M>
##      then select <M>N</M>, <M>H</M>,
##    </Item>
##    <Mark>2.</Mark>
##    <Item>
##      if <A>G</A> is solvable, then select a solvable normal Hall subgroup
##      <M>N</M>, if exists, and consider the semidirect decomposition of
##      <M>N</M> and <M><A>G</A>/N</M>,
##    </Item>
##    <Mark>3.</Mark>
##    <Item>
##      find any nontrivial normal subgroup <M>N</M> which has a complement
##      <M>H</M>.
##    </Item>
##    </List>
##    The option <Q>nice</Q> is recognized. If this option is set, then all
##    semidirect products are computed in order to find a possibly nicer
##    presentation. Note, that this may take a very long time if <A>G</A> has
##    many normal subgroups, e.g. if <M><A>G</A>/<A>G</A>'</M> has many cyclic
##    factors.
##    If the option <Q>nice</Q> is set, then GAP would select a pair
##    <M>N</M>, <M>H</M> with the following preferences:
##    <List>
##    <Mark>1.</Mark>
##    <Item>
##      <M>H</M> is abelian
##    </Item>
##    <Mark>2.</Mark>
##    <Item>
##      <M>N</M> is abelian
##    </Item>
##    <Mark>2a.</Mark>
##    <Item>
##      <M>N</M> has many abelian invariants
##    </Item>
##    <Mark>3.</Mark>
##    <Item>
##      <M>N</M> is a direct product
##    </Item>
##    <Mark>3a.</Mark>
##    <Item>
##      <M>N</M> has many direct factors
##    </Item>
##    <Mark>4.</Mark>
##    <Item>
##      <M>\phi: H \rightarrow</M> Aut(<M>N</M>),
##      <M>h \mapsto (n \mapsto n^h)</M> is injective.
##    </Item>
##    </List>
##  </Item>
##  <Mark>6.</Mark>
##  <Item>
##    Fall back to non-splitting extensions:
##    If the centre or the commutator factor group is non-trivial,
##    write <A>G</A> as <M>Z(<A>G</A>)</M>.<M><A>G</A>/Z(<A>G</A>)</M> or
##    <M><A>G</A>'</M>.<M><A>G</A>/<A>G</A>'</M>, respectively.
##    Otherwise if the Frattini subgroup is non-trivial, write <A>G</A>
##    as <M>\Phi</M>(<A>G</A>).<A>G</A>/<M>\Phi</M>(<A>G</A>).
##  </Item>
##  <Mark>7.</Mark>
##  <Item>
##    If no decomposition is found (maybe this is not the case for
##    any finite group), try to identify <A>G</A> in the perfect groups
##    library. If this fails also, then return a string describing this
##    situation.
##  </Item>
##  </List>
##  Note that <Ref Attr="StructureDescription"/> is <E>not</E> intended
##  to be a research tool, but rather an educational tool. The reasons for
##  this are as follows:
##  <List>
##    <Mark>1.</Mark>
##    <Item>
##      <Q>Most</Q> groups do not have <Q>nice</Q> decompositions.
##      This is in some contrast to what is often taught in elementary
##      courses on group theory, where it is sometimes suggested that
##      basically every group can be written as iterated direct or
##      semidirect product of cyclic groups and nonabelian simple groups.
##    </Item>
##    <Mark>2.</Mark>
##    <Item>
##      In particular many <M>p</M>-groups have very <Q>similar</Q>
##      structure, and <Ref Attr="StructureDescription"/> can only
##      exhibit a little of it. Changing this would likely make the
##      output not essentially easier to read than a pc presentation.
##    </Item>
##  </List>
##  <Example><![CDATA[
##  gap> l := AllSmallGroups(12);;
##  gap> List(l,StructureDescription);; l;
##  [ C3 : C4, C12, A4, D12, C6 x C2 ]
##  gap> List(AllSmallGroups(40),G->StructureDescription(G:short));
##  [ "5:8", "40", "5:8", "5:Q8", "4xD10", "D40", "2x(5:4)", "(10x2):2",
##    "20x2", "5xD8", "5xQ8", "2x(5:4)", "2^2xD10", "10x2^2" ]
##  gap> List(AllTransitiveGroups(DegreeAction,6),
##  >         G->StructureDescription(G:short));
##  [ "6", "S3", "D12", "A4", "3xS3", "2xA4", "S4", "S4", "S3xS3",
##    "(3^2):4", "2xS4", "A5", "(S3xS3):2", "S5", "A6", "S6" ]
##  gap> StructureDescription(SmallGroup(504,7));
##  "C7 : (C9 x Q8)"
##  gap> StructureDescription(SmallGroup(504,7):nice);
##  "(C7 : Q8) : C9"
##  gap> StructureDescription(AbelianGroup([0,2,3]));
##  "Z x C6"
##  gap> StructureDescription(AbelianGroup([0,0,0,2,3,6]):short);
##  "Z^3x6^2"
##  gap> StructureDescription(PSL(4,2));
##  "A8"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "StructureDescription", IsGroup );
