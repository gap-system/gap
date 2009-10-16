############################################################################
##
##  classes.g                       CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: classes.g,v 1.3 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");

25grps := PiGroups ([2,5]);
abab := Intersection (AbelianGroups, AbelianGroups);
if not KnownTruePropertiesOfObject (abab) 
   = KnownTruePropertiesOfObject (AbelianGroups) then 
      Error ("properties not preserved by intersection");
fi;
nilab := Intersection (NilpotentGroups, AbelianGroups);
if not KnownTruePropertiesOfObject (abab) 
   = KnownTruePropertiesOfObject (AbelianGroups) then 
      Error ("properties not preserved by intersection");
fi;
nilnil := Intersection (NilpotentGroups, NilpotentGroups);
if not KnownTruePropertiesOfObject (nilnil) 
   = KnownTruePropertiesOfObject (NilpotentGroups) then 
      Error ("properties not preserved by intersection");
fi;
nilunil := Union (NilpotentGroups, NilpotentGroups);
niluab := Union (NilpotentGroups, AbelianGroups);
nilu25 := Union (NilpotentGroups, 25grps);
nil25 := Intersection (NilpotentGroups, 25grps);
nilpbynilp := FormationProduct (NilpotentGroups, NilpotentGroups);
if not KnownTruePropertiesOfObject (nilpbynilp) 
   = KnownTruePropertiesOfObject (NilpotentGroups)then 
      Error ("properties not preserved by intersection");
fi;
abbyab := FormationProduct (AbelianGroups, AbelianGroups);
SetIsSubgroupClosed (abbyab, true);
if not KnownTruePropertiesOfObject (abbyab) 
   = KnownTruePropertiesOfObject (AbelianGroups) then 
      Error ("properties not preserved by intersection");
fi;

FermatPrimes := Class (p -> IsPrime (p) and p = 2^LogInt (p, 2) + 1);
if HasIsEmpty  (FermatPrimes) then
   Error ("HasIsEmpty set");
fi;
3 in FermatPrimes;
if IsEmpty (FermatPrimes) then
   Error ("IsEmpty should be false");
fi;

C := GroupClass (G -> 6 mod Size (G) = 0);
SetIsSubgroupClosed (C, true);
if HasContainsTrivialGroup (C) then
   Error ("HasContainsTrivialGroup set");
fi;
CyclicGroup (2) in C;
if not ContainsTrivialGroup (C) then
   Error ("ContainsTrivialGroup should be true");
fi;


############################################################################
##
#E
##
