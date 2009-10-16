#############################################################################
##
#W    extrachains.gi           The GenSift package            Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: extrachains.gi,v 1.1.1.1 2004/12/22 13:22:49 gap Exp $
##
##  This file contains data for additional subset chains, which are
##  not "optimal" in some sense.
##


############################################################################
# M11 - first try using class 2a and max2:
############################################################################

# Step 3 brings us already into the Centralizer of a.
# Then we sift further in there along a subgroup chain.
PreSift.M11Max := [];
PreSift.m11Max := PreSift.M11Max;  # An alias
PreSift.M11Max[1] := rec(
  # this does M11 -> C_G(a)*A_6.2
  subgpSLP := # AtlasStraightLineProgram("M11",1).program:
    StraightLineProgram( 
    [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
      [ [ 3,1,5,1 ],6 ],[ [ 6,1,3,1 ],7 ],[ [ 4,1,4,1 ],5 ],
      [ [ 5,-1 ],6 ],[ [ 6,1,7,1 ],4 ],[ [ 4,1,5,1 ],2 ],
      [ [ 3,1,3,1 ],4 ],[ [ 4,1,4,1 ],3 ],[ [ 3,-1 ],4 ],
      [ [ 4,1,1,1 ],5 ],[ [ 5,1,3,1 ],1 ],[ [ 1,1 ],[ 2,1 ] ] ],
    2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 3/11 ),
  ismember := rec( 
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",   # this copies the info from one step down during prep.
    ismember := rec( 
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 23/66 ),
      orders := [6,11], 
      ordersslp := [[1,1,0],[1,2,0],[2,3,0],[1,4,1],[4,5,1],],
    ),
  ),
);
PreSift.M11Max[2] := rec(
  # this does C_G(a)*A_6.2 -> C_G(a)*C3xC3.Q8
  subgpSLP := StraightLineProgram( [[[1,1,2,2,1,1],[2,1,1,1,2,2]]],2),
      # this was found for N(Syl_3(L1)) with VerySillyFindGeneratorsSubgroup
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",   # this copies the info from one step down during prep.
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 9/20 ),
      orders := [5,8],
      ordersslp := [[1,1,0],[2,2,0],[1,3,1],[3,3,1],],
    ),
  ),
);
PreSift.M11Max[3] := rec(
  # this does C_G(a)*C3xC3.Q8 -> C_G(a)*Q8 = C_G(a)
  subgpSLP := StraightLineProgram( [ [[1,1,2,1],[1,3,2,1,1,1]] ],2 ),
      # A cyclic group of order 4
      # this was found for an element of order 4 with SillyFindShortEl 
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/9 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [ [1,1,2,1,1,1,2,1] ], 2 ),
    ismember := rec(
      method := IsMemberCentralizer, 
      centof := StraightLineProgram( [ [[1,1,2,1]] ] , 2 ),
    ),
  ),
);
PreSift.M11Max[4] := rec(
  # this starts anew with the centralizer of a:
  groupSLP := StraightLineProgram(
      [ [2,2,1,1], [[3,2,2,1,1,1,3,1],[3,1,2,1,3,1,2,1,1,1,2,2]] ],2 ),
  subgpSLP := StraightLineProgram(
      [ [[2,1,1,1]] ], 2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],2 ),  # the identity
                StraightLineProgram( [ [1,1] ], 2 ),
                StraightLineProgram( [ [1,2] ], 2 ),
                StraightLineProgram( [ [2,1,1,2] ], 2 ),
                StraightLineProgram( [ [1,1,2,1,1,2] ], 2 ),
                StraightLineProgram( [ [1,2,2,1,1,2] ], 2 )],
  p := FLOAT_RAT(1/6),   # FIXME: Determine p!
  ismember := rec( 
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [ [2,1,1,1], [[3,2]] ],2 ),
  ),
);  
PreSift.M11Max[5] := rec(
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ], 1 ),  # the identity
                StraightLineProgram( [ [1,1] ], 1 ),
                StraightLineProgram( [ [1,2] ], 1 ),
                StraightLineProgram( [ [1,3] ], 1 ),
                StraightLineProgram( [ [1,4] ], 1 ),
                StraightLineProgram( [ [1,5] ], 1 ),
                StraightLineProgram( [ [1,6] ], 1 ),
                StraightLineProgram( [ [1,7] ], 1 )],
  p := FLOAT_RAT(1/8),   # FIXME: Determine p!
  ismember := rec( method := IsMemberIsOne,
                   isdeterministic := true ),
);


############################################################################
# M12 - using M11
############################################################################

# This is the chain of M11 (see above) with one step prepended, where coset
# reps of M11 in M12 are stored and we use element orders as IsMember.
PreSift.M12viaM11 := [];
PreSift.m12viam11 := PreSift.M12viaM11;  # An alias
PreSift.M12viaM11[1] := rec(
  # this does M12 -> M11
  subgpSLP := # AtlasStraightLineProgram("M12",1).program:
    StraightLineProgram( 
    [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
      [ [ 3,1,5,1 ],6 ],[ [ 3,1,6,1 ],7 ],[ [ 7,1,4,1 ],8 ],
      [ [ 8,1,5,1 ],9 ],[ [ 9,1,9,1 ],2 ],[ [ 4,1,4,1 ],5 ],
      [ [ 5,-1 ],4 ],[ [ 4,1,2,1 ],6 ],[ [ 6,1,5,1 ],2 ],
      [ [ 3,1,3,1 ],4 ],[ [ 4,-1 ],3 ],[ [ 3,1,1,1 ],5 ],
      [ [ 5,1,4,1 ],1 ],[ [ 1,1 ],[ 2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  p := FLOAT_RAT(1/12),
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,2,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,2,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1,2,2,1,1,2,1 ] ],2 ), ],
  ismember := rec(
    isdeterministic := false,
    method := IsMemberOrders,
    p0 := FLOAT_RAT( 1/10 ),
    orders := [ 10 ],
    ordersslp := [[1,1,0],[1,2,0],[2,3,0],[4,4,1],],
  ),
);
PreSift.M12viaM11[2] := rec(
  # Note that this comes from M11, so in what follows, G = M11
  # this does M11 -> C_G(a)*A_6.2
  subgpSLP := # AtlasStraightLineProgram("M11",1).program:
    StraightLineProgram( 
    [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
      [ [ 3,1,5,1 ],6 ],[ [ 6,1,3,1 ],7 ],[ [ 4,1,4,1 ],5 ],
      [ [ 5,-1 ],6 ],[ [ 6,1,7,1 ],4 ],[ [ 4,1,5,1 ],2 ],
      [ [ 3,1,3,1 ],4 ],[ [ 4,1,4,1 ],3 ],[ [ 3,-1 ],4 ],
      [ [ 4,1,1,1 ],5 ],[ [ 5,1,3,1 ],1 ],[ [ 1,1 ],[ 2,1 ] ] ],
    2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 3/11 ),
  ismember := rec( 
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",   # this copies the info from one step down during prep.
    ismember := rec( 
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 23/66 ),
      orders := [6,11], 
      ordersslp := [[1,1,0],[1,2,0],[2,3,0],[1,4,1],[4,5,1],],
    ),
  ),
);
PreSift.M12viaM11[3] := rec(
  # this does C_G(a)*A_6.2 -> C_G(a)*C3xC3.Q8
  subgpSLP := StraightLineProgram( [[[1,1,2,2,1,1],[2,1,1,1,2,2]]],2),
      # this was found for N(Syl_3(L1)) with VerySillyFindGeneratorsSubgroup
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",   # this copies the info from one step down during prep.
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 9/20 ),
      orders := [5,8],
      ordersslp := [[1,1,0],[2,2,0],[1,3,1],[3,3,1],],
    ),
  ),
);
PreSift.M12viaM11[4] := rec(
  # this does C_G(a)*C3xC3.Q8 -> C_G(a)*Q8 = C_G(a)
  subgpSLP := StraightLineProgram( [ [[1,1,2,1],[1,3,2,1,1,1]] ],2 ),
      # A cyclic group of order 4
      # this was found for an element of order 4 with SillyFindShortEl 
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/9 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [ [1,1,2,1,1,1,2,1] ], 2 ),
    ismember := rec(
      method := IsMemberCentralizer, 
      centof := StraightLineProgram( [ [[1,1,2,1]] ] , 2 ),
    ),
  ),
);
PreSift.M12viaM11[5] := rec(
  # this starts anew with the centralizer of a:
  # now we do things with respect to M11, which is the second group!
  groupSLP := [StraightLineProgram(
      [ [2,2,1,1], [[3,2,2,1,1,1,3,1],[3,1,2,1,3,1,2,1,1,1,2,2]] ],2 ),2],
  subgpSLP := StraightLineProgram( [ [[2,1,1,1]] ], 2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],2 ),  # the identity
                StraightLineProgram( [ [1,1] ], 2 ),
                StraightLineProgram( [ [1,2] ], 2 ),
                StraightLineProgram( [ [2,1,1,2] ], 2 ),
                StraightLineProgram( [ [1,1,2,1,1,2] ], 2 ),
                StraightLineProgram( [ [1,2,2,1,1,2] ], 2 )],
  p := FLOAT_RAT(1/6),   # FIXME: Determine p!
  ismember := rec( 
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [ [2,1,1,1], [[3,2]] ],2 ),
  ),
);  
PreSift.M12viaM11[6] := rec(
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ], 1 ),  # the identity
                StraightLineProgram( [ [1,1] ], 1 ),
                StraightLineProgram( [ [1,2] ], 1 ),
                StraightLineProgram( [ [1,3] ], 1 ),
                StraightLineProgram( [ [1,4] ], 1 ),
                StraightLineProgram( [ [1,5] ], 1 ),
                StraightLineProgram( [ [1,6] ], 1 ),
                StraightLineProgram( [ [1,7] ], 1 )],
  p := FLOAT_RAT(1/8),   # FIXME: Determine p!
  ismember := rec( method := IsMemberIsOne,
                   isdeterministic := true ),
);


############################################################################
# M12, using L2(11) and class 2a:
############################################################################

PreSift.M12Max1 := [];
PreSift.m12Max1 := PreSift.M12Max1;   # an alias
PreSift.M12Max1[1] := rec(
  # this does: G=M12  ->  C_G(a) * L2(11), where a is from 2a
  subgpSLP := # = AtlasStraightLineProgram("M12",5)
     StraightLineProgram( 
        [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 4,1,3,1 ],5 ],
          [ [ 5,1,3,1 ],6 ],[ [ 6,1,6,1 ],5 ],[ [ 6,1,5,1 ],1 ],
          [ [ 4,1,4,1 ],5 ],[ [ 5,-1 ],4 ],[ [ 4,1,2,1 ],6 ],
          [ [ 6,1,5,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 5/36 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 33/80 ),
      orders := [4,8,10],
      ordersslp := [[1,1,0],[2,2,1],[1,3,0],[3,3,1],[2,5,1],],
    ),
  ),
);
PreSift.M12Max1[2] := rec(
  # this does: C_G(a) * L2(11)  ->  C_G(a) * A5
  subgpSLP := # = AtlasStraightLineProgram( "L2(11)", 1 )
     StraightLineProgram( 
        [ [ [ 2,1,1,1 ],3 ],[ [ 2,1,3,1 ],4 ],[ [ 3,1,2,1 ],5 ],
          [ [ 4,1,5,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 3/11 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 23/66 ),
      orders := [6,11],
      ordersslp := [[1,1,0],[1,2,0],[2,3,0],[1,4,1],[4,5,1],],
    ),
  ),
);
PreSift.M12Max1[3] := rec(
  # this does: C_G(a) * A5  ->  C_G(a) * 12
  # where 12 is the intermediate subgroup between C_G(a) \cap A5 and A5 of
  # order 12
  subgpSLP := StraightLineProgram( [ [ [ 2,1 ],[ 1,1,2,1,1,1,2,2,1,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [[1,1,2,1,1,1,2,2,1,1],[2,2,3,1,2,1]], 2 ),
    # this is also used in the upper levels
    ismember := rec(
      method := IsMemberCentralizer,
      centof := StraightLineProgram( [[1,1,2,1,1,1,2,2,1,1],[[2,2,3,1,2,1]]],2),
      # this is again a
    ),
  ),
);
PreSift.M12Max1[4] := rec(
  # this does: C_G(a) * 12  ->  C_G(a) * 4 = C_G(a)
  subgpSLP := StraightLineProgram( [ [ [ 2,1 ],[ 1,2,2,1,1,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  p := FLOAT_RAT( 1/3 ),
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),],
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[1,2,2,1,1,1]]], 2 ),
  ),
);
PreSift.M12Max1[5] := rec(
  # this does: 240  ->  40 = N_l4(5a)
  groupSLP := StraightLineProgram( 
        [ [1,1,2,1],[1,1,2,2], [ [ 3,3,4,2,3,1,4,1,3,1,1,1 ],
              [ 2,1,4,1,3,2,4,1,3,2,4,1,3,1,1,1 ] ] ],2 ),
  subgpSLP := StraightLineProgram( [ [ [ 2,1,1,1 ],[ 1,2,2,1,1,4 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),
                StraightLineProgram( [ [ 1,4 ] ],2 ),
                StraightLineProgram( [ [ 1,5 ] ],2 ),],
  p := FLOAT_RAT( 1/6 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberNormalizerOfCyclicSubgroup,
    generator := StraightLineProgram( [[1,1,2,1],[1,2,3,2]],2 ),
    conjugates := StraightLineProgram( [[[1,4,2,1,1,3,2,1,1,1],
        [2,1,1,2,2,1,1,1,2,1,1,3,2,1],[1,1,2,1,1,1,2,1,1,4]]], 2 ),
  ),
);
PreSift.M12Max1[6] := rec(
  # this does: N_l4(5a)  ->  C_l4(5a) = 10
  subgpSLP := StraightLineProgram( [ [[ 1, 2, 2, 1 ]] ], 2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/4 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[1,2,2,1],[[ 3,2 ]]], 2 ),
  ),
);
PreSift.M12Max1[7] := rec(
  # this does 10  ->  1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],1 ),
                StraightLineProgram( [ [ 1,1 ] ],1 ),
                StraightLineProgram( [ [ 1,2 ] ],1 ),
                StraightLineProgram( [ [ 1,3 ] ],1 ),
                StraightLineProgram( [ [ 1,4 ] ],1 ),
                StraightLineProgram( [ [ 1,5 ] ],1 ),
                StraightLineProgram( [ [ 1,6 ] ],1 ),
                StraightLineProgram( [ [ 1,7 ] ],1 ),
                StraightLineProgram( [ [ 1,8 ] ],1 ),
                StraightLineProgram( [ [ 1,9 ] ],1 ),],
  p := FLOAT_RAT( 1/10 ),
  ismember := rec(
    method := IsMemberIsOne,
    isdeterministic := true,
  ),
);

############################################################################
# HS by Sophie using class 8b:
############################################################################

PreSift.HScl8b := [];
PreSift.hscl8b := PreSift.HScl8b;    # an alias
PreSift.HScl8b[1] := rec(
  # this does: G=HS  ->  C_G(8b) * U3(5).2
  subgpSLP :=     # this is AtlasStraightLineProgram("HS",2)
      StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
              [ [ 3,1,4,1 ],5 ],[ [ 3,1,5,1 ],6 ],[ [ 6,1,3,1 ],7 ],
              [ [ 7,1,4,1 ],8 ],[ [ 3,1,8,1 ],9 ],[ [ 9,1,4,1 ],10 ],
              [ [ 10,1,10,1 ],11 ],[ [ 10,1,11,1 ],1 ],[ [ 7,1,9,1 ],2 ],
              [ [ 3,1,3,1 ],6 ],[ [ 6,1,6,1 ],7 ],[ [ 7,-1 ],8 ],
              [ [ 7,1,2,1 ],6 ],[ [ 6,1,8,1 ],2 ],[ [ 5,5 ],6 ],
              [ [ 6,-1 ],7 ],[ [ 6,1,1,1 ],8 ],[ [ 8,1,7,1 ],1 ],
              [ [ 1,1 ],[ 2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/88 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 41/165 ),
      orders := [11,15],
      ordersslp := [[1,1,0],[2,2,0],[2,3,0],[1,2,0],[1,3,0],[4,6,1],[3,7,1],],
    ),
  ),
);
PreSift.HScl8b[2] := rec(
  # this does: C_G(8b) * U3(5).2  ->  C_G(8b) * {1,t1} * 2000
  # where 2000 = 5^{1+2}:(8:2) and T = {1,t2} \subseteq U3(5).2
  #subgpSLP := StraightLineProgram( 
  #      [ [ [ 1,1,2,1,1,1,2,2,1,1,2,3,1,1 ],
  #          [ 2,1,1,1,2,1,1,1,2,1,1,1,2,2,1,1,2,1 ] ] ],2 ),
  subgpSLP := StraightLineProgram( 
         [ [2,1,1,1],[2,2,1,1],[ [ 3,3,2,2,1,1,2,1 ], [ 4,2,3,3,2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/63 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := StraightLineProgram( [ [ 1,1,2,1,1,1,2,2,1,1,2,3,1,1 ],
            [ 2,1,1,1,2,1,1,1,2,1,1,1,2,2,1,1,2,1 ],
            [ 3,1,4,1 ], [5,2,4,2,5,2,4,2] ],2 ),
      conjugates := StraightLineProgram( [ [ 1,1,2,1,1,1,2,2,1,1,2,3,1,1 ],
            [ 2,1,1,1,2,1,1,1,2,1,1,1,2,2,1,1,2,1 ],
            [ 3,1,4,1 ], [5,2,4,2,5,2,4,2], [[6,1],[6,2],[6,3],[6,4]] ],2 )
    ),
  ),
);
PreSift.HScl8b[3] := rec(
  # this does: C_G(8b) * {1,t1} * 2000  -> C_G(8b) * {1,t2,t3,t4} * 8
  subgpSLP := StraightLineProgram( [[[1,1]]], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/125 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [[1,1]], 2 ),
    ismember := rec(
      method := IsMemberSet,
      set := StraightLineProgram( [[[1,1],[1,3],[1,5],[1,7]]], 2 ),
    ),
  ),
);
PreSift.HScl8b[4] := rec(
  # this does: C_G(8b) * {1,t2,t3,t4}  ->  C_G(8b)
  subgpSLP := TrivialSubgroup,    # not needed
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,   # used to run through T^-1
  cosetreps := [[StraightLineProgram([[1,0]],2),1],
                [StraightLineProgram([[2,1,1,1],
                   [3,1,2,2,3,3,2,2,3,4,2,2,1,1,2,2,1,1]],2),2],
                [StraightLineProgram([[2,1,1,1],
                   [1,1,2,1,3,2,2,1,3,4,2,2,1,1,2,2,1,1]],2),2],
                [StraightLineProgram([[2,1,1,1],
                   [3,2,2,3,1,1,2,1]],2),2]],
  p := FLOAT_RAT( 1/4 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[1,1]]], 1 ),
  ),
);
PreSift.HScl8b[5] := rec(
  # this does: C_G(8b)  ->  1
  groupSLP := StraightLineProgram( 
        [ [ [ 2,2,1,1,2,1,1,1,2,4,1,1,2,1,1,1,2,1,1,1,2,2 ],3 ],
          [ [ 2,1,1,1,2,1,1,1,2,2,1,1,2,4,1,1,2,1,1,1,2,2,1,1,
                  2,1,1,1,2,1 ],4 ],[ [ 3,1 ],1 ],[ [ 4,1 ],2 ],
          [ [ 2,3,1,2,2,1,1,2 ],[ 2,1,1,4,2,4,1,1 ] ] ],2 ),
  subgpSLP := TrivialSubgroup,
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,3 ] ],2 ),
                StraightLineProgram( [ [ 2,3,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,4 ] ],2 ),
                StraightLineProgram( [ [ 2,4,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,5 ] ],2 ),
                StraightLineProgram( [ [ 2,5,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,6 ] ],2 ),
                StraightLineProgram( [ [ 2,6,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,7 ] ],2 ),
                StraightLineProgram( [ [ 2,7,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/16 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);

############################################################################
# M22 by Max:
############################################################################

PreSift.M22Max := [];
PreSift.m22Max := PreSift.M22Max;  # An alias
PreSift.M22Max[1] := rec(
  # this goes M22 -> C_G(a)*L3(4)
  subgpSLP := # AtlasStraightLineProgram ("M22",2).program:
     StraightLineProgram( 
      [ [ [ 1, 1, 2, 1 ], 3 ], [ [ 3, 1, 2, 1 ], 4 ], [ [ 3, 1, 4, 1 ], 5 ], 
        [ [ 5, 1, 5, 1 ], 6 ], [ [ 3, 3 ], 7 ], [ [ 7, 1, 6, 1 ], 8 ], 
        [ [ 8, -1 ], 9 ], [ [ 9, 1, 2, 1 ], 10 ], [ [ 10, 1, 8, 1 ], 2 ], 
        [ [ 1, 1 ], [ 2, 1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 2/11 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 103/264 ),
      orders := [6,8,11],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[2,4,1],[2,5,1],[3,6,1],],
    ),
  ),
);
PreSift.M22Max[2] := rec(
  # this goes C_G(a)*L3(4) -> C_G(a)*2^4.A5
  subgpSLP := # AtlasStraightLineProgram("L3(4)",1):
     StraightLineProgram( [ [ [ 1, 1, 2, 1 ], 3 ], [ [ 3, 1, 2, 1 ], 4 ], 
       [ [ 1, 1, 1, 1 ], 5 ], [ [ 5, 1, 2, 1 ], 1 ], [ [ 4, 1, 4, 1 ], 5 ], 
       [ [ 3, 1, 3, 1 ], 4 ], [ [ 2, 1, 4, 1 ], 3 ], [ [ 3, 1, 3, 1 ], 4 ], 
       [ [ 5, 1, 4, 1 ], 2 ], [ [ 1, 1 ], [ 2, 1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/7 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 2/7 ),
      orders := [7],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[3,4,1],],
    ),
  ),
);
PreSift.M22Max[3] := rec(
  # this goes C_G(a)*2^4.A5 -> C_G(a)*A5
  subgpSLP := 
    StraightLineProgram([ [ [1,1,2,2,1,1],[1,1,2,1,1,1,2,2] ] ],2),
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],2 ),  # the identity
                StraightLineProgram( [[1,1]],2 ),
                StraightLineProgram( [[2,1]],2 ),
                StraightLineProgram( [[1,2]],2 ),
                StraightLineProgram( [[2,1,1,1]],2 ),
                StraightLineProgram( [[1,1,2,1]],2 ),
                StraightLineProgram( [[2,2]],2 ),
                StraightLineProgram( [[1,3]],2 ),
                StraightLineProgram( [[2,1,1,2]],2 ),
                StraightLineProgram( [[1,1,2,1,1,1]],2 ),
                StraightLineProgram( [[1,2,2,1]],2 ),
                StraightLineProgram( [[2,1,1,1,2,1]],2 ),
                StraightLineProgram( [[1,1,2,1,1,2]],2 ),
                StraightLineProgram( [[2,2,1,2]],2 ),
                StraightLineProgram( [[1,2,2,1,1,1]],2 ),
                StraightLineProgram( [[1,2,2,1,1,2]],2 )],
  p := FLOAT_RAT(1/16),   # FIXME: Determine p!
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 3/16 ),
      orders := [4],
      ordersslp := [[1,1,0],[2,2,1],],
    ),
  ),
);
PreSift.M22Max[4] := rec(
  # this goes C_G(a)*A5 -> C_G(a)*S3
  subgpSLP := 
    StraightLineProgram([ [ [2,1,1,1,2,2],[2,2,1,1,2,1] ] ],2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],2 ),  # the identity
                StraightLineProgram( [[1,1]],2 ),
                StraightLineProgram( [[2,1]],2 ),
                StraightLineProgram( [[1,2]],2 ),
                StraightLineProgram( [[2,1,1,1]],2 ),
                StraightLineProgram( [[1,1,2,1]],2 ),
                StraightLineProgram( [[2,2]],2 ),
                StraightLineProgram( [[2,2,1,1]],2 ),
                StraightLineProgram( [[2,1,1,1,2,1]],2 ),
                StraightLineProgram( [[2,3,1,1]],2 )],
  p := FLOAT_RAT(1/10),   # FIXME: Determine p!
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram([ [2,1,1,1,2,4,1,1,2,1] ],2),
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := StraightLineProgram( [[1,2,2,1,1,2]], 2 ),
      conjugates := [StraightLineProgram( [[1,2,2,1,1,2], [3,2]],2 )],
    ),
  ),
);
PreSift.M22Max[5] := rec(
  # this goes C_G(a)*S3 -> C_G(a)*C3 = C_G(a)
  subgpSLP := StraightLineProgram([ [[1,1,2,1]] ],2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],2 ),  # the identity
                StraightLineProgram( [[1,1]],2 )],
  p := FLOAT_RAT(1/2),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer, 
    centof := StraightLineProgram( [ [[1,1,2,1]] ] , 2 ),
  ),
); 
PreSift.M22Max[6] := rec(
  # We are now in C_G(a), which is a group of order 36, the 2-Sylow of
  # which is normal, we sift down there and then to 1
  # this goes C_G(a) -> Syl_2(C_G(a))=C2xC2
  # note that because we change the trick, we go up a group!
  groupSLP := StraightLineProgram([ [1,1,2,1], [1,1,2,3],
    [ [3,3,2,1,4,2,3,2,2,1,4,1], [4,2,3,2,2,1,4,1,3,2,4,1,3,1] ] ],2),
  subgpSLP := StraightLineProgram([ [ [1,2,2,1,1,1,2,2],
                                         [1,2,2,2,1,1,2,1] ] ],2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],2 ),  # the identity
                StraightLineProgram( [ [1,1] ], 2 ),
                StraightLineProgram( [ [2,1] ], 2 ),
                StraightLineProgram( [ [1,2] ], 2 ),
                StraightLineProgram( [ [2,1,1,1] ], 2 ),
                StraightLineProgram( [ [2,2] ], 2 ),
                StraightLineProgram( [ [2,1,1,2] ], 2 ),
                StraightLineProgram( [ [2,2,1,1] ], 2 ),
                StraightLineProgram( [ [2,2,1,2] ], 2 )],
  p := FLOAT_RAT(1/9),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberOrderOfElement,
    orders := [1,2],
    ordersslp := [[1,1,1],],
  ),
);
PreSift.M22Max[7] := rec(
  # this goes C2xC2 -> 1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],2 ),  # the identity
                StraightLineProgram( [ [1,1] ],2 ),
                StraightLineProgram( [ [2,1] ],2 ),
                StraightLineProgram( [ [2,1,1,1] ],2 )],
  p := FLOAT_RAT(1/4),   # FIXME: determine p
  ismember := rec( method := IsMemberIsOne, isdeterministic := true ),
);


############################################################################
# J2, using 3.A6.2_2 and class 2a:
############################################################################

PreSift.J2Max := [];
PreSift.j2Max := PreSift.J2Max;    # an alias
PreSift.J2Max[1] := rec(
  # this does: G=J2  ->  C_G(a) * 3.A6.2_2
  # where a is from class 2a coming from groups further down
  # note, that because a^(3.A6.2) = a^(3.A6), we are actually already
  # in C_G(a) * 3.A6
  subgpSLP :=    # AtlasStraightLineProgram("J2",2)
      StraightLineProgram( 
        [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
          [ [ 3,1,5,1 ],6 ],[ [ 5,1,5,1 ],7 ],[ [ 7,1,3,1 ],8 ],
          [ [ 6,3 ],9 ],[ [ 8,-1 ],7 ],[ [ 7,1,9,1 ],10 ],
          [ [ 10,1,8,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/7 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := [StraightLineProgram([[2,1,1,1],[1,3,3,1,2,3,1,3,3,1,2,3]], 
                                        2), 2],
      conjugates := [StraightLineProgram([[2,1,1,1],[1,3,3,1,2,3,1,3,3,1,2,3],
                             [[4,2]]], 2), 2],
    ),
  ),
);
PreSift.J2Max[2] := rec(
  # we have to specify groupSLP, because we got being in 3.A6 as a present!
  # this does: C * 3.A6  ->  C * 3xA5
  # note, that the central 3 is in C, so we are actually in A5
  groupSLP := StraightLineProgram( 
        [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
          [ [ 3,1,5,1 ],6 ],[ [ 5,1,5,1 ],7 ],[ [ 7,1,3,1 ],8 ],
          [ [ 6,3 ],9 ],[ [ 8,-1 ],7 ],[ [ 7,1,9,1 ],10 ],
          [ [ 10,1,8,1 ],2 ],[ [ 2,1 ],[ 1,1,2,1,1,1 ] ] ],2 ),
  subgpSLP := StraightLineProgram( [[[1,1,2,2 ],[1,1,2,1,1,1,2,1,1,1]]],2 ),
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1 ] ],2 ),],
  p := FLOAT_RAT( 1/3 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 1/4 ),
      orders := [4,12],
      ordersslp := [[1,1,0],[2,2,1],[2,3,0],[4,4,1],],
    ),
  ),
);
PreSift.J2Max[3] := rec(
  # this does: C * A5  ->  C * 12
  # note the 3 was eaten by C!
  groupSLP := [StraightLineProgram( 
                [ [ [ 1,1,2,2 ],3 ],[ [ 1,1,2,1,1,1,2,1,1,1 ],4 ],
                  [ [ 3,1 ],1 ],[ [ 4,1 ],2 ],[ [ 1,1,2,2 ],3 ],[ [ 3,2 ],4 ],
                  [ [ 1,1,4,1 ],[ 2,1 ] ] ],2 ),2],
  subgpSLP := StraightLineProgram( [ [ [ 1,2,2,1 ],[ 1,1,2,1,1,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,2 ] ],2 ),],
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 2/5 ),
      orders := [5],
      ordersslp := [[1,1,0],[1,2,0],[2,3,1],],
    ),
  ),
);
PreSift.J2Max[4] := rec(
  # this does: C * 12  ->  C * 4 = C
  subgpSLP := StraightLineProgram( [ [ [ 1,1,2,1 ],[ 2,1,1,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1, 0 ] ], 2 ),
                StraightLineProgram( [ [ 1, 1 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1 ] ], 2 ), ],
  p := FLOAT_RAT( 1/3 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[2,1,1,1]]], 2 ),
    a := StraightLineProgram( [[2,1,1,1]], 2 ),          # used above
  ),
);
PreSift.J2Max[5] := rec(
  # this does: C=1920  ->  C_C(2b)=192
  groupSLP := StraightLineProgram( [[1,1,2,1],[2,1,1,1],
                   [[4,1,2,2,3,3,4,2],[3,3,4,3,2,2,3,2,4,1,2,1,4,2],
                         [4,3,2,2,3,2,4,3,2,2,3,2,1,1]]], 2 ),
  subgpSLP := StraightLineProgram( [[[3,1,2,1],[1,2,2,1],[2,2,1,1]]],3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],3 ),
                StraightLineProgram( [ [ 1,1 ] ],3 ),
                StraightLineProgram( [ [ 2,1 ] ],3 ),
                StraightLineProgram( [ [ 1,2 ] ],3 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],3 ),
                StraightLineProgram( [ [ 3,1,1,1 ] ],3 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],3 ),
                StraightLineProgram( [ [ 2,2 ] ],3 ),
                StraightLineProgram( [ [ 3,1,1,2 ] ],3 ),
                StraightLineProgram( [ [ 3,1,1,1,2,1 ] ],3 ),],
  p := FLOAT_RAT( 1/10 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[3,1,2,1],[[4,2]]],3 ),
  ),
);
PreSift.J2Max[6] := rec(
  # this does: CC=C_C(2b)=192  ->  N_CC(4a)=32
  subgpSLP := StraightLineProgram( [[[1,1],[3,1,2,1],[3,1,1,1,2,1]]],3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],3 ),
                StraightLineProgram( [ [ 2,1 ] ],3 ),
                StraightLineProgram( [ [ 3,1 ] ],3 ),
                StraightLineProgram( [ [ 2,2 ] ],3 ),
                StraightLineProgram( [ [ 2,1,3,1 ] ],3 ),
                StraightLineProgram( [ [ 3,1,2,2 ] ],3 ),],
  p := FLOAT_RAT( 1/6 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberNormalizerOfCyclicSubgroup,
    generator := StraightLineProgram( [[1,1]], 3 ),
    conjugates := StraightLineProgram( [[[1,3]]], 3),
  ),
);
PreSift.J2Max[7] := rec(
  # this does: N_CC(4a)=32  ->  C_CC(4a)=16
  subgpSLP := StraightLineProgram( [ [ [ 1, 1 ], [ 2, 1 ] ] ], 3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],3 ),
                StraightLineProgram( [ [ 3,1 ] ],3 ),],
  p := FLOAT_RAT( 1/2 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[1,1]]], 3 ),
  ),
);
PreSift.J2Max[8] := rec(
  # this does 16  ->  1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,3 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,3 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,3,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,3 ] ],2 ),
                StraightLineProgram( [ [ 2,3,1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,3,1,3 ] ],2 ),],
  p := FLOAT_RAT( 1/16 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);


