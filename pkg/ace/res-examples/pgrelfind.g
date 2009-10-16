#############################################################################
####
##
#W  pgrelfind.g             ACE Research Example             Alexander Hulpke
#W                                                                Greg Gamble
#W                                                               George Havas
##
##  Defines programs and variables for finding 3-relator presentations  of  a
##  specific form, for perfect simple groups.
##
##  Featured in this file is a genuine research example.  The  original  code
##  was  written  by  Alexander  Hulpke.  Greg  Gamble  later   modified   it
##  significantly, adding comments and options,  and  alterations  needed  to
##  enable it to work with the  latest  ACE Package.  Names of some functions
##  and variables were also changed.
##
#H  @(#)$Id: pgrelfind.g,v 1.4 2003/12/22 17:52:07 gap Exp $
##
#Y  Copyright (C) 2000  Centre for Discrete Mathematics and Computing
#Y                      Department of Computer Science & Electrical Eng.
#Y                      University of Queensland, Australia.
##
Revision.pgrelfind_g :=
    "@(#)$Id: pgrelfind.g,v 1.4 2003/12/22 17:52:07 gap Exp $";

## Begin
if not(IsBound(ACEResExample) and IsBound(ACEResExample.reread)) then
  ACEResExample := rec(filename := "pgrelfind.g");
  RequirePackage("ace", "3.0");
fi;
# Use ACE for CosetTableFromGensAndRels coset enumerations
TCENUM := ACETCENUM;;

# The following global variables are set in PGRelFind
ALLRELS := []; # in case we want to collect all relators tried.
newrels := []; # in case we want to collect all relators that work.

PGRelFind := function(Fgens, rels, sgens)
##  For the perfect *simple* group S = <Fgens | rels> with  subgroup  <sgens>
##  where each element of the list sgens is a word in the  generators  Fgens,
##  try to find one `extra' relator. Fgens should contain two generators of a
##  free group, say [a, b]; rels  should  contain  words  in  the  generators
##  Fgens, the first of which, should determine that a is an involution,  the
##  second should determine the order  of  b.  The  subgroup  <sgens>  should
##  ideally be a maximal subgroup of <Fgens | rels>. The purpose of PGRelFind
##  is to find a presentation containing just 3 relators, one determining the
##  order of a, one determining the order of b, and just one other.  After  a
##  search is successful, searching continues in  case  there  is  a  shorter
##  relator, and terminates with a relator of shortest length.
##
##  Options : 
##   head : Each relator tested is of form `head' * `middle' * `tail'
##      where `head' is constant. This option sets the value of `head'.
##     Value: a word in Fgens
##     Default: a*b*a*b*a/b (if |b| = 3), a*b (otherwise)
##   Nrandom : Each `middle' may be generated sequentially or randomly.
##      If Nrandom = 0 then `middle's are generated sequentially.
##      If Nrandom is a positive integer then for each length of a
##       middle Nrandom `middle's are generated.
##      If Nrandom is a positive integer valued single-argument
##       function then for each length len of a middle Nrandom(len)
##       `middle's are generated.
##     Value: a non-negative integer OR a single-argument function
##            that returns a positive integer.
##     Default: 0
##   ACEworkspace : The workspace ACE is set to use when running the
##      index check of the large subgroup. If the index is right,
##      double this workspace is used to check the index of <b>.
##     Value: a positive integer
##     Default: 10^6
##   Ntails : Approximate no. of tails generated. It is used to set
##      maxTailLength.
##     Value: a positive integer
##     Default: 2048
##   maxTailLength : (Intended) maximum tail length. Actual maximum
##      tail length may be 1 less, so that it has the same parity as
##      the minimum tail length. Overrides the effect of Ntails.
##     Value: a positive integer
##     Default: LogInt(Ntails, |b| - 1)
##   minMiddleLength : Minimum length of a `middle'.
##     Value: non-negative integer
##     Default: 0
##   maxMiddleLength : (Intended) maximum length of a `middle'. Actual
##      maximum may be less, in order to ensure granularity + 2 divides
##       maxMiddleLength - minMiddleLength, where 
##
##          granularity = maxTailLength - minTailLength
##
##     Value: positive integer
##     Default: 30
##   
local SetConstFromOption, NewRelator, F, a, b, t, permSgens, idx, orderS, 
      orderb, whead;

  SetConstFromOption := function(opt, default)
    # Sets a PGRelFind constant according to the option opt passed to
    # PGRelFind, or if no such option is passed sets the constant to
    # default.
    local optval;
    optval := ValueOption(opt);
    if optval = fail then
       optval := default;
    fi;
    return optval;
  end;

  NewRelator := function(gens)
  # Produces a,b-words starting with whead until a new relator that
  # satisfies IsPresentation is found and returns that relator. 
  local ACEworkspace, Nrandom, headLength, minMiddleLength, maxMiddleLength, 
        Ntails, minTailLength, maxTailLength, granularity, GAPstarttime, 
        IsPresentation, ap, bp, head, headbExptSum, Nbexpts, bexpts, absylls,
        Initc, cLength, c, cCtr, NcVectors, bExptSum, GetNextc, Permc, Wordc,
        TailLenIndex, tails, NonZeroModOrderb, tail, UnbindList, nrandom, 
        bPowers, Randomc, relatorExclusions, maxTailLenIndex, p, tailrec, 
        w, Nwbisyllables;

    # Constants ... read `Length' as #a,b-bisyllables
    ACEworkspace := SetConstFromOption("ACEworkspace", 10^6);
    Nrandom := SetConstFromOption("Nrandom", 0);
    headLength := ExponentSumWord(whead, a);
    minTailLength := (headLength - 1) mod 2;
    Ntails := SetConstFromOption("Ntails", 2048);
    maxTailLength := SetConstFromOption(
                         "maxTailLength", LogInt(Ntails, orderb - 1)
                         ); 
    # ensure maxTailLength has same parity as minTailLength
    maxTailLength := maxTailLength - (maxTailLength - minTailLength) mod 2;
    granularity := maxTailLength - minTailLength;
    minMiddleLength := SetConstFromOption("minMiddleLength", 0);
    # ensure minMiddleLength is even
    minMiddleLength := minMiddleLength - (minMiddleLength mod 2);
    maxMiddleLength := SetConstFromOption("maxMiddleLength", 30);
    # ensure granularity + 2 divides maxMiddleLength - minTailLength
    maxMiddleLength 
        := maxMiddleLength - 
           (maxMiddleLength - minMiddleLength) mod (granularity + 2);
    GAPstarttime := Runtime();

    # Each potential new relator w will be constructed as: 
    #
    #    w = whead * wmiddle * wtail
    #
    # with corresponding permutation representation:
    #
    #    wp = head * middle * tail.
    #
    # To be a relator, such a word w must be the identity.
    # In particular, 1^wp = 1 i.e. 1^(head * middle) = 1^(tail^-1).
    # As we go, we ensure that the total number of bisyllables
    # (= ExponentSum(w, a)) is odd ... avoiding an explicit
    # perfectness test for the as.

    IsPresentation := function(word)
    # As a side-effect IsPresentation prints coset enumeration stats.
    local t, PrintACEStats;

      PrintACEStats := function(msg)
        Print("ACEStats", msg, ":\n  index=", t.index,
              " cputime=", t.cputime * 10, " ms",
              " maxcosets=", t.maxcosets,
              " totcosets=", t.totcosets,"\n");
      end;

      # First test whether the subgroup has the right index
      t := ACEStats([a,b], [a^2,b^orderb,word], sgens
                    :workspace:=ACEworkspace, hard, mend, 
                     acenow, aceignoreu);
      PrintACEStats("");

      if t.index=idx then
        Print("Large subgroup index OK\n");
        t := ACEStats([a,b], [a^2,b^orderb,word], [b]
                      :workspace:=2*ACEworkspace, hard, mend, 
                       acenow, aceignoreu);
        PrintACEStats(" for cyclic subgroup");
        if t.index * orderb=orderS then
          Print("Cyclic subgroup index OK\n");
          return true;
        else
          return false;
        fi;
      fi;
      return false;
    end;

    ap := gens[1];
    bp := gens[2];

    Print("#bisyllables in head = ", headLength, " head: ", whead, "\n");
    head := MappedWord(whead, [a,b], [ap,bp]);
    headbExptSum := ExponentSumWord(whead, b);

    # Each a,b-(sub)word (be it head, middle or tail) is of form:
    #
    #        e[1]   e[2]       e[eLength]
    #     a b    a b    ... a b
    # 
    # where e[i] = bexpts[ c[i] ]
    
    Nbexpts := orderb - 1; # Number of b exponents
    bexpts  # Possible b exponents (we assume |b| is odd)
            # [ 1, 2, ..., |b| div 2, -(|b| div 2), ..., -2, -1 ]
       := Concatenation([1 .. Int(orderb/2)], [-Int(orderb/2) .. -1]);
    absylls := List(bexpts, i -> ap*bp^i); # feasible a,b-bisyllables

    Initc := function()
    # Initialise c
      
      c := ListWithIdenticalEntries(cLength, bexpts[1]);
      bExptSum := cLength;
      NcVectors := Nbexpts^cLength; # Number of different cs
    end;

    GetNextc := function()
    # Essentially, if n is a counter in base (|b| - 1),
    # with #c digits, then c[i] = n[i] + 1
    # i.e. each digit n[i] is in the range [0 .. |b| - 2]
    # so that c[i] = n[i] + 1 is in the range [1 .. |b| - 1].
    local i;
      if cCtr < NcVectors then
        # We only need bExptSum to be correct modulo |b|
        if c[1] < Nbexpts then
          c[1] := c[1] + 1;
          bExptSum := bExptSum + 1;
        else
          i := 1;
          while c[i] = Nbexpts do
            c[i] := 1;
            bExptSum := bExptSum + 2; # Correct modulo |b|
            i := i + 1;
          od;
          c[i] := c[i] + 1;
          bExptSum := bExptSum + 1;
        fi;
      fi;
    end;

    # Permc gives the corresponding permutation to c
    Permc := c -> Product(c, ci -> absylls[ci], One(ap));

    # Wordc gives the corresponding a,b-word to c
    Wordc := c -> Product(c, ci -> a*b^bexpts[ci], One(a));
    
    Print("Max #bisyllables in tail = ", maxTailLength, 
          " (granularity = ", maxTailLength - minTailLength, ")\n");

    # Produce all tails up to maxTailLength bisyllables and index them 
    # according to:
    #
    #   * their preimages of 1 
    #   * their b exponent sums after multiplication by head
    #   * their number of bisyllables
    # 
    # in the following way. If tailrec = tails[i][j][k] and
    #
    #   wtail = tailrec.word   ... tail as an a,b-word
    #    tail = tailrec.perm   ... tail as a permutation
    # 
    # then:
    #
    #    i = 1^(tail^-1)
    #    j = ExponentSumWord(whead * wtail, b) mod |b|
    #        (except that j = |b| where the above returns 0)
    #        ... this enables a fast perfectness check for
    #            the b exponent sum
    #    k = ((#bisyllables in wtail) div 2) + 1
    #
    # We also include #bisyllables in wtail in the tailrec as
    #
    #   aExpt = tailrec.aExptSum
    #

    TailLenIndex := length -> Int(length/2) + 1;

    tails := List([1..idx], 
                  i -> List([1..orderb], 
                            j -> List([1..TailLenIndex(maxTailLength)],
                                      k -> [])));

    NonZeroModOrderb := function(x)
      local xmodb;

      xmodb := x mod orderb;
      if xmodb = 0 then
        return orderb;
      else
        return xmodb;
      fi;
    end;
    
    for cLength in [minTailLength, minTailLength + 2 .. maxTailLength] do
      Initc();
      for cCtr in [1 .. NcVectors] do
        tail := Permc(c); # tail as permutation
        Add(tails[1^(tail^-1)]
                 [NonZeroModOrderb(headbExptSum + bExptSum)]
                 [TailLenIndex(cLength)], 
            rec(word := Wordc(c), perm := tail, aExptSum := cLength));
        GetNextc();
      od;
    od;

    UnbindList := function(list, indexlist)
    # Unbinds list[i] for each i in indexlist
      local i;

      for i in indexlist do
        Unbind(list[i]);
      od;
    end;

    if IsInt(Nrandom) and Nrandom > 0 then
      # First make Nrandom a function, if Nrandom is a nonzero constant
      nrandom := Nrandom;
      Nrandom := len -> nrandom;
    fi;

    if IsFunction(Nrandom) then
    # If random non-zero middles are to be chosen randomly
    # ... so we redefine Initc() and GetNextc()

      bPowers := [1 .. orderb - 1];
      
      Randomc := function()
        c := List([1..cLength], i -> Random(bPowers));
        bExptSum := Sum(c);
      end;

      Initc := function()
        NcVectors := Nrandom(cLength);
        Randomc();
      end;

      GetNextc := function()
        if cCtr < NcVectors then
          Randomc();
        fi;
      end;

    fi;

    newrels := [];      # newrels is a global variable
    relatorExclusions   # relators already checked of each length
            := List([1 .. headLength + maxMiddleLength + maxTailLength], 
                    i -> []);
    maxTailLenIndex := TailLenIndex(maxTailLength);

    # Now compute all middles ... and use them
    for cLength in [minMiddleLength, 
                    minMiddleLength + granularity + 2 .. maxMiddleLength] do
      Print("#bisyllables in middle = ", cLength, "\n");
      Initc();
      for cCtr in [1 .. NcVectors] do
        if cCtr mod 10000 = 0 then
          Print("#words tested: ", cCtr, 
                " GAP time: ", Runtime() - GAPstarttime, " ms\n");
        fi;
        p := head * Permc(c); # head * middle
        for tailrec in 
            Flat(tails[1^p]            # tails with the right preimage of 1
                 {Filtered([1..orderb],# s.t. #bs in w is coprime to |b|
                           j -> Gcd(j + bExptSum, orderb) = 1
                           )}
                 {[1..maxTailLenIndex]}) do
          if # w = p * tail is a relator (i.e. p * tail = identity)
             # ... first check 2 fixed - (quicker test than order)
             (2^p)^tailrec.perm = 2 and Order(p * tailrec.perm) = 1 then
            w := whead * Wordc(c) * tailrec.word;
            Nwbisyllables := headLength + cLength + tailrec.aExptSum;
            if ForAll(RelatorRepresentatives([w]),
                      wc -> not(wc in relatorExclusions[Nwbisyllables])) then
              Add(relatorExclusions[Nwbisyllables], w); # Avoid testing 
                                                      # essentially the 
                                                      # same relator twice
              Print("Candidate relator: ",w,"\n",
                    " #bisyllables = ", Nwbisyllables,
                    " (#bisyllables in tail = ", tailrec.aExptSum, ")",
                    " #words tested: ", cCtr, "\n"); 
              Add(ALLRELS, w);
              if IsPresentation(w) then
                Print("Success! ... new relator: \n   ", w, "\n");
                maxTailLenIndex := TailLenIndex(tailrec.aExptSum) - 1;
                if maxTailLenIndex < 1 then
                  Print("Relator found is shortest possible.\n");
                  return w;
                else
                  Print("... continuing (there may be a shorter relator).\n");
                  Add(newrels, w);
                fi;
              fi;
            fi;
          fi;
        od;
        GetNextc();
      od;
      if maxTailLenIndex < TailLenIndex(maxTailLength) then
        # We have found at least one new relator ... and since we have
        # now exhausted the middles for this iteration, we now know
        # the last relator found is shortest possible.
        w := newrels[Length(newrels)];
        Print("Middles of length ", cLength, " exhausted.\n");
        Print("Relator found of length ", ExponentSumWord(w, a), 
              ", is shortest.\n");
        return newrels[Length(newrels)];
      fi;
      UnbindList(relatorExclusions, [1 .. headLength + cLength]);
    od;

    # If the alternative `Error("Success! ...' lines are used above
    # then newrels at this point can be non-empty ... otherwise the
    # only way we can get here is if we didn't succeed.
    if IsEmpty(newrels) then
      Print("Search completed! ... but no new relator found :-(");
      return [];
    else
      Error("Search completed! \n",
            "... newrels contains all new relators that work");
      # A continuation from the break-loop here will effect a graceful
      # exit from RelatorWords.
      return newrels[Length(newrels)];
    fi;
  end;

  F := GroupWithGenerators(Fgens); a := F.1; b := F.2;

  # We create an initial permutation representation . . . . . . . . . .
  # Since S = <Fgens | rels> is simple,  the permutation representation
  # permS of S's action on the right cosets of a large subgroup of G is
  # isomorphic to S itself i.e. 
  #   
  #    phi : S       -> permS
  #          [a, b] |-> [permSgens[1], permSgens[2]]
  #
  # is an isomorphism. Word calculations using this permutation repres-
  # entation are far more efficient than using a free presentation.
  t := CosetTableFromGensAndRels(Fgens, rels, sgens : 
                                 acenow, aceignoreu);
  permSgens := List(t{[1,3..Length(t)-1]}, PermList);
  idx := Length(t[1]);

  if Order(permSgens[1]) <> 2 then
    Error(a, " (1st gen'r) should be an involution, not of order ",
          Order(permSgens[1]), "\n");
  fi;
  orderb := Order(permSgens[2]);
  if orderb = 2 or not IsPrime(orderb) then
    Error("order of ", b, " (2nd gen'r) is ", orderb, 
          " ... it should be an odd prime\n");
  fi;

  if orderb = 3 then
    # we can guarantee a slightly longer head
    whead := SetConstFromOption("head", a*b*a*b*a/b);
  else
    whead := SetConstFromOption("head", a*b); # a*b*a/b often works
  fi; 

  orderS := Order(Group(permSgens));
  Print("GroupOrder=", orderS, " SubgroupIndex=", idx, "\n");

  return rec(gens := Fgens, 
             rels := [a^2, b^orderb, NewRelator(permSgens)],
             sgens := sgens);
end;

ClassesGenPairs := function(G, orderx, ordery)
##  Finds generator pairs for G of orders orderx and ordery.
local a, b, p, h, cla, clb, ai, bi, ra, rb, cena, cenb, gens, u, dc, j;
  a := AutomorphismGroup(G);
  p := IsomorphismPermGroup(a);
  b := Image(p, a);
  h := Image(p, InnerAutomorphismsAutomorphismGroup(a));
  cla := Filtered(ConjugacyClasses(b),
                  i -> Order(Representative(i)) = orderx 
                       and Representative(i) in h);
  clb := Filtered(ConjugacyClasses(b),
                  i -> Order(Representative(i)) = ordery
                       and Representative(i) in h);
  gens := [];
  for ai in cla do
    cena := Centralizer(ai);
    ra := Representative(ai);
    for bi in clb do
      cenb := Centralizer(bi);
      rb := Representative(bi);
      dc := List(DoubleCosetRepsAndSizes(b, cenb, cena), Representative);
      for j in dc do
        u := Subgroup(b, [ra, rb^j]);
        if Index(h, u)=1 then
          Add(gens, [ConjugatorInnerAutomorphism(
                         PreImagesRepresentative(p, ra)
                         ), 
                     ConjugatorInnerAutomorphism(
                         PreImagesRepresentative(p, rb^j)
                         )
                    ]);
        fi;
      od;
    od;
  od;
  return gens;
end;

# Global variables used in TranslatePresentation
newF := FreeGroup("x", "y"); x := newF.1; y := newF.2;

TranslatePresentation := function(Fgens, rels, sgens, newgens)
##  For the *simple* quotient q = F/rels where F is a  free  group  with  two
##  generators Fgens, and the subgroup of q generated by the words  in  Fgens
##  in the list sgens and a pair of new generators newgens for q, in terms of
##  Fgens, returns a record with fields gens, rels, sgens where gens = [x, y]
##  represent  the  new  generators  newgens,  <gens  |  rels>  is  the   new
##  presentation (rels is a list of words in x and y) and sgens is  the  list
##  of subgroup words of the input sgens, but in terms of x and y. The  first
##  new generator newgens[1] should be an involution.
##
local F, t, Permqgens, Permqnewgens, ValueInPermq, orderx, ordery,
      q, p, newFgens, n, nrels, Prune, CheckOrders, xwords,
      ywords, xywords, xyValueInPermq, Permqvalues, MakeNewWords,
      xyFgens, unboundi, xyList, i;
  if Length(Fgens) <> 2 then
    Error("Free group of first argument should have 2 generators");
  fi;

  # We create an initial permutation representation . . . . . . . . . .
  # Since q = F/rels is a simple group,  the permutation representation
  # Permq of q's action on the right cosets of a large subgroup of q is
  # isomorphic to q itself i.e. 
  #   
  #    phi : q           -> Permq
  #          [q.1, q.2] |-> [Permqgens[1], Permqgens[2]]
  #
  # is an isomorphism. Word calculations using this permutation repres-
  # entation are far more efficient than using a free presentation.
  t := CosetTableFromGensAndRels(Fgens, rels, sgens : acenow, aceignoreu);
  Permqgens := List(t{[1,3..Length(t)-1]}, PermList);
  Permqnewgens := List(newgens, i -> MappedWord(i, Fgens, Permqgens));

  # Value of a word in the generators of F in Permq
  ValueInPermq := w -> MappedWord(w, Fgens, Permqgens);

  # The group output will be on generators x and y
  # i.e. think of newgens[1] as x, and newgens[2] as y
  # (or in the Permq representation Permqnewgens[1] represents x etc.)
  orderx := Order(Permqnewgens[1]);

  if orderx <> 2 then
    Error("First new generator should be an involution");
  fi;
  
  ordery := Order(Permqnewgens[2]);

  F := GroupWithGenerators(Fgens);
  q := F/rels;

  # New presentation in terms of newgens
  p := PresentationSubgroupMtc(
           q, 
           Subgroup(
               q, 
               List(newgens,
                    w -> MappedWord(w, Fgens, GeneratorsOfGroup(q)) )
               )
           );
  TzGoGo(p);

  newFgens := GeneratorsOfGroup(newF);
  n := FpGroupPresentation(p);
  nrels := 
      Union(List(RelatorsOfFpGroup(n),
                 w -> MappedWord(w, FreeGeneratorsOfFpGroup(n), newFgens)
                 ),
            # Ensure presentation contains relators giving generator
            # orders
            List([1..2], i->newFgens[i]^Order(Permqnewgens[i])) 
            );

  # Calculate x,y-expressions xyFgens for the old generators Fgens.
  # We need these to rewrite sgens in terms of x and y.
  # This is of course hidden in the rewriting code, 
  # but there is no proper interfacing function yet. 
  # So we recursively generate x,y-words until we find what we want.
  # This could be expensive!

  Prune := u -> u{[1..Length(u)-1]};
  
  CheckOrders := o -> Prune(Concatenation([1,-1], [2..o-1])); 

  xwords := List(CheckOrders(orderx), i -> x^i);
  ywords := List(CheckOrders(ordery), i -> y^i);

  # Initialise xywords to the words in x,y of one syllable
  # ... the first component has words ending in an x-syllable, 
  #     the second component has words ending in a y-syllable.
  xywords := [xwords, ywords];

  # The value of an x,y-word in Permq
  xyValueInPermq := w -> MappedWord(w, newFgens, Permqnewgens);

  # Permqvalues contains the values in Permq of all x,y-words that
  # have been generated.
  Permqvalues := List(Concatenation(xywords), w -> xyValueInPermq(w));

  # Adds one extra x- or y- syllable to each x,y-word in xywords,
  # omitting any words that have Permqvalues we've met already.
  # Permqvalues is also updated.
  MakeNewWords := function()
    local NewWords, i;

    NewWords := function(wlist, words)
      return Concatenation(
                 List(wlist, wl -> List(words, word -> wl * word))
                 );
    end;
    
    xywords := [ NewWords(xywords[2], xwords),
                 NewWords(xywords[1], ywords) ];
    for i in [1,2] do
      xywords[i] := Filtered(xywords[i], 
                             w -> not(xyValueInPermq(w) in Permqvalues));
      Permqvalues := Concatenation(Permqvalues, 
                                   List(xywords[i], 
                                        w -> xyValueInPermq(w)));
    od;
  end;

  xyFgens := [];
  unboundi := [1,2]; # The list of indices i of xyFgens for which
                     # xyFgens[i] is unbound i.e. not known yet.

  repeat
    for i in unboundi do
      # See if one of our latest x,y-words represents Permqgens[i]
      xyList := Filtered(Concatenation(xywords),
                         w -> xyValueInPermq(w) = Permqgens[i]);
      if not(IsEmpty(xyList)) then
        xyFgens[i] := xyList[1];
      fi;
    od;
    unboundi := Filtered(unboundi, i -> not(IsBound(xyFgens[i])));
    if not(IsEmpty(unboundi)) then
      MakeNewWords();
    fi;
  until IsEmpty(unboundi);

  return rec(fgens := [x, y],
             rels := nrels,
             sgens := List(sgens, w -> MappedWord(w, Fgens, xyFgens)) );

end;

F := FreeGroup("a","b");     a := F.1;    b := F.2;

# The presentations below have been obtained from:
#   [CCN85] J.H. Conway et al, `Atlas of Finite Groups'
#   [CMY79] John J. Cannon, John McKay, Kiang-chuen Young,
#           `The non-abelian Simple groups G, |G| < 10^5',
#           Comm. Alg. 7(13), 1397-1406 (1979).
#   [CR84]  Colin M. Campbell and Edmund F. Robertson,
#           `Presentations for the Simple groups G, 10^5 < |G| < 10^6',
#           Comm. Alg. 12(21), 2643-2663 (1984).
#   [Bray]  John Bray's web site: http://www.cix.co.uk/~vicarage/

L2_8 := rec( source := "[CCN85, p6]",
             rels := [a^7, (a^2*b)^3, (a^3*b)^2, (a*b^5)^2],
             sgens := [a] );

L2_16 := rec( source := "[CCN85, p12]",
              rels := [a^15, (a^2*b)^3, (a^3*b)^2, (a*b^9)^2,
                       (a^8*b^2)^2, b^17 ],
              sgens := [a] );

L3_3s := [# L_3(3), 1
          rec( source := "[CMY79, 5.1]",
               rels := [a^2, b^3, (a*b)^13, 
                        ((a*b)^4*a*b^-1)^2*(a*b)^2*(a*b^-1)^2*
                         (a*b)*(a*b^-1)^2*(a*b)^2*a*b^-1], 
               sgens := [a^(b*a), b] ),

          # L_3(3), 2 
          rec( source := "[CMY79, 5.2]",
               rels := [a^2, b^3, (a*b)^13, (Comm(a,b))^6,
                        ((a*b)^2*(a*b^-1)^2)^3],
               sgens := [a^(b*a), b^(a*b)] ),

          # L_3(3), 3 
          rec( source := "[CCN85, p13]",
               rels := [a^6, b^3, (a*b)^4, (a^2*b)^4, (a^3*b)^3,
                        Comm(a^2,(b*a^2*b)^2)], 
               sgens := [a] )
          ];

U3_3s := [# U_3(3), 1 
          rec( source := "[CMY79, 6.1]",
               rels := [a^2, b^6, (a*b)^7, (a*b^2)^3*(a*b^-2)^3,
                        (a*b*a*b^-2)^3*a*b*(a*b^-1)^2], 
               sgens := [a^b, a*b*a*b*a*b^-2] ),

          # U_3(3), 2 
          rec( source := "[CMY79, 6.2]",
               rels := [a^2, b^6, (a*b)^8, (Comm(a,b))^4, (a*b^3)^3,
                        (a*b^2)^3*(a*b^-2)^3, ((a*b)^2*a*b^2)^3], 
               sgens := [a, a^b*b] )
          ];

M11 := rec( source := "[CMY79, 7.1]",
            rels := [a^2, b^4, (a*b)^11, (a*b^2)^6,
                     (a*b)^2*(a*b^-1)^2*a*b*a*b^-1*a*b^2*a*b*a*b^-1],
            sgens := [a, b^((a*b)^2)] );

M12 := rec( source := "[Bray, M=C2]",
            rels := [a^2, b^3, (a*b)^11, (Comm(a,b))^6,
                     (a*b)^8*(a*b^-1)^2*(a*b*a*b^-1)^4*a*b^-1,
                     (a*b*a*b*a*b^-1)^6],
            sgens := [a, b*a*b*a*b*a*b^-1] );

L2_32 := rec( source := "[CCN85, p29]",
              rels := [a^31, (a^2*b)^3, (a^3*b)^2, (a*b^6)^2,
                       (a^2*b^4*a^4*b^5)^2, (a^2*b^5*a^4*b^4)^2 ],
              sgens := [a] );

U3_4s := [# U_3(4), 1 
          rec( source := "[CMY79, 12.1]",
               rels := [a^2, b^3, (a*b)^13,
                        a*b*(a*b^-1)^2*(a*b)^2*a*b^-1*a*b*(a*b^-1)^4*
                         a*b*a*b^-1*(a*b)^4*a*b^-1],
               sgens := [(a*b)^5*a, (a*b)^2*a*b^-1*a*b*(a*b^-1)^2*a,
                        (a*b*(a*b^-1)^2)^2,
                        a*b*a*b^2*(a*b)^2*(a*b^-1)^2*a*b] ),

          # U_3(4), 2 
          rec( source := "[CMY79, 12.2]",
               rels := [a^2, b^3, (a*b)^15, (Comm(a,b))^5,
                        ((a*b)^3*(a*b^-1)^3)^3, (a*b^-1*(a*b)^5)^4],
               sgens := [a*b*a*b^2*a*b^-1*a*b*a, b*a*b*(a*b^-1)^3*a*b])
          ];

J1s := [#J1, 1  
        rec( source := "[CR84, 15.1]",
             rels := [a^2, b^3, (a*b)^7, (Comm(a,b))^10,
                      (Comm(a, b^-1*(a*b)^2))^6],
             sgens := [a, b^(a*b*(a*b^-1)^2)] ),

        #J1, 2  
        rec( source := "[CR84, 15.3]",
             rels := [a^2, b^3, (a*b)^7, ((a*b)^2*a*b^-1)^11,
                      (Comm(a,b*(a*b^-1)^2))^5],
             sgens := [a, b^(a*b^-1)] ),

        #J1, 3  
        rec( source := "[CR84, 15.5]",
             rels := [a^2, b^3, (a*b)^7, (Comm(a,b))^15,
                      (Comm(a,b^-1*(a*b)^2))^5,
                      ((a*b*a*b^-1)^2*a*b)^6],
             sgens := [a, b^((a*b^-1*a*b)^2*a*b^-1)] ),

        #J1, 4  
        rec( source := "[CR84, 15.7]",
             rels := [a^2, b^3, (a*b)^7, ((a*b*a*b^-1)^3*a*b)^5,
                      ((a*b*a*b^-1)^3*(a*b^-1*a*b)^3)^3],
             sgens := [a, b^((a*b^-1*a*b)^2*a*b^-1*(a*b)^2)] ),

        #J1, 5  
        rec( source := "[CR84, 15.8]",
             rels := [a^2, b^3, (a*b)^10, (Comm(a, b^-1*a*b^-1*(a*b)^3))^2,
                      ((a*b)^3*(a*b*a*b^-1)^2*(a*b)^2*(a*b^-1)^2)^3],
             sgens := [a, b^((a*b^-1)^3)] ),

        #J1, 6  
        rec( source := "[CR84, 15.10]",
             rels := [a^2, b^3, (a*b)^10, ((a*b)^2*a*b^-1)^7,
                      (Comm(a, b*a*b^-1*(a*b)^3))^2],
             sgens := [a, b^(a*b^-1*a*b*(a*b^-1)^2)] ),

        #J1, 7  
        rec( source := "[CR84, 15.12]",
             rels := [a^2, b^3, (a*b)^10, (Comm(a, b*a*b*(a*b^-1)^3))^2,
                      ((a*b)^4*a*b^-1*a*b*(a*b*a*b^-1)^2)^3],
             sgens := [a, b^(a*b^-1*a*b*a*b^-1)] ),

        #J1, 8  
        rec( source := "[CR84, 15.14]",
             rels := [a^2, b^3, (a*b)^10, ((a*b)^2*a*b^-1)^5,
                      ((a*b)^2*(a*b*a*b^-1)^2*(a*b)^2*(a*b^-1)^3)^3],
             sgens := [a, b^(a*b*(a*b^-1)^2*(a*b)^2)] ),

        #J1, 9  
        rec( source := "[CR84, 15.15]",
             rels := [a^2, b^3, (a*b)^10, ((a*b)^3*(a*b^-1)^2)^5,
                      ((a*b)^2*(a*b*a*b^-1)^2*(a*b)^2*(a*b^-1)^3)^3],
             sgens := [a, b^(a*b*(a*b^-1)^2*(a*b)^2)] ),

        #J1, 10  
        rec( source := "[CR84, 15.16]",
             rels := [a^2, b^3, (a*b)^11, ((a*b)^2*(a*b^-1)^2)^5,
                      ((a*b)^4*(a*b^-1)^3*(a*b)^2*(a*b^-1)^4)^2],
             sgens := [a, b^(a*b^-1*a*b*(a*b^-1)^2*a*b)] ),

        #J1, 11  
        rec( source := "[CR84, 15.18]",
             rels := [a^2, b^3, (a*b)^11, ((a*b)^2*a*b^-1)^6,
                      ((a*b)^4*(a*b^-1)^3)^3],
             sgens := [a, b^((a*b^-1)^2*(a*b)^2)] ),

        #J1, 12  
        rec( source := "[CR84, 15.19]",
             rels := [a^2, b^3, (a*b)^15, (Comm(a,b))^5,
                      ((a*b)^4*(a*b^-1)^2)^5,
                      ((a*b)^2*((a*b^2)*(a*b^-1)^2)^2)^3],
             sgens := [a, b^((a*b^-1)^3*(a*b)^2)] ),

        #J1, 13  
        rec( source := "[CR84, 15.20]",
             rels := [a^2, b^3, (Comm(a,b))^6, ((a*b)^2*a*b^-1)^7,
                      (Comm(a, b^-1*(a*b)^3))^2],
             sgens := [a, b^(a*b*(a*b^-1)^4)] ),

        #J1, 14  
        rec( source := "[CR84, 15.22]",
             rels := [a^2, b^3, (a*b)^15, (Comm(a, b*a*b))^5,
                      ((a*b)^5*(a*b^-1*a*b*a*b^-1)^2*a*b^-1)^2,
                      ((a*b)^3*((a*b)^2*a*b^-1)^2*(a*b^-1*a*b)^2)^2],
             sgens := [a, b^(a*b^-1)] ),

        #J1, 15  
        rec( source := "[CR84, 15.24]",
             rels := [a^2, b^3, (a*b)^15, (Comm(a, b*a*b))^5,
                      ((a*b)^2*a*b^-1)^6, ((a*b)^5*a*b^-1)^7,
                      (Comm(a, (b*a)^2*(b^-1*a)^3*b))^2],
             sgens := [a, b^((a*b)^3*a*b^-1)] ),

        #J1, 16  
        rec( source := "[CR84, 15.26]",
             rels := [a^2, b^3, (a*b)^15, (Comm(a, b*a*b))^3,
                      ((a*b)^4*(a*b^-1)^2)^5,
                      ((a*b)^4*(a*b^-1*a*b)^2*(a*b^-1)^2*a*b*(a*b^-1)^3)^2],
             sgens := [a, b^(a*b)] ),

        #J1, 17  
        rec( source := "[CR84, 15.27]",
             rels := [a^2, b^3, (a*b)^19, ((a*b)^3*(a*b^-1*a*b)^4)^2,
                      (((a*b)^4*a*b^-1)^2*a*b^-1)^2],
             sgens := [a, b^(a*b^-1*(a*b)^4)] ),

        #J1, 18  
        rec( source := "[CR84, 15.28]",
             rels := [a^2, b^3, (a*b)^19, ((a*b)^2*(a*b*a*b^-1)^2)^2,
                      (((a*b)^4*a*b^-1)^2*a*b^-1)^3],
             sgens := [a, b^((a*b)^2)] ),

        #J1, 19  
        rec( source := "[CR84, 15.29]",
             rels := [a^2, b^3, (a*b)^19, ((a*b)^2*a*b^-1)^6,
                      ((a*b)^3*a*b^-1)^6, (Comm(a, (b*a)^4*b^-1*a*b))^2,
                      ((a*b)^4*a*b^-1*a*b*(a*b^-1)^3*(a*b)^2*a*b^-1)^2],
             sgens := [a, b^((a*b^-1*a*b)^2*a*b^-1*(a*b)^2)] ),

        #J1, 20  
        rec( source := "[CR84, 15.31]",
             rels := [a^2, b^3, (a*b)^19, (Comm(a, b*(a*b)^2))^3,
                      ((a*b)^5*((a*b)^2*a*b^-1)^2)^2],
             sgens := [a, b^(a*b*a*b^-1*(a*b)^2)] ),

        #J1, 21  
        rec( source := "[CR84, 15.32]",
             rels := [a^2, b^3, (a*b)^19, (Comm(a, b*a*b))^3,
                      ((a*b)^3*(a*b*a*b^-1)^2)^3],
             sgens := [a, b^((a*b)^5)] )
        ];

L3_5s := [# L_3(5), 1 
          rec( source := "[CR84, 17.1]",
               rels := [a^2, b^3, (a*b)^24, Comm(a,b)^6, 
                        ((a*b)^6*(a/b)^2)^3, ((a*b)^3*(a*b*a/b)^2)^5,
                        ((a*b)^5*(a/b*a*b)^2*(a*b)^2*(a*b*a/b)^2)^2],
               sgens := [a, (b*a*b)^(a*b)] ),

          # L_3(5), 2 
          rec( source := "[CR84, 17.2]",
               rels := [a^2, b^3, (a*b)^24, Comm(a,b)^10, 
                        Comm(a,b*a*b)^3, Comm(a,b*(a*b)^2)^4,
                        ((a*b*a/b)^3*a*b)^5,((a*b)^2*((a*b)^2*a/b)^2)^3],
               sgens := [a, (b*a*b)^(a*b*a/b)] ),

          # L_3(5), 3 
          rec( source := "[CR84, 17.3]",
               rels := [a^2, b^3, (a*b)^31, Comm(a,b)^4, 
                        ((a*b)^4*a/b)^4, Comm(a,b*(a*b)^4)^3],
               sgens := [a, (b^-1*a)^3*b*(a*b*a/b)^2] ),

          # L_3(5), 4 
          rec( source := "[CR84, 17.4]",
               rels := [a^2, b^3, (a*b)^31, Comm(a,b)^5, 
                        ((a*b)^5*(a/b)^4)^2, ((a*b)^6*(a/b)^2)^3],
               sgens := [a^b, (b*a)^3/b*a] ),

          # L_3(5), 5 
          rec( source := "[CR84, 17.5]",
               rels := [a^2, b^3, (a*b)^31, Comm(a,b)^6, 
                        Comm(a,b*(a*b)^2)^3, Comm(a,b*(a*b)^3)^3,
                        ((a*b)^3*(a*b*a/b)^2)^3],
               sgens := [a, b*a/b*a*b*a*b] ),

          # L_3(5), 6 
          rec( source := "[CR84, 17.6]",
               rels := [a^2, b^3, (a*b)^31, 
                        (a*b)^9*a/b*a*b*((a/b)^3*a*b)^3*a/b,
                        (a*b)^4*(a*b*a/b)^2*(a*b)^5*(a/b)^4*
                         (a*b*a/b)^2*(a/b)^3],
               sgens := [a^(b*a), b*a*(a^(b*a*b))] ),

          # L_3(5), 7 
          rec( source := "[CR84, 17.7]",
               rels := [a^2, b^3, (a*b)^31, Comm(a,b*a*b)^4, 
                        Comm(a,b^-1*(a*b)^2)^6, ((a*b)^5*(a/b)^2)^3, 
                        ((a*b)^3*(a/b)^2)^5],
               sgens := [a*b*a/b, b^-1*(a*b)^5*a/b*(a*b)^3] )
          ];

PSp4_4s := [#PSp(4,4), 1 
            rec( source := "[CR84, 20.1]",
                 rels := [a^2, b^5, Comm(a,b)^5, (a*b^2)^17, 
                          Comm(a,b^2)^2, ((a*b)^2*a/b^2)^4],
                 sgens := [b*(b*a)^3/b*a, (a/b*a*b)^2*b] ),

            #PSp(4,4), 2 
            rec( source := "[CR84, 20.2]",
                 rels := [a^2, b^5, (a*b)^17, Comm(a,b)^2, 
                          Comm(a,b^2)^5, (a*b*(a*b^2)^2)^4, 
                          Comm(a,b^2*a*b*a*b^2)^2],
                 sgens := [a*b^2*(a*b)^3, (b^2*a)^5*b] ),

            #PSp(4,4), 3 
            rec( source := "[CR84, 20.3]",
                 rels := [a^2, b^5, (a*b)^17, Comm(a,b)^5,
                          Comm(a,b*a*b)^3, Comm(a,(b*a)^2/b)^2,
                          Comm(b^-1*a*b,(b*a)^2)^2],
                 sgens := [b^2*(a*b)^4*b, a/b*(a*b^2*a*b^-2)^2] ),

            #PSp(4,4), 4 
            rec( source := "[CR84, 20.4]",
                 rels := [a^2, b^4, Comm(a,b)^4, (a*b)^15,
                          (a*b*(a*b^2)^4*a*b^-1*(a*b^2)^2)^2,
                          (a*b)^2*(a*b^2)^4*(a*b^-1)^2*(a*b^2)^2*
                          a*b*a*b^2*a*b^-1*(a*b^2)^2],
                 sgens := [a*b^2, a^(b^-1*a*b^-1*a*b)*a*b] ),
                 
            #PSp(4,4), 5 
            rec( source := "[CR84, 20.6]",
                 rels := [a^2, b^4, (a*b)^15, 
                          ((a*b*(a*b^2)^2)^2*b)^2,
                          ((a*b*a*b^-1*a*b)^2*b)^2,
                          ((a*b*a*b^2*a*b)^2*b*a*b^-1)^3,
                          ((a*b*a*b^-1)^2*(a*b^2)^2*a*b^-1*(a*b^2)^2)^2,
                          ((a*b*a*b^2)^2*(a*b^2*a*b^-1)^2*a*b^-1)^2,
                          ((a*b)^4*b*a*b*a*b^-1*a*b^2*(a*b)^2*a*b^-1)^2],
                 sgens := [a*b, b^(a*b*a*b^-1)*a*b^-1] ),
                 
            #PSp(4,4), 6 
            rec( source := "[CR84, 20.8]",
                 rels := [a^2, b^4, (a*b)^15, 
                          ((a*b)^2*(a*b*(a*b^2)^2)^2)^2,
                          ((a*b)^2*(a*b^-1*a*b^2)^2*a*b^2)^3,
                          ((a*b)^3*b)^4,
                          (((a*b)^4*b)^2*a*b^2)^2,
                          ((a*b*a*b^-1)^2*a*b^-1*a*b^2*(a*b^-1)^2)^2],
                 sgens := [a*b, (b*a*b^2*a)^2*b^(a*b^-1)] ),
                 
            #PSp(4,4), 7 
            rec( source := "[CR84, 20.9]",
                 rels := [a^2, b^4, (a*b)^15, 
                          (((a*b)^3*b)^2*a*b^-1)^2,
                          ((a*b)^2*(a*b^-1)^2*b^-1)^5,
                          ((a*b*a*b^2*(a*b^-1)^2)^2*b^-1)^2,
                          ((a*b)^2*a*b^-1*a*b*a*b^2*a*b^-1*a*b^2)^2],
                 sgens := [a*b, a^(b^2)*(a*b^-1)^3] ),
                 
            #PSp(4,4), 8 
            rec( source := "[CR84, 20.11]",
                 rels := [a^2, b^4, Comm(a,b)^4, (a*b)^17,
                          ((a*b)^2*(a*b^2)^2*a*b^-1)^3,
                          (a*b*(a*b^2*(a*b)^2*a*b^-1)^2)^2,
                          ((a*b)^6*b*(a*b^-1)^2*a*b*a*b^2)^2,
                          ((a*b)^2*a*b^-1*a*b*a*b^2*a*b*(a*b^2)^3)^2],
                 sgens := [a*b^2*a*b^-1, (b^2*a)^3*b^(a*b^-1)] ),
                 
            #PSp(4,4), 9 
            rec( source := "[CR84, 20.13]",
                 rels := [a^2, b^4, (a*b)^17,
                          (a*b*(a*b^2)^3*a*b^-1)^3,
                          ((a*b^-1*a*b)^2*(a*b*a*b^-1)^2*b^-1*a*b^2)^2,
                          Comm(a,b)^6, 
                          ((a*b^2)^3*(a*b)^3*a*b^-1*a*b)^2,
                          (a*b)^3*((a*b)^3*(b*a)^2*b^-1)^2*(a*b^-1)^2],
                 sgens := [a*b^2*a*b*a*b, (b^2*a)^3*a^(b*a*b)] ),
                 
            #PSp(4,4), 10 
            rec( source := "[CR84, 20.15]",
                 rels := [a^2, b^4, (a*b)^17,
                          ((a*b)^2*a*b^-1)^4,
                          (a*b*a*b^2*a*b^-1)^5,
                          (a*b*(a*b^-1)^2*(a*b^2)^2*a*b^-1)^2,
                          (a*b*a*b^-1*(a*b^2)^3*a*b^-1*(a*b^2)^2)^2],
                 sgens := [a*b^2*a*b^-1, (a*b^2)^4*a*b] ),
                 
            #PSp(4,4), 11 
            rec( source := "[CR84, 20.17]",
                 rels := [a^2, b^4, (a*b)^17,
                          Comm(a,(b*a*b)^2)^2,
                          ((a*b*a*b^-1)^2*a*b^2)^5,
                          (a*b*(a*b^2)^2*a*b^-1*(a*b^2)^2*a*b*a*b^-1)^2,
                          ((a*b)^3*b*a*b*a*b^-1*a*b*(a*b^2)^2*a*b^-1)^2],
                 sgens := [a*b*a*b^-1, (b^2*a)^2*b*a] ),
                 
            #PSp(4,4), 12 
            rec( source := "[CR84, 20.18]",
                 rels := [a^2, b^4, (a*b)^17,
                          ((a*b)^2*(a*b^-1*a*b^2)^2*a*b*a*b^2)^2,
                          (a*b*(a*b^2)^2)^4,
                          ((a*b)^2*b)^6,
                          ((a*b)^4*(b*a)^2*b^-1*(a*b)^2*b)^2,
                          (a*b*((a*b)^2*b)^2*a*b*a*b^-1*a*b^2)^3],
                 sgens := [(a*b)^2*a*b^-1, a*b^2] ),
                 
            #PSp(4,4), 13
            rec( source := "[CR84, 20.19]",
                 rels := [a^2, b^4, (a*b)^5,
                          Comm(b,(a*b^2)^4*a)^2,
                          (a*b*a*b^2*a*b^-1*(a*b^2)^4)^3,
                          (a*b^-1*a*b^2*a*b*(a*b^2)^4)^3,
                          (a*b^-1*(a*b^2)^2*a*b*a*b^-1*a*b*(a*b^2)^2)^3],
                 sgens := [(a*b^2*a*b)^2*b^2, a*b^-1*a*(b^2*a)^3*b*a*b^-1] ),
                 
            #PSp(4,4), 14 
            rec( source := "[CR84, 20.20]",
                 rels := [a^2, b^4, (a*b)^15,
                          Comm(a,b)^5,
                          (a*b^2)^15,
                          ((a*b)^2*(a*b^-1)^2*a*b^2)^2,
                          ((a*b)^2*a*b^-1*a*b*a*b^2)^4,
                          ((a*b)^4*a*b^2*a*b^-1*(a*b^2)^3)^2,
                          (a*b)^4*(b*a*b*a*b^-1*a*b^2)^2*(a*b)^3*
                           b*a*b^2*(a*b^-1*a*b)^2],
                 sgens := [a*b^2, (b*a*b^2*a*b*a)^2*b^-1] ),
                 
            #PSp(4,4), 15 
            rec( source := "[CR84, 20.22]",
                 rels := [a^2, b^4, (a*b)^15,
                          (a*b^2)^6,
                          ((a*b)^3*b)^4,
                          Comm(a,b*(a*b)^2)^2,
                          ((a*b)^3*(b*a)^2*b^-1*(a*b^2)^2)^3],
                 sgens := [a*b*a*b^-1, a*b^2*(a*b)^5] ),
                 
            #PSp(4,4), 16 
            rec( source := "[CR84, 20.23]",
                 rels := [a^2, b^4, (a*b)^15,
                          (a*b^2)^6,
                          ((a*b)^2*a*b^-1)^4,
                          (a*b*(a*b^2)^2)^4,
                          Comm(a,(b*a*b)^2)^2,
                          ((a*b*a*b^-1)^2*a*b^2*a*b^-1*a*b)^3],
                 sgens := [a*b, (b^2*a*b^-1*a)^2*b^2] ),
                 
            #PSp(4,4), 17 
            rec( source := "[CR84, 20.24]",
                 rels := [a^2, b^4, (a*b)^15,
                          (a*b^2)^5,
                          Comm(a,b*a*b)^4,
                          ((a*b)^4*(b*a)^2*b^-1*a*b^2)^2],
                 sgens := [(a*b)^3*a*b^-1, (b^2*a)^2*b*a*b^-1] ),
                 
            #PSp(4,4), 18 
            rec( source := "[CR84, 20.26]",
                 rels := [a^2, b^4, (a*b)^15,
                          Comm(a,b)^17,
                          (a*b^2)^10,
                          (a*b*(a*b^2)^2*(a*b^-1*a*b)^2*b)^3,
                          ((a*b)^2*a*b^2)^2*(a*b)^3*(a*b^-1*a*b)^3,
                          (a*b*(a*b^2)^3*a*b*a*b^-1*a*b^2*a*b^-1)^2],
                 sgens := [a*b, a^(b^2)] ),
                 
            #PSp(4,4), 19 
            rec( source := "[CR84, 20.27]",
                 rels := [a^2, b^4, (a*b)^17,
                          (a*b^2)^10,
                          ((a*b)^4*b)^4,
                          ((a*b)^2*(b*a)^2*b^-1)^2,
                          ((a*b)^2*(a*b^2)^3*(a*b^-1)^3)^3],
                 sgens := [(a*b)^2*a*b^-1, b*(a*b^2)^4] ),
                 
            #PSp(4,4), 20 
            rec( source := "[CR84, 20.28]",
                 rels := [a^2, b^4, (a*b)^17,
                          (((a*b)^2*a*b^2)^2*(a*b^2)^2)^2,
                          ((a*b)^2*a*b^2*(a*b^-1)^2)^3,
                          (a*b^2)^10,
                          ((a*b^-1*a*b)^3*(b^2*a)^2*b^-1)^2,
                          ((a*b^-1*a*b^2)^3*b^-1*a*b^2*a*b)^2],
                 sgens := [a*b*a*b^-1*a*b*a*b*a*b^-1, a*b^2*a*b] ),
                 
            #PSp(4,4), 21 
            rec( source := "[CR84, 20.29]",
                 rels := [a^2, b^4, (a*b)^17,
                          (a*b*(a*b^2)^3*a*b^-1)^3,
                          (a*b*(a*b^2)^4*a*b*a*b^-1*(a*b^2)^2)^2,
                          a*b*(a*b^2)^3*(a*b*a*b^-1)^2*(a*b^2)^3*
                           a*b^-1*(a*b^2)^3],
                 sgens := [a*b*a*b^-1, b^-1*(a*b)^3*b*a*b^-1] ),
                 
            #PSp(4,4), 22 
            rec( source := "[CR84, 20.31]",
                 rels := [a^2, b^4, (a*b)^17,
                          (a*b*a*b^-1*a*b^2)^3,
                          ((a*b)^3*b*a*b*(a*b^-1)^2*(a*b^2)^3)^2,
                          ((a*b)^3*b*a*b*a*b^-1*(a*b*a*b^2)^2)^2,
                          (a*b)^2*a*b^-1*(a*b^2)^5*a*b*(a*b^-1)^2*
                           a*b^2*a*b^-1*a*b*a*b^2],
                 sgens := [a*b^2, a*b*a*b^-1*a*b*a*b] )
            ];

presentations := rec( L2_8 := L2_8,
                      L2_16 := L2_16,
                      L3_3s := L3_3s,
                      U3_3s := U3_3s,
                      M11 := M11,
                      M12 := M12,
                      L2_32 := L2_32,
                      U3_4s := U3_4s,
                      J1s := J1s,
                      L3_5s := L3_5s,
                      PSp4_4s := PSp4_4s );

IsACEResExampleOK := function()
##  does a number of integrity checks and tries to give an accurate diagnosis
##  if something is wrong.
local head, grp, n, newgens, ok, saved,
      IsFunctionsOK, IsGensOK, IsGroupOK, IsNewgensOK, IsnOK;
  head := ValueOption("head");
  grp := ValueOption("grp");
  n := ValueOption("n");
  newgens := ValueOption("newgens");
  saved := ACEResExample;

  IsFunctionsOK := function()
    return IsBound(PGRelFind) and IsFunction(PGRelFind) and
           IsBound(TranslatePresentation) and
           IsFunction(TranslatePresentation);
  end;

  IsGensOK := function(u, v)
    return (FamilyObj(u) = FamilyObj(v)) and IsAssocWordWithInverse(u) and
           ForAll([u, v], g -> (NumberSyllables(g) = 1) and
                               (ExponentSyllable(g, 1) = 1));
  end;

  IsGroupOK := function()
    return (grp <> fail) and IsBound(presentations) and
           IsRecord(presentations) and (grp in RecNames(presentations));
  end;

  IsnOK := function()
    return (grp[Length(grp)] <> 's') or 
           (IsPosInt(n) and (n <= Length( presentations.(grp) ))); 
  end;

  IsNewgensOK := function()
    return IsBound(a) and IsBound(b) and IsGensOK(a, b) and
           (newgens = fail or 
            (IsList(newgens) and (Length(newgens) = 2) and
             (ForAll(newgens, w -> FamilyObj(w) = FamilyObj(a)))));
  end;

  ok := false;
  if ACEResExample.filename = "doGrp.g" and not IsFunctionsOK() then
    Print("Error, ACEReadResearchExample: functions not initialised.\n",
          "Please type: 'ACEReadResearchExample();'\n",
          "and try again.\n");
  elif ACEResExample.filename = "doGrp.g" and
       not(IsGroupOK() and IsnOK() and IsNewgensOK()) then
    ACEResExample.reread := true;
    RequirePackage("ace", "3.0");
    ACEReadResearchExample("pgrelfind.g");
    ACEResExample := saved;
    Unbind(ACEResExample.reread);
    Print("Error, ",
          "`grp' (and maybe `n' and/or `newgens') options must have values.\n",
          "Usage: ACEReadResearchExample(\"doGrp.g\"\n",
          "                              : grp := <grp>,\n",
          "                                [n := <int>,]\n",
          "                                [newgens := [<w1>, <w2>]]\n",
          "                                [, opt := <val> ...]);\n",
          "where <grp> must be a string in the following list:\n",
          RecNames(presentations),"\n",
          "and <w1>, <w2> must be words in `a' and `b'.\n");
  elif head <> fail and not(IsBound(x) and IsBound(y) and IsGensOK(x, y)) then
    Print("Error, `x' and `y' do not have correct values.\n",
          "Please type: 'ACEReadResearchExample();'\n",
          "to (re-)initialise `x' and `y' and try your call of\n",
          "'ACEReadResearchExample(", ACEResExample.filename, ");' again.\n");
  else
    ok := true;
  fi;
  if ok then
    if ACEResExample.filename = "doGrp.g" then
      if grp[ Length(grp) ] = 's' then
        ACEResExample.grp := presentations.(grp)[n];
      else
        ACEResExample.grp := presentations.(grp);
      fi;
      ACEResExample.newgens := newgens;
    elif not(IsFunctionsOK() and IsBound(a) and IsBound(b) and 
             IsGensOK(a, b)) then
      ACEResExample.reread := true;
      RequirePackage("ace", "3.0");
      ACEReadResearchExample("pgrelfind.g");
      ACEResExample := saved;
      Unbind(ACEResExample.reread);
    fi;
  fi;
  return ok;
end;

## End
if not(IsBound(ACEResExample.reread) and ACEResExample.reread) then
  for s in ["The following are now defined:",
            "",
            "Functions:",
            "  PGRelFind, ClassesGenPairs, TranslatePresentation,",
            "  IsACEResExampleOK",
            "Variables:",
            "  ACEResExample, ALLRELS, newrels, F, a, b, newF, x, y,",
            "  L2_8, L2_16, L3_3s, U3_3s, M11, M12, L2_32,",
            "  U3_4s, J1s, L3_5s, PSp4_4s, presentations",
            "",
            "Also:",
            "",
            "TCENUM = ACETCENUM  (Todd-Coxeter Enumerator is now ACE)",
            "",
            "For an example of their application, you might like to try:",
            "gap> ACEReadResearchExample(\"doL28.g\" : optex := [1,2,4,5,8]);",
            "(the output is 65 lines followed by a 'gap> ' prompt)",
            "",
            "For information type: ?Using ACEReadResearchExample"
           ] 
  do
    Info(InfoACE, 1, s);
  od;
fi;

#E  pgrelfind.g . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
