#############################################################################
##
#W  pminus1.gi               GAP4 Package `FactInt'               Stefan Kohl
##
##  This file contains functions for factorization using Pollard's p-1.
##
##  Arguments of FactorsPminus1:
##
##  <n>        the integer to be factored
##  <a>        the base for exponentiation; usually, <a> = 2 (default)
##  <Limit1>   the limit for the first stage
##  <Limit2>   the limit for the second stage
##
##  The result is returned as a list of two lists. The first list
##  contains the prime factors found, and the second list contains
##  remaining unfactored parts of <n>, if there are any.
##
#############################################################################

Pminus1Split := function (n,a,Limit1,Limit2)

  local  PowerOfa,PowerAfterFirstStage,p,pExponent,
         DiffPowers,DiffPos,DiffSum,NextDiff,DiffsLng,BufProd,
         FactorFoundAndReady,FactorsFound;

  FactorFoundAndReady := function (PowerProd)
    
    local  Result,i;

    Result := Gcd(PowerProd,n);
    if not Result in [1,n] then
      Info(IntegerFactorizationInfo,1,LogInt(Result,10) + 1,
           "-digit factor ",Result," was found");
      Add(FactorsFound,Result); n := n/Result;
      if IsProbablyPrimeInt(n) then Add(FactorsFound,n); return true; fi;
      if IsBound(DiffPowers) then 
        for i in [1..Length(DiffPowers)] do
          if   IsBound(DiffPowers[i]) 
          then DiffPowers[i] := DiffPowers[i] mod n; fi;
        od;
      fi;
    fi;
    return false;
  end;

  if IsProbablyPrimeInt(n) then return [n]; fi;
  FactorsFound := [];

  Info(IntegerFactorizationInfo,2,
       "p-1 for n = ",n,"\na : ",a,
       ", Limit1 : ",Limit1,", Limit2 : ",Limit2);

  Info(IntegerFactorizationInfo,2,"First stage");
  p := 2; PowerOfa := a;
  while p <= Limit1 do
    pExponent := LogInt(Limit1,p);
    PowerOfa  := PowerModInt(PowerOfa,p^pExponent,n);
    if   FactorFoundAndReady(PowerOfa - 1) 
    then return FactorsFound; fi;
    p := NextPrimeInt(p);
  od;

  Info(IntegerFactorizationInfo,2,"Second stage");
  PowerAfterFirstStage := PowerOfa; PowerOfa := 1;
  DiffPowers := []; DiffPos := 1; DiffSum := 0;
  DiffsLng := Length(PrimeDiffs); BufProd := 1;
  while (DiffSum <= Limit2) and (DiffPos <= DiffsLng) do
    NextDiff := PrimeDiffs[DiffPos];
    DiffSum  := DiffSum + NextDiff;
    if not IsBound(DiffPowers[NextDiff]) 
    then DiffPowers[NextDiff] := 
         PowerModInt(PowerAfterFirstStage,NextDiff,n); fi;
    PowerOfa := PowerOfa * DiffPowers[NextDiff] mod n;
    BufProd  := BufProd  * (PowerOfa - 1) mod n;
    if DiffPos mod 100 = 0 then
      if   FactorFoundAndReady(BufProd)
      then return FactorsFound; fi;
    fi; 
    DiffPos := DiffPos + 1;
  od;

  Add(FactorsFound,n); return FactorsFound;
end;
MakeReadOnlyGlobal("Pminus1Split");

#############################################################################
##
#F  FactorsPminus1( <n>, [ [ <a> ], <Limit1>, [ <Limit2> ] ] )
##
InstallGlobalFunction( FactorsPminus1,

function ( arg )

  local  n, a, Limit1, Limit2, GetArg, ArgCorrect,
         FactorsList, m, Split, q;

  GetArg := function (ArgPos,ArgName,ArgDefault)
    if IsBound(arg[ArgPos]) then 
      if arg[ArgPos] <> fail then return arg[ArgPos];
                             else return ArgDefault; fi; 
    fi;
    if ValueOption(ArgName) <> fail then return ValueOption(ArgName); fi;
    return ArgDefault;
  end;

  ArgCorrect := Length(arg) in [1..4];
  if ArgCorrect then
    n := arg[1];
    if Length(arg) = 4 
    then
      a      := arg[2];
      Limit1 := GetArg(3,"Pminus1Limit1",Int(PrimeDiffLimit/40));
      Limit2 := GetArg(4,"Pminus1Limit2",40 * Limit1);
    else
      a      := 2;
      Limit1 := GetArg(2,"Pminus1Limit1",Int(PrimeDiffLimit/40));
      Limit2 := GetArg(3,"Pminus1Limit2",40 * Limit1);
    fi; 
    if not (IsInt(n) and n > 1 and IsInt(a) and a >= 2
            and IsPosInt(Limit1) and IsPosInt(Limit2)) 
    then ArgCorrect := false; fi; 
  fi;
  if not ArgCorrect
  then Error("Usage : FactorsPminus1( <n>, [ [ <a> ], <Limit1>, ",
             "[ <Limit2> ] ] ), where <n>, <a>, <Limit1> and <Limit2> ",
             "have to be integers > 1.");
  fi;

  if IsProbablyPrimeInt(n) then return [[n],[]]; fi;

  InitPrimeDiffs(Limit2); 

  FactorsList := FactorsTD(n); 
  if FactorsList[2] <> [] then
    m := FactorsList[2][1];
    if   SmallestRootInt(m) < m
    then ApplyFactoringMethod(FactorsPowerCheck,
                              [FactorsPminus1,"FactorsPminus1"],
                              FactorsList,infinity);
    else
      Split := Pminus1Split(m,a,Limit1,Limit2);
      FactorsList[2] := [];
      for q in Split do if   IsProbablyPrimeInt(q) 
                        then Add(FactorsList[1],q);
                        else Add(FactorsList[2],q); fi; od;
    fi;
  fi;

  Sort(FactorsList[1]); Sort(FactorsList[2]);
  FactorizationCheck(n,FactorsList);
  return FactorsList;
end);

#############################################################################
##
#E  pminus1.gi . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here