############################################################################
##
##  timing_test.g                  CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_test.g,v 1.3 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##


############################################################################
##
#V  PRINT
##
##  global variable storing the original value of `Print'
##
if not IsBound (PRINT) then
   PRINT := Print;
   MakeReadOnlyGlobal ("PRINT");
fi;


############################################################################
##
#F  SilentRead (g1, g2)
##
##  if g1 is a function, this simply returns g1 (g2). 
##  Otherwise, it behaves like ReadPackage (pkg fname), but suppresses anything 
##  printed while reading the file
##
SilentRead := function (g1, g2)

   if IsFunction (g1) then
      CallFuncList (g1, g2);
   else
      MakeReadWriteGlobal ("Print");
      Print := Ignore;
      ReadPackage (g1, g2);
      Print := PRINT;
      MakeReadOnlyGlobal ("Print");
   fi;
end;


############################################################################
##
#F  DoTests (groups, tests)
##
##  performs a series of tests with a list of sample groups, comparing 
##  the results of the various tests. if the global Boolean DO_TIMING is
##  true, additionally, a table containing the running times of the 
##  various tests is printed.
##
##  groups is a list describing the sample input groups for the tests.
##  Each entry consists of a list g. 
##  Either g[1] is the name of the GAP package to which the sample group 
##  belongs, and g[2] is the file containing the sample group, or g[1] is a
##  function which returns a *new* group (not identical to any previous object) -
##  note that each call to g[1] should return a group with the same presentation.
##
##  g[3] contains the name of the global variable 
##  to which the group will be assigned after the file is read.
##  if g[4] is bound, the name of the sample group will be the string in t[4],
##  otherwise the string in g[3].
##
##  tests consists of a list of tests to be performed. Each entry t is a list.
##  t[1] must be the function to be tested. t[2] is a function to be applied
##  to the result of t[1]. t[3] is a string describing the test. This string
##  should be short (7 chars max.) because it will be used as a column heading
##  if DO_TIMING is true.
##  t[4] contains a list of the names of those groups for which the test
##  should be skipped. t[5], if bound, must contain a function which will be
##  called with the test group as the argument *before* the test function
##  t[1] will be carried out. (The idea is to allow t[5] to pre-compute
##  some knowledge about the test group, while the computing time needed
##  to compute that knowledge is not taken into account when timing the call
##  to t[1].
##  if t[6] is bound, it must be a function with no arguments. If DO_TIMING
##  is true, its result will be printed after the timing for the call to t[1].
##  The column heading for that result must be in t[7].
##  The idea is to allow partial timings during the call to t[1] or a
##  call to t[5] to be displayed.
##
DoTests := function (groups, tests)

   local g, name, tmp, t, t0, t1, res, prevres, size;
   
   Print (String ("group",-10));
   Print (String ("logsize", 8));
   Print (String ("complen", 8));
   if IsBound (DO_TIMING) and DO_TIMING then
      for t in tests do
         Print (String(t[3],8),"\c");
         if IsBound (t[6]) then
            Print (String (t[7],8), "\c");
         fi;
      od;
   fi;
   Print ("\n");
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
      Print (String (name,-10));
      tmp := ValueGlobal (g[3]);
      size := Size (tmp);
      Print (String (LogInt (Size (tmp), 10), 8));
      Print (String (Length (Pcgs(tmp)), 8), "\c");
      UnbindGlobal (g[3]);
      prevres := fail;
      
      for t in tests do
         if name in t[4] then
            t1 := "n/a";
         else
            SilentRead (g[1],g[2]);
            tmp := ValueGlobal (g[3]);
            if IsBound (t[5]) then
               t[5](tmp);
            fi;
            if IsBound (DO_TIMING) and DO_TIMING then
               GASMAN ("collect");
            fi;
            t0 := Runtime();
            res := t[1](tmp);
            t1 := Runtime() - t0;
            res := t[2](res);
            if prevres <> fail then
               if res <> fail and res <> prevres then
                  Error ("results do not match");
               fi;
            else
               prevres := res;
            fi;
            UnbindGlobal (g[3]);
         fi;
         
         if IsBound (DO_TIMING) and DO_TIMING then
            Print (String(t1,8), "\c");
            if IsBound (t[6]) then
               Print (String(t[6](),8), "\c");
            fi;
         fi;
      od;
      Print ("  ");
      if IsInt (prevres) then # assume that it is the order of a subgroup
         PrintFactorsInt (prevres);
         Print ("  ");
         PrintFactorsInt (size/prevres);
      elif IsList (prevres) then # assume that it is a list of subgroups
         Print (Length (prevres));
      else
         Print (prevres);
      fi;
      Print ("\n");
   od;
end;


############################################################################
##
#F  SpecialPcGroup (grp)
##
##  return a pc group isomorphic with grp whose family pcgs is a special 
##  pcgs
##
SpecialPcGroup := G -> Image (IsomorphismSpecialPcGroup (G));

############################################################################
##
#V  tSpcgs
##
##  store time needed to compute a special pcgs
##
tSpcgs := 0;


############################################################################
##
#F  SpcgsCompute (grp)
##
##  compute a special pcgs and store the time needed in the global variable
##  tSpcgs
##
SpcgsCompute  := function (tmp)
	local t0;
	if IsBound (DO_TIMING) and DO_TIMING then
		GASMAN ("collect");
	fi;
	t0 := Runtime();
	IsomorphismSpecialPcGroup (tmp);
	tSpcgs := Runtime() - t0;
end;

############################################################################
##
#F  SpcgsTime ()
##
##  return time needed to compute special pcgs
##
SpcgsTime := function ()
	return tSpcgs;
end;


############################################################################
##
#V  mtxinfo
##
##  variable used by the Smash meataxe  to record internal running times
##
mtxinfo := [];


############################################################################
##
#F  MTXTime (grp)
##
##  compute time needed by meataxe
##
MTXTime := function ()
   return Sum (mtxinfo, x -> x[2]);
end;


############################################################################
##
#F  MTXTime (grp)
##
##  reset time measurement by meataxe
##
MTXReset := function (tmp)
   mtxinfo := [];
end;


############################################################################
##
#E
##
