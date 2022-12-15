#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck, Max Neunhöffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file implements the basic operations for some types of random
##  sources.
##

###########################################################################
##  Generic methods for random sources.
##
# The generic initializer of a random source creates a dummy object of the
# right type and then calls 'Init'.
InstallMethod(RandomSource, [IsOperation, IsObject], function(rep, seed)
  local res;
  res := Objectify(NewType(RandomSourcesFamily, rep), rec());
  return Init(res, seed);
end);
InstallMethod(RandomSource, [IsOperation], function(rep)
  return RandomSource(rep, 1);
end);

# A generic Reset if no seed is given (then seed=1 is chosen).
InstallMethod(Reset, [IsRandomSource], function(rs)
  return Reset(rs, 1);
end);

# Generic fallback methods, such that it is sufficient to install Random for
# lists or for pairs of integers.
InstallMethod(Random, [IsRandomSource, IsInt, IsInt], function(rs, a, b)
  local  d, x, r, y;
  d := b - a;
  if d < 0  then
    return fail;
  elif a = b  then
    return a;
  else
    x := LogInt( d, 2 ) + 1;
    r := 0;
    while 0 < x  do
        y := Minimum( 10, x );
        x := x - y;
        r := r * 2 ^ y + Random( rs, [ 0 .. (2 ^ y - 1) ] );
    od;
    if d < r  then
        return Random( rs, a, b );
    else
        return a + r;
    fi;
  fi;
end);

InstallMethod(Random, [IsRandomSource, IsList and IsDenseList],
  function(rs, list)
  return list[Random(rs, 1, Length(list))];
end);

# A print method.
InstallMethod(PrintObj, [IsRandomSource], function(rs)
  local cat;
  cat := Difference(CategoriesOfObject(rs), [ "IsRandomSource" ]);
  Print("<RandomSource in ", JoinStringsWithSeparator(cat, " and "), ">");
end);


############################################################################
##  The classical GAP random generator as independent random sources.
##

# We need to compute modulo 2^28 repeatedly. If we just write 2^28 into the
# code, though, GAP needs to evaluate it to 268435456 each time it executes
# the function. To avoid this, we put it into a constant. As an additional
# trick, we actually store -2^28, which gives identical results, but has the
# benefit of being an immediate integer even on 32 bit systems.
BIND_CONSTANT("R_228", -2^28);

InstallMethod(Init, [IsGAPRandomSource, IsObject], function(rs, seed)
  local R_N, R_X, i;
  if seed = 1 then
    rs!.R_N := 45;
    rs!.R_X  :=   [  66318732,  86395905,  22233618,   21989103,  237245480,
    264566285,  240037038, 264902875,  9274660,  180361945, 94688010,  24032135,
    106293216,  27264613,  126456102,  243761907, 80312412,  2522186,  59575208,
    70682510, 228947516,  173992210, 175178224, 250788150,  73030390, 210575942,
    128491926, 194508966,  201311350, 63569414, 185485910,  62786150, 213986102,
    88913350,  94904086, 252860454,  247700982, 233113990,  75685846, 196780518,
    74570934,  7958751,  130274620,  247708693, 183364378,  82600777,  28385464,
    184547675,  20423483, 75041763,  235736203,  54265107, 49075195,  100648387,
    114539755 ];
  elif IsInt(seed) then
    R_N := 1;
    R_X := [ seed mod R_228 ];
    for i in [2..55] do
        R_X[i] := (1664525 * R_X[i-1] + 1) mod R_228;
    od;
    for i in [1..99] do
        R_N := R_N mod 55 + 1;
        R_X[R_N] := (R_X[R_N] + R_X[(R_N+30) mod 55+1]) mod R_228;
    od;
    rs!.R_N := R_N;
    rs!.R_X := R_X;
  else
    rs!.R_N := seed[1];
    rs!.R_X := ShallowCopy(seed[2]);
  fi;
  return rs;
end);

InstallMethod(State, [IsGAPRandomSource], function(rs)
  return [rs!.R_N, ShallowCopy(rs!.R_X)];
end);

InstallMethod(Reset, [IsGAPRandomSource, IsObject], function(rs, seed)
  local old;
  old := State(rs);
  Init(rs, seed);
  return old;
end);

InstallMethod(Random, [IsGAPRandomSource, IsList and IsDenseList],
  function(rs, list)
  local rx, rn;
  if Length(list) < 2^28 then
    rx := rs!.R_X;
    rn := rs!.R_N mod 55 + 1;
    rs!.R_N := rn;
    rx[rn] := (rx[rn] + rx[(rn+30) mod 55+1]) mod R_228;
    return list[ QUO_INT( rx[rn] * LEN_LIST(list), -R_228 ) + 1 ];
  else
    return list[Random(rs, 1, Length(list))];
  fi;
end);


############################################################################
##  We provide the "classical" GAP random generator via a random source.
##
if IsHPCGAP then
    BIND_GLOBAL("RANDOM_SEED_COUNTER", FixedAtomicList(1, 0));
    BIND_GLOBAL("GET_RANDOM_SEED_COUNTER", {} ->
      ATOMIC_ADDITION(RANDOM_SEED_COUNTER, 1, 1) );

    # HACK to enforce backwards compatibility: when reading this file,
    # we are on the main thread, and want to initialize GlobalRandomSource
    # with seed 1, without modifying the RANDOM_SEED_COUNTER, to get
    # behavior identical with that of prior GAP versions, and also identical
    # with regular GAP (on a single thread).
    BIND_GLOBAL("GlobalRandomSource", RandomSource(IsGAPRandomSource, 1));

    BindThreadLocalConstructor("GlobalRandomSource", {} ->
       RandomSource(IsGAPRandomSource, GET_RANDOM_SEED_COUNTER()));
else
    BindGlobal("GlobalRandomSource", RandomSource(IsGAPRandomSource, 1));
fi;


##############################################################################
##  Random source using the Mersenne twister kernel functions.
##
InstallMethod(Init, [IsMersenneTwister, IsObject], function(rs, seed)
  local st, endianseed, endiansys, perm, tmp, i;
  if IsPlistRep(seed) and IsString(seed[1]) and Length(seed[1]) = 2504 then
    st := ShallowCopy(seed[1]);
    # maybe adjust endianness if seed comes from different machine:
    endianseed := st{[2501..2504]};
    endiansys := GlobalMersenneTwister!.state{[2501..2504]};
    if endianseed <> endiansys then
      perm := List(endiansys, c-> Position(endianseed, c));
      tmp := "";
      for i in [0..625] do
        tmp{[4*i+1..4*i+4]} := st{4*i+perm};
      od;
      st := tmp;
    fi;
    rs!.state := st;
  else
    if not IsString(seed) then
      seed := ShallowCopy(String(seed));
      # padding such that length is positive and divisible by 4
      while Length(seed) = 0 or Length(seed) mod 4 <> 0 do
        Add(seed, CHAR_INT(0));
      od;
    fi;
    rs!.state := InitRandomMT(seed);
  fi;
  return rs;
end);

InstallMethod(State, [IsMersenneTwister], function(rs)
  return [ShallowCopy(rs!.state)];
end);

InstallMethod(Reset, [IsMersenneTwister, IsObject], function(rs, seed)
  local old;
  old := State(rs);
  Init(rs, seed);
  return old;
end);

# We do not need a 'Random' method for 'IsMersenneTwister' and a dense list,
# the default method for 'IsRandomSource' is enough.

InstallMethod(Random, [IsMersenneTwister, IsInt, IsInt], function(rs, a, b)
  local d, nrbits, res;
  d := b-a+1;
  if d <= 0 then
    return fail;
  fi;
  # Here we could return 'a' in the case 'd = 1'.
  # However, this would change the sequence of random numbers
  # w.r.t. earlier GAP versions.
  nrbits := Log2Int(d) + 1;
  repeat
    res := RandomIntegerMT(rs!.state, nrbits);
  until res < d;
  return res + a;
end);

# One global Mersenne twister random source, can be used to overwrite
# the library Random(list) and Random(a,b) methods.
if IsHPCGAP then
BindThreadLocalConstructor("GlobalMersenneTwister", {} ->
    RandomSource(IsMersenneTwister, String(GET_RANDOM_SEED_COUNTER())));
else
BindGlobal("GlobalMersenneTwister", RandomSource(IsMersenneTwister, "1"));
fi;

# default random method for lists and pairs of integers using the Mersenne
# twister
InstallMethod( Random, "for a dense internal list",
    [ IsList and IsDenseList and IsInternalRep ], 100, function(l)
  return l[Random(GlobalMersenneTwister, 1, Length(l))];
end );

InstallMethod( Random,
    "for two integers",
    IsIdenticalObj,
    [ IsInt,
      IsInt ],
    0,
function(low, high)
  return Random(GlobalMersenneTwister, low, high);
end );


(function()
    local func;
    func := function(installType)
        return function(args...)
            local filterpos, i, func, info;

            # Check we understand arguments
            # Second value must be an info string
            if not IsString(args[2]) then
                ErrorNoReturn("Second argument must be an info string");
            fi;

            # Info strings always tend to begin 'for ', and here we want
            # to be able to edit it, so we check.
            if args[2]{[1..23]} <> "for a random source and" then
                ErrorNoReturn("Info string must begin 'for a random source and'");
            fi;

            # Filters must start with 'IsRandomSource'
            for i in [1..Length(args)] do
                if IsList(args[i]) and args[i][1] = IsRandomSource then
                    filterpos := i;
                fi;
            od;

            if not IsBound(filterpos) then
                ErrorNoReturn("Must use a list of filters beginning 'IsRandomSource'");
            fi;

            # Last argument must be the actual method
            if not IsFunction(args[Length(args)]) then
                ErrorNoReturn("Argument list must end with the method");
            fi;

            # Install
            CallFuncList(installType, args);

            # Install random, wrapping random source argument

            # Remove 'IsRandomSource' from the filter list
            Remove(args[filterpos], 1);

            # Correct info string by removing 'a random source and'
            info := "for";
            APPEND_LIST(info, args[2]{[24..Length(args[2])]});
            args[2] := info;

            func := Remove(args);
            if Length(args[filterpos]) = 1 then
                Add(args, x -> func(GlobalMersenneTwister,x));
            elif Length(args[filterpos]) = 2 then
                Add(args, {x,y} -> func(GlobalMersenneTwister,x,y));
            else
                Error("Only 2 or 3 argument methods supported");
            fi;

            CallFuncList(installType, args);
        end;
    end;
    InstallGlobalFunction("InstallMethodWithRandomSource", func(InstallMethod));
    InstallGlobalFunction("InstallOtherMethodWithRandomSource", func(InstallOtherMethod));
end)();

# This method must rank below Random(SomeRandomSource, IsList)
# for any random source SomeRandomSource, to avoid an infinite loop.
InstallMethodWithRandomSource( Random, "for a random source and a (finite) collection",
    [ IsRandomSource, IsCollection and IsFinite ],
    {} -> -RankFilter(IsCollection and IsFinite),
    {rs, C} -> RandomList(rs, Enumerator( C ) ) );
