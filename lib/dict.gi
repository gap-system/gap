#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Gene Cooperman, Scott Murray, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementations for dictionaries.
##

##
## List and Sort dictionaries
##


BindGlobal("DictionaryByList",function(look)
local d,rep;
  d:=rec();
  if look then
    rep:=IsListLookupDictionary;
    d.entries:=[];
  else
    rep:=IsListDictionary;
    d.list:=[];
  fi;
  Objectify(NewType(DictionariesFamily,rep and IsMutable and IsCopyable),d);
  return d;
end);


BindGlobal("DictionaryBySort",function(look)
local d,rep;
  d:=rec();
  if look then
    rep:=IsSortLookupDictionary;
    d.entries:=[];
  else
    rep:=IsSortDictionary;
    d.list:=[];
  fi;
  Objectify(NewType(DictionariesFamily,rep and IsMutable and IsCopyable),d);
  return d;
end);

#############################################################################
##
#M  ShallowCopy (for list dictionaries)
##


InstallMethod(ShallowCopy, [IsListLookupDictionary and IsCopyable],
        function(dict)
    local   c;
    c := rec( entries := ShallowCopy(dict!.entries) );
    return Objectify( NewType(DictionariesFamily, IsListLookupDictionary and IsMutable), c);
end);

InstallMethod(ShallowCopy, [IsListDictionary and IsCopyable],
        function(dict)
    local   c;
    c := rec( list := ShallowCopy(dict!.list) );
    return Objectify( NewType(DictionariesFamily, IsListDictionary and IsMutable), c);
end);

InstallMethod(ShallowCopy, [IsSortLookupDictionary and IsCopyable],
        function(dict)
    local   c;
    c := rec( entries := ShallowCopy(dict!.entries) );
    return Objectify( NewType(DictionariesFamily, IsSortLookupDictionary and IsMutable), c);
end);

InstallMethod(ShallowCopy, [IsSortDictionary and IsCopyable],
        function(dict)
    local   c;
    c := rec( list := ShallowCopy(dict!.list) );
    return Objectify( NewType(DictionariesFamily, IsSortDictionary and IsMutable), c);
end);



#############################################################################
##
#M  AddDictionary(<dict>,<obj>,<val>)
##
InstallOtherMethod(AddDictionary,"for lookup list dictionaries",true,
  [IsListLookupDictionary and IsMutable,IsObject,IsObject],0,
function(d, x, val)
  x:=[Immutable(x),val];
  #  MakeImmutable(x); # to be able to store sortedness
  # We don't actually need to do that and we don't want to modify val
  #
  Add(d!.entries,x);
end);

InstallMethod(AddDictionary,"for list dictionaries",true,
  [IsListDictionary and IsMutable,IsObject],0,
function(d, x)
    x:=Immutable(x); # to be able to store sortedness
  Add(d!.list,x);
end);

#############################################################################
##
#M  RemoveDictionary(<dict>,<obj>)
##
InstallOtherMethod(RemoveDictionary,"for lookup list dictionaries",true,
  [IsListLookupDictionary and IsMutable,IsObject],0,
function(d, key)
  local pos;
  pos := PositionProperty(d!.entries, x->x[1] = key);
  if pos <> fail then
    Remove(d!.entries, pos);
  fi;
end);

InstallMethod(RemoveDictionary,"for list dictionaries",true,
  [IsListDictionary and IsMutable,IsObject],0,
function(d, key)
  local pos;
  pos := Position(d!.list, key);
  if pos <= Length(d!.list) and d!.list[pos] = key then
    Remove(d!.list, pos);
  fi;;
end);


#############################################################################
##
#M  AddDictionary(<dict>,<obj>,<val>)
##
InstallOtherMethod(AddDictionary,"for lookup sort dictionaries",true,
        [IsSortLookupDictionary and IsMutable,IsObject,IsObject],0,
        function(d, x, val)
    local pair, p;
    pair:=[Immutable(x),val];
    # MakeImmutable(pair); # to be able to store sortedness

    p := PositionSorted(d!.entries,[x]);
    if p <= Length(d!.entries) and d!.entries[p][1] = x then
        d!.entries[p] := pair;
    else
        Add(d!.entries, pair, p);
    fi;
end);

InstallMethod(AddDictionary,"for sort dictionaries",true,
  [IsSortDictionary and IsMutable,IsObject],0,
function(d, x)
  x:=Immutable(x); # to be able to store sortedness
  AddSet(d!.list,x);
end);

#############################################################################
##
#M  KnowsDictionary(<dict>,<obj>)
##
InstallMethod(KnowsDictionary,"for list lookup dictionaries",true,
  [IsListLookupDictionary,IsObject],0,
function(d,x)
local p;
  for p in d!.entries do
    if p[1] = x then
      return true;
    fi;
  od;
  return false;
end);

InstallMethod(KnowsDictionary,"for lookup sort dictionaries",true,
  [IsSortLookupDictionary,IsObject],0,
function(d,x)
local p;
  p := PositionSorted(d!.entries,[x]);
  return p <= Length(d!.entries) and d!.entries[p][1] = x;
end);

InstallMethod(KnowsDictionary,"for list dictionaries",true,
  [IsListDictionary,IsObject],0,
function(d,x)
    return x in d!.list;
end);

#############################################################################
##
#M  LookupDictionary(<dict>,<obj>)
##
InstallMethod(LookupDictionary,"for list dictionaries",true,
  [IsListLookupDictionary,IsObject],0,
function(d,x)
    local p;
    for p in d!.entries do
        if p[1] = x then
            return p[2];
        fi;
    od;
    return fail;
end);

InstallMethod(LookupDictionary,"for lookup sort dictionaries",true,
  [IsSortLookupDictionary,IsObject],0,
function(d,x)
local p;
  p := PositionSorted(d!.entries,[x]);
  if p <= Length(d!.entries) and d!.entries[p][1] = x then
    return d!.entries[p][2];
  fi;
  return fail;
end);

##
## Position dictionaries
##

InstallGlobalFunction(DictionaryByPosition,
function(domain,look)
local d,rep;
  d:=rec(domain:=domain,blist:=BlistList([1..Length(domain)],[]));
  if look then
    rep:=IsPositionLookupDictionary;
    d.vals:=[];
  else
    rep:=IsPositionDictionary;
  fi;
  Objectify(NewType(DictionariesFamily,rep and IsMutable and IsCopyable),d);
  return d;
end);

InstallMethod(ShallowCopy, [IsPositionDictionary and IsCopyable],
        function(d)
    local   r;
    r := rec( domain := d!.domain,
              blist := ShallowCopy(d!.blist));
    Objectify(NewType(DictionariesFamily,IsPositionDictionary and IsMutable and IsCopyable),r);
    return r;
end);

InstallMethod(ShallowCopy, [IsPositionLookupDictionary and IsCopyable],
        function(d)
    local   r;
    r := rec( domain := d!.domain,
              blist := ShallowCopy(d!.blist),
              vals := ShallowCopy(d!.vals));
    Objectify(NewType(DictionariesFamily,IsPositionLookupDictionary and IsMutable and IsCopyable),r);
    return r;
end);


#############################################################################
##
#M  AddDictionary(<dict>,<obj>,<val>)
##
InstallOtherMethod(AddDictionary,"for lookup position dictionaries",true,
  [IsPositionLookupDictionary and IsMutable,IsObject,IsObject],0,
function(d, x, val)
  x:=PositionCanonical(d!.domain,x);
  d!.blist[x]:=true;
  d!.vals[x]:=val;
end);

InstallMethod(AddDictionary,"for position dictionaries",true,
  [IsPositionDictionary and IsMutable,IsObject],0,
function(d, x)
  x:=PositionCanonical(d!.domain,x);
  d!.blist[x]:=true;
end);

#############################################################################
##
#M  KnowsDictionary(<dict>,<obj>)
##
InstallMethod(KnowsDictionary,"for position dictionaries",true,
  [IsPositionDictionary,IsObject],0,
function(d,x)
  x:=PositionCanonical(d!.domain,x);
  return d!.blist[x];
end);

#############################################################################
##
#M  LookupDictionary(<dict>,<obj>)
##
InstallMethod(LookupDictionary,"for position dictionaries",true,
  [IsPositionLookupDictionary,IsObject],0,
function(d,x)
  x:=PositionCanonical(d!.domain,x);
  if d!.blist[x] then
    return d!.vals[x];
  else
    return fail;
  fi;
end);


#############################################################################
##
#F  NewDictionary(<objcoll>,<look>)
##
InstallGlobalFunction(NewDictionary,function(arg)
local hashfun,obj,dom,lookup,maxblist,forcesort;
  obj:=arg[1];
  lookup:=arg[2];
  if Length(arg)>2 then
    dom:=arg[3];
  else
    dom:=fail;
  fi;

  # if the domain is an enumerator, get rid of it
  if HasUnderlyingCollection(dom) then
    dom:=UnderlyingCollection(dom);
  fi;

  maxblist:=ValueOption("blistlimit");
  if not IsInt(maxblist) then
    #2^25 plist (for the lookup list that will hold e.g. positions)
    # is 128MB size on a 32-bit system.
    maxblist:=2^25;
  fi;

  # are we given a domain, which can index very quickly?
  if dom<>fail and IsList(dom) and
    (IsQuickPositionList(dom) or
      (not IsMutable(dom) and IsSSortedList(dom) and
       CanEasilySortElements(dom[1]) )  )
      and Length(dom)<=maxblist then
    Info(InfoHash,1,obj," Position dictionary");
    return DictionaryByPosition(dom,lookup);
  elif dom<>fail and IsFreeLeftModule(dom) and
    IsFFECollection(LeftActingDomain(dom)) and
    Size(LeftActingDomain(dom))<=256
    and Size(dom)<=maxblist then
    # FF vector space: use enumerator for position
    Info(InfoHash,1,obj," Position dictionary for vector space");
    return DictionaryByPosition(Enumerator(dom),lookup);
  fi;

  # can we try hashing? Only if domain is given and not for small perms.
  if dom<>fail and (not IsPerm(obj) or NrMovedPoints(obj)>100000) then
    if IsRecord(dom) and IsBound(dom.hashfun) then
      hashfun:=dom.hashfun;
    else
      hashfun:=SparseIntKey(dom,obj);
    fi;
  elif dom=fail and IsFFECollColl(obj) then
    hashfun:=SparseIntKey(dom,obj);
  else
    hashfun:=fail;
  fi;

  if hashfun<>fail then
    Info(InfoHash,1," Hash dictionary");
    # uncomment the next line to get back the old version.
    #return NaiveHashDictionary(dom,lookup,hashfun);
    return SparseHashTable(hashfun);
  fi;

  # can we sort the elements cheaply?
  forcesort:=ValueOption("usesortdictionary");
  if forcesort=true or (forcesort<>false and CanEasilySortElements(obj)) then
    Info(InfoHash,2,obj," Sort dictionary");
    return DictionaryBySort(lookup);
  fi;

  # Alas, we can't do anything. Go the hard way
  Info(InfoHash,1,obj," ",dom," List dictionary");
  return DictionaryByList(lookup);
end);

#############################################################################
##
#M  Enumerator( <dict> ) for list dictionaries
##
InstallMethod( Enumerator, "for list dictionaries",
    [ IsListDictionary ], 0,
    function( dict )
      if IsListLookupDictionary(dict) then
        return List(dict!.entries, pair -> pair[2]);
      else
        return ShallowCopy(dict!.list);
      fi;
    end );

#############################################################################
##
#M  ListKeyEnumerator( <dict> ) for list dictionaries
##
InstallMethod( ListKeyEnumerator, "for list dictionaries",
    [ IsListDictionary ], 0,
    function( dict )
      if IsListLookupDictionary(dict) then
        return List(dict!.entries, pair -> pair[1]);
      else
        return ShallowCopy(dict!.list);
      fi;
    end );

#############################################################################
##
#M  ViewObj( <dict> ) for dictionaries
##
InstallMethod( ViewObj, "for dictionaries", true,
    [ IsDictionary ], 0,
    function( hash )
      Print("<");
      if IsLookupDictionary(hash) then
          Print("lookup ");
      fi;
      Print("dictionary>");
    end );

# here starts the hash table bit by Gene and Scott

##  PERFORMANCE:
##   For perms, IsBound() inside GetHashKey() might cost too much.
##   Try initializing hash!.valueArray to all 'fail' entries.
##   Then just return hash!.valueArray[ LastHashIndex ], and if
##     it's fail, let it be so.
##   How much does this speed up the perm code?
##

#############################################################################
##
#V  MaxHashViewSize
##
##  The maximum size of a hash table for which ViewObj will print the whole
##  table (default 10).
##
MaxHashViewSize := 10;

#############################################################################
##
#V  LastHashIndex is used for fast access to the last hash index.
##
LastHashIndex := -1;


#############################################################################
#############################################################################
##
##  Dense hash tables
##
#############################################################################
#############################################################################

#############################################################################
##
#F  DenseHashTable( )
##
InstallGlobalFunction( DenseHashTable,
    function( )
        local Type, Rec;

        Type := NewType( DictionariesFamily, IsDenseHashRep and IsMutable );
        Rec := rec( KeyArray := [], ValueArray := [] );
        return Objectify( Type, Rec );
    end );

#############################################################################
##
#M  ViewObj( <hash> ) for dense hash tables
##
InstallMethod( ViewObj, "for dense hash tables", true,
    [ IsDenseHashRep ], 0,
    function( hash )
        if Size( hash ) > MaxHashViewSize then
            Print("<dense hash table of size ", Size( hash ), ">");
        else
            PrintHashWithNames( hash, "Keys", "Values" );
        fi;
    end );

#############################################################################
##
#M  PrintHashWithNames( <hash>, <keyName>, <valueName> )
#M      for dense hash tables
##
InstallMethod( PrintHashWithNames, "for dense hash tables", true,
    [ IsDenseHashRep, IsString, IsString ], 0,
    function( hash, keyName, valueName )
        local key;
        Print(keyName, ": ", hash!.KeyArray, "\n");
        Print(valueName, ": ", List( hash!.KeyArray,
               key -> hash!.ValueArray[key] ));
    end );

#############################################################################
##
#M  PrintObj( <hash> ) for dense hash tables
##
InstallMethod( PrintObj, "for dense hash tables", true,
    [ IsDenseHashRep ], 0,
    function( hash )
        PrintHashWithNames( hash, "Keys", "Values" ); Print("\n");
    end );

#############################################################################
##
#M  Size( <hash> ) for dense hash tables
##
InstallMethod( Size, "for dense hash tables", true,
    [ IsDenseHashRep ], 0,
    function( hash )
        return Length( hash!.KeyArray );
    end );

#############################################################################
##
#M  Enumerator( <hash> ) for dense hash tables
##
InstallMethod( Enumerator, "for dense hash tables", true,
    [ IsDenseHashRep ], 0,
    function( hash )
        return List( hash!.KeyArray, key -> GetHashEntry( hash, key ) );
    end );

#############################################################################
##
#M  HashKeyEnumerator( <hash> ) for dense hash tables
##
InstallMethod( HashKeyEnumerator, "for dense hash tables", true,
    [ IsDenseHashRep ], 0,
    function( hash )
        return hash!.KeyArray;
    end );

#############################################################################
##
#M  Random( <hash> ) for dense hash tables
##
##  Returns a random value.
##
InstallMethod( Random, "for dense hash tables", true,
    [ IsHash and IsDenseHashRep ], 100,
    function( hash )
        return GetHashEntry( hash, RandomHashKey( hash ) );
    end );

#############################################################################
##
#M  RandomHashKey( <hash> ) for dense hash tables
##
##  Returns a random key.
##
InstallMethod( RandomHashKey, "for dense hash tables", true,
    [ IsHash and IsDenseHashRep ], 100,
    function( hash )
        return Random(hash!.KeyArray);
    end );


#############################################################################
#############################################################################
##
##  Sparse hash tables
##
#############################################################################
#############################################################################

#############################################################################
##
#V  DefaultHashLength
##
##  Default starting hash table size
##
DefaultHashLength := 2^8;
if IsHPCGAP then
  MakeThreadLocal("DefaultHashLength");
fi;

#############################################################################
##
#F  SparseHashTable( )
##
InstallGlobalFunction( SparseHashTable,
function(arg)
local Rec,T,len;

  len:=DefaultHashLength;
  if Length(arg)>1 then
    len:=arg[2];
  fi;

  Rec := rec( KeyArray := ListWithIdenticalEntries( len, fail ),
              ValueArray := [],
              LengthArray := len,
              NumberKeys := 0,
              ProbingDepth := len - 2);

  if Length(arg)>0 then
    T:=Objectify( DefaultSparseHashWithIKRepType, Rec );
    T!.intKeyFun:=arg[1];
  else
    T:=Objectify( DefaultSparseHashRepType, Rec );
  fi;
  T!.LengthArrayHalf := QuoInt(T!.LengthArray,2);

  return T;
end );

#############################################################################
##
#M  ShallowCopy( <hash> ) for sparse hash table
##
InstallMethod(ShallowCopy, [IsSparseHashRep and IsCopyable],
        function(t)
    local r;
    r := rec( KeyArray := ShallowCopy(t!.KeyArray),
              ValueArray := ShallowCopy(t!.ValueArray),
              LengthArray := t!.LengthArray,
              NumberKeys := t!.NumberKeys,
              ProbingDepth := t!.ProbingDepth,
              LengthArrayHalf := t!.LengthArrayHalf);
    return Objectify( DefaultSparseHashRepType and IsMutable, r);
end);

InstallMethod(ShallowCopy, [IsSparseHashRep and TableHasIntKeyFun and IsCopyable],
        function(t)
    local r;
    r := rec( KeyArray := ShallowCopy(t!.KeyArray),
              ValueArray := ShallowCopy(t!.ValueArray),
              LengthArray := t!.LengthArray,
              NumberKeys := t!.NumberKeys,
              ProbingDepth := t!.ProbingDepth,
              intKeyFun := t!.intKeyFun,
              LengthArrayHalf := t!.LengthArrayHalf);
    return Objectify( DefaultSparseHashWithIKRepType and IsMutable, r);
end);

#############################################################################
##
#M  ViewObj( <hash> ) for sparse hash table
##
InstallMethod( ViewObj, "for sparse hash tables", true,
    [ IsSparseHashRep ], 0,
    function( hash )
        if Size( hash ) > MaxHashViewSize then
            Print("<sparse hash table of size ", Size( hash ), ">");
        else
            PrintHashWithNames( hash, "Keys", "Values" );
        fi;
    end );

#############################################################################
##
#M  PrintHashWithNames( <hash>, <keyName>, <valueName> )
##      for sparse hash table
##
InstallMethod( PrintHashWithNames, "for sparse hash tables", true,
    [ IsSparseHashRep, IsString, IsString ], 0,
    function( hash, keyName, valueName )
        Print(keyName, ": ", HashKeyEnumerator( hash ), "\n");
        Print(valueName, ": ", Enumerator( hash ));
    end );

#############################################################################
##
#M  PrintObj( <hash> ) for sparse hash table
##
InstallMethod( PrintObj, "for sparse hash tables", true,
    [ IsSparseHashRep ], 0,
    function( hash )
        PrintHashWithNames(hash, "Keys", "Values" ); Print("\n");
    end );

#############################################################################
##
#M  Size( <hash> ) for sparse hash table
##
InstallMethod( Size, "for sparse hash tables", true,
    [ IsHash and IsSparseHashRep ], 0,
    hash -> hash!.NumberKeys );

#############################################################################
##
#M  Enumerator( <hash> ) for sparse hash table
##
InstallMethod( Enumerator, "for sparse hash tables", true,
    [ IsHash and IsSparseHashRep ], 0,
    hash -> List( Filtered( hash!.KeyArray, x -> x <> fail ),
                  key -> GetHashEntry( hash, key ) ) );

#############################################################################
##
#M  HashKeyEnumerator( <hash> ) for sparse hash table
##
InstallMethod( HashKeyEnumerator, "for sparse hash tables", true,
    [ IsHash and IsSparseHashRep ], 0,
    hash -> Filtered( hash!.KeyArray, x -> x <> fail ) );

#############################################################################
##
#M  Random( <hash> ) for sparse hash tables
##
##  Returns a random key.
##
InstallMethod( Random, "for sparse hash tables", true,
    [ IsHash and IsSparseHashRep ], 100,
    function( hash )
        return GetHashEntry( hash, RandomHashKey( hash ) );
    end );

#############################################################################
##
#M  RandomHashKey( <hash> ) for sparse hash tables
##
##  Returns a random key.
##
InstallMethod( RandomHashKey, "for sparse hash tables", true,
    [ IsHash and IsSparseHashRep ], 100,
    function( hash )
        local i;

        if Size( hash ) = 0 then return fail; fi;
        repeat
            i := Random( 1, hash!.LengthArray );
        until hash!.KeyArray[i] <> fail;
        return hash!.KeyArray[i];
    end );

#############################################################################
#############################################################################
##
##  Hash functions
##
#############################################################################
#############################################################################

#############################################################################
##
#F  IntegerHashFunction( <key>, <i>, <size> )
##
InstallGlobalFunction( IntegerHashFunction,
    function( key, i, size )
        # return ( (1+key) + i*(1+2*(key mod size/2)) ) mod size;
        return 1+( (1+key) + i*(1+2*(key mod QuoInt(size,2))) ) mod size;
        #return 1 + ( key + i * (1 + (key mod 2) + (key mod size)) ) mod size;
        #return 1 + ( key + (i-1) * (QuoInt(size,17))) mod size;
    end );

BindGlobal("HashClashFct",function(intkey,i,len)
  return 1+((intkey+i) mod len);
  #return 1+(intkey mod (len-i));
end);

#############################################################################
##
#M  AddDictionary(<dict>,<key>,<val>)
##
BindGlobal("HashDictAddDictionary",function(hash,key,value)
local index,intkey,i;
  intkey := hash!.intKeyFun(key);
#  cnt:=0;
  repeat
    for i in [0..hash!.ProbingDepth] do
      index:=HashClashFct(intkey,i,hash!.LengthArray);
      if hash!.KeyArray[index] = fail then
#if cnt>MAXCLASH then MAXCLASH:=cnt;
#Print("found after ",cnt," clashes, ", Length(Set(
#  List([0..i-1],x->hash!.intKeyFun(hash!.KeyArray[HashClashFct(intkey,x,hash!.LengthArray)]))   )), " different keys\n");
#fi;
        hash!.KeyArray[ index ] := key;
        hash!.ValueArray[ index ] := value;
        hash!.NumberKeys := hash!.NumberKeys + 1;
        # was: if 2 * hash!.NumberKeys > Length( hash!.KeyArray ) then
        # The length of the key array is just hash!.lengthArray. Thus
        # this looks like an unnecessary multiplication.
        if hash!.NumberKeys > hash!.LengthArrayHalf then
          DoubleHashDictSize( hash );
        fi;
        return;
      fi;
#      cnt:=cnt+1;
    od;
    # failed: Double size
    #Error("Failed/double ",intkey," ",key," ",hash!.ProbingDepth,"\n");
    hash!.ProbingDepth := hash!.ProbingDepth * 2;
    DoubleHashDictSize( hash );
  until false;
end );

InstallOtherMethod(AddDictionary,"for hash tables",true,
  [IsHash and IsSparseHashRep and TableHasIntKeyFun and IsMutable,
   IsObject,IsObject],0,HashDictAddDictionary);

InstallOtherMethod(AddDictionary,"for hash tables",true,
  [IsHash and IsSparseHashRep and IsMutable,
   IsObject,IsObject],0,
function(hash,key,value)
local index,intkey,i;
  intkey := SparseIntKey( false,key )(key);
  for i in [0..hash!.ProbingDepth] do
    index:=HashClashFct(intkey,i,hash!.LengthArray);

    if hash!.KeyArray[index] = fail then
      hash!.KeyArray[ index ] := key;
      hash!.ValueArray[ index ] := value;
      hash!.NumberKeys := hash!.NumberKeys + 1;
      # was: if 2 * hash!.NumberKeys > Length( hash!.KeyArray ) then
      # The length of the key array is just hash!.lengthArray. Thus
      # this looks like an unnecessary multiplication.
      if hash!.NumberKeys > hash!.LengthArrayHalf then
        DoubleHashDictSize( hash );
      fi;
      return;
    fi;
  od;
  Error("hash table in infinite loop");
end );

InstallGlobalFunction(DoubleHashDictSize,
function( hash )
  local oldKeyArray, oldValueArray, i,j,l;

  #Print("Double from ",hash!.LengthArray,"\n");
  oldKeyArray := hash!.KeyArray;
  oldValueArray := hash!.ValueArray;
  # compact
  l:=Length(oldKeyArray);
  i:=1; # read
  j:=1; # write
  while i<=l do
    if oldKeyArray[i]<>fail then
      if i>j then
        oldKeyArray[j]:=oldKeyArray[i];
        oldValueArray[j]:=oldValueArray[i];
      fi;
      j:=j+1;
    fi;
    i:=i+1;
  od;
  for i in [l,l-1..j] do
    Unbind(oldKeyArray[i]);
    Unbind(oldValueArray[i]);
  od;

  hash!.LengthArray := NextPrimeInt(hash!.LengthArray * 2);
  hash!.LengthArrayHalf := QuoInt(hash!.LengthArray,2);
  hash!.KeyArray:=0; # old one away
  hash!.KeyArray := ListWithIdenticalEntries( hash!.LengthArray, fail );
  hash!.ValueArray := [];
  if IsHPCGAP then
    MigrateObj(hash!.KeyArray, hash);
    MigrateObj(hash!.ValueArray, hash);
  fi;
  hash!.NumberKeys := 0;
  l:=Length(oldKeyArray);
  if IsBound(hash!.intKeyFun) then
    for i in [l,l-1..1] do
      if oldKeyArray[i] <> fail then
        HashDictAddDictionary( hash, oldKeyArray[i], oldValueArray[i] );
      fi;
      Unbind(oldKeyArray[i]);
      Unbind(oldValueArray[i]);
    od;
  else
    for i in [l,l-1..1] do
      if oldKeyArray[i] <> fail then
        AddDictionary( hash, oldKeyArray[i], oldValueArray[i] );
      fi;
      Unbind(oldKeyArray[i]);
      Unbind(oldValueArray[i]);
    od;
  fi;
end );

#############################################################################
##
#M  AddDictionary(<dict>,<key>)
##
InstallOtherMethod(AddDictionary,"for hash tables, no value given",true,
  [IsHash and IsMutable,IsObject],0,
function(ht, x)
  AddDictionary(ht,x,true);
end);

#############################################################################
##
#M  KnowsDictionary(<dict>,<key>)
##
InstallMethod(KnowsDictionary,"for hash tables",true,
  [IsHash,IsObject],0,
function(ht,x)
  return LookupDictionary(ht,x)<>fail;
end);

############################################################################
##
#M  LookupDictionary(<dict>,<key>)
##
InstallMethod(LookupDictionary,"for hash tables that know their int key",true,
  [IsHash and IsSparseHashRep and TableHasIntKeyFun,IsObject],0,
function( hash, key )
local index,intkey,i;
  intkey := hash!.intKeyFun(key);
  for i in [0..hash!.ProbingDepth] do
    index:=HashClashFct(intkey,i,hash!.LengthArray);
    if hash!.KeyArray[index] = key then
      #LastHashIndex := index;
      return hash!.ValueArray[ index ];
    elif hash!.KeyArray[index] = fail then
      return fail;
    fi;
  od;
  # the entry could not have been added, as we would have found it by now
  return fail;
end );

############################################################################
##
#M  LookupDictionary(<dict>,<key>)
##
InstallMethod(LookupDictionary,"for hash tables",true,
  [IsHash and IsSparseHashRep,IsObject],0,
function( hash, key )
local index,intkey,i;
  intkey := SparseIntKey( false,key )(key);
  for i in [0..hash!.ProbingDepth] do
    index:=HashClashFct(intkey,i,hash!.LengthArray);
    if hash!.KeyArray[index] = key then
        #LastHashIndex := index;
        return hash!.ValueArray[ index ];
    elif hash!.KeyArray[index] = fail then
      return fail;
    fi;
  od;
  Error("hash table in infinite loop");
end );
