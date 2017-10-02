#############################################################################
##
#W  random.gi                     GAP library                    Frank Lübeck
#W                                                             Max Neunhöffer
##
##
#Y  Copyright (C) 2006 The GAP Group
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
  return Init (res, seed);
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

InstallMethod(Random, [IsRandomSource, IsList], function(rs, list)
  return list[Random(rs, 1, Length(list))];
end);

# A print method.
InstallMethod(PrintObj, [IsRandomSource], function(rs)
  local cat;
  cat := Difference(CategoriesOfObject(rs), [ "IsRandomSource" ]);
  Print("<RandomSource in ", JoinStringsWithSeparator(cat, " and "), ">");
end);

############################################################################
##  We provide the "classical" GAP random generator via a random source.
##
if IsBound(HPCGAP) then
BindThreadLocalConstructor("GlobalRandomSource", {} ->
    Objectify(NewType(RandomSourcesFamily, IsGlobalRandomSource), rec()));
else
InstallValue(GlobalRandomSource,
    Objectify(NewType(RandomSourcesFamily, IsGlobalRandomSource), rec()));
fi;

InstallMethod(Init, [IsGlobalRandomSource, IsObject], function(rs, seed)
  if IsInt(seed) then
    RANDOM_SEED(seed);
  else
    R_N := seed[1];
    R_X := ShallowCopy(seed[2]);
  fi;
  return GlobalRandomSource;
end);
Init(GlobalRandomSource, 1);

InstallMethod(State, [IsGlobalRandomSource], function(rs)
  return [R_N, ShallowCopy(R_X)];
end);

InstallMethod(Reset, [IsGlobalRandomSource, IsObject], function(rs, seed)
  local old;
  old := State(GlobalRandomSource);
  Init(rs, seed);
  return old;
end);

InstallMethod(Random, [IsGlobalRandomSource, IsList], function(rs, l)
  if Length(l) < 2^28 then
    return RANDOM_LIST(l);
  else
    return l[Random(rs, 1, Length(l))];
  fi;
end);

############################################################################
##  The classical GAP random generator as independent random sources.
##  
InstallMethod(Init, [IsGAPRandomSource, IsObject], function(rs, seed)
  local old;
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
    old := Reset(GlobalRandomSource, seed);
    rs!.R_N := R_N;
    rs!.R_X := ShallowCopy(R_X);
    Reset(GlobalRandomSource, old);
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

InstallMethod(Random, [IsGAPRandomSource, IsList], function(rs, list)
  local rx, rn;
  if Length(list) < 2^28 then
    # we need to repeat the code of RANDOM_LIST
    rx := rs!.R_X;
    rn := rs!.R_N mod 55 + 1;
    rs!.R_N := rn;
    rx[rn] := (rx[rn] + rx[(rn+30) mod 55+1]) mod R_228;
    return list[ QUO_INT( rx[rn] * LEN_LIST(list), R_228 ) + 1 ];
  else
    return list[Random(rs, 1, Length(list))];
  fi;
end);


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

InstallMethod(Random, [IsMersenneTwister, IsList], function(rs, list)
  return list[Random(rs, 1, Length(list))];
end);

InstallMethod(Random, [IsMersenneTwister, IsInt, IsInt], function(rs, a, b)
  local d, nrbits, res;
  d := b-a+1;
  if d < 0 then
    return fail;
  elif d = 0 then
    return a;
  fi;
  nrbits := Log2Int(d) + 1;
  repeat
    res := RandomIntegerMT(rs!.state, nrbits);
  until res < d;
  return res + a;
end);

# One global Mersenne twister random source, can be used to overwrite
# the library Random(list) and Random(a,b) methods.
if IsBound(HPCGAP) then
BindThreadLocalConstructor("GlobalMersenneTwister", {} ->
    RandomSource(IsMersenneTwister, String(GET_RANDOM_SEED_COUNTER())));
else
InstallValue(GlobalMersenneTwister, RandomSource(IsMersenneTwister, "1"));
fi;

# default random method for lists and pairs of integers using the Mersenne
# twister
InstallMethod( Random, "for an internal list",
    [ IsList and IsInternalRep ], 100, function(l) 
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

