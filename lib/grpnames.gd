#############################################################################
##
#W  grpnames.gd                                                   Stefan Kohl
##                                                             Markus Püschel
##                                                            Sebastian Egner
##
#H  @(#)$Id$
##
#Y  Copyright (C) 2004 The GAP Group
##
##  This file contains declarations of attributes, operations and functions
##  related to the determination of structure descriptions for finite groups.
##
##  It also includes comments from corresponding GAP3 code written by
##  Markus Püschel and Sebastian Egner.
##
Revision.grpnames_gd :=
  "@(#)$Id$";

#############################################################################
##
#A  DirectFactorsOfGroup( <G> ) . . . . . decomposition into a direct product
##
##  A sorted list of factors [<G1>, .., <Gr>] such that
##  <G> = <G1> x .. x <Gr> and none of the <Gi> is a direct product.
##  This means
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
##   and where it is in the b-sequence if any. The the
##   linear algorithm above may be used.
##
DeclareAttribute( "DirectFactorsOfGroup", IsGroup );

#############################################################################
##
#A  SemidirectFactorsOfGroup( <G> ) . decomposition into a semidirect product
##
##  A list [[<H1>, <N1>], .., [<Hr>, <Nr>]] of all direct or semidirect
##  decompositions with minimal <H>: <G> = <Hi> semidirect <Ni> and
##  |<Hi>| = |<Hj>| is minimal with respect to all semidirect products.
##  Note that this function also recognizes direct products.
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
DeclareAttribute( "SemidirectFactorsOfGroup", IsGroup );

#############################################################################
##
#A  DecompositionTypesOfGroup( <G> ) . .  descriptions of decomposition types
#A  DecompositionTypes( <G> )
##
##  A list of all possible decomposition types of the group
##  into direct/semidirect products of non-splitting factors.
##
##  A *decomposition type* <type> is denoted by a specification of the form
##  \begintt
##  <type> ::= 
##      <integer>                 ; cyclic group of prime power order
##    | ["non-split", <integer>]  ; non-split extension; size annotated
##    | ["x", <type>, .., <type>] ; non-trivial direct product (ass., comm.)
##    | [":", <type>, <type>]     ; non-direct, non-trivial split extension
##  \endtt
##
DeclareAttribute( "DecompositionTypesOfGroup", IsGroup );
DeclareSynonym( "DecompositionTypes", DecompositionTypesOfGroup );

#############################################################################
##
#P  IsDihedralGroup( <G> )
#A  DihedralGenerators( <G> )
##
##  Indicates whether the group <G> is a Dihedral group. If so, methods may
##  set the attribute `DihedralGenerators' to [<t>,<s>] with two elements
##  <t>, <s> such that <G> = $<t, s | t^2 = s^n = 1, s^t = s^-1>$.
##
DeclareProperty( "IsDihedralGroup", IsGroup );
DeclareAttribute( "DihedralGenerators", IsGroup );

#############################################################################
##
#P  IsQuaternionGroup( <G> )
#A  QuaternionGenerators( <G> )
##
##  Indicates whether the group <G> is a generalized Quaternion group 
##  of size $N = 2^(k+1)$, $k >= 2$. If so, methods may set the attribute
##  `QuaternionGenerators' to [<t>,<s>] with two elements <t>, <s> such that 
##  <G> = $<t, s | s^(2^k) = 1, t^2 = s^(2^k-1), s^t = s^-1>$.
##
DeclareProperty( "IsQuaternionGroup", IsGroup );
DeclareAttribute( "QuaternionGenerators", IsGroup );

#############################################################################
##
#P  IsQuasiDihedralGroup( <G> )
#A  QuasiDihedralGenerators( <G> )
##
##  Indicates whether the group <G> is a quasidihedral group 
##  of size $N = 2^(k+1)$, $k >= 2$. If so, methods may set the attribute
##  `QuasiDihedralGenerators' to [<t>,<s>] with two elements <t>, <s> such
##  that <G> = $<t, s | s^(2^k) = t^2 = 1, s^t = s^(-1 + 2^(k-1))>$.
##
DeclareProperty( "IsQuasiDihedralGroup", IsGroup );
DeclareAttribute( "QuasiDihedralGenerators", IsGroup );

#############################################################################
##
#P  IsPSL( <G> )
##
##  Indicates whether the group <G> is isomorphic to the projective special
##  linear group PSL(<n>,<q>) for some integer <n> and some prime power <q>.
##
##  Methods may set the attribute `npePSL'.
##
DeclareProperty( "IsPSL", IsGroup );

#############################################################################
##
#A  npePSL .  triples (n,p,e) such that the group is isomorphic to PSL(n,p^e)
#A  npeSL  .  triples (n,p,e) such that the group is isomorphic to  SL(n,p^e)
#A  npeGL  .  triples (n,p,e) such that the group is isomorphic to  GL(n,p^e)
##
DeclareAttribute( "npePSL", IsGroup );
DeclareAttribute( "npeSL", IsGroup );
DeclareAttribute( "npeGL", IsGroup );

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
##  Computes the size of the group GL(<n>,<p>^<e>), SL(<n>,<p>^<e>),
##  PSL(<n>,<p>^<e>) respectively according to the formulas:
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
##  Determines all parameters <n> >= 2, <p> prime, <e> >= 1, 
##  such that the given number is the size of one of the linear groups
##  GL(<n>,<p>^<e>), SL(<n>,<p>^<e>), PSL(<n>,<p>^<e>).
##
##  A record with the fields npeGL, npeSL, npePSL is returned 
##  containing the lists of possible triples [<n>,<p>,<e>].
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
##  The method for `StructureDescription' exhibits the structure of the
##  given group to some extend using the strategy outlined below. The idea
##  is to return a possibly short string which gives some insight in the
##  structure of the considered group and can be computed reasonably quickly.
##
##  Note that non-isomorphic groups can have the same `StructureDescription',
##  since the structure description might not exhibit the structure of the
##  considered group in all detail. However, isomorphic groups in different
##  representation will always obtain the same structure description.
##
##  The `StructureDescription' is a string of the following form:
##
##  \begintt
##    StructureDescription(<G>) ::=
##       1                                 ; trivial group 
##     || C<size>                           ; cyclic group
##     || A<degree>                         ; alternating group
##     || S<degree>                         ; symmetric group
##     || D<size>                           ; dihedral group
##     || Q<size>                           ; quaternion group
##     || QD<size>                          ; quasidihedral group
##     || PSL(<n>,<q>)                      ; projective special linear group
##     || SL(<n>,<q>)                       ; special linear group
##     || GL(<n>,<q>)                       ; general linear group
##     || PSU(<n>,<q>)                      ; proj. special unitary group
##     || O(2<n>+1,<q>)                     ; orthogonal group, type B
##     || O+(2<n>,<q>)                      ; orthogonal group, type D
##     || O-(2<n>,<q>)                      ; orthogonal group, type 2D
##     || PSp(2<n>,<q>)                     ; proj. special symplectic group
##     || Sz(<q>)                           ; Suzuki group
##     || Ree(<q>)                          ; Ree group (type 2F or 2G)
##     || E(6,<q>) || E(7,<q>) || E(8,<q>)    ; Lie group of exceptional type
##     || 2E(6,<q>) || F(4,<q>) || G(2,<q>)
##     || 3D(4,<q>)                         ; Steinberg triality group
##     || M11 || M12 || M22 || M23 || M24
##     || J1 || J2 || J3 || J4 || Co1 || Co2
##     || Co3 || Fi22 || Fi23 || Fi24' || Suz
##     || HS || McL || He || HN || Th || B
##     || M || ON || Ly || Ru                  ; sporadic simple group
##     || 2F(4,2)'                          ; Tits group
##     || PerfectGroup(<size>,<id>)         ; the indicated group from the
##                                         ; library of perfect groups
##     || A x B                             ; direct product
##     || N : H                             ; semidirect product
##     || C(G) . G/C(G) = G' . G/G'         ; non-split extension
##                                         ; (equal alternatives and
##                                         ; trivial extensions omitted)
##     || Phi(G) . G/Phi(G)                 ; non-split extension:
##                                         ; Frattini subgroup and
##                                         ; Frattini factor group
##  \endtt
##
##  Note that the method chooses *one* possible way of building up
##  the given group from smaller pieces (others are possible too).
##
##  The option ``short'' is recognized -- if this option is set, an
##  abbreviated output format is used (e.g. `"6x3"' instead of `"C6 x C3"').
##
##  If the `Name' attribute is not bound, but `StructureDescription' is,
##  `View' prints the value of the attribute `StructureDescription'.
##  The `Print'ed representation of a group is not affected by computing
##  a `StructureDescription'.
##
##  The strategy is
##
##  \beginlist
##    \item{1.} Lookup in precomputed list, if the order of <G> is not
##              larger than 100 and not equal to 64.
##
##    \item{2.} If <G> is abelian: decompose it into cyclic factors
##              in ``elementary divisors style'',
##              e.g. `"C2 x C3 x C3"' is `"C6 x C3"'.
##
##    \item{3.} Recognize alternating groups, symmetric groups,
##              dihedral groups, quasidihedral groups, quaternion groups,
##              PSL's, SL's, GL's and simple groups not listed so far
##              as basic building blocks.
##
##    \item{4.} Decompose into a direct product of irreducible factors.
##
##    \item{5.} Recognize semidirect products ($N$:$H$), where $N$ is normal.
##              Select a pair $N$, $H$ with the following preferences: 
##              \beginlist
##                \item{1.}  $H$ is abelian
##
##                \item{2.}  $N$ is abelian
##
##                \item{2a.} $N$ has many abelian invariants
##
##                \item{3.}  $N$ is a direct product
##
##                \item{3a.} $N$ has many direct factors
##
##                \item{4.}  $\phi: H \rightarrow$ Aut($N$), 
##                           $h \mapsto (n \mapsto n^h)$ is injective.
##              \endlist
##
##    \item{6.} Fall back to non-splitting extensions:
##              If the centre or the commutator factor group is non-trivial,
##              write <G> as Z(<G>).<G>/Z(<G>) resp. <G>'.<G>/<G>'.
##              Otherwise if the Frattini subgroup is non-trivial,
##              write <G> as $\Phi$(<G>).<G>/$\Phi$(<G>).
##
##    \item{7.} If no decomposition is found (maybe this is not the case for
##              any finite group) try to identify <G> in the perfect groups
##              library.
##              If also this fails return a string describing this situation.
##  \endlist
##
DeclareAttribute( "StructureDescription", IsGroup );

#############################################################################
##
#E  grpnames.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here