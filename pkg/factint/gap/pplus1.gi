#############################################################################
##
#W  pplus1.gi               GAP4 Package `FactInt'                Stefan Kohl
##
##  This file contains functions for factorization using a variant of
##  Williams' p+1.
##
##  Arguments of FactorsPplus1:
##
##  <n>         the integer to be factored
##  <Residues>  the number of residues that should be examined
##              (the probability of hitting a usable one is
##              approx. 1 - 1/2^<Residues>)
##  <Limit1>    the limit for the first stage
##  <Limit2>    the limit for the second stage
##
##  The result is returned as a list of two lists. The first list
##  contains the prime factors found, and the second list contains
##  remaining unfactored parts of <n>, if there are any.
##
#############################################################################

Pplus1Product := function (a,b,n)

  local  c,c12,a12b12;

  a12b12 := a[1][2] * b[1][2];
  c12    := (a[1][1] * b[1][2] + a[1][2] * b[2][2]) mod n;
  c      := [[(a[1][1] * b[1][1] + a12b12) mod n, c12],
             [c12, (a12b12 + a[2][2] * b[2][2]) mod n]];
  return c;
end;
MakeReadOnlyGlobal("Pplus1Product");

Pplus1Square := function (a,n)

  local  c,c12,a12a12;

  a12a12 := a[1][2] * a[1][2];
  c12    := a[1][2] * (a[1][1] + a[2][2]) mod n;
  c      := [[(a[1][1]^2 + a12a12) mod n, c12],
             [c12, (a12a12 + a[2][2]^2) mod n]];
  return c;
end;
MakeReadOnlyGlobal("Pplus1Square");

Pplus1Power := function (Base,exp,n)

  local  Power,BinExp,i;

  BinExp := CoefficientsQadic(exp,2);
  Power  := Base;

  for i in [Length(BinExp),Length(BinExp)-1..2] do
    Power := Pplus1Square(Power,n);
    if BinExp[i-1] = 1 then
      Power := Pplus1Product(Power,Base,n);
    fi;
  od;

  return Power;
end;
MakeReadOnlyGlobal("Pplus1Power");

Pplus1Split := function (n,Residues,Limit1,Limit2)

  local  Residue,ResNo,a,
         PowerOfa,PowerAfterFirstStage,p,pExponent,
         DiffPowers,DiffPos,DiffSum,NextDiff,DiffsLng,BufProd,
         FactorFoundAndReady,FactorsFound;

  FactorFoundAndReady := function (PowerProd)
    
    local  Result,i,j,k;

    Result := Gcd(PowerProd,n);
    if not Result in [1,n] then
      Info(IntegerFactorizationInfo,1,LogInt(Result,10) + 1,
           "-digit factor ",Result," was found");
      Add(FactorsFound,Result); n := n/Result;
      if IsProbablyPrimeInt(n) then Add(FactorsFound,n); return true; fi;
      if IsBound(DiffPowers) then 
        for i in [1..Length(DiffPowers)] do 
          if IsBound(DiffPowers[i]) then 
            for j in [1,2] do for k in [1,2] do
              DiffPowers[i][j][k] := DiffPowers[i][j][k] mod n;
            od; od; 
          fi;
        od;
      fi;
    fi;
    return false;
  end;

  if IsProbablyPrimeInt(n) then return [n]; fi;
  FactorsFound := [];

  Info(IntegerFactorizationInfo,2,
       "p+1 for n = ",n,"\nResidues : ",Residues,
       ", Limit1 : ",Limit1,", Limit2 : ",Limit2);

  Residue := 1;
  for ResNo in [1..Residues] do
    Info(IntegerFactorizationInfo,2,"Residue no. ",ResNo);
    a := [[Residue,1],[1,0]];

    Info(IntegerFactorizationInfo,3,"First stage");
    p := 2; PowerOfa := a;
    while p <= Limit1 do
      pExponent := LogInt(Limit1,p);
      PowerOfa  := Pplus1Power(PowerOfa,p^pExponent,n);
      if   FactorFoundAndReady(PowerOfa[1][2]) 
      then return FactorsFound; fi;
      p := NextPrimeInt(p);
    od;

    Info(IntegerFactorizationInfo,3,"Second stage");
    PowerAfterFirstStage := PowerOfa; PowerOfa := [[1,0],[0,1]];
    DiffPowers := []; DiffPos := 1; DiffSum := 0;
    DiffsLng := Length(PrimeDiffs); BufProd := 1;
    while (DiffSum <= Limit2) and (DiffPos <= DiffsLng) do
      NextDiff := PrimeDiffs[DiffPos];
      DiffSum := DiffSum + NextDiff;
      if not IsBound(DiffPowers[NextDiff]) 
      then DiffPowers[NextDiff] := 
           Pplus1Power(PowerAfterFirstStage,NextDiff,n); fi;
      PowerOfa := Pplus1Product(PowerOfa,DiffPowers[NextDiff],n);
      BufProd  := BufProd * PowerOfa[1][2] mod n;
      if DiffPos mod 50 = 0 then
        if   FactorFoundAndReady(BufProd)
        then return FactorsFound; fi;
      fi; 
      DiffPos := DiffPos + 1;
    od;
    Residue := NextPrimeInt(Residue);
  od;

  Add(FactorsFound,n); return FactorsFound;
end;
MakeReadOnlyGlobal("Pplus1Split");

#############################################################################
##
#F  FactorsPplus1( <n>, [ [ <Residues> ], <Limit1>, [ <Limit2> ] ] )
##
InstallGlobalFunction( FactorsPplus1,

function ( arg )

  local  n, Residues, Limit1, Limit2, GetArg, ArgCorrect,
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
      Residues := arg[2];
      Limit1   := GetArg(3,"Pplus1Limit1",Int(PrimeDiffLimit/40));
      Limit2   := GetArg(4,"Pplus1Limit2",40 * Limit1);
    else
      Residues := GetArg(5,"Pplus1Residues",2);
      Limit1   := GetArg(2,"Pplus1Limit1",Int(PrimeDiffLimit/40));
      Limit2   := GetArg(3,"Pplus1Limit2",40 * Limit1);
    fi; 
    if not (IsInt(n) and n >= 1 and IsInt(Residues) and Residues >= 1
            and IsPosInt(Limit1) and IsPosInt(Limit2)) 
    then ArgCorrect := false; fi; 
  fi;
  if not ArgCorrect
  then Error("Usage : FactorsPplus1( <n>, [ [ <Residues> ], <Limit1>, ",
             "[ <Limit2> ] ] ), where <n>, <Residues>, ",
             "<Limit1> and <Limit2> have to be positive integers");
  fi;

  if IsProbablyPrimeInt(n) then return [[n],[]]; fi;

  InitPrimeDiffs(Limit2); 

  FactorsList := FactorsTD(n);
  if FactorsList[2] <> [] then
    m := FactorsList[2][1];
    if   SmallestRootInt(m) < m
    then ApplyFactoringMethod(FactorsPowerCheck,
                              [FactorsPplus1,"FactorsPplus1"],
                              FactorsList,infinity);
    else
      Split := Pplus1Split(m,Residues,Limit1,Limit2);
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
#E  pplus1.gi  . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here