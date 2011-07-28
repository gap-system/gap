#############################################################################
##
#W  general.gi              GAP4 Package `FactInt'                Stefan Kohl
##                                                               Frank Lübeck
##
##  This file contains the general routines for integer factorization and
##  auxiliary functions used by them and/or more than one of the 
##  functions for the specific factorization methods implemented in
##  pminus1.gi (Pollard's p-1), pplus1.gi (Williams' p+1), ecm.gi 
##  (Elliptic Curves Method, ECM), cfrac.gi (Continued Fraction Algorithm,
##  CFRAC) and mpqs.gi (Multiple Polynomial Quadratic Sieve, MPQS).
##
##  The argument <n> is always the number to be factored.
## 
##  Descriptions of the algorithms can be found in
##
##  David M. Bressoud: Factorization and Primality Testing, Springer 1989
##
##  A (brief) description of the factoring algorithms can also be found in
##
##  Henri Cohen: A Course in Computational Algebraic Number Theory,
##  Springer 1993
##
##  In the last book, there is also a (very short) description of the
##  Generalized Number Field Sieve (GNFS), which is the asymptotically
##  most efficient factoring method known today. The GNFS is not
##  implemented in this package, because the MPQS is usually faster for
##  numbers less than about 10^100.
##  Factoring ``difficult'' numbers of this order of magnitude is far
##  beyond the scope in this context.
##
#############################################################################

if not IsBound(CommandLineHistory) then CommandLineHistory := fail; fi;

InstallGlobalFunction( FactIntInfo,
                       function( lev ) 
                         SetInfoLevel(IntegerFactorizationInfo,lev); 
                       end );


# For pretty-printing info messages

PrettyInfo := function (lev,Args)

  local InfoString,Arg;
  
  InfoString := "";
  for Arg in Args do
    if   IsString(Arg) 
    then Append(InfoString,Arg);
    else Append(InfoString,String(Arg[1],Arg[2]));
    fi;
  od;
  Info(IntegerFactorizationInfo,lev,InfoString);
end;
MakeReadOnlyGlobal("PrettyInfo");


# For converting a time in ms as given by Runtime() to a
# printable string

TimeToString := function (Time)

  return Concatenation(String(Int(Time/1000)),".",
                       String(Time mod 1000 + 1000){[2..4]}," sec.");
end;
MakeReadOnlyGlobal("TimeToString");


# For checking the results of all the factorization routines

FactorizationCheck := function (n,Result)

  local  ResultCorrect;

  if IsList(Result[1])
  then ResultCorrect :=     Product(Flat(Result)) = n 
                        and ForAll(Result[1],IsProbablyPrimeInt)
                        and not ForAny(Result[2],IsProbablyPrimeInt);
  else ResultCorrect :=     Product(Result) = n
                        and ForAll(Result,IsProbablyPrimeInt);
  fi;
  if not ResultCorrect
  then Error("\nInternal error, the result is incorrect !!!\n\n",
             "Please send e-mail to the author\n",
             "(kohl@mathematik.uni-stuttgart.de)\n",
             "and mention the number to be factored : \n",n,
             "\nas well as the options you specified, ",
             "thank you very much.\n"); 
  fi;
end;
MakeReadOnlyGlobal("FactorizationCheck");


# Initialize the factorization caches

BindGlobal("FACTINT_SMALLINTCACHE_LIMIT",64);
BindGlobal("FACTINT_SMALLINTCACHE",List([1..64],FactorsInt));
BindGlobal("FACTINT_SMALLINTCOUNT",0);
BindGlobal("FACTINT_SMALLINTCOUNT_THRESHOLD",2187);
BindGlobal("FACTINT_CACHE",[]);
BindGlobal("FACTINT_FACTORS_CACHE",[]);


# For writing the temporary factorization data of the MPQS
# (relations over the factor base etc.) to a file which can
# be read using the `Read'-function

SaveMPQSTmp := function (TempFile)

  local  MPQSTmp;

  MPQSTmp := ValueOption("MPQSTmp");
  PrintTo(TempFile,
          "PushOptions(rec(MPQSTmp :=\n",MPQSTmp,"));\n");
end;
MakeReadOnlyGlobal("SaveMPQSTmp");


# Initialize the prime differences list
# (used by ECM, Pollard's p-1 and Williams' p+1 for second stages)

BindGlobal("PrimeDiffs",[]);
BindGlobal("PrimeDiffLimit",1000000);

InitPrimeDiffs := function ( Limit )

  local  Sieve, SieveSegment, ChunkSize, p, Maxp, pos, incr,
         zero, one;

  if Limit <= PrimeDiffLimit and PrimeDiffs <> [] 
  then return; fi;
  Limit := Maximum(Limit,PrimeDiffLimit);
  ChunkSize := 100000;
  if   Limit mod ChunkSize <> 0
  then Limit := Limit + ChunkSize - Limit mod ChunkSize; fi;
  Info(IntegerFactorizationInfo,2,
       "Initializing prime differences list, ",
       "PrimeDiffLimit = ",Limit);
  MakeReadWriteGlobal("PrimeDiffLimit");
  PrimeDiffLimit := Limit;
  MakeReadOnlyGlobal("PrimeDiffLimit");

  zero := Zero(GF(2)); one := One(GF(2));
  SieveSegment := ListWithIdenticalEntries(ChunkSize,zero);
  ConvertToGF2VectorRep(SieveSegment);
  Sieve := Concatenation(List([1..Limit/ChunkSize],i->SieveSegment));
  Sieve[1] := one;
  Maxp := RootInt(PrimeDiffLimit); p := 2;
  while p <= Maxp do
    pos := 2 * p;
    while pos <= PrimeDiffLimit do
      Sieve[pos] := one;
      pos := pos + p;
    od;
    p := NextPrimeInt(p);  
  od;
  MakeReadWriteGlobal("PrimeDiffs");
  PrimeDiffs := [2,1];
  incr := 0;
  for pos in [4..PrimeDiffLimit] do
    incr := incr + 1;
    if Sieve[pos] = zero then
      Add(PrimeDiffs,incr);
      incr := 0;
    fi;
  od;
  MakeReadOnlyGlobal("PrimeDiffs");
end;
MakeReadOnlyGlobal("InitPrimeDiffs");


# BRENTFACTORS is a list of lists. If there is an entry in position [a][n]
# then this is a list of primes which divide b^k - 1 but no b^l - 1 with 
# l < k.
#  
# BRENTFACTORSAVAILABLE is a binary list (blist) whose entry [b] is 'true'
# when there are data available for BRENTFACTORS[b]. (They are only loaded 
# when they are needed.)
#
# The source for the data is
#
# http://wwwmaths.anu.edu.au/~brent/ftp/factors/factors.gz.
#
# The code for accessing these factorization tables has been contributed
# by Frank Lübeck.

BindGlobal("BRENTFACTORS", []);
BindGlobal("BRENTFACTORSAVAILABLE", BlistStringDecode(
"6E7EFF5EEFFF7FFEFFFF7FFFEFFFFF76FFFEFFFFFF7FFFFFEFFFFEFF7FFFDFFEFFFFFFFF7FFFF\
FFFEFFFFDFFFF7FFFFFFFFEFFFFFFFFFF7FFFFFFFFFEFFFFFFEFFFF7FFFFFFFFFFEFFFFFFFFFFF\
F7FFFFFFFFFFFEFFFFFFFFFFFFF7FFFFFFFFFFFFEFFFFFFFFFFFFFF7FFFFFFFFFFFFFEFFFFFFFF\
FFFFFFF7FFFFFFFFE55DD6C77CF55F55F4945577DD35D5B71D515578531615D75D98889820A080\
18DA2002A20A09E200292000100A0A20808000200A00628821238240200A288200200282242088\
20221220009828828240A00008228000008A00800A008082082100082380080200202000200082\
28A00800820800029000A10000820208A20208028020008020800A280A0028000A08A00A080002\
00000220808000A30200028808208810A00000828220808208A088200208200088200202088000\
01200008024228A08000020028000808800800200A20208228821229240A00808800200800A08A\
00020008820208800020200820808020020008820A000000280202200088080082002208000080\
28009800004228008220020809808000028A00240000028208220A04220029028000A000308800\
08000808A28000020200208028828200A80200A00A102088202082000220288002088080202082\
00000C28022008820000A00801228020008808000224A20A00220000200000804A24828200000A\
08000828028200200428820008A00008000008020A00A00A00828028020808000000200A008082\
00800020800800A00008220820000A00800208A20000028008200020209200008000A20A082008\
22020020000A088400202000002288280088002000000080208008012080200288202080288002\
08220A00A000200202000088200282082000000208002202008080080002288000008008280008\
20800200A00220000000820820208A00208A08000020A20000A200282200000082088080200000\
00200028228A00800208808020800008A08000001220200820808200220A288280280008200002\
20020008000000820000220000808220800208210A00800808028020200200800000A202088080\
00200820A08020028020820808200828208200809000008200000A000088080200000008080002\
28020A08800020200200008000828008200A00A08021008800000A000280280200002288080008\
20A002000202208000000280282208202088008202002200180080200000208008280000202000\
08020800228200808220800000020008028008028000A00008000008000208000800020A000088\
28020200820808828028008820A00220008000220800008808220220008220009008A000000088\
00000820800800800208A20000820020208800A00200000008000A080000200082008008288080\
208200000200082202002000080280288200002088002288002080080000080208080280000002\
20A00220009200000000800808200A20000200808000A008002280082000208088088202082002\
08820808000220000220028021A00800A20000208000000208808020020A00000028228000800A\
08020200000200208000208800208800808200220810820028000800008A00800020220008A080\
00020800208200828028A00000A20820020800200800820220000000020009008220A002080080\
00A00808000028008220800028008220020208008820020A0020022000820B820A008080002080\
00004"));

BindGlobal( "WriteBrentFactorsFiles",

  function ( dir )

    local  bf, i;

    if not IsDirectory(dir) then dir := Directory(dir); fi;
    bf := BRENTFACTORS;
    for i in [1..Length(bf)] do 
      if IsBound(bf[i]) then 
        PrintTo(Filename(dir, Concatenation("brfac", String(i))),
                "BRENTFACTORS[",i,"]:=", bf[i], ";\n"); 
      fi;
    od;
  end );

#############################################################################
##
#F  FetchBrentFactors( ) . . get Brent's tables of factors of numbers b^k - 1
##
InstallGlobalFunction( "FetchBrentFactors",

  function ( )

    local  str, get, comm, rows, b, k, a, dir;

    # Fetch the file from R. P. Brent's ftp site and gunzip it into 'str'.

    str := "";
    get := OutputTextString(str, false);
    comm := Concatenation("wget -q http://wwwmaths.anu.edu.au/~brent/ftp/",
                          "factors/factors.gz -O - | gzip -dc ");
    Process(DirectoryCurrent(), Filename(DirectoriesSystemPrograms(),"sh"),
            InputTextUser(), get, ["-c", comm]);
  
    rows := SplitString(str, "", "\n");
    str := 0;
    for a in rows do 
      b := List(SplitString(a, "", "+- \n"), Int);
      if not IsBound(BRENTFACTORS[b[1]]) then
        BRENTFACTORS[b[1]] := [];
      fi;
      if '-' in a then
        k := b[2];
      else
        k := 2*b[2];
      fi;
      if not IsBound(BRENTFACTORS[b[1]][k]) then
        BRENTFACTORS[b[1]][k] := [b[3]];
      else
        Add(BRENTFACTORS[b[1]][k], b[3]);
      fi;
    od;
    dir := GAPInfo.PackagesInfo.("factint")[1].InstallationPath;
    WriteBrentFactorsFiles(Concatenation(dir,"/tables/brent/"));
  end );


# Grab factors with at least <mindigits> decimal digits from <file>.
# Optionally exclude rightmost (largest?) factor.

GrabFactors := function ( file, mindigits, excludelast )

  local  nums, num, lines, line, nondigits;

  lines     := SplitString(ReadAll(InputTextFile(file)),"\n","\n");
  nondigits := Difference(List([0..255],CHAR_INT),"0123456789");
  nums  := [];
  for line in lines do
    num := List(SplitString(line,nondigits,nondigits),Int);
    if IsEmpty(num) then continue; fi;
    if excludelast then Unbind(num[Length(num)]); fi;
    num := Filtered(num,n->LogInt(n,10)>=mindigits-1);
    num := Filtered(num,IsProbablyPrimeInt);
    nums := Concatenation(nums,num);
  od;
  return Set(nums);  
end;
MakeReadOnlyGlobal("GrabFactors");

# Remove redundancies from a list <facts> of factors of numbers <f>(k)
# for 1 <= k <= <max_k>, under the assumption that a|b implies f(a)|f(b).

CleanedFactorsList := function ( facts, f, max_k )

  local  result, smldivpos, val, i;

  val := List([1..max_k],f);
  smldivpos := List(facts,p->First([1..max_k],k->val[k] mod p = 0));
  result := List([1..max_k],k->facts{Filtered([1..Length(smldivpos)],
                                              i->smldivpos[i]=k)});;
  for i in [1..Length(result)] do
    if result[i] <> [] then Unbind(result[i][Length(result[i])]); fi;
  od;
  return Set(Flat(result));
end;
MakeReadOnlyGlobal("CleanedFactorsList");


# Apply a factoring method to the composite factors of a partial
# factorization and give information about it

ApplyFactoringMethod := function (arg)

  local  FactoringMethod,Parameters,FactList,Bound,
         InfoArgs,InfoArgsTmp,InfoBaseString,InfoString,Display_n,
         Unfactored,n,Arguments,Temp,l;

  FactoringMethod := arg[1];
  Parameters      := arg[2];
  FactList        := arg[3];
  Bound           := arg[4];
  if FactList[2] = [] then return; fi;
  Display_n := false;
  if IsBound(arg[5]) then
    InfoArgs := arg[5];
    l := Length(InfoArgs);
    Display_n := InfoArgs[l] = "n";
    if Display_n then Unbind(InfoArgs[l]); fi;
    InfoArgsTmp := List(InfoArgs,function(Arg) 
                                   if IsFunction(Arg) or Arg = fail
                                   then return "<func.>";
                                   else return Arg; fi;
                                 end);
    InfoBaseString := Concatenation(List(InfoArgsTmp,elt->String(elt))); 
    if not Display_n 
    then Info(IntegerFactorizationInfo,2,"");
         Info(IntegerFactorizationInfo,1,InfoBaseString); fi;
  fi;
  Unfactored := ShallowCopy(FactList[2]);
  FactList[2] := [];
  for n in Unfactored do
    if n < Bound then
      if Display_n then 
        if   Length(InfoBaseString) 
           + LogInt(n,10) + 1 >= SizeScreen()[1]
        then InfoString := Concatenation(InfoBaseString,"\n");
        else InfoString := InfoBaseString; fi;
        Info(IntegerFactorizationInfo,2,"");
        Info(IntegerFactorizationInfo,1,
             Concatenation(InfoString,String(n)));
      fi;
      Arguments := [n];
      Append(Arguments,Parameters);
      Temp := CallFuncList(FactoringMethod,Arguments);
      if not IsList(Temp[1]) then Temp := [Temp,[]]; fi;
      if Temp[1] <> [] then
      Info(IntegerFactorizationInfo,1,"Intermediate result : ",Temp); fi;
      Append(FactList[1],Temp[1]); Sort(FactList[1]);
      Append(FactList[2],Temp[2]); Sort(FactList[2]);
    else Add(FactList[2],n);
    fi;
  od;
end;
MakeReadOnlyGlobal("ApplyFactoringMethod");


#############################################################################
##
#F  FactorsTD( <n> [, <Divisors> ] ) . . . . . . . . . . . . . Trial Division
##
InstallGlobalFunction( FactorsTD,

function ( arg )

  local n, p, Result, DivisorsList;

  if arg[1] =  1 then return [[  ],[]]; fi;
  if arg[1] = -1 then return [[-1],[]]; fi;

  n := AbsInt(arg[1]);
  if IsBound(arg[2]) then DivisorsList := arg[2];
                     else DivisorsList := Primes; fi;
  Result := [[],[]];
  for p in DivisorsList do
    while n mod p = 0 do 
      if IsProbablyPrimeInt(p) then Add(Result[1],p); 
                               else Add(Result[2],p); fi;
      n := n/p;
      if IsProbablyPrimeInt(n) then Add(Result[1],n); n := 1; fi;
    od;
    if n = 1 then break; fi;
  od;
  if   IsProbablyPrimeInt(n) then Add(Result[1],n);
  elif n > 1                 then Add(Result[2],n); fi;

  if   Length(Result[1]) >= 1
  then Result[1][1] := Result[1][1]*SignInt(arg[1]);
  else Result[2][1] := Result[2][1]*SignInt(arg[1]); fi;

  return Result;
end );

FactorsTDNC := function ( n )

  local  Result, p;

  if n > 0 then
    Result := [[],[]];
    for p in Primes do
      while n mod p = 0 do 
        Add(Result[1],p); 
        n := n/p;
      od;
      if n = 1 then return Result; fi;
    od;
    if n < 1000000 then Add(Result[1],n);
                   else Add(Result[2],n); fi;   
  else
    Result := FactorsTDNC(-n);
    if   Result[1] <> []
    then Result[1][1] := -Result[1][1];
    else Result[2][1] := -Result[2][1]; fi;
  fi;
  return Result;
end;
MakeReadOnlyGlobal("FactorsTDNC");

# Initialize some lists of trial divisors

BindGlobal("K_FACTORIAL_M1_FACTORS",[]);
BindGlobal("K_FACTORIAL_P1_FACTORS",[]);
BindGlobal("K_PRIMORIAL_M1_FACTORS",[]);
BindGlobal("K_PRIMORIAL_P1_FACTORS",[]);
BindGlobal("FACTORS_FIB",[]);
BindGlobal("FIB_RES", # Fib(k) mod 13, 21, 34, 55, 89, 144.
[ [ 0, 1, 2, 3, 5, 8, 10, 11, 12 ], [ 0, 1, 2, 3, 5, 8, 13, 18, 20 ],
  [ 0, 1, 2, 3, 5, 8, 13, 21, 26, 29, 31, 32, 33 ],
  [ 0, 1, 2, 3, 5, 8, 13, 21, 34, 47, 52, 54 ],
  [ 0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 68, 76, 81, 84, 86, 87, 88 ],
  [ 0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 123, 136, 141, 143 ] ]);
BindGlobal("POW3_M_POW2_FACTORS",[]);
BindGlobal("AK_PM_BK_MOD_2520",[]);


# Treat values of functions f such that a|b implies f(a)|f(b)
# (f is assumed to be strictly growing)

FactorsMultFunc := function ( n, f )

  local  val, fact, k, step, fk, gcd, i;

  if IsProbablyPrimeInt(n) then return [[n],[]]; fi;
  k := 1;
  repeat k := 2*k; until f(k) >= n;
  step := k/4;
  while f(k) <> n and IsInt(step) do
    if f(k) > n then k := k - step; else k := k + step; fi;
    step := step/2;
  od;
  if f(k) <> n then return [[],[n]]; fi;
  val := List(DivisorsInt(k),f);
  fact := [n];
  for fk in val do
    for i in [1..Length(fact)] do
      gcd := Gcd(fact[i],fk);
      if not gcd in [1,fact[i]] then fact[i] := [gcd,fact[i]/gcd]; fi;
    od;
    fact := Flat(fact);
  od;
  return [Filtered(fact,IsProbablyPrimeInt),
          Filtered(fact,q->not IsProbablyPrimeInt(q))];
end;
MakeReadOnlyGlobal("FactorsMultFunc");


# Power Check

FactorsPowerCheck := function (n,SplittingFunction,SplittingFunctionName)

  local  m,k,FactorsOfm,factors;

  m := SmallestRootInt(n); 
  k := LogInt(n,m);
  if m < n 
  then Info(IntegerFactorizationInfo,1,n," = ",m,"^",k); fi;
  if IsProbablyPrimeInt(m) 
  then return [ListWithIdenticalEntries(k,m),[]];
  elif m = n then return [[],[n]]; 
  else 
    FactorsOfm := [[],[m]];
    ApplyFactoringMethod(SplittingFunction,[],FactorsOfm,infinity,
                         [SplittingFunctionName,
                          ", Number to be factored : ","n"]);
    factors := [Concatenation(ListWithIdenticalEntries(k,FactorsOfm[1])),
                Concatenation(ListWithIdenticalEntries(k,FactorsOfm[2]))];
    Sort(factors[1]); Sort(factors[2]);
    return factors;
  fi;
end;
MakeReadOnlyGlobal("FactorsPowerCheck");


# Check for a decomposition n = p*q such that p/q is close
# to a fraction with small numerator and denominator.

FactorsFermat := function ( n, maxmult, steps )

  local  a, b, a2, b2, d, mult,
         steps1, steps2, facts, result;

  a := RootInt(n,2); a2 := a^2;
  d := 2*a + 1; b := 0; mult := 0;
  steps1 := steps + 1;
  repeat
    if steps1 > steps then
      if mult > 0 then n := n/mult; fi;
      mult := mult + 1; steps1 := 0; steps2 := 0;
      if mult > maxmult then return [ [  ], [ n ] ]; fi;
      n := n * mult;
      a := RootInt(n,2); a2 := a^2; d := 2*a + 1; b := 0;
    fi;
    a      := a + 1;
    a2     := a2 + d;
    d      := d + 2;
    b2     := a2 - n;
    steps1 := steps1 + 1;
    if   not b2 mod 64 in [ 0, 1, 4, 9, 16, 17, 25, 33, 36, 41, 49, 57 ]
      or not b2 mod 45 in [ 0, 1, 4, 9, 10, 16, 19, 25, 31, 34, 36, 40 ]
      or not b2 mod  7 in [ 0, 1, 2, 4 ]
      or not b2 mod 11 in [ 0, 1, 3, 4, 5, 9 ]
    then continue; fi;
    b      := RootInt(b2,2);
    steps2 := steps2 + 1;
  until b^2 = b2;
  b := RootInt(b2,2);
  Info(InfoFactInt,2,"FactorsFermat: Multiplier = ",mult,
                     ", #Steps = ",steps1," / ", steps2);
  result := []; n := n/mult;
  facts := List([a-b,a+b],m->m/Gcd(m,mult));
  result[1] := Filtered(facts,IsProbablyPrimeInt);
  result[2] := Difference(facts,result[1]);
  if Product(Flat(result)) <> n then
    result[1] := AsSortedList(Concatenation(result[1],
                              Factors(n/Product(Flat(result)))));
  fi;
  return result;
end;
MakeReadOnlyGlobal("FactorsFermat");


# Check for n = b^k +/- 1

FactorsAurifeuillian := function ( n )

  local b, k, s, FactorsOfP, PolyFactors, factors, c, m, j, p, a;

  for c  in [ -1, 1 ]  do
    b := SmallestRootInt( n - c );
    if b < n - c  then
      k := LogInt( n - c, b );
      if c = -1  then
        s := " - 1";
      else
        s := " + 1";
      fi;
      Info( IntegerFactorizationInfo, 1, n, " = ", b, "^", k, s);
      if c = -1 then
        FactorsOfP := DivisorsInt(k);
      else
        FactorsOfP := Difference(DivisorsInt(2*k), DivisorsInt(k));
      fi;
      PolyFactors := List(FactorsOfP,
                          i -> ValuePol(CyclotomicPol(i), b));
      Info( IntegerFactorizationInfo, 1,
            "The factors corresponding to ", "polynomial factors are\n",
            PolyFactors );
      factors := [ [  ], [  ] ];
      for j in [1..Length(FactorsOfP)] do
        a := PolyFactors[j];
        if b <= Length(BRENTFACTORSAVAILABLE)
          and not IsBound(BRENTFACTORS[b]) and BRENTFACTORSAVAILABLE[b]
        then
          ReadPackage("factint",
                      Concatenation("tables/brent/brfac",String(b)));
        fi;
        if b <= Length(BRENTFACTORSAVAILABLE)
          and IsBound(BRENTFACTORS[b])
          and IsBound(BRENTFACTORS[b][FactorsOfP[j]])
        then
          for p in BRENTFACTORS[b][FactorsOfP[j]] do
            while a mod p = 0 do
              Add(factors[1],p);
              a := a/p;
            od;
          od;
        fi;
        if IsProbablyPrimeInt(a) then
          Add(factors[1], a);
        else
          Add(factors[2], a);
        fi;
      od;
      return factors;
    fi;
  od;
  return [ [  ], [ n ] ];
end;
MakeReadOnlyGlobal("FactorsAurifeuillian");


#############################################################################
##
#F  FactInt( <n> ) . . . . . . . . . . prime factorization of the integer <n>
#F                                                      (partial or complete)
##
InstallGlobalFunction( FactInt,

function ( n )

  local  TDHints, RhoSteps, RhoCluster,
         Pminus1Limit1, Pminus1Limit2,
         Pplus1Residues, Pplus1Limit1, Pplus1Limit2,
         ECMCurves, ECMLimit1, ECMLimit2, ECMDelta,
         Cheap, FactIntPartial, FBMethod, CFRACLimit, MPQSLimit,
         IsNonnegInt, StateInfo, LastMentioned,
         FactorizationObtainedSoFar, Result, sign,
         CFRACBound, MPQSBound, StartingTime, UsedTime,
         fib_res, a, b, nmod2520, NonDigits, CmdLineFacts;

  IsNonnegInt := n->(IsInt(n) and n >= 0);

  StateInfo := function ()
    if FactorizationObtainedSoFar[2] <> [] 
      and not (    IsBound(LastMentioned) 
               and FactorizationObtainedSoFar[1] = LastMentioned) 
    then
      Info(IntegerFactorizationInfo,2,"");
      Info(IntegerFactorizationInfo,1,
           "Factors already found : ",FactorizationObtainedSoFar[1]);
      Info(IntegerFactorizationInfo,1,"");
      LastMentioned := ShallowCopy(FactorizationObtainedSoFar[1]);
    fi;
  end;

  if  not IsInt(n)
  then Error("Usage : FactInt( <n> ), for an integer <n>"); fi;

  if AbsInt(n) < 10^12 then
    Info(IntegerFactorizationInfo,3," | ",n," | ",
         "< 10^12, so use GAP Library function `FactorsInt'");
    return [FactorsInt(n),[]];
  fi;

  StartingTime := Runtime();

  # Get options / set default values

  TDHints := ValueOption("TDHints");
  if not IsList(TDHints) or not ForAll(TDHints,IsPosInt) 
  then TDHints := []; fi;
  RhoSteps := ValueOption("RhoSteps"); 
  if not IsNonnegInt(RhoSteps) then RhoSteps := 16384; fi;
  RhoCluster := ValueOption("RhoCluster"); 
  if not IsPosInt(RhoCluster) 
  then RhoCluster := Maximum(Minimum(Int(LogInt(AbsInt(n),2)^2/100),
                                     Int(RhoSteps/10)),16); fi;
  Pminus1Limit1 := ValueOption("Pminus1Limit1");
  if not IsNonnegInt(Pminus1Limit1) then Pminus1Limit1 := 10000; fi;
  Pminus1Limit2 := ValueOption("Pminus1Limit2");
  if not IsNonnegInt(Pminus1Limit2) 
  then Pminus1Limit2 := 40 * Pminus1Limit1; fi;
  Pplus1Residues := ValueOption("Pplus1Residues");
  if not IsNonnegInt(Pplus1Residues) then Pplus1Residues := 2; fi;
  Pplus1Limit1 := ValueOption("Pplus1Limit1");
  if not IsNonnegInt(Pplus1Limit1) then Pplus1Limit1 := 2000; fi;
  Pplus1Limit2 := ValueOption("Pplus1Limit2");
  if not IsNonnegInt(Pplus1Limit2) 
  then Pplus1Limit2 := 40 * Pplus1Limit1; fi;
  ECMCurves := ValueOption("ECMCurves");
  ECMLimit1 := ValueOption("ECMLimit1");
  ECMLimit2 := ValueOption("ECMLimit2");
  ECMDelta  := ValueOption("ECMDelta");
  FactIntPartial := ValueOption("FactIntPartial");
  if not IsBool(FactIntPartial) or FactIntPartial = fail 
  then FactIntPartial := false; fi;
  FBMethod := ValueOption("FBMethod");
  if not IsString(FBMethod) or not FBMethod in ["MPQS","CFRAC"]
  then FBMethod := "MPQS"; fi;
  CFRACLimit := ValueOption("CFRACLimit");
  if not IsPosInt(CFRACLimit) then CFRACLimit := 40; fi;
  MPQSLimit := ValueOption("MPQSLimit");
  if not IsPosInt(MPQSLimit) then MPQSLimit := 40; fi;

  Cheap := ValueOption("cheap");
  if Cheap = true then
    Pminus1Limit1  := 0;
    Pplus1Limit1   := 0;
    ECMCurves      := 0;
    CFRACLimit     := 0;
    MPQSLimit      := 0;
    FactIntPartial := true;
  else Cheap := false; fi;

  if n < 0  then sign := -1; else sign := 1; fi;    
  n := AbsInt(n);

  FactorizationObtainedSoFar := [[],[n]];

  # First of all, check whether n = b^k +/- 1 for some b, k

  ApplyFactoringMethod(FactorsAurifeuillian,[],
                       FactorizationObtainedSoFar,infinity,
                       ["Check for n = b^k +/- 1"]);
  StateInfo();

  # Special case k! +/- 1

  if n mod 620448401733239439360000 in [1,620448401733239439359999] then
    if   IsEmpty(K_FACTORIAL_M1_FACTORS)
    then ReadPackage("factint","tables/factorial.g"); fi;
    if n mod 6 = 1 then
      ApplyFactoringMethod(FactorsTD,[K_FACTORIAL_P1_FACTORS],
                           FactorizationObtainedSoFar,infinity,
                           ["Trial division by factors of k!+1"]);
    else
      ApplyFactoringMethod(FactorsTD,[K_FACTORIAL_M1_FACTORS],
                           FactorizationObtainedSoFar,infinity,
                           ["Trial division by factors of k!-1"]);
    fi;
    StateInfo();
  fi;

  # Special case Primorial(k) +/- 1

  if n mod 32589158477190044730 in [1,32589158477190044729] then
    if   IsEmpty(K_PRIMORIAL_M1_FACTORS)
    then ReadPackage("factint","tables/primorial.g"); fi;
    if n mod 6 = 1 then
      ApplyFactoringMethod(FactorsTD,[K_PRIMORIAL_P1_FACTORS],
                           FactorizationObtainedSoFar,infinity,
                           ["Trial division by factors of Primorial(k)+1"]);
    else
      ApplyFactoringMethod(FactorsTD,[K_PRIMORIAL_M1_FACTORS],
                           FactorizationObtainedSoFar,infinity,
                           ["Trial division by factors of Primorial(k)-1"]);
    fi;
    StateInfo();
  fi;

  # Special case Fibonacci numbers

  fib_res := List([13,21,34,55,89,144], m -> n mod m);
  if ForAll([1..6],i->fib_res[i] in FIB_RES[i]) then
    ApplyFactoringMethod(FactorsMultFunc,[Fibonacci],
                         FactorizationObtainedSoFar,infinity,
                         ["Factors of Fibonacci(k) by divisors of k"]);
    if   IsEmpty(FACTORS_FIB)
    then ReadPackage("factint","tables/fibo.g"); fi;
    ApplyFactoringMethod(FactorsTD,[FACTORS_FIB],
                         FactorizationObtainedSoFar,infinity,
                         ["Trial division by factors of Fibonacci(k)"]);
    StateInfo();
  fi;

  # Special case 3^k - 2^k

  if n mod 2520 in [1,5,19,65,211,665,1051,1219,1265,1531,2059] then
    ApplyFactoringMethod(FactorsMultFunc,[k->3^k-2^k],
                         FactorizationObtainedSoFar,infinity,
                         ["Factors of 3^k-2^k by divisors of k"]);
    if   IsEmpty(POW3_M_POW2_FACTORS)
    then ReadPackage("factint","tables/3k2k.g"); fi;
    ApplyFactoringMethod(FactorsTD,[POW3_M_POW2_FACTORS],
                         FactorizationObtainedSoFar,infinity,
                         ["Trial division by factors of 3^k-2^k"]);
    StateInfo();
  fi;

  # Special case a^k +/- b^k

  if   IsEmpty(AK_PM_BK_MOD_2520)
  then ReadPackage("factint","tables/akbk.g"); fi;
  nmod2520 := n mod 2520;
  for a in [3..Length(AK_PM_BK_MOD_2520[1])] do
    for b in [2..a-1] do
      if   nmod2520 in AK_PM_BK_MOD_2520[1][a][b] then
        ApplyFactoringMethod(FactorsMultFunc,[k->a^k-b^k],
          FactorizationObtainedSoFar,infinity,
          [Concatenation("Factors of ",String(a),"^k-",String(b),
                         "^k by divisors of k")]);
      elif nmod2520 in AK_PM_BK_MOD_2520[2][a][b] then
        ApplyFactoringMethod(FactorsMultFunc,[k->a^k+b^k],
          FactorizationObtainedSoFar,infinity,
          [Concatenation("Factors of ",String(a),"^k+",String(b),
                         "^k by divisors of k")]);
      fi;
    od;
  od;

  # Special case `11111111 ...'

  if n mod 10000 in [1111,2222,3333,4444,5555,6666,7777,8888] then
    if n mod (n mod 10) = 0 and SmallestRootInt(9*n/(n mod 10) + 1) = 10 then
      ApplyFactoringMethod(FactorsTD,[Factors(9*n/(n mod 10))],
                           FactorizationObtainedSoFar,infinity,
                           ["RepUnits case ..."]);
    fi;
  fi;

  # The 'naive' methods

  ApplyFactoringMethod(FactorsTD,[],
                       FactorizationObtainedSoFar,infinity,
                       ["Trial division by all primes p < 1000"]);
  StateInfo();
  ApplyFactoringMethod(FactorsTD,[FACTINT_FACTORS_CACHE],
                       FactorizationObtainedSoFar,infinity,
                       ["Trial division by some cached factors"]);
  StateInfo();
  if TDHints <> [] then
  ApplyFactoringMethod(FactorsTD,[TDHints],
                       FactorizationObtainedSoFar,infinity,
                       ["Trial division by factors given as <TDHints>"]); fi;
  StateInfo();
  if IsBoundGlobal("CommandLineHistory") and CommandLineHistory <> fail
    and n > 10^40 and FactorizationObtainedSoFar[2] <> []
  then
    NonDigits := Difference(List([0..255],CHAR_INT),"0123456789");
    CmdLineFacts := SplitString(Concatenation(List(CommandLineHistory,
                                                   String)),
                                NonDigits,NonDigits);
    CmdLineFacts := Set(List(CmdLineFacts,Int));
    CmdLineFacts := List(CmdLineFacts,
                         m->Gcd(m,Maximum(FactorizationObtainedSoFar[2])));
    CmdLineFacts := Filtered(Set(CmdLineFacts,AbsInt),m->m>1);
    ApplyFactoringMethod(FactorsTD,[CmdLineFacts],
                         FactorizationObtainedSoFar,infinity,
                         [Concatenation("Trial division by numbers appear",
                                        "ing in command line history")]);
    StateInfo();
  fi;
  ApplyFactoringMethod(FactorsPowerCheck,[FactInt,"FactInt"],
                       FactorizationObtainedSoFar,infinity,
                       ["Check for perfect powers"]);
  StateInfo();

  # Special case of two factors p, q such that p/q is close to a fraction
  # with small numerator and denominator

  ApplyFactoringMethod(FactorsFermat,[10,1],
                       FactorizationObtainedSoFar,infinity,
                       ["Fermat's method"]);
  StateInfo();

  # Let 'FactorsRho', 'FactorsPminus1', 'FactorsPplus1' and 'FactorsECM' 
  # cast out the medium-sized factors

  if RhoSteps > 0 then
    ApplyFactoringMethod(FactorsRho,[1,RhoCluster,RhoSteps],
                         FactorizationObtainedSoFar,infinity,
                         ["Pollard's Rho\nSteps = ",RhoSteps,
                          ", Cluster = ",RhoCluster,
                          "\nNumber to be factored : ","n"]:
                          UseProbabilisticPrimalityTest);
    StateInfo();
  fi;

  if ForAny(FactorizationObtainedSoFar[2],comp->comp>10^40) then
    ApplyFactoringMethod(FactorsFermat,[1000,1], # Once again, try harder
                         FactorizationObtainedSoFar,infinity,
                         ["Fermat's method"]);
    StateInfo();
    if Pminus1Limit1 > 0 then
    ApplyFactoringMethod(FactorsPminus1,[2,Pminus1Limit1,Pminus1Limit2],
                         FactorizationObtainedSoFar,infinity,
                         ["Pollard's p - 1\nLimit1 = ",
                          Pminus1Limit1,", Limit2 = ",Pminus1Limit2,
                        "\nNumber to be factored : ","n"]); fi;
    StateInfo();
  fi;

  if ForAny(FactorizationObtainedSoFar[2],comp->comp>10^50) then
    if Pplus1Residues > 0 and Pplus1Limit1 > 0 then
    ApplyFactoringMethod(FactorsPplus1,
                         [Pplus1Residues,Pplus1Limit1,Pplus1Limit2],
                         FactorizationObtainedSoFar,infinity,
                         ["Williams' p + 1\nResidues = ",Pplus1Residues,
                          ", Limit1 = ",Pplus1Limit1,", Limit2 = ",
                          Pplus1Limit2,
                          "\nNumber to be factored : ","n"]); fi;
    StateInfo();
  fi;

  if ForAny(FactorizationObtainedSoFar[2],comp->comp>10^30) then
    if ECMLimit1 > 0 and ECMCurves <> 0 then
    ApplyFactoringMethod(FactorsECM,[ECMCurves,ECMLimit1,ECMLimit2,ECMDelta],
                         FactorizationObtainedSoFar,infinity,
                         ["Elliptic Curves Method (ECM)\n",
                          "Curves = ",ECMCurves,"\nInit. Limit1 = ",
                          ECMLimit1,", Init. Limit2 = ",ECMLimit2,
                          ", Delta = ",ECMDelta,
                          "\nNumber to be factored : ","n"]); fi;
    StateInfo();
  fi;

  if ForAny(FactorizationObtainedSoFar[2],comp->comp>10^50) then
    ApplyFactoringMethod(FactorsFermat,[10000,1],
                         FactorizationObtainedSoFar,infinity,
                         ["Fermat's method"]);
    StateInfo();
  fi;

  # Let FactorsMPQS or FactorsCFRAC
  # do the really hard work, if <FactIntPartial> is false
  # or the remaining composite factors are smaller than
  # the upper bounds given by CFRACLimit and MPQSLimit 

  if not Cheap and not FactIntPartial 
  then CFRACBound := infinity;      MPQSBound := infinity;
  else CFRACBound := 10^CFRACLimit; MPQSBound := 10^MPQSLimit; fi;

  if FBMethod = "MPQS" then
  ApplyFactoringMethod(FactorsMPQS,[],
                       FactorizationObtainedSoFar,MPQSBound,
                       ["Multiple Polynomial Quadratic Sieve (MPQS)\n",
                       "Number to be factored : ","n"]:NoPreprocessing);
  elif FBMethod = "CFRAC" then
  ApplyFactoringMethod(FactorsCFRAC,[],
                       FactorizationObtainedSoFar,CFRACBound,
                       ["Continued Fraction Algorithm (CFRAC)\n",
                       "Number to be factored : ","n"]:NoPreprocessing);
  fi;

  Result := FactorizationObtainedSoFar;
  if Result[1] <> [] then Result[1][1] := Result[1][1] * sign;
                     else Result[2][1] := Result[2][1] * sign; fi;

  Info(IntegerFactorizationInfo,1,"");
  Info(IntegerFactorizationInfo,1,"The result is\n",Result,"\n");
  UsedTime := Runtime() - StartingTime;
  Info(IntegerFactorizationInfo,2,"The total runtime was ",
                                   TimeToString(UsedTime),"\n");
  FactorizationCheck(n*sign,Result);
  return Result;
end);

#############################################################################
##
#F  IntegerFactorization( <n> ) . . . . . .  prime factors of the integer <n>
## 
##  Returns the list of prime factors of the integer <n>.
##
InstallGlobalFunction( IntegerFactorization,

function ( n )

  local  result, new, pos, i;

  if   not IsInt(n) 
  then Error("Usage: IntegerFactorization( <n> ), ",
             "where n has to be an integer"); fi;
  if AbsInt(n) <= FACTINT_SMALLINTCACHE_LIMIT then
    if   n > 0 then if   IsBound(FACTINT_SMALLINTCACHE[n])
                    then result := ShallowCopy(FACTINT_SMALLINTCACHE[n]);
                    else result := FactorsInt(n);
                         FACTINT_SMALLINTCACHE[n] := ShallowCopy(result);
                    fi;
                    return result;
    elif n < 0 then if   IsBound(FACTINT_SMALLINTCACHE[-n])
                    then result := ShallowCopy(FACTINT_SMALLINTCACHE[-n]);
                         result[1] := -result[1];
                    else result := FactorsInt(n);
                         FACTINT_SMALLINTCACHE[-n] := ShallowCopy(result);
                         FACTINT_SMALLINTCACHE[-n][1] :=
                        -FACTINT_SMALLINTCACHE[-n][1];
                    fi;
                    return result;
    else return [0]; fi;
  elif AbsInt(n) < 16 * FACTINT_SMALLINTCACHE_LIMIT then
    MakeReadWriteGlobal("FACTINT_SMALLINTCOUNT");
    FACTINT_SMALLINTCOUNT := FACTINT_SMALLINTCOUNT + 1;
    MakeReadOnlyGlobal("FACTINT_SMALLINTCOUNT");
    if    FACTINT_SMALLINTCOUNT > FACTINT_SMALLINTCOUNT_THRESHOLD
      and FACTINT_SMALLINTCACHE_LIMIT < 1048576
    then
      MakeReadWriteGlobal("FACTINT_SMALLINTCACHE_LIMIT");
      FACTINT_SMALLINTCACHE_LIMIT := 2 * FACTINT_SMALLINTCACHE_LIMIT;
      MakeReadOnlyGlobal("FACTINT_SMALLINTCACHE_LIMIT");
      MakeReadWriteGlobal("FACTINT_SMALLINTCOUNT_THRESHOLD");
      FACTINT_SMALLINTCOUNT_THRESHOLD := 3 * FACTINT_SMALLINTCOUNT_THRESHOLD;
      MakeReadOnlyGlobal("FACTINT_SMALLINTCOUNT_THRESHOLD");
    fi;
    return FactorsInt(n);
  elif AbsInt(n) <= 268435455 then return FactorsInt(n); fi;

  pos := Position(List(FACTINT_CACHE,t->t[1]),n);
  if IsInt(pos) then
    MakeReadWriteGlobal("FACTINT_CACHE");
    FACTINT_CACHE[pos][2] := 0;
    for i in [1..Length(FACTINT_CACHE)] do
      FACTINT_CACHE[i][2] := FACTINT_CACHE[i][2] + 1;
    od;
    MakeReadOnlyGlobal("FACTINT_CACHE");
    return FACTINT_CACHE[pos][3];
  fi;

  result := FactorsTDNC(AbsInt(n));
  if result[2] = [] then
    result[1][1] := result[1][1] * SignInt(n);
    return result[1];
  fi;

  result := FactInt( n : FactIntPartial := false, cheap := false )[1];

  if ForAny(result,p->p>1000000) or Number(result,p->p>10000) >= 2 then
    MakeReadWriteGlobal("FACTINT_CACHE");
    Add(FACTINT_CACHE,[n,0,result]);
    for i in [1..Length(FACTINT_CACHE)] do
      FACTINT_CACHE[i][2] := FACTINT_CACHE[i][2] + 1;
    od;
    Sort(FACTINT_CACHE,function(t1,t2) return t1[2] < t2[2]; end);
    if   Length(FACTINT_CACHE) > 20
    then FACTINT_CACHE := FACTINT_CACHE{[1..20]}; fi;
    MakeReadOnlyGlobal("FACTINT_CACHE");
    MakeReadWriteGlobal("FACTINT_FACTORS_CACHE");
    new := Filtered(Set(result),
                    p -> p > 1000000000 and not p in FACTINT_FACTORS_CACHE);
    FACTINT_FACTORS_CACHE := Concatenation(new,FACTINT_FACTORS_CACHE);
    if   Length(FACTINT_FACTORS_CACHE) > 200
    then FACTINT_FACTORS_CACHE := FACTINT_FACTORS_CACHE{[1..200]}; fi;
    MakeReadOnlyGlobal("FACTINT_FACTORS_CACHE");
  fi;

  return result;
end);

#############################################################################
##
#M  Factors( Integers, <n> )  . . . . . . . . . . factorization of an integer
##
InstallMethod( Factors,
               "for integers (FactInt)", true, [ IsIntegers, IsInt ], 1,

  function ( Integers, n )
    return IntegerFactorization( n );
  end );

InstallOtherMethod( Factors, [ IsInt ], n -> Factors( Integers, n ) );

#############################################################################
##
#M  PartialFactorization( <n>, <effort> )  . . . . . . . . . . . . try harder
##
InstallMethod( PartialFactorization,
               "try harder (FactInt)", true, [ IsInt, IsPosInt ], 1,

  function ( n, effort )

    local  CheckAndSortFactors, factors, sign, N;

    CheckAndSortFactors := function ( )
      factors    := SortedList(factors);
      factors[1] := sign*factors[1];
      if   Product(factors) <> N
      then Error("PartialFactorization: Internal error, wrong result!"); fi;
    end;

    if effort < 6 then TryNextMethod(); fi;

    N := n; sign := 1; if n < 0 then sign := -sign; n := -n; fi;

    if effort  = 6 then
      factors := SortedList(Concatenation(FactInt(n:cheap)));
      CheckAndSortFactors(); return factors;
    fi;
    if effort >= 7 then
      factors := SortedList(Concatenation(FactInt(n:FactIntPartial,
                                                  MPQSLimit:=50)));
      CheckAndSortFactors(); return factors;
    fi;
  end );

#############################################################################
##
#E  general.gi . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here