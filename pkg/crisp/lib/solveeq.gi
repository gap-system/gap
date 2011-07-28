#############################################################################
##
##  solveeq.gi                      CRISP                    Burkhard Höfling
##
##  @(#)$Id: solveeq.gi,v 1.6 2011/05/15 19:18:04 gap Exp $
##
##  Copyright (C) 2000-2002 Burkhard Höfling
##
Revision.solveeq_gi :=
    "@(#)$Id: solveeq.gi,v 1.6 2011/05/15 19:18:04 gap Exp $";


#############################################################################
##
#F  LinearSystem (nrvars, nrsolutions, field, conv, convsol)
##
InstallGlobalFunction (LinearSystem,
   function (nrvars, nrsolutions, field, conv, convsol)

      local sys, i;
         
      sys := rec(
         nrvars := nrvars,
         nrsolutions := nrsolutions,
         field := field,
         fieldsize := Size (field),
         zero := Zero (field),
         one := One (field),
         equations := [],
         nrequations := 0,
         solutions := [],
         solvable := ListWithIdenticalEntries (nrsolutions,true),
         conv := conv,
         convsol := convsol,
         nullrow := ListWithIdenticalEntries (nrvars, Zero (field)),
         nullsol := ListWithIdenticalEntries (nrsolutions, Zero (field)));
     if conv then
         ConvertToVectorRep (sys.nullrow, sys.fieldsize);
     fi;
     if convsol then
         ConvertToVectorRep (sys.nullsol, sys.fieldsize);
     fi;
         
      return sys;
   end);


#############################################################################
##
#F  AddEquation (sys, row, sol)
##
InstallGlobalFunction (AddEquation,
    function (sys, r, s)

      local row, sol, i, solv, oldsolv, coeff;
      
      if Length (r) <> sys.nrvars or Length (s) <> sys.nrsolutions 
            or (sys.conv and sys.fieldsize <> ConvertToVectorRep (r, sys.fieldsize)) 
            or (sys.convsol and sys.fieldsize <> ConvertToVectorRep (s, sys.fieldsize)) then
         Error ("vectors must be of the right length and over the correct field");
      fi;
      
      row := ShallowCopy (r);
      sol := ShallowCopy (s);
      
      i := 1;
      while  i <= sys.nrvars do
         coeff := row[i];
         if coeff <> sys.zero then
            if IsBound (sys.equations[i]) then
               # row := row - row[i] * sys.equations[i];
               AddRowVector (row, sys.equations[i], - coeff);
               if sys.nrsolutions > 0 then
               	  AddRowVector (sol, sys.solutions[i], - coeff);
               fi;
            elif coeff = sys.one then
               sys.equations[i] := row;
               if sys.nrsolutions > 0 then
                  sys.solutions[i] := sol;
               fi;
               sys.nrequations := sys.nrequations + 1;
               return true;
            else
               sys.equations[i] := row / coeff;
               if sys.nrsolutions > 0 then
                  sys.solutions[i] := sol / coeff;
               fi;
               sys.nrequations := sys.nrequations + 1;
               return true;
            fi;
         fi;
         i := i + 1;
      od;
      
      solv := true;
      for i in [1..sys.nrsolutions] do
         if sys.solvable[i] and sol[i] <> sys.zero then
            sys.solvable[i] := false;
            solv := false;
         fi;
      od;

      return solv;
   end);


#############################################################################
##
#F  HasSolution (sys, n)
##
InstallGlobalFunction (HasSolution, 
   function (sys, n)

      return sys.solvable[n];
   end);


#############################################################################
##
#F  DimensionOfNullspace (sys)
##
InstallGlobalFunction (DimensionOfNullspace, 
   function (sys)

      return sys.nrvars - sys.nrequations;
   end);


#############################################################################
##
#F  OneSolution (sys, n)
##
InstallGlobalFunction (OneSolution, 
   function (sys, n)

      local s, i;
      
      if not sys.solvable[n] then
         return fail;
      fi;
      
      s := ShallowCopy (sys.nullrow);
      
      for i in [sys.nrvars, sys.nrvars-1..1] do 
         # treat the i-th row   
         if IsBound (sys.equations[i]) then
            s[i] := sys.solutions[i][n] - s*sys.equations[i];
         fi;
      od;
            
      return s;
   end);


#############################################################################
##
#F  BasisNullspaceSolution (sys)
##
InstallGlobalFunction (BasisNullspaceSolution,

   function (sys)

      local v, i, j, basis, nullspace;
      
      nullspace := [];
      
      for i in [sys.nrvars, sys.nrvars-1..1] do 
         # treat the i-th row   
         if not IsBound (sys.equations[i]) then
            v := ShallowCopy (sys.nullrow);
            v[i] := sys.one;
            for j in [i-1, i-2 .. 1] do
               if IsBound (sys.equations[j]) then
                  v[j] := - v * sys.equations[j];
               fi;
            od;
            Add (nullspace, v{[1..sys.nrvars]});
         fi;
      od;
      return nullspace;
   end);

  
############################################################################
##
#E
##
