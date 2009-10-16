#############################################################################
##
#W factor.gi               The Congruence package              Helena Verrill
##
#H $Id: factor.g,v 1.1 2007/04/29 17:51:34 alexk Exp $
##
#############################################################################

# it will be useful to find the maximum value of the labels
# though if space is not a problem, this could just return
# the Length of the labels.

max_label:= function(L)
  local s, i;
  s:=1;
  for i in [1..Length(L)] do
    if (not L[i] = "even") and (not L[i] = "odd")  and  L[i] > s then
       s := L[i];
    fi;
  od;
  return s;
end;;

# For a list of labels L such as
# [1,3,4,7,4,7,3,1,"odd","even"], for reference, indices are:
#  1 2 3 4 5 6 7 8  9     10
# want to produce a list:
# [[9],[10],[1,8],[],[2,7],[3,5],...]
# this is the list of the form:
# [[all indices with L[x] = "odd"],[all indices with L[x] = "even"],
# [all indices with L[x] = 1], ....]

# assume L is a list of integers, or "odd" or "even".

edgepairs := function(L)
  local max, pairs, i;
  pairs:=[];
  max:=max_label(L);
  for i in [1..max+2] do
      pairs[i] := [];
  od;
  for i in [1..Length(L)] do
      if L[i]="odd" then
        Add(pairs[1],i);
      elif L[i]="even" then
        Add(pairs[2],i);
      else
        Add(pairs[L[i]+2],i);
      fi;
  od;
  return pairs;
end;;

# for each edge of a Farey Symbol, we compute the generator
# which maps that edge to another edge.
# (this is done at the same time as the fundamental
# domain is computed, but the data may not have been stored,
# and has to be recomputed; suggest change for a future version)

# this function gives "edge gluing matrices" as a number in the
# list of generators (gens); negative entries mean the inverse matrix,
# e.g., -5 would mean (5th generator)^(-1)
# (note, the list of labels in a Farey sequence says which edge is
# glued to which; -2 and -3 means there is an elliptic point order
# 2 or 3)
#
# the input is assumed to be a FareySymbol;
# another version of this function could take input to be the group
#
# Note, if the output of this function was
# stored as an attribute of the FareySymbol,
# then it would not have to be recomputed
#

gluing_matrices := function(FS)
   local cusps, gens, label_list, glue_list, l, i, index, gfs, labels, matrix;
   # the following is a list of the cusps of the sequence,
   # and other data extracted from the FareySymbol
   gfs := GeneralizedFareySequence(FS);
   labels := LabelsOfFareySymbol(FS);
   gens := GeneratorsByFareySymbol( FS );
   # make a list of which edges have a given label:
   label_list := edgepairs(labels);
   # the following list will be what is finally returned, 
   # a list of integers as described above.
   glue_list := [];
   # make list of which generator joins two edges,
   # in the non elliptic case
   for i in [3..Length(label_list)] do
      l := label_list[i];
      matrix := MatrixByFreePairOfIntervals( gfs, l[1], l[2] );
      index := PositionNthOccurrence( gens ,matrix,1);
      if index = "fail" then
        index := -PositionNthOccurrence(gens,matrix^(-1),1);
      fi;
      glue_list[l[1]] := index;
      glue_list[l[2]] := -index;
   od;
   # Now deal with elliptic elements:
   for i in label_list[1] do
      matrix := MatrixByOddInterval( gfs, i );
      index := PositionNthOccurrence(gens,matrix,1);
      if index = "fail" then
         index := -PositionNthOccurrence(gens,matrix^(-1),1);
         glue_list[i] := -index;
      else
         glue_list[i] := -index;
      fi;
   od;
   for i in label_list[2] do
      matrix := MatrixByEvenInterval( gfs, i );
      index := PositionNthOccurrence(gens,matrix,1);
      if index = "fail" then
         index := -PositionNthOccurrence(gens,matrix^(-1),1);
         glue_list[i] := -index;
      else
         glue_list[i] := -index;
      fi;
   od;
   return glue_list;     
end;;

# following function determines which edge an image ImL of
# a domain is the longest
#
# The function either returns a index of an edge
# which is a number between 1 and #L-1,
# or it returns "overlap" meaning that there is overlap, but not equality.

longest_edge := function(ImL)
   local i, minImL, maxImL, maxindex, minindex;
   for i in [1..Length(ImL)] do
      if ImL[i] = infinity then
        return "infinity";
      fi; 
   od;
   minImL := Minimum(ImL);
   maxImL := Maximum(ImL);
   maxindex := PositionNthOccurrence( ImL ,maxImL,1);
      return maxindex;
end;;

# Need to be able to apply action of matrices to cusps

fractionallineartransformation:= function(g,c)
  local den, num;
  if c = infinity then
    if g[2][1] = 0 then
      return infinity;
    else    
      return g[1][1]/g[2][1];
    fi;  
  else
    num:=g[1][1]*c + g[1][2];
    den:=g[2][1]*c + g[2][2];
    if den = 0 then
      return infinity;
    else
      return num/den;
    fi;
  fi;
end;;

PSL2multiply := function(g,L)
  local imL, i;
  imL := [];
  for i in [1..Length(L)] do
    Add(imL,fractionallineartransformation(g,L[i]));
  od;
  return imL;
end;;

# this an algorithm to determine a word for
# a given matrix g in G in terms of the generators:

find_word_ver2 := function(FS,glue_list,g)
   local gens, L, ImL, done, word,letter,i, edge, h, maybesame, inf;
   gens := GeneratorsByFareySymbol( FS );
   L := GeneralizedFareySequence( FS );
   ImL := PSL2multiply(g,L);
   word:=[];
   h := g;
   done := false;
   while not done do;      
      edge := longest_edge(ImL);
      if edge = "infinity" then
         # check equality of L and ImL:
         maybesame := true;
         i := 1;
         while i < Length(L) and maybesame do
            if not L[i] = ImL[i] then
              maybesame := false;
            fi;
            i := i+1;
         od;
         if maybesame then
            done := true;
            return Reversed(word);
         fi;         
         # now assume the domains are not equal
         inf := PositionNthOccurrence( ImL , infinity ,1);
         if inf = 1 and
            ImL[2]<L[Length(L)-1] and
            ImL[Length(L)-1]>L[2] then              
            return "g is not in the group";
         elif
            ImL[i+1]<L[Length(L)-1] and
            ImL[i-1]>L[2] then              
            return "g is not in the group";
         fi;
         # now assume the domains do not overlap
         if ImL[inf+1] >= L[2] then
            letter := glue_list[inf];
         elif inf = 1 then
            letter := glue_list[Length(glue_list)];
         else
            letter := glue_list[inf-1];
         fi;
         Add(word,letter);
         h:=h*gens[AbsoluteValue(letter)]^(-SignInt(letter));
         ImL := PSL2multiply(h,L);
      else
         # get next "letter" in the word for the matrix:
         letter := glue_list[edge];
         Add(word,letter);
      h:=h*gens[AbsoluteValue(letter)]^(-SignInt(letter));
      ImL := PSL2multiply(h,L);
      fi;
   od;
   return Reversed(word);
end;;


#############################################################################
#
# FactorizeMat( G, g )
#
FactorizeMat := function( G, g )
return find_word_ver2( FareySymbol(G), 
                       gluing_matrices(FareySymbol(G)),
                       g );
end;

#############################################################################
#
# CheckFactorizeMat(gens,word)
#
# the following function is for testing purposes:
# gens is a list of generators, "word" a sequence of integers, none 
# of which is bigger than the size of the list of generators.  
# a word [4,6,-3] will return the product gens[4]*gens[6]*gens[3]^(-1)
#
CheckFactorizeMat := function(gens,word)
local g, i;
g := [[1,0],[0,1]];
for i in word do
  g := g*gens[AbsoluteValue(i)]^SignInt(i);
od;
return g;
end;