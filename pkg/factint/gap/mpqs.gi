#############################################################################
##
#W  mpqs.gi                GAP4 Package `FactInt'                 Stefan Kohl
##
##  This file contains functions for factorization using the
##  Single Large Prime Variation of the
##  Multiple Polynomial Quadratic Sieve (MPQS).
##
##  Argument of FactorsMPQS:
##
##  <n>        the integer to be factored
##
##  The result is returned as a list of the prime factors of <n>.
##
##  A possible improvement would be the implementation of the
##  Double Large Prime Variation of the MPQS (PPMPQS).
##
#############################################################################

MPQSSplit := function (n)

  local Sieve,Pos,x1,x2,Pos1,Pos2,Weight,pi,qi,i,j,pos,zero,one,
        Digits,Multiplier,MultiplierQuality,MultiplierPrimeValues,
        PrimeValue,BestQuality,MaxMultiplier,RangeEnd,Mult,nTimesMult,
        FactorBase,FactorBaseSize,MaxFactorBaseEl,x,CompleteBase,
        SmallPrimeLimit,NrSmallPrimes,SievingPrimePowers,
        NrSievedPowers,piPower,RangeTable,
        a,b,c,aInverse,bmodqi,xabc,PolyCount,
        aOptimum,NraFactors,aFactorsOptimum,MinaFactor,MaxaFactor,
        aFactorsPoolsize,aFactorsPool,aFactorsPoolRoots,
        aFactorsSelectedPositions,aFactorsSelection,HypercubeChunk,
        InitialValue,InitialSieve,SievingIntervalLength,HalfLength,
        SieveBegin,Middle,SieveEnd,LogWeight,LogWeightExpander,
        r,fr,frFact,LargePrimeLimit,LargePrimeLimitWeight,SmallPrimeGap,
        SmallEnough,Tolerance,TriedEntries1,TriedEntries2,
        SmallPrimeContrib,MinSmallPrimeContrib,MinSmallPrimeContribTable,
        Factored,FactoredLarge,LargeFactors,UsableFactors,
        FactoredLargeUsable,RelationsLarge,RelPos,Factorizations,
        Pair1,Pair2,Fact,q,CollectingInterval,NextCollectionAt,
        RelsFB,RelsLarge,RelsTotal,Efficiency1,Efficiency2,
        Progress,Remaining,Required,
        LeftMatrix,RightMatrix,CanonFact,Line,Col,Lines,Cols,
        X,Y,YQuadFactors,FactorsFound,p,DependencyNr,Ready,Result,
        Pause,Resume,StartingTime,UsedTime;

  Pause := function ()  # Put the intermediate results on the options stack
                        # (to be called from the break loop)
    PushOptions(rec(
    MPQSTmp := rec(n                         := n,
                   UsedTime                  := Runtime() - StartingTime,
                   PolyCount                 := PolyCount,
                   aFactorsSelectedPositions := aFactorsSelectedPositions,
                   aFactorsSelection         := aFactorsSelection,
                   a                         := a,
                   aInverse                  := aInverse,
                   TriedEntries1             := TriedEntries1,
                   TriedEntries2             := TriedEntries2,
                   Factored                  := Factored,
                   FactoredLarge             := FactoredLarge,
                   LargeFactors              := LargeFactors,
                   RelationsLarge            := RelationsLarge,
                   NextCollectionAt          := NextCollectionAt)));
  end;

  Resume := function ()  # Resume a previously interrupted computation,
                         # if present
    local  MPQSTmp;

    MPQSTmp := ValueOption("MPQSTmp");
    if MPQSTmp <> fail and MPQSTmp.n = n then
      Info(IntegerFactorizationInfo,2,"");
      Info(IntegerFactorizationInfo,2,
           "Resuming previously interrupted computation");
      StartingTime              := Runtime() - MPQSTmp.UsedTime;
      PolyCount                 := MPQSTmp.PolyCount;
      aFactorsSelectedPositions := MPQSTmp.aFactorsSelectedPositions;
      aFactorsSelection         := MPQSTmp.aFactorsSelection;
      a                         := MPQSTmp.a;
      aInverse                  := MPQSTmp.aInverse;
      TriedEntries1             := MPQSTmp.TriedEntries1;
      TriedEntries2             := MPQSTmp.TriedEntries2;
      Factored                  := MPQSTmp.Factored;
      FactoredLarge             := MPQSTmp.FactoredLarge;
      LargeFactors              := MPQSTmp.LargeFactors;
      RelationsLarge            := MPQSTmp.RelationsLarge;
      NextCollectionAt          := MPQSTmp.NextCollectionAt;
    fi;
  end;

  StartingTime := Runtime();

  Digits := LogInt(n,10) + 1;

  Info(IntegerFactorizationInfo,2,"MPQS for n = ",n);
  PrettyInfo(2,["Digits                     : ",[Digits,10]]);

  zero := Zero(GF(2)); one := One(GF(2));

  # Choose the multiplier

  MultiplierPrimeValues := 
  [[ 3, 75/52,52/25],[ 5, 40/29,99/52],[ 7, 33/25,68/39],[11, 46/37,17/11],
   [13, 67/55,46/31],[17, 13/11,60/43],[19,  7/ 6,15/11],[23, 47/41,67/51],
   [29, 73/65,82/65],[31, 19/17, 5/ 4],[37, 43/39,62/51],[41, 23/21, 6/ 5],
   [43, 12/11,81/68],[47, 89/82,53/45],[53, 83/77,79/68],[59, 15/14,31/27]];
  BestQuality := 0; Multiplier := 1; MaxMultiplier := 1023;
  RangeEnd := MaxMultiplier - MaxMultiplier mod 8 + n mod 8;
  for Mult in [n mod 8,n mod 8 + 8..RangeEnd] do 
    nTimesMult := n * Mult;
    MultiplierQuality := 99/35;
    for PrimeValue in MultiplierPrimeValues do
      if Legendre(nTimesMult,PrimeValue[1]) = 1 then
        if   Mult mod PrimeValue[1] = 0 
        then MultiplierQuality := MultiplierQuality * PrimeValue[2];
        else MultiplierQuality := MultiplierQuality * PrimeValue[3]; fi;
      fi;
    od;
    MultiplierQuality := MultiplierQuality/RootInt(Mult);
    if MultiplierQuality > BestQuality then
      Multiplier  := Mult;
      BestQuality := MultiplierQuality; 
    fi;
  od;
  n := n * Multiplier;

  # Generate the factor base

  FactorBaseSize := QuoInt(Digits^3,100);
  FactorBase := [-1]; pi := 1;
  for i in [2..FactorBaseSize] do
    repeat
      pi := NextPrimeInt(pi);
    until Legendre(n,pi) = 1;
    FactorBase[i] := pi;
  od;

  # Variables used for sieving

  MaxFactorBaseEl    := FactorBase[FactorBaseSize];
  SmallPrimeLimit    := Int(MaxFactorBaseEl/LogInt(MaxFactorBaseEl,2)^2);
  NrSmallPrimes      := Length(Filtered(FactorBase,
                                        pi -> pi < SmallPrimeLimit));
  SievingPrimePowers := Filtered(Flat(List(FactorBase{[2..FactorBaseSize]},
                        pi->List([1..LogInt(MaxFactorBaseEl,pi)],j->pi^j))),
                        piPower -> piPower >= SmallPrimeLimit
                                   and Legendre(n,piPower) = 1);
  NrSievedPowers     := Length(SievingPrimePowers);
  x                  := List(SievingPrimePowers,qi -> RootMod(n,qi));
  LogWeightExpander  := 16;
  LogWeight          := List(SievingPrimePowers,
                             function(qi)
                               pi := SmallestRootInt(qi);
                               if   qi = pi or qi/pi < SmallPrimeLimit 
                               then return LogInt(qi^LogWeightExpander,2);
                               else return LogInt(pi^LogWeightExpander,2); 
                               fi;
                             end);
  SievingIntervalLength := 2^LogInt(QuoInt(Digits^4,32),2); 
  HalfLength            := QuoInt(SievingIntervalLength,2); 
  RangeTable            := List(SievingPrimePowers,
                                qi -> qi * QuoInt(SievingIntervalLength,qi));

  # Parameters used when evaluating the result of the sieving process

  LargePrimeLimit       := RootInt(MaxFactorBaseEl^3);
  LargePrimeLimitWeight := LogInt(LargePrimeLimit^LogWeightExpander,2);
  SmallPrimeGap         := LogInt(LogInt(n,2),2) - 3;
  SmallEnough           := LargePrimeLimitWeight 
                         + LogInt(SmallPrimeLimit^
                                 (SmallPrimeGap * LogWeightExpander),2);
  Tolerance             := 4;

  # Set up the 'pool' of factors for the polynomial coefficient 'a'
  # (used for generating the different polynomials for sieving)

  aOptimum         := QuoInt(RootInt(2 * n),HalfLength);
  NraFactors       := LogInt(aOptimum,2 * MaxFactorBaseEl);
  HypercubeChunk   := 2^(NraFactors - 1);
  aFactorsOptimum  := RootInt(aOptimum,NraFactors);
  MinaFactor       := aFactorsOptimum;
  MaxaFactor       := aFactorsOptimum;
  aFactorsPoolsize := Digits;
  aFactorsPool     := [];
  while Length(aFactorsPool) < aFactorsPoolsize do
    repeat MinaFactor := PrevPrimeInt(MinaFactor); 
    until  Legendre(n,MinaFactor) = 1;
    repeat MaxaFactor := NextPrimeInt(MaxaFactor);
    until  Legendre(n,MaxaFactor) = 1;
    Add(aFactorsPool,MinaFactor);
    Add(aFactorsPool,MaxaFactor);
  od;
  Sort(aFactorsPool); aFactorsPoolsize := Length(aFactorsPool);
  aFactorsPoolRoots := List(aFactorsPool,q->RootMod(n,q));
  aFactorsSelectedPositions := List([1..NraFactors],i->i);
  CompleteBase := Concatenation(FactorBase,aFactorsPool);
  Required := Length(CompleteBase) + 20;

  PrettyInfo(2,["Multiplier                 : ",[Multiplier,10]]);
  PrettyInfo(2,["Size of factor base        : ",[FactorBaseSize,10]]);
  Info(IntegerFactorizationInfo,3,"Factor base : \n",FactorBase,"\n");
  PrettyInfo(2,["Prime powers to be sieved  : ",[NrSievedPowers,10]]);
  PrettyInfo(2,["Length of sieving interval : ",[SievingIntervalLength,10]]);
  PrettyInfo(2,["Small prime limit          : ",[SmallPrimeLimit,10]]);
  PrettyInfo(2,["Large prime limit          : ",[LargePrimeLimit,10]]);
  PrettyInfo(2,["Number of used a-factors   : ",[NraFactors,10]]);
  PrettyInfo(2,["Size of a-factors pool     : ",[aFactorsPoolsize,10]]);
  Info(IntegerFactorizationInfo,3,"a-factors pool :\n",aFactorsPool,"\n");

  # Initialize the sieve
 
  InitialValue := LogInt(Int(n/aOptimum),2) * LogWeightExpander;
  InitialSieve := ListWithIdenticalEntries
                  (SievingIntervalLength + MaxFactorBaseEl,InitialValue);
  MinSmallPrimeContribTable := 
  List([1..InitialValue],i->Int(RootInt(Int(2^(i - LargePrimeLimitWeight)),
                                        LogWeightExpander)/Tolerance));
  Factored := []; 
  LargeFactors := []; FactoredLarge := []; 
  FactoredLargeUsable := []; RelationsLarge := [];
  PolyCount := 0; TriedEntries1 := 0; TriedEntries2 := 0;
  if   FactorBaseSize <  200 then CollectingInterval :=  10;
  elif FactorBaseSize <  500 then CollectingInterval :=  20;
  elif FactorBaseSize < 2000 then CollectingInterval :=  50;
                             else CollectingInterval := 100; fi;
  if   InfoLevel(IntegerFactorizationInfo) = 4 then CollectingInterval := 5;
  elif InfoLevel(IntegerFactorizationInfo) = 5 then CollectingInterval := 1;
  fi;
  NextCollectionAt := CollectingInterval;

  UsedTime := Int((Runtime() - StartingTime)/1000);
  PrettyInfo(2,["Initialization time        : ",[UsedTime,10]," sec."]);

  Resume();  # Check whether there are intermediate results on
             # the options stack for the number to be factored

  # Sieve with different polynomials until there are enough factored fr's

  Info(IntegerFactorizationInfo,2,"");
  Info(IntegerFactorizationInfo,2,"Sieving");

  repeat

    # Choose polynomial and compute roots (mod qi)
    # for all prime powers qi to be sieved

    if PolyCount mod HypercubeChunk = 0 then
      if PolyCount > 0 then
        i := NraFactors;
        while   aFactorsSelectedPositions[i] 
              = aFactorsPoolsize - (NraFactors - i) do i := i - 1; od;
        aFactorsSelectedPositions[i] := aFactorsSelectedPositions[i] + 1;
        for j in [i + 1..NraFactors] do
          aFactorsSelectedPositions[j] := 
          aFactorsSelectedPositions[i] + (j - i);
        od;
      fi;
      aFactorsSelection := List(aFactorsSelectedPositions,
                                pos -> aFactorsPool[pos]);
      a := Product(aFactorsSelection);
      aInverse := List(SievingPrimePowers,qi -> 1/(a mod qi) mod qi);
    fi;
    b := ChineseRem(aFactorsSelection,
                    List([1..NraFactors],
                    i -> (CoefficientsQadic(  PolyCount mod HypercubeChunk 
                                        + 2 * HypercubeChunk,2)[i] * 2 - 1) 
                       * aFactorsPoolRoots[aFactorsSelectedPositions[i]]));
    c := (b^2 - n)/a;
    PolyCount := PolyCount + 1; 
    xabc := [];
    for i in [1..NrSievedPowers] do
      qi      := SievingPrimePowers[i];
      bmodqi  := b mod qi;
      xabc[i] := [(-bmodqi + x[i]) * aInverse[i] mod qi,
                  (-bmodqi - x[i]) * aInverse[i] mod qi];
    od;

    Sieve      := ShallowCopy(InitialSieve);
    Middle     := Int(-b/a);
    SieveBegin := Middle - HalfLength; 
    SieveEnd   := Middle + HalfLength;

    # Do the sieving

    for i in [1..NrSievedPowers] do
      qi := SievingPrimePowers[i]; Weight := LogWeight[i];
      x1 := xabc[i][1]; x2 := xabc[i][2];
      Pos := SieveBegin - SieveBegin mod qi;
      Pos1 := Pos + x1; if Pos1 < SieveBegin then Pos1 := Pos1 + qi; fi;
      Pos2 := Pos + x2; if Pos2 < SieveBegin then Pos2 := Pos2 + qi; fi;
      Pos1 := Pos1 - SieveBegin + 1; Pos2 := Pos2 - SieveBegin + 1;
      ADD_TO_LIST_ENTRIES_PLIST_RANGE
        (Sieve,[Pos1,Pos1 + qi..Pos1 + RangeTable[i]],-Weight);
      if   Pos2 <> Pos1 
      then ADD_TO_LIST_ENTRIES_PLIST_RANGE
             (Sieve,[Pos2,Pos2 + qi..Pos2 + RangeTable[i]],-Weight); fi;
    od;

    # Look for factorizations over the factor base
     
    for Pos in [1..SievingIntervalLength] do
      if Sieve[Pos] <= SmallEnough then
        TriedEntries1 := TriedEntries1 + 1;
        r  := SieveBegin + Pos - 1;
        fr := (a * r^2 + 2 * b * r + c) mod n;
        if fr <> 0 
        then
          if fr > n - fr then fr := fr - n; fi; 
          if fr < 0 then frFact := [-1]; fr := -fr;
                    else frFact := []; 
          fi;
          MinSmallPrimeContrib := 
          MinSmallPrimeContribTable[Maximum(1,Sieve[Pos])];
          SmallPrimeContrib    := 1;
          for i in [2..NrSmallPrimes] do
            while fr mod FactorBase[i] = 0 do
              Add(frFact,FactorBase[i]);
              fr := fr/FactorBase[i];
              SmallPrimeContrib := SmallPrimeContrib * FactorBase[i];
            od;
          od;
          if SmallPrimeContrib >= MinSmallPrimeContrib then
            TriedEntries2 := TriedEntries2 + 1;
            for i in [NrSmallPrimes + 1..FactorBaseSize] do
              while fr mod FactorBase[i] = 0 do
                Add(frFact,FactorBase[i]);
                fr := fr/FactorBase[i];
              od;
            od;
            if fr <= LargePrimeLimit then
              if fr in aFactorsPool then Add(frFact,fr); fr := 1; fi;
              frFact := Concatenation(frFact,aFactorsSelection);
              if fr = 1 then Sort(frFact);
                             Add(Factored,[a * r + b,frFact]);
                        else Add(frFact,fr); Sort(frFact); 
                             Add(FactoredLarge,[a * r + b,frFact]);
                             Add(LargeFactors,fr); 
              fi;  
            fi;
          fi;
        fi;
      fi;      
    od;

    # Look for usable factorizations with a large factor

    if Length(Factored) >= NextCollectionAt then

      Info(IntegerFactorizationInfo,2,"");
      Info(IntegerFactorizationInfo,3,
           "Collecting relations with a large factor");

      Sort(LargeFactors);
      UsableFactors := Set(List(Filtered(Collected(LargeFactors),
                                Pair1->Pair1[2] > 1),Pair2->Pair2[1]));
      FactoredLargeUsable := 
      Filtered(FactoredLarge,
               Fact->ForAll(Fact[2],q ->   q <= MaxFactorBaseEl 
                                        or q in UsableFactors
                                        or q in aFactorsPool));
      Sort(FactoredLargeUsable,
           function(f1,f2)
             return   Intersection(f1[2],UsableFactors)[1]
                    < Intersection(f2[2],UsableFactors)[1];
           end);
      RelationsLarge := []; pos := 1; RelPos := 1;
      while pos < Length(FactoredLargeUsable) do
        if   Intersection(FactoredLargeUsable[pos    ][2],UsableFactors)
           = Intersection(FactoredLargeUsable[pos + 1][2],UsableFactors)
        then
          RelationsLarge[RelPos] := 
          [FactoredLargeUsable[pos][1] * FactoredLargeUsable[pos + 1][1],
           Concatenation(FactoredLargeUsable[pos    ][2],
                         FactoredLargeUsable[pos + 1][2])];
          RelPos := RelPos + 1;
        fi;
        pos := pos + 1;
      od;

      RelsFB      := Length(Factored);
      RelsLarge   := Length(RelationsLarge);
      RelsTotal   := RelsFB + RelsLarge;
      Remaining   := Maximum(0,Required - RelsTotal);
      Efficiency1 := Int(100 * TriedEntries2/TriedEntries1);
      Efficiency2 := Int((100 * (Length(FactoredLarge) + Length(Factored)))/
                        TriedEntries2);
      UsedTime    := Int((Runtime() - StartingTime)/1000);
      Progress    := Minimum(100,Int(100 * RelsTotal/Required));

      PrettyInfo(2,["Complete factorizations over the factor base   : ",
                    [RelsFB,8]]);
      PrettyInfo(2,["Relations with a large prime factor            : ",
                    [RelsLarge,8]]);
      PrettyInfo(2,["Relations remaining to be found                : ",
                    [Remaining,8]]);
      PrettyInfo(2,["Total factorizations with a large prime factor : ",
                    [Length(FactoredLarge),8]]);
      PrettyInfo(2,["Used polynomials                               : ",
                    [PolyCount,8]]);
      PrettyInfo(3,["Efficiency 1                                   : ",
                    [Efficiency1,8]," %"]);
      PrettyInfo(3,["Efficiency 2                                   : ",
                    [Efficiency2,8]," %"]);
      PrettyInfo(2,["Elapsed runtime                                : ",
                    [UsedTime,8]," sec."]);
      PrettyInfo(2,["Progress (relations)                           : ",
                    [Progress,8]," %"]);
      Info(IntegerFactorizationInfo,2,"");
      
      NextCollectionAt := NextCollectionAt + CollectingInterval;

    fi;

  until Length(Factored) + Length(RelationsLarge) >= Required;

  # Create exponent matrix

  Info(IntegerFactorizationInfo,2,"Creating the exponent matrix");
  LeftMatrix := []; Cols := Length(CompleteBase);
  Factorizations := Concatenation(Factored,RelationsLarge);
  Lines := Length(Factorizations);
  for Line in [1..Lines] do
    LeftMatrix [Line] := ListWithIdenticalEntries(Cols,zero);
    CanonFact := Collected(Factorizations[Line][2]);
    for i in [1..Length(CanonFact)] do
      if   CanonFact[i][2] mod 2 = 1 
      then LeftMatrix[Line]
                     [Position(CompleteBase,CanonFact[i][1])] := one;
      fi;
    od;
  od;

  # Do Gaussian Elimination

  Info(IntegerFactorizationInfo,2,
       "Doing Gaussian Elimination, #rows = ",Lines,
       ", #columns = ",Cols);
  RightMatrix := NullspaceMat(LeftMatrix);

  # Calculate X and Y such that X^2 = Y^2 mod n 
  # and check if 1 < Gcd(X - Y,n) < n

  Info(IntegerFactorizationInfo,2,"Processing the zero rows"); 
  p := 1; FactorsFound := []; DependencyNr := 1; Line := 1; Ready := false;

  while Line <= Length(RightMatrix) and not Ready do 

    X := 1; Y := 1;
    for Col in [1..Lines] do 
      if   RightMatrix[Line][Col] = one
      then X := X * Factorizations[Col][1] mod n; fi;
    od;
    YQuadFactors := 
    Collected(Concatenation(List(Filtered([1..Lines],
                                          i->RightMatrix[Line][i] = one),
                                 j->Factorizations[j][2])));
    for i in [1..Length(YQuadFactors)] do
      Y := Y * YQuadFactors[i][1]^(YQuadFactors[i][2]/2) mod n;
    od;
    if  (X^2 - Y^2) mod n <> 0 
    then Error("Internal Error : X^2 - Y^2 mod n <> 0"); fi;

    p := Gcd(X - Y,n/Multiplier);

    if not p in [1,n/Multiplier] 
    then 
      Info(IntegerFactorizationInfo,2,
           "Dependency no. ",DependencyNr," yielded factor ",p); 
      Add(FactorsFound,p); FactorsFound := Set(FactorsFound);
      if FactorsTD(n/Multiplier,FactorsFound)[2] = [] 
      then Ready := true; fi;
    else
      Info(IntegerFactorizationInfo,2,
           "Dependency no. ",DependencyNr," yielded no factor"); 
    fi;

    Line         := Line + 1; 
    DependencyNr := DependencyNr + 1;

  od;
  
  if   FactorsFound = [] 
  then Error("\nSorry, the MPQS has failed ...\n\n"); return [n]; fi;
      
  Result := Flat(FactorsTD(n/Multiplier,FactorsFound));

  Info(IntegerFactorizationInfo,1,"The factors are\n",Result);
  Info(IntegerFactorizationInfo,2,"Digit partition : ",
       List(Result,p -> LogInt(p,10) + 1));
  UsedTime := Runtime() - StartingTime;
  Info(IntegerFactorizationInfo,2,
       "MPQS runtime : ",TimeToString(UsedTime),"\n");

  return Result;
end;
MakeReadOnlyGlobal("MPQSSplit");

#############################################################################
##
#F  FactorsMPQS( <n> )
##
InstallGlobalFunction( FactorsMPQS,

function ( n )

  local  FactorsList, StandardFactorsList, m, Ready, Pos, Passno;

  if   not (IsInt(n) and n > 1)
  then Error("Usage : FactorsMPQS( <n> ), ",
             "where <n> has to be an integer > 1"); fi;

  if   ValueOption("NoPreprocessing") = true 
  then FactorsList := Flat(FactorsTD(n));
  else Info(IntegerFactorizationInfo,2,
            "Doing some preprocessing using Pollard's Rho");
       FactorsList := Flat(FactorsRho(n,1,16,8192)); 
  fi;

  Passno := 0;
  repeat
    Passno := Passno + 1;
    Info(IntegerFactorizationInfo,3,"Pass no. ",Passno);

    StandardFactorsList := [[],[]];
    for m in FactorsList do 
      if IsProbablyPrimeInt(m) then Add(StandardFactorsList[1],m);
                               else Add(StandardFactorsList[2],m); fi;
    od;
    ApplyFactoringMethod(FactorsPowerCheck,[FactorsMPQS,"FactorsMPQS"],
                         StandardFactorsList,infinity);
    FactorsList := Flat(StandardFactorsList);

    for Pos in [1..Length(FactorsList)] do 
      if   not IsProbablyPrimeInt(FactorsList[Pos]) 
      then FactorsList[Pos] := MPQSSplit(FactorsList[Pos]); fi; 
    od;
    FactorsList := Flat(FactorsList);
    Ready := ForAll(FactorsList,IsProbablyPrimeInt);
  until Ready;

  Sort(FactorsList);
  FactorizationCheck(n,FactorsList);
  return FactorsList;
end);

#############################################################################
##
#E  mpqs.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here