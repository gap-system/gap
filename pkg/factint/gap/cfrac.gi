#############################################################################
##
#W  cfrac.gi               GAP4 Package `FactInt'                 Stefan Kohl
##
##  This file contains functions for factorization using the
##  Continued Fraction Algorithm (Brillhard-Morrison Algorithm).
##
##  Argument of FactorsCFRAC:
##
##  <n>        the integer to be factored
##
##  The result is returned as a list of the prime factors of <n>.
##
#############################################################################

CFRACSplit := function (n)

  local Digits,
        Multiplier,FactorBase,FactorBaseSize,MaxFactorBaseEl,pi,sqrt,
        Ai,Bi,Ci,Pi,Aj,Bj,Cj,Pj,Ak,Bk,Ck,Pk,Step,CiBuf,CiFact,
        abort1,abort2,AbortingTime1,AbortingTime2,LargePrimeLimit,
        CollectingInterval,CollectingIntervals,NextCollectionAt,
        Factored,FactoredLarge,LargeFactors,UsableFactors,
        FactoredLargeUsable,RelationsLarge,RelPos,Factorizations,
        RelsFB,RelsLarge,RelsTotal,Progress,Remaining,Required,
        LeftMatrix,RightMatrix,CanonFact,Line,Col,Lines,Cols,
        X,Y,YQuadFactors,FactorsFound,p,DependencyNr,Ready,Result,
        Pair1,Pair2,Fact,q,pos,zero,one,i,j,StartingTime,UsedTime;

  StartingTime := Runtime();

  Digits := LogInt(n,10) + 1;

  Info(IntegerFactorizationInfo,2,"CFRAC for n = ",n);
  Info(IntegerFactorizationInfo,2,"Digits              : ",Digits);

  zero := Zero(GF(2)); one := One(GF(2));
  CollectingIntervals := [1000,2000,5000,10000,20000,50000,100000,200000,
                          500000,1000000];
  CollectingInterval := CollectingIntervals[Minimum(Int(Digits/5),
                                            Length(CollectingIntervals))];
  NextCollectionAt := CollectingInterval;

  # Generate the factor base

  Multiplier := n mod 8; n := n * Multiplier;
  FactorBaseSize := QuoInt(Digits^3,200);
  FactorBase := [-1]; pi := 1;
  for i in [2..FactorBaseSize] do
    repeat
      pi := NextPrimeInt(pi);
    until Legendre(n,pi) = 1;
    FactorBase[i] := pi;
  od;
  MaxFactorBaseEl := FactorBase[FactorBaseSize];
  LargePrimeLimit := MaxFactorBaseEl^2;
  Required        := FactorBaseSize + 20;

  Info(IntegerFactorizationInfo,2,"Size of factor base : ",
                                   FactorBaseSize);
  Info(IntegerFactorizationInfo,3,"\nFactor base : \n",FactorBase,"\n");

  # Some initializations

  Factored := [];
  LargeFactors := []; FactoredLarge := [];
  FactoredLargeUsable := []; RelationsLarge := [];

  sqrt := RootInt(n);

  Aj   := sqrt;
  Bk   := 0; Bj := sqrt;
  Ck   := 1; Cj := n - sqrt^2;
  Pk   := 1; Pj := sqrt;

  Step := 1;

  # Abort Trial Division after dividing Ci by the first <AbortingTime> 
  # primes in the factor base if the the unfactored part after that
  # is larger than <abort>

  abort1        := RootInt(n,12)^5;
  abort2        := RootInt(n,3); 
  AbortingTime1 := Maximum(10,QuoInt(FactorBaseSize,20));
  AbortingTime2 := QuoInt(FactorBaseSize,5);

  # Calculate the continued fraction expansion of the square root of n
  # until there are enough factored Ci's
 
  repeat
    
    # Generate the next set of values of the considered five sequences,
    # especially the next Ci

    Step := Step + 1;
    Ai := QuoInt(sqrt + Bj,Cj);   
    Bi := Ai * Cj - Bj;
    Ci := Ck + Ai * (Bj - Bi);
    Pi := (Pk + Ai * Pj) mod n;

    # Trial divide Ci

    if Step > 100 then
      CiBuf := Ci; 
      if Step mod 2 = 0 then CiFact := [];
                        else CiFact := [-1]; 
      fi;
      for i in [2..AbortingTime1] do
        while CiBuf mod FactorBase[i] = 0 do
          CiBuf := CiBuf/FactorBase[i];
          Add(CiFact,FactorBase[i]);
        od;
      od;
      if CiBuf <= abort1 then
        for i in [AbortingTime1 + 1..AbortingTime2] do
          while CiBuf mod FactorBase[i] = 0 do
            CiBuf := CiBuf/FactorBase[i];
            Add(CiFact,FactorBase[i]);
          od;
        od;
        if CiBuf <= abort2 then
          for i in [AbortingTime2 + 1..FactorBaseSize] do
            while CiBuf mod FactorBase[i] = 0 do
              CiBuf := CiBuf/FactorBase[i];
              Add(CiFact,FactorBase[i]);
            od;
          od;
          if CiBuf < LargePrimeLimit then
            if CiBuf = 1 then
              Add(Factored,[Pi,CiFact]);
            else
              Add(LargeFactors,CiBuf);
              Add(CiFact,CiBuf);
              Add(FactoredLarge,[Pi,CiFact]);
            fi;
          fi;   
        fi;
      fi;
    fi;
    
    # Look for usable factorizations with a large factor

    if Step >= NextCollectionAt
    then

      Info(IntegerFactorizationInfo,3,"");
      Info(IntegerFactorizationInfo,3,
           "Collecting relations with a large factor");

      Sort(LargeFactors);
      UsableFactors := Set(List(Filtered(Collected(LargeFactors),
                                Pair1->Pair1[2] > 1),Pair2->Pair2[1]));
      FactoredLargeUsable := 
      Filtered(FactoredLarge,
               Fact->ForAll(Fact[2],q ->   q <= MaxFactorBaseEl 
                                        or q in UsableFactors));
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

      RelsFB    := Length(Factored);
      RelsLarge := Length(RelationsLarge);
      RelsTotal := RelsFB + RelsLarge;
      Remaining := Maximum(0,Required - RelsTotal);
      UsedTime  := Int((Runtime() - StartingTime)/1000);
      Progress  := Minimum(100,Int(100 * RelsTotal/Required));

      if InfoLevel(IntegerFactorizationInfo) < 3 then
        PrettyInfo(2,["Step ",[Step,9]," : Factored/FB.: ",[RelsFB,4],
                      ", w. Large Fact.: ",[RelsLarge,4],
                      ", Progress :",[Progress,3],"%"]);
      fi;  

      PrettyInfo(3,["Steps                                          : ",
                    [Step,10]]);
      PrettyInfo(3,["Complete factorizations over the factor base   : ",
                    [RelsFB,10]]);
      PrettyInfo(3,["Total factorizations with a large prime factor : ",
                    [Length(FactoredLarge),10]]);
      PrettyInfo(3,["Relations with a large prime factor            : ",
                    [RelsLarge,10]]);
      PrettyInfo(3,["Relations remaining to be found                : ",
                    [Remaining,10]]);
      PrettyInfo(3,["Elapsed runtime                                : ",
                    [UsedTime,10]," sec."]);
      PrettyInfo(3,["Progress (relations)                           : ",
                    [Progress,10]," %"]);
      Info(IntegerFactorizationInfo,3,"");

      NextCollectionAt := NextCollectionAt + CollectingInterval;

    fi;

    Ak := Aj; Bk := Bj; Ck := Cj; Pk := Pj;
    Aj := Ai; Bj := Bi; Cj := Ci; Pj := Pi;   

  until Length(Factored) + Length(RelationsLarge) >= Required;

  # Create exponent matrix

  Info(IntegerFactorizationInfo,2,"Creating the exponent matrix");
  LeftMatrix := []; Cols := FactorBaseSize;
  Factorizations := Concatenation(Factored,RelationsLarge);
  Lines := Length(Factorizations);
  for Line in [1..Lines] do
    LeftMatrix [Line] := ListWithIdenticalEntries(Cols,zero);
    CanonFact := Collected(Factorizations[Line][2]);
    for i in [1..Length(CanonFact)] do
      if   CanonFact[i][2] mod 2 = 1 
      then LeftMatrix[Line]
                     [Position(FactorBase,CanonFact[i][1])] := one;
      fi;
    od;
  od;

  # Do Gaussian Elimination

  Info(IntegerFactorizationInfo,2,
       "Doing Gaussian Elimination, #rows = ",Lines,
       ", #columns = ",Cols);
  RightMatrix := NullspaceMat(LeftMatrix);

  # Calculate X and Y such that X^2 = Y^2 mod n 
  # and check if 1 < gcd(X - Y,n) < n

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
  then Error("\nSorry, CFRAC has failed ...\n",
             "Perhaps the continued fraction expansion of the square\n",
             "root of the number you attempted to factor has properties\n",
             "disadvantageous for obtaining a factorization\n",
             "with this algorithm, try using the MPQS\n\n"); return [n]; fi;
      
  Result := Flat(FactorsTD(n/Multiplier,FactorsFound));

  Info(IntegerFactorizationInfo,1,"The factors are\n",Result);
  Info(IntegerFactorizationInfo,2,"Digit partition : ",
       List(Result,p -> LogInt(p,10) + 1));
  UsedTime := Runtime() - StartingTime;
  Info(IntegerFactorizationInfo,2,
       "CFRAC runtime : ",TimeToString(UsedTime),"\n");

  return Result;
end;
MakeReadOnlyGlobal("CFRACSplit");

#############################################################################
##
#F  FactorsCFRAC( <n>, [ <ContinueFromFile>, <PagingDir> ] )
##
InstallGlobalFunction( FactorsCFRAC,

function ( n )

  local  FactorsList, StandardFactorsList, m,
         Ready, Pos, Passno;

  if   not (IsInt(n) and n > 1)
  then Error("Usage : FactorsCFRAC( <n> ), ",
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
    ApplyFactoringMethod(FactorsPowerCheck,[FactorsCFRAC,"FactorsCFRAC"],
                         StandardFactorsList,infinity);
    FactorsList := Flat(StandardFactorsList);

    for Pos in [1..Length(FactorsList)] do 
      if   not IsProbablyPrimeInt(FactorsList[Pos]) 
      then FactorsList[Pos] := CFRACSplit(FactorsList[Pos]); fi;
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
#E  cfrac.gi . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here