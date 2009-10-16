############################################################################
##
##  timing_normpro.g                CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_normpro.g,v 1.3 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_samples.g");

LoadPackage ("crisp");
ReadPackage ("crisp", "tst/timing_test.g");
ReadPackage ("crisp", "tst/timing_samples.g");


############################################################################
##
#F  test (H)
##
##  computes normalizers of the Sylow p-subgroups of H for all prime 
##  p of |H| and compares the result of the library method to the results
##  obtained by NormalizerOfPronormalSubgroup
##
##  if DO_TIMING is true, the running times needed by these functions is 
##  being measured, too.
##
test := function (H)  # computes normalizers of the Sylow subgroups of H
   
   local p, primes, res, P, norm1, norm2, t1, t2, t0;
   
   Print ("testing group of size ");
   PrintFactorsInt (Size (H));
   Print ("\n");
   primes := Set (FactorsInt (Size(H)));
   res := [];
   SpecialPcgs (H);
   PcgsElementaryAbelianSeries (H);
   
   for p in primes do 
      P := SylowSubgroup (H, p);
      Print ("prime ", p, " |P| =", Size (P), " |H:P| = ", 
         Size (H)/Size (P), "\c");
      if IsBound (DO_TIMING) and DO_TIMING then
         GASMAN ("collect");
      fi;
      t0 := Runtime();
      norm1 := NormalizerOfPronormalSubgroup (H, P);
      t1 := Runtime() - t0;
      if IsBound (DO_TIMING) and DO_TIMING then
         GASMAN ("collect");
      fi;
      t0 := Runtime();
      norm2 := Normalizer (H, P); 
      t2 := Runtime() - t0;
      if norm1 <> norm2 then
         Error ("wrong normalizer  \n");
      fi;
      if norm1 <> norm2 then
         Error ("normalizer not self-normalising \n");
      fi;
      if Index (H, norm1) mod p <> 1 then
         Error ("wrong index \n");
      fi;
      if IsBound (DO_TIMING) and DO_TIMING then
         Print ("  ", t1, "   ", t2,
            "  |N_G(P):P| = ", Size (norm1)/Size(P),
            "  |G:N_G(P)| =  ", Size (H)/Size(norm1), "\n");
      else
      	 Print ("\n");
      fi;
   od;
end;


############################################################################
##
#F  test (G)
##
##  generate random subgroup of G and run function test on it
##
test2 := function (G)  

   local pcgs, pcgsH, H, i, new;
   
   pcgs := Pcgs (G);
   pcgsH := InducedPcgsByPcSequence (pcgs, []);
   H := SubgroupByPcgs (G, pcgsH);
   
   repeat 
      new := Random(PcSeries (pcgs)[Random([1..Length (pcgs)])]);
      i := DepthOfPcElement (pcgs, new);
      if not new in H then
         pcgsH := InducedPcgsByPcSequenceAndGenerators (pcgs, pcgsH, [new]);
         H := SubgroupByPcgs (G, pcgsH);
         test (H);
      fi;
   until H = G;
end;


# now run the actual tests

for g in groups do
   if IsBoundGlobal (g[3]) then
      UnbindGlobal (g[3]);
   fi;
   SilentRead (g[1],g[2]);
   if IsBound (g[4]) then
      name := g[4];
   else
      name := g[3];
   fi;
   tmp := ValueGlobal (g[3]);
   UnbindGlobal (g[3]);

   # test2 uses random subgroups, so it makes sense to run it a few times
   test2(tmp);
   test2(tmp);
   test2(tmp);
od;


############################################################################
##
#E
##
