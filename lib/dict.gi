#############################################################################
##
#W  dict.gi                   GAP Library                      Gene Cooperman
#W                                                               Scott Murray
#W                                                           Alexander Hulpke
##
##
#Y  Copyright (C)  1999,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
  MakeImmutable(x); # to be able to store sortedness
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
#M  AddDictionary(<dict>,<obj>,<val>)
##
InstallOtherMethod(AddDictionary,"for lookup sort dictionaries",true,
        [IsSortLookupDictionary and IsMutable,IsObject,IsObject],0,
        function(d, x, val)
    local pair, p;
    pair:=[Immutable(x),val];
    MakeImmutable(pair); # to be able to store sortedness
    p := PositionFirstComponent(d!.entries,x);
    if p <= Length(d!.entries) and d!.entries[p][1] = x then
        d!.entries[p] := pair;
    else
        AddSet(d!.entries, pair);
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
    p:=PositionFirstComponent(d!.entries,x);
    return p <= Length(d!.entries) and d!.entries[p][1] = x;
end);

InstallMethod(KnowsDictionary,"for list dictionaries",true,
  [IsListDictionary,IsObject],0,
function(d,x)
local p;
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
  p:=PositionFirstComponent(d!.entries,x);
  if p > Length(d!.entries) or d!.entries[p][1] <> x then
    return fail;
  else
    return d!.entries[p][2];
  fi;
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
local p;
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
local hashfun,obj,dom,lookup;
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

  # are we given a domain, which can index very quickly?
  if dom<>fail and IsList(dom) and 
    (IsQuickPositionList(dom) or 
      (not IsMutable(dom) and IsSSortedList(dom) and
       CanEasilySortElements(dom[1]) )  )
       #2^22 plist (for position lookup) is 16MB size
      and Length(dom)<2^22 then
    Info(InfoHash,1,obj," Position dictionary");
    return DictionaryByPosition(dom,lookup);
  elif dom<>fail and IsFreeLeftModule(dom) and
    IsFFECollection(LeftActingDomain(dom)) and
    Size(LeftActingDomain(dom))<=256 
    #2^22 plist (for position lookup) is 16MB size
    and Size(dom)<2^22 then
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
  if CanEasilySortElements(obj) then
    Info(InfoHash,1,obj," Sort dictionary");
    return DictionaryBySort(lookup);
  fi;

  # Alas, we can't do anything. Go the hard way
  Info(InfoHash,1,obj," ",dom," List dictionary");
  return DictionaryByList(lookup);
end);

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
            Print("< dense hash table of size ", Size( hash ), " >");
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
DefaultHashLength := 2^7; 
BindGlobal("HASH_RANGE",[0..DefaultHashLength-2]);

#############################################################################
##
#F  SparseHashTable( )
##
InstallGlobalFunction( SparseHashTable, 
function(arg)
      local Rec,T;

  Rec := rec( KeyArray := ListWithIdenticalEntries( DefaultHashLength, fail ), 
          ValueArray := [], LengthArray := DefaultHashLength, NumberKeys := 0 );
    
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
            Print("< sparse hash table of size ", Size( hash ), " >");
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
        local key;
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
            i := Random( [1..hash!.LengthArray] );
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


# old obsolete code
# #############################################################################
# ##
# #M  GetHashEntryAtLastIndex( <hash> )
# ##
# InstallMethod( GetHashEntryAtLastIndex, "for hash table", true,
#     [ IsHash ], 0, 
#     function( hash )
#         if IsBound( hash!.ValueArray[ LastHashIndex ] ) then
#             return( hash!.ValueArray[ LastHashIndex ] );
#       else 
#           return fail;
#       fi;
#     end );
# 
# #############################################################################
# ##
# #M  SetHashEntry( <hash>, <key>, <value> )
# ##
# InstallMethod( SetHashEntry, "for hash table", true,
#     [ IsHash and IsMutable, IsObject, IsObject ], 0,
# function( hash, intkey, value )
# local index, i;
#   for i in HASH_RANGE do
#     index := IntegerHashFunction( intkey, i, hash!.LengthArray );
#     if hash!.KeyArray[index] = fail then
#       hash!.ValueArray[ LastHashIndex ] := value;
#       return value;
#     fi;
#   od;
#   Error("hash table in infinite loop");
# end );
# 
# #############################################################################
# ##
# #M  SetHashEntryAtLastIndex( <hash>, <newValue> )
# ##
# InstallMethod( SetHashEntryAtLastIndex, "for hash table", true,
#     [ IsHash and IsMutable, IsObject ], 0, 
#     function( hash, newvalue )
#       hash!.ValueArray[ LastHashIndex ] := newvalue;
#         return newvalue;
#     end );

# dictionary type interface for hash tables. As we want these to be really
# fast, the code has been stripped down.

#MAXCLASH:=0;

#############################################################################
##
#M  AddDictionary(<dict>,<key>,<val>)
##
BindGlobal("HashDictAddDictionary",function(hash,key,value)
local index,intkey,i,cnt;
  intkey := hash!.intKeyFun(key);
#  cnt:=0;
  repeat
    for i in HASH_RANGE do
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
    #Error("Failed/double ",intkey," ",key," ",Maximum(HASH_RANGE),"\n");
    MakeReadWriteGlobal("HASH_RANGE");
    HASH_RANGE:=[1..2*Maximum(HASH_RANGE)];
    MakeReadOnlyGlobal("HASH_RANGE");
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
  for i in HASH_RANGE do
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
local index,intkey,i,cnt;
  intkey := hash!.intKeyFun(key);
  for i in HASH_RANGE do
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
  for i in HASH_RANGE do
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

#
# some hash functions
#

#############################################################################
##
#M  DenseIntKey(<objcol>)
##
InstallMethod(DenseIntKey,"default fail",true,[IsObject,IsObject],
  0,ReturnFail);

InstallMethod(SparseIntKey,"defaults to DenseIntKey",true,[IsObject,IsObject],
  0,DenseIntKey);

InstallMethod(SparseIntKey,"for finite Gaussian row spaces",true,
    [ IsFFECollColl and IsGaussianRowSpace,IsObject ], 0,
function(m,v)
local f,n,bytelen,data,qq,i;
  f:=LeftActingDomain(m);
  n:=Size(f);
  if n=2 then
    bytelen:=QuoInt(Length(v),8);
    if bytelen<=8 then
      # short GF2
      return x->NumberFFVector(x,2);
    else
      # long GF2
      data:=[2*GAPInfo.BytesPerVariable,bytelen];
      return function(x)
             if not IsGF2VectorRep(x) then
                 Info(InfoWarning,1,"uncompressed vector");
                 x:=ShallowCopy(x);
                 ConvertToGF2VectorRep(x);
               fi;
               return HASHKEY_BAG(x,101,data[1],data[2]);
             end;
    fi;
  elif n < 256 then
    qq:=n; # log
    i:=0;
    while qq<=256 do
        qq:=qq*n;
        i:=i+1;
    od;
    # i is now the number of field elements per byte
    bytelen := QuoInt(Length(v),i);
    if bytelen<=8 then
      # short 8-bit
      return x->NumberFFVector(x,n);
    else
      # long 8 bit
      data:=[3*GAPInfo.BytesPerVariable,bytelen];
      return x->HASHKEY_BAG(x,101,data[1],data[2]);
      return function(x)
             if not Is8BitVectorRep(x) then
                 Info(InfoWarning,1,"uncompressed vector");
                 x:=ShallowCopy(x);
                 ConvertToVectorRep(x,n);
               fi;
               return HASHKEY_BAG(x,101,data[1],data[2]);
             end;

    fi;
  else
    # large field -- vector represented as plist.
    f:=AsSSortedList(f);
    return function(v)
           local x,sy,p;
              sy := 0;
              for x in v do
                p := Position(f, x);
# want to be quick: Assume no failures
#               if p = fail then
#                   Error("NumberFFVector: Vector not over specified field");
#               fi;
                sy := n*sy + (p-1);
              od;
            return sy;
           end;
  fi;
end);

SparseIntKeyVecListAndMatrix:=function(d,m)
local f,n,pow,fct;
  if IsList(d) and Length(d)>0 and IsMatrix(d[1]) then
    f:=FieldOfMatrixList(d);
  else
    f:=FieldOfMatrixList([m]);
  fi;

  fct:=SparseIntKey(f^Length(m[1]),m[1]);

  n:=Minimum(Size(f),11)^Minimum(12,QuoInt(Length(m[1]),2));
  #pow:=n^Length(m[1]);
  pow:=NextPrimeInt(n); # otherwise we produce huge numbers which take time
  return function(x)
          local i,gsy;
            gsy:=0;
            for i in x do
              gsy:=pow*gsy+fct(i);
            od;
            return gsy;
          end;
end;

InstallMethod(SparseIntKey,"for lists of vectors",true,
    [ IsFFECollColl,IsObject ], 0,
function(m,v)
local f,n;
if not (IsList(m) and IS_PLIST_REP(m) and ForAll(m,i->IsRowVector(i))) then
    TryNextMethod();
  fi;
  f:=DefaultFieldOfMatrix(m);
  return SparseIntKey(f^Length(v),v);
end);

InstallMethod(SparseIntKey,
  "for matrices over finite field vector spaces",true,
  [IsObject,IsFFECollColl and IsMatrix],0,
SparseIntKeyVecListAndMatrix);

InstallMethod(SparseIntKey,
  "for vector listsover finite field vector spaces",true,
  [IsObject,IsFFECollColl and IsList],0,
SparseIntKeyVecListAndMatrix);

#############################################################################
##
#M  SparseIntKey( <dom>, <key> ) for row spaces over finite fields
##
InstallMethod( SparseIntKey, "for row spaces over finite fields", true,
    [ IsObject,IsVectorSpace and IsRowSpace], 0,
function( key, dom )
  return function(key)
    local sz, n, ret, k,d;

    d:=LeftActingDomain( key );
    sz := Size(d);
    key := BasisVectors( CanonicalBasis( key ) );
    n := sz ^ Length( key[1] );
    ret := 1;
    for k in key do
        ret := ret * n + NumberFFVector( k, sz );
    od;
    return ret;
  end;
end );


InstallMethod(DenseIntKey,"integers",true,
  [IsObject,IsPosInt],0,
function(d,i)
  #T this function might cause problems if there are nonpositive integers
  #T used densly.
  return IdFunc;
end);

InstallMethod(SparseIntKey,"permutations, arbitrary domain",true,
  [IsObject,IsInternalRep and IsPerm],0,
function(d,pe)
  return function(p)
         local l;
           l:=LARGEST_MOVED_POINT_PERM(p);
           if IsPerm4Rep(p) then
             # is it a proper 4byte perm?
             if l>65536 then
               return HashKeyBag(p,255,0,4*l);
             else
               # the permutation does not require 4 bytes. Trim in two
               # byte representation (we need to do this to get consistent
               # hash keys, regardless of representation.)
               TRIM_PERM(p,l);
             fi;
            fi;
            # now we have a Perm2Rep:
            return HashKeyBag(p,255,0,2*l);
          end;
end);

#T Still to do: Permutation values based on base images: Method if the
#T domain given is a permgroup.

InstallMethod(SparseIntKey,"kernel pc group elements",true,
  [IsObject,
    IsElementFinitePolycyclicGroup and IsDataObjectRep and IsNBitsPcWordRep],0,
function(d,e)
local l,p;
  # we want to use an small shift to avoid cancellation due to similar bit
  # patterns in many bytes (the exponent values in most cases are very
  # small). The pcgs length is a reasonable small value-- otherwise we get
  # already overlap for the generators alone.
  p:=FamilyObj(e)!.DefiningPcgs;
  l:=NextPrimeInt(Length(p)+1);
  p:=Product(RelativeOrders(p));
  while Gcd(l,p)>1 do
    l:=NextPrimeInt(l);
  od;
  return e->HashKeyBag(e,l,DOUBLE_OBJLEN,-1);
end);

InstallMethod(SparseIntKey,"pcgs element lists: i.e. pcgs",true,
  [IsObject,IsElementFinitePolycyclicGroupCollection and IsList],0,
function(d,p)
local o,e;

  if IsPcgs(p) then
    o:=OneOfPcgs(p);
  else
    o:=One(p[1]);
  fi;

  e:=SparseIntKey(false,o); # element hash fun
  o:=DefiningPcgs(FamilyObj(o));
  o:=Product(RelativeOrders(o)); # order of group
  return function(x)
         local i,h;
           h:=0;
           for i in x do
             h:=h*o+e(i);
           od;
           return h;
         end;
end);

InstallMethod(SparseIntKey,"transformations, arbitrary domain",true,
  [IsObject,IsTransformationRep],0,
function(d,t)
local n,l;
  n:=DegreeOfTransformation(t);
  l:=List([1..n],i->n^(i-1));
  return x->x![1]*l;
end);

