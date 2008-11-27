#############################################################################
##
#W  dict.gi                   GAP Library                      Gene Cooperman
#W							         Scott Murray
#W                                                           Alexander Hulpke
##
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementations for dictionaries.
##
Revision.dict_gi :=
    "@(#)$Id$";

##
## List and Sort dictionaries
##

InstallMethod( PositionFirstComponentDict,"for dense list", true,
    [ IsDenseList, IsObject ], 0,
function ( list, obj )
local i;
  i:=1;
  while i<=Length(list) do
    if list[i][1]=obj then
      return i;
    fi;
    i:=i+1;
  od;
  return fail;
end);

InstallMethod( PositionFirstComponentDict,"for sorted list", true,
    [ IsSSortedList, IsObject ], 0,
function ( list, obj )
local lo,up,s;
  # simple binary search. The entry is in the range [lo..up]
  lo:=1;
  up:=Length(list);
  if up = 0 then 
    return fail; # empty list
  fi;
  while lo<up do
    s:=Int((up+lo)/2);# middle entry
    if list[s][1]<obj then
      lo:=s+1; # it's not in [lo..s], so take the upper part.
    else
      up:=s; # So obj<=list[s][1], so the new range is [1..s].
    fi;
  od;
  # now lo=up, unless lo=1, up=0 (fixed by Laurent Bartholdi)
  if lo=up and list[lo][1]=obj then
    return lo;
  else
    return fail;
  fi;
end );

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
  Objectify(NewType(DictionariesFamily,rep),d);
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
  Objectify(NewType(DictionariesFamily,rep),d);
  return d;
end);

#############################################################################
##
#M  AddDictionary(<dict>,<obj>,<val>)
##
InstallOtherMethod(AddDictionary,"for lookup list dictionaries",true,
  [IsListLookupDictionary,IsObject,IsObject],0,
function(d, x, val)
  x:=[Immutable(x),val];
  MakeImmutable(x); # to be able to store sortedness
  Add(d!.entries,x);
end);

InstallMethod(AddDictionary,"for list dictionaries",true,
  [IsListDictionary,IsObject],0,
function(d, x)
  x:=Immutable(x); # to be able to store sortedness
  Add(d!.list,x);
end);

#############################################################################
##
#M  AddDictionary(<dict>,<obj>,<val>)
##
InstallOtherMethod(AddDictionary,"for lookup sort dictionaries",true,
  [IsSortLookupDictionary,IsObject,IsObject],0,
function(d, x, val)
  x:=[Immutable(x),val];
  MakeImmutable(x); # to be able to store sortedness
  AddSet(d!.entries,x);
end);

InstallMethod(AddDictionary,"for sort dictionaries",true,
  [IsSortDictionary,IsObject],0,
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
  p:=PositionFirstComponentDict(d!.entries,x);
  return p<>fail;
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
  p:=PositionFirstComponentDict(d!.entries,x);
  if p=fail then
    return p;
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
  Objectify(NewType(DictionariesFamily,rep),d);
  return d;
end);

#############################################################################
##
#M  AddDictionary(<dict>,<obj>,<val>)
##
InstallOtherMethod(AddDictionary,"for lookup position dictionaries",true,
  [IsPositionLookupDictionary,IsObject,IsObject],0,
function(d, x, val)
  x:=PositionCanonical(d!.domain,x);
  d!.blist[x]:=true;
  d!.vals[x]:=val;
end);

InstallMethod(AddDictionary,"for position dictionaries",true,
  [IsPositionDictionary,IsObject],0,
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
  if dom<>fail and 
    (IsQuickPositionList(dom) or 
      (not IsMutable(dom) and IsSSortedList(dom) and
       CanEasilySortElements(dom[1]) )  )
      and Length(dom)<2^17 then
    Info(InfoHash,1,obj," Position dictionary");
    return DictionaryByPosition(dom,lookup);
  fi;

  # can we try hashing? Only if domain is given and not for small perms.
  if dom<>fail and (not IsPerm(obj) or NrMovedPoints(obj)>100000) then
    hashfun:=SparseIntKey(dom,obj);
  else
    hashfun:=fail;
  fi;

  if hashfun<>fail then
    Info(InfoHash,1,obj," Hash dictionary");
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

	Type := NewType( DictionariesFamily, IsDenseHashRep );
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
#M	for dense hash tables
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
#M  GetHashEntry( <hash>, <key> ) for dense hash tables
##
InstallMethod( GetHashEntry, "for dense hash tables", true,
    [ IsHash and IsDenseHashRep, IsObject and IsInt ], 0,
    function( hash, key )
	local valueArray;
	valueArray := hash!.ValueArray;
	if TableHasIntKeyFun(hash) then
	    LastHashIndex := hash!.intKeyFun(key);
        # For efficiency:  KeyInt(key) too costly when KeyInt := x->x;
	# Note this makes it impossible to hash nonpositive integers.
        elif IsInt(key) then LastHashIndex := key;
        else
	    Info( InfoHash, 5, "Keys: ", hash!.KeyArray,
                  "\nValues: ", hash!.ValueArray );
            LastHashIndex := DenseIntKey( false,key )(key);
        fi;
	if IsBound(valueArray[ LastHashIndex ]) then
	    return valueArray[ LastHashIndex ];
	else
	    return fail;
	fi;
    end );

#############################################################################
##
#M  AddHashEntry( <hash>, <key>, <value> ) for dense hash tables
##
InstallMethod( AddHashEntry, "for dense hash tables", true,
    [ IsHash and IsDenseHashRep, IsObject and IsInt, IsObject ], 0,
    function( hash, key, value )
	local valueArray, keyArray;
	valueArray := hash!.ValueArray;
	keyArray := hash!.KeyArray;
	if TableHasIntKeyFun(hash) then
	  LastHashIndex := hash!.intKeyFun(key);
	else
	  LastHashIndex := DenseIntKey( false,key )(key);
	fi;
	if not IsBound( valueArray[ LastHashIndex ] ) then
	    Add( keyArray, key );
	    valueArray[  LastHashIndex ] := value; #list with holes
# changing attributes is verboten.
#            if HasSize(hash) then SetSize(hash, Size(hash)+1); fi;
	    Info( InfoHash, 2, "key hashed to ", LastHashIndex );
            return value;
	else 
	    Info( InfoHash, 2, "key already in hash table" );
	    return fail;
	fi;
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
  T!.LengthArrayHalf := Int(T!.LengthArray / 2);

  return T;
end );

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
##	for sparse hash table
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
#F  GetHashEntryIndex( <hash>, <key> ) for sparse hash table
##
# do not create this range anew again and again.
BindGlobal("HASH_RANGE",[0..10000]);
InstallGlobalFunction( GetHashEntryIndex,
    function( hash, key )
	local intkey, i, index;
	if TableHasIntKeyFun(hash) then
	  intkey := hash!.intKeyFun(key);
	else
	  intkey := SparseIntKey( false,key )(key);
	fi;
        for i in HASH_RANGE do
	    Info( InfoHash, 3, "Getting hash entry index for ", key, ", i = ", i );
            index := HashFunct( intkey, i, hash!.LengthArray );
            #USED FOR DEBUGGING:
            # if keyArray[index] = fail then INDEX := index; 
            #   KEYARRAY := keyArray; fi;
            if hash!.KeyArray[index] = fail or hash!.KeyArray[index] = key then 
                LastHashIndex := index;
		return index;
            fi;
	od;
        Error("hash table in infinite loop");
    end );

#############################################################################
##
#M  GetHashEntry( <hash>, <key> ) for sparse hash table
##
InstallMethod( GetHashEntry, "for sparse hash tables", true,
    [ IsHash and IsSparseHashRep, IsObject ], 0,
    function( hash, key )
        local index, keyArray, valueArray;
	index := GetHashEntryIndex( hash, key );
	if hash!.KeyArray[index] = fail then
	    return fail;
	fi;
	Info( InfoHash, 5, "Keys: ", hash!.KeyArray, "\nValues: ", hash!.ValueArray );
	return hash!.ValueArray[ index ]; 
    end );

#############################################################################
##
#F  DoubleHashArraySize( <hash> )
##
InstallGlobalFunction( DoubleHashArraySize,
    function( hash )
	local oldKeyArray, oldValueArray, i;
	Info( InfoHash, 2, "Doubling hash array size" );
       	oldKeyArray := hash!.KeyArray;
        oldValueArray := hash!.ValueArray;
        hash!.LengthArray := hash!.LengthArray * 2;
	hash!.LengthArrayHalf := Int(hash!.LengthArray / 2);
        hash!.KeyArray := ListWithIdenticalEntries( hash!.LengthArray, fail );
        hash!.ValueArray := [];
        hash!.NumberKeys := 0;
        for i in [1..Length(oldKeyArray)] do
            if oldKeyArray[i] <> fail then
            	AddHashEntry( hash, oldKeyArray[i], oldValueArray[i] );
 	    fi;
        od;
    end );

#############################################################################
##
#M  AddHashEntry( <hash>, <key>, <value> ) for sparse hash tables
##
InstallMethod( AddHashEntry, "for sparse hash tables", true,
    [ IsHash and IsSparseHashRep, IsObject, IsObject ], 0,
    function( hash, key, value )
	local index;
	index := GetHashEntryIndex( hash, key );
        if hash!.KeyArray[ index ] = fail then
            hash!.KeyArray[ index ] := key;
            hash!.ValueArray[ index ] := value;
            hash!.NumberKeys := hash!.NumberKeys + 1;
            if 2 * hash!.NumberKeys > Length( hash!.KeyArray ) then
                DoubleHashArraySize( hash );
            fi;

# changing attributes is verboten.
#            if HasSize( hash ) then 
#		hash!.Size := hash!.NumberKeys;
#		SetSize( hash, Size( hash ) + 1); 
#		if Size(hash) <> hash!.NumberKeys then Error("size"); fi;
#	    fi;

	    Info( InfoHash, 2, "key hashed to ", index );
	    
            return value;
        else 
	    Info( InfoHash, 2, "key already in hash table" );
	    return fail;
	fi;
    end );

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
#F  HashFunct( <key>, <i>, <size> )
##
InstallGlobalFunction( HashFunct,
    function( key, i, size )
        # return ( (1+key) + i*(1+2*(key mod size/2)) ) mod size;
        return 1 + ( key + i * (1 + (key mod 2) + (key mod size)) ) mod size;	
    end );


#############################################################################
#############################################################################
##
##  Fast access to last hash index
##
#############################################################################
#############################################################################

#############################################################################
##
#M  GetHashEntryAtLastIndex( <hash> )
##
InstallMethod( GetHashEntryAtLastIndex, "for hash table", true,
    [ IsHash ], 0, 
    function( hash )
        if IsBound( hash!.ValueArray[ LastHashIndex ] ) then
            return( hash!.ValueArray[ LastHashIndex ] );
    	else 
	    return fail;
    	fi;
    end );

#############################################################################
##
#M  SetHashEntryAtLastIndex( <hash>, <newValue> )
##
InstallMethod( SetHashEntryAtLastIndex, "for hash table", true,
    [ IsHash, IsObject ], 0, 
    function( hash, newvalue )
	hash!.ValueArray[ LastHashIndex ] := newvalue;
        return newvalue;
    end );

#############################################################################
##
#M  SetHashEntry( <hash>, <key>, <value> )
##
InstallMethod( SetHashEntry, "for hash table", true,
    [ IsHash, IsObject, IsObject ], 0,
    function( hash, key, value )
	GetHashEntry( hash, key ); #can be fail; sets LastHashIndex
        SetHashEntryAtLastIndex( hash, value );
        return value;
    end );

# dictionary type interface for hash tables. As we want to be these really
# fast, we permit to duplicate code...

#############################################################################
##
#M  AddDictionary(<dict>,<key>,<val>)
##
BindGlobal("HashDictAddDictionary",function(hash,key,value)
local index,intkey,i;
  intkey := hash!.intKeyFun(key);
  for i in HASH_RANGE do
    index := HashFunct( intkey, i, hash!.LengthArray );
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

InstallOtherMethod(AddDictionary,"for hash tables",true,
  [IsHash and IsSparseHashRep and TableHasIntKeyFun,
   IsObject,IsObject],0,HashDictAddDictionary);

# this is almost a copy of `DoubleHashArraySize', however we call the
# (faster) dictionary methods.
InstallGlobalFunction(DoubleHashDictSize,
function( hash )
  local oldKeyArray, oldValueArray, i,j,l;
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

  hash!.LengthArray := hash!.LengthArray * 2;
  hash!.LengthArrayHalf := Int(hash!.LengthArray / 2);
  hash!.KeyArray := ListWithIdenticalEntries( hash!.LengthArray, fail );
  hash!.ValueArray := [];
  hash!.NumberKeys := 0;
  l:=Length(oldKeyArray);
  for i in [l,l-1..1] do
    if oldKeyArray[i] <> fail then
      HashDictAddDictionary( hash, oldKeyArray[i], oldValueArray[i] );
      Unbind(oldKeyArray[i]);
      Unbind(oldValueArray[i]);
    fi;
  od;
end );

#############################################################################
##
#M  AddDictionary(<dict>,<key>)
##
InstallOtherMethod(AddDictionary,"for hash tables, no value given",true,
  [IsHash,IsObject],0,
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
InstallMethod(LookupDictionary,"for hash tables",true,
  [IsHash and IsSparseHashRep and TableHasIntKeyFun,IsObject],0,
function( hash, key )
local index,intkey,i;
  intkey := hash!.intKeyFun(key);
  for i in HASH_RANGE do
    index := HashFunct( intkey, i, hash!.LengthArray );
    if hash!.KeyArray[index] = key then
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

InstallMethod(DenseIntKey,"for finite Gaussian row spaces",true,
    [ IsFFECollColl and IsGaussianRowSpace,IsObject ], 0,
function(m,v)
local f,n;
  f:=LeftActingDomain(m);
  n:=Size(f);
  if n < 256 then
    return x->NumberFFVector(x,n);
  else
    f:=AsSSortedList(f);
    return function(v)
	   local x,sy,p;
	      sy := 0;
	      for x in v do
		p := Position(f, x);
# want to be quick: Assume no failures
#		if p = fail then
#		    Error("NumberFFVector: Vector not over specified field");
#		fi;
		sy := n*sy + (p-1);
	      od;
	    return sy;
           end;
  fi;
end);

InstallMethod(DenseIntKey,"for lists of vectors",true,
    [ IsFFECollColl,IsObject ], 0,
function(m,v)
local f,n;
  if not IsList(m) and ForAll(m,i->IsRowVector(i)) then
    TryNextMethod();
  fi;
  f:=DefaultFieldOfMatrix(m);
  return DenseIntKey(f^Length(v),v);
end);

InstallMethod(DenseIntKey,
  "for matrices over finite field vector spaces",true,
  [IsObject,IsFFECollColl and IsMatrix],0,
function(d,m)
local f,n,pow;
  if IsList(d) and Length(d)>0 and IsMatrix(d[1]) then
    f:=FieldOfMatrixList(d);
  else
    f:=FieldOfMatrixList([m]);
  fi;

  n:=Size(f);
  pow:=n^Length(m[1]);
  if Size(f)<256 then
    return function(x)
	   local i,gsy;
	     gsy:=0;
	     for i in x do
	       gsy:=pow*gsy+NumberFFVector(i,n);
	     od;
	     return gsy;
           end;
  else
    f:=AsSSortedList(f);
    return function(ma)
	   local x,y,sy,gsy,p;
	      gsy:=0;
	      for y in ma do
		sy := 0;
		for x in y do
		  p := Position(f, x);
# want to be quick: Assume no failures
#		if p = fail then
#		    Error("NumberFFVector: Vector not over specified field");
#		fi;
		  sy := n*sy + (p-1);
		od;
		gsy := pow*gsy + sy;
	      od;
	      return gsy;
           end;
  fi;
end);

InstallMethod(SparseIntKey,
  "for matrices over finite field vector spaces",true,
  [IsObject,IsFFECollColl and IsMatrix],0,
function(d,m)
local f,n,pow;
  if IsList(d) and Length(d)>0 and IsMatrix(d[1]) then
    f:=FieldOfMatrixList(d);
  else
    f:=FieldOfMatrixList([m]);
  fi;

  n:=Size(f);
  pow:=NextPrimeInt(n); # otherwise we produce big numbers which take time
			# and can produce very bad results when hashing.
  if Size(f)<256 then
    return function(x)
	   local i,gsy;
	     gsy:=0;
	     for i in x do
	       gsy:=pow*gsy+NumberFFVector(i,n);
	     od;
	     return gsy;
           end;
  else
    f:=AsSSortedList(f);
    return function(ma)
	   local x,y,sy,gsy,p;
	      gsy:=0;
	      for y in ma do
		sy := 0;
		for x in y do
		  p := Position(f, x);
# want to be quick: Assume no failures
#		if p = fail then
#		    Error("NumberFFVector: Vector not over specified field");
#		fi;
		  sy := n*sy + (p-1);
		od;
		gsy := pow*gsy + sy;
	      od;
	      return gsy;
           end;
  fi;
end);

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
local l;
  # we want to use an small shift to avoid cancellation due to similar bit
  # patterns in many bytes (the exponent values in most cases are very
  # small). The pcgs length is a reasonable small value-- otherwise we get
  # already overlap for the generators alone.
  l:=Length(FamilyObj(e)!.DefiningPcgs)+1;
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

InstallMethod(DenseIntKey,"transformations, arbitrary domain",true,
  [IsObject,IsTransformationRep],0,
function(d,t)
local n,l;
  n:=DegreeOfTransformation(t);
  l:=List([1..n],i->n^(i-1));
  return x->x![1]*l;
end);

#E
