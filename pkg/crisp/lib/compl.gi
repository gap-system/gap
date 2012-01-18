#############################################################################
##
##  compl.gi                         CRISP                   Burkhard Höfling
##
##  @(#)$Id: compl.gi,v 1.10 2011/07/17 11:53:45 gap Exp $
##
##  Copyright (C) 2000-2002, 2005 Burkhard Höfling
##
Revision.compl_gi :=
    "@(#)$Id: compl.gi,v 1.10 2011/07/17 11:53:45 gap Exp $";


#############################################################################
##
#F  PcgsComplementOfChiefFactor (<pcgs>, <hpcgs>, <first>, <npcgs>, <kpcgs>)
##
InstallGlobalFunction ("PcgsComplementOfChiefFactor", 
   function (pcgs, hpcgs, first, npcgs, kpcgs)

   local 
      p,        # prime exponent of npcgs
      q,        # prime dividing the order of the sylow subgroup
      r,        # integer divisible by p with r mod q = 1
      field,    # GF(p)
      qpcgs,    # pc sequence for Q mod K
      depths,   # depths of elements in qpcgs (wrt pcgs)
      cpcgs,    # pc sequence for a complement
      cdepths,  # depths of elements in cpcgs (wrt pcgs)
      copied,   # true if cpcgs is a shallow copy of qpcgs, 
                # false as long as they refer to the same object
      g,        # element to be adjusted
      conj,     # qgens[k]^g
      n,        # conj = t * n with t in Q and n in  N
      e,        # exponent vector 
      lhs,      # lhs of linear system of equations 
      rhs,      # rhs of linear system of equations 
      sol,      # solution of the system 
      j, k, l,  # loop indices
      tmp;      # temp store for result, for debugging only

   p := RelativeOrderOfPcElement (npcgs, npcgs[1]);
   q := RelativeOrderOfPcElement (pcgs, hpcgs[first]);
   Assert (1, p <> q);
   field := GF(p);
   
   # compute a pc sequence qpcgs (of length 1) for a Sylow q-subgroup of N/K 
   # in the group <hpcgs[Length(hpcgs)], N>/K

   r := Gcdex (p, q).coeff1 * p;
   qpcgs := [hpcgs[Length(hpcgs)]^r];
   depths := [DepthOfPcElement (pcgs, qpcgs[1])]; # depths of elements of qpcgs
   
   # complement and Sylow subgroup coincide
   copied:= false; 
   
   for j in [Length (hpcgs)-1, Length (hpcgs)-2..1] do
   
      # now extend cpcgs, and if j >= first, also qpcgs, to pc sequences
      # representing a complement and a Sylow q-subgroup of 
      # the group <hpcgs{[j..Length(hpcgs)]}, N>/K
      
      # This is done by finding a product x of elements of npcgs such that 
      # hpcgs[j]*x normalizes qpcgs (modulo K).
      # The exponents of x wrt. npcgs can be found by solving linear equations
      
      g := hpcgs[j];
         
      lhs := [];
      rhs := [];
         
      for l in [1..Length (npcgs)] do
         lhs[l] := [];
      od;
         
      # determine the conjugation action of g = hpcgs[j] on npcgs
      for k in [1..Length (qpcgs)] do
         conj := qpcgs[k]^g;
         n := SiftedPcElementWrtPcSequence (pcgs, qpcgs, depths, conj);
         for l in [1..Length (npcgs)] do
            e := ExponentsConjugateLayer (npcgs, npcgs[l], conj)* One (field);
            e[l] := e[l] - One(field);
            Append (lhs[l],e);
         od;   
         
         Append (rhs, ExponentsOfPcElement (npcgs, n) * One(field));
      od;
         
      # now solve the system and adjust g = hpcgs[j]
      
      sol := SolutionMat (lhs , rhs);

      g := g * PcElementByExponentsNC (npcgs, List (sol, IntFFE ));;
      
      if j >= first then # we are computing a pcgs for Q and C
         g := g^r;
         AddPcElementToPcSequence (pcgs, qpcgs, depths, g);
      else # Q is found, we only extend C
         if not copied then
            cpcgs := ShallowCopy (qpcgs);
            cdepths := ShallowCopy (depths);
            copied := true;
         fi;
         AddPcElementToPcSequence (pcgs, cpcgs, cdepths, g);
      fi;
   od;

   if not copied then # this only happens if R = H, or equivalently if first = 1
      cpcgs := qpcgs;
      cdepths := depths;
   fi;
   
   for g in kpcgs do
      AddPcElementToPcSequence (pcgs, cpcgs, cdepths, g);
   od;
   
   tmp := InducedPcgsByPcSequenceNC (pcgs, cpcgs);
   Assert (1, CanonicalPcgs (tmp) = CanonicalPcgs (InducedPcgsByGenerators (pcgs, cpcgs)),
      Error ("cpcgs is not a pc sequence"));
   return tmp;
end);


#############################################################################
##
#F  COMPLEMENT_SOLUTION_FUNCTION (<complements>, <i>)
##
InstallGlobalFunction ("COMPLEMENT_SOLUTION_FUNCTION",
   function (complements, i)
   
      local s, w, depth, len, gens;
      s := Length (complements.mpcgs);
      gens := List (complements.nden);
      w := complements.oneSolution + complements.solutionSpace[i];
      len := Length (gens);
      if not IsBound (complements.denomDepths) then
         complements.denomDepths := List (gens, x -> DepthOfPcElement (complements.pcgs, x));
      fi;
      depth := ShallowCopy (complements.denomDepths);
      
      for i in [1..s] do
         AddPcElementToPcSequence (complements.pcgs, gens, depth,
            complements.mpcgs[i] 
               * PcElementByExponents (complements.npcgs, 
                  w{[i,i+s..i+(Length (complements.npcgs)-1)*s]}));
      od;
      gens := InducedPcgsByPcSequenceNC (complements.pcgs, gens);

      Assert (1, CanonicalPcgs (gens) 
            = CanonicalPcgs (InducedPcgsByGenerators (complements.pcgs, gens)),
         Error ("gens is not a pc sequence"));
      return gens;
      
   end);


#############################################################################
##
#F  EnumeratorOfTriangle (<k>)
##  
##  enumerates pairs [1,1], [2,1], [2,2], [3,1], [3,2], [3,3], ...
##
BindGlobal ("EnumeratorOfTriangle", function (k)

	local i, j;
	
	i := QuoInt (1 + RootInt (8*k-1), 2);
	j := k - i* (i-1)/2;
	return [i,j];
end);


#############################################################################
##
#F  ExtendedPcgsComplementsOfCentralModuloPcgsUnderAction (
##      <act>, <pcgs>, <gpcgs>, <npcgs>, <kpcgs>, <all>)
##
InstallGlobalFunction (ExtendedPcgsComplementsOfCentralModuloPcgsUnderAction,
   function (act, pcgs, gpcgs, npcgs, kpcgs, all)

      local 
         gamma,       # exponent vector
         delta,       # exponent vector
         exp,         # exponent vector
         c,           # exponent vector
         d,           # exponent vector
         e,           # list of exponent vectors
         field,       # prime field, its order = exponent
                      # of factor grp. represented by npcgs
         sys,         # system of linear equations
         row,         # row to be added to sys
         nreq,        # number of equations to be solved
         perm,        # random permutation of the equations
         count,       # loop variable
         eq,          # number of equation to add
         eqind,       # pair of indices specifying equation
         bas,         # basis of solution space of linear system
         i, j, k, l,  # loop variables
         r,           # length of act
         s,           # length of gpcgs
         n,           # length of npcgs
         y,           # group elements
         p,           # relative order of a group element
         complements, # record storing the result
         t;           # for measuring the running time
      
      t := Runtime();
      
      if IsGroup (act) then
         act := GeneratorsOfGroup (act);
      fi;
      r := Length (act);
      s := Length (gpcgs);   
      n := Length (npcgs);
      
      Info (InfoComplement, 1, "complementing (bot =", n, ", top = ", s,
         ", act = ", r,")");
         
      # set up result record
      
      complements := rec (
         pcgs := pcgs,
         mpcgs := gpcgs,
         npcgs := npcgs,
         nden := kpcgs);

      # handle some trivial cases
      if n = 0 then
         complements.nrSolutions := 1;
         complements.solutionFunction := 
            function (complements, i)
               return NumeratorOfModuloPcgs (complements.mpcgs);
            end;
         Info (InfoComplement, 2, "trivial solution (n = 0)");
         Info (InfoComplement, 3, "time = ", Runtime() - t);
         return complements;
      elif s = 0 then
         complements.nrSolutions := 1;
         complements.solutionFunction := 
            function (complements, i)
               return complements.nden;
            end;
         Info (InfoComplement, 2, "trivial solution (s = 0)");
         Info (InfoComplement, 3, "time = ", Runtime() - t);
         return complements;
      fi;
      
      # prepare a solution for the case when no complement exists
      complements.nrSolutions := 0;
      complements.solutionFunction := ReturnFail;
      

      # We want to find a vector t over field such that when
      # for i = 1..s, the element gpcgs[i] is multiplied by 
      # npcgs[1]*t[i] + npcgs[2]*t[i+s] + ... + npcgs[n]*t[i+(n-1)*s],
      # then the elements of the modified gpcgs satisfy the same relations 
      # modulo kpcgs which the original elements of gpcgs satisfied modulo
      # NumeratorOfModuloPcgs (npcgs)
      # The requirements for t translate into a system of linear equations,
      # which we now set up.
      
      field := GF(RelativeOrderOfPcElement (npcgs, npcgs[1]));
      sys:= LinearSystem (n*s, 1, field, n*s > 20, false);
         
      Info (InfoComplement, 2, "computing linear action on N");
      
      e := [];
      nreq := s*(s+1)/2 + r*s;
      perm := Random (SymmetricGroup (nreq));
      
      for count in [1..nreq] do
         eq := count^perm;
         
         if eq <= r * s then
         	i := QuoInt (eq-1, r) + 1;
         	j := eq - r * (i - 1);
         	
            # add equations to ensure invariance of the complement under <act>
            if not IsBound (e[j]) then
               e[j] := [];
               for l in [1..n] do
                  y := npcgs[l]^act[j];
                  Assert (1, y in Group (Concatenation (npcgs, kpcgs)), 
                     Error("npcgs[l]^act[j] must be in N"));
                  e[j][l] := ExponentsOfPcElement (npcgs, y) * One(field);
               od;
            fi;
            
            # express gpcgs[i]^act[j] mod kpcgs as a product of elements 
            # in gpcgs and npcgs
            y := gpcgs[i]^act[j];
            exp := ExponentsOfPcElement (gpcgs, y);
            delta := exp * One (field);
            y := LeftQuotient (PcElementByExponents (gpcgs, exp), y);
            Assert (1, y in Group (Concatenation (npcgs, kpcgs)), 
               Error ("gpcgs[i]^act[j]/... must be in N"));
            d := ExponentsOfPcElement (npcgs, y) * One(field);

            # translate into a linear equation
            for k in [1..n] do
               row := ShallowCopy (sys.nullrow);
               row{[(k-1)*s+1..k*s]} := delta;
              
               for l in [1..n] do
                  row[(l-1)*s+i] := row[(l-1)*s+i]-e[j][l][k];
               od;
                              
               if not AddEquation (sys, row, [d[k]]) then
                  Info (InfoComplement, 2, "no solution");
                  Info (InfoComplement, 3, "time = ", Runtime() - t);
                  return complements;
               fi;
            od;
         else # power or conjugate relations of factor group
            eqind := EnumeratorOfTriangle (eq - r*s);
            i := eqind[1];
            j := eqind[2];
            if i = j then
               # evaluate power relation
               # express gpcgs[i]^p mod kpcgs as a product of elements in gpcgs and npcgs
               p := RelativeOrderOfPcElement (gpcgs, gpcgs[i]);
               y := gpcgs[i]^p;
               exp := ExponentsOfPcElement (gpcgs, y);
               y := LeftQuotient (PcElementByExponents (gpcgs, exp), y);
        
               Assert (1, y in Group (NumeratorOfModuloPcgs(npcgs)), 
                  Error ("gpcgs[i]^p/... must be in N"));
	           
	           exp[i] := - p;
	           gamma := exp * One (field);
	           c := ExponentsOfPcElement (npcgs, y) * One(field);
	     
	           # translate into a linear equation
               for k in [1..n] do
                  row := ShallowCopy (sys.nullrow);
                  row{[(k-1)*s+1..k*s]} := gamma;
                  if not AddEquation (sys, row, [c[k]]) then
                     Info (InfoComplement, 2, "no solution");
                     Info (InfoComplement, 3, "time = ", Runtime() - t);
                     return complements;
                  fi;
               od;
            else
               # evaluate conjugation relation
               # express gpcgs[i]^gpcgs[j] mod kpcgs as a product of elements 
               # in gpcgs and npcgs
               y := gpcgs[i]^gpcgs[j]; 
               exp := ExponentsOfPcElement (gpcgs, y);
               y := LeftQuotient (PcElementByExponents (gpcgs, exp), y);
               Assert (1, y in Group (Concatenation (npcgs, kpcgs)), 
                  Error ("Comm (gpcgs[i], gpcgs[j])/... must be in N"));
               exp[i] := exp[i]-1;
               gamma := exp * One (field);
               c := ExponentsOfPcElement (npcgs, y) * One(field);

               # translate into an equation
               for k in [1..n] do
                  row := ShallowCopy (sys.nullrow);
                  row{[(k-1)*s+1..k*s]} := gamma;
                  if not AddEquation (sys, row, [c[k]]) then
                     Info (InfoComplement, 2, "no solution");
                     Info (InfoComplement, 3, "time = ", Runtime() - t);
                     return complements;
                  fi;
               od;
            fi;
         fi; 
      od;
      
      # now compute a solution of the system
      complements.oneSolution := OneSolution (sys,1);
      
      # add a function which generates the pcgs of any complement found
      complements.solutionFunction := COMPLEMENT_SOLUTION_FUNCTION;

      if all then
         bas := BasisNullspaceSolution (sys);
         complements.solutionSpace := Enumerator(
            VectorSpace (field, bas, complements.oneSolution*Zero(field)));
         complements.nrSolutions := Size (field)^Length (bas);
         Info (InfoComplement, 2, complements.nrSolutions, " solution(s) found");

      else # if we only want one solution, why bother computing the nullspace
         complements.solutionSpace := [complements.oneSolution*Zero(field)];
         complements.nrSolutions := 1;
         Info (InfoComplement, 2, "one solution found (all = false)");
      fi;
      
      Info (InfoComplement, 3, "time = ", Runtime() - t);
      return complements;
   end);


#############################################################################
##
#F  PcgsComplementsOfCentralModuloPcgsUnderActionNC (
##      <act>, <pcgsnum>, <pcgs>, <mpcgs>, <pcgsdenum>, <all>)
##
InstallGlobalFunction (PcgsComplementsOfCentralModuloPcgsUnderActionNC,
   function (act, pcgs, gpcgs, npcgs, kpcgs, all)
      local complements;
      complements := 
         ExtendedPcgsComplementsOfCentralModuloPcgsUnderAction (
            act, pcgs, gpcgs, npcgs, kpcgs, all);
      return List ([1..complements.nrSolutions], 
            i -> complements.solutionFunction (complements, i));
   end);
   
#############################################################################
##
#F  PcgsInvariantComplementsOfElAbModuloPcgs (
##      <act>, <pcgsnum>, <pcgs>, <mpcgs>, <pcgsdenum>, <all>)
##
InstallGlobalFunction ("PcgsInvariantComplementsOfElAbModuloPcgs",
   function (act, pcgs, gpcgs, npcgs, kpcgs, all)

      if CentralizesLayer (gpcgs, npcgs) then
         return PcgsComplementsOfCentralModuloPcgsUnderActionNC (
            act, pcgs, gpcgs, npcgs, kpcgs, all);
      else
         return [];
      fi;
   end);
   

#############################################################################
##
#M  ComplementsOfCentralSectionUnderActionNC (<act>,<G>,<N>,<L>,<all>)
##
##  version where <act> is a list of maps G -> G (which are supposed to
##  induce automorphisms on G/L)
##
InstallMethod (ComplementsOfCentralSectionUnderActionNC,
    "for section of solvable group",
   function (famact, famG, famN, famL, famall)
      return IsIdenticalObj (famG, famN) and IsIdenticalObj (famN, famL) ;
   end,
   [IsListOrCollection, IsSolvableGroup and IsFinite, IsSolvableGroup and IsFinite, 
      IsSolvableGroup and IsFinite, IsBool], 0,
   function (act, G, N, L, all)

      local cpcgs, complements, pcgs, pcgsL;
      
      pcgs := ParentPcgs (Pcgs (G));
      pcgsL:= InducedPcgs (pcgs, L);
      cpcgs := PcgsComplementsOfCentralModuloPcgsUnderActionNC (
         act, pcgs, ModuloPcgs (G, N), ModuloPcgs (N, L), pcgsL, all);
      
      complements := List (cpcgs, c -> GroupOfPcgs (c));
      
      Assert (2, ForAll (complements, C ->
         IsNormal (G, C) 
            and NormalIntersection (C, N) = L 
            and Index (G, C) * Index (G, N) = Index (G, L)
            and ForAll (act, a -> Image (a, C) = C)),
         Error ("wrong invariant complement(s)"));
      if all then
         return complements;
      else
         if Length (complements) > 0 then
            return complements[1];
         else
            return fail;
         fi;
      fi;
   end);


#############################################################################
##
#F  ComplementsOfCentralSectionUnderAction (<act>, <G>, <N>, <L>, <all>)
##
InstallGlobalFunction ("ComplementsOfCentralSectionUnderAction",
   function (act, G, N, L, all)
      
      if ForAll (GeneratorsOfGroup (G), g ->
         ForAll (GeneratorsOfGroup (N), n -> Comm (g, n) in L)) then
            return ComplementsOfCentralSectionUnderActionNC (
               act, G, N, L, all);
      else
         Error ("G must centralize N/L");
      fi;
   end);
   
   
#############################################################################
##
#M  InvariantComplementsOfElAbSection (<act>,<G>,<N>,<L>,<all>)
##
##  version where <act> is a list of maps G -> G (which are supposed to
##  induce automorphisms on G/L)
##
InstallMethod (InvariantComplementsOfElAbSection,
    "for section of finite solvable group",
   function (famact, famG, famN, famL, famall)
      return IsIdenticalObj (famG, famN) and IsIdenticalObj (famN, famL);
   end,
   [IsListOrCollection, IsSolvableGroup and IsFinite, IsSolvableGroup and IsFinite, 
      IsSolvableGroup and IsFinite, IsBool], 0,
   function (act, G, N, L, all)

      local cpcgs, complements, pcgs, pcgsL;
      
      pcgs := ParentPcgs (Pcgs(G));
      pcgsL := InducedPcgs (pcgs, L);
      
      cpcgs := PcgsInvariantComplementsOfElAbModuloPcgs (
         act, pcgs, ModuloPcgs (G, N), ModuloPcgs (N, L), pcgsL, all);
      
      complements := List (cpcgs, c -> SubgroupByPcgs (G, c));
      
      if complements = fail then
         complements := [];
      fi;
      
      Assert (2, ForAll (complements, C ->
         IsNormal (G, C) 
            and NormalIntersection (C, N) = L 
            and Index (G, C) * Index (G, N) = Index (G, L)
            and ( (FamilyObj(act)=FamilyObj(C) and ForAll (act, a -> C^a = C))
               or (FamilyObj(act)<>FamilyObj(C) and ForAll (act, a -> Image (a, C) = C))
               )),
         Error ("wrong normal complement(s)"));
      if all then
         return complements;
      else
         if Length (complements) > 0 then
            return complements[1];
         else
            return fail;
         fi;
      fi;
   end);


#############################################################################
##
#F  ComplementsMaximalUnderAction (<act>, <ser>, <i>, <j>, <k>, <all>) 
## 
InstallGlobalFunction ("ComplementsMaximalUnderAction",
   function (act, ser, i, j, k, all)

      local p, complements, newser, l, pcgs;
      
      if i > j or j > k  then
         Error( "The indices must satisfy i <= j <= k" );
      fi;

      newser := [PcgsElementaryAbelianSeries (ser[i])];
      pcgs := ParentPcgs (newser[1]);
      for l in [i+1..k] do
         Add (newser, InducedPcgs (pcgs, ser[l]));
      od;
      
      complements := PcgsComplementsMaximalUnderAction (
         act, 
         pcgs, newser[1], newser, j-i+1, k-i+1, all);
      
      if all then
         return List (complements, GroupOfPcgs);
      elif IsEmpty (complements) then
         return fail;
      else
         return GroupOfPcgs (complements[1]);
      fi;
   end);
   
      
###################################################################################
##
#F  PcgsComplementsMaximalUnderAction (<act>, <U>, <ser>,  <j>, <k>, <all>) 
##
InstallGlobalFunction ("PcgsComplementsMaximalUnderAction",
   function (act, pcgs, upcgs, ser, j, k, all)
   
      local top, bot, CC, p, q, gens, x, y, complements;
         
      if j = k then
         return [upcgs]; # trivial case
      fi;
   
      top  := upcgs mod ser[j];
      
      if IsEmpty (top) then
         return [ser[k]]; # trivial case
      fi;
      
      bot  := ser[j] mod ser[j+1];
      
      # first compute complements modulo ser[j+1]
      CC := []; # assume that there are no complements
      
      if CentralizesLayer(top, bot) then 
         p := RelativeOrderOfPcElement (top,top[1]);
         q := RelativeOrderOfPcElement (bot, bot[1]);
         if p <> q then # coprime case
            CC := [InducedPcgsByPcSequenceAndGenerators (pcgs, ser[j+1],
                  List (top, x -> x^q))];
   
         elif ForAll (top, x-> SiftedPcElement (ser[j+1], x^p) = OneOfPcgs (pcgs)) then  
            # upcgs mod ser[j+1] is an elementary abelian  p-group
            CC := PcgsComplementsOfCentralModuloPcgsUnderActionNC (act, pcgs, top, bot, ser[j+1], all or j+1 < k);
         fi; # else upcgs mod ser[j+1] has exponent p^2, so no complement exists
      fi;
   
      Info (InfoComplement, 1, " depth ",k-j-1," ", Length (CC), " complements found");
   
      if j+1 = k then # we are done
         return CC;
      else # recurse      
         return Concatenation (List (CC, 
            C -> PcgsComplementsMaximalUnderAction (act, pcgs, C, ser, j+1, k, true)));
      fi;
   end);
      

###################################################################################
##
#E
##