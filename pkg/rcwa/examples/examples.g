#############################################################################
##
#W  examples.g                GAP4 Package `RCWA'                 Stefan Kohl
##
##  This file contains a collection of examples of rcwa mappings and -groups.
##  It can be read into a GAP session by the function `RCWALoadExamples'
##  which takes no arguments and returns a record containing all examples.
##
##  Selected examples are discussed in some detail in the manual chapter
##  "Examples". The global variables defined there can be assigned by
##  applying the function `AssignGlobals' to the the respective component
##  of the record returned by `RCWALoadExamples'. The component names are
##  given in the corresponding sections of the manual.
##
##  Note that since the beginnings of RCWA, examples have only been added to
##  this file, but never been removed. For this reason, there are 'older' and
##  'newer' examples, where the latter are often considerably 'better' than
##  the former. 
##
#############################################################################

local  RCWAExamples, tau, nu, t, rc, k, l, m, n, x, e, r;

RCWAExamples := rec( );

#############################################################################
##
##  Some basics.
##
rc  := function(r,m) return ResidueClass(DefaultRing(m),m,r); end;

nu  := ClassShift(Integers);
t   := ClassReflection(Integers);
tau := ClassTransposition(0,2,1,2);

RCWAExamples.Basics := rec( tau := tau, nu := nu, t := t );
SetName(RCWAExamples.Basics.tau,"tau");
SetName(RCWAExamples.Basics.nu,"nu");
SetName(RCWAExamples.Basics.t,"t");

#############################################################################
##
##  The Collatz mapping and a few related mappings.
##
RCWAExamples.CollatzMapping := rec( T   := RcwaMapping([[1,0,2],[3,1,2]]),
                                    T5  := RcwaMapping([[1,0,2],[5,-1,2]]),
                                    Tp  := RcwaMapping([[1,0,2],[3,1,2]]),
                                    Tm  := RcwaMapping([[1,0,2],[3,-1,2]]),
                                    T5m := RcwaMapping([[1,0,2],[5,-1,2]]),
                                    T5p := RcwaMapping([[1,0,2],[5,1,2]]) );
SetName(RCWAExamples.CollatzMapping.T,"T");
SetName(RCWAExamples.CollatzMapping.T5,"T5");
SetName(RCWAExamples.CollatzMapping.Tp,"T+");
SetName(RCWAExamples.CollatzMapping.Tm,"T-");
SetName(RCWAExamples.CollatzMapping.T5m,"T5-");
SetName(RCWAExamples.CollatzMapping.T5p,"T5+");

#############################################################################
##
##  The Higman-Thompson group
##
##  As John P. McDermott has observed, the group G = H = CT_{}(Z) in this
##  example is isomorphic to the (first) Higman-Thompson group.
##
##  For details on the Higman-Thompson group, see
##
##  [1] Graham Higman. Finitely Presented Infinite Simple Groups.
##      Notes on Pure Mathematics, 1974, Department of Pure Mathematics,
##      Australian National University, Canberra, ISBN 0 7081 0300 6.
##
k := ClassTransposition(0,2,1,2); l := ClassTransposition(1,2,2,4);
m := ClassTransposition(0,2,1,4); n := ClassTransposition(1,4,2,4);

x := Indeterminate(GF(2)); SetName(x,"x");

RCWAExamples.HigmanThompson := rec(

  G := Group(List([[0,2,1,4],[0,4,1,4],[1,4,2,4],[2,4,3,4]],
                            ClassTransposition)),

  k := ClassTransposition(0,2,1,2), # kappa in Higman's book.
  l := ClassTransposition(1,2,2,4), # lambda    "
  m := ClassTransposition(0,2,1,4), # mu        "
  n := ClassTransposition(1,4,2,4), # nu        "

  H := Group(k,l,m,n), # G = H

  HigmanThompsonRels := # List of identity mappings, for checking purposes.
  [ k^2, l^2, m^2, n^2,                             # (1) in [1], p.50.
    l*k*m*k*l*n*k*n*m*k*l*k*m,                      # (2)           "
    k*n*l*k*m*n*k*l*n*m*n*l*n*m,                    # (3)           "
    (l*k*m*k*l*n)^3, (m*k*l*k*m*n)^3,               # (4)           "
    (l*n*m)^2*k*(m*n*l)^2*k,                        # (5)           "
    (l*n*m*n)^5,                                    # (6)           "
    (l*k*n*k*l*n)^3*k*n*k*(m*k*n*k*m*n)^3*k*n*k*n,  # (7)           "
    ((l*k*m*n)^2*(m*k*l*n)^2)^3,                    # (8)           "
    (l*n*l*k*m*k*m*n*l*n*m*k*m*k)^4,                # (9)           "
    (m*n*m*k*l*k*l*n*m*n*l*k*l*k)^4,                #(10)           "
    (l*m*k*l*k*m*l*k*n*k)^2,                        #(11)           "
    (m*l*k*m*k*l*m*k*n*k)^2 ],                      #(12)           "

  g1 := ClassTransposition(0,2,1,4),
  g2 := ClassTransposition(0,2,3,4),
  g3 := ClassTransposition(1,2,0,4),
  g4 := ClassTransposition(1,2,2,4),

  h1 := ClassTransposition(0,4,1,4),
  h2 := ClassTransposition(1,4,2,4),

  S := Filtered(List(ClassPairs(4),ClassTransposition),
                     ct->Mod(ct) in [2,4]),

  ReducingConjugator := function ( tau )

    local  w, F, g1, g2, g3, g4, h1, h2, h, cls, cl, r;

    g1 := ClassTransposition(0,2,1,4);
    g2 := ClassTransposition(0,2,3,4);
    g3 := ClassTransposition(1,2,0,4);
    g4 := ClassTransposition(1,2,2,4);

    h1 := ClassTransposition(0,4,1,4);
    h2 := ClassTransposition(1,4,2,4);

    F := FreeGroup("g1","g2","g3","g4","h1","h2");
    w := One(F); if Mod(tau) <= 4 then return w; fi;

    cls := TransposedClasses(tau);
    if Mod(cls[1]) = 2 then
      if Residue(cls[1]) = 0 then
        if Residue(cls[2]) mod 4 = 1 then tau := tau^g2; w := w * F.2;
                                     else tau := tau^g1; w := w * F.1; fi;
      else
        if Residue(cls[2]) mod 4 = 0 then tau := tau^g4; w := w * F.4;
                                     else tau := tau^g3; w := w * F.3; fi;
      fi;
    fi;

    while Mod(tau) > 4 do
      if not ForAny(AllResidueClassesModulo(2),
                    cl -> IsEmpty(Intersection(cl,Support(tau))))
      then
        cls := TransposedClasses(tau);
        h := Filtered([h1,h2],
               hi->Length(Filtered(cls,cl->IsSubset(Support(hi),cl)))=1);
        h := h[1]; tau := tau^h;
        if h = h1 then w := w * F.5; else w := w * F.6; fi;
      fi;
      cl := TransposedClasses(tau)[2]; # class with larger modulus
      r  := Residue(cl);
      if   r mod 4 = 1 then tau := tau^g1; w := w * F.1;
      elif r mod 4 = 3 then tau := tau^g2; w := w * F.2;
      elif r mod 4 = 0 then tau := tau^g3; w := w * F.3;
      elif r mod 4 = 2 then tau := tau^g4; w := w * F.4; fi;
    od;

    return w;
  end,

  # The Higman-Thompson group over GF(2)[x].

  x := x,
  R := PolynomialRing(GF(2),1),

  kp := ClassTransposition(0,x,1,x),     # kappa in Higman's book.
  lp := ClassTransposition(1,x,x,x^2),   # lambda    "
  mp := ClassTransposition(0,x,1,x^2),   # mu        "
  np := ClassTransposition(1,x^2,x,x^2), # nu        "

  Hp := Group(~.kp,~.lp,~.mp,~.np)

);

#############################################################################
##
##  Finite generation of CT_P(Z) for finite sets P
##
##  Given a set P of odd primes, let CT_P(Z) denote the group which is
##  generated by all class transpositions (r_1(m_1),r_2(m_2)) where all odd
##  prime factors of m_1 and m_2 lie in P. The groups CT_P(Z) are simple, cf.
##
##    A Simple Group Generated by Involutions Interchanging Residue Classes
##    of the Integers, Math. Z. 264 (2010), no. 4, 927-938.
##
##  The group CT_P(Z) is finitely generated if and only if P is finite.
##  If P is the empty set, then CT_P(Z) is isomorphic to the Higman-Thompson
##  group (see above).
##
##  Let m := 8 * \prod_(p in P) p^2, and let C_m be the set of all class
##  transpositions in CT_P(Z) whose moduli divide m. Given a class transposi-
##  tion tau in CT_P(Z), the function given below returns a list l of class
##  transpositions (r_i(m_i),r_j(m_j)) in C_m such that tau^g in C_m, where
##  g denotes the product of the class transpositions in l.
##
RCWAExamples.CTPZ := rec(

  ListOfReducingConjugators := function ( tau )

    local  facts, P, m, p, cls, k1, k2, m1, m2, m3, m4, r1, r2, r4, h, sigma;

    P := Difference(PrimeSet(tau),[2]);
    m := 8 * Product(P)^2;

    facts := [];

    for p in Union(P,[2]) do

      repeat

        cls := TransposedClasses(tau);

        m1 := Modulus(cls[1]); m2 := Modulus(cls[2]);
        r1 := Residue(cls[1]); r2 := Residue(cls[2]);

        k1 := Number(Factors(m1),pi->pi=p);
        k2 := Number(Factors(m2),pi->pi=p);

        if k1 > k2 then
          h := k1; k1 := k2; k2 := h;
          h := m1; m1 := m2; m2 := h;
          h := r1; r1 := r2; r2 := h;
          cls := Reversed(cls);
        fi;

        if k2 > 2 then

          m3 := Gcd(m,m2); m4 := m3/p;

          r4 := 0;
          while Intersection(ResidueClass(r4,m4),Support(tau)) <> [] do
            r4 := r4 + 1;
          od;

          sigma := ClassTransposition(r2,m3,r4,m4);
          tau   := tau^sigma;
          Add(facts,sigma);

        fi;

      until k2 <= 2;

    od;

    return facts;
  end );

#############################################################################
##
##  The group CT_{3}(Z)
##
##  Using this package, the generating set C_72 for CT_{3}(Z)
##  (cf. Example "Finite generation of CT_P(Z) for finite sets P")
##  can be reduced to the set of 20 class transpositions given below.
##
RCWAExamples.CT3Z := rec(

  gens := List([ [0,2,1,2], [1,2,2,4], [0,2,1,4], [1,4,2,4],
                 [0,3,1,3], [1,3,2,3], [0,3,1,9], [0,3,4,9],
                 [0,3,7,9], [0,2,1,6], [0,2,5,6], [0,3,1,6],
                 [0,4,1,6], [0,4,5,6], [2,4,3,6], [0,6,1,8],
                 [0,6,7,8], [3,6,4,8], [0,8,1,8], [6,8,7,8] ],
               ClassTransposition),

  CT3Z := Group(~.gens)

);

#############################################################################
##
##  An infinite subgroup of CT(GF(2)[x]) with many torsion elements
##
RCWAExamples.OddNumberOfGens_FiniteOrder := rec(

  x := Indeterminate(GF(2)),
  R := PolynomialRing(GF(2),1),
  a := ClassTransposition(0,~.x,1,~.x),
  b := ClassTransposition(0,~.x^2+1,1,~.x^2+1),
  c := ClassTransposition(1,~.x,0,~.x^2+~.x),
  G := Group(~.a,~.b,~.c),
  H := Subgroup(~.G,[~.a*~.b,~.a*~.c])

);

SetName(RCWAExamples.OddNumberOfGens_FiniteOrder.x,"x");

#############################################################################
##
##  Examples of rcwa mappings of Z^2.
##
RCWAExamples.ZxZ := rec(

  R := Integers^2,

  twice        := RcwaMapping(~.R,[[1,0],[0,1]],[[[[2,0],[0,2]],[0,0],1]]),
  twice1       := RcwaMapping(~.R,[[1,0],[0,1]],[[[[2,0],[0,1]],[0,0],1]]),
  twice2       := RcwaMapping(~.R,[[1,0],[0,1]],[[[[1,0],[0,2]],[0,0],1]]),
  switch       := RcwaMapping(~.R,[[1,0],[0,1]],[[[[0,1],[1,0]],[0,0],1]]),
  reflection   := RcwaMapping(~.R,[[1,0],[0,1]],[[[[-1,0],[0,-1]],[0,0],1]]),
  reflection1  := RcwaMapping(~.R,[[1,0],[0,1]],[[[[-1,0],[0,1]],[0,0],1]]),
  reflection2  := RcwaMapping(~.R,[[1,0],[0,1]],[[[[1,0],[0,-1]],[0,0],1]]),
  transvection := RcwaMapping(~.R,[[1,0],[0,1]],[[[[1,1],[1,0]],[0,0],1]]),

  hyperbolic := RcwaMapping(~.R,[[1,0],[0,2]],[[[[4,0],[0,1]],[0, 0],2],
                                               [[[4,0],[0,1]],[2,-1],2]]),

  T2 := RcwaMapping( ~.R, [[2,0],[0,2]],
                          [[[0,0],[[[1,0],[0,1]],[0,0],2]],
                            [[0,1],[[[1,0],[0,2]],[0,0],2]],
                            [[1,0],[[[2,0],[0,1]],[0,0],2]],
                            [[1,1],[[[2,1],[1,2]],[1,1],2]]] ),

  Sigma_T := RcwaMapping( ~.R, [[1,0],[0,6]],
                               [[[[2,0],[0,1]],[0,0],2],
                                [[[4,0],[0,3]],[2,1],2],
                                [[[2,0],[0,1]],[0,0],2],
                                [[[4,0],[0,3]],[2,1],2],
                                [[[4,0],[0,1]],[0,0],2],
                                [[[4,0],[0,3]],[2,1],2]] ),

  SigmaT := RcwaMapping( ~.R, [[1,0],[0,6]],
                              [[[0,0],[[[2,0],[0,1]],[0,0],2]],
                               [[0,1],[[[4,0],[0,3]],[0,1],2]],
                               [[0,2],[[[2,0],[0,1]],[0,0],2]],
                               [[0,3],[[[4,0],[0,3]],[0,1],2]],
                               [[0,4],[[[4,0],[0,1]],[2,0],2]],
                               [[0,5],[[[4,0],[0,3]],[0,1],2]]] ),

  SigmaTm := RcwaMapping( ~.R, [[1,0],[0,6]],
                               [[[0,0],[[[2,0],[0,1]],[0,0],2]],
                                [[0,1],[[[4,0],[0,3]],[0,-1],2]],
                                [[0,2],[[[4,0],[0,1]],[2,0],2]],
                                [[0,3],[[[4,0],[0,3]],[0,-1],2]],
                                [[0,4],[[[2,0],[0,1]],[0,0],2]],
                                [[0,5],[[[4,0],[0,3]],[0,-1],2]]] ),

  a := ~.hyperbolic, b := ~.a^-1*~.Sigma_T,

  commT_Tm := RcwaMapping( ~.R, [[4,0],[0,9]],
  [[[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[3,0],[0,1]],[3,1],3],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,1]],[0,-1],1],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[2,0],[0,1]],[2,-1],1],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,3]],[-1,1],1],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,3]],[-1,1],1],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,3]],[-1,1],1],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,2]],[-2,-2],2],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,1]],[0,-1],1],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[2,0],[0,1]],[2,-1],1],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,4]],[-3,0],4],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,4]],[-3,0],4],
   [[[1,0],[0,1]],[0,0],1],[[[4,0],[0,1]],[3,0],1],[[[1,0],[0,4]],[-3,0],4]])

);

#############################################################################
##
##  Rcwa mappings which seem to be contracting, but very slow.
##
RCWAExamples.SlowlyContractingMappings := rec(

  # The trajectory of 3224 under f6 has length 19949562.
  f6 := RcwaMapping([[1,0,6],[5,1,6],[7,-2,6],[11,3,6],[11,-2,6],[11,-1,6]]),

  # A mapping still having long, but less extreme trajectories:
  T7 := RcwaMapping([[1,0,6],[7,1,2],[1,0,2],[1,0,3],[1,0,2],[7,1,2]]),

  # Some other probably contracting mappings with divergence very close to 1.
  f5 := RcwaMapping([[7,0,5],[7,-2,5],[3,-1,5],[3,1,5],[7,2,5]]),
  f7 := RcwaMapping([[5,0,7],[9,-2,7],[9,3,7],
                             [5,-1,7],[5,1,7],
                             [9,-3,7],[9,2,7]]),
  f9 := RcwaMapping([[ 5, 0,9],[16, 2,9],[10,-2,9],
                     [11, 3,9],[ 5,-2,9],[ 5, 2,9],
                     [11,-3,9],[10, 2,9],[16,-2,9]]),

  # A probably very quickly contracting mapping -- proving this seems to be
  # difficult anyway ...
  f6q := RcwaMapping([[1,0,6],[1,1,2],[1,0,2],[1,0,3],[1,0,2],[7,1,6]])

);

SetName(RCWAExamples.SlowlyContractingMappings.f6,"f6");
SetName(RCWAExamples.SlowlyContractingMappings.T7,"T7");
SetName(RCWAExamples.SlowlyContractingMappings.f5,"f5");
SetName(RCWAExamples.SlowlyContractingMappings.f7,"f7");
SetName(RCWAExamples.SlowlyContractingMappings.f9,"f9");
SetName(RCWAExamples.SlowlyContractingMappings.f6q,"f6q");

#############################################################################
##
##  The Matthews-Leigh examples -- the trajectories of 1 resp. x^3+x+1 can be
##  shown to be divergent, and their iterates can be shown to be non-cyclic
##  (mod x).
##
RCWAExamples.MatthewsLeigh := rec(

  x := Indeterminate(GF(2),1),
  R := PolynomialRing(GF(2),1),

  ML1 := RcwaMapping(~.R,~.x,[[1,0,~.x],[(~.x+1)^3,1,~.x]]*One(~.R)),
  ML2 := RcwaMapping(~.R,~.x,[[1,0,~.x],[(~.x+1)^2,1,~.x]]*One(~.R)),

  ChangePoints := l -> Filtered([1..Length(l)-1],pos->l[pos]<>l[pos+1]),
  Diffs        := l -> List([1..Length(l)-1],pos->l[pos+1]-l[pos])

);

SetName(RCWAExamples.MatthewsLeigh.x,"x");
SetName(RCWAExamples.MatthewsLeigh.ML1,"ML1");
SetName(RCWAExamples.MatthewsLeigh.ML2,"ML2");

#############################################################################
##
##  The Hicks - Mullen - Yucas - Zavislak example.
##
##  In the article
##
##  Kenneth Hicks, Gary L. Mullen, Joseph L. Yucas, and Ryan Zavislak:
##  A Polynomial Analogue of the 3N + 1 Problem?
##  Amer. Math. Monthly 115 (2008), no. 7
##
##  it is shown that the mapping C given below is contracting.
##
RCWAExamples.HicksMullenYucasZavislak := rec(

  x := Indeterminate(GF(2),1),
  R := PolynomialRing(GF(2),1),

  C := RcwaMapping(~.R,~.x,[[1,0,~.x],[~.x+1,1,1]]*One(~.R))

);

#############################################################################
##
##  Some 'Collatz-like' permutations.
##
RCWAExamples.CollatzlikePerms := rec(

  Collatz := RcwaMapping([[2,0,3],[4,-1,3],[4,1,3]]),

  a := RcwaMapping([[2,0,3],[4,-1,3],[4,1,3]]), # available under two names
  u := RcwaMapping([[3,0,5],[9,1,5],[3,-1,5],[9,-2,5],[9,4,5]]),

  # The following mapping is wild, but all cycles of integers |n| < 29 are
  # finite. It has been constructed in a similar way as `u'.

  f5_12 := RcwaMapping([[5, 0,6],[5,3,4],[5,-4,6],[5,-3,4],
                        [5, 4,6],[5,3,4],[5, 0,6],[5,-3,4],
                        [5,-4,6],[5,3,4],[5, 4,6],[5,-3,4]]),

  # The following mapping has modulus 5 and multiplier 16 (this is the
  # largest possible multiplier of a mapping with this modulus).

  Mod5Mult16 := RcwaMapping([[16,0,5],[16,24,5],[8,4,5],[4,-2,5],[2,-3,5]])

);

SetName(RCWAExamples.CollatzlikePerms.Collatz,"Collatz");
SetName(RCWAExamples.CollatzlikePerms.a,"a");
SetName(RCWAExamples.CollatzlikePerms.u,"u");
SetName(RCWAExamples.CollatzlikePerms.f5_12,"f5_12");
SetName(RCWAExamples.CollatzlikePerms.Mod5Mult16,"Mod5Mult16");

#############################################################################
##
##  An rcwa mapping of GF(2)[x] of infinite order which has only finite
##  cycles.
##
x := Indeterminate(GF(2),1); SetName(x,"x"); e := One(GF(2));

RCWAExamples.GF2xFiniteCycles := rec(

  R := PolynomialRing(GF(2),1),
  x := x,
  e := x,
  zero := Zero(~.R),

  r_2mod := RcwaMapping( 2, x^2 + e,
                         [ [ x^2 + x + e, ~.zero , x^2 + e ],
                           [ x^2 + x + e, x      , x^2 + e ],
                           [ x^2 + x + e, x^2    , x^2 + e ],
                           [ x^2 + x + e, x^2 + x, x^2 + e ] ] )

);

SetName(RCWAExamples.GF2xFiniteCycles.r_2mod,"r_2mod");

#############################################################################
##
##  Quotients of Grigorchuk groups
##
##  The definition of a, b, c and d is omitted in order to avoid overwriting
##  the previous values of these variables.
##
RCWAExamples.GrigorchukQuotients := rec(

  SequenceElement := function ( r, level )

    return Permutation(Product(Filtered([1..level-1],k->k mod 3 <> r),
                               k->ClassTransposition(2^(k-1)-1, 2^(k+1),
                                                 2^k+2^(k-1)-1, 2^(k+1))),
                       [0..2^level-1]);
  end,

  FourCycle := RcwaMapping((4,5,6,7),[4..7]),

  GrigorchukGroup2Generator := function ( level )
    if level = 1 then return RCWAExamples.GrigorchukQuotients.FourCycle;
    else
      return   Restriction(RCWAExamples.GrigorchukQuotients.FourCycle,
                           RcwaMapping([[4,1,1]]))
             * Restriction(RCWAExamples.GrigorchukQuotients.FourCycle,
                           RcwaMapping([[4,3,1]]))
             * Restriction(RCWAExamples.GrigorchukQuotients.
                                        GrigorchukGroup2Generator(level-1),
                           RcwaMapping([[4,0,1]]));
    fi;
  end,

  GrigorchukGroup2 :=
    level -> Group(RCWAExamples.GrigorchukQuotients.FourCycle,
                   RCWAExamples.GrigorchukQuotients.
                                GrigorchukGroup2Generator(level))

);

#############################################################################
##
##  Representations of the free group of rank 2 and of PSL(2,Z).
##
RCWAExamples.F2_PSL2Z := rec(

  r1 := ClassTransposition(0,2,1,2) * ClassTransposition(0,2,1,4),
  r2 := ClassTransposition(0,2,1,2) * ClassTransposition(0,2,3,4),

  F2 := Group(~.r1^2,~.r2^2),

  PSL2Z := Group(ClassTransposition(0,3,1,3) * ClassTransposition(0,3,2,3),
                 ClassTransposition(1,3,0,6) * ClassTransposition(2,3,3,6))

);

SetName(RCWAExamples.F2_PSL2Z.r1,"r1");
SetName(RCWAExamples.F2_PSL2Z.r2,"r2");
SetName(RCWAExamples.F2_PSL2Z.F2,"F_2");
SetName(RCWAExamples.F2_PSL2Z.PSL2Z,"PSL(2,Z)");

#############################################################################
##
##  It seems that the group defined below has the following infinite
##  presentation:
##
##  G = < a,b | [a^(2k+1),b^l]^(4^l) = 1, k,l in N_0 >
##
RCWAExamples.MaybeInfinitelyPresentedGroup := rec(
  G := Group(ClassShift(0,2),
             ClassTransposition(0,2,1,2) * ClassTransposition(3,4,5,8)
           * ClassTransposition(0,2,1,8)));

SetName(RCWAExamples.MaybeInfinitelyPresentedGroup.G.1,"a");
SetName(RCWAExamples.MaybeInfinitelyPresentedGroup.G.2,"b");

#############################################################################
##
##  A permutation with cycle lengths 12 + 6k, k in N_0
##
##  The name reflects the shape of the transition graph.
##
RCWAExamples.Hexagon := rec(

  Hexagon := RcwaMapping(
               [ [ 1,  0, 1 ], [ 1,  0, 1 ], [ 3,  -2, 2 ], [ 2,  3, 3 ],
                 [ 1,  0, 1 ], [ 2,  5, 3 ], [ 3,  -6, 2 ], [ 2,  7, 3 ],
                 [ 1,  0, 1 ], [ 1,  0, 1 ], [ 3, -10, 2 ], [ 1,  0, 1 ],
                 [ 1,  0, 1 ], [ 1,  0, 1 ], [ 3,  -2, 2 ], [ 1,  7, 1 ],
                 [ 1,  0, 1 ], [ 1, -3, 1 ], [ 3,  -6, 2 ], [ 1, -1, 1 ],
                 [ 1,  1, 1 ], [ 2,  3, 3 ], [ 3, -10, 2 ], [ 2,  5, 3 ],
                 [ 1, -1, 1 ], [ 2,  7, 3 ], [ 3,  -2, 2 ], [ 1,  7, 1 ],
                 [ 1, -3, 1 ], [ 1, -3, 1 ], [ 3,  -6, 2 ], [ 1, -1, 1 ],
                 [ 1,  0, 1 ], [ 1,  0, 1 ], [ 3, -10, 2 ], [ 1,  0, 1 ] ] ),

  HexagonFacts := Factorization(~.Hexagon),

  Hexagon1 := Product(~.HexagonFacts{[1..13]}), # an integral perm., order 4
  Hexagon2 := Product(~.HexagonFacts{[14..22]}) # an involution

);

SetName(RCWAExamples.Hexagon.Hexagon,"Hexagon");

#############################################################################
##
##  A permutation with finite cycles of various lengths,
##  and likely also infinite cycles
##
##  The name again reflects the shape of the transition graph. Cycle lengths
##  are e.g. 12, 14, 15, 18, 21, 30, 36, 42, 48. Constructing the permutation
##  needs a couple of seconds, thus the code is wrapped into a function to
##  avoid it being executed at any time this file is read into GAP.
##
RCWAExamples.Hexagon.Hexagon235 := function ( )

  local  edges, classes, source, range, fixed;

  edges :=
    [[1,60,1,90],[2,90,2,60],[3,20,3,50],[4,50,4,20],[5,45,5,75],[6,75,6,45],
     [91,720,23,100],[271,720,43,100],[451,720,63,100],[631,720,83,100],
     [53,200,81,225],[153,200,156,225],
     [51,225,92,720],[96,225,272,720],[141,225,452,720],[186,225,632,720],
     [62,180,54,200],[122,180,154,200],
     [24,100,50,225],[44,100,95,225],[64,100,140,225],[84,100,185,225],
     [80,225,61,180],[155,225,121,180]];

  classes := List(edges,edge->[ResidueClass(edge[1],edge[2]),
                               ResidueClass(edge[3],edge[4])]);

  source := List(classes,cls->cls[1]);
  range  := List(classes,cls->cls[2]);

  fixed  := Difference(Integers,Union(source));

  Append(source,AsUnionOfFewClasses(fixed));
  Append(range, AsUnionOfFewClasses(fixed));

  return RepresentativeAction(RCWA(Integers),source,range);

end;

#############################################################################
##
##  A group which has any symmetric group of odd degree as a quotient
##
RCWAExamples.FiniteQuotients := rec(

  SmOdd := Group( ClassTransposition(0,4,3,4),
                  ClassTransposition(0,6,3,6),
                  ClassTransposition(1,4,0,6) )

);

#############################################################################
##
##  Examples of pairs of class transpositions whose product has order 2, 3,
##  4, 6, 10, 12, 15, 20, 30, 60 or infinity, respectively. These numbers are
##  perhaps the only possible orders of a product of two class transpositions
##  of the integers. The example with order infinity is at position 1 in the
##  list. The moduli of the involved residue classes are kept as small as
##  possible.
##
if   not IsBound( RCWAExamples.ClassTranspositionProducts )
then RCWAExamples.ClassTranspositionProducts := rec( ); fi;

RCWAExamples.ClassTranspositionProducts.
PairsOfCTsWhoseProductHasGivenOrder :=
  [ [ ClassTransposition(1,2,2,4), ClassTransposition(2,4,3,4) ],
    [ ClassTransposition(0,4,1,4), ClassTransposition(2,4,3,4) ],
    [ ClassTransposition(0,3,1,3), ClassTransposition(0,3,2,3) ],
    [ ClassTransposition(0,2,1,2), ClassTransposition(0,3,1,3) ],,
    [ ClassTransposition(0,2,1,2), ClassTransposition(0,3,2,3) ],,,,
    [ ClassTransposition(1,2,2,4), ClassTransposition(0,3,4,6) ],,
    [ ClassTransposition(1,3,2,3), ClassTransposition(0,4,2,4) ],,,
    [ ClassTransposition(0,3,2,3), ClassTransposition(0,2,3,4) ],,,,,
    [ ClassTransposition(0,4,2,4), ClassTransposition(2,3,4,6) ],,,,,,,,,,
    [ ClassTransposition(1,3,2,3), ClassTransposition(1,2,0,4) ],,,,,,,,,,
    ,,,,,,,,,,,,,,,,,,,,
    [ ClassTransposition(2,5,3,5), ClassTransposition(1,3,5,6) ] ];

#############################################################################
##
##  Examples of pairs of class transpositions whose product has given
##  cycle type. Each entry of the list is a list of length 4, where the
##  entries are the intersection type, the order, the cycle type and the
##  pair of class transpositions itself, in the given order. A detailed
##  description of the entries can be found in the file ctprodclass.g,
##  which contains a list of all pairs of class transpositions interchanging
##  residue classes with moduli <= 6, which belong to the respective classes.
##  The list given here contains only certain 'nicest' representatives of
##  these classes. It is generated from the list `CTProductClassification'
##  in ctprodclass.g by the function `NicestCTProducts' given below.
##
RCWAExamples.ClassTranspositionProducts.
NicestPairsOfCTsWhoseProductHasGivenCycleType :=
[ [ [ 0, 3, 3, 1 ], infinity, [ [ infinity ], 2 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,2,1,4) ] ],
  [ [ 0, 3, 3, 1 ], infinity, [ [ 1, infinity ], 2 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,4,1,4) ] ],
  [ [ 0, 3, 3, 1 ], infinity, [ [ infinity ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,2,3,6) ] ],
  [ [ 0, 3, 3, 1 ], infinity, [ [ 1, infinity ], 0 ],
      [ ClassTransposition(1,2,0,4), ClassTransposition(0,4,3,6) ] ],
  [ [ 0, 3, 3, 3 ], 3, [ [ 3 ], 0 ],
      [ ClassTransposition(0,3,1,3), ClassTransposition(0,3,2,3) ] ],
  [ [ 0, 3, 3, 3 ], 3, [ [ 1, 3 ], 0 ],
      [ ClassTransposition(0,4,1,4), ClassTransposition(0,4,2,4) ] ],
  [ [ 0, 3, 3, 4 ], infinity, [ ResidueClass(1,2), 2 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,2,1,6) ] ],
  [ [ 1, 1, 3, 3 ], 4, [ [ 4 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,4,2,4) ] ],
  [ [ 1, 1, 3, 3 ], 4, [ [ 2, 4 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,6,2,6) ] ],
  [ [ 1, 1, 3, 3 ], 4, [ [ 1, 4 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,4,2,4) ] ],
  [ [ 1, 1, 3, 3 ], 4, [ [ 1, 2, 4 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,6,2,6) ] ],
  [ [ 1, 3, 3, 1 ], 2, [ [ 1, 2 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,4,1,4) ] ],
  [ [ 1, 3, 3, 1 ], 4, [ [ 4 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,4,3,4) ] ],
  [ [ 1, 3, 3, 1 ], 4, [ [ 2, 4 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,6,3,6) ] ],
  [ [ 1, 3, 3, 1 ], 4, [ [ 1, 4 ], 0 ],
      [ ClassTransposition(0,3,1,3), ClassTransposition(0,6,4,6) ] ],
  [ [ 1, 3, 3, 1 ], infinity, [ ResidueClass(0,2), 2 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,4,1,6) ] ],
  [ [ 1, 3, 3, 2 ], infinity, [ [ infinity ], 2 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(1,2,0,4) ] ],
  [ [ 1, 3, 3, 2 ], infinity, [ [ 1, infinity ], 2 ],
      [ ClassTransposition(0,3,1,6), ClassTransposition(1,3,0,6) ] ],
  [ [ 1, 3, 3, 2 ], infinity, [ [ infinity ], 0 ],
      [ ClassTransposition(0,2,3,4), ClassTransposition(1,2,0,4) ] ],
  [ [ 1, 3, 3, 2 ], infinity, [ [ 1, infinity ], 0 ],
      [ ClassTransposition(0,3,4,6), ClassTransposition(1,3,0,6) ] ],
  [ [ 1, 3, 3, 3 ], 6, [ [ 2, 3 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,4,3,4) ] ],
  [ [ 1, 3, 3, 3 ], 6, [ [ 1, 2, 3 ], 0 ],
      [ ClassTransposition(0,3,1,6), ClassTransposition(2,3,0,6) ] ],
  [ [ 1, 3, 3, 4 ], 12, [ [ 1, 2, 3, 4 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,6,3,6) ] ],
  [ [ 1, 3, 3, 4 ], 12, [ [ 1, 3, 4 ], 0 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(0,4,3,4) ] ],
  [ [ 1, 3, 3, 4 ], infinity, [ PositiveIntegers, 2 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,4,1,6) ] ],
  [ [ 1, 3, 3, 4 ], infinity, [ [ 1, 2, infinity ], 2 ],
      [ ClassTransposition(1,2,0,6), ClassTransposition(0,4,1,4) ] ],
  [ [ 1, 3, 3, 4 ], infinity, [ PositiveIntegers, 0 ],
      [ ClassTransposition(0,2,3,6), ClassTransposition(1,4,0,6) ] ],
  [ [ 1, 3, 3, 4 ], infinity, [ [ 1, 2, infinity ], 0 ],
      [ ClassTransposition(0,2,5,6), ClassTransposition(0,4,1,4) ] ],
  [ [ 1, 4, 3, 2 ], infinity, [ [ 1, infinity ], 2 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(1,3,0,6) ] ],
  [ [ 1, 4, 3, 2 ], infinity, [ [ 1, infinity ], 0 ],
      [ ClassTransposition(1,2,0,6), ClassTransposition(0,3,5,6) ] ],
  [ [ 1, 4, 3, 3 ], 12, [ [ 1, 2, 3, 4 ], 0 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(0,3,2,6) ] ],
  [ [ 1, 4, 3, 3 ], 12, [ [ 1, 3, 4 ], 0 ],
      [ ClassTransposition(1,2,0,6), ClassTransposition(0,3,2,6) ] ],
  [ [ 1, 4, 3, 4 ], 4, [ [ 4 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(2,3,0,6) ] ],
  [ [ 1, 4, 3, 4 ], 6, [ [ 1, 2, 3, 6 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(2,3,0,6) ] ],
  [ [ 1, 4, 3, 4 ], 6, [ [ 1, 3, 6 ], 0 ],
      [ ClassTransposition(1,2,0,6), ClassTransposition(0,3,2,3) ] ],
  [ [ 1, 4, 3, 4 ], 12, [ [ 1, 3, 4 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,3,2,6) ] ],
  [ [ 1, 4, 3, 4 ], 12, [ [ 1, 3, 4, 6 ], 0 ],
      [ ClassTransposition(0,3,1,6), ClassTransposition(3,4,0,6) ] ],
  [ [ 1, 4, 3, 4 ], infinity, [ [ 2, infinity ], 2 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,3,1,6) ] ],
  [ [ 1, 4, 3, 4 ], infinity, [ [ 1, 2, infinity ], 2 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(1,3,0,6) ] ],
  [ [ 1, 4, 3, 4 ], infinity, [ [ 1, 2, infinity ], 0 ],
      [ ClassTransposition(1,2,0,4), ClassTransposition(1,3,3,6) ] ],
  [ [ 1, 4, 3, 4 ], infinity, [ [ 1, infinity ], 2 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(0,3,1,3) ] ],
  [ [ 1, 4, 3, 4 ], infinity, [ [ 1, infinity ], 0 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(1,3,2,3) ] ],
  [ [ 1, 4, 3, 4 ], infinity, [ PositiveIntegers, 2 ],
      [ ClassTransposition(0,3,1,3), ClassTransposition(0,4,1,6) ] ],
  [ [ 3, 3, 3, 3 ], 2, [ [ 2 ], 0 ],
      [ ClassTransposition(0,4,2,4), ClassTransposition(1,4,3,4) ] ],
  [ [ 3, 3, 3, 3 ], 2, [ [ 1, 2 ], 0 ],
      [ ClassTransposition(0,5,1,5), ClassTransposition(2,5,3,5) ] ],
  [ [ 3, 3, 3, 4 ], 6, [ [ 2, 3 ], 0 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(0,3,5,6) ] ],
  [ [ 3, 3, 3, 4 ], 6, [ [ 1, 2, 3 ], 0 ],
      [ ClassTransposition(0,4,3,4), ClassTransposition(1,4,0,6) ] ],
  [ [ 3, 3, 4, 4 ], 4, [ [ 1, 2, 4 ], 0 ],
      [ ClassTransposition(1,2,0,4), ClassTransposition(0,6,4,6) ] ],
  [ [ 3, 3, 4, 4 ], 4, [ [ 2, 4 ], 0 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(0,3,2,3) ] ],
  [ [ 3, 3, 4, 4 ], 6, [ [ 1, 2, 3 ], 0 ],
      [ ClassTransposition(0,3,2,3), ClassTransposition(0,4,1,6) ] ],
  [ [ 3, 3, 4, 4 ], 6, [ [ 2, 3 ], 0 ],
      [ ClassTransposition(0,2,5,6), ClassTransposition(0,3,1,3) ] ],
  [ [ 3, 3, 4, 4 ], 12, [ [ 1, 2, 3, 4 ], 0 ],
      [ ClassTransposition(2,3,0,6), ClassTransposition(0,4,1,6) ] ],
  [ [ 3, 4, 4, 3 ], 2, [ [ 1, 2 ], 0 ],
      [ ClassTransposition(0,4,1,4), ClassTransposition(0,6,1,6) ] ],
  [ [ 3, 4, 4, 3 ], 4, [ [ 1, 2, 4 ], 0 ],
      [ ClassTransposition(0,4,1,4), ClassTransposition(0,6,5,6) ] ],
  [ [ 3, 4, 4, 3 ], 6, [ [ 1, 2, 3 ], 0 ],
      [ ClassTransposition(0,4,1,4), ClassTransposition(0,6,3,6) ] ],
  [ [ 3, 4, 4, 3 ], infinity, [ PositiveIntegers, 2 ],
      [ ClassTransposition(0,4,1,6), ClassTransposition(1,4,0,6) ] ],
  [ [ 3, 4, 4, 3 ], infinity, [ PositiveIntegers, 0 ],
      [ ClassTransposition(0,4,3,6), ClassTransposition(1,4,0,6) ] ],
  [ [ 3, 4, 4, 4 ], 6, [ [ 1, 2, 3 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,3,1,6) ] ],
  [ [ 3, 4, 4, 4 ], 10, [ [ 1, 2, 5 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(2,3,1,6) ] ],
  [ [ 3, 4, 4, 4 ], 12, [ [ 1, 2, 3, 4 ], 0 ],
      [ ClassTransposition(1,2,0,4), ClassTransposition(0,3,2,6) ] ],
  [ [ 3, 4, 4, 4 ], 12, [ [ 1, 3, 4 ], 0 ],
      [ ClassTransposition(1,2,0,4), ClassTransposition(1,3,2,6) ] ],
  [ [ 3, 4, 4, 4 ], 20, [ [ 1, 2, 4, 5 ], 0 ],
      [ ClassTransposition(1,2,0,4), ClassTransposition(0,3,4,6) ] ],
  [ [ 3, 4, 4, 4 ], 30, [ [ 1, 2, 3, 5 ], 0 ],
      [ ClassTransposition(1,2,0,4), ClassTransposition(2,3,0,6) ] ],
  [ [ 3, 4, 4, 4 ], infinity, [ [ 1, 2, 3, infinity ], 2 ],
      [ ClassTransposition(0,3,1,6), ClassTransposition(0,4,1,4) ] ],
  [ [ 4, 4, 4, 4 ], 4, [ [ 1, 4 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,3,1,3) ] ],
  [ [ 4, 4, 4, 4 ], 4, [ [ 1, 2, 4 ], 0 ],
      [ ClassTransposition(0,3,2,3), ClassTransposition(0,4,2,4) ] ],
  [ [ 4, 4, 4, 4 ], 4, [ [ 2, 4 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,5,2,5) ] ],
  [ [ 4, 4, 4, 4 ], 6, [ [ 6 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,3,2,3) ] ],
  [ [ 4, 4, 4, 4 ], 6, [ [ 2, 6 ], 0 ],
      [ ClassTransposition(0,2,1,2), ClassTransposition(0,5,4,5) ] ],
  [ [ 4, 4, 4, 4 ], 6, [ [ 1, 2, 6 ], 0 ],
      [ ClassTransposition(0,3,1,3), ClassTransposition(0,4,3,4) ] ],
  [ [ 4, 4, 4, 4 ], 6, [ [ 1, 2, 3 ], 0 ],
      [ ClassTransposition(0,3,1,3), ClassTransposition(0,4,1,4) ] ],
  [ [ 4, 4, 4, 4 ], 6, [ [ 1, 6 ], 0 ],
      [ ClassTransposition(0,4,2,4), ClassTransposition(0,6,4,6) ] ],
  [ [ 4, 4, 4, 4 ], 12, [ [ 1, 2, 3, 4 ], 0 ],
      [ ClassTransposition(0,3,2,3), ClassTransposition(0,5,1,5) ] ],
  [ [ 4, 4, 4, 4 ], 12, [ [ 1, 3, 4 ], 0 ],
      [ ClassTransposition(0,3,1,3), ClassTransposition(0,4,2,4) ] ],
  [ [ 4, 4, 4, 4 ], 15, [ [ 1, 3, 5 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,3,2,3) ] ],
  [ [ 4, 4, 4, 4 ], 20, [ [ 1, 4, 5 ], 0 ],
      [ ClassTransposition(0,3,1,6), ClassTransposition(1,4,3,4) ] ],
  [ [ 4, 4, 4, 4 ], 30, [ [ 1, 3, 5, 6 ], 0 ],
      [ ClassTransposition(0,2,3,4), ClassTransposition(0,3,1,3) ] ],
  [ [ 4, 4, 4, 4 ], 30, [ [ 1, 2, 3, 5 ], 0 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,5,2,5) ] ],
  [ [ 4, 4, 4, 4 ], 30, [ [ 1, 2, 3, 5, 6 ], 0 ],
      [ ClassTransposition(1,2,2,4), ClassTransposition(0,5,1,5) ] ],
  [ [ 4, 4, 4, 4 ], 60, [ [ 1, 2, 3, 4, 5 ], 0 ],
      [ ClassTransposition(0,3,5,6), ClassTransposition(0,5,2,5) ] ],
  [ [ 4, 4, 4, 4 ], 60, [ [ 1, 2, 3, 4, 5, 6 ], 0 ],
      [ ClassTransposition(0,4,1,6), ClassTransposition(0,5,3,5) ] ],
  [ [ 4, 4, 4, 4 ], infinity, [ [ 1, 2, infinity ], 4 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,3,1,3) ] ],
  [ [ 4, 4, 4, 4 ], infinity, [ [ 1, 2, 3, 4, infinity ], 2 ],
      [ ClassTransposition(0,2,1,4), ClassTransposition(0,5,1,5) ] ],
  [ [ 4, 4, 4, 4 ], infinity, [ [ 1, 2, 3, 4, infinity ], 0 ],
      [ ClassTransposition(0,2,1,6), ClassTransposition(1,5,4,5) ] ],
  [ [ 4, 4, 4, 4 ], infinity, [ [ 1, 2, 3, infinity ], 2 ],
      [ ClassTransposition(0,3,1,6), ClassTransposition(0,5,1,5) ] ],
  [ [ 4, 4, 4, 4 ], infinity, [ [ 1, 3, infinity ], 2 ],
      [ ClassTransposition(1,3,0,6), ClassTransposition(0,4,2,4) ] ],
  [ [ 4, 4, 4, 4 ], infinity, [ Union( ResidueClass(0,2), [ 1 ] ), 4 ],
      [ ClassTransposition(0,4,1,6), ClassTransposition(0,5,1,5) ] ] ];

RCWAExamples.ClassTranspositionProducts.NicestCTProducts := 

function ( CTProductClassification )

  local  l, examples, entry, pairs, i, j, k;

  l := CTProductClassification; examples := [];
  for i in [1..Length(l)] do
    for j in [2..Length(l[i])] do
      for k in [2..Length(l[i][j])] do
        pairs := l[i][j][k]{[2..Length(l[i][j][k])]};
        entry := [l[i][1],l[i][j][1],l[i][j][k][1]];
        Sort(pairs,
             function ( p1, p2 )

               local  cl1, r1, m1, cl2, r2, m2;

               cl1 := Concatenation(List(p1,TransposedClasses));
               cl2 := Concatenation(List(p2,TransposedClasses));
               m1 := Reversed(AsSortedList(List(cl1,Modulus)));
               m2 := Reversed(AsSortedList(List(cl2,Modulus)));
               r1 := AsSortedList(List(cl1,Residue));
               r2 := AsSortedList(List(cl2,Residue));
               return [m1,r1] < [m2,r2];
             end );
        Add(entry,pairs[1]);
        Add(examples,entry);
      od;
    od;
  od;
  return examples;
end;

#############################################################################
##
##  The ``Class Transposition Graph''
##
##  The vertices of the `Class Transposition Graph' are the class transposi-
##  tions. Two vertices are connected by an edge if their product is tame.
##
##  Below, examples of embeddings of all 11 graphs with 4 vertices into this
##  graph are listed. The function `CheckGraphEmbeddings' can be used to
##  check this data. If it detects an error, it raises an error message and
##  enters a break loop.
##
RCWAExamples.ClassTranspositionProducts.Embeddings4 := [
  [ [  ],
    [ ClassTransposition(0,2,1,2), ClassTransposition(0,2,1,4),
      ClassTransposition(0,2,1,6), ClassTransposition(0,2,1,8) ] ],
  [ [ [ 1, 2 ] ],
    [ ClassTransposition(0,4,1,4), ClassTransposition(2,4,3,4),
      ClassTransposition(0,2,1,6), ClassTransposition(0,2,1,10) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ] ],
    [ ClassTransposition(1,4,4,6), ClassTransposition(1,2,0,6),
      ClassTransposition(3,4,0,6), ClassTransposition(0,2,1,2) ] ],
  [ [ [ 1, 2 ], [ 3, 4 ] ],
    [ ClassTransposition(1,2,0,6), ClassTransposition(3,4,2,6),
      ClassTransposition(0,2,3,6), ClassTransposition(2,4,5,6) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ] ],
    [ ClassTransposition(1,3,0,6), ClassTransposition(1,3,2,3),
      ClassTransposition(3,4,2,6), ClassTransposition(2,4,1,6) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ], [ 2, 3 ] ],
    [ ClassTransposition(1,3,2,3), ClassTransposition(1,6,2,6),
      ClassTransposition(0,4,3,6), ClassTransposition(0,2,3,4) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ], [ 2, 4 ] ],
    [ ClassTransposition(1,6,4,6), ClassTransposition(0,4,3,6),
      ClassTransposition(1,2,2,6), ClassTransposition(2,4,1,6) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ] ],
    [ ClassTransposition(3,6,4,6), ClassTransposition(0,3,2,6),
      ClassTransposition(1,3,2,6), ClassTransposition(1,5,2,5) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ], [ 2, 4 ], [ 3, 4 ] ],
    [ ClassTransposition(2,4,3,4), ClassTransposition(0,4,2,4),
      ClassTransposition(1,3,0,6), ClassTransposition(1,3,5,6) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ] ],
    [ ClassTransposition(3,6,4,6), ClassTransposition(1,5,3,5),
      ClassTransposition(0,2,1,2), ClassTransposition(1,2,2,6) ] ],
  [ [ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 2, 3 ], [ 2, 4 ], [ 3, 4 ] ],
    [ ClassTransposition(0,3,2,3), ClassTransposition(0,4,3,4),
      ClassTransposition(3,6,4,6), ClassTransposition(2,6,5,6) ] ] ];

RCWAExamples.ClassTranspositionProducts.CheckGraphEmbeddings := 

function ( embeddingslist )
  
  local  i, pairs, deg;

  deg   := Maximum(Filtered(Flat(embeddingslist),IsInt));
  pairs := Combinations([1..deg],2);
  for i in [1..Length(embeddingslist)] do
    if   Filtered(pairs,pair->IsTame(Product(embeddingslist[i][2]{pair})))
      <> embeddingslist[i][1]
    then Error("graph embeddings list is wrong!!!\n"); fi;
  od;
  return true;
end;

#############################################################################
##
##  The Venturini examples.
##
##  The examples V0 - V8 below are taken from
##
##  G. Venturini. Iterates of number-theoretic functions with periodic
##  rational coefficients (generalization of the 3x+1 problem).
##  Stud. Appl. Math., 86(3):185--218, 1992.
##
RCWAExamples.Venturini := rec(

  V0 := RcwaMapping([[2,0,3],[4,5,3],[4,-5,3]]), # The residue class 0(5)
                                                 # is an ergodic set of V0.

  V1 := function ( t )

          local map;

          map := RcwaMapping([[2500,6     ,6],[t,  -t+4,2],[1,16,6],
                              [t   ,-3*t+4,2],[t,-4*t+4,2],[1,13,6]]);
          SetName(map,Concatenation("V1(",String(t),")"));
          return map;
        end,

  V2 := function ( k, p, t )

          local  map, c, r;

          if not IsSubset(PositiveIntegers,[k,p,t])
            or t < 1 or t >= p or Gcd(p,t) <> 1 then return fail;
          fi;
          c := [[p^(k-1),1,1]];
          for r in [1..p-1] do c[r+1] := [t,r*(p-t),p]; od;
          map := RcwaMapping(c);
          SetName(map,Concatenation("V2(",String(k),",",String(p),",",
                                          String(t),")"));
          return map;
        end,

  V3 := function ( t )

          local map;

          map := RcwaMapping([[ 1, 0,4],[1,  1,2],[20,    -40,1],[1,-3,8],
                              [20,48,1],[3,-13,2],[ t,-6*t+64,4],[1, 1,8]]);
          SetName(map,Concatenation("V3(",String(t),")"));
          return map;
        end,

  V4 := RcwaMapping([[9, 1,1],[  1,  32,3],[1,-2,3],
                     [1, 3,1],[100,-364,9],[1,-5,3],
                     [1,-6,1],[100,-637,9],[1,-8,3]]),

  V5 := RcwaMapping([[1,0,6],[2,16,3],[3,11,1],[1,-3,6],[1,-4,1],[1,9,2]]),

  V6 := RcwaMapping([[1,4,2],[1,3,2],[1,2,2],[1,1,2],[1,0,2],[5,-17,2],
                     [5,-22,2],[17,-39,10],[17,-56,10],[17,-73,10]]),

  V7 := RcwaMapping([[1,0,3],[2,-2,3],[5,-4,3],[4,0,3],[5,-8,3],[4,-2,3]]),

  V8 := RcwaMapping([[1,0,3],[1,-1,3],[5,5,3],[3,5,2],[3,2,2],[3,-1,2]])

);

SetName(RCWAExamples.Venturini.V0,"V0");
SetName(RCWAExamples.Venturini.V4,"V4");
SetName(RCWAExamples.Venturini.V5,"V5");
SetName(RCWAExamples.Venturini.V6,"V6");
SetName(RCWAExamples.Venturini.V7,"V7");
SetName(RCWAExamples.Venturini.V8,"V8");

#############################################################################
##
##  An example by H. M. Farkas.
##
##  The following mapping has no divergent trajectories, but trajectories
##  which ascend any given number of consecutive steps. Proof: elementary.
##
RCWAExamples.Farkas := rec(

  Farkas := RcwaMapping([[1,0,3],[1,1,2],[1,0,1],[1,0,3],
                         [1,0,1],[1,1,2],[1,0,3],[3,1,2],
                         [1,0,1],[1,0,3],[1,0,1],[3,1,2]])

);

SetName(RCWAExamples.Farkas.Farkas,"Farkas");

#############################################################################
##
##  The mappings defined in the preprint ``Symmetrizing the 3n+1 Tree''.
##
RCWAExamples.SymmetrizingCollatzTree := rec(

  l := RcwaMapping([[1,0,1],[1,0,1],[ 4,0,1],
                    [1,0,1],[1,0,1],[ 1,0,1],
                    [1,0,1],[1,0,1],[16,0,1]]),

  r := RcwaMapping([[1,0,1],[1,0,1],[ 4,-2,3],
                    [1,0,1],[1,0,1],[ 1, 0,1],
                    [1,0,1],[1,0,1],[ 8,-4,3],
                    [1,0,1],[1,0,1],[16,-8,3],
                    [1,0,1],[1,0,1],[ 1, 0,1],
                    [1,0,1],[1,0,1],[ 2,-1,3],
                    [1,0,1],[1,0,1],[ 4,-2,3],
                    [1,0,1],[1,0,1],[ 1, 0,1],
                    [1,0,1],[1,0,1],[ 2,-1,3]]),

  d := RcwaMapping([[1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,4],[1,0,1],[1,0,1],[3,1,2],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [3,4,8],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[3,1,2],
                    [1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,4],[1,0,1],[1,0,1],[3,1,2],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [3,8,16],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[3,1,2],
                    [1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,4],[1,0,1],[1,0,1],[3,1,2],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [3,4,8],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[3,1,2],
                    [1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,4],[1,0,1],[1,0,1],[3,1,2],
                    [1,0,1],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [1,0,16],[1,0,1],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[3,2,4],[1,0,1],
                    [1,0,1],[3,1,2],[1,0,1],[1,0,1],
                    [1,0,1],[1,0,1],[1,0,1],[3,1,2]]),

  f := RcwaMapping([[2,0,1]])
     * RepresentativeAction(RCWA(Integers),
                            ResidueClass(0,2),MovedPoints(~.l)),

  finv := RcwaMapping([[1,0,1],[1,0,1],[2,-4,9],
                       [1,0,1],[1,0,1],[1, 0,1],
                       [1,0,1],[1,0,1],[2,-7,9]]),

  L := ~.f*~.l*~.finv,
  R := ~.f*~.r*~.finv,
  D := ~.f*~.d*~.finv,

  # The function `LRWord' is a bijection from the positive integers
  # to the free monoid F if and only if the 3n+1 Conjecture holds.

  F := FreeMonoid("L","R"),

  LRWord := function ( n )

    local  l, imL, imR, w, i;

    if not IsPosInt(n) then return fail; fi;
    if n = 1 then return One(RCWAExamples.SymmetrizingCollatzTree.F); fi;
    imL := Image(RCWAExamples.SymmetrizingCollatzTree.L);
    imR := Image(RCWAExamples.SymmetrizingCollatzTree.R);
    l := Trajectory(RCWAExamples.SymmetrizingCollatzTree.D,n,[1]);
    w := [];
    for i in [Length(l)-1,Length(l)-2..1] do
      if   l[i] in imL
      then Add(w,RCWAExamples.SymmetrizingCollatzTree.F.1);
      else Add(w,RCWAExamples.SymmetrizingCollatzTree.F.2); fi;
    od;
    return Product(w);
  end,

  # The mapping `TreeSortingPerm' is a permutation of the positive integers
  # if and only if the 3n+1 Conjecture holds.

  TreeSortingPerm := MappingByFunction( PositiveIntegers, PositiveIntegers,

  function ( n ) # The conjectured permutation ...

    local  l, imL, imR, m, i;

    if not IsPosInt(n) then return fail; fi;
    if n = 1 then return 1; fi;
    imL := Image(RCWAExamples.SymmetrizingCollatzTree.L);
    imR := Image(RCWAExamples.SymmetrizingCollatzTree.R);
    l := Trajectory(RCWAExamples.SymmetrizingCollatzTree.D,n,[1]);
    m := 1;
    for i in [Length(l)-1,Length(l)-2..1] do
      if l[i] in imL then m := 2*m; else m := 2*m+1; fi;
    od;
    return m;
  end,

  function ( n ) # ... and its inverse.

    local  l, m, i;

    if not IsPosInt(n) then return fail; fi;
    if n = 1 then return 1; fi;
    l := Reversed(CoefficientsQadic(n,2));
    m := 1;
    for i in [2..Length(l)] do
      if l[i] = 0 then m := m^RCWAExamples.SymmetrizingCollatzTree.L; 
                  else m := m^RCWAExamples.SymmetrizingCollatzTree.R; fi;
    od;
    return m;
  end ),

  # Other pairs of mappings like (L,R).

  L2 := RcwaMapping([[3,0,1]]),
  R2 := RcwaMapping([[3,1,1],[3,5,2],[3,1,1],[3,-1,4]]),
  D2 := CommonRightInverse(~.L2,~.R2),

  L3 := RcwaMapping([[3,0,1]]),
  R3 := RcwaMapping(List([[0, 2],[ 3, 4],[ 1,20],[5,20],
                          [9,20],[13,20],[17,20]],ResidueClass),
                    List([[ 1, 6],[ 2, 3],[ 4,12],[10,48],
                          [22,48],[34,48],[46,48]],ResidueClass)),
  D3 := CommonRightInverse(~.L3,~.R3),


  L4 := 8 * IdentityRcwaMappingOfZ,
  R4 := RcwaMapping([[8,5,5],[8,12,5],[8,9,5],[4,-2,5],[4,-1,5]]),
  D4 := CommonRightInverse(~.L4,~.R4),

  # A pair (L,R) which spans a tree which definitely has not all positive
  # integers as vertices.

  L5 := RcwaMapping(List([[0, 2],[1,4],[3, 8],[7,8]],ResidueClass),
                    List([[0,16],[4,8],[8,16],[2,4]],ResidueClass)),
  R5 := RcwaMapping(List([[0,2],[1, 4],[ 3, 8],[7,8]],ResidueClass),
                    List([[1,8],[5,16],[13,16],[3,4]],ResidueClass)),
  D5 := CommonRightInverse(~.L5,~.R5)

);

SetName(RCWAExamples.SymmetrizingCollatzTree.l,"l");
SetName(RCWAExamples.SymmetrizingCollatzTree.r,"r");
SetName(RCWAExamples.SymmetrizingCollatzTree.d,"d");

SetName(RCWAExamples.SymmetrizingCollatzTree.f,"f");
SetName(RCWAExamples.SymmetrizingCollatzTree.finv,"finv");

SetName(RCWAExamples.SymmetrizingCollatzTree.L,"L");
SetName(RCWAExamples.SymmetrizingCollatzTree.R,"R");
SetName(RCWAExamples.SymmetrizingCollatzTree.D,"D");

SetName(RCWAExamples.SymmetrizingCollatzTree.L2,"L2");
SetName(RCWAExamples.SymmetrizingCollatzTree.R2,"R2");
SetName(RCWAExamples.SymmetrizingCollatzTree.D2,"D2");

SetName(RCWAExamples.SymmetrizingCollatzTree.L3,"L3");
SetName(RCWAExamples.SymmetrizingCollatzTree.R3,"R3");
SetName(RCWAExamples.SymmetrizingCollatzTree.D3,"D3");

SetName(RCWAExamples.SymmetrizingCollatzTree.L4,"L4");
SetName(RCWAExamples.SymmetrizingCollatzTree.R4,"R4");
SetName(RCWAExamples.SymmetrizingCollatzTree.D4,"D4");

SetName(RCWAExamples.SymmetrizingCollatzTree.L5,"L5");
SetName(RCWAExamples.SymmetrizingCollatzTree.R5,"R5");
SetName(RCWAExamples.SymmetrizingCollatzTree.D5,"D5");

#############################################################################
##
##  Some wild rcwa mappings which have only finite cycles, or which have
##  cycles with positive densities as sets. 
##
RCWAExamples.FiniteVsDenseCycles := rec(

  kappa := RcwaMapping([[1,0,1],[1,0,1],[3,2,2],[1,-1,1],
                        [2,0,1],[1,0,1],[3,2,2],[1,-1,1],
                        [1,1,3],[1,0,1],[3,2,2],[2,-2,1]]),

  kappaZ := RcwaMapping([[2, 8,1],[1,-1,1],[3,2,2],[1, 2,1],
                         [1,-3,1],[1,-3,1],[3,2,2],[1, 2,1],
                         [1, 1,3],[1,-3,1],[3,2,2],[2,-2,1]]),

  # An example of a mapping with an infinite cycle traversing the residue
  # classes (mod 12) acyclically, but having positive density as a subset
  # of Z (apparently 3/8).

  kappatilde := RcwaMapping([[2,-4,1],[3, 33,1],[3,2,2],[1,-1,1],
                             [2, 0,1],[3,-39,1],[3,2,2],[1,-1,1],
                             [1, 1,3],[3, 33,1],[3,2,2],[1, 4,3]]),

  # Slight modifications which also have only finite cycles.

  kappa12_fincyc := RcwaMapping([[2,-4,1],[3,-3,1],[3,2,2],[1,-1,1],
                                 [2, 0,1],[3,-3,1],[3,2,2],[1,-1,1],
                                 [1, 1,3],[3,-3,1],[3,2,2],[1, 4,3]]),

  kappa24_fincyc := RcwaMapping([[1, 0,1],[1, 0,1],[1,0,1],[1, 0,1],
                                 [3, 4,2],[1,-1,1],[1,0,1],[6,-2,1],
                                 [2, 0,1],[1, 0,1],[1,0,1],[1, 0,1],
                                 [3, 4,2],[1,-1,1],[1,0,1],[6,-2,1],
                                 [1,-1,3],[1, 0,1],[1,0,1],[1, 0,1],
                                 [3, 4,2],[1, 0,3],[1,0,1],[6,-2,1]]),

  # A mapping which has finite cycles of unbounded length and, like the
  # mapping `kappatilde' above, apparently one ``chaotically behaving''
  # infinite cycle which has positive density (apparently 11/48) as
  # a subset of Z.

  kappa24_densecyc := RcwaMapping([[1, 0,1],[1, 0,1],[1,0,1],[1,  0,1],
                                   [3, 4,2],[1,-1,1],[6,4,1],[1, 23,1],
                                   [2, 0,1],[1, 0,1],[1,0,1],[1,  0,1],
                                   [3, 4,2],[1,-1,1],[6,4,1],[1,-25,1],
                                   [1,-1,3],[1, 0,1],[1,0,1],[1,  0,1],
                                   [3, 4,2],[1, 0,3],[6,4,1],[1, 23,1]]),

  # As above, but the density now seems to be 1/6.

  kappa24_onesixthcyc := RcwaMapping([[1, 0,1],[1, 0,1],[1,0,1],[1,   0,1],
                                      [3, 4,2],[1,-1,1],[1,0,1],[6, 142,1],
                                      [2, 0,1],[1, 0,1],[1,0,1],[1,   0,1],
                                      [3, 4,2],[1,-1,1],[1,0,1],[6,-146,1],
                                      [1,-1,3],[1, 0,1],[1,0,1],[1,   0,1],
                                      [3, 4,2],[1, 0,3],[1,0,1],[6, 142,1]]),

  # Apart from fixed points and three 2-cycles, the following permutation
  # apparently has only one cycle, traversing the set (0(4) U 1(6) U 5(12)
  # U 6(12) U 22(36) U 26(36) U 27(36)) \ {-45, -17, 4, 6, 8, 13, 17, 36, 48}
  # in some sense `chaotically':

  kappa36 := RcwaMapping(
               [[1, 3,3],[2, 10,1],[1, 0,1],[1, 0,1],[3,-4,2],[1,11,1],
                [3,-6,2],[1, 13,1],[3,-8,2],[1, 0,1],[1, 0,1],[1, 0,1],
                [1, 3,3],[2, 10,1],[1, 0,1],[1, 0,1],[3,-4,2],[2,14,1],
                [3,-6,2],[2,-11,1],[3,-8,2],[1, 0,1],[1,-4,1],[1, 0,1],
                [2,24,1],[2, 13,1],[1, 4,1],[1,-6,3],[3,-4,2],[1,-1,1],
                [3,-6,2],[1,  1,1],[3,-8,2],[1, 0,1],[1, 0,1],[1, 0,1]]),

  # Even better: apart from the fixed points 4, 6 and 8 and the transposi-
  # tions (-17,-45), (13,36) and (17,48), the following permutation seems
  # to have only one single cycle on the integers:

  omega := RcwaMapping(
             [[1,  3,3],[1,  9,1],[1, 14,1],[1, -7,1],[3, -4,2],[1,-14,3],
              [3, -6,2],[1, 13,1],[3, -8,2],[3, 11,1],[2, -8,1],[3,  6,1],
              [1,  3,3],[2, 10,1],[1,  4,1],[1, 15,1],[3, -4,2],[2, 14,1],
              [3, -6,2],[2,-11,1],[3, -8,2],[3, 11,1],[1, -8,1],[3,  6,1],
              [2, 24,1],[1,  9,1],[1,-11,1],[1, -6,3],[3, -4,2],[1, -1,1],
              [3, -6,2],[1,  2,3],[3, -8,2],[3, 11,1],[2, -5,1],[3,  6,1]]),

  # Similar, but with smaller modulus and with only one fixed point and only
  # one transposition:

  kappaOneCycle := RcwaMapping([[2, 8,1],[1,-1,1],[3,2,2],[1, 2,1],
                                [1, 9,1],[1,-3,1],[3,2,2],[1, 2,1],
                                [1, 1,3],[1,-3,1],[3,2,2],[2,-2,1]]),

  # The mappings <sigma1> and <sigma2> generate a non-cyclic wild group
  # all of whose orbits on Z seem to be finite.

  sigma1 := RcwaMapping([[1,0,1],[1,1,1],[1,1,1],[1,-2,1]]),
  sigma2 := RcwaMapping([[1, 0,1],[3,3,2],[1,0,1],[2,0,1],[1,0,1],[1,0,1],
                         [1,-3,3],[3,3,2],[1,0,1],[1,0,1],[1,0,1],[1,0,1],
                         [2, 0,1],[3,3,2],[1,0,1],[1,0,1],[1,0,1],[1,0,1]]),

  theta := RcwaMapping([[3, 32,16],[3,-1,2],[9,-6,4],[9,-15,2],
                        [3, 20, 8],[3,-1,2],[9,-6,4],[9,-15,2],
                        [9,-72,16],[3,-1,2],[9,-6,4],[9,-15,2],
                        [9, 12, 8],[3,-1,2],[9,-6,4],[9,-15,2]]),

  sigma := ~.sigma1 * ~.sigma2,

  # A `simplification' of <sigma>.

  sigma_r := RcwaMapping([[1, 0,1], [1, 0,1], [2, 2,1], [3,-3,2],
                          [1, 0,1], [1, 1,3], [3, 6,2], [1, 0,1],
                          [1, 0,1], [1, 0,1], [1, 0,1], [1, 0,1],
                          [2, 0,1], [1, 0,1], [1, 1,1], [3,-3,2],
                          [1, 0,1], [1, 1,1], [3, 6,2], [1, 0,1],
                          [1, 0,1], [2, 0,1], [1, 0,1], [1, 0,1],
                          [1,-9,3], [1, 0,1], [1, 1,1], [3,-3,2],
                          [1, 0,1], [2, 2,1], [3, 6,2], [1, 0,1],
                          [1, 0,1], [1, 0,1], [1, 0,1], [1, 0,1]]),

  # The mapping <comm> is another `only finite cycles' example.

  sigmas2 := RcwaMapping([[1,0,1],[1, 0,1],[3,0,2],[2,1,1],[1,0,1],[1,0,1],
                          [3,0,2],[1,-1,3],[1,0,1],[2,1,1],[3,0,2],[1,0,1]]),
  sigmas := ~.sigma1 * ~.sigmas2,
  comm := Comm(~.sigmas,~.sigma1)

);

SetName(RCWAExamples.FiniteVsDenseCycles.kappa,"kappa");
SetName(RCWAExamples.FiniteVsDenseCycles.kappaZ,"kappaZ");
SetName(RCWAExamples.FiniteVsDenseCycles.kappatilde,"kappatilde");
SetName(RCWAExamples.FiniteVsDenseCycles.kappa12_fincyc,"kappa12_fincyc");
SetName(RCWAExamples.FiniteVsDenseCycles.kappa24_fincyc,"kappa24_fincyc");
SetName(RCWAExamples.FiniteVsDenseCycles.kappa24_densecyc,
        "kappa24_densecyc");
SetName(RCWAExamples.FiniteVsDenseCycles.kappa24_densecyc,
        "kappa24_densecyc");
SetName(RCWAExamples.FiniteVsDenseCycles.kappa24_onesixthcyc,
        "kappa24_onesixthcyc");
SetName(RCWAExamples.FiniteVsDenseCycles.kappa36,"kappa36");
SetName(RCWAExamples.FiniteVsDenseCycles.omega,"omega");
SetName(RCWAExamples.FiniteVsDenseCycles.kappaOneCycle,"kappaOneCycle");
SetName(RCWAExamples.FiniteVsDenseCycles.sigma1,"sigma1");
SetName(RCWAExamples.FiniteVsDenseCycles.sigma2,"sigma2");
SetName(RCWAExamples.FiniteVsDenseCycles.theta,"theta");
SetName(RCWAExamples.FiniteVsDenseCycles.sigma,"sigma");
SetName(RCWAExamples.FiniteVsDenseCycles.sigma_r,"sigma_r");
SetName(RCWAExamples.FiniteVsDenseCycles.sigmas2,"sigmas2");
SetName(RCWAExamples.FiniteVsDenseCycles.sigmas,"sigmas");
SetName(RCWAExamples.FiniteVsDenseCycles.comm,"comm");

#############################################################################
##
##  An abelian rcwa group over a polynomial ring
##
##  As the mappings <g> and <h> are modified within the example, we denote
##  the unmodified versions by <gu> and <hu> and the modified ones by
##  <gm> and <hm>, respectively.
##
RCWAExamples.AbelianGroupOverPolynomialRing := rec(

  x := Indeterminate(GF(4),1),
  R := PolynomialRing(GF(4),1),
  e := One(GF(4)),
  p := ~.x^2 + ~.x + ~.e,
  q := ~.x^2 + ~.e,
  r := ~.x^2 + ~.x + Z(4),
  s := ~.x^2 + ~.x + Z(4)^2,
  cg := List( AllResidues(~.R,~.x^2), pol -> [~.p,~.p*pol mod ~.q,~.q] ),
  ch := List( AllResidues(~.R,~.x^2), pol -> [~.r,~.r*pol mod ~.s,~.s] ),
  gu := RcwaMapping( ~.R, ~.q, ~.cg ),
  hu := RcwaMapping( ~.R, ~.s, ~.ch )

);

r := RCWAExamples.AbelianGroupOverPolynomialRing;
SetName(r.x,"x");
r.cg[1][2] := r.cg[1][2] + (r.x^2 + r.e) * r.p * r.q;
r.ch[7][2] := r.ch[7][2] + r.x * r.r * r.s;
r.gm := RcwaMapping( r.R, r.q, r.cg );
r.hm := RcwaMapping( r.R, r.s, r.ch );

#############################################################################
##
##  Some examples over (semi)localizations of the integers
##
RCWAExamples.Semilocals := rec(

  a2  := RcwaMapping(Z_pi(2),[[3,0,2],[3,1,4],[3,0,2],[3,-1,4]]),

  a23 := RcwaMapping(Z_pi([2,3]),[[3,0,2],[3, 1,4],[3,0,2],[3,-1,4]]),
  b23 := RcwaMapping(Z_pi([2,3]),[[3,0,2],[3,13,4],[3,0,2],[3,-1,4]]),
  c23 := RcwaMapping(Z_pi([2,3]),[[3,0,2],[3, 1,4],[3,0,2],[3,11,4]]),

  ab23 := Comm(~.a23,~.b23),
  ac23 := Comm(~.a23,~.c23),

  v := RcwaMapping([[6,0,1],[1,-7,2],[6,0,1],[1,-1,1],
                    [6,0,1],[1, 1,2],[6,0,1],[1,-1,1]]),

  v2 := RcwaMapping(Z_pi(2),ShallowCopy(Coefficients(~.v))),
  w2 := RcwaMapping(Z_pi(2),[[1,0,2],[2,-1,1],[1,1,1],[2,-1,1]]),

  v2w2 := Comm(~.v2,~.w2)

);

SetName(RCWAExamples.Semilocals.a2,"a2");

SetName(RCWAExamples.Semilocals.a23,"a23");
SetName(RCWAExamples.Semilocals.b23,"b23");
SetName(RCWAExamples.Semilocals.c23,"c23");

SetName(RCWAExamples.Semilocals.ab23,"[a23,b23]");
SetName(RCWAExamples.Semilocals.ac23,"[a23,c23]");

SetName(RCWAExamples.Semilocals.v,"v");

SetName(RCWAExamples.Semilocals.v2,"v2");
SetName(RCWAExamples.Semilocals.w2,"w2");

SetName(RCWAExamples.Semilocals.v2w2,"[v2,w2]");

#############################################################################
##
##  Twisting 257-cycles into an rcwa mapping with modulus 32
##
RCWAExamples.LongCyclesOfPrimeLength := rec(

  x_257 := RcwaMapping(
            [[ 16,  2,  1], [ 16, 18,  1],
             [  1, 16,  1], [ 16, 18,  1],
             [  1, 16,  1], [ 16, 18,  1],
             [  1, 16,  1], [ 16, 18,  1],
             [  1, 16,  1], [ 16, 18,  1],
             [  1, 16,  1], [ 16, 18,  1],
             [  1, 16,  1], [ 16, 18,  1],
             [  1, 16,  1], [ 16, 18,  1],
             [  1,  0, 16], [ 16, 18,  1],
             [  1,-14,  1], [ 16, 18,  1],
             [  1,-14,  1], [ 16, 18,  1],
             [  1,-14,  1], [ 16, 18,  1],
             [  1,-14,  1], [ 16, 18,  1],
             [  1,-14,  1], [ 16, 18,  1],
             [  1,-14,  1], [ 16, 18,  1],
             [  1,-14,  1], [  1,-31,  1]])

);

SetName(RCWAExamples.LongCyclesOfPrimeLength.x_257,"x_257");

#############################################################################
##
##  The behaviour of the moduli of powers
##
##  Here we list only those mappings which are used in this example exclu-
##  sively.
##
RCWAExamples.ModuliOfPowers := rec(

  a := RcwaMapping([[3,0,2],[3, 1,4],[3,0,2],[3,-1,4]]),

  e1 := RcwaMapping([[1,4,1],[2,0,1],[1,0,2],[2,0,1]]),
  e2 := RcwaMapping([[1,4,1],[2,0,1],[1,0,2],[1,0,1],
                     [1,4,1],[2,0,1],[1,0,1],[1,0,1]]),

  g  := RcwaMapping([[2,2,1],[1, 4,1],[1,0,2],[2,2,1],[1,-4,1],[1,-2,1]]),
  h  := RcwaMapping([[2,2,1],[1,-2,1],[1,0,2],[2,2,1],[1,-1,1],[1, 1,1]]),

  u  := RcwaMapping([[3,0,5],[9,1,5],[3,-1,5],[9,-2,5],[9,4,5]]),

  v6 := RcwaMapping([[-1,2,1],[1,-1,1],[1,-1,1]]),
  w8 := RcwaMapping([[-1,3,1],[1,-1,1],[1,-1,1],[1,-1,1]]),

  z := RcwaMapping([[2,  1, 1],[1,  1,1],[2, -1,1],[2, -2,1],
                    [1,  6, 2],[1,  1,1],[1, -6,2],[2,  5,1],
                    [1,  6, 2],[1,  1,1],[1,  1,1],[2, -5,1],
                    [1,  0, 1],[1, -4,1],[1,  0,1],[2,-10,1]])

);

SetName(RCWAExamples.ModuliOfPowers.a,"a");
SetName(RCWAExamples.ModuliOfPowers.e1,"e1");
SetName(RCWAExamples.ModuliOfPowers.e2,"e2");
SetName(RCWAExamples.ModuliOfPowers.g,"g");
SetName(RCWAExamples.ModuliOfPowers.h,"h");
SetName(RCWAExamples.ModuliOfPowers.u,"u");
SetName(RCWAExamples.ModuliOfPowers.v6,"v6");
SetName(RCWAExamples.ModuliOfPowers.w8,"w8");
SetName(RCWAExamples.ModuliOfPowers.z,"z");

#############################################################################
##
##  Class transpositions can be written as commutators:
##
##  The class transposition interchanging <r1>(<m1>) and <r2>(<m2>) is the
##  commutator of `ct1'(<r1>,<m1>,<r2>,<m2>) and `ct2'(<r1>,<m1>,<r2>,<m2>).
##
RCWAExamples.ClassTranspositionsAsCommutators := rec(

  tau1 := ClassTransposition(0,4,1,4) * ClassTransposition(0,4,2,4),
  tau2 := ClassTransposition(0,4,1,4) * ClassTransposition(0,4,3,4),

  ct1 := function(r1,m1,r2,m2)
           return Restriction(RCWAExamples.
                              ClassTranspositionsAsCommutators.tau1,
                              RcwaMapping([[m1,2*r1,2],[m2,2*r2-m2,2]]));
         end,

  ct2 := function(r1,m1,r2,m2)
           return Restriction(RCWAExamples.
                              ClassTranspositionsAsCommutators.tau2,
                              RcwaMapping([[m1,2*r1,2],[m2,2*r2-m2,2]]));
         end

);

#############################################################################
##
##  Involutions whose product has coprime multiplier and divisor
##
##  This was one of the first examples, and it is still here
##  only in order to stick to not removing anything from this file.
##  Cf. the function `PrimeSwitch'.
##
RCWAExamples.CoprimeMultDiv := rec(

  f1 := RcwaMapping([List([[1,6],[0, 8]],ResidueClass),
                     List([[5,6],[4, 8]],ResidueClass)]),
  f2 := RcwaMapping([List([[1,6],[0, 4]],ResidueClass),
                     List([[2,4],[5, 6]],ResidueClass)]),
  f3 := RcwaMapping([List([[2,6],[1,12]],ResidueClass),
                     List([[4,6],[7,12]],ResidueClass)]),

  f12 := ~.f1*~.f2,
  f23 := ~.f2*~.f3, # Only finite cycles (?)
  f13 := ~.f1*~.f3, #  "     "      "    (?)

  f := ~.f1*~.f2*~.f3,

  # Two tame mappings (of orders 3 and 2, respectively),
  # whose product is not balanced.

  g1 := RcwaMapping([[6,2,1],[1,-1,1],[1,4,6],[6,2,1],[1,-1,1],[1,0,1],
                     [6,2,1],[1,-1,1],[1,0,1],[6,2,1],[1,-1,1],[1,0,1],
                     [6,2,1],[1,-1,1],[1,0,1],[6,2,1],[1,-1,1],[1,0,1]]),

  g2 := RcwaMapping([[1,0,1],[3,-1,1],[1,1,3],[1,0,1],[1,0,1],[1,0,1],
                     [1,0,1],[3,-1,1],[1,0,1],[1,0,1],[1,0,1],[1,0,1],
                     [1,0,1],[3,-1,1],[1,0,1],[1,0,1],[1,0,1],[1,0,1]]),

  # Two mappings whose commutator is not balanced.

  c1 := Restriction(RcwaMapping([[2,0,3],[4,-1,3],[4,1,3]]),
                    RcwaMapping([[2,0,1]])),
  c2 := RcwaMapping([[1,0,2],[2,1,1],[1,-1,1],[2,1,1]])

);

SetName(RCWAExamples.CoprimeMultDiv.f1,"f1");
SetName(RCWAExamples.CoprimeMultDiv.f2,"f2");
SetName(RCWAExamples.CoprimeMultDiv.f3,"f3");

SetName(RCWAExamples.CoprimeMultDiv.f12,"f12");
SetName(RCWAExamples.CoprimeMultDiv.f23,"f23");
SetName(RCWAExamples.CoprimeMultDiv.f13,"f13");

SetName(RCWAExamples.CoprimeMultDiv.f,"f");

SetName(RCWAExamples.CoprimeMultDiv.g1,"g1");
SetName(RCWAExamples.CoprimeMultDiv.g2,"g2");

SetName(RCWAExamples.CoprimeMultDiv.c1,"c1");
SetName(RCWAExamples.CoprimeMultDiv.c2,"c2");

#############################################################################
##
##  A tame group generated by commutators of wild permutations
##
##  This was one of the first examples, and it is still here only in order
##  to stick to not removing anything from this file.
##
RCWAExamples.TameGroupByCommsOfWildPerms := rec(

  a := RcwaMapping([[3,0,2],[3, 1,4],[3,0,2],[3,-1,4]]),
  b := RcwaMapping([[3,0,2],[3,13,4],[3,0,2],[3,-1,4]]),
  c := RcwaMapping([[3,0,2],[3, 1,4],[3,0,2],[3,11,4]]),

  ab := Comm(~.a,~.b),
  ac := Comm(~.a,~.c),
  bc := Comm(~.b,~.c),

  # A factorization of `a' (see above) into two balanced mappings,
  # where one of them is an involution.

  a_2 := RcwaMapping([List([[1,2],[36,72]],ResidueClass)]),
  a_1 := ~.a/~.a_2,

  # Two rcwa mappings of orders 7 and 12, respectively, which have isomorphic
  # transition graphs for modulus 6 and generate an infinite tame group.

  g := RcwaMapping([[2,2,1],[1, 4,1],[1,0,2],[2,2,1],[1,-4,1],[1,-2,1]]),
  h := RcwaMapping([[2,2,1],[1,-2,1],[1,0,2],[2,2,1],[1,-1,1],[1, 1,1]]),

);

SetName(RCWAExamples.TameGroupByCommsOfWildPerms.a,"a");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.b,"b");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.c,"c");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.ab,"[a,b]");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.ac,"[a,c]");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.bc,"[b,c]");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.a_1,"a_1");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.a_2,"a_2");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.g,"g");
SetName(RCWAExamples.TameGroupByCommsOfWildPerms.h,"h");

#############################################################################
##
##  Checking for (in-)solvability
##
RCWAExamples.CheckingForSolvability := rec(

  a := RcwaMapping([[3,0,2],[3, 1,4],[3,0,2],[3,-1,4]]),
  b := RcwaMapping([[3,0,2],[3,13,4],[3,0,2],[3,-1,4]]),
  G := Group(~.a,~.b)

);

SetName(RCWAExamples.CheckingForSolvability.a,"a");
SetName(RCWAExamples.CheckingForSolvability.b,"b");

#############################################################################
##
##  An rcwa representation of Syl_3(S_9)
##
##  This was one of the first examples, and it is still here only in order
##  to stick to not removing anything from this file.
##
RCWAExamples.Syl3_S9 := rec(

  r := RcwaMapping([[1,0,1],[1,1,1],[3, -3,1],
                    [1,0,3],[1,1,1],[3, -3,1],
                    [1,0,1],[1,1,1],[3, -3,1]]),

  s := RcwaMapping([[1,0,1],[1,1,1],[3,  6,1],
                    [1,0,3],[1,1,1],[3,  6,1],
                    [1,0,1],[1,1,1],[3,-21,1]])

);

SetName(RCWAExamples.Syl3_S9.r,"r");
SetName(RCWAExamples.Syl3_S9.s,"s");

#############################################################################
##
##  "Class switches": Involutions which interchange two residue classes
##  which are not necessarily disjoint (of course there must not be a proper
##  subset relation between them!):
##
RCWAExamples.ClassSwitches := rec(

  ClassSwitch := function( r1, m1, r2, m2 )

    local  cl, int, diff, lng, pos, clsp, sp, c, r, m, rti, mti, rest, i;

    cl  := List([[r1,m1],[r2,m2]],ResidueClass);
    int := Intersection(cl);
    if int = [] then return ClassTransposition(r1,m1,r2,m2); fi;
    diff := [Difference(cl[1],cl[2]),Difference(cl[2],cl[1])];
    if [] in diff then return fail; fi; # Subset rel. --> no class switch!
    diff := List(diff,AsUnionOfFewClasses); lng := List(diff,Length);
    if lng[1] <> lng[2] then
      if lng[1] < lng[2] then pos := 1; else pos := 2; fi;
      for i in [1..AbsInt(lng[1]-lng[2])] do
        clsp := diff[pos][1];
        sp := [ResidueClass(Residues(clsp)[1],
                            2*Modulus(clsp)),
               ResidueClass(Residues(clsp)[1]+Modulus(clsp),
                            2*Modulus(clsp))];
        diff[pos] := Union(Difference(diff[pos],[clsp]),sp);
      od;
    fi;
    lng := Maximum(lng); m := 2*lng; c := [];
    for r in [0..m-1] do
      rti := Residues(diff[r mod 2 + 1][Int(r/2)+1])[1];
      mti := Modulus (diff[r mod 2 + 1][Int(r/2)+1]);
      c[r+1] := [mti,m*rti-mti*r,m];
    od;
    rest := RcwaMapping(c);
    return Restriction(tau,rest);
  end

);

#############################################################################
##
##  A factorization of Collatz' permutation into involutions. 
##
##  The following factorization has been determined interactively, before
##  the general factorization routine `FactorizationIntoCSCRCT' has been
##  implemented. The determination of this factorization gave the necessary
##  insights to develop a general method.
##
RCWAExamples.CollatzFactorizationOld := rec(

  f1 := RCWAExamples.CoprimeMultDiv.f1,
  f2 := RCWAExamples.CoprimeMultDiv.f2,
  f3 := RCWAExamples.CoprimeMultDiv.f3,
  f  := RCWAExamples.CoprimeMultDiv.f,

  INTEGRAL_PART_COEFFS :=
  [ -3, -26, -47, -40, 47, -1, 0, 17, 0, -4, 0, 28, 19, 12, 0, 2, -7, 20,
    0, -3, 0, 12, 0, 37, -3, 4, 0, 13, -9, -1, 0, 17, 0, 2, 0, 70, 38, 12,
    0, 2, 3, -26, 0, -30, 0, 30, 0, 144, 19, -26, 0, -40, -7, -1, 0, 17,
    0, -4, 0, 28, -3, 12, 0, 2, -9, 20, 0, -3, 0, -57, 0, -35, -3, 4, -47,
    13, 47, -1, 0, 17, 0, 2, 0, -76, 19, 12, 0, 2, -7, -26, 0, -30, 0, 54,
    0, 37, -3, -26, 0, -40, -9, -1, 0, 17, 0, -4, 0, 28, 38, 12, 0, 2, 3,
    20, 0, -3, 0, -22, 0, 24, 19, 4, 0, 13, -7, -1, 0, 17, 0, 2, 0, -52,
    -3, 12, 0, 2, -9, -26, 0, -30, 0, -57, 0, -35, -3, -26, -47, -40, 47,
    -1, 0, 17, 0, -4, 0, 28, 19, 12, 0, 2, -7, 20, 0, -3, 0, 12, 0, 37,
    -3, 4, 0, 13, -9, -1, 0, 17, 0, 2, 0, 70, 38, 12, 0, 2, 3, -26, 0,
    -30, 0, 30, 0, 96, 19, -26, 0, -40, -7, -1, 0, 17, 0, -4, 0, 28, -3,
    12, 0, 2, -9, 20, 0, -3, 0, -57, 0, -35, -3, 4, -47, 13, 47, -1, 0,
    17, 0, 2, 0, -76, 19, 12, 0, 2, -7, -26, 0, -30, 0, 54, 0, 37, -3,
    -26, 0, -40, -9, -1, 0, 17, 0, -4, 0, 28, 38, 12, 0, 2, 3, 20, 0, -3,
    0, -214, 0, -24, 19, 4, 0, 13, -7, -1, 0, 17, 0, 2, 0, -52, -3, 12, 0,
    2, -9, -26, 0, -30, 0, -57, 0, -35 ],

  FactorsOfCollatzPermutation := [
    RcwaMapping(List(~.INTEGRAL_PART_COEFFS,b_rm->[1,b_rm,1])), nu^-4,
    RcwaMapping([[rc(3,144),rc(139,288)],[rc(75,144),rc(235,288)]]),
    RcwaMapping([[rc(101,144),rc(43,288)]]),
    RcwaMapping([[rc(27,36),rc(23,72)],[rc(17,36),rc(47,72)],
                 [rc(70,72),rc(71,144)],[rc(65,72),rc(143,144)]]),
    RcwaMapping([[rc(29,144),rc(91,288)]]),
    RcwaMapping([[rc(27,36),rc(70,72)],[rc(17,36),rc(3,72)]]),
    RcwaMapping([[rc(29,72),rc(187,288)],[rc(65,72),rc(283,288)]]),
    RcwaMapping([[rc(3,36),rc(8,72)],[rc(5,36),rc(32,72)],
                 [rc(15,36),rc(56,72)]]),
    RcwaMapping([[rc(3,36),rc(91,288)],[rc(5,36),rc(187,288)],
                 [rc(15,36),rc(283,288)]]),
    RcwaMapping([[rc(23,24),rc(7,48)],[rc(8,24),rc(33,48)],
                 [rc(13,24),rc(43,96)]]),
    RcwaMapping([[rc(17,36),rc(91,288)],[rc(29,36),rc(283,288)]]),
    RcwaMapping([[rc(20,24),rc(4,12)],[rc(19,48),rc(21,24)]]),
    RcwaMapping([[rc(283,288),rc(29,36)]]),
    RcwaMapping([[rc(3,36),rc(1,48)],[rc(15,36),rc(25,48)],
                 [rc(27,36),rc(11,48)],[rc(5,36),rc(35,48)],
                 [rc(17,36),rc(36,48)],[rc(29,36),rc(9,48)],
                 [rc(91,288),rc(33,48)],[rc(187,288),rc(20,24)],
                 [rc(283,288),rc(7,48)]]), ~.f, nu^4, ~.f^4 ],

  FACTORS_OF_CP_CYCS := List([1,2,4,12,112,156,256],
                             n->Cycle(~.FactorsOfCollatzPermutation[1],n)
                                mod 288),

  nu_rm := ClassShift, t_rm := ClassReflection,

  InvolutionFactorsOfCollatzPermutation := Concatenation(
    [ ~.t_rm(  0,288), ~.t_rm(  0,288) * ~.nu_rm(  0,288)^-1,
      ~.t_rm(  1,288), ~.t_rm(  1,288) * ~.nu_rm(  1,288)^-1,
      ~.t_rm(  2,288), ~.t_rm(  2,288) * ~.nu_rm(  2,288)^-1,
      ~.t_rm(  3,288), ~.t_rm(  3,288) * ~.nu_rm(  3,288)^-1,
      ~.t_rm(237,288), ~.t_rm(237,288) * ~.nu_rm(237,288),
      ~.t_rm(252,288), ~.t_rm(252,288) * ~.nu_rm(252,288),
      ~.t_rm(271,288), ~.t_rm(271,288) * ~.nu_rm(271,288),
      ~.t_rm(277,288), ~.t_rm(277,288) * ~.nu_rm(277,288) ],
    Concatenation(List(~.FACTORS_OF_CP_CYCS,cyc->List([2..Length(cyc)],
                       i->RcwaMapping([[rc(cyc[1],288),rc(cyc[i],288)]])))),
    [ RcwaMapping([[-1,1,1]]), t, RcwaMapping([[-1,1,1]]), t,
      RcwaMapping([[-1,1,1]]), t, RcwaMapping([[-1,1,1]]), t ],
    ~.FactorsOfCollatzPermutation{[3..15]},
    [ ~.f1, ~.f2, ~.f3, t, RcwaMapping([[-1,1,1]]), t,
      RcwaMapping([[-1,1,1]]), t, RcwaMapping([[-1,1,1]]), t,
      RcwaMapping([[-1,1,1]]), ~.f1, ~.f2, ~.f3, ~.f1, ~.f2, ~.f3,
      ~.f1, ~.f2, ~.f3, ~.f1, ~.f2, ~.f3 ] )

);

return RCWAExamples;

#############################################################################
##
#E  examples.g . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here