#############################################################################
##
#W  mealymachines.g                FR Package               Laurent Bartholdi
##
#H  @(#)$Id: mealymachines.g,v 1.2 2008/10/28 15:49:18 gap Exp $
##
#Y  Copyright (C) 2006,  Laurent Bartholdi
##
#############################################################################
##
##  This file reads the implementations, and in principle could be reloaded
##  during a GAP session.
#############################################################################

# We input 7 examples of Mealy machines. The first 5 are invertible.
# They are stored in the variable mealym
# These machines correspond to the ones in frmachines.g

mealym := [];
transitionsm := [];
outputsm := [];

# m1 : Grigorchuk group

Add(mealym, []);
Add(transitionsm, [[1, 1], [1, 1], [2, 4], [2, 5], [1, 3]]);
Add(outputsm, [[1,2], [2,1], [1,2], [1..2], [1,2]]);
m := MealyMachineNC(FRMFamily([1,2]), transitionsm[1], outputsm[1]);
Add(mealym[1], m);
m := MealyMachine(transitionsm[1], outputsm[1]);
Add(mealym[1], m);
m := MealyMachine(Domain(["x","y"]), transitionsm[1], outputsm[1]);
Add(mealym[1], m);
trans := function(state, letter)
  if state = "e" or state = "a" or (state = "d" and letter = "x") then
    return "e";
  elif ((state = "b" or state = "c") and letter = "x") then
    return "a";
  elif state = "b" and letter = "y" then
    return "c";
  elif state = "c" and letter = "y" then
    return "d";
  else
    return "b";
  fi;
end;
out := function(state, letter)
  if state = "a" then
    if letter = "x" then
      return "y";
    else
      return "x";
    fi;
  else
    return letter;
  fi;
end;
m := MealyMachine(Domain(["e","a","b","c","d"]), Domain(["x","y"]), trans, out);
Add(mealym[1], m);

# m2 : Grigorchuk group (on a 8-ary tree)

Add(mealym, []);
e := ListWithIdenticalEntries(8, 4);
Add(transitionsm, [e, Concatenation(e{[1..7]}, [2]), Concatenation(e{[1..6]}, [1,3]), e]);
Add(outputsm, [[5,6,7,8,1,2,3,4], [3,4,1,2,6,5,7,8], [3,4,1,2,5,6,7,8], [1..8]]);
m := MealyMachineNC(FRMFamily([1..8]), transitionsm[2], outputsm[2]);
Add(mealym[2], m);
m := MealyMachine(transitionsm[2], outputsm[2]);
Add(mealym[2], m);
m := MealyMachine(Domain(List([1..8], i -> [1..i])), transitionsm[2], outputsm[2]);
Add(mealym[2], m);
trans := function(state, letter)
  if state = "e" or state = "a" then
    return "e";
  elif state = "c" and letter = [1..7] then
    return "a";
  elif ((state = "b" or state = "c") and letter <> [1..8]) then
    return "e";
  else
    return state;
  fi;
end;
out := function(state, letter)
  if state = "a" then
    return [1..Length(letter)^(1,5)(2,6)(3,7)(4,8)];
  elif state = "b" then
    return [1..Length(letter)^(1,3)(2,4)(5,6)];
  elif state = "c" then
    return [1..Length(letter)^(1,3)(2,4)];
  else
    return letter;
  fi;
end;
m := MealyMachine(Domain(["a","b","c","e"]), Domain(List([1..8], i -> [1..i])), trans, out);
Add(mealym[2], m);

# m3 : a spinal group

Add(mealym, []);
Add(transitionsm, [[4, 4], [1, 3], [4, 2], [4, 4]]);
Add(outputsm, [[2,1], [1,2], [1,2], [1,2]]);
m := MealyMachineNC(FRMFamily([1..2]), transitionsm[3], outputsm[3]);
Add(mealym[3], m);
m := MealyMachine(transitionsm[3], outputsm[3]);
Add(mealym[3], m);
mygrp2 := CyclicGroup(2);
m := MealyMachine(mygrp2, transitionsm[3], outputsm[3]);
Add(mealym[3], m);
trans := function(state, letter)
  if state = "e" or state = "a" or (state = "b2" and letter = mygrp2.1^2) then
    return "e";
  elif (state = "b1" and letter = mygrp2.1^2) then
    return "a";
  elif state = "b1" and letter = mygrp2.1 then
    return "b2";
  else
    return "b1";
  fi;
end;
out := function(state, letter)
  if state = "a" then
    return letter*mygrp2.1;
  else
    return letter;
  fi;
end;
m := MealyMachine(Domain(["a","b1","b2","e"]), mygrp2, trans, out);
Add(mealym[3], m);

# m4 : the 5-adic adding machine

Add(mealym, []);
Add(transitionsm, [[2,2,2,2,1], [2,2,2,2,2]]);
Add(outputsm, [[2,3,4,5,1], [1..5]]);
m := MealyMachineNC(FRMFamily([1..5]), transitionsm[4], outputsm[4]);
Add(mealym[4], m);
m := MealyMachine(transitionsm[4], outputsm[4]);
Add(mealym[4], m);
m := MealyMachine(ZmodpZ(5), transitionsm[4], outputsm[4]);
Add(mealym[4], m);
trans := function(state, letter)
  if state = SymmetricGroup(3) and letter = ZmodnZObj(4,5) then
    return state;
  else
    return AlternatingGroup(3);
  fi;
end;
out := function(state, letter)
  if state = SymmetricGroup(3) then
    return letter + 1;
  else
    return letter;
  fi;
end;
m := MealyMachine(Domain([SymmetricGroup(3), AlternatingGroup(3)]), ZmodpZ(5), trans, out);
Add(mealym[4], m);

# m5 : a miscellaneous machine on a 7-ary tree

Add(mealym, []);
Add(transitionsm, [[1,2,3,1,2,3,4], [1,2,3,4,3,2,1], [4,2,2,1,3,4,4], [4,4,4,4,4,4,4]]);
Add(outputsm, [[2,3,4,5,1,6,7], [4,3,2,1,5,6,7], [6,5,1,4,2,3,7], [1..7]]);
m := MealyMachineNC(FRMFamily([1..7]), transitionsm[5], outputsm[5]);
Add(mealym[5], m);
m := MealyMachine(transitionsm[5], outputsm[5]);
Add(mealym[5], m);
m := MealyMachine(Domain([1..7]), transitionsm[5], outputsm[5]);
Add(mealym[5], m);
trans := function(state, letter)
  return transitionsm[5][state][letter];
end;
out := function(state, letter)
  return outputsm[5][state][letter];
end;
m := MealyMachine(Domain([1..4]), Domain([1..7]), trans, out);
Add(mealym[5], m);

# m6 : a non-Mealy GroupFRMachine

Add(mealym, []);
Add(transitionsm, []);
Add(outputsm, []);

# m7 : a miscellaneous MonoidFRMachine on the binary tree

Add(mealym, []);
Add(transitionsm, [[1, 3], [2, 4], [2, 1], [4, 4]]);
Add(outputsm, [[1,1], [2,1], [2,2], [1,2]]);
m := MealyMachineNC(FRMFamily([1..2]), transitionsm[7], outputsm[7]);
Add(mealym[7], m);
m := MealyMachine(transitionsm[7], outputsm[7]);
Add(mealym[7], m);
m := MealyMachine(Domain(["one","two"]), transitionsm[7], outputsm[7]);
Add(mealym[7], m);
int := function(num)
  if num = "one" then
    return 1;
  elif num = "two" then
    return 2;
  elif num = "three" then
    return 3;
  elif num = "four" then
    return 4;
  else
    return fail;
  fi;
end;
str := function(num)
  if num = 1 then
    return "one";
  elif num = 2 then
    return "two";
  elif num = 3 then
    return "three";
  elif num = 4 then
    return "four";
  else
    return fail;
  fi;
end;
trans := function(state, letter)
  return str(transitionsm[7][int(state)][int(letter)]);
end;
out := function(state, letter)
  return str(outputsm[7][int(state)][int(letter)]);
end;
m := MealyMachine(Domain(["one","two","three","four"]), Domain(["one","two"]), trans, out);
Add(mealym[7], m);

# m8 : a miscellaneous SemigroupFRMachine on a 7-ary tree

Add(mealym, []);
Add(transitionsm, [[1,2,1,2,1,2,1],[2,2,1,2,1,1,2]]);
Add(outputsm, [[2,5,4,7,7,4,3],[3,1,6,7,4,7,1]]);
m := MealyMachineNC(FRMFamily([1..7]), transitionsm[8], outputsm[8]);
Add(mealym[8], m);
m := MealyMachine(transitionsm[8], outputsm[8]);
Add(mealym[8], m);
m := MealyMachine(Domain([8..14]), transitionsm[8], outputsm[8]);
Add(mealym[8], m);
trans := function(state, letter)
  return -5*transitionsm[8][((state-1)mod 2)+1][((letter-1)mod 7)+1]+8;
end;
out := function(state, letter)
  return outputsm[8][((state-1)mod 2)+1][((letter-1)mod 7)+1] + 7;
end;
m := MealyMachine(Domain([3,-2]), Domain([8..14]), trans, out);
Add(mealym[8], m);

# m9 : a non-Mealy SemigroupFRMachine

Add(mealym, []);
Add(transitionsm, []);
Add(outputsm, []);

#E mealymachines.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here