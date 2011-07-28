#############################################################################
##
#W  ecm.gi                GAP4 Package `FactInt'                  Stefan Kohl
##
##  This file contains functions for factorization using the
##  Elliptic Curves Method (ECM).
##
##  Arguments of FactorsECM:  
## 
##  <n>       the integer to be factored
##  <Curves>  specifies how many different curves should be examined
##  <Limit1>  specifies a limit for the exponentiation of a point
##            on a given curve (``first stage limit'')
##  <Limit2>  gives the second stage limit
##  <Delta>   the increment per curve for the first stage limit
##            (the second stage limit is adjusted appropriately)
##
##  The result is returned as a list of two lists. The first list contains
##  the prime factors found, and the second list contains remaining
##  unfactored parts of <n>, if there are any.
##
##  The computations are done with elliptic curve points given in projective
##  coordinates [X,Y,Z], as integer solutions of
##
##                      b*Y^2*Z = X^3 + a*X^2*Z + X*Z^2,
##
##  where the ``point at infinity'', the identity element of the group
##  E(a,b)/n, corresponds to [0,Y,0] (with arbitrary Y). This avoids the
##  calculation of inverses (mod <n>) for the group operation and gives the
##  advantage of having an explicit representation of the identity element
##  on the one hand, but requires more multiplications (mod <n>) than in
##  affine representation on the other hand; since inversion (mod <n>) is
##  O((log n)^3) and multiplication (mod <n>) is only O((log n)^2), this is
##  at least asymptotically a good choice.
##
##  The algorithm only keeps track on two of the three coordinates, namely
##  X and Z.
##
##  The choice of curves is done in a way that ensures the order of the
##  respective group to be divisible by 12.
##
##  The implementation follows mainly the description of R. P. Brent given
##  in ``Factorization of the Tenth and Eleventh Fermat Numbers'', available
##  under
##  ftp://ftp.comlab.ox.ac.uk/pub/Documents/techpapers/Richard.Brent/
##  rpb161tr.dvi.gz, pp. 5 -- 8 (in terms of this paper, for the
##  second stage the ``improved standard continuation'' is used),
##  the group operations are performed as described in:
##
##  P. L. Montgomery, Speeding the Pollard and elliptic curve methods of
##  factorization, Math. Comp. 48 (1987)  
##
#############################################################################

ECMProduct := function (Quot,P1,P2,n)

  local  X1,Z1,X2,Z2,X3,Z3,
         Product1,Product2,Square1,Square2;

  X1 := P1[1]; X2 := P2[1];
  Z1 := P1[2]; Z2 := P2[2];

  Product1 := (X1 - Z1) * (X2 + Z2) mod n;
  Product2 := (X1 + Z1) * (X2 - Z2) mod n;
  Square1  := (Product1 + Product2)^2 mod n;
  Square2  := (Product1 - Product2)^2 mod n;
  X3       := Quot[2] * Square1 mod n;
  Z3       := Quot[1] * Square2 mod n;    

  return [X3,Z3];
end;
MakeReadOnlyGlobal("ECMProduct");

ECMSquare := function (P,n,a)

  local  X1,Z1,X2,Z2,
         Square1,Square2,FourX1Z1,FouraX1Z1;

  X1 := P[1]; Z1 := P[2];

  Square1   := (X1 + Z1)^2 mod n;
  Square2   := (X1 - Z1)^2 mod n;
  FourX1Z1  := Square1 - Square2;
  FouraX1Z1 := a * FourX1Z1 mod n;
  X2        := Square1 * Square2 mod n;
  Z2        := FourX1Z1 * (Square2 + FouraX1Z1) mod n;

  return [X2,Z2];
end;
MakeReadOnlyGlobal("ECMSquare");

ECMPower := function (Base,exp,n,a)

  local  Power,PowerTimesBase,BinExp,i;

  BinExp         := CoefficientsQadic(exp,2);
  Power          := Base;
  PowerTimesBase := ECMSquare(Base,n,a);

  for i in [Length(BinExp),Length(BinExp)-1..2] do
    if BinExp[i-1] = 1
    then 
      Power          := ECMProduct(Base,Power,PowerTimesBase,n);
      PowerTimesBase := ECMSquare (PowerTimesBase,n,a);
    else
      PowerTimesBase := ECMProduct(Base,Power,PowerTimesBase,n);
      Power          := ECMSquare (Power,n,a);
    fi;
  od;

  return Power;
end;
MakeReadOnlyGlobal("ECMPower");

ECMTryCurve := function (n,CurveNo,X,Z,a,Limit1,Limit2,StartingTime)

  local  p,q,qExponent,Point,GcdInterval,NextGcdAt,Lastq,
         PowerAfterFirstStage,GcdExtCutOffPoint,PowerTable,
         StepSize,DoubleStepSize,StepPos,DoubleStepSizePower,
         StepPower,LastStepPower,StepPowerBuf,BufProd,
         CoordDifference,PrimeDiffPos,PowerTablePos,qLimit,i,
         CurveStartingTime,FirstStageTime,SecondStageTime,
         CurveTime,TotalTime,Fill1,Fill2;

  CurveStartingTime := Runtime();

  p := Gcd(a^2 - 4,n);
  if p <> 1 then return rec(p := p, Stage := "first stage, precomp."); fi;
  a := (a + 2)/4 mod n;

  if CurveNo = 1 then GcdInterval := 1;
                 else GcdInterval := Int(Limit1/4); fi;
  NextGcdAt := GcdInterval;

  # First Stage

  q := 1; Lastq := PrevPrimeInt(Limit1);
  Point := [X,Z];
  while q <= Limit1 do
    q := NextPrimeInt(q);
    qExponent := LogInt(Limit1,q);
    if   q = 2 then qExponent := qExponent + 2;
    elif q = 3 then qExponent := qExponent + 1; fi;
    Point := ECMPower(Point,q^qExponent,n,a); 
    if q >= NextGcdAt then
      p := Gcd(Point[2],n);
      if p <> 1 then return rec(p := p, Stage := "first stage"); fi;
      NextGcdAt := Minimum(NextGcdAt + GcdInterval,Lastq);
    fi;
  od;
  FirstStageTime := Runtime() - CurveStartingTime;

  # Second Stage

  PowerAfterFirstStage := Point;

  StepSize      := Minimum(Int(Limit1/2),RootInt(Int(Limit2/2)));
  PowerTable    := [ECMSquare(PowerAfterFirstStage,n,a)];
  PowerTable[2] :=  ECMSquare(PowerTable[1],n,a);
  for i in [3..StepSize] do
    PowerTable[i] := ECMProduct
                     (PowerTable[i-2],PowerTable[1],PowerTable[i-1],n);
  od;
  GcdExtCutOffPoint := 500000;
  if Limit2 > GcdExtCutOffPoint then 
    for i in [1..StepSize] do
      p := Gcd(PowerTable[i][2],n); 
      if   p <> 1 
      then return rec(p := p, Stage := "second stage, precomp."); fi;
      PowerTable[i][1] := PowerTable[i][1]/PowerTable[i][2] mod n;
      PowerTable[i][2] := 1;
    od;
  fi;

  DoubleStepSize      := 2 * StepSize;
  DoubleStepSizePower := ECMPower(PowerAfterFirstStage,
                                  DoubleStepSize,n,a);
  StepPower           := ECMPower(PowerAfterFirstStage,
                                  DoubleStepSize + 1,n,a);
  LastStepPower       := PowerAfterFirstStage; 
  StepPos             := 1;
  q                   := 3;
  PrimeDiffPos        := 3;

  while StepPos <= Limit2 - DoubleStepSize do
    
    BufProd := 1; qLimit := StepPos + DoubleStepSize;
    PowerTablePos := (q - StepPos)/2;
    if Limit2 > GcdExtCutOffPoint then
      p := Gcd(StepPower[2],n);
      if   p <> 1 
      then return rec(p := p, Stage := "second stage, precomp."); fi;
      StepPower[1] := StepPower[1]/StepPower[2] mod n;
      StepPower[2] := 1;
    fi;

    while q <= qLimit do
      if   Limit2 > GcdExtCutOffPoint
      then CoordDifference := StepPower[1] - PowerTable[PowerTablePos][1];
      else CoordDifference := (StepPower[1] * PowerTable[PowerTablePos][2]
             - PowerTable[PowerTablePos][1] * StepPower[2]) mod n; 
      fi; 
      BufProd := BufProd * CoordDifference mod n;
      q := q + PrimeDiffs[PrimeDiffPos];
      PowerTablePos := PowerTablePos + PrimeDiffs[PrimeDiffPos]/2;
      PrimeDiffPos := PrimeDiffPos + 1;
    od;

    p := Gcd(BufProd,n);
    if p <> 1 then return rec(p := p, Stage := "second stage"); fi;
    
    StepPowerBuf  := StepPower;
    StepPower     := ECMProduct
                     (LastStepPower,DoubleStepSizePower,StepPower,n);
    LastStepPower := StepPowerBuf;
    StepPos       := StepPos + DoubleStepSize;

  od;

  CurveTime       := Runtime() - CurveStartingTime;
  SecondStageTime := CurveTime - FirstStageTime;
  TotalTime       := Runtime() - StartingTime;
  Fill1 := String("",Maximum(0,LogInt(Maximum(CurveTime,1),10) 
                   - Maximum(3,LogInt(Maximum(FirstStageTime,1),10))));
  Fill2 := String("",Maximum(0,LogInt(Maximum(TotalTime,1),10) 
                   - Maximum(3,LogInt(Maximum(SecondStageTime,1),10))));
  Info(IntegerFactorizationInfo,3,
       "Timings : first stage : ",Fill1,TimeToString(FirstStageTime),
       ", second stage : ",Fill2,TimeToString(SecondStageTime));
  Info(IntegerFactorizationInfo,3,
       "          curve       : ",TimeToString(CurveTime),
       ", total        : ",TimeToString(TotalTime));

  return rec(p := 1, Stage := "none"); 
end;
MakeReadOnlyGlobal("ECMTryCurve");

ECMSplit := function (n,Curve,Curves,Limit1,Limit2,Delta,deterministic,
                      StartingTime)

  local  Sigma,u,v,X,Z,a,a1,a2,p,Result,RangeRatio;

  if IsProbablyPrimeInt(n) then return [n]; fi;

  Info(IntegerFactorizationInfo,2,"ECM for n = ",n);
  Info(IntegerFactorizationInfo,2,"Digits : ",LogInt(n,10) + 1,
                                  ", Curves : ",Curves);
  Info(IntegerFactorizationInfo,2,"Initial Limit1 : ",Limit1,
                                ", Initial Limit2 : ",Limit2,
                                ", Delta : ",Delta);

  RangeRatio := Int(Limit2/Limit1);
  if   deterministic
  then Sigma := 7;
  else Sigma := Random([6..2^28-1]); fi;
  p := 1;

  repeat
    PrettyInfo(2,["Curve no. ",[Curve,6]," (",[Curves,6],")",
                  ", Limit1 : ",[Limit1,7],
                  ", Limit2 : ",[Limit2,8]]);

    if   Limit2 > PrimeDiffLimit
    then InitPrimeDiffs(Maximum(2 * PrimeDiffLimit,Limit2)); fi;

    u  := (Sigma^2 - 5) mod n;
    v  := 4 * Sigma mod n;
    X  := u^3 mod n;
    Z  := v^3 mod n;
    a1 := (v - u)^3 * (3 * u + v) mod n;
    a2 := 4 * X * v mod n;
    a  := QuotientMod(a1,a2,n);
    if a <> fail then a := (a - 2) mod n; 
                 else p := Gcd(a2,n); fi;

    if   p = 1 
    then Result := ECMTryCurve(n,Curve,X,Z,a,Limit1,Limit2,StartingTime);
         p := Result.p;
    fi;

    if not p in [1,n] 
    then Info(IntegerFactorizationInfo,1,LogInt(p,10) + 1,
         "-digit factor ",p," was found in ",Result.Stage); fi;

    Curve  := Curve + 1;
    Limit1 := Limit1 + Delta;
    Limit2 := Limit2 + Delta * RangeRatio;
    Sigma  := Maximum(6,(Sigma^2 + 1) mod n);
  until (Curve > Curves) or not (p in [1,n]);

  if not p in [1,n] then return rec(Curves := Curve - 1, Result := [p,n/p]);
                    else return rec(Curves := Curve - 1, Result := [n]); fi;
end;
MakeReadOnlyGlobal("ECMSplit");

#############################################################################
##
#F  FactorsECM( <n>, [ <Curves>, [ <Limit1>, [ <Limit2>, [ <Delta> ] ] ] ] )
## 
InstallGlobalFunction( FactorsECM,

function ( arg )

  local  n, Curves, Limit1, Limit2, Delta, deterministic, GetArg, ArgCorrect,
         FactorsList, FactorsPool, FailedHere, m, Split, q,
         NumberOfCurves, CurvesTried, i, StartingTime;

  GetArg := function (ArgPos,ArgName,ArgDefault)
    if IsBound(arg[ArgPos]) then 
      if arg[ArgPos] <> fail then return arg[ArgPos];
                             else return ArgDefault; fi; 
    fi;
    if ValueOption(ArgName) <> fail then return ValueOption(ArgName); fi;
    return ArgDefault;
  end;

  StartingTime := Runtime();
  ArgCorrect := Length(arg) in [1..5];
  if ArgCorrect then
    n      := GetArg(1,"DoesNotExist",fail);
    Curves := GetArg(2,"ECMCurves",
                     n -> Maximum(4,3 * RootInt(2^(LogInt(n,10) - 24),8)
                                      + RootInt(2^(LogInt(n,10) - 50),4)));
    if   IsInt(Curves) 
    then NumberOfCurves := Curves; Curves := n -> NumberOfCurves; fi;
    if Curves(n) <= 0 then return [[],[n]]; fi;
    Limit1 := GetArg(3,"ECMLimit1",200);
    Limit2 := GetArg(4,"ECMLimit2",100 * Limit1);
    Delta  := GetArg(5,"ECMDelta",200);
    if not (IsPosInt(n) and IsPosInt(Curves(n)) 
            and IsPosInt(Limit1) and IsPosInt(Limit2) 
            and IsInt(Delta) and Delta >= 0) 
    then ArgCorrect := false; fi;
  fi;
  if not ArgCorrect
  then Error("Usage : FactorsECM( <n>, [ <Curves>, ",
             "[ <Limit1>, [ <Limit2>, [ <Delta> ] ] ] ] ), ",
             "where <n>, <Curves>, <Limit1>, <Limit2> and <Delta> ",
             "have to be positive integers"); fi;
  deterministic := ValueOption("ECMDeterministic");
  if deterministic = fail then deterministic := false; fi;  

  if IsProbablyPrimeInt(n) then return [[n],[]]; fi;

  InitPrimeDiffs(PrimeDiffLimit);

  FactorsList := FactorsTD(n); CurvesTried := 0;
  if FactorsList[2] <> [] then
    m := FactorsList[2][1];
    if   SmallestRootInt(m) < m
    then ApplyFactoringMethod(FactorsPowerCheck,
                              [FactorsECM,"FactorsECM"],
                              FactorsList,infinity);
    else
      FactorsPool    := FactorsList[2]; 
      FactorsList[2] := [];
      FailedHere     := [];
      repeat
        for i in [1..Length(FactorsPool)] do
          m := FactorsPool[i];
          if not (   IsProbablyPrimeInt(m) or m in FailedHere
                  or CurvesTried >= Curves(m)) 
          then
            Split := ECMSplit(m,CurvesTried + 1,Curves(m),
                     Limit1 + CurvesTried * Delta,
                     Limit2 + CurvesTried * Delta * Int(Limit2/Limit1),
                     Delta,deterministic,StartingTime);
            CurvesTried := Split.Curves;
            if   Length(Split.Result) = 1
            then Add(FailedHere,m);
            else FactorsPool[i] := Split.Result; fi;
          fi;
        od;
        FactorsPool := Flat(FactorsPool);
      until ForAll(   FactorsPool,m -> IsProbablyPrimeInt(m)
                   or m in FailedHere
                   or CurvesTried >= Curves(m));
      for q in FactorsPool do if   IsProbablyPrimeInt(q) 
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
#E  ecm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here