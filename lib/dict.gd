#############################################################################
##
#W  dict.gd			GAP Library		       Gene Cooperman
#W							         Scott Murray
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for dictionaries and for improved
##  hash tables.
##
##  In the hash tables, we hash by keys and also store a value.  Keys 
##  cannot be removed from the table, but the corresponding value can be 
##  changed.  Fast access to last hash index allows you to efficiently store 
##  more than one array of values -- this facility should be used with care.
##
##  This code works for any kind of object, provided you have a KeyIntDense 
##  or KeyIntSparse method to convert the key into a positive integer.  
##  These methods should ideally be implemented efficiently in the core.
##
##  Note that, for efficiency, it is currently impossible to create a 
##  hash table with non-positive integers.
##
##  Requires: nothing
##  Exports: 
##     	Category IsHash.
##     	Representations IsDenseHashRep and IsSparseHashRep.  
##     	Operations PrintHashWithNames, Iterator, GetHashEntry, AddHashEntry,
##     	  GetHashEntryAtLastIndex, SetHashEntryAtLastIndex, SetHashEntry, 
##	  [AddHashEntryAtLastIndex], HashFunct, KeyIntDense, KeyIntSparse.
##	Functions DenseHash, SparseHash.
##	Variables MaxViewSize, LastHashIndex.
##
Revision.dict_gd :=
    "@(#)$Id$";

#############################################################################
##
#I  InfoHash
##
DeclareInfoClass( "InfoHash" );

#############################################################################
##
#O  PositionFirstComponent(<list>,<obj>)
##
##  returns the index <i> in <list> such that $<list>[<i>][1]=<obj>$ and
##  `fail' if no such entry exists.
DeclareOperation("PositionFirstComponent",[IsList,IsObject]);

#############################################################################
##
#C  IsDictionary(<obj>)
##
##  A dictionary is a growable collection of objects that permits to add
##  objects (with associated values) and to check whether an object is
##  already known.
DeclareCategory("IsDictionary",IsCollection);

#############################################################################
##
#C  IsLookupDictionary(<obj>)
##
##  A *lookup dictionary* is a dictionary, which permits not only to check
##  whether an object is contained, but also to retrieve associated values,
##  using the operation `LookupDictionary'.
##
DeclareCategory("IsLookupDictionary",IsDictionary);

#############################################################################
##
#C  IsHash(<obj>)
##
##  The category of hash tables for arbitrary objects (provided an `IntKey'
##  function 
##  is defined).
##
DeclareCategory( "IsHash", IsLookupDictionary );  

#1
##  There are several ways how dictionaries are implemented: As lists, as
##  sorted lists, as hash tables or via binary lists. A user however will
##  just have to call `NewDictionary' and obtain a ``suitable'' dictionary
##  for the kind of objects she wants to create. It is possible however to
##  create hash tables (see~"General hash table definitions and operations")
##  and dictionaries using binary lists (see~"DictionaryByPosition").

#############################################################################
##
#F  NewDictionary(<obj>,<look>[,<objcoll>])
##
##  creates a new dictionary for objects such as <obj>. If <objcoll> is
##  given the dictionary will be for objects only from this collection,
##  knowing this can improve the performance. If <objcoll> is given, <obj>
##  may be replaced by `false', i.e. no sample object is needed.
##
##  The function tries to find the right kind of dictionary for the basic
##  dictionary functions to be quick.
##  If <look> is `true', the dictionary will be a lookup dictionary,
##  otherwise it is an ordinary dictionary.
DeclareGlobalFunction("NewDictionary");

#2
##  The use of two objects, <obj> and <objcoll> to parametrize the objects a
##  dictionary is able to store might look confusing. However there are
##  situations where either of them might be needed:
##
##  The first situation is that of objects, for which no formal ``collection
##  object'' has been defined. A typical example here might be subspaces of
##  a vector space. {\GAP} does not formally define a ``Grassmannian'' or
##  anything else to represent the multitude of all subspaces. So it is only
##  possible to give the dictionary a ``sample object''.
##
##  The other situation is that of an object which might represent quite
##  varied domains. The permutation $(1,10^6)$ might be the nontrivial
##  element of a cyclic group of order 2, it might be a representative of
##  $S_{10^6}$. In the first situation the best approach might be just to
##  have two entries for the two possible objects, in the second situation a
##  much more elaborate approach might be needed.
##
##  An algorithm that creates a dictionary will usually know a priori, from what
##  domain all the objects will be, giving this domain permits to use a more
##  efficient dictionary.
##
##  This is particularly true for vectors. From a single vector one cannot
##  decide whether a calculation will take place over the smallest field
##  containing all its entries or over a larger field.


#############################################################################
##
#F  DictionaryByPosition(<list>,<lookup>)
##
##  creates a new (lookup) dictionary which uses `PositionCanonical' in
##  <list> for indexing. The dictionary will have an entry `<dict>!.blist'
##  which is a bit list corresponding to <list> indicating the known
##  If <look> is `true', the dictionary will be a lookup dictionary,
##  otherwise it is an ordinary dictionary.
DeclareGlobalFunction("DictionaryByPosition");

#############################################################################
##
#V  DictionariesFamily
##
##  Is the family of all dictionaries.
BindGlobal("DictionariesFamily",NewFamily( "DictionariesFamily",IsDictionary));

#############################################################################
##
#O  KnowsDictionary(<dict>,<key>)
##
##  checks, whether <key> is known to the dictionary <dict>, and returns
##  `true' or `false' accordingly. <key> *must* be an object of the kind for
##  which the dictionary was specified, otherwise the results are
##  unpredictable.
DeclareOperation("KnowsDictionary",[IsDictionary,IsObject]);

#############################################################################
##
#O  AddDictionary(<dict>,<key>)
#O  AddDictionary(<dict>,<key>,<val>)
##
##  adds <key> to the dictionary <dict>, storing the associated value <val>
##  in case <dict> is a lookup dictionary. (If another value had been stored
##  already, it is overwritten.) <key> *must* be an object of the kind for
##  which the dictionary was specified, otherwise the results are
##  unpredictable.
DeclareOperation("AddDictionary",[IsDictionary,IsObject]);

#############################################################################
##
#O  LookupDictionary(<dict>,<key>)
##
##  looks up <key> in the lookup dictionary <dict> and returns the
##  associated value. If <key> is not knwon to the dictionary, `fail' is
##  returned.
DeclareOperation("LookupDictionary",[IsDictionary,IsObject]);

IsDictionaryDefaultRep:=NewRepresentation("IsDictionaryDefaultRep",
  IsDictionary and IsComponentObjectRep,[]);

#############################################################################
##
#R  IsListDictionary(<obj>)
#R  IsListLookupDictionary(<obj>)
##
##  A list dictionary uses a simple (unsorted) list and searching internally.
IsListDictionary:=NewRepresentation("IsListDictionary",IsDictionaryDefaultRep,
  ["entries"] );
IsListLookupDictionary:=NewRepresentation("IsListLookupDictionary",
  IsListDictionary and IsLookupDictionary,
  ["entries"] );

#############################################################################
##
#R  IsSortDictionary(<obj>)
#R  IsSortLookupDictionary(<obj>)
##
##  A sort dictionary uses a sorted list internally.
IsSortDictionary:=NewRepresentation("IsSortDictionary",IsListDictionary,
  ["entries"] );
IsSortLookupDictionary:=NewRepresentation("IsSortLookupDictionary",
  IsSortDictionary and IsListLookupDictionary and IsLookupDictionary,
  ["entries"] );

#############################################################################
##
#R  IsPositionDictionary(<obj>)
#R  IsPositionLookupDictionary(<obj>)
##
##  A hash dictionary uses `PositionCanonical' in a list internally.
IsPositionDictionary:=NewRepresentation("IsPositionDictionary",
  IsDictionaryDefaultRep,["domain","blist"] );
IsPositionLookupDictionary:=NewRepresentation("IsPositionDictionary",
  IsPositionDictionary and IsLookupDictionary,
  ["domain","blist","vals"] );

#############################################################################
#############################################################################
##
##  General hash table definitions and operations
##
#############################################################################
#############################################################################

#############################################################################
##
#O  PrintHashWithNames( <hash>, <keyName>, <valueName> )
##
##  Print a hash table with the given names for the keys and values.
##
DeclareOperation( "PrintHashWithNames", [ IsHash, IsString, IsString ] );

#############################################################################
##
#O  GetHashEntry( <hash>, <key> )
##
##  If the key is in hash, return the corresponding value.  Otherwise
##  return fail.  Note that it is not a good idea to use fail as a value.
##
DeclareOperation( "GetHashEntry", [ IsHash, IsObject ] );

#############################################################################
##
#O  AddHashEntry( <hash>, <key>, <value> )
##
##  Add the key and value to the hash table.
##
DeclareOperation( "AddHashEntry", [ IsHash, IsObject, IsObject ] );

#############################################################################
##
#O  RandomHashKey( <hash> )
##
##  Return a random Key from the hash table (Random returns a random value).
##
DeclareOperation( "RandomHashKey", [ IsHash ] );

#############################################################################
##
#O  HashKeyEnumerator( <hash> )
##
##  Enumerates the keys of the hash table (Enumerator enumerates values).
##
DeclareOperation( "HashKeyEnumerator", [ IsHash ] );

#############################################################################
##
#P  TableHasIntKeyFun(<hash>)
##
##  If this filter is set, the hash table has an `IntKey' function in its
##  component `<hash>!.intKeyFun'.
##
DeclareFilter( "TableHasIntKeyFun" );


#############################################################################
#############################################################################
##
##  Dense hash tables
##
##  Used for hashing dense sets without collisions, in particular integers.
##  Stores keys as an unordered list and values as an 
##  array with holes.  The position of a value is given by
##  KeyIntDense of the key, and so KeyIntDense must be one-to-one.  
##
#############################################################################
#############################################################################

#############################################################################
##
#R  IsDenseHashRep
##
##  The dense representation for hash tables.
##
DeclareRepresentation( "IsDenseHashRep",
    # as we will call `Enumerator' to get the *current* value list, a hash
    # table may not be attribute storing.
    IsComponentObjectRep and IsHash,
    ["KeyArray", "ValueArray"] );

#############################################################################
##
#F  DenseHashTable( )
##
##  Construct an empty dense hash table.  This is the only correct way to
##  construct such a table.
##
DeclareGlobalFunction( "DenseHashTable", [] );


#############################################################################
#############################################################################
##
##  Sparse hash tables
##
##  Used for hashing sparse sets.  Stores keys as an array with fail 
##  denoting an empty position, stores values as an array with holes.
##  Uses HashFunct applied to KeyInt of the key.  DefaultHashLength 
##  is the default starting hash table length; the table is doubled 
##  when it becomes half full.
##
#############################################################################
#############################################################################

#############################################################################
##
#R  IsSparseHashRep
##
##  The sparse representation for hash tables.  
##
DeclareRepresentation( "IsSparseHashRep",
    # as we will call `Enumerator' to get the *current* value list, a hash
    # table may not be attribute storing.
    IsComponentObjectRep and IsHash,
    ["KeyArray", "ValueArray", "HashFunct", "LengthArray",
     "LengthArrayHalf", # so we dont need to *2 to see overflow
     "NumberKeys"] );

BindGlobal("DefaultSparseHashRepType",
  NewType( DictionariesFamily, IsSparseHashRep ));

BindGlobal("DefaultSparseHashWithIKRepType",
  NewType( DictionariesFamily, IsSparseHashRep and TableHasIntKeyFun));

#############################################################################
##
#F  SparseHashTable([<intkeyfun>])
##
##  Construct an empty sparse hash table.  This is the only correct way to
##  construct such a table.
##  If the argument <intkeyfun> is given, this function will be used to
##  obtain numbers for the keys passed to it.
##
DeclareGlobalFunction( "SparseHashTable", [] );

#############################################################################
##
#F  GetHashEntryIndex( <hash>, <key> )
##
##  If the key is in hash, return its index in the hash array.
##
DeclareGlobalFunction( "GetHashEntryIndex", [ IsSparseHashRep, IsObject ] );

#############################################################################
##
#F  DoubleHashArraySize( <hash> )
##
##  Double the size of the hash array and rehash all the entries.
##  This will also happen automatically when the hash array is half full.
##
DeclareGlobalFunction( "DoubleHashArraySize", [ IsSparseHashRep ] );

# almost duplicate without any extras - thus faster
DeclareGlobalFunction( "DoubleHashDictSize");

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
##  This will be a good double hashing function for any reasonable KeyInt 
##  (see Cormen, Leiserson and Rivest, Introduction to Algorithms, 
##  1e, p. 235).
##
DeclareGlobalFunction( "HashFunct", [ IsInt, IsInt, IsInt ] );

#############################################################################
##
#O  DenseIntKey(<objcoll>,<obj>)
##
##  returns a function that can be used as hash key function for objects
##  such as <obj> in the collection <objcoll>. <objcoll> typically will be a
##  large domain.  If the domain is not available, it can be given as
##  `false' in which case the hash key function will be determined only
##  based on <obj>. (For a further discussion of these two arguments
##  see~`NewDictionary', section~"NewDictionary").
##
##  The function returned by `DenseIntKey' is guaranteed to give different
##  values for different objects.
##  If no suitable hash key function has beed predefined, `fail' is returned.
DeclareOperation("DenseIntKey",[IsObject,IsObject]);

#############################################################################
##
#O  SparseIntKey(<objcoll>,<obj>)
##
##  returns a function that can be used as hash key function for objects
##  such as <obj> in the collection <objcoll>. In contrast to `DenseIntKey',
##  the function returned may return the same key value for different
##  objects.
##  If no suitable hash key function has beed predefined, `fail' is returned.
DeclareOperation("SparseIntKey",[IsObject,IsObject]);


#############################################################################
#############################################################################
##
##  Fast access to last hash index
##
##  Index of last hash access or modification.
##  Note that this is global across all hash tables.  If you want to
##  have two hash tables with identical layouts, the following works:
##  GetHashEntry( hashTable1, object ); GetHashEntryAtLastIndex( hashTable2 );
##  These functions should be used with extreme care, as they bypass most
##  of the inbuilt error checking for hash tables.
##
#############################################################################
#############################################################################

#############################################################################
##
#O  GetHashEntryAtLastIndex( <hash> )
##
##  Returns the value of the last hash entry accessed.
##
DeclareOperation( "GetHashEntryAtLastIndex", [ IsHash ] );

#############################################################################
##
#O  SetHashEntryAtLastIndex( <hash>, <newValue> )
##
##  Resets the value of the last hash entry accessed.
##
DeclareOperation( "SetHashEntryAtLastIndex", [ IsHash, IsObject ] );

#############################################################################
##
#O  SetHashEntry( <hash>, <key>, <value> )
##
##  Resets the value corresponding to <key>.
##
DeclareOperation( "SetHashEntry", [ IsHash, IsObject, IsObject ] );

#############################################################################
##
##  AddHashEntryAtLastIndex( <hash>, <value> )
##
##  Check first if the last index has been set, and don't reset it if it has.
##  This operation has not yet been implemented
##
##DeclareOperation( "AddHashEntryAtLastIndex", [ IsHash, IsObject ] );

#E

