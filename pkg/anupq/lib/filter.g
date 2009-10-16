##
## this file contains procedures which can be used to construct
## using p-group generation a list of those groups which satisfy 
## the particular property encoded in the procedure GoodGroup 
## 
## Eamonn O'Brien 
## ANU September 1992
#######################################################################
## 
## current definition of good group 
##
## those groups which have abundance at most k
## 
IsGoodGroup := function (H)

   local NCl, Desired, O, facs, p, m, n, e, k; 

   O := Size (H);
   facs := Flat (Collected (FactorsInt (O)));
   p := facs[1];
   m := facs[2];

   n := Int (m / 2);
   e := m - n * 2;

   k := 0;
   
   Desired := n * (p^2 - 1) + p^e + k * (p - 1) * (p^2 - 1);

   Print ("Desired number of classes is ", Desired, "\n");

   NCl := Length (ConjugacyClasses (H));
   Print ("The number of classes is ", NCl, "\n");
   
   return NCl <= Desired;

end; #IsGoodGroup

#impose some properties on the descendants 

GoodDescendants := function (G)

   local Good, L, H;

   L := PqDescendants (G, "AllDescendants", "PcgsAutomorphisms");
   Print ("There are a total of ", Length (L), " immediate descendants\n");
   Good := [];
   for H in L do
      if IsGoodGroup (H) then
         Print ("We have found a good group\n");
         Add (Good, H);
      fi;
   od;

   return Good;

end; #GoodDescendants 

#generate the groups which are GoodGroups 

GenerateGoodGroups := function (G)

   local L, H, Good;

   L := GoodDescendants (G);
   for H in L do
      Good := GoodDescendants (H);
      if Good <> [] then 
         Append (L, Good);
      fi;
   od;

   return L;

end; #GenerateGoodGroups
