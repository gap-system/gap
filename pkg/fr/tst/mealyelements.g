#############################################################################
##
#W  mealyelements.g                FR Package               Laurent Bartholdi
##
#H  @(#)$Id: mealyelements.g,v 1.3 2008/10/29 12:57:43 gap Exp $
##
#Y  Copyright (C) 2006,  Laurent Bartholdi
##
#############################################################################
##
##  This file reads the implementations, and in principle could be reloaded
##  during a GAP session.
#############################################################################

# We input the elements corresponding to the states of the machines of mealyelachines.g

Read(Filename(DirectoriesPackageLibrary("fr","tst"),"mealymachines.g"));
mealyel := [];

# m1 : Grigorchuk group

Add(mealyel, []);
Add(mealyel[1], List([1..5], i -> MealyElementNC(FREFamily([1,2]), transitionsm[1], outputsm[1], i)));
Add(mealyel[1], List([1..5], i -> MealyElement(transitionsm[1], outputsm[1], i)));
Add(mealyel[1], List([1..5], i -> MealyElement(Domain(["x","y"]), transitionsm[1], outputsm[1], i)));
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
Add(mealyel[1], List(["e","a","b","c","d"], i -> MealyElement(Domain(["e","a","b","c","d"]), Domain(["x","y"]), trans, out, i)));
Add(mealyel[1], mealym[1][1]{[1..5]});

# m2 : Grigorchuk group (on a 8-ary tree)

Add(mealyel, []);
e := ListWithIdenticalEntries(8, 4);
Add(mealyel[2], List([1..4], i -> MealyElementNC(FREFamily([1..8]), transitionsm[2], outputsm[2], i)));
Add(mealyel[2], List([1..4], i -> MealyElement(transitionsm[2], outputsm[2], i)));
Add(mealyel[2], List([1..4], j -> MealyElement(Domain(List([1..8], i -> [1..i])), transitionsm[2], outputsm[2], j)));
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
Add(mealyel[2], List(["a","b","c","e"], j -> MealyElement(Domain(["a","b","c","e"]), Domain(List([1..8], i -> [1..i])), trans, out, j)));
Add(mealyel[2], List([1..4], i -> mealym[2][2][i]));

# m3 : a spinal group

Add(mealyel, []);
Add(mealyel[3], List([1..4], i -> MealyElementNC(FREFamily([1..2]), transitionsm[3], outputsm[3], i)));
Add(mealyel[3], List([1..4], i -> MealyElement(transitionsm[3], outputsm[3], i)));
# mygrp2 is a global variable defined in mealymachines.g. It is CyclicGroup(2).
Add(mealyel[3], List([1..4], i -> MealyElement(mygrp2, transitionsm[3], outputsm[3], i)));
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
Add(mealyel[3], List(["a","b1","b2","e"], i -> MealyElement(Domain(["a","b1","b2","e"]), mygrp2, trans, out, i)));
Add(mealyel[3], AsIntMealyMachine(mealym[3][3]){[1,2,3,4]});

# m4 : the 5-adic adding machine

Add(mealyel, []);
Add(mealyel[4], List([1..2], i -> MealyElementNC(FREFamily([1..5]), transitionsm[4], outputsm[4], i)));
Add(mealyel[4], List([1..2], i -> MealyElement(transitionsm[4], outputsm[4], i)));
Add(mealyel[4], List([1..2], i -> MealyElement(ZmodpZ(5), transitionsm[4], outputsm[4], i)));
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
Add(mealyel[4], List([SymmetricGroup(3), AlternatingGroup(3)], i -> MealyElement(Domain([SymmetricGroup(3), AlternatingGroup(3)]), ZmodpZ(5), trans, out, i)));
Add(mealyel[4], mealym[4][2]{[1,2]});

# m5 : a miscellaneous machine on a 7-ary tree

Add(mealyel, []);
Add(mealyel[5], List([1..4], i -> MealyElementNC(FREFamily([1..7]), transitionsm[5], outputsm[5], i)));
Add(mealyel[5], List([1..4], i -> MealyElement(transitionsm[5], outputsm[5], i)));
Add(mealyel[5], List([1..4], i -> MealyElement(Domain([1..7]), transitionsm[5], outputsm[5], i)));
trans := function(state, letter)
  return transitionsm[5][state][letter];
end;
out := function(state, letter)
  return outputsm[5][state][letter];
end;
Add(mealyel[5], List([1..4], i -> MealyElement(Domain([1..4]), Domain([1..7]), trans, out, i)));
Add(mealyel[5], List([1..4], i -> mealym[5][1][i]));

# m6 : a non-Mealy GroupFRMachine

Add(mealyel, []);

# m7 : a miscellaneous MonoidFRMachine on the binary tree

Add(mealyel, []);
Add(mealyel[7], List([1..4], i -> MealyElementNC(FREFamily([1..2]), transitionsm[7], outputsm[7], i)));
Add(mealyel[7], List([1..4], i -> MealyElement(transitionsm[7], outputsm[7], i)));
Add(mealyel[7], List([1..4], i -> MealyElement(Domain(["one","two"]), transitionsm[7], outputsm[7], i)));
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
    return 0;
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
Add(mealyel[7], List(["one","two","three","four"], i -> MealyElement(Domain(["one","two","three","four"]), Domain(["one","two"]), trans, out, i)));
Add(mealyel[7], mealym[7][1]{[1..4]});

# m8 : a miscellaneous SemigroupFRMachine on a 7-ary tree

Add(mealyel, []);
Add(mealyel[8], List([1..2], i -> MealyElementNC(FREFamily([1..7]), transitionsm[8], outputsm[8], i)));
Add(mealyel[8], List([1..2], i -> MealyElement(transitionsm[8], outputsm[8], i)));
Add(mealyel[8], List([1..2], i -> MealyElement(Domain([8..14]), transitionsm[8], outputsm[8], i)));
trans := function(state, letter)
  return -5*transitionsm[8][((state-1)mod 2)+1][((letter-1)mod 7)+1]+8;
end;
out := function(state, letter)
  return outputsm[8][((state-1)mod 2)+1][((letter-1)mod 7)+1] + 7;
end;
Add(mealyel[8], List([3,-2], i -> MealyElement(Domain([3,-2]), Domain([8..14]), trans, out, i)));
Add(mealyel[8], List([1..2], i -> mealym[8][2][i]));

# m9 : a non-Mealy SemigroupFRMachine

Add(mealyel, []);

#E mealyelements.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here