#############################################################################
##
#W    chain.gi             The GenSift package                Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: chains.gi,v 1.4 2009/07/25 22:15:26 gap Exp $
##
##  This file contains the data for the "best" subset chains.
##

# Overview over sporadics and their state of implementation:

# M11  : my chain, paper chain not implemented
# M12  : my chain, chain via M11, paper chain not implemented
# M22  : my chain, Sophie's chain, not compared yet
# M23  : can be done relatively easily using M22
# M24  : can be done relatively easily using M23
# J2   : done, paper chain not implemented, but 1/140 very bad in first step
# HS   : paper chain, better chain using involution centralizer
# Co3  : done
# Co2  : done
# McL  : is doable because it occurred in Co2 and 3.McL occured in Ly
# J1   : probably doable, because small
# J3   : probably doable, because small enough
# Co1  : huge, but having Co2 and Co3 as maximal subgroups, probably doable
# Fi22 : big, there is hope
# Fi23 : large, not checked
# Fi24': huge, not checked
# Suz  : no investigations yet
# O'N  : no investigations yet
# Ru   : no investigations yet
# HN   : no investigations yet
# He   : no investigations yet
# Th   : no investigations yet
# Ly   : done
# J4   : no investigations yet, hopeless???
# B    : no investigations yet, probably hopeless
# M    : no investigations yet, probably hopeless


############################################################################
# M11, using class 2a and max5=C_G(2a):
############################################################################

PreSift.M11 := [];
PreSift.m11 := PreSift.M11;   # an alias
PreSift.M11[1] := rec(
  # this does: M11  ->  C_G(a) * {1,t1} * C_G(a)
  # where a is from class 2a and C := C_G(a) is max5 with order 48
  subgpSLP :=     # AtlasStraightLineProgram("M11",5)
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 2,1,3,1 ],4 ],
          [ [ 4,1,3,1 ],5 ],[ [ 5,1,5,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 13/165 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [[StraightLineProgram([[1,1,2,1],[3,4]],2),2]],
    ),
  ),
);
PreSift.M11[2] := rec(
  # this does: C * {1,t1} * C  ->  C * {1,t2,t3} * 2^2
  # where 2^2 contains a
  # Note: The normalizer of 2^2 in G contains suitable elements {t2,t3,t4}!
  subgpSLP := StraightLineProgram( 
                [ [ [ 1,1,2,1,1,1,2,2,1,1 ],[ 1,1,2,2,1,1,2,1,1,1,2,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1,2,1,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/6 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [[1,1,2,1],[3,4]],2 ),
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram( [[1,1,2,1,1,1,2,2,1,1]], 2)],
    ),
  ),
);
PreSift.M11[3] := rec(
  # this does: C * {1,t2,t3} * 2^2  ->  C
  # by trying T:
  subgpSLP := TrivialSubgroup,   # unused
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram([[1,0]], 2 ),
                [StraightLineProgram([[2,1,1,1],[1,1,2,2,1,1,2,1],
                                      [3,2,2,3,1,1,2,2],[4,2,1,1,2,2,1,1],
                                      [5,-1]], 2 ),1], 
                [StraightLineProgram([[2,1,1,1],[1,1,2,2,1,1,2,1],
                                      [3,2,2,3,1,1,2,2],[4,2,1,1,2,2,1,1],
                                      [6,-1,5,-1]], 2 ),1]],
  # These coset reps are actually T^-1={1,t2^-1,t3^-1}
  p := FLOAT_RAT( 1/3 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [[StraightLineProgram( [[1,1,2,1],[3,4]], 2 ),2]],
  ),
);      
# Was used for the coset reps in step 3:
#                StraightLineProgram( 
#[ [ [ 2, 1, 1, 1, 2, 1, 1, 1, 2, 3, 1, 1, 2, 2 ], [ 1, 1, 2, 2, 1, 1, 2, 1, 
#          1, 1, 2, 2, 1, 1, 2, 1, 1, 1, 2, 2, 1, 1 ] ] ], 2 )
PreSift.M11[4] := rec(
  # this does: C  ->  8
  groupSLP :=      # this is again AtlasStraightLineProgram("M11",5)
     StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 2,1,3,1 ],4 ],
                [ [ 4,1,3,1 ],5 ],[ [ 5,1,5,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ],2 ),
  subgpSLP := StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1,2,1 ] ],2 ),],
  p := FLOAT_RAT( 1/6 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [[2,1,1,1]],2 )],
  ),
);
PreSift.M11[5] := rec(
  # this does 8  ->  1
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
                StraightLineProgram( [ [ 1,7 ] ],1 ),],
  p := FLOAT_RAT( 1/8 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);


############################################################################
# M12 - using max9 and class 2a:
############################################################################
PreSift.M12 := [];
PreSift.m12 := PreSift.M12;  # An alias
PreSift.M12[1] := rec(
  # this does: G=M12  ->  C_G(a) * C_G(b) where a is in class 2A and b is
  # in class 2B, such that |C_G(a)| = 240 and |C_G(b)| = 192
  # let C := C_G(a)
  subgpSLP :=      # this is AtlasStraightLineProgram("M12",9)
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
                      [ [ 3,1,4,1 ],5 ],[ [ 4,1,5,1 ],6 ],[ [ 4,1,6,1 ],7 ],
                      [ [ 6,1,4,1 ],8 ],[ [ 3,1,3,1 ],4 ],[ [ 3,1,4,1 ],5 ],
                      [ [ 5,1,7,1 ],2 ],[ [ 5,1,8,1 ],3 ],[ [ 4,-1 ],5 ],
                      [ [ 2,1,2,1 ],8 ],[ [ 8,1,8,1 ],9 ],[ [ 9,1,5,1 ],6 ],
                      [ [ 3,1,3,1 ],8 ],[ [ 8,1,8,1 ],9 ],[ [ 9,1,4,1 ],7 ],
                      [ [ 6,1,7,1 ],8 ],[ [ 8,1,8,1 ],7 ],[ [ 4,1,7,1 ],5 ],
                      [ [ 5,-1 ],6 ],[ [ 6,1,3,1 ],7 ],[ [ 7,1,5,1 ],1 ],
                      [ [ 1,1 ],[ 2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/33 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram([ [ 1,1,2,1,1,1,2,2 ], [ 3,1,3,1,1,1,2,2],
                    [ 1,1,2,1,4,1,3,1 ], [ [ 3,1,5,1,1,1 ] ] ], 2)],
    ),
  ),
);
PreSift.M12[2] := rec(
  # this does: C * C_G(b)  ->  C * C_G(c) where c is an element of order 4
  # and |C_G(c)| = 32
  subgpSLP := StraightLineProgram( [ [ [ 1,1,2,2 ],[ 1,1,2,1,1,2,2,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/3 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram( [ [1,3,2,2,1,1,2,2] ], 2 )],
    ),
  ),
);
PreSift.M12[3] := rec(
  # this does: C * C_G(c) ->  C * {1,t1} * 8
  # where 8 is the centralizer of an element of order 4 and 8 < C and 8^t1 < C
  subgpSLP := StraightLineProgram( [ [ [ 2,1,1,1 ],[ 2,2 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),],
  p := FLOAT_RAT( 1/2 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [[2,1,1,1],[3,1,2,4]], 2 ),
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram( [[2,1,1,1]], 2 )],
    ),
  ),
);
PreSift.M12[4] := rec(
  # this does: C * {1,t1} * 8  ->  C * 8 = C
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [[1,0]], 2 ),
                [StraightLineProgram( [[1,2]], 2 ),3]],
  p := FLOAT_RAT( 1/2 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [[1,1,2,2]], 2 )],
  ),
);
PreSift.M12[5] := rec(
  # this does: C  ->  N_C(5a) with 40 elements
  groupSLP := StraightLineProgram( [[1,1,2,1,1,1],[3,1,2,1,1,1,2,2],[3,1,2,2],
          [[5,2,1,1,2,2,1,1,2,1],[2,1,5,1,4,1,1,1,2,2],[4,2,3,1]]],2),
  subgpSLP := StraightLineProgram( [ [ [ 1,1,3,1 ],[ 3,1,2,1 ] ] ],3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],3 ),
                StraightLineProgram( [ [ 1,1 ] ],3 ),
                StraightLineProgram( [ [ 2,1 ] ],3 ),
                StraightLineProgram( [ [ 3,1 ] ],3 ),
                StraightLineProgram( [ [ 2,2 ] ],3 ),
                StraightLineProgram( [ [ 2,1,3,1 ] ],3 ),],
  p := FLOAT_RAT( 1/6 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberNormalizerOfCyclicSubgroup,
    generator := StraightLineProgram( [[2,1,3,2]], 3 ),
    conjugates := [StraightLineProgram( [[2,1,3,2]], 3),
                   StraightLineProgram( [[2,1,3,2],[4,2]], 3),
                   StraightLineProgram( [[2,1,3,2],[4,3]], 3),
                   StraightLineProgram( [[2,1,3,2],[4,4]], 3)],
  ),
);
PreSift.M12[6] := rec(
  # this does N_C(5a)  ->  C_C(5a) with 10 elements
  subgpSLP := StraightLineProgram( [ [ 1,1,2,2 ] ],2 ),
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
    centof := [[StraightLineProgram( [[2,1,3,2]], 3 ),5]],
  ),
);
PreSift.M12[7] := rec(
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
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);

############################################################################
# M22 by Sophie using class 2a:
############################################################################

PreSift.M22 := [];
PreSift.m22 := PreSift.M22;   # an alias
PreSift.M22[1] := rec(
  # this does M22 -> C_G(a)PSL(3.4)
  subgpSLP := # AtlasStraightLineProgram("M22",1).program:
    StraightLineProgram( [ [ [ 1, 1, 2, 1 ], 3 ], [ [ 3, 1, 2, 1 ], 4 ], 
       [ [ 3, 1, 4, 1 ], 5 ], [ [ 5, 1, 5, 1 ], 6 ], [ [ 3, 3 ], 7 ], 
       [ [ 7, 1, 6, 1 ], 8 ], [ [ 8, -1 ], 9 ], [ [ 9, 1, 2, 1 ], 10 ], 
       [ [ 10, 1, 8, 1 ], 2 ], [ [ 1, 1 ], [ 2, 1 ] ] ] ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 3/11 ),
  ismember := rec( 
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",   # this copies the info from one step down during prep.
    ismember := rec( 
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 103/364 ),
      orders := [6,8,11], 
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[2,4,1],[2,5,1],[3,6,1],],
    ),
  ),
);
PreSift.M22[2] := rec(
  # this does C_G(a)*PSL(3.4) -> C_G(a)*T2*Z_2xSxA_5
  subgpSLP := StraightLineProgram( 
        [ [2,1,1,1],[[3,3,2,2,1,1],[3,1,2,3,1,1,3,1,2,1]] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 5/21 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",   # this copies the info from one step down during prep.
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 2/7 ),
      orders := [7],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[3,4,1],],
    ),
  ),
);

PreSift.M22[3] := rec(
  # this does C_G(a)*T2*Z2xSxA5 -> C_G(a)
  subgpSLP :=StraightLineProgram([[[1,1],[2,1]]],2), 
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/60 ),
    ismember := rec(
         isdeterministic := true,
         method:=IsMemberConjugates,     
         a := StraightLineProgram([[2,2]],2),
         extraels := [[StraightLineProgram([[1,0]],2),1],
                      [StraightLineProgram(
                            [[1,1,2,1,1,1,2,2,1,1,2,1,1,1,2,1,1,1]],2),1]],
         ismember := rec(
              method := IsMemberWithSetConjugating,              
              #set:=StraightLineProgram([ [[2,2],[1,4,2,1,1,1,2,2]] ],2),
              extraels := [[StraightLineProgram([[1,0]],2),1],
                           [StraightLineProgram(
                              [[1,1,2,1,1,1,2,2,1,1,2,1,1,1,2,1,1,1]],2),1]],
              ismember := rec(
                 method := IsMemberSet,
                 set:=[StraightLineProgram([[2,2]],2)],
              ),
         ),
    ),
  specialaction := GenSift.SpecialActionUseIsMemberInfo,
);
PreSift.M22[4] := rec(
  #From C_G(a) to C_{C_G(a)}(k)
  groupSLP :=StraightLineProgram( [ [1,1,2,1], [2,1,1,1], 
   [[3,1,2,2,3,1,4,2], [4,1,2,3,3,2,2,2,3,1,2,1],[2,3,3,2,4,1,2,3,3,1] ] ], 2 ),
  subgpSLP := StraightLineProgram([ 
   [[1,1],[3,1,2,2,3,1],[2,1,1,1,2,3],[2,3,1,1,2,1]]],3),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1,0] ],3 ),  # the identity
                StraightLineProgram( [ [2,1] ], 3 ),
                StraightLineProgram( [ [3,1] ], 3 ),
                StraightLineProgram( [ [2,2] ], 3 ),
                StraightLineProgram( [ [3,1,2,1] ], 3 ),
                StraightLineProgram( [ [1,1,3,1] ], 3 ),
                StraightLineProgram( [ [2,1,3,1] ], 3 ),
                StraightLineProgram( [ [2,3] ], 3 ),
                StraightLineProgram( [ [3,1,2,2] ], 3 ),
                StraightLineProgram( [ [1,1,3,1,2,1] ], 3 ),
                StraightLineProgram( [ [2,1,3,1,2,1] ], 3 ),
                StraightLineProgram( [ [2,1,1,1,3,1] ], 3 ),
                StraightLineProgram( [ [1,1,2,1,3,1] ], 3 ),
                StraightLineProgram( [ [3,1,2,1,3,1] ], 3 ),
                StraightLineProgram( [ [3,1,2,3] ], 3 ),
                StraightLineProgram( [ [1,1,3,1,2,2] ], 3 ),
                StraightLineProgram( [ [2,1,3,1,2,2] ], 3 ),
                StraightLineProgram( [ [1,1,2,1,3,1,2,1] ], 3 ),
                StraightLineProgram( [ [3,1,2,1],[4,2] ], 3 ),
                StraightLineProgram( [ [2,1,3,1],[4,2] ], 3 ),
                StraightLineProgram( [ [2,1,3,1,2,3] ], 3 ),
                StraightLineProgram( [ [1,1,2,1,3,1,2,2] ], 3 ),
                StraightLineProgram( [ [3,1,2,1,3,1,2,2] ], 3 ),
                StraightLineProgram( [ [1,1,2,1,3,1,2,3] ], 3 )
                ],
  p := FLOAT_RAT( 1/24 ),
  ismember := rec( 
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[ [1,1]] ],3 ), # k
  ),
);  

PreSift.M22[5] := rec(
# From C_{C_G(a)}(k) to 1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [
            StraightLineProgram( [ [1,0] ],4 ),  # the identity
            StraightLineProgram( [ [1,1] ], 4 ),
            StraightLineProgram( [ [2,1] ], 4 ),
            StraightLineProgram( [ [3,1] ], 4 ),
            StraightLineProgram( [ [4,1] ], 4 ),
            StraightLineProgram( [ [2,1,1,1] ], 4 ),
            StraightLineProgram( [ [3,1,1,1] ], 4 ),
            StraightLineProgram( [ [4,1,1,1] ], 4 ),
            StraightLineProgram( [ [3,1,2,1] ], 4 ),
            StraightLineProgram( [ [4,1,2,1] ], 4 ),
            StraightLineProgram( [ [4,1,3,1] ], 4 ),
            StraightLineProgram( [ [3,1,2,1,1,1] ], 4 ),
            StraightLineProgram( [ [4,1,2,1,1,1] ], 4 ),
            StraightLineProgram( [ [4,1,3,1,1,1] ], 4 ),
            StraightLineProgram( [ [4,1,3,1,2,1] ], 4 ),
            StraightLineProgram( [ [4,1,3,1,2,1,1,1] ], 4 )       
  ], #C_{C_G(a)}(k)
  ismember := rec( method := IsMemberIsOne, isdeterministic := true ),
);


############################################################################
# J2, using class 8a:
############################################################################

PreSift.J2 := [];
PreSift.j2 := PreSift.J2;      # an alias
PreSift.J2[1] := rec(
  # a = 8a, C := C_J2(a) = <a>
  # this does: J2  ->  C * {1,t1} * 3.A6.2
  subgpSLP :=    # this is AtlasStraightLineProgram("J2",2):
    StraightLineProgram( 
        [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
          [ [ 3,1,5,1 ],6 ],[ [ 5,1,5,1 ],7 ],[ [ 7,1,3,1 ],8 ],
          [ [ 6,3 ],9 ],[ [ 8,-1 ],7 ],[ [ 7,1,9,1 ],10 ],
          [ [ 10,1,8,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/140 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := [StraightLineProgram( [[1,1,2,1],[1,4,3,2,1,1,3,1]], 2 ),3],
      conjugates := [[StraightLineProgram( [[1,1,2,1],[1,4,3,2,1,1,3,1],[4,-1]],
                                           2),3]],
    ),
  ),
);
PreSift.J2[2] := rec(
  # this does: C * {1,t1} * 3.A6.2  ->  C * {1,t2,t3,t4} * 3^{1+2}:8
  subgpSLP := StraightLineProgram( [[[2,1,1,1,2,1],[2,2,1,1,2,1,1,1]]], 2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,2,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,3,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,3,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberNormalizer,
      generators := [StraightLineProgram( [[[2,1],[1,7,2,1,1,1]]],2 ),3],
      conjugates := [StraightLineProgram( [ [2,1],[1,7,2,1,1,1],
            [ [3,1], [4,1], [3,2], [4,1,3,1], [3,1,4,1], [4,2], [4,1,3,2],
              [3,1,4,1,3,1], [4,2,3,1], [3,2,4,1], [4,1,3,1,4,1], [3,1,4,2],
              [3,1,4,1,3,2], [4,2,3,2], [3,2,4,1,3,1], [4,1,4,1,4,1,3,1],
              [3,1,4,2,3,1], [4,2,3,1,4,1], [4,1,3,1,4,2], [3,2,4,1,3,2],
              [4,1,3,1,4,1,3,2], [3,1,4,2,3,2], [4,2,3,1,4,1,3,1],
              [4,1,3,1,4,2,3,1], [4,2,3,1,4,1,3,2], [4,1,3,1,4,2,3,2]]],2),3],
    ),
  ),
);
PreSift.J2[3] := rec(
  # this does: C * {1,t2,t3,t4} * 3^{1+2}:8  ->  C * {1,t2,t3,t4} * 8
  # where 8 = <a>
  subgpSLP := StraightLineProgram( [ [[ 1, 1 ]] ], 2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,3,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,3,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,2,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,2,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,3,2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,3,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,3,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1,1,2,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2,2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1,2,1,1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1,1,3,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1,2,1,1,2,2,1 ] ],2 ),],
  p := FLOAT_RAT( 1/27 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [ [ 1,1 ] ],2 ),
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram( [ [ 1,1 ] ],2 )],
    ),
  ),
);
PreSift.J2[4] := rec(
  # this does: C * {1,t2,t3,t4} * 8  ->  C  by trying 1,t2^-1,t3^-1,t4^-1
  # note that a^t is in <a> because L4 = <a>
  subgpSLP := TrivialSubgroup,   # not used
  isdeterministic := true,
  cosetreps := [[StraightLineProgram([[1,0]],2),1],
                [StraightLineProgram( 
                    [ [2,1,1,1], [2,1,3,2], [3,3,4,5,3,1,2,2] ],2),1 ],
                [StraightLineProgram( 
                    [ [2,1,1,1], [2,1,3,1], [2,1,3,2], [2,1,3,3], 
                      [6,1,5,1,6,1,4,1,5,2,4,2,2,1]],2),1 ],
                [StraightLineProgram( [ [1,1,2,2], [1,1,2,1],
                     [ 3,1,4,1,3,2,4,3,2,1,4,2,2,1,4,2,2,1,4,3,2,1,3,1,4,2,
                       2,1,4,1 ]],2),1]],
  basicsift := BasicSiftCosetReps,
  p := FLOAT_RAT( 1/4 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [[1,1]], 1 )],
  ),
);
PreSift.J2[5] := rec(
  # this does: C=<a>  ->  1
  groupSLP := [StraightLineProgram( [ [[ 1, 1 ]] ], 2 ),3],
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
                StraightLineProgram( [ [ 1,7 ] ],1 ),],
  p := FLOAT_RAT( 1/8 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);


############################################################################
# Co3
############################################################################

PreSift.Co3 := [];
PreSift.co3 := PreSift.Co3;    # an alias
PreSift.Co3[1] := rec(
  # this goes Co3 -> C(a) * McL.2
  subgpSLP := # AtlasStraightLineProgram ("Co3",1).program
     StraightLineProgram(
      [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
        [ [ 3,1,5,1 ],6 ],[ [ 6,-1 ],7 ],[ [ 7,1,2,1 ],8 ],
        [ [ 8,1,6,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 4/69 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 551/2898 ),
      orders := [ 18,21,23 ],
      ordersslp := [[1,1,0],[1,2,0],[3,3,0],[1,4,0],[2,5,0],[6,6,1],
                    [3,7,1],[2,8,1],],
    ),
  ),
);
PreSift.Co3[2] := rec(
  # this goes C(a) * McL.2 -> C(a) * U4(3).2_3
  subgpSLP := # not the atlas program, as our gens of McL.2 are non-std.
     StraightLineProgram( [ [1,1,2,1], [[1,2,2,1,1,1],[3,3,2,1,1,2]] ], 2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 3/55 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 97/231 ),
      orders := [11, 14, 15, 20, 22, 30],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[1,4,0],[1,5,0],[1,6,0],[3,7,0],
                    [1,8,1],[3,9,1],[1,10,1],[5,11,1],[2,12,1],[8,12,1],],
    ),
  ),
);
PreSift.Co3[3] := rec(
  # this goes C(a) * U4(3).2_3 -> C(a) * 58320
  subgpSLP :=
     StraightLineProgram( [ [1,1,2,2], 
       [[2,3,3,1],[3,1,2,1,3,1,1,1],[1,1,2,1,1,2,2,1,1,2,2,1,1,1]] ], 2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/14 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 137/420 ),
      orders := [ 7,10,24 ],
      ordersslp := [[1,1,0],[1,2,0],[2,3,0],[2,4,1],[1,5,0],[2,6,1],
                    [2,7,0],[8,8,1],],
    ),
  ),
);
PreSift.Co3[4] := rec(
  # this goes C(a) * 58320 -> C(a) * 720
  subgpSLP :=
     StraightLineProgram( [ [[2,3,3,1,2,1], [1,1,3,1,2,2,1,2]] ], 3),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/27 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 8/27 ),
      orders := [ 6,9,12 ],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[2,4,1],[3,5,1],[3,6,1],],
    ),
  ),
);
PreSift.Co3[5] := rec(
  # this goes C(a) * 720 -> C(a) * {id,t2} * 72
  # Attention: Here a class splits: 4a,4b->4a
  subgpSLP := StraightLineProgram( [ [1,1,2,1], [[3,2],[2,1,1,1,2,4]] ], 2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/5),  # this is the combined probability
  T := [StraightLineProgram( [[1,0]], 2 ),
        StraightLineProgram( [[1,1]], 2 )],  # used only further down!
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 9/20 ),
      orders := [5,8],
      ordersslp := [[1,1,0],[2,2,0],[1,3,1],[3,3,1],],
    ),
  ),
);
PreSift.Co3[6] := rec(
  # this goes C(a) * {1,t2} * 72 -> C(a) * {1,t2} * 8
  # Both 4-classes go nicely down with p = 1/9
  subgpSLP := StraightLineProgram( [ [[2,1,1,1],[1,1,2,2]] ], 2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [[1,0]], 2 ),
                StraightLineProgram( [[1,1]], 2 ),
                StraightLineProgram( [[2,1]], 2 ),
                StraightLineProgram( [[1,2]], 2 ),
                StraightLineProgram( [[1,1,2,1]], 2 ),
                StraightLineProgram( [[2,2]], 2 ),
                StraightLineProgram( [[2,1,1,2]], 2 ),
                StraightLineProgram( [[1,2,2,1]], 2 ),
                StraightLineProgram( [[1,3,2,1]], 2 )],
  T := "fromUp",
  p := FLOAT_RAT( 1/9 ),   # this is the probability in both classes!
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [[1,3,2,3]], 2 ),
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := StraightLineProgram( [[1,3,2,3]], 2 ),
      conjugates := StraightLineProgram( [[1,3,2,3], [[3,3]]], 2 ),
    ),
  ),
);
PreSift.Co3[7] := rec(
  # this goes C(a) * 8 -> C(a) * 2 = C(a)
  # Note that 4 = <a> and 2 = <a^2> and that we have that t2 centralizes
  # a^2. If we therefore try the left coset reps of 2 in 8 and in addition
  # multiply with t2^-1 from the right, we will reach 2.
  subgpSLP := StraightLineProgram( [[[1,2]]], 2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetRepsWithT,
  cosetreps := [StraightLineProgram( [[1,0]], 2 ),
                StraightLineProgram( [[1,1]], 2 ),
                StraightLineProgram( [[2,1]], 2 ),
                StraightLineProgram( [[2,1,1,1]], 2 )],
  p := FLOAT_RAT(1/4),   # FIXME: determine p
  T := "fromUp",
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[1,3]]], 2 ),  # this is [a]
  ),
);
PreSift.Co3[8] := rec(
  # this starts a new thing in C=C_G(a)=23040 
  # it goes C -> C_C(aa) * 640
  groupSLP := StraightLineProgram( [ [1,1,2,1],[3,1,2,2,1,2,2,2,3,1,1,2],
       [2,2,3,3,2,1,3,1,2,2,3,1],[3,2,2,2,3,2,2,1,1,2,2,3,1,2,2,2],
       [[4,1,6,1,4,1],[6,1,4,1,5,1,4,1]] ], 2),
  subgpSLP := StraightLineProgram( [[1,1,2,1],
       [[1,2,2,3,1,1],[1,1,3,2,1,2],[3,2,2,1,1,2,2,1]]], 2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/9 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 2/9 ),
      orders := [3,6,12],
      ordersslp := [[1,1,0],[1,2,1],[1,3,0],[2,4,1],[5,5,1],],
    ),
  ),
);
PreSift.Co3[9] := rec(
  # this does C_C(aa) * 640 -> C_C(aa) * N_C(Syl_5(C)) = C_c(aa) * 40
  # attention: splitting classes: 4e<-4a,4c
  subgpSLP := StraightLineProgram( [[[1,1,3,2,2,1],[2,1,3,1,2,2]]], 3),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/4 ),
  T := [StraightLineProgram( [[1,0]], 3 ),  # used further down
        StraightLineProgram( [[2,3]], 3 )],
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := StraightLineProgram( [[1,1,2,2,3,2,1,1]], 3 ),
      conjugates := StraightLineProgram( [[1,1,2,2,3,2,1,1],[[4,4]]], 3 ),
    ),
  ),
);
PreSift.Co3[10] := rec(
  # this does C_C(aa) * N_C(Syl_5(C)) -> C_C(aa) * 4 = C_C(aa)
  subgpSLP := StraightLineProgram([ [1,1,2,1], [[3,5]] ], 2),
  isdeterministic := true,
  basicsift := BasicSiftCosetRepsWithT,
  cosetreps := [StraightLineProgram( [[1,0]], 2 ),
                StraightLineProgram( [[1,1]], 2 ),
                StraightLineProgram( [[2,1]], 2 ),
                StraightLineProgram( [[2,1,1,1]], 2 ),
                StraightLineProgram( [[1,1,2,1]], 2 ),
                StraightLineProgram( [[1,1,2,1,1,1]], 2 ),
                StraightLineProgram( [[2,1,1,1,2,1]], 2 ),
                StraightLineProgram( [[2,1,1,1,2,1,1,1]], 2 ),
                StraightLineProgram( [[1,1,2,1,1,1,2,1]], 2 ),
                StraightLineProgram( [[1,1,2,1,1,1,2,1,1,1]], 2 )],
  p := FLOAT_RAT(1/10),   # FIXME: determine p
  T := "fromUp",
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[1,1]]], 2 ),
    a := StraightLineProgram( [[1,1]], 2 ),  # this is for further up!
  ),
);
PreSift.Co3[11] := rec(
  # this starts again in the centralizer CC in C of aa
  # then it does CC -> 8
  groupSLP := 
     StraightLineProgram( [ [1,1,2,1],[3,1,2,2,1,2,2,2,3,1,1,2],
       [2,2,3,3,2,1,3,1,2,2,3,1],[3,2,2,2,3,2,2,1,1,2,2,3,1,2,2,2],
       [4,1,6,1,4,1],[6,1,4,1,5,1,4,1],
       [7,1,8,1], [[9,1,8,2,9,1,7,2,8,1,7,1],[9,2,8,1,7,1,8,2,7,2,8,2],
                   [7,1,8,3,7,1,8,3,7,1,8,3]] ], 2),
  subgpSLP :=
     StraightLineProgram( [[[3,1],[1,2]]], 3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [[1,0]], 3 ),
                StraightLineProgram( [[1,1]], 3 ),
                StraightLineProgram( [[2,1]], 3 ),
                StraightLineProgram( [[2,1,1,1]], 3 ),
                StraightLineProgram( [[1,1,2,1]], 3 ),
                StraightLineProgram( [[1,1,2,1,1,1]], 3 ),
                StraightLineProgram( [[2,1,1,1,2,1]], 3 ),
                StraightLineProgram( [[2,1,1,1,2,1,1,1]], 3 )],
  p := FLOAT_RAT(1/8),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[1,1],[2,1,1,1,2,1]]], 3 ),
  ),
);
PreSift.Co3[12] := rec(
  # this does 8 -> 1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [[1,0]], 2 ),
                StraightLineProgram( [[1,1]], 2 ),
                StraightLineProgram( [[2,1]], 2 ),
                StraightLineProgram( [[1,2]], 2 ),
                StraightLineProgram( [[2,1,1,1]], 2 ),
                StraightLineProgram( [[1,3]], 2 ),
                StraightLineProgram( [[2,1,1,2]], 2 ),
                StraightLineProgram( [[2,1,1,3]], 2 )],
  p := FLOAT_RAT(1/8),   # FIXME: determine p
  ismember := rec( method := IsMemberIsOne, isdeterministic := true ),
);
 

############################################################################
# Co2
############################################################################

PreSift.Co2 := [];
PreSift.co2 := PreSift.Co2;   # An alias
PreSift.Co2[1] := rec(
  # this goes Co2 -> C(a) * McL, where a is from 2a in M22 
  subgpSLP := # AtlasStraightLineProgram("Co2",3).program + std gens.
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
      [ [ 3,1,4,1 ],5 ],[ [ 3,1,5,1 ],6 ],[ [ 6,1,3,1 ],7 ],
      [ [ 7,1,4,1 ],8 ],[ [ 3,1,8,1 ],9 ],[ [ 9,1,4,1 ],10 ],
      [ [ 10,1,10,1 ],11 ],[ [ 11,1,11,1 ],9 ],[ [ 10,1,11,1 ],8 ],
      [ [ 9,1,8,1 ],1 ],[ [ 3,1,3,1 ],10 ],[ [ 5,1,5,1 ],11 ],
      [ [ 11,1,11,1 ],8 ],[ [ 10,1,8,1 ],9 ],[ [ 6,1,6,1 ],10 ],
      [ [ 10,1,10,1 ],11 ],[ [ 10,1,11,1 ],6 ],[ [ 9,-1 ],8 ],
      [ [ 8,1,6,1 ],10 ],[ [ 10,1,9,1 ],2 ],[ [ 1,1 ],12 ],
      [ [ 2,1 ],13 ],[ [ 12,1 ],1 ],[ [ 13,1 ],2 ],[ [ 1,1,2,1 ],3 ],
      [ [ 3,3,2,1 ],4 ],[ [ 1,1 ],14 ],[ [ 2,1 ],15 ],[ [ 4,3 ],16 ],
      [ [ 14,1 ],1 ],[ [ 15,1 ],2 ],[ [ 16,1 ],3 ],[ [ 1,1,2,1 ],4 ],
      [ [ 1,1,1,1 ],5 ],[ [ 4,1,2,1 ],6 ],[ [ 6,1,3,1 ],7 ],
      [ [ 3,1,5,1 ],8 ],[ [ 3,1,7,1 ],9 ],[ [ 2,1,3,1 ],10 ],
      [ [ 2,1,4,1 ],11 ],[ [ 8,1,9,1 ],12 ],[ [ 3,1,11,1 ],13 ],
      [ [ 2,1,10,1 ],14 ],[ [ 13,1,12,1 ],15 ],[ [ 2,1,15,1 ],16 ],
      [ [ 2,1,3,1 ],17 ],[ [ 17,1,5,1 ],18 ],[ [ 18,1,16,1 ],19 ],
      [ [ 14,1,5,1 ],20 ],[ [ 19,1,20,1 ],21 ],[ [ 21,-1 ],22 ],
      [ [ 22,1,1,1 ],23 ],[ [ 23,1,21,1 ],24 ],[ [ 16,1,14,1 ],25 ],
      [ [ 25,-1 ],26 ],[ [ 26,1,3,1 ],27 ],[ [ 27,1,25,1 ],28 ],
      [ [ 24,1 ],[ 28,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/46 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 49157/115920 ),
      orders := [16, 18, 20, 23, 24, 28],
      ordersslp := [[1,1,0],[2,2,0],[2,3,0],[2,4,0],[1,5,0],[1,6,0],[2,7,0],
                    [2,8,0],[2,9,1],[2,10,1],[2,11,1],[6,9,1],[1,13,1],
                    [3,14,1],],
    ),
  ),
);
PreSift.Co2[2] := rec(
  # this does: C * McL  ->  C * M22
  subgpSLP := # AtlasStraightLineProgram("McL",2)
     StraightLineProgram(
        [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],
          [ [ 3,1,5,1 ],6 ],[ [ 6,1,3,1 ],7 ],[ [ 6,1,7,1 ],2 ],
          [ [ 4,1,4,1 ],5 ],[ [ 5,-1 ],6 ],[ [ 6,1,1,1 ],7 ],
          [ [ 7,1,5,1 ],1 ],[ [ 3,1,3,1 ],5 ],[ [ 5,1,5,1 ],6 ],
          [ [ 6,-1 ],5 ],[ [ 6,1,2,1 ],7 ],[ [ 7,1,5,1 ],2 ],
          [ [ 1,1 ],[ 2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 7/135 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 353/756 ),
      orders := [9, 10, 12, 14, 15, 30],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[1,4,0],[1,5,0],[1,6,0],[2,7,1],
                    [1,8,1],[2,9,1],[2,10,1],[1,11,1],[12,12,1],],
    ),
  ),
);
PreSift.Co2[3] := rec(
  # this does: C * M22  -> C * A7
  subgpSLP := StraightLineProgram( [ [2,1,1,1],
     [ [3,1,2,2,3,3],[2,1,3,1,2,2,3,1,2,1,3,2,2,2],
       [2,2,3,2,2,2,1,1,2,3,1,1,2,1] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/11 ),
  # This is needed further down
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 27/88 ),
      orders := [8,11],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[4,4,1],[3,5,1],],
    ),
  ),
);
PreSift.Co2[4] := rec(
  # this does: C * A7 = C * A6
  subgpSLP := StraightLineProgram( [[[1,2,2,1],[2,1,3,1,1,1]]], 3 ),
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [[1,0]], 3 ),
                StraightLineProgram( [[1,1]], 3 ),
                StraightLineProgram( [[2,1]], 3 ),
                StraightLineProgram( [[3,1]], 3 ),
                StraightLineProgram( [[1,1,2,1]], 3 ),
                StraightLineProgram( [[2,1,3,1]], 3 ),
                StraightLineProgram( [[1,1,2,1,3,1]], 3 )],
  p := FLOAT_RAT( 3/7 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 31/84 ),
      orders := [6,7],
      ordersslp := [[1,1,0],[1,2,0],[3,3,1],[1,4,1],],
    ),
  ),
);
PreSift.Co2[5] := rec(
  # this does: C * A6  ->  C * A5
  subgpSLP := StraightLineProgram( [[[1,1,2,1,1,1],[2,1,1,1,2,2]]], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [[1,0]], 2 ),
                StraightLineProgram( [[1,1]], 2 ),
                StraightLineProgram( [[2,1]], 2 ),
                StraightLineProgram( [[2,2]], 2 ),
                StraightLineProgram( [[1,1,2,2]], 2 ),
                StraightLineProgram( [[2,3]], 2 )],
  p := FLOAT_RAT( 1/3 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 1/4 ),
      orders := [4],
      ordersslp := [[1,1,0],[2,2,1],],
    ),
  ),
);
PreSift.Co2[6] := rec(
  # this does: C * A5  ->  C * 4 = C
  subgpSLP := StraightLineProgram( [[[1,1,2,1],[1,2,2,2,1,1]]], 2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [[1,0]], 2 ), 
                StraightLineProgram( [[1,1]], 2 ),
                StraightLineProgram( [[2,1]], 2 ),
                StraightLineProgram( [[1,2]], 2 ),
                StraightLineProgram( [[2,1,1,1]], 2 ),
                StraightLineProgram( [[2,2]], 2 ),
                StraightLineProgram( [[1,3]], 2 ),
                StraightLineProgram( [[2,1,1,2]], 2 ),
                StraightLineProgram( [[1,1,2,1,1,1]], 2 ),
                StraightLineProgram( [[2,3]], 2 ),
                StraightLineProgram( [[2,1,1,3]], 2 ),
                StraightLineProgram( [[1,1,2,1,1,2]], 2 ),
                StraightLineProgram( [[2,2,1,2]], 2 ),
                StraightLineProgram( [[1,2,2,1,1,1]], 2 ),
                StraightLineProgram( [[1,1,2,1,1,3]], 2 )],
  p := FLOAT_RAT(1/15),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [[[1,2,2,2,1,1]]], 2 ),
    a := StraightLineProgram( [[1,2,2,2,1,1]], 2 ),  # used further up
  ),
);
PreSift.Co2[7] := rec(
  # from now on: x from 24a in C a=x^8 in class 3a, 
  # this does: C  ->  C_C(a) * C_C(x^6) = C_C(a) * 73728
  groupSLP := StraightLineProgram( [ [ 1,1,2,1 ],[ 2,1,1,1 ],[ 2,1,2,1 ],
      [ 3,1,1,1 ],[ 3,1,2,1 ],[ 4,1,2,1 ],[ 5,1,1,1 ],
      [ 6,1,2,1 ],[ 7,1,1,1 ],[ 8,1,2,1 ],[ 9,1,2,1 ],
      [ 10,1,1,1 ],[ 11,1,2,1 ],[ 12,1,2,1 ],[ 13,1,1,1 ],
      [ 13,-1 ],[ 17,1,18,1 ],[ 13,1,2,1 ],[ 14,1,2,1 ],
      [ 15,1,2,1 ],[ 16,1,1,1 ],[ 16,1,2,1 ],[ 20,1,2,1 ],
      [ 21,1,2,1 ],[ 22,1,1,1 ],[ 23,1,2,1 ],[ 24,1,1,1 ],
      [ 25,1,1,1 ],[ 26,1,2,1 ],[ 27,1,2,1 ],[ 28,1,1,1 ],
      [ 29,1,2,1 ],[ 30,1,2,1 ],[ 31,1,1,1 ],[ 32,1,2,1 ],
      [ 33,1,2,1 ],[ 34,1,1,1 ],[ 35,1,1,1 ],[ 36,1,2,1 ],
      [ 37,1,2,1 ],[ 38,1,1,1 ],[ 39,1,2,1 ],[ 40,1,2,1 ],
      [ 41,1,1,1 ],[ 42,1,2,1 ],[ 43,1,2,1 ],[ 44,1,1,1 ],
      [ 45,1,1,1 ],[ 46,1,2,1 ],[ 47,1,1,1 ],[ 47,-1 ],
      [ 52,1,53,1 ],[ 48,1,1,1 ],[ 48,-1 ],[ 55,1,56,1 ],
      [ 49,1,2,1 ],[ 50,1,2,1 ],[ 51,1,2,1 ],[ 58,1,1,1 ],
      [ 58,-1 ],[ 61,1,62,1 ],[ 59,1,1,1 ],[ 60,1,1,1 ],[ 60,-1 ],
      [ 65,1,66,1 ],[ 64,1,2,1 ],[ 68,1,1,1 ],[ 68,-1 ],
      [ 69,1,70,1 ],
      [ [ 19,1 ],[ 54,1 ],[ 57,1 ],[ 63,1 ],[ 67,1 ],[ 71,1 ] ] ],2 ),
  subgpSLP := StraightLineProgram( [ [ [ 1,1 ],[ 2,1,3,1,6,1 ] ] ],6 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/28 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := [StraightLineProgram( [ [1,8] ], 3 ),9],
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram( [ [[1,6]] ], 3 ), 9],
    ),
  ),
);
PreSift.Co2[8] := rec(
  # this does: C_C(a) * C_C(x^6)  ->  C_C(a) * C_C(x^3) = C_C(a) * 768
  subgpSLP := StraightLineProgram(
      [ [ [ 1,1,2,1 ],[ 2,1,1,1,2,1,1,1,2,1,1,1 ], 
          [ 2,2,1,1,2,3,1,1,2,2,1,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/8 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram( [ [[1,3]] ], 3 ), 9],
    ),
  ),
);
PreSift.Co2[9] := rec(
  # this does: C_C(a) * C_C(x^3)  ->  C_C(a) * T * C_C(x) = C_C(a) * T * 24
  # with T = {1,t_2} and C_C(x) < C_C(a) and t_2 * C_C(x) * t_2^-1 < C_C(a)
  subgpSLP := StraightLineProgram( [ [ 1, 1 ] ], 3 ),
  T := [StraightLineProgram( [ [1,0] ], 3 ),
        StraightLineProgram( [ [3,1,1,2,3,2] ], 3 )],
  isdeterministic := true,
  basicsift := BasicSiftCosetRepsWithT,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ], 3 ),
                StraightLineProgram( [ [ 2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,1,3,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,3,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,2 ] ], 3 ),
                StraightLineProgram( [ [ 1,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,1,1,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,1,3,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,2,3,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,1,2,1,3,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,1,3,2 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,1,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,1,1,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,1,2,1,1,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,3,1,1,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,2,1,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,2,3,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,1,1,3,1,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,1,2,3,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,1,1,2,3,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,1,1,3,2 ] ], 3 ),
                StraightLineProgram( [ [ 1,1,2,1,1,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 1,1,3,1,1,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,3,1,1,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,2,1,2,2,1 ] ], 3 ),
                StraightLineProgram( [ [ 2,1,3,1,1,2,3,1 ] ], 3 ),
                StraightLineProgram( [ [ 3,2,1,2,3,1 ] ], 3 )],
  p := FLOAT_RAT( 1/32 ),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [ [[1,8]] ], 3 ), 9],
  ),
);
PreSift.Co2[10] := rec(
  # from here on we start anew with H=C_C(a)=5760
  # this does: H=5760  ->  576
  groupSLP := StraightLineProgram( [ [ 1,1,2,1 ],[ 2,1,1,1 ],[ 2,1,2,1 ],
      [ 3,1,1,1 ],[ 3,1,2,1 ],[ 4,1,2,1 ],[ 5,1,1,1 ],
      [ 6,1,2,1 ],[ 7,1,1,1 ],[ 8,1,2,1 ],[ 9,1,2,1 ],
      [ 10,1,1,1 ],[ 11,1,2,1 ],[ 12,1,2,1 ],[ 13,1,1,1 ],
      [ 13,-1 ],[ 17,1,18,1 ],[ 13,1,2,1 ],[ 14,1,2,1 ],
      [ 15,1,2,1 ],[ 16,1,1,1 ],[ 16,1,2,1 ],[ 20,1,2,1 ],
      [ 21,1,2,1 ],[ 22,1,1,1 ],[ 23,1,2,1 ],[ 24,1,1,1 ],
      [ 25,1,1,1 ],[ 26,1,2,1 ],[ 27,1,2,1 ],[ 28,1,1,1 ],
      [ 29,1,2,1 ],[ 30,1,2,1 ],[ 31,1,1,1 ],[ 32,1,2,1 ],
      [ 33,1,2,1 ],[ 34,1,1,1 ],[ 35,1,1,1 ],[ 36,1,2,1 ],
      [ 37,1,2,1 ],[ 38,1,1,1 ],[ 39,1,2,1 ],[ 40,1,2,1 ],
      [ 41,1,1,1 ],[ 42,1,2,1 ],[ 43,1,2,1 ],[ 44,1,1,1 ],
      [ 45,1,1,1 ],[ 46,1,2,1 ],[ 47,1,1,1 ],[ 47,-1 ],
      [ 52,1,53,1 ],[ 48,1,1,1 ],[ 48,-1 ],[ 55,1,56,1 ],
      [ 49,1,2,1 ],[ 50,1,2,1 ],[ 51,1,2,1 ],[ 58,1,1,1 ],
      [ 58,-1 ],[ 61,1,62,1 ],[ 59,1,1,1 ],[ 60,1,1,1 ],[ 60,-1 ],
      [ 65,1,66,1 ],[ 64,1,2,1 ],[ 68,1,1,1 ],[ 68,-1 ],
      [ 69,1,70,1 ],[ [ 19,1 ],72 ],[ [ 54,1 ],73 ],[ [ 57,1 ],74 ],
      [ [ 63,1 ],75 ],[ [ 67,1 ],76 ],[ [ 71,1 ],77 ],[ [ 72,1 ],1 ],
      [ [ 73,1 ],2 ],[ [ 74,1 ],3 ],[ [ 75,1 ],4 ],[ [ 76,1 ],5 ],
      [ [ 77,1 ],6 ],
      [ [ 1,1,2,1,3,1,6,1 ],[ 4,1,2,1,3,1,1,1,2,1,5,1 ],
        [ 4,1,6,1,1,1,5,1,6,1,4,1 ] ] ],2 ),
  subgpSLP := StraightLineProgram([[[ 3,1 ],[ 1,2 ],[ 1,1,3,1,1,1 ]]],3),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1, 0 ] ], 3 ),
                StraightLineProgram( [ [ 1, 1 ] ], 3 ),
                StraightLineProgram( [ [ 2, 1 ] ], 3 ),
                StraightLineProgram( [ [ 2, 1, 1, 1 ] ], 3 ),
                StraightLineProgram( [ [ 1, 1, 2, 1 ] ], 3 ),
                StraightLineProgram( [ [ 3, 1, 2, 1 ] ], 3 ),
                StraightLineProgram( [ [ 1, 1, 2, 1, 1, 1 ] ], 3 ),
                StraightLineProgram( [ [ 3, 1, 2, 1, 1, 1 ] ], 3 ),
                StraightLineProgram( [ [ 1, 1, 3, 1, 2, 1 ] ], 3 ),
                StraightLineProgram( [ [ 1, 1, 3, 1, 2, 1, 1, 1 ] ], 3 ), ],
  p := FLOAT_RAT( 1/10 ),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [ [1,1,3,1,1,1,3,2], [[4,2]] ], 3 ),
  ),
);
PreSift.Co2[11] := rec(
  # this does: 576  ->  96
  subgpSLP := StraightLineProgram(
        [ [ [ 1,1,3,2 ],[ 1,2,2,1,1,1 ],[ 1,2,3,1,2,1 ] ] ],3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [1, 0] ], 3 ),
                StraightLineProgram( [ [ 1, 1 ] ], 3 ),
                StraightLineProgram( [ [ 2, 1 ] ], 3 ),
                StraightLineProgram( [ [ 3, 1 ] ], 3 ),
                StraightLineProgram( [ [ 1, 2 ] ], 3 ),
                StraightLineProgram( [ [ 3, 1, 1, 1 ] ], 3 ), ],
  p := FLOAT_RAT( 1/6 ),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [ [[1,1,3,1,1,1,3,2]] ], 3 ),10],
  ),
);
PreSift.Co2[12] := rec(
  # this does: 96  ->  24=Center(96)
  subgpSLP := StraightLineProgram( [ [ [ 1, 1 ], [ 2, 2 ] ] ], 3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1, 0 ] ], 3 ),
                StraightLineProgram( [ [ 2, 1 ] ], 3 ),
                StraightLineProgram( [ [ 3, 1 ] ], 3 ),
                StraightLineProgram( [ [ 3, 1, 2, 1 ] ], 3 ), ],
  p := FLOAT_RAT( 1/4 ),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := StraightLineProgram( [ [[1,1],[2,1],[3,1]] ], 3 ),
    # the full center!
  ),
);
PreSift.Co2[13] := rec(
  # this does: 24  ->  1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1, 0 ] ], 2 ),
                StraightLineProgram( [ [ 1, 1 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1 ] ], 2 ),
                StraightLineProgram( [ [ 1, 2 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1, 1, 1 ] ], 2 ),
                StraightLineProgram( [ [ 2, 2 ] ], 2 ),
                StraightLineProgram( [ [ 1, 3 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1, 1, 2 ] ], 2 ),
                StraightLineProgram( [ [ 2, 2, 1, 1 ] ], 2 ),
                StraightLineProgram( [ [ 2, 3 ] ], 2 ),
                StraightLineProgram( [ [ 1, 4 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1, 1, 3 ] ], 2 ),
                StraightLineProgram( [ [ 2, 2, 1, 2 ] ], 2 ),
                StraightLineProgram( [ [ 2, 3, 1, 1 ] ], 2 ),
                StraightLineProgram( [ [ 1, 5 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1, 1, 4 ] ], 2 ),
                StraightLineProgram( [ [ 2, 2, 1, 3 ] ], 2 ),
                StraightLineProgram( [ [ 2, 3, 1, 2 ] ], 2 ),
                StraightLineProgram( [ [ 1, 6 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1, 1, 5 ] ], 2 ),
                StraightLineProgram( [ [ 2, 3, 1, 3 ] ], 2 ),
                StraightLineProgram( [ [ 1, 7 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1, 1, 6 ] ], 2 ),
                StraightLineProgram( [ [ 2, 1, 1, 7 ] ], 2 ), ],
  p := FLOAT_RAT( 1/25 ),   # FIXME: determine p
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);


############################################################################
# HS, using class 2a with centralizer 7680
############################################################################

PreSift.HS := [];
PreSift.hs := PreSift.HS;    # an alias
PreSift.HS[1] := rec(
  # this does: HS  ->  C * M22, where C = C_HS(2a) = 7680
  subgpSLP :=      # AtlasStraightLineProgram("HS",1)
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 2,1,5,1 ],6 ],[ [ 6,1,6,1 ],2 ],
          [ [ 4,1,4,1 ],5 ],[ [ 4,1,5,1 ],6 ],[ [ 5,1,6,1 ],4 ],
          [ [ 4,1,2,1 ],3 ],[ [ 3,1,4,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 7/20 ),
      orders := [ 10, 12, 15, 20 ],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[1,4,0],[1,5,0],[4,6,1],[2,7,1],
   [3,8,1],[5,9,1],],
    ),
  ),
);
PreSift.HS[2] := rec(
  # this does: C * M22  ->  C * L3(4)
  subgpSLP :=     # AtlasStraightLineProgram("M22",1)
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 5,1,5,1 ],6 ],[ [ 3,3 ],7 ],
          [ [ 7,1,6,1 ],8 ],[ [ 8,-1 ],9 ],[ [ 9,1,2,1 ],10 ],
          [ [ 10,1,8,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 3/11 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 103/264 ),
      orders := [ 6, 8, 11 ],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[2,4,1],[2,5,1],[3,6,1],],
    ),
  ),
);
PreSift.HS[3] := rec(
  # this does: C * L3(4)  ->  C * A6
  subgpSLP :=      # AtlasStraightLineProgram("L3(4)",3)
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 5,1,2,1 ],3 ],[ [ 3,1,5,1 ],2 ],
          [ [ 1,1 ],[ 2,1 ] ] ], 2 ),
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
      orders := [ 7 ],
      ordersslp := [[1,1,0],[1,2,0],[1,3,0],[3,4,1],],
    ),
  ),
);
PreSift.HS[4] := rec(
  # this does: C * A6  ->  C * A5
  subgpSLP := StraightLineProgram( [ [ [ 1,1,2,1 ],[ 2,1,1,1,2,2,1,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1,2,1,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/3 ),
  ismember := rec(
    isdeterministic := false,
    method := IsMemberConjugates,
    a := "fromDown",
    ismember := rec(
      method := IsMemberOrders,
      p0 := FLOAT_RAT( 1/4 ),
      orders := [ 4 ],
      ordersslp := [[1,1,0],[2,2,1],],
    ),
  ),
);
PreSift.HS[5] := rec(
  # this does: C * A5  ->  C * 12, where 2^2 < 12 < A5 with 2^2 = C_A5(a)
  # note, that we only need a transversal of 12 in A5 but can do the
  # ismember test by testing for C_A5(x) where x is an element of order 3
  # in 12, because 12 is 2^2.3^1 (semidirect) and 2^2 < C
  subgpSLP := StraightLineProgram( [ [ [ 1,1,2,1 ],[ 2,1,1,3 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),],
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram( [[1,1,2,1]], 2 ),   # element from 2a
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram( [[1,1,2,1]], 2 )],
      # this is again a, because a^A5 = C_A5(a) \ {1}
    ),
  ),
);
PreSift.HS[6] := rec(
  # this does: C * 12  ->  C * 2^2 = C
  subgpSLP := TrivialSubgroup,   # not needed here
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),],
  p := FLOAT_RAT( 1/3 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [[1,1]], 2 )],
  ),
);
PreSift.HS[7] := rec(
  # this does C = 7680  ->  3840 = C_C(4b)
  groupSLP := StraightLineProgram( 
                [ [ [ 2,4,1,1,2,3,1,1,2,2,1,1,2,1 ],[ 1,1,2,1,1,1,2,3,
                          1,1,2,2,1,1,2,3,1,1,2,2,1,1,2,1,1,1 ] ] ],2 ),
  subgpSLP := StraightLineProgram( [ [ [ 2,1 ],[ 1,1,2,1,1,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/2 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [[1,1,2,1],[3,2,2,1],[4,3]], 2 )],
  ),
);
PreSift.HS[8] := rec(
  # this does 3840  ->  256 = N(8a^2)
  subgpSLP := StraightLineProgram(
                  [ [ [ 1,1,2,4 ],[ 1,2,2,3,1,1 ],[ 1,3,2,1,1,1,2,2 ],
                        [ 1,3,2,2,1,2,2,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,3 ] ],2 ),
                StraightLineProgram( [ [ 1,4 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,3 ] ],2 ),],
  p := FLOAT_RAT( 1/15 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberNormalizerOfCyclicSubgroup,
    generator := StraightLineProgram( [[1,3,2,1,1,1,2,2],[3,2]], 2 ),
    conjugates := StraightLineProgram( [[1,3,2,1,1,1,2,2],[[3,-2]]], 2 )
  ),
);
PreSift.HS[9] := rec(
  # this does 256  ->  128 = C(8a^2)
  subgpSLP := StraightLineProgram( [ [ [ 1,1 ],[ 2,1 ],[ 3,1 ] ] ],4 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],4 ),
                StraightLineProgram( [ [ 4,1 ] ],4 ),],
  p := FLOAT_RAT( 1/2 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [[1,3,2,1,1,1,2,2],[[3,2]]], 2 ),8],
  ),
);
PreSift.HS[10] := rec(
  # this does 128  ->  16 = C(8a)
  subgpSLP := StraightLineProgram( [ [ [ 3,1 ],[ 1,2 ] ] ],3 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],3 ),
                StraightLineProgram( [ [ 1,1 ] ],3 ),
                StraightLineProgram( [ [ 2,1 ] ],3 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],3 ),
                StraightLineProgram( [ [ 2,2 ] ],3 ),
                StraightLineProgram( [ [ 3,1,2,1 ] ],3 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],3 ),
                StraightLineProgram( [ [ 3,1,2,1,1,1 ] ],3 ),],
  p := FLOAT_RAT( 1/8 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram( [[[1,3,2,1,1,1,2,2]]], 2 ),8],
  ),
);
PreSift.HS[11] := rec(
  # this does 16  ->  1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,4 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,3 ] ],2 ),
                StraightLineProgram( [ [ 1,5 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,4 ] ],2 ),
                StraightLineProgram( [ [ 1,6 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,5 ] ],2 ),
                StraightLineProgram( [ [ 1,7 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,6 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,7 ] ],2 ),],
  p := FLOAT_RAT( 1/16 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);

############################################################################
# Ly, using class 3a
############################################################################

PreSift.Ly := [];
PreSift.ly := PreSift.Ly;    # an alias
PreSift.Ly[1] := rec(
  # Let G := Ly
  # Let a be in 3A of G and C = C_G(a) = 3.McL
  # this does: Ly  ->  C * x * 3.McL    (with a possible exit to C)
  subgpSLP := # this is AtlasStraightLineProgram("McL.2") o AtlasSLP("Ly",2)
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 2,1,5,1 ],6 ],[ [ 3,1,5,1 ],7 ],
          [ [ 7,1,3,1 ],8 ],[ [ 8,1,8,1 ],9 ],[ [ 8,1,9,1 ],2 ],
          [ [ 7,15 ],3 ],[ [ 3,-1 ],4 ],[ [ 3,1,1,1 ],5 ],
          [ [ 5,1,4,1 ],1 ],[ [ 6,12 ],9 ],[ [ 9,-1 ],8 ],
          [ [ 8,1,2,1 ],3 ],[ [ 3,1,9,1 ],2 ],[ [ 1,1 ],10 ],
          [ [ 2,1 ],11 ],[ [ 10,1 ],1 ],[ [ 11,1 ],2 ],[ [ 1,1,2,1 ],3 ],
          [ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],[ [ 3,1,5,1 ],6 ],
          [ [ 6,1,3,1 ],7 ],[ [ 6,1,7,1 ],8 ],[ [ 8,12 ],1 ],
          [ [ 5,3 ],2 ],[ [ 4,3 ],5 ],[ [ 5,-1 ],6 ],[ [ 6,1,2,1 ],7 ],
          [ [ 7,1,5,1 ],2 ],[ [ 3,-1 ],4 ],[ [ 4,1,1,1 ],5 ],
          [ [ 5,1,3,1 ],1 ],[ [ 1,1 ],[ 2,1 ] ] ],2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 15401/9606125 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := [StraightLineProgram([[1,1,2,1],[3,11]],2),2],
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [[StraightLineProgram([[1,1,2,1],[3,11]],2),2]],
    ),
  ),
  y := [StraightLineProgram( [[1,1,2,2],[2,1,1,1,2,1,3,4],[4,-1]], 2 ),2],
  specialaction := function(sr,i,ret)
    local s,e,x;
    x := sr[i].ismember.a^ret.new;
    GeneralizedSiftProfile.Multiplications[i] :=
      GeneralizedSiftProfile.Multiplications[i] + 2;
    GeneralizedSiftProfile.Inversions[i] :=
      GeneralizedSiftProfile.Inversions[i]+1;
    if x = sr[i].ismember.a then
        ret.action := "GOTO";   # go on in the centraliser of a
        ret.to := 6;
        return;
    elif x = sr[i].ismember.a^-1 then
        # we modify
        e := sr[1].y;
        ret.el := ret.el * e;
        ret.new := ret.new * e;
        GeneralizedSiftProfile.Multiplications[i] :=
           GeneralizedSiftProfile.Multiplications[i] + 2;
        Add(ret.slp,sr[1].ySLP);
        ret.action := "GOTO";   # go on in the centraliser of a
        ret.to := 6;
        return;
    else
        return;
    fi;
  end,
);
# Note that by the specialaction above we know now that we are in "the long"
# 3-class in 3.Mcl (and not in the center)!
PreSift.Ly[2] := rec(
  # this does: C * x * 3.McL  ->  C * x * 2.A8
  subgpSLP :=    # this is AtlasStraightLineProgram( "McL", 8)
    StraightLineProgram( 
        [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],1 ],
          [ [ 4,1,3,1 ],2 ],[ [ 1,7 ],3 ],[ [ 2,7 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 5,1,5,1 ],3 ],[ [ 3,-1 ],4 ],
          [ [ 4,1,2,1 ],5 ],[ [ 5,1,3,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/275 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram([[1,1,2,1],[3,1,2,1],[3,1,4,1],[5,7]],2)],
    ),
  ),
);
# Note that the centraliser of the involution above is 3x2.A8, however,
# we automatically reach 2.A8, since we have already excluded the
# central classes above and 3c lies completely in 2.A8 (see powermaps).
PreSift.Ly[3] := rec(
  # this does: C * x * 2.A8  ->  C * {t1,t2,t3} * 3x(2.A5)
  subgpSLP := StraightLineProgram([[[2,2,1,1,2,1,1,1,2,2],
                                    [1,1,2,2,1,2,2,2,1,1]]],2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 11/56 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram([[2,2,1,1,2,1,1,1,2,2],[3,20]],2)],
    ),
  ),
);
PreSift.Ly[4] := rec(
  # this does: C * {t1,t2,t3} * 3x(2.A5)  ->  C * {t1,t2,t3} * 3x(2.S3)
  subgpSLP := StraightLineProgram([[[1,1,2,1],[1,3,2,1,1,3,2,1,1,1]]],2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/10 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := StraightLineProgram([[1,6,2,1]],2),
      conjugates := StraightLineProgram([[1,6,2,1],[[3,1],[3,-1]]],2),
    ),
  ),
);
PreSift.Ly[5] := rec(
  # this does: C * {t1,t2,t3} * 3x(2.S3)  ->  C * {t1,t2,t3,t4} * 6x3
  subgpSLP := StraightLineProgram( [ [ [ 1,1 ],[ 2,2 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),],
  p := FLOAT_RAT( 1/2 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberSetWithExtraEls,
      set := [StraightLineProgram([[1,3,2,2]],2),
              StraightLineProgram([[2,1,1,1,2,1]],2),
              StraightLineProgram([[1,1,2,2]],2),
              StraightLineProgram([[2,4]],2)],
    ),
    extraels := [
    [StraightLineProgram( [ [ 1,1,2,2 ],[ 1,1,2,1 ],[ [ 1,1 ],5 ],
          [ [ 2,1 ],6 ],[ [ 5,1,6,1 ],7 ],[ [ 7,1,6,1 ],8 ],
          [ [ 7,1,8,1 ],9 ],[ [ 6,1,9,1 ],10 ],[ [ 7,1,9,1 ],11 ],
          [ [ 11,1,7,1 ],12 ],[ [ 12,1,12,1 ],13 ],[ [ 12,1,13,1 ],6 ],
          [ [ 11,15 ],7 ],[ [ 7,-1 ],8 ],[ [ 7,1,5,1 ],9 ],
          [ [ 9,1,8,1 ],5 ],[ [ 10,12 ],13 ],[ [ 13,-1 ],12 ],
          [ [ 12,1,6,1 ],7 ],[ [ 7,1,13,1 ],6 ],[ [ 5,1 ],14 ],
          [ [ 6,1 ],15 ],[ [ 14,1 ],5 ],[ [ 15,1 ],6 ],[ [ 5,1,6,1 ],7 ],
          [ [ 7,1,6,1 ],8 ],[ [ 7,1,8,1 ],9 ],[ [ 7,1,9,1 ],10 ],
          [ [ 10,1,7,1 ],11 ],[ [ 10,1,11,1 ],12 ],[ [ 12,12 ],5 ],
          [ [ 9,3 ],6 ],[ [ 8,3 ],9 ],[ [ 9,-1 ],10 ],
          [ [ 10,1,6,1 ],11 ],[ [ 11,1,9,1 ],6 ],[ [ 7,-1 ],8 ],
          [ [ 8,1,5,1 ],9 ],[ [ 9,1,7,1 ],5 ],[ [ 5,1 ],16 ],
          [ [ 6,1 ],17 ],[ [ 16,1 ],5 ],[ [ 17,1 ],6 ],[ [ 1,1 ],18 ],
          [ [ 2,1 ],19 ],[ [ 18,1,19,1 ],20 ],[ [ 20,1,19,1 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 19,1,22,1 ],23 ],
          [ [ 20,1,22,1 ],24 ],[ [ 24,1,20,1 ],25 ],
          [ [ 25,1,25,1 ],26 ],[ [ 25,1,26,1 ],19 ],[ [ 24,15 ],20 ],
          [ [ 20,-1 ],21 ],[ [ 20,1,18,1 ],22 ],[ [ 22,1,21,1 ],18 ],
          [ [ 23,12 ],26 ],[ [ 26,-1 ],25 ],[ [ 25,1,19,1 ],20 ],
          [ [ 20,1,26,1 ],19 ],[ [ 18,1 ],27 ],[ [ 19,1 ],28 ],
          [ [ 27,1 ],18 ],[ [ 28,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],22 ],
          [ [ 20,1,22,1 ],23 ],[ [ 23,1,20,1 ],24 ],
          [ [ 23,1,24,1 ],25 ],[ [ 25,12 ],18 ],[ [ 22,3 ],19 ],
          [ [ 21,3 ],22 ],[ [ 22,-1 ],23 ],[ [ 23,1,19,1 ],24 ],
          [ [ 24,1,22,1 ],19 ],[ [ 20,-1 ],21 ],[ [ 21,1,18,1 ],22 ],
          [ [ 22,1,20,1 ],18 ],[ [ 18,1 ],29 ],[ [ 19,1 ],30 ],
          [ [ 29,1 ],18 ],[ [ 30,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],18 ],
          [ [ 21,1,20,1 ],19 ],[ [ 18,7 ],20 ],[ [ 19,7 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 22,1,22,1 ],20 ],[ [ 20,-1 ],21 ],
          [ [ 21,1,19,1 ],22 ],[ [ 22,1,20,1 ],19 ],[ [ 18,1 ],23 ],
          [ [ 19,1 ],24 ],[ [ 23,1 ],18 ],[ [ 24,1 ],19 ],
          [ 18,-1,19,-1,18,-1,19,-3,6,-1,5,-1,6,-2,5,-1,6,-3,4,-2,3,-3 ]],2),1],
    [StraightLineProgram( [ [ 1,1,2,2 ],[ 1,1,2,1 ],[ [ 1,1 ],5 ],
          [ [ 2,1 ],6 ],[ [ 5,1,6,1 ],7 ],[ [ 7,1,6,1 ],8 ],
          [ [ 7,1,8,1 ],9 ],[ [ 6,1,9,1 ],10 ],[ [ 7,1,9,1 ],11 ],
          [ [ 11,1,7,1 ],12 ],[ [ 12,1,12,1 ],13 ],[ [ 12,1,13,1 ],6 ],
          [ [ 11,15 ],7 ],[ [ 7,-1 ],8 ],[ [ 7,1,5,1 ],9 ],
          [ [ 9,1,8,1 ],5 ],[ [ 10,12 ],13 ],[ [ 13,-1 ],12 ],
          [ [ 12,1,6,1 ],7 ],[ [ 7,1,13,1 ],6 ],[ [ 5,1 ],14 ],
          [ [ 6,1 ],15 ],[ [ 14,1 ],5 ],[ [ 15,1 ],6 ],[ [ 5,1,6,1 ],7 ],
          [ [ 7,1,6,1 ],8 ],[ [ 7,1,8,1 ],9 ],[ [ 7,1,9,1 ],10 ],
          [ [ 10,1,7,1 ],11 ],[ [ 10,1,11,1 ],12 ],[ [ 12,12 ],5 ],
          [ [ 9,3 ],6 ],[ [ 8,3 ],9 ],[ [ 9,-1 ],10 ],
          [ [ 10,1,6,1 ],11 ],[ [ 11,1,9,1 ],6 ],[ [ 7,-1 ],8 ],
          [ [ 8,1,5,1 ],9 ],[ [ 9,1,7,1 ],5 ],[ [ 5,1 ],16 ],
          [ [ 6,1 ],17 ],[ [ 16,1 ],5 ],[ [ 17,1 ],6 ],[ [ 1,1 ],18 ],
          [ [ 2,1 ],19 ],[ [ 18,1,19,1 ],20 ],[ [ 20,1,19,1 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 19,1,22,1 ],23 ],
          [ [ 20,1,22,1 ],24 ],[ [ 24,1,20,1 ],25 ],
          [ [ 25,1,25,1 ],26 ],[ [ 25,1,26,1 ],19 ],[ [ 24,15 ],20 ],
          [ [ 20,-1 ],21 ],[ [ 20,1,18,1 ],22 ],[ [ 22,1,21,1 ],18 ],
          [ [ 23,12 ],26 ],[ [ 26,-1 ],25 ],[ [ 25,1,19,1 ],20 ],
          [ [ 20,1,26,1 ],19 ],[ [ 18,1 ],27 ],[ [ 19,1 ],28 ],
          [ [ 27,1 ],18 ],[ [ 28,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],22 ],
          [ [ 20,1,22,1 ],23 ],[ [ 23,1,20,1 ],24 ],
          [ [ 23,1,24,1 ],25 ],[ [ 25,12 ],18 ],[ [ 22,3 ],19 ],
          [ [ 21,3 ],22 ],[ [ 22,-1 ],23 ],[ [ 23,1,19,1 ],24 ],
          [ [ 24,1,22,1 ],19 ],[ [ 20,-1 ],21 ],[ [ 21,1,18,1 ],22 ],
          [ [ 22,1,20,1 ],18 ],[ [ 18,1 ],29 ],[ [ 19,1 ],30 ],
          [ [ 29,1 ],18 ],[ [ 30,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],18 ],
          [ [ 21,1,20,1 ],19 ],[ [ 18,7 ],20 ],[ [ 19,7 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 22,1,22,1 ],20 ],[ [ 20,-1 ],21 ],
          [ [ 21,1,19,1 ],22 ],[ [ 22,1,20,1 ],19 ],[ [ 18,1 ],23 ],
          [ [ 19,1 ],24 ],[ [ 23,1 ],18 ],[ [ 24,1 ],19 ],
          [ [ 19,2,18,1,19,1,18,1,19,2 ],20 ],
          [ [ 18,1,19,2,18,2,19,2,18,1 ],21 ],[ [ 20,1 ],18 ],
          [ [ 21,1 ],19 ],[19,-1,6,-1,5,-1,6,-2,5,-1,6,-3,4,-2,3,-3]],2),1],
    [StraightLineProgram( [ [ 1,1,2,2 ],[ 1,1,2,1 ],[ [ 1,1 ],5 ],
          [ [ 2,1 ],6 ],[ [ 5,1,6,1 ],7 ],[ [ 7,1,6,1 ],8 ],
          [ [ 7,1,8,1 ],9 ],[ [ 6,1,9,1 ],10 ],[ [ 7,1,9,1 ],11 ],
          [ [ 11,1,7,1 ],12 ],[ [ 12,1,12,1 ],13 ],[ [ 12,1,13,1 ],6 ],
          [ [ 11,15 ],7 ],[ [ 7,-1 ],8 ],[ [ 7,1,5,1 ],9 ],
          [ [ 9,1,8,1 ],5 ],[ [ 10,12 ],13 ],[ [ 13,-1 ],12 ],
          [ [ 12,1,6,1 ],7 ],[ [ 7,1,13,1 ],6 ],[ [ 5,1 ],14 ],
          [ [ 6,1 ],15 ],[ [ 14,1 ],5 ],[ [ 15,1 ],6 ],[ [ 5,1,6,1 ],7 ],
          [ [ 7,1,6,1 ],8 ],[ [ 7,1,8,1 ],9 ],[ [ 7,1,9,1 ],10 ],
          [ [ 10,1,7,1 ],11 ],[ [ 10,1,11,1 ],12 ],[ [ 12,12 ],5 ],
          [ [ 9,3 ],6 ],[ [ 8,3 ],9 ],[ [ 9,-1 ],10 ],
          [ [ 10,1,6,1 ],11 ],[ [ 11,1,9,1 ],6 ],[ [ 7,-1 ],8 ],
          [ [ 8,1,5,1 ],9 ],[ [ 9,1,7,1 ],5 ],[ [ 5,1 ],16 ],
          [ [ 6,1 ],17 ],[ [ 16,1 ],5 ],[ [ 17,1 ],6 ],[ [ 1,1 ],18 ],
          [ [ 2,1 ],19 ],[ [ 18,1,19,1 ],20 ],[ [ 20,1,19,1 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 19,1,22,1 ],23 ],
          [ [ 20,1,22,1 ],24 ],[ [ 24,1,20,1 ],25 ],
          [ [ 25,1,25,1 ],26 ],[ [ 25,1,26,1 ],19 ],[ [ 24,15 ],20 ],
          [ [ 20,-1 ],21 ],[ [ 20,1,18,1 ],22 ],[ [ 22,1,21,1 ],18 ],
          [ [ 23,12 ],26 ],[ [ 26,-1 ],25 ],[ [ 25,1,19,1 ],20 ],
          [ [ 20,1,26,1 ],19 ],[ [ 18,1 ],27 ],[ [ 19,1 ],28 ],
          [ [ 27,1 ],18 ],[ [ 28,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],22 ],
          [ [ 20,1,22,1 ],23 ],[ [ 23,1,20,1 ],24 ],
          [ [ 23,1,24,1 ],25 ],[ [ 25,12 ],18 ],[ [ 22,3 ],19 ],
          [ [ 21,3 ],22 ],[ [ 22,-1 ],23 ],[ [ 23,1,19,1 ],24 ],
          [ [ 24,1,22,1 ],19 ],[ [ 20,-1 ],21 ],[ [ 21,1,18,1 ],22 ],
          [ [ 22,1,20,1 ],18 ],[ [ 18,1 ],29 ],[ [ 19,1 ],30 ],
          [ [ 29,1 ],18 ],[ [ 30,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],18 ],
          [ [ 21,1,20,1 ],19 ],[ [ 18,7 ],20 ],[ [ 19,7 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 22,1,22,1 ],20 ],[ [ 20,-1 ],21 ],
          [ [ 21,1,19,1 ],22 ],[ [ 22,1,20,1 ],19 ],[ [ 18,1 ],23 ],
          [ [ 19,1 ],24 ],[ [ 23,1 ],18 ],[ [ 24,1 ],19 ],
          [ 18,-1,19,-2,6,-1,5,-1,6,-2,5,-1,6,-3,4,-2,3,-3 ]],2),1],
    [StraightLineProgram( [ [ 1,1,2,2 ],[ 1,1,2,1 ],[ [ 1,1 ],5 ],
          [ [ 2,1 ],6 ],[ [ 5,1,6,1 ],7 ],[ [ 7,1,6,1 ],8 ],
          [ [ 7,1,8,1 ],9 ],[ [ 6,1,9,1 ],10 ],[ [ 7,1,9,1 ],11 ],
          [ [ 11,1,7,1 ],12 ],[ [ 12,1,12,1 ],13 ],[ [ 12,1,13,1 ],6 ],
          [ [ 11,15 ],7 ],[ [ 7,-1 ],8 ],[ [ 7,1,5,1 ],9 ],
          [ [ 9,1,8,1 ],5 ],[ [ 10,12 ],13 ],[ [ 13,-1 ],12 ],
          [ [ 12,1,6,1 ],7 ],[ [ 7,1,13,1 ],6 ],[ [ 5,1 ],14 ],
          [ [ 6,1 ],15 ],[ [ 14,1 ],5 ],[ [ 15,1 ],6 ],[ [ 5,1,6,1 ],7 ],
          [ [ 7,1,6,1 ],8 ],[ [ 7,1,8,1 ],9 ],[ [ 7,1,9,1 ],10 ],
          [ [ 10,1,7,1 ],11 ],[ [ 10,1,11,1 ],12 ],[ [ 12,12 ],5 ],
          [ [ 9,3 ],6 ],[ [ 8,3 ],9 ],[ [ 9,-1 ],10 ],
          [ [ 10,1,6,1 ],11 ],[ [ 11,1,9,1 ],6 ],[ [ 7,-1 ],8 ],
          [ [ 8,1,5,1 ],9 ],[ [ 9,1,7,1 ],5 ],[ [ 5,1 ],16 ],
          [ [ 6,1 ],17 ],[ [ 16,1 ],5 ],[ [ 17,1 ],6 ],[ [ 1,1 ],18 ],
          [ [ 2,1 ],19 ],[ [ 18,1,19,1 ],20 ],[ [ 20,1,19,1 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 19,1,22,1 ],23 ],
          [ [ 20,1,22,1 ],24 ],[ [ 24,1,20,1 ],25 ],
          [ [ 25,1,25,1 ],26 ],[ [ 25,1,26,1 ],19 ],[ [ 24,15 ],20 ],
          [ [ 20,-1 ],21 ],[ [ 20,1,18,1 ],22 ],[ [ 22,1,21,1 ],18 ],
          [ [ 23,12 ],26 ],[ [ 26,-1 ],25 ],[ [ 25,1,19,1 ],20 ],
          [ [ 20,1,26,1 ],19 ],[ [ 18,1 ],27 ],[ [ 19,1 ],28 ],
          [ [ 27,1 ],18 ],[ [ 28,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],22 ],
          [ [ 20,1,22,1 ],23 ],[ [ 23,1,20,1 ],24 ],
          [ [ 23,1,24,1 ],25 ],[ [ 25,12 ],18 ],[ [ 22,3 ],19 ],
          [ [ 21,3 ],22 ],[ [ 22,-1 ],23 ],[ [ 23,1,19,1 ],24 ],
          [ [ 24,1,22,1 ],19 ],[ [ 20,-1 ],21 ],[ [ 21,1,18,1 ],22 ],
          [ [ 22,1,20,1 ],18 ],[ [ 18,1 ],29 ],[ [ 19,1 ],30 ],
          [ [ 29,1 ],18 ],[ [ 30,1 ],19 ],[ [ 18,1,19,1 ],20 ],
          [ [ 20,1,19,1 ],21 ],[ [ 20,1,21,1 ],18 ],
          [ [ 21,1,20,1 ],19 ],[ [ 18,7 ],20 ],[ [ 19,7 ],21 ],
          [ [ 20,1,21,1 ],22 ],[ [ 22,1,22,1 ],20 ],[ [ 20,-1 ],21 ],
          [ [ 21,1,19,1 ],22 ],[ [ 22,1,20,1 ],19 ],[ [ 18,1 ],23 ],
          [ [ 19,1 ],24 ],[ [ 23,1 ],18 ],[ [ 24,1 ],19 ],
          [ 18,-3,6,-1,5,-1,6,-2,5,-1,6,-3,4,-2,3,-3 ]],2),1]],
  ),
  specialaction := GenSift.SpecialActionUseIsMemberInfo,
);
# From now on we are back in C and use a from class 3C to go down to
# CC := C_C(a)=87480 analogously as above:
PreSift.Ly[6] := rec(
  # this does: 3.McL  ->  CC * 2.A8
  groupSLP :=    # this is Ly[1].subgpSLP from above!
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 2,1,5,1 ],6 ],[ [ 3,1,5,1 ],7 ],
          [ [ 7,1,3,1 ],8 ],[ [ 8,1,8,1 ],9 ],[ [ 8,1,9,1 ],2 ],
          [ [ 7,15 ],3 ],[ [ 3,-1 ],4 ],[ [ 3,1,1,1 ],5 ],
          [ [ 5,1,4,1 ],1 ],[ [ 6,12 ],9 ],[ [ 9,-1 ],8 ],
          [ [ 8,1,2,1 ],3 ],[ [ 3,1,9,1 ],2 ],[ [ 1,1 ],10 ],
          [ [ 2,1 ],11 ],[ [ 10,1 ],1 ],[ [ 11,1 ],2 ],[ [ 1,1,2,1 ],3 ],
          [ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],[ [ 3,1,5,1 ],6 ],
          [ [ 6,1,3,1 ],7 ],[ [ 6,1,7,1 ],8 ],[ [ 8,12 ],1 ],
          [ [ 5,3 ],2 ],[ [ 4,3 ],5 ],[ [ 5,-1 ],6 ],[ [ 6,1,2,1 ],7 ],
          [ [ 7,1,5,1 ],2 ],[ [ 3,-1 ],4 ],[ [ 4,1,1,1 ],5 ],
          [ [ 5,1,3,1 ],1 ],[ [ 1,1 ],[ 2,1 ] ] ],2 ),
  subgpSLP :=    # this is AtlasStraightLineProgram( "McL", 8)
    StraightLineProgram( 
        [ [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],1 ],
          [ [ 4,1,3,1 ],2 ],[ [ 1,7 ],3 ],[ [ 2,7 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 5,1,5,1 ],3 ],[ [ 3,-1 ],4 ],
          [ [ 4,1,2,1 ],5 ],[ [ 5,1,3,1 ],2 ],[ [ 1,1 ],[ 2,1 ] ] ], 2 ),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 1/275 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := [StraightLineProgram( [ [[1,1,2,2],14],[[1,1,2,1],15],[[14,3,15,2],16],
          [ [ 1,1,2,1 ],3 ],[ [ 3,1,2,1 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 2,1,5,1 ],6 ],[ [ 3,1,5,1 ],7 ],
          [ [ 7,1,3,1 ],8 ],[ [ 8,1,8,1 ],9 ],[ [ 8,1,9,1 ],2 ],
          [ [ 7,15 ],3 ],[ [ 3,-1 ],4 ],[ [ 3,1,1,1 ],5 ],
          [ [ 5,1,4,1 ],1 ],[ [ 6,12 ],9 ],[ [ 9,-1 ],8 ],
          [ [ 8,1,2,1 ],3 ],[ [ 3,1,9,1 ],2 ],[ [ 1,1 ],10 ],
          [ [ 2,1 ],11 ],[ [ 10,1 ],1 ],[ [ 11,1 ],2 ],[ [ 1,1,2,1 ],3 ],
          [ [ 3,1,2,1 ],4 ],[ [ 3,1,4,1 ],5 ],[ [ 3,1,5,1 ],6 ],
          [ [ 6,1,3,1 ],7 ],[ [ 6,1,7,1 ],8 ],[ [ 8,12 ],1 ],
          [ [ 5,3 ],2 ],[ [ 4,3 ],5 ],[ [ 5,-1 ],6 ],[ [ 6,1,2,1 ],7 ],
          [ [ 7,1,5,1 ],2 ],[ [ 3,-1 ],4 ],[ [ 4,1,1,1 ],5 ],
          [ [ 5,1,3,1 ],1 ],[ [ 1,1 ],12 ],[ [ 2,1 ],13 ],[ [ 12,1 ],1 ],
          [ [ 13,1 ],2 ],[ [ 1,1,2,1 ],3 ],[ [ 3,11 ],4 ],
          [16,-1,4,1,16,1] ],2 ),1],
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram([[1,1,2,1],[3,1,2,1],[3,1,4,1],[5,7]],2)],
    ),
  ),
);
# Note that the centraliser of the involution above is 3x2.A8, however,
# we automatically reach 2.A8, since we have already excluded the
# central classes above and 3c lies completely in 2.A8 (see powermaps).
PreSift.Ly[7] := rec(
  # this does: CC * 2.A8  ->  CC * {t1,t2,t3} * 3x(2.A5)
  subgpSLP := StraightLineProgram([[[2,2,1,1,2,1,1,1,2,2],
                                    [1,1,2,2,1,2,2,2,1,1]]],2),
  isdeterministic := false,
  basicsift := BasicSiftRandom,
  p := FLOAT_RAT( 11/56 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberCentralizer,
      centof := [StraightLineProgram([[2,2,1,1,2,1,1,1,2,2],[3,20]],2)],
    ),
  ),
);
PreSift.Ly[8] := rec(
  # this does: CC * {t1,t2,t3} * (A5x3):2  ->  CC * {t1,t2,t3} * 3x(2.S3)
  subgpSLP := StraightLineProgram([[[1,1,2,1],[1,3,2,1,1,3,2,1,1,1]]],2),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,3 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1,1,1 ] ],2 ),],
  p := FLOAT_RAT( 1/10 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberNormalizerOfCyclicSubgroup,
      generator := StraightLineProgram([[1,6,2,1]],2),
      conjugates := StraightLineProgram([[1,6,2,1],[[3,1],[3,-1]]],2),
    ),
  ),
);
PreSift.Ly[9] := rec(
  # this does: CC * {t1,t2,t3} * 3x(2.S3)  ->  CC * {t1,t2,t3,t4} * 6x3
  subgpSLP := StraightLineProgram( [ [ [ 1,1 ],[ 2,2 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),],
  p := FLOAT_RAT( 1/2 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := "fromUp",
    ismember := rec(
      method := IsMemberSetWithExtraEls,
      set := [StraightLineProgram([[1,3,2,2]],2),
              StraightLineProgram([[2,1,1,1,2,1]],2),
              StraightLineProgram([[1,1,2,2]],2),
              StraightLineProgram([[2,4]],2)],
    ),
    extraels := [
      [StraightLineProgram( [ [ 1,1,2,3 ],[ 1,1,2,1 ],[ [ 1,1 ],5 ],
          [ [ 2,1 ],6 ],[ [ 5,1,6,1 ],7 ],[ [ 7,1,6,1 ],8 ],
          [ [ 7,1,8,1 ],5 ],[ [ 8,1,7,1 ],6 ],[ [ 5,7 ],7 ],
          [ [ 6,7 ],8 ],[ [ 7,1,8,1 ],9 ],[ [ 9,1,9,1 ],7 ],
          [ [ 7,-1 ],8 ],[ [ 8,1,6,1 ],9 ],[ [ 9,1,7,1 ],6 ],
          [ [ 5,1 ],10 ],[ [ 6,1 ],11 ],[ [ 10,1 ],5 ],[ [ 11,1 ],6 ],
          [ 5,-2,3,-1,4,-2,3,-1,2,-1,4,-1,3,-1 ] ],2 ),6],
      [StraightLineProgram( [ [ [ 1,1 ],3 ],[ [ 2,1 ],4 ],
          [ [ 3,1,4,1 ],5 ],[ [ 5,1,4,1 ],6 ],[ [ 5,1,6,1 ],3 ],
          [ [ 6,1,5,1 ],4 ],[ [ 3,7 ],5 ],[ [ 4,7 ],6 ],
          [ [ 5,1,6,1 ],7 ],[ [ 7,1,7,1 ],5 ],[ [ 5,-1 ],6 ],
          [ [ 6,1,4,1 ],7 ],[ [ 7,1,5,1 ],4 ],[ [ 3,1 ],8 ],
          [ [ 4,1 ],9 ],[ [ 8,1 ],3 ],[ [ 9,1 ],4 ],
          [ [ 4,2,3,1,4,1,3,1,4,2 ],10 ],
          [ [ 3,1,4,2,3,2,4,2,3,1 ],11 ],[ [ 10,1 ],3 ],
          [ [ 11,1 ],4 ],[ 4,-1,2,-1,1,-1,2,-2,1,-1,2,-3 ] ],2 ),6],
      [StraightLineProgram( [ [ 2,1,1,1 ],[ [ 1,1 ],4 ],[ [ 2,1 ],5 ],
          [ [ 4,1,5,1 ],6 ],[ [ 6,1,5,1 ],7 ],[ [ 6,1,7,1 ],4 ],
          [ [ 7,1,6,1 ],5 ],[ [ 4,7 ],6 ],[ [ 5,7 ],7 ],
          [ [ 6,1,7,1 ],8 ],[ [ 8,1,8,1 ],6 ],[ [ 6,-1 ],7 ],
          [ [ 7,1,5,1 ],8 ],[ [ 8,1,6,1 ],5 ],[ [ 4,1 ],9 ],
          [ [ 5,1 ],10 ],[ [ 9,1 ],4 ],[ [ 10,1 ],5 ],[ [ 1,1 ],11 ],
          [ [ 2,1 ],12 ],[ [ 11,1,12,1 ],13 ],[ [ 13,1,12,1 ],14 ],
          [ [ 13,1,14,1 ],11 ],[ [ 14,1,13,1 ],12 ],[ [ 11,7 ],13 ],
          [ [ 12,7 ],14 ],[ [ 13,1,14,1 ],15 ],[ [ 15,1,15,1 ],13 ],
          [ [ 13,-1 ],14 ],[ [ 14,1,12,1 ],15 ],[ [ 15,1,13,1 ],12 ],
          [ [ 11,1 ],16 ],[ [ 12,1 ],17 ],[ [ 16,1 ],11 ],[ [ 17,1 ],12 ],
          [ [ 12,2,11,1,12,1,11,1,12,2 ],18 ],
          [ [ 11,1,12,2,11,2,12,2,11,1 ],19 ],[ [ 18,1 ],11 ],
          [ [ 19,1 ],12 ],
          [ 11,-1,12,-1,5,-1,2,-1,1,-1,2,-2,1,-1,2,-2,3,-3 ] ],2 ),6],
      [StraightLineProgram( [ [ 2,1,1,1 ],[ [ 1,1 ],4 ],[ [ 2,1 ],5 ],
          [ [ 4,1,5,1 ],6 ],[ [ 6,1,5,1 ],7 ],[ [ 6,1,7,1 ],4 ],
          [ [ 7,1,6,1 ],5 ],[ [ 4,7 ],6 ],[ [ 5,7 ],7 ],
          [ [ 6,1,7,1 ],8 ],[ [ 8,1,8,1 ],6 ],[ [ 6,-1 ],7 ],
          [ [ 7,1,5,1 ],8 ],[ [ 8,1,6,1 ],5 ],[ [ 4,1 ],9 ],
          [ [ 5,1 ],10 ],[ [ 9,1 ],4 ],[ [ 10,1 ],5 ],
          [ 4,-2,2,-2,3,-3,2,-1,1,-1,2,-3 ] ],2 ),6]],
    ),
  specialaction := GenSift.SpecialActionUseIsMemberInfo,
);
# Now we are in CC==87480 
PreSift.Ly[10] := rec(
  # this does: CC  -->  C1:=C_CC(c1) with c1 = (CC.1*CC.2)^3 and |C_CC(c1)|=1080
  groupSLP := 
    [StraightLineProgram( [ [ 1,1,2,1 ],[ 1,1,2,2 ],[ [ 1,1 ],5 ],
          [ [ 2,1 ],6 ],[ [ 5,1 ],19 ],[ [ 6,1 ],20 ],[ [ 19,1 ],5 ],
          [ [ 20,1 ],6 ],[ [ 5,1,6,1 ],7 ],[ [ 7,1,6,1 ],8 ],
          [ [ 7,1,8,1 ],5 ],[ [ 8,1,7,1 ],6 ],[ [ 5,7 ],7 ],
          [ [ 6,7 ],8 ],[ [ 7,1,8,1 ],9 ],[ [ 9,1,9,1 ],7 ],
          [ [ 7,-1 ],8 ],[ [ 8,1,6,1 ],9 ],[ [ 9,1,7,1 ],6 ],
          [ [ 5,1 ],21 ],[ [ 6,1 ],22 ],[ [ 19,1 ],5 ],[ [ 20,1 ],6 ],
          [ [ 5,1,6,2,5,1,6,1,5,1,6,3,5,1,6,1,5,1 ],7 ],
          [ [ 7,1 ],23 ],[ [ 21,1 ],5 ],[ [ 22,1 ],6 ],[ [ 5,1,6,1 ],7 ],
          [ [ 7,1 ],24 ],[ [ 19,1 ],5 ],[ [ 20,1 ],6 ],[ [ 5,1 ],7 ],
          [ [ 6,1 ],8 ],[ [ 7,1,8,1 ],9 ],[ [ 9,1,8,1 ],10 ],
          [ [ 9,1,10,1 ],7 ],[ [ 10,1,9,1 ],8 ],[ [ 7,7 ],9 ],
          [ [ 8,7 ],10 ],[ [ 9,1,10,1 ],11 ],[ [ 11,1,11,1 ],9 ],
          [ [ 9,-1 ],10 ],[ [ 10,1,8,1 ],11 ],[ [ 11,1,9,1 ],8 ],
          [ [ 7,1 ],12 ],[ [ 8,1 ],13 ],[ [ 12,1 ],7 ],[ [ 13,1 ],8 ],
          [ [ 8,2,7,1,8,1,7,1,8,2 ],14 ],
          [ [ 7,1,8,2,7,2,8,2,7,1 ],15 ],[ [ 14,1 ],7 ],
          [ [ 15,1 ],8 ],[ [ 8,-1,6,-1,5,-1,6,-2,5,-1,6,-3 ],16 ],
          [ [ 16,1 ],25 ],[ [ 1,1 ],26 ],[ [ 2,1 ],27 ],[ [ 26,1 ],40 ],
          [ [ 27,1 ],41 ],[ [ 40,1 ],26 ],[ [ 41,1 ],27 ],
          [ [ 26,1,27,1 ],28 ],[ [ 28,1,27,1 ],29 ],
          [ [ 28,1,29,1 ],26 ],[ [ 29,1,28,1 ],27 ],[ [ 26,7 ],28 ],
          [ [ 27,7 ],29 ],[ [ 28,1,29,1 ],30 ],[ [ 30,1,30,1 ],28 ],
          [ [ 28,-1 ],29 ],[ [ 29,1,27,1 ],30 ],[ [ 30,1,28,1 ],27 ],
          [ [ 26,1 ],42 ],[ [ 27,1 ],43 ],[ [ 42,1 ],26 ],[ [ 43,1 ],27 ],
          [ [ 27,2,26,1,27,1,26,1,27,2 ],44 ],
          [ [ 26,1,27,2,26,2,27,2,26,1 ],45 ],[ [ 40,1 ],26 ],
          [ [ 41,1 ],27 ],
          [ [ 27,4,26,1,27,1,26,1,27,3,26,1,27,1 ],28 ],
          [ [ 28,1 ],46 ],[ [ 42,1 ],26 ],[ [ 43,1 ],27 ],
          [ [ 26,2,27,1 ],28 ],[ [ 28,1 ],47 ],[ [ 44,1 ],26 ],
          [ [ 45,1 ],27 ],[ [ 26,2 ],28 ],[ [ 28,1 ],48 ],[ [ 40,1 ],26 ],
          [ [ 41,1 ],27 ],[ [ 26,1 ],28 ],[ [ 27,1 ],29 ],
          [ [ 28,1,29,1 ],30 ],[ [ 30,1,29,1 ],31 ],
          [ [ 30,1,31,1 ],28 ],[ [ 31,1,30,1 ],29 ],[ [ 28,7 ],30 ],
          [ [ 29,7 ],31 ],[ [ 30,1,31,1 ],32 ],[ [ 32,1,32,1 ],30 ],
          [ [ 30,-1 ],31 ],[ [ 31,1,29,1 ],32 ],[ [ 32,1,30,1 ],29 ],
          [ [ 28,1 ],33 ],[ [ 29,1 ],34 ],[ [ 33,1 ],28 ],[ [ 34,1 ],29 ],
          [ [ 29,2,28,1,29,1,28,1,29,2 ],35 ],
          [ [ 28,1,29,2,28,2,29,2,28,1 ],36 ],[ [ 35,1 ],28 ],
          [ [ 36,1 ],29 ],[ [ 29,-1,27,-1,26,-1,27,-2,26,-1,27,-3 ],37 
             ],[ [ 37,1 ],49 ],
          [ [ 2,1,3,7,1,1,23,1,24,1,25,1 ],[ 2,1,4,7,1,1,46,1,47,
                  1,48,1,49,1 ] ] ],2 ),6],
  subgpSLP := 
    StraightLineProgram( [[[1,1,2,1],[1,2,2,1,1,1,2,1,1,1,2,2,1,1] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram([[1,0 ] ],2 ),
                StraightLineProgram([[1,1 ] ],2 ),
                StraightLineProgram([[2,1 ] ],2 ),
                StraightLineProgram([[1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,1 ] ],2 ),
                StraightLineProgram([[2,2 ] ],2 ),
                StraightLineProgram([[1,3 ] ],2 ),
                StraightLineProgram([[2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,2,1,1 ] ],2 ),
                StraightLineProgram([[1,1,2,2 ] ],2 ),
                StraightLineProgram([[2,1,1,3 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,2,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,2,1,1 ] ],2 ),
                StraightLineProgram([[1,2,2,2 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,3 ] ],2 ),
                StraightLineProgram([[2,2,1,3 ] ],2 ),
                StraightLineProgram([[1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,2,1,2 ] ],2 ),
                StraightLineProgram([[1,2,2,2,1,1 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,2,1,1 ] ],2 ),
                StraightLineProgram([[1,3,2,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,1,2,2 ] ],2 ),
                StraightLineProgram([[2,2,1,1,2,2 ] ],2 ),
                StraightLineProgram([[1,2,2,1,1,3 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,1,1,3 ] ],2 ),
                StraightLineProgram([[1,3,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,2,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,2,2,2,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,2,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,2,2,2,1,1 ] ],2 ),
                StraightLineProgram([[2,1,1,3,2,2 ] ],2 ),
                StraightLineProgram([[1,1,2,2,1,1,2,2 ] ],2 ),
                StraightLineProgram([[2,1,1,2,2,1,1,3 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,1,2,1,1,3 ] ],2 ),
                StraightLineProgram([[2,2,1,1,2,1,1,3 ] ],2 ),
                StraightLineProgram([[1,4,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,2,1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,2,2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,2,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,3,2,2,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,2,2,2,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,1,2,2,1,2 ] ],2 ),
                StraightLineProgram([[2,2,1,1,2,2,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,2,2,2,1,1 ] ],2 ),
                StraightLineProgram([[2,2,1,2,2,2,1,1 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,3,2,2 ] ],2 ),
                StraightLineProgram([[1,2,2,2,1,1,2,2 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,2,1,1,2,2 ] ],2 ),
                StraightLineProgram([[2,2,1,2,2,1,1,3 ] ],2 ),
                StraightLineProgram([[1,2,2,1,1,1,2,1,1,3 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,1,1,1,2,1,1,3 ] ],2 ),
                StraightLineProgram([[1,1,2,2,1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,2,2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,1,2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,2,1,1,2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,2,2,2,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[1,4,2,2,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,2,1,1,2,2,1,2 ] ],2 ),
                StraightLineProgram([[1,2,2,1,1,2,2,2,1,1 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,1,1,2,2,2,1,1 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,1,1,3,2,2 ] ],2 ),
                StraightLineProgram([[2,1,1,2,2,2,1,1,2,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,1,2,2,1,1,2,2 ] ],2 ),
                StraightLineProgram([[1,1,2,2,1,2,2,1,1,3 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,1,2,1,1,1,2,1,1,3 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,2,1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,2]],2),
                StraightLineProgram([[1,1,2,2,1,1,2,1,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,2,2,2,1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram([[2,1,1,4,2,2,1,2 ] ],2 ),
                StraightLineProgram([[1,1,2,1,1,2,2,2,1,1,2,2 ] ],2 ),
                StraightLineProgram([[1,2,2,2,1,2,2,1,1,3]],2),
                StraightLineProgram([[2,1,1,1,2,2,1,1,2,1,1,1,2,1,1,2]],2),
                StraightLineProgram([[2,2,1,1,2,2,1,1,2,1,1,1,2,1,1,2]],2),],
  p := FLOAT_RAT( 1/81 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram([[1,1,2,1],[3,3]],2)],
  ),
);
PreSift.Ly[11] := rec(
  # this does: C1  -->  C2 := C_C1(c2) where c1 = C1.2
  subgpSLP := 
    StraightLineProgram( [ [ [ 2,1 ],[ 1,1,2,3,1,1 ] ] ],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2,2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2,2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 1,1,2,1,1,2,2,1,1,2 ] ],2 ),],
  p := FLOAT_RAT( 1/12 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberCentralizer,
    centof := [StraightLineProgram([[2,1]],2)],
  ),
);
PreSift.Ly[12] := rec(
  # this does: C2  -->  C3 := Syl_3(C2) with 9 elements (C2 is abelian)
  subgpSLP := 
    StraightLineProgram( [ [ [ 1,1,2,2 ],[ 1,5 ] ] ],2 ),
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
                StraightLineProgram( [ [ 2,3 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,3 ] ],2 ),],
  p := FLOAT_RAT( 1/10 ),
  ismember := rec(
    isdeterministic := true,
    method := function(ismember,grp,z,e) return IsOne(z^3); end,
  ),
);
PreSift.Ly[13] := rec(
  # this does: C3  -->  1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps,
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],2 ),
                StraightLineProgram( [ [ 1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,1 ] ],2 ),
                StraightLineProgram( [ [ 1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2 ] ],2 ),
                StraightLineProgram( [ [ 2,1,1,2 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,1 ] ],2 ),
                StraightLineProgram( [ [ 2,2,1,2 ] ],2 ),],
  p := FLOAT_RAT( 1/9 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);


############################################################################
# M11, 11-Sylows, suggested by Cheryl
############################################################################

PreSift.M11Cheryl := [];
PreSift.m11Cheryl := PreSift.M11Cheryl;   # an alias
PreSift.M11Cheryl[1] := rec(
  # this does: M11  ->  N_G(a) where a is from class 11X
  # C := C_G(a) is generated by a
  # N := N_G(a) is a Frobenius group with 55 elements
  # Here is the trick:
  # We use an "invisible" L_2(11), which has 12 11-Sylows, each of which
  # are self-centralizing in M11, therefore we can use cosetreps to
  # reach L_2(11) with a^xz and then check, whether we are in one of
  # the 11-Sylows. Using the information, in which we are, we can afterwards
  # conjugate a^z back into the centralizer of a using some stored element
  # x (for each 11-Sylow), which brings zx into N_G(a).
  subgpSLP :=     # SLP for L_2(11)->N_G(a) o AtlasStraightLineProgram("M11",2)
    StraightLineProgram( [ [ [ 1,1,2,1 ],3 ],[ [ 2,1,3,1 ],4 ],
      [ [ 4,1,4,1 ],2 ],[ [ 1,1 ],5 ],[ [ 2,1 ],6 ],[ [ 5,1 ],1 ],[[6,1],2],
      [ [ 1,1,2,1 ],[ 2,1,1,1,2,1,1,1,2,1,1,1,2,2,1,1,2,1,1,1,2,1,1,1]]],2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps, 
  # note that the following are cosetreps of L_2(11) in M11!
  cosetreps := [
    StraightLineProgram([[1,0]],2),
    StraightLineProgram([[2,1]],2 ),
    StraightLineProgram([[1,1,2,1 ] ],2 ),
    StraightLineProgram([[2,1,1,1,2,1 ] ],2 ),
    StraightLineProgram([[1,1,2,1,1,1,2,1 ] ],2 ),
    StraightLineProgram([[2,1,1,1,2,1,1,1,2,1 ] ],2 ),
    StraightLineProgram([[2,2,1,1,2,1,1,1,2,1 ] ],2 ),
    StraightLineProgram([[2,3,1,1,2,1,1,1,2,1 ] ],2 ),
    StraightLineProgram([[1,1,2,3,1,1,2,1,1,1,2,1 ] ],2 ),
    StraightLineProgram([[2,1,1,1,2,3,1,1,2,1,1,1,2,1 ] ],2 ),
    StraightLineProgram([[1,1,2,1,1,1,2,3,1,1,2,1,1,1,2,1]],2),
    StraightLineProgram([[2,1,1,1,2,1,1,1,2,3,1,1,2,1,1,1,2,1]],2),],
  p := FLOAT_RAT( 1/12 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],[1,1,2,1]],2),
    ismember := rec(
      method := IsMemberCentralizers,
      centof := StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
         [[1,1,2,1],3],[[2,1,1,1],4],
         [1,1],[2,1],[2,1,1,1],[2,1,3,1],[4,2],[4,1,2,2],[4,2,2,1],
         [4,1,2,2,1,1],[4,3],[4,2,2,2],[4,3,2,1],
         [[3,1],[5,-1,3,1,5,1],[6,-1,3,1,6,1],[7,-1,3,1,7,1],[8,-1,3,1,8,1],
          [9,-1,3,1,9,1],[10,-1,3,1,10,1],[11,-1,3,1,11,1],[12,-1,3,1,12,1],
          [13,-1,3,1,13,1],[14,-1,3,1,14,1],[15,-1,3,1,15,1]]],2),
    ),
    extraels := [
      StraightLineProgram([[1,0]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],[1,-1]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],[2,-1]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],[1,-1,2,-1]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[1,1,2,1],3],[3,-1,2,-1]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[2,1,1,1],3],[3,-2]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[2,1,1,1],3],[2,-2,3,-1]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[2,1,1,1],3],[2,-1,3,-2]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[2,1,1,1],3],[1,-1,2,-2,3,-1]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[2,1,1,1],3],[3,-3]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[2,1,1,1],3],[2,-2,3,-2]],2),
      StraightLineProgram([[1,1,2,1],[2,1,3,1],[[4,2],2],
                           [[2,1,1,1],3],[2,-1,3,-3]],2)],
  ),
  specialaction := GenSift.SpecialActionUseIsMemberInfo,
);
PreSift.M11Cheryl[2] := rec(
  # this does: F_{55}  ->  <b> where b is F_{55}.2 with the same
  # trick as above, this time using the 12 5-Sylows
  subgpSLP := StraightLineProgram( [[[2,1]]], 2 ),
  isdeterministic := true,
  basicsift := BasicSiftCosetReps, 
  # note that the following are cosetreps of L_2(11) in M11!
  cosetreps :=[StraightLineProgram([[1,0]],2 )],
  p := FLOAT_RAT( 1/1 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberConjugates,
    a := StraightLineProgram([[2,1]],2),
    ismember := rec(
      method := IsMemberCentralizers,
      centof := StraightLineProgram([[1,1,2,1],
         [1,1],[1,2],[3,1],[1,3],[1,2,2,1],[3,1,1,1],[1,4],[3,1,1,2],[3,2],
         [1,4,2,1],
         [[2,1],[4,-1,2,1,4,1],[5,-1,2,1,5,1],[6,-1,2,1,6,1],[7,-1,2,1,7,1],
          [8,-1,2,1,8,1],[9,-1,2,1,9,1],[10,-1,2,1,10,1],[11,-1,2,1,11,1],
          [12,-1,2,1,12,1],[13,-1,2,1,13,1]]],2),
    ),
    extraels := [StraightLineProgram([[1,0]],2),
                 StraightLineProgram([[1,-1]],2),
                 StraightLineProgram([[1,-2]],2),
                 StraightLineProgram([[1,1,2,1],[3,-1]],2),
                 StraightLineProgram([[1,1,2,1],[1,-3]],2),
                 StraightLineProgram([[2,-1,1,-2]],2),
                 StraightLineProgram([[1,1,2,1],[1,-1,3,-1]],2),
                 StraightLineProgram([[1,-4]],2),
                 StraightLineProgram([[1,1,2,1],[1,-2,3,-1]],2),
                 StraightLineProgram([[1,1,2,1],[3,-2]],2),
                 StraightLineProgram([[2,-1,1,-4]],2)],
  ),
  specialaction := GenSift.SpecialActionUseIsMemberInfo,
);
PreSift.M11Cheryl[3] := rec(
  # this does: 5  ->  1
  subgpSLP := TrivialSubgroup,
  isdeterministic := true,
  basicsift := BasicSiftCosetReps, 
  # note that the following are cosetreps of L_2(11) in M11!
  cosetreps := [StraightLineProgram( [ [ 1,0 ] ],1 ),
                StraightLineProgram( [ [ 1,1 ] ],1 ),
                StraightLineProgram( [ [ 1,2 ] ],1 ),
                StraightLineProgram( [ [ 1,3 ] ],1 ),
                StraightLineProgram( [ [ 1,4 ] ],1 ),],
  p := FLOAT_RAT( 1/5 ),
  ismember := rec(
    isdeterministic := true,
    method := IsMemberIsOne,
  ),
);
